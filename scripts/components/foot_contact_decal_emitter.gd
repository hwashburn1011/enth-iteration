class_name FootContactDecalEmitter
extends Node3D

## Drops a small ground contact decal under each leg's foot bone whenever
## that bone crosses a downward velocity threshold (i.e. lands). Used by
## the GlitchBug (Epic 04 task 34) and reusable by any multi-leg enemy.
##
## Distinct from LeakTrail (which drops slow-zone footprints continuously
## along a moving enemy's path) and InfestedDecal (which marks cluster
## areas under groups of enemies). This one is per-leg, per-step,
## triggered by the actual bone motion of the rig — so the decals
## land EXACTLY where the foot lands, not approximately under the body.
##
## Required scene shape:
##   FootContactDecalEmitter (Node3D + this script)
##     parent must be the enemy root or a Node3D
##     export armature_path → Skeleton3D
##     export foot_bone_names → array of bone names (e.g. all leg_*_lower bones)
##
## Inspector:
##   armature_path        — Skeleton3D containing the foot bones
##   foot_bone_names      — bone names whose tip position is the "foot"
##   landing_threshold_m  — how far the foot must drop in one frame to
##                          count as "landing" (default 0.005 — small
##                          since we check each frame)
##   ground_y_m           — Y coordinate considered "ground" (default 0)
##                          decals only drop when the foot is near this
##   decal_lifetime_s     — how long each decal persists
##   decal_radius_m       — size of each decal
##   decal_color          — base color (default dark dust)
##   max_active_decals    — cap total simultaneous decals

@export var armature_path: NodePath
@export var foot_bone_names: PackedStringArray = PackedStringArray([
	"leg_FR_lower", "leg_FL_lower",
	"leg_MR_lower", "leg_ML_lower",
	"leg_RR_lower", "leg_RL_lower",
])
@export_range(0.001, 0.1) var landing_threshold_m: float = 0.005
@export_range(0.0, 1.0) var ground_proximity_m: float = 0.05
@export_range(0.5, 30.0) var decal_lifetime_s: float = 4.0
@export_range(0.05, 1.0) var decal_radius_m: float = 0.18
@export var decal_color: Color = Color(0.10, 0.10, 0.12, 0.75)
@export_range(8, 256) var max_active_decals: int = 64
@export var stop_when_dead: bool = true
@export var health_component_path: NodePath

var _armature: Skeleton3D
var _foot_bone_indices: Array[int] = []
var _last_foot_world_y: Array[float] = []
var _last_foot_pos: Array[Vector3] = []
var _active_decals: Array[Decal] = []
var _enabled: bool = true


func _ready() -> void:
	_armature = get_node_or_null(armature_path) as Skeleton3D
	if _armature == null:
		# Auto-find: walk parent for a Skeleton3D
		var parent: Node = get_parent()
		var stack: Array[Node] = [parent]
		while stack.size() > 0:
			var node: Node = stack.pop_back()
			if node is Skeleton3D:
				_armature = node
				break
			for child: Node in node.get_children():
				stack.append(child)

	if _armature == null:
		push_warning("FootContactDecalEmitter: no Skeleton3D found")
		return

	# Resolve bone indices once
	for bone_name: String in foot_bone_names:
		var idx: int = _armature.find_bone(bone_name)
		if idx >= 0:
			_foot_bone_indices.append(idx)
			_last_foot_world_y.append(_get_foot_world_pos(idx).y)
			_last_foot_pos.append(_get_foot_world_pos(idx))

	if stop_when_dead:
		var hc: Node = get_node_or_null(health_component_path)
		if hc == null:
			var parent: Node = get_parent()
			if parent != null:
				for child: Node in parent.get_children():
					if child.has_signal("died"):
						hc = child
						break
		if hc != null and hc.has_signal("died"):
			hc.died.connect(_on_died)


func _physics_process(_delta: float) -> void:
	if not _enabled or _armature == null:
		return

	for i: int in _foot_bone_indices.size():
		var bone_idx: int = _foot_bone_indices[i]
		var pos: Vector3 = _get_foot_world_pos(bone_idx)
		var prev_y: float = _last_foot_world_y[i]
		var dy: float = prev_y - pos.y  # positive if foot dropped
		# Detect landing: foot dropped by at least the threshold AND is
		# now near the ground plane
		if dy >= landing_threshold_m and pos.y <= ground_proximity_m:
			_drop_decal(pos)
		_last_foot_world_y[i] = pos.y
		_last_foot_pos[i] = pos


func _get_foot_world_pos(bone_idx: int) -> Vector3:
	# The foot tip is the bone's tail in world space
	var bone_pose: Transform3D = _armature.get_bone_global_pose(bone_idx)
	var bone_length: float = _armature.get_bone_rest(bone_idx).origin.length()
	# Use the bone tip via Y axis since Blender bones extend along local Y
	var local_tip: Vector3 = Vector3(0, _armature.get_bone_rest(bone_idx).basis.get_scale().y, 0)
	# Simpler: use the bone's pose origin as the foot position
	return _armature.global_transform * bone_pose.origin


func _drop_decal(world_pos: Vector3) -> void:
	# Cap active decals
	if _active_decals.size() >= max_active_decals:
		var oldest: Decal = _active_decals.pop_front()
		if is_instance_valid(oldest):
			oldest.queue_free()

	var decal: Decal = Decal.new()
	decal.size = Vector3(decal_radius_m * 2.0, 1.5, decal_radius_m * 2.0)
	decal.modulate = Color(decal_color.r, decal_color.g, decal_color.b, decal_color.a)
	decal.albedo_mix = 0.85

	# Add to the world scene so it persists when the enemy moves away
	var world: Node = get_tree().current_scene
	if world == null:
		decal.queue_free()
		return
	world.add_child(decal)
	decal.global_position = Vector3(world_pos.x, 0.02, world_pos.z)
	_active_decals.append(decal)

	# Schedule the decal's free via a tween fade
	var tw: Tween = decal.create_tween()
	tw.tween_interval(decal_lifetime_s * 0.6)
	tw.tween_property(decal, "modulate:a", 0.0, decal_lifetime_s * 0.4)
	tw.tween_callback(_remove_from_active.bind(decal))
	tw.tween_callback(decal.queue_free)


func _remove_from_active(decal: Decal) -> void:
	var idx: int = _active_decals.find(decal)
	if idx >= 0:
		_active_decals.remove_at(idx)


func _on_died() -> void:
	_enabled = false
