class_name MinigameDatabase
extends RefCounted

## Static metadata for all 8 minigames. Drives the minigame system + UI.

const MINIGAMES: Array = [
	{
		"id": &"terminal_hacking",
		"name": "Terminal Hacking",
		"theme": "Match a glowing pattern of code symbols.",
		"category": &"sequence",
		"world_object": &"hacking_terminal",
		"placement": &"dungeon_terminals",
		"base_reward": {"cache_crystal": 1, "pure_code": 1},
		"difficulties": [
			{"name": "Easy",   "params": {"symbols": 4}},
			{"name": "Normal", "params": {"symbols": 6}},
			{"name": "Hard",   "params": {"symbols": 8}},
			{"name": "Expert", "params": {"symbols": 10}},
		],
	},
	{
		"id": &"memory_match",
		"name": "Memory Match",
		"theme": "Match pairs of memory tiles.",
		"category": &"memory",
		"world_object": &"memory_crystal",
		"placement": &"vault_crystals",
		"base_reward": {"memory_glass": 1, "lore_tablet": 1},
		"difficulties": [
			{"name": "Easy",   "params": {"pairs": 4}},
			{"name": "Normal", "params": {"pairs": 8}},
			{"name": "Hard",   "params": {"pairs": 12}},
			{"name": "Expert", "params": {"pairs": 16}},
		],
	},
	{
		"id": &"code_compile",
		"name": "Code Compile",
		"theme": "Drag operation blocks into the right order.",
		"category": &"logic",
		"world_object": &"code_console",
		"placement": &"story_rooms",
		"base_reward": {"algorithm_stone": 1},
		"difficulties": [
			{"name": "Easy",   "params": {"ops": 3}},
			{"name": "Normal", "params": {"ops": 5}},
			{"name": "Hard",   "params": {"ops": 7}},
			{"name": "Expert", "params": {"ops": 10}},
		],
	},
	{
		"id": &"data_sort",
		"name": "Data Sort",
		"theme": "Sort falling data packets into the right bins.",
		"category": &"reaction",
		"world_object": &"sort_terminal",
		"placement": &"server_room",
		"base_reward": {"bit_fragment": 3, "wire": 1},
		"difficulties": [
			{"name": "Easy",   "params": {"bins": 3, "speed": 1.0}},
			{"name": "Normal", "params": {"bins": 4, "speed": 1.3}},
			{"name": "Hard",   "params": {"bins": 5, "speed": 1.7}},
			{"name": "Expert", "params": {"bins": 6, "speed": 2.2}},
		],
	},
	{
		"id": &"fishing",
		"name": "Fishing",
		"theme": "Hold the catch zone over the fish icon.",
		"category": &"rhythm",
		"world_object": &"fishing_spot",
		"placement": &"docks_river",
		"base_reward": {},  # rewards driven by FishDatabase
		"difficulties": [
			{"name": "Calm",     "params": {"behavior": "calm"}},
			{"name": "Erratic",  "params": {"behavior": "erratic"}},
			{"name": "Sinker",   "params": {"behavior": "sinker"}},
			{"name": "Dasher",   "params": {"behavior": "dasher"}},
		],
	},
	{
		"id": &"cooking",
		"name": "Cooking",
		"theme": "Add ingredients in the right order, watch heat, stir at intervals.",
		"category": &"resource_mgmt",
		"world_object": &"cooking_station",
		"placement": &"tavern",
		"base_reward": {"cooked_food": 1},
		"difficulties": [
			{"name": "Easy",   "params": {"ingredients": 2}},
			{"name": "Normal", "params": {"ingredients": 3}},
			{"name": "Hard",   "params": {"ingredients": 4}},
			{"name": "Expert", "params": {"ingredients": 5}},
		],
	},
	{
		"id": &"lockpicking",
		"name": "Lockpicking",
		"theme": "Stop a moving cursor inside narrow target zones.",
		"category": &"precision",
		"world_object": &"locked_container",
		"placement": &"dungeon_chests",
		"base_reward": {"gold": 50},
		"difficulties": [
			{"name": "Wide",     "params": {"zone_width": 0.30, "zones": 1}},
			{"name": "Narrow",   "params": {"zone_width": 0.18, "zones": 2}},
			{"name": "VNarrow",  "params": {"zone_width": 0.10, "zones": 2}},
			{"name": "Moving",   "params": {"zone_width": 0.10, "zones": 3, "moving": true}},
		],
	},
	{
		"id": &"music_sync",
		"name": "Music Sync",
		"theme": "Press correct keys in time with a scrolling note track.",
		"category": &"rhythm",
		"world_object": &"music_station",
		"placement": &"sync_lounge",
		"base_reward": {"affinity": {"sync": 10}},
		"difficulties": [
			{"name": "Easy",   "params": {"note_speed": 1.0}},
			{"name": "Normal", "params": {"note_speed": 1.5}},
			{"name": "Hard",   "params": {"note_speed": 2.0}},
			{"name": "Master", "params": {"note_speed": 2.8}},
		],
	},
]

const MASTERY_REWARDS: Dictionary = {
	3: "practice_mode",
	5: "cosmetic_decoration",
	8: "title_unlock",
	10: "legendary_quest",
}

static var _index: Dictionary = {}


static func get_all() -> Array:
	return MINIGAMES


static func get_minigame(id: StringName) -> Dictionary:
	if _index.is_empty():
		_build_index()
	return _index.get(id, {})


static func _build_index() -> void:
	for m in MINIGAMES:
		_index[m["id"]] = m


static func get_difficulty_params(id: StringName, difficulty_index: int) -> Dictionary:
	var m: Dictionary = get_minigame(id)
	if m.is_empty():
		return {}
	var diffs: Array = m.get("difficulties", [])
	if difficulty_index < 0 or difficulty_index >= diffs.size():
		return {}
	return diffs[difficulty_index].get("params", {})


static func get_difficulty_name(id: StringName, difficulty_index: int) -> String:
	var m: Dictionary = get_minigame(id)
	var diffs: Array = m.get("difficulties", [])
	if difficulty_index < 0 or difficulty_index >= diffs.size():
		return ""
	return diffs[difficulty_index].get("name", "")


static func count() -> int:
	return MINIGAMES.size()
