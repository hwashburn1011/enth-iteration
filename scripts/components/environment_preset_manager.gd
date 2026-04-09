class_name EnvironmentPresetManager
extends Node

## Per-environment lighting preset manager (Epic 19 closing tasks).
## Holds 5 environment presets covering town day/night, dungeon dim, boss
## arena, menu key — and applies them to the world environment + all
## lights in the scene at runtime.
##
## Used by:
##   - SceneManager when transitioning between zones
##   - Day/night cycle when crossing time-of-day thresholds
##   - Combat state machine when entering "danger" mode
##
## Each preset covers:
##   - WorldEnvironment params (fog, ambient, tonemap, glow, ssao, ssr,
##     sdfgi, color grading lut)
##   - DirectionalLight3D params (color, energy, shadow, angular distance)
##   - Reflection probe intensity scale
##   - Skybox material assignment

enum PresetID {
	TOWN_DAY,
	TOWN_NIGHT,
	DUNGEON_DIM,
	BOSS_ARENA,
	MENU_KEY,
	DANGER_COMBAT,
	SAFE_HUB,
	STORY_CINEMATIC,
}

const PRESETS: Dictionary = {
	PresetID.TOWN_DAY: {
		"fog_enabled": true,
		"fog_density": 0.005,
		"fog_color": Color(0.55, 0.65, 0.85),
		"fog_aerial": 0.5,
		"ambient_color": Color(0.45, 0.55, 0.75),
		"ambient_energy": 0.35,
		"glow_enabled": true,
		"glow_intensity": 0.5,
		"glow_strength": 0.85,
		"glow_blend": 1,
		"tonemap_mode": 3,  # FILMIC
		"tonemap_exposure": 1.1,
		"tonemap_white": 6.0,
		"sdfgi_enabled": true,
		"sdfgi_energy": 1.0,
		"ssao_enabled": true,
		"ssao_intensity": 1.5,
		"ssr_enabled": false,
		"sun_color": Color(1.0, 0.95, 0.85),
		"sun_energy": 1.4,
		"sun_angle_deg": 55.0,
		"sky_id": &"town_day",
	},
	PresetID.TOWN_NIGHT: {
		"fog_enabled": true,
		"fog_density": 0.012,
		"fog_color": Color(0.10, 0.15, 0.30),
		"fog_aerial": 0.7,
		"ambient_color": Color(0.10, 0.15, 0.30),
		"ambient_energy": 0.20,
		"glow_enabled": true,
		"glow_intensity": 0.85,
		"glow_strength": 1.10,
		"glow_blend": 1,
		"tonemap_mode": 3,
		"tonemap_exposure": 0.85,
		"tonemap_white": 6.0,
		"sdfgi_enabled": true,
		"sdfgi_energy": 0.65,
		"ssao_enabled": true,
		"ssao_intensity": 1.8,
		"ssr_enabled": true,
		"sun_color": Color(0.30, 0.40, 0.85),
		"sun_energy": 0.20,
		"sun_angle_deg": -30.0,
		"sky_id": &"town_night",
	},
	PresetID.DUNGEON_DIM: {
		"fog_enabled": true,
		"fog_density": 0.025,
		"fog_color": Color(0.05, 0.10, 0.18),
		"fog_aerial": 0.85,
		"ambient_color": Color(0.10, 0.15, 0.25),
		"ambient_energy": 0.30,
		"glow_enabled": true,
		"glow_intensity": 0.95,
		"glow_strength": 1.20,
		"glow_blend": 1,
		"tonemap_mode": 3,
		"tonemap_exposure": 0.95,
		"tonemap_white": 5.0,
		"sdfgi_enabled": false,
		"ssao_enabled": true,
		"ssao_intensity": 2.2,
		"ssr_enabled": true,
		"sun_color": Color(0.10, 0.20, 0.40),
		"sun_energy": 0.05,
		"sun_angle_deg": -90.0,
		"sky_id": &"dungeon_void",
	},
	PresetID.BOSS_ARENA: {
		"fog_enabled": true,
		"fog_density": 0.020,
		"fog_color": Color(0.08, 0.18, 0.30),
		"fog_aerial": 0.85,
		"ambient_color": Color(0.05, 0.10, 0.18),
		"ambient_energy": 0.50,
		"glow_enabled": true,
		"glow_intensity": 1.15,
		"glow_strength": 1.40,
		"glow_blend": 1,
		"tonemap_mode": 3,
		"tonemap_exposure": 1.0,
		"tonemap_white": 7.0,
		"sdfgi_enabled": false,
		"ssao_enabled": true,
		"ssao_intensity": 2.5,
		"ssr_enabled": true,
		"sun_color": Color(0.20, 0.45, 0.85),
		"sun_energy": 0.40,
		"sun_angle_deg": -45.0,
		"sky_id": &"boss_void",
	},
	PresetID.MENU_KEY: {
		"fog_enabled": true,
		"fog_density": 0.008,
		"fog_color": Color(0.08, 0.12, 0.22),
		"fog_aerial": 0.45,
		"ambient_color": Color(0.20, 0.25, 0.40),
		"ambient_energy": 0.40,
		"glow_enabled": true,
		"glow_intensity": 0.95,
		"glow_strength": 1.20,
		"glow_blend": 1,
		"tonemap_mode": 3,
		"tonemap_exposure": 1.05,
		"tonemap_white": 6.0,
		"sdfgi_enabled": false,
		"ssao_enabled": true,
		"ssao_intensity": 1.5,
		"ssr_enabled": false,
		"sun_color": Color(1.0, 0.85, 0.60),
		"sun_energy": 1.20,
		"sun_angle_deg": 35.0,
		"sky_id": &"menu_void",
	},
	PresetID.DANGER_COMBAT: {
		"fog_enabled": true,
		"fog_density": 0.022,
		"fog_color": Color(0.20, 0.05, 0.10),
		"fog_aerial": 0.85,
		"ambient_color": Color(0.20, 0.05, 0.10),
		"ambient_energy": 0.30,
		"glow_enabled": true,
		"glow_intensity": 1.05,
		"glow_strength": 1.30,
		"glow_blend": 1,
		"tonemap_mode": 3,
		"tonemap_exposure": 0.90,
		"tonemap_white": 5.5,
		"sdfgi_enabled": false,
		"ssao_enabled": true,
		"ssao_intensity": 2.0,
		"ssr_enabled": false,
		"sun_color": Color(1.0, 0.20, 0.05),
		"sun_energy": 0.10,
		"sun_angle_deg": -45.0,
		"sky_id": &"danger_void",
	},
	PresetID.SAFE_HUB: {
		"fog_enabled": true,
		"fog_density": 0.005,
		"fog_color": Color(0.55, 0.55, 0.65),
		"fog_aerial": 0.40,
		"ambient_color": Color(0.55, 0.50, 0.45),
		"ambient_energy": 0.55,
		"glow_enabled": true,
		"glow_intensity": 0.55,
		"glow_strength": 0.90,
		"glow_blend": 1,
		"tonemap_mode": 3,
		"tonemap_exposure": 1.15,
		"tonemap_white": 6.0,
		"sdfgi_enabled": true,
		"sdfgi_energy": 1.10,
		"ssao_enabled": true,
		"ssao_intensity": 1.2,
		"ssr_enabled": false,
		"sun_color": Color(1.0, 0.95, 0.85),
		"sun_energy": 1.30,
		"sun_angle_deg": 50.0,
		"sky_id": &"hub_warm",
	},
	PresetID.STORY_CINEMATIC: {
		"fog_enabled": true,
		"fog_density": 0.015,
		"fog_color": Color(0.20, 0.18, 0.30),
		"fog_aerial": 0.60,
		"ambient_color": Color(0.30, 0.25, 0.40),
		"ambient_energy": 0.35,
		"glow_enabled": true,
		"glow_intensity": 1.25,
		"glow_strength": 1.45,
		"glow_blend": 1,
		"tonemap_mode": 3,
		"tonemap_exposure": 1.05,
		"tonemap_white": 6.5,
		"sdfgi_enabled": false,
		"ssao_enabled": true,
		"ssao_intensity": 1.8,
		"ssr_enabled": true,
		"sun_color": Color(0.85, 0.70, 0.95),
		"sun_energy": 0.55,
		"sun_angle_deg": 25.0,
		"sky_id": &"story_dusk",
	},
}

