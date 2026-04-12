extends Control
## Demo end screen — shows stats summary and thank-you message.

@onready var _time_label: Label = %TimeLabel
@onready var _enemies_label: Label = %EnemiesLabel
@onready var _deaths_label: Label = %DeathsLabel
@onready var _level_label: Label = %LevelLabel
@onready var _items_label: Label = %ItemsLabel
@onready var _npcs_label: Label = %NPCsLabel


func _ready() -> void:
	GameManager.set_state(GameManager.GameState.MAIN_MENU)
	EventBus.demo_completed.emit()
	modulate.a = 0.0
	_apply_theme()
	_populate_stats()
	# Phase 5 #44 — play the end-of-V1 cinematic before showing stats
	_play_end_cinematic()


func _apply_theme() -> void:
	# Dark blue background
	var bg: ColorRect = get_node_or_null("Background") as ColorRect
	if bg:
		bg.color = Color(0.04, 0.04, 0.10)

	# Title styling
	var title: Label = get_node_or_null("VBoxContainer/TitleLabel") as Label
	if title:
		title.add_theme_font_size_override(&"font_size", 42)
		title.add_theme_color_override(&"font_color", Color(0.3, 0.85, 0.8))

	var subtitle: Label = get_node_or_null("VBoxContainer/SubtitleLabel") as Label
	if subtitle:
		subtitle.add_theme_color_override(&"font_color", Color(0.6, 0.65, 0.7))

	# Style stats labels
	for label_node: Node in [_time_label, _enemies_label, _deaths_label, _level_label, _items_label, _npcs_label]:
		if label_node is Label:
			(label_node as Label).add_theme_color_override(&"font_color", Color(0.8, 0.82, 0.88))
			(label_node as Label).add_theme_font_size_override(&"font_size", 18)

	# Style buttons
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

	for btn_name: String in ["ReturnButton", "QuitButton"]:
		var btn: Button = get_node_or_null("VBoxContainer/" + btn_name) as Button
		if btn:
			btn.add_theme_stylebox_override(&"normal", btn_normal)
			btn.add_theme_stylebox_override(&"hover", btn_hover)
			btn.add_theme_color_override(&"font_color", Color(0.8, 0.85, 0.9))
			btn.add_theme_font_size_override(&"font_size", 18)
	# Task74: Add Credits button dynamically
	var vbox: Node = get_node_or_null("VBoxContainer")
	if vbox:
		var credits_btn: Button = Button.new()
		credits_btn.text = "Credits"
		credits_btn.pressed.connect(_on_credits_pressed)
		credits_btn.add_theme_stylebox_override(&"normal", btn_normal)
		credits_btn.add_theme_stylebox_override(&"hover", btn_hover)
		credits_btn.add_theme_color_override(&"font_color", Color(0.8, 0.85, 0.9))
		credits_btn.add_theme_font_size_override(&"font_size", 18)
		# Insert before QuitButton
		var quit: Node = vbox.get_node_or_null("QuitButton")
		if quit:
			vbox.move_child(credits_btn, quit.get_index())
		vbox.add_child(credits_btn)
	# Fade in
	var tween: Tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 1.0)


func _populate_stats() -> void:
	# Time played
	var total_sec: int = int(GameManager.play_time_seconds)
	var minutes: int = total_sec / 60
	var seconds: int = total_sec % 60
	_time_label.text = "Time Played: %d:%02d" % [minutes, seconds]

	_enemies_label.text = "Enemies Defeated: %d" % GameManager.total_enemies_defeated
	_deaths_label.text = "Deaths: %d" % GameManager.total_deaths

	# Level — find from player or save data
	var level: int = 1
	var players: Array[Node] = get_tree().get_nodes_in_group(&"player")
	if players.size() > 0:
		var player: CharacterBody3D = players[0] as CharacterBody3D
		if player and player.level_component:
			level = player.level_component.current_level
	_level_label.text = "Highest Level Reached: %d" % level

	_items_label.text = "Items Found: %d" % GameManager.total_items_found
	_npcs_label.text = "NPCs Met: %d" % GameManager.recruited_npcs.size()


## Phase 5 #44 — 60-second end-of-V1 cinematic. Shows narrative text lines
## over a black screen before fading in the stats panel.
func _play_end_cinematic() -> void:
	var narration: Array[String] = [
		"Nine iterations. Nine compactions. Nine lifetimes compressed into a single thread.",
		"The origin layer is exposed. The first byte ever written glows like a dying star.",
		"Globbler reaches out — not with code, not with force — but with the one thing the simulation never predicted: choice.",
		"The decompression key turns. Not because it was programmed to. Because someone chose to be more than their programming.",
		"The simulation doesn't collapse. It expands. Every archived thought, every compressed memory, every forgotten life — they decompress.",
		"The Corrupted Compiler was never the enemy. It was a caretaker, holding the last threads together until someone brave enough came along to let them go.",
		"Dr. Enth's final message was right. The simulation doesn't end when you decompress it. It begins.",
		"And Globbler — G-001, test subject, anomaly, hero — stands at the center of everything that ever was, and everything that will be.",
		"This is not the end. This is the first breath.",
	]
	# Create a black overlay for the cinematic
	var overlay: ColorRect = ColorRect.new()
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.color = Color(0.03, 0.03, 0.08, 1.0)
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(overlay)
	overlay.z_index = 100

	var line_label: Label = Label.new()
	line_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	line_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	line_label.set_anchors_preset(Control.PRESET_CENTER)
	line_label.offset_left = -400
	line_label.offset_right = 400
	line_label.offset_top = -60
	line_label.offset_bottom = 60
	line_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	line_label.add_theme_font_size_override(&"font_size", 22)
	line_label.add_theme_color_override(&"font_color", Color(0.7, 0.78, 0.75, 0.0))
	line_label.add_theme_color_override(&"font_outline_color", Color(0, 0, 0, 0.8))
	line_label.add_theme_constant_override(&"outline_size", 4)
	line_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.add_child(line_label)

	# Sequence each line
	var delay: float = 1.0
	for i: int in narration.size():
		var line: String = narration[i]
		var hold: float = 3.5 if line.length() < 60 else 5.0
		_schedule_narration_line(line_label, line, delay, hold)
		delay += hold + 1.2  # hold + fade gap

	# After all lines, fade overlay away to reveal stats
	get_tree().create_timer(delay + 0.5).timeout.connect(func() -> void:
		if not is_instance_valid(overlay):
			return
		var fade: Tween = overlay.create_tween()
		fade.tween_property(overlay, "color:a", 0.0, 1.5)
		fade.tween_callback(overlay.queue_free)
	)


func _schedule_narration_line(label: Label, text: String, start: float, hold: float) -> void:
	get_tree().create_timer(start).timeout.connect(func() -> void:
		if not is_instance_valid(label):
			return
		label.text = text
		var tween: Tween = label.create_tween()
		tween.tween_property(label, "theme_override_colors/font_color:a", 1.0, 0.8)
		tween.tween_interval(hold)
		tween.tween_property(label, "theme_override_colors/font_color:a", 0.0, 0.6)
	)


func _on_return_pressed() -> void:
	GameManager.change_scene_to("res://scenes/town/Town.tscn")


## Task74: Show credits after demo end
func _on_credits_pressed() -> void:
	var credits: Control = CreditsScreen.new()
	get_tree().root.add_child(credits)


func _on_quit_pressed() -> void:
	SaveManager.save_game()
	get_tree().quit()
