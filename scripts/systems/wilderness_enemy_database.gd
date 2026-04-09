class_name WildernessEnemyDatabase
extends RefCounted

## Overworld combat encounters for the wilderness regions. These are the
## hostile mobs that ambush the player while traversing — distinct from
## dungeon enemies (handled by EnemyDatabase) in that they spawn into a
## live open zone with strict placement rules.
##
## See `_bmad-output/wilderness/wilderness_bible.md` "Hostile encounters"
## for the design intent. Spawn rules:
##   1. Never within 20m of the player on first entry into a region
##   2. Never within 30m of a fast-travel waypoint
##   3. Density scales with iteration (30% at iter 1 → 100% at iter 9)
##   4. No respawn during a single visit (cleared until town return)

const WILDERNESS_ENEMIES: Array[Dictionary] = [
	{
		"id": &"glitch_eel",
		"display_name": "Glitch Eel",
		"enemy_type": &"glitch_eel",  # Maps to EnemyDatabase entry
		"regions": [&"wild_river"],
		"placement": &"water_only",
		"spawn_pattern": &"ambush_from_water",
		"phases": [&"day", &"dusk", &"night"],
		"weather_blacklist": [],
		"base_pack_size": 1,
		"max_pack_size": 3,
		"base_density": 4,  # spawns per region instance at 100% density
		"alert_radius": 8.0,
		"chase_radius": 14.0,
		"loot_table": &"loot_river_minor",
		"first_kill_lore": &"lore_glitch_eel_origin",
	},
	{
		"id": &"bit_beetle",
		"display_name": "Bit Beetle",
		"enemy_type": &"bit_beetle",
		"regions": [&"wild_river"],
		"placement": &"river_bank",
		"spawn_pattern": &"swarm",
		"phases": [&"day", &"dusk"],
		"weather_blacklist": [&"storm"],
		"base_pack_size": 4,
		"max_pack_size": 6,
		"base_density": 3,
		"alert_radius": 10.0,
		"chase_radius": 16.0,
		"loot_table": &"loot_swarm_minor",
	},
	{
		"id": &"stack_overflow_spider",
		"display_name": "Stack Overflow Spider",
		"enemy_type": &"stack_overflow_spider",
		"regions": [&"wild_forest"],
		"placement": &"forest_canopy",
		"spawn_pattern": &"drop_from_canopy",
		"phases": [&"day", &"dusk", &"night"],
		"weather_blacklist": [],
		"base_pack_size": 1,
		"max_pack_size": 2,
		"base_density": 5,
		"alert_radius": 6.0,
		"chase_radius": 12.0,
		"loot_table": &"loot_forest_minor",
		"ambush_warning_sfx": &"sfx_canopy_creak",
	},
	{
		"id": &"null_pointer_wisp",
		"display_name": "Null Pointer Wisp",
		"enemy_type": &"null_pointer_wisp",
		"regions": [&"wild_forest"],
		"placement": &"forest_clearing",
		"spawn_pattern": &"float",
		"phases": [&"night"],
		"weather_blacklist": [],
		"base_pack_size": 2,
		"max_pack_size": 4,
		"base_density": 4,
		"alert_radius": 12.0,
		"chase_radius": 20.0,
		"explodes_on_contact": true,
		"loot_table": &"loot_void_minor",
	},
	{
		"id": &"crash_daemon",
		"display_name": "Crash Daemon",
		"enemy_type": &"crash_daemon",
		"regions": [&"wild_ruins"],
		"placement": &"ruin_floor_crack",
		"spawn_pattern": &"emerge_from_ground",
		"phases": [&"day", &"dusk", &"night"],
		"weather_blacklist": [],
		"base_pack_size": 1,
		"max_pack_size": 3,
		"base_density": 6,
		"alert_radius": 9.0,
		"chase_radius": 15.0,
		"loot_table": &"loot_ruin_minor",
	},
	{
		"id": &"memory_leak",
		"display_name": "Memory Leak",
		"enemy_type": &"memory_leak",
		"regions": [&"wild_ruins"],
		"placement": &"ruin_archway",
		"spawn_pattern": &"drift_from_arch",
		"phases": [&"dawn", &"day", &"dusk", &"night"],
		"weather_blacklist": [],
		"base_pack_size": 1,
		"max_pack_size": 2,
		"base_density": 4,
		"alert_radius": 7.0,
		"chase_radius": 12.0,
		"slow_aura_radius": 3.0,
		"loot_table": &"loot_ruin_minor",
	},
]

# Iteration → density multiplier curve (30% at iter 1, 100% at iter 9+)
const ITERATION_DENSITY_CURVE: Array[float] = [
	0.30,  # iter 1
	0.40,  # iter 2
	0.50,  # iter 3
	0.60,  # iter 4
	0.70,  # iter 5
	0.78,  # iter 6
	0.86,  # iter 7
	0.93,  # iter 8
	1.00,  # iter 9
]

static var _index: Dictionary = {}


static func _ensure_index() -> void:
	if not _index.is_empty():
		return
	for entry: Dictionary in WILDERNESS_ENEMIES:
		_index[entry["id"]] = entry


static func get_enemy(enemy_id: StringName) -> Dictionary:
	_ensure_index()
	return _index.get(enemy_id, {})


static func get_all() -> Array[Dictionary]:
	return WILDERNESS_ENEMIES.duplicate()


static func get_for_region(region_id: StringName) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for entry: Dictionary in WILDERNESS_ENEMIES:
		if entry.get("regions", []).has(region_id):
			result.append(entry)
	return result


static func get_density_multiplier_for_iteration(iteration: int) -> float:
	if iteration <= 0:
		return ITERATION_DENSITY_CURVE[0]
	if iteration >= ITERATION_DENSITY_CURVE.size():
		return 1.0
	return ITERATION_DENSITY_CURVE[iteration - 1]


static func get_count() -> int:
	return WILDERNESS_ENEMIES.size()
