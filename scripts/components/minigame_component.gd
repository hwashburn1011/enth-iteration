class_name MinigameComponent
extends Node

## Player-side minigame state. Tracks: per-game attempts, successes, mastery
## levels, best scores, current difficulty, streaks. Drives unlocks (next
## difficulty tier, mastery rewards) and statistics for the UI.

signal minigame_completed(minigame_id: StringName, success: bool, score: int)
signal mastery_level_up(minigame_id: StringName, new_level: int)
signal difficulty_unlocked(minigame_id: StringName, new_difficulty: int)

const MASTERY_PER_LEVEL: PackedInt32Array = [0, 5, 12, 22, 35, 50, 70, 95, 125, 160, 200]

var minigame_state: Dictionary = {}  ## minigame_id -> { attempts, successes, best_score, mastery_xp, mastery_level, current_difficulty, streak }


func _ready() -> void:
	# Init all minigames
	for m in MinigameDatabase.get_all():
		minigame_state[m["id"]] = {
			"attempts": 0,
			"successes": 0,
			"best_score": 0,
			"mastery_xp": 0,
			"mastery_level": 1,
			"current_difficulty": 0,
			"streak": 0,
			"completed_easy": false,
			"completed_normal": false,
			"completed_hard": false,
			"completed_expert": false,
		}


# === COMPLETION ===

func record_attempt(minigame_id: StringName, success: bool, score: int = 0) -> void:
	var state: Dictionary = minigame_state.get(minigame_id)
	if state == null:
		return
	state["attempts"] = state.get("attempts", 0) + 1
	if success:
		state["successes"] = state.get("successes", 0) + 1
		state["streak"] = state.get("streak", 0) + 1
		state["best_score"] = max(state.get("best_score", 0), score)
		# Mastery XP
		var diff_index: int = state.get("current_difficulty", 0)
		var mastery_xp_gained: int = (diff_index + 1) * 2
		_grant_mastery_xp(minigame_id, mastery_xp_gained)
		# Unlock next difficulty
		_check_difficulty_unlock(minigame_id, diff_index)
	else:
		state["streak"] = 0
	minigame_completed.emit(minigame_id, success, score)


func _check_difficulty_unlock(minigame_id: StringName, completed_difficulty: int) -> void:
	var state: Dictionary = minigame_state[minigame_id]
	var key: String = ""
	match completed_difficulty:
		0: key = "completed_easy"
		1: key = "completed_normal"
		2: key = "completed_hard"
		3: key = "completed_expert"
	if key != "" and not state.get(key, false):
		state[key] = true
		var next_diff: int = completed_difficulty + 1
		if next_diff < 4 and state.get("current_difficulty", 0) == completed_difficulty:
			# Don't auto-bump current difficulty, just unlock it for selection
			difficulty_unlocked.emit(minigame_id, next_diff)


# === MASTERY ===

func _grant_mastery_xp(minigame_id: StringName, amount: int) -> void:
	var state: Dictionary = minigame_state.get(minigame_id)
	if state == null:
		return
	state["mastery_xp"] = state.get("mastery_xp", 0) + amount
	while state["mastery_level"] < MASTERY_PER_LEVEL.size() - 1 and state["mastery_xp"] >= MASTERY_PER_LEVEL[state["mastery_level"] + 1]:
		state["mastery_level"] += 1
		mastery_level_up.emit(minigame_id, state["mastery_level"])


func get_mastery_level(minigame_id: StringName) -> int:
	return minigame_state.get(minigame_id, {}).get("mastery_level", 1)


func has_practice_mode(minigame_id: StringName) -> bool:
	return get_mastery_level(minigame_id) >= 3


func has_cosmetic_unlock(minigame_id: StringName) -> bool:
	return get_mastery_level(minigame_id) >= 5


func has_title_unlock(minigame_id: StringName) -> bool:
	return get_mastery_level(minigame_id) >= 8


func has_legendary_quest(minigame_id: StringName) -> bool:
	return get_mastery_level(minigame_id) >= 10


# === DIFFICULTY ===

func set_difficulty(minigame_id: StringName, difficulty_index: int) -> bool:
	var state: Dictionary = minigame_state.get(minigame_id)
	if state == null:
		return false
	# Validate unlock
	if difficulty_index >= 1 and not state.get("completed_easy", false):
		return false
	if difficulty_index >= 2 and not state.get("completed_normal", false):
		return false
	if difficulty_index >= 3 and not state.get("completed_hard", false):
		return false
	state["current_difficulty"] = difficulty_index
	return true


func get_difficulty(minigame_id: StringName) -> int:
	return minigame_state.get(minigame_id, {}).get("current_difficulty", 0)


# === STATS ===

func get_success_rate(minigame_id: StringName) -> float:
	var state: Dictionary = minigame_state.get(minigame_id, {})
	var attempts: int = state.get("attempts", 0)
	if attempts == 0:
		return 0.0
	return float(state.get("successes", 0)) / float(attempts)


# === SAVE / LOAD ===

func to_save_data() -> Dictionary:
	var entries: Dictionary = {}
	for k: StringName in minigame_state.keys():
		entries[String(k)] = minigame_state[k]
	return entries


func from_save_data(data: Dictionary) -> void:
	for k in data.keys():
		minigame_state[StringName(k)] = data[k]
