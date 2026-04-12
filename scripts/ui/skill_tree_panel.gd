class_name SkillTreePanel
extends Control
## R3 M28 — Visual skill tree panel showing unlocked/locked passive nodes.
##
## Opened from the inventory/pause menu. Displays all 24 passive nodes
## in a grid, coloring unlocked nodes cyan and locked nodes dim gray.
## Also shows respec button with gold cost.

var _node_labels: Array[Label] = []
var _bg: ColorRect = null


func _ready() -> void:
	_build_ui()
	_refresh()


func _build_ui() -> void:
	# Full-screen semi-transparent background
	_bg = ColorRect.new()
	_bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	_bg.color = Color(0.03, 0.03, 0.08, 0.92)
	_bg.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(_bg)

	# Title
	var title: Label = Label.new()
	title.text = "PASSIVE NODE TREE"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.set_anchors_preset(Control.PRESET_TOP_WIDE)
	title.offset_top = 30
	title.offset_bottom = 70
	title.add_theme_font_size_override(&"font_size", 28)
	title.add_theme_color_override(&"font_color", Color(0.3, 0.85, 0.8))
	add_child(title)

	# Node grid — 6 columns x 4 rows = 24 nodes
	var grid_start_x: float = 120.0
	var grid_start_y: float = 100.0
	var col_width: float = 180.0
	var row_height: float = 100.0
	var lib_script: Script = load("res://scripts/systems/passive_node_database.gd") as Script
	if lib_script == null:
		return
	var nodes: Array = lib_script.get("NODES") as Array
	if nodes == null:
		return

	for i: int in nodes.size():
		var node_data: Dictionary = nodes[i] as Dictionary
		var col: int = i % 6
		var row: int = i / 6

		# Node background
		var node_bg: ColorRect = ColorRect.new()
		node_bg.position = Vector2(grid_start_x + col * col_width, grid_start_y + row * row_height)
		node_bg.size = Vector2(160, 80)
		node_bg.color = Color(0.1, 0.1, 0.15, 0.8)
		add_child(node_bg)

		# Node name
		var name_label: Label = Label.new()
		name_label.text = str(node_data.get("name", ""))
		name_label.position = Vector2(grid_start_x + col * col_width + 5, grid_start_y + row * row_height + 5)
		name_label.add_theme_font_size_override(&"font_size", 14)
		name_label.add_theme_color_override(&"font_color", Color(0.5, 0.5, 0.5))
		add_child(name_label)
		_node_labels.append(name_label)

		# Description
		var desc_label: Label = Label.new()
		desc_label.text = str(node_data.get("description", ""))
		desc_label.position = Vector2(grid_start_x + col * col_width + 5, grid_start_y + row * row_height + 28)
		desc_label.add_theme_font_size_override(&"font_size", 11)
		desc_label.add_theme_color_override(&"font_color", Color(0.4, 0.4, 0.45))
		add_child(desc_label)

	# Close button
	var close_btn: Button = Button.new()
	close_btn.text = "Close"
	close_btn.position = Vector2(500, 530)
	close_btn.size = Vector2(120, 40)
	close_btn.pressed.connect(_on_close)
	add_child(close_btn)

	# Respec button
	var respec_btn: Button = Button.new()
	respec_btn.text = "Respec Passives (50g/node)"
	respec_btn.position = Vector2(300, 530)
	respec_btn.size = Vector2(180, 40)
	add_child(respec_btn)


func _refresh() -> void:
	# Check which nodes are unlocked via player meta
	var unlocked: Array = []
	var players: Array[Node] = get_tree().get_nodes_in_group(&"player")
	if players.size() > 0:
		var player: Node = players[0]
		if player.has_meta(&"unlocked_passives"):
			unlocked = player.get_meta(&"unlocked_passives") as Array

	var lib_script: Script = load("res://scripts/systems/passive_node_database.gd") as Script
	if lib_script == null:
		return
	var nodes: Array = lib_script.get("NODES") as Array
	if nodes == null:
		return

	for i: int in mini(_node_labels.size(), nodes.size()):
		var node_data: Dictionary = nodes[i] as Dictionary
		var node_id: String = str(node_data.get("id", ""))
		var is_unlocked: bool = node_id in unlocked
		if is_unlocked:
			_node_labels[i].add_theme_color_override(&"font_color", Color(0.3, 0.9, 0.8))
		else:
			_node_labels[i].add_theme_color_override(&"font_color", Color(0.4, 0.4, 0.45))


func _on_close() -> void:
	queue_free()
