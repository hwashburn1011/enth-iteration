class_name DungeonEntranceWeatherResponder
extends Node3D

## Per-entrance weather response. Sibling to DungeonEntrancePhaseTuner —
## where the phase tuner modulates by time of day, this one modulates by
## active weather. Both compose multiplicatively against the captured
## lighting baselines so phase + weather can stack (foggy dawn at the
## Final Vault is dimmer than either alone).
##
## Each entrance reacts to weather in a way that fits its identity:
##   server_room    — barely reacts; the Server Room is sealed and the
##                    weather doesn't reach it. Storms tighten the rim
##                    light a touch.
##   memory_vaults  — fog *brightens* the vault (the choir gets louder),
##                    rain dims it slightly
##   corrupted_wilds — storms make the Wilds *bloom* (1.6x particles),
##                    glitch storms double the core energy
##   final_vault    — glitch storms ignite the seals; the core jumps
##                    to 1.5x and the rim goes harder
##
## Required scene shape:
##   DungeonEntranceWeatherResponder (Node3D + this script)
##     [no children needed; references siblings via NodePath]

const PROFILES: Dictionary = {
	&"server_room": {
		"key_mult":      {&"clear": 1.00, &"cloudy": 0.95, &"rain": 0.95, &"storm": 0.95, &"fog": 0.90, &"glitch_storm": 1.00},
		"rim_mult":      {&"clear": 1.00, &"cloudy": 1.00, &"rain": 1.05, &"storm": 1.15, &"fog": 0.95, &"glitch_storm": 1.10},
		"core_mult":     {&"clear": 1.00, &"cloudy": 1.00, &"rain": 1.00, &"storm": 1.00, &"fog": 0.95, &"glitch_storm": 1.05},
		"particle_mult": {&"clear": 1.00, &"cloudy": 1.00, &"rain": 1.00, &"storm": 1.00, &"fog": 0.95, &"glitch_storm": 1.00},
	},
	&"memory_vaults": {
		"key_mult":      {&"clear": 1.00, &"cloudy": 1.05, &"rain": 0.85, &"storm": 0.75, &"fog": 1.20, &"glitch_storm": 0.90},
		"rim_mult":      {&"clear": 1.00, &"cloudy": 1.10, &"rain": 0.85, &"storm": 0.75, &"fog": 1.25, &"glitch_storm": 0.90},
		"core_mult":     {&"clear": 1.00, &"cloudy": 1.05, &"rain": 0.90, &"storm": 0.85, &"fog": 1.30, &"glitch_storm": 0.95},
		"particle_mult": {&"clear": 1.00, &"cloudy": 1.05, &"rain": 0.85, &"storm": 0.75, &"fog": 1.25, &"glitch_storm": 0.90},
	},
	&"corrupted_wilds": {
		"key_mult":      {&"clear": 1.00, &"cloudy": 1.10, &"rain": 1.20, &"storm": 1.35, &"fog": 1.15, &"glitch_storm": 1.50},
		"rim_mult":      {&"clear": 1.00, &"cloudy": 1.15, &"rain": 1.25, &"storm": 1.40, &"fog": 1.20, &"glitch_storm": 1.55},
		"core_mult":     {&"clear": 1.00, &"cloudy": 1.10, &"rain": 1.20, &"storm": 1.35, &"fog": 1.15, &"glitch_storm": 1.80},
		"particle_mult": {&"clear": 1.00, &"cloudy": 1.20, &"rain": 1.30, &"storm": 1.60, &"fog": 1.25, &"glitch_storm": 1.90},
	},
	&"final_vault": {
		"key_mult":      {&"clear": 1.00, &"cloudy": 1.00, &"rain": 0.95, &"storm": 1.10, &"fog": 1.10, &"glitch_storm": 1.50},
		"rim_mult":      {&"clear": 1.00, &"cloudy": 1.05, &"rain": 1.00, &"storm": 1.15, &"fog": 1.15, &"glitch_storm": 1.60},
		"core_mult":     {&"clear": 1.00, &"cloudy": 1.00, &"rain": 0.95, &"storm": 1.10, &"fog": 1.10, &"glitch_storm": 1.50},
		"particle_mult": {&"clear": 1.00, &"cloudy": 1.05, &"rain": 1.00, &"storm": 1.20, &"fog": 1.15, &"glitch_storm": 1.70},
	},
}

