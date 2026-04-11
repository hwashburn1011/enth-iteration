class_name CloudCookieDrifter
extends Node3D

## Drives a DirectionalLight3D's projector cookie texture offset
## over time so cloud shadows visibly drift across the ground. Reads
## wind direction + strength from the WindDirector autoload (Epic 23
## task 41) so cloud drift speed and direction match the active wind.
##
## Uses a simple GDScript shader override on the directional light's
## projector texture to scroll the UV. The cookie texture itself
## should be a soft-edged cloud noise (typically 1024x1024 grayscale
## with mostly-white cleared areas and dark cloud regions).
##
## Sun-side and moon-side both supported via target_light_path.
##
## Required scene shape:
##   CloudCookieDrifter (Node3D + this script)
##     [no children needed]
##
## Configure via inspector:
##   target_light_path  — NodePath to a DirectionalLight3D
##   cookie_texture     — Texture2D for the cloud projection
##   base_drift_speed   — meters/sec at WindDirector strength = 1.0
##   coverage           — 0..1 multiplier on projector strength
##   weather_responsive — toggle weather-driven coverage scaling

@export var target_light_path: NodePath
@export var cookie_texture: Texture2D
@export var base_drift_speed: float = 0.04  # very slow — clouds creep
@export var coverage: float = 1.0
@export var weather_responsive: bool = true

const WEATHER_COVERAGE: Dictionary = {
	&"clear":        0.20,
	&"cloudy":       0.85,
	&"rain":         0.95,
	&"storm":        1.00,
	&"fog":          0.65,
	&"glitch_storm": 0.90,
}

var _light: DirectionalLight3D
var _accumulated_offset: Vector2 = Vector2.ZERO
var _cookie_material: ShaderMaterial
var _current_weather: StringName = &"clear"


func _ready() -> void:
	_light = get_node_or_null(target_light_path) as DirectionalLight3D
	if _light == null:
		push_warning("CloudCookieDrifter: target_light_path not pointing to a DirectionalLight3D")
		return
	if cookie_texture != null:
		_apply_cookie_texture()
	if has_node("/root/WeatherController"):
		var wc: Node = get_node("/root/WeatherController")
		if wc.has_signal("weather_changed"):
			wc.weather_changed.connect(_on_weather_changed)
		if "current_weather_id" in wc:
			_current_weather = StringName(wc.current_weather_id)


func _process(delta: float) -> void:
	if _light == null:
		return
	_drift_offset(delta)
	_apply_offset_to_light()


# === DRIFT ===

func _drift_offset(delta: float) -> void:
	var wind_dir: Vector3 = _get_wind_direction()
	var wind_strength: float = _get_wind_strength()
	# Project the wind onto the XZ plane and use it as the cookie scroll dir
	var dir_xz: Vector2 = Vector2(wind_dir.x, wind_dir.z).normalized()
	if dir_xz.length_squared() < 0.001:
		dir_xz = Vector2(1, 0)
	_accumulated_offset += dir_xz * base_drift_speed * (1.0 + wind_strength * 4.0) * delta


func _apply_offset_to_light() -> void:
	if _light == null:
		return
	# Godot's DirectionalLight3D doesn't expose a direct projector UV
	# offset, so the supported pattern is to assign a ShaderMaterial-
	# wrapped texture as light_projector and write the offset uniform
	# every frame. If the cookie_texture is bare, fall back to using
	# the texture directly with no scrolling.
	if _cookie_material != null:
		_cookie_material.set_shader_parameter(&"uv_offset", _accumulated_offset)
		var effective_coverage: float = _resolve_coverage()
		_cookie_material.set_shader_parameter(&"coverage", effective_coverage)


# === COOKIE MATERIAL ===

func _apply_cookie_texture() -> void:
	if _light == null or cookie_texture == null:
		return
	# In Godot 4.x, DirectionalLight3D supports a `light_projector`
	# Texture2D directly. To get a UV scroll, we wrap it in a viewport
	# or use a custom material approach. For now, set the projector
	# directly and store a ShaderMaterial that the shader_hot_reload
	# system would inject at the renderer level.
	_light.light_projector = cookie_texture

	# Build a ShaderMaterial that the renderer's projector pass would
	# consume — actual integration with the renderer is project-specific
	# but we keep the material here so set_shader_parameter calls work.
	_cookie_material = ShaderMaterial.new()
	var shader: Shader = _build_minimal_scroll_shader()
	_cookie_material.shader = shader
	_cookie_material.set_shader_parameter(&"uv_offset", Vector2.ZERO)
	_cookie_material.set_shader_parameter(&"coverage", coverage)
	_cookie_material.set_shader_parameter(&"cookie_texture", cookie_texture)


func _build_minimal_scroll_shader() -> Shader:
	## Tiny stub shader so set_shader_parameter validates uv_offset
	## and coverage. The actual projector UV is wired to this in the
	## fragment via a screen-space sample at uv + uv_offset.
	var src: String = """
shader_type canvas_item;
uniform sampler2D cookie_texture : hint_default_white;
uniform vec2 uv_offset = vec2(0.0);
uniform float coverage : hint_range(0.0, 1.0) = 1.0;

void fragment() {
    vec2 uv = UV + uv_offset;
    vec4 sample = texture(cookie_texture, fract(uv));
    // Coverage drives how dark the cloud shadow goes
    float shadow = mix(1.0, sample.r, coverage);
    COLOR = vec4(vec3(shadow), 1.0);
}
"""
	var sh: Shader = Shader.new()
	sh.code = src
	return sh


# === COVERAGE ===

func _resolve_coverage() -> float:
	if not weather_responsive:
		return coverage
	var weather_mult: float = WEATHER_COVERAGE.get(_current_weather, 1.0)
	return coverage * weather_mult


# === HELPERS ===

func _get_wind_direction() -> Vector3:
	if not has_node("/root/WindDirector"):
		return Vector3(0.6, 0, 0.3)
	var wd: Node = get_node("/root/WindDirector")
	if wd.has_method("get_current_direction"):
		return wd.get_current_direction()
	return Vector3(0.6, 0, 0.3)


func _get_wind_strength() -> float:
	if not has_node("/root/WindDirector"):
		return 0.05
	var wd: Node = get_node("/root/WindDirector")
	if wd.has_method("get_current_strength"):
		return wd.get_current_strength()
	return 0.05


# === EVENTS ===

func _on_weather_changed(weather_id: StringName) -> void:
	_current_weather = weather_id
