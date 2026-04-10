class_name GlitchBug
extends "res://scenes/entities/enemies/enemy_base.gd"
## Fast melee enemy — teaches basic combat. Small, red, aggressive.

const XP_REWARD: int = 10


func _ready() -> void:
	super._ready()
	# Override base stats
	health_component.max_health = 30.0
	health_component.current_health = 30.0
	stats_component.base_processing = 5.0
	stats_component.base_bandwidth = 4.0
	stats_component.base_memory = 0.0
	stats_component.base_integrity = 2.0


func _build_enemy_visual() -> void:
	# R5 fix: skip if .tscn already has a GlitchbugR3 child (R3-16)
	for child: Node in model.get_children():
		if child.name.begins_with("GlitchbugR3"):
			return
	for child: Node in model.get_children():
		child.queue_free()
	var glb: PackedScene = load("res://assets/models/enemies/glitchbug_r3.glb") as PackedScene
	if glb:
		var instance: Node3D = glb.instantiate() as Node3D
		instance.scale = Vector3(0.4, 0.4, 0.4)
		model.add_child(instance)
		return
	# Fallback: Red spiky body — small aggressive creature
	var body: MeshInstance3D = MeshInstance3D.new()
	var sphere: SphereMesh = SphereMesh.new()
	sphere.radius = 0.35
	sphere.height = 0.7
	sphere.radial_segments = 6  # Low poly = spiky look
	sphere.rings = 3
	body.mesh = sphere
	body.position = Vector3(0, 0.35, 0)
	var mat: StandardMaterial3D = StandardMaterial3D.new()
	mat.albedo_color = Color(0.85, 0.15, 0.1)
	mat.emission_enabled = true
	mat.emission = Color(0.7, 0.1, 0.05)
	mat.emission_energy_multiplier = 0.5
	mat.roughness = 0.7
	body.material_override = mat
	model.add_child(body)
	# Spiky protrusions
	for i: int in 4:
		var spike: MeshInstance3D = MeshInstance3D.new()
		var spike_mesh: CylinderMesh = CylinderMesh.new()
		spike_mesh.top_radius = 0.0
		spike_mesh.bottom_radius = 0.08
		spike_mesh.height = 0.25
		spike.mesh = spike_mesh
		var angle: float = i * TAU / 4.0
		spike.position = Vector3(cos(angle) * 0.3, 0.4, sin(angle) * 0.3)
		spike.rotation = Vector3(sin(angle) * 0.5, 0, -cos(angle) * 0.5)
		spike.material_override = mat
		model.add_child(spike)
	# Eyes (angry red)
	var eye_mat: StandardMaterial3D = StandardMaterial3D.new()
	eye_mat.albedo_color = Color(1.0, 0.9, 0.2)
	eye_mat.emission_enabled = true
	eye_mat.emission = Color(1.0, 0.8, 0.1)
	eye_mat.emission_energy_multiplier = 1.5
	for side: float in [-0.1, 0.1]:
		var eye: MeshInstance3D = MeshInstance3D.new()
		var eye_mesh: SphereMesh = SphereMesh.new()
		eye_mesh.radius = 0.05
		eye_mesh.height = 0.1
		eye.mesh = eye_mesh
		eye.position = Vector3(side, 0.42, -0.28)
		eye.material_override = eye_mat
		model.add_child(eye)


func _on_died() -> void:
	var death_state: Node = state_machine.get_node_or_null("EnemyDeathState") as Node
	if death_state:
		state_machine.force_transition_to(death_state)
