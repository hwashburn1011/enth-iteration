class_name FloorData
extends Resource
## Defines a dungeon floor as an ordered sequence of room scenes.

@export var floor_name: String = ""
@export var floor_number: int = 1
@export var room_sequence: Array[PackedScene] = []
