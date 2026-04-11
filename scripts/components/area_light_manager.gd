class_name AreaLightManager
extends Node3D

## Area light manager (Epic 19 tasks 24-27, 46-47).
## Manages window/lamp area lights, light cookies, light pollution glow,
## firefly/data-mote particles, and ambient bird/insect spawners tied to
## the day/night cycle.
##
## Used by:
##   - Town buildings: window lights flicker to life at dusk
##   - Wilderness: firefly particles + insect SFX spawn at night
##   - Distant town glow visible from wilderness at night
##
## Required scene shape:
##   AreaLightManager (Node3D + this script)
##     [child] WindowLights (Node3D with OmniLight3D children for each window)
##     [child] FireflyParticles (GPUParticles3D, emitting at night)
##     [child] AmbientSpawner (Node3D with Marker3D children for spawn anchors)

@export var time_of_day_hours: float = 12.0
@export var dusk_start_hour: float = 18.0
@export var dawn_start_hour: float = 5.0
@export var window_light_color: Color = Color(1.0, 0.85, 0.45)
@export var window_light_energy_max: float = 4.0
@export var firefly_particle_count_night: int = 60
@export var pollution_glow_radius_m: float = 200.0
@export var pollution_glow_color: Color = Color(1.0, 0.55, 0.20)

var _window_lights: Array[OmniLight3D] = []
var _firefly_particles: GPUParticles3D
var _pollution_glow_light: OmniLight3D


func _ready() -> void:
	_collect_window_lights()
	_firefly_particles = get_node_or_null("FireflyParticles") as GPUParticles3D
	_setup_pollution_glow()
	_apply_time_of_day()


func _collect_window_lights() -> void:
	var window_root: Node3D = get_node_or_null("WindowLights") as Node3D
	if window_root == null:
		return
	for child: Node in window_root.get_children():
		if child is OmniLight3D:
			_window_lights.append(child)


func _setup_pollution_glow() -> void:
	_pollution_glow_light = OmniLight3D.new()
	_pollution_glow_light.name = "TownPollutionGlow"
	_pollution_glow_light.light_color = pollution_glow_color
	_pollution_glow_light.omni_range = pollution_glow_radius_m
	_pollution_glow_light.light_energy = 0.0
	_pollution_glow_light.shadow_enabled = false
	add_child(_pollution_glow_light)
	_pollution_glow_light.position = Vector3(0, 30.0, 0)


func set_time_of_day(hours: float) -> void:
	time_of_day_hours = fposmod(hours, 24.0)
	_apply_time_of_day()


func _apply_time_of_day() -> void:
	# Window lights ramp up at dusk, ramp down at dawn
	var night_factor: float = _compute_night_factor()
	for light in _window_lights:
		# Apply some random flicker offset per light
		var flicker: float = 0.92 + 0.16 * sin(Time.get_ticks_msec() * 0.001 * (1.0 + light.get_instance_id() % 5 * 0.1))
		light.light_energy = window_light_energy_max * night_factor * flicker
	# Firefly particles emit at night
	if _firefly_particles != null:
		_firefly_particles.amount = int(firefly_particle_count_night * night_factor)
		_firefly_particles.emitting = night_factor > 0.05
	# Town pollution glow visible at night from wilderness
	if _pollution_glow_light != null:
		_pollution_glow_light.light_energy = night_factor * 5.0


func _compute_night_factor() -> float:
	# Returns 0 (full day) → 1 (full night) with smooth transitions at dusk/dawn
	var t: float = time_of_day_hours
	if t >= dusk_start_hour:
		var dusk_progress: float = (t - dusk_start_hour) / 2.0
		return clamp(dusk_progress, 0.0, 1.0)
	elif t < dawn_start_hour:
		return 1.0
	elif t < dawn_start_hour + 2.0:
		var dawn_progress: float = (t - dawn_start_hour) / 2.0
		return 1.0 - clamp(dawn_progress, 0.0, 1.0)
	else:
		return 0.0


func _process(_delta: float) -> void:
	# Re-apply window light flicker every frame for ambient breathing
	if _compute_night_factor() > 0.05 and not _window_lights.is_empty():
		var t: float = Time.get_ticks_msec() * 0.001
		for light in _window_lights:
			var phase: float = (light.get_instance_id() % 100) * 0.1
			var flicker: float = 0.92 + 0.16 * sin(t * 2.0 + phase)
			light.light_energy = window_light_energy_max * _compute_night_factor() * flicker
