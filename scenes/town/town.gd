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
	print("[town] _build_town_decorations()")
	_build_town_decorations()
	print("[town] _populate_npcs()")
	_populate_npcs()
	print("[town] _update_town_state()")
	_update_town_state()
	print("[town] _add_ambient_particles()")
	_add_ambient_particles()
	# R6 epic-1: build East Plaza district expansion (data market)
	# This call chains into Districts 2-9 sequentially. The last `print` you see
	# in the Output before a crash will tell you which step failed.
	print("[town] _build_east_plaza() — chains into D2..D9")
	_build_east_plaza()
	print("[town] districts done")
	# R5 round-30: clamp baked-GLB hot emissions (lantern flames at 80.0)
	# down to a HDR-safe value to prevent bloom blowout. Discovered via the
	# round-30 emission survey across all 3 main scenes.
	print("[town] _clamp_hot_emissions()")
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
	print("[town] D1 east plaza done")
	# === EPIC 2: District 2 — Stack Overflow Outskirts ===
	print("[town] entering D2")
	_build_district_2(geom)
	print("[town] D2 done")




func _build_district_2(geom: Node) -> void:
	## Epic 2 entry point — delegates to D2Builder (scenes/town/districts/district_2.gd).
	## All Stack Outskirts content was extracted to that module to keep
	## town.gd modular. After D2 finishes, chain into D3 (Memory Vault).
	D2Builder.build(self, geom)
	# === EPIC 3: Memory Vault — The Datacore Depths ===
	print("[town] entering D3")
	_build_district_3(geom)
	print("[town] D3 done")


func _build_district_3(geom: Node) -> void:
	## Epic 3 entry point — delegates to D3Builder. After D3, chains into D4..D8.
	D3Builder.build(self, geom)
	# === EPIC 4: Bloom Cluster — The Sandbox Greenhouse ===
	print("[town] entering D4")
	_build_district_4(geom)
	print("[town] D4 done")
	# === EPIC 5: Frozen Cache — The Cryogenic Archive ===
	print("[town] entering D5")
	_build_district_5(geom)
	print("[town] D5 done")
	# === EPIC 6: Neon Bazaar — The All-Night Market ===
	print("[town] entering D6")
	_build_district_6(geom)
	print("[town] D6 done")
	# === EPIC 7: Ascension Spires — The High Sandstone Monastery ===
	print("[town] entering D7")
	_build_district_7(geom)
	print("[town] D7 done")
	# === EPIC 8: Tidal Harbor — The Working Seaside Port ===
	print("[town] entering D8")
	_build_district_8(geom)
	print("[town] D8 done")


func _build_district_4(geom: Node) -> void:
	## Epic 4 entry point — delegates to D4Builder.
	D4Builder.build(self, geom)




func _build_district_5(geom: Node) -> void:
	## Epic 5 entry point — delegates to D5Builder.
	D5Builder.build(self, geom)




func _build_district_6(geom: Node) -> void:
	## Epic 6 entry point — delegates to D6Builder (scenes/town/districts/district_6.gd).
	## All Neon Bazaar content was extracted to that module to keep
	## town.gd modular. See D6Builder.build() for the full task list.
	D6Builder.build(self, geom)




func _build_district_7(geom: Node) -> void:
	## Epic 7 entry point — delegates to D7Builder (scenes/town/districts/district_7.gd).
	## All Ascension Spires content was extracted to that module to keep
	## town.gd modular. See D7Builder.build() for the full task list.
	D7Builder.build(self, geom)


func _build_district_8(geom: Node) -> void:
	## Epic 8 entry point — delegates to D8Builder (scenes/town/districts/district_8.gd).
	## All Tidal Harbor content was extracted to that module. After D8 finishes,
	## chain into D9 (Volcanic Forge).
	D8Builder.build(self, geom)
	# === EPIC 9: District 9 — Volcanic Forge ===
	print("[town] entering D9")
	_build_district_9(geom)
	print("[town] D9 done")


func _build_district_9(geom: Node) -> void:
	## Epic 9 entry point — delegates to D9Builder (scenes/town/districts/district_9.gd).
	## All Volcanic Forge content was extracted to that module to keep town.gd
	## modular. See D9Builder.build() for the full task list.
	D9Builder.build(self, geom)







