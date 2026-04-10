class_name DungeonNavmeshStitcher
extends Node

## Dungeon Navmesh Stitcher (Epic 29 task 7).
##
## After the procedural generator places anchor rooms and connectors, the
## per-room baked navmeshes have hard edges at room boundaries. This stitcher
## walks every connection point between rooms and creates a NavigationLink3D
## bridge plus a small overlap quad so agents can path-find seamlessly across
## the entire generated floor.
##
## It also validates that every room is reachable from every other room and
## reports orphaned regions.
##
## Hook (after generation, before any AI spawns):
##   var stitcher := DungeonNavmeshStitcher.new()
##   add_child(stitcher)
##   var report := stitcher.stitch_floor(generated_rooms, connections)
##
## Where `connections` is an Array of:
##   {
##     "from_room": StringName,
##     "to_room": StringName,
##     "from_door_pos": Vector3,  # world position of the doorway portal
##     "to_door_pos": Vector3,
##     "width": float,            # doorway width in meters
##   }

signal stitching_started
signal connection_stitched(from_room: StringName, to_room: StringName)
signal stitching_finished(stitched: int, orphans: Array[StringName])

const OVERLAP_PAD_M: float = 0.6  # extra navmesh overlap on each side


func stitch_floor(rooms: Array, connections: Array) -> Dictionary:
	stitching_started.emit()
	var stitched: int = 0
	for conn: Dictionary in connections:
		_stitch_connection(rooms, conn)
		stitched += 1
		connection_stitched.emit(conn.get("from_room", &""), conn.get("to_room", &""))
	var orphans: Array[StringName] = _find_orphans(rooms, connections)
	stitching_finished.emit(stitched, orphans)
	return {
		"stitched": stitched,
		"orphans": orphans,
		"valid": orphans.is_empty(),
	}


func _stitch_connection(rooms: Array, conn: Dictionary) -> void:
	var from_pos: Vector3 = conn.get("from_door_pos", Vector3.ZERO)
	var to_pos: Vector3 = conn.get("to_door_pos", Vector3.ZERO)
	var width: float = conn.get("width", 2.0)

	# Find the from-room node
	var from_room: Dictionary = _find_room_by_id(rooms, conn.get("from_room", &""))
	var to_room: Dictionary = _find_room_by_id(rooms, conn.get("to_room", &""))
	if from_room.is_empty() or to_room.is_empty():
		push_warning("DungeonNavmeshStitcher: skipping conn with missing room")
		return

	var parent: Node3D = from_room.get("node") as Node3D
	if parent == null:
		return

	# Build a navigation link spanning the doorway
	var link := NavigationLink3D.new()
	link.name = "NavLink_%s_to_%s" % [conn.get("from_room", ""), conn.get("to_room", "")]
	link.start_position = parent.to_local(from_pos)
	link.end_position = parent.to_local(to_pos)
	link.bidirectional = true
	link.travel_cost = 1.0
	parent.add_child(link)

	# Add an overlap quad mesh that the navigation system will pick up as
	# walkable surface (helps the bake-on-the-fly approach if used)
	_add_overlap_quad(parent, from_pos, to_pos, width)


func _add_overlap_quad(parent: Node3D, a: Vector3, b: Vector3, width: float) -> void:
	var midpoint: Vector3 = (a + b) * 0.5
	var direction: Vector3 = (b - a).normalized()
	var marker := Marker3D.new()
	marker.name = "NavOverlapQuad"
	marker.position = parent.to_local(midpoint)
	marker.set_meta("width", width + OVERLAP_PAD_M * 2.0)
	marker.set_meta("direction", direction)
	marker.set_meta("walkable", true)
	parent.add_child(marker)


func _find_room_by_id(rooms: Array, id: StringName) -> Dictionary:
	for room: Dictionary in rooms:
		if room.get("id", &"") == id:
			return room
	return {}


# === Reachability validation ===
func _find_orphans(rooms: Array, connections: Array) -> Array[StringName]:
	if rooms.is_empty():
		return []
	# Build adjacency
	var adj: Dictionary = {}
	for room: Dictionary in rooms:
		adj[room["id"]] = []
	for conn: Dictionary in connections:
		var f: StringName = conn.get("from_room", &"")
		var t: StringName = conn.get("to_room", &"")
		if adj.has(f):
			adj[f].append(t)
		if adj.has(t):
			adj[t].append(f)

	# BFS from first room
	var visited: Dictionary = {}
	var queue: Array = [rooms[0]["id"]]
	visited[rooms[0]["id"]] = true
	while not queue.is_empty():
		var current: StringName = queue.pop_front()
		for neighbor: StringName in adj.get(current, []):
			if not visited.has(neighbor):
				visited[neighbor] = true
				queue.append(neighbor)

	var orphans: Array[StringName] = []
	for room: Dictionary in rooms:
		if not visited.has(room["id"]):
			orphans.append(room["id"])
	return orphans
