class_name WorldMapControllerNav
extends Node

## World Map Controller Navigation (Epic 28 task 47).
##
## Gives the world map UI full gamepad support. Attaches to a map panel
## root (Control) and provides:
##   - D-pad / left stick: pan the map cursor over the parchment
##   - Right stick: pan the map view (scroll)
##   - Trigger L/R: zoom out/in
##   - South button (A/cross): activate focused marker
##   - East button (B/circle): close map
##   - Y (triangle): open filter menu
##   - X (square): add waypoint at cursor
##   - Shoulder L/R: cycle between marker categories (towns/dungeons/quests/lore)
##
## The nav keeps an internal "focused marker" index and updates visual focus
## on any Control node registered via register_marker(). Markers are ranked
## by screen-space distance to the cursor so D-pad input jumps to the
## nearest marker in the pressed direction — natural behavior for map UIs.

signal cursor_moved(position: Vector2)
signal marker_focused(marker_id: StringName)
signal marker_activated(marker_id: StringName)
signal map_closed
signal map_zoom_changed(zoom: float)
signal map_panned(offset: Vector2)
signal waypoint_placed(position: Vector2)
signal filter_opened
signal category_cycled(direction: int)

const CURSOR_SPEED: float = 320.0  # pixels/sec
const PAN_SPEED: float = 450.0
const ZOOM_SPEED: float = 1.2      # multiplier/sec
const ZOOM_MIN: float = 0.5
const ZOOM_MAX: float = 2.5
const DEADZONE: float = 0.2

@export var map_panel_path: NodePath
@export var enabled: bool = true

var _cursor_position: Vector2 = Vector2.ZERO
var _pan_offset: Vector2 = Vector2.ZERO
var _zoom: float = 1.0
var _markers: Dictionary = {}  # marker_id → {control: Control, position: Vector2, category: StringName}
var _focused_marker_id: StringName = &""
var _map_panel: Control


func _ready() -> void:
	_map_panel = get_node_or_null(map_panel_path) as Control
	set_process(enabled)
	set_process_input(enabled)
	if _map_panel != null:
		_cursor_position = _map_panel.size * 0.5


func register_marker(marker_id: StringName, control: Control, world_pos: Vector2, category: StringName = &"all") -> void:
	_markers[marker_id] = {
		"control": control,
		"position": world_pos,
		"category": category,
	}


func unregister_marker(marker_id: StringName) -> void:
	_markers.erase(marker_id)
	if _focused_marker_id == marker_id:
		_focused_marker_id = &""


func clear_markers() -> void:
	_markers.clear()
	_focused_marker_id = &""


func _process(delta: float) -> void:
	if not enabled:
		return
	_handle_cursor(delta)
	_handle_pan(delta)
	_handle_zoom(delta)


func _input(event: InputEvent) -> void:
	if not enabled:
		return

	# D-pad discrete jumps to nearest marker in direction
	if event.is_action_pressed("ui_up"):
		_jump_to_nearest_marker(Vector2.UP)
	elif event.is_action_pressed("ui_down"):
		_jump_to_nearest_marker(Vector2.DOWN)
	elif event.is_action_pressed("ui_left"):
		_jump_to_nearest_marker(Vector2.LEFT)
	elif event.is_action_pressed("ui_right"):
		_jump_to_nearest_marker(Vector2.RIGHT)
	# South button: activate
	elif event.is_action_pressed("ui_accept"):
		_activate_focused_marker()
	# East button: close map
	elif event.is_action_pressed("ui_cancel"):
		map_closed.emit()
	# Y button: filter menu
	elif event.is_action_pressed("map_filter"):
		filter_opened.emit()
	# X button: waypoint
	elif event.is_action_pressed("map_waypoint"):
		waypoint_placed.emit(_cursor_position + _pan_offset)
	# Shoulders: cycle category
	elif event.is_action_pressed("map_cycle_prev"):
		category_cycled.emit(-1)
	elif event.is_action_pressed("map_cycle_next"):
		category_cycled.emit(1)


func _handle_cursor(delta: float) -> void:
	var stick: Vector2 = Vector2.ZERO
	if Input.get_connected_joypads().size() > 0:
		var x: float = Input.get_joy_axis(0, JOY_AXIS_LEFT_X)
		var y: float = Input.get_joy_axis(0, JOY_AXIS_LEFT_Y)
		if abs(x) > DEADZONE:
			stick.x = x
		if abs(y) > DEADZONE:
			stick.y = y
	if stick == Vector2.ZERO:
		return
	_cursor_position += stick * CURSOR_SPEED * delta
	if _map_panel != null:
		_cursor_position.x = clamp(_cursor_position.x, 0, _map_panel.size.x)
		_cursor_position.y = clamp(_cursor_position.y, 0, _map_panel.size.y)
	cursor_moved.emit(_cursor_position)
	_update_focus_by_proximity()


func _handle_pan(delta: float) -> void:
	var stick: Vector2 = Vector2.ZERO
	if Input.get_connected_joypads().size() > 0:
		var x: float = Input.get_joy_axis(0, JOY_AXIS_RIGHT_X)
		var y: float = Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y)
		if abs(x) > DEADZONE:
			stick.x = x
		if abs(y) > DEADZONE:
			stick.y = y
	if stick == Vector2.ZERO:
		return
	_pan_offset += stick * PAN_SPEED * delta
	map_panned.emit(_pan_offset)


func _handle_zoom(delta: float) -> void:
	if Input.get_connected_joypads().size() == 0:
		return
	var l_trig: float = Input.get_joy_axis(0, JOY_AXIS_TRIGGER_LEFT)
	var r_trig: float = Input.get_joy_axis(0, JOY_AXIS_TRIGGER_RIGHT)
	var zoom_delta: float = 0.0
	if r_trig > 0.15:
		zoom_delta += r_trig * ZOOM_SPEED * delta
	if l_trig > 0.15:
		zoom_delta -= l_trig * ZOOM_SPEED * delta
	if zoom_delta != 0.0:
		_zoom = clamp(_zoom + zoom_delta, ZOOM_MIN, ZOOM_MAX)
		map_zoom_changed.emit(_zoom)


func _jump_to_nearest_marker(direction: Vector2) -> void:
	if _markers.is_empty():
		return
	var best_id: StringName = &""
	var best_score: float = INF
	for mid: StringName in _markers.keys():
		var data: Dictionary = _markers[mid]
		var mpos: Vector2 = data["position"]
		var delta: Vector2 = mpos - _cursor_position
		var proj: float = delta.dot(direction)
		if proj <= 0.5:
			continue  # not in the target direction
		var perp: float = delta.length() - proj
		var score: float = proj + perp * 2.0  # penalize sideways offset
		if score < best_score:
			best_score = score
			best_id = mid
	if best_id != &"":
		_focused_marker_id = best_id
		_cursor_position = _markers[best_id]["position"]
		cursor_moved.emit(_cursor_position)
		marker_focused.emit(_focused_marker_id)


func _update_focus_by_proximity() -> void:
	if _markers.is_empty():
		return
	var best_id: StringName = &""
	var best_dist: float = 40.0  # 40-pixel focus radius
	for mid: StringName in _markers.keys():
		var mpos: Vector2 = _markers[mid]["position"]
		var d: float = mpos.distance_to(_cursor_position)
		if d < best_dist:
			best_dist = d
			best_id = mid
	if best_id != _focused_marker_id:
		_focused_marker_id = best_id
		if _focused_marker_id != &"":
			marker_focused.emit(_focused_marker_id)


func _activate_focused_marker() -> void:
	if _focused_marker_id != &"":
		marker_activated.emit(_focused_marker_id)
