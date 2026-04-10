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
	# Combat room danger lighting
	_setup_danger_lighting()


func _on_exit_trigger_body_entered(body: Node3D) -> void:
	if body.is_in_group(&"player") and is_cleared:
		player_at_exit.emit()


func _on_all_enemies_defeated() -> void:
	is_cleared = true
	room_cleared.emit()
	_show_exit_indicator()
	_clear_danger_lighting()


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
	# Rising particles around beacon
	var exit_particles: GPUParticles3D = GPUParticles3D.new()
	exit_particles.amount = 20
	exit_particles.lifetime = 2.0
	exit_particles.position = Vector3(exit_point.position.x, 0.1, exit_point.position.z)
	var ep_mat: ParticleProcessMaterial = ParticleProcessMaterial.new()
	ep_mat.direction = Vector3(0, 1, 0)
	ep_mat.spread = 15.0
	ep_mat.initial_velocity_min = 0.5
	ep_mat.initial_velocity_max = 1.2
	ep_mat.gravity = Vector3.ZERO
	ep_mat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	ep_mat.emission_sphere_radius = 0.4
	ep_mat.color = Color(0.2, 1.0, 0.4, 0.7)
	ep_mat.scale_min = 0.3
	ep_mat.scale_max = 0.8
	exit_particles.process_material = ep_mat
	var ep_mesh: BoxMesh = BoxMesh.new()
	ep_mesh.size = Vector3(0.04, 0.04, 0.04)
	exit_particles.draw_pass_1 = ep_mesh
	var ep_vis: StandardMaterial3D = StandardMaterial3D.new()
	ep_vis.albedo_color = Color(0.2, 1.0, 0.4, 0.6)
	ep_vis.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	ep_vis.emission_enabled = true
	ep_vis.emission = Color(0.15, 0.8, 0.3)
	ep_vis.emission_energy_multiplier = 3.0
	ep_vis.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	exit_particles.material_override = ep_vis
	add_child(exit_particles)


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
	# Procedurally textured tech floor — noise-based panels with normal map
	var floor_node: MeshInstance3D = geom.get_node_or_null("Floor") as MeshInstance3D
	if floor_node:
		floor_node.material_override = _make_floor_material()
	# Procedurally textured walls with brushed-metal noise + normal map.
	# Apply to Wall*, Pillar*, and any other unmaterialized CSGBox3D so the
	# boss arena pillars and other structural elements get the texture too.
	var wall_mat: StandardMaterial3D = _make_wall_material()
	for child: Node in geom.get_children():
		if child is CSGBox3D and (child.name.begins_with("Wall") or child.name.begins_with("Pillar")):
			(child as CSGBox3D).material = wall_mat
			(child as CSGBox3D).use_collision = true
	# Room type accent strip on top of walls
	_add_room_type_accent(geom)
	# Add ceiling and pipes
	_add_ceiling(geom)
	# Add glowing edge strips to room for visibility
	_add_room_glow_strips(geom)


static func _make_floor_material() -> StandardMaterial3D:
	## Real Polyhaven CC0 cobblestone_floor_04 PBR (R3-29: replaces the previous
	## procedural cellular sci-fi floor — now uses photoscanned diffuse +
	## normal_gl + roughness, with ambient cyan emission preserved for that
	## "dungeon glow under your feet" mood).
	var mat: StandardMaterial3D = StandardMaterial3D.new()
	var diff: Texture2D = load("res://assets/textures/polyhaven/cobblestone_floor_04_diff_1k.png") as Texture2D
	var nor: Texture2D = load("res://assets/textures/polyhaven/cobblestone_floor_04_nor_gl_1k.png") as Texture2D
	var rough: Texture2D = load("res://assets/textures/polyhaven/cobblestone_floor_04_rough_1k.png") as Texture2D
	if diff:
		mat.albedo_texture = diff
	if nor:
		mat.normal_enabled = true
		mat.normal_texture = nor
		mat.normal_scale = 1.6
	if rough:
		mat.roughness_texture = rough
		mat.roughness_texture_channel = BaseMaterial3D.TEXTURE_CHANNEL_RED
	mat.albedo_color = Color(1, 1, 1)
	mat.metallic = 0.0
	mat.uv1_triplanar = true
	mat.uv1_scale = Vector3(0.4, 0.4, 0.4)
	# Subtle cyan ambient emission so the floor reads even in dim rooms
	mat.emission_enabled = true
	mat.emission = Color(0.06, 0.10, 0.18)
	mat.emission_energy_multiplier = 0.12
	return mat


