class_name HoverTerrainSolver
extends Node3D

## Keeps a hovering enemy at a target altitude above the terrain. Used by
## the RogueProcess (Epic 06 task 44) and reusable for any flying/hovering
## enemy that should follow ground height instead of flying through stairs
## and slopes.
##
## How it works:
## 1) Each _physics_process casts a ray straight down from the parent's
##    current position
## 2) Computes the desired altitude as ground_hit.y + target_altitude_m
## 3) Smooths the parent's Y position toward the desired altitude with
##    a configurable damping factor (so the enemy bobs into position
##    rather than snapping)
## 4) Optionally adds a sin-wave hover bob on top of the smoothed altitude
##    for the natural floating motion
##
## Distinct from LegIkTerrainSolver (Epic 04 task 36) which adjusts
## individual leg IK targets — this one moves the WHOLE BODY.
##
## Required scene shape:
##   HoverTerrainSolver (Node3D + this script, child of the enemy root)
##     parent must be a Node3D — typically the enemy root
##
## Inspector configuration:
##   target_altitude_m       — desired height above terrain
##   raycast_max_distance_m  — max downward ray length
##   raycast_collision_mask  — physics layer mask
##   smooth_speed            — how fast to track changes (higher = snappier)
##   bob_amplitude_m         — vertical sin-wave bob magnitude
##   bob_period_s            — bob cycle duration
##   raycast_origin_offset_m — Y offset from parent position to ray origin
##                              (so the ray starts above the body, not from
##                              inside it)

@export_range(0.1, 8.0) var target_altitude_m: float = 0.45
@export_range(0.5, 20.0) var raycast_max_distance_m: float = 6.0
@export_flags_3d_physics var raycast_collision_mask: int = 1
@export_range(0.5, 30.0) var smooth_speed: float = 6.0
@export_range(0.0, 0.5) var bob_amplitude_m: float = 0.05
@export_range(0.5, 8.0) var bob_period_s: float = 1.8
@export_range(0.0, 4.0) var raycast_origin_offset_m: float = 1.5
@export var enabled: bool = true
@export var control_x_z: bool = false  ## if true, also smooths X/Z to body's planned target

var _parent: Node3D
var _current_y: float = 0.0
var _bob_phase: float = 0.0
var _initialized: bool = false


func _ready() -> void:
	_parent = get_parent() as Node3D
	if _parent == null:
		push_warning("HoverTerrainSolver: parent is not Node3D")
		return
	_current_y = _parent.global_position.y
	_initialized = true


func _physics_process(delta: float) -> void:
	if not enabled or not _initialized or _parent == null:
		return

	var space: PhysicsDirectSpaceState3D = _parent.get_world_3d().direct_space_state
	if space == null:
		return

	# Cast from above the parent straight down
	var origin: Vector3 = _parent.global_position + Vector3(0, raycast_origin_offset_m, 0)
	var to_pos: Vector3 = origin + Vector3(0, -raycast_max_distance_m, 0)
	var query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(
		origin, to_pos, raycast_collision_mask
	)
	# Exclude the parent's own body if it's a CollisionObject3D
	if _parent is CollisionObject3D:
		query.exclude = [(_parent as CollisionObject3D).get_rid()]

	var result: Dictionary = space.intersect_ray(query)

	var desired_y: float
	if result.is_empty():
		# No ground found — keep the current altitude (don't crash)
		desired_y = _current_y
	else:
		var ground_y: float = result.get("position", Vector3.ZERO).y
		desired_y = ground_y + target_altitude_m

	# Smooth the current Y toward the desired Y using exponential damping
	# Equivalent to: lerp with a delta-rate dependent factor
	var t: float = 1.0 - exp(-smooth_speed * delta)
	_current_y = lerp(_current_y, desired_y, t)

	# Add the sin-wave bob on top
	_bob_phase += delta
	var bob: float = sin(_bob_phase * TAU / bob_period_s) * bob_amplitude_m

	# Apply to parent
	var pos: Vector3 = _parent.global_position
	pos.y = _current_y + bob
	_parent.global_position = pos


func snap_to_terrain() -> void:
	## Force-snap the current altitude to the desired position immediately,
	## skipping the smoothing. Used after teleport-in or scene spawn so
	## the enemy doesn't have to ease in from its placement Y.
	if _parent == null:
		return
	var space: PhysicsDirectSpaceState3D = _parent.get_world_3d().direct_space_state
	if space == null:
		return
	var origin: Vector3 = _parent.global_position + Vector3(0, raycast_origin_offset_m, 0)
	var to_pos: Vector3 = origin + Vector3(0, -raycast_max_distance_m, 0)
	var query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(
		origin, to_pos, raycast_collision_mask
	)
	if _parent is CollisionObject3D:
		query.exclude = [(_parent as CollisionObject3D).get_rid()]
	var result: Dictionary = space.intersect_ray(query)
	if not result.is_empty():
		var ground_y: float = result.get("position", Vector3.ZERO).y
		_current_y = ground_y + target_altitude_m
		var pos: Vector3 = _parent.global_position
		pos.y = _current_y
		_parent.global_position = pos
