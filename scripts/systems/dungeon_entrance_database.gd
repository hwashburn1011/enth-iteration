class_name DungeonEntranceDatabase
extends RefCounted

## Static catalog of all 4 dungeon entrances with unlock conditions, themes,
## difficulty, and lore plaques.

const ENTRANCES: Array = [
	{
		"id": &"server_room",
		"display_name": "Server Room Portal",
		"biome_id": &"server_room",
		"location_zone": &"wilderness_clearings",
		"difficulty_stars": 1,
		"max_difficulty_stars": 5,
		"recommended_level": 1,
		"unlock_iteration": 1,
		"unlock_quest": &"",  # available from start
		"theme_color": Color(0.20, 0.40, 0.85),
		"music_sting": &"biome_server_room",
		"lore_plaque": "All processes begin here. All processes return.",
		"first_time_cinematic": &"first_compaction",
		"floor_count": 5,
		"boss_id": &"corrupted_compiler",
		"approach_path_visible": true,
	},
	{
		"id": &"memory_vaults",
		"display_name": "Memory Vaults Portal",
		"biome_id": &"memory_vaults",
		"location_zone": &"wilderness_lake",
		"difficulty_stars": 2,
		"max_difficulty_stars": 5,
		"recommended_level": 8,
		"unlock_iteration": 2,
		"unlock_quest": &"main_08_other_side",
		"theme_color": Color(0.78, 0.65, 0.20),
		"music_sting": &"biome_memory_vaults",
		"lore_plaque": "What the system forgets, the vault remembers.",
		"first_time_cinematic": &"vault_first_entry",
		"floor_count": 5,
		"boss_id": &"memory_warden",
		"approach_path_visible": false,
	},
	{
		"id": &"corrupted_wilds",
		"display_name": "Corrupted Wilds Portal",
		"biome_id": &"corrupted_wilds",
		"location_zone": &"wilderness_cave",
		"difficulty_stars": 3,
		"max_difficulty_stars": 5,
		"recommended_level": 15,
		"unlock_iteration": 3,
		"unlock_quest": &"main_14_glitch",
		"theme_color": Color(0.55, 0.20, 0.85),
		"music_sting": &"biome_corrupted_wilds",
		"lore_plaque": "Where the rot meets the code.",
		"first_time_cinematic": &"wilds_first_entry",
		"floor_count": 5,
		"boss_id": &"root_heart",
		"approach_path_visible": false,
	},
	{
		"id": &"final_vault",
		"display_name": "Final Vault Portal",
		"biome_id": &"final_vault",
		"location_zone": &"town_commons",
		"difficulty_stars": 5,
		"max_difficulty_stars": 5,
		"recommended_level": 30,
		"unlock_iteration": 8,
		"unlock_quest": &"main_36_user_speaks",
		"theme_color": Color(0.10, 0.05, 0.15),
		"music_sting": &"biome_final_vault",
		"lore_plaque": "The final question. The final answer.",
		"first_time_cinematic": &"final_vault_first_entry",
		"floor_count": 5,
		"boss_id": &"compiler_reborn",
		"approach_path_visible": false,
	},
]

static var _index: Dictionary = {}


static func get_all() -> Array:
	return ENTRANCES


static func get_entrance(id: StringName) -> Dictionary:
	if _index.is_empty():
		for e in ENTRANCES:
			_index[e["id"]] = e
	return _index.get(id, {})


static func get_for_biome(biome_id: StringName) -> Dictionary:
	for e in ENTRANCES:
		if e["biome_id"] == biome_id:
			return e
	return {}


static func count() -> int:
	return ENTRANCES.size()
