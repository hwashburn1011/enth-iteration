class_name DungeonSelectionUI
extends Control

## Dungeon selection screen — shows all 4 entrances at once with their
## unlock state, daily bonus indicator, clear count, best time, and a
## confirm button.

signal entrance_selected(entrance_id: StringName)
signal closed

@onready var _entry_list: VBoxContainer = %EntryList
@onready var _close_button: Button = %CloseButton
@onready var _details_panel: PanelContainer = %DetailsPanel
@onready var _details_name: Label = %DetailsName
@onready var _details_lore: Label = %DetailsLore
@onready var _details_difficulty: Label = %DetailsDifficulty
@onready var _details_level: Label = %DetailsLevel
@onready var _details_clears: Label = %DetailsClears
@onready var _details_best_time: Label = %DetailsBestTime
@onready var _enter_button: Button = %EnterButton

var _selected_entrance_id: StringName = &""


func _ready() -> void:
	if _close_button != null:
		_close_button.pressed.connect(_on_close_pressed)
	if _enter_button != null:
		_enter_button.pressed.connect(_on_enter_pressed)
	_build_entry_list()


func _build_entry_list() -> void:
	if _entry_list == null:
		return
	for c in _entry_list.get_children():
		c.queue_free()

	var dem: Node = get_node_or_null("/root/DungeonEntranceManager")
	if dem == null:
		return

	for entrance in DungeonEntranceDatabase.get_all():
		var entrance_id: StringName = entrance["id"]
		var btn: Button = Button.new()
		btn.text = entrance.get("display_name", "")
		btn.custom_minimum_size = Vector2(300, 60)
		var is_discovered: bool = dem.is_discovered(entrance_id)
		var is_daily: bool = dem.is_daily_bonus_biome(entrance.get("biome_id", &""))

		if not is_discovered:
			btn.text = "??? (Locked)"
			btn.disabled = true
			btn.modulate = Color(0.5, 0.5, 0.5)
		elif is_daily:
			btn.text = "★ " + btn.text + " (Daily Bonus)"
			btn.modulate = Color(1.0, 0.95, 0.65)

		btn.pressed.connect(_on_entry_pressed.bind(entrance_id))
		_entry_list.add_child(btn)


func _on_entry_pressed(entrance_id: StringName) -> void:
	_selected_entrance_id = entrance_id
	_show_details(entrance_id)


func _show_details(entrance_id: StringName) -> void:
	var entrance: Dictionary = DungeonEntranceDatabase.get_entrance(entrance_id)
	if entrance.is_empty() or _details_panel == null:
		return
	_details_panel.visible = true

	var dem: Node = get_node_or_null("/root/DungeonEntranceManager")
	if _details_name != null:
		_details_name.text = entrance.get("display_name", "")
	if _details_lore != null:
		_details_lore.text = entrance.get("lore_plaque", "")
	if _details_difficulty != null:
		var stars: String = "★".repeat(entrance.get("difficulty_stars", 1)) + "☆".repeat(5 - entrance.get("difficulty_stars", 1))
		_details_difficulty.text = "Difficulty: " + stars
	if _details_level != null:
		_details_level.text = "Recommended Level: %d+" % entrance.get("recommended_level", 1)
	if _details_clears != null and dem != null:
		_details_clears.text = "Cleared: %d times" % dem.get_clear_count(entrance_id)
	if _details_best_time != null and dem != null:
		var best: int = dem.get_best_time(entrance_id)
		if best > 0:
			_details_best_time.text = "Best: %d:%02d" % [best / 60, best % 60]
		else:
			_details_best_time.text = "Best: --"


func _on_enter_pressed() -> void:
	if _selected_entrance_id == &"":
		return
	entrance_selected.emit(_selected_entrance_id)
	visible = false


func _on_close_pressed() -> void:
	visible = false
	closed.emit()
