class_name EquipmentVisualizer
extends Node

## Attaches and detaches equipment meshes to slot mounts on the Globbler v2 model.
## Listens to EquipmentComponent signals and updates the visual model in real time.
##
## Also handles:
## - Dye color application (overrides primary material color)
## - Wear / dirt visual progression on damage
## - Set-bonus glow when all 6 pieces of a set are equipped
## - Transmog override (visual one set, stats from another)
##
## Slot mounts are Node3D children of the model named: slot_head, slot_chest,
## slot_back, slot_hand_R, slot_hand_L, slot_hip_R, slot_hip_L, slot_foot_R,
## slot_foot_L, slot_shoulder_R, slot_shoulder_L.

@export var model_root: NodePath
@export var equipment_component_path: NodePath
@export var health_component_path: NodePath
@export var set_bonus_glow_strength: float = 0.6
@export var wear_per_damage_event: float = 0.005

const SLOT_NAMES: PackedStringArray = [
	&"slot_head", &"slot_chest", &"slot_back",
	&"slot_hand_R", &"slot_hand_L",
	&"slot_hip_R", &"slot_hip_L",
	&"slot_foot_R", &"slot_foot_L",
	&"slot_shoulder_R", &"slot_shoulder_L",
]

var _model_root: Node3D
var _equipment_component: Node
var _health_component: Node
var _slots: Dictionary = {}        ## slot_name -> Node3D
var _attached: Dictionary = {}     ## slot_name -> Node3D (instanced equipment)
var _equipped_items: Dictionary = {}  ## slot_name -> OutfitItem
var _transmog_overrides: Dictionary = {}  ## slot_name -> OutfitItem (visual override)


func _ready() -> void:
	_model_root = get_node_or_null(model_root) as Node3D
	_equipment_component = get_node_or_null(equipment_component_path)
	_health_component = get_node_or_null(health_component_path)

	if _model_root == null:
		push_warning("EquipmentVisualizer: model_root not found at %s" % model_root)
		return

	_resolve_slots()

	if _equipment_component != null and _equipment_component.has_signal("equipment_changed"):
		_equipment_component.equipment_changed.connect(_on_equipment_changed)

	if _health_component != null and _health_component.has_signal("damage_taken"):
		_health_component.damage_taken.connect(_on_damage_taken)


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


func attach_equipment(slot_name: StringName, scene: PackedScene, item: OutfitItem = null) -> void:
	if not _slots.has(slot_name):
		push_warning("EquipmentVisualizer: unknown slot %s" % slot_name)
		return

	detach_equipment(slot_name)

	if scene == null:
		return

	var instance: Node = scene.instantiate()
	var slot: Node3D = _slots[slot_name]
	slot.add_child(instance)
	_attached[slot_name] = instance

	if item != null:
		_equipped_items[slot_name] = item
		_apply_dye_to(instance, item.dye_color, item.dye_index)
		_apply_wear_to(instance, item.wear)

	_update_set_bonus()


func detach_equipment(slot_name: StringName) -> void:
	if _attached.has(slot_name):
		var existing: Node = _attached[slot_name]
		if is_instance_valid(existing):
			existing.queue_free()
		_attached.erase(slot_name)
	_equipped_items.erase(slot_name)
	_update_set_bonus()


func clear_all() -> void:
	for slot_name: StringName in _attached.keys():
		detach_equipment(slot_name)


func set_transmog(slot_name: StringName, visual_item: OutfitItem) -> void:
	## Visual override — slot still uses the equipped item's stats but
	## displays a different outfit piece.
	if visual_item == null:
		_transmog_overrides.erase(slot_name)
	else:
		_transmog_overrides[slot_name] = visual_item
	# Re-attach using transmog visual
	attach_equipment(slot_name, visual_item.visual_scene if visual_item else null, visual_item)


