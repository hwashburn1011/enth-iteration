extends Node3D
## Town hub — persistent home base with NPC slots and spawn points.

const NPC_SCENES: Dictionary = {
	"ai_sage": "res://scenes/entities/npcs/AISageTown.tscn",
	"cache_sprite": "res://scenes/entities/npcs/CacheSprite.tscn",
	"villager_r3": "res://scenes/entities/npcs/VillagerR3.tscn",
}

## NPCs that are always present in town (no recruitment needed)
const ALWAYS_PRESENT: Array[String] = ["ai_sage", "villager_r3"]

@onready var player_spawn_point: Marker3D = %PlayerSpawnPoint
@onready var portal_return_point: Marker3D = %PortalReturnPoint
@onready var npc_slots: Node3D = %NPCSlots


func _ready() -> void:
	portal_return_point.add_to_group(&"portal_return_point")
	player_spawn_point.add_to_group(&"respawn_point")

	# --- Lighting and Environment ---
	_setup_environment()
	# Replace the flat green Ground material with a procedural grass texture
	_apply_town_ground_texture()
	# Replace flat building/boundary materials with procedural plaster + stone
	_apply_town_building_textures()

	# Spawn HUD (combat elements hidden in town)
	var hud_scene: PackedScene = load("res://scenes/ui/hud/HUD.tscn") as PackedScene
	if hud_scene:
		var hud_inst: Node = hud_scene.instantiate()
		add_child(hud_inst)
		if hud_inst.has_method(&"set_combat_visible"):
			hud_inst.set_combat_visible.call_deferred(false)

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
	# Start town music directly (AudioManager scene_changed may fail during transitions)
	AudioManager.play_music("town_ambient")
	_build_town_decorations()
	_populate_npcs()
	_update_town_state()
	_add_ambient_particles()
	# R6 epic-1: build East Plaza district expansion (data market)
	_build_east_plaza()
	# R5 round-30: clamp baked-GLB hot emissions (lantern flames at 80.0)
	# down to a HDR-safe value to prevent bloom blowout. Discovered via the
	# round-30 emission survey across all 3 main scenes.
	_clamp_hot_emissions(get_node_or_null("Geometry"))
	# Show "TOWN" location label briefly
	_show_location_label("TOWN")

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
			add_child(npc)
			npc.global_position = slot.global_position
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
		"villager_r3":
			return npc_slots.get_node_or_null("NPCSlot3") as Marker3D
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


func _show_location_label(location: String) -> void:
	## Cinematic location title — dramatic fade in/out at the top of the screen.
	var canvas: CanvasLayer = CanvasLayer.new()
	canvas.layer = 85
	# Wrap the label in a wide control so the underline can stretch
	var holder: Control = Control.new()
	holder.set_anchors_preset(Control.PRESET_CENTER_TOP)
	holder.offset_left = -260
	holder.offset_right = 260
	holder.offset_top = 140
	holder.offset_bottom = 230
	holder.mouse_filter = Control.MOUSE_FILTER_IGNORE
	holder.modulate.a = 0.0
	canvas.add_child(holder)
	# Main location text
	var label: Label = Label.new()
	label.text = location
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.set_anchors_preset(Control.PRESET_TOP_WIDE)
	label.offset_top = 0
	label.offset_bottom = 50
	label.add_theme_font_size_override(&"font_size", 44)
	label.add_theme_color_override(&"font_color", Color(0.95, 0.88, 0.55))
	label.add_theme_color_override(&"font_outline_color", Color(0, 0, 0, 0.85))
	label.add_theme_constant_override(&"outline_size", 6)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	holder.add_child(label)
	# Decorative underline rule
	var rule: ColorRect = ColorRect.new()
	rule.set_anchors_preset(Control.PRESET_TOP_WIDE)
	rule.offset_left = 80
	rule.offset_right = -80
	rule.offset_top = 56
	rule.offset_bottom = 58
	rule.color = Color(0.95, 0.85, 0.45, 0.7)
	rule.mouse_filter = Control.MOUSE_FILTER_IGNORE
	holder.add_child(rule)
	add_child(canvas)
	# Cinematic in/hold/out
	var tween: Tween = holder.create_tween()
	tween.tween_property(holder, "modulate:a", 1.0, 0.5).set_ease(Tween.EASE_OUT)
	tween.tween_interval(2.0)
	tween.tween_property(holder, "modulate:a", 0.0, 0.7).set_ease(Tween.EASE_IN)
	tween.tween_callback(canvas.queue_free)


func _add_ambient_particles() -> void:
	# Warm floating dust motes / fireflies
	var particles: GPUParticles3D = GPUParticles3D.new()
	particles.amount = 60  # More fireflies for richer atmosphere
	particles.lifetime = 7.0
	particles.visibility_aabb = AABB(Vector3(-20, 0, -20), Vector3(40, 6, 40))
	particles.position = Vector3(0, 2, 0)

	var mat: ParticleProcessMaterial = ParticleProcessMaterial.new()
	mat.direction = Vector3(0, 1, 0)
	mat.spread = 180.0
	mat.initial_velocity_min = 0.2
	mat.initial_velocity_max = 0.5
	mat.gravity = Vector3(0, 0.1, 0)
	mat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	mat.emission_box_extents = Vector3(18, 2, 18)
	mat.color = Color(1.0, 0.9, 0.5, 0.6)
	mat.scale_min = 0.5
	mat.scale_max = 1.5
	particles.process_material = mat

	var mesh: SphereMesh = SphereMesh.new()
	mesh.radius = 0.03
	mesh.height = 0.06
	particles.draw_pass_1 = mesh

	# Glow material for particles
	var vis_mat: StandardMaterial3D = StandardMaterial3D.new()
	vis_mat.albedo_color = Color(1.0, 0.9, 0.5, 0.6)
	vis_mat.emission_enabled = true
	vis_mat.emission = Color(1.0, 0.85, 0.4)
	vis_mat.emission_energy_multiplier = 2.0
	vis_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	vis_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	particles.material_override = vis_mat

	add_child(particles)

	# High-altitude drifting cloud particles for sky depth
	var clouds: GPUParticles3D = GPUParticles3D.new()
	clouds.amount = 15
	clouds.lifetime = 20.0
	clouds.position = Vector3(0, 12, 0)
	clouds.visibility_aabb = AABB(Vector3(-25, 8, -25), Vector3(50, 6, 50))
	var cloud_mat: ParticleProcessMaterial = ParticleProcessMaterial.new()
	cloud_mat.direction = Vector3(1, 0, 0.2)
	cloud_mat.spread = 5.0
	cloud_mat.initial_velocity_min = 0.3
	cloud_mat.initial_velocity_max = 0.6
	cloud_mat.gravity = Vector3.ZERO
	cloud_mat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	cloud_mat.emission_box_extents = Vector3(25, 2, 25)
	cloud_mat.color = Color(1.0, 0.95, 0.85, 0.15)
	cloud_mat.scale_min = 3.0
	cloud_mat.scale_max = 6.0
	clouds.process_material = cloud_mat
	var cloud_mesh: SphereMesh = SphereMesh.new()
	cloud_mesh.radius = 0.5
	cloud_mesh.height = 0.4
	clouds.draw_pass_1 = cloud_mesh
	var cloud_vis: StandardMaterial3D = StandardMaterial3D.new()
	cloud_vis.albedo_color = Color(1.0, 0.96, 0.88, 0.12)
	cloud_vis.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	cloud_vis.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	clouds.material_override = cloud_vis
	add_child(clouds)


