class_name BossComponent
extends Node

## Player-side boss progression tracker. Records defeated bosses, clear times,
## boss rush state, and per-boss best stats.

signal boss_defeated(boss_id: StringName, clear_time_seconds: int)
signal boss_phase_advanced(boss_id: StringName, new_phase: int)

var defeated_bosses: Array[StringName] = []
var boss_clear_times: Dictionary = {}  ## boss_id -> seconds
var boss_attempts: Dictionary = {}     ## boss_id -> count
var boss_rush_completed: bool = false
var boss_rush_best_time: int = -1

# Active boss state
var current_boss_id: StringName = &""
var current_phase: int = 0
var current_hp: float = 0.0
var current_phase_max_hp: float = 0.0
var fight_start_time: int = -1


# === FIGHT LIFECYCLE ===

func start_fight(boss_id: StringName) -> void:
	current_boss_id = boss_id
	current_phase = 0
	var phase: Dictionary = BossDatabase.get_phase(boss_id, 0)
	current_phase_max_hp = float(phase.get("hp", 1000))
	current_hp = current_phase_max_hp
	fight_start_time = Time.get_unix_time_from_system()
	boss_attempts[boss_id] = boss_attempts.get(boss_id, 0) + 1


func damage_boss(amount: float) -> void:
	if current_boss_id == &"":
		return
	current_hp -= amount
	if current_hp <= 0.0:
		_advance_phase_or_die()


func _advance_phase_or_die() -> void:
	var phase_count: int = BossDatabase.get_phase_count(current_boss_id)
	if current_phase + 1 < phase_count:
		current_phase += 1
		var phase: Dictionary = BossDatabase.get_phase(current_boss_id, current_phase)
		current_phase_max_hp = float(phase.get("hp", 1000))
		current_hp = current_phase_max_hp
		boss_phase_advanced.emit(current_boss_id, current_phase)
	else:
		_finish_fight()


func _finish_fight() -> void:
	var clear_time: int = Time.get_unix_time_from_system() - fight_start_time
	if not defeated_bosses.has(current_boss_id):
		defeated_bosses.append(current_boss_id)
	# Record best clear time
	var prev: int = boss_clear_times.get(current_boss_id, INF)
	if clear_time < prev:
		boss_clear_times[current_boss_id] = clear_time
	boss_defeated.emit(current_boss_id, clear_time)
	current_boss_id = &""


func get_phase_progress() -> float:
	if current_phase_max_hp <= 0:
		return 0.0
	return current_hp / current_phase_max_hp


func get_total_progress() -> float:
	if current_boss_id == &"":
		return 0.0
	var total_max: int = BossDatabase.get_total_hp(current_boss_id)
	if total_max <= 0:
		return 0.0
	# Sum HP of all phases up to current + current phase HP
	var hp_remaining: float = current_hp
	var phases: Array = BossDatabase.get_boss(current_boss_id).get("phases", [])
	for i in range(current_phase + 1, phases.size()):
		hp_remaining += float(phases[i].get("hp", 0))
	return hp_remaining / float(total_max)


# === BOSS RUSH ===

func is_boss_rush_unlocked() -> bool:
	# Need to defeat all 5 new bosses + the original Compiler
	const REQUIRED: PackedStringArray = [
		"corrupted_compiler", "memory_warden", "root_heart",
		"sentinel_prime", "iteration_phantom", "compiler_reborn",
	]
	for boss_id in REQUIRED:
		if not defeated_bosses.has(StringName(boss_id)):
			return false
	return true


func record_boss_rush_completion(time_seconds: int) -> void:
	boss_rush_completed = true
	if boss_rush_best_time < 0 or time_seconds < boss_rush_best_time:
		boss_rush_best_time = time_seconds


# === SAVE / LOAD ===

func to_save_data() -> Dictionary:
	return {
		"defeated_bosses": defeated_bosses.map(func(s: StringName) -> String: return String(s)),
		"boss_clear_times": boss_clear_times,
		"boss_attempts": boss_attempts,
		"boss_rush_completed": boss_rush_completed,
		"boss_rush_best_time": boss_rush_best_time,
	}


func from_save_data(data: Dictionary) -> void:
	defeated_bosses.clear()
	for s in data.get("defeated_bosses", []):
		defeated_bosses.append(StringName(s))
	boss_clear_times = data.get("boss_clear_times", {})
	boss_attempts = data.get("boss_attempts", {})
	boss_rush_completed = data.get("boss_rush_completed", false)
	boss_rush_best_time = data.get("boss_rush_best_time", -1)
