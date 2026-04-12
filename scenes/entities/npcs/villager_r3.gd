extends "res://scenes/entities/npcs/npc_base.gd"
## Villager NPC. Loads its dialogue resource in _ready so the
## NPCBase._start_conversation guard doesn't bail on a null check
## the way it did before T36 — VillagerR3.tscn used to inherit
## NPCBase but never wired dialogue_resource, so pressing E
## silently did nothing.

func _ready() -> void:
	if dialogue_resource == null:
		dialogue_resource = load("res://data/dialogue/villager_greeting.tres") as Resource
	super._ready()
