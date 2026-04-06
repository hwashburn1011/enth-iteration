class_name SaveManagerClass
extends Node
## Centralized save/load system with versioned JSON schema.

const SAVE_PATH: String = "user://save_data.json"
const BACKUP_DIR: String = "user://backups/"
const SCHEMA_VERSION: int = 1

var current_data: Dictionary = {}
var last_save_time: float = 0.0
var _save_queued: bool = false
var _save_indicator: Label = null
var _item_registry: Script = null

const MIN_SAVE_INTERVAL: float = 10.0
const INDICATOR_DURATION: float = 1.5


func _ready() -> void:
	current_data = get_default_save_data()
	_item_registry = load("res://scripts/items/item_registry.gd")
	# Auto-save triggers
	EventBus.floor_completed.connect(_on_auto_save_trigger)
	EventBus.returned_to_town.connect(_on_auto_save_trigger_no_arg)
	EventBus.portal_used.connect(_on_auto_save_trigger_no_arg)
	EventBus.dungeon_entered.connect(_on_auto_save_trigger_no_arg)
	EventBus.game_saved.connect(_show_save_indicator)
	_create_save_indicator()


func _on_auto_save_trigger(_arg: Variant = null) -> void:
	_try_auto_save()


func _on_auto_save_trigger_no_arg() -> void:
	_try_auto_save()


func _try_auto_save() -> void:
	var now: float = Time.get_ticks_msec() / 1000.0
	if now - last_save_time < MIN_SAVE_INTERVAL:
		return
	# Queue if in combat
	if GameManager.has_meta(&"is_in_combat") and GameManager.get_meta(&"is_in_combat"):
		_save_queued = true
		if not EventBus.enemy_defeated.is_connected(_on_combat_may_have_ended):
			EventBus.enemy_defeated.connect(_on_combat_may_have_ended)
		return
	last_save_time = now
	save_game()


func _on_combat_may_have_ended(_t: StringName, _p: Vector3, _l: Resource) -> void:
	if _save_queued:
		# Check if still in combat (room not cleared) — simple heuristic
		_save_queued = false
		if EventBus.enemy_defeated.is_connected(_on_combat_may_have_ended):
			EventBus.enemy_defeated.disconnect(_on_combat_may_have_ended)
		last_save_time = Time.get_ticks_msec() / 1000.0
		save_game()


func _create_save_indicator() -> void:
	var canvas: CanvasLayer = CanvasLayer.new()
	canvas.layer = 90
	_save_indicator = Label.new()
	_save_indicator.text = "Saving..."
	_save_indicator.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_save_indicator.anchors_preset = Control.PRESET_TOP_RIGHT
	_save_indicator.offset_left = -120.0
	_save_indicator.offset_top = 10.0
	_save_indicator.offset_right = -10.0
	_save_indicator.offset_bottom = 40.0
	_save_indicator.modulate.a = 0.0
	canvas.add_child(_save_indicator)
	add_child(canvas)


func _show_save_indicator() -> void:
	if _save_indicator == null:
		return
	_save_indicator.modulate.a = 1.0
	var tween: Tween = create_tween()
	tween.tween_interval(INDICATOR_DURATION)
	tween.tween_property(_save_indicator, "modulate:a", 0.0, 0.3)


func new_game() -> void:
	current_data = get_default_save_data()
	# Reset GameManager state
	GameManager.recruited_npcs.clear()
	GameManager.newly_recruited.clear()
	GameManager.npc_affinity.clear()
	GameManager._talked_this_session.clear()
	GameManager.first_run = true
	GameManager.set_meta(&"highest_floor", 0)
	GameManager.set_meta(&"total_runs", 0)
	GameManager.set_meta(&"town_entry_type", "new_game")
	# Write initial save
	save_game()
	# Load town
	GameManager.change_scene_to("res://scenes/town/Town.tscn")


