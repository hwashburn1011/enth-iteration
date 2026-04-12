class_name PauseMenu
extends CanvasLayer
## Esc pause menu with Resume, Settings, and Quit. Works while paused.

var _panel: Control = null
var _settings_panel: PanelContainer = null
var _controls_panel: PanelContainer = null

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

	var controls_btn: Button = Button.new()
	controls_btn.text = "Controls"
	controls_btn.pressed.connect(_toggle_controls)
	_style_pause_button(controls_btn)
	vbox.add_child(controls_btn)

	# Task71: Statistics button
	var stats_btn: Button = Button.new()
	stats_btn.text = "Statistics"
	stats_btn.pressed.connect(_open_statistics)
	_style_pause_button(stats_btn)
	vbox.add_child(stats_btn)

	# Task72: Skill Tree button
	var tree_btn: Button = Button.new()
	tree_btn.text = "Skill Tree"
	tree_btn.pressed.connect(_open_skill_tree)
	_style_pause_button(tree_btn)
	vbox.add_child(tree_btn)

	# A4: Bestiary button
	var bestiary_btn: Button = Button.new()
	bestiary_btn.text = "Bestiary"
	bestiary_btn.pressed.connect(_open_bestiary)
	_style_pause_button(bestiary_btn)
	vbox.add_child(bestiary_btn)

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
	# Task75: Show confirmation dialog before quitting
	ReleaseUI.show_quit_dialog(self)


## Task71: Open statistics panel showing play stats.
func _open_statistics() -> void:
	var panel: Control = Control.new()
	panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	var bg: ColorRect = ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0.02, 0.02, 0.06, 0.95)
	bg.mouse_filter = Control.MOUSE_FILTER_STOP
	panel.add_child(bg)
	var title: Label = Label.new()
	title.text = "STATISTICS"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.set_anchors_preset(Control.PRESET_CENTER_TOP)
	title.offset_top = 30
	title.offset_bottom = 60
	title.add_theme_font_size_override(&"font_size", 24)
	title.add_theme_color_override(&"font_color", Color(0.3, 0.85, 0.8))
	panel.add_child(title)
	var vbox: VBoxContainer = VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_CENTER)
	vbox.offset_left = -200
	vbox.offset_right = 200
	vbox.offset_top = -80
	vbox.offset_bottom = 80
	panel.add_child(vbox)
	HudWidgets.populate_stats_panel(vbox)
	var close_btn: Button = Button.new()
	close_btn.text = "Close"
	close_btn.pressed.connect(panel.queue_free)
	vbox.add_child(close_btn)
	add_child(panel)


## Task72: Open skill tree panel.
func _open_skill_tree() -> void:
	var panel: Control = SkillTreePanel.new()
	get_tree().root.add_child(panel)