func _build_town_decorations() -> void:
	var geom: Node3D = get_node_or_null("Geometry") as Node3D
	if geom == null:
		return

	# --- Boundary collision + ground collision ---
	_add_boundary_collision()
	_add_ground_collision()

	# --- Dirt paths ---
	_add_path(geom, Vector3(0, 0.01, 0), Vector3(3, 0.02, 30))
	_add_path(geom, Vector3(0, 0.01, 0), Vector3(24, 0.02, 3))
	_add_path(geom, Vector3(0, 0.01, -10), Vector3(3, 0.02, 12))

	# --- Ground variation patches ---
	_add_ground_patches(geom)

	# R5 fix: Town.tscn already instances Building1R3..Building4R3 from R4-08
	# + R4-29. The old code below ALSO spawned cottage_01/workshop_01/tavern_01
	# at the same positions, doubling the buildings. Skip the runtime loop if
	# any R3 building instance is already present in geom.
	var has_r3_buildings: bool = geom.get_node_or_null("Building1R3") != null
	if not has_r3_buildings:
		# Legacy v2 path — only fires if Town.tscn doesn't already have R3
		var building_models: Array[String] = [
			"res://assets/models/buildings/cottage_01.glb",
			"res://assets/models/buildings/workshop_01.glb",
			"res://assets/models/buildings/tavern_01.glb",
			"res://assets/models/buildings/cottage_01.glb",
		]
		var building_rotations: Array[float] = [0, 0, PI, PI / 2.0]
		var plaster_mat: StandardMaterial3D = _make_plaster_material()
		var roof_mat: StandardMaterial3D = _make_roof_tile_material()
		for i: int in range(1, 5):
			var building: CSGBox3D = geom.get_node_or_null("Building%d" % i) as CSGBox3D
			if building:
				var pos: Vector3 = building.global_position
				var glb: PackedScene = load(building_models[i - 1]) as PackedScene
				if glb:
					building.visible = false
					var instance: Node3D = glb.instantiate() as Node3D
					instance.rotation.y = building_rotations[i - 1]
					geom.add_child(instance)
					instance.global_position = Vector3(pos.x, 0, pos.z)
					_apply_building_materials(instance, plaster_mat, roof_mat)
					var win_light: OmniLight3D = OmniLight3D.new()
					win_light.position = Vector3(0, 2.0, -2.0)
					win_light.light_color = Color(1.0, 0.85, 0.55)
					win_light.light_energy = 1.0
					win_light.omni_range = 5.0
					win_light.omni_attenuation = 2.0
					instance.add_child(win_light)
				else:
					building.use_collision = true
					_add_roof(building)
	else:
		# R3 path: add a warm window light to each R3 building instance for
		# evening atmosphere (the R3 GLBs don't include lights themselves).
		# R5 round-3 fix: also override the building mesh material because
		# the R3 baked albedos are placeholder UV pads of solid pale color
		# (same bug as the character sculpts) so the buildings render as
		# featureless white blocks. Use distinct hues per building so the
		# town reads as separate structures.
		# R5 round-6: shift building hues into the digital palette so they
		# stop reading as warm earthtone medieval houses. Same distinct
		# silhouettes but blue / teal / violet / amber data-block flavors.
		var building_mats: Array[Color] = [
			Color(0.18, 0.40, 0.55),  # cyan smithy
			Color(0.40, 0.20, 0.55),  # violet workshop
			Color(0.55, 0.30, 0.10),  # amber cottage
			Color(0.15, 0.55, 0.45),  # teal tavern
		]
		for i: int in range(1, 5):
			var r3_building: Node = geom.get_node_or_null("Building%dR3" % i)
			if r3_building:
				var win_light: OmniLight3D = OmniLight3D.new()
				win_light.position = Vector3(0, 2.0, -2.0)
				win_light.light_color = Color(1.0, 0.85, 0.55)
				win_light.light_energy = 1.0
				win_light.omni_range = 5.0
				win_light.omni_attenuation = 2.0
				r3_building.add_child(win_light)
				# R5 round-43 fix: the R3 sculpted building GLBs ship without
				# any collision shape. The original Building1-4 CSG placeholders
				# WERE the collision providers but they're set visible=false
				# in Town.tscn (with use_collision implicitly false because the
				# CSG isn't rendered). Net result: player walks straight through
				# every building. Caught by the round-43 wall collision survey.
				# Add a procedural StaticBody3D + BoxShape3D matching the
				# building's largest mesh AABB.
				var biggest_size: float = 0.0
				var biggest_aabb: AABB
				var bs: Array = [r3_building]
				while not bs.is_empty():
					var bn: Node = bs.pop_back()
					if bn is MeshInstance3D and (bn as MeshInstance3D).mesh:
						var ab: AABB = (bn as MeshInstance3D).mesh.get_aabb()
						var sv: float = ab.size.x * ab.size.y * ab.size.z
						if sv > biggest_size:
							biggest_size = sv
							biggest_aabb = ab
					for bc in bn.get_children():
						bs.append(bc)
				if biggest_size > 0.0:
					var building_scale: Vector3 = (r3_building as Node3D).scale
					var body: StaticBody3D = StaticBody3D.new()
					var shape: CollisionShape3D = CollisionShape3D.new()
					var box: BoxShape3D = BoxShape3D.new()
					box.size = Vector3(
						biggest_aabb.size.x * building_scale.x,
						biggest_aabb.size.y * building_scale.y,
						biggest_aabb.size.z * building_scale.z
					)
					shape.shape = box
					var center: Vector3 = biggest_aabb.position + biggest_aabb.size * 0.5
					shape.position = Vector3(
						center.x * building_scale.x,
						center.y * building_scale.y,
						center.z * building_scale.z
					)
					body.add_child(shape)
					r3_building.add_child(body)
				# Material override on every mesh under the R3 building
				var bm: StandardMaterial3D = StandardMaterial3D.new()
				bm.albedo_color = building_mats[i - 1] * 0.4
				bm.roughness = 0.5
				bm.metallic = 0.4
				bm.emission_enabled = true
				bm.emission = building_mats[i - 1]
				bm.emission_energy_multiplier = 0.55
				# Force opaque — some R3 building meshes have alpha mode set
				bm.transparency = BaseMaterial3D.TRANSPARENCY_DISABLED
				bm.cull_mode = BaseMaterial3D.CULL_BACK
				var st: Array = [r3_building]
				while not st.is_empty():
					var n: Node = st.pop_back()
					if n is MeshInstance3D:
						(n as MeshInstance3D).material_override = bm
					for c in n.get_children():
						st.append(c)

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

	# --- Flower beds ---
	_add_prop(geom, "res://assets/models/props/flower_bed.glb", Vector3(-6, 0, 2), Vector3(0.8, 0.8, 0.8))
	_add_prop(geom, "res://assets/models/props/flower_bed.glb", Vector3(6, 0, -2), Vector3(0.7, 0.7, 0.7))
	_add_prop(geom, "res://assets/models/props/flower_bed.glb", Vector3(-2, 0, 12), Vector3(0.9, 0.9, 0.9))
	_add_prop(geom, "res://assets/models/props/flower_bed.glb", Vector3(12, 0, 2), Vector3(0.6, 0.6, 0.6))

	# --- Portal archway at dungeon entrance ---
	# R5 round-41 fix: REMOVED — DungeonEntrance.tscn already instances its
	# own portal_archway via _build_entrance_visual at the same (0, 0, -15)
	# position. Spawning a second copy here caused both archways to z-fight
	# at every shared mesh (PortalGlow, TopRune_*, etc). Caught by the
	# round-41 z-fighting survey (18 conflicting mesh pairs at identical XYZ).
	# _add_prop(geom, "res://assets/models/props/portal_archway.glb", Vector3(0, 0, -15), Vector3(1, 1, 1))

	# --- Bushes and pine trees for variety ---
	_add_prop(geom, "res://assets/models/props/bush.glb", Vector3(-13, 0, 0), Vector3(1, 1, 1))
	_add_prop(geom, "res://assets/models/props/bush.glb", Vector3(13, 0, -3), Vector3(0.8, 0.8, 0.8))
	_add_prop(geom, "res://assets/models/props/bush.glb", Vector3(-5, 0, 16), Vector3(1.1, 1.1, 1.1))
	_add_prop(geom, "res://assets/models/props/bush.glb", Vector3(8, 0, -14), Vector3(0.7, 0.7, 0.7))
	_add_prop(geom, "res://assets/models/props/bush.glb", Vector3(3, 0, 10), Vector3(0.9, 0.9, 0.9))
	_add_prop(geom, "res://assets/models/props/pine_tree.glb", Vector3(-17, 0, 10), Vector3(0.8, 0.8, 0.8))
	_add_prop(geom, "res://assets/models/props/pine_tree.glb", Vector3(17, 0, -5), Vector3(0.7, 0.7, 0.7))
	_add_prop(geom, "res://assets/models/props/pine_tree.glb", Vector3(-10, 0, -16), Vector3(0.9, 0.9, 0.9))

	# --- Detail props: barrels, crates, signpost, well ---
	_add_prop(geom, "res://assets/models/props/barrel.glb", Vector3(-12, 0, -6), Vector3(1, 1, 1))
	_add_prop(geom, "res://assets/models/props/barrel.glb", Vector3(-11.5, 0, -5.5), Vector3(0.9, 0.9, 0.9))
	_add_prop(geom, "res://assets/models/props/crate_stack.glb", Vector3(11, 0, 8), Vector3(1, 1, 1))
	_add_prop(geom, "res://assets/models/props/crate_stack.glb", Vector3(-9, 0, 11), Vector3(0.8, 0.8, 0.8))
	_add_prop(geom, "res://assets/models/props/signpost.glb", Vector3(2, 0, 3), Vector3(1.2, 1.2, 1.2))
	# Benches near the well
	_add_prop(geom, "res://assets/models/props/bench.glb", Vector3(-2.5, 0, 1), Vector3(1.5, 1.5, 1.5))
	_add_prop(geom, "res://assets/models/props/bench.glb", Vector3(2.5, 0, -1.5), Vector3(1.5, 1.5, 1.5))
	# R5-04: Decorative R5 sculpted bridge on the north path
	# R5 round-31: drop y to -0.48 to get the bridge bottom flush with the
	# ground. The bridge GLB origin is ~16cm above its lowest mesh vertex
	# and at scale 1.6 the visible bottom was floating 49cm above the ground
	# per the round-31 survey. -0.48 brings the bottom to ~0.
	_add_prop(geom, "res://assets/models/props/wooden_bridge_r5.glb", Vector3(0, -0.48, -6), Vector3(1.6, 1.6, 1.6))
	# R5 round-2 fix: stone_well_r5.glb has broken geometry (AABB 0.05x0.6x0.05
	# = a stick) and missing texture UIDs. Skip until re-bake. The town already
	# has the bench around the well anchor point.
	# _add_prop(geom, "res://assets/models/props/stone_well_r5.glb", ...)

	# R4-07: R3 hero forge + anvil near Building1 (the smithy)
	# R5 round-2 fix: forge_anvil_r3.glb is 2.8x2.5x2.4m at scale 1 — that's
	# bigger than the player. Drop to 0.4 → ~1m tall.
	_add_prop(geom, "res://assets/models/props/forge_anvil_r3.glb", Vector3(-9, 0, -6), Vector3(0.4, 0.4, 0.4))

	# R4-07: R3 rock formation scatter on the boundary perimeter
	# R5 round-2 fix: rock_formation_r3 base AABB is 3.7x2.5x3.4m. Drop to
	# 0.5–0.7 to read as foreground rocks not city-block boulders.
	_add_prop(geom, "res://assets/models/props/rock_formation_r3.glb", Vector3(-18, 0, 5), Vector3(0.65, 0.65, 0.65))
	_add_prop(geom, "res://assets/models/props/rock_formation_r3.glb", Vector3(18, 0, -3), Vector3(0.5, 0.5, 0.5))
	_add_prop(geom, "res://assets/models/props/rock_formation_r3.glb", Vector3(-8, 0, 18), Vector3(0.6, 0.6, 0.6))


func _add_ground_patches(parent: Node3D) -> void:
	# Subtle dark/light grass patches for depth — much lower alpha now that
	# the procedural grass texture provides natural variation.
	var dark_mat: StandardMaterial3D = StandardMaterial3D.new()
	dark_mat.albedo_color = Color(0.18, 0.30, 0.16, 0.35)
	dark_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	dark_mat.roughness = 0.95
	var light_mat: StandardMaterial3D = StandardMaterial3D.new()
	light_mat.albedo_color = Color(0.55, 0.78, 0.45, 0.30)
	light_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	light_mat.roughness = 0.9
	# Dark patches near buildings
	var dark_positions: Array[Vector3] = [
		Vector3(-10, 0.005, -8), Vector3(10, 0.005, -6),
		Vector3(-8, 0.005, 8), Vector3(8, 0.005, 10),
	]
	for pos: Vector3 in dark_positions:
		var patch: CSGBox3D = CSGBox3D.new()
		patch.size = Vector3(8, 0.01, 7)
		patch.position = pos
		patch.material = dark_mat
		parent.add_child(patch)
	# Light patches in open areas
	for pos: Vector3 in [Vector3(-12, 0.005, 12), Vector3(12, 0.005, -14), Vector3(0, 0.005, 8)]:
		var patch: CSGBox3D = CSGBox3D.new()
		patch.size = Vector3(5, 0.01, 5)
		patch.position = pos
		patch.material = light_mat
		parent.add_child(patch)
	# Textured stone rock clusters
	var rock_mat: StandardMaterial3D = _make_pebble_rock_material()
	for pos: Vector3 in [Vector3(-13, 0.1, 10), Vector3(15, 0.1, -8), Vector3(-3, 0.1, -12)]:
		for j: int in 3:
			var rock: CSGSphere3D = CSGSphere3D.new()
			rock.radius = randf_range(0.15, 0.3)
			rock.radial_segments = 6
			rock.rings = 3
			rock.position = pos + Vector3(randf_range(-0.4, 0.4), 0, randf_range(-0.4, 0.4))
			rock.material = rock_mat
			parent.add_child(rock)


static func _make_pebble_rock_material() -> StandardMaterial3D:
	## Mossy gray stone for small ground rocks.
	var mat: StandardMaterial3D = StandardMaterial3D.new()
	mat.albedo_color = Color(0.55, 0.55, 0.52)
	var stone_noise: FastNoiseLite = FastNoiseLite.new()
	stone_noise.noise_type = FastNoiseLite.TYPE_CELLULAR
	stone_noise.frequency = 0.5
	stone_noise.cellular_jitter = 0.7
	var stone_tex: NoiseTexture2D = NoiseTexture2D.new()
	stone_tex.noise = stone_noise
	stone_tex.width = 256
	stone_tex.height = 256
	stone_tex.seamless = true
	var ramp: Gradient = Gradient.new()
	ramp.set_color(0, Color(0.30, 0.32, 0.28))
	ramp.set_color(1, Color(0.68, 0.68, 0.62))
	ramp.add_point(0.4, Color(0.42, 0.43, 0.38))
	ramp.add_point(0.75, Color(0.55, 0.55, 0.50))
	stone_tex.color_ramp = ramp
	mat.albedo_texture = stone_tex
	var bump_tex: NoiseTexture2D = NoiseTexture2D.new()
	bump_tex.noise = stone_noise
	bump_tex.width = 256
	bump_tex.height = 256
	bump_tex.seamless = true
	bump_tex.as_normal_map = true
	bump_tex.bump_strength = 5.0
	mat.normal_enabled = true
	mat.normal_texture = bump_tex
	mat.normal_scale = 1.0
	mat.uv1_triplanar = true
	mat.uv1_scale = Vector3(2.0, 2.0, 2.0)
	mat.metallic = 0.05
	mat.roughness = 0.95
	return mat


func _add_prop(parent: Node3D, path: String, pos: Vector3, prop_scale: Vector3) -> void:
	var scene: PackedScene = load(path) as PackedScene
	if scene:
		var instance: Node3D = scene.instantiate() as Node3D
		instance.scale = prop_scale
		parent.add_child(instance)
		instance.global_position = pos
		# Route texture by GLB filename
		_apply_prop_material_by_path(instance, path)
		# R5 round-44 fix: every prop loaded via _add_prop has been shipping
		# with NO collision shape — the player walks through trees, rocks,
		# anvils, barrels, crates, the bridge, and benches. Caught by the
		# round-44 town prop collision survey (28 solid props missing
		# collision). Add a procedural BoxShape3D matching the largest
		# mesh AABB, except for decorative props (flower beds, bushes,
		# small leaves, signposts) where collision would feel obstructive.
		var stem: String = path.get_file().get_basename().to_lower()
		var skip_collision: bool = (
			"flower" in stem or "bush" in stem or "pine" in stem
			or "bridge" in stem or "signpost" in stem or "lantern" in stem
		)
		if not skip_collision:
			_add_prop_collision(instance)


static func _add_prop_collision(prop_root: Node3D) -> void:
	## Walk the prop tree, find the biggest mesh AABB, and add a
	## procedural StaticBody3D + BoxShape3D under the prop root.
	var biggest_size: float = 0.0
	var biggest_aabb: AABB
	var st: Array = [prop_root]
	while not st.is_empty():
		var n: Node = st.pop_back()
		if n is MeshInstance3D and (n as MeshInstance3D).mesh:
			var ab: AABB = (n as MeshInstance3D).mesh.get_aabb()
			var sv: float = ab.size.x * ab.size.y * ab.size.z
			if sv > biggest_size:
				biggest_size = sv
				biggest_aabb = ab
		for c in n.get_children():
			st.append(c)
	if biggest_size <= 0.0:
		return
	var prop_scale: Vector3 = prop_root.scale
	var body: StaticBody3D = StaticBody3D.new()
	var shape: CollisionShape3D = CollisionShape3D.new()
	var box: BoxShape3D = BoxShape3D.new()
	box.size = Vector3(
		biggest_aabb.size.x * prop_scale.x,
		biggest_aabb.size.y * prop_scale.y,
		biggest_aabb.size.z * prop_scale.z
	)
	shape.shape = box
	var center: Vector3 = biggest_aabb.position + biggest_aabb.size * 0.5
	shape.position = Vector3(
		center.x * prop_scale.x,
		center.y * prop_scale.y,
		center.z * prop_scale.z
	)
	body.add_child(shape)
	prop_root.add_child(body)


