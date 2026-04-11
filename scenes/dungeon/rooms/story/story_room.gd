class_name StoryRoom
extends "res://scenes/dungeon/rooms/room_base.gd"
## Dungeon story room — contains an NPC that must be talked to before exit unlocks.

@export var npc_scene: PackedScene
@export var npc_id: StringName = &""

var has_interacted: bool = false
var _npc_instance: Node = null
var _dialogue_active: bool = false


func _ready() -> void:
	room_type = "story"
	is_cleared = false
	super._ready()

	# Instantiate NPC at spawn point
	if npc_scene:
		_npc_instance = npc_scene.instantiate()
		var spawn_point: Marker3D = get_node_or_null("NPCSpawnPoint") as Marker3D
		if spawn_point:
			add_child(_npc_instance)
			_npc_instance.global_position = spawn_point.global_position
		else:
			add_child(_npc_instance)

	# Track dialogue from this room's NPC specifically
	EventBus.dialogue_started.connect(_on_dialogue_started)
	EventBus.dialogue_ended.connect(_on_dialogue_ended)


func _on_dialogue_started(_started_npc_id: StringName) -> void:
	# Only track if this is our NPC's dialogue (or if npc_id matches)
	if not npc_id.is_empty() and _started_npc_id == npc_id:
		_dialogue_active = true
	elif npc_id.is_empty():
		# If no specific NPC ID set, accept any dialogue that starts while in this room
		_dialogue_active = true


func _on_dialogue_ended() -> void:
	if has_interacted or not _dialogue_active:
		return
	_dialogue_active = false
	has_interacted = true
	is_cleared = true
	room_cleared.emit()
	# Recruit NPC
	if not npc_id.is_empty():
		EventBus.npc_recruited.emit(npc_id)
