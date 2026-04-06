class_name PlayerIdleState
extends State
## Player is standing still, waiting for input.


func enter() -> void:
	var p: Player = player as Player
	if p and p.animation_player.has_animation(&"idle"):
		p.animation_player.play(&"idle")


func handle_input(event: InputEvent) -> void:
	var p: Player = player as Player
	if event.is_action_pressed(&"dash") and p.can_dash:
		state_machine.transition_to(state_machine.get_node("DashState") as State)
	elif event.is_action_pressed(&"attack_primary") and p.can_attack:
		state_machine.transition_to(state_machine.get_node("AttackState") as State)


func physics_update(_delta: float) -> void:
	var p: Player = player as Player
	var input_vector: Vector2 = Input.get_vector(
		&"move_left", &"move_right", &"move_forward", &"move_back"
	)

	if input_vector.length() > 0.0:
		state_machine.transition_to(state_machine.get_node("WalkState") as State)
		return

	p.velocity = p.velocity.lerp(Vector3.ZERO, p.friction)
	p.move_and_slide()
