class_name WildernessMapPanel
extends Control

## Wilderness map screen. Renders the 6 sub-region polygons, 9 landmarks,
## 7 fast-travel waypoints, 4 dungeon entrance portals, and the player's
## current position. Discovered elements are full-color and clickable;
## undiscovered elements show as silhouettes.
##
## Required scene shape:
##   WildernessMapPanel (Control + this script)
##     %MapCanvas (Control)        — the pan/zoom canvas
##     %RegionsLayer (Control)     — region polygons drawn with _draw()
##     %LandmarksLayer (Control)   — landmark icon buttons
##     %WaypointsLayer (Control)   — waypoint fast-travel buttons
##     %EntrancesLayer (Control)   — dungeon entrance portal buttons
##     %PlayerDot (Control)        — pulsing player position marker
##     %TooltipPanel (PanelContainer)
##       %TooltipName (Label)
##       %TooltipDescription (Label)
##     %CloseButton (Button)
##     %DiscoveryCounter (Label)   — "5 / 7 waypoints"
##
## World coordinates are mapped to screen pixels via WORLD_TO_PIXEL.
## Wilderness world is roughly ±110m on X and ±90m on Z, fitting a
## 1100×900 canvas at the default zoom.

signal map_closed
signal fast_travel_requested(waypoint_id: StringName)

const WORLD_TO_PIXEL: float = 5.0  # 1 meter = 5 pixels at zoom 1
const CANVAS_CENTER: Vector2 = Vector2(550, 450)
const MIN_ZOOM: float = 0.5
const MAX_ZOOM: float = 3.0
const ZOOM_STEP: float = 0.15

@onready var _map_canvas: Control = %MapCanvas
@onready var _regions_layer: Control = %RegionsLayer
@onready var _landmarks_layer: Control = %LandmarksLayer
@onready var _waypoints_layer: Control = %WaypointsLayer
@onready var _entrances_layer: Control = %EntrancesLayer
@onready var _player_dot: Control = %PlayerDot
@onready var _tooltip_panel: PanelContainer = %TooltipPanel
@onready var _tooltip_name: Label = %TooltipName
@onready var _tooltip_description: Label = %TooltipDescription
@onready var _close_button: Button = %CloseButton
@onready var _discovery_counter: Label = %DiscoveryCounter

var _zoom: float = 1.0
var _pan_offset: Vector2 = Vector2.ZERO
var _dragging: bool = false
var _drag_start: Vector2
var _drag_offset_start: Vector2

const REGION_COLORS: Dictionary = {
	&"wild_plateau": Color(0.50, 0.65, 0.40, 0.35),
	&"wild_river":   Color(0.30, 0.55, 0.75, 0.35),
	&"wild_forest":  Color(0.20, 0.45, 0.25, 0.40),
	&"wild_ruins":   Color(0.55, 0.50, 0.45, 0.35),
	&"wild_cliffs":  Color(0.45, 0.42, 0.50, 0.40),
	&"wild_pasture": Color(0.65, 0.70, 0.45, 0.35),
}

# Approximate region polygons in world coords (XZ plane).
const REGION_POLYGONS: Dictionary = {
	&"wild_plateau": [
		Vector3(-50, 0,  80), Vector3( 50, 0,  80),
		Vector3( 50, 0,  20), Vector3(-50, 0,  20),
	],
	&"wild_river": [
		Vector3(-60, 0,  20), Vector3( 60, 0,  20),
		Vector3( 60, 0, -20), Vector3(-60, 0, -20),
	],
	&"wild_forest": [
		Vector3(-110, 0,  10), Vector3(-50, 0,  10),
		Vector3(-50, 0, -50), Vector3(-110, 0, -50),
	],
	&"wild_ruins": [
		Vector3( 50, 0,  10), Vector3(110, 0,  10),
		Vector3(110, 0, -50), Vector3( 50, 0, -50),
	],
	&"wild_cliffs": [
		Vector3(-110, 0, -50), Vector3(110, 0, -50),
		Vector3( 110, 0, -90), Vector3(-110, 0, -90),
	],
	&"wild_pasture": [
		Vector3( 20, 0,  20), Vector3( 60, 0,  20),
		Vector3( 60, 0,   0), Vector3( 20, 0,   0),
	],
}