## A4: Open bestiary panel showing discovered enemies.
func _open_bestiary() -> void:
	var bestiary: Control = Control.new()
	bestiary.set_script(load("res://scripts/ui/bestiary_screen.gd"))
	bestiary.set_anchors_preset(Control.PRESET_FULL_RECT)

	# Build required node structure that bestiary_screen.gd expects via %UniqueNames
	var bg: ColorRect = ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0.02, 0.02, 0.06, 0.95)
	bg.mouse_filter = Control.MOUSE_FILTER_STOP
	bestiary.add_child(bg)

	var entry_list: ItemList = ItemList.new()
	entry_list.unique_name_in_owner = true
	entry_list.name = "EntryList"
	entry_list.set_anchors_preset(Control.PRESET_LEFT_WIDE)
	entry_list.offset_right = 250.0
	entry_list.offset_top = 20.0
	entry_list.offset_bottom = -20.0
	entry_list.add_theme_color_override(&"font_color", Color(0.8, 0.85, 0.9))
	bestiary.add_child(entry_list)

	var detail: VBoxContainer = VBoxContainer.new()
	detail.unique_name_in_owner = true
	detail.name = "DetailContainer"
	detail.set_anchors_preset(Control.PRESET_RIGHT_WIDE)
	detail.offset_left = 270.0
	detail.offset_top = 20.0
	detail.offset_right = -20.0
	detail.offset_bottom = -60.0
	detail.add_theme_constant_override(&"separation", 8)
	bestiary.add_child(detail)

	var hero_render: TextureRect = TextureRect.new()
	hero_render.unique_name_in_owner = true
	hero_render.name = "HeroRender"
	hero_render.custom_minimum_size = Vector2(128, 128)
	hero_render.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	detail.add_child(hero_render)

	var display_name: Label = Label.new()
	display_name.unique_name_in_owner = true
	display_name.name = "DisplayName"
	display_name.add_theme_font_size_override(&"font_size", 22)
	display_name.add_theme_color_override(&"font_color", Color(0.3, 0.85, 0.8))
	detail.add_child(display_name)

	var tagline: Label = Label.new()
	tagline.unique_name_in_owner = true
	tagline.name = "Tagline"
	tagline.add_theme_color_override(&"font_color", Color(0.6, 0.65, 0.7))
	detail.add_child(tagline)

	var tuning_summary: Label = Label.new()
	tuning_summary.unique_name_in_owner = true
	tuning_summary.name = "TuningSummary"
	tuning_summary.add_theme_font_size_override(&"font_size", 14)
	tuning_summary.add_theme_color_override(&"font_color", Color(0.7, 0.75, 0.8))
	detail.add_child(tuning_summary)

	var encounter_notes: RichTextLabel = RichTextLabel.new()
	encounter_notes.unique_name_in_owner = true
	encounter_notes.name = "EncounterNotes"
	encounter_notes.custom_minimum_size = Vector2(0, 60)
	encounter_notes.bbcode_enabled = true
	detail.add_child(encounter_notes)

	var lore_flavor: RichTextLabel = RichTextLabel.new()
	lore_flavor.unique_name_in_owner = true
	lore_flavor.name = "LoreFlavor"
	lore_flavor.custom_minimum_size = Vector2(0, 60)
	lore_flavor.bbcode_enabled = true
	detail.add_child(lore_flavor)

	var close_btn: Button = Button.new()
	close_btn.unique_name_in_owner = true
	close_btn.name = "CloseButton"
	close_btn.text = "Close"
	close_btn.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	close_btn.offset_left = -100.0
	close_btn.offset_top = -40.0
	bestiary.add_child(close_btn)

	get_tree().root.add_child(bestiary)


func _toggle_settings() -> void:
	if _settings_panel:
		_settings_panel.queue_free()
		_settings_panel = null
		return

	_settings_panel = PanelContainer.new()
	# Place to the right of the pause menu, vertically centered
	_settings_panel.set_anchors_preset(Control.PRESET_CENTER)
	_settings_panel.offset_left = 200.0
	_settings_panel.offset_top = -150.0
	_settings_panel.offset_right = 540.0
	_settings_panel.offset_bottom = 150.0
	var settings_style: StyleBoxFlat = StyleBoxFlat.new()
	settings_style.bg_color = Color(0.05, 0.06, 0.12, 0.96)
	settings_style.border_color = Color(0.15, 0.45, 0.55, 0.8)
	settings_style.set_border_width_all(2)
	settings_style.set_corner_radius_all(8)
	settings_style.set_content_margin_all(16)
	_settings_panel.add_theme_stylebox_override(&"panel", settings_style)

	var vbox: VBoxContainer = VBoxContainer.new()
	vbox.add_theme_constant_override(&"separation", 12)

	var stitle: Label = Label.new()
	stitle.text = "SETTINGS"
	stitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	stitle.add_theme_color_override(&"font_color", Color(0.3, 0.85, 0.8))
	stitle.add_theme_color_override(&"font_outline_color", Color(0, 0, 0, 0.7))
	stitle.add_theme_constant_override(&"outline_size", 3)
	stitle.add_theme_font_size_override(&"font_size", 22)
	vbox.add_child(stitle)

	var sep: HSeparator = HSeparator.new()
	vbox.add_child(sep)

	# Volume sliders
	_add_slider(vbox, "Master Volume", 0, func(val: float) -> void: _set_bus_volume("Master", val))
	_add_slider(vbox, "Music Volume", 1, func(val: float) -> void: _set_bus_volume("Music", val))
	_add_slider(vbox, "SFX Volume", 2, func(val: float) -> void: _set_bus_volume("SFX", val))

	var sep2: HSeparator = HSeparator.new()
	vbox.add_child(sep2)

	# Phase 4 #38 — Camera zoom speed slider
	_add_zoom_slider(vbox)

	var sep3: HSeparator = HSeparator.new()
	vbox.add_child(sep3)

	# Fullscreen toggle
	var fs_check: CheckButton = CheckButton.new()
	fs_check.text = "Fullscreen"
	fs_check.button_pressed = DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
	fs_check.toggled.connect(_on_fullscreen_toggled)
	fs_check.add_theme_color_override(&"font_color", Color(0.85, 0.9, 0.95))
	fs_check.add_theme_color_override(&"font_hover_color", Color(0.3, 0.85, 0.85))
	fs_check.add_theme_font_size_override(&"font_size", 16)
	vbox.add_child(fs_check)

	# Phase 4 #38 — stub key rebind
	var sep4: HSeparator = HSeparator.new()
	vbox.add_child(sep4)
	var rebind_lbl: Label = Label.new()
	rebind_lbl.text = "Key Rebind — coming soon"
	rebind_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	rebind_lbl.add_theme_color_override(&"font_color", Color(0.5, 0.55, 0.6))
	rebind_lbl.add_theme_font_size_override(&"font_size", 13)
	vbox.add_child(rebind_lbl)

	_settings_panel.add_child(vbox)
	_panel.add_child(_settings_panel)


