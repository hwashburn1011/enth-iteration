class_name RogueProcess
extends "res://scenes/entities/enemies/enemy_base.gd"
## Fast aggressive enemy — two attack patterns, enrages at low health.

const XP_REWARD: int = 20
const ENRAGE_THRESHOLD: float = 0.3
const ENRAGE_SPEED_MULT: float = 1.5
const ENRAGE_CD_MULT: float = 0.7

var is_enraged: bool = false
var _base_move_speed: float = 6.0
## Snapshot of each mesh's polish material captured BEFORE the first
## enrage so reset() can restore them on pool re-activation. Wiping
## material_override blindly would also clear the
## _polish_r3_enemy() result from _build_enemy_visual.
var _pre_enrage_materials: Dictionary = {}


func _ready() -> void:
	enemy_type = &"rogue_process"
	super._ready()
	_base_move_speed = move_speed
	health_component.max_health = 25.0
	health_component.current_health = 25.0
	stats_component.base_processing = 7.0
	stats_component.base_bandwidth = 8.0
	stats_component.base_memory = 0.0
	stats_component.base_integrity = 3.0
	health_component.health_changed.connect(_on_health_changed)


func _build_enemy_visual() -> void:
	# R5 fix: skip if .tscn already has a RogueProcessR3 child (R3-19),
	# but still apply orb-polish (cold blue + white eyes).
	for child: Node in model.get_children():
		if child.name.begins_with("RogueProcessR3"):
			_polish_r3_enemy(child as Node3D, Color(0.2, 0.32, 0.85), Color(0.95, 0.95, 1.0))
			return
	for child: Node in model.get_children():
		child.queue_free()
	var glb: PackedScene = load("res://assets/models/enemies/rogueprocess_r3.glb") as PackedScene
	if glb:
		var instance: Node3D = glb.instantiate() as Node3D
		instance.scale = Vector3(0.5, 0.5, 0.5)
		model.add_child(instance)
		_polish_r3_enemy(instance, Color(0.2, 0.32, 0.85), Color(0.95, 0.95, 1.0))
		return
	# Fallback: Angular blue geometric
	var body: MeshInstance3D = MeshInstance3D.new()
	var box: BoxMesh = BoxMesh.new()
	box.size = Vector3(0.6, 0.8, 0.6)
	body.mesh = box
	body.position = Vector3(0, 0.5, 0)
	body.rotation = Vector3(0, PI / 4.0, 0)  # Rotated 45 degrees = diamond
	var mat: StandardMaterial3D = StandardMaterial3D.new()
	mat.albedo_color = Color(0.15, 0.25, 0.85)
	mat.emission_enabled = true
	mat.emission = Color(0.1, 0.2, 0.7)
	mat.emission_energy_multiplier = 0.6
	mat.roughness = 0.5
	body.material_override = mat
	model.add_child(body)
	# Top spike
	var spike: MeshInstance3D = MeshInstance3D.new()
	var spike_mesh: CylinderMesh = CylinderMesh.new()
	spike_mesh.top_radius = 0.0
	spike_mesh.bottom_radius = 0.2
	spike_mesh.height = 0.4
	spike.mesh = spike_mesh
	spike.position = Vector3(0, 1.0, 0)
	spike.material_override = mat
	model.add_child(spike)
	# Shoulder blades
	for side: float in [-0.4, 0.4]:
		var blade: MeshInstance3D = MeshInstance3D.new()
		var blade_mesh: BoxMesh = BoxMesh.new()
		blade_mesh.size = Vector3(0.15, 0.5, 0.3)
		blade.mesh = blade_mesh
		blade.position = Vector3(side, 0.6, 0)
		blade.material_override = mat
		model.add_child(blade)
	# Eyes (cold white)
	var eye_mat: StandardMaterial3D = StandardMaterial3D.new()
	eye_mat.albedo_color = Color(0.9, 0.9, 1.0)
	eye_mat.emission_enabled = true
	eye_mat.emission = Color(0.8, 0.85, 1.0)
	eye_mat.emission_energy_multiplier = 1.8
	for side: float in [-0.12, 0.12]:
		var eye: MeshInstance3D = MeshInstance3D.new()
		var eye_mesh: SphereMesh = SphereMesh.new()
		eye_mesh.radius = 0.05
		eye_mesh.height = 0.1
		eye.mesh = eye_mesh
		eye.position = Vector3(side, 0.6, -0.31)
		eye.material_override = eye_mat
		model.add_child(eye)


func _on_health_changed(current: float, maximum: float) -> void:
	if not is_enraged and current / maximum <= ENRAGE_THRESHOLD and current > 0.0:
		is_enraged = true
		move_speed = _base_move_speed * ENRAGE_SPEED_MULT
		# Visual indicator — blue glow intensifies on every mesh in the model.
		# Snapshot the existing polish material first so reset() can put it
		# back when the enemy returns to the pool.
		var mat: StandardMaterial3D = StandardMaterial3D.new()
		mat.albedo_color = Color(0.3, 0.3, 1.0)
		mat.emission_enabled = true
		mat.emission = Color(0.2, 0.2, 1.0)
		mat.emission_energy_multiplier = 2.0
		_pre_enrage_materials.clear()
		for mesh: MeshInstance3D in get_mesh_instances():
			_pre_enrage_materials[mesh] = mesh.material_override
			mesh.material_override = mat


func _on_died() -> void:
	var death_state: Node = state_machine.get_node_or_null("EnemyDeathState") as Node
	if death_state:
		state_machine.force_transition_to(death_state)


func reset() -> void:
	## Pool re-activation hook. is_enraged + the enrage speed boost +
	## the blue glow material override all persist across pool reuse.
	## Without this override, the second rogue process you fight is
	## already enraged (with the speed bonus) but the trigger never
	## re-fires because is_enraged is already true, AND the blue glow
	## material override is permanently stuck on every mesh in the
	## model. Same pattern T32 used for the boss.
	super.reset()
	if is_enraged:
		# Restore the polish materials snapshotted before enrage so the
		# cold blue + procedural eyes from _build_enemy_visual come back
		# instead of getting wiped to the default GLB material.
		for mesh: Variant in _pre_enrage_materials:
			if is_instance_valid(mesh):
				(mesh as MeshInstance3D).material_override = _pre_enrage_materials[mesh]
		_pre_enrage_materials.clear()
	is_enraged = false
	move_speed = _base_move_speed
