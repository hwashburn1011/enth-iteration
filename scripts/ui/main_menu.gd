extends Control
## Main menu UI — title screen with New Game, Continue, and Quit buttons.

@onready var _new_game_button: Button = %NewGameButton
@onready var _continue_button: Button = %ContinueButton
@onready var _quit_button: Button = %QuitButton


func _ready() -> void:
	GameManager.set_state(GameManager.GameState.MAIN_MENU)
	_apply_menu_theme()
	_new_game_button.pressed.connect(_on_new_game_pressed)
	_continue_button.pressed.connect(_on_continue_pressed)
	_quit_button.pressed.connect(_on_quit_pressed)

	# Show/hide continue based on save existence
	_continue_button.visible = SaveManager.has_valid_save()

	if _continue_button.visible:
		_continue_button.grab_focus()
	else:
		_new_game_button.grab_focus()


func _apply_menu_theme() -> void:
	# Dark blue-purple background
	var bg: ColorRect = get_node_or_null("Background") as ColorRect
	if bg:
		bg.color = Color(0.06, 0.05, 0.12)

	# Title styling
	var title: Label = get_node_or_null("VBoxContainer/TitleLabel") as Label
	if title:
		title.add_theme_font_size_override(&"font_size", 52)
		title.add_theme_color_override(&"font_color", Color(0.3, 0.85, 0.8))
		title.add_theme_color_override(&"font_shadow_color", Color(0.1, 0.4, 0.4, 0.5))
		title.add_theme_constant_override(&"shadow_offset_x", 2)
		title.add_theme_constant_override(&"shadow_offset_y", 2)

	var subtitle: Label = get_node_or_null("VBoxContainer/SubtitleLabel") as Label
	if subtitle:
		subtitle.add_theme_font_size_override(&"font_size", 18)
		subtitle.add_theme_color_override(&"font_color", Color(0.5, 0.6, 0.7))

	# Style all buttons with sci-fi look
	var btn_normal: StyleBoxFlat = StyleBoxFlat.new()
	btn_normal.bg_color = Color(0.12, 0.12, 0.22, 0.9)
	btn_normal.border_color = Color(0.2, 0.5, 0.6, 0.6)
	btn_normal.set_border_width_all(2)
	btn_normal.set_corner_radius_all(6)
	btn_normal.set_content_margin_all(12)

	var btn_hover: StyleBoxFlat = StyleBoxFlat.new()
	btn_hover.bg_color = Color(0.15, 0.18, 0.32, 0.95)
	btn_hover.border_color = Color(0.3, 0.7, 0.8, 0.9)
	btn_hover.set_border_width_all(2)
	btn_hover.set_corner_radius_all(6)
	btn_hover.set_content_margin_all(12)

	var btn_pressed: StyleBoxFlat = StyleBoxFlat.new()
	btn_pressed.bg_color = Color(0.1, 0.25, 0.35, 1.0)
	btn_pressed.border_color = Color(0.4, 0.9, 1.0, 1.0)
	btn_pressed.set_border_width_all(2)
	btn_pressed.set_corner_radius_all(6)
	btn_pressed.set_content_margin_all(12)

	var btn_focus: StyleBoxFlat = btn_hover.duplicate() as StyleBoxFlat
	btn_focus.border_color = Color(0.3, 0.8, 0.9, 1.0)
	btn_focus.set_border_width_all(3)

	for btn: Node in [_new_game_button, _continue_button, _quit_button]:
		(btn as Button).add_theme_stylebox_override(&"normal", btn_normal)
		(btn as Button).add_theme_stylebox_override(&"hover", btn_hover)
		(btn as Button).add_theme_stylebox_override(&"pressed", btn_pressed)
		(btn as Button).add_theme_stylebox_override(&"focus", btn_focus)
		(btn as Button).add_theme_color_override(&"font_color", Color(0.8, 0.85, 0.9))
		(btn as Button).add_theme_color_override(&"font_hover_color", Color(0.3, 0.9, 0.85))
		(btn as Button).add_theme_font_size_override(&"font_size", 20)

	# Version and copyright footer
	var version_label: Label = Label.new()
	version_label.text = "Demo v0.1"
	version_label.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	version_label.offset_left = 16.0
	version_label.offset_top = -30.0
	version_label.offset_bottom = -10.0
	version_label.add_theme_color_override(&"font_color", Color(0.35, 0.4, 0.5))
	version_label.add_theme_font_size_override(&"font_size", 13)
	add_child(version_label)

	var copyright_label: Label = Label.new()
	copyright_label.text = "© 2026 Heath Washburn"
	copyright_label.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	copyright_label.offset_left = -200.0
	copyright_label.offset_top = -30.0
	copyright_label.offset_right = -16.0
	copyright_label.offset_bottom = -10.0
	copyright_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	copyright_label.add_theme_color_override(&"font_color", Color(0.35, 0.4, 0.5))
	copyright_label.add_theme_font_size_override(&"font_size", 13)
	add_child(copyright_label)

	# Digital floating particles
	_spawn_menu_particles()


