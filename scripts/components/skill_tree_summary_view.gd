class_name SkillTreeSummaryView
extends CanvasLayer

## Skill Tree Summary View (Epic 32 task 36).
##
## A compact summary panel that shows the current build at a glance:
##   - Active class
##   - Total points spent
##   - Total points available
##   - Allocated keystones (icons + labels)
##   - Notable passives (scrollable list)
##   - Build score (0-100 numeric estimate of synergy)
##
## Useful as a HUD overlay during combat or as an export preview before
## sharing a build code.
##
## Hook:
##   var summary := SkillTreeSummaryView.new()
##   add_child(summary)
##   summary.refresh(class_id, allocated_node_ids)

signal summary_refreshed(class_id: StringName)

@export var auto_refresh_on_eventbus: bool = true

var _root: Control
var _class_label: Label
var _points_label: Label
var _keystone_panel: Control
var _passive_list: VBoxContainer
var _score_label: Label
var _current_class: StringName = &""
var _allocated: Array[StringName] = []


func _ready() -> void:
	layer = 70
	_build_ui()
	visible = false
	if auto_refresh_on_eventbus and has_node("/root/EventBus"):
		var bus: Node = get_node("/root/EventBus")
		if bus.has_signal("skill_node_allocated"):
			bus.connect("skill_node_allocated", _on_node_allocated)


func _build_ui() -> void:
	_root = Control.new()
	_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_root)

	var bg := ColorRect.new()
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0, 0, 0, 0.6)
	_root.add_child(bg)

	var panel := Panel.new()
	panel.size = Vector2(540, 540)
	panel.anchor_left = 0.5
	panel.anchor_top = 0.5
	panel.offset_left = -270
	panel.offset_top = -270
	_root.add_child(panel)

	# Title
	var title := Label.new()
	title.position = Vector2(20, 18)
	title.size = Vector2(500, 36)
	title.text = "BUILD SUMMARY"
	title.add_theme_font_size_override("font_size", 26)
	title.add_theme_color_override("font_color", Color(1.0, 0.95, 0.6))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	panel.add_child(title)

	_class_label = Label.new()
	_class_label.position = Vector2(20, 60)
	_class_label.size = Vector2(500, 28)
	_class_label.add_theme_font_size_override("font_size", 18)
	_class_label.add_theme_color_override("font_color", Color(0.7, 0.85, 1.0))
	_class_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	panel.add_child(_class_label)

	_points_label = Label.new()
	_points_label.position = Vector2(20, 90)
	_points_label.size = Vector2(500, 24)
	_points_label.add_theme_font_size_override("font_size", 15)
	_points_label.add_theme_color_override("font_color", Color(0.85, 0.92, 1.0))
	_points_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	panel.add_child(_points_label)

	# Keystones header
	var keystone_header := Label.new()
	keystone_header.position = Vector2(20, 130)
	keystone_header.size = Vector2(500, 24)
	keystone_header.text = "★ KEYSTONES ALLOCATED"
	keystone_header.add_theme_font_size_override("font_size", 16)
	keystone_header.add_theme_color_override("font_color", Color(0.95, 0.78, 0.30))
	panel.add_child(keystone_header)

	_keystone_panel = Control.new()
	_keystone_panel.position = Vector2(20, 160)
	_keystone_panel.size = Vector2(500, 80)
	panel.add_child(_keystone_panel)

	# Passives header
	var passives_header := Label.new()
	passives_header.position = Vector2(20, 250)
	passives_header.size = Vector2(500, 24)
	passives_header.text = "NOTABLE PASSIVES"
	passives_header.add_theme_font_size_override("font_size", 16)
	passives_header.add_theme_color_override("font_color", Color(0.95, 0.78, 0.30))
	panel.add_child(passives_header)

	var scroll := ScrollContainer.new()
	scroll.position = Vector2(20, 280)
	scroll.size = Vector2(500, 200)
	panel.add_child(scroll)

	_passive_list = VBoxContainer.new()
	_passive_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(_passive_list)

	# Build score
	_score_label = Label.new()
	_score_label.position = Vector2(20, 488)
	_score_label.size = Vector2(500, 32)
	_score_label.add_theme_font_size_override("font_size", 22)
	_score_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.35))
	_score_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	panel.add_child(_score_label)


func refresh(class_id: StringName, allocated_node_ids: Array[StringName], available_points: int = 0) -> void:
	_current_class = class_id
	_allocated = allocated_node_ids.duplicate()
	visible = true

	_class_label.text = ClassSystemDatabase.get_display_name(class_id).to_upper()
	var spent: int = SkillTreeNodesDatabase.compute_total_cost(class_id, allocated_node_ids)
	_points_label.text = "%d points spent · %d available" % [spent, available_points]

	_render_keystones()
	_render_passives()
	_render_build_score()
	summary_refreshed.emit(class_id)


func _render_keystones() -> void:
	for child in _keystone_panel.get_children():
		child.queue_free()
	var keystone_ids: Array[StringName] = SkillTreeNodesDatabase.get_keystones_for_class(_current_class)
	var x: int = 0
	for ks_id in keystone_ids:
		var allocated: bool = _allocated.has(ks_id)
		var icon := Panel.new()
		icon.position = Vector2(x, 0)
		icon.size = Vector2(70, 70)
		icon.modulate = Color(1, 1, 1) if allocated else Color(0.4, 0.4, 0.4)
		_keystone_panel.add_child(icon)

		var node: Dictionary = SkillTreeNodesDatabase.get_node(_current_class, ks_id)
		var label := Label.new()
		label.position = Vector2(2, 50)
		label.size = Vector2(66, 18)
		label.text = String(node.get("label", "")).substr(0, 12)
		label.add_theme_font_size_override("font_size", 9)
		label.add_theme_color_override("font_color", Color(1, 1, 1))
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		icon.add_child(label)
		x += 80


func _render_passives() -> void:
	for child in _passive_list.get_children():
		child.queue_free()
	for nid: StringName in _allocated:
		var node: Dictionary = SkillTreeNodesDatabase.get_node(_current_class, nid)
		if node.is_empty():
			continue
		if node.get("kind", &"") == SkillTreeNodesDatabase.NODE_KIND_KEYSTONE:
			continue
		var row := Label.new()
		row.text = "• %s — %s" % [node.get("label", ""), node.get("description", "")]
		row.autowrap_mode = TextServer.AUTOWRAP_WORD
		row.add_theme_font_size_override("font_size", 13)
		row.add_theme_color_override("font_color", Color(0.85, 0.92, 1.0))
		_passive_list.add_child(row)


func _render_build_score() -> void:
	# Heuristic score: 1pt per node + 5pt per keystone + 2pt synergy bonus per
	# 5 nodes that share a prefix
	var score: int = 0
	var prefix_counts: Dictionary = {}
	for nid: StringName in _allocated:
		score += 1
		var node: Dictionary = SkillTreeNodesDatabase.get_node(_current_class, nid)
		if node.get("kind", &"") == SkillTreeNodesDatabase.NODE_KIND_KEYSTONE:
			score += 5
		var label_str: String = String(node.get("label", "")).split(" ")[0].to_lower()
		prefix_counts[label_str] = prefix_counts.get(label_str, 0) + 1
	for prefix in prefix_counts:
		if int(prefix_counts[prefix]) >= 3:
			score += 2
	_score_label.text = "BUILD SCORE: %d / 100" % min(100, score)


func _on_node_allocated(node_id: StringName) -> void:
	if not _allocated.has(node_id):
		_allocated.append(node_id)
		if visible:
			refresh(_current_class, _allocated)


func _input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("ui_cancel"):
		visible = false
