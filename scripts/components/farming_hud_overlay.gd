class_name FarmingHUDOverlay
extends CanvasLayer

## Farming HUD Overlay (Epic 35 task 15) + Gathering Tracker (task 38).
##
## Compact HUD panel showing:
##   - Active crop plot status (planted/growing/harvestable counts)
##   - Top 3 ready-to-harvest crops with countdown
##   - Gathering skill levels with XP progress bars
##   - Active gathering quest progress
##
## Auto-shows when player is near a farm plot OR has any in-progress gathering
## quest. Hides during combat.

signal overlay_shown
signal overlay_hidden

const HIDE_IN_COMBAT: bool = true
const FONT_SIZE_HEADER: int = 14
const FONT_SIZE_BODY: int = 12

@export var auto_show_on_farm_proximity: bool = true
@export var farming_subsystems_path: NodePath

var _root: Control
var _crop_panel: Panel
var _crop_label: Label
var _skill_panel: Panel
var _skill_labels: Array[Label] = []
var _quest_panel: Panel
var _quest_labels: Array[Label] = []
var _farming_subs: FarmingSubsystems
var _is_visible: bool = false


func _ready() -> void:
	layer = 30
	_build_ui()
	visible = false
	if farming_subsystems_path != NodePath():
		_farming_subs = get_node_or_null(farming_subsystems_path)


func _build_ui() -> void:
	_root = Control.new()
	_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_root)

	# Crop status panel (top right)
	_crop_panel = Panel.new()
	_crop_panel.size = Vector2(280, 110)
	_crop_panel.anchor_left = 1.0
	_crop_panel.anchor_top = 0.0
	_crop_panel.offset_left = -300
	_crop_panel.offset_top = 20
	_root.add_child(_crop_panel)

	var crop_header := Label.new()
	crop_header.position = Vector2(12, 8)
	crop_header.size = Vector2(256, 20)
	crop_header.text = "FARM STATUS"
	crop_header.add_theme_font_size_override("font_size", FONT_SIZE_HEADER)
	crop_header.add_theme_color_override("font_color", Color(1.0, 0.85, 0.35))
	_crop_panel.add_child(crop_header)

	_crop_label = Label.new()
	_crop_label.position = Vector2(12, 32)
	_crop_label.size = Vector2(256, 70)
	_crop_label.add_theme_font_size_override("font_size", FONT_SIZE_BODY)
	_crop_label.add_theme_color_override("font_color", Color(0.92, 0.92, 1.0))
	_crop_panel.add_child(_crop_label)

	# Skills panel (right side, below crop)
	_skill_panel = Panel.new()
	_skill_panel.size = Vector2(280, 200)
	_skill_panel.anchor_left = 1.0
	_skill_panel.anchor_top = 0.0
	_skill_panel.offset_left = -300
	_skill_panel.offset_top = 140
	_root.add_child(_skill_panel)

	var skill_header := Label.new()
	skill_header.position = Vector2(12, 8)
	skill_header.size = Vector2(256, 20)
	skill_header.text = "GATHERING SKILLS"
	skill_header.add_theme_font_size_override("font_size", FONT_SIZE_HEADER)
	skill_header.add_theme_color_override("font_color", Color(1.0, 0.85, 0.35))
	_skill_panel.add_child(skill_header)

	# 6 skill rows
	for i in range(6):
		var row := Label.new()
		row.position = Vector2(12, 32 + i * 26)
		row.size = Vector2(256, 22)
		row.add_theme_font_size_override("font_size", FONT_SIZE_BODY)
		row.add_theme_color_override("font_color", Color(0.85, 0.92, 1.0))
		_skill_panel.add_child(row)
		_skill_labels.append(row)

	# Quest panel (right side, below skills)
	_quest_panel = Panel.new()
	_quest_panel.size = Vector2(280, 130)
	_quest_panel.anchor_left = 1.0
	_quest_panel.anchor_top = 0.0
	_quest_panel.offset_left = -300
	_quest_panel.offset_top = 360
	_root.add_child(_quest_panel)

	var quest_header := Label.new()
	quest_header.position = Vector2(12, 8)
	quest_header.size = Vector2(256, 20)
	quest_header.text = "ACTIVE GATHERING QUESTS"
	quest_header.add_theme_font_size_override("font_size", FONT_SIZE_HEADER)
	quest_header.add_theme_color_override("font_color", Color(1.0, 0.85, 0.35))
	_quest_panel.add_child(quest_header)

	for i in range(3):
		var row := Label.new()
		row.position = Vector2(12, 32 + i * 30)
		row.size = Vector2(256, 26)
		row.autowrap_mode = TextServer.AUTOWRAP_WORD
		row.add_theme_font_size_override("font_size", FONT_SIZE_BODY)
		row.add_theme_color_override("font_color", Color(0.85, 0.92, 1.0))
		_quest_panel.add_child(row)
		_quest_labels.append(row)


func show_overlay() -> void:
	if _is_visible:
		return
	_is_visible = true
	visible = true
	overlay_shown.emit()
	refresh()


func hide_overlay() -> void:
	if not _is_visible:
		return
	_is_visible = false
	visible = false
	overlay_hidden.emit()


func refresh() -> void:
	if _farming_subs == null:
		return
	_refresh_crops()
	_refresh_skills()
	_refresh_quests()


func _refresh_crops() -> void:
	# Pull from FarmManager if present
	var planted: int = 0
	var growing: int = 0
	var ready: int = 0
	if has_node("/root/FarmManager"):
		var fm: Node = get_node("/root/FarmManager")
		if fm.has_method("get_plot_summary"):
			var summary: Dictionary = fm.call("get_plot_summary")
			planted = int(summary.get("planted", 0))
			growing = int(summary.get("growing", 0))
			ready = int(summary.get("ready", 0))
	_crop_label.text = "Planted: %d\nGrowing: %d\n[color=#ffd966]Ready: %d[/color]" % [planted, growing, ready]


func _refresh_skills() -> void:
	for i in range(min(6, FarmingSubsystems.GATHERING_SKILLS.size())):
		var skill_id: StringName = FarmingSubsystems.GATHERING_SKILLS[i]
		var level: int = _farming_subs.get_skill_level(skill_id)
		var progress: float = _farming_subs.get_skill_progress(skill_id)
		var bar: String = _build_progress_bar(progress, 12)
		_skill_labels[i].text = "%s Lv%d %s" % [String(skill_id).capitalize(), level, bar]


func _build_progress_bar(progress: float, width: int) -> String:
	var filled: int = int(round(progress * width))
	return "[" + "█".repeat(filled) + "░".repeat(width - filled) + "]"


func _refresh_quests() -> void:
	if _farming_subs == null:
		return
	var i: int = 0
	for qid in _farming_subs._quest_progress.keys():
		if i >= 3:
			break
		var quest: Dictionary = FarmingSubsystems.NPC_GATHERING_QUESTS.get(qid, {})
		var current: int = int(_farming_subs._quest_progress[qid])
		var target: int = int(quest.get("target", 0))
		var item: StringName = quest.get("item", &"")
		_quest_labels[i].text = "• %s: %d / %d" % [String(item).capitalize().replace("_", " "), current, target]
		i += 1
	# Clear remaining
	while i < 3:
		_quest_labels[i].text = ""
		i += 1
