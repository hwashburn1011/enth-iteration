class_name KeyRebindPanel
extends Control
## R6 AA11-AA20 — Key rebinding panel with capture, persistence, and display settings.

const REBINDABLE_ACTIONS: Array[String] = [
	"attack_primary", "attack_secondary", "dash", "block",
	"interact", "use_prompt", "ability_1", "ability_2",
	"ability_3", "ability_4", "inventory", "pause",
]
const CONFIG_PATH: String = "user://keybinds.cfg"

var _capturing_action: String = ""
var _rows: Dictionary = {}  # action -> Label


func _ready() -> void:
	_build_ui()
	_load_bindings()


func _build_ui() -> void:
	var bg: ColorRect = ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0.03, 0.03, 0.08, 0.95)
	bg.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(bg)

	var title: Label = Label.new()
	title.text = "KEY BINDINGS"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.set_anchors_preset(Control.PRESET_TOP_WIDE)
	title.offset_top = 20
	title.offset_bottom = 55
	title.add_theme_font_size_override(&"font_size", 24)
	title.add_theme_color_override(&"font_color", Color(0.3, 0.85, 0.8))
	add_child(title)

	var y_offset: float = 70.0
	for action: String in REBINDABLE_ACTIONS:
		var row: HBoxContainer = HBoxContainer.new()
		row.position = Vector2(80, y_offset)
		row.size = Vector2(500, 30)

		var name_lbl: Label = Label.new()
		name_lbl.text = action.replace("_", " ").capitalize()
		name_lbl.add_theme_font_size_override(&"font_size", 16)
		name_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(name_lbl)

		var key_lbl: Label = Label.new()
		key_lbl.text = _get_current_key(action)
		key_lbl.add_theme_font_size_override(&"font_size", 16)
		key_lbl.add_theme_color_override(&"font_color", Color(0.9, 0.85, 0.3))
		row.add_child(key_lbl)
		_rows[action] = key_lbl

		var rebind_btn: Button = Button.new()
		rebind_btn.text = "Rebind"
		rebind_btn.size = Vector2(80, 28)
		var bound_action: String = action
		rebind_btn.pressed.connect(func() -> void: _start_capture(bound_action))
		row.add_child(rebind_btn)

		add_child(row)
		y_offset += 35.0

	# AA14: Reset to defaults button
	var reset_btn: Button = Button.new()
	reset_btn.text = "Reset to Defaults"
	reset_btn.position = Vector2(80, y_offset + 20)
	reset_btn.size = Vector2(160, 35)
	reset_btn.pressed.connect(_reset_defaults)
	add_child(reset_btn)

	# AA17: Mouse sensitivity slider
	var sens_lbl: Label = Label.new()
	sens_lbl.text = "Mouse Sensitivity"
	sens_lbl.position = Vector2(300, y_offset + 20)
	sens_lbl.add_theme_font_size_override(&"font_size", 16)
	add_child(sens_lbl)
	var sens_slider: HSlider = HSlider.new()
	sens_slider.position = Vector2(460, y_offset + 22)
	sens_slider.size = Vector2(150, 20)
	sens_slider.min_value = 0.1
	sens_slider.max_value = 3.0
	sens_slider.step = 0.1
	sens_slider.value = 1.0
	add_child(sens_slider)

	# AA19: Fullscreen toggle
	var fs_check: CheckBox = CheckBox.new()
	fs_check.text = "Fullscreen"
	fs_check.position = Vector2(80, y_offset + 65)
	fs_check.button_pressed = DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
	fs_check.toggled.connect(func(pressed: bool) -> void:
		if pressed:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	)
	add_child(fs_check)

	# AA20: VSync toggle
	var vsync_check: CheckBox = CheckBox.new()
	vsync_check.text = "VSync"
	vsync_check.position = Vector2(220, y_offset + 65)
	vsync_check.button_pressed = DisplayServer.vsync_mode_get() != DisplayServer.VSYNC_DISABLED
	vsync_check.toggled.connect(func(pressed: bool) -> void:
		DisplayServer.vsync_mode_set(DisplayServer.VSYNC_ENABLED if pressed else DisplayServer.VSYNC_DISABLED)
	)
	add_child(vsync_check)

	# AA18: Invert Y-axis toggle
	var invert_check: CheckBox = CheckBox.new()
	invert_check.text = "Invert Y-Axis"
	invert_check.position = Vector2(360, y_offset + 65)
	invert_check.toggled.connect(func(pressed: bool) -> void:
		GameManager.set_meta(&"invert_y_axis", pressed)
	)
	add_child(invert_check)

	# Close button
	var close_btn: Button = Button.new()
	close_btn.text = "Close"
	close_btn.position = Vector2(530, y_offset + 65)
	close_btn.size = Vector2(80, 35)
	close_btn.pressed.connect(queue_free)
	add_child(close_btn)


