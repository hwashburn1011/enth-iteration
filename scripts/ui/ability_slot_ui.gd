class_name AbilitySlotUI
extends Control
## Single ability slot display with icon, key label, and cooldown overlay.

@onready var _icon_bg: ColorRect = %IconBG
@onready var _key_label: Label = %KeyLabel
@onready var _cooldown_overlay: ColorRect = %CooldownOverlay
@onready var _name_label: Label = %NameLabel

var _cooldown_duration: float = 0.0
var _cooldown_remaining: float = 0.0
var _on_cooldown: bool = false


func _ready() -> void:
	_apply_slot_style()


func _apply_slot_style() -> void:
	# Wrap the slot in a styled panel border (drawn behind icon_bg)
	var border_panel: PanelContainer = PanelContainer.new()
	border_panel.name = "BorderPanel"
	border_panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	border_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	border_panel.show_behind_parent = true
	var bg_style: StyleBoxFlat = StyleBoxFlat.new()
	bg_style.bg_color = Color(0.06, 0.08, 0.14, 0.92)
	bg_style.border_color = Color(0.18, 0.45, 0.55, 0.85)
	bg_style.set_border_width_all(2)
	bg_style.set_corner_radius_all(5)
	border_panel.add_theme_stylebox_override(&"panel", bg_style)
	add_child(border_panel)
	move_child(border_panel, 0)

	if _icon_bg:
		_icon_bg.color = Color(0.0, 0.0, 0.0, 0.0)  # transparent — let border panel show
		# Inset the icon bg so the border is visible
		_icon_bg.offset_left = 3
		_icon_bg.offset_top = 3
		_icon_bg.offset_right = -3
		_icon_bg.offset_bottom = -3
	if _key_label:
		_key_label.add_theme_color_override(&"font_color", Color(0.65, 0.85, 0.9))
		_key_label.add_theme_color_override(&"font_outline_color", Color(0, 0, 0, 0.7))
		_key_label.add_theme_constant_override(&"outline_size", 2)
		_key_label.add_theme_font_size_override(&"font_size", 14)
	if _name_label:
		_name_label.add_theme_color_override(&"font_color", Color(0.85, 0.9, 0.95))
		_name_label.add_theme_color_override(&"font_outline_color", Color(0, 0, 0, 0.8))
		_name_label.add_theme_constant_override(&"outline_size", 2)
		_name_label.add_theme_font_size_override(&"font_size", 11)
	if _cooldown_overlay:
		_cooldown_overlay.color = Color(0, 0, 0, 0.65)


func _process(delta: float) -> void:
	if not _on_cooldown:
		return
	_cooldown_remaining -= delta
	if _cooldown_remaining <= 0.0:
		set_ready()
		return
	var ratio: float = _cooldown_remaining / _cooldown_duration
	_cooldown_overlay.anchor_top = 1.0 - ratio
	_cooldown_overlay.visible = true


func set_module(module: Resource, key_number: int) -> void:
	_key_label.text = str(key_number)
	_name_label.text = module.ability_name
	_icon_bg.color = Color(0.3, 0.4, 0.6, 1.0)
	_cooldown_overlay.visible = false
	_on_cooldown = false


func set_empty(key_number: int) -> void:
	_key_label.text = str(key_number)
	_name_label.text = ""
	_icon_bg.color = Color(0.2, 0.2, 0.2, 0.5)
	_cooldown_overlay.visible = false
	_on_cooldown = false


func start_cooldown(duration: float) -> void:
	_cooldown_duration = duration
	_cooldown_remaining = duration
	_on_cooldown = true
	_cooldown_overlay.visible = true
	_cooldown_overlay.anchor_top = 0.0


func set_ready() -> void:
	_on_cooldown = false
	_cooldown_overlay.visible = false
	# Brief flash
	var tween: Tween = create_tween()
	tween.tween_property(_icon_bg, "color", Color(0.6, 0.8, 1.0), 0.1)
	tween.tween_property(_icon_bg, "color", Color(0.3, 0.4, 0.6), 0.2)
