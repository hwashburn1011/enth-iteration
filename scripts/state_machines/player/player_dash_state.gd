class_name PlayerDashState
extends State
## Teleport dash with i-frames. Instantly moves the player in facing direction.


func enter() -> void:
	var player: Player = state_machine.get_parent() as Player
	var from_position: Vector3 = player.global_position

	# Determine dash direction — movement input or current facing
	var input_vector: Vector2 = Input.get_vector(
		&"move_left", &"move_right", &"move_forward", &"move_back"
	)
	var dash_dir: Vector3 = player.facing_direction
	if input_vector.length() > 0.0:
		var camera: Camera3D = player.get_viewport().get_camera_3d()
		var camera_basis: Basis = Basis(Vector3.UP, camera.global_rotation.y) if camera else Basis.IDENTITY
		dash_dir = (camera_basis * Vector3(input_vector.x, 0.0, input_vector.y)).normalized()

	# Wall collision check — test motion to find valid dash endpoint
	var target_offset: Vector3 = dash_dir * player.dash_distance
	var params := PhysicsTestMotionParameters3D.new()
	params.from = player.global_transform
	params.motion = target_offset
	var result := PhysicsTestMotionResult3D.new()

	if PhysicsServer3D.body_test_motion(player.get_rid(), params, result):
		# Hit something — stop at last safe position
		target_offset = dash_dir * (player.dash_distance * result.get_collision_safe_fraction())

	player.global_position += target_offset
	player.facing_direction = dash_dir

	# Emit event
	EventBus.player_dashed.emit(from_position, player.global_position)

	# Start i-frames
	player.is_invulnerable = true
	_flash_transparent(player, true)

	# Start cooldown timer
	player.can_dash = false
	player.dash_cooldown_timer.start(player.dash_cooldown)

	# End i-frames after duration
	var tree: SceneTree = player.get_tree()
	await tree.create_timer(player.iframe_duration).timeout
	player.is_invulnerable = false
	_flash_transparent(player, false)

	# Transition back based on input
	var current_input: Vector2 = Input.get_vector(
		&"move_left", &"move_right", &"move_forward", &"move_back"
	)
	if current_input.length() > 0.0:
		state_machine.transition_to(state_machine.get_node("WalkState") as State)
	else:
		state_machine.transition_to(state_machine.get_node("IdleState") as State)


func _flash_transparent(player: Player, transparent: bool) -> void:
	var mesh: MeshInstance3D = player.model.get_child(0) as MeshInstance3D
	if mesh == null:
		return
	if transparent:
		var mat: StandardMaterial3D = StandardMaterial3D.new()
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		mat.albedo_color = Color(1.0, 1.0, 1.0, 0.3)
		mesh.material_override = mat
	else:
		mesh.material_override = null
