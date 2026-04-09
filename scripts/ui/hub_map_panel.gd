class_name HubMapPanel
extends Control

## Town hub interior map. Renders the 17 hub fast-travel points from
## HubFastTravelDatabase as clickable markers, color-coded by lock
## state, with the 3 special story-locked spaces highlighted (Memorial
## Gallery, Hidden Treasure Room, Tower Top). Click an unlocked
## marker to fast-travel via HubFastTravelManager.travel_to.
##
## Pan with right-mouse-drag, zoom with the wheel, hover for tooltip.
## Updates live on point_unlocked signal so the player can solve the
## bookshelf puzzle, open the map, and immediately see the Hidden
## Treasure Room marker pop in.
##
## Required scene shape:
##   HubMapPanel (Control + this script)
##     %MapCanvas (Control)
##     %DistrictPolygons (Control with _draw connected to _draw_districts)
##     %MarkersLayer (Control — marker buttons spawned at runtime)
##     %PlayerDot (Control — pulsing player position marker)
##     %TooltipPanel (PanelContainer)
##       %TooltipName (Label)
##       %TooltipDescription (Label)
##       %TooltipHint (Label — shown when locked)
##     %CloseButton (Button)
##     %DiscoveryCounter (Label — "10 / 17 points")
##     %FilterDropdown (OptionButton — All / Unlocked / Locked)

signal map_closed
signal travel_requested(point_id: StringName)

const WORLD_TO_PIXEL: float = 8.0  # 1 meter = 8 pixels at zoom 1
const CANVAS_CENTER: Vector2 = Vector2(550, 450)
const MIN_ZOOM: float = 0.5
const MAX_ZOOM: float = 3.0
const ZOOM_STEP: float = 0.15

@onready var _map_canvas: Control = %MapCanvas
@onready var _district_polygons: Control = %DistrictPolygons
@onready var _markers_layer: Control = %MarkersLayer
@onready var _player_dot: Control = %PlayerDot
@onready var _tooltip_panel: PanelContainer = %TooltipPanel
@onready var _tooltip_name: Label = %TooltipName
@onready var _tooltip_description: Label = %TooltipDescription
@onready var _tooltip_hint: Label = %TooltipHint
@onready var _close_button: Button = %CloseButton
@onready var _discovery_counter: Label = %DiscoveryCounter
@onready var _filter_dropdown: OptionButton = %FilterDropdown

var _zoom: float = 1.0
var _pan_offset: Vector2 = Vector2.ZERO
var _dragging: bool = false
var _drag_start: Vector2
var _drag_offset_start: Vector2
var _filter_mode: int = 0  # 0=all, 1=unlocked, 2=locked

# Approximate town district polygons (in world coords, XZ plane)
const DISTRICT_POLYGONS: Dictionary = {
	&"residential": [Vector2(-30, -2), Vector2(-2, -2), Vector2(-2, 18), Vector2(-30, 18)],
	&"workshop":    [Vector2(  2, -2), Vector2( 30, -2), Vector2( 30, 18), Vector2(  2, 18)],
	&"market":      [Vector2(-15, 18), Vector2( 15, 18), Vector2( 15, 30), Vector2(-15, 30)],
	&"sage_sanctum":[Vector2(-10, -22), Vector2( 10, -22), Vector2( 10, -2), Vector2(-10, -2)],
}

const DISTRICT_COLORS: Dictionary = {
	&"residential": Color(0.65, 0.55, 0.40, 0.30),
	&"workshop":    Color(0.55, 0.55, 0.55, 0.30),
	&"market":      Color(0.85, 0.75, 0.50, 0.30),
	&"sage_sanctum":Color(0.55, 0.42, 0.65, 0.30),
}

const SPECIAL_SPACES: Array[StringName] = [
	&"hub_memorial_gallery",
	&"hub_treasure_room",
	&"hub_tower_top",
]


func _ready() -> void:
	if _close_button != null:
		_close_button.pressed.connect(_on_close_pressed)
	if _district_polygons != null:
		_district_polygons.draw.connect(_draw_districts)
	if _filter_dropdown != null:
		_filter_dropdown.add_item("All", 0)
		_filter_dropdown.add_item("Unlocked", 1)
		_filter_dropdown.add_item("Locked", 2)
		_filter_dropdown.item_selected.connect(_on_filter_changed)
	if _tooltip_panel != null:
		_tooltip_panel.visible = false

	if has_node("/root/HubFastTravelManager"):
		var hftm: Node = get_node("/root/HubFastTravelManager")
		if hftm.has_signal("point_unlocked"):
			hftm.point_unlocked.connect(_on_point_unlocked)

	_build_markers()
	_update_counter()


func _process(_delta: float) -> void:
	_update_player_dot()


# === DRAW ===

func _draw_districts() -> void:
	if _district_polygons == null:
		return
	for district_id in DISTRICT_POLYGONS.keys():
		var polygon: Array = DISTRICT_POLYGONS[district_id]
		var pts: PackedVector2Array = PackedVector2Array()
		for v in polygon:
			pts.append(_world_to_canvas(Vector3(v.x, 0, v.y)))
		var color: Color = DISTRICT_COLORS.get(district_id, Color(0.5, 0.5, 0.5, 0.25))
		_district_polygons.draw_colored_polygon(pts, color)
		_district_polygons.draw_polyline(
			pts + PackedVector2Array([pts[0]]),
			Color(color.r, color.g, color.b, 0.85),
			2.0
		)


# === MARKERS ===

