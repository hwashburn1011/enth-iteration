class_name DecorationDatabase
extends RefCounted

## Static catalog of all 50 placeable decorations. Each entry has the
## category, theme, rarity, footprint, recipe ingredients, and any
## interactive behavior.

const DECORATIONS: Array = [
	# === SMALL (15) ===
	{"id": &"deco_flower_pot",     "name": "Flower Pot",     "cat": &"small", "theme": &"natural", "rarity": 0, "size": Vector2i(1, 1), "ing": {&"patch": 1, &"bytewood": 1}},
	{"id": &"deco_data_lamp",      "name": "Data Lamp",      "cat": &"small", "theme": &"tech",    "rarity": 0, "size": Vector2i(1, 1), "ing": {&"wire": 1, &"cache_crystal": 1}},
	{"id": &"deco_coffee_mug",     "name": "Coffee Mug",     "cat": &"small", "theme": &"cozy",    "rarity": 0, "size": Vector2i(1, 1), "ing": {&"bit_fragment": 2}},
	{"id": &"deco_terminal",       "name": "Terminal",       "cat": &"small", "theme": &"tech",    "rarity": 0, "size": Vector2i(1, 1), "ing": {&"wire": 2, &"server_coil": 1}},
	{"id": &"deco_plant_sprout",   "name": "Plant Sprout",   "cat": &"small", "theme": &"natural", "rarity": 0, "size": Vector2i(1, 1), "ing": {&"patch": 1}},
	{"id": &"deco_bit_sculpture",  "name": "Bit Sculpture",  "cat": &"small", "theme": &"ornate",  "rarity": 1, "size": Vector2i(1, 1), "ing": {&"algorithm_stone": 2}},
	{"id": &"deco_cache_cube",     "name": "Cache Cube",     "cat": &"small", "theme": &"tech",    "rarity": 0, "size": Vector2i(1, 1), "ing": {&"cache_crystal": 3}},
	{"id": &"deco_glow_mushroom",  "name": "Glow Mushroom",  "cat": &"small", "theme": &"glitch",  "rarity": 1, "size": Vector2i(1, 1), "ing": {&"glowmoss": 2}},
	{"id": &"deco_tiny_statue",    "name": "Tiny Statue",    "cat": &"small", "theme": &"ornate",  "rarity": 1, "size": Vector2i(1, 1), "ing": {&"compiled_steel": 1}},
	{"id": &"deco_tea_set",        "name": "Tea Set",        "cat": &"small", "theme": &"cozy",    "rarity": 0, "size": Vector2i(1, 1), "ing": {&"patch": 2}},
	{"id": &"deco_code_scroll",    "name": "Code Scroll",    "cat": &"small", "theme": &"ornate",  "rarity": 1, "size": Vector2i(1, 1), "ing": {&"dyed_thread": 1}},
	{"id": &"deco_wind_chime",     "name": "Wind Chime",     "cat": &"small", "theme": &"natural", "rarity": 0, "size": Vector2i(1, 1), "ing": {&"cache_crystal": 2}},
	{"id": &"deco_memory_ball",    "name": "Memory Ball",    "cat": &"small", "theme": &"glitch",  "rarity": 1, "size": Vector2i(1, 1), "ing": {&"memory_glass": 1}},
	{"id": &"deco_nightlight",     "name": "Nightlight",     "cat": &"small", "theme": &"cozy",    "rarity": 0, "size": Vector2i(1, 1), "ing": {&"wire": 1, &"cache_crystal": 2}},
	{"id": &"deco_crystal_cluster","name": "Crystal Cluster","cat": &"small", "theme": &"ornate",  "rarity": 1, "size": Vector2i(1, 1), "ing": {&"cache_crystal": 3}},

	# === MEDIUM (15) ===
	{"id": &"deco_bookshelf",      "name": "Bookshelf",      "cat": &"medium","theme": &"cozy",    "rarity": 0, "size": Vector2i(2, 2), "ing": {&"bytewood": 5, &"patch": 2}},
	{"id": &"deco_cozy_sofa",      "name": "Cozy Sofa",      "cat": &"medium","theme": &"cozy",    "rarity": 1, "size": Vector2i(2, 2), "ing": {&"patch": 4, &"dyed_thread": 2}},
	{"id": &"deco_server_rack",    "name": "Server Rack",    "cat": &"medium","theme": &"tech",    "rarity": 1, "size": Vector2i(2, 2), "ing": {&"wire": 3, &"server_coil": 2}},
	{"id": &"deco_coffee_table",   "name": "Coffee Table",   "cat": &"medium","theme": &"cozy",    "rarity": 0, "size": Vector2i(2, 2), "ing": {&"bytewood": 3}},
	{"id": &"deco_tech_desk",      "name": "Tech Desk",      "cat": &"medium","theme": &"tech",    "rarity": 1, "size": Vector2i(2, 2), "ing": {&"compiled_steel": 3, &"server_coil": 1}},
	{"id": &"deco_wardrobe",       "name": "Wardrobe",       "cat": &"medium","theme": &"cozy",    "rarity": 0, "size": Vector2i(2, 2), "ing": {&"bytewood": 4, &"patch": 2}},
	{"id": &"deco_decor_plant",    "name": "Decor Plant",    "cat": &"medium","theme": &"natural", "rarity": 0, "size": Vector2i(2, 2), "ing": {&"logleaf": 2, &"patch": 1}},
	{"id": &"deco_dining_table",   "name": "Dining Table",   "cat": &"medium","theme": &"cozy",    "rarity": 1, "size": Vector2i(2, 2), "ing": {&"bytewood": 4, &"dyed_thread": 1}},
	{"id": &"deco_workbench",      "name": "Workbench",      "cat": &"medium","theme": &"tech",    "rarity": 0, "size": Vector2i(2, 2), "ing": {&"compiled_steel": 3}},
	{"id": &"deco_display_case",   "name": "Display Case",   "cat": &"medium","theme": &"ornate",  "rarity": 1, "size": Vector2i(2, 2), "ing": {&"memory_glass": 3}},
	{"id": &"deco_tatami_mat",     "name": "Tatami Mat",     "cat": &"medium","theme": &"natural", "rarity": 1, "size": Vector2i(2, 2), "ing": {&"patch": 4, &"dyed_thread": 1}},
	{"id": &"deco_mini_forge",     "name": "Mini Forge",     "cat": &"medium","theme": &"tech",    "rarity": 2, "size": Vector2i(2, 2), "ing": {&"compiled_steel": 2, &"quantum_shard": 1}},
	{"id": &"deco_garden_bench",   "name": "Garden Bench",   "cat": &"medium","theme": &"natural", "rarity": 0, "size": Vector2i(2, 2), "ing": {&"bytewood": 3, &"patch": 1}},
	{"id": &"deco_music_player",   "name": "Music Player",   "cat": &"medium","theme": &"tech",    "rarity": 1, "size": Vector2i(2, 2), "ing": {&"server_coil": 2, &"dyed_thread": 1}},
	{"id": &"deco_holo_globe",     "name": "Holo Globe",     "cat": &"medium","theme": &"glitch",  "rarity": 2, "size": Vector2i(2, 2), "ing": {&"memory_glass": 2, &"algorithm_stone": 1}},

	# === LARGE (10) ===
	{"id": &"deco_stone_statue",   "name": "Stone Statue",   "cat": &"large", "theme": &"ornate",  "rarity": 1, "size": Vector2i(3, 3), "ing": {&"compiled_steel": 5}},
	{"id": &"deco_player_bed",     "name": "Player Bed",     "cat": &"large", "theme": &"cozy",    "rarity": 1, "size": Vector2i(3, 3), "ing": {&"patch": 5, &"bytewood": 3, &"dyed_thread": 1}},
	{"id": &"deco_holo_projector", "name": "Holo-Projector", "cat": &"large", "theme": &"tech",    "rarity": 2, "size": Vector2i(3, 3), "ing": {&"memory_glass": 4, &"algorithm_stone": 2}},
	{"id": &"deco_grand_fountain", "name": "Grand Fountain", "cat": &"large", "theme": &"ornate",  "rarity": 2, "size": Vector2i(3, 3), "ing": {&"compiled_steel": 4, &"quantum_shard": 2}},
	{"id": &"deco_master_bookshelf","name": "Master Bookshelf","cat": &"large","theme": &"cozy",    "rarity": 1, "size": Vector2i(3, 3), "ing": {&"bytewood": 8, &"patch": 4}},
	{"id": &"deco_iteration_monument","name": "Iteration Monument","cat": &"large","theme": &"glitch","rarity": 3, "size": Vector2i(3, 3), "ing": {&"iteration_echo": 1}, "story_unlock": true},
	{"id": &"deco_compiler_statue","name": "Compiler's Statue","cat": &"large","theme": &"glitch","rarity": 3, "size": Vector2i(3, 3), "ing": {&"boss_soul": 1}, "story_unlock": true},
	{"id": &"deco_sages_tree",     "name": "Sage's Tree",    "cat": &"large", "theme": &"natural", "rarity": 3, "size": Vector2i(3, 3), "ing": {&"logleaf": 5, &"sages_tear": 1}},
	{"id": &"deco_throne",         "name": "Throne",         "cat": &"large", "theme": &"ornate",  "rarity": 3, "size": Vector2i(3, 3), "ing": {&"compiled_steel": 5, &"dream_silk": 2}},
	{"id": &"deco_compaction_pillar","name": "Compaction Pillar","cat": &"large","theme": &"glitch","rarity": 3, "size": Vector2i(3, 3), "ing": {&"compaction_heart": 1}, "story_unlock": true},

	# === INTERACTIVE (10) ===
	{"id": &"deco_jukebox",        "name": "Jukebox",        "cat": &"inter", "theme": &"tech",    "rarity": 2, "size": Vector2i(2, 2), "ing": {&"server_coil": 3, &"quantum_shard": 1}, "interaction": &"play_music"},
	{"id": &"deco_training_dummy", "name": "Training Dummy", "cat": &"inter", "theme": &"tech",    "rarity": 1, "size": Vector2i(2, 2), "ing": {&"compiled_steel": 4}, "interaction": &"practice"},
	{"id": &"deco_piano",          "name": "Piano",          "cat": &"inter", "theme": &"ornate",  "rarity": 2, "size": Vector2i(2, 2), "ing": {&"bytewood": 5, &"dyed_thread": 2}, "interaction": &"piano"},
	{"id": &"deco_pet_bed",        "name": "Pet Bed",        "cat": &"inter", "theme": &"cozy",    "rarity": 1, "size": Vector2i(2, 2), "ing": {&"patch": 3}, "interaction": &"pet_rest"},
	{"id": &"deco_mini_garden",    "name": "Mini Garden",    "cat": &"inter", "theme": &"natural", "rarity": 1, "size": Vector2i(2, 2), "ing": {&"logleaf": 4, &"patch": 2}, "interaction": &"auto_garden"},
	{"id": &"deco_mini_bench",     "name": "Mini Workbench", "cat": &"inter", "theme": &"tech",    "rarity": 1, "size": Vector2i(2, 2), "ing": {&"compiled_steel": 3}, "interaction": &"mini_craft"},
	{"id": &"deco_storage_chest",  "name": "Storage Chest",  "cat": &"inter", "theme": &"cozy",    "rarity": 1, "size": Vector2i(2, 2), "ing": {&"bytewood": 4, &"wire": 2}, "interaction": &"storage"},
	{"id": &"deco_mirror",         "name": "Mirror",         "cat": &"inter", "theme": &"ornate",  "rarity": 1, "size": Vector2i(2, 2), "ing": {&"memory_glass": 3}, "interaction": &"cosmetics"},
	{"id": &"deco_telescope",      "name": "Telescope",      "cat": &"inter", "theme": &"tech",    "rarity": 2, "size": Vector2i(2, 2), "ing": {&"memory_glass": 2, &"quantum_shard": 1}, "interaction": &"daily_lore"},
	{"id": &"deco_compaction_shrine","name": "Compaction Shrine","cat": &"inter","theme": &"glitch","rarity": 3, "size": Vector2i(2, 2), "ing": {&"sages_tear": 1}, "interaction": &"story", "story_unlock": true},
]

