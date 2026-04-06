class_name RoomBase
extends Node3D
## Base template for all dungeon rooms. Handles cleared state and exit triggers.

signal room_cleared
signal player_at_exit

@export var room_type: String = "corridor"  # "combat", "loot", "corridor", "story"
@export var room_name: String = ""

var is_cleared: bool = false


func _ready() -> void:
	# Non-combat rooms are cleared by default
	if room_type != "combat":
		is_cleared = true

	var exit_trigger: Area3D = get_node_or_null("ExitTrigger") as Area3D
	if exit_trigger:
		exit_trigger.body_entered.connect(_on_exit_trigger_body_entered)


func _on_exit_trigger_body_entered(body: Node3D) -> void:
	if body.is_in_group(&"player") and is_cleared:
		player_at_exit.emit()


func _on_all_enemies_defeated() -> void:
	is_cleared = true
	room_cleared.emit()


func get_entry_point() -> Vector3:
	var marker: Marker3D = get_node_or_null("EntryPoint") as Marker3D
	if marker:
		return marker.global_position
	return global_position


func get_exit_point() -> Vector3:
	var marker: Marker3D = get_node_or_null("ExitPoint") as Marker3D
	if marker:
		return marker.global_position
	return global_position
