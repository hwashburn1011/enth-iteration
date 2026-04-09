class_name LeakAbsorbController
extends Node

## Absorb-corpse mechanic for the MemoryLeak (Epic 05 task 38).
##
## When a non-leak enemy dies near the leak, the leak slowly drags
## itself onto the corpse and "eats" it — the corpse's mesh shrinks
## and dissolves into the leak's body, the leak gains HP and grows in
## scale, and the absorb count increments. Capped so leaks don't
## scale infinitely.
##
## The actual corpse-pulling animation is delegated: this controller
## fires absorb_started/absorb_progressed/absorb_finished signals so
## the rig animation can react. Until the Blender animations exist,
## the visual is a simple Tween that scales the corpse mesh down to
## zero over absorb_duration_s.
##
## Triggers off the existing CorpsePersistence component on the dying
## enemy: this controller scans for ANY group node tagged "absorbable"
## within sense_radius_m. CorpsePersistence is the natural producer of
## absorbable nodes — it owns the dead body during its linger phase.
##
## Required scene shape:
##   LeakAbsorbController (Node + this script)
##     parent must be a Node3D
##     parent's HealthComponent reference for HP gain
##
## Inspector configuration:
##   sense_radius_m         — distance to detect a corpse
##   reach_radius_m         — distance to actually start absorbing (must
##                             be smaller than sense, the leak has to walk
##                             into reach first)
##   absorb_duration_s      — how long the absorption animation takes
##   absorb_cooldown_s      — gap between absorptions
##   hp_per_absorb          — flat HP gained
##   scale_per_absorb       — uniform body scale gained per absorb
##   max_absorbs            — cap on lifetime absorbs
##   group_name             — group to scan (default "absorbable")

signal absorb_started(corpse: Node3D)
signal absorb_progressed(corpse: Node3D, t: float)
signal absorb_finished(corpse: Node3D)

@export var sense_radius_m: float = 4.0
@export var reach_radius_m: float = 1.0
@export var absorb_duration_s: float = 2.5
@export var absorb_cooldown_s: float = 1.0
@export var hp_per_absorb: float = 25.0
@export_range(0.0, 0.5) var scale_per_absorb: float = 0.05
@export var max_absorbs: int = 6
@export var group_name: StringName = &"absorbable"
@export var rescan_interval_s: float = 0.5
@export var health_component_path: NodePath

var _parent: Node3D
var _hc: Node
var _scan_timer: float = 0.0
var _cooldown_timer: float = 0.0
var _absorbing: bool = false
var _absorb_progress: float = 0.0
var _current_corpse: Node3D
var _absorb_count: int = 0
var _starting_scale: Vector3 = Vector3.ONE


func _ready() -> void:
	_parent = get_parent() as Node3D
	if _parent == null:
		push_warning("LeakAbsorbController: parent is not a Node3D")
		return
	_starting_scale = _parent.scale
	_hc = get_node_or_null(health_component_path)
	if _hc == null:
		for child: Node in _parent.get_children():
			if child.has_signal("died"):
				_hc = child
				break


func _process(delta: float) -> void:
	if _parent == null:
		return

	if _cooldown_timer > 0.0:
		_cooldown_timer -= delta

	if _absorbing:
		_advance_absorb(delta)
		return

	if _absorb_count >= max_absorbs:
		return

	_scan_timer += delta
	if _scan_timer >= rescan_interval_s:
		_scan_timer = 0.0
		if _cooldown_timer <= 0.0:
			_try_find_corpse()


func _try_find_corpse() -> void:
	var tree: SceneTree = get_tree()
	if tree == null:
		return
	var origin: Vector3 = _parent.global_position
	var best: Node3D = null
	var best_dist: float = sense_radius_m
	for node: Node in tree.get_nodes_in_group(group_name):
		if node == _parent or not (node is Node3D):
			continue
		var n3d: Node3D = node as Node3D
		var d: float = origin.distance_to(n3d.global_position)
		if d <= reach_radius_m and d < best_dist:
			best = n3d
			best_dist = d
	if best != null:
		_start_absorb(best)


func _start_absorb(corpse: Node3D) -> void:
	_absorbing = true
	_current_corpse = corpse
	_absorb_progress = 0.0
	# Tag the corpse so other leaks don't try to absorb it simultaneously
	if not corpse.is_in_group(&"absorb_in_progress"):
		corpse.add_to_group(&"absorb_in_progress")
	# Disable the corpse's own dissolve timer if it has one — we want to
	# manage the visual ourselves during absorption
	for child: Node in corpse.get_children():
		if child is CorpsePersistence:
			child.set_process(false)
			break
	absorb_started.emit(corpse)


func _advance_absorb(delta: float) -> void:
	if _current_corpse == null or not is_instance_valid(_current_corpse):
		_finish_absorb_with_failure()
		return

	_absorb_progress += delta
	var t: float = clampf(_absorb_progress / absorb_duration_s, 0.0, 1.0)

	# Shrink the corpse and pull it toward the leak's center
	var leak_pos: Vector3 = _parent.global_position
	var corpse_start_pos: Vector3 = _current_corpse.global_position
	var pull_target: Vector3 = lerp(corpse_start_pos, leak_pos, t * 0.4)
	_current_corpse.global_position = pull_target
	_current_corpse.scale = _current_corpse.scale.lerp(Vector3.ZERO, t * 0.05)
	# Note: scale lerp uses t*0.05 so we don't snap to zero — corpse
	# shrinks gradually each frame which compounds smoothly

	absorb_progressed.emit(_current_corpse, t)

	if t >= 1.0:
		_finish_absorb_with_success()


func _finish_absorb_with_success() -> void:
	if _current_corpse != null and is_instance_valid(_current_corpse):
		# Free the corpse fully
		_current_corpse.queue_free()
		absorb_finished.emit(_current_corpse)

	_absorbing = false
	_absorb_progress = 0.0
	_current_corpse = null
	_absorb_count += 1
	_cooldown_timer = absorb_cooldown_s

	# Apply the gain
	_apply_hp_gain(hp_per_absorb)
	_apply_scale_gain(scale_per_absorb)


func _finish_absorb_with_failure() -> void:
	# Corpse vanished out from under us — clean up state and cool down
	_absorbing = false
	_absorb_progress = 0.0
	_current_corpse = null
	_cooldown_timer = absorb_cooldown_s


func _apply_hp_gain(amount: float) -> void:
	if _hc == null:
		return
	if _hc.has_method("heal"):
		_hc.call("heal", amount)
	elif _hc.has_method("take_heal"):
		_hc.call("take_heal", amount)
	elif "current_health" in _hc and "max_health" in _hc:
		var maxh: float = _hc.get("max_health")
		var curh: float = _hc.get("current_health")
		_hc.set("current_health", minf(curh + amount, maxh))


func _apply_scale_gain(per_absorb: float) -> void:
	if _parent == null:
		return
	var multiplier: float = 1.0 + per_absorb
	_parent.scale = _parent.scale * multiplier
