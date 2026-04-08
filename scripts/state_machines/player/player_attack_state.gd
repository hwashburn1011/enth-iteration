class_name PlayerAttackState
extends "res://scripts/state_machines/state.gd"
## Handles both Data Pulse (basic) and Energy Burst (charged) attacks.

const DATA_PULSE_ACTIVE_START: float = 0.1
const DATA_PULSE_ACTIVE_END: float = 0.3
const DATA_PULSE_DURATION: float = 0.4
const ENERGY_BURST_ACTIVE_START: float = 0.05
const ENERGY_BURST_ACTIVE_END: float = 0.25
const ENERGY_BURST_DURATION: float = 0.5

var _timer: float = 0.0
var _hitbox_enabled: bool = false
var _has_hit: Dictionary = {}
var _is_energy_burst: bool = false
var _burst_damage: float = 0.0
var _active_start: float = 0.0
var _active_end: float = 0.0
var _duration: float = 0.0


func enter() -> void:
	var p = player
	_timer = 0.0
	_hitbox_enabled = false
	_has_hit.clear()

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
		# Cooldown 1.5s for energy burst
		p.can_attack = false
		p.attack_cooldown_timer.start(1.5)
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
		p.attack_cooldown_timer.start(0.5)
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
	var p = player
	_timer += delta

	if _timer >= _active_start and _timer < _active_end:
		if not _hitbox_enabled:
			# Set metadata on the hitbox so HurtboxComponent can read damage values
			if _is_energy_burst:
				p.hitbox_component.set_meta(&"base_damage", _burst_damage)
				p.hitbox_component.set_meta(&"damage_type", &"energy")
			else:
				p.hitbox_component.set_meta(&"base_damage", 5.0 + p.stats_component.get_stat("processing") * 1.5)
				p.hitbox_component.set_meta(&"damage_type", &"data")
			_set_hitbox_active(p, true)
			_hitbox_enabled = true
			_spawn_attack_arc(p)
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
	var p = player
	_set_hitbox_active(p, false)
	_hitbox_enabled = false
	# Restore default hitbox size
	_set_hitbox_size(p, Vector3(1.5, 1.0, 1.5))


func _poll_hitbox_overlaps(p: CharacterBody3D) -> void:
	var hitbox: Node = p.hitbox_component
	if not hitbox.is_active:
		return
	for area: Area3D in hitbox.get_overlapping_areas():
		if area == p.hurtbox_component:
			continue  # Skip self
		if not area.has_method(&"activate"):
			continue  # Not a hurtbox
		if hitbox.has_hit(area.get_parent()):
			continue  # Already hit this target
		# Trigger the hurtbox's damage processing manually
		area._on_area_entered(hitbox)


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
	var arc: MeshInstance3D = MeshInstance3D.new()
	var torus: TorusMesh = TorusMesh.new()
	torus.inner_radius = 0.6
	torus.outer_radius = 0.9
	torus.rings = 8
	torus.ring_segments = 12
	arc.mesh = torus
	arc.position = p.global_position + p.facing_direction * 0.5 + Vector3(0, 0.5, 0)
	arc.rotation.x = PI / 2.0  # Lay flat
	arc.rotation.y = atan2(p.facing_direction.x, p.facing_direction.z)

	var mat: StandardMaterial3D = StandardMaterial3D.new()
	if _is_energy_burst:
		mat.albedo_color = Color(0.3, 0.5, 1.0, 0.6)
		mat.emission_enabled = true
		mat.emission = Color(0.25, 0.45, 0.9)
		mat.emission_energy_multiplier = 2.0
		arc.scale = Vector3(1.5, 1.5, 0.3)
	else:
		mat.albedo_color = Color(0.2, 0.8, 0.8, 0.5)
		mat.emission_enabled = true
		mat.emission = Color(0.15, 0.6, 0.6)
		mat.emission_energy_multiplier = 1.5
		arc.scale = Vector3(1.0, 1.0, 0.2)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	arc.material_override = mat

	p.get_tree().current_scene.add_child(arc)
	var tween: Tween = arc.create_tween()
	tween.tween_property(arc, "scale", arc.scale * 1.5, 0.15)
	tween.parallel().tween_property(mat, "albedo_color:a", 0.0, 0.2)
	tween.tween_callback(arc.queue_free)
