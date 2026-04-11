class_name DungeonLayout
extends RefCounted

## Graph data structure representing a generated dungeon floor. Each node is
## a placed room with its template, position, rotation, and connection IDs.

class RoomNode:
	var index: int
	var template: RoomTemplate
	var grid_position: Vector2i
	var rotation: int = 0  # 0-3 (90° increments)
	var mirrored: bool = false
	var connection_ids: Array[int] = []  ## indices of connected rooms
	var visited_by_player: bool = false


var rooms: Array[RoomNode] = []
var entry_room_index: int = -1
var boss_room_index: int = -1
var seed: int = 0
var biome: StringName = &""
var floor_number: int = 1


func add_room(template: RoomTemplate, grid_pos: Vector2i, rotation: int = 0, mirrored: bool = false) -> int:
	var node: RoomNode = RoomNode.new()
	node.index = rooms.size()
	node.template = template
	node.grid_position = grid_pos
	node.rotation = rotation
	node.mirrored = mirrored
	rooms.append(node)
	if template.has_tag(&"entry"):
		entry_room_index = node.index
	if template.has_tag(&"boss"):
		boss_room_index = node.index
	return node.index


func connect_rooms(a: int, b: int) -> void:
	if a < 0 or a >= rooms.size() or b < 0 or b >= rooms.size():
		return
	if not rooms[a].connection_ids.has(b):
		rooms[a].connection_ids.append(b)
	if not rooms[b].connection_ids.has(a):
		rooms[b].connection_ids.append(a)


func get_room(index: int) -> RoomNode:
	if index < 0 or index >= rooms.size():
		return null
	return rooms[index]


func find_rooms_with_tag(tag: StringName) -> Array[RoomNode]:
	var result: Array[RoomNode] = []
	for room in rooms:
		if room.template != null and room.template.has_tag(tag):
			result.append(room)
	return result


func count() -> int:
	return rooms.size()


func get_neighbors(room_index: int) -> Array[int]:
	var room: RoomNode = get_room(room_index)
	if room == null:
		return []
	return room.connection_ids
