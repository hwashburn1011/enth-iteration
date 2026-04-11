class_name ModuleFactory
extends RefCounted

## Builds all 40 ModuleItem instances declaratively. Used at game startup
## to populate the ItemRegistry with the canonical module catalog. Lets us
## tune balance values in code without authoring 40 .tres files by hand.
##
## Each entry: { id, name, desc, cost, cooldown, anim, category, rarity, base_damage }

const COMPILER_MODULES: Array = [
	{"id": &"pattern_lock",     "name": "Pattern Lock",     "desc": "Freeze a target for 1.5s.",                              "cost": 15, "cd": 4.0,  "anim": &"ability_small",    "dmg": 0,   "tag": &"control"},
	{"id": &"recompile",        "name": "Recompile",        "desc": "Teleport, leaving an explosive glyph at origin.",       "cost": 25, "cd": 8.0,  "anim": &"ability_medium",   "dmg": 35,  "tag": &"mobility"},
	{"id": &"logic_bomb",       "name": "Logic Bomb",       "desc": "Sequential explosion ring (200 dmg total).",            "cost": 80, "cd": 60.0, "anim": &"ability_ultimate", "dmg": 200, "tag": &"aoe"},
	{"id": &"iterative_mend",   "name": "Iterative Mend",   "desc": "Heal 30 HP over 3 seconds.",                            "cost": 20, "cd": 12.0, "anim": &"ability_small",    "dmg": 0,   "tag": &"heal"},
	{"id": &"stack_trace",      "name": "Stack Trace",      "desc": "Mark a target. Attacks against it deal +15% damage.",   "cost": 12, "cd": 6.0,  "anim": &"ability_small",    "dmg": 0,   "tag": &"debuff"},
	{"id": &"garbage_collect",  "name": "Garbage Collect",  "desc": "Destroy all hazards in 5m radius.",                     "cost": 18, "cd": 10.0, "anim": &"ability_medium",   "dmg": 0,   "tag": &"utility"},
	{"id": &"memory_allocate",  "name": "Memory Allocate",  "desc": "Temporary +30 max HP for 8 seconds.",                   "cost": 25, "cd": 15.0, "anim": &"ability_small",    "dmg": 0,   "tag": &"buff"},
	{"id": &"branch_predict",   "name": "Branch Predict",   "desc": "Auto-dodge all attacks for 2 seconds.",                 "cost": 30, "cd": 18.0, "anim": &"ability_medium",   "dmg": 0,   "tag": &"defense"},
]

const DAEMON_MODULES: Array = [
	{"id": &"phase_strike",     "name": "Phase Strike",     "desc": "Instant teleport-stab. 22 dmg.",                        "cost": 15, "cd": 5.0,  "anim": &"ability_small",    "dmg": 22,  "tag": &"melee"},
	{"id": &"hunters_mark",     "name": "Hunter's Mark",    "desc": "Marked enemies take +30% from Daemon for 8s.",          "cost": 12, "cd": 5.0,  "anim": &"ability_small",    "dmg": 0,   "tag": &"debuff"},
	{"id": &"smoke_veil",       "name": "Smoke Veil",       "desc": "Become invisible for 2 seconds.",                        "cost": 30, "cd": 12.0, "anim": &"ability_small",    "dmg": 0,   "tag": &"stealth"},
	{"id": &"shadow_clone",     "name": "Shadow Clone",     "desc": "Split into 3 clones for 4 seconds.",                    "cost": 35, "cd": 20.0, "anim": &"ability_medium",   "dmg": 0,   "tag": &"summon"},
	{"id": &"massacre_protocol","name": "Massacre Protocol","desc": "4s execute mode. Refresh on hit. Instant kill <20% HP.", "cost": 100,"cd": 90.0, "anim": &"ability_ultimate", "dmg": 0,   "tag": &"ultimate"},
	{"id": &"acid_splash",      "name": "Acid Splash",      "desc": "Projectile leaves a poison pool. 15 dmg + 5/s for 5s.", "cost": 18, "cd": 8.0,  "anim": &"ability_small",    "dmg": 15,  "tag": &"dot"},
	{"id": &"backstep",         "name": "Backstep",         "desc": "Short backwards dash + throw 2 daggers.",                "cost": 14, "cd": 6.0,  "anim": &"ability_small",    "dmg": 18,  "tag": &"mobility"},
	{"id": &"bleed_out",        "name": "Bleed Out",        "desc": "Apply 8s bleed. Lethal at 20% HP.",                     "cost": 22, "cd": 10.0, "anim": &"ability_small",    "dmg": 0,   "tag": &"dot"},
]

