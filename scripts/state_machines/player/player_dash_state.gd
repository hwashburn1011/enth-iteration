class_name PlayerDashState
extends "res://scripts/state_machines/state.gd"
## Teleport dash with i-frames. Instantly moves the player in facing direction.


func _ready() -> void:
	can_be_interrupted = false


func enter() -> void:
	var p: CharacterBody3D = player as CharacterBody3D
	var from_position: Vector3 = p.global_position

	# Play dash animation
	if p.animation_player.has_animation(&"dash"):
		p.animation_player.play(&"dash")

	# Determine dash direction — movement input or current facing
	var input_vector: Vector2 = Input.get_vector(
		&"move_left", &"move_right", &"move_forward", &"move_back"
	)
	var dash_dir: Vector3 = p.facing_direction
	if input_vector.length() > 0.0:
		var camera: Camera3D = p.get_viewport().get_camera_3d()
		var camera_basis: Basis = Basis(Vector3.UP, camera.global_rotation.y) if camera else Basis.IDENTITY
		dash_dir = (camera_basis * Vector3(input_vector.x, 0.0, input_vector.y)).normalized()

	# Wall collision check — test motion to find valid dash endpoint
	var target_offset: Vector3 = dash_dir * p.dash_distance
	var params := PhysicsTestMotionParameters3D.new()
	params.from = p.global_transform
	params.motion = target_offset
	var result := PhysicsTestMotionResult3D.new()

	if PhysicsServer3D.body_test_motion(p.get_rid(), params, result):
		target_offset = dash_dir * (p.dash_distance * result.get_collision_safe_fraction())

	p.global_position += target_offset
	p.facing_direction = dash_dir

	# Emit event
	EventBus.player_dashed.emit(from_position, p.global_position)

	# Start i-frames
	p.is_invulnerable = true
	_flash_transparent(p, true)

	# Start cooldown timer
	p.can_dash = false
	p.dash_cooldown_timer.start(p.dash_cooldown)

	# End i-frames after duration
	await p.get_tree().create_timer(p.iframe_duration).timeout
	p.is_invulnerable = false
	_flash_transparent(p, false)

	# Transition back based on input
	var current_input: Vector2 = Input.get_vector(
		&"move_left", &"move_right", &"move_forward", &"move_back"
	)
	if current_input.length() > 0.0:
		state_machine.transition_to(state_machine.get_node("WalkState") as Node)
	else:
		state_machine.transition_to(state_machine.get_node("IdleState") as Node)


func _flash_transparent(p: CharacterBody3D, transparent: bool) -> void:
	var mesh: MeshInstance3D = p.model.get_child(0) as MeshInstance3D
	if mesh == null:
		return
	if transparent:
		var mat: StandardMaterial3D = StandardMaterial3D.new()
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		mat.albedo_color = Color(1.0, 1.0, 1.0, 0.3)
		mesh.material_override = mat
	else:
		mesh.material_override = null
