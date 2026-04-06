extends "res://scenes/dungeon/rooms/room_base.gd"
## Tutorial: open a container and pick up loot.


func _ready() -> void:
	room_type = "loot"
	is_cleared = true
	super._ready()
	TutorialManager.start_loot_hint()