@export var world_environment_path: NodePath
@export var directional_light_path: NodePath
@export var transition_duration_s: float = 1.5
@export var current_preset: int = PresetID.TOWN_DAY

var _world_env: WorldEnvironment
var _sun: DirectionalLight3D
var _transition_tween: Tween


func _ready() -> void:
	_world_env = get_node_or_null(world_environment_path) as WorldEnvironment
	_sun = get_node_or_null(directional_light_path) as DirectionalLight3D
	apply_preset(current_preset)


func apply_preset(preset_id: int) -> void:
	if not PRESETS.has(preset_id):
		push_warning("EnvironmentPresetManager: unknown preset_id %d" % preset_id)
		return
	current_preset = preset_id
	var p: Dictionary = PRESETS[preset_id]
	_apply_to_environment(p)
	_apply_to_sun(p)


func transition_to(preset_id: int, duration_s: float = -1.0) -> void:
	if duration_s < 0:
		duration_s = transition_duration_s
	if not PRESETS.has(preset_id):
		return
	if _transition_tween != null and _transition_tween.is_valid():
		_transition_tween.kill()
	var from_preset: Dictionary = PRESETS.get(current_preset, PRESETS[PresetID.TOWN_DAY])
	var to_preset: Dictionary = PRESETS[preset_id]
	current_preset = preset_id
	_transition_tween = create_tween()
	_transition_tween.tween_method(_lerp_apply.bind(from_preset, to_preset), 0.0, 1.0, duration_s)


