class_name PlayerAttackState
extends "res://scripts/state_machines/state.gd"
## Handles both Data Pulse (ranged lightning) and Energy Burst (charged AoE).
##
## Data Pulse fires a LightningProjectile in the mouse direction. The combo
## system still works — rapid-fire 3 bolts with escalating damage. Energy
## Burst remains a melee AoE centered on the player using the hitbox component.

const DATA_PULSE_DURATION: float = 0.4
const DATA_PULSE_COOLDOWN: float = 0.5
const DATA_PULSE_FIRE_TIME: float = 0.1  # fire bolt at this point in the swing
const ENERGY_BURST_ACTIVE_START: float = 0.05
const ENERGY_BURST_ACTIVE_END: float = 0.25
const ENERGY_BURST_DURATION: float = 0.5
const ENERGY_BURST_COOLDOWN: float = 1.5

# Hit-confirm feedback tuning (used by Energy Burst melee path only)
const HIT_SHAKE_AMP: float = 0.07
const HIT_SHAKE_DECAY: float = 14.0
const HIT_STOP_REAL_SECONDS: float = 0.06
const HIT_STOP_TIME_SCALE: float = 0.2
const BASE_DATA_PULSE_DAMAGE: float = 5.0
const PROCESSING_DAMAGE_SCALE: float = 1.5

# Combo system tuning — shared between ranged bolts and melee.
const COMBO_DAMAGE_MULTS: Array[float] = [1.0, 1.15, 1.60]
const COMBO_HITBOX_SIZES: Array[Vector3] = [
	Vector3(1.5, 1.0, 1.5),
	Vector3(1.7, 1.0, 1.7),
	Vector3(2.0, 1.0, 2.0),
]
const COMBO_SHAKE_BONUS: Array[float] = [0.0, 0.02, 0.08]
# Inner-arc tint per combo step (used only by Energy Burst now).
const COMBO_INNER_COLORS: Array[Color] = [
	Color(0.30, 0.90, 0.85, 0.7),
	Color(0.55, 0.95, 0.70, 0.78),
	Color(1.00, 0.85, 0.30, 0.85),
]

var _timer: float = 0.0
var _hitbox_enabled: bool = false
var _has_hit: Dictionary = {}
var _is_energy_burst: bool = false
var _burst_damage: float = 0.0
var _active_start: float = 0.0
var _active_end: float = 0.0
var _duration: float = 0.0
var _hits_landed_this_swing: int = 0
var _combo_step: int = 0
## Whether the lightning bolt has already been fired this swing.
var _bolt_fired: bool = false
## Cached attack direction for the projectile.
var _attack_direction: Vector3 = Vector3.FORWARD
## T90: Input buffering — queued attack during recovery chains into next combo.
var _buffered_attack: bool = false


func enter() -> void:
	var p: CharacterBody3D = player
	_timer = 0.0
	_hitbox_enabled = false
	_bolt_fired = false
	_buffered_attack = false
	_has_hit.clear()
	_hits_landed_this_swing = 0

	# Check attack type
	_is_energy_burst = p.has_meta(&"attack_type") and p.get_meta(&"attack_type") == &"energy_burst"

	if _is_energy_burst:
		_burst_damage = p.get_meta(&"energy_burst_damage", 10.0) as float
		_active_start = ENERGY_BURST_ACTIVE_START
		_active_end = ENERGY_BURST_ACTIVE_END
		_duration = ENERGY_BURST_DURATION
		# Scale hitbox 50% larger for burst (was 2.5 → now 3.75)
		_set_hitbox_size(p, Vector3(3.75, 1.0, 3.75))
		p.remove_meta(&"attack_type")
		p.remove_meta(&"energy_burst_damage")
		p.remove_meta(&"energy_burst_charge_multiplier")
		p.can_attack = false
		p.attack_cooldown_timer.start(ENERGY_BURST_COOLDOWN)
		# Energy burst breaks the data-pulse chain entirely.
		p.combo_count = 0
		p.combo_window_left = 0.0
		_combo_step = 0
		if p.animation_player.has_animation(&"energy_burst"):
			p.animation_player.play(&"energy_burst")
		elif p.animation_player.has_animation(&"attack_primary"):
			p.animation_player.play(&"attack_primary")
	else:
		_burst_damage = 0.0
		_duration = DATA_PULSE_DURATION
		# Advance the combo chain.
		var next_step: int = clampi(p.combo_count, 0, 2) + 1
		if next_step > 3:
			next_step = 1
		p.combo_count = next_step
		p.combo_window_left = p.COMBO_WINDOW
		_combo_step = next_step - 1  # 0, 1, or 2 → array index
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
		if _is_energy_burst:
			p.hitbox_component.rotation.y = target_angle
	_attack_direction = attack_dir if attack_dir.length() > 0.0 else p.facing_direction

	if _is_energy_burst:
		_set_hitbox_active(p, false)


