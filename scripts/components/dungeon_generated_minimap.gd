class_name DungeonGeneratedMinimap
extends Control

## Dungeon Generated Minimap (Epic 29 tasks 28, 29, 30, 31, 32).
##
## Builds and renders a minimap from the procedurally generated layout.
##  - Task 28: build_from_layout(rooms) — converts room polygons to a tile mask
##  - Task 29: hook_player_position(player_node) — tracks the player's room
##  - Task 30: reveal_at_position() — fog-of-war reveal as the player walks
##  - Task 31: room name labels rendered above each revealed room
##  - Task 32: room transition fades — smooth alpha pulse when entering a room
##
## Drawn entirely via the Control draw API so it ships with no textures.
## Each room becomes a polygon on a 1:1 → 6 px scale that can be panned.

signal room_entered_minimap(room_id: StringName)
signal area_revealed(room_id: StringName)

const TILE_SCALE: float = 6.0  # world meters → pixels
const FOG_COLOR: Color = Color(0.05, 0.06, 0.10, 0.95)
const REVEAL_RADIUS_M: float = 8.0
const TRANSITION_FADE_DURATION: float = 0.35

@export var minimap_size: Vector2 = Vector2(220, 220)
@export var background_color: Color = Color(0.08, 0.10, 0.18, 0.85)
@export var border_color: Color = Color(0.50, 0.55, 0.75, 0.9)

var _rooms: Array[Dictionary] = []
var _room_revealed: Dictionary = {}  # room_id → bool
var _player_node: Node3D
var _player_room_id: StringName = &""
var _previous_player_room_id: StringName = &""
var _transition_alpha: float = 1.0
var _world_to_minimap_offset: Vector2 = Vector2.ZERO
var _layout_centroid: Vector2 = Vector2.ZERO


func _ready() -> void:
	custom_minimum_size = minimap_size
	mouse_filter = MOUSE_FILTER_IGNORE
	set_process(true)


# === Task 28: build from generated layout ===
func build_from_layout(rooms: Array) -> void:
	_rooms.clear()
	_room_revealed.clear()
	var sum := Vector2.ZERO
	var count: int = 0
	for room: Dictionary in rooms:
		var data: Dictionary = {
			"id": room.get("id", &""),
			"tag": room.get("tag", &"combat"),
			"biome": room.get("biome", &""),
			"name": room.get("display_name", String(room.get("id", "Room"))),
			"polygon": room.get("floor_polygon", PackedVector2Array()),
			"world_position": room.get("world_position", Vector3.ZERO),
		}
		_rooms.append(data)
		_room_revealed[data["id"]] = false
		var poly: PackedVector2Array = data["polygon"]
		for p in poly:
			sum += p
			count += 1
	if count > 0:
		_layout_centroid = sum / float(count)
	_world_to_minimap_offset = minimap_size * 0.5 - _layout_centroid * TILE_SCALE
	queue_redraw()


# === Task 29: hook player position ===
func hook_player_position(player: Node3D) -> void:
	_player_node = player


func _process(delta: float) -> void:
	if _player_node == null:
		return
	var player_xz := Vector2(_player_node.global_position.x, _player_node.global_position.z)
	# Task 30: reveal nearby
	for room: Dictionary in _rooms:
		if _room_revealed[room["id"]]:
			continue
		var poly: PackedVector2Array = room["polygon"]
		if poly.is_empty():
			continue
		# Check if player is within reveal radius of polygon centroid
		var c := Vector2.ZERO
		for p in poly:
			c += p
		c /= float(poly.size())
		if c.distance_to(player_xz) <= REVEAL_RADIUS_M:
			_room_revealed[room["id"]] = true
			area_revealed.emit(room["id"])
			queue_redraw()

	# Track current room
	var new_room_id: StringName = _find_room_at(player_xz)
	if new_room_id != _player_room_id:
		_previous_player_room_id = _player_room_id
		_player_room_id = new_room_id
		if _player_room_id != &"":
			room_entered_minimap.emit(_player_room_id)
			# Task 32: trigger transition fade
			_transition_alpha = 0.0

	# Tween fade
	if _transition_alpha < 1.0:
		_transition_alpha = min(1.0, _transition_alpha + delta / TRANSITION_FADE_DURATION)
		queue_redraw()


