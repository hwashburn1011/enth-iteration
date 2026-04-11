class_name PlayerAttackState
extends "res://scripts/state_machines/state.gd"
## Handles both Data Pulse (basic) and Energy Burst (charged) attacks.
##
## Hit feedback note: screen shake + hitstop fire on *successful* hit-confirm
## from _poll_hitbox_overlaps, not on swing start. This means missed swings
## are silent and connecting attacks feel impactful — the single biggest
## "game feel" lever per the design pillar of cozy-but-challenging combat.

const DATA_PULSE_ACTIVE_START: float = 0.1
const DATA_PULSE_ACTIVE_END: float = 0.3
const DATA_PULSE_DURATION: float = 0.4
const DATA_PULSE_COOLDOWN: float = 0.5
const ENERGY_BURST_ACTIVE_START: float = 0.05
const ENERGY_BURST_ACTIVE_END: float = 0.25
const ENERGY_BURST_DURATION: float = 0.5
const ENERGY_BURST_COOLDOWN: float = 1.5

# Hit-confirm feedback tuning
const HIT_SHAKE_AMP: float = 0.07
const HIT_SHAKE_DECAY: float = 14.0
const HIT_STOP_REAL_SECONDS: float = 0.04
const HIT_STOP_TIME_SCALE: float = 0.05
const BASE_DATA_PULSE_DAMAGE: float = 5.0
const PROCESSING_DAMAGE_SCALE: float = 1.5

var _timer: float = 0.0
var _hitbox_enabled: bool = false
var _has_hit: Dictionary = {}
var _is_energy_burst: bool = false
var _burst_damage: float = 0.0
var _active_start: float = 0.0
var _active_end: float = 0.0
var _duration: float = 0.0
var _hits_landed_this_swing: int = 0


func enter() -> void:
	var p: CharacterBody3D = player
	_timer = 0.0
	_hitbox_enabled = false
	_has_hit.clear()
	_hits_landed_this_swing = 0

	# Check attack type
	_is_energy_burst = p.has_meta(&"attack_type") and p.get_meta(&"attack_type") == &"energy_burst"

	if _is_energy_burst:
		_burst_damage = p.get_meta(&"energy_burst_damage", 10.0) as float
		_active_start = ENERGY_BURST_ACTIVE_START
		_active_end = ENERGY_BURST_ACTIVE_END
		_duration = ENERGY_BURST_DURATION
		# Scale hitbox larger for burst
		_set_hitbox_size(p, Vector3(2.5, 1.0, 2.5))
		p.remove_meta(&"attack_type")
		p.remove_meta(&"energy_burst_damage")
		p.remove_meta(&"energy_burst_charge_multiplier")
		p.can_attack = false
		p.attack_cooldown_timer.start(ENERGY_BURST_COOLDOWN)
		if p.animation_player.has_animation(&"energy_burst"):
			p.animation_player.play(&"energy_burst")
		elif p.animation_player.has_animation(&"attack_primary"):
			p.animation_player.play(&"attack_primary")
	else:
		_burst_damage = 0.0
		_active_start = DATA_PULSE_ACTIVE_START
		_active_end = DATA_PULSE_ACTIVE_END
		_duration = DATA_PULSE_DURATION
		# Restore default hitbox size
		_set_hitbox_size(p, Vector3(1.5, 1.0, 1.5))
		p.can_attack = false
		p.attack_cooldown_timer.start(DATA_PULSE_COOLDOWN)
		if p.animation_player.has_animation(&"attack_primary"):
			p.animation_player.play(&"attack_primary")

	# Face the mouse cursor
	var attack_dir: Vector3 = _get_mouse_world_direction(p)
	if attack_dir.length() > 0.0:
		p.facing_direction = attack_dir
		var target_angle: float = atan2(attack_dir.x, attack_dir.z)
		p.model.rotation.y = target_angle
		# Position hitbox in the attack direction
		p.hitbox_component.rotation.y = target_angle

	_set_hitbox_active(p, false)


