class_name AffinityUIScreen
extends CanvasLayer

## Affinity UI Screen (Epic 37 task 10).
##
## Modal panel showing the player's current affinity with all 12 town NPCs:
##   - NPC name + portrait
##   - Current affinity level (Stranger / Friend / Confidant / Bond / Soul-Linked)
##   - Heart icon row showing fill progress
##   - Last gift given + reaction
##   - Days since last interaction
##
## Pulls live data from AffinityManager autoload + AffinitySubsystems history.

signal screen_opened
signal screen_closed
signal npc_focused(npc_id: StringName)

const HEART_ICON_PATHS: Dictionary = {
	&"stranger": "res://_art_source/ui/renders/heart_stranger.png",
	&"friend": "res://_art_source/ui/renders/heart_friend.png",
	&"confidant": "res://_art_source/ui/renders/heart_confidant.png",
	&"bond": "res://_art_source/ui/renders/heart_bond.png",
	&"soul_linked": "res://_art_source/ui/renders/heart_soul_linked.png",
}

const NPC_IDS: Array[StringName] = [
	&"pixel", &"forge", &"cache", &"index", &"harvest", &"bit",
	&"legacy", &"trade", &"lab", &"render", &"sync", &"sentinel",
]

@export var affinity_subsystems_path: NodePath

var _root: Control
var _bg_dim: ColorRect
var _panel: Panel
var _scroll: ScrollContainer
var _list: VBoxContainer
var _affinity_subs: AffinitySubsystems


func _ready() -> void:
	layer = 75
	_build_ui()
	visible = false
	if affinity_subsystems_path != NodePath():
		_affinity_subs = get_node_or_null(affinity_subsystems_path)


func _build_ui() -> void:
	_root = Control.new()
	_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_root)

	_bg_dim = ColorRect.new()
	_bg_dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_bg_dim.color = Color(0, 0, 0, 0.7)
	_root.add_child(_bg_dim)

	_panel = Panel.new()
	_panel.size = Vector2(640, 600)
	_panel.anchor_left = 0.5
	_panel.anchor_top = 0.5
	_panel.offset_left = -320
	_panel.offset_top = -300
	_root.add_child(_panel)

	# Title
	var title := Label.new()
	title.position = Vector2(20, 18)
	title.size = Vector2(600, 38)
	title.text = "RELATIONSHIPS"
	title.add_theme_font_size_override("font_size", 28)
	title.add_theme_color_override("font_color", Color(1.0, 0.85, 0.45))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_panel.add_child(title)

	# Subtitle
	var subtitle := Label.new()
	subtitle.position = Vector2(20, 60)
	subtitle.size = Vector2(600, 20)
	subtitle.text = "Tap an NPC to see their full history"
	subtitle.add_theme_font_size_override("font_size", 13)
	subtitle.add_theme_color_override("font_color", Color(0.7, 0.78, 0.92))
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_panel.add_child(subtitle)

	# Scroll container with NPC rows
	_scroll = ScrollContainer.new()
	_scroll.position = Vector2(20, 90)
	_scroll.size = Vector2(600, 460)
	_panel.add_child(_scroll)

	_list = VBoxContainer.new()
	_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_list.add_theme_constant_override("separation", 8)
	_scroll.add_child(_list)

	# Close button
	var close := Button.new()
	close.text = "Close [Esc]"
	close.position = Vector2(500, 558)
	close.size = Vector2(120, 32)
	close.pressed.connect(_on_close)
	_panel.add_child(close)


func show_screen() -> void:
	visible = true
	_refresh()
	screen_opened.emit()


func _refresh() -> void:
	for child in _list.get_children():
		child.queue_free()
	for npc_id in NPC_IDS:
		_add_npc_row(npc_id)


func _add_npc_row(npc_id: StringName) -> void:
	var row := Panel.new()
	row.custom_minimum_size = Vector2(580, 70)
	_list.add_child(row)

	# NPC name
	var name_label := Label.new()
	name_label.position = Vector2(16, 12)
	name_label.size = Vector2(180, 28)
	name_label.text = String(npc_id).capitalize()
	name_label.add_theme_font_size_override("font_size", 18)
	name_label.add_theme_color_override("font_color", Color(1.0, 0.95, 0.85))
	row.add_child(name_label)

	# Affinity level + heart icon
	var level: StringName = _get_affinity_level(npc_id)
	var level_label := Label.new()
	level_label.position = Vector2(16, 38)
	level_label.size = Vector2(200, 22)
	level_label.text = String(level).capitalize().replace("_", " ")
	level_label.add_theme_font_size_override("font_size", 13)
	level_label.add_theme_color_override("font_color", _color_for_level(level))
	row.add_child(level_label)

	# Heart icon
	var heart_path: String = HEART_ICON_PATHS.get(level, "")
	if heart_path != "" and ResourceLoader.exists(heart_path):
		var heart := TextureRect.new()
		heart.position = Vector2(220, 14)
		heart.size = Vector2(48, 48)
		heart.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
		heart.texture = load(heart_path)
		row.add_child(heart)

	# Progress to next level
	var current: int = _get_affinity_value(npc_id)
	var next_target: int = _next_level_threshold(level)
	var progress_label := Label.new()
	progress_label.position = Vector2(280, 18)
	progress_label.size = Vector2(280, 22)
	progress_label.text = "%d / %d" % [current, next_target]
	progress_label.add_theme_font_size_override("font_size", 14)
	progress_label.add_theme_color_override("font_color", Color(0.85, 0.92, 1.0))
	row.add_child(progress_label)

	# Last gift / interaction
	var last_label := Label.new()
	last_label.position = Vector2(280, 40)
	last_label.size = Vector2(280, 22)
	last_label.text = _get_last_interaction_text(npc_id)
	last_label.add_theme_font_size_override("font_size", 12)
	last_label.add_theme_color_override("font_color", Color(0.6, 0.78, 0.92))
	row.add_child(last_label)


func _get_affinity_level(npc_id: StringName) -> StringName:
	if has_node("/root/AffinityManager"):
		var am: Node = get_node("/root/AffinityManager")
		if am.has_method("get_level"):
			return am.call("get_level", npc_id)
	return &"stranger"


func _get_affinity_value(npc_id: StringName) -> int:
	if has_node("/root/AffinityManager"):
		var am: Node = get_node("/root/AffinityManager")
		if am.has_method("get_value"):
			return int(am.call("get_value", npc_id))
	return 0


func _next_level_threshold(level: StringName) -> int:
	match level:
		&"stranger": return 100
		&"friend": return 250
		&"confidant": return 500
		&"bond": return 800
		&"soul_linked": return 1000
	return 0


func _color_for_level(level: StringName) -> Color:
	match level:
		&"stranger": return Color(0.65, 0.65, 0.65)
		&"friend": return Color(0.95, 0.55, 0.65)
		&"confidant": return Color(0.95, 0.20, 0.30)
		&"bond": return Color(0.85, 0.30, 0.95)
		&"soul_linked": return Color(1.0, 0.85, 0.30)
	return Color.WHITE


func _get_last_interaction_text(npc_id: StringName) -> String:
	if _affinity_subs == null:
		return "No recent activity"
	var history: Array[Dictionary] = _affinity_subs.get_history_for_npc(npc_id)
	if history.is_empty():
		return "No recent activity"
	var last: Dictionary = history[history.size() - 1]
	return "Last: %s (%+d)" % [last.get("reason", ""), last.get("change", 0)]


func _on_close() -> void:
	visible = false
	screen_closed.emit()


func _input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("ui_cancel"):
		_on_close()
