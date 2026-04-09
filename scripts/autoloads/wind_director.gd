extends Node
## WindDirector — global wind state for the world. Pushes a smoothly
## varying (direction, strength, speed) tuple to RenderingServer global
## shader parameters every frame so the vertex_wind shader on every
## vegetation surface in the scene picks it up automatically — no
## per-material wiring needed.
##
## Behavior:
##   - Each weather defines a base wind direction + strength
##   - The director adds two layers of low-frequency noise on top so
##     the wind never feels static (one slow drift over ~30s, one
##     faster shimmer over ~4s)
##   - On weather change, tweens the base direction over 6s
##   - Optional gust events add a one-shot velocity bump that decays
##
## Add to project autoloads as "WindDirector".

signal wind_changed(direction: Vector3, strength: float)
signal gust_started(intensity: float)

const PARAM_DIR: StringName     = &"wind_global_direction"
const PARAM_STRENGTH: StringName = &"wind_global_strength"
const PARAM_SPEED: StringName   = &"wind_global_speed"

const SLOW_DRIFT_PERIOD: float  = 30.0
const FAST_SHIMMER_PERIOD: float = 4.0
const SLOW_DRIFT_AMOUNT: float  = 0.18  # radians of yaw wander
const FAST_SHIMMER_AMOUNT: float = 0.07

const WEATHER_WIND: Dictionary = {
	&"clear":         {"dir": Vector3(0.6, 0.0, 0.3), "strength": 0.05, "speed": 1.0},
	&"cloudy":        {"dir": Vector3(0.7, 0.0, 0.4), "strength": 0.10, "speed": 1.4},
	&"rain":          {"dir": Vector3(0.5, 0.0, 0.2), "strength": 0.13, "speed": 1.8},
	&"storm":         {"dir": Vector3(1.0, 0.0, 0.5), "strength": 0.28, "speed": 3.0},
	&"fog":           {"dir": Vector3(0.3, 0.0, 0.2), "strength": 0.04, "speed": 0.7},
	&"glitch_storm":  {"dir": Vector3(0.8, 0.0, 0.6), "strength": 0.20, "speed": 2.4},
}

# Region multipliers — cliffs are windier, forest is calmer
const REGION_STRENGTH_MULT: Dictionary = {
	&"wild_plateau": 1.0,
	&"wild_river":   0.85,
	&"wild_forest":  0.55,
	&"wild_ruins":   0.90,
	&"wild_cliffs":  1.45,
	&"wild_pasture": 0.80,
}

var _base_dir: Vector3 = Vector3(0.6, 0.0, 0.3)
var _base_strength: float = 0.05
var _base_speed: float = 1.0
var _region_mult: float = 1.0
var _gust_decay: float = 0.0
var _gust_intensity: float = 0.0
var _direction_tween: Tween
var _strength_tween: Tween
var _speed_tween: Tween


func _ready() -> void:
	_register_global_params()
	_subscribe_to_events()
	_publish_now()


func _register_global_params() -> void:
	# Initialize global shader params with safe defaults so any material
	# using vertex_wind renders correctly even before the first publish.
	if not RenderingServer.global_shader_parameter_get_list().has(PARAM_DIR):
		RenderingServer.global_shader_parameter_add(PARAM_DIR, RenderingServer.GLOBAL_VAR_TYPE_VEC3, _base_dir)
	if not RenderingServer.global_shader_parameter_get_list().has(PARAM_STRENGTH):
		RenderingServer.global_shader_parameter_add(PARAM_STRENGTH, RenderingServer.GLOBAL_VAR_TYPE_FLOAT, _base_strength)
	if not RenderingServer.global_shader_parameter_get_list().has(PARAM_SPEED):
		RenderingServer.global_shader_parameter_add(PARAM_SPEED, RenderingServer.GLOBAL_VAR_TYPE_FLOAT, _base_speed)


