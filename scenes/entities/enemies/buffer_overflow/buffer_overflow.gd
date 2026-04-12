class_name BufferOverflow
extends "res://scenes/entities/enemies/enemy_base.gd"
## Fast charger that explodes on death — high speed, low HP, AoE death burst.

const XP_REWARD: int = 12
const DEATH_EXPLOSION_RADIUS: float = 3.0
const DEATH_EXPLOSION_DAMAGE: float = 25.0


func _ready() -> void:
	enemy_type = &"buffer_overflow"
	move_speed = 6.0  # Very fast
	attack_range = 1.5
	super._ready()
	health_component.max_health = 20.0
	health_component.current_health = 20.0
	stats_component.base_processing = 6.0
	stats_component.base_bandwidth = 8.0
	stats_component.base_memory = 0.0
	stats_component.base_integrity = 1.0


func _build_enemy_visual() -> void:
	for child: Node in model.get_children():
		child.queue_free()
	# Unstable sphere — pulsing, glowing, volatile
	var body: MeshInstance3D = MeshInstance3D.new()
	var sphere: SphereMesh = SphereMesh.new()
	sphere.radius = 0.3
	sphere.height = 0.6
	body.mesh = sphere
	body.position = Vector3(0, 0.3, 0)
	var mat: StandardMaterial3D = StandardMaterial3D.new()
	mat.albedo_color = Color(1.0, 0.6, 0.1)
	mat.emission_enabled = true
	mat.emission = Color(1.0, 0.4, 0.0)
	mat.emission_energy_multiplier = 1.5
	mat.roughness = 0.3
	body.material_override = mat
	model.add_child(body)
	# Crackling energy lines — small spike protrusions
	for i: int in 6:
		var spike: MeshInstance3D = MeshInstance3D.new()
		var spike_mesh: CylinderMesh = CylinderMesh.new()
		spike_mesh.top_radius = 0.0
		spike_mesh.bottom_radius = 0.04
		spike_mesh.height = 0.2
		spike.mesh = spike_mesh
		var angle: float = i * TAU / 6.0
		spike.position = Vector3(cos(angle) * 0.25, 0.3, sin(angle) * 0.25)
		spike.rotation = Vector3(sin(angle) * 0.8, 0, -cos(angle) * 0.8)
		var spark_mat: StandardMaterial3D = StandardMaterial3D.new()
		spark_mat.albedo_color = Color(1.0, 0.9, 0.3)
		spark_mat.emission_enabled = true
		spark_mat.emission = Color(1.0, 0.8, 0.2)
		spark_mat.emission_energy_multiplier = 2.0
		spike.material_override = spark_mat
		model.add_child(spike)


func _on_died() -> void:
	# Explode on death — deal AoE damage to nearby players
	_death_explosion()
	var death_state: Node = state_machine.get_node_or_null("EnemyDeathState") as Node
	if death_state:
		state_machine.force_transition_to(death_state)


func _death_explosion() -> void:
	var players: Array[Node] = get_tree().get_nodes_in_group(&"player")
	for p: Node in players:
		if p is Node3D:
			var dist: float = global_position.distance_to((p as Node3D).global_position)
			if dist <= DEATH_EXPLOSION_RADIUS:
				var health: Node = p.get_node_or_null("HealthComponent")
				if health and health.has_method(&"take_damage"):
					health.take_damage(DEATH_EXPLOSION_DAMAGE * damage_multiplier)
	# VFX burst
	if is_inside_tree():
		VFXFactory.spawn_level_up_effect(global_position, get_tree().current_scene)
