class_name CinematicDepthOfField
extends Node

## Cinematic Depth of Field Controller (Epic 49 task 15).
##
## Drives the active Camera3D's CameraAttributesPractical DOF properties
## from a keyframed timeline. Used by CutsceneController during cinematic
## playback to push focus from foreground subject to background reveal.
##
## DOF properties driven:
##   - dof_blur_far_enabled / dof_blur_far_distance / dof_blur_far_transition
##   - dof_blur_near_enabled / dof_blur_near_distance / dof_blur_near_transition
##   - dof_blur_amount (0.0-1.0 strength)
##
## Hook:
##   var dof := CinematicDepthOfField.new()
##   add_child(dof)
##   dof.bind_camera(camera)
##   dof.play_keyframes([
##       {"time": 0.0, "focus": 2.0, "amount": 0.3, "near_distance": 0.1, "far_distance": 5.0},
##       {"time": 2.0, "focus": 8.0, "amount": 0.6, "near_distance": 0.5, "far_distance": 15.0},
##   ])

signal dof_keyframe_reached(index: int)
signal dof_finished

@export var camera_path: NodePath
@export var auto_attach_attributes: bool = true

var _camera: Camera3D
var _attributes: CameraAttributesPractical
var _keyframes: Array[Dictionary] = []
var _elapsed: float = 0.0
var _is_playing: bool = false
var _current_index: int = -1


func _ready() -> void:
	if camera_path != NodePath():
		bind_camera(get_node_or_null(camera_path) as Camera3D)


func bind_camera(camera: Camera3D) -> void:
	if camera == null:
		return
	_camera = camera
	if auto_attach_attributes:
		_ensure_attributes()


func _ensure_attributes() -> void:
	if _camera == null:
		return
	if _camera.attributes == null:
		_attributes = CameraAttributesPractical.new()
		_camera.attributes = _attributes
	elif _camera.attributes is CameraAttributesPractical:
		_attributes = _camera.attributes


func play_keyframes(keyframes: Array[Dictionary]) -> void:
	_keyframes = keyframes.duplicate()
	_keyframes.sort_custom(func(a, b): return float(a.get("time", 0)) < float(b.get("time", 0)))
	_elapsed = 0.0
	_current_index = -1
	_is_playing = true
	set_process(true)
	if not _keyframes.is_empty():
		_apply_keyframe(_keyframes[0])
		_current_index = 0


func stop() -> void:
	_is_playing = false
	set_process(false)
	if _attributes != null:
		_attributes.dof_blur_far_enabled = false
		_attributes.dof_blur_near_enabled = false


func _process(delta: float) -> void:
	if not _is_playing or _attributes == null or _keyframes.is_empty():
		return
	_elapsed += delta

	# Find current keyframe pair
	var next_idx: int = -1
	for i in range(_current_index + 1, _keyframes.size()):
		if float(_keyframes[i].get("time", 0)) >= _elapsed:
			next_idx = i
			break
	if next_idx == -1:
		# Past last keyframe
		_apply_keyframe(_keyframes[_keyframes.size() - 1])
		_is_playing = false
		set_process(false)
		dof_finished.emit()
		return

	var prev_idx: int = max(0, next_idx - 1)
	var prev_kf: Dictionary = _keyframes[prev_idx]
	var next_kf: Dictionary = _keyframes[next_idx]
	var prev_t: float = float(prev_kf.get("time", 0))
	var next_t: float = float(next_kf.get("time", 0))
	var span: float = max(0.001, next_t - prev_t)
	var lerp_t: float = clamp((_elapsed - prev_t) / span, 0.0, 1.0)

	var interpolated: Dictionary = {
		"focus": lerp(float(prev_kf.get("focus", 2.0)), float(next_kf.get("focus", 2.0)), lerp_t),
		"amount": lerp(float(prev_kf.get("amount", 0.3)), float(next_kf.get("amount", 0.3)), lerp_t),
		"near_distance": lerp(float(prev_kf.get("near_distance", 0.5)), float(next_kf.get("near_distance", 0.5)), lerp_t),
		"far_distance": lerp(float(prev_kf.get("far_distance", 10.0)), float(next_kf.get("far_distance", 10.0)), lerp_t),
		"near_transition": lerp(float(prev_kf.get("near_transition", 0.5)), float(next_kf.get("near_transition", 0.5)), lerp_t),
		"far_transition": lerp(float(prev_kf.get("far_transition", 1.0)), float(next_kf.get("far_transition", 1.0)), lerp_t),
	}
	_apply_keyframe(interpolated)

	# Emit signal when crossing into next keyframe
	if prev_idx > _current_index:
		_current_index = prev_idx
		dof_keyframe_reached.emit(_current_index)


func _apply_keyframe(kf: Dictionary) -> void:
	if _attributes == null:
		return
	_attributes.dof_blur_amount = float(kf.get("amount", 0.3))
	_attributes.dof_blur_far_enabled = true
	_attributes.dof_blur_far_distance = float(kf.get("far_distance", 10.0))
	_attributes.dof_blur_far_transition = float(kf.get("far_transition", 1.0))
	_attributes.dof_blur_near_enabled = true
	_attributes.dof_blur_near_distance = float(kf.get("near_distance", 0.5))
	_attributes.dof_blur_near_transition = float(kf.get("near_transition", 0.5))


## Convenience: smoothly transition from rack-focus near→far over `duration` seconds.
func rack_focus(start_focus: float, end_focus: float, duration: float, amount: float = 0.6) -> void:
	play_keyframes([
		{"time": 0.0, "focus": start_focus, "amount": amount, "near_distance": start_focus * 0.5, "far_distance": start_focus * 2.0},
		{"time": duration, "focus": end_focus, "amount": amount, "near_distance": end_focus * 0.5, "far_distance": end_focus * 2.0},
	])
