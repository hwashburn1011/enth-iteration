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
	_panel.anchors_preset = Control.PRESET_FULL_RECT
	_panel.mouse_filter = Control.MOUSE_FILTER_STOP

	var bg: ColorRect = ColorRect.new()
	bg.anchors_preset = Control.PRESET_FULL_RECT
	bg.color = Color(0, 0, 0, 0.6)
	_panel.add_child(bg)

	var hbox: HBoxContainer = HBoxContainer.new()
	hbox.anchors_preset = Control.PRESET_CENTER
	hbox.offset_left = -300.0
	hbox.offset_top = -200.0
	hbox.offset_right = 300.0
	hbox.offset_bottom = 200.0
	hbox.theme_override_constants_separation = 12

	# Left: category tabs
	var tabs: VBoxContainer = VBoxContainer.new()
	tabs.custom_minimum_size = Vector2(120, 0)
	tabs.theme_override_constants_separation = 8
	var title: Label = Label.new()
	title.text = "Quest Log"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tabs.add_child(title)
	for cat: String in CATEGORIES:
		var btn: Button = Button.new()
		btn.text = cat.capitalize()
		btn.pressed.connect(_on_category_selected.bind(cat))
		tabs.add_child(btn)
	hbox.add_child(tabs)

	# Right: quest list
	var list_panel: PanelContainer = PanelContainer.new()
	list_panel.custom_minimum_size = Vector2(400, 0)
	var scroll: ScrollContainer = ScrollContainer.new()
	_quest_list = VBoxContainer.new()
	_quest_list.theme_override_constants_separation = 8
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

	var quests: Array[QuestData] = QuestManager.get_quests_by_category(_active_category)
	if quests.is_empty():
		var empty_lbl: Label = Label.new()
		empty_lbl.text = "No quests in this category."
		empty_lbl.modulate = Color(0.5, 0.5, 0.5)
		_quest_list.add_child(empty_lbl)
		return

	# Active first, completed at bottom
	var active: Array[QuestData] = []
	var completed: Array[QuestData] = []
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
