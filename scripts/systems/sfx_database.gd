class_name SFXDatabase
extends RefCounted

## Static catalog of all SFX entries with metadata for the SFXManager.
## Each entry: { id, category, spatial, pool_size, volume_db, pitch_min, pitch_max, priority }

const SFX: Array = [
	# === PLAYER MOVEMENT (24) ===
	# Footsteps grass (×4)
	{"id": &"footstep_grass_01", "category": &"world",  "spatial": true, "pool": 8, "volume": -6.0, "pitch_min": 0.9, "pitch_max": 1.1, "priority": 1},
	{"id": &"footstep_grass_02", "category": &"world",  "spatial": true, "pool": 8, "volume": -6.0, "pitch_min": 0.9, "pitch_max": 1.1, "priority": 1},
	{"id": &"footstep_grass_03", "category": &"world",  "spatial": true, "pool": 8, "volume": -6.0, "pitch_min": 0.9, "pitch_max": 1.1, "priority": 1},
	{"id": &"footstep_grass_04", "category": &"world",  "spatial": true, "pool": 8, "volume": -6.0, "pitch_min": 0.9, "pitch_max": 1.1, "priority": 1},
	# Footsteps stone (×4)
	{"id": &"footstep_stone_01", "category": &"world",  "spatial": true, "pool": 8, "volume": -6.0, "pitch_min": 0.9, "pitch_max": 1.1, "priority": 1},
	{"id": &"footstep_stone_02", "category": &"world",  "spatial": true, "pool": 8, "volume": -6.0, "pitch_min": 0.9, "pitch_max": 1.1, "priority": 1},
	{"id": &"footstep_stone_03", "category": &"world",  "spatial": true, "pool": 8, "volume": -6.0, "pitch_min": 0.9, "pitch_max": 1.1, "priority": 1},
	{"id": &"footstep_stone_04", "category": &"world",  "spatial": true, "pool": 8, "volume": -6.0, "pitch_min": 0.9, "pitch_max": 1.1, "priority": 1},
	# Footsteps metal (×4)
	{"id": &"footstep_metal_01", "category": &"world",  "spatial": true, "pool": 8, "volume": -6.0, "pitch_min": 0.9, "pitch_max": 1.1, "priority": 1},
	{"id": &"footstep_metal_02", "category": &"world",  "spatial": true, "pool": 8, "volume": -6.0, "pitch_min": 0.9, "pitch_max": 1.1, "priority": 1},
	{"id": &"footstep_metal_03", "category": &"world",  "spatial": true, "pool": 8, "volume": -6.0, "pitch_min": 0.9, "pitch_max": 1.1, "priority": 1},
	{"id": &"footstep_metal_04", "category": &"world",  "spatial": true, "pool": 8, "volume": -6.0, "pitch_min": 0.9, "pitch_max": 1.1, "priority": 1},
	# Footsteps wood (×4)
	{"id": &"footstep_wood_01",  "category": &"world",  "spatial": true, "pool": 8, "volume": -6.0, "pitch_min": 0.9, "pitch_max": 1.1, "priority": 1},
	{"id": &"footstep_wood_02",  "category": &"world",  "spatial": true, "pool": 8, "volume": -6.0, "pitch_min": 0.9, "pitch_max": 1.1, "priority": 1},
	{"id": &"footstep_wood_03",  "category": &"world",  "spatial": true, "pool": 8, "volume": -6.0, "pitch_min": 0.9, "pitch_max": 1.1, "priority": 1},
	{"id": &"footstep_wood_04",  "category": &"world",  "spatial": true, "pool": 8, "volume": -6.0, "pitch_min": 0.9, "pitch_max": 1.1, "priority": 1},
	# Footsteps water (×4)
	{"id": &"footstep_water_01", "category": &"world",  "spatial": true, "pool": 8, "volume": -6.0, "pitch_min": 0.9, "pitch_max": 1.1, "priority": 1},
	{"id": &"footstep_water_02", "category": &"world",  "spatial": true, "pool": 8, "volume": -6.0, "pitch_min": 0.9, "pitch_max": 1.1, "priority": 1},
	{"id": &"footstep_water_03", "category": &"world",  "spatial": true, "pool": 8, "volume": -6.0, "pitch_min": 0.9, "pitch_max": 1.1, "priority": 1},
	{"id": &"footstep_water_04", "category": &"world",  "spatial": true, "pool": 8, "volume": -6.0, "pitch_min": 0.9, "pitch_max": 1.1, "priority": 1},
	# Movement actions
	{"id": &"player_jump",       "category": &"world",  "spatial": true, "pool": 4, "volume": -3.0, "pitch_min": 0.95, "pitch_max": 1.05, "priority": 2},
	{"id": &"player_land",       "category": &"world",  "spatial": true, "pool": 4, "volume": -3.0, "pitch_min": 0.95, "pitch_max": 1.05, "priority": 2},
	{"id": &"player_dash",       "category": &"world",  "spatial": true, "pool": 4, "volume": -2.0, "pitch_min": 0.95, "pitch_max": 1.05, "priority": 3},
	{"id": &"player_crouch",     "category": &"world",  "spatial": true, "pool": 4, "volume": -8.0, "pitch_min": 0.95, "pitch_max": 1.05, "priority": 1},

	# === PLAYER STATE (8) ===
	{"id": &"player_damaged_light", "category": &"combat", "spatial": false, "pool": 4, "volume": 0.0,  "pitch_min": 0.95, "pitch_max": 1.05, "priority": 5},
	{"id": &"player_damaged_med",   "category": &"combat", "spatial": false, "pool": 4, "volume": 0.0,  "pitch_min": 0.95, "pitch_max": 1.05, "priority": 5},
	{"id": &"player_damaged_heavy", "category": &"combat", "spatial": false, "pool": 4, "volume": 0.0,  "pitch_min": 0.95, "pitch_max": 1.05, "priority": 5},
	{"id": &"player_death",         "category": &"combat", "spatial": false, "pool": 1, "volume": 0.0,  "pitch_min": 1.0,  "pitch_max": 1.0,  "priority": 10},
	{"id": &"player_level_up",      "category": &"ui",     "spatial": false, "pool": 1, "volume": 0.0,  "pitch_min": 1.0,  "pitch_max": 1.0,  "priority": 6},
	{"id": &"player_potion_drink",  "category": &"ui",     "spatial": false, "pool": 4, "volume": -2.0, "pitch_min": 0.95, "pitch_max": 1.05, "priority": 3},
	{"id": &"player_heal_pulse",    "category": &"combat", "spatial": false, "pool": 4, "volume": -2.0, "pitch_min": 0.95, "pitch_max": 1.05, "priority": 4},
	{"id": &"player_shield_up",     "category": &"combat", "spatial": false, "pool": 4, "volume": -2.0, "pitch_min": 0.95, "pitch_max": 1.05, "priority": 4},

	# === BASIC ATTACKS (8) ===
	{"id": &"attack_swing_01",   "category": &"combat", "spatial": true, "pool": 6, "volume": -2.0, "pitch_min": 0.95, "pitch_max": 1.05, "priority": 3},
	{"id": &"attack_swing_02",   "category": &"combat", "spatial": true, "pool": 6, "volume": -2.0, "pitch_min": 0.95, "pitch_max": 1.05, "priority": 3},
	{"id": &"attack_swing_03",   "category": &"combat", "spatial": true, "pool": 6, "volume": -2.0, "pitch_min": 0.95, "pitch_max": 1.05, "priority": 3},
	{"id": &"attack_hit_light",  "category": &"combat", "spatial": true, "pool": 6, "volume": -1.0, "pitch_min": 0.95, "pitch_max": 1.05, "priority": 4},
	{"id": &"attack_hit_med",    "category": &"combat", "spatial": true, "pool": 6, "volume": -1.0, "pitch_min": 0.95, "pitch_max": 1.05, "priority": 4},
	{"id": &"attack_hit_crit",   "category": &"combat", "spatial": true, "pool": 4, "volume": 0.0,  "pitch_min": 0.95, "pitch_max": 1.05, "priority": 5},
	{"id": &"charged_release",   "category": &"combat", "spatial": true, "pool": 4, "volume": 0.0,  "pitch_min": 0.95, "pitch_max": 1.05, "priority": 5},
	{"id": &"charged_hit",       "category": &"combat", "spatial": true, "pool": 4, "volume": 1.0,  "pitch_min": 0.95, "pitch_max": 1.05, "priority": 5},

	# === MODULES (40 entries via macro — generated from ModuleFactory IDs) ===
	# At runtime SFXManager auto-creates entries: <module_id>_cast and <module_id>_hit

	# === ENEMY GENERIC TRIPLES (33) ===
	# Each enemy: aggro, attack, hit, death = 4 sounds
	# GlitchBug
	{"id": &"glitchbug_aggro",   "category": &"combat", "spatial": true, "pool": 4, "volume": -2.0, "pitch_min": 0.9, "pitch_max": 1.1, "priority": 3},
	{"id": &"glitchbug_attack",  "category": &"combat", "spatial": true, "pool": 4, "volume": -2.0, "pitch_min": 0.9, "pitch_max": 1.1, "priority": 3},
	{"id": &"glitchbug_hit",     "category": &"combat", "spatial": true, "pool": 4, "volume": -3.0, "pitch_min": 0.9, "pitch_max": 1.1, "priority": 2},
	{"id": &"glitchbug_death",   "category": &"combat", "spatial": true, "pool": 4, "volume": -1.0, "pitch_min": 0.9, "pitch_max": 1.1, "priority": 4},
	# MemoryLeak
	{"id": &"memoryleak_aggro",  "category": &"combat", "spatial": true, "pool": 4, "volume": -2.0, "pitch_min": 0.9, "pitch_max": 1.1, "priority": 3},
	{"id": &"memoryleak_attack", "category": &"combat", "spatial": true, "pool": 4, "volume": -2.0, "pitch_min": 0.9, "pitch_max": 1.1, "priority": 3},
	{"id": &"memoryleak_hit",    "category": &"combat", "spatial": true, "pool": 4, "volume": -3.0, "pitch_min": 0.9, "pitch_max": 1.1, "priority": 2},
	{"id": &"memoryleak_death",  "category": &"combat", "spatial": true, "pool": 4, "volume": -1.0, "pitch_min": 0.9, "pitch_max": 1.1, "priority": 4},
	# RogueProcess
	{"id": &"rogueprocess_aggro",  "category": &"combat", "spatial": true, "pool": 4, "volume": -2.0, "pitch_min": 0.9, "pitch_max": 1.1, "priority": 3},
	{"id": &"rogueprocess_attack", "category": &"combat", "spatial": true, "pool": 4, "volume": -2.0, "pitch_min": 0.9, "pitch_max": 1.1, "priority": 3},
	{"id": &"rogueprocess_hit",    "category": &"combat", "spatial": true, "pool": 4, "volume": -3.0, "pitch_min": 0.9, "pitch_max": 1.1, "priority": 2},
	{"id": &"rogueprocess_death",  "category": &"combat", "spatial": true, "pool": 4, "volume": -1.0, "pitch_min": 0.9, "pitch_max": 1.1, "priority": 4},
	# 8 new enemies × 4 sounds (auto-generated by enemy_id naming convention)

	# === BOSSES (36) ===
	# Per boss: intro, attack_1-4, phase_transition, death
	{"id": &"boss_compiler_intro",          "category": &"combat", "spatial": false, "pool": 1, "volume": 0.0, "pitch_min": 1.0, "pitch_max": 1.0, "priority": 10},
	{"id": &"boss_compiler_attack_1",       "category": &"combat", "spatial": true,  "pool": 4, "volume": -1.0, "pitch_min": 0.95, "pitch_max": 1.05, "priority": 5},
	{"id": &"boss_compiler_attack_2",       "category": &"combat", "spatial": true,  "pool": 4, "volume": -1.0, "pitch_min": 0.95, "pitch_max": 1.05, "priority": 5},
	{"id": &"boss_compiler_attack_3",       "category": &"combat", "spatial": true,  "pool": 4, "volume": -1.0, "pitch_min": 0.95, "pitch_max": 1.05, "priority": 5},
	{"id": &"boss_compiler_attack_4",       "category": &"combat", "spatial": true,  "pool": 4, "volume": -1.0, "pitch_min": 0.95, "pitch_max": 1.05, "priority": 5},
	{"id": &"boss_compiler_phase",          "category": &"combat", "spatial": false, "pool": 1, "volume": 0.0,  "pitch_min": 1.0, "pitch_max": 1.0, "priority": 10},
	{"id": &"boss_compiler_death",          "category": &"combat", "spatial": false, "pool": 1, "volume": 0.0,  "pitch_min": 1.0, "pitch_max": 1.0, "priority": 10},
	# Memory Warden, Root Heart, Sentinel Prime, Iteration Phantom, Compiler Reborn — 5 more sets generated

	# === UI (20) ===
	{"id": &"ui_button_hover",   "category": &"ui", "spatial": false, "pool": 4, "volume": -8.0, "pitch_min": 0.98, "pitch_max": 1.02, "priority": 1},
	{"id": &"ui_button_click",   "category": &"ui", "spatial": false, "pool": 4, "volume": -5.0, "pitch_min": 0.98, "pitch_max": 1.02, "priority": 2},
	{"id": &"ui_menu_open",      "category": &"ui", "spatial": false, "pool": 2, "volume": -3.0, "pitch_min": 1.0, "pitch_max": 1.0, "priority": 3},
	{"id": &"ui_menu_close",     "category": &"ui", "spatial": false, "pool": 2, "volume": -3.0, "pitch_min": 1.0, "pitch_max": 1.0, "priority": 3},
	{"id": &"ui_tab_switch",     "category": &"ui", "spatial": false, "pool": 4, "volume": -6.0, "pitch_min": 0.98, "pitch_max": 1.02, "priority": 1},
	{"id": &"ui_inventory_open", "category": &"ui", "spatial": false, "pool": 2, "volume": -3.0, "pitch_min": 1.0, "pitch_max": 1.0, "priority": 3},
	{"id": &"ui_inventory_close","category": &"ui", "spatial": false, "pool": 2, "volume": -3.0, "pitch_min": 1.0, "pitch_max": 1.0, "priority": 3},
	{"id": &"ui_item_pickup",    "category": &"ui", "spatial": false, "pool": 4, "volume": -2.0, "pitch_min": 0.95, "pitch_max": 1.05, "priority": 3},
	{"id": &"ui_item_drop",      "category": &"ui", "spatial": false, "pool": 4, "volume": -4.0, "pitch_min": 0.95, "pitch_max": 1.05, "priority": 2},
	{"id": &"ui_item_equip",     "category": &"ui", "spatial": false, "pool": 4, "volume": -2.0, "pitch_min": 0.95, "pitch_max": 1.05, "priority": 3},
	{"id": &"ui_item_drop_world","category": &"ui", "spatial": true,  "pool": 4, "volume": -4.0, "pitch_min": 0.95, "pitch_max": 1.05, "priority": 2},
	{"id": &"ui_gold_pickup",    "category": &"ui", "spatial": false, "pool": 4, "volume": -2.0, "pitch_min": 0.95, "pitch_max": 1.05, "priority": 3},
	{"id": &"ui_xp_pickup",      "category": &"ui", "spatial": false, "pool": 4, "volume": -4.0, "pitch_min": 0.95, "pitch_max": 1.05, "priority": 2},
	{"id": &"ui_skill_allocate", "category": &"ui", "spatial": false, "pool": 4, "volume": -2.0, "pitch_min": 0.95, "pitch_max": 1.05, "priority": 3},
	{"id": &"ui_quest_accept",   "category": &"ui", "spatial": false, "pool": 2, "volume": 0.0,  "pitch_min": 1.0, "pitch_max": 1.0, "priority": 4},
	{"id": &"ui_quest_complete", "category": &"ui", "spatial": false, "pool": 2, "volume": 0.0,  "pitch_min": 1.0, "pitch_max": 1.0, "priority": 5},
	{"id": &"ui_quest_fail",     "category": &"ui", "spatial": false, "pool": 2, "volume": -2.0, "pitch_min": 1.0, "pitch_max": 1.0, "priority": 4},
	{"id": &"ui_achievement",    "category": &"ui", "spatial": false, "pool": 2, "volume": 0.0,  "pitch_min": 1.0, "pitch_max": 1.0, "priority": 5},
	{"id": &"ui_save_indicator", "category": &"ui", "spatial": false, "pool": 2, "volume": -10.0, "pitch_min": 1.0, "pitch_max": 1.0, "priority": 1},

	# === WORLD AMBIENT (15) ===
	{"id": &"door_open",         "category": &"world", "spatial": true, "pool": 4, "volume": -2.0, "pitch_min": 0.95, "pitch_max": 1.05, "priority": 3},
	{"id": &"door_close",        "category": &"world", "spatial": true, "pool": 4, "volume": -2.0, "pitch_min": 0.95, "pitch_max": 1.05, "priority": 3},
	{"id": &"chest_open",        "category": &"world", "spatial": true, "pool": 2, "volume": 0.0,  "pitch_min": 0.95, "pitch_max": 1.05, "priority": 4},
	{"id": &"crystal_shimmer",   "category": &"world", "spatial": true, "pool": 4, "volume": -4.0, "pitch_min": 0.9, "pitch_max": 1.1, "priority": 2},
	{"id": &"water_splash",      "category": &"world", "spatial": true, "pool": 4, "volume": -2.0, "pitch_min": 0.9, "pitch_max": 1.1, "priority": 2},
	{"id": &"wind_gust_loop",    "category": &"world", "spatial": false, "pool": 1, "volume": -12.0, "pitch_min": 1.0, "pitch_max": 1.0, "priority": 1},
	{"id": &"fire_crackle_loop", "category": &"world", "spatial": true, "pool": 4, "volume": -8.0, "pitch_min": 1.0, "pitch_max": 1.0, "priority": 1},
	{"id": &"birdsong_loop",     "category": &"world", "spatial": false, "pool": 1, "volume": -10.0, "pitch_min": 1.0, "pitch_max": 1.0, "priority": 1},
	{"id": &"cricket_loop",      "category": &"world", "spatial": false, "pool": 1, "volume": -10.0, "pitch_min": 1.0, "pitch_max": 1.0, "priority": 1},
	{"id": &"server_hum_loop",   "category": &"world", "spatial": true, "pool": 4, "volume": -8.0, "pitch_min": 1.0, "pitch_max": 1.0, "priority": 1},
	{"id": &"glitch_crackle_loop","category": &"world","spatial": true, "pool": 4, "volume": -8.0, "pitch_min": 1.0, "pitch_max": 1.0, "priority": 1},
	{"id": &"memory_chime_loop", "category": &"world", "spatial": true, "pool": 4, "volume": -8.0, "pitch_min": 1.0, "pitch_max": 1.0, "priority": 1},
	{"id": &"footfall_dust",     "category": &"world", "spatial": true, "pool": 4, "volume": -10.0, "pitch_min": 0.9, "pitch_max": 1.1, "priority": 1},
	{"id": &"environment_collapse","category":&"world","spatial": true, "pool": 2, "volume": 0.0,  "pitch_min": 0.95, "pitch_max": 1.05, "priority": 5},
	{"id": &"environment_glitch_pulse","category":&"world","spatial":true,"pool":4,"volume":-4.0,"pitch_min":0.9,"pitch_max":1.1,"priority":2},
]

const AUDIO_BASE_PATH: String = "res://assets/audio/sfx/"

static var _index: Dictionary = {}


static func get_all() -> Array:
	return SFX


static func get_sfx(id: StringName) -> Dictionary:
	if _index.is_empty():
		_build_index()
	return _index.get(id, {})


static func _build_index() -> void:
	for s in SFX:
		_index[s["id"]] = s


static func get_file_path(id: StringName) -> String:
	return AUDIO_BASE_PATH + String(id) + ".ogg"


static func get_random_footstep(surface: StringName) -> StringName:
	## Returns a random footstep variant for the surface
	var prefix: String = "footstep_" + String(surface) + "_"
	var variants: PackedStringArray = []
	for s in SFX:
		var id_str: String = String(s["id"])
		if id_str.begins_with(prefix):
			variants.append(id_str)
	if variants.is_empty():
		return &""
	return StringName(variants[randi() % variants.size()])


static func count() -> int:
	return SFX.size()