func _start_capture(action: String) -> void:
	_capturing_action = action
	if action in _rows:
		(_rows[action] as Label).text = "Press a key..."


func _unhandled_input(event: InputEvent) -> void:
	if _capturing_action.is_empty():
		return
	if event is InputEventKey and event.is_pressed():
		var key_event: InputEventKey = event as InputEventKey
		# AA16: Check for conflicts
		for other_action: String in REBINDABLE_ACTIONS:
			if other_action == _capturing_action:
				continue
			for existing: InputEvent in InputMap.action_get_events(other_action):
				if existing is InputEventKey and (existing as InputEventKey).keycode == key_event.keycode:
					InputMap.action_erase_event(other_action, existing)
					if other_action in _rows:
						(_rows[other_action] as Label).text = "—"
		# Apply new binding
		InputMap.action_erase_events(_capturing_action)
		InputMap.action_add_event(_capturing_action, key_event)
		if _capturing_action in _rows:
			(_rows[_capturing_action] as Label).text = OS.get_keycode_string(key_event.keycode)
		_capturing_action = ""
		_save_bindings()
		get_viewport().set_input_as_handled()


func _get_current_key(action: String) -> String:
	if not InputMap.has_action(action):
		return "—"
	var events: Array[InputEvent] = InputMap.action_get_events(action)
	for ev: InputEvent in events:
		if ev is InputEventKey:
			return OS.get_keycode_string((ev as InputEventKey).keycode)
	return "—"


## AA13: Save custom bindings.
func _save_bindings() -> void:
	var config: ConfigFile = ConfigFile.new()
	for action: String in REBINDABLE_ACTIONS:
		var events: Array[InputEvent] = InputMap.action_get_events(action)
		for ev: InputEvent in events:
			if ev is InputEventKey:
				config.set_value("keybinds", action, (ev as InputEventKey).keycode)
				break
	config.save(CONFIG_PATH)


## AA13: Load saved bindings.
func _load_bindings() -> void:
	var config: ConfigFile = ConfigFile.new()
	if config.load(CONFIG_PATH) != OK:
		return
	for action: String in REBINDABLE_ACTIONS:
		if not config.has_section_key("keybinds", action):
			continue
		var keycode: int = int(config.get_value("keybinds", action, 0))
		if keycode == 0:
			continue
		InputMap.action_erase_events(action)
		var ev: InputEventKey = InputEventKey.new()
		ev.keycode = keycode as Key
		InputMap.action_add_event(action, ev)
		if action in _rows:
			(_rows[action] as Label).text = OS.get_keycode_string(keycode as Key)


## AA14: Reset all bindings to project.godot defaults.
func _reset_defaults() -> void:
	InputMap.load_from_project_settings()
	for action: String in _rows:
		(_rows[action] as Label).text = _get_current_key(action)
	# Delete saved config
	if FileAccess.file_exists(CONFIG_PATH):
		DirAccess.remove_absolute(CONFIG_PATH)
