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

	# Ensure floor has collision (visual PlaneMesh doesn't provide physics)
	_ensure_floor_collision()


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


func _ensure_floor_collision() -> void:
	# Check if there's already a StaticBody3D floor
	if find_child("FloorBody", true, false) != null:
		return
	# Find the floor mesh to match its size
	var floor_mesh: MeshInstance3D = null
	var geom: Node = get_node_or_null("Geometry")
	if geom:
		floor_mesh = geom.get_node_or_null("Floor") as MeshInstance3D
	if floor_mesh == null:
		return
	# Create a StaticBody3D with a flat collision box matching the floor
	var body: StaticBody3D = StaticBody3D.new()
	body.name = "FloorBody"
	var shape: CollisionShape3D = CollisionShape3D.new()
	var box: BoxShape3D = BoxShape3D.new()
	# PlaneMesh size is in X/Z — get it from the mesh
	var plane: PlaneMesh = floor_mesh.mesh as PlaneMesh
	if plane:
		box.size = Vector3(plane.size.x, 0.1, plane.size.y)
	else:
		box.size = Vector3(20.0, 0.1, 20.0)
	shape.shape = box
	shape.position = Vector3(0, -0.05, 0)
	body.add_child(shape)
	add_child(body)
