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
	# Add door model at exit
	_add_exit_door()
	# Show exit indicator if already cleared (corridors only — tutorials override is_cleared)
	if is_cleared and room_type == "corridor":
		_show_exit_indicator()
	# Ambient digital particles
	_add_ambient_particles()


func _on_exit_trigger_body_entered(body: Node3D) -> void:
	if body.is_in_group(&"player") and is_cleared:
		player_at_exit.emit()


func _on_all_enemies_defeated() -> void:
	is_cleared = true
	room_cleared.emit()
	_show_exit_indicator()


func _show_exit_indicator() -> void:
	var exit_point: Marker3D = get_node_or_null("ExitTrigger") as Marker3D
	if exit_point == null:
		# Try finding ExitPoint marker instead
		exit_point = get_node_or_null("ExitPoint") as Marker3D
	if exit_point == null:
		return
	# Glowing green beacon
	var beacon: MeshInstance3D = MeshInstance3D.new()
	var cyl: CylinderMesh = CylinderMesh.new()
	cyl.top_radius = 0.05
	cyl.bottom_radius = 0.3
	cyl.height = 3.0
	beacon.mesh = cyl
	beacon.position = Vector3(exit_point.position.x, 1.5, exit_point.position.z)
	var mat: StandardMaterial3D = StandardMaterial3D.new()
	mat.albedo_color = Color(0.1, 0.9, 0.3, 0.4)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.emission_enabled = true
	mat.emission = Color(0.1, 0.8, 0.25)
	mat.emission_energy_multiplier = 1.5
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	beacon.material_override = mat
	add_child(beacon)
	# Arrow label pointing down
	var arrow: Label3D = Label3D.new()
	arrow.text = "EXIT"
	arrow.font_size = 24
	arrow.modulate = Color(0.2, 1.0, 0.4)
	arrow.outline_modulate = Color(0, 0, 0)
	arrow.outline_size = 4
	arrow.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	arrow.position = Vector3(exit_point.position.x, 2.5, exit_point.position.z)
	add_child(arrow)
	# Point light
	var light: OmniLight3D = OmniLight3D.new()
	light.position = Vector3(exit_point.position.x, 1.0, exit_point.position.z)
	light.light_color = Color(0.1, 0.9, 0.3)
	light.light_energy = 1.5
	light.omni_range = 4.0
	add_child(light)


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
	# Room type accent strip on top of walls
	_add_room_type_accent(geom)
	# Add ceiling and pipes
	_add_ceiling(geom)
	# Add glowing edge strips to room for visibility
	_add_room_glow_strips(geom)


func _add_room_type_accent(geom: Node) -> void:
	# Colored accent strip at top of walls indicating room type
	var accent_color: Color
	match room_type:
		"combat":
			accent_color = Color(0.7, 0.1, 0.08)
		"loot":
			accent_color = Color(0.8, 0.65, 0.1)
		"story":
			accent_color = Color(0.1, 0.3, 0.7)
		_:
			accent_color = Color(0.15, 0.35, 0.45)  # Corridor/default

	var accent_mat: StandardMaterial3D = StandardMaterial3D.new()
	accent_mat.albedo_color = accent_color
	accent_mat.emission_enabled = true
	accent_mat.emission = accent_color * 0.8
	accent_mat.emission_energy_multiplier = 0.8
	accent_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED

	for child: Node in geom.get_children():
		if child is CSGBox3D and child.name.begins_with("Wall"):
			var wall: CSGBox3D = child as CSGBox3D
			var strip: CSGBox3D = CSGBox3D.new()
			# Strip at top of wall
			if wall.size.x > wall.size.z:
				strip.size = Vector3(wall.size.x, 0.08, wall.size.z + 0.02)
			else:
				strip.size = Vector3(wall.size.x + 0.02, 0.08, wall.size.z)
			strip.position = Vector3(0, wall.size.y / 2.0 - 0.04, 0)
			strip.material = accent_mat
			wall.add_child(strip)


