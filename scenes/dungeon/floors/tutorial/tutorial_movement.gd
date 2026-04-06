extends RoomBase
## Tutorial: walk to 3 markers to unlock exit.

var _markers_reached: int = 0
var _required: int = 3


func _ready() -> void:
	room_type = "corridor"
	is_cleared = false
	super._ready()
	TutorialManager.start_movement_tracking()

	for child: Node in get_node("Markers").get_children():
		if child is Area3D:
			child.body_entered.connect(_on_marker_reached.bind(child))


func _on_marker_reached(body: Node3D, marker: Area3D) -> void:
	if not body is Player:
		return
	marker.queue_free()
	_markers_reached += 1
	if _markers_reached >= _required:
		is_cleared = true
		room_cleared.emit()
