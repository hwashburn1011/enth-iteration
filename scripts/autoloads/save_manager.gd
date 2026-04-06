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
