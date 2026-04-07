class_name IsometricCamera
extends Camera3D
## Orthographic isometric camera that smoothly follows a target node.

@export var target: Node3D
@export var follow_speed: float = 8.0
@export var camera_size: float = 13.0
@export var offset: Vector3 = Vector3.ZERO

## Fixed camera arm offset — positions camera above and behind target at isometric angle
var _camera_arm: Vector3 = Vector3(10, 14, 10)
var _shake_intensity: float = 0.0
var _shake_decay: float = 5.0


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
	var desired_pos: Vector3 = target.global_position + offset + _camera_arm
	# Apply screen shake
	if _shake_intensity > 0.0:
		desired_pos += Vector3(
			randf_range(-_shake_intensity, _shake_intensity),
			randf_range(-_shake_intensity, _shake_intensity) * 0.5,
			randf_range(-_shake_intensity, _shake_intensity)
		)
		_shake_intensity = maxf(0.0, _shake_intensity - _shake_decay * delta)
	global_position = global_position.lerp(desired_pos, follow_speed * delta)
	# Keep looking at target
	look_at(target.global_position + offset, Vector3.UP)


func shake(intensity: float = 0.15, decay: float = 5.0) -> void:
	_shake_intensity = intensity
	_shake_decay = decay