func _apply_prop_material_by_path(root: Node, path: String) -> void:
	## Pick a material from the path stem and override every mesh in the
	## prop tree, skipping meshes that have emissive (glow) materials.
	## R5 round-6: forge/anvil/rock/well now route to digital theme materials
	## (metallic dark base + cyan emission) so they fit the cyber world.
	var stem: String = path.get_file().get_basename().to_lower()
	var mat: StandardMaterial3D
	if "well" in stem or "stone" in stem or "rock" in stem:
		mat = _make_stone_material()
	elif "anvil" in stem or "forge" in stem:
		mat = _make_data_metal_material()
	elif "bridge" in stem or "barrel" in stem or "crate" in stem or "bench" in stem or "signpost" in stem:
		mat = _make_wood_material()
	elif "bush" in stem or "flower" in stem or "pine" in stem:
		# Foliage already textured by tree pass — reuse
		mat = _make_foliage_material()
	else:
		return  # Unknown prop type — leave default materials
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
				mi.material_override = mat
		for c in n.get_children():
			stack.append(c)


static func _make_wood_material() -> StandardMaterial3D:
	## R5 round-6: weathered planks photoscanned PBR is off-theme. Return a
	## warm amber emissive panel — reads as a "data plank" or holographic
	## construct rather than real wood. Used for bridges, benches, signposts.
	var mat: StandardMaterial3D = StandardMaterial3D.new()
	mat.albedo_color = Color(0.22, 0.16, 0.10)
	mat.emission_enabled = true
	mat.emission = Color(0.65, 0.40, 0.10)
	mat.emission_energy_multiplier = 0.45
	mat.metallic = 0.3
	mat.roughness = 0.55
	return mat


static func _make_data_metal_material() -> StandardMaterial3D:
	## R5 round-6: digital "data metal" surface — dark metallic base with
	## bright cyan emission edges. Used for forge/anvil props that should
	## read as compute hardware rather than blacksmith tools.
	var mat: StandardMaterial3D = StandardMaterial3D.new()
	mat.albedo_color = Color(0.08, 0.12, 0.18)
	mat.emission_enabled = true
	mat.emission = Color(0.15, 0.55, 0.70)
	mat.emission_energy_multiplier = 0.55
	mat.metallic = 0.75
	mat.roughness = 0.35
	return mat


func _add_path(parent: Node3D, pos: Vector3, size: Vector3) -> void:
	var path: CSGBox3D = CSGBox3D.new()
	path.size = size
	path.position = pos
	path.material = _make_dirt_path_material()
	parent.add_child(path)


static func _make_dirt_path_material() -> StandardMaterial3D:
	## R5 round-4: dirt-mud photoscanned PBR is off-theme for the digital
	## simulation world. Return a flat dark-cyan emissive panel that reads
	## as a "data lane" rather than a path. Real shader work happens on the
	## ground plane (see _apply_town_ground_texture); paths just need to be
	## visually distinct from the surrounding grid without screaming "dirt".
	var mat: StandardMaterial3D = StandardMaterial3D.new()
	mat.albedo_color = Color(0.08, 0.18, 0.22)
	mat.emission_enabled = true
	mat.emission = Color(0.10, 0.42, 0.50)
	mat.emission_energy_multiplier = 0.45
	mat.metallic = 0.2
	mat.roughness = 0.6
	mat.transparency = BaseMaterial3D.TRANSPARENCY_DISABLED
	return mat


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
	## R4-03: load the R3 sculpted hero tree GLB (gnarled cylinder trunk
	## w/ Z-twist + 5 extruded branches + 6 jittered SSS leaf canopies)
	## instead of the v2 tree_01.glb placeholder.
	var tree_scene: PackedScene = load("res://assets/models/props/hero_tree_r3.glb") as PackedScene
	if tree_scene:
		var tree: Node3D = tree_scene.instantiate() as Node3D
		# R5 round-2 fix: hero_tree_r3 actual AABB is 2.46x6.42x2.54 — at the
		# old scale_factor (canopy_radius / 1.3 ≈ 1.0) trees were 6.4m tall
		# and dwarfed every building. Halve the divisor so trees come in
		# around 3-3.5m tall (still hero-scale, fits scene better).
		var scale_factor: float = canopy_radius / 2.6
		tree.scale = Vector3(scale_factor, scale_factor, scale_factor)
		parent.add_child(tree)
		tree.global_position = pos
		_apply_tree_textures(tree)
		# R5 round-44: trees are solid props but ship without collision —
		# add a procedural BoxShape3D so the player can't walk through trunks
		_add_prop_collision(tree)
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
	## R4-02: load the R3 sculpted iron lantern (carved 4 glass panels +
	## 8 deep vent cutouts + extruded dome + chain link + Pointiness flame
	## emission + inner emission flame icosphere) instead of the v2 placeholder.
	var glb: PackedScene = load("res://assets/models/props/iron_lantern_r3.glb") as PackedScene
	if glb:
		var lantern: Node3D = glb.instantiate() as Node3D
		parent.add_child(lantern)
		# R5 round-31 fix: the iron_lantern_r3 GLB only contains the lamp head
		# (~0.9m tall, no post) and the lamp internally sits ~1m above the
		# GLB origin where the post would have been. With lantern.global_y=0,
		# the lamp head bottom hovers at ~0.75m with nothing under it. Add
		# a procedural emissive cyan post that fills the 0–0.75m gap so the
		# lamp visually rests on a data-conduit support column. Discovered
		# via the round-31 floating prop survey.
		lantern.global_position = pos
		var lantern_post: MeshInstance3D = MeshInstance3D.new()
		var lantern_post_mesh: CylinderMesh = CylinderMesh.new()
		lantern_post_mesh.top_radius = 0.05
		lantern_post_mesh.bottom_radius = 0.08
		lantern_post_mesh.height = 0.78
		lantern_post.mesh = lantern_post_mesh
		lantern_post.position = Vector3(0, 0.39, 0)
		var lantern_post_mat: StandardMaterial3D = StandardMaterial3D.new()
		lantern_post_mat.albedo_color = Color(0.10, 0.18, 0.26)
		lantern_post_mat.emission_enabled = true
		lantern_post_mat.emission = Color(0.20, 0.55, 0.75)
		lantern_post_mat.emission_energy_multiplier = 0.8
		lantern_post_mat.metallic = 0.7
		lantern_post_mat.roughness = 0.35
		lantern_post.material_override = lantern_post_mat
		lantern.add_child(lantern_post)
		# Add point light (not in the model — the R3 GLB also embeds a flame
		# icosphere but Godot needs an actual Light3D to cast shadows)
		var light: OmniLight3D = OmniLight3D.new()
		light.position = Vector3(0, 1.5, 0)
		light.light_color = Color(1.0, 0.85, 0.5)
		light.light_energy = 1.5
		light.omni_range = 8.0
		light.omni_attenuation = 1.5
		lantern.add_child(light)
		return
	# Fallback CSG
	var fallback_lantern: Node3D = Node3D.new()
	fallback_lantern.position = pos
	var post: CSGBox3D = CSGBox3D.new()
	post.size = Vector3(0.15, 2.0, 0.15)
	post.position = Vector3(0, 1.0, 0)
	var wood_mat: StandardMaterial3D = StandardMaterial3D.new()
	wood_mat.albedo_color = Color(0.45, 0.32, 0.20)
	wood_mat.roughness = 0.9
	post.material = wood_mat
	fallback_lantern.add_child(post)
	var lamp: CSGBox3D = CSGBox3D.new()
	lamp.size = Vector3(0.4, 0.5, 0.4)
	lamp.position = Vector3(0, 2.2, 0)
	var glow_mat: StandardMaterial3D = StandardMaterial3D.new()
	glow_mat.albedo_color = Color(1.0, 0.85, 0.5)
	glow_mat.emission_enabled = true
	glow_mat.emission = Color(1.0, 0.8, 0.4)
	glow_mat.emission_energy_multiplier = 2.0
	lamp.material = glow_mat
	fallback_lantern.add_child(lamp)
	var fallback_light: OmniLight3D = OmniLight3D.new()
	fallback_light.position = Vector3(0, 2.5, 0)
	fallback_light.light_color = Color(1.0, 0.85, 0.5)
	fallback_light.light_energy = 1.5
	fallback_light.omni_range = 8.0
	fallback_light.omni_attenuation = 1.5
	fallback_lantern.add_child(fallback_light)
	parent.add_child(fallback_lantern)


func _add_boundary_collision() -> void:
	# Make the existing CSG boundary walls thick enough to prevent clipping
	# AND enable collision on them
	var geom: Node3D = get_node_or_null("Geometry") as Node3D
	if geom == null:
		return
	# Resize walls to be much thicker (3 units instead of 0.5)
	var wall_configs: Dictionary = {
		"BoundaryNorth": Vector3(44, 3, 3),
		"BoundarySouth": Vector3(44, 3, 3),
		"BoundaryEast": Vector3(3, 3, 44),
		"BoundaryWest": Vector3(3, 3, 44),
	}
	for dir: String in wall_configs:
		var wall: CSGBox3D = geom.get_node_or_null(dir) as CSGBox3D
		if wall:
			wall.size = wall_configs[dir] as Vector3
			wall.use_collision = true
	# Backup: StaticBody3D walls with convex BoxShape3D (more reliable than CSG trimesh)
	var backup_walls: Array[Array] = [
		[Vector3(0, 1.5, -21), Vector3(44, 4, 4)],
		[Vector3(0, 1.5, 21), Vector3(44, 4, 4)],
		[Vector3(21, 1.5, 0), Vector3(4, 4, 44)],
		[Vector3(-21, 1.5, 0), Vector3(4, 4, 44)],
	]
	for data: Array in backup_walls:
		var body: StaticBody3D = StaticBody3D.new()
		body.collision_layer = 1
		var shape: CollisionShape3D = CollisionShape3D.new()
		var box: BoxShape3D = BoxShape3D.new()
		box.size = data[1] as Vector3
		shape.shape = box
		body.add_child(shape)
		body.position = data[0] as Vector3
		add_child(body)


func _apply_town_ground_texture() -> void:
	## R5 round-4: replace the Polyhaven forrest_ground_03 photoscanned PBR
	## (which is fantasy-medieval and off-theme) with a procedural digital
	## grid shader that fits the GDD's "AI agent inside a computer simulation"
	## theme. Cyan grid lines + dim hex glow + dark base — reads as a data
	## field, not dirt.
	var ground: MeshInstance3D = get_node_or_null("Geometry/Ground") as MeshInstance3D
	if ground == null:
		return
	var shader: Shader = Shader.new()
	shader.code = """
shader_type spatial;
render_mode unshaded, depth_draw_opaque, cull_back;
uniform vec3 base_color : source_color = vec3(0.04, 0.06, 0.10);
uniform vec3 grid_color : source_color = vec3(0.15, 0.55, 0.65);
uniform vec3 hex_color : source_color = vec3(0.05, 0.30, 0.40);
uniform float grid_scale = 1.0;
uniform float grid_thickness = 0.04;
uniform float pulse_speed = 0.6;
void fragment() {
	vec2 uv = UV * grid_scale;
	vec2 g = abs(fract(uv) - 0.5);
	float line = step(0.5 - grid_thickness, max(g.x, g.y));
	// Bigger 5x5 super-grid lanes that glow brighter
	vec2 g5 = abs(fract(uv * 0.2) - 0.5);
	float lane = step(0.5 - grid_thickness * 0.6, max(g5.x, g5.y));
	// Slow pulse so the grid feels alive
	float pulse = 0.6 + 0.4 * sin(TIME * pulse_speed + uv.x * 0.4 + uv.y * 0.3);
	vec3 col = base_color;
	col = mix(col, hex_color, lane * 0.55);
	col = mix(col, grid_color * pulse, line * 0.85);
	ALBEDO = col;
	EMISSION = col * 0.75;
}
"""
	var mat: ShaderMaterial = ShaderMaterial.new()
	mat.shader = shader
	mat.set_shader_parameter("grid_scale", 12.0)
	mat.set_shader_parameter("grid_thickness", 0.04)
	ground.material_override = mat


