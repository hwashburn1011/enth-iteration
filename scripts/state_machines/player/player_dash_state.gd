class_name PlayerDashState
extends "res://scripts/state_machines/state.gd"
## Teleport dash with i-frames. Instantly moves the player in facing direction.

var _iframe_timer: float = 0.0
var _iframe_active: bool = false


func _ready() -> void:
	can_be_interrupted = false


func enter() -> void:
	var p = player
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
		var dir_camera: Camera3D = p.get_viewport().get_camera_3d()
		var camera_basis: Basis = Basis(Vector3.UP, dir_camera.global_rotation.y) if dir_camera else Basis.IDENTITY
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

	# Dash ghost trail VFX
	_spawn_dash_trail(p, from_position, p.global_position)

	# Brief screen shake on dash
	var camera: Camera3D = p.get_viewport().get_camera_3d()
	if camera and camera.has_method(&"shake"):
		camera.shake(0.06, 10.0)

	# Emit event
	EventBus.player_dashed.emit(from_position, p.global_position)

	# Start i-frames
	p.is_invulnerable = true
	_iframe_active = true
	_iframe_timer = 0.0
	_flash_transparent(p, true)

	# Start cooldown timer
	p.can_dash = false
	p.dash_cooldown_timer.start(p.dash_cooldown)


func physics_update(delta: float) -> void:
	if not _iframe_active:
		return
	var p = player
	_iframe_timer += delta
	if _iframe_timer >= p.iframe_duration:
		_iframe_active = false
		p.is_invulnerable = false
		_flash_transparent(p, false)
		# Transition back based on input
		var current_input: Vector2 = Input.get_vector(
			&"move_left", &"move_right", &"move_forward", &"move_back"
		)
		if current_input.length() > 0.0:
			state_machine.force_transition_to(state_machine.get_node("WalkState") as Node)
		else:
			state_machine.force_transition_to(state_machine.get_node("IdleState") as Node)


func exit() -> void:
	_iframe_active = false
	player.is_invulnerable = false
	_flash_transparent(player, false)


func _spawn_dash_trail(p: CharacterBody3D, from: Vector3, to: Vector3) -> void:
	if not p.is_inside_tree():
		return
	var scene_root: Node = p.get_tree().current_scene
	var trail_dir: Vector3 = (to - from).normalized()

	# Ghost afterimages along the dash path (3 ghosts)
	for i: int in 3:
		var t: float = (i + 1) / 4.0
		var ghost_pos: Vector3 = from.lerp(to, t) + Vector3(0, 0.5, 0)
		var ghost: MeshInstance3D = MeshInstance3D.new()
		var sphere: SphereMesh = SphereMesh.new()
		sphere.radius = 0.3
		sphere.height = 0.6
		ghost.mesh = sphere
		ghost.global_position = ghost_pos
		var ghost_mat: StandardMaterial3D = StandardMaterial3D.new()
		ghost_mat.albedo_color = Color(0.2, 0.8, 0.75, 0.4 - i * 0.1)
		ghost_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		ghost_mat.emission_enabled = true
		ghost_mat.emission = Color(0.15, 0.65, 0.6)
		ghost_mat.emission_energy_multiplier = 1.5
		ghost_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		ghost.material_override = ghost_mat
		scene_root.add_child(ghost)
		var tween: Tween = ghost.create_tween()
		tween.tween_property(ghost_mat, "albedo_color:a", 0.0, 0.2 + i * 0.05)
		tween.parallel().tween_property(ghost, "scale", Vector3(0.5, 0.5, 0.5), 0.25)
		tween.tween_callback(ghost.queue_free)

	# Speed line particles along trail
	var trail_particles: GPUParticles3D = GPUParticles3D.new()
	trail_particles.amount = 12
	trail_particles.lifetime = 0.3
	trail_particles.one_shot = true
	trail_particles.emitting = true
	trail_particles.global_position = from.lerp(to, 0.5) + Vector3(0, 0.5, 0)
	var trail_mat: ParticleProcessMaterial = ParticleProcessMaterial.new()
	trail_mat.direction = Vector3(trail_dir.x, 0, trail_dir.z)
	trail_mat.spread = 20.0
	trail_mat.initial_velocity_min = 4.0
	trail_mat.initial_velocity_max = 6.0
	trail_mat.gravity = Vector3.ZERO
	trail_mat.color = Color(0.3, 0.9, 0.85, 0.6)
	trail_mat.scale_min = 0.2
	trail_mat.scale_max = 0.5
	trail_particles.process_material = trail_mat
	var line_mesh: BoxMesh = BoxMesh.new()
	line_mesh.size = Vector3(0.02, 0.02, 0.15)
	trail_particles.draw_pass_1 = line_mesh
	var line_vis: StandardMaterial3D = StandardMaterial3D.new()
	line_vis.albedo_color = Color(0.3, 0.9, 0.85, 0.6)
	line_vis.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	line_vis.emission_enabled = true
	line_vis.emission = Color(0.2, 0.7, 0.65)
	line_vis.emission_energy_multiplier = 2.0
	line_vis.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	trail_particles.material_override = line_vis
	scene_root.add_child(trail_particles)
	p.get_tree().create_timer(0.6).timeout.connect(trail_particles.queue_free)


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
