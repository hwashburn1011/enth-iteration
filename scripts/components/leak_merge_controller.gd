class_name LeakMergeController
extends Node

## Merge mechanic for the MemoryLeak family (Epic 05 task 36).
##
## When two leaks come within merge_radius_m and both are above the
## merge_hp_threshold, they combine into a single larger leak with
## summed HP and stats. The merge has a windup so the player can
## interrupt it by killing one of the participants during the windup.
##
## Architecture:
##   - Each MemoryLeak has a LeakMergeController child
##   - It scans the "memoryleak" group for nearby compatible partners
##   - On a candidate match, the LOWER instance ID controller is the
##     "leader" (deterministic ownership) and starts a merge sequence:
##       1) Both leaks emit merge_starting (signal for VFX/SFX hooks)
##       2) Both leaks "lean toward" each other (animation hook)
##       3) After windup_s, fire EventBus.leak_merged(leader_pos, total_hp)
##          and queue_free both source leaks
##       4) A spawner upstream listens for leak_merged and instantiates
##          a larger leak at the merge point with the combined HP
##   - During the windup, if either leak's HP drops below the HP
##     threshold or one dies, the merge is canceled and both return to
##     normal AI
##
## Required scene shape:
##   LeakMergeController (Node + this script)
##     parent must be a Node3D in the "memoryleak" group
##     parent should have a HealthComponent sibling
##
## Inspector configuration:
##   merge_radius_m         — distance to detect a partner
##   merge_hp_threshold     — both leaks must be above this fraction
##                             of max HP to merge (default 0.4 — wounded
##                             leaks won't merge, full-HP ones will)
##   windup_s               — time before the merge resolves (default 1.5)
##   rescan_interval_s      — how often to look for partners (default 0.8)
##   merge_cooldown_s       — cooldown after a failed merge attempt
##   group_name             — group to scan (default "memoryleak")
##   max_merge_size_tier    — don't merge above this size class (alpha/queen
##                             can't merge with anything)

signal merge_starting(partner: Node3D)
signal merge_canceled()
signal merge_committed(partner: Node3D, merge_position: Vector3)

@export var merge_radius_m: float = 2.5
@export_range(0.0, 1.0) var merge_hp_threshold: float = 0.40
@export var windup_s: float = 1.5
@export var rescan_interval_s: float = 0.8
@export var merge_cooldown_s: float = 4.0
@export var group_name: StringName = &"memoryleak"
@export var max_merge_size_tier: int = 2  ## 0=drip, 1=leak, 2=flood, 3=ocean
@export var size_tier: int = 1
@export var health_component_path: NodePath

var _parent: Node3D
var _hc: Node
var _scan_timer: float = 0.0
var _cooldown_timer: float = 0.0
var _merge_partner: Node3D
var _merge_progress: float = 0.0
var _merging: bool = false


func _ready() -> void:
	_parent = get_parent() as Node3D
	if _parent == null:
		push_warning("LeakMergeController: parent is not Node3D")
		return

	# Make sure the parent is in the merge group so other controllers can find it
	if not _parent.is_in_group(group_name):
		_parent.add_to_group(group_name)

	_hc = get_node_or_null(health_component_path)
	if _hc == null:
		for child: Node in _parent.get_children():
			if child.has_signal("died"):
				_hc = child
				break

	if _hc != null:
		if _hc.has_signal("died"):
			_hc.died.connect(_on_died)


func _process(delta: float) -> void:
	if _parent == null:
		return

	if _cooldown_timer > 0.0:
		_cooldown_timer -= delta

	if _merging:
		_advance_merge(delta)
		return

	_scan_timer += delta
	if _scan_timer >= rescan_interval_s:
		_scan_timer = 0.0
		if _cooldown_timer <= 0.0 and _is_eligible():
			_try_find_partner()


func _is_eligible() -> bool:
	if size_tier > max_merge_size_tier:
		return false
	if _hc == null:
		return true  # no HP gating possible
	var hp_frac: float = _get_hp_fraction()
	return hp_frac >= merge_hp_threshold