func _apply_town_building_textures() -> void:
	## Replace flat brown Building1-4 and gray Boundary1-4 materials with
	## procedurally textured plaster + stone surfaces.
	var geom: Node = get_node_or_null("Geometry")
	if geom == null:
		return
	var building_mat: StandardMaterial3D = _make_plaster_material()
	var boundary_mat: StandardMaterial3D = _make_stone_material()
	for child: Node in geom.get_children():
		if not (child is CSGBox3D):
			continue
		var box: CSGBox3D = child as CSGBox3D
		if box.name.begins_with("Building"):
			box.material = building_mat
		elif box.name.begins_with("Boundary"):
			box.material = boundary_mat


static func _make_plaster_material() -> StandardMaterial3D:
	## Real Polyhaven CC0 plaster_brick_01 PBR (R3-26: replaces the previous
	## procedural FastNoiseLite plaster — now uses photoscanned diffuse +
	## normal_gl + roughness instead of Perlin + cellular noise).
	var mat: StandardMaterial3D = StandardMaterial3D.new()
	var diff: Texture2D = load("res://assets/textures/polyhaven/plaster_brick_01_diff_1k.png") as Texture2D
	var nor: Texture2D = load("res://assets/textures/polyhaven/plaster_brick_01_nor_gl_1k.png") as Texture2D
	var rough: Texture2D = load("res://assets/textures/polyhaven/plaster_brick_01_rough_1k.png") as Texture2D
	if diff:
		mat.albedo_texture = diff
	if nor:
		mat.normal_enabled = true
		mat.normal_texture = nor
		mat.normal_scale = 1.2
	if rough:
		mat.roughness_texture = rough
		mat.roughness_texture_channel = BaseMaterial3D.TEXTURE_CHANNEL_RED
	mat.albedo_color = Color(1, 1, 1)
	mat.metallic = 0.0
	mat.uv1_triplanar = true
	mat.uv1_scale = Vector3(0.6, 0.6, 0.6)
	return mat


static func _make_roof_tile_material() -> StandardMaterial3D:
	## Real Polyhaven CC0 roof_09 PBR (R3-27: replaces the previous procedural
	## cellular terracotta — now uses photoscanned diffuse + normal_gl + roughness).
	var mat: StandardMaterial3D = StandardMaterial3D.new()
	var diff: Texture2D = load("res://assets/textures/polyhaven/roof_09_diff_1k.png") as Texture2D
	var nor: Texture2D = load("res://assets/textures/polyhaven/roof_09_nor_gl_1k.png") as Texture2D
	var rough: Texture2D = load("res://assets/textures/polyhaven/roof_09_rough_1k.png") as Texture2D
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
	mat.metallic = 0.05
	mat.uv1_triplanar = true
	mat.uv1_scale = Vector3(0.7, 0.7, 0.7)
	return mat


func _apply_building_materials(root: Node, body_mat: StandardMaterial3D, roof_mat: StandardMaterial3D) -> void:
	## Walk a building GLB tree and override every MeshInstance3D's material.
	## Heuristic: if the mesh's first surface uses a warm/orange tone, treat
	## it as roof; otherwise treat it as body.
	var stack: Array = [root]
	while not stack.is_empty():
		var n: Node = stack.pop_back()
		if n is MeshInstance3D:
			var mi: MeshInstance3D = n as MeshInstance3D
			var existing: Material = mi.get_active_material(0)
			var is_roof: bool = false
			if existing is StandardMaterial3D:
				var col: Color = (existing as StandardMaterial3D).albedo_color
				# Roofs are red/orange in the original GLB
				if col.r > col.g and col.r > col.b:
					is_roof = true
			mi.material_override = roof_mat if is_roof else body_mat
		for c in n.get_children():
			stack.append(c)


func _apply_tree_textures(root: Node) -> void:
	## Walk a tree GLB and apply bark / foliage textures by detecting which
	## meshes are bark (brown) and which are foliage (green).
	var bark_mat: StandardMaterial3D = _make_bark_material()
	var leaf_mat: StandardMaterial3D = _make_foliage_material()
	var stack: Array = [root]
	while not stack.is_empty():
		var n: Node = stack.pop_back()
		if n is MeshInstance3D:
			var mi: MeshInstance3D = n as MeshInstance3D
			var existing: Material = mi.get_active_material(0)
			var is_foliage: bool = false
			if existing is StandardMaterial3D:
				var col: Color = (existing as StandardMaterial3D).albedo_color
				# Foliage tends to be green-dominant
				if col.g > col.r and col.g > col.b * 1.2:
					is_foliage = true
			mi.material_override = leaf_mat if is_foliage else bark_mat
		for c in n.get_children():
			stack.append(c)


static func _make_bark_material() -> StandardMaterial3D:
	## R5 round-5: organic bark is off-theme. Re-style trees as "data spires" —
	## dark metal-like trunk with vertical cyan circuit traces. Solid color
	## with subtle emission so it reads as a structural data conduit.
	var mat: StandardMaterial3D = StandardMaterial3D.new()
	mat.albedo_color = Color(0.10, 0.18, 0.24)
	mat.emission_enabled = true
	mat.emission = Color(0.10, 0.45, 0.55)
	mat.emission_energy_multiplier = 0.4
	mat.metallic = 0.6
	mat.roughness = 0.4
	return mat


static func _make_foliage_material() -> StandardMaterial3D:
	## R5 round-5: organic foliage is off-theme. Re-style canopies as
	## "data crowns" — softly emissive teal cloud spheres that read as
	## clouds of code/particles around the data spire trunks.
	var mat: StandardMaterial3D = StandardMaterial3D.new()
	mat.albedo_color = Color(0.15, 0.55, 0.62)
	mat.emission_enabled = true
	mat.emission = Color(0.18, 0.70, 0.80)
	mat.emission_energy_multiplier = 0.7
	mat.metallic = 0.1
	mat.roughness = 0.5
	return mat


static func _make_stone_material() -> StandardMaterial3D:
	## R5 round-6: photoscanned rough_block_wall is off-theme. Return a
	## dark "data crystal" material — deep blue base with violet emission
	## that fits the simulation world. Used for stone wells, rock formations,
	## boundary walls.
	var mat: StandardMaterial3D = StandardMaterial3D.new()
	mat.albedo_color = Color(0.10, 0.12, 0.20)
	mat.emission_enabled = true
	mat.emission = Color(0.30, 0.20, 0.55)
	mat.emission_energy_multiplier = 0.4
	mat.metallic = 0.5
	mat.roughness = 0.45
	return mat


func _add_ground_collision() -> void:
	var body: StaticBody3D = StaticBody3D.new()
	var shape: CollisionShape3D = CollisionShape3D.new()
	var box: BoxShape3D = BoxShape3D.new()
	box.size = Vector3(42, 0.2, 42)
	shape.shape = box
	shape.position = Vector3(0, -0.1, 0)
	body.add_child(shape)
	add_child(body)


static func _clamp_hot_emissions(root: Node) -> void:
	## R5 round-30: walk every mesh under root and clamp baked-GLB
	## emission_energy_multiplier > 5.0 down to 4.0. Lantern flames ship
	## from Blender at 80.0 which causes severe HDR bloom blowout.
	## Duplicate the material before mutating to avoid poisoning the
	## shared resource cache.
	if root == null:
		return
	const HOT_THRESHOLD: float = 5.0
	const CLAMPED: float = 4.0
	var stack: Array = [root]
	while not stack.is_empty():
		var n: Node = stack.pop_back()
		if n is MeshInstance3D and (n as MeshInstance3D).mesh:
			var mi: MeshInstance3D = n as MeshInstance3D
			for s in range(mi.mesh.get_surface_count()):
				var existing := mi.get_active_material(s)
				if existing is StandardMaterial3D:
					var sm := existing as StandardMaterial3D
					if sm.emission_enabled and sm.emission_energy_multiplier > HOT_THRESHOLD:
						var dup := sm.duplicate() as StandardMaterial3D
						dup.emission_energy_multiplier = CLAMPED
						mi.set_surface_override_material(s, dup)
		for c in n.get_children():
			stack.append(c)


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
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
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


# ============================================================================
# R6 Epic-1: East Plaza district expansion
# ============================================================================
# Adds a new playable district east of the original town boundary, doubling
# the playable area. East Plaza is a digital data market — orange/cyan
# faction palette, holographic kiosks, queue bollards, ambient market chatter
# particles. Anchored at center (32, 0, 0) with 18m radius.

const EAST_PLAZA_CENTER: Vector3 = Vector3(32, 0, 0)


func _build_east_plaza() -> void:
	var geom: Node = get_node_or_null("Geometry")
	if geom == null:
		return
	# Step 1: extend the playable boundary east. The original BoundaryEast is
	# at x=20 and we want the player to walk to x=44 (center + 12). Push the
	# existing boundary out and add new north/south boundaries that span the
	# extension.
	var east_wall: CSGBox3D = geom.get_node_or_null("BoundaryEast") as CSGBox3D
	if east_wall:
		east_wall.position.x = 44.0
	# Step 2: ground extension — a separate cyan grid plane stitched to the
	# main town ground at x=20. Extends from x=20 to x=44, z=-20 to z=20.
	_build_east_plaza_ground(geom)
	# Step 3: connecting path from main town to plaza
	_build_east_plaza_path(geom)
	# Step 4: data terminal centerpiece (procedural mesh, no GLB needed)
	_build_data_terminal(geom, EAST_PLAZA_CENTER)
	# Step 5: 4 holographic kiosks around the centerpiece
	_build_kiosks(geom)
	# Step 6: queue bollards forming a market line
	_build_queue_bollards(geom)
	# Step 7: ambient market particles (orange/cyan code dust)
	_build_market_particles(geom)
	# Step 8: 4 plaza lights
	_build_plaza_lights(geom)
	# Step 9: data merchant NPC (placeholder + interaction)
	_build_data_merchant_npc()
	# Epic-1 T2: Cipher data broker NPC at far east
	_build_cipher_npc()
	# Epic-1 T3: procedural Market Hall building NE of the centerpiece
	_build_market_hall(geom)
	# Epic-1 T4: kiosk interaction labels
	_attach_kiosk_interactables(geom)
	# Epic-1 T5: ambient market chatter trigger zone (sets a meta on enter)
	_build_market_chatter_zone(geom)
	# Epic-1 T6: procedural vendor stall (separate from kiosks — open-air booth)
	_build_vendor_stall(geom)
	# Epic-1 T7: 5 ambient pedestrian orbs drifting through the plaza
	_build_plaza_pedestrians(geom)
	# Epic-1 T8: loading dock sub-area at far east edge
	_build_loading_dock(geom)
	# Epic-1 T9: hanging banner flags between kiosks
	_build_banner_flags(geom)
	# Epic-1 T10: cyan OPEN floor decals
	_build_open_decals(geom)
	# Epic-1 T11: cyan park benches
	_build_plaza_benches(geom)
	# Epic-1 T12: holographic planters with floating leaves
	_build_plaza_planters(geom)
	# Epic-1 T13: vending machines along the market hall wall
	_build_vending_machines(geom)
	# Epic-1 T14: 2 patrolling security drones above the plaza
	_build_security_drones(geom)
	# Epic-1 T15: info totem pillars at plaza entrances
	_build_info_totems(geom)
	# Epic-1 T16: data fountain centerpiece replacing the data terminal? no, in addition
	_build_data_fountain(geom)
	# Epic-1 T17: holographic billboards floating above the plaza
	_build_holo_billboards(geom)
	# Epic-1 T18: animated neon ad strips on the market hall walls
	_build_neon_ads(geom)
	# Epic-1 T19: transit pad with arrival pulse animation
	_build_transit_pad(geom)
	# Epic-1 T20: shop signage with glow text labels
	_build_shop_signage(geom)


