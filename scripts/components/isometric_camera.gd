class_name IsometricCamera
extends Camera3D
## Orthographic isometric camera that smoothly follows a target node.

@export var target: Node3D
@export var follow_speed: float = 8.0
## R5 fix: was 13.0 — character was barely visible. 8.0 puts the player at ~10% of
## screen height instead of ~6%, while still showing enough room context for ARPG combat.
@export var camera_size: float = 8.0
@export var offset: Vector3 = Vector3.ZERO

## Fixed camera arm offset — positions camera above and behind target at isometric angle.
## R5 fix: was (10, 14, 10) — too steep, hid the character behind walls. New angle
## is shallower (more "above and slightly forward") so wall occlusion is reduced.
var _camera_arm: Vector3 = Vector3(7, 10, 7)
var _shake_intensity: float = 0.0
var _shake_decay: float = 5.0
var _lean_offset: Vector3 = Vector3.ZERO
const LEAN_STRENGTH: float = 1.2
const LEAN_RESPONSIVENESS: float = 3.0


func _ready() -> void:
	projection = PROJECTION_ORTHOGONAL
	size = camera_size
	# Position camera at the arm offset and look toward origin
	if target:
		global_position = target.global_position + _camera_arm
	else:
		global_position = _camera_arm
	look_at(target.global_position if target else Vector3.ZERO, Vector3.UP)


func _process(delta: float) -> void:
	if target == null:
		return
	# Calculate lean based on target velocity (for player CharacterBody3D)
	var target_lean: Vector3 = Vector3.ZERO
	if target is CharacterBody3D:
		var vel: Vector3 = (target as CharacterBody3D).velocity
		vel.y = 0.0
		if vel.length() > 0.5:
			target_lean = vel.normalized() * LEAN_STRENGTH
	_lean_offset = _lean_offset.lerp(target_lean, LEAN_RESPONSIVENESS * delta)

	var desired_pos: Vector3 = target.global_position + offset + _camera_arm + _lean_offset
	# Apply screen shake
	if _shake_intensity > 0.0:
		desired_pos += Vector3(
			randf_range(-_shake_intensity, _shake_intensity),
			randf_range(-_shake_intensity, _shake_intensity) * 0.5,
			randf_range(-_shake_intensity, _shake_intensity)
		)
		_shake_intensity = maxf(0.0, _shake_intensity - _shake_decay * delta)
	global_position = global_position.lerp(desired_pos, follow_speed * delta)
	# Keep looking at target (with lean)
	look_at(target.global_position + offset + _lean_offset * 0.3, Vector3.UP)


func shake(intensity: float = 0.15, decay: float = 5.0) -> void:
	_shake_intensity = intensity
	_shake_decay = decay


func zoom_pulse(in_size: float = 11.0, duration: float = 0.3) -> void:
	## Briefly zoom in then out for dramatic effect
	var tween: Tween = create_tween()
	tween.tween_property(self, "size", in_size, duration * 0.4).set_ease(Tween.EASE_OUT)
	tween.tween_interval(duration * 0.2)
	tween.tween_property(self, "size", camera_size, duration * 0.4).set_ease(Tween.EASE_IN)


func zoom_to(target_size: float, duration: float = 0.5) -> void:
	## Smoothly zoom to a target size and stay there
	var tween: Tween = create_tween()
	tween.tween_property(self, "size", target_size, duration).set_ease(Tween.EASE_IN_OUT)


func zoom_reset(duration: float = 0.5) -> void:
	## Smoothly return to default camera_size
	var tween: Tween = create_tween()
	tween.tween_property(self, "size", camera_size, duration).set_ease(Tween.EASE_IN_OUT)
