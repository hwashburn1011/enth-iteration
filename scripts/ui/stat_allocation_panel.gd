class_name StatAllocationPanel
extends CanvasLayer
## Panel for allocating stat points on level-up. Pauses game while open.

var _player: CharacterBody3D = null
var _panel: PanelContainer = null
var _points_label: Label = null
var _stat_labels: Dictionary = {}

const STATS: Array[String] = ["processing", "bandwidth", "memory", "integrity"]


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
	_panel.offset_left = -180.0
	_panel.offset_top = -140.0
	_panel.offset_right = 180.0
	_panel.offset_bottom = 140.0
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
		var hbox: HBoxContainer = HBoxContainer.new()
		var name_label: Label = Label.new()
		name_label.text = stat_name.capitalize()
		name_label.custom_minimum_size = Vector2(120, 0)
		hbox.add_child(name_label)

		var value_label: Label = Label.new()
		value_label.text = str(int(_player.stats_component.get_stat(stat_name)))
		value_label.custom_minimum_size = Vector2(40, 0)
		value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		hbox.add_child(value_label)
		_stat_labels[stat_name] = value_label

		var plus_btn: Button = Button.new()
		plus_btn.text = "+"
		plus_btn.custom_minimum_size = Vector2(30, 30)
		plus_btn.pressed.connect(_on_allocate.bind(stat_name))
		hbox.add_child(plus_btn)

		vbox.add_child(hbox)

	var confirm: Button = Button.new()
	confirm.text = "Confirm"
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