func _build_markers() -> void:
	if _markers_layer == null:
		return
	for c in _markers_layer.get_children():
		c.queue_free()

	for entry in HubFastTravelDatabase.get_all():
		var pid: StringName = entry["id"]
		var unlocked: bool = _is_unlocked(pid)

		# Apply filter
		if _filter_mode == 1 and not unlocked:
			continue
		if _filter_mode == 2 and unlocked:
			continue

		var btn: Button = Button.new()
		btn.flat = false
		var is_special: bool = SPECIAL_SPACES.has(pid)
		btn.text = _icon_for(pid, unlocked, is_special)
		var color: Color = _color_for(unlocked, is_special)
		btn.add_theme_color_override(&"font_color", color)
		btn.position = _world_to_canvas(entry["world_position"]) - Vector2(14, 14)
		btn.custom_minimum_size = Vector2(28, 28)
		btn.tooltip_text = entry["display_name"]
		btn.disabled = not unlocked
		btn.mouse_entered.connect(_on_marker_hover.bind(entry, unlocked))
		btn.mouse_exited.connect(_on_marker_hover_exit)
		btn.pressed.connect(_on_marker_pressed.bind(pid))
		_markers_layer.add_child(btn)


func _icon_for(pid: StringName, unlocked: bool, is_special: bool) -> String:
	if not unlocked:
		return "○" if not is_special else "?"
	if is_special:
		return "★"
	return "◉"


func _color_for(unlocked: bool, is_special: bool) -> Color:
	if not unlocked:
		return Color(0.50, 0.50, 0.55)
	if is_special:
		return Color(1.00, 0.85, 0.40)
	return Color(0.45, 0.85, 1.00)


# === PLAYER DOT ===

func _update_player_dot() -> void:
	if _player_dot == null:
		return
	var player: Node3D = _find_player()
	if player == null:
		_player_dot.visible = false
		return
	_player_dot.visible = true
	_player_dot.position = _world_to_canvas(player.global_position) - Vector2(8, 8)
	var pulse: float = 0.6 + sin(Time.get_ticks_msec() / 250.0) * 0.4
	_player_dot.modulate.a = pulse


func _find_player() -> Node3D:
	var nodes: Array = get_tree().get_nodes_in_group(&"player")
	if nodes.is_empty():
		return null
	return nodes[0] as Node3D


# === COORDS ===

func _world_to_canvas(world: Vector3) -> Vector2:
	# X right, Z up (north positive Z), so we flip Z to screen-down
	var local: Vector2 = Vector2(world.x, -world.z) * WORLD_TO_PIXEL * _zoom
	return CANVAS_CENTER + _pan_offset + local


# === HOVER ===

func _on_marker_hover(entry: Dictionary, unlocked: bool) -> void:
	if _tooltip_panel == null:
		return
	if _tooltip_name != null:
		_tooltip_name.text = entry.get("display_name", "")
	if _tooltip_description != null:
		_tooltip_description.text = entry.get("description", "")
	if _tooltip_hint != null:
		if unlocked:
			_tooltip_hint.text = ""
			_tooltip_hint.visible = false
		else:
			_tooltip_hint.text = entry.get("locked_hint", "Locked.")
			_tooltip_hint.visible = true
	_tooltip_panel.visible = true
	_tooltip_panel.position = get_global_mouse_position() + Vector2(16, 16)


func _on_marker_hover_exit() -> void:
	if _tooltip_panel != null:
		_tooltip_panel.visible = false


# === INTERACTION ===

func _on_marker_pressed(point_id: StringName) -> void:
	travel_requested.emit(point_id)
	if has_node("/root/HubFastTravelManager"):
		var hftm: Node = get_node("/root/HubFastTravelManager")
		if hftm.has_method("travel_to"):
			hftm.travel_to(point_id)
	_on_close_pressed()


func _on_close_pressed() -> void:
	map_closed.emit()
	visible = false


# === COUNTER ===

func _update_counter() -> void:
	if _discovery_counter == null:
		return
	if not has_node("/root/HubFastTravelManager"):
		return
	var hftm: Node = get_node("/root/HubFastTravelManager")
	var unlocked: int = hftm.get_unlocked_count() if hftm.has_method("get_unlocked_count") else 0
	var total: int = hftm.get_total_count() if hftm.has_method("get_total_count") else HubFastTravelDatabase.get_count()
	_discovery_counter.text = "%d / %d points" % [unlocked, total]


func _on_point_unlocked(_pid: StringName) -> void:
	_build_markers()
	_update_counter()


func _on_filter_changed(index: int) -> void:
	_filter_mode = index
	_build_markers()


# === STATE ===

func _is_unlocked(point_id: StringName) -> bool:
	if not has_node("/root/HubFastTravelManager"):
		return false
	var hftm: Node = get_node("/root/HubFastTravelManager")
	if hftm.has_method("is_unlocked"):
		return hftm.is_unlocked(point_id)
	return false


# === INPUT (pan + zoom) ===

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var btn: InputEventMouseButton = event
		if btn.button_index == MOUSE_BUTTON_WHEEL_UP and btn.pressed:
			_set_zoom(_zoom + ZOOM_STEP)
			_rebuild()
		elif btn.button_index == MOUSE_BUTTON_WHEEL_DOWN and btn.pressed:
			_set_zoom(_zoom - ZOOM_STEP)
			_rebuild()
		elif btn.button_index == MOUSE_BUTTON_RIGHT:
			if btn.pressed:
				_dragging = true
				_drag_start = btn.position
				_drag_offset_start = _pan_offset
			else:
				_dragging = false
	elif event is InputEventMouseMotion and _dragging:
		var motion: InputEventMouseMotion = event
		_pan_offset = _drag_offset_start + (motion.position - _drag_start)
		_rebuild()


func _set_zoom(z: float) -> void:
	_zoom = clampf(z, MIN_ZOOM, MAX_ZOOM)


func _rebuild() -> void:
	if _district_polygons != null:
		_district_polygons.queue_redraw()
	_build_markers()
