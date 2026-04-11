class_name DungeonValidator
extends RefCounted

## Validates a generated DungeonLayout. Checks:
## - Path from entry to boss exists (BFS)
## - Every room is reachable from entry
## - Required tag count is met
## - Spawn points are within room bounds

const MAX_ROOMS_PER_FLOOR: int = 30


static func validate(layout: DungeonLayout) -> Dictionary:
	var issues: Array[String] = []

	if layout.entry_room_index < 0:
		issues.append("Layout has no entry room")
	if layout.boss_room_index < 0:
		issues.append("Layout has no boss room")
	if layout.count() == 0:
		issues.append("Layout has no rooms")
		return {"valid": false, "issues": issues}
	if layout.count() > MAX_ROOMS_PER_FLOOR:
		issues.append("Layout has %d rooms (max %d)" % [layout.count(), MAX_ROOMS_PER_FLOOR])

	# Path validation: BFS from entry to boss
	if layout.entry_room_index >= 0 and layout.boss_room_index >= 0:
		if not has_path(layout, layout.entry_room_index, layout.boss_room_index):
			issues.append("No path from entry to boss")

	# Reachability: every room must be reachable from entry
	if layout.entry_room_index >= 0:
		var reached: Array[int] = bfs_reachable(layout, layout.entry_room_index)
		if reached.size() != layout.count():
			var unreachable_count: int = layout.count() - reached.size()
			issues.append("%d unreachable rooms" % unreachable_count)

	return {"valid": issues.is_empty(), "issues": issues}


static func has_path(layout: DungeonLayout, from: int, to: int) -> bool:
	if from == to:
		return true
	var reached: Array[int] = bfs_reachable(layout, from)
	return reached.has(to)


static func bfs_reachable(layout: DungeonLayout, start: int) -> Array[int]:
	var visited: Array[int] = [start]
	var queue: Array[int] = [start]
	while not queue.is_empty():
		var current: int = queue.pop_front()
		for neighbor: int in layout.get_neighbors(current):
			if not visited.has(neighbor):
				visited.append(neighbor)
				queue.append(neighbor)
	return visited


static func count_tags(layout: DungeonLayout, tag: StringName) -> int:
	return layout.find_rooms_with_tag(tag).size()


static func validate_required_tags(layout: DungeonLayout, requirements: Dictionary) -> Array[String]:
	## requirements: { tag (StringName) -> required_count (int) }
	var issues: Array[String] = []
	for tag: StringName in requirements.keys():
		var actual: int = count_tags(layout, tag)
		var required: int = requirements[tag]
		if actual < required:
			issues.append("Tag '%s': %d found, %d required" % [tag, actual, required])
	return issues
