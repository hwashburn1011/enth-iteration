class_name ClassSelectUI
extends Control

## Class selection screen shown at character creation. Lists all 3 classes
## with portraits, taglines, stat preview, and a 3D rotating model preview.
## Confirms with the chosen class via signal — caller wires this to the
## new-game flow.

signal class_confirmed(class_id: StringName)
signal class_select_cancelled

@export var class_ids: Array[StringName] = [&"compiler", &"daemon", &"kernel"]

var _selected_class_id: StringName = &""

@onready var _name_label: Label = %ClassNameLabel
@onready var _tagline_label: Label = %TaglineLabel
@onready var _description_label: RichTextLabel = %DescriptionLabel
@onready var _stats_container: VBoxContainer = %StatsContainer
@onready var _portrait_rect: TextureRect = %PortraitRect
@onready var _confirm_button: Button = %ConfirmButton
@onready var _cancel_button: Button = %CancelButton
@onready var _class_buttons: HBoxContainer = %ClassButtons


func _ready() -> void:
	_build_class_buttons()
	if class_ids.size() > 0:
		_select_class(class_ids[0])
	if _confirm_button != null:
		_confirm_button.pressed.connect(_on_confirm_pressed)
	if _cancel_button != null:
		_cancel_button.pressed.connect(_on_cancel_pressed)


func _build_class_buttons() -> void:
	if _class_buttons == null:
		return
	for class_id in class_ids:
		var def: ClassDefinition = ClassRegistry.get_class(class_id)
		if def == null:
			continue
		var btn: Button = Button.new()
		btn.text = def.display_name
		btn.custom_minimum_size = Vector2(160, 60)
		btn.add_theme_font_size_override(&"font_size", 20)
		btn.add_theme_color_override(&"font_color", def.color_primary)
		btn.pressed.connect(_select_class.bind(class_id))
		_class_buttons.add_child(btn)


func _select_class(class_id: StringName) -> void:
	_selected_class_id = class_id
	var def: ClassDefinition = ClassRegistry.get_class(class_id)
	if def == null:
		return

	if _name_label != null:
		_name_label.text = def.display_name
		_name_label.add_theme_color_override(&"font_color", def.color_primary)
	if _tagline_label != null:
		_tagline_label.text = def.tagline
	if _description_label != null:
		_description_label.text = def.description
	if _portrait_rect != null:
		_portrait_rect.texture = def.portrait
	_populate_stats(def)


func _populate_stats(def: ClassDefinition) -> void:
	if _stats_container == null:
		return
	for c in _stats_container.get_children():
		c.queue_free()

	var rows: Array = [
		["Max HP",       def.max_hp],
		["Max Compute",  def.max_compute],
		["Move Speed",   def.move_speed],
		["Crit Chance",  def.crit_chance * 100.0],
		["Damage Mod",   def.damage_modifier],
		["Defense Mod",  def.defense_modifier],
		["Dash CD",      def.dash_cooldown],
		["Charge Time",  def.charge_time],
	]
	for row in rows:
		var hbox: HBoxContainer = HBoxContainer.new()
		var label: Label = Label.new()
		label.text = row[0]
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var value: Label = Label.new()
		value.text = "%.2f" % row[1]
		value.add_theme_color_override(&"font_color", def.color_accent)
		hbox.add_child(label)
		hbox.add_child(value)
		_stats_container.add_child(hbox)


func _on_confirm_pressed() -> void:
	if _selected_class_id == &"":
		return
	ClassRegistry.set_active_class(_selected_class_id)
	class_confirmed.emit(_selected_class_id)


func _on_cancel_pressed() -> void:
	class_select_cancelled.emit()
