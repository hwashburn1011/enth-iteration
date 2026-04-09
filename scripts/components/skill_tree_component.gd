class_name SkillTreeComponent
extends Node

## Player-attached component that manages skill point allocation, prerequisite
## validation, and effect application from a SkillTree resource. Switches
## trees automatically when the player class changes.

signal skill_allocated(node_id: StringName, new_rank: int)
signal skill_refunded(node_id: StringName)
signal skill_points_changed(available: int, total_spent: int)
signal tree_reset

@export var stats_component_path: NodePath
@export var ability_manager_path: NodePath

var current_tree: SkillTree
var allocation: Dictionary = {}  ## node_id -> current rank
var available_points: int = 0
var total_points_earned: int = 0


func _ready() -> void:
	if Engine.has_singleton("ClassRegistry") or has_node("/root/ClassRegistry"):
		var reg: Node = get_node("/root/ClassRegistry")
		if reg.has_signal("class_changed"):
			reg.class_changed.connect(_on_class_changed)
		if reg.has_signal("class_milestone_reached"):
			reg.class_milestone_reached.connect(_on_class_milestone)


func _on_class_changed(new_class_id: StringName, _previous: StringName) -> void:
	var path: String = "res://data/skill_trees/skill_tree_%s.tres" % String(new_class_id)
	if ResourceLoader.exists(path):
		current_tree = load(path) as SkillTree
		reset_allocation()


func load_tree(tree: SkillTree) -> void:
	current_tree = tree
	reset_allocation()


func grant_points(amount: int) -> void:
	available_points += amount
	total_points_earned += amount
	skill_points_changed.emit(available_points, total_points_earned - available_points)


func _on_class_milestone(_class_id: StringName, _level: int, _unlock_id: StringName) -> void:
	# Each milestone grants 2 skill points
	grant_points(2)


func can_allocate(node_id: StringName) -> bool:
	if current_tree == null:
		return false
	var node: SkillNode = current_tree.get_node(node_id)
	if node == null:
		return false
	var current_rank: int = allocation.get(node_id, 0)
	if current_rank >= node.max_rank:
		return false
	if available_points < node.cost:
		return false
	if not current_tree.validate_prerequisites(node_id, allocation):
		return false
	return true


func allocate(node_id: StringName) -> bool:
	if not can_allocate(node_id):
		return false
	var node: SkillNode = current_tree.get_node(node_id)
	available_points -= node.cost
	var new_rank: int = allocation.get(node_id, 0) + 1
	allocation[node_id] = new_rank
	_apply_effects(node, +1)
	skill_allocated.emit(node_id, new_rank)
	skill_points_changed.emit(available_points, total_points_earned - available_points)
	return true


func refund(node_id: StringName) -> bool:
	if not allocation.has(node_id) or allocation[node_id] <= 0:
		return false
	# Don't refund if other allocated nodes depend on this one
	var dependents: Array[SkillNode] = current_tree.get_dependents(node_id)
	for dep in dependents:
		if allocation.get(dep.node_id, 0) > 0:
			return false
	var node: SkillNode = current_tree.get_node(node_id)
	available_points += node.cost
	allocation[node_id] -= 1
	if allocation[node_id] <= 0:
		allocation.erase(node_id)
	_apply_effects(node, -1)
	skill_refunded.emit(node_id)
	skill_points_changed.emit(available_points, total_points_earned - available_points)
	return true


func reset_allocation() -> void:
	# Refund all points and reapply zero state
	for node_id: StringName in allocation.keys():
		var node: SkillNode = current_tree.get_node(node_id) if current_tree else null
		if node != null:
			_apply_effects(node, -allocation[node_id])
	available_points = total_points_earned
	allocation.clear()
	tree_reset.emit()
	skill_points_changed.emit(available_points, 0)


