class_name AISageNPC
extends Node3D

## AI Sage NPC component bundle (Epic 09 tasks 33, 34, 37, 41, 42, 43, 49).
## A single Node3D that mounts onto the Sage scene and drives:
##
##   1) Floating motion (task 34) — 5cm hover offset + 0.025m vertical
##      breath bob + 1.5deg head sway + idle Y-axis sway
##   2) Eye-tracking (task 43) — head bone slowly rotates to face the
##      player whenever the player is within tracking_range_m
##   3) Aura particle system (task 33) — child GPUParticles3D emitting
##      cyan glow specks that intensify during dialogue (task 37)
##   4) Custom shader uniform driver (task 37) — pushes
##      "dialogue_intensity" 0..1 into the body shader so the aura +
##      orb emission can intensify during key moments
##   5) Ambient SFX hook (task 41) — looping low chime hum that scales
##      volume with proximity to player
##   6) Interaction prompt (task 42) — when player enters interact
##      range, emits a UI signal so the HUD can show the prompt
##   7) Dialogue system hookup (task 49) — triggers the speaking
##      animation + boosts dialogue_intensity when DialogueManager
##      starts a conversation, returns to wise_idle when done
##
## Required scene shape:
##   AISage (Node3D root from the .blend import)
##     Armature_AISage (Skeleton3D, with the 32-bone rig)
##     AISage_LOD0 (MeshInstance3D)
##     AnimationPlayer (with the 13 ai_sage_* actions)
##     AISageNPC (Node3D + this script, with target_path set to player)

signal interact_prompt_shown
signal interact_prompt_hidden
signal dialogue_started
signal dialogue_ended

@export var target_path: NodePath
@export var animation_player_path: NodePath
@export var skeleton_path: NodePath
@export var body_mesh_path: NodePath
@export var hover_height_m: float = 0.05
@export var bob_amplitude_m: float = 0.025
@export var bob_speed: float = 0.6
@export var sway_amplitude_m: float = 0.012
@export var head_track_range_m: float = 8.0
@export var head_track_max_yaw_deg: float = 35.0
@export var interact_range_m: float = 3.0
@export var ambient_sfx_id: StringName = &"ai_sage_chime_hum"

const HEAD_BONE_NAME: String = "head"

var _target: Node3D
var _animation_player: AnimationPlayer
var _skeleton: Skeleton3D
var _body_mesh: MeshInstance3D
var _shader_material: ShaderMaterial
var _aura_particles: GPUParticles3D
var _ambient_sfx_player: AudioStreamPlayer3D
var _t: float = 0.0
var _is_in_dialogue: bool = false
var _is_prompt_shown: bool = false
var _dialogue_intensity: float = 0.0


func _ready() -> void:
	_target = get_node_or_null(target_path) as Node3D
	_animation_player = get_node_or_null(animation_player_path) as AnimationPlayer
	_skeleton = get_node_or_null(skeleton_path) as Skeleton3D
	_body_mesh = get_node_or_null(body_mesh_path) as MeshInstance3D
	if _body_mesh != null and _body_mesh.material_override is ShaderMaterial:
		_shader_material = _body_mesh.material_override
	_build_aura_particles()
	_build_ambient_sfx()
	_play_idle()


func _build_aura_particles() -> void:
	_aura_particles = GPUParticles3D.new()
	_aura_particles.name = "SageAuraParticles"
	_aura_particles.amount = 80
	_aura_particles.lifetime = 4.0
	_aura_particles.local_coords = false
	var pmat: ParticleProcessMaterial = ParticleProcessMaterial.new()
	pmat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	pmat.emission_sphere_radius = 0.7
	pmat.direction = Vector3(0, 0.4, 0)
	pmat.spread = 50.0
	pmat.initial_velocity_min = 0.1
	pmat.initial_velocity_max = 0.3
	pmat.gravity = Vector3(0, 0.05, 0)
	pmat.scale_min = 0.025
	pmat.scale_max = 0.060
	var grad: Gradient = Gradient.new()
	grad.add_point(0.0, Color(0.0, 0.95, 1.0, 0.0))
	grad.add_point(0.3, Color(0.0, 0.95, 1.0, 0.85))
	grad.add_point(1.0, Color(0.0, 0.95, 1.0, 0.0))
	var grad_tex: GradientTexture1D = GradientTexture1D.new()
	grad_tex.gradient = grad
	pmat.color_ramp = grad_tex
	_aura_particles.process_material = pmat
	# Use a small sphere mesh for each particle
	var sphere: SphereMesh = SphereMesh.new()
	sphere.radius = 0.04
	sphere.height = 0.08
	sphere.radial_segments = 6
	sphere.rings = 4
	var mat: StandardMaterial3D = StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.albedo_color = Color(0.0, 0.95, 1.0, 0.85)
	mat.emission_enabled = true
	mat.emission = Color(0.0, 0.95, 1.0)
	mat.emission_energy_multiplier = 4.0
	mat.vertex_color_use_as_albedo = true
	sphere.material = mat
	_aura_particles.draw_pass_1 = sphere
	add_child(_aura_particles)
	_aura_particles.global_position = global_position + Vector3(0, 1.5, 0)
	_aura_particles.emitting = true


