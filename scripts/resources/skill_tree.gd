class_name SkillTree
extends Resource

## A complete skill tree for one class. Owns the node graph + helper queries.
## Loaded from data/skill_trees/<class_id>.tres at startup.

@export var class_id: StringName = &""
@export var display_name: String = ""
@export var theme_color: Color = Color.WHITE
@export var nodes: Array[SkillNode] = []

var _node_index: Dictionary = {}  ## node_id -> SkillNode (built on demand)


func _get_index() -> Dictionary:
	if _node_index.is_empty() and not nodes.is_empty():
		for n in nodes:
			_node_index[n.node_id] = n
	return _node_index


func get_node(id: StringName) -> SkillNode:
	return _get_index().get(id)


func get_keystones() -> Array[SkillNode]:
	var result: Array[SkillNode] = []
	for n in nodes:
		if n.is_keystone:
			result.append(n)
	return result


func get_root_nodes() -> Array[SkillNode]:
	var result: Array[SkillNode] = []
	for n in nodes:
		if n.prerequisites.is_empty():
			result.append(n)
	return result


func get_dependents(node_id: StringName) -> Array[SkillNode]:
	## Returns all nodes that have node_id in their prerequisites.
	var result: Array[SkillNode] = []
	for n in nodes:
		if node_id in n.prerequisites:
			result.append(n)
	return result


func validate_prerequisites(node_id: StringName, allocation: Dictionary) -> bool:
	## allocation: node_id -> rank
	var node: SkillNode = get_node(node_id)
	if node == null:
		return false
	for prereq_id in node.prerequisites:
		if not allocation.has(prereq_id) or allocation[prereq_id] <= 0:
			return false
	return true