func _get_hp_fraction() -> float:
	if _hc == null:
		return 1.0
	# Try common HP getters
	if _hc.has_method("get_hp_fraction"):
		return _hc.call("get_hp_fraction")
	if "current_health" in _hc and "max_health" in _hc:
		var maxh: float = _hc.get("max_health")
		if maxh > 0.0:
			return _hc.get("current_health") / maxh
	return 1.0


func _try_find_partner() -> void:
	var tree: SceneTree = get_tree()
	if tree == null:
		return
	var origin: Vector3 = _parent.global_position
	for node: Node in tree.get_nodes_in_group(group_name):
		if node == _parent or not (node is Node3D):
			continue
		var other: Node3D = node as Node3D
		if origin.distance_to(other.global_position) > merge_radius_m:
			continue
		# Find the other leak's merge controller
		var other_ctrl: LeakMergeController = _find_controller_on(other)
		if other_ctrl == null or other_ctrl._merging:
			continue
		if not other_ctrl._is_eligible():
			continue
		# Deterministic ownership: only the LOWER instance id starts the merge
		if _parent.get_instance_id() > other.get_instance_id():
			continue
		# Match! Start the merge from both sides
		_start_merge_with(other_ctrl)
		return


func _find_controller_on(target: Node3D) -> LeakMergeController:
	for child: Node in target.get_children():
		if child is LeakMergeController:
			return child
	return null


func _start_merge_with(other: LeakMergeController) -> void:
	_merging = true
	_merge_partner = other._parent
	_merge_progress = 0.0
	merge_starting.emit(_merge_partner)
	# Mirror the merge state on the partner so it stops looking for new partners
	other._merging = true
	other._merge_partner = _parent
	other._merge_progress = 0.0
	other.merge_starting.emit(_parent)


func _advance_merge(delta: float) -> void:
	if not is_instance_valid(_merge_partner):
		_cancel_merge()
		return

	# Either leak dropping below threshold cancels
	var partner_ctrl: LeakMergeController = _find_controller_on(_merge_partner)
	if partner_ctrl == null:
		_cancel_merge()
		return
	if _get_hp_fraction() < merge_hp_threshold or partner_ctrl._get_hp_fraction() < merge_hp_threshold:
		_cancel_merge()
		return

	_merge_progress += delta
	if _merge_progress >= windup_s:
		_commit_merge()


func _commit_merge() -> void:
	if not is_instance_valid(_merge_partner):
		_cancel_merge()
		return
	# Compute the merge point as the midpoint between the two leaks
	var merge_pos: Vector3 = (_parent.global_position + _merge_partner.global_position) * 0.5

	merge_committed.emit(_merge_partner, merge_pos)

	# Notify the world via EventBus so a spawner can instantiate the larger leak
	var bus: Node = get_node_or_null("/root/EventBus")
	if bus != null and bus.has_signal("leak_merged"):
		bus.emit_signal("leak_merged", merge_pos, _parent, _merge_partner)

	# Free both source leaks (use call_deferred so signal listeners run first)
	_merge_partner.call_deferred("queue_free")
	_parent.call_deferred("queue_free")


func _cancel_merge() -> void:
	_merging = false
	_merge_progress = 0.0
	_cooldown_timer = merge_cooldown_s
	merge_canceled.emit()
	# Cancel the partner side too if it still exists
	if _merge_partner != null and is_instance_valid(_merge_partner):
		var partner_ctrl: LeakMergeController = _find_controller_on(_merge_partner)
		if partner_ctrl != null and partner_ctrl._merging:
			partner_ctrl._merging = false
			partner_ctrl._merge_progress = 0.0
			partner_ctrl._cooldown_timer = merge_cooldown_s
			partner_ctrl.merge_canceled.emit()
	_merge_partner = null


func _on_died() -> void:
	# If we die mid-merge, the partner gets a free cancel
	if _merging:
		_cancel_merge()