const KERNEL_MODULES: Array = [
	{"id": &"bulwark",          "name": "Bulwark",          "desc": "Sustained +50% defense (cannot move).",                 "cost": 0,  "cd": 0.0,  "anim": &"ability_small",    "dmg": 0,   "tag": &"sustained"},
	{"id": &"gravity_well",     "name": "Gravity Well",     "desc": "Pull all enemies in 4m toward you.",                    "cost": 20, "cd": 8.0,  "anim": &"ability_medium",   "dmg": 0,   "tag": &"control"},
	{"id": &"thunder_strike",   "name": "Thunder Strike",   "desc": "Slow-charge AoE slam. 60 damage.",                      "cost": 40, "cd": 12.0, "anim": &"ability_medium",   "dmg": 60,  "tag": &"aoe"},
	{"id": &"aegis_protocol",   "name": "Aegis Protocol",   "desc": "Bubble blocks 3 attacks per ally in 5m.",               "cost": 35, "cd": 12.0, "anim": &"ability_medium",   "dmg": 0,   "tag": &"defense"},
	{"id": &"overclock_reactor","name": "Overclock Reactor","desc": "5s invuln + 200% damage ultimate.",                     "cost": 150,"cd": 120.0,"anim": &"ability_ultimate", "dmg": 0,   "tag": &"ultimate"},
	{"id": &"earthquake",       "name": "Earthquake",       "desc": "Radial knockdown 6m. 30 dmg + stun.",                   "cost": 30, "cd": 14.0, "anim": &"ability_medium",   "dmg": 30,  "tag": &"aoe"},
	{"id": &"thorn_aegis",      "name": "Thorn Aegis",      "desc": "Reflect 50% melee damage for 5 seconds.",               "cost": 25, "cd": 16.0, "anim": &"ability_small",    "dmg": 0,   "tag": &"defense"},
	{"id": &"iron_will",        "name": "Iron Will",        "desc": "Break all CC. +80% defense for 3 seconds.",             "cost": 20, "cd": 25.0, "anim": &"ability_small",    "dmg": 0,   "tag": &"defense"},
]

const UNIVERSAL_MODULES: Array = [
	{"id": &"healing_prompt",   "name": "Healing Prompt",   "desc": "Instant heal 50 HP.",                                   "cost": 15, "cd": 20.0, "anim": &"ability_small",    "dmg": 0,   "tag": &"heal"},
	{"id": &"compute_surge",    "name": "Compute Surge",    "desc": "Refill 50 compute over 3 seconds.",                     "cost": 0,  "cd": 30.0, "anim": &"ability_small",    "dmg": 0,   "tag": &"resource"},
	{"id": &"translocate",      "name": "Translocate",      "desc": "Short teleport to cursor.",                              "cost": 18, "cd": 10.0, "anim": &"ability_small",    "dmg": 0,   "tag": &"mobility"},
	{"id": &"provoke",          "name": "Provoke",          "desc": "Taunt all enemies in 6m for 4 seconds.",                "cost": 12, "cd": 15.0, "anim": &"ability_small",    "dmg": 0,   "tag": &"control"},
	{"id": &"time_dilate",      "name": "Time Dilate",      "desc": "Slow nearby enemies 50% for 3 seconds.",                "cost": 25, "cd": 18.0, "anim": &"ability_medium",   "dmg": 0,   "tag": &"control"},
	{"id": &"decoy_daemon",     "name": "Decoy Daemon",     "desc": "Spawn a distraction puppet for 8 seconds.",             "cost": 22, "cd": 20.0, "anim": &"ability_small",    "dmg": 0,   "tag": &"summon"},
	{"id": &"repair_kit",       "name": "Repair Kit",       "desc": "Restore item durability and clean wear.",               "cost": 20, "cd": 60.0, "anim": &"ability_small",    "dmg": 0,   "tag": &"utility"},
	{"id": &"module_combust",   "name": "Module Combust",   "desc": "Destroy worst module for full HP/compute refill.",      "cost": 0,  "cd": 999.0,"anim": &"ability_medium",   "dmg": 0,   "tag": &"unique"},
]

