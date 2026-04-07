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
	# Apply tech-themed dungeon materials
	_apply_dungeon_materials()
	# Add tech props based on room type
	_add_dungeon_props()


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


func _apply_dungeon_materials() -> void:
	var geom: Node = get_node_or_null("Geometry")
	if geom == null:
		return
	# Dark tech floor with subtle grid emission
	var floor_node: MeshInstance3D = geom.get_node_or_null("Floor") as MeshInstance3D
	if floor_node:
		var floor_mat: StandardMaterial3D = StandardMaterial3D.new()
		floor_mat.albedo_color = Color(0.18, 0.20, 0.25)
		floor_mat.emission_enabled = true
		floor_mat.emission = Color(0.08, 0.12, 0.18)
		floor_mat.emission_energy_multiplier = 0.15
		floor_mat.roughness = 0.85
		floor_node.material_override = floor_mat
	# Dark walls with subtle blue/purple tint
	var wall_mat: StandardMaterial3D = StandardMaterial3D.new()
	wall_mat.albedo_color = Color(0.15, 0.16, 0.22)
	wall_mat.emission_enabled = true
	wall_mat.emission = Color(0.05, 0.08, 0.15)
	wall_mat.emission_energy_multiplier = 0.1
	wall_mat.roughness = 0.9
	for child: Node in geom.get_children():
		if child is CSGBox3D and child.name.begins_with("Wall"):
			(child as CSGBox3D).material = wall_mat
			(child as CSGBox3D).use_collision = true
	# Add glowing edge strips to room for visibility
	_add_room_glow_strips(geom)


func _add_room_glow_strips(geom: Node) -> void:
	# Find floor size for positioning
	var floor_node: MeshInstance3D = geom.get_node_or_null("Floor") as MeshInstance3D
	if floor_node == null:
		return
	var plane: PlaneMesh = floor_node.mesh as PlaneMesh
	if plane == null:
		return
	var half_x: float = plane.size.x / 2.0 - 0.3
	var half_z: float = plane.size.y / 2.0 - 0.3
	# Glowing strip material
	var glow_mat: StandardMaterial3D = StandardMaterial3D.new()
	glow_mat.albedo_color = Color(0.1, 0.4, 0.6)
	glow_mat.emission_enabled = true
	glow_mat.emission = Color(0.08, 0.35, 0.55)
	glow_mat.emission_energy_multiplier = 1.2
	# Floor edge strips
	var strip_data: Array = [
		[Vector3(0, 0.02, -half_z), Vector3(plane.size.x - 1.0, 0.04, 0.08)],
		[Vector3(0, 0.02, half_z), Vector3(plane.size.x - 1.0, 0.04, 0.08)],
		[Vector3(-half_x, 0.02, 0), Vector3(0.08, 0.04, plane.size.y - 1.0)],
		[Vector3(half_x, 0.02, 0), Vector3(0.08, 0.04, plane.size.y - 1.0)],
	]
	for data: Array in strip_data:
		var strip: CSGBox3D = CSGBox3D.new()
		strip.position = data[0] as Vector3
		strip.size = data[1] as Vector3
		strip.material = glow_mat
		geom.add_child(strip)


func _add_dungeon_props() -> void:
	var geom: Node = get_node_or_null("Geometry")
	if geom == null:
		return
	# Get floor size for prop placement
	var floor_node: MeshInstance3D = geom.get_node_or_null("Floor") as MeshInstance3D
	if floor_node == null:
		return
	var plane: PlaneMesh = floor_node.mesh as PlaneMesh
	if plane == null:
		return
	var half_x: float = plane.size.x / 2.0 - 1.5
	var half_z: float = plane.size.y / 2.0 - 1.5

	# Server racks along walls (combat and corridor rooms)
	if room_type in ["combat", "corridor"]:
		var rack_scene: PackedScene = load("res://assets/models/props/server_rack.glb") as PackedScene
		if rack_scene:
			for i: int in 2:
				var rack: Node3D = rack_scene.instantiate() as Node3D
				rack.scale = Vector3(0.8, 0.8, 0.8)
				geom.add_child(rack)
				if i == 0:
					rack.position = Vector3(-half_x, 0, randf_range(-half_z * 0.5, half_z * 0.5))
					rack.rotation.y = PI / 2.0
				else:
					rack.position = Vector3(half_x, 0, randf_range(-half_z * 0.5, half_z * 0.5))
					rack.rotation.y = -PI / 2.0

	# Data terminals (loot and story rooms)
	if room_type in ["loot", "story"]:
		var term_scene: PackedScene = load("res://assets/models/props/data_terminal.glb") as PackedScene
		if term_scene:
			var terminal: Node3D = term_scene.instantiate() as Node3D
			geom.add_child(terminal)
			terminal.position = Vector3(randf_range(-2, 2), 0, randf_range(-half_z * 0.3, half_z * 0.3))

	# Corner point lights for all rooms
	var corner_color: Color = Color(0.08, 0.3, 0.5) if room_type != "combat" else Color(0.5, 0.1, 0.08)
	for corner: Vector2 in [Vector2(-1, -1), Vector2(1, -1), Vector2(-1, 1), Vector2(1, 1)]:
		var light: OmniLight3D = OmniLight3D.new()
		light.position = Vector3(corner.x * (half_x - 0.5), 2.5, corner.y * (half_z - 0.5))
		light.light_color = corner_color
		light.light_energy = 0.4
		light.omni_range = 5.0
		light.omni_attenuation = 2.0
		geom.add_child(light)


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
