extends Node
## EnvironmentManager — global lighting/post-process controller. Switches
## WorldEnvironment + DirectionalLight3D values smoothly between presets.
##
## Add to project autoloads as "EnvironmentManager".

signal environment_changed(new_preset_id: StringName)
signal transition_started(from_id: StringName, to_id: StringName)
signal transition_finished(preset_id: StringName)

const TRANSITION_DURATION: float = 1.5

var current_preset_id: StringName = &""
var _world_env: WorldEnvironment
var _sun_light: DirectionalLight3D
var _transition_tween: Tween


func _ready() -> void:
	_subscribe_to_events()


func _subscribe_to_events() -> void:
	if Engine.has_singleton("EventBus") or has_node("/root/EventBus"):
		var bus: Node = get_node("/root/EventBus")
		if bus.has_signal("zone_entered"):
			bus.zone_entered.connect(_on_zone_entered)


func register_world_environment(env: WorldEnvironment) -> void:
	_world_env = env


func register_sun_light(light: DirectionalLight3D) -> void:
	_sun_light = light


func apply_preset(preset_id: StringName, transition: bool = true) -> void:
	var preset: Dictionary = EnvironmentDatabase.get_preset(preset_id)
	if preset.is_empty():
		push_warning("EnvironmentManager: unknown preset %s" % preset_id)
		return
	var prev: StringName = current_preset_id
	current_preset_id = preset_id

	if not transition or _world_env == null:
		_apply_immediate(preset)
	else:
		transition_started.emit(prev, preset_id)
		_apply_with_tween(preset)

	environment_changed.emit(preset_id)


func _apply_immediate(preset: Dictionary) -> void:
	if _world_env == null:
		return
	var env: Environment = _world_env.environment
	if env == null:
		env = Environment.new()
		_world_env.environment = env

	# Sky
	if env.sky == null:
		env.sky = Sky.new()
		env.sky.sky_material = ProceduralSkyMaterial.new()
	if env.sky.sky_material is ProceduralSkyMaterial:
		var psm: ProceduralSkyMaterial = env.sky.sky_material
		psm.sky_horizon_color = preset.get("sky_horizon_color", Color.WHITE)
		psm.sky_top_color = preset.get("sky_top_color", Color.WHITE)
		psm.ground_horizon_color = preset.get("sky_ground_color", Color.BLACK)
		psm.energy_multiplier = preset.get("sky_energy", 1.0)

	# Ambient
	env.ambient_light_color = preset.get("ambient_color", Color.WHITE)
	env.ambient_light_energy = preset.get("ambient_energy", 0.5)

	# Fog
	env.fog_enabled = preset.get("fog_enabled", false)
	if env.fog_enabled:
		env.fog_light_color = preset.get("fog_color", Color.WHITE)
		env.fog_density = preset.get("fog_density", 0.01)
		env.fog_height_density = preset.get("fog_height_falloff", 0.1)

	# Volumetric fog
	env.volumetric_fog_enabled = preset.get("vfog_enabled", false)
	if env.volumetric_fog_enabled:
		env.volumetric_fog_density = preset.get("vfog_density", 0.03)
		env.volumetric_fog_albedo = preset.get("vfog_albedo", Color.WHITE)
		env.volumetric_fog_emission = preset.get("vfog_emission", Color.BLACK)

	# Bloom (Glow)
	env.glow_enabled = preset.get("bloom_enabled", false)
	if env.glow_enabled:
		env.glow_intensity = preset.get("bloom_intensity", 0.5)
		env.glow_strength = preset.get("bloom_strength", 1.0)
		env.glow_hdr_threshold = preset.get("bloom_threshold", 0.5)

	# SSAO
	env.ssao_enabled = preset.get("ssao_enabled", false)
	if env.ssao_enabled:
		env.ssao_radius = preset.get("ssao_radius", 0.5)
		env.ssao_intensity = preset.get("ssao_strength", 0.4)

	# SSR
	env.ssr_enabled = preset.get("ssr_enabled", false)
	if env.ssr_enabled:
		env.ssr_max_steps = preset.get("ssr_samples", 32)

	# SDFGI
	env.sdfgi_enabled = preset.get("sdfgi_enabled", false)
	if env.sdfgi_enabled:
		env.sdfgi_cascades = preset.get("sdfgi_cascades", 1)

	# Tonemap
	env.tonemap_mode = preset.get("tonemapper_mode", 2)
	env.tonemap_exposure = preset.get("exposure", 1.0)

	# Sun light
	if _sun_light != null:
		var sun_enabled: bool = preset.get("sun_enabled", true)
		_sun_light.visible = sun_enabled
		if sun_enabled:
			_sun_light.light_color = preset.get("sun_color", Color.WHITE)
			_sun_light.light_energy = preset.get("sun_energy", 1.5)
			var angles: Vector2 = preset.get("sun_angle_degrees", Vector2(50, 90))
			_sun_light.rotation_degrees = Vector3(-angles.x, angles.y, 0)

	transition_finished.emit(current_preset_id)


func _apply_with_tween(preset: Dictionary) -> void:
	if _transition_tween != null and _transition_tween.is_valid():
		_transition_tween.kill()
	_transition_tween = create_tween()
	_transition_tween.set_parallel(true)
	# Tween sun light over duration; everything else applies immediately
	# (Godot doesn't tween Environment fields cleanly)
	if _sun_light != null:
		_transition_tween.tween_property(_sun_light, "light_color", preset.get("sun_color", Color.WHITE), TRANSITION_DURATION)
		_transition_tween.tween_property(_sun_light, "light_energy", preset.get("sun_energy", 1.5), TRANSITION_DURATION)
	# Apply non-tweenable fields immediately
	_apply_immediate(preset)
	_transition_tween.tween_callback(func() -> void: transition_finished.emit(current_preset_id)).set_delay(TRANSITION_DURATION)


func _on_zone_entered(_zone_id: StringName, environment_preset_id: StringName) -> void:
	if environment_preset_id != &"":
		apply_preset(environment_preset_id)


# === SAVE / LOAD ===

func to_save_data() -> Dictionary:
	return {"current_preset_id": String(current_preset_id)}


func from_save_data(data: Dictionary) -> void:
	current_preset_id = StringName(data.get("current_preset_id", ""))
	if current_preset_id != &"":
		apply_preset(current_preset_id, false)
