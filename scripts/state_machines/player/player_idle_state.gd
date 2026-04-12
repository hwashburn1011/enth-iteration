class_name PlayerIdleState
extends "res://scripts/state_machines/state.gd"
## Player is standing still, waiting for input.


func enter() -> void:
	var p = player
	if p and p.animation_player.has_animation(&"idle"):
		p.animation_player.play(&"idle", 0.15)


func handle_input(event: InputEvent) -> void:
	var p = player
	if event.is_action_pressed(&"dash"):
		if p.can_dash:
			state_machine.transition_to(state_machine.get_node("DashState") as Node)
		else:
			_flash_cooldown_indicator(p, "DASH NOT READY")
	elif event.is_action_pressed(&"attack_primary"):
		if p.can_attack:
			state_machine.transition_to(state_machine.get_node("AttackState") as Node)
		else:
			_flash_cooldown_indicator(p, "")
	elif event.is_action_pressed(&"attack_secondary"):
		if p.can_attack:
			state_machine.transition_to(state_machine.get_node("ChargeState") as Node)
		else:
			_flash_cooldown_indicator(p, "")


func _flash_cooldown_indicator(p: CharacterBody3D, msg: String) -> void:
	## Subtle red flash on player ring when ability is on cooldown
	if not p.is_inside_tree():
		return
	var ring: MeshInstance3D = p.get_node_or_null("HighlightRing") as MeshInstance3D
	if ring == null or not is_instance_valid(ring):
		return
	var mat: StandardMaterial3D = ring.material_override as StandardMaterial3D
	if mat == null:
		return
	var original_color: Color = mat.albedo_color
	var tween: Tween = ring.create_tween()
	tween.tween_property(mat, "albedo_color", Color(0.95, 0.3, 0.1, 0.6), 0.05)
	tween.tween_property(mat, "albedo_color", original_color, 0.2)
	if msg != "":
		var label: Label3D = Label3D.new()
		label.text = msg
		label.font_size = 16
		label.modulate = Color(0.95, 0.3, 0.1)
		label.outline_modulate = Color(0, 0, 0, 0.6)
		label.outline_size = 3
		label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		label.position = p.global_position + Vector3(0, 1.4, 0)
		p.get_tree().current_scene.add_child(label)
		var label_tween: Tween = label.create_tween()
		label_tween.tween_property(label, "position:y", label.position.y + 0.6, 0.5).set_ease(Tween.EASE_OUT)
		label_tween.parallel().tween_property(label, "modulate:a", 0.0, 0.5)
		label_tween.tween_callback(label.queue_free)


func physics_update(_delta: float) -> void:
	var p = player
	var input_vector: Vector2 = Input.get_vector(
		&"move_left", &"move_right", &"move_forward", &"move_back"
	)

	if input_vector.length() > 0.0:
		state_machine.transition_to(state_machine.get_node("WalkState") as Node)
		return

	p.velocity = p.velocity.lerp(Vector3.ZERO, p.friction)
	p.move_and_slide()
