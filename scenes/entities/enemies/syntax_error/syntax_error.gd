class_name SyntaxError
extends "res://scenes/entities/enemies/enemy_base.gd"
## Spawns glitch clones when hit — medium stats, creates copies on damage.

const XP_REWARD: int = 14
const CLONE_CHANCE: float = 0.3
const MAX_CLONES: int = 2

var _clones_spawned: int = 0


func _ready() -> void:
	enemy_type = &"syntax_error"
	move_speed = 3.0
	attack_range = 2.0
	super._ready()
	health_component.max_health = 45.0
	health_component.current_health = 45.0
	stats_component.base_processing = 7.0
	stats_component.base_bandwidth = 5.0
	stats_component.base_memory = 0.0
	stats_component.base_integrity = 4.0
	# Connect to damage signal to spawn clones
	if health_component.has_signal(&"health_changed"):
		if not health_component.health_changed.is_connected(_on_health_changed):
			health_component.health_changed.connect(_on_health_changed)


func reset() -> void:
	_clones_spawned = 0
	super.reset()


func _on_health_changed(_new_health: float, _old_health: float) -> void:
	if _new_health < _old_health and _clones_spawned < MAX_CLONES:
		if randf() < CLONE_CHANCE:
			_spawn_glitch_clone()


func _spawn_glitch_clone() -> void:
	_clones_spawned += 1
	# Spawn a glitch_bug as a "clone" — simpler than true self-replication
	if not is_inside_tree():
		return
	var pool: Node = get_node_or_null("/root/EnemyPool")
	if pool == null:
		return
	if not pool.has_method(&"get_enemy"):
		return
	var clone: CharacterBody3D = pool.get_enemy("glitch_bug") as CharacterBody3D
	if clone == null:
		return
	# Place clone near this enemy
	var offset: Vector3 = Vector3(randf_range(-2.0, 2.0), 0, randf_range(-2.0, 2.0))
	clone.global_position = global_position + offset
	clone.spawn_position = clone.global_position
	# Flash effect
	if is_inside_tree():
		VFXFactory.spawn_level_up_effect(clone.global_position, get_tree().current_scene)


func _build_enemy_visual() -> void:
	for child: Node in model.get_children():
		child.queue_free()
	# Glitchy polygon — irregular shape with flickering edges
	var body: MeshInstance3D = MeshInstance3D.new()
	var box: BoxMesh = BoxMesh.new()
	box.size = Vector3(0.5, 0.6, 0.5)
	body.mesh = box
	body.position = Vector3(0, 0.3, 0)
	body.rotation_degrees = Vector3(0, 45, 10)
	var mat: StandardMaterial3D = StandardMaterial3D.new()
	mat.albedo_color = Color(0.9, 0.2, 0.6)
	mat.emission_enabled = true
	mat.emission = Color(0.8, 0.1, 0.5)
	mat.emission_energy_multiplier = 0.8
	mat.roughness = 0.5
	body.material_override = mat
	model.add_child(body)
	# Offset duplicate — "glitch" double
	var ghost: MeshInstance3D = MeshInstance3D.new()
	var ghost_mesh: BoxMesh = BoxMesh.new()
	ghost_mesh.size = Vector3(0.4, 0.5, 0.4)
	ghost.mesh = ghost_mesh
	ghost.position = Vector3(0.1, 0.35, 0.1)
	ghost.rotation_degrees = Vector3(5, 50, -5)
	var ghost_mat: StandardMaterial3D = StandardMaterial3D.new()
	ghost_mat.albedo_color = Color(0.9, 0.2, 0.6, 0.3)
	ghost_mat.emission_enabled = true
	ghost_mat.emission = Color(0.8, 0.1, 0.5)
	ghost_mat.emission_energy_multiplier = 0.5
	ghost_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	ghost.material_override = ghost_mat
	model.add_child(ghost)
	# Error symbol — exclamation mark
	var excl: MeshInstance3D = MeshInstance3D.new()
	var excl_mesh: CylinderMesh = CylinderMesh.new()
	excl_mesh.top_radius = 0.03
	excl_mesh.bottom_radius = 0.05
	excl_mesh.height = 0.2
	excl.mesh = excl_mesh
	excl.position = Vector3(0, 0.75, 0)
	var err_mat: StandardMaterial3D = StandardMaterial3D.new()
	err_mat.albedo_color = Color(1.0, 1.0, 0.2)
	err_mat.emission_enabled = true
	err_mat.emission = Color(1.0, 0.9, 0.1)
	err_mat.emission_energy_multiplier = 2.0
	excl.material_override = err_mat
	model.add_child(excl)


func _on_died() -> void:
	var death_state: Node = state_machine.get_node_or_null("EnemyDeathState") as Node
	if death_state:
		state_machine.force_transition_to(death_state)
