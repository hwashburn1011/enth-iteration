class_name HardcoreMode
extends Node

## Hardcore mode: full main story but death = permanent save deletion.
## Uses a separate save slot to prevent contamination of the main game save.

signal hardcore_run_started
signal hardcore_player_died(iteration_reached: int)
signal hardcore_iteration_cleared(iteration: int)
signal hardcore_run_completed

const HARDCORE_SAVE_PATH: String = "user://hardcore_save.json"

var hardcore_active: bool = false
var current_iteration_in_run: int = 1
var deaths_in_history: int = 0
var iterations_cleared_in_current_run: Array[int] = []
var has_completed_main_story: bool = false  # set when main game finished


func is_unlocked() -> bool:
	return has_completed_main_story


func start_run() -> bool:
	if not is_unlocked():
		return false
	hardcore_active = true
	current_iteration_in_run = 1
	iterations_cleared_in_current_run.clear()
	hardcore_run_started.emit()
	return true


func on_iteration_cleared(iteration: int) -> void:
	if not hardcore_active:
		return
	iterations_cleared_in_current_run.append(iteration)
	hardcore_iteration_cleared.emit(iteration)
	if iteration >= 9:
		_complete_run()
	else:
		current_iteration_in_run = iteration + 1


func on_player_died() -> void:
	if not hardcore_active:
		return
	deaths_in_history += 1
	hardcore_active = false
	hardcore_player_died.emit(current_iteration_in_run)
	# Delete the hardcore save
	if FileAccess.file_exists(HARDCORE_SAVE_PATH):
		DirAccess.remove_absolute(HARDCORE_SAVE_PATH)


func _complete_run() -> void:
	hardcore_active = false
	hardcore_run_completed.emit()


func get_unique_iterations_cleared() -> int:
	return iterations_cleared_in_current_run.size()


# === SAVE / LOAD (separate from main game) ===

func save_hardcore_state(state: Dictionary) -> void:
	if not hardcore_active:
		return
	var file: FileAccess = FileAccess.open(HARDCORE_SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_error("HardcoreMode: failed to write hardcore save")
		return
	state["current_iteration_in_run"] = current_iteration_in_run
	state["iterations_cleared_in_current_run"] = iterations_cleared_in_current_run
	file.store_string(JSON.stringify(state))
	file.close()


func load_hardcore_state() -> Dictionary:
	if not FileAccess.file_exists(HARDCORE_SAVE_PATH):
		return {}
	var file: FileAccess = FileAccess.open(HARDCORE_SAVE_PATH, FileAccess.READ)
	if file == null:
		return {}
	var content: String = file.get_as_text()
	file.close()
	var parsed: Variant = JSON.parse_string(content)
	if parsed is Dictionary:
		current_iteration_in_run = parsed.get("current_iteration_in_run", 1)
		iterations_cleared_in_current_run = parsed.get("iterations_cleared_in_current_run", [])
		hardcore_active = true
		return parsed
	return {}


# === META PROGRESS ===

func to_meta_save_data() -> Dictionary:
	return {
		"deaths_in_history": deaths_in_history,
		"has_completed_main_story": has_completed_main_story,
	}


func from_meta_save_data(data: Dictionary) -> void:
	deaths_in_history = data.get("deaths_in_history", 0)
	has_completed_main_story = data.get("has_completed_main_story", false)
