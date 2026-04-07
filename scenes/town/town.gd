extends Node3D
## Town hub — persistent home base with NPC slots and spawn points.

const NPC_SCENES: Dictionary = {
	"ai_sage": "res://scenes/entities/npcs/AISageTown.tscn",
	"cache_sprite": "res://scenes/entities/npcs/CacheSprite.tscn",
}

## NPCs that are always present in town (no recruitment needed)
const ALWAYS_PRESENT: Array[String] = ["ai_sage"]

@onready var player_spawn_point: Marker3D = %PlayerSpawnPoint
@onready var portal_return_point: Marker3D = %PortalReturnPoint
@onready var npc_slots: Node3D = %NPCSlots


func _ready() -> void:
	portal_return_point.add_to_group(&"portal_return_point")
	player_spawn_point.add_to_group(&"respawn_point")

	# --- Lighting and Environment ---
	_setup_environment()

	# Spawn HUD
	var hud_scene: PackedScene = load("res://scenes/ui/hud/HUD.tscn") as PackedScene
	if hud_scene:
		add_child(hud_scene.instantiate())

	# Spawn player
	var player_scene: PackedScene = load("res://scenes/entities/player/Player.tscn") as PackedScene
	var player_node: CharacterBody3D = null
	if player_scene:
		player_node = player_scene.instantiate() as CharacterBody3D
		add_child(player_node)

		# Determine spawn position based on entry type
		if GameManager.has_meta(&"town_entry_type") and GameManager.get_meta(&"town_entry_type") == "portal_return":
			player_node.global_position = portal_return_point.global_position
			GameManager.remove_meta(&"town_entry_type")
			# Reset health/compute after dungeon return
			player_node.health_component.reset()
			player_node.compute_component.reset()
		else:
			player_node.global_position = player_spawn_point.global_position

	# Spawn isometric camera targeting player
	var cam_script: GDScript = load("res://scripts/components/isometric_camera.gd") as GDScript
	var camera: Camera3D = Camera3D.new()
	camera.set_script(cam_script)
	if player_node:
		camera.set(&"target", player_node)
	add_child(camera)

	GameManager.set_state(GameManager.GameState.PLAYING)
	_build_town_decorations()
	_populate_npcs()
	_update_town_state()

	# Narrative: demo end check after returning from boss
	if GameManager.should_trigger_demo_end():
		_setup_demo_end_trigger()
	# Narrative: auto-trigger AI Sage on first visit — delay 5s so player sees the world
	elif GameManager.first_run and not GameManager.first_sage_dialogue_complete:
		_auto_trigger_sage_dialogue.call_deferred()


func _populate_npcs() -> void:
	for npc_id: String in NPC_SCENES:
		var should_spawn: bool = npc_id in ALWAYS_PRESENT
		if not should_spawn and GameManager.is_npc_recruited(npc_id):
			should_spawn = true
		if not should_spawn:
			continue
		var slot: Marker3D = _get_npc_slot(npc_id)
		if slot == null:
			continue
		var scene: PackedScene = load(NPC_SCENES[npc_id]) as PackedScene
		if scene:
			var npc: Node3D = scene.instantiate() as Node3D
			npc.global_position = slot.global_position
			add_child(npc)
			# Trigger arrival dialogue for newly recruited NPCs
			if GameManager.is_npc_newly_arrived(npc_id) and npc.has_method(&"_start_conversation"):
				var arrival_data: Resource = _get_arrival_dialogue(npc_id)
				if arrival_data:
					npc.set(&"dialogue_resource", arrival_data)
				GameManager.acknowledge_npc_arrival(npc_id)
				# Trigger arrival dialogue after a delay
				_trigger_arrival_dialogue.call_deferred(npc)


func _get_arrival_dialogue(npc_id: String) -> Resource:
	var path: String = "res://data/dialogue/%s_arrival.tres" % npc_id
	if ResourceLoader.exists(path):
		return load(path) as Resource
	return null


func _get_npc_slot(npc_id: String) -> Marker3D:
	match npc_id:
		"ai_sage":
			return npc_slots.get_node_or_null("AISageSlot") as Marker3D
		"cache_sprite":
			return npc_slots.get_node_or_null("CacheSpriteSlot") as Marker3D
		_:
			return npc_slots.get_node_or_null(npc_id + "_slot") as Marker3D


func _update_town_state() -> void:
	var npc_count: int = GameManager.recruited_npcs.size()
	var expansion1: Node3D = get_node_or_null("TownExpansion1") as Node3D
	var expansion2: Node3D = get_node_or_null("TownExpansion2") as Node3D
	var expansion3: Node3D = get_node_or_null("TownExpansion3") as Node3D
	if expansion1:
		expansion1.visible = npc_count >= 1
	if expansion2:
		expansion2.visible = npc_count >= 2
	if expansion3:
		expansion3.visible = npc_count >= 3


