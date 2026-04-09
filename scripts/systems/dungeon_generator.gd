class_name DungeonGenerator
extends RefCounted

## Anchor + connector procedural dungeon generator. Picks required anchor
## rooms (entry, combat, loot, story, elite, boss, exit), arranges them
## in a graph, and weaves connector rooms to fill gaps. Validates the
## result and retries with a +1 seed if invalid.

signal floor_generated(layout: DungeonLayout)

const MAX_RETRIES: int = 5
const SECRET_ROOM_CHANCE: float = 0.10  ## 10% per layout (5% base + 5% from skill)

## Per-floor anchor requirements
const FLOOR_REQUIREMENTS: Dictionary = {
	1: {"entry": 1, "combat": 3, "loot": 1, "exit": 1},
	2: {"entry": 1, "combat": 4, "loot": 1, "story": 1, "exit": 1},
	3: {"entry": 1, "combat": 4, "elite": 1, "loot": 1, "exit": 1},
	4: {"entry": 1, "combat": 5, "elite": 1, "loot": 1, "story": 1, "exit": 1},
	5: {"entry": 1, "combat": 3, "boss": 1, "loot": 1, "exit": 1},
}


static func generate_floor(biome: StringName, floor_number: int, seed: int) -> DungeonLayout:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = seed

	for retry in MAX_RETRIES:
		var layout: DungeonLayout = _generate_attempt(biome, floor_number, rng)
		var validation: Dictionary = DungeonValidator.validate(layout)
		if validation["valid"]:
			return layout
		# Retry with new seed
		rng.seed = seed + retry + 1
		push_warning("Dungeon generation retry %d: %s" % [retry, validation["issues"]])

	# Fallback: return whatever we have
	push_warning("Dungeon generation failed after %d retries, returning best effort" % MAX_RETRIES)
	return _generate_attempt(biome, floor_number, rng)


static func _generate_attempt(biome: StringName, floor_number: int, rng: RandomNumberGenerator) -> DungeonLayout:
	var layout: DungeonLayout = DungeonLayout.new()
	layout.biome = biome
	layout.floor_number = floor_number
	layout.seed = rng.seed

	var requirements: Dictionary = FLOOR_REQUIREMENTS.get(floor_number, FLOOR_REQUIREMENTS[1])

	# Step 1: pick anchors
	var anchor_templates: Array[RoomTemplate] = _pick_anchors(biome, floor_number, requirements, rng)
	if anchor_templates.is_empty():
		return layout

	# Step 2: arrange anchors in a line graph
	_arrange_anchors_linear(layout, anchor_templates)

	# Step 3: weave connectors
	_weave_connectors(layout, biome, floor_number, rng)

	# Step 4: place secret room (chance roll)
	if rng.randf() < SECRET_ROOM_CHANCE:
		_place_secret_room(layout, biome, floor_number, rng)

	return layout


static func _pick_anchors(biome: StringName, floor_number: int, requirements: Dictionary, rng: RandomNumberGenerator) -> Array[RoomTemplate]:
	var anchors: Array[RoomTemplate] = []
	for tag: StringName in requirements.keys():
		var count: int = requirements[tag]
		for i in count:
			var template: RoomTemplate = RoomLibrary.get_random_template(biome, tag, floor_number, rng)
			if template != null:
				anchors.append(template)
	return anchors


static func _arrange_anchors_linear(layout: DungeonLayout, anchors: Array[RoomTemplate]) -> void:
	## Lay anchors out in a roughly linear path, entry first, boss/exit last.
	# Sort: entry first, boss/exit last, others in middle
	var sorted_anchors: Array[RoomTemplate] = []
	var entries: Array[RoomTemplate] = []
	var bosses_exits: Array[RoomTemplate] = []
	var middles: Array[RoomTemplate] = []
	for a in anchors:
		if a.has_tag(&"entry"):
			entries.append(a)
		elif a.has_any_tag([&"boss", &"exit"]):
			bosses_exits.append(a)
		else:
			middles.append(a)
	sorted_anchors.append_array(entries)
	sorted_anchors.append_array(middles)
	sorted_anchors.append_array(bosses_exits)

	# Place each anchor at incrementing grid positions and connect linearly
	var current_pos: Vector2i = Vector2i.ZERO
	var prev_index: int = -1
	for template in sorted_anchors:
		var idx: int = layout.add_room(template, current_pos)
		if prev_index >= 0:
			layout.connect_rooms(prev_index, idx)
		prev_index = idx
		current_pos.x += 2  # space rooms apart for connectors


static func _weave_connectors(layout: DungeonLayout, biome: StringName, floor_number: int, rng: RandomNumberGenerator) -> void:
	## Insert corridor rooms between anchors to add length variety.
	# For each anchor pair, optionally insert 0-2 corridor rooms
	var n: int = layout.count()
	if n < 2:
		return

	for i in range(n - 1):
		var insert_count: int = rng.randi_range(0, 2)
		for c in insert_count:
			var corridor: RoomTemplate = RoomLibrary.get_random_template(biome, &"corridor", floor_number, rng)
			if corridor == null:
				continue
			var pos: Vector2i = layout.get_room(i).grid_position + Vector2i(1, c)
			var corridor_idx: int = layout.add_room(corridor, pos)
			# Connect corridor between anchor i and anchor i+1
			# Note: simplified — real implementation would re-route the chain
			layout.connect_rooms(i, corridor_idx)


static func _place_secret_room(layout: DungeonLayout, biome: StringName, floor_number: int, rng: RandomNumberGenerator) -> void:
	var secret: RoomTemplate = RoomLibrary.get_random_template(biome, &"secret", floor_number, rng)
	if secret == null:
		return
	# Pick a random non-entry/non-boss room to attach the secret to
	var candidates: Array[int] = []
	for i in layout.count():
		var room: DungeonLayout.RoomNode = layout.get_room(i)
		if room.template != null and not room.template.has_any_tag([&"entry", &"boss", &"exit"]):
			candidates.append(i)
	if candidates.is_empty():
		return
	var anchor_idx: int = candidates[rng.randi() % candidates.size()]
	var pos: Vector2i = layout.get_room(anchor_idx).grid_position + Vector2i(0, 2)
	var secret_idx: int = layout.add_room(secret, pos)
	layout.connect_rooms(anchor_idx, secret_idx)


# === SAVE / LOAD ===

static func to_save_data(layout: DungeonLayout) -> Dictionary:
	var rooms_data: Array = []
	for room in layout.rooms:
		rooms_data.append({
			"index": room.index,
			"template_id": String(room.template.room_id) if room.template else "",
			"grid_x": room.grid_position.x,
			"grid_y": room.grid_position.y,
			"rotation": room.rotation,
			"mirrored": room.mirrored,
			"connections": room.connection_ids,
			"visited": room.visited_by_player,
		})
	return {
		"biome": String(layout.biome),
		"floor": layout.floor_number,
		"seed": layout.seed,
		"entry_index": layout.entry_room_index,
		"boss_index": layout.boss_room_index,
		"rooms": rooms_data,
	}


static func from_save_data(data: Dictionary) -> DungeonLayout:
	## Note: a real impl would re-resolve template references via RoomLibrary
	## using the stored template_id strings. This is a stub.
	var layout: DungeonLayout = DungeonLayout.new()
	layout.biome = StringName(data.get("biome", ""))
	layout.floor_number = data.get("floor", 1)
	layout.seed = data.get("seed", 0)
	layout.entry_room_index = data.get("entry_index", -1)
	layout.boss_room_index = data.get("boss_index", -1)
	# Real impl: walk rooms array and rebuild RoomNode objects
	return layout