func save_game() -> bool:
	current_data = get_default_save_data()
	current_data["timestamp"] = Time.get_datetime_string_from_system()

	# 1. Player data
	var player: Node = _find_player()
	if player:
		current_data["player"]["health"] = player.health_component.current_health
		current_data["player"]["compute"] = player.compute_component.current_compute
		current_data["player"]["position"] = {
			"x": player.global_position.x,
			"y": player.global_position.y,
			"z": player.global_position.z,
		}
		current_data["player"]["stat_points"] = player.stats_component.level_points.duplicate()
		# Save level and XP from LevelComponent
		if player.level_component:
			current_data["player"]["level"] = player.level_component.current_level
			current_data["player"]["xp"] = player.level_component.current_xp
			current_data["player"]["xp_to_next"] = player.level_component.xp_to_next_level
			current_data["player"]["unspent_stat_points"] = player.level_component.unspent_stat_points
	# Save current scene path
	var scene_path: String = get_tree().current_scene.scene_file_path
	if scene_path != "":
		current_data["player"]["current_scene"] = scene_path

	# 2. Inventory data
	if player and player.inventory_component:
		var grid_items: Array = []
		var _seen_items: Array = []  # Track item instances to avoid multi-cell duplicates
		for y: int in player.inventory_component.grid_height:
			for x: int in player.inventory_component.grid_width:
				var item: Resource = player.inventory_component.grid[y][x] as Resource
				if item != null and item not in _seen_items:
					_seen_items.append(item)
					grid_items.append({
						"item_id": item.item_id,
						"grid_pos": [x, y],
						"durability": item.current_durability,
						"rarity": item.rarity,
						"stat_modifiers": item.get_effective_stat_modifiers() if item.has_method(&"get_effective_stat_modifiers") else item.stat_modifiers.duplicate(),
					})
		current_data["inventory"]["grid_items"] = grid_items
		var hotbar: Array = []
		for entry: Dictionary in player.inventory_component.prompt_hotbar:
			var prompt: Resource = entry["item"] as Resource
			hotbar.append({"item_id": prompt.item_id, "quantity": int(entry["quantity"])})
		current_data["inventory"]["prompt_hotbar"] = hotbar

	# 3. Equipment data
	if player and player.equipment_component:
		var eq: Node = player.equipment_component
		var modules: Array = []
		for m: Variant in eq.module_slots:
			modules.append(m.item_id if m else null)
		current_data["equipment"]["modules"] = modules
		current_data["equipment"]["core"] = eq.core_slot.item_id if eq.core_slot else null
		var chips: Array = []
		for c: Variant in eq.chip_slots:
			chips.append(c.item_id if c else null)
		current_data["equipment"]["chips"] = chips
		var protocols: Array = []
		for p: Variant in eq.protocol_slots:
			protocols.append(p.item_id if p else null)
		current_data["equipment"]["protocols"] = protocols

	# 4. Town data
	current_data["town"]["recruited_npcs"] = GameManager.recruited_npcs.duplicate()
	current_data["town"]["npc_affinity"] = GameManager.npc_affinity.duplicate()
	current_data["town"]["expansion_stage"] = GameManager.recruited_npcs.size()

	# 5. Dungeon data (stored on GameManager)
	current_data["dungeon"]["highest_floor_reached"] = GameManager.get_meta(&"highest_floor", 0) as int
	current_data["dungeon"]["total_runs"] = GameManager.get_meta(&"total_runs", 0) as int

	# Create backup before writing
	_create_backup()

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
		# Try backups sequentially
		for i: int in range(1, 4):
			push_warning("SaveManager: trying backup %d..." % i)
			data = _read_save_file(_backup_path(i))
			if not data.is_empty():
				break
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


func _backup_path(index: int) -> String:
	return BACKUP_DIR + "save_backup_%d.json" % index


func _create_backup() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	DirAccess.make_dir_recursive_absolute(BACKUP_DIR)
	# Rotate: 2→3, 1→2
	if FileAccess.file_exists(_backup_path(2)):
		DirAccess.copy_absolute(_backup_path(2), _backup_path(3))
	if FileAccess.file_exists(_backup_path(1)):
		DirAccess.copy_absolute(_backup_path(1), _backup_path(2))
	# Current save → backup 1
	DirAccess.copy_absolute(SAVE_PATH, _backup_path(1))


func load_backup(index: int = 1) -> bool:
	var data: Dictionary = _read_save_file(_backup_path(index))
	if data.is_empty():
		return false
	var version: int = data.get("schema_version", 0) as int
	if version < SCHEMA_VERSION:
		data = _migrate_save(data, version, SCHEMA_VERSION)
	current_data = data
	_apply_loaded_data(data)
	EventBus.game_loaded.emit()
	return true


func has_valid_save() -> bool:
	if FileAccess.file_exists(SAVE_PATH):
		var data: Dictionary = _read_save_file(SAVE_PATH)
		if not data.is_empty():
			return true
	for i: int in range(1, 4):
		if FileAccess.file_exists(_backup_path(i)):
			var data: Dictionary = _read_save_file(_backup_path(i))
			if not data.is_empty():
				return true
	return false


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


func apply_to_player(player: Node) -> void:
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

	# Restore level and XP
	if player.level_component:
		player.level_component.current_level = int(pdata.get("level", 1))
		player.level_component.current_xp = int(pdata.get("xp", 0))
		player.level_component.xp_to_next_level = int(pdata.get("xp_to_next", player.level_component.xp_to_next_level))
		player.level_component.unspent_stat_points = int(pdata.get("unspent_stat_points", 0))

	# Inventory
	var inv_data: Dictionary = get_meta(&"pending_inventory_data", {}) as Dictionary
	var grid_items: Array = inv_data.get("grid_items", []) as Array
	for entry: Variant in grid_items:
		var e: Dictionary = entry as Dictionary
		var item: Resource = _item_registry.create_item(
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
		var prompt: Resource = _item_registry.create_item(str(e.get("item_id", "")))
		if prompt and prompt.get("item_type") == "prompt":
			for i: int in int(e.get("quantity", 1)):
				player.inventory_component.add_prompt(prompt)

	# Equipment
	var eq_data: Dictionary = get_meta(&"pending_equipment_data", {}) as Dictionary
	var modules: Array = eq_data.get("modules", []) as Array
	for i: int in modules.size():
		if modules[i] != null:
			var item: Resource = _item_registry.create_item(str(modules[i]))
			if item:
				player.equipment_component.equip(item, i)
	var core_id: Variant = eq_data.get("core")
	if core_id != null:
		var item: Resource = _item_registry.create_item(str(core_id))
		if item:
			player.equipment_component.equip(item)
	var chips: Array = eq_data.get("chips", []) as Array
	for i: int in chips.size():
		if chips[i] != null:
			var item: Resource = _item_registry.create_item(str(chips[i]))
			if item:
				player.equipment_component.equip(item, i)
	var protocols: Array = eq_data.get("protocols", []) as Array
	for i: int in protocols.size():
		if protocols[i] != null:
			var item: Resource = _item_registry.create_item(str(protocols[i]))
			if item:
				player.equipment_component.equip(item, i)

	# Clean up pending data
	remove_meta(&"pending_player_data")
	remove_meta(&"pending_inventory_data")
	remove_meta(&"pending_equipment_data")


func _find_player() -> Node:
	var nodes: Array[Node] = get_tree().get_nodes_in_group(&"player")
	if nodes.size() > 0:
		return nodes[0]
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
