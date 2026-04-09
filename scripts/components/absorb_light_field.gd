class_name AbsorbLightField
extends Node3D

## Wraps the absorb_light.gdshader on a sphere mesh and parents it to the
## enemy so the sphere follows the body. The sphere darkens the visible
## scene around the enemy via blend_mul (the closer the player camera is,
## the more they see the world get visually "drained" by the leak).
##
## Single component to drop on any enemy that should "absorb light":
##   var absorb: AbsorbLightField = AbsorbLightField.new()
##   absorb.field_radius_m = 2.5
##   absorb.absorb_strength = 0.7
##   memoryleak_root.add_child(absorb)
##
## Inspector configuration:
##   field_radius_m   — sphere radius (default 2.0)
##   absorb_strength  — 0..1 darken intensity
##   tint_color       — color tint of the absorbed area
##   pulse_period_s   — slow breathing pulse on absorb_strength (0 = static)
##   stop_when_dead   — auto-disable on parent died (default true)

const SHADER_PATH: String = "res://assets/shaders/absorb_light.gdshader"

@export_range(0.5, 12.0) var field_radius_m: float = 2.0
@export_range(0.0, 1.0) var absorb_strength: float = 0.65
@export var tint_color: Color = Color(0.55, 0.75, 0.80)
@export_range(0.0, 16.0) var pulse_period_s: float = 4.0
@export_range(0.0, 0.5) var pulse_amplitude: float = 0.10
@export var stop_when_dead: bool = true
@export var health_component_path: NodePath

var _mesh: MeshInstance3D
var _material: ShaderMaterial
var _time_accum: float = 0.0
var _base_strength: float = 0.0
var _disabled: bool = false


func _ready() -> void:
	_base_strength = absorb_strength
	_build_field()

	if stop_when_dead:
		var hc: Node = get_node_or_null(health_component_path)
		if hc == null:
			var parent: Node = get_parent()
			if parent != null:
				for child: Node in parent.get_children():
					if child.has_signal("died"):
						hc = child
						break
		if hc != null and hc.has_signal("died"):
			hc.died.connect(_on_died)


func _build_field() -> void:
	_mesh = MeshInstance3D.new()
	_mesh.name = "AbsorbField"
	var sphere: SphereMesh = SphereMesh.new()
	sphere.radius = field_radius_m
	sphere.height = field_radius_m * 2.0
	sphere.radial_segments = 24
	sphere.rings = 12
	_mesh.mesh = sphere
	_mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

	_material = ShaderMaterial.new()
	_material.shader = load(SHADER_PATH) as Shader
	_material.set_shader_parameter("absorb_strength", absorb_strength)
	_material.set_shader_parameter("falloff_power", 2.5)
	_material.set_shader_parameter("inner_softness", 0.30)
	_material.set_shader_parameter("tint_color", tint_color)
	_material.set_shader_parameter("rim_emission", 0.6)
	_mesh.material_override = _material

	add_child(_mesh)


func _process(delta: float) -> void:
	if _disabled:
		return
	if pulse_period_s > 0.0 and pulse_amplitude > 0.0:
		_time_accum += delta
		var pulse: float = sin(_time_accum * TAU / pulse_period_s) * pulse_amplitude
		_material.set_shader_parameter("absorb_strength", clampf(_base_strength + pulse, 0.0, 1.0))


func _on_died() -> void:
	_disabled = true
	# Tween the absorb effect away over a short fade so the death
	# transition feels gradual instead of snapping back to normal lighting
	var tw: Tween = create_tween()
	tw.tween_method(_set_strength, _base_strength, 0.0, 0.8) \
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tw.tween_callback(_mesh.queue_free)


func _set_strength(value: float) -> void:
	if _material != null:
		_material.set_shader_parameter("absorb_strength", value)
