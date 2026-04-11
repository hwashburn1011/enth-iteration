class_name PaperDollUI
extends Control

## Paper-doll UI panel showing the player's equipped outfit slots as a 2D
## silhouette layout with slot icons. Click a slot to open its dye/transmog
## menu, drag-drop items from inventory to equip.

@export var equipment_component_path: NodePath
@export var slot_size: Vector2 = Vector2(64, 64)

const SLOT_LAYOUT: Dictionary = {
	# slot_name -> Vector2 normalized position (0-1) on the silhouette
	&"slot_head":       Vector2(0.50, 0.10),
	&"slot_shoulder_R": Vector2(0.72, 0.30),
	&"slot_shoulder_L": Vector2(0.28, 0.30),
	&"slot_chest":      Vector2(0.50, 0.40),
	&"slot_back":       Vector2(0.50, 0.42),
	&"slot_hand_R":     Vector2(0.85, 0.55),
	&"slot_hand_L":     Vector2(0.15, 0.55),
	&"slot_hip_R":      Vector2(0.65, 0.65),
	&"slot_hip_L":      Vector2(0.35, 0.65),
	&"slot_foot_R":     Vector2(0.60, 0.92),
	&"slot_foot_L":     Vector2(0.40, 0.92),
}

@onready var _silhouette_rect: TextureRect = %SilhouetteRect
@onready var _slots_container: Control = %SlotsContainer

var _equipment_component: Node
var _slot_buttons: Dictionary = {}  # slot_name -> TextureButton

signal slot_clicked(slot_name: StringName)
signal slot_right_clicked(slot_name: StringName)


func _ready() -> void:
	_equipment_component = get_node_or_null(equipment_component_path)
	_build_slot_buttons()

	if _equipment_component != null and _equipment_component.has_signal("equipment_changed"):
		_equipment_component.equipment_changed.connect(_on_equipment_changed)

	_refresh_all()


func _build_slot_buttons() -> void:
	if _slots_container == null:
		push_warning("PaperDollUI: SlotsContainer node not found")
		return

	for slot_name: StringName in SLOT_LAYOUT.keys():
		var btn: TextureButton = TextureButton.new()
		btn.name = String(slot_name)
		btn.custom_minimum_size = slot_size
		btn.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
		btn.tooltip_text = _humanize_slot(slot_name)
		_slots_container.add_child(btn)

		var pos: Vector2 = SLOT_LAYOUT[slot_name]
		btn.anchor_left = pos.x
		btn.anchor_right = pos.x
		btn.anchor_top = pos.y
		btn.anchor_bottom = pos.y
		btn.offset_left = -slot_size.x * 0.5
		btn.offset_right = slot_size.x * 0.5
		btn.offset_top = -slot_size.y * 0.5
		btn.offset_bottom = slot_size.y * 0.5

		btn.pressed.connect(func() -> void: slot_clicked.emit(slot_name))
		btn.gui_input.connect(_on_slot_input.bind(slot_name))

		_slot_buttons[slot_name] = btn


func _on_slot_input(event: InputEvent, slot_name: StringName) -> void:
	if event is InputEventMouseButton:
		var mb: InputEventMouseButton = event
		if mb.pressed and mb.button_index == MOUSE_BUTTON_RIGHT:
			slot_right_clicked.emit(slot_name)


func _refresh_all() -> void:
	for slot_name: StringName in _slot_buttons.keys():
		_refresh_slot(slot_name)


func _refresh_slot(slot_name: StringName) -> void:
	var btn: TextureButton = _slot_buttons.get(slot_name)
	if btn == null:
		return
	if _equipment_component != null and _equipment_component.has_method("get_equipped"):
		var item: OutfitItem = _equipment_component.get_equipped(slot_name) as OutfitItem
		if item != null and item.icon != null:
			btn.texture_normal = item.icon
			btn.tooltip_text = "%s\n%s" % [item.item_name, _humanize_slot(slot_name)]
		else:
			btn.texture_normal = null
			btn.tooltip_text = _humanize_slot(slot_name)


func _on_equipment_changed(slot_name: StringName, _item: Resource) -> void:
	_refresh_slot(slot_name)


func _humanize_slot(slot_name: StringName) -> String:
	const NAMES: Dictionary = {
		&"slot_head":       "Head",
		&"slot_chest":      "Chest",
		&"slot_back":       "Back",
		&"slot_hand_R":     "Right Hand",
		&"slot_hand_L":     "Left Hand",
		&"slot_hip_R":      "Right Hip",
		&"slot_hip_L":      "Left Hip",
		&"slot_foot_R":     "Right Foot",
		&"slot_foot_L":     "Left Foot",
		&"slot_shoulder_R": "Right Shoulder",
		&"slot_shoulder_L": "Left Shoulder",
	}
	return NAMES.get(slot_name, String(slot_name))