func _lerp_apply(t: float, from_p: Dictionary, to_p: Dictionary) -> void:
	if _world_env == null or _world_env.environment == null:
		return
	var env: Environment = _world_env.environment
	env.fog_density = lerp(float(from_p.get("fog_density", 0.0)), float(to_p.get("fog_density", 0.0)), t)
	env.fog_light_color = (from_p.get("fog_color", Color.WHITE) as Color).lerp(to_p.get("fog_color", Color.WHITE), t)
	env.ambient_light_color = (from_p.get("ambient_color", Color.WHITE) as Color).lerp(to_p.get("ambient_color", Color.WHITE), t)
	env.ambient_light_energy = lerp(float(from_p.get("ambient_energy", 0.5)), float(to_p.get("ambient_energy", 0.5)), t)
	env.glow_intensity = lerp(float(from_p.get("glow_intensity", 0.5)), float(to_p.get("glow_intensity", 0.5)), t)
	env.glow_strength = lerp(float(from_p.get("glow_strength", 1.0)), float(to_p.get("glow_strength", 1.0)), t)
	env.tonemap_exposure = lerp(float(from_p.get("tonemap_exposure", 1.0)), float(to_p.get("tonemap_exposure", 1.0)), t)
	if _sun != null:
		_sun.light_color = (from_p.get("sun_color", Color.WHITE) as Color).lerp(to_p.get("sun_color", Color.WHITE), t)
		_sun.light_energy = lerp(float(from_p.get("sun_energy", 1.0)), float(to_p.get("sun_energy", 1.0)), t)


func _apply_to_environment(p: Dictionary) -> void:
	if _world_env == null:
		return
	if _world_env.environment == null:
		_world_env.environment = Environment.new()
	var env: Environment = _world_env.environment
	env.fog_enabled = p.get("fog_enabled", true)
	env.fog_density = p.get("fog_density", 0.01)
	env.fog_light_color = p.get("fog_color", Color(0.5, 0.5, 0.6))
	env.fog_aerial_perspective = p.get("fog_aerial", 0.5)
	env.ambient_light_color = p.get("ambient_color", Color(0.3, 0.3, 0.4))
	env.ambient_light_energy = p.get("ambient_energy", 0.5)
	env.glow_enabled = p.get("glow_enabled", true)
	env.glow_intensity = p.get("glow_intensity", 0.8)
	env.glow_strength = p.get("glow_strength", 1.0)
	env.glow_blend_mode = p.get("glow_blend", 1)
	env.tonemap_mode = p.get("tonemap_mode", 3)
	env.tonemap_exposure = p.get("tonemap_exposure", 1.0)
	env.tonemap_white = p.get("tonemap_white", 6.0)
	env.sdfgi_enabled = p.get("sdfgi_enabled", false)
	if env.sdfgi_enabled:
		env.sdfgi_energy = p.get("sdfgi_energy", 1.0)
	env.ssao_enabled = p.get("ssao_enabled", true)
	env.ssao_intensity = p.get("ssao_intensity", 1.5)
	env.ssr_enabled = p.get("ssr_enabled", false)


func _apply_to_sun(p: Dictionary) -> void:
	if _sun == null:
		return
	_sun.light_color = p.get("sun_color", Color.WHITE)
	_sun.light_energy = p.get("sun_energy", 1.0)
	_sun.shadow_enabled = true
	_sun.directional_shadow_max_distance = 100.0
	# Sun pitch from horizon
	var pitch_rad: float = deg_to_rad(p.get("sun_angle_deg", 45.0))
	_sun.rotation = Vector3(-pitch_rad, deg_to_rad(45.0), 0.0)
