class_name QuestLog
extends CanvasLayer
## Quest log UI — categorized view of active and completed quests. Pauses game.

var _panel: Control = null
var _quest_list: VBoxContainer = null
var _active_category: String = "story"

const CATEGORIES: Array[String] = ["story", "character", "discovery"]


func _ready() -> void:
	layer = 55
	process_mode = Node.PROCESS_MODE_ALWAYS
	_build_ui()
	get_tree().paused = true
	GameManager.set_state(GameManager.GameState.INVENTORY)


func _unhandled_input(event: InputEvent) -> void:
	if _panel == null:
		return
	if event.is_action_pressed(&"pause") or event.is_action_pressed(&"toggle_quest_log"):
		_close()
		get_viewport().set_input_as_handled()


func _build_ui() -> void:
	_panel = Control.new()
	_panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	_panel.mouse_filter = Control.MOUSE_FILTER_STOP

	var bg: ColorRect = ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0.02, 0.02, 0.06, 0.7)
	_panel.add_child(bg)

	var hbox: HBoxContainer = HBoxContainer.new()
	hbox.set_anchors_preset(Control.PRESET_CENTER)
	hbox.offset_left = -300.0
	hbox.offset_top = -200.0
	hbox.offset_right = 300.0
	hbox.offset_bottom = 200.0
	hbox.add_theme_constant_override(&"separation", 12)

	# Left: category tabs
	var tabs: VBoxContainer = VBoxContainer.new()
	tabs.custom_minimum_size = Vector2(120, 0)
	tabs.add_theme_constant_override(&"separation", 8)
	var title: Label = Label.new()
	title.text = "Quest Log"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_color_override(&"font_color", Color(0.3, 0.85, 0.8))
	title.add_theme_font_size_override(&"font_size", 22)
	tabs.add_child(title)
	for cat: String in CATEGORIES:
		var btn: Button = Button.new()
		btn.text = cat.capitalize()
		btn.pressed.connect(_on_category_selected.bind(cat))
		_style_tab_button(btn)
		tabs.add_child(btn)
	hbox.add_child(tabs)

	# Right: quest list
	var list_panel: PanelContainer = PanelContainer.new()
	list_panel.custom_minimum_size = Vector2(400, 0)
	var scroll: ScrollContainer = ScrollContainer.new()
	_quest_list = VBoxContainer.new()
	_quest_list.add_theme_constant_override(&"separation", 8)
	scroll.add_child(_quest_list)
	list_panel.add_child(scroll)
	hbox.add_child(list_panel)

	_panel.add_child(hbox)
	add_child(_panel)
	_populate_quests()


func _on_category_selected(category: String) -> void:
	_active_category = category
	_populate_quests()


func _populate_quests() -> void:
	for child: Node in _quest_list.get_children():
		child.queue_free()

	var quests: Array[Resource] = QuestManager.get_quests_by_category(_active_category)
	if quests.is_empty():
		var empty_lbl: Label = Label.new()
		empty_lbl.text = "No quests in this category."
		empty_lbl.modulate = Color(0.5, 0.5, 0.5)
		_quest_list.add_child(empty_lbl)
		return

	# Active first, completed at bottom
	var active: Array[Resource] = []
	var completed: Array[Resource] = []
	for q: QuestData in quests:
		if q.is_completed:
			completed.append(q)
		else:
			active.append(q)

	for q: QuestData in active:
		_quest_list.add_child(_create_quest_entry(q, false))
	for q: QuestData in completed:
		_quest_list.add_child(_create_quest_entry(q, true))


func _create_quest_entry(quest: QuestData, is_done: bool) -> PanelContainer:
	var entry: PanelContainer = PanelContainer.new()
	var entry_style: StyleBoxFlat = StyleBoxFlat.new()
	entry_style.bg_color = Color(0.06, 0.07, 0.14, 0.8) if not is_done else Color(0.04, 0.05, 0.08, 0.6)
	entry_style.border_color = Color(0.12, 0.3, 0.4, 0.5) if not is_done else Color(0.1, 0.15, 0.2, 0.3)
	entry_style.set_border_width_all(1)
	entry_style.set_corner_radius_all(4)
	entry_style.set_content_margin_all(8)
	entry.add_theme_stylebox_override(&"panel", entry_style)
	var vbox: VBoxContainer = VBoxContainer.new()

	var name_lbl: Label = Label.new()
	name_lbl.text = ("✓ " if is_done else "● ") + quest.quest_name
	if is_done:
		name_lbl.modulate = Color(0.5, 0.5, 0.5)
	vbox.add_child(name_lbl)

	var desc_lbl: Label = Label.new()
	desc_lbl.text = quest.description
	desc_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD
	desc_lbl.add_theme_font_size_override(&"font_size", 13)
	if is_done:
		desc_lbl.modulate = Color(0.5, 0.5, 0.5)
	vbox.add_child(desc_lbl)

	for obj: QuestObjective in quest.objectives:
		var obj_lbl: Label = Label.new()
		obj_lbl.text = "  %s (%d/%d)" % [obj.objective_text, obj.current_count, obj.target_count]
		obj_lbl.add_theme_font_size_override(&"font_size", 12)
		vbox.add_child(obj_lbl)

	entry.add_child(vbox)
	return entry


func _close() -> void:
	if _panel:
		_panel.queue_free()
	get_tree().paused = false
	GameManager.set_state(GameManager.GameState.PLAYING)
	queue_free()


func _style_tab_button(btn: Button) -> void:
	var normal: StyleBoxFlat = StyleBoxFlat.new()
	normal.bg_color = Color(0.08, 0.1, 0.18, 0.9)
	normal.border_color = Color(0.15, 0.35, 0.45, 0.5)
	normal.set_border_width_all(1)
	normal.set_corner_radius_all(4)
	normal.set_content_margin_all(8)
	var hover: StyleBoxFlat = StyleBoxFlat.new()
	hover.bg_color = Color(0.12, 0.15, 0.28, 0.95)
	hover.border_color = Color(0.25, 0.6, 0.7, 0.8)
	hover.set_border_width_all(1)
	hover.set_corner_radius_all(4)
	hover.set_content_margin_all(8)
	var focus: StyleBoxFlat = hover.duplicate() as StyleBoxFlat
	focus.set_border_width_all(2)
	btn.add_theme_stylebox_override(&"normal", normal)
	btn.add_theme_stylebox_override(&"hover", hover)
	btn.add_theme_stylebox_override(&"focus", focus)
	btn.add_theme_color_override(&"font_color", Color(0.7, 0.75, 0.8))
	btn.add_theme_color_override(&"font_hover_color", Color(0.3, 0.85, 0.8))
	btn.add_theme_font_size_override(&"font_size", 16)