func _trigger_arrival_dialogue(npc: Node3D) -> void:
	await get_tree().create_timer(2.0).timeout
	if npc and is_instance_valid(npc) and npc.has_method(&"_start_conversation"):
		npc._start_conversation()


func _auto_trigger_sage_dialogue() -> void:
	# Wait 5 seconds so player can see the world first
	await get_tree().create_timer(5.0).timeout
	if not is_instance_valid(self):
		return
	for child: Node in get_children():
		if child.has_method(&"_start_conversation") and child.get(&"npc_id") == "ai_sage":
			child._start_conversation()
			return


func _build_town_decorations() -> void:
	var geom: Node3D = get_node_or_null("Geometry") as Node3D
	if geom == null:
		return

	# --- Boundary collision ---
	_add_boundary_collision()

	# --- Dirt paths ---
	_add_path(geom, Vector3(0, 0.01, 0), Vector3(3, 0.02, 30))
	_add_path(geom, Vector3(0, 0.01, 0), Vector3(24, 0.02, 3))
	_add_path(geom, Vector3(0, 0.01, -10), Vector3(3, 0.02, 12))

	# --- Rooftops on buildings + collision ---
	for i: int in range(1, 5):
		var building: CSGBox3D = geom.get_node_or_null("Building%d" % i) as CSGBox3D
		if building:
			building.use_collision = true
			_add_roof(building)

	# --- Trees ---
	_add_tree(geom, Vector3(-15, 0, 3), 1.5, 2.4)
	_add_tree(geom, Vector3(14, 0, 6), 1.3, 2.0)
	_add_tree(geom, Vector3(-4, 0, 14), 1.8, 3.0)
	_add_tree(geom, Vector3(16, 0, -12), 1.2, 2.0)
	_add_tree(geom, Vector3(-16, 0, -14), 1.4, 2.2)
	_add_tree(geom, Vector3(6, 0, 16), 1.1, 1.8)

	# --- Lanterns with point lights ---
	_add_lantern(geom, Vector3(-3, 0, 2))
	_add_lantern(geom, Vector3(3, 0, -4))
	_add_lantern(geom, Vector3(-6, 0, -10))
	_add_lantern(geom, Vector3(7, 0, 8))

	# --- Fences ---
	_add_fence(geom, Vector3(-14, 0.4, -3), Vector3(0.15, 0.8, 6))
	_add_fence(geom, Vector3(14, 0.4, 5), Vector3(0.15, 0.8, 8))
	_add_fence(geom, Vector3(5, 0.4, 14), Vector3(6, 0.8, 0.15))


func _add_path(parent: Node3D, pos: Vector3, size: Vector3) -> void:
	var path: CSGBox3D = CSGBox3D.new()
	path.size = size
	path.position = pos
	var mat: StandardMaterial3D = StandardMaterial3D.new()
	mat.albedo_color = Color(0.65, 0.58, 0.48)
	mat.roughness = 0.95
	path.material = mat
	parent.add_child(path)


func _add_roof(building: CSGBox3D) -> void:
	var roof: CSGBox3D = CSGBox3D.new()
	roof.size = Vector3(building.size.x + 0.6, 0.6, building.size.z + 0.6)
	roof.position = Vector3(0, building.size.y / 2.0 + 0.3, 0)
	var mat: StandardMaterial3D = StandardMaterial3D.new()
	mat.albedo_color = Color(0.65, 0.30, 0.22)
	mat.roughness = 0.8
	roof.material = mat
	building.add_child(roof)
	# Peak
	var peak: CSGBox3D = CSGBox3D.new()
	peak.size = Vector3(building.size.x - 1.0, 0.4, building.size.z - 1.0)
	peak.position = Vector3(0, building.size.y / 2.0 + 0.8, 0)
	peak.material = mat
	building.add_child(peak)


func _add_tree(parent: Node3D, pos: Vector3, canopy_radius: float, trunk_height: float) -> void:
	# Try to use Blender-made model, fall back to CSG
	var tree_scene: PackedScene = load("res://assets/models/props/tree_01.glb") as PackedScene
	if tree_scene:
		var tree: Node3D = tree_scene.instantiate() as Node3D
		var scale_factor: float = canopy_radius / 1.3  # Base model has radius 1.3
		tree.scale = Vector3(scale_factor, scale_factor, scale_factor)
		parent.add_child(tree)
		tree.global_position = pos
	else:
		# Fallback to CSG
		var tree: Node3D = Node3D.new()
		tree.position = pos
		var trunk: CSGBox3D = CSGBox3D.new()
		trunk.size = Vector3(0.4, trunk_height, 0.4)
		trunk.position = Vector3(0, trunk_height / 2.0, 0)
		var trunk_mat: StandardMaterial3D = StandardMaterial3D.new()
		trunk_mat.albedo_color = Color(0.40, 0.28, 0.18)
		trunk_mat.roughness = 0.9
		trunk.material = trunk_mat
		tree.add_child(trunk)
		var canopy: CSGSphere3D = CSGSphere3D.new()
		canopy.radius = canopy_radius
		canopy.radial_segments = 8
		canopy.rings = 4
		canopy.position = Vector3(0, trunk_height + canopy_radius * 0.7, 0)
		var leaf_mat: StandardMaterial3D = StandardMaterial3D.new()
		leaf_mat.albedo_color = Color(0.30, 0.55, 0.28)
		leaf_mat.roughness = 0.85
		canopy.material = leaf_mat
		tree.add_child(canopy)
		parent.add_child(tree)