func _build_east_plaza_ground(geom: Node) -> void:
	## Cyan grid floor extension stitched to main town ground at x=20.
	var plane: PlaneMesh = PlaneMesh.new()
	plane.size = Vector2(24, 40)
	var ground: MeshInstance3D = MeshInstance3D.new()
	ground.name = "EastPlazaGround"
	ground.mesh = plane
	ground.position = Vector3(32, 0, 0)
	# Reuse the same digital grid shader as the main ground for visual continuity
	var shader: Shader = Shader.new()
	shader.code = """
shader_type spatial;
render_mode unshaded, depth_draw_opaque, cull_back;
uniform vec3 base_color : source_color = vec3(0.04, 0.06, 0.10);
uniform vec3 grid_color : source_color = vec3(0.85, 0.45, 0.15);
uniform vec3 hex_color : source_color = vec3(0.45, 0.20, 0.05);
uniform float grid_scale = 12.0;
uniform float grid_thickness = 0.04;
uniform float pulse_speed = 0.6;
void fragment() {
	vec2 uv = UV * grid_scale;
	vec2 g = abs(fract(uv) - 0.5);
	float line = step(0.5 - grid_thickness, max(g.x, g.y));
	vec2 g5 = abs(fract(uv * 0.2) - 0.5);
	float lane = step(0.5 - grid_thickness * 0.6, max(g5.x, g5.y));
	float pulse = 0.6 + 0.4 * sin(TIME * pulse_speed + uv.x * 0.4 + uv.y * 0.3);
	vec3 col = base_color;
	col = mix(col, hex_color, lane * 0.55);
	col = mix(col, grid_color * pulse, line * 0.85);
	ALBEDO = col;
	EMISSION = col * 0.75;
}
"""
	var mat: ShaderMaterial = ShaderMaterial.new()
	mat.shader = shader
	ground.material_override = mat
	geom.add_child(ground)
	# Collision under the ground extension
	var body: StaticBody3D = StaticBody3D.new()
	var shape: CollisionShape3D = CollisionShape3D.new()
	var box: BoxShape3D = BoxShape3D.new()
	box.size = Vector3(24, 0.2, 40)
	shape.shape = box
	shape.position = Vector3(0, -0.1, 0)
	body.add_child(shape)
	ground.add_child(body)


func _build_east_plaza_path(geom: Node) -> void:
	## Glowing data lane stitching main town ground (x=20) to plaza center (x=32)
	var path: CSGBox3D = CSGBox3D.new()
	path.size = Vector3(12, 0.02, 3)
	path.position = Vector3(26, 0.01, 0)
	path.material = _make_dirt_path_material()
	geom.add_child(path)


func _build_data_terminal(geom: Node, center: Vector3) -> void:
	## Procedural data terminal — hexagonal pillar with glowing top dome
	var terminal_root: Node3D = Node3D.new()
	terminal_root.name = "EastPlazaDataTerminal"
	terminal_root.position = center
	geom.add_child(terminal_root)
	# Hex pillar base
	var pillar: MeshInstance3D = MeshInstance3D.new()
	var pillar_mesh: CylinderMesh = CylinderMesh.new()
	pillar_mesh.top_radius = 0.5
	pillar_mesh.bottom_radius = 0.7
	pillar_mesh.height = 1.6
	pillar_mesh.radial_segments = 6
	pillar.mesh = pillar_mesh
	pillar.position = Vector3(0, 0.8, 0)
	var pillar_mat: StandardMaterial3D = StandardMaterial3D.new()
	pillar_mat.albedo_color = Color(0.10, 0.16, 0.22)
	pillar_mat.emission_enabled = true
	pillar_mat.emission = Color(0.85, 0.45, 0.15)
	pillar_mat.emission_energy_multiplier = 0.45
	pillar_mat.metallic = 0.7
	pillar_mat.roughness = 0.35
	pillar.material_override = pillar_mat
	terminal_root.add_child(pillar)
	# Glowing dome on top
	var dome: MeshInstance3D = MeshInstance3D.new()
	var dome_mesh: SphereMesh = SphereMesh.new()
	dome_mesh.radius = 0.55
	dome_mesh.height = 0.7
	dome_mesh.is_hemisphere = true
	dome.mesh = dome_mesh
	dome.position = Vector3(0, 1.6, 0)
	var dome_mat: StandardMaterial3D = StandardMaterial3D.new()
	dome_mat.albedo_color = Color(0.95, 0.55, 0.20)
	dome_mat.emission_enabled = true
	dome_mat.emission = Color(1.0, 0.55, 0.10)
	dome_mat.emission_energy_multiplier = 2.5
	dome_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	dome.material_override = dome_mat
	terminal_root.add_child(dome)
	# Spinning ring decoration
	var ring: MeshInstance3D = MeshInstance3D.new()
	var ring_mesh: TorusMesh = TorusMesh.new()
	ring_mesh.inner_radius = 0.7
	ring_mesh.outer_radius = 0.85
	ring_mesh.rings = 16
	ring_mesh.ring_segments = 16
	ring.mesh = ring_mesh
	ring.position = Vector3(0, 1.2, 0)
	var ring_mat: StandardMaterial3D = StandardMaterial3D.new()
	ring_mat.albedo_color = Color(0.2, 0.6, 0.85)
	ring_mat.emission_enabled = true
	ring_mat.emission = Color(0.3, 0.7, 1.0)
	ring_mat.emission_energy_multiplier = 1.8
	ring_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	ring.material_override = ring_mat
	terminal_root.add_child(ring)
	# Spin animation
	var spin: Tween = create_tween().set_loops()
	spin.tween_property(ring, "rotation:y", TAU, 8.0)
	# Collision
	var body: StaticBody3D = StaticBody3D.new()
	var shape: CollisionShape3D = CollisionShape3D.new()
	var col_box: BoxShape3D = BoxShape3D.new()
	col_box.size = Vector3(1.4, 2.2, 1.4)
	shape.shape = col_box
	shape.position = Vector3(0, 1.1, 0)
	body.add_child(shape)
	terminal_root.add_child(body)


func _build_kiosks(geom: Node) -> void:
	## 4 holographic kiosks arranged around the data terminal
	var positions: Array[Vector3] = [
		Vector3(28, 0, -4), Vector3(36, 0, -4),
		Vector3(28, 0, 4), Vector3(36, 0, 4),
	]
	for pos in positions:
		var kiosk: Node3D = Node3D.new()
		kiosk.position = pos
		geom.add_child(kiosk)
		# Stand
		var stand: MeshInstance3D = MeshInstance3D.new()
		var stand_mesh: BoxMesh = BoxMesh.new()
		stand_mesh.size = Vector3(0.6, 0.8, 0.4)
		stand.mesh = stand_mesh
		stand.position = Vector3(0, 0.4, 0)
		var stand_mat: StandardMaterial3D = StandardMaterial3D.new()
		stand_mat.albedo_color = Color(0.12, 0.18, 0.26)
		stand_mat.emission_enabled = true
		stand_mat.emission = Color(0.15, 0.55, 0.75)
		stand_mat.emission_energy_multiplier = 0.4
		stand_mat.metallic = 0.6
		stand.material_override = stand_mat
		kiosk.add_child(stand)
		# Holographic panel
		var holo: MeshInstance3D = MeshInstance3D.new()
		var holo_mesh: BoxMesh = BoxMesh.new()
		holo_mesh.size = Vector3(0.7, 0.55, 0.04)
		holo.mesh = holo_mesh
		holo.position = Vector3(0, 1.1, 0)
		var holo_mat: StandardMaterial3D = StandardMaterial3D.new()
		holo_mat.albedo_color = Color(0.25, 0.7, 0.95, 0.55)
		holo_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		holo_mat.emission_enabled = true
		holo_mat.emission = Color(0.35, 0.8, 1.0)
		holo_mat.emission_energy_multiplier = 2.2
		holo_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		holo.material_override = holo_mat
		kiosk.add_child(holo)
		# Collision
		var body: StaticBody3D = StaticBody3D.new()
		var shape: CollisionShape3D = CollisionShape3D.new()
		var box: BoxShape3D = BoxShape3D.new()
		box.size = Vector3(0.7, 1.5, 0.5)
		shape.shape = box
		shape.position = Vector3(0, 0.75, 0)
		body.add_child(shape)
		kiosk.add_child(body)


func _build_queue_bollards(geom: Node) -> void:
	## Short cyan posts forming a queue path leading to the data terminal
	for i: int in range(0, 6):
		var bollard: MeshInstance3D = MeshInstance3D.new()
		var b_mesh: CylinderMesh = CylinderMesh.new()
		b_mesh.top_radius = 0.08
		b_mesh.bottom_radius = 0.10
		b_mesh.height = 0.7
		bollard.mesh = b_mesh
		bollard.position = Vector3(28 - i * 0.8, 0.35, 7)
		var b_mat: StandardMaterial3D = StandardMaterial3D.new()
		b_mat.albedo_color = Color(0.10, 0.18, 0.26)
		b_mat.emission_enabled = true
		b_mat.emission = Color(0.20, 0.65, 0.90)
		b_mat.emission_energy_multiplier = 0.7
		bollard.material_override = b_mat
		geom.add_child(bollard)


func _build_market_particles(geom: Node) -> void:
	## Ambient orange + cyan code dust drifting through the plaza
	var particles: GPUParticles3D = GPUParticles3D.new()
	particles.amount = 60
	particles.lifetime = 6.0
	particles.position = Vector3(32, 2.0, 0)
	var pmat: ParticleProcessMaterial = ParticleProcessMaterial.new()
	pmat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	pmat.emission_box_extents = Vector3(10, 1.5, 18)
	pmat.direction = Vector3(0, -1, 0)
	pmat.gravity = Vector3(0, -0.15, 0)
	pmat.initial_velocity_min = 0.1
	pmat.initial_velocity_max = 0.3
	pmat.scale_min = 0.05
	pmat.scale_max = 0.12
	pmat.color = Color(0.95, 0.55, 0.15, 0.6)
	particles.process_material = pmat
	var dot_mesh: SphereMesh = SphereMesh.new()
	dot_mesh.radius = 0.04
	dot_mesh.height = 0.08
	particles.draw_pass_1 = dot_mesh
	geom.add_child(particles)


func _build_plaza_lights(geom: Node) -> void:
	## 4 amber omni lights anchored at the kiosk corners
	for pos in [Vector3(28, 2.5, -4), Vector3(36, 2.5, -4), Vector3(28, 2.5, 4), Vector3(36, 2.5, 4)]:
		var light: OmniLight3D = OmniLight3D.new()
		light.position = pos
		light.light_color = Color(1.0, 0.65, 0.35)
		light.light_energy = 1.4
		light.omni_range = 8.0
		light.omni_attenuation = 1.5
		geom.add_child(light)


func _build_data_merchant_npc() -> void:
	## Place a stationary glowing orb NPC at the kiosk row. No dialogue
	## logic yet — that's a future task. For now: visible orb with name label.
	var merchant: Node3D = Node3D.new()
	merchant.name = "EastPlazaDataMerchant"
	merchant.position = Vector3(32, 0.5, -7)
	add_child(merchant)
	var body: MeshInstance3D = MeshInstance3D.new()
	var sphere: SphereMesh = SphereMesh.new()
	sphere.radius = 0.4
	sphere.height = 0.8
	body.mesh = sphere
	var mat: StandardMaterial3D = StandardMaterial3D.new()
	mat.albedo_color = Color(0.95, 0.55, 0.15)
	mat.emission_enabled = true
	mat.emission = Color(1.0, 0.6, 0.2)
	mat.emission_energy_multiplier = 0.8
	mat.metallic = 0.4
	body.material_override = mat
	merchant.add_child(body)
	# Floating name label
	var label: Label3D = Label3D.new()
	label.text = "Data Merchant"
	label.position = Vector3(0, 1.4, 0)
	label.modulate = Color(1.0, 0.7, 0.3)
	label.outline_modulate = Color(0, 0, 0, 0.8)
	label.outline_size = 6
	label.font_size = 24
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	merchant.add_child(label)


func _build_cipher_npc() -> void:
	## Epic-1 T2: Cipher data broker — colder violet NPC at far east edge
	var cipher: Node3D = Node3D.new()
	cipher.name = "EastPlazaCipher"
	cipher.position = Vector3(40, 0.5, 5)
	add_child(cipher)
	var body: MeshInstance3D = MeshInstance3D.new()
	var sphere: SphereMesh = SphereMesh.new()
	sphere.radius = 0.42
	sphere.height = 0.84
	body.mesh = sphere
	var mat: StandardMaterial3D = StandardMaterial3D.new()
	mat.albedo_color = Color(0.42, 0.20, 0.65)
	mat.emission_enabled = true
	mat.emission = Color(0.55, 0.25, 0.85)
	mat.emission_energy_multiplier = 0.7
	mat.metallic = 0.5
	body.material_override = mat
	cipher.add_child(body)
	# Floating eye
	var eye_mat: StandardMaterial3D = StandardMaterial3D.new()
	eye_mat.albedo_color = Color(0.95, 0.85, 1.0)
	eye_mat.emission_enabled = true
	eye_mat.emission = Color(0.85, 0.55, 1.0)
	eye_mat.emission_energy_multiplier = 2.5
	eye_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for side: float in [-0.13, 0.13]:
		var eye: MeshInstance3D = MeshInstance3D.new()
		var em: SphereMesh = SphereMesh.new()
		em.radius = 0.07
		em.height = 0.14
		eye.mesh = em
		eye.position = Vector3(side, 0.18, -0.32)
		eye.material_override = eye_mat
		body.add_child(eye)
	var label: Label3D = Label3D.new()
	label.text = "Cipher"
	label.position = Vector3(0, 1.4, 0)
	label.modulate = Color(0.85, 0.5, 1.0)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 6
	label.font_size = 24
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	cipher.add_child(label)