func physics_update(delta: float) -> void:
	var p: CharacterBody3D = player
	_timer += delta

	if _timer >= _active_start and _timer < _active_end:
		if not _hitbox_enabled:
			# Set metadata on the hitbox so HurtboxComponent can read damage values
			if _is_energy_burst:
				p.hitbox_component.set_meta(&"base_damage", _burst_damage)
				p.hitbox_component.set_meta(&"damage_type", &"energy")
			else:
				var dmg: float = BASE_DATA_PULSE_DAMAGE + p.stats_component.get_stat("processing") * PROCESSING_DAMAGE_SCALE
				p.hitbox_component.set_meta(&"base_damage", dmg)
				p.hitbox_component.set_meta(&"damage_type", &"data")
			_set_hitbox_active(p, true)
			_hitbox_enabled = true
			_spawn_attack_arc(p)
			_spawn_attack_range_indicator(p)
			if _is_energy_burst:
				_spawn_burst_shockwave(p)
			# NB: basic attack screen shake moved to _on_hit_landed — only fires on confirmed hit
		# Poll for overlaps each frame (area_entered may not fire if already overlapping)
		_poll_hitbox_overlaps(p)
	elif _hitbox_enabled:
		_set_hitbox_active(p, false)
		_hitbox_enabled = false

	if _timer >= _duration:
		_set_hitbox_active(p, false)
		var input_vector: Vector2 = Input.get_vector(
			&"move_left", &"move_right", &"move_forward", &"move_back"
		)
		if input_vector.length() > 0.0:
			state_machine.transition_to(state_machine.get_node("WalkState") as Node)
		else:
			state_machine.transition_to(state_machine.get_node("IdleState") as Node)


func exit() -> void:
	var p: CharacterBody3D = player
	_set_hitbox_active(p, false)
	_hitbox_enabled = false
	# Restore default hitbox size
	_set_hitbox_size(p, Vector3(1.5, 1.0, 1.5))
	# Safety: clear any lingering time_scale dip if exit hits during hitstop
	if Engine.time_scale != 1.0:
		Engine.time_scale = 1.0


func _poll_hitbox_overlaps(p: CharacterBody3D) -> void:
	var hitbox: Node = p.hitbox_component
	if not hitbox.is_active:
		return
	for area: Area3D in hitbox.get_overlapping_areas():
		if area == p.hurtbox_component:
			continue  # Skip self
		if not area.has_method(&"_on_area_entered"):
			continue  # Not a hurtbox component
		var target_entity: Node = area.get_parent()
		if hitbox.has_hit(target_entity):
			continue  # Already hit this target
		# Trigger the hurtbox's damage processing (it will register the hit)
		area._on_area_entered(hitbox)
		# Confirm the hurtbox actually accepted the hit (it can no-op on
		# invulnerable targets, dead enemies, or self) before firing feedback.
		if hitbox.has_hit(target_entity):
			_on_hit_landed(p)


func _on_hit_landed(p: CharacterBody3D) -> void:
	## Fired once per *successful* hit-confirm. The Energy Burst already does
	## its own bigger shockwave/shake/hitstop in _spawn_burst_shockwave, so we
	## only add the basic-attack feedback here to avoid double-stacking.
	if _is_energy_burst:
		return
	_hits_landed_this_swing += 1
	# Only fire the screen shake on the first hit of a swing — multi-hit AoE
	# attacks (later modules) shouldn't compound shake on the same frame.
	if _hits_landed_this_swing == 1:
		var camera: Camera3D = p.get_viewport().get_camera_3d()
		if camera and camera.has_method(&"shake"):
			camera.shake(HIT_SHAKE_AMP, HIT_SHAKE_DECAY)
		_apply_hitstop(p)


