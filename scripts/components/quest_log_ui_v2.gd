class_name QuestLogUIv2
extends CanvasLayer

## Quest Log UI v2 (Epic 38 task 3 + 41).
##
## Modal quest journal with:
##   - Tab bar: Main / Side / Daily / Hidden / Lore
##   - Filter row (active / completed / failed / all)
##   - Sort dropdown (newest / oldest / alphabetical / by_giver / by_progress)
##   - Scrollable quest list on the left
##   - Quest detail panel on the right (description, objectives, rewards,
##     giver portrait, prereqs)
##   - Lore tab showing all collected lore tablets

signal screen_opened
signal screen_closed
signal quest_selected(quest_id: StringName)
signal filter_changed(filter: StringName)
signal sort_changed(sort: StringName)

enum Tab { MAIN, SIDE, DAILY, HIDDEN, LORE }
enum Filter { ALL, ACTIVE, COMPLETED, FAILED }
enum SortOrder { NEWEST, OLDEST, ALPHABETICAL, BY_GIVER, BY_PROGRESS }

const TAB_LABELS: Array[String] = ["Main", "Side", "Daily", "Hidden", "Lore"]
const FILTER_LABELS: Array[String] = ["All", "Active", "Completed", "Failed"]
const SORT_LABELS: Array[String] = ["Newest", "Oldest", "Alphabetical", "By Giver", "By Progress"]

var _root: Control
var _bg_dim: ColorRect
var _panel: Panel
var _tab_buttons: Array[Button] = []
var _filter_buttons: Array[Button] = []
var _sort_button: OptionButton
var _quest_list: VBoxContainer
var _quest_scroll: ScrollContainer
var _detail_panel: Control
var _detail_title: Label
var _detail_desc: Label
var _detail_objectives: VBoxContainer
var _detail_rewards: VBoxContainer
var _current_tab: int = Tab.MAIN
var _current_filter: int = Filter.ALL
var _current_sort: int = SortOrder.NEWEST
var _selected_quest_id: StringName = &""


func _ready() -> void:
	layer = 76
	_build_ui()
	visible = false


