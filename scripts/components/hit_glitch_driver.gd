class_name HitGlitchDriver
extends Node

## Drives the `enemy_hit_glitch.gdshader` `hit_pulse` parameter on a target
## MeshInstance3D's material. Listens for damage_taken from a HealthComponent
## and triggers a 0.25s pulse → 0.0 tween. Stack multiple hits by killing the
## previous tween and restarting from 1.0.
##
## Required scene shape:
##   HitGlitchDriver (Node + this script)
##     export mesh_path → MeshInstance3D using a ShaderMaterial bound to
##       res://assets/shaders/enemy_hit_glitch.gdshader
##     export health_component_path → HealthComponent emitting damage_taken
##
## Inspector:
##   pulse_duration_s — how long the glitch effect lasts (default 0.25)
##   peak_intensity   — initial pulse value (default 1.0; lower for hits that
##                       shouldn't fully fragment, e.g. resisted damage)

@export var mesh_path: NodePath
@export var health_component_path: NodePath
@export var pulse_duration_s: float = 0.25
@export var peak_intensity: float = 1.0

var _mesh: MeshInstance3D
var _material: ShaderMaterial
var _active_tween: Tween


func _ready() -> void:
	_mesh = get_node_or_null(mesh_path) as MeshInstance3D
	if _mesh == null:
		push_warning("HitGlitchDriver: mesh_path not found at %s" % mesh_path)
		return

	# Resolve the ShaderMaterial — accept either material_override or the
	# first surface material
	_material = _mesh.material_override as ShaderMaterial
	if _material == null and _mesh.get_surface_override_material_count() > 0:
		_material = _mesh.get_surface_override_material(0) as ShaderMaterial

	if _material == null:
		push_warning("HitGlitchDriver: no ShaderMaterial on %s" % _mesh.name)
		return

	# Wire to the health component
	var hc: Node = get_node_or_null(health_component_path)
	if hc != null and hc.has_signal("damage_taken"):
		hc.damage_taken.connect(_on_damage_taken)


func _on_damage_taken(_amount: float) -> void:
	pulse(peak_intensity)


func pulse(intensity: float = 1.0) -> void:
	## Manually fire the glitch pulse — useful for non-damage triggers like
	## stagger interrupts or environmental hazards.
	if _material == null:
		return

	# Kill prior tween so re-hits restart cleanly instead of double-easing
	if _active_tween != null and _active_tween.is_valid():
		_active_tween.kill()

	_material.set_shader_parameter("hit_pulse", intensity)
	_active_tween = create_tween()
	_active_tween.tween_property(
		_material,
		"shader_parameter/hit_pulse",
		0.0,
		pulse_duration_s,
	).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
