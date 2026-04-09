extends Node
## WeatherController — global weather controller. Schedules weather changes,
## fires transition events, manages thunder triggers, drives wind direction,
## and exposes combat/fishing/crop modifier queries.
##
## Add to project autoloads as "WeatherController".

signal weather_changed(new_weather_id: StringName)
signal weather_transition_started(from_id: StringName, to_id: StringName)
signal weather_transition_finished(weather_id: StringName)
signal thunder_struck

const TRANSITION_DURATION: float = 30.0  ## in-game seconds
const MIN_DURATION_MINUTES: int = 8
const MAX_DURATION_MINUTES: int = 16
const THUNDER_CHECK_INTERVAL: float = 5.0  ## real seconds

var current_weather_id: StringName = &"clear"
var current_zone_id: StringName = &"town_center"
var weather_locked: bool = false
var iteration_glitch_bonus: float = 0.0  ## scales with current iteration

var _next_change_at_minute: int = 0
var _last_change_minute: int = 0
var _thunder_timer: float = 0.0
var _transitioning: bool = false
var _wind_direction: Vector3 = Vector3.ZERO


func _ready() -> void:
	_subscribe_to_events()


func _subscribe_to_events() -> void:
	if Engine.has_singleton("EventBus") or has_node("/root/EventBus"):
		var bus: Node = get_node("/root/EventBus")
		if bus.has_signal("zone_entered"):
			bus.zone_entered.connect(_on_zone_entered)
		if bus.has_signal("hour_changed"):
			bus.hour_changed.connect(_on_hour_changed)
		if bus.has_signal("iteration_changed"):
			bus.iteration_changed.connect(_on_iteration_changed)


func _process(delta: float) -> void:
	# Thunder triggers during storms
	var weather: Dictionary = WeatherDatabase.get_weather(current_weather_id)
	var thunder_chance: float = weather.get("thunder_chance", 0.0)
	if thunder_chance > 0.0:
		_thunder_timer += delta
		if _thunder_timer >= THUNDER_CHECK_INTERVAL:
			_thunder_timer = 0.0
			if randf() < thunder_chance:
				thunder_struck.emit()
				if has_node("/root/SFXManager"):
					var sm: Node = get_node("/root/SFXManager")
					if sm.has_method("play"):
						sm.play(&"environment_collapse")  # using existing thunder-like SFX


# === WEATHER CHANGE ===

func set_weather(weather_id: StringName, force: bool = false) -> bool:
	if weather_locked and not force:
		return false
	if weather_id == current_weather_id:
		return false
	if not WeatherDatabase.can_transition(current_weather_id, weather_id):
		# Force transition through cloudy
		_chained_transition(weather_id)
		return true
	_begin_transition(weather_id)
	return true


func _begin_transition(to_id: StringName) -> void:
	var from_id: StringName = current_weather_id
	weather_transition_started.emit(from_id, to_id)
	_transitioning = true
	# Update wind direction immediately (its own tween system handles smoothing)
	var to_weather: Dictionary = WeatherDatabase.get_weather(to_id)
	_wind_direction = to_weather.get("wind_direction", Vector3.ZERO)
	# Apply audio + visual changes immediately (the visual layer crossfades)
	_apply_weather_audio(to_id)
	current_weather_id = to_id
	weather_changed.emit(to_id)
	# Schedule completion after transition duration
	await get_tree().create_timer(TRANSITION_DURATION / 60.0).timeout  # divide for real seconds
	_transitioning = false
	weather_transition_finished.emit(to_id)


func _chained_transition(target_id: StringName) -> void:
	## Forbidden transition — must pass through cloudy first.
	_begin_transition(&"cloudy")
	await get_tree().create_timer(TRANSITION_DURATION / 60.0 + 1.0).timeout
	_begin_transition(target_id)


func _apply_weather_audio(weather_id: StringName) -> void:
	if not has_node("/root/SFXManager"):
		return
	var sm: Node = get_node("/root/SFXManager")
	# Stop existing world ambient loops
	if sm.has_method("stop_all_in_category"):
		sm.stop_all_in_category(&"world")
	# Start new ambient loops
	var weather: Dictionary = WeatherDatabase.get_weather(weather_id)
	for loop_id in weather.get("sfx_loops", []):
		if sm.has_method("play"):
			sm.play(loop_id)


# === ZONE / TIME / ITERATION HOOKS ===

func _on_zone_entered(zone_id: StringName, _env_preset: StringName) -> void:
	current_zone_id = zone_id
	# Roll a fresh weather for this zone
	var new_weather: StringName = WeatherDatabase.roll_weather_for_zone(zone_id, iteration_glitch_bonus)
	set_weather(new_weather, true)
	_schedule_next_change()


func _on_hour_changed(_h: int) -> void:
	if not has_node("/root/DayNightController"):
		return
	var dnc: Node = get_node("/root/DayNightController")
	var current_minute: int = int(dnc.current_in_game_minute)
	if current_minute >= _next_change_at_minute:
		_roll_and_apply_weather()
		_schedule_next_change()


func _on_iteration_changed(new_iteration: int) -> void:
	# Each iteration past 1 adds 1% glitch storm chance, capping at 8%
	iteration_glitch_bonus = clampf(float(new_iteration - 1) * 0.01, 0.0, 0.08)


func _roll_and_apply_weather() -> void:
	var new_weather: StringName = WeatherDatabase.roll_weather_for_zone(current_zone_id, iteration_glitch_bonus)
	set_weather(new_weather)


func _schedule_next_change() -> void:
	if not has_node("/root/DayNightController"):
		return
	var dnc: Node = get_node("/root/DayNightController")
	_last_change_minute = int(dnc.current_in_game_minute)
	_next_change_at_minute = _last_change_minute + randi_range(MIN_DURATION_MINUTES, MAX_DURATION_MINUTES)
	if _next_change_at_minute >= 1440:
		_next_change_at_minute -= 1440


# === GAMEPLAY MODIFIER QUERIES ===

func get_combat_modifier(key: StringName) -> float:
	var weather: Dictionary = WeatherDatabase.get_weather(current_weather_id)
	var mods: Dictionary = weather.get("combat_modifiers", {})
	return mods.get(key, 1.0)


func get_fish_modifier(key: StringName) -> Variant:
	var weather: Dictionary = WeatherDatabase.get_weather(current_weather_id)
	var mods: Dictionary = weather.get("fish_modifiers", {})
	return mods.get(key, null)


func get_crop_modifier(key: StringName) -> Variant:
	var weather: Dictionary = WeatherDatabase.get_weather(current_weather_id)
	var mods: Dictionary = weather.get("crop_modifiers", {})
	return mods.get(key, null)


func get_wind_direction() -> Vector3:
	return _wind_direction


# === LOCKING (for story events) ===

func lock_weather(weather_id: StringName) -> void:
	weather_locked = true
	set_weather(weather_id, true)


func unlock_weather() -> void:
	weather_locked = false


# === SAVE / LOAD ===

func to_save_data() -> Dictionary:
	return {
		"current_weather_id": String(current_weather_id),
		"current_zone_id": String(current_zone_id),
		"weather_locked": weather_locked,
		"iteration_glitch_bonus": iteration_glitch_bonus,
	}


func from_save_data(data: Dictionary) -> void:
	current_weather_id = StringName(data.get("current_weather_id", "clear"))
	current_zone_id = StringName(data.get("current_zone_id", "town_center"))
	weather_locked = data.get("weather_locked", false)
	iteration_glitch_bonus = data.get("iteration_glitch_bonus", 0.0)
	# Re-apply audio for restored weather
	_apply_weather_audio(current_weather_id)
