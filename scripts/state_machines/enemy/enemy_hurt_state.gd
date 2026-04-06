class_name EnemyHurtState
extends State
## Enemy was hit — brief stun with knockback.

const STUN_DURATION: float = 0.3
const KNOCKBACK_SPEED: float = 6.0

var _timer: float = 0.0
var _knockback_dir: Vector3 = Vector3.ZERO


func enter() -> void:
	var enemy: EnemyBase = player as EnemyBase
	_timer = 0.0

	if enemy.has_meta(&"damage_source_position"):
		var source_pos: Vector3 = enemy.get_meta(&"damage_source_position") as Vector3
		_knockback_dir = (enemy.global_position - source_pos).normalized()
		_knockback_dir.y = 0.0
		enemy.remove_meta(&"damage_source_position")
	else:
		_knockback_dir = Vector3.ZERO

	if enemy.animation_player.has_animation(&"hurt"):
		enemy.animation_player.play(&"hurt")


func physics_update(delta: float) -> void:
	var enemy: EnemyBase = player as EnemyBase
	_timer += delta

	var factor: float = maxf(0.0, 1.0 - _timer / STUN_DURATION)
	enemy.velocity = _knockback_dir * KNOCKBACK_SPEED * factor
	enemy.move_and_slide()

	if _timer >= STUN_DURATION:
		state_machine.transition_to(state_machine.get_node("EnemyChaseState") as State)
