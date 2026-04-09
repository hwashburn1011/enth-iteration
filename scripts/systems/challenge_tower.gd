class_name ChallengeTower
extends Node

## 50-floor escalating challenge mode. Each floor has procedural modifiers
## that escalate with floor number. Tracks attempts, best floor reached,
## clear times.

signal floor_started(floor: int, modifiers: Array[StringName])
signal floor_cleared(floor: int)
signal tower_cleared(total_time_seconds: int)
signal player_failed(floor: int)

const TOTAL_FLOORS: int = 50
const TOWER_LORD_FLOOR: int = 50

const MODIFIERS: Array[Dictionary] = [
	{"id": &"no_prompts",      "name": "No Prompts",       "desc": "Cannot use prompt items.", "tier": 1},
	{"id": &"double_damage",   "name": "Glass Dance",      "desc": "All damage doubled.", "tier": 2},
	{"id": &"lifesteal_50",    "name": "Vampire Mode",     "desc": "Enemies have 50% lifesteal.", "tier": 2},
	{"id": &"cd_x15",          "name": "Sluggish",         "desc": "All cooldowns x1.5.", "tier": 1},
	{"id": &"no_compute_regen","name": "Drained",          "desc": "Compute regen disabled.", "tier": 1},
	{"id": &"enemy_speed_x2",  "name": "Hyper Threat",     "desc": "Enemies move 2x faster.", "tier": 2},
	{"id": &"no_dash",         "name": "Grounded",         "desc": "Dash disabled.", "tier": 3},
	{"id": &"shared_hp",       "name": "Shared Pain",      "desc": "Damage taken also drains compute.", "tier": 2},
	{"id": &"falling_blocks",  "name": "Stack Overflow",   "desc": "Falling code blocks throughout.", "tier": 3},
	{"id": &"low_visibility",  "name": "Dark Vault",       "desc": "Visibility radius halved.", "tier": 3},
]

var current_floor: int = 0
var run_active: bool = false
var run_start_time: int = -1
var attempts: int = 0
var highest_floor_reached: int = 0
var clear_count: int = 0
var best_clear_time: int = -1


func is_unlocked(quest_component: Node) -> bool:
	if quest_component == null or not quest_component.has_method("is_quest_complete"):
		return false
	return quest_component.completed_quests.has(StringName("main_25_compaction5"))


func start_run() -> void:
	current_floor = 1
	run_active = true
	run_start_time = Time.get_unix_time_from_system()
	attempts += 1
	_emit_floor_start()


func clear_current_floor() -> void:
	if not run_active:
		return
	floor_cleared.emit(current_floor)
	if current_floor > highest_floor_reached:
		highest_floor_reached = current_floor
	if current_floor >= TOTAL_FLOORS:
		_complete_run()
	else:
		current_floor += 1
		_emit_floor_start()


func fail_run() -> void:
	if not run_active:
		return
	run_active = false
	player_failed.emit(current_floor)


func _complete_run() -> void:
	var total_time: int = Time.get_unix_time_from_system() - run_start_time
	run_active = false
	clear_count += 1
	if best_clear_time < 0 or total_time < best_clear_time:
		best_clear_time = total_time
	tower_cleared.emit(total_time)


func _emit_floor_start() -> void:
	var mods: Array[StringName] = _generate_modifiers_for_floor(current_floor)
	floor_started.emit(current_floor, mods)


func _generate_modifiers_for_floor(floor: int) -> Array[StringName]:
	## Modifier count + tier scales with floor.
	var mod_count: int = 0
	var max_tier: int = 1
	if floor <= 10:
		mod_count = 1
		max_tier = 1
	elif floor <= 20:
		mod_count = 1
		max_tier = 2
	elif floor <= 30:
		mod_count = 2
		max_tier = 2
	elif floor <= 40:
		mod_count = 3
		max_tier = 3
	elif floor < TOWER_LORD_FLOOR:
		mod_count = 3
		max_tier = 3
	else:
		# Tower Lord floor — fixed challenging modifier set
		return [&"double_damage", &"no_dash", &"no_prompts"]

	var eligible: Array[Dictionary] = []
	for m in MODIFIERS:
		if m["tier"] <= max_tier:
			eligible.append(m)
	eligible.shuffle()
	var result: Array[StringName] = []
	for i in mod_count:
		if i < eligible.size():
			result.append(StringName(eligible[i]["id"]))
	return result


func get_floor_reward(floor: int) -> Dictionary:
	## Returns the rewards for clearing this floor
	var rewards: Dictionary = {"gold": 100 * floor}
	if floor % 5 == 0:
		rewards["materials"] = {"quantum_shard": floor / 5}
	if floor == 10:
		rewards["cosmetic"] = "tower_floor_10_cosmetic"
	if floor == 25:
		rewards["outfit_piece"] = "tower_floor_25_piece"
	if floor == TOWER_LORD_FLOOR:
		rewards["legendary_core"] = "core_tower_lords_resolve"
	return rewards


# === SAVE / LOAD ===

func to_save_data() -> Dictionary:
	return {
		"attempts": attempts,
		"highest_floor_reached": highest_floor_reached,
		"clear_count": clear_count,
		"best_clear_time": best_clear_time,
	}


func from_save_data(data: Dictionary) -> void:
	attempts = data.get("attempts", 0)
	highest_floor_reached = data.get("highest_floor_reached", 0)
	clear_count = data.get("clear_count", 0)
	best_clear_time = data.get("best_clear_time", -1)
