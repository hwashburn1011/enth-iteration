class_name IsometricCamera
extends Camera3D
## Orthographic isometric camera that smoothly follows a target node.

@export var target: Node3D
@export var follow_speed: float = 8.0
## R5 fix: was 13.0 — character was barely visible. 8.0 puts the player at ~10% of
## screen height instead of ~6%, while still showing enough room context for ARPG combat.
@export var camera_size: float = 8.0
@export var offset: Vector3 = Vector3.ZERO

## Mouse wheel zoom range. Tighter than 5 hides too much room context;
## wider than 22 makes the player visually disappear into a sea of props.
const ZOOM_MIN: float = 5.0
const ZOOM_MAX: float = 22.0
const ZOOM_STEP: float = 1.5
const ZOOM_LERP_SPEED: float = 12.0

## Camera collision pull-in. When a wall sits between the camera arm
## anchor and the player, raycast from the player up the arm and pull the
## camera to the first hit (minus a small backoff) so the wall is behind
## the camera instead of occluding the player. Mask 1 = world geometry.
const COLLISION_BACKOFF: float = 0.4
const COLLISION_MASK: int = 1

## Fixed camera arm offset — positions camera above and behind target at isometric angle.
## R5 fix: was (10, 14, 10) — too steep, hid the character behind walls. New angle
## is shallower (more "above and slightly forward") so wall occlusion is reduced.
var _camera_arm: Vector3 = Vector3(7, 10, 7)
var _shake_intensity: float = 0.0
var _shake_decay: float = 5.0
var _lean_offset: Vector3 = Vector3.ZERO
var _target_size: float = 0.0
const LEAN_STRENGTH: float = 1.2
const LEAN_RESPONSIVENESS: float = 3.0


func _ready() -> void:
	projection = PROJECTION_ORTHOGONAL
	size = camera_size
	_target_size = camera_size
	# Position camera at the arm offset and look toward origin
	if target:
		global_position = target.global_position + _camera_arm
	else:
		global_position = _camera_arm
	look_at(target.global_position if target else Vector3.ZERO, Vector3.UP)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		var mb: InputEventMouseButton = event as InputEventMouseButton
		# Phase 4 #38 — read zoom speed override from settings if present
		var step: float = float(ProjectSettings.get_setting("application/zoom_speed_override", ZOOM_STEP))
		if mb.button_index == MOUSE_BUTTON_WHEEL_UP:
			_target_size = clampf(_target_size - step, ZOOM_MIN, ZOOM_MAX)
			get_viewport().set_input_as_handled()
		elif mb.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_target_size = clampf(_target_size + step, ZOOM_MIN, ZOOM_MAX)
			get_viewport().set_input_as_handled()


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
	# Camera collision: if a wall sits on the line from the player to the
	# desired camera position, pull the camera in to the first hit point
	# (minus a small backoff) so the wall ends up behind the camera and
	# stops occluding the player. Cheap raycast each frame; the camera
	# arm springs back to its full length the moment line-of-sight clears.
	var anchor: Vector3 = target.global_position + offset + Vector3(0, 0.8, 0)
	var space: PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
	if space != null:
		var query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(anchor, desired_pos)
		query.collision_mask = COLLISION_MASK
		query.collide_with_areas = false
		var hit: Dictionary = space.intersect_ray(query)
		if not hit.is_empty():
			var hit_pos: Vector3 = hit["position"] as Vector3
			var dir: Vector3 = (desired_pos - anchor).normalized()
			desired_pos = hit_pos - dir * COLLISION_BACKOFF
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
	# Smooth lerp toward the wheel-zoom target size. Tween-based zoom calls
	# (zoom_pulse / zoom_to / zoom_reset) tween `size` directly so they
	# override this lerp for the duration of the tween — when the tween ends
	# they leave `size` at the new value, and the lerp catches up to
	# whatever _target_size is afterwards. The mouse wheel only updates
	# _target_size, never tweens, so the two paths don't fight each other.
	if absf(size - _target_size) > 0.001:
		size = lerp(size, _target_size, clampf(ZOOM_LERP_SPEED * delta, 0.0, 1.0))


func shake(intensity: float = 0.15, decay: float = 5.0) -> void:
	_shake_intensity = intensity
	_shake_decay = decay


func zoom_pulse(in_size: float = 11.0, duration: float = 0.3) -> void:
	## Briefly zoom in then out for dramatic effect
	var tween: Tween = create_tween()
	tween.tween_property(self, "size", in_size, duration * 0.4).set_ease(Tween.EASE_OUT)
	tween.tween_interval(duration * 0.2)
	tween.tween_property(self, "size", _target_size, duration * 0.4).set_ease(Tween.EASE_IN)


func zoom_to(target_size: float, duration: float = 0.5) -> void:
	## Smoothly zoom to a target size and stay there. Updates _target_size
	## so subsequent wheel inputs apply on top of the new baseline.
	_target_size = target_size
	var tween: Tween = create_tween()
	tween.tween_property(self, "size", target_size, duration).set_ease(Tween.EASE_IN_OUT)


func zoom_reset(duration: float = 0.5) -> void:
	## Smoothly return to default camera_size
	_target_size = camera_size
	var tween: Tween = create_tween()
	tween.tween_property(self, "size", camera_size, duration).set_ease(Tween.EASE_IN_OUT)
