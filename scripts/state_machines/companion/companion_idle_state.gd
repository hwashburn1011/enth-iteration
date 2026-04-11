class_name CompanionIdleState
extends CompanionState

## Idle: standing still near the player. Plays idle animation, occasional
## banter. Transitions to Follow when player moves, Combat when enemies appear.

const IDLE_BANTER_INTERVAL_MIN: float = 12.0
const IDLE_BANTER_INTERVAL_MAX: float = 24.0
const PLAYER_MOVE_THRESHOLD: float = 0.3

var _last_player_pos: Vector3
var _banter_timer: float = 0.0
var _next_banter_at: float = 15.0


func get_state_id() -> StringName:
	return STATE_IDLE


func enter(ai: Node) -> void:
	_last_player_pos = ai.player.global_position if ai.player != null else Vector3.ZERO
	if ai.has_method("play_animation"):
		ai.play_animation(&"idle")
	_banter_timer = 0.0
	_next_banter_at = randf_range(IDLE_BANTER_INTERVAL_MIN, IDLE_BANTER_INTERVAL_MAX)


func tick(ai: Node, delta: float) -> void:
	_banter_timer += delta
	if _banter_timer >= _next_banter_at:
		_banter_timer = 0.0
		_next_banter_at = randf_range(IDLE_BANTER_INTERVAL_MIN, IDLE_BANTER_INTERVAL_MAX)
		if ai.has_method("emit_banter"):
			ai.emit_banter(&"idle")


func get_next_state(ai: Node) -> StringName:
	if ai.has_method("get_health") and ai.get_health() <= 0.0:
		return STATE_DOWNED
	if ai.has_method("has_combat_target") and ai.has_combat_target():
		return STATE_COMBAT
	if ai.player != null:
		var dist: float = ai.global_position.distance_to(ai.player.global_position)
		if dist > PLAYER_MOVE_THRESHOLD * 5.0:
			return STATE_FOLLOW
	return &""
