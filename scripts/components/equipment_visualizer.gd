class_name EquipmentVisualizer
extends Node

## Attaches and detaches equipment meshes to slot mounts on the Globbler v2 model.
## Listens to EquipmentComponent signals and updates the visual model in real time.
##
## Slot mounts are Node3D children of the model named: slot_head, slot_chest,
## slot_back, slot_hand_R, slot_hand_L, slot_hip_R, slot_hip_L, slot_foot_R,
## slot_foot_L, slot_shoulder_R, slot_shoulder_L.
##
## Each equipment piece is a PackedScene that gets instantiated under the matching slot.

@export var model_root: NodePath
@export var equipment_component_path: NodePath

const SLOT_NAMES: PackedStringArray = [
	&"slot_head", &"slot_chest", &"slot_back",
	&"slot_hand_R", &"slot_hand_L",
	&"slot_hip_R", &"slot_hip_L",
	&"slot_foot_R", &"slot_foot_L",
	&"slot_shoulder_R", &"slot_shoulder_L",
]

var _model_root: Node3D
var _equipment_component: Node
var _slots: Dictionary = {}        ## slot_name -> Node3D
var _attached: Dictionary = {}     ## slot_name -> Node3D (instanced equipment)


func _ready() -> void:
	_model_root = get_node_or_null(model_root) as Node3D
	_equipment_component = get_node_or_null(equipment_component_path)

	if _model_root == null:
		push_warning("EquipmentVisualizer: model_root not found at %s" % model_root)
		return

	_resolve_slots()

	if _equipment_component != null and _equipment_component.has_signal("equipment_changed"):
		_equipment_component.equipment_changed.connect(_on_equipment_changed)


func _resolve_slots() -> void:
	for slot_name in SLOT_NAMES:
		var slot: Node = _find_descendant_named(_model_root, slot_name)
		if slot is Node3D:
			_slots[slot_name] = slot
		else:
			# Slot not present in this model - acceptable for early variants
			pass


func _find_descendant_named(root: Node, target_name: StringName) -> Node:
	if root.name == target_name:
		return root
	for child in root.get_children():
		var found: Node = _find_descendant_named(child, target_name)
		if found != null:
			return found
	return null


func attach_equipment(slot_name: StringName, scene: PackedScene) -> void:
	if not _slots.has(slot_name):
		push_warning("EquipmentVisualizer: unknown slot %s" % slot_name)
		return

	# Detach existing first
	detach_equipment(slot_name)

	if scene == null:
		return

	var instance: Node = scene.instantiate()
	var slot: Node3D = _slots[slot_name]
	slot.add_child(instance)
	_attached[slot_name] = instance


func detach_equipment(slot_name: StringName) -> void:
	if _attached.has(slot_name):
		var existing: Node = _attached[slot_name]
		if is_instance_valid(existing):
			existing.queue_free()
		_attached.erase(slot_name)


func clear_all() -> void:
	for slot_name: StringName in _attached.keys():
		detach_equipment(slot_name)


func _on_equipment_changed(slot: StringName, item: Resource) -> void:
	# Resolve item -> visual scene via convention: item.visual_scene
	var visual: PackedScene = null
	if item != null and item.has_method("get") and item.get("visual_scene") != null:
		visual = item.visual_scene
	attach_equipment(slot, visual)
