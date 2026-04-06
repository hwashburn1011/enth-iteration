class_name PlayerWalkState
extends State
## Player is moving via WASD input.


func physics_update(delta: float) -> void:
	var player: Player = state_machine.get_parent() as Player
	var input_vector: Vector2 = Input.get_vector(
		&"move_left", &"move_right", &"move_forward", &"move_back"
	)

	if input_vector.length() <= 0.0:
		state_machine.transition_to(state_machine.get_node("IdleState") as State)
		return

	if Input.is_action_just_pressed(&"dash") and player.can_dash:
		state_machine.transition_to(state_machine.get_node("DashState") as State)
		return

	var camera: Camera3D = player.get_viewport().get_camera_3d()
	var camera_basis: Basis = Basis(Vector3.UP, camera.global_rotation.y) if camera else Basis.IDENTITY
	var direction: Vector3 = camera_basis * Vector3(input_vector.x, 0.0, input_vector.y)
	direction = direction.normalized()

	player.velocity = direction * player.move_speed
	player.facing_direction = direction

	var target_angle: float = atan2(direction.x, direction.z)
	player.model.rotation.y = lerp_angle(player.model.rotation.y, target_angle, player.turn_speed * delta)

	player.move_and_slide()
