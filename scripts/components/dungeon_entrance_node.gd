class_name DungeonEntranceNode
extends Node3D

## Interactable dungeon entrance scene component. Player walks up to it,
## interact prompt appears, confirms biome selection, then triggers scene
## transition to the dungeon biome.

signal entrance_interacted
signal entrance_confirmed(entrance_id: StringName)

@export var entrance_id: StringName = &"server_room"
@export var interaction_radius: float = 2.5

var _player_in_range: bool = false


func _ready() -> void:
	add_to_group(&"interactable")
	add_to_group(&"dungeon_entrance")
	# Auto-discover when player gets close
	if has_node("/root/DungeonEntranceManager"):
		var dem: Node = get_node("/root/DungeonEntranceManager")
		dem.discover_entrance(entrance_id)


func interact(player: Node) -> void:
	entrance_interacted.emit()
	if has_node("/root/EventBus"):
		var bus: Node = get_node("/root/EventBus")
		if bus.has_signal("dungeon_entrance_interact"):
			bus.dungeon_entrance_interact.emit(entrance_id, self, player)


func confirm_entry(player: Node) -> void:
	entrance_confirmed.emit(entrance_id)
	# Get entrance data
	var entrance: Dictionary = DungeonEntranceDatabase.get_entrance(entrance_id)
	if entrance.is_empty():
		return
	# Trigger first-time cinematic if not seen
	var first_time_id: StringName = entrance.get("first_time_cinematic", &"")
	if first_time_id != &"":
		if has_node("/root/CutsceneController"):
			var cc: Node = get_node("/root/CutsceneController")
			if cc.has_method("has_seen") and not cc.has_seen(first_time_id):
				# Play cinematic before scene transition
				pass
	# Request scene transition
	if has_node("/root/EventBus"):
		var bus: Node = get_node("/root/EventBus")
		if bus.has_signal("scene_transition_requested"):
			bus.scene_transition_requested.emit(entrance.get("biome_id", &""))


func get_display_info() -> Dictionary:
	return DungeonEntranceDatabase.get_entrance(entrance_id)