# Landmark world positions (matches WildernessLandmarkDatabase if/when added)
const LANDMARKS: Array[Dictionary] = [
	{"id": &"lm_arch",          "name": "Town Gate Archway",  "pos": Vector3(  0, 0,  60), "icon": "⌂"},
	{"id": &"lm_three_cairns",  "name": "Three Cairns",       "pos": Vector3(  0, 0,   0), "icon": "▲"},
	{"id": &"lm_bridge",        "name": "Half Bridge",        "pos": Vector3(-12, 0, -10), "icon": "═"},
	{"id": &"lm_listening_tree","name": "Listening Tree",     "pos": Vector3(-30, 0, -20), "icon": "♣"},
	{"id": &"lm_spire",         "name": "Tilted Spire",       "pos": Vector3( 28, 0, -15), "icon": "⌇"},
	{"id": &"lm_four_mouths",   "name": "Four Mouths",        "pos": Vector3(  0, 0, -85), "icon": "◊◊◊◊"},
	{"id": &"lm_campsite",      "name": "Campsite",           "pos": Vector3( 35, 0,   5), "icon": "△"},
	{"id": &"lm_signpost_main", "name": "Main Signpost",      "pos": Vector3(  0, 0,  40), "icon": "↕"},
	{"id": &"lm_shrine",        "name": "Shrine of the Loop", "pos": Vector3(-25, 0,   5), "icon": "✦"},
]


func _ready() -> void:
	if _close_button != null:
		_close_button.pressed.connect(_on_close_pressed)
	if _regions_layer != null:
		_regions_layer.draw.connect(_draw_regions)
	if _tooltip_panel != null:
		_tooltip_panel.visible = false
	_build_landmarks()
	_build_waypoints()
	_build_entrances()
	_update_discovery_counter()
	if has_node("/root/WildernessWaypointManager"):
		var wwm: Node = get_node("/root/WildernessWaypointManager")
		if wwm.has_signal("waypoint_discovered"):
			wwm.waypoint_discovered.connect(_on_waypoint_discovered)


func _process(_delta: float) -> void:
	_update_player_dot()


# === BUILD ===

func _build_landmarks() -> void:
	if _landmarks_layer == null:
		return
	for c in _landmarks_layer.get_children():
		c.queue_free()
	for entry in LANDMARKS:
		var btn: Button = Button.new()
		btn.text = entry["icon"]
		btn.flat = true
		btn.add_theme_color_override(&"font_color", Color(0.95, 0.92, 0.78))
		btn.position = _world_to_canvas(entry["pos"]) - Vector2(12, 12)
		btn.custom_minimum_size = Vector2(24, 24)
		btn.tooltip_text = entry["name"]
		btn.mouse_entered.connect(_on_hover.bind(entry["name"], "Landmark"))
		btn.mouse_exited.connect(_on_hover_exit)
		_landmarks_layer.add_child(btn)


func _build_waypoints() -> void:
	if _waypoints_layer == null:
		return
	for c in _waypoints_layer.get_children():
		c.queue_free()
	for entry in WildernessWaypointDatabase.get_all():
		var wp_id: StringName = entry["id"]
		var btn: Button = Button.new()
		btn.flat = false
		var unlocked: bool = _is_waypoint_unlocked(wp_id)
		btn.text = "◉" if unlocked else "○"
		btn.add_theme_color_override(&"font_color",
			Color(0.45, 0.85, 1.00) if unlocked else Color(0.50, 0.50, 0.55))
		btn.position = _world_to_canvas(entry["world_position"]) - Vector2(14, 14)
		btn.custom_minimum_size = Vector2(28, 28)
		btn.tooltip_text = entry["display_name"]
		btn.disabled = not unlocked
		btn.mouse_entered.connect(_on_hover.bind(
			entry["display_name"],
			entry.get("description", "")
		))
		btn.mouse_exited.connect(_on_hover_exit)
		btn.pressed.connect(_on_waypoint_pressed.bind(wp_id))
		_waypoints_layer.add_child(btn)


func _build_entrances() -> void:
	if _entrances_layer == null:
		return
	for c in _entrances_layer.get_children():
		c.queue_free()
	for entry in DungeonEntranceDatabase.get_for_region(&"wild_cliffs"):
		var btn: Button = Button.new()
		btn.flat = false
		btn.text = "◆"
		btn.add_theme_color_override(&"font_color", entry.get("theme_color", Color.WHITE))
		var pos: Vector3 = entry.get("wilderness_position", Vector3.ZERO)
		btn.position = _world_to_canvas(pos) - Vector2(16, 16)
		btn.custom_minimum_size = Vector2(32, 32)
		var locked: bool = entry.get("locked_visible", false) and not _is_entrance_unlocked(entry)
		btn.tooltip_text = entry["display_name"] + (" (sealed)" if locked else "")
		btn.mouse_entered.connect(_on_hover.bind(
			entry["display_name"],
			entry.get("lore_plaque", "")
		))
		btn.mouse_exited.connect(_on_hover_exit)
		_entrances_layer.add_child(btn)


