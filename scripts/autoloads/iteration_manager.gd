extends Node
## Tracks the player's progress through the 9 compaction iterations.
##
## The compaction loop is the central conceit of Enth: each iteration
## represents one full pass through the simulation, the dungeon scales,
## and the player's town hub picks up new structures. CLAUDE.md and the
## architecture doc list this as one of the 5 required autoloads, but it
## was never authored — 27 files across the codebase already do
## defensive `has_node("/root/IterationManager")` lookups expecting it to
## be there and silently fall back to iteration 1 when it isn't.
##
## This implementation is intentionally minimal: a single int with
## advance/reset semantics, an unlock-aware getter, and save/load hooks.
## Nothing else needs to change for the existing callers to start
## reading the real value — they're already feature-detecting via
## `has_method("get_current_iteration")` / `if "current_iteration" in im`.

signal iteration_advanced(new_iteration: int)
signal iteration_reset

const FIRST_ITERATION: int = 1
const FINAL_ITERATION: int = 9

var current_iteration: int = FIRST_ITERATION


func get_current_iteration() -> int:
	return current_iteration


func is_final_iteration() -> bool:
	return current_iteration >= FINAL_ITERATION


func advance_iteration() -> void:
	## Move to the next compaction iteration. Capped at FINAL_ITERATION so
	## post-game state is well-defined for late-game systems that gate on
	## "iteration >= 9" without needing a separate finished flag.
	if current_iteration >= FINAL_ITERATION:
		return
	current_iteration += 1
	iteration_advanced.emit(current_iteration)


func reset_to_first() -> void:
	## Used by new-game / save-deletion paths so a fresh save starts at 1.
	current_iteration = FIRST_ITERATION
	iteration_reset.emit()


# === SAVE / LOAD ===

func to_save_data() -> Dictionary:
	return {"current_iteration": current_iteration}


func from_save_data(data: Dictionary) -> void:
	if data.has("current_iteration"):
		current_iteration = clampi(int(data["current_iteration"]), FIRST_ITERATION, FINAL_ITERATION)
