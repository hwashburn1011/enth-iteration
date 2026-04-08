class_name MemoryLeak
extends "res://scenes/entities/enemies/enemy_base.gd"
## Ranged enemy — fires slow projectiles that leave damaging pools.

const XP_REWARD: int = 15
const FLEE_DISTANCE: float = 4.0


func _ready() -> void:
	super._ready()
	health_component.max_health = 20.0
	health_component.current_health = 20.0
	stats_component.base_processing = 8.0
	stats_component.base_bandwidth = 2.0
	stats_component.base_memory = 0.0
	stats_component.base_integrity = 1.0


func _build_enemy_visual() -> void:
	for child: Node in model.get_children():
		child.queue_free()
	var glb: PackedScene = load("res://assets/models/enemies/enemy_memoryleak_v2.glb") as PackedScene
	if glb:
		var instance: Node3D = glb.instantiate() as Node3D
		model.add_child(instance)
		return
	# Fallback: Green ooze blob
	var body: MeshInstance3D = MeshInstance3D.new()
	var sphere: SphereMesh = SphereMesh.new()
	sphere.radius = 0.4
	sphere.height = 0.6  # Squashed = blobby
	sphere.radial_segments = 12
	sphere.rings = 6
	body.mesh = sphere
	body.position = Vector3(0, 0.3, 0)
	var mat: StandardMaterial3D = StandardMaterial3D.new()
	mat.albedo_color = Color(0.2, 0.8, 0.3, 0.85)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.emission_enabled = true
	mat.emission = Color(0.15, 0.6, 0.2)
	mat.emission_energy_multiplier = 0.8
	mat.roughness = 0.3
	body.material_override = mat
	model.add_child(body)
	# Smaller blob on top (head)
	var head: MeshInstance3D = MeshInstance3D.new()
	var head_mesh: SphereMesh = SphereMesh.new()
	head_mesh.radius = 0.25
	head_mesh.height = 0.35
	head_mesh.radial_segments = 10
	head_mesh.rings = 5
	head.mesh = head_mesh
	head.position = Vector3(0, 0.6, 0)
	head.material_override = mat
	model.add_child(head)
	# Drip particles (small spheres underneath)
	for i: int in 3:
		var drip: MeshInstance3D = MeshInstance3D.new()
		var drip_mesh: SphereMesh = SphereMesh.new()
		drip_mesh.radius = 0.06
		drip_mesh.height = 0.12
		drip.mesh = drip_mesh
		drip.position = Vector3(randf_range(-0.2, 0.2), 0.05, randf_range(-0.2, 0.2))
		drip.material_override = mat
		model.add_child(drip)


func _on_died() -> void:
	var death_state: Node = state_machine.get_node_or_null("EnemyDeathState") as Node
	if death_state:
		state_machine.force_transition_to(death_state)