func _add_ceiling(geom: Node) -> void:
	var floor_node: MeshInstance3D = geom.get_node_or_null("Floor") as MeshInstance3D
	if floor_node == null:
		return
	var plane: PlaneMesh = floor_node.mesh as PlaneMesh
	if plane == null:
		return
	# Dark ceiling plane
	var ceiling: MeshInstance3D = MeshInstance3D.new()
	var ceil_mesh: PlaneMesh = PlaneMesh.new()
	ceil_mesh.size = plane.size
	ceiling.mesh = ceil_mesh
	ceiling.position = Vector3(0, 3.2, 0)
	ceiling.rotation.x = PI  # Flip to face downward
	var ceil_mat: StandardMaterial3D = StandardMaterial3D.new()
	ceil_mat.albedo_color = Color(0.08, 0.09, 0.14)
	ceil_mat.roughness = 0.95
	ceiling.material_override = ceil_mat
	geom.add_child(ceiling)
	# Pipe runs along ceiling edges
	var pipe_mat: StandardMaterial3D = StandardMaterial3D.new()
	pipe_mat.albedo_color = Color(0.2, 0.22, 0.28)
	pipe_mat.roughness = 0.7
	pipe_mat.metallic = 0.4
	var half_x: float = plane.size.x / 2.0 - 0.5
	var half_z: float = plane.size.y / 2.0 - 0.5
	# Pipes along X edges at ceiling height
	for z_sign: float in [-1.0, 1.0]:
		var pipe: CSGBox3D = CSGBox3D.new()
		pipe.size = Vector3(plane.size.x - 1.0, 0.15, 0.15)
		pipe.position = Vector3(0, 2.9, z_sign * half_z)
		pipe.material = pipe_mat
		geom.add_child(pipe)
	# Pipes along Z edges
	for x_sign: float in [-1.0, 1.0]:
		var pipe: CSGBox3D = CSGBox3D.new()
		pipe.size = Vector3(0.15, 0.15, plane.size.y - 1.0)
		pipe.position = Vector3(x_sign * half_x, 2.9, 0)
		pipe.material = pipe_mat
		geom.add_child(pipe)
	# Ceiling light strips (subtle emission)
	var light_mat: StandardMaterial3D = StandardMaterial3D.new()
	light_mat.albedo_color = Color(0.15, 0.25, 0.35)
	light_mat.emission_enabled = true
	light_mat.emission = Color(0.1, 0.2, 0.3)
	light_mat.emission_energy_multiplier = 0.8
	for x_pos: float in [-half_x * 0.5, half_x * 0.5]:
		var strip: CSGBox3D = CSGBox3D.new()
		strip.size = Vector3(0.2, 0.05, plane.size.y - 2.0)
		strip.position = Vector3(x_pos, 3.15, 0)
		strip.material = light_mat
		geom.add_child(strip)


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
	# Glowing strip material — use floor accent color if available
	var accent: Color = GameManager.get_meta(&"floor_accent_color", Color(0.08, 0.35, 0.55)) as Color
	var glow_mat: StandardMaterial3D = StandardMaterial3D.new()
	glow_mat.albedo_color = accent
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


func _add_exit_door() -> void:
	var exit_trigger: Node3D = get_node_or_null("ExitTrigger") as Node3D
	if exit_trigger == null:
		exit_trigger = get_node_or_null("ExitPoint") as Node3D
	if exit_trigger == null:
		return
	var door_scene: PackedScene = load("res://assets/models/props/tech_door.glb") as PackedScene
	if door_scene:
		var door: Node3D = door_scene.instantiate() as Node3D
		add_child(door)
		door.position = exit_trigger.position
		# Face the door toward the room center
		var to_center: Vector3 = (Vector3.ZERO - exit_trigger.position).normalized()
		if to_center.length() > 0.1:
			door.rotation.y = atan2(to_center.x, to_center.z)


