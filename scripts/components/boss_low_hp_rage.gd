class_name BossLowHpRage
extends Node

## Drives the "low HP rage" visual escalation for the Compiler boss
## (Epic 07 task 38). As the boss's HP drops below the rage threshold,
## the boss's body shader uniform low_hp_rage ramps from 0.0 to 1.0,
## boosting all emission strengths and triggering particle density
## escalation.
##
## Behavior:
##   1) Listens for HealthComponent damage_taken / health_changed
##   2) Computes hp_pct = current_hp / max_hp
##   3) When hp_pct < rage_threshold (default 0.25), starts ramping
##      low_hp_rage from 0 → 1 over the remaining HP range
##   4) Pushes the value into every Compiler body mesh's ShaderMaterial
##      uniform "low_hp_rage" (the compiler_phase_transition shader
##      uses this to boost emission by 1.5x)
##   5) Also boosts the rage particle emission count + spawn rate via
##      a child GPUParticles3D's amount property
##
## Required scene shape:
##   AnyBossRoot (Node3D)
##     BossLowHpRage (Node + this script)
##     HealthComponent (with health_changed(current, max) signal)
##     Body MeshInstance3Ds with the compiler_phase_transition shader
##
## Hookup from a boss factory:
##   var rage: BossLowHpRage = BossLowHpRage.new()
##   rage.body_mesh_paths = [NodePath("Body"), NodePath("Arms/Arm1"), ...]
##   boss.add_child(rage)

@export var rage_threshold: float = 0.25
@export var body_mesh_paths: Array[NodePath] = []
@export var rage_particles_path: NodePath
@export var rage_base_amount: int = 30
@export var rage_max_amount: int = 200
@export var health_component_path: NodePath

var _hc: Node
var _current_rage: float = 0.0
var _materials: Array[ShaderMaterial] = []
var _rage_particles: GPUParticles3D


func _ready() -> void:
	_resolve_health_component()
	_collect_materials()
	_resolve_particles()


func _resolve_health_component() -> void:
	_hc = get_node_or_null(health_component_path)
	if _hc == null:
		var parent: Node = get_parent()
		if parent != null:
			for child: Node in parent.get_children():
				if child.has_signal("health_changed"):
					_hc = child
					break
	if _hc != null and _hc.has_signal("health_changed"):
		_hc.health_changed.connect(_on_health_changed)


func _collect_materials() -> void:
	for path: NodePath in body_mesh_paths:
		var mesh: MeshInstance3D = get_node_or_null(path) as MeshInstance3D
		if mesh == null:
			continue
		var mat: Material = mesh.material_override
		if mat == null and mesh.get_surface_override_material_count() > 0:
			mat = mesh.get_surface_override_material(0)
		if mat is ShaderMaterial:
			_materials.append(mat as ShaderMaterial)


func _resolve_particles() -> void:
	_rage_particles = get_node_or_null(rage_particles_path) as GPUParticles3D


func _on_health_changed(current: float, maximum: float) -> void:
	if maximum <= 0.0:
		return
	var hp_pct: float = current / maximum
	var rage: float = 0.0
	if hp_pct < rage_threshold:
		rage = 1.0 - (hp_pct / rage_threshold)
		rage = clamp(rage, 0.0, 1.0)
	_set_rage(rage)


func _set_rage(value: float) -> void:
	if absf(value - _current_rage) < 0.005:
		return
	_current_rage = value
	for sm: ShaderMaterial in _materials:
		sm.set_shader_parameter("low_hp_rage", value)
	if _rage_particles != null:
		_rage_particles.amount = int(lerp(float(rage_base_amount), float(rage_max_amount), value))
		_rage_particles.emitting = value > 0.05
