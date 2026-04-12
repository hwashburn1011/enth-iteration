class_name NullPointer
extends "res://scenes/entities/enemies/enemy_base.gd"
## Teleporter — appears behind the player, strikes, then blinks away.

const XP_REWARD: int = 15
const TELEPORT_COOLDOWN: float = 4.0
const TELEPORT_RANGE: float = 2.5

var _teleport_timer: float = 0.0


func _ready() -> void:
	enemy_type = &"null_pointer"
	move_speed = 3.5
	attack_range = 1.8
	super._ready()
	health_component.max_health = 40.0
	health_component.current_health = 40.0
	stats_component.base_processing = 10.0
	stats_component.base_bandwidth = 6.0
	stats_component.base_memory = 0.0
	stats_component.base_integrity = 3.0


func _process(delta: float) -> void:
	super._process(delta)
	if _teleport_timer > 0.0:
		_teleport_timer -= delta


func _build_enemy_visual() -> void:
	for child: Node in model.get_children():
		child.queue_free()
	# Ghostly void form — dark translucent with purple core
	var body: MeshInstance3D = MeshInstance3D.new()
	var sphere: SphereMesh = SphereMesh.new()
	sphere.radius = 0.35
	sphere.height = 0.7
	body.mesh = sphere
	body.position = Vector3(0, 0.5, 0)
	var mat: StandardMaterial3D = StandardMaterial3D.new()
	mat.albedo_color = Color(0.15, 0.05, 0.25, 0.6)
	mat.emission_enabled = true
	mat.emission = Color(0.5, 0.1, 0.8)
	mat.emission_energy_multiplier = 1.0
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.roughness = 0.2
	body.material_override = mat
	model.add_child(body)
	# Inner core — bright purple
	var core: MeshInstance3D = MeshInstance3D.new()
	var core_mesh: SphereMesh = SphereMesh.new()
	core_mesh.radius = 0.12
	core_mesh.height = 0.24
	core.mesh = core_mesh
	core.position = Vector3(0, 0.5, 0)
	var core_mat: StandardMaterial3D = StandardMaterial3D.new()
	core_mat.albedo_color = Color(0.8, 0.2, 1.0)
	core_mat.emission_enabled = true
	core_mat.emission = Color(0.7, 0.1, 1.0)
	core_mat.emission_energy_multiplier = 3.0
	core.material_override = core_mat
	model.add_child(core)
	# Glitch fragments orbiting
	for i: int in 3:
		var frag: MeshInstance3D = MeshInstance3D.new()
		var frag_mesh: BoxMesh = BoxMesh.new()
		frag_mesh.size = Vector3(0.08, 0.08, 0.08)
		frag.mesh = frag_mesh
		var angle: float = i * TAU / 3.0
		frag.position = Vector3(cos(angle) * 0.4, 0.5 + sin(angle) * 0.15, sin(angle) * 0.4)
		frag.material_override = core_mat
		model.add_child(frag)


func _on_died() -> void:
	var death_state: Node = state_machine.get_node_or_null("EnemyDeathState") as Node
	if death_state:
		state_machine.force_transition_to(death_state)
