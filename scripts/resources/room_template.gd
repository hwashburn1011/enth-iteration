class_name RoomTemplate
extends Resource

## Metadata for a hand-crafted room scene used by the dungeon generator.
## Each room has its scene path, tags, connection points, and biome.

@export var room_id: StringName = &""
@export var scene_path: String = ""
@export var biome: StringName = &""
@export var tags: Array[StringName] = []  ## combat / loot / story / secret / elite / boss / corridor / junction / entry / exit

## Connection points: 4 cardinal directions, true if the room has an opening.
@export var connection_north: bool = true
@export var connection_east: bool = true
@export var connection_south: bool = true
@export var connection_west: bool = true

## Footprint in grid cells (1 cell = 4 meters typically)
@export var footprint: Vector2i = Vector2i(1, 1)

## Tier restrictions — only generated on these floor tiers
@export var min_floor: int = 1
@export var max_floor: int = 99

## Per-room difficulty hint
@export var encounter_difficulty: int = 1

## Allowed rotations (in 90° increments)
@export var allowed_rotations: Array[int] = [0, 1, 2, 3]

## Mirror allowed?
@export var mirror_allowed: bool = true


func has_tag(tag: StringName) -> bool:
	return tags.has(tag)


func has_any_tag(tag_list: Array) -> bool:
	for t in tag_list:
		if tags.has(t):
			return true
	return false


func can_connect_direction(direction: int) -> bool:
	## direction: 0=N, 1=E, 2=S, 3=W
	match direction:
		0: return connection_north
		1: return connection_east
		2: return connection_south
		3: return connection_west
	return false


func is_eligible_for_floor(floor: int) -> bool:
	return floor >= min_floor and floor <= max_floor
