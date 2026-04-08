class_name StatAllocationPanel
extends CanvasLayer
## Panel for allocating stat points on level-up. Pauses game while open.

var _player: CharacterBody3D = null
var _panel: PanelContainer = null
var _points_label: Label = null
var _stat_labels: Dictionary = {}

const STATS: Array[String] = ["processing", "bandwidth", "memory", "integrity"]
const STAT_COLORS: Dictionary = {
	"processing": Color(0.3, 0.85, 0.85),
	"bandwidth": Color(0.3, 0.85, 0.4),
	"memory": Color(0.6, 0.4, 0.85),
	"integrity": Color(0.85, 0.6, 0.2),
}
const STAT_DESCRIPTIONS: Dictionary = {
	"processing": "Damage output",
	"bandwidth": "Movement speed",
	"memory": "Compute pool",
	"integrity": "Health & defense",
}


func show_panel(player: CharacterBody3D) -> void:
	_player = player
	get_tree().paused = true
	GameManager.set_state(GameManager.GameState.INVENTORY)
	_build_ui()


func _build_ui() -> void:
	layer = 60
	process_mode = Node.PROCESS_MODE_ALWAYS

	var fullscreen: Control = Control.new()
	fullscreen.set_anchors_preset(Control.PRESET_FULL_RECT)
	fullscreen.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(fullscreen)
	var dim: ColorRect = ColorRect.new()
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim.color = Color(0.02, 0.02, 0.06, 0.7)
	fullscreen.add_child(dim)

	_panel = PanelContainer.new()
	_panel.set_anchors_preset(Control.PRESET_CENTER)
	_panel.offset_left = -210.0
	_panel.offset_top = -190.0
	_panel.offset_right = 210.0
	_panel.offset_bottom = 190.0
	var panel_style: StyleBoxFlat = StyleBoxFlat.new()
	panel_style.bg_color = Color(0.06, 0.07, 0.14, 0.95)
	panel_style.border_color = Color(0.15, 0.4, 0.5, 0.7)
	panel_style.set_border_width_all(2)
	panel_style.set_corner_radius_all(6)
	panel_style.set_content_margin_all(14)
	_panel.add_theme_stylebox_override(&"panel", panel_style)

	var vbox: VBoxContainer = VBoxContainer.new()
	vbox.add_theme_constant_override(&"separation", 8)

	var title: Label = Label.new()
	title.text = "Level Up! Allocate Stat Points"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_color_override(&"font_color", Color(1.0, 0.85, 0.2))
	title.add_theme_font_size_override(&"font_size", 20)
	vbox.add_child(title)

	_points_label = Label.new()
	_update_points_label()
	_points_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(_points_label)

	var spacer: Control = Control.new()
	spacer.custom_minimum_size = Vector2(0, 8)
	vbox.add_child(spacer)

	for stat_name: String in STATS:
		var stat_color: Color = STAT_COLORS.get(stat_name, Color.WHITE) as Color
		var row_vbox: VBoxContainer = VBoxContainer.new()
		row_vbox.add_theme_constant_override(&"separation", 0)

		var hbox: HBoxContainer = HBoxContainer.new()
		hbox.add_theme_constant_override(&"separation", 8)

		var name_label: Label = Label.new()
		name_label.text = stat_name.capitalize()
		name_label.custom_minimum_size = Vector2(120, 0)
		name_label.add_theme_color_override(&"font_color", stat_color)
		name_label.add_theme_font_size_override(&"font_size", 16)
		hbox.add_child(name_label)

		var value_label: Label = Label.new()
		value_label.text = str(int(_player.stats_component.get_stat(stat_name)))
		value_label.custom_minimum_size = Vector2(50, 0)
		value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		value_label.add_theme_font_size_override(&"font_size", 18)
		hbox.add_child(value_label)
		_stat_labels[stat_name] = value_label

		var plus_btn: Button = Button.new()
		plus_btn.text = "+"
		plus_btn.custom_minimum_size = Vector2(36, 32)
		_style_plus_button(plus_btn, stat_color)
		plus_btn.pressed.connect(_on_allocate.bind(stat_name))
		hbox.add_child(plus_btn)

		row_vbox.add_child(hbox)

		var desc_label: Label = Label.new()
		desc_label.text = "  " + STAT_DESCRIPTIONS.get(stat_name, "")
		desc_label.add_theme_font_size_override(&"font_size", 11)
		desc_label.modulate = Color(0.65, 0.7, 0.78)
		row_vbox.add_child(desc_label)

		vbox.add_child(row_vbox)

	var confirm_spacer: Control = Control.new()
	confirm_spacer.custom_minimum_size = Vector2(0, 6)
	vbox.add_child(confirm_spacer)

	var confirm: Button = Button.new()
	confirm.text = "Confirm"
	confirm.custom_minimum_size = Vector2(0, 36)
	_style_confirm_button(confirm)
	confirm.pressed.connect(_on_confirm)
	vbox.add_child(confirm)

	_panel.add_child(vbox)
	fullscreen.add_child(_panel)


