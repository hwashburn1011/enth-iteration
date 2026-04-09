class_name NightSkyStarField
extends Node3D

## Global night sky star field. Drop one of these in any outdoor
## scene and it spawns a code-built GPUParticles3D layer of unshaded
## emissive billboard quads that:
##
##   - Tracks the player camera horizontally so the field always
##     surrounds the active view
##   - Reads star_visibility (0..1) from the SkyboxPresetDatabase
##     preset for the current phase via DayNightController
##   - Tweens emission energy + alpha to match the visibility value,
##     so stars fade in at dusk and out at dawn smoothly
##   - Star count + spawn extents scale with the configurable
##     density inspector value
##   - Optional twinkle: per-particle scale wobble via animated
##     scale_curve on the ParticleProcessMaterial
##
## This is the SCENE-LEVEL counterpart to the TowerTopLighting's
## tower-only star field — both use the same emissive billboard
## technique but this one is global and reads from the day/night
## state instead of running per-tower presets.
##
## Required scene shape:
##   NightSkyStarField (Node3D + this script)
##     [no children needed; built at runtime]
##
## Configure via inspector:
##   star_count       — total particles
##   spawn_radius     — meters from the player camera that stars surround
##   star_height      — Y above the player at which stars spawn
##   star_size        — base quad size (twinkle wobble multiplies this)
##   follow_camera    — toggle camera-tracking on/off

@export var star_count: int = 320
@export var spawn_radius: float = 60.0
@export var star_height: float = 25.0
@export var star_size: float = 0.18
@export var follow_camera: bool = true
@export var twinkle_amount: float = 0.5  # 0=no wobble, 1=full wobble

const FADE_DURATION_S: float = 4.0

var _particles: GPUParticles3D
var _star_material: StandardMaterial3D
var _current_visibility: float = 0.0
var _target_visibility: float = 0.0
var _camera: Camera3D
var _fade_tween: Tween


func _ready() -> void:
	_build_field()
	if has_node("/root/DayNightController"):
		var dnc: Node = get_node("/root/DayNightController")
		if dnc.has_signal("phase_changed"):
			dnc.phase_changed.connect(_on_phase_changed)
		if "current_phase" in dnc:
			_apply_visibility_for_phase(StringName(dnc.current_phase), false)
	else:
		_apply_visibility_for_phase(&"night", false)


func _process(_delta: float) -> void:
	if follow_camera:
		_track_camera()


# === BUILD ===

func _build_field() -> void:
	_particles = GPUParticles3D.new()
	_particles.name = "NightStars"
	_particles.amount = star_count
	_particles.lifetime = 60.0
	_particles.preprocess = 30.0
	_particles.visibility_aabb = AABB(
		Vector3(-spawn_radius, -10, -spawn_radius),
		Vector3(spawn_radius * 2.0, spawn_radius, spawn_radius * 2.0)
	)

	# Star quad — small unshaded emissive white billboard
	var quad: QuadMesh = QuadMesh.new()
	quad.size = Vector2(star_size, star_size)
	_star_material = StandardMaterial3D.new()
	_star_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_star_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_star_material.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	_star_material.albedo_color = Color(0.95, 0.96, 1.00, 0.0)  # alpha modulated below
	_star_material.emission_enabled = true
	_star_material.emission = Color(1.0, 1.0, 1.0)
	_star_material.emission_energy_multiplier = 0.0  # ramped by visibility
	quad.surface_set_material(0, _star_material)
	_particles.draw_pass_1 = quad

	var pmat: ParticleProcessMaterial = ParticleProcessMaterial.new()
	pmat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	pmat.emission_box_extents = Vector3(spawn_radius, 1.0, spawn_radius)
	pmat.gravity = Vector3.ZERO
	pmat.initial_velocity_min = 0.0
	pmat.initial_velocity_max = 0.05  # near-still — stars don't drift much
	# Twinkle: per-particle random scale on top of base
	pmat.scale_min = lerp(1.0, 0.5, twinkle_amount)
	pmat.scale_max = lerp(1.0, 1.6, twinkle_amount)
	pmat.color = Color(0.95, 0.96, 1.00)

	_particles.process_material = pmat
	_particles.position = Vector3(0, star_height, 0)
	_particles.emitting = true
	add_child(_particles)


# === VISIBILITY ===

func _apply_visibility_for_phase(phase: StringName, animate: bool) -> void:
	# Map phase → preset id (day uses noon, etc)
	var preset_id: StringName = _phase_to_preset(phase)
	var preset: Dictionary = SkyboxPresetDatabase.get_preset(preset_id)
	if preset.is_empty():
		return
	_target_visibility = float(preset.get("star_visibility", 0.0))
	if animate:
		_tween_to_target()
	else:
		_current_visibility = _target_visibility
		_apply_visibility_now(_current_visibility)


func _phase_to_preset(phase: StringName) -> StringName:
	match phase:
		&"dawn":  return &"dawn"
		&"day":   return &"noon"
		&"dusk":  return &"dusk"
		&"night": return &"night"
	return &"noon"


func _tween_to_target() -> void:
	if _fade_tween != null and _fade_tween.is_valid():
		_fade_tween.kill()
	_fade_tween = create_tween()
	_fade_tween.tween_method(_apply_visibility_now, _current_visibility, _target_visibility, FADE_DURATION_S)
	_fade_tween.tween_callback(func() -> void: _current_visibility = _target_visibility)


func _apply_visibility_now(v: float) -> void:
	_current_visibility = v
	if _star_material == null:
		return
	# Drive both alpha (to fade out cleanly) and emission energy (to brighten)
	var c: Color = _star_material.albedo_color
	_star_material.albedo_color = Color(c.r, c.g, c.b, v)
	_star_material.emission_energy_multiplier = v * 1.6  # max ~1.6 for 1.0 visibility


# === CAMERA TRACK ===

func _track_camera() -> void:
	if _camera == null or not is_instance_valid(_camera):
		_camera = get_viewport().get_camera_3d()
		if _camera == null:
			return
	# Snap horizontal position to camera; height stays fixed offset above ground
	var cam_pos: Vector3 = _camera.global_position
	global_position = Vector3(cam_pos.x, global_position.y, cam_pos.z)


# === EVENTS ===

func _on_phase_changed(phase: StringName) -> void:
	_apply_visibility_for_phase(phase, true)