func _apply_effects(node: SkillNode, delta_rank: int) -> void:
	## Apply each effect on the node, scaled by delta_rank (+1 on allocate, -1 on refund).
	var stats: Node = get_node_or_null(stats_component_path)
	var abilities: Node = get_node_or_null(ability_manager_path)
	for effect in node.effects:
		var t: StringName = effect.get("type", &"")
		var p: Dictionary = effect.get("params", {})
		match t:
			&"stat_add":
				if stats != null and stats.has_method("modify_stat_flat"):
					stats.modify_stat_flat(p.get("stat", &""), float(p.get("amount", 0.0)) * delta_rank)
			&"stat_mult":
				if stats != null and stats.has_method("modify_stat_mult"):
					var m: float = float(p.get("multiplier", 1.0))
					if delta_rank > 0:
						stats.modify_stat_mult(p.get("stat", &""), m)
					else:
						# Inverse to undo
						if m != 0.0:
							stats.modify_stat_mult(p.get("stat", &""), 1.0 / m)
			&"ability_unlock":
				if abilities != null:
					if delta_rank > 0 and abilities.has_method("unlock_ability"):
						abilities.unlock_ability(p.get("ability_id", &""))
					elif delta_rank < 0 and abilities.has_method("lock_ability"):
						abilities.lock_ability(p.get("ability_id", &""))
			&"ability_modifier":
				if abilities != null and abilities.has_method("set_ability_modifier"):
					abilities.set_ability_modifier(p.get("ability_id", &""), p.get("key", &""), p.get("value"))
			&"passive_unlock":
				if delta_rank > 0:
					_emit_passive_event(p.get("passive_id", &""), true)
				else:
					_emit_passive_event(p.get("passive_id", &""), false)


func _emit_passive_event(passive_id: StringName, active: bool) -> void:
	if Engine.has_singleton("EventBus") or has_node("/root/EventBus"):
		var bus: Node = get_node("/root/EventBus")
		if bus.has_signal("passive_state_changed"):
			bus.passive_state_changed.emit(passive_id, active)


# === SAVE / LOAD ===

func to_save_data() -> Dictionary:
	var alloc_str: Dictionary = {}
	for k: StringName in allocation.keys():
		alloc_str[String(k)] = allocation[k]
	return {
		"available_points": available_points,
		"total_points_earned": total_points_earned,
		"allocation": alloc_str,
	}


func from_save_data(data: Dictionary) -> void:
	available_points = data.get("available_points", 0)
	total_points_earned = data.get("total_points_earned", 0)
	var alloc: Dictionary = data.get("allocation", {})
	allocation.clear()
	for k in alloc.keys():
		allocation[StringName(k)] = alloc[k]
	# Re-apply all effects from current allocation
	if current_tree != null:
		for node_id: StringName in allocation.keys():
			var node: SkillNode = current_tree.get_node(node_id)
			if node != null:
				_apply_effects(node, allocation[node_id])


# === BUILD SHARING ===

func export_build_code() -> String:
	## Encodes the current allocation as a base64 string for sharing builds.
	## Format: class_id|node1=rank|node2=rank|...
	if current_tree == null:
		return ""
	var parts: PackedStringArray = [String(current_tree.class_id)]
	for k: StringName in allocation.keys():
		parts.append("%s=%d" % [String(k), allocation[k]])
	var raw: String = "|".join(parts)
	return Marshalls.utf8_to_base64(raw)


func import_build_code(code: String) -> bool:
	if current_tree == null:
		return false
	var raw: String = Marshalls.base64_to_utf8(code)
	if raw.is_empty():
		return false
	var parts: PackedStringArray = raw.split("|")
	if parts.is_empty():
		return false
	if parts[0] != String(current_tree.class_id):
		push_warning("Build code is for class '%s', current is '%s'" % [parts[0], current_tree.class_id])
		return false
	# Reset and apply
	reset_allocation()
	for i in range(1, parts.size()):
		var entry: PackedStringArray = parts[i].split("=")
		if entry.size() != 2:
			continue
		var node_id: StringName = StringName(entry[0])
		var rank: int = int(entry[1])
		for r in rank:
			if not allocate(node_id):
				break
	return true