func _apply_hitstop(p: CharacterBody3D) -> void:
	## Brief Engine.time_scale dip — uses an unscaled timer so the restore
	## fires reliably even though the world is slowed.
	if not p.is_inside_tree():
		return
	Engine.time_scale = HIT_STOP_TIME_SCALE
	p.get_tree().create_timer(HIT_STOP_REAL_SECONDS, true, false, true).timeout.connect(func() -> void:
		Engine.time_scale = 1.0
	)


func _set_hitbox_active(p: CharacterBody3D, active: bool) -> void:
	var hitbox: Node = p.hitbox_component
	if active:
		hitbox.activate()  # Sets is_active=true, clears hit_targets, enables monitoring
	else:
		hitbox.deactivate()  # Sets is_active=false, disables monitoring


func _set_hitbox_size(p: CharacterBody3D, size: Vector3) -> void:
	for child: Node in p.hitbox_component.get_children():
		if child is CollisionShape3D:
			var box: BoxShape3D = child.shape as BoxShape3D
			if box:
				box.size = size


func _get_mouse_world_direction(p: CharacterBody3D) -> Vector3:
	var camera: Camera3D = p.get_viewport().get_camera_3d()
	if camera == null:
		return p.facing_direction
	var mouse_pos: Vector2 = p.get_viewport().get_mouse_position()
	var ray_origin: Vector3 = camera.project_ray_origin(mouse_pos)
	var ray_dir: Vector3 = camera.project_ray_normal(mouse_pos)
	if absf(ray_dir.y) < 0.001:
		return p.facing_direction
	var t: float = -ray_origin.y / ray_dir.y
	var ground_pos: Vector3 = ray_origin + ray_dir * t
	var direction: Vector3 = (ground_pos - p.global_position)
	direction.y = 0.0
	if direction.length() < 0.1:
		return p.facing_direction
	return direction.normalized()