# === DRAW ===

func _draw_regions() -> void:
	if _regions_layer == null:
		return
	for region_id in REGION_POLYGONS.keys():
		var polygon: Array = REGION_POLYGONS[region_id]
		var pts: PackedVector2Array = PackedVector2Array()
		for v in polygon:
			pts.append(_world_to_canvas(v))
		var color: Color = REGION_COLORS.get(region_id, Color(0.5, 0.5, 0.5, 0.25))
		_regions_layer.draw_colored_polygon(pts, color)
		_regions_layer.draw_polyline(pts + PackedVector2Array([pts[0]]),
			Color(color.r, color.g, color.b, 0.85), 2.0)


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
	# Subtle pulse via modulate alpha
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


# === STATE QUERIES ===

func _is_waypoint_unlocked(waypoint_id: StringName) -> bool:
	if not has_node("/root/WildernessWaypointManager"):
		return false
	var wwm: Node = get_node("/root/WildernessWaypointManager")
	if wwm.has_method("is_unlocked"):
		return wwm.is_unlocked(waypoint_id)
	return false


func _is_entrance_unlocked(entry: Dictionary) -> bool:
	var unlock_iter: int = entry.get("unlock_iteration", 0)
	if unlock_iter <= 0:
		return true
	if not has_node("/root/IterationManager"):
		return false
	var im: Node = get_node("/root/IterationManager")
	if im.has_method("get_current_iteration"):
		return im.get_current_iteration() >= unlock_iter
	return false


# === HOVER + INTERACTION ===

func _on_hover(name_text: String, description: String) -> void:
	if _tooltip_panel == null:
		return
	if _tooltip_name != null:
		_tooltip_name.text = name_text
	if _tooltip_description != null:
		_tooltip_description.text = description
	_tooltip_panel.visible = true
	_tooltip_panel.position = get_global_mouse_position() + Vector2(16, 16)


func _on_hover_exit() -> void:
	if _tooltip_panel != null:
		_tooltip_panel.visible = false


func _on_waypoint_pressed(waypoint_id: StringName) -> void:
	fast_travel_requested.emit(waypoint_id)
	if has_node("/root/WildernessWaypointManager"):
		var wwm: Node = get_node("/root/WildernessWaypointManager")
		if wwm.has_method("travel_to"):
			wwm.travel_to(waypoint_id)
	_on_close_pressed()


func _on_close_pressed() -> void:
	map_closed.emit()
	visible = false


# === DISCOVERY COUNTER ===

func _update_discovery_counter() -> void:
	if _discovery_counter == null or not has_node("/root/WildernessWaypointManager"):
		return
	var wwm: Node = get_node("/root/WildernessWaypointManager")
	var unlocked: int = wwm.get_unlocked_count() if wwm.has_method("get_unlocked_count") else 0
	var total: int = wwm.get_total_count() if wwm.has_method("get_total_count") else WildernessWaypointDatabase.get_count()
	_discovery_counter.text = "%d / %d waypoints" % [unlocked, total]


func _on_waypoint_discovered(_waypoint_id: StringName) -> void:
	_build_waypoints()
	_update_discovery_counter()


# === INPUT (pan + zoom) ===

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var btn: InputEventMouseButton = event
		if btn.button_index == MOUSE_BUTTON_WHEEL_UP and btn.pressed:
			_set_zoom(_zoom + ZOOM_STEP)
			_rebuild_overlay_layers()
		elif btn.button_index == MOUSE_BUTTON_WHEEL_DOWN and btn.pressed:
			_set_zoom(_zoom - ZOOM_STEP)
			_rebuild_overlay_layers()
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
		_rebuild_overlay_layers()


func _set_zoom(z: float) -> void:
	_zoom = clampf(z, MIN_ZOOM, MAX_ZOOM)


func _rebuild_overlay_layers() -> void:
	if _regions_layer != null:
		_regions_layer.queue_redraw()
	_build_landmarks()
	_build_waypoints()
	_build_entrances()
