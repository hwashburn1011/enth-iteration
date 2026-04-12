class_name PlayerDashState
extends "res://scripts/state_machines/state.gd"
## Teleport dash with i-frames. Instantly moves the player in facing direction.
##
## Attack-cancel: after a brief DASH_CANCEL_LOCKOUT (60ms) the player can
## cancel out of dash i-frames into a primary attack via force_transition_to,
## allowing aggressive dash-attack weaves. The base AttackState will preserve
## the dash direction since p.facing_direction was set in enter().

const DASH_CANCEL_LOCKOUT: float = 0.06
const DASH_SHAKE_AMP: float = 0.06
const DASH_SHAKE_DECAY: float = 10.0

var _iframe_timer: float = 0.0
var _iframe_active: bool = false
## Snapshot of pre-dash material_override per mesh so _flash_transparent
## doesn't permanently wipe the polish materials applied by player.gd
## (orb body, eyes, antenna, etc). Same pattern T39 used for enemies.
var _pre_dash_materials: Dictionary = {}


func _ready() -> void:
	can_be_interrupted = false


func enter() -> void:
	var p: CharacterBody3D = player
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

	# Phase 3 #29 — Kinetic Dash chip: damage every enemy whose
	# global position lies near the dash path. Read once on dash
	# enter so the hit happens visually with the ghost trail.
	_apply_kinetic_dash_damage(p, from_position, p.global_position)

	# Brief screen shake on dash
	var camera: Camera3D = p.get_viewport().get_camera_3d()
	if camera and camera.has_method(&"shake"):
		camera.shake(DASH_SHAKE_AMP, DASH_SHAKE_DECAY)

	# Emit event
	EventBus.player_dashed.emit(from_position, p.global_position)

	# Start i-frames
	p.is_invulnerable = true
	_iframe_active = true
	_iframe_timer = 0.0
	_flash_transparent(p, true)

	# Start cooldown timer. Phase 3 #28: Persistent Thread core
	# subtracts dash_cooldown_reduction seconds (clamped at 0.2s
	# floor so the player can't permanently dash). Defensive
	# against missing equipment / empty core slot / non-core resource.
	p.can_dash = false
	var cd: float = p.dash_cooldown
	var equip: Node = p.get_node_or_null("EquipmentComponent") as Node
	if equip:
		var core: Resource = equip.get(&"core_slot") as Resource
		if core != null and (&"dash_cooldown_reduction" in core):
			cd -= float(core.dash_cooldown_reduction)
	# Phase 3 #26 — passive dash cooldown reduction from skill tree nodes.
	if p.has_meta(&"passive_dash_cd_reduction"):
		cd -= float(p.get_meta(&"passive_dash_cd_reduction"))
	cd = maxf(0.2, cd)
	p.dash_cooldown_timer.start(cd)


func handle_input(event: InputEvent) -> void:
	## Dash-cancel into attack — opens after DASH_CANCEL_LOCKOUT so the
	## dash always commits visually. Charged-attack cancel is also allowed
	## so a held button can be released into a burst.
	if not _iframe_active or _iframe_timer < DASH_CANCEL_LOCKOUT:
		return
	var p: CharacterBody3D = player
	if event.is_action_pressed(&"attack_primary") and p.can_attack:
		state_machine.force_transition_to(state_machine.get_node("AttackState") as Node)
	elif event.is_action_pressed(&"attack_secondary") and p.can_attack:
		state_machine.force_transition_to(state_machine.get_node("ChargeState") as Node)


func physics_update(delta: float) -> void:
	if not _iframe_active:
		return
	var p: CharacterBody3D = player
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


## Phase 3 #29 — Kinetic Dash chip damage tuning. Hit anything within
## KINETIC_DASH_RADIUS of the dash line for a flat damage value scaled
## off processing. Constants live here so the chip is one rebalance
## edit away from being retuned.
const KINETIC_DASH_RADIUS: float = 1.5
const KINETIC_DASH_DAMAGE: float = 14.0
const KINETIC_DASH_PROCESSING_SCALE: float = 0.6


func _apply_kinetic_dash_damage(p: CharacterBody3D, from: Vector3, to: Vector3) -> void:
	## Read once per dash. The chip lookup is cheap (4 slot iter) so
	## we don't cache. Defensive against missing equipment / no chips.
	var equip: Node = p.get_node_or_null("EquipmentComponent") as Node
	if equip == null or not equip.has_method(&"has_chip_passive"):
		return
	if not equip.has_chip_passive("dash_kinetic"):
		return
	var stats: Node = p.get_node_or_null("StatsComponent") as Node
	var processing: float = 0.0
	if stats and stats.has_method(&"get_stat"):
		processing = float(stats.get_stat("processing"))
	var dmg: float = KINETIC_DASH_DAMAGE + processing * KINETIC_DASH_PROCESSING_SCALE
	var dash_dir: Vector3 = to - from
	var dash_len: float = dash_dir.length()
	if dash_len < 0.01:
		return
	dash_dir = dash_dir / dash_len
	# Walk every enemy and reject any whose perpendicular distance
	# from the dash line exceeds the radius. The math is point-to-
	# segment in 3D — we project onto the dash dir and clamp.
	for enemy: Node in p.get_tree().get_nodes_in_group(&"enemies"):
		if not enemy is Node3D:
			continue
		var enemy_pos: Vector3 = (enemy as Node3D).global_position
		var to_enemy: Vector3 = enemy_pos - from
		var t: float = clampf(to_enemy.dot(dash_dir), 0.0, dash_len)
		var nearest: Vector3 = from + dash_dir * t
		if enemy_pos.distance_to(nearest) > KINETIC_DASH_RADIUS:
			continue
		var hp: Node = enemy.get_node_or_null("HealthComponent") as Node
		if hp and hp.has_method(&"take_damage"):
			hp.take_damage(dmg)


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
		var ghost_mat: StandardMaterial3D = StandardMaterial3D.new()
		ghost_mat.albedo_color = Color(0.2, 0.8, 0.75, 0.4 - i * 0.1)
		ghost_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		ghost_mat.emission_enabled = true
		ghost_mat.emission = Color(0.15, 0.65, 0.6)
		ghost_mat.emission_energy_multiplier = 1.5
		ghost_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		ghost.material_override = ghost_mat
		scene_root.add_child(ghost)
		ghost.global_position = ghost_pos
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
	trail_particles.global_position = from.lerp(to, 0.5) + Vector3(0, 0.5, 0)
	p.get_tree().create_timer(0.6).timeout.connect(trail_particles.queue_free)


func _flash_transparent(p: CharacterBody3D, transparent: bool) -> void:
	var meshes: Array[MeshInstance3D] = p.get_mesh_instances()
	if transparent:
		_pre_dash_materials.clear()
		var mat: StandardMaterial3D = StandardMaterial3D.new()
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		mat.albedo_color = Color(1.0, 1.0, 1.0, 0.3)
		for mesh: MeshInstance3D in meshes:
			_pre_dash_materials[mesh] = mesh.material_override
			mesh.material_override = mat
	else:
		for mesh: MeshInstance3D in meshes:
			if _pre_dash_materials.has(mesh):
				mesh.material_override = _pre_dash_materials[mesh]
		_pre_dash_materials.clear()