const TWEEN_DURATION: float = 4.0

@export var entrance_id: StringName = &""
@export var lighting_path: NodePath
@export var ambience_path: NodePath
@export var phase_tuner_path: NodePath  ## optional, for stacked-multiplier compose

var _lighting: Node3D
var _ambience: Node3D
var _profile: Dictionary = {}
var _key_base: float = 0.0
var _rim_base: float = 0.0
var _core_base: float = 0.0
var _particle_amount_base: int = 0
var _last_applied_weather: StringName = &""


func _ready() -> void:
	_profile = PROFILES.get(entrance_id, {})
	if _profile.is_empty():
		push_warning("DungeonEntranceWeatherResponder: unknown entrance_id '%s'" % entrance_id)
		return
	_lighting = get_node_or_null(lighting_path) as Node3D
	_ambience = get_node_or_null(ambience_path) as Node3D
	_capture_baselines()
	if has_node("/root/WeatherController"):
		var wc: Node = get_node("/root/WeatherController")
		if wc.has_signal("weather_changed"):
			wc.weather_changed.connect(_on_weather_changed)
	# Apply current weather immediately
	_apply_weather(_current_weather(), false)


func _capture_baselines() -> void:
	if _lighting == null:
		return
	var key: SpotLight3D = _lighting.get_node_or_null("KeyLight") as SpotLight3D
	var rim: SpotLight3D = _lighting.get_node_or_null("RimLight") as SpotLight3D
	var core: OmniLight3D = _lighting.get_node_or_null("PortalCore") as OmniLight3D
	if key != null:
		_key_base = key.light_energy
	if rim != null:
		_rim_base = rim.light_energy
	if core != null:
		_core_base = core.light_energy
	if _ambience != null:
		var particles: GPUParticles3D = _ambience.get_node_or_null("EntranceParticles") as GPUParticles3D
		if particles != null:
			_particle_amount_base = particles.amount


# === APPLY ===

func _apply_weather(weather_id: StringName, animate: bool) -> void:
	if _profile.is_empty():
		return
	if weather_id == _last_applied_weather:
		return
	_last_applied_weather = weather_id

	var key_mult: float  = float(_profile.get("key_mult", {}).get(weather_id, 1.0))
	var rim_mult: float  = float(_profile.get("rim_mult", {}).get(weather_id, 1.0))
	var core_mult: float = float(_profile.get("core_mult", {}).get(weather_id, 1.0))
	var part_mult: float = float(_profile.get("particle_mult", {}).get(weather_id, 1.0))

	if _lighting != null:
		var key: SpotLight3D = _lighting.get_node_or_null("KeyLight") as SpotLight3D
		var rim: SpotLight3D = _lighting.get_node_or_null("RimLight") as SpotLight3D
		var core: OmniLight3D = _lighting.get_node_or_null("PortalCore") as OmniLight3D
		if animate:
			if key != null: _tween(key, &"light_energy", _key_base * key_mult)
			if rim != null: _tween(rim, &"light_energy", _rim_base * rim_mult)
			if core != null: _tween(core, &"light_energy", _core_base * core_mult)
		else:
			if key != null: key.light_energy = _key_base * key_mult
			if rim != null: rim.light_energy = _rim_base * rim_mult
			if core != null: core.light_energy = _core_base * core_mult

	if _ambience != null:
		var particles: GPUParticles3D = _ambience.get_node_or_null("EntranceParticles") as GPUParticles3D
		if particles != null:
			particles.amount = int(_particle_amount_base * part_mult)


func _tween(target: Object, property: StringName, value: Variant) -> void:
	var tw: Tween = create_tween()
	tw.tween_property(target, property, value, TWEEN_DURATION)


# === EVENTS ===

func _on_weather_changed(weather_id: StringName) -> void:
	_apply_weather(weather_id, true)


# === HELPERS ===

func _current_weather() -> StringName:
	if not has_node("/root/WeatherController"):
		return &"clear"
	var wc: Node = get_node("/root/WeatherController")
	if "current_weather_id" in wc:
		return StringName(wc.current_weather_id)
	return &"clear"
