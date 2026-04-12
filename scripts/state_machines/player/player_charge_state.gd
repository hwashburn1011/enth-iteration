class_name PlayerChargeState
extends "res://scripts/state_machines/state.gd"
## Charges Energy Burst while right mouse button is held.

const MAX_CHARGE_TIME: float = 2.0
const MOVE_SPEED_MULTIPLIER: float = 0.5
## Post-V1 C21: max charge delivers 3x damage (was 2x).
const MAX_CHARGE_MULTIPLIER: float = 3.0

var charge_time: float = 0.0
var _original_move_speed: float = 0.0
var _charge_particles: GPUParticles3D = null
var _charge_ring: MeshInstance3D = null
## Pre-charge material snapshot per mesh so the emission glow doesn't
## permanently wipe the polish materials applied by player.gd. Same
## pattern T39/T42 used elsewhere.
var _pre_charge_materials: Dictionary = {}


func enter() -> void:
	var p = player
	charge_time = 0.0
	_original_move_speed = p.move_speed
	p.move_speed *= MOVE_SPEED_MULTIPLIER
	_set_emission(p, 0.0)
	_create_charge_vfx(p)

	if p.animation_player.has_animation(&"charge"):
		p.animation_player.play(&"charge")


func exit() -> void:
	var p = player
	p.move_speed = _original_move_speed
	_set_emission(p, 0.0)
	_cleanup_charge_vfx()


func handle_input(event: InputEvent) -> void:
	if event.is_action_released(&"attack_secondary"):
		_release_burst()


func physics_update(delta: float) -> void:
	var p = player
	charge_time = minf(charge_time + delta, MAX_CHARGE_TIME)

	# Visual charge indicator — emission intensity + VFX
	var charge_pct: float = charge_time / MAX_CHARGE_TIME
	_set_emission(p, charge_pct)
	_update_charge_vfx(p, charge_pct)
	# Subtle screen shake when fully charged (last 20% of charge time)
	if charge_pct >= 0.8:
		var camera: Camera3D = p.get_viewport().get_camera_3d()
		if camera and camera.has_method(&"shake"):
			camera.shake(0.02 + (charge_pct - 0.8) * 0.1, 10.0)

	# Allow reduced-speed movement while charging
	var input_vector: Vector2 = Input.get_vector(
		&"move_left", &"move_right", &"move_forward", &"move_back"
	)
	if input_vector.length() > 0.0:
		var camera: Camera3D = p.get_viewport().get_camera_3d()
		var camera_basis: Basis = Basis(Vector3.UP, camera.global_rotation.y) if camera else Basis.IDENTITY
		var direction: Vector3 = camera_basis * Vector3(input_vector.x, 0.0, input_vector.y)
		direction = direction.normalized()
		p.velocity = direction * p.move_speed
	else:
		p.velocity = p.velocity.lerp(Vector3.ZERO, p.friction)
	p.move_and_slide()


func _release_burst() -> void:
	var p = player
	var charge_multiplier: float = lerpf(0.5, MAX_CHARGE_MULTIPLIER, charge_time / MAX_CHARGE_TIME)
	var compute_cost: float = 15.0 * charge_multiplier

	if not p.compute_component.spend(compute_cost):
		# Fizzle — not enough compute
		_spawn_fizzle_vfx(p)
		p.move_speed = _original_move_speed
		_set_emission(p, 0.0)
		var input_vector: Vector2 = Input.get_vector(
			&"move_left", &"move_right", &"move_forward", &"move_back"
		)
		if input_vector.length() > 0.0:
			state_machine.transition_to(state_machine.get_node("WalkState") as Node)
		else:
			state_machine.transition_to(state_machine.get_node("IdleState") as Node)
		return

	# Store charge data on player for AttackState to use
	p.set_meta(&"energy_burst_charge_multiplier", charge_multiplier)
	p.set_meta(&"energy_burst_damage", (10.0 + p.stats_component.get_stat("processing") * 3.0) * charge_multiplier)

	# Transition to AttackState for the burst release
	var attack_state: Node = state_machine.get_node("AttackState") as Node
	p.set_meta(&"attack_type", &"energy_burst")
	state_machine.transition_to(attack_state)


var _charge_material: StandardMaterial3D = null

func _set_emission(p: CharacterBody3D, intensity: float) -> void:
	var meshes: Array[MeshInstance3D] = p.get_mesh_instances()
	if intensity > 0.0:
		# Snapshot pre-charge materials on the first transition (intensity > 0
		# arrives every physics frame while charging; only snapshot on the
		# very first one when the dict is still empty).
		if _pre_charge_materials.is_empty():
			for mesh: MeshInstance3D in meshes:
				_pre_charge_materials[mesh] = mesh.material_override
		if _charge_material == null:
			_charge_material = StandardMaterial3D.new()
			_charge_material.emission_enabled = true
			_charge_material.emission = Color(0.7, 0.25, 0.85)
		_charge_material.emission_energy_multiplier = intensity * 3.0
		for mesh: MeshInstance3D in meshes:
			mesh.material_override = _charge_material
	else:
		for mesh: MeshInstance3D in meshes:
			if _pre_charge_materials.has(mesh):
				mesh.material_override = _pre_charge_materials[mesh]
		_pre_charge_materials.clear()
		_charge_material = null


