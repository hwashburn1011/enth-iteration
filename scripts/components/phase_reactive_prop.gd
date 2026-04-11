class_name PhaseReactiveProp
extends Node3D

## Drop-in component that makes any prop visually react to the day-night
## phase. The wilderness is full of props that need this — bioluminescent
## mushroom rings that only glow at night, water lilies that close at
## dusk, sunpetals that follow the sun, lanterns that ignite at dusk,
## glow moss patches that hide during the day.
##
## Configure ANY combination of:
##   - visibility_by_phase: hide the prop entirely in some phases
##   - emission_by_phase: per-phase emission color/energy on a target mat
##   - animation_by_phase: play an AnimationPlayer track per phase
##   - rotate_to_sun: tilts the prop's local Y axis toward the sun light
##   - light_node: enables a child Light3D in some phases only
##
## Required scene shape:
##   PhaseReactiveProp (Node3D + this script)
##     [target meshes / lights / animation player as children]
##
## Configure via inspector — every section is independent.

signal phase_state_applied(phase: StringName)

@export_group("Visibility")
@export var visibility_by_phase: Dictionary = {}  ## phase → bool
@export var fade_duration_s: float = 1.0

@export_group("Emission")
@export var target_mesh: NodePath          ## MeshInstance3D whose surface[0] override material gets edited
@export var emission_by_phase: Dictionary = {}  ## phase → Color
@export var emission_energy_by_phase: Dictionary = {}  ## phase → float

@export_group("Animation")
@export var animation_player: NodePath
@export var animation_by_phase: Dictionary = {}  ## phase → animation name (StringName)

@export_group("Light")
@export var light_node: NodePath
@export var light_enabled_by_phase: Dictionary = {}  ## phase → bool

@export_group("Sun rotation")
@export var rotate_to_sun: bool = false
@export var rotate_axis: Vector3 = Vector3.UP

var _current_phase: StringName = &"day"
var _override_mat: StandardMaterial3D
var _fade_tween: Tween


func _ready() -> void:
	if has_node("/root/DayNightController"):
		var dnc: Node = get_node("/root/DayNightController")
		if dnc.has_signal("phase_changed"):
			dnc.phase_changed.connect(_on_phase_changed)
		if "current_phase" in dnc:
			_current_phase = StringName(dnc.current_phase)
	_apply_phase_state(_current_phase, false)


func _process(_delta: float) -> void:
	if rotate_to_sun:
		_apply_sun_rotation()


# === STATE APPLICATION ===

func _apply_phase_state(phase: StringName, animate: bool) -> void:
	# Visibility
	if visibility_by_phase.has(phase):
		var should_be_visible: bool = bool(visibility_by_phase[phase])
		if animate and fade_duration_s > 0.0:
			_fade_visibility(should_be_visible)
		else:
			visible = should_be_visible

	# Emission on target mesh
	if emission_by_phase.has(phase) or emission_energy_by_phase.has(phase):
		_apply_emission(phase, animate)

	# Animation
	if animation_by_phase.has(phase):
		_apply_animation(phase)

	# Light enable/disable
	if light_enabled_by_phase.has(phase):
		_apply_light(phase)

	phase_state_applied.emit(phase)


func _apply_emission(phase: StringName, animate: bool) -> void:
	var mesh: MeshInstance3D = get_node_or_null(target_mesh) as MeshInstance3D
	if mesh == null:
		return
	if _override_mat == null:
		var src_mat: Material = mesh.get_surface_override_material(0)
		if src_mat == null and mesh.mesh != null:
			src_mat = mesh.mesh.surface_get_material(0)
		if src_mat is StandardMaterial3D:
			_override_mat = (src_mat as StandardMaterial3D).duplicate() as StandardMaterial3D
		else:
			_override_mat = StandardMaterial3D.new()
		mesh.set_surface_override_material(0, _override_mat)

	var target_color: Color = emission_by_phase.get(phase, _override_mat.emission)
	var target_energy: float = float(emission_energy_by_phase.get(phase, _override_mat.emission_energy_multiplier))

	_override_mat.emission_enabled = target_energy > 0.001 or target_color != Color.BLACK

	if animate and fade_duration_s > 0.0:
		if _fade_tween != null and _fade_tween.is_valid():
			_fade_tween.kill()
		_fade_tween = create_tween()
		_fade_tween.set_parallel(true)
		_fade_tween.tween_property(_override_mat, "emission", target_color, fade_duration_s)
		_fade_tween.tween_property(_override_mat, "emission_energy_multiplier", target_energy, fade_duration_s)
	else:
		_override_mat.emission = target_color
		_override_mat.emission_energy_multiplier = target_energy


func _apply_animation(phase: StringName) -> void:
	var ap: AnimationPlayer = get_node_or_null(animation_player) as AnimationPlayer
	if ap == null:
		return
	var anim_name: StringName = animation_by_phase.get(phase, &"")
	if anim_name == &"":
		return
	if ap.has_animation(anim_name):
		ap.play(anim_name)


func _apply_light(phase: StringName) -> void:
	var light: Light3D = get_node_or_null(light_node) as Light3D
	if light == null:
		return
	light.visible = bool(light_enabled_by_phase[phase])


func _apply_sun_rotation() -> void:
	var sun: DirectionalLight3D = _find_sun_light()
	if sun == null:
		return
	# Project sun direction onto the rotate_axis plane and aim our local
	# Y at it (or whichever axis is configured).
	var sun_dir: Vector3 = -sun.global_transform.basis.z
	var axis: Vector3 = rotate_axis.normalized()
	var projected: Vector3 = (sun_dir - axis * sun_dir.dot(axis)).normalized()
	if projected.length_squared() < 0.001:
		return
	var current_basis: Basis = global_transform.basis
	var target_basis: Basis = Basis.looking_at(projected, axis)
	global_transform.basis = current_basis.slerp(target_basis, 0.05)


func _find_sun_light() -> DirectionalLight3D:
	var root: Node = get_tree().current_scene
	if root == null:
		return null
	return _find_first_directional(root)


func _find_first_directional(node: Node) -> DirectionalLight3D:
	if node is DirectionalLight3D:
		return node as DirectionalLight3D
	for child in node.get_children():
		var found: DirectionalLight3D = _find_first_directional(child)
		if found != null:
			return found
	return null


# === FADE VISIBILITY ===

func _fade_visibility(target_visible: bool) -> void:
	if target_visible:
		visible = true
		modulate = Color(modulate.r, modulate.g, modulate.b, 0.0) if "modulate" in self else modulate
	if _fade_tween != null and _fade_tween.is_valid():
		_fade_tween.kill()
	_fade_tween = create_tween()
	# Node3D doesn't have modulate; use a custom callback that scales each
	# child mesh's surface override alpha. For simplicity in the engine, we
	# just hard-toggle visibility after a short timer if modulate isn't
	# applicable.
	_fade_tween.tween_callback(func() -> void:
		visible = target_visible
	).set_delay(fade_duration_s if target_visible else 0.0)


# === EVENTS ===

func _on_phase_changed(phase: StringName) -> void:
	_current_phase = phase
	_apply_phase_state(phase, true)
