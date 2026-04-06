class_name PlayerIdleState
extends State
## Player is standing still, waiting for input.


func physics_update(_delta: float) -> void:
	var player: Player = state_machine.get_parent() as Player
	var input_vector: Vector2 = Input.get_vector(
		&"move_left", &"move_right", &"move_forward", &"move_back"
	)

	if input_vector.length() > 0.0:
		state_machine.transition_to(state_machine.get_node("WalkState") as State)
		return

	if Input.is_action_just_pressed(&"dash") and player.can_dash:
		state_machine.transition_to(state_machine.get_node("DashState") as State)
		return

	player.velocity = player.velocity.lerp(Vector3.ZERO, player.friction)
	player.move_and_slide()
