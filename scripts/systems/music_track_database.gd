class_name MusicTrackDatabase
extends RefCounted

## Static catalog of all 33 music tracks. Provides metadata + file path
## resolution for the MusicManager.

const TRACKS: Array = [
	# Town
	{"id": &"town_main",            "title": "Globbler's Town",      "category": &"town",       "length": 150, "loop": true,  "volume": 1.0},
	{"id": &"town_night",           "title": "Town at Night",        "category": &"town",       "length": 150, "loop": true,  "volume": 1.0},
	{"id": &"district_residential", "title": "Home",                 "category": &"district",   "length": 90,  "loop": true,  "volume": 0.9},
	{"id": &"district_market",      "title": "Market Day",           "category": &"district",   "length": 90,  "loop": true,  "volume": 0.9},
	{"id": &"district_commons",     "title": "The Commons",          "category": &"district",   "length": 90,  "loop": true,  "volume": 0.9},
	{"id": &"district_workshop",    "title": "The Workshop",         "category": &"district",   "length": 90,  "loop": true,  "volume": 0.9},
	{"id": &"district_docks",       "title": "Down by the Docks",    "category": &"district",   "length": 90,  "loop": true,  "volume": 0.9},
	{"id": &"tavern_music",         "title": "Cache's Tavern",       "category": &"interior",   "length": 120, "loop": true,  "volume": 1.0},

	# Wilderness — generic (legacy / fallback)
	{"id": &"wilderness_day",       "title": "Open Sky",             "category": &"wilderness", "length": 150, "loop": true,  "volume": 1.0},
	{"id": &"wilderness_night",     "title": "Stars Above",          "category": &"wilderness", "length": 150, "loop": true,  "volume": 1.0},
	{"id": &"wilderness_storm",     "title": "The Glitch Storm",     "category": &"wilderness", "length": 120, "loop": true,  "volume": 1.0},

	# Wilderness — base wind drone (always-on bed at -18 dB beneath any region track)
	{"id": &"wild_base_wind_drone", "title": "The Long Wind",        "category": &"wilderness", "length": 240, "loop": true,  "volume": 1.0},

	# Wilderness — region tracks (one per sub-region in the bible)
	{"id": &"wild_plateau",         "title": "The Edge of Safe",     "category": &"wilderness", "length": 180, "loop": true,  "volume": 1.0},
	{"id": &"wild_river",           "title": "Half-Built Bridge",    "category": &"wilderness", "length": 180, "loop": true,  "volume": 1.0},
	{"id": &"wild_forest",          "title": "The Listening Tree",   "category": &"wilderness", "length": 180, "loop": true,  "volume": 1.0},
	{"id": &"wild_forest_night",    "title": "Choir of the Canopy",  "category": &"wilderness", "length": 180, "loop": true,  "volume": 1.0},
	{"id": &"wild_ruins",           "title": "Tilted Spire",         "category": &"wilderness", "length": 180, "loop": true,  "volume": 1.0},
	{"id": &"wild_ruins_night",     "title": "Glyphs at Midnight",   "category": &"wilderness", "length": 180, "loop": true,  "volume": 1.0},
	{"id": &"wild_cliffs",          "title": "The Four Mouths",      "category": &"wilderness", "length": 180, "loop": true,  "volume": 1.0},
	{"id": &"wild_pasture",         "title": "Where the Deer Come",  "category": &"wilderness", "length": 180, "loop": true,  "volume": 1.0},

	# Wilderness — weather music layers (sit on the weather slot above the base + region)
	{"id": &"wild_weather_rain",    "title": "Soft Rain Over Steel", "category": &"wilderness", "length": 120, "loop": true,  "volume": 1.0},
	{"id": &"wild_weather_storm",   "title": "Thunder Falls West",   "category": &"wilderness", "length": 120, "loop": true,  "volume": 1.0},
	{"id": &"wild_weather_fog",     "title": "Lost in the White",    "category": &"wilderness", "length": 120, "loop": true,  "volume": 1.0},
	{"id": &"wild_weather_glitch",  "title": "Sky Cracks Open",      "category": &"wilderness", "length": 120, "loop": true,  "volume": 1.0},

	# Dungeon biomes
	{"id": &"biome_server_room",     "title": "The Server",          "category": &"dungeon",    "length": 180, "loop": true,  "volume": 1.0},
	{"id": &"biome_memory_vaults",   "title": "Memory Vault",        "category": &"dungeon",    "length": 180, "loop": true,  "volume": 1.0},
	{"id": &"biome_corrupted_wilds", "title": "Wilds of Corruption", "category": &"dungeon",    "length": 180, "loop": true,  "volume": 1.0},
	{"id": &"biome_final_vault",     "title": "The Final Vault",     "category": &"dungeon",    "length": 210, "loop": true,  "volume": 1.0},

	# Combat layers (crossfade together)
	{"id": &"combat_l1",            "title": "Combat (light)",       "category": &"combat",     "length": 90,  "loop": true,  "volume": 1.0},
	{"id": &"combat_l2",            "title": "Combat (mid)",         "category": &"combat",     "length": 90,  "loop": true,  "volume": 1.0},
	{"id": &"combat_l3",            "title": "Combat (intense)",     "category": &"combat",     "length": 90,  "loop": true,  "volume": 1.0},

	# Boss themes
	{"id": &"boss_intro_sting",     "title": "Boss Approaches",      "category": &"sting",      "length": 8,   "loop": false, "volume": 1.0},
	{"id": &"boss_compiler",        "title": "The Corrupted Compiler","category": &"boss",      "length": 240, "loop": true,  "volume": 1.0},
	{"id": &"boss_memory_warden",   "title": "The Warden Awakens",   "category": &"boss",       "length": 240, "loop": true,  "volume": 1.0},
	{"id": &"boss_root_heart",      "title": "Heart of Corruption",  "category": &"boss",       "length": 240, "loop": true,  "volume": 1.0},
	{"id": &"boss_sentinel_prime",  "title": "Sentinel Override",    "category": &"boss",       "length": 240, "loop": true,  "volume": 1.0},
	{"id": &"boss_iteration_phantom","title": "Phantom Self",        "category": &"boss",       "length": 240, "loop": true,  "volume": 1.0},
	{"id": &"boss_compiler_reborn", "title": "End of Iteration",     "category": &"boss",       "length": 360, "loop": true,  "volume": 1.0},

	# Stings & jingles
	{"id": &"victory_fanfare",      "title": "Victory",              "category": &"sting",      "length": 5,   "loop": false, "volume": 1.0},
	{"id": &"defeat_sting",         "title": "System Failure",       "category": &"sting",      "length": 8,   "loop": false, "volume": 1.0},
	{"id": &"level_up_sting",       "title": "Level Up",             "category": &"sting",      "length": 4,   "loop": false, "volume": 1.0},
	{"id": &"iteration_reset",      "title": "Iteration Reset",      "category": &"cinematic",  "length": 30,  "loop": false, "volume": 1.0},

	# UI / Menu
	{"id": &"main_menu",            "title": "Boot",                 "category": &"menu",       "length": 150, "loop": true,  "volume": 1.0},
	{"id": &"credits",              "title": "End of Cycle",         "category": &"menu",       "length": 240, "loop": true,  "volume": 1.0},
	{"id": &"dialogue_ambient",     "title": "Conversation",         "category": &"ambient",    "length": 90,  "loop": true,  "volume": 0.6},
	{"id": &"forge_workshop",       "title": "The Forge",            "category": &"interior",   "length": 90,  "loop": true,  "volume": 0.8},
	{"id": &"archive_library",      "title": "The Archive",          "category": &"interior",   "length": 90,  "loop": true,  "volume": 0.8},
]

const AUDIO_BASE_PATH: String = "res://assets/audio/music/"

static var _index: Dictionary = {}


static func get_all() -> Array:
	return TRACKS


static func get_track(id: StringName) -> Dictionary:
	if _index.is_empty():
		_build_index()
	return _index.get(id, {})


static func _build_index() -> void:
	for t in TRACKS:
		_index[t["id"]] = t


static func get_file_path(id: StringName) -> String:
	return AUDIO_BASE_PATH + String(id) + ".ogg"


static func get_tracks_by_category(category: StringName) -> Array:
	var result: Array = []
	for t in TRACKS:
		if t["category"] == category:
			result.append(t)
	return result


static func count() -> int:
	return TRACKS.size()
