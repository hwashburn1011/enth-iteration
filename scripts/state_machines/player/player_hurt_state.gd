class_name PlayerHurtState
extends State
## Player was hit — brief stun with knockback, then recover or die.

const STUN_DURATION: float = 0.3
const KNOCKBACK_SPEED: float = 8.0

var _timer: float = 0.0
var _knockback_dir: Vector3 = Vector3.ZERO
var can_be_interrupted: bool = false  # only DeathState can interrupt


func enter() -> void:
	var p: Player = player as Player
	_timer = 0.0

	# Determine knockback direction from damage source metadata
	if p.has_meta(&"damage_source_position"):
		var source_pos: Vector3 = p.get_meta(&"damage_source_position") as Vector3
		_knockback_dir = (p.global_position - source_pos).normalized()
		_knockback_dir.y = 0.0
		p.remove_meta(&"damage_source_position")
	else:
		_knockback_dir = -p.facing_direction

	if p.animation_player.has_animation(&"hurt"):
		p.animation_player.play(&"hurt")


func physics_update(delta: float) -> void:
	var p: Player = player as Player
	_timer += delta

	# Apply decaying knockback
	var knockback_factor: float = maxf(0.0, 1.0 - _timer / STUN_DURATION)
	p.velocity = _knockback_dir * KNOCKBACK_SPEED * knockback_factor
	p.move_and_slide()

	if _timer >= STUN_DURATION:
		# Check if player died during stun
		if p.health_component.is_dead:
			state_machine.transition_to(state_machine.get_node("DeathState") as State)
			return
		var input_vector: Vector2 = Input.get_vector(
			&"move_left", &"move_right", &"move_forward", &"move_back"
		)
		if input_vector.length() > 0.0:
			state_machine.transition_to(state_machine.get_node("WalkState") as State)
		else:
			state_machine.transition_to(state_machine.get_node("IdleState") as State)