func _create_charge_vfx(p: CharacterBody3D) -> void:
	if not p.is_inside_tree():
		return
	# Orbiting charge particles
	_charge_particles = GPUParticles3D.new()
	_charge_particles.amount = 16
	_charge_particles.lifetime = 0.8
	_charge_particles.position = Vector3(0, 0.5, 0)
	var pmat: ParticleProcessMaterial = ParticleProcessMaterial.new()
	pmat.direction = Vector3(0, 1, 0)
	pmat.spread = 60.0
	pmat.initial_velocity_min = 0.5
	pmat.initial_velocity_max = 1.0
	pmat.gravity = Vector3(0, 0.5, 0)
	pmat.orbit_velocity_min = 1.5
	pmat.orbit_velocity_max = 2.5
	pmat.color = Color(0.7, 0.25, 0.85, 0.6)
	pmat.scale_min = 0.3
	pmat.scale_max = 0.8
	_charge_particles.process_material = pmat
	var mesh: BoxMesh = BoxMesh.new()
	mesh.size = Vector3(0.03, 0.03, 0.03)
	_charge_particles.draw_pass_1 = mesh
	var vis: StandardMaterial3D = StandardMaterial3D.new()
	vis.albedo_color = Color(0.75, 0.3, 0.9, 0.6)
	vis.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	vis.emission_enabled = true
	vis.emission = Color(0.65, 0.2, 0.85)
	vis.emission_energy_multiplier = 2.0
	vis.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_charge_particles.material_override = vis
	p.add_child(_charge_particles)

	# Ground AoE preview ring
	_charge_ring = MeshInstance3D.new()
	var ring_mesh: TorusMesh = TorusMesh.new()
	ring_mesh.inner_radius = 1.2
	ring_mesh.outer_radius = 1.35
	ring_mesh.rings = 12
	ring_mesh.ring_segments = 16
	_charge_ring.mesh = ring_mesh
	_charge_ring.position = Vector3(0, 0.03, 0)
	var ring_mat: StandardMaterial3D = StandardMaterial3D.new()
	ring_mat.albedo_color = Color(0.7, 0.2, 0.85, 0.0)
	ring_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	ring_mat.emission_enabled = true
	ring_mat.emission = Color(0.65, 0.15, 0.8)
	ring_mat.emission_energy_multiplier = 1.5
	ring_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_charge_ring.material_override = ring_mat
	p.add_child(_charge_ring)


func _update_charge_vfx(_p: CharacterBody3D, charge_pct: float) -> void:
	# Scale particle speed and ring opacity with charge
	if _charge_particles and _charge_particles.process_material is ParticleProcessMaterial:
		var pmat: ParticleProcessMaterial = _charge_particles.process_material as ParticleProcessMaterial
		pmat.orbit_velocity_min = 1.5 + charge_pct * 3.0
		pmat.orbit_velocity_max = 2.5 + charge_pct * 4.0
		# At full charge, shift toward bright white-cyan
		if charge_pct >= 0.95:
			pmat.color = Color(0.95, 0.85, 1.0, 0.95)
		else:
			pmat.color = Color(0.7 + charge_pct * 0.15, 0.25 - charge_pct * 0.1, 0.85 + charge_pct * 0.1, 0.4 + charge_pct * 0.4)
	# Visible material on particles too (drawn pass material)
	if _charge_particles and _charge_particles.material_override is StandardMaterial3D:
		var vis_mat: StandardMaterial3D = _charge_particles.material_override as StandardMaterial3D
		if charge_pct >= 0.95:
			vis_mat.emission_energy_multiplier = 4.5
			vis_mat.emission = Color(0.95, 0.85, 1.0)
		else:
			vis_mat.emission_energy_multiplier = 2.0 + charge_pct * 1.5
			vis_mat.emission = Color(0.65, 0.2, 0.85)
	if _charge_ring and _charge_ring.material_override is StandardMaterial3D:
		var rmat: StandardMaterial3D = _charge_ring.material_override as StandardMaterial3D
		rmat.albedo_color.a = charge_pct * 0.35
		# Scale ring to show AoE size
		var ring_scale: float = 1.0 + charge_pct * 0.8
		_charge_ring.scale = Vector3(ring_scale, 1.0, ring_scale)


func _spawn_fizzle_vfx(p: CharacterBody3D) -> void:
	## Brief gray "no compute" puff when burst fizzles
	if not p.is_inside_tree():
		return
	var label: Label3D = Label3D.new()
	label.text = "NO COMPUTE"
	label.font_size = 18
	label.modulate = Color(0.6, 0.6, 0.6)
	label.outline_modulate = Color(0, 0, 0, 0.6)
	label.outline_size = 3
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.position = p.global_position + Vector3(0, 1.6, 0)
	p.get_tree().current_scene.add_child(label)
	var tween: Tween = label.create_tween()
	tween.tween_property(label, "position:y", label.position.y + 0.8, 0.7).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(label, "modulate:a", 0.0, 0.7)
	tween.tween_callback(label.queue_free)


func _cleanup_charge_vfx() -> void:
	if _charge_particles and is_instance_valid(_charge_particles):
		_charge_particles.queue_free()
	_charge_particles = null
	if _charge_ring and is_instance_valid(_charge_ring):
		_charge_ring.queue_free()
	_charge_ring = null
