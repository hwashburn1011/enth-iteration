class_name TowerTopLighting
extends Node3D

## The Tower Top is the highest point in town — it needs its own
## dedicated atmospheric rig because the wilderness lighting director
## doesn't reach interior tower scenes. This component spawns:
##
##   1. AmbientFill (DirectionalLight3D, no shadow) — fills the
##      observation deck so the floor and railings read clean
##   2. KeyLight (DirectionalLight3D, shadow_enabled) — the dramatic
##      sun/moon light that throws long shadows of the railing
##   3. StarField (GPUParticles3D, night only) — drifting white
##      points overhead, the visible "you're standing in the sky"
##   4. WindWhip (GPUParticles3D, always on) — long horizontal
##      streaks of cloud-stuff blowing past the deck
##
## Per-phase profiles tune all four. The component listens to
## DayNightController.phase_changed and crossfades over 4 seconds.
##
## Required scene shape:
##   TowerTopLighting (Node3D + this script)
##     [no children needed; lights + particles built at runtime]

const PHASE_PROFILES: Dictionary = {
	&"dawn": {
		"key_color":     Color(1.00, 0.78, 0.52),
		"key_energy":    2.6,
		"key_angle_deg": Vector2(8, 95),  # x=elevation, y=azimuth
		"ambient_color": Color(0.62, 0.55, 0.55),
		"ambient_energy": 0.55,
		"sky_horizon":   Color(1.00, 0.65, 0.45),
		"star_emission": 0.0,
		"wind_strength": 0.6,
	},
	&"day": {
		"key_color":     Color(1.00, 0.96, 0.85),
		"key_energy":    4.0,
		"key_angle_deg": Vector2(60, 100),
		"ambient_color": Color(0.62, 0.65, 0.68),
		"ambient_energy": 0.70,
		"sky_horizon":   Color(0.70, 0.85, 0.98),
		"star_emission": 0.0,
		"wind_strength": 0.45,
	},
	&"dusk": {
		"key_color":     Color(1.00, 0.55, 0.30),
		"key_energy":    2.4,
		"key_angle_deg": Vector2(6, 270),
		"ambient_color": Color(0.55, 0.40, 0.45),
		"ambient_energy": 0.55,
		"sky_horizon":   Color(1.00, 0.42, 0.25),
		"star_emission": 0.10,  # very faint stars start at dusk
		"wind_strength": 0.7,
	},
	&"night": {
		"key_color":     Color(0.50, 0.62, 0.85),
		"key_energy":    0.95,
		"key_angle_deg": Vector2(-30, 90),
		"ambient_color": Color(0.10, 0.13, 0.22),
		"ambient_energy": 0.25,
		"sky_horizon":   Color(0.04, 0.06, 0.12),
		"star_emission": 1.6,  # starfield bright at night
		"wind_strength": 0.85,
	},
}

const TWEEN_DURATION_S: float = 4.0

@export var star_count: int = 220
@export var wind_count: int = 60

var _key_light: DirectionalLight3D
var _ambient_fill: DirectionalLight3D
var _star_field: GPUParticles3D
var _wind_whip: GPUParticles3D
var _star_material: StandardMaterial3D
var _current_phase: StringName = &"day"
var _tweens: Dictionary = {}


func _ready() -> void:
	_build_lights()
	_build_star_field()
	_build_wind_whip()
	if has_node("/root/DayNightController"):
		var dnc: Node = get_node("/root/DayNightController")
		if dnc.has_signal("phase_changed"):
			dnc.phase_changed.connect(_on_phase_changed)
		if "current_phase" in dnc:
			_current_phase = StringName(dnc.current_phase)
	_apply_profile(_current_phase, false)


# === BUILD ===

func _build_lights() -> void:
	_key_light = DirectionalLight3D.new()
	_key_light.name = "KeyLight"
	_key_light.shadow_enabled = true
	add_child(_key_light)

	_ambient_fill = DirectionalLight3D.new()
	_ambient_fill.name = "AmbientFill"
	_ambient_fill.shadow_enabled = false
	# Fill from the opposite hemisphere
	_ambient_fill.rotation_degrees = Vector3(45, 220, 0)
	add_child(_ambient_fill)


