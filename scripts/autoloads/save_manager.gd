class_name SaveManagerClass
extends Node
## Centralized save/load system with versioned JSON schema.

const SAVE_PATH: String = "user://save_data.json"
const BACKUP_DIR: String = "user://backups/"
const SCHEMA_VERSION: int = 1

var current_data: Dictionary = {}


func _ready() -> void:
	current_data = get_default_save_data()


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
