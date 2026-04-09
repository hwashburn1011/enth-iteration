class_name BossSlamDustEmitter
extends Node3D

## Slam impact dust + debris emitter for the Compiler boss (Epic 07 task 33).
## Spawns a single-shot burst of dust + chunked debris when the boss's
## ground slam attack hits the floor. Designed to be reusable across all
## 4 Compiler boss arms (UR/UL/LR/LL) and the phase-3 8-arm variant.
##
## Behavior:
##   1) On emit() call, spawns 2 GPUParticles3D bursts:
##      - DUST: dense low-velocity ground-spreading cloud (8m radius)
##      - DEBRIS: 24 high-velocity rigid chunks that arc outward and
##        bounce on the arena floor
##   2) Plays an audio cue via SfxManager (boss_slam_impact)
##   3) Spawns a 4m radius decal scorch mark at the impact point that
##      fades over 12 seconds
##   4) Auto-cleans up after the longest particle lifetime
##
## Required scene shape:
##   BossSlamDustEmitter (Node3D + this script)
##     [child auto-spawned] DustParticles (GPUParticles3D)
##     [child auto-spawned] DebrisParticles (GPUParticles3D)
##     [child auto-spawned] ScorchDecal (Decal)
##
## Hookup from boss controller:
##   var dust: BossSlamDustEmitter = preload("res://scenes/effects/boss_slam_dust.tscn").instantiate()
##   dust.global_position = impact_world_pos
##   get_tree().current_scene.add_child(dust)
##   dust.emit()

@export var dust_burst_count: int = 80
@export var debris_chunk_count: int = 24
@export var slam_radius_m: float = 4.0
@export var dust_lifetime_s: float = 2.4
@export var debris_lifetime_s: float = 3.0
@export var scorch_lifetime_s: float = 12.0
@export var scorch_size_m: float = 4.5
@export var dust_color: Color = Color(0.55, 0.55, 0.62, 0.85)
@export var debris_color: Color = Color(0.18, 0.20, 0.24)
@export var auto_emit_on_ready: bool = false

var _dust: GPUParticles3D
var _debris: GPUParticles3D
var _scorch: Decal


func _ready() -> void:
	_build_dust()
	_build_debris()
	_build_scorch()
	if auto_emit_on_ready:
		emit()


func _build_dust() -> void:
	_dust = GPUParticles3D.new()
	_dust.name = "DustParticles"
	_dust.amount = dust_burst_count
	_dust.lifetime = dust_lifetime_s
	_dust.one_shot = true
	_dust.explosiveness = 1.0
	_dust.emitting = false
	_dust.local_coords = false

	var pmat: ParticleProcessMaterial = ParticleProcessMaterial.new()
	pmat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	pmat.emission_sphere_radius = 0.6
	pmat.direction = Vector3(0, 0.5, 0)
	pmat.spread = 75.0
	pmat.initial_velocity_min = 1.5
	pmat.initial_velocity_max = 4.5
	pmat.gravity = Vector3(0, -1.5, 0)
	pmat.linear_accel_min = -1.0
	pmat.linear_accel_max = -0.4
	pmat.scale_min = 0.6
	pmat.scale_max = 1.4
	# Scale curve: small → big → fade
	var scale_curve: Curve = Curve.new()
	scale_curve.add_point(Vector2(0.0, 0.2))
	scale_curve.add_point(Vector2(0.15, 1.4))
	scale_curve.add_point(Vector2(1.0, 0.0))
	var scale_tex: CurveTexture = CurveTexture.new()
	scale_tex.curve = scale_curve
	pmat.scale_curve = scale_tex
	# Color ramp: bright dust → fade to alpha 0
	var grad: Gradient = Gradient.new()
	grad.add_point(0.0, Color(dust_color.r, dust_color.g, dust_color.b, 1.0))
	grad.add_point(0.4, Color(dust_color.r, dust_color.g, dust_color.b, 0.6))
	grad.add_point(1.0, Color(dust_color.r, dust_color.g, dust_color.b, 0.0))
	var grad_tex: GradientTexture1D = GradientTexture1D.new()
	grad_tex.gradient = grad
	pmat.color_ramp = grad_tex

	_dust.process_material = pmat

	# Mesh: a simple billboard quad with an unshaded soft material
	var quad: QuadMesh = QuadMesh.new()
	quad.size = Vector2(1.6, 1.6)
	var mat: StandardMaterial3D = StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	mat.albedo_color = Color(1, 1, 1, 1)
	mat.vertex_color_use_as_albedo = true
	quad.material = mat
	_dust.draw_pass_1 = quad

	add_child(_dust)


func _build_debris() -> void:
	_debris = GPUParticles3D.new()
	_debris.name = "DebrisParticles"
	_debris.amount = debris_chunk_count
	_debris.lifetime = debris_lifetime_s
	_debris.one_shot = true
	_debris.explosiveness = 1.0
	_debris.emitting = false
	_debris.local_coords = false

	var pmat: ParticleProcessMaterial = ParticleProcessMaterial.new()
	pmat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	pmat.emission_sphere_radius = 0.4
	pmat.direction = Vector3(0, 1, 0)
	pmat.spread = 55.0
	pmat.initial_velocity_min = 4.0
	pmat.initial_velocity_max = 9.0
	pmat.gravity = Vector3(0, -14.0, 0)
	pmat.angular_velocity_min = -360.0
	pmat.angular_velocity_max = 360.0
	pmat.scale_min = 0.10
	pmat.scale_max = 0.22
	pmat.color = debris_color

	_debris.process_material = pmat

	# Mesh: small box for chunk
	var box: BoxMesh = BoxMesh.new()
	box.size = Vector3(0.18, 0.18, 0.18)
	var mat: StandardMaterial3D = StandardMaterial3D.new()
	mat.albedo_color = debris_color
	mat.metallic = 0.5
	mat.roughness = 0.85
	box.material = mat
	_debris.draw_pass_1 = box

	add_child(_debris)


func _build_scorch() -> void:
	_scorch = Decal.new()
	_scorch.name = "ScorchDecal"
	_scorch.size = Vector3(scorch_size_m, 1.5, scorch_size_m)
	_scorch.modulate = Color(0.05, 0.05, 0.07, 0.0)
	_scorch.albedo_mix = 0.85
	_scorch.upper_fade = 0.3
	_scorch.lower_fade = 0.3
	add_child(_scorch)


func emit() -> void:
	_dust.emitting = true
	_debris.emitting = true
	_play_scorch()
	_play_audio()
	# Cleanup after the longest particle lifetime + scorch fade
	var ttl: float = max(dust_lifetime_s, debris_lifetime_s) + scorch_lifetime_s
	get_tree().create_timer(ttl).timeout.connect(queue_free)


func _play_scorch() -> void:
	# Fade in over 0.1s, hold, fade out over 1.5s starting at scorch_lifetime - 1.5
	var tw: Tween = create_tween()
	tw.tween_property(_scorch, "modulate:a", 0.85, 0.1)
	tw.tween_interval(scorch_lifetime_s - 1.6)
	tw.tween_property(_scorch, "modulate:a", 0.0, 1.5)


func _play_audio() -> void:
	var sfx: Node = get_node_or_null("/root/SfxManager")
	if sfx != null and sfx.has_method("play"):
		sfx.play(&"boss_slam_impact", global_position)
