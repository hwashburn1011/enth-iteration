class_name PauseMenu
extends CanvasLayer
## Esc pause menu with Resume, Settings, and Quit. Works while paused.

var _panel: Control = null
var _settings_panel: PanelContainer = null

static var _instance: Node = null


func _ready() -> void:
	layer = 70
	process_mode = Node.PROCESS_MODE_ALWAYS
	_instance = self
	_build_ui()
	get_tree().paused = true
	GameManager.set_state(GameManager.GameState.PAUSED)


func _exit_tree() -> void:
	if _instance == self:
		_instance = null


func _unhandled_input(event: InputEvent) -> void:
	if _panel == null:
		return
	if event.is_action_pressed(&"pause"):
		_resume()
		get_viewport().set_input_as_handled()


static func is_open() -> bool:
	return _instance != null


func _build_ui() -> void:
	_panel = Control.new()
	_panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	_panel.mouse_filter = Control.MOUSE_FILTER_STOP

	var bg: ColorRect = ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0, 0, 0, 0.5)
	_panel.add_child(bg)

	var container: PanelContainer = PanelContainer.new()
	container.set_anchors_preset(Control.PRESET_CENTER)
	container.offset_left = -160.0
	container.offset_top = -140.0
	container.offset_right = 160.0
	container.offset_bottom = 140.0
	var panel_style: StyleBoxFlat = StyleBoxFlat.new()
	panel_style.bg_color = Color(0.05, 0.06, 0.12, 0.95)
	panel_style.border_color = Color(0.15, 0.45, 0.55, 0.8)
	panel_style.set_border_width_all(2)
	panel_style.set_corner_radius_all(8)
	panel_style.set_content_margin_all(20)
	container.add_theme_stylebox_override(&"panel", panel_style)

	var vbox: VBoxContainer = VBoxContainer.new()
	vbox.add_theme_constant_override(&"separation", 14)
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER

	var title: Label = Label.new()
	title.text = "PAUSED"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_color_override(&"font_color", Color(0.3, 0.85, 0.8))
	title.add_theme_font_size_override(&"font_size", 28)
	vbox.add_child(title)

	var resume_btn: Button = Button.new()
	resume_btn.text = "Resume"
	resume_btn.pressed.connect(_resume)
	_style_pause_button(resume_btn)
	vbox.add_child(resume_btn)

	var settings_btn: Button = Button.new()
	settings_btn.text = "Settings"
	settings_btn.pressed.connect(_toggle_settings)
	_style_pause_button(settings_btn)
	vbox.add_child(settings_btn)

	var menu_btn: Button = Button.new()
	menu_btn.text = "Quit to Main Menu"
	menu_btn.pressed.connect(_quit_to_menu)
	_style_pause_button(menu_btn)
	vbox.add_child(menu_btn)

	var quit_btn: Button = Button.new()
	quit_btn.text = "Quit to Desktop"
	quit_btn.pressed.connect(_quit)
	_style_pause_button(quit_btn)
	vbox.add_child(quit_btn)

	container.add_child(vbox)
	_panel.add_child(container)
	add_child(_panel)
	resume_btn.grab_focus()


func _resume() -> void:
	get_tree().paused = false
	GameManager.set_state(GameManager.GameState.PLAYING)
	_instance = null
	queue_free()


func _quit_to_menu() -> void:
	SaveManager.save_game()
	get_tree().paused = false
	_instance = null
	GameManager.change_scene_to("res://scenes/main/MainMenu.tscn")
	queue_free()


func _quit() -> void:
	SaveManager.save_game()
	get_tree().quit()


