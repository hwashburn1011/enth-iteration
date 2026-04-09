extends Node
## WildernessMusicDirector — orchestrates the 4-layer wilderness music
## stack from the wilderness bible:
##
##   base_wind_layer (always on, -18 dB while in any wilderness region)
##     +
##   region_layer (zone player, crossfades on region change, -6 dB)
##     +
##   encounter_layer (combat layers, MusicManager already handles)
##     +
##   weather_layer (situational, -9 dB) — rain / storm / fog / glitch
##
## This director sits ABOVE MusicManager. It listens to EventBus,
## DayNightController, and WeatherController and issues commands to
## MusicManager (`play_zone_track`, `play_base_layer`, `play_weather_layer`).
##
## Add to project autoloads as "WildernessMusicDirector".

const REGION_TRACK_DAY: Dictionary = {
	&"wild_plateau": &"wild_plateau",
	&"wild_river":   &"wild_river",
	&"wild_forest":  &"wild_forest",
	&"wild_ruins":   &"wild_ruins",
	&"wild_cliffs":  &"wild_cliffs",
	&"wild_pasture": &"wild_pasture",
}

const REGION_TRACK_NIGHT: Dictionary = {
	&"wild_forest":  &"wild_forest_night",
	&"wild_ruins":   &"wild_ruins_night",
	# others fall back to day variant + base wind drone carries the night feel
}

const WEATHER_TRACK: Dictionary = {
	&"rain":         &"wild_weather_rain",
	&"storm":        &"wild_weather_storm",
	&"fog":          &"wild_weather_fog",
	&"glitch_storm": &"wild_weather_glitch",
}

const BASE_WIND_TRACK: StringName = &"wild_base_wind_drone"
const BASE_DB: float = -18.0
const REGION_DB: float = -6.0
const WEATHER_DB: float = -9.0

var _current_region: StringName = &""
var _current_phase: StringName = &"day"
var _current_weather: StringName = &"clear"
var _in_wilderness: bool = false


func _ready() -> void:
	_subscribe_to_events()


func _subscribe_to_events() -> void:
	if has_node("/root/EventBus"):
		var bus: Node = get_node("/root/EventBus")
		if bus.has_signal("region_entered"):
			bus.region_entered.connect(_on_region_entered)
	if has_node("/root/DayNightController"):
		var dnc: Node = get_node("/root/DayNightController")
		if dnc.has_signal("phase_changed"):
			dnc.phase_changed.connect(_on_phase_changed)
		if "current_phase" in dnc:
			_current_phase = StringName(dnc.current_phase)
	if has_node("/root/WeatherController"):
		var wc: Node = get_node("/root/WeatherController")
		if wc.has_signal("weather_changed"):
			wc.weather_changed.connect(_on_weather_changed)
		if "current_weather_id" in wc:
			_current_weather = StringName(wc.current_weather_id)


# === REGION ===

func enter_region(region_id: StringName) -> void:
	var was_in_wilderness: bool = _in_wilderness
	_current_region = region_id
	_in_wilderness = String(region_id).begins_with("wild_")

	if not _in_wilderness:
		_exit_wilderness()
		return

	if not was_in_wilderness:
		_enter_wilderness()

	_apply_region_track()
	_apply_weather_layer()


func _enter_wilderness() -> void:
	if has_node("/root/MusicManager"):
		var mm: Node = get_node("/root/MusicManager")
		if mm.has_method("play_base_layer"):
			mm.play_base_layer(BASE_WIND_TRACK, BASE_DB, 4.0)


func _exit_wilderness() -> void:
	_in_wilderness = false
	if has_node("/root/MusicManager"):
		var mm: Node = get_node("/root/MusicManager")
		if mm.has_method("stop_base_layer"):
			mm.stop_base_layer(3.0)
		if mm.has_method("stop_weather_layer"):
			mm.stop_weather_layer(3.0)


func _apply_region_track() -> void:
	if not _in_wilderness:
		return
	var track: StringName = _resolve_region_track(_current_region, _current_phase)
	if track == &"":
		return
	if has_node("/root/MusicManager"):
		var mm: Node = get_node("/root/MusicManager")
		if mm.has_method("play_zone_track"):
			mm.play_zone_track(track)


func _resolve_region_track(region_id: StringName, phase: StringName) -> StringName:
	if phase == &"night" and REGION_TRACK_NIGHT.has(region_id):
		return REGION_TRACK_NIGHT[region_id]
	return REGION_TRACK_DAY.get(region_id, &"")


# === WEATHER ===

func _apply_weather_layer() -> void:
	if not _in_wilderness:
		return
	if not has_node("/root/MusicManager"):
		return
	var mm: Node = get_node("/root/MusicManager")
	var track: StringName = WEATHER_TRACK.get(_current_weather, &"")
	if track == &"":
		if mm.has_method("stop_weather_layer"):
			mm.stop_weather_layer(3.0)
		return
	if mm.has_method("play_weather_layer"):
		mm.play_weather_layer(track, WEATHER_DB, 3.0)


# === EVENT HANDLERS ===

func _on_region_entered(region_id: StringName, _meta: Dictionary) -> void:
	enter_region(region_id)


func _on_phase_changed(phase: StringName) -> void:
	_current_phase = phase
	if _in_wilderness:
		_apply_region_track()


func _on_weather_changed(weather_id: StringName) -> void:
	_current_weather = weather_id
	if _in_wilderness:
		_apply_weather_layer()