func _build_market_hall(geom: Node) -> void:
	## Epic-1 T3: procedural Market Hall NE of the data terminal
	var hall: Node3D = Node3D.new()
	hall.name = "EastPlazaMarketHall"
	hall.position = Vector3(38, 0, -10)
	geom.add_child(hall)
	# Walls (4 panels)
	var hall_mat: StandardMaterial3D = StandardMaterial3D.new()
	hall_mat.albedo_color = Color(0.18, 0.10, 0.04)
	hall_mat.emission_enabled = true
	hall_mat.emission = Color(0.85, 0.45, 0.15)
	hall_mat.emission_energy_multiplier = 0.45
	hall_mat.metallic = 0.4
	hall_mat.roughness = 0.55
	for side in [Vector3(0, 1.5, -3), Vector3(0, 1.5, 3), Vector3(-3, 1.5, 0), Vector3(3, 1.5, 0)]:
		var wall: MeshInstance3D = MeshInstance3D.new()
		var wmesh: BoxMesh = BoxMesh.new()
		# Walls along x-axis are wider in x; walls along z-axis are wider in z
		if abs(side.x) > 0.01:
			wmesh.size = Vector3(0.3, 3.0, 6.0)
		else:
			wmesh.size = Vector3(6.0, 3.0, 0.3)
		wall.mesh = wmesh
		wall.position = side
		wall.material_override = hall_mat
		hall.add_child(wall)
	# Roof (flat slab)
	var roof: MeshInstance3D = MeshInstance3D.new()
	var rmesh: BoxMesh = BoxMesh.new()
	rmesh.size = Vector3(6.4, 0.2, 6.4)
	roof.mesh = rmesh
	roof.position = Vector3(0, 3.1, 0)
	var roof_mat: StandardMaterial3D = StandardMaterial3D.new()
	roof_mat.albedo_color = Color(0.25, 0.15, 0.05)
	roof_mat.emission_enabled = true
	roof_mat.emission = Color(0.65, 0.35, 0.10)
	roof_mat.emission_energy_multiplier = 0.3
	roof_mat.metallic = 0.6
	roof.material_override = roof_mat
	hall.add_child(roof)
	# Marquee strip — horizontal cyan glow above the entrance
	var marquee: MeshInstance3D = MeshInstance3D.new()
	var qmesh: BoxMesh = BoxMesh.new()
	qmesh.size = Vector3(5.5, 0.4, 0.15)
	marquee.mesh = qmesh
	marquee.position = Vector3(0, 2.6, -3.05)
	var qmat: StandardMaterial3D = StandardMaterial3D.new()
	qmat.albedo_color = Color(0.15, 0.55, 0.75)
	qmat.emission_enabled = true
	qmat.emission = Color(0.30, 0.80, 1.0)
	qmat.emission_energy_multiplier = 2.5
	qmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	marquee.material_override = qmat
	hall.add_child(marquee)
	# Marquee text label
	var marquee_text: Label3D = Label3D.new()
	marquee_text.text = "DATA MARKET"
	marquee_text.position = Vector3(0, 2.6, -3.13)
	marquee_text.modulate = Color(1.0, 0.95, 0.85)
	marquee_text.outline_modulate = Color(0, 0.05, 0.15, 1.0)
	marquee_text.outline_size = 8
	marquee_text.font_size = 32
	marquee_text.no_depth_test = true
	hall.add_child(marquee_text)
	# Collision around the hall (simple box covering the perimeter)
	var body: StaticBody3D = StaticBody3D.new()
	for side in [Vector3(0, 1.5, -3), Vector3(0, 1.5, 3), Vector3(-3, 1.5, 0), Vector3(3, 1.5, 0)]:
		var shape: CollisionShape3D = CollisionShape3D.new()
		var cbox: BoxShape3D = BoxShape3D.new()
		if abs(side.x) > 0.01:
			cbox.size = Vector3(0.3, 3.0, 6.0)
		else:
			cbox.size = Vector3(6.0, 3.0, 0.3)
		shape.shape = cbox
		shape.position = side
		body.add_child(shape)
	hall.add_child(body)
	# Interior point light
	var light: OmniLight3D = OmniLight3D.new()
	light.position = Vector3(0, 2.4, 0)
	light.light_color = Color(1.0, 0.7, 0.4)
	light.light_energy = 1.6
	light.omni_range = 8.0
	light.omni_attenuation = 1.5
	hall.add_child(light)


func _attach_kiosk_interactables(geom: Node) -> void:
	## Epic-1 T4: add a small floating "[E] Browse" label above each plaza kiosk
	## (purely visual for now — full dialogue branching is a later epic).
	var positions: Array[Vector3] = [
		Vector3(28, 0, -4), Vector3(36, 0, -4),
		Vector3(28, 0, 4), Vector3(36, 0, 4),
	]
	for pos in positions:
		var label: Label3D = Label3D.new()
		label.text = "[E] Browse"
		label.position = pos + Vector3(0, 1.85, 0)
		label.modulate = Color(0.6, 0.95, 1.0)
		label.outline_modulate = Color(0, 0, 0, 0.85)
		label.outline_size = 6
		label.font_size = 18
		label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		label.no_depth_test = true
		geom.add_child(label)


func _build_market_chatter_zone(geom: Node) -> void:
	## Epic-1 T5: invisible Area3D over the plaza that fires "entered_plaza"
	## meta on the GameManager when the player enters. Future epics can hook
	## ambient market chatter SFX to this trigger.
	var area: Area3D = Area3D.new()
	area.name = "EastPlazaChatterZone"
	area.position = Vector3(32, 1.0, 0)
	var shape: CollisionShape3D = CollisionShape3D.new()
	var box: BoxShape3D = BoxShape3D.new()
	box.size = Vector3(20, 4, 30)
	shape.shape = box
	area.add_child(shape)
	area.collision_layer = 0
	area.collision_mask = 1  # scan player layer
	area.body_entered.connect(func(body: Node3D) -> void:
		if body.is_in_group(&"player"):
			GameManager.set_meta(&"in_east_plaza", true)
	)
	area.body_exited.connect(func(body: Node3D) -> void:
		if body.is_in_group(&"player"):
			GameManager.set_meta(&"in_east_plaza", false)
	)
	geom.add_child(area)


func _build_vendor_stall(geom: Node) -> void:
	## Epic-1 T6: open-air vendor stall at (29, 0, -8) — counter + canopy + 2 stools
	var stall: Node3D = Node3D.new()
	stall.name = "EastPlazaVendorStall"
	stall.position = Vector3(29, 0, -8)
	geom.add_child(stall)
	# Counter
	var counter: MeshInstance3D = MeshInstance3D.new()
	var c_mesh: BoxMesh = BoxMesh.new()
	c_mesh.size = Vector3(2.5, 1.0, 0.7)
	counter.mesh = c_mesh
	counter.position = Vector3(0, 0.5, 0)
	var counter_mat: StandardMaterial3D = StandardMaterial3D.new()
	counter_mat.albedo_color = Color(0.18, 0.10, 0.04)
	counter_mat.emission_enabled = true
	counter_mat.emission = Color(0.85, 0.45, 0.10)
	counter_mat.emission_energy_multiplier = 0.5
	counter_mat.metallic = 0.4
	counter.material_override = counter_mat
	stall.add_child(counter)
	# Canopy supports (4 thin posts)
	for x: float in [-1.1, 1.1]:
		for z: float in [-0.3, 0.3]:
			var post: MeshInstance3D = MeshInstance3D.new()
			var pmesh: CylinderMesh = CylinderMesh.new()
			pmesh.top_radius = 0.04
			pmesh.bottom_radius = 0.05
			pmesh.height = 2.5
			post.mesh = pmesh
			post.position = Vector3(x, 1.25, z)
			var pmat: StandardMaterial3D = StandardMaterial3D.new()
			pmat.albedo_color = Color(0.12, 0.18, 0.26)
			pmat.emission_enabled = true
			pmat.emission = Color(0.20, 0.55, 0.75)
			pmat.emission_energy_multiplier = 0.5
			pmat.metallic = 0.7
			post.material_override = pmat
			stall.add_child(post)
	# Canopy slab
	var canopy: MeshInstance3D = MeshInstance3D.new()
	var canopy_mesh: BoxMesh = BoxMesh.new()
	canopy_mesh.size = Vector3(2.7, 0.1, 1.0)
	canopy.mesh = canopy_mesh
	canopy.position = Vector3(0, 2.6, 0)
	var canopy_mat: StandardMaterial3D = StandardMaterial3D.new()
	canopy_mat.albedo_color = Color(0.30, 0.15, 0.05)
	canopy_mat.emission_enabled = true
	canopy_mat.emission = Color(0.95, 0.50, 0.15)
	canopy_mat.emission_energy_multiplier = 0.6
	canopy.material_override = canopy_mat
	stall.add_child(canopy)
	# Collision (counter blocks the player)
	var body: StaticBody3D = StaticBody3D.new()
	var shape: CollisionShape3D = CollisionShape3D.new()
	var col: BoxShape3D = BoxShape3D.new()
	col.size = Vector3(2.5, 1.0, 0.7)
	shape.shape = col
	shape.position = Vector3(0, 0.5, 0)
	body.add_child(shape)
	stall.add_child(body)


func _build_plaza_pedestrians(geom: Node) -> void:
	## Epic-1 T7: 5 ambient pedestrian orbs drifting on a procedural patrol
	var pedestrian_colors: Array[Color] = [
		Color(0.35, 0.65, 0.85),  # cyan
		Color(0.85, 0.55, 0.30),  # orange
		Color(0.55, 0.35, 0.75),  # violet
		Color(0.65, 0.85, 0.45),  # lime
		Color(0.85, 0.35, 0.45),  # coral
	]
	var spawn_positions: Array[Vector3] = [
		Vector3(28, 0.5, 7), Vector3(35, 0.5, 6),
		Vector3(38, 0.5, -2), Vector3(30, 0.5, -7),
		Vector3(33, 0.5, 8),
	]
	for i: int in pedestrian_colors.size():
		var ped: MeshInstance3D = MeshInstance3D.new()
		ped.name = "EastPlazaPedestrian_%d" % i
		var sphere: SphereMesh = SphereMesh.new()
		sphere.radius = 0.3
		sphere.height = 0.6
		ped.mesh = sphere
		ped.position = spawn_positions[i]
		var mat: StandardMaterial3D = StandardMaterial3D.new()
		mat.albedo_color = pedestrian_colors[i]
		mat.emission_enabled = true
		mat.emission = pedestrian_colors[i] * 1.3
		mat.emission_energy_multiplier = 0.5
		mat.metallic = 0.3
		ped.material_override = mat
		geom.add_child(ped)
		# Drift: bob + slow patrol along a small loop
		var tween: Tween = create_tween().set_loops()
		var orig_pos: Vector3 = ped.position
		var step1: Vector3 = orig_pos + Vector3(randf_range(-2, 2), 0, randf_range(-2, 2))
		var step2: Vector3 = orig_pos + Vector3(randf_range(-2, 2), 0, randf_range(-2, 2))
		tween.tween_property(ped, "position", step1, randf_range(4, 7)).set_ease(Tween.EASE_IN_OUT)
		tween.tween_property(ped, "position", step2, randf_range(4, 7)).set_ease(Tween.EASE_IN_OUT)
		tween.tween_property(ped, "position", orig_pos, randf_range(4, 7)).set_ease(Tween.EASE_IN_OUT)


