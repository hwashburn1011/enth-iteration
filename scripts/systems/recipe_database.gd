class_name RecipeDatabase
extends RefCounted

## Static catalog of all 85 recipes. Each recipe defines its station type,
## ingredients, output, rarity, and unlock requirement. Built once at startup.

const MODULE_RECIPES: Array = [
	# Compiler modules
	{"id": &"recipe_pattern_lock",     "name": "Pattern Lock Module",      "station": &"forge", "out": &"pattern_lock",     "out_n": 1, "ing": {&"wire": 2, &"bit_fragment": 1},                       "rarity": 0, "unlock": {}},
	{"id": &"recipe_recompile",        "name": "Recompile Module",         "station": &"forge", "out": &"recompile",        "out_n": 1, "ing": {&"wire": 3, &"compiled_steel": 1, &"bit_fragment": 2}, "rarity": 1, "unlock": {}},
	{"id": &"recipe_logic_bomb",       "name": "Logic Bomb Module",        "station": &"forge", "out": &"logic_bomb",       "out_n": 1, "ing": {&"compiled_steel": 3, &"quantum_shard": 1},            "rarity": 2, "unlock": {"type": "quest", "source_id": &"compiler_quest_3"}},
	{"id": &"recipe_iterative_mend",   "name": "Iterative Mend Module",    "station": &"forge", "out": &"iterative_mend",   "out_n": 1, "ing": {&"patch": 3, &"bit_fragment": 2},                     "rarity": 0, "unlock": {}},
	{"id": &"recipe_stack_trace",      "name": "Stack Trace Module",       "station": &"forge", "out": &"stack_trace",      "out_n": 1, "ing": {&"wire": 2, &"algorithm_stone": 1},                   "rarity": 1, "unlock": {}},
	{"id": &"recipe_garbage_collect",  "name": "Garbage Collect Module",   "station": &"forge", "out": &"garbage_collect",  "out_n": 1, "ing": {&"compiled_steel": 2, &"server_coil": 1},             "rarity": 1, "unlock": {}},
	{"id": &"recipe_memory_allocate",  "name": "Memory Allocate Module",   "station": &"forge", "out": &"memory_allocate",  "out_n": 1, "ing": {&"memory_glass": 2, &"compiled_steel": 1},            "rarity": 1, "unlock": {}},
	{"id": &"recipe_branch_predict",   "name": "Branch Predict Module",    "station": &"forge", "out": &"branch_predict",   "out_n": 1, "ing": {&"pure_code": 1, &"quantum_shard": 1},                "rarity": 2, "unlock": {"type": "drop", "source_id": &"elite_compiler"}},

	# Daemon modules
	{"id": &"recipe_phase_strike",     "name": "Phase Strike Module",      "station": &"forge", "out": &"phase_strike",     "out_n": 1, "ing": {&"wire": 2, &"bit_fragment": 2},                      "rarity": 0, "unlock": {}},
	{"id": &"recipe_hunters_mark",     "name": "Hunter's Mark Module",     "station": &"forge", "out": &"hunters_mark",     "out_n": 1, "ing": {&"compiled_steel": 1, &"algorithm_stone": 1},         "rarity": 1, "unlock": {}},
	{"id": &"recipe_smoke_veil",       "name": "Smoke Veil Module",        "station": &"forge", "out": &"smoke_veil",       "out_n": 1, "ing": {&"voidsteel": 1, &"dream_silk": 1},                   "rarity": 2, "unlock": {"type": "quest", "source_id": &"daemon_quest_2"}},
	{"id": &"recipe_shadow_clone",     "name": "Shadow Clone Module",      "station": &"forge", "out": &"shadow_clone",     "out_n": 1, "ing": {&"voidsteel": 2, &"pure_code": 1},                    "rarity": 2, "unlock": {}},
	{"id": &"recipe_massacre_protocol","name": "Massacre Protocol",        "station": &"forge", "out": &"massacre_protocol","out_n": 1, "ing": {&"glitch_core": 1, &"boss_soul": 1},                  "rarity": 3, "unlock": {"type": "quest", "source_id": &"daemon_finale"}},
	{"id": &"recipe_acid_splash",      "name": "Acid Splash Module",       "station": &"forge", "out": &"acid_splash",      "out_n": 1, "ing": {&"server_coil": 2, &"voidsteel": 1},                  "rarity": 1, "unlock": {}},
	{"id": &"recipe_backstep",         "name": "Backstep Module",          "station": &"forge", "out": &"backstep",         "out_n": 1, "ing": {&"wire": 2, &"compiled_steel": 1},                    "rarity": 0, "unlock": {}},
	{"id": &"recipe_bleed_out",        "name": "Bleed Out Module",         "station": &"forge", "out": &"bleed_out",        "out_n": 1, "ing": {&"voidsteel": 1, &"glitch_core": 1},                  "rarity": 2, "unlock": {}},

	# Kernel modules
	{"id": &"recipe_bulwark",          "name": "Bulwark Module",           "station": &"forge", "out": &"bulwark",          "out_n": 1, "ing": {&"compiled_steel": 3, &"patch": 2},                   "rarity": 0, "unlock": {}},
	{"id": &"recipe_gravity_well",     "name": "Gravity Well Module",      "station": &"forge", "out": &"gravity_well",     "out_n": 1, "ing": {&"server_coil": 2, &"algorithm_stone": 1},            "rarity": 1, "unlock": {}},
	{"id": &"recipe_thunder_strike",   "name": "Thunder Strike Module",    "station": &"forge", "out": &"thunder_strike",   "out_n": 1, "ing": {&"compiled_steel": 4, &"quantum_shard": 1},           "rarity": 2, "unlock": {}},
	{"id": &"recipe_aegis_protocol",   "name": "Aegis Protocol Module",    "station": &"forge", "out": &"aegis_protocol",   "out_n": 1, "ing": {&"sages_tear": 1, &"compiled_steel": 3},              "rarity": 3, "unlock": {"type": "npc", "source_id": &"sage"}},
	{"id": &"recipe_overclock_reactor","name": "Overclock Reactor",        "station": &"forge", "out": &"overclock_reactor","out_n": 1, "ing": {&"boss_soul": 1, &"glitch_core": 1, &"pure_code": 2}, "rarity": 3, "unlock": {"type": "quest", "source_id": &"kernel_finale"}},
	{"id": &"recipe_earthquake",       "name": "Earthquake Module",        "station": &"forge", "out": &"earthquake",       "out_n": 1, "ing": {&"compiled_steel": 3, &"voidsteel": 1},               "rarity": 1, "unlock": {}},
	{"id": &"recipe_thorn_aegis",      "name": "Thorn Aegis Module",       "station": &"forge", "out": &"thorn_aegis",      "out_n": 1, "ing": {&"compiled_steel": 2, &"server_coil": 2},             "rarity": 1, "unlock": {}},
	{"id": &"recipe_iron_will",        "name": "Iron Will Module",         "station": &"forge", "out": &"iron_will",        "out_n": 1, "ing": {&"compiled_steel": 2, &"memory_glass": 1},            "rarity": 1, "unlock": {}},

	# Universal modules
	{"id": &"recipe_healing_prompt",   "name": "Healing Prompt Module",    "station": &"lab",   "out": &"healing_prompt",   "out_n": 1, "ing": {&"patch": 2, &"bit_fragment": 1},                     "rarity": 0, "unlock": {}},
	{"id": &"recipe_compute_surge",    "name": "Compute Surge Module",     "station": &"lab",   "out": &"compute_surge",    "out_n": 1, "ing": {&"wire": 2, &"cache_crystal": 1},                     "rarity": 0, "unlock": {}},
	{"id": &"recipe_translocate",      "name": "Translocate Module",       "station": &"forge", "out": &"translocate",      "out_n": 1, "ing": {&"algorithm_stone": 1, &"server_coil": 1},            "rarity": 1, "unlock": {}},
	{"id": &"recipe_provoke",          "name": "Provoke Module",           "station": &"forge", "out": &"provoke",          "out_n": 1, "ing": {&"wire": 2, &"bytewood": 1},                          "rarity": 0, "unlock": {}},
	{"id": &"recipe_time_dilate",      "name": "Time Dilate Module",       "station": &"compiler","out": &"time_dilate",    "out_n": 1, "ing": {&"quantum_shard": 1, &"pure_code": 1},                "rarity": 2, "unlock": {"type": "explore", "source_id": &"vault_secret"}},
	{"id": &"recipe_decoy_daemon",     "name": "Decoy Daemon Module",      "station": &"forge", "out": &"decoy_daemon",     "out_n": 1, "ing": {&"server_coil": 1, &"dyed_thread": 1},                "rarity": 1, "unlock": {}},
]