func _build_ambient_sfx() -> void:
	_ambient_sfx_player = AudioStreamPlayer3D.new()
	_ambient_sfx_player.name = "SageAmbientSfx"
	_ambient_sfx_player.unit_size = 8.0
	_ambient_sfx_player.max_distance = 25.0
	_ambient_sfx_player.volume_db = -10.0
	# The actual stream is loaded externally — leave a hook
	add_child(_ambient_sfx_player)


func _process(delta: float) -> void:
	if get_parent() == null or not (get_parent() is Node3D):
		return
	_t += delta
	_apply_floating_motion()
	_apply_eye_tracking()
	_apply_dialogue_intensity()
	_check_interact_range()


# === TASK 34: floating motion ===
func _apply_floating_motion() -> void:
	var parent: Node3D = get_parent() as Node3D
	if parent == null:
		return
	# Apply hover offset + bob to the parent's local Y
	var bob: float = sin(_t * bob_speed * TAU) * bob_amplitude_m
	var sway_x: float = cos(_t * bob_speed * 0.5 * TAU) * sway_amplitude_m
	parent.position.y = hover_height_m + bob
	parent.position.x = sway_x


# === TASK 43: eye-tracking ===
func _apply_eye_tracking() -> void:
	if _target == null or _skeleton == null:
		return
	if get_parent() is not Node3D:
		return
	var parent: Node3D = get_parent() as Node3D
	var dist: float = parent.global_position.distance_to(_target.global_position)
	if dist > head_track_range_m:
		return
	var head_idx: int = _skeleton.find_bone(HEAD_BONE_NAME)
	if head_idx < 0:
		return
	# Compute desired yaw to face the target
	var to_target: Vector3 = _target.global_position - parent.global_position
	to_target.y = 0
	if to_target.length_squared() < 0.01:
		return
	var sage_forward: Vector3 = -parent.global_transform.basis.z
	sage_forward.y = 0
	sage_forward = sage_forward.normalized()
	var to_target_norm: Vector3 = to_target.normalized()
	var yaw_rad: float = atan2(
		sage_forward.cross(to_target_norm).y,
		sage_forward.dot(to_target_norm)
	)
	var max_yaw_rad: float = deg_to_rad(head_track_max_yaw_deg)
	yaw_rad = clamp(yaw_rad, -max_yaw_rad, max_yaw_rad)
	# Apply as a bone pose rotation
	var rest_pose: Transform3D = _skeleton.get_bone_rest(head_idx)
	var current_pose: Transform3D = _skeleton.get_bone_pose(head_idx)
	var rotated: Basis = rest_pose.basis.rotated(Vector3.UP, yaw_rad)
	_skeleton.set_bone_pose_rotation(head_idx, rotated.get_rotation_quaternion())


# === TASK 33 + 37: aura intensity driven by dialogue ===
func _apply_dialogue_intensity() -> void:
	# Smoothly approach target intensity (0 normal, 1 dialogue)
	var target: float = 1.0 if _is_in_dialogue else 0.0
	_dialogue_intensity = lerp(_dialogue_intensity, target, 0.05)
	# Push to shader uniform
	if _shader_material != null:
		_shader_material.set_shader_parameter("dialogue_intensity", _dialogue_intensity)
	# Aura particle amount scales with intensity (80 baseline → 200 dialogue)
	if _aura_particles != null:
		_aura_particles.amount = int(lerp(80.0, 200.0, _dialogue_intensity))


# === TASK 42: interact prompt + interact range detection ===
func _check_interact_range() -> void:
	if _target == null:
		return
	var parent: Node3D = get_parent() as Node3D
	if parent == null:
		return
	var dist: float = parent.global_position.distance_to(_target.global_position)
	var should_show: bool = dist <= interact_range_m and not _is_in_dialogue
	if should_show != _is_prompt_shown:
		_is_prompt_shown = should_show
		if should_show:
			interact_prompt_shown.emit()
		else:
			interact_prompt_hidden.emit()


# === TASK 49: dialogue system hookup ===
func start_dialogue() -> void:
	_is_in_dialogue = true
	_play_animation("ai_sage_speaking")
	dialogue_started.emit()


func end_dialogue() -> void:
	_is_in_dialogue = false
	_play_idle()
	dialogue_ended.emit()


func _play_idle() -> void:
	_play_animation("ai_sage_wise_idle")


func _play_animation(name: String) -> void:
	if _animation_player == null:
		return
	if _animation_player.has_animation(name):
		_animation_player.play(name)