func _spawn_menu_particles() -> void:
	var bg: ColorRect = get_node_or_null("Background") as ColorRect
	if bg == null:
		return
	# Floating data particles — cyan/purple/blue mix
	for i: int in 40:
		var dot: ColorRect = ColorRect.new()
		dot.size = Vector2(randf_range(1, 4), randf_range(1, 4))
		dot.position = Vector2(randf_range(0, 1152), randf_range(0, 648))
		var colors: Array[Color] = [
			Color(0.2, 0.7, 0.7, 0.3),
			Color(0.4, 0.3, 0.7, 0.2),
			Color(0.2, 0.5, 0.8, 0.25),
			Color(0.3, 0.8, 0.75, 0.2),
		]
		dot.color = colors[i % 4]
		dot.mouse_filter = Control.MOUSE_FILTER_IGNORE
		bg.add_child(dot)
		var tween: Tween = dot.create_tween().set_loops()
		var duration: float = randf_range(6.0, 14.0)
		var start_y: float = randf_range(650, 800)
		dot.position.y = start_y
		tween.tween_property(dot, "position:y", randf_range(-50, -10), duration)
		tween.tween_callback(func() -> void: dot.position.y = start_y)
	# Horizontal scan lines (digital aesthetic)
	for i: int in 5:
		var line: ColorRect = ColorRect.new()
		line.size = Vector2(1152, 1)
		line.color = Color(0.15, 0.4, 0.5, 0.08)
		line.mouse_filter = Control.MOUSE_FILTER_IGNORE
		bg.add_child(line)
		var line_tween: Tween = line.create_tween().set_loops()
		var line_start: float = randf_range(700, 900)
		line.position.y = line_start
		line_tween.tween_property(line, "position:y", randf_range(-50, -10), randf_range(10.0, 20.0))
		line_tween.tween_callback(func() -> void: line.position.y = line_start)
	# Pulsing title glow
	_animate_title_glow()


func _animate_title_glow() -> void:
	var title: Label = get_node_or_null("VBoxContainer/TitleLabel") as Label
	if title == null:
		return
	# Subtle pulsing shadow that creates a glow effect
	var tween: Tween = title.create_tween().set_loops()
	tween.tween_property(title, "theme_override_colors/font_shadow_color",
		Color(0.15, 0.5, 0.5, 0.7), 2.0).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(title, "theme_override_colors/font_shadow_color",
		Color(0.1, 0.3, 0.35, 0.3), 2.0).set_ease(Tween.EASE_IN_OUT)


func _on_new_game_pressed() -> void:
	SaveManager.new_game()


func _on_continue_pressed() -> void:
	if SaveManager.load_game():
		var scene_path: String = SaveManager.current_data.get("player", {}).get("current_scene", "res://scenes/town/Town.tscn") as String
		GameManager.change_scene_to(scene_path)
	else:
		push_warning("MainMenu: failed to load save, starting new game")
		SaveManager.new_game()


func _on_quit_pressed() -> void:
	get_tree().quit()