func _add_lantern(parent: Node3D, pos: Vector3) -> void:
	var lantern: Node3D = Node3D.new()
	lantern.position = pos
	# Post
	var post: CSGBox3D = CSGBox3D.new()
	post.size = Vector3(0.15, 2.0, 0.15)
	post.position = Vector3(0, 1.0, 0)
	var wood_mat: StandardMaterial3D = StandardMaterial3D.new()
	wood_mat.albedo_color = Color(0.45, 0.32, 0.20)
	wood_mat.roughness = 0.9
	post.material = wood_mat
	lantern.add_child(post)
	# Lamp head
	var lamp: CSGBox3D = CSGBox3D.new()
	lamp.size = Vector3(0.4, 0.5, 0.4)
	lamp.position = Vector3(0, 2.2, 0)
	var glow_mat: StandardMaterial3D = StandardMaterial3D.new()
	glow_mat.albedo_color = Color(1.0, 0.85, 0.5)
	glow_mat.emission_enabled = true
	glow_mat.emission = Color(1.0, 0.8, 0.4)
	glow_mat.emission_energy_multiplier = 2.0
	lamp.material = glow_mat
	lantern.add_child(lamp)
	# Point light
	var light: OmniLight3D = OmniLight3D.new()
	light.position = Vector3(0, 2.5, 0)
	light.light_color = Color(1.0, 0.85, 0.5)
	light.light_energy = 1.5
	light.omni_range = 8.0
	light.omni_attenuation = 1.5
	lantern.add_child(light)
	parent.add_child(lantern)


func _add_boundary_collision() -> void:
	# Town CSGBox3D boundaries are visual only — add StaticBody3D collision
	var geom: Node3D = get_node_or_null("Geometry") as Node3D
	if geom == null:
		return
	for dir: String in ["BoundaryNorth", "BoundarySouth", "BoundaryEast", "BoundaryWest"]:
		var wall: CSGBox3D = geom.get_node_or_null(dir) as CSGBox3D
		if wall and not wall.use_collision:
			wall.use_collision = true


func _add_fence(parent: Node3D, pos: Vector3, size: Vector3) -> void:
	var fence: CSGBox3D = CSGBox3D.new()
	fence.size = size
	fence.position = pos
	var mat: StandardMaterial3D = StandardMaterial3D.new()
	mat.albedo_color = Color(0.45, 0.32, 0.20)
	mat.roughness = 0.9
	fence.material = mat
	parent.add_child(fence)


func _setup_environment() -> void:
	# Skip if scene already has lighting (Town.tscn has it in the scene file)
	if get_node_or_null("DirectionalLight3D") or get_node_or_null("WorldEnvironment"):
		return
	# Warm directional light — top-left per visual style guide
	var sun: DirectionalLight3D = DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-50, -30, 0)
	sun.light_energy = 1.0
	sun.light_color = Color(1.0, 0.95, 0.85)  # Warm sunlight
	sun.shadow_enabled = true
	sun.directional_shadow_mode = DirectionalLight3D.SHADOW_PARALLEL_4_SPLITS
	add_child(sun)

	# Soft fill light
	var fill: DirectionalLight3D = DirectionalLight3D.new()
	fill.rotation_degrees = Vector3(-35, 150, 0)
	fill.light_energy = 0.35
	fill.light_color = Color(0.8, 0.85, 1.0)
	fill.shadow_enabled = false
	add_child(fill)

	# World environment — cozy warm town atmosphere
	var env: Environment = Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.45, 0.65, 0.85)  # Light sky blue
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.5, 0.48, 0.42)  # Warm ambient
	env.ambient_light_energy = 0.6
	# Light fog for depth
	env.fog_enabled = true
	env.fog_light_color = Color(0.6, 0.65, 0.75)
	env.fog_density = 0.005
	# Tonemap
	env.tonemap_mode = 2  # Filmic
	env.tonemap_white = 6.0
	# Subtle glow
	env.glow_enabled = true
	env.glow_intensity = 0.2
	env.glow_bloom = 0.05

	var world_env: WorldEnvironment = WorldEnvironment.new()
	world_env.environment = env
	add_child(world_env)


func _setup_demo_end_trigger() -> void:
	# Give player a moment to see the town, then trigger demo end
	await get_tree().create_timer(3.0).timeout
	if not is_instance_valid(self):
		return
	if GameManager.should_trigger_demo_end():
		GameManager.trigger_demo_end()
