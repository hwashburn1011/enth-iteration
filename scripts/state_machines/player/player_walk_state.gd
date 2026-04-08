class_name PlayerWalkState
extends "res://scripts/state_machines/state.gd"
## Player is moving via WASD input.

var _dust_timer: float = 0.0
const DUST_INTERVAL: float = 0.3


func enter() -> void:
	var p = player
	if p and p.animation_player.has_animation(&"walk"):
		p.animation_player.play(&"walk")


func handle_input(event: InputEvent) -> void:
	var p = player
	if event.is_action_pressed(&"dash") and p.can_dash:
		state_machine.transition_to(state_machine.get_node("DashState") as Node)
	elif event.is_action_pressed(&"attack_primary") and p.can_attack:
		state_machine.transition_to(state_machine.get_node("AttackState") as Node)
	elif event.is_action_pressed(&"attack_secondary") and p.can_attack:
		state_machine.transition_to(state_machine.get_node("ChargeState") as Node)


func physics_update(delta: float) -> void:
	var p = player
	var input_vector: Vector2 = Input.get_vector(
		&"move_left", &"move_right", &"move_forward", &"move_back"
	)

	if input_vector.length() <= 0.0:
		state_machine.transition_to(state_machine.get_node("IdleState") as Node)
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

	# Footstep dust particles
	_dust_timer += delta
	if _dust_timer >= DUST_INTERVAL:
		_dust_timer = 0.0
		_spawn_footstep_dust(p)


func _spawn_footstep_dust(p: CharacterBody3D) -> void:
	if not p.is_inside_tree():
		return
	var dust: MeshInstance3D = MeshInstance3D.new()
	var sphere: SphereMesh = SphereMesh.new()
	sphere.radius = 0.08
	sphere.height = 0.06
	dust.mesh = sphere
	var mat: StandardMaterial3D = StandardMaterial3D.new()
	# Use floor accent color if in dungeon, otherwise warm dust
	var dust_color: Color = Color(0.6, 0.55, 0.45, 0.4)
	if GameManager.has_meta(&"floor_accent_color"):
		var accent: Color = GameManager.get_meta(&"floor_accent_color") as Color
		dust_color = Color(accent.r * 0.6 + 0.3, accent.g * 0.6 + 0.3, accent.b * 0.6 + 0.3, 0.4)
	mat.albedo_color = dust_color
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.emission_enabled = true
	mat.emission = Color(dust_color.r * 0.5, dust_color.g * 0.5, dust_color.b * 0.5)
	mat.emission_energy_multiplier = 0.6
	dust.material_override = mat
	p.get_tree().current_scene.add_child(dust)
	dust.global_position = p.global_position + Vector3(randf_range(-0.15, 0.15), 0.05, randf_range(-0.15, 0.15))
	var tween: Tween = dust.create_tween()
	tween.tween_property(dust, "position:y", dust.position.y + 0.3, 0.4)
	tween.parallel().tween_property(dust, "scale", Vector3(2, 2, 2), 0.4)
	tween.parallel().tween_property(mat, "albedo_color:a", 0.0, 0.4)
	tween.tween_callback(dust.queue_free)