func _subscribe_to_events() -> void:
	if has_node("/root/WeatherController"):
		var wc: Node = get_node("/root/WeatherController")
		if wc.has_signal("weather_changed"):
			wc.weather_changed.connect(_on_weather_changed)
	if has_node("/root/EventBus"):
		var bus: Node = get_node("/root/EventBus")
		if bus.has_signal("region_entered"):
			bus.region_entered.connect(_on_region_entered)


func _process(delta: float) -> void:
	# Compute live drift on top of the base direction
	var t: float = Time.get_ticks_msec() / 1000.0
	var slow: float = sin(t * (TAU / SLOW_DRIFT_PERIOD)) * SLOW_DRIFT_AMOUNT
	var fast: float = sin(t * (TAU / FAST_SHIMMER_PERIOD)) * FAST_SHIMMER_AMOUNT
	var yaw: float = slow + fast
	var live_dir: Vector3 = _base_dir.rotated(Vector3.UP, yaw)

	# Decay any active gust
	if _gust_decay > 0.0:
		_gust_decay = max(0.0, _gust_decay - delta)

	var gust_factor: float = 1.0 + _gust_intensity * (_gust_decay if _gust_decay > 0.0 else 0.0)
	var live_strength: float = _base_strength * _region_mult * gust_factor

	RenderingServer.global_shader_parameter_set(PARAM_DIR, live_dir)
	RenderingServer.global_shader_parameter_set(PARAM_STRENGTH, live_strength)
	RenderingServer.global_shader_parameter_set(PARAM_SPEED, _base_speed)


# === WEATHER ===

func _on_weather_changed(weather_id: StringName) -> void:
	var entry: Dictionary = WEATHER_WIND.get(weather_id, WEATHER_WIND[&"clear"])
	var target_dir: Vector3 = entry.get("dir", Vector3(1, 0, 0))
	var target_strength: float = float(entry.get("strength", 0.05))
	var target_speed: float = float(entry.get("speed", 1.0))
	_tween_to(target_dir, target_strength, target_speed, 6.0)
	wind_changed.emit(target_dir, target_strength)


func _on_region_entered(region_id: StringName, _meta: Dictionary) -> void:
	_region_mult = float(REGION_STRENGTH_MULT.get(region_id, 1.0))


# === GUST API ===

func trigger_gust(intensity: float = 1.0, duration_s: float = 1.5) -> void:
	## One-shot velocity bump that decays linearly. Used by storm strikes,
	## boss arenas, glitch storms, scripted cinematic moments.
	_gust_intensity = clampf(intensity, 0.0, 4.0)
	_gust_decay = max(_gust_decay, duration_s)
	gust_started.emit(_gust_intensity)


# === INTERNAL TWEENING ===

func _tween_to(dir: Vector3, strength: float, speed: float, duration: float) -> void:
	if _direction_tween != null and _direction_tween.is_valid():
		_direction_tween.kill()
	if _strength_tween != null and _strength_tween.is_valid():
		_strength_tween.kill()
	if _speed_tween != null and _speed_tween.is_valid():
		_speed_tween.kill()

	_direction_tween = create_tween()
	_direction_tween.tween_method(_set_base_dir, _base_dir, dir, duration)

	_strength_tween = create_tween()
	_strength_tween.tween_method(_set_base_strength, _base_strength, strength, duration)

	_speed_tween = create_tween()
	_speed_tween.tween_method(_set_base_speed, _base_speed, speed, duration)


func _set_base_dir(d: Vector3) -> void:
	_base_dir = d


func _set_base_strength(s: float) -> void:
	_base_strength = s


func _set_base_speed(s: float) -> void:
	_base_speed = s


func _publish_now() -> void:
	RenderingServer.global_shader_parameter_set(PARAM_DIR, _base_dir)
	RenderingServer.global_shader_parameter_set(PARAM_STRENGTH, _base_strength * _region_mult)
	RenderingServer.global_shader_parameter_set(PARAM_SPEED, _base_speed)


# === QUERY ===

func get_current_direction() -> Vector3:
	return _base_dir


func get_current_strength() -> float:
	return _base_strength * _region_mult


func get_current_speed() -> float:
	return _base_speed
