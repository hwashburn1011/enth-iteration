class_name CompanionState
extends RefCounted

## Base class for companion AI states. State machines drive the active
## companion's behavior in the dungeon. Each state implements:
##   enter(ai), exit(ai), tick(ai, delta), get_next_state(ai)
##
## The active companion node owns the state machine and ticks the current
## state every physics frame.

const STATE_IDLE: StringName = &"idle"
const STATE_FOLLOW: StringName = &"follow"
const STATE_CATCHUP: StringName = &"catchup"
const STATE_COMBAT: StringName = &"combat"
const STATE_REPOSITION: StringName = &"reposition"
const STATE_USE_ABILITY: StringName = &"use_ability"
const STATE_DOWNED: StringName = &"downed"


func get_state_id() -> StringName:
	return &""


func enter(_ai: Node) -> void:
	pass


func exit(_ai: Node) -> void:
	pass


func tick(_ai: Node, _delta: float) -> void:
	pass


func get_next_state(_ai: Node) -> StringName:
	## Returns the next state to transition to, or empty StringName to stay.
	return &""
