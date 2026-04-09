class_name CompanionDownedState
extends CompanionState

## Downed: HP reached 0. Companion is incapacitated for up to 30 seconds.
## Player can interact to revive (gives back 50% HP). After 30s, the
## companion auto-retreats to town and the player loses them for the rest
## of the dungeon run.

const FORCED_RETREAT_TIME: float = 30.0

var _downed_timer: float = 0.0


func get_state_id() -> StringName:
	return STATE_DOWNED


func enter(ai: Node) -> void:
	_downed_timer = 0.0
	if ai.has_method("play_animation"):
		ai.play_animation(&"downed")
	if ai.has_method("emit_banter"):
		ai.emit_banter(&"downed")
	# Notify the component that this companion is down
	if ai.has_method("notify_downed"):
		ai.notify_downed()


func tick(ai: Node, delta: float) -> void:
	_downed_timer += delta
	if _downed_timer >= FORCED_RETREAT_TIME:
		if ai.has_method("force_retreat"):
			ai.force_retreat()


func get_next_state(ai: Node) -> StringName:
	if ai.has_method("get_health") and ai.get_health() > 0.0:
		# Revived
		if ai.has_method("emit_banter"):
			ai.emit_banter(&"revived")
		return STATE_FOLLOW
	return &""