const THEME_SET_BONUSES: Dictionary = {
	&"cozy":    {"name": "Cozy",    "min_count": 5, "effect": &"npc_visit_rate_50pct"},
	&"tech":    {"name": "Tech",    "min_count": 5, "effect": &"craft_cost_minus_10pct"},
	&"glitch":  {"name": "Glitch",  "min_count": 5, "effect": &"glitch_sprite_spawn"},
	&"ornate":  {"name": "Ornate",  "min_count": 5, "effect": &"affinity_gain_plus_1"},
	&"natural": {"name": "Natural", "min_count": 5, "effect": &"adjacent_growth_10pct"},
}

static var _index: Dictionary = {}


static func get_all() -> Array:
	return DECORATIONS


static func get_decoration(id: StringName) -> Dictionary:
	if _index.is_empty():
		_build_index()
	return _index.get(id, {})


static func _build_index() -> void:
	for d in DECORATIONS:
		_index[d["id"]] = d


static func get_by_category(cat: StringName) -> Array:
	var result: Array = []
	for d in DECORATIONS:
		if d["cat"] == cat:
			result.append(d)
	return result


static func get_by_theme(theme: StringName) -> Array:
	var result: Array = []
	for d in DECORATIONS:
		if d["theme"] == theme:
			result.append(d)
	return result


static func compute_active_themes(placed_ids: Array) -> Array:
	## Returns themes that have hit their min_count for set bonuses.
	var counts: Dictionary = {}
	for id: StringName in placed_ids:
		var d: Dictionary = get_decoration(id)
		if d.is_empty():
			continue
		var theme: StringName = d["theme"]
		counts[theme] = counts.get(theme, 0) + 1
	var active: Array = []
	for theme: StringName in counts.keys():
		if counts[theme] >= THEME_SET_BONUSES[theme]["min_count"]:
			active.append(theme)
	return active


static func count() -> int:
	return DECORATIONS.size()
