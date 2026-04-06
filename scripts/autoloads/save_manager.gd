class_name SaveManagerClass
extends Node
## Centralized save/load system with versioned JSON schema.

const SAVE_PATH: String = "user://save_data.json"
const BACKUP_DIR: String = "user://backups/"
const SCHEMA_VERSION: int = 1

var current_data: Dictionary = {}


func _ready() -> void:
	current_data = get_default_save_data()


func save_game() -> bool:
	current_data = get_default_save_data()
	current_data["timestamp"] = Time.get_datetime_string_from_system()

	# 1. Player data
	var player: Player = _find_player()
	if player:
		current_data["player"]["health"] = player.health_component.current_health
		current_data["player"]["compute"] = player.compute_component.current_compute
		current_data["player"]["position"] = {
			"x": player.global_position.x,
			"y": player.global_position.y,
			"z": player.global_position.z,
		}
		current_data["player"]["stat_points"] = player.stats_component.level_points.duplicate()

	# 2. Inventory data
	if player and player.inventory_component:
		var grid_items: Array = []
		for y: int in player.inventory_component.grid_height:
			for x: int in player.inventory_component.grid_width:
				var item: ItemBase = player.inventory_component.grid[y][x] as ItemBase
				if item != null:
					# Avoid duplicates (multi-cell items)
					var already: bool = false
					for entry: Dictionary in grid_items:
						if entry.get("grid_pos", []) == [x, y]:
							already = true
							break
					if not already:
						grid_items.append({
							"item_id": item.item_id,
							"grid_pos": [x, y],
							"durability": item.current_durability,
							"rarity": item.rarity,
							"stat_modifiers": item.stat_modifiers.duplicate(),
						})
		current_data["inventory"]["grid_items"] = grid_items
		var hotbar: Array = []
		for entry: Dictionary in player.inventory_component.prompt_hotbar:
			var prompt: PromptItem = entry["item"] as PromptItem
			hotbar.append({"item_id": prompt.item_id, "quantity": int(entry["quantity"])})
		current_data["inventory"]["prompt_hotbar"] = hotbar

	# 3. Equipment data
	if player and player.equipment_component:
		var eq: EquipmentComponent = player.equipment_component
		var modules: Array = []
		for m: ModuleItem in eq.module_slots:
			modules.append(m.item_id if m else null)
		current_data["equipment"]["modules"] = modules
		current_data["equipment"]["core"] = eq.core_slot.item_id if eq.core_slot else null
		var chips: Array = []
		for c: ChipItem in eq.chip_slots:
			chips.append(c.item_id if c else null)
		current_data["equipment"]["chips"] = chips
		var protocols: Array = []
		for p: ProtocolItem in eq.protocol_slots:
			protocols.append(p.item_id if p else null)
		current_data["equipment"]["protocols"] = protocols

	# 4. Town data
	current_data["town"]["recruited_npcs"] = GameManager.recruited_npcs.duplicate()
	current_data["town"]["npc_affinity"] = GameManager.npc_affinity.duplicate()
	current_data["town"]["expansion_stage"] = GameManager.recruited_npcs.size()

	# 5. Dungeon data (stored on GameManager)
	current_data["dungeon"]["highest_floor_reached"] = GameManager.get_meta(&"highest_floor", 0) as int
	current_data["dungeon"]["total_runs"] = GameManager.get_meta(&"total_runs", 0) as int

	# Write to file
	var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_error("SaveManager: failed to open save file — %s" % FileAccess.get_open_error())
		return false
	file.store_string(JSON.stringify(current_data, "\t"))
	file.close()
	EventBus.game_saved.emit()
	return true


func load_game() -> bool:
	var data: Dictionary = _read_save_file(SAVE_PATH)
	if data.is_empty():
		# Try most recent backup
		data = _try_load_backup()
		if data.is_empty():
			push_error("SaveManager: no valid save file or backup found")
			return false

	# Validate and migrate schema
	var version: int = data.get("schema_version", 0) as int
	if version < SCHEMA_VERSION:
		data = _migrate_save(data, version, SCHEMA_VERSION)

	current_data = data
	_apply_loaded_data(data)
	EventBus.game_loaded.emit()
	return true


func has_save_file() -> bool:
	return FileAccess.file_exists(SAVE_PATH)