const ULTIMATE_MODULES: Array = [
	{"id": &"compilers_last_word","name": "The Compiler's Last Word","desc": "10s automatic Pattern Lock on every visible enemy.","cost": 150,"cd": 120.0,"anim": &"ability_ultimate","dmg": 0, "tag": &"ultimate"},
	{"id": &"daemon_storm",     "name": "Daemon Storm",     "desc": "5s of self-controlled multi-shadow strikes.",           "cost": 120,"cd": 100.0,"anim": &"ability_ultimate", "dmg": 0,   "tag": &"ultimate"},
	{"id": &"wall_of_walls",    "name": "Wall of Walls",    "desc": "Become immobile but reflect all damage for 8s.",        "cost": 100,"cd": 90.0, "anim": &"ability_ultimate", "dmg": 0,   "tag": &"ultimate"},
	{"id": &"system_reset",     "name": "System Reset",     "desc": "Refill HP/compute and refresh all cooldowns.",          "cost": 0,  "cd": 999.0,"anim": &"ability_ultimate", "dmg": 0,   "tag": &"ultimate"},
	{"id": &"iteration_echo",   "name": "Iteration Echo",   "desc": "Clone Globbler from 5s ago for 10 seconds.",            "cost": 140,"cd": 120.0,"anim": &"ability_ultimate", "dmg": 0,   "tag": &"ultimate"},
	{"id": &"glitch_explosion", "name": "Glitch Explosion", "desc": "800 dmg in 8m, kill self, respawn after 1s.",           "cost": 0,  "cd": 999.0,"anim": &"ability_ultimate", "dmg": 800, "tag": &"ultimate"},
	{"id": &"memory_banking",   "name": "Memory Banking",   "desc": "Bank current HP/compute, refund on next death.",        "cost": 60, "cd": 999.0,"anim": &"ability_small",    "dmg": 0,   "tag": &"ultimate"},
	{"id": &"compaction_forecast","name": "Compaction Forecast","desc": "Reveal next 3 floors' room types and elite locations.","cost": 50,"cd": 999.0,"anim": &"ability_small","dmg": 0, "tag": &"ultimate"},
]


static func build_all_modules() -> Array[ModuleItem]:
	var result: Array[ModuleItem] = []
	for entry in COMPILER_MODULES:
		result.append(_build("compiler", entry, 2))  # rare default
	for entry in DAEMON_MODULES:
		result.append(_build("daemon", entry, 2))
	for entry in KERNEL_MODULES:
		result.append(_build("kernel", entry, 2))
	for entry in UNIVERSAL_MODULES:
		result.append(_build("universal", entry, 2))
	for entry in ULTIMATE_MODULES:
		result.append(_build("ultimate", entry, 3))  # epic default for ultimates
	return result


static func _build(category: String, entry: Dictionary, rarity: int) -> ModuleItem:
	var m: ModuleItem = ModuleItem.new()
	m.item_id = String(entry["id"])
	m.item_name = entry["name"]
	m.description = entry["desc"]
	m.ability_name = entry["name"]
	m.ability_description = entry["desc"]
	m.compute_cost = float(entry["cost"])
	m.cooldown = float(entry["cd"])
	m.rarity = rarity
	m.stat_modifiers = {
		"category": category,
		"animation_trigger": String(entry["anim"]),
		"base_damage": entry["dmg"],
		"tag": String(entry["tag"]),
	}
	return m


static func get_total_count() -> int:
	return COMPILER_MODULES.size() + DAEMON_MODULES.size() + KERNEL_MODULES.size() + UNIVERSAL_MODULES.size() + ULTIMATE_MODULES.size()


static func get_modules_for_class(class_id: StringName) -> Array:
	match class_id:
		&"compiler": return COMPILER_MODULES + UNIVERSAL_MODULES
		&"daemon": return DAEMON_MODULES + UNIVERSAL_MODULES
		&"kernel": return KERNEL_MODULES + UNIVERSAL_MODULES
	return UNIVERSAL_MODULES


static func get_ultimate_modules() -> Array:
	return ULTIMATE_MODULES