func _on_allocate(stat_name: String) -> void:
	var level_comp: Node = _player.get_node_or_null("LevelComponent") as Node
	if level_comp == null or level_comp.unspent_stat_points <= 0:
		return
	_player.stats_component.allocate_point(stat_name)
	level_comp.unspent_stat_points -= 1
	_stat_labels[stat_name].text = str(int(_player.stats_component.get_stat(stat_name)))
	_update_points_label()


func _on_confirm() -> void:
	get_tree().paused = false
	GameManager.set_state(GameManager.GameState.PLAYING)
	queue_free()


func _update_points_label() -> void:
	var level_comp: Node = _player.get_node_or_null("LevelComponent") as Node
	var pts: int = level_comp.unspent_stat_points if level_comp else 0
	_points_label.text = "Unspent Points: %d" % pts


func _style_plus_button(btn: Button, accent: Color) -> void:
	var normal: StyleBoxFlat = StyleBoxFlat.new()
	normal.bg_color = Color(0.08, 0.12, 0.18, 0.95)
	normal.border_color = Color(accent.r, accent.g, accent.b, 0.7)
	normal.set_border_width_all(2)
	normal.set_corner_radius_all(4)
	var hover: StyleBoxFlat = StyleBoxFlat.new()
	hover.bg_color = Color(accent.r * 0.3, accent.g * 0.3, accent.b * 0.3, 0.95)
	hover.border_color = accent
	hover.set_border_width_all(2)
	hover.set_corner_radius_all(4)
	var pressed: StyleBoxFlat = StyleBoxFlat.new()
	pressed.bg_color = Color(accent.r * 0.5, accent.g * 0.5, accent.b * 0.5, 1.0)
	pressed.border_color = accent
	pressed.set_border_width_all(2)
	pressed.set_corner_radius_all(4)
	btn.add_theme_stylebox_override(&"normal", normal)
	btn.add_theme_stylebox_override(&"hover", hover)
	btn.add_theme_stylebox_override(&"pressed", pressed)
	btn.add_theme_color_override(&"font_color", accent)
	btn.add_theme_color_override(&"font_hover_color", Color.WHITE)
	btn.add_theme_font_size_override(&"font_size", 18)


func _style_confirm_button(btn: Button) -> void:
	var accent: Color = Color(1.0, 0.85, 0.2)
	var normal: StyleBoxFlat = StyleBoxFlat.new()
	normal.bg_color = Color(0.12, 0.1, 0.04, 0.95)
	normal.border_color = Color(accent.r, accent.g, accent.b, 0.7)
	normal.set_border_width_all(2)
	normal.set_corner_radius_all(5)
	normal.set_content_margin_all(8)
	var hover: StyleBoxFlat = StyleBoxFlat.new()
	hover.bg_color = Color(0.25, 0.2, 0.05, 0.95)
	hover.border_color = accent
	hover.set_border_width_all(2)
	hover.set_corner_radius_all(5)
	hover.set_content_margin_all(8)
	var pressed: StyleBoxFlat = StyleBoxFlat.new()
	pressed.bg_color = Color(0.35, 0.28, 0.08, 1.0)
	pressed.border_color = accent
	pressed.set_border_width_all(2)
	pressed.set_corner_radius_all(5)
	pressed.set_content_margin_all(8)
	btn.add_theme_stylebox_override(&"normal", normal)
	btn.add_theme_stylebox_override(&"hover", hover)
	btn.add_theme_stylebox_override(&"pressed", pressed)
	btn.add_theme_color_override(&"font_color", accent)
	btn.add_theme_color_override(&"font_hover_color", Color.WHITE)
	btn.add_theme_font_size_override(&"font_size", 16)
