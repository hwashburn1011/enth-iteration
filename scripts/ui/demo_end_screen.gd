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
	_npcs_label.text = "NPCs Recruited: %d / 2" % GameManager.recruited_npcs.size()


func _on_return_pressed() -> void:
	GameManager.change_scene_to("res://scenes/town/Town.tscn")


func _on_quit_pressed() -> void:
	SaveManager.save_game()
	get_tree().quit()