const PROMPT_RECIPES: Array = [
	{"id": &"recipe_health_potion_s",  "name": "Healing Prompt (S)",       "station": &"lab", "out": &"prompt_heal_s",  "out_n": 3, "ing": {&"patch": 1, &"bit_fragment": 1},                          "rarity": 0, "unlock": {}},
	{"id": &"recipe_health_potion_m",  "name": "Healing Prompt (M)",       "station": &"lab", "out": &"prompt_heal_m",  "out_n": 2, "ing": {&"patch": 2, &"memory_glass": 1},                          "rarity": 1, "unlock": {}},
	{"id": &"recipe_health_potion_l",  "name": "Healing Prompt (L)",       "station": &"lab", "out": &"prompt_heal_l",  "out_n": 1, "ing": {&"patch": 3, &"quantum_shard": 1},                         "rarity": 2, "unlock": {}},
	{"id": &"recipe_compute_potion_s", "name": "Compute Prompt (S)",       "station": &"lab", "out": &"prompt_comp_s",  "out_n": 3, "ing": {&"wire": 1, &"cache_crystal": 1},                          "rarity": 0, "unlock": {}},
	{"id": &"recipe_compute_potion_m", "name": "Compute Prompt (M)",       "station": &"lab", "out": &"prompt_comp_m",  "out_n": 2, "ing": {&"wire": 2, &"server_coil": 1},                            "rarity": 1, "unlock": {}},
	{"id": &"recipe_dmg_boost",        "name": "Damage Boost Prompt",      "station": &"lab", "out": &"prompt_dmg",     "out_n": 2, "ing": {&"bit_fragment": 3, &"quantum_shard": 1},                  "rarity": 2, "unlock": {}},
	{"id": &"recipe_def_boost",        "name": "Defense Boost Prompt",     "station": &"lab", "out": &"prompt_def",     "out_n": 2, "ing": {&"compiled_steel": 2, &"memory_glass": 1},                 "rarity": 2, "unlock": {}},
	{"id": &"recipe_speed_boost",      "name": "Speed Boost Prompt",       "station": &"lab", "out": &"prompt_speed",   "out_n": 2, "ing": {&"server_coil": 2, &"bit_fragment": 1},                    "rarity": 1, "unlock": {}},
	{"id": &"recipe_invis",            "name": "Invisibility Prompt",      "station": &"lab", "out": &"prompt_invis",   "out_n": 1, "ing": {&"voidsteel": 1, &"dream_silk": 1},                        "rarity": 3, "unlock": {"type": "drop", "source_id": &"glitch_drop"}},
	{"id": &"recipe_compute_max",      "name": "Compute Max Prompt",       "station": &"lab", "out": &"prompt_comp_max","out_n": 1, "ing": {&"sages_tear": 1, &"pure_code": 2},                         "rarity": 3, "unlock": {"type": "npc", "source_id": &"sage"}},
]