func _on_equipment_changed(slot: StringName, item: Resource) -> void:
	if item is OutfitItem:
		var outfit: OutfitItem = item
		# If slot has an active transmog override, use that visual instead
		if _transmog_overrides.has(slot):
			var override: OutfitItem = _transmog_overrides[slot]
			attach_equipment(slot, override.visual_scene, override)
		else:
			attach_equipment(slot, outfit.visual_scene, outfit)
	else:
		# Generic resource with visual_scene field
		var visual: PackedScene = null
		if item != null and item.get("visual_scene") != null:
			visual = item.visual_scene
		attach_equipment(slot, visual)


func _on_damage_taken(_amount: float) -> void:
	# Wear up every equipped piece a tiny bit per damage event
	for slot_name: StringName in _equipped_items.keys():
		var item: OutfitItem = _equipped_items[slot_name]
		if item != null:
			item.add_wear(wear_per_damage_event)
			var inst: Node = _attached.get(slot_name)
			if inst != null:
				_apply_wear_to(inst, item.wear)


func _update_set_bonus() -> void:
	## A "set" is when all 6 outfit slots share the same set_id.
	const SET_SLOTS: Array[StringName] = [
		&"slot_head", &"slot_chest", &"slot_hand_R",
		&"slot_hand_L", &"slot_foot_R", &"slot_foot_L",
	]

	if _equipped_items.size() < SET_SLOTS.size():
		_clear_set_glow()
		return

	var first_set_id: StringName = &""
	for slot in SET_SLOTS:
		if not _equipped_items.has(slot):
			_clear_set_glow()
			return
		var item: OutfitItem = _equipped_items[slot]
		if first_set_id == &"":
			first_set_id = item.set_id
		elif item.set_id != first_set_id:
			_clear_set_glow()
			return

	# Full matching set — apply bonus glow to every attached piece
	for slot_name: StringName in _attached.keys():
		_apply_set_glow(_attached[slot_name])


func _apply_dye_to(instance: Node, color: Color, dye_index: int) -> void:
	if dye_index == -1:
		return  # use set's natural primary color
	for mesh: MeshInstance3D in _walk_meshes(instance):
		# Override the first material slot with a duplicated material
		if mesh.get_surface_override_material_count() == 0:
			continue
		for i in mesh.get_surface_override_material_count():
			var src: Material = mesh.get_surface_override_material(i)
			if src == null:
				src = mesh.mesh.surface_get_material(i) if mesh.mesh else null
			if src is StandardMaterial3D:
				var dup: StandardMaterial3D = src.duplicate()
				dup.albedo_color = color
				mesh.set_surface_override_material(i, dup)


func _apply_wear_to(instance: Node, wear: float) -> void:
	if wear <= 0.0:
		return
	for mesh: MeshInstance3D in _walk_meshes(instance):
		for i in mesh.get_surface_override_material_count():
			var mat: Material = mesh.get_surface_override_material(i)
			if mat is StandardMaterial3D:
				var sm: StandardMaterial3D = mat
				sm.roughness = clampf(sm.roughness + wear * 0.4, 0.0, 1.0)
				sm.albedo_color = sm.albedo_color.lerp(Color(0.4, 0.4, 0.4, 1.0), wear * 0.20)


func _apply_set_glow(instance: Node) -> void:
	for mesh: MeshInstance3D in _walk_meshes(instance):
		for i in mesh.get_surface_override_material_count():
			var mat: Material = mesh.get_surface_override_material(i)
			if mat is StandardMaterial3D:
				var sm: StandardMaterial3D = mat
				sm.emission_enabled = true
				sm.emission = sm.albedo_color
				sm.emission_energy_multiplier = set_bonus_glow_strength


func _clear_set_glow() -> void:
	for slot_name: StringName in _attached.keys():
		var inst: Node = _attached[slot_name]
		for mesh: MeshInstance3D in _walk_meshes(inst):
			for i in mesh.get_surface_override_material_count():
				var mat: Material = mesh.get_surface_override_material(i)
				if mat is StandardMaterial3D:
					(mat as StandardMaterial3D).emission_energy_multiplier = 0.0


func _walk_meshes(root: Node) -> Array[MeshInstance3D]:
	var result: Array[MeshInstance3D] = []
	if root is MeshInstance3D:
		result.append(root)
	for child in root.get_children():
		result.append_array(_walk_meshes(child))
	return result
