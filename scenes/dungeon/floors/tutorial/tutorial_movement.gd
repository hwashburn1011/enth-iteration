extends "res://scenes/dungeon/rooms/room_base.gd"
## Tutorial: walk to 3 markers to unlock exit.

var _markers_reached: int = 0
var _required: int = 3


func _ready() -> void:
	room_type = "corridor"
	is_cleared = false
	super._ready()
	TutorialManager.start_movement_tracking()

	# R5 round-28 fix: marker Visual meshes ship without any material so
	# they render as engine-default gray boxes in the tutorial. Apply a
	# pulsing cyan glow that doubles as a visual "walk here" indicator.
	# Found via the round-28 mesh health survey.
	var glow_mat: StandardMaterial3D = StandardMaterial3D.new()
	glow_mat.albedo_color = Color(0.2, 0.7, 0.85, 0.65)
	glow_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	glow_mat.emission_enabled = true
	glow_mat.emission = Color(0.3, 0.85, 1.0)
	glow_mat.emission_energy_multiplier = 2.5
	glow_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for child: Node in get_node("Markers").get_children():
		if child is Area3D:
			child.body_entered.connect(_on_marker_reached.bind(child))
		var visual := child.get_node_or_null("Visual") as MeshInstance3D
		if visual:
			visual.material_override = glow_mat
			# Pulse the marker so the player notices it
			var tween: Tween = visual.create_tween().set_loops()
			tween.tween_property(visual, "scale", Vector3(1.15, 1.15, 1.15), 0.7).set_ease(Tween.EASE_IN_OUT)
			tween.tween_property(visual, "scale", Vector3(0.95, 0.95, 0.95), 0.7).set_ease(Tween.EASE_IN_OUT)


func _on_marker_reached(body: Node3D, marker: Area3D) -> void:
	if not body.is_in_group(&"player"):
		return
	marker.queue_free()
	_markers_reached += 1
	if _markers_reached >= _required:
		is_cleared = true
		room_cleared.emit()
		_show_exit_indicator()