func physics_update(delta: float) -> void:
	var p: CharacterBody3D = player
	_timer += delta

	if _is_energy_burst:
		# --- Energy Burst: melee AoE path (unchanged logic) ---
		if _timer >= _active_start and _timer < _active_end:
			if not _hitbox_enabled:
				p.hitbox_component.set_meta(&"base_damage", _burst_damage)
				p.hitbox_component.set_meta(&"damage_type", &"energy")
				_set_hitbox_active(p, true)
				_hitbox_enabled = true
				_spawn_attack_arc(p)
				_spawn_attack_range_indicator(p)
				_spawn_burst_shockwave(p)
			_poll_hitbox_overlaps(p)
		elif _hitbox_enabled:
			_set_hitbox_active(p, false)
			_hitbox_enabled = false
	else:
		# --- Data Pulse: ranged lightning projectile path ---
		if _timer >= DATA_PULSE_FIRE_TIME and not _bolt_fired:
			_bolt_fired = true
			_fire_lightning_bolt(p)

	# T90: Buffer attack input during recovery frames so queued clicks chain
	if _timer >= DATA_PULSE_FIRE_TIME and not _is_energy_burst:
		if Input.is_action_just_pressed(&"attack_primary"):
			_buffered_attack = true

	if _timer >= _duration:
		if _is_energy_burst:
			_set_hitbox_active(p, false)
		# T90: If attack was buffered during recovery, chain into next attack
		if _buffered_attack and p.can_attack:
			state_machine.transition_to(state_machine.get_node("AttackState") as Node)
			return
		var input_vector: Vector2 = Input.get_vector(
			&"move_left", &"move_right", &"move_forward", &"move_back"
		)
		if input_vector.length() > 0.0:
			state_machine.transition_to(state_machine.get_node("WalkState") as Node)
		else:
			state_machine.transition_to(state_machine.get_node("IdleState") as Node)


func exit() -> void:
	var p: CharacterBody3D = player
	if _is_energy_burst:
		_set_hitbox_active(p, false)
	_hitbox_enabled = false
	_bolt_fired = false
	# Restore default hitbox size
	_set_hitbox_size(p, Vector3(1.5, 1.0, 1.5))
	# Safety: clear any lingering time_scale dip if exit hits during hitstop
	if Engine.time_scale != 1.0:
		Engine.time_scale = 1.0


func _fire_lightning_bolt(p: CharacterBody3D) -> void:
	## Instantiate a LightningProjectile and add it to the scene tree.
	if not p.is_inside_tree():
		return
	var scene_root: Node = p.get_tree().current_scene
	var bolt: LightningProjectile = LightningProjectile.new()

	# Calculate damage using the same formula as the old melee path
	var base: float = BASE_DATA_PULSE_DAMAGE + p.stats_component.get_stat("processing") * PROCESSING_DAMAGE_SCALE
	var dmg: float = base * COMBO_DAMAGE_MULTS[_combo_step]

	# Spawn position: slightly in front of the player
	var spawn_pos: Vector3 = p.global_position + _attack_direction * 0.5 + Vector3(0, 0.5, 0)

	bolt.setup(p, _attack_direction, dmg, _combo_step)
	bolt.global_position = spawn_pos
	# Rotate bolt to face the attack direction
	bolt.rotation.y = atan2(_attack_direction.x, _attack_direction.z)

	scene_root.add_child(bolt)

	# Muzzle flash VFX at spawn point
	_spawn_muzzle_flash(p, spawn_pos)

	# Play attack SFX
	AudioManager.play_sfx("attack_miss")  # reuse until zap SFX exists


func _spawn_muzzle_flash(p: CharacterBody3D, pos: Vector3) -> void:
	## Brief cyan flash at the bolt spawn point.
	if not p.is_inside_tree():
		return
	var scene_root: Node = p.get_tree().current_scene
	var flash: MeshInstance3D = MeshInstance3D.new()
	var sphere: SphereMesh = SphereMesh.new()
	sphere.radius = 0.15
	sphere.height = 0.3
	flash.mesh = sphere
	flash.position = pos
	var mat: StandardMaterial3D = StandardMaterial3D.new()
	mat.albedo_color = Color(0.3, 0.9, 1.0, 0.8)
	mat.emission_enabled = true
	mat.emission = Color(0.3, 0.9, 1.0)
	mat.emission_energy_multiplier = 5.0
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	flash.material_override = mat
	scene_root.add_child(flash)
	var tween: Tween = flash.create_tween()
	tween.tween_property(flash, "scale", Vector3(1.5, 1.5, 1.5), 0.08)
	tween.parallel().tween_property(mat, "albedo_color:a", 0.0, 0.1)
	tween.tween_callback(flash.queue_free)


