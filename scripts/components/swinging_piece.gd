class_name SwingingPiece
extends Node3D

## Drop-in subtle-physics for cape/mantle/antenna/strap pieces.
##
## A real cloth simulation would need a subdivided mesh and per-vertex
## verlet integration, but the Epic 02 outfit pieces are rigid cubes/
## quads modeled as single primitives. So instead this component does
## the next best thing: a damped pendulum rotation around the piece's
## attachment point that responds to the parent's movement velocity.
##
## The visual: when Globbler dashes forward, the cape lags behind for
## ~150ms, then swings back to center over ~600ms. When Globbler stops,
## the cape over-swings forward and oscillates back. When the player
## stands still, the cape sways gently in a sin curve driven by the
## WindDirector's wind strength (epic 23 task 41 integration).
##
## Required scene shape:
##   SwingingPiece (Node3D + this script)
##     [the piece mesh as a child]
##
## Configure via inspector:
##   max_lag_degrees    — how far the piece tilts away from the parent's
##                         direction of motion (cape default 25°)
##   damping            — 0..1 per-frame velocity decay (default 0.15)
##   gravity_pull       — angular pull back toward rest (default 8.0)
##   wind_response      — 0..1 multiplier on WindDirector influence
##   axis               — local axis to rotate around (cape: X, antenna: Z)
##   rest_offset_degrees — base resting tilt before any motion

@export var max_lag_degrees: float = 25.0
@export var damping: float = 0.15
@export var gravity_pull: float = 8.0
@export var wind_response: float = 0.5
@export var axis: Vector3 = Vector3.RIGHT  # X axis = pitch (forward/back)
@export var rest_offset_degrees: float = 0.0

# Tracking state
var _parent_prev_pos: Vector3
var _parent_velocity: Vector3 = Vector3.ZERO
var _angular_velocity: float = 0.0
var _current_angle_degrees: float = 0.0
var _initialized: bool = false


func _ready() -> void:
	# Capture initial parent world position
	if get_parent() is Node3D:
		_parent_prev_pos = (get_parent() as Node3D).global_position
	_current_angle_degrees = rest_offset_degrees
	_initialized = true


func _process(delta: float) -> void:
	if not _initialized or not (get_parent() is Node3D):
		return

	var parent: Node3D = get_parent()

	# Compute parent velocity from positional delta
	var dt: float = max(0.001, delta)
	var current_pos: Vector3 = parent.global_position
	_parent_velocity = (current_pos - _parent_prev_pos) / dt
	_parent_prev_pos = current_pos

	# Project velocity onto the piece's axis-of-swing local space.
	# For a cape rotating around X (pitch), forward velocity tilts the
	# cape backward. Convert parent velocity into local space first.
	var local_vel: Vector3 = parent.global_transform.basis.inverse() * _parent_velocity

	# Lag amount based on the velocity component in the swing axis's
	# perpendicular plane. For X-axis swing (default), use Z (forward).
	# For Z-axis swing (antenna), use X+Y combined.
	var swing_input: float = 0.0
	if axis == Vector3.RIGHT or axis.is_equal_approx(Vector3.RIGHT):
		swing_input = -local_vel.z * 4.0  # forward motion → backward tilt
	elif axis == Vector3.UP or axis.is_equal_approx(Vector3.UP):
		swing_input = local_vel.x * 4.0   # lateral motion → yaw
	else:
		swing_input = local_vel.length() * 2.0

	# Wind influence (only when standing still)
	var wind_influence: float = 0.0
	if _parent_velocity.length() < 0.5 and wind_response > 0.0:
		wind_influence = _get_wind_swing() * wind_response

	# Target angle = rest + lag from velocity + wind sway
	var target_angle: float = rest_offset_degrees + clampf(swing_input + wind_influence, -max_lag_degrees, max_lag_degrees)

	# Spring-damper integration: angular velocity is pulled toward target
	var error: float = target_angle - _current_angle_degrees
	_angular_velocity += error * gravity_pull * delta
	_angular_velocity *= (1.0 - damping)
	_current_angle_degrees += _angular_velocity * delta

	# Apply the rotation around the configured axis
	rotation = Vector3.ZERO
	rotate(axis.normalized(), deg_to_rad(_current_angle_degrees))


func _get_wind_swing() -> float:
	if not has_node("/root/WindDirector"):
		return 0.0
	var wd: Node = get_node("/root/WindDirector")
	if not wd.has_method("get_current_strength"):
		return 0.0
	var strength: float = wd.get_current_strength()
	# Sin sway driven by global time + per-instance phase offset
	var t: float = Time.get_ticks_msec() / 1000.0
	var phase: float = float(get_instance_id() % 1000) / 1000.0 * TAU
	return sin(t * 1.5 + phase) * strength * 80.0  # 80° max wind sway


# === EXPLICIT IMPULSE API (for hit reactions, dashes, etc) ===

func apply_impulse(angular_delta_degrees: float) -> void:
	## Manually push the piece — useful for hit reactions to make the
	## cape jerk on a takedown, or for ability casts to flare it.
	_angular_velocity += angular_delta_degrees
