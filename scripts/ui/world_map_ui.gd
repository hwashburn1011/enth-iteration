class_name WorldMapUI
extends Control

## Pan/zoom world map UI. Renders all 18 regions as markers based on
## discovery state, lets the player click waypoints, place notes, and
## fast travel to discovered regions.

signal map_closed
signal fast_travel_requested(region_id: StringName)

@export var min_zoom: float = 0.5
@export var max_zoom: float = 2.5
@export var zoom_step: float = 0.15

@onready var _map_canvas: Control = %MapCanvas
@onready var _markers_container: Control = %MarkersContainer
@onready var _legend: VBoxContainer = %Legend
@onready var _filter_dropdown: OptionButton = %FilterDropdown
@onready var _search_input: LineEdit = %SearchInput
@onready var _close_button: Button = %CloseButton

var _zoom: float = 1.0
var _pan_offset: Vector2 = Vector2.ZERO
var _dragging: bool = false
var _drag_start: Vector2
var _drag_offset_start: Vector2
var _filter_mode: StringName = &"all"
var _search_text: String = ""
var _marker_buttons: Dictionary = {}  ## region_id -> Button


func _ready() -> void:
	if _close_button != null:
		_close_button.pressed.connect(_on_close_pressed)
	if _filter_dropdown != null:
		_filter_dropdown.add_item("All", 0)
		_filter_dropdown.add_item("NPCs", 1)
		_filter_dropdown.add_item("Quests", 2)
		_filter_dropdown.add_item("Lore", 3)
		_filter_dropdown.add_item("Hidden Rooms", 4)
		_filter_dropdown.item_selected.connect(_on_filter_selected)
	if _search_input != null:
		_search_input.text_changed.connect(_on_search_changed)

	if has_node("/root/WorldMapManager"):
		var wmm: Node = get_node("/root/WorldMapManager")
		wmm.region_discovered.connect(_on_region_discovered)
		wmm.region_explored.connect(_on_region_explored)
		_build_markers()


func _build_markers() -> void:
	if _markers_container == null:
		return
	for c in _markers_container.get_children():
		c.queue_free()
	_marker_buttons.clear()

	var wmm: Node = get_node_or_null("/root/WorldMapManager")
	if wmm == null:
		return

	for region in RegionDatabase.get_all_regions():
		var region_id: StringName = region["id"]
		var is_discovered: bool = wmm.is_discovered(region_id)
		var is_explored: bool = wmm.is_explored(region_id)

		var btn: TextureButton = TextureButton.new()
		btn.name = String(region_id)
		btn.custom_minimum_size = Vector2(48, 48)
		btn.tooltip_text = _build_tooltip(region, is_discovered, is_explored)
		btn.position = (region["map_position"] as Vector2) - Vector2(24, 24)
		btn.modulate = _color_for_state(is_discovered, is_explored)
		btn.pressed.connect(_on_marker_pressed.bind(region_id))
		_markers_container.add_child(btn)
		_marker_buttons[region_id] = btn


func _build_tooltip(region: Dictionary, discovered: bool, explored: bool) -> String:
	if not discovered:
		return "???"
	var lines: PackedStringArray = [String(region["name"])]
	if explored:
		var wmm: Node = get_node_or_null("/root/WorldMapManager")
		if wmm != null:
			var pct: float = wmm.get_region_completion_pct(region["id"])
			lines.append("Completion: %.0f%%" % (pct * 100.0))
	lines.append(region.get("description", ""))
	return "\n".join(lines)


func _color_for_state(discovered: bool, explored: bool) -> Color:
	if not discovered:
		return Color(0.3, 0.3, 0.3, 0.5)
	if explored:
		return Color(0.4, 0.95, 0.4, 1.0)
	return Color(0.95, 0.85, 0.40, 1.0)


func _on_marker_pressed(region_id: StringName) -> void:
	var wmm: Node = get_node_or_null("/root/WorldMapManager")
	if wmm == null:
		return
	if not wmm.is_discovered(region_id):
		return
	# Show fast travel confirmation
	if wmm.can_fast_travel_to(region_id):
		fast_travel_requested.emit(region_id)


func _on_region_discovered(_region_id: StringName) -> void:
	_build_markers()


func _on_region_explored(_region_id: StringName) -> void:
	_build_markers()


func _on_filter_selected(index: int) -> void:
	const FILTERS: Array[StringName] = [&"all", &"npcs", &"quests", &"lore", &"hidden"]
	_filter_mode = FILTERS[index] if index < FILTERS.size() else &"all"
	_apply_filter()


func _on_search_changed(text: String) -> void:
	_search_text = text.to_lower()
	_apply_filter()


func _apply_filter() -> void:
	# Show/hide markers based on filter + search
	for region_id: StringName in _marker_buttons.keys():
		var btn: Button = _marker_buttons[region_id]
		var region: Dictionary = RegionDatabase.get_region(region_id)
		var visible: bool = true
		# Filter by search
		if not _search_text.is_empty():
			visible = String(region.get("name", "")).to_lower().contains(_search_text)
		btn.visible = visible


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mb: InputEventMouseButton = event
		if mb.button_index == MOUSE_BUTTON_MIDDLE or (mb.button_index == MOUSE_BUTTON_LEFT and mb.shift_pressed):
			_dragging = mb.pressed
			if _dragging:
				_drag_start = mb.position
				_drag_offset_start = _pan_offset
		elif mb.button_index == MOUSE_BUTTON_WHEEL_UP and mb.pressed:
			_zoom = clampf(_zoom + zoom_step, min_zoom, max_zoom)
			_apply_transform()
		elif mb.button_index == MOUSE_BUTTON_WHEEL_DOWN and mb.pressed:
			_zoom = clampf(_zoom - zoom_step, min_zoom, max_zoom)
			_apply_transform()
		elif mb.button_index == MOUSE_BUTTON_RIGHT and mb.pressed:
			# Right-click to set waypoint
			var wmm: Node = get_node_or_null("/root/WorldMapManager")
			if wmm != null:
				var local_pos: Vector2 = (mb.position - _pan_offset) / _zoom
				wmm.set_waypoint(local_pos)
	elif event is InputEventMouseMotion and _dragging:
		_pan_offset = _drag_offset_start + (event.position - _drag_start)
		_apply_transform()


func _apply_transform() -> void:
	if _map_canvas != null:
		_map_canvas.position = _pan_offset
		_map_canvas.scale = Vector2(_zoom, _zoom)


func _on_close_pressed() -> void:
	visible = false
	map_closed.emit()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"open_map"):
		visible = not visible
		if visible:
			_build_markers()