func _build_ui() -> void:
	_root = Control.new()
	_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_root)

	_bg_dim = ColorRect.new()
	_bg_dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_bg_dim.color = Color(0, 0, 0, 0.7)
	_root.add_child(_bg_dim)

	_panel = Panel.new()
	_panel.size = Vector2(960, 640)
	_panel.anchor_left = 0.5
	_panel.anchor_top = 0.5
	_panel.offset_left = -480
	_panel.offset_top = -320
	_root.add_child(_panel)

	# Title
	var title := Label.new()
	title.position = Vector2(20, 16)
	title.size = Vector2(920, 36)
	title.text = "QUEST JOURNAL"
	title.add_theme_font_size_override("font_size", 26)
	title.add_theme_color_override("font_color", Color(1.0, 0.85, 0.45))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_panel.add_child(title)

	# Tab bar
	for i in range(TAB_LABELS.size()):
		var btn := Button.new()
		btn.text = TAB_LABELS[i]
		btn.position = Vector2(20 + i * 130, 60)
		btn.size = Vector2(120, 36)
		btn.pressed.connect(_on_tab_pressed.bind(i))
		_panel.add_child(btn)
		_tab_buttons.append(btn)

	# Filter row
	for i in range(FILTER_LABELS.size()):
		var btn := Button.new()
		btn.text = FILTER_LABELS[i]
		btn.position = Vector2(20 + i * 110, 108)
		btn.size = Vector2(100, 28)
		btn.pressed.connect(_on_filter_pressed.bind(i))
		_panel.add_child(btn)
		_filter_buttons.append(btn)

	# Sort dropdown
	_sort_button = OptionButton.new()
	for label in SORT_LABELS:
		_sort_button.add_item(label)
	_sort_button.position = Vector2(720, 108)
	_sort_button.size = Vector2(220, 28)
	_sort_button.item_selected.connect(_on_sort_selected)
	_panel.add_child(_sort_button)

	# Quest list (left, scrollable)
	_quest_scroll = ScrollContainer.new()
	_quest_scroll.position = Vector2(20, 150)
	_quest_scroll.size = Vector2(380, 440)
	_panel.add_child(_quest_scroll)

	_quest_list = VBoxContainer.new()
	_quest_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_quest_list.add_theme_constant_override("separation", 6)
	_quest_scroll.add_child(_quest_list)

	# Detail panel (right)
	_detail_panel = Control.new()
	_detail_panel.position = Vector2(420, 150)
	_detail_panel.size = Vector2(520, 440)
	_panel.add_child(_detail_panel)

	_detail_title = Label.new()
	_detail_title.position = Vector2(0, 0)
	_detail_title.size = Vector2(520, 32)
	_detail_title.add_theme_font_size_override("font_size", 22)
	_detail_title.add_theme_color_override("font_color", Color(1.0, 0.95, 0.6))
	_detail_panel.add_child(_detail_title)

	_detail_desc = Label.new()
	_detail_desc.position = Vector2(0, 36)
	_detail_desc.size = Vector2(520, 80)
	_detail_desc.autowrap_mode = TextServer.AUTOWRAP_WORD
	_detail_desc.add_theme_font_size_override("font_size", 14)
	_detail_desc.add_theme_color_override("font_color", Color(0.85, 0.92, 1.0))
	_detail_panel.add_child(_detail_desc)

	var obj_header := Label.new()
	obj_header.position = Vector2(0, 130)
	obj_header.size = Vector2(520, 24)
	obj_header.text = "OBJECTIVES"
	obj_header.add_theme_font_size_override("font_size", 16)
	obj_header.add_theme_color_override("font_color", Color(0.95, 0.78, 0.30))
	_detail_panel.add_child(obj_header)

	_detail_objectives = VBoxContainer.new()
	_detail_objectives.position = Vector2(0, 158)
	_detail_objectives.size = Vector2(520, 130)
	_detail_panel.add_child(_detail_objectives)

	var rew_header := Label.new()
	rew_header.position = Vector2(0, 296)
	rew_header.size = Vector2(520, 24)
	rew_header.text = "REWARDS"
	rew_header.add_theme_font_size_override("font_size", 16)
	rew_header.add_theme_color_override("font_color", Color(0.95, 0.78, 0.30))
	_detail_panel.add_child(rew_header)

	_detail_rewards = VBoxContainer.new()
	_detail_rewards.position = Vector2(0, 324)
	_detail_rewards.size = Vector2(520, 110)
	_detail_panel.add_child(_detail_rewards)

	# Close button
	var close := Button.new()
	close.text = "Close [Esc]"
	close.position = Vector2(820, 600)
	close.size = Vector2(120, 32)
	close.pressed.connect(_on_close)
	_panel.add_child(close)


func show_log() -> void:
	visible = true
	_refresh_quest_list()
	screen_opened.emit()


func _on_tab_pressed(tab: int) -> void:
	_current_tab = tab
	_refresh_quest_list()


func _on_filter_pressed(filter: int) -> void:
	_current_filter = filter
	_refresh_quest_list()
	filter_changed.emit(StringName(FILTER_LABELS[filter].to_lower()))


func _on_sort_selected(idx: int) -> void:
	_current_sort = idx
	_refresh_quest_list()
	sort_changed.emit(StringName(SORT_LABELS[idx].to_lower().replace(" ", "_")))


func _refresh_quest_list() -> void:
	for child in _quest_list.get_children():
		child.queue_free()
	var quests: Array = _get_quests_for_tab()
	quests = _apply_filter(quests)
	quests = _apply_sort(quests)
	for q in quests:
		_add_quest_row(q)


