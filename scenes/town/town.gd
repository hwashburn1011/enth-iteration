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
	# Epic-1 T21: cyan ground light strips guiding the path through the plaza
	_build_ground_light_strips(geom)
	# Epic-1 T22: 3 small maintenance bots sweeping the plaza floor
	_build_maintenance_bots(geom)
	# Epic-1 T23: rare sky data fragments falling slowly through the plaza
	_build_sky_data_fragments(geom)
	# Epic-1 T24: glowing power conduits running across the plaza ground
	_build_power_conduits(geom)
	# Epic-1 T25: plaza arch gateway at the western entrance
	_build_plaza_arch_gateway(geom)
	# Epic-1 T26: sparring arena sub-area at NE plaza corner
	_build_sparring_arena(geom)
	# Epic-1 T27: 2 practice dummies inside the sparring arena
	_build_practice_dummies(geom)
	# Epic-1 T28: tournament pit (sunken combat ring) at SE corner
	_build_tournament_pit(geom)
	# Epic-1 T29: crowd seating ring around the tournament pit
	_build_crowd_seating(geom)
	# Epic-1 T30: combat trainer NPC at the sparring arena edge
	_build_combat_trainer_npc()
	# Epic-1 T31: weapon rack with 4 displayed weapons
	_build_weapon_rack(geom)
	# Epic-1 T32: armored combat mannequin (humanoid display)
	_build_combat_mannequin(geom)
	# Epic-1 T33: padded training mat (warm-up zone)
	_build_training_mat(geom)
	# Epic-1 T34: scoreboard with HP/XP display panels
	_build_score_board(geom)
	# Epic-1 T35: cyan chalk technique lines painted on the spar zone floor
	_build_chalk_lines(geom)
	# Epic-1 T36: quest bulletin board with floating mock quest entries
	_build_quest_board(geom)
	# Epic-1 T37: data recycling bins (trash bins) at plaza corners
	_build_data_bins(geom)
	# Epic-1 T38: animated street lamps with on/off cycle
	_build_animated_lamps(geom)
	# Epic-1 T39: stairs ramp connecting plaza to loading dock
	_build_dock_ramp(geom)
	# Epic-1 T40: plaza sub-zone number markers (floating "1/5" etc)
	_build_zone_numbers(geom)
	# Epic-1 T41: tournament leaderboard near the pit
	_build_tournament_leaderboard(geom)
	# Epic-1 T42: portcullis-style gate at the tournament pit entrance
	_build_tournament_gate(geom)
	# Epic-1 T43: long perimeter seating wall around plaza edges
	_build_perimeter_seating(geom)
	# Epic-1 T44: 2 gate guard NPCs at the west arch
	_build_gate_guards()
	# Epic-1 T45: ambient cipher data orbs floating through the plaza
	_build_cipher_orbs(geom)
	# Epic-1 T46: holographic shop window displays at vendor row
	_build_holo_shop_windows(geom)
	# Epic-1 T47: translucent glass atrium roof above market core
	_build_atrium_roof(geom)
	# Epic-1 T48: small cafe seating cluster (tables + chairs) near vendors
	_build_cafe_seating(geom)
	# Epic-1 T49: secondary data-stream fountains flanking the main fountain
	_build_data_streams(geom)
	# Epic-1 T50: directional district signpost cluster at the plaza arch
	_build_district_signposts(geom)
	# Epic-1 T51: static onlooker crowd ringing the tournament pit
	_build_tournament_audience(geom)
	# Epic-1 T52: animated banner flags swaying on tall poles
	_build_waving_banners(geom)
	# Epic-1 T53: spinning turbine generator near the loading dock
	_build_power_generator(geom)
	# Epic-1 T54: scattered floating data shard collectibles
	_build_data_shards(geom)
	# Epic-1 T55: holographic AI statue centerpiece in the plaza
	_build_ai_statue(geom)
	# Epic-1 T56: covered merchant tent with fabric awning + crates
	_build_merchant_tent(geom)
	# Epic-1 T57: towering data archive landmark structure
	_build_data_archive(geom)
	# Epic-1 T58: combat dummy hit-effect VFX (sparks + recoil tweens)
	_build_dummy_hit_vfx(geom)
	# Epic-1 T59: 3 courier delivery drones flying patrol routes
	_build_courier_drones(geom)
	# Epic-1 T60: scattered ambient glow nodes pulsing on the ground
	_build_glow_nodes(geom)
	# Epic-1 T61: holographic minimap kiosk near plaza arch entrance
	_build_minimap_kiosk(geom)
	# Epic-1 T62: data ATM deposit terminal — currency exchange post
	_build_data_atm(geom)
	# Epic-1 T63: bug-catcher cage prop — captured glitchbug specimen
	_build_bug_cage(geom)
	# Epic-1 T64: 4 plaza speaker towers broadcasting ambient announcements
	_build_announcement_speakers(geom)
	# Epic-1 T65: small statue garden — 4 mini ancestor busts around AI statue
	_build_statue_garden(geom)
	# Epic-1 T66: large radial floor decals around plaza center
	_build_radial_floor_decals(geom)
	# Epic-1 T67: hovering food vendor cart
	_build_food_cart(geom)
	# Epic-1 T68: ambient coin/currency drop animations
	_build_coin_drops(geom)
	# Epic-1 T69: tournament pit overhead spotlights
	_build_pit_spotlights(geom)
	# Epic-1 T70: ambient floating data-flake snow particles over the plaza
	_build_data_snow(geom)
	# Epic-1 T71: rope barrier rings around sparring + tournament arenas
	_build_arena_rope_barriers(geom)
	# Epic-1 T72: floating "% OFF" sale signs over the kiosks
	_build_sale_signs(geom)
	# Epic-1 T73: intermittent NPC chatter speech bubbles
	_build_chatter_bubbles(geom)
	# Epic-1 T74: fountain mist particles rising from data fountain
	_build_fountain_mist(geom)
	# Epic-1 T75: tournament champion banner stretched across the pit
	_build_champion_banner(geom)
	# Epic-1 T76: locked east gate hinting at next district (Epic 2 hook)
	_build_east_gate(geom)
	# Epic-1 T77: distant skyline silhouette beyond east boundary
	_build_skyline_silhouette(geom)
	# Epic-1 T78: twinkling horizon city lights
	_build_horizon_lights(geom)
	# Epic-1 T79: border guard NPC at the east gate ("CLOSED" notice)
	_build_border_guard_npc()
	# Epic-1 T80: path teaser extending east toward the next district
	_build_eastbound_path(geom)
	# Epic-1 T81: glowing save shrine pillar in the plaza
	_build_save_shrine(geom)
	# Epic-1 T82: tall bell tower with hanging bell
	_build_bell_tower(geom)
	# Epic-1 T83: drifting data clouds overhead
	_build_data_clouds(geom)
	# Epic-1 T84: 2 holo-chess players seated at a table
	_build_chess_players(geom)
	# Epic-1 T85: plaza directory hologram listing shops + NPCs
	_build_plaza_directory(geom)
	# Epic-1 T86: combat respawn beacon (separate from save shrine)
	_build_respawn_beacon(geom)
	# Epic-1 T87: glitching ground crack VFX showing the simulation seams
	_build_ground_glitch(geom)
	# Epic-1 T88: 6 floating purchase receipts drifting between vendors
	_build_floating_receipts(geom)
	# Epic-1 T89: animated combat training golem punching air
	_build_combat_golem(geom)
	# Epic-1 T90: decorative weather dial kiosk
	_build_weather_dial(geom)
	# Epic-1 T91: 4 massive corner light pillars marking the plaza edge
	_build_corner_pillars(geom)
	# Epic-1 T92: patrolling maintenance bot collecting "trash"
	_build_maintenance_patrol(geom)
	# Epic-1 T93: large horizontal news ticker sign
	_build_news_ticker(geom)
	# Epic-1 T94: data spa relaxation pool with 3 floating bathers
	_build_data_spa(geom)
	# Epic-1 T95: ambient fireworks emitter over the plaza center
	_build_plaza_fireworks(geom)
	# Epic-1 T96: welcome arch banner spanning the west plaza entrance
	_build_welcome_arch_banner(geom)
	# Epic-1 T97: 4 colored spotlights illuminating the central AI statue
	_build_statue_spotlights(geom)
	# Epic-1 T98: ambient lighting + fill light tweak for the entire plaza
	_build_plaza_ambient_lighting(geom)
	# Epic-1 T99: Epic 1 completion plaque hidden near the east gate
	_build_epic1_plaque(geom)
	# Epic-1 T100: FINALE — massive central holographic Globbler landmark
	_build_central_globbler_landmark(geom)
	# === EPIC 2: District 2 — Stack Overflow Outskirts ===
	_build_district_2(geom)


func _build_district_2(geom: Node) -> void:
	## Epic 2 entry point — builds the second district east of the East Plaza
	## gate. Each task adds another _build_d2_X helper extending the area.
	# Epic-2 T1: unlock the east gate forcefield + push boundary further east
	_unlock_east_gate_and_extend(geom)
	# Epic-2 T2: District 2 ground floor (darker cracked digital terrain)
	_build_d2_ground(geom)
	# Epic-2 T3: D2 entrance arch with district name
	_build_d2_entrance_arch(geom)
	# Epic-2 T4: broken data tower landmark
	_build_d2_broken_tower(geom)
	# Epic-2 T5: wandering survivor NPC
	_build_d2_survivor_npc()
	# Epic-2 T6: crashed data ship wreckage landmark
	_build_d2_crashed_ship(geom)
	# Epic-2 T7: 3 glitch enemies pacing the perimeter (decorative)
	_build_d2_glitch_enemies(geom)
	# Epic-2 T8: 4 broken flickering street lamps
	_build_d2_flicker_lamps(geom)
	# Epic-2 T9: hardware junk pile (broken servers + cables)
	_build_d2_junk_pile(geom)
	# Epic-2 T10: abandoned roadside terminal kiosk
	_build_d2_abandoned_kiosk(geom)
	# Epic-2 T11: 4 ground impact craters with glowing rims
	_build_d2_craters(geom)
	# Epic-2 T12: overturned crate barricade
	_build_d2_barricade(geom)
	# Epic-2 T13: 5 toxic glowing puddles on the ground
	_build_d2_toxic_puddles(geom)
	# Epic-2 T14: ambient falling sparks raining from above
	_build_d2_falling_sparks(geom)
	# Epic-2 T15: scavenger NPC picking through junk
	_build_d2_scavenger_npc()
	# Epic-2 T16: combat trial pit (sunken arena with hazard rim)
	_build_d2_trial_pit(geom)
	# Epic-2 T17: mercenary tent camp with weapon rack
	_build_d2_mercenary_tent(geom)
	# Epic-2 T18: yellow caution stripes painted on the ground
	_build_d2_caution_stripes(geom)
	# Epic-2 T19: black market merchant NPC
	_build_d2_black_market_npc()
	# Epic-2 T20: hovering watchtower with sweeping searchlight
	_build_d2_watchtower(geom)
	# Epic-2 T21: data conduit pipes running across district
	_build_d2_data_conduits(geom)
	# Epic-2 T22: tall server farm tower with rack lights
	_build_d2_server_farm(geom)
	# Epic-2 T23: cracked highway billboard
	_build_d2_cracked_billboard(geom)
	# Epic-2 T24: shipping container clutter pile
	_build_d2_shipping_containers(geom)
	# Epic-2 T25: large wandering glitch beast (mini-boss visual)
	_build_d2_glitch_beast(geom)
	# Epic-2 T26: open-air repair workshop with welding sparks
	_build_d2_repair_workshop(geom)
	# Epic-2 T27: 4 holographic graffiti tags on walls + ground
	_build_d2_holo_graffiti(geom)
	# Epic-2 T28: scattered drone wreckage debris field
	_build_d2_drone_wreckage(geom)
	# Epic-2 T29: patrolling watchman NPC
	_build_d2_watchman_npc()
	# Epic-2 T30: 5 ground smoke vents
	_build_d2_smoke_vents(geom)
	# Epic-2 T31: cluster of glowing toxic barrels
	_build_d2_toxic_barrels(geom)
	# Epic-2 T32: half-buried giant mechanical arm
	_build_d2_buried_arm(geom)
	# Epic-2 T33: campfire pit with seated NPCs
	_build_d2_fire_pit(geom)
	# Epic-2 T34: wrecked hover-bike at the side of the road
	_build_d2_hoverbike_wreck(geom)
	# Epic-2 T35: vertical code stream waterfall
	_build_d2_code_waterfall(geom)
	# Epic-2 T36: horizontal dust storm particles drifting east
	_build_d2_dust_storm(geom)
	# Epic-2 T37: ancient data well / tap landmark
	_build_d2_data_well(geom)
	# Epic-2 T38: scrap metal tower of stacked machines
	_build_d2_scrap_tower(geom)
	# Epic-2 T39: scrap metal vendor cart on the road
	_build_d2_scrap_vendor_cart(geom)
	# Epic-2 T40: smuggler NPC hiding behind a container
	_build_d2_smuggler_npc()
	# Epic-2 T41: holographic enemy wireframe billboard
	_build_d2_holo_wireframe(geom)
	# Epic-2 T42: 3 caged glitchbug specimens stacked
	_build_d2_caged_bugs(geom)
	# Epic-2 T43: arcing electric generator with sparks
	_build_d2_arc_generator(geom)
	# Epic-2 T44: floating hover platform that bobs
	_build_d2_hover_platform(geom)
	# Epic-2 T45: arms dealer NPC with weapon display
	_build_d2_arms_dealer_npc()
	# Epic-2 T46: cracked road path tiles through the district
	_build_d2_cracked_road(geom)
	# Epic-2 T47: med tent / first aid station
	_build_d2_med_tent(geom)
	# Epic-2 T48: rusted satellite dish dish landmark
	_build_d2_satellite_dish(geom)
	# Epic-2 T49: caged fight arena with chain link walls
	_build_d2_cage_arena(geom)
	# Epic-2 T50: second mini-boss — Corrupted Titan
	_build_d2_corrupted_titan(geom)
	# Epic-2 T51: power substation with sparking transformer
	_build_d2_power_substation(geom)
	# Epic-2 T52: decaying corpse pile (lore element)
	_build_d2_corpse_pile(geom)
	# Epic-2 T53: wrecked hover-truck
	_build_d2_hover_truck_wreck(geom)
	# Epic-2 T54: faction graffiti wall + symbol
	_build_d2_faction_wall(geom)
	# Epic-2 T55: hacker NPC with floating screens
	_build_d2_hacker_npc()
	# Epic-2 T56: sniper NPC perched on a roof tower
	_build_d2_sniper_npc()
	# Epic-2 T57: locked treasure chest with combo lock
	_build_d2_treasure_chest(geom)
	# Epic-2 T58: small graveyard with marker stones
	_build_d2_graveyard(geom)
	# Epic-2 T59: floating data packet drift
	_build_d2_data_packets(geom)
	# Epic-2 T60: defensive turret base
	_build_d2_turret(geom)
	# Epic-2 T61: floating architecture debris field overhead
	_build_d2_floating_debris(geom)
	# Epic-2 T62: suspended power lines spanning the district
	_build_d2_power_lines(geom)
	# Epic-2 T63: quarantine zone with biohazard tape barrier
	_build_d2_quarantine_zone(geom)
	# Epic-2 T64: crashed lander pod with deployable ramp
	_build_d2_lander_pod(geom)
	# Epic-2 T65: info broker NPC at a small data table
	_build_d2_info_broker_npc()
	# Epic-2 T66: pile of glowing rune stones / data crystals
	_build_d2_rune_pile(geom)
	# Epic-2 T67: broken clock tower with frozen hands
	_build_d2_broken_clock(geom)
	# Epic-2 T68: 4 glowing directional arrow signs pointing to landmarks
	_build_d2_arrow_signs(geom)
	# Epic-2 T69: zipline cable strung between two scrap towers
	_build_d2_zipline(geom)
	# Epic-2 T70: mechanic NPC with wrenches
	_build_d2_mechanic_npc()
	# Epic-2 T71: parkour obstacle course with jump pads + climb walls
	_build_d2_parkour_course(geom)
	# Epic-2 T72: orbiting debris belt circling overhead
	_build_d2_debris_belt(geom)
	# Epic-2 T73: ancient ruins of broken pillars + partially intact arch
	_build_d2_ruins(geom)
	# Epic-2 T74: vertical reality tear (glitching rift)
	_build_d2_reality_tear(geom)
	# Epic-2 T75: glitch rain particles falling
	_build_d2_glitch_rain(geom)
	# Epic-2 T76: message terminal mailbox
	_build_d2_mail_terminal(geom)
	# Epic-2 T77: permanent trading post building
	_build_d2_trading_post(geom)
	# Epic-2 T78: abandoned playground (swing + slide)
	_build_d2_playground(geom)
	# Epic-2 T79: floating data archive scrolls
	_build_d2_data_scrolls(geom)
	# Epic-2 T80: enchanter NPC with orbiting runes
	_build_d2_enchanter_npc()
	# Epic-2 T81: hospital wing extension building
	_build_d2_hospital_wing(geom)
	# Epic-2 T82: garage with stored hover-vehicle inside
	_build_d2_garage(geom)
	# Epic-2 T83: library ruins with floating data tomes
	_build_d2_library_ruins(geom)
	# Epic-2 T84: 4 gargoyle statues guarding the trading post
	_build_d2_gargoyles(geom)
	# Epic-2 T85: boss arena teaser at the far east edge
	_build_d2_boss_arena_teaser(geom)
	# Epic-2 T86: second rival faction wall painted with a different symbol
	_build_d2_rival_faction_wall(geom)
	# Epic-2 T87: skill trainer NPC with practice target
	_build_d2_skill_trainer_npc()
	# Epic-2 T88: large ground fissure ravine
	_build_d2_ground_fissure(geom)
	# Epic-2 T89: scratch + skid marks decal cluster
	_build_d2_scratch_decals(geom)
	# Epic-2 T90: ammo crate stash
	_build_d2_ammo_stash(geom)
	# Epic-2 T91: cargo lift platform with vertical bob tween
	_build_d2_cargo_lift(geom)
	# Epic-2 T92: ambient ember particle drift across district
	_build_d2_ember_drift(geom)
	# Epic-2 T93: tomb of the unknown agent
	_build_d2_unknown_tomb(geom)
	# Epic-2 T94: stalker enemy patrolling slowly
	_build_d2_stalker_enemy(geom)
	# Epic-2 T95: fortification barriers around boss arena teaser
	_build_d2_boss_fortifications(geom)
	# Epic-2 T96: D2 welcome banner stretched between entrance pillars
	_build_d2_welcome_banner(geom)
	# Epic-2 T97: atmospheric red fog particles drifting low
	_build_d2_red_fog(geom)
	# Epic-2 T98: Epic 2 completion plaque
	_build_d2_epic2_plaque(geom)
	# Epic-2 T99: 3 high amber ambient fill lights
	_build_d2_ambient_lighting(geom)
	# Epic-2 T100: FINALE — massive hovering Glitch Herald landmark
	_build_d2_glitch_herald_landmark(geom)
	# === EPIC 3: Memory Vault — The Datacore Depths ===
	_build_district_3(geom)


func _build_district_3(geom: Node) -> void:
	## Epic 3 entry point — builds the third district east of D2's boss
	## arena. Violet/purple arcane theme, ancient code, awakened guardians.
	# Epic-3 T1: extend boundary further + D3 violet ground
	_extend_boundary_for_d3(geom)
	_build_d3_ground(geom)
	# Epic-3 T2: D3 entrance arch (memory vault doorway)
	_build_d3_entrance_arch(geom)
	# Epic-3 T3: giant data crystal landmark at D3 center
	_build_d3_great_crystal(geom)
	# Epic-3 T4: awakened guardian mini-boss
	_build_d3_awakened_guardian(geom)
	# Epic-3 T5: Lost Coder NPC
	_build_d3_lost_coder_npc()
	# Epic-3 T6: ancient pillar cluster
	_build_d3_ancient_pillars(geom)
	# Epic-3 T7: floating sigil glyphs
	_build_d3_sigil_glyphs(geom)
	# Epic-3 T8: small reading chamber alcove
	_build_d3_reading_chamber(geom)
	# Epic-3 T9: memory shard collectibles cluster
	_build_d3_memory_shards(geom)
	# Epic-3 T10: archivist NPC
	_build_d3_archivist_npc()
	# Epic-3 T11: drifting ancient codex pages
	_build_d3_codex_pages(geom)
	# Epic-3 T12: spiral knowledge staircase landmark
	_build_d3_spiral_stair(geom)
	# Epic-3 T13: wisp enemy (small floating glow)
	_build_d3_wisp_enemy(geom)
	# Epic-3 T14: Vault Keeper NPC
	_build_d3_vault_keeper_npc()
	# Epic-3 T15: small memory pool
	_build_d3_memory_pool(geom)
	# Epic-3 T16: 4 floating bookshelves with violet glow
	_build_d3_floating_bookshelves(geom)
	# Epic-3 T17: semicircle of stone benches around the great crystal
	_build_d3_stone_benches(geom)
	# Epic-3 T18: ritual circle ground pattern
	_build_d3_ritual_circle(geom)
	# Epic-3 T19: ancient war banners hanging from poles
	_build_d3_war_banners(geom)
	# Epic-3 T20: Acolyte NPC sitting cross-legged
	_build_d3_acolyte_npc()
	# Epic-3 T21: mana font fountain with rising sphere
	_build_d3_mana_font(geom)
	# Epic-3 T22: stone mausoleum building
	_build_d3_mausoleum(geom)
	# Epic-3 T23: floating crystal lantern cluster
	_build_d3_crystal_lanterns(geom)
	# Epic-3 T24: Sage NPC with crystal staff
	_build_d3_sage_npc()
	# Epic-3 T25: echo wraith enemy
	_build_d3_echo_wraith(geom)
	# Epic-3 T26: 4 small rune circle floor decals
	_build_d3_rune_decals(geom)
	# Epic-3 T27: sealed vault gates landmark
	_build_d3_sealed_gates(geom)
	# Epic-3 T28: 8 floating data spirits orbiting overhead
	_build_d3_data_spirits(geom)
	# Epic-3 T29: Oracle NPC
	_build_d3_oracle_npc()
	# Epic-3 T30: ambient violet mist particles
	_build_d3_violet_mist(geom)
	# Epic-3 T31: 3 floating archways drifting overhead
	_build_d3_floating_arches(geom)
	# Epic-3 T32: broken battle scar stone fragments
	_build_d3_battle_scars(geom)
	# Epic-3 T33: 3 tall memory obelisks
	_build_d3_memory_obelisks(geom)
	# Epic-3 T34: Phantom Warrior NPC
	_build_d3_phantom_warrior_npc()
	# Epic-3 T35: short illusion bridge
	_build_d3_illusion_bridge(geom)
	# Epic-3 T36: levitating runes ring around great crystal
	_build_d3_levitating_runes(geom)
	# Epic-3 T37: ancient observatory dome
	_build_d3_observatory_dome(geom)
	# Epic-3 T38: portal pad with rotating beams
	_build_d3_portal_pad(geom)
	# Epic-3 T39: Ritualist NPC
	_build_d3_ritualist_npc()
	# Epic-3 T40: 4 violet flame braziers
	_build_d3_violet_braziers(geom)
	# Epic-3 T41: spell circle puzzle with 4 colored runes
	_build_d3_spell_puzzle(geom)
	# Epic-3 T42: vertical floating platform staircase
	_build_d3_floating_stair(geom)
	# Epic-3 T43: chained ancient statue
	_build_d3_chained_statue(geom)
	# Epic-3 T44: Librarian NPC
	_build_d3_librarian_npc()
	# Epic-3 T45: 4 elemental wisps in 4 colors
	_build_d3_elemental_wisps(geom)
	# Epic-3 T46: large sky portal ring overhead
	_build_d3_sky_portal(geom)
	# Epic-3 T47: judgment dais with throne
	_build_d3_judgment_dais(geom)
	# Epic-3 T48: Echo Singer NPC
	_build_d3_echo_singer_npc()
	# Epic-3 T49: mana crystal cluster
	_build_d3_mana_crystals(geom)
	# Epic-3 T50: MEMORY ECHO 2nd mini-boss
	_build_d3_memory_echo(geom)
	# Epic-3 T51: ancient pool with floating fish
	_build_d3_ancient_pool(geom)
	# Epic-3 T52: tall hanging pendulum
	_build_d3_pendulum(geom)
	# Epic-3 T53: 3 prophecy stones
	_build_d3_prophecy_stones(geom)
	# Epic-3 T54: Apprentice child NPC
	_build_d3_apprentice_npc()
	# Epic-3 T55: ambient page rain particles
	_build_d3_page_rain(geom)
	# Epic-3 T56: alchemy table with bottles
	_build_d3_alchemy_table(geom)
	# Epic-3 T57: ancient sundial
	_build_d3_sundial(geom)
	# Epic-3 T58: grand library facade landmark
	_build_d3_library_facade(geom)
	# Epic-3 T59: starlight projector with ground stars
	_build_d3_starlight_projector(geom)
	# Epic-3 T60: floating data dragon enemy
	_build_d3_data_dragon(geom)
	# Epic-3 T61: healing fountain
	_build_d3_healing_fountain(geom)
	# Epic-3 T62: 3 study desks with scrolls
	_build_d3_study_desks(geom)
	# Epic-3 T63: hanging mage robes on a rack
	_build_d3_mage_robes(geom)
	# Epic-3 T64: Fortune Teller NPC
	_build_d3_fortune_teller_npc()
	# Epic-3 T65: 6 floating tarot cards
	_build_d3_tarot_cards(geom)
	# Epic-3 T66: hanging sky chimes
	_build_d3_sky_chimes(geom)
	# Epic-3 T67: 3 spirit altars
	_build_d3_spirit_altars(geom)
	# Epic-3 T68: floating crown landmark
	_build_d3_floating_crown(geom)
	# Epic-3 T69: grimoire stack
	_build_d3_grimoire_stack(geom)
	# Epic-3 T70: Monk NPC walking circular path
	_build_d3_monk_npc()
	# Epic-3 T71: Conjurer NPC with familiar
	_build_d3_conjurer_npc()
	# Epic-3 T72: ancient map wall
	_build_d3_map_wall(geom)
	# Epic-3 T73: floating dust orbs ambient
	_build_d3_dust_orbs(geom)
	# Epic-3 T74: spirit altar circle
	_build_d3_altar_circle(geom)
	# Epic-3 T75: mind crystal cluster
	_build_d3_mind_crystals(geom)
	# Epic-3 T76: ascending stone stairs to a high observation platform
	_build_d3_ascending_stairs(geom)
	# Epic-3 T77: grand telescope landmark
	_build_d3_grand_telescope(geom)
	# Epic-3 T78: hanging prayer chain mobile
	_build_d3_prayer_chains(geom)
	# Epic-3 T79: large dreamcatcher mobile
	_build_d3_dreamcatcher(geom)
	# Epic-3 T80: Starseer NPC
	_build_d3_starseer_npc()
	# Epic-3 T81: spell scrolls cluster
	_build_d3_spell_scrolls(geom)
	# Epic-3 T82: Cleric NPC
	_build_d3_cleric_npc()
	# Epic-3 T83: 3 ancient violet gargoyles
	_build_d3_ancient_gargoyles(geom)
	# Epic-3 T84: lone tall bell
	_build_d3_lone_bell(geom)
	# Epic-3 T85: DREAM EATER 3rd mini-boss
	_build_d3_dream_eater(geom)
	# Epic-3 T86: lectern with floating script
	_build_d3_lectern(geom)
	# Epic-3 T87: reflecting pool
	_build_d3_reflecting_pool(geom)
	# Epic-3 T88: cluster of mage staves
	_build_d3_staff_cluster(geom)
	# Epic-3 T89: Elder Mage NPC
	_build_d3_elder_mage_npc()
	# Epic-3 T90: 6 perimeter violet flame braziers
	_build_d3_perimeter_braziers(geom)
	# Epic-3 T91: astrolabe device on a stand
	_build_d3_astrolabe(geom)
	# Epic-3 T92: spell ingredient shelves
	_build_d3_ingredient_shelves(geom)
	# Epic-3 T93: floating planet model
	_build_d3_planet_model(geom)
	# Epic-3 T94: Time Keeper NPC
	_build_d3_time_keeper_npc()
	# Epic-3 T95: seeker trial puzzle pad
	_build_d3_seeker_trial(geom)
	# Epic-3 T96: D3 welcome banner stretched across entrance arch
	_build_d3_welcome_banner(geom)
	# Epic-3 T97: ambient violet fog drifting across D3
	_build_d3_atmosphere_fog(geom)
	# Epic-3 T98: Epic 3 completion plaque
	_build_d3_epic3_plaque(geom)
	# Epic-3 T99: 3 high violet ambient fill lights
	_build_d3_ambient_fills(geom)
	# Epic-3 T100: FINALE — massive Arcane Overseer landmark
	_build_d3_arcane_overseer_landmark(geom)
	# === EPIC 4: Bloom Cluster — The Sandbox Greenhouse ===
	_build_district_4(geom)


func _build_district_4(geom: Node) -> void:
	## Epic 4 entry point — Bloom Cluster, the green organic biome.
	# Epic-4 T1: extend boundary + D4 ground
	_extend_boundary_for_d4(geom)
	_build_d4_ground(geom)
	# Epic-4 T2: vine-covered entrance arch
	_build_d4_entrance_arch(geom)
	# Epic-4 T3: GREAT BLOOM landmark
	_build_d4_great_bloom(geom)
	# Epic-4 T4: friendly bloomling creature (decorative pet)
	_build_d4_bloomling(geom)
	# Epic-4 T5: Gardener NPC
	_build_d4_gardener_npc()
	# Epic-4 T6: bush cluster
	_build_d4_bush_cluster(geom)
	# Epic-4 T7: glowing mushroom forest
	_build_d4_mushroom_forest(geom)
	# Epic-4 T8: vine canopy overhead
	_build_d4_vine_canopy(geom)
	# Epic-4 T9: Botanist NPC
	_build_d4_botanist_npc()
	# Epic-4 T10: beehive with bee particles
	_build_d4_beehive(geom)
	# Epic-4 T11: meadow flowers
	_build_d4_meadow_flowers(geom)
	# Epic-4 T12: butterfly particles
	_build_d4_butterflies(geom)
	# Epic-4 T13: stone watering well
	_build_d4_watering_well(geom)
	# Epic-4 T14: Farmer NPC
	_build_d4_farmer_npc()
	# Epic-4 T15: straw scarecrow
	_build_d4_scarecrow(geom)
	# Epic-4 T16: 5 tree grove cluster
	_build_d4_tree_grove(geom)
	# Epic-4 T17: large apple tree with red apples
	_build_d4_apple_tree(geom)
	# Epic-4 T18: oval fish pond with circling fish
	_build_d4_fish_pond(geom)
	# Epic-4 T19: Fisherman NPC
	_build_d4_fisherman_npc()
	# Epic-4 T20: lily pads on the pond
	_build_d4_lily_pads(geom)
	# Epic-4 T21: glass greenhouse building
	_build_d4_greenhouse_building(geom)
	# Epic-4 T22: plant pot row
	_build_d4_plant_pot_row(geom)
	# Epic-4 T23: ladybug creature wandering
	_build_d4_ladybug_creature(geom)
	# Epic-4 T24: Chef NPC
	_build_d4_chef_npc()
	# Epic-4 T25: soup pot with steam
	_build_d4_soup_pot(geom)
	# Epic-4 T26: cracked stone path tiles
	_build_d4_stone_path(geom)
	# Epic-4 T27: windmill with rotating blades
	_build_d4_windmill(geom)
	# Epic-4 T28: wheat field grid
	_build_d4_wheat_field(geom)
	# Epic-4 T29: Miller NPC
	_build_d4_miller_npc()
	# Epic-4 T30: bread oven with smoke
	_build_d4_bread_oven(geom)
	# Epic-4 T31: octagonal gazebo
	_build_d4_gazebo(geom)
	# Epic-4 T32: hanging flower wreaths
	_build_d4_flower_wreaths(geom)
	# Epic-4 T33: stone bird bath
	_build_d4_bird_bath(geom)
	# Epic-4 T34: Storyteller NPC
	_build_d4_storyteller_npc()
	# Epic-4 T35: sleeping cat on cushion
	_build_d4_sleeping_cat(geom)
	# Epic-4 T36: picnic blanket spread with food
	_build_d4_picnic_blanket(geom)
	# Epic-4 T37: wooden vegetable cart
	_build_d4_veg_cart(geom)
	# Epic-4 T38: 3 garden gnome statues
	_build_d4_garden_gnomes(geom)
	# Epic-4 T39: Beekeeper NPC
	_build_d4_beekeeper_npc()
	# Epic-4 T40: honey jars cluster
	_build_d4_honey_jars(geom)
	# Epic-4 T41: compost heap
	_build_d4_compost_heap(geom)
	# Epic-4 T42: Painter NPC
	_build_d4_painter_npc()
	# Epic-4 T43: easel with canvas
	_build_d4_easel_canvas(geom)
	# Epic-4 T44: birdhouse on pole
	_build_d4_birdhouse(geom)
	# Epic-4 T45: hanging clothesline with sheets
	_build_d4_clothesline(geom)
	# Epic-4 T46: stone arch bridge over a stream
	_build_d4_stone_bridge(geom)
	# Epic-4 T47: small flowing stream
	_build_d4_small_stream(geom)
	# Epic-4 T48: friendly frog creature
	_build_d4_frog_creature(geom)
	# Epic-4 T49: Musician NPC with lute
	_build_d4_musician_npc()
	# Epic-4 T50: BLOOM GUARDIAN mini-boss
	_build_d4_bloom_guardian(geom)
	# Epic-4 T51: wooden stable building
	_build_d4_stable(geom)
	# Epic-4 T52: friendly horse creature
	_build_d4_horse(geom)
	# Epic-4 T53: Stableboy NPC
	_build_d4_stableboy_npc()
	# Epic-4 T54: hay loft above the stable
	_build_d4_hay_loft(geom)
	# Epic-4 T55: pile of hay bales
	_build_d4_hay_bales(geom)
	# Epic-4 T56: pumpkin patch with various sized pumpkins
	_build_d4_pumpkin_patch(geom)
	# Epic-4 T57: chicken coop wooden hut
	_build_d4_chicken_coop(geom)
	# Epic-4 T58: rooster + chickens pecking around
	_build_d4_chickens(geom)
	# Epic-4 T59: harvest crates stacked with crops
	_build_d4_harvest_crates(geom)
	# Epic-4 T60: berry bushes lining a path
	_build_d4_berry_bushes(geom)


const D4_CENTER := Vector3(220, 0, 0)


func _extend_boundary_for_d4(geom: Node) -> void:
	## Epic-4 T1a: push the east boundary wall from x=180 out to x=260.
	var east_wall: CSGBox3D = geom.get_node_or_null("BoundaryEast") as CSGBox3D
	if east_wall:
		east_wall.position.x = 260.0


func _build_d4_ground(geom: Node) -> void:
	## Epic-4 T1b: D4 ground — green organic floor extending from x=190 to
	## x=250. Uses a green grid shader variant.
	var plane: PlaneMesh = PlaneMesh.new()
	plane.size = Vector2(60, 40)
	var ground: MeshInstance3D = MeshInstance3D.new()
	ground.name = "D4Ground"
	ground.mesh = plane
	ground.position = Vector3(220, 0, 0)
	# Green organic grid shader
	var shader: Shader = Shader.new()
	shader.code = """
shader_type spatial;
render_mode unshaded;
uniform vec3 base_color = vec3(0.04, 0.10, 0.04);
uniform vec3 grid_color = vec3(0.30, 1.00, 0.40);
uniform float grid_scale = 1.4;
uniform float line_width = 0.04;

void fragment() {
	vec2 uv = UV * grid_scale * 30.0;
	vec2 grid = abs(fract(uv - 0.5) - 0.5) / fwidth(uv);
	float line = min(grid.x, grid.y);
	float strength = 1.0 - min(line, 1.0);
	vec3 color = mix(base_color, grid_color, strength * 0.85);
	ALBEDO = color;
}
"""
	var smat: ShaderMaterial = ShaderMaterial.new()
	smat.shader = shader
	ground.material_override = smat
	geom.add_child(ground)
	# Ground collision
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var bs: BoxShape3D = BoxShape3D.new()
	bs.size = Vector3(60, 0.10, 40)
	cs.shape = bs
	cs.position = Vector3(0, -0.05, 0)
	sb.add_child(cs)
	ground.add_child(sb)


func _build_d4_entrance_arch(geom: Node) -> void:
	## Epic-4 T2: a wide vine-covered organic arch reading "BLOOM CLUSTER".
	var arch: Node3D = Node3D.new()
	arch.name = "D4EntranceArch"
	arch.position = Vector3(192, 0, 0)
	geom.add_child(arch)
	# Wood material with green emission
	var wood_mat: StandardMaterial3D = StandardMaterial3D.new()
	wood_mat.albedo_color = Color(0.30, 0.18, 0.10)
	wood_mat.metallic = 0.10
	wood_mat.roughness = 0.65
	wood_mat.emission_enabled = true
	wood_mat.emission = Color(0.45, 1.0, 0.55)
	wood_mat.emission_energy_multiplier = 0.35
	# 2 wide pillars
	for sx: float in [-4.5, 4.5]:
		var pillar: MeshInstance3D = MeshInstance3D.new()
		var pmesh: CylinderMesh = CylinderMesh.new()
		pmesh.top_radius = 0.65
		pmesh.bottom_radius = 0.85
		pmesh.height = 8.0
		pillar.mesh = pmesh
		pillar.position = Vector3(sx, 4.0, 0)
		pillar.material_override = wood_mat
		arch.add_child(pillar)
		# Spiral vine wrapping the pillar (small green torus rings up the column)
		for v in 6:
			var vine: MeshInstance3D = MeshInstance3D.new()
			var vmesh: TorusMesh = TorusMesh.new()
			vmesh.inner_radius = 0.85
			vmesh.outer_radius = 0.95
			vine.mesh = vmesh
			vine.position = Vector3(sx, 1.0 + v * 1.20, 0)
			var vmat: StandardMaterial3D = StandardMaterial3D.new()
			vmat.albedo_color = Color(0.30, 0.65, 0.30)
			vmat.emission_enabled = true
			vmat.emission = Color(0.45, 1.0, 0.55)
			vmat.emission_energy_multiplier = 1.4
			vmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
			vine.material_override = vmat
			arch.add_child(vine)
		# Collision per pillar
		var sb: StaticBody3D = StaticBody3D.new()
		var cs: CollisionShape3D = CollisionShape3D.new()
		var cap: CapsuleShape3D = CapsuleShape3D.new()
		cap.radius = 0.95
		cap.height = 8.0
		cs.shape = cap
		cs.position = Vector3(sx, 4.0, 0)
		sb.add_child(cs)
		arch.add_child(sb)
	# Top wood crossbar
	var crossbar: MeshInstance3D = MeshInstance3D.new()
	var cm: BoxMesh = BoxMesh.new()
	cm.size = Vector3(11.0, 0.85, 1.40)
	crossbar.mesh = cm
	crossbar.position = Vector3(0, 8.40, 0)
	crossbar.material_override = wood_mat
	arch.add_child(crossbar)
	# Big bloom flower in center of crossbar — pink+yellow petals
	var bloom: MeshInstance3D = MeshInstance3D.new()
	var bm: SphereMesh = SphereMesh.new()
	bm.radius = 0.55
	bm.height = 1.10
	bloom.mesh = bm
	bloom.position = Vector3(0, 9.30, 0)
	var bmat: StandardMaterial3D = StandardMaterial3D.new()
	bmat.albedo_color = Color(1.0, 0.55, 0.85)
	bmat.emission_enabled = true
	bmat.emission = Color(1.0, 0.65, 0.85)
	bmat.emission_energy_multiplier = 2.4
	bmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	bloom.material_override = bmat
	arch.add_child(bloom)
	# Pulse the bloom
	var pulse: Tween = create_tween().set_loops()
	pulse.tween_property(bloom, "scale", Vector3(1.30, 1.30, 1.30), 1.6).set_ease(Tween.EASE_IN_OUT)
	pulse.tween_property(bloom, "scale", Vector3(0.85, 0.85, 0.85), 1.6).set_ease(Tween.EASE_IN_OUT)
	# District name on crossbar both sides
	for fz: float in [-0.71, 0.71]:
		var label: Label3D = Label3D.new()
		label.text = "BLOOM CLUSTER"
		label.position = Vector3(0, 8.40, fz)
		label.rotation = Vector3(0, deg_to_rad(0 if fz > 0 else 180), 0)
		label.modulate = Color(0.45, 1.0, 0.55)
		label.outline_modulate = Color(0, 0, 0, 0.85)
		label.outline_size = 6
		label.font_size = 26
		label.no_depth_test = true
		arch.add_child(label)


func _build_d4_great_bloom(geom: Node) -> void:
	## Epic-4 T3: GREAT BLOOM — a 10m-tall flower in the center. Massive
	## stem cylinder + multi-layered petal sphere arrangement on top.
	var bloom_root: Node3D = Node3D.new()
	bloom_root.name = "D4GreatBloom"
	bloom_root.position = D4_CENTER
	geom.add_child(bloom_root)
	# Tall thick stem cylinder
	var stem_mat: StandardMaterial3D = StandardMaterial3D.new()
	stem_mat.albedo_color = Color(0.20, 0.55, 0.20)
	stem_mat.emission_enabled = true
	stem_mat.emission = Color(0.45, 1.0, 0.55)
	stem_mat.emission_energy_multiplier = 0.85
	stem_mat.metallic = 0.20
	stem_mat.roughness = 0.55
	var stem: MeshInstance3D = MeshInstance3D.new()
	var smesh: CylinderMesh = CylinderMesh.new()
	smesh.top_radius = 0.45
	smesh.bottom_radius = 0.85
	smesh.height = 6.0
	stem.mesh = smesh
	stem.position = Vector3(0, 3.0, 0)
	stem.material_override = stem_mat
	bloom_root.add_child(stem)
	# Pivot for the flower head
	var pivot: Node3D = Node3D.new()
	pivot.position = Vector3(0, 6.0, 0)
	bloom_root.add_child(pivot)
	# Center sphere — glowing yellow pollen pod
	var center: MeshInstance3D = MeshInstance3D.new()
	var cm: SphereMesh = SphereMesh.new()
	cm.radius = 0.85
	cm.height = 1.70
	center.mesh = cm
	center.position = Vector3(0, 0, 0)
	var center_mat: StandardMaterial3D = StandardMaterial3D.new()
	center_mat.albedo_color = Color(1.0, 0.95, 0.30)
	center_mat.emission_enabled = true
	center_mat.emission = Color(1.0, 0.95, 0.30)
	center_mat.emission_energy_multiplier = 3.0
	center_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	center.material_override = center_mat
	pivot.add_child(center)
	# 8 large petal spheres arranged around the center
	var petal_mat: StandardMaterial3D = StandardMaterial3D.new()
	petal_mat.albedo_color = Color(1.0, 0.55, 0.85)
	petal_mat.emission_enabled = true
	petal_mat.emission = Color(1.0, 0.65, 0.85)
	petal_mat.emission_energy_multiplier = 1.8
	petal_mat.metallic = 0.20
	petal_mat.roughness = 0.30
	for i in 8:
		var angle: float = (float(i) / 8.0) * TAU
		var petal: MeshInstance3D = MeshInstance3D.new()
		var pm: SphereMesh = SphereMesh.new()
		pm.radius = 0.85
		pm.height = 1.70
		petal.mesh = pm
		petal.position = Vector3(cos(angle) * 1.55, 0, sin(angle) * 1.55)
		petal.scale = Vector3(0.85, 0.4, 1.20)
		petal.material_override = petal_mat
		pivot.add_child(petal)
	# Slow rotation
	var spin: Tween = create_tween().set_loops()
	spin.tween_property(pivot, "rotation:y", TAU, 16.0)
	# Bob in place
	var bob: Tween = create_tween().set_loops()
	bob.tween_property(pivot, "position:y", 6.55, 2.4).set_ease(Tween.EASE_IN_OUT)
	bob.tween_property(pivot, "position:y", 6.0, 2.4).set_ease(Tween.EASE_IN_OUT)
	# Real OmniLight from the bloom
	var light: OmniLight3D = OmniLight3D.new()
	light.position = Vector3(0, 0, 0)
	light.light_color = Color(1.0, 0.85, 0.65)
	light.light_energy = 3.0
	light.omni_range = 22.0
	pivot.add_child(light)
	# Sign
	var label: Label3D = Label3D.new()
	label.text = "GREAT BLOOM"
	label.position = Vector3(0, 8.85, 0)
	label.modulate = Color(1.0, 0.65, 0.85)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 6
	label.font_size = 22
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	bloom_root.add_child(label)
	# Collision around stem
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cap: CapsuleShape3D = CapsuleShape3D.new()
	cap.radius = 1.0
	cap.height = 6.0
	cs.shape = cap
	cs.position = Vector3(0, 3.0, 0)
	sb.add_child(cs)
	bloom_root.add_child(sb)


func _build_d4_bloomling(geom: Node) -> void:
	## Epic-4 T4: a friendly bloomling — small plant creature with a
	## flower head, 2 leaf arms, and a wandering hop animation.
	var bloomling: Node3D = Node3D.new()
	bloomling.name = "D4Bloomling"
	bloomling.position = D4_CENTER + Vector3(8, 0, 4)
	geom.add_child(bloomling)
	# Body — short capsule
	var body_mat: StandardMaterial3D = StandardMaterial3D.new()
	body_mat.albedo_color = Color(0.30, 0.65, 0.30)
	body_mat.emission_enabled = true
	body_mat.emission = Color(0.45, 1.0, 0.55)
	body_mat.emission_energy_multiplier = 0.85
	body_mat.metallic = 0.10
	body_mat.roughness = 0.55
	var body: MeshInstance3D = MeshInstance3D.new()
	var bmesh: SphereMesh = SphereMesh.new()
	bmesh.radius = 0.40
	bmesh.height = 0.65
	body.mesh = bmesh
	body.position = Vector3(0, 0.40, 0)
	body.material_override = body_mat
	bloomling.add_child(body)
	# Flower head — sphere
	var head: MeshInstance3D = MeshInstance3D.new()
	var hmesh: SphereMesh = SphereMesh.new()
	hmesh.radius = 0.30
	hmesh.height = 0.60
	head.mesh = hmesh
	head.position = Vector3(0, 0.95, 0)
	var hmat: StandardMaterial3D = StandardMaterial3D.new()
	hmat.albedo_color = Color(1.0, 0.55, 0.85)
	hmat.emission_enabled = true
	hmat.emission = Color(1.0, 0.65, 0.85)
	hmat.emission_energy_multiplier = 2.0
	hmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	head.material_override = hmat
	bloomling.add_child(head)
	# 2 white eye dots
	var eye_mat: StandardMaterial3D = StandardMaterial3D.new()
	eye_mat.albedo_color = Color(1, 1, 1)
	eye_mat.emission_enabled = true
	eye_mat.emission = Color(1, 1, 1)
	eye_mat.emission_energy_multiplier = 2.6
	eye_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for ex: float in [-0.10, 0.10]:
		var eye: MeshInstance3D = MeshInstance3D.new()
		var em: SphereMesh = SphereMesh.new()
		em.radius = 0.05
		em.height = 0.10
		eye.mesh = em
		eye.position = Vector3(ex, 0.95, 0.25)
		eye.material_override = eye_mat
		bloomling.add_child(eye)
	# 2 leaf arms — flat angled boxes
	for sx: float in [-1.0, 1.0]:
		var arm: MeshInstance3D = MeshInstance3D.new()
		var am: BoxMesh = BoxMesh.new()
		am.size = Vector3(0.40, 0.04, 0.20)
		arm.mesh = am
		arm.position = Vector3(sx * 0.55, 0.50, 0)
		arm.rotation = Vector3(0, 0, sign(sx) * deg_to_rad(20))
		arm.material_override = body_mat
		bloomling.add_child(arm)
	# Hop tween
	var hop: Tween = create_tween().set_loops()
	hop.tween_property(body, "position:y", 0.65, 0.4).set_ease(Tween.EASE_OUT)
	hop.tween_property(body, "position:y", 0.40, 0.30).set_ease(Tween.EASE_IN)
	hop.tween_interval(0.5)
	# Slow patrol path
	var origin: Vector3 = D4_CENTER + Vector3(8, 0, 4)
	var patrol: Tween = create_tween().set_loops()
	patrol.tween_property(bloomling, "position", origin + Vector3(4, 0, 4), 6.0).set_ease(Tween.EASE_IN_OUT)
	patrol.tween_property(bloomling, "position", origin + Vector3(-4, 0, 4), 6.0).set_ease(Tween.EASE_IN_OUT)
	patrol.tween_property(bloomling, "position", origin, 6.0).set_ease(Tween.EASE_IN_OUT)
	# Friendly name
	var label: Label3D = Label3D.new()
	label.text = "Bloomling"
	label.position = Vector3(0, 1.55, 0)
	label.modulate = Color(0.45, 1.0, 0.55)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 16
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	bloomling.add_child(label)


func _build_d4_gardener_npc() -> void:
	## Epic-4 T5: Gardener NPC — friendly green-robed figure with a small
	## watering can in one hand and a flower-petal hat.
	var slots: Node3D = get_node_or_null("%NPCSlots") as Node3D
	if slots == null:
		return
	var gardener: Node3D = Node3D.new()
	gardener.name = "D4Gardener"
	gardener.position = D4_CENTER + Vector3(-12, 0, 4)
	slots.add_child(gardener)
	# Robed body
	var bmat: StandardMaterial3D = StandardMaterial3D.new()
	bmat.albedo_color = Color(0.30, 0.65, 0.30)
	bmat.metallic = 0.20
	bmat.roughness = 0.55
	bmat.emission_enabled = true
	bmat.emission = Color(0.45, 1.0, 0.55)
	bmat.emission_energy_multiplier = 0.40
	var body: MeshInstance3D = MeshInstance3D.new()
	var bmesh: CapsuleMesh = CapsuleMesh.new()
	bmesh.radius = 0.45
	bmesh.height = 1.40
	body.mesh = bmesh
	body.position = Vector3(0, 0.70, 0)
	body.material_override = bmat
	gardener.add_child(body)
	# Head
	var head: MeshInstance3D = MeshInstance3D.new()
	var hmesh: SphereMesh = SphereMesh.new()
	hmesh.radius = 0.36
	hmesh.height = 0.65
	head.mesh = hmesh
	head.position = Vector3(0, 1.55, 0)
	head.material_override = bmat
	gardener.add_child(head)
	# Petal hat (3 layered torus)
	var hat_mat: StandardMaterial3D = StandardMaterial3D.new()
	hat_mat.albedo_color = Color(1.0, 0.55, 0.85)
	hat_mat.emission_enabled = true
	hat_mat.emission = Color(1.0, 0.65, 0.85)
	hat_mat.emission_energy_multiplier = 1.4
	hat_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for i in 3:
		var petal: MeshInstance3D = MeshInstance3D.new()
		var pm: TorusMesh = TorusMesh.new()
		pm.inner_radius = 0.30 - i * 0.05
		pm.outer_radius = 0.45 - i * 0.05
		petal.mesh = pm
		petal.position = Vector3(0, 1.85 + i * 0.10, 0)
		petal.material_override = hat_mat
		gardener.add_child(petal)
	# 2 brown eyes
	var eye_mat: StandardMaterial3D = StandardMaterial3D.new()
	eye_mat.albedo_color = Color(0.30, 0.18, 0.10)
	eye_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for ex: float in [-0.10, 0.10]:
		var eye: MeshInstance3D = MeshInstance3D.new()
		var em: SphereMesh = SphereMesh.new()
		em.radius = 0.05
		em.height = 0.10
		eye.mesh = em
		eye.position = Vector3(ex, 1.55, 0.32)
		eye.material_override = eye_mat
		gardener.add_child(eye)
	# Watering can held in front (small box + spout)
	var can_mat: StandardMaterial3D = StandardMaterial3D.new()
	can_mat.albedo_color = Color(0.55, 0.55, 0.65)
	can_mat.metallic = 0.85
	can_mat.roughness = 0.30
	var can: MeshInstance3D = MeshInstance3D.new()
	var cm: BoxMesh = BoxMesh.new()
	cm.size = Vector3(0.30, 0.30, 0.30)
	can.mesh = cm
	can.position = Vector3(0.45, 0.85, 0.30)
	can.material_override = can_mat
	gardener.add_child(can)
	# Spout cylinder
	var spout: MeshInstance3D = MeshInstance3D.new()
	var sm: CylinderMesh = CylinderMesh.new()
	sm.top_radius = 0.04
	sm.bottom_radius = 0.06
	sm.height = 0.40
	spout.mesh = sm
	spout.position = Vector3(0.65, 0.95, 0.30)
	spout.rotation = Vector3(0, 0, deg_to_rad(60))
	spout.material_override = can_mat
	gardener.add_child(spout)
	# Name billboard
	var label: Label3D = Label3D.new()
	label.text = "Gardener"
	label.position = Vector3(0, 2.45, 0)
	label.modulate = Color(0.45, 1.0, 0.55)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 18
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	gardener.add_child(label)


func _build_d4_bush_cluster(geom: Node) -> void:
	## Epic-4 T6: 8 round green bushes scattered across the district.
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 277
	for i in 8:
		var bush: MeshInstance3D = MeshInstance3D.new()
		bush.name = "D4Bush_%d" % i
		var bm: SphereMesh = SphereMesh.new()
		bm.radius = rng.randf_range(0.55, 0.95)
		bm.height = bm.radius * 2
		bush.mesh = bm
		bush.position = D4_CENTER + Vector3(rng.randf_range(-22, 22), bm.radius * 0.85, rng.randf_range(-16, 16))
		var bmat: StandardMaterial3D = StandardMaterial3D.new()
		bmat.albedo_color = Color(0.20, 0.55, 0.20)
		bmat.emission_enabled = true
		bmat.emission = Color(0.45, 1.0, 0.45)
		bmat.emission_energy_multiplier = 0.55
		bmat.metallic = 0.10
		bmat.roughness = 0.65
		bush.material_override = bmat
		geom.add_child(bush)
		var sb: StaticBody3D = StaticBody3D.new()
		var cs: CollisionShape3D = CollisionShape3D.new()
		var cap: CapsuleShape3D = CapsuleShape3D.new()
		cap.radius = bm.radius
		cap.height = bm.radius * 2
		cs.shape = cap
		sb.add_child(cs)
		bush.add_child(sb)


func _build_d4_mushroom_forest(geom: Node) -> void:
	## Epic-4 T7: 8 glowing mushrooms with bioluminescent caps.
	var positions: Array[Vector3] = [
		D4_CENTER + Vector3(-15, 0, 8),
		D4_CENTER + Vector3(-13, 0, 10),
		D4_CENTER + Vector3(-11, 0, 9),
		D4_CENTER + Vector3(-14, 0, 12),
		D4_CENTER + Vector3(-16, 0, 11),
		D4_CENTER + Vector3(-12, 0, 13),
		D4_CENTER + Vector3(-10, 0, 11),
		D4_CENTER + Vector3(-15, 0, 14),
	]
	var cap_colors: Array[Color] = [
		Color(0.55, 0.95, 1.0),
		Color(1.0, 0.55, 1.0),
		Color(0.45, 1.0, 0.55),
		Color(1.0, 0.95, 0.30),
		Color(1.0, 0.55, 0.20),
		Color(0.85, 0.40, 1.0),
		Color(0.55, 0.95, 1.0),
		Color(1.0, 0.30, 0.55),
	]
	for i in positions.size():
		var shroom: Node3D = Node3D.new()
		shroom.name = "D4Mushroom_%d" % i
		shroom.position = positions[i]
		geom.add_child(shroom)
		var height: float = 0.55 + (i % 3) * 0.30
		var stem: MeshInstance3D = MeshInstance3D.new()
		var sm: CylinderMesh = CylinderMesh.new()
		sm.top_radius = 0.10
		sm.bottom_radius = 0.14
		sm.height = height
		stem.mesh = sm
		stem.position = Vector3(0, height * 0.5, 0)
		var smat: StandardMaterial3D = StandardMaterial3D.new()
		smat.albedo_color = Color(0.95, 0.95, 0.85)
		smat.metallic = 0.10
		smat.roughness = 0.65
		smat.emission_enabled = true
		smat.emission = Color(1.0, 1.0, 0.85)
		smat.emission_energy_multiplier = 0.55
		stem.material_override = smat
		shroom.add_child(stem)
		var cap: MeshInstance3D = MeshInstance3D.new()
		var cm: SphereMesh = SphereMesh.new()
		cm.radius = 0.30 + (i % 2) * 0.10
		cm.height = cm.radius
		cap.mesh = cm
		cap.position = Vector3(0, height + cm.radius * 0.4, 0)
		cap.scale = Vector3(1.0, 0.55, 1.0)
		var cmat: StandardMaterial3D = StandardMaterial3D.new()
		cmat.albedo_color = cap_colors[i]
		cmat.emission_enabled = true
		cmat.emission = cap_colors[i]
		cmat.emission_energy_multiplier = 2.4
		cmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		cap.material_override = cmat
		shroom.add_child(cap)


func _build_d4_vine_canopy(geom: Node) -> void:
	## Epic-4 T8: overhead vine canopy at 5m altitude.
	var canopy: Node3D = Node3D.new()
	canopy.name = "D4VineCanopy"
	canopy.position = D4_CENTER + Vector3(0, 5.0, 0)
	geom.add_child(canopy)
	var vine_mat: StandardMaterial3D = StandardMaterial3D.new()
	vine_mat.albedo_color = Color(0.20, 0.55, 0.20)
	vine_mat.emission_enabled = true
	vine_mat.emission = Color(0.45, 1.0, 0.45)
	vine_mat.emission_energy_multiplier = 0.85
	vine_mat.metallic = 0.10
	vine_mat.roughness = 0.65
	for i in 3:
		var vine: MeshInstance3D = MeshInstance3D.new()
		var vm: CylinderMesh = CylinderMesh.new()
		vm.top_radius = 0.15
		vm.bottom_radius = 0.15
		vm.height = 12.0
		vine.mesh = vm
		vine.position = Vector3(0, 0, -8 + i * 8)
		vine.rotation = Vector3(0, 0, deg_to_rad(90))
		vine.material_override = vine_mat
		canopy.add_child(vine)
	for i in 3:
		var vine: MeshInstance3D = MeshInstance3D.new()
		var vm: CylinderMesh = CylinderMesh.new()
		vm.top_radius = 0.15
		vm.bottom_radius = 0.15
		vm.height = 12.0
		vine.mesh = vm
		vine.position = Vector3(-8 + i * 8, 0.30, 0)
		vine.rotation = Vector3(deg_to_rad(90), 0, 0)
		vine.material_override = vine_mat
		canopy.add_child(vine)
	for i in 12:
		var leaf: MeshInstance3D = MeshInstance3D.new()
		var lm: PrismMesh = PrismMesh.new()
		lm.size = Vector3(0.30, 0.55, 0.10)
		leaf.mesh = lm
		leaf.position = Vector3(randf_range(-8, 8), -0.55, randf_range(-8, 8))
		leaf.rotation = Vector3(deg_to_rad(180), randf() * TAU, 0)
		leaf.material_override = vine_mat
		canopy.add_child(leaf)


func _build_d4_botanist_npc() -> void:
	## Epic-4 T9: Botanist NPC with green coat and magnifying glass.
	var slots: Node3D = get_node_or_null("%NPCSlots") as Node3D
	if slots == null:
		return
	var bot: Node3D = Node3D.new()
	bot.name = "D4Botanist"
	bot.position = D4_CENTER + Vector3(-12, 0, 12)
	slots.add_child(bot)
	var bmat: StandardMaterial3D = StandardMaterial3D.new()
	bmat.albedo_color = Color(0.30, 0.65, 0.30)
	bmat.metallic = 0.20
	bmat.roughness = 0.55
	bmat.emission_enabled = true
	bmat.emission = Color(0.45, 1.0, 0.45)
	bmat.emission_energy_multiplier = 0.40
	var body: MeshInstance3D = MeshInstance3D.new()
	var bmesh: CapsuleMesh = CapsuleMesh.new()
	bmesh.radius = 0.42
	bmesh.height = 1.30
	body.mesh = bmesh
	body.position = Vector3(0, 0.70, 0)
	body.material_override = bmat
	bot.add_child(body)
	var head: MeshInstance3D = MeshInstance3D.new()
	var hmesh: SphereMesh = SphereMesh.new()
	hmesh.radius = 0.36
	hmesh.height = 0.65
	head.mesh = hmesh
	head.position = Vector3(0, 1.55, 0)
	var hmat: StandardMaterial3D = StandardMaterial3D.new()
	hmat.albedo_color = Color(0.85, 0.65, 0.45)
	head.material_override = hmat
	bot.add_child(head)
	# Glasses
	var glass_mat: StandardMaterial3D = StandardMaterial3D.new()
	glass_mat.albedo_color = Color(0.08, 0.08, 0.10)
	glass_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for ex: float in [-0.13, 0.13]:
		var glass: MeshInstance3D = MeshInstance3D.new()
		var gm: TorusMesh = TorusMesh.new()
		gm.inner_radius = 0.06
		gm.outer_radius = 0.10
		glass.mesh = gm
		glass.position = Vector3(ex, 1.55, 0.32)
		glass.rotation = Vector3(deg_to_rad(90), 0, 0)
		glass.material_override = glass_mat
		bot.add_child(glass)
	# Magnifying glass
	var handle: MeshInstance3D = MeshInstance3D.new()
	var ham: CylinderMesh = CylinderMesh.new()
	ham.top_radius = 0.04
	ham.bottom_radius = 0.04
	ham.height = 0.40
	handle.mesh = ham
	handle.position = Vector3(0.40, 0.85, 0.30)
	handle.rotation = Vector3(0, 0, deg_to_rad(-25))
	var hand_mat: StandardMaterial3D = StandardMaterial3D.new()
	hand_mat.albedo_color = Color(0.30, 0.18, 0.10)
	handle.material_override = hand_mat
	bot.add_child(handle)
	var lens: MeshInstance3D = MeshInstance3D.new()
	var lm: TorusMesh = TorusMesh.new()
	lm.inner_radius = 0.10
	lm.outer_radius = 0.18
	lens.mesh = lm
	lens.position = Vector3(0.55, 1.20, 0.30)
	var lmat: StandardMaterial3D = StandardMaterial3D.new()
	lmat.albedo_color = Color(0.85, 0.65, 0.30)
	lmat.metallic = 0.85
	lmat.emission_enabled = true
	lmat.emission = Color(1.0, 0.85, 0.30)
	lmat.emission_energy_multiplier = 0.85
	lens.material_override = lmat
	bot.add_child(lens)
	var label: Label3D = Label3D.new()
	label.text = "Botanist"
	label.position = Vector3(0, 2.20, 0)
	label.modulate = Color(0.45, 1.0, 0.55)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 18
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	bot.add_child(label)


func _build_d4_beehive(geom: Node) -> void:
	## Epic-4 T10: hanging beehive with bee particles.
	var hive: Node3D = Node3D.new()
	hive.name = "D4Beehive"
	hive.position = D4_CENTER + Vector3(15, 0, 12)
	geom.add_child(hive)
	var wood_mat: StandardMaterial3D = StandardMaterial3D.new()
	wood_mat.albedo_color = Color(0.30, 0.18, 0.10)
	wood_mat.metallic = 0.10
	wood_mat.roughness = 0.65
	var post: MeshInstance3D = MeshInstance3D.new()
	var pm: CylinderMesh = CylinderMesh.new()
	pm.top_radius = 0.18
	pm.bottom_radius = 0.30
	pm.height = 4.0
	post.mesh = pm
	post.position = Vector3(0, 2.0, 0)
	post.material_override = wood_mat
	hive.add_child(post)
	var branch: MeshInstance3D = MeshInstance3D.new()
	var bm: CylinderMesh = CylinderMesh.new()
	bm.top_radius = 0.10
	bm.bottom_radius = 0.10
	bm.height = 1.40
	branch.mesh = bm
	branch.position = Vector3(0.55, 3.85, 0)
	branch.rotation = Vector3(0, 0, deg_to_rad(90))
	branch.material_override = wood_mat
	hive.add_child(branch)
	var hive_mat: StandardMaterial3D = StandardMaterial3D.new()
	hive_mat.albedo_color = Color(0.85, 0.65, 0.20)
	hive_mat.emission_enabled = true
	hive_mat.emission = Color(1.0, 0.75, 0.25)
	hive_mat.emission_energy_multiplier = 0.85
	for i in 3:
		var seg: MeshInstance3D = MeshInstance3D.new()
		var sm: SphereMesh = SphereMesh.new()
		sm.radius = 0.40 - i * 0.05
		sm.height = sm.radius
		seg.mesh = sm
		seg.position = Vector3(1.20, 3.30 - i * 0.40, 0)
		seg.scale = Vector3(1.0, 0.65, 1.0)
		seg.material_override = hive_mat
		hive.add_child(seg)
	var bees: GPUParticles3D = GPUParticles3D.new()
	bees.amount = 25
	bees.lifetime = 4.0
	bees.position = Vector3(1.20, 3.0, 0)
	var pmat: ParticleProcessMaterial = ParticleProcessMaterial.new()
	pmat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	pmat.emission_sphere_radius = 0.85
	pmat.spread = 180.0
	pmat.initial_velocity_min = 0.30
	pmat.initial_velocity_max = 0.85
	pmat.scale_min = 0.04
	pmat.scale_max = 0.08
	pmat.color = Color(1.0, 0.95, 0.30, 1.0)
	bees.process_material = pmat
	var bee_mesh: SphereMesh = SphereMesh.new()
	bee_mesh.radius = 0.05
	bee_mesh.height = 0.10
	var bee_mat: StandardMaterial3D = StandardMaterial3D.new()
	bee_mat.albedo_color = Color(1.0, 0.95, 0.30)
	bee_mat.emission_enabled = true
	bee_mat.emission = Color(1.0, 0.95, 0.30)
	bee_mat.emission_energy_multiplier = 2.6
	bee_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	bee_mesh.material = bee_mat
	bees.draw_pass_1 = bee_mesh
	hive.add_child(bees)
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cap: CapsuleShape3D = CapsuleShape3D.new()
	cap.radius = 0.45
	cap.height = 4.0
	cs.shape = cap
	cs.position = Vector3(0, 2.0, 0)
	sb.add_child(cs)
	hive.add_child(sb)


func _build_d4_meadow_flowers(geom: Node) -> void:
	## Epic-4 T11: 24 small flower stem+head clusters scattered across D4.
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 311
	var colors: Array[Color] = [
		Color(1.0, 0.55, 0.85),
		Color(1.0, 0.95, 0.30),
		Color(0.85, 0.40, 1.0),
		Color(1.0, 0.55, 0.20),
		Color(0.55, 0.95, 1.0),
	]
	var stem_mat: StandardMaterial3D = StandardMaterial3D.new()
	stem_mat.albedo_color = Color(0.30, 0.65, 0.30)
	stem_mat.emission_enabled = true
	stem_mat.emission = Color(0.45, 1.0, 0.45)
	stem_mat.emission_energy_multiplier = 0.65
	for i in 24:
		var flower: Node3D = Node3D.new()
		flower.name = "D4MeadowFlower_%d" % i
		flower.position = D4_CENTER + Vector3(
			rng.randf_range(-22, 22),
			0,
			rng.randf_range(-16, 16)
		)
		geom.add_child(flower)
		var stem: MeshInstance3D = MeshInstance3D.new()
		var sm: CylinderMesh = CylinderMesh.new()
		sm.top_radius = 0.04
		sm.bottom_radius = 0.05
		sm.height = 0.55
		stem.mesh = sm
		stem.position = Vector3(0, 0.27, 0)
		stem.material_override = stem_mat
		flower.add_child(stem)
		var head: MeshInstance3D = MeshInstance3D.new()
		var hm: SphereMesh = SphereMesh.new()
		hm.radius = 0.10
		hm.height = 0.20
		head.mesh = hm
		head.position = Vector3(0, 0.60, 0)
		var color: Color = colors[i % colors.size()]
		var hmat: StandardMaterial3D = StandardMaterial3D.new()
		hmat.albedo_color = color
		hmat.emission_enabled = true
		hmat.emission = color
		hmat.emission_energy_multiplier = 1.8
		hmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		head.material_override = hmat
		flower.add_child(head)


func _build_d4_butterflies(geom: Node) -> void:
	## Epic-4 T12: 30 butterfly particles drifting near the great bloom.
	var fly: GPUParticles3D = GPUParticles3D.new()
	fly.name = "D4Butterflies"
	fly.position = D4_CENTER + Vector3(0, 3, 0)
	fly.amount = 30
	fly.lifetime = 6.0
	fly.preprocess = 3.0
	var pmat: ParticleProcessMaterial = ParticleProcessMaterial.new()
	pmat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	pmat.emission_box_extents = Vector3(8, 2, 8)
	pmat.direction = Vector3(0, 0, 0)
	pmat.spread = 180.0
	pmat.initial_velocity_min = 0.30
	pmat.initial_velocity_max = 0.85
	pmat.gravity = Vector3.ZERO
	pmat.scale_min = 0.10
	pmat.scale_max = 0.18
	pmat.color = Color(1.0, 0.55, 0.85, 1.0)
	fly.process_material = pmat
	var bm: BoxMesh = BoxMesh.new()
	bm.size = Vector3(0.18, 0.04, 0.10)
	var bmat: StandardMaterial3D = StandardMaterial3D.new()
	bmat.albedo_color = Color(1.0, 0.55, 0.85)
	bmat.emission_enabled = true
	bmat.emission = Color(1.0, 0.65, 0.85)
	bmat.emission_energy_multiplier = 1.8
	bmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	bm.material = bmat
	fly.draw_pass_1 = bm
	geom.add_child(fly)


func _build_d4_watering_well(geom: Node) -> void:
	## Epic-4 T13: stone watering well with bucket.
	var well: Node3D = Node3D.new()
	well.name = "D4WateringWell"
	well.position = D4_CENTER + Vector3(8, 0, -8)
	geom.add_child(well)
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.55, 0.50, 0.45)
	stone_mat.metallic = 0.30
	stone_mat.roughness = 0.65
	# Round well wall — torus
	var rim: MeshInstance3D = MeshInstance3D.new()
	var rmesh: TorusMesh = TorusMesh.new()
	rmesh.inner_radius = 0.85
	rmesh.outer_radius = 1.10
	rim.mesh = rmesh
	rim.position = Vector3(0, 0.50, 0)
	rim.material_override = stone_mat
	well.add_child(rim)
	# Water inside
	var water: MeshInstance3D = MeshInstance3D.new()
	var wmesh: CylinderMesh = CylinderMesh.new()
	wmesh.top_radius = 0.85
	wmesh.bottom_radius = 0.85
	wmesh.height = 0.06
	water.mesh = wmesh
	water.position = Vector3(0, 0.50, 0)
	var wmat: StandardMaterial3D = StandardMaterial3D.new()
	wmat.albedo_color = Color(0.30, 0.55, 0.85, 0.85)
	wmat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	wmat.emission_enabled = true
	wmat.emission = Color(0.55, 0.85, 1.0)
	wmat.emission_energy_multiplier = 1.0
	wmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	water.material_override = wmat
	well.add_child(water)
	# Wood arch over the well
	var wood_mat: StandardMaterial3D = StandardMaterial3D.new()
	wood_mat.albedo_color = Color(0.30, 0.18, 0.10)
	for sx: float in [-0.85, 0.85]:
		var leg: MeshInstance3D = MeshInstance3D.new()
		var lm: BoxMesh = BoxMesh.new()
		lm.size = Vector3(0.14, 2.40, 0.14)
		leg.mesh = lm
		leg.position = Vector3(sx, 1.20, 0)
		leg.material_override = wood_mat
		well.add_child(leg)
	var crossbar: MeshInstance3D = MeshInstance3D.new()
	var cm: BoxMesh = BoxMesh.new()
	cm.size = Vector3(2.0, 0.18, 0.18)
	crossbar.mesh = cm
	crossbar.position = Vector3(0, 2.40, 0)
	crossbar.material_override = wood_mat
	well.add_child(crossbar)
	# Hanging bucket
	var bucket: MeshInstance3D = MeshInstance3D.new()
	var bm: CylinderMesh = CylinderMesh.new()
	bm.top_radius = 0.20
	bm.bottom_radius = 0.18
	bm.height = 0.30
	bucket.mesh = bm
	bucket.position = Vector3(0, 1.85, 0)
	bucket.material_override = wood_mat
	well.add_child(bucket)
	# Collision
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(2.20, 2.40, 2.20)
	cs.shape = cb
	cs.position = Vector3(0, 1.20, 0)
	sb.add_child(cs)
	well.add_child(sb)


func _build_d4_farmer_npc() -> void:
	## Epic-4 T14: Farmer NPC with straw hat and pitchfork.
	var slots: Node3D = get_node_or_null("%NPCSlots") as Node3D
	if slots == null:
		return
	var farmer: Node3D = Node3D.new()
	farmer.name = "D4Farmer"
	farmer.position = D4_CENTER + Vector3(15, 0, -8)
	slots.add_child(farmer)
	var bmat: StandardMaterial3D = StandardMaterial3D.new()
	bmat.albedo_color = Color(0.55, 0.40, 0.20)
	bmat.metallic = 0.10
	bmat.roughness = 0.65
	bmat.emission_enabled = true
	bmat.emission = Color(0.85, 0.65, 0.30)
	bmat.emission_energy_multiplier = 0.30
	var body: MeshInstance3D = MeshInstance3D.new()
	var bmesh: CapsuleMesh = CapsuleMesh.new()
	bmesh.radius = 0.42
	bmesh.height = 1.30
	body.mesh = bmesh
	body.position = Vector3(0, 0.70, 0)
	body.material_override = bmat
	farmer.add_child(body)
	# Straw hat — wide flat cylinder
	var hat: MeshInstance3D = MeshInstance3D.new()
	var hm: CylinderMesh = CylinderMesh.new()
	hm.top_radius = 0.55
	hm.bottom_radius = 0.55
	hm.height = 0.10
	hat.mesh = hm
	hat.position = Vector3(0, 1.65, 0)
	var hmat: StandardMaterial3D = StandardMaterial3D.new()
	hmat.albedo_color = Color(0.85, 0.65, 0.30)
	hmat.metallic = 0.10
	hmat.roughness = 0.85
	hat.material_override = hmat
	farmer.add_child(hat)
	# Eyes
	var eye_mat: StandardMaterial3D = StandardMaterial3D.new()
	eye_mat.albedo_color = Color(0.30, 0.18, 0.10)
	eye_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for ex: float in [-0.10, 0.10]:
		var eye: MeshInstance3D = MeshInstance3D.new()
		var em: SphereMesh = SphereMesh.new()
		em.radius = 0.05
		em.height = 0.10
		eye.mesh = em
		eye.position = Vector3(ex, 1.50, 0.32)
		eye.material_override = eye_mat
		farmer.add_child(eye)
	# Pitchfork
	var fork: MeshInstance3D = MeshInstance3D.new()
	var fm: CylinderMesh = CylinderMesh.new()
	fm.top_radius = 0.05
	fm.bottom_radius = 0.05
	fm.height = 2.40
	fork.mesh = fm
	fork.position = Vector3(0.50, 1.20, 0)
	var fork_mat: StandardMaterial3D = StandardMaterial3D.new()
	fork_mat.albedo_color = Color(0.30, 0.18, 0.10)
	fork.material_override = fork_mat
	farmer.add_child(fork)
	# Name billboard
	var label: Label3D = Label3D.new()
	label.text = "Farmer"
	label.position = Vector3(0, 2.20, 0)
	label.modulate = Color(0.85, 0.65, 0.30)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 18
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	farmer.add_child(label)


func _build_d4_scarecrow(geom: Node) -> void:
	## Epic-4 T15: a straw scarecrow on a wooden cross post.
	var crow: Node3D = Node3D.new()
	crow.name = "D4Scarecrow"
	crow.position = D4_CENTER + Vector3(18, 0, -4)
	geom.add_child(crow)
	var wood_mat: StandardMaterial3D = StandardMaterial3D.new()
	wood_mat.albedo_color = Color(0.30, 0.18, 0.10)
	# Vertical post
	var post: MeshInstance3D = MeshInstance3D.new()
	var pm: CylinderMesh = CylinderMesh.new()
	pm.top_radius = 0.07
	pm.bottom_radius = 0.10
	pm.height = 2.85
	post.mesh = pm
	post.position = Vector3(0, 1.42, 0)
	post.material_override = wood_mat
	crow.add_child(post)
	# Cross arms
	var arms: MeshInstance3D = MeshInstance3D.new()
	var am: BoxMesh = BoxMesh.new()
	am.size = Vector3(2.0, 0.10, 0.10)
	arms.mesh = am
	arms.position = Vector3(0, 2.20, 0)
	arms.material_override = wood_mat
	crow.add_child(arms)
	# Straw head — yellow sphere
	var straw_mat: StandardMaterial3D = StandardMaterial3D.new()
	straw_mat.albedo_color = Color(0.95, 0.85, 0.30)
	straw_mat.emission_enabled = true
	straw_mat.emission = Color(1.0, 0.95, 0.30)
	straw_mat.emission_energy_multiplier = 0.55
	var head: MeshInstance3D = MeshInstance3D.new()
	var hmesh: SphereMesh = SphereMesh.new()
	hmesh.radius = 0.40
	hmesh.height = 0.80
	head.mesh = hmesh
	head.position = Vector3(0, 2.85, 0)
	head.material_override = straw_mat
	crow.add_child(head)
	# Conical hat
	var hat: MeshInstance3D = MeshInstance3D.new()
	var hat_mesh: PrismMesh = PrismMesh.new()
	hat_mesh.size = Vector3(0.55, 0.40, 0.55)
	hat.mesh = hat_mesh
	hat.position = Vector3(0, 3.30, 0)
	var hat_mat: StandardMaterial3D = StandardMaterial3D.new()
	hat_mat.albedo_color = Color(0.18, 0.10, 0.06)
	hat.material_override = hat_mat
	crow.add_child(hat)
	# X eyes (black bars)
	var eye_mat: StandardMaterial3D = StandardMaterial3D.new()
	eye_mat.albedo_color = Color(0.05, 0.05, 0.10)
	eye_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for ex: float in [-0.12, 0.12]:
		var eye: MeshInstance3D = MeshInstance3D.new()
		var em: BoxMesh = BoxMesh.new()
		em.size = Vector3(0.10, 0.10, 0.04)
		eye.mesh = em
		eye.position = Vector3(ex, 2.85, 0.36)
		eye.material_override = eye_mat
		crow.add_child(eye)
	# Collision
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cap: CapsuleShape3D = CapsuleShape3D.new()
	cap.radius = 0.30
	cap.height = 3.40
	cs.shape = cap
	cs.position = Vector3(0, 1.70, 0)
	sb.add_child(cs)
	crow.add_child(sb)


func _build_d4_tree_grove(geom: Node) -> void:
	## Epic-4 T16: 5 medium-sized trees in a grove cluster.
	var positions: Array[Vector3] = [
		D4_CENTER + Vector3(-18, 0, -10),
		D4_CENTER + Vector3(-15, 0, -8),
		D4_CENTER + Vector3(-20, 0, -6),
		D4_CENTER + Vector3(-16, 0, -12),
		D4_CENTER + Vector3(-12, 0, -10),
	]
	var trunk_mat: StandardMaterial3D = StandardMaterial3D.new()
	trunk_mat.albedo_color = Color(0.30, 0.18, 0.10)
	trunk_mat.metallic = 0.10
	trunk_mat.roughness = 0.65
	var leaves_mat: StandardMaterial3D = StandardMaterial3D.new()
	leaves_mat.albedo_color = Color(0.20, 0.55, 0.20)
	leaves_mat.emission_enabled = true
	leaves_mat.emission = Color(0.45, 1.0, 0.45)
	leaves_mat.emission_energy_multiplier = 0.55
	for i in positions.size():
		var tree: Node3D = Node3D.new()
		tree.name = "D4Tree_%d" % i
		tree.position = positions[i]
		geom.add_child(tree)
		var trunk: MeshInstance3D = MeshInstance3D.new()
		var tm: CylinderMesh = CylinderMesh.new()
		tm.top_radius = 0.30
		tm.bottom_radius = 0.45
		tm.height = 3.0
		trunk.mesh = tm
		trunk.position = Vector3(0, 1.50, 0)
		trunk.material_override = trunk_mat
		tree.add_child(trunk)
		var leaves: MeshInstance3D = MeshInstance3D.new()
		var lm: SphereMesh = SphereMesh.new()
		lm.radius = 1.40
		lm.height = 2.80
		leaves.mesh = lm
		leaves.position = Vector3(0, 4.0, 0)
		leaves.material_override = leaves_mat
		tree.add_child(leaves)
		var sb: StaticBody3D = StaticBody3D.new()
		var cs: CollisionShape3D = CollisionShape3D.new()
		var cap: CapsuleShape3D = CapsuleShape3D.new()
		cap.radius = 0.55
		cap.height = 3.0
		cs.shape = cap
		cs.position = Vector3(0, 1.50, 0)
		sb.add_child(cs)
		tree.add_child(sb)


func _build_d4_apple_tree(geom: Node) -> void:
	## Epic-4 T17: a single big apple tree with red apples on the leaves.
	var tree: Node3D = Node3D.new()
	tree.name = "D4AppleTree"
	tree.position = D4_CENTER + Vector3(15, 0, -16)
	geom.add_child(tree)
	var trunk_mat: StandardMaterial3D = StandardMaterial3D.new()
	trunk_mat.albedo_color = Color(0.30, 0.18, 0.10)
	var trunk: MeshInstance3D = MeshInstance3D.new()
	var tm: CylinderMesh = CylinderMesh.new()
	tm.top_radius = 0.55
	tm.bottom_radius = 0.85
	tm.height = 4.0
	trunk.mesh = tm
	trunk.position = Vector3(0, 2.0, 0)
	trunk.material_override = trunk_mat
	tree.add_child(trunk)
	var leaves: MeshInstance3D = MeshInstance3D.new()
	var lm: SphereMesh = SphereMesh.new()
	lm.radius = 2.40
	lm.height = 4.80
	leaves.mesh = lm
	leaves.position = Vector3(0, 5.0, 0)
	var lmat: StandardMaterial3D = StandardMaterial3D.new()
	lmat.albedo_color = Color(0.20, 0.55, 0.20)
	lmat.emission_enabled = true
	lmat.emission = Color(0.45, 1.0, 0.45)
	lmat.emission_energy_multiplier = 0.55
	leaves.material_override = lmat
	tree.add_child(leaves)
	# 8 red apple spheres
	var apple_mat: StandardMaterial3D = StandardMaterial3D.new()
	apple_mat.albedo_color = Color(1.0, 0.20, 0.20)
	apple_mat.emission_enabled = true
	apple_mat.emission = Color(1.0, 0.30, 0.30)
	apple_mat.emission_energy_multiplier = 1.4
	apple_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for i in 8:
		var angle: float = (float(i) / 8.0) * TAU
		var apple: MeshInstance3D = MeshInstance3D.new()
		var am: SphereMesh = SphereMesh.new()
		am.radius = 0.18
		am.height = 0.36
		apple.mesh = am
		apple.position = Vector3(cos(angle) * 1.85, 4.5 + sin(i * 0.85) * 0.55, sin(angle) * 1.85)
		apple.material_override = apple_mat
		tree.add_child(apple)
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cap: CapsuleShape3D = CapsuleShape3D.new()
	cap.radius = 0.95
	cap.height = 4.0
	cs.shape = cap
	cs.position = Vector3(0, 2.0, 0)
	sb.add_child(cs)
	tree.add_child(sb)


func _build_d4_fish_pond(geom: Node) -> void:
	## Epic-4 T18: oval fish pond with stone rim + 3 circling fish.
	var pond: Node3D = Node3D.new()
	pond.name = "D4FishPond"
	pond.position = D4_CENTER + Vector3(-8, 0, 14)
	geom.add_child(pond)
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.55, 0.50, 0.45)
	stone_mat.metallic = 0.30
	var rim: MeshInstance3D = MeshInstance3D.new()
	var rm: TorusMesh = TorusMesh.new()
	rm.inner_radius = 1.85
	rm.outer_radius = 2.20
	rim.mesh = rm
	rim.position = Vector3(0, 0.10, 0)
	rim.material_override = stone_mat
	pond.add_child(rim)
	# Water
	var water: MeshInstance3D = MeshInstance3D.new()
	var wm: CylinderMesh = CylinderMesh.new()
	wm.top_radius = 1.85
	wm.bottom_radius = 1.85
	wm.height = 0.06
	water.mesh = wm
	water.position = Vector3(0, 0.10, 0)
	var wmat: StandardMaterial3D = StandardMaterial3D.new()
	wmat.albedo_color = Color(0.30, 0.65, 0.85, 0.85)
	wmat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	wmat.emission_enabled = true
	wmat.emission = Color(0.55, 0.85, 1.0)
	wmat.emission_energy_multiplier = 1.4
	wmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	water.material_override = wmat
	pond.add_child(water)
	# 3 fish circling on a pivot
	var fish_pivot: Node3D = Node3D.new()
	fish_pivot.position = Vector3(0, 0.30, 0)
	pond.add_child(fish_pivot)
	for i in 3:
		var angle: float = (float(i) / 3.0) * TAU
		var fish: MeshInstance3D = MeshInstance3D.new()
		var fm: BoxMesh = BoxMesh.new()
		fm.size = Vector3(0.30, 0.10, 0.10)
		fish.mesh = fm
		fish.position = Vector3(cos(angle) * 1.20, 0, sin(angle) * 1.20)
		fish.rotation = Vector3(0, -angle - PI * 0.5, 0)
		var fmat: StandardMaterial3D = StandardMaterial3D.new()
		fmat.albedo_color = Color(1.0, 0.55, 0.20)
		fmat.emission_enabled = true
		fmat.emission = Color(1.0, 0.65, 0.20)
		fmat.emission_energy_multiplier = 2.0
		fmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		fish.material_override = fmat
		fish_pivot.add_child(fish)
	var spin: Tween = create_tween().set_loops()
	spin.tween_property(fish_pivot, "rotation:y", TAU, 6.0)


func _build_d4_fisherman_npc() -> void:
	## Epic-4 T19: Fisherman NPC by the pond holding a fishing rod.
	var slots: Node3D = get_node_or_null("%NPCSlots") as Node3D
	if slots == null:
		return
	var fish: Node3D = Node3D.new()
	fish.name = "D4Fisherman"
	fish.position = D4_CENTER + Vector3(-10, 0, 12)
	slots.add_child(fish)
	var bmat: StandardMaterial3D = StandardMaterial3D.new()
	bmat.albedo_color = Color(0.30, 0.55, 0.85)
	bmat.metallic = 0.20
	bmat.roughness = 0.55
	bmat.emission_enabled = true
	bmat.emission = Color(0.55, 0.85, 1.0)
	bmat.emission_energy_multiplier = 0.30
	var body: MeshInstance3D = MeshInstance3D.new()
	var bmesh: CapsuleMesh = CapsuleMesh.new()
	bmesh.radius = 0.42
	bmesh.height = 1.30
	body.mesh = bmesh
	body.position = Vector3(0, 0.70, 0)
	body.material_override = bmat
	fish.add_child(body)
	var head: MeshInstance3D = MeshInstance3D.new()
	var hm: SphereMesh = SphereMesh.new()
	hm.radius = 0.36
	hm.height = 0.65
	head.mesh = hm
	head.position = Vector3(0, 1.55, 0)
	var hmat: StandardMaterial3D = StandardMaterial3D.new()
	hmat.albedo_color = Color(0.85, 0.65, 0.45)
	head.material_override = hmat
	fish.add_child(head)
	# Fishing rod — long thin angled cylinder
	var rod: MeshInstance3D = MeshInstance3D.new()
	var rm: CylinderMesh = CylinderMesh.new()
	rm.top_radius = 0.04
	rm.bottom_radius = 0.06
	rm.height = 2.40
	rod.mesh = rm
	rod.position = Vector3(0.55, 1.50, 0.55)
	rod.rotation = Vector3(deg_to_rad(45), 0, deg_to_rad(-15))
	var rmat: StandardMaterial3D = StandardMaterial3D.new()
	rmat.albedo_color = Color(0.30, 0.18, 0.10)
	rod.material_override = rmat
	fish.add_child(rod)
	# Name billboard
	var label: Label3D = Label3D.new()
	label.text = "Fisherman"
	label.position = Vector3(0, 2.20, 0)
	label.modulate = Color(0.55, 0.85, 1.0)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 18
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	fish.add_child(label)


func _build_d4_lily_pads(geom: Node) -> void:
	## Epic-4 T20: 6 lily pads scattered on the pond surface.
	var positions: Array[Vector3] = [
		D4_CENTER + Vector3(-9, 0.18, 13),
		D4_CENTER + Vector3(-7, 0.18, 14),
		D4_CENTER + Vector3(-8, 0.18, 15),
		D4_CENTER + Vector3(-9, 0.18, 15),
		D4_CENTER + Vector3(-7, 0.18, 13),
		D4_CENTER + Vector3(-8, 0.18, 12),
	]
	var pad_mat: StandardMaterial3D = StandardMaterial3D.new()
	pad_mat.albedo_color = Color(0.20, 0.55, 0.20)
	pad_mat.emission_enabled = true
	pad_mat.emission = Color(0.45, 1.0, 0.45)
	pad_mat.emission_energy_multiplier = 0.85
	var flower_mat: StandardMaterial3D = StandardMaterial3D.new()
	flower_mat.albedo_color = Color(1.0, 0.55, 0.85)
	flower_mat.emission_enabled = true
	flower_mat.emission = Color(1.0, 0.65, 0.85)
	flower_mat.emission_energy_multiplier = 1.8
	flower_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for i in positions.size():
		var pad: MeshInstance3D = MeshInstance3D.new()
		pad.name = "D4LilyPad_%d" % i
		var pm: CylinderMesh = CylinderMesh.new()
		pm.top_radius = 0.30
		pm.bottom_radius = 0.30
		pm.height = 0.06
		pad.mesh = pm
		pad.position = positions[i]
		pad.material_override = pad_mat
		geom.add_child(pad)
		# Small lily flower on top of every other pad
		if i % 2 == 0:
			var flower: MeshInstance3D = MeshInstance3D.new()
			var fm: SphereMesh = SphereMesh.new()
			fm.radius = 0.10
			fm.height = 0.20
			flower.mesh = fm
			flower.position = positions[i] + Vector3(0, 0.12, 0)
			flower.material_override = flower_mat
			geom.add_child(flower)


func _build_d4_greenhouse_building(geom: Node) -> void:
	## Epic-4 T21: a glass greenhouse building.
	var house: Node3D = Node3D.new()
	house.name = "D4Greenhouse"
	house.position = D4_CENTER + Vector3(15, 0, 8)
	geom.add_child(house)
	var glass_mat: StandardMaterial3D = StandardMaterial3D.new()
	glass_mat.albedo_color = Color(0.55, 0.95, 0.85, 0.30)
	glass_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	glass_mat.emission_enabled = true
	glass_mat.emission = Color(0.45, 1.0, 0.55)
	glass_mat.emission_energy_multiplier = 0.55
	glass_mat.metallic = 0.30
	glass_mat.roughness = 0.10
	# Walls
	var body: MeshInstance3D = MeshInstance3D.new()
	var bm: BoxMesh = BoxMesh.new()
	bm.size = Vector3(3.40, 2.85, 2.40)
	body.mesh = bm
	body.position = Vector3(0, 1.42, 0)
	body.material_override = glass_mat
	house.add_child(body)
	# Pitched roof
	var roof: MeshInstance3D = MeshInstance3D.new()
	var rm: PrismMesh = PrismMesh.new()
	rm.size = Vector3(3.40, 1.0, 2.40)
	roof.mesh = rm
	roof.position = Vector3(0, 3.40, 0)
	roof.material_override = glass_mat
	house.add_child(roof)
	# 4 corner posts
	var frame_mat: StandardMaterial3D = StandardMaterial3D.new()
	frame_mat.albedo_color = Color(0.30, 0.18, 0.10)
	for ox: float in [-1.70, 1.70]:
		for oz: float in [-1.20, 1.20]:
			var post: MeshInstance3D = MeshInstance3D.new()
			var pm: BoxMesh = BoxMesh.new()
			pm.size = Vector3(0.10, 2.85, 0.10)
			post.mesh = pm
			post.position = Vector3(ox, 1.42, oz)
			post.material_override = frame_mat
			house.add_child(post)
	# Sign
	var label: Label3D = Label3D.new()
	label.text = "GREENHOUSE"
	label.position = Vector3(0, 4.40, 0)
	label.modulate = Color(0.45, 1.0, 0.55)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 18
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	house.add_child(label)
	# Collision
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(3.40, 2.85, 2.40)
	cs.shape = cb
	cs.position = Vector3(0, 1.42, 0)
	sb.add_child(cs)
	house.add_child(sb)


func _build_d4_plant_pot_row(geom: Node) -> void:
	## Epic-4 T22: 6 small plant pots in a row near the greenhouse.
	var pot_mat: StandardMaterial3D = StandardMaterial3D.new()
	pot_mat.albedo_color = Color(0.55, 0.30, 0.20)
	var plant_mat: StandardMaterial3D = StandardMaterial3D.new()
	plant_mat.albedo_color = Color(0.20, 0.55, 0.20)
	plant_mat.emission_enabled = true
	plant_mat.emission = Color(0.45, 1.0, 0.45)
	plant_mat.emission_energy_multiplier = 0.65
	for i in 6:
		var pot: Node3D = Node3D.new()
		pot.name = "D4Pot_%d" % i
		pot.position = D4_CENTER + Vector3(11 + i * 0.85, 0, 10)
		geom.add_child(pot)
		var pot_body: MeshInstance3D = MeshInstance3D.new()
		var pm: CylinderMesh = CylinderMesh.new()
		pm.top_radius = 0.30
		pm.bottom_radius = 0.20
		pm.height = 0.40
		pot_body.mesh = pm
		pot_body.position = Vector3(0, 0.20, 0)
		pot_body.material_override = pot_mat
		pot.add_child(pot_body)
		# Plant on top
		var plant: MeshInstance3D = MeshInstance3D.new()
		var plm: SphereMesh = SphereMesh.new()
		plm.radius = 0.22
		plm.height = 0.44
		plant.mesh = plm
		plant.position = Vector3(0, 0.55, 0)
		plant.material_override = plant_mat
		pot.add_child(plant)


func _build_d4_ladybug_creature(geom: Node) -> void:
	## Epic-4 T23: large red ladybug with black spots wandering on a patrol.
	var bug: Node3D = Node3D.new()
	bug.name = "D4Ladybug"
	bug.position = D4_CENTER + Vector3(5, 0, 10)
	geom.add_child(bug)
	# Red body shell — flattened sphere
	var body: MeshInstance3D = MeshInstance3D.new()
	var bm: SphereMesh = SphereMesh.new()
	bm.radius = 0.45
	bm.height = 0.65
	body.mesh = bm
	body.position = Vector3(0, 0.40, 0)
	body.scale = Vector3(1.0, 0.7, 1.20)
	var bmat: StandardMaterial3D = StandardMaterial3D.new()
	bmat.albedo_color = Color(1.0, 0.20, 0.20)
	bmat.emission_enabled = true
	bmat.emission = Color(1.0, 0.30, 0.30)
	bmat.emission_energy_multiplier = 1.4
	body.material_override = bmat
	bug.add_child(body)
	# 4 black spots on top
	var spot_mat: StandardMaterial3D = StandardMaterial3D.new()
	spot_mat.albedo_color = Color(0.05, 0.05, 0.10)
	spot_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for spec in [Vector3(-0.20, 0.65, 0.10), Vector3(0.20, 0.65, 0.10), Vector3(-0.20, 0.65, -0.10), Vector3(0.20, 0.65, -0.10)]:
		var spot: MeshInstance3D = MeshInstance3D.new()
		var sm: SphereMesh = SphereMesh.new()
		sm.radius = 0.10
		sm.height = 0.20
		spot.mesh = sm
		spot.position = spec
		spot.material_override = spot_mat
		bug.add_child(spot)
	# Patrol path
	var origin: Vector3 = D4_CENTER + Vector3(5, 0, 10)
	var patrol: Tween = create_tween().set_loops()
	patrol.tween_property(bug, "position", origin + Vector3(3, 0, 3), 5.0)
	patrol.tween_property(bug, "position", origin + Vector3(-3, 0, 3), 5.0)
	patrol.tween_property(bug, "position", origin, 5.0)


func _build_d4_chef_npc() -> void:
	## Epic-4 T24: Chef NPC with white outfit and tall chef hat.
	var slots: Node3D = get_node_or_null("%NPCSlots") as Node3D
	if slots == null:
		return
	var chef: Node3D = Node3D.new()
	chef.name = "D4Chef"
	chef.position = D4_CENTER + Vector3(15, 0, -3)
	slots.add_child(chef)
	var bmat: StandardMaterial3D = StandardMaterial3D.new()
	bmat.albedo_color = Color(0.95, 0.95, 0.95)
	bmat.metallic = 0.10
	bmat.roughness = 0.55
	bmat.emission_enabled = true
	bmat.emission = Color(1.0, 1.0, 1.0)
	bmat.emission_energy_multiplier = 0.30
	var body: MeshInstance3D = MeshInstance3D.new()
	var bmesh: CapsuleMesh = CapsuleMesh.new()
	bmesh.radius = 0.45
	bmesh.height = 1.40
	body.mesh = bmesh
	body.position = Vector3(0, 0.70, 0)
	body.material_override = bmat
	chef.add_child(body)
	# Tall chef hat — cylinder + dome top
	var hat: MeshInstance3D = MeshInstance3D.new()
	var hm: CylinderMesh = CylinderMesh.new()
	hm.top_radius = 0.30
	hm.bottom_radius = 0.30
	hm.height = 0.65
	hat.mesh = hm
	hat.position = Vector3(0, 1.95, 0)
	hat.material_override = bmat
	chef.add_child(hat)
	var hat_top: MeshInstance3D = MeshInstance3D.new()
	var htm: SphereMesh = SphereMesh.new()
	htm.radius = 0.40
	htm.height = 0.40
	hat_top.mesh = htm
	hat_top.position = Vector3(0, 2.40, 0)
	hat_top.scale = Vector3(1.0, 0.55, 1.0)
	hat_top.material_override = bmat
	chef.add_child(hat_top)
	var label: Label3D = Label3D.new()
	label.text = "Chef"
	label.position = Vector3(0, 2.95, 0)
	label.modulate = Color(1, 1, 1)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 18
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	chef.add_child(label)


func _build_d4_soup_pot(geom: Node) -> void:
	## Epic-4 T25: a large iron pot with bubbling orange soup and steam.
	var pot: Node3D = Node3D.new()
	pot.name = "D4SoupPot"
	pot.position = D4_CENTER + Vector3(13, 0, -3)
	geom.add_child(pot)
	var iron_mat: StandardMaterial3D = StandardMaterial3D.new()
	iron_mat.albedo_color = Color(0.16, 0.16, 0.18)
	iron_mat.metallic = 0.85
	iron_mat.roughness = 0.30
	var pot_body: MeshInstance3D = MeshInstance3D.new()
	var pm: CylinderMesh = CylinderMesh.new()
	pm.top_radius = 0.55
	pm.bottom_radius = 0.45
	pm.height = 0.85
	pot_body.mesh = pm
	pot_body.position = Vector3(0, 0.42, 0)
	pot_body.material_override = iron_mat
	pot.add_child(pot_body)
	# Soup inside
	var soup: MeshInstance3D = MeshInstance3D.new()
	var sm: CylinderMesh = CylinderMesh.new()
	sm.top_radius = 0.50
	sm.bottom_radius = 0.50
	sm.height = 0.06
	soup.mesh = sm
	soup.position = Vector3(0, 0.85, 0)
	var sm_mat: StandardMaterial3D = StandardMaterial3D.new()
	sm_mat.albedo_color = Color(1.0, 0.55, 0.20)
	sm_mat.emission_enabled = true
	sm_mat.emission = Color(1.0, 0.65, 0.20)
	sm_mat.emission_energy_multiplier = 1.4
	sm_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	soup.material_override = sm_mat
	pot.add_child(soup)
	# Steam particles
	var steam: GPUParticles3D = GPUParticles3D.new()
	steam.amount = 25
	steam.lifetime = 2.5
	steam.position = Vector3(0, 1.40, 0)
	var pmat: ParticleProcessMaterial = ParticleProcessMaterial.new()
	pmat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	pmat.emission_sphere_radius = 0.30
	pmat.direction = Vector3(0, 1, 0)
	pmat.spread = 18.0
	pmat.initial_velocity_min = 0.55
	pmat.initial_velocity_max = 1.0
	pmat.gravity = Vector3.ZERO
	pmat.scale_min = 0.30
	pmat.scale_max = 0.55
	pmat.color = Color(0.95, 0.95, 1.0, 0.55)
	steam.process_material = pmat
	var smesh: SphereMesh = SphereMesh.new()
	smesh.radius = 0.30
	smesh.height = 0.60
	var st_mat: StandardMaterial3D = StandardMaterial3D.new()
	st_mat.albedo_color = Color(0.95, 0.95, 1.0, 0.55)
	st_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	st_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	smesh.material = st_mat
	steam.draw_pass_1 = smesh
	pot.add_child(steam)
	# Collision
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cap: CapsuleShape3D = CapsuleShape3D.new()
	cap.radius = 0.65
	cap.height = 0.85
	cs.shape = cap
	cs.position = Vector3(0, 0.42, 0)
	sb.add_child(cs)
	pot.add_child(sb)


func _build_d4_stone_path(geom: Node) -> void:
	## Epic-4 T26: 12 cracked stone path tiles winding through D4.
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.55, 0.50, 0.45)
	stone_mat.metallic = 0.30
	stone_mat.roughness = 0.65
	for i in 12:
		var t: float = float(i) / 12.0
		var x: float = 192.0 + i * 2.4
		var z: float = sin(t * 4.0) * 1.6
		var tile: MeshInstance3D = MeshInstance3D.new()
		tile.name = "D4PathTile_%d" % i
		var tm: BoxMesh = BoxMesh.new()
		tm.size = Vector3(1.40, 0.10, 1.40)
		tile.mesh = tm
		tile.position = Vector3(x, 0.05, z)
		tile.rotation = Vector3(0, deg_to_rad(randf_range(-15, 15)), 0)
		tile.material_override = stone_mat
		geom.add_child(tile)


func _build_d4_windmill(geom: Node) -> void:
	## Epic-4 T27: a tall windmill — round stone tower + 4 rotating blades.
	var mill: Node3D = Node3D.new()
	mill.name = "D4Windmill"
	mill.position = D4_CENTER + Vector3(-15, 0, -16)
	geom.add_child(mill)
	# Tower body
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.55, 0.50, 0.45)
	var tower: MeshInstance3D = MeshInstance3D.new()
	var tm: CylinderMesh = CylinderMesh.new()
	tm.top_radius = 1.20
	tm.bottom_radius = 1.40
	tm.height = 6.0
	tower.mesh = tm
	tower.position = Vector3(0, 3.0, 0)
	tower.material_override = stone_mat
	mill.add_child(tower)
	# Roof cone
	var roof: MeshInstance3D = MeshInstance3D.new()
	var rm: PrismMesh = PrismMesh.new()
	rm.size = Vector3(2.85, 1.20, 2.85)
	roof.mesh = rm
	roof.position = Vector3(0, 6.55, 0)
	var roof_mat: StandardMaterial3D = StandardMaterial3D.new()
	roof_mat.albedo_color = Color(0.30, 0.18, 0.10)
	roof.material_override = roof_mat
	mill.add_child(roof)
	# Blade pivot at front
	var pivot: Node3D = Node3D.new()
	pivot.position = Vector3(0, 4.0, 1.40)
	mill.add_child(pivot)
	for i in 4:
		var angle: float = (float(i) / 4.0) * TAU
		var blade: MeshInstance3D = MeshInstance3D.new()
		var bm: BoxMesh = BoxMesh.new()
		bm.size = Vector3(0.40, 3.40, 0.18)
		blade.mesh = bm
		blade.position = Vector3(cos(angle) * 1.70, sin(angle) * 1.70, 0)
		blade.rotation = Vector3(0, 0, -angle)
		var bmat: StandardMaterial3D = StandardMaterial3D.new()
		bmat.albedo_color = Color(0.95, 0.95, 0.95)
		blade.material_override = bmat
		pivot.add_child(blade)
	var spin: Tween = create_tween().set_loops()
	spin.tween_property(pivot, "rotation:z", TAU, 8.0)
	# Collision around tower
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cap: CapsuleShape3D = CapsuleShape3D.new()
	cap.radius = 1.40
	cap.height = 6.0
	cs.shape = cap
	cs.position = Vector3(0, 3.0, 0)
	sb.add_child(cs)
	mill.add_child(sb)


func _build_d4_wheat_field(geom: Node) -> void:
	## Epic-4 T28: 30 wheat stalks in a 5x6 grid.
	var field: Node3D = Node3D.new()
	field.name = "D4WheatField"
	field.position = D4_CENTER + Vector3(-12, 0, -12)
	geom.add_child(field)
	var wheat_mat: StandardMaterial3D = StandardMaterial3D.new()
	wheat_mat.albedo_color = Color(0.95, 0.85, 0.30)
	wheat_mat.emission_enabled = true
	wheat_mat.emission = Color(1.0, 0.95, 0.30)
	wheat_mat.emission_energy_multiplier = 0.85
	wheat_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for r in 5:
		for c in 6:
			var stalk: MeshInstance3D = MeshInstance3D.new()
			var sm: BoxMesh = BoxMesh.new()
			sm.size = Vector3(0.06, 0.85, 0.06)
			stalk.mesh = sm
			stalk.position = Vector3(-1.5 + c * 0.65, 0.42, -1.0 + r * 0.55)
			stalk.material_override = wheat_mat
			field.add_child(stalk)


func _build_d4_miller_npc() -> void:
	## Epic-4 T29: Miller NPC with flour-dusted apron.
	var slots: Node3D = get_node_or_null("%NPCSlots") as Node3D
	if slots == null:
		return
	var miller: Node3D = Node3D.new()
	miller.name = "D4Miller"
	miller.position = D4_CENTER + Vector3(-12, 0, -16)
	slots.add_child(miller)
	var bmat: StandardMaterial3D = StandardMaterial3D.new()
	bmat.albedo_color = Color(0.85, 0.65, 0.45)
	bmat.metallic = 0.10
	bmat.roughness = 0.65
	bmat.emission_enabled = true
	bmat.emission = Color(1.0, 0.85, 0.55)
	bmat.emission_energy_multiplier = 0.30
	var body: MeshInstance3D = MeshInstance3D.new()
	var bmesh: CapsuleMesh = CapsuleMesh.new()
	bmesh.radius = 0.45
	bmesh.height = 1.30
	body.mesh = bmesh
	body.position = Vector3(0, 0.70, 0)
	body.material_override = bmat
	miller.add_child(body)
	var head: MeshInstance3D = MeshInstance3D.new()
	var hm: SphereMesh = SphereMesh.new()
	hm.radius = 0.36
	hm.height = 0.65
	head.mesh = hm
	head.position = Vector3(0, 1.55, 0)
	head.material_override = bmat
	miller.add_child(head)
	var label: Label3D = Label3D.new()
	label.text = "Miller"
	label.position = Vector3(0, 2.20, 0)
	label.modulate = Color(1.0, 0.85, 0.55)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 18
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	miller.add_child(label)


func _build_d4_bread_oven(geom: Node) -> void:
	## Epic-4 T30: stone bread oven with fire mouth and chimney smoke.
	var oven: Node3D = Node3D.new()
	oven.name = "D4BreadOven"
	oven.position = D4_CENTER + Vector3(-9, 0, -16)
	geom.add_child(oven)
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.55, 0.50, 0.45)
	var body: MeshInstance3D = MeshInstance3D.new()
	var bm: BoxMesh = BoxMesh.new()
	bm.size = Vector3(1.40, 1.20, 1.40)
	body.mesh = bm
	body.position = Vector3(0, 0.60, 0)
	body.material_override = stone_mat
	oven.add_child(body)
	# Dome top
	var dome: MeshInstance3D = MeshInstance3D.new()
	var dm: SphereMesh = SphereMesh.new()
	dm.radius = 0.85
	dm.height = 0.85
	dome.mesh = dm
	dome.position = Vector3(0, 1.20, 0)
	dome.scale = Vector3(1.0, 0.6, 1.0)
	dome.material_override = stone_mat
	oven.add_child(dome)
	# Dark fire mouth
	var mouth: MeshInstance3D = MeshInstance3D.new()
	var mm: BoxMesh = BoxMesh.new()
	mm.size = Vector3(0.55, 0.40, 0.10)
	mouth.mesh = mm
	mouth.position = Vector3(0, 0.65, 0.71)
	var mmat: StandardMaterial3D = StandardMaterial3D.new()
	mmat.albedo_color = Color(0.10, 0.06, 0.04)
	mmat.emission_enabled = true
	mmat.emission = Color(1.0, 0.55, 0.20)
	mmat.emission_energy_multiplier = 2.0
	mmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mouth.material_override = mmat
	oven.add_child(mouth)
	# Chimney
	var chimney: MeshInstance3D = MeshInstance3D.new()
	var cm: BoxMesh = BoxMesh.new()
	cm.size = Vector3(0.30, 1.0, 0.30)
	chimney.mesh = cm
	chimney.position = Vector3(0, 2.0, -0.40)
	chimney.material_override = stone_mat
	oven.add_child(chimney)
	# Smoke particles
	var smoke: GPUParticles3D = GPUParticles3D.new()
	smoke.amount = 20
	smoke.lifetime = 3.0
	smoke.position = Vector3(0, 2.55, -0.40)
	var pmat: ParticleProcessMaterial = ParticleProcessMaterial.new()
	pmat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	pmat.emission_sphere_radius = 0.10
	pmat.direction = Vector3(0, 1, 0)
	pmat.spread = 12.0
	pmat.initial_velocity_min = 0.55
	pmat.initial_velocity_max = 1.0
	pmat.gravity = Vector3.ZERO
	pmat.scale_min = 0.20
	pmat.scale_max = 0.40
	pmat.color = Color(0.40, 0.40, 0.50, 0.55)
	smoke.process_material = pmat
	var sm: SphereMesh = SphereMesh.new()
	sm.radius = 0.20
	sm.height = 0.40
	var sm_mat: StandardMaterial3D = StandardMaterial3D.new()
	sm_mat.albedo_color = Color(0.40, 0.40, 0.50, 0.55)
	sm_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	sm_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	sm.material = sm_mat
	smoke.draw_pass_1 = sm
	oven.add_child(smoke)
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(1.40, 1.85, 1.40)
	cs.shape = cb
	cs.position = Vector3(0, 0.92, 0)
	sb.add_child(cs)
	oven.add_child(sb)


func _build_d4_gazebo(geom: Node) -> void:
	## Epic-4 T31: 6-column octagonal gazebo with roof.
	var gaz: Node3D = Node3D.new()
	gaz.name = "D4Gazebo"
	gaz.position = D4_CENTER + Vector3(0, 0, -14)
	geom.add_child(gaz)
	var wood_mat: StandardMaterial3D = StandardMaterial3D.new()
	wood_mat.albedo_color = Color(0.55, 0.40, 0.20)
	for i in 6:
		var angle: float = (float(i) / 6.0) * TAU
		var col: MeshInstance3D = MeshInstance3D.new()
		var cm: CylinderMesh = CylinderMesh.new()
		cm.top_radius = 0.10
		cm.bottom_radius = 0.14
		cm.height = 2.40
		col.mesh = cm
		col.position = Vector3(cos(angle) * 1.85, 1.20, sin(angle) * 1.85)
		col.material_override = wood_mat
		gaz.add_child(col)
		var sb: StaticBody3D = StaticBody3D.new()
		var cs: CollisionShape3D = CollisionShape3D.new()
		var cap: CapsuleShape3D = CapsuleShape3D.new()
		cap.radius = 0.20
		cap.height = 2.40
		cs.shape = cap
		cs.position = Vector3(cos(angle) * 1.85, 1.20, sin(angle) * 1.85)
		sb.add_child(cs)
		gaz.add_child(sb)
	# Roof — flat tapered cylinder
	var roof: MeshInstance3D = MeshInstance3D.new()
	var rm: CylinderMesh = CylinderMesh.new()
	rm.top_radius = 1.85
	rm.bottom_radius = 2.40
	rm.height = 0.85
	roof.mesh = rm
	roof.position = Vector3(0, 2.85, 0)
	roof.material_override = wood_mat
	gaz.add_child(roof)


func _build_d4_flower_wreaths(geom: Node) -> void:
	## Epic-4 T32: 4 pink flower wreaths hanging on the gazebo columns.
	var wreath_mat: StandardMaterial3D = StandardMaterial3D.new()
	wreath_mat.albedo_color = Color(1.0, 0.55, 0.85)
	wreath_mat.emission_enabled = true
	wreath_mat.emission = Color(1.0, 0.65, 0.85)
	wreath_mat.emission_energy_multiplier = 1.4
	wreath_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for i in 4:
		var angle: float = (float(i) / 4.0) * TAU
		var wreath: MeshInstance3D = MeshInstance3D.new()
		wreath.name = "D4Wreath_%d" % i
		var wm: TorusMesh = TorusMesh.new()
		wm.inner_radius = 0.30
		wm.outer_radius = 0.45
		wreath.mesh = wm
		wreath.position = D4_CENTER + Vector3(cos(angle) * 1.85, 1.85, sin(angle) * 1.85) + Vector3(0, 0, -14)
		wreath.rotation = Vector3(deg_to_rad(90), 0, 0)
		wreath.material_override = wreath_mat
		geom.add_child(wreath)


func _build_d4_bird_bath(geom: Node) -> void:
	## Epic-4 T33: stone bird bath with rim, water, and 2 small birds.
	var bath: Node3D = Node3D.new()
	bath.name = "D4BirdBath"
	bath.position = D4_CENTER + Vector3(8, 0, 16)
	geom.add_child(bath)
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.55, 0.50, 0.45)
	# Stem column
	var stem: MeshInstance3D = MeshInstance3D.new()
	var sm: CylinderMesh = CylinderMesh.new()
	sm.top_radius = 0.18
	sm.bottom_radius = 0.30
	sm.height = 1.0
	stem.mesh = sm
	stem.position = Vector3(0, 0.50, 0)
	stem.material_override = stone_mat
	bath.add_child(stem)
	# Bowl
	var bowl: MeshInstance3D = MeshInstance3D.new()
	var bm: CylinderMesh = CylinderMesh.new()
	bm.top_radius = 0.55
	bm.bottom_radius = 0.30
	bm.height = 0.20
	bowl.mesh = bm
	bowl.position = Vector3(0, 1.10, 0)
	bowl.material_override = stone_mat
	bath.add_child(bowl)
	# Water
	var water: MeshInstance3D = MeshInstance3D.new()
	var wm: CylinderMesh = CylinderMesh.new()
	wm.top_radius = 0.50
	wm.bottom_radius = 0.50
	wm.height = 0.06
	water.mesh = wm
	water.position = Vector3(0, 1.20, 0)
	var wmat: StandardMaterial3D = StandardMaterial3D.new()
	wmat.albedo_color = Color(0.30, 0.85, 1.0, 0.85)
	wmat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	wmat.emission_enabled = true
	wmat.emission = Color(0.55, 0.95, 1.0)
	wmat.emission_energy_multiplier = 1.4
	wmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	water.material_override = wmat
	bath.add_child(water)
	# 2 small birds on the rim
	var bird_mat: StandardMaterial3D = StandardMaterial3D.new()
	bird_mat.albedo_color = Color(0.85, 0.85, 0.95)
	for sx: float in [-0.40, 0.40]:
		var bird: MeshInstance3D = MeshInstance3D.new()
		var bird_mesh: SphereMesh = SphereMesh.new()
		bird_mesh.radius = 0.10
		bird_mesh.height = 0.20
		bird.mesh = bird_mesh
		bird.position = Vector3(sx, 1.30, 0)
		bird.material_override = bird_mat
		bath.add_child(bird)
	# Collision
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cap: CapsuleShape3D = CapsuleShape3D.new()
	cap.radius = 0.55
	cap.height = 1.20
	cs.shape = cap
	cs.position = Vector3(0, 0.60, 0)
	sb.add_child(cs)
	bath.add_child(sb)


func _build_d4_storyteller_npc() -> void:
	## Epic-4 T34: Storyteller NPC standing inside the gazebo.
	var slots: Node3D = get_node_or_null("%NPCSlots") as Node3D
	if slots == null:
		return
	var teller: Node3D = Node3D.new()
	teller.name = "D4Storyteller"
	teller.position = D4_CENTER + Vector3(0, 0, -14)
	slots.add_child(teller)
	var bmat: StandardMaterial3D = StandardMaterial3D.new()
	bmat.albedo_color = Color(0.55, 0.30, 0.20)
	bmat.emission_enabled = true
	bmat.emission = Color(0.85, 0.55, 0.30)
	bmat.emission_energy_multiplier = 0.30
	var body: MeshInstance3D = MeshInstance3D.new()
	var bmesh: CapsuleMesh = CapsuleMesh.new()
	bmesh.radius = 0.42
	bmesh.height = 1.30
	body.mesh = bmesh
	body.position = Vector3(0, 0.70, 0)
	body.material_override = bmat
	teller.add_child(body)
	var head: MeshInstance3D = MeshInstance3D.new()
	var hm: SphereMesh = SphereMesh.new()
	hm.radius = 0.36
	hm.height = 0.65
	head.mesh = hm
	head.position = Vector3(0, 1.55, 0)
	var hmat: StandardMaterial3D = StandardMaterial3D.new()
	hmat.albedo_color = Color(0.85, 0.65, 0.45)
	head.material_override = hmat
	teller.add_child(head)
	var label: Label3D = Label3D.new()
	label.text = "Storyteller"
	label.position = Vector3(0, 2.20, 0)
	label.modulate = Color(1.0, 0.85, 0.55)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 18
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	teller.add_child(label)


func _build_d4_sleeping_cat(geom: Node) -> void:
	## Epic-4 T35: a small yellow cat curled up sleeping on a pink cushion.
	var cat: Node3D = Node3D.new()
	cat.name = "D4SleepingCat"
	cat.position = D4_CENTER + Vector3(-3, 0, 12)
	geom.add_child(cat)
	# Cushion
	var cush: MeshInstance3D = MeshInstance3D.new()
	var cm: CylinderMesh = CylinderMesh.new()
	cm.top_radius = 0.55
	cm.bottom_radius = 0.55
	cm.height = 0.18
	cush.mesh = cm
	cush.position = Vector3(0, 0.10, 0)
	var cmat: StandardMaterial3D = StandardMaterial3D.new()
	cmat.albedo_color = Color(0.85, 0.55, 0.85)
	cush.material_override = cmat
	cat.add_child(cush)
	# Cat body — curled flattened sphere
	var body: MeshInstance3D = MeshInstance3D.new()
	var bm: SphereMesh = SphereMesh.new()
	bm.radius = 0.30
	bm.height = 0.40
	body.mesh = bm
	body.position = Vector3(0, 0.30, 0)
	body.scale = Vector3(1.4, 0.85, 1.0)
	var bmat: StandardMaterial3D = StandardMaterial3D.new()
	bmat.albedo_color = Color(0.95, 0.85, 0.30)
	bmat.emission_enabled = true
	bmat.emission = Color(1.0, 0.85, 0.30)
	bmat.emission_energy_multiplier = 0.30
	body.material_override = bmat
	cat.add_child(body)
	# 2 ear prisms
	for sx: float in [-0.10, 0.10]:
		var ear: MeshInstance3D = MeshInstance3D.new()
		var em: PrismMesh = PrismMesh.new()
		em.size = Vector3(0.08, 0.10, 0.08)
		ear.mesh = em
		ear.position = Vector3(sx, 0.50, 0.30)
		ear.material_override = bmat
		cat.add_child(ear)
	# Closed eyes — black bars
	var eye_mat: StandardMaterial3D = StandardMaterial3D.new()
	eye_mat.albedo_color = Color(0.05, 0.05, 0.10)
	eye_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for ex: float in [-0.08, 0.08]:
		var eye: MeshInstance3D = MeshInstance3D.new()
		var em: BoxMesh = BoxMesh.new()
		em.size = Vector3(0.06, 0.02, 0.04)
		eye.mesh = em
		eye.position = Vector3(ex, 0.40, 0.32)
		eye.material_override = eye_mat
		cat.add_child(eye)
	# Slow breathing scale tween
	var breath: Tween = create_tween().set_loops()
	breath.tween_property(body, "scale", Vector3(1.45, 0.90, 1.05), 1.4).set_ease(Tween.EASE_IN_OUT)
	breath.tween_property(body, "scale", Vector3(1.4, 0.85, 1.0), 1.4).set_ease(Tween.EASE_IN_OUT)


func _build_d4_picnic_blanket(geom: Node) -> void:
	## Epic-4 T36: a red picnic blanket spread with a basket and 3 fruits.
	var picnic: Node3D = Node3D.new()
	picnic.name = "D4Picnic"
	picnic.position = D4_CENTER + Vector3(-3, 0, -8)
	geom.add_child(picnic)
	# Red checkered blanket — flat box
	var blanket: MeshInstance3D = MeshInstance3D.new()
	var bm: BoxMesh = BoxMesh.new()
	bm.size = Vector3(2.40, 0.05, 2.40)
	blanket.mesh = bm
	blanket.position = Vector3(0, 0.04, 0)
	var bmat: StandardMaterial3D = StandardMaterial3D.new()
	bmat.albedo_color = Color(0.85, 0.20, 0.20)
	bmat.emission_enabled = true
	bmat.emission = Color(1.0, 0.30, 0.30)
	bmat.emission_energy_multiplier = 0.45
	blanket.material_override = bmat
	picnic.add_child(blanket)
	# Wicker basket — small brown box
	var basket: MeshInstance3D = MeshInstance3D.new()
	var bk: BoxMesh = BoxMesh.new()
	bk.size = Vector3(0.55, 0.40, 0.40)
	basket.mesh = bk
	basket.position = Vector3(0, 0.30, -0.40)
	var bkmat: StandardMaterial3D = StandardMaterial3D.new()
	bkmat.albedo_color = Color(0.55, 0.40, 0.20)
	basket.material_override = bkmat
	picnic.add_child(basket)
	# 3 small fruits
	var fruit_specs: Array = [
		[Vector3(0.55, 0.18, 0.20), Color(1.0, 0.20, 0.20)],   # apple
		[Vector3(-0.40, 0.18, 0.30), Color(1.0, 0.65, 0.20)],  # orange
		[Vector3(0.20, 0.18, 0.65), Color(0.45, 1.0, 0.55)],   # apple
	]
	for spec in fruit_specs:
		var fruit: MeshInstance3D = MeshInstance3D.new()
		var fm: SphereMesh = SphereMesh.new()
		fm.radius = 0.14
		fm.height = 0.28
		fruit.mesh = fm
		fruit.position = spec[0]
		var fmat: StandardMaterial3D = StandardMaterial3D.new()
		fmat.albedo_color = spec[1]
		fmat.emission_enabled = true
		fmat.emission = spec[1]
		fmat.emission_energy_multiplier = 1.0
		fruit.material_override = fmat
		picnic.add_child(fruit)


func _build_d4_veg_cart(geom: Node) -> void:
	## Epic-4 T37: wooden vegetable cart with 2 wheels and colorful veg.
	var cart: Node3D = Node3D.new()
	cart.name = "D4VegCart"
	cart.position = D4_CENTER + Vector3(8, 0, 8)
	geom.add_child(cart)
	var wood_mat: StandardMaterial3D = StandardMaterial3D.new()
	wood_mat.albedo_color = Color(0.55, 0.40, 0.20)
	# Cart body
	var body: MeshInstance3D = MeshInstance3D.new()
	var bm: BoxMesh = BoxMesh.new()
	bm.size = Vector3(1.85, 0.65, 1.20)
	body.mesh = bm
	body.position = Vector3(0, 0.65, 0)
	body.material_override = wood_mat
	cart.add_child(body)
	# 2 wheels
	var wheel_mat: StandardMaterial3D = StandardMaterial3D.new()
	wheel_mat.albedo_color = Color(0.30, 0.18, 0.10)
	for sx: float in [-0.85, 0.85]:
		var wheel: MeshInstance3D = MeshInstance3D.new()
		var wm: CylinderMesh = CylinderMesh.new()
		wm.top_radius = 0.30
		wm.bottom_radius = 0.30
		wm.height = 0.10
		wheel.mesh = wm
		wheel.position = Vector3(sx, 0.30, 0)
		wheel.rotation = Vector3(0, 0, deg_to_rad(90))
		wheel.material_override = wheel_mat
		cart.add_child(wheel)
	# Push handle
	var handle: MeshInstance3D = MeshInstance3D.new()
	var hm: CylinderMesh = CylinderMesh.new()
	hm.top_radius = 0.05
	hm.bottom_radius = 0.05
	hm.height = 1.20
	handle.mesh = hm
	handle.position = Vector3(0, 1.0, -0.85)
	handle.rotation = Vector3(deg_to_rad(45), 0, 0)
	handle.material_override = wood_mat
	cart.add_child(handle)
	# Vegetables in a heap on top
	var veg_specs: Array = [
		[Vector3(-0.40, 1.10, 0.20), Color(1.0, 0.55, 0.20), 0.18],   # carrot
		[Vector3(0.20, 1.10, -0.20), Color(0.45, 1.0, 0.45), 0.20],   # cabbage
		[Vector3(0.55, 1.10, 0.20), Color(1.0, 0.20, 0.20), 0.16],    # tomato
		[Vector3(-0.20, 1.30, -0.10), Color(0.85, 0.65, 0.20), 0.18], # squash
	]
	for spec in veg_specs:
		var veg: MeshInstance3D = MeshInstance3D.new()
		var vm: SphereMesh = SphereMesh.new()
		vm.radius = spec[2]
		vm.height = spec[2] * 2
		veg.mesh = vm
		veg.position = spec[0]
		var vmat: StandardMaterial3D = StandardMaterial3D.new()
		vmat.albedo_color = spec[1]
		vmat.emission_enabled = true
		vmat.emission = spec[1]
		vmat.emission_energy_multiplier = 1.0
		veg.material_override = vmat
		cart.add_child(veg)
	# Collision
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(1.85, 1.40, 1.20)
	cs.shape = cb
	cs.position = Vector3(0, 0.70, 0)
	sb.add_child(cs)
	cart.add_child(sb)


func _build_d4_garden_gnomes(geom: Node) -> void:
	## Epic-4 T38: 3 garden gnome statues with red conical hats.
	var positions: Array[Vector3] = [
		D4_CENTER + Vector3(-6, 0, -3),
		D4_CENTER + Vector3(-4, 0, -4),
		D4_CENTER + Vector3(-5, 0, -5),
	]
	for i in positions.size():
		var gnome: Node3D = Node3D.new()
		gnome.name = "D4Gnome_%d" % i
		gnome.position = positions[i]
		gnome.rotation = Vector3(0, deg_to_rad(i * 90), 0)
		geom.add_child(gnome)
		# Stocky body
		var body: MeshInstance3D = MeshInstance3D.new()
		var bm: CylinderMesh = CylinderMesh.new()
		bm.top_radius = 0.18
		bm.bottom_radius = 0.30
		bm.height = 0.55
		body.mesh = bm
		body.position = Vector3(0, 0.27, 0)
		var bmat: StandardMaterial3D = StandardMaterial3D.new()
		bmat.albedo_color = Color(0.20, 0.55, 0.85)
		body.material_override = bmat
		gnome.add_child(body)
		# Round head
		var head: MeshInstance3D = MeshInstance3D.new()
		var hmesh: SphereMesh = SphereMesh.new()
		hmesh.radius = 0.18
		hmesh.height = 0.36
		head.mesh = hmesh
		head.position = Vector3(0, 0.65, 0)
		var hmat: StandardMaterial3D = StandardMaterial3D.new()
		hmat.albedo_color = Color(0.95, 0.85, 0.65)
		head.material_override = hmat
		gnome.add_child(head)
		# White beard
		var beard: MeshInstance3D = MeshInstance3D.new()
		var bbm: BoxMesh = BoxMesh.new()
		bbm.size = Vector3(0.20, 0.20, 0.06)
		beard.mesh = bbm
		beard.position = Vector3(0, 0.55, 0.16)
		var bb_mat: StandardMaterial3D = StandardMaterial3D.new()
		bb_mat.albedo_color = Color(0.95, 0.95, 1.0)
		beard.material_override = bb_mat
		gnome.add_child(beard)
		# Tall red conical hat
		var hat: MeshInstance3D = MeshInstance3D.new()
		var hat_mesh: PrismMesh = PrismMesh.new()
		hat_mesh.size = Vector3(0.30, 0.55, 0.30)
		hat.mesh = hat_mesh
		hat.position = Vector3(0, 1.05, 0)
		var hatmat: StandardMaterial3D = StandardMaterial3D.new()
		hatmat.albedo_color = Color(1.0, 0.20, 0.20)
		hatmat.emission_enabled = true
		hatmat.emission = Color(1.0, 0.30, 0.30)
		hatmat.emission_energy_multiplier = 0.85
		hat.material_override = hatmat
		gnome.add_child(hat)


func _build_d4_beekeeper_npc() -> void:
	## Epic-4 T39: Beekeeper NPC near the beehive with a white veil hat.
	var slots: Node3D = get_node_or_null("%NPCSlots") as Node3D
	if slots == null:
		return
	var bk: Node3D = Node3D.new()
	bk.name = "D4Beekeeper"
	bk.position = D4_CENTER + Vector3(13, 0, 12)
	slots.add_child(bk)
	var bmat: StandardMaterial3D = StandardMaterial3D.new()
	bmat.albedo_color = Color(0.95, 0.95, 0.95)
	bmat.metallic = 0.10
	bmat.roughness = 0.55
	bmat.emission_enabled = true
	bmat.emission = Color(1.0, 1.0, 1.0)
	bmat.emission_energy_multiplier = 0.30
	var body: MeshInstance3D = MeshInstance3D.new()
	var bmesh: CapsuleMesh = CapsuleMesh.new()
	bmesh.radius = 0.45
	bmesh.height = 1.40
	body.mesh = bmesh
	body.position = Vector3(0, 0.70, 0)
	body.material_override = bmat
	bk.add_child(body)
	# Wide veil hat — flat cylinder + dome top
	var brim: MeshInstance3D = MeshInstance3D.new()
	var brm: CylinderMesh = CylinderMesh.new()
	brm.top_radius = 0.55
	brm.bottom_radius = 0.55
	brm.height = 0.06
	brim.mesh = brm
	brim.position = Vector3(0, 1.65, 0)
	brim.material_override = bmat
	bk.add_child(brim)
	# Veil — thin translucent cylinder hanging down
	var veil: MeshInstance3D = MeshInstance3D.new()
	var vm: CylinderMesh = CylinderMesh.new()
	vm.top_radius = 0.40
	vm.bottom_radius = 0.40
	vm.height = 0.55
	veil.mesh = vm
	veil.position = Vector3(0, 1.40, 0)
	var vmat: StandardMaterial3D = StandardMaterial3D.new()
	vmat.albedo_color = Color(0.95, 0.95, 0.95, 0.45)
	vmat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	veil.material_override = vmat
	bk.add_child(veil)
	# Top dome
	var dome: MeshInstance3D = MeshInstance3D.new()
	var dm: SphereMesh = SphereMesh.new()
	dm.radius = 0.30
	dm.height = 0.30
	dome.mesh = dm
	dome.position = Vector3(0, 1.85, 0)
	dome.scale = Vector3(1.0, 0.55, 1.0)
	dome.material_override = bmat
	bk.add_child(dome)
	var label: Label3D = Label3D.new()
	label.text = "Beekeeper"
	label.position = Vector3(0, 2.50, 0)
	label.modulate = Color(1.0, 0.95, 0.30)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 18
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	bk.add_child(label)


func _build_d4_honey_jars(geom: Node) -> void:
	## Epic-4 T40: 6 honey jars in a 2x3 grid on a small wooden table.
	var jars: Node3D = Node3D.new()
	jars.name = "D4HoneyJars"
	jars.position = D4_CENTER + Vector3(13, 0, 14)
	geom.add_child(jars)
	# Wood table
	var wood_mat: StandardMaterial3D = StandardMaterial3D.new()
	wood_mat.albedo_color = Color(0.55, 0.40, 0.20)
	var table: MeshInstance3D = MeshInstance3D.new()
	var tm: BoxMesh = BoxMesh.new()
	tm.size = Vector3(1.40, 0.85, 0.85)
	table.mesh = tm
	table.position = Vector3(0, 0.42, 0)
	table.material_override = wood_mat
	jars.add_child(table)
	# 6 honey jars
	var honey_mat: StandardMaterial3D = StandardMaterial3D.new()
	honey_mat.albedo_color = Color(1.0, 0.75, 0.20, 0.85)
	honey_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	honey_mat.emission_enabled = true
	honey_mat.emission = Color(1.0, 0.85, 0.30)
	honey_mat.emission_energy_multiplier = 1.4
	honey_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for r in 2:
		for c in 3:
			var jar: MeshInstance3D = MeshInstance3D.new()
			var jm: CylinderMesh = CylinderMesh.new()
			jm.top_radius = 0.10
			jm.bottom_radius = 0.14
			jm.height = 0.30
			jar.mesh = jm
			jar.position = Vector3(-0.40 + c * 0.40, 1.0, -0.18 + r * 0.36)
			jar.material_override = honey_mat
			jars.add_child(jar)
	# Collision around table
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(1.40, 1.40, 0.85)
	cs.shape = cb
	cs.position = Vector3(0, 0.70, 0)
	sb.add_child(cs)
	jars.add_child(sb)


func _build_d4_compost_heap(geom: Node) -> void:
	## Epic-4 T41: compost heap — wooden bin frame with brown organic pile.
	var heap: Node3D = Node3D.new()
	heap.name = "D4Compost"
	heap.position = D4_CENTER + Vector3(-15, 0, -3)
	geom.add_child(heap)
	# 4 corner posts
	var wood_mat: StandardMaterial3D = StandardMaterial3D.new()
	wood_mat.albedo_color = Color(0.30, 0.18, 0.10)
	for ox: float in [-0.85, 0.85]:
		for oz: float in [-0.85, 0.85]:
			var post: MeshInstance3D = MeshInstance3D.new()
			var pm: BoxMesh = BoxMesh.new()
			pm.size = Vector3(0.10, 1.20, 0.10)
			post.mesh = pm
			post.position = Vector3(ox, 0.60, oz)
			post.material_override = wood_mat
			heap.add_child(post)
	# Side rails
	for spec in [
		[Vector3(0, 0.30, -0.85), Vector3(1.85, 0.06, 0.06)],
		[Vector3(0, 0.30, 0.85), Vector3(1.85, 0.06, 0.06)],
		[Vector3(-0.85, 0.30, 0), Vector3(0.06, 0.06, 1.85)],
		[Vector3(0.85, 0.30, 0), Vector3(0.06, 0.06, 1.85)],
		[Vector3(0, 0.85, -0.85), Vector3(1.85, 0.06, 0.06)],
		[Vector3(0, 0.85, 0.85), Vector3(1.85, 0.06, 0.06)],
		[Vector3(-0.85, 0.85, 0), Vector3(0.06, 0.06, 1.85)],
		[Vector3(0.85, 0.85, 0), Vector3(0.06, 0.06, 1.85)],
	]:
		var rail: MeshInstance3D = MeshInstance3D.new()
		var rm: BoxMesh = BoxMesh.new()
		rm.size = spec[1]
		rail.mesh = rm
		rail.position = spec[0]
		rail.material_override = wood_mat
		heap.add_child(rail)
	# Brown organic pile inside
	var pile: MeshInstance3D = MeshInstance3D.new()
	var plm: BoxMesh = BoxMesh.new()
	plm.size = Vector3(1.40, 0.85, 1.40)
	pile.mesh = plm
	pile.position = Vector3(0, 0.42, 0)
	var plmat: StandardMaterial3D = StandardMaterial3D.new()
	plmat.albedo_color = Color(0.30, 0.20, 0.10)
	plmat.emission_enabled = true
	plmat.emission = Color(0.40, 0.30, 0.10)
	plmat.emission_energy_multiplier = 0.30
	pile.material_override = plmat
	heap.add_child(pile)
	# 3 small green sprout box leaves on top
	var sprout_mat: StandardMaterial3D = StandardMaterial3D.new()
	sprout_mat.albedo_color = Color(0.45, 1.0, 0.45)
	sprout_mat.emission_enabled = true
	sprout_mat.emission = Color(0.55, 1.0, 0.55)
	sprout_mat.emission_energy_multiplier = 1.0
	sprout_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for i in 3:
		var sprout: MeshInstance3D = MeshInstance3D.new()
		var spm: BoxMesh = BoxMesh.new()
		spm.size = Vector3(0.10, 0.20, 0.10)
		sprout.mesh = spm
		sprout.position = Vector3(-0.30 + i * 0.30, 0.95, randf_range(-0.30, 0.30))
		sprout.material_override = sprout_mat
		heap.add_child(sprout)
	# Collision
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(1.85, 1.20, 1.85)
	cs.shape = cb
	cs.position = Vector3(0, 0.60, 0)
	sb.add_child(cs)
	heap.add_child(sb)


func _build_d4_painter_npc() -> void:
	## Epic-4 T42: Painter NPC at an easel with a paint palette.
	var slots: Node3D = get_node_or_null("%NPCSlots") as Node3D
	if slots == null:
		return
	var p: Node3D = Node3D.new()
	p.name = "D4Painter"
	p.position = D4_CENTER + Vector3(-3, 0, 8)
	slots.add_child(p)
	var bmat: StandardMaterial3D = StandardMaterial3D.new()
	bmat.albedo_color = Color(0.85, 0.55, 0.85)
	bmat.metallic = 0.10
	bmat.emission_enabled = true
	bmat.emission = Color(1.0, 0.65, 0.95)
	bmat.emission_energy_multiplier = 0.30
	var body: MeshInstance3D = MeshInstance3D.new()
	var bmesh: CapsuleMesh = CapsuleMesh.new()
	bmesh.radius = 0.42
	bmesh.height = 1.30
	body.mesh = bmesh
	body.position = Vector3(0, 0.70, 0)
	body.material_override = bmat
	p.add_child(body)
	var head: MeshInstance3D = MeshInstance3D.new()
	var hm: SphereMesh = SphereMesh.new()
	hm.radius = 0.36
	hm.height = 0.65
	head.mesh = hm
	head.position = Vector3(0, 1.55, 0)
	var hmat: StandardMaterial3D = StandardMaterial3D.new()
	hmat.albedo_color = Color(0.85, 0.65, 0.45)
	head.material_override = hmat
	p.add_child(head)
	# Beret hat (flat torus + small cap)
	var beret: MeshInstance3D = MeshInstance3D.new()
	var brm: CylinderMesh = CylinderMesh.new()
	brm.top_radius = 0.45
	brm.bottom_radius = 0.40
	brm.height = 0.15
	beret.mesh = brm
	beret.position = Vector3(0, 1.85, 0)
	var brmat: StandardMaterial3D = StandardMaterial3D.new()
	brmat.albedo_color = Color(0.30, 0.10, 0.10)
	beret.material_override = brmat
	p.add_child(beret)
	# Paint palette held in hand — flat oval
	var palette: MeshInstance3D = MeshInstance3D.new()
	var pm: CylinderMesh = CylinderMesh.new()
	pm.top_radius = 0.30
	pm.bottom_radius = 0.30
	pm.height = 0.04
	palette.mesh = pm
	palette.position = Vector3(0.55, 0.85, 0.30)
	palette.rotation = Vector3(0, 0, deg_to_rad(-20))
	var pmat: StandardMaterial3D = StandardMaterial3D.new()
	pmat.albedo_color = Color(0.85, 0.65, 0.30)
	palette.material_override = pmat
	p.add_child(palette)
	# 5 colored paint dots on palette
	for i in 5:
		var angle: float = (float(i) / 5.0) * TAU
		var dot: MeshInstance3D = MeshInstance3D.new()
		var dm: SphereMesh = SphereMesh.new()
		dm.radius = 0.04
		dm.height = 0.08
		dot.mesh = dm
		dot.position = Vector3(0.55 + cos(angle) * 0.18, 0.92, 0.30 + sin(angle) * 0.18)
		var dot_mat: StandardMaterial3D = StandardMaterial3D.new()
		var color: Color = [Color(1.0, 0.20, 0.20), Color(0.20, 0.55, 1.0), Color(1.0, 0.95, 0.30), Color(0.45, 1.0, 0.45), Color(0.85, 0.40, 1.0)][i]
		dot_mat.albedo_color = color
		dot_mat.emission_enabled = true
		dot_mat.emission = color
		dot_mat.emission_energy_multiplier = 1.4
		dot_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		dot.material_override = dot_mat
		p.add_child(dot)
	var label: Label3D = Label3D.new()
	label.text = "Painter"
	label.position = Vector3(0, 2.40, 0)
	label.modulate = Color(1.0, 0.65, 0.95)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 18
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	p.add_child(label)


func _build_d4_easel_canvas(geom: Node) -> void:
	## Epic-4 T43: a wooden easel with a colorful painted canvas.
	var easel: Node3D = Node3D.new()
	easel.name = "D4Easel"
	easel.position = D4_CENTER + Vector3(-2, 0, 9)
	geom.add_child(easel)
	var wood_mat: StandardMaterial3D = StandardMaterial3D.new()
	wood_mat.albedo_color = Color(0.55, 0.40, 0.20)
	# 3-leg tripod stand
	for i in 3:
		var angle: float = (float(i) / 3.0) * TAU
		var leg: MeshInstance3D = MeshInstance3D.new()
		var lm: CylinderMesh = CylinderMesh.new()
		lm.top_radius = 0.04
		lm.bottom_radius = 0.06
		lm.height = 1.85
		leg.mesh = lm
		leg.position = Vector3(cos(angle) * 0.30, 0.92, sin(angle) * 0.30)
		leg.rotation = Vector3(sin(angle) * deg_to_rad(15), 0, -cos(angle) * deg_to_rad(15))
		leg.material_override = wood_mat
		easel.add_child(leg)
	# Canvas — flat box
	var canvas: MeshInstance3D = MeshInstance3D.new()
	var cm: BoxMesh = BoxMesh.new()
	cm.size = Vector3(0.85, 1.20, 0.04)
	canvas.mesh = cm
	canvas.position = Vector3(0, 1.70, 0.10)
	var cmat: StandardMaterial3D = StandardMaterial3D.new()
	cmat.albedo_color = Color(0.95, 0.85, 0.65)
	cmat.emission_enabled = true
	cmat.emission = Color(1.0, 0.85, 0.65)
	cmat.emission_energy_multiplier = 0.55
	canvas.material_override = cmat
	easel.add_child(canvas)
	# 4 colored paint blobs on canvas (abstract painting)
	var blob_specs: Array = [
		[Vector3(-0.20, 1.95, 0.13), Color(1.0, 0.55, 0.85)],
		[Vector3(0.20, 1.85, 0.13), Color(0.45, 1.0, 0.55)],
		[Vector3(0, 1.55, 0.13), Color(1.0, 0.95, 0.30)],
		[Vector3(0.10, 1.30, 0.13), Color(0.55, 0.85, 1.0)],
	]
	for spec in blob_specs:
		var blob: MeshInstance3D = MeshInstance3D.new()
		var bm: SphereMesh = SphereMesh.new()
		bm.radius = 0.10
		bm.height = 0.20
		blob.mesh = bm
		blob.position = spec[0]
		blob.scale = Vector3(1.0, 1.0, 0.3)
		var bmat: StandardMaterial3D = StandardMaterial3D.new()
		bmat.albedo_color = spec[1]
		bmat.emission_enabled = true
		bmat.emission = spec[1]
		bmat.emission_energy_multiplier = 1.4
		bmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		blob.material_override = bmat
		easel.add_child(blob)
	# Collision
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cap: CapsuleShape3D = CapsuleShape3D.new()
	cap.radius = 0.40
	cap.height = 1.85
	cs.shape = cap
	cs.position = Vector3(0, 0.92, 0)
	sb.add_child(cs)
	easel.add_child(sb)


func _build_d4_birdhouse(geom: Node) -> void:
	## Epic-4 T44: a small wooden birdhouse on a tall pole.
	var house: Node3D = Node3D.new()
	house.name = "D4Birdhouse"
	house.position = D4_CENTER + Vector3(5, 0, 14)
	geom.add_child(house)
	var wood_mat: StandardMaterial3D = StandardMaterial3D.new()
	wood_mat.albedo_color = Color(0.55, 0.40, 0.20)
	# Tall pole
	var pole: MeshInstance3D = MeshInstance3D.new()
	var pm: CylinderMesh = CylinderMesh.new()
	pm.top_radius = 0.07
	pm.bottom_radius = 0.10
	pm.height = 2.85
	pole.mesh = pm
	pole.position = Vector3(0, 1.42, 0)
	pole.material_override = wood_mat
	house.add_child(pole)
	# House body (small box)
	var body: MeshInstance3D = MeshInstance3D.new()
	var bm: BoxMesh = BoxMesh.new()
	bm.size = Vector3(0.40, 0.40, 0.40)
	body.mesh = bm
	body.position = Vector3(0, 3.05, 0)
	body.material_override = wood_mat
	house.add_child(body)
	# Pitched roof
	var roof: MeshInstance3D = MeshInstance3D.new()
	var rm: PrismMesh = PrismMesh.new()
	rm.size = Vector3(0.50, 0.20, 0.50)
	roof.mesh = rm
	roof.position = Vector3(0, 3.35, 0)
	var roof_mat: StandardMaterial3D = StandardMaterial3D.new()
	roof_mat.albedo_color = Color(0.30, 0.18, 0.10)
	roof.material_override = roof_mat
	house.add_child(roof)
	# Round entrance hole (dark sphere recess)
	var hole: MeshInstance3D = MeshInstance3D.new()
	var hm: SphereMesh = SphereMesh.new()
	hm.radius = 0.06
	hm.height = 0.12
	hole.mesh = hm
	hole.position = Vector3(0, 3.05, 0.21)
	var hmat: StandardMaterial3D = StandardMaterial3D.new()
	hmat.albedo_color = Color(0.05, 0.05, 0.10)
	hmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	hole.material_override = hmat
	house.add_child(hole)
	# Tiny perch stick
	var perch: MeshInstance3D = MeshInstance3D.new()
	var per: CylinderMesh = CylinderMesh.new()
	per.top_radius = 0.02
	per.bottom_radius = 0.02
	per.height = 0.18
	perch.mesh = per
	perch.position = Vector3(0, 2.95, 0.30)
	perch.rotation = Vector3(deg_to_rad(90), 0, 0)
	perch.material_override = wood_mat
	house.add_child(perch)
	# Collision around pole
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cap: CapsuleShape3D = CapsuleShape3D.new()
	cap.radius = 0.20
	cap.height = 2.85
	cs.shape = cap
	cs.position = Vector3(0, 1.42, 0)
	sb.add_child(cs)
	house.add_child(sb)


func _build_d4_clothesline(geom: Node) -> void:
	## Epic-4 T45: hanging clothesline between 2 wooden posts with 5 sheets.
	var line: Node3D = Node3D.new()
	line.name = "D4Clothesline"
	line.position = D4_CENTER + Vector3(0, 0, 14)
	geom.add_child(line)
	var wood_mat: StandardMaterial3D = StandardMaterial3D.new()
	wood_mat.albedo_color = Color(0.55, 0.40, 0.20)
	# 2 vertical posts
	for sx: float in [-2.0, 2.0]:
		var post: MeshInstance3D = MeshInstance3D.new()
		var pm: CylinderMesh = CylinderMesh.new()
		pm.top_radius = 0.07
		pm.bottom_radius = 0.10
		pm.height = 2.40
		post.mesh = pm
		post.position = Vector3(sx, 1.20, 0)
		post.material_override = wood_mat
		line.add_child(post)
		# Collision per post
		var sb: StaticBody3D = StaticBody3D.new()
		var cs: CollisionShape3D = CollisionShape3D.new()
		var cap: CapsuleShape3D = CapsuleShape3D.new()
		cap.radius = 0.20
		cap.height = 2.40
		cs.shape = cap
		cs.position = Vector3(sx, 1.20, 0)
		sb.add_child(cs)
		line.add_child(sb)
	# Rope line — thin cylinder
	var rope: MeshInstance3D = MeshInstance3D.new()
	var rm: CylinderMesh = CylinderMesh.new()
	rm.top_radius = 0.02
	rm.bottom_radius = 0.02
	rm.height = 4.0
	rope.mesh = rm
	rope.position = Vector3(0, 2.20, 0)
	rope.rotation = Vector3(0, 0, deg_to_rad(90))
	var rope_mat: StandardMaterial3D = StandardMaterial3D.new()
	rope_mat.albedo_color = Color(0.85, 0.85, 0.85)
	rope.material_override = rope_mat
	line.add_child(rope)
	# 5 sheets hanging in different colors
	var sheet_colors: Array[Color] = [
		Color(1.0, 0.55, 0.85),
		Color(0.55, 0.85, 1.0),
		Color(0.95, 0.95, 0.95),
		Color(1.0, 0.95, 0.30),
		Color(0.45, 1.0, 0.55),
	]
	for i in 5:
		var sheet: MeshInstance3D = MeshInstance3D.new()
		var sm: BoxMesh = BoxMesh.new()
		sm.size = Vector3(0.65, 0.85, 0.04)
		sheet.mesh = sm
		sheet.position = Vector3(-1.60 + i * 0.80, 1.55, 0)
		var smat: StandardMaterial3D = StandardMaterial3D.new()
		smat.albedo_color = sheet_colors[i]
		smat.emission_enabled = true
		smat.emission = sheet_colors[i]
		smat.emission_energy_multiplier = 0.55
		sheet.material_override = smat
		line.add_child(sheet)


func _build_d4_stone_bridge(geom: Node) -> void:
	## Epic-4 T46: stone arch bridge over the small stream — wide flat
	## deck on 2 stone arches with side rails.
	var bridge: Node3D = Node3D.new()
	bridge.name = "D4StoneBridge"
	bridge.position = D4_CENTER + Vector3(-12, 0, -3)
	geom.add_child(bridge)
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.55, 0.50, 0.45)
	stone_mat.metallic = 0.30
	stone_mat.roughness = 0.65
	# Wide deck box
	var deck: MeshInstance3D = MeshInstance3D.new()
	var dm: BoxMesh = BoxMesh.new()
	dm.size = Vector3(4.0, 0.30, 1.85)
	deck.mesh = dm
	deck.position = Vector3(0, 1.0, 0)
	deck.material_override = stone_mat
	bridge.add_child(deck)
	# 2 stone arch supports — half cylinders
	for sx: float in [-1.40, 1.40]:
		var arch: MeshInstance3D = MeshInstance3D.new()
		var am: CylinderMesh = CylinderMesh.new()
		am.top_radius = 0.85
		am.bottom_radius = 0.85
		am.height = 1.85
		arch.mesh = am
		arch.position = Vector3(sx, 0.50, 0)
		arch.rotation = Vector3(deg_to_rad(90), 0, 0)
		arch.material_override = stone_mat
		bridge.add_child(arch)
	# 2 side rails
	for sz: float in [-0.85, 0.85]:
		var rail: MeshInstance3D = MeshInstance3D.new()
		var rm: BoxMesh = BoxMesh.new()
		rm.size = Vector3(4.0, 0.55, 0.10)
		rail.mesh = rm
		rail.position = Vector3(0, 1.40, sz)
		rail.material_override = stone_mat
		bridge.add_child(rail)
	# 6 small post markers along each rail
	for sz: float in [-0.85, 0.85]:
		for i in 6:
			var post: MeshInstance3D = MeshInstance3D.new()
			var pm: BoxMesh = BoxMesh.new()
			pm.size = Vector3(0.18, 0.30, 0.18)
			post.mesh = pm
			post.position = Vector3(-1.85 + i * 0.74, 1.55, sz)
			post.material_override = stone_mat
			bridge.add_child(post)
	# Collision around deck
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(4.0, 0.30, 1.85)
	cs.shape = cb
	cs.position = Vector3(0, 1.0, 0)
	sb.add_child(cs)
	bridge.add_child(sb)


func _build_d4_small_stream(geom: Node) -> void:
	## Epic-4 T47: a small flowing stream running through D4 — long thin
	## emissive blue strip on the ground passing under the stone bridge.
	var stream: MeshInstance3D = MeshInstance3D.new()
	stream.name = "D4Stream"
	var sm: BoxMesh = BoxMesh.new()
	sm.size = Vector3(40.0, 0.10, 0.85)
	stream.mesh = sm
	stream.position = D4_CENTER + Vector3(-12, 0.06, -3)
	var smat: StandardMaterial3D = StandardMaterial3D.new()
	smat.albedo_color = Color(0.30, 0.65, 0.95, 0.85)
	smat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	smat.emission_enabled = true
	smat.emission = Color(0.55, 0.85, 1.0)
	smat.emission_energy_multiplier = 1.4
	smat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	stream.material_override = smat
	geom.add_child(stream)


func _build_d4_frog_creature(geom: Node) -> void:
	## Epic-4 T48: a friendly green frog sitting on a lily pad near the
	## stream. Has 2 large eyes and a hop tween.
	var frog: Node3D = Node3D.new()
	frog.name = "D4Frog"
	frog.position = D4_CENTER + Vector3(-15, 0.10, -3)
	geom.add_child(frog)
	# Lily pad under frog
	var pad: MeshInstance3D = MeshInstance3D.new()
	var pm: CylinderMesh = CylinderMesh.new()
	pm.top_radius = 0.40
	pm.bottom_radius = 0.40
	pm.height = 0.06
	pad.mesh = pm
	pad.position = Vector3(0, 0.0, 0)
	var pmat: StandardMaterial3D = StandardMaterial3D.new()
	pmat.albedo_color = Color(0.20, 0.55, 0.20)
	pmat.emission_enabled = true
	pmat.emission = Color(0.45, 1.0, 0.45)
	pmat.emission_energy_multiplier = 0.85
	pad.material_override = pmat
	frog.add_child(pad)
	# Frog body — flattened sphere
	var body: MeshInstance3D = MeshInstance3D.new()
	var bm: SphereMesh = SphereMesh.new()
	bm.radius = 0.20
	bm.height = 0.30
	body.mesh = bm
	body.position = Vector3(0, 0.20, 0)
	body.scale = Vector3(1.4, 0.85, 1.0)
	var bmat: StandardMaterial3D = StandardMaterial3D.new()
	bmat.albedo_color = Color(0.30, 0.85, 0.30)
	bmat.emission_enabled = true
	bmat.emission = Color(0.45, 1.0, 0.45)
	bmat.emission_energy_multiplier = 1.0
	body.material_override = bmat
	frog.add_child(body)
	# 2 large bulging eyes
	var eye_mat: StandardMaterial3D = StandardMaterial3D.new()
	eye_mat.albedo_color = Color(0.95, 0.95, 0.95)
	eye_mat.emission_enabled = true
	eye_mat.emission = Color(1.0, 1.0, 1.0)
	eye_mat.emission_energy_multiplier = 1.4
	eye_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for ex: float in [-0.10, 0.10]:
		var eye: MeshInstance3D = MeshInstance3D.new()
		var em: SphereMesh = SphereMesh.new()
		em.radius = 0.08
		em.height = 0.16
		eye.mesh = em
		eye.position = Vector3(ex, 0.40, 0.10)
		eye.material_override = eye_mat
		frog.add_child(eye)
		# Black pupil
		var pupil: MeshInstance3D = MeshInstance3D.new()
		var pum: SphereMesh = SphereMesh.new()
		pum.radius = 0.03
		pum.height = 0.06
		pupil.mesh = pum
		pupil.position = Vector3(ex, 0.42, 0.16)
		var pumat: StandardMaterial3D = StandardMaterial3D.new()
		pumat.albedo_color = Color(0.05, 0.05, 0.10)
		pumat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		pupil.material_override = pumat
		frog.add_child(pupil)
	# Hop tween
	var hop: Tween = create_tween().set_loops()
	hop.tween_property(body, "position:y", 0.45, 0.30).set_ease(Tween.EASE_OUT)
	hop.tween_property(body, "position:y", 0.20, 0.25).set_ease(Tween.EASE_IN)
	hop.tween_interval(1.5)


func _build_d4_musician_npc() -> void:
	## Epic-4 T49: Musician NPC near the gazebo with a small wooden lute.
	var slots: Node3D = get_node_or_null("%NPCSlots") as Node3D
	if slots == null:
		return
	var mus: Node3D = Node3D.new()
	mus.name = "D4Musician"
	mus.position = D4_CENTER + Vector3(3, 0, -14)
	slots.add_child(mus)
	var bmat: StandardMaterial3D = StandardMaterial3D.new()
	bmat.albedo_color = Color(0.30, 0.20, 0.55)
	bmat.metallic = 0.20
	bmat.roughness = 0.55
	bmat.emission_enabled = true
	bmat.emission = Color(0.55, 0.30, 0.85)
	bmat.emission_energy_multiplier = 0.30
	var body: MeshInstance3D = MeshInstance3D.new()
	var bmesh: CapsuleMesh = CapsuleMesh.new()
	bmesh.radius = 0.42
	bmesh.height = 1.30
	body.mesh = bmesh
	body.position = Vector3(0, 0.70, 0)
	body.material_override = bmat
	mus.add_child(body)
	var head: MeshInstance3D = MeshInstance3D.new()
	var hm: SphereMesh = SphereMesh.new()
	hm.radius = 0.36
	hm.height = 0.65
	head.mesh = hm
	head.position = Vector3(0, 1.55, 0)
	var hmat: StandardMaterial3D = StandardMaterial3D.new()
	hmat.albedo_color = Color(0.85, 0.65, 0.45)
	head.material_override = hmat
	mus.add_child(head)
	# Wooden lute body — oval shape
	var lute: MeshInstance3D = MeshInstance3D.new()
	var lm: SphereMesh = SphereMesh.new()
	lm.radius = 0.30
	lm.height = 0.55
	lute.mesh = lm
	lute.position = Vector3(0.40, 0.85, 0.40)
	lute.scale = Vector3(0.85, 0.65, 1.20)
	var lutemat: StandardMaterial3D = StandardMaterial3D.new()
	lutemat.albedo_color = Color(0.55, 0.30, 0.10)
	lutemat.emission_enabled = true
	lutemat.emission = Color(0.85, 0.55, 0.20)
	lutemat.emission_energy_multiplier = 0.55
	lute.material_override = lutemat
	mus.add_child(lute)
	# Lute neck — long thin cylinder
	var neck: MeshInstance3D = MeshInstance3D.new()
	var nm: CylinderMesh = CylinderMesh.new()
	nm.top_radius = 0.04
	nm.bottom_radius = 0.05
	nm.height = 0.85
	neck.mesh = nm
	neck.position = Vector3(0.40, 1.30, 0.40)
	neck.rotation = Vector3(0, 0, deg_to_rad(20))
	neck.material_override = lutemat
	mus.add_child(neck)
	# Music notes floating around the head
	var note_mat: StandardMaterial3D = StandardMaterial3D.new()
	note_mat.albedo_color = Color(1.0, 0.95, 0.30)
	note_mat.emission_enabled = true
	note_mat.emission = Color(1.0, 0.95, 0.30)
	note_mat.emission_energy_multiplier = 2.4
	note_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for i in 3:
		var note: Label3D = Label3D.new()
		note.text = "♪"
		note.position = Vector3(-0.55 + i * 0.55, 2.10 + sin(i * 0.85) * 0.30, 0)
		note.modulate = Color(1.0, 0.95, 0.30)
		note.outline_modulate = Color(0, 0, 0, 0.85)
		note.outline_size = 4
		note.font_size = 22
		note.no_depth_test = true
		note.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		mus.add_child(note)
	var label: Label3D = Label3D.new()
	label.text = "Musician"
	label.position = Vector3(0, 2.55, 0)
	label.modulate = Color(0.85, 0.55, 1.0)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 18
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	mus.add_child(label)


func _build_d4_bloom_guardian(geom: Node) -> void:
	## Epic-4 T50: BLOOM GUARDIAN — friendly mini-boss with a giant
	## flower-bud body, 4 leaf wings, and a slow patrol around the central
	## bloom. Pure decorative — peaceful guardian, not hostile.
	var guard: Node3D = Node3D.new()
	guard.name = "D4BloomGuardian"
	guard.position = D4_CENTER + Vector3(8, 0, -8)
	geom.add_child(guard)
	# Big flower bud body — large pink sphere
	var body: MeshInstance3D = MeshInstance3D.new()
	var bm: SphereMesh = SphereMesh.new()
	bm.radius = 0.85
	bm.height = 1.70
	body.mesh = bm
	body.position = Vector3(0, 1.20, 0)
	var bmat: StandardMaterial3D = StandardMaterial3D.new()
	bmat.albedo_color = Color(1.0, 0.55, 0.85)
	bmat.emission_enabled = true
	bmat.emission = Color(1.0, 0.65, 0.85)
	bmat.emission_energy_multiplier = 1.6
	bmat.metallic = 0.20
	bmat.roughness = 0.30
	body.material_override = bmat
	guard.add_child(body)
	# Yellow center pollen disc on the body's front
	var center: MeshInstance3D = MeshInstance3D.new()
	var cm: SphereMesh = SphereMesh.new()
	cm.radius = 0.40
	cm.height = 0.80
	center.mesh = cm
	center.position = Vector3(0, 1.20, 0.55)
	center.scale = Vector3(1.0, 1.0, 0.4)
	var cmat: StandardMaterial3D = StandardMaterial3D.new()
	cmat.albedo_color = Color(1.0, 0.95, 0.30)
	cmat.emission_enabled = true
	cmat.emission = Color(1.0, 0.95, 0.30)
	cmat.emission_energy_multiplier = 2.4
	cmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	center.material_override = cmat
	guard.add_child(center)
	# 2 white friendly eyes
	var eye_mat: StandardMaterial3D = StandardMaterial3D.new()
	eye_mat.albedo_color = Color(0.05, 0.05, 0.10)
	eye_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for ex: float in [-0.18, 0.18]:
		var eye: MeshInstance3D = MeshInstance3D.new()
		var em: SphereMesh = SphereMesh.new()
		em.radius = 0.08
		em.height = 0.16
		eye.mesh = em
		eye.position = Vector3(ex, 1.40, 0.85)
		eye.material_override = eye_mat
		guard.add_child(eye)
	# 4 leaf wings around the body
	var wing_mat: StandardMaterial3D = StandardMaterial3D.new()
	wing_mat.albedo_color = Color(0.20, 0.55, 0.20)
	wing_mat.emission_enabled = true
	wing_mat.emission = Color(0.45, 1.0, 0.45)
	wing_mat.emission_energy_multiplier = 1.2
	wing_mat.metallic = 0.20
	wing_mat.roughness = 0.55
	for i in 4:
		var angle: float = (float(i) / 4.0) * TAU
		var wing: MeshInstance3D = MeshInstance3D.new()
		var wm: PrismMesh = PrismMesh.new()
		wm.size = Vector3(0.30, 0.85, 0.10)
		wing.mesh = wm
		wing.position = Vector3(cos(angle) * 1.10, 1.20, sin(angle) * 1.10)
		wing.rotation = Vector3(0, -angle, deg_to_rad(20))
		wing.material_override = wing_mat
		guard.add_child(wing)
	# Slow patrol path
	var origin: Vector3 = D4_CENTER + Vector3(8, 0, -8)
	var patrol: Tween = create_tween().set_loops()
	patrol.tween_property(guard, "position", origin + Vector3(-8, 0, 0), 8.0).set_ease(Tween.EASE_IN_OUT)
	patrol.tween_property(guard, "position", origin + Vector3(0, 0, 8), 8.0).set_ease(Tween.EASE_IN_OUT)
	patrol.tween_property(guard, "position", origin, 8.0).set_ease(Tween.EASE_IN_OUT)
	# Pulse the body
	var pulse: Tween = create_tween().set_loops()
	pulse.tween_property(body, "scale", Vector3(1.10, 1.10, 1.10), 1.4).set_ease(Tween.EASE_IN_OUT)
	pulse.tween_property(body, "scale", Vector3(1.0, 1.0, 1.0), 1.4).set_ease(Tween.EASE_IN_OUT)
	# Friendly name billboard
	var label: Label3D = Label3D.new()
	label.text = "BLOOM GUARDIAN"
	label.position = Vector3(0, 2.85, 0)
	label.modulate = Color(1.0, 0.65, 0.85)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 6
	label.font_size = 22
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	guard.add_child(label)


func _build_d4_stable(geom: Node) -> void:
	## Epic-4 T51: wooden stable building with open front and stall doors.
	var stable: Node3D = Node3D.new()
	stable.name = "D4Stable"
	stable.position = D4_CENTER + Vector3(20, 0, 8)
	geom.add_child(stable)
	var wood_mat: StandardMaterial3D = StandardMaterial3D.new()
	wood_mat.albedo_color = Color(0.55, 0.40, 0.20)
	wood_mat.metallic = 0.10
	wood_mat.roughness = 0.65
	wood_mat.emission_enabled = true
	wood_mat.emission = Color(0.85, 0.55, 0.30)
	wood_mat.emission_energy_multiplier = 0.30
	# Building body — wide box
	var body: MeshInstance3D = MeshInstance3D.new()
	var bm: BoxMesh = BoxMesh.new()
	bm.size = Vector3(4.0, 2.85, 2.40)
	body.mesh = bm
	body.position = Vector3(0, 1.42, 0)
	body.material_override = wood_mat
	stable.add_child(body)
	# Pitched prism roof
	var roof: MeshInstance3D = MeshInstance3D.new()
	var rm: PrismMesh = PrismMesh.new()
	rm.size = Vector3(4.0, 1.20, 2.40)
	roof.mesh = rm
	roof.position = Vector3(0, 3.40, 0)
	var roof_mat: StandardMaterial3D = StandardMaterial3D.new()
	roof_mat.albedo_color = Color(0.30, 0.18, 0.10)
	roof.material_override = roof_mat
	stable.add_child(roof)
	# 2 stall doors on front (dark recessed boxes)
	var door_mat: StandardMaterial3D = StandardMaterial3D.new()
	door_mat.albedo_color = Color(0.18, 0.10, 0.06)
	door_mat.metallic = 0.30
	for sx: float in [-0.95, 0.95]:
		var door: MeshInstance3D = MeshInstance3D.new()
		var dm: BoxMesh = BoxMesh.new()
		dm.size = Vector3(1.40, 1.85, 0.10)
		door.mesh = dm
		door.position = Vector3(sx, 0.95, 1.21)
		door.material_override = door_mat
		stable.add_child(door)
	# "STABLE" sign above
	var label: Label3D = Label3D.new()
	label.text = "STABLE"
	label.position = Vector3(0, 4.40, 0)
	label.modulate = Color(0.85, 0.55, 0.20)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 18
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	stable.add_child(label)
	# Collision around the building
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(4.0, 2.85, 2.40)
	cs.shape = cb
	cs.position = Vector3(0, 1.42, 0)
	sb.add_child(cs)
	stable.add_child(sb)


func _build_d4_horse(geom: Node) -> void:
	## Epic-4 T52: a friendly horse standing outside the stable. Body
	## capsule + 4 legs + head + mane + tail.
	var horse: Node3D = Node3D.new()
	horse.name = "D4Horse"
	horse.position = D4_CENTER + Vector3(16, 0, 8)
	geom.add_child(horse)
	# Brown body
	var body_mat: StandardMaterial3D = StandardMaterial3D.new()
	body_mat.albedo_color = Color(0.55, 0.30, 0.10)
	body_mat.metallic = 0.10
	body_mat.roughness = 0.55
	body_mat.emission_enabled = true
	body_mat.emission = Color(0.85, 0.55, 0.30)
	body_mat.emission_energy_multiplier = 0.30
	var body: MeshInstance3D = MeshInstance3D.new()
	var bm: BoxMesh = BoxMesh.new()
	bm.size = Vector3(0.85, 0.85, 1.85)
	body.mesh = bm
	body.position = Vector3(0, 1.20, 0)
	body.material_override = body_mat
	horse.add_child(body)
	# 4 legs
	for ox: float in [-0.30, 0.30]:
		for oz: float in [-0.65, 0.65]:
			var leg: MeshInstance3D = MeshInstance3D.new()
			var lm: BoxMesh = BoxMesh.new()
			lm.size = Vector3(0.18, 1.20, 0.18)
			leg.mesh = lm
			leg.position = Vector3(ox, 0.60, oz)
			leg.material_override = body_mat
			horse.add_child(leg)
	# Head — angled box at front
	var head: MeshInstance3D = MeshInstance3D.new()
	var hm: BoxMesh = BoxMesh.new()
	hm.size = Vector3(0.55, 0.65, 0.85)
	head.mesh = hm
	head.position = Vector3(0, 1.85, 1.20)
	head.rotation = Vector3(deg_to_rad(20), 0, 0)
	head.material_override = body_mat
	horse.add_child(head)
	# Black mane — small dark box on top of neck
	var mane: MeshInstance3D = MeshInstance3D.new()
	var mm: BoxMesh = BoxMesh.new()
	mm.size = Vector3(0.20, 0.30, 0.85)
	mane.mesh = mm
	mane.position = Vector3(0, 1.85, 0.55)
	var mmat: StandardMaterial3D = StandardMaterial3D.new()
	mmat.albedo_color = Color(0.10, 0.06, 0.04)
	mane.material_override = mmat
	horse.add_child(mane)
	# Tail — small dark box at the back
	var tail: MeshInstance3D = MeshInstance3D.new()
	var tm: BoxMesh = BoxMesh.new()
	tm.size = Vector3(0.10, 0.55, 0.10)
	tail.mesh = tm
	tail.position = Vector3(0, 1.10, -1.0)
	tail.rotation = Vector3(deg_to_rad(-30), 0, 0)
	tail.material_override = mmat
	horse.add_child(tail)
	# 2 small black eyes on the head
	var eye_mat: StandardMaterial3D = StandardMaterial3D.new()
	eye_mat.albedo_color = Color(0.05, 0.05, 0.10)
	eye_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for ex: float in [-0.15, 0.15]:
		var eye: MeshInstance3D = MeshInstance3D.new()
		var em: SphereMesh = SphereMesh.new()
		em.radius = 0.05
		em.height = 0.10
		eye.mesh = em
		eye.position = Vector3(ex, 1.95, 1.55)
		eye.material_override = eye_mat
		horse.add_child(eye)
	# Slow swaying head animation
	var sway: Tween = create_tween().set_loops()
	sway.tween_property(head, "rotation:x", deg_to_rad(15), 1.4).set_ease(Tween.EASE_IN_OUT)
	sway.tween_property(head, "rotation:x", deg_to_rad(25), 1.4).set_ease(Tween.EASE_IN_OUT)
	# Friendly name
	var label: Label3D = Label3D.new()
	label.text = "Horse"
	label.position = Vector3(0, 2.85, 0)
	label.modulate = Color(0.85, 0.65, 0.30)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 16
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	horse.add_child(label)


func _build_d4_stableboy_npc() -> void:
	## Epic-4 T53: Stableboy NPC near the stable holding a feed bucket.
	var slots: Node3D = get_node_or_null("%NPCSlots") as Node3D
	if slots == null:
		return
	var sb: Node3D = Node3D.new()
	sb.name = "D4Stableboy"
	sb.position = D4_CENTER + Vector3(18, 0, 6)
	slots.add_child(sb)
	var bmat: StandardMaterial3D = StandardMaterial3D.new()
	bmat.albedo_color = Color(0.55, 0.40, 0.20)
	bmat.metallic = 0.10
	bmat.roughness = 0.55
	bmat.emission_enabled = true
	bmat.emission = Color(0.85, 0.55, 0.30)
	bmat.emission_energy_multiplier = 0.30
	var body: MeshInstance3D = MeshInstance3D.new()
	var bmesh: CapsuleMesh = CapsuleMesh.new()
	bmesh.radius = 0.40
	bmesh.height = 1.20
	body.mesh = bmesh
	body.position = Vector3(0, 0.65, 0)
	body.material_override = bmat
	sb.add_child(body)
	var head: MeshInstance3D = MeshInstance3D.new()
	var hm: SphereMesh = SphereMesh.new()
	hm.radius = 0.32
	hm.height = 0.55
	head.mesh = hm
	head.position = Vector3(0, 1.45, 0)
	var hmat: StandardMaterial3D = StandardMaterial3D.new()
	hmat.albedo_color = Color(0.85, 0.65, 0.45)
	head.material_override = hmat
	sb.add_child(head)
	# Small straw hat
	var hat: MeshInstance3D = MeshInstance3D.new()
	var hatm: CylinderMesh = CylinderMesh.new()
	hatm.top_radius = 0.45
	hatm.bottom_radius = 0.45
	hatm.height = 0.10
	hat.mesh = hatm
	hat.position = Vector3(0, 1.75, 0)
	var hatmat: StandardMaterial3D = StandardMaterial3D.new()
	hatmat.albedo_color = Color(0.85, 0.65, 0.30)
	hat.material_override = hatmat
	sb.add_child(hat)
	# Feed bucket held in hand
	var bucket: MeshInstance3D = MeshInstance3D.new()
	var bkm: CylinderMesh = CylinderMesh.new()
	bkm.top_radius = 0.20
	bkm.bottom_radius = 0.18
	bkm.height = 0.30
	bucket.mesh = bkm
	bucket.position = Vector3(0.45, 0.85, 0.30)
	var bk_mat: StandardMaterial3D = StandardMaterial3D.new()
	bk_mat.albedo_color = Color(0.30, 0.18, 0.10)
	bucket.material_override = bk_mat
	sb.add_child(bucket)
	# Eyes
	var eye_mat: StandardMaterial3D = StandardMaterial3D.new()
	eye_mat.albedo_color = Color(0.30, 0.18, 0.10)
	eye_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for ex: float in [-0.10, 0.10]:
		var eye: MeshInstance3D = MeshInstance3D.new()
		var em: SphereMesh = SphereMesh.new()
		em.radius = 0.05
		em.height = 0.10
		eye.mesh = em
		eye.position = Vector3(ex, 1.40, 0.30)
		eye.material_override = eye_mat
		sb.add_child(eye)
	var label: Label3D = Label3D.new()
	label.text = "Stableboy"
	label.position = Vector3(0, 2.20, 0)
	label.modulate = Color(0.85, 0.55, 0.30)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 18
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	sb.add_child(label)


func _build_d4_hay_loft(geom: Node) -> void:
	## Epic-4 T54: a hay loft jutting out of the stable's upper level —
	## small platform with a stack of hay sacks.
	var loft: Node3D = Node3D.new()
	loft.name = "D4HayLoft"
	loft.position = D4_CENTER + Vector3(20, 0, 8)
	geom.add_child(loft)
	# Wooden platform deck — small flat box jutting out the front of the stable
	var wood_mat: StandardMaterial3D = StandardMaterial3D.new()
	wood_mat.albedo_color = Color(0.55, 0.40, 0.20)
	var deck: MeshInstance3D = MeshInstance3D.new()
	var dm: BoxMesh = BoxMesh.new()
	dm.size = Vector3(2.40, 0.18, 0.85)
	deck.mesh = dm
	deck.position = Vector3(0, 2.85, 1.55)
	deck.material_override = wood_mat
	loft.add_child(deck)
	# 2 support rope angles to the deck
	var rope_mat: StandardMaterial3D = StandardMaterial3D.new()
	rope_mat.albedo_color = Color(0.85, 0.85, 0.85)
	for sx: float in [-0.85, 0.85]:
		var rope: MeshInstance3D = MeshInstance3D.new()
		var rm: CylinderMesh = CylinderMesh.new()
		rm.top_radius = 0.03
		rm.bottom_radius = 0.03
		rm.height = 1.40
		rope.mesh = rm
		rope.position = Vector3(sx, 3.40, 1.10)
		rope.rotation = Vector3(deg_to_rad(45), 0, 0)
		rope.material_override = rope_mat
		loft.add_child(rope)
	# 3 hay sacks stacked on the deck
	var hay_mat: StandardMaterial3D = StandardMaterial3D.new()
	hay_mat.albedo_color = Color(0.95, 0.85, 0.30)
	hay_mat.emission_enabled = true
	hay_mat.emission = Color(1.0, 0.95, 0.30)
	hay_mat.emission_energy_multiplier = 0.85
	for i in 3:
		var sack: MeshInstance3D = MeshInstance3D.new()
		var sm: BoxMesh = BoxMesh.new()
		sm.size = Vector3(0.55, 0.40, 0.40)
		sack.mesh = sm
		sack.position = Vector3(-0.55 + i * 0.55, 3.20, 1.55)
		sack.material_override = hay_mat
		loft.add_child(sack)


func _build_d4_hay_bales(geom: Node) -> void:
	## Epic-4 T55: 5 stacked round hay bales near the stable.
	var bales: Node3D = Node3D.new()
	bales.name = "D4HayBales"
	bales.position = D4_CENTER + Vector3(15, 0, 14)
	geom.add_child(bales)
	var hay_mat: StandardMaterial3D = StandardMaterial3D.new()
	hay_mat.albedo_color = Color(0.95, 0.85, 0.30)
	hay_mat.emission_enabled = true
	hay_mat.emission = Color(1.0, 0.95, 0.30)
	hay_mat.emission_energy_multiplier = 0.85
	hay_mat.metallic = 0.10
	hay_mat.roughness = 0.65
	# 3 bales on the ground row + 2 stacked on top
	var bale_specs: Array = [
		[Vector3(-0.85, 0.45, 0), 0.0],
		[Vector3(0, 0.45, 0), 0.0],
		[Vector3(0.85, 0.45, 0), 0.0],
		[Vector3(-0.40, 1.20, 0), 0.0],
		[Vector3(0.40, 1.20, 0), 0.0],
	]
	for spec in bale_specs:
		var bale: MeshInstance3D = MeshInstance3D.new()
		var bm: CylinderMesh = CylinderMesh.new()
		bm.top_radius = 0.40
		bm.bottom_radius = 0.40
		bm.height = 0.65
		bale.mesh = bm
		bale.position = spec[0]
		bale.rotation = Vector3(0, 0, deg_to_rad(90))
		bale.material_override = hay_mat
		bales.add_child(bale)
	# Collision around the heap
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(2.40, 1.85, 0.85)
	cs.shape = cb
	cs.position = Vector3(0, 0.92, 0)
	sb.add_child(cs)
	bales.add_child(sb)


func _build_d4_pumpkin_patch(geom: Node) -> void:
	## Epic-4 T56: pumpkin patch — squat orange pumpkins of varying sizes on
	## a small dirt plot at the south of D4.
	var patch: Node3D = Node3D.new()
	patch.name = "PumpkinPatch"
	patch.position = Vector3(D4_CENTER.x - 6.0, 0.0, 14.0)
	geom.add_child(patch)
	# Dirt plot
	var dirt: MeshInstance3D = MeshInstance3D.new()
	var dm: BoxMesh = BoxMesh.new()
	dm.size = Vector3(6.0, 0.10, 4.0)
	dirt.mesh = dm
	var dmat: StandardMaterial3D = StandardMaterial3D.new()
	dmat.albedo_color = Color(0.30, 0.18, 0.10)
	dmat.roughness = 0.95
	dirt.material_override = dmat
	dirt.position = Vector3(0, 0.05, 0)
	patch.add_child(dirt)
	# Pumpkin material
	var pmat: StandardMaterial3D = StandardMaterial3D.new()
	pmat.albedo_color = Color(0.95, 0.45, 0.10)
	pmat.emission_enabled = true
	pmat.emission = Color(0.85, 0.30, 0.05)
	pmat.emission_energy_multiplier = 0.20
	pmat.roughness = 0.55
	# Stem material
	var stem_mat: StandardMaterial3D = StandardMaterial3D.new()
	stem_mat.albedo_color = Color(0.30, 0.50, 0.15)
	stem_mat.roughness = 0.80
	# Place 9 pumpkins in a grid
	var positions: Array = [
		Vector3(-2.2, 0, -1.4), Vector3(-0.4, 0, -1.4), Vector3(1.6, 0, -1.4),
		Vector3(-2.2, 0,  0.0), Vector3( 0.4, 0,  0.0), Vector3(2.0, 0, -0.2),
		Vector3(-1.8, 0,  1.4), Vector3( 0.0, 0,  1.4), Vector3(1.8, 0,  1.4),
	]
	var sizes: Array = [0.55, 0.70, 0.45, 0.80, 0.50, 0.65, 0.60, 0.75, 0.55]
	for i in positions.size():
		var p: Vector3 = positions[i]
		var s: float = sizes[i]
		var pumpkin: MeshInstance3D = MeshInstance3D.new()
		var sm: SphereMesh = SphereMesh.new()
		sm.radius = s
		sm.height = s * 1.4
		pumpkin.mesh = sm
		pumpkin.material_override = pmat
		pumpkin.position = Vector3(p.x, s * 0.7, p.z)
		pumpkin.scale = Vector3(1.0, 0.7, 1.0)
		patch.add_child(pumpkin)
		# Stem
		var stem: MeshInstance3D = MeshInstance3D.new()
		var stm: CylinderMesh = CylinderMesh.new()
		stm.top_radius = 0.06
		stm.bottom_radius = 0.10
		stm.height = 0.25
		stem.mesh = stm
		stem.material_override = stem_mat
		stem.position = Vector3(p.x, s * 1.05, p.z)
		patch.add_child(stem)


func _build_d4_chicken_coop(geom: Node) -> void:
	## Epic-4 T57: chicken coop — small wooden hut with sloped roof, opening,
	## and a small wire fence run.
	var coop: Node3D = Node3D.new()
	coop.name = "ChickenCoop"
	coop.position = Vector3(D4_CENTER.x + 7.0, 0.0, 13.0)
	geom.add_child(coop)
	# Wooden walls
	var wood_mat: StandardMaterial3D = StandardMaterial3D.new()
	wood_mat.albedo_color = Color(0.55, 0.35, 0.18)
	wood_mat.roughness = 0.85
	var hut: MeshInstance3D = MeshInstance3D.new()
	var hm: BoxMesh = BoxMesh.new()
	hm.size = Vector3(2.4, 1.6, 2.0)
	hut.mesh = hm
	hut.material_override = wood_mat
	hut.position = Vector3(0, 0.8, 0)
	coop.add_child(hut)
	# Sloped roof (prism)
	var roof: MeshInstance3D = MeshInstance3D.new()
	var rm: PrismMesh = PrismMesh.new()
	rm.size = Vector3(2.6, 0.7, 2.2)
	roof.mesh = rm
	var roof_mat: StandardMaterial3D = StandardMaterial3D.new()
	roof_mat.albedo_color = Color(0.40, 0.22, 0.10)
	roof_mat.roughness = 0.85
	roof.material_override = roof_mat
	roof.position = Vector3(0, 1.95, 0)
	coop.add_child(roof)
	# Door opening (dark hole)
	var door: MeshInstance3D = MeshInstance3D.new()
	var dm: BoxMesh = BoxMesh.new()
	dm.size = Vector3(0.5, 0.7, 0.05)
	door.mesh = dm
	var dmat: StandardMaterial3D = StandardMaterial3D.new()
	dmat.albedo_color = Color(0.10, 0.07, 0.04)
	dmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	door.material_override = dmat
	door.position = Vector3(0, 0.45, 1.02)
	coop.add_child(door)
	# Run fence (4 short posts and rails)
	var fence_mat: StandardMaterial3D = StandardMaterial3D.new()
	fence_mat.albedo_color = Color(0.45, 0.30, 0.15)
	fence_mat.roughness = 0.90
	var fence_corners: Array = [
		Vector2(-1.5,  1.4), Vector2( 1.5,  1.4),
		Vector2( 1.5,  3.4), Vector2(-1.5,  3.4),
	]
	for c in fence_corners:
		var post: MeshInstance3D = MeshInstance3D.new()
		var pm: CylinderMesh = CylinderMesh.new()
		pm.top_radius = 0.06
		pm.bottom_radius = 0.06
		pm.height = 0.9
		post.mesh = pm
		post.material_override = fence_mat
		post.position = Vector3(c.x, 0.45, c.y)
		coop.add_child(post)
	# Static collision body
	var sb: StaticBody3D = StaticBody3D.new()
	sb.position = Vector3(0, 0.8, 0)
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(2.4, 1.6, 2.0)
	cs.shape = cb
	sb.add_child(cs)
	coop.add_child(sb)


func _build_d4_chickens(geom: Node) -> void:
	## Epic-4 T58: rooster + 3 hens pecking and bobbing around the coop.
	var flock: Node3D = Node3D.new()
	flock.name = "Chickens"
	flock.position = Vector3(D4_CENTER.x + 7.0, 0.0, 11.0)
	geom.add_child(flock)
	var birds: Array = [
		{"pos": Vector3( 0.0, 0,  0.0), "color": Color(0.95, 0.92, 0.85), "is_rooster": true},
		{"pos": Vector3(-1.4, 0,  0.6), "color": Color(0.95, 0.85, 0.60), "is_rooster": false},
		{"pos": Vector3( 1.2, 0, -0.4), "color": Color(0.85, 0.55, 0.30), "is_rooster": false},
		{"pos": Vector3( 0.4, 0,  1.4), "color": Color(0.95, 0.95, 0.92), "is_rooster": false},
	]
	for b in birds:
		var bird: Node3D = Node3D.new()
		bird.position = b["pos"]
		flock.add_child(bird)
		# Body
		var body_mat: StandardMaterial3D = StandardMaterial3D.new()
		body_mat.albedo_color = b["color"]
		body_mat.roughness = 0.75
		var body: MeshInstance3D = MeshInstance3D.new()
		var bm: SphereMesh = SphereMesh.new()
		bm.radius = 0.20
		bm.height = 0.30
		body.mesh = bm
		body.material_override = body_mat
		body.position = Vector3(0, 0.20, 0)
		body.scale = Vector3(1.0, 0.85, 1.2)
		bird.add_child(body)
		# Head
		var head: MeshInstance3D = MeshInstance3D.new()
		var hm: SphereMesh = SphereMesh.new()
		hm.radius = 0.10
		hm.height = 0.18
		head.mesh = hm
		head.material_override = body_mat
		head.position = Vector3(0, 0.42, 0.18)
		bird.add_child(head)
		# Beak
		var beak: MeshInstance3D = MeshInstance3D.new()
		var bkm: PrismMesh = PrismMesh.new()
		bkm.size = Vector3(0.06, 0.05, 0.10)
		beak.mesh = bkm
		var beak_mat: StandardMaterial3D = StandardMaterial3D.new()
		beak_mat.albedo_color = Color(0.95, 0.65, 0.10)
		beak.material_override = beak_mat
		beak.position = Vector3(0, 0.40, 0.30)
		beak.rotation_degrees = Vector3(90, 0, 0)
		bird.add_child(beak)
		# Comb (red, larger on rooster)
		var comb: MeshInstance3D = MeshInstance3D.new()
		var cm: BoxMesh = BoxMesh.new()
		var sf: float = 1.5 if b["is_rooster"] else 1.0
		cm.size = Vector3(0.05, 0.08 * sf, 0.14 * sf)
		comb.mesh = cm
		var cmat: StandardMaterial3D = StandardMaterial3D.new()
		cmat.albedo_color = Color(0.95, 0.20, 0.20)
		cmat.emission_enabled = true
		cmat.emission = Color(0.75, 0.10, 0.10)
		cmat.emission_energy_multiplier = 0.30
		comb.material_override = cmat
		comb.position = Vector3(0, 0.52, 0.16)
		bird.add_child(comb)
		# Tail (rooster gets larger plume)
		var tail: MeshInstance3D = MeshInstance3D.new()
		var tm: SphereMesh = SphereMesh.new()
		tm.radius = 0.12 if b["is_rooster"] else 0.08
		tm.height = 0.20 if b["is_rooster"] else 0.14
		tail.mesh = tm
		var tail_mat: StandardMaterial3D = StandardMaterial3D.new()
		var base_col: Color = b["color"]
		if b["is_rooster"]:
			tail_mat.albedo_color = base_col.darkened(0.3)
		else:
			tail_mat.albedo_color = base_col
		tail.material_override = tail_mat
		tail.position = Vector3(0, 0.30, -0.24)
		bird.add_child(tail)
		# Bobbing tween
		var tw: Tween = bird.create_tween().set_loops()
		tw.tween_property(bird, "position:y", 0.04, 0.30 + randf() * 0.20)
		tw.tween_property(bird, "position:y", 0.0, 0.30 + randf() * 0.20)


func _build_d4_harvest_crates(geom: Node) -> void:
	## Epic-4 T59: stacked wooden crates filled with vegetables (carrots,
	## potatoes, onions). Sit by the chicken coop.
	var crates: Node3D = Node3D.new()
	crates.name = "HarvestCrates"
	crates.position = Vector3(D4_CENTER.x + 5.0, 0.0, 15.5)
	geom.add_child(crates)
	var wood_mat: StandardMaterial3D = StandardMaterial3D.new()
	wood_mat.albedo_color = Color(0.55, 0.35, 0.18)
	wood_mat.roughness = 0.85
	# 3 crates: two on bottom, one on top
	var positions: Array = [
		Vector3(-0.55, 0.40, 0.0),
		Vector3( 0.55, 0.40, 0.0),
		Vector3( 0.0,  1.20, 0.0),
	]
	var contents: Array = [
		{"col": Color(0.95, 0.50, 0.10), "shape": "carrot"},
		{"col": Color(0.85, 0.65, 0.40), "shape": "potato"},
		{"col": Color(0.85, 0.85, 0.65), "shape": "onion"},
	]
	for i in positions.size():
		var crate: MeshInstance3D = MeshInstance3D.new()
		var cm: BoxMesh = BoxMesh.new()
		cm.size = Vector3(1.0, 0.80, 1.0)
		crate.mesh = cm
		crate.material_override = wood_mat
		crate.position = positions[i]
		crates.add_child(crate)
		# Veggies inside
		var contents_mat: StandardMaterial3D = StandardMaterial3D.new()
		contents_mat.albedo_color = contents[i]["col"]
		contents_mat.roughness = 0.80
		for j in 5:
			var veg: MeshInstance3D = MeshInstance3D.new()
			var vm: SphereMesh = SphereMesh.new()
			vm.radius = 0.12
			vm.height = 0.20
			veg.mesh = vm
			veg.material_override = contents_mat
			var ox: float = randf_range(-0.30, 0.30)
			var oz: float = randf_range(-0.30, 0.30)
			veg.position = positions[i] + Vector3(ox, 0.50, oz)
			crates.add_child(veg)
	# Collision
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(1.20, 1.65, 1.00)
	cs.shape = cb
	cs.position = Vector3(0, 0.80, 0)
	sb.add_child(cs)
	crates.add_child(sb)


func _build_d4_berry_bushes(geom: Node) -> void:
	## Epic-4 T60: row of 6 berry bushes lining a path. Each bush has dark
	## green foliage with bright red berries (small spheres).
	var row: Node3D = Node3D.new()
	row.name = "BerryBushes"
	row.position = Vector3(D4_CENTER.x - 14.0, 0.0, 4.0)
	geom.add_child(row)
	var leaf_mat: StandardMaterial3D = StandardMaterial3D.new()
	leaf_mat.albedo_color = Color(0.18, 0.45, 0.20)
	leaf_mat.roughness = 0.85
	var berry_mat: StandardMaterial3D = StandardMaterial3D.new()
	berry_mat.albedo_color = Color(0.85, 0.10, 0.15)
	berry_mat.emission_enabled = true
	berry_mat.emission = Color(0.75, 0.10, 0.15)
	berry_mat.emission_energy_multiplier = 0.30
	berry_mat.roughness = 0.40
	for i in 6:
		var bush: Node3D = Node3D.new()
		bush.position = Vector3(i * 1.6, 0, 0)
		row.add_child(bush)
		# Foliage (3 overlapping spheres)
		for j in 3:
			var leaf: MeshInstance3D = MeshInstance3D.new()
			var lm: SphereMesh = SphereMesh.new()
			lm.radius = 0.45
			lm.height = 0.85
			leaf.mesh = lm
			leaf.material_override = leaf_mat
			leaf.position = Vector3(
				randf_range(-0.20, 0.20),
				0.45 + randf_range(-0.10, 0.10),
				randf_range(-0.20, 0.20)
			)
			bush.add_child(leaf)
		# Berries (8 small red spheres scattered on the bush)
		for j in 8:
			var berry: MeshInstance3D = MeshInstance3D.new()
			var bm: SphereMesh = SphereMesh.new()
			bm.radius = 0.06
			bm.height = 0.12
			berry.mesh = bm
			berry.material_override = berry_mat
			berry.position = Vector3(
				randf_range(-0.40, 0.40),
				randf_range(0.30, 0.85),
				randf_range(-0.40, 0.40)
			)
			bush.add_child(berry)
		# Static collision (one body per bush)
		var sb: StaticBody3D = StaticBody3D.new()
		sb.position = Vector3(0, 0.45, 0)
		var cs: CollisionShape3D = CollisionShape3D.new()
		var cb: BoxShape3D = BoxShape3D.new()
		cb.size = Vector3(0.85, 0.85, 0.85)
		cs.shape = cb
		sb.add_child(cs)
		bush.add_child(sb)



const D3_CENTER := Vector3(150, 0, 0)


func _extend_boundary_for_d3(geom: Node) -> void:
	## Epic-3 T1a: push the east boundary wall from x=120 out to x=180 to
	## make room for District 3.
	var east_wall: CSGBox3D = geom.get_node_or_null("BoundaryEast") as CSGBox3D
	if east_wall:
		east_wall.position.x = 180.0


func _build_d3_ground(geom: Node) -> void:
	## Epic-3 T1b: D3 ground — violet/purple grid floor extending from
	## x=120 to x=180. Uses a tweaked variant of the digital grid shader
	## with violet primary color on a deep black base.
	var plane: PlaneMesh = PlaneMesh.new()
	plane.size = Vector2(60, 40)
	var ground: MeshInstance3D = MeshInstance3D.new()
	ground.name = "D3Ground"
	ground.mesh = plane
	ground.position = Vector3(150, 0, 0)
	# Violet variant of the grid shader
	var shader: Shader = Shader.new()
	shader.code = """
shader_type spatial;
render_mode unshaded;
uniform vec3 base_color = vec3(0.04, 0.02, 0.08);
uniform vec3 grid_color = vec3(0.85, 0.40, 1.00);
uniform float grid_scale = 1.4;
uniform float line_width = 0.04;

void fragment() {
	vec2 uv = UV * grid_scale * 30.0;
	vec2 grid = abs(fract(uv - 0.5) - 0.5) / fwidth(uv);
	float line = min(grid.x, grid.y);
	float strength = 1.0 - min(line, 1.0);
	vec3 color = mix(base_color, grid_color, strength * 0.85);
	ALBEDO = color;
}
"""
	var smat: ShaderMaterial = ShaderMaterial.new()
	smat.shader = shader
	ground.material_override = smat
	geom.add_child(ground)
	# Ground collision
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var bs: BoxShape3D = BoxShape3D.new()
	bs.size = Vector3(60, 0.10, 40)
	cs.shape = bs
	cs.position = Vector3(0, -0.05, 0)
	sb.add_child(cs)
	ground.add_child(sb)


func _build_d3_entrance_arch(geom: Node) -> void:
	## Epic-3 T2: a tall ornate violet stone arch at the D3 entrance
	## (just east of D2 boundary at x=120) reading "MEMORY VAULT".
	var arch: Node3D = Node3D.new()
	arch.name = "D3EntranceArch"
	arch.position = Vector3(122, 0, 0)
	geom.add_child(arch)
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.10, 0.06, 0.18)
	stone_mat.metallic = 0.55
	stone_mat.roughness = 0.45
	stone_mat.emission_enabled = true
	stone_mat.emission = Color(0.85, 0.40, 1.0)
	stone_mat.emission_energy_multiplier = 0.40
	# 2 wide pillars
	for sx: float in [-4.5, 4.5]:
		var pillar: MeshInstance3D = MeshInstance3D.new()
		var pmesh: BoxMesh = BoxMesh.new()
		pmesh.size = Vector3(1.85, 8.5, 1.85)
		pillar.mesh = pmesh
		pillar.position = Vector3(sx, 4.25, 0)
		pillar.material_override = stone_mat
		arch.add_child(pillar)
		# Glowing violet rune stripe
		var stripe: MeshInstance3D = MeshInstance3D.new()
		var smesh: BoxMesh = BoxMesh.new()
		smesh.size = Vector3(0.06, 6.5, 1.95)
		stripe.mesh = smesh
		stripe.position = Vector3(sx + (-0.96 if sx < 0 else 0.96), 4.0, 0)
		var stripe_mat: StandardMaterial3D = StandardMaterial3D.new()
		stripe_mat.albedo_color = Color(0.85, 0.40, 1.0)
		stripe_mat.emission_enabled = true
		stripe_mat.emission = Color(1.0, 0.55, 1.0)
		stripe_mat.emission_energy_multiplier = 1.8
		stripe_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		stripe.material_override = stripe_mat
		arch.add_child(stripe)
		# Collision per pillar
		var sb: StaticBody3D = StaticBody3D.new()
		var cs: CollisionShape3D = CollisionShape3D.new()
		var cb: BoxShape3D = BoxShape3D.new()
		cb.size = Vector3(1.85, 8.5, 1.85)
		cs.shape = cb
		cs.position = Vector3(sx, 4.25, 0)
		sb.add_child(cs)
		arch.add_child(sb)
	# Arched lintel — wide flat box
	var lintel: MeshInstance3D = MeshInstance3D.new()
	var lmesh: BoxMesh = BoxMesh.new()
	lmesh.size = Vector3(11.0, 1.85, 1.95)
	lintel.mesh = lmesh
	lintel.position = Vector3(0, 9.40, 0)
	lintel.material_override = stone_mat
	arch.add_child(lintel)
	# Crowning peak — small prism on top of lintel
	var peak: MeshInstance3D = MeshInstance3D.new()
	var prmesh: PrismMesh = PrismMesh.new()
	prmesh.size = Vector3(2.40, 1.40, 1.95)
	peak.mesh = prmesh
	peak.position = Vector3(0, 11.0, 0)
	peak.material_override = stone_mat
	arch.add_child(peak)
	# Glowing eye gem in the peak
	var gem: MeshInstance3D = MeshInstance3D.new()
	var gm: SphereMesh = SphereMesh.new()
	gm.radius = 0.30
	gm.height = 0.60
	gem.mesh = gm
	gem.position = Vector3(0, 11.20, 0)
	var gmat: StandardMaterial3D = StandardMaterial3D.new()
	gmat.albedo_color = Color(0.85, 0.40, 1.0)
	gmat.emission_enabled = true
	gmat.emission = Color(1.0, 0.55, 1.0)
	gmat.emission_energy_multiplier = 3.0
	gmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	gem.material_override = gmat
	arch.add_child(gem)
	# Pulse the gem
	var pulse: Tween = create_tween().set_loops()
	pulse.tween_property(gem, "scale", Vector3(1.30, 1.30, 1.30), 1.6).set_ease(Tween.EASE_IN_OUT)
	pulse.tween_property(gem, "scale", Vector3(0.95, 0.95, 0.95), 1.6).set_ease(Tween.EASE_IN_OUT)
	# Big district name on the lintel both sides
	for fz: float in [-0.99, 0.99]:
		var label: Label3D = Label3D.new()
		label.text = "MEMORY VAULT"
		label.position = Vector3(0, 9.40, fz)
		label.rotation = Vector3(0, deg_to_rad(0 if fz > 0 else 180), 0)
		label.modulate = Color(0.85, 0.55, 1.0)
		label.outline_modulate = Color(0, 0, 0, 0.85)
		label.outline_size = 6
		label.font_size = 26
		label.no_depth_test = true
		arch.add_child(label)


func _build_d3_great_crystal(geom: Node) -> void:
	## Epic-3 T3: a giant 8m-tall data crystal at the D3 center, the
	## district's main landmark. Translucent violet prism floating just
	## above a stepped platform with a slow vertical bob and rotation.
	var crystal: Node3D = Node3D.new()
	crystal.name = "D3GreatCrystal"
	crystal.position = D3_CENTER
	geom.add_child(crystal)
	# Stepped stone platform
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.10, 0.06, 0.18)
	stone_mat.metallic = 0.55
	stone_mat.roughness = 0.45
	for i in 3:
		var step: MeshInstance3D = MeshInstance3D.new()
		var sm: BoxMesh = BoxMesh.new()
		sm.size = Vector3(4.0 - i * 0.55, 0.30, 4.0 - i * 0.55)
		step.mesh = sm
		step.position = Vector3(0, 0.15 + i * 0.30, 0)
		step.material_override = stone_mat
		crystal.add_child(step)
	# Crystal pivot above the platform (where bob + rotation happen)
	var pivot: Node3D = Node3D.new()
	pivot.position = Vector3(0, 5.0, 0)
	crystal.add_child(pivot)
	# Main crystal — large prism
	var crystal_mat: StandardMaterial3D = StandardMaterial3D.new()
	crystal_mat.albedo_color = Color(0.85, 0.40, 1.0, 0.55)
	crystal_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	crystal_mat.emission_enabled = true
	crystal_mat.emission = Color(1.0, 0.55, 1.0)
	crystal_mat.emission_energy_multiplier = 2.4
	crystal_mat.metallic = 0.30
	crystal_mat.roughness = 0.10
	crystal_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var prism: MeshInstance3D = MeshInstance3D.new()
	var pmesh: PrismMesh = PrismMesh.new()
	pmesh.size = Vector3(2.40, 5.0, 2.40)
	prism.mesh = pmesh
	prism.position = Vector3(0, 0, 0)
	prism.material_override = crystal_mat
	pivot.add_child(prism)
	# Inverted crystal underneath (pointing down)
	var lower: MeshInstance3D = MeshInstance3D.new()
	var lmesh: PrismMesh = PrismMesh.new()
	lmesh.size = Vector3(2.40, 2.40, 2.40)
	lower.mesh = lmesh
	lower.position = Vector3(0, -3.40, 0)
	lower.rotation = Vector3(deg_to_rad(180), 0, 0)
	lower.material_override = crystal_mat
	pivot.add_child(lower)
	# Slow rotation
	var spin: Tween = create_tween().set_loops()
	spin.tween_property(pivot, "rotation:y", TAU, 14.0)
	# Bob in place
	var bob: Tween = create_tween().set_loops()
	bob.tween_property(pivot, "position:y", 5.55, 2.4).set_ease(Tween.EASE_IN_OUT)
	bob.tween_property(pivot, "position:y", 5.0, 2.4).set_ease(Tween.EASE_IN_OUT)
	# 4 small orbital satellite crystals around the main one
	for i in 4:
		var angle: float = (float(i) / 4.0) * TAU
		var sat: MeshInstance3D = MeshInstance3D.new()
		var sm: PrismMesh = PrismMesh.new()
		sm.size = Vector3(0.55, 1.20, 0.55)
		sat.mesh = sm
		sat.position = Vector3(cos(angle) * 2.40, randf_range(-0.5, 0.5), sin(angle) * 2.40)
		sat.material_override = crystal_mat
		pivot.add_child(sat)
	# Real OmniLight inside the crystal
	var crystal_light: OmniLight3D = OmniLight3D.new()
	crystal_light.position = Vector3(0, 0, 0)
	crystal_light.light_color = Color(1.0, 0.55, 1.0)
	crystal_light.light_energy = 3.5
	crystal_light.omni_range = 22.0
	pivot.add_child(crystal_light)
	# Halo on the platform
	var halo: MeshInstance3D = MeshInstance3D.new()
	var hmesh: TorusMesh = TorusMesh.new()
	hmesh.inner_radius = 2.40
	hmesh.outer_radius = 2.85
	halo.mesh = hmesh
	halo.position = Vector3(0, 1.05, 0)
	var hmat: StandardMaterial3D = StandardMaterial3D.new()
	hmat.albedo_color = Color(0.85, 0.40, 1.0)
	hmat.emission_enabled = true
	hmat.emission = Color(1.0, 0.55, 1.0)
	hmat.emission_energy_multiplier = 2.0
	hmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	halo.material_override = hmat
	crystal.add_child(halo)
	# Sign
	var label: Label3D = Label3D.new()
	label.text = "GREAT CRYSTAL"
	label.position = Vector3(0, 11.0, 0)
	label.modulate = Color(1.0, 0.55, 1.0)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 6
	label.font_size = 22
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	crystal.add_child(label)
	# Collision around the platform
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(4.0, 1.40, 4.0)
	cs.shape = cb
	cs.position = Vector3(0, 0.70, 0)
	sb.add_child(cs)
	crystal.add_child(sb)


func _build_d3_awakened_guardian(geom: Node) -> void:
	## Epic-3 T4: an awakened guardian mini-boss — a stone humanoid statue
	## that has come to life. Tall thin body, glowing violet runes
	## carved into chest, deep amethyst eyes, slow patrol around the
	## crystal platform.
	var guardian: Node3D = Node3D.new()
	guardian.name = "D3AwakenedGuardian"
	guardian.position = D3_CENTER + Vector3(8, 0, 6)
	geom.add_child(guardian)
	# Body — tall stone box
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.20, 0.16, 0.26)
	stone_mat.metallic = 0.40
	stone_mat.roughness = 0.55
	var torso: MeshInstance3D = MeshInstance3D.new()
	var tm: BoxMesh = BoxMesh.new()
	tm.size = Vector3(1.40, 2.40, 0.85)
	torso.mesh = tm
	torso.position = Vector3(0, 1.90, 0)
	torso.material_override = stone_mat
	guardian.add_child(torso)
	# Head — narrower box
	var head: MeshInstance3D = MeshInstance3D.new()
	var hm: BoxMesh = BoxMesh.new()
	hm.size = Vector3(0.85, 0.85, 0.85)
	head.mesh = hm
	head.position = Vector3(0, 3.55, 0)
	head.material_override = stone_mat
	guardian.add_child(head)
	# 2 deep amethyst eyes
	var eye_mat: StandardMaterial3D = StandardMaterial3D.new()
	eye_mat.albedo_color = Color(0.85, 0.40, 1.0)
	eye_mat.emission_enabled = true
	eye_mat.emission = Color(1.0, 0.55, 1.0)
	eye_mat.emission_energy_multiplier = 3.0
	eye_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for ex: float in [-0.18, 0.18]:
		var eye: MeshInstance3D = MeshInstance3D.new()
		var em: SphereMesh = SphereMesh.new()
		em.radius = 0.10
		em.height = 0.20
		eye.mesh = em
		eye.position = Vector3(ex, 3.60, 0.45)
		eye.material_override = eye_mat
		guardian.add_child(eye)
	# 4 violet rune squares carved into chest
	var rune_mat: StandardMaterial3D = StandardMaterial3D.new()
	rune_mat.albedo_color = Color(0.85, 0.40, 1.0)
	rune_mat.emission_enabled = true
	rune_mat.emission = Color(1.0, 0.55, 1.0)
	rune_mat.emission_energy_multiplier = 2.4
	rune_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for i in 4:
		var rune: MeshInstance3D = MeshInstance3D.new()
		var rm: BoxMesh = BoxMesh.new()
		rm.size = Vector3(0.20, 0.20, 0.04)
		rune.mesh = rm
		rune.position = Vector3(-0.40 + (i % 2) * 0.55, 1.60 + int(i / 2) * 0.55, 0.45)
		rune.material_override = rune_mat
		guardian.add_child(rune)
		# Rune flicker
		var flicker: Tween = create_tween().set_loops()
		flicker.tween_interval(1.0 + i * 0.3)
		flicker.tween_property(rune, "visible", false, 0.0)
		flicker.tween_interval(0.10)
		flicker.tween_property(rune, "visible", true, 0.0)
	# 2 thick legs
	for sx: float in [-0.40, 0.40]:
		var leg: MeshInstance3D = MeshInstance3D.new()
		var lm: BoxMesh = BoxMesh.new()
		lm.size = Vector3(0.40, 0.85, 0.40)
		leg.mesh = lm
		leg.position = Vector3(sx, 0.42, 0)
		leg.material_override = stone_mat
		guardian.add_child(leg)
	# Stone sword in front
	var sword: MeshInstance3D = MeshInstance3D.new()
	var sm: BoxMesh = BoxMesh.new()
	sm.size = Vector3(0.20, 2.40, 0.06)
	sword.mesh = sm
	sword.position = Vector3(0.85, 1.40, 0.45)
	sword.material_override = stone_mat
	guardian.add_child(sword)
	# Patrol path circling the crystal
	var origin: Vector3 = D3_CENTER + Vector3(8, 0, 6)
	var patrol: Tween = create_tween().set_loops()
	patrol.tween_property(guardian, "rotation:y", deg_to_rad(90), 0.5)
	patrol.tween_property(guardian, "position", D3_CENTER + Vector3(8, 0, -6), 8.0)
	patrol.tween_property(guardian, "rotation:y", deg_to_rad(180), 0.5)
	patrol.tween_property(guardian, "position", D3_CENTER + Vector3(-8, 0, -6), 8.0)
	patrol.tween_property(guardian, "rotation:y", deg_to_rad(270), 0.5)
	patrol.tween_property(guardian, "position", D3_CENTER + Vector3(-8, 0, 6), 8.0)
	patrol.tween_property(guardian, "rotation:y", 0.0, 0.5)
	patrol.tween_property(guardian, "position", origin, 8.0)
	# Boss-tier name billboard
	var label: Label3D = Label3D.new()
	label.text = "AWAKENED GUARDIAN"
	label.position = Vector3(0, 4.65, 0)
	label.modulate = Color(1.0, 0.55, 1.0)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 6
	label.font_size = 22
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	guardian.add_child(label)


func _build_d3_lost_coder_npc() -> void:
	## Epic-3 T5: Lost Coder NPC — a wandering ancient programmer ghost
	## with a translucent body and a glowing keyboard floating in front
	## of them. The first inhabitant of the Memory Vault.
	var slots: Node3D = get_node_or_null("%NPCSlots") as Node3D
	if slots == null:
		return
	var coder: Node3D = Node3D.new()
	coder.name = "D3LostCoder"
	coder.position = D3_CENTER + Vector3(-12, 0, 4)
	slots.add_child(coder)
	# Translucent ghostly body
	var bmat: StandardMaterial3D = StandardMaterial3D.new()
	bmat.albedo_color = Color(0.85, 0.55, 1.0, 0.55)
	bmat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	bmat.emission_enabled = true
	bmat.emission = Color(0.85, 0.40, 1.0)
	bmat.emission_energy_multiplier = 1.4
	bmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var body: MeshInstance3D = MeshInstance3D.new()
	var bmesh: CapsuleMesh = CapsuleMesh.new()
	bmesh.radius = 0.42
	bmesh.height = 1.20
	body.mesh = bmesh
	body.position = Vector3(0, 0.65, 0)
	body.material_override = bmat
	coder.add_child(body)
	# Head sphere
	var head: MeshInstance3D = MeshInstance3D.new()
	var hm: SphereMesh = SphereMesh.new()
	hm.radius = 0.36
	hm.height = 0.72
	head.mesh = hm
	head.position = Vector3(0, 1.55, 0)
	head.material_override = bmat
	coder.add_child(head)
	# 2 white glowing eyes
	var eye_mat: StandardMaterial3D = StandardMaterial3D.new()
	eye_mat.albedo_color = Color(1, 1, 1)
	eye_mat.emission_enabled = true
	eye_mat.emission = Color(1, 1, 1)
	eye_mat.emission_energy_multiplier = 2.6
	eye_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for ex: float in [-0.10, 0.10]:
		var eye: MeshInstance3D = MeshInstance3D.new()
		var em: SphereMesh = SphereMesh.new()
		em.radius = 0.06
		em.height = 0.12
		eye.mesh = em
		eye.position = Vector3(ex, 1.55, 0.32)
		eye.material_override = eye_mat
		coder.add_child(eye)
	# Floating glowing keyboard in front
	var kb: MeshInstance3D = MeshInstance3D.new()
	var kbm: BoxMesh = BoxMesh.new()
	kbm.size = Vector3(0.85, 0.10, 0.30)
	kb.mesh = kbm
	kb.position = Vector3(0, 1.0, 0.55)
	var kbmat: StandardMaterial3D = StandardMaterial3D.new()
	kbmat.albedo_color = Color(0.04, 0.10, 0.16)
	kbmat.metallic = 0.65
	kbmat.emission_enabled = true
	kbmat.emission = Color(0.40, 1.0, 0.55)
	kbmat.emission_energy_multiplier = 1.4
	kb.material_override = kbmat
	coder.add_child(kb)
	# 9 small "key" emissive boxes on the keyboard (3x3 grid)
	for r in 3:
		for c in 3:
			var key: MeshInstance3D = MeshInstance3D.new()
			var km: BoxMesh = BoxMesh.new()
			km.size = Vector3(0.10, 0.04, 0.06)
			key.mesh = km
			key.position = Vector3(-0.30 + c * 0.30, 1.07, 0.45 + r * 0.10)
			var kmat: StandardMaterial3D = StandardMaterial3D.new()
			kmat.albedo_color = Color(0.55, 1.0, 0.55)
			kmat.emission_enabled = true
			kmat.emission = Color(0.55, 1.0, 0.55)
			kmat.emission_energy_multiplier = 2.2
			kmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
			key.material_override = kmat
			coder.add_child(key)
	# Pulse the body to feel ghostly
	var pulse: Tween = create_tween().set_loops()
	pulse.tween_property(bmat, "emission_energy_multiplier", 2.4, 1.6).set_ease(Tween.EASE_IN_OUT)
	pulse.tween_property(bmat, "emission_energy_multiplier", 0.85, 1.6).set_ease(Tween.EASE_IN_OUT)
	# Slow drift patrol
	var origin: Vector3 = D3_CENTER + Vector3(-12, 0, 4)
	var drift: Tween = create_tween().set_loops()
	drift.tween_property(coder, "position", origin + Vector3(0, 0, -8), 6.0).set_ease(Tween.EASE_IN_OUT)
	drift.tween_property(coder, "position", origin, 6.0).set_ease(Tween.EASE_IN_OUT)
	# Name billboard
	var label: Label3D = Label3D.new()
	label.text = "Lost Coder"
	label.position = Vector3(0, 2.10, 0)
	label.modulate = Color(0.85, 0.55, 1.0)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 18
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	coder.add_child(label)


func _build_d3_ancient_pillars(geom: Node) -> void:
	## Epic-3 T6: a cluster of 6 ancient violet stone pillars at varying
	## heights forming a half-circle around the great crystal — like
	## sentinels guarding the heart of the vault.
	var cluster: Node3D = Node3D.new()
	cluster.name = "D3AncientPillars"
	cluster.position = D3_CENTER + Vector3(0, 0, -10)
	geom.add_child(cluster)
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.10, 0.06, 0.18)
	stone_mat.metallic = 0.55
	stone_mat.roughness = 0.45
	stone_mat.emission_enabled = true
	stone_mat.emission = Color(0.85, 0.40, 1.0)
	stone_mat.emission_energy_multiplier = 0.30
	for i in 6:
		var t: float = float(i) / 5.0
		var angle: float = (-PI * 0.5) + t * PI
		var radius: float = 8.0
		var height: float = 4.0 + (i % 3) * 1.0
		var pillar: MeshInstance3D = MeshInstance3D.new()
		var pmesh: BoxMesh = BoxMesh.new()
		pmesh.size = Vector3(0.85, height, 0.85)
		pillar.mesh = pmesh
		pillar.position = Vector3(cos(angle) * radius, height * 0.5, sin(angle) * radius)
		pillar.material_override = stone_mat
		cluster.add_child(pillar)
		# Top crown — small pulsing emissive sphere
		var crown: MeshInstance3D = MeshInstance3D.new()
		var cm: SphereMesh = SphereMesh.new()
		cm.radius = 0.20
		cm.height = 0.40
		crown.mesh = cm
		crown.position = Vector3(cos(angle) * radius, height + 0.20, sin(angle) * radius)
		var cmat: StandardMaterial3D = StandardMaterial3D.new()
		cmat.albedo_color = Color(0.85, 0.40, 1.0)
		cmat.emission_enabled = true
		cmat.emission = Color(1.0, 0.55, 1.0)
		cmat.emission_energy_multiplier = 2.4
		cmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		crown.material_override = cmat
		cluster.add_child(crown)
		# Pulse the crown
		var pulse: Tween = create_tween().set_loops()
		pulse.tween_property(crown, "scale", Vector3(1.30, 1.30, 1.30), 1.4 + i * 0.2).set_ease(Tween.EASE_IN_OUT)
		pulse.tween_property(crown, "scale", Vector3(0.85, 0.85, 0.85), 1.4 + i * 0.2).set_ease(Tween.EASE_IN_OUT)
		# Collision per pillar
		var sb: StaticBody3D = StaticBody3D.new()
		var cs: CollisionShape3D = CollisionShape3D.new()
		var cb: BoxShape3D = BoxShape3D.new()
		cb.size = Vector3(0.85, height, 0.85)
		cs.shape = cb
		cs.position = Vector3(cos(angle) * radius, height * 0.5, sin(angle) * radius)
		sb.add_child(cs)
		cluster.add_child(sb)


func _build_d3_sigil_glyphs(geom: Node) -> void:
	## Epic-3 T7: 8 floating violet sigil glyphs drifting through the air
	## near the crystal. Each is a different ancient symbol Label3D
	## floating + slowly rotating + bobbing.
	var symbols: Array[String] = ["Δ", "Φ", "Ψ", "Ω", "Σ", "Λ", "Θ", "Ξ"]
	for i in symbols.size():
		var glyph: Node3D = Node3D.new()
		glyph.name = "D3SigilGlyph_%d" % i
		var t: float = float(i) / symbols.size()
		var angle: float = t * TAU
		glyph.position = D3_CENTER + Vector3(cos(angle) * 6.0, 3.0 + (i % 3) * 0.85, sin(angle) * 6.0)
		geom.add_child(glyph)
		# Backing card (translucent)
		var card: MeshInstance3D = MeshInstance3D.new()
		var cmesh: BoxMesh = BoxMesh.new()
		cmesh.size = Vector3(0.65, 0.65, 0.04)
		card.mesh = cmesh
		var cmat: StandardMaterial3D = StandardMaterial3D.new()
		cmat.albedo_color = Color(0.85, 0.40, 1.0, 0.30)
		cmat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		cmat.emission_enabled = true
		cmat.emission = Color(1.0, 0.55, 1.0)
		cmat.emission_energy_multiplier = 1.0
		cmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		card.material_override = cmat
		glyph.add_child(card)
		# Symbol label
		var label: Label3D = Label3D.new()
		label.text = symbols[i]
		label.position = Vector3(0, 0, 0.05)
		label.modulate = Color(1, 1, 1)
		label.outline_modulate = Color(0, 0, 0, 0.85)
		label.outline_size = 5
		label.font_size = 28
		label.no_depth_test = true
		label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		glyph.add_child(label)
		# Rotation tween
		var spin: Tween = create_tween().set_loops()
		spin.tween_property(glyph, "rotation:y", TAU, 6.0 + i * 0.5)
		# Bob tween
		var bob: Tween = create_tween().set_loops()
		var origin_y: float = glyph.position.y
		bob.tween_property(glyph, "position:y", origin_y + 0.55, 1.6 + i * 0.2).set_ease(Tween.EASE_IN_OUT)
		bob.tween_property(glyph, "position:y", origin_y, 1.6 + i * 0.2).set_ease(Tween.EASE_IN_OUT)


func _build_d3_reading_chamber(geom: Node) -> void:
	## Epic-3 T8: a small alcove reading chamber — 3-sided stone walls
	## containing a podium with a glowing tome and a stool. The "scholar's
	## corner" of the vault.
	var chamber: Node3D = Node3D.new()
	chamber.name = "D3ReadingChamber"
	chamber.position = D3_CENTER + Vector3(-15, 0, -8)
	geom.add_child(chamber)
	var wall_mat: StandardMaterial3D = StandardMaterial3D.new()
	wall_mat.albedo_color = Color(0.14, 0.10, 0.22)
	wall_mat.metallic = 0.40
	wall_mat.roughness = 0.55
	wall_mat.emission_enabled = true
	wall_mat.emission = Color(0.55, 0.30, 0.85)
	wall_mat.emission_energy_multiplier = 0.30
	# Back wall
	var back: MeshInstance3D = MeshInstance3D.new()
	var bm: BoxMesh = BoxMesh.new()
	bm.size = Vector3(3.40, 3.40, 0.30)
	back.mesh = bm
	back.position = Vector3(0, 1.70, -1.40)
	back.material_override = wall_mat
	chamber.add_child(back)
	# Side walls
	for sx: float in [-1.55, 1.55]:
		var side: MeshInstance3D = MeshInstance3D.new()
		var sm: BoxMesh = BoxMesh.new()
		sm.size = Vector3(0.30, 3.40, 2.80)
		side.mesh = sm
		side.position = Vector3(sx, 1.70, 0)
		side.material_override = wall_mat
		chamber.add_child(side)
	# Podium in the center
	var podium_mat: StandardMaterial3D = StandardMaterial3D.new()
	podium_mat.albedo_color = Color(0.20, 0.16, 0.26)
	podium_mat.metallic = 0.55
	var podium: MeshInstance3D = MeshInstance3D.new()
	var pm: BoxMesh = BoxMesh.new()
	pm.size = Vector3(0.85, 1.20, 0.55)
	podium.mesh = pm
	podium.position = Vector3(0, 0.60, -0.55)
	podium.material_override = podium_mat
	chamber.add_child(podium)
	# Glowing tome on the podium
	var tome: MeshInstance3D = MeshInstance3D.new()
	var tm: BoxMesh = BoxMesh.new()
	tm.size = Vector3(0.55, 0.10, 0.40)
	tome.mesh = tm
	tome.position = Vector3(0, 1.30, -0.55)
	tome.rotation = Vector3(deg_to_rad(-20), 0, 0)
	var tmat: StandardMaterial3D = StandardMaterial3D.new()
	tmat.albedo_color = Color(0.85, 0.40, 1.0)
	tmat.emission_enabled = true
	tmat.emission = Color(1.0, 0.55, 1.0)
	tmat.emission_energy_multiplier = 1.6
	tmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	tome.material_override = tmat
	chamber.add_child(tome)
	# Floating page glyph above the tome (a small pulsing prism)
	var page: MeshInstance3D = MeshInstance3D.new()
	var pg: PrismMesh = PrismMesh.new()
	pg.size = Vector3(0.20, 0.30, 0.06)
	page.mesh = pg
	page.position = Vector3(0, 1.85, -0.55)
	var pgmat: StandardMaterial3D = StandardMaterial3D.new()
	pgmat.albedo_color = Color(1, 1, 1)
	pgmat.emission_enabled = true
	pgmat.emission = Color(1, 1, 1)
	pgmat.emission_energy_multiplier = 2.6
	pgmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	page.material_override = pgmat
	chamber.add_child(page)
	var bob: Tween = create_tween().set_loops()
	bob.tween_property(page, "position:y", 2.10, 1.4).set_ease(Tween.EASE_IN_OUT)
	bob.tween_property(page, "position:y", 1.85, 1.4).set_ease(Tween.EASE_IN_OUT)
	# Stool in front
	var stool: MeshInstance3D = MeshInstance3D.new()
	var sm2: CylinderMesh = CylinderMesh.new()
	sm2.top_radius = 0.22
	sm2.bottom_radius = 0.22
	sm2.height = 0.55
	stool.mesh = sm2
	stool.position = Vector3(0, 0.27, 0.65)
	stool.material_override = podium_mat
	chamber.add_child(stool)
	# Sign
	var label: Label3D = Label3D.new()
	label.text = "READING\nCHAMBER"
	label.position = Vector3(0, 3.85, 0)
	label.modulate = Color(0.85, 0.55, 1.0)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 16
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	chamber.add_child(label)
	# Collision around the back wall + sides
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(3.40, 3.40, 2.80)
	cs.shape = cb
	cs.position = Vector3(0, 1.70, 0)
	sb.add_child(cs)
	chamber.add_child(sb)


func _build_d3_memory_shards(geom: Node) -> void:
	## Epic-3 T9: 8 small floating "memory shard" prism collectibles
	## scattered around the great crystal — like Epic 1's data shards but
	## violet. Spinning + bobbing decorative collectibles.
	var positions: Array[Vector3] = [
		D3_CENTER + Vector3(-6, 1.2, -4),
		D3_CENTER + Vector3(6, 1.2, -4),
		D3_CENTER + Vector3(-6, 1.2, 4),
		D3_CENTER + Vector3(6, 1.2, 4),
		D3_CENTER + Vector3(-10, 1.2, 0),
		D3_CENTER + Vector3(10, 1.2, 0),
		D3_CENTER + Vector3(0, 1.2, -10),
		D3_CENTER + Vector3(0, 1.2, 10),
	]
	var shard_mat: StandardMaterial3D = StandardMaterial3D.new()
	shard_mat.albedo_color = Color(0.85, 0.40, 1.0)
	shard_mat.emission_enabled = true
	shard_mat.emission = Color(1.0, 0.55, 1.0)
	shard_mat.emission_energy_multiplier = 2.4
	shard_mat.metallic = 0.40
	shard_mat.roughness = 0.10
	shard_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for i in positions.size():
		var shard: MeshInstance3D = MeshInstance3D.new()
		shard.name = "D3MemoryShard_%d" % i
		var smesh: PrismMesh = PrismMesh.new()
		smesh.size = Vector3(0.30, 0.55, 0.30)
		shard.mesh = smesh
		shard.position = positions[i]
		shard.material_override = shard_mat
		geom.add_child(shard)
		# Spin
		var spin: Tween = create_tween().set_loops()
		spin.tween_property(shard, "rotation:y", TAU, 3.0 + i * 0.2)
		# Bob
		var bob: Tween = create_tween().set_loops()
		var origin_y: float = positions[i].y
		bob.tween_property(shard, "position:y", origin_y + 0.40, 1.4).set_ease(Tween.EASE_IN_OUT)
		bob.tween_property(shard, "position:y", origin_y, 1.4).set_ease(Tween.EASE_IN_OUT)


func _build_d3_archivist_npc() -> void:
	## Epic-3 T10: Archivist NPC standing inside the reading chamber.
	## Tall robed figure with a glowing scroll case slung over one shoulder
	## and a single bright violet eye on the head.
	var slots: Node3D = get_node_or_null("%NPCSlots") as Node3D
	if slots == null:
		return
	var arch: Node3D = Node3D.new()
	arch.name = "D3Archivist"
	arch.position = D3_CENTER + Vector3(-15, 0, -7)
	slots.add_child(arch)
	# Robed body
	var bmat: StandardMaterial3D = StandardMaterial3D.new()
	bmat.albedo_color = Color(0.16, 0.10, 0.22)
	bmat.metallic = 0.30
	bmat.roughness = 0.55
	bmat.emission_enabled = true
	bmat.emission = Color(0.55, 0.30, 0.85)
	bmat.emission_energy_multiplier = 0.40
	var body: MeshInstance3D = MeshInstance3D.new()
	var bmesh: CapsuleMesh = CapsuleMesh.new()
	bmesh.radius = 0.45
	bmesh.height = 1.40
	body.mesh = bmesh
	body.position = Vector3(0, 0.70, 0)
	body.material_override = bmat
	arch.add_child(body)
	# Wide hood
	var hood: MeshInstance3D = MeshInstance3D.new()
	var hmesh: SphereMesh = SphereMesh.new()
	hmesh.radius = 0.50
	hmesh.height = 0.65
	hood.mesh = hmesh
	hood.position = Vector3(0, 1.55, 0)
	hood.material_override = bmat
	arch.add_child(hood)
	# Single bright violet eye
	var eye: MeshInstance3D = MeshInstance3D.new()
	var em: SphereMesh = SphereMesh.new()
	em.radius = 0.10
	em.height = 0.20
	eye.mesh = em
	eye.position = Vector3(0, 1.45, 0.36)
	var emat: StandardMaterial3D = StandardMaterial3D.new()
	emat.albedo_color = Color(1.0, 0.55, 1.0)
	emat.emission_enabled = true
	emat.emission = Color(1.0, 0.55, 1.0)
	emat.emission_energy_multiplier = 3.0
	emat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	eye.material_override = emat
	arch.add_child(eye)
	# Scroll case slung over shoulder — long cylinder at angle
	var case_mat: StandardMaterial3D = StandardMaterial3D.new()
	case_mat.albedo_color = Color(0.30, 0.20, 0.10)
	case_mat.metallic = 0.40
	case_mat.roughness = 0.55
	case_mat.emission_enabled = true
	case_mat.emission = Color(1.0, 0.65, 0.20)
	case_mat.emission_energy_multiplier = 0.55
	var scroll_case: MeshInstance3D = MeshInstance3D.new()
	var scmesh: CylinderMesh = CylinderMesh.new()
	scmesh.top_radius = 0.10
	scmesh.bottom_radius = 0.10
	scmesh.height = 0.85
	scroll_case.mesh = scmesh
	scroll_case.position = Vector3(0.40, 1.0, -0.20)
	scroll_case.rotation = Vector3(0, 0, deg_to_rad(35))
	scroll_case.material_override = case_mat
	arch.add_child(scroll_case)
	# Pulse eye
	var pulse: Tween = create_tween().set_loops()
	pulse.tween_property(emat, "emission_energy_multiplier", 4.0, 1.0).set_ease(Tween.EASE_IN_OUT)
	pulse.tween_property(emat, "emission_energy_multiplier", 2.0, 1.0).set_ease(Tween.EASE_IN_OUT)
	# Name billboard
	var label: Label3D = Label3D.new()
	label.text = "Archivist"
	label.position = Vector3(0, 2.20, 0)
	label.modulate = Color(0.85, 0.55, 1.0)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 18
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	arch.add_child(label)


func _build_d3_codex_pages(geom: Node) -> void:
	## Epic-3 T11: 12 drifting "codex pages" — small thin translucent
	## boxes floating across the vault on independent paths, each with
	## a small Label3D rune symbol on it.
	var pages_root: Node3D = Node3D.new()
	pages_root.name = "D3CodexPages"
	geom.add_child(pages_root)
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 121
	var symbols: Array[String] = ["α", "β", "γ", "δ", "ε", "ζ"]
	for i in 12:
		var page: MeshInstance3D = MeshInstance3D.new()
		page.name = "CodexPage_%d" % i
		var pmesh: BoxMesh = BoxMesh.new()
		pmesh.size = Vector3(0.40, 0.55, 0.04)
		page.mesh = pmesh
		page.position = D3_CENTER + Vector3(
			rng.randf_range(-22, 22),
			rng.randf_range(2, 8),
			rng.randf_range(-16, 16)
		)
		var pmat: StandardMaterial3D = StandardMaterial3D.new()
		pmat.albedo_color = Color(0.95, 0.85, 0.65, 0.75)
		pmat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		pmat.emission_enabled = true
		pmat.emission = Color(1.0, 0.85, 0.55)
		pmat.emission_energy_multiplier = 0.85
		pmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		page.material_override = pmat
		pages_root.add_child(page)
		# Symbol on page
		var label: Label3D = Label3D.new()
		label.text = symbols[i % symbols.size()]
		label.position = page.position + Vector3(0, 0, 0.04)
		label.modulate = Color(0.30, 0.10, 0.40)
		label.outline_size = 0
		label.font_size = 18
		label.no_depth_test = true
		label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		pages_root.add_child(label)
		# Drift tween
		var origin: Vector3 = page.position
		var drift: Tween = create_tween().set_loops()
		var wp1: Vector3 = origin + Vector3(rng.randf_range(-3, 3), rng.randf_range(-1, 1), rng.randf_range(-3, 3))
		var wp2: Vector3 = origin + Vector3(rng.randf_range(-3, 3), rng.randf_range(-1, 1), rng.randf_range(-3, 3))
		drift.tween_property(page, "position", wp1, 5.0).set_ease(Tween.EASE_IN_OUT)
		drift.tween_property(page, "position", wp2, 5.0).set_ease(Tween.EASE_IN_OUT)
		drift.tween_property(page, "position", origin, 5.0).set_ease(Tween.EASE_IN_OUT)
		# Tumble
		var tumble: Tween = create_tween().set_loops()
		tumble.tween_property(page, "rotation", Vector3(TAU, TAU * 0.5, 0), 7.0)


func _build_d3_spiral_stair(geom: Node) -> void:
	## Epic-3 T12: a tall spiral knowledge staircase landmark — 12 steps
	## winding upward around a central column, each step with a small
	## emissive trim. Decorative climb-tower on the side of the district.
	var stair: Node3D = Node3D.new()
	stair.name = "D3SpiralStair"
	stair.position = D3_CENTER + Vector3(15, 0, -12)
	geom.add_child(stair)
	# Center column
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.10, 0.06, 0.18)
	stone_mat.metallic = 0.55
	stone_mat.roughness = 0.45
	var col: MeshInstance3D = MeshInstance3D.new()
	var cmesh: CylinderMesh = CylinderMesh.new()
	cmesh.top_radius = 0.55
	cmesh.bottom_radius = 0.65
	cmesh.height = 7.0
	col.mesh = cmesh
	col.position = Vector3(0, 3.5, 0)
	col.material_override = stone_mat
	stair.add_child(col)
	# 12 steps spiraling upward
	for i in 12:
		var t: float = float(i) / 12.0
		var angle: float = t * TAU * 1.5
		var height: float = 0.3 + i * 0.55
		var step_root: Node3D = Node3D.new()
		step_root.position = Vector3(cos(angle) * 1.20, height, sin(angle) * 1.20)
		step_root.rotation = Vector3(0, -angle, 0)
		stair.add_child(step_root)
		# Step slab
		var step: MeshInstance3D = MeshInstance3D.new()
		var sm: BoxMesh = BoxMesh.new()
		sm.size = Vector3(1.40, 0.20, 0.85)
		step.mesh = sm
		step.material_override = stone_mat
		step_root.add_child(step)
		# Glowing edge trim
		var trim: MeshInstance3D = MeshInstance3D.new()
		var tm: BoxMesh = BoxMesh.new()
		tm.size = Vector3(1.40, 0.06, 0.06)
		trim.mesh = tm
		trim.position = Vector3(0, 0.15, 0.42)
		var tmat: StandardMaterial3D = StandardMaterial3D.new()
		tmat.albedo_color = Color(0.85, 0.40, 1.0)
		tmat.emission_enabled = true
		tmat.emission = Color(1.0, 0.55, 1.0)
		tmat.emission_energy_multiplier = 1.8
		tmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		trim.material_override = tmat
		step_root.add_child(trim)
		# Per-step collision
		var sb: StaticBody3D = StaticBody3D.new()
		var cs: CollisionShape3D = CollisionShape3D.new()
		var cb: BoxShape3D = BoxShape3D.new()
		cb.size = Vector3(1.40, 0.20, 0.85)
		cs.shape = cb
		sb.add_child(cs)
		step_root.add_child(sb)
	# Top crown — pulsing violet sphere
	var crown: MeshInstance3D = MeshInstance3D.new()
	var crmesh: SphereMesh = SphereMesh.new()
	crmesh.radius = 0.45
	crmesh.height = 0.90
	crown.mesh = crmesh
	crown.position = Vector3(0, 7.85, 0)
	var crmat: StandardMaterial3D = StandardMaterial3D.new()
	crmat.albedo_color = Color(0.85, 0.40, 1.0)
	crmat.emission_enabled = true
	crmat.emission = Color(1.0, 0.55, 1.0)
	crmat.emission_energy_multiplier = 2.6
	crmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	crown.material_override = crmat
	stair.add_child(crown)
	var pulse: Tween = create_tween().set_loops()
	pulse.tween_property(crown, "scale", Vector3(1.30, 1.30, 1.30), 1.8).set_ease(Tween.EASE_IN_OUT)
	pulse.tween_property(crown, "scale", Vector3(0.85, 0.85, 0.85), 1.8).set_ease(Tween.EASE_IN_OUT)
	# Collision around the central column
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cap: CapsuleShape3D = CapsuleShape3D.new()
	cap.radius = 0.65
	cap.height = 7.0
	cs.shape = cap
	cs.position = Vector3(0, 3.5, 0)
	sb.add_child(cs)
	stair.add_child(sb)


func _build_d3_wisp_enemy(geom: Node) -> void:
	## Epic-3 T13: 4 small floating wisp enemies — pulsing emissive
	## spheres with trailing tail particles, drifting through the vault.
	var positions: Array[Vector3] = [
		D3_CENTER + Vector3(-8, 2.5, 8),
		D3_CENTER + Vector3(10, 3.0, -6),
		D3_CENTER + Vector3(-12, 2.0, -4),
		D3_CENTER + Vector3(14, 2.5, 10),
	]
	for i in positions.size():
		var wisp: Node3D = Node3D.new()
		wisp.name = "D3Wisp_%d" % i
		wisp.position = positions[i]
		geom.add_child(wisp)
		# Core sphere
		var core: MeshInstance3D = MeshInstance3D.new()
		var cm: SphereMesh = SphereMesh.new()
		cm.radius = 0.30
		cm.height = 0.60
		core.mesh = cm
		var cmat: StandardMaterial3D = StandardMaterial3D.new()
		cmat.albedo_color = Color(0.85, 0.40, 1.0)
		cmat.emission_enabled = true
		cmat.emission = Color(1.0, 0.55, 1.0)
		cmat.emission_energy_multiplier = 3.0
		cmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		core.material_override = cmat
		wisp.add_child(core)
		# Pulse the core
		var pulse: Tween = create_tween().set_loops()
		pulse.tween_property(core, "scale", Vector3(1.40, 1.40, 1.40), 0.8).set_ease(Tween.EASE_IN_OUT)
		pulse.tween_property(core, "scale", Vector3(0.85, 0.85, 0.85), 0.8).set_ease(Tween.EASE_IN_OUT)
		# Trailing tail particles
		var tail: GPUParticles3D = GPUParticles3D.new()
		tail.amount = 30
		tail.lifetime = 0.85
		var pmat: ParticleProcessMaterial = ParticleProcessMaterial.new()
		pmat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
		pmat.emission_sphere_radius = 0.20
		pmat.direction = Vector3(0, -0.5, 0)
		pmat.spread = 30.0
		pmat.initial_velocity_min = 0.30
		pmat.initial_velocity_max = 0.65
		pmat.gravity = Vector3.ZERO
		pmat.scale_min = 0.10
		pmat.scale_max = 0.20
		pmat.color = Color(1.0, 0.55, 1.0, 1.0)
		tail.process_material = pmat
		var pm: SphereMesh = SphereMesh.new()
		pm.radius = 0.10
		pm.height = 0.20
		var pmm: StandardMaterial3D = StandardMaterial3D.new()
		pmm.albedo_color = Color(1.0, 0.55, 1.0)
		pmm.emission_enabled = true
		pmm.emission = Color(1.0, 0.55, 1.0)
		pmm.emission_energy_multiplier = 2.2
		pmm.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		pm.material = pmm
		tail.draw_pass_1 = pm
		wisp.add_child(tail)
		# Slow drift patrol
		var origin: Vector3 = positions[i]
		var drift: Tween = create_tween().set_loops()
		drift.tween_property(wisp, "position", origin + Vector3(3, 0.8, 3), 4.0).set_ease(Tween.EASE_IN_OUT)
		drift.tween_property(wisp, "position", origin + Vector3(-3, -0.8, 3), 4.0).set_ease(Tween.EASE_IN_OUT)
		drift.tween_property(wisp, "position", origin + Vector3(-3, 0.8, -3), 4.0).set_ease(Tween.EASE_IN_OUT)
		drift.tween_property(wisp, "position", origin, 4.0).set_ease(Tween.EASE_IN_OUT)


func _build_d3_vault_keeper_npc() -> void:
	## Epic-3 T14: Vault Keeper NPC — large statue-like guardian standing
	## still by the entrance arch. Has a key motif on chest and golden eyes.
	var slots: Node3D = get_node_or_null("%NPCSlots") as Node3D
	if slots == null:
		return
	var keeper: Node3D = Node3D.new()
	keeper.name = "D3VaultKeeper"
	keeper.position = Vector3(125, 0, -3)
	slots.add_child(keeper)
	# Tall stone body
	var bmat: StandardMaterial3D = StandardMaterial3D.new()
	bmat.albedo_color = Color(0.18, 0.14, 0.24)
	bmat.metallic = 0.40
	bmat.roughness = 0.55
	bmat.emission_enabled = true
	bmat.emission = Color(0.55, 0.30, 0.85)
	bmat.emission_energy_multiplier = 0.40
	var body: MeshInstance3D = MeshInstance3D.new()
	var bmesh: BoxMesh = BoxMesh.new()
	bmesh.size = Vector3(1.20, 2.20, 0.85)
	body.mesh = bmesh
	body.position = Vector3(0, 1.10, 0)
	body.material_override = bmat
	keeper.add_child(body)
	# Head — square
	var head: MeshInstance3D = MeshInstance3D.new()
	var hm: BoxMesh = BoxMesh.new()
	hm.size = Vector3(0.85, 0.85, 0.85)
	head.mesh = hm
	head.position = Vector3(0, 2.65, 0)
	head.material_override = bmat
	keeper.add_child(head)
	# 2 golden eyes
	var eye_mat: StandardMaterial3D = StandardMaterial3D.new()
	eye_mat.albedo_color = Color(1.0, 0.85, 0.30)
	eye_mat.emission_enabled = true
	eye_mat.emission = Color(1.0, 0.95, 0.30)
	eye_mat.emission_energy_multiplier = 2.6
	eye_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for ex: float in [-0.18, 0.18]:
		var eye: MeshInstance3D = MeshInstance3D.new()
		var em: SphereMesh = SphereMesh.new()
		em.radius = 0.10
		em.height = 0.20
		eye.mesh = em
		eye.position = Vector3(ex, 2.70, 0.45)
		eye.material_override = eye_mat
		keeper.add_child(eye)
	# Key motif on chest — a thin emissive cross + circle
	var key_mat: StandardMaterial3D = StandardMaterial3D.new()
	key_mat.albedo_color = Color(1.0, 0.85, 0.30)
	key_mat.emission_enabled = true
	key_mat.emission = Color(1.0, 0.95, 0.30)
	key_mat.emission_energy_multiplier = 1.8
	key_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	# Vertical bar
	var v_bar: MeshInstance3D = MeshInstance3D.new()
	var vm: BoxMesh = BoxMesh.new()
	vm.size = Vector3(0.10, 0.85, 0.04)
	v_bar.mesh = vm
	v_bar.position = Vector3(0, 1.40, 0.45)
	v_bar.material_override = key_mat
	keeper.add_child(v_bar)
	# Horizontal bar
	var h_bar: MeshInstance3D = MeshInstance3D.new()
	var hbm: BoxMesh = BoxMesh.new()
	hbm.size = Vector3(0.40, 0.10, 0.04)
	h_bar.mesh = hbm
	h_bar.position = Vector3(0, 1.55, 0.45)
	h_bar.material_override = key_mat
	keeper.add_child(h_bar)
	# Circle bow at top of key
	var bow: MeshInstance3D = MeshInstance3D.new()
	var bowm: SphereMesh = SphereMesh.new()
	bowm.radius = 0.18
	bowm.height = 0.36
	bow.mesh = bowm
	bow.position = Vector3(0, 1.85, 0.45)
	bow.material_override = key_mat
	keeper.add_child(bow)
	# Name billboard
	var label: Label3D = Label3D.new()
	label.text = "Vault Keeper"
	label.position = Vector3(0, 3.30, 0)
	label.modulate = Color(1.0, 0.85, 0.30)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 18
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	keeper.add_child(label)


func _build_d3_memory_pool(geom: Node) -> void:
	## Epic-3 T15: a small circular memory pool — torus rim around a
	## glowing translucent disc. Bubbling violet "data" rises from it.
	var pool: Node3D = Node3D.new()
	pool.name = "D3MemoryPool"
	pool.position = D3_CENTER + Vector3(15, 0, 8)
	geom.add_child(pool)
	# Stone rim
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.16, 0.10, 0.20)
	stone_mat.metallic = 0.55
	stone_mat.roughness = 0.45
	var rim: MeshInstance3D = MeshInstance3D.new()
	var rmesh: TorusMesh = TorusMesh.new()
	rmesh.inner_radius = 1.40
	rmesh.outer_radius = 1.85
	rim.mesh = rmesh
	rim.position = Vector3(0, 0.20, 0)
	rim.material_override = stone_mat
	pool.add_child(rim)
	# Inner pool surface — glowing violet disc
	var surface: MeshInstance3D = MeshInstance3D.new()
	var sm: CylinderMesh = CylinderMesh.new()
	sm.top_radius = 1.40
	sm.bottom_radius = 1.40
	sm.height = 0.06
	surface.mesh = sm
	surface.position = Vector3(0, 0.20, 0)
	var smat: StandardMaterial3D = StandardMaterial3D.new()
	smat.albedo_color = Color(0.85, 0.40, 1.0, 0.85)
	smat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	smat.emission_enabled = true
	smat.emission = Color(1.0, 0.55, 1.0)
	smat.emission_energy_multiplier = 1.8
	smat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	surface.material_override = smat
	pool.add_child(surface)
	# Ripple tween
	var ripple: Tween = create_tween().set_loops()
	ripple.tween_property(surface, "scale", Vector3(1.05, 1.0, 0.96), 1.6).set_ease(Tween.EASE_IN_OUT)
	ripple.tween_property(surface, "scale", Vector3(0.96, 1.0, 1.05), 1.6).set_ease(Tween.EASE_IN_OUT)
	# Bubbling violet particles rising from the surface
	var bubbles: GPUParticles3D = GPUParticles3D.new()
	bubbles.amount = 30
	bubbles.lifetime = 2.5
	bubbles.position = Vector3(0, 0.30, 0)
	var pmat: ParticleProcessMaterial = ParticleProcessMaterial.new()
	pmat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	pmat.emission_sphere_radius = 1.20
	pmat.direction = Vector3(0, 1, 0)
	pmat.spread = 12.0
	pmat.initial_velocity_min = 0.55
	pmat.initial_velocity_max = 1.0
	pmat.gravity = Vector3.ZERO
	pmat.scale_min = 0.10
	pmat.scale_max = 0.20
	pmat.color = Color(1.0, 0.55, 1.0, 1.0)
	bubbles.process_material = pmat
	var bm: SphereMesh = SphereMesh.new()
	bm.radius = 0.10
	bm.height = 0.20
	var bm_mat: StandardMaterial3D = StandardMaterial3D.new()
	bm_mat.albedo_color = Color(1.0, 0.55, 1.0)
	bm_mat.emission_enabled = true
	bm_mat.emission = Color(1.0, 0.55, 1.0)
	bm_mat.emission_energy_multiplier = 2.6
	bm_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	bm.material = bm_mat
	bubbles.draw_pass_1 = bm
	pool.add_child(bubbles)
	# Sign
	var label: Label3D = Label3D.new()
	label.text = "MEMORY POOL"
	label.position = Vector3(0, 1.85, 0)
	label.modulate = Color(1.0, 0.55, 1.0)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 16
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	pool.add_child(label)


func _build_d3_floating_bookshelves(geom: Node) -> void:
	## Epic-3 T16: 4 floating bookshelves drifting at different altitudes,
	## each holding 5 colored book spines glowing inside.
	var positions: Array[Vector3] = [
		D3_CENTER + Vector3(-18, 3.5, 4),
		D3_CENTER + Vector3(-18, 4.5, -2),
		D3_CENTER + Vector3(18, 3.5, 4),
		D3_CENTER + Vector3(18, 4.5, -2),
	]
	var shelf_mat: StandardMaterial3D = StandardMaterial3D.new()
	shelf_mat.albedo_color = Color(0.30, 0.18, 0.10)
	shelf_mat.metallic = 0.20
	shelf_mat.roughness = 0.65
	shelf_mat.emission_enabled = true
	shelf_mat.emission = Color(0.85, 0.40, 1.0)
	shelf_mat.emission_energy_multiplier = 0.45
	for i in positions.size():
		var shelf: Node3D = Node3D.new()
		shelf.name = "D3FloatingShelf_%d" % i
		shelf.position = positions[i]
		geom.add_child(shelf)
		# Shelf box
		var body: MeshInstance3D = MeshInstance3D.new()
		var bm: BoxMesh = BoxMesh.new()
		bm.size = Vector3(1.85, 0.85, 0.45)
		body.mesh = bm
		body.material_override = shelf_mat
		shelf.add_child(body)
		# 5 colored book spines
		var book_colors: Array[Color] = [
			Color(0.55, 0.30, 0.30),
			Color(0.30, 0.55, 0.30),
			Color(0.30, 0.30, 0.55),
			Color(0.55, 0.55, 0.30),
			Color(0.55, 0.30, 0.55),
		]
		for b in 5:
			var book: MeshInstance3D = MeshInstance3D.new()
			var bkm: BoxMesh = BoxMesh.new()
			bkm.size = Vector3(0.30, 0.65, 0.04)
			book.mesh = bkm
			book.position = Vector3(-0.65 + b * 0.32, 0, 0.20)
			var bkmat: StandardMaterial3D = StandardMaterial3D.new()
			bkmat.albedo_color = book_colors[b]
			bkmat.emission_enabled = true
			bkmat.emission = book_colors[b]
			bkmat.emission_energy_multiplier = 1.4
			bkmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
			book.material_override = bkmat
			shelf.add_child(book)
		# Bob tween
		var origin_y: float = positions[i].y
		var bob: Tween = create_tween().set_loops()
		bob.tween_property(shelf, "position:y", origin_y + 0.40, 1.8 + i * 0.2).set_ease(Tween.EASE_IN_OUT)
		bob.tween_property(shelf, "position:y", origin_y, 1.8 + i * 0.2).set_ease(Tween.EASE_IN_OUT)
		# Slow rotation
		var spin: Tween = create_tween().set_loops()
		spin.tween_property(shelf, "rotation:y", TAU, 18.0 + i * 2)


func _build_d3_stone_benches(geom: Node) -> void:
	## Epic-3 T17: 5 stone benches arranged in a semicircle facing the
	## great crystal — meditation seating for the vault scholars.
	var bench_mat: StandardMaterial3D = StandardMaterial3D.new()
	bench_mat.albedo_color = Color(0.16, 0.10, 0.20)
	bench_mat.metallic = 0.40
	bench_mat.roughness = 0.55
	bench_mat.emission_enabled = true
	bench_mat.emission = Color(0.55, 0.30, 0.85)
	bench_mat.emission_energy_multiplier = 0.30
	for i in 5:
		var t: float = float(i) / 4.0
		var angle: float = (-PI * 0.5) + t * PI + PI  # facing the crystal
		var radius: float = 6.5
		var bench: Node3D = Node3D.new()
		bench.name = "D3Bench_%d" % i
		bench.position = D3_CENTER + Vector3(cos(angle) * radius, 0, sin(angle) * radius)
		bench.rotation = Vector3(0, -angle, 0)
		geom.add_child(bench)
		# Top slab
		var slab: MeshInstance3D = MeshInstance3D.new()
		var sm: BoxMesh = BoxMesh.new()
		sm.size = Vector3(1.85, 0.20, 0.55)
		slab.mesh = sm
		slab.position = Vector3(0, 0.55, 0)
		slab.material_override = bench_mat
		bench.add_child(slab)
		# 2 stubby legs
		for sx: float in [-0.65, 0.65]:
			var leg: MeshInstance3D = MeshInstance3D.new()
			var lm: BoxMesh = BoxMesh.new()
			lm.size = Vector3(0.30, 0.45, 0.45)
			leg.mesh = lm
			leg.position = Vector3(sx, 0.22, 0)
			leg.material_override = bench_mat
			bench.add_child(leg)
		# Per-bench collision
		var sb: StaticBody3D = StaticBody3D.new()
		var cs: CollisionShape3D = CollisionShape3D.new()
		var cb: BoxShape3D = BoxShape3D.new()
		cb.size = Vector3(1.85, 0.65, 0.55)
		cs.shape = cb
		cs.position = Vector3(0, 0.32, 0)
		sb.add_child(cs)
		bench.add_child(sb)


func _build_d3_ritual_circle(geom: Node) -> void:
	## Epic-3 T18: a 5m violet ritual circle on the ground in front of the
	## great crystal — concentric torus rings + 8 small rune dots in a
	## ring + a center pulsing star.
	var ring_root: Node3D = Node3D.new()
	ring_root.name = "D3RitualCircle"
	ring_root.position = D3_CENTER + Vector3(0, 0.06, 0)
	geom.add_child(ring_root)
	var ring_mat: StandardMaterial3D = StandardMaterial3D.new()
	ring_mat.albedo_color = Color(0.85, 0.40, 1.0)
	ring_mat.emission_enabled = true
	ring_mat.emission = Color(1.0, 0.55, 1.0)
	ring_mat.emission_energy_multiplier = 1.8
	ring_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	# 2 concentric rings
	for r in 2:
		var ring: MeshInstance3D = MeshInstance3D.new()
		var rmesh: TorusMesh = TorusMesh.new()
		rmesh.inner_radius = 4.0 + r * 0.40
		rmesh.outer_radius = 4.20 + r * 0.40
		ring.mesh = rmesh
		ring.material_override = ring_mat
		ring_root.add_child(ring)
		# Slow rotation
		var spin: Tween = create_tween().set_loops()
		spin.tween_property(ring, "rotation:y", TAU * (1 if r % 2 == 0 else -1), 22.0 + r * 4)
	# 8 small rune dots in a ring inside
	for i in 8:
		var angle: float = (float(i) / 8.0) * TAU
		var dot: MeshInstance3D = MeshInstance3D.new()
		var dm: SphereMesh = SphereMesh.new()
		dm.radius = 0.18
		dm.height = 0.36
		dot.mesh = dm
		dot.position = Vector3(cos(angle) * 3.40, 0.10, sin(angle) * 3.40)
		dot.material_override = ring_mat
		ring_root.add_child(dot)
	# Center 4-prong pulsing star
	for i in 4:
		var angle: float = (float(i) / 4.0) * TAU
		var prong: MeshInstance3D = MeshInstance3D.new()
		var pm: BoxMesh = BoxMesh.new()
		pm.size = Vector3(0.20, 0.04, 1.40)
		prong.mesh = pm
		prong.position = Vector3(0, 0.10, 0)
		prong.rotation = Vector3(0, -angle, 0)
		prong.material_override = ring_mat
		ring_root.add_child(prong)
	# Pulse the entire circle scale
	var pulse: Tween = create_tween().set_loops()
	pulse.tween_property(ring_root, "scale", Vector3(1.06, 1.0, 1.06), 2.4).set_ease(Tween.EASE_IN_OUT)
	pulse.tween_property(ring_root, "scale", Vector3(0.96, 1.0, 0.96), 2.4).set_ease(Tween.EASE_IN_OUT)


func _build_d3_war_banners(geom: Node) -> void:
	## Epic-3 T19: 4 ancient war banners hanging from tall stone poles —
	## long violet cloth panels with rune symbols. Tells "ancient battles
	## happened here, the vault commemorates fallen mages".
	var positions: Array[Vector3] = [
		D3_CENTER + Vector3(-22, 0, -8),
		D3_CENTER + Vector3(-22, 0, 8),
		D3_CENTER + Vector3(22, 0, -8),
		D3_CENTER + Vector3(22, 0, 8),
	]
	var pole_mat: StandardMaterial3D = StandardMaterial3D.new()
	pole_mat.albedo_color = Color(0.10, 0.06, 0.18)
	pole_mat.metallic = 0.55
	pole_mat.roughness = 0.45
	var banner_mat: StandardMaterial3D = StandardMaterial3D.new()
	banner_mat.albedo_color = Color(0.20, 0.10, 0.30)
	banner_mat.emission_enabled = true
	banner_mat.emission = Color(0.85, 0.40, 1.0)
	banner_mat.emission_energy_multiplier = 0.95
	banner_mat.metallic = 0.10
	banner_mat.roughness = 0.55
	for i in positions.size():
		var banner_root: Node3D = Node3D.new()
		banner_root.name = "D3WarBanner_%d" % i
		banner_root.position = positions[i]
		geom.add_child(banner_root)
		# Tall pole
		var pole: MeshInstance3D = MeshInstance3D.new()
		var pmesh: CylinderMesh = CylinderMesh.new()
		pmesh.top_radius = 0.10
		pmesh.bottom_radius = 0.14
		pmesh.height = 6.5
		pole.mesh = pmesh
		pole.position = Vector3(0, 3.25, 0)
		pole.material_override = pole_mat
		banner_root.add_child(pole)
		# Hanging banner cloth
		var banner: MeshInstance3D = MeshInstance3D.new()
		var bm: BoxMesh = BoxMesh.new()
		bm.size = Vector3(1.40, 3.0, 0.06)
		banner.mesh = bm
		banner.position = Vector3(0.85, 4.85, 0)
		banner.material_override = banner_mat
		banner_root.add_child(banner)
		# Rune symbol on banner
		var rune: Label3D = Label3D.new()
		var symbols: Array[String] = ["Ψ", "Ω", "Φ", "Δ"]
		rune.text = symbols[i]
		rune.position = Vector3(0.85, 4.85, 0.05)
		rune.modulate = Color(1, 1, 1)
		rune.outline_modulate = Color(0, 0, 0, 0.85)
		rune.outline_size = 5
		rune.font_size = 38
		rune.no_depth_test = true
		banner_root.add_child(rune)
		# Top pole crown
		var crown: MeshInstance3D = MeshInstance3D.new()
		var cm: SphereMesh = SphereMesh.new()
		cm.radius = 0.18
		cm.height = 0.36
		crown.mesh = cm
		crown.position = Vector3(0, 6.65, 0)
		var cmat: StandardMaterial3D = StandardMaterial3D.new()
		cmat.albedo_color = Color(0.85, 0.40, 1.0)
		cmat.emission_enabled = true
		cmat.emission = Color(1.0, 0.55, 1.0)
		cmat.emission_energy_multiplier = 2.4
		cmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		crown.material_override = cmat
		banner_root.add_child(crown)
		# Collision on pole
		var sb: StaticBody3D = StaticBody3D.new()
		var cs: CollisionShape3D = CollisionShape3D.new()
		var cap: CapsuleShape3D = CapsuleShape3D.new()
		cap.radius = 0.20
		cap.height = 6.5
		cs.shape = cap
		cs.position = Vector3(0, 3.25, 0)
		sb.add_child(cs)
		banner_root.add_child(sb)


func _build_d3_acolyte_npc() -> void:
	## Epic-3 T20: Acolyte NPC sitting cross-legged on one of the stone
	## benches, meditating with hands clasped in front and eyes closed.
	## Has a small floating prayer symbol over their head.
	var slots: Node3D = get_node_or_null("%NPCSlots") as Node3D
	if slots == null:
		return
	var acolyte: Node3D = Node3D.new()
	acolyte.name = "D3Acolyte"
	acolyte.position = D3_CENTER + Vector3(0, 0.65, 6.5)
	acolyte.rotation = Vector3(0, deg_to_rad(180), 0)
	slots.add_child(acolyte)
	# Robed body — short capsule (sitting)
	var bmat: StandardMaterial3D = StandardMaterial3D.new()
	bmat.albedo_color = Color(0.30, 0.20, 0.40)
	bmat.metallic = 0.20
	bmat.roughness = 0.65
	bmat.emission_enabled = true
	bmat.emission = Color(0.55, 0.30, 0.85)
	bmat.emission_energy_multiplier = 0.40
	var body: MeshInstance3D = MeshInstance3D.new()
	var bmesh: CapsuleMesh = CapsuleMesh.new()
	bmesh.radius = 0.40
	bmesh.height = 0.85
	body.mesh = bmesh
	body.position = Vector3(0, 0.45, 0)
	body.material_override = bmat
	acolyte.add_child(body)
	# Hood
	var hood: MeshInstance3D = MeshInstance3D.new()
	var hmesh: SphereMesh = SphereMesh.new()
	hmesh.radius = 0.40
	hmesh.height = 0.50
	hood.mesh = hmesh
	hood.position = Vector3(0, 1.0, 0)
	hood.material_override = bmat
	acolyte.add_child(hood)
	# Closed eyes — 2 thin black bars (eyes shut, meditating)
	var eye_mat: StandardMaterial3D = StandardMaterial3D.new()
	eye_mat.albedo_color = Color(0.05, 0.05, 0.10)
	eye_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for ex: float in [-0.10, 0.10]:
		var eye: MeshInstance3D = MeshInstance3D.new()
		var em: BoxMesh = BoxMesh.new()
		em.size = Vector3(0.08, 0.02, 0.04)
		eye.mesh = em
		eye.position = Vector3(ex, 0.95, 0.32)
		eye.material_override = eye_mat
		acolyte.add_child(eye)
	# Floating prayer rune above head — small pulsing prism
	var rune: MeshInstance3D = MeshInstance3D.new()
	var rmesh: PrismMesh = PrismMesh.new()
	rmesh.size = Vector3(0.20, 0.30, 0.20)
	rune.mesh = rmesh
	rune.position = Vector3(0, 1.85, 0)
	var rmat: StandardMaterial3D = StandardMaterial3D.new()
	rmat.albedo_color = Color(0.85, 0.40, 1.0)
	rmat.emission_enabled = true
	rmat.emission = Color(1.0, 0.55, 1.0)
	rmat.emission_energy_multiplier = 2.6
	rmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	rune.material_override = rmat
	acolyte.add_child(rune)
	# Rune slow rotation + bob
	var spin: Tween = create_tween().set_loops()
	spin.tween_property(rune, "rotation:y", TAU, 4.0)
	var bob: Tween = create_tween().set_loops()
	bob.tween_property(rune, "position:y", 2.10, 1.4).set_ease(Tween.EASE_IN_OUT)
	bob.tween_property(rune, "position:y", 1.85, 1.4).set_ease(Tween.EASE_IN_OUT)
	# Name billboard
	var label: Label3D = Label3D.new()
	label.text = "Acolyte"
	label.position = Vector3(0, 2.40, 0)
	label.modulate = Color(0.85, 0.55, 1.0)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 18
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	acolyte.add_child(label)


func _build_d3_mana_font(geom: Node) -> void:
	## Epic-3 T21: a mana font — small fountain with a glowing violet
	## sphere rising and falling on a tween. Ringed by 4 small candle
	## flames (mocked with emissive amber spheres).
	var font: Node3D = Node3D.new()
	font.name = "D3ManaFont"
	font.position = D3_CENTER + Vector3(-15, 0, 8)
	geom.add_child(font)
	# Stone basin
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.16, 0.10, 0.20)
	stone_mat.metallic = 0.55
	stone_mat.roughness = 0.45
	var basin: MeshInstance3D = MeshInstance3D.new()
	var bmesh: CylinderMesh = CylinderMesh.new()
	bmesh.top_radius = 0.85
	bmesh.bottom_radius = 1.0
	bmesh.height = 0.85
	basin.mesh = bmesh
	basin.position = Vector3(0, 0.42, 0)
	basin.material_override = stone_mat
	font.add_child(basin)
	# Mana sphere — bobs vertically
	var mana: MeshInstance3D = MeshInstance3D.new()
	var mm: SphereMesh = SphereMesh.new()
	mm.radius = 0.40
	mm.height = 0.80
	mana.mesh = mm
	mana.position = Vector3(0, 1.20, 0)
	var mmat: StandardMaterial3D = StandardMaterial3D.new()
	mmat.albedo_color = Color(0.85, 0.40, 1.0)
	mmat.emission_enabled = true
	mmat.emission = Color(1.0, 0.55, 1.0)
	mmat.emission_energy_multiplier = 3.0
	mmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mana.material_override = mmat
	font.add_child(mana)
	# Bob the mana sphere
	var bob: Tween = create_tween().set_loops()
	bob.tween_property(mana, "position:y", 1.85, 1.6).set_ease(Tween.EASE_IN_OUT)
	bob.tween_property(mana, "position:y", 1.0, 1.6).set_ease(Tween.EASE_IN_OUT)
	# 4 candle flames around the basin
	var flame_mat: StandardMaterial3D = StandardMaterial3D.new()
	flame_mat.albedo_color = Color(1.0, 0.65, 0.20)
	flame_mat.emission_enabled = true
	flame_mat.emission = Color(1.0, 0.75, 0.20)
	flame_mat.emission_energy_multiplier = 2.6
	flame_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for i in 4:
		var angle: float = (float(i) / 4.0) * TAU
		var flame: MeshInstance3D = MeshInstance3D.new()
		var fm: SphereMesh = SphereMesh.new()
		fm.radius = 0.12
		fm.height = 0.24
		flame.mesh = fm
		flame.position = Vector3(cos(angle) * 1.20, 0.95, sin(angle) * 1.20)
		flame.material_override = flame_mat
		font.add_child(flame)
		# Tiny flicker
		var fl: Tween = create_tween().set_loops()
		fl.tween_property(flame, "scale", Vector3(1.30, 1.30, 1.30), 0.4 + i * 0.08).set_ease(Tween.EASE_IN_OUT)
		fl.tween_property(flame, "scale", Vector3(0.85, 0.85, 0.85), 0.4 + i * 0.08).set_ease(Tween.EASE_IN_OUT)
	# Sign
	var label: Label3D = Label3D.new()
	label.text = "MANA FONT"
	label.position = Vector3(0, 2.40, 0)
	label.modulate = Color(1.0, 0.55, 1.0)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 16
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	font.add_child(label)
	# Collision around basin
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(2.0, 0.85, 2.0)
	cs.shape = cb
	cs.position = Vector3(0, 0.42, 0)
	sb.add_child(cs)
	font.add_child(sb)


func _build_d3_mausoleum(geom: Node) -> void:
	## Epic-3 T22: a stone mausoleum building — square structure with
	## peaked roof, sealed door with rune carving, and 4 corner crests.
	var maus: Node3D = Node3D.new()
	maus.name = "D3Mausoleum"
	maus.position = D3_CENTER + Vector3(15, 0, -16)
	geom.add_child(maus)
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.18, 0.14, 0.24)
	stone_mat.metallic = 0.40
	stone_mat.roughness = 0.55
	stone_mat.emission_enabled = true
	stone_mat.emission = Color(0.55, 0.30, 0.85)
	stone_mat.emission_energy_multiplier = 0.30
	# Main building cube
	var building: MeshInstance3D = MeshInstance3D.new()
	var bm: BoxMesh = BoxMesh.new()
	bm.size = Vector3(3.40, 3.40, 3.40)
	building.mesh = bm
	building.position = Vector3(0, 1.70, 0)
	building.material_override = stone_mat
	maus.add_child(building)
	# Peaked roof prism
	var roof: MeshInstance3D = MeshInstance3D.new()
	var rmesh: PrismMesh = PrismMesh.new()
	rmesh.size = Vector3(3.85, 1.40, 3.85)
	roof.mesh = rmesh
	roof.position = Vector3(0, 4.10, 0)
	roof.material_override = stone_mat
	maus.add_child(roof)
	# Sealed door — dark recess
	var door: MeshInstance3D = MeshInstance3D.new()
	var dm: BoxMesh = BoxMesh.new()
	dm.size = Vector3(0.85, 1.85, 0.10)
	door.mesh = dm
	door.position = Vector3(0, 1.30, 1.71)
	var dmat: StandardMaterial3D = StandardMaterial3D.new()
	dmat.albedo_color = Color(0.04, 0.02, 0.08)
	dmat.metallic = 0.30
	dmat.emission_enabled = true
	dmat.emission = Color(0.85, 0.40, 1.0)
	dmat.emission_energy_multiplier = 0.45
	dmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	door.material_override = dmat
	maus.add_child(door)
	# Glowing rune symbol on door
	var rune: Label3D = Label3D.new()
	rune.text = "Φ"
	rune.position = Vector3(0, 1.40, 1.77)
	rune.modulate = Color(1.0, 0.55, 1.0)
	rune.outline_modulate = Color(0, 0, 0, 0.85)
	rune.outline_size = 5
	rune.font_size = 36
	rune.no_depth_test = true
	maus.add_child(rune)
	# 4 corner crests on the roof — small spheres
	for ox: float in [-1.40, 1.40]:
		for oz: float in [-1.40, 1.40]:
			var crest: MeshInstance3D = MeshInstance3D.new()
			var cm: SphereMesh = SphereMesh.new()
			cm.radius = 0.20
			cm.height = 0.40
			crest.mesh = cm
			crest.position = Vector3(ox, 3.50, oz)
			var cmat: StandardMaterial3D = StandardMaterial3D.new()
			cmat.albedo_color = Color(0.85, 0.40, 1.0)
			cmat.emission_enabled = true
			cmat.emission = Color(1.0, 0.55, 1.0)
			cmat.emission_energy_multiplier = 2.4
			cmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
			crest.material_override = cmat
			maus.add_child(crest)
	# Sign
	var label: Label3D = Label3D.new()
	label.text = "MAUSOLEUM"
	label.position = Vector3(0, 5.30, 0)
	label.modulate = Color(0.85, 0.55, 1.0)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 18
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	maus.add_child(label)
	# Collision
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(3.40, 3.40, 3.40)
	cs.shape = cb
	cs.position = Vector3(0, 1.70, 0)
	sb.add_child(cs)
	maus.add_child(sb)


func _build_d3_crystal_lanterns(geom: Node) -> void:
	## Epic-3 T23: 6 floating crystal lantern cluster — small prisms
	## suspended in the air with thin tether cables to the ground.
	var positions: Array[Vector3] = [
		D3_CENTER + Vector3(-8, 3.5, 12),
		D3_CENTER + Vector3(-4, 4.0, 12),
		D3_CENTER + Vector3(0, 3.5, 12),
		D3_CENTER + Vector3(4, 4.0, 12),
		D3_CENTER + Vector3(8, 3.5, 12),
		D3_CENTER + Vector3(0, 4.5, 14),
	]
	var lantern_mat: StandardMaterial3D = StandardMaterial3D.new()
	lantern_mat.albedo_color = Color(0.85, 0.40, 1.0)
	lantern_mat.emission_enabled = true
	lantern_mat.emission = Color(1.0, 0.55, 1.0)
	lantern_mat.emission_energy_multiplier = 2.6
	lantern_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var cable_mat: StandardMaterial3D = StandardMaterial3D.new()
	cable_mat.albedo_color = Color(0.05, 0.05, 0.10)
	cable_mat.metallic = 0.55
	for i in positions.size():
		var lantern: MeshInstance3D = MeshInstance3D.new()
		lantern.name = "D3CrystalLantern_%d" % i
		var lmesh: PrismMesh = PrismMesh.new()
		lmesh.size = Vector3(0.30, 0.55, 0.30)
		lantern.mesh = lmesh
		lantern.position = positions[i]
		lantern.material_override = lantern_mat
		geom.add_child(lantern)
		# Thin tether cable down to the ground
		var cable: MeshInstance3D = MeshInstance3D.new()
		var cm: CylinderMesh = CylinderMesh.new()
		cm.top_radius = 0.02
		cm.bottom_radius = 0.02
		cm.height = positions[i].y
		cable.mesh = cm
		cable.position = Vector3(positions[i].x, positions[i].y * 0.5, positions[i].z)
		cable.material_override = cable_mat
		geom.add_child(cable)
		# Bob lantern
		var bob: Tween = create_tween().set_loops()
		var origin_y: float = positions[i].y
		bob.tween_property(lantern, "position:y", origin_y + 0.30, 1.4 + i * 0.15).set_ease(Tween.EASE_IN_OUT)
		bob.tween_property(lantern, "position:y", origin_y, 1.4 + i * 0.15).set_ease(Tween.EASE_IN_OUT)
		# Slow rotation
		var spin: Tween = create_tween().set_loops()
		spin.tween_property(lantern, "rotation:y", TAU, 5.0 + i * 0.3)


func _build_d3_sage_npc() -> void:
	## Epic-3 T24: Sage NPC — old wise figure with a long beard, holding
	## a tall crystal staff with a glowing orb on top. The "wisdom giver"
	## archetype.
	var slots: Node3D = get_node_or_null("%NPCSlots") as Node3D
	if slots == null:
		return
	var sage: Node3D = Node3D.new()
	sage.name = "D3Sage"
	sage.position = D3_CENTER + Vector3(8, 0, -8)
	slots.add_child(sage)
	# Robed body
	var bmat: StandardMaterial3D = StandardMaterial3D.new()
	bmat.albedo_color = Color(0.30, 0.20, 0.40)
	bmat.metallic = 0.20
	bmat.roughness = 0.65
	bmat.emission_enabled = true
	bmat.emission = Color(0.55, 0.30, 0.85)
	bmat.emission_energy_multiplier = 0.30
	var body: MeshInstance3D = MeshInstance3D.new()
	var bmesh: CapsuleMesh = CapsuleMesh.new()
	bmesh.radius = 0.45
	bmesh.height = 1.40
	body.mesh = bmesh
	body.position = Vector3(0, 0.70, 0)
	body.material_override = bmat
	sage.add_child(body)
	# Wide hood
	var hood: MeshInstance3D = MeshInstance3D.new()
	var hmesh: SphereMesh = SphereMesh.new()
	hmesh.radius = 0.45
	hmesh.height = 0.55
	hood.mesh = hmesh
	hood.position = Vector3(0, 1.55, 0)
	hood.material_override = bmat
	sage.add_child(hood)
	# Long beard — white box
	var beard: MeshInstance3D = MeshInstance3D.new()
	var bm2: BoxMesh = BoxMesh.new()
	bm2.size = Vector3(0.30, 0.55, 0.10)
	beard.mesh = bm2
	beard.position = Vector3(0, 1.20, 0.34)
	var bmat2: StandardMaterial3D = StandardMaterial3D.new()
	bmat2.albedo_color = Color(0.95, 0.95, 1.0)
	bmat2.metallic = 0.10
	bmat2.roughness = 0.85
	beard.material_override = bmat2
	sage.add_child(beard)
	# 2 small white eyes above beard
	var eye_mat: StandardMaterial3D = StandardMaterial3D.new()
	eye_mat.albedo_color = Color(0.55, 0.95, 1.0)
	eye_mat.emission_enabled = true
	eye_mat.emission = Color(0.55, 0.95, 1.0)
	eye_mat.emission_energy_multiplier = 2.4
	eye_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for ex: float in [-0.10, 0.10]:
		var eye: MeshInstance3D = MeshInstance3D.new()
		var em: SphereMesh = SphereMesh.new()
		em.radius = 0.06
		em.height = 0.12
		eye.mesh = em
		eye.position = Vector3(ex, 1.55, 0.32)
		eye.material_override = eye_mat
		sage.add_child(eye)
	# Tall crystal staff — long cylinder
	var staff_mat: StandardMaterial3D = StandardMaterial3D.new()
	staff_mat.albedo_color = Color(0.30, 0.20, 0.10)
	staff_mat.metallic = 0.30
	var staff: MeshInstance3D = MeshInstance3D.new()
	var sm: CylinderMesh = CylinderMesh.new()
	sm.top_radius = 0.05
	sm.bottom_radius = 0.06
	sm.height = 2.40
	staff.mesh = sm
	staff.position = Vector3(0.55, 1.20, 0)
	staff.material_override = staff_mat
	sage.add_child(staff)
	# Crystal orb on top of staff
	var orb: MeshInstance3D = MeshInstance3D.new()
	var om: PrismMesh = PrismMesh.new()
	om.size = Vector3(0.30, 0.55, 0.30)
	orb.mesh = om
	orb.position = Vector3(0.55, 2.50, 0)
	var omat: StandardMaterial3D = StandardMaterial3D.new()
	omat.albedo_color = Color(0.85, 0.40, 1.0)
	omat.emission_enabled = true
	omat.emission = Color(1.0, 0.55, 1.0)
	omat.emission_energy_multiplier = 3.0
	omat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	orb.material_override = omat
	sage.add_child(orb)
	# Pulse the orb
	var pulse: Tween = create_tween().set_loops()
	pulse.tween_property(orb, "scale", Vector3(1.30, 1.30, 1.30), 1.4).set_ease(Tween.EASE_IN_OUT)
	pulse.tween_property(orb, "scale", Vector3(0.95, 0.95, 0.95), 1.4).set_ease(Tween.EASE_IN_OUT)
	# Name billboard
	var label: Label3D = Label3D.new()
	label.text = "Sage"
	label.position = Vector3(0, 2.95, 0)
	label.modulate = Color(0.85, 0.55, 1.0)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 18
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	sage.add_child(label)


func _build_d3_echo_wraith(geom: Node) -> void:
	## Epic-3 T25: an echo wraith — wider thinner enemy than the wisps,
	## with a cloak-like trailing form, glowing white face, slow patrol.
	var wraith: Node3D = Node3D.new()
	wraith.name = "D3EchoWraith"
	wraith.position = D3_CENTER + Vector3(-15, 0, -8)
	geom.add_child(wraith)
	# Translucent body capsule
	var bmat: StandardMaterial3D = StandardMaterial3D.new()
	bmat.albedo_color = Color(0.30, 0.10, 0.40, 0.55)
	bmat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	bmat.emission_enabled = true
	bmat.emission = Color(0.85, 0.40, 1.0)
	bmat.emission_energy_multiplier = 1.4
	bmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var body: MeshInstance3D = MeshInstance3D.new()
	var bmesh: CapsuleMesh = CapsuleMesh.new()
	bmesh.radius = 0.55
	bmesh.height = 1.85
	body.mesh = bmesh
	body.position = Vector3(0, 1.20, 0)
	body.material_override = bmat
	wraith.add_child(body)
	# Trailing skirt — wider box at the bottom
	var skirt: MeshInstance3D = MeshInstance3D.new()
	var sm: PrismMesh = PrismMesh.new()
	sm.size = Vector3(1.40, 1.20, 1.40)
	skirt.mesh = sm
	skirt.position = Vector3(0, 0.60, 0)
	skirt.rotation = Vector3(deg_to_rad(180), 0, 0)
	skirt.material_override = bmat
	wraith.add_child(skirt)
	# Glowing white face — single big oval
	var face: MeshInstance3D = MeshInstance3D.new()
	var fm: SphereMesh = SphereMesh.new()
	fm.radius = 0.30
	fm.height = 0.55
	face.mesh = fm
	face.position = Vector3(0, 1.85, 0.30)
	var fmat: StandardMaterial3D = StandardMaterial3D.new()
	fmat.albedo_color = Color(1, 1, 1)
	fmat.emission_enabled = true
	fmat.emission = Color(1, 1, 1)
	fmat.emission_energy_multiplier = 3.4
	fmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	face.material_override = fmat
	wraith.add_child(face)
	# Pulse the face
	var pulse: Tween = create_tween().set_loops()
	pulse.tween_property(fmat, "emission_energy_multiplier", 4.5, 0.85).set_ease(Tween.EASE_IN_OUT)
	pulse.tween_property(fmat, "emission_energy_multiplier", 2.2, 0.85).set_ease(Tween.EASE_IN_OUT)
	# Slow drift patrol
	var origin: Vector3 = D3_CENTER + Vector3(-15, 0, -8)
	var drift: Tween = create_tween().set_loops()
	drift.tween_property(wraith, "position", origin + Vector3(6, 0, 4), 8.0).set_ease(Tween.EASE_IN_OUT)
	drift.tween_property(wraith, "position", origin + Vector3(0, 0, 8), 8.0).set_ease(Tween.EASE_IN_OUT)
	drift.tween_property(wraith, "position", origin, 8.0).set_ease(Tween.EASE_IN_OUT)
	# Boss-tier name billboard
	var label: Label3D = Label3D.new()
	label.text = "ECHO WRAITH"
	label.position = Vector3(0, 2.85, 0)
	label.modulate = Color(0.85, 0.55, 1.0)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 18
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	wraith.add_child(label)


func _build_d3_rune_decals(geom: Node) -> void:
	## Epic-3 T26: 4 small rune circle decals on the D3 floor scattered
	## across the district. Each is a flat torus with 8 small dots inside.
	var positions: Array[Vector3] = [
		D3_CENTER + Vector3(-12, 0.06, 4),
		D3_CENTER + Vector3(8, 0.06, -4),
		D3_CENTER + Vector3(-6, 0.06, -10),
		D3_CENTER + Vector3(12, 0.06, 10),
	]
	var rune_mat: StandardMaterial3D = StandardMaterial3D.new()
	rune_mat.albedo_color = Color(0.85, 0.40, 1.0)
	rune_mat.emission_enabled = true
	rune_mat.emission = Color(1.0, 0.55, 1.0)
	rune_mat.emission_energy_multiplier = 1.6
	rune_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for i in positions.size():
		var decal: Node3D = Node3D.new()
		decal.name = "D3RuneDecal_%d" % i
		decal.position = positions[i]
		geom.add_child(decal)
		# Outer ring
		var ring: MeshInstance3D = MeshInstance3D.new()
		var rmesh: TorusMesh = TorusMesh.new()
		rmesh.inner_radius = 0.85
		rmesh.outer_radius = 1.0
		ring.mesh = rmesh
		ring.material_override = rune_mat
		decal.add_child(ring)
		# 8 small dots inside
		for d in 8:
			var angle: float = (float(d) / 8.0) * TAU
			var dot: MeshInstance3D = MeshInstance3D.new()
			var dm: SphereMesh = SphereMesh.new()
			dm.radius = 0.10
			dm.height = 0.20
			dot.mesh = dm
			dot.position = Vector3(cos(angle) * 0.55, 0.05, sin(angle) * 0.55)
			dot.material_override = rune_mat
			decal.add_child(dot)
		# Slow rotation
		var spin: Tween = create_tween().set_loops()
		spin.tween_property(decal, "rotation:y", TAU * (1 if i % 2 == 0 else -1), 14.0 + i * 2)


func _build_d3_sealed_gates(geom: Node) -> void:
	## Epic-3 T27: sealed vault gates landmark — 2 huge stone double doors
	## with a glowing rune seal across the middle. Looks like a quest hook
	## but is purely decorative.
	var gates: Node3D = Node3D.new()
	gates.name = "D3SealedGates"
	gates.position = D3_CENTER + Vector3(20, 0, 0)
	geom.add_child(gates)
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.16, 0.10, 0.20)
	stone_mat.metallic = 0.55
	stone_mat.roughness = 0.45
	# Frame around the doors
	for sx: float in [-2.40, 2.40]:
		var frame: MeshInstance3D = MeshInstance3D.new()
		var fm: BoxMesh = BoxMesh.new()
		fm.size = Vector3(0.55, 6.0, 1.20)
		frame.mesh = fm
		frame.position = Vector3(sx, 3.0, 0)
		frame.material_override = stone_mat
		gates.add_child(frame)
		# Collision per side
		var sb: StaticBody3D = StaticBody3D.new()
		var cs: CollisionShape3D = CollisionShape3D.new()
		var cb: BoxShape3D = BoxShape3D.new()
		cb.size = Vector3(0.55, 6.0, 1.20)
		cs.shape = cb
		cs.position = Vector3(sx, 3.0, 0)
		sb.add_child(cs)
		gates.add_child(sb)
	# Top frame
	var top: MeshInstance3D = MeshInstance3D.new()
	var tm: BoxMesh = BoxMesh.new()
	tm.size = Vector3(5.40, 0.55, 1.20)
	top.mesh = tm
	top.position = Vector3(0, 6.30, 0)
	top.material_override = stone_mat
	gates.add_child(top)
	# 2 door slabs
	var door_mat: StandardMaterial3D = StandardMaterial3D.new()
	door_mat.albedo_color = Color(0.04, 0.02, 0.08)
	door_mat.metallic = 0.85
	door_mat.roughness = 0.30
	door_mat.emission_enabled = true
	door_mat.emission = Color(0.85, 0.40, 1.0)
	door_mat.emission_energy_multiplier = 0.30
	for sx: float in [-1.10, 1.10]:
		var door: MeshInstance3D = MeshInstance3D.new()
		var dm: BoxMesh = BoxMesh.new()
		dm.size = Vector3(2.0, 5.5, 0.30)
		door.mesh = dm
		door.position = Vector3(sx, 2.85, 0)
		door.material_override = door_mat
		gates.add_child(door)
		# Door collision
		var sb: StaticBody3D = StaticBody3D.new()
		var cs: CollisionShape3D = CollisionShape3D.new()
		var cb: BoxShape3D = BoxShape3D.new()
		cb.size = Vector3(2.0, 5.5, 0.30)
		cs.shape = cb
		cs.position = Vector3(sx, 2.85, 0)
		sb.add_child(cs)
		gates.add_child(sb)
	# Glowing rune seal across the middle (a circle of 12 small emissive spheres)
	for i in 12:
		var angle: float = (float(i) / 12.0) * TAU
		var rune: MeshInstance3D = MeshInstance3D.new()
		var rmesh: SphereMesh = SphereMesh.new()
		rmesh.radius = 0.12
		rmesh.height = 0.24
		rune.mesh = rmesh
		rune.position = Vector3(cos(angle) * 0.85, 2.85, 0.16)
		var rmat: StandardMaterial3D = StandardMaterial3D.new()
		rmat.albedo_color = Color(1.0, 0.55, 1.0)
		rmat.emission_enabled = true
		rmat.emission = Color(1.0, 0.55, 1.0)
		rmat.emission_energy_multiplier = 2.6
		rmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		rune.material_override = rmat
		gates.add_child(rune)
	# Center seal sphere — bigger
	var seal: MeshInstance3D = MeshInstance3D.new()
	var sm: SphereMesh = SphereMesh.new()
	sm.radius = 0.30
	sm.height = 0.60
	seal.mesh = sm
	seal.position = Vector3(0, 2.85, 0.16)
	var smat: StandardMaterial3D = StandardMaterial3D.new()
	smat.albedo_color = Color(1.0, 0.55, 1.0)
	smat.emission_enabled = true
	smat.emission = Color(1.0, 0.55, 1.0)
	smat.emission_energy_multiplier = 3.4
	smat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	seal.material_override = smat
	gates.add_child(seal)
	# Pulse the seal
	var pulse: Tween = create_tween().set_loops()
	pulse.tween_property(seal, "scale", Vector3(1.30, 1.30, 1.30), 1.6).set_ease(Tween.EASE_IN_OUT)
	pulse.tween_property(seal, "scale", Vector3(0.85, 0.85, 0.85), 1.6).set_ease(Tween.EASE_IN_OUT)
	# Sign
	var label: Label3D = Label3D.new()
	label.text = "SEALED VAULT"
	label.position = Vector3(0, 7.0, 0)
	label.modulate = Color(1.0, 0.55, 1.0)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 18
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	gates.add_child(label)


func _build_d3_data_spirits(geom: Node) -> void:
	## Epic-3 T28: 8 floating data spirits orbiting in a circle overhead
	## around the great crystal — small translucent ghost figures.
	var spirit_mat: StandardMaterial3D = StandardMaterial3D.new()
	spirit_mat.albedo_color = Color(0.85, 0.55, 1.0, 0.55)
	spirit_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	spirit_mat.emission_enabled = true
	spirit_mat.emission = Color(1.0, 0.55, 1.0)
	spirit_mat.emission_energy_multiplier = 1.8
	spirit_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	# Pivot for orbital rotation
	var orbit_pivot: Node3D = Node3D.new()
	orbit_pivot.name = "D3DataSpiritsPivot"
	orbit_pivot.position = D3_CENTER + Vector3(0, 9, 0)
	geom.add_child(orbit_pivot)
	for i in 8:
		var angle: float = (float(i) / 8.0) * TAU
		var spirit: Node3D = Node3D.new()
		spirit.name = "D3DataSpirit_%d" % i
		spirit.position = Vector3(cos(angle) * 6.0, randf_range(-0.5, 0.5), sin(angle) * 6.0)
		orbit_pivot.add_child(spirit)
		# Body capsule
		var body: MeshInstance3D = MeshInstance3D.new()
		var bm: CapsuleMesh = CapsuleMesh.new()
		bm.radius = 0.20
		bm.height = 0.65
		body.mesh = bm
		body.material_override = spirit_mat
		spirit.add_child(body)
		# Single eye
		var eye: MeshInstance3D = MeshInstance3D.new()
		var em: SphereMesh = SphereMesh.new()
		em.radius = 0.08
		em.height = 0.16
		eye.mesh = em
		eye.position = Vector3(0, 0.30, 0)
		var emat: StandardMaterial3D = StandardMaterial3D.new()
		emat.albedo_color = Color(1, 1, 1)
		emat.emission_enabled = true
		emat.emission = Color(1, 1, 1)
		emat.emission_energy_multiplier = 2.6
		emat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		eye.material_override = emat
		spirit.add_child(eye)
	# Rotate the entire pivot
	var spin: Tween = create_tween().set_loops()
	spin.tween_property(orbit_pivot, "rotation:y", TAU, 16.0)


func _build_d3_oracle_npc() -> void:
	## Epic-3 T29: Oracle NPC sitting on a small plinth in front of the
	## sealed gates with a glowing crystal ball floating in front of them.
	## Hooded with no visible face, just glowing eyes inside the hood.
	var slots: Node3D = get_node_or_null("%NPCSlots") as Node3D
	if slots == null:
		return
	var oracle: Node3D = Node3D.new()
	oracle.name = "D3Oracle"
	oracle.position = D3_CENTER + Vector3(16, 0, 0)
	slots.add_child(oracle)
	# Plinth
	var plinth_mat: StandardMaterial3D = StandardMaterial3D.new()
	plinth_mat.albedo_color = Color(0.16, 0.10, 0.20)
	plinth_mat.metallic = 0.55
	plinth_mat.roughness = 0.45
	var plinth: MeshInstance3D = MeshInstance3D.new()
	var pm: CylinderMesh = CylinderMesh.new()
	pm.top_radius = 0.55
	pm.bottom_radius = 0.65
	pm.height = 0.55
	plinth.mesh = pm
	plinth.position = Vector3(0, 0.27, 0)
	plinth.material_override = plinth_mat
	oracle.add_child(plinth)
	# Body — capsule sitting on plinth
	var bmat: StandardMaterial3D = StandardMaterial3D.new()
	bmat.albedo_color = Color(0.16, 0.10, 0.24)
	bmat.metallic = 0.20
	bmat.roughness = 0.65
	bmat.emission_enabled = true
	bmat.emission = Color(0.55, 0.30, 0.85)
	bmat.emission_energy_multiplier = 0.40
	var body: MeshInstance3D = MeshInstance3D.new()
	var bmesh: CapsuleMesh = CapsuleMesh.new()
	bmesh.radius = 0.40
	bmesh.height = 0.85
	body.mesh = bmesh
	body.position = Vector3(0, 1.0, 0)
	body.material_override = bmat
	oracle.add_child(body)
	# Wide deep hood
	var hood: MeshInstance3D = MeshInstance3D.new()
	var hm: SphereMesh = SphereMesh.new()
	hm.radius = 0.50
	hm.height = 0.65
	hood.mesh = hm
	hood.position = Vector3(0, 1.85, 0)
	hood.material_override = bmat
	oracle.add_child(hood)
	# 2 small bright violet eyes inside hood shadow
	var eye_mat: StandardMaterial3D = StandardMaterial3D.new()
	eye_mat.albedo_color = Color(1.0, 0.55, 1.0)
	eye_mat.emission_enabled = true
	eye_mat.emission = Color(1.0, 0.55, 1.0)
	eye_mat.emission_energy_multiplier = 3.4
	eye_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for ex: float in [-0.10, 0.10]:
		var eye: MeshInstance3D = MeshInstance3D.new()
		var em: SphereMesh = SphereMesh.new()
		em.radius = 0.06
		em.height = 0.12
		eye.mesh = em
		eye.position = Vector3(ex, 1.80, 0.30)
		eye.material_override = eye_mat
		oracle.add_child(eye)
	# Floating crystal ball in front
	var ball: MeshInstance3D = MeshInstance3D.new()
	var bm2: SphereMesh = SphereMesh.new()
	bm2.radius = 0.30
	bm2.height = 0.60
	ball.mesh = bm2
	ball.position = Vector3(0, 1.40, 0.65)
	var ball_mat: StandardMaterial3D = StandardMaterial3D.new()
	ball_mat.albedo_color = Color(0.85, 0.55, 1.0, 0.55)
	ball_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	ball_mat.emission_enabled = true
	ball_mat.emission = Color(1.0, 0.55, 1.0)
	ball_mat.emission_energy_multiplier = 2.4
	ball_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	ball.material_override = ball_mat
	oracle.add_child(ball)
	# Bob the ball
	var bob: Tween = create_tween().set_loops()
	bob.tween_property(ball, "position:y", 1.65, 1.4).set_ease(Tween.EASE_IN_OUT)
	bob.tween_property(ball, "position:y", 1.40, 1.4).set_ease(Tween.EASE_IN_OUT)
	# Name billboard
	var label: Label3D = Label3D.new()
	label.text = "Oracle"
	label.position = Vector3(0, 2.65, 0)
	label.modulate = Color(1.0, 0.55, 1.0)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 18
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	oracle.add_child(label)


func _build_d3_violet_mist(geom: Node) -> void:
	## Epic-3 T30: ambient violet mist drifting low across the district —
	## 80 large translucent violet puff particles slowly moving north.
	var mist: GPUParticles3D = GPUParticles3D.new()
	mist.name = "D3VioletMist"
	mist.position = D3_CENTER + Vector3(0, 1.0, -20)
	mist.amount = 80
	mist.lifetime = 12.0
	mist.preprocess = 6.0
	var pmat: ParticleProcessMaterial = ParticleProcessMaterial.new()
	pmat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	pmat.emission_box_extents = Vector3(28, 0.5, 0.5)
	pmat.direction = Vector3(0, 0, 1)
	pmat.spread = 6.0
	pmat.initial_velocity_min = 0.45
	pmat.initial_velocity_max = 0.85
	pmat.gravity = Vector3.ZERO
	pmat.scale_min = 0.85
	pmat.scale_max = 1.40
	pmat.color = Color(0.85, 0.40, 1.0, 0.20)
	mist.process_material = pmat
	var puff: SphereMesh = SphereMesh.new()
	puff.radius = 0.85
	puff.height = 1.70
	var puff_mat: StandardMaterial3D = StandardMaterial3D.new()
	puff_mat.albedo_color = Color(0.85, 0.40, 1.0, 0.20)
	puff_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	puff_mat.emission_enabled = true
	puff_mat.emission = Color(1.0, 0.55, 1.0)
	puff_mat.emission_energy_multiplier = 0.55
	puff_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	puff.material = puff_mat
	mist.draw_pass_1 = puff
	geom.add_child(mist)


func _build_d3_floating_arches(geom: Node) -> void:
	## Epic-3 T31: 3 floating ancient archways drifting overhead at
	## different altitudes — small free-floating arches like portal
	## fragments suspended in the air.
	var positions: Array[Vector3] = [
		D3_CENTER + Vector3(-15, 6.0, 8),
		D3_CENTER + Vector3(0, 8.5, -10),
		D3_CENTER + Vector3(15, 7.0, 6),
	]
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.16, 0.10, 0.20)
	stone_mat.metallic = 0.55
	stone_mat.roughness = 0.45
	stone_mat.emission_enabled = true
	stone_mat.emission = Color(0.85, 0.40, 1.0)
	stone_mat.emission_energy_multiplier = 0.40
	for i in positions.size():
		var arch: Node3D = Node3D.new()
		arch.name = "D3FloatingArch_%d" % i
		arch.position = positions[i]
		arch.rotation = Vector3(deg_to_rad(randf_range(-15, 15)), deg_to_rad(randf_range(0, 360)), deg_to_rad(randf_range(-15, 15)))
		geom.add_child(arch)
		# 2 side pillars
		for sx: float in [-1.20, 1.20]:
			var pillar: MeshInstance3D = MeshInstance3D.new()
			var pmesh: BoxMesh = BoxMesh.new()
			pmesh.size = Vector3(0.40, 2.40, 0.40)
			pillar.mesh = pmesh
			pillar.position = Vector3(sx, 0, 0)
			pillar.material_override = stone_mat
			arch.add_child(pillar)
		# Top crossbar
		var top: MeshInstance3D = MeshInstance3D.new()
		var tm: BoxMesh = BoxMesh.new()
		tm.size = Vector3(2.85, 0.40, 0.40)
		top.mesh = tm
		top.position = Vector3(0, 1.40, 0)
		top.material_override = stone_mat
		arch.add_child(top)
		# Bob tween
		var origin: Vector3 = positions[i]
		var bob: Tween = create_tween().set_loops()
		bob.tween_property(arch, "position:y", origin.y + 0.55, 2.4 + i * 0.3).set_ease(Tween.EASE_IN_OUT)
		bob.tween_property(arch, "position:y", origin.y, 2.4 + i * 0.3).set_ease(Tween.EASE_IN_OUT)
		# Slow rotation
		var spin: Tween = create_tween().set_loops()
		spin.tween_property(arch, "rotation:y", arch.rotation.y + TAU, 18.0)


func _build_d3_battle_scars(geom: Node) -> void:
	## Epic-3 T32: scattered broken stone fragments across the D3 floor —
	## 10 small angled stone shards suggesting an ancient battle.
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 144
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.18, 0.13, 0.22)
	stone_mat.metallic = 0.40
	stone_mat.roughness = 0.65
	for i in 10:
		var fragment: MeshInstance3D = MeshInstance3D.new()
		fragment.name = "D3BattleFragment_%d" % i
		var fmesh: BoxMesh = BoxMesh.new()
		fmesh.size = Vector3(rng.randf_range(0.30, 0.85), rng.randf_range(0.20, 0.55), rng.randf_range(0.30, 0.85))
		fragment.mesh = fmesh
		fragment.position = D3_CENTER + Vector3(
			rng.randf_range(-22, 22),
			0.10,
			rng.randf_range(-16, 16)
		)
		fragment.rotation = Vector3(
			deg_to_rad(rng.randf_range(-30, 30)),
			deg_to_rad(rng.randf_range(0, 360)),
			deg_to_rad(rng.randf_range(-30, 30))
		)
		fragment.material_override = stone_mat
		geom.add_child(fragment)


func _build_d3_memory_obelisks(geom: Node) -> void:
	## Epic-3 T33: 3 tall memory obelisks — narrow stone prisms with
	## glowing rune lines down each face. Sentinel-like landmarks placed
	## at the edges of the district.
	var positions: Array[Vector3] = [
		D3_CENTER + Vector3(-15, 0, -16),
		D3_CENTER + Vector3(0, 0, -18),
		D3_CENTER + Vector3(15, 0, -16),
	]
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.10, 0.06, 0.18)
	stone_mat.metallic = 0.55
	stone_mat.roughness = 0.45
	for i in positions.size():
		var obelisk: Node3D = Node3D.new()
		obelisk.name = "D3MemoryObelisk_%d" % i
		obelisk.position = positions[i]
		geom.add_child(obelisk)
		# Tapered prism — taller than wide
		var body: MeshInstance3D = MeshInstance3D.new()
		var bmesh: PrismMesh = PrismMesh.new()
		bmesh.size = Vector3(0.85, 5.0, 0.85)
		body.mesh = bmesh
		body.position = Vector3(0, 2.50, 0)
		body.material_override = stone_mat
		obelisk.add_child(body)
		# Glowing rune line down the front face
		var line: MeshInstance3D = MeshInstance3D.new()
		var lm: BoxMesh = BoxMesh.new()
		lm.size = Vector3(0.04, 4.0, 0.06)
		line.mesh = lm
		line.position = Vector3(0, 2.50, 0.40)
		var lmat: StandardMaterial3D = StandardMaterial3D.new()
		lmat.albedo_color = Color(0.85, 0.40, 1.0)
		lmat.emission_enabled = true
		lmat.emission = Color(1.0, 0.55, 1.0)
		lmat.emission_energy_multiplier = 1.8
		lmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		line.material_override = lmat
		obelisk.add_child(line)
		# Top crowning gem
		var gem: MeshInstance3D = MeshInstance3D.new()
		var gm: SphereMesh = SphereMesh.new()
		gm.radius = 0.22
		gm.height = 0.44
		gem.mesh = gm
		gem.position = Vector3(0, 5.20, 0)
		var gmat: StandardMaterial3D = StandardMaterial3D.new()
		gmat.albedo_color = Color(0.85, 0.40, 1.0)
		gmat.emission_enabled = true
		gmat.emission = Color(1.0, 0.55, 1.0)
		gmat.emission_energy_multiplier = 2.6
		gmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		gem.material_override = gmat
		obelisk.add_child(gem)
		# Pulse the gem
		var pulse: Tween = create_tween().set_loops()
		pulse.tween_property(gem, "scale", Vector3(1.30, 1.30, 1.30), 1.4 + i * 0.2).set_ease(Tween.EASE_IN_OUT)
		pulse.tween_property(gem, "scale", Vector3(0.85, 0.85, 0.85), 1.4 + i * 0.2).set_ease(Tween.EASE_IN_OUT)
		# Collision per obelisk
		var sb: StaticBody3D = StaticBody3D.new()
		var cs: CollisionShape3D = CollisionShape3D.new()
		var cb: BoxShape3D = BoxShape3D.new()
		cb.size = Vector3(0.85, 5.0, 0.85)
		cs.shape = cb
		cs.position = Vector3(0, 2.50, 0)
		sb.add_child(cs)
		obelisk.add_child(sb)


func _build_d3_phantom_warrior_npc() -> void:
	## Epic-3 T34: Phantom Warrior NPC — a translucent ghost of a fallen
	## warrior with armor outline + a translucent sword. Stands at attention.
	var slots: Node3D = get_node_or_null("%NPCSlots") as Node3D
	if slots == null:
		return
	var phantom: Node3D = Node3D.new()
	phantom.name = "D3PhantomWarrior"
	phantom.position = D3_CENTER + Vector3(-8, 0, -16)
	slots.add_child(phantom)
	# Translucent body
	var bmat: StandardMaterial3D = StandardMaterial3D.new()
	bmat.albedo_color = Color(0.55, 0.95, 1.0, 0.45)
	bmat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	bmat.emission_enabled = true
	bmat.emission = Color(0.55, 0.95, 1.0)
	bmat.emission_energy_multiplier = 1.4
	bmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var body: MeshInstance3D = MeshInstance3D.new()
	var bmesh: CapsuleMesh = CapsuleMesh.new()
	bmesh.radius = 0.45
	bmesh.height = 1.40
	body.mesh = bmesh
	body.position = Vector3(0, 0.70, 0)
	body.material_override = bmat
	phantom.add_child(body)
	# Helmet — narrow box
	var helmet: MeshInstance3D = MeshInstance3D.new()
	var hm: BoxMesh = BoxMesh.new()
	hm.size = Vector3(0.55, 0.65, 0.55)
	helmet.mesh = hm
	helmet.position = Vector3(0, 1.65, 0)
	helmet.material_override = bmat
	phantom.add_child(helmet)
	# 2 white slit eyes
	var eye_mat: StandardMaterial3D = StandardMaterial3D.new()
	eye_mat.albedo_color = Color(1, 1, 1)
	eye_mat.emission_enabled = true
	eye_mat.emission = Color(1, 1, 1)
	eye_mat.emission_energy_multiplier = 3.0
	eye_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for ex: float in [-0.10, 0.10]:
		var eye: MeshInstance3D = MeshInstance3D.new()
		var em: BoxMesh = BoxMesh.new()
		em.size = Vector3(0.10, 0.04, 0.04)
		eye.mesh = em
		eye.position = Vector3(ex, 1.65, 0.30)
		eye.material_override = eye_mat
		phantom.add_child(eye)
	# Translucent sword held vertically in front
	var sword: MeshInstance3D = MeshInstance3D.new()
	var sm: BoxMesh = BoxMesh.new()
	sm.size = Vector3(0.10, 1.85, 0.04)
	sword.mesh = sm
	sword.position = Vector3(0.30, 1.0, 0.40)
	sword.material_override = bmat
	phantom.add_child(sword)
	# Slow flicker visibility for ghost feel
	var flicker: Tween = create_tween().set_loops()
	flicker.tween_property(bmat, "emission_energy_multiplier", 2.4, 1.4).set_ease(Tween.EASE_IN_OUT)
	flicker.tween_property(bmat, "emission_energy_multiplier", 0.85, 1.4).set_ease(Tween.EASE_IN_OUT)
	# Name billboard
	var label: Label3D = Label3D.new()
	label.text = "Phantom Warrior"
	label.position = Vector3(0, 2.30, 0)
	label.modulate = Color(0.55, 0.95, 1.0)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 18
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	phantom.add_child(label)


func _build_d3_illusion_bridge(geom: Node) -> void:
	## Epic-3 T35: a short illusion bridge — 6 floating tile platforms in
	## a row that fade in/out on independent flickers, suggesting "the
	## bridge only appears for the worthy".
	var bridge: Node3D = Node3D.new()
	bridge.name = "D3IllusionBridge"
	bridge.position = D3_CENTER + Vector3(0, 0.55, 16)
	geom.add_child(bridge)
	for i in 6:
		var tile: MeshInstance3D = MeshInstance3D.new()
		tile.name = "D3BridgeTile_%d" % i
		var tmesh: BoxMesh = BoxMesh.new()
		tmesh.size = Vector3(1.40, 0.10, 1.40)
		tile.mesh = tmesh
		tile.position = Vector3(-3.5 + i * 1.40, 0, 0)
		var tmat: StandardMaterial3D = StandardMaterial3D.new()
		tmat.albedo_color = Color(0.85, 0.40, 1.0, 0.55)
		tmat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		tmat.emission_enabled = true
		tmat.emission = Color(1.0, 0.55, 1.0)
		tmat.emission_energy_multiplier = 1.6
		tmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		tile.material_override = tmat
		bridge.add_child(tile)
		# Fade visibility on independent timings
		var flicker: Tween = create_tween().set_loops()
		flicker.tween_interval(i * 0.30)
		flicker.tween_property(tile, "visible", false, 0.0)
		flicker.tween_interval(0.20)
		flicker.tween_property(tile, "visible", true, 0.0)
		flicker.tween_interval(2.0 - i * 0.20)
	# Sign
	var label: Label3D = Label3D.new()
	label.text = "ILLUSION BRIDGE"
	label.position = Vector3(0, 1.20, 0)
	label.modulate = Color(1.0, 0.55, 1.0)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 16
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	bridge.add_child(label)


func _build_d3_levitating_runes(geom: Node) -> void:
	## Epic-3 T36: 12 levitating glowing rune cubes orbiting horizontally
	## around the great crystal at chest height. Pivot rotation tween.
	var pivot: Node3D = Node3D.new()
	pivot.name = "D3LevitatingRunes"
	pivot.position = D3_CENTER + Vector3(0, 1.40, 0)
	geom.add_child(pivot)
	for i in 12:
		var angle: float = (float(i) / 12.0) * TAU
		var rune: MeshInstance3D = MeshInstance3D.new()
		rune.name = "Rune_%d" % i
		var rmesh: BoxMesh = BoxMesh.new()
		rmesh.size = Vector3(0.18, 0.18, 0.18)
		rune.mesh = rmesh
		rune.position = Vector3(cos(angle) * 5.0, 0, sin(angle) * 5.0)
		var rmat: StandardMaterial3D = StandardMaterial3D.new()
		rmat.albedo_color = Color(0.85, 0.40, 1.0)
		rmat.emission_enabled = true
		rmat.emission = Color(1.0, 0.55, 1.0)
		rmat.emission_energy_multiplier = 2.4
		rmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		rune.material_override = rmat
		pivot.add_child(rune)
	# Rotate the entire pivot
	var spin: Tween = create_tween().set_loops()
	spin.tween_property(pivot, "rotation:y", TAU, 12.0)


func _build_d3_observatory_dome(geom: Node) -> void:
	## Epic-3 T37: an ancient observatory dome — large hemisphere on a
	## stone base with a slit opening + a small telescope poking out.
	var dome: Node3D = Node3D.new()
	dome.name = "D3ObservatoryDome"
	dome.position = D3_CENTER + Vector3(-20, 0, -16)
	geom.add_child(dome)
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.16, 0.10, 0.20)
	stone_mat.metallic = 0.55
	stone_mat.roughness = 0.45
	# Cylinder base
	var base: MeshInstance3D = MeshInstance3D.new()
	var bm: CylinderMesh = CylinderMesh.new()
	bm.top_radius = 1.85
	bm.bottom_radius = 2.0
	bm.height = 2.40
	base.mesh = bm
	base.position = Vector3(0, 1.20, 0)
	base.material_override = stone_mat
	dome.add_child(base)
	# Hemispherical dome roof
	var roof: MeshInstance3D = MeshInstance3D.new()
	var rmesh: SphereMesh = SphereMesh.new()
	rmesh.radius = 1.85
	rmesh.height = 1.85
	roof.mesh = rmesh
	roof.position = Vector3(0, 2.40, 0)
	roof.scale = Vector3(1.0, 0.5, 1.0)
	roof.material_override = stone_mat
	dome.add_child(roof)
	# Telescope poking out at an angle (cylinder)
	var scope_mat: StandardMaterial3D = StandardMaterial3D.new()
	scope_mat.albedo_color = Color(0.10, 0.13, 0.18)
	scope_mat.metallic = 0.85
	scope_mat.roughness = 0.30
	var scope: MeshInstance3D = MeshInstance3D.new()
	var smesh: CylinderMesh = CylinderMesh.new()
	smesh.top_radius = 0.18
	smesh.bottom_radius = 0.20
	smesh.height = 1.85
	scope.mesh = smesh
	scope.position = Vector3(0.55, 3.0, 0.55)
	scope.rotation = Vector3(deg_to_rad(60), deg_to_rad(45), 0)
	scope.material_override = scope_mat
	dome.add_child(scope)
	# Glowing telescope tip lens
	var lens: MeshInstance3D = MeshInstance3D.new()
	var lmesh: SphereMesh = SphereMesh.new()
	lmesh.radius = 0.20
	lmesh.height = 0.40
	lens.mesh = lmesh
	lens.position = Vector3(1.10, 3.55, 1.10)
	var lmat: StandardMaterial3D = StandardMaterial3D.new()
	lmat.albedo_color = Color(0.55, 0.95, 1.0)
	lmat.emission_enabled = true
	lmat.emission = Color(0.55, 0.95, 1.0)
	lmat.emission_energy_multiplier = 2.6
	lmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	lens.material_override = lmat
	dome.add_child(lens)
	# Sign
	var label: Label3D = Label3D.new()
	label.text = "OBSERVATORY"
	label.position = Vector3(0, 4.65, 0)
	label.modulate = Color(0.55, 0.95, 1.0)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 18
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	dome.add_child(label)
	# Collision around the building
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(4.0, 4.0, 4.0)
	cs.shape = cb
	cs.position = Vector3(0, 2.0, 0)
	sb.add_child(cs)
	dome.add_child(sb)


func _build_d3_portal_pad(geom: Node) -> void:
	## Epic-3 T38: portal pad — circular dais on the ground with 4
	## upright energy beams forming a square gate, slowly rotating.
	var portal: Node3D = Node3D.new()
	portal.name = "D3PortalPad"
	portal.position = D3_CENTER + Vector3(20, 0, 12)
	geom.add_child(portal)
	# Stone dais
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.16, 0.10, 0.20)
	stone_mat.metallic = 0.55
	stone_mat.roughness = 0.45
	var dais: MeshInstance3D = MeshInstance3D.new()
	var dm: CylinderMesh = CylinderMesh.new()
	dm.top_radius = 1.85
	dm.bottom_radius = 2.0
	dm.height = 0.30
	dais.mesh = dm
	dais.position = Vector3(0, 0.15, 0)
	dais.material_override = stone_mat
	portal.add_child(dais)
	# Inner glowing disc
	var disc: MeshInstance3D = MeshInstance3D.new()
	var disc_mesh: CylinderMesh = CylinderMesh.new()
	disc_mesh.top_radius = 1.55
	disc_mesh.bottom_radius = 1.55
	disc_mesh.height = 0.06
	disc.mesh = disc_mesh
	disc.position = Vector3(0, 0.32, 0)
	var disc_mat: StandardMaterial3D = StandardMaterial3D.new()
	disc_mat.albedo_color = Color(0.85, 0.40, 1.0)
	disc_mat.emission_enabled = true
	disc_mat.emission = Color(1.0, 0.55, 1.0)
	disc_mat.emission_energy_multiplier = 2.4
	disc_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	disc.material_override = disc_mat
	portal.add_child(disc)
	# Beam pivot — 4 upright beams that rotate around the center
	var beam_pivot: Node3D = Node3D.new()
	portal.add_child(beam_pivot)
	for i in 4:
		var angle: float = (float(i) / 4.0) * TAU
		var beam: MeshInstance3D = MeshInstance3D.new()
		var bmesh: BoxMesh = BoxMesh.new()
		bmesh.size = Vector3(0.18, 3.40, 0.18)
		beam.mesh = bmesh
		beam.position = Vector3(cos(angle) * 1.40, 1.85, sin(angle) * 1.40)
		var bmat: StandardMaterial3D = StandardMaterial3D.new()
		bmat.albedo_color = Color(0.85, 0.40, 1.0)
		bmat.emission_enabled = true
		bmat.emission = Color(1.0, 0.55, 1.0)
		bmat.emission_energy_multiplier = 3.0
		bmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		beam.material_override = bmat
		beam_pivot.add_child(beam)
	# Rotate the beam pivot
	var spin: Tween = create_tween().set_loops()
	spin.tween_property(beam_pivot, "rotation:y", TAU, 8.0)
	# Real OmniLight inside
	var light: OmniLight3D = OmniLight3D.new()
	light.position = Vector3(0, 1.85, 0)
	light.light_color = Color(1.0, 0.55, 1.0)
	light.light_energy = 2.4
	light.omni_range = 8.0
	portal.add_child(light)
	# Sign
	var label: Label3D = Label3D.new()
	label.text = "PORTAL PAD"
	label.position = Vector3(0, 4.0, 0)
	label.modulate = Color(1.0, 0.55, 1.0)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 16
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	portal.add_child(label)


func _build_d3_ritualist_npc() -> void:
	## Epic-3 T39: Ritualist NPC standing by the ritual circle with arms
	## outstretched, casting a spell. Has glowing palms and a tall hat.
	var slots: Node3D = get_node_or_null("%NPCSlots") as Node3D
	if slots == null:
		return
	var rit: Node3D = Node3D.new()
	rit.name = "D3Ritualist"
	rit.position = D3_CENTER + Vector3(0, 0, 4)
	rit.rotation = Vector3(0, deg_to_rad(180), 0)
	slots.add_child(rit)
	# Robed body
	var bmat: StandardMaterial3D = StandardMaterial3D.new()
	bmat.albedo_color = Color(0.20, 0.10, 0.30)
	bmat.metallic = 0.20
	bmat.roughness = 0.65
	bmat.emission_enabled = true
	bmat.emission = Color(0.55, 0.30, 0.85)
	bmat.emission_energy_multiplier = 0.40
	var body: MeshInstance3D = MeshInstance3D.new()
	var bmesh: CapsuleMesh = CapsuleMesh.new()
	bmesh.radius = 0.45
	bmesh.height = 1.40
	body.mesh = bmesh
	body.position = Vector3(0, 0.70, 0)
	body.material_override = bmat
	rit.add_child(body)
	# Tall conical hat (prism)
	var hat: MeshInstance3D = MeshInstance3D.new()
	var hm: PrismMesh = PrismMesh.new()
	hm.size = Vector3(0.55, 0.85, 0.55)
	hat.mesh = hm
	hat.position = Vector3(0, 1.85, 0)
	hat.material_override = bmat
	rit.add_child(hat)
	# 2 violet eyes
	var eye_mat: StandardMaterial3D = StandardMaterial3D.new()
	eye_mat.albedo_color = Color(1.0, 0.55, 1.0)
	eye_mat.emission_enabled = true
	eye_mat.emission = Color(1.0, 0.55, 1.0)
	eye_mat.emission_energy_multiplier = 2.6
	eye_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for ex: float in [-0.10, 0.10]:
		var eye: MeshInstance3D = MeshInstance3D.new()
		var em: SphereMesh = SphereMesh.new()
		em.radius = 0.06
		em.height = 0.12
		eye.mesh = em
		eye.position = Vector3(ex, 1.40, 0.36)
		eye.material_override = eye_mat
		rit.add_child(eye)
	# Outstretched arms with glowing palms
	for sx: float in [-1.0, 1.0]:
		var arm: MeshInstance3D = MeshInstance3D.new()
		var am: BoxMesh = BoxMesh.new()
		am.size = Vector3(0.85, 0.18, 0.18)
		arm.mesh = am
		arm.position = Vector3(sx * 0.65, 0.95, 0.30)
		arm.material_override = bmat
		rit.add_child(arm)
		# Glowing palm sphere
		var palm: MeshInstance3D = MeshInstance3D.new()
		var pm: SphereMesh = SphereMesh.new()
		pm.radius = 0.18
		pm.height = 0.36
		palm.mesh = pm
		palm.position = Vector3(sx * 1.0, 0.95, 0.30)
		var pmat: StandardMaterial3D = StandardMaterial3D.new()
		pmat.albedo_color = Color(1.0, 0.55, 1.0)
		pmat.emission_enabled = true
		pmat.emission = Color(1.0, 0.55, 1.0)
		pmat.emission_energy_multiplier = 3.0
		pmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		palm.material_override = pmat
		rit.add_child(palm)
	# Name billboard
	var label: Label3D = Label3D.new()
	label.text = "Ritualist"
	label.position = Vector3(0, 2.85, 0)
	label.modulate = Color(0.85, 0.55, 1.0)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 18
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	rit.add_child(label)


func _build_d3_violet_braziers(geom: Node) -> void:
	## Epic-3 T40: 4 violet flame braziers at the corners of the great
	## crystal platform — stone bowls with flame particles rising from them.
	var positions: Array[Vector3] = [
		D3_CENTER + Vector3(-3, 0, -3),
		D3_CENTER + Vector3(3, 0, -3),
		D3_CENTER + Vector3(-3, 0, 3),
		D3_CENTER + Vector3(3, 0, 3),
	]
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.16, 0.10, 0.20)
	stone_mat.metallic = 0.55
	stone_mat.roughness = 0.45
	for i in positions.size():
		var brazier: Node3D = Node3D.new()
		brazier.name = "D3Brazier_%d" % i
		brazier.position = positions[i]
		geom.add_child(brazier)
		# Stem column
		var stem: MeshInstance3D = MeshInstance3D.new()
		var sm: CylinderMesh = CylinderMesh.new()
		sm.top_radius = 0.18
		sm.bottom_radius = 0.22
		sm.height = 1.20
		stem.mesh = sm
		stem.position = Vector3(0, 0.60, 0)
		stem.material_override = stone_mat
		brazier.add_child(stem)
		# Bowl on top — wider cylinder
		var bowl: MeshInstance3D = MeshInstance3D.new()
		var bm: CylinderMesh = CylinderMesh.new()
		bm.top_radius = 0.40
		bm.bottom_radius = 0.18
		bm.height = 0.30
		bowl.mesh = bm
		bowl.position = Vector3(0, 1.30, 0)
		bowl.material_override = stone_mat
		brazier.add_child(bowl)
		# Flame particles rising
		var flame: GPUParticles3D = GPUParticles3D.new()
		flame.amount = 30
		flame.lifetime = 1.4
		flame.position = Vector3(0, 1.55, 0)
		var pmat: ParticleProcessMaterial = ParticleProcessMaterial.new()
		pmat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
		pmat.emission_sphere_radius = 0.20
		pmat.direction = Vector3(0, 1, 0)
		pmat.spread = 12.0
		pmat.initial_velocity_min = 1.0
		pmat.initial_velocity_max = 1.85
		pmat.gravity = Vector3.ZERO
		pmat.scale_min = 0.18
		pmat.scale_max = 0.35
		pmat.color = Color(1.0, 0.55, 1.0, 1.0)
		flame.process_material = pmat
		var fm: SphereMesh = SphereMesh.new()
		fm.radius = 0.18
		fm.height = 0.36
		var fmat: StandardMaterial3D = StandardMaterial3D.new()
		fmat.albedo_color = Color(1.0, 0.55, 1.0)
		fmat.emission_enabled = true
		fmat.emission = Color(1.0, 0.55, 1.0)
		fmat.emission_energy_multiplier = 2.6
		fmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		fm.material = fmat
		flame.draw_pass_1 = fm
		brazier.add_child(flame)
		# OmniLight from the brazier
		var light: OmniLight3D = OmniLight3D.new()
		light.position = Vector3(0, 1.65, 0)
		light.light_color = Color(1.0, 0.55, 1.0)
		light.light_energy = 1.4
		light.omni_range = 4.5
		brazier.add_child(light)
		# Collision around brazier
		var sb: StaticBody3D = StaticBody3D.new()
		var cs: CollisionShape3D = CollisionShape3D.new()
		var cap: CapsuleShape3D = CapsuleShape3D.new()
		cap.radius = 0.30
		cap.height = 1.40
		cs.shape = cap
		cs.position = Vector3(0, 0.70, 0)
		sb.add_child(cs)
		brazier.add_child(sb)


func _build_d3_spell_puzzle(geom: Node) -> void:
	## Epic-3 T41: a spell circle puzzle on the ground — 4 colored rune
	## tiles in a square arrangement, each pulsing in a different color.
	## Looks like a "step on these in order" puzzle.
	var puzzle: Node3D = Node3D.new()
	puzzle.name = "D3SpellPuzzle"
	puzzle.position = D3_CENTER + Vector3(-12, 0.06, 14)
	geom.add_child(puzzle)
	# Outer circle frame
	var frame: MeshInstance3D = MeshInstance3D.new()
	var fmesh: TorusMesh = TorusMesh.new()
	fmesh.inner_radius = 1.85
	fmesh.outer_radius = 2.10
	frame.mesh = fmesh
	var fmat: StandardMaterial3D = StandardMaterial3D.new()
	fmat.albedo_color = Color(0.16, 0.10, 0.20)
	fmat.metallic = 0.55
	fmat.roughness = 0.45
	fmat.emission_enabled = true
	fmat.emission = Color(0.85, 0.40, 1.0)
	fmat.emission_energy_multiplier = 0.85
	frame.material_override = fmat
	puzzle.add_child(frame)
	# 4 colored rune tiles
	var tile_specs: Array = [
		[Vector3(-1.0, 0.04, 0), Color(0.55, 0.95, 1.0), "I"],
		[Vector3(1.0, 0.04, 0), Color(1.0, 0.55, 0.20), "II"],
		[Vector3(0, 0.04, -1.0), Color(0.45, 1.0, 0.55), "III"],
		[Vector3(0, 0.04, 1.0), Color(0.85, 0.40, 1.0), "IV"],
	]
	for spec in tile_specs:
		var tile: MeshInstance3D = MeshInstance3D.new()
		var tm: BoxMesh = BoxMesh.new()
		tm.size = Vector3(0.65, 0.10, 0.65)
		tile.mesh = tm
		tile.position = spec[0]
		var color: Color = spec[1]
		var tmat: StandardMaterial3D = StandardMaterial3D.new()
		tmat.albedo_color = color
		tmat.emission_enabled = true
		tmat.emission = color
		tmat.emission_energy_multiplier = 1.8
		tmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		tile.material_override = tmat
		puzzle.add_child(tile)
		# Roman numeral on top
		var label: Label3D = Label3D.new()
		label.text = spec[2]
		label.position = (spec[0] as Vector3) + Vector3(0, 0.07, 0)
		label.rotation = Vector3(deg_to_rad(-90), 0, 0)
		label.modulate = Color(1, 1, 1)
		label.outline_modulate = Color(0, 0, 0, 0.85)
		label.outline_size = 4
		label.font_size = 16
		label.no_depth_test = true
		puzzle.add_child(label)
		# Pulse on independent timing
		var pulse: Tween = create_tween().set_loops()
		pulse.tween_property(tmat, "emission_energy_multiplier", 3.0, 0.85 + tile.position.x * 0.1).set_ease(Tween.EASE_IN_OUT)
		pulse.tween_property(tmat, "emission_energy_multiplier", 1.4, 0.85 + tile.position.x * 0.1).set_ease(Tween.EASE_IN_OUT)


func _build_d3_floating_stair(geom: Node) -> void:
	## Epic-3 T42: a vertical "floating platform staircase" — 8 small
	## platforms hovering at ascending heights forming a climbable path
	## up to 8m altitude.
	var stair: Node3D = Node3D.new()
	stair.name = "D3FloatingStair"
	stair.position = D3_CENTER + Vector3(20, 0, -12)
	geom.add_child(stair)
	var pad_mat: StandardMaterial3D = StandardMaterial3D.new()
	pad_mat.albedo_color = Color(0.16, 0.10, 0.20)
	pad_mat.metallic = 0.55
	pad_mat.roughness = 0.45
	pad_mat.emission_enabled = true
	pad_mat.emission = Color(0.85, 0.40, 1.0)
	pad_mat.emission_energy_multiplier = 0.55
	for i in 8:
		var pad: MeshInstance3D = MeshInstance3D.new()
		pad.name = "StairPad_%d" % i
		var pm: BoxMesh = BoxMesh.new()
		pm.size = Vector3(1.40, 0.20, 1.40)
		pad.mesh = pm
		pad.position = Vector3(i * 0.85, 1.0 + i * 0.85, sin(i * 0.5) * 0.55)
		pad.material_override = pad_mat
		stair.add_child(pad)
		# Bob each pad slightly on its own timing
		var origin: Vector3 = pad.position
		var bob: Tween = create_tween().set_loops()
		bob.tween_property(pad, "position:y", origin.y + 0.20, 1.4 + i * 0.1).set_ease(Tween.EASE_IN_OUT)
		bob.tween_property(pad, "position:y", origin.y, 1.4 + i * 0.1).set_ease(Tween.EASE_IN_OUT)
		# Per-pad collision
		var sb: StaticBody3D = StaticBody3D.new()
		var cs: CollisionShape3D = CollisionShape3D.new()
		var cb: BoxShape3D = BoxShape3D.new()
		cb.size = Vector3(1.40, 0.20, 1.40)
		cs.shape = cb
		cs.position = origin
		sb.add_child(cs)
		stair.add_child(sb)


func _build_d3_chained_statue(geom: Node) -> void:
	## Epic-3 T43: a chained ancient statue — humanoid stone figure with
	## 4 thin chain cylinders binding it to the ground. Tells "ancient
	## power was sealed here".
	var statue: Node3D = Node3D.new()
	statue.name = "D3ChainedStatue"
	statue.position = D3_CENTER + Vector3(8, 0, 16)
	geom.add_child(statue)
	# Stone body
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.20, 0.16, 0.26)
	stone_mat.metallic = 0.40
	stone_mat.roughness = 0.55
	var torso: MeshInstance3D = MeshInstance3D.new()
	var tm: BoxMesh = BoxMesh.new()
	tm.size = Vector3(1.20, 1.85, 0.85)
	torso.mesh = tm
	torso.position = Vector3(0, 1.30, 0)
	torso.material_override = stone_mat
	statue.add_child(torso)
	# Head sphere
	var head: MeshInstance3D = MeshInstance3D.new()
	var hm: SphereMesh = SphereMesh.new()
	hm.radius = 0.45
	hm.height = 0.85
	head.mesh = hm
	head.position = Vector3(0, 2.65, 0)
	head.material_override = stone_mat
	statue.add_child(head)
	# 2 dim violet eyes
	var eye_mat: StandardMaterial3D = StandardMaterial3D.new()
	eye_mat.albedo_color = Color(0.85, 0.40, 1.0)
	eye_mat.emission_enabled = true
	eye_mat.emission = Color(1.0, 0.55, 1.0)
	eye_mat.emission_energy_multiplier = 1.4
	eye_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for ex: float in [-0.15, 0.15]:
		var eye: MeshInstance3D = MeshInstance3D.new()
		var em: SphereMesh = SphereMesh.new()
		em.radius = 0.07
		em.height = 0.14
		eye.mesh = em
		eye.position = Vector3(ex, 2.70, 0.36)
		eye.material_override = eye_mat
		statue.add_child(eye)
	# 4 chain cylinders binding it to the ground at angles
	var chain_mat: StandardMaterial3D = StandardMaterial3D.new()
	chain_mat.albedo_color = Color(0.10, 0.10, 0.13)
	chain_mat.metallic = 0.85
	chain_mat.roughness = 0.30
	for i in 4:
		var angle: float = (float(i) / 4.0) * TAU
		var chain: MeshInstance3D = MeshInstance3D.new()
		var cm: CylinderMesh = CylinderMesh.new()
		cm.top_radius = 0.06
		cm.bottom_radius = 0.06
		cm.height = 2.40
		chain.mesh = cm
		chain.position = Vector3(cos(angle) * 0.95, 1.20, sin(angle) * 0.95)
		# Tilt chains outward toward ground
		chain.rotation = Vector3(sin(angle) * deg_to_rad(40), 0, -cos(angle) * deg_to_rad(40))
		chain.material_override = chain_mat
		statue.add_child(chain)
	# Collision around statue
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(1.40, 3.40, 1.0)
	cs.shape = cb
	cs.position = Vector3(0, 1.70, 0)
	sb.add_child(cs)
	statue.add_child(sb)


func _build_d3_librarian_npc() -> void:
	## Epic-3 T44: Librarian NPC standing next to the floating bookshelves
	## holding an open glowing book in front of them.
	var slots: Node3D = get_node_or_null("%NPCSlots") as Node3D
	if slots == null:
		return
	var lib: Node3D = Node3D.new()
	lib.name = "D3Librarian"
	lib.position = D3_CENTER + Vector3(-18, 0, 1)
	slots.add_child(lib)
	# Robed body
	var bmat: StandardMaterial3D = StandardMaterial3D.new()
	bmat.albedo_color = Color(0.20, 0.16, 0.30)
	bmat.metallic = 0.20
	bmat.roughness = 0.65
	bmat.emission_enabled = true
	bmat.emission = Color(0.55, 0.30, 0.85)
	bmat.emission_energy_multiplier = 0.40
	var body: MeshInstance3D = MeshInstance3D.new()
	var bmesh: CapsuleMesh = CapsuleMesh.new()
	bmesh.radius = 0.42
	bmesh.height = 1.30
	body.mesh = bmesh
	body.position = Vector3(0, 0.70, 0)
	body.material_override = bmat
	lib.add_child(body)
	# Head
	var head: MeshInstance3D = MeshInstance3D.new()
	var hm: SphereMesh = SphereMesh.new()
	hm.radius = 0.36
	hm.height = 0.65
	head.mesh = hm
	head.position = Vector3(0, 1.55, 0)
	head.material_override = bmat
	lib.add_child(head)
	# Round glasses (2 small black torus)
	var glass_mat: StandardMaterial3D = StandardMaterial3D.new()
	glass_mat.albedo_color = Color(0.08, 0.08, 0.10)
	glass_mat.metallic = 0.55
	glass_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for ex: float in [-0.13, 0.13]:
		var glass: MeshInstance3D = MeshInstance3D.new()
		var gm: TorusMesh = TorusMesh.new()
		gm.inner_radius = 0.06
		gm.outer_radius = 0.10
		glass.mesh = gm
		glass.position = Vector3(ex, 1.55, 0.30)
		glass.rotation = Vector3(deg_to_rad(90), 0, 0)
		glass.material_override = glass_mat
		lib.add_child(glass)
	# Open book held in front (2 angled boxes)
	var book_mat: StandardMaterial3D = StandardMaterial3D.new()
	book_mat.albedo_color = Color(0.95, 0.85, 0.55)
	book_mat.emission_enabled = true
	book_mat.emission = Color(1.0, 0.85, 0.55)
	book_mat.emission_energy_multiplier = 1.4
	book_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for sx: float in [-0.18, 0.18]:
		var page: MeshInstance3D = MeshInstance3D.new()
		var pm: BoxMesh = BoxMesh.new()
		pm.size = Vector3(0.30, 0.04, 0.40)
		page.mesh = pm
		page.position = Vector3(sx, 0.85, 0.55)
		page.rotation = Vector3(0, 0, sign(sx) * deg_to_rad(15))
		page.material_override = book_mat
		lib.add_child(page)
	# Name billboard
	var label: Label3D = Label3D.new()
	label.text = "Librarian"
	label.position = Vector3(0, 2.20, 0)
	label.modulate = Color(1.0, 0.85, 0.55)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 18
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	lib.add_child(label)


func _build_d3_elemental_wisps(geom: Node) -> void:
	## Epic-3 T45: 4 elemental wisps in different colors (fire/ice/leaf/
	## storm) drifting near the spell puzzle as if guarding it.
	var wisp_specs: Array = [
		[D3_CENTER + Vector3(-10, 2.5, 13), Color(1.0, 0.40, 0.20)],
		[D3_CENTER + Vector3(-14, 2.5, 13), Color(0.55, 0.95, 1.0)],
		[D3_CENTER + Vector3(-12, 3.5, 11), Color(0.45, 1.0, 0.55)],
		[D3_CENTER + Vector3(-12, 3.5, 16), Color(1.0, 0.95, 0.30)],
	]
	for i in wisp_specs.size():
		var wisp: MeshInstance3D = MeshInstance3D.new()
		wisp.name = "D3ElementalWisp_%d" % i
		var wm: SphereMesh = SphereMesh.new()
		wm.radius = 0.20
		wm.height = 0.40
		wisp.mesh = wm
		wisp.position = wisp_specs[i][0]
		var color: Color = wisp_specs[i][1]
		var wmat: StandardMaterial3D = StandardMaterial3D.new()
		wmat.albedo_color = color
		wmat.emission_enabled = true
		wmat.emission = color
		wmat.emission_energy_multiplier = 3.0
		wmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		wisp.material_override = wmat
		geom.add_child(wisp)
		# Pulse + bob
		var pulse: Tween = create_tween().set_loops()
		pulse.tween_property(wisp, "scale", Vector3(1.40, 1.40, 1.40), 0.85 + i * 0.1).set_ease(Tween.EASE_IN_OUT)
		pulse.tween_property(wisp, "scale", Vector3(0.85, 0.85, 0.85), 0.85 + i * 0.1).set_ease(Tween.EASE_IN_OUT)
		var origin: Vector3 = wisp_specs[i][0]
		var bob: Tween = create_tween().set_loops()
		bob.tween_property(wisp, "position:y", origin.y + 0.55, 1.4 + i * 0.15).set_ease(Tween.EASE_IN_OUT)
		bob.tween_property(wisp, "position:y", origin.y, 1.4 + i * 0.15).set_ease(Tween.EASE_IN_OUT)


func _build_d3_sky_portal(geom: Node) -> void:
	## Epic-3 T46: a large sky portal ring 16m above the district center —
	## a huge translucent torus with 8 emissive runes around its edge,
	## slowly rotating + tilted at an angle.
	var portal: Node3D = Node3D.new()
	portal.name = "D3SkyPortal"
	portal.position = D3_CENTER + Vector3(0, 16, 0)
	portal.rotation = Vector3(deg_to_rad(20), 0, 0)
	geom.add_child(portal)
	# Big ring torus
	var ring: MeshInstance3D = MeshInstance3D.new()
	var rmesh: TorusMesh = TorusMesh.new()
	rmesh.inner_radius = 5.5
	rmesh.outer_radius = 6.0
	ring.mesh = rmesh
	var rmat: StandardMaterial3D = StandardMaterial3D.new()
	rmat.albedo_color = Color(0.85, 0.40, 1.0, 0.85)
	rmat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	rmat.emission_enabled = true
	rmat.emission = Color(1.0, 0.55, 1.0)
	rmat.emission_energy_multiplier = 2.4
	rmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	ring.material_override = rmat
	portal.add_child(ring)
	# 8 small emissive rune dots around the ring's edge
	for i in 8:
		var angle: float = (float(i) / 8.0) * TAU
		var rune: MeshInstance3D = MeshInstance3D.new()
		var rm: SphereMesh = SphereMesh.new()
		rm.radius = 0.30
		rm.height = 0.60
		rune.mesh = rm
		rune.position = Vector3(cos(angle) * 5.75, 0, sin(angle) * 5.75)
		var rmat2: StandardMaterial3D = StandardMaterial3D.new()
		rmat2.albedo_color = Color(1.0, 0.55, 1.0)
		rmat2.emission_enabled = true
		rmat2.emission = Color(1.0, 0.55, 1.0)
		rmat2.emission_energy_multiplier = 3.0
		rmat2.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		rune.material_override = rmat2
		portal.add_child(rune)
	# Slow rotation
	var spin: Tween = create_tween().set_loops()
	spin.tween_property(portal, "rotation:z", TAU, 24.0)


func _build_d3_judgment_dais(geom: Node) -> void:
	## Epic-3 T47: a raised judgment dais with a throne — 3-step stone
	## platform supporting a tall stone seat. Empty throne suggesting
	## "the judge of memories has not yet returned".
	var dais: Node3D = Node3D.new()
	dais.name = "D3JudgmentDais"
	dais.position = D3_CENTER + Vector3(-15, 0, 14)
	geom.add_child(dais)
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.16, 0.10, 0.20)
	stone_mat.metallic = 0.55
	stone_mat.roughness = 0.45
	# 3 stepped platforms
	for i in 3:
		var step: MeshInstance3D = MeshInstance3D.new()
		var sm: BoxMesh = BoxMesh.new()
		sm.size = Vector3(3.40 - i * 0.55, 0.30, 3.40 - i * 0.55)
		step.mesh = sm
		step.position = Vector3(0, 0.15 + i * 0.30, 0)
		step.material_override = stone_mat
		dais.add_child(step)
	# Throne — vertical box body + tall back
	var seat: MeshInstance3D = MeshInstance3D.new()
	var sm: BoxMesh = BoxMesh.new()
	sm.size = Vector3(1.40, 0.65, 1.20)
	seat.mesh = sm
	seat.position = Vector3(0, 1.20, 0)
	seat.material_override = stone_mat
	dais.add_child(seat)
	# Tall throne back
	var back: MeshInstance3D = MeshInstance3D.new()
	var bm: BoxMesh = BoxMesh.new()
	bm.size = Vector3(1.40, 2.85, 0.30)
	back.mesh = bm
	back.position = Vector3(0, 2.55, -0.45)
	back.material_override = stone_mat
	dais.add_child(back)
	# Crowning gem on the throne back
	var gem: MeshInstance3D = MeshInstance3D.new()
	var gm: SphereMesh = SphereMesh.new()
	gm.radius = 0.30
	gm.height = 0.60
	gem.mesh = gm
	gem.position = Vector3(0, 4.0, -0.45)
	var gmat: StandardMaterial3D = StandardMaterial3D.new()
	gmat.albedo_color = Color(0.85, 0.40, 1.0)
	gmat.emission_enabled = true
	gmat.emission = Color(1.0, 0.55, 1.0)
	gmat.emission_energy_multiplier = 3.0
	gmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	gem.material_override = gmat
	dais.add_child(gem)
	# Pulse the gem
	var pulse: Tween = create_tween().set_loops()
	pulse.tween_property(gem, "scale", Vector3(1.30, 1.30, 1.30), 1.4).set_ease(Tween.EASE_IN_OUT)
	pulse.tween_property(gem, "scale", Vector3(0.85, 0.85, 0.85), 1.4).set_ease(Tween.EASE_IN_OUT)
	# Sign
	var label: Label3D = Label3D.new()
	label.text = "JUDGMENT DAIS"
	label.position = Vector3(0, 4.85, 0)
	label.modulate = Color(0.85, 0.55, 1.0)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 18
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	dais.add_child(label)
	# Collision around dais
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(3.40, 4.0, 3.40)
	cs.shape = cb
	cs.position = Vector3(0, 2.0, 0)
	sb.add_child(cs)
	dais.add_child(sb)


func _build_d3_echo_singer_npc() -> void:
	## Epic-3 T48: Echo Singer NPC — translucent figure with a flowing
	## robe that "sings" memory echoes. Has 5 small floating note glyphs
	## drifting around their head.
	var slots: Node3D = get_node_or_null("%NPCSlots") as Node3D
	if slots == null:
		return
	var singer: Node3D = Node3D.new()
	singer.name = "D3EchoSinger"
	singer.position = D3_CENTER + Vector3(15, 0, 14)
	slots.add_child(singer)
	# Translucent robed body
	var bmat: StandardMaterial3D = StandardMaterial3D.new()
	bmat.albedo_color = Color(0.55, 0.85, 1.0, 0.55)
	bmat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	bmat.emission_enabled = true
	bmat.emission = Color(0.55, 0.95, 1.0)
	bmat.emission_energy_multiplier = 1.4
	bmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var body: MeshInstance3D = MeshInstance3D.new()
	var bmesh: CapsuleMesh = CapsuleMesh.new()
	bmesh.radius = 0.45
	bmesh.height = 1.40
	body.mesh = bmesh
	body.position = Vector3(0, 0.70, 0)
	body.material_override = bmat
	singer.add_child(body)
	# Head
	var head: MeshInstance3D = MeshInstance3D.new()
	var hm: SphereMesh = SphereMesh.new()
	hm.radius = 0.36
	hm.height = 0.65
	head.mesh = hm
	head.position = Vector3(0, 1.55, 0)
	head.material_override = bmat
	singer.add_child(head)
	# Open singing mouth
	var mouth: MeshInstance3D = MeshInstance3D.new()
	var mm: SphereMesh = SphereMesh.new()
	mm.radius = 0.10
	mm.height = 0.20
	mouth.mesh = mm
	mouth.position = Vector3(0, 1.45, 0.30)
	var momat: StandardMaterial3D = StandardMaterial3D.new()
	momat.albedo_color = Color(1, 1, 1)
	momat.emission_enabled = true
	momat.emission = Color(1, 1, 1)
	momat.emission_energy_multiplier = 2.6
	momat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mouth.material_override = momat
	singer.add_child(mouth)
	# 5 floating note glyphs around the head
	var note_pivot: Node3D = Node3D.new()
	note_pivot.position = Vector3(0, 1.85, 0)
	singer.add_child(note_pivot)
	for i in 5:
		var angle: float = (float(i) / 5.0) * TAU
		var note: Label3D = Label3D.new()
		note.text = "♪"
		note.position = Vector3(cos(angle) * 0.65, sin(i * 0.5) * 0.20, sin(angle) * 0.65)
		note.modulate = Color(0.55, 0.95, 1.0)
		note.outline_modulate = Color(0, 0, 0, 0.85)
		note.outline_size = 4
		note.font_size = 22
		note.no_depth_test = true
		note.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		note_pivot.add_child(note)
	# Rotate the note pivot
	var spin: Tween = create_tween().set_loops()
	spin.tween_property(note_pivot, "rotation:y", TAU, 4.0)
	# Name billboard
	var label: Label3D = Label3D.new()
	label.text = "Echo Singer"
	label.position = Vector3(0, 2.85, 0)
	label.modulate = Color(0.55, 0.95, 1.0)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 18
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	singer.add_child(label)


func _build_d3_mana_crystals(geom: Node) -> void:
	## Epic-3 T49: a cluster of 6 floating mana crystals at the corners
	## of the judgment dais — each is a small spinning prism with strong
	## emission.
	var positions: Array[Vector3] = [
		D3_CENTER + Vector3(-18, 0.5, 12),
		D3_CENTER + Vector3(-12, 0.5, 12),
		D3_CENTER + Vector3(-15, 0.5, 11),
		D3_CENTER + Vector3(-18, 0.5, 17),
		D3_CENTER + Vector3(-12, 0.5, 17),
		D3_CENTER + Vector3(-15, 0.5, 18),
	]
	var crystal_mat: StandardMaterial3D = StandardMaterial3D.new()
	crystal_mat.albedo_color = Color(0.85, 0.40, 1.0)
	crystal_mat.emission_enabled = true
	crystal_mat.emission = Color(1.0, 0.55, 1.0)
	crystal_mat.emission_energy_multiplier = 2.4
	crystal_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for i in positions.size():
		var crystal: MeshInstance3D = MeshInstance3D.new()
		crystal.name = "D3ManaCrystal_%d" % i
		var cmesh: PrismMesh = PrismMesh.new()
		cmesh.size = Vector3(0.30, 0.65, 0.30)
		crystal.mesh = cmesh
		crystal.position = positions[i]
		crystal.material_override = crystal_mat
		geom.add_child(crystal)
		var spin: Tween = create_tween().set_loops()
		spin.tween_property(crystal, "rotation:y", TAU, 4.0 + i * 0.3)
		var bob: Tween = create_tween().set_loops()
		bob.tween_property(crystal, "position:y", positions[i].y + 0.30, 1.4 + i * 0.1).set_ease(Tween.EASE_IN_OUT)
		bob.tween_property(crystal, "position:y", positions[i].y, 1.4 + i * 0.1).set_ease(Tween.EASE_IN_OUT)


func _build_d3_memory_echo(geom: Node) -> void:
	## Epic-3 T50: MEMORY ECHO mini-boss — large translucent face with
	## 4 floating cube fragments orbiting it. Slow patrol around the
	## sealed gates area.
	var echo: Node3D = Node3D.new()
	echo.name = "D3MemoryEcho"
	echo.position = D3_CENTER + Vector3(20, 0, 8)
	geom.add_child(echo)
	# Big translucent head sphere
	var head_mat: StandardMaterial3D = StandardMaterial3D.new()
	head_mat.albedo_color = Color(0.55, 0.30, 0.85, 0.45)
	head_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	head_mat.emission_enabled = true
	head_mat.emission = Color(1.0, 0.55, 1.0)
	head_mat.emission_energy_multiplier = 2.0
	head_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var head: MeshInstance3D = MeshInstance3D.new()
	var hmesh: SphereMesh = SphereMesh.new()
	hmesh.radius = 1.40
	hmesh.height = 2.80
	head.mesh = hmesh
	head.position = Vector3(0, 2.40, 0)
	head.material_override = head_mat
	echo.add_child(head)
	# 2 huge glowing white eyes
	var eye_mat: StandardMaterial3D = StandardMaterial3D.new()
	eye_mat.albedo_color = Color(1, 1, 1)
	eye_mat.emission_enabled = true
	eye_mat.emission = Color(1, 1, 1)
	eye_mat.emission_energy_multiplier = 3.4
	eye_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for ex: float in [-0.45, 0.45]:
		var eye: MeshInstance3D = MeshInstance3D.new()
		var em: SphereMesh = SphereMesh.new()
		em.radius = 0.30
		em.height = 0.60
		eye.mesh = em
		eye.position = Vector3(ex, 2.55, 1.0)
		eye.material_override = eye_mat
		echo.add_child(eye)
	# Floating mouth slit
	var mouth: MeshInstance3D = MeshInstance3D.new()
	var mm: BoxMesh = BoxMesh.new()
	mm.size = Vector3(0.85, 0.10, 0.06)
	mouth.mesh = mm
	mouth.position = Vector3(0, 1.85, 1.20)
	var momat: StandardMaterial3D = StandardMaterial3D.new()
	momat.albedo_color = Color(1.0, 0.55, 1.0)
	momat.emission_enabled = true
	momat.emission = Color(1.0, 0.55, 1.0)
	momat.emission_energy_multiplier = 2.6
	momat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mouth.material_override = momat
	echo.add_child(mouth)
	# 4 cube fragments orbiting head
	var orbit_pivot: Node3D = Node3D.new()
	orbit_pivot.position = Vector3(0, 2.40, 0)
	echo.add_child(orbit_pivot)
	for i in 4:
		var angle: float = (float(i) / 4.0) * TAU
		var frag: MeshInstance3D = MeshInstance3D.new()
		var fmesh: BoxMesh = BoxMesh.new()
		fmesh.size = Vector3(0.40, 0.40, 0.40)
		frag.mesh = fmesh
		frag.position = Vector3(cos(angle) * 2.20, randf_range(-0.30, 0.30), sin(angle) * 2.20)
		var fmat: StandardMaterial3D = StandardMaterial3D.new()
		fmat.albedo_color = Color(0.85, 0.40, 1.0, 0.65)
		fmat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		fmat.emission_enabled = true
		fmat.emission = Color(1.0, 0.55, 1.0)
		fmat.emission_energy_multiplier = 2.4
		fmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		frag.material_override = fmat
		orbit_pivot.add_child(frag)
	var spin: Tween = create_tween().set_loops()
	spin.tween_property(orbit_pivot, "rotation:y", TAU, 8.0)
	# Slow patrol path
	var origin: Vector3 = D3_CENTER + Vector3(20, 0, 8)
	var patrol: Tween = create_tween().set_loops()
	patrol.tween_property(echo, "position", origin + Vector3(-4, 0, -4), 6.0).set_ease(Tween.EASE_IN_OUT)
	patrol.tween_property(echo, "position", origin + Vector3(-4, 0, 4), 6.0).set_ease(Tween.EASE_IN_OUT)
	patrol.tween_property(echo, "position", origin, 6.0).set_ease(Tween.EASE_IN_OUT)
	# Boss-tier name billboard
	var label: Label3D = Label3D.new()
	label.text = "MEMORY ECHO"
	label.position = Vector3(0, 4.85, 0)
	label.modulate = Color(1.0, 0.55, 1.0)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 6
	label.font_size = 22
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	echo.add_child(label)


func _build_d3_ancient_pool(geom: Node) -> void:
	## Epic-3 T51: ancient stone pool with 4 floating "data fish" — small
	## elongated emissive shapes drifting in circles above the surface.
	var pool: Node3D = Node3D.new()
	pool.name = "D3AncientPool"
	pool.position = D3_CENTER + Vector3(15, 0, -8)
	geom.add_child(pool)
	# Stone basin — wider than memory pool
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.16, 0.10, 0.20)
	stone_mat.metallic = 0.55
	stone_mat.roughness = 0.45
	var rim: MeshInstance3D = MeshInstance3D.new()
	var rmesh: TorusMesh = TorusMesh.new()
	rmesh.inner_radius = 1.85
	rmesh.outer_radius = 2.20
	rim.mesh = rmesh
	rim.position = Vector3(0, 0.20, 0)
	rim.material_override = stone_mat
	pool.add_child(rim)
	# Water surface — translucent cyan disc
	var water: MeshInstance3D = MeshInstance3D.new()
	var wmesh: CylinderMesh = CylinderMesh.new()
	wmesh.top_radius = 1.85
	wmesh.bottom_radius = 1.85
	wmesh.height = 0.06
	water.mesh = wmesh
	water.position = Vector3(0, 0.20, 0)
	var wmat: StandardMaterial3D = StandardMaterial3D.new()
	wmat.albedo_color = Color(0.30, 0.85, 1.0, 0.55)
	wmat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	wmat.emission_enabled = true
	wmat.emission = Color(0.55, 0.95, 1.0)
	wmat.emission_energy_multiplier = 1.4
	wmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	water.material_override = wmat
	pool.add_child(water)
	# 4 data fish — small elongated boxes circling
	var fish_pivot: Node3D = Node3D.new()
	fish_pivot.position = Vector3(0, 0.55, 0)
	pool.add_child(fish_pivot)
	for i in 4:
		var angle: float = (float(i) / 4.0) * TAU
		var fish: MeshInstance3D = MeshInstance3D.new()
		var fm: BoxMesh = BoxMesh.new()
		fm.size = Vector3(0.30, 0.10, 0.55)
		fish.mesh = fm
		fish.position = Vector3(cos(angle) * 1.20, 0, sin(angle) * 1.20)
		fish.rotation = Vector3(0, -angle - PI * 0.5, 0)
		var fmat: StandardMaterial3D = StandardMaterial3D.new()
		fmat.albedo_color = Color(0.55, 0.95, 1.0)
		fmat.emission_enabled = true
		fmat.emission = Color(0.55, 0.95, 1.0)
		fmat.emission_energy_multiplier = 2.4
		fmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		fish.material_override = fmat
		fish_pivot.add_child(fish)
	# Rotate the fish pivot
	var spin: Tween = create_tween().set_loops()
	spin.tween_property(fish_pivot, "rotation:y", TAU, 6.0)
	# Sign
	var label: Label3D = Label3D.new()
	label.text = "ANCIENT POOL"
	label.position = Vector3(0, 1.85, 0)
	label.modulate = Color(0.55, 0.95, 1.0)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 16
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	pool.add_child(label)
	# Collision around basin
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(4.0, 0.85, 4.0)
	cs.shape = cb
	cs.position = Vector3(0, 0.42, 0)
	sb.add_child(cs)
	pool.add_child(sb)


func _build_d3_pendulum(geom: Node) -> void:
	## Epic-3 T52: tall hanging pendulum — stone arch frame with a long
	## thin chain holding a heavy weighted ball that swings back and forth.
	var pend: Node3D = Node3D.new()
	pend.name = "D3Pendulum"
	pend.position = D3_CENTER + Vector3(8, 0, -16)
	geom.add_child(pend)
	# Arch frame — 2 thin legs + crossbar
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.16, 0.10, 0.20)
	stone_mat.metallic = 0.55
	stone_mat.roughness = 0.45
	for sx: float in [-1.20, 1.20]:
		var leg: MeshInstance3D = MeshInstance3D.new()
		var lm: CylinderMesh = CylinderMesh.new()
		lm.top_radius = 0.10
		lm.bottom_radius = 0.14
		lm.height = 5.0
		leg.mesh = lm
		leg.position = Vector3(sx, 2.50, 0)
		leg.material_override = stone_mat
		pend.add_child(leg)
		# Collision per leg
		var sb: StaticBody3D = StaticBody3D.new()
		var cs: CollisionShape3D = CollisionShape3D.new()
		var cap: CapsuleShape3D = CapsuleShape3D.new()
		cap.radius = 0.20
		cap.height = 5.0
		cs.shape = cap
		cs.position = Vector3(sx, 2.50, 0)
		sb.add_child(cs)
		pend.add_child(sb)
	# Crossbar
	var bar: MeshInstance3D = MeshInstance3D.new()
	var bm: BoxMesh = BoxMesh.new()
	bm.size = Vector3(2.85, 0.30, 0.30)
	bar.mesh = bm
	bar.position = Vector3(0, 5.0, 0)
	bar.material_override = stone_mat
	pend.add_child(bar)
	# Pendulum pivot at the top
	var pivot: Node3D = Node3D.new()
	pivot.position = Vector3(0, 5.0, 0)
	pend.add_child(pivot)
	# Long chain
	var chain_mat: StandardMaterial3D = StandardMaterial3D.new()
	chain_mat.albedo_color = Color(0.10, 0.10, 0.13)
	chain_mat.metallic = 0.85
	var chain: MeshInstance3D = MeshInstance3D.new()
	var cm: CylinderMesh = CylinderMesh.new()
	cm.top_radius = 0.04
	cm.bottom_radius = 0.04
	cm.height = 3.40
	chain.mesh = cm
	chain.position = Vector3(0, -1.70, 0)
	chain.material_override = chain_mat
	pivot.add_child(chain)
	# Heavy weighted ball
	var ball: MeshInstance3D = MeshInstance3D.new()
	var bm2: SphereMesh = SphereMesh.new()
	bm2.radius = 0.40
	bm2.height = 0.80
	ball.mesh = bm2
	ball.position = Vector3(0, -3.55, 0)
	var ball_mat: StandardMaterial3D = StandardMaterial3D.new()
	ball_mat.albedo_color = Color(0.20, 0.16, 0.26)
	ball_mat.metallic = 0.85
	ball_mat.roughness = 0.30
	ball_mat.emission_enabled = true
	ball_mat.emission = Color(0.85, 0.40, 1.0)
	ball_mat.emission_energy_multiplier = 0.55
	ball.material_override = ball_mat
	pivot.add_child(ball)
	# Swing tween
	var swing: Tween = create_tween().set_loops()
	swing.tween_property(pivot, "rotation:x", deg_to_rad(20), 1.6).set_ease(Tween.EASE_IN_OUT)
	swing.tween_property(pivot, "rotation:x", deg_to_rad(-20), 1.6).set_ease(Tween.EASE_IN_OUT)


func _build_d3_prophecy_stones(geom: Node) -> void:
	## Epic-3 T53: 3 prophecy stones forming a small triangle — each stone
	## is a flat slab with text engraved + glowing emission.
	var positions: Array[Vector3] = [
		D3_CENTER + Vector3(-12, 0, 8),
		D3_CENTER + Vector3(-10, 0, 11),
		D3_CENTER + Vector3(-14, 0, 11),
	]
	var texts: Array[String] = ["PAST", "PRESENT", "FUTURE"]
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.30, 0.20, 0.40)
	stone_mat.metallic = 0.40
	stone_mat.roughness = 0.55
	stone_mat.emission_enabled = true
	stone_mat.emission = Color(0.85, 0.40, 1.0)
	stone_mat.emission_energy_multiplier = 0.55
	for i in positions.size():
		var stone: Node3D = Node3D.new()
		stone.name = "D3ProphecyStone_%d" % i
		stone.position = positions[i]
		stone.rotation = Vector3(0, deg_to_rad(i * 120), 0)
		geom.add_child(stone)
		# Slab body
		var slab: MeshInstance3D = MeshInstance3D.new()
		var sm: BoxMesh = BoxMesh.new()
		sm.size = Vector3(1.0, 1.85, 0.30)
		slab.mesh = sm
		slab.position = Vector3(0, 0.92, 0)
		slab.material_override = stone_mat
		stone.add_child(slab)
		# Engraved text
		var label: Label3D = Label3D.new()
		label.text = texts[i]
		label.position = Vector3(0, 0.92, 0.16)
		label.modulate = Color(1.0, 0.95, 0.30)
		label.outline_modulate = Color(0, 0, 0, 0.85)
		label.outline_size = 4
		label.font_size = 16
		label.no_depth_test = true
		stone.add_child(label)
		# Per-stone collision
		var sb: StaticBody3D = StaticBody3D.new()
		var cs: CollisionShape3D = CollisionShape3D.new()
		var cb: BoxShape3D = BoxShape3D.new()
		cb.size = Vector3(1.0, 1.85, 0.30)
		cs.shape = cb
		cs.position = Vector3(0, 0.92, 0)
		sb.add_child(cs)
		stone.add_child(sb)


func _build_d3_apprentice_npc() -> void:
	## Epic-3 T54: an apprentice child NPC — smaller body, eager bouncing
	## animation, and a small floating practice rune sphere they're trying
	## to learn to control.
	var slots: Node3D = get_node_or_null("%NPCSlots") as Node3D
	if slots == null:
		return
	var app: Node3D = Node3D.new()
	app.name = "D3Apprentice"
	app.position = D3_CENTER + Vector3(-3, 0, 12)
	slots.add_child(app)
	# Smaller body
	var bmat: StandardMaterial3D = StandardMaterial3D.new()
	bmat.albedo_color = Color(0.30, 0.20, 0.40)
	bmat.metallic = 0.20
	bmat.roughness = 0.55
	bmat.emission_enabled = true
	bmat.emission = Color(0.55, 0.30, 0.85)
	bmat.emission_energy_multiplier = 0.40
	var body: MeshInstance3D = MeshInstance3D.new()
	var bmesh: CapsuleMesh = CapsuleMesh.new()
	bmesh.radius = 0.30
	bmesh.height = 0.85
	body.mesh = bmesh
	body.position = Vector3(0, 0.50, 0)
	body.material_override = bmat
	app.add_child(body)
	# Small head
	var head: MeshInstance3D = MeshInstance3D.new()
	var hm: SphereMesh = SphereMesh.new()
	hm.radius = 0.28
	hm.height = 0.50
	head.mesh = hm
	head.position = Vector3(0, 1.10, 0)
	head.material_override = bmat
	app.add_child(head)
	# 2 large eager eyes
	var eye_mat: StandardMaterial3D = StandardMaterial3D.new()
	eye_mat.albedo_color = Color(0.55, 0.95, 1.0)
	eye_mat.emission_enabled = true
	eye_mat.emission = Color(0.55, 0.95, 1.0)
	eye_mat.emission_energy_multiplier = 2.6
	eye_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for ex: float in [-0.10, 0.10]:
		var eye: MeshInstance3D = MeshInstance3D.new()
		var em: SphereMesh = SphereMesh.new()
		em.radius = 0.08
		em.height = 0.16
		eye.mesh = em
		eye.position = Vector3(ex, 1.10, 0.22)
		eye.material_override = eye_mat
		app.add_child(eye)
	# Floating practice rune in front
	var rune: MeshInstance3D = MeshInstance3D.new()
	var rm: SphereMesh = SphereMesh.new()
	rm.radius = 0.18
	rm.height = 0.36
	rune.mesh = rm
	rune.position = Vector3(0, 0.85, 0.65)
	var rmat: StandardMaterial3D = StandardMaterial3D.new()
	rmat.albedo_color = Color(0.85, 0.40, 1.0)
	rmat.emission_enabled = true
	rmat.emission = Color(1.0, 0.55, 1.0)
	rmat.emission_energy_multiplier = 2.6
	rmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	rune.material_override = rmat
	app.add_child(rune)
	# Bounce body in place
	var bounce: Tween = create_tween().set_loops()
	bounce.tween_property(body, "position:y", 0.65, 0.5).set_ease(Tween.EASE_OUT)
	bounce.tween_property(body, "position:y", 0.50, 0.4).set_ease(Tween.EASE_IN)
	bounce.tween_interval(0.8)
	# Wobble the rune
	var wobble: Tween = create_tween().set_loops()
	wobble.tween_property(rune, "position:x", 0.20, 0.5).set_ease(Tween.EASE_IN_OUT)
	wobble.tween_property(rune, "position:x", -0.20, 0.5).set_ease(Tween.EASE_IN_OUT)
	wobble.tween_property(rune, "position:x", 0.0, 0.5).set_ease(Tween.EASE_IN_OUT)
	# Name billboard
	var label: Label3D = Label3D.new()
	label.text = "Apprentice"
	label.position = Vector3(0, 1.65, 0)
	label.modulate = Color(0.55, 0.95, 1.0)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 16
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	app.add_child(label)


func _build_d3_page_rain(geom: Node) -> void:
	## Epic-3 T55: ambient floating page rain — 80 small translucent
	## amber page particles drifting down across the entire district like
	## paper leaves.
	var rain: GPUParticles3D = GPUParticles3D.new()
	rain.name = "D3PageRain"
	rain.position = D3_CENTER + Vector3(0, 14, 0)
	rain.amount = 80
	rain.lifetime = 8.0
	rain.preprocess = 4.0
	var pmat: ParticleProcessMaterial = ParticleProcessMaterial.new()
	pmat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	pmat.emission_box_extents = Vector3(28, 0.5, 18)
	pmat.direction = Vector3(0, -1, 0)
	pmat.spread = 12.0
	pmat.initial_velocity_min = 0.45
	pmat.initial_velocity_max = 0.85
	pmat.gravity = Vector3(0, -0.55, 0)
	pmat.scale_min = 0.20
	pmat.scale_max = 0.40
	pmat.color = Color(1.0, 0.85, 0.55, 0.55)
	rain.process_material = pmat
	var page: BoxMesh = BoxMesh.new()
	page.size = Vector3(0.30, 0.04, 0.40)
	var page_mat: StandardMaterial3D = StandardMaterial3D.new()
	page_mat.albedo_color = Color(1.0, 0.85, 0.55, 0.55)
	page_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	page_mat.emission_enabled = true
	page_mat.emission = Color(1.0, 0.85, 0.55)
	page_mat.emission_energy_multiplier = 0.85
	page_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	page.material = page_mat
	rain.draw_pass_1 = page
	geom.add_child(rain)


func _build_d3_alchemy_table(geom: Node) -> void:
	## Epic-3 T56: alchemy table with 5 colored potion bottles + glowing
	## crucible. Crowded with arcane experimentation gear.
	var alch: Node3D = Node3D.new()
	alch.name = "D3AlchemyTable"
	alch.position = D3_CENTER + Vector3(-12, 0, -3)
	geom.add_child(alch)
	# Wooden table
	var table_mat: StandardMaterial3D = StandardMaterial3D.new()
	table_mat.albedo_color = Color(0.30, 0.18, 0.10)
	table_mat.metallic = 0.10
	table_mat.roughness = 0.65
	var table: MeshInstance3D = MeshInstance3D.new()
	var tm: BoxMesh = BoxMesh.new()
	tm.size = Vector3(2.40, 0.95, 0.85)
	table.mesh = tm
	table.position = Vector3(0, 0.47, 0)
	table.material_override = table_mat
	alch.add_child(table)
	# 5 potion bottles in a row
	var potion_colors: Array[Color] = [
		Color(0.55, 0.95, 1.0),
		Color(1.0, 0.55, 0.20),
		Color(0.45, 1.0, 0.55),
		Color(1.0, 0.95, 0.30),
		Color(0.85, 0.40, 1.0),
	]
	for i in 5:
		var bottle: MeshInstance3D = MeshInstance3D.new()
		var bm: CylinderMesh = CylinderMesh.new()
		bm.top_radius = 0.10
		bm.bottom_radius = 0.14
		bm.height = 0.40
		bottle.mesh = bm
		bottle.position = Vector3(-0.85 + i * 0.40, 1.15, 0)
		var bmat: StandardMaterial3D = StandardMaterial3D.new()
		bmat.albedo_color = potion_colors[i]
		bmat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		bmat.albedo_color.a = 0.85
		bmat.emission_enabled = true
		bmat.emission = potion_colors[i]
		bmat.emission_energy_multiplier = 1.8
		bmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		bottle.material_override = bmat
		alch.add_child(bottle)
	# Glowing crucible at the side — small bowl
	var crucible: MeshInstance3D = MeshInstance3D.new()
	var cm: CylinderMesh = CylinderMesh.new()
	cm.top_radius = 0.30
	cm.bottom_radius = 0.18
	cm.height = 0.30
	crucible.mesh = cm
	crucible.position = Vector3(1.0, 1.10, 0)
	var cmat: StandardMaterial3D = StandardMaterial3D.new()
	cmat.albedo_color = Color(0.10, 0.10, 0.13)
	cmat.metallic = 0.85
	cmat.emission_enabled = true
	cmat.emission = Color(1.0, 0.55, 1.0)
	cmat.emission_energy_multiplier = 1.4
	crucible.material_override = cmat
	alch.add_child(crucible)
	# Pulsing flame inside the crucible
	var flame: MeshInstance3D = MeshInstance3D.new()
	var fmesh: SphereMesh = SphereMesh.new()
	fmesh.radius = 0.15
	fmesh.height = 0.30
	flame.mesh = fmesh
	flame.position = Vector3(1.0, 1.30, 0)
	var fmat: StandardMaterial3D = StandardMaterial3D.new()
	fmat.albedo_color = Color(1.0, 0.55, 1.0)
	fmat.emission_enabled = true
	fmat.emission = Color(1.0, 0.55, 1.0)
	fmat.emission_energy_multiplier = 3.0
	fmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	flame.material_override = fmat
	alch.add_child(flame)
	var pulse: Tween = create_tween().set_loops()
	pulse.tween_property(flame, "scale", Vector3(1.30, 1.30, 1.30), 0.6).set_ease(Tween.EASE_IN_OUT)
	pulse.tween_property(flame, "scale", Vector3(0.85, 0.85, 0.85), 0.6).set_ease(Tween.EASE_IN_OUT)
	# Sign
	var label: Label3D = Label3D.new()
	label.text = "ALCHEMY"
	label.position = Vector3(0, 2.0, 0)
	label.modulate = Color(0.85, 0.55, 1.0)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 16
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	alch.add_child(label)
	# Collision around table
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(2.40, 1.40, 0.85)
	cs.shape = cb
	cs.position = Vector3(0, 0.70, 0)
	sb.add_child(cs)
	alch.add_child(sb)


func _build_d3_sundial(geom: Node) -> void:
	## Epic-3 T57: ancient sundial — flat circular stone disc with a tall
	## angled gnomon casting a virtual shadow across 12 hour markers.
	var dial: Node3D = Node3D.new()
	dial.name = "D3Sundial"
	dial.position = D3_CENTER + Vector3(-15, 0, 4)
	geom.add_child(dial)
	# Flat disc base
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.30, 0.20, 0.40)
	stone_mat.metallic = 0.40
	stone_mat.roughness = 0.55
	stone_mat.emission_enabled = true
	stone_mat.emission = Color(0.85, 0.40, 1.0)
	stone_mat.emission_energy_multiplier = 0.30
	var disc: MeshInstance3D = MeshInstance3D.new()
	var dm: CylinderMesh = CylinderMesh.new()
	dm.top_radius = 1.85
	dm.bottom_radius = 1.85
	dm.height = 0.20
	disc.mesh = dm
	disc.position = Vector3(0, 0.10, 0)
	disc.material_override = stone_mat
	dial.add_child(disc)
	# Angled gnomon — tall thin prism
	var gnomon: MeshInstance3D = MeshInstance3D.new()
	var gm: PrismMesh = PrismMesh.new()
	gm.size = Vector3(0.20, 1.85, 1.40)
	gnomon.mesh = gm
	gnomon.position = Vector3(0, 1.10, 0)
	gnomon.material_override = stone_mat
	dial.add_child(gnomon)
	# 12 hour markers around the rim — small emissive dots
	var marker_mat: StandardMaterial3D = StandardMaterial3D.new()
	marker_mat.albedo_color = Color(0.85, 0.40, 1.0)
	marker_mat.emission_enabled = true
	marker_mat.emission = Color(1.0, 0.55, 1.0)
	marker_mat.emission_energy_multiplier = 2.4
	marker_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for i in 12:
		var angle: float = (float(i) / 12.0) * TAU
		var marker: MeshInstance3D = MeshInstance3D.new()
		var mm: SphereMesh = SphereMesh.new()
		mm.radius = 0.10
		mm.height = 0.20
		marker.mesh = mm
		marker.position = Vector3(cos(angle) * 1.55, 0.25, sin(angle) * 1.55)
		marker.material_override = marker_mat
		dial.add_child(marker)
	# Sign
	var label: Label3D = Label3D.new()
	label.text = "SUNDIAL"
	label.position = Vector3(0, 2.55, 0)
	label.modulate = Color(1.0, 0.55, 1.0)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 16
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	dial.add_child(label)
	# Collision
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(3.85, 0.40, 3.85)
	cs.shape = cb
	cs.position = Vector3(0, 0.20, 0)
	sb.add_child(cs)
	dial.add_child(sb)


func _build_d3_library_facade(geom: Node) -> void:
	## Epic-3 T58: a grand library facade — wide tall building front with
	## 4 columns + lintel + tall pointed pediment + glowing entryway.
	var lib: Node3D = Node3D.new()
	lib.name = "D3LibraryFacade"
	lib.position = D3_CENTER + Vector3(0, 0, 18)
	geom.add_child(lib)
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.20, 0.16, 0.26)
	stone_mat.metallic = 0.40
	stone_mat.roughness = 0.55
	stone_mat.emission_enabled = true
	stone_mat.emission = Color(0.85, 0.40, 1.0)
	stone_mat.emission_energy_multiplier = 0.30
	# 4 wide column pillars
	for ox: float in [-3.0, -1.0, 1.0, 3.0]:
		var col: MeshInstance3D = MeshInstance3D.new()
		var cm: CylinderMesh = CylinderMesh.new()
		cm.top_radius = 0.30
		cm.bottom_radius = 0.40
		cm.height = 4.85
		col.mesh = cm
		col.position = Vector3(ox, 2.42, 0)
		col.material_override = stone_mat
		lib.add_child(col)
		# Per-column collision
		var sb: StaticBody3D = StaticBody3D.new()
		var cs: CollisionShape3D = CollisionShape3D.new()
		var cap: CapsuleShape3D = CapsuleShape3D.new()
		cap.radius = 0.40
		cap.height = 4.85
		cs.shape = cap
		cs.position = Vector3(ox, 2.42, 0)
		sb.add_child(cs)
		lib.add_child(sb)
	# Wide flat lintel on top of columns
	var lintel: MeshInstance3D = MeshInstance3D.new()
	var lm: BoxMesh = BoxMesh.new()
	lm.size = Vector3(7.5, 0.85, 1.40)
	lintel.mesh = lm
	lintel.position = Vector3(0, 5.30, 0)
	lintel.material_override = stone_mat
	lib.add_child(lintel)
	# Tall pointed pediment (prism)
	var pediment: MeshInstance3D = MeshInstance3D.new()
	var pm: PrismMesh = PrismMesh.new()
	pm.size = Vector3(7.5, 1.85, 1.40)
	pediment.mesh = pm
	pediment.position = Vector3(0, 6.65, 0)
	pediment.material_override = stone_mat
	lib.add_child(pediment)
	# Glowing entryway between the middle columns
	var entry: MeshInstance3D = MeshInstance3D.new()
	var em: BoxMesh = BoxMesh.new()
	em.size = Vector3(1.85, 3.40, 0.20)
	entry.mesh = em
	entry.position = Vector3(0, 1.70, 0.55)
	var emat: StandardMaterial3D = StandardMaterial3D.new()
	emat.albedo_color = Color(0.06, 0.04, 0.10)
	emat.emission_enabled = true
	emat.emission = Color(1.0, 0.55, 1.0)
	emat.emission_energy_multiplier = 1.4
	emat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	entry.material_override = emat
	lib.add_child(entry)
	# Glowing rune on pediment
	var rune: Label3D = Label3D.new()
	rune.text = "Φ"
	rune.position = Vector3(0, 6.85, 0.71)
	rune.modulate = Color(1.0, 0.55, 1.0)
	rune.outline_modulate = Color(0, 0, 0, 0.85)
	rune.outline_size = 5
	rune.font_size = 36
	rune.no_depth_test = true
	lib.add_child(rune)
	# Sign above
	var label: Label3D = Label3D.new()
	label.text = "GRAND LIBRARY"
	label.position = Vector3(0, 8.30, 0)
	label.modulate = Color(1.0, 0.55, 1.0)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 6
	label.font_size = 22
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	lib.add_child(label)


func _build_d3_starlight_projector(geom: Node) -> void:
	## Epic-3 T59: a starlight projector — small floor-mounted gem that
	## projects a circle of 24 small stars on the floor around it.
	var proj: Node3D = Node3D.new()
	proj.name = "D3StarlightProjector"
	proj.position = D3_CENTER + Vector3(12, 0.06, 18)
	geom.add_child(proj)
	# Center gem
	var gem: MeshInstance3D = MeshInstance3D.new()
	var gm: SphereMesh = SphereMesh.new()
	gm.radius = 0.30
	gm.height = 0.60
	gem.mesh = gm
	gem.position = Vector3(0, 0.30, 0)
	var gmat: StandardMaterial3D = StandardMaterial3D.new()
	gmat.albedo_color = Color(0.85, 0.40, 1.0)
	gmat.emission_enabled = true
	gmat.emission = Color(1.0, 0.55, 1.0)
	gmat.emission_energy_multiplier = 3.0
	gmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	gem.material_override = gmat
	proj.add_child(gem)
	# 24 floor stars in a ring
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 200
	var star_mat: StandardMaterial3D = StandardMaterial3D.new()
	star_mat.albedo_color = Color(1, 1, 1)
	star_mat.emission_enabled = true
	star_mat.emission = Color(1, 1, 1)
	star_mat.emission_energy_multiplier = 2.6
	star_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for i in 24:
		var angle: float = rng.randf() * TAU
		var dist: float = rng.randf_range(1.20, 4.0)
		var star: MeshInstance3D = MeshInstance3D.new()
		var sm: SphereMesh = SphereMesh.new()
		sm.radius = 0.06
		sm.height = 0.12
		star.mesh = sm
		star.position = Vector3(cos(angle) * dist, 0.04, sin(angle) * dist)
		star.material_override = star_mat
		proj.add_child(star)
		# Twinkle
		var twk: Tween = create_tween().set_loops()
		twk.tween_property(star, "scale", Vector3(0.4, 0.4, 0.4), 0.6 + rng.randf() * 0.4).set_ease(Tween.EASE_IN_OUT)
		twk.tween_property(star, "scale", Vector3(1.4, 1.4, 1.4), 0.6 + rng.randf() * 0.4).set_ease(Tween.EASE_IN_OUT)


func _build_d3_data_dragon(geom: Node) -> void:
	## Epic-3 T60: a floating data dragon — long serpentine body made of
	## 8 connected emissive cube segments that drift in a sinuous pattern.
	var dragon: Node3D = Node3D.new()
	dragon.name = "D3DataDragon"
	dragon.position = D3_CENTER + Vector3(0, 6, -12)
	geom.add_child(dragon)
	# 8 body segments in a chain
	var dragon_mat: StandardMaterial3D = StandardMaterial3D.new()
	dragon_mat.albedo_color = Color(0.30, 0.85, 1.0)
	dragon_mat.emission_enabled = true
	dragon_mat.emission = Color(0.55, 0.95, 1.0)
	dragon_mat.emission_energy_multiplier = 2.4
	dragon_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for i in 8:
		var seg: MeshInstance3D = MeshInstance3D.new()
		var sm: BoxMesh = BoxMesh.new()
		sm.size = Vector3(0.65 - i * 0.04, 0.65 - i * 0.04, 0.65 - i * 0.04)
		seg.mesh = sm
		seg.position = Vector3(-i * 0.85, sin(i * 0.5) * 0.40, 0)
		seg.material_override = dragon_mat
		dragon.add_child(seg)
	# Head — bigger box at index 0 already, add eyes
	var eye_mat: StandardMaterial3D = StandardMaterial3D.new()
	eye_mat.albedo_color = Color(1, 1, 1)
	eye_mat.emission_enabled = true
	eye_mat.emission = Color(1, 1, 1)
	eye_mat.emission_energy_multiplier = 3.4
	eye_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for ex: float in [-0.18, 0.18]:
		var eye: MeshInstance3D = MeshInstance3D.new()
		var em: SphereMesh = SphereMesh.new()
		em.radius = 0.08
		em.height = 0.16
		eye.mesh = em
		eye.position = Vector3(0, 0.15, 0.34) + Vector3(ex, 0, 0)
		eye.material_override = eye_mat
		dragon.add_child(eye)
	# Slow patrol path circling overhead
	var origin: Vector3 = D3_CENTER + Vector3(0, 6, -12)
	var patrol: Tween = create_tween().set_loops()
	patrol.tween_property(dragon, "position", origin + Vector3(8, 1.5, 0), 8.0).set_ease(Tween.EASE_IN_OUT)
	patrol.tween_property(dragon, "position", origin + Vector3(0, 1.5, 8), 8.0).set_ease(Tween.EASE_IN_OUT)
	patrol.tween_property(dragon, "position", origin + Vector3(-8, 1.5, 0), 8.0).set_ease(Tween.EASE_IN_OUT)
	patrol.tween_property(dragon, "position", origin, 8.0).set_ease(Tween.EASE_IN_OUT)
	# Slow rotation
	var spin: Tween = create_tween().set_loops()
	spin.tween_property(dragon, "rotation:y", TAU, 32.0)
	# Boss-tier name billboard
	var label: Label3D = Label3D.new()
	label.text = "DATA DRAGON"
	label.position = Vector3(-3.5, 1.55, 0)
	label.modulate = Color(0.55, 0.95, 1.0)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 18
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	dragon.add_child(label)


func _build_d3_healing_fountain(geom: Node) -> void:
	## Epic-3 T61: a healing fountain — stone basin with rising green
	## emissive water column + 4 small healing pulse particles flowing
	## outward at the rim.
	var font: Node3D = Node3D.new()
	font.name = "D3HealingFountain"
	font.position = D3_CENTER + Vector3(20, 0, -8)
	geom.add_child(font)
	# Stone basin
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.16, 0.10, 0.20)
	stone_mat.metallic = 0.55
	stone_mat.roughness = 0.45
	var basin: MeshInstance3D = MeshInstance3D.new()
	var bm: CylinderMesh = CylinderMesh.new()
	bm.top_radius = 1.20
	bm.bottom_radius = 1.40
	bm.height = 0.85
	basin.mesh = bm
	basin.position = Vector3(0, 0.42, 0)
	basin.material_override = stone_mat
	font.add_child(basin)
	# Inner glowing green water disc
	var water: MeshInstance3D = MeshInstance3D.new()
	var wm: CylinderMesh = CylinderMesh.new()
	wm.top_radius = 1.0
	wm.bottom_radius = 1.0
	wm.height = 0.06
	water.mesh = wm
	water.position = Vector3(0, 0.85, 0)
	var wmat: StandardMaterial3D = StandardMaterial3D.new()
	wmat.albedo_color = Color(0.40, 1.0, 0.55, 0.85)
	wmat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	wmat.emission_enabled = true
	wmat.emission = Color(0.45, 1.0, 0.55)
	wmat.emission_energy_multiplier = 1.8
	wmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	water.material_override = wmat
	font.add_child(water)
	# Rising water column — small cylinder + GPU particles
	var column: MeshInstance3D = MeshInstance3D.new()
	var cm: CylinderMesh = CylinderMesh.new()
	cm.top_radius = 0.18
	cm.bottom_radius = 0.18
	cm.height = 1.40
	column.mesh = cm
	column.position = Vector3(0, 1.55, 0)
	var cmat: StandardMaterial3D = StandardMaterial3D.new()
	cmat.albedo_color = Color(0.45, 1.0, 0.55, 0.65)
	cmat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	cmat.emission_enabled = true
	cmat.emission = Color(0.55, 1.0, 0.55)
	cmat.emission_energy_multiplier = 2.0
	cmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	column.material_override = cmat
	font.add_child(column)
	# Rising particles
	var sparks: GPUParticles3D = GPUParticles3D.new()
	sparks.amount = 30
	sparks.lifetime = 1.85
	sparks.position = Vector3(0, 1.0, 0)
	var pmat: ParticleProcessMaterial = ParticleProcessMaterial.new()
	pmat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	pmat.emission_sphere_radius = 0.20
	pmat.direction = Vector3(0, 1, 0)
	pmat.spread = 8.0
	pmat.initial_velocity_min = 1.4
	pmat.initial_velocity_max = 2.0
	pmat.gravity = Vector3(0, 0.0, 0)
	pmat.scale_min = 0.10
	pmat.scale_max = 0.18
	pmat.color = Color(0.55, 1.0, 0.55, 1.0)
	sparks.process_material = pmat
	var sm2: SphereMesh = SphereMesh.new()
	sm2.radius = 0.10
	sm2.height = 0.20
	var sm_mat: StandardMaterial3D = StandardMaterial3D.new()
	sm_mat.albedo_color = Color(0.55, 1.0, 0.55)
	sm_mat.emission_enabled = true
	sm_mat.emission = Color(0.55, 1.0, 0.55)
	sm_mat.emission_energy_multiplier = 2.6
	sm_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	sm2.material = sm_mat
	sparks.draw_pass_1 = sm2
	font.add_child(sparks)
	# Sign
	var label: Label3D = Label3D.new()
	label.text = "HEALING FOUNT"
	label.position = Vector3(0, 2.85, 0)
	label.modulate = Color(0.55, 1.0, 0.55)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 16
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	font.add_child(label)
	# Collision around basin
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(2.85, 0.85, 2.85)
	cs.shape = cb
	cs.position = Vector3(0, 0.42, 0)
	sb.add_child(cs)
	font.add_child(sb)


func _build_d3_study_desks(geom: Node) -> void:
	## Epic-3 T62: 3 study desks in a row — wooden tables with stacked
	## books + small inkpot + an open scroll on each.
	var positions: Array[Vector3] = [
		D3_CENTER + Vector3(-18, 0, 8),
		D3_CENTER + Vector3(-18, 0, 11),
		D3_CENTER + Vector3(-18, 0, 14),
	]
	var wood_mat: StandardMaterial3D = StandardMaterial3D.new()
	wood_mat.albedo_color = Color(0.30, 0.18, 0.10)
	wood_mat.metallic = 0.10
	wood_mat.roughness = 0.65
	for i in positions.size():
		var desk: Node3D = Node3D.new()
		desk.name = "D3StudyDesk_%d" % i
		desk.position = positions[i]
		geom.add_child(desk)
		# Table
		var table: MeshInstance3D = MeshInstance3D.new()
		var tm: BoxMesh = BoxMesh.new()
		tm.size = Vector3(1.40, 0.85, 1.0)
		table.mesh = tm
		table.position = Vector3(0, 0.42, 0)
		table.material_override = wood_mat
		desk.add_child(table)
		# Stack of books
		for b in 3:
			var book: MeshInstance3D = MeshInstance3D.new()
			var bm: BoxMesh = BoxMesh.new()
			bm.size = Vector3(0.55, 0.10, 0.40)
			book.mesh = bm
			book.position = Vector3(-0.40, 0.95 + b * 0.10, 0)
			var bmat: StandardMaterial3D = StandardMaterial3D.new()
			bmat.albedo_color = [Color(0.55, 0.30, 0.30), Color(0.30, 0.55, 0.30), Color(0.30, 0.30, 0.55)][b]
			book.material_override = bmat
			desk.add_child(book)
		# Small inkpot
		var ink: MeshInstance3D = MeshInstance3D.new()
		var im: CylinderMesh = CylinderMesh.new()
		im.top_radius = 0.06
		im.bottom_radius = 0.08
		im.height = 0.18
		ink.mesh = im
		ink.position = Vector3(0.40, 0.94, 0)
		var imat: StandardMaterial3D = StandardMaterial3D.new()
		imat.albedo_color = Color(0.10, 0.10, 0.13)
		imat.metallic = 0.85
		ink.material_override = imat
		desk.add_child(ink)
		# Open glowing scroll
		var scroll: MeshInstance3D = MeshInstance3D.new()
		var sm: BoxMesh = BoxMesh.new()
		sm.size = Vector3(0.55, 0.04, 0.40)
		scroll.mesh = sm
		scroll.position = Vector3(0, 0.87, 0)
		var smat: StandardMaterial3D = StandardMaterial3D.new()
		smat.albedo_color = Color(0.95, 0.85, 0.55)
		smat.emission_enabled = true
		smat.emission = Color(1.0, 0.85, 0.55)
		smat.emission_energy_multiplier = 0.85
		smat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		scroll.material_override = smat
		desk.add_child(scroll)
		# Per-desk collision
		var sb: StaticBody3D = StaticBody3D.new()
		var cs: CollisionShape3D = CollisionShape3D.new()
		var cb: BoxShape3D = BoxShape3D.new()
		cb.size = Vector3(1.40, 0.85, 1.0)
		cs.shape = cb
		cs.position = Vector3(0, 0.42, 0)
		sb.add_child(cs)
		desk.add_child(sb)


func _build_d3_mage_robes(geom: Node) -> void:
	## Epic-3 T63: a coat rack with 3 hanging mage robes in different
	## colors — boxes with conical hat tops.
	var rack: Node3D = Node3D.new()
	rack.name = "D3MageRobes"
	rack.position = D3_CENTER + Vector3(-15, 0, -3)
	geom.add_child(rack)
	# Wooden post
	var post_mat: StandardMaterial3D = StandardMaterial3D.new()
	post_mat.albedo_color = Color(0.30, 0.18, 0.10)
	post_mat.metallic = 0.10
	post_mat.roughness = 0.65
	var post: MeshInstance3D = MeshInstance3D.new()
	var pmesh: CylinderMesh = CylinderMesh.new()
	pmesh.top_radius = 0.07
	pmesh.bottom_radius = 0.10
	pmesh.height = 2.40
	post.mesh = pmesh
	post.position = Vector3(0, 1.20, 0)
	post.material_override = post_mat
	rack.add_child(post)
	# Top crossbar
	var bar: MeshInstance3D = MeshInstance3D.new()
	var bm: BoxMesh = BoxMesh.new()
	bm.size = Vector3(2.0, 0.06, 0.06)
	bar.mesh = bm
	bar.position = Vector3(0, 2.20, 0)
	bar.material_override = post_mat
	rack.add_child(bar)
	# 3 hanging robes
	var robe_colors: Array[Color] = [
		Color(0.55, 0.30, 0.85),
		Color(0.30, 0.55, 0.85),
		Color(0.85, 0.30, 0.55),
	]
	for i in 3:
		var hx: float = -0.65 + i * 0.65
		# Robe body — narrow box
		var robe: MeshInstance3D = MeshInstance3D.new()
		var rm: BoxMesh = BoxMesh.new()
		rm.size = Vector3(0.55, 1.40, 0.18)
		robe.mesh = rm
		robe.position = Vector3(hx, 1.40, 0)
		var rmat: StandardMaterial3D = StandardMaterial3D.new()
		rmat.albedo_color = robe_colors[i]
		rmat.emission_enabled = true
		rmat.emission = robe_colors[i]
		rmat.emission_energy_multiplier = 0.55
		rmat.metallic = 0.20
		rmat.roughness = 0.55
		robe.material_override = rmat
		rack.add_child(robe)
		# Conical hat on top
		var hat: MeshInstance3D = MeshInstance3D.new()
		var hm: PrismMesh = PrismMesh.new()
		hm.size = Vector3(0.40, 0.55, 0.40)
		hat.mesh = hm
		hat.position = Vector3(hx, 2.40, 0)
		hat.material_override = rmat
		rack.add_child(hat)
	# Sign
	var label: Label3D = Label3D.new()
	label.text = "ROBES"
	label.position = Vector3(0, 3.0, 0)
	label.modulate = Color(0.85, 0.55, 1.0)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 14
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	rack.add_child(label)
	# Collision
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(2.20, 2.40, 0.30)
	cs.shape = cb
	cs.position = Vector3(0, 1.20, 0)
	sb.add_child(cs)
	rack.add_child(sb)


func _build_d3_fortune_teller_npc() -> void:
	## Epic-3 T64: Fortune Teller NPC sitting at a small round table with
	## a glowing crystal ball in front. Has a scarf wrapped around the head.
	var slots: Node3D = get_node_or_null("%NPCSlots") as Node3D
	if slots == null:
		return
	var teller: Node3D = Node3D.new()
	teller.name = "D3FortuneTeller"
	teller.position = D3_CENTER + Vector3(-12, 0, -8)
	slots.add_child(teller)
	# Round table
	var table_mat: StandardMaterial3D = StandardMaterial3D.new()
	table_mat.albedo_color = Color(0.30, 0.18, 0.10)
	table_mat.metallic = 0.10
	table_mat.roughness = 0.65
	var table: MeshInstance3D = MeshInstance3D.new()
	var tm: CylinderMesh = CylinderMesh.new()
	tm.top_radius = 0.55
	tm.bottom_radius = 0.55
	tm.height = 0.85
	table.mesh = tm
	table.position = Vector3(0, 0.42, 0.85)
	table.material_override = table_mat
	teller.add_child(table)
	# Crystal ball on the table
	var ball: MeshInstance3D = MeshInstance3D.new()
	var bm: SphereMesh = SphereMesh.new()
	bm.radius = 0.20
	bm.height = 0.40
	ball.mesh = bm
	ball.position = Vector3(0, 1.0, 0.85)
	var bmat: StandardMaterial3D = StandardMaterial3D.new()
	bmat.albedo_color = Color(0.85, 0.55, 1.0, 0.55)
	bmat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	bmat.emission_enabled = true
	bmat.emission = Color(1.0, 0.55, 1.0)
	bmat.emission_energy_multiplier = 2.6
	bmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	ball.material_override = bmat
	teller.add_child(ball)
	# Body — short capsule (sitting)
	var bbmat: StandardMaterial3D = StandardMaterial3D.new()
	bbmat.albedo_color = Color(0.30, 0.10, 0.30)
	bbmat.metallic = 0.20
	bbmat.roughness = 0.65
	bbmat.emission_enabled = true
	bbmat.emission = Color(1.0, 0.30, 0.65)
	bbmat.emission_energy_multiplier = 0.40
	var body: MeshInstance3D = MeshInstance3D.new()
	var bmesh: CapsuleMesh = CapsuleMesh.new()
	bmesh.radius = 0.40
	bmesh.height = 0.85
	body.mesh = bmesh
	body.position = Vector3(0, 0.45, 0)
	body.material_override = bbmat
	teller.add_child(body)
	# Wrapped scarf head — sphere
	var head: MeshInstance3D = MeshInstance3D.new()
	var hm: SphereMesh = SphereMesh.new()
	hm.radius = 0.36
	hm.height = 0.65
	head.mesh = hm
	head.position = Vector3(0, 1.0, 0)
	var hmat: StandardMaterial3D = StandardMaterial3D.new()
	hmat.albedo_color = Color(0.85, 0.30, 0.65)
	hmat.metallic = 0.20
	hmat.roughness = 0.65
	hmat.emission_enabled = true
	hmat.emission = Color(1.0, 0.40, 0.65)
	hmat.emission_energy_multiplier = 0.55
	head.material_override = hmat
	teller.add_child(head)
	# 2 small white eyes
	var eye_mat: StandardMaterial3D = StandardMaterial3D.new()
	eye_mat.albedo_color = Color(1, 1, 1)
	eye_mat.emission_enabled = true
	eye_mat.emission = Color(1, 1, 1)
	eye_mat.emission_energy_multiplier = 2.6
	eye_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for ex: float in [-0.10, 0.10]:
		var eye: MeshInstance3D = MeshInstance3D.new()
		var em: SphereMesh = SphereMesh.new()
		em.radius = 0.05
		em.height = 0.10
		eye.mesh = em
		eye.position = Vector3(ex, 1.0, 0.32)
		eye.material_override = eye_mat
		teller.add_child(eye)
	# Pulse the ball
	var pulse: Tween = create_tween().set_loops()
	pulse.tween_property(ball, "scale", Vector3(1.30, 1.30, 1.30), 1.4).set_ease(Tween.EASE_IN_OUT)
	pulse.tween_property(ball, "scale", Vector3(0.85, 0.85, 0.85), 1.4).set_ease(Tween.EASE_IN_OUT)
	# Name billboard
	var label: Label3D = Label3D.new()
	label.text = "Fortune Teller"
	label.position = Vector3(0, 1.85, 0)
	label.modulate = Color(1.0, 0.55, 0.85)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 18
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	teller.add_child(label)


func _build_d3_tarot_cards(geom: Node) -> void:
	## Epic-3 T65: 6 floating tarot cards near the fortune teller — small
	## rectangles in different colors with floating animation.
	var positions: Array[Vector3] = [
		D3_CENTER + Vector3(-13, 1.5, -6),
		D3_CENTER + Vector3(-12, 1.8, -6),
		D3_CENTER + Vector3(-11, 1.5, -6),
		D3_CENTER + Vector3(-13, 2.4, -7),
		D3_CENTER + Vector3(-12, 2.7, -7),
		D3_CENTER + Vector3(-11, 2.4, -7),
	]
	var card_colors: Array[Color] = [
		Color(0.55, 0.95, 1.0),
		Color(1.0, 0.55, 0.20),
		Color(0.45, 1.0, 0.55),
		Color(0.85, 0.40, 1.0),
		Color(1.0, 0.95, 0.30),
		Color(1.0, 0.30, 0.55),
	]
	for i in positions.size():
		var card: MeshInstance3D = MeshInstance3D.new()
		card.name = "D3TarotCard_%d" % i
		var cmesh: BoxMesh = BoxMesh.new()
		cmesh.size = Vector3(0.30, 0.55, 0.04)
		card.mesh = cmesh
		card.position = positions[i]
		var cmat: StandardMaterial3D = StandardMaterial3D.new()
		cmat.albedo_color = card_colors[i]
		cmat.emission_enabled = true
		cmat.emission = card_colors[i]
		cmat.emission_energy_multiplier = 1.6
		cmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		card.material_override = cmat
		geom.add_child(card)
		# Bob and slow rotation
		var bob: Tween = create_tween().set_loops()
		var origin_y: float = positions[i].y
		bob.tween_property(card, "position:y", origin_y + 0.30, 1.4 + i * 0.1).set_ease(Tween.EASE_IN_OUT)
		bob.tween_property(card, "position:y", origin_y, 1.4 + i * 0.1).set_ease(Tween.EASE_IN_OUT)
		var spin: Tween = create_tween().set_loops()
		spin.tween_property(card, "rotation:y", TAU, 5.0 + i * 0.5)


func _build_d3_sky_chimes(geom: Node) -> void:
	## Epic-3 T66: 5 hanging sky chimes — long thin metal cylinders
	## hanging from a horizontal bar between 2 tall poles, swinging
	## gently as if in a breeze.
	var chimes: Node3D = Node3D.new()
	chimes.name = "D3SkyChimes"
	chimes.position = D3_CENTER + Vector3(15, 0, 4)
	geom.add_child(chimes)
	# 2 tall poles
	var pole_mat: StandardMaterial3D = StandardMaterial3D.new()
	pole_mat.albedo_color = Color(0.10, 0.06, 0.18)
	pole_mat.metallic = 0.55
	pole_mat.roughness = 0.45
	for sx: float in [-1.40, 1.40]:
		var pole: MeshInstance3D = MeshInstance3D.new()
		var pmesh: CylinderMesh = CylinderMesh.new()
		pmesh.top_radius = 0.07
		pmesh.bottom_radius = 0.10
		pmesh.height = 3.40
		pole.mesh = pmesh
		pole.position = Vector3(sx, 1.70, 0)
		pole.material_override = pole_mat
		chimes.add_child(pole)
		# Collision per pole
		var sb: StaticBody3D = StaticBody3D.new()
		var cs: CollisionShape3D = CollisionShape3D.new()
		var cap: CapsuleShape3D = CapsuleShape3D.new()
		cap.radius = 0.20
		cap.height = 3.40
		cs.shape = cap
		cs.position = Vector3(sx, 1.70, 0)
		sb.add_child(cs)
		chimes.add_child(sb)
	# Top bar
	var bar: MeshInstance3D = MeshInstance3D.new()
	var bm: BoxMesh = BoxMesh.new()
	bm.size = Vector3(3.0, 0.10, 0.10)
	bar.mesh = bm
	bar.position = Vector3(0, 3.40, 0)
	bar.material_override = pole_mat
	chimes.add_child(bar)
	# 5 hanging chimes pivoted from the bar
	var chime_mat: StandardMaterial3D = StandardMaterial3D.new()
	chime_mat.albedo_color = Color(0.85, 0.85, 0.95)
	chime_mat.metallic = 0.85
	chime_mat.roughness = 0.20
	chime_mat.emission_enabled = true
	chime_mat.emission = Color(0.55, 0.95, 1.0)
	chime_mat.emission_energy_multiplier = 0.85
	for i in 5:
		var pivot: Node3D = Node3D.new()
		pivot.position = Vector3(-1.10 + i * 0.55, 3.40, 0)
		chimes.add_child(pivot)
		var chime: MeshInstance3D = MeshInstance3D.new()
		var cmesh: CylinderMesh = CylinderMesh.new()
		cmesh.top_radius = 0.06
		cmesh.bottom_radius = 0.06
		cmesh.height = 0.85 + i * 0.10
		chime.mesh = cmesh
		chime.position = Vector3(0, -(0.85 + i * 0.10) * 0.5, 0)
		chime.material_override = chime_mat
		pivot.add_child(chime)
		# Sway tween
		var sway: Tween = create_tween().set_loops()
		sway.tween_property(pivot, "rotation:x", deg_to_rad(8 + i * 2), 0.85 + i * 0.1).set_ease(Tween.EASE_IN_OUT)
		sway.tween_property(pivot, "rotation:x", deg_to_rad(-8 - i * 2), 0.85 + i * 0.1).set_ease(Tween.EASE_IN_OUT)


func _build_d3_spirit_altars(geom: Node) -> void:
	## Epic-3 T67: 3 small spirit altars in a row — stone pedestals each
	## with a glowing offering bowl on top + flame.
	var positions: Array[Vector3] = [
		D3_CENTER + Vector3(15, 0, -3),
		D3_CENTER + Vector3(15, 0, 0),
		D3_CENTER + Vector3(15, 0, 3),
	]
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.16, 0.10, 0.20)
	stone_mat.metallic = 0.55
	stone_mat.roughness = 0.45
	var flame_mat: StandardMaterial3D = StandardMaterial3D.new()
	flame_mat.albedo_color = Color(0.85, 0.40, 1.0)
	flame_mat.emission_enabled = true
	flame_mat.emission = Color(1.0, 0.55, 1.0)
	flame_mat.emission_energy_multiplier = 2.6
	flame_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for i in positions.size():
		var altar: Node3D = Node3D.new()
		altar.name = "D3SpiritAltar_%d" % i
		altar.position = positions[i]
		geom.add_child(altar)
		# Pedestal
		var ped: MeshInstance3D = MeshInstance3D.new()
		var pm: BoxMesh = BoxMesh.new()
		pm.size = Vector3(0.85, 1.0, 0.85)
		ped.mesh = pm
		ped.position = Vector3(0, 0.50, 0)
		ped.material_override = stone_mat
		altar.add_child(ped)
		# Bowl on top
		var bowl: MeshInstance3D = MeshInstance3D.new()
		var bm: CylinderMesh = CylinderMesh.new()
		bm.top_radius = 0.30
		bm.bottom_radius = 0.18
		bm.height = 0.20
		bowl.mesh = bm
		bowl.position = Vector3(0, 1.10, 0)
		bowl.material_override = stone_mat
		altar.add_child(bowl)
		# Flame inside
		var flame: MeshInstance3D = MeshInstance3D.new()
		var fmesh: SphereMesh = SphereMesh.new()
		fmesh.radius = 0.18
		fmesh.height = 0.36
		flame.mesh = fmesh
		flame.position = Vector3(0, 1.30, 0)
		flame.material_override = flame_mat
		altar.add_child(flame)
		# Pulse the flame
		var pulse: Tween = create_tween().set_loops()
		pulse.tween_property(flame, "scale", Vector3(1.30, 1.30, 1.30), 0.6 + i * 0.1).set_ease(Tween.EASE_IN_OUT)
		pulse.tween_property(flame, "scale", Vector3(0.85, 0.85, 0.85), 0.6 + i * 0.1).set_ease(Tween.EASE_IN_OUT)
		# Per-altar collision
		var sb: StaticBody3D = StaticBody3D.new()
		var cs: CollisionShape3D = CollisionShape3D.new()
		var cb: BoxShape3D = BoxShape3D.new()
		cb.size = Vector3(0.85, 1.0, 0.85)
		cs.shape = cb
		cs.position = Vector3(0, 0.50, 0)
		sb.add_child(cs)
		altar.add_child(sb)


func _build_d3_floating_crown(geom: Node) -> void:
	## Epic-3 T68: a massive floating crown landmark — large 5-pronged
	## golden crown ring suspended above the judgment dais.
	var crown: Node3D = Node3D.new()
	crown.name = "D3FloatingCrown"
	crown.position = D3_CENTER + Vector3(-15, 6, 14)
	geom.add_child(crown)
	# Crown band — torus
	var band: MeshInstance3D = MeshInstance3D.new()
	var bm: TorusMesh = TorusMesh.new()
	bm.inner_radius = 1.20
	bm.outer_radius = 1.40
	band.mesh = bm
	var bmat: StandardMaterial3D = StandardMaterial3D.new()
	bmat.albedo_color = Color(1.0, 0.85, 0.30)
	bmat.metallic = 0.85
	bmat.roughness = 0.20
	bmat.emission_enabled = true
	bmat.emission = Color(1.0, 0.95, 0.30)
	bmat.emission_energy_multiplier = 1.8
	band.material_override = bmat
	crown.add_child(band)
	# 5 vertical prongs around the band
	for i in 5:
		var angle: float = (float(i) / 5.0) * TAU
		var prong: MeshInstance3D = MeshInstance3D.new()
		var pm: PrismMesh = PrismMesh.new()
		pm.size = Vector3(0.20, 0.85, 0.20)
		prong.mesh = pm
		prong.position = Vector3(cos(angle) * 1.30, 0.55, sin(angle) * 1.30)
		prong.material_override = bmat
		crown.add_child(prong)
		# Tip gem at top of each prong
		var gem: MeshInstance3D = MeshInstance3D.new()
		var gm: SphereMesh = SphereMesh.new()
		gm.radius = 0.12
		gm.height = 0.24
		gem.mesh = gm
		gem.position = Vector3(cos(angle) * 1.30, 0.95, sin(angle) * 1.30)
		var gmat: StandardMaterial3D = StandardMaterial3D.new()
		gmat.albedo_color = Color(0.85, 0.40, 1.0)
		gmat.emission_enabled = true
		gmat.emission = Color(1.0, 0.55, 1.0)
		gmat.emission_energy_multiplier = 3.0
		gmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		gem.material_override = gmat
		crown.add_child(gem)
	# Slow rotation
	var spin: Tween = create_tween().set_loops()
	spin.tween_property(crown, "rotation:y", TAU, 12.0)
	# Bob in place
	var bob: Tween = create_tween().set_loops()
	bob.tween_property(crown, "position:y", 6.55, 2.4).set_ease(Tween.EASE_IN_OUT)
	bob.tween_property(crown, "position:y", 6.0, 2.4).set_ease(Tween.EASE_IN_OUT)


func _build_d3_grimoire_stack(geom: Node) -> void:
	## Epic-3 T69: a tall stack of 6 magical grimoires — colored book
	## boxes piled with the top one slightly open and glowing.
	var stack: Node3D = Node3D.new()
	stack.name = "D3GrimoireStack"
	stack.position = D3_CENTER + Vector3(-18, 0, 0)
	geom.add_child(stack)
	var book_colors: Array[Color] = [
		Color(0.55, 0.30, 0.30),
		Color(0.30, 0.55, 0.30),
		Color(0.30, 0.30, 0.55),
		Color(0.55, 0.55, 0.30),
		Color(0.55, 0.30, 0.55),
		Color(0.30, 0.55, 0.55),
	]
	for i in 6:
		var book: MeshInstance3D = MeshInstance3D.new()
		var bm: BoxMesh = BoxMesh.new()
		bm.size = Vector3(0.85, 0.18, 0.55)
		book.mesh = bm
		book.position = Vector3(randf_range(-0.10, 0.10), 0.10 + i * 0.20, randf_range(-0.10, 0.10))
		book.rotation = Vector3(0, deg_to_rad(randf_range(-15, 15)), 0)
		var bmat: StandardMaterial3D = StandardMaterial3D.new()
		bmat.albedo_color = book_colors[i]
		bmat.metallic = 0.10
		bmat.roughness = 0.65
		bmat.emission_enabled = true
		bmat.emission = book_colors[i]
		bmat.emission_energy_multiplier = 0.55
		book.material_override = bmat
		stack.add_child(book)
	# Top open book glowing
	var open_book: MeshInstance3D = MeshInstance3D.new()
	var obm: BoxMesh = BoxMesh.new()
	obm.size = Vector3(0.85, 0.10, 0.55)
	open_book.mesh = obm
	open_book.position = Vector3(0, 1.40, 0)
	var obmat: StandardMaterial3D = StandardMaterial3D.new()
	obmat.albedo_color = Color(0.95, 0.85, 0.55)
	obmat.emission_enabled = true
	obmat.emission = Color(1.0, 0.85, 0.55)
	obmat.emission_energy_multiplier = 1.4
	obmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	open_book.material_override = obmat
	stack.add_child(open_book)
	# Floating glowing rune above the open book
	var rune: MeshInstance3D = MeshInstance3D.new()
	var rm: PrismMesh = PrismMesh.new()
	rm.size = Vector3(0.20, 0.30, 0.20)
	rune.mesh = rm
	rune.position = Vector3(0, 1.85, 0)
	var rmat: StandardMaterial3D = StandardMaterial3D.new()
	rmat.albedo_color = Color(0.85, 0.40, 1.0)
	rmat.emission_enabled = true
	rmat.emission = Color(1.0, 0.55, 1.0)
	rmat.emission_energy_multiplier = 2.6
	rmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	rune.material_override = rmat
	stack.add_child(rune)
	# Bob the rune
	var bob: Tween = create_tween().set_loops()
	bob.tween_property(rune, "position:y", 2.10, 1.4).set_ease(Tween.EASE_IN_OUT)
	bob.tween_property(rune, "position:y", 1.85, 1.4).set_ease(Tween.EASE_IN_OUT)
	# Per-stack collision
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(0.95, 1.40, 0.65)
	cs.shape = cb
	cs.position = Vector3(0, 0.70, 0)
	sb.add_child(cs)
	stack.add_child(sb)


func _build_d3_monk_npc() -> void:
	## Epic-3 T70: a Monk NPC walking a circular path around the great
	## crystal — slow continuous patrol on a circle.
	var slots: Node3D = get_node_or_null("%NPCSlots") as Node3D
	if slots == null:
		return
	var monk: Node3D = Node3D.new()
	monk.name = "D3Monk"
	monk.position = D3_CENTER + Vector3(8, 0, 0)
	slots.add_child(monk)
	# Robed body
	var bmat: StandardMaterial3D = StandardMaterial3D.new()
	bmat.albedo_color = Color(0.30, 0.20, 0.10)
	bmat.metallic = 0.10
	bmat.roughness = 0.65
	bmat.emission_enabled = true
	bmat.emission = Color(0.85, 0.55, 0.20)
	bmat.emission_energy_multiplier = 0.30
	var body: MeshInstance3D = MeshInstance3D.new()
	var bmesh: CapsuleMesh = CapsuleMesh.new()
	bmesh.radius = 0.42
	bmesh.height = 1.30
	body.mesh = bmesh
	body.position = Vector3(0, 0.70, 0)
	body.material_override = bmat
	monk.add_child(body)
	# Wide hood
	var hood: MeshInstance3D = MeshInstance3D.new()
	var hm: SphereMesh = SphereMesh.new()
	hm.radius = 0.45
	hm.height = 0.55
	hood.mesh = hm
	hood.position = Vector3(0, 1.55, 0)
	hood.material_override = bmat
	monk.add_child(hood)
	# Bald head — small sphere visible from hood
	var head: MeshInstance3D = MeshInstance3D.new()
	var hmesh: SphereMesh = SphereMesh.new()
	hmesh.radius = 0.30
	hmesh.height = 0.55
	head.mesh = hmesh
	head.position = Vector3(0, 1.55, 0.10)
	var hmat: StandardMaterial3D = StandardMaterial3D.new()
	hmat.albedo_color = Color(0.85, 0.55, 0.30)
	hmat.metallic = 0.10
	hmat.roughness = 0.55
	head.material_override = hmat
	monk.add_child(head)
	# 2 closed eye dots (small black bars)
	var eye_mat: StandardMaterial3D = StandardMaterial3D.new()
	eye_mat.albedo_color = Color(0.05, 0.05, 0.10)
	eye_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for ex: float in [-0.08, 0.08]:
		var eye: MeshInstance3D = MeshInstance3D.new()
		var em: BoxMesh = BoxMesh.new()
		em.size = Vector3(0.06, 0.02, 0.04)
		eye.mesh = em
		eye.position = Vector3(ex, 1.58, 0.36)
		eye.material_override = eye_mat
		monk.add_child(eye)
	# Hands clasped in prayer in front (small sphere)
	var hands: MeshInstance3D = MeshInstance3D.new()
	var hands_mesh: SphereMesh = SphereMesh.new()
	hands_mesh.radius = 0.12
	hands_mesh.height = 0.24
	hands.mesh = hands_mesh
	hands.position = Vector3(0, 0.85, 0.45)
	hands.material_override = hmat
	monk.add_child(hands)
	# Walking circular path tween — 4 quarter-turns around the crystal
	var center: Vector3 = D3_CENTER
	var radius: float = 8.0
	var monk_path: Tween = create_tween().set_loops()
	for step in 8:
		var angle: float = (float(step) / 8.0) * TAU
		var target: Vector3 = center + Vector3(cos(angle) * radius, 0, sin(angle) * radius)
		monk_path.tween_property(monk, "position", target, 4.0).set_ease(Tween.EASE_IN_OUT)
		monk_path.tween_property(monk, "rotation:y", -angle, 0.3)
	# Name billboard
	var label: Label3D = Label3D.new()
	label.text = "Monk"
	label.position = Vector3(0, 2.20, 0)
	label.modulate = Color(1.0, 0.85, 0.55)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 18
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	monk.add_child(label)


func _build_d3_conjurer_npc() -> void:
	## Epic-3 T71: Conjurer NPC with a small familiar floating beside.
	## Wide-brimmed pointy hat, robe, and a small wisp creature orbiting.
	var slots: Node3D = get_node_or_null("%NPCSlots") as Node3D
	if slots == null:
		return
	var conj: Node3D = Node3D.new()
	conj.name = "D3Conjurer"
	conj.position = D3_CENTER + Vector3(-3, 0, -8)
	slots.add_child(conj)
	# Body
	var bmat: StandardMaterial3D = StandardMaterial3D.new()
	bmat.albedo_color = Color(0.30, 0.20, 0.40)
	bmat.metallic = 0.20
	bmat.roughness = 0.65
	bmat.emission_enabled = true
	bmat.emission = Color(0.55, 0.30, 0.85)
	bmat.emission_energy_multiplier = 0.40
	var body: MeshInstance3D = MeshInstance3D.new()
	var bmesh: CapsuleMesh = CapsuleMesh.new()
	bmesh.radius = 0.45
	bmesh.height = 1.40
	body.mesh = bmesh
	body.position = Vector3(0, 0.70, 0)
	body.material_override = bmat
	conj.add_child(body)
	# Wide-brim hat — flat torus + tall prism
	var brim: MeshInstance3D = MeshInstance3D.new()
	var brmesh: TorusMesh = TorusMesh.new()
	brmesh.inner_radius = 0.40
	brmesh.outer_radius = 0.65
	brim.mesh = brmesh
	brim.position = Vector3(0, 1.65, 0)
	brim.material_override = bmat
	conj.add_child(brim)
	var hat_top: MeshInstance3D = MeshInstance3D.new()
	var htm: PrismMesh = PrismMesh.new()
	htm.size = Vector3(0.55, 0.85, 0.55)
	hat_top.mesh = htm
	hat_top.position = Vector3(0, 2.10, 0)
	hat_top.material_override = bmat
	conj.add_child(hat_top)
	# 2 cyan eyes
	var eye_mat: StandardMaterial3D = StandardMaterial3D.new()
	eye_mat.albedo_color = Color(0.55, 0.95, 1.0)
	eye_mat.emission_enabled = true
	eye_mat.emission = Color(0.55, 0.95, 1.0)
	eye_mat.emission_energy_multiplier = 2.6
	eye_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for ex: float in [-0.10, 0.10]:
		var eye: MeshInstance3D = MeshInstance3D.new()
		var em: SphereMesh = SphereMesh.new()
		em.radius = 0.06
		em.height = 0.12
		eye.mesh = em
		eye.position = Vector3(ex, 1.40, 0.32)
		eye.material_override = eye_mat
		conj.add_child(eye)
	# Familiar — small wisp creature orbiting head
	var familiar_pivot: Node3D = Node3D.new()
	familiar_pivot.position = Vector3(0, 1.85, 0)
	conj.add_child(familiar_pivot)
	var familiar: MeshInstance3D = MeshInstance3D.new()
	var fm: SphereMesh = SphereMesh.new()
	fm.radius = 0.18
	fm.height = 0.36
	familiar.mesh = fm
	familiar.position = Vector3(0.85, 0, 0)
	var fmat: StandardMaterial3D = StandardMaterial3D.new()
	fmat.albedo_color = Color(0.55, 0.95, 1.0)
	fmat.emission_enabled = true
	fmat.emission = Color(0.55, 0.95, 1.0)
	fmat.emission_energy_multiplier = 3.0
	fmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	familiar.material_override = fmat
	familiar_pivot.add_child(familiar)
	# 2 small white eyes on the familiar
	for ex: float in [-0.06, 0.06]:
		var f_eye: MeshInstance3D = MeshInstance3D.new()
		var fem: SphereMesh = SphereMesh.new()
		fem.radius = 0.03
		fem.height = 0.06
		f_eye.mesh = fem
		f_eye.position = Vector3(0.85 + ex, 0.04, 0.18)
		var femat: StandardMaterial3D = StandardMaterial3D.new()
		femat.albedo_color = Color(1, 1, 1)
		femat.emission_enabled = true
		femat.emission = Color(1, 1, 1)
		femat.emission_energy_multiplier = 3.0
		femat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		f_eye.material_override = femat
		familiar_pivot.add_child(f_eye)
	# Orbit familiar
	var orbit: Tween = create_tween().set_loops()
	orbit.tween_property(familiar_pivot, "rotation:y", TAU, 4.0)
	# Name billboard
	var label: Label3D = Label3D.new()
	label.text = "Conjurer"
	label.position = Vector3(0, 3.0, 0)
	label.modulate = Color(0.85, 0.55, 1.0)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 18
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	conj.add_child(label)


func _build_d3_map_wall(geom: Node) -> void:
	## Epic-3 T72: ancient map wall — large flat wall covered with 6
	## colored map fragment boxes pinned in a grid pattern.
	var wall_root: Node3D = Node3D.new()
	wall_root.name = "D3MapWall"
	wall_root.position = D3_CENTER + Vector3(-22, 0, -2)
	geom.add_child(wall_root)
	# Wall slab
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.16, 0.10, 0.20)
	stone_mat.metallic = 0.55
	stone_mat.roughness = 0.45
	var wall: MeshInstance3D = MeshInstance3D.new()
	var wm: BoxMesh = BoxMesh.new()
	wm.size = Vector3(0.30, 4.0, 5.0)
	wall.mesh = wm
	wall.position = Vector3(0, 2.0, 0)
	wall.material_override = stone_mat
	wall_root.add_child(wall)
	# 6 map fragments in a 3x2 grid
	var map_colors: Array[Color] = [
		Color(0.55, 0.95, 1.0),
		Color(0.45, 1.0, 0.55),
		Color(1.0, 0.55, 0.20),
		Color(0.85, 0.40, 1.0),
		Color(1.0, 0.95, 0.30),
		Color(1.0, 0.30, 0.55),
	]
	for r in 2:
		for c in 3:
			var i: int = r * 3 + c
			var frag: MeshInstance3D = MeshInstance3D.new()
			var fm: BoxMesh = BoxMesh.new()
			fm.size = Vector3(0.10, 1.20, 1.20)
			frag.mesh = fm
			frag.position = Vector3(0.21, 1.30 + r * 1.40, -1.50 + c * 1.50)
			var fmat: StandardMaterial3D = StandardMaterial3D.new()
			fmat.albedo_color = map_colors[i]
			fmat.emission_enabled = true
			fmat.emission = map_colors[i]
			fmat.emission_energy_multiplier = 1.0
			fmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
			frag.material_override = fmat
			wall_root.add_child(frag)
	# Sign
	var label: Label3D = Label3D.new()
	label.text = "STAR MAPS"
	label.position = Vector3(0, 4.40, 0)
	label.modulate = Color(0.85, 0.55, 1.0)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 16
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	wall_root.add_child(label)
	# Collision
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(0.30, 4.0, 5.0)
	cs.shape = cb
	cs.position = Vector3(0, 2.0, 0)
	sb.add_child(cs)
	wall_root.add_child(sb)


func _build_d3_dust_orbs(geom: Node) -> void:
	## Epic-3 T73: 12 small floating dust orbs scattered through the
	## district airspace at varied heights — pulsing emissive spheres.
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 233
	for i in 12:
		var orb: MeshInstance3D = MeshInstance3D.new()
		orb.name = "D3DustOrb_%d" % i
		var om: SphereMesh = SphereMesh.new()
		om.radius = 0.10
		om.height = 0.20
		orb.mesh = om
		orb.position = D3_CENTER + Vector3(
			rng.randf_range(-22, 22),
			rng.randf_range(2, 10),
			rng.randf_range(-16, 16)
		)
		var omat: StandardMaterial3D = StandardMaterial3D.new()
		omat.albedo_color = Color(1.0, 0.95, 0.55)
		omat.emission_enabled = true
		omat.emission = Color(1.0, 0.95, 0.55)
		omat.emission_energy_multiplier = 2.6
		omat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		orb.material_override = omat
		geom.add_child(orb)
		# Pulse + drift
		var pulse: Tween = create_tween().set_loops()
		var ps: float = 1.0 + rng.randf() * 0.85
		pulse.tween_property(orb, "scale", Vector3(1.40, 1.40, 1.40), ps).set_ease(Tween.EASE_IN_OUT)
		pulse.tween_property(orb, "scale", Vector3(0.85, 0.85, 0.85), ps).set_ease(Tween.EASE_IN_OUT)
		var origin: Vector3 = orb.position
		var drift: Tween = create_tween().set_loops()
		drift.tween_property(orb, "position", origin + Vector3(rng.randf_range(-1, 1), rng.randf_range(-0.5, 0.5), rng.randf_range(-1, 1)), 4.0).set_ease(Tween.EASE_IN_OUT)
		drift.tween_property(orb, "position", origin, 4.0).set_ease(Tween.EASE_IN_OUT)


func _build_d3_altar_circle(geom: Node) -> void:
	## Epic-3 T74: 6 small spirit altars arranged in a circle around a
	## central glow point — like a coven gathering site.
	var circle_root: Node3D = Node3D.new()
	circle_root.name = "D3AltarCircle"
	circle_root.position = D3_CENTER + Vector3(0, 0, -16)
	geom.add_child(circle_root)
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.16, 0.10, 0.20)
	stone_mat.metallic = 0.55
	stone_mat.roughness = 0.45
	for i in 6:
		var angle: float = (float(i) / 6.0) * TAU
		var altar: MeshInstance3D = MeshInstance3D.new()
		altar.name = "AltarCircle_%d" % i
		var am: BoxMesh = BoxMesh.new()
		am.size = Vector3(0.55, 0.85, 0.55)
		altar.mesh = am
		altar.position = Vector3(cos(angle) * 2.40, 0.42, sin(angle) * 2.40)
		altar.material_override = stone_mat
		circle_root.add_child(altar)
		# Top crystal
		var crystal: MeshInstance3D = MeshInstance3D.new()
		var cm: PrismMesh = PrismMesh.new()
		cm.size = Vector3(0.20, 0.40, 0.20)
		crystal.mesh = cm
		crystal.position = Vector3(cos(angle) * 2.40, 1.05, sin(angle) * 2.40)
		var cmat: StandardMaterial3D = StandardMaterial3D.new()
		cmat.albedo_color = Color(0.85, 0.40, 1.0)
		cmat.emission_enabled = true
		cmat.emission = Color(1.0, 0.55, 1.0)
		cmat.emission_energy_multiplier = 2.6
		cmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		crystal.material_override = cmat
		circle_root.add_child(crystal)
		# Per-altar collision
		var sb: StaticBody3D = StaticBody3D.new()
		var cs: CollisionShape3D = CollisionShape3D.new()
		var cb: BoxShape3D = BoxShape3D.new()
		cb.size = Vector3(0.55, 0.85, 0.55)
		cs.shape = cb
		cs.position = Vector3(cos(angle) * 2.40, 0.42, sin(angle) * 2.40)
		sb.add_child(cs)
		circle_root.add_child(sb)
	# Center glow point
	var glow: MeshInstance3D = MeshInstance3D.new()
	var gm: SphereMesh = SphereMesh.new()
	gm.radius = 0.40
	gm.height = 0.80
	glow.mesh = gm
	glow.position = Vector3(0, 0.40, 0)
	var gmat: StandardMaterial3D = StandardMaterial3D.new()
	gmat.albedo_color = Color(1.0, 0.55, 1.0)
	gmat.emission_enabled = true
	gmat.emission = Color(1.0, 0.55, 1.0)
	gmat.emission_energy_multiplier = 3.4
	gmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	glow.material_override = gmat
	circle_root.add_child(glow)
	# Pulse the center
	var pulse: Tween = create_tween().set_loops()
	pulse.tween_property(glow, "scale", Vector3(1.30, 1.30, 1.30), 1.4).set_ease(Tween.EASE_IN_OUT)
	pulse.tween_property(glow, "scale", Vector3(0.85, 0.85, 0.85), 1.4).set_ease(Tween.EASE_IN_OUT)
	# Real OmniLight
	var light: OmniLight3D = OmniLight3D.new()
	light.position = Vector3(0, 0.85, 0)
	light.light_color = Color(1.0, 0.55, 1.0)
	light.light_energy = 2.4
	light.omni_range = 6.0
	circle_root.add_child(light)


func _build_d3_mind_crystals(geom: Node) -> void:
	## Epic-3 T75: a cluster of 8 floating "mind crystals" forming a
	## thinking pattern overhead — small spinning prisms drifting in a
	## brain-like cluster.
	var positions: Array[Vector3] = [
		D3_CENTER + Vector3(8, 6.5, 4),
		D3_CENTER + Vector3(9, 6.5, 5),
		D3_CENTER + Vector3(10, 7.0, 4),
		D3_CENTER + Vector3(9, 6.0, 3),
		D3_CENTER + Vector3(11, 7.0, 5),
		D3_CENTER + Vector3(8, 7.5, 5),
		D3_CENTER + Vector3(10, 6.0, 3),
		D3_CENTER + Vector3(11, 6.5, 4),
	]
	var crystal_mat: StandardMaterial3D = StandardMaterial3D.new()
	crystal_mat.albedo_color = Color(0.55, 0.95, 1.0)
	crystal_mat.emission_enabled = true
	crystal_mat.emission = Color(0.55, 0.95, 1.0)
	crystal_mat.emission_energy_multiplier = 2.4
	crystal_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for i in positions.size():
		var crystal: MeshInstance3D = MeshInstance3D.new()
		crystal.name = "D3MindCrystal_%d" % i
		var cm: PrismMesh = PrismMesh.new()
		cm.size = Vector3(0.20, 0.30, 0.20)
		crystal.mesh = cm
		crystal.position = positions[i]
		crystal.material_override = crystal_mat
		geom.add_child(crystal)
		# Spin + pulse
		var spin: Tween = create_tween().set_loops()
		spin.tween_property(crystal, "rotation:y", TAU, 4.0 + i * 0.3)
		var pulse: Tween = create_tween().set_loops()
		pulse.tween_property(crystal, "scale", Vector3(1.30, 1.30, 1.30), 0.85 + i * 0.1).set_ease(Tween.EASE_IN_OUT)
		pulse.tween_property(crystal, "scale", Vector3(0.85, 0.85, 0.85), 0.85 + i * 0.1).set_ease(Tween.EASE_IN_OUT)


func _build_d3_ascending_stairs(geom: Node) -> void:
	## Epic-3 T76: ascending stone stairs leading up to a high observation
	## platform — 6 wide steps + a square platform at the top.
	var stair: Node3D = Node3D.new()
	stair.name = "D3AscendingStairs"
	stair.position = D3_CENTER + Vector3(20, 0, -16)
	geom.add_child(stair)
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.16, 0.10, 0.20)
	stone_mat.metallic = 0.55
	stone_mat.roughness = 0.45
	stone_mat.emission_enabled = true
	stone_mat.emission = Color(0.85, 0.40, 1.0)
	stone_mat.emission_energy_multiplier = 0.30
	for i in 6:
		var step: MeshInstance3D = MeshInstance3D.new()
		var sm: BoxMesh = BoxMesh.new()
		sm.size = Vector3(2.40, 0.30, 1.20)
		step.mesh = sm
		step.position = Vector3(0, 0.15 + i * 0.30, i * 1.20)
		step.material_override = stone_mat
		stair.add_child(step)
		# Per-step collision
		var sb: StaticBody3D = StaticBody3D.new()
		var cs: CollisionShape3D = CollisionShape3D.new()
		var cb: BoxShape3D = BoxShape3D.new()
		cb.size = Vector3(2.40, 0.30, 1.20)
		cs.shape = cb
		cs.position = Vector3(0, 0.15 + i * 0.30, i * 1.20)
		sb.add_child(cs)
		stair.add_child(sb)
	# Top platform
	var platform: MeshInstance3D = MeshInstance3D.new()
	var pm: BoxMesh = BoxMesh.new()
	pm.size = Vector3(3.40, 0.30, 3.40)
	platform.mesh = pm
	platform.position = Vector3(0, 1.85, 8.40)
	platform.material_override = stone_mat
	stair.add_child(platform)
	# Platform collision
	var psb: StaticBody3D = StaticBody3D.new()
	var pcs: CollisionShape3D = CollisionShape3D.new()
	var pcb: BoxShape3D = BoxShape3D.new()
	pcb.size = Vector3(3.40, 0.30, 3.40)
	pcs.shape = pcb
	pcs.position = Vector3(0, 1.85, 8.40)
	psb.add_child(pcs)
	stair.add_child(psb)


func _build_d3_grand_telescope(geom: Node) -> void:
	## Epic-3 T77: a grand telescope landmark on a tripod stand — large
	## angled cylinder pointing at the sky portal.
	var scope: Node3D = Node3D.new()
	scope.name = "D3GrandTelescope"
	scope.position = D3_CENTER + Vector3(-22, 0, 6)
	geom.add_child(scope)
	# Tripod stand — 3 legs
	var leg_mat: StandardMaterial3D = StandardMaterial3D.new()
	leg_mat.albedo_color = Color(0.10, 0.10, 0.13)
	leg_mat.metallic = 0.85
	leg_mat.roughness = 0.30
	for i in 3:
		var angle: float = (float(i) / 3.0) * TAU
		var leg: MeshInstance3D = MeshInstance3D.new()
		var lm: CylinderMesh = CylinderMesh.new()
		lm.top_radius = 0.07
		lm.bottom_radius = 0.10
		lm.height = 2.40
		leg.mesh = lm
		leg.position = Vector3(cos(angle) * 0.55, 1.20, sin(angle) * 0.55)
		leg.rotation = Vector3(sin(angle) * deg_to_rad(20), 0, -cos(angle) * deg_to_rad(20))
		leg.material_override = leg_mat
		scope.add_child(leg)
	# Telescope tube — long angled cylinder
	var tube_mat: StandardMaterial3D = StandardMaterial3D.new()
	tube_mat.albedo_color = Color(0.20, 0.20, 0.28)
	tube_mat.metallic = 0.85
	tube_mat.roughness = 0.30
	tube_mat.emission_enabled = true
	tube_mat.emission = Color(0.85, 0.40, 1.0)
	tube_mat.emission_energy_multiplier = 0.45
	var tube: MeshInstance3D = MeshInstance3D.new()
	var tm: CylinderMesh = CylinderMesh.new()
	tm.top_radius = 0.30
	tm.bottom_radius = 0.40
	tm.height = 2.85
	tube.mesh = tm
	tube.position = Vector3(0, 2.85, 0)
	tube.rotation = Vector3(deg_to_rad(45), 0, 0)
	tube.material_override = tube_mat
	scope.add_child(tube)
	# Glowing lens at the top end
	var lens: MeshInstance3D = MeshInstance3D.new()
	var lm: SphereMesh = SphereMesh.new()
	lm.radius = 0.30
	lm.height = 0.60
	lens.mesh = lm
	lens.position = Vector3(0, 4.0, -1.0)
	var lmat: StandardMaterial3D = StandardMaterial3D.new()
	lmat.albedo_color = Color(0.55, 0.95, 1.0)
	lmat.emission_enabled = true
	lmat.emission = Color(0.55, 0.95, 1.0)
	lmat.emission_energy_multiplier = 3.0
	lmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	lens.material_override = lmat
	scope.add_child(lens)
	# Sign
	var label: Label3D = Label3D.new()
	label.text = "GRAND TELESCOPE"
	label.position = Vector3(0, 5.0, 0)
	label.modulate = Color(0.55, 0.95, 1.0)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 16
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	scope.add_child(label)
	# Collision
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cap: CapsuleShape3D = CapsuleShape3D.new()
	cap.radius = 0.65
	cap.height = 2.40
	cs.shape = cap
	cs.position = Vector3(0, 1.20, 0)
	sb.add_child(cs)
	scope.add_child(sb)


func _build_d3_prayer_chains(geom: Node) -> void:
	## Epic-3 T78: a hanging prayer chain mobile — top horizontal bar
	## with 5 vertical chains, each holding a colored prayer pendant.
	var chains: Node3D = Node3D.new()
	chains.name = "D3PrayerChains"
	chains.position = D3_CENTER + Vector3(0, 4.5, 8)
	geom.add_child(chains)
	# Top bar
	var bar_mat: StandardMaterial3D = StandardMaterial3D.new()
	bar_mat.albedo_color = Color(0.10, 0.10, 0.13)
	bar_mat.metallic = 0.85
	var bar: MeshInstance3D = MeshInstance3D.new()
	var bm: CylinderMesh = CylinderMesh.new()
	bm.top_radius = 0.06
	bm.bottom_radius = 0.06
	bm.height = 2.85
	bar.mesh = bm
	bar.rotation = Vector3(0, 0, deg_to_rad(90))
	bar.material_override = bar_mat
	chains.add_child(bar)
	# 5 hanging chains with pendants
	var pendant_colors: Array[Color] = [
		Color(0.55, 0.95, 1.0),
		Color(1.0, 0.55, 0.20),
		Color(0.45, 1.0, 0.55),
		Color(0.85, 0.40, 1.0),
		Color(1.0, 0.95, 0.30),
	]
	for i in 5:
		var hx: float = -1.20 + i * 0.60
		# Chain — thin cylinder
		var chain: MeshInstance3D = MeshInstance3D.new()
		var cm: CylinderMesh = CylinderMesh.new()
		cm.top_radius = 0.02
		cm.bottom_radius = 0.02
		cm.height = 1.20 + (i % 3) * 0.20
		chain.mesh = cm
		chain.position = Vector3(hx, -(0.60 + (i % 3) * 0.10), 0)
		chain.material_override = bar_mat
		chains.add_child(chain)
		# Pendant at the bottom
		var pendant: MeshInstance3D = MeshInstance3D.new()
		var pmesh: PrismMesh = PrismMesh.new()
		pmesh.size = Vector3(0.18, 0.30, 0.18)
		pendant.mesh = pmesh
		pendant.position = Vector3(hx, -(1.20 + (i % 3) * 0.20), 0)
		var pmat: StandardMaterial3D = StandardMaterial3D.new()
		pmat.albedo_color = pendant_colors[i]
		pmat.emission_enabled = true
		pmat.emission = pendant_colors[i]
		pmat.emission_energy_multiplier = 2.4
		pmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		pendant.material_override = pmat
		chains.add_child(pendant)
	# Sway the entire mobile
	var sway: Tween = create_tween().set_loops()
	sway.tween_property(chains, "rotation:z", deg_to_rad(8), 1.6).set_ease(Tween.EASE_IN_OUT)
	sway.tween_property(chains, "rotation:z", deg_to_rad(-8), 1.6).set_ease(Tween.EASE_IN_OUT)


func _build_d3_dreamcatcher(geom: Node) -> void:
	## Epic-3 T79: a large dreamcatcher mobile — torus rim with 8 thin
	## emissive web threads forming an X pattern + 3 small hanging
	## feathers below.
	var catcher: Node3D = Node3D.new()
	catcher.name = "D3Dreamcatcher"
	catcher.position = D3_CENTER + Vector3(15, 4.5, -4)
	geom.add_child(catcher)
	# Outer torus rim
	var rim_mat: StandardMaterial3D = StandardMaterial3D.new()
	rim_mat.albedo_color = Color(0.85, 0.55, 0.20)
	rim_mat.metallic = 0.40
	rim_mat.roughness = 0.55
	rim_mat.emission_enabled = true
	rim_mat.emission = Color(1.0, 0.65, 0.20)
	rim_mat.emission_energy_multiplier = 0.85
	var rim: MeshInstance3D = MeshInstance3D.new()
	var rmesh: TorusMesh = TorusMesh.new()
	rmesh.inner_radius = 0.85
	rmesh.outer_radius = 1.0
	rim.mesh = rmesh
	rim.rotation = Vector3(deg_to_rad(90), 0, 0)
	rim.material_override = rim_mat
	catcher.add_child(rim)
	# 8 thin web threads in radial pattern
	var web_mat: StandardMaterial3D = StandardMaterial3D.new()
	web_mat.albedo_color = Color(0.85, 0.95, 1.0)
	web_mat.emission_enabled = true
	web_mat.emission = Color(0.85, 0.95, 1.0)
	web_mat.emission_energy_multiplier = 1.4
	web_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for i in 8:
		var angle: float = (float(i) / 8.0) * TAU
		var thread: MeshInstance3D = MeshInstance3D.new()
		var tm: BoxMesh = BoxMesh.new()
		tm.size = Vector3(0.04, 1.85, 0.04)
		thread.mesh = tm
		thread.position = Vector3(0, 0, 0)
		thread.rotation = Vector3(0, 0, angle)
		thread.material_override = web_mat
		catcher.add_child(thread)
	# 3 small hanging feathers below
	for i in 3:
		var feather: MeshInstance3D = MeshInstance3D.new()
		var fm: BoxMesh = BoxMesh.new()
		fm.size = Vector3(0.10, 0.55, 0.04)
		feather.mesh = fm
		feather.position = Vector3(-0.30 + i * 0.30, -1.40, 0)
		var fmat: StandardMaterial3D = StandardMaterial3D.new()
		fmat.albedo_color = [Color(1.0, 0.55, 0.20), Color(0.85, 0.40, 1.0), Color(0.55, 0.95, 1.0)][i]
		fmat.emission_enabled = true
		fmat.emission = fmat.albedo_color
		fmat.emission_energy_multiplier = 0.85
		feather.material_override = fmat
		catcher.add_child(feather)
	# Slow rotation
	var spin: Tween = create_tween().set_loops()
	spin.tween_property(catcher, "rotation:z", TAU, 12.0)


func _build_d3_starseer_npc() -> void:
	## Epic-3 T80: Starseer NPC standing on the high observation platform
	## looking up at the sky portal. Has a long telescope held in one hand.
	var slots: Node3D = get_node_or_null("%NPCSlots") as Node3D
	if slots == null:
		return
	var seer: Node3D = Node3D.new()
	seer.name = "D3Starseer"
	seer.position = D3_CENTER + Vector3(20, 2.0, -8)
	slots.add_child(seer)
	# Robed body
	var bmat: StandardMaterial3D = StandardMaterial3D.new()
	bmat.albedo_color = Color(0.10, 0.16, 0.30)
	bmat.metallic = 0.20
	bmat.roughness = 0.65
	bmat.emission_enabled = true
	bmat.emission = Color(0.30, 0.55, 0.95)
	bmat.emission_energy_multiplier = 0.40
	var body: MeshInstance3D = MeshInstance3D.new()
	var bmesh: CapsuleMesh = CapsuleMesh.new()
	bmesh.radius = 0.45
	bmesh.height = 1.40
	body.mesh = bmesh
	body.position = Vector3(0, 0.70, 0)
	body.material_override = bmat
	seer.add_child(body)
	# Star-patterned hood
	var hood: MeshInstance3D = MeshInstance3D.new()
	var hmesh: SphereMesh = SphereMesh.new()
	hmesh.radius = 0.45
	hmesh.height = 0.55
	hood.mesh = hmesh
	hood.position = Vector3(0, 1.55, 0)
	hood.material_override = bmat
	seer.add_child(hood)
	# 2 cyan eyes
	var eye_mat: StandardMaterial3D = StandardMaterial3D.new()
	eye_mat.albedo_color = Color(0.55, 0.95, 1.0)
	eye_mat.emission_enabled = true
	eye_mat.emission = Color(0.55, 0.95, 1.0)
	eye_mat.emission_energy_multiplier = 2.6
	eye_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for ex: float in [-0.10, 0.10]:
		var eye: MeshInstance3D = MeshInstance3D.new()
		var em: SphereMesh = SphereMesh.new()
		em.radius = 0.06
		em.height = 0.12
		eye.mesh = em
		eye.position = Vector3(ex, 1.40, 0.34)
		eye.material_override = eye_mat
		seer.add_child(eye)
	# Long telescope held in front pointing upward
	var scope_mat: StandardMaterial3D = StandardMaterial3D.new()
	scope_mat.albedo_color = Color(0.10, 0.10, 0.13)
	scope_mat.metallic = 0.85
	var scope: MeshInstance3D = MeshInstance3D.new()
	var sm: CylinderMesh = CylinderMesh.new()
	sm.top_radius = 0.07
	sm.bottom_radius = 0.10
	sm.height = 1.40
	scope.mesh = sm
	scope.position = Vector3(0.40, 1.30, 0.30)
	scope.rotation = Vector3(deg_to_rad(45), 0, 0)
	scope.material_override = scope_mat
	seer.add_child(scope)
	# Glowing tip
	var tip: MeshInstance3D = MeshInstance3D.new()
	var tm2: SphereMesh = SphereMesh.new()
	tm2.radius = 0.10
	tm2.height = 0.20
	tip.mesh = tm2
	tip.position = Vector3(0.40, 1.85, 0.85)
	var tmat: StandardMaterial3D = StandardMaterial3D.new()
	tmat.albedo_color = Color(0.55, 0.95, 1.0)
	tmat.emission_enabled = true
	tmat.emission = Color(0.55, 0.95, 1.0)
	tmat.emission_energy_multiplier = 3.0
	tmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	tip.material_override = tmat
	seer.add_child(tip)
	# Name billboard
	var label: Label3D = Label3D.new()
	label.text = "Starseer"
	label.position = Vector3(0, 2.20, 0)
	label.modulate = Color(0.55, 0.95, 1.0)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 18
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	seer.add_child(label)


func _build_d3_spell_scrolls(geom: Node) -> void:
	## Epic-3 T81: 8 spell scrolls floating in a cluster — long thin
	## emissive cylinders with rune labels at varying heights.
	var positions: Array[Vector3] = [
		D3_CENTER + Vector3(-15, 2.5, 8),
		D3_CENTER + Vector3(-15, 3.0, 9),
		D3_CENTER + Vector3(-14, 2.5, 9),
		D3_CENTER + Vector3(-16, 2.5, 9),
		D3_CENTER + Vector3(-15, 3.5, 8),
		D3_CENTER + Vector3(-14, 3.5, 8),
		D3_CENTER + Vector3(-16, 3.5, 8),
		D3_CENTER + Vector3(-15, 4.0, 9),
	]
	var scroll_mat: StandardMaterial3D = StandardMaterial3D.new()
	scroll_mat.albedo_color = Color(0.95, 0.85, 0.55)
	scroll_mat.emission_enabled = true
	scroll_mat.emission = Color(1.0, 0.85, 0.55)
	scroll_mat.emission_energy_multiplier = 1.4
	scroll_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for i in positions.size():
		var scroll: MeshInstance3D = MeshInstance3D.new()
		scroll.name = "D3SpellScroll_%d" % i
		var sm: CylinderMesh = CylinderMesh.new()
		sm.top_radius = 0.10
		sm.bottom_radius = 0.10
		sm.height = 0.55
		scroll.mesh = sm
		scroll.position = positions[i]
		scroll.rotation = Vector3(0, 0, deg_to_rad(randf_range(-25, 25)))
		scroll.material_override = scroll_mat
		geom.add_child(scroll)
		# Bob + spin
		var bob: Tween = create_tween().set_loops()
		var origin_y: float = positions[i].y
		bob.tween_property(scroll, "position:y", origin_y + 0.30, 1.4 + i * 0.1).set_ease(Tween.EASE_IN_OUT)
		bob.tween_property(scroll, "position:y", origin_y, 1.4 + i * 0.1).set_ease(Tween.EASE_IN_OUT)
		var spin: Tween = create_tween().set_loops()
		spin.tween_property(scroll, "rotation:y", TAU, 5.0 + i * 0.4)


func _build_d3_cleric_npc() -> void:
	## Epic-3 T82: Cleric NPC standing by the healing fountain holding a
	## green glowing healing wand.
	var slots: Node3D = get_node_or_null("%NPCSlots") as Node3D
	if slots == null:
		return
	var cleric: Node3D = Node3D.new()
	cleric.name = "D3Cleric"
	cleric.position = D3_CENTER + Vector3(18, 0, -8)
	slots.add_child(cleric)
	# Robed body — white-green
	var bmat: StandardMaterial3D = StandardMaterial3D.new()
	bmat.albedo_color = Color(0.85, 0.95, 0.85)
	bmat.metallic = 0.20
	bmat.roughness = 0.55
	bmat.emission_enabled = true
	bmat.emission = Color(0.45, 1.0, 0.55)
	bmat.emission_energy_multiplier = 0.30
	var body: MeshInstance3D = MeshInstance3D.new()
	var bmesh: CapsuleMesh = CapsuleMesh.new()
	bmesh.radius = 0.45
	bmesh.height = 1.40
	body.mesh = bmesh
	body.position = Vector3(0, 0.70, 0)
	body.material_override = bmat
	cleric.add_child(body)
	# Hood
	var hood: MeshInstance3D = MeshInstance3D.new()
	var hmesh: SphereMesh = SphereMesh.new()
	hmesh.radius = 0.45
	hmesh.height = 0.55
	hood.mesh = hmesh
	hood.position = Vector3(0, 1.55, 0)
	hood.material_override = bmat
	cleric.add_child(hood)
	# 2 green eyes
	var eye_mat: StandardMaterial3D = StandardMaterial3D.new()
	eye_mat.albedo_color = Color(0.55, 1.0, 0.55)
	eye_mat.emission_enabled = true
	eye_mat.emission = Color(0.55, 1.0, 0.55)
	eye_mat.emission_energy_multiplier = 2.6
	eye_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for ex: float in [-0.10, 0.10]:
		var eye: MeshInstance3D = MeshInstance3D.new()
		var em: SphereMesh = SphereMesh.new()
		em.radius = 0.06
		em.height = 0.12
		eye.mesh = em
		eye.position = Vector3(ex, 1.40, 0.34)
		eye.material_override = eye_mat
		cleric.add_child(eye)
	# Healing wand held in front
	var wand: MeshInstance3D = MeshInstance3D.new()
	var wm: CylinderMesh = CylinderMesh.new()
	wm.top_radius = 0.04
	wm.bottom_radius = 0.06
	wm.height = 1.20
	wand.mesh = wm
	wand.position = Vector3(0.45, 1.0, 0)
	var wmat: StandardMaterial3D = StandardMaterial3D.new()
	wmat.albedo_color = Color(0.30, 0.20, 0.10)
	wmat.metallic = 0.30
	wand.material_override = wmat
	cleric.add_child(wand)
	# Glowing tip orb
	var orb: MeshInstance3D = MeshInstance3D.new()
	var om: SphereMesh = SphereMesh.new()
	om.radius = 0.18
	om.height = 0.36
	orb.mesh = om
	orb.position = Vector3(0.45, 1.65, 0)
	var omat: StandardMaterial3D = StandardMaterial3D.new()
	omat.albedo_color = Color(0.55, 1.0, 0.55)
	omat.emission_enabled = true
	omat.emission = Color(0.55, 1.0, 0.55)
	omat.emission_energy_multiplier = 3.0
	omat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	orb.material_override = omat
	cleric.add_child(orb)
	# Pulse the orb
	var pulse: Tween = create_tween().set_loops()
	pulse.tween_property(orb, "scale", Vector3(1.40, 1.40, 1.40), 1.0).set_ease(Tween.EASE_IN_OUT)
	pulse.tween_property(orb, "scale", Vector3(0.85, 0.85, 0.85), 1.0).set_ease(Tween.EASE_IN_OUT)
	# Name billboard
	var label: Label3D = Label3D.new()
	label.text = "Cleric"
	label.position = Vector3(0, 2.20, 0)
	label.modulate = Color(0.55, 1.0, 0.55)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 18
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	cleric.add_child(label)


func _build_d3_ancient_gargoyles(geom: Node) -> void:
	## Epic-3 T83: 3 violet gargoyle statues guarding the sealed gates.
	var positions: Array[Vector3] = [
		D3_CENTER + Vector3(16, 0, -4),
		D3_CENTER + Vector3(16, 0, 4),
		D3_CENTER + Vector3(20, 0, 0),
	]
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.16, 0.10, 0.20)
	stone_mat.metallic = 0.40
	stone_mat.roughness = 0.55
	stone_mat.emission_enabled = true
	stone_mat.emission = Color(0.85, 0.40, 1.0)
	stone_mat.emission_energy_multiplier = 0.30
	for i in positions.size():
		var garg: Node3D = Node3D.new()
		garg.name = "D3AncientGargoyle_%d" % i
		garg.position = positions[i]
		garg.rotation = Vector3(0, deg_to_rad(180 + i * 45), 0)
		geom.add_child(garg)
		# Pedestal
		var ped: MeshInstance3D = MeshInstance3D.new()
		var pm: BoxMesh = BoxMesh.new()
		pm.size = Vector3(0.85, 0.85, 0.85)
		ped.mesh = pm
		ped.position = Vector3(0, 0.42, 0)
		ped.material_override = stone_mat
		garg.add_child(ped)
		# Crouched body
		var body: MeshInstance3D = MeshInstance3D.new()
		var bm: BoxMesh = BoxMesh.new()
		bm.size = Vector3(0.55, 0.55, 0.65)
		body.mesh = bm
		body.position = Vector3(0, 1.10, 0)
		body.material_override = stone_mat
		garg.add_child(body)
		# Head
		var head: MeshInstance3D = MeshInstance3D.new()
		var hm: BoxMesh = BoxMesh.new()
		hm.size = Vector3(0.40, 0.40, 0.40)
		head.mesh = hm
		head.position = Vector3(0, 1.55, 0.10)
		head.material_override = stone_mat
		garg.add_child(head)
		# 2 violet glowing eyes
		var eye_mat: StandardMaterial3D = StandardMaterial3D.new()
		eye_mat.albedo_color = Color(1.0, 0.55, 1.0)
		eye_mat.emission_enabled = true
		eye_mat.emission = Color(1.0, 0.55, 1.0)
		eye_mat.emission_energy_multiplier = 2.6
		eye_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		for ex: float in [-0.08, 0.08]:
			var eye: MeshInstance3D = MeshInstance3D.new()
			var em: SphereMesh = SphereMesh.new()
			em.radius = 0.05
			em.height = 0.10
			eye.mesh = em
			eye.position = Vector3(ex, 1.58, 0.32)
			eye.material_override = eye_mat
			garg.add_child(eye)
		# Wings — angled boxes on the body
		for sx: float in [-0.40, 0.40]:
			var wing: MeshInstance3D = MeshInstance3D.new()
			var wm: BoxMesh = BoxMesh.new()
			wm.size = Vector3(0.10, 0.55, 0.20)
			wing.mesh = wm
			wing.position = Vector3(sx, 1.30, -0.10)
			wing.rotation = Vector3(0, 0, sign(sx) * deg_to_rad(25))
			wing.material_override = stone_mat
			garg.add_child(wing)
		# Per-gargoyle collision
		var sb: StaticBody3D = StaticBody3D.new()
		var cs: CollisionShape3D = CollisionShape3D.new()
		var cb: BoxShape3D = BoxShape3D.new()
		cb.size = Vector3(0.85, 1.85, 0.85)
		cs.shape = cb
		cs.position = Vector3(0, 0.92, 0)
		sb.add_child(cs)
		garg.add_child(sb)


func _build_d3_lone_bell(geom: Node) -> void:
	## Epic-3 T84: a lone tall bell on a stone arch frame near the
	## boundary, swinging gently.
	var bell: Node3D = Node3D.new()
	bell.name = "D3LoneBell"
	bell.position = D3_CENTER + Vector3(-22, 0, 14)
	geom.add_child(bell)
	# 2 frame legs
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.16, 0.10, 0.20)
	stone_mat.metallic = 0.55
	stone_mat.roughness = 0.45
	for sx: float in [-0.85, 0.85]:
		var leg: MeshInstance3D = MeshInstance3D.new()
		var lm: BoxMesh = BoxMesh.new()
		lm.size = Vector3(0.30, 3.40, 0.30)
		leg.mesh = lm
		leg.position = Vector3(sx, 1.70, 0)
		leg.material_override = stone_mat
		bell.add_child(leg)
		# Collision
		var sb: StaticBody3D = StaticBody3D.new()
		var cs: CollisionShape3D = CollisionShape3D.new()
		var cb: BoxShape3D = BoxShape3D.new()
		cb.size = Vector3(0.30, 3.40, 0.30)
		cs.shape = cb
		cs.position = Vector3(sx, 1.70, 0)
		sb.add_child(cs)
		bell.add_child(sb)
	# Crossbar
	var bar: MeshInstance3D = MeshInstance3D.new()
	var bm: BoxMesh = BoxMesh.new()
	bm.size = Vector3(2.0, 0.30, 0.30)
	bar.mesh = bm
	bar.position = Vector3(0, 3.40, 0)
	bar.material_override = stone_mat
	bell.add_child(bar)
	# Pivot for the bell
	var pivot: Node3D = Node3D.new()
	pivot.position = Vector3(0, 3.40, 0)
	bell.add_child(pivot)
	# Bell — wider cylinder + half sphere
	var bell_mat: StandardMaterial3D = StandardMaterial3D.new()
	bell_mat.albedo_color = Color(0.85, 0.65, 0.30)
	bell_mat.emission_enabled = true
	bell_mat.emission = Color(1.0, 0.75, 0.30)
	bell_mat.emission_energy_multiplier = 0.85
	bell_mat.metallic = 0.85
	bell_mat.roughness = 0.20
	var bell_body: MeshInstance3D = MeshInstance3D.new()
	var bbm: CylinderMesh = CylinderMesh.new()
	bbm.top_radius = 0.30
	bbm.bottom_radius = 0.55
	bbm.height = 0.85
	bell_body.mesh = bbm
	bell_body.position = Vector3(0, -0.65, 0)
	bell_body.material_override = bell_mat
	pivot.add_child(bell_body)
	# Swing tween
	var swing: Tween = create_tween().set_loops()
	swing.tween_property(pivot, "rotation:z", deg_to_rad(15), 1.4).set_ease(Tween.EASE_IN_OUT)
	swing.tween_property(pivot, "rotation:z", deg_to_rad(-15), 1.4).set_ease(Tween.EASE_IN_OUT)


func _build_d3_dream_eater(geom: Node) -> void:
	## Epic-3 T85: DREAM EATER 3rd mini-boss — a wide hovering creature
	## with translucent tentacle arms hanging down. Slow drift patrol.
	var eater: Node3D = Node3D.new()
	eater.name = "D3DreamEater"
	eater.position = D3_CENTER + Vector3(-20, 4, 8)
	geom.add_child(eater)
	# Wide hovering body — flattened sphere
	var bmat: StandardMaterial3D = StandardMaterial3D.new()
	bmat.albedo_color = Color(0.55, 0.30, 0.85, 0.55)
	bmat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	bmat.emission_enabled = true
	bmat.emission = Color(1.0, 0.55, 1.0)
	bmat.emission_energy_multiplier = 1.8
	bmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var body: MeshInstance3D = MeshInstance3D.new()
	var bmesh: SphereMesh = SphereMesh.new()
	bmesh.radius = 1.40
	bmesh.height = 1.40
	body.mesh = bmesh
	body.position = Vector3(0, 0, 0)
	body.scale = Vector3(1.0, 0.6, 1.0)
	body.material_override = bmat
	eater.add_child(body)
	# Single bright eye in the center
	var eye: MeshInstance3D = MeshInstance3D.new()
	var em: SphereMesh = SphereMesh.new()
	em.radius = 0.40
	em.height = 0.80
	eye.mesh = em
	eye.position = Vector3(0, 0.10, 0)
	var emat: StandardMaterial3D = StandardMaterial3D.new()
	emat.albedo_color = Color(1, 1, 1)
	emat.emission_enabled = true
	emat.emission = Color(1, 1, 1)
	emat.emission_energy_multiplier = 3.4
	emat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	eye.material_override = emat
	eater.add_child(eye)
	# 6 hanging tentacle arms
	var tent_mat: StandardMaterial3D = StandardMaterial3D.new()
	tent_mat.albedo_color = Color(0.85, 0.40, 1.0, 0.55)
	tent_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	tent_mat.emission_enabled = true
	tent_mat.emission = Color(1.0, 0.55, 1.0)
	tent_mat.emission_energy_multiplier = 1.4
	tent_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for i in 6:
		var angle: float = (float(i) / 6.0) * TAU
		var tent: MeshInstance3D = MeshInstance3D.new()
		var tm: CylinderMesh = CylinderMesh.new()
		tm.top_radius = 0.10
		tm.bottom_radius = 0.04
		tm.height = 1.40
		tent.mesh = tm
		tent.position = Vector3(cos(angle) * 0.85, -1.0, sin(angle) * 0.85)
		tent.material_override = tent_mat
		eater.add_child(tent)
	# Slow drift patrol
	var origin: Vector3 = D3_CENTER + Vector3(-20, 4, 8)
	var patrol: Tween = create_tween().set_loops()
	patrol.tween_property(eater, "position", origin + Vector3(4, 0, 4), 8.0).set_ease(Tween.EASE_IN_OUT)
	patrol.tween_property(eater, "position", origin + Vector3(0, 0, 8), 8.0).set_ease(Tween.EASE_IN_OUT)
	patrol.tween_property(eater, "position", origin, 8.0).set_ease(Tween.EASE_IN_OUT)
	# Pulse the eye
	var pulse: Tween = create_tween().set_loops()
	pulse.tween_property(emat, "emission_energy_multiplier", 4.5, 0.85).set_ease(Tween.EASE_IN_OUT)
	pulse.tween_property(emat, "emission_energy_multiplier", 2.0, 0.85).set_ease(Tween.EASE_IN_OUT)
	# Boss-tier name billboard
	var label: Label3D = Label3D.new()
	label.text = "DREAM EATER"
	label.position = Vector3(0, 2.0, 0)
	label.modulate = Color(1.0, 0.55, 1.0)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 6
	label.font_size = 22
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	eater.add_child(label)


func _build_d3_lectern(geom: Node) -> void:
	## Epic-3 T86: a lectern with a floating script — angled stand with
	## a glowing scroll hovering above the reading surface.
	var lect: Node3D = Node3D.new()
	lect.name = "D3Lectern"
	lect.position = D3_CENTER + Vector3(8, 0, -3)
	geom.add_child(lect)
	# Stand column
	var wood_mat: StandardMaterial3D = StandardMaterial3D.new()
	wood_mat.albedo_color = Color(0.30, 0.18, 0.10)
	wood_mat.metallic = 0.10
	wood_mat.roughness = 0.65
	var stand: MeshInstance3D = MeshInstance3D.new()
	var sm: BoxMesh = BoxMesh.new()
	sm.size = Vector3(0.40, 1.20, 0.40)
	stand.mesh = sm
	stand.position = Vector3(0, 0.60, 0)
	stand.material_override = wood_mat
	lect.add_child(stand)
	# Angled top desk
	var top: MeshInstance3D = MeshInstance3D.new()
	var tm: BoxMesh = BoxMesh.new()
	tm.size = Vector3(0.85, 0.10, 0.55)
	top.mesh = tm
	top.position = Vector3(0, 1.30, 0)
	top.rotation = Vector3(deg_to_rad(-15), 0, 0)
	top.material_override = wood_mat
	lect.add_child(top)
	# Floating script above the desk
	var script: MeshInstance3D = MeshInstance3D.new()
	var scrm: BoxMesh = BoxMesh.new()
	scrm.size = Vector3(0.65, 0.04, 0.40)
	script.mesh = scrm
	script.position = Vector3(0, 1.65, 0)
	script.rotation = Vector3(deg_to_rad(-15), 0, 0)
	var scrmat: StandardMaterial3D = StandardMaterial3D.new()
	scrmat.albedo_color = Color(1.0, 0.85, 0.55)
	scrmat.emission_enabled = true
	scrmat.emission = Color(1.0, 0.85, 0.55)
	scrmat.emission_energy_multiplier = 1.4
	scrmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	script.material_override = scrmat
	lect.add_child(script)
	# Bob the script
	var bob: Tween = create_tween().set_loops()
	bob.tween_property(script, "position:y", 1.85, 1.4).set_ease(Tween.EASE_IN_OUT)
	bob.tween_property(script, "position:y", 1.65, 1.4).set_ease(Tween.EASE_IN_OUT)
	# Collision
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(0.85, 1.40, 0.55)
	cs.shape = cb
	cs.position = Vector3(0, 0.70, 0)
	sb.add_child(cs)
	lect.add_child(sb)


func _build_d3_reflecting_pool(geom: Node) -> void:
	## Epic-3 T87: a long rectangular reflecting pool — slim emissive
	## cyan basin reflecting the sky.
	var pool: Node3D = Node3D.new()
	pool.name = "D3ReflectingPool"
	pool.position = D3_CENTER + Vector3(-15, 0, 0)
	geom.add_child(pool)
	# Stone rim — 4 boxes forming a rectangle frame
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.16, 0.10, 0.20)
	stone_mat.metallic = 0.55
	stone_mat.roughness = 0.45
	var rim_specs: Array = [
		[Vector3(0, 0.10, -1.40), Vector3(3.40, 0.20, 0.30)],
		[Vector3(0, 0.10, 1.40), Vector3(3.40, 0.20, 0.30)],
		[Vector3(-1.55, 0.10, 0), Vector3(0.30, 0.20, 2.50)],
		[Vector3(1.55, 0.10, 0), Vector3(0.30, 0.20, 2.50)],
	]
	for spec in rim_specs:
		var rim: MeshInstance3D = MeshInstance3D.new()
		var rm: BoxMesh = BoxMesh.new()
		rm.size = spec[1]
		rim.mesh = rm
		rim.position = spec[0]
		rim.material_override = stone_mat
		pool.add_child(rim)
	# Inner water surface
	var water: MeshInstance3D = MeshInstance3D.new()
	var wm: BoxMesh = BoxMesh.new()
	wm.size = Vector3(2.85, 0.06, 2.40)
	water.mesh = wm
	water.position = Vector3(0, 0.10, 0)
	var wmat: StandardMaterial3D = StandardMaterial3D.new()
	wmat.albedo_color = Color(0.30, 0.85, 1.0, 0.85)
	wmat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	wmat.emission_enabled = true
	wmat.emission = Color(0.55, 0.95, 1.0)
	wmat.emission_energy_multiplier = 1.4
	wmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	water.material_override = wmat
	pool.add_child(water)
	# Sign
	var label: Label3D = Label3D.new()
	label.text = "REFLECTING POOL"
	label.position = Vector3(0, 1.40, 0)
	label.modulate = Color(0.55, 0.95, 1.0)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 14
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	pool.add_child(label)


func _build_d3_staff_cluster(geom: Node) -> void:
	## Epic-3 T88: 5 mage staves leaning against each other in a cluster —
	## tall thin cylinders with colored gem tops.
	var cluster: Node3D = Node3D.new()
	cluster.name = "D3StaffCluster"
	cluster.position = D3_CENTER + Vector3(-18, 0, 14)
	geom.add_child(cluster)
	var wood_mat: StandardMaterial3D = StandardMaterial3D.new()
	wood_mat.albedo_color = Color(0.30, 0.18, 0.10)
	wood_mat.metallic = 0.10
	wood_mat.roughness = 0.65
	var gem_colors: Array[Color] = [
		Color(0.55, 0.95, 1.0),
		Color(1.0, 0.55, 0.20),
		Color(0.45, 1.0, 0.55),
		Color(0.85, 0.40, 1.0),
		Color(1.0, 0.95, 0.30),
	]
	for i in 5:
		var angle: float = (float(i) / 5.0) * TAU
		var staff: MeshInstance3D = MeshInstance3D.new()
		var smesh: CylinderMesh = CylinderMesh.new()
		smesh.top_radius = 0.05
		smesh.bottom_radius = 0.06
		smesh.height = 1.85
		staff.mesh = smesh
		staff.position = Vector3(cos(angle) * 0.30, 0.92, sin(angle) * 0.30)
		staff.rotation = Vector3(sin(angle) * deg_to_rad(20), 0, -cos(angle) * deg_to_rad(20))
		staff.material_override = wood_mat
		cluster.add_child(staff)
		# Gem tip on top
		var gem: MeshInstance3D = MeshInstance3D.new()
		var gm: SphereMesh = SphereMesh.new()
		gm.radius = 0.10
		gm.height = 0.20
		gem.mesh = gm
		gem.position = Vector3(cos(angle) * 0.55, 1.85, sin(angle) * 0.55)
		var gmat: StandardMaterial3D = StandardMaterial3D.new()
		gmat.albedo_color = gem_colors[i]
		gmat.emission_enabled = true
		gmat.emission = gem_colors[i]
		gmat.emission_energy_multiplier = 2.6
		gmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		gem.material_override = gmat
		cluster.add_child(gem)


func _build_d3_elder_mage_npc() -> void:
	## Epic-3 T89: Elder Mage NPC standing on the floating crown landmark
	## platform — long beard, tall hat, multi-colored robe.
	var slots: Node3D = get_node_or_null("%NPCSlots") as Node3D
	if slots == null:
		return
	var elder: Node3D = Node3D.new()
	elder.name = "D3ElderMage"
	elder.position = D3_CENTER + Vector3(-15, 2.0, 14)
	slots.add_child(elder)
	# Multi-color robe body
	var bmat: StandardMaterial3D = StandardMaterial3D.new()
	bmat.albedo_color = Color(0.40, 0.20, 0.55)
	bmat.metallic = 0.20
	bmat.roughness = 0.65
	bmat.emission_enabled = true
	bmat.emission = Color(0.85, 0.40, 1.0)
	bmat.emission_energy_multiplier = 0.40
	var body: MeshInstance3D = MeshInstance3D.new()
	var bmesh: CapsuleMesh = CapsuleMesh.new()
	bmesh.radius = 0.45
	bmesh.height = 1.40
	body.mesh = bmesh
	body.position = Vector3(0, 0.70, 0)
	body.material_override = bmat
	elder.add_child(body)
	# Tall pointed hat
	var hat: MeshInstance3D = MeshInstance3D.new()
	var hm: PrismMesh = PrismMesh.new()
	hm.size = Vector3(0.55, 1.20, 0.55)
	hat.mesh = hm
	hat.position = Vector3(0, 2.10, 0)
	hat.material_override = bmat
	elder.add_child(hat)
	# Long white beard
	var beard: MeshInstance3D = MeshInstance3D.new()
	var bm: BoxMesh = BoxMesh.new()
	bm.size = Vector3(0.30, 0.85, 0.10)
	beard.mesh = bm
	beard.position = Vector3(0, 1.20, 0.34)
	var bmat2: StandardMaterial3D = StandardMaterial3D.new()
	bmat2.albedo_color = Color(0.95, 0.95, 1.0)
	bmat2.metallic = 0.10
	bmat2.roughness = 0.85
	beard.material_override = bmat2
	elder.add_child(beard)
	# 2 wise white eyes
	var eye_mat: StandardMaterial3D = StandardMaterial3D.new()
	eye_mat.albedo_color = Color(0.55, 0.95, 1.0)
	eye_mat.emission_enabled = true
	eye_mat.emission = Color(0.55, 0.95, 1.0)
	eye_mat.emission_energy_multiplier = 2.6
	eye_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for ex: float in [-0.10, 0.10]:
		var eye: MeshInstance3D = MeshInstance3D.new()
		var em: SphereMesh = SphereMesh.new()
		em.radius = 0.05
		em.height = 0.10
		eye.mesh = em
		eye.position = Vector3(ex, 1.55, 0.34)
		eye.material_override = eye_mat
		elder.add_child(eye)
	# Long curved staff held in front
	var staff: MeshInstance3D = MeshInstance3D.new()
	var sm: CylinderMesh = CylinderMesh.new()
	sm.top_radius = 0.06
	sm.bottom_radius = 0.08
	sm.height = 2.40
	staff.mesh = sm
	staff.position = Vector3(0.45, 1.20, 0)
	var smat: StandardMaterial3D = StandardMaterial3D.new()
	smat.albedo_color = Color(0.30, 0.18, 0.10)
	smat.metallic = 0.30
	staff.material_override = smat
	elder.add_child(staff)
	# Big glowing crystal at the top of the staff
	var crystal: MeshInstance3D = MeshInstance3D.new()
	var cm: PrismMesh = PrismMesh.new()
	cm.size = Vector3(0.30, 0.55, 0.30)
	crystal.mesh = cm
	crystal.position = Vector3(0.45, 2.65, 0)
	var cmat: StandardMaterial3D = StandardMaterial3D.new()
	cmat.albedo_color = Color(1.0, 0.95, 0.30)
	cmat.emission_enabled = true
	cmat.emission = Color(1.0, 0.95, 0.30)
	cmat.emission_energy_multiplier = 3.0
	cmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	crystal.material_override = cmat
	elder.add_child(crystal)
	# Pulse the crystal
	var pulse: Tween = create_tween().set_loops()
	pulse.tween_property(crystal, "scale", Vector3(1.30, 1.30, 1.30), 1.4).set_ease(Tween.EASE_IN_OUT)
	pulse.tween_property(crystal, "scale", Vector3(0.85, 0.85, 0.85), 1.4).set_ease(Tween.EASE_IN_OUT)
	# Name billboard
	var label: Label3D = Label3D.new()
	label.text = "Elder Mage"
	label.position = Vector3(0, 3.25, 0)
	label.modulate = Color(1.0, 0.95, 0.30)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 18
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	elder.add_child(label)


func _build_d3_perimeter_braziers(geom: Node) -> void:
	## Epic-3 T90: 6 large violet flame braziers around the perimeter of
	## D3 — taller than the inner braziers, real lighting.
	for i in 6:
		var angle: float = (float(i) / 6.0) * TAU
		var brazier: Node3D = Node3D.new()
		brazier.name = "D3PerimeterBrazier_%d" % i
		brazier.position = D3_CENTER + Vector3(cos(angle) * 22.0, 0, sin(angle) * 16.0)
		geom.add_child(brazier)
		# Tall column stem
		var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
		stone_mat.albedo_color = Color(0.16, 0.10, 0.20)
		stone_mat.metallic = 0.55
		stone_mat.roughness = 0.45
		var stem: MeshInstance3D = MeshInstance3D.new()
		var smesh: CylinderMesh = CylinderMesh.new()
		smesh.top_radius = 0.20
		smesh.bottom_radius = 0.30
		smesh.height = 2.40
		stem.mesh = smesh
		stem.position = Vector3(0, 1.20, 0)
		stem.material_override = stone_mat
		brazier.add_child(stem)
		# Bowl on top
		var bowl: MeshInstance3D = MeshInstance3D.new()
		var bmesh: CylinderMesh = CylinderMesh.new()
		bmesh.top_radius = 0.55
		bmesh.bottom_radius = 0.20
		bmesh.height = 0.30
		bowl.mesh = bmesh
		bowl.position = Vector3(0, 2.55, 0)
		bowl.material_override = stone_mat
		brazier.add_child(bowl)
		# Big violet flame
		var flame: MeshInstance3D = MeshInstance3D.new()
		var fmesh: SphereMesh = SphereMesh.new()
		fmesh.radius = 0.30
		fmesh.height = 0.60
		flame.mesh = fmesh
		flame.position = Vector3(0, 2.95, 0)
		var fmat: StandardMaterial3D = StandardMaterial3D.new()
		fmat.albedo_color = Color(1.0, 0.55, 1.0)
		fmat.emission_enabled = true
		fmat.emission = Color(1.0, 0.55, 1.0)
		fmat.emission_energy_multiplier = 3.0
		fmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		flame.material_override = fmat
		brazier.add_child(flame)
		# Pulse flame
		var pulse: Tween = create_tween().set_loops()
		pulse.tween_property(flame, "scale", Vector3(1.30, 1.30, 1.30), 0.5 + i * 0.1).set_ease(Tween.EASE_IN_OUT)
		pulse.tween_property(flame, "scale", Vector3(0.85, 0.85, 0.85), 0.5 + i * 0.1).set_ease(Tween.EASE_IN_OUT)
		# OmniLight
		var light: OmniLight3D = OmniLight3D.new()
		light.position = Vector3(0, 3.0, 0)
		light.light_color = Color(1.0, 0.55, 1.0)
		light.light_energy = 1.8
		light.omni_range = 8.0
		brazier.add_child(light)
		# Collision around stem
		var sb: StaticBody3D = StaticBody3D.new()
		var cs: CollisionShape3D = CollisionShape3D.new()
		var cap: CapsuleShape3D = CapsuleShape3D.new()
		cap.radius = 0.40
		cap.height = 2.40
		cs.shape = cap
		cs.position = Vector3(0, 1.20, 0)
		sb.add_child(cs)
		brazier.add_child(sb)


func _build_d3_astrolabe(geom: Node) -> void:
	## Epic-3 T91: an astrolabe device — stone stand with 3 nested rotating
	## torus rings (rotating around different axes) representing celestial
	## tracking.
	var astro: Node3D = Node3D.new()
	astro.name = "D3Astrolabe"
	astro.position = D3_CENTER + Vector3(8, 0, 14)
	geom.add_child(astro)
	# Stone stand
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.16, 0.10, 0.20)
	stone_mat.metallic = 0.55
	stone_mat.roughness = 0.45
	var stand: MeshInstance3D = MeshInstance3D.new()
	var sm: BoxMesh = BoxMesh.new()
	sm.size = Vector3(0.55, 1.40, 0.55)
	stand.mesh = sm
	stand.position = Vector3(0, 0.70, 0)
	stand.material_override = stone_mat
	astro.add_child(stand)
	# Pivot for rotating rings
	var pivot: Node3D = Node3D.new()
	pivot.position = Vector3(0, 1.85, 0)
	astro.add_child(pivot)
	# 3 nested torus rings rotating on different axes
	var ring_mat: StandardMaterial3D = StandardMaterial3D.new()
	ring_mat.albedo_color = Color(0.85, 0.55, 0.20)
	ring_mat.emission_enabled = true
	ring_mat.emission = Color(1.0, 0.65, 0.20)
	ring_mat.emission_energy_multiplier = 1.4
	ring_mat.metallic = 0.85
	ring_mat.roughness = 0.20
	for i in 3:
		var ring: MeshInstance3D = MeshInstance3D.new()
		var rm: TorusMesh = TorusMesh.new()
		rm.inner_radius = 0.65 - i * 0.10
		rm.outer_radius = 0.75 - i * 0.10
		ring.mesh = rm
		# Rotate each ring on a different axis
		if i == 0:
			ring.rotation = Vector3(0, 0, 0)
		elif i == 1:
			ring.rotation = Vector3(deg_to_rad(45), 0, 0)
		else:
			ring.rotation = Vector3(0, 0, deg_to_rad(45))
		ring.material_override = ring_mat
		pivot.add_child(ring)
		# Rotation tween
		var spin: Tween = create_tween().set_loops()
		var axis: String = ["rotation:y", "rotation:x", "rotation:z"][i]
		spin.tween_property(ring, axis, ring.get(axis) + TAU, 6.0 + i * 2)
	# Center sphere
	var center: MeshInstance3D = MeshInstance3D.new()
	var cm: SphereMesh = SphereMesh.new()
	cm.radius = 0.18
	cm.height = 0.36
	center.mesh = cm
	var cmat: StandardMaterial3D = StandardMaterial3D.new()
	cmat.albedo_color = Color(1.0, 0.85, 0.30)
	cmat.emission_enabled = true
	cmat.emission = Color(1.0, 0.95, 0.30)
	cmat.emission_energy_multiplier = 3.0
	cmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	center.material_override = cmat
	pivot.add_child(center)
	# Sign
	var label: Label3D = Label3D.new()
	label.text = "ASTROLABE"
	label.position = Vector3(0, 3.0, 0)
	label.modulate = Color(1.0, 0.65, 0.20)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 16
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	astro.add_child(label)
	# Collision
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(0.55, 1.40, 0.55)
	cs.shape = cb
	cs.position = Vector3(0, 0.70, 0)
	sb.add_child(cs)
	astro.add_child(sb)


func _build_d3_ingredient_shelves(geom: Node) -> void:
	## Epic-3 T92: 2 ingredient shelves stacked with colored vials in
	## small grid arrangements.
	var shelves: Node3D = Node3D.new()
	shelves.name = "D3IngredientShelves"
	shelves.position = D3_CENTER + Vector3(-15, 0, -3)
	geom.add_child(shelves)
	var wood_mat: StandardMaterial3D = StandardMaterial3D.new()
	wood_mat.albedo_color = Color(0.30, 0.18, 0.10)
	wood_mat.metallic = 0.10
	wood_mat.roughness = 0.65
	# 2 horizontal shelf boards
	for sy: float in [0.85, 1.55]:
		var shelf: MeshInstance3D = MeshInstance3D.new()
		var smesh: BoxMesh = BoxMesh.new()
		smesh.size = Vector3(2.40, 0.10, 0.40)
		shelf.mesh = smesh
		shelf.position = Vector3(0, sy, 0)
		shelf.material_override = wood_mat
		shelves.add_child(shelf)
		# 6 colored vials per shelf
		for c in 6:
			var vial: MeshInstance3D = MeshInstance3D.new()
			var vm: CylinderMesh = CylinderMesh.new()
			vm.top_radius = 0.06
			vm.bottom_radius = 0.10
			vm.height = 0.30
			vial.mesh = vm
			vial.position = Vector3(-1.0 + c * 0.40, sy + 0.20, 0)
			var color: Color = Color.from_hsv(c / 6.0, 0.65, 1.0)
			var vmat: StandardMaterial3D = StandardMaterial3D.new()
			vmat.albedo_color = color
			vmat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
			vmat.albedo_color.a = 0.85
			vmat.emission_enabled = true
			vmat.emission = color
			vmat.emission_energy_multiplier = 1.6
			vmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
			vial.material_override = vmat
			shelves.add_child(vial)
	# 2 side support posts
	for sx: float in [-1.20, 1.20]:
		var post: MeshInstance3D = MeshInstance3D.new()
		var pm: BoxMesh = BoxMesh.new()
		pm.size = Vector3(0.10, 1.85, 0.40)
		post.mesh = pm
		post.position = Vector3(sx, 0.92, 0)
		post.material_override = wood_mat
		shelves.add_child(post)
	# Collision
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(2.40, 1.85, 0.40)
	cs.shape = cb
	cs.position = Vector3(0, 0.92, 0)
	sb.add_child(cs)
	shelves.add_child(sb)


func _build_d3_planet_model(geom: Node) -> void:
	## Epic-3 T93: a floating planet model — large sphere with a torus
	## ring around it like a saturnian planet, suspended above a stand.
	var plan: Node3D = Node3D.new()
	plan.name = "D3PlanetModel"
	plan.position = D3_CENTER + Vector3(15, 0, 8)
	geom.add_child(plan)
	# Stone stand
	var stand_mat: StandardMaterial3D = StandardMaterial3D.new()
	stand_mat.albedo_color = Color(0.16, 0.10, 0.20)
	stand_mat.metallic = 0.55
	stand_mat.roughness = 0.45
	var stand: MeshInstance3D = MeshInstance3D.new()
	var sm: CylinderMesh = CylinderMesh.new()
	sm.top_radius = 0.30
	sm.bottom_radius = 0.40
	sm.height = 0.85
	stand.mesh = sm
	stand.position = Vector3(0, 0.42, 0)
	stand.material_override = stand_mat
	plan.add_child(stand)
	# Pivot for the planet
	var pivot: Node3D = Node3D.new()
	pivot.position = Vector3(0, 2.20, 0)
	plan.add_child(pivot)
	# Planet sphere
	var planet: MeshInstance3D = MeshInstance3D.new()
	var pm: SphereMesh = SphereMesh.new()
	pm.radius = 0.65
	pm.height = 1.30
	planet.mesh = pm
	var pmat: StandardMaterial3D = StandardMaterial3D.new()
	pmat.albedo_color = Color(0.30, 0.55, 1.0)
	pmat.emission_enabled = true
	pmat.emission = Color(0.55, 0.85, 1.0)
	pmat.emission_energy_multiplier = 1.4
	pmat.metallic = 0.40
	pmat.roughness = 0.30
	pmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	planet.material_override = pmat
	pivot.add_child(planet)
	# Saturn-like ring
	var ring: MeshInstance3D = MeshInstance3D.new()
	var rmesh: TorusMesh = TorusMesh.new()
	rmesh.inner_radius = 0.95
	rmesh.outer_radius = 1.20
	ring.mesh = rmesh
	ring.rotation = Vector3(deg_to_rad(20), 0, 0)
	var rmat: StandardMaterial3D = StandardMaterial3D.new()
	rmat.albedo_color = Color(0.85, 0.65, 0.30, 0.65)
	rmat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	rmat.emission_enabled = true
	rmat.emission = Color(1.0, 0.75, 0.30)
	rmat.emission_energy_multiplier = 1.8
	rmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	ring.material_override = rmat
	pivot.add_child(ring)
	# Slow rotation
	var spin: Tween = create_tween().set_loops()
	spin.tween_property(pivot, "rotation:y", TAU, 12.0)
	# Collision around stand
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cap: CapsuleShape3D = CapsuleShape3D.new()
	cap.radius = 0.45
	cap.height = 0.85
	cs.shape = cap
	cs.position = Vector3(0, 0.42, 0)
	sb.add_child(cs)
	plan.add_child(sb)


func _build_d3_time_keeper_npc() -> void:
	## Epic-3 T94: Time Keeper NPC standing by the sundial — robed figure
	## with an hourglass at the belt and a slow pendulum cane.
	var slots: Node3D = get_node_or_null("%NPCSlots") as Node3D
	if slots == null:
		return
	var keeper: Node3D = Node3D.new()
	keeper.name = "D3TimeKeeper"
	keeper.position = D3_CENTER + Vector3(-13, 0, 6)
	slots.add_child(keeper)
	# Robed body
	var bmat: StandardMaterial3D = StandardMaterial3D.new()
	bmat.albedo_color = Color(0.20, 0.30, 0.40)
	bmat.metallic = 0.20
	bmat.roughness = 0.65
	bmat.emission_enabled = true
	bmat.emission = Color(0.40, 0.55, 0.85)
	bmat.emission_energy_multiplier = 0.30
	var body: MeshInstance3D = MeshInstance3D.new()
	var bmesh: CapsuleMesh = CapsuleMesh.new()
	bmesh.radius = 0.45
	bmesh.height = 1.40
	body.mesh = bmesh
	body.position = Vector3(0, 0.70, 0)
	body.material_override = bmat
	keeper.add_child(body)
	# Hood
	var hood: MeshInstance3D = MeshInstance3D.new()
	var hmesh: SphereMesh = SphereMesh.new()
	hmesh.radius = 0.45
	hmesh.height = 0.55
	hood.mesh = hmesh
	hood.position = Vector3(0, 1.55, 0)
	hood.material_override = bmat
	keeper.add_child(hood)
	# 2 cyan eyes
	var eye_mat: StandardMaterial3D = StandardMaterial3D.new()
	eye_mat.albedo_color = Color(0.55, 0.95, 1.0)
	eye_mat.emission_enabled = true
	eye_mat.emission = Color(0.55, 0.95, 1.0)
	eye_mat.emission_energy_multiplier = 2.6
	eye_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for ex: float in [-0.10, 0.10]:
		var eye: MeshInstance3D = MeshInstance3D.new()
		var em: SphereMesh = SphereMesh.new()
		em.radius = 0.06
		em.height = 0.12
		eye.mesh = em
		eye.position = Vector3(ex, 1.40, 0.34)
		eye.material_override = eye_mat
		keeper.add_child(eye)
	# Hourglass at the belt — small box with bright sand inside
	var hourglass: MeshInstance3D = MeshInstance3D.new()
	var hgm: BoxMesh = BoxMesh.new()
	hgm.size = Vector3(0.18, 0.40, 0.18)
	hourglass.mesh = hgm
	hourglass.position = Vector3(0.36, 0.70, 0.30)
	var hgmat: StandardMaterial3D = StandardMaterial3D.new()
	hgmat.albedo_color = Color(1.0, 0.95, 0.30, 0.85)
	hgmat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	hgmat.emission_enabled = true
	hgmat.emission = Color(1.0, 0.95, 0.30)
	hgmat.emission_energy_multiplier = 1.4
	hgmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	hourglass.material_override = hgmat
	keeper.add_child(hourglass)
	# Pendulum cane held in front
	var cane_pivot: Node3D = Node3D.new()
	cane_pivot.position = Vector3(-0.40, 1.20, 0)
	keeper.add_child(cane_pivot)
	var cane: MeshInstance3D = MeshInstance3D.new()
	var cnm: CylinderMesh = CylinderMesh.new()
	cnm.top_radius = 0.04
	cnm.bottom_radius = 0.06
	cnm.height = 1.40
	cane.mesh = cnm
	cane.position = Vector3(0, -0.70, 0)
	var cnmat: StandardMaterial3D = StandardMaterial3D.new()
	cnmat.albedo_color = Color(0.30, 0.18, 0.10)
	cnmat.metallic = 0.30
	cane.material_override = cnmat
	cane_pivot.add_child(cane)
	# Pendulum sway
	var swing: Tween = create_tween().set_loops()
	swing.tween_property(cane_pivot, "rotation:z", deg_to_rad(8), 1.6).set_ease(Tween.EASE_IN_OUT)
	swing.tween_property(cane_pivot, "rotation:z", deg_to_rad(-8), 1.6).set_ease(Tween.EASE_IN_OUT)
	# Name billboard
	var label: Label3D = Label3D.new()
	label.text = "Time Keeper"
	label.position = Vector3(0, 2.20, 0)
	label.modulate = Color(0.55, 0.85, 1.0)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 18
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	keeper.add_child(label)


func _build_d3_seeker_trial(geom: Node) -> void:
	## Epic-3 T95: seeker trial — 9 small floor pads in a 3x3 grid that
	## glow in sequence (chase pattern), suggesting a "step on these in
	## the right order" puzzle.
	var trial: Node3D = Node3D.new()
	trial.name = "D3SeekerTrial"
	trial.position = D3_CENTER + Vector3(0, 0.06, 16)
	geom.add_child(trial)
	for r in 3:
		for c in 3:
			var i: int = r * 3 + c
			var pad: MeshInstance3D = MeshInstance3D.new()
			pad.name = "TrialPad_%d" % i
			var pm: BoxMesh = BoxMesh.new()
			pm.size = Vector3(0.85, 0.10, 0.85)
			pad.mesh = pm
			pad.position = Vector3(-1.20 + c * 1.20, 0, -1.20 + r * 1.20)
			var pmat: StandardMaterial3D = StandardMaterial3D.new()
			pmat.albedo_color = Color(0.16, 0.10, 0.20)
			pmat.metallic = 0.55
			pmat.roughness = 0.45
			pmat.emission_enabled = true
			pmat.emission = Color(0.85, 0.40, 1.0)
			pmat.emission_energy_multiplier = 0.45
			pad.material_override = pmat
			trial.add_child(pad)
			# Chase emission pulse
			var pulse: Tween = create_tween().set_loops()
			pulse.tween_interval(i * 0.20)
			pulse.tween_property(pmat, "emission_energy_multiplier", 3.0, 0.30).set_ease(Tween.EASE_OUT)
			pulse.tween_property(pmat, "emission_energy_multiplier", 0.45, 0.30).set_ease(Tween.EASE_IN)
			pulse.tween_interval(2.0 - i * 0.20 * 0.5)
	# Sign overhead
	var label: Label3D = Label3D.new()
	label.text = "SEEKER TRIAL"
	label.position = Vector3(0, 1.85, 0)
	label.modulate = Color(1.0, 0.55, 1.0)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 16
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	trial.add_child(label)


func _build_d3_welcome_banner(geom: Node) -> void:
	## Epic-3 T96: a wide violet welcome banner stretched between the
	## D3 entrance arch pillars at x=122 reading "MEMORY VAULT".
	var banner_root: Node3D = Node3D.new()
	banner_root.name = "D3WelcomeBanner"
	banner_root.position = Vector3(122, 0, 0)
	geom.add_child(banner_root)
	# Banner cloth
	var cloth: MeshInstance3D = MeshInstance3D.new()
	var cmesh: BoxMesh = BoxMesh.new()
	cmesh.size = Vector3(0.10, 0.95, 8.5)
	cloth.mesh = cmesh
	cloth.position = Vector3(0, 6.0, 0)
	var cmat: StandardMaterial3D = StandardMaterial3D.new()
	cmat.albedo_color = Color(0.16, 0.06, 0.30)
	cmat.emission_enabled = true
	cmat.emission = Color(0.85, 0.40, 1.0)
	cmat.emission_energy_multiplier = 1.0
	cmat.metallic = 0.10
	cmat.roughness = 0.55
	cloth.material_override = cmat
	banner_root.add_child(cloth)
	# Top + bottom emissive trim
	var trim_mat: StandardMaterial3D = StandardMaterial3D.new()
	trim_mat.albedo_color = Color(1.0, 0.55, 1.0)
	trim_mat.emission_enabled = true
	trim_mat.emission = Color(1.0, 0.55, 1.0)
	trim_mat.emission_energy_multiplier = 2.0
	trim_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for ty: float in [6.45, 5.55]:
		var trim: MeshInstance3D = MeshInstance3D.new()
		var tmesh: BoxMesh = BoxMesh.new()
		tmesh.size = Vector3(0.12, 0.08, 8.5)
		trim.mesh = tmesh
		trim.position = Vector3(0, ty, 0)
		trim.material_override = trim_mat
		banner_root.add_child(trim)
	# Welcome text — duplicated for both sides
	for fx: float in [-0.10, 0.10]:
		var label: Label3D = Label3D.new()
		label.text = "MEMORY VAULT"
		label.position = Vector3(fx, 6.0, 0)
		label.rotation = Vector3(0, deg_to_rad(-90 if fx < 0 else 90), 0)
		label.modulate = Color(1.0, 0.55, 1.0)
		label.outline_modulate = Color(0, 0, 0, 0.85)
		label.outline_size = 6
		label.font_size = 28
		label.no_depth_test = true
		banner_root.add_child(label)
	# Slow emission pulse
	var pulse: Tween = create_tween().set_loops()
	pulse.tween_property(cmat, "emission_energy_multiplier", 1.6, 2.0).set_ease(Tween.EASE_IN_OUT)
	pulse.tween_property(cmat, "emission_energy_multiplier", 0.85, 2.0).set_ease(Tween.EASE_IN_OUT)


func _build_d3_atmosphere_fog(geom: Node) -> void:
	## Epic-3 T97: ambient violet fog drifting across the entire D3 floor —
	## 80 large translucent violet puffs.
	var fog: GPUParticles3D = GPUParticles3D.new()
	fog.name = "D3AtmosphereFog"
	fog.position = D3_CENTER + Vector3(-30, 0.5, 0)
	fog.amount = 80
	fog.lifetime = 14.0
	fog.preprocess = 6.0
	var pmat: ParticleProcessMaterial = ParticleProcessMaterial.new()
	pmat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	pmat.emission_box_extents = Vector3(0.5, 0.5, 18.0)
	pmat.direction = Vector3(1, 0, 0)
	pmat.spread = 6.0
	pmat.initial_velocity_min = 0.45
	pmat.initial_velocity_max = 0.85
	pmat.gravity = Vector3.ZERO
	pmat.scale_min = 0.85
	pmat.scale_max = 1.40
	pmat.color = Color(0.85, 0.40, 1.0, 0.20)
	fog.process_material = pmat
	var puff: SphereMesh = SphereMesh.new()
	puff.radius = 0.85
	puff.height = 1.70
	var puff_mat: StandardMaterial3D = StandardMaterial3D.new()
	puff_mat.albedo_color = Color(0.85, 0.40, 1.0, 0.20)
	puff_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	puff_mat.emission_enabled = true
	puff_mat.emission = Color(1.0, 0.55, 1.0)
	puff_mat.emission_energy_multiplier = 0.55
	puff_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	puff.material = puff_mat
	fog.draw_pass_1 = puff
	geom.add_child(fog)


func _build_d3_epic3_plaque(geom: Node) -> void:
	## Epic-3 T98: a stone tablet plaque commemorating Epic 3 completion.
	var plaque: Node3D = Node3D.new()
	plaque.name = "D3Epic3Plaque"
	plaque.position = D3_CENTER + Vector3(15, 0, -3)
	geom.add_child(plaque)
	# Pedestal
	var ped_mat: StandardMaterial3D = StandardMaterial3D.new()
	ped_mat.albedo_color = Color(0.16, 0.10, 0.20)
	ped_mat.metallic = 0.55
	ped_mat.roughness = 0.45
	var ped: MeshInstance3D = MeshInstance3D.new()
	var pmesh: BoxMesh = BoxMesh.new()
	pmesh.size = Vector3(0.85, 0.50, 0.40)
	ped.mesh = pmesh
	ped.position = Vector3(0, 0.25, 0)
	ped.material_override = ped_mat
	plaque.add_child(ped)
	# Tilted stone tablet
	var tablet: MeshInstance3D = MeshInstance3D.new()
	var tmesh: BoxMesh = BoxMesh.new()
	tmesh.size = Vector3(0.85, 0.65, 0.06)
	tablet.mesh = tmesh
	tablet.position = Vector3(0, 0.85, 0)
	tablet.rotation = Vector3(deg_to_rad(-25), 0, 0)
	var tmat: StandardMaterial3D = StandardMaterial3D.new()
	tmat.albedo_color = Color(0.30, 0.20, 0.40)
	tmat.metallic = 0.65
	tmat.roughness = 0.30
	tmat.emission_enabled = true
	tmat.emission = Color(1.0, 0.55, 1.0)
	tmat.emission_energy_multiplier = 0.40
	tablet.material_override = tmat
	plaque.add_child(tablet)
	# Engraved text
	var label: Label3D = Label3D.new()
	label.text = "EPIC 03\nMEMORY VAULT\nCOMPLETE"
	label.position = Vector3(0, 0.95, 0.18)
	label.rotation = Vector3(deg_to_rad(-25), 0, 0)
	label.modulate = Color(1.0, 0.55, 1.0)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 4
	label.font_size = 14
	label.no_depth_test = true
	plaque.add_child(label)
	# Collision
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(0.85, 0.60, 0.40)
	cs.shape = cb
	cs.position = Vector3(0, 0.30, 0)
	sb.add_child(cs)
	plaque.add_child(sb)


func _build_d3_ambient_fills(geom: Node) -> void:
	## Epic-3 T99: 3 high violet-tinted OmniLight3D fill lights spaced
	## along the D3 length lifting overall light level.
	var positions: Array[Vector3] = [
		D3_CENTER + Vector3(-15, 8, 0),
		D3_CENTER + Vector3(0, 8, 0),
		D3_CENTER + Vector3(15, 8, 0),
	]
	for i in positions.size():
		var fill: OmniLight3D = OmniLight3D.new()
		fill.name = "D3FillLight_%d" % i
		fill.position = positions[i]
		fill.light_color = Color(0.85, 0.55, 1.0)
		fill.light_energy = 1.4
		fill.omni_range = 24.0
		fill.omni_attenuation = 1.6
		geom.add_child(fill)


func _build_d3_arcane_overseer_landmark(geom: Node) -> void:
	## Epic-3 T100 (FINALE): a massive ARCANE OVERSEER landmark hovering
	## 14m above the D3 center — translucent violet humanoid + 8 orbital
	## rune cubes + ground halo + real OmniLight3D casting violet over the
	## entire district. The Memory Vault equivalent of D1's Globbler and
	## D2's Glitch Herald.
	var landmark: Node3D = Node3D.new()
	landmark.name = "D3ArcaneOverseerLandmark"
	landmark.position = D3_CENTER + Vector3(0, 14, 0)
	geom.add_child(landmark)
	var pivot: Node3D = Node3D.new()
	pivot.name = "RotationPivot"
	landmark.add_child(pivot)
	# Translucent humanoid body
	var holo_mat: StandardMaterial3D = StandardMaterial3D.new()
	holo_mat.albedo_color = Color(0.85, 0.55, 1.0, 0.45)
	holo_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	holo_mat.emission_enabled = true
	holo_mat.emission = Color(1.0, 0.55, 1.0)
	holo_mat.emission_energy_multiplier = 2.4
	holo_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	# Body capsule
	var body: MeshInstance3D = MeshInstance3D.new()
	var bmesh: CapsuleMesh = CapsuleMesh.new()
	bmesh.radius = 0.95
	bmesh.height = 2.85
	body.mesh = bmesh
	body.position = Vector3(0, 0, 0)
	body.material_override = holo_mat
	pivot.add_child(body)
	# Head sphere
	var head: MeshInstance3D = MeshInstance3D.new()
	var hmesh: SphereMesh = SphereMesh.new()
	hmesh.radius = 0.85
	hmesh.height = 1.70
	head.mesh = hmesh
	head.position = Vector3(0, 2.20, 0)
	head.material_override = holo_mat
	pivot.add_child(head)
	# 3 huge glowing white eyes (cyclops + 2 — overseer style)
	var eye_mat: StandardMaterial3D = StandardMaterial3D.new()
	eye_mat.albedo_color = Color(1, 1, 1, 0.9)
	eye_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	eye_mat.emission_enabled = true
	eye_mat.emission = Color(1, 1, 1)
	eye_mat.emission_energy_multiplier = 4.0
	eye_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for spec in [Vector3(-0.40, 2.30, 0.65), Vector3(0.40, 2.30, 0.65), Vector3(0, 2.65, 0.75)]:
		var eye: MeshInstance3D = MeshInstance3D.new()
		var em: SphereMesh = SphereMesh.new()
		em.radius = 0.22
		em.height = 0.44
		eye.mesh = em
		eye.position = spec
		eye.material_override = eye_mat
		pivot.add_child(eye)
	# 8 orbital rune cubes circling at body height
	for i in 8:
		var angle: float = (float(i) / 8.0) * TAU
		var rune: MeshInstance3D = MeshInstance3D.new()
		var rmesh: BoxMesh = BoxMesh.new()
		rmesh.size = Vector3(0.40, 0.40, 0.40)
		rune.mesh = rmesh
		rune.position = Vector3(cos(angle) * 2.85, sin(float(i) * 0.85) * 0.55, sin(angle) * 2.85)
		rune.rotation = Vector3(0, -angle, deg_to_rad(15))
		var rmat: StandardMaterial3D = StandardMaterial3D.new()
		rmat.albedo_color = Color(1.0, 0.55, 1.0)
		rmat.emission_enabled = true
		rmat.emission = Color(1.0, 0.55, 1.0)
		rmat.emission_energy_multiplier = 2.6
		rmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		rune.material_override = rmat
		pivot.add_child(rune)
	# Slow main rotation
	var spin: Tween = create_tween().set_loops()
	spin.tween_property(pivot, "rotation:y", TAU, 18.0)
	# Bobbing in place
	var bob: Tween = create_tween().set_loops()
	bob.tween_property(landmark, "position:y", 15.0, 3.0).set_ease(Tween.EASE_IN_OUT)
	bob.tween_property(landmark, "position:y", 14.0, 3.0).set_ease(Tween.EASE_IN_OUT)
	# Ground halo beneath the landmark
	var halo: MeshInstance3D = MeshInstance3D.new()
	var hmesh2: TorusMesh = TorusMesh.new()
	hmesh2.inner_radius = 4.5
	hmesh2.outer_radius = 5.0
	halo.mesh = hmesh2
	halo.position = D3_CENTER + Vector3(0, 0.06, 0)
	var hmat2: StandardMaterial3D = StandardMaterial3D.new()
	hmat2.albedo_color = Color(1.0, 0.55, 1.0)
	hmat2.emission_enabled = true
	hmat2.emission = Color(1.0, 0.55, 1.0)
	hmat2.emission_energy_multiplier = 2.4
	hmat2.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	halo.material_override = hmat2
	geom.add_child(halo)
	var halo_pulse: Tween = create_tween().set_loops()
	halo_pulse.tween_property(halo, "scale", Vector3(1.20, 1.0, 1.20), 2.0).set_ease(Tween.EASE_IN_OUT)
	halo_pulse.tween_property(halo, "scale", Vector3(1.0, 1.0, 1.0), 2.0).set_ease(Tween.EASE_IN_OUT)
	# Real OmniLight at the landmark casting violet over the district
	var landmark_light: OmniLight3D = OmniLight3D.new()
	landmark_light.position = Vector3(0, 0, 0)
	landmark_light.light_color = Color(1.0, 0.55, 1.0)
	landmark_light.light_energy = 3.5
	landmark_light.omni_range = 30.0
	landmark_light.omni_attenuation = 1.4
	pivot.add_child(landmark_light)
	# ARCANE OVERSEER billboard
	var label: Label3D = Label3D.new()
	label.text = "ARCANE OVERSEER"
	label.position = Vector3(0, 4.40, 0)
	label.modulate = Color(1.0, 0.55, 1.0)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 6
	label.font_size = 26
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	landmark.add_child(label)




const D2_CENTER := Vector3(85, 0, 0)


func _unlock_east_gate_and_extend(geom: Node) -> void:
	## Epic-2 T1: disable the locked east gate forcefield (player can now
	## walk through), push the east boundary wall from x=70 to x=120 to
	## make room for District 2.
	# Find the east gate node
	var gate: Node = geom.get_node_or_null("EastPlazaEastGate")
	if gate:
		# Remove the forcefield collision so the player can pass
		var field: MeshInstance3D = gate.get_node_or_null("GateForceField") as MeshInstance3D
		if field:
			# Make it a translucent decorative shimmer instead of solid
			field.scale = Vector3(1.0, 1.0, 0.05)
			# Remove all StaticBody3D children of the gate (which include the
			# forcefield collider and the pillar colliders — keep pillars by
			# rebuilding their colliders selectively below)
			pass
		# The locked sign should change to "UNLOCKED"
		for child in gate.get_children():
			if child is Label3D:
				(child as Label3D).text = "DISTRICT 2\nSECTOR OPEN"
				(child as Label3D).modulate = Color(0.40, 1.0, 0.55)
		# Find the gate forcefield static body and remove it specifically.
		# The pillar bodies are also static bodies but we want to keep those.
		# Strategy: walk the gate's children, find StaticBody3Ds with a single
		# BoxShape3D matching the field collider size (5.6 x 6.2 x 0.5).
		var to_remove: Array[Node] = []
		for child in gate.get_children():
			if child is StaticBody3D:
				for shape_child in (child as StaticBody3D).get_children():
					if shape_child is CollisionShape3D:
						var shp: Shape3D = (shape_child as CollisionShape3D).shape
						if shp is BoxShape3D:
							var sz: Vector3 = (shp as BoxShape3D).size
							if sz.x == 5.6 and sz.y == 6.2 and sz.z == 0.5:
								to_remove.append(child)
		for body in to_remove:
			body.queue_free()
	# Push the boundary east wall
	var east_wall: CSGBox3D = geom.get_node_or_null("BoundaryEast") as CSGBox3D
	if east_wall:
		east_wall.position.x = 120.0


func _build_d2_ground(geom: Node) -> void:
	## Epic-2 T2: District 2 ground — darker amber/red cracked digital floor
	## extending from x=68 to x=118. Uses a different shader variant to
	## visually distinguish from the cyan East Plaza tiles.
	var plane: PlaneMesh = PlaneMesh.new()
	plane.size = Vector2(50, 40)
	var ground: MeshInstance3D = MeshInstance3D.new()
	ground.name = "D2Ground"
	ground.mesh = plane
	ground.position = Vector3(93, 0, 0)
	# Reuse a tweaked version of the digital grid shader — amber instead of cyan
	var shader: Shader = Shader.new()
	shader.code = """
shader_type spatial;
render_mode unshaded;
uniform vec3 base_color = vec3(0.10, 0.06, 0.04);
uniform vec3 grid_color = vec3(1.00, 0.40, 0.10);
uniform float grid_scale = 1.4;
uniform float line_width = 0.04;

void fragment() {
	vec2 uv = UV * grid_scale * 30.0;
	vec2 grid = abs(fract(uv - 0.5) - 0.5) / fwidth(uv);
	float line = min(grid.x, grid.y);
	float strength = 1.0 - min(line, 1.0);
	vec3 color = mix(base_color, grid_color, strength * 0.85);
	ALBEDO = color;
}
"""
	var smat: ShaderMaterial = ShaderMaterial.new()
	smat.shader = shader
	ground.material_override = smat
	geom.add_child(ground)
	# StaticBody for ground collision so player doesn't fall through
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var bs: BoxShape3D = BoxShape3D.new()
	bs.size = Vector3(50, 0.10, 40)
	cs.shape = bs
	cs.position = Vector3(0, -0.05, 0)
	sb.add_child(cs)
	ground.add_child(sb)


func _build_d2_entrance_arch(geom: Node) -> void:
	## Epic-2 T3: a wide cracked stone arch at the D2 entrance (just east of
	## the unlocked plaza gate) reading "STACK OVERFLOW OUTSKIRTS".
	var arch: Node3D = Node3D.new()
	arch.name = "D2EntranceArch"
	arch.position = Vector3(70, 0, 0)
	geom.add_child(arch)
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.16, 0.10, 0.06)
	stone_mat.metallic = 0.45
	stone_mat.roughness = 0.65
	stone_mat.emission_enabled = true
	stone_mat.emission = Color(0.85, 0.30, 0.10)
	stone_mat.emission_energy_multiplier = 0.30
	# 2 wide pillars
	for sx: float in [-4.0, 4.0]:
		var pillar: MeshInstance3D = MeshInstance3D.new()
		var pmesh: BoxMesh = BoxMesh.new()
		pmesh.size = Vector3(1.6, 7.5, 1.6)
		pillar.mesh = pmesh
		pillar.position = Vector3(sx, 3.75, 0)
		pillar.material_override = stone_mat
		arch.add_child(pillar)
		# Cracked emissive stripe
		var crack: MeshInstance3D = MeshInstance3D.new()
		var cmesh: BoxMesh = BoxMesh.new()
		cmesh.size = Vector3(0.06, 6.0, 1.7)
		crack.mesh = cmesh
		crack.position = Vector3(sx + (-0.81 if sx < 0 else 0.81), 3.5, 0)
		var crack_mat: StandardMaterial3D = StandardMaterial3D.new()
		crack_mat.albedo_color = Color(1.0, 0.40, 0.20)
		crack_mat.emission_enabled = true
		crack_mat.emission = Color(1.0, 0.55, 0.20)
		crack_mat.emission_energy_multiplier = 1.8
		crack_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		crack.material_override = crack_mat
		arch.add_child(crack)
		# Collision
		var sb: StaticBody3D = StaticBody3D.new()
		var cs: CollisionShape3D = CollisionShape3D.new()
		var cb: BoxShape3D = BoxShape3D.new()
		cb.size = Vector3(1.6, 7.5, 1.6)
		cs.shape = cb
		cs.position = Vector3(sx, 3.75, 0)
		sb.add_child(cs)
		arch.add_child(sb)
	# Lintel
	var lintel: MeshInstance3D = MeshInstance3D.new()
	var lmesh: BoxMesh = BoxMesh.new()
	lmesh.size = Vector3(9.5, 1.40, 1.60)
	lintel.mesh = lmesh
	lintel.position = Vector3(0, 8.20, 0)
	lintel.material_override = stone_mat
	arch.add_child(lintel)
	# Big district name on the lintel
	for fz: float in [-0.81, 0.81]:
		var label: Label3D = Label3D.new()
		label.text = "STACK OVERFLOW\nOUTSKIRTS"
		label.position = Vector3(0, 8.20, fz)
		label.rotation = Vector3(0, deg_to_rad(0 if fz > 0 else 180), 0)
		label.modulate = Color(1.0, 0.55, 0.20)
		label.outline_modulate = Color(0, 0, 0, 0.85)
		label.outline_size = 6
		label.font_size = 22
		label.no_depth_test = true
		arch.add_child(label)


func _build_d2_broken_tower(geom: Node) -> void:
	## Epic-2 T4: a tall broken data tower as the first D2 landmark. Stone
	## column with a snapped top, glowing internal "wires" exposed, leaning
	## slightly. Sells "this district is in disrepair".
	var tower: Node3D = Node3D.new()
	tower.name = "D2BrokenTower"
	tower.position = D2_CENTER + Vector3(-8, 0, -10)
	tower.rotation = Vector3(deg_to_rad(8), 0, deg_to_rad(-5))
	geom.add_child(tower)
	# Lower intact column
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.18, 0.14, 0.10)
	stone_mat.metallic = 0.45
	stone_mat.roughness = 0.55
	var lower: MeshInstance3D = MeshInstance3D.new()
	var lmesh: CylinderMesh = CylinderMesh.new()
	lmesh.top_radius = 0.95
	lmesh.bottom_radius = 1.10
	lmesh.height = 6.0
	lower.mesh = lmesh
	lower.position = Vector3(0, 3.0, 0)
	lower.material_override = stone_mat
	tower.add_child(lower)
	# Broken jagged top piece (smaller cylinder)
	var top: MeshInstance3D = MeshInstance3D.new()
	var tmesh: CylinderMesh = CylinderMesh.new()
	tmesh.top_radius = 0.40
	tmesh.bottom_radius = 0.85
	tmesh.height = 2.5
	top.mesh = tmesh
	top.position = Vector3(0, 7.25, 0)
	top.rotation = Vector3(deg_to_rad(15), deg_to_rad(20), deg_to_rad(-10))
	top.material_override = stone_mat
	tower.add_child(top)
	# Exposed glowing internal wires — 4 thin emissive bars protruding
	var wire_mat: StandardMaterial3D = StandardMaterial3D.new()
	wire_mat.albedo_color = Color(1.0, 0.40, 0.20)
	wire_mat.emission_enabled = true
	wire_mat.emission = Color(1.0, 0.55, 0.20)
	wire_mat.emission_energy_multiplier = 2.4
	wire_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for w in 4:
		var wire: MeshInstance3D = MeshInstance3D.new()
		var wmesh: CylinderMesh = CylinderMesh.new()
		wmesh.top_radius = 0.04
		wmesh.bottom_radius = 0.04
		wmesh.height = 1.4
		wire.mesh = wmesh
		var angle: float = (float(w) / 4.0) * TAU
		wire.position = Vector3(cos(angle) * 0.3, 6.4, sin(angle) * 0.3)
		wire.rotation = Vector3(deg_to_rad(randf_range(-30, 30)), 0, deg_to_rad(randf_range(-30, 30)))
		wire.material_override = wire_mat
		tower.add_child(wire)
	# Sparking glowing core at the break point
	var core: MeshInstance3D = MeshInstance3D.new()
	var cmesh: SphereMesh = SphereMesh.new()
	cmesh.radius = 0.30
	cmesh.height = 0.60
	core.mesh = cmesh
	core.position = Vector3(0, 6.10, 0)
	var cmat: StandardMaterial3D = StandardMaterial3D.new()
	cmat.albedo_color = Color(1.0, 0.85, 0.30)
	cmat.emission_enabled = true
	cmat.emission = Color(1.0, 0.95, 0.40)
	cmat.emission_energy_multiplier = 2.6
	cmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	core.material_override = cmat
	tower.add_child(core)
	# Spark particle burst from the core
	var sparks: GPUParticles3D = GPUParticles3D.new()
	sparks.amount = 30
	sparks.lifetime = 0.85
	sparks.position = Vector3(0, 6.10, 0)
	var pmat: ParticleProcessMaterial = ParticleProcessMaterial.new()
	pmat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	pmat.emission_sphere_radius = 0.20
	pmat.direction = Vector3(0, 1, 0)
	pmat.spread = 80.0
	pmat.initial_velocity_min = 1.5
	pmat.initial_velocity_max = 3.0
	pmat.gravity = Vector3(0, -3.5, 0)
	pmat.scale_min = 0.05
	pmat.scale_max = 0.10
	pmat.color = Color(1.0, 0.85, 0.30, 1.0)
	sparks.process_material = pmat
	var spark_mesh: SphereMesh = SphereMesh.new()
	spark_mesh.radius = 0.05
	spark_mesh.height = 0.10
	var spark_mat: StandardMaterial3D = StandardMaterial3D.new()
	spark_mat.albedo_color = Color(1.0, 0.85, 0.30)
	spark_mat.emission_enabled = true
	spark_mat.emission = Color(1.0, 0.95, 0.40)
	spark_mat.emission_energy_multiplier = 2.5
	spark_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	spark_mesh.material = spark_mat
	sparks.draw_pass_1 = spark_mesh
	tower.add_child(sparks)
	# Pulse the core
	var pulse: Tween = create_tween().set_loops()
	pulse.tween_property(core, "scale", Vector3(1.30, 1.30, 1.30), 0.45).set_ease(Tween.EASE_IN_OUT)
	pulse.tween_property(core, "scale", Vector3(1.0, 1.0, 1.0), 0.45).set_ease(Tween.EASE_IN_OUT)
	# Collision around the column
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cap: CapsuleShape3D = CapsuleShape3D.new()
	cap.radius = 1.10
	cap.height = 6.0
	cs.shape = cap
	cs.position = Vector3(0, 3.0, 0)
	sb.add_child(cs)
	tower.add_child(sb)


func _build_d2_survivor_npc() -> void:
	## Epic-2 T5: wandering survivor NPC in the D2 entrance area. Hooded
	## procedural figure with a worn cyan cloak, slowly walking back and
	## forth on a patrol tween. The first inhabitant of District 2.
	var slots: Node3D = get_node_or_null("%NPCSlots") as Node3D
	if slots == null:
		return
	var survivor: Node3D = Node3D.new()
	survivor.name = "D2Survivor"
	survivor.position = D2_CENTER + Vector3(-12, 0, 4)
	slots.add_child(survivor)
	# Body capsule — worn brown cloak
	var body: MeshInstance3D = MeshInstance3D.new()
	var bmesh: CapsuleMesh = CapsuleMesh.new()
	bmesh.radius = 0.42
	bmesh.height = 1.20
	body.mesh = bmesh
	body.position = Vector3(0, 0.65, 0)
	var bmat: StandardMaterial3D = StandardMaterial3D.new()
	bmat.albedo_color = Color(0.30, 0.25, 0.20)
	bmat.metallic = 0.10
	bmat.roughness = 0.65
	body.material_override = bmat
	survivor.add_child(body)
	# Hood — wider half sphere on top
	var hood: MeshInstance3D = MeshInstance3D.new()
	var hmesh: SphereMesh = SphereMesh.new()
	hmesh.radius = 0.45
	hmesh.height = 0.55
	hood.mesh = hmesh
	hood.position = Vector3(0, 1.45, 0)
	var hmat: StandardMaterial3D = StandardMaterial3D.new()
	hmat.albedo_color = Color(0.20, 0.16, 0.12)
	hmat.metallic = 0.10
	hmat.roughness = 0.70
	hood.material_override = hmat
	survivor.add_child(hood)
	# 2 dim cyan eyes peeking from the hood shadow
	var eye_mat: StandardMaterial3D = StandardMaterial3D.new()
	eye_mat.albedo_color = Color(0.30, 0.85, 1.0)
	eye_mat.emission_enabled = true
	eye_mat.emission = Color(0.30, 0.85, 1.0)
	eye_mat.emission_energy_multiplier = 1.8
	eye_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for ex: float in [-0.10, 0.10]:
		var eye: MeshInstance3D = MeshInstance3D.new()
		var emesh: SphereMesh = SphereMesh.new()
		emesh.radius = 0.05
		emesh.height = 0.10
		eye.mesh = emesh
		eye.position = Vector3(ex, 1.30, 0.30)
		eye.material_override = eye_mat
		survivor.add_child(eye)
	# Walking stick
	var stick: MeshInstance3D = MeshInstance3D.new()
	var smesh: CylinderMesh = CylinderMesh.new()
	smesh.top_radius = 0.04
	smesh.bottom_radius = 0.05
	smesh.height = 1.6
	stick.mesh = smesh
	stick.position = Vector3(0.45, 0.80, 0)
	var stmat: StandardMaterial3D = StandardMaterial3D.new()
	stmat.albedo_color = Color(0.25, 0.18, 0.10)
	stick.material_override = stmat
	survivor.add_child(stick)
	# Stick tip glow
	var tip: MeshInstance3D = MeshInstance3D.new()
	var tip_mesh: SphereMesh = SphereMesh.new()
	tip_mesh.radius = 0.10
	tip_mesh.height = 0.20
	tip.mesh = tip_mesh
	tip.position = Vector3(0.45, 1.65, 0)
	var tip_mat: StandardMaterial3D = StandardMaterial3D.new()
	tip_mat.albedo_color = Color(0.30, 0.85, 1.0)
	tip_mat.emission_enabled = true
	tip_mat.emission = Color(0.55, 0.95, 1.0)
	tip_mat.emission_energy_multiplier = 2.4
	tip_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	tip.material_override = tip_mat
	survivor.add_child(tip)
	# Name billboard
	var label: Label3D = Label3D.new()
	label.text = "Wanderer"
	label.position = Vector3(0, 1.95, 0)
	label.modulate = Color(0.85, 0.85, 0.55)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 18
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	survivor.add_child(label)
	# Walking patrol tween
	var origin: Vector3 = D2_CENTER + Vector3(-12, 0, 4)
	var patrol: Tween = create_tween().set_loops()
	patrol.tween_property(survivor, "rotation:y", deg_to_rad(90), 0.4)
	patrol.tween_property(survivor, "position", origin + Vector3(0, 0, 6), 5.0)
	patrol.tween_property(survivor, "rotation:y", deg_to_rad(-90), 0.4)
	patrol.tween_property(survivor, "position", origin, 5.0)


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
		var hue: Color = [Color(0.85, 0.20, 0.30), Color(0.20, 0.50, 0.85), Color(0.85, 0.65, 0.20)][i]
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


func _build_tournament_leaderboard(geom: Node) -> void:
	## Epic-1 T41: tall leaderboard panel next to the tournament pit
	var lb: Node3D = Node3D.new()
	lb.name = "EastPlazaLeaderboard"
	lb.position = Vector3(44, 0, 14)
	geom.add_child(lb)
	# Backboard
	var back: MeshInstance3D = MeshInstance3D.new()
	var bmesh: BoxMesh = BoxMesh.new()
	bmesh.size = Vector3(0.10, 3.0, 2.0)
	back.mesh = bmesh
	back.position = Vector3(0, 1.7, 0)
	var bmat: StandardMaterial3D = StandardMaterial3D.new()
	bmat.albedo_color = Color(0.18, 0.10, 0.04)
	bmat.emission_enabled = true
	bmat.emission = Color(0.85, 0.30, 0.10)
	bmat.emission_energy_multiplier = 0.55
	bmat.metallic = 0.4
	back.material_override = bmat
	lb.add_child(back)
	# Header label
	var header: Label3D = Label3D.new()
	header.text = "TOP RUNNERS"
	header.position = Vector3(0.07, 2.9, 0)
	header.rotation_degrees = Vector3(0, 90, 0)
	header.modulate = Color(1.0, 0.55, 0.20)
	header.outline_modulate = Color(0, 0, 0, 0.95)
	header.outline_size = 7
	header.font_size = 22
	header.no_depth_test = true
	lb.add_child(header)
	# 5 mock entries
	var entries: Array[String] = [
		"1. Cipher    99",
		"2. Globbler  87",
		"3. Forge     74",
		"4. Pixel     61",
		"5. Index     53",
	]
	for i in entries.size():
		var line: Label3D = Label3D.new()
		line.text = entries[i]
		line.position = Vector3(0.07, 2.4 - i * 0.4, 0)
		line.rotation_degrees = Vector3(0, 90, 0)
		line.modulate = Color(1.0, 0.95, 0.85)
		line.outline_modulate = Color(0, 0.05, 0.10, 0.95)
		line.outline_size = 5
		line.font_size = 18
		line.no_depth_test = true
		lb.add_child(line)
	# Collision
	var sb: StaticBody3D = StaticBody3D.new()
	var col_shape: CollisionShape3D = CollisionShape3D.new()
	var col_box: BoxShape3D = BoxShape3D.new()
	col_box.size = Vector3(0.4, 3.0, 2.0)
	col_shape.shape = col_box
	col_shape.position = Vector3(0, 1.7, 0)
	sb.add_child(col_shape)
	lb.add_child(sb)


func _build_tournament_gate(geom: Node) -> void:
	## Epic-1 T42: portcullis-style gate above the tournament pit entrance
	var gate: Node3D = Node3D.new()
	gate.name = "EastPlazaTournamentGate"
	gate.position = Vector3(36, 0, 14)
	geom.add_child(gate)
	# 2 vertical pillars
	var pillar_mat: StandardMaterial3D = StandardMaterial3D.new()
	pillar_mat.albedo_color = Color(0.12, 0.18, 0.26)
	pillar_mat.emission_enabled = true
	pillar_mat.emission = Color(1.0, 0.30, 0.20)
	pillar_mat.emission_energy_multiplier = 0.7
	pillar_mat.metallic = 0.7
	for z_offset: float in [-2.5, 2.5]:
		var pillar: MeshInstance3D = MeshInstance3D.new()
		var pmesh: BoxMesh = BoxMesh.new()
		pmesh.size = Vector3(0.4, 3.5, 0.4)
		pillar.mesh = pmesh
		pillar.position = Vector3(0, 1.75, z_offset)
		pillar.material_override = pillar_mat
		gate.add_child(pillar)
		# Pillar collision
		var sb: StaticBody3D = StaticBody3D.new()
		var col_shape: CollisionShape3D = CollisionShape3D.new()
		var col_box: BoxShape3D = BoxShape3D.new()
		col_box.size = Vector3(0.4, 3.5, 0.4)
		col_shape.shape = col_box
		col_shape.position = Vector3(0, 1.75, z_offset)
		sb.add_child(col_shape)
		gate.add_child(sb)
	# Top crossbar
	var top: MeshInstance3D = MeshInstance3D.new()
	var tmesh: BoxMesh = BoxMesh.new()
	tmesh.size = Vector3(0.4, 0.4, 5.5)
	top.mesh = tmesh
	top.position = Vector3(0, 3.5, 0)
	top.material_override = pillar_mat
	gate.add_child(top)
	# 5 hanging vertical bars (portcullis)
	for i in range(0, 5):
		var bar: MeshInstance3D = MeshInstance3D.new()
		var bmesh: BoxMesh = BoxMesh.new()
		bmesh.size = Vector3(0.10, 1.5, 0.10)
		bar.mesh = bmesh
		bar.position = Vector3(0, 2.5, -2.0 + i * 1.0)
		bar.material_override = pillar_mat
		gate.add_child(bar)


func _build_perimeter_seating(geom: Node) -> void:
	## Epic-1 T43: long perimeter seating wall — 6 long benches around the
	## plaza edges (mostly cosmetic)
	var bench_mat: StandardMaterial3D = StandardMaterial3D.new()
	bench_mat.albedo_color = Color(0.10, 0.18, 0.26)
	bench_mat.emission_enabled = true
	bench_mat.emission = Color(0.20, 0.55, 0.75)
	bench_mat.emission_energy_multiplier = 0.5
	bench_mat.metallic = 0.55
	var bench_positions: Array[Vector3] = [
		Vector3(34, 0, -18), Vector3(34, 0, 18),
		Vector3(22.5, 0, -16), Vector3(22.5, 0, 16),
		Vector3(43.5, 0, -16), Vector3(43.5, 0, 16),
	]
	for pos in bench_positions:
		var bench: MeshInstance3D = MeshInstance3D.new()
		var bmesh: BoxMesh = BoxMesh.new()
		bmesh.size = Vector3(3.0, 0.4, 0.7)
		bench.mesh = bmesh
		bench.position = pos + Vector3(0, 0.2, 0)
		bench.material_override = bench_mat
		geom.add_child(bench)
		# Collision
		var sb: StaticBody3D = StaticBody3D.new()
		var col_shape: CollisionShape3D = CollisionShape3D.new()
		var col_box: BoxShape3D = BoxShape3D.new()
		col_box.size = Vector3(3.0, 0.4, 0.7)
		col_shape.shape = col_box
		col_shape.position = pos + Vector3(0, 0.2, 0)
		sb.add_child(col_shape)
		geom.add_child(sb)


func _build_gate_guards() -> void:
	## Epic-1 T44: 2 gate guard NPCs flanking the west arch entrance
	for entry in [
		[Vector3(20, 0.5, -2.5), "Gate Guard A", Color(0.30, 0.65, 0.95)],
		[Vector3(20, 0.5, 2.5), "Gate Guard B", Color(0.30, 0.65, 0.95)],
	]:
		var pos: Vector3 = entry[0]
		var name: String = entry[1]
		var hue: Color = entry[2]
		var guard: Node3D = Node3D.new()
		guard.name = "EastPlazaGuard_" + name.replace(" ", "")
		guard.position = pos
		add_child(guard)
		var body: MeshInstance3D = MeshInstance3D.new()
		var sphere: SphereMesh = SphereMesh.new()
		sphere.radius = 0.40
		sphere.height = 0.80
		body.mesh = sphere
		var mat: StandardMaterial3D = StandardMaterial3D.new()
		mat.albedo_color = hue
		mat.emission_enabled = true
		mat.emission = hue * 1.4
		mat.emission_energy_multiplier = 0.6
		mat.metallic = 0.5
		body.material_override = mat
		guard.add_child(body)
		# Helmet
		var helm: MeshInstance3D = MeshInstance3D.new()
		var hmesh: SphereMesh = SphereMesh.new()
		hmesh.radius = 0.25
		hmesh.height = 0.50
		helm.mesh = hmesh
		helm.position = Vector3(0, 0.40, 0)
		var hmat: StandardMaterial3D = StandardMaterial3D.new()
		hmat.albedo_color = Color(0.12, 0.20, 0.30)
		hmat.metallic = 0.85
		hmat.roughness = 0.3
		helm.material_override = hmat
		guard.add_child(helm)
		# Visor stripe
		var visor: MeshInstance3D = MeshInstance3D.new()
		var vmesh: BoxMesh = BoxMesh.new()
		vmesh.size = Vector3(0.45, 0.06, 0.04)
		visor.mesh = vmesh
		visor.position = Vector3(0, 0.42, -0.23)
		var vmat: StandardMaterial3D = StandardMaterial3D.new()
		vmat.albedo_color = Color(0.30, 0.85, 1.0)
		vmat.emission_enabled = true
		vmat.emission = Color(0.40, 0.95, 1.0)
		vmat.emission_energy_multiplier = 2.5
		vmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		visor.material_override = vmat
		guard.add_child(visor)
		# Name label
		var label: Label3D = Label3D.new()
		label.text = name
		label.position = Vector3(0, 1.4, 0)
		label.modulate = Color(0.55, 0.85, 1.0)
		label.outline_modulate = Color(0, 0, 0, 0.85)
		label.outline_size = 5
		label.font_size = 18
		label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		guard.add_child(label)


func _build_cipher_orbs(geom: Node) -> void:
	## Epic-1 T45: 6 floating cipher data orbs drifting through the plaza —
	## small bright violet spheres on individual bob+drift tweens
	for i: int in 6:
		var orb: MeshInstance3D = MeshInstance3D.new()
		orb.name = "EastPlazaCipherOrb_%d" % i
		var omesh: SphereMesh = SphereMesh.new()
		omesh.radius = 0.10
		omesh.height = 0.20
		orb.mesh = omesh
		var origin := Vector3(26 + i * 2.5, 1.5 + (i % 2) * 0.8, -8 + (i % 3) * 6)
		orb.position = origin
		var mat: StandardMaterial3D = StandardMaterial3D.new()
		mat.albedo_color = Color(0.85, 0.40, 1.0)
		mat.emission_enabled = true
		mat.emission = Color(0.95, 0.55, 1.0)
		mat.emission_energy_multiplier = 2.5
		mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		orb.material_override = mat
		geom.add_child(orb)
		# Drift tween — slow continuous motion
		var tween: Tween = create_tween().set_loops()
		var drift1 := origin + Vector3(randf_range(-3, 3), randf_range(-0.4, 0.4), randf_range(-3, 3))
		var drift2 := origin + Vector3(randf_range(-3, 3), randf_range(-0.4, 0.4), randf_range(-3, 3))
		tween.tween_property(orb, "position", drift1, randf_range(5, 8)).set_ease(Tween.EASE_IN_OUT)
		tween.tween_property(orb, "position", drift2, randf_range(5, 8)).set_ease(Tween.EASE_IN_OUT)
		tween.tween_property(orb, "position", origin, randf_range(5, 8)).set_ease(Tween.EASE_IN_OUT)


func _build_quest_board(geom: Node) -> void:
	## Epic-1 T36: quest bulletin board at (24, 0, -8) with 3 mock quest entries
	var board: Node3D = Node3D.new()
	board.name = "EastPlazaQuestBoard"
	board.position = Vector3(24, 0, -8)
	geom.add_child(board)
	# Backboard panel
	var back: MeshInstance3D = MeshInstance3D.new()
	var bmesh: BoxMesh = BoxMesh.new()
	bmesh.size = Vector3(1.6, 1.8, 0.10)
	back.mesh = bmesh
	back.position = Vector3(0, 1.4, 0)
	var bmat: StandardMaterial3D = StandardMaterial3D.new()
	bmat.albedo_color = Color(0.18, 0.10, 0.04)
	bmat.emission_enabled = true
	bmat.emission = Color(0.65, 0.40, 0.10)
	bmat.emission_energy_multiplier = 0.5
	bmat.metallic = 0.4
	back.material_override = bmat
	board.add_child(back)
	# 3 mock quest "papers" (small glowing rectangles)
	var quest_titles: Array[String] = [
		"Bug Hunt: 5 Glitches",
		"Cipher's Errand",
		"Collect 10 Data Shards",
	]
	for i in quest_titles.size():
		var paper: MeshInstance3D = MeshInstance3D.new()
		var pmesh: BoxMesh = BoxMesh.new()
		pmesh.size = Vector3(1.3, 0.35, 0.02)
		paper.mesh = pmesh
		paper.position = Vector3(0, 2.0 - i * 0.45, -0.06)
		var pmat: StandardMaterial3D = StandardMaterial3D.new()
		pmat.albedo_color = Color(0.95, 0.85, 0.55)
		pmat.emission_enabled = true
		pmat.emission = Color(1.0, 0.85, 0.45)
		pmat.emission_energy_multiplier = 0.7
		pmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		paper.material_override = pmat
		board.add_child(paper)
		# Title label
		var label: Label3D = Label3D.new()
		label.text = quest_titles[i]
		label.position = Vector3(0, 2.0 - i * 0.45, -0.075)
		label.modulate = Color(0.20, 0.10, 0.02)
		label.outline_modulate = Color(1.0, 0.85, 0.45, 0.4)
		label.outline_size = 3
		label.font_size = 16
		label.no_depth_test = true
		board.add_child(label)
	# Wood post supports
	for x: float in [-0.7, 0.7]:
		var post: MeshInstance3D = MeshInstance3D.new()
		var pmesh: CylinderMesh = CylinderMesh.new()
		pmesh.top_radius = 0.06
		pmesh.bottom_radius = 0.08
		pmesh.height = 2.6
		post.mesh = pmesh
		post.position = Vector3(x, 1.3, 0.05)
		var pmat: StandardMaterial3D = StandardMaterial3D.new()
		pmat.albedo_color = Color(0.18, 0.10, 0.04)
		pmat.emission_enabled = true
		pmat.emission = Color(0.65, 0.40, 0.10)
		pmat.emission_energy_multiplier = 0.4
		post.material_override = pmat
		board.add_child(post)
	# Collision
	var sb: StaticBody3D = StaticBody3D.new()
	var col_shape: CollisionShape3D = CollisionShape3D.new()
	var col_box: BoxShape3D = BoxShape3D.new()
	col_box.size = Vector3(1.7, 2.6, 0.3)
	col_shape.shape = col_box
	col_shape.position = Vector3(0, 1.3, 0)
	sb.add_child(col_shape)
	board.add_child(sb)


func _build_data_bins(geom: Node) -> void:
	## Epic-1 T37: 4 data recycling bins at plaza corners
	for entry in [
		[Vector3(24, 0, 12), Color(0.30, 0.85, 0.50)],   # green RECYCLE
		[Vector3(40, 0, 12), Color(1.0, 0.55, 0.20)],    # orange WASTE
		[Vector3(24, 0, -12), Color(0.85, 0.30, 0.55)],  # pink BUGS
		[Vector3(40, 0, -12), Color(0.30, 0.65, 0.95)],  # blue DATA
	]:
		var pos: Vector3 = entry[0]
		var hue: Color = entry[1]
		var bin: Node3D = Node3D.new()
		bin.position = pos
		geom.add_child(bin)
		# Bin body
		var body: MeshInstance3D = MeshInstance3D.new()
		var bmesh: CylinderMesh = CylinderMesh.new()
		bmesh.top_radius = 0.32
		bmesh.bottom_radius = 0.28
		bmesh.height = 0.8
		body.mesh = bmesh
		body.position = Vector3(0, 0.4, 0)
		var bmat: StandardMaterial3D = StandardMaterial3D.new()
		bmat.albedo_color = Color(0.10, 0.18, 0.26)
		bmat.emission_enabled = true
		bmat.emission = hue
		bmat.emission_energy_multiplier = 0.6
		bmat.metallic = 0.55
		body.material_override = bmat
		bin.add_child(body)
		# Lid
		var lid: MeshInstance3D = MeshInstance3D.new()
		var lmesh: CylinderMesh = CylinderMesh.new()
		lmesh.top_radius = 0.34
		lmesh.bottom_radius = 0.34
		lmesh.height = 0.06
		lid.mesh = lmesh
		lid.position = Vector3(0, 0.83, 0)
		var lmat: StandardMaterial3D = StandardMaterial3D.new()
		lmat.albedo_color = hue * 0.6
		lmat.emission_enabled = true
		lmat.emission = hue
		lmat.emission_energy_multiplier = 1.2
		lid.material_override = lmat
		bin.add_child(lid)
		# Collision
		var sb: StaticBody3D = StaticBody3D.new()
		var col_shape: CollisionShape3D = CollisionShape3D.new()
		var col_capsule: CapsuleShape3D = CapsuleShape3D.new()
		col_capsule.radius = 0.34
		col_capsule.height = 0.86
		col_shape.shape = col_capsule
		col_shape.position = Vector3(0, 0.43, 0)
		sb.add_child(col_shape)
		bin.add_child(sb)


func _build_animated_lamps(geom: Node) -> void:
	## Epic-1 T38: 4 animated street lamps with sequential on/off cycle
	## arranged along the plaza north edge
	for i: int in 4:
		var lamp_root: Node3D = Node3D.new()
		lamp_root.position = Vector3(26 + i * 4, 0, -10)
		geom.add_child(lamp_root)
		# Tall post
		var post: MeshInstance3D = MeshInstance3D.new()
		var pmesh: CylinderMesh = CylinderMesh.new()
		pmesh.top_radius = 0.06
		pmesh.bottom_radius = 0.10
		pmesh.height = 3.0
		post.mesh = pmesh
		post.position = Vector3(0, 1.5, 0)
		var pmat: StandardMaterial3D = StandardMaterial3D.new()
		pmat.albedo_color = Color(0.10, 0.18, 0.26)
		pmat.emission_enabled = true
		pmat.emission = Color(0.20, 0.55, 0.75)
		pmat.emission_energy_multiplier = 0.5
		pmat.metallic = 0.7
		post.material_override = pmat
		lamp_root.add_child(post)
		# Lamp head sphere
		var head: MeshInstance3D = MeshInstance3D.new()
		var hmesh: SphereMesh = SphereMesh.new()
		hmesh.radius = 0.22
		hmesh.height = 0.44
		head.mesh = hmesh
		head.position = Vector3(0, 3.1, 0)
		var hmat: StandardMaterial3D = StandardMaterial3D.new()
		hmat.albedo_color = Color(1.0, 0.85, 0.40)
		hmat.emission_enabled = true
		hmat.emission = Color(1.0, 0.80, 0.30)
		hmat.emission_energy_multiplier = 2.5
		hmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		head.material_override = hmat
		lamp_root.add_child(head)
		# Sequential pulse — each lamp dims in turn
		var tween: Tween = create_tween().set_loops()
		tween.tween_interval(i * 0.4)
		tween.tween_property(hmat, "emission_energy_multiplier", 0.5, 0.5).set_ease(Tween.EASE_OUT)
		tween.tween_property(hmat, "emission_energy_multiplier", 2.5, 0.5).set_ease(Tween.EASE_IN)
		tween.tween_interval((4 - i) * 0.4)


func _build_dock_ramp(geom: Node) -> void:
	## Epic-1 T39: angled ramp slab connecting the loading dock platform
	## to the plaza floor
	var ramp: MeshInstance3D = MeshInstance3D.new()
	ramp.name = "EastPlazaDockRamp"
	var rmesh: BoxMesh = BoxMesh.new()
	rmesh.size = Vector3(1.8, 0.1, 2.0)
	ramp.mesh = rmesh
	ramp.position = Vector3(40, 0.15, 3)
	ramp.rotation_degrees = Vector3(8, 0, 0)
	var rmat: StandardMaterial3D = StandardMaterial3D.new()
	rmat.albedo_color = Color(0.12, 0.18, 0.26)
	rmat.emission_enabled = true
	rmat.emission = Color(0.20, 0.55, 0.75)
	rmat.emission_energy_multiplier = 0.45
	rmat.metallic = 0.6
	ramp.material_override = rmat
	geom.add_child(ramp)


func _build_zone_numbers(geom: Node) -> void:
	## Epic-1 T40: floating zone-number labels above each sub-zone
	var zone_data: Array = [
		[Vector3(32, 4.8, -1), "1 — MARKET"],
		[Vector3(40, 4.8, -14), "2 — SPAR"],
		[Vector3(40, 4.8, 14), "3 — ARENA"],
		[Vector3(42, 4.8, 0), "4 — DOCK"],
		[Vector3(29, 4.8, -8), "5 — VENDORS"],
	]
	for entry in zone_data:
		var label: Label3D = Label3D.new()
		label.text = entry[1]
		label.position = entry[0]
		label.modulate = Color(1.0, 0.65, 0.20)
		label.outline_modulate = Color(0, 0.05, 0.10, 0.95)
		label.outline_size = 7
		label.font_size = 24
		label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		label.no_depth_test = true
		geom.add_child(label)


func _build_weapon_rack(geom: Node) -> void:
	## Epic-1 T31: vertical weapon rack at (44, 0, -14) with 4 displayed weapons
	var rack: Node3D = Node3D.new()
	rack.name = "EastPlazaWeaponRack"
	rack.position = Vector3(44, 0, -14)
	geom.add_child(rack)
	# Rack frame (vertical post)
	var post_mat: StandardMaterial3D = StandardMaterial3D.new()
	post_mat.albedo_color = Color(0.10, 0.18, 0.26)
	post_mat.emission_enabled = true
	post_mat.emission = Color(0.20, 0.55, 0.75)
	post_mat.emission_energy_multiplier = 0.5
	post_mat.metallic = 0.7
	var frame: MeshInstance3D = MeshInstance3D.new()
	var fmesh: BoxMesh = BoxMesh.new()
	fmesh.size = Vector3(0.15, 2.4, 1.6)
	frame.mesh = fmesh
	frame.position = Vector3(0, 1.2, 0)
	frame.material_override = post_mat
	rack.add_child(frame)
	# 4 weapons, evenly spaced along the rack height
	var weapons: Array = [
		# [shape_size, color, name]
		[Vector3(0.06, 1.2, 0.10), Color(0.45, 0.95, 1.0), "BLADE"],   # sword
		[Vector3(0.10, 0.4, 0.10), Color(1.0, 0.55, 0.20), "BOLT"],     # pistol-like
		[Vector3(0.05, 1.0, 0.05), Color(0.85, 0.30, 1.0), "STAFF"],    # staff
		[Vector3(0.30, 0.30, 0.05), Color(0.30, 0.85, 0.50), "BUCKLER"],# small shield
	]
	for i in weapons.size():
		var entry = weapons[i]
		var size: Vector3 = entry[0]
		var hue: Color = entry[1]
		var weapon_name: String = entry[2]
		var w: MeshInstance3D = MeshInstance3D.new()
		var wmesh: BoxMesh = BoxMesh.new()
		wmesh.size = size
		w.mesh = wmesh
		w.position = Vector3(0.15, 0.5 + i * 0.55, 0)
		var wmat: StandardMaterial3D = StandardMaterial3D.new()
		wmat.albedo_color = hue
		wmat.emission_enabled = true
		wmat.emission = hue
		wmat.emission_energy_multiplier = 1.4
		wmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		w.material_override = wmat
		rack.add_child(w)
		# Tiny name label next to each weapon
		var label: Label3D = Label3D.new()
		label.text = weapon_name
		label.position = Vector3(0.45, 0.5 + i * 0.55, 0)
		label.modulate = hue
		label.outline_modulate = Color(0, 0, 0, 0.85)
		label.outline_size = 4
		label.font_size = 14
		label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		rack.add_child(label)
	# Collision
	var sb: StaticBody3D = StaticBody3D.new()
	var col_shape: CollisionShape3D = CollisionShape3D.new()
	var col_box: BoxShape3D = BoxShape3D.new()
	col_box.size = Vector3(0.6, 2.4, 1.6)
	col_shape.shape = col_box
	col_shape.position = Vector3(0, 1.2, 0)
	sb.add_child(col_shape)
	rack.add_child(sb)


func _build_combat_mannequin(geom: Node) -> void:
	## Epic-1 T32: armored humanoid mannequin (display, not interactive)
	## next to the weapon rack
	var mq: Node3D = Node3D.new()
	mq.name = "EastPlazaCombatMannequin"
	mq.position = Vector3(44, 0, -16)
	geom.add_child(mq)
	# Body — taller than dummies, armored look
	var body: MeshInstance3D = MeshInstance3D.new()
	var bmesh: CapsuleMesh = CapsuleMesh.new()
	bmesh.radius = 0.32
	bmesh.height = 1.8
	body.mesh = bmesh
	body.position = Vector3(0, 1.0, 0)
	var bmat: StandardMaterial3D = StandardMaterial3D.new()
	bmat.albedo_color = Color(0.20, 0.30, 0.40)
	bmat.emission_enabled = true
	bmat.emission = Color(0.30, 0.65, 0.85)
	bmat.emission_energy_multiplier = 0.4
	bmat.metallic = 0.85
	bmat.roughness = 0.3
	body.material_override = bmat
	mq.add_child(body)
	# Helmet (sphere on top)
	var helm: MeshInstance3D = MeshInstance3D.new()
	var hmesh: SphereMesh = SphereMesh.new()
	hmesh.radius = 0.32
	hmesh.height = 0.64
	helm.mesh = hmesh
	helm.position = Vector3(0, 1.95, 0)
	helm.material_override = bmat
	mq.add_child(helm)
	# Glowing visor stripe
	var visor: MeshInstance3D = MeshInstance3D.new()
	var vmesh: BoxMesh = BoxMesh.new()
	vmesh.size = Vector3(0.55, 0.10, 0.05)
	visor.mesh = vmesh
	visor.position = Vector3(0, 1.95, -0.30)
	var vmat: StandardMaterial3D = StandardMaterial3D.new()
	vmat.albedo_color = Color(1.0, 0.30, 0.30)
	vmat.emission_enabled = true
	vmat.emission = Color(1.0, 0.20, 0.20)
	vmat.emission_energy_multiplier = 2.5
	vmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	visor.material_override = vmat
	mq.add_child(visor)
	# Collision
	var sb: StaticBody3D = StaticBody3D.new()
	var col_shape: CollisionShape3D = CollisionShape3D.new()
	var col_capsule: CapsuleShape3D = CapsuleShape3D.new()
	col_capsule.radius = 0.32
	col_capsule.height = 1.8
	col_shape.shape = col_capsule
	col_shape.position = Vector3(0, 1.0, 0)
	sb.add_child(col_shape)
	mq.add_child(sb)


func _build_training_mat(geom: Node) -> void:
	## Epic-1 T33: padded training mat at (37, 0.02, -14) — flat soft area
	## next to the spar zone where the player can warm up
	var mat: MeshInstance3D = MeshInstance3D.new()
	mat.name = "EastPlazaTrainingMat"
	var mmesh: BoxMesh = BoxMesh.new()
	mmesh.size = Vector3(2.0, 0.04, 2.0)
	mat.mesh = mmesh
	mat.position = Vector3(37, 0.02, -10)
	var mmat: StandardMaterial3D = StandardMaterial3D.new()
	mmat.albedo_color = Color(0.20, 0.55, 0.65)
	mmat.emission_enabled = true
	mmat.emission = Color(0.30, 0.75, 0.90)
	mmat.emission_energy_multiplier = 0.6
	mmat.roughness = 0.85
	mat.material_override = mmat
	geom.add_child(mat)


func _build_score_board(geom: Node) -> void:
	## Epic-1 T34: large scoreboard with mock HP/XP display panels
	var board: Node3D = Node3D.new()
	board.name = "EastPlazaScoreBoard"
	board.position = Vector3(44, 0, -10)
	geom.add_child(board)
	# Backboard
	var back: MeshInstance3D = MeshInstance3D.new()
	var bmesh: BoxMesh = BoxMesh.new()
	bmesh.size = Vector3(0.10, 2.0, 3.0)
	back.mesh = bmesh
	back.position = Vector3(0, 1.5, 0)
	var bmat: StandardMaterial3D = StandardMaterial3D.new()
	bmat.albedo_color = Color(0.05, 0.10, 0.20)
	bmat.emission_enabled = true
	bmat.emission = Color(0.10, 0.30, 0.55)
	bmat.emission_energy_multiplier = 0.5
	bmat.metallic = 0.6
	back.material_override = bmat
	board.add_child(back)
	# Glowing display screen
	var screen: MeshInstance3D = MeshInstance3D.new()
	var smesh: BoxMesh = BoxMesh.new()
	smesh.size = Vector3(0.05, 1.6, 2.6)
	screen.mesh = smesh
	screen.position = Vector3(0.08, 1.5, 0)
	var smat: StandardMaterial3D = StandardMaterial3D.new()
	smat.albedo_color = Color(0.10, 0.30, 0.55)
	smat.emission_enabled = true
	smat.emission = Color(0.30, 0.85, 1.0)
	smat.emission_energy_multiplier = 1.4
	smat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	screen.material_override = smat
	board.add_child(screen)
	# Mock score text labels (3 lines)
	var lines: Array[String] = [
		"PLAYER",
		"HP  100/100",
		"XP    0/100",
	]
	for i in lines.size():
		var line: Label3D = Label3D.new()
		line.text = lines[i]
		line.position = Vector3(0.12, 2.1 - i * 0.4, 0)
		line.rotation_degrees = Vector3(0, 90, 0)
		line.modulate = Color(0.40, 0.95, 1.0) if i == 0 else Color(1, 1, 1)
		line.outline_modulate = Color(0, 0, 0, 0.95)
		line.outline_size = 6
		line.font_size = 22 if i == 0 else 18
		line.no_depth_test = true
		board.add_child(line)


func _build_chalk_lines(geom: Node) -> void:
	## Epic-1 T35: cyan chalk technique lines painted on the spar zone floor —
	## footwork markers (4 lines + 1 center cross)
	var chalk_mat: StandardMaterial3D = StandardMaterial3D.new()
	chalk_mat.albedo_color = Color(0.40, 0.95, 1.0, 0.85)
	chalk_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	chalk_mat.emission_enabled = true
	chalk_mat.emission = Color(0.50, 0.95, 1.0)
	chalk_mat.emission_energy_multiplier = 1.4
	chalk_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	# Center cross (2 perpendicular lines)
	for entry in [
		[Vector3(40, 0.13, -14), Vector3(2.0, 0.02, 0.05)],
		[Vector3(40, 0.13, -14), Vector3(0.05, 0.02, 2.0)],
	]:
		var line: MeshInstance3D = MeshInstance3D.new()
		var lmesh: BoxMesh = BoxMesh.new()
		lmesh.size = entry[1]
		line.mesh = lmesh
		line.position = entry[0]
		line.material_override = chalk_mat
		geom.add_child(line)
	# 4 corner quadrant markers (small Xs)
	for offset in [Vector3(-1.5, 0, -1.5), Vector3(1.5, 0, -1.5), Vector3(-1.5, 0, 1.5), Vector3(1.5, 0, 1.5)]:
		for rot in [0.0, PI/2.0]:
			var line: MeshInstance3D = MeshInstance3D.new()
			var lmesh: BoxMesh = BoxMesh.new()
			lmesh.size = Vector3(0.5, 0.02, 0.05)
			line.mesh = lmesh
			line.position = Vector3(40, 0.13, -14) + offset
			line.rotation.y = rot + PI/4.0
			line.material_override = chalk_mat
			geom.add_child(line)


func _build_sparring_arena(geom: Node) -> void:
	## Epic-1 T26: square sparring arena at (40, 0, -14) — raised platform with
	## red boundary stripes
	var arena: Node3D = Node3D.new()
	arena.name = "EastPlazaSparringArena"
	arena.position = Vector3(40, 0, -14)
	geom.add_child(arena)
	# Floor pad
	var pad: MeshInstance3D = MeshInstance3D.new()
	var pmesh: BoxMesh = BoxMesh.new()
	pmesh.size = Vector3(6, 0.1, 6)
	pad.mesh = pmesh
	pad.position = Vector3(0, 0.05, 0)
	var pmat: StandardMaterial3D = StandardMaterial3D.new()
	pmat.albedo_color = Color(0.10, 0.18, 0.26)
	pmat.emission_enabled = true
	pmat.emission = Color(0.30, 0.85, 1.0)
	pmat.emission_energy_multiplier = 0.6
	pmat.metallic = 0.5
	pad.material_override = pmat
	arena.add_child(pad)
	# Red boundary stripes (4 sides)
	for entry in [
		[Vector3(-3, 0.11, 0), Vector3(0.15, 0.02, 6)],
		[Vector3(3, 0.11, 0), Vector3(0.15, 0.02, 6)],
		[Vector3(0, 0.11, -3), Vector3(6, 0.02, 0.15)],
		[Vector3(0, 0.11, 3), Vector3(6, 0.02, 0.15)],
	]:
		var stripe: MeshInstance3D = MeshInstance3D.new()
		var smesh: BoxMesh = BoxMesh.new()
		smesh.size = entry[1]
		stripe.mesh = smesh
		stripe.position = entry[0]
		var smat: StandardMaterial3D = StandardMaterial3D.new()
		smat.albedo_color = Color(1.0, 0.18, 0.18)
		smat.emission_enabled = true
		smat.emission = Color(1.0, 0.20, 0.15)
		smat.emission_energy_multiplier = 1.6
		smat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		stripe.material_override = smat
		arena.add_child(stripe)
	# Floor label
	var label: Label3D = Label3D.new()
	label.text = "SPAR ZONE"
	label.position = Vector3(0, 0.13, 0)
	label.rotation_degrees = Vector3(-90, 0, 0)
	label.modulate = Color(1.0, 0.30, 0.30)
	label.outline_modulate = Color(0, 0, 0, 0.95)
	label.outline_size = 6
	label.font_size = 28
	label.no_depth_test = true
	arena.add_child(label)


func _build_practice_dummies(geom: Node) -> void:
	## Epic-1 T27: 2 humanoid practice dummies inside the sparring arena
	for i: int in 2:
		var dummy: Node3D = Node3D.new()
		dummy.name = "EastPlazaSparDummy_%d" % i
		dummy.position = Vector3(40 + (i * 2 - 1) * 1.5, 0, -14)
		geom.add_child(dummy)
		# Body — tall capsule
		var body: MeshInstance3D = MeshInstance3D.new()
		var bmesh: CapsuleMesh = CapsuleMesh.new()
		bmesh.radius = 0.30
		bmesh.height = 1.5
		body.mesh = bmesh
		body.position = Vector3(0, 0.85, 0)
		var bmat: StandardMaterial3D = StandardMaterial3D.new()
		bmat.albedo_color = Color(0.45, 0.30, 0.20)
		bmat.emission_enabled = true
		bmat.emission = Color(0.65, 0.40, 0.20)
		bmat.emission_energy_multiplier = 0.4
		bmat.roughness = 0.7
		body.material_override = bmat
		dummy.add_child(body)
		# Target ring around the chest
		var ring: MeshInstance3D = MeshInstance3D.new()
		var rmesh: TorusMesh = TorusMesh.new()
		rmesh.inner_radius = 0.32
		rmesh.outer_radius = 0.40
		rmesh.rings = 12
		rmesh.ring_segments = 16
		ring.mesh = rmesh
		ring.position = Vector3(0, 0.95, 0)
		ring.rotation_degrees = Vector3(90, 0, 0)
		var rmat: StandardMaterial3D = StandardMaterial3D.new()
		rmat.albedo_color = Color(1.0, 0.95, 0.30)
		rmat.emission_enabled = true
		rmat.emission = Color(1.0, 0.90, 0.20)
		rmat.emission_energy_multiplier = 1.6
		rmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		ring.material_override = rmat
		dummy.add_child(ring)
		# Floating hp label (placeholder)
		var label: Label3D = Label3D.new()
		label.text = "HP 100/100"
		label.position = Vector3(0, 2.0, 0)
		label.modulate = Color(1.0, 0.95, 0.85)
		label.outline_modulate = Color(0, 0, 0, 0.85)
		label.outline_size = 5
		label.font_size = 16
		label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		dummy.add_child(label)
		# Collision (the dummy can be hit)
		var sb: StaticBody3D = StaticBody3D.new()
		var col_shape: CollisionShape3D = CollisionShape3D.new()
		var col_capsule: CapsuleShape3D = CapsuleShape3D.new()
		col_capsule.radius = 0.30
		col_capsule.height = 1.5
		col_shape.shape = col_capsule
		col_shape.position = Vector3(0, 0.85, 0)
		sb.add_child(col_shape)
		dummy.add_child(sb)


func _build_tournament_pit(geom: Node) -> void:
	## Epic-1 T28: sunken tournament pit at (40, -0.5, 14) — circular fighting
	## ring lower than the surrounding plaza
	var pit: Node3D = Node3D.new()
	pit.name = "EastPlazaTournamentPit"
	pit.position = Vector3(40, 0, 14)
	geom.add_child(pit)
	# Sunken floor
	var floor_disc: MeshInstance3D = MeshInstance3D.new()
	var fmesh: CylinderMesh = CylinderMesh.new()
	fmesh.top_radius = 4.0
	fmesh.bottom_radius = 4.0
	fmesh.height = 0.2
	fmesh.radial_segments = 24
	floor_disc.mesh = fmesh
	floor_disc.position = Vector3(0, -0.4, 0)
	var fmat: StandardMaterial3D = StandardMaterial3D.new()
	fmat.albedo_color = Color(0.18, 0.10, 0.04)
	fmat.emission_enabled = true
	fmat.emission = Color(0.85, 0.30, 0.10)
	fmat.emission_energy_multiplier = 0.65
	fmat.metallic = 0.4
	fmat.roughness = 0.6
	floor_disc.material_override = fmat
	pit.add_child(floor_disc)
	# Outer ring wall (low rim)
	var wall: MeshInstance3D = MeshInstance3D.new()
	var wmesh: CylinderMesh = CylinderMesh.new()
	wmesh.top_radius = 4.2
	wmesh.bottom_radius = 4.2
	wmesh.height = 0.6
	wmesh.radial_segments = 24
	wall.mesh = wmesh
	wall.position = Vector3(0, 0.0, 0)
	var wmat: StandardMaterial3D = StandardMaterial3D.new()
	wmat.albedo_color = Color(0.12, 0.18, 0.26)
	wmat.emission_enabled = true
	wmat.emission = Color(1.0, 0.30, 0.20)
	wmat.emission_energy_multiplier = 0.8
	wmat.metallic = 0.7
	wall.material_override = wmat
	pit.add_child(wall)
	# Floor label
	var label: Label3D = Label3D.new()
	label.text = "ARENA"
	label.position = Vector3(0, -0.28, 0)
	label.rotation_degrees = Vector3(-90, 0, 0)
	label.modulate = Color(1.0, 0.50, 0.20)
	label.outline_modulate = Color(0, 0, 0, 0.95)
	label.outline_size = 7
	label.font_size = 36
	label.no_depth_test = true
	pit.add_child(label)


func _build_crowd_seating(geom: Node) -> void:
	## Epic-1 T29: ring of small spectator seats around the tournament pit
	## (4 seat blocks at NE/NW/SE/SW)
	for i: int in 8:
		var angle: float = i * TAU / 8.0
		var radius: float = 5.5
		var seat_pos := Vector3(40 + cos(angle) * radius, 0.3, 14 + sin(angle) * radius)
		var seat: MeshInstance3D = MeshInstance3D.new()
		var smesh: BoxMesh = BoxMesh.new()
		smesh.size = Vector3(1.4, 0.6, 1.0)
		seat.mesh = smesh
		seat.position = seat_pos
		var smat: StandardMaterial3D = StandardMaterial3D.new()
		smat.albedo_color = Color(0.12, 0.18, 0.26)
		smat.emission_enabled = true
		smat.emission = Color(0.20, 0.55, 0.75)
		smat.emission_energy_multiplier = 0.5
		smat.metallic = 0.5
		seat.material_override = smat
		geom.add_child(seat)
		# Spectator orb (sitting on each seat)
		var spec: MeshInstance3D = MeshInstance3D.new()
		var orb_mesh: SphereMesh = SphereMesh.new()
		orb_mesh.radius = 0.22
		orb_mesh.height = 0.44
		spec.mesh = orb_mesh
		spec.position = seat_pos + Vector3(0, 0.55, 0)
		var hue: Color = [
			Color(0.85, 0.55, 0.30),  # orange
			Color(0.55, 0.35, 0.85),  # violet
			Color(0.30, 0.85, 0.50),  # green
			Color(0.85, 0.30, 0.45),  # coral
			Color(0.30, 0.65, 0.90),  # blue
			Color(1.0, 0.85, 0.30),   # yellow
			Color(0.50, 0.90, 0.85),  # teal
			Color(0.95, 0.45, 0.85),  # magenta
		][i]
		var omat: StandardMaterial3D = StandardMaterial3D.new()
		omat.albedo_color = hue
		omat.emission_enabled = true
		omat.emission = hue * 1.3
		omat.emission_energy_multiplier = 0.6
		spec.material_override = omat
		geom.add_child(spec)
		# Subtle bob animation
		var tween: Tween = create_tween().set_loops()
		var bob_pos: Vector3 = spec.position
		tween.tween_property(spec, "position:y", bob_pos.y + 0.04, 1.0 + i * 0.1).set_ease(Tween.EASE_IN_OUT)
		tween.tween_property(spec, "position:y", bob_pos.y, 1.0 + i * 0.1).set_ease(Tween.EASE_IN_OUT)


func _build_combat_trainer_npc() -> void:
	## Epic-1 T30: combat trainer NPC at the sparring arena edge
	var trainer: Node3D = Node3D.new()
	trainer.name = "EastPlazaCombatTrainer"
	trainer.position = Vector3(36, 0.5, -14)
	add_child(trainer)
	var body: MeshInstance3D = MeshInstance3D.new()
	var sphere: SphereMesh = SphereMesh.new()
	sphere.radius = 0.42
	sphere.height = 0.84
	body.mesh = sphere
	var mat: StandardMaterial3D = StandardMaterial3D.new()
	mat.albedo_color = Color(0.85, 0.18, 0.18)
	mat.emission_enabled = true
	mat.emission = Color(1.0, 0.25, 0.15)
	mat.emission_energy_multiplier = 0.7
	mat.metallic = 0.4
	body.material_override = mat
	trainer.add_child(body)
	# Determined eyes
	var eye_mat: StandardMaterial3D = StandardMaterial3D.new()
	eye_mat.albedo_color = Color(1.0, 0.95, 0.30)
	eye_mat.emission_enabled = true
	eye_mat.emission = Color(1.0, 0.85, 0.20)
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
	label.text = "Combat Trainer"
	label.position = Vector3(0, 1.4, 0)
	label.modulate = Color(1.0, 0.50, 0.30)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 6
	label.font_size = 22
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	trainer.add_child(label)


func _build_ground_light_strips(geom: Node) -> void:
	## Epic-1 T21: thin cyan light strips embedded in the floor leading from the
	## main town path edge into the plaza centerpiece
	for i: int in 8:
		var strip: MeshInstance3D = MeshInstance3D.new()
		var smesh: BoxMesh = BoxMesh.new()
		smesh.size = Vector3(0.4, 0.02, 0.08)
		strip.mesh = smesh
		strip.position = Vector3(22 + i * 1.4, 0.02, 0)
		var smat: StandardMaterial3D = StandardMaterial3D.new()
		smat.albedo_color = Color(0.30, 0.85, 1.0)
		smat.emission_enabled = true
		smat.emission = Color(0.40, 0.95, 1.0)
		smat.emission_energy_multiplier = 2.5
		smat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		strip.material_override = smat
		geom.add_child(strip)
		# Sequential pulse — each strip flashes in turn for a "follow me" effect
		var tween: Tween = create_tween().set_loops()
		var dim_amount: float = 0.6
		var bright_amount: float = 4.0
		tween.tween_interval(i * 0.15)
		tween.tween_property(smat, "emission_energy_multiplier", bright_amount, 0.4).set_ease(Tween.EASE_OUT)
		tween.tween_property(smat, "emission_energy_multiplier", dim_amount, 0.8).set_ease(Tween.EASE_IN)
		tween.tween_interval((8 - i) * 0.15)


func _build_maintenance_bots(geom: Node) -> void:
	## Epic-1 T22: 3 small disk-shaped maintenance bots sweeping the plaza floor
	for i: int in 3:
		var bot: Node3D = Node3D.new()
		bot.name = "EastPlazaMaintBot_%d" % i
		bot.position = Vector3(28 + i * 4, 0.1, 9 - i * 5)
		geom.add_child(bot)
		# Disc body
		var body: MeshInstance3D = MeshInstance3D.new()
		var bmesh: CylinderMesh = CylinderMesh.new()
		bmesh.top_radius = 0.22
		bmesh.bottom_radius = 0.22
		bmesh.height = 0.10
		body.mesh = bmesh
		var bmat: StandardMaterial3D = StandardMaterial3D.new()
		bmat.albedo_color = Color(0.85, 0.85, 0.90)
		bmat.emission_enabled = true
		bmat.emission = Color(1.0, 0.95, 0.90)
		bmat.emission_energy_multiplier = 0.4
		bmat.metallic = 0.85
		body.material_override = bmat
		bot.add_child(body)
		# Top status LED
		var led: MeshInstance3D = MeshInstance3D.new()
		var lmesh: SphereMesh = SphereMesh.new()
		lmesh.radius = 0.04
		lmesh.height = 0.08
		led.mesh = lmesh
		led.position = Vector3(0.05, 0.06, 0)
		var lmat: StandardMaterial3D = StandardMaterial3D.new()
		lmat.albedo_color = Color(0.30, 1.0, 0.40)
		lmat.emission_enabled = true
		lmat.emission = Color(0.30, 1.0, 0.40)
		lmat.emission_energy_multiplier = 3.0
		lmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		led.material_override = lmat
		bot.add_child(led)
		# Sweep tween — patrol along the south edge
		var tween: Tween = create_tween().set_loops()
		var p1 := Vector3(24 + i * 6, 0.1, 9 - i * 5)
		var p2 := Vector3(40 - i * 4, 0.1, 9 - i * 5)
		tween.tween_property(bot, "position", p1, 6.0 + i).set_ease(Tween.EASE_IN_OUT)
		tween.tween_property(bot, "position", p2, 6.0 + i).set_ease(Tween.EASE_IN_OUT)


func _build_sky_data_fragments(geom: Node) -> void:
	## Epic-1 T23: slow falling cyan/orange data fragments overhead — rare,
	## small particles that drift down through the plaza
	var particles: GPUParticles3D = GPUParticles3D.new()
	particles.amount = 30
	particles.lifetime = 12.0
	particles.position = Vector3(32, 8.0, 0)
	var pmat: ParticleProcessMaterial = ParticleProcessMaterial.new()
	pmat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	pmat.emission_box_extents = Vector3(10, 0.5, 18)
	pmat.direction = Vector3(0, -1, 0)
	pmat.gravity = Vector3(0.05, -0.4, 0.02)
	pmat.initial_velocity_min = 0.1
	pmat.initial_velocity_max = 0.3
	pmat.scale_min = 0.06
	pmat.scale_max = 0.14
	pmat.color = Color(0.85, 0.55, 0.30, 0.85)
	particles.process_material = pmat
	var dot_mesh: SphereMesh = SphereMesh.new()
	dot_mesh.radius = 0.05
	dot_mesh.height = 0.10
	particles.draw_pass_1 = dot_mesh
	geom.add_child(particles)


func _build_power_conduits(geom: Node) -> void:
	## Epic-1 T24: glowing cyan power conduits running across the plaza floor
	## connecting the data terminal to the kiosks (4 lines radiating outward)
	var conduit_mat: StandardMaterial3D = StandardMaterial3D.new()
	conduit_mat.albedo_color = Color(0.15, 0.45, 0.65)
	conduit_mat.emission_enabled = true
	conduit_mat.emission = Color(0.20, 0.70, 0.95)
	conduit_mat.emission_energy_multiplier = 1.4
	conduit_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	# 4 lines from the centerpiece (32, 0, 0) to each kiosk corner
	var endpoints: Array[Vector3] = [
		Vector3(28, 0.04, -4), Vector3(36, 0.04, -4),
		Vector3(28, 0.04, 4), Vector3(36, 0.04, 4),
	]
	for ep in endpoints:
		var conduit: MeshInstance3D = MeshInstance3D.new()
		var cmesh: BoxMesh = BoxMesh.new()
		var dist: float = (ep - Vector3(32, 0.04, 0)).length()
		cmesh.size = Vector3(0.10, 0.02, dist)
		conduit.mesh = cmesh
		var midpoint: Vector3 = Vector3(32, 0.04, 0).lerp(ep, 0.5)
		conduit.position = midpoint
		conduit.look_at(ep, Vector3.UP)
		conduit.material_override = conduit_mat
		geom.add_child(conduit)


func _build_plaza_arch_gateway(geom: Node) -> void:
	## Epic-1 T25: large arch gateway at the west entrance of the plaza
	## (where the connecting path meets the plaza)
	var arch: Node3D = Node3D.new()
	arch.name = "EastPlazaArchGateway"
	arch.position = Vector3(21, 0, 0)
	geom.add_child(arch)
	# 2 vertical pillars
	var pillar_mat: StandardMaterial3D = StandardMaterial3D.new()
	pillar_mat.albedo_color = Color(0.10, 0.18, 0.26)
	pillar_mat.emission_enabled = true
	pillar_mat.emission = Color(0.30, 0.85, 1.0)
	pillar_mat.emission_energy_multiplier = 0.7
	pillar_mat.metallic = 0.7
	for x_offset: float in [-3.0, 3.0]:
		var pillar: MeshInstance3D = MeshInstance3D.new()
		var pmesh: CylinderMesh = CylinderMesh.new()
		pmesh.top_radius = 0.25
		pmesh.bottom_radius = 0.35
		pmesh.height = 4.0
		pillar.mesh = pmesh
		pillar.position = Vector3(0, 2.0, x_offset)
		pillar.material_override = pillar_mat
		arch.add_child(pillar)
		# Collision per pillar
		var sb: StaticBody3D = StaticBody3D.new()
		var col_shape: CollisionShape3D = CollisionShape3D.new()
		var col_box: BoxShape3D = BoxShape3D.new()
		col_box.size = Vector3(0.7, 4.0, 0.7)
		col_shape.shape = col_box
		col_shape.position = Vector3(0, 2.0, x_offset)
		sb.add_child(col_shape)
		arch.add_child(sb)
	# Top crossbar
	var crossbar: MeshInstance3D = MeshInstance3D.new()
	var cmesh: BoxMesh = BoxMesh.new()
	cmesh.size = Vector3(0.5, 0.5, 6.5)
	crossbar.mesh = cmesh
	crossbar.position = Vector3(0, 4.0, 0)
	crossbar.material_override = pillar_mat
	arch.add_child(crossbar)
	# Glowing arch label
	var label: Label3D = Label3D.new()
	label.text = "EAST PLAZA"
	label.position = Vector3(0, 4.5, 0)
	label.modulate = Color(0.40, 0.95, 1.0)
	label.outline_modulate = Color(0, 0.05, 0.10, 0.95)
	label.outline_size = 8
	label.font_size = 32
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	arch.add_child(label)


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


func _build_holo_shop_windows(geom: Node) -> void:
	## Epic-1 T46: 4 holographic shop windows along vendor row at z=10. Each is
	## a large translucent cyan panel with a floating product silhouette inside,
	## bobbing gently to suggest a hovering 3d hologram preview.
	var product_names: Array[String] = ["BLADE", "SHARD", "CORE", "PATCH"]
	for i in 4:
		var booth: Node3D = Node3D.new()
		booth.name = "EastPlazaHoloShop_%d" % i
		booth.position = Vector3(26 + i * 3.5, 0, 10)
		geom.add_child(booth)
		# Backing frame
		var frame: MeshInstance3D = MeshInstance3D.new()
		var fmesh: BoxMesh = BoxMesh.new()
		fmesh.size = Vector3(2.4, 2.6, 0.18)
		frame.mesh = fmesh
		frame.position = Vector3(0, 1.6, 0)
		var fmat: StandardMaterial3D = StandardMaterial3D.new()
		fmat.albedo_color = Color(0.06, 0.10, 0.14)
		fmat.metallic = 0.85
		fmat.roughness = 0.25
		frame.material_override = fmat
		booth.add_child(frame)
		# Translucent cyan glass panel
		var panel: MeshInstance3D = MeshInstance3D.new()
		var pmesh: BoxMesh = BoxMesh.new()
		pmesh.size = Vector3(2.1, 2.3, 0.04)
		panel.mesh = pmesh
		panel.position = Vector3(0, 1.65, 0.1)
		var pmat: StandardMaterial3D = StandardMaterial3D.new()
		pmat.albedo_color = Color(0.20, 0.85, 1.0, 0.30)
		pmat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		pmat.emission_enabled = true
		pmat.emission = Color(0.30, 0.85, 1.0)
		pmat.emission_energy_multiplier = 0.6
		pmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		panel.material_override = pmat
		booth.add_child(panel)
		# Floating product silhouette (rotating cube as placeholder hologram)
		var holo: MeshInstance3D = MeshInstance3D.new()
		holo.name = "Hologram"
		var hmesh: BoxMesh = BoxMesh.new()
		hmesh.size = Vector3(0.55, 0.55, 0.55)
		holo.mesh = hmesh
		holo.position = Vector3(0, 1.7, 0.2)
		var hmat: StandardMaterial3D = StandardMaterial3D.new()
		hmat.albedo_color = Color(0.85, 0.95, 1.0, 0.55)
		hmat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		hmat.emission_enabled = true
		hmat.emission = Color(0.50, 0.95, 1.0)
		hmat.emission_energy_multiplier = 1.6
		hmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		holo.material_override = hmat
		booth.add_child(holo)
		# Slow rotation tween + bob
		var rot: Tween = create_tween().set_loops()
		rot.tween_property(holo, "rotation:y", TAU, 6.0)
		var bob: Tween = create_tween().set_loops()
		bob.tween_property(holo, "position:y", 1.85, 1.6).set_ease(Tween.EASE_IN_OUT)
		bob.tween_property(holo, "position:y", 1.7, 1.6).set_ease(Tween.EASE_IN_OUT)
		# Product label above panel
		var label: Label3D = Label3D.new()
		label.text = product_names[i]
		label.position = Vector3(0, 3.0, 0.15)
		label.modulate = Color(0.55, 0.95, 1.0)
		label.outline_modulate = Color(0, 0, 0, 0.85)
		label.outline_size = 5
		label.font_size = 22
		label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		booth.add_child(label)
		# Collision so the player cannot phase through the booth
		var sb: StaticBody3D = StaticBody3D.new()
		var col_shape: CollisionShape3D = CollisionShape3D.new()
		var col_box: BoxShape3D = BoxShape3D.new()
		col_box.size = Vector3(2.4, 2.6, 0.5)
		col_shape.shape = col_box
		col_shape.position = Vector3(0, 1.3, 0)
		sb.add_child(col_shape)
		booth.add_child(sb)


func _build_atrium_roof(geom: Node) -> void:
	## Epic-1 T47: translucent glass atrium roof spanning the market core. 4
	## tall metal columns and a wide flat glass panel suggest a covered market
	## hall without occluding the camera. Edge trim glows cyan.
	var atrium: Node3D = Node3D.new()
	atrium.name = "EastPlazaAtrium"
	atrium.position = Vector3(32, 0, 0)
	geom.add_child(atrium)
	var glass_mat: StandardMaterial3D = StandardMaterial3D.new()
	glass_mat.albedo_color = Color(0.55, 0.85, 1.0, 0.18)
	glass_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	glass_mat.emission_enabled = true
	glass_mat.emission = Color(0.35, 0.80, 1.0)
	glass_mat.emission_energy_multiplier = 0.20
	glass_mat.metallic = 0.30
	glass_mat.roughness = 0.10
	var col_mat: StandardMaterial3D = StandardMaterial3D.new()
	col_mat.albedo_color = Color(0.12, 0.16, 0.20)
	col_mat.metallic = 0.85
	col_mat.roughness = 0.30
	col_mat.emission_enabled = true
	col_mat.emission = Color(0.25, 0.75, 1.0)
	col_mat.emission_energy_multiplier = 0.4
	# 4 perimeter columns
	var col_offsets: Array[Vector3] = [
		Vector3(-6, 0, -6),
		Vector3(6, 0, -6),
		Vector3(-6, 0, 6),
		Vector3(6, 0, 6),
	]
	for off in col_offsets:
		var pillar: MeshInstance3D = MeshInstance3D.new()
		var cmesh: CylinderMesh = CylinderMesh.new()
		cmesh.top_radius = 0.22
		cmesh.bottom_radius = 0.30
		cmesh.height = 6.5
		pillar.mesh = cmesh
		pillar.position = off + Vector3(0, 3.25, 0)
		pillar.material_override = col_mat
		atrium.add_child(pillar)
		# Collision so columns are solid
		var sb: StaticBody3D = StaticBody3D.new()
		var cs: CollisionShape3D = CollisionShape3D.new()
		var cap: CapsuleShape3D = CapsuleShape3D.new()
		cap.radius = 0.30
		cap.height = 6.5
		cs.shape = cap
		cs.position = off + Vector3(0, 3.25, 0)
		sb.add_child(cs)
		atrium.add_child(sb)
	# Flat glass roof slab
	var roof: MeshInstance3D = MeshInstance3D.new()
	var rmesh: BoxMesh = BoxMesh.new()
	rmesh.size = Vector3(13, 0.10, 13)
	roof.mesh = rmesh
	roof.position = Vector3(0, 6.55, 0)
	roof.material_override = glass_mat
	atrium.add_child(roof)
	# Glowing edge trim — 4 thin emissive bars around the slab perimeter
	var trim_mat: StandardMaterial3D = StandardMaterial3D.new()
	trim_mat.albedo_color = Color(0.30, 0.85, 1.0)
	trim_mat.emission_enabled = true
	trim_mat.emission = Color(0.50, 0.95, 1.0)
	trim_mat.emission_energy_multiplier = 1.4
	trim_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var trim_specs: Array = [
		[Vector3(0, 6.55, -6.5), Vector3(13, 0.12, 0.12)],
		[Vector3(0, 6.55, 6.5), Vector3(13, 0.12, 0.12)],
		[Vector3(-6.5, 6.55, 0), Vector3(0.12, 0.12, 13)],
		[Vector3(6.5, 6.55, 0), Vector3(0.12, 0.12, 13)],
	]
	for spec in trim_specs:
		var bar: MeshInstance3D = MeshInstance3D.new()
		var bmesh: BoxMesh = BoxMesh.new()
		bmesh.size = spec[1]
		bar.mesh = bmesh
		bar.position = spec[0]
		bar.material_override = trim_mat
		atrium.add_child(bar)


func _build_cafe_seating(geom: Node) -> void:
	## Epic-1 T48: 3 small round cafe tables with 2 stools each, near vendor row.
	## Tables have warm amber emissive tops to read as data-cafes.
	var table_mat: StandardMaterial3D = StandardMaterial3D.new()
	table_mat.albedo_color = Color(0.30, 0.20, 0.08)
	table_mat.emission_enabled = true
	table_mat.emission = Color(0.95, 0.65, 0.20)
	table_mat.emission_energy_multiplier = 0.45
	table_mat.metallic = 0.55
	table_mat.roughness = 0.40
	var leg_mat: StandardMaterial3D = StandardMaterial3D.new()
	leg_mat.albedo_color = Color(0.10, 0.12, 0.14)
	leg_mat.metallic = 0.85
	leg_mat.roughness = 0.30
	var stool_mat: StandardMaterial3D = StandardMaterial3D.new()
	stool_mat.albedo_color = Color(0.22, 0.30, 0.40)
	stool_mat.emission_enabled = true
	stool_mat.emission = Color(0.30, 0.65, 0.95)
	stool_mat.emission_energy_multiplier = 0.30
	stool_mat.metallic = 0.50
	var positions: Array[Vector3] = [
		Vector3(28, 0, 7),
		Vector3(33, 0, 7),
		Vector3(38, 0, 7),
	]
	for i in positions.size():
		var cafe: Node3D = Node3D.new()
		cafe.name = "EastPlazaCafe_%d" % i
		cafe.position = positions[i]
		geom.add_child(cafe)
		# Table column
		var leg: MeshInstance3D = MeshInstance3D.new()
		var leg_mesh: CylinderMesh = CylinderMesh.new()
		leg_mesh.top_radius = 0.08
		leg_mesh.bottom_radius = 0.10
		leg_mesh.height = 0.85
		leg.mesh = leg_mesh
		leg.position = Vector3(0, 0.43, 0)
		leg.material_override = leg_mat
		cafe.add_child(leg)
		# Round table top
		var top: MeshInstance3D = MeshInstance3D.new()
		var top_mesh: CylinderMesh = CylinderMesh.new()
		top_mesh.top_radius = 0.55
		top_mesh.bottom_radius = 0.55
		top_mesh.height = 0.08
		top.mesh = top_mesh
		top.position = Vector3(0, 0.89, 0)
		top.material_override = table_mat
		cafe.add_child(top)
		# 2 stools facing each other
		for sx: float in [-1.0, 1.0]:
			var stool: MeshInstance3D = MeshInstance3D.new()
			var smesh: CylinderMesh = CylinderMesh.new()
			smesh.top_radius = 0.22
			smesh.bottom_radius = 0.22
			smesh.height = 0.55
			stool.mesh = smesh
			stool.position = Vector3(sx, 0.27, 0)
			stool.material_override = stool_mat
			cafe.add_child(stool)
		# Collision: one box around the table
		var sb: StaticBody3D = StaticBody3D.new()
		var cs: CollisionShape3D = CollisionShape3D.new()
		var cb: BoxShape3D = BoxShape3D.new()
		cb.size = Vector3(2.6, 1.0, 1.2)
		cs.shape = cb
		cs.position = Vector3(0, 0.5, 0)
		sb.add_child(cs)
		cafe.add_child(sb)


func _build_data_streams(geom: Node) -> void:
	## Epic-1 T49: 2 small secondary data-stream fountains flanking the main
	## fountain at the plaza center. Each is a low ring + a tall vertical column
	## of cyan particles flowing upward and dispersing — pure ambient effect.
	var positions: Array[Vector3] = [
		Vector3(28, 0, -3),
		Vector3(36, 0, -3),
	]
	var ring_mat: StandardMaterial3D = StandardMaterial3D.new()
	ring_mat.albedo_color = Color(0.10, 0.18, 0.26)
	ring_mat.emission_enabled = true
	ring_mat.emission = Color(0.30, 0.85, 1.0)
	ring_mat.emission_energy_multiplier = 0.7
	ring_mat.metallic = 0.55
	ring_mat.roughness = 0.30
	for i in positions.size():
		var stream: Node3D = Node3D.new()
		stream.name = "EastPlazaDataStream_%d" % i
		stream.position = positions[i]
		geom.add_child(stream)
		# Low torus ring base
		var ring: MeshInstance3D = MeshInstance3D.new()
		var tmesh: TorusMesh = TorusMesh.new()
		tmesh.inner_radius = 0.55
		tmesh.outer_radius = 0.85
		ring.mesh = tmesh
		ring.position = Vector3(0, 0.15, 0)
		ring.material_override = ring_mat
		stream.add_child(ring)
		# Vertical particle column
		var col: GPUParticles3D = GPUParticles3D.new()
		col.name = "Stream"
		col.amount = 60
		col.lifetime = 1.8
		col.position = Vector3(0, 0.5, 0)
		col.one_shot = false
		col.explosiveness = 0.0
		var pmat: ParticleProcessMaterial = ParticleProcessMaterial.new()
		pmat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
		pmat.emission_sphere_radius = 0.30
		pmat.direction = Vector3(0, 1, 0)
		pmat.spread = 8.0
		pmat.initial_velocity_min = 1.4
		pmat.initial_velocity_max = 2.2
		pmat.gravity = Vector3(0, -0.4, 0)
		pmat.scale_min = 0.05
		pmat.scale_max = 0.12
		pmat.color = Color(0.55, 0.95, 1.0, 1.0)
		col.process_material = pmat
		# A simple sphere mesh draw
		var dmesh: SphereMesh = SphereMesh.new()
		dmesh.radius = 0.10
		dmesh.height = 0.20
		var dmat: StandardMaterial3D = StandardMaterial3D.new()
		dmat.albedo_color = Color(0.55, 0.95, 1.0)
		dmat.emission_enabled = true
		dmat.emission = Color(0.55, 0.95, 1.0)
		dmat.emission_energy_multiplier = 2.4
		dmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		dmesh.material = dmat
		col.draw_pass_1 = dmesh
		stream.add_child(col)


func _build_district_signposts(geom: Node) -> void:
	## Epic-1 T50: directional signpost cluster at the plaza arch entrance.
	## Single tall metal pole with 4 angled arrow signs pointing toward
	## hypothetical districts to telegraph future expansion.
	var post_root: Node3D = Node3D.new()
	post_root.name = "EastPlazaDistrictSignpost"
	post_root.position = Vector3(22, 0, 0)
	geom.add_child(post_root)
	# Tall metal pole
	var pole: MeshInstance3D = MeshInstance3D.new()
	var pmesh: CylinderMesh = CylinderMesh.new()
	pmesh.top_radius = 0.07
	pmesh.bottom_radius = 0.10
	pmesh.height = 3.4
	pole.mesh = pmesh
	pole.position = Vector3(0, 1.7, 0)
	var pole_mat: StandardMaterial3D = StandardMaterial3D.new()
	pole_mat.albedo_color = Color(0.10, 0.13, 0.16)
	pole_mat.metallic = 0.85
	pole_mat.roughness = 0.30
	pole.material_override = pole_mat
	post_root.add_child(pole)
	# 4 arrow signs at different heights / yaws
	var sign_specs: Array = [
		["MARKET", Color(0.95, 0.65, 0.20), 2.9, 0.0],
		["DUNGEON", Color(0.85, 0.30, 0.30), 2.45, PI * 0.5],
		["TOURNAMENT", Color(0.45, 0.95, 0.65), 2.0, PI],
		["CIPHER LAB", Color(0.85, 0.40, 1.0), 1.55, PI * 1.5],
	]
	for spec in sign_specs:
		var sign_text: String = spec[0]
		var color: Color = spec[1]
		var sign_y: float = spec[2]
		var yaw: float = spec[3]
		var arrow: MeshInstance3D = MeshInstance3D.new()
		var amesh: BoxMesh = BoxMesh.new()
		amesh.size = Vector3(1.6, 0.32, 0.06)
		arrow.mesh = amesh
		arrow.position = Vector3(0.85, sign_y, 0)
		var amat: StandardMaterial3D = StandardMaterial3D.new()
		amat.albedo_color = Color(color.r * 0.4, color.g * 0.4, color.b * 0.4)
		amat.emission_enabled = true
		amat.emission = color
		amat.emission_energy_multiplier = 1.0
		amat.metallic = 0.4
		arrow.material_override = amat
		var pivot: Node3D = Node3D.new()
		pivot.rotation = Vector3(0, yaw, 0)
		pivot.add_child(arrow)
		post_root.add_child(pivot)
		# Label on sign
		var label: Label3D = Label3D.new()
		label.text = sign_text
		label.position = Vector3(0.85, sign_y, 0.05)
		label.modulate = Color(1, 1, 1)
		label.outline_modulate = Color(0, 0, 0, 0.85)
		label.outline_size = 4
		label.font_size = 14
		label.no_depth_test = true
		var lpivot: Node3D = Node3D.new()
		lpivot.rotation = Vector3(0, yaw, 0)
		lpivot.add_child(label)
		post_root.add_child(lpivot)
	# Collision around the pole
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cap: CapsuleShape3D = CapsuleShape3D.new()
	cap.radius = 0.20
	cap.height = 3.4
	cs.shape = cap
	cs.position = Vector3(0, 1.7, 0)
	sb.add_child(cs)
	post_root.add_child(sb)


func _build_tournament_audience(geom: Node) -> void:
	## Epic-1 T51: 8 procedural onlooker NPCs ringing the tournament pit at
	## (40, 0, 12). Each is a simple capsule body with eyes, gently bobbing
	## in place as if cheering. Pure ambience — no AI or interaction.
	var pit_center := Vector3(40, 0, 12)
	for i in 8:
		var angle: float = (float(i) / 8.0) * TAU
		var dist: float = 5.5
		var pos: Vector3 = pit_center + Vector3(cos(angle) * dist, 0, sin(angle) * dist)
		var fan: Node3D = Node3D.new()
		fan.name = "EastPlazaTournamentFan_%d" % i
		fan.position = pos
		geom.add_child(fan)
		# Capsule body — palette varies per fan
		var hue: float = float(i) / 8.0
		var body_color: Color = Color.from_hsv(hue, 0.55, 0.85)
		var body: MeshInstance3D = MeshInstance3D.new()
		var bmesh: CapsuleMesh = CapsuleMesh.new()
		bmesh.radius = 0.32
		bmesh.height = 1.0
		body.mesh = bmesh
		body.position = Vector3(0, 0.55, 0)
		var bmat: StandardMaterial3D = StandardMaterial3D.new()
		bmat.albedo_color = body_color
		bmat.emission_enabled = true
		bmat.emission = body_color
		bmat.emission_energy_multiplier = 0.35
		bmat.metallic = 0.20
		bmat.roughness = 0.55
		body.material_override = bmat
		fan.add_child(body)
		# 2 small glowing eyes
		var eye_mat: StandardMaterial3D = StandardMaterial3D.new()
		eye_mat.albedo_color = Color(0.95, 0.95, 1.0)
		eye_mat.emission_enabled = true
		eye_mat.emission = Color(1.0, 1.0, 1.0)
		eye_mat.emission_energy_multiplier = 1.4
		eye_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		# Eyes face the pit center
		var to_center: Vector3 = (pit_center - pos).normalized()
		for ex: float in [-0.10, 0.10]:
			var eye: MeshInstance3D = MeshInstance3D.new()
			var emesh: SphereMesh = SphereMesh.new()
			emesh.radius = 0.05
			emesh.height = 0.10
			eye.mesh = emesh
			# Offset eyes laterally relative to center-facing direction
			var right: Vector3 = to_center.cross(Vector3.UP).normalized()
			eye.position = Vector3(0, 0.95, 0) + right * ex + to_center * 0.30
			eye.material_override = eye_mat
			fan.add_child(eye)
		# Cheering bob tween (random offset so they're not synced)
		var bob: Tween = create_tween().set_loops()
		var bob_speed: float = 0.45 + (i * 0.05)
		bob.tween_property(body, "position:y", 0.75, bob_speed).set_ease(Tween.EASE_IN_OUT)
		bob.tween_property(body, "position:y", 0.55, bob_speed).set_ease(Tween.EASE_IN_OUT)


func _build_waving_banners(geom: Node) -> void:
	## Epic-1 T52: 4 tall flag poles with cyan/violet pennants gently swaying.
	## Each banner is a thin box that rotates around its pole base via a tween,
	## simulating digital wind for ambient motion variety.
	var pole_mat: StandardMaterial3D = StandardMaterial3D.new()
	pole_mat.albedo_color = Color(0.10, 0.13, 0.16)
	pole_mat.metallic = 0.85
	pole_mat.roughness = 0.30
	var positions: Array[Vector3] = [
		Vector3(24, 0, -12),
		Vector3(40, 0, -12),
		Vector3(24, 0, 14),
		Vector3(40, 0, 14),
	]
	var colors: Array[Color] = [
		Color(0.30, 0.85, 1.0),
		Color(0.85, 0.40, 1.0),
		Color(0.30, 0.85, 1.0),
		Color(0.85, 0.40, 1.0),
	]
	for i in positions.size():
		var pole_root: Node3D = Node3D.new()
		pole_root.name = "EastPlazaWavingBanner_%d" % i
		pole_root.position = positions[i]
		geom.add_child(pole_root)
		# Pole
		var pole: MeshInstance3D = MeshInstance3D.new()
		var pmesh: CylinderMesh = CylinderMesh.new()
		pmesh.top_radius = 0.08
		pmesh.bottom_radius = 0.12
		pmesh.height = 5.0
		pole.mesh = pmesh
		pole.position = Vector3(0, 2.5, 0)
		pole.material_override = pole_mat
		pole_root.add_child(pole)
		# Banner pivot at the top of pole, attaches to one edge so it can sway
		var pivot: Node3D = Node3D.new()
		pivot.position = Vector3(0, 4.6, 0)
		pole_root.add_child(pivot)
		# Banner panel pointed away from pole
		var banner: MeshInstance3D = MeshInstance3D.new()
		var bmesh: BoxMesh = BoxMesh.new()
		bmesh.size = Vector3(1.4, 1.6, 0.04)
		banner.mesh = bmesh
		banner.position = Vector3(0.7, -0.8, 0)
		var bmat: StandardMaterial3D = StandardMaterial3D.new()
		bmat.albedo_color = Color(colors[i].r * 0.40, colors[i].g * 0.40, colors[i].b * 0.40)
		bmat.emission_enabled = true
		bmat.emission = colors[i]
		bmat.emission_energy_multiplier = 0.95
		bmat.metallic = 0.10
		bmat.roughness = 0.55
		banner.material_override = bmat
		pivot.add_child(banner)
		# Sway tween — rotate pivot around y axis a few degrees back and forth
		var sway: Tween = create_tween().set_loops()
		var sway_speed: float = 1.2 + (i * 0.15)
		sway.tween_property(pivot, "rotation:y", deg_to_rad(20), sway_speed).set_ease(Tween.EASE_IN_OUT)
		sway.tween_property(pivot, "rotation:y", deg_to_rad(-20), sway_speed).set_ease(Tween.EASE_IN_OUT)
		# Collision on pole
		var sb: StaticBody3D = StaticBody3D.new()
		var cs: CollisionShape3D = CollisionShape3D.new()
		var cap: CapsuleShape3D = CapsuleShape3D.new()
		cap.radius = 0.20
		cap.height = 5.0
		cs.shape = cap
		cs.position = Vector3(0, 2.5, 0)
		sb.add_child(cs)
		pole_root.add_child(sb)


func _build_power_generator(geom: Node) -> void:
	## Epic-1 T53: industrial generator near the loading dock with a spinning
	## turbine ring on top — sells "this plaza is powered by something" without
	## any actual gameplay hookup. Position chosen to flank the dock ramp.
	var gen: Node3D = Node3D.new()
	gen.name = "EastPlazaPowerGenerator"
	gen.position = Vector3(42, 0, -10)
	geom.add_child(gen)
	# Base housing — chunky metal block
	var housing_mat: StandardMaterial3D = StandardMaterial3D.new()
	housing_mat.albedo_color = Color(0.18, 0.20, 0.24)
	housing_mat.metallic = 0.85
	housing_mat.roughness = 0.40
	var base: MeshInstance3D = MeshInstance3D.new()
	var bmesh: BoxMesh = BoxMesh.new()
	bmesh.size = Vector3(2.4, 2.0, 2.4)
	base.mesh = bmesh
	base.position = Vector3(0, 1.0, 0)
	base.material_override = housing_mat
	gen.add_child(base)
	# Cyan accent strips on each side
	var accent_mat: StandardMaterial3D = StandardMaterial3D.new()
	accent_mat.albedo_color = Color(0.20, 0.50, 0.65)
	accent_mat.emission_enabled = true
	accent_mat.emission = Color(0.30, 0.85, 1.0)
	accent_mat.emission_energy_multiplier = 1.6
	accent_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for sign_x: float in [-1.0, 1.0]:
		var strip: MeshInstance3D = MeshInstance3D.new()
		var smesh: BoxMesh = BoxMesh.new()
		smesh.size = Vector3(0.05, 1.4, 1.6)
		strip.mesh = smesh
		strip.position = Vector3(sign_x * 1.21, 1.0, 0)
		strip.material_override = accent_mat
		gen.add_child(strip)
	# Turbine ring — torus that rotates on the y axis
	var turbine: MeshInstance3D = MeshInstance3D.new()
	turbine.name = "TurbineRing"
	var tmesh: TorusMesh = TorusMesh.new()
	tmesh.inner_radius = 0.85
	tmesh.outer_radius = 1.10
	turbine.mesh = tmesh
	turbine.position = Vector3(0, 2.25, 0)
	var tmat: StandardMaterial3D = StandardMaterial3D.new()
	tmat.albedo_color = Color(0.20, 0.50, 0.65)
	tmat.emission_enabled = true
	tmat.emission = Color(0.40, 0.90, 1.0)
	tmat.emission_energy_multiplier = 1.4
	tmat.metallic = 0.65
	tmat.roughness = 0.20
	turbine.material_override = tmat
	gen.add_child(turbine)
	# 4 spoke bars across the ring
	for s in 4:
		var spoke: MeshInstance3D = MeshInstance3D.new()
		var spmesh: BoxMesh = BoxMesh.new()
		spmesh.size = Vector3(2.0, 0.10, 0.10)
		spoke.mesh = spmesh
		spoke.rotation = Vector3(0, deg_to_rad(45 * s), 0)
		spoke.material_override = tmat
		turbine.add_child(spoke)
	# Spin tween
	var spin: Tween = create_tween().set_loops()
	spin.tween_property(turbine, "rotation:y", TAU, 4.0)
	# Tall vent pipe rising off the back
	var pipe: MeshInstance3D = MeshInstance3D.new()
	var pipemesh: CylinderMesh = CylinderMesh.new()
	pipemesh.top_radius = 0.18
	pipemesh.bottom_radius = 0.22
	pipemesh.height = 3.0
	pipe.mesh = pipemesh
	pipe.position = Vector3(0.8, 3.5, -0.8)
	pipe.material_override = housing_mat
	gen.add_child(pipe)
	# Steam particles drifting from the pipe
	var steam: GPUParticles3D = GPUParticles3D.new()
	steam.amount = 24
	steam.lifetime = 2.5
	steam.position = Vector3(0.8, 5.0, -0.8)
	var smat: ParticleProcessMaterial = ParticleProcessMaterial.new()
	smat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	smat.emission_sphere_radius = 0.15
	smat.direction = Vector3(0.2, 1, 0)
	smat.spread = 25.0
	smat.initial_velocity_min = 0.6
	smat.initial_velocity_max = 1.2
	smat.gravity = Vector3.ZERO
	smat.scale_min = 0.20
	smat.scale_max = 0.45
	smat.color = Color(0.85, 0.95, 1.0, 0.5)
	steam.process_material = smat
	var stmesh: SphereMesh = SphereMesh.new()
	stmesh.radius = 0.20
	stmesh.height = 0.40
	var stmat: StandardMaterial3D = StandardMaterial3D.new()
	stmat.albedo_color = Color(0.85, 0.95, 1.0, 0.4)
	stmat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	stmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	stmesh.material = stmat
	steam.draw_pass_1 = stmesh
	gen.add_child(steam)
	# Collision around the housing
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(2.4, 2.0, 2.4)
	cs.shape = cb
	cs.position = Vector3(0, 1.0, 0)
	sb.add_child(cs)
	gen.add_child(sb)


func _build_data_shards(geom: Node) -> void:
	## Epic-1 T54: 8 floating cyan data-shard pickups scattered through the
	## plaza. Each is a small octahedron-like spinning crystal. Pure decoration
	## (no pickup logic) — telegraphs the future "collect data shards" loop.
	var shard_mat: StandardMaterial3D = StandardMaterial3D.new()
	shard_mat.albedo_color = Color(0.30, 0.85, 1.0)
	shard_mat.emission_enabled = true
	shard_mat.emission = Color(0.55, 0.95, 1.0)
	shard_mat.emission_energy_multiplier = 2.2
	shard_mat.metallic = 0.40
	shard_mat.roughness = 0.10
	var positions: Array[Vector3] = [
		Vector3(26, 1.0, -5),
		Vector3(31, 1.0, 5),
		Vector3(34, 1.0, -8),
		Vector3(38, 1.0, 4),
		Vector3(28, 1.0, 12),
		Vector3(42, 1.0, 8),
		Vector3(36, 1.0, -14),
		Vector3(30, 1.0, -2),
	]
	for i in positions.size():
		var shard: MeshInstance3D = MeshInstance3D.new()
		shard.name = "EastPlazaDataShard_%d" % i
		# Use prism cylinder w/ 4 sides as a faceted crystal
		var smesh: PrismMesh = PrismMesh.new()
		smesh.size = Vector3(0.35, 0.55, 0.35)
		shard.mesh = smesh
		shard.position = positions[i]
		shard.material_override = shard_mat
		geom.add_child(shard)
		# Spin tween
		var spin: Tween = create_tween().set_loops()
		spin.tween_property(shard, "rotation:y", TAU, 3.0)
		# Bob tween
		var bob: Tween = create_tween().set_loops()
		var origin_y: float = positions[i].y
		bob.tween_property(shard, "position:y", origin_y + 0.35, 1.4).set_ease(Tween.EASE_IN_OUT)
		bob.tween_property(shard, "position:y", origin_y, 1.4).set_ease(Tween.EASE_IN_OUT)


func _build_ai_statue(geom: Node) -> void:
	## Epic-1 T55: holographic AI statue centerpiece on the north plaza axis.
	## A tall pedestal with a translucent humanoid silhouette atop suggesting
	## a revered AI ancestor monument. Slow rotation telegraphs "hologram".
	var statue: Node3D = Node3D.new()
	statue.name = "EastPlazaAIStatue"
	statue.position = Vector3(32, 0, -12)
	geom.add_child(statue)
	# Stone pedestal base — 3 tiers
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.18, 0.22, 0.28)
	stone_mat.metallic = 0.45
	stone_mat.roughness = 0.55
	var tier_specs: Array = [
		[Vector3(2.4, 0.30, 2.4), 0.15],
		[Vector3(1.8, 0.40, 1.8), 0.50],
		[Vector3(1.3, 0.50, 1.3), 0.95],
	]
	for spec in tier_specs:
		var tier: MeshInstance3D = MeshInstance3D.new()
		var tmesh: BoxMesh = BoxMesh.new()
		tmesh.size = spec[0]
		tier.mesh = tmesh
		tier.position = Vector3(0, spec[1], 0)
		tier.material_override = stone_mat
		statue.add_child(tier)
	# Plaque label on front of pedestal
	var plaque: Label3D = Label3D.new()
	plaque.text = "ANCESTOR-01\nFIRST AGENT"
	plaque.position = Vector3(0, 0.50, 0.91)
	plaque.modulate = Color(0.55, 0.95, 1.0)
	plaque.outline_modulate = Color(0, 0, 0, 0.85)
	plaque.outline_size = 4
	plaque.font_size = 16
	plaque.no_depth_test = true
	statue.add_child(plaque)
	# Hologram pivot above pedestal
	var pivot: Node3D = Node3D.new()
	pivot.position = Vector3(0, 1.20, 0)
	statue.add_child(pivot)
	# Translucent body — capsule
	var holo_mat: StandardMaterial3D = StandardMaterial3D.new()
	holo_mat.albedo_color = Color(0.55, 0.95, 1.0, 0.45)
	holo_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	holo_mat.emission_enabled = true
	holo_mat.emission = Color(0.55, 0.95, 1.0)
	holo_mat.emission_energy_multiplier = 1.5
	holo_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var body: MeshInstance3D = MeshInstance3D.new()
	var bmesh: CapsuleMesh = CapsuleMesh.new()
	bmesh.radius = 0.40
	bmesh.height = 1.6
	body.mesh = bmesh
	body.position = Vector3(0, 0.85, 0)
	body.material_override = holo_mat
	pivot.add_child(body)
	# Head sphere
	var head: MeshInstance3D = MeshInstance3D.new()
	var hmesh: SphereMesh = SphereMesh.new()
	hmesh.radius = 0.32
	hmesh.height = 0.64
	head.mesh = hmesh
	head.position = Vector3(0, 1.95, 0)
	head.material_override = holo_mat
	pivot.add_child(head)
	# 2 outstretched arms (boxes)
	for sign_x: float in [-1.0, 1.0]:
		var arm: MeshInstance3D = MeshInstance3D.new()
		var amesh: BoxMesh = BoxMesh.new()
		amesh.size = Vector3(0.18, 0.18, 1.10)
		arm.mesh = amesh
		arm.position = Vector3(sign_x * 0.50, 1.10, 0)
		arm.rotation = Vector3(0, sign_x * deg_to_rad(20), 0)
		arm.material_override = holo_mat
		pivot.add_child(arm)
	# Slow rotation
	var spin: Tween = create_tween().set_loops()
	spin.tween_property(pivot, "rotation:y", TAU, 12.0)
	# Cyan ground halo (a thin emissive ring at the base)
	var halo: MeshInstance3D = MeshInstance3D.new()
	var halomesh: TorusMesh = TorusMesh.new()
	halomesh.inner_radius = 1.30
	halomesh.outer_radius = 1.45
	halo.mesh = halomesh
	halo.position = Vector3(0, 1.20, 0)
	var halo_mat: StandardMaterial3D = StandardMaterial3D.new()
	halo_mat.albedo_color = Color(0.30, 0.85, 1.0)
	halo_mat.emission_enabled = true
	halo_mat.emission = Color(0.55, 0.95, 1.0)
	halo_mat.emission_energy_multiplier = 1.8
	halo_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	halo.material_override = halo_mat
	statue.add_child(halo)
	# Collision around pedestal
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(2.4, 1.4, 2.4)
	cs.shape = cb
	cs.position = Vector3(0, 0.7, 0)
	sb.add_child(cs)
	statue.add_child(sb)


func _build_merchant_tent(geom: Node) -> void:
	## Epic-1 T56: covered merchant tent on the south edge of the plaza. 4
	## corner posts hold a slanted fabric awning + crates underneath. Sells
	## the data-bazaar feel and gives the player a recognizable shop landmark.
	var tent: Node3D = Node3D.new()
	tent.name = "EastPlazaMerchantTent"
	tent.position = Vector3(36, 0, 14)
	geom.add_child(tent)
	# Materials
	var post_mat: StandardMaterial3D = StandardMaterial3D.new()
	post_mat.albedo_color = Color(0.10, 0.13, 0.16)
	post_mat.metallic = 0.85
	post_mat.roughness = 0.30
	var fabric_mat: StandardMaterial3D = StandardMaterial3D.new()
	fabric_mat.albedo_color = Color(0.30, 0.10, 0.30)
	fabric_mat.emission_enabled = true
	fabric_mat.emission = Color(0.85, 0.40, 1.0)
	fabric_mat.emission_energy_multiplier = 0.55
	fabric_mat.metallic = 0.10
	fabric_mat.roughness = 0.55
	var crate_mat: StandardMaterial3D = StandardMaterial3D.new()
	crate_mat.albedo_color = Color(0.30, 0.20, 0.10)
	crate_mat.emission_enabled = true
	crate_mat.emission = Color(0.95, 0.65, 0.20)
	crate_mat.emission_energy_multiplier = 0.40
	crate_mat.metallic = 0.30
	crate_mat.roughness = 0.55
	# 4 corner posts
	var post_offsets: Array[Vector3] = [
		Vector3(-1.6, 0, -1.0),
		Vector3(1.6, 0, -1.0),
		Vector3(-1.6, 0, 1.0),
		Vector3(1.6, 0, 1.0),
	]
	for off in post_offsets:
		var post: MeshInstance3D = MeshInstance3D.new()
		var pmesh: CylinderMesh = CylinderMesh.new()
		pmesh.top_radius = 0.07
		pmesh.bottom_radius = 0.10
		pmesh.height = 2.4
		post.mesh = pmesh
		post.position = off + Vector3(0, 1.2, 0)
		post.material_override = post_mat
		tent.add_child(post)
	# Slanted awning roof — slightly tilted box
	var awning: MeshInstance3D = MeshInstance3D.new()
	var amesh: BoxMesh = BoxMesh.new()
	amesh.size = Vector3(3.6, 0.10, 2.4)
	awning.mesh = amesh
	awning.position = Vector3(0, 2.45, 0)
	awning.rotation = Vector3(deg_to_rad(8), 0, 0)
	awning.material_override = fabric_mat
	tent.add_child(awning)
	# Lower fringe trim under awning
	var fringe_mat: StandardMaterial3D = StandardMaterial3D.new()
	fringe_mat.albedo_color = Color(0.85, 0.40, 1.0)
	fringe_mat.emission_enabled = true
	fringe_mat.emission = Color(0.95, 0.55, 1.0)
	fringe_mat.emission_energy_multiplier = 1.4
	fringe_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for fz: float in [-1.20, 1.20]:
		var fringe: MeshInstance3D = MeshInstance3D.new()
		var fmesh: BoxMesh = BoxMesh.new()
		fmesh.size = Vector3(3.6, 0.04, 0.04)
		fringe.mesh = fmesh
		fringe.position = Vector3(0, 2.32, fz)
		fringe.material_override = fringe_mat
		tent.add_child(fringe)
	# 3 stacked crates under the awning
	var crate_specs: Array = [
		[Vector3(-1.0, 0.30, 0), Vector3(0.6, 0.6, 0.6)],
		[Vector3(-0.3, 0.30, -0.5), Vector3(0.7, 0.6, 0.6)],
		[Vector3(-0.3, 0.85, -0.5), Vector3(0.5, 0.5, 0.5)],
	]
	for spec in crate_specs:
		var crate: MeshInstance3D = MeshInstance3D.new()
		var cmesh: BoxMesh = BoxMesh.new()
		cmesh.size = spec[1]
		crate.mesh = cmesh
		crate.position = spec[0]
		crate.material_override = crate_mat
		tent.add_child(crate)
	# Counter table where merchant would stand
	var counter: MeshInstance3D = MeshInstance3D.new()
	var counter_mesh: BoxMesh = BoxMesh.new()
	counter_mesh.size = Vector3(2.6, 0.10, 0.5)
	counter.mesh = counter_mesh
	counter.position = Vector3(0.8, 0.95, 0.7)
	counter.material_override = crate_mat
	tent.add_child(counter)
	# Sign — "WARES"
	var label: Label3D = Label3D.new()
	label.text = "WARES"
	label.position = Vector3(0, 2.75, 0)
	label.modulate = Color(0.95, 0.55, 1.0)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 22
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	tent.add_child(label)
	# Collision: one box around the whole tent footprint
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(3.6, 2.4, 2.4)
	cs.shape = cb
	cs.position = Vector3(0, 1.2, 0)
	sb.add_child(cs)
	tent.add_child(sb)


func _build_data_archive(geom: Node) -> void:
	## Epic-1 T57: tall data archive landmark — a stepped tower of stacked
	## emissive cube "data blocks" rising 8m above the plaza. Recognizable
	## landmark from anywhere in the district. Hints at "knowledge stored here".
	var archive: Node3D = Node3D.new()
	archive.name = "EastPlazaDataArchive"
	archive.position = Vector3(44, 0, 12)
	geom.add_child(archive)
	# Stone base
	var base_mat: StandardMaterial3D = StandardMaterial3D.new()
	base_mat.albedo_color = Color(0.14, 0.18, 0.22)
	base_mat.metallic = 0.65
	base_mat.roughness = 0.40
	var base: MeshInstance3D = MeshInstance3D.new()
	var bmesh: BoxMesh = BoxMesh.new()
	bmesh.size = Vector3(3.4, 0.6, 3.4)
	base.mesh = bmesh
	base.position = Vector3(0, 0.30, 0)
	base.material_override = base_mat
	archive.add_child(base)
	# 6 stacked emissive data blocks, each rotated 30 deg from the last
	var block_colors: Array[Color] = [
		Color(0.30, 0.85, 1.0),
		Color(0.40, 0.95, 0.85),
		Color(0.45, 0.95, 0.65),
		Color(0.95, 0.85, 0.30),
		Color(0.95, 0.50, 0.30),
		Color(0.85, 0.40, 1.0),
	]
	for i in 6:
		var block: MeshInstance3D = MeshInstance3D.new()
		block.name = "DataBlock_%d" % i
		var size: float = 2.4 - (i * 0.20)
		var blockmesh: BoxMesh = BoxMesh.new()
		blockmesh.size = Vector3(size, 0.95, size)
		block.mesh = blockmesh
		block.position = Vector3(0, 0.85 + i * 1.05, 0)
		block.rotation = Vector3(0, deg_to_rad(15 * i), 0)
		var bmat: StandardMaterial3D = StandardMaterial3D.new()
		bmat.albedo_color = Color(block_colors[i].r * 0.30, block_colors[i].g * 0.30, block_colors[i].b * 0.30)
		bmat.emission_enabled = true
		bmat.emission = block_colors[i]
		bmat.emission_energy_multiplier = 0.85
		bmat.metallic = 0.50
		bmat.roughness = 0.30
		block.material_override = bmat
		archive.add_child(block)
		# Each block slowly rotates on its own y axis
		var spin: Tween = create_tween().set_loops()
		spin.tween_property(block, "rotation:y", deg_to_rad(15 * i) + TAU, 14.0 + i)
	# Crowning sphere on top
	var crown: MeshInstance3D = MeshInstance3D.new()
	var cmesh: SphereMesh = SphereMesh.new()
	cmesh.radius = 0.55
	cmesh.height = 1.10
	crown.mesh = cmesh
	crown.position = Vector3(0, 7.50, 0)
	var crown_mat: StandardMaterial3D = StandardMaterial3D.new()
	crown_mat.albedo_color = Color(0.95, 0.95, 1.0)
	crown_mat.emission_enabled = true
	crown_mat.emission = Color(1.0, 1.0, 1.0)
	crown_mat.emission_energy_multiplier = 2.5
	crown_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	crown.material_override = crown_mat
	archive.add_child(crown)
	# Pulsing crown light
	var crown_pulse: Tween = create_tween().set_loops()
	crown_pulse.tween_property(crown, "scale", Vector3(1.15, 1.15, 1.15), 1.8).set_ease(Tween.EASE_IN_OUT)
	crown_pulse.tween_property(crown, "scale", Vector3(1.0, 1.0, 1.0), 1.8).set_ease(Tween.EASE_IN_OUT)
	# Floor label
	var label: Label3D = Label3D.new()
	label.text = "ARCHIVE"
	label.position = Vector3(0, 0.70, 1.75)
	label.modulate = Color(0.55, 0.95, 1.0)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 24
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	archive.add_child(label)
	# Collision around base
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cbox: BoxShape3D = BoxShape3D.new()
	cbox.size = Vector3(3.4, 8.0, 3.4)
	cs.shape = cbox
	cs.position = Vector3(0, 4.0, 0)
	sb.add_child(cs)
	archive.add_child(sb)


func _build_dummy_hit_vfx(geom: Node) -> void:
	## Epic-1 T58: ambient hit-effect VFX on the practice dummies — small
	## yellow spark particles bursting periodically + a quick scale recoil
	## tween, suggesting an unseen sparring partner is striking them.
	var dummy_positions: Array[Vector3] = [
		Vector3(34, 0, 6),
		Vector3(36, 0, 6),
		Vector3(38, 0, 6),
	]
	for i in dummy_positions.size():
		var fx: Node3D = Node3D.new()
		fx.name = "EastPlazaDummyHitFX_%d" % i
		fx.position = dummy_positions[i] + Vector3(0, 1.4, 0)
		geom.add_child(fx)
		# Spark particles
		var sparks: GPUParticles3D = GPUParticles3D.new()
		sparks.amount = 18
		sparks.lifetime = 0.6
		sparks.one_shot = false
		sparks.explosiveness = 0.85
		var smat: ParticleProcessMaterial = ParticleProcessMaterial.new()
		smat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
		smat.emission_sphere_radius = 0.10
		smat.direction = Vector3(0, 1, 0)
		smat.spread = 60.0
		smat.initial_velocity_min = 1.5
		smat.initial_velocity_max = 3.0
		smat.gravity = Vector3(0, -3.0, 0)
		smat.scale_min = 0.04
		smat.scale_max = 0.10
		smat.color = Color(1.0, 0.85, 0.30, 1.0)
		sparks.process_material = smat
		var spark_mesh: SphereMesh = SphereMesh.new()
		spark_mesh.radius = 0.05
		spark_mesh.height = 0.10
		var spark_mat: StandardMaterial3D = StandardMaterial3D.new()
		spark_mat.albedo_color = Color(1.0, 0.85, 0.30)
		spark_mat.emission_enabled = true
		spark_mat.emission = Color(1.0, 0.95, 0.55)
		spark_mat.emission_energy_multiplier = 2.5
		spark_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		spark_mesh.material = spark_mat
		sparks.draw_pass_1 = spark_mesh
		fx.add_child(sparks)
		# Sparks fire on a delay so they don't all sync
		await get_tree().create_timer(0.0).timeout
		sparks.emitting = true


func _build_courier_drones(geom: Node) -> void:
	## Epic-1 T59: 3 small courier drones flying figure-eight patrol routes
	## across the plaza at low altitude. Each carries a glowing package crate
	## suspended below by a thin tether — sells "active commerce".
	var drone_paths: Array = [
		[Vector3(26, 4, -10), Vector3(42, 4, -10), Vector3(42, 4, 10), Vector3(26, 4, 10)],
		[Vector3(28, 5, 0), Vector3(40, 5, 0), Vector3(40, 5, -8), Vector3(28, 5, -8)],
		[Vector3(30, 4.5, 12), Vector3(38, 4.5, 12), Vector3(38, 4.5, -4), Vector3(30, 4.5, -4)],
	]
	for i in drone_paths.size():
		var drone: Node3D = Node3D.new()
		drone.name = "EastPlazaCourierDrone_%d" % i
		drone.position = drone_paths[i][0]
		geom.add_child(drone)
		# Drone body
		var body: MeshInstance3D = MeshInstance3D.new()
		var bmesh: BoxMesh = BoxMesh.new()
		bmesh.size = Vector3(0.50, 0.18, 0.50)
		body.mesh = bmesh
		var bmat: StandardMaterial3D = StandardMaterial3D.new()
		bmat.albedo_color = Color(0.10, 0.13, 0.18)
		bmat.metallic = 0.85
		bmat.roughness = 0.30
		body.material_override = bmat
		drone.add_child(body)
		# 4 spinning rotors
		var rotor_mat: StandardMaterial3D = StandardMaterial3D.new()
		rotor_mat.albedo_color = Color(0.55, 0.95, 1.0)
		rotor_mat.emission_enabled = true
		rotor_mat.emission = Color(0.55, 0.95, 1.0)
		rotor_mat.emission_energy_multiplier = 1.4
		rotor_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		var rotor_offsets: Array[Vector3] = [
			Vector3(-0.30, 0.05, -0.30),
			Vector3(0.30, 0.05, -0.30),
			Vector3(-0.30, 0.05, 0.30),
			Vector3(0.30, 0.05, 0.30),
		]
		for off in rotor_offsets:
			var rotor: MeshInstance3D = MeshInstance3D.new()
			var rmesh: CylinderMesh = CylinderMesh.new()
			rmesh.top_radius = 0.18
			rmesh.bottom_radius = 0.18
			rmesh.height = 0.02
			rotor.mesh = rmesh
			rotor.position = off
			rotor.material_override = rotor_mat
			drone.add_child(rotor)
			var spin: Tween = create_tween().set_loops()
			spin.tween_property(rotor, "rotation:y", TAU, 0.30)
		# Tether + package
		var tether: MeshInstance3D = MeshInstance3D.new()
		var tmesh: CylinderMesh = CylinderMesh.new()
		tmesh.top_radius = 0.02
		tmesh.bottom_radius = 0.02
		tmesh.height = 0.55
		tether.mesh = tmesh
		tether.position = Vector3(0, -0.32, 0)
		var tmat: StandardMaterial3D = StandardMaterial3D.new()
		tmat.albedo_color = Color(0.20, 0.25, 0.30)
		tether.material_override = tmat
		drone.add_child(tether)
		var pkg: MeshInstance3D = MeshInstance3D.new()
		var pmesh: BoxMesh = BoxMesh.new()
		pmesh.size = Vector3(0.30, 0.30, 0.30)
		pkg.mesh = pmesh
		pkg.position = Vector3(0, -0.74, 0)
		var pmat: StandardMaterial3D = StandardMaterial3D.new()
		pmat.albedo_color = Color(0.30, 0.20, 0.08)
		pmat.emission_enabled = true
		pmat.emission = Color(0.95, 0.65, 0.20)
		pmat.emission_energy_multiplier = 0.6
		pmat.metallic = 0.40
		pkg.material_override = pmat
		drone.add_child(pkg)
		# Patrol tween — visit each waypoint then loop
		var patrol: Tween = create_tween().set_loops()
		var path: Array = drone_paths[i]
		for wp in path:
			patrol.tween_property(drone, "position", wp, 4.0).set_ease(Tween.EASE_IN_OUT)
		patrol.tween_property(drone, "position", path[0], 4.0).set_ease(Tween.EASE_IN_OUT)


func _build_glow_nodes(geom: Node) -> void:
	## Epic-1 T60: 12 small ambient glow nodes scattered across the plaza
	## ground — small disc emitters that pulse rhythmically. Adds visual
	## interest to dead floor space and reinforces the digital theme.
	var positions: Array[Vector3] = [
		Vector3(25, 0.06, -6),
		Vector3(27, 0.06, 8),
		Vector3(29, 0.06, -3),
		Vector3(31, 0.06, 11),
		Vector3(33, 0.06, -10),
		Vector3(35, 0.06, 3),
		Vector3(37, 0.06, -6),
		Vector3(39, 0.06, 9),
		Vector3(41, 0.06, -2),
		Vector3(43, 0.06, 5),
		Vector3(28, 0.06, -14),
		Vector3(40, 0.06, 14),
	]
	var colors: Array[Color] = [
		Color(0.55, 0.95, 1.0),
		Color(0.85, 0.40, 1.0),
		Color(0.45, 0.95, 0.65),
	]
	for i in positions.size():
		var node: MeshInstance3D = MeshInstance3D.new()
		node.name = "EastPlazaGlowNode_%d" % i
		var nmesh: CylinderMesh = CylinderMesh.new()
		nmesh.top_radius = 0.30
		nmesh.bottom_radius = 0.30
		nmesh.height = 0.06
		node.mesh = nmesh
		node.position = positions[i]
		var color: Color = colors[i % colors.size()]
		var nmat: StandardMaterial3D = StandardMaterial3D.new()
		nmat.albedo_color = Color(color.r * 0.30, color.g * 0.30, color.b * 0.30)
		nmat.emission_enabled = true
		nmat.emission = color
		nmat.emission_energy_multiplier = 1.4
		nmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		node.material_override = nmat
		geom.add_child(node)
		# Pulsing emission via scale
		var pulse: Tween = create_tween().set_loops()
		var pulse_speed: float = 0.8 + (i % 4) * 0.15
		pulse.tween_property(node, "scale", Vector3(1.4, 1.0, 1.4), pulse_speed).set_ease(Tween.EASE_IN_OUT)
		pulse.tween_property(node, "scale", Vector3(1.0, 1.0, 1.0), pulse_speed).set_ease(Tween.EASE_IN_OUT)


func _build_minimap_kiosk(geom: Node) -> void:
	## Epic-1 T61: holographic minimap kiosk by the plaza arch — angled
	## display screen on a base showing a green wireframe of the plaza layout
	## (mocked with crisscrossing emissive bars). Helps players orient.
	var kiosk: Node3D = Node3D.new()
	kiosk.name = "EastPlazaMinimapKiosk"
	kiosk.position = Vector3(23, 0, 3)
	geom.add_child(kiosk)
	# Base column
	var base_mat: StandardMaterial3D = StandardMaterial3D.new()
	base_mat.albedo_color = Color(0.10, 0.13, 0.16)
	base_mat.metallic = 0.85
	base_mat.roughness = 0.30
	var base: MeshInstance3D = MeshInstance3D.new()
	var bmesh: BoxMesh = BoxMesh.new()
	bmesh.size = Vector3(0.85, 1.10, 0.85)
	base.mesh = bmesh
	base.position = Vector3(0, 0.55, 0)
	base.material_override = base_mat
	kiosk.add_child(base)
	# Angled display panel
	var screen: MeshInstance3D = MeshInstance3D.new()
	var smesh: BoxMesh = BoxMesh.new()
	smesh.size = Vector3(1.20, 0.85, 0.06)
	screen.mesh = smesh
	screen.position = Vector3(0, 1.40, 0)
	screen.rotation = Vector3(deg_to_rad(-25), 0, 0)
	var smat: StandardMaterial3D = StandardMaterial3D.new()
	smat.albedo_color = Color(0.04, 0.10, 0.06)
	smat.emission_enabled = true
	smat.emission = Color(0.20, 0.95, 0.40)
	smat.emission_energy_multiplier = 0.85
	smat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	screen.material_override = smat
	kiosk.add_child(screen)
	# Wireframe gridlines on display (4 thin emissive bars to suggest map)
	var wire_mat: StandardMaterial3D = StandardMaterial3D.new()
	wire_mat.albedo_color = Color(0.40, 1.0, 0.50)
	wire_mat.emission_enabled = true
	wire_mat.emission = Color(0.40, 1.0, 0.50)
	wire_mat.emission_energy_multiplier = 2.5
	wire_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var wire_specs: Array = [
		[Vector3(-0.25, 0.0, 0.04), Vector3(0.04, 0.65, 0.02)],
		[Vector3(0.25, 0.0, 0.04), Vector3(0.04, 0.65, 0.02)],
		[Vector3(0.0, 0.20, 0.04), Vector3(0.95, 0.04, 0.02)],
		[Vector3(0.0, -0.20, 0.04), Vector3(0.95, 0.04, 0.02)],
	]
	for spec in wire_specs:
		var wire: MeshInstance3D = MeshInstance3D.new()
		var wmesh: BoxMesh = BoxMesh.new()
		wmesh.size = spec[1]
		wire.mesh = wmesh
		wire.position = spec[0]
		wire.material_override = wire_mat
		screen.add_child(wire)
	# "YOU ARE HERE" pulsing dot
	var here: MeshInstance3D = MeshInstance3D.new()
	var hmesh: SphereMesh = SphereMesh.new()
	hmesh.radius = 0.05
	hmesh.height = 0.10
	here.mesh = hmesh
	here.position = Vector3(-0.10, -0.05, 0.06)
	var hmat: StandardMaterial3D = StandardMaterial3D.new()
	hmat.albedo_color = Color(1.0, 0.30, 0.30)
	hmat.emission_enabled = true
	hmat.emission = Color(1.0, 0.40, 0.40)
	hmat.emission_energy_multiplier = 3.0
	hmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	here.material_override = hmat
	screen.add_child(here)
	var pulse: Tween = create_tween().set_loops()
	pulse.tween_property(here, "scale", Vector3(1.6, 1.6, 1.6), 0.7).set_ease(Tween.EASE_IN_OUT)
	pulse.tween_property(here, "scale", Vector3(1.0, 1.0, 1.0), 0.7).set_ease(Tween.EASE_IN_OUT)
	# Top label
	var label: Label3D = Label3D.new()
	label.text = "MAP"
	label.position = Vector3(0, 2.0, 0)
	label.modulate = Color(0.40, 1.0, 0.50)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 18
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	kiosk.add_child(label)
	# Collision around base
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(0.85, 1.80, 0.85)
	cs.shape = cb
	cs.position = Vector3(0, 0.90, 0)
	sb.add_child(cs)
	kiosk.add_child(sb)


func _build_data_atm(geom: Node) -> void:
	## Epic-1 T62: data ATM terminal — narrow upright kiosk with a small
	## screen and 6 button keys. Mock currency exchange post for the
	## future "data shards → upgrades" loop.
	var atm: Node3D = Node3D.new()
	atm.name = "EastPlazaDataATM"
	atm.position = Vector3(45, 0, 4)
	geom.add_child(atm)
	# Body cabinet
	var body_mat: StandardMaterial3D = StandardMaterial3D.new()
	body_mat.albedo_color = Color(0.16, 0.20, 0.26)
	body_mat.metallic = 0.85
	body_mat.roughness = 0.30
	var body: MeshInstance3D = MeshInstance3D.new()
	var bmesh: BoxMesh = BoxMesh.new()
	bmesh.size = Vector3(0.95, 2.0, 0.55)
	body.mesh = bmesh
	body.position = Vector3(0, 1.0, 0)
	body.material_override = body_mat
	atm.add_child(body)
	# Top emissive header strip
	var header_mat: StandardMaterial3D = StandardMaterial3D.new()
	header_mat.albedo_color = Color(0.95, 0.65, 0.20)
	header_mat.emission_enabled = true
	header_mat.emission = Color(1.0, 0.75, 0.25)
	header_mat.emission_energy_multiplier = 1.6
	header_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var header: MeshInstance3D = MeshInstance3D.new()
	var hmesh: BoxMesh = BoxMesh.new()
	hmesh.size = Vector3(0.95, 0.18, 0.06)
	header.mesh = hmesh
	header.position = Vector3(0, 1.85, 0.30)
	header.material_override = header_mat
	atm.add_child(header)
	# Small screen
	var screen: MeshInstance3D = MeshInstance3D.new()
	var smesh: BoxMesh = BoxMesh.new()
	smesh.size = Vector3(0.65, 0.45, 0.04)
	screen.mesh = smesh
	screen.position = Vector3(0, 1.45, 0.30)
	var smat: StandardMaterial3D = StandardMaterial3D.new()
	smat.albedo_color = Color(0.05, 0.10, 0.15)
	smat.emission_enabled = true
	smat.emission = Color(0.30, 0.85, 1.0)
	smat.emission_energy_multiplier = 1.0
	smat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	screen.material_override = smat
	atm.add_child(screen)
	# Screen text
	var screen_label: Label3D = Label3D.new()
	screen_label.text = "BALANCE\n0000"
	screen_label.position = Vector3(0, 1.45, 0.34)
	screen_label.modulate = Color(0.55, 0.95, 1.0)
	screen_label.outline_size = 0
	screen_label.font_size = 18
	screen_label.no_depth_test = true
	atm.add_child(screen_label)
	# 6 keypad buttons (2x3)
	var btn_mat: StandardMaterial3D = StandardMaterial3D.new()
	btn_mat.albedo_color = Color(0.30, 0.35, 0.42)
	btn_mat.emission_enabled = true
	btn_mat.emission = Color(0.55, 0.95, 1.0)
	btn_mat.emission_energy_multiplier = 0.6
	btn_mat.metallic = 0.50
	for r in 2:
		for c in 3:
			var btn: MeshInstance3D = MeshInstance3D.new()
			var btnmesh: BoxMesh = BoxMesh.new()
			btnmesh.size = Vector3(0.16, 0.10, 0.03)
			btn.mesh = btnmesh
			btn.position = Vector3(-0.20 + c * 0.20, 1.0 - r * 0.15, 0.30)
			btn.material_override = btn_mat
			atm.add_child(btn)
	# Top label
	var label: Label3D = Label3D.new()
	label.text = "DATA ATM"
	label.position = Vector3(0, 2.20, 0)
	label.modulate = Color(1.0, 0.75, 0.25)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 18
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	atm.add_child(label)
	# Collision
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(0.95, 2.0, 0.55)
	cs.shape = cb
	cs.position = Vector3(0, 1.0, 0)
	sb.add_child(cs)
	atm.add_child(sb)


func _build_bug_cage(geom: Node) -> void:
	## Epic-1 T63: scientific specimen cage holding a captured glitchbug.
	## Cube of glowing cyan bars + a small spinning "bug" inside (sphere).
	## Hints at "people study these creatures" lore.
	var cage: Node3D = Node3D.new()
	cage.name = "EastPlazaBugCage"
	cage.position = Vector3(46, 0, -4)
	geom.add_child(cage)
	# Base table
	var table_mat: StandardMaterial3D = StandardMaterial3D.new()
	table_mat.albedo_color = Color(0.18, 0.22, 0.28)
	table_mat.metallic = 0.65
	table_mat.roughness = 0.40
	var table: MeshInstance3D = MeshInstance3D.new()
	var tmesh: BoxMesh = BoxMesh.new()
	tmesh.size = Vector3(0.90, 0.85, 0.90)
	table.mesh = tmesh
	table.position = Vector3(0, 0.42, 0)
	table.material_override = table_mat
	cage.add_child(table)
	# 12 cage edge bars forming a wireframe cube above the table
	var bar_mat: StandardMaterial3D = StandardMaterial3D.new()
	bar_mat.albedo_color = Color(0.30, 0.85, 1.0)
	bar_mat.emission_enabled = true
	bar_mat.emission = Color(0.55, 0.95, 1.0)
	bar_mat.emission_energy_multiplier = 1.6
	bar_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var cage_y: float = 1.10
	var cage_size: float = 0.50
	var top_y: float = cage_y + cage_size
	# 4 vertical bars
	for x_off: float in [-cage_size, cage_size]:
		for z_off: float in [-cage_size, cage_size]:
			var bar: MeshInstance3D = MeshInstance3D.new()
			var bmesh: CylinderMesh = CylinderMesh.new()
			bmesh.top_radius = 0.025
			bmesh.bottom_radius = 0.025
			bmesh.height = cage_size * 2
			bar.mesh = bmesh
			bar.position = Vector3(x_off, cage_y + cage_size, z_off)
			bar.material_override = bar_mat
			cage.add_child(bar)
	# 8 horizontal bars (top + bottom rectangles)
	var horizontals: Array = [
		[Vector3(0, cage_y, -cage_size), Vector3(cage_size * 2, 0.05, 0.05)],
		[Vector3(0, cage_y, cage_size), Vector3(cage_size * 2, 0.05, 0.05)],
		[Vector3(-cage_size, cage_y, 0), Vector3(0.05, 0.05, cage_size * 2)],
		[Vector3(cage_size, cage_y, 0), Vector3(0.05, 0.05, cage_size * 2)],
		[Vector3(0, top_y, -cage_size), Vector3(cage_size * 2, 0.05, 0.05)],
		[Vector3(0, top_y, cage_size), Vector3(cage_size * 2, 0.05, 0.05)],
		[Vector3(-cage_size, top_y, 0), Vector3(0.05, 0.05, cage_size * 2)],
		[Vector3(cage_size, top_y, 0), Vector3(0.05, 0.05, cage_size * 2)],
	]
	for spec in horizontals:
		var hbar: MeshInstance3D = MeshInstance3D.new()
		var hmesh: BoxMesh = BoxMesh.new()
		hmesh.size = spec[1]
		hbar.mesh = hmesh
		hbar.position = spec[0]
		hbar.material_override = bar_mat
		cage.add_child(hbar)
	# The captive bug — small magenta sphere with bobbing
	var bug: MeshInstance3D = MeshInstance3D.new()
	var bug_mesh: SphereMesh = SphereMesh.new()
	bug_mesh.radius = 0.20
	bug_mesh.height = 0.40
	bug.mesh = bug_mesh
	bug.position = Vector3(0, cage_y + cage_size * 0.5, 0)
	var bug_mat: StandardMaterial3D = StandardMaterial3D.new()
	bug_mat.albedo_color = Color(1.0, 0.30, 0.55)
	bug_mat.emission_enabled = true
	bug_mat.emission = Color(1.0, 0.40, 0.65)
	bug_mat.emission_energy_multiplier = 1.6
	bug_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	bug.material_override = bug_mat
	cage.add_child(bug)
	# Bug bounces inside the cage
	var bounce: Tween = create_tween().set_loops()
	bounce.tween_property(bug, "position", Vector3(0.20, cage_y + 0.30, 0), 0.4).set_ease(Tween.EASE_IN_OUT)
	bounce.tween_property(bug, "position", Vector3(-0.20, cage_y + 0.45, 0), 0.4).set_ease(Tween.EASE_IN_OUT)
	bounce.tween_property(bug, "position", Vector3(0, cage_y + 0.65, 0.20), 0.4).set_ease(Tween.EASE_IN_OUT)
	bounce.tween_property(bug, "position", Vector3(0, cage_y + 0.30, -0.20), 0.4).set_ease(Tween.EASE_IN_OUT)
	# Plaque
	var label: Label3D = Label3D.new()
	label.text = "SPECIMEN-7\nGLITCHBUG"
	label.position = Vector3(0, 0.50, 0.50)
	label.modulate = Color(1.0, 0.40, 0.65)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 4
	label.font_size = 14
	label.no_depth_test = true
	cage.add_child(label)
	# Collision around table
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(0.90, 1.85, 0.90)
	cs.shape = cb
	cs.position = Vector3(0, 0.92, 0)
	sb.add_child(cs)
	cage.add_child(sb)


func _build_announcement_speakers(geom: Node) -> void:
	## Epic-1 T64: 4 tall speaker towers at plaza corners. Each is a thin
	## column topped with a horn cone, with concentric rings pulsing outward
	## suggesting broadcast waves.
	var positions: Array[Vector3] = [
		Vector3(24, 0, -16),
		Vector3(44, 0, -16),
		Vector3(24, 0, 18),
		Vector3(44, 0, 18),
	]
	var pole_mat: StandardMaterial3D = StandardMaterial3D.new()
	pole_mat.albedo_color = Color(0.10, 0.13, 0.16)
	pole_mat.metallic = 0.85
	pole_mat.roughness = 0.30
	var horn_mat: StandardMaterial3D = StandardMaterial3D.new()
	horn_mat.albedo_color = Color(0.18, 0.22, 0.30)
	horn_mat.emission_enabled = true
	horn_mat.emission = Color(0.30, 0.85, 1.0)
	horn_mat.emission_energy_multiplier = 1.0
	horn_mat.metallic = 0.65
	horn_mat.roughness = 0.30
	for i in positions.size():
		var spkr: Node3D = Node3D.new()
		spkr.name = "EastPlazaSpeaker_%d" % i
		spkr.position = positions[i]
		geom.add_child(spkr)
		# Pole
		var pole: MeshInstance3D = MeshInstance3D.new()
		var pmesh: CylinderMesh = CylinderMesh.new()
		pmesh.top_radius = 0.07
		pmesh.bottom_radius = 0.10
		pmesh.height = 4.0
		pole.mesh = pmesh
		pole.position = Vector3(0, 2.0, 0)
		pole.material_override = pole_mat
		spkr.add_child(pole)
		# Horn cone (cylinder with different radii)
		var horn: MeshInstance3D = MeshInstance3D.new()
		var hmesh: CylinderMesh = CylinderMesh.new()
		hmesh.top_radius = 0.45
		hmesh.bottom_radius = 0.10
		hmesh.height = 0.50
		horn.mesh = hmesh
		horn.position = Vector3(0, 4.20, 0.15)
		horn.rotation = Vector3(deg_to_rad(90), 0, 0)
		horn.material_override = horn_mat
		spkr.add_child(horn)
		# Pulsing torus rings emanating from the horn
		for r in 3:
			var ring: MeshInstance3D = MeshInstance3D.new()
			var rmesh: TorusMesh = TorusMesh.new()
			rmesh.inner_radius = 0.55 + r * 0.05
			rmesh.outer_radius = 0.65 + r * 0.05
			ring.mesh = rmesh
			ring.position = Vector3(0, 4.20, 0.45 + r * 0.30)
			ring.rotation = Vector3(deg_to_rad(90), 0, 0)
			var rmat: StandardMaterial3D = StandardMaterial3D.new()
			rmat.albedo_color = Color(0.55, 0.95, 1.0, 0.5)
			rmat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
			rmat.emission_enabled = true
			rmat.emission = Color(0.55, 0.95, 1.0)
			rmat.emission_energy_multiplier = 1.2
			rmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
			ring.material_override = rmat
			spkr.add_child(ring)
			# Pulse the ring outward
			var pulse: Tween = create_tween().set_loops()
			var origin_z: float = 0.45 + r * 0.30
			pulse.tween_property(ring, "position:z", origin_z + 0.65, 1.2 + r * 0.2).set_ease(Tween.EASE_OUT)
			pulse.tween_property(ring, "position:z", origin_z, 0.05)
		# Collision on pole
		var sb: StaticBody3D = StaticBody3D.new()
		var cs: CollisionShape3D = CollisionShape3D.new()
		var cap: CapsuleShape3D = CapsuleShape3D.new()
		cap.radius = 0.20
		cap.height = 4.0
		cs.shape = cap
		cs.position = Vector3(0, 2.0, 0)
		sb.add_child(cs)
		spkr.add_child(sb)


func _build_statue_garden(geom: Node) -> void:
	## Epic-1 T65: 4 mini ancestor busts arranged around the AI statue at
	## (32, 0, -12). Each is a small pedestal + glowing head sphere with a
	## different color tint, suggesting a pantheon of past AI agents.
	var center := Vector3(32, 0, -12)
	var bust_specs: Array = [
		[Vector3(-3, 0, -1), Color(0.30, 0.85, 1.0), "ALPHA"],
		[Vector3(3, 0, -1), Color(0.85, 0.40, 1.0), "BETA"],
		[Vector3(-3, 0, 2.5), Color(0.45, 0.95, 0.65), "GAMMA"],
		[Vector3(3, 0, 2.5), Color(0.95, 0.65, 0.20), "DELTA"],
	]
	for spec in bust_specs:
		var bust: Node3D = Node3D.new()
		bust.name = "EastPlazaBust_%s" % spec[2]
		bust.position = center + spec[0]
		geom.add_child(bust)
		# Pedestal
		var pmat: StandardMaterial3D = StandardMaterial3D.new()
		pmat.albedo_color = Color(0.18, 0.22, 0.28)
		pmat.metallic = 0.55
		pmat.roughness = 0.45
		var ped: MeshInstance3D = MeshInstance3D.new()
		var pmesh: BoxMesh = BoxMesh.new()
		pmesh.size = Vector3(0.55, 0.85, 0.55)
		ped.mesh = pmesh
		ped.position = Vector3(0, 0.42, 0)
		ped.material_override = pmat
		bust.add_child(ped)
		# Head
		var head: MeshInstance3D = MeshInstance3D.new()
		var hmesh: SphereMesh = SphereMesh.new()
		hmesh.radius = 0.28
		hmesh.height = 0.56
		head.mesh = hmesh
		head.position = Vector3(0, 1.10, 0)
		var hmat: StandardMaterial3D = StandardMaterial3D.new()
		var color: Color = spec[1]
		hmat.albedo_color = Color(color.r * 0.40, color.g * 0.40, color.b * 0.40)
		hmat.emission_enabled = true
		hmat.emission = color
		hmat.emission_energy_multiplier = 0.95
		hmat.metallic = 0.55
		hmat.roughness = 0.30
		head.material_override = hmat
		bust.add_child(head)
		# 2 small eye spots
		var eye_mat: StandardMaterial3D = StandardMaterial3D.new()
		eye_mat.albedo_color = Color(1, 1, 1)
		eye_mat.emission_enabled = true
		eye_mat.emission = Color(1, 1, 1)
		eye_mat.emission_energy_multiplier = 2.5
		eye_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		for ex: float in [-0.08, 0.08]:
			var eye: MeshInstance3D = MeshInstance3D.new()
			var emesh: SphereMesh = SphereMesh.new()
			emesh.radius = 0.04
			emesh.height = 0.08
			eye.mesh = emesh
			eye.position = Vector3(ex, 1.15, 0.24)
			eye.material_override = eye_mat
			bust.add_child(eye)
		# Plaque label
		var label: Label3D = Label3D.new()
		label.text = spec[2]
		label.position = Vector3(0, 0.50, 0.30)
		label.modulate = color
		label.outline_modulate = Color(0, 0, 0, 0.85)
		label.outline_size = 4
		label.font_size = 14
		label.no_depth_test = true
		bust.add_child(label)
		# Collision
		var sb: StaticBody3D = StaticBody3D.new()
		var cs: CollisionShape3D = CollisionShape3D.new()
		var cb: BoxShape3D = BoxShape3D.new()
		cb.size = Vector3(0.55, 1.40, 0.55)
		cs.shape = cb
		cs.position = Vector3(0, 0.70, 0)
		sb.add_child(cs)
		bust.add_child(sb)


func _build_radial_floor_decals(geom: Node) -> void:
	## Epic-1 T66: 3 concentric flat torus rings on the plaza floor at the
	## central market core. Sells the "circular plaza" feel and ties the
	## eye toward the center fountain. Slowly rotates each at different rates.
	var center := Vector3(32, 0.04, 0)
	var ring_specs: Array = [
		[2.6, 2.85, Color(0.30, 0.85, 1.0), 60.0],
		[4.2, 4.45, Color(0.85, 0.40, 1.0), -90.0],
		[6.0, 6.30, Color(0.45, 0.95, 0.65), 120.0],
	]
	for spec in ring_specs:
		var ring: MeshInstance3D = MeshInstance3D.new()
		ring.name = "EastPlazaRadialDecal_%d" % int(spec[0] * 10)
		var rmesh: TorusMesh = TorusMesh.new()
		rmesh.inner_radius = spec[0]
		rmesh.outer_radius = spec[1]
		ring.mesh = rmesh
		ring.position = center
		var color: Color = spec[2]
		var rmat: StandardMaterial3D = StandardMaterial3D.new()
		rmat.albedo_color = Color(color.r * 0.30, color.g * 0.30, color.b * 0.30)
		rmat.emission_enabled = true
		rmat.emission = color
		rmat.emission_energy_multiplier = 1.4
		rmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		ring.material_override = rmat
		geom.add_child(ring)
		# 8 small "tick marks" arrayed around the ring
		var tick_count: int = 8
		for t in tick_count:
			var angle: float = (float(t) / tick_count) * TAU
			var radius: float = (spec[0] + spec[1]) * 0.5
			var tick: MeshInstance3D = MeshInstance3D.new()
			var tmesh: BoxMesh = BoxMesh.new()
			tmesh.size = Vector3(0.30, 0.05, 0.10)
			tick.mesh = tmesh
			tick.position = Vector3(cos(angle) * radius, 0.02, sin(angle) * radius)
			tick.rotation = Vector3(0, -angle, 0)
			tick.material_override = rmat
			ring.add_child(tick)
		# Slow rotation
		var period: float = float(spec[3])
		var spin: Tween = create_tween().set_loops()
		spin.tween_property(ring, "rotation:y", TAU * sign(period), abs(period))


func _build_food_cart(geom: Node) -> void:
	## Epic-1 T67: hovering food vendor cart on the south plaza axis. A
	## wheeled stall body floating just above the ground (no legs visible)
	## with a striped awning and 3 plates of glowing data-snacks on top.
	var cart: Node3D = Node3D.new()
	cart.name = "EastPlazaFoodCart"
	cart.position = Vector3(28, 0, 16)
	geom.add_child(cart)
	# Cart body
	var body_mat: StandardMaterial3D = StandardMaterial3D.new()
	body_mat.albedo_color = Color(0.35, 0.18, 0.06)
	body_mat.emission_enabled = true
	body_mat.emission = Color(0.95, 0.55, 0.20)
	body_mat.emission_energy_multiplier = 0.40
	body_mat.metallic = 0.30
	body_mat.roughness = 0.55
	var body: MeshInstance3D = MeshInstance3D.new()
	var bmesh: BoxMesh = BoxMesh.new()
	bmesh.size = Vector3(2.0, 0.85, 1.0)
	body.mesh = bmesh
	body.position = Vector3(0, 0.85, 0)
	body.material_override = body_mat
	cart.add_child(body)
	# Hover glow underneath
	var hover: MeshInstance3D = MeshInstance3D.new()
	var hmesh: CylinderMesh = CylinderMesh.new()
	hmesh.top_radius = 0.85
	hmesh.bottom_radius = 0.85
	hmesh.height = 0.05
	hover.mesh = hmesh
	hover.position = Vector3(0, 0.30, 0)
	var hmat: StandardMaterial3D = StandardMaterial3D.new()
	hmat.albedo_color = Color(0.30, 0.85, 1.0, 0.6)
	hmat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	hmat.emission_enabled = true
	hmat.emission = Color(0.55, 0.95, 1.0)
	hmat.emission_energy_multiplier = 1.8
	hmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	hover.material_override = hmat
	cart.add_child(hover)
	# Bob the body slightly to suggest hovering
	var bob: Tween = create_tween().set_loops()
	bob.tween_property(body, "position:y", 0.92, 1.4).set_ease(Tween.EASE_IN_OUT)
	bob.tween_property(body, "position:y", 0.85, 1.4).set_ease(Tween.EASE_IN_OUT)
	# Striped awning above
	var awning_mat: StandardMaterial3D = StandardMaterial3D.new()
	awning_mat.albedo_color = Color(0.85, 0.20, 0.20)
	awning_mat.emission_enabled = true
	awning_mat.emission = Color(0.95, 0.40, 0.30)
	awning_mat.emission_energy_multiplier = 0.95
	awning_mat.metallic = 0.10
	awning_mat.roughness = 0.55
	var awning: MeshInstance3D = MeshInstance3D.new()
	var amesh: BoxMesh = BoxMesh.new()
	amesh.size = Vector3(2.4, 0.10, 1.4)
	awning.mesh = amesh
	awning.position = Vector3(0, 1.85, 0)
	awning.material_override = awning_mat
	cart.add_child(awning)
	# 4 thin support posts from cart to awning
	var post_mat: StandardMaterial3D = StandardMaterial3D.new()
	post_mat.albedo_color = Color(0.20, 0.20, 0.22)
	post_mat.metallic = 0.85
	for ox: float in [-0.95, 0.95]:
		for oz: float in [-0.45, 0.45]:
			var post: MeshInstance3D = MeshInstance3D.new()
			var pmesh: CylinderMesh = CylinderMesh.new()
			pmesh.top_radius = 0.04
			pmesh.bottom_radius = 0.04
			pmesh.height = 0.50
			post.mesh = pmesh
			post.position = Vector3(ox, 1.55, oz)
			post.material_override = post_mat
			cart.add_child(post)
	# 3 glowing snack plates on top of cart
	var snack_colors: Array[Color] = [
		Color(0.45, 0.95, 0.65),
		Color(0.95, 0.65, 0.20),
		Color(0.85, 0.40, 1.0),
	]
	for i in 3:
		var plate: MeshInstance3D = MeshInstance3D.new()
		var pmesh: CylinderMesh = CylinderMesh.new()
		pmesh.top_radius = 0.18
		pmesh.bottom_radius = 0.18
		pmesh.height = 0.08
		plate.mesh = pmesh
		plate.position = Vector3(-0.6 + i * 0.6, 1.35, 0)
		var pmat: StandardMaterial3D = StandardMaterial3D.new()
		var color: Color = snack_colors[i]
		pmat.albedo_color = Color(color.r * 0.40, color.g * 0.40, color.b * 0.40)
		pmat.emission_enabled = true
		pmat.emission = color
		pmat.emission_energy_multiplier = 1.4
		pmat.metallic = 0.30
		pmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		plate.material_override = pmat
		cart.add_child(plate)
	# Sign
	var label: Label3D = Label3D.new()
	label.text = "DATA EATS"
	label.position = Vector3(0, 2.20, 0)
	label.modulate = Color(1.0, 0.55, 0.30)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 22
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	cart.add_child(label)
	# Collision around body
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(2.0, 1.6, 1.0)
	cs.shape = cb
	cs.position = Vector3(0, 0.85, 0)
	sb.add_child(cs)
	cart.add_child(sb)


func _build_coin_drops(geom: Node) -> void:
	## Epic-1 T68: 5 ambient coin-drop animations scattered through the
	## plaza — small gold coins that endlessly fall, fade out near the floor,
	## and reset to the top. Pure ambient sparkle.
	var positions: Array[Vector3] = [
		Vector3(27, 4, -8),
		Vector3(34, 4, 4),
		Vector3(38, 4, -10),
		Vector3(42, 4, 8),
		Vector3(30, 4, 12),
	]
	for i in positions.size():
		var coin: MeshInstance3D = MeshInstance3D.new()
		coin.name = "EastPlazaCoinDrop_%d" % i
		var cmesh: CylinderMesh = CylinderMesh.new()
		cmesh.top_radius = 0.12
		cmesh.bottom_radius = 0.12
		cmesh.height = 0.05
		coin.mesh = cmesh
		coin.position = positions[i]
		coin.rotation = Vector3(deg_to_rad(90), 0, 0)
		var cmat: StandardMaterial3D = StandardMaterial3D.new()
		cmat.albedo_color = Color(0.95, 0.75, 0.25)
		cmat.emission_enabled = true
		cmat.emission = Color(1.0, 0.85, 0.30)
		cmat.emission_energy_multiplier = 1.6
		cmat.metallic = 0.85
		cmat.roughness = 0.20
		coin.material_override = cmat
		geom.add_child(coin)
		# Continuous fall + spin
		var origin: Vector3 = positions[i]
		var fall: Tween = create_tween().set_loops()
		var fall_speed: float = 2.4 + i * 0.3
		fall.tween_property(coin, "position", origin + Vector3(0, -3.5, 0), fall_speed).set_ease(Tween.EASE_IN)
		fall.tween_property(coin, "position", origin, 0.05)
		var spin: Tween = create_tween().set_loops()
		spin.tween_property(coin, "rotation:z", TAU, 0.6)


func _build_pit_spotlights(geom: Node) -> void:
	## Epic-1 T69: 2 overhead spotlights illuminating the tournament pit at
	## (40, 0, 12). Each is a high-mounted lamp on a tall pole + an actual
	## SpotLight3D casting downward + a rotating cone beam mesh for visibility.
	var pit_center := Vector3(40, 0, 12)
	for i in 2:
		var pole_root: Node3D = Node3D.new()
		pole_root.name = "EastPlazaPitSpotlight_%d" % i
		var off: Vector3 = Vector3(-4 if i == 0 else 4, 0, 0)
		pole_root.position = pit_center + off
		geom.add_child(pole_root)
		# Tall pole
		var pole_mat: StandardMaterial3D = StandardMaterial3D.new()
		pole_mat.albedo_color = Color(0.10, 0.13, 0.16)
		pole_mat.metallic = 0.85
		pole_mat.roughness = 0.30
		var pole: MeshInstance3D = MeshInstance3D.new()
		var pmesh: CylinderMesh = CylinderMesh.new()
		pmesh.top_radius = 0.10
		pmesh.bottom_radius = 0.14
		pmesh.height = 6.5
		pole.mesh = pmesh
		pole.position = Vector3(0, 3.25, 0)
		pole.material_override = pole_mat
		pole_root.add_child(pole)
		# Lamp head
		var lamp: MeshInstance3D = MeshInstance3D.new()
		var lmesh: BoxMesh = BoxMesh.new()
		lmesh.size = Vector3(0.55, 0.30, 0.55)
		lamp.mesh = lmesh
		lamp.position = Vector3(0, 6.55, 0)
		var lmat: StandardMaterial3D = StandardMaterial3D.new()
		lmat.albedo_color = Color(0.85, 0.85, 0.95)
		lmat.emission_enabled = true
		lmat.emission = Color(1.0, 0.95, 0.80)
		lmat.emission_energy_multiplier = 2.0
		lmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		lamp.material_override = lmat
		pole_root.add_child(lamp)
		# Spot light
		var spot: SpotLight3D = SpotLight3D.new()
		spot.position = Vector3(0, 6.40, 0)
		spot.rotation = Vector3(deg_to_rad(-90), 0, 0)
		spot.light_energy = 2.5
		spot.light_color = Color(1.0, 0.95, 0.80)
		spot.spot_range = 12.0
		spot.spot_angle = 32.0
		spot.spot_attenuation = 1.4
		pole_root.add_child(spot)
		# Visible cone beam
		var beam: MeshInstance3D = MeshInstance3D.new()
		var bmesh: CylinderMesh = CylinderMesh.new()
		bmesh.top_radius = 0.10
		bmesh.bottom_radius = 2.40
		bmesh.height = 6.4
		beam.mesh = bmesh
		beam.position = Vector3(0, 3.20, 0)
		var bmat: StandardMaterial3D = StandardMaterial3D.new()
		bmat.albedo_color = Color(1.0, 0.95, 0.80, 0.10)
		bmat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		bmat.emission_enabled = true
		bmat.emission = Color(1.0, 0.95, 0.80)
		bmat.emission_energy_multiplier = 0.45
		bmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		beam.material_override = bmat
		pole_root.add_child(beam)
		# Collision on pole
		var sb: StaticBody3D = StaticBody3D.new()
		var cs: CollisionShape3D = CollisionShape3D.new()
		var cap: CapsuleShape3D = CapsuleShape3D.new()
		cap.radius = 0.25
		cap.height = 6.5
		cs.shape = cap
		cs.position = Vector3(0, 3.25, 0)
		sb.add_child(cs)
		pole_root.add_child(sb)


func _build_data_snow(geom: Node) -> void:
	## Epic-1 T70: ambient floating "data flake" particles drifting down
	## across the entire plaza. Tiny cyan diamonds, slow descent, no gravity.
	## Sells the "we're inside a simulation" feel.
	var snow: GPUParticles3D = GPUParticles3D.new()
	snow.name = "EastPlazaDataSnow"
	snow.position = Vector3(32, 8, 0)
	snow.amount = 80
	snow.lifetime = 8.0
	snow.preprocess = 4.0
	var smat: ParticleProcessMaterial = ParticleProcessMaterial.new()
	smat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	smat.emission_box_extents = Vector3(11, 0.5, 19)
	smat.direction = Vector3(0, -1, 0)
	smat.spread = 8.0
	smat.initial_velocity_min = 0.45
	smat.initial_velocity_max = 0.85
	smat.gravity = Vector3.ZERO
	smat.scale_min = 0.06
	smat.scale_max = 0.14
	smat.color = Color(0.55, 0.95, 1.0, 1.0)
	snow.process_material = smat
	var flake: PrismMesh = PrismMesh.new()
	flake.size = Vector3(0.10, 0.10, 0.10)
	var flake_mat: StandardMaterial3D = StandardMaterial3D.new()
	flake_mat.albedo_color = Color(0.55, 0.95, 1.0)
	flake_mat.emission_enabled = true
	flake_mat.emission = Color(0.55, 0.95, 1.0)
	flake_mat.emission_energy_multiplier = 1.8
	flake_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	flake.material = flake_mat
	snow.draw_pass_1 = flake
	geom.add_child(snow)


func _build_arena_rope_barriers(geom: Node) -> void:
	## Epic-1 T71: low rope-style barrier rings around the sparring arena
	## (36, 0, 6) and tournament pit (40, 0, 12). Each consists of 8 short
	## posts connected by glowing horizontal cyan bars at 2 heights.
	var arenas: Array = [
		[Vector3(36, 0, 6), 3.5],
		[Vector3(40, 0, 12), 5.5],
	]
	var post_mat: StandardMaterial3D = StandardMaterial3D.new()
	post_mat.albedo_color = Color(0.10, 0.13, 0.16)
	post_mat.metallic = 0.85
	post_mat.roughness = 0.30
	var rope_mat: StandardMaterial3D = StandardMaterial3D.new()
	rope_mat.albedo_color = Color(0.30, 0.85, 1.0)
	rope_mat.emission_enabled = true
	rope_mat.emission = Color(0.55, 0.95, 1.0)
	rope_mat.emission_energy_multiplier = 1.6
	rope_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for ai in arenas.size():
		var center: Vector3 = arenas[ai][0]
		var radius: float = arenas[ai][1]
		var ring_root: Node3D = Node3D.new()
		ring_root.name = "EastPlazaRopeRing_%d" % ai
		ring_root.position = center
		geom.add_child(ring_root)
		var post_count: int = 8
		var prev_post_pos: Vector3 = Vector3.ZERO
		var first_post_pos: Vector3 = Vector3.ZERO
		for p in post_count:
			var angle: float = (float(p) / post_count) * TAU
			var pos: Vector3 = Vector3(cos(angle) * radius, 0, sin(angle) * radius)
			var post: MeshInstance3D = MeshInstance3D.new()
			var pmesh: CylinderMesh = CylinderMesh.new()
			pmesh.top_radius = 0.06
			pmesh.bottom_radius = 0.08
			pmesh.height = 0.95
			post.mesh = pmesh
			post.position = pos + Vector3(0, 0.48, 0)
			post.material_override = post_mat
			ring_root.add_child(post)
			# Connect to previous post with two horizontal rope bars
			if p > 0:
				_make_rope_segment(ring_root, prev_post_pos, pos, 0.30, rope_mat)
				_make_rope_segment(ring_root, prev_post_pos, pos, 0.75, rope_mat)
			else:
				first_post_pos = pos
			prev_post_pos = pos
		# Close the ring back to the first post
		_make_rope_segment(ring_root, prev_post_pos, first_post_pos, 0.30, rope_mat)
		_make_rope_segment(ring_root, prev_post_pos, first_post_pos, 0.75, rope_mat)


func _make_rope_segment(parent: Node3D, a: Vector3, b: Vector3, y: float, mat: Material) -> void:
	## Helper for arena_rope_barriers — places a thin emissive bar between
	## two ground points at the given Y height, oriented along the segment.
	var seg: MeshInstance3D = MeshInstance3D.new()
	var dist: float = a.distance_to(b)
	var bmesh: BoxMesh = BoxMesh.new()
	bmesh.size = Vector3(dist, 0.05, 0.05)
	seg.mesh = bmesh
	var mid: Vector3 = (a + b) * 0.5 + Vector3(0, y, 0)
	seg.position = mid
	var dir: Vector3 = (b - a).normalized()
	var yaw: float = atan2(dir.z, dir.x)
	seg.rotation = Vector3(0, -yaw, 0)
	seg.material_override = mat
	parent.add_child(seg)


func _build_sale_signs(geom: Node) -> void:
	## Epic-1 T72: 3 floating "% OFF" sale signs above the kiosks suggesting
	## a market discount. Each is a small box panel with floating text on a
	## bobbing tween. Bright orange to grab attention.
	var positions: Array[Vector3] = [
		Vector3(28, 3.5, -2),
		Vector3(34, 3.5, 2),
		Vector3(40, 3.5, -4),
	]
	var texts: Array[String] = ["50% OFF", "BUY 1\nGET 1", "FLASH\nDEAL"]
	for i in positions.size():
		var sign_root: Node3D = Node3D.new()
		sign_root.name = "EastPlazaSaleSign_%d" % i
		sign_root.position = positions[i]
		geom.add_child(sign_root)
		# Backing card
		var card: MeshInstance3D = MeshInstance3D.new()
		var cmesh: BoxMesh = BoxMesh.new()
		cmesh.size = Vector3(1.0, 0.65, 0.05)
		card.mesh = cmesh
		var cmat: StandardMaterial3D = StandardMaterial3D.new()
		cmat.albedo_color = Color(0.95, 0.40, 0.10)
		cmat.emission_enabled = true
		cmat.emission = Color(1.0, 0.55, 0.15)
		cmat.emission_energy_multiplier = 1.6
		cmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		card.material_override = cmat
		sign_root.add_child(card)
		# Label on top of card
		var label: Label3D = Label3D.new()
		label.text = texts[i]
		label.position = Vector3(0, 0, 0.04)
		label.modulate = Color(1, 1, 1)
		label.outline_modulate = Color(0, 0, 0, 0.85)
		label.outline_size = 5
		label.font_size = 22
		label.no_depth_test = true
		label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		sign_root.add_child(label)
		# Bob tween
		var bob: Tween = create_tween().set_loops()
		var origin_y: float = positions[i].y
		bob.tween_property(sign_root, "position:y", origin_y + 0.30, 1.2 + i * 0.15).set_ease(Tween.EASE_IN_OUT)
		bob.tween_property(sign_root, "position:y", origin_y, 1.2 + i * 0.15).set_ease(Tween.EASE_IN_OUT)
		# Slow rotation for visibility
		var spin: Tween = create_tween().set_loops()
		spin.tween_property(sign_root, "rotation:y", TAU, 6.0)


func _build_chatter_bubbles(geom: Node) -> void:
	## Epic-1 T73: 4 ambient speech bubbles floating above pedestrian spawn
	## locations, each containing a short overheard chatter line. Cycle the
	## visible text on a timer to suggest different conversations.
	var positions: Array[Vector3] = [
		Vector3(29, 2.4, 9),
		Vector3(35, 2.4, -7),
		Vector3(41, 2.4, 3),
		Vector3(33, 2.4, 14),
	]
	var lines: Array[String] = [
		"...did you see\nthe glitch?",
		"prices are\noutrageous!",
		"i heard the\nboss is back",
		"new shipment\ntomorrow",
	]
	for i in positions.size():
		var bubble: Node3D = Node3D.new()
		bubble.name = "EastPlazaChatterBubble_%d" % i
		bubble.position = positions[i]
		geom.add_child(bubble)
		# Bubble backing
		var card: MeshInstance3D = MeshInstance3D.new()
		var cmesh: BoxMesh = BoxMesh.new()
		cmesh.size = Vector3(1.4, 0.65, 0.05)
		card.mesh = cmesh
		var cmat: StandardMaterial3D = StandardMaterial3D.new()
		cmat.albedo_color = Color(0.92, 0.92, 0.95, 0.85)
		cmat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		cmat.emission_enabled = true
		cmat.emission = Color(0.95, 0.95, 1.0)
		cmat.emission_energy_multiplier = 0.40
		cmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		card.material_override = cmat
		bubble.add_child(card)
		# Tail (small triangle prism pointing down)
		var tail: MeshInstance3D = MeshInstance3D.new()
		var tmesh: PrismMesh = PrismMesh.new()
		tmesh.size = Vector3(0.30, 0.30, 0.05)
		tail.mesh = tmesh
		tail.position = Vector3(0, -0.45, 0)
		tail.rotation = Vector3(deg_to_rad(180), 0, 0)
		tail.material_override = cmat
		bubble.add_child(tail)
		# Text
		var label: Label3D = Label3D.new()
		label.text = lines[i]
		label.position = Vector3(0, 0, 0.04)
		label.modulate = Color(0.10, 0.12, 0.20)
		label.outline_size = 0
		label.font_size = 14
		label.no_depth_test = true
		label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		bubble.add_child(label)
		# Bob and fade tween (alpha pulse via modulate)
		var bob: Tween = create_tween().set_loops()
		var origin_y: float = positions[i].y
		bob.tween_property(bubble, "position:y", origin_y + 0.25, 1.6 + i * 0.2).set_ease(Tween.EASE_IN_OUT)
		bob.tween_property(bubble, "position:y", origin_y, 1.6 + i * 0.2).set_ease(Tween.EASE_IN_OUT)


func _build_fountain_mist(geom: Node) -> void:
	## Epic-1 T74: ambient cyan mist rising off the data fountain at the
	## plaza center. Wide gentle particle emitter, very transparent.
	var mist: GPUParticles3D = GPUParticles3D.new()
	mist.name = "EastPlazaFountainMist"
	mist.position = Vector3(32, 1.4, 0)
	mist.amount = 50
	mist.lifetime = 3.5
	mist.preprocess = 1.5
	var pmat: ParticleProcessMaterial = ParticleProcessMaterial.new()
	pmat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	pmat.emission_sphere_radius = 0.85
	pmat.direction = Vector3(0, 1, 0)
	pmat.spread = 30.0
	pmat.initial_velocity_min = 0.30
	pmat.initial_velocity_max = 0.65
	pmat.gravity = Vector3.ZERO
	pmat.scale_min = 0.30
	pmat.scale_max = 0.65
	pmat.color = Color(0.55, 0.95, 1.0, 0.30)
	mist.process_material = pmat
	var dmesh: SphereMesh = SphereMesh.new()
	dmesh.radius = 0.30
	dmesh.height = 0.60
	var dmat: StandardMaterial3D = StandardMaterial3D.new()
	dmat.albedo_color = Color(0.55, 0.95, 1.0, 0.30)
	dmat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	dmat.emission_enabled = true
	dmat.emission = Color(0.55, 0.95, 1.0)
	dmat.emission_energy_multiplier = 0.85
	dmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	dmesh.material = dmat
	mist.draw_pass_1 = dmesh
	geom.add_child(mist)


func _build_champion_banner(geom: Node) -> void:
	## Epic-1 T75: long horizontal champion banner stretched between two
	## tall poles above the tournament pit. Reads "TOURNAMENT CHAMPION /
	## CIPHER 99". Adds vertical drama and reinforces the leaderboard.
	var banner_root: Node3D = Node3D.new()
	banner_root.name = "EastPlazaChampionBanner"
	banner_root.position = Vector3(40, 0, 12)
	geom.add_child(banner_root)
	# Pole material
	var pole_mat: StandardMaterial3D = StandardMaterial3D.new()
	pole_mat.albedo_color = Color(0.10, 0.13, 0.16)
	pole_mat.metallic = 0.85
	pole_mat.roughness = 0.30
	# 2 tall side poles flanking the pit
	for sx: float in [-7.0, 7.0]:
		var pole: MeshInstance3D = MeshInstance3D.new()
		var pmesh: CylinderMesh = CylinderMesh.new()
		pmesh.top_radius = 0.10
		pmesh.bottom_radius = 0.14
		pmesh.height = 8.0
		pole.mesh = pmesh
		pole.position = Vector3(sx, 4.0, 0)
		pole.material_override = pole_mat
		banner_root.add_child(pole)
		# Collision on pole
		var sb: StaticBody3D = StaticBody3D.new()
		var cs: CollisionShape3D = CollisionShape3D.new()
		var cap: CapsuleShape3D = CapsuleShape3D.new()
		cap.radius = 0.25
		cap.height = 8.0
		cs.shape = cap
		cs.position = Vector3(sx, 4.0, 0)
		sb.add_child(cs)
		banner_root.add_child(sb)
	# The banner cloth
	var banner: MeshInstance3D = MeshInstance3D.new()
	var bmesh: BoxMesh = BoxMesh.new()
	bmesh.size = Vector3(13.0, 1.6, 0.06)
	banner.mesh = bmesh
	banner.position = Vector3(0, 7.0, 0)
	var bmat: StandardMaterial3D = StandardMaterial3D.new()
	bmat.albedo_color = Color(0.30, 0.10, 0.04)
	bmat.emission_enabled = true
	bmat.emission = Color(1.0, 0.55, 0.10)
	bmat.emission_energy_multiplier = 0.95
	bmat.metallic = 0.10
	bmat.roughness = 0.55
	banner.material_override = bmat
	banner_root.add_child(banner)
	# Top + bottom emissive trim
	var trim_mat: StandardMaterial3D = StandardMaterial3D.new()
	trim_mat.albedo_color = Color(1.0, 0.85, 0.30)
	trim_mat.emission_enabled = true
	trim_mat.emission = Color(1.0, 0.95, 0.40)
	trim_mat.emission_energy_multiplier = 1.8
	trim_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for ty: float in [7.78, 6.22]:
		var trim: MeshInstance3D = MeshInstance3D.new()
		var tmesh: BoxMesh = BoxMesh.new()
		tmesh.size = Vector3(13.0, 0.08, 0.10)
		trim.mesh = tmesh
		trim.position = Vector3(0, ty, 0)
		trim.material_override = trim_mat
		banner_root.add_child(trim)
	# 2 lines of text on the banner
	var line1: Label3D = Label3D.new()
	line1.text = "TOURNAMENT CHAMPION"
	line1.position = Vector3(0, 7.30, 0.05)
	line1.modulate = Color(1.0, 0.85, 0.30)
	line1.outline_modulate = Color(0, 0, 0, 0.85)
	line1.outline_size = 6
	line1.font_size = 28
	line1.no_depth_test = true
	banner_root.add_child(line1)
	var line2: Label3D = Label3D.new()
	line2.text = "CIPHER 99"
	line2.position = Vector3(0, 6.65, 0.05)
	line2.modulate = Color(1.0, 0.95, 0.55)
	line2.outline_modulate = Color(0, 0, 0, 0.85)
	line2.outline_size = 6
	line2.font_size = 36
	line2.no_depth_test = true
	banner_root.add_child(line2)


func _build_east_gate(geom: Node) -> void:
	## Epic-1 T76: locked east gate marking the future Epic 2 district
	## entrance. Pushes the east boundary out from x=44 to x=70 to make room
	## for the eastbound corridor + skyline. The gate itself is a tall arch
	## with a "DISTRICT 2 / SECTOR LOCKED" hologram blocking passage.
	# Push the boundary wall further east
	var east_wall: CSGBox3D = geom.get_node_or_null("BoundaryEast") as CSGBox3D
	if east_wall:
		east_wall.position.x = 70.0
	# Build the gate at x=48 (just beyond the plaza)
	var gate: Node3D = Node3D.new()
	gate.name = "EastPlazaEastGate"
	gate.position = Vector3(48, 0, 0)
	geom.add_child(gate)
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.14, 0.18, 0.22)
	stone_mat.metallic = 0.55
	stone_mat.roughness = 0.45
	# 2 huge corner pillars
	for sx: float in [-3.5, 3.5]:
		var pillar: MeshInstance3D = MeshInstance3D.new()
		var pmesh: BoxMesh = BoxMesh.new()
		pmesh.size = Vector3(1.4, 7.0, 1.4)
		pillar.mesh = pmesh
		pillar.position = Vector3(sx, 3.5, 0)
		pillar.material_override = stone_mat
		gate.add_child(pillar)
		# Cyan accent stripes
		var accent: MeshInstance3D = MeshInstance3D.new()
		var amesh: BoxMesh = BoxMesh.new()
		amesh.size = Vector3(0.05, 5.5, 1.5)
		accent.mesh = amesh
		accent.position = Vector3(sx + (-0.71 if sx < 0 else 0.71), 3.5, 0)
		var amat: StandardMaterial3D = StandardMaterial3D.new()
		amat.albedo_color = Color(0.30, 0.85, 1.0)
		amat.emission_enabled = true
		amat.emission = Color(0.55, 0.95, 1.0)
		amat.emission_energy_multiplier = 1.6
		amat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		accent.material_override = amat
		gate.add_child(accent)
		# Collision on pillar
		var sb: StaticBody3D = StaticBody3D.new()
		var cs: CollisionShape3D = CollisionShape3D.new()
		var cb: BoxShape3D = BoxShape3D.new()
		cb.size = Vector3(1.4, 7.0, 1.4)
		cs.shape = cb
		cs.position = Vector3(sx, 3.5, 0)
		sb.add_child(cs)
		gate.add_child(sb)
	# Crossbar lintel on top
	var lintel: MeshInstance3D = MeshInstance3D.new()
	var lmesh: BoxMesh = BoxMesh.new()
	lmesh.size = Vector3(8.5, 1.20, 1.40)
	lintel.mesh = lmesh
	lintel.position = Vector3(0, 7.60, 0)
	lintel.material_override = stone_mat
	gate.add_child(lintel)
	# Forcefield in the gate opening — pulsing translucent cyan field
	var field: MeshInstance3D = MeshInstance3D.new()
	field.name = "GateForceField"
	var fmesh: BoxMesh = BoxMesh.new()
	fmesh.size = Vector3(5.6, 6.2, 0.10)
	field.mesh = fmesh
	field.position = Vector3(0, 3.20, 0)
	var fmat: StandardMaterial3D = StandardMaterial3D.new()
	fmat.albedo_color = Color(1.0, 0.30, 0.30, 0.40)
	fmat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	fmat.emission_enabled = true
	fmat.emission = Color(1.0, 0.40, 0.40)
	fmat.emission_energy_multiplier = 1.4
	fmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	field.material_override = fmat
	gate.add_child(field)
	# Forcefield collision (blocks player)
	var fsb: StaticBody3D = StaticBody3D.new()
	var fcs: CollisionShape3D = CollisionShape3D.new()
	var fcb: BoxShape3D = BoxShape3D.new()
	fcb.size = Vector3(5.6, 6.2, 0.5)
	fcs.shape = fcb
	fcs.position = Vector3(0, 3.20, 0)
	fsb.add_child(fcs)
	gate.add_child(fsb)
	# Pulse the forcefield
	var pulse: Tween = create_tween().set_loops()
	pulse.tween_property(fmat, "albedo_color", Color(1.0, 0.30, 0.30, 0.55), 1.4).set_ease(Tween.EASE_IN_OUT)
	pulse.tween_property(fmat, "albedo_color", Color(1.0, 0.30, 0.30, 0.25), 1.4).set_ease(Tween.EASE_IN_OUT)
	# Big "LOCKED" sign on lintel
	var label: Label3D = Label3D.new()
	label.text = "DISTRICT 2\nSECTOR LOCKED"
	label.position = Vector3(0, 7.60, 0.71)
	label.modulate = Color(1.0, 0.40, 0.40)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 6
	label.font_size = 26
	label.no_depth_test = true
	gate.add_child(label)


func _build_skyline_silhouette(geom: Node) -> void:
	## Epic-1 T77: distant skyline silhouette visible beyond the east gate.
	## A row of 12 dark towers with cyan tops at varying heights, placed far
	## east (x=58 to x=68) so the player sees the future district from afar.
	var skyline_root: Node3D = Node3D.new()
	skyline_root.name = "EastPlazaSkylineSilhouette"
	skyline_root.position = Vector3(63, 0, 0)
	geom.add_child(skyline_root)
	var dark_mat: StandardMaterial3D = StandardMaterial3D.new()
	dark_mat.albedo_color = Color(0.04, 0.06, 0.10)
	dark_mat.metallic = 0.20
	dark_mat.roughness = 0.85
	var top_mat: StandardMaterial3D = StandardMaterial3D.new()
	top_mat.albedo_color = Color(0.30, 0.85, 1.0)
	top_mat.emission_enabled = true
	top_mat.emission = Color(0.55, 0.95, 1.0)
	top_mat.emission_energy_multiplier = 2.4
	top_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	# Tower height pattern (varied)
	var heights: Array[float] = [8.0, 12.0, 6.0, 14.0, 9.0, 11.0, 7.0, 15.0, 10.0, 13.0, 8.5, 12.5]
	for i in heights.size():
		var h: float = heights[i]
		var tower: MeshInstance3D = MeshInstance3D.new()
		var tmesh: BoxMesh = BoxMesh.new()
		tmesh.size = Vector3(1.6, h, 1.6)
		tower.mesh = tmesh
		# Spread along z
		var z: float = -16 + (float(i) / heights.size()) * 32
		tower.position = Vector3(0, h * 0.5, z)
		tower.material_override = dark_mat
		skyline_root.add_child(tower)
		# Glowing top cap
		var top: MeshInstance3D = MeshInstance3D.new()
		var top_mesh: BoxMesh = BoxMesh.new()
		top_mesh.size = Vector3(1.6, 0.20, 1.6)
		top.mesh = top_mesh
		top.position = Vector3(0, h + 0.10, z)
		top.material_override = top_mat
		skyline_root.add_child(top)
		# Antenna spike
		var spike: MeshInstance3D = MeshInstance3D.new()
		var smesh: CylinderMesh = CylinderMesh.new()
		smesh.top_radius = 0.04
		smesh.bottom_radius = 0.10
		smesh.height = 1.5
		spike.mesh = smesh
		spike.position = Vector3(0, h + 0.95, z)
		spike.material_override = dark_mat
		skyline_root.add_child(spike)
		# Blinking spike tip
		var tip: MeshInstance3D = MeshInstance3D.new()
		var tip_mesh: SphereMesh = SphereMesh.new()
		tip_mesh.radius = 0.10
		tip_mesh.height = 0.20
		tip.mesh = tip_mesh
		tip.position = Vector3(0, h + 1.75, z)
		var tip_mat: StandardMaterial3D = StandardMaterial3D.new()
		tip_mat.albedo_color = Color(1.0, 0.30, 0.30)
		tip_mat.emission_enabled = true
		tip_mat.emission = Color(1.0, 0.40, 0.40)
		tip_mat.emission_energy_multiplier = 2.5
		tip_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		tip.material_override = tip_mat
		skyline_root.add_child(tip)
		# Blink the tip
		var blink: Tween = create_tween().set_loops()
		var blink_speed: float = 0.6 + (i % 4) * 0.2
		blink.tween_property(tip, "scale", Vector3(0.3, 0.3, 0.3), blink_speed).set_ease(Tween.EASE_IN_OUT)
		blink.tween_property(tip, "scale", Vector3(1.4, 1.4, 1.4), blink_speed).set_ease(Tween.EASE_IN_OUT)


func _build_horizon_lights(geom: Node) -> void:
	## Epic-1 T78: 30 small twinkling cyan/violet pinpoint lights scattered
	## across the distant skyline area to suggest a populated district.
	var lights_root: Node3D = Node3D.new()
	lights_root.name = "EastPlazaHorizonLights"
	lights_root.position = Vector3(63, 0, 0)
	geom.add_child(lights_root)
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 42
	var palette: Array[Color] = [
		Color(0.55, 0.95, 1.0),
		Color(0.85, 0.40, 1.0),
		Color(0.95, 0.65, 0.20),
	]
	for i in 30:
		var light: MeshInstance3D = MeshInstance3D.new()
		var lmesh: SphereMesh = SphereMesh.new()
		lmesh.radius = 0.10
		lmesh.height = 0.20
		light.mesh = lmesh
		light.position = Vector3(
			rng.randf_range(-1.5, 1.5),
			rng.randf_range(2.0, 14.0),
			rng.randf_range(-18.0, 18.0)
		)
		var color: Color = palette[i % palette.size()]
		var lmat: StandardMaterial3D = StandardMaterial3D.new()
		lmat.albedo_color = color
		lmat.emission_enabled = true
		lmat.emission = color
		lmat.emission_energy_multiplier = 2.6
		lmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		light.material_override = lmat
		lights_root.add_child(light)
		# Twinkle
		var twinkle: Tween = create_tween().set_loops()
		var twk_speed: float = rng.randf_range(0.8, 1.6)
		twinkle.tween_property(light, "scale", Vector3(0.4, 0.4, 0.4), twk_speed).set_ease(Tween.EASE_IN_OUT)
		twinkle.tween_property(light, "scale", Vector3(1.2, 1.2, 1.2), twk_speed).set_ease(Tween.EASE_IN_OUT)


func _build_border_guard_npc() -> void:
	## Epic-1 T79: border guard procedural NPC stationed in front of the
	## east gate. Cyan body, "BORDER GUARD" name, faces the gate with eyes
	## pointed eastward. Pure decoration — no interaction wired yet.
	var slots: Node3D = get_node_or_null("%NPCSlots") as Node3D
	if slots == null:
		return
	var guard: Node3D = Node3D.new()
	guard.name = "BorderGuard"
	guard.position = Vector3(46, 0, 0)
	slots.add_child(guard)
	# Body capsule — military gray-blue
	var body: MeshInstance3D = MeshInstance3D.new()
	var bmesh: CapsuleMesh = CapsuleMesh.new()
	bmesh.radius = 0.42
	bmesh.height = 1.20
	body.mesh = bmesh
	body.position = Vector3(0, 0.65, 0)
	var bmat: StandardMaterial3D = StandardMaterial3D.new()
	bmat.albedo_color = Color(0.20, 0.30, 0.40)
	bmat.emission_enabled = true
	bmat.emission = Color(0.30, 0.55, 0.85)
	bmat.emission_energy_multiplier = 0.45
	bmat.metallic = 0.55
	bmat.roughness = 0.45
	body.material_override = bmat
	guard.add_child(body)
	# Helmet — flat dark cylinder on top
	var helmet: MeshInstance3D = MeshInstance3D.new()
	var hmesh: CylinderMesh = CylinderMesh.new()
	hmesh.top_radius = 0.45
	hmesh.bottom_radius = 0.45
	hmesh.height = 0.18
	helmet.mesh = hmesh
	helmet.position = Vector3(0, 1.40, 0)
	var hmat: StandardMaterial3D = StandardMaterial3D.new()
	hmat.albedo_color = Color(0.10, 0.13, 0.16)
	hmat.metallic = 0.85
	hmat.roughness = 0.30
	helmet.material_override = hmat
	guard.add_child(helmet)
	# 2 cyan visor eyes facing east (+x direction)
	var eye_mat: StandardMaterial3D = StandardMaterial3D.new()
	eye_mat.albedo_color = Color(0.55, 0.95, 1.0)
	eye_mat.emission_enabled = true
	eye_mat.emission = Color(0.55, 0.95, 1.0)
	eye_mat.emission_energy_multiplier = 2.6
	eye_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for ez: float in [-0.10, 0.10]:
		var eye: MeshInstance3D = MeshInstance3D.new()
		var emesh: SphereMesh = SphereMesh.new()
		emesh.radius = 0.06
		emesh.height = 0.12
		eye.mesh = emesh
		eye.position = Vector3(0.36, 1.18, ez)
		eye.material_override = eye_mat
		guard.add_child(eye)
	# Spear/staff weapon
	var spear: MeshInstance3D = MeshInstance3D.new()
	var smesh: CylinderMesh = CylinderMesh.new()
	smesh.top_radius = 0.04
	smesh.bottom_radius = 0.04
	smesh.height = 2.4
	spear.mesh = smesh
	spear.position = Vector3(0.45, 1.20, 0)
	var spear_mat: StandardMaterial3D = StandardMaterial3D.new()
	spear_mat.albedo_color = Color(0.85, 0.85, 0.95)
	spear_mat.metallic = 0.85
	spear_mat.roughness = 0.20
	spear.material_override = spear_mat
	guard.add_child(spear)
	# Spear tip glowing cyan
	var tip: MeshInstance3D = MeshInstance3D.new()
	var tip_mesh: PrismMesh = PrismMesh.new()
	tip_mesh.size = Vector3(0.18, 0.40, 0.18)
	tip.mesh = tip_mesh
	tip.position = Vector3(0.45, 2.40, 0)
	var tip_mat: StandardMaterial3D = StandardMaterial3D.new()
	tip_mat.albedo_color = Color(0.30, 0.85, 1.0)
	tip_mat.emission_enabled = true
	tip_mat.emission = Color(0.55, 0.95, 1.0)
	tip_mat.emission_energy_multiplier = 2.0
	tip_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	tip.material_override = tip_mat
	guard.add_child(tip)
	# Name billboard
	var label: Label3D = Label3D.new()
	label.text = "Border Guard"
	label.position = Vector3(0, 1.85, 0)
	label.modulate = Color(0.55, 0.85, 1.0)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 18
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	guard.add_child(label)


func _build_eastbound_path(geom: Node) -> void:
	## Epic-1 T80: emissive path stretching east from the plaza arch through
	## the east gate, continuing into the distance to telegraph "this is the
	## road to District 2". Made of 12 cyan lit tiles spaced 1m apart.
	var path_root: Node3D = Node3D.new()
	path_root.name = "EastPlazaEastboundPath"
	geom.add_child(path_root)
	var tile_mat: StandardMaterial3D = StandardMaterial3D.new()
	tile_mat.albedo_color = Color(0.20, 0.50, 0.70)
	tile_mat.emission_enabled = true
	tile_mat.emission = Color(0.55, 0.95, 1.0)
	tile_mat.emission_energy_multiplier = 1.4
	tile_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	# Tiles from x=44 to x=68
	for i in 12:
		var x: float = 45.0 + i * 2.0
		var tile: MeshInstance3D = MeshInstance3D.new()
		tile.name = "EastPath_%d" % i
		var tmesh: BoxMesh = BoxMesh.new()
		tmesh.size = Vector3(1.5, 0.05, 2.0)
		tile.mesh = tmesh
		tile.position = Vector3(x, 0.05, 0)
		tile.material_override = tile_mat
		path_root.add_child(tile)
		# Walking-light pulse: scale glow
		var pulse: Tween = create_tween().set_loops()
		pulse.tween_interval(i * 0.10)
		pulse.tween_property(tile, "scale", Vector3(1.0, 2.5, 1.0), 0.25).set_ease(Tween.EASE_OUT)
		pulse.tween_property(tile, "scale", Vector3(1.0, 1.0, 1.0), 0.25).set_ease(Tween.EASE_IN)
		pulse.tween_interval(1.20 - i * 0.10 * 0.5)


func _build_save_shrine(geom: Node) -> void:
	## Epic-1 T81: a save shrine pillar in the plaza — green obelisk on a
	## stone base with a slowly rotating "S" hologram. Telegraphs the
	## save-point loop without wiring up actual save logic.
	var shrine: Node3D = Node3D.new()
	shrine.name = "EastPlazaSaveShrine"
	shrine.position = Vector3(28, 0, -10)
	geom.add_child(shrine)
	# Stone base
	var base_mat: StandardMaterial3D = StandardMaterial3D.new()
	base_mat.albedo_color = Color(0.18, 0.22, 0.28)
	base_mat.metallic = 0.55
	base_mat.roughness = 0.45
	var base: MeshInstance3D = MeshInstance3D.new()
	var bmesh: BoxMesh = BoxMesh.new()
	bmesh.size = Vector3(1.6, 0.40, 1.6)
	base.mesh = bmesh
	base.position = Vector3(0, 0.20, 0)
	base.material_override = base_mat
	shrine.add_child(base)
	# Tall green obelisk
	var obelisk: MeshInstance3D = MeshInstance3D.new()
	var omesh: PrismMesh = PrismMesh.new()
	omesh.size = Vector3(0.85, 3.20, 0.85)
	obelisk.mesh = omesh
	obelisk.position = Vector3(0, 2.00, 0)
	var omat: StandardMaterial3D = StandardMaterial3D.new()
	omat.albedo_color = Color(0.10, 0.40, 0.20)
	omat.emission_enabled = true
	omat.emission = Color(0.30, 1.0, 0.50)
	omat.emission_energy_multiplier = 1.6
	omat.metallic = 0.55
	omat.roughness = 0.20
	obelisk.material_override = omat
	shrine.add_child(obelisk)
	# Floating "S" hologram on top
	var s_holo: Label3D = Label3D.new()
	s_holo.text = "S"
	s_holo.position = Vector3(0, 4.40, 0)
	s_holo.modulate = Color(0.40, 1.0, 0.55)
	s_holo.outline_modulate = Color(0, 0, 0, 0.85)
	s_holo.outline_size = 8
	s_holo.font_size = 64
	s_holo.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	shrine.add_child(s_holo)
	# Halo ring around the base
	var halo: MeshInstance3D = MeshInstance3D.new()
	var hmesh: TorusMesh = TorusMesh.new()
	hmesh.inner_radius = 1.10
	hmesh.outer_radius = 1.30
	halo.mesh = hmesh
	halo.position = Vector3(0, 0.45, 0)
	var hmat: StandardMaterial3D = StandardMaterial3D.new()
	hmat.albedo_color = Color(0.30, 1.0, 0.50)
	hmat.emission_enabled = true
	hmat.emission = Color(0.40, 1.0, 0.55)
	hmat.emission_energy_multiplier = 2.0
	hmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	halo.material_override = hmat
	shrine.add_child(halo)
	# Pulse halo
	var pulse: Tween = create_tween().set_loops()
	pulse.tween_property(halo, "scale", Vector3(1.25, 1.0, 1.25), 1.6).set_ease(Tween.EASE_IN_OUT)
	pulse.tween_property(halo, "scale", Vector3(1.0, 1.0, 1.0), 1.6).set_ease(Tween.EASE_IN_OUT)
	# Save shrine label
	var label: Label3D = Label3D.new()
	label.text = "SAVE POINT"
	label.position = Vector3(0, 0.75, 0.85)
	label.modulate = Color(0.40, 1.0, 0.55)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 4
	label.font_size = 16
	label.no_depth_test = true
	shrine.add_child(label)
	# Collision around base
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(1.6, 4.0, 1.6)
	cs.shape = cb
	cs.position = Vector3(0, 2.0, 0)
	sb.add_child(cs)
	shrine.add_child(sb)


func _build_bell_tower(geom: Node) -> void:
	## Epic-1 T82: tall plaza bell tower with a hanging bell that gently
	## swings on a tween. Adds vertical drama and a recognizable landmark.
	var tower: Node3D = Node3D.new()
	tower.name = "EastPlazaBellTower"
	tower.position = Vector3(44, 0, -16)
	geom.add_child(tower)
	# Stone column
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.20, 0.24, 0.30)
	stone_mat.metallic = 0.50
	stone_mat.roughness = 0.45
	var column: MeshInstance3D = MeshInstance3D.new()
	var cmesh: BoxMesh = BoxMesh.new()
	cmesh.size = Vector3(1.8, 9.0, 1.8)
	column.mesh = cmesh
	column.position = Vector3(0, 4.5, 0)
	column.material_override = stone_mat
	tower.add_child(column)
	# Top open belfry — 4 thin pillars
	for ox: float in [-0.65, 0.65]:
		for oz: float in [-0.65, 0.65]:
			var pillar: MeshInstance3D = MeshInstance3D.new()
			var pmesh: CylinderMesh = CylinderMesh.new()
			pmesh.top_radius = 0.10
			pmesh.bottom_radius = 0.10
			pmesh.height = 1.6
			pillar.mesh = pmesh
			pillar.position = Vector3(ox, 9.80, oz)
			pillar.material_override = stone_mat
			tower.add_child(pillar)
	# Roof cap
	var roof: MeshInstance3D = MeshInstance3D.new()
	var rmesh: PrismMesh = PrismMesh.new()
	rmesh.size = Vector3(2.0, 1.40, 2.0)
	roof.mesh = rmesh
	roof.position = Vector3(0, 11.30, 0)
	var roof_mat: StandardMaterial3D = StandardMaterial3D.new()
	roof_mat.albedo_color = Color(0.30, 0.10, 0.10)
	roof_mat.emission_enabled = true
	roof_mat.emission = Color(0.85, 0.30, 0.20)
	roof_mat.emission_energy_multiplier = 0.55
	roof_mat.metallic = 0.40
	roof_mat.roughness = 0.45
	roof.material_override = roof_mat
	tower.add_child(roof)
	# Bell pivot at top
	var bell_pivot: Node3D = Node3D.new()
	bell_pivot.position = Vector3(0, 10.40, 0)
	tower.add_child(bell_pivot)
	# Bell itself — large cylinder with a half-sphere on top
	var bell: MeshInstance3D = MeshInstance3D.new()
	var bell_mesh: CylinderMesh = CylinderMesh.new()
	bell_mesh.top_radius = 0.30
	bell_mesh.bottom_radius = 0.55
	bell_mesh.height = 0.75
	bell.mesh = bell_mesh
	bell.position = Vector3(0, -0.55, 0)
	var bell_mat: StandardMaterial3D = StandardMaterial3D.new()
	bell_mat.albedo_color = Color(0.85, 0.65, 0.30)
	bell_mat.emission_enabled = true
	bell_mat.emission = Color(1.0, 0.75, 0.30)
	bell_mat.emission_energy_multiplier = 0.55
	bell_mat.metallic = 0.85
	bell_mat.roughness = 0.20
	bell.material_override = bell_mat
	bell_pivot.add_child(bell)
	# Clapper inside the bell
	var clapper: MeshInstance3D = MeshInstance3D.new()
	var clap_mesh: SphereMesh = SphereMesh.new()
	clap_mesh.radius = 0.12
	clap_mesh.height = 0.24
	clapper.mesh = clap_mesh
	clapper.position = Vector3(0, -0.85, 0)
	var clap_mat: StandardMaterial3D = StandardMaterial3D.new()
	clap_mat.albedo_color = Color(0.40, 0.30, 0.15)
	clap_mat.metallic = 0.85
	clapper.material_override = clap_mat
	bell_pivot.add_child(clapper)
	# Swing the bell
	var swing: Tween = create_tween().set_loops()
	swing.tween_property(bell_pivot, "rotation:z", deg_to_rad(15), 1.6).set_ease(Tween.EASE_IN_OUT)
	swing.tween_property(bell_pivot, "rotation:z", deg_to_rad(-15), 1.6).set_ease(Tween.EASE_IN_OUT)
	# Collision around column
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(1.8, 9.0, 1.8)
	cs.shape = cb
	cs.position = Vector3(0, 4.5, 0)
	sb.add_child(cs)
	tower.add_child(sb)


func _build_data_clouds(geom: Node) -> void:
	## Epic-1 T83: 5 large translucent "data clouds" drifting overhead at
	## ~12m altitude. Each is a fat rounded box with cyan emission, slowly
	## tweening across the plaza on independent paths.
	var cloud_specs: Array = [
		[Vector3(24, 12, -14), Vector3(48, 12, -14), 22.0],
		[Vector3(48, 13, -2), Vector3(24, 13, -2), 26.0],
		[Vector3(24, 11, 8), Vector3(48, 11, 8), 24.0],
		[Vector3(48, 14, 14), Vector3(24, 14, 14), 28.0],
		[Vector3(24, 12, -8), Vector3(48, 12, -8), 30.0],
	]
	for i in cloud_specs.size():
		var cloud: MeshInstance3D = MeshInstance3D.new()
		cloud.name = "EastPlazaDataCloud_%d" % i
		var cmesh: BoxMesh = BoxMesh.new()
		cmesh.size = Vector3(4.5, 1.4, 3.0)
		cloud.mesh = cmesh
		cloud.position = cloud_specs[i][0]
		var cmat: StandardMaterial3D = StandardMaterial3D.new()
		cmat.albedo_color = Color(0.55, 0.85, 1.0, 0.35)
		cmat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		cmat.emission_enabled = true
		cmat.emission = Color(0.55, 0.95, 1.0)
		cmat.emission_energy_multiplier = 0.55
		cmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		cloud.material_override = cmat
		geom.add_child(cloud)
		# Drift across the plaza
		var drift: Tween = create_tween().set_loops()
		drift.tween_property(cloud, "position", cloud_specs[i][1], cloud_specs[i][2]).set_ease(Tween.EASE_IN_OUT)
		drift.tween_property(cloud, "position", cloud_specs[i][0], cloud_specs[i][2]).set_ease(Tween.EASE_IN_OUT)


func _build_chess_players(geom: Node) -> void:
	## Epic-1 T84: 2 procedural NPCs sitting across a small chess table at
	## the south plaza edge, with a holographic chess board and pieces
	## floating above the table. Pure ambience.
	var scene: Node3D = Node3D.new()
	scene.name = "EastPlazaChessPlayers"
	scene.position = Vector3(40, 0, -16)
	geom.add_child(scene)
	# Table
	var table_mat: StandardMaterial3D = StandardMaterial3D.new()
	table_mat.albedo_color = Color(0.18, 0.22, 0.28)
	table_mat.metallic = 0.55
	table_mat.roughness = 0.45
	var table: MeshInstance3D = MeshInstance3D.new()
	var tmesh: BoxMesh = BoxMesh.new()
	tmesh.size = Vector3(1.0, 0.85, 1.0)
	table.mesh = tmesh
	table.position = Vector3(0, 0.42, 0)
	table.material_override = table_mat
	scene.add_child(table)
	# Chess board on top — checkered with cyan/violet
	var board_mat: StandardMaterial3D = StandardMaterial3D.new()
	board_mat.albedo_color = Color(0.14, 0.18, 0.22)
	board_mat.metallic = 0.40
	var board: MeshInstance3D = MeshInstance3D.new()
	var bmesh: BoxMesh = BoxMesh.new()
	bmesh.size = Vector3(0.85, 0.04, 0.85)
	board.mesh = bmesh
	board.position = Vector3(0, 0.87, 0)
	board.material_override = board_mat
	scene.add_child(board)
	# 4 holographic pieces — alternating cyan and violet
	var piece_colors: Array[Color] = [
		Color(0.55, 0.95, 1.0),
		Color(0.85, 0.40, 1.0),
	]
	var piece_offsets: Array[Vector3] = [
		Vector3(-0.20, 0, -0.20),
		Vector3(0.20, 0, -0.20),
		Vector3(-0.20, 0, 0.20),
		Vector3(0.20, 0, 0.20),
	]
	for i in piece_offsets.size():
		var piece: MeshInstance3D = MeshInstance3D.new()
		var pmesh: CylinderMesh = CylinderMesh.new()
		pmesh.top_radius = 0.05
		pmesh.bottom_radius = 0.10
		pmesh.height = 0.25
		piece.mesh = pmesh
		piece.position = piece_offsets[i] + Vector3(0, 1.02, 0)
		var color: Color = piece_colors[i % 2]
		var pmat: StandardMaterial3D = StandardMaterial3D.new()
		pmat.albedo_color = color
		pmat.emission_enabled = true
		pmat.emission = color
		pmat.emission_energy_multiplier = 1.8
		pmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		piece.material_override = pmat
		scene.add_child(piece)
		# Bob slightly
		var bob: Tween = create_tween().set_loops()
		var origin_y: float = 1.02
		bob.tween_property(piece, "position:y", origin_y + 0.06, 1.0 + i * 0.15).set_ease(Tween.EASE_IN_OUT)
		bob.tween_property(piece, "position:y", origin_y, 1.0 + i * 0.15).set_ease(Tween.EASE_IN_OUT)
	# 2 player capsules flanking the table
	var player_specs: Array = [
		[Vector3(0, 0.55, -1.0), Color(0.55, 0.95, 1.0), "Bit"],
		[Vector3(0, 0.55, 1.0), Color(0.85, 0.40, 1.0), "Byte"],
	]
	for spec in player_specs:
		var player: MeshInstance3D = MeshInstance3D.new()
		var pcap: CapsuleMesh = CapsuleMesh.new()
		pcap.radius = 0.32
		pcap.height = 1.0
		player.mesh = pcap
		player.position = spec[0]
		var pmat: StandardMaterial3D = StandardMaterial3D.new()
		var color: Color = spec[1]
		pmat.albedo_color = Color(color.r * 0.55, color.g * 0.55, color.b * 0.55)
		pmat.emission_enabled = true
		pmat.emission = color
		pmat.emission_energy_multiplier = 0.45
		pmat.metallic = 0.35
		pmat.roughness = 0.55
		player.material_override = pmat
		scene.add_child(player)
		# Name floating overhead
		var label: Label3D = Label3D.new()
		label.text = spec[2]
		label.position = spec[0] + Vector3(0, 0.95, 0)
		label.modulate = color
		label.outline_modulate = Color(0, 0, 0, 0.85)
		label.outline_size = 4
		label.font_size = 16
		label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		scene.add_child(label)
	# Collision around table
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(2.4, 1.4, 2.4)
	cs.shape = cb
	cs.position = Vector3(0, 0.7, 0)
	sb.add_child(cs)
	scene.add_child(sb)


func _build_plaza_directory(geom: Node) -> void:
	## Epic-1 T85: large vertical hologram listing 6 plaza shops/NPCs.
	## Pillar base + a tall holographic display panel. Acts as the plaza's
	## "table of contents" and ties together the 5 sub-zones.
	var dir: Node3D = Node3D.new()
	dir.name = "EastPlazaDirectory"
	dir.position = Vector3(28, 0, -3)
	geom.add_child(dir)
	# Base column
	var base_mat: StandardMaterial3D = StandardMaterial3D.new()
	base_mat.albedo_color = Color(0.10, 0.13, 0.16)
	base_mat.metallic = 0.85
	base_mat.roughness = 0.30
	var base: MeshInstance3D = MeshInstance3D.new()
	var bmesh: BoxMesh = BoxMesh.new()
	bmesh.size = Vector3(0.50, 1.0, 0.50)
	base.mesh = bmesh
	base.position = Vector3(0, 0.50, 0)
	base.material_override = base_mat
	dir.add_child(base)
	# Tall hologram panel
	var panel: MeshInstance3D = MeshInstance3D.new()
	var pmesh: BoxMesh = BoxMesh.new()
	pmesh.size = Vector3(1.4, 2.4, 0.06)
	panel.mesh = pmesh
	panel.position = Vector3(0, 2.20, 0)
	var pmat: StandardMaterial3D = StandardMaterial3D.new()
	pmat.albedo_color = Color(0.10, 0.20, 0.30, 0.45)
	pmat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	pmat.emission_enabled = true
	pmat.emission = Color(0.30, 0.85, 1.0)
	pmat.emission_energy_multiplier = 0.85
	pmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	panel.material_override = pmat
	dir.add_child(panel)
	# Title at the top
	var title: Label3D = Label3D.new()
	title.text = "PLAZA DIRECTORY"
	title.position = Vector3(0, 3.30, 0.05)
	title.modulate = Color(0.55, 0.95, 1.0)
	title.outline_modulate = Color(0, 0, 0, 0.85)
	title.outline_size = 5
	title.font_size = 18
	title.no_depth_test = true
	title.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	dir.add_child(title)
	# 6 listed entries
	var entries: Array[String] = [
		"1. Data Merchant",
		"2. Cipher Lab",
		"3. Tournament",
		"4. Sparring",
		"5. Data Eats",
		"6. Specimen-7",
	]
	for i in entries.size():
		var line: Label3D = Label3D.new()
		line.text = entries[i]
		line.position = Vector3(0, 2.85 - i * 0.28, 0.05)
		line.modulate = Color(0.85, 0.95, 1.0)
		line.outline_modulate = Color(0, 0, 0, 0.85)
		line.outline_size = 4
		line.font_size = 14
		line.no_depth_test = true
		line.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		dir.add_child(line)
	# Collision around base
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(0.50, 1.0, 0.50)
	cs.shape = cb
	cs.position = Vector3(0, 0.50, 0)
	sb.add_child(cs)
	dir.add_child(sb)


func _build_respawn_beacon(geom: Node) -> void:
	## Epic-1 T86: combat respawn beacon — a tall narrow column of stacked
	## glowing rings climbing into the sky. Visually distinct from the save
	## shrine (which is solid green obelisk). This is hovering rings only.
	var beacon: Node3D = Node3D.new()
	beacon.name = "EastPlazaRespawnBeacon"
	beacon.position = Vector3(36, 0, -11)
	geom.add_child(beacon)
	# Tiny base disc
	var base: MeshInstance3D = MeshInstance3D.new()
	var bmesh: CylinderMesh = CylinderMesh.new()
	bmesh.top_radius = 0.55
	bmesh.bottom_radius = 0.55
	bmesh.height = 0.10
	base.mesh = bmesh
	base.position = Vector3(0, 0.05, 0)
	var bmat: StandardMaterial3D = StandardMaterial3D.new()
	bmat.albedo_color = Color(0.10, 0.13, 0.16)
	bmat.metallic = 0.85
	bmat.roughness = 0.30
	bmat.emission_enabled = true
	bmat.emission = Color(0.30, 0.85, 1.0)
	bmat.emission_energy_multiplier = 0.7
	base.material_override = bmat
	beacon.add_child(base)
	# 6 stacked glowing rings rising upward
	var ring_mat: StandardMaterial3D = StandardMaterial3D.new()
	ring_mat.albedo_color = Color(0.30, 0.85, 1.0)
	ring_mat.emission_enabled = true
	ring_mat.emission = Color(0.55, 0.95, 1.0)
	ring_mat.emission_energy_multiplier = 2.4
	ring_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for i in 6:
		var ring: MeshInstance3D = MeshInstance3D.new()
		var rmesh: TorusMesh = TorusMesh.new()
		rmesh.inner_radius = 0.30
		rmesh.outer_radius = 0.40
		ring.mesh = rmesh
		var origin_y: float = 0.50 + i * 0.55
		ring.position = Vector3(0, origin_y, 0)
		ring.material_override = ring_mat
		beacon.add_child(ring)
		# Each ring rises and resets, staggered
		var rise: Tween = create_tween().set_loops()
		rise.tween_interval(i * 0.30)
		rise.tween_property(ring, "position:y", origin_y + 3.30, 2.4).set_ease(Tween.EASE_OUT)
		rise.tween_property(ring, "position:y", origin_y, 0.05)
		rise.tween_interval(0.40)
	# Floating "RESPAWN" label
	var label: Label3D = Label3D.new()
	label.text = "RESPAWN"
	label.position = Vector3(0, 4.5, 0)
	label.modulate = Color(0.55, 0.95, 1.0)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 18
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	beacon.add_child(label)


func _build_ground_glitch(geom: Node) -> void:
	## Epic-1 T87: 4 ground "glitch crack" decals scattered through the
	## plaza — thin emissive cracks suggesting the simulation seams. Each
	## flickers on a fast tween to feel unstable.
	var positions: Array[Vector3] = [
		Vector3(29, 0.04, -11),
		Vector3(38, 0.04, 4),
		Vector3(31, 0.04, 13),
		Vector3(42, 0.04, -8),
	]
	var crack_mat: StandardMaterial3D = StandardMaterial3D.new()
	crack_mat.albedo_color = Color(1.0, 0.20, 0.40)
	crack_mat.emission_enabled = true
	crack_mat.emission = Color(1.0, 0.40, 0.55)
	crack_mat.emission_energy_multiplier = 2.6
	crack_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for i in positions.size():
		var crack_root: Node3D = Node3D.new()
		crack_root.name = "EastPlazaGlitchCrack_%d" % i
		crack_root.position = positions[i]
		crack_root.rotation = Vector3(0, randf() * TAU, 0)
		geom.add_child(crack_root)
		# 3 thin emissive bars at random angles forming a "crack"
		for s in 3:
			var seg: MeshInstance3D = MeshInstance3D.new()
			var smesh: BoxMesh = BoxMesh.new()
			smesh.size = Vector3(0.85 + randf() * 0.4, 0.02, 0.05)
			seg.mesh = smesh
			seg.position = Vector3(randf_range(-0.3, 0.3), 0, randf_range(-0.3, 0.3))
			seg.rotation = Vector3(0, randf() * TAU, 0)
			seg.material_override = crack_mat
			crack_root.add_child(seg)
		# Flicker visibility
		var flicker: Tween = create_tween().set_loops()
		flicker.tween_property(crack_root, "visible", false, 0.08)
		flicker.tween_interval(0.10 + randf() * 0.20)
		flicker.tween_property(crack_root, "visible", true, 0.0)
		flicker.tween_interval(0.85 + randf() * 0.50)


func _build_floating_receipts(geom: Node) -> void:
	## Epic-1 T88: 6 small floating "receipt" papers drifting through the
	## plaza on slow paths, suggesting commerce and ambient wind. Each is a
	## thin amber-tinted card that bobs and slowly cycles between waypoints.
	var paths: Array = [
		[Vector3(28, 1.6, -7), Vector3(30, 2.2, -3), Vector3(28, 1.8, 0)],
		[Vector3(34, 2.0, 5), Vector3(36, 1.6, 9), Vector3(34, 2.4, 5)],
		[Vector3(40, 1.8, -4), Vector3(42, 2.4, 0), Vector3(40, 1.6, 4)],
		[Vector3(32, 2.4, -2), Vector3(34, 1.8, 2), Vector3(32, 2.0, -2)],
		[Vector3(38, 1.6, 11), Vector3(40, 2.2, 13), Vector3(38, 1.8, 11)],
		[Vector3(30, 2.0, 8), Vector3(28, 1.6, 11), Vector3(30, 2.4, 8)],
	]
	for i in paths.size():
		var receipt: MeshInstance3D = MeshInstance3D.new()
		receipt.name = "EastPlazaReceipt_%d" % i
		var rmesh: BoxMesh = BoxMesh.new()
		rmesh.size = Vector3(0.30, 0.45, 0.02)
		receipt.mesh = rmesh
		receipt.position = paths[i][0]
		var rmat: StandardMaterial3D = StandardMaterial3D.new()
		rmat.albedo_color = Color(0.95, 0.90, 0.65)
		rmat.emission_enabled = true
		rmat.emission = Color(1.0, 0.95, 0.55)
		rmat.emission_energy_multiplier = 0.55
		rmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		receipt.material_override = rmat
		geom.add_child(receipt)
		# Drift through waypoints
		var drift: Tween = create_tween().set_loops()
		var path: Array = paths[i]
		for wp in path:
			drift.tween_property(receipt, "position", wp, 3.5).set_ease(Tween.EASE_IN_OUT)
		drift.tween_property(receipt, "position", path[0], 3.5).set_ease(Tween.EASE_IN_OUT)
		# Tumbling rotation
		var tumble: Tween = create_tween().set_loops()
		tumble.tween_property(receipt, "rotation", Vector3(TAU, TAU * 0.5, 0), 6.0)


func _build_combat_golem(geom: Node) -> void:
	## Epic-1 T89: animated combat training golem in the sparring arena.
	## Larger than the practice dummies, has stubby arms that punch the air,
	## and a glowing red core in its chest.
	var golem: Node3D = Node3D.new()
	golem.name = "EastPlazaCombatGolem"
	golem.position = Vector3(34, 0, 9)
	geom.add_child(golem)
	# Stone body
	var body_mat: StandardMaterial3D = StandardMaterial3D.new()
	body_mat.albedo_color = Color(0.20, 0.24, 0.30)
	body_mat.metallic = 0.40
	body_mat.roughness = 0.55
	var body: MeshInstance3D = MeshInstance3D.new()
	var bmesh: BoxMesh = BoxMesh.new()
	bmesh.size = Vector3(1.2, 1.6, 0.85)
	body.mesh = bmesh
	body.position = Vector3(0, 1.20, 0)
	body.material_override = body_mat
	golem.add_child(body)
	# Head box
	var head: MeshInstance3D = MeshInstance3D.new()
	var hmesh: BoxMesh = BoxMesh.new()
	hmesh.size = Vector3(0.85, 0.65, 0.65)
	head.mesh = hmesh
	head.position = Vector3(0, 2.30, 0)
	head.material_override = body_mat
	golem.add_child(head)
	# Glowing red eyes
	var eye_mat: StandardMaterial3D = StandardMaterial3D.new()
	eye_mat.albedo_color = Color(1.0, 0.20, 0.20)
	eye_mat.emission_enabled = true
	eye_mat.emission = Color(1.0, 0.30, 0.30)
	eye_mat.emission_energy_multiplier = 2.6
	eye_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for ex: float in [-0.18, 0.18]:
		var eye: MeshInstance3D = MeshInstance3D.new()
		var emesh: SphereMesh = SphereMesh.new()
		emesh.radius = 0.08
		emesh.height = 0.16
		eye.mesh = emesh
		eye.position = Vector3(ex, 2.35, 0.34)
		eye.material_override = eye_mat
		golem.add_child(eye)
	# Glowing red core in chest
	var core: MeshInstance3D = MeshInstance3D.new()
	var cmesh: SphereMesh = SphereMesh.new()
	cmesh.radius = 0.20
	cmesh.height = 0.40
	core.mesh = cmesh
	core.position = Vector3(0, 1.40, 0.45)
	var cmat: StandardMaterial3D = StandardMaterial3D.new()
	cmat.albedo_color = Color(1.0, 0.30, 0.30)
	cmat.emission_enabled = true
	cmat.emission = Color(1.0, 0.40, 0.30)
	cmat.emission_energy_multiplier = 2.4
	cmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	core.material_override = cmat
	golem.add_child(core)
	# Pulsing core
	var pulse: Tween = create_tween().set_loops()
	pulse.tween_property(core, "scale", Vector3(1.25, 1.25, 1.25), 0.85).set_ease(Tween.EASE_IN_OUT)
	pulse.tween_property(core, "scale", Vector3(1.0, 1.0, 1.0), 0.85).set_ease(Tween.EASE_IN_OUT)
	# 2 stubby arms with punch animation
	for sx: float in [-1.0, 1.0]:
		var arm_pivot: Node3D = Node3D.new()
		arm_pivot.position = Vector3(sx * 0.65, 1.65, 0)
		golem.add_child(arm_pivot)
		var arm: MeshInstance3D = MeshInstance3D.new()
		var amesh: BoxMesh = BoxMesh.new()
		amesh.size = Vector3(0.40, 0.40, 1.0)
		arm.mesh = amesh
		arm.position = Vector3(0, 0, 0.55)
		arm.material_override = body_mat
		arm_pivot.add_child(arm)
		# Punch tween — arm moves forward and back
		var punch: Tween = create_tween().set_loops()
		punch.tween_interval(sx * 0.20 + 0.30)
		punch.tween_property(arm, "position:z", 1.10, 0.18).set_ease(Tween.EASE_OUT)
		punch.tween_property(arm, "position:z", 0.55, 0.30).set_ease(Tween.EASE_IN)
		punch.tween_interval(0.35)
	# Collision around body
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(1.2, 2.6, 0.85)
	cs.shape = cb
	cs.position = Vector3(0, 1.30, 0)
	sb.add_child(cs)
	golem.add_child(sb)


func _build_weather_dial(geom: Node) -> void:
	## Epic-1 T90: a small "weather control dial" kiosk on a tall pole. The
	## dial has 3 setting wedges (sunny/storm/glitch) and an indicator
	## needle that slowly rotates between them.
	var dial: Node3D = Node3D.new()
	dial.name = "EastPlazaWeatherDial"
	dial.position = Vector3(46, 0, 8)
	geom.add_child(dial)
	# Pole
	var pole_mat: StandardMaterial3D = StandardMaterial3D.new()
	pole_mat.albedo_color = Color(0.10, 0.13, 0.16)
	pole_mat.metallic = 0.85
	pole_mat.roughness = 0.30
	var pole: MeshInstance3D = MeshInstance3D.new()
	var pmesh: CylinderMesh = CylinderMesh.new()
	pmesh.top_radius = 0.07
	pmesh.bottom_radius = 0.10
	pmesh.height = 1.85
	pole.mesh = pmesh
	pole.position = Vector3(0, 0.92, 0)
	pole.material_override = pole_mat
	dial.add_child(pole)
	# Dial body — flat disc facing the player
	var disc: MeshInstance3D = MeshInstance3D.new()
	var dmesh: CylinderMesh = CylinderMesh.new()
	dmesh.top_radius = 0.45
	dmesh.bottom_radius = 0.45
	dmesh.height = 0.06
	disc.mesh = dmesh
	disc.position = Vector3(0, 2.0, 0)
	disc.rotation = Vector3(deg_to_rad(90), 0, 0)
	var dmat: StandardMaterial3D = StandardMaterial3D.new()
	dmat.albedo_color = Color(0.18, 0.22, 0.28)
	dmat.metallic = 0.65
	dmat.roughness = 0.30
	disc.material_override = dmat
	dial.add_child(disc)
	# 3 colored wedge labels
	var label_specs: Array = [
		["SUN", Color(1.0, 0.85, 0.30), -0.30, 0.30],
		["STORM", Color(0.55, 0.85, 1.0), 0.30, 0.30],
		["GLITCH", Color(1.0, 0.30, 0.55), 0.0, -0.30],
	]
	for spec in label_specs:
		var label: Label3D = Label3D.new()
		label.text = spec[0]
		label.position = Vector3(spec[2], 2.0 + spec[3], 0.06)
		label.modulate = spec[1]
		label.outline_modulate = Color(0, 0, 0, 0.85)
		label.outline_size = 4
		label.font_size = 12
		label.no_depth_test = true
		dial.add_child(label)
	# Needle indicator on the disc
	var needle_pivot: Node3D = Node3D.new()
	needle_pivot.position = Vector3(0, 2.0, 0.04)
	dial.add_child(needle_pivot)
	var needle: MeshInstance3D = MeshInstance3D.new()
	var nmesh: BoxMesh = BoxMesh.new()
	nmesh.size = Vector3(0.04, 0.34, 0.04)
	needle.mesh = nmesh
	needle.position = Vector3(0, 0.17, 0)
	var nmat: StandardMaterial3D = StandardMaterial3D.new()
	nmat.albedo_color = Color(1.0, 0.95, 0.40)
	nmat.emission_enabled = true
	nmat.emission = Color(1.0, 0.95, 0.55)
	nmat.emission_energy_multiplier = 2.4
	nmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	needle.material_override = nmat
	needle_pivot.add_child(needle)
	# Needle slowly cycles between the 3 settings
	var spin: Tween = create_tween().set_loops()
	spin.tween_property(needle_pivot, "rotation:z", deg_to_rad(-45), 2.0).set_ease(Tween.EASE_IN_OUT)
	spin.tween_interval(1.0)
	spin.tween_property(needle_pivot, "rotation:z", deg_to_rad(45), 2.0).set_ease(Tween.EASE_IN_OUT)
	spin.tween_interval(1.0)
	spin.tween_property(needle_pivot, "rotation:z", deg_to_rad(180), 2.0).set_ease(Tween.EASE_IN_OUT)
	spin.tween_interval(1.0)
	spin.tween_property(needle_pivot, "rotation:z", 0, 2.0).set_ease(Tween.EASE_IN_OUT)
	# Top label
	var label: Label3D = Label3D.new()
	label.text = "WEATHER"
	label.position = Vector3(0, 2.65, 0)
	label.modulate = Color(0.85, 0.95, 1.0)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 14
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	dial.add_child(label)
	# Collision around pole
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cap: CapsuleShape3D = CapsuleShape3D.new()
	cap.radius = 0.20
	cap.height = 1.85
	cs.shape = cap
	cs.position = Vector3(0, 0.92, 0)
	sb.add_child(cs)
	dial.add_child(sb)


func _build_corner_pillars(geom: Node) -> void:
	## Epic-1 T91: 4 massive light pillars at the plaza corners — each is
	## 12m tall with a stacked pattern of stone tiers and a glowing capital
	## crowned by a pulsing emissive sphere. Defines the plaza silhouette.
	var positions: Array[Vector3] = [
		Vector3(22, 0, -18),
		Vector3(46, 0, -18),
		Vector3(22, 0, 18),
		Vector3(46, 0, 18),
	]
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.16, 0.20, 0.26)
	stone_mat.metallic = 0.55
	stone_mat.roughness = 0.45
	for i in positions.size():
		var pillar: Node3D = Node3D.new()
		pillar.name = "EastPlazaCornerPillar_%d" % i
		pillar.position = positions[i]
		geom.add_child(pillar)
		# Wide base
		var base: MeshInstance3D = MeshInstance3D.new()
		var bmesh: BoxMesh = BoxMesh.new()
		bmesh.size = Vector3(2.0, 0.55, 2.0)
		base.mesh = bmesh
		base.position = Vector3(0, 0.27, 0)
		base.material_override = stone_mat
		pillar.add_child(base)
		# Tall column shaft
		var shaft: MeshInstance3D = MeshInstance3D.new()
		var smesh: CylinderMesh = CylinderMesh.new()
		smesh.top_radius = 0.55
		smesh.bottom_radius = 0.65
		smesh.height = 9.5
		shaft.mesh = smesh
		shaft.position = Vector3(0, 5.30, 0)
		shaft.material_override = stone_mat
		pillar.add_child(shaft)
		# Cyan emissive ring inset midway up the shaft
		var ring_mat: StandardMaterial3D = StandardMaterial3D.new()
		ring_mat.albedo_color = Color(0.30, 0.85, 1.0)
		ring_mat.emission_enabled = true
		ring_mat.emission = Color(0.55, 0.95, 1.0)
		ring_mat.emission_energy_multiplier = 1.6
		ring_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		for ry: float in [3.0, 5.5, 8.0]:
			var ring: MeshInstance3D = MeshInstance3D.new()
			var rmesh: TorusMesh = TorusMesh.new()
			rmesh.inner_radius = 0.62
			rmesh.outer_radius = 0.72
			ring.mesh = rmesh
			ring.position = Vector3(0, ry, 0)
			ring.material_override = ring_mat
			pillar.add_child(ring)
		# Wider capital block at the top
		var capital: MeshInstance3D = MeshInstance3D.new()
		var cmesh: BoxMesh = BoxMesh.new()
		cmesh.size = Vector3(1.6, 0.50, 1.6)
		capital.mesh = cmesh
		capital.position = Vector3(0, 10.30, 0)
		capital.material_override = stone_mat
		pillar.add_child(capital)
		# Crowning emissive sphere
		var crown: MeshInstance3D = MeshInstance3D.new()
		var crown_mesh: SphereMesh = SphereMesh.new()
		crown_mesh.radius = 0.65
		crown_mesh.height = 1.30
		crown.mesh = crown_mesh
		crown.position = Vector3(0, 11.20, 0)
		var crown_mat: StandardMaterial3D = StandardMaterial3D.new()
		crown_mat.albedo_color = Color(0.55, 0.95, 1.0)
		crown_mat.emission_enabled = true
		crown_mat.emission = Color(0.55, 0.95, 1.0)
		crown_mat.emission_energy_multiplier = 2.6
		crown_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		crown.material_override = crown_mat
		pillar.add_child(crown)
		# Pulse the crown sphere
		var pulse: Tween = create_tween().set_loops()
		var pulse_speed: float = 1.4 + i * 0.2
		pulse.tween_property(crown, "scale", Vector3(1.20, 1.20, 1.20), pulse_speed).set_ease(Tween.EASE_IN_OUT)
		pulse.tween_property(crown, "scale", Vector3(1.0, 1.0, 1.0), pulse_speed).set_ease(Tween.EASE_IN_OUT)
		# Real OmniLight illuminating the corner
		var light: OmniLight3D = OmniLight3D.new()
		light.position = Vector3(0, 11.20, 0)
		light.light_color = Color(0.55, 0.95, 1.0)
		light.light_energy = 2.8
		light.omni_range = 14.0
		light.omni_attenuation = 1.6
		pillar.add_child(light)
		# Collision around the column
		var sb: StaticBody3D = StaticBody3D.new()
		var cs: CollisionShape3D = CollisionShape3D.new()
		var cap: CapsuleShape3D = CapsuleShape3D.new()
		cap.radius = 0.75
		cap.height = 10.5
		cs.shape = cap
		cs.position = Vector3(0, 5.30, 0)
		sb.add_child(cs)
		pillar.add_child(sb)


func _build_maintenance_patrol(geom: Node) -> void:
	## Epic-1 T92: a maintenance bot patrolling the plaza on a long looping
	## path, visibly larger than the existing ambient bots. Stubby chassis
	## on 4 thin wheels with a bristle "broom" attachment underneath.
	var bot: Node3D = Node3D.new()
	bot.name = "EastPlazaMaintenanceBot"
	bot.position = Vector3(26, 0, -14)
	geom.add_child(bot)
	# Chassis
	var chassis_mat: StandardMaterial3D = StandardMaterial3D.new()
	chassis_mat.albedo_color = Color(0.95, 0.65, 0.20)
	chassis_mat.emission_enabled = true
	chassis_mat.emission = Color(1.0, 0.75, 0.30)
	chassis_mat.emission_energy_multiplier = 0.45
	chassis_mat.metallic = 0.55
	chassis_mat.roughness = 0.40
	var chassis: MeshInstance3D = MeshInstance3D.new()
	var cmesh: BoxMesh = BoxMesh.new()
	cmesh.size = Vector3(0.95, 0.55, 1.20)
	chassis.mesh = cmesh
	chassis.position = Vector3(0, 0.45, 0)
	chassis.material_override = chassis_mat
	bot.add_child(chassis)
	# Cyan dome eye
	var eye: MeshInstance3D = MeshInstance3D.new()
	var emesh: SphereMesh = SphereMesh.new()
	emesh.radius = 0.18
	emesh.height = 0.36
	eye.mesh = emesh
	eye.position = Vector3(0, 0.85, 0)
	var emat: StandardMaterial3D = StandardMaterial3D.new()
	emat.albedo_color = Color(0.30, 0.85, 1.0)
	emat.emission_enabled = true
	emat.emission = Color(0.55, 0.95, 1.0)
	emat.emission_energy_multiplier = 2.0
	emat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	eye.material_override = emat
	bot.add_child(eye)
	# 4 wheels
	var wheel_mat: StandardMaterial3D = StandardMaterial3D.new()
	wheel_mat.albedo_color = Color(0.10, 0.13, 0.16)
	wheel_mat.metallic = 0.85
	for ox: float in [-0.40, 0.40]:
		for oz: float in [-0.50, 0.50]:
			var wheel: MeshInstance3D = MeshInstance3D.new()
			var wmesh: CylinderMesh = CylinderMesh.new()
			wmesh.top_radius = 0.18
			wmesh.bottom_radius = 0.18
			wmesh.height = 0.10
			wheel.mesh = wmesh
			wheel.position = Vector3(ox, 0.18, oz)
			wheel.rotation = Vector3(0, 0, deg_to_rad(90))
			wheel.material_override = wheel_mat
			bot.add_child(wheel)
	# Bristle broom — thin emissive bars hanging below
	var bristle_mat: StandardMaterial3D = StandardMaterial3D.new()
	bristle_mat.albedo_color = Color(1.0, 0.85, 0.30)
	bristle_mat.emission_enabled = true
	bristle_mat.emission = Color(1.0, 0.85, 0.30)
	bristle_mat.emission_energy_multiplier = 1.4
	bristle_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for bx in 5:
		var bristle: MeshInstance3D = MeshInstance3D.new()
		var bmesh: BoxMesh = BoxMesh.new()
		bmesh.size = Vector3(0.02, 0.18, 0.6)
		bristle.mesh = bmesh
		bristle.position = Vector3(-0.30 + bx * 0.15, 0.10, -0.65)
		bristle.material_override = bristle_mat
		bot.add_child(bristle)
	# Patrol path tween — long loop around the plaza
	var waypoints: Array[Vector3] = [
		Vector3(26, 0, -14),
		Vector3(45, 0, -14),
		Vector3(45, 0, 16),
		Vector3(26, 0, 16),
		Vector3(26, 0, -14),
	]
	var patrol: Tween = create_tween().set_loops()
	for wi in waypoints.size() - 1:
		var from: Vector3 = waypoints[wi]
		var to: Vector3 = waypoints[wi + 1]
		# Face direction of travel
		var dir: Vector3 = (to - from).normalized()
		var yaw: float = atan2(dir.x, dir.z)
		patrol.tween_property(bot, "rotation:y", yaw, 0.3)
		patrol.tween_property(bot, "position", to, 8.0)


func _build_news_ticker(geom: Node) -> void:
	## Epic-1 T93: a large horizontal news ticker mounted on tall columns
	## above the plaza directory. Wide black panel with a long string of
	## news headlines that scrolls (we mock the scroll with a tween moving
	## the label horizontally inside the bar).
	var ticker_root: Node3D = Node3D.new()
	ticker_root.name = "EastPlazaNewsTicker"
	ticker_root.position = Vector3(34, 0, -3)
	geom.add_child(ticker_root)
	# 2 support columns
	var col_mat: StandardMaterial3D = StandardMaterial3D.new()
	col_mat.albedo_color = Color(0.10, 0.13, 0.16)
	col_mat.metallic = 0.85
	col_mat.roughness = 0.30
	for sx: float in [-3.5, 3.5]:
		var col: MeshInstance3D = MeshInstance3D.new()
		var cmesh: CylinderMesh = CylinderMesh.new()
		cmesh.top_radius = 0.10
		cmesh.bottom_radius = 0.14
		cmesh.height = 4.5
		col.mesh = cmesh
		col.position = Vector3(sx, 2.25, 0)
		col.material_override = col_mat
		ticker_root.add_child(col)
		# Collision on each column
		var sb: StaticBody3D = StaticBody3D.new()
		var cs: CollisionShape3D = CollisionShape3D.new()
		var cap: CapsuleShape3D = CapsuleShape3D.new()
		cap.radius = 0.20
		cap.height = 4.5
		cs.shape = cap
		cs.position = Vector3(sx, 2.25, 0)
		sb.add_child(cs)
		ticker_root.add_child(sb)
	# Black bar panel
	var bar: MeshInstance3D = MeshInstance3D.new()
	var bmesh: BoxMesh = BoxMesh.new()
	bmesh.size = Vector3(7.5, 0.85, 0.20)
	bar.mesh = bmesh
	bar.position = Vector3(0, 4.40, 0)
	var bmat: StandardMaterial3D = StandardMaterial3D.new()
	bmat.albedo_color = Color(0.04, 0.06, 0.10)
	bmat.metallic = 0.30
	bmat.roughness = 0.30
	bar.material_override = bmat
	ticker_root.add_child(bar)
	# Top + bottom emissive trim
	var trim_mat: StandardMaterial3D = StandardMaterial3D.new()
	trim_mat.albedo_color = Color(1.0, 0.40, 0.20)
	trim_mat.emission_enabled = true
	trim_mat.emission = Color(1.0, 0.55, 0.20)
	trim_mat.emission_energy_multiplier = 1.8
	trim_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for ty: float in [4.83, 3.97]:
		var trim: MeshInstance3D = MeshInstance3D.new()
		var tmesh: BoxMesh = BoxMesh.new()
		tmesh.size = Vector3(7.5, 0.05, 0.22)
		trim.mesh = tmesh
		trim.position = Vector3(0, ty, 0)
		trim.material_override = trim_mat
		ticker_root.add_child(trim)
	# Scrolling news label — clipped within bar via tween x position
	var headline: Label3D = Label3D.new()
	headline.text = "*** GLOBBLER SIGHTED IN EAST PLAZA  ***  TOURNAMENT FINALS TONIGHT  ***  CIPHER 99 STILL UNDEFEATED  ***  DATA SHARDS UP 12%  ***"
	headline.position = Vector3(3.5, 4.40, 0.12)
	headline.modulate = Color(1.0, 0.55, 0.20)
	headline.outline_modulate = Color(0, 0, 0, 0.85)
	headline.outline_size = 4
	headline.font_size = 22
	headline.no_depth_test = true
	ticker_root.add_child(headline)
	var scroll: Tween = create_tween().set_loops()
	scroll.tween_property(headline, "position:x", -10.5, 18.0)
	scroll.tween_property(headline, "position:x", 3.5, 0.05)


func _build_data_spa(geom: Node) -> void:
	## Epic-1 T94: a small relaxation pool — sunken cyan disc with 3 NPC
	## "bathers" hovering inside (just heads + shoulders above the surface).
	## Adds a "leisure" vibe to balance the combat-heavy areas.
	var spa: Node3D = Node3D.new()
	spa.name = "EastPlazaDataSpa"
	spa.position = Vector3(46, 0, -10)
	geom.add_child(spa)
	# Pool rim — wide flat torus
	var rim: MeshInstance3D = MeshInstance3D.new()
	var rim_mesh: TorusMesh = TorusMesh.new()
	rim_mesh.inner_radius = 1.40
	rim_mesh.outer_radius = 1.65
	rim.mesh = rim_mesh
	rim.position = Vector3(0, 0.20, 0)
	var rim_mat: StandardMaterial3D = StandardMaterial3D.new()
	rim_mat.albedo_color = Color(0.18, 0.22, 0.28)
	rim_mat.metallic = 0.65
	rim_mat.roughness = 0.30
	rim_mat.emission_enabled = true
	rim_mat.emission = Color(0.30, 0.85, 1.0)
	rim_mat.emission_energy_multiplier = 0.5
	rim.material_override = rim_mat
	spa.add_child(rim)
	# Water disc inside the rim
	var water: MeshInstance3D = MeshInstance3D.new()
	var wmesh: CylinderMesh = CylinderMesh.new()
	wmesh.top_radius = 1.40
	wmesh.bottom_radius = 1.40
	wmesh.height = 0.10
	water.mesh = wmesh
	water.position = Vector3(0, 0.15, 0)
	var wmat: StandardMaterial3D = StandardMaterial3D.new()
	wmat.albedo_color = Color(0.30, 0.85, 1.0, 0.55)
	wmat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	wmat.emission_enabled = true
	wmat.emission = Color(0.55, 0.95, 1.0)
	wmat.emission_energy_multiplier = 1.4
	wmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	water.material_override = wmat
	spa.add_child(water)
	# 3 bather "heads" peeking above the water
	var bather_specs: Array = [
		[Vector3(-0.7, 0.30, 0), Color(0.95, 0.65, 0.45)],
		[Vector3(0.7, 0.30, -0.3), Color(0.85, 0.40, 1.0)],
		[Vector3(0.0, 0.30, 0.7), Color(0.45, 0.95, 0.65)],
	]
	for i in bather_specs.size():
		var bather: Node3D = Node3D.new()
		bather.name = "Bather_%d" % i
		bather.position = bather_specs[i][0]
		spa.add_child(bather)
		# Head
		var head: MeshInstance3D = MeshInstance3D.new()
		var hmesh: SphereMesh = SphereMesh.new()
		hmesh.radius = 0.18
		hmesh.height = 0.36
		head.mesh = hmesh
		head.position = Vector3(0, 0.10, 0)
		var color: Color = bather_specs[i][1]
		var hmat: StandardMaterial3D = StandardMaterial3D.new()
		hmat.albedo_color = color
		hmat.emission_enabled = true
		hmat.emission = color
		hmat.emission_energy_multiplier = 0.55
		hmat.metallic = 0.20
		hmat.roughness = 0.55
		head.material_override = hmat
		bather.add_child(head)
		# Eyes (closed/relaxing — 2 small black bars)
		var eye_mat: StandardMaterial3D = StandardMaterial3D.new()
		eye_mat.albedo_color = Color(0.05, 0.05, 0.10)
		eye_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		for ex: float in [-0.06, 0.06]:
			var eye: MeshInstance3D = MeshInstance3D.new()
			var emesh: BoxMesh = BoxMesh.new()
			emesh.size = Vector3(0.04, 0.01, 0.02)
			eye.mesh = emesh
			eye.position = Vector3(ex, 0.13, 0.16)
			eye.material_override = eye_mat
			bather.add_child(eye)
		# Bob in the water
		var bob: Tween = create_tween().set_loops()
		bob.tween_property(bather, "position:y", 0.40, 1.6 + i * 0.2).set_ease(Tween.EASE_IN_OUT)
		bob.tween_property(bather, "position:y", 0.30, 1.6 + i * 0.2).set_ease(Tween.EASE_IN_OUT)
	# Steam particles rising
	var steam: GPUParticles3D = GPUParticles3D.new()
	steam.amount = 30
	steam.lifetime = 3.0
	steam.position = Vector3(0, 0.50, 0)
	var spmat: ParticleProcessMaterial = ParticleProcessMaterial.new()
	spmat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	spmat.emission_sphere_radius = 1.20
	spmat.direction = Vector3(0, 1, 0)
	spmat.spread = 25.0
	spmat.initial_velocity_min = 0.40
	spmat.initial_velocity_max = 0.85
	spmat.gravity = Vector3.ZERO
	spmat.scale_min = 0.30
	spmat.scale_max = 0.55
	spmat.color = Color(0.85, 0.95, 1.0, 0.30)
	steam.process_material = spmat
	var sm: SphereMesh = SphereMesh.new()
	sm.radius = 0.30
	sm.height = 0.60
	var sm_mat: StandardMaterial3D = StandardMaterial3D.new()
	sm_mat.albedo_color = Color(0.85, 0.95, 1.0, 0.30)
	sm_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	sm_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	sm.material = sm_mat
	steam.draw_pass_1 = sm
	spa.add_child(steam)


func _build_plaza_fireworks(geom: Node) -> void:
	## Epic-1 T95: ambient fireworks emitter high over the plaza center,
	## continuously bursting cyan/violet/amber sparks. Sells "active festive
	## district" with one VFX call.
	var fw: GPUParticles3D = GPUParticles3D.new()
	fw.name = "EastPlazaFireworks"
	fw.position = Vector3(34, 14, 0)
	fw.amount = 120
	fw.lifetime = 2.5
	fw.explosiveness = 0.6
	var pmat: ParticleProcessMaterial = ParticleProcessMaterial.new()
	pmat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	pmat.emission_sphere_radius = 0.30
	pmat.direction = Vector3(0, 0, 0)
	pmat.spread = 180.0
	pmat.initial_velocity_min = 3.0
	pmat.initial_velocity_max = 6.0
	pmat.gravity = Vector3(0, -2.5, 0)
	pmat.scale_min = 0.10
	pmat.scale_max = 0.22
	pmat.color = Color(0.55, 0.95, 1.0, 1.0)
	# Color ramp via gradient
	var grad: Gradient = Gradient.new()
	grad.add_point(0.0, Color(0.55, 0.95, 1.0, 1.0))
	grad.add_point(0.4, Color(0.85, 0.40, 1.0, 1.0))
	grad.add_point(0.75, Color(1.0, 0.85, 0.30, 0.8))
	grad.add_point(1.0, Color(1.0, 0.30, 0.30, 0.0))
	var grad_tex: GradientTexture1D = GradientTexture1D.new()
	grad_tex.gradient = grad
	pmat.color_ramp = grad_tex
	fw.process_material = pmat
	var spark: SphereMesh = SphereMesh.new()
	spark.radius = 0.08
	spark.height = 0.16
	var spark_mat: StandardMaterial3D = StandardMaterial3D.new()
	spark_mat.albedo_color = Color(1, 1, 1)
	spark_mat.emission_enabled = true
	spark_mat.emission = Color(1, 1, 1)
	spark_mat.emission_energy_multiplier = 2.5
	spark_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	spark.material = spark_mat
	fw.draw_pass_1 = spark
	geom.add_child(fw)


func _build_welcome_arch_banner(geom: Node) -> void:
	## Epic-1 T96: a wide cyan banner stretched between the existing plaza
	## arch pillars at the west entrance reading "WELCOME TO EAST PLAZA".
	## The banner has waving emissive trim and a slow alpha pulse.
	var banner_root: Node3D = Node3D.new()
	banner_root.name = "EastPlazaWelcomeBanner"
	banner_root.position = Vector3(22, 0, 0)
	geom.add_child(banner_root)
	# Banner cloth — long horizontal box stretched between the existing
	# plaza arch pillars (which sit roughly at z=-3 and z=3 at x=22)
	var cloth: MeshInstance3D = MeshInstance3D.new()
	var cmesh: BoxMesh = BoxMesh.new()
	cmesh.size = Vector3(0.10, 0.95, 6.5)
	cloth.mesh = cmesh
	cloth.position = Vector3(0, 4.4, 0)
	var cmat: StandardMaterial3D = StandardMaterial3D.new()
	cmat.albedo_color = Color(0.10, 0.20, 0.30)
	cmat.emission_enabled = true
	cmat.emission = Color(0.30, 0.85, 1.0)
	cmat.emission_energy_multiplier = 1.0
	cmat.metallic = 0.10
	cmat.roughness = 0.55
	cloth.material_override = cmat
	banner_root.add_child(cloth)
	# Top + bottom emissive trim
	var trim_mat: StandardMaterial3D = StandardMaterial3D.new()
	trim_mat.albedo_color = Color(0.55, 0.95, 1.0)
	trim_mat.emission_enabled = true
	trim_mat.emission = Color(0.55, 0.95, 1.0)
	trim_mat.emission_energy_multiplier = 2.0
	trim_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for ty: float in [4.85, 3.95]:
		var trim: MeshInstance3D = MeshInstance3D.new()
		var tmesh: BoxMesh = BoxMesh.new()
		tmesh.size = Vector3(0.12, 0.08, 6.5)
		trim.mesh = tmesh
		trim.position = Vector3(0, ty, 0)
		trim.material_override = trim_mat
		banner_root.add_child(trim)
	# Welcome text — duplicate on each side so it reads from both directions
	for fx: float in [-0.10, 0.10]:
		var label: Label3D = Label3D.new()
		label.text = "WELCOME TO\nEAST PLAZA"
		label.position = Vector3(fx, 4.40, 0)
		label.rotation = Vector3(0, deg_to_rad(-90 if fx < 0 else 90), 0)
		label.modulate = Color(0.55, 0.95, 1.0)
		label.outline_modulate = Color(0, 0, 0, 0.85)
		label.outline_size = 6
		label.font_size = 24
		label.no_depth_test = true
		banner_root.add_child(label)
	# Slow alpha pulse to feel "alive"
	var pulse: Tween = create_tween().set_loops()
	pulse.tween_property(cmat, "emission_energy_multiplier", 1.6, 2.0).set_ease(Tween.EASE_IN_OUT)
	pulse.tween_property(cmat, "emission_energy_multiplier", 0.85, 2.0).set_ease(Tween.EASE_IN_OUT)


func _build_statue_spotlights(geom: Node) -> void:
	## Epic-1 T97: 4 ground-mounted SpotLight3Ds aimed up at the central AI
	## statue at (32, 0, -12). Each spotlight is a different color from the
	## ancestor bust palette (cyan, violet, green, amber) plus a tiny visible
	## floor housing so the lights look intentional.
	var center := Vector3(32, 0, -12)
	var light_specs: Array = [
		[Vector3(-2.0, 0, -2.0), Color(0.30, 0.85, 1.0)],
		[Vector3(2.0, 0, -2.0), Color(0.85, 0.40, 1.0)],
		[Vector3(-2.0, 0, 2.0), Color(0.45, 0.95, 0.65)],
		[Vector3(2.0, 0, 2.0), Color(0.95, 0.65, 0.20)],
	]
	for i in light_specs.size():
		var spot_root: Node3D = Node3D.new()
		spot_root.name = "EastPlazaStatueSpot_%d" % i
		spot_root.position = center + light_specs[i][0]
		geom.add_child(spot_root)
		# Floor housing — small dark disc
		var housing: MeshInstance3D = MeshInstance3D.new()
		var hmesh: CylinderMesh = CylinderMesh.new()
		hmesh.top_radius = 0.30
		hmesh.bottom_radius = 0.32
		hmesh.height = 0.20
		housing.mesh = hmesh
		housing.position = Vector3(0, 0.10, 0)
		var hmat: StandardMaterial3D = StandardMaterial3D.new()
		hmat.albedo_color = Color(0.10, 0.13, 0.16)
		hmat.metallic = 0.85
		hmat.roughness = 0.30
		hmat.emission_enabled = true
		hmat.emission = light_specs[i][1]
		hmat.emission_energy_multiplier = 1.0
		housing.material_override = hmat
		spot_root.add_child(housing)
		# Pointing toward the statue center (+y aim component)
		var spot: SpotLight3D = SpotLight3D.new()
		spot.position = Vector3(0, 0.25, 0)
		# Aim at statue body (~2m up at center)
		var to_statue: Vector3 = (center + Vector3(0, 2.0, 0)) - spot_root.position
		var aim_dir: Vector3 = to_statue.normalized()
		# look_at would set rotation; build manually instead
		var spot_yaw: float = atan2(aim_dir.x, aim_dir.z)
		var spot_pitch: float = -asin(aim_dir.y)
		spot.rotation = Vector3(spot_pitch, spot_yaw, 0)
		spot.light_color = light_specs[i][1]
		spot.light_energy = 3.0
		spot.spot_range = 8.0
		spot.spot_angle = 22.0
		spot.spot_attenuation = 1.4
		spot_root.add_child(spot)


func _build_plaza_ambient_lighting(geom: Node) -> void:
	## Epic-1 T98: 3 high omni fill lights spaced along the plaza length
	## bringing the overall light level up so all the new geometry reads
	## nicely. Soft cyan-tinted to reinforce the digital theme.
	var positions: Array[Vector3] = [
		Vector3(28, 8, 0),
		Vector3(36, 8, 0),
		Vector3(44, 8, 0),
	]
	for i in positions.size():
		var fill: OmniLight3D = OmniLight3D.new()
		fill.name = "EastPlazaFillLight_%d" % i
		fill.position = positions[i]
		fill.light_color = Color(0.75, 0.90, 1.0)
		fill.light_energy = 1.4
		fill.omni_range = 18.0
		fill.omni_attenuation = 1.6
		geom.add_child(fill)


func _build_epic1_plaque(geom: Node) -> void:
	## Epic-1 T99: a small commemorative plaque near the east gate marking
	## the completion of Epic 1. Stone tablet on a tiny pedestal with text.
	var plaque: Node3D = Node3D.new()
	plaque.name = "EastPlazaEpic1Plaque"
	plaque.position = Vector3(47, 0, 6)
	geom.add_child(plaque)
	# Tiny pedestal
	var ped_mat: StandardMaterial3D = StandardMaterial3D.new()
	ped_mat.albedo_color = Color(0.18, 0.22, 0.28)
	ped_mat.metallic = 0.55
	ped_mat.roughness = 0.45
	var ped: MeshInstance3D = MeshInstance3D.new()
	var pmesh: BoxMesh = BoxMesh.new()
	pmesh.size = Vector3(0.85, 0.50, 0.40)
	ped.mesh = pmesh
	ped.position = Vector3(0, 0.25, 0)
	ped.material_override = ped_mat
	plaque.add_child(ped)
	# Tilted stone tablet on top
	var tablet: MeshInstance3D = MeshInstance3D.new()
	var tmesh: BoxMesh = BoxMesh.new()
	tmesh.size = Vector3(0.85, 0.65, 0.06)
	tablet.mesh = tmesh
	tablet.position = Vector3(0, 0.85, 0)
	tablet.rotation = Vector3(deg_to_rad(-25), 0, 0)
	var tmat: StandardMaterial3D = StandardMaterial3D.new()
	tmat.albedo_color = Color(0.30, 0.34, 0.40)
	tmat.metallic = 0.65
	tmat.roughness = 0.30
	tmat.emission_enabled = true
	tmat.emission = Color(0.55, 0.95, 1.0)
	tmat.emission_energy_multiplier = 0.40
	tablet.material_override = tmat
	plaque.add_child(tablet)
	# Engraved text on tablet
	var label: Label3D = Label3D.new()
	label.text = "EPIC 01\nEAST PLAZA\nCOMPLETE"
	label.position = Vector3(0, 0.95, 0.18)
	label.rotation = Vector3(deg_to_rad(-25), 0, 0)
	label.modulate = Color(0.55, 0.95, 1.0)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 4
	label.font_size = 16
	label.no_depth_test = true
	plaque.add_child(label)
	# Collision
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(0.85, 0.60, 0.40)
	cs.shape = cb
	cs.position = Vector3(0, 0.30, 0)
	sb.add_child(cs)
	plaque.add_child(sb)


func _build_central_globbler_landmark(geom: Node) -> void:
	## Epic-1 T100 (FINALE): a massive central holographic Globbler
	## landmark hovering 10m above the plaza market core, slowly rotating.
	## Visible from anywhere in the district. Marks the East Plaza as
	## the player's home base in the most unmissable way possible.
	var landmark: Node3D = Node3D.new()
	landmark.name = "EastPlazaCentralLandmark"
	landmark.position = Vector3(32, 10, 0)
	geom.add_child(landmark)
	# Inner pivot for rotation
	var pivot: Node3D = Node3D.new()
	pivot.name = "RotationPivot"
	landmark.add_child(pivot)
	# Translucent holographic Globbler — large sphere body
	var holo_mat: StandardMaterial3D = StandardMaterial3D.new()
	holo_mat.albedo_color = Color(0.55, 0.85, 1.0, 0.50)
	holo_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	holo_mat.emission_enabled = true
	holo_mat.emission = Color(0.55, 0.95, 1.0)
	holo_mat.emission_energy_multiplier = 2.0
	holo_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	# Body sphere
	var body: MeshInstance3D = MeshInstance3D.new()
	var bmesh: SphereMesh = SphereMesh.new()
	bmesh.radius = 1.40
	bmesh.height = 2.80
	body.mesh = bmesh
	body.position = Vector3(0, 0, 0)
	body.material_override = holo_mat
	pivot.add_child(body)
	# 2 large eyes (white emissive)
	var eye_mat: StandardMaterial3D = StandardMaterial3D.new()
	eye_mat.albedo_color = Color(1, 1, 1, 0.9)
	eye_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	eye_mat.emission_enabled = true
	eye_mat.emission = Color(1, 1, 1)
	eye_mat.emission_energy_multiplier = 3.0
	eye_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for ex: float in [-0.45, 0.45]:
		var eye: MeshInstance3D = MeshInstance3D.new()
		var emesh: SphereMesh = SphereMesh.new()
		emesh.radius = 0.28
		emesh.height = 0.56
		eye.mesh = emesh
		eye.position = Vector3(ex, 0.30, 1.20)
		eye.material_override = eye_mat
		pivot.add_child(eye)
		# Pupil dot (cyan)
		var pupil: MeshInstance3D = MeshInstance3D.new()
		var pmesh: SphereMesh = SphereMesh.new()
		pmesh.radius = 0.12
		pmesh.height = 0.24
		pupil.mesh = pmesh
		pupil.position = Vector3(ex, 0.30, 1.40)
		var pmat: StandardMaterial3D = StandardMaterial3D.new()
		pmat.albedo_color = Color(0.30, 0.85, 1.0)
		pmat.emission_enabled = true
		pmat.emission = Color(0.55, 0.95, 1.0)
		pmat.emission_energy_multiplier = 3.5
		pmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		pupil.material_override = pmat
		pivot.add_child(pupil)
	# 4 orbital rings around the body at different tilts
	for i in 4:
		var ring: MeshInstance3D = MeshInstance3D.new()
		var rmesh: TorusMesh = TorusMesh.new()
		rmesh.inner_radius = 1.85 + i * 0.10
		rmesh.outer_radius = 1.95 + i * 0.10
		ring.mesh = rmesh
		ring.rotation = Vector3(deg_to_rad(15 + i * 35), deg_to_rad(i * 20), deg_to_rad(i * 25))
		var rmat: StandardMaterial3D = StandardMaterial3D.new()
		rmat.albedo_color = Color(0.55, 0.95, 1.0)
		rmat.emission_enabled = true
		rmat.emission = Color(0.55, 0.95, 1.0)
		rmat.emission_energy_multiplier = 2.4
		rmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		ring.material_override = rmat
		pivot.add_child(ring)
		# Counter-rotate each ring
		var ring_spin: Tween = create_tween().set_loops()
		var spin_dir: float = 1.0 if i % 2 == 0 else -1.0
		ring_spin.tween_property(ring, "rotation:z", deg_to_rad(i * 25) + TAU * spin_dir, 8.0 + i * 1.5)
	# Slow main rotation
	var spin: Tween = create_tween().set_loops()
	spin.tween_property(pivot, "rotation:y", TAU, 18.0)
	# Bobbing in place
	var bob: Tween = create_tween().set_loops()
	bob.tween_property(landmark, "position:y", 11.0, 3.0).set_ease(Tween.EASE_IN_OUT)
	bob.tween_property(landmark, "position:y", 10.0, 3.0).set_ease(Tween.EASE_IN_OUT)
	# Ground halo beneath the landmark
	var halo: MeshInstance3D = MeshInstance3D.new()
	var hmesh: TorusMesh = TorusMesh.new()
	hmesh.inner_radius = 3.5
	hmesh.outer_radius = 4.0
	halo.mesh = hmesh
	halo.position = Vector3(32, 0.05, 0)
	var hmat: StandardMaterial3D = StandardMaterial3D.new()
	hmat.albedo_color = Color(0.55, 0.95, 1.0)
	hmat.emission_enabled = true
	hmat.emission = Color(0.55, 0.95, 1.0)
	hmat.emission_energy_multiplier = 2.4
	hmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	halo.material_override = hmat
	geom.add_child(halo)
	# Pulse the ground halo
	var halo_pulse: Tween = create_tween().set_loops()
	halo_pulse.tween_property(halo, "scale", Vector3(1.20, 1.0, 1.20), 2.0).set_ease(Tween.EASE_IN_OUT)
	halo_pulse.tween_property(halo, "scale", Vector3(1.0, 1.0, 1.0), 2.0).set_ease(Tween.EASE_IN_OUT)
	# Real OmniLight at the landmark casting cyan light over the plaza
	var landmark_light: OmniLight3D = OmniLight3D.new()
	landmark_light.position = Vector3(0, 0, 0)
	landmark_light.light_color = Color(0.55, 0.95, 1.0)
	landmark_light.light_energy = 3.5
	landmark_light.omni_range = 25.0
	landmark_light.omni_attenuation = 1.4
	pivot.add_child(landmark_light)


func _build_d2_crashed_ship(geom: Node) -> void:
	## Epic-2 T6: a large crashed data ship wreckage near the D2 center.
	## Tilted hull (a wide angled box) with broken wing fins, exposed
	## glowing engine core, and impact debris scattered around it.
	var ship: Node3D = Node3D.new()
	ship.name = "D2CrashedShip"
	ship.position = D2_CENTER + Vector3(8, 0, 8)
	ship.rotation = Vector3(deg_to_rad(-12), deg_to_rad(35), deg_to_rad(-8))
	geom.add_child(ship)
	# Hull material — dark armored grey
	var hull_mat: StandardMaterial3D = StandardMaterial3D.new()
	hull_mat.albedo_color = Color(0.16, 0.18, 0.22)
	hull_mat.metallic = 0.85
	hull_mat.roughness = 0.40
	# Main fuselage — tapered box (we use a prism for the front)
	var hull: MeshInstance3D = MeshInstance3D.new()
	var hmesh: BoxMesh = BoxMesh.new()
	hmesh.size = Vector3(6.0, 1.6, 2.4)
	hull.mesh = hmesh
	hull.position = Vector3(0, 0.95, 0)
	hull.material_override = hull_mat
	ship.add_child(hull)
	# Tapered nose (prism)
	var nose: MeshInstance3D = MeshInstance3D.new()
	var nmesh: PrismMesh = PrismMesh.new()
	nmesh.size = Vector3(2.4, 1.6, 2.4)
	nose.mesh = nmesh
	nose.position = Vector3(4.20, 0.95, 0)
	nose.rotation = Vector3(0, deg_to_rad(90), 0)
	nose.material_override = hull_mat
	ship.add_child(nose)
	# 2 wing fins
	for sz: float in [-1.6, 1.6]:
		var fin: MeshInstance3D = MeshInstance3D.new()
		var fmesh: BoxMesh = BoxMesh.new()
		fmesh.size = Vector3(2.6, 0.30, 1.2)
		fin.mesh = fmesh
		fin.position = Vector3(-0.5, 1.0, sz)
		fin.rotation = Vector3(0, 0, deg_to_rad(15 if sz > 0 else -15))
		fin.material_override = hull_mat
		ship.add_child(fin)
	# Exposed engine core at the back — sphere
	var core: MeshInstance3D = MeshInstance3D.new()
	var cmesh: SphereMesh = SphereMesh.new()
	cmesh.radius = 0.55
	cmesh.height = 1.10
	core.mesh = cmesh
	core.position = Vector3(-3.4, 0.95, 0)
	var cmat: StandardMaterial3D = StandardMaterial3D.new()
	cmat.albedo_color = Color(1.0, 0.40, 0.20)
	cmat.emission_enabled = true
	cmat.emission = Color(1.0, 0.55, 0.25)
	cmat.emission_energy_multiplier = 2.6
	cmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	core.material_override = cmat
	ship.add_child(core)
	var core_pulse: Tween = create_tween().set_loops()
	core_pulse.tween_property(core, "scale", Vector3(1.20, 1.20, 1.20), 0.85).set_ease(Tween.EASE_IN_OUT)
	core_pulse.tween_property(core, "scale", Vector3(1.0, 1.0, 1.0), 0.85).set_ease(Tween.EASE_IN_OUT)
	# Cyan cockpit window
	var cockpit: MeshInstance3D = MeshInstance3D.new()
	var cock_mesh: BoxMesh = BoxMesh.new()
	cock_mesh.size = Vector3(1.4, 0.40, 1.4)
	cockpit.mesh = cock_mesh
	cockpit.position = Vector3(2.40, 1.85, 0)
	var cock_mat: StandardMaterial3D = StandardMaterial3D.new()
	cock_mat.albedo_color = Color(0.20, 0.50, 0.70, 0.55)
	cock_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	cock_mat.emission_enabled = true
	cock_mat.emission = Color(0.30, 0.85, 1.0)
	cock_mat.emission_energy_multiplier = 1.4
	cock_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	cockpit.material_override = cock_mat
	ship.add_child(cockpit)
	# Smoke from the engine
	var smoke: GPUParticles3D = GPUParticles3D.new()
	smoke.amount = 30
	smoke.lifetime = 3.5
	smoke.position = Vector3(-3.4, 1.5, 0)
	var pmat: ParticleProcessMaterial = ParticleProcessMaterial.new()
	pmat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	pmat.emission_sphere_radius = 0.30
	pmat.direction = Vector3(0, 1, 0)
	pmat.spread = 25.0
	pmat.initial_velocity_min = 0.85
	pmat.initial_velocity_max = 1.4
	pmat.gravity = Vector3.ZERO
	pmat.scale_min = 0.30
	pmat.scale_max = 0.65
	pmat.color = Color(0.40, 0.40, 0.50, 0.55)
	smoke.process_material = pmat
	var sm_mesh: SphereMesh = SphereMesh.new()
	sm_mesh.radius = 0.30
	sm_mesh.height = 0.60
	var sm_mat: StandardMaterial3D = StandardMaterial3D.new()
	sm_mat.albedo_color = Color(0.40, 0.40, 0.50, 0.55)
	sm_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	sm_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	sm_mesh.material = sm_mat
	smoke.draw_pass_1 = sm_mesh
	ship.add_child(smoke)
	# Collision around hull
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(8.0, 2.5, 3.5)
	cs.shape = cb
	cs.position = Vector3(0, 1.0, 0)
	sb.add_child(cs)
	ship.add_child(sb)


func _build_d2_glitch_enemies(geom: Node) -> void:
	## Epic-2 T7: 3 procedural "glitch enemy" decorative critters pacing
	## the D2 perimeter. Each is a small angular sphere with magenta eyes
	## that hops on a tween — telegraphs combat danger ahead without
	## actually wiring up enemy AI yet.
	var positions: Array[Vector3] = [
		D2_CENTER + Vector3(-4, 0, 12),
		D2_CENTER + Vector3(15, 0, -8),
		D2_CENTER + Vector3(20, 0, 14),
	]
	for i in positions.size():
		var enemy: Node3D = Node3D.new()
		enemy.name = "D2GlitchEnemy_%d" % i
		enemy.position = positions[i]
		geom.add_child(enemy)
		# Faceted body — use prism (3-sided) for jagged look
		var body: MeshInstance3D = MeshInstance3D.new()
		var bmesh: PrismMesh = PrismMesh.new()
		bmesh.size = Vector3(0.85, 0.85, 0.85)
		body.mesh = bmesh
		body.position = Vector3(0, 0.50, 0)
		var bmat: StandardMaterial3D = StandardMaterial3D.new()
		bmat.albedo_color = Color(0.40, 0.10, 0.30)
		bmat.emission_enabled = true
		bmat.emission = Color(1.0, 0.30, 0.55)
		bmat.emission_energy_multiplier = 1.4
		bmat.metallic = 0.40
		bmat.roughness = 0.30
		body.material_override = bmat
		enemy.add_child(body)
		# 2 magenta eyes
		var eye_mat: StandardMaterial3D = StandardMaterial3D.new()
		eye_mat.albedo_color = Color(1.0, 0.30, 0.55)
		eye_mat.emission_enabled = true
		eye_mat.emission = Color(1.0, 0.40, 0.65)
		eye_mat.emission_energy_multiplier = 2.6
		eye_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		for ex: float in [-0.15, 0.15]:
			var eye: MeshInstance3D = MeshInstance3D.new()
			var emesh: SphereMesh = SphereMesh.new()
			emesh.radius = 0.07
			emesh.height = 0.14
			eye.mesh = emesh
			eye.position = Vector3(ex, 0.65, 0.30)
			eye.material_override = eye_mat
			enemy.add_child(eye)
		# Hop tween + spin
		var hop: Tween = create_tween().set_loops()
		hop.tween_property(body, "position:y", 1.10, 0.45).set_ease(Tween.EASE_OUT)
		hop.tween_property(body, "position:y", 0.50, 0.35).set_ease(Tween.EASE_IN)
		hop.tween_interval(0.4 + i * 0.2)
		# Slow patrol path
		var origin: Vector3 = positions[i]
		var patrol: Tween = create_tween().set_loops()
		patrol.tween_property(enemy, "position", origin + Vector3(2, 0, 2), 3.0)
		patrol.tween_property(enemy, "position", origin + Vector3(-2, 0, 2), 3.0)
		patrol.tween_property(enemy, "position", origin + Vector3(-2, 0, -2), 3.0)
		patrol.tween_property(enemy, "position", origin, 3.0)


func _build_d2_flicker_lamps(geom: Node) -> void:
	## Epic-2 T8: 4 broken street lamps across D2 with flickering on/off
	## tweens and slightly leaning angles. Sells "the power's failing here".
	var positions: Array[Vector3] = [
		D2_CENTER + Vector3(-15, 0, -10),
		D2_CENTER + Vector3(-5, 0, 14),
		D2_CENTER + Vector3(10, 0, -14),
		D2_CENTER + Vector3(20, 0, 6),
	]
	for i in positions.size():
		var lamp: Node3D = Node3D.new()
		lamp.name = "D2FlickerLamp_%d" % i
		lamp.position = positions[i]
		lamp.rotation = Vector3(deg_to_rad(randf_range(-12, 12)), 0, deg_to_rad(randf_range(-12, 12)))
		geom.add_child(lamp)
		# Pole
		var pole_mat: StandardMaterial3D = StandardMaterial3D.new()
		pole_mat.albedo_color = Color(0.10, 0.10, 0.12)
		pole_mat.metallic = 0.85
		pole_mat.roughness = 0.50
		var pole: MeshInstance3D = MeshInstance3D.new()
		var pmesh: CylinderMesh = CylinderMesh.new()
		pmesh.top_radius = 0.07
		pmesh.bottom_radius = 0.10
		pmesh.height = 3.4
		pole.mesh = pmesh
		pole.position = Vector3(0, 1.7, 0)
		pole.material_override = pole_mat
		lamp.add_child(pole)
		# Lamp head box at top
		var head: MeshInstance3D = MeshInstance3D.new()
		var hmesh: BoxMesh = BoxMesh.new()
		hmesh.size = Vector3(0.45, 0.30, 0.45)
		head.mesh = hmesh
		head.position = Vector3(0, 3.55, 0)
		head.material_override = pole_mat
		lamp.add_child(head)
		# Bulb (the flicker light)
		var bulb: MeshInstance3D = MeshInstance3D.new()
		var bmesh: SphereMesh = SphereMesh.new()
		bmesh.radius = 0.16
		bmesh.height = 0.32
		bulb.mesh = bmesh
		bulb.position = Vector3(0, 3.30, 0)
		var bmat: StandardMaterial3D = StandardMaterial3D.new()
		bmat.albedo_color = Color(1.0, 0.85, 0.55)
		bmat.emission_enabled = true
		bmat.emission = Color(1.0, 0.85, 0.55)
		bmat.emission_energy_multiplier = 2.0
		bmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		bulb.material_override = bmat
		lamp.add_child(bulb)
		# Real light
		var light: OmniLight3D = OmniLight3D.new()
		light.position = Vector3(0, 3.30, 0)
		light.light_color = Color(1.0, 0.85, 0.55)
		light.light_energy = 1.4
		light.omni_range = 6.0
		lamp.add_child(light)
		# Flicker visibility on bulb + light together
		var flicker: Tween = create_tween().set_loops()
		flicker.tween_interval(0.4 + randf() * 1.5)
		flicker.tween_property(bulb, "visible", false, 0.0)
		flicker.tween_property(light, "visible", false, 0.0)
		flicker.tween_interval(0.08)
		flicker.tween_property(bulb, "visible", true, 0.0)
		flicker.tween_property(light, "visible", true, 0.0)
		flicker.tween_interval(0.05)
		flicker.tween_property(bulb, "visible", false, 0.0)
		flicker.tween_property(light, "visible", false, 0.0)
		flicker.tween_interval(0.18)
		flicker.tween_property(bulb, "visible", true, 0.0)
		flicker.tween_property(light, "visible", true, 0.0)
		# Collision
		var sb: StaticBody3D = StaticBody3D.new()
		var cs: CollisionShape3D = CollisionShape3D.new()
		var cap: CapsuleShape3D = CapsuleShape3D.new()
		cap.radius = 0.20
		cap.height = 3.4
		cs.shape = cap
		cs.position = Vector3(0, 1.7, 0)
		sb.add_child(cs)
		lamp.add_child(sb)


func _build_d2_junk_pile(geom: Node) -> void:
	## Epic-2 T9: a heap of broken hardware — stacked crushed boxes, loose
	## cables coiling out, the occasional emissive flicker. Tells the
	## "this place is a junkyard" story instantly.
	var pile: Node3D = Node3D.new()
	pile.name = "D2JunkPile"
	pile.position = D2_CENTER + Vector3(-6, 0, -14)
	geom.add_child(pile)
	# 6 stacked broken boxes at random sizes/orientations
	var server_mat: StandardMaterial3D = StandardMaterial3D.new()
	server_mat.albedo_color = Color(0.18, 0.20, 0.24)
	server_mat.metallic = 0.65
	server_mat.roughness = 0.50
	var server_specs: Array = [
		[Vector3(0, 0.30, 0), Vector3(1.4, 0.55, 0.85), Vector3(0, 0, 0)],
		[Vector3(0.5, 0.85, 0.2), Vector3(1.0, 0.40, 0.85), Vector3(0, 0, deg_to_rad(8))],
		[Vector3(-0.3, 1.20, -0.2), Vector3(0.85, 0.45, 0.70), Vector3(0, deg_to_rad(15), deg_to_rad(-12))],
		[Vector3(0.7, 0.30, -0.7), Vector3(0.65, 0.55, 0.65), Vector3(0, deg_to_rad(35), 0)],
		[Vector3(-0.6, 0.30, 0.5), Vector3(0.85, 0.55, 0.70), Vector3(0, deg_to_rad(-20), 0)],
		[Vector3(0.2, 1.65, 0.0), Vector3(0.65, 0.40, 0.50), Vector3(0, 0, deg_to_rad(20))],
	]
	for spec in server_specs:
		var server: MeshInstance3D = MeshInstance3D.new()
		var smesh: BoxMesh = BoxMesh.new()
		smesh.size = spec[1]
		server.mesh = smesh
		server.position = spec[0]
		server.rotation = spec[2]
		server.material_override = server_mat
		pile.add_child(server)
		# Small status LED on each (red or green)
		var led: MeshInstance3D = MeshInstance3D.new()
		var lmesh: SphereMesh = SphereMesh.new()
		lmesh.radius = 0.04
		lmesh.height = 0.08
		led.mesh = lmesh
		var spec_size: Vector3 = spec[1]
		led.position = (spec[0] as Vector3) + Vector3(0, 0, spec_size.z * 0.5 + 0.04)
		var lmat: StandardMaterial3D = StandardMaterial3D.new()
		var c: Color = Color(1.0, 0.30, 0.30) if randi() % 2 == 0 else Color(0.30, 1.0, 0.40)
		lmat.albedo_color = c
		lmat.emission_enabled = true
		lmat.emission = c
		lmat.emission_energy_multiplier = 2.6
		lmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		led.material_override = lmat
		pile.add_child(led)
	# Loose cables — 3 thin cylinders snaking out
	var cable_mat: StandardMaterial3D = StandardMaterial3D.new()
	cable_mat.albedo_color = Color(0.10, 0.10, 0.12)
	cable_mat.metallic = 0.30
	for c in 3:
		var cable: MeshInstance3D = MeshInstance3D.new()
		var cmesh: CylinderMesh = CylinderMesh.new()
		cmesh.top_radius = 0.04
		cmesh.bottom_radius = 0.04
		cmesh.height = 1.2 + c * 0.3
		cable.mesh = cmesh
		var angle: float = (float(c) / 3.0) * TAU
		cable.position = Vector3(cos(angle) * 0.85, 0.10, sin(angle) * 0.85)
		cable.rotation = Vector3(deg_to_rad(85), angle, 0)
		cable.material_override = cable_mat
		pile.add_child(cable)
	# Collision around the whole pile
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(2.6, 2.0, 2.0)
	cs.shape = cb
	cs.position = Vector3(0, 1.0, 0)
	sb.add_child(cs)
	pile.add_child(sb)


func _build_d2_abandoned_kiosk(geom: Node) -> void:
	## Epic-2 T10: an abandoned roadside terminal kiosk. The screen is dark
	## and cracked, the structure is leaning, and a "OUT OF ORDER" tag
	## flickers above it.
	var kiosk: Node3D = Node3D.new()
	kiosk.name = "D2AbandonedKiosk"
	kiosk.position = D2_CENTER + Vector3(-10, 0, -2)
	kiosk.rotation = Vector3(0, 0, deg_to_rad(-6))
	geom.add_child(kiosk)
	# Stand
	var stand_mat: StandardMaterial3D = StandardMaterial3D.new()
	stand_mat.albedo_color = Color(0.18, 0.16, 0.14)
	stand_mat.metallic = 0.55
	stand_mat.roughness = 0.55
	var stand: MeshInstance3D = MeshInstance3D.new()
	var smesh: BoxMesh = BoxMesh.new()
	smesh.size = Vector3(0.70, 1.40, 0.50)
	stand.mesh = smesh
	stand.position = Vector3(0, 0.70, 0)
	stand.material_override = stand_mat
	kiosk.add_child(stand)
	# Cracked dark screen
	var screen: MeshInstance3D = MeshInstance3D.new()
	var scr_mesh: BoxMesh = BoxMesh.new()
	scr_mesh.size = Vector3(0.55, 0.50, 0.04)
	screen.mesh = scr_mesh
	screen.position = Vector3(0, 1.20, 0.27)
	var scr_mat: StandardMaterial3D = StandardMaterial3D.new()
	scr_mat.albedo_color = Color(0.04, 0.05, 0.08)
	scr_mat.emission_enabled = true
	scr_mat.emission = Color(0.20, 0.20, 0.30)
	scr_mat.emission_energy_multiplier = 0.30
	scr_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	screen.material_override = scr_mat
	kiosk.add_child(screen)
	# Diagonal crack across the screen
	var crack_mat: StandardMaterial3D = StandardMaterial3D.new()
	crack_mat.albedo_color = Color(0.95, 0.95, 1.0)
	crack_mat.emission_enabled = true
	crack_mat.emission = Color(0.95, 0.95, 1.0)
	crack_mat.emission_energy_multiplier = 1.4
	crack_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for i in 2:
		var crack: MeshInstance3D = MeshInstance3D.new()
		var cmesh: BoxMesh = BoxMesh.new()
		cmesh.size = Vector3(0.50, 0.02, 0.01)
		crack.mesh = cmesh
		crack.position = Vector3(0, 1.20 + i * 0.05, 0.30)
		crack.rotation = Vector3(0, 0, deg_to_rad(-25 + i * 15))
		crack.material_override = crack_mat
		kiosk.add_child(crack)
	# OUT OF ORDER hanging tag above the kiosk
	var tag: MeshInstance3D = MeshInstance3D.new()
	var tmesh: BoxMesh = BoxMesh.new()
	tmesh.size = Vector3(0.85, 0.30, 0.05)
	tag.mesh = tmesh
	tag.position = Vector3(0, 2.0, 0.30)
	var tmat: StandardMaterial3D = StandardMaterial3D.new()
	tmat.albedo_color = Color(0.85, 0.20, 0.20)
	tmat.emission_enabled = true
	tmat.emission = Color(1.0, 0.30, 0.20)
	tmat.emission_energy_multiplier = 1.4
	tmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	tag.material_override = tmat
	kiosk.add_child(tag)
	# Tag label
	var label: Label3D = Label3D.new()
	label.text = "OUT OF\nORDER"
	label.position = Vector3(0, 2.0, 0.34)
	label.modulate = Color(1, 1, 1)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 4
	label.font_size = 14
	label.no_depth_test = true
	kiosk.add_child(label)
	# Flicker tag
	var flicker: Tween = create_tween().set_loops()
	flicker.tween_property(tmat, "emission_energy_multiplier", 0.3, 0.4).set_ease(Tween.EASE_IN_OUT)
	flicker.tween_property(tmat, "emission_energy_multiplier", 1.6, 0.3).set_ease(Tween.EASE_IN_OUT)
	flicker.tween_interval(1.0 + randf() * 1.0)
	# Collision around stand
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(0.70, 1.40, 0.50)
	cs.shape = cb
	cs.position = Vector3(0, 0.70, 0)
	sb.add_child(cs)
	kiosk.add_child(sb)


func _build_d2_craters(geom: Node) -> void:
	## Epic-2 T11: 4 ground impact craters scattered around D2. Each is a
	## flat torus rim slightly recessed with a glowing inner disc.
	var positions: Array[Vector3] = [
		D2_CENTER + Vector3(-12, 0.04, 8),
		D2_CENTER + Vector3(2, 0.04, -12),
		D2_CENTER + Vector3(16, 0.04, 10),
		D2_CENTER + Vector3(22, 0.04, -6),
	]
	for i in positions.size():
		var crater: Node3D = Node3D.new()
		crater.name = "D2Crater_%d" % i
		crater.position = positions[i]
		geom.add_child(crater)
		# Outer rim torus
		var rim: MeshInstance3D = MeshInstance3D.new()
		var rmesh: TorusMesh = TorusMesh.new()
		rmesh.inner_radius = 1.20
		rmesh.outer_radius = 1.50
		rim.mesh = rmesh
		rim.position = Vector3(0, 0.05, 0)
		var rmat: StandardMaterial3D = StandardMaterial3D.new()
		rmat.albedo_color = Color(0.20, 0.10, 0.06)
		rmat.metallic = 0.55
		rmat.roughness = 0.55
		rmat.emission_enabled = true
		rmat.emission = Color(1.0, 0.40, 0.10)
		rmat.emission_energy_multiplier = 0.95
		rim.material_override = rmat
		crater.add_child(rim)
		# Inner glowing disc
		var disc: MeshInstance3D = MeshInstance3D.new()
		var dmesh: CylinderMesh = CylinderMesh.new()
		dmesh.top_radius = 1.15
		dmesh.bottom_radius = 1.15
		dmesh.height = 0.04
		disc.mesh = dmesh
		disc.position = Vector3(0, 0.02, 0)
		var dmat: StandardMaterial3D = StandardMaterial3D.new()
		dmat.albedo_color = Color(1.0, 0.40, 0.10)
		dmat.emission_enabled = true
		dmat.emission = Color(1.0, 0.55, 0.15)
		dmat.emission_energy_multiplier = 1.6
		dmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		disc.material_override = dmat
		crater.add_child(disc)
		# Pulse the disc
		var pulse: Tween = create_tween().set_loops()
		var ps: float = 1.4 + i * 0.2
		pulse.tween_property(disc, "scale", Vector3(1.10, 1.0, 1.10), ps).set_ease(Tween.EASE_IN_OUT)
		pulse.tween_property(disc, "scale", Vector3(0.95, 1.0, 0.95), ps).set_ease(Tween.EASE_IN_OUT)


func _build_d2_barricade(geom: Node) -> void:
	## Epic-2 T12: an overturned crate barricade — 5 angled crates stacked
	## haphazardly across part of the road, partially blocking passage.
	## Glowing red warning bars stretched between two posts.
	var bar: Node3D = Node3D.new()
	bar.name = "D2Barricade"
	bar.position = D2_CENTER + Vector3(-2, 0, 0)
	geom.add_child(bar)
	# 5 stacked tilted crates
	var crate_mat: StandardMaterial3D = StandardMaterial3D.new()
	crate_mat.albedo_color = Color(0.30, 0.18, 0.08)
	crate_mat.metallic = 0.30
	crate_mat.roughness = 0.55
	var crate_specs: Array = [
		[Vector3(-1.0, 0.40, 0.0), Vector3(0, deg_to_rad(15), deg_to_rad(-8))],
		[Vector3(-0.20, 0.40, 0.5), Vector3(0, deg_to_rad(-20), 0)],
		[Vector3(0.6, 0.40, -0.3), Vector3(0, deg_to_rad(35), 0)],
		[Vector3(-0.40, 1.10, 0.2), Vector3(0, deg_to_rad(10), deg_to_rad(15))],
		[Vector3(0.30, 1.10, -0.4), Vector3(0, deg_to_rad(-25), 0)],
	]
	for spec in crate_specs:
		var crate: MeshInstance3D = MeshInstance3D.new()
		var cmesh: BoxMesh = BoxMesh.new()
		cmesh.size = Vector3(0.85, 0.80, 0.85)
		crate.mesh = cmesh
		crate.position = spec[0]
		crate.rotation = spec[1]
		crate.material_override = crate_mat
		bar.add_child(crate)
	# 2 metal posts on either side
	var post_mat: StandardMaterial3D = StandardMaterial3D.new()
	post_mat.albedo_color = Color(0.10, 0.13, 0.16)
	post_mat.metallic = 0.85
	for sx: float in [-1.8, 1.8]:
		var post: MeshInstance3D = MeshInstance3D.new()
		var pmesh: CylinderMesh = CylinderMesh.new()
		pmesh.top_radius = 0.07
		pmesh.bottom_radius = 0.10
		pmesh.height = 1.6
		post.mesh = pmesh
		post.position = Vector3(sx, 0.80, 0)
		post.material_override = post_mat
		bar.add_child(post)
	# 2 horizontal red warning bars between the posts
	var warn_mat: StandardMaterial3D = StandardMaterial3D.new()
	warn_mat.albedo_color = Color(1.0, 0.20, 0.20)
	warn_mat.emission_enabled = true
	warn_mat.emission = Color(1.0, 0.40, 0.30)
	warn_mat.emission_energy_multiplier = 1.8
	warn_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for wy: float in [0.55, 1.10]:
		var warn: MeshInstance3D = MeshInstance3D.new()
		var wmesh: BoxMesh = BoxMesh.new()
		wmesh.size = Vector3(3.6, 0.10, 0.06)
		warn.mesh = wmesh
		warn.position = Vector3(0, wy, 0)
		warn.material_override = warn_mat
		bar.add_child(warn)
	# Pulse warning bars
	var pulse: Tween = create_tween().set_loops()
	pulse.tween_property(warn_mat, "emission_energy_multiplier", 2.6, 0.6).set_ease(Tween.EASE_IN_OUT)
	pulse.tween_property(warn_mat, "emission_energy_multiplier", 0.8, 0.6).set_ease(Tween.EASE_IN_OUT)
	# Collision around the whole barricade
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(3.6, 1.6, 1.4)
	cs.shape = cb
	cs.position = Vector3(0, 0.80, 0)
	sb.add_child(cs)
	bar.add_child(sb)


func _build_d2_toxic_puddles(geom: Node) -> void:
	## Epic-2 T13: 5 toxic glowing puddles on the D2 ground. Each is a
	## low elliptical disc of bright green emissive liquid that pulses
	## scale to feel slimy and unstable.
	var positions: Array[Vector3] = [
		D2_CENTER + Vector3(-8, 0.04, 0),
		D2_CENTER + Vector3(6, 0.04, 6),
		D2_CENTER + Vector3(12, 0.04, -10),
		D2_CENTER + Vector3(18, 0.04, 4),
		D2_CENTER + Vector3(22, 0.04, 12),
	]
	for i in positions.size():
		var puddle: MeshInstance3D = MeshInstance3D.new()
		puddle.name = "D2ToxicPuddle_%d" % i
		var pmesh: CylinderMesh = CylinderMesh.new()
		pmesh.top_radius = 0.65 + randf_range(0, 0.30)
		pmesh.bottom_radius = pmesh.top_radius
		pmesh.height = 0.06
		puddle.mesh = pmesh
		puddle.position = positions[i]
		puddle.scale = Vector3(1.0 + randf_range(-0.30, 0.30), 1.0, 1.0 + randf_range(-0.30, 0.30))
		var pmat: StandardMaterial3D = StandardMaterial3D.new()
		pmat.albedo_color = Color(0.20, 0.95, 0.30)
		pmat.emission_enabled = true
		pmat.emission = Color(0.40, 1.0, 0.30)
		pmat.emission_energy_multiplier = 1.8
		pmat.metallic = 0.30
		pmat.roughness = 0.10
		pmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		puddle.material_override = pmat
		geom.add_child(puddle)
		# Pulse scale to feel like sloshing
		var pulse: Tween = create_tween().set_loops()
		var sx: float = puddle.scale.x
		var sz: float = puddle.scale.z
		var pp: float = 1.4 + i * 0.2
		pulse.tween_property(puddle, "scale", Vector3(sx * 1.10, 1.0, sz * 0.92), pp).set_ease(Tween.EASE_IN_OUT)
		pulse.tween_property(puddle, "scale", Vector3(sx * 0.92, 1.0, sz * 1.10), pp).set_ease(Tween.EASE_IN_OUT)


func _build_d2_falling_sparks(geom: Node) -> void:
	## Epic-2 T14: ambient falling sparks raining down from high above the
	## district — yellow tiny particles falling slowly with gravity. Sells
	## "this place is electrically unstable".
	var sparks: GPUParticles3D = GPUParticles3D.new()
	sparks.name = "D2FallingSparks"
	sparks.position = D2_CENTER + Vector3(0, 12, 0)
	sparks.amount = 60
	sparks.lifetime = 4.5
	sparks.preprocess = 2.0
	var pmat: ParticleProcessMaterial = ParticleProcessMaterial.new()
	pmat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	pmat.emission_box_extents = Vector3(20, 0.5, 18)
	pmat.direction = Vector3(0, -1, 0)
	pmat.spread = 12.0
	pmat.initial_velocity_min = 0.85
	pmat.initial_velocity_max = 1.40
	pmat.gravity = Vector3(0, -1.5, 0)
	pmat.scale_min = 0.04
	pmat.scale_max = 0.10
	pmat.color = Color(1.0, 0.85, 0.30, 1.0)
	sparks.process_material = pmat
	var spark_mesh: SphereMesh = SphereMesh.new()
	spark_mesh.radius = 0.05
	spark_mesh.height = 0.10
	var spark_mat: StandardMaterial3D = StandardMaterial3D.new()
	spark_mat.albedo_color = Color(1.0, 0.85, 0.30)
	spark_mat.emission_enabled = true
	spark_mat.emission = Color(1.0, 0.95, 0.40)
	spark_mat.emission_energy_multiplier = 2.6
	spark_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	spark_mesh.material = spark_mat
	sparks.draw_pass_1 = spark_mesh
	geom.add_child(sparks)


func _build_d2_scavenger_npc() -> void:
	## Epic-2 T15: a scavenger NPC bent over the junk pile sifting through
	## debris. Crouched body, smaller than the wanderer, with a glowing
	## flashlight cone pointed at the ground.
	var slots: Node3D = get_node_or_null("%NPCSlots") as Node3D
	if slots == null:
		return
	var scav: Node3D = Node3D.new()
	scav.name = "D2Scavenger"
	scav.position = D2_CENTER + Vector3(-6, 0, -12)
	slots.add_child(scav)
	# Crouched body — shorter capsule
	var body: MeshInstance3D = MeshInstance3D.new()
	var bmesh: CapsuleMesh = CapsuleMesh.new()
	bmesh.radius = 0.40
	bmesh.height = 0.85
	body.mesh = bmesh
	body.position = Vector3(0, 0.45, 0)
	body.rotation = Vector3(deg_to_rad(35), 0, 0)
	var bmat: StandardMaterial3D = StandardMaterial3D.new()
	bmat.albedo_color = Color(0.28, 0.20, 0.14)
	bmat.metallic = 0.10
	bmat.roughness = 0.65
	body.material_override = bmat
	scav.add_child(body)
	# Goggles head — smaller box
	var head: MeshInstance3D = MeshInstance3D.new()
	var hmesh: BoxMesh = BoxMesh.new()
	hmesh.size = Vector3(0.40, 0.32, 0.40)
	head.mesh = hmesh
	head.position = Vector3(0, 0.85, 0.45)
	var hmat: StandardMaterial3D = StandardMaterial3D.new()
	hmat.albedo_color = Color(0.22, 0.16, 0.10)
	hmat.metallic = 0.30
	hmat.roughness = 0.60
	head.material_override = hmat
	scav.add_child(head)
	# 2 cyan goggle lenses
	var goggle_mat: StandardMaterial3D = StandardMaterial3D.new()
	goggle_mat.albedo_color = Color(0.30, 0.85, 1.0)
	goggle_mat.emission_enabled = true
	goggle_mat.emission = Color(0.55, 0.95, 1.0)
	goggle_mat.emission_energy_multiplier = 2.0
	goggle_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for ex: float in [-0.10, 0.10]:
		var lens: MeshInstance3D = MeshInstance3D.new()
		var lmesh: SphereMesh = SphereMesh.new()
		lmesh.radius = 0.06
		lmesh.height = 0.12
		lens.mesh = lmesh
		lens.position = Vector3(ex, 0.85, 0.66)
		lens.material_override = goggle_mat
		scav.add_child(lens)
	# Flashlight pointed at ground
	var flashlight_root: Node3D = Node3D.new()
	flashlight_root.position = Vector3(0.30, 0.50, 0.40)
	scav.add_child(flashlight_root)
	# Flashlight body
	var flash: MeshInstance3D = MeshInstance3D.new()
	var fmesh: CylinderMesh = CylinderMesh.new()
	fmesh.top_radius = 0.06
	fmesh.bottom_radius = 0.06
	fmesh.height = 0.30
	flash.mesh = fmesh
	flash.rotation = Vector3(deg_to_rad(80), 0, 0)
	flash.material_override = bmat
	flashlight_root.add_child(flash)
	# Flashlight beam (visible cone)
	var beam: MeshInstance3D = MeshInstance3D.new()
	var beam_mesh: CylinderMesh = CylinderMesh.new()
	beam_mesh.top_radius = 0.06
	beam_mesh.bottom_radius = 0.30
	beam_mesh.height = 0.55
	beam.mesh = beam_mesh
	beam.position = Vector3(0, -0.30, 0.30)
	beam.rotation = Vector3(deg_to_rad(80), 0, 0)
	var beam_mat: StandardMaterial3D = StandardMaterial3D.new()
	beam_mat.albedo_color = Color(1.0, 0.95, 0.55, 0.30)
	beam_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	beam_mat.emission_enabled = true
	beam_mat.emission = Color(1.0, 0.95, 0.55)
	beam_mat.emission_energy_multiplier = 1.4
	beam_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	beam.material_override = beam_mat
	flashlight_root.add_child(beam)
	# Sifting hand bobble — body rocks slightly
	var rock: Tween = create_tween().set_loops()
	rock.tween_property(scav, "rotation:y", deg_to_rad(15), 1.4).set_ease(Tween.EASE_IN_OUT)
	rock.tween_property(scav, "rotation:y", deg_to_rad(-15), 1.4).set_ease(Tween.EASE_IN_OUT)
	# Name billboard
	var label: Label3D = Label3D.new()
	label.text = "Scavenger"
	label.position = Vector3(0, 1.4, 0)
	label.modulate = Color(0.85, 0.85, 0.55)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 18
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	scav.add_child(label)


func _build_d2_trial_pit(geom: Node) -> void:
	## Epic-2 T16: a sunken combat trial pit at D2 center+(15, 0, 0).
	## A 6m wide cylinder hole rimmed by a glowing orange torus + 4 spike
	## hazards around the rim. The center has 2 placeholder enemy spawn
	## markers (small red glowing pads).
	var pit: Node3D = Node3D.new()
	pit.name = "D2TrialPit"
	pit.position = D2_CENTER + Vector3(15, 0, 0)
	geom.add_child(pit)
	# Wide flat dark disc as the pit floor (sunken slightly)
	var floor_mat: StandardMaterial3D = StandardMaterial3D.new()
	floor_mat.albedo_color = Color(0.10, 0.06, 0.04)
	floor_mat.metallic = 0.45
	floor_mat.roughness = 0.55
	floor_mat.emission_enabled = true
	floor_mat.emission = Color(0.85, 0.30, 0.10)
	floor_mat.emission_energy_multiplier = 0.35
	var pit_floor: MeshInstance3D = MeshInstance3D.new()
	var fmesh: CylinderMesh = CylinderMesh.new()
	fmesh.top_radius = 3.0
	fmesh.bottom_radius = 3.0
	fmesh.height = 0.10
	pit_floor.mesh = fmesh
	pit_floor.position = Vector3(0, 0.06, 0)
	pit_floor.material_override = floor_mat
	pit.add_child(pit_floor)
	# Glowing rim torus
	var rim: MeshInstance3D = MeshInstance3D.new()
	var rmesh: TorusMesh = TorusMesh.new()
	rmesh.inner_radius = 3.0
	rmesh.outer_radius = 3.30
	rim.mesh = rmesh
	rim.position = Vector3(0, 0.12, 0)
	var rmat: StandardMaterial3D = StandardMaterial3D.new()
	rmat.albedo_color = Color(1.0, 0.40, 0.10)
	rmat.emission_enabled = true
	rmat.emission = Color(1.0, 0.55, 0.15)
	rmat.emission_energy_multiplier = 1.8
	rmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	rim.material_override = rmat
	pit.add_child(rim)
	# Pulse the rim
	var pulse: Tween = create_tween().set_loops()
	pulse.tween_property(rmat, "emission_energy_multiplier", 2.6, 1.6).set_ease(Tween.EASE_IN_OUT)
	pulse.tween_property(rmat, "emission_energy_multiplier", 1.0, 1.6).set_ease(Tween.EASE_IN_OUT)
	# 4 spike hazards around the rim (n/s/e/w)
	var spike_mat: StandardMaterial3D = StandardMaterial3D.new()
	spike_mat.albedo_color = Color(0.16, 0.18, 0.22)
	spike_mat.metallic = 0.85
	spike_mat.roughness = 0.30
	spike_mat.emission_enabled = true
	spike_mat.emission = Color(1.0, 0.40, 0.20)
	spike_mat.emission_energy_multiplier = 0.45
	for i in 4:
		var angle: float = (float(i) / 4.0) * TAU
		var spike: MeshInstance3D = MeshInstance3D.new()
		var smesh: PrismMesh = PrismMesh.new()
		smesh.size = Vector3(0.40, 1.40, 0.40)
		spike.mesh = smesh
		spike.position = Vector3(cos(angle) * 3.40, 0.70, sin(angle) * 3.40)
		spike.material_override = spike_mat
		pit.add_child(spike)
		# Collision on each spike
		var sp_sb: StaticBody3D = StaticBody3D.new()
		var sp_cs: CollisionShape3D = CollisionShape3D.new()
		var sp_cb: BoxShape3D = BoxShape3D.new()
		sp_cb.size = Vector3(0.40, 1.40, 0.40)
		sp_cs.shape = sp_cb
		sp_cs.position = Vector3(cos(angle) * 3.40, 0.70, sin(angle) * 3.40)
		sp_sb.add_child(sp_cs)
		pit.add_child(sp_sb)
	# 2 placeholder enemy spawn pads (small red glowing discs in the floor)
	for sx: float in [-0.85, 0.85]:
		var pad: MeshInstance3D = MeshInstance3D.new()
		var pmesh: CylinderMesh = CylinderMesh.new()
		pmesh.top_radius = 0.40
		pmesh.bottom_radius = 0.40
		pmesh.height = 0.06
		pad.mesh = pmesh
		pad.position = Vector3(sx, 0.13, 0)
		var pmat: StandardMaterial3D = StandardMaterial3D.new()
		pmat.albedo_color = Color(1.0, 0.20, 0.20)
		pmat.emission_enabled = true
		pmat.emission = Color(1.0, 0.40, 0.30)
		pmat.emission_energy_multiplier = 1.8
		pmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		pad.material_override = pmat
		pit.add_child(pad)
	# Floating "TRIAL PIT" label
	var label: Label3D = Label3D.new()
	label.text = "TRIAL PIT"
	label.position = Vector3(0, 2.2, 0)
	label.modulate = Color(1.0, 0.55, 0.20)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 6
	label.font_size = 22
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	pit.add_child(label)


func _build_d2_mercenary_tent(geom: Node) -> void:
	## Epic-2 T17: a mercenary camp tent with a weapon rack out front.
	## Brown fabric tent (slanted box) on 4 posts with a small rack of
	## 3 weapons (different colored emissive blades).
	var camp: Node3D = Node3D.new()
	camp.name = "D2MercenaryCamp"
	camp.position = D2_CENTER + Vector3(8, 0, -10)
	geom.add_child(camp)
	# 4 corner posts
	var post_mat: StandardMaterial3D = StandardMaterial3D.new()
	post_mat.albedo_color = Color(0.20, 0.16, 0.10)
	post_mat.metallic = 0.30
	for ox: float in [-1.4, 1.4]:
		for oz: float in [-1.0, 1.0]:
			var post: MeshInstance3D = MeshInstance3D.new()
			var pmesh: CylinderMesh = CylinderMesh.new()
			pmesh.top_radius = 0.06
			pmesh.bottom_radius = 0.08
			pmesh.height = 2.4
			post.mesh = pmesh
			post.position = Vector3(ox, 1.20, oz)
			post.material_override = post_mat
			camp.add_child(post)
	# Tent fabric — angled triangular box
	var fabric_mat: StandardMaterial3D = StandardMaterial3D.new()
	fabric_mat.albedo_color = Color(0.30, 0.20, 0.10)
	fabric_mat.emission_enabled = true
	fabric_mat.emission = Color(0.85, 0.55, 0.20)
	fabric_mat.emission_energy_multiplier = 0.30
	fabric_mat.metallic = 0.10
	fabric_mat.roughness = 0.65
	var roof: MeshInstance3D = MeshInstance3D.new()
	var rmesh: PrismMesh = PrismMesh.new()
	rmesh.size = Vector3(3.2, 1.0, 2.4)
	roof.mesh = rmesh
	roof.position = Vector3(0, 2.85, 0)
	roof.material_override = fabric_mat
	camp.add_child(roof)
	# Side fabric panels (back wall)
	var back: MeshInstance3D = MeshInstance3D.new()
	var bmesh: BoxMesh = BoxMesh.new()
	bmesh.size = Vector3(3.0, 2.4, 0.06)
	back.mesh = bmesh
	back.position = Vector3(0, 1.20, -1.0)
	back.material_override = fabric_mat
	camp.add_child(back)
	# Weapon rack — horizontal bar mounted in front
	var rack_root: Node3D = Node3D.new()
	rack_root.position = Vector3(0, 1.20, 1.20)
	camp.add_child(rack_root)
	var rack_bar: MeshInstance3D = MeshInstance3D.new()
	var rb_mesh: CylinderMesh = CylinderMesh.new()
	rb_mesh.top_radius = 0.05
	rb_mesh.bottom_radius = 0.05
	rb_mesh.height = 2.6
	rack_bar.mesh = rb_mesh
	rack_bar.rotation = Vector3(0, 0, deg_to_rad(90))
	rack_bar.material_override = post_mat
	rack_root.add_child(rack_bar)
	# 3 hanging weapons (vertical thin bars + colored blade tips)
	var weapon_specs: Array = [
		[-0.85, Color(0.55, 0.95, 1.0)],
		[0.0, Color(1.0, 0.40, 0.20)],
		[0.85, Color(0.85, 0.40, 1.0)],
	]
	for spec in weapon_specs:
		var hilt: MeshInstance3D = MeshInstance3D.new()
		var hmesh: CylinderMesh = CylinderMesh.new()
		hmesh.top_radius = 0.04
		hmesh.bottom_radius = 0.04
		hmesh.height = 0.45
		hilt.mesh = hmesh
		hilt.position = Vector3(spec[0], -0.30, 0)
		hilt.material_override = post_mat
		rack_root.add_child(hilt)
		# Blade
		var blade: MeshInstance3D = MeshInstance3D.new()
		var bldmesh: BoxMesh = BoxMesh.new()
		bldmesh.size = Vector3(0.05, 0.85, 0.04)
		blade.mesh = bldmesh
		blade.position = Vector3(spec[0], -0.95, 0)
		var blade_mat: StandardMaterial3D = StandardMaterial3D.new()
		var c: Color = spec[1]
		blade_mat.albedo_color = c
		blade_mat.emission_enabled = true
		blade_mat.emission = c
		blade_mat.emission_energy_multiplier = 1.8
		blade_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		blade.material_override = blade_mat
		rack_root.add_child(blade)
	# Tent label
	var label: Label3D = Label3D.new()
	label.text = "MERC CAMP"
	label.position = Vector3(0, 3.5, 0)
	label.modulate = Color(1.0, 0.65, 0.30)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 18
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	camp.add_child(label)
	# Collision around the tent
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(3.2, 2.4, 2.4)
	cs.shape = cb
	cs.position = Vector3(0, 1.20, 0)
	sb.add_child(cs)
	camp.add_child(sb)


func _build_d2_caution_stripes(geom: Node) -> void:
	## Epic-2 T18: 8 yellow caution stripes painted on the D2 ground in
	## front of the trial pit, marking the danger zone. Each is a thin
	## emissive box at a 45-degree angle.
	var center := D2_CENTER + Vector3(15, 0.06, 5)
	var stripe_mat: StandardMaterial3D = StandardMaterial3D.new()
	stripe_mat.albedo_color = Color(1.0, 0.85, 0.20)
	stripe_mat.emission_enabled = true
	stripe_mat.emission = Color(1.0, 0.95, 0.30)
	stripe_mat.emission_energy_multiplier = 1.6
	stripe_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for i in 8:
		var stripe: MeshInstance3D = MeshInstance3D.new()
		stripe.name = "D2CautionStripe_%d" % i
		var smesh: BoxMesh = BoxMesh.new()
		smesh.size = Vector3(0.85, 0.05, 0.20)
		stripe.mesh = smesh
		stripe.position = center + Vector3(-2.8 + i * 0.80, 0, 0)
		stripe.rotation = Vector3(0, deg_to_rad(45), 0)
		stripe.material_override = stripe_mat
		geom.add_child(stripe)


func _build_d2_black_market_npc() -> void:
	## Epic-2 T19: Black market merchant NPC standing inside the merc tent.
	## Hooded figure with a glowing red eye and a gold coin pouch belt.
	var slots: Node3D = get_node_or_null("%NPCSlots") as Node3D
	if slots == null:
		return
	var bm: Node3D = Node3D.new()
	bm.name = "D2BlackMarketMerchant"
	bm.position = D2_CENTER + Vector3(8, 0, -10.5)
	slots.add_child(bm)
	# Body capsule — dark cloak
	var body: MeshInstance3D = MeshInstance3D.new()
	var bmesh: CapsuleMesh = CapsuleMesh.new()
	bmesh.radius = 0.42
	bmesh.height = 1.20
	body.mesh = bmesh
	body.position = Vector3(0, 0.65, 0)
	var bmat: StandardMaterial3D = StandardMaterial3D.new()
	bmat.albedo_color = Color(0.10, 0.10, 0.14)
	bmat.metallic = 0.30
	bmat.roughness = 0.65
	body.material_override = bmat
	bm.add_child(body)
	# Hood (wider sphere)
	var hood: MeshInstance3D = MeshInstance3D.new()
	var hmesh: SphereMesh = SphereMesh.new()
	hmesh.radius = 0.45
	hmesh.height = 0.55
	hood.mesh = hmesh
	hood.position = Vector3(0, 1.45, 0)
	var hmat: StandardMaterial3D = StandardMaterial3D.new()
	hmat.albedo_color = Color(0.06, 0.06, 0.10)
	hmat.metallic = 0.30
	hmat.roughness = 0.65
	hood.material_override = hmat
	bm.add_child(hood)
	# Single red glowing eye (cyclops style)
	var eye: MeshInstance3D = MeshInstance3D.new()
	var emesh: SphereMesh = SphereMesh.new()
	emesh.radius = 0.10
	emesh.height = 0.20
	eye.mesh = emesh
	eye.position = Vector3(0, 1.32, 0.34)
	var emat: StandardMaterial3D = StandardMaterial3D.new()
	emat.albedo_color = Color(1.0, 0.20, 0.20)
	emat.emission_enabled = true
	emat.emission = Color(1.0, 0.30, 0.30)
	emat.emission_energy_multiplier = 3.0
	emat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	eye.material_override = emat
	bm.add_child(eye)
	# Gold coin pouch belt
	var pouch_mat: StandardMaterial3D = StandardMaterial3D.new()
	pouch_mat.albedo_color = Color(0.85, 0.65, 0.20)
	pouch_mat.emission_enabled = true
	pouch_mat.emission = Color(1.0, 0.75, 0.25)
	pouch_mat.emission_energy_multiplier = 1.0
	pouch_mat.metallic = 0.85
	for i in 3:
		var coin: MeshInstance3D = MeshInstance3D.new()
		var cmesh: SphereMesh = SphereMesh.new()
		cmesh.radius = 0.08
		cmesh.height = 0.16
		coin.mesh = cmesh
		coin.position = Vector3(-0.20 + i * 0.20, 0.55, 0.30)
		coin.material_override = pouch_mat
		bm.add_child(coin)
	# Pulse the eye
	var pulse: Tween = create_tween().set_loops()
	pulse.tween_property(emat, "emission_energy_multiplier", 4.0, 1.0).set_ease(Tween.EASE_IN_OUT)
	pulse.tween_property(emat, "emission_energy_multiplier", 2.0, 1.0).set_ease(Tween.EASE_IN_OUT)
	# Name billboard
	var label: Label3D = Label3D.new()
	label.text = "Black Market"
	label.position = Vector3(0, 1.95, 0)
	label.modulate = Color(1.0, 0.30, 0.30)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 18
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	bm.add_child(label)


func _build_d2_watchtower(geom: Node) -> void:
	## Epic-2 T20: a tall watchtower with a hovering top platform and a
	## sweeping searchlight (real SpotLight3D rotating on a tween). Sells
	## "this place is being watched" without spawning hostile guards.
	var tower: Node3D = Node3D.new()
	tower.name = "D2Watchtower"
	tower.position = D2_CENTER + Vector3(20, 0, -16)
	geom.add_child(tower)
	# Tall narrow column
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.16, 0.14, 0.12)
	stone_mat.metallic = 0.45
	stone_mat.roughness = 0.55
	var column: MeshInstance3D = MeshInstance3D.new()
	var cmesh: CylinderMesh = CylinderMesh.new()
	cmesh.top_radius = 0.30
	cmesh.bottom_radius = 0.40
	cmesh.height = 8.0
	column.mesh = cmesh
	column.position = Vector3(0, 4.0, 0)
	column.material_override = stone_mat
	tower.add_child(column)
	# Top platform — wider disc
	var platform: MeshInstance3D = MeshInstance3D.new()
	var pmesh: CylinderMesh = CylinderMesh.new()
	pmesh.top_radius = 1.20
	pmesh.bottom_radius = 1.0
	pmesh.height = 0.40
	platform.mesh = pmesh
	platform.position = Vector3(0, 8.20, 0)
	platform.material_override = stone_mat
	tower.add_child(platform)
	# Cabin on top — small box
	var cabin: MeshInstance3D = MeshInstance3D.new()
	var cab_mesh: BoxMesh = BoxMesh.new()
	cab_mesh.size = Vector3(1.40, 1.0, 1.40)
	cabin.mesh = cab_mesh
	cabin.position = Vector3(0, 8.95, 0)
	cabin.material_override = stone_mat
	tower.add_child(cabin)
	# Cyan window slits on the cabin
	var window_mat: StandardMaterial3D = StandardMaterial3D.new()
	window_mat.albedo_color = Color(0.30, 0.85, 1.0)
	window_mat.emission_enabled = true
	window_mat.emission = Color(0.55, 0.95, 1.0)
	window_mat.emission_energy_multiplier = 1.6
	window_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for sx: float in [-0.71, 0.71]:
		var win: MeshInstance3D = MeshInstance3D.new()
		var wmesh: BoxMesh = BoxMesh.new()
		wmesh.size = Vector3(0.04, 0.30, 0.85)
		win.mesh = wmesh
		win.position = Vector3(sx, 8.95, 0)
		win.material_override = window_mat
		tower.add_child(win)
	# Sweeping searchlight pivot mounted on top of cabin
	var spot_pivot: Node3D = Node3D.new()
	spot_pivot.position = Vector3(0, 9.65, 0)
	tower.add_child(spot_pivot)
	# Searchlight body
	var spot_body: MeshInstance3D = MeshInstance3D.new()
	var sb_mesh: CylinderMesh = CylinderMesh.new()
	sb_mesh.top_radius = 0.20
	sb_mesh.bottom_radius = 0.30
	sb_mesh.height = 0.45
	spot_body.mesh = sb_mesh
	spot_body.position = Vector3(0, 0, 0.30)
	spot_body.rotation = Vector3(deg_to_rad(70), 0, 0)
	spot_body.material_override = stone_mat
	spot_pivot.add_child(spot_body)
	# Real spotlight + visible cone beam pointed downward+forward
	var spot: SpotLight3D = SpotLight3D.new()
	spot.position = Vector3(0, -0.10, 0.40)
	spot.rotation = Vector3(deg_to_rad(-70), 0, 0)
	spot.light_color = Color(1.0, 0.95, 0.65)
	spot.light_energy = 4.0
	spot.spot_range = 18.0
	spot.spot_angle = 26.0
	spot.spot_attenuation = 1.4
	spot_pivot.add_child(spot)
	# Visible cone
	var beam: MeshInstance3D = MeshInstance3D.new()
	var beam_mesh: CylinderMesh = CylinderMesh.new()
	beam_mesh.top_radius = 0.20
	beam_mesh.bottom_radius = 3.40
	beam_mesh.height = 9.0
	beam.mesh = beam_mesh
	beam.position = Vector3(0, -4.0, 1.6)
	beam.rotation = Vector3(deg_to_rad(20), 0, 0)
	var bm_mat: StandardMaterial3D = StandardMaterial3D.new()
	bm_mat.albedo_color = Color(1.0, 0.95, 0.65, 0.10)
	bm_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	bm_mat.emission_enabled = true
	bm_mat.emission = Color(1.0, 0.95, 0.65)
	bm_mat.emission_energy_multiplier = 0.45
	bm_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	beam.material_override = bm_mat
	spot_pivot.add_child(beam)
	# Sweeping rotation tween
	var sweep: Tween = create_tween().set_loops()
	sweep.tween_property(spot_pivot, "rotation:y", deg_to_rad(60), 4.0).set_ease(Tween.EASE_IN_OUT)
	sweep.tween_property(spot_pivot, "rotation:y", deg_to_rad(-60), 4.0).set_ease(Tween.EASE_IN_OUT)
	# Collision around column
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cap: CapsuleShape3D = CapsuleShape3D.new()
	cap.radius = 0.45
	cap.height = 8.0
	cs.shape = cap
	cs.position = Vector3(0, 4.0, 0)
	sb.add_child(cs)
	tower.add_child(sb)


func _build_d2_data_conduits(geom: Node) -> void:
	## Epic-2 T21: 3 large suspended data conduit pipes running east-west
	## across the district at varying heights. Each is a long thick cylinder
	## with cyan emissive bands at intervals + a slow energy pulse traveling
	## along its length (mocked by moving a bright sphere along the pipe).
	var pipe_specs: Array = [
		[Vector3(70, 4.5, -16), Vector3(115, 4.5, -16), Color(0.55, 0.95, 1.0)],
		[Vector3(70, 5.5, 0), Vector3(115, 5.5, 0), Color(1.0, 0.55, 0.20)],
		[Vector3(70, 4.5, 16), Vector3(115, 4.5, 16), Color(0.85, 0.40, 1.0)],
	]
	var pipe_metal_mat: StandardMaterial3D = StandardMaterial3D.new()
	pipe_metal_mat.albedo_color = Color(0.20, 0.22, 0.28)
	pipe_metal_mat.metallic = 0.85
	pipe_metal_mat.roughness = 0.30
	for i in pipe_specs.size():
		var spec: Array = pipe_specs[i]
		var from: Vector3 = spec[0]
		var to: Vector3 = spec[1]
		var color: Color = spec[2]
		var dist: float = from.distance_to(to)
		var mid: Vector3 = (from + to) * 0.5
		var pipe: MeshInstance3D = MeshInstance3D.new()
		pipe.name = "D2DataConduit_%d" % i
		var pmesh: CylinderMesh = CylinderMesh.new()
		pmesh.top_radius = 0.30
		pmesh.bottom_radius = 0.30
		pmesh.height = dist
		pipe.mesh = pmesh
		pipe.position = mid
		pipe.rotation = Vector3(0, 0, deg_to_rad(90))
		pipe.material_override = pipe_metal_mat
		geom.add_child(pipe)
		# Emissive band rings every 5m along the pipe
		var num_bands: int = int(dist / 5.0)
		for b in num_bands:
			var t: float = float(b + 1) / float(num_bands + 1)
			var band_pos: Vector3 = from.lerp(to, t)
			var band: MeshInstance3D = MeshInstance3D.new()
			var bmesh: TorusMesh = TorusMesh.new()
			bmesh.inner_radius = 0.32
			bmesh.outer_radius = 0.40
			band.mesh = bmesh
			band.position = band_pos
			band.rotation = Vector3(0, 0, deg_to_rad(90))
			var bmat: StandardMaterial3D = StandardMaterial3D.new()
			bmat.albedo_color = color
			bmat.emission_enabled = true
			bmat.emission = color
			bmat.emission_energy_multiplier = 1.6
			bmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
			band.material_override = bmat
			geom.add_child(band)
		# Pulse sphere traveling along the pipe
		var pulse_ball: MeshInstance3D = MeshInstance3D.new()
		var pmesh_b: SphereMesh = SphereMesh.new()
		pmesh_b.radius = 0.22
		pmesh_b.height = 0.44
		pulse_ball.mesh = pmesh_b
		pulse_ball.position = from
		var pball_mat: StandardMaterial3D = StandardMaterial3D.new()
		pball_mat.albedo_color = color
		pball_mat.emission_enabled = true
		pball_mat.emission = color
		pball_mat.emission_energy_multiplier = 3.0
		pball_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		pulse_ball.material_override = pball_mat
		geom.add_child(pulse_ball)
		var travel: Tween = create_tween().set_loops()
		travel.tween_property(pulse_ball, "position", to, 4.0 + i * 0.5).set_ease(Tween.EASE_IN_OUT)
		travel.tween_property(pulse_ball, "position", from, 0.05)


func _build_d2_server_farm(geom: Node) -> void:
	## Epic-2 T22: a tall multi-rack server farm tower in D2. 3 stacked
	## rack units with rows of small green/red LED lights, vent fins on
	## the sides, and a roof antenna. Hints "this district hosts compute".
	var farm: Node3D = Node3D.new()
	farm.name = "D2ServerFarm"
	farm.position = D2_CENTER + Vector3(-15, 0, 14)
	geom.add_child(farm)
	# Base
	var dark_mat: StandardMaterial3D = StandardMaterial3D.new()
	dark_mat.albedo_color = Color(0.10, 0.13, 0.16)
	dark_mat.metallic = 0.85
	dark_mat.roughness = 0.30
	var base: MeshInstance3D = MeshInstance3D.new()
	var base_mesh: BoxMesh = BoxMesh.new()
	base_mesh.size = Vector3(2.4, 0.30, 2.0)
	base.mesh = base_mesh
	base.position = Vector3(0, 0.15, 0)
	base.material_override = dark_mat
	farm.add_child(base)
	# 3 stacked rack units
	for r in 3:
		var rack: MeshInstance3D = MeshInstance3D.new()
		var rmesh: BoxMesh = BoxMesh.new()
		rmesh.size = Vector3(2.0, 1.6, 1.6)
		rack.mesh = rmesh
		rack.position = Vector3(0, 1.15 + r * 1.85, 0)
		rack.material_override = dark_mat
		farm.add_child(rack)
		# Rows of LEDs across the front face
		for row in 4:
			for col in 5:
				var led: MeshInstance3D = MeshInstance3D.new()
				var lmesh: SphereMesh = SphereMesh.new()
				lmesh.radius = 0.05
				lmesh.height = 0.10
				led.mesh = lmesh
				led.position = Vector3(-0.85 + col * 0.40, 1.50 + r * 1.85 + row * 0.30, 0.81)
				var lmat: StandardMaterial3D = StandardMaterial3D.new()
				var c: Color = Color(0.30, 1.0, 0.40) if (row + col) % 2 == 0 else Color(1.0, 0.40, 0.30)
				lmat.albedo_color = c
				lmat.emission_enabled = true
				lmat.emission = c
				lmat.emission_energy_multiplier = 2.0
				lmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
				led.material_override = lmat
				farm.add_child(led)
				# Random blink (some lights flicker)
				if (row * 5 + col) % 3 == 0:
					var blink: Tween = create_tween().set_loops()
					blink.tween_interval(0.5 + randf() * 1.0)
					blink.tween_property(led, "visible", false, 0.0)
					blink.tween_interval(0.10)
					blink.tween_property(led, "visible", true, 0.0)
		# Vent fins on each side of the rack
		for sx: float in [-1.05, 1.05]:
			for fy in 4:
				var fin: MeshInstance3D = MeshInstance3D.new()
				var fmesh: BoxMesh = BoxMesh.new()
				fmesh.size = Vector3(0.05, 0.06, 1.5)
				fin.mesh = fmesh
				fin.position = Vector3(sx, 1.20 + r * 1.85 + fy * 0.36, 0)
				fin.material_override = dark_mat
				farm.add_child(fin)
	# Roof antenna
	var antenna: MeshInstance3D = MeshInstance3D.new()
	var amesh: CylinderMesh = CylinderMesh.new()
	amesh.top_radius = 0.04
	amesh.bottom_radius = 0.10
	amesh.height = 1.6
	antenna.mesh = amesh
	antenna.position = Vector3(0, 7.50, 0)
	antenna.material_override = dark_mat
	farm.add_child(antenna)
	# Antenna blink tip
	var tip: MeshInstance3D = MeshInstance3D.new()
	var tip_mesh: SphereMesh = SphereMesh.new()
	tip_mesh.radius = 0.10
	tip_mesh.height = 0.20
	tip.mesh = tip_mesh
	tip.position = Vector3(0, 8.30, 0)
	var tmat: StandardMaterial3D = StandardMaterial3D.new()
	tmat.albedo_color = Color(1.0, 0.30, 0.30)
	tmat.emission_enabled = true
	tmat.emission = Color(1.0, 0.40, 0.40)
	tmat.emission_energy_multiplier = 2.5
	tmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	tip.material_override = tmat
	farm.add_child(tip)
	var blink: Tween = create_tween().set_loops()
	blink.tween_property(tip, "scale", Vector3(0.4, 0.4, 0.4), 0.6).set_ease(Tween.EASE_IN_OUT)
	blink.tween_property(tip, "scale", Vector3(1.4, 1.4, 1.4), 0.6).set_ease(Tween.EASE_IN_OUT)
	# Label
	var label: Label3D = Label3D.new()
	label.text = "SERVER FARM"
	label.position = Vector3(0, 9.0, 0)
	label.modulate = Color(0.40, 1.0, 0.50)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 18
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	farm.add_child(label)
	# Collision around the whole stack
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(2.4, 7.0, 2.0)
	cs.shape = cb
	cs.position = Vector3(0, 3.50, 0)
	sb.add_child(cs)
	farm.add_child(sb)


func _build_d2_cracked_billboard(geom: Node) -> void:
	## Epic-2 T23: a tall cracked highway billboard mounted on 2 thick
	## posts. Old advert face is faded with diagonal cracks. Reads "RUN
	## FASTER / BETA TEST 0.99" with vertical text glitching.
	var bb: Node3D = Node3D.new()
	bb.name = "D2CrackedBillboard"
	bb.position = D2_CENTER + Vector3(-12, 0, -6)
	bb.rotation = Vector3(0, deg_to_rad(20), 0)
	geom.add_child(bb)
	# 2 support posts
	var post_mat: StandardMaterial3D = StandardMaterial3D.new()
	post_mat.albedo_color = Color(0.10, 0.13, 0.16)
	post_mat.metallic = 0.85
	post_mat.roughness = 0.30
	for sx: float in [-1.6, 1.6]:
		var post: MeshInstance3D = MeshInstance3D.new()
		var pmesh: CylinderMesh = CylinderMesh.new()
		pmesh.top_radius = 0.10
		pmesh.bottom_radius = 0.14
		pmesh.height = 4.5
		post.mesh = pmesh
		post.position = Vector3(sx, 2.25, 0)
		post.material_override = post_mat
		bb.add_child(post)
		# Collision
		var sb: StaticBody3D = StaticBody3D.new()
		var cs: CollisionShape3D = CollisionShape3D.new()
		var cap: CapsuleShape3D = CapsuleShape3D.new()
		cap.radius = 0.20
		cap.height = 4.5
		cs.shape = cap
		cs.position = Vector3(sx, 2.25, 0)
		sb.add_child(cs)
		bb.add_child(sb)
	# Billboard backing — wide rectangle
	var back_mat: StandardMaterial3D = StandardMaterial3D.new()
	back_mat.albedo_color = Color(0.95, 0.85, 0.55)
	back_mat.emission_enabled = true
	back_mat.emission = Color(1.0, 0.85, 0.55)
	back_mat.emission_energy_multiplier = 0.40
	back_mat.metallic = 0.10
	back_mat.roughness = 0.65
	var board: MeshInstance3D = MeshInstance3D.new()
	var bmesh: BoxMesh = BoxMesh.new()
	bmesh.size = Vector3(4.5, 2.4, 0.10)
	board.mesh = bmesh
	board.position = Vector3(0, 4.50, 0)
	board.material_override = back_mat
	bb.add_child(board)
	# Diagonal crack lines on the board
	var crack_mat: StandardMaterial3D = StandardMaterial3D.new()
	crack_mat.albedo_color = Color(0.10, 0.10, 0.10)
	crack_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for c in 3:
		var crack: MeshInstance3D = MeshInstance3D.new()
		var cmesh: BoxMesh = BoxMesh.new()
		cmesh.size = Vector3(3.5, 0.05, 0.02)
		crack.mesh = cmesh
		crack.position = Vector3(0, 4.50 + c * 0.30 - 0.40, 0.06)
		crack.rotation = Vector3(0, 0, deg_to_rad(-22 + c * 20))
		crack.material_override = crack_mat
		bb.add_child(crack)
	# Big text on the board
	var label1: Label3D = Label3D.new()
	label1.text = "RUN FASTER"
	label1.position = Vector3(0, 5.05, 0.07)
	label1.modulate = Color(0.95, 0.30, 0.20)
	label1.outline_modulate = Color(0, 0, 0, 0.85)
	label1.outline_size = 6
	label1.font_size = 32
	label1.no_depth_test = true
	bb.add_child(label1)
	var label2: Label3D = Label3D.new()
	label2.text = "BETA TEST 0.99"
	label2.position = Vector3(0, 4.10, 0.07)
	label2.modulate = Color(0.20, 0.20, 0.30)
	label2.outline_modulate = Color(0, 0, 0, 0.85)
	label2.outline_size = 4
	label2.font_size = 18
	label2.no_depth_test = true
	bb.add_child(label2)
	# Glitch flicker on the title
	var flicker: Tween = create_tween().set_loops()
	flicker.tween_interval(2.0)
	flicker.tween_property(label1, "visible", false, 0.0)
	flicker.tween_interval(0.10)
	flicker.tween_property(label1, "visible", true, 0.0)
	flicker.tween_interval(0.05)
	flicker.tween_property(label1, "visible", false, 0.0)
	flicker.tween_interval(0.08)
	flicker.tween_property(label1, "visible", true, 0.0)


func _build_d2_shipping_containers(geom: Node) -> void:
	## Epic-2 T24: 5 stacked shipping containers cluttering an area. Each
	## is a long box at varying colors with stenciled IDs and rusty trim.
	var stack: Node3D = Node3D.new()
	stack.name = "D2ShippingContainers"
	stack.position = D2_CENTER + Vector3(22, 0, 14)
	geom.add_child(stack)
	var container_specs: Array = [
		[Vector3(0, 0.70, 0), Vector3(0, 0, 0), Color(0.20, 0.40, 0.55)],
		[Vector3(0, 2.10, 0), Vector3(0, deg_to_rad(15), 0), Color(0.55, 0.30, 0.20)],
		[Vector3(2.5, 0.70, 0.5), Vector3(0, deg_to_rad(-25), 0), Color(0.30, 0.45, 0.25)],
		[Vector3(-2.0, 0.70, 0.8), Vector3(0, deg_to_rad(8), 0), Color(0.55, 0.45, 0.20)],
		[Vector3(2.5, 2.10, 0.5), Vector3(0, deg_to_rad(-15), deg_to_rad(8)), Color(0.40, 0.35, 0.40)],
	]
	for i in container_specs.size():
		var spec: Array = container_specs[i]
		var color: Color = spec[2]
		var container: MeshInstance3D = MeshInstance3D.new()
		container.name = "Container_%d" % i
		var cmesh: BoxMesh = BoxMesh.new()
		cmesh.size = Vector3(2.6, 1.40, 1.20)
		container.mesh = cmesh
		container.position = spec[0]
		container.rotation = spec[1]
		var cmat: StandardMaterial3D = StandardMaterial3D.new()
		cmat.albedo_color = color
		cmat.metallic = 0.55
		cmat.roughness = 0.65
		container.material_override = cmat
		stack.add_child(container)
		# Stencil ID label on side
		var id_label: Label3D = Label3D.new()
		id_label.text = "C-%03d" % (i * 47 + 12)
		id_label.position = spec[0] + Vector3(0, 0.20, 0.66)
		id_label.rotation = spec[1]
		id_label.modulate = Color(0.95, 0.95, 0.95, 0.85)
		id_label.outline_modulate = Color(0, 0, 0, 0.55)
		id_label.outline_size = 3
		id_label.font_size = 18
		id_label.no_depth_test = true
		stack.add_child(id_label)
		# Collision per container
		var sb: StaticBody3D = StaticBody3D.new()
		var cs: CollisionShape3D = CollisionShape3D.new()
		var cb: BoxShape3D = BoxShape3D.new()
		cb.size = Vector3(2.6, 1.40, 1.20)
		cs.shape = cb
		cs.position = spec[0]
		sb.add_child(cs)
		stack.add_child(sb)


func _build_d2_glitch_beast(geom: Node) -> void:
	## Epic-2 T25: a large wandering "glitch beast" — bigger than the
	## glitch enemies, the visual mini-boss of D2. 4-legged hulking body
	## with 6 magenta eyes and a glowing back spike row. Slow patrol.
	var beast: Node3D = Node3D.new()
	beast.name = "D2GlitchBeast"
	beast.position = D2_CENTER + Vector3(15, 0, 14)
	geom.add_child(beast)
	# Body — chunky box
	var body_mat: StandardMaterial3D = StandardMaterial3D.new()
	body_mat.albedo_color = Color(0.30, 0.10, 0.18)
	body_mat.emission_enabled = true
	body_mat.emission = Color(1.0, 0.20, 0.40)
	body_mat.emission_energy_multiplier = 0.55
	body_mat.metallic = 0.40
	body_mat.roughness = 0.55
	var body: MeshInstance3D = MeshInstance3D.new()
	var bmesh: BoxMesh = BoxMesh.new()
	bmesh.size = Vector3(2.0, 1.20, 1.40)
	body.mesh = bmesh
	body.position = Vector3(0, 1.30, 0)
	body.material_override = body_mat
	beast.add_child(body)
	# Head — smaller box jutting forward
	var head: MeshInstance3D = MeshInstance3D.new()
	var hmesh: BoxMesh = BoxMesh.new()
	hmesh.size = Vector3(1.0, 0.85, 1.0)
	head.mesh = hmesh
	head.position = Vector3(1.30, 1.20, 0)
	head.material_override = body_mat
	beast.add_child(head)
	# 6 magenta eyes (3x2 grid on the head front)
	var eye_mat: StandardMaterial3D = StandardMaterial3D.new()
	eye_mat.albedo_color = Color(1.0, 0.30, 0.55)
	eye_mat.emission_enabled = true
	eye_mat.emission = Color(1.0, 0.40, 0.65)
	eye_mat.emission_energy_multiplier = 2.6
	eye_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for col in 3:
		for row in 2:
			var eye: MeshInstance3D = MeshInstance3D.new()
			var emesh: SphereMesh = SphereMesh.new()
			emesh.radius = 0.10
			emesh.height = 0.20
			eye.mesh = emesh
			eye.position = Vector3(1.85, 1.05 + row * 0.30, -0.30 + col * 0.30)
			eye.material_override = eye_mat
			beast.add_child(eye)
	# Glowing back spike row — 5 prisms along the body top
	var spike_mat: StandardMaterial3D = StandardMaterial3D.new()
	spike_mat.albedo_color = Color(1.0, 0.20, 0.40)
	spike_mat.emission_enabled = true
	spike_mat.emission = Color(1.0, 0.30, 0.55)
	spike_mat.emission_energy_multiplier = 2.2
	spike_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for s in 5:
		var spike: MeshInstance3D = MeshInstance3D.new()
		var smesh: PrismMesh = PrismMesh.new()
		smesh.size = Vector3(0.20, 0.65, 0.20)
		spike.mesh = smesh
		spike.position = Vector3(0.80 - s * 0.40, 2.20, 0)
		spike.material_override = spike_mat
		beast.add_child(spike)
	# 4 chunky legs
	var leg_mat: StandardMaterial3D = StandardMaterial3D.new()
	leg_mat.albedo_color = Color(0.16, 0.06, 0.10)
	leg_mat.metallic = 0.30
	leg_mat.roughness = 0.55
	var leg_offsets: Array[Vector3] = [
		Vector3(-0.85, 0.40, -0.55),
		Vector3(0.85, 0.40, -0.55),
		Vector3(-0.85, 0.40, 0.55),
		Vector3(0.85, 0.40, 0.55),
	]
	for off in leg_offsets:
		var leg: MeshInstance3D = MeshInstance3D.new()
		var lmesh: BoxMesh = BoxMesh.new()
		lmesh.size = Vector3(0.30, 0.85, 0.30)
		leg.mesh = lmesh
		leg.position = off
		leg.material_override = leg_mat
		beast.add_child(leg)
	# Slow patrol path
	var origin: Vector3 = D2_CENTER + Vector3(15, 0, 14)
	var patrol: Tween = create_tween().set_loops()
	patrol.tween_property(beast, "rotation:y", 0.0, 0.4)
	patrol.tween_property(beast, "position", origin + Vector3(8, 0, 0), 8.0)
	patrol.tween_property(beast, "rotation:y", deg_to_rad(180), 0.6)
	patrol.tween_property(beast, "position", origin, 8.0)
	# Pulse the back spikes
	var spike_pulse: Tween = create_tween().set_loops()
	spike_pulse.tween_property(spike_mat, "emission_energy_multiplier", 3.4, 0.85).set_ease(Tween.EASE_IN_OUT)
	spike_pulse.tween_property(spike_mat, "emission_energy_multiplier", 1.4, 0.85).set_ease(Tween.EASE_IN_OUT)
	# Boss-like name billboard
	var label: Label3D = Label3D.new()
	label.text = "GLITCH BEAST"
	label.position = Vector3(0, 3.20, 0)
	label.modulate = Color(1.0, 0.30, 0.55)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 6
	label.font_size = 22
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	beast.add_child(label)


func _build_d2_repair_workshop(geom: Node) -> void:
	## Epic-2 T26: open-air repair workshop — anvil + workbench + active
	## welding spark emitter. Sells "stuff gets fixed here, not bought".
	var shop: Node3D = Node3D.new()
	shop.name = "D2RepairWorkshop"
	shop.position = D2_CENTER + Vector3(-18, 0, 4)
	geom.add_child(shop)
	# Workbench
	var bench_mat: StandardMaterial3D = StandardMaterial3D.new()
	bench_mat.albedo_color = Color(0.20, 0.16, 0.10)
	bench_mat.metallic = 0.30
	bench_mat.roughness = 0.65
	var bench: MeshInstance3D = MeshInstance3D.new()
	var bm: BoxMesh = BoxMesh.new()
	bm.size = Vector3(2.4, 0.95, 1.0)
	bench.mesh = bm
	bench.position = Vector3(0, 0.47, 0)
	bench.material_override = bench_mat
	shop.add_child(bench)
	# Anvil — small block on top of bench
	var anvil_mat: StandardMaterial3D = StandardMaterial3D.new()
	anvil_mat.albedo_color = Color(0.10, 0.10, 0.13)
	anvil_mat.metallic = 0.85
	anvil_mat.roughness = 0.30
	var anvil: MeshInstance3D = MeshInstance3D.new()
	var am: BoxMesh = BoxMesh.new()
	am.size = Vector3(0.65, 0.30, 0.40)
	anvil.mesh = am
	anvil.position = Vector3(0.5, 1.10, 0)
	anvil.material_override = anvil_mat
	shop.add_child(anvil)
	# Half-finished blade lying on the anvil — heated orange tip
	var blade: MeshInstance3D = MeshInstance3D.new()
	var blade_mesh: BoxMesh = BoxMesh.new()
	blade_mesh.size = Vector3(0.85, 0.04, 0.10)
	blade.mesh = blade_mesh
	blade.position = Vector3(0.5, 1.30, 0)
	var blade_mat: StandardMaterial3D = StandardMaterial3D.new()
	blade_mat.albedo_color = Color(0.85, 0.40, 0.20)
	blade_mat.emission_enabled = true
	blade_mat.emission = Color(1.0, 0.55, 0.20)
	blade_mat.emission_energy_multiplier = 1.6
	blade_mat.metallic = 0.65
	blade_mat.roughness = 0.30
	blade.material_override = blade_mat
	shop.add_child(blade)
	# Active welding spark emitter at the bench
	var sparks: GPUParticles3D = GPUParticles3D.new()
	sparks.amount = 40
	sparks.lifetime = 0.65
	sparks.position = Vector3(0.5, 1.32, 0)
	var pmat: ParticleProcessMaterial = ParticleProcessMaterial.new()
	pmat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	pmat.emission_sphere_radius = 0.10
	pmat.direction = Vector3(0, 1, 0)
	pmat.spread = 60.0
	pmat.initial_velocity_min = 1.4
	pmat.initial_velocity_max = 2.4
	pmat.gravity = Vector3(0, -3.0, 0)
	pmat.scale_min = 0.04
	pmat.scale_max = 0.08
	pmat.color = Color(1.0, 0.85, 0.30, 1.0)
	sparks.process_material = pmat
	var sm: SphereMesh = SphereMesh.new()
	sm.radius = 0.04
	sm.height = 0.08
	var sm_mat: StandardMaterial3D = StandardMaterial3D.new()
	sm_mat.albedo_color = Color(1.0, 0.85, 0.30)
	sm_mat.emission_enabled = true
	sm_mat.emission = Color(1.0, 0.95, 0.40)
	sm_mat.emission_energy_multiplier = 2.6
	sm_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	sm.material = sm_mat
	sparks.draw_pass_1 = sm
	shop.add_child(sparks)
	# Tool wall behind the bench — 4 hanging tools
	var wall: MeshInstance3D = MeshInstance3D.new()
	var wmesh: BoxMesh = BoxMesh.new()
	wmesh.size = Vector3(2.6, 1.85, 0.08)
	wall.mesh = wmesh
	wall.position = Vector3(0, 1.85, -0.55)
	wall.material_override = anvil_mat
	shop.add_child(wall)
	for i in 4:
		var tool: MeshInstance3D = MeshInstance3D.new()
		var tm: BoxMesh = BoxMesh.new()
		tm.size = Vector3(0.10, 0.55, 0.05)
		tool.mesh = tm
		tool.position = Vector3(-0.95 + i * 0.65, 1.85, -0.50)
		var tmat: StandardMaterial3D = StandardMaterial3D.new()
		tmat.albedo_color = Color(0.30, 0.30, 0.35)
		tmat.metallic = 0.85
		tool.material_override = tmat
		shop.add_child(tool)
	# Sign
	var label: Label3D = Label3D.new()
	label.text = "REPAIRS"
	label.position = Vector3(0, 3.0, 0)
	label.modulate = Color(1.0, 0.65, 0.30)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 18
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	shop.add_child(label)
	# Collision around the bench
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(2.4, 1.4, 1.4)
	cs.shape = cb
	cs.position = Vector3(0, 0.7, 0)
	sb.add_child(cs)
	shop.add_child(sb)


func _build_d2_holo_graffiti(geom: Node) -> void:
	## Epic-2 T27: 4 holographic graffiti tags floating on D2 walls. Each
	## is a brightly colored emissive label with intentional misalignment
	## like spray paint, mounted on the boundary wall area.
	var tags: Array = [
		[D2_CENTER + Vector3(-18, 1.8, -16), "404", Color(1.0, 0.30, 0.55)],
		[D2_CENTER + Vector3(-12, 2.5, -16), "GLITCH", Color(0.55, 0.95, 1.0)],
		[D2_CENTER + Vector3(8, 2.0, -16), "FREE BIT", Color(1.0, 0.95, 0.30)],
		[D2_CENTER + Vector3(20, 1.8, -16), "RUN", Color(0.40, 1.0, 0.55)],
	]
	for spec in tags:
		var pos: Vector3 = spec[0]
		var text: String = spec[1]
		var color: Color = spec[2]
		var tag: Label3D = Label3D.new()
		tag.text = text
		tag.position = pos
		tag.modulate = color
		tag.outline_modulate = Color(0, 0, 0, 0.85)
		tag.outline_size = 5
		tag.font_size = 32
		tag.no_depth_test = true
		tag.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		geom.add_child(tag)


func _build_d2_drone_wreckage(geom: Node) -> void:
	## Epic-2 T28: a debris field of 6 broken drone parts scattered on the
	## ground — propellers, fuselage halves, smoking pieces. Tells a story
	## of "couriers tried to fly through here and got knocked down".
	var field: Node3D = Node3D.new()
	field.name = "D2DroneWreckage"
	field.position = D2_CENTER + Vector3(2, 0, 14)
	geom.add_child(field)
	var dark_mat: StandardMaterial3D = StandardMaterial3D.new()
	dark_mat.albedo_color = Color(0.10, 0.13, 0.16)
	dark_mat.metallic = 0.85
	dark_mat.roughness = 0.40
	# 2 broken propeller discs
	for i in 2:
		var prop: MeshInstance3D = MeshInstance3D.new()
		var pmesh: CylinderMesh = CylinderMesh.new()
		pmesh.top_radius = 0.30
		pmesh.bottom_radius = 0.30
		pmesh.height = 0.04
		prop.mesh = pmesh
		prop.position = Vector3(-1.5 + i * 3.0, 0.05, randf_range(-0.5, 0.5))
		prop.rotation = Vector3(deg_to_rad(randf_range(-30, 30)), randf() * TAU, deg_to_rad(randf_range(-30, 30)))
		prop.material_override = dark_mat
		field.add_child(prop)
	# 3 fuselage chunks (small boxes)
	for i in 3:
		var chunk: MeshInstance3D = MeshInstance3D.new()
		var cmesh: BoxMesh = BoxMesh.new()
		cmesh.size = Vector3(0.55, 0.18, 0.65)
		chunk.mesh = cmesh
		chunk.position = Vector3(randf_range(-2, 2), 0.10, randf_range(-2, 2))
		chunk.rotation = Vector3(deg_to_rad(randf_range(-25, 25)), randf() * TAU, deg_to_rad(randf_range(-25, 25)))
		chunk.material_override = dark_mat
		field.add_child(chunk)
	# 1 smoking battery — has a sparking emitter
	var battery: MeshInstance3D = MeshInstance3D.new()
	var bm: BoxMesh = BoxMesh.new()
	bm.size = Vector3(0.30, 0.18, 0.30)
	battery.mesh = bm
	battery.position = Vector3(0, 0.10, 0)
	var bmat: StandardMaterial3D = StandardMaterial3D.new()
	bmat.albedo_color = Color(0.85, 0.30, 0.20)
	bmat.emission_enabled = true
	bmat.emission = Color(1.0, 0.40, 0.20)
	bmat.emission_energy_multiplier = 1.6
	battery.material_override = bmat
	field.add_child(battery)
	# Spark emitter from the battery
	var sparks: GPUParticles3D = GPUParticles3D.new()
	sparks.amount = 18
	sparks.lifetime = 0.85
	sparks.position = Vector3(0, 0.30, 0)
	var pmat: ParticleProcessMaterial = ParticleProcessMaterial.new()
	pmat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	pmat.emission_sphere_radius = 0.08
	pmat.direction = Vector3(0, 1, 0)
	pmat.spread = 50.0
	pmat.initial_velocity_min = 0.85
	pmat.initial_velocity_max = 1.4
	pmat.gravity = Vector3(0, -1.5, 0)
	pmat.scale_min = 0.04
	pmat.scale_max = 0.08
	pmat.color = Color(1.0, 0.85, 0.30, 1.0)
	sparks.process_material = pmat
	var sm: SphereMesh = SphereMesh.new()
	sm.radius = 0.04
	sm.height = 0.08
	var sm_mat: StandardMaterial3D = StandardMaterial3D.new()
	sm_mat.albedo_color = Color(1.0, 0.85, 0.30)
	sm_mat.emission_enabled = true
	sm_mat.emission = Color(1.0, 0.95, 0.40)
	sm_mat.emission_energy_multiplier = 2.6
	sm_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	sm.material = sm_mat
	sparks.draw_pass_1 = sm
	field.add_child(sparks)


func _build_d2_watchman_npc() -> void:
	## Epic-2 T29: a patrolling D2 watchman NPC marching back and forth
	## along the boundary. Wears a heavy armor body, has a glowing red
	## visor strip, and carries a long pulse rifle.
	var slots: Node3D = get_node_or_null("%NPCSlots") as Node3D
	if slots == null:
		return
	var watch: Node3D = Node3D.new()
	watch.name = "D2Watchman"
	watch.position = D2_CENTER + Vector3(18, 0, -10)
	slots.add_child(watch)
	# Body — heavy armored capsule
	var armor_mat: StandardMaterial3D = StandardMaterial3D.new()
	armor_mat.albedo_color = Color(0.20, 0.16, 0.14)
	armor_mat.metallic = 0.65
	armor_mat.roughness = 0.40
	armor_mat.emission_enabled = true
	armor_mat.emission = Color(0.85, 0.30, 0.20)
	armor_mat.emission_energy_multiplier = 0.30
	var body: MeshInstance3D = MeshInstance3D.new()
	var bmesh: CapsuleMesh = CapsuleMesh.new()
	bmesh.radius = 0.45
	bmesh.height = 1.30
	body.mesh = bmesh
	body.position = Vector3(0, 0.70, 0)
	body.material_override = armor_mat
	watch.add_child(body)
	# Helmet — dark cylinder
	var helmet: MeshInstance3D = MeshInstance3D.new()
	var hmesh: CylinderMesh = CylinderMesh.new()
	hmesh.top_radius = 0.35
	hmesh.bottom_radius = 0.40
	hmesh.height = 0.50
	helmet.mesh = hmesh
	helmet.position = Vector3(0, 1.55, 0)
	var hmat: StandardMaterial3D = StandardMaterial3D.new()
	hmat.albedo_color = Color(0.10, 0.10, 0.12)
	hmat.metallic = 0.85
	hmat.roughness = 0.30
	helmet.material_override = hmat
	watch.add_child(helmet)
	# Red glowing visor strip across the front
	var visor: MeshInstance3D = MeshInstance3D.new()
	var vmesh: BoxMesh = BoxMesh.new()
	vmesh.size = Vector3(0.55, 0.10, 0.04)
	visor.mesh = vmesh
	visor.position = Vector3(0, 1.55, 0.34)
	var vmat: StandardMaterial3D = StandardMaterial3D.new()
	vmat.albedo_color = Color(1.0, 0.20, 0.20)
	vmat.emission_enabled = true
	vmat.emission = Color(1.0, 0.30, 0.30)
	vmat.emission_energy_multiplier = 2.6
	vmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	visor.material_override = vmat
	watch.add_child(visor)
	# Pulse rifle held diagonally across the body
	var rifle_root: Node3D = Node3D.new()
	rifle_root.position = Vector3(0.20, 0.85, 0.40)
	rifle_root.rotation = Vector3(0, deg_to_rad(20), deg_to_rad(-25))
	watch.add_child(rifle_root)
	# Rifle body
	var rifle: MeshInstance3D = MeshInstance3D.new()
	var rmesh: BoxMesh = BoxMesh.new()
	rmesh.size = Vector3(0.10, 0.18, 1.40)
	rifle.mesh = rmesh
	rifle.material_override = hmat
	rifle_root.add_child(rifle)
	# Glowing barrel tip
	var muzzle: MeshInstance3D = MeshInstance3D.new()
	var mm: SphereMesh = SphereMesh.new()
	mm.radius = 0.10
	mm.height = 0.20
	muzzle.mesh = mm
	muzzle.position = Vector3(0, 0, -0.85)
	var muz_mat: StandardMaterial3D = StandardMaterial3D.new()
	muz_mat.albedo_color = Color(1.0, 0.40, 0.20)
	muz_mat.emission_enabled = true
	muz_mat.emission = Color(1.0, 0.55, 0.20)
	muz_mat.emission_energy_multiplier = 2.4
	muz_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	muzzle.material_override = muz_mat
	rifle_root.add_child(muzzle)
	# Patrol path — back and forth along z
	var origin: Vector3 = D2_CENTER + Vector3(18, 0, -10)
	var patrol: Tween = create_tween().set_loops()
	patrol.tween_property(watch, "rotation:y", deg_to_rad(180), 0.4)
	patrol.tween_property(watch, "position", origin + Vector3(0, 0, -8), 6.0)
	patrol.tween_property(watch, "rotation:y", 0.0, 0.4)
	patrol.tween_property(watch, "position", origin, 6.0)
	# Name billboard
	var label: Label3D = Label3D.new()
	label.text = "Watchman"
	label.position = Vector3(0, 2.10, 0)
	label.modulate = Color(1.0, 0.55, 0.30)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 18
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	watch.add_child(label)


func _build_d2_smoke_vents(geom: Node) -> void:
	## Epic-2 T30: 5 ground steam/smoke vents emitting upward streams.
	## Each is a small dark grate with a particle column rising from it.
	var positions: Array[Vector3] = [
		D2_CENTER + Vector3(-10, 0, 6),
		D2_CENTER + Vector3(0, 0, -8),
		D2_CENTER + Vector3(8, 0, 12),
		D2_CENTER + Vector3(20, 0, -2),
		D2_CENTER + Vector3(-4, 0, -16),
	]
	for i in positions.size():
		var vent: Node3D = Node3D.new()
		vent.name = "D2SmokeVent_%d" % i
		vent.position = positions[i]
		geom.add_child(vent)
		# Grate — dark short cylinder flush with ground
		var grate: MeshInstance3D = MeshInstance3D.new()
		var gmesh: CylinderMesh = CylinderMesh.new()
		gmesh.top_radius = 0.45
		gmesh.bottom_radius = 0.45
		gmesh.height = 0.10
		grate.mesh = gmesh
		grate.position = Vector3(0, 0.05, 0)
		var gmat: StandardMaterial3D = StandardMaterial3D.new()
		gmat.albedo_color = Color(0.06, 0.06, 0.10)
		gmat.metallic = 0.65
		gmat.roughness = 0.55
		gmat.emission_enabled = true
		gmat.emission = Color(0.85, 0.30, 0.20)
		gmat.emission_energy_multiplier = 0.55
		grate.material_override = gmat
		vent.add_child(grate)
		# 4 cross bars on top to look like a grate
		for b in 4:
			var bar: MeshInstance3D = MeshInstance3D.new()
			var bmesh: BoxMesh = BoxMesh.new()
			bmesh.size = Vector3(0.85, 0.04, 0.06)
			bar.mesh = bmesh
			bar.position = Vector3(0, 0.13, -0.30 + b * 0.20)
			bar.material_override = gmat
			vent.add_child(bar)
		# Smoke particles rising
		var smoke: GPUParticles3D = GPUParticles3D.new()
		smoke.amount = 24
		smoke.lifetime = 3.0
		smoke.position = Vector3(0, 0.40, 0)
		var pmat: ParticleProcessMaterial = ParticleProcessMaterial.new()
		pmat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
		pmat.emission_sphere_radius = 0.30
		pmat.direction = Vector3(0, 1, 0)
		pmat.spread = 18.0
		pmat.initial_velocity_min = 0.45
		pmat.initial_velocity_max = 0.85
		pmat.gravity = Vector3.ZERO
		pmat.scale_min = 0.30
		pmat.scale_max = 0.55
		pmat.color = Color(0.40, 0.40, 0.50, 0.55)
		smoke.process_material = pmat
		var sm: SphereMesh = SphereMesh.new()
		sm.radius = 0.30
		sm.height = 0.60
		var sm_mat: StandardMaterial3D = StandardMaterial3D.new()
		sm_mat.albedo_color = Color(0.40, 0.40, 0.50, 0.55)
		sm_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		sm_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		sm.material = sm_mat
		smoke.draw_pass_1 = sm
		vent.add_child(smoke)


func _build_d2_toxic_barrels(geom: Node) -> void:
	## Epic-2 T31: cluster of 6 yellow toxic barrels with glowing rims +
	## hazard symbols. Some are tipped over, some upright. Sells "this
	## stuff is dangerous, the workers couldn't seal it back up".
	var cluster: Node3D = Node3D.new()
	cluster.name = "D2ToxicBarrels"
	cluster.position = D2_CENTER + Vector3(-3, 0, -8)
	geom.add_child(cluster)
	var body_mat: StandardMaterial3D = StandardMaterial3D.new()
	body_mat.albedo_color = Color(0.85, 0.65, 0.10)
	body_mat.metallic = 0.45
	body_mat.roughness = 0.55
	var rim_mat: StandardMaterial3D = StandardMaterial3D.new()
	rim_mat.albedo_color = Color(0.30, 1.0, 0.30)
	rim_mat.emission_enabled = true
	rim_mat.emission = Color(0.45, 1.0, 0.40)
	rim_mat.emission_energy_multiplier = 1.8
	rim_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var barrel_specs: Array = [
		[Vector3(0.0, 0.55, 0.0), Vector3(0, 0, 0)],
		[Vector3(1.2, 0.55, 0.4), Vector3(0, 0, 0)],
		[Vector3(-1.0, 0.55, 0.6), Vector3(0, 0, 0)],
		[Vector3(0.5, 0.55, -1.2), Vector3(0, 0, 0)],
		[Vector3(2.2, 0.30, -0.6), Vector3(deg_to_rad(85), deg_to_rad(20), 0)],
		[Vector3(-1.8, 0.30, -0.4), Vector3(deg_to_rad(80), deg_to_rad(-30), 0)],
	]
	for i in barrel_specs.size():
		var barrel: Node3D = Node3D.new()
		barrel.name = "Barrel_%d" % i
		barrel.position = barrel_specs[i][0]
		barrel.rotation = barrel_specs[i][1]
		cluster.add_child(barrel)
		# Body cylinder
		var body: MeshInstance3D = MeshInstance3D.new()
		var bmesh: CylinderMesh = CylinderMesh.new()
		bmesh.top_radius = 0.40
		bmesh.bottom_radius = 0.40
		bmesh.height = 1.05
		body.mesh = bmesh
		body.material_override = body_mat
		barrel.add_child(body)
		# Top + bottom rim
		for ry: float in [-0.50, 0.50]:
			var rim: MeshInstance3D = MeshInstance3D.new()
			var rmesh: TorusMesh = TorusMesh.new()
			rmesh.inner_radius = 0.40
			rmesh.outer_radius = 0.45
			rim.mesh = rmesh
			rim.position = Vector3(0, ry, 0)
			rim.material_override = rim_mat
			barrel.add_child(rim)
		# Hazard sign label on the side
		var hazard: Label3D = Label3D.new()
		hazard.text = "☢"
		hazard.position = Vector3(0, 0, 0.41)
		hazard.modulate = Color(0.10, 0.10, 0.10)
		hazard.outline_size = 0
		hazard.font_size = 32
		hazard.no_depth_test = true
		barrel.add_child(hazard)
	# Collision around the cluster
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(4.5, 1.20, 3.0)
	cs.shape = cb
	cs.position = Vector3(0, 0.60, 0)
	sb.add_child(cs)
	cluster.add_child(sb)


func _build_d2_buried_arm(geom: Node) -> void:
	## Epic-2 T32: half-buried giant mechanical arm sticking out of the
	## ground at an angle, frozen in a gripping pose. 4 segments + a
	## 4-fingered claw at the top. Mysterious lore-piece scale prop.
	var arm: Node3D = Node3D.new()
	arm.name = "D2BuriedArm"
	arm.position = D2_CENTER + Vector3(0, 0, 18)
	arm.rotation = Vector3(0, deg_to_rad(35), deg_to_rad(-30))
	geom.add_child(arm)
	var metal_mat: StandardMaterial3D = StandardMaterial3D.new()
	metal_mat.albedo_color = Color(0.20, 0.22, 0.28)
	metal_mat.metallic = 0.85
	metal_mat.roughness = 0.40
	# 4 stacked arm segments (each smaller than the last)
	var segment_sizes: Array[float] = [1.20, 1.0, 0.85, 0.65]
	var current_y: float = 0.0
	for i in segment_sizes.size():
		var seg: MeshInstance3D = MeshInstance3D.new()
		var smesh: BoxMesh = BoxMesh.new()
		var seg_height: float = 1.6
		smesh.size = Vector3(segment_sizes[i], seg_height, segment_sizes[i])
		seg.mesh = smesh
		seg.position = Vector3(0, current_y + seg_height * 0.5, 0)
		seg.material_override = metal_mat
		arm.add_child(seg)
		# Glowing joint ring at the bottom of each segment except the first
		if i > 0:
			var joint: MeshInstance3D = MeshInstance3D.new()
			var jm: TorusMesh = TorusMesh.new()
			jm.inner_radius = segment_sizes[i] * 0.55
			jm.outer_radius = segment_sizes[i] * 0.70
			joint.mesh = jm
			joint.position = Vector3(0, current_y, 0)
			var jmat: StandardMaterial3D = StandardMaterial3D.new()
			jmat.albedo_color = Color(1.0, 0.40, 0.20)
			jmat.emission_enabled = true
			jmat.emission = Color(1.0, 0.55, 0.20)
			jmat.emission_energy_multiplier = 1.8
			jmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
			joint.material_override = jmat
			arm.add_child(joint)
		current_y += seg_height
	# 4 finger claws at the top, splayed outward
	for f in 4:
		var angle: float = (float(f) / 4.0) * TAU
		var finger: MeshInstance3D = MeshInstance3D.new()
		var fmesh: BoxMesh = BoxMesh.new()
		fmesh.size = Vector3(0.18, 1.20, 0.18)
		finger.mesh = fmesh
		finger.position = Vector3(cos(angle) * 0.45, current_y + 0.50, sin(angle) * 0.45)
		finger.rotation = Vector3(deg_to_rad(20) * sin(angle), 0, deg_to_rad(20) * cos(angle))
		finger.material_override = metal_mat
		arm.add_child(finger)
	# Collision around the base
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cap: CapsuleShape3D = CapsuleShape3D.new()
	cap.radius = 0.85
	cap.height = current_y
	cs.shape = cap
	cs.position = Vector3(0, current_y * 0.5, 0)
	sb.add_child(cs)
	arm.add_child(sb)


func _build_d2_fire_pit(geom: Node) -> void:
	## Epic-2 T33: campfire pit with crackling fire particles + 2 small
	## NPCs (silhouette capsules) seated around it. The first sign of
	## "people gather here for warmth" in the dangerous district.
	var fire: Node3D = Node3D.new()
	fire.name = "D2FirePit"
	fire.position = D2_CENTER + Vector3(-12, 0, 10)
	geom.add_child(fire)
	# Stone ring
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.16, 0.14, 0.12)
	stone_mat.metallic = 0.30
	stone_mat.roughness = 0.55
	for s in 8:
		var angle: float = (float(s) / 8.0) * TAU
		var stone: MeshInstance3D = MeshInstance3D.new()
		var smesh: BoxMesh = BoxMesh.new()
		smesh.size = Vector3(0.35, 0.20, 0.30)
		stone.mesh = smesh
		stone.position = Vector3(cos(angle) * 0.85, 0.10, sin(angle) * 0.85)
		stone.rotation = Vector3(0, -angle, 0)
		stone.material_override = stone_mat
		fire.add_child(stone)
	# Logs in center (4 crossed cylinders)
	var log_mat: StandardMaterial3D = StandardMaterial3D.new()
	log_mat.albedo_color = Color(0.30, 0.18, 0.10)
	log_mat.metallic = 0.10
	log_mat.roughness = 0.65
	for i in 4:
		var log_mesh: MeshInstance3D = MeshInstance3D.new()
		var lm: CylinderMesh = CylinderMesh.new()
		lm.top_radius = 0.10
		lm.bottom_radius = 0.10
		lm.height = 1.0
		log_mesh.mesh = lm
		log_mesh.position = Vector3(0, 0.20, 0)
		log_mesh.rotation = Vector3(deg_to_rad(85), deg_to_rad(45 * i), 0)
		log_mesh.material_override = log_mat
		fire.add_child(log_mesh)
	# Glowing ember core
	var ember: MeshInstance3D = MeshInstance3D.new()
	var em: SphereMesh = SphereMesh.new()
	em.radius = 0.30
	em.height = 0.60
	ember.mesh = em
	ember.position = Vector3(0, 0.30, 0)
	var em_mat: StandardMaterial3D = StandardMaterial3D.new()
	em_mat.albedo_color = Color(1.0, 0.55, 0.20)
	em_mat.emission_enabled = true
	em_mat.emission = Color(1.0, 0.65, 0.20)
	em_mat.emission_energy_multiplier = 2.6
	em_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	ember.material_override = em_mat
	fire.add_child(ember)
	# Pulse ember
	var pulse: Tween = create_tween().set_loops()
	pulse.tween_property(ember, "scale", Vector3(1.20, 1.20, 1.20), 0.6).set_ease(Tween.EASE_IN_OUT)
	pulse.tween_property(ember, "scale", Vector3(0.95, 0.95, 0.95), 0.6).set_ease(Tween.EASE_IN_OUT)
	# Real omni light from fire
	var light: OmniLight3D = OmniLight3D.new()
	light.position = Vector3(0, 0.5, 0)
	light.light_color = Color(1.0, 0.65, 0.30)
	light.light_energy = 2.4
	light.omni_range = 7.0
	fire.add_child(light)
	# Flame particles rising
	var flames: GPUParticles3D = GPUParticles3D.new()
	flames.amount = 50
	flames.lifetime = 1.4
	flames.position = Vector3(0, 0.45, 0)
	var pmat: ParticleProcessMaterial = ParticleProcessMaterial.new()
	pmat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	pmat.emission_sphere_radius = 0.25
	pmat.direction = Vector3(0, 1, 0)
	pmat.spread = 18.0
	pmat.initial_velocity_min = 1.4
	pmat.initial_velocity_max = 2.4
	pmat.gravity = Vector3.ZERO
	pmat.scale_min = 0.18
	pmat.scale_max = 0.35
	pmat.color = Color(1.0, 0.55, 0.20, 1.0)
	flames.process_material = pmat
	var flame_mesh: SphereMesh = SphereMesh.new()
	flame_mesh.radius = 0.18
	flame_mesh.height = 0.36
	var flame_mat: StandardMaterial3D = StandardMaterial3D.new()
	flame_mat.albedo_color = Color(1.0, 0.55, 0.20)
	flame_mat.emission_enabled = true
	flame_mat.emission = Color(1.0, 0.65, 0.20)
	flame_mat.emission_energy_multiplier = 2.4
	flame_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	flame_mesh.material = flame_mat
	flames.draw_pass_1 = flame_mesh
	fire.add_child(flames)
	# 2 seated silhouettes (capsules) around the fire
	var sit_mat: StandardMaterial3D = StandardMaterial3D.new()
	sit_mat.albedo_color = Color(0.16, 0.10, 0.06)
	sit_mat.metallic = 0.10
	sit_mat.roughness = 0.65
	for spec in [[Vector3(-1.7, 0.35, 0), Color(1.0, 0.65, 0.30)], [Vector3(1.7, 0.35, 0), Color(1.0, 0.55, 0.20)]]:
		var npc: MeshInstance3D = MeshInstance3D.new()
		var nmesh: CapsuleMesh = CapsuleMesh.new()
		nmesh.radius = 0.30
		nmesh.height = 0.55
		npc.mesh = nmesh
		npc.position = spec[0]
		npc.rotation = Vector3(deg_to_rad(15), 0, 0)
		npc.material_override = sit_mat
		fire.add_child(npc)
		# Glowing eye facing the fire
		var eye: MeshInstance3D = MeshInstance3D.new()
		var eye_mesh: SphereMesh = SphereMesh.new()
		eye_mesh.radius = 0.05
		eye_mesh.height = 0.10
		eye.mesh = eye_mesh
		var to_fire_x: float = -sign(spec[0].x) * 0.30
		eye.position = (spec[0] as Vector3) + Vector3(to_fire_x, 0.10, 0)
		var eye_mat: StandardMaterial3D = StandardMaterial3D.new()
		var eye_color: Color = spec[1]
		eye_mat.albedo_color = eye_color
		eye_mat.emission_enabled = true
		eye_mat.emission = eye_color
		eye_mat.emission_energy_multiplier = 2.6
		eye_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		eye.material_override = eye_mat
		fire.add_child(eye)


func _build_d2_hoverbike_wreck(geom: Node) -> void:
	## Epic-2 T34: a wrecked hover-bike at the side of the road, tilted on
	## its side, with one engine pod sparking. Tells "fast travel exists
	## here but it's deadly".
	var bike: Node3D = Node3D.new()
	bike.name = "D2HoverbikeWreck"
	bike.position = D2_CENTER + Vector3(10, 0, -16)
	bike.rotation = Vector3(0, deg_to_rad(-25), deg_to_rad(35))
	geom.add_child(bike)
	# Main fuselage — long box
	var hull_mat: StandardMaterial3D = StandardMaterial3D.new()
	hull_mat.albedo_color = Color(0.20, 0.22, 0.28)
	hull_mat.metallic = 0.85
	hull_mat.roughness = 0.30
	var hull: MeshInstance3D = MeshInstance3D.new()
	var hmesh: BoxMesh = BoxMesh.new()
	hmesh.size = Vector3(1.40, 0.40, 0.55)
	hull.mesh = hmesh
	hull.position = Vector3(0, 0.45, 0)
	hull.material_override = hull_mat
	bike.add_child(hull)
	# Pointy nose (prism)
	var nose: MeshInstance3D = MeshInstance3D.new()
	var nmesh: PrismMesh = PrismMesh.new()
	nmesh.size = Vector3(0.55, 0.40, 0.55)
	nose.mesh = nmesh
	nose.position = Vector3(0.95, 0.45, 0)
	nose.rotation = Vector3(0, deg_to_rad(90), 0)
	nose.material_override = hull_mat
	bike.add_child(nose)
	# Handlebars (thin bar across)
	var bar: MeshInstance3D = MeshInstance3D.new()
	var bmesh: CylinderMesh = CylinderMesh.new()
	bmesh.top_radius = 0.05
	bmesh.bottom_radius = 0.05
	bmesh.height = 0.85
	bar.mesh = bmesh
	bar.position = Vector3(0.55, 0.55, 0)
	bar.rotation = Vector3(deg_to_rad(90), 0, 0)
	bar.material_override = hull_mat
	bike.add_child(bar)
	# 2 engine pods on each side
	var engine_mat: StandardMaterial3D = StandardMaterial3D.new()
	engine_mat.albedo_color = Color(0.30, 0.10, 0.06)
	engine_mat.emission_enabled = true
	engine_mat.emission = Color(1.0, 0.40, 0.20)
	engine_mat.emission_energy_multiplier = 0.85
	engine_mat.metallic = 0.55
	for sz: float in [-0.55, 0.55]:
		var pod: MeshInstance3D = MeshInstance3D.new()
		var pmesh: CylinderMesh = CylinderMesh.new()
		pmesh.top_radius = 0.18
		pmesh.bottom_radius = 0.22
		pmesh.height = 1.0
		pod.mesh = pmesh
		pod.position = Vector3(-0.30, 0.45, sz)
		pod.rotation = Vector3(deg_to_rad(90), 0, 0)
		pod.material_override = engine_mat
		bike.add_child(pod)
	# Sparks from one engine
	var sparks: GPUParticles3D = GPUParticles3D.new()
	sparks.amount = 24
	sparks.lifetime = 0.85
	sparks.position = Vector3(-0.80, 0.45, 0.55)
	var spmat: ParticleProcessMaterial = ParticleProcessMaterial.new()
	spmat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	spmat.emission_sphere_radius = 0.10
	spmat.direction = Vector3(-1, 0.5, 0)
	spmat.spread = 50.0
	spmat.initial_velocity_min = 1.4
	spmat.initial_velocity_max = 2.4
	spmat.gravity = Vector3(0, -2.0, 0)
	spmat.scale_min = 0.04
	spmat.scale_max = 0.10
	spmat.color = Color(1.0, 0.85, 0.30, 1.0)
	sparks.process_material = spmat
	var sm: SphereMesh = SphereMesh.new()
	sm.radius = 0.05
	sm.height = 0.10
	var sm_mat: StandardMaterial3D = StandardMaterial3D.new()
	sm_mat.albedo_color = Color(1.0, 0.85, 0.30)
	sm_mat.emission_enabled = true
	sm_mat.emission = Color(1.0, 0.95, 0.40)
	sm_mat.emission_energy_multiplier = 2.6
	sm_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	sm.material = sm_mat
	sparks.draw_pass_1 = sm
	bike.add_child(sparks)
	# Collision around the wreck
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(2.4, 1.0, 1.6)
	cs.shape = cb
	cs.position = Vector3(0, 0.45, 0)
	sb.add_child(cs)
	bike.add_child(sb)


func _build_d2_code_waterfall(geom: Node) -> void:
	## Epic-2 T35: a vertical "code stream waterfall" — a tall narrow
	## column of green emissive characters falling from a high broken
	## conduit at the back of the district. Particles + a Label3D ribbon.
	var fall: Node3D = Node3D.new()
	fall.name = "D2CodeWaterfall"
	fall.position = D2_CENTER + Vector3(-22, 0, -2)
	geom.add_child(fall)
	# Broken conduit pipe at the top (small box)
	var pipe_mat: StandardMaterial3D = StandardMaterial3D.new()
	pipe_mat.albedo_color = Color(0.20, 0.22, 0.28)
	pipe_mat.metallic = 0.85
	pipe_mat.roughness = 0.30
	var pipe: MeshInstance3D = MeshInstance3D.new()
	var pmesh: CylinderMesh = CylinderMesh.new()
	pmesh.top_radius = 0.30
	pmesh.bottom_radius = 0.30
	pmesh.height = 1.4
	pipe.mesh = pmesh
	pipe.position = Vector3(0, 7.5, 0)
	pipe.rotation = Vector3(0, 0, deg_to_rad(90))
	pipe.material_override = pipe_mat
	fall.add_child(pipe)
	# Falling green particles
	var stream: GPUParticles3D = GPUParticles3D.new()
	stream.amount = 80
	stream.lifetime = 3.5
	stream.position = Vector3(0, 7.0, 0)
	var spmat: ParticleProcessMaterial = ParticleProcessMaterial.new()
	spmat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	spmat.emission_sphere_radius = 0.20
	spmat.direction = Vector3(0, -1, 0)
	spmat.spread = 4.0
	spmat.initial_velocity_min = 0.85
	spmat.initial_velocity_max = 1.40
	spmat.gravity = Vector3(0, -1.5, 0)
	spmat.scale_min = 0.10
	spmat.scale_max = 0.18
	spmat.color = Color(0.40, 1.0, 0.55, 1.0)
	stream.process_material = spmat
	var bit: BoxMesh = BoxMesh.new()
	bit.size = Vector3(0.10, 0.18, 0.04)
	var bit_mat: StandardMaterial3D = StandardMaterial3D.new()
	bit_mat.albedo_color = Color(0.40, 1.0, 0.55)
	bit_mat.emission_enabled = true
	bit_mat.emission = Color(0.55, 1.0, 0.55)
	bit_mat.emission_energy_multiplier = 2.6
	bit_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	bit.material = bit_mat
	stream.draw_pass_1 = bit
	fall.add_child(stream)
	# 3 floating "01" Label3D ribbons inside the column
	for i in 3:
		var ribbon: Label3D = Label3D.new()
		ribbon.text = "01010\n10110\n01101"
		ribbon.position = Vector3(randf_range(-0.20, 0.20), 5.0 - i * 1.6, 0)
		ribbon.modulate = Color(0.40, 1.0, 0.55)
		ribbon.outline_modulate = Color(0, 0, 0, 0.85)
		ribbon.outline_size = 3
		ribbon.font_size = 16
		ribbon.no_depth_test = true
		ribbon.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		fall.add_child(ribbon)
		# Drift down + reset
		var drift: Tween = create_tween().set_loops()
		var origin_y: float = ribbon.position.y
		drift.tween_property(ribbon, "position:y", origin_y - 4.0, 3.5)
		drift.tween_property(ribbon, "position:y", origin_y, 0.05)
	# Collision around the conduit pipe
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cap: CapsuleShape3D = CapsuleShape3D.new()
	cap.radius = 0.40
	cap.height = 1.4
	cs.shape = cap
	cs.position = Vector3(0, 7.5, 0)
	sb.add_child(cs)
	fall.add_child(sb)


func _build_d2_dust_storm(geom: Node) -> void:
	## Epic-2 T36: horizontal dust storm particles drifting eastward across
	## the entire D2 floor — large slow grey-amber motes carried by wind.
	var dust: GPUParticles3D = GPUParticles3D.new()
	dust.name = "D2DustStorm"
	dust.position = D2_CENTER + Vector3(-25, 3, 0)
	dust.amount = 80
	dust.lifetime = 8.0
	dust.preprocess = 4.0
	var pmat: ParticleProcessMaterial = ParticleProcessMaterial.new()
	pmat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	pmat.emission_box_extents = Vector3(0.5, 4.0, 18.0)
	pmat.direction = Vector3(1, 0, 0)
	pmat.spread = 6.0
	pmat.initial_velocity_min = 1.4
	pmat.initial_velocity_max = 2.2
	pmat.gravity = Vector3.ZERO
	pmat.scale_min = 0.30
	pmat.scale_max = 0.55
	pmat.color = Color(0.85, 0.65, 0.40, 0.30)
	dust.process_material = pmat
	var dmesh: SphereMesh = SphereMesh.new()
	dmesh.radius = 0.30
	dmesh.height = 0.60
	var dmat: StandardMaterial3D = StandardMaterial3D.new()
	dmat.albedo_color = Color(0.85, 0.65, 0.40, 0.30)
	dmat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	dmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	dmesh.material = dmat
	dust.draw_pass_1 = dmesh
	geom.add_child(dust)


func _build_d2_data_well(geom: Node) -> void:
	## Epic-2 T37: an ancient data well — a stone circular rim around a
	## glowing cyan pool, with a winch frame above it. The pool surface
	## ripples (scale tween). The first sign of "old infrastructure" in D2.
	var well: Node3D = Node3D.new()
	well.name = "D2DataWell"
	well.position = D2_CENTER + Vector3(0, 0, 6)
	geom.add_child(well)
	# Stone rim torus
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.20, 0.18, 0.14)
	stone_mat.metallic = 0.30
	stone_mat.roughness = 0.65
	var rim: MeshInstance3D = MeshInstance3D.new()
	var rmesh: TorusMesh = TorusMesh.new()
	rmesh.inner_radius = 0.85
	rmesh.outer_radius = 1.15
	rim.mesh = rmesh
	rim.position = Vector3(0, 0.30, 0)
	rim.material_override = stone_mat
	well.add_child(rim)
	# Pool surface inside the rim — glowing cyan disc
	var pool: MeshInstance3D = MeshInstance3D.new()
	var pmesh: CylinderMesh = CylinderMesh.new()
	pmesh.top_radius = 0.85
	pmesh.bottom_radius = 0.85
	pmesh.height = 0.05
	pool.mesh = pmesh
	pool.position = Vector3(0, 0.30, 0)
	var pmat: StandardMaterial3D = StandardMaterial3D.new()
	pmat.albedo_color = Color(0.30, 0.85, 1.0, 0.85)
	pmat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	pmat.emission_enabled = true
	pmat.emission = Color(0.55, 0.95, 1.0)
	pmat.emission_energy_multiplier = 1.6
	pmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	pool.material_override = pmat
	well.add_child(pool)
	# Ripple tween — scale x/z slightly
	var ripple: Tween = create_tween().set_loops()
	ripple.tween_property(pool, "scale", Vector3(1.05, 1.0, 0.96), 1.6).set_ease(Tween.EASE_IN_OUT)
	ripple.tween_property(pool, "scale", Vector3(0.96, 1.0, 1.05), 1.6).set_ease(Tween.EASE_IN_OUT)
	# Winch frame above the well — 4 legs + top crossbar
	var metal_mat: StandardMaterial3D = StandardMaterial3D.new()
	metal_mat.albedo_color = Color(0.10, 0.13, 0.16)
	metal_mat.metallic = 0.85
	metal_mat.roughness = 0.30
	for ox: float in [-0.95, 0.95]:
		for oz: float in [-0.95, 0.95]:
			var leg: MeshInstance3D = MeshInstance3D.new()
			var lmesh: CylinderMesh = CylinderMesh.new()
			lmesh.top_radius = 0.06
			lmesh.bottom_radius = 0.08
			lmesh.height = 2.4
			leg.mesh = lmesh
			leg.position = Vector3(ox * 0.85, 1.20, oz * 0.85)
			# Tilt legs inward to form a tripod top
			leg.rotation = Vector3(-sign(oz) * deg_to_rad(8), 0, sign(ox) * deg_to_rad(8))
			leg.material_override = metal_mat
			well.add_child(leg)
	# Top crossbar
	var bar: MeshInstance3D = MeshInstance3D.new()
	var bmesh: CylinderMesh = CylinderMesh.new()
	bmesh.top_radius = 0.07
	bmesh.bottom_radius = 0.07
	bmesh.height = 1.6
	bar.mesh = bmesh
	bar.position = Vector3(0, 2.40, 0)
	bar.rotation = Vector3(0, 0, deg_to_rad(90))
	bar.material_override = metal_mat
	well.add_child(bar)
	# Hanging bucket on a chain (cylinder + thin chain)
	var chain: MeshInstance3D = MeshInstance3D.new()
	var cmesh: CylinderMesh = CylinderMesh.new()
	cmesh.top_radius = 0.02
	cmesh.bottom_radius = 0.02
	cmesh.height = 1.40
	chain.mesh = cmesh
	chain.position = Vector3(0, 1.70, 0)
	chain.material_override = metal_mat
	well.add_child(chain)
	var bucket: MeshInstance3D = MeshInstance3D.new()
	var buc_mesh: CylinderMesh = CylinderMesh.new()
	buc_mesh.top_radius = 0.20
	buc_mesh.bottom_radius = 0.18
	buc_mesh.height = 0.30
	bucket.mesh = buc_mesh
	bucket.position = Vector3(0, 1.0, 0)
	bucket.material_override = metal_mat
	well.add_child(bucket)
	# Sign
	var label: Label3D = Label3D.new()
	label.text = "DATA WELL"
	label.position = Vector3(0, 3.0, 0)
	label.modulate = Color(0.55, 0.95, 1.0)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 18
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	well.add_child(label)
	# Collision around the rim
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(2.4, 1.0, 2.4)
	cs.shape = cb
	cs.position = Vector3(0, 0.40, 0)
	sb.add_child(cs)
	well.add_child(sb)


func _build_d2_scrap_tower(geom: Node) -> void:
	## Epic-2 T38: a tall stacked tower of broken machines welded together
	## haphazardly. 8 random boxes in different sizes/orientations climbing
	## upward, topped by a small antenna. Decorative landmark.
	var tower: Node3D = Node3D.new()
	tower.name = "D2ScrapTower"
	tower.position = D2_CENTER + Vector3(-22, 0, 12)
	geom.add_child(tower)
	var dark_mat: StandardMaterial3D = StandardMaterial3D.new()
	dark_mat.albedo_color = Color(0.18, 0.16, 0.12)
	dark_mat.metallic = 0.65
	dark_mat.roughness = 0.55
	var rust_mat: StandardMaterial3D = StandardMaterial3D.new()
	rust_mat.albedo_color = Color(0.40, 0.20, 0.10)
	rust_mat.metallic = 0.30
	rust_mat.roughness = 0.65
	var current_y: float = 0.0
	for i in 8:
		var size: float = 1.5 - i * 0.10
		var height: float = 0.85 + randf_range(-0.20, 0.30)
		var box: MeshInstance3D = MeshInstance3D.new()
		var bmesh: BoxMesh = BoxMesh.new()
		bmesh.size = Vector3(size, height, size)
		box.mesh = bmesh
		box.position = Vector3(randf_range(-0.20, 0.20), current_y + height * 0.5, randf_range(-0.20, 0.20))
		box.rotation = Vector3(0, deg_to_rad(randf_range(-25, 25)), 0)
		box.material_override = dark_mat if i % 2 == 0 else rust_mat
		tower.add_child(box)
		# Random LED
		if i % 2 == 0:
			var led: MeshInstance3D = MeshInstance3D.new()
			var lmesh: SphereMesh = SphereMesh.new()
			lmesh.radius = 0.06
			lmesh.height = 0.12
			led.mesh = lmesh
			led.position = Vector3(0, current_y + height * 0.5, size * 0.5 + 0.04)
			var lmat: StandardMaterial3D = StandardMaterial3D.new()
			lmat.albedo_color = Color(0.30, 1.0, 0.40)
			lmat.emission_enabled = true
			lmat.emission = Color(0.45, 1.0, 0.45)
			lmat.emission_energy_multiplier = 2.0
			lmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
			led.material_override = lmat
			tower.add_child(led)
		current_y += height
	# Top antenna
	var antenna: MeshInstance3D = MeshInstance3D.new()
	var amesh: CylinderMesh = CylinderMesh.new()
	amesh.top_radius = 0.04
	amesh.bottom_radius = 0.10
	amesh.height = 1.6
	antenna.mesh = amesh
	antenna.position = Vector3(0, current_y + 0.80, 0)
	antenna.material_override = dark_mat
	tower.add_child(antenna)
	# Antenna tip blink
	var tip: MeshInstance3D = MeshInstance3D.new()
	var tmesh: SphereMesh = SphereMesh.new()
	tmesh.radius = 0.10
	tmesh.height = 0.20
	tip.mesh = tmesh
	tip.position = Vector3(0, current_y + 1.65, 0)
	var tip_mat: StandardMaterial3D = StandardMaterial3D.new()
	tip_mat.albedo_color = Color(1.0, 0.40, 0.20)
	tip_mat.emission_enabled = true
	tip_mat.emission = Color(1.0, 0.55, 0.20)
	tip_mat.emission_energy_multiplier = 2.4
	tip_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	tip.material_override = tip_mat
	tower.add_child(tip)
	var blink: Tween = create_tween().set_loops()
	blink.tween_property(tip, "scale", Vector3(0.4, 0.4, 0.4), 0.5).set_ease(Tween.EASE_IN_OUT)
	blink.tween_property(tip, "scale", Vector3(1.4, 1.4, 1.4), 0.5).set_ease(Tween.EASE_IN_OUT)
	# Collision around the whole stack
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(1.6, current_y, 1.6)
	cs.shape = cb
	cs.position = Vector3(0, current_y * 0.5, 0)
	sb.add_child(cs)
	tower.add_child(sb)


func _build_d2_scrap_vendor_cart(geom: Node) -> void:
	## Epic-2 T39: a beat-up vendor cart selling scrap. Lower body with
	## 2 wheels, a hood with hanging metal bits, a sign reading "SCRAP".
	var cart: Node3D = Node3D.new()
	cart.name = "D2ScrapVendorCart"
	cart.position = D2_CENTER + Vector3(12, 0, 0)
	geom.add_child(cart)
	var rust_mat: StandardMaterial3D = StandardMaterial3D.new()
	rust_mat.albedo_color = Color(0.40, 0.20, 0.10)
	rust_mat.metallic = 0.30
	rust_mat.roughness = 0.65
	# Cart body
	var body: MeshInstance3D = MeshInstance3D.new()
	var bmesh: BoxMesh = BoxMesh.new()
	bmesh.size = Vector3(1.85, 0.85, 1.0)
	body.mesh = bmesh
	body.position = Vector3(0, 0.65, 0)
	body.material_override = rust_mat
	cart.add_child(body)
	# 2 wheels
	var wheel_mat: StandardMaterial3D = StandardMaterial3D.new()
	wheel_mat.albedo_color = Color(0.10, 0.10, 0.12)
	wheel_mat.metallic = 0.55
	for sx: float in [-0.85, 0.85]:
		var wheel: MeshInstance3D = MeshInstance3D.new()
		var wmesh: CylinderMesh = CylinderMesh.new()
		wmesh.top_radius = 0.30
		wmesh.bottom_radius = 0.30
		wmesh.height = 0.10
		wheel.mesh = wmesh
		wheel.position = Vector3(sx, 0.30, 0)
		wheel.rotation = Vector3(0, 0, deg_to_rad(90))
		wheel.material_override = wheel_mat
		cart.add_child(wheel)
	# Hood roof — angled box overhead
	var hood: MeshInstance3D = MeshInstance3D.new()
	var hmesh: BoxMesh = BoxMesh.new()
	hmesh.size = Vector3(2.2, 0.10, 1.4)
	hood.mesh = hmesh
	hood.position = Vector3(0, 1.85, 0)
	var hmat: StandardMaterial3D = StandardMaterial3D.new()
	hmat.albedo_color = Color(0.20, 0.16, 0.12)
	hmat.metallic = 0.30
	hmat.roughness = 0.55
	hood.material_override = hmat
	cart.add_child(hood)
	# 4 vertical poles holding hood up
	var pole_mat: StandardMaterial3D = StandardMaterial3D.new()
	pole_mat.albedo_color = Color(0.10, 0.13, 0.16)
	pole_mat.metallic = 0.85
	for ox: float in [-0.95, 0.95]:
		for oz: float in [-0.55, 0.55]:
			var pole: MeshInstance3D = MeshInstance3D.new()
			var pmesh: CylinderMesh = CylinderMesh.new()
			pmesh.top_radius = 0.04
			pmesh.bottom_radius = 0.04
			pmesh.height = 0.85
			pole.mesh = pmesh
			pole.position = Vector3(ox, 1.40, oz)
			pole.material_override = pole_mat
			cart.add_child(pole)
	# 5 hanging metal scrap bits from the hood
	for i in 5:
		var bit: MeshInstance3D = MeshInstance3D.new()
		var bmesh2: BoxMesh = BoxMesh.new()
		bmesh2.size = Vector3(0.18, 0.18, 0.04)
		bit.mesh = bmesh2
		var bx: float = -0.85 + i * 0.40
		bit.position = Vector3(bx, 1.65, 0.30)
		bit.rotation = Vector3(0, 0, deg_to_rad(randf_range(-25, 25)))
		bit.material_override = pole_mat
		cart.add_child(bit)
	# Sign
	var label: Label3D = Label3D.new()
	label.text = "SCRAP"
	label.position = Vector3(0, 2.20, 0)
	label.modulate = Color(1.0, 0.55, 0.20)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 22
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	cart.add_child(label)
	# Collision around body
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(2.0, 1.6, 1.4)
	cs.shape = cb
	cs.position = Vector3(0, 0.85, 0)
	sb.add_child(cs)
	cart.add_child(sb)


func _build_d2_smuggler_npc() -> void:
	## Epic-2 T40: a sneaky smuggler NPC peeking out from behind a shipping
	## container. Crouched body, single shifty cyan eye, holding a small
	## glowing red package. Crouching, with a periodic peek-out animation.
	var slots: Node3D = get_node_or_null("%NPCSlots") as Node3D
	if slots == null:
		return
	var smug: Node3D = Node3D.new()
	smug.name = "D2Smuggler"
	smug.position = D2_CENTER + Vector3(20, 0, 12)
	slots.add_child(smug)
	# Crouched body
	var body: MeshInstance3D = MeshInstance3D.new()
	var bmesh: CapsuleMesh = CapsuleMesh.new()
	bmesh.radius = 0.36
	bmesh.height = 0.85
	body.mesh = bmesh
	body.position = Vector3(0, 0.45, 0)
	var bmat: StandardMaterial3D = StandardMaterial3D.new()
	bmat.albedo_color = Color(0.10, 0.10, 0.14)
	bmat.metallic = 0.20
	bmat.roughness = 0.65
	body.material_override = bmat
	smug.add_child(body)
	# Hood
	var hood: MeshInstance3D = MeshInstance3D.new()
	var hmesh: SphereMesh = SphereMesh.new()
	hmesh.radius = 0.40
	hmesh.height = 0.55
	hood.mesh = hmesh
	hood.position = Vector3(0, 1.0, 0)
	hood.material_override = bmat
	smug.add_child(hood)
	# Single shifty cyan eye
	var eye: MeshInstance3D = MeshInstance3D.new()
	var emesh: SphereMesh = SphereMesh.new()
	emesh.radius = 0.08
	emesh.height = 0.16
	eye.mesh = emesh
	eye.position = Vector3(0, 0.95, 0.30)
	var emat: StandardMaterial3D = StandardMaterial3D.new()
	emat.albedo_color = Color(0.30, 0.85, 1.0)
	emat.emission_enabled = true
	emat.emission = Color(0.55, 0.95, 1.0)
	emat.emission_energy_multiplier = 2.6
	emat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	eye.material_override = emat
	smug.add_child(eye)
	# Glowing red package held in front
	var pkg: MeshInstance3D = MeshInstance3D.new()
	var pmesh: BoxMesh = BoxMesh.new()
	pmesh.size = Vector3(0.30, 0.20, 0.30)
	pkg.mesh = pmesh
	pkg.position = Vector3(0.30, 0.50, 0.35)
	var pmat: StandardMaterial3D = StandardMaterial3D.new()
	pmat.albedo_color = Color(0.50, 0.10, 0.10)
	pmat.emission_enabled = true
	pmat.emission = Color(1.0, 0.30, 0.20)
	pmat.emission_energy_multiplier = 1.6
	pmat.metallic = 0.30
	pkg.material_override = pmat
	smug.add_child(pkg)
	# Peek-out tween — body shifts left/right periodically
	var peek: Tween = create_tween().set_loops()
	peek.tween_interval(2.0)
	peek.tween_property(smug, "position:x", D2_CENTER.x + 21.2, 0.5).set_ease(Tween.EASE_OUT)
	peek.tween_interval(1.4)
	peek.tween_property(smug, "position:x", D2_CENTER.x + 20.0, 0.5).set_ease(Tween.EASE_IN)
	# Name billboard
	var label: Label3D = Label3D.new()
	label.text = "Smuggler"
	label.position = Vector3(0, 1.55, 0)
	label.modulate = Color(0.55, 0.95, 1.0)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 16
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	smug.add_child(label)


func _build_d2_holo_wireframe(geom: Node) -> void:
	## Epic-2 T41: a holographic enemy wireframe billboard — a tall narrow
	## display showing a rotating wireframe glitch beast silhouette. Used
	## by mercenaries as a "WANTED" notice.
	var billboard: Node3D = Node3D.new()
	billboard.name = "D2HoloWireframe"
	billboard.position = D2_CENTER + Vector3(6, 0, -4)
	geom.add_child(billboard)
	# Stand
	var stand_mat: StandardMaterial3D = StandardMaterial3D.new()
	stand_mat.albedo_color = Color(0.10, 0.13, 0.16)
	stand_mat.metallic = 0.85
	stand_mat.roughness = 0.30
	var stand: MeshInstance3D = MeshInstance3D.new()
	var smesh: BoxMesh = BoxMesh.new()
	smesh.size = Vector3(0.30, 0.85, 0.30)
	stand.mesh = smesh
	stand.position = Vector3(0, 0.42, 0)
	stand.material_override = stand_mat
	billboard.add_child(stand)
	# Display panel
	var panel: MeshInstance3D = MeshInstance3D.new()
	var pmesh: BoxMesh = BoxMesh.new()
	pmesh.size = Vector3(1.40, 1.85, 0.10)
	panel.mesh = pmesh
	panel.position = Vector3(0, 1.80, 0)
	var pmat: StandardMaterial3D = StandardMaterial3D.new()
	pmat.albedo_color = Color(0.06, 0.05, 0.10)
	pmat.metallic = 0.40
	pmat.roughness = 0.30
	pmat.emission_enabled = true
	pmat.emission = Color(1.0, 0.30, 0.30)
	pmat.emission_energy_multiplier = 0.45
	panel.material_override = pmat
	billboard.add_child(panel)
	# Rotating wireframe enemy inside the display
	var wire_pivot: Node3D = Node3D.new()
	wire_pivot.position = Vector3(0, 1.80, 0.10)
	billboard.add_child(wire_pivot)
	# Use a wireframe sphere (we approximate with thin emissive bars)
	var wire_mat: StandardMaterial3D = StandardMaterial3D.new()
	wire_mat.albedo_color = Color(1.0, 0.30, 0.30)
	wire_mat.emission_enabled = true
	wire_mat.emission = Color(1.0, 0.40, 0.40)
	wire_mat.emission_energy_multiplier = 2.4
	wire_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	# Body box wireframe (12 edges)
	var size: float = 0.55
	var edges: Array = [
		# Bottom rectangle
		[Vector3(-size, -size, -size), Vector3(size, -size, -size)],
		[Vector3(size, -size, -size), Vector3(size, -size, size)],
		[Vector3(size, -size, size), Vector3(-size, -size, size)],
		[Vector3(-size, -size, size), Vector3(-size, -size, -size)],
		# Top rectangle
		[Vector3(-size, size, -size), Vector3(size, size, -size)],
		[Vector3(size, size, -size), Vector3(size, size, size)],
		[Vector3(size, size, size), Vector3(-size, size, size)],
		[Vector3(-size, size, size), Vector3(-size, size, -size)],
		# Vertical edges
		[Vector3(-size, -size, -size), Vector3(-size, size, -size)],
		[Vector3(size, -size, -size), Vector3(size, size, -size)],
		[Vector3(size, -size, size), Vector3(size, size, size)],
		[Vector3(-size, -size, size), Vector3(-size, size, size)],
	]
	for edge in edges:
		var seg: MeshInstance3D = MeshInstance3D.new()
		var dist: float = (edge[0] as Vector3).distance_to(edge[1] as Vector3)
		var em: BoxMesh = BoxMesh.new()
		em.size = Vector3(0.03, dist, 0.03)
		seg.mesh = em
		var mid: Vector3 = ((edge[0] as Vector3) + (edge[1] as Vector3)) * 0.5
		seg.position = mid
		var dir: Vector3 = ((edge[1] as Vector3) - (edge[0] as Vector3)).normalized()
		# Orient the box so its Y axis aligns with edge direction
		var up: Vector3 = Vector3.UP
		if abs(dir.dot(up)) > 0.99:
			seg.rotation = Vector3(0, 0, 0)
		else:
			var right: Vector3 = up.cross(dir).normalized()
			var new_up: Vector3 = dir
			var new_right: Vector3 = right
			var new_fwd: Vector3 = new_up.cross(new_right)
			var basis: Basis = Basis(new_right, new_up, new_fwd)
			seg.basis = basis
		seg.material_override = wire_mat
		wire_pivot.add_child(seg)
	# Slow rotation
	var spin: Tween = create_tween().set_loops()
	spin.tween_property(wire_pivot, "rotation:y", TAU, 6.0)
	# WANTED label at top
	var wanted: Label3D = Label3D.new()
	wanted.text = "WANTED"
	wanted.position = Vector3(0, 2.85, 0.06)
	wanted.modulate = Color(1.0, 0.30, 0.30)
	wanted.outline_modulate = Color(0, 0, 0, 0.85)
	wanted.outline_size = 5
	wanted.font_size = 22
	wanted.no_depth_test = true
	billboard.add_child(wanted)
	# REWARD subtitle
	var reward: Label3D = Label3D.new()
	reward.text = "REWARD: 500"
	reward.position = Vector3(0, 0.95, 0.06)
	reward.modulate = Color(1.0, 0.85, 0.30)
	reward.outline_modulate = Color(0, 0, 0, 0.85)
	reward.outline_size = 4
	reward.font_size = 14
	reward.no_depth_test = true
	billboard.add_child(reward)
	# Collision around stand
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(0.30, 2.7, 0.30)
	cs.shape = cb
	cs.position = Vector3(0, 1.35, 0)
	sb.add_child(cs)
	billboard.add_child(sb)


func _build_d2_caged_bugs(geom: Node) -> void:
	## Epic-2 T42: a stack of 3 wireframe cages on a table, each holding
	## a captured glitchbug specimen of a different color (green/orange/violet).
	var cage_root: Node3D = Node3D.new()
	cage_root.name = "D2CagedBugs"
	cage_root.position = D2_CENTER + Vector3(-15, 0, -2)
	geom.add_child(cage_root)
	# Table
	var table_mat: StandardMaterial3D = StandardMaterial3D.new()
	table_mat.albedo_color = Color(0.18, 0.16, 0.12)
	table_mat.metallic = 0.30
	table_mat.roughness = 0.65
	var table: MeshInstance3D = MeshInstance3D.new()
	var tmesh: BoxMesh = BoxMesh.new()
	tmesh.size = Vector3(1.20, 0.85, 0.85)
	table.mesh = tmesh
	table.position = Vector3(0, 0.42, 0)
	table.material_override = table_mat
	cage_root.add_child(table)
	# Helper inline function — 1 cage at given position with given color bug
	var bug_specs: Array = [
		[Vector3(-0.40, 1.10, 0), Color(0.40, 1.0, 0.40), Color(0.40, 1.0, 0.40)],
		[Vector3(0.40, 1.10, 0), Color(1.0, 0.55, 0.20), Color(1.0, 0.55, 0.20)],
		[Vector3(0.0, 1.65, 0), Color(0.85, 0.40, 1.0), Color(0.85, 0.40, 1.0)],
	]
	for spec in bug_specs:
		var pos: Vector3 = spec[0]
		var bar_color: Color = spec[1]
		var bug_color: Color = spec[2]
		# Cage cube wireframe — 12 edges
		var bar_mat: StandardMaterial3D = StandardMaterial3D.new()
		bar_mat.albedo_color = bar_color
		bar_mat.emission_enabled = true
		bar_mat.emission = bar_color
		bar_mat.emission_energy_multiplier = 1.8
		bar_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		var s: float = 0.30
		# 4 vertical
		for ox in [-s, s]:
			for oz in [-s, s]:
				var bar: MeshInstance3D = MeshInstance3D.new()
				var bm: CylinderMesh = CylinderMesh.new()
				bm.top_radius = 0.018
				bm.bottom_radius = 0.018
				bm.height = s * 2
				bar.mesh = bm
				bar.position = pos + Vector3(ox, 0, oz)
				bar.material_override = bar_mat
				cage_root.add_child(bar)
		# 8 horizontal (top + bottom rectangles)
		var horizontals: Array = [
			[Vector3(0, -s, -s), Vector3(s * 2, 0.04, 0.04)],
			[Vector3(0, -s, s), Vector3(s * 2, 0.04, 0.04)],
			[Vector3(-s, -s, 0), Vector3(0.04, 0.04, s * 2)],
			[Vector3(s, -s, 0), Vector3(0.04, 0.04, s * 2)],
			[Vector3(0, s, -s), Vector3(s * 2, 0.04, 0.04)],
			[Vector3(0, s, s), Vector3(s * 2, 0.04, 0.04)],
			[Vector3(-s, s, 0), Vector3(0.04, 0.04, s * 2)],
			[Vector3(s, s, 0), Vector3(0.04, 0.04, s * 2)],
		]
		for h in horizontals:
			var hbar: MeshInstance3D = MeshInstance3D.new()
			var hbm: BoxMesh = BoxMesh.new()
			hbm.size = h[1]
			hbar.mesh = hbm
			hbar.position = pos + (h[0] as Vector3)
			hbar.material_override = bar_mat
			cage_root.add_child(hbar)
		# Bug inside — small sphere
		var bug: MeshInstance3D = MeshInstance3D.new()
		var bgm: SphereMesh = SphereMesh.new()
		bgm.radius = 0.14
		bgm.height = 0.28
		bug.mesh = bgm
		bug.position = pos
		var bgmat: StandardMaterial3D = StandardMaterial3D.new()
		bgmat.albedo_color = bug_color
		bgmat.emission_enabled = true
		bgmat.emission = bug_color
		bgmat.emission_energy_multiplier = 1.8
		bgmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		bug.material_override = bgmat
		cage_root.add_child(bug)
		# Bug bounces inside
		var bounce: Tween = create_tween().set_loops()
		bounce.tween_property(bug, "position", pos + Vector3(0.10, 0.08, 0), 0.4).set_ease(Tween.EASE_IN_OUT)
		bounce.tween_property(bug, "position", pos + Vector3(-0.10, -0.08, 0), 0.4).set_ease(Tween.EASE_IN_OUT)
		bounce.tween_property(bug, "position", pos + Vector3(0, 0, 0.10), 0.4).set_ease(Tween.EASE_IN_OUT)
	# Sign
	var label: Label3D = Label3D.new()
	label.text = "SPECIMENS"
	label.position = Vector3(0, 2.20, 0)
	label.modulate = Color(0.85, 0.95, 0.55)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 16
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	cage_root.add_child(label)
	# Collision around table
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(1.20, 1.85, 0.85)
	cs.shape = cb
	cs.position = Vector3(0, 0.92, 0)
	sb.add_child(cs)
	cage_root.add_child(sb)


func _build_d2_arc_generator(geom: Node) -> void:
	## Epic-2 T43: an industrial arc generator — 2 metal coil pillars with
	## a sparking electrical arc traveling between them, mounted on a base.
	var gen: Node3D = Node3D.new()
	gen.name = "D2ArcGenerator"
	gen.position = D2_CENTER + Vector3(-18, 0, -10)
	geom.add_child(gen)
	# Base platform
	var dark_mat: StandardMaterial3D = StandardMaterial3D.new()
	dark_mat.albedo_color = Color(0.10, 0.13, 0.16)
	dark_mat.metallic = 0.85
	dark_mat.roughness = 0.30
	var base: MeshInstance3D = MeshInstance3D.new()
	var bmesh: BoxMesh = BoxMesh.new()
	bmesh.size = Vector3(2.40, 0.40, 1.40)
	base.mesh = bmesh
	base.position = Vector3(0, 0.20, 0)
	base.material_override = dark_mat
	gen.add_child(base)
	# 2 coil pillars
	var coil_mat: StandardMaterial3D = StandardMaterial3D.new()
	coil_mat.albedo_color = Color(0.55, 0.30, 0.10)
	coil_mat.metallic = 0.85
	coil_mat.roughness = 0.30
	for sx: float in [-0.85, 0.85]:
		var pillar: MeshInstance3D = MeshInstance3D.new()
		var pmesh: CylinderMesh = CylinderMesh.new()
		pmesh.top_radius = 0.20
		pmesh.bottom_radius = 0.30
		pmesh.height = 1.85
		pillar.mesh = pmesh
		pillar.position = Vector3(sx, 1.30, 0)
		pillar.material_override = coil_mat
		gen.add_child(pillar)
		# Top sphere terminal
		var term: MeshInstance3D = MeshInstance3D.new()
		var tmesh: SphereMesh = SphereMesh.new()
		tmesh.radius = 0.30
		tmesh.height = 0.60
		term.mesh = tmesh
		term.position = Vector3(sx, 2.30, 0)
		var tmat: StandardMaterial3D = StandardMaterial3D.new()
		tmat.albedo_color = Color(0.85, 0.85, 0.95)
		tmat.metallic = 0.85
		tmat.roughness = 0.20
		tmat.emission_enabled = true
		tmat.emission = Color(0.55, 0.95, 1.0)
		tmat.emission_energy_multiplier = 1.4
		term.material_override = tmat
		gen.add_child(term)
	# Arc — 5 thin emissive bars between the terminals at random angles
	var arc_mat: StandardMaterial3D = StandardMaterial3D.new()
	arc_mat.albedo_color = Color(0.85, 0.95, 1.0)
	arc_mat.emission_enabled = true
	arc_mat.emission = Color(0.95, 0.95, 1.0)
	arc_mat.emission_energy_multiplier = 3.6
	arc_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for i in 5:
		var seg: MeshInstance3D = MeshInstance3D.new()
		var sm: BoxMesh = BoxMesh.new()
		sm.size = Vector3(0.36, 0.05, 0.05)
		seg.mesh = sm
		seg.position = Vector3(-0.65 + i * 0.34, 2.30 + randf_range(-0.15, 0.15), 0)
		seg.rotation = Vector3(0, 0, deg_to_rad(randf_range(-25, 25)))
		seg.material_override = arc_mat
		gen.add_child(seg)
		# Flicker
		var flicker: Tween = create_tween().set_loops()
		flicker.tween_property(seg, "visible", false, 0.0)
		flicker.tween_interval(0.06 + randf() * 0.10)
		flicker.tween_property(seg, "visible", true, 0.0)
		flicker.tween_interval(0.04 + randf() * 0.10)
	# Collision around base
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(2.40, 2.20, 1.40)
	cs.shape = cb
	cs.position = Vector3(0, 1.10, 0)
	sb.add_child(cs)
	gen.add_child(sb)


func _build_d2_hover_platform(geom: Node) -> void:
	## Epic-2 T44: a small floating hover platform that bobs in place.
	## Hex-shaped disc with cyan glow underneath, slowly rotating.
	var plat: Node3D = Node3D.new()
	plat.name = "D2HoverPlatform"
	plat.position = D2_CENTER + Vector3(4, 1.6, -16)
	geom.add_child(plat)
	# Hex disc
	var disc_mat: StandardMaterial3D = StandardMaterial3D.new()
	disc_mat.albedo_color = Color(0.20, 0.22, 0.28)
	disc_mat.metallic = 0.85
	disc_mat.roughness = 0.30
	var disc: MeshInstance3D = MeshInstance3D.new()
	var dmesh: PrismMesh = PrismMesh.new()
	dmesh.size = Vector3(1.40, 0.20, 1.40)
	disc.mesh = dmesh
	disc.material_override = disc_mat
	plat.add_child(disc)
	# Cyan glow underneath
	var glow_mat: StandardMaterial3D = StandardMaterial3D.new()
	glow_mat.albedo_color = Color(0.30, 0.85, 1.0, 0.55)
	glow_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	glow_mat.emission_enabled = true
	glow_mat.emission = Color(0.55, 0.95, 1.0)
	glow_mat.emission_energy_multiplier = 1.8
	glow_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var glow: MeshInstance3D = MeshInstance3D.new()
	var gmesh: CylinderMesh = CylinderMesh.new()
	gmesh.top_radius = 0.95
	gmesh.bottom_radius = 0.95
	gmesh.height = 0.06
	glow.mesh = gmesh
	glow.position = Vector3(0, -0.20, 0)
	glow.material_override = glow_mat
	plat.add_child(glow)
	# Edge emissive trim
	var trim_mat: StandardMaterial3D = StandardMaterial3D.new()
	trim_mat.albedo_color = Color(0.55, 0.95, 1.0)
	trim_mat.emission_enabled = true
	trim_mat.emission = Color(0.55, 0.95, 1.0)
	trim_mat.emission_energy_multiplier = 1.8
	trim_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for i in 6:
		var t: float = float(i) / 6.0
		var angle: float = t * TAU
		var trim: MeshInstance3D = MeshInstance3D.new()
		var tmesh: BoxMesh = BoxMesh.new()
		tmesh.size = Vector3(0.30, 0.04, 0.04)
		trim.mesh = tmesh
		trim.position = Vector3(cos(angle) * 0.65, 0.10, sin(angle) * 0.65)
		trim.rotation = Vector3(0, -angle, 0)
		trim.material_override = trim_mat
		plat.add_child(trim)
	# Bob in place
	var origin: Vector3 = D2_CENTER + Vector3(4, 1.6, -16)
	var bob: Tween = create_tween().set_loops()
	bob.tween_property(plat, "position:y", 2.0, 1.4).set_ease(Tween.EASE_IN_OUT)
	bob.tween_property(plat, "position:y", 1.6, 1.4).set_ease(Tween.EASE_IN_OUT)
	# Slow rotation
	var spin: Tween = create_tween().set_loops()
	spin.tween_property(plat, "rotation:y", TAU, 8.0)
	# Collision
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(1.4, 0.30, 1.4)
	cs.shape = cb
	sb.add_child(cs)
	plat.add_child(sb)


func _build_d2_arms_dealer_npc() -> void:
	## Epic-2 T45: arms dealer NPC standing behind a small table with 3
	## displayed weapons (3 colored vertical bars). Heavy armor + a wide
	## metal shoulder pad.
	var slots: Node3D = get_node_or_null("%NPCSlots") as Node3D
	if slots == null:
		return
	var dealer: Node3D = Node3D.new()
	dealer.name = "D2ArmsDealer"
	dealer.position = D2_CENTER + Vector3(15, 0, -6)
	slots.add_child(dealer)
	# Display table in front of the dealer
	var table_mat: StandardMaterial3D = StandardMaterial3D.new()
	table_mat.albedo_color = Color(0.18, 0.16, 0.12)
	table_mat.metallic = 0.40
	var table: MeshInstance3D = MeshInstance3D.new()
	var tmesh: BoxMesh = BoxMesh.new()
	tmesh.size = Vector3(1.40, 0.85, 0.55)
	table.mesh = tmesh
	table.position = Vector3(0, 0.42, 0.65)
	table.material_override = table_mat
	dealer.add_child(table)
	# 3 displayed weapons standing on the table
	var weapon_specs: Array = [
		[-0.45, Color(0.55, 0.95, 1.0)],
		[0.0, Color(1.0, 0.40, 0.20)],
		[0.45, Color(0.85, 0.40, 1.0)],
	]
	for spec in weapon_specs:
		var weapon: MeshInstance3D = MeshInstance3D.new()
		var wmesh: BoxMesh = BoxMesh.new()
		wmesh.size = Vector3(0.05, 0.85, 0.04)
		weapon.mesh = wmesh
		weapon.position = Vector3(spec[0], 1.30, 0.65)
		var wmat: StandardMaterial3D = StandardMaterial3D.new()
		var c: Color = spec[1]
		wmat.albedo_color = c
		wmat.emission_enabled = true
		wmat.emission = c
		wmat.emission_energy_multiplier = 1.8
		wmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		weapon.material_override = wmat
		dealer.add_child(weapon)
	# Body capsule
	var armor_mat: StandardMaterial3D = StandardMaterial3D.new()
	armor_mat.albedo_color = Color(0.20, 0.20, 0.24)
	armor_mat.metallic = 0.65
	armor_mat.roughness = 0.40
	var body: MeshInstance3D = MeshInstance3D.new()
	var bmesh: CapsuleMesh = CapsuleMesh.new()
	bmesh.radius = 0.45
	bmesh.height = 1.30
	body.mesh = bmesh
	body.position = Vector3(0, 0.70, 0)
	body.material_override = armor_mat
	dealer.add_child(body)
	# Wide metal shoulder pad (box on top of capsule)
	var pad: MeshInstance3D = MeshInstance3D.new()
	var pmesh: BoxMesh = BoxMesh.new()
	pmesh.size = Vector3(1.20, 0.20, 0.55)
	pad.mesh = pmesh
	pad.position = Vector3(0, 1.30, 0)
	pad.material_override = armor_mat
	dealer.add_child(pad)
	# Helmet
	var helmet: MeshInstance3D = MeshInstance3D.new()
	var hmesh: BoxMesh = BoxMesh.new()
	hmesh.size = Vector3(0.55, 0.50, 0.55)
	helmet.mesh = hmesh
	helmet.position = Vector3(0, 1.70, 0)
	var hmat: StandardMaterial3D = StandardMaterial3D.new()
	hmat.albedo_color = Color(0.08, 0.08, 0.10)
	hmat.metallic = 0.85
	hmat.roughness = 0.30
	helmet.material_override = hmat
	dealer.add_child(helmet)
	# 1 amber visor stripe
	var visor: MeshInstance3D = MeshInstance3D.new()
	var vmesh: BoxMesh = BoxMesh.new()
	vmesh.size = Vector3(0.55, 0.10, 0.04)
	visor.mesh = vmesh
	visor.position = Vector3(0, 1.72, 0.30)
	var vmat: StandardMaterial3D = StandardMaterial3D.new()
	vmat.albedo_color = Color(1.0, 0.65, 0.20)
	vmat.emission_enabled = true
	vmat.emission = Color(1.0, 0.75, 0.25)
	vmat.emission_energy_multiplier = 2.6
	vmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	visor.material_override = vmat
	dealer.add_child(visor)
	# Name billboard
	var label: Label3D = Label3D.new()
	label.text = "Arms Dealer"
	label.position = Vector3(0, 2.20, 0)
	label.modulate = Color(1.0, 0.65, 0.30)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 18
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	dealer.add_child(label)


func _build_d2_cracked_road(geom: Node) -> void:
	## Epic-2 T46: 14 cracked broken stone road tiles forming a winding path
	## from the entrance gate (x=72) east to the trial pit area. Each tile
	## has a slight random offset/rotation to look weathered.
	var road: Node3D = Node3D.new()
	road.name = "D2CrackedRoad"
	geom.add_child(road)
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.20, 0.16, 0.12)
	stone_mat.metallic = 0.30
	stone_mat.roughness = 0.65
	stone_mat.emission_enabled = true
	stone_mat.emission = Color(1.0, 0.55, 0.20)
	stone_mat.emission_energy_multiplier = 0.35
	for i in 14:
		var tile: MeshInstance3D = MeshInstance3D.new()
		tile.name = "RoadTile_%d" % i
		var tmesh: BoxMesh = BoxMesh.new()
		tmesh.size = Vector3(2.0 + randf_range(-0.20, 0.20), 0.10, 2.0 + randf_range(-0.20, 0.20))
		tile.mesh = tmesh
		# S-curve from entrance toward trial pit
		var t: float = float(i) / 14.0
		var x: float = 72.0 + i * 2.4
		var z: float = sin(t * 4.0) * 1.6
		tile.position = Vector3(x, 0.05, z)
		tile.rotation = Vector3(0, deg_to_rad(randf_range(-12, 12)), 0)
		tile.material_override = stone_mat
		road.add_child(tile)
		# Random emissive crack across the tile
		if i % 3 == 0:
			var crack: MeshInstance3D = MeshInstance3D.new()
			var cmesh: BoxMesh = BoxMesh.new()
			cmesh.size = Vector3(1.6, 0.04, 0.06)
			crack.mesh = cmesh
			crack.position = tile.position + Vector3(0, 0.06, 0)
			crack.rotation = Vector3(0, deg_to_rad(randf_range(-45, 45)), 0)
			var cmat: StandardMaterial3D = StandardMaterial3D.new()
			cmat.albedo_color = Color(1.0, 0.40, 0.20)
			cmat.emission_enabled = true
			cmat.emission = Color(1.0, 0.55, 0.20)
			cmat.emission_energy_multiplier = 1.6
			cmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
			crack.material_override = cmat
			road.add_child(crack)


func _build_d2_med_tent(geom: Node) -> void:
	## Epic-2 T47: a small first-aid med tent. White cloth canopy on 4 poles
	## with a glowing red cross on top + a small wooden cot inside.
	var tent: Node3D = Node3D.new()
	tent.name = "D2MedTent"
	tent.position = D2_CENTER + Vector3(-8, 0, 14)
	geom.add_child(tent)
	var post_mat: StandardMaterial3D = StandardMaterial3D.new()
	post_mat.albedo_color = Color(0.18, 0.16, 0.14)
	post_mat.metallic = 0.30
	for ox: float in [-1.2, 1.2]:
		for oz: float in [-1.0, 1.0]:
			var post: MeshInstance3D = MeshInstance3D.new()
			var pmesh: CylinderMesh = CylinderMesh.new()
			pmesh.top_radius = 0.06
			pmesh.bottom_radius = 0.08
			pmesh.height = 2.4
			post.mesh = pmesh
			post.position = Vector3(ox, 1.20, oz)
			post.material_override = post_mat
			tent.add_child(post)
	# White canopy roof — slightly angled prism
	var canopy_mat: StandardMaterial3D = StandardMaterial3D.new()
	canopy_mat.albedo_color = Color(0.85, 0.85, 0.92)
	canopy_mat.emission_enabled = true
	canopy_mat.emission = Color(0.95, 0.95, 1.0)
	canopy_mat.emission_energy_multiplier = 0.30
	canopy_mat.metallic = 0.10
	canopy_mat.roughness = 0.65
	var roof: MeshInstance3D = MeshInstance3D.new()
	var rmesh: PrismMesh = PrismMesh.new()
	rmesh.size = Vector3(2.8, 0.85, 2.4)
	roof.mesh = rmesh
	roof.position = Vector3(0, 2.85, 0)
	roof.material_override = canopy_mat
	tent.add_child(roof)
	# Red cross on top of roof
	var cross_mat: StandardMaterial3D = StandardMaterial3D.new()
	cross_mat.albedo_color = Color(1.0, 0.20, 0.20)
	cross_mat.emission_enabled = true
	cross_mat.emission = Color(1.0, 0.30, 0.30)
	cross_mat.emission_energy_multiplier = 1.8
	cross_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	# Vertical bar
	var v_bar: MeshInstance3D = MeshInstance3D.new()
	var vm: BoxMesh = BoxMesh.new()
	vm.size = Vector3(0.20, 0.85, 0.10)
	v_bar.mesh = vm
	v_bar.position = Vector3(0, 3.55, 0)
	v_bar.material_override = cross_mat
	tent.add_child(v_bar)
	# Horizontal bar
	var h_bar: MeshInstance3D = MeshInstance3D.new()
	var hm: BoxMesh = BoxMesh.new()
	hm.size = Vector3(0.65, 0.20, 0.10)
	h_bar.mesh = hm
	h_bar.position = Vector3(0, 3.55, 0)
	h_bar.material_override = cross_mat
	tent.add_child(h_bar)
	# Cot inside (a low box with a pillow)
	var cot_mat: StandardMaterial3D = StandardMaterial3D.new()
	cot_mat.albedo_color = Color(0.55, 0.50, 0.40)
	cot_mat.metallic = 0.10
	cot_mat.roughness = 0.75
	var cot: MeshInstance3D = MeshInstance3D.new()
	var cot_mesh: BoxMesh = BoxMesh.new()
	cot_mesh.size = Vector3(1.85, 0.18, 0.65)
	cot.mesh = cot_mesh
	cot.position = Vector3(0, 0.30, 0)
	cot.material_override = cot_mat
	tent.add_child(cot)
	# Pillow (smaller box)
	var pillow: MeshInstance3D = MeshInstance3D.new()
	var pmesh2: BoxMesh = BoxMesh.new()
	pmesh2.size = Vector3(0.40, 0.10, 0.30)
	pillow.mesh = pmesh2
	pillow.position = Vector3(-0.65, 0.45, 0)
	var pmat: StandardMaterial3D = StandardMaterial3D.new()
	pmat.albedo_color = Color(0.85, 0.85, 0.85)
	pillow.material_override = pmat
	tent.add_child(pillow)
	# Sign
	var label: Label3D = Label3D.new()
	label.text = "MED TENT"
	label.position = Vector3(0, 4.20, 0)
	label.modulate = Color(1.0, 0.30, 0.30)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 18
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	tent.add_child(label)
	# Collision around the tent
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(2.8, 2.4, 2.4)
	cs.shape = cb
	cs.position = Vector3(0, 1.20, 0)
	sb.add_child(cs)
	tent.add_child(sb)


func _build_d2_satellite_dish(geom: Node) -> void:
	## Epic-2 T48: a tall rusted satellite dish on a tilted base, slowly
	## rotating to scan the sky. The dish itself is a wide flat disc with
	## a focal element on a short stalk.
	var sat: Node3D = Node3D.new()
	sat.name = "D2SatelliteDish"
	sat.position = D2_CENTER + Vector3(22, 0, 0)
	geom.add_child(sat)
	var rust_mat: StandardMaterial3D = StandardMaterial3D.new()
	rust_mat.albedo_color = Color(0.40, 0.20, 0.10)
	rust_mat.metallic = 0.55
	rust_mat.roughness = 0.65
	# Tilted base mast
	var mast: MeshInstance3D = MeshInstance3D.new()
	var mmesh: CylinderMesh = CylinderMesh.new()
	mmesh.top_radius = 0.18
	mmesh.bottom_radius = 0.30
	mmesh.height = 4.0
	mast.mesh = mmesh
	mast.position = Vector3(0, 2.0, 0)
	mast.rotation = Vector3(deg_to_rad(-12), 0, 0)
	mast.material_override = rust_mat
	sat.add_child(mast)
	# Pivot for the dish (rotates)
	var dish_pivot: Node3D = Node3D.new()
	dish_pivot.position = Vector3(0, 4.0, 0.40)
	sat.add_child(dish_pivot)
	# Dish — wide flat curved disc (use a flat cylinder)
	var dish: MeshInstance3D = MeshInstance3D.new()
	var dmesh: CylinderMesh = CylinderMesh.new()
	dmesh.top_radius = 1.40
	dmesh.bottom_radius = 1.40
	dmesh.height = 0.10
	dish.mesh = dmesh
	dish.rotation = Vector3(deg_to_rad(75), 0, 0)
	dish.material_override = rust_mat
	dish_pivot.add_child(dish)
	# Focal element on a stalk
	var stalk: MeshInstance3D = MeshInstance3D.new()
	var smesh: CylinderMesh = CylinderMesh.new()
	smesh.top_radius = 0.04
	smesh.bottom_radius = 0.04
	smesh.height = 1.0
	stalk.mesh = smesh
	stalk.position = Vector3(0, 0.50, 0.10)
	stalk.rotation = Vector3(deg_to_rad(15), 0, 0)
	stalk.material_override = rust_mat
	dish_pivot.add_child(stalk)
	var focal: MeshInstance3D = MeshInstance3D.new()
	var fmesh: SphereMesh = SphereMesh.new()
	fmesh.radius = 0.18
	fmesh.height = 0.36
	focal.mesh = fmesh
	focal.position = Vector3(0, 1.0, 0.20)
	var focal_mat: StandardMaterial3D = StandardMaterial3D.new()
	focal_mat.albedo_color = Color(0.55, 0.95, 1.0)
	focal_mat.emission_enabled = true
	focal_mat.emission = Color(0.55, 0.95, 1.0)
	focal_mat.emission_energy_multiplier = 2.4
	focal_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	focal.material_override = focal_mat
	dish_pivot.add_child(focal)
	# Slow rotation scanning the sky
	var spin: Tween = create_tween().set_loops()
	spin.tween_property(dish_pivot, "rotation:y", deg_to_rad(80), 6.0).set_ease(Tween.EASE_IN_OUT)
	spin.tween_property(dish_pivot, "rotation:y", deg_to_rad(-80), 6.0).set_ease(Tween.EASE_IN_OUT)
	# Collision around mast
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cap: CapsuleShape3D = CapsuleShape3D.new()
	cap.radius = 0.45
	cap.height = 4.0
	cs.shape = cap
	cs.position = Vector3(0, 2.0, 0)
	sb.add_child(cs)
	sat.add_child(sb)


func _build_d2_cage_arena(geom: Node) -> void:
	## Epic-2 T49: a small caged fight arena with chain-link walls + a
	## center floor pad. 8 vertical bars + 8 horizontal cross-bars on each
	## of the 4 sides, leaving an entrance gap on the south side.
	var arena: Node3D = Node3D.new()
	arena.name = "D2CageArena"
	arena.position = D2_CENTER + Vector3(8, 0, -3)
	geom.add_child(arena)
	# Floor pad — 5x5 dark disc
	var pad_mat: StandardMaterial3D = StandardMaterial3D.new()
	pad_mat.albedo_color = Color(0.16, 0.10, 0.08)
	pad_mat.metallic = 0.40
	pad_mat.roughness = 0.55
	pad_mat.emission_enabled = true
	pad_mat.emission = Color(1.0, 0.40, 0.20)
	pad_mat.emission_energy_multiplier = 0.40
	var pad: MeshInstance3D = MeshInstance3D.new()
	var pad_mesh: CylinderMesh = CylinderMesh.new()
	pad_mesh.top_radius = 2.5
	pad_mesh.bottom_radius = 2.5
	pad_mesh.height = 0.08
	pad.mesh = pad_mesh
	pad.position = Vector3(0, 0.05, 0)
	pad.material_override = pad_mat
	arena.add_child(pad)
	# Cage bars — 4 sides, 6 verticals each side
	var bar_mat: StandardMaterial3D = StandardMaterial3D.new()
	bar_mat.albedo_color = Color(0.10, 0.10, 0.13)
	bar_mat.metallic = 0.85
	bar_mat.roughness = 0.30
	# 4 walls (north, east, west — south has entrance)
	var wall_specs: Array = [
		[Vector3(0, 0, -3.0), Vector3(0, 0, 0)],  # North wall
		[Vector3(3.0, 0, 0), Vector3(0, deg_to_rad(90), 0)],  # East wall
		[Vector3(-3.0, 0, 0), Vector3(0, deg_to_rad(90), 0)],  # West wall
	]
	for spec in wall_specs:
		var wall: Node3D = Node3D.new()
		wall.position = spec[0]
		wall.rotation = spec[1]
		arena.add_child(wall)
		# 6 vertical bars
		for v in 6:
			var vbar: MeshInstance3D = MeshInstance3D.new()
			var vbm: CylinderMesh = CylinderMesh.new()
			vbm.top_radius = 0.05
			vbm.bottom_radius = 0.05
			vbm.height = 2.4
			vbar.mesh = vbm
			vbar.position = Vector3(-2.5 + v * 1.0, 1.20, 0)
			vbar.material_override = bar_mat
			wall.add_child(vbar)
		# 4 horizontal cross-bars
		for h in 4:
			var hbar: MeshInstance3D = MeshInstance3D.new()
			var hbm: BoxMesh = BoxMesh.new()
			hbm.size = Vector3(5.0, 0.05, 0.05)
			hbar.mesh = hbm
			hbar.position = Vector3(0, 0.30 + h * 0.65, 0)
			hbar.material_override = bar_mat
			wall.add_child(hbar)
	# Top corner posts (4 thick posts framing the cage)
	for ox: float in [-3.0, 3.0]:
		for oz: float in [-3.0, 3.0]:
			var post: MeshInstance3D = MeshInstance3D.new()
			var pmesh: CylinderMesh = CylinderMesh.new()
			pmesh.top_radius = 0.10
			pmesh.bottom_radius = 0.12
			pmesh.height = 2.6
			post.mesh = pmesh
			post.position = Vector3(ox, 1.30, oz)
			post.material_override = bar_mat
			arena.add_child(post)
			# Collision per post
			var sb: StaticBody3D = StaticBody3D.new()
			var cs: CollisionShape3D = CollisionShape3D.new()
			var cap: CapsuleShape3D = CapsuleShape3D.new()
			cap.radius = 0.25
			cap.height = 2.6
			cs.shape = cap
			cs.position = Vector3(ox, 1.30, oz)
			sb.add_child(cs)
			arena.add_child(sb)
	# CAGE FIGHT label above
	var label: Label3D = Label3D.new()
	label.text = "CAGE FIGHT"
	label.position = Vector3(0, 3.0, 0)
	label.modulate = Color(1.0, 0.40, 0.30)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 6
	label.font_size = 22
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	arena.add_child(label)


func _build_d2_corrupted_titan(geom: Node) -> void:
	## Epic-2 T50: a 2nd mini-boss visual called "Corrupted Titan" — taller
	## than the glitch beast. Humanoid silhouette with hulking shoulders,
	## glitching geometry segments around the body, 2 huge red eyes, slow
	## intimidating pacing tween.
	var titan: Node3D = Node3D.new()
	titan.name = "D2CorruptedTitan"
	titan.position = D2_CENTER + Vector3(20, 0, -16)
	geom.add_child(titan)
	# Body torso — wide block
	var body_mat: StandardMaterial3D = StandardMaterial3D.new()
	body_mat.albedo_color = Color(0.10, 0.05, 0.10)
	body_mat.emission_enabled = true
	body_mat.emission = Color(0.85, 0.20, 0.40)
	body_mat.emission_energy_multiplier = 0.85
	body_mat.metallic = 0.55
	body_mat.roughness = 0.45
	var torso: MeshInstance3D = MeshInstance3D.new()
	var tmesh: BoxMesh = BoxMesh.new()
	tmesh.size = Vector3(2.0, 2.4, 1.40)
	torso.mesh = tmesh
	torso.position = Vector3(0, 2.20, 0)
	torso.material_override = body_mat
	titan.add_child(torso)
	# Hulking shoulder pads (2 wide blocks on top of torso)
	for sx: float in [-1.20, 1.20]:
		var pad: MeshInstance3D = MeshInstance3D.new()
		var pmesh: BoxMesh = BoxMesh.new()
		pmesh.size = Vector3(0.85, 0.55, 1.40)
		pad.mesh = pmesh
		pad.position = Vector3(sx, 3.20, 0)
		pad.material_override = body_mat
		titan.add_child(pad)
	# Head — smaller block
	var head: MeshInstance3D = MeshInstance3D.new()
	var hmesh: BoxMesh = BoxMesh.new()
	hmesh.size = Vector3(1.0, 0.95, 1.0)
	head.mesh = hmesh
	head.position = Vector3(0, 4.0, 0)
	head.material_override = body_mat
	titan.add_child(head)
	# 2 huge red eyes on the head
	var eye_mat: StandardMaterial3D = StandardMaterial3D.new()
	eye_mat.albedo_color = Color(1.0, 0.20, 0.20)
	eye_mat.emission_enabled = true
	eye_mat.emission = Color(1.0, 0.30, 0.30)
	eye_mat.emission_energy_multiplier = 3.4
	eye_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for ex: float in [-0.25, 0.25]:
		var eye: MeshInstance3D = MeshInstance3D.new()
		var em: SphereMesh = SphereMesh.new()
		em.radius = 0.18
		em.height = 0.36
		eye.mesh = em
		eye.position = Vector3(ex, 4.0, 0.55)
		eye.material_override = eye_mat
		titan.add_child(eye)
	# 2 huge legs (wide pillars)
	var leg_mat: StandardMaterial3D = StandardMaterial3D.new()
	leg_mat.albedo_color = Color(0.10, 0.05, 0.08)
	leg_mat.metallic = 0.40
	leg_mat.roughness = 0.55
	leg_mat.emission_enabled = true
	leg_mat.emission = Color(0.85, 0.20, 0.40)
	leg_mat.emission_energy_multiplier = 0.40
	for sx: float in [-0.55, 0.55]:
		var leg: MeshInstance3D = MeshInstance3D.new()
		var lm: BoxMesh = BoxMesh.new()
		lm.size = Vector3(0.65, 1.0, 0.55)
		leg.mesh = lm
		leg.position = Vector3(sx, 0.50, 0)
		leg.material_override = leg_mat
		titan.add_child(leg)
	# Glitching geometry segments — 6 random small boxes orbiting torso
	var glitch_mat: StandardMaterial3D = StandardMaterial3D.new()
	glitch_mat.albedo_color = Color(0.85, 0.20, 0.40, 0.65)
	glitch_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	glitch_mat.emission_enabled = true
	glitch_mat.emission = Color(1.0, 0.30, 0.55)
	glitch_mat.emission_energy_multiplier = 2.0
	glitch_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for i in 6:
		var glitch: MeshInstance3D = MeshInstance3D.new()
		var gm: BoxMesh = BoxMesh.new()
		gm.size = Vector3(0.30, 0.30, 0.30)
		glitch.mesh = gm
		var angle: float = (float(i) / 6.0) * TAU
		glitch.position = Vector3(cos(angle) * 1.50, 2.20 + (i - 3) * 0.30, sin(angle) * 1.50)
		glitch.material_override = glitch_mat
		titan.add_child(glitch)
		# Flicker visibility
		var fl: Tween = create_tween().set_loops()
		fl.tween_interval(0.5 + i * 0.1)
		fl.tween_property(glitch, "visible", false, 0.0)
		fl.tween_interval(0.10)
		fl.tween_property(glitch, "visible", true, 0.0)
		fl.tween_interval(0.4)
	# Slow pacing tween
	var origin: Vector3 = D2_CENTER + Vector3(20, 0, -16)
	var pace: Tween = create_tween().set_loops()
	pace.tween_property(titan, "rotation:y", deg_to_rad(180), 0.6)
	pace.tween_property(titan, "position", origin + Vector3(-6, 0, 0), 10.0)
	pace.tween_property(titan, "rotation:y", 0.0, 0.6)
	pace.tween_property(titan, "position", origin, 10.0)
	# Boss-tier name billboard
	var label: Label3D = Label3D.new()
	label.text = "CORRUPTED TITAN"
	label.position = Vector3(0, 5.20, 0)
	label.modulate = Color(1.0, 0.30, 0.40)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 6
	label.font_size = 24
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	titan.add_child(label)


func _build_d2_power_substation(geom: Node) -> void:
	## Epic-2 T51: a power substation — large transformer box on a fenced
	## platform with sparking insulators and warning signs.
	var sub: Node3D = Node3D.new()
	sub.name = "D2PowerSubstation"
	sub.position = D2_CENTER + Vector3(-22, 0, 6)
	geom.add_child(sub)
	# Concrete platform
	var plat_mat: StandardMaterial3D = StandardMaterial3D.new()
	plat_mat.albedo_color = Color(0.30, 0.32, 0.38)
	plat_mat.metallic = 0.20
	plat_mat.roughness = 0.65
	var plat: MeshInstance3D = MeshInstance3D.new()
	var pmesh: BoxMesh = BoxMesh.new()
	pmesh.size = Vector3(2.40, 0.30, 2.40)
	plat.mesh = pmesh
	plat.position = Vector3(0, 0.15, 0)
	plat.material_override = plat_mat
	sub.add_child(plat)
	# Transformer box (big rusted box)
	var trans_mat: StandardMaterial3D = StandardMaterial3D.new()
	trans_mat.albedo_color = Color(0.40, 0.30, 0.18)
	trans_mat.metallic = 0.40
	trans_mat.roughness = 0.55
	var trans: MeshInstance3D = MeshInstance3D.new()
	var tmesh: BoxMesh = BoxMesh.new()
	tmesh.size = Vector3(1.60, 1.85, 1.60)
	trans.mesh = tmesh
	trans.position = Vector3(0, 1.225, 0)
	trans.material_override = trans_mat
	sub.add_child(trans)
	# 3 ceramic insulator stacks on top
	var ceramic_mat: StandardMaterial3D = StandardMaterial3D.new()
	ceramic_mat.albedo_color = Color(0.85, 0.80, 0.70)
	ceramic_mat.metallic = 0.20
	ceramic_mat.roughness = 0.45
	for ix: float in [-0.50, 0.0, 0.50]:
		# 3 stacked discs
		for s in 3:
			var disc: MeshInstance3D = MeshInstance3D.new()
			var dmesh: CylinderMesh = CylinderMesh.new()
			dmesh.top_radius = 0.18 - s * 0.02
			dmesh.bottom_radius = 0.20 - s * 0.02
			dmesh.height = 0.18
			disc.mesh = dmesh
			disc.position = Vector3(ix, 2.30 + s * 0.20, 0)
			disc.material_override = ceramic_mat
			sub.add_child(disc)
		# Top spark cap
		var cap: MeshInstance3D = MeshInstance3D.new()
		var cmesh: SphereMesh = SphereMesh.new()
		cmesh.radius = 0.10
		cmesh.height = 0.20
		cap.mesh = cmesh
		cap.position = Vector3(ix, 2.95, 0)
		var cap_mat: StandardMaterial3D = StandardMaterial3D.new()
		cap_mat.albedo_color = Color(0.55, 0.95, 1.0)
		cap_mat.emission_enabled = true
		cap_mat.emission = Color(0.55, 0.95, 1.0)
		cap_mat.emission_energy_multiplier = 2.6
		cap_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		cap.material_override = cap_mat
		sub.add_child(cap)
	# Spark particles from the center insulator
	var sparks: GPUParticles3D = GPUParticles3D.new()
	sparks.amount = 20
	sparks.lifetime = 0.65
	sparks.position = Vector3(0, 3.0, 0)
	var spmat: ParticleProcessMaterial = ParticleProcessMaterial.new()
	spmat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	spmat.emission_sphere_radius = 0.15
	spmat.direction = Vector3(0, 1, 0)
	spmat.spread = 90.0
	spmat.initial_velocity_min = 1.4
	spmat.initial_velocity_max = 2.2
	spmat.gravity = Vector3(0, -3.0, 0)
	spmat.scale_min = 0.04
	spmat.scale_max = 0.10
	spmat.color = Color(0.55, 0.95, 1.0, 1.0)
	sparks.process_material = spmat
	var sm: SphereMesh = SphereMesh.new()
	sm.radius = 0.05
	sm.height = 0.10
	var sm_mat: StandardMaterial3D = StandardMaterial3D.new()
	sm_mat.albedo_color = Color(0.55, 0.95, 1.0)
	sm_mat.emission_enabled = true
	sm_mat.emission = Color(0.55, 0.95, 1.0)
	sm_mat.emission_energy_multiplier = 2.6
	sm_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	sm.material = sm_mat
	sparks.draw_pass_1 = sm
	sub.add_child(sparks)
	# Warning sign on the front of transformer (yellow box with red text)
	var warn: MeshInstance3D = MeshInstance3D.new()
	var wmesh: BoxMesh = BoxMesh.new()
	wmesh.size = Vector3(0.55, 0.40, 0.04)
	warn.mesh = wmesh
	warn.position = Vector3(0, 1.40, 0.82)
	var wmat: StandardMaterial3D = StandardMaterial3D.new()
	wmat.albedo_color = Color(1.0, 0.85, 0.20)
	wmat.emission_enabled = true
	wmat.emission = Color(1.0, 0.95, 0.30)
	wmat.emission_energy_multiplier = 1.4
	wmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	warn.material_override = wmat
	sub.add_child(warn)
	var warn_label: Label3D = Label3D.new()
	warn_label.text = "DANGER\nHIGH V"
	warn_label.position = Vector3(0, 1.40, 0.86)
	warn_label.modulate = Color(0.85, 0.10, 0.10)
	warn_label.outline_size = 0
	warn_label.font_size = 12
	warn_label.no_depth_test = true
	sub.add_child(warn_label)
	# Collision around platform + transformer
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(2.40, 3.30, 2.40)
	cs.shape = cb
	cs.position = Vector3(0, 1.65, 0)
	sb.add_child(cs)
	sub.add_child(sb)


func _build_d2_corpse_pile(geom: Node) -> void:
	## Epic-2 T52: a small respectful pile of fallen NPC silhouettes — 3
	## crumpled capsule bodies + 2 small Label3Ds with names. Lore element
	## sells "people died fighting here". Pure decoration, no gore.
	var pile: Node3D = Node3D.new()
	pile.name = "D2CorpsePile"
	pile.position = D2_CENTER + Vector3(13, 0, -14)
	geom.add_child(pile)
	var corpse_mat: StandardMaterial3D = StandardMaterial3D.new()
	corpse_mat.albedo_color = Color(0.16, 0.10, 0.06)
	corpse_mat.metallic = 0.10
	corpse_mat.roughness = 0.85
	var corpse_specs: Array = [
		[Vector3(-0.5, 0.18, 0), Vector3(deg_to_rad(85), deg_to_rad(20), 0)],
		[Vector3(0.4, 0.18, 0.3), Vector3(deg_to_rad(85), deg_to_rad(-30), deg_to_rad(15))],
		[Vector3(0.0, 0.18, -0.4), Vector3(deg_to_rad(85), deg_to_rad(60), 0)],
	]
	for spec in corpse_specs:
		var corpse: MeshInstance3D = MeshInstance3D.new()
		var cmesh: CapsuleMesh = CapsuleMesh.new()
		cmesh.radius = 0.32
		cmesh.height = 0.85
		corpse.mesh = cmesh
		corpse.position = spec[0]
		corpse.rotation = spec[1]
		corpse.material_override = corpse_mat
		pile.add_child(corpse)
	# Memorial banner stake
	var stake_mat: StandardMaterial3D = StandardMaterial3D.new()
	stake_mat.albedo_color = Color(0.18, 0.16, 0.14)
	stake_mat.metallic = 0.30
	var stake: MeshInstance3D = MeshInstance3D.new()
	var smesh: CylinderMesh = CylinderMesh.new()
	smesh.top_radius = 0.05
	smesh.bottom_radius = 0.05
	smesh.height = 1.40
	stake.mesh = smesh
	stake.position = Vector3(0, 0.70, 0.85)
	stake.material_override = stake_mat
	pile.add_child(stake)
	# Tiny banner cloth
	var banner: MeshInstance3D = MeshInstance3D.new()
	var bm: BoxMesh = BoxMesh.new()
	bm.size = Vector3(0.50, 0.30, 0.04)
	banner.mesh = bm
	banner.position = Vector3(0.30, 1.20, 0.85)
	var bmat: StandardMaterial3D = StandardMaterial3D.new()
	bmat.albedo_color = Color(0.55, 0.55, 0.65)
	bmat.emission_enabled = true
	bmat.emission = Color(0.65, 0.65, 0.75)
	bmat.emission_energy_multiplier = 0.55
	banner.material_override = bmat
	pile.add_child(banner)
	# Memorial text
	var label: Label3D = Label3D.new()
	label.text = "REMEMBER\nTHE FALLEN"
	label.position = Vector3(0, 1.70, 0.85)
	label.modulate = Color(0.85, 0.85, 0.95)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 4
	label.font_size = 13
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	pile.add_child(label)


func _build_d2_hover_truck_wreck(geom: Node) -> void:
	## Epic-2 T53: a much larger wrecked hover-truck blocking part of the
	## road. Long boxy body, 4 broken hover engines, cargo bay door open
	## with broken crates spilling out.
	var truck: Node3D = Node3D.new()
	truck.name = "D2HoverTruckWreck"
	truck.position = D2_CENTER + Vector3(8, 0, 4)
	truck.rotation = Vector3(0, deg_to_rad(40), deg_to_rad(-12))
	geom.add_child(truck)
	# Cab
	var cab_mat: StandardMaterial3D = StandardMaterial3D.new()
	cab_mat.albedo_color = Color(0.20, 0.22, 0.28)
	cab_mat.metallic = 0.85
	cab_mat.roughness = 0.40
	var cab: MeshInstance3D = MeshInstance3D.new()
	var cab_mesh: BoxMesh = BoxMesh.new()
	cab_mesh.size = Vector3(1.80, 1.20, 1.40)
	cab.mesh = cab_mesh
	cab.position = Vector3(2.20, 0.85, 0)
	cab.material_override = cab_mat
	truck.add_child(cab)
	# Cargo body — long box
	var cargo: MeshInstance3D = MeshInstance3D.new()
	var crmesh: BoxMesh = BoxMesh.new()
	crmesh.size = Vector3(3.40, 1.85, 1.85)
	cargo.mesh = crmesh
	cargo.position = Vector3(-0.50, 1.20, 0)
	cargo.material_override = cab_mat
	truck.add_child(cargo)
	# Cyan windshield
	var glass: MeshInstance3D = MeshInstance3D.new()
	var gmesh: BoxMesh = BoxMesh.new()
	gmesh.size = Vector3(0.10, 0.55, 1.20)
	glass.mesh = gmesh
	glass.position = Vector3(3.05, 1.20, 0)
	var gmat: StandardMaterial3D = StandardMaterial3D.new()
	gmat.albedo_color = Color(0.20, 0.50, 0.70, 0.55)
	gmat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	gmat.emission_enabled = true
	gmat.emission = Color(0.30, 0.85, 1.0)
	gmat.emission_energy_multiplier = 1.0
	gmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	glass.material_override = gmat
	truck.add_child(glass)
	# 4 hover engine pods underneath
	var engine_mat: StandardMaterial3D = StandardMaterial3D.new()
	engine_mat.albedo_color = Color(0.30, 0.10, 0.06)
	engine_mat.emission_enabled = true
	engine_mat.emission = Color(1.0, 0.40, 0.20)
	engine_mat.emission_energy_multiplier = 0.85
	engine_mat.metallic = 0.55
	for ox: float in [-1.5, 0.0, 1.5]:
		for oz: float in [-0.85, 0.85]:
			var pod: MeshInstance3D = MeshInstance3D.new()
			var pmesh: CylinderMesh = CylinderMesh.new()
			pmesh.top_radius = 0.20
			pmesh.bottom_radius = 0.30
			pmesh.height = 0.40
			pod.mesh = pmesh
			pod.position = Vector3(ox, 0.20, oz)
			pod.material_override = engine_mat
			truck.add_child(pod)
	# Cargo door open at the back — small angled panel
	var door: MeshInstance3D = MeshInstance3D.new()
	var door_mesh: BoxMesh = BoxMesh.new()
	door_mesh.size = Vector3(0.10, 1.85, 1.85)
	door.mesh = door_mesh
	door.position = Vector3(-2.30, 1.20, 0)
	door.rotation = Vector3(0, 0, deg_to_rad(45))
	door.material_override = cab_mat
	truck.add_child(door)
	# 3 spilled crates behind the truck
	var crate_mat: StandardMaterial3D = StandardMaterial3D.new()
	crate_mat.albedo_color = Color(0.30, 0.18, 0.08)
	crate_mat.metallic = 0.10
	crate_mat.roughness = 0.65
	for i in 3:
		var crate: MeshInstance3D = MeshInstance3D.new()
		var cmesh2: BoxMesh = BoxMesh.new()
		cmesh2.size = Vector3(0.55, 0.55, 0.55)
		crate.mesh = cmesh2
		crate.position = Vector3(-3.30 - i * 0.30, 0.30, randf_range(-0.55, 0.55))
		crate.rotation = Vector3(0, deg_to_rad(randf_range(-30, 30)), 0)
		crate.material_override = crate_mat
		truck.add_child(crate)
	# Collision around the cargo + cab
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(5.5, 2.4, 2.0)
	cs.shape = cb
	cs.position = Vector3(0.85, 1.20, 0)
	sb.add_child(cs)
	truck.add_child(sb)


func _build_d2_faction_wall(geom: Node) -> void:
	## Epic-2 T54: a tall stone faction wall painted with a glowing red
	## faction symbol (X inside a circle). Marks territory of "the
	## Outskirts gang".
	var wall: Node3D = Node3D.new()
	wall.name = "D2FactionWall"
	wall.position = D2_CENTER + Vector3(-22, 0, -2)
	geom.add_child(wall)
	# Wall slab
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.20, 0.16, 0.12)
	stone_mat.metallic = 0.30
	stone_mat.roughness = 0.65
	var slab: MeshInstance3D = MeshInstance3D.new()
	var smesh: BoxMesh = BoxMesh.new()
	smesh.size = Vector3(0.30, 4.0, 4.5)
	slab.mesh = smesh
	slab.position = Vector3(0, 2.0, 0)
	slab.material_override = stone_mat
	wall.add_child(slab)
	# Painted symbol — circle made of small box segments
	var sym_mat: StandardMaterial3D = StandardMaterial3D.new()
	sym_mat.albedo_color = Color(1.0, 0.20, 0.20)
	sym_mat.emission_enabled = true
	sym_mat.emission = Color(1.0, 0.30, 0.30)
	sym_mat.emission_energy_multiplier = 1.8
	sym_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	# Circle of 16 small boxes
	for i in 16:
		var angle: float = (float(i) / 16.0) * TAU
		var seg: MeshInstance3D = MeshInstance3D.new()
		var sgm: BoxMesh = BoxMesh.new()
		sgm.size = Vector3(0.06, 0.20, 0.20)
		seg.mesh = sgm
		seg.position = Vector3(0.16, 2.0 + cos(angle) * 1.20, sin(angle) * 1.20)
		seg.material_override = sym_mat
		wall.add_child(seg)
	# X across the circle (4 boxes forming 2 diagonal lines)
	for i in 2:
		var rot_z: float = deg_to_rad(45 if i == 0 else -45)
		var x_bar: MeshInstance3D = MeshInstance3D.new()
		var xm: BoxMesh = BoxMesh.new()
		xm.size = Vector3(0.06, 0.20, 2.40)
		x_bar.mesh = xm
		x_bar.position = Vector3(0.16, 2.0, 0)
		x_bar.rotation = Vector3(rot_z, 0, 0)
		x_bar.material_override = sym_mat
		wall.add_child(x_bar)
	# Faction name graffiti below
	var label: Label3D = Label3D.new()
	label.text = "OUTSKIRTS"
	label.position = Vector3(0.18, 0.55, 0)
	label.rotation = Vector3(0, deg_to_rad(90), 0)
	label.modulate = Color(1.0, 0.30, 0.30)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 26
	label.no_depth_test = true
	wall.add_child(label)
	# Collision
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(0.30, 4.0, 4.5)
	cs.shape = cb
	cs.position = Vector3(0, 2.0, 0)
	sb.add_child(cs)
	wall.add_child(sb)


func _build_d2_hacker_npc() -> void:
	## Epic-2 T55: a hacker NPC sitting cross-legged with 3 small floating
	## holographic screens around them. Hooded body, glowing green visor,
	## screens cycle through "code".
	var slots: Node3D = get_node_or_null("%NPCSlots") as Node3D
	if slots == null:
		return
	var hacker: Node3D = Node3D.new()
	hacker.name = "D2Hacker"
	hacker.position = D2_CENTER + Vector3(-6, 0, 8)
	slots.add_child(hacker)
	# Body — short capsule (sitting)
	var bmat: StandardMaterial3D = StandardMaterial3D.new()
	bmat.albedo_color = Color(0.10, 0.14, 0.10)
	bmat.metallic = 0.20
	bmat.roughness = 0.65
	var body: MeshInstance3D = MeshInstance3D.new()
	var bmesh: CapsuleMesh = CapsuleMesh.new()
	bmesh.radius = 0.40
	bmesh.height = 0.85
	body.mesh = bmesh
	body.position = Vector3(0, 0.45, 0)
	body.material_override = bmat
	hacker.add_child(body)
	# Hood
	var hood: MeshInstance3D = MeshInstance3D.new()
	var hmesh: SphereMesh = SphereMesh.new()
	hmesh.radius = 0.40
	hmesh.height = 0.55
	hood.mesh = hmesh
	hood.position = Vector3(0, 1.0, 0)
	hood.material_override = bmat
	hacker.add_child(hood)
	# Wide green visor strip
	var visor: MeshInstance3D = MeshInstance3D.new()
	var vmesh: BoxMesh = BoxMesh.new()
	vmesh.size = Vector3(0.50, 0.10, 0.04)
	visor.mesh = vmesh
	visor.position = Vector3(0, 0.95, 0.34)
	var vmat: StandardMaterial3D = StandardMaterial3D.new()
	vmat.albedo_color = Color(0.40, 1.0, 0.55)
	vmat.emission_enabled = true
	vmat.emission = Color(0.55, 1.0, 0.55)
	vmat.emission_energy_multiplier = 2.6
	vmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	visor.material_override = vmat
	hacker.add_child(visor)
	# 3 floating screens around the hacker
	var screen_mat: StandardMaterial3D = StandardMaterial3D.new()
	screen_mat.albedo_color = Color(0.04, 0.10, 0.06, 0.85)
	screen_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	screen_mat.emission_enabled = true
	screen_mat.emission = Color(0.40, 1.0, 0.55)
	screen_mat.emission_energy_multiplier = 1.0
	screen_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var screen_specs: Array = [
		[Vector3(-0.85, 1.40, 0.55), "0xFF\nMOV\nLDR"],
		[Vector3(0.85, 1.40, 0.55), "01010\nERROR\n404"],
		[Vector3(0.0, 1.85, 0.65), "ROOT\nGRANT"],
	]
	for spec in screen_specs:
		var screen: MeshInstance3D = MeshInstance3D.new()
		var sgm: BoxMesh = BoxMesh.new()
		sgm.size = Vector3(0.65, 0.45, 0.04)
		screen.mesh = sgm
		screen.position = spec[0]
		screen.material_override = screen_mat
		hacker.add_child(screen)
		# Code text on the screen
		var code: Label3D = Label3D.new()
		code.text = spec[1]
		code.position = (spec[0] as Vector3) + Vector3(0, 0, 0.04)
		code.modulate = Color(0.55, 1.0, 0.55)
		code.outline_size = 0
		code.font_size = 12
		code.no_depth_test = true
		code.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		hacker.add_child(code)
		# Bob screen
		var bob: Tween = create_tween().set_loops()
		var origin_y: float = (spec[0] as Vector3).y
		bob.tween_property(screen, "position:y", origin_y + 0.10, 1.4).set_ease(Tween.EASE_IN_OUT)
		bob.tween_property(screen, "position:y", origin_y, 1.4).set_ease(Tween.EASE_IN_OUT)
	# Name billboard
	var label: Label3D = Label3D.new()
	label.text = "Hacker"
	label.position = Vector3(0, 1.55, 0)
	label.modulate = Color(0.55, 1.0, 0.55)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 18
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	hacker.add_child(label)


func _build_d2_sniper_npc() -> void:
	## Epic-2 T56: a sniper NPC perched on top of the watchtower roof at
	## (D2_CENTER + 20, 0, -16). Crouched silhouette with a long rifle
	## scope visible, cyan laser sight projecting downward into the plaza.
	var slots: Node3D = get_node_or_null("%NPCSlots") as Node3D
	if slots == null:
		return
	var sniper: Node3D = Node3D.new()
	sniper.name = "D2Sniper"
	sniper.position = D2_CENTER + Vector3(20, 9.45, -16)
	slots.add_child(sniper)
	# Crouched body
	var bmat: StandardMaterial3D = StandardMaterial3D.new()
	bmat.albedo_color = Color(0.10, 0.13, 0.16)
	bmat.metallic = 0.30
	bmat.roughness = 0.55
	bmat.emission_enabled = true
	bmat.emission = Color(0.30, 0.30, 0.40)
	bmat.emission_energy_multiplier = 0.30
	var body: MeshInstance3D = MeshInstance3D.new()
	var bmesh: CapsuleMesh = CapsuleMesh.new()
	bmesh.radius = 0.30
	bmesh.height = 0.55
	body.mesh = bmesh
	body.position = Vector3(0, 0.30, 0)
	body.rotation = Vector3(deg_to_rad(20), 0, 0)
	body.material_override = bmat
	sniper.add_child(body)
	# Helmet
	var helmet: MeshInstance3D = MeshInstance3D.new()
	var hmesh: BoxMesh = BoxMesh.new()
	hmesh.size = Vector3(0.40, 0.30, 0.40)
	helmet.mesh = hmesh
	helmet.position = Vector3(0, 0.65, 0.10)
	helmet.material_override = bmat
	sniper.add_child(helmet)
	# Long rifle held in front
	var rifle_mat: StandardMaterial3D = StandardMaterial3D.new()
	rifle_mat.albedo_color = Color(0.05, 0.05, 0.10)
	rifle_mat.metallic = 0.85
	rifle_mat.roughness = 0.30
	var rifle: MeshInstance3D = MeshInstance3D.new()
	var rmesh: BoxMesh = BoxMesh.new()
	rmesh.size = Vector3(0.10, 0.10, 1.85)
	rifle.mesh = rmesh
	rifle.position = Vector3(0.20, 0.50, 0.50)
	rifle.rotation = Vector3(deg_to_rad(-15), deg_to_rad(10), 0)
	rifle.material_override = rifle_mat
	sniper.add_child(rifle)
	# Scope on top of rifle
	var scope: MeshInstance3D = MeshInstance3D.new()
	var sc_mesh: CylinderMesh = CylinderMesh.new()
	sc_mesh.top_radius = 0.06
	sc_mesh.bottom_radius = 0.06
	sc_mesh.height = 0.30
	scope.mesh = sc_mesh
	scope.position = Vector3(0.20, 0.62, 0.50)
	scope.rotation = Vector3(deg_to_rad(75), deg_to_rad(10), 0)
	scope.material_override = rifle_mat
	sniper.add_child(scope)
	# Cyan laser sight — long thin emissive line projecting forward + down
	var laser: MeshInstance3D = MeshInstance3D.new()
	var lmesh: BoxMesh = BoxMesh.new()
	lmesh.size = Vector3(0.02, 0.02, 14.0)
	laser.mesh = lmesh
	laser.position = Vector3(0.20, 0.30, -6.5)
	laser.rotation = Vector3(deg_to_rad(-25), deg_to_rad(15), 0)
	var lmat: StandardMaterial3D = StandardMaterial3D.new()
	lmat.albedo_color = Color(0.55, 0.95, 1.0)
	lmat.emission_enabled = true
	lmat.emission = Color(0.55, 0.95, 1.0)
	lmat.emission_energy_multiplier = 3.4
	lmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	laser.material_override = lmat
	sniper.add_child(laser)
	# Name billboard
	var label: Label3D = Label3D.new()
	label.text = "Sniper"
	label.position = Vector3(0, 1.20, 0)
	label.modulate = Color(0.55, 0.95, 1.0)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 16
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	sniper.add_child(label)


func _build_d2_treasure_chest(geom: Node) -> void:
	## Epic-2 T57: a locked treasure chest with a glowing combination dial
	## sitting in a hidden corner of the district. Made of dark metal with
	## a glowing amber rim around the lid.
	var chest: Node3D = Node3D.new()
	chest.name = "D2TreasureChest"
	chest.position = D2_CENTER + Vector3(-8, 0, -16)
	chest.rotation = Vector3(0, deg_to_rad(35), 0)
	geom.add_child(chest)
	var metal_mat: StandardMaterial3D = StandardMaterial3D.new()
	metal_mat.albedo_color = Color(0.16, 0.13, 0.10)
	metal_mat.metallic = 0.85
	metal_mat.roughness = 0.40
	# Body box
	var body: MeshInstance3D = MeshInstance3D.new()
	var bmesh: BoxMesh = BoxMesh.new()
	bmesh.size = Vector3(1.20, 0.65, 0.85)
	body.mesh = bmesh
	body.position = Vector3(0, 0.32, 0)
	body.material_override = metal_mat
	chest.add_child(body)
	# Lid (slightly raised box)
	var lid: MeshInstance3D = MeshInstance3D.new()
	var lmesh: BoxMesh = BoxMesh.new()
	lmesh.size = Vector3(1.25, 0.20, 0.90)
	lid.mesh = lmesh
	lid.position = Vector3(0, 0.75, 0)
	lid.material_override = metal_mat
	chest.add_child(lid)
	# Glowing amber rim around the lid edge
	var rim_mat: StandardMaterial3D = StandardMaterial3D.new()
	rim_mat.albedo_color = Color(1.0, 0.65, 0.20)
	rim_mat.emission_enabled = true
	rim_mat.emission = Color(1.0, 0.75, 0.25)
	rim_mat.emission_energy_multiplier = 1.8
	rim_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for spec in [
		[Vector3(0, 0.65, 0.45), Vector3(1.20, 0.06, 0.06)],
		[Vector3(0, 0.65, -0.45), Vector3(1.20, 0.06, 0.06)],
		[Vector3(-0.60, 0.65, 0), Vector3(0.06, 0.06, 0.85)],
		[Vector3(0.60, 0.65, 0), Vector3(0.06, 0.06, 0.85)],
	]:
		var seg: MeshInstance3D = MeshInstance3D.new()
		var sm: BoxMesh = BoxMesh.new()
		sm.size = spec[1]
		seg.mesh = sm
		seg.position = spec[0]
		seg.material_override = rim_mat
		chest.add_child(seg)
	# Combination dial on the front face
	var dial: MeshInstance3D = MeshInstance3D.new()
	var dmesh: CylinderMesh = CylinderMesh.new()
	dmesh.top_radius = 0.18
	dmesh.bottom_radius = 0.18
	dmesh.height = 0.06
	dial.mesh = dmesh
	dial.position = Vector3(0, 0.30, 0.45)
	dial.rotation = Vector3(deg_to_rad(90), 0, 0)
	var dmat: StandardMaterial3D = StandardMaterial3D.new()
	dmat.albedo_color = Color(0.85, 0.85, 0.95)
	dmat.metallic = 0.85
	dmat.roughness = 0.20
	dmat.emission_enabled = true
	dmat.emission = Color(1.0, 0.85, 0.30)
	dmat.emission_energy_multiplier = 0.85
	dial.material_override = dmat
	chest.add_child(dial)
	# Dial pointer needle
	var needle: MeshInstance3D = MeshInstance3D.new()
	var nm: BoxMesh = BoxMesh.new()
	nm.size = Vector3(0.04, 0.04, 0.16)
	needle.mesh = nm
	needle.position = Vector3(0, 0.30, 0.50)
	var nmat: StandardMaterial3D = StandardMaterial3D.new()
	nmat.albedo_color = Color(1.0, 0.30, 0.30)
	nmat.emission_enabled = true
	nmat.emission = Color(1.0, 0.40, 0.40)
	nmat.emission_energy_multiplier = 2.6
	nmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	needle.material_override = nmat
	chest.add_child(needle)
	# Slow needle rotation simulating "trying combinations"
	var spin: Tween = create_tween().set_loops()
	spin.tween_property(needle, "rotation:z", deg_to_rad(45), 1.4).set_ease(Tween.EASE_IN_OUT)
	spin.tween_interval(0.5)
	spin.tween_property(needle, "rotation:z", deg_to_rad(-90), 2.0).set_ease(Tween.EASE_IN_OUT)
	spin.tween_interval(0.5)
	spin.tween_property(needle, "rotation:z", 0.0, 1.4).set_ease(Tween.EASE_IN_OUT)
	# Label
	var label: Label3D = Label3D.new()
	label.text = "LOCKED"
	label.position = Vector3(0, 1.20, 0)
	label.modulate = Color(1.0, 0.65, 0.20)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 16
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	chest.add_child(label)
	# Collision
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(1.30, 0.95, 0.95)
	cs.shape = cb
	cs.position = Vector3(0, 0.45, 0)
	sb.add_child(cs)
	chest.add_child(sb)


func _build_d2_graveyard(geom: Node) -> void:
	## Epic-2 T58: a small graveyard plot with 5 simple stone markers
	## arranged in a row. Each marker has a different name on it.
	var grave: Node3D = Node3D.new()
	grave.name = "D2Graveyard"
	grave.position = D2_CENTER + Vector3(-10, 0, 18)
	geom.add_child(grave)
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.30, 0.32, 0.38)
	stone_mat.metallic = 0.30
	stone_mat.roughness = 0.55
	var names: Array[String] = ["BIT", "ECHO", "NULL", "FORGE", "PIXEL"]
	for i in names.size():
		var marker: Node3D = Node3D.new()
		marker.name = "Marker_%s" % names[i]
		marker.position = Vector3(-2.0 + i * 1.0, 0, 0)
		marker.rotation = Vector3(0, 0, deg_to_rad(randf_range(-8, 8)))
		grave.add_child(marker)
		# Tablet — flat box with rounded top (we use a box + sphere on top)
		var tablet: MeshInstance3D = MeshInstance3D.new()
		var tmesh: BoxMesh = BoxMesh.new()
		tmesh.size = Vector3(0.55, 0.85, 0.18)
		tablet.mesh = tmesh
		tablet.position = Vector3(0, 0.42, 0)
		tablet.material_override = stone_mat
		marker.add_child(tablet)
		# Top arch
		var arch: MeshInstance3D = MeshInstance3D.new()
		var amesh: SphereMesh = SphereMesh.new()
		amesh.radius = 0.27
		amesh.height = 0.30
		arch.mesh = amesh
		arch.position = Vector3(0, 0.85, 0)
		arch.scale = Vector3(1.0, 0.6, 0.4)
		arch.material_override = stone_mat
		marker.add_child(arch)
		# Name engraved
		var label: Label3D = Label3D.new()
		label.text = names[i]
		label.position = Vector3(0, 0.55, 0.10)
		label.modulate = Color(0.10, 0.10, 0.10)
		label.outline_size = 0
		label.font_size = 14
		label.no_depth_test = true
		marker.add_child(label)
	# Memorial sign behind the row
	var sign_label: Label3D = Label3D.new()
	sign_label.text = "FALLEN AGENTS"
	sign_label.position = Vector3(0, 1.85, -1.0)
	sign_label.modulate = Color(0.65, 0.65, 0.75)
	sign_label.outline_modulate = Color(0, 0, 0, 0.85)
	sign_label.outline_size = 5
	sign_label.font_size = 18
	sign_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	grave.add_child(sign_label)


func _build_d2_data_packets(geom: Node) -> void:
	## Epic-2 T59: 8 floating data packet "envelopes" drifting through the
	## district. Each is a small glowing cyan box with an emissive seal,
	## bobbing on independent paths through the air.
	var positions: Array[Vector3] = [
		D2_CENTER + Vector3(-15, 4.0, -10),
		D2_CENTER + Vector3(-5, 5.5, 0),
		D2_CENTER + Vector3(8, 4.5, -8),
		D2_CENTER + Vector3(18, 5.0, 4),
		D2_CENTER + Vector3(22, 4.5, 16),
		D2_CENTER + Vector3(0, 5.5, 12),
		D2_CENTER + Vector3(-10, 4.0, 6),
		D2_CENTER + Vector3(14, 5.0, -16),
	]
	for i in positions.size():
		var packet: MeshInstance3D = MeshInstance3D.new()
		packet.name = "D2DataPacket_%d" % i
		var pmesh: BoxMesh = BoxMesh.new()
		pmesh.size = Vector3(0.30, 0.20, 0.04)
		packet.mesh = pmesh
		packet.position = positions[i]
		var pmat: StandardMaterial3D = StandardMaterial3D.new()
		pmat.albedo_color = Color(0.85, 0.95, 1.0, 0.85)
		pmat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		pmat.emission_enabled = true
		pmat.emission = Color(0.55, 0.95, 1.0)
		pmat.emission_energy_multiplier = 1.6
		pmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		packet.material_override = pmat
		geom.add_child(packet)
		# Drift through random waypoints
		var origin: Vector3 = positions[i]
		var drift: Tween = create_tween().set_loops()
		var wp1: Vector3 = origin + Vector3(randf_range(-3, 3), randf_range(-1, 1), randf_range(-3, 3))
		var wp2: Vector3 = origin + Vector3(randf_range(-3, 3), randf_range(-1, 1), randf_range(-3, 3))
		drift.tween_property(packet, "position", wp1, 4.0).set_ease(Tween.EASE_IN_OUT)
		drift.tween_property(packet, "position", wp2, 4.0).set_ease(Tween.EASE_IN_OUT)
		drift.tween_property(packet, "position", origin, 4.0).set_ease(Tween.EASE_IN_OUT)
		# Tumble
		var tumble: Tween = create_tween().set_loops()
		tumble.tween_property(packet, "rotation", Vector3(TAU, TAU * 0.5, 0), 5.0)


func _build_d2_turret(geom: Node) -> void:
	## Epic-2 T60: a defensive automated turret on a base. Fixed to the
	## ground, with a slowly tracking barrel that sweeps left/right looking
	## for targets. Red blinking power indicator on the side.
	var turret: Node3D = Node3D.new()
	turret.name = "D2Turret"
	turret.position = D2_CENTER + Vector3(0, 0, -16)
	geom.add_child(turret)
	# Base pedestal
	var base_mat: StandardMaterial3D = StandardMaterial3D.new()
	base_mat.albedo_color = Color(0.16, 0.18, 0.22)
	base_mat.metallic = 0.85
	base_mat.roughness = 0.30
	var base: MeshInstance3D = MeshInstance3D.new()
	var bmesh: CylinderMesh = CylinderMesh.new()
	bmesh.top_radius = 0.55
	bmesh.bottom_radius = 0.65
	bmesh.height = 0.85
	base.mesh = bmesh
	base.position = Vector3(0, 0.42, 0)
	base.material_override = base_mat
	turret.add_child(base)
	# Pivot for rotating top
	var pivot: Node3D = Node3D.new()
	pivot.position = Vector3(0, 1.0, 0)
	turret.add_child(pivot)
	# Turret head — bigger box on the pivot
	var head: MeshInstance3D = MeshInstance3D.new()
	var hmesh: BoxMesh = BoxMesh.new()
	hmesh.size = Vector3(0.85, 0.55, 0.85)
	head.mesh = hmesh
	head.material_override = base_mat
	pivot.add_child(head)
	# 2 long barrels protruding from the front
	var barrel_mat: StandardMaterial3D = StandardMaterial3D.new()
	barrel_mat.albedo_color = Color(0.10, 0.10, 0.13)
	barrel_mat.metallic = 0.85
	barrel_mat.roughness = 0.30
	for sx: float in [-0.20, 0.20]:
		var barrel: MeshInstance3D = MeshInstance3D.new()
		var brmesh: CylinderMesh = CylinderMesh.new()
		brmesh.top_radius = 0.07
		brmesh.bottom_radius = 0.07
		brmesh.height = 1.20
		barrel.mesh = brmesh
		barrel.position = Vector3(sx, 0, 0.85)
		barrel.rotation = Vector3(deg_to_rad(90), 0, 0)
		barrel.material_override = barrel_mat
		pivot.add_child(barrel)
		# Glowing tip
		var tip: MeshInstance3D = MeshInstance3D.new()
		var tip_mesh: SphereMesh = SphereMesh.new()
		tip_mesh.radius = 0.08
		tip_mesh.height = 0.16
		tip.mesh = tip_mesh
		tip.position = Vector3(sx, 0, 1.45)
		var tip_mat: StandardMaterial3D = StandardMaterial3D.new()
		tip_mat.albedo_color = Color(1.0, 0.40, 0.20)
		tip_mat.emission_enabled = true
		tip_mat.emission = Color(1.0, 0.55, 0.20)
		tip_mat.emission_energy_multiplier = 2.4
		tip_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		tip.material_override = tip_mat
		pivot.add_child(tip)
	# Sweeping rotation
	var sweep: Tween = create_tween().set_loops()
	sweep.tween_property(pivot, "rotation:y", deg_to_rad(80), 4.0).set_ease(Tween.EASE_IN_OUT)
	sweep.tween_property(pivot, "rotation:y", deg_to_rad(-80), 4.0).set_ease(Tween.EASE_IN_OUT)
	# Red blinking power indicator on the base side
	var indicator: MeshInstance3D = MeshInstance3D.new()
	var im: SphereMesh = SphereMesh.new()
	im.radius = 0.08
	im.height = 0.16
	indicator.mesh = im
	indicator.position = Vector3(0.55, 0.55, 0)
	var imat: StandardMaterial3D = StandardMaterial3D.new()
	imat.albedo_color = Color(1.0, 0.20, 0.20)
	imat.emission_enabled = true
	imat.emission = Color(1.0, 0.30, 0.30)
	imat.emission_energy_multiplier = 2.6
	imat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	indicator.material_override = imat
	turret.add_child(indicator)
	var blink: Tween = create_tween().set_loops()
	blink.tween_property(indicator, "scale", Vector3(0.4, 0.4, 0.4), 0.4).set_ease(Tween.EASE_IN_OUT)
	blink.tween_property(indicator, "scale", Vector3(1.2, 1.2, 1.2), 0.4).set_ease(Tween.EASE_IN_OUT)
	# Collision around base
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(1.0, 1.85, 1.0)
	cs.shape = cb
	cs.position = Vector3(0, 0.92, 0)
	sb.add_child(cs)
	turret.add_child(sb)


func _build_d2_floating_debris(geom: Node) -> void:
	## Epic-2 T61: 8 large slabs of cracked architecture floating overhead
	## as if torn from a broken world. Each is a tilted slab on a slow
	## bobbing tween, scattered across the district.
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 88
	for i in 8:
		var slab: MeshInstance3D = MeshInstance3D.new()
		slab.name = "D2FloatingSlab_%d" % i
		var smesh: BoxMesh = BoxMesh.new()
		smesh.size = Vector3(rng.randf_range(1.4, 2.6), rng.randf_range(0.20, 0.55), rng.randf_range(1.4, 2.6))
		slab.mesh = smesh
		slab.position = D2_CENTER + Vector3(
			rng.randf_range(-22, 22),
			rng.randf_range(8, 14),
			rng.randf_range(-16, 16)
		)
		slab.rotation = Vector3(
			deg_to_rad(rng.randf_range(-25, 25)),
			deg_to_rad(rng.randf_range(0, 360)),
			deg_to_rad(rng.randf_range(-25, 25))
		)
		var mat: StandardMaterial3D = StandardMaterial3D.new()
		mat.albedo_color = Color(0.16, 0.13, 0.10)
		mat.metallic = 0.30
		mat.roughness = 0.65
		mat.emission_enabled = true
		mat.emission = Color(1.0, 0.40, 0.20)
		mat.emission_energy_multiplier = 0.30
		slab.material_override = mat
		geom.add_child(slab)
		# Slow bob + drift
		var origin: Vector3 = slab.position
		var bob: Tween = create_tween().set_loops()
		bob.tween_property(slab, "position", origin + Vector3(0, 0.55, 0), 2.4 + i * 0.2).set_ease(Tween.EASE_IN_OUT)
		bob.tween_property(slab, "position", origin, 2.4 + i * 0.2).set_ease(Tween.EASE_IN_OUT)
		# Slow lazy rotation
		var spin: Tween = create_tween().set_loops()
		spin.tween_property(slab, "rotation:y", slab.rotation.y + TAU, 16.0 + i * 1.5)


func _build_d2_power_lines(geom: Node) -> void:
	## Epic-2 T62: 3 suspended power lines running across the district from
	## tall metal poles. Each line is a thin sagging cylinder + small spark
	## that periodically slides along the wire.
	var pole_specs: Array = [
		[D2_CENTER + Vector3(-22, 0, -14), D2_CENTER + Vector3(22, 0, -14)],
		[D2_CENTER + Vector3(-22, 0, 0), D2_CENTER + Vector3(22, 0, 0)],
		[D2_CENTER + Vector3(-22, 0, 14), D2_CENTER + Vector3(22, 0, 14)],
	]
	var pole_mat: StandardMaterial3D = StandardMaterial3D.new()
	pole_mat.albedo_color = Color(0.10, 0.13, 0.16)
	pole_mat.metallic = 0.85
	pole_mat.roughness = 0.30
	for i in pole_specs.size():
		var from: Vector3 = pole_specs[i][0]
		var to: Vector3 = pole_specs[i][1]
		# 2 metal poles at the endpoints
		for endpoint in [from, to]:
			var pole: MeshInstance3D = MeshInstance3D.new()
			var pmesh: CylinderMesh = CylinderMesh.new()
			pmesh.top_radius = 0.10
			pmesh.bottom_radius = 0.14
			pmesh.height = 6.0
			pole.mesh = pmesh
			pole.position = endpoint + Vector3(0, 3.0, 0)
			pole.material_override = pole_mat
			geom.add_child(pole)
			# Cross arm
			var arm: MeshInstance3D = MeshInstance3D.new()
			var amesh: BoxMesh = BoxMesh.new()
			amesh.size = Vector3(1.40, 0.10, 0.10)
			arm.mesh = amesh
			arm.position = endpoint + Vector3(0, 5.85, 0)
			arm.material_override = pole_mat
			geom.add_child(arm)
			# Collision per pole
			var sb: StaticBody3D = StaticBody3D.new()
			var cs: CollisionShape3D = CollisionShape3D.new()
			var cap: CapsuleShape3D = CapsuleShape3D.new()
			cap.radius = 0.20
			cap.height = 6.0
			cs.shape = cap
			cs.position = endpoint + Vector3(0, 3.0, 0)
			sb.add_child(cs)
			geom.add_child(sb)
		# Power line — long thin cylinder slightly sagging at the middle
		var line: MeshInstance3D = MeshInstance3D.new()
		line.name = "D2PowerLine_%d" % i
		var dist: float = from.distance_to(to)
		var lmesh: CylinderMesh = CylinderMesh.new()
		lmesh.top_radius = 0.04
		lmesh.bottom_radius = 0.04
		lmesh.height = dist
		line.mesh = lmesh
		line.position = (from + to) * 0.5 + Vector3(0, 5.50, 0)
		line.rotation = Vector3(0, 0, deg_to_rad(90))
		var lmat: StandardMaterial3D = StandardMaterial3D.new()
		lmat.albedo_color = Color(0.05, 0.05, 0.10)
		lmat.metallic = 0.55
		line.material_override = lmat
		geom.add_child(line)
		# Spark traveling along the line
		var spark: MeshInstance3D = MeshInstance3D.new()
		var sm: SphereMesh = SphereMesh.new()
		sm.radius = 0.10
		sm.height = 0.20
		spark.mesh = sm
		spark.position = from + Vector3(0, 5.50, 0)
		var smat: StandardMaterial3D = StandardMaterial3D.new()
		smat.albedo_color = Color(0.55, 0.95, 1.0)
		smat.emission_enabled = true
		smat.emission = Color(0.55, 0.95, 1.0)
		smat.emission_energy_multiplier = 3.0
		smat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		spark.material_override = smat
		geom.add_child(spark)
		var travel: Tween = create_tween().set_loops()
		travel.tween_property(spark, "position", to + Vector3(0, 5.50, 0), 5.0 + i * 0.4).set_ease(Tween.EASE_IN_OUT)
		travel.tween_property(spark, "position", from + Vector3(0, 5.50, 0), 5.0 + i * 0.4).set_ease(Tween.EASE_IN_OUT)


func _build_d2_quarantine_zone(geom: Node) -> void:
	## Epic-2 T63: a quarantine zone marked off with yellow biohazard tape
	## stretched between 4 metal posts forming a square. Inside the zone,
	## a single sealed container with a hazard symbol.
	var zone: Node3D = Node3D.new()
	zone.name = "D2QuarantineZone"
	zone.position = D2_CENTER + Vector3(-15, 0, 0)
	geom.add_child(zone)
	var post_mat: StandardMaterial3D = StandardMaterial3D.new()
	post_mat.albedo_color = Color(0.10, 0.13, 0.16)
	post_mat.metallic = 0.85
	# 4 corner posts forming a 3x3 square
	var post_offsets: Array[Vector3] = [
		Vector3(-1.5, 0, -1.5),
		Vector3(1.5, 0, -1.5),
		Vector3(-1.5, 0, 1.5),
		Vector3(1.5, 0, 1.5),
	]
	for off in post_offsets:
		var post: MeshInstance3D = MeshInstance3D.new()
		var pmesh: CylinderMesh = CylinderMesh.new()
		pmesh.top_radius = 0.07
		pmesh.bottom_radius = 0.10
		pmesh.height = 1.40
		post.mesh = pmesh
		post.position = off + Vector3(0, 0.70, 0)
		post.material_override = post_mat
		zone.add_child(post)
	# Yellow biohazard tape between posts at 2 heights
	var tape_mat: StandardMaterial3D = StandardMaterial3D.new()
	tape_mat.albedo_color = Color(1.0, 0.85, 0.20)
	tape_mat.emission_enabled = true
	tape_mat.emission = Color(1.0, 0.95, 0.30)
	tape_mat.emission_energy_multiplier = 1.4
	tape_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	# 4 sides x 2 heights = 8 tape segments
	var tape_specs: Array = [
		[Vector3(0, 0, -1.5), Vector3(3.0, 0.10, 0.05)],
		[Vector3(0, 0, 1.5), Vector3(3.0, 0.10, 0.05)],
		[Vector3(-1.5, 0, 0), Vector3(0.05, 0.10, 3.0)],
		[Vector3(1.5, 0, 0), Vector3(0.05, 0.10, 3.0)],
	]
	for spec in tape_specs:
		for ty: float in [0.55, 1.10]:
			var tape: MeshInstance3D = MeshInstance3D.new()
			var tmesh: BoxMesh = BoxMesh.new()
			tmesh.size = spec[1]
			tape.mesh = tmesh
			var p: Vector3 = spec[0]
			p.y = ty
			tape.position = p
			tape.material_override = tape_mat
			zone.add_child(tape)
	# Sealed container at the center with hazard symbol
	var container_mat: StandardMaterial3D = StandardMaterial3D.new()
	container_mat.albedo_color = Color(0.18, 0.20, 0.24)
	container_mat.metallic = 0.85
	container_mat.roughness = 0.40
	var container: MeshInstance3D = MeshInstance3D.new()
	var cmesh: BoxMesh = BoxMesh.new()
	cmesh.size = Vector3(1.0, 0.85, 0.85)
	container.mesh = cmesh
	container.position = Vector3(0, 0.42, 0)
	container.material_override = container_mat
	zone.add_child(container)
	# Hazard symbol on the front
	var hazard: Label3D = Label3D.new()
	hazard.text = "☣"
	hazard.position = Vector3(0, 0.42, 0.45)
	hazard.modulate = Color(1.0, 0.95, 0.30)
	hazard.outline_modulate = Color(0, 0, 0, 0.85)
	hazard.outline_size = 4
	hazard.font_size = 36
	hazard.no_depth_test = true
	zone.add_child(hazard)
	# Sign
	var label: Label3D = Label3D.new()
	label.text = "QUARANTINE"
	label.position = Vector3(0, 1.85, 0)
	label.modulate = Color(1.0, 0.85, 0.20)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 18
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	zone.add_child(label)
	# Collision around container
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(1.0, 0.85, 0.85)
	cs.shape = cb
	cs.position = Vector3(0, 0.42, 0)
	sb.add_child(cs)
	zone.add_child(sb)


func _build_d2_lander_pod(geom: Node) -> void:
	## Epic-2 T64: a crashed lander pod — egg-shaped capsule with 4 landing
	## legs splayed outward, hatch open with a deployable ramp dropped to
	## the ground, glowing cyan interior visible.
	var pod: Node3D = Node3D.new()
	pod.name = "D2LanderPod"
	pod.position = D2_CENTER + Vector3(18, 0, 8)
	pod.rotation = Vector3(0, deg_to_rad(-30), deg_to_rad(8))
	geom.add_child(pod)
	# Capsule body
	var hull_mat: StandardMaterial3D = StandardMaterial3D.new()
	hull_mat.albedo_color = Color(0.55, 0.55, 0.65)
	hull_mat.metallic = 0.85
	hull_mat.roughness = 0.30
	var hull: MeshInstance3D = MeshInstance3D.new()
	var hmesh: SphereMesh = SphereMesh.new()
	hmesh.radius = 1.10
	hmesh.height = 2.80
	hull.mesh = hmesh
	hull.position = Vector3(0, 1.40, 0)
	hull.scale = Vector3(0.85, 1.0, 0.85)
	hull.material_override = hull_mat
	pod.add_child(hull)
	# 4 landing legs splayed
	var leg_mat: StandardMaterial3D = StandardMaterial3D.new()
	leg_mat.albedo_color = Color(0.10, 0.13, 0.16)
	leg_mat.metallic = 0.85
	leg_mat.roughness = 0.30
	for i in 4:
		var angle: float = (float(i) / 4.0) * TAU
		var leg: MeshInstance3D = MeshInstance3D.new()
		var lmesh: CylinderMesh = CylinderMesh.new()
		lmesh.top_radius = 0.10
		lmesh.bottom_radius = 0.14
		lmesh.height = 1.40
		leg.mesh = lmesh
		leg.position = Vector3(cos(angle) * 0.85, 0.45, sin(angle) * 0.85)
		# Splay outward
		leg.rotation = Vector3(sin(angle) * deg_to_rad(20), 0, -cos(angle) * deg_to_rad(20))
		leg.material_override = leg_mat
		pod.add_child(leg)
		# Foot pad
		var foot: MeshInstance3D = MeshInstance3D.new()
		var fmesh: CylinderMesh = CylinderMesh.new()
		fmesh.top_radius = 0.18
		fmesh.bottom_radius = 0.18
		fmesh.height = 0.06
		foot.mesh = fmesh
		foot.position = Vector3(cos(angle) * 1.20, 0.05, sin(angle) * 1.20)
		foot.material_override = leg_mat
		pod.add_child(foot)
	# Open hatch — flat box at the front rotated outward
	var hatch_mat: StandardMaterial3D = StandardMaterial3D.new()
	hatch_mat.albedo_color = Color(0.20, 0.50, 0.70, 0.55)
	hatch_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	hatch_mat.emission_enabled = true
	hatch_mat.emission = Color(0.55, 0.95, 1.0)
	hatch_mat.emission_energy_multiplier = 1.6
	hatch_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var hatch: MeshInstance3D = MeshInstance3D.new()
	var ha_mesh: BoxMesh = BoxMesh.new()
	ha_mesh.size = Vector3(1.20, 1.40, 0.06)
	hatch.mesh = ha_mesh
	hatch.position = Vector3(0.30, 1.40, 0.95)
	hatch.rotation = Vector3(0, deg_to_rad(60), 0)
	hatch.material_override = hatch_mat
	pod.add_child(hatch)
	# Ramp — long flat box from hatch to the ground
	var ramp: MeshInstance3D = MeshInstance3D.new()
	var rmesh: BoxMesh = BoxMesh.new()
	rmesh.size = Vector3(1.20, 0.06, 1.85)
	ramp.mesh = rmesh
	ramp.position = Vector3(0, 0.40, 1.85)
	ramp.rotation = Vector3(deg_to_rad(15), 0, 0)
	ramp.material_override = hull_mat
	pod.add_child(ramp)
	# Glowing cyan interior light visible through hatch
	var interior: OmniLight3D = OmniLight3D.new()
	interior.position = Vector3(0, 1.40, 0)
	interior.light_color = Color(0.55, 0.95, 1.0)
	interior.light_energy = 1.6
	interior.omni_range = 4.0
	pod.add_child(interior)
	# Collision around the body
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cap: CapsuleShape3D = CapsuleShape3D.new()
	cap.radius = 1.0
	cap.height = 2.40
	cs.shape = cap
	cs.position = Vector3(0, 1.40, 0)
	sb.add_child(cs)
	pod.add_child(sb)


func _build_d2_info_broker_npc() -> void:
	## Epic-2 T65: an info broker NPC standing behind a small data table
	## with a holographic file folder floating above it. The "trade
	## information for credits" archetype.
	var slots: Node3D = get_node_or_null("%NPCSlots") as Node3D
	if slots == null:
		return
	var broker: Node3D = Node3D.new()
	broker.name = "D2InfoBroker"
	broker.position = D2_CENTER + Vector3(-10, 0, -2)
	slots.add_child(broker)
	# Table
	var table_mat: StandardMaterial3D = StandardMaterial3D.new()
	table_mat.albedo_color = Color(0.18, 0.16, 0.12)
	table_mat.metallic = 0.40
	var table: MeshInstance3D = MeshInstance3D.new()
	var tmesh: BoxMesh = BoxMesh.new()
	tmesh.size = Vector3(1.20, 0.85, 0.55)
	table.mesh = tmesh
	table.position = Vector3(0, 0.42, 0.65)
	table.material_override = table_mat
	broker.add_child(table)
	# Floating holographic file folder above the table
	var folder: MeshInstance3D = MeshInstance3D.new()
	var fmesh: BoxMesh = BoxMesh.new()
	fmesh.size = Vector3(0.85, 0.55, 0.04)
	folder.mesh = fmesh
	folder.position = Vector3(0, 1.30, 0.65)
	var fmat: StandardMaterial3D = StandardMaterial3D.new()
	fmat.albedo_color = Color(0.95, 0.85, 0.30, 0.85)
	fmat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	fmat.emission_enabled = true
	fmat.emission = Color(1.0, 0.95, 0.40)
	fmat.emission_energy_multiplier = 1.8
	fmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	folder.material_override = fmat
	broker.add_child(folder)
	# Bob the folder
	var bob: Tween = create_tween().set_loops()
	bob.tween_property(folder, "position:y", 1.45, 1.4).set_ease(Tween.EASE_IN_OUT)
	bob.tween_property(folder, "position:y", 1.30, 1.4).set_ease(Tween.EASE_IN_OUT)
	# Slow rotation
	var spin: Tween = create_tween().set_loops()
	spin.tween_property(folder, "rotation:y", TAU, 6.0)
	# Body — slim figure
	var bmat: StandardMaterial3D = StandardMaterial3D.new()
	bmat.albedo_color = Color(0.20, 0.18, 0.30)
	bmat.metallic = 0.30
	bmat.roughness = 0.45
	bmat.emission_enabled = true
	bmat.emission = Color(0.40, 0.30, 0.85)
	bmat.emission_energy_multiplier = 0.30
	var body: MeshInstance3D = MeshInstance3D.new()
	var bmesh: CapsuleMesh = CapsuleMesh.new()
	bmesh.radius = 0.36
	bmesh.height = 1.30
	body.mesh = bmesh
	body.position = Vector3(0, 0.70, 0)
	body.material_override = bmat
	broker.add_child(body)
	# Top hat (small cylinder)
	var hat: MeshInstance3D = MeshInstance3D.new()
	var hmesh: CylinderMesh = CylinderMesh.new()
	hmesh.top_radius = 0.30
	hmesh.bottom_radius = 0.30
	hmesh.height = 0.45
	hat.mesh = hmesh
	hat.position = Vector3(0, 1.62, 0)
	var hmat: StandardMaterial3D = StandardMaterial3D.new()
	hmat.albedo_color = Color(0.05, 0.04, 0.10)
	hmat.metallic = 0.30
	hmat.roughness = 0.55
	hat.material_override = hmat
	broker.add_child(hat)
	# Hat brim
	var brim: MeshInstance3D = MeshInstance3D.new()
	var brmesh: CylinderMesh = CylinderMesh.new()
	brmesh.top_radius = 0.45
	brmesh.bottom_radius = 0.45
	brmesh.height = 0.05
	brim.mesh = brmesh
	brim.position = Vector3(0, 1.40, 0)
	brim.material_override = hmat
	broker.add_child(brim)
	# 2 yellow eyes
	var eye_mat: StandardMaterial3D = StandardMaterial3D.new()
	eye_mat.albedo_color = Color(1.0, 0.95, 0.30)
	eye_mat.emission_enabled = true
	eye_mat.emission = Color(1.0, 0.95, 0.30)
	eye_mat.emission_energy_multiplier = 2.6
	eye_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for ex: float in [-0.10, 0.10]:
		var eye: MeshInstance3D = MeshInstance3D.new()
		var em: SphereMesh = SphereMesh.new()
		em.radius = 0.06
		em.height = 0.12
		eye.mesh = em
		eye.position = Vector3(ex, 1.30, 0.30)
		eye.material_override = eye_mat
		broker.add_child(eye)
	# Name billboard
	var label: Label3D = Label3D.new()
	label.text = "Info Broker"
	label.position = Vector3(0, 2.10, 0)
	label.modulate = Color(1.0, 0.95, 0.30)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 18
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	broker.add_child(label)


func _build_d2_rune_pile(geom: Node) -> void:
	## Epic-2 T66: a pile of 8 glowing rune stones / data crystals stacked
	## haphazardly. Each is a prism with a different color tint, pulsing
	## emission at slightly different rates.
	var pile: Node3D = Node3D.new()
	pile.name = "D2RunePile"
	pile.position = D2_CENTER + Vector3(-12, 0, -12)
	geom.add_child(pile)
	var palette: Array[Color] = [
		Color(0.55, 0.95, 1.0),
		Color(1.0, 0.55, 0.20),
		Color(0.85, 0.40, 1.0),
		Color(0.40, 1.0, 0.55),
		Color(1.0, 0.95, 0.30),
		Color(0.30, 0.85, 1.0),
		Color(1.0, 0.30, 0.55),
		Color(0.55, 1.0, 0.85),
	]
	var stone_specs: Array = [
		Vector3(0, 0.30, 0),
		Vector3(0.55, 0.30, 0.20),
		Vector3(-0.45, 0.30, 0.30),
		Vector3(-0.20, 0.30, -0.55),
		Vector3(0.30, 0.30, -0.40),
		Vector3(0.0, 0.85, 0.0),
		Vector3(0.40, 0.85, -0.10),
		Vector3(-0.20, 0.85, 0.30),
	]
	for i in stone_specs.size():
		var stone: MeshInstance3D = MeshInstance3D.new()
		var smesh: PrismMesh = PrismMesh.new()
		smesh.size = Vector3(0.30, 0.65, 0.30)
		stone.mesh = smesh
		stone.position = stone_specs[i]
		stone.rotation = Vector3(0, deg_to_rad(randf_range(0, 360)), deg_to_rad(randf_range(-25, 25)))
		var color: Color = palette[i]
		var mat: StandardMaterial3D = StandardMaterial3D.new()
		mat.albedo_color = color
		mat.emission_enabled = true
		mat.emission = color
		mat.emission_energy_multiplier = 2.0
		mat.metallic = 0.40
		mat.roughness = 0.20
		mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		stone.material_override = mat
		pile.add_child(stone)
		# Pulse emission
		var pulse: Tween = create_tween().set_loops()
		var ps: float = 1.0 + i * 0.15
		pulse.tween_property(mat, "emission_energy_multiplier", 3.4, ps).set_ease(Tween.EASE_IN_OUT)
		pulse.tween_property(mat, "emission_energy_multiplier", 1.4, ps).set_ease(Tween.EASE_IN_OUT)
	# Sign
	var label: Label3D = Label3D.new()
	label.text = "RUNE PILE"
	label.position = Vector3(0, 1.85, 0)
	label.modulate = Color(0.85, 0.95, 1.0)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 16
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	pile.add_child(label)


func _build_d2_broken_clock(geom: Node) -> void:
	## Epic-2 T67: a tall broken clock tower with frozen hands. Stone
	## column with a clock face on each of 4 sides at the top, frozen at
	## different broken angles like time stopped here.
	var tower: Node3D = Node3D.new()
	tower.name = "D2BrokenClockTower"
	tower.position = D2_CENTER + Vector3(20, 0, -8)
	geom.add_child(tower)
	# Stone column
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.18, 0.16, 0.14)
	stone_mat.metallic = 0.30
	stone_mat.roughness = 0.65
	var col: MeshInstance3D = MeshInstance3D.new()
	var cmesh: BoxMesh = BoxMesh.new()
	cmesh.size = Vector3(1.40, 6.5, 1.40)
	col.mesh = cmesh
	col.position = Vector3(0, 3.25, 0)
	col.material_override = stone_mat
	tower.add_child(col)
	# Cracked stripe down one side
	var crack_mat: StandardMaterial3D = StandardMaterial3D.new()
	crack_mat.albedo_color = Color(1.0, 0.30, 0.20)
	crack_mat.emission_enabled = true
	crack_mat.emission = Color(1.0, 0.40, 0.20)
	crack_mat.emission_energy_multiplier = 1.4
	crack_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var crack: MeshInstance3D = MeshInstance3D.new()
	var cmesh2: BoxMesh = BoxMesh.new()
	cmesh2.size = Vector3(0.06, 5.5, 0.10)
	crack.mesh = cmesh2
	crack.position = Vector3(0.71, 3.0, 0)
	crack.rotation = Vector3(0, 0, deg_to_rad(8))
	crack.material_override = crack_mat
	tower.add_child(crack)
	# Crown — wider top block
	var crown: MeshInstance3D = MeshInstance3D.new()
	var crmesh: BoxMesh = BoxMesh.new()
	crmesh.size = Vector3(2.0, 2.0, 2.0)
	crown.mesh = crmesh
	crown.position = Vector3(0, 7.50, 0)
	crown.material_override = stone_mat
	tower.add_child(crown)
	# 4 clock faces (one on each side of the crown)
	var face_mat: StandardMaterial3D = StandardMaterial3D.new()
	face_mat.albedo_color = Color(0.85, 0.85, 0.95)
	face_mat.emission_enabled = true
	face_mat.emission = Color(1.0, 0.95, 0.85)
	face_mat.emission_energy_multiplier = 0.75
	face_mat.metallic = 0.20
	face_mat.roughness = 0.30
	var sides: Array[Vector3] = [
		Vector3(0, 0, 1.01),
		Vector3(0, 0, -1.01),
		Vector3(1.01, 0, 0),
		Vector3(-1.01, 0, 0),
	]
	for i in sides.size():
		var face: MeshInstance3D = MeshInstance3D.new()
		var fmesh: CylinderMesh = CylinderMesh.new()
		fmesh.top_radius = 0.65
		fmesh.bottom_radius = 0.65
		fmesh.height = 0.06
		face.mesh = fmesh
		face.position = sides[i] + Vector3(0, 7.50, 0)
		# Orient flat to the side
		if i < 2:
			face.rotation = Vector3(deg_to_rad(90), 0, 0)
		else:
			face.rotation = Vector3(0, 0, deg_to_rad(90))
		face.material_override = face_mat
		tower.add_child(face)
		# Hour hand (broken angle)
		var hour: MeshInstance3D = MeshInstance3D.new()
		var hmesh: BoxMesh = BoxMesh.new()
		hmesh.size = Vector3(0.06, 0.45, 0.04)
		hour.mesh = hmesh
		hour.position = sides[i] * 1.05 + Vector3(0, 7.50, 0)
		var hour_rot: float = deg_to_rad(45 + i * 60)
		if i < 2:
			hour.rotation = Vector3(deg_to_rad(90), 0, hour_rot)
		else:
			hour.rotation = Vector3(0, hour_rot, deg_to_rad(90))
		var hour_mat: StandardMaterial3D = StandardMaterial3D.new()
		hour_mat.albedo_color = Color(0.05, 0.05, 0.10)
		hour_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		hour.material_override = hour_mat
		tower.add_child(hour)
		# Minute hand
		var minute: MeshInstance3D = MeshInstance3D.new()
		var mm: BoxMesh = BoxMesh.new()
		mm.size = Vector3(0.04, 0.55, 0.04)
		minute.mesh = mm
		minute.position = sides[i] * 1.05 + Vector3(0, 7.50, 0)
		var min_rot: float = deg_to_rad(-30 + i * 90)
		if i < 2:
			minute.rotation = Vector3(deg_to_rad(90), 0, min_rot)
		else:
			minute.rotation = Vector3(0, min_rot, deg_to_rad(90))
		minute.material_override = hour_mat
		tower.add_child(minute)
	# Collision around tower
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(2.0, 8.5, 2.0)
	cs.shape = cb
	cs.position = Vector3(0, 4.25, 0)
	sb.add_child(cs)
	tower.add_child(sb)


func _build_d2_arrow_signs(geom: Node) -> void:
	## Epic-2 T68: 4 glowing directional arrow signs near the entrance arch
	## pointing toward key D2 landmarks (TRIAL PIT, MERC CAMP, ARCHIVE,
	## CAGE FIGHT). Each is a tilted post with an angled emissive arrow.
	var sign_root: Node3D = Node3D.new()
	sign_root.name = "D2ArrowSigns"
	sign_root.position = D2_CENTER + Vector3(-18, 0, -2)
	geom.add_child(sign_root)
	# 1 shared post
	var post_mat: StandardMaterial3D = StandardMaterial3D.new()
	post_mat.albedo_color = Color(0.10, 0.13, 0.16)
	post_mat.metallic = 0.85
	var post: MeshInstance3D = MeshInstance3D.new()
	var pmesh: CylinderMesh = CylinderMesh.new()
	pmesh.top_radius = 0.07
	pmesh.bottom_radius = 0.10
	pmesh.height = 3.4
	post.mesh = pmesh
	post.position = Vector3(0, 1.7, 0)
	post.material_override = post_mat
	sign_root.add_child(post)
	# 4 arrow signs at different heights, each pointing at a different yaw
	var sign_specs: Array = [
		["TRIAL PIT", Color(1.0, 0.40, 0.20), 2.85, deg_to_rad(45)],
		["MERC CAMP", Color(1.0, 0.65, 0.30), 2.40, deg_to_rad(135)],
		["ARMS DEALER", Color(0.85, 0.40, 1.0), 1.95, deg_to_rad(225)],
		["CAGE FIGHT", Color(0.55, 0.95, 1.0), 1.50, deg_to_rad(315)],
	]
	for spec in sign_specs:
		var arrow_pivot: Node3D = Node3D.new()
		arrow_pivot.position = Vector3(0, spec[2], 0)
		arrow_pivot.rotation = Vector3(0, spec[3], 0)
		sign_root.add_child(arrow_pivot)
		# Arrow board
		var arrow: MeshInstance3D = MeshInstance3D.new()
		var amesh: BoxMesh = BoxMesh.new()
		amesh.size = Vector3(0.04, 0.30, 1.40)
		arrow.mesh = amesh
		arrow.position = Vector3(0, 0, 0.85)
		var color: Color = spec[1]
		var amat: StandardMaterial3D = StandardMaterial3D.new()
		amat.albedo_color = Color(color.r * 0.40, color.g * 0.40, color.b * 0.40)
		amat.emission_enabled = true
		amat.emission = color
		amat.emission_energy_multiplier = 1.4
		amat.metallic = 0.30
		arrow.material_override = amat
		arrow_pivot.add_child(arrow)
		# Pointed tip prism
		var tip: MeshInstance3D = MeshInstance3D.new()
		var tmesh: PrismMesh = PrismMesh.new()
		tmesh.size = Vector3(0.30, 0.30, 0.06)
		tip.mesh = tmesh
		tip.position = Vector3(0, 0, 1.65)
		tip.rotation = Vector3(0, deg_to_rad(90), deg_to_rad(90))
		tip.material_override = amat
		arrow_pivot.add_child(tip)
		# Label on the arrow
		var label: Label3D = Label3D.new()
		label.text = spec[0]
		label.position = Vector3(0.05, 0, 0.85)
		label.modulate = Color(1, 1, 1)
		label.outline_modulate = Color(0, 0, 0, 0.85)
		label.outline_size = 4
		label.font_size = 14
		label.no_depth_test = true
		arrow_pivot.add_child(label)
	# Collision around the post
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cap: CapsuleShape3D = CapsuleShape3D.new()
	cap.radius = 0.20
	cap.height = 3.4
	cs.shape = cap
	cs.position = Vector3(0, 1.7, 0)
	sb.add_child(cs)
	sign_root.add_child(sb)


func _build_d2_zipline(geom: Node) -> void:
	## Epic-2 T69: a zipline cable strung diagonally between 2 tall scrap
	## towers, with a small handle slider that occasionally rides down it.
	var line_root: Node3D = Node3D.new()
	line_root.name = "D2Zipline"
	geom.add_child(line_root)
	var from_tower: Vector3 = D2_CENTER + Vector3(-22, 7.5, 12)  # top of scrap tower
	var to_tower: Vector3 = D2_CENTER + Vector3(20, 4.5, -16)   # top of watchtower
	var dist: float = from_tower.distance_to(to_tower)
	var mid: Vector3 = (from_tower + to_tower) * 0.5
	# Cable — long thin cylinder
	var cable: MeshInstance3D = MeshInstance3D.new()
	var cmesh: CylinderMesh = CylinderMesh.new()
	cmesh.top_radius = 0.04
	cmesh.bottom_radius = 0.04
	cmesh.height = dist
	cable.mesh = cmesh
	cable.position = mid
	# Orient along from->to direction
	var dir: Vector3 = (to_tower - from_tower).normalized()
	# Use look_at trick: rotate cylinder so its Y axis aligns with dir
	var basis: Basis = Basis(Quaternion(Vector3(0, 1, 0), dir))
	cable.basis = basis
	var cmat: StandardMaterial3D = StandardMaterial3D.new()
	cmat.albedo_color = Color(0.05, 0.05, 0.08)
	cmat.metallic = 0.85
	cmat.roughness = 0.30
	cable.material_override = cmat
	line_root.add_child(cable)
	# Handle slider — small box that rides along the cable
	var slider: MeshInstance3D = MeshInstance3D.new()
	var smesh: BoxMesh = BoxMesh.new()
	smesh.size = Vector3(0.30, 0.20, 0.30)
	slider.mesh = smesh
	slider.position = from_tower
	var smat: StandardMaterial3D = StandardMaterial3D.new()
	smat.albedo_color = Color(0.30, 0.35, 0.42)
	smat.metallic = 0.85
	smat.emission_enabled = true
	smat.emission = Color(1.0, 0.55, 0.20)
	smat.emission_energy_multiplier = 0.85
	slider.material_override = smat
	line_root.add_child(slider)
	# Travel tween — slider rides down the cable, resets, repeats
	var travel: Tween = create_tween().set_loops()
	travel.tween_property(slider, "position", to_tower, 3.5).set_ease(Tween.EASE_IN)
	travel.tween_interval(2.0)
	travel.tween_property(slider, "position", from_tower, 0.05)
	travel.tween_interval(1.0)


func _build_d2_mechanic_npc() -> void:
	## Epic-2 T70: mechanic NPC standing next to the repair workshop with
	## an oversized wrench in one hand and a tool belt around the waist.
	var slots: Node3D = get_node_or_null("%NPCSlots") as Node3D
	if slots == null:
		return
	var mech: Node3D = Node3D.new()
	mech.name = "D2Mechanic"
	mech.position = D2_CENTER + Vector3(-16, 0, 4)
	slots.add_child(mech)
	# Body — average capsule with overall blue tint
	var bmat: StandardMaterial3D = StandardMaterial3D.new()
	bmat.albedo_color = Color(0.20, 0.30, 0.40)
	bmat.metallic = 0.30
	bmat.roughness = 0.55
	bmat.emission_enabled = true
	bmat.emission = Color(0.30, 0.55, 0.85)
	bmat.emission_energy_multiplier = 0.30
	var body: MeshInstance3D = MeshInstance3D.new()
	var bmesh: CapsuleMesh = CapsuleMesh.new()
	bmesh.radius = 0.42
	bmesh.height = 1.20
	body.mesh = bmesh
	body.position = Vector3(0, 0.65, 0)
	body.material_override = bmat
	mech.add_child(body)
	# Tool belt — a thin amber band around the waist
	var belt: MeshInstance3D = MeshInstance3D.new()
	var belt_mesh: TorusMesh = TorusMesh.new()
	belt_mesh.inner_radius = 0.40
	belt_mesh.outer_radius = 0.45
	belt.mesh = belt_mesh
	belt.position = Vector3(0, 0.55, 0)
	var belt_mat: StandardMaterial3D = StandardMaterial3D.new()
	belt_mat.albedo_color = Color(0.85, 0.65, 0.20)
	belt_mat.metallic = 0.65
	belt_mat.roughness = 0.30
	belt_mat.emission_enabled = true
	belt_mat.emission = Color(1.0, 0.75, 0.25)
	belt_mat.emission_energy_multiplier = 0.85
	belt.material_override = belt_mat
	mech.add_child(belt)
	# Helmet
	var helmet: MeshInstance3D = MeshInstance3D.new()
	var hmesh: SphereMesh = SphereMesh.new()
	hmesh.radius = 0.40
	hmesh.height = 0.55
	helmet.mesh = hmesh
	helmet.position = Vector3(0, 1.45, 0)
	var hmat: StandardMaterial3D = StandardMaterial3D.new()
	hmat.albedo_color = Color(1.0, 0.55, 0.10)
	hmat.metallic = 0.30
	hmat.roughness = 0.55
	hmat.emission_enabled = true
	hmat.emission = Color(1.0, 0.65, 0.15)
	hmat.emission_energy_multiplier = 0.40
	helmet.material_override = hmat
	mech.add_child(helmet)
	# 2 cyan eyes
	var eye_mat: StandardMaterial3D = StandardMaterial3D.new()
	eye_mat.albedo_color = Color(0.55, 0.95, 1.0)
	eye_mat.emission_enabled = true
	eye_mat.emission = Color(0.55, 0.95, 1.0)
	eye_mat.emission_energy_multiplier = 2.6
	eye_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for ex: float in [-0.10, 0.10]:
		var eye: MeshInstance3D = MeshInstance3D.new()
		var em: SphereMesh = SphereMesh.new()
		em.radius = 0.05
		em.height = 0.10
		eye.mesh = em
		eye.position = Vector3(ex, 1.30, 0.30)
		eye.material_override = eye_mat
		mech.add_child(eye)
	# Oversized wrench (thin handle + chunky head)
	var wrench_handle: MeshInstance3D = MeshInstance3D.new()
	var wh_mesh: BoxMesh = BoxMesh.new()
	wh_mesh.size = Vector3(0.08, 1.40, 0.08)
	wrench_handle.mesh = wh_mesh
	wrench_handle.position = Vector3(0.55, 0.85, 0)
	wrench_handle.rotation = Vector3(0, 0, deg_to_rad(-30))
	var wmat: StandardMaterial3D = StandardMaterial3D.new()
	wmat.albedo_color = Color(0.20, 0.22, 0.28)
	wmat.metallic = 0.85
	wmat.roughness = 0.30
	wrench_handle.material_override = wmat
	mech.add_child(wrench_handle)
	var wrench_head: MeshInstance3D = MeshInstance3D.new()
	var wh2_mesh: BoxMesh = BoxMesh.new()
	wh2_mesh.size = Vector3(0.30, 0.30, 0.18)
	wrench_head.mesh = wh2_mesh
	wrench_head.position = Vector3(0.85, 1.50, 0)
	wrench_head.rotation = Vector3(0, 0, deg_to_rad(-30))
	wrench_head.material_override = wmat
	mech.add_child(wrench_head)
	# Idle wrench swing tween
	var swing: Tween = create_tween().set_loops()
	swing.tween_property(wrench_handle, "rotation:z", deg_to_rad(-15), 1.4).set_ease(Tween.EASE_IN_OUT)
	swing.tween_property(wrench_handle, "rotation:z", deg_to_rad(-30), 1.4).set_ease(Tween.EASE_IN_OUT)
	# Name billboard
	var label: Label3D = Label3D.new()
	label.text = "Mechanic"
	label.position = Vector3(0, 2.0, 0)
	label.modulate = Color(1.0, 0.65, 0.20)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 18
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	mech.add_child(label)


func _build_d2_parkour_course(geom: Node) -> void:
	## Epic-2 T71: a small parkour obstacle course in D2 — 4 jump pads of
	## ascending heights + 1 climb wall + a finish goal pad. Each pad has
	## glowing edge trim. Telegraphs traversal training without coding it.
	var course: Node3D = Node3D.new()
	course.name = "D2ParkourCourse"
	course.position = D2_CENTER + Vector3(-2, 0, 14)
	geom.add_child(course)
	var pad_mat: StandardMaterial3D = StandardMaterial3D.new()
	pad_mat.albedo_color = Color(0.16, 0.18, 0.22)
	pad_mat.metallic = 0.85
	pad_mat.roughness = 0.30
	var trim_mat: StandardMaterial3D = StandardMaterial3D.new()
	trim_mat.albedo_color = Color(0.55, 0.95, 1.0)
	trim_mat.emission_enabled = true
	trim_mat.emission = Color(0.55, 0.95, 1.0)
	trim_mat.emission_energy_multiplier = 1.8
	trim_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	# 4 jump pads at ascending heights
	for i in 4:
		var height: float = 0.5 + i * 0.45
		var pad: MeshInstance3D = MeshInstance3D.new()
		var pmesh: BoxMesh = BoxMesh.new()
		pmesh.size = Vector3(1.40, height, 1.40)
		pad.mesh = pmesh
		pad.position = Vector3(-3.0 + i * 1.85, height * 0.5, 0)
		pad.material_override = pad_mat
		course.add_child(pad)
		# Top trim ring (4 box edges)
		for spec in [
			[Vector3(0, height + 0.05, -0.70), Vector3(1.40, 0.06, 0.06)],
			[Vector3(0, height + 0.05, 0.70), Vector3(1.40, 0.06, 0.06)],
			[Vector3(-0.70, height + 0.05, 0), Vector3(0.06, 0.06, 1.40)],
			[Vector3(0.70, height + 0.05, 0), Vector3(0.06, 0.06, 1.40)],
		]:
			var edge: MeshInstance3D = MeshInstance3D.new()
			var em: BoxMesh = BoxMesh.new()
			em.size = spec[1]
			edge.mesh = em
			edge.position = Vector3(-3.0 + i * 1.85, 0, 0) + (spec[0] as Vector3)
			edge.material_override = trim_mat
			course.add_child(edge)
		# Per-pad collision
		var sb: StaticBody3D = StaticBody3D.new()
		var cs: CollisionShape3D = CollisionShape3D.new()
		var cb: BoxShape3D = BoxShape3D.new()
		cb.size = Vector3(1.40, height, 1.40)
		cs.shape = cb
		cs.position = Vector3(-3.0 + i * 1.85, height * 0.5, 0)
		sb.add_child(cs)
		course.add_child(sb)
	# Climb wall at the end
	var wall: MeshInstance3D = MeshInstance3D.new()
	var wmesh: BoxMesh = BoxMesh.new()
	wmesh.size = Vector3(2.40, 3.50, 0.30)
	wall.mesh = wmesh
	wall.position = Vector3(5.0, 1.75, 0)
	wall.material_override = pad_mat
	course.add_child(wall)
	# 6 hand-grip prisms across the wall
	for i in 6:
		var grip: MeshInstance3D = MeshInstance3D.new()
		var gmesh: PrismMesh = PrismMesh.new()
		gmesh.size = Vector3(0.20, 0.18, 0.18)
		grip.mesh = gmesh
		grip.position = Vector3(5.0 + (i % 2) * 0.40 - 0.20, 0.50 + i * 0.55, 0.18)
		grip.rotation = Vector3(0, 0, deg_to_rad(90))
		grip.material_override = trim_mat
		course.add_child(grip)
	# Wall collision
	var wsb: StaticBody3D = StaticBody3D.new()
	var wcs: CollisionShape3D = CollisionShape3D.new()
	var wcb: BoxShape3D = BoxShape3D.new()
	wcb.size = Vector3(2.40, 3.50, 0.30)
	wcs.shape = wcb
	wcs.position = Vector3(5.0, 1.75, 0)
	wsb.add_child(wcs)
	course.add_child(wsb)
	# Finish goal pad — bright green disc on the ground past the wall
	var goal: MeshInstance3D = MeshInstance3D.new()
	var gmesh: CylinderMesh = CylinderMesh.new()
	gmesh.top_radius = 0.85
	gmesh.bottom_radius = 0.85
	gmesh.height = 0.06
	goal.mesh = gmesh
	goal.position = Vector3(7.0, 0.05, 0)
	var gmat: StandardMaterial3D = StandardMaterial3D.new()
	gmat.albedo_color = Color(0.30, 1.0, 0.40)
	gmat.emission_enabled = true
	gmat.emission = Color(0.45, 1.0, 0.45)
	gmat.emission_energy_multiplier = 1.8
	gmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	goal.material_override = gmat
	course.add_child(goal)
	# "PARKOUR" sign overhead
	var label: Label3D = Label3D.new()
	label.text = "PARKOUR"
	label.position = Vector3(2.0, 4.40, 0)
	label.modulate = Color(0.55, 0.95, 1.0)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 22
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	course.add_child(label)


func _build_d2_debris_belt(geom: Node) -> void:
	## Epic-2 T72: orbiting debris belt — 12 small chunks of metal
	## arranged in a horizontal ring at high altitude, all rotating around
	## the D2 center on a shared pivot tween.
	var belt_pivot: Node3D = Node3D.new()
	belt_pivot.name = "D2DebrisBelt"
	belt_pivot.position = D2_CENTER + Vector3(0, 16, 0)
	geom.add_child(belt_pivot)
	var chunk_mat: StandardMaterial3D = StandardMaterial3D.new()
	chunk_mat.albedo_color = Color(0.18, 0.16, 0.14)
	chunk_mat.metallic = 0.85
	chunk_mat.roughness = 0.40
	chunk_mat.emission_enabled = true
	chunk_mat.emission = Color(1.0, 0.40, 0.20)
	chunk_mat.emission_energy_multiplier = 0.45
	for i in 12:
		var angle: float = (float(i) / 12.0) * TAU
		var radius: float = 18.0
		var chunk: MeshInstance3D = MeshInstance3D.new()
		chunk.name = "DebrisChunk_%d" % i
		var cmesh: BoxMesh = BoxMesh.new()
		cmesh.size = Vector3(randf_range(0.55, 0.95), randf_range(0.20, 0.40), randf_range(0.55, 0.95))
		chunk.mesh = cmesh
		chunk.position = Vector3(cos(angle) * radius, randf_range(-0.5, 0.5), sin(angle) * radius)
		chunk.rotation = Vector3(deg_to_rad(randf_range(-30, 30)), randf() * TAU, deg_to_rad(randf_range(-30, 30)))
		chunk.material_override = chunk_mat
		belt_pivot.add_child(chunk)
	# Shared pivot rotation tween
	var spin: Tween = create_tween().set_loops()
	spin.tween_property(belt_pivot, "rotation:y", TAU, 24.0)


func _build_d2_ruins(geom: Node) -> void:
	## Epic-2 T73: a cluster of ancient ruins — 4 broken stone pillars at
	## different heights + 1 partially intact arch (2 pillars + crumbling
	## lintel). Suggests this district once held an old structure.
	var ruins: Node3D = Node3D.new()
	ruins.name = "D2Ruins"
	ruins.position = D2_CENTER + Vector3(-12, 0, 12)
	geom.add_child(ruins)
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.30, 0.26, 0.22)
	stone_mat.metallic = 0.30
	stone_mat.roughness = 0.65
	# 4 broken pillars at different positions/heights
	var pillar_specs: Array = [
		[Vector3(-3.0, 0, -1.0), 2.40],
		[Vector3(-1.5, 0, 1.5), 1.85],
		[Vector3(0.5, 0, -1.5), 3.20],
		[Vector3(2.0, 0, 0.5), 2.10],
	]
	for spec in pillar_specs:
		var pos: Vector3 = spec[0]
		var height: float = spec[1]
		var pillar: MeshInstance3D = MeshInstance3D.new()
		var pmesh: CylinderMesh = CylinderMesh.new()
		pmesh.top_radius = 0.40
		pmesh.bottom_radius = 0.50
		pmesh.height = height
		pillar.mesh = pmesh
		pillar.position = pos + Vector3(0, height * 0.5, 0)
		pillar.rotation = Vector3(deg_to_rad(randf_range(-5, 5)), 0, deg_to_rad(randf_range(-5, 5)))
		pillar.material_override = stone_mat
		ruins.add_child(pillar)
		# Top "broken cap" — small angled cylinder
		var cap: MeshInstance3D = MeshInstance3D.new()
		var cmesh: CylinderMesh = CylinderMesh.new()
		cmesh.top_radius = 0.20
		cmesh.bottom_radius = 0.40
		cmesh.height = 0.30
		cap.mesh = cmesh
		cap.position = pos + Vector3(0, height + 0.15, 0)
		cap.rotation = Vector3(deg_to_rad(randf_range(-15, 15)), 0, deg_to_rad(randf_range(-15, 15)))
		cap.material_override = stone_mat
		ruins.add_child(cap)
		# Collision per pillar
		var sb: StaticBody3D = StaticBody3D.new()
		var cs: CollisionShape3D = CollisionShape3D.new()
		var cap_shape: CapsuleShape3D = CapsuleShape3D.new()
		cap_shape.radius = 0.50
		cap_shape.height = height
		cs.shape = cap_shape
		cs.position = pos + Vector3(0, height * 0.5, 0)
		sb.add_child(cs)
		ruins.add_child(sb)
	# Partially intact arch — 2 pillars + lintel
	for sx: float in [-4.5, -2.5]:
		var arch_pillar: MeshInstance3D = MeshInstance3D.new()
		var apm: BoxMesh = BoxMesh.new()
		apm.size = Vector3(0.55, 4.0, 0.55)
		arch_pillar.mesh = apm
		arch_pillar.position = Vector3(sx, 2.0, -3.5)
		arch_pillar.material_override = stone_mat
		ruins.add_child(arch_pillar)
		# Collision
		var sb: StaticBody3D = StaticBody3D.new()
		var cs: CollisionShape3D = CollisionShape3D.new()
		var cb: BoxShape3D = BoxShape3D.new()
		cb.size = Vector3(0.55, 4.0, 0.55)
		cs.shape = cb
		cs.position = Vector3(sx, 2.0, -3.5)
		sb.add_child(cs)
		ruins.add_child(sb)
	# Crumbling lintel — short slab on top with a missing chunk on one side
	var lintel: MeshInstance3D = MeshInstance3D.new()
	var lmesh: BoxMesh = BoxMesh.new()
	lmesh.size = Vector3(2.20, 0.55, 0.65)
	lintel.mesh = lmesh
	lintel.position = Vector3(-3.5, 4.30, -3.5)
	lintel.rotation = Vector3(0, 0, deg_to_rad(-3))
	lintel.material_override = stone_mat
	ruins.add_child(lintel)
	# Sign
	var label: Label3D = Label3D.new()
	label.text = "ANCIENT RUINS"
	label.position = Vector3(-3.5, 5.20, -3.5)
	label.modulate = Color(0.85, 0.85, 0.65)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 16
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	ruins.add_child(label)


func _build_d2_reality_tear(geom: Node) -> void:
	## Epic-2 T74: a vertical "reality tear" — a tall thin emissive rift
	## that the simulation has torn open. 3 stacked elongated boxes at
	## random Z offsets, glitching color tween. Magenta/cyan duotone.
	var tear: Node3D = Node3D.new()
	tear.name = "D2RealityTear"
	tear.position = D2_CENTER + Vector3(15, 0, -3)
	geom.add_child(tear)
	# 3 stacked rift segments
	for i in 3:
		var seg: MeshInstance3D = MeshInstance3D.new()
		var smesh: BoxMesh = BoxMesh.new()
		smesh.size = Vector3(0.30, 2.20, 0.06)
		seg.mesh = smesh
		seg.position = Vector3(randf_range(-0.20, 0.20), 1.10 + i * 2.0, randf_range(-0.20, 0.20))
		seg.rotation = Vector3(0, deg_to_rad(randf_range(-25, 25)), 0)
		var mat: StandardMaterial3D = StandardMaterial3D.new()
		mat.albedo_color = Color(1.0, 0.30, 0.55)
		mat.emission_enabled = true
		mat.emission = Color(1.0, 0.30, 0.55)
		mat.emission_energy_multiplier = 3.4
		mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		seg.material_override = mat
		tear.add_child(seg)
		# Color cycle tween between magenta and cyan
		var cycle: Tween = create_tween().set_loops()
		cycle.tween_property(mat, "emission", Color(0.55, 0.95, 1.0), 1.4 + i * 0.2).set_ease(Tween.EASE_IN_OUT)
		cycle.tween_property(mat, "emission", Color(1.0, 0.30, 0.55), 1.4 + i * 0.2).set_ease(Tween.EASE_IN_OUT)
		# Tiny visibility flicker for glitch feel
		var flicker: Tween = create_tween().set_loops()
		flicker.tween_interval(2.0 + randf() * 1.0)
		flicker.tween_property(seg, "visible", false, 0.0)
		flicker.tween_interval(0.05)
		flicker.tween_property(seg, "visible", true, 0.0)
	# Floating "RIFT" label
	var label: Label3D = Label3D.new()
	label.text = "RIFT"
	label.position = Vector3(0, 7.20, 0)
	label.modulate = Color(1.0, 0.40, 0.65)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 22
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	tear.add_child(label)


func _build_d2_glitch_rain(geom: Node) -> void:
	## Epic-2 T75: glitch rain — magenta GPU particles falling through D2
	## with light gravity, looking like distorted simulation rain.
	var rain: GPUParticles3D = GPUParticles3D.new()
	rain.name = "D2GlitchRain"
	rain.position = D2_CENTER + Vector3(0, 14, 0)
	rain.amount = 120
	rain.lifetime = 5.0
	rain.preprocess = 2.5
	var pmat: ParticleProcessMaterial = ParticleProcessMaterial.new()
	pmat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	pmat.emission_box_extents = Vector3(22, 0.5, 18)
	pmat.direction = Vector3(0, -1, 0)
	pmat.spread = 4.0
	pmat.initial_velocity_min = 1.4
	pmat.initial_velocity_max = 2.4
	pmat.gravity = Vector3(0, -2.0, 0)
	pmat.scale_min = 0.04
	pmat.scale_max = 0.10
	pmat.color = Color(1.0, 0.30, 0.55, 1.0)
	rain.process_material = pmat
	var drop_mesh: BoxMesh = BoxMesh.new()
	drop_mesh.size = Vector3(0.04, 0.18, 0.04)
	var drop_mat: StandardMaterial3D = StandardMaterial3D.new()
	drop_mat.albedo_color = Color(1.0, 0.30, 0.55)
	drop_mat.emission_enabled = true
	drop_mat.emission = Color(1.0, 0.40, 0.65)
	drop_mat.emission_energy_multiplier = 2.6
	drop_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	drop_mesh.material = drop_mat
	rain.draw_pass_1 = drop_mesh
	geom.add_child(rain)


func _build_d2_mail_terminal(geom: Node) -> void:
	## Epic-2 T76: a small mail / message terminal kiosk. Tall thin box
	## with a slot opening, an indicator light showing "new mail", and an
	## envelope icon Label3D on the front.
	var term: Node3D = Node3D.new()
	term.name = "D2MailTerminal"
	term.position = D2_CENTER + Vector3(-12, 0, -3)
	geom.add_child(term)
	# Body box
	var body_mat: StandardMaterial3D = StandardMaterial3D.new()
	body_mat.albedo_color = Color(0.20, 0.18, 0.30)
	body_mat.metallic = 0.65
	body_mat.roughness = 0.40
	body_mat.emission_enabled = true
	body_mat.emission = Color(0.40, 0.30, 0.85)
	body_mat.emission_energy_multiplier = 0.40
	var body: MeshInstance3D = MeshInstance3D.new()
	var bmesh: BoxMesh = BoxMesh.new()
	bmesh.size = Vector3(0.65, 1.85, 0.55)
	body.mesh = bmesh
	body.position = Vector3(0, 0.92, 0)
	body.material_override = body_mat
	term.add_child(body)
	# Mail slot — dark recess
	var slot: MeshInstance3D = MeshInstance3D.new()
	var smesh: BoxMesh = BoxMesh.new()
	smesh.size = Vector3(0.45, 0.10, 0.04)
	slot.mesh = smesh
	slot.position = Vector3(0, 1.40, 0.27)
	var smat: StandardMaterial3D = StandardMaterial3D.new()
	smat.albedo_color = Color(0.04, 0.04, 0.06)
	smat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	slot.material_override = smat
	term.add_child(slot)
	# "NEW MAIL" indicator light (small pulsing yellow sphere)
	var indicator: MeshInstance3D = MeshInstance3D.new()
	var im: SphereMesh = SphereMesh.new()
	im.radius = 0.06
	im.height = 0.12
	indicator.mesh = im
	indicator.position = Vector3(0, 1.62, 0.27)
	var imat: StandardMaterial3D = StandardMaterial3D.new()
	imat.albedo_color = Color(1.0, 0.95, 0.30)
	imat.emission_enabled = true
	imat.emission = Color(1.0, 0.95, 0.30)
	imat.emission_energy_multiplier = 2.6
	imat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	indicator.material_override = imat
	term.add_child(indicator)
	var pulse: Tween = create_tween().set_loops()
	pulse.tween_property(indicator, "scale", Vector3(1.4, 1.4, 1.4), 0.6).set_ease(Tween.EASE_IN_OUT)
	pulse.tween_property(indicator, "scale", Vector3(0.8, 0.8, 0.8), 0.6).set_ease(Tween.EASE_IN_OUT)
	# Envelope icon label on the front
	var icon: Label3D = Label3D.new()
	icon.text = "✉"
	icon.position = Vector3(0, 1.0, 0.30)
	icon.modulate = Color(1.0, 0.95, 0.55)
	icon.outline_modulate = Color(0, 0, 0, 0.85)
	icon.outline_size = 4
	icon.font_size = 28
	icon.no_depth_test = true
	term.add_child(icon)
	# Sign above
	var label: Label3D = Label3D.new()
	label.text = "MAIL"
	label.position = Vector3(0, 2.10, 0)
	label.modulate = Color(0.85, 0.75, 1.0)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 16
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	term.add_child(label)
	# Collision
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(0.65, 1.85, 0.55)
	cs.shape = cb
	cs.position = Vector3(0, 0.92, 0)
	sb.add_child(cs)
	term.add_child(sb)


func _build_d2_trading_post(geom: Node) -> void:
	## Epic-2 T77: a permanent trading post building — small storefront
	## hut with a sloped roof, a counter window cut into the front, and
	## glowing "OPEN" sign hanging beside it.
	var post: Node3D = Node3D.new()
	post.name = "D2TradingPost"
	post.position = D2_CENTER + Vector3(2, 0, -8)
	geom.add_child(post)
	# Walls — single wide box
	var wall_mat: StandardMaterial3D = StandardMaterial3D.new()
	wall_mat.albedo_color = Color(0.30, 0.22, 0.16)
	wall_mat.metallic = 0.20
	wall_mat.roughness = 0.65
	wall_mat.emission_enabled = true
	wall_mat.emission = Color(0.85, 0.55, 0.20)
	wall_mat.emission_energy_multiplier = 0.30
	var hut: MeshInstance3D = MeshInstance3D.new()
	var hmesh: BoxMesh = BoxMesh.new()
	hmesh.size = Vector3(3.40, 2.80, 2.40)
	hut.mesh = hmesh
	hut.position = Vector3(0, 1.40, 0)
	hut.material_override = wall_mat
	post.add_child(hut)
	# Sloped roof — prism on top
	var roof_mat: StandardMaterial3D = StandardMaterial3D.new()
	roof_mat.albedo_color = Color(0.45, 0.20, 0.12)
	roof_mat.metallic = 0.20
	roof_mat.roughness = 0.55
	var roof: MeshInstance3D = MeshInstance3D.new()
	var rmesh: PrismMesh = PrismMesh.new()
	rmesh.size = Vector3(3.60, 0.85, 2.60)
	roof.mesh = rmesh
	roof.position = Vector3(0, 3.20, 0)
	roof.material_override = roof_mat
	post.add_child(roof)
	# Counter window cut into front (a dark recessed box)
	var window: MeshInstance3D = MeshInstance3D.new()
	var wmesh: BoxMesh = BoxMesh.new()
	wmesh.size = Vector3(1.85, 0.85, 0.10)
	window.mesh = wmesh
	window.position = Vector3(0, 1.40, 1.21)
	var winmat: StandardMaterial3D = StandardMaterial3D.new()
	winmat.albedo_color = Color(0.05, 0.04, 0.10)
	winmat.emission_enabled = true
	winmat.emission = Color(0.85, 0.55, 0.20)
	winmat.emission_energy_multiplier = 0.55
	winmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	window.material_override = winmat
	post.add_child(window)
	# Counter board below the window
	var counter: MeshInstance3D = MeshInstance3D.new()
	var cmesh: BoxMesh = BoxMesh.new()
	cmesh.size = Vector3(2.0, 0.10, 0.45)
	counter.mesh = cmesh
	counter.position = Vector3(0, 0.95, 1.30)
	counter.material_override = roof_mat
	post.add_child(counter)
	# Hanging "OPEN" sign on the side
	var sign_panel: MeshInstance3D = MeshInstance3D.new()
	var sm: BoxMesh = BoxMesh.new()
	sm.size = Vector3(0.85, 0.40, 0.05)
	sign_panel.mesh = sm
	sign_panel.position = Vector3(1.85, 1.85, 1.0)
	var spmat: StandardMaterial3D = StandardMaterial3D.new()
	spmat.albedo_color = Color(0.30, 1.0, 0.40)
	spmat.emission_enabled = true
	spmat.emission = Color(0.45, 1.0, 0.45)
	spmat.emission_energy_multiplier = 1.6
	spmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	sign_panel.material_override = spmat
	post.add_child(sign_panel)
	var open_label: Label3D = Label3D.new()
	open_label.text = "OPEN"
	open_label.position = Vector3(1.85, 1.85, 1.04)
	open_label.modulate = Color(1, 1, 1)
	open_label.outline_modulate = Color(0, 0, 0, 0.85)
	open_label.outline_size = 4
	open_label.font_size = 16
	open_label.no_depth_test = true
	post.add_child(open_label)
	# Big "TRADING POST" sign on the roof
	var label: Label3D = Label3D.new()
	label.text = "TRADING POST"
	label.position = Vector3(0, 4.0, 0)
	label.modulate = Color(1.0, 0.85, 0.30)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 22
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	post.add_child(label)
	# Collision around the hut
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(3.40, 2.80, 2.40)
	cs.shape = cb
	cs.position = Vector3(0, 1.40, 0)
	sb.add_child(cs)
	post.add_child(sb)


func _build_d2_playground(geom: Node) -> void:
	## Epic-2 T78: an eerie abandoned playground — a single swing on a
	## rusty frame swaying gently in the wind + a small slide. The sense
	## of "kids used to live here" before the district fell.
	var play: Node3D = Node3D.new()
	play.name = "D2Playground"
	play.position = D2_CENTER + Vector3(-18, 0, 18)
	geom.add_child(play)
	var rust_mat: StandardMaterial3D = StandardMaterial3D.new()
	rust_mat.albedo_color = Color(0.40, 0.20, 0.10)
	rust_mat.metallic = 0.40
	rust_mat.roughness = 0.65
	# Swing frame — 2 angled legs + horizontal top bar
	for sx: float in [-1.20, 1.20]:
		var leg: MeshInstance3D = MeshInstance3D.new()
		var lmesh: CylinderMesh = CylinderMesh.new()
		lmesh.top_radius = 0.07
		lmesh.bottom_radius = 0.10
		lmesh.height = 2.40
		leg.mesh = lmesh
		leg.position = Vector3(sx, 1.20, 0)
		leg.rotation = Vector3(0, 0, sign(sx) * deg_to_rad(15))
		leg.material_override = rust_mat
		play.add_child(leg)
	# Top bar
	var top_bar: MeshInstance3D = MeshInstance3D.new()
	var tbmesh: CylinderMesh = CylinderMesh.new()
	tbmesh.top_radius = 0.06
	tbmesh.bottom_radius = 0.06
	tbmesh.height = 2.40
	top_bar.mesh = tbmesh
	top_bar.position = Vector3(0, 2.40, 0)
	top_bar.rotation = Vector3(0, 0, deg_to_rad(90))
	top_bar.material_override = rust_mat
	play.add_child(top_bar)
	# Swing pivot at top center
	var swing_pivot: Node3D = Node3D.new()
	swing_pivot.position = Vector3(0, 2.40, 0)
	play.add_child(swing_pivot)
	# Swing chains + seat
	for sx: float in [-0.30, 0.30]:
		var chain: MeshInstance3D = MeshInstance3D.new()
		var ch_mesh: CylinderMesh = CylinderMesh.new()
		ch_mesh.top_radius = 0.02
		ch_mesh.bottom_radius = 0.02
		ch_mesh.height = 1.30
		chain.mesh = ch_mesh
		chain.position = Vector3(sx, -0.65, 0)
		chain.material_override = rust_mat
		swing_pivot.add_child(chain)
	var seat: MeshInstance3D = MeshInstance3D.new()
	var seat_mesh: BoxMesh = BoxMesh.new()
	seat_mesh.size = Vector3(0.85, 0.06, 0.30)
	seat.mesh = seat_mesh
	seat.position = Vector3(0, -1.30, 0)
	var seat_mat: StandardMaterial3D = StandardMaterial3D.new()
	seat_mat.albedo_color = Color(0.20, 0.16, 0.12)
	seat_mat.metallic = 0.20
	seat.material_override = seat_mat
	swing_pivot.add_child(seat)
	# Sway tween
	var sway: Tween = create_tween().set_loops()
	sway.tween_property(swing_pivot, "rotation:x", deg_to_rad(15), 1.4).set_ease(Tween.EASE_IN_OUT)
	sway.tween_property(swing_pivot, "rotation:x", deg_to_rad(-15), 1.4).set_ease(Tween.EASE_IN_OUT)
	# Small slide nearby — angled box
	var slide: MeshInstance3D = MeshInstance3D.new()
	var sl_mesh: BoxMesh = BoxMesh.new()
	sl_mesh.size = Vector3(0.85, 0.10, 2.60)
	slide.mesh = sl_mesh
	slide.position = Vector3(3.5, 0.85, 0)
	slide.rotation = Vector3(deg_to_rad(-30), 0, 0)
	var sl_mat: StandardMaterial3D = StandardMaterial3D.new()
	sl_mat.albedo_color = Color(0.85, 0.85, 0.95)
	sl_mat.metallic = 0.65
	sl_mat.roughness = 0.30
	slide.material_override = sl_mat
	play.add_child(slide)
	# Slide top platform
	var platform: MeshInstance3D = MeshInstance3D.new()
	var pl_mesh: BoxMesh = BoxMesh.new()
	pl_mesh.size = Vector3(0.85, 0.10, 0.85)
	platform.mesh = pl_mesh
	platform.position = Vector3(3.5, 1.85, -1.20)
	platform.material_override = sl_mat
	play.add_child(platform)
	# Slide ladder (angled)
	var ladder: MeshInstance3D = MeshInstance3D.new()
	var ld_mesh: BoxMesh = BoxMesh.new()
	ld_mesh.size = Vector3(0.45, 0.06, 1.85)
	ladder.mesh = ld_mesh
	ladder.position = Vector3(3.5, 0.95, -1.85)
	ladder.rotation = Vector3(deg_to_rad(60), 0, 0)
	ladder.material_override = rust_mat
	play.add_child(ladder)


func _build_d2_data_scrolls(geom: Node) -> void:
	## Epic-2 T79: 5 floating data archive scrolls — vertical translucent
	## strips with code-like symbols on them, drifting in a small cluster
	## near the data well.
	var origin: Vector3 = D2_CENTER + Vector3(0, 1.5, 6)
	for i in 5:
		var scroll: MeshInstance3D = MeshInstance3D.new()
		scroll.name = "D2DataScroll_%d" % i
		var smesh: BoxMesh = BoxMesh.new()
		smesh.size = Vector3(0.30, 1.40, 0.04)
		scroll.mesh = smesh
		scroll.position = origin + Vector3(randf_range(-1.5, 1.5), randf_range(0, 0.85), randf_range(-1.5, 1.5))
		scroll.rotation = Vector3(0, deg_to_rad(randf_range(0, 360)), 0)
		var mat: StandardMaterial3D = StandardMaterial3D.new()
		mat.albedo_color = Color(0.55, 0.95, 1.0, 0.65)
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		mat.emission_enabled = true
		mat.emission = Color(0.55, 0.95, 1.0)
		mat.emission_energy_multiplier = 1.4
		mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		scroll.material_override = mat
		geom.add_child(scroll)
		# Slow rotation
		var spin: Tween = create_tween().set_loops()
		spin.tween_property(scroll, "rotation:y", scroll.rotation.y + TAU, 8.0 + i)
		# Slow vertical bob
		var bob: Tween = create_tween().set_loops()
		var origin_y: float = scroll.position.y
		bob.tween_property(scroll, "position:y", origin_y + 0.30, 1.6 + i * 0.2).set_ease(Tween.EASE_IN_OUT)
		bob.tween_property(scroll, "position:y", origin_y, 1.6 + i * 0.2).set_ease(Tween.EASE_IN_OUT)


func _build_d2_enchanter_npc() -> void:
	## Epic-2 T80: enchanter NPC standing with 4 small rune cubes orbiting
	## their head on a horizontal ring. Robed figure with a glowing violet
	## staff. The "magical" archetype contrasting the more mechanical NPCs.
	var slots: Node3D = get_node_or_null("%NPCSlots") as Node3D
	if slots == null:
		return
	var enc: Node3D = Node3D.new()
	enc.name = "D2Enchanter"
	enc.position = D2_CENTER + Vector3(8, 0, 8)
	slots.add_child(enc)
	# Body — robed capsule
	var bmat: StandardMaterial3D = StandardMaterial3D.new()
	bmat.albedo_color = Color(0.20, 0.10, 0.30)
	bmat.metallic = 0.30
	bmat.roughness = 0.55
	bmat.emission_enabled = true
	bmat.emission = Color(0.55, 0.30, 0.85)
	bmat.emission_energy_multiplier = 0.40
	var body: MeshInstance3D = MeshInstance3D.new()
	var bmesh: CapsuleMesh = CapsuleMesh.new()
	bmesh.radius = 0.45
	bmesh.height = 1.40
	body.mesh = bmesh
	body.position = Vector3(0, 0.70, 0)
	body.material_override = bmat
	enc.add_child(body)
	# Hood
	var hood: MeshInstance3D = MeshInstance3D.new()
	var hmesh: SphereMesh = SphereMesh.new()
	hmesh.radius = 0.45
	hmesh.height = 0.55
	hood.mesh = hmesh
	hood.position = Vector3(0, 1.55, 0)
	hood.material_override = bmat
	enc.add_child(hood)
	# 2 small violet eyes
	var eye_mat: StandardMaterial3D = StandardMaterial3D.new()
	eye_mat.albedo_color = Color(0.85, 0.40, 1.0)
	eye_mat.emission_enabled = true
	eye_mat.emission = Color(1.0, 0.55, 1.0)
	eye_mat.emission_energy_multiplier = 2.6
	eye_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for ex: float in [-0.10, 0.10]:
		var eye: MeshInstance3D = MeshInstance3D.new()
		var em: SphereMesh = SphereMesh.new()
		em.radius = 0.05
		em.height = 0.10
		eye.mesh = em
		eye.position = Vector3(ex, 1.40, 0.34)
		eye.material_override = eye_mat
		enc.add_child(eye)
	# Staff in front of the body — long thin cylinder
	var staff: MeshInstance3D = MeshInstance3D.new()
	var smesh: CylinderMesh = CylinderMesh.new()
	smesh.top_radius = 0.05
	smesh.bottom_radius = 0.06
	smesh.height = 2.0
	staff.mesh = smesh
	staff.position = Vector3(0.45, 1.0, 0)
	var stmat: StandardMaterial3D = StandardMaterial3D.new()
	stmat.albedo_color = Color(0.10, 0.06, 0.10)
	stmat.metallic = 0.30
	staff.material_override = stmat
	enc.add_child(staff)
	# Staff orb on top
	var orb: MeshInstance3D = MeshInstance3D.new()
	var om: SphereMesh = SphereMesh.new()
	om.radius = 0.20
	om.height = 0.40
	orb.mesh = om
	orb.position = Vector3(0.45, 2.10, 0)
	var omat: StandardMaterial3D = StandardMaterial3D.new()
	omat.albedo_color = Color(0.85, 0.40, 1.0)
	omat.emission_enabled = true
	omat.emission = Color(1.0, 0.55, 1.0)
	omat.emission_energy_multiplier = 2.6
	omat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	orb.material_override = omat
	enc.add_child(orb)
	# Pulse the orb
	var pulse: Tween = create_tween().set_loops()
	pulse.tween_property(orb, "scale", Vector3(1.30, 1.30, 1.30), 1.0).set_ease(Tween.EASE_IN_OUT)
	pulse.tween_property(orb, "scale", Vector3(1.0, 1.0, 1.0), 1.0).set_ease(Tween.EASE_IN_OUT)
	# 4 orbiting rune cubes — pivot at the head, cubes at TAU/4 spacings
	var rune_pivot: Node3D = Node3D.new()
	rune_pivot.position = Vector3(0, 2.10, 0)
	enc.add_child(rune_pivot)
	for i in 4:
		var angle: float = (float(i) / 4.0) * TAU
		var rune: MeshInstance3D = MeshInstance3D.new()
		var rmesh: BoxMesh = BoxMesh.new()
		rmesh.size = Vector3(0.18, 0.18, 0.18)
		rune.mesh = rmesh
		rune.position = Vector3(cos(angle) * 0.65, 0, sin(angle) * 0.65)
		var rmat: StandardMaterial3D = StandardMaterial3D.new()
		var color: Color = [Color(0.55, 0.95, 1.0), Color(1.0, 0.55, 0.20), Color(0.85, 0.40, 1.0), Color(0.45, 1.0, 0.55)][i]
		rmat.albedo_color = color
		rmat.emission_enabled = true
		rmat.emission = color
		rmat.emission_energy_multiplier = 2.4
		rmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		rune.material_override = rmat
		rune_pivot.add_child(rune)
	# Pivot rotation
	var spin: Tween = create_tween().set_loops()
	spin.tween_property(rune_pivot, "rotation:y", TAU, 4.0)
	# Name billboard
	var label: Label3D = Label3D.new()
	label.text = "Enchanter"
	label.position = Vector3(0, 2.55, 0)
	label.modulate = Color(0.85, 0.55, 1.0)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 18
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	enc.add_child(label)


func _build_d2_hospital_wing(geom: Node) -> void:
	## Epic-2 T81: a small hospital wing building next to the med tent.
	## Wider concrete structure with red cross emblem on the front + a
	## glowing entryway and 2 small upper windows.
	var wing: Node3D = Node3D.new()
	wing.name = "D2HospitalWing"
	wing.position = D2_CENTER + Vector3(-12, 0, 14)
	geom.add_child(wing)
	# Main building
	var wall_mat: StandardMaterial3D = StandardMaterial3D.new()
	wall_mat.albedo_color = Color(0.85, 0.85, 0.92)
	wall_mat.metallic = 0.20
	wall_mat.roughness = 0.55
	wall_mat.emission_enabled = true
	wall_mat.emission = Color(0.95, 0.95, 1.0)
	wall_mat.emission_energy_multiplier = 0.30
	var building: MeshInstance3D = MeshInstance3D.new()
	var bmesh: BoxMesh = BoxMesh.new()
	bmesh.size = Vector3(3.40, 3.20, 2.40)
	building.mesh = bmesh
	building.position = Vector3(0, 1.60, 0)
	building.material_override = wall_mat
	wing.add_child(building)
	# Flat roof slab
	var roof_mat: StandardMaterial3D = StandardMaterial3D.new()
	roof_mat.albedo_color = Color(0.55, 0.55, 0.65)
	roof_mat.metallic = 0.30
	var roof: MeshInstance3D = MeshInstance3D.new()
	var rmesh: BoxMesh = BoxMesh.new()
	rmesh.size = Vector3(3.65, 0.20, 2.65)
	roof.mesh = rmesh
	roof.position = Vector3(0, 3.30, 0)
	roof.material_override = roof_mat
	wing.add_child(roof)
	# Big red cross emblem on the front face
	var cross_mat: StandardMaterial3D = StandardMaterial3D.new()
	cross_mat.albedo_color = Color(1.0, 0.20, 0.20)
	cross_mat.emission_enabled = true
	cross_mat.emission = Color(1.0, 0.30, 0.30)
	cross_mat.emission_energy_multiplier = 1.8
	cross_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var v_bar: MeshInstance3D = MeshInstance3D.new()
	var vm: BoxMesh = BoxMesh.new()
	vm.size = Vector3(0.30, 1.40, 0.10)
	v_bar.mesh = vm
	v_bar.position = Vector3(0, 2.30, 1.21)
	v_bar.material_override = cross_mat
	wing.add_child(v_bar)
	var h_bar: MeshInstance3D = MeshInstance3D.new()
	var hm: BoxMesh = BoxMesh.new()
	hm.size = Vector3(1.0, 0.30, 0.10)
	h_bar.mesh = hm
	h_bar.position = Vector3(0, 2.30, 1.21)
	h_bar.material_override = cross_mat
	wing.add_child(h_bar)
	# Glowing entryway — dark recessed door with cyan light frame
	var door: MeshInstance3D = MeshInstance3D.new()
	var dmesh: BoxMesh = BoxMesh.new()
	dmesh.size = Vector3(0.85, 1.40, 0.10)
	door.mesh = dmesh
	door.position = Vector3(0, 0.80, 1.21)
	var dmat: StandardMaterial3D = StandardMaterial3D.new()
	dmat.albedo_color = Color(0.06, 0.10, 0.16)
	dmat.emission_enabled = true
	dmat.emission = Color(0.55, 0.95, 1.0)
	dmat.emission_energy_multiplier = 0.85
	dmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	door.material_override = dmat
	wing.add_child(door)
	# Door frame trim — 4 cyan emissive bars
	var trim_mat: StandardMaterial3D = StandardMaterial3D.new()
	trim_mat.albedo_color = Color(0.55, 0.95, 1.0)
	trim_mat.emission_enabled = true
	trim_mat.emission = Color(0.55, 0.95, 1.0)
	trim_mat.emission_energy_multiplier = 1.6
	trim_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for spec in [
		[Vector3(0, 0.10, 1.22), Vector3(0.95, 0.05, 0.04)],
		[Vector3(0, 1.50, 1.22), Vector3(0.95, 0.05, 0.04)],
		[Vector3(-0.45, 0.80, 1.22), Vector3(0.05, 1.40, 0.04)],
		[Vector3(0.45, 0.80, 1.22), Vector3(0.05, 1.40, 0.04)],
	]:
		var bar: MeshInstance3D = MeshInstance3D.new()
		var bmesh2: BoxMesh = BoxMesh.new()
		bmesh2.size = spec[1]
		bar.mesh = bmesh2
		bar.position = spec[0]
		bar.material_override = trim_mat
		wing.add_child(bar)
	# 2 upper window squares
	for sx: float in [-0.95, 0.95]:
		var win: MeshInstance3D = MeshInstance3D.new()
		var wm2: BoxMesh = BoxMesh.new()
		wm2.size = Vector3(0.55, 0.45, 0.04)
		win.mesh = wm2
		win.position = Vector3(sx, 2.85, 1.22)
		var wmat2: StandardMaterial3D = StandardMaterial3D.new()
		wmat2.albedo_color = Color(0.95, 0.85, 0.55)
		wmat2.emission_enabled = true
		wmat2.emission = Color(1.0, 0.85, 0.55)
		wmat2.emission_energy_multiplier = 1.4
		wmat2.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		win.material_override = wmat2
		wing.add_child(win)
	# Sign
	var label: Label3D = Label3D.new()
	label.text = "HOSPITAL"
	label.position = Vector3(0, 4.0, 0)
	label.modulate = Color(1.0, 0.30, 0.30)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 22
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	wing.add_child(label)
	# Collision around the building
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(3.40, 3.20, 2.40)
	cs.shape = cb
	cs.position = Vector3(0, 1.60, 0)
	sb.add_child(cs)
	wing.add_child(sb)


func _build_d2_garage(geom: Node) -> void:
	## Epic-2 T82: a garage building with an open roll-up door, revealing
	## a small hover-vehicle stored inside. Big rusty metal walls + slot
	## for the door + a half-built bike on the floor.
	var garage: Node3D = Node3D.new()
	garage.name = "D2Garage"
	garage.position = D2_CENTER + Vector3(-18, 0, -8)
	geom.add_child(garage)
	# Walls — concrete sides
	var wall_mat: StandardMaterial3D = StandardMaterial3D.new()
	wall_mat.albedo_color = Color(0.30, 0.30, 0.34)
	wall_mat.metallic = 0.30
	wall_mat.roughness = 0.65
	# Back wall
	var back: MeshInstance3D = MeshInstance3D.new()
	var bm: BoxMesh = BoxMesh.new()
	bm.size = Vector3(3.40, 2.85, 0.20)
	back.mesh = bm
	back.position = Vector3(0, 1.42, -1.20)
	back.material_override = wall_mat
	garage.add_child(back)
	# Side walls
	for sx: float in [-1.70, 1.70]:
		var side: MeshInstance3D = MeshInstance3D.new()
		var sm2: BoxMesh = BoxMesh.new()
		sm2.size = Vector3(0.20, 2.85, 2.60)
		side.mesh = sm2
		side.position = Vector3(sx, 1.42, 0)
		side.material_override = wall_mat
		garage.add_child(side)
	# Roof
	var roof: MeshInstance3D = MeshInstance3D.new()
	var rm: BoxMesh = BoxMesh.new()
	rm.size = Vector3(3.60, 0.20, 2.80)
	roof.mesh = rm
	roof.position = Vector3(0, 2.95, 0)
	roof.material_override = wall_mat
	garage.add_child(roof)
	# Half-rolled door — sits at the top of the front opening
	var door_mat: StandardMaterial3D = StandardMaterial3D.new()
	door_mat.albedo_color = Color(0.40, 0.20, 0.10)
	door_mat.metallic = 0.40
	door_mat.roughness = 0.55
	var door: MeshInstance3D = MeshInstance3D.new()
	var dm: BoxMesh = BoxMesh.new()
	dm.size = Vector3(3.40, 0.85, 0.10)
	door.mesh = dm
	door.position = Vector3(0, 2.40, 1.20)
	door.material_override = door_mat
	garage.add_child(door)
	# Half-built bike inside (small bike body box)
	var bike_mat: StandardMaterial3D = StandardMaterial3D.new()
	bike_mat.albedo_color = Color(0.20, 0.22, 0.28)
	bike_mat.metallic = 0.85
	bike_mat.roughness = 0.30
	var bike: MeshInstance3D = MeshInstance3D.new()
	var bk_mesh: BoxMesh = BoxMesh.new()
	bk_mesh.size = Vector3(1.40, 0.40, 0.55)
	bike.mesh = bk_mesh
	bike.position = Vector3(0, 0.30, -0.20)
	bike.rotation = Vector3(0, deg_to_rad(20), 0)
	bike.material_override = bike_mat
	garage.add_child(bike)
	# Bike engine glow
	var engine: MeshInstance3D = MeshInstance3D.new()
	var em: SphereMesh = SphereMesh.new()
	em.radius = 0.18
	em.height = 0.36
	engine.mesh = em
	engine.position = Vector3(-0.45, 0.30, -0.20)
	var emat: StandardMaterial3D = StandardMaterial3D.new()
	emat.albedo_color = Color(1.0, 0.40, 0.20)
	emat.emission_enabled = true
	emat.emission = Color(1.0, 0.55, 0.20)
	emat.emission_energy_multiplier = 2.4
	emat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	engine.material_override = emat
	garage.add_child(engine)
	# Sign
	var label: Label3D = Label3D.new()
	label.text = "GARAGE"
	label.position = Vector3(0, 3.55, 0)
	label.modulate = Color(1.0, 0.55, 0.20)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 18
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	garage.add_child(label)
	# Collision around walls
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(3.40, 2.85, 2.60)
	cs.shape = cb
	cs.position = Vector3(0, 1.42, 0)
	sb.add_child(cs)
	garage.add_child(sb)


func _build_d2_library_ruins(geom: Node) -> void:
	## Epic-2 T83: collapsed library — 3 broken bookshelf boxes leaning at
	## angles + 4 floating "data tomes" hovering above them. Lore element
	## telling "knowledge was destroyed here".
	var lib: Node3D = Node3D.new()
	lib.name = "D2LibraryRuins"
	lib.position = D2_CENTER + Vector3(6, 0, 16)
	geom.add_child(lib)
	# 3 shelves leaning
	var shelf_mat: StandardMaterial3D = StandardMaterial3D.new()
	shelf_mat.albedo_color = Color(0.30, 0.18, 0.10)
	shelf_mat.metallic = 0.10
	shelf_mat.roughness = 0.65
	var shelf_specs: Array = [
		[Vector3(-1.5, 1.10, 0), Vector3(0, 0, deg_to_rad(-12))],
		[Vector3(0, 1.10, 0.55), Vector3(0, deg_to_rad(15), deg_to_rad(8))],
		[Vector3(1.5, 1.10, -0.30), Vector3(0, deg_to_rad(-25), deg_to_rad(15))],
	]
	for spec in shelf_specs:
		var shelf: MeshInstance3D = MeshInstance3D.new()
		var smesh: BoxMesh = BoxMesh.new()
		smesh.size = Vector3(1.0, 2.20, 0.40)
		shelf.mesh = smesh
		shelf.position = spec[0]
		shelf.rotation = spec[1]
		shelf.material_override = shelf_mat
		lib.add_child(shelf)
		# 3 colored book "row" boxes inside the shelf
		for i in 3:
			var book_color: Color = [Color(0.55, 0.30, 0.30), Color(0.30, 0.55, 0.30), Color(0.30, 0.30, 0.55)][i]
			var book: MeshInstance3D = MeshInstance3D.new()
			var bk: BoxMesh = BoxMesh.new()
			bk.size = Vector3(0.85, 0.55, 0.30)
			book.mesh = bk
			book.position = (spec[0] as Vector3) + Vector3(0, -0.65 + i * 0.55, 0)
			book.rotation = spec[1]
			var bmat: StandardMaterial3D = StandardMaterial3D.new()
			bmat.albedo_color = book_color
			bmat.metallic = 0.10
			book.material_override = bmat
			lib.add_child(book)
		# Collision per shelf
		var sb: StaticBody3D = StaticBody3D.new()
		var cs: CollisionShape3D = CollisionShape3D.new()
		var cb: BoxShape3D = BoxShape3D.new()
		cb.size = Vector3(1.0, 2.20, 0.40)
		cs.shape = cb
		cs.position = spec[0]
		sb.add_child(cs)
		lib.add_child(sb)
	# 4 floating data tomes hovering above
	var tome_mat: StandardMaterial3D = StandardMaterial3D.new()
	tome_mat.albedo_color = Color(0.85, 0.40, 1.0)
	tome_mat.emission_enabled = true
	tome_mat.emission = Color(1.0, 0.55, 1.0)
	tome_mat.emission_energy_multiplier = 1.8
	tome_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for i in 4:
		var tome: MeshInstance3D = MeshInstance3D.new()
		var tmesh: BoxMesh = BoxMesh.new()
		tmesh.size = Vector3(0.40, 0.30, 0.10)
		tome.mesh = tmesh
		var origin_y: float = 3.0 + (i % 2) * 0.55
		tome.position = Vector3(-1.5 + i * 0.85, origin_y, 0)
		tome.material_override = tome_mat
		lib.add_child(tome)
		# Bob + spin
		var bob: Tween = create_tween().set_loops()
		bob.tween_property(tome, "position:y", origin_y + 0.30, 1.4 + i * 0.15).set_ease(Tween.EASE_IN_OUT)
		bob.tween_property(tome, "position:y", origin_y, 1.4 + i * 0.15).set_ease(Tween.EASE_IN_OUT)
		var spin: Tween = create_tween().set_loops()
		spin.tween_property(tome, "rotation:y", TAU, 6.0)
	# Sign
	var label: Label3D = Label3D.new()
	label.text = "LIBRARY RUINS"
	label.position = Vector3(0, 4.40, 0)
	label.modulate = Color(0.85, 0.65, 1.0)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 16
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	lib.add_child(label)


func _build_d2_gargoyles(geom: Node) -> void:
	## Epic-2 T84: 4 gargoyle statues guarding the trading post. Each is a
	## small dark figure crouched on a pedestal with red eyes. Decorative
	## ward-like flavor.
	var positions: Array[Vector3] = [
		D2_CENTER + Vector3(0, 0, -6),
		D2_CENTER + Vector3(4, 0, -6),
		D2_CENTER + Vector3(0, 0, -10),
		D2_CENTER + Vector3(4, 0, -10),
	]
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.16, 0.14, 0.18)
	stone_mat.metallic = 0.30
	stone_mat.roughness = 0.65
	var eye_mat: StandardMaterial3D = StandardMaterial3D.new()
	eye_mat.albedo_color = Color(1.0, 0.20, 0.20)
	eye_mat.emission_enabled = true
	eye_mat.emission = Color(1.0, 0.30, 0.30)
	eye_mat.emission_energy_multiplier = 2.6
	eye_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for i in positions.size():
		var garg: Node3D = Node3D.new()
		garg.name = "D2Gargoyle_%d" % i
		garg.position = positions[i]
		garg.rotation = Vector3(0, deg_to_rad(45 + i * 90), 0)
		geom.add_child(garg)
		# Pedestal
		var ped: MeshInstance3D = MeshInstance3D.new()
		var pmesh: BoxMesh = BoxMesh.new()
		pmesh.size = Vector3(0.65, 0.65, 0.65)
		ped.mesh = pmesh
		ped.position = Vector3(0, 0.32, 0)
		ped.material_override = stone_mat
		garg.add_child(ped)
		# Body — crouched cube
		var body: MeshInstance3D = MeshInstance3D.new()
		var bm2: BoxMesh = BoxMesh.new()
		bm2.size = Vector3(0.45, 0.45, 0.55)
		body.mesh = bm2
		body.position = Vector3(0, 0.85, 0)
		body.material_override = stone_mat
		garg.add_child(body)
		# Head
		var head: MeshInstance3D = MeshInstance3D.new()
		var hmesh: BoxMesh = BoxMesh.new()
		hmesh.size = Vector3(0.35, 0.30, 0.35)
		head.mesh = hmesh
		head.position = Vector3(0, 1.20, 0.10)
		head.material_override = stone_mat
		garg.add_child(head)
		# 2 red eyes
		for ex: float in [-0.07, 0.07]:
			var eye: MeshInstance3D = MeshInstance3D.new()
			var em: SphereMesh = SphereMesh.new()
			em.radius = 0.04
			em.height = 0.08
			eye.mesh = em
			eye.position = Vector3(ex, 1.22, 0.28)
			eye.material_override = eye_mat
			garg.add_child(eye)
		# Wing on top of body (small angled box)
		for sx: float in [-0.30, 0.30]:
			var wing: MeshInstance3D = MeshInstance3D.new()
			var wmesh: BoxMesh = BoxMesh.new()
			wmesh.size = Vector3(0.10, 0.45, 0.20)
			wing.mesh = wmesh
			wing.position = Vector3(sx, 1.10, -0.10)
			wing.rotation = Vector3(0, 0, sign(sx) * deg_to_rad(20))
			wing.material_override = stone_mat
			garg.add_child(wing)
		# Collision per gargoyle
		var sb: StaticBody3D = StaticBody3D.new()
		var cs: CollisionShape3D = CollisionShape3D.new()
		var cb: BoxShape3D = BoxShape3D.new()
		cb.size = Vector3(0.65, 1.40, 0.65)
		cs.shape = cb
		cs.position = Vector3(0, 0.70, 0)
		sb.add_child(cs)
		garg.add_child(sb)


func _build_d2_boss_arena_teaser(geom: Node) -> void:
	## Epic-2 T85: a massive shadowed boss arena teaser at the far east
	## edge of D2 — a wide circular ring of dark stone pillars surrounding
	## a glowing red rune-circle in the center. Tells the player "the
	## final boss lives here, but is asleep". Telegraphs Epic 3.
	var arena: Node3D = Node3D.new()
	arena.name = "D2BossArenaTeaser"
	arena.position = D2_CENTER + Vector3(28, 0, 0)
	geom.add_child(arena)
	# Big circular floor disc — dark amber emissive
	var floor_mat: StandardMaterial3D = StandardMaterial3D.new()
	floor_mat.albedo_color = Color(0.10, 0.04, 0.04)
	floor_mat.metallic = 0.45
	floor_mat.roughness = 0.55
	floor_mat.emission_enabled = true
	floor_mat.emission = Color(0.85, 0.20, 0.20)
	floor_mat.emission_energy_multiplier = 0.45
	var floor_disc: MeshInstance3D = MeshInstance3D.new()
	var fmesh: CylinderMesh = CylinderMesh.new()
	fmesh.top_radius = 6.0
	fmesh.bottom_radius = 6.0
	fmesh.height = 0.10
	floor_disc.mesh = fmesh
	floor_disc.position = Vector3(0, 0.06, 0)
	floor_disc.material_override = floor_mat
	arena.add_child(floor_disc)
	# 8 dark stone pillars in a ring
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.10, 0.10, 0.13)
	stone_mat.metallic = 0.55
	stone_mat.roughness = 0.45
	stone_mat.emission_enabled = true
	stone_mat.emission = Color(1.0, 0.20, 0.30)
	stone_mat.emission_energy_multiplier = 0.45
	for i in 8:
		var angle: float = (float(i) / 8.0) * TAU
		var pillar: MeshInstance3D = MeshInstance3D.new()
		var pmesh: BoxMesh = BoxMesh.new()
		pmesh.size = Vector3(0.85, 6.0, 0.85)
		pillar.mesh = pmesh
		pillar.position = Vector3(cos(angle) * 5.5, 3.0, sin(angle) * 5.5)
		pillar.material_override = stone_mat
		arena.add_child(pillar)
		# Top emissive crown
		var crown: MeshInstance3D = MeshInstance3D.new()
		var cm: SphereMesh = SphereMesh.new()
		cm.radius = 0.30
		cm.height = 0.60
		crown.mesh = cm
		crown.position = Vector3(cos(angle) * 5.5, 6.30, sin(angle) * 5.5)
		var cmat: StandardMaterial3D = StandardMaterial3D.new()
		cmat.albedo_color = Color(1.0, 0.30, 0.30)
		cmat.emission_enabled = true
		cmat.emission = Color(1.0, 0.40, 0.40)
		cmat.emission_energy_multiplier = 2.6
		cmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		crown.material_override = cmat
		arena.add_child(crown)
		# Collision per pillar
		var sb: StaticBody3D = StaticBody3D.new()
		var cs: CollisionShape3D = CollisionShape3D.new()
		var cb: BoxShape3D = BoxShape3D.new()
		cb.size = Vector3(0.85, 6.0, 0.85)
		cs.shape = cb
		cs.position = Vector3(cos(angle) * 5.5, 3.0, sin(angle) * 5.5)
		sb.add_child(cs)
		arena.add_child(sb)
	# Center rune circle — 3 concentric pulsing torus rings
	for r in 3:
		var ring: MeshInstance3D = MeshInstance3D.new()
		var rmesh: TorusMesh = TorusMesh.new()
		rmesh.inner_radius = 1.0 + r * 0.55
		rmesh.outer_radius = 1.20 + r * 0.55
		ring.mesh = rmesh
		ring.position = Vector3(0, 0.12, 0)
		var rmat: StandardMaterial3D = StandardMaterial3D.new()
		rmat.albedo_color = Color(1.0, 0.20, 0.20)
		rmat.emission_enabled = true
		rmat.emission = Color(1.0, 0.30, 0.30)
		rmat.emission_energy_multiplier = 2.4
		rmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		ring.material_override = rmat
		arena.add_child(ring)
		# Pulse the ring scale outward
		var pulse: Tween = create_tween().set_loops()
		pulse.tween_property(ring, "scale", Vector3(1.10, 1.0, 1.10), 1.8 + r * 0.3).set_ease(Tween.EASE_IN_OUT)
		pulse.tween_property(ring, "scale", Vector3(0.92, 1.0, 0.92), 1.8 + r * 0.3).set_ease(Tween.EASE_IN_OUT)
	# Center marker — small dark sphere on the rune circle
	var marker: MeshInstance3D = MeshInstance3D.new()
	var mm: SphereMesh = SphereMesh.new()
	mm.radius = 0.40
	mm.height = 0.80
	marker.mesh = mm
	marker.position = Vector3(0, 0.50, 0)
	var marker_mat: StandardMaterial3D = StandardMaterial3D.new()
	marker_mat.albedo_color = Color(0.04, 0.04, 0.06)
	marker_mat.metallic = 0.85
	marker_mat.emission_enabled = true
	marker_mat.emission = Color(1.0, 0.20, 0.20)
	marker_mat.emission_energy_multiplier = 0.85
	marker.material_override = marker_mat
	arena.add_child(marker)
	# Boss-tier name billboard
	var label: Label3D = Label3D.new()
	label.text = "BOSS ARENA\n— ASLEEP —"
	label.position = Vector3(0, 8.0, 0)
	label.modulate = Color(1.0, 0.30, 0.30)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 6
	label.font_size = 26
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	arena.add_child(label)


func _build_d2_rival_faction_wall(geom: Node) -> void:
	## Epic-2 T86: a second rival faction wall opposite the first one,
	## painted with a glowing cyan triangle symbol and "NULL CREW" tag.
	## Establishes "two factions are fighting over this district".
	var wall: Node3D = Node3D.new()
	wall.name = "D2RivalFactionWall"
	wall.position = D2_CENTER + Vector3(22, 0, 4)
	wall.rotation = Vector3(0, deg_to_rad(180), 0)
	geom.add_child(wall)
	# Wall slab
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.20, 0.16, 0.12)
	stone_mat.metallic = 0.30
	stone_mat.roughness = 0.65
	var slab: MeshInstance3D = MeshInstance3D.new()
	var smesh: BoxMesh = BoxMesh.new()
	smesh.size = Vector3(0.30, 4.0, 4.5)
	slab.mesh = smesh
	slab.position = Vector3(0, 2.0, 0)
	slab.material_override = stone_mat
	wall.add_child(slab)
	# Painted triangle symbol — 3 box edges forming the outline
	var sym_mat: StandardMaterial3D = StandardMaterial3D.new()
	sym_mat.albedo_color = Color(0.30, 0.85, 1.0)
	sym_mat.emission_enabled = true
	sym_mat.emission = Color(0.55, 0.95, 1.0)
	sym_mat.emission_energy_multiplier = 1.8
	sym_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	# 3 triangle sides
	var tri_specs: Array = [
		[Vector3(0.16, 1.10, 0), Vector3(0.06, 0.20, 2.40), 0.0],
		[Vector3(0.16, 2.05, -0.55), Vector3(0.06, 0.20, 2.20), deg_to_rad(60)],
		[Vector3(0.16, 2.05, 0.55), Vector3(0.06, 0.20, 2.20), deg_to_rad(-60)],
	]
	for spec in tri_specs:
		var seg: MeshInstance3D = MeshInstance3D.new()
		var sm: BoxMesh = BoxMesh.new()
		sm.size = spec[1]
		seg.mesh = sm
		seg.position = spec[0]
		seg.rotation = Vector3(spec[2], 0, 0)
		seg.material_override = sym_mat
		wall.add_child(seg)
	# Faction tag
	var label: Label3D = Label3D.new()
	label.text = "NULL CREW"
	label.position = Vector3(0.18, 0.65, 0)
	label.rotation = Vector3(0, deg_to_rad(90), 0)
	label.modulate = Color(0.55, 0.95, 1.0)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 26
	label.no_depth_test = true
	wall.add_child(label)
	# Collision
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(0.30, 4.0, 4.5)
	cs.shape = cb
	cs.position = Vector3(0, 2.0, 0)
	sb.add_child(cs)
	wall.add_child(sb)


func _build_d2_skill_trainer_npc() -> void:
	## Epic-2 T87: skill trainer NPC standing next to a punching dummy,
	## demonstrating combat skills with a periodic punch animation.
	var slots: Node3D = get_node_or_null("%NPCSlots") as Node3D
	if slots == null:
		return
	var trainer: Node3D = Node3D.new()
	trainer.name = "D2SkillTrainer"
	trainer.position = D2_CENTER + Vector3(2, 0, -3)
	slots.add_child(trainer)
	# Body — fit capsule
	var bmat: StandardMaterial3D = StandardMaterial3D.new()
	bmat.albedo_color = Color(0.85, 0.30, 0.20)
	bmat.metallic = 0.30
	bmat.roughness = 0.55
	bmat.emission_enabled = true
	bmat.emission = Color(1.0, 0.40, 0.20)
	bmat.emission_energy_multiplier = 0.40
	var body: MeshInstance3D = MeshInstance3D.new()
	var bmesh: CapsuleMesh = CapsuleMesh.new()
	bmesh.radius = 0.42
	bmesh.height = 1.30
	body.mesh = bmesh
	body.position = Vector3(0, 0.70, 0)
	body.material_override = bmat
	trainer.add_child(body)
	# Head sphere
	var head: MeshInstance3D = MeshInstance3D.new()
	var hmesh: SphereMesh = SphereMesh.new()
	hmesh.radius = 0.36
	hmesh.height = 0.65
	head.mesh = hmesh
	head.position = Vector3(0, 1.55, 0)
	var hmat: StandardMaterial3D = StandardMaterial3D.new()
	hmat.albedo_color = Color(0.30, 0.20, 0.15)
	hmat.metallic = 0.20
	hmat.roughness = 0.65
	head.material_override = hmat
	trainer.add_child(head)
	# 2 amber eyes
	var eye_mat: StandardMaterial3D = StandardMaterial3D.new()
	eye_mat.albedo_color = Color(1.0, 0.85, 0.30)
	eye_mat.emission_enabled = true
	eye_mat.emission = Color(1.0, 0.95, 0.30)
	eye_mat.emission_energy_multiplier = 2.6
	eye_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for ex: float in [-0.10, 0.10]:
		var eye: MeshInstance3D = MeshInstance3D.new()
		var em: SphereMesh = SphereMesh.new()
		em.radius = 0.06
		em.height = 0.12
		eye.mesh = em
		eye.position = Vector3(ex, 1.55, 0.30)
		eye.material_override = eye_mat
		trainer.add_child(eye)
	# Punching arm in front of body — animated forward/back tween
	var arm: MeshInstance3D = MeshInstance3D.new()
	var amesh: BoxMesh = BoxMesh.new()
	amesh.size = Vector3(0.20, 0.20, 0.85)
	arm.mesh = amesh
	arm.position = Vector3(0, 0.95, 0.55)
	arm.material_override = bmat
	trainer.add_child(arm)
	# Punching dummy in front of trainer
	var dummy_mat: StandardMaterial3D = StandardMaterial3D.new()
	dummy_mat.albedo_color = Color(0.40, 0.30, 0.18)
	dummy_mat.metallic = 0.10
	dummy_mat.roughness = 0.65
	var dummy: MeshInstance3D = MeshInstance3D.new()
	var dmesh: CapsuleMesh = CapsuleMesh.new()
	dmesh.radius = 0.40
	dmesh.height = 1.40
	dummy.mesh = dmesh
	dummy.position = Vector3(0, 0.70, 1.85)
	dummy.material_override = dummy_mat
	trainer.add_child(dummy)
	# Dummy stand
	var stand: MeshInstance3D = MeshInstance3D.new()
	var smesh: CylinderMesh = CylinderMesh.new()
	smesh.top_radius = 0.45
	smesh.bottom_radius = 0.45
	smesh.height = 0.10
	stand.mesh = smesh
	stand.position = Vector3(0, 0.05, 1.85)
	var stand_mat: StandardMaterial3D = StandardMaterial3D.new()
	stand_mat.albedo_color = Color(0.10, 0.10, 0.13)
	stand_mat.metallic = 0.85
	stand.material_override = stand_mat
	trainer.add_child(stand)
	# Punch tween — arm shoots forward and back, dummy recoils slightly
	var punch: Tween = create_tween().set_loops()
	punch.tween_property(arm, "position:z", 1.40, 0.18).set_ease(Tween.EASE_OUT)
	punch.tween_property(dummy, "position:z", 2.00, 0.10).set_ease(Tween.EASE_OUT)
	punch.tween_property(arm, "position:z", 0.55, 0.30).set_ease(Tween.EASE_IN)
	punch.tween_property(dummy, "position:z", 1.85, 0.30).set_ease(Tween.EASE_IN)
	punch.tween_interval(0.40)
	# Name billboard
	var label: Label3D = Label3D.new()
	label.text = "Skill Trainer"
	label.position = Vector3(0, 2.20, 0)
	label.modulate = Color(1.0, 0.55, 0.20)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 18
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	trainer.add_child(label)


func _build_d2_ground_fissure(geom: Node) -> void:
	## Epic-2 T88: a long jagged ground fissure — 6 connected emissive
	## red bars at random angles forming a crack across the floor.
	var fissure: Node3D = Node3D.new()
	fissure.name = "D2GroundFissure"
	fissure.position = D2_CENTER + Vector3(10, 0.06, -6)
	fissure.rotation = Vector3(0, deg_to_rad(35), 0)
	geom.add_child(fissure)
	var crack_mat: StandardMaterial3D = StandardMaterial3D.new()
	crack_mat.albedo_color = Color(1.0, 0.30, 0.20)
	crack_mat.emission_enabled = true
	crack_mat.emission = Color(1.0, 0.40, 0.20)
	crack_mat.emission_energy_multiplier = 2.4
	crack_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var current_offset: float = 0.0
	for i in 6:
		var seg: MeshInstance3D = MeshInstance3D.new()
		var smesh: BoxMesh = BoxMesh.new()
		var seg_len: float = 1.40 + randf_range(-0.30, 0.30)
		smesh.size = Vector3(seg_len, 0.04, 0.30 + randf_range(-0.10, 0.10))
		seg.mesh = smesh
		seg.position = Vector3(current_offset + seg_len * 0.5, 0, randf_range(-0.30, 0.30))
		seg.rotation = Vector3(0, deg_to_rad(randf_range(-25, 25)), 0)
		seg.material_override = crack_mat
		fissure.add_child(seg)
		current_offset += seg_len * 0.85
		# Pulse on a random delay
		var pulse: Tween = create_tween().set_loops()
		pulse.tween_interval(randf() * 0.4)
		pulse.tween_property(crack_mat, "emission_energy_multiplier", 3.5, 0.85).set_ease(Tween.EASE_IN_OUT)
		pulse.tween_property(crack_mat, "emission_energy_multiplier", 1.4, 0.85).set_ease(Tween.EASE_IN_OUT)


func _build_d2_scratch_decals(geom: Node) -> void:
	## Epic-2 T89: 12 small skid mark decals scattered on the road —
	## thin dark grey lines suggesting hover-vehicle landings + drag.
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 99
	var decal_mat: StandardMaterial3D = StandardMaterial3D.new()
	decal_mat.albedo_color = Color(0.04, 0.04, 0.06)
	decal_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for i in 12:
		var decal: MeshInstance3D = MeshInstance3D.new()
		decal.name = "D2Skid_%d" % i
		var dmesh: BoxMesh = BoxMesh.new()
		dmesh.size = Vector3(rng.randf_range(0.85, 1.40), 0.02, 0.10)
		decal.mesh = dmesh
		decal.position = D2_CENTER + Vector3(
			rng.randf_range(-22, 22),
			0.04,
			rng.randf_range(-16, 16)
		)
		decal.rotation = Vector3(0, deg_to_rad(rng.randf_range(0, 360)), 0)
		decal.material_override = decal_mat
		geom.add_child(decal)


func _build_d2_ammo_stash(geom: Node) -> void:
	## Epic-2 T90: a small ammo crate stash — 4 ammo boxes stacked with
	## a tarp covering them and a glowing yellow "AMMO" label.
	var stash: Node3D = Node3D.new()
	stash.name = "D2AmmoStash"
	stash.position = D2_CENTER + Vector3(16, 0, -3)
	geom.add_child(stash)
	var box_mat: StandardMaterial3D = StandardMaterial3D.new()
	box_mat.albedo_color = Color(0.30, 0.40, 0.20)
	box_mat.metallic = 0.30
	box_mat.roughness = 0.55
	box_mat.emission_enabled = true
	box_mat.emission = Color(0.45, 0.55, 0.20)
	box_mat.emission_energy_multiplier = 0.30
	# 4 stacked boxes
	var box_specs: Array = [
		[Vector3(0, 0.30, 0), 0.0],
		[Vector3(0.55, 0.30, 0), 0.0],
		[Vector3(0.30, 0.85, 0), deg_to_rad(8)],
		[Vector3(-0.10, 0.85, 0.30), deg_to_rad(-15)],
	]
	for spec in box_specs:
		var box: MeshInstance3D = MeshInstance3D.new()
		var bm: BoxMesh = BoxMesh.new()
		bm.size = Vector3(0.55, 0.55, 0.40)
		box.mesh = bm
		box.position = spec[0]
		box.rotation = Vector3(0, spec[1], 0)
		box.material_override = box_mat
		stash.add_child(box)
		# Side label
		var side: Label3D = Label3D.new()
		side.text = "AMMO"
		side.position = (spec[0] as Vector3) + Vector3(0, 0, 0.21)
		side.rotation = Vector3(0, spec[1], 0)
		side.modulate = Color(1.0, 0.95, 0.30)
		side.outline_modulate = Color(0, 0, 0, 0.85)
		side.outline_size = 3
		side.font_size = 12
		side.no_depth_test = true
		stash.add_child(side)
	# Tarp draped over the top — flat box
	var tarp_mat: StandardMaterial3D = StandardMaterial3D.new()
	tarp_mat.albedo_color = Color(0.20, 0.20, 0.25)
	tarp_mat.metallic = 0.10
	tarp_mat.roughness = 0.85
	var tarp: MeshInstance3D = MeshInstance3D.new()
	var tmesh: BoxMesh = BoxMesh.new()
	tmesh.size = Vector3(1.40, 0.04, 1.0)
	tarp.mesh = tmesh
	tarp.position = Vector3(0.20, 1.20, 0.10)
	tarp.rotation = Vector3(deg_to_rad(-8), deg_to_rad(15), deg_to_rad(5))
	tarp.material_override = tarp_mat
	stash.add_child(tarp)
	# Sign
	var label: Label3D = Label3D.new()
	label.text = "AMMO STASH"
	label.position = Vector3(0, 1.85, 0)
	label.modulate = Color(1.0, 0.95, 0.30)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 16
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	stash.add_child(label)
	# Collision around the whole stash
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(1.40, 1.20, 1.0)
	cs.shape = cb
	cs.position = Vector3(0.20, 0.60, 0.10)
	sb.add_child(cs)
	stash.add_child(sb)


func _build_d2_cargo_lift(geom: Node) -> void:
	## Epic-2 T91: a cargo lift platform with 4 corner posts and a center
	## platform that bobs vertically. The "moving" cargo is a stack of
	## 2 large crates fastened to the lift.
	var lift: Node3D = Node3D.new()
	lift.name = "D2CargoLift"
	lift.position = D2_CENTER + Vector3(20, 0, 4)
	geom.add_child(lift)
	# 4 corner posts (fixed)
	var post_mat: StandardMaterial3D = StandardMaterial3D.new()
	post_mat.albedo_color = Color(0.10, 0.13, 0.16)
	post_mat.metallic = 0.85
	post_mat.roughness = 0.30
	for ox: float in [-1.40, 1.40]:
		for oz: float in [-1.40, 1.40]:
			var post: MeshInstance3D = MeshInstance3D.new()
			var pmesh: CylinderMesh = CylinderMesh.new()
			pmesh.top_radius = 0.10
			pmesh.bottom_radius = 0.14
			pmesh.height = 4.0
			post.mesh = pmesh
			post.position = Vector3(ox, 2.0, oz)
			post.material_override = post_mat
			lift.add_child(post)
			# Collision per post
			var sb: StaticBody3D = StaticBody3D.new()
			var cs: CollisionShape3D = CollisionShape3D.new()
			var cap: CapsuleShape3D = CapsuleShape3D.new()
			cap.radius = 0.20
			cap.height = 4.0
			cs.shape = cap
			cs.position = Vector3(ox, 2.0, oz)
			sb.add_child(cs)
			lift.add_child(sb)
	# Lift platform that bobs (parent for the platform + crates)
	var lift_pivot: Node3D = Node3D.new()
	lift_pivot.position = Vector3(0, 0.30, 0)
	lift.add_child(lift_pivot)
	# Platform base — wide flat box
	var plat_mat: StandardMaterial3D = StandardMaterial3D.new()
	plat_mat.albedo_color = Color(0.20, 0.22, 0.28)
	plat_mat.metallic = 0.65
	plat_mat.roughness = 0.40
	plat_mat.emission_enabled = true
	plat_mat.emission = Color(0.55, 0.95, 1.0)
	plat_mat.emission_energy_multiplier = 0.55
	var plat: MeshInstance3D = MeshInstance3D.new()
	var pmesh: BoxMesh = BoxMesh.new()
	pmesh.size = Vector3(2.60, 0.20, 2.60)
	plat.mesh = pmesh
	plat.material_override = plat_mat
	lift_pivot.add_child(plat)
	# 2 crates on the platform
	var crate_mat: StandardMaterial3D = StandardMaterial3D.new()
	crate_mat.albedo_color = Color(0.30, 0.18, 0.08)
	crate_mat.metallic = 0.10
	crate_mat.roughness = 0.65
	for spec in [
		[Vector3(-0.40, 0.65, 0), Vector3(0.85, 0.85, 0.85)],
		[Vector3(0.55, 0.65, 0.20), Vector3(0.85, 0.85, 0.85)],
	]:
		var crate: MeshInstance3D = MeshInstance3D.new()
		var cm: BoxMesh = BoxMesh.new()
		cm.size = spec[1]
		crate.mesh = cm
		crate.position = spec[0]
		crate.rotation = Vector3(0, deg_to_rad(randf_range(-15, 15)), 0)
		crate.material_override = crate_mat
		lift_pivot.add_child(crate)
	# Bob the lift up and down
	var bob: Tween = create_tween().set_loops()
	bob.tween_property(lift_pivot, "position:y", 3.0, 4.0).set_ease(Tween.EASE_IN_OUT)
	bob.tween_interval(0.85)
	bob.tween_property(lift_pivot, "position:y", 0.30, 4.0).set_ease(Tween.EASE_IN_OUT)
	bob.tween_interval(0.85)
	# Sign
	var label: Label3D = Label3D.new()
	label.text = "CARGO LIFT"
	label.position = Vector3(0, 4.40, 0)
	label.modulate = Color(0.55, 0.95, 1.0)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 16
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	lift.add_child(label)


func _build_d2_ember_drift(geom: Node) -> void:
	## Epic-2 T92: ambient orange ember particles drifting upward across
	## the district — 100 small embers floating up like burning paper.
	var embers: GPUParticles3D = GPUParticles3D.new()
	embers.name = "D2EmberDrift"
	embers.position = D2_CENTER + Vector3(0, 1, 0)
	embers.amount = 100
	embers.lifetime = 6.5
	embers.preprocess = 3.0
	var pmat: ParticleProcessMaterial = ParticleProcessMaterial.new()
	pmat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	pmat.emission_box_extents = Vector3(22, 0.5, 18)
	pmat.direction = Vector3(0.2, 1, 0)
	pmat.spread = 18.0
	pmat.initial_velocity_min = 0.55
	pmat.initial_velocity_max = 1.0
	pmat.gravity = Vector3.ZERO
	pmat.scale_min = 0.04
	pmat.scale_max = 0.10
	pmat.color = Color(1.0, 0.55, 0.20, 1.0)
	embers.process_material = pmat
	var em: SphereMesh = SphereMesh.new()
	em.radius = 0.05
	em.height = 0.10
	var em_mat: StandardMaterial3D = StandardMaterial3D.new()
	em_mat.albedo_color = Color(1.0, 0.55, 0.20)
	em_mat.emission_enabled = true
	em_mat.emission = Color(1.0, 0.65, 0.20)
	em_mat.emission_energy_multiplier = 2.6
	em_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	em.material = em_mat
	embers.draw_pass_1 = em
	geom.add_child(embers)


func _build_d2_unknown_tomb(geom: Node) -> void:
	## Epic-2 T93: a stone tomb engraved "TOMB OF THE UNKNOWN AGENT".
	## Long sarcophagus shape with a glowing central rune on top.
	var tomb: Node3D = Node3D.new()
	tomb.name = "D2UnknownTomb"
	tomb.position = D2_CENTER + Vector3(-15, 0, 18)
	geom.add_child(tomb)
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.30, 0.30, 0.34)
	stone_mat.metallic = 0.30
	stone_mat.roughness = 0.55
	# Stepped base
	for i in 2:
		var step: MeshInstance3D = MeshInstance3D.new()
		var sm: BoxMesh = BoxMesh.new()
		sm.size = Vector3(3.0 - i * 0.30, 0.20, 1.40 - i * 0.20)
		step.mesh = sm
		step.position = Vector3(0, 0.10 + i * 0.20, 0)
		step.material_override = stone_mat
		tomb.add_child(step)
	# Sarcophagus body
	var sarc: MeshInstance3D = MeshInstance3D.new()
	var sm2: BoxMesh = BoxMesh.new()
	sm2.size = Vector3(2.40, 0.85, 0.85)
	sarc.mesh = sm2
	sarc.position = Vector3(0, 0.85, 0)
	sarc.material_override = stone_mat
	tomb.add_child(sarc)
	# Glowing rune on top — small emissive star (4-prism arrangement)
	var rune_mat: StandardMaterial3D = StandardMaterial3D.new()
	rune_mat.albedo_color = Color(0.85, 0.85, 0.95)
	rune_mat.emission_enabled = true
	rune_mat.emission = Color(0.95, 0.95, 1.0)
	rune_mat.emission_energy_multiplier = 2.4
	rune_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for i in 4:
		var spike: MeshInstance3D = MeshInstance3D.new()
		var prm: PrismMesh = PrismMesh.new()
		prm.size = Vector3(0.10, 0.30, 0.10)
		spike.mesh = prm
		var angle: float = (float(i) / 4.0) * TAU
		spike.position = Vector3(cos(angle) * 0.15, 1.40, sin(angle) * 0.15)
		spike.rotation = Vector3(0, -angle, 0)
		spike.material_override = rune_mat
		tomb.add_child(spike)
	# Engraved text on the side of the sarcophagus
	var label: Label3D = Label3D.new()
	label.text = "TOMB OF THE\nUNKNOWN AGENT"
	label.position = Vector3(0, 0.85, 0.45)
	label.modulate = Color(0.85, 0.85, 0.95)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 4
	label.font_size = 14
	label.no_depth_test = true
	tomb.add_child(label)
	# Collision around the sarcophagus
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(2.40, 1.40, 1.40)
	cs.shape = cb
	cs.position = Vector3(0, 0.70, 0)
	sb.add_child(cs)
	tomb.add_child(sb)


func _build_d2_stalker_enemy(geom: Node) -> void:
	## Epic-2 T94: a stalker enemy slinking around the district. Tall thin
	## body with 3 spider-like leg sticks and 1 single white-hot eye.
	var stalker: Node3D = Node3D.new()
	stalker.name = "D2Stalker"
	stalker.position = D2_CENTER + Vector3(-3, 0, 12)
	geom.add_child(stalker)
	# Tall thin body — vertical capsule
	var bmat: StandardMaterial3D = StandardMaterial3D.new()
	bmat.albedo_color = Color(0.04, 0.04, 0.06)
	bmat.metallic = 0.30
	bmat.roughness = 0.65
	bmat.emission_enabled = true
	bmat.emission = Color(0.20, 0.10, 0.30)
	bmat.emission_energy_multiplier = 0.30
	var body: MeshInstance3D = MeshInstance3D.new()
	var bmesh: CapsuleMesh = CapsuleMesh.new()
	bmesh.radius = 0.20
	bmesh.height = 1.40
	body.mesh = bmesh
	body.position = Vector3(0, 1.30, 0)
	body.material_override = bmat
	stalker.add_child(body)
	# Single white-hot eye on top
	var eye: MeshInstance3D = MeshInstance3D.new()
	var em: SphereMesh = SphereMesh.new()
	em.radius = 0.12
	em.height = 0.24
	eye.mesh = em
	eye.position = Vector3(0, 1.85, 0.18)
	var emat: StandardMaterial3D = StandardMaterial3D.new()
	emat.albedo_color = Color(1, 1, 1)
	emat.emission_enabled = true
	emat.emission = Color(1, 1, 1)
	emat.emission_energy_multiplier = 3.4
	emat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	eye.material_override = emat
	stalker.add_child(eye)
	# 3 thin spider legs splaying outward from the bottom
	var leg_mat: StandardMaterial3D = StandardMaterial3D.new()
	leg_mat.albedo_color = Color(0.04, 0.04, 0.06)
	leg_mat.metallic = 0.30
	for i in 3:
		var angle: float = (float(i) / 3.0) * TAU
		var leg: MeshInstance3D = MeshInstance3D.new()
		var lmesh: CylinderMesh = CylinderMesh.new()
		lmesh.top_radius = 0.04
		lmesh.bottom_radius = 0.04
		lmesh.height = 1.20
		leg.mesh = lmesh
		leg.position = Vector3(cos(angle) * 0.30, 0.55, sin(angle) * 0.30)
		leg.rotation = Vector3(sin(angle) * deg_to_rad(20), 0, -cos(angle) * deg_to_rad(20))
		leg.material_override = leg_mat
		stalker.add_child(leg)
	# Patrol path
	var origin: Vector3 = D2_CENTER + Vector3(-3, 0, 12)
	var patrol: Tween = create_tween().set_loops()
	patrol.tween_property(stalker, "position", origin + Vector3(6, 0, -6), 8.0)
	patrol.tween_property(stalker, "position", origin + Vector3(-3, 0, -6), 8.0)
	patrol.tween_property(stalker, "position", origin, 8.0)
	# Eye flicker
	var flicker: Tween = create_tween().set_loops()
	flicker.tween_property(emat, "emission_energy_multiplier", 4.5, 0.6).set_ease(Tween.EASE_IN_OUT)
	flicker.tween_property(emat, "emission_energy_multiplier", 1.6, 0.6).set_ease(Tween.EASE_IN_OUT)
	# Boss-tier name billboard
	var label: Label3D = Label3D.new()
	label.text = "STALKER"
	label.position = Vector3(0, 2.40, 0)
	label.modulate = Color(0.85, 0.55, 1.0)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 16
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	stalker.add_child(label)


func _build_d2_boss_fortifications(geom: Node) -> void:
	## Epic-2 T95: 6 stone barricade walls forming a partial outer ring
	## around the boss arena teaser, suggesting "the gangs tried to keep
	## the boss contained but failed".
	var fort: Node3D = Node3D.new()
	fort.name = "D2BossFortifications"
	fort.position = D2_CENTER + Vector3(28, 0, 0)
	geom.add_child(fort)
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.16, 0.13, 0.10)
	stone_mat.metallic = 0.30
	stone_mat.roughness = 0.65
	stone_mat.emission_enabled = true
	stone_mat.emission = Color(1.0, 0.40, 0.20)
	stone_mat.emission_energy_multiplier = 0.20
	# 6 walls at 60-degree increments around the arena
	for i in 6:
		var angle: float = (float(i) / 6.0) * TAU + deg_to_rad(30)
		var wall_root: Node3D = Node3D.new()
		wall_root.position = Vector3(cos(angle) * 8.5, 0, sin(angle) * 8.5)
		wall_root.rotation = Vector3(0, -angle, 0)
		fort.add_child(wall_root)
		# Wall slab — wide flat box
		var wall: MeshInstance3D = MeshInstance3D.new()
		var wmesh: BoxMesh = BoxMesh.new()
		wmesh.size = Vector3(0.40, 1.85, 2.40)
		wall.mesh = wmesh
		wall.position = Vector3(0, 0.92, 0)
		wall.rotation = Vector3(deg_to_rad(randf_range(-5, 5)), 0, deg_to_rad(randf_range(-8, 8)))
		wall.material_override = stone_mat
		wall_root.add_child(wall)
		# Crack stripe down the middle (broken through)
		if i % 2 == 0:
			var crack: MeshInstance3D = MeshInstance3D.new()
			var cmesh: BoxMesh = BoxMesh.new()
			cmesh.size = Vector3(0.06, 1.20, 0.30)
			crack.mesh = cmesh
			crack.position = Vector3(0.21, 0.92, 0)
			crack.rotation = Vector3(0, 0, deg_to_rad(8))
			var crack_mat: StandardMaterial3D = StandardMaterial3D.new()
			crack_mat.albedo_color = Color(1.0, 0.40, 0.20)
			crack_mat.emission_enabled = true
			crack_mat.emission = Color(1.0, 0.55, 0.20)
			crack_mat.emission_energy_multiplier = 1.8
			crack_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
			crack.material_override = crack_mat
			wall_root.add_child(crack)
		# Collision per wall
		var sb: StaticBody3D = StaticBody3D.new()
		var cs: CollisionShape3D = CollisionShape3D.new()
		var cb: BoxShape3D = BoxShape3D.new()
		cb.size = Vector3(0.40, 1.85, 2.40)
		cs.shape = cb
		cs.position = Vector3(0, 0.92, 0)
		sb.add_child(cs)
		wall_root.add_child(sb)


func _build_d2_welcome_banner(geom: Node) -> void:
	## Epic-2 T96: a wide amber banner stretched between the existing D2
	## entrance arch pillars at x=70 reading "STACK OVERFLOW / OUTSKIRTS".
	## Has waving emissive trim and a slow alpha pulse.
	var banner_root: Node3D = Node3D.new()
	banner_root.name = "D2WelcomeBanner"
	banner_root.position = Vector3(70, 0, 0)
	geom.add_child(banner_root)
	# Banner cloth — long horizontal box
	var cloth: MeshInstance3D = MeshInstance3D.new()
	var cmesh: BoxMesh = BoxMesh.new()
	cmesh.size = Vector3(0.10, 0.95, 7.5)
	cloth.mesh = cmesh
	cloth.position = Vector3(0, 5.5, 0)
	var cmat: StandardMaterial3D = StandardMaterial3D.new()
	cmat.albedo_color = Color(0.30, 0.10, 0.04)
	cmat.emission_enabled = true
	cmat.emission = Color(1.0, 0.40, 0.20)
	cmat.emission_energy_multiplier = 1.0
	cmat.metallic = 0.10
	cmat.roughness = 0.55
	cloth.material_override = cmat
	banner_root.add_child(cloth)
	# Top + bottom emissive trim
	var trim_mat: StandardMaterial3D = StandardMaterial3D.new()
	trim_mat.albedo_color = Color(1.0, 0.55, 0.20)
	trim_mat.emission_enabled = true
	trim_mat.emission = Color(1.0, 0.65, 0.20)
	trim_mat.emission_energy_multiplier = 2.0
	trim_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for ty: float in [5.95, 5.05]:
		var trim: MeshInstance3D = MeshInstance3D.new()
		var tmesh: BoxMesh = BoxMesh.new()
		tmesh.size = Vector3(0.12, 0.08, 7.5)
		trim.mesh = tmesh
		trim.position = Vector3(0, ty, 0)
		trim.material_override = trim_mat
		banner_root.add_child(trim)
	# Welcome text — duplicated for both sides
	for fx: float in [-0.10, 0.10]:
		var label: Label3D = Label3D.new()
		label.text = "STACK OVERFLOW\nOUTSKIRTS"
		label.position = Vector3(fx, 5.50, 0)
		label.rotation = Vector3(0, deg_to_rad(-90 if fx < 0 else 90), 0)
		label.modulate = Color(1.0, 0.55, 0.20)
		label.outline_modulate = Color(0, 0, 0, 0.85)
		label.outline_size = 6
		label.font_size = 24
		label.no_depth_test = true
		banner_root.add_child(label)
	# Slow emission pulse
	var pulse: Tween = create_tween().set_loops()
	pulse.tween_property(cmat, "emission_energy_multiplier", 1.6, 2.0).set_ease(Tween.EASE_IN_OUT)
	pulse.tween_property(cmat, "emission_energy_multiplier", 0.85, 2.0).set_ease(Tween.EASE_IN_OUT)


func _build_d2_red_fog(geom: Node) -> void:
	## Epic-2 T97: atmospheric red fog drifting low across the district —
	## 60 large translucent red puff particles slowly moving east at
	## ~0.5m altitude, very transparent.
	var fog: GPUParticles3D = GPUParticles3D.new()
	fog.name = "D2RedFog"
	fog.position = D2_CENTER + Vector3(-25, 0.5, 0)
	fog.amount = 60
	fog.lifetime = 12.0
	fog.preprocess = 6.0
	var pmat: ParticleProcessMaterial = ParticleProcessMaterial.new()
	pmat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	pmat.emission_box_extents = Vector3(0.5, 0.5, 18.0)
	pmat.direction = Vector3(1, 0, 0)
	pmat.spread = 4.0
	pmat.initial_velocity_min = 0.45
	pmat.initial_velocity_max = 0.85
	pmat.gravity = Vector3.ZERO
	pmat.scale_min = 0.85
	pmat.scale_max = 1.40
	pmat.color = Color(1.0, 0.30, 0.20, 0.20)
	fog.process_material = pmat
	var puff: SphereMesh = SphereMesh.new()
	puff.radius = 0.85
	puff.height = 1.70
	var puff_mat: StandardMaterial3D = StandardMaterial3D.new()
	puff_mat.albedo_color = Color(1.0, 0.30, 0.20, 0.20)
	puff_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	puff_mat.emission_enabled = true
	puff_mat.emission = Color(1.0, 0.40, 0.20)
	puff_mat.emission_energy_multiplier = 0.45
	puff_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	puff.material = puff_mat
	fog.draw_pass_1 = puff
	geom.add_child(fog)


func _build_d2_epic2_plaque(geom: Node) -> void:
	## Epic-2 T98: a stone tablet plaque commemorating the completion of
	## Epic 2 ("EPIC 02 / OUTSKIRTS COMPLETE"), placed near the boss arena.
	var plaque: Node3D = Node3D.new()
	plaque.name = "D2Epic2Plaque"
	plaque.position = D2_CENTER + Vector3(24, 0, -8)
	geom.add_child(plaque)
	# Tiny pedestal
	var ped_mat: StandardMaterial3D = StandardMaterial3D.new()
	ped_mat.albedo_color = Color(0.16, 0.13, 0.10)
	ped_mat.metallic = 0.55
	ped_mat.roughness = 0.45
	var ped: MeshInstance3D = MeshInstance3D.new()
	var pmesh: BoxMesh = BoxMesh.new()
	pmesh.size = Vector3(0.85, 0.50, 0.40)
	ped.mesh = pmesh
	ped.position = Vector3(0, 0.25, 0)
	ped.material_override = ped_mat
	plaque.add_child(ped)
	# Tilted stone tablet
	var tablet: MeshInstance3D = MeshInstance3D.new()
	var tmesh: BoxMesh = BoxMesh.new()
	tmesh.size = Vector3(0.85, 0.65, 0.06)
	tablet.mesh = tmesh
	tablet.position = Vector3(0, 0.85, 0)
	tablet.rotation = Vector3(deg_to_rad(-25), 0, 0)
	var tmat: StandardMaterial3D = StandardMaterial3D.new()
	tmat.albedo_color = Color(0.30, 0.20, 0.14)
	tmat.metallic = 0.65
	tmat.roughness = 0.30
	tmat.emission_enabled = true
	tmat.emission = Color(1.0, 0.55, 0.20)
	tmat.emission_energy_multiplier = 0.40
	tablet.material_override = tmat
	plaque.add_child(tablet)
	# Engraved text
	var label: Label3D = Label3D.new()
	label.text = "EPIC 02\nOUTSKIRTS\nCOMPLETE"
	label.position = Vector3(0, 0.95, 0.18)
	label.rotation = Vector3(deg_to_rad(-25), 0, 0)
	label.modulate = Color(1.0, 0.55, 0.20)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 4
	label.font_size = 14
	label.no_depth_test = true
	plaque.add_child(label)
	# Collision
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(0.85, 0.60, 0.40)
	cs.shape = cb
	cs.position = Vector3(0, 0.30, 0)
	sb.add_child(cs)
	plaque.add_child(sb)


func _build_d2_ambient_lighting(geom: Node) -> void:
	## Epic-2 T99: 3 high amber-tinted OmniLight3D fill lights spaced
	## along the D2 length lifting the overall light level so all 100
	## elements read nicely.
	var positions: Array[Vector3] = [
		D2_CENTER + Vector3(-15, 8, 0),
		D2_CENTER + Vector3(0, 8, 0),
		D2_CENTER + Vector3(15, 8, 0),
	]
	for i in positions.size():
		var fill: OmniLight3D = OmniLight3D.new()
		fill.name = "D2FillLight_%d" % i
		fill.position = positions[i]
		fill.light_color = Color(1.0, 0.75, 0.55)
		fill.light_energy = 1.4
		fill.omni_range = 22.0
		fill.omni_attenuation = 1.6
		geom.add_child(fill)


func _build_d2_glitch_herald_landmark(geom: Node) -> void:
	## Epic-2 T100 (FINALE): a massive hovering "Glitch Herald" landmark
	## above the D2 center — translucent crimson humanoid figure with
	## 6 orbital glitch shards, slow rotation, ground halo, real omni
	## light. The Outskirts equivalent of East Plaza's Globbler landmark.
	var landmark: Node3D = Node3D.new()
	landmark.name = "D2GlitchHeraldLandmark"
	landmark.position = D2_CENTER + Vector3(0, 12, 0)
	geom.add_child(landmark)
	# Pivot for rotation
	var pivot: Node3D = Node3D.new()
	pivot.name = "RotationPivot"
	landmark.add_child(pivot)
	# Translucent humanoid body — capsule
	var holo_mat: StandardMaterial3D = StandardMaterial3D.new()
	holo_mat.albedo_color = Color(1.0, 0.30, 0.30, 0.45)
	holo_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	holo_mat.emission_enabled = true
	holo_mat.emission = Color(1.0, 0.30, 0.30)
	holo_mat.emission_energy_multiplier = 2.4
	holo_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	# Body capsule
	var body: MeshInstance3D = MeshInstance3D.new()
	var bmesh: CapsuleMesh = CapsuleMesh.new()
	bmesh.radius = 0.85
	bmesh.height = 2.40
	body.mesh = bmesh
	body.position = Vector3(0, 0, 0)
	body.material_override = holo_mat
	pivot.add_child(body)
	# Head sphere
	var head: MeshInstance3D = MeshInstance3D.new()
	var hmesh: SphereMesh = SphereMesh.new()
	hmesh.radius = 0.70
	hmesh.height = 1.40
	head.mesh = hmesh
	head.position = Vector3(0, 1.85, 0)
	head.material_override = holo_mat
	pivot.add_child(head)
	# 2 huge glowing white eyes
	var eye_mat: StandardMaterial3D = StandardMaterial3D.new()
	eye_mat.albedo_color = Color(1, 1, 1, 0.9)
	eye_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	eye_mat.emission_enabled = true
	eye_mat.emission = Color(1, 1, 1)
	eye_mat.emission_energy_multiplier = 3.4
	eye_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for ex: float in [-0.32, 0.32]:
		var eye: MeshInstance3D = MeshInstance3D.new()
		var em: SphereMesh = SphereMesh.new()
		em.radius = 0.22
		em.height = 0.44
		eye.mesh = em
		eye.position = Vector3(ex, 1.95, 0.55)
		eye.material_override = eye_mat
		pivot.add_child(eye)
	# 2 outstretched arms
	for sx: float in [-1.0, 1.0]:
		var arm: MeshInstance3D = MeshInstance3D.new()
		var am: BoxMesh = BoxMesh.new()
		am.size = Vector3(0.30, 0.30, 1.60)
		arm.mesh = am
		arm.position = Vector3(sx * 1.10, 0.30, 0)
		arm.rotation = Vector3(0, 0, sign(sx) * deg_to_rad(20))
		arm.material_override = holo_mat
		pivot.add_child(arm)
	# 6 orbital glitch shards (prisms) circling at body height
	for i in 6:
		var angle: float = (float(i) / 6.0) * TAU
		var shard: MeshInstance3D = MeshInstance3D.new()
		var sm: PrismMesh = PrismMesh.new()
		sm.size = Vector3(0.30, 0.65, 0.30)
		shard.mesh = sm
		shard.position = Vector3(cos(angle) * 2.20, sin(float(i) * 0.85) * 0.55, sin(angle) * 2.20)
		shard.rotation = Vector3(0, -angle, deg_to_rad(15))
		var smat: StandardMaterial3D = StandardMaterial3D.new()
		smat.albedo_color = Color(1.0, 0.40, 0.40)
		smat.emission_enabled = true
		smat.emission = Color(1.0, 0.55, 0.30)
		smat.emission_energy_multiplier = 2.6
		smat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		shard.material_override = smat
		pivot.add_child(shard)
	# Slow main rotation
	var spin: Tween = create_tween().set_loops()
	spin.tween_property(pivot, "rotation:y", TAU, 18.0)
	# Bobbing in place
	var bob: Tween = create_tween().set_loops()
	bob.tween_property(landmark, "position:y", 13.0, 3.0).set_ease(Tween.EASE_IN_OUT)
	bob.tween_property(landmark, "position:y", 12.0, 3.0).set_ease(Tween.EASE_IN_OUT)
	# Ground halo beneath the landmark
	var halo: MeshInstance3D = MeshInstance3D.new()
	var hmesh2: TorusMesh = TorusMesh.new()
	hmesh2.inner_radius = 4.0
	hmesh2.outer_radius = 4.55
	halo.mesh = hmesh2
	halo.position = D2_CENTER + Vector3(0, 0.06, 0)
	var hmat2: StandardMaterial3D = StandardMaterial3D.new()
	hmat2.albedo_color = Color(1.0, 0.40, 0.40)
	hmat2.emission_enabled = true
	hmat2.emission = Color(1.0, 0.55, 0.30)
	hmat2.emission_energy_multiplier = 2.4
	hmat2.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	halo.material_override = hmat2
	geom.add_child(halo)
	var halo_pulse: Tween = create_tween().set_loops()
	halo_pulse.tween_property(halo, "scale", Vector3(1.20, 1.0, 1.20), 2.0).set_ease(Tween.EASE_IN_OUT)
	halo_pulse.tween_property(halo, "scale", Vector3(1.0, 1.0, 1.0), 2.0).set_ease(Tween.EASE_IN_OUT)
	# Real OmniLight at the landmark casting amber light over the district
	var landmark_light: OmniLight3D = OmniLight3D.new()
	landmark_light.position = Vector3(0, 0, 0)
	landmark_light.light_color = Color(1.0, 0.55, 0.30)
	landmark_light.light_energy = 3.5
	landmark_light.omni_range = 28.0
	landmark_light.omni_attenuation = 1.4
	pivot.add_child(landmark_light)
	# GLITCH HERALD billboard above the landmark
	var label: Label3D = Label3D.new()
	label.text = "GLITCH HERALD"
	label.position = Vector3(0, 4.0, 0)
	label.modulate = Color(1.0, 0.40, 0.40)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 6
	label.font_size = 26
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	landmark.add_child(label)