func _spawn_attack_arc(p: CharacterBody3D) -> void:
	if not p.is_inside_tree():
		return
	var scene_root: Node = p.get_tree().current_scene
	var arc_pos: Vector3 = p.global_position + p.facing_direction * 0.5 + Vector3(0, 0.5, 0)
	var arc_rot_y: float = atan2(p.facing_direction.x, p.facing_direction.z)

	var inner_color: Color
	var outer_color: Color
	var base_scale: Vector3
	if _is_energy_burst:
		inner_color = Color(0.4, 0.6, 1.0, 0.8)
		outer_color = Color(0.2, 0.4, 0.9, 0.4)
		base_scale = Vector3(1.5, 1.5, 0.3)
	else:
		inner_color = Color(0.3, 0.9, 0.85, 0.7)
		outer_color = Color(0.15, 0.6, 0.6, 0.35)
		base_scale = Vector3(1.0, 1.0, 0.2)

	# Layer 1: Bright inner arc
	var arc_inner: MeshInstance3D = MeshInstance3D.new()
	var torus_inner: TorusMesh = TorusMesh.new()
	torus_inner.inner_radius = 0.5
	torus_inner.outer_radius = 0.75
	torus_inner.rings = 10
	torus_inner.ring_segments = 14
	arc_inner.mesh = torus_inner
	arc_inner.position = arc_pos
	arc_inner.rotation.x = PI / 2.0
	arc_inner.rotation.y = arc_rot_y
	arc_inner.scale = base_scale
	var mat_inner: StandardMaterial3D = StandardMaterial3D.new()
	mat_inner.albedo_color = inner_color
	mat_inner.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat_inner.emission_enabled = true
	mat_inner.emission = Color(inner_color.r, inner_color.g, inner_color.b)
	mat_inner.emission_energy_multiplier = 2.5 if _is_energy_burst else 2.0
	mat_inner.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	arc_inner.material_override = mat_inner
	scene_root.add_child(arc_inner)

	# Layer 2: Soft outer glow
	var arc_outer: MeshInstance3D = MeshInstance3D.new()
	var torus_outer: TorusMesh = TorusMesh.new()
	torus_outer.inner_radius = 0.4
	torus_outer.outer_radius = 1.0
	torus_outer.rings = 8
	torus_outer.ring_segments = 12
	arc_outer.mesh = torus_outer
	arc_outer.position = arc_pos
	arc_outer.rotation.x = PI / 2.0
	arc_outer.rotation.y = arc_rot_y
	arc_outer.scale = base_scale * 1.1
	var mat_outer: StandardMaterial3D = StandardMaterial3D.new()
	mat_outer.albedo_color = outer_color
	mat_outer.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat_outer.emission_enabled = true
	mat_outer.emission = Color(outer_color.r, outer_color.g, outer_color.b)
	mat_outer.emission_energy_multiplier = 1.0
	mat_outer.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	arc_outer.material_override = mat_outer
	scene_root.add_child(arc_outer)

	# Inner arc: expand + fade
	var tween_in: Tween = arc_inner.create_tween()
	tween_in.tween_property(arc_inner, "scale", base_scale * 1.6, 0.12)
	tween_in.parallel().tween_property(mat_inner, "albedo_color:a", 0.0, 0.15)
	tween_in.tween_callback(arc_inner.queue_free)

	# Outer arc: expand slightly slower
	var tween_out: Tween = arc_outer.create_tween()
	tween_out.tween_property(arc_outer, "scale", base_scale * 1.8, 0.18)
	tween_out.parallel().tween_property(mat_outer, "albedo_color:a", 0.0, 0.2)
	tween_out.tween_callback(arc_outer.queue_free)

	# Spark particles along the arc
	var sparks: GPUParticles3D = GPUParticles3D.new()
	sparks.amount = 8
	sparks.lifetime = 0.25
	sparks.one_shot = true
	sparks.emitting = true
	sparks.position = arc_pos
	var spark_mat: ParticleProcessMaterial = ParticleProcessMaterial.new()
	spark_mat.direction = Vector3(p.facing_direction.x, 0.5, p.facing_direction.z)
	spark_mat.spread = 60.0
	spark_mat.initial_velocity_min = 3.0
	spark_mat.initial_velocity_max = 5.0
	spark_mat.gravity = Vector3(0, -4, 0)
	spark_mat.color = inner_color
	spark_mat.scale_min = 0.3
	spark_mat.scale_max = 0.7
	sparks.process_material = spark_mat
	var spark_mesh: BoxMesh = BoxMesh.new()
	spark_mesh.size = Vector3(0.03, 0.03, 0.03)
	sparks.draw_pass_1 = spark_mesh
	var spark_vis: StandardMaterial3D = StandardMaterial3D.new()
	spark_vis.albedo_color = inner_color
	spark_vis.emission_enabled = true
	spark_vis.emission = Color(inner_color.r, inner_color.g, inner_color.b)
	spark_vis.emission_energy_multiplier = 3.0
	spark_vis.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	sparks.material_override = spark_vis
	scene_root.add_child(sparks)
	p.get_tree().create_timer(0.5).timeout.connect(sparks.queue_free)


func _spawn_attack_range_indicator(p: CharacterBody3D) -> void:
	## Brief faint cyan ring showing attack reach
	if not p.is_inside_tree():
		return
	var ring: MeshInstance3D = MeshInstance3D.new()
	var torus: TorusMesh = TorusMesh.new()
	var attack_radius: float = 1.5 if not _is_energy_burst else 2.5
	torus.inner_radius = attack_radius - 0.05
	torus.outer_radius = attack_radius + 0.05
	torus.rings = 16
	torus.ring_segments = 16
	ring.mesh = torus
	var mat: StandardMaterial3D = StandardMaterial3D.new()
	mat.albedo_color = Color(0.3, 0.85, 0.85, 0.4)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.emission_enabled = true
	mat.emission = Color(0.25, 0.8, 0.8)
	mat.emission_energy_multiplier = 1.5
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	ring.material_override = mat
	p.get_tree().current_scene.add_child(ring)
	ring.global_position = p.global_position + Vector3(0, 0.05, 0)
	var tween: Tween = ring.create_tween()
	tween.tween_property(mat, "albedo_color:a", 0.0, 0.25)
	tween.tween_callback(ring.queue_free)