const CHIP_RECIPES: Array = [
	{"id": &"recipe_chip_power",       "name": "Power Chip",               "station": &"forge", "out": &"chip_power",      "out_n": 1, "ing": {&"wire": 2, &"bit_fragment": 1},                       "rarity": 0, "unlock": {}},
	{"id": &"recipe_chip_vitality",    "name": "Vitality Chip",            "station": &"forge", "out": &"chip_vitality",   "out_n": 1, "ing": {&"patch": 2, &"cache_crystal": 1},                     "rarity": 0, "unlock": {}},
	{"id": &"recipe_chip_compute",     "name": "Compute Chip",             "station": &"forge", "out": &"chip_compute",    "out_n": 1, "ing": {&"server_coil": 1, &"cache_crystal": 1},               "rarity": 0, "unlock": {}},
	{"id": &"recipe_chip_speed",       "name": "Speed Chip",               "station": &"forge", "out": &"chip_speed",      "out_n": 1, "ing": {&"server_coil": 2, &"compiled_steel": 1},              "rarity": 1, "unlock": {}},
	{"id": &"recipe_chip_crit",        "name": "Crit Chip",                "station": &"forge", "out": &"chip_crit",       "out_n": 1, "ing": {&"algorithm_stone": 1, &"quantum_shard": 1},           "rarity": 2, "unlock": {}},
]

