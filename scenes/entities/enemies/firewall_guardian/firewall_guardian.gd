class_name FirewallGuardian
extends "res://scenes/entities/enemies/enemy_base.gd"
## Stationary shielded turret — fires projectiles at range, high armor, low mobility.

const XP_REWARD: int = 18


func _ready() -> void:
	enemy_type = &"firewall_guardian"
	move_speed = 0.0  # Stationary
	attack_range = 8.0
	super._ready()
	health_component.max_health = 80.0
	health_component.current_health = 80.0
	stats_component.base_processing = 8.0
	stats_component.base_bandwidth = 2.0
	stats_component.base_memory = 0.0
	stats_component.base_integrity = 8.0


func _build_enemy_visual() -> void:
	for child: Node in model.get_children():
		child.queue_free()
	# Shield base — wide, flat hexagonal look
	var base: MeshInstance3D = MeshInstance3D.new()
	var base_mesh: CylinderMesh = CylinderMesh.new()
	base_mesh.top_radius = 0.5
	base_mesh.bottom_radius = 0.6
	base_mesh.height = 0.8
	base_mesh.radial_segments = 6
	base.mesh = base_mesh
	base.position = Vector3(0, 0.4, 0)
	var mat: StandardMaterial3D = StandardMaterial3D.new()
	mat.albedo_color = Color(0.2, 0.5, 0.8)
	mat.emission_enabled = true
	mat.emission = Color(0.1, 0.3, 0.7)
	mat.emission_energy_multiplier = 0.6
	mat.roughness = 0.4
	mat.metallic = 0.7
	base.material_override = mat
	model.add_child(base)
	# Turret barrel
	var barrel: MeshInstance3D = MeshInstance3D.new()
	var barrel_mesh: CylinderMesh = CylinderMesh.new()
	barrel_mesh.top_radius = 0.08
	barrel_mesh.bottom_radius = 0.12
	barrel_mesh.height = 0.6
	barrel.mesh = barrel_mesh
	barrel.position = Vector3(0, 0.8, -0.3)
	barrel.rotation_degrees = Vector3(90, 0, 0)
	barrel.material_override = mat
	model.add_child(barrel)
	# Shield glow ring
	var ring: MeshInstance3D = MeshInstance3D.new()
	var ring_mesh: TorusMesh = TorusMesh.new()
	ring_mesh.inner_radius = 0.45
	ring_mesh.outer_radius = 0.55
	ring.mesh = ring_mesh
	ring.position = Vector3(0, 0.6, 0)
	var glow_mat: StandardMaterial3D = StandardMaterial3D.new()
	glow_mat.albedo_color = Color(0.3, 0.6, 1.0, 0.5)
	glow_mat.emission_enabled = true
	glow_mat.emission = Color(0.2, 0.5, 1.0)
	glow_mat.emission_energy_multiplier = 1.2
	glow_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	ring.material_override = glow_mat
	model.add_child(ring)
	# Eye lens
	var eye: MeshInstance3D = MeshInstance3D.new()
	var eye_mesh: SphereMesh = SphereMesh.new()
	eye_mesh.radius = 0.1
	eye_mesh.height = 0.2
	eye.mesh = eye_mesh
	eye.position = Vector3(0, 0.7, -0.45)
	var eye_mat: StandardMaterial3D = StandardMaterial3D.new()
	eye_mat.albedo_color = Color(1.0, 0.3, 0.1)
	eye_mat.emission_enabled = true
	eye_mat.emission = Color(1.0, 0.2, 0.05)
	eye_mat.emission_energy_multiplier = 2.0
	eye.material_override = eye_mat
	model.add_child(eye)


func _on_died() -> void:
	var death_state: Node = state_machine.get_node_or_null("EnemyDeathState") as Node
	if death_state:
		state_machine.force_transition_to(death_state)
