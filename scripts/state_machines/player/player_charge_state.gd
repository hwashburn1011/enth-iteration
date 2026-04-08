class_name PlayerChargeState
extends "res://scripts/state_machines/state.gd"
## Charges Energy Burst while right mouse button is held.

const MAX_CHARGE_TIME: float = 2.0
const MOVE_SPEED_MULTIPLIER: float = 0.5

var charge_time: float = 0.0
var _original_move_speed: float = 0.0
var _charge_particles: GPUParticles3D = null
var _charge_ring: MeshInstance3D = null


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
	var charge_multiplier: float = lerpf(0.5, 2.0, charge_time / MAX_CHARGE_TIME)
	var compute_cost: float = 15.0 * charge_multiplier

	if not p.compute_component.spend(compute_cost):
		# Fizzle — not enough compute
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
	var mesh: MeshInstance3D = p.model.get_child(0) as MeshInstance3D
	if mesh == null:
		return
	if intensity > 0.0:
		if _charge_material == null:
			_charge_material = StandardMaterial3D.new()
			_charge_material.emission_enabled = true
			_charge_material.emission = Color(0.4, 0.7, 1.0)
		_charge_material.emission_energy_multiplier = intensity * 3.0
		mesh.material_override = _charge_material
	else:
		mesh.material_override = null
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
	pmat.color = Color(0.3, 0.6, 1.0, 0.6)
	pmat.scale_min = 0.3
	pmat.scale_max = 0.8
	_charge_particles.process_material = pmat
	var mesh: BoxMesh = BoxMesh.new()
	mesh.size = Vector3(0.03, 0.03, 0.03)
	_charge_particles.draw_pass_1 = mesh
	var vis: StandardMaterial3D = StandardMaterial3D.new()
	vis.albedo_color = Color(0.4, 0.7, 1.0, 0.6)
	vis.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	vis.emission_enabled = true
	vis.emission = Color(0.3, 0.6, 0.95)
	vis.emission_energy_multiplier = 2.0
	vis.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_charge_particles.material_override = vis
	p.add_child(_charge_particles)

	# Ground AoE preview ring
	_charge_ring = MeshInstance3D.new()
	var ring_mesh: TorusMesh = TorusMesh.new()
	ring_mesh.inner_radius = 0.8
	ring_mesh.outer_radius = 0.9
	ring_mesh.rings = 12
	ring_mesh.ring_segments = 16
	_charge_ring.mesh = ring_mesh
	_charge_ring.position = Vector3(0, 0.03, 0)
	var ring_mat: StandardMaterial3D = StandardMaterial3D.new()
	ring_mat.albedo_color = Color(0.3, 0.5, 1.0, 0.0)
	ring_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	ring_mat.emission_enabled = true
	ring_mat.emission = Color(0.25, 0.45, 0.9)
	ring_mat.emission_energy_multiplier = 1.5
	ring_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_charge_ring.material_override = ring_mat
	p.add_child(_charge_ring)


func _update_charge_vfx(p: CharacterBody3D, charge_pct: float) -> void:
	# Scale particle speed and ring opacity with charge
	if _charge_particles and _charge_particles.process_material is ParticleProcessMaterial:
		var pmat: ParticleProcessMaterial = _charge_particles.process_material as ParticleProcessMaterial
		pmat.orbit_velocity_min = 1.5 + charge_pct * 3.0
		pmat.orbit_velocity_max = 2.5 + charge_pct * 4.0
		pmat.color = Color(0.3 + charge_pct * 0.2, 0.6 + charge_pct * 0.2, 1.0, 0.4 + charge_pct * 0.4)
	if _charge_ring and _charge_ring.material_override is StandardMaterial3D:
		var rmat: StandardMaterial3D = _charge_ring.material_override as StandardMaterial3D
		rmat.albedo_color.a = charge_pct * 0.35
		# Scale ring to show AoE size
		var ring_scale: float = 1.0 + charge_pct * 0.8
		_charge_ring.scale = Vector3(ring_scale, 1.0, ring_scale)


func _cleanup_charge_vfx() -> void:
	if _charge_particles and is_instance_valid(_charge_particles):
		_charge_particles.queue_free()
	_charge_particles = null
	if _charge_ring and is_instance_valid(_charge_ring):
		_charge_ring.queue_free()
	_charge_ring = null