## Phase 4 #37 — controls list panel showing all key bindings.
func _toggle_controls() -> void:
	# Close settings if open
	if _settings_panel:
		_settings_panel.queue_free()
		_settings_panel = null
	if _controls_panel:
		_controls_panel.queue_free()
		_controls_panel = null
		return

	_controls_panel = PanelContainer.new()
	_controls_panel.set_anchors_preset(Control.PRESET_CENTER)
	_controls_panel.offset_left = 200.0
	_controls_panel.offset_top = -220.0
	_controls_panel.offset_right = 560.0
	_controls_panel.offset_bottom = 220.0
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color(0.05, 0.06, 0.12, 0.96)
	style.border_color = Color(0.15, 0.45, 0.55, 0.8)
	style.set_border_width_all(2)
	style.set_corner_radius_all(8)
	style.set_content_margin_all(16)
	_controls_panel.add_theme_stylebox_override(&"panel", style)

	var scroll: ScrollContainer = ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(320, 400)
	_controls_panel.add_child(scroll)

	var vbox: VBoxContainer = VBoxContainer.new()
	vbox.add_theme_constant_override(&"separation", 4)
	scroll.add_child(vbox)

	var ctitle: Label = Label.new()
	ctitle.text = "CONTROLS"
	ctitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ctitle.add_theme_color_override(&"font_color", Color(0.3, 0.85, 0.8))
	ctitle.add_theme_font_size_override(&"font_size", 22)
	vbox.add_child(ctitle)

	var sep: HSeparator = HSeparator.new()
	vbox.add_child(sep)

	var bindings: Array[Array] = [
		["Move", "W A S D"],
		["Attack", "Left Click"],
		["Heavy Attack", "Right Click (hold)"],
		["Dash", "Space"],
		["Block / Parry", "F"],
		["Interact / Talk", "E"],
		["Use Health Prompt", "Q"],
		["Ability 1-4", "1 2 3 4"],
		["Inventory", "Tab / I"],
		["Quest Log", "J"],
		["Pause", "Escape"],
		["Zoom In/Out", "Mouse Wheel"],
	]
	for binding: Array in bindings:
		_add_control_row(vbox, str(binding[0]), str(binding[1]))

	_panel.add_child(_controls_panel)


