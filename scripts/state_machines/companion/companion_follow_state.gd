class_name CompanionFollowState
extends CompanionState

## Follow: walks behind the player at a fixed offset. Switches to Catchup
## if too far, Idle if close enough, Combat if enemies appear.

const IDLE_DISTANCE: float = 2.5
const CATCHUP_DISTANCE: float = 8.0


func get_state_id() -> StringName:
	return STATE_FOLLOW


func enter(ai: Node) -> void:
	if ai.has_method("play_animation"):
		ai.play_animation(&"walk")


func tick(ai: Node, delta: float) -> void:
	if ai.player == null:
		return
	var follow_offset: Vector3 = ai.companion_def.get("follow_offset", Vector3(-1.5, 0, -1.0))
	var target_pos: Vector3 = ai.player.global_position + follow_offset
	if ai.has_method("move_toward_position"):
		ai.move_toward_position(target_pos, delta)


func get_next_state(ai: Node) -> StringName:
	if ai.has_method("get_health") and ai.get_health() <= 0.0:
		return STATE_DOWNED
	if ai.has_method("has_combat_target") and ai.has_combat_target():
		return STATE_COMBAT
	if ai.player != null:
		var dist: float = ai.global_position.distance_to(ai.player.global_position)
		if dist > CATCHUP_DISTANCE:
			return STATE_CATCHUP
		if dist < IDLE_DISTANCE:
			return STATE_IDLE
	return &""