func _build_star_field() -> void:
	_star_field = GPUParticles3D.new()
	_star_field.name = "StarField"
	_star_field.amount = star_count
	_star_field.lifetime = 18.0
	_star_field.preprocess = 9.0
	_star_field.visibility_aabb = AABB(Vector3(-30, 5, -30), Vector3(60, 50, 60))

	# Quad mesh for the star points, billboarded, emissive white
	var quad: QuadMesh = QuadMesh.new()
	quad.size = Vector2(0.18, 0.18)
	_star_material = StandardMaterial3D.new()
	_star_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_star_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_star_material.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	_star_material.albedo_color = Color(0.95, 0.96, 1.00, 0.9)
	_star_material.emission_enabled = true
	_star_material.emission = Color(1.0, 1.0, 1.0)
	_star_material.emission_energy_multiplier = 1.6
	quad.surface_set_material(0, _star_material)
	_star_field.draw_pass_1 = quad

	var mat: ParticleProcessMaterial = ParticleProcessMaterial.new()
	mat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	mat.emission_box_extents = Vector3(28, 0.5, 28)
	mat.gravity = Vector3.ZERO
	mat.initial_velocity_min = 0.05
	mat.initial_velocity_max = 0.15
	mat.scale_min = 0.6
	mat.scale_max = 1.4
	mat.color = Color(0.95, 0.96, 1.00)
	_star_field.process_material = mat
	_star_field.position = Vector3(0, 18, 0)
	_star_field.emitting = true
	add_child(_star_field)


func _build_wind_whip() -> void:
	_wind_whip = GPUParticles3D.new()
	_wind_whip.name = "WindWhip"
	_wind_whip.amount = wind_count
	_wind_whip.lifetime = 4.0
	_wind_whip.preprocess = 2.0
	_wind_whip.visibility_aabb = AABB(Vector3(-25, -5, -25), Vector3(50, 20, 50))

	var quad: QuadMesh = QuadMesh.new()
	quad.size = Vector2(2.0, 0.05)
	var mat: StandardMaterial3D = StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	mat.albedo_color = Color(0.92, 0.92, 0.96, 0.30)
	quad.surface_set_material(0, mat)
	_wind_whip.draw_pass_1 = quad

	var pmat: ParticleProcessMaterial = ParticleProcessMaterial.new()
	pmat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	pmat.emission_box_extents = Vector3(20, 4, 20)
	pmat.gravity = Vector3.ZERO
	pmat.initial_velocity_min = 5.0
	pmat.initial_velocity_max = 9.0
	pmat.direction = Vector3(1, 0, 0.3)
	pmat.spread = 8.0
	pmat.scale_min = 0.5
	pmat.scale_max = 1.4
	pmat.color = Color(0.92, 0.92, 0.96, 0.30)
	_wind_whip.process_material = pmat
	_wind_whip.position = Vector3(0, 4, 0)
	_wind_whip.emitting = true
	add_child(_wind_whip)


# === APPLY ===

func _apply_profile(phase: StringName, animate: bool) -> void:
	var profile: Dictionary = PHASE_PROFILES.get(phase, PHASE_PROFILES[&"day"])

	# Key light
	var angle: Vector2 = profile.get("key_angle_deg", Vector2(60, 95))
	_key_light.rotation_degrees = Vector3(-angle.x, angle.y, 0)
	if animate:
		_tween(_key_light, &"light_color",  profile.get("key_color", Color.WHITE))
		_tween(_key_light, &"light_energy", float(profile.get("key_energy", 3.0)))
		_tween(_ambient_fill, &"light_color",  profile.get("ambient_color", Color.WHITE))
		_tween(_ambient_fill, &"light_energy", float(profile.get("ambient_energy", 0.5)))
	else:
		_key_light.light_color = profile.get("key_color", Color.WHITE)
		_key_light.light_energy = float(profile.get("key_energy", 3.0))
		_ambient_fill.light_color = profile.get("ambient_color", Color.WHITE)
		_ambient_fill.light_energy = float(profile.get("ambient_energy", 0.5))

	# Star field emission energy (and toggle visibility for day/dawn)
	if _star_material != null:
		var star_e: float = float(profile.get("star_emission", 0.0))
		if animate:
			var tw: Tween = create_tween()
			tw.tween_property(_star_material, "emission_energy_multiplier", star_e, TWEEN_DURATION_S)
		else:
			_star_material.emission_energy_multiplier = star_e
	if _star_field != null:
		_star_field.visible = profile.get("star_emission", 0.0) > 0.05

	# Wind whip strength (scale particle initial velocity envelope)
	if _wind_whip != null:
		var pmat: ParticleProcessMaterial = _wind_whip.process_material as ParticleProcessMaterial
		if pmat != null:
			var strength: float = float(profile.get("wind_strength", 0.5))
			pmat.initial_velocity_min = 5.0 * strength
			pmat.initial_velocity_max = 9.0 * strength


func _tween(obj: Object, property: StringName, value: Variant) -> void:
	if _tweens.has([obj, property]):
		var prev: Tween = _tweens[[obj, property]]
		if is_instance_valid(prev):
			prev.kill()
	var tw: Tween = create_tween()
	tw.tween_property(obj, property, value, TWEEN_DURATION_S)
	_tweens[[obj, property]] = tw


# === EVENTS ===

func _on_phase_changed(phase: StringName) -> void:
	_current_phase = phase
	_apply_profile(phase, true)