func _read_save_file(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("SaveManager: failed to open '%s'" % path)
		return {}
	var content: String = file.get_as_text()
	file.close()
	var parsed: Variant = JSON.parse_string(content)
	if parsed is Dictionary:
		return parsed as Dictionary
	push_error("SaveManager: corrupted save file '%s'" % path)
	return {}


func _migrate_save(data: Dictionary, from_version: int, to_version: int) -> Dictionary:
	# Sequential migration — add cases as schema evolves
	var migrated: Dictionary = data
	for v: int in range(from_version, to_version):
		match v:
			0:
				# v0 → v1: fill missing fields with defaults
				var defaults: Dictionary = get_default_save_data()
				for key: String in defaults:
					if key not in migrated:
						migrated[key] = defaults[key]
				migrated["schema_version"] = 1
	return migrated


func _try_load_backup() -> Dictionary:
	if not DirAccess.dir_exists_absolute(BACKUP_DIR):
		return {}
	var dir: DirAccess = DirAccess.open(BACKUP_DIR)
	if dir == null:
		return {}
	var files: PackedStringArray = dir.get_files()
	if files.is_empty():
		return {}
	# Try most recent backup (last alphabetically — timestamped names)
	files.sort()
	for i: int in range(files.size() - 1, -1, -1):
		var data: Dictionary = _read_save_file(BACKUP_DIR + files[i])
		if not data.is_empty():
			return data
	return {}


func _apply_loaded_data(data: Dictionary) -> void:
	var defaults: Dictionary = get_default_save_data()

	# 4. Town data — restore to GameManager first (before scene loads)
	var town: Dictionary = data.get("town", defaults["town"]) as Dictionary
	GameManager.recruited_npcs.clear()
	for npc_id: Variant in town.get("recruited_npcs", []):
		GameManager.recruited_npcs.append(str(npc_id))
	GameManager.npc_affinity = {}
	var affinity_data: Dictionary = town.get("npc_affinity", {}) as Dictionary
	for npc_id: String in affinity_data:
		GameManager.npc_affinity[npc_id] = int(affinity_data[npc_id])

	# 5. Dungeon data
	var dungeon: Dictionary = data.get("dungeon", defaults["dungeon"]) as Dictionary
	GameManager.set_meta(&"highest_floor", int(dungeon.get("highest_floor_reached", 0)))
	GameManager.set_meta(&"total_runs", int(dungeon.get("total_runs", 0)))

	# Player, inventory, and equipment are applied after scene load
	# (player node must exist). Store data for deferred application.
	set_meta(&"pending_player_data", data.get("player", defaults["player"]))
	set_meta(&"pending_inventory_data", data.get("inventory", defaults["inventory"]))
	set_meta(&"pending_equipment_data", data.get("equipment", defaults["equipment"]))


func apply_to_player(player: Player) -> void:
	## Called after player is instantiated to restore saved state.
	if not has_meta(&"pending_player_data"):
		return
	var pdata: Dictionary = get_meta(&"pending_player_data") as Dictionary
	player.health_component.max_health = float(pdata.get("health", 100.0))
	player.health_component.current_health = float(pdata.get("health", 100.0))
	player.compute_component.current_compute = float(pdata.get("compute", 50.0))
	var pos: Dictionary = pdata.get("position", {}) as Dictionary
	player.global_position = Vector3(
		float(pos.get("x", 0.0)),
		float(pos.get("y", 0.0)),
		float(pos.get("z", 0.0))
	)
	var stat_pts: Dictionary = pdata.get("stat_points", {}) as Dictionary
	for stat_name: String in stat_pts:
		player.stats_component.level_points[stat_name] = int(stat_pts[stat_name])

	# Inventory
	var inv_data: Dictionary = get_meta(&"pending_inventory_data", {}) as Dictionary
	var grid_items: Array = inv_data.get("grid_items", []) as Array
	for entry: Variant in grid_items:
		var e: Dictionary = entry as Dictionary
		var item: ItemBase = ItemRegistry.create_item(
			str(e.get("item_id", "")),
			float(e.get("durability", 100.0)),
			e.get("stat_modifiers", {}) as Dictionary,
			int(e.get("rarity", 0))
		)
		if item:
			player.inventory_component.add_item(item)
	var hotbar: Array = inv_data.get("prompt_hotbar", []) as Array
	for entry: Variant in hotbar:
		var e: Dictionary = entry as Dictionary
		var prompt: ItemBase = ItemRegistry.create_item(str(e.get("item_id", "")))
		if prompt is PromptItem:
			for i: int in int(e.get("quantity", 1)):
				player.inventory_component.add_prompt(prompt as PromptItem)

	# Equipment
	var eq_data: Dictionary = get_meta(&"pending_equipment_data", {}) as Dictionary
	var modules: Array = eq_data.get("modules", []) as Array
	for i: int in modules.size():
		if modules[i] != null:
			var item: ItemBase = ItemRegistry.create_item(str(modules[i]))
			if item:
				player.equipment_component.equip(item, i)
	var core_id: Variant = eq_data.get("core")
	if core_id != null:
		var item: ItemBase = ItemRegistry.create_item(str(core_id))
		if item:
			player.equipment_component.equip(item)
	var chips: Array = eq_data.get("chips", []) as Array
	for i: int in chips.size():
		if chips[i] != null:
			var item: ItemBase = ItemRegistry.create_item(str(chips[i]))
			if item:
				player.equipment_component.equip(item, i)
	var protocols: Array = eq_data.get("protocols", []) as Array
	for i: int in protocols.size():
		if protocols[i] != null:
			var item: ItemBase = ItemRegistry.create_item(str(protocols[i]))
			if item:
				player.equipment_component.equip(item, i)

	# Clean up pending data
	remove_meta(&"pending_player_data")
	remove_meta(&"pending_inventory_data")
	remove_meta(&"pending_equipment_data")


func _find_player() -> Player:
	var nodes: Array[Node] = get_tree().get_nodes_in_group(&"player")
	if nodes.size() > 0:
		return nodes[0] as Player
	return null


func get_default_save_data() -> Dictionary:
	return {
		"schema_version": SCHEMA_VERSION,
		"timestamp": "",
		"player": {
			"level": 1,
			"xp": 0,
			"stat_points": {
				"processing": 0,
				"bandwidth": 0,
				"memory": 0,
				"integrity": 0,
			},
			"health": 100.0,
			"compute": 50.0,
			"position": {"x": 0.0, "y": 0.0, "z": 0.0},
			"current_scene": "res://scenes/town/Town.tscn",
		},
		"inventory": {
			"grid_items": [],
			"prompt_hotbar": [],
		},
		"equipment": {
			"modules": [null, null, null, null],
			"core": null,
			"chips": [null, null, null, null],
			"protocols": [null, null, null],
		},
		"town": {
			"recruited_npcs": [],
			"npc_affinity": {},
			"expansion_stage": 0,
		},
		"dungeon": {
			"highest_floor_reached": 0,
			"total_runs": 0,
		},
		"quests": {
			"active": [],
			"completed": [],
		},
		"settings": {
			"master_volume": 1.0,
			"music_volume": 0.8,
			"sfx_volume": 1.0,
		},
	}