func _toggle_settings() -> void:
	if _settings_panel:
		_settings_panel.queue_free()
		_settings_panel = null
		return

	_settings_panel = PanelContainer.new()
	_settings_panel.set_anchors_preset(Control.PRESET_CENTER)
	_settings_panel.offset_left = -180.0
	_settings_panel.offset_top = 50.0
	_settings_panel.offset_right = 180.0
	_settings_panel.offset_bottom = 250.0

	var vbox: VBoxContainer = VBoxContainer.new()
	vbox.add_theme_constant_override(&"separation", 10)

	var stitle: Label = Label.new()
	stitle.text = "Settings"
	stitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(stitle)

	# Volume sliders
	_add_slider(vbox, "Master Volume", 0, func(val: float) -> void: _set_bus_volume("Master", val))
	_add_slider(vbox, "Music Volume", 1, func(val: float) -> void: _set_bus_volume("Music", val))
	_add_slider(vbox, "SFX Volume", 2, func(val: float) -> void: _set_bus_volume("SFX", val))

	# Fullscreen toggle
	var fs_check: CheckButton = CheckButton.new()
	fs_check.text = "Fullscreen"
	fs_check.button_pressed = DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
	fs_check.toggled.connect(_on_fullscreen_toggled)
	vbox.add_child(fs_check)

	_settings_panel.add_child(vbox)
	_panel.add_child(_settings_panel)


func _add_slider(parent: VBoxContainer, label_text: String, bus_index: int, callback: Callable) -> void:
	var hbox: HBoxContainer = HBoxContainer.new()
	var lbl: Label = Label.new()
	lbl.text = label_text
	lbl.custom_minimum_size = Vector2(110, 0)
	hbox.add_child(lbl)

	var slider: HSlider = HSlider.new()
	slider.min_value = 0.0
	slider.max_value = 1.0
	slider.step = 0.05
	slider.value = db_to_linear(AudioServer.get_bus_volume_db(bus_index)) if bus_index < AudioServer.bus_count else 1.0
	slider.custom_minimum_size = Vector2(120, 0)
	slider.value_changed.connect(callback)
	hbox.add_child(slider)

	parent.add_child(hbox)


func _set_bus_volume(bus_name: String, linear_value: float) -> void:
	var bus_idx: int = AudioServer.get_bus_index(bus_name)
	if bus_idx >= 0:
		AudioServer.set_bus_volume_db(bus_idx, linear_to_db(linear_value))


func _on_fullscreen_toggled(pressed: bool) -> void:
	if pressed:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)


func _style_pause_button(btn: Button) -> void:
	var normal: StyleBoxFlat = StyleBoxFlat.new()
	normal.bg_color = Color(0.1, 0.11, 0.2, 0.9)
	normal.border_color = Color(0.18, 0.45, 0.55, 0.5)
	normal.set_border_width_all(2)
	normal.set_corner_radius_all(5)
	normal.set_content_margin_all(10)
	var hover: StyleBoxFlat = StyleBoxFlat.new()
	hover.bg_color = Color(0.14, 0.16, 0.3, 0.95)
	hover.border_color = Color(0.25, 0.65, 0.75, 0.9)
	hover.set_border_width_all(2)
	hover.set_corner_radius_all(5)
	hover.set_content_margin_all(10)
	var pressed: StyleBoxFlat = StyleBoxFlat.new()
	pressed.bg_color = Color(0.08, 0.2, 0.3, 1.0)
	pressed.border_color = Color(0.35, 0.85, 0.95, 1.0)
	pressed.set_border_width_all(2)
	pressed.set_corner_radius_all(5)
	pressed.set_content_margin_all(10)
	var focus: StyleBoxFlat = hover.duplicate() as StyleBoxFlat
	focus.set_border_width_all(3)
	btn.add_theme_stylebox_override(&"normal", normal)
	btn.add_theme_stylebox_override(&"hover", hover)
	btn.add_theme_stylebox_override(&"pressed", pressed)
	btn.add_theme_stylebox_override(&"focus", focus)
	btn.add_theme_color_override(&"font_color", Color(0.8, 0.85, 0.9))
	btn.add_theme_color_override(&"font_hover_color", Color(0.3, 0.9, 0.85))
	btn.add_theme_font_size_override(&"font_size", 18)
	btn.custom_minimum_size = Vector2(220, 0)