func _find_room_at(player_xz: Vector2) -> StringName:
	for room: Dictionary in _rooms:
		var poly: PackedVector2Array = room["polygon"]
		if Geometry2D.is_point_in_polygon(player_xz, poly):
			return room["id"]
	return &""


# === Drawing ===
func _draw() -> void:
	# Background panel
	draw_rect(Rect0(), background_color)
	# Border
	draw_rect(Rect0(), border_color, false, 2.0)

	# Draw fog tile to cover the whole panel — we will overdraw rooms that are revealed
	# (drawn rooms cut through the fog)

	# Draw all revealed rooms
	for room: Dictionary in _rooms:
		if not _room_revealed[room["id"]]:
			continue
		_draw_room(room)

	# Draw a special highlight on current room
	if _player_room_id != &"":
		for room: Dictionary in _rooms:
			if room["id"] == _player_room_id:
				_draw_room_highlight(room)
				break

	# Draw player marker
	if _player_node != null:
		var player_xz := Vector2(_player_node.global_position.x, _player_node.global_position.z)
		var px: Vector2 = player_xz * TILE_SCALE + _world_to_minimap_offset
		if Rect0().has_point(px):
			draw_circle(px, 4.0, Color(1.0, 0.95, 0.4))
			draw_circle(px, 6.0, Color(1.0, 0.95, 0.4, 0.4))

	# Draw room labels above revealed rooms (Task 31)
	for room: Dictionary in _rooms:
		if not _room_revealed[room["id"]]:
			continue
		_draw_room_label(room)


func Rect0() -> Rect2:
	return Rect2(Vector2.ZERO, minimap_size)


func _draw_room(room: Dictionary) -> void:
	var poly: PackedVector2Array = room["polygon"]
	if poly.size() < 3:
		return
	var transformed := PackedVector2Array()
	for p in poly:
		transformed.append(p * TILE_SCALE + _world_to_minimap_offset)
	var color: Color = _room_color(room["tag"])
	if room["id"] == _player_room_id:
		color = color.lerp(Color(1.0, 0.95, 0.4), 1.0 - _transition_alpha)
	draw_colored_polygon(transformed, color)
	# Outline
	for i in range(transformed.size()):
		var a: Vector2 = transformed[i]
		var b: Vector2 = transformed[(i+1) % transformed.size()]
		draw_line(a, b, Color(0.7, 0.75, 0.85, 0.85), 1.5, true)


func _draw_room_highlight(room: Dictionary) -> void:
	var poly: PackedVector2Array = room["polygon"]
	if poly.size() < 3:
		return
	var transformed := PackedVector2Array()
	for p in poly:
		transformed.append(p * TILE_SCALE + _world_to_minimap_offset)
	# Pulsing outline
	var pulse: float = 0.5 + 0.5 * sin(Time.get_ticks_msec() / 250.0)
	for i in range(transformed.size()):
		var a: Vector2 = transformed[i]
		var b: Vector2 = transformed[(i+1) % transformed.size()]
		draw_line(a, b, Color(1.0, 0.95, 0.4, 0.4 + pulse * 0.5), 2.5, true)


func _draw_room_label(room: Dictionary) -> void:
	var poly: PackedVector2Array = room["polygon"]
	if poly.is_empty():
		return
	var c := Vector2.ZERO
	for p in poly:
		c += p
	c /= float(poly.size())
	var px: Vector2 = c * TILE_SCALE + _world_to_minimap_offset
	if not Rect0().has_point(px):
		return
	var font := ThemeDB.fallback_font
	if font != null:
		var label_text: String = String(room["name"])
		var text_size: Vector2 = font.get_string_size(label_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 10)
		draw_string(font, px - text_size * 0.5, label_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.95, 0.95, 1.0))


func _room_color(tag: StringName) -> Color:
	match tag:
		&"combat": return Color(0.40, 0.55, 0.65, 0.85)
		&"loot":   return Color(0.85, 0.70, 0.30, 0.85)
		&"story":  return Color(0.55, 0.65, 0.85, 0.85)
		&"secret": return Color(0.55, 0.40, 0.85, 0.85)
		&"elite":  return Color(0.85, 0.45, 0.30, 0.85)
		&"boss":   return Color(0.85, 0.25, 0.40, 0.85)
	return Color(0.50, 0.55, 0.65, 0.80)
