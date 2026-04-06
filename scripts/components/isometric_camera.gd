class_name IsometricCamera
extends Camera3D
## Orthographic isometric camera that smoothly follows a target node.

@export var target: Node3D
@export var follow_speed: float = 5.0
@export var camera_size: float = 10.0
@export var offset: Vector3 = Vector3.ZERO


func _ready() -> void:
	projection = PROJECTION_ORTHOGONAL
	size = camera_size
	rotation_degrees = Vector3(-60.0, -45.0, 0.0)


func _process(delta: float) -> void:
	if target == null:
		return
	var target_position: Vector3 = target.global_position + offset
	global_position = global_position.lerp(
		target_position + _get_camera_offset(), follow_speed * delta
	)


func _get_camera_offset() -> Vector3:
	# Offset the camera position along its viewing direction so the target stays centered
	return -global_transform.basis.z * 20.0