func _get_quests_for_tab() -> Array:
	var result: Array = []
	if not has_node("/root/QuestManager"):
		return result
	var qm: Node = get_node("/root/QuestManager")
	var category: StringName = StringName(TAB_LABELS[_current_tab].to_lower())
	if qm.has_method("get_quests_by_category"):
		result = qm.call("get_quests_by_category", category)
	return result


func _apply_filter(quests: Array) -> Array:
	if _current_filter == Filter.ALL:
		return quests
	var key: String = FILTER_LABELS[_current_filter].to_lower()
	var filtered: Array = []
	for q in quests:
		if q.get("status", "active") == key:
			filtered.append(q)
	return filtered


func _apply_sort(quests: Array) -> Array:
	var sorted: Array = quests.duplicate()
	match _current_sort:
		SortOrder.NEWEST:
			sorted.sort_custom(func(a, b): return a.get("accepted_at", 0) > b.get("accepted_at", 0))
		SortOrder.OLDEST:
			sorted.sort_custom(func(a, b): return a.get("accepted_at", 0) < b.get("accepted_at", 0))
		SortOrder.ALPHABETICAL:
			sorted.sort_custom(func(a, b): return String(a.get("title", "")) < String(b.get("title", "")))
		SortOrder.BY_GIVER:
			sorted.sort_custom(func(a, b): return String(a.get("giver", "")) < String(b.get("giver", "")))
		SortOrder.BY_PROGRESS:
			sorted.sort_custom(func(a, b): return float(a.get("progress", 0.0)) > float(b.get("progress", 0.0)))
	return sorted


func _add_quest_row(quest: Dictionary) -> void:
	var btn := Button.new()
	btn.custom_minimum_size = Vector2(360, 50)
	var title: String = quest.get("title", "?")
	var status: String = quest.get("status", "active")
	btn.text = "%s\n[%s]" % [title, status.to_upper()]
	btn.pressed.connect(_on_quest_clicked.bind(quest))
	_quest_list.add_child(btn)


func _on_quest_clicked(quest: Dictionary) -> void:
	_selected_quest_id = quest.get("id", &"")
	quest_selected.emit(_selected_quest_id)
	_render_detail(quest)


func _render_detail(quest: Dictionary) -> void:
	_detail_title.text = quest.get("title", "")
	_detail_desc.text = quest.get("description", "")
	# Objectives
	for child in _detail_objectives.get_children():
		child.queue_free()
	for obj in quest.get("objectives", []):
		var label := Label.new()
		var done: bool = obj.get("done", false)
		var marker: String = "[x]" if done else "[ ]"
		label.text = "  %s %s" % [marker, str(obj.get("kind", "?")).capitalize()]
		label.add_theme_font_size_override("font_size", 13)
		label.add_theme_color_override("font_color", Color(0.85, 0.92, 1.0) if not done else Color(0.55, 0.95, 0.55))
		_detail_objectives.add_child(label)
	# Rewards
	for child in _detail_rewards.get_children():
		child.queue_free()
	var rewards: Dictionary = quest.get("rewards", {})
	if rewards.has("gold"):
		var l := Label.new()
		l.text = "  • %d gold" % int(rewards["gold"])
		l.add_theme_font_size_override("font_size", 13)
		l.add_theme_color_override("font_color", Color(1.0, 0.85, 0.30))
		_detail_rewards.add_child(l)
	if rewards.has("xp"):
		var l := Label.new()
		l.text = "  • %d XP" % int(rewards["xp"])
		l.add_theme_font_size_override("font_size", 13)
		l.add_theme_color_override("font_color", Color(0.6, 0.85, 1.0))
		_detail_rewards.add_child(l)
	for item in rewards.get("items", []):
		var l := Label.new()
		l.text = "  • %s × %d" % [item.get("id", "?"), int(item.get("qty", 1))]
		l.add_theme_font_size_override("font_size", 13)
		l.add_theme_color_override("font_color", Color(0.85, 0.92, 1.0))
		_detail_rewards.add_child(l)


func _on_close() -> void:
	visible = false
	screen_closed.emit()


func _input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("ui_cancel"):
		_on_close()