func _add_ambient_particles() -> void:
	var geom: Node = get_node_or_null("Geometry")
	if geom == null:
		return
	var floor_node: MeshInstance3D = geom.get_node_or_null("Floor") as MeshInstance3D
	if floor_node == null:
		return
	var plane: PlaneMesh = floor_node.mesh as PlaneMesh
	if plane == null:
		return

	var accent: Color = GameManager.get_meta(&"floor_accent_color", Color(0.08, 0.35, 0.55)) as Color
	var particles: GPUParticles3D = GPUParticles3D.new()
	particles.amount = 20
	particles.lifetime = 5.0
	particles.position = Vector3(0, 1.5, 0)
	particles.visibility_aabb = AABB(Vector3(-plane.size.x / 2, -1, -plane.size.y / 2), Vector3(plane.size.x, 4, plane.size.y))

	var mat: ParticleProcessMaterial = ParticleProcessMaterial.new()
	mat.direction = Vector3(0, 0.5, 0)
	mat.spread = 180.0
	mat.initial_velocity_min = 0.1
	mat.initial_velocity_max = 0.3
	mat.gravity = Vector3(0, 0.05, 0)
	mat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	mat.emission_box_extents = Vector3(plane.size.x / 2 - 1, 1, plane.size.y / 2 - 1)
	mat.color = Color(accent.r, accent.g, accent.b, 0.5)
	mat.scale_min = 0.3
	mat.scale_max = 1.0
	particles.process_material = mat

	var mesh: BoxMesh = BoxMesh.new()
	mesh.size = Vector3(0.04, 0.04, 0.04)
	particles.draw_pass_1 = mesh

	var vis_mat: StandardMaterial3D = StandardMaterial3D.new()
	vis_mat.albedo_color = Color(accent.r, accent.g, accent.b, 0.4)
	vis_mat.emission_enabled = true
	vis_mat.emission = accent
	vis_mat.emission_energy_multiplier = 1.5
	vis_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	vis_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	particles.material_override = vis_mat

	add_child(particles)


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

	# Wall pipe bundles on all room types
	var pipe_scene: PackedScene = load("res://assets/models/props/wall_pipes.glb") as PackedScene
	if pipe_scene:
		# Pipes along two walls
		for wall_side: int in [0, 1]:
			var pipes: Node3D = pipe_scene.instantiate() as Node3D
			pipes.scale = Vector3(1, 1, 1)
			geom.add_child(pipes)
			if wall_side == 0:
				pipes.position = Vector3(-half_x + 0.15, 0, 2.2)
				pipes.rotation.y = PI / 2.0
			else:
				pipes.position = Vector3(half_x - 0.15, 0, 2.2)
				pipes.rotation.y = -PI / 2.0

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

	# Loot room golden ambient glow
	if room_type == "loot":
		var gold_light: OmniLight3D = OmniLight3D.new()
		gold_light.position = Vector3(0, 2.0, 0)
		gold_light.light_color = Color(1.0, 0.85, 0.4)
		gold_light.light_energy = 1.2
		gold_light.omni_range = 8.0
		gold_light.omni_attenuation = 1.5
		geom.add_child(gold_light)

	# Data terminals (loot and story rooms)
	if room_type in ["loot", "story"]:
		var term_scene: PackedScene = load("res://assets/models/props/data_terminal.glb") as PackedScene
		if term_scene:
			var terminal: Node3D = term_scene.instantiate() as Node3D
			geom.add_child(terminal)
			terminal.position = Vector3(randf_range(-2, 2), 0, randf_range(-half_z * 0.3, half_z * 0.3))

	# Energy crystal decorations (scattered in some rooms)
	var crystal_scene: PackedScene = load("res://assets/models/props/energy_crystal.glb") as PackedScene
	if crystal_scene and room_type in ["combat", "corridor"]:
		for _i: int in randi_range(1, 3):
			var crystal: Node3D = crystal_scene.instantiate() as Node3D
			crystal.scale = Vector3(randf_range(0.6, 1.2), randf_range(0.6, 1.2), randf_range(0.6, 1.2))
			crystal.rotation.y = randf() * TAU
			geom.add_child(crystal)
			crystal.position = Vector3(
				randf_range(-half_x * 0.7, half_x * 0.7),
				0,
				randf_range(-half_z * 0.7, half_z * 0.7)
			)

	# Corner point lights for all rooms
	var floor_accent: Color = GameManager.get_meta(&"floor_accent_color", Color(0.08, 0.35, 0.55)) as Color
	var corner_color: Color = floor_accent if room_type != "combat" else Color(floor_accent.r + 0.2, floor_accent.g * 0.5, floor_accent.b * 0.5)
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