## Phase 4 #38 — camera zoom speed slider. Adjusts IsometricCamera.ZOOM_STEP.
func _add_zoom_slider(parent: VBoxContainer) -> void:
	var hbox: HBoxContainer = HBoxContainer.new()
	hbox.add_theme_constant_override(&"separation", 10)
	var lbl: Label = Label.new()
	lbl.text = "Zoom Speed"
	lbl.custom_minimum_size = Vector2(130, 0)
	lbl.add_theme_color_override(&"font_color", Color(0.85, 0.9, 0.95))
	lbl.add_theme_font_size_override(&"font_size", 15)
	hbox.add_child(lbl)
	var slider: HSlider = HSlider.new()
	slider.min_value = 0.5
	slider.max_value = 3.0
	slider.step = 0.25
	slider.value = 1.5
	# Try to read from an active camera
	var cam: Camera3D = get_viewport().get_camera_3d()
	if cam and &"ZOOM_STEP" in cam:
		slider.value = float(cam.get(&"ZOOM_STEP"))
	slider.custom_minimum_size = Vector2(150, 0)
	slider.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	slider.value_changed.connect(_on_zoom_speed_changed)
	hbox.add_child(slider)
	var pct: Label = Label.new()
	pct.text = "%.1f" % slider.value
	pct.custom_minimum_size = Vector2(40, 0)
	pct.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	pct.add_theme_color_override(&"font_color", Color(0.55, 0.85, 0.85))
	pct.add_theme_font_size_override(&"font_size", 14)
	slider.value_changed.connect(func(val: float) -> void: pct.text = "%.1f" % val)
	hbox.add_child(pct)
	parent.add_child(hbox)


func _on_zoom_speed_changed(value: float) -> void:
	# ZOOM_STEP is a const on IsometricCamera but we can't change consts at
	# runtime. Instead use a project-level meta that the camera reads.
	ProjectSettings.set_setting("application/zoom_speed_override", value)


func _add_control_row(parent: VBoxContainer, action_name: String, key_text: String) -> void:
	var hbox: HBoxContainer = HBoxContainer.new()
	hbox.add_theme_constant_override(&"separation", 8)
	var action_lbl: Label = Label.new()
	action_lbl.text = action_name
	action_lbl.custom_minimum_size = Vector2(160, 0)
	action_lbl.add_theme_color_override(&"font_color", Color(0.85, 0.9, 0.95))
	action_lbl.add_theme_font_size_override(&"font_size", 14)
	hbox.add_child(action_lbl)
	var key_lbl: Label = Label.new()
	key_lbl.text = key_text
	key_lbl.add_theme_color_override(&"font_color", Color(0.4, 0.85, 0.8))
	key_lbl.add_theme_font_size_override(&"font_size", 14)
	hbox.add_child(key_lbl)
	parent.add_child(hbox)


func _add_slider(parent: VBoxContainer, label_text: String, bus_index: int, callback: Callable) -> void:
	var hbox: HBoxContainer = HBoxContainer.new()
	hbox.add_theme_constant_override(&"separation", 10)
	var lbl: Label = Label.new()
	lbl.text = label_text
	lbl.custom_minimum_size = Vector2(130, 0)
	lbl.add_theme_color_override(&"font_color", Color(0.85, 0.9, 0.95))
	lbl.add_theme_font_size_override(&"font_size", 15)
	hbox.add_child(lbl)

	var slider: HSlider = HSlider.new()
	slider.min_value = 0.0
	slider.max_value = 1.0
	slider.step = 0.05
	slider.value = db_to_linear(AudioServer.get_bus_volume_db(bus_index)) if bus_index < AudioServer.bus_count else 1.0
	slider.custom_minimum_size = Vector2(150, 0)
	slider.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	slider.value_changed.connect(callback)
	hbox.add_child(slider)

	# Live percentage label
	var pct: Label = Label.new()
	pct.text = "%d%%" % int(slider.value * 100)
	pct.custom_minimum_size = Vector2(40, 0)
	pct.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	pct.add_theme_color_override(&"font_color", Color(0.55, 0.85, 0.85))
	pct.add_theme_font_size_override(&"font_size", 14)
	slider.value_changed.connect(func(val: float) -> void: pct.text = "%d%%" % int(val * 100))
	hbox.add_child(pct)

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
