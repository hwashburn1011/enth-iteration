class_name PlayerWalkState
extends State
## Player is moving via WASD input.


func enter() -> void:
	var p: Player = player as Player
	if p and p.animation_player.has_animation(&"walk"):
		p.animation_player.play(&"walk")


func handle_input(event: InputEvent) -> void:
	var p: Player = player as Player
	if event.is_action_pressed(&"dash") and p.can_dash:
		state_machine.transition_to(state_machine.get_node("DashState") as State)
	elif event.is_action_pressed(&"attack_primary") and p.can_attack:
		state_machine.transition_to(state_machine.get_node("AttackState") as State)


func physics_update(delta: float) -> void:
	var p: Player = player as Player
	var input_vector: Vector2 = Input.get_vector(
		&"move_left", &"move_right", &"move_forward", &"move_back"
	)

	if input_vector.length() <= 0.0:
		state_machine.transition_to(state_machine.get_node("IdleState") as State)
		return

	var camera: Camera3D = p.get_viewport().get_camera_3d()
	var camera_basis: Basis = Basis(Vector3.UP, camera.global_rotation.y) if camera else Basis.IDENTITY
	var direction: Vector3 = camera_basis * Vector3(input_vector.x, 0.0, input_vector.y)
	direction = direction.normalized()

	p.velocity = direction * p.move_speed
	p.facing_direction = direction

	var target_angle: float = atan2(direction.x, direction.z)
	p.model.rotation.y = lerp_angle(p.model.rotation.y, target_angle, p.turn_speed * delta)

	p.move_and_slide()