func _build_loading_dock(geom: Node) -> void:
	## Epic-1 T8: loading dock sub-area at the far east edge — raised platform +
	## crates + warning stripes painted on the ground
	var dock: Node3D = Node3D.new()
	dock.name = "EastPlazaLoadingDock"
	dock.position = Vector3(42, 0, 0)
	geom.add_child(dock)
	# Raised platform
	var platform: MeshInstance3D = MeshInstance3D.new()
	var pmesh: BoxMesh = BoxMesh.new()
	pmesh.size = Vector3(3.5, 0.3, 6)
	platform.mesh = pmesh
	platform.position = Vector3(0, 0.15, 0)
	var pmat: StandardMaterial3D = StandardMaterial3D.new()
	pmat.albedo_color = Color(0.12, 0.18, 0.26)
	pmat.emission_enabled = true
	pmat.emission = Color(0.20, 0.55, 0.75)
	pmat.emission_energy_multiplier = 0.4
	pmat.metallic = 0.65
	platform.material_override = pmat
	dock.add_child(platform)
	# Warning stripes (alternating yellow/black emissive)
	for i: int in 5:
		var stripe: MeshInstance3D = MeshInstance3D.new()
		var smesh: BoxMesh = BoxMesh.new()
		smesh.size = Vector3(3.5, 0.01, 0.4)
		stripe.mesh = smesh
		stripe.position = Vector3(0, 0.32, -2.5 + i * 1.2)
		var smat: StandardMaterial3D = StandardMaterial3D.new()
		var stripe_color := Color(1.0, 0.85, 0.15) if i % 2 == 0 else Color(0.05, 0.05, 0.05)
		smat.albedo_color = stripe_color
		smat.emission_enabled = i % 2 == 0
		smat.emission = stripe_color
		smat.emission_energy_multiplier = 0.6
		smat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		stripe.material_override = smat
		dock.add_child(stripe)
	# Stacked crates (3 boxes)
	for i: int in 3:
		var crate: MeshInstance3D = MeshInstance3D.new()
		var cmesh: BoxMesh = BoxMesh.new()
		cmesh.size = Vector3(0.6, 0.6, 0.6)
		crate.mesh = cmesh
		crate.position = Vector3(-1.0, 0.6 + i * 0.6, -1.5)
		var cmat: StandardMaterial3D = StandardMaterial3D.new()
		cmat.albedo_color = Color(0.30, 0.18, 0.08)
		cmat.emission_enabled = true
		cmat.emission = Color(0.85, 0.50, 0.15)
		cmat.emission_energy_multiplier = 0.4
		cmat.metallic = 0.3
		crate.material_override = cmat
		dock.add_child(crate)
	# Collision for the platform
	var body: StaticBody3D = StaticBody3D.new()
	var shape: CollisionShape3D = CollisionShape3D.new()
	var col: BoxShape3D = BoxShape3D.new()
	col.size = Vector3(3.5, 0.3, 6)
	shape.shape = col
	shape.position = Vector3(0, 0.15, 0)
	body.add_child(shape)
	dock.add_child(body)


func _build_banner_flags(geom: Node) -> void:
	## Epic-1 T9: hanging banner flags between kiosk pairs
	var banner_pairs: Array = [
		[Vector3(28, 1.6, -4), Vector3(36, 1.6, -4)],
		[Vector3(28, 1.6, 4), Vector3(36, 1.6, 4)],
	]
	for pair in banner_pairs:
		var banner: MeshInstance3D = MeshInstance3D.new()
		var bmesh: BoxMesh = BoxMesh.new()
		var span: float = (pair[1] as Vector3).distance_to(pair[0] as Vector3)
		bmesh.size = Vector3(span, 0.5, 0.05)
		banner.mesh = bmesh
		banner.position = ((pair[0] as Vector3) + (pair[1] as Vector3)) * 0.5
		var bmat: StandardMaterial3D = StandardMaterial3D.new()
		bmat.albedo_color = Color(0.85, 0.30, 0.10, 0.85)
		bmat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		bmat.emission_enabled = true
		bmat.emission = Color(1.0, 0.45, 0.15)
		bmat.emission_energy_multiplier = 0.9
		bmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		banner.material_override = bmat
		geom.add_child(banner)
		# Slow sway animation
		var tween: Tween = create_tween().set_loops()
		tween.tween_property(banner, "rotation:z", 0.05, 2.5).set_ease(Tween.EASE_IN_OUT)
		tween.tween_property(banner, "rotation:z", -0.05, 2.5).set_ease(Tween.EASE_IN_OUT)


func _build_open_decals(geom: Node) -> void:
	## Epic-1 T10: cyan "OPEN" floor decals near each kiosk
	var positions: Array[Vector3] = [
		Vector3(28, 0.02, -2.6), Vector3(36, 0.02, -2.6),
		Vector3(28, 0.02, 2.6), Vector3(36, 0.02, 2.6),
	]
	for pos in positions:
		var decal: Label3D = Label3D.new()
		decal.text = "OPEN"
		decal.position = pos
		decal.rotation_degrees = Vector3(-90, 0, 0)
		decal.modulate = Color(0.30, 0.95, 1.0)
		decal.outline_modulate = Color(0, 0.05, 0.10, 0.95)
		decal.outline_size = 5
		decal.font_size = 22
		decal.no_depth_test = true
		decal.fixed_size = false
		geom.add_child(decal)


func _build_plaza_benches(geom: Node) -> void:
	## Epic-1 T11: 4 cyan park benches in the plaza
	var bench_mat: StandardMaterial3D = StandardMaterial3D.new()
	bench_mat.albedo_color = Color(0.10, 0.18, 0.26)
	bench_mat.emission_enabled = true
	bench_mat.emission = Color(0.20, 0.55, 0.75)
	bench_mat.emission_energy_multiplier = 0.55
	bench_mat.metallic = 0.6
	for pos in [Vector3(28, 0, 1), Vector3(36, 0, 1), Vector3(28, 0, -1.5), Vector3(36, 0, -1.5)]:
		var bench: Node3D = Node3D.new()
		bench.position = pos
		geom.add_child(bench)
		# Seat
		var seat: MeshInstance3D = MeshInstance3D.new()
		var sm: BoxMesh = BoxMesh.new()
		sm.size = Vector3(1.4, 0.08, 0.4)
		seat.mesh = sm
		seat.position = Vector3(0, 0.4, 0)
		seat.material_override = bench_mat
		bench.add_child(seat)
		# Backrest
		var back: MeshInstance3D = MeshInstance3D.new()
		var bm: BoxMesh = BoxMesh.new()
		bm.size = Vector3(1.4, 0.5, 0.06)
		back.mesh = bm
		back.position = Vector3(0, 0.65, -0.17)
		back.material_override = bench_mat
		bench.add_child(back)
		# Legs
		for x: float in [-0.6, 0.6]:
			var leg: MeshInstance3D = MeshInstance3D.new()
			var lm: BoxMesh = BoxMesh.new()
			lm.size = Vector3(0.06, 0.4, 0.34)
			leg.mesh = lm
			leg.position = Vector3(x, 0.2, 0)
			leg.material_override = bench_mat
			bench.add_child(leg)


func _build_plaza_planters(geom: Node) -> void:
	## Epic-1 T12: holographic planters — cyan rim + floating teal leaves
	var planter_positions: Array[Vector3] = [
		Vector3(26, 0, 6), Vector3(38, 0, 6),
		Vector3(26, 0, -6), Vector3(38, 0, -6),
	]
	for pos in planter_positions:
		var planter: Node3D = Node3D.new()
		planter.position = pos
		geom.add_child(planter)
		# Cyan rim cylinder
		var rim: MeshInstance3D = MeshInstance3D.new()
		var rmesh: CylinderMesh = CylinderMesh.new()
		rmesh.top_radius = 0.55
		rmesh.bottom_radius = 0.65
		rmesh.height = 0.5
		rim.mesh = rmesh
		rim.position = Vector3(0, 0.25, 0)
		var rmat: StandardMaterial3D = StandardMaterial3D.new()
		rmat.albedo_color = Color(0.10, 0.30, 0.40)
		rmat.emission_enabled = true
		rmat.emission = Color(0.20, 0.70, 0.95)
		rmat.emission_energy_multiplier = 0.7
		rim.material_override = rmat
		planter.add_child(rim)
		# Floating teal leaves (3 small spheres)
		for i: int in 3:
			var leaf: MeshInstance3D = MeshInstance3D.new()
			var lmesh: SphereMesh = SphereMesh.new()
			lmesh.radius = 0.18 - i * 0.02
			lmesh.height = lmesh.radius * 2.0
			leaf.mesh = lmesh
			var lpos := Vector3(randf_range(-0.3, 0.3), 0.7 + i * 0.25, randf_range(-0.3, 0.3))
			leaf.position = lpos
			var lmat: StandardMaterial3D = StandardMaterial3D.new()
			lmat.albedo_color = Color(0.20, 0.65, 0.55)
			lmat.emission_enabled = true
			lmat.emission = Color(0.25, 0.85, 0.70)
			lmat.emission_energy_multiplier = 1.2
			leaf.material_override = lmat
			planter.add_child(leaf)
			# Floating tween
			var tween: Tween = create_tween().set_loops()
			tween.tween_property(leaf, "position:y", lpos.y + 0.15, 2.0 + i * 0.3).set_ease(Tween.EASE_IN_OUT)
			tween.tween_property(leaf, "position:y", lpos.y, 2.0 + i * 0.3).set_ease(Tween.EASE_IN_OUT)


func _build_vending_machines(geom: Node) -> void:
	## Epic-1 T13: 3 vending machines along the south edge of the plaza
	for i: int in 3:
		var vm: Node3D = Node3D.new()
		vm.position = Vector3(31 + i * 1.4, 0, 11)
		geom.add_child(vm)
		# Body
		var body: MeshInstance3D = MeshInstance3D.new()
		var bm: BoxMesh = BoxMesh.new()
		bm.size = Vector3(1.0, 1.8, 0.6)
		body.mesh = bm
		body.position = Vector3(0, 0.9, 0)
		var body_mat: StandardMaterial3D = StandardMaterial3D.new()
		var hue := [Color(0.85, 0.20, 0.30), Color(0.20, 0.50, 0.85), Color(0.85, 0.65, 0.20)][i]
		body_mat.albedo_color = hue * 0.6
		body_mat.emission_enabled = true
		body_mat.emission = hue
		body_mat.emission_energy_multiplier = 0.55
		body_mat.metallic = 0.4
		body.material_override = body_mat
		vm.add_child(body)
		# Display screen
		var screen: MeshInstance3D = MeshInstance3D.new()
		var sm: BoxMesh = BoxMesh.new()
		sm.size = Vector3(0.85, 0.5, 0.05)
		screen.mesh = sm
		screen.position = Vector3(0, 1.4, -0.32)
		var smat: StandardMaterial3D = StandardMaterial3D.new()
		smat.albedo_color = Color(0.05, 0.10, 0.20)
		smat.emission_enabled = true
		smat.emission = Color(0.30, 0.85, 1.0)
		smat.emission_energy_multiplier = 1.6
		smat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		screen.material_override = smat
		vm.add_child(screen)
		# Collision
		var sb: StaticBody3D = StaticBody3D.new()
		var col_shape: CollisionShape3D = CollisionShape3D.new()
		var col_box: BoxShape3D = BoxShape3D.new()
		col_box.size = Vector3(1.0, 1.8, 0.6)
		col_shape.shape = col_box
		col_shape.position = Vector3(0, 0.9, 0)
		sb.add_child(col_shape)
		vm.add_child(sb)


func _build_security_drones(geom: Node) -> void:
	## Epic-1 T14: 2 small patrolling drones above the plaza
	var drone_paths: Array = [
		[Vector3(28, 3.5, -8), Vector3(36, 3.5, 8), Vector3(28, 3.5, 8), Vector3(36, 3.5, -8)],
		[Vector3(36, 3.0, -2), Vector3(28, 3.0, 2), Vector3(36, 3.0, 6), Vector3(28, 3.0, -6)],
	]
	for path in drone_paths:
		var drone: Node3D = Node3D.new()
		drone.position = (path[0] as Vector3)
		geom.add_child(drone)
		# Body — small disc
		var body: MeshInstance3D = MeshInstance3D.new()
		var bmesh: CylinderMesh = CylinderMesh.new()
		bmesh.top_radius = 0.18
		bmesh.bottom_radius = 0.18
		bmesh.height = 0.08
		body.mesh = bmesh
		var bmat: StandardMaterial3D = StandardMaterial3D.new()
		bmat.albedo_color = Color(0.10, 0.18, 0.26)
		bmat.emission_enabled = true
		bmat.emission = Color(0.20, 0.65, 0.85)
		bmat.emission_energy_multiplier = 1.0
		bmat.metallic = 0.7
		body.material_override = bmat
		drone.add_child(body)
		# Glowing scan eye
		var eye: MeshInstance3D = MeshInstance3D.new()
		var emesh: SphereMesh = SphereMesh.new()
		emesh.radius = 0.06
		emesh.height = 0.12
		eye.mesh = emesh
		eye.position = Vector3(0, -0.05, 0)
		var emat: StandardMaterial3D = StandardMaterial3D.new()
		emat.albedo_color = Color(1.0, 0.30, 0.30)
		emat.emission_enabled = true
		emat.emission = Color(1.0, 0.20, 0.20)
		emat.emission_energy_multiplier = 3.0
		emat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		eye.material_override = emat
		drone.add_child(eye)
		# Loop tween through the path waypoints
		var tween: Tween = create_tween().set_loops()
		for waypoint in path:
			tween.tween_property(drone, "position", waypoint, 4.0).set_ease(Tween.EASE_IN_OUT)


