class_name LegIkTerrainSolver
extends Node3D

## Adjusts each leg's IK target to follow the terrain underneath the
## foot's nominal rest position. Uses a per-leg downward raycast to find
## the actual ground height, then sets the corresponding IK target
## position so the leg lower-bone IK constraint resolves with the foot
## planted on the slope.
##
## Used by the GlitchBug (Epic 04 task 36) — the 6-leg rig from task 14
## has 6 IK constraints already wired to 6 IK_target_leg_* empties.
## This solver pushes those empty positions on each frame based on the
## terrain raycast results.
##
## Reusable by any multi-leg enemy that needs ground-conforming IK.
##
## Required scene shape:
##   LegIkTerrainSolver (Node3D + this script)
##     export ik_target_paths → array of NodePath to the 6 IK target empties
##     export foot_rest_offsets → array of Vector3 nominal foot positions
##                                  in body-relative space
##     export raycast_max_distance_m → max downward ray length
##     export raycast_collision_mask → physics layer mask for ground
##
## On _physics_process: for each foot, projects the nominal rest position
## into world space using the parent's transform, raycasts straight down,
## and pushes the IK target to the hit point. If no hit, the IK target
## stays at the body-projected nominal height.

@export var ik_target_paths: Array[NodePath] = []
@export var foot_rest_offsets: Array[Vector3] = [
	Vector3(0.65, 0, 0.20),     # FR
	Vector3(-0.65, 0, 0.20),    # FL
	Vector3(0.72, 0, -0.05),    # MR
	Vector3(-0.72, 0, -0.05),   # ML
	Vector3(0.72, 0, -0.70),    # RR
	Vector3(-0.72, 0, -0.70),   # RL
]
@export_range(0.5, 8.0) var raycast_max_distance_m: float = 3.0
@export_flags_3d_physics var raycast_collision_mask: int = 1
@export_range(0.0, 0.3) var foot_clearance_m: float = 0.02
@export var enabled: bool = true

var _ik_targets: Array[Node3D] = []
var _parent: Node3D


func _ready() -> void:
	_parent = get_parent() as Node3D
	if _parent == null:
		push_warning("LegIkTerrainSolver: parent is not Node3D")
		return

	# Resolve IK target paths to nodes
	for path: NodePath in ik_target_paths:
		var node: Node3D = get_node_or_null(path) as Node3D
		if node != null:
			_ik_targets.append(node)
		else:
			# Push a null placeholder to keep array indices aligned with offsets
			_ik_targets.append(null)


func _physics_process(_delta: float) -> void:
	if not enabled or _parent == null:
		return
	if _ik_targets.size() != foot_rest_offsets.size():
		return

	var space: PhysicsDirectSpaceState3D = _parent.get_world_3d().direct_space_state
	if space == null:
		return

	for i: int in _ik_targets.size():
		var target: Node3D = _ik_targets[i]
		if target == null:
			continue
		var offset: Vector3 = foot_rest_offsets[i]
		# Project the rest offset into world space using the parent's transform
		var nominal_world: Vector3 = _parent.global_transform * offset
		# Cast from above the nominal position straight down
		var ray_from: Vector3 = Vector3(nominal_world.x, nominal_world.y + raycast_max_distance_m * 0.5, nominal_world.z)
		var ray_to: Vector3 = Vector3(nominal_world.x, nominal_world.y - raycast_max_distance_m * 0.5, nominal_world.z)
		var query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(
			ray_from, ray_to, raycast_collision_mask
		)
		query.exclude = [_parent.get_rid()] if _parent is CollisionObject3D else []
		var result: Dictionary = space.intersect_ray(query)
		if result.is_empty():
			# No ground hit — fall back to nominal height in body space
			target.global_position = nominal_world
		else:
			var hit_pos: Vector3 = result.get("position", nominal_world)
			# Add small clearance so the foot doesn't sink into the ground
			target.global_position = hit_pos + Vector3(0, foot_clearance_m, 0)


func set_enabled(value: bool) -> void:
	enabled = value