func _poll_hitbox_overlaps(p: CharacterBody3D) -> void:
	## Used only by Energy Burst melee AoE path.
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
	## Fired once per *successful* Energy Burst hit-confirm. Data Pulse
	## hit feedback is handled by the LightningProjectile itself.
	if _is_energy_burst:
		return
	_hits_landed_this_swing += 1
	if _hits_landed_this_swing == 1:
		var camera: Camera3D = p.get_viewport().get_camera_3d()
		if camera and camera.has_method(&"shake"):
			camera.shake(HIT_SHAKE_AMP + COMBO_SHAKE_BONUS[_combo_step], HIT_SHAKE_DECAY)
		_apply_hitstop(p)
		if _combo_step == 2:
			AudioManager.play_sfx("combo_finisher")


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
		# Violet/magenta for Energy Burst AoE — distinct from cyan lightning
		inner_color = Color(0.8, 0.2, 0.9, 0.8)
		outer_color = Color(0.6, 0.15, 0.7, 0.4)
		base_scale = Vector3(2.25, 2.25, 0.3)  # 50% larger to match bigger hitbox
	else:
		# Data Pulse arc is no longer used (bolts replace it), but keep
		# for potential future use. Combo step picks the arc tint.
		inner_color = COMBO_INNER_COLORS[_combo_step]
		outer_color = Color(inner_color.r * 0.55, inner_color.g * 0.65, inner_color.b * 0.65, 0.35)
		var finisher_scale: float = 1.0 + (0.25 if _combo_step == 2 else (0.10 if _combo_step == 1 else 0.0))
		base_scale = Vector3(finisher_scale, finisher_scale, 0.2)

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
	var attack_radius: float = 1.5 if not _is_energy_burst else 3.75
	torus.inner_radius = attack_radius - 0.05
	torus.outer_radius = attack_radius + 0.05
	torus.rings = 16
	torus.ring_segments = 16
	ring.mesh = torus
	var mat: StandardMaterial3D = StandardMaterial3D.new()
	var ring_color: Color = Color(0.7, 0.2, 0.85, 0.4) if _is_energy_burst else Color(0.3, 0.85, 0.85, 0.4)
	mat.albedo_color = ring_color
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.emission_enabled = true
	mat.emission = Color(ring_color.r, ring_color.g, ring_color.b)
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
	ring_mat.albedo_color = Color(0.7, 0.2, 0.85, 0.7)
	ring_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	ring_mat.emission_enabled = true
	ring_mat.emission = Color(0.65, 0.15, 0.8)
	ring_mat.emission_energy_multiplier = 3.5
	ring_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	ring.material_override = ring_mat
	scene_root.add_child(ring)
	ring.global_position = pos
	var ring_tween: Tween = ring.create_tween()
	ring_tween.tween_property(ring, "scale", Vector3(6.0, 1.0, 6.0), 0.25).set_ease(Tween.EASE_OUT)
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
	burst_mat.color = Color(0.7, 0.25, 0.85, 0.8)
	burst_mat.scale_min = 0.3
	burst_mat.scale_max = 1.0
	burst.process_material = burst_mat
	var burst_mesh: BoxMesh = BoxMesh.new()
	burst_mesh.size = Vector3(0.04, 0.04, 0.04)
	burst.draw_pass_1 = burst_mesh
	var burst_vis: StandardMaterial3D = StandardMaterial3D.new()
	burst_vis.albedo_color = Color(0.75, 0.3, 0.9, 0.8)
	burst_vis.emission_enabled = true
	burst_vis.emission = Color(0.65, 0.2, 0.85)
	burst_vis.emission_energy_multiplier = 3.5
	burst_vis.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	burst.material_override = burst_vis
	scene_root.add_child(burst)
	burst.global_position = pos + Vector3(0, 0.3, 0)
	p.get_tree().create_timer(0.7).timeout.connect(burst.queue_free)

	# Screen shake
	var camera: Camera3D = p.get_viewport().get_camera_3d()
	if camera and camera.has_method(&"shake"):
		camera.shake(0.3, 5.0)

	# Brief hitstop
	Engine.time_scale = 0.25
	p.get_tree().create_timer(0.04, true, false, true).timeout.connect(func() -> void:
		Engine.time_scale = 1.0
	)
