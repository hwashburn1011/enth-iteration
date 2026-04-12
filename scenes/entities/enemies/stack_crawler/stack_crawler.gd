class_name StackCrawler
extends "res://scenes/entities/enemies/enemy_base.gd"
## Slow tanky worm — very high HP, slow movement, heavy melee damage.

const XP_REWARD: int = 22


func _ready() -> void:
	enemy_type = &"stack_crawler"
	move_speed = 1.5  # Very slow
	attack_range = 2.5
	super._ready()
	health_component.max_health = 150.0
	health_component.current_health = 150.0
	stats_component.base_processing = 12.0
	stats_component.base_bandwidth = 1.0
	stats_component.base_memory = 0.0
	stats_component.base_integrity = 10.0


func _build_enemy_visual() -> void:
	for child: Node in model.get_children():
		child.queue_free()
	# Segmented worm body — 4 spheres in a row, getting smaller
	var sizes: Array[float] = [0.45, 0.38, 0.32, 0.25]
	var mat: StandardMaterial3D = StandardMaterial3D.new()
	mat.albedo_color = Color(0.3, 0.55, 0.2)
	mat.emission_enabled = true
	mat.emission = Color(0.2, 0.4, 0.1)
	mat.emission_energy_multiplier = 0.4
	mat.roughness = 0.8
	mat.metallic = 0.3
	for i: int in sizes.size():
		var seg: MeshInstance3D = MeshInstance3D.new()
		var seg_mesh: SphereMesh = SphereMesh.new()
		seg_mesh.radius = sizes[i]
		seg_mesh.height = sizes[i] * 2.0
		seg.mesh = seg_mesh
		seg.position = Vector3(0, sizes[i], i * 0.5)
		seg.material_override = mat
		model.add_child(seg)
	# Head plate — armored
	var plate: MeshInstance3D = MeshInstance3D.new()
	var plate_mesh: BoxMesh = BoxMesh.new()
	plate_mesh.size = Vector3(0.5, 0.15, 0.3)
	plate.mesh = plate_mesh
	plate.position = Vector3(0, 0.7, -0.15)
	var plate_mat: StandardMaterial3D = StandardMaterial3D.new()
	plate_mat.albedo_color = Color(0.4, 0.4, 0.35)
	plate_mat.metallic = 0.8
	plate_mat.roughness = 0.3
	plate.material_override = plate_mat
	model.add_child(plate)
	# Eyes
	var eye_mat: StandardMaterial3D = StandardMaterial3D.new()
	eye_mat.albedo_color = Color(0.9, 1.0, 0.3)
	eye_mat.emission_enabled = true
	eye_mat.emission = Color(0.8, 1.0, 0.2)
	eye_mat.emission_energy_multiplier = 1.5
	for side: float in [-0.12, 0.12]:
		var eye: MeshInstance3D = MeshInstance3D.new()
		var eye_mesh: SphereMesh = SphereMesh.new()
		eye_mesh.radius = 0.06
		eye_mesh.height = 0.12
		eye.mesh = eye_mesh
		eye.position = Vector3(side, 0.65, -0.35)
		eye.material_override = eye_mat
		model.add_child(eye)


func _on_died() -> void:
	var death_state: Node = state_machine.get_node_or_null("EnemyDeathState") as Node
	if death_state:
		state_machine.force_transition_to(death_state)