func _build_data_fountain(geom: Node) -> void:
	## Epic-1 T16: cyan data fountain at (32, 0, 12) — wide basin + central
	## column with rising particle stream
	var fountain: Node3D = Node3D.new()
	fountain.name = "EastPlazaDataFountain"
	fountain.position = Vector3(32, 0, 12)
	geom.add_child(fountain)
	# Wide basin (low cylinder)
	var basin: MeshInstance3D = MeshInstance3D.new()
	var basin_mesh: CylinderMesh = CylinderMesh.new()
	basin_mesh.top_radius = 1.4
	basin_mesh.bottom_radius = 1.5
	basin_mesh.height = 0.3
	basin.mesh = basin_mesh
	basin.position = Vector3(0, 0.15, 0)
	var basin_mat: StandardMaterial3D = StandardMaterial3D.new()
	basin_mat.albedo_color = Color(0.10, 0.18, 0.26)
	basin_mat.emission_enabled = true
	basin_mat.emission = Color(0.30, 0.85, 1.0)
	basin_mat.emission_energy_multiplier = 0.5
	basin_mat.metallic = 0.6
	basin.material_override = basin_mat
	fountain.add_child(basin)
	# Central column
	var column: MeshInstance3D = MeshInstance3D.new()
	var col_mesh: CylinderMesh = CylinderMesh.new()
	col_mesh.top_radius = 0.18
	col_mesh.bottom_radius = 0.25
	col_mesh.height = 1.2
	column.mesh = col_mesh
	column.position = Vector3(0, 0.9, 0)
	column.material_override = basin_mat
	fountain.add_child(column)
	# Rising "data stream" particle column
	var particles: GPUParticles3D = GPUParticles3D.new()
	particles.amount = 80
	particles.lifetime = 2.0
	particles.position = Vector3(0, 1.5, 0)
	var pmat: ParticleProcessMaterial = ParticleProcessMaterial.new()
	pmat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	pmat.emission_sphere_radius = 0.1
	pmat.direction = Vector3(0, 1, 0)
	pmat.spread = 8.0
	pmat.gravity = Vector3(0, -0.4, 0)
	pmat.initial_velocity_min = 1.5
	pmat.initial_velocity_max = 2.4
	pmat.scale_min = 0.05
	pmat.scale_max = 0.10
	pmat.color = Color(0.45, 0.95, 1.0, 0.85)
	particles.process_material = pmat
	var dot_mesh: SphereMesh = SphereMesh.new()
	dot_mesh.radius = 0.04
	dot_mesh.height = 0.08
	particles.draw_pass_1 = dot_mesh
	fountain.add_child(particles)
	# Collision around the basin
	var sb: StaticBody3D = StaticBody3D.new()
	var col_shape: CollisionShape3D = CollisionShape3D.new()
	var col_box: BoxShape3D = BoxShape3D.new()
	col_box.size = Vector3(3.0, 0.3, 3.0)
	col_shape.shape = col_box
	col_shape.position = Vector3(0, 0.15, 0)
	sb.add_child(col_shape)
	fountain.add_child(sb)


func _build_holo_billboards(geom: Node) -> void:
	## Epic-1 T17: 2 floating holographic billboards above the plaza
	for entry in [
		[Vector3(28, 5.0, 0), "EAST PLAZA", Color(1.0, 0.55, 0.15)],
		[Vector3(36, 5.5, 0), "DATA MARKET", Color(0.30, 0.85, 1.0)],
	]:
		var pos: Vector3 = entry[0]
		var text: String = entry[1]
		var hue: Color = entry[2]
		var board: Node3D = Node3D.new()
		board.position = pos
		geom.add_child(board)
		# Translucent panel backdrop
		var panel: MeshInstance3D = MeshInstance3D.new()
		var pmesh: BoxMesh = BoxMesh.new()
		pmesh.size = Vector3(3.5, 0.9, 0.05)
		panel.mesh = pmesh
		var pmat: StandardMaterial3D = StandardMaterial3D.new()
		pmat.albedo_color = Color(hue.r, hue.g, hue.b, 0.4)
		pmat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		pmat.emission_enabled = true
		pmat.emission = hue
		pmat.emission_energy_multiplier = 1.8
		pmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		panel.material_override = pmat
		board.add_child(panel)
		# Text label
		var label: Label3D = Label3D.new()
		label.text = text
		label.position = Vector3(0, 0, -0.05)
		label.modulate = Color(1, 1, 1)
		label.outline_modulate = Color(0, 0, 0, 0.95)
		label.outline_size = 8
		label.font_size = 36
		label.no_depth_test = true
		board.add_child(label)
		# Slow Y-bob animation
		var tween: Tween = create_tween().set_loops()
		tween.tween_property(board, "position:y", pos.y + 0.2, 3.0).set_ease(Tween.EASE_IN_OUT)
		tween.tween_property(board, "position:y", pos.y, 3.0).set_ease(Tween.EASE_IN_OUT)


func _build_neon_ads(geom: Node) -> void:
	## Epic-1 T18: 4 neon ad strips along the south plaza boundary
	for i: int in 4:
		var strip: MeshInstance3D = MeshInstance3D.new()
		var smesh: BoxMesh = BoxMesh.new()
		smesh.size = Vector3(2.2, 0.3, 0.04)
		strip.mesh = smesh
		strip.position = Vector3(26 + i * 4, 1.8, 14)
		var hues: Array[Color] = [
			Color(1.0, 0.20, 0.50),  # hot pink
			Color(0.30, 1.0, 0.50),  # neon green
			Color(0.20, 0.50, 1.0),  # electric blue
			Color(1.0, 0.85, 0.20),  # neon yellow
		]
		var smat: StandardMaterial3D = StandardMaterial3D.new()
		smat.albedo_color = hues[i]
		smat.emission_enabled = true
		smat.emission = hues[i]
		smat.emission_energy_multiplier = 2.5
		smat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		strip.material_override = smat
		geom.add_child(strip)
		# Pulse animation — alternating brightness
		var tween: Tween = create_tween().set_loops()
		tween.tween_property(smat, "emission_energy_multiplier", 4.0, 0.8 + i * 0.15).set_ease(Tween.EASE_IN_OUT)
		tween.tween_property(smat, "emission_energy_multiplier", 1.5, 0.8 + i * 0.15).set_ease(Tween.EASE_IN_OUT)


func _build_transit_pad(geom: Node) -> void:
	## Epic-1 T19: glowing transit pad at the SW corner of the plaza —
	## hexagonal landing pad with circular pulse animation
	var pad: Node3D = Node3D.new()
	pad.name = "EastPlazaTransitPad"
	pad.position = Vector3(24, 0, -10)
	geom.add_child(pad)
	# Hexagonal base
	var hex: MeshInstance3D = MeshInstance3D.new()
	var hex_mesh: CylinderMesh = CylinderMesh.new()
	hex_mesh.top_radius = 1.6
	hex_mesh.bottom_radius = 1.6
	hex_mesh.height = 0.15
	hex_mesh.radial_segments = 6
	hex.mesh = hex_mesh
	hex.position = Vector3(0, 0.075, 0)
	var hmat: StandardMaterial3D = StandardMaterial3D.new()
	hmat.albedo_color = Color(0.10, 0.20, 0.35)
	hmat.emission_enabled = true
	hmat.emission = Color(0.30, 0.85, 1.0)
	hmat.emission_energy_multiplier = 1.0
	hmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	hex.material_override = hmat
	pad.add_child(hex)
	# Pulsing emission
	var tween: Tween = create_tween().set_loops()
	tween.tween_property(hmat, "emission_energy_multiplier", 2.5, 1.5).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(hmat, "emission_energy_multiplier", 0.8, 1.5).set_ease(Tween.EASE_IN_OUT)
	# Vertical light beam
	var beam: MeshInstance3D = MeshInstance3D.new()
	var beam_mesh: CylinderMesh = CylinderMesh.new()
	beam_mesh.top_radius = 1.5
	beam_mesh.bottom_radius = 1.5
	beam_mesh.height = 8.0
	beam.mesh = beam_mesh
	beam.position = Vector3(0, 4.0, 0)
	var bmat: StandardMaterial3D = StandardMaterial3D.new()
	bmat.albedo_color = Color(0.30, 0.85, 1.0, 0.18)
	bmat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	bmat.emission_enabled = true
	bmat.emission = Color(0.40, 0.90, 1.0)
	bmat.emission_energy_multiplier = 0.5
	bmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	bmat.cull_mode = BaseMaterial3D.CULL_DISABLED
	beam.material_override = bmat
	pad.add_child(beam)


func _build_shop_signage(geom: Node) -> void:
	## Epic-1 T20: 4 vertical glow text labels above the kiosks naming
	## what each kiosk sells
	var sign_data: Array = [
		[Vector3(28, 2.4, -4), "CHIPS", Color(0.30, 0.85, 1.0)],
		[Vector3(36, 2.4, -4), "MODULES", Color(1.0, 0.55, 0.15)],
		[Vector3(28, 2.4, 4), "PROTOCOLS", Color(0.55, 0.35, 0.85)],
		[Vector3(36, 2.4, 4), "PROMPTS", Color(0.30, 1.0, 0.50)],
	]
	for entry in sign_data:
		var pos: Vector3 = entry[0]
		var text: String = entry[1]
		var hue: Color = entry[2]
		var label: Label3D = Label3D.new()
		label.text = text
		label.position = pos
		label.modulate = hue
		label.outline_modulate = Color(0, 0.05, 0.10, 0.95)
		label.outline_size = 7
		label.font_size = 26
		label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		label.no_depth_test = true
		geom.add_child(label)


func _build_info_totems(geom: Node) -> void:
	## Epic-1 T15: 3 info totem pillars near plaza entrances
	for pos in [Vector3(22, 0, 0), Vector3(32, 0, 12), Vector3(32, 0, -12)]:
		var totem: Node3D = Node3D.new()
		totem.position = pos
		geom.add_child(totem)
		# Tall pillar
		var pillar: MeshInstance3D = MeshInstance3D.new()
		var pmesh: CylinderMesh = CylinderMesh.new()
		pmesh.top_radius = 0.15
		pmesh.bottom_radius = 0.20
		pmesh.height = 2.4
		pillar.mesh = pmesh
		pillar.position = Vector3(0, 1.2, 0)
		var pmat: StandardMaterial3D = StandardMaterial3D.new()
		pmat.albedo_color = Color(0.10, 0.16, 0.22)
		pmat.emission_enabled = true
		pmat.emission = Color(0.20, 0.70, 0.95)
		pmat.emission_energy_multiplier = 0.5
		pmat.metallic = 0.7
		pillar.material_override = pmat
		totem.add_child(pillar)
		# Glowing top
		var top: MeshInstance3D = MeshInstance3D.new()
		var tmesh: SphereMesh = SphereMesh.new()
		tmesh.radius = 0.22
		tmesh.height = 0.44
		top.mesh = tmesh
		top.position = Vector3(0, 2.5, 0)
		var tmat: StandardMaterial3D = StandardMaterial3D.new()
		tmat.albedo_color = Color(0.30, 0.85, 1.0)
		tmat.emission_enabled = true
		tmat.emission = Color(0.40, 0.95, 1.0)
		tmat.emission_energy_multiplier = 2.5
		tmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		top.material_override = tmat
		totem.add_child(top)
		# Floating "i" info label
		var label: Label3D = Label3D.new()
		label.text = "ⓘ INFO"
		label.position = Vector3(0, 2.95, 0)
		label.modulate = Color(0.50, 0.95, 1.0)
		label.outline_modulate = Color(0, 0, 0, 0.85)
		label.outline_size = 6
		label.font_size = 18
		label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		totem.add_child(label)
		# Collision
		var sb: StaticBody3D = StaticBody3D.new()
		var col_shape: CollisionShape3D = CollisionShape3D.new()
		var col_box: BoxShape3D = BoxShape3D.new()
		col_box.size = Vector3(0.4, 2.7, 0.4)
		col_shape.shape = col_box
		col_shape.position = Vector3(0, 1.35, 0)
		sb.add_child(col_shape)
		totem.add_child(sb)