static func _build_floor_ramp() -> Gradient:
	## More dramatic gradient — brighter highs, visible cell seams.
	var g: Gradient = Gradient.new()
	g.set_color(0, Color(0.12, 0.16, 0.22))
	g.set_color(1, Color(0.55, 0.66, 0.82))
	g.add_point(0.35, Color(0.20, 0.26, 0.36))
	g.add_point(0.65, Color(0.34, 0.44, 0.58))
	g.add_point(0.92, Color(0.48, 0.60, 0.78))
	return g


static func _make_wall_material() -> StandardMaterial3D:
	## Real Polyhaven CC0 castle_brick_07 PBR (R3-29: replaces the previous
	## procedural Perlin streak + cellular bump). Subtle blue emission preserved.
	var mat: StandardMaterial3D = StandardMaterial3D.new()
	var diff: Texture2D = load("res://assets/textures/polyhaven/castle_brick_07_diff_1k.png") as Texture2D
	var nor: Texture2D = load("res://assets/textures/polyhaven/castle_brick_07_nor_gl_1k.png") as Texture2D
	var rough: Texture2D = load("res://assets/textures/polyhaven/castle_brick_07_rough_1k.png") as Texture2D
	if diff:
		mat.albedo_texture = diff
	if nor:
		mat.normal_enabled = true
		mat.normal_texture = nor
		mat.normal_scale = 1.4
	if rough:
		mat.roughness_texture = rough
		mat.roughness_texture_channel = BaseMaterial3D.TEXTURE_CHANNEL_RED
	mat.albedo_color = Color(1, 1, 1)
	mat.metallic = 0.0
	mat.uv1_triplanar = true
	mat.uv1_scale = Vector3(0.5, 0.5, 0.5)
	mat.emission_enabled = true
	mat.emission = Color(0.04, 0.07, 0.13)
	mat.emission_energy_multiplier = 0.08
	return mat


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
	# Procedurally textured ceiling — same panel grid as floor but darker
	var ceiling: MeshInstance3D = MeshInstance3D.new()
	var ceil_mesh: PlaneMesh = PlaneMesh.new()
	ceil_mesh.size = plane.size
	ceiling.mesh = ceil_mesh
	ceiling.position = Vector3(0, 3.2, 0)
	ceiling.rotation.x = PI  # Flip to face downward
	ceiling.material_override = _make_ceiling_material()
	geom.add_child(ceiling)
	# Pipe runs along ceiling edges — share the brushed metal prop material
	var pipe_mat: StandardMaterial3D = _make_tech_prop_material()
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
		# Apply brushed metal texture to the door body (preserve any glow)
		_apply_prop_texture(door, _make_tech_prop_material())


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

	# Ground fog layer for depth
	var fog: GPUParticles3D = GPUParticles3D.new()
	fog.amount = 30
	fog.lifetime = 8.0
	fog.position = Vector3(0, 0.15, 0)
	fog.visibility_aabb = AABB(Vector3(-plane.size.x / 2, -0.5, -plane.size.y / 2), Vector3(plane.size.x, 1.5, plane.size.y))
	var fog_mat: ParticleProcessMaterial = ParticleProcessMaterial.new()
	fog_mat.direction = Vector3(1, 0.1, 0)
	fog_mat.spread = 180.0
	fog_mat.initial_velocity_min = 0.05
	fog_mat.initial_velocity_max = 0.15
	fog_mat.gravity = Vector3.ZERO
	fog_mat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	fog_mat.emission_box_extents = Vector3(plane.size.x / 2 - 0.5, 0.1, plane.size.y / 2 - 0.5)
	fog_mat.color = Color(0.15, 0.2, 0.3, 0.08)
	fog_mat.scale_min = 2.0
	fog_mat.scale_max = 4.0
	fog.process_material = fog_mat
	var fog_mesh: SphereMesh = SphereMesh.new()
	fog_mesh.radius = 0.5
	fog_mesh.height = 0.3
	fog.draw_pass_1 = fog_mesh
	var fog_vis: StandardMaterial3D = StandardMaterial3D.new()
	fog_vis.albedo_color = Color(0.1, 0.15, 0.25, 0.06)
	fog_vis.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	fog_vis.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	fog.material_override = fog_vis
	add_child(fog)

	# Flickering accent lights in corners
	var fog_half_x: float = plane.size.x / 2.0 - 1.5
	var fog_half_z: float = plane.size.y / 2.0 - 1.5
	for corner_x: float in [-fog_half_x + 1.0, fog_half_x - 1.0]:
		for corner_z: float in [-fog_half_z + 1.0, fog_half_z - 1.0]:
			var point_light: OmniLight3D = OmniLight3D.new()
			point_light.position = Vector3(corner_x, 1.5, corner_z)
			point_light.light_color = accent
			point_light.light_energy = 0.6
			point_light.omni_range = 3.5
			point_light.omni_attenuation = 1.8
			add_child(point_light)