func _spawn_burst_shockwave(p: CharacterBody3D) -> void:
	## Energy Burst exclusive: expanding shockwave ring + screen shake + hitstop
	if not p.is_inside_tree():
		return
	var scene_root: Node = p.get_tree().current_scene
	var pos: Vector3 = p.global_position + Vector3(0, 0.1, 0)

	# Expanding ground shockwave ring
	var ring: MeshInstance3D = MeshInstance3D.new()
	var ring_mesh: TorusMesh = TorusMesh.new()
	ring_mesh.inner_radius = 0.3
	ring_mesh.outer_radius = 0.5
	ring_mesh.rings = 16
	ring_mesh.ring_segments = 20
	ring.mesh = ring_mesh
	ring.scale = Vector3(0.5, 0.5, 0.5)
	var ring_mat: StandardMaterial3D = StandardMaterial3D.new()
	ring_mat.albedo_color = Color(0.3, 0.55, 1.0, 0.7)
	ring_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	ring_mat.emission_enabled = true
	ring_mat.emission = Color(0.25, 0.5, 0.95)
	ring_mat.emission_energy_multiplier = 3.0
	ring_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	ring.material_override = ring_mat
	scene_root.add_child(ring)
	ring.global_position = pos
	var ring_tween: Tween = ring.create_tween()
	ring_tween.tween_property(ring, "scale", Vector3(4.0, 1.0, 4.0), 0.25).set_ease(Tween.EASE_OUT)
	ring_tween.parallel().tween_property(ring_mat, "albedo_color:a", 0.0, 0.3)
	ring_tween.tween_callback(ring.queue_free)

	# Radial particle burst (energy fragments)
	var burst: GPUParticles3D = GPUParticles3D.new()
	burst.amount = 20
	burst.lifetime = 0.4
	burst.one_shot = true
	burst.emitting = true
	var burst_mat: ParticleProcessMaterial = ParticleProcessMaterial.new()
	burst_mat.direction = Vector3(0, 0.3, 0)
	burst_mat.spread = 180.0
	burst_mat.initial_velocity_min = 4.0
	burst_mat.initial_velocity_max = 7.0
	burst_mat.gravity = Vector3(0, -2, 0)
	burst_mat.color = Color(0.35, 0.6, 1.0, 0.8)
	burst_mat.scale_min = 0.3
	burst_mat.scale_max = 1.0
	burst.process_material = burst_mat
	var burst_mesh: BoxMesh = BoxMesh.new()
	burst_mesh.size = Vector3(0.04, 0.04, 0.04)
	burst.draw_pass_1 = burst_mesh
	var burst_vis: StandardMaterial3D = StandardMaterial3D.new()
	burst_vis.albedo_color = Color(0.4, 0.65, 1.0, 0.8)
	burst_vis.emission_enabled = true
	burst_vis.emission = Color(0.3, 0.55, 0.95)
	burst_vis.emission_energy_multiplier = 3.5
	burst_vis.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	burst.material_override = burst_vis
	scene_root.add_child(burst)
	burst.global_position = pos + Vector3(0, 0.3, 0)
	p.get_tree().create_timer(0.7).timeout.connect(burst.queue_free)

	# Screen shake
	var camera: Camera3D = p.get_viewport().get_camera_3d()
	if camera and camera.has_method(&"shake"):
		camera.shake(0.2, 6.0)

	# Brief hitstop
	Engine.time_scale = 0.15
	p.get_tree().create_timer(0.05, true, false, true).timeout.connect(func() -> void:
		Engine.time_scale = 1.0
	)