const PROTOCOL_RECIPES: Array = [
	{"id": &"recipe_proto_autoheal",   "name": "Auto-Heal Protocol",       "station": &"compiler", "out": &"proto_autoheal", "out_n": 1, "ing": {&"memory_glass": 5, &"pure_code": 2},               "rarity": 2, "unlock": {"type": "quest", "source_id": &"compiler_lore"}},
	{"id": &"recipe_proto_lootmagnet", "name": "Loot Magnet Protocol",     "station": &"compiler", "out": &"proto_loot",    "out_n": 1, "ing": {&"algorithm_stone": 3, &"quantum_shard": 1},          "rarity": 2, "unlock": {}},
	{"id": &"recipe_proto_xpgain",     "name": "XP Gain Protocol",         "station": &"compiler", "out": &"proto_xp",      "out_n": 1, "ing": {&"pure_code": 3, &"sages_tear": 1},                   "rarity": 3, "unlock": {"type": "npc", "source_id": &"sage"}},
]

const COSMETIC_RECIPES: Array = [
	{"id": &"recipe_dye_crimson",      "name": "Crimson Dye",              "station": &"loom", "out": &"dye_crimson",     "out_n": 5, "ing": {&"patch": 2, &"voidsteel": 1},                          "rarity": 1, "unlock": {}},
	{"id": &"recipe_dye_gold",         "name": "Gold Dye",                 "station": &"loom", "out": &"dye_gold",        "out_n": 5, "ing": {&"patch": 2, &"quantum_shard": 1},                      "rarity": 2, "unlock": {}},
	{"id": &"recipe_compiler_boots",   "name": "Compiler Boots",           "station": &"loom", "out": &"compiler_boots",  "out_n": 1, "ing": {&"compiled_steel": 5, &"dyed_thread": 3},               "rarity": 2, "unlock": {"type": "quest", "source_id": &"loom_intro"}},
]

static var _index: Dictionary = {}


static func get_all_recipes() -> Array:
	return MODULE_RECIPES + PROMPT_RECIPES + CHIP_RECIPES + PROTOCOL_RECIPES + COSMETIC_RECIPES


static func get_recipe(id: StringName) -> Dictionary:
	if _index.is_empty():
		_build_index()
	return _index.get(id, {})


static func _build_index() -> void:
	for r in get_all_recipes():
		_index[r["id"]] = r


static func get_recipes_for_station(station_type: StringName) -> Array:
	var result: Array = []
	for r in get_all_recipes():
		if r["station"] == station_type:
			result.append(r)
	return result


static func get_recipes_for_player(known_recipes: Array, station_type: StringName) -> Array:
	var result: Array = []
	for r in get_recipes_for_station(station_type):
		var unlock: Dictionary = r.get("unlock", {})
		if unlock.is_empty() or known_recipes.has(r["id"]):
			result.append(r)
	return result


static func count() -> int:
	return get_all_recipes().size()


static func count_by_rarity(rarity: int) -> int:
	var n: int = 0
	for r in get_all_recipes():
		if r["rarity"] == rarity:
			n += 1
	return n