var _danger_light: OmniLight3D = null


func _setup_danger_lighting() -> void:
	## Red-tinted center light for active combat rooms
	if room_type != "combat" or is_cleared:
		return
	_danger_light = OmniLight3D.new()
	_danger_light.position = Vector3(0, 2.5, 0)
	_danger_light.light_color = Color(0.8, 0.15, 0.1)
	_danger_light.light_energy = 0.0
	_danger_light.omni_range = 10.0
	_danger_light.omni_attenuation = 1.5
	add_child(_danger_light)
	# Fade in danger light
	var tween: Tween = _danger_light.create_tween()
	tween.tween_property(_danger_light, "light_energy", 0.5, 1.0)


func _clear_danger_lighting() -> void:
	if _danger_light == null or not is_instance_valid(_danger_light):
		return
	var tween: Tween = _danger_light.create_tween()
	tween.tween_property(_danger_light, "light_energy", 0.0, 0.8)
	tween.tween_callback(_danger_light.queue_free)
	_danger_light = null


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

	# Shared sci-fi metal material for tech props (server racks, pipes, terminals)
	var prop_mat: StandardMaterial3D = _make_tech_prop_material()

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
			_apply_prop_texture(pipes, prop_mat)

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
				_apply_prop_texture(rack, prop_mat)

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
			_apply_prop_texture(terminal, prop_mat)

	# Glowing mushroom clusters (corridors and story rooms) — keep their
	# original glowing materials, only re-tint the stems
	var mushroom_scene: PackedScene = load("res://assets/models/props/mushroom_cluster.glb") as PackedScene
	if mushroom_scene and room_type in ["corridor", "story", "loot"]:
		for _i: int in randi_range(1, 2):
			var mushroom: Node3D = mushroom_scene.instantiate() as Node3D
			mushroom.scale = Vector3(randf_range(1.0, 2.0), randf_range(1.0, 2.0), randf_range(1.0, 2.0))
			mushroom.rotation.y = randf() * TAU
			geom.add_child(mushroom)
			mushroom.position = Vector3(
				randf_range(-half_x * 0.8, half_x * 0.8),
				0,
				randf_range(-half_z * 0.8, half_z * 0.8)
			)
			# Skip texture override on mushrooms — they're meant to glow

	# Energy crystal decorations (scattered in some rooms) — keep glow
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
			# Skip texture override on crystals — they're meant to glow

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


func _apply_prop_texture(root: Node, prop_mat: StandardMaterial3D) -> void:
	## Apply the shared brushed-metal prop material to every mesh in a prop
	## GLB tree, EXCEPT meshes that look like glowing accents (cyan/red emit
	## colors that should keep their original glowing material).
	var stack: Array = [root]
	while not stack.is_empty():
		var n: Node = stack.pop_back()
		if n is MeshInstance3D:
			var mi: MeshInstance3D = n as MeshInstance3D
			var existing: Material = mi.get_active_material(0)
			var keep_glow: bool = false
			if existing is StandardMaterial3D:
				var sm: StandardMaterial3D = existing as StandardMaterial3D
				if sm.emission_enabled and sm.emission_energy_multiplier > 0.5:
					keep_glow = true
			if not keep_glow:
				mi.material_override = prop_mat
		for c in n.get_children():
			stack.append(c)


static func _make_ceiling_material() -> StandardMaterial3D:
	## Real Polyhaven CC0 metal_plate PBR (R3-29: replaces the previous procedural
	## cellular panel grid). Tinted darker via uv1_scale + base color so the
	## ceiling reads as panels but doesn't compete with the floor visually.
	var mat: StandardMaterial3D = StandardMaterial3D.new()
	var diff: Texture2D = load("res://assets/textures/polyhaven/metal_plate_diff_1k.png") as Texture2D
	var nor: Texture2D = load("res://assets/textures/polyhaven/metal_plate_nor_gl_1k.png") as Texture2D
	var rough: Texture2D = load("res://assets/textures/polyhaven/metal_plate_rough_1k.png") as Texture2D
	var metal: Texture2D = load("res://assets/textures/polyhaven/metal_plate_metal_1k.png") as Texture2D
	if diff:
		mat.albedo_texture = diff
	if nor:
		mat.normal_enabled = true
		mat.normal_texture = nor
		mat.normal_scale = 1.2
	if rough:
		mat.roughness_texture = rough
		mat.roughness_texture_channel = BaseMaterial3D.TEXTURE_CHANNEL_RED
	if metal:
		mat.metallic_texture = metal
		mat.metallic_texture_channel = BaseMaterial3D.TEXTURE_CHANNEL_RED
		mat.metallic = 1.0
	mat.albedo_color = Color(0.6, 0.65, 0.75)  # tint cooler for ceiling reads
	mat.uv1_triplanar = true
	mat.uv1_scale = Vector3(0.5, 0.5, 0.5)
	return mat


static func _make_tech_prop_material() -> StandardMaterial3D:
	## Real Polyhaven CC0 metal_plate PBR (R3-29: replaces the previous procedural
	## brushed-metal). Used for server racks, pipes, terminals, doors.
	var mat: StandardMaterial3D = StandardMaterial3D.new()
	var diff: Texture2D = load("res://assets/textures/polyhaven/metal_plate_diff_1k.png") as Texture2D
	var nor: Texture2D = load("res://assets/textures/polyhaven/metal_plate_nor_gl_1k.png") as Texture2D
	var rough: Texture2D = load("res://assets/textures/polyhaven/metal_plate_rough_1k.png") as Texture2D
	var metal: Texture2D = load("res://assets/textures/polyhaven/metal_plate_metal_1k.png") as Texture2D
	if diff:
		mat.albedo_texture = diff
	if nor:
		mat.normal_enabled = true
		mat.normal_texture = nor
		mat.normal_scale = 1.0
	if rough:
		mat.roughness_texture = rough
		mat.roughness_texture_channel = BaseMaterial3D.TEXTURE_CHANNEL_RED
	if metal:
		mat.metallic_texture = metal
		mat.metallic_texture_channel = BaseMaterial3D.TEXTURE_CHANNEL_RED
		mat.metallic = 1.0
	mat.albedo_color = Color(1, 1, 1)
	mat.uv1_triplanar = true
	mat.uv1_scale = Vector3(0.8, 0.8, 0.8)
	return mat
