class_name D5Builder
extends Node
## Frozen Cache district builder — extracted from scenes/town/town.gd to keep
## the main town script modular and under control.

const D5_CENTER := Vector3(290, 0, 0)


func extend_boundary(geom: Node) -> void:
	## Push the east boundary wall from x=260 out to x=330.
	var east_wall: CSGBox3D = geom.get_node_or_null("BoundaryEast") as CSGBox3D
	if east_wall:
		east_wall.position.x = 330.0


func build(town: Node, geom: Node) -> void:
	## Entry point — called from town.gd::_build_district_5(geom).
	print("[D5Builder] start")
	extend_boundary(geom)
	_build_d5_ground(geom)
	_build_d5_entrance_arch(geom)
	_build_d5_great_monolith(geom)
	_build_d5_cryo_keeper_npc(town)
	_build_d5_cryo_pods(geom)
	print("[D5] h5")
	_build_d5_ice_golem(geom)
	_build_d5_frost_servers(geom)
	_build_d5_crystal_tree(geom)
	_build_d5_snowfall(geom)
	print("[D5] h10")
	_build_d5_glacier_wall(geom)
	_build_d5_frozen_waterfall(geom)
	_build_d5_data_archaeologist_npc(town)
	_build_d5_ice_fishing_hole(geom)
	_build_d5_aurora_pillars(geom)
	print("[D5] h15")
	_build_d5_snowflake_circle(geom)
	_build_d5_frost_wisps(geom)
	_build_d5_ice_mage_npc(town)
	_build_d5_frozen_shelves(geom)
	_build_d5_cold_wind(geom)
	_build_d5_ice_bridge(geom)
	_build_d5_mammoth_statue(geom)
	_build_d5_cryo_engineer_npc(town)
	_build_d5_ice_cave_entrance(geom)
	_build_d5_frozen_heart(geom)
	_build_d5_mining_rig(geom)
	_build_d5_penguin_colony(geom)
	_build_d5_weather_tower(geom)
	_build_d5_meteorologist_npc(town)
	_build_d5_ice_fog(geom)
	_build_d5_dog_sled(geom)
	_build_d5_husky_team(geom)
	_build_d5_musher_npc(town)
	_build_d5_snow_fort(geom)
	_build_d5_aurora_curtain(geom)
	_build_d5_ice_harvest_pit(geom)
	_build_d5_ice_block_stacks(geom)
	_build_d5_data_analyst_npc(town)
	_build_d5_holo_charts(geom)
	_build_d5_lab_hut(geom)
	_build_d5_ice_rink(geom)
	_build_d5_skater_npc(geom)
	_build_d5_warming_campfire(geom)
	_build_d5_cocoa_stand(geom)
	_build_d5_cocoa_vendor_npc(town)
	_build_d5_cryo_prison(geom)
	_build_d5_yeti_silhouette(geom)
	_build_d5_explorer_npc(town)
	_build_d5_ice_spike_traps(geom)
	_build_d5_glacial_warden(geom)
	_build_d5_telescope_observatory(geom)
	_build_d5_stargazer_npc(town)
	_build_d5_comet_streaks(geom)
	_build_d5_rune_monument(geom)
	_build_d5_arctic_fox(geom)
	_build_d5_ice_fishing_huts(geom)
	_build_d5_ice_angler_npc(town)
	_build_d5_aurora_altar(geom)
	_build_d5_pine_grove(geom)
	_build_d5_snowman(geom)
	_build_d5_caribou_herd(geom)
	_build_d5_caribou_herder_npc(town)
	_build_d5_ice_rails(geom)
	_build_d5_cable_car_station(geom)
	_build_d5_snow_sculpture(geom)
	_build_d5_thermal_vents(geom)
	_build_d5_hot_spring(geom)
	_build_d5_bath_attendant_npc(town)
	_build_d5_ice_climbing_wall(geom)
	_build_d5_ice_climber_npc(town)
	_build_d5_ice_maze(geom)
	_build_d5_lost_wanderer_npc(town)
	_build_d5_glacial_chess(geom)
	_build_d5_chess_player_npc(town)
	_build_d5_crystal_cluster(geom)
	_build_d5_snow_globe(geom)
	_build_d5_cellist_npc(town)
	_build_d5_frosted_lamps(geom)
	_build_d5_arctic_owl(geom)
	_build_d5_rune_ring(geom)
	_build_d5_ice_slide(geom)
	_build_d5_skating_instructor_npc(town)
	_build_d5_ice_harp(geom)
	_build_d5_harpist_npc(town)
	_build_d5_data_prism_array(geom)
	_build_d5_ice_fountain(geom)
	_build_d5_cryo_lantern_grove(geom)
	_build_d5_signposts(geom)
	_build_d5_tablet_shrine(geom)
	_build_d5_ice_elemental(geom)
	_build_d5_glacier_crab(geom)
	_build_d5_cryo_kiosk(geom)
	_build_d5_seeker_npc(town)
	_build_d5_cryosleep_pods(geom)
	_build_d5_starlight_projector(geom)
	_build_d5_welcome_banner(geom)
	_build_d5_crown_tower(geom)
	_build_d5_district_plaque(geom)
	_build_d5_ambient_tweak(geom)
	_build_d5_frost_monarch(geom)
	print("[D5Builder] done")


func _build_d5_ground(geom: Node) -> void:
	## Epic-5 T1b: D5 snowy ground plane — pale blue-white with a subtle
	## cyan grid shader baked into the material as emission.
	var plane: PlaneMesh = PlaneMesh.new()
	plane.size = Vector2(70, 40)
	var ground: MeshInstance3D = MeshInstance3D.new()
	ground.mesh = plane
	var snow_mat: StandardMaterial3D = StandardMaterial3D.new()
	snow_mat.albedo_color = Color(0.85, 0.92, 0.98)
	snow_mat.emission_enabled = true
	snow_mat.emission = Color(0.55, 0.75, 0.95)
	snow_mat.emission_energy_multiplier = 0.18
	snow_mat.roughness = 0.65
	snow_mat.metallic = 0.10
	ground.material_override = snow_mat
	ground.position = Vector3(D5_CENTER.x, 0.01, 0)
	ground.name = "D5SnowGround"
	geom.add_child(ground)
	# Sprinkle 60 small snowdrift bumps for visual texture
	var drift_mat: StandardMaterial3D = StandardMaterial3D.new()
	drift_mat.albedo_color = Color(0.95, 0.97, 1.0)
	drift_mat.emission_enabled = true
	drift_mat.emission = Color(0.75, 0.90, 1.0)
	drift_mat.emission_energy_multiplier = 0.20
	drift_mat.roughness = 0.55
	for i in 60:
		var drift: MeshInstance3D = MeshInstance3D.new()
		var dm: SphereMesh = SphereMesh.new()
		dm.radius = 0.45 + randf() * 0.40
		dm.height = 0.30 + randf() * 0.20
		drift.mesh = dm
		drift.material_override = drift_mat
		drift.position = Vector3(
			D5_CENTER.x + randf_range(-32, 32),
			0.05,
			randf_range(-18, 18)
		)
		drift.scale = Vector3(1.0, 0.30, 1.0)
		geom.add_child(drift)


func _build_d5_entrance_arch(geom: Node) -> void:
	## Epic-5 T2: frost-crystal entrance arch — twin tall ice spires curving
	## together at the top, with hanging icicles and a soft blue light.
	var arch: Node3D = Node3D.new()
	arch.name = "D5FrostArch"
	arch.position = Vector3(D5_CENTER.x - 32.0, 0.0, 0.0)
	geom.add_child(arch)
	var ice_mat: StandardMaterial3D = StandardMaterial3D.new()
	ice_mat.albedo_color = Color(0.55, 0.80, 0.95, 0.85)
	ice_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	ice_mat.emission_enabled = true
	ice_mat.emission = Color(0.40, 0.75, 0.95)
	ice_mat.emission_energy_multiplier = 0.85
	ice_mat.metallic = 0.65
	ice_mat.roughness = 0.10
	# 2 ice spires (curved cones via tapered cylinders)
	for sx in [-2.40, 2.40]:
		var spire: MeshInstance3D = MeshInstance3D.new()
		var sm: CylinderMesh = CylinderMesh.new()
		sm.top_radius = 0.20
		sm.bottom_radius = 0.85
		sm.height = 5.40
		spire.mesh = sm
		spire.material_override = ice_mat
		spire.position = Vector3(sx, 2.70, 0)
		# Slight inward lean
		spire.rotation_degrees = Vector3(0, 0, -10.0 if sx > 0 else 10.0)
		arch.add_child(spire)
		# Spire collision
		var sb: StaticBody3D = StaticBody3D.new()
		sb.position = Vector3(sx, 2.70, 0)
		var cs: CollisionShape3D = CollisionShape3D.new()
		var cap: CapsuleShape3D = CapsuleShape3D.new()
		cap.radius = 0.85
		cap.height = 5.40
		cs.shape = cap
		sb.add_child(cs)
		arch.add_child(sb)
	# Top crossing crystal beam (horizontal prism with ice glow)
	var crown: MeshInstance3D = MeshInstance3D.new()
	var cm: PrismMesh = PrismMesh.new()
	cm.size = Vector3(5.20, 0.65, 0.85)
	crown.mesh = cm
	crown.material_override = ice_mat
	crown.position = Vector3(0, 5.50, 0)
	arch.add_child(crown)
	# 8 hanging icicles
	for i in 8:
		var ic: MeshInstance3D = MeshInstance3D.new()
		var im: PrismMesh = PrismMesh.new()
		im.size = Vector3(0.18, 0.55 + randf() * 0.40, 0.18)
		ic.mesh = im
		ic.material_override = ice_mat
		ic.position = Vector3(-2.30 + i * 0.66, 4.85, 0)
		ic.rotation_degrees = Vector3(180, 0, 0)
		arch.add_child(ic)
	# Cyan light under the arch
	var light: OmniLight3D = OmniLight3D.new()
	light.light_color = Color(0.40, 0.75, 1.0)
	light.light_energy = 2.6
	light.omni_range = 9.0
	light.position = Vector3(0, 4.20, 0)
	arch.add_child(light)
	# Subtle cold pulse
	var tw: Tween = light.create_tween().set_loops()
	tw.tween_property(light, "light_energy", 3.2, 1.6)
	tw.tween_property(light, "light_energy", 2.6, 1.6)


func _build_d5_great_monolith(geom: Node) -> void:
	## Epic-5 T3: GREAT FROZEN MONOLITH — towering ice obelisk with embedded
	## flickering data core, hovering rune fragments, and aura beam.
	var mono: Node3D = Node3D.new()
	mono.name = "GreatFrozenMonolith"
	mono.position = Vector3(D5_CENTER.x, 0.0, 0.0)
	geom.add_child(mono)
	# Pedestal stone
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.55, 0.65, 0.75)
	stone_mat.roughness = 0.85
	var ped: MeshInstance3D = MeshInstance3D.new()
	var pm: BoxMesh = BoxMesh.new()
	pm.size = Vector3(4.20, 0.55, 4.20)
	ped.mesh = pm
	ped.material_override = stone_mat
	ped.position = Vector3(0, 0.27, 0)
	mono.add_child(ped)
	# Main monolith — tall translucent ice slab
	var ice_mat: StandardMaterial3D = StandardMaterial3D.new()
	ice_mat.albedo_color = Color(0.55, 0.80, 0.95, 0.78)
	ice_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	ice_mat.emission_enabled = true
	ice_mat.emission = Color(0.40, 0.80, 0.95)
	ice_mat.emission_energy_multiplier = 1.4
	ice_mat.metallic = 0.55
	ice_mat.roughness = 0.10
	var slab: MeshInstance3D = MeshInstance3D.new()
	var slm: BoxMesh = BoxMesh.new()
	slm.size = Vector3(2.40, 8.50, 1.10)
	slab.mesh = slm
	slab.material_override = ice_mat
	slab.position = Vector3(0, 4.80, 0)
	mono.add_child(slab)
	# Embedded data core (small bright cyan sphere inside the slab)
	var core_mat: StandardMaterial3D = StandardMaterial3D.new()
	core_mat.albedo_color = Color(0.30, 0.95, 1.0)
	core_mat.emission_enabled = true
	core_mat.emission = Color(0.30, 1.0, 1.0)
	core_mat.emission_energy_multiplier = 4.5
	core_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var core: MeshInstance3D = MeshInstance3D.new()
	var cmm: SphereMesh = SphereMesh.new()
	cmm.radius = 0.45
	cmm.height = 0.80
	core.mesh = cmm
	core.material_override = core_mat
	core.position = Vector3(0, 4.80, 0)
	mono.add_child(core)
	# Pulse the core (data heartbeat)
	var tw: Tween = core.create_tween().set_loops()
	tw.tween_property(core, "scale", Vector3.ONE * 1.20, 0.8)
	tw.tween_property(core, "scale", Vector3.ONE * 0.85, 0.8)
	# 6 hovering rune fragments orbiting the slab
	var rune_mat: StandardMaterial3D = StandardMaterial3D.new()
	rune_mat.albedo_color = Color(0.55, 0.85, 0.95)
	rune_mat.emission_enabled = true
	rune_mat.emission = Color(0.40, 0.85, 1.0)
	rune_mat.emission_energy_multiplier = 1.8
	rune_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var pivot: Node3D = Node3D.new()
	pivot.position = Vector3(0, 4.80, 0)
	mono.add_child(pivot)
	for i in 6:
		var ang: float = (TAU / 6.0) * i
		var rune: MeshInstance3D = MeshInstance3D.new()
		var rm: BoxMesh = BoxMesh.new()
		rm.size = Vector3(0.30, 0.45, 0.06)
		rune.mesh = rm
		rune.material_override = rune_mat
		rune.position = Vector3(cos(ang) * 2.40, sin(i) * 0.50, sin(ang) * 2.40)
		rune.rotation = Vector3(0, ang + PI * 0.5, 0)
		pivot.add_child(rune)
	var trot: Tween = pivot.create_tween().set_loops()
	trot.tween_property(pivot, "rotation_degrees:y", 360.0, 12.0)
	trot.tween_property(pivot, "rotation_degrees:y", 0.0, 0.0)
	# Top beam of cold light
	var beam: MeshInstance3D = MeshInstance3D.new()
	var beam_m: CylinderMesh = CylinderMesh.new()
	beam_m.top_radius = 0.10
	beam_m.bottom_radius = 0.55
	beam_m.height = 14.0
	beam.mesh = beam_m
	var beam_mat: StandardMaterial3D = StandardMaterial3D.new()
	beam_mat.albedo_color = Color(0.55, 0.85, 1.0, 0.45)
	beam_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	beam_mat.emission_enabled = true
	beam_mat.emission = Color(0.40, 0.85, 1.0)
	beam_mat.emission_energy_multiplier = 1.4
	beam_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	beam.material_override = beam_mat
	beam.position = Vector3(0, 16.0, 0)
	mono.add_child(beam)
	# Cold central light
	var light: OmniLight3D = OmniLight3D.new()
	light.light_color = Color(0.45, 0.85, 1.0)
	light.light_energy = 4.5
	light.omni_range = 18.0
	light.position = Vector3(0, 4.80, 0)
	mono.add_child(light)
	# Slab collision
	var sb: StaticBody3D = StaticBody3D.new()
	sb.position = Vector3(0, 4.80, 0)
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(2.40, 8.50, 1.10)
	cs.shape = cb
	sb.add_child(cs)
	mono.add_child(sb)


func _build_d5_cryo_keeper_npc(town: Node) -> void:
	## Epic-5 T4: cryo-keeper NPC — pale-robed archivist who guards the
	## frozen archive entrance.
	var npc_slots: Node3D = town.get_node_or_null("%NPCSlots") as Node3D
	if npc_slots == null:
		return
	var slot: Marker3D = Marker3D.new()
	slot.name = "CryoKeeperSlot"
	slot.position = Vector3(D5_CENTER.x - 28.0, 0.0, 3.0)
	npc_slots.add_child(slot)
	var npc_scene: PackedScene = load("res://scenes/entities/npcs/VillagerR3.tscn") as PackedScene
	if npc_scene == null:
		return
	var npc: Node3D = npc_scene.instantiate() as Node3D
	npc.name = "CryoKeeper"
	if "npc_name" in npc:
		npc.set("npc_name", "Frostward")
	if "npc_id" in npc:
		npc.set("npc_id", "cryo_keeper_d5")
	slot.add_child(npc)
	# Pale-blue hooded robe
	var robe: MeshInstance3D = MeshInstance3D.new()
	var rm: BoxMesh = BoxMesh.new()
	rm.size = Vector3(0.65, 1.00, 0.45)
	robe.mesh = rm
	var robe_mat: StandardMaterial3D = StandardMaterial3D.new()
	robe_mat.albedo_color = Color(0.65, 0.85, 0.95)
	robe_mat.emission_enabled = true
	robe_mat.emission = Color(0.45, 0.75, 0.95)
	robe_mat.emission_energy_multiplier = 0.30
	robe_mat.roughness = 0.75
	robe.material_override = robe_mat
	robe.position = Vector3(0, 0.55, 0)
	npc.add_child(robe)
	# Hood (sphere)
	var hood: MeshInstance3D = MeshInstance3D.new()
	var hm: SphereMesh = SphereMesh.new()
	hm.radius = 0.20
	hm.height = 0.36
	hood.mesh = hm
	hood.material_override = robe_mat
	hood.position = Vector3(0, 1.42, 0)
	npc.add_child(hood)
	# Frost staff (vertical cylinder + glowing cyan crystal top)
	var staff: MeshInstance3D = MeshInstance3D.new()
	var stm: CylinderMesh = CylinderMesh.new()
	stm.top_radius = 0.05
	stm.bottom_radius = 0.06
	stm.height = 1.85
	staff.mesh = stm
	var staff_mat: StandardMaterial3D = StandardMaterial3D.new()
	staff_mat.albedo_color = Color(0.30, 0.40, 0.50)
	staff_mat.metallic = 0.55
	staff_mat.roughness = 0.45
	staff.material_override = staff_mat
	staff.position = Vector3(0.45, 0.92, 0)
	npc.add_child(staff)
	var crystal: MeshInstance3D = MeshInstance3D.new()
	var cmm: SphereMesh = SphereMesh.new()
	cmm.radius = 0.14
	cmm.height = 0.24
	crystal.mesh = cmm
	var crystal_mat: StandardMaterial3D = StandardMaterial3D.new()
	crystal_mat.albedo_color = Color(0.40, 0.85, 1.0)
	crystal_mat.emission_enabled = true
	crystal_mat.emission = Color(0.40, 0.95, 1.0)
	crystal_mat.emission_energy_multiplier = 2.5
	crystal_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	crystal.material_override = crystal_mat
	crystal.position = Vector3(0.45, 1.92, 0)
	npc.add_child(crystal)
	# Crystal pulse
	var tw: Tween = crystal.create_tween().set_loops()
	tw.tween_property(crystal, "scale", Vector3.ONE * 1.20, 1.0)
	tw.tween_property(crystal, "scale", Vector3.ONE * 0.85, 1.0)


func _build_d5_cryo_pods(geom: Node) -> void:
	## Epic-5 T6: 6 vertical cryo-pod chambers in a row, each containing
	## a faintly visible silhouette of a frozen data-spirit.
	var pods: Node3D = Node3D.new()
	pods.name = "CryoPods"
	pods.position = Vector3(D5_CENTER.x - 14.0, 0.0, -10.0)
	geom.add_child(pods)
	var metal_mat: StandardMaterial3D = StandardMaterial3D.new()
	metal_mat.albedo_color = Color(0.40, 0.50, 0.60)
	metal_mat.metallic = 0.85
	metal_mat.roughness = 0.30
	var glass_mat: StandardMaterial3D = StandardMaterial3D.new()
	glass_mat.albedo_color = Color(0.55, 0.85, 1.0, 0.55)
	glass_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	glass_mat.emission_enabled = true
	glass_mat.emission = Color(0.40, 0.85, 1.0)
	glass_mat.emission_energy_multiplier = 0.85
	glass_mat.metallic = 0.55
	glass_mat.roughness = 0.10
	var spirit_mat: StandardMaterial3D = StandardMaterial3D.new()
	spirit_mat.albedo_color = Color(0.40, 0.95, 1.0, 0.65)
	spirit_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	spirit_mat.emission_enabled = true
	spirit_mat.emission = Color(0.30, 0.95, 1.0)
	spirit_mat.emission_energy_multiplier = 1.4
	spirit_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for i in 6:
		var pod: Node3D = Node3D.new()
		pod.position = Vector3(i * 1.85, 0, 0)
		pods.add_child(pod)
		# Base
		var base: MeshInstance3D = MeshInstance3D.new()
		var bm: CylinderMesh = CylinderMesh.new()
		bm.top_radius = 0.65
		bm.bottom_radius = 0.75
		bm.height = 0.40
		base.mesh = bm
		base.material_override = metal_mat
		base.position = Vector3(0, 0.20, 0)
		pod.add_child(base)
		# Glass tube
		var tube: MeshInstance3D = MeshInstance3D.new()
		var tm: CylinderMesh = CylinderMesh.new()
		tm.top_radius = 0.55
		tm.bottom_radius = 0.55
		tm.height = 2.30
		tube.mesh = tm
		tube.material_override = glass_mat
		tube.position = Vector3(0, 1.55, 0)
		pod.add_child(tube)
		# Cap (metal hemisphere)
		var cap: MeshInstance3D = MeshInstance3D.new()
		var cmm: SphereMesh = SphereMesh.new()
		cmm.radius = 0.55
		cmm.height = 0.55
		cap.mesh = cmm
		cap.material_override = metal_mat
		cap.position = Vector3(0, 2.85, 0)
		cap.scale = Vector3(1.0, 0.55, 1.0)
		pod.add_child(cap)
		# Frozen spirit silhouette inside (humanoid blob)
		var spirit: Node3D = Node3D.new()
		spirit.position = Vector3(0, 1.55, 0)
		pod.add_child(spirit)
		var body: MeshInstance3D = MeshInstance3D.new()
		var bbm: SphereMesh = SphereMesh.new()
		bbm.radius = 0.30
		bbm.height = 0.85
		body.mesh = bbm
		body.material_override = spirit_mat
		body.position = Vector3(0, 0, 0)
		body.scale = Vector3(0.85, 1.10, 0.85)
		spirit.add_child(body)
		var head: MeshInstance3D = MeshInstance3D.new()
		var hm: SphereMesh = SphereMesh.new()
		hm.radius = 0.18
		hm.height = 0.32
		head.mesh = hm
		head.material_override = spirit_mat
		head.position = Vector3(0, 0.55, 0)
		spirit.add_child(head)
		# Slow gentle bob (tube life-support breathing)
		var tw: Tween = spirit.create_tween().set_loops()
		tw.tween_property(spirit, "position:y", 1.65, 2.0 + randf() * 0.5)
		tw.tween_property(spirit, "position:y", 1.45, 2.0 + randf() * 0.5)
		# Status lights at the base (3 small dots)
		for k in 3:
			var dot: MeshInstance3D = MeshInstance3D.new()
			var dmm: SphereMesh = SphereMesh.new()
			dmm.radius = 0.05
			dmm.height = 0.10
			dot.mesh = dmm
			var dot_mat: StandardMaterial3D = StandardMaterial3D.new()
			dot_mat.albedo_color = Color(0.30, 1.0, 0.55) if k == 0 else (Color(1.0, 0.85, 0.30) if k == 1 else Color(0.95, 0.30, 0.30))
			dot_mat.emission_enabled = true
			dot_mat.emission = dot_mat.albedo_color
			dot_mat.emission_energy_multiplier = 2.5
			dot_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
			dot.material_override = dot_mat
			var ang: float = (TAU / 3.0) * k
			dot.position = Vector3(cos(ang) * 0.55, 0.30, sin(ang) * 0.55)
			pod.add_child(dot)
		# Pod collision
		var sb: StaticBody3D = StaticBody3D.new()
		var cs: CollisionShape3D = CollisionShape3D.new()
		var capsh: CapsuleShape3D = CapsuleShape3D.new()
		capsh.radius = 0.65
		capsh.height = 3.10
		cs.shape = capsh
		cs.position = Vector3(0, 1.55, 0)
		sb.add_child(cs)
		pod.add_child(sb)


func _build_d5_ice_golem(geom: Node) -> void:
	## Epic-5 T7: large hostile ice golem creature — chunky humanoid with
	## glowing cyan eyes and a slow patrol path. Decorative for now.
	var golem: Node3D = Node3D.new()
	golem.name = "IceGolem"
	golem.position = Vector3(D5_CENTER.x + 12.0, 0.0, -8.0)
	geom.add_child(golem)
	var ice_mat: StandardMaterial3D = StandardMaterial3D.new()
	ice_mat.albedo_color = Color(0.70, 0.85, 0.95)
	ice_mat.emission_enabled = true
	ice_mat.emission = Color(0.40, 0.75, 0.95)
	ice_mat.emission_energy_multiplier = 0.30
	ice_mat.metallic = 0.55
	ice_mat.roughness = 0.20
	# Body (large chunky box)
	var body: MeshInstance3D = MeshInstance3D.new()
	var bm: BoxMesh = BoxMesh.new()
	bm.size = Vector3(1.40, 1.85, 0.95)
	body.mesh = bm
	body.material_override = ice_mat
	body.position = Vector3(0, 1.10, 0)
	golem.add_child(body)
	# Head (smaller block on top)
	var head: MeshInstance3D = MeshInstance3D.new()
	var hm: BoxMesh = BoxMesh.new()
	hm.size = Vector3(0.85, 0.75, 0.75)
	head.mesh = hm
	head.material_override = ice_mat
	head.position = Vector3(0, 2.40, 0)
	golem.add_child(head)
	# Cyan eye slits
	var eye_mat: StandardMaterial3D = StandardMaterial3D.new()
	eye_mat.albedo_color = Color(0.30, 1.0, 1.0)
	eye_mat.emission_enabled = true
	eye_mat.emission = Color(0.30, 1.0, 1.0)
	eye_mat.emission_energy_multiplier = 4.0
	eye_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for ex in [-0.20, 0.20]:
		var eye: MeshInstance3D = MeshInstance3D.new()
		var em: BoxMesh = BoxMesh.new()
		em.size = Vector3(0.16, 0.06, 0.04)
		eye.mesh = em
		eye.material_override = eye_mat
		eye.position = Vector3(ex, 2.45, 0.40)
		golem.add_child(eye)
	# Arms (two large rectangular boxes hanging at sides)
	for sx in [-1.10, 1.10]:
		var arm: MeshInstance3D = MeshInstance3D.new()
		var am: BoxMesh = BoxMesh.new()
		am.size = Vector3(0.55, 1.65, 0.55)
		arm.mesh = am
		arm.material_override = ice_mat
		arm.position = Vector3(sx, 1.10, 0)
		golem.add_child(arm)
		# Fist (slightly larger sphere)
		var fist: MeshInstance3D = MeshInstance3D.new()
		var fm: SphereMesh = SphereMesh.new()
		fm.radius = 0.40
		fm.height = 0.70
		fist.mesh = fm
		fist.material_override = ice_mat
		fist.position = Vector3(sx, 0.20, 0)
		golem.add_child(fist)
	# Legs (two short stout boxes)
	for sx in [-0.35, 0.35]:
		var leg: MeshInstance3D = MeshInstance3D.new()
		var lm: BoxMesh = BoxMesh.new()
		lm.size = Vector3(0.50, 0.40, 0.55)
		leg.mesh = lm
		leg.material_override = ice_mat
		leg.position = Vector3(sx, 0.20, 0)
		golem.add_child(leg)
	# Patrol tween — slow back and forth
	var tw: Tween = golem.create_tween().set_loops()
	tw.tween_property(golem, "position", Vector3(D5_CENTER.x + 16.0, 0.0, -8.0), 5.0)
	tw.tween_property(golem, "rotation_degrees:y", 180.0, 0.6)
	tw.tween_property(golem, "position", Vector3(D5_CENTER.x + 8.0, 0.0, -8.0), 5.0)
	tw.tween_property(golem, "rotation_degrees:y", 0.0, 0.6)
	# Body collision
	var sb: StaticBody3D = StaticBody3D.new()
	sb.position = Vector3(0, 1.10, 0)
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(2.40, 2.20, 1.10)
	cs.shape = cb
	sb.add_child(cs)
	golem.add_child(sb)


func _build_d5_frost_servers(geom: Node) -> void:
	## Epic-5 T8: frost-tech server bank — 4 tall metal cabinets with cyan
	## flicker LED grids and frost halos around them.
	var bank: Node3D = Node3D.new()
	bank.name = "FrostServers"
	bank.position = Vector3(D5_CENTER.x + 8.0, 0.0, 12.0)
	geom.add_child(bank)
	var metal_mat: StandardMaterial3D = StandardMaterial3D.new()
	metal_mat.albedo_color = Color(0.30, 0.40, 0.50)
	metal_mat.metallic = 0.85
	metal_mat.roughness = 0.30
	var led_mat: StandardMaterial3D = StandardMaterial3D.new()
	led_mat.albedo_color = Color(0.30, 0.95, 1.0)
	led_mat.emission_enabled = true
	led_mat.emission = Color(0.30, 1.0, 1.0)
	led_mat.emission_energy_multiplier = 2.5
	led_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for i in 4:
		var rack: Node3D = Node3D.new()
		rack.position = Vector3(i * 1.30, 0, 0)
		bank.add_child(rack)
		# Cabinet
		var cab: MeshInstance3D = MeshInstance3D.new()
		var cm: BoxMesh = BoxMesh.new()
		cm.size = Vector3(1.10, 2.85, 0.85)
		cab.mesh = cm
		cab.material_override = metal_mat
		cab.position = Vector3(0, 1.42, 0)
		rack.add_child(cab)
		# 8 horizontal LED strips on the front
		for j in 8:
			var strip: MeshInstance3D = MeshInstance3D.new()
			var sm: BoxMesh = BoxMesh.new()
			sm.size = Vector3(0.85, 0.06, 0.04)
			strip.mesh = sm
			strip.material_override = led_mat
			strip.position = Vector3(0, 0.45 + j * 0.30, 0.42)
			rack.add_child(strip)
			# Flicker tween
			var tw: Tween = strip.create_tween().set_loops()
			tw.tween_interval((i * 8 + j) * 0.05)
			tw.tween_property(strip, "scale:x", 0.40, 0.30)
			tw.tween_property(strip, "scale:x", 1.0, 0.30)
		# Frost halo light
		var light: OmniLight3D = OmniLight3D.new()
		light.light_color = Color(0.40, 0.85, 1.0)
		light.light_energy = 1.2
		light.omni_range = 2.6
		light.position = Vector3(0, 1.85, 0.50)
		rack.add_child(light)
		# Cabinet collision
		var sb: StaticBody3D = StaticBody3D.new()
		sb.position = Vector3(0, 1.42, 0)
		var cs: CollisionShape3D = CollisionShape3D.new()
		var cb: BoxShape3D = BoxShape3D.new()
		cb.size = Vector3(1.10, 2.85, 0.85)
		cs.shape = cb
		sb.add_child(cs)
		rack.add_child(sb)


func _build_d5_crystal_tree(geom: Node) -> void:
	## Epic-5 T9: ice crystal tree — translucent prismatic trunk with
	## branches of glowing cyan crystals instead of leaves.
	var tree: Node3D = Node3D.new()
	tree.name = "CrystalTree"
	tree.position = Vector3(D5_CENTER.x - 8.0, 0.0, 12.0)
	geom.add_child(tree)
	var ice_mat: StandardMaterial3D = StandardMaterial3D.new()
	ice_mat.albedo_color = Color(0.65, 0.85, 0.95, 0.85)
	ice_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	ice_mat.emission_enabled = true
	ice_mat.emission = Color(0.40, 0.85, 0.95)
	ice_mat.emission_energy_multiplier = 0.65
	ice_mat.metallic = 0.55
	ice_mat.roughness = 0.10
	var bright_mat: StandardMaterial3D = StandardMaterial3D.new()
	bright_mat.albedo_color = Color(0.30, 0.95, 1.0)
	bright_mat.emission_enabled = true
	bright_mat.emission = Color(0.30, 1.0, 1.0)
	bright_mat.emission_energy_multiplier = 2.5
	bright_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	# Trunk
	var trunk: MeshInstance3D = MeshInstance3D.new()
	var trm: CylinderMesh = CylinderMesh.new()
	trm.top_radius = 0.20
	trm.bottom_radius = 0.45
	trm.height = 3.40
	trunk.mesh = trm
	trunk.material_override = ice_mat
	trunk.position = Vector3(0, 1.70, 0)
	tree.add_child(trunk)
	# 5 branches as prisms angling outward
	for i in 5:
		var ang: float = (TAU / 5.0) * i
		var branch: MeshInstance3D = MeshInstance3D.new()
		var bm: PrismMesh = PrismMesh.new()
		bm.size = Vector3(0.20, 1.40, 0.20)
		branch.mesh = bm
		branch.material_override = ice_mat
		branch.position = Vector3(cos(ang) * 0.55, 3.20, sin(ang) * 0.55)
		branch.rotation = Vector3(deg_to_rad(35) * sin(ang), ang, deg_to_rad(35) * cos(ang))
		tree.add_child(branch)
		# Cluster of bright crystal "leaves" at the branch tip
		for j in 4:
			var crystal: MeshInstance3D = MeshInstance3D.new()
			var cm: PrismMesh = PrismMesh.new()
			cm.size = Vector3(0.16, 0.30, 0.16)
			crystal.mesh = cm
			crystal.material_override = bright_mat
			crystal.position = Vector3(
				cos(ang) * 1.30 + randf_range(-0.20, 0.20),
				3.85 + randf_range(-0.20, 0.20),
				sin(ang) * 1.30 + randf_range(-0.20, 0.20)
			)
			crystal.rotation_degrees = Vector3(randf_range(-30, 30), randf_range(0, 360), randf_range(-30, 30))
			tree.add_child(crystal)
	# Top crystal cluster
	for i in 3:
		var top: MeshInstance3D = MeshInstance3D.new()
		var tm2: PrismMesh = PrismMesh.new()
		tm2.size = Vector3(0.22, 0.45, 0.22)
		top.mesh = tm2
		top.material_override = bright_mat
		top.position = Vector3(randf_range(-0.20, 0.20), 3.65 + i * 0.15, randf_range(-0.20, 0.20))
		tree.add_child(top)
	# Trunk collision
	var sb: StaticBody3D = StaticBody3D.new()
	sb.position = Vector3(0, 1.70, 0)
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cap: CapsuleShape3D = CapsuleShape3D.new()
	cap.radius = 0.45
	cap.height = 3.40
	cs.shape = cap
	sb.add_child(cs)
	tree.add_child(sb)


func _build_d5_snowfall(geom: Node) -> void:
	## Epic-5 T10: ambient snowfall — GPU particles drifting downward over
	## the entire Frozen Cache district.
	var snow: GPUParticles3D = GPUParticles3D.new()
	snow.name = "Snowfall"
	snow.position = Vector3(D5_CENTER.x, 14.0, 0.0)
	snow.amount = 200
	snow.lifetime = 9.0
	snow.preprocess = 5.0
	snow.explosiveness = 0.0
	snow.randomness = 0.7
	snow.visibility_aabb = AABB(Vector3(-40, -16, -25), Vector3(80, 30, 50))
	var pm: ParticleProcessMaterial = ParticleProcessMaterial.new()
	pm.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	pm.emission_box_extents = Vector3(35, 0.5, 22)
	pm.direction = Vector3(0.10, -1, 0.05)
	pm.spread = 18.0
	pm.gravity = Vector3(0.05, -0.85, 0.04)
	pm.initial_velocity_min = 0.45
	pm.initial_velocity_max = 0.95
	pm.angular_velocity_min = -45.0
	pm.angular_velocity_max = 45.0
	pm.scale_min = 0.06
	pm.scale_max = 0.14
	pm.color = Color(0.95, 0.97, 1.0, 0.95)
	snow.process_material = pm
	# Snowflake mesh — small flat box
	var flake_mesh: BoxMesh = BoxMesh.new()
	flake_mesh.size = Vector3(0.10, 0.02, 0.10)
	snow.draw_pass_1 = flake_mesh
	var fmat: StandardMaterial3D = StandardMaterial3D.new()
	fmat.albedo_color = Color(0.95, 0.97, 1.0)
	fmat.emission_enabled = true
	fmat.emission = Color(0.85, 0.95, 1.0)
	fmat.emission_energy_multiplier = 1.4
	fmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	fmat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	flake_mesh.material = fmat
	geom.add_child(snow)


func _build_d5_glacier_wall(geom: Node) -> void:
	## Epic-5 T11: 12m-wide glacier wall with embedded data slabs glowing
	## from within. Acts as visual backdrop on the north side of D5.
	var wall: Node3D = Node3D.new()
	wall.name = "GlacierWall"
	wall.position = Vector3(D5_CENTER.x + 4.0, 0.0, -16.0)
	geom.add_child(wall)
	var ice_mat: StandardMaterial3D = StandardMaterial3D.new()
	ice_mat.albedo_color = Color(0.65, 0.85, 0.95, 0.85)
	ice_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	ice_mat.emission_enabled = true
	ice_mat.emission = Color(0.40, 0.85, 0.95)
	ice_mat.emission_energy_multiplier = 0.65
	ice_mat.metallic = 0.45
	ice_mat.roughness = 0.20
	# Main wall slab
	var slab: MeshInstance3D = MeshInstance3D.new()
	var sm: BoxMesh = BoxMesh.new()
	sm.size = Vector3(14.0, 5.50, 1.40)
	slab.mesh = sm
	slab.material_override = ice_mat
	slab.position = Vector3(0, 2.75, 0)
	wall.add_child(slab)
	# 5 jagged ice spikes rising from the top
	for i in 5:
		var spike: MeshInstance3D = MeshInstance3D.new()
		var spm: PrismMesh = PrismMesh.new()
		spm.size = Vector3(0.85, 1.40 + randf() * 0.85, 0.85)
		spike.mesh = spm
		spike.material_override = ice_mat
		spike.position = Vector3(-5.5 + i * 2.75, 5.50 + spm.size.y * 0.5, 0)
		wall.add_child(spike)
	# 6 embedded data slabs (small bright glowing rectangles)
	var data_mat: StandardMaterial3D = StandardMaterial3D.new()
	data_mat.albedo_color = Color(0.30, 1.0, 1.0)
	data_mat.emission_enabled = true
	data_mat.emission = Color(0.30, 1.0, 1.0)
	data_mat.emission_energy_multiplier = 3.5
	data_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for i in 6:
		var data: MeshInstance3D = MeshInstance3D.new()
		var dm: BoxMesh = BoxMesh.new()
		dm.size = Vector3(0.55, 0.85, 0.06)
		data.mesh = dm
		data.material_override = data_mat
		data.position = Vector3(-5.0 + i * 2.0, 1.50 + randf_range(-0.30, 0.85), 0.72)
		wall.add_child(data)
		# Subtle pulse
		var tw: Tween = data.create_tween().set_loops()
		tw.tween_interval(i * 0.25)
		tw.tween_property(data, "scale:y", 1.20, 0.8)
		tw.tween_property(data, "scale:y", 0.85, 0.8)
	# Wall collision
	var sb: StaticBody3D = StaticBody3D.new()
	sb.position = Vector3(0, 2.75, 0)
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(14.0, 5.50, 1.40)
	cs.shape = cb
	sb.add_child(cs)
	wall.add_child(sb)


func _build_d5_frozen_waterfall(geom: Node) -> void:
	## Epic-5 T12: frozen waterfall — 3 vertical translucent ice columns
	## frozen mid-flow with cyan light underneath, evoking suspended motion.
	var fall: Node3D = Node3D.new()
	fall.name = "FrozenWaterfall"
	fall.position = Vector3(D5_CENTER.x - 16.0, 0.0, 14.0)
	geom.add_child(fall)
	# Stone cliff base
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.40, 0.45, 0.50)
	stone_mat.roughness = 0.92
	var cliff: MeshInstance3D = MeshInstance3D.new()
	var cm: BoxMesh = BoxMesh.new()
	cm.size = Vector3(4.20, 4.50, 1.20)
	cliff.mesh = cm
	cliff.material_override = stone_mat
	cliff.position = Vector3(0, 2.25, -1.0)
	fall.add_child(cliff)
	# 3 frozen flow columns (slightly curving forward)
	var ice_mat: StandardMaterial3D = StandardMaterial3D.new()
	ice_mat.albedo_color = Color(0.55, 0.85, 0.95, 0.75)
	ice_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	ice_mat.emission_enabled = true
	ice_mat.emission = Color(0.40, 0.85, 0.95)
	ice_mat.emission_energy_multiplier = 0.85
	ice_mat.metallic = 0.55
	ice_mat.roughness = 0.10
	for sx in [-1.20, 0.0, 1.20]:
		var col: MeshInstance3D = MeshInstance3D.new()
		var cm2: CylinderMesh = CylinderMesh.new()
		cm2.top_radius = 0.30
		cm2.bottom_radius = 0.55
		cm2.height = 4.20
		col.mesh = cm2
		col.material_override = ice_mat
		col.position = Vector3(sx, 2.10, 0)
		# Slight forward lean
		col.rotation_degrees = Vector3(8, 0, 0)
		fall.add_child(col)
	# Pool at the base (flat translucent disc)
	var pool: MeshInstance3D = MeshInstance3D.new()
	var pm: CylinderMesh = CylinderMesh.new()
	pm.top_radius = 2.20
	pm.bottom_radius = 2.20
	pm.height = 0.10
	pool.mesh = pm
	pool.material_override = ice_mat
	pool.position = Vector3(0, 0.05, 0.65)
	fall.add_child(pool)
	# Light beneath pool
	var light: OmniLight3D = OmniLight3D.new()
	light.light_color = Color(0.40, 0.85, 1.0)
	light.light_energy = 2.5
	light.omni_range = 6.0
	light.position = Vector3(0, 0.40, 0.65)
	fall.add_child(light)
	# Pulse the light
	var tw: Tween = light.create_tween().set_loops()
	tw.tween_property(light, "light_energy", 3.0, 1.4)
	tw.tween_property(light, "light_energy", 2.5, 1.4)
	# Cliff collision
	var sb: StaticBody3D = StaticBody3D.new()
	sb.position = Vector3(0, 2.25, -1.0)
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(4.20, 4.50, 1.20)
	cs.shape = cb
	sb.add_child(cs)
	fall.add_child(sb)


func _build_d5_data_archaeologist_npc(town: Node) -> void:
	## Epic-5 T13: data archaeologist NPC — heavy parka, holding a small
	## glowing data fragment they "excavated" from the ice.
	var npc_slots: Node3D = town.get_node_or_null("%NPCSlots") as Node3D
	if npc_slots == null:
		return
	var slot: Marker3D = Marker3D.new()
	slot.name = "DataArchaeologistSlot"
	slot.position = Vector3(D5_CENTER.x - 6.0, 0.0, -10.0)
	npc_slots.add_child(slot)
	var npc_scene: PackedScene = load("res://scenes/entities/npcs/VillagerR3.tscn") as PackedScene
	if npc_scene == null:
		return
	var npc: Node3D = npc_scene.instantiate() as Node3D
	npc.name = "DataArchaeologist"
	if "npc_name" in npc:
		npc.set("npc_name", "Stratlin")
	if "npc_id" in npc:
		npc.set("npc_id", "archaeo_d5")
	slot.add_child(npc)
	# Heavy parka (large box)
	var parka: MeshInstance3D = MeshInstance3D.new()
	var pmm: BoxMesh = BoxMesh.new()
	pmm.size = Vector3(0.75, 1.05, 0.50)
	parka.mesh = pmm
	var parka_mat: StandardMaterial3D = StandardMaterial3D.new()
	parka_mat.albedo_color = Color(0.85, 0.55, 0.20)
	parka_mat.roughness = 0.85
	parka.material_override = parka_mat
	parka.position = Vector3(0, 0.55, 0)
	npc.add_child(parka)
	# Fur trim hood (white sphere)
	var hood: MeshInstance3D = MeshInstance3D.new()
	var hm: SphereMesh = SphereMesh.new()
	hm.radius = 0.24
	hm.height = 0.42
	hood.mesh = hm
	var fur_mat: StandardMaterial3D = StandardMaterial3D.new()
	fur_mat.albedo_color = Color(0.95, 0.95, 0.92)
	fur_mat.roughness = 0.95
	hood.material_override = fur_mat
	hood.position = Vector3(0, 1.40, 0)
	npc.add_child(hood)
	# Held data fragment (small bright cube)
	var frag: MeshInstance3D = MeshInstance3D.new()
	var fm: BoxMesh = BoxMesh.new()
	fm.size = Vector3(0.20, 0.20, 0.20)
	frag.mesh = fm
	var frag_mat: StandardMaterial3D = StandardMaterial3D.new()
	frag_mat.albedo_color = Color(0.30, 1.0, 1.0)
	frag_mat.emission_enabled = true
	frag_mat.emission = Color(0.30, 1.0, 1.0)
	frag_mat.emission_energy_multiplier = 3.5
	frag_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	frag.material_override = frag_mat
	frag.position = Vector3(0.45, 0.85, 0.18)
	npc.add_child(frag)
	# Fragment hover + spin
	var ts: Tween = frag.create_tween().set_loops()
	ts.tween_property(frag, "rotation_degrees:y", 360.0, 4.0)
	ts.tween_property(frag, "rotation_degrees:y", 0.0, 0.0)
	var th: Tween = frag.create_tween().set_loops()
	th.tween_property(frag, "position:y", 0.95, 1.2)
	th.tween_property(frag, "position:y", 0.85, 1.2)


func _build_d5_ice_fishing_hole(geom: Node) -> void:
	## Epic-5 T14: ice fishing hole on a frozen pond — round disc of ice
	## with a circular hole in the center, a tiny stool, and a fishing rod.
	var hole: Node3D = Node3D.new()
	hole.name = "IceFishingHole"
	hole.position = Vector3(D5_CENTER.x + 4.0, 0.0, 8.0)
	geom.add_child(hole)
	var ice_mat: StandardMaterial3D = StandardMaterial3D.new()
	ice_mat.albedo_color = Color(0.65, 0.88, 0.95, 0.92)
	ice_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	ice_mat.emission_enabled = true
	ice_mat.emission = Color(0.40, 0.85, 0.95)
	ice_mat.emission_energy_multiplier = 0.40
	ice_mat.metallic = 0.45
	ice_mat.roughness = 0.20
	# Frozen pond disc (large flat cylinder)
	var pond: MeshInstance3D = MeshInstance3D.new()
	var pm: CylinderMesh = CylinderMesh.new()
	pm.top_radius = 3.20
	pm.bottom_radius = 3.20
	pm.height = 0.12
	pond.mesh = pm
	pond.material_override = ice_mat
	pond.position = Vector3(0, 0.06, 0)
	hole.add_child(pond)
	# Dark hole in center (small dark cylinder above)
	var dark: MeshInstance3D = MeshInstance3D.new()
	var dm: CylinderMesh = CylinderMesh.new()
	dm.top_radius = 0.40
	dm.bottom_radius = 0.40
	dm.height = 0.05
	dark.mesh = dm
	var dark_mat: StandardMaterial3D = StandardMaterial3D.new()
	dark_mat.albedo_color = Color(0.05, 0.10, 0.15)
	dark_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	dark.material_override = dark_mat
	dark.position = Vector3(0, 0.13, 0)
	hole.add_child(dark)
	# Wooden stool (3 legs + seat)
	var wood_mat: StandardMaterial3D = StandardMaterial3D.new()
	wood_mat.albedo_color = Color(0.45, 0.28, 0.12)
	wood_mat.roughness = 0.85
	var seat: MeshInstance3D = MeshInstance3D.new()
	var sm: CylinderMesh = CylinderMesh.new()
	sm.top_radius = 0.28
	sm.bottom_radius = 0.28
	sm.height = 0.08
	seat.mesh = sm
	seat.material_override = wood_mat
	seat.position = Vector3(1.20, 0.45, 0)
	hole.add_child(seat)
	for i in 3:
		var ang: float = (TAU / 3.0) * i
		var leg: MeshInstance3D = MeshInstance3D.new()
		var lm: CylinderMesh = CylinderMesh.new()
		lm.top_radius = 0.04
		lm.bottom_radius = 0.04
		lm.height = 0.42
		leg.mesh = lm
		leg.material_override = wood_mat
		leg.position = Vector3(1.20 + cos(ang) * 0.20, 0.21, sin(ang) * 0.20)
		hole.add_child(leg)
	# Fishing rod (long thin cylinder pointing into hole)
	var rod: MeshInstance3D = MeshInstance3D.new()
	var rm: CylinderMesh = CylinderMesh.new()
	rm.top_radius = 0.02
	rm.bottom_radius = 0.04
	rm.height = 1.85
	rod.mesh = rm
	rod.material_override = wood_mat
	rod.position = Vector3(0.65, 0.65, 0)
	rod.rotation_degrees = Vector3(0, 0, 65)
	hole.add_child(rod)
	# Fishing line (very thin line down to hole)
	var line: MeshInstance3D = MeshInstance3D.new()
	var lmm: CylinderMesh = CylinderMesh.new()
	lmm.top_radius = 0.005
	lmm.bottom_radius = 0.005
	lmm.height = 0.95
	line.mesh = lmm
	var line_mat: StandardMaterial3D = StandardMaterial3D.new()
	line_mat.albedo_color = Color(0.95, 0.95, 0.90)
	line.material_override = line_mat
	line.position = Vector3(0.05, 0.65, 0)
	hole.add_child(line)


func _build_d5_aurora_pillars(geom: Node) -> void:
	## Epic-5 T15: 5 tall aurora light pillars — vertical translucent
	## colored beams shifting through cyan/violet/green hues.
	var aurora: Node3D = Node3D.new()
	aurora.name = "AuroraPillars"
	aurora.position = Vector3(D5_CENTER.x + 18.0, 0.0, 4.0)
	geom.add_child(aurora)
	var beam_colors: Array = [
		Color(0.30, 0.85, 0.95),
		Color(0.55, 0.40, 0.95),
		Color(0.30, 0.95, 0.55),
		Color(0.95, 0.55, 0.85),
		Color(0.40, 0.75, 1.0),
	]
	for i in 5:
		var pillar: Node3D = Node3D.new()
		pillar.position = Vector3(i * 2.60, 0, 0)
		aurora.add_child(pillar)
		var beam: MeshInstance3D = MeshInstance3D.new()
		var bm: CylinderMesh = CylinderMesh.new()
		bm.top_radius = 0.10
		bm.bottom_radius = 0.45
		bm.height = 11.0
		beam.mesh = bm
		var bmat: StandardMaterial3D = StandardMaterial3D.new()
		bmat.albedo_color = Color(beam_colors[i].r, beam_colors[i].g, beam_colors[i].b, 0.55)
		bmat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		bmat.emission_enabled = true
		bmat.emission = beam_colors[i]
		bmat.emission_energy_multiplier = 1.6
		bmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		beam.material_override = bmat
		beam.position = Vector3(0, 5.50, 0)
		pillar.add_child(beam)
		# Slow color shift on the underlying material
		var tw: Tween = bmat.create_tween().set_loops()
		var alt: Color = beam_colors[(i + 2) % 5]
		tw.tween_property(bmat, "emission", alt, 4.0 + i * 0.3)
		tw.tween_property(bmat, "emission", beam_colors[i], 4.0 + i * 0.3)
		# Light at the base
		var light: OmniLight3D = OmniLight3D.new()
		light.light_color = beam_colors[i]
		light.light_energy = 1.4
		light.omni_range = 4.0
		light.position = Vector3(0, 1.0, 0)
		pillar.add_child(light)


func _build_d5_snowflake_circle(geom: Node) -> void:
	## Epic-5 T16: snowflake ritual circle — flat ice disc with a 6-spoked
	## snowflake pattern carved in glowing cyan, surrounded by 6 small ice
	## standing stones.
	var circle: Node3D = Node3D.new()
	circle.name = "SnowflakeCircle"
	circle.position = Vector3(D5_CENTER.x - 4.0, 0.0, 14.0)
	geom.add_child(circle)
	var ice_mat: StandardMaterial3D = StandardMaterial3D.new()
	ice_mat.albedo_color = Color(0.65, 0.85, 0.95, 0.85)
	ice_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	ice_mat.emission_enabled = true
	ice_mat.emission = Color(0.40, 0.85, 0.95)
	ice_mat.emission_energy_multiplier = 0.45
	ice_mat.metallic = 0.55
	ice_mat.roughness = 0.10
	# Base disc
	var disc: MeshInstance3D = MeshInstance3D.new()
	var dm: CylinderMesh = CylinderMesh.new()
	dm.top_radius = 3.40
	dm.bottom_radius = 3.40
	dm.height = 0.10
	disc.mesh = dm
	disc.material_override = ice_mat
	disc.position = Vector3(0, 0.05, 0)
	circle.add_child(disc)
	# 6-spoke snowflake pattern (glowing cyan boxes)
	var glow_mat: StandardMaterial3D = StandardMaterial3D.new()
	glow_mat.albedo_color = Color(0.30, 1.0, 1.0)
	glow_mat.emission_enabled = true
	glow_mat.emission = Color(0.30, 1.0, 1.0)
	glow_mat.emission_energy_multiplier = 2.5
	glow_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for i in 6:
		var ang: float = (TAU / 6.0) * i
		var spoke: MeshInstance3D = MeshInstance3D.new()
		var sm: BoxMesh = BoxMesh.new()
		sm.size = Vector3(2.85, 0.04, 0.20)
		spoke.mesh = sm
		spoke.material_override = glow_mat
		spoke.position = Vector3(0, 0.12, 0)
		spoke.rotation = Vector3(0, ang, 0)
		circle.add_child(spoke)
		# Cross-arms on each spoke (smaller arms forming snowflake fractal)
		for j in 2:
			var arm_offset: float = 0.85 + j * 0.55
			for s in [-1, 1]:
				var arm: MeshInstance3D = MeshInstance3D.new()
				var am: BoxMesh = BoxMesh.new()
				am.size = Vector3(0.55, 0.04, 0.10)
				arm.mesh = am
				arm.material_override = glow_mat
				arm.position = Vector3(cos(ang) * arm_offset, 0.12, sin(ang) * arm_offset)
				arm.rotation = Vector3(0, ang + s * deg_to_rad(60), 0)
				circle.add_child(arm)
	# 6 small ice standing stones around the disc
	for i in 6:
		var ang: float = (TAU / 6.0) * i + PI / 12.0
		var stone: MeshInstance3D = MeshInstance3D.new()
		var sm2: BoxMesh = BoxMesh.new()
		sm2.size = Vector3(0.45, 1.85, 0.45)
		stone.mesh = sm2
		stone.material_override = ice_mat
		stone.position = Vector3(cos(ang) * 3.85, 0.92, sin(ang) * 3.85)
		circle.add_child(stone)
		# Stone collision
		var sb: StaticBody3D = StaticBody3D.new()
		sb.position = Vector3(cos(ang) * 3.85, 0.92, sin(ang) * 3.85)
		var cs: CollisionShape3D = CollisionShape3D.new()
		var cb: BoxShape3D = BoxShape3D.new()
		cb.size = Vector3(0.45, 1.85, 0.45)
		cs.shape = cb
		sb.add_child(cs)
		circle.add_child(sb)
	# Central light
	var light: OmniLight3D = OmniLight3D.new()
	light.light_color = Color(0.40, 0.95, 1.0)
	light.light_energy = 2.5
	light.omni_range = 6.0
	light.position = Vector3(0, 0.55, 0)
	circle.add_child(light)


func _build_d5_frost_wisps(geom: Node) -> void:
	## Epic-5 T17: 5 small drifting frost wisp orbs — pure cyan light spheres
	## that bob and orbit randomly across the district.
	var wisps: Node3D = Node3D.new()
	wisps.name = "FrostWisps"
	wisps.position = Vector3(D5_CENTER.x, 1.5, 0.0)
	geom.add_child(wisps)
	for i in 5:
		var pivot: Node3D = Node3D.new()
		pivot.position = Vector3(0, randf_range(-0.5, 1.5), 0)
		pivot.rotation_degrees = Vector3(0, i * 72.0, 0)
		wisps.add_child(pivot)
		var wisp: MeshInstance3D = MeshInstance3D.new()
		var wm: SphereMesh = SphereMesh.new()
		wm.radius = 0.20
		wm.height = 0.36
		wisp.mesh = wm
		var wmat: StandardMaterial3D = StandardMaterial3D.new()
		wmat.albedo_color = Color(0.30, 0.95, 1.0)
		wmat.emission_enabled = true
		wmat.emission = Color(0.30, 1.0, 1.0)
		wmat.emission_energy_multiplier = 3.5
		wmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		wisp.material_override = wmat
		wisp.position = Vector3(8.0 + randf() * 4.0, 0, 0)
		pivot.add_child(wisp)
		# Tiny light per wisp
		var light: OmniLight3D = OmniLight3D.new()
		light.light_color = Color(0.40, 0.95, 1.0)
		light.light_energy = 1.2
		light.omni_range = 2.5
		light.position = Vector3.ZERO
		wisp.add_child(light)
		# Orbit + bob
		var trot: Tween = pivot.create_tween().set_loops()
		trot.tween_property(pivot, "rotation_degrees:y", i * 72.0 + 360.0, 12.0 + i * 0.6)
		trot.tween_property(pivot, "rotation_degrees:y", i * 72.0, 0.0)
		var tb: Tween = wisp.create_tween().set_loops()
		tb.tween_property(wisp, "position:y", 0.85, 1.4 + randf() * 0.4)
		tb.tween_property(wisp, "position:y", -0.20, 1.4 + randf() * 0.4)


func _build_d5_ice_mage_npc(town: Node) -> void:
	## Epic-5 T18: ice mage NPC — pale-violet robe, floating ice shard
	## orbs around their hands, radiates cold mist.
	var npc_slots: Node3D = town.get_node_or_null("%NPCSlots") as Node3D
	if npc_slots == null:
		return
	var slot: Marker3D = Marker3D.new()
	slot.name = "IceMageSlot"
	slot.position = Vector3(D5_CENTER.x + 8.0, 0.0, 0.0)
	npc_slots.add_child(slot)
	var npc_scene: PackedScene = load("res://scenes/entities/npcs/VillagerR3.tscn") as PackedScene
	if npc_scene == null:
		return
	var npc: Node3D = npc_scene.instantiate() as Node3D
	npc.name = "IceMage"
	if "npc_name" in npc:
		npc.set("npc_name", "Brimrose")
	if "npc_id" in npc:
		npc.set("npc_id", "ice_mage_d5")
	slot.add_child(npc)
	# Pale violet robe
	var robe: MeshInstance3D = MeshInstance3D.new()
	var rm: BoxMesh = BoxMesh.new()
	rm.size = Vector3(0.65, 1.10, 0.45)
	robe.mesh = rm
	var robe_mat: StandardMaterial3D = StandardMaterial3D.new()
	robe_mat.albedo_color = Color(0.55, 0.45, 0.85)
	robe_mat.emission_enabled = true
	robe_mat.emission = Color(0.40, 0.30, 0.85)
	robe_mat.emission_energy_multiplier = 0.30
	robe_mat.roughness = 0.75
	robe.material_override = robe_mat
	robe.position = Vector3(0, 0.55, 0)
	npc.add_child(robe)
	# Pointed wizard hat
	var hat: MeshInstance3D = MeshInstance3D.new()
	var hm: PrismMesh = PrismMesh.new()
	hm.size = Vector3(0.45, 0.65, 0.45)
	hat.mesh = hm
	var hat_mat: StandardMaterial3D = StandardMaterial3D.new()
	hat_mat.albedo_color = Color(0.40, 0.35, 0.75)
	hat_mat.roughness = 0.80
	hat.material_override = hat_mat
	hat.position = Vector3(0, 1.65, 0)
	npc.add_child(hat)
	# 3 floating ice shard orbs around the mage
	var shard_mat: StandardMaterial3D = StandardMaterial3D.new()
	shard_mat.albedo_color = Color(0.40, 0.85, 1.0)
	shard_mat.emission_enabled = true
	shard_mat.emission = Color(0.30, 0.95, 1.0)
	shard_mat.emission_energy_multiplier = 2.5
	shard_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var pivot: Node3D = Node3D.new()
	pivot.position = Vector3(0, 0.95, 0)
	npc.add_child(pivot)
	for i in 3:
		var shard: MeshInstance3D = MeshInstance3D.new()
		var sm: PrismMesh = PrismMesh.new()
		sm.size = Vector3(0.10, 0.22, 0.10)
		shard.mesh = sm
		shard.material_override = shard_mat
		var ang: float = (TAU / 3.0) * i
		shard.position = Vector3(cos(ang) * 0.85, 0, sin(ang) * 0.85)
		pivot.add_child(shard)
	var trot: Tween = pivot.create_tween().set_loops()
	trot.tween_property(pivot, "rotation_degrees:y", 360.0, 4.0)
	trot.tween_property(pivot, "rotation_degrees:y", 0.0, 0.0)
	# Mage aura light
	var light: OmniLight3D = OmniLight3D.new()
	light.light_color = Color(0.40, 0.85, 1.0)
	light.light_energy = 1.4
	light.omni_range = 3.5
	light.position = Vector3(0, 0.95, 0)
	npc.add_child(light)


func _build_d5_frozen_shelves(geom: Node) -> void:
	## Epic-5 T19: 4 tall frozen library shelves with crystallized "books"
	## stacked on each. The simulation's archived knowledge.
	var shelves: Node3D = Node3D.new()
	shelves.name = "FrozenShelves"
	shelves.position = Vector3(D5_CENTER.x - 14.0, 0.0, -2.0)
	geom.add_child(shelves)
	var ice_mat: StandardMaterial3D = StandardMaterial3D.new()
	ice_mat.albedo_color = Color(0.65, 0.85, 0.95, 0.85)
	ice_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	ice_mat.emission_enabled = true
	ice_mat.emission = Color(0.40, 0.85, 0.95)
	ice_mat.emission_energy_multiplier = 0.40
	ice_mat.metallic = 0.55
	ice_mat.roughness = 0.10
	var book_colors: Array = [
		Color(0.30, 0.95, 1.0),
		Color(0.55, 0.40, 0.95),
		Color(0.95, 0.55, 0.30),
		Color(0.30, 0.95, 0.55),
	]
	for s in 4:
		var shelf: Node3D = Node3D.new()
		shelf.position = Vector3(s * 2.20, 0, 0)
		shelves.add_child(shelf)
		# Frame
		var frame: MeshInstance3D = MeshInstance3D.new()
		var fm: BoxMesh = BoxMesh.new()
		fm.size = Vector3(1.85, 3.20, 0.55)
		frame.mesh = fm
		frame.material_override = ice_mat
		frame.position = Vector3(0, 1.60, 0)
		shelf.add_child(frame)
		# 4 horizontal shelf planks (thinner ice slabs)
		for r in 4:
			var plank: MeshInstance3D = MeshInstance3D.new()
			var pmm: BoxMesh = BoxMesh.new()
			pmm.size = Vector3(1.65, 0.06, 0.40)
			plank.mesh = pmm
			plank.material_override = ice_mat
			plank.position = Vector3(0, 0.45 + r * 0.75, 0)
			shelf.add_child(plank)
			# 6 books per plank
			for b in 6:
				var book: MeshInstance3D = MeshInstance3D.new()
				var bm: BoxMesh = BoxMesh.new()
				bm.size = Vector3(0.18, 0.42, 0.16)
				book.mesh = bm
				var bmat: StandardMaterial3D = StandardMaterial3D.new()
				var col: Color = book_colors[(s + r + b) % 4]
				bmat.albedo_color = col
				bmat.emission_enabled = true
				bmat.emission = col
				bmat.emission_energy_multiplier = 0.65
				bmat.metallic = 0.30
				bmat.roughness = 0.30
				book.material_override = bmat
				book.position = Vector3(-0.65 + b * 0.22, 0.69 + r * 0.75, 0)
				shelf.add_child(book)
		# Shelf collision
		var sb: StaticBody3D = StaticBody3D.new()
		sb.position = Vector3(0, 1.60, 0)
		var cs: CollisionShape3D = CollisionShape3D.new()
		var cb: BoxShape3D = BoxShape3D.new()
		cb.size = Vector3(1.85, 3.20, 0.55)
		cs.shape = cb
		sb.add_child(cs)
		shelf.add_child(sb)


func _build_d5_cold_wind(geom: Node) -> void:
	## Epic-5 T20: GPU cold wind drift — fast-moving horizontal pale streaks
	## blowing across the district to give a sense of weather.
	var wind: GPUParticles3D = GPUParticles3D.new()
	wind.name = "ColdWind"
	wind.position = Vector3(D5_CENTER.x, 2.0, 0.0)
	wind.amount = 100
	wind.lifetime = 4.0
	wind.preprocess = 2.0
	wind.explosiveness = 0.0
	wind.randomness = 0.5
	wind.visibility_aabb = AABB(Vector3(-40, -3, -25), Vector3(80, 8, 50))
	var pm: ParticleProcessMaterial = ParticleProcessMaterial.new()
	pm.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	pm.emission_box_extents = Vector3(2, 4, 22)
	pm.direction = Vector3(1, 0.10, 0)
	pm.spread = 8.0
	pm.gravity = Vector3.ZERO
	pm.initial_velocity_min = 4.5
	pm.initial_velocity_max = 7.5
	pm.scale_min = 0.30
	pm.scale_max = 0.75
	pm.color = Color(0.85, 0.95, 1.0, 0.55)
	wind.process_material = pm
	# Streak mesh — long flat box
	var streak_mesh: BoxMesh = BoxMesh.new()
	streak_mesh.size = Vector3(0.85, 0.04, 0.06)
	wind.draw_pass_1 = streak_mesh
	var smat: StandardMaterial3D = StandardMaterial3D.new()
	smat.albedo_color = Color(0.85, 0.95, 1.0, 0.65)
	smat.emission_enabled = true
	smat.emission = Color(0.65, 0.95, 1.0)
	smat.emission_energy_multiplier = 1.6
	smat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	smat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	streak_mesh.material = smat
	# Position the emitter at the west edge so wind blows east
	wind.position.x = D5_CENTER.x - 30.0
	geom.add_child(wind)


func _build_d5_ice_bridge(geom: Node) -> void:
	## Epic-5 T21: 8m translucent ice bridge spanning a small chasm —
	## arched plank deck + 2 side rails + supporting pillars at each end.
	var bridge: Node3D = Node3D.new()
	bridge.name = "IceBridge"
	bridge.position = Vector3(D5_CENTER.x + 14.0, 0.0, -2.0)
	geom.add_child(bridge)
	var ice_mat: StandardMaterial3D = StandardMaterial3D.new()
	ice_mat.albedo_color = Color(0.65, 0.85, 0.95, 0.85)
	ice_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	ice_mat.emission_enabled = true
	ice_mat.emission = Color(0.40, 0.85, 0.95)
	ice_mat.emission_energy_multiplier = 0.55
	ice_mat.metallic = 0.55
	ice_mat.roughness = 0.10
	# Chasm — visible darker recess in the ground (large dark cylinder set
	# slightly below grade)
	var chasm: MeshInstance3D = MeshInstance3D.new()
	var cm: CylinderMesh = CylinderMesh.new()
	cm.top_radius = 3.20
	cm.bottom_radius = 3.20
	cm.height = 0.40
	chasm.mesh = cm
	var chasm_mat: StandardMaterial3D = StandardMaterial3D.new()
	chasm_mat.albedo_color = Color(0.05, 0.10, 0.20)
	chasm_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	chasm.material_override = chasm_mat
	chasm.position = Vector3(0, -0.18, 0)
	bridge.add_child(chasm)
	# Bridge deck (long box, slightly arched via 5 panel slabs)
	for i in 5:
		var panel: MeshInstance3D = MeshInstance3D.new()
		var pmm: BoxMesh = BoxMesh.new()
		pmm.size = Vector3(1.85, 0.12, 1.85)
		panel.mesh = pmm
		panel.material_override = ice_mat
		var t: float = i / 4.0
		var arch_y: float = 1.40 + sin(t * PI) * 0.40
		panel.position = Vector3(-3.70 + i * 1.85, arch_y, 0)
		bridge.add_child(panel)
	# Side rails (2 long thin curving cylinders)
	for sz in [-0.85, 0.85]:
		var rail: MeshInstance3D = MeshInstance3D.new()
		var rm: CylinderMesh = CylinderMesh.new()
		rm.top_radius = 0.06
		rm.bottom_radius = 0.06
		rm.height = 8.5
		rail.mesh = rm
		rail.material_override = ice_mat
		rail.position = Vector3(0, 1.95, sz)
		rail.rotation_degrees = Vector3(0, 0, 90)
		bridge.add_child(rail)
	# 2 end pillars
	for sx in [-4.20, 4.20]:
		var pillar: MeshInstance3D = MeshInstance3D.new()
		var pm: BoxMesh = BoxMesh.new()
		pm.size = Vector3(0.85, 1.85, 1.85)
		pillar.mesh = pm
		pillar.material_override = ice_mat
		pillar.position = Vector3(sx, 0.92, 0)
		bridge.add_child(pillar)
		# Pillar collision
		var sb: StaticBody3D = StaticBody3D.new()
		sb.position = Vector3(sx, 0.92, 0)
		var cs: CollisionShape3D = CollisionShape3D.new()
		var cb: BoxShape3D = BoxShape3D.new()
		cb.size = Vector3(0.85, 1.85, 1.85)
		cs.shape = cb
		sb.add_child(cs)
		bridge.add_child(sb)
	# Deck collision (one slab spanning the bridge)
	var dsb: StaticBody3D = StaticBody3D.new()
	dsb.position = Vector3(0, 1.45, 0)
	var dcs: CollisionShape3D = CollisionShape3D.new()
	var dcb: BoxShape3D = BoxShape3D.new()
	dcb.size = Vector3(8.50, 0.20, 1.85)
	dcs.shape = dcb
	dsb.add_child(dcs)
	bridge.add_child(dsb)


func _build_d5_mammoth_statue(geom: Node) -> void:
	## Epic-5 T22: frozen mammoth statue — large procedural mammoth made
	## of ice (body, head, tusks, 4 legs, trunk), suggesting an extinct
	## subroutine preserved in the cache.
	var mammoth: Node3D = Node3D.new()
	mammoth.name = "MammothStatue"
	mammoth.position = Vector3(D5_CENTER.x + 22.0, 0.0, 8.0)
	geom.add_child(mammoth)
	var ice_mat: StandardMaterial3D = StandardMaterial3D.new()
	ice_mat.albedo_color = Color(0.65, 0.82, 0.95, 0.92)
	ice_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	ice_mat.emission_enabled = true
	ice_mat.emission = Color(0.40, 0.80, 0.95)
	ice_mat.emission_energy_multiplier = 0.45
	ice_mat.metallic = 0.55
	ice_mat.roughness = 0.20
	var tusk_mat: StandardMaterial3D = StandardMaterial3D.new()
	tusk_mat.albedo_color = Color(0.95, 0.92, 0.80)
	tusk_mat.metallic = 0.30
	tusk_mat.roughness = 0.30
	# Body — large rounded sphere
	var body: MeshInstance3D = MeshInstance3D.new()
	var bm: SphereMesh = SphereMesh.new()
	bm.radius = 1.40
	bm.height = 2.40
	body.mesh = bm
	body.material_override = ice_mat
	body.position = Vector3(0, 2.20, 0)
	body.scale = Vector3(1.0, 0.95, 1.55)
	mammoth.add_child(body)
	# Head
	var head: MeshInstance3D = MeshInstance3D.new()
	var hm: SphereMesh = SphereMesh.new()
	hm.radius = 0.95
	hm.height = 1.65
	head.mesh = hm
	head.material_override = ice_mat
	head.position = Vector3(0, 2.20, 1.85)
	head.scale = Vector3(0.95, 1.0, 0.95)
	mammoth.add_child(head)
	# 2 large tusks (curved cylinders)
	for sx in [-0.45, 0.45]:
		var tusk: MeshInstance3D = MeshInstance3D.new()
		var tm: CylinderMesh = CylinderMesh.new()
		tm.top_radius = 0.06
		tm.bottom_radius = 0.18
		tm.height = 1.85
		tusk.mesh = tm
		tusk.material_override = tusk_mat
		tusk.position = Vector3(sx, 1.65, 2.55)
		tusk.rotation_degrees = Vector3(35, 0, -15.0 if sx > 0 else 15.0)
		mammoth.add_child(tusk)
	# Trunk (3 narrowing sphere segments)
	for i in 4:
		var seg: MeshInstance3D = MeshInstance3D.new()
		var sm: SphereMesh = SphereMesh.new()
		sm.radius = 0.25 - i * 0.04
		sm.height = 0.42 - i * 0.06
		seg.mesh = sm
		seg.material_override = ice_mat
		seg.position = Vector3(0, 1.95 - i * 0.18, 2.55 + i * 0.30)
		mammoth.add_child(seg)
	# 4 legs (large cylinders)
	for sx in [-0.85, 0.85]:
		for sz in [-0.85, 0.85]:
			var leg: MeshInstance3D = MeshInstance3D.new()
			var lm: CylinderMesh = CylinderMesh.new()
			lm.top_radius = 0.30
			lm.bottom_radius = 0.40
			lm.height = 1.85
			leg.mesh = lm
			leg.material_override = ice_mat
			leg.position = Vector3(sx, 0.92, sz)
			mammoth.add_child(leg)
	# Pedestal stone block under the mammoth
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.45, 0.50, 0.55)
	stone_mat.roughness = 0.92
	var ped: MeshInstance3D = MeshInstance3D.new()
	var pmm: BoxMesh = BoxMesh.new()
	pmm.size = Vector3(4.20, 0.40, 4.20)
	ped.mesh = pmm
	ped.material_override = stone_mat
	ped.position = Vector3(0, 0.20, 0)
	mammoth.add_child(ped)
	# Pedestal collision
	var sb: StaticBody3D = StaticBody3D.new()
	sb.position = Vector3(0, 0.20, 0)
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(4.20, 0.40, 4.20)
	cs.shape = cb
	sb.add_child(cs)
	mammoth.add_child(sb)
	# Body collision (large box)
	var bsb: StaticBody3D = StaticBody3D.new()
	bsb.position = Vector3(0, 1.85, 0)
	var bcs: CollisionShape3D = CollisionShape3D.new()
	var bcb: BoxShape3D = BoxShape3D.new()
	bcb.size = Vector3(2.40, 3.30, 4.20)
	bcs.shape = bcb
	bsb.add_child(bcs)
	mammoth.add_child(bsb)


func _build_d5_cryo_engineer_npc(town: Node) -> void:
	## Epic-5 T23: cryo engineer NPC — heavy snowsuit + welding-style helmet
	## with a glowing visor + small toolbox at their feet.
	var npc_slots: Node3D = town.get_node_or_null("%NPCSlots") as Node3D
	if npc_slots == null:
		return
	var slot: Marker3D = Marker3D.new()
	slot.name = "CryoEngineerSlot"
	slot.position = Vector3(D5_CENTER.x + 6.0, 0.0, 13.0)
	npc_slots.add_child(slot)
	var npc_scene: PackedScene = load("res://scenes/entities/npcs/VillagerR3.tscn") as PackedScene
	if npc_scene == null:
		return
	var npc: Node3D = npc_scene.instantiate() as Node3D
	npc.name = "CryoEngineer"
	if "npc_name" in npc:
		npc.set("npc_name", "Argyle")
	if "npc_id" in npc:
		npc.set("npc_id", "engineer_d5")
	slot.add_child(npc)
	# Snowsuit body
	var suit: MeshInstance3D = MeshInstance3D.new()
	var sm: BoxMesh = BoxMesh.new()
	sm.size = Vector3(0.75, 1.05, 0.55)
	suit.mesh = sm
	var suit_mat: StandardMaterial3D = StandardMaterial3D.new()
	suit_mat.albedo_color = Color(0.30, 0.50, 0.65)
	suit_mat.roughness = 0.65
	suit_mat.metallic = 0.25
	suit.material_override = suit_mat
	suit.position = Vector3(0, 0.55, 0)
	npc.add_child(suit)
	# Welding helmet (box with glowing cyan visor)
	var helmet: MeshInstance3D = MeshInstance3D.new()
	var hm: BoxMesh = BoxMesh.new()
	hm.size = Vector3(0.40, 0.45, 0.40)
	helmet.mesh = hm
	var helmet_mat: StandardMaterial3D = StandardMaterial3D.new()
	helmet_mat.albedo_color = Color(0.20, 0.25, 0.30)
	helmet_mat.metallic = 0.85
	helmet_mat.roughness = 0.30
	helmet.material_override = helmet_mat
	helmet.position = Vector3(0, 1.40, 0)
	npc.add_child(helmet)
	# Glowing visor strip
	var visor: MeshInstance3D = MeshInstance3D.new()
	var vm: BoxMesh = BoxMesh.new()
	vm.size = Vector3(0.32, 0.10, 0.04)
	visor.mesh = vm
	var visor_mat: StandardMaterial3D = StandardMaterial3D.new()
	visor_mat.albedo_color = Color(0.30, 1.0, 1.0)
	visor_mat.emission_enabled = true
	visor_mat.emission = Color(0.30, 1.0, 1.0)
	visor_mat.emission_energy_multiplier = 3.0
	visor_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	visor.material_override = visor_mat
	visor.position = Vector3(0, 1.40, 0.21)
	npc.add_child(visor)
	# Toolbox at their feet (small box)
	var toolbox: MeshInstance3D = MeshInstance3D.new()
	var tm: BoxMesh = BoxMesh.new()
	tm.size = Vector3(0.55, 0.30, 0.30)
	toolbox.mesh = tm
	var tool_mat: StandardMaterial3D = StandardMaterial3D.new()
	tool_mat.albedo_color = Color(0.85, 0.55, 0.20)
	tool_mat.metallic = 0.55
	tool_mat.roughness = 0.45
	toolbox.material_override = tool_mat
	toolbox.position = Vector3(0.65, 0.15, 0.20)
	npc.add_child(toolbox)


func _build_d5_ice_cave_entrance(geom: Node) -> void:
	## Epic-5 T24: small ice cave entrance — half-dome ice opening with a
	## dark interior, hinting at unexplored areas behind the cache.
	var cave: Node3D = Node3D.new()
	cave.name = "IceCaveEntrance"
	cave.position = Vector3(D5_CENTER.x + 24.0, 0.0, -16.0)
	geom.add_child(cave)
	var ice_mat: StandardMaterial3D = StandardMaterial3D.new()
	ice_mat.albedo_color = Color(0.65, 0.85, 0.95, 0.92)
	ice_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	ice_mat.emission_enabled = true
	ice_mat.emission = Color(0.40, 0.85, 0.95)
	ice_mat.emission_energy_multiplier = 0.55
	ice_mat.metallic = 0.55
	ice_mat.roughness = 0.20
	# Half-dome cave roof (large sphere flattened)
	var dome: MeshInstance3D = MeshInstance3D.new()
	var dm: SphereMesh = SphereMesh.new()
	dm.radius = 3.40
	dm.height = 5.40
	dome.mesh = dm
	dome.material_override = ice_mat
	dome.position = Vector3(0, 2.20, 0)
	dome.scale = Vector3(1.0, 0.85, 1.0)
	cave.add_child(dome)
	# Dark interior plug (large dark disk facing outward)
	var dark: MeshInstance3D = MeshInstance3D.new()
	var darkm: CylinderMesh = CylinderMesh.new()
	darkm.top_radius = 1.85
	darkm.bottom_radius = 1.85
	darkm.height = 0.20
	dark.mesh = darkm
	var dark_mat: StandardMaterial3D = StandardMaterial3D.new()
	dark_mat.albedo_color = Color(0.04, 0.06, 0.10)
	dark_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	dark.material_override = dark_mat
	dark.position = Vector3(0, 1.85, 1.40)
	dark.rotation_degrees = Vector3(90, 0, 0)
	cave.add_child(dark)
	# Faint inner light (mysterious blue glow from within)
	var inner: OmniLight3D = OmniLight3D.new()
	inner.light_color = Color(0.30, 0.65, 0.95)
	inner.light_energy = 1.6
	inner.omni_range = 5.5
	inner.position = Vector3(0, 1.55, 0.85)
	cave.add_child(inner)
	# 4 hanging icicles around the opening
	for i in 4:
		var ic: MeshInstance3D = MeshInstance3D.new()
		var im: PrismMesh = PrismMesh.new()
		im.size = Vector3(0.20, 0.85 + randf() * 0.40, 0.20)
		ic.mesh = im
		ic.material_override = ice_mat
		var ang: float = lerp(-PI * 0.30, PI * 0.30, float(i) / 3.0)
		ic.position = Vector3(cos(ang + PI * 0.5) * 1.85, 3.20, sin(ang + PI * 0.5) * 1.85 + 1.20)
		ic.rotation_degrees = Vector3(180, 0, 0)
		cave.add_child(ic)
	# Cave dome collision
	var sb: StaticBody3D = StaticBody3D.new()
	sb.position = Vector3(0, 2.20, 0)
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cap: SphereShape3D = SphereShape3D.new()
	cap.radius = 2.80
	cs.shape = cap
	sb.add_child(cs)
	cave.add_child(sb)


func _build_d5_frozen_heart(geom: Node) -> void:
	## Epic-5 T25: frozen heart artifact — small pulsing crystal heart on
	## a stone pedestal. A hint at later quest collectibles.
	var heart: Node3D = Node3D.new()
	heart.name = "FrozenHeart"
	heart.position = Vector3(D5_CENTER.x + 2.0, 0.0, -8.0)
	geom.add_child(heart)
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.55, 0.62, 0.68)
	stone_mat.roughness = 0.92
	# Pedestal
	var ped: MeshInstance3D = MeshInstance3D.new()
	var pm: BoxMesh = BoxMesh.new()
	pm.size = Vector3(0.85, 1.10, 0.85)
	ped.mesh = pm
	ped.material_override = stone_mat
	ped.position = Vector3(0, 0.55, 0)
	heart.add_child(ped)
	# Pedestal cap
	var cap: MeshInstance3D = MeshInstance3D.new()
	var cmm: CylinderMesh = CylinderMesh.new()
	cmm.top_radius = 0.55
	cmm.bottom_radius = 0.50
	cmm.height = 0.20
	cap.mesh = cmm
	cap.material_override = stone_mat
	cap.position = Vector3(0, 1.20, 0)
	heart.add_child(cap)
	# Heart artifact — 2 spheres + prism, pulsing
	var heart_mat: StandardMaterial3D = StandardMaterial3D.new()
	heart_mat.albedo_color = Color(0.40, 0.85, 1.0)
	heart_mat.emission_enabled = true
	heart_mat.emission = Color(0.30, 1.0, 1.0)
	heart_mat.emission_energy_multiplier = 3.5
	heart_mat.metallic = 0.40
	heart_mat.roughness = 0.10
	heart_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var pivot: Node3D = Node3D.new()
	pivot.position = Vector3(0, 1.85, 0)
	heart.add_child(pivot)
	for sx in [-0.18, 0.18]:
		var lobe: MeshInstance3D = MeshInstance3D.new()
		var lm: SphereMesh = SphereMesh.new()
		lm.radius = 0.22
		lm.height = 0.40
		lobe.mesh = lm
		lobe.material_override = heart_mat
		lobe.position = Vector3(sx, 0.0, 0)
		pivot.add_child(lobe)
	var point: MeshInstance3D = MeshInstance3D.new()
	var ptm: PrismMesh = PrismMesh.new()
	ptm.size = Vector3(0.55, 0.40, 0.20)
	point.mesh = ptm
	point.material_override = heart_mat
	point.position = Vector3(0, -0.20, 0)
	point.rotation_degrees = Vector3(180, 0, 0)
	pivot.add_child(point)
	# Pulse heartbeat (the actual function of this artifact)
	var tw: Tween = pivot.create_tween().set_loops()
	tw.tween_property(pivot, "scale", Vector3.ONE * 1.20, 0.35)
	tw.tween_property(pivot, "scale", Vector3.ONE * 0.95, 0.35)
	tw.tween_property(pivot, "scale", Vector3.ONE * 1.10, 0.35)
	tw.tween_property(pivot, "scale", Vector3.ONE * 0.95, 0.85)
	# Hover spin
	var ts: Tween = pivot.create_tween().set_loops()
	ts.tween_property(pivot, "rotation_degrees:y", 360.0, 5.0)
	ts.tween_property(pivot, "rotation_degrees:y", 0.0, 0.0)
	# Aura light
	var light: OmniLight3D = OmniLight3D.new()
	light.light_color = Color(0.40, 0.95, 1.0)
	light.light_energy = 2.5
	light.omni_range = 5.0
	light.position = Vector3(0, 1.85, 0)
	heart.add_child(light)
	# Pedestal collision
	var sb: StaticBody3D = StaticBody3D.new()
	sb.position = Vector3(0, 0.55, 0)
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(0.85, 1.30, 0.85)
	cs.shape = cb
	sb.add_child(cs)
	heart.add_child(sb)


func _build_d5_mining_rig(geom: Node) -> void:
	## Epic-5 T26: data crystal mining rig — tall industrial frame with a
	## drill core descending into the ice and a conveyor belt of crystal
	## chunks running into a collection bin.
	var rig: Node3D = Node3D.new()
	rig.name = "MiningRig"
	rig.position = Vector3(D5_CENTER.x - 20.0, 0.0, -8.0)
	geom.add_child(rig)
	var metal_mat: StandardMaterial3D = StandardMaterial3D.new()
	metal_mat.albedo_color = Color(0.40, 0.45, 0.50)
	metal_mat.metallic = 0.85
	metal_mat.roughness = 0.30
	var dark_metal_mat: StandardMaterial3D = StandardMaterial3D.new()
	dark_metal_mat.albedo_color = Color(0.20, 0.25, 0.30)
	dark_metal_mat.metallic = 0.85
	dark_metal_mat.roughness = 0.40
	# 4 corner support beams
	for sx in [-1.30, 1.30]:
		for sz in [-1.30, 1.30]:
			var beam: MeshInstance3D = MeshInstance3D.new()
			var bm: BoxMesh = BoxMesh.new()
			bm.size = Vector3(0.20, 4.20, 0.20)
			beam.mesh = bm
			beam.material_override = metal_mat
			beam.position = Vector3(sx, 2.10, sz)
			rig.add_child(beam)
	# Top platform
	var top: MeshInstance3D = MeshInstance3D.new()
	var tm: BoxMesh = BoxMesh.new()
	tm.size = Vector3(2.85, 0.20, 2.85)
	top.mesh = tm
	top.material_override = dark_metal_mat
	top.position = Vector3(0, 4.30, 0)
	rig.add_child(top)
	# Drill core (long vertical cylinder going down)
	var drill: MeshInstance3D = MeshInstance3D.new()
	var dm: CylinderMesh = CylinderMesh.new()
	dm.top_radius = 0.30
	dm.bottom_radius = 0.45
	dm.height = 5.40
	drill.mesh = dm
	drill.material_override = dark_metal_mat
	drill.position = Vector3(0, 1.85, 0)
	rig.add_child(drill)
	# Drill spin tween
	var ts: Tween = drill.create_tween().set_loops()
	ts.tween_property(drill, "rotation_degrees:y", 360.0, 1.5)
	ts.tween_property(drill, "rotation_degrees:y", 0.0, 0.0)
	# Crystal core glow inside the drill
	var core: MeshInstance3D = MeshInstance3D.new()
	var cmm: SphereMesh = SphereMesh.new()
	cmm.radius = 0.30
	cmm.height = 0.55
	core.mesh = cmm
	var core_mat: StandardMaterial3D = StandardMaterial3D.new()
	core_mat.albedo_color = Color(0.30, 1.0, 1.0)
	core_mat.emission_enabled = true
	core_mat.emission = Color(0.30, 1.0, 1.0)
	core_mat.emission_energy_multiplier = 3.5
	core_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	core.material_override = core_mat
	core.position = Vector3(0, 4.55, 0)
	rig.add_child(core)
	# Conveyor belt (slanted long box leading from drill to a bin)
	var belt: MeshInstance3D = MeshInstance3D.new()
	var blm: BoxMesh = BoxMesh.new()
	blm.size = Vector3(3.20, 0.10, 0.65)
	belt.mesh = blm
	belt.material_override = dark_metal_mat
	belt.position = Vector3(2.40, 1.20, 0)
	belt.rotation_degrees = Vector3(0, 0, -10)
	rig.add_child(belt)
	# 5 small data crystal chunks on the belt
	var chunk_mat: StandardMaterial3D = StandardMaterial3D.new()
	chunk_mat.albedo_color = Color(0.40, 0.85, 1.0)
	chunk_mat.emission_enabled = true
	chunk_mat.emission = Color(0.30, 0.95, 1.0)
	chunk_mat.emission_energy_multiplier = 1.4
	chunk_mat.metallic = 0.40
	chunk_mat.roughness = 0.20
	for i in 5:
		var chunk: MeshInstance3D = MeshInstance3D.new()
		var cmm2: PrismMesh = PrismMesh.new()
		cmm2.size = Vector3(0.20, 0.16, 0.20)
		chunk.mesh = cmm2
		chunk.material_override = chunk_mat
		chunk.position = Vector3(1.20 + i * 0.55, 1.32 - i * 0.08, 0)
		rig.add_child(chunk)
	# Collection bin (open box at end of belt)
	var bin: MeshInstance3D = MeshInstance3D.new()
	var bnm: BoxMesh = BoxMesh.new()
	bnm.size = Vector3(0.95, 0.85, 0.95)
	bin.mesh = bnm
	bin.material_override = metal_mat
	bin.position = Vector3(4.20, 0.55, 0)
	rig.add_child(bin)
	# Bin contents (stacked crystals)
	for i in 4:
		var c: MeshInstance3D = MeshInstance3D.new()
		var cm: PrismMesh = PrismMesh.new()
		cm.size = Vector3(0.22, 0.18, 0.22)
		c.mesh = cm
		c.material_override = chunk_mat
		c.position = Vector3(4.20 + randf_range(-0.20, 0.20), 0.95 + randf_range(0, 0.10), randf_range(-0.20, 0.20))
		c.rotation_degrees = Vector3(randf_range(-30, 30), randf_range(0, 360), randf_range(-30, 30))
		rig.add_child(c)
	# Frame collision (wide box covering the rig)
	var sb: StaticBody3D = StaticBody3D.new()
	sb.position = Vector3(0, 2.10, 0)
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(3.00, 4.20, 3.00)
	cs.shape = cb
	sb.add_child(cs)
	rig.add_child(sb)


func _build_d5_penguin_colony(geom: Node) -> void:
	## Epic-5 T27: 6 small penguin creatures waddling on the ice with
	## bobbing tweens. Black body, white belly, orange beak.
	var colony: Node3D = Node3D.new()
	colony.name = "PenguinColony"
	colony.position = Vector3(D5_CENTER.x + 12.0, 0.0, 14.0)
	geom.add_child(colony)
	var black_mat: StandardMaterial3D = StandardMaterial3D.new()
	black_mat.albedo_color = Color(0.10, 0.12, 0.16)
	black_mat.roughness = 0.85
	var white_mat: StandardMaterial3D = StandardMaterial3D.new()
	white_mat.albedo_color = Color(0.95, 0.95, 0.92)
	white_mat.roughness = 0.85
	var beak_mat: StandardMaterial3D = StandardMaterial3D.new()
	beak_mat.albedo_color = Color(0.95, 0.55, 0.10)
	beak_mat.roughness = 0.55
	var positions: Array = [
		Vector3(0, 0, 0), Vector3(1.4, 0, 0.8), Vector3(-1.2, 0, 1.0),
		Vector3(2.5, 0, -0.6), Vector3(-2.0, 0, -1.4), Vector3(0.8, 0, -2.0),
	]
	for p in positions:
		var penguin: Node3D = Node3D.new()
		penguin.position = p
		colony.add_child(penguin)
		# Body (tall sphere)
		var body: MeshInstance3D = MeshInstance3D.new()
		var bm: SphereMesh = SphereMesh.new()
		bm.radius = 0.32
		bm.height = 0.85
		body.mesh = bm
		body.material_override = black_mat
		body.position = Vector3(0, 0.45, 0)
		body.scale = Vector3(0.85, 1.10, 0.85)
		penguin.add_child(body)
		# White belly
		var belly: MeshInstance3D = MeshInstance3D.new()
		var bym: SphereMesh = SphereMesh.new()
		bym.radius = 0.24
		bym.height = 0.65
		belly.mesh = bym
		belly.material_override = white_mat
		belly.position = Vector3(0, 0.42, 0.10)
		belly.scale = Vector3(0.85, 1.10, 0.45)
		penguin.add_child(belly)
		# Head
		var head: MeshInstance3D = MeshInstance3D.new()
		var hm: SphereMesh = SphereMesh.new()
		hm.radius = 0.18
		hm.height = 0.32
		head.mesh = hm
		head.material_override = black_mat
		head.position = Vector3(0, 0.95, 0)
		penguin.add_child(head)
		# Beak
		var beak: MeshInstance3D = MeshInstance3D.new()
		var bkm: PrismMesh = PrismMesh.new()
		bkm.size = Vector3(0.06, 0.06, 0.18)
		beak.mesh = bkm
		beak.material_override = beak_mat
		beak.position = Vector3(0, 0.92, 0.20)
		beak.rotation_degrees = Vector3(90, 0, 0)
		penguin.add_child(beak)
		# 2 wings
		for sx in [-0.30, 0.30]:
			var wing: MeshInstance3D = MeshInstance3D.new()
			var wm: BoxMesh = BoxMesh.new()
			wm.size = Vector3(0.10, 0.40, 0.20)
			wing.mesh = wm
			wing.material_override = black_mat
			wing.position = Vector3(sx, 0.45, 0)
			penguin.add_child(wing)
		# 2 orange feet
		for sx in [-0.10, 0.10]:
			var foot: MeshInstance3D = MeshInstance3D.new()
			var fm: BoxMesh = BoxMesh.new()
			fm.size = Vector3(0.10, 0.04, 0.18)
			foot.mesh = fm
			foot.material_override = beak_mat
			foot.position = Vector3(sx, 0.04, 0.10)
			penguin.add_child(foot)
		# Waddle: side-to-side rocking + tiny hop
		var tw: Tween = penguin.create_tween().set_loops()
		tw.tween_property(penguin, "rotation_degrees:z", 8.0, 0.45)
		tw.tween_property(penguin, "rotation_degrees:z", -8.0, 0.45)
		var th: Tween = penguin.create_tween().set_loops()
		th.tween_property(penguin, "position:y", 0.10, 0.85)
		th.tween_property(penguin, "position:y", 0.0, 0.85)


func _build_d5_weather_tower(geom: Node) -> void:
	## Epic-5 T28: weather station tower — slim metal lattice with anemometer
	## (rotating wind cups), satellite dish, and a temperature display board.
	var tower: Node3D = Node3D.new()
	tower.name = "WeatherTower"
	tower.position = Vector3(D5_CENTER.x + 18.0, 0.0, 14.0)
	geom.add_child(tower)
	var metal_mat: StandardMaterial3D = StandardMaterial3D.new()
	metal_mat.albedo_color = Color(0.50, 0.55, 0.60)
	metal_mat.metallic = 0.75
	metal_mat.roughness = 0.40
	# 4 lattice corner posts
	for sx in [-0.40, 0.40]:
		for sz in [-0.40, 0.40]:
			var post: MeshInstance3D = MeshInstance3D.new()
			var pm: BoxMesh = BoxMesh.new()
			pm.size = Vector3(0.10, 5.50, 0.10)
			post.mesh = pm
			post.material_override = metal_mat
			post.position = Vector3(sx, 2.75, sz)
			tower.add_child(post)
	# 4 horizontal lattice braces
	for h in 4:
		for axis in 2:
			var brace: MeshInstance3D = MeshInstance3D.new()
			var brm: BoxMesh = BoxMesh.new()
			brm.size = Vector3(0.85, 0.06, 0.06) if axis == 0 else Vector3(0.06, 0.06, 0.85)
			brace.mesh = brm
			brace.material_override = metal_mat
			brace.position = Vector3(0, 0.85 + h * 1.30, 0.40 if axis == 0 else 0.0)
			tower.add_child(brace)
	# Anemometer pivot at top (4 cup arms)
	var pivot: Node3D = Node3D.new()
	pivot.position = Vector3(0, 5.85, 0)
	tower.add_child(pivot)
	for i in 4:
		var ang: float = (TAU / 4.0) * i
		var arm: MeshInstance3D = MeshInstance3D.new()
		var am: CylinderMesh = CylinderMesh.new()
		am.top_radius = 0.04
		am.bottom_radius = 0.04
		am.height = 0.55
		arm.mesh = am
		arm.material_override = metal_mat
		arm.position = Vector3(cos(ang) * 0.30, 0, sin(ang) * 0.30)
		arm.rotation_degrees = Vector3(0, 0, 90)
		arm.rotation = Vector3(0, ang + PI * 0.5, PI * 0.5)
		pivot.add_child(arm)
		var cup: MeshInstance3D = MeshInstance3D.new()
		var cm: SphereMesh = SphereMesh.new()
		cm.radius = 0.10
		cm.height = 0.20
		cup.mesh = cm
		cup.material_override = metal_mat
		cup.position = Vector3(cos(ang) * 0.55, 0, sin(ang) * 0.55)
		cup.scale = Vector3(0.85, 0.85, 0.55)
		pivot.add_child(cup)
	var twa: Tween = pivot.create_tween().set_loops()
	twa.tween_property(pivot, "rotation_degrees:y", 360.0, 2.0)
	twa.tween_property(pivot, "rotation_degrees:y", 0.0, 0.0)
	# Satellite dish (tilted half-sphere on the side)
	var dish: MeshInstance3D = MeshInstance3D.new()
	var dmm: SphereMesh = SphereMesh.new()
	dmm.radius = 0.55
	dmm.height = 0.55
	dish.mesh = dmm
	dish.material_override = metal_mat
	dish.position = Vector3(0.85, 4.50, 0)
	dish.scale = Vector3(1.0, 0.30, 1.0)
	dish.rotation_degrees = Vector3(0, 0, -45)
	tower.add_child(dish)
	# Temperature display board
	var display: MeshInstance3D = MeshInstance3D.new()
	var disp_m: BoxMesh = BoxMesh.new()
	disp_m.size = Vector3(0.85, 0.55, 0.06)
	display.mesh = disp_m
	var disp_mat: StandardMaterial3D = StandardMaterial3D.new()
	disp_mat.albedo_color = Color(0.10, 0.12, 0.16)
	disp_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	display.material_override = disp_mat
	display.position = Vector3(0, 1.65, 0.45)
	tower.add_child(display)
	var label: Label3D = Label3D.new()
	label.text = "-273.15°C"
	label.modulate = Color(0.30, 1.0, 1.0)
	label.outline_modulate = Color(0.05, 0.10, 0.20)
	label.outline_size = 4
	label.font_size = 64
	label.pixel_size = 0.005
	label.position = Vector3(0, 1.65, 0.50)
	tower.add_child(label)
	# Tower collision (capsule)
	var sb: StaticBody3D = StaticBody3D.new()
	sb.position = Vector3(0, 2.75, 0)
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cap: CapsuleShape3D = CapsuleShape3D.new()
	cap.radius = 0.55
	cap.height = 5.50
	cs.shape = cap
	sb.add_child(cs)
	tower.add_child(sb)


func _build_d5_meteorologist_npc(town: Node) -> void:
	## Epic-5 T29: meteorologist NPC — heavy parka, tablet in hand showing
	## weather data, knit beanie cap.
	var npc_slots: Node3D = town.get_node_or_null("%NPCSlots") as Node3D
	if npc_slots == null:
		return
	var slot: Marker3D = Marker3D.new()
	slot.name = "MeteorologistSlot"
	slot.position = Vector3(D5_CENTER.x + 16.0, 0.0, 13.0)
	npc_slots.add_child(slot)
	var npc_scene: PackedScene = load("res://scenes/entities/npcs/VillagerR3.tscn") as PackedScene
	if npc_scene == null:
		return
	var npc: Node3D = npc_scene.instantiate() as Node3D
	npc.name = "Meteorologist"
	if "npc_name" in npc:
		npc.set("npc_name", "Cumulis")
	if "npc_id" in npc:
		npc.set("npc_id", "weather_d5")
	slot.add_child(npc)
	# Heavy red parka
	var parka: MeshInstance3D = MeshInstance3D.new()
	var pmm: BoxMesh = BoxMesh.new()
	pmm.size = Vector3(0.75, 1.05, 0.50)
	parka.mesh = pmm
	var parka_mat: StandardMaterial3D = StandardMaterial3D.new()
	parka_mat.albedo_color = Color(0.85, 0.20, 0.30)
	parka_mat.roughness = 0.85
	parka.material_override = parka_mat
	parka.position = Vector3(0, 0.55, 0)
	npc.add_child(parka)
	# Knit beanie (small sphere on top of head)
	var beanie: MeshInstance3D = MeshInstance3D.new()
	var bm: SphereMesh = SphereMesh.new()
	bm.radius = 0.20
	bm.height = 0.32
	beanie.mesh = bm
	var beanie_mat: StandardMaterial3D = StandardMaterial3D.new()
	beanie_mat.albedo_color = Color(0.30, 0.45, 0.65)
	beanie_mat.roughness = 0.95
	beanie.material_override = beanie_mat
	beanie.position = Vector3(0, 1.50, 0)
	beanie.scale = Vector3(1.0, 0.65, 1.0)
	npc.add_child(beanie)
	# Tablet (flat box with glowing screen)
	var tablet: MeshInstance3D = MeshInstance3D.new()
	var tm: BoxMesh = BoxMesh.new()
	tm.size = Vector3(0.30, 0.40, 0.04)
	tablet.mesh = tm
	var tablet_mat: StandardMaterial3D = StandardMaterial3D.new()
	tablet_mat.albedo_color = Color(0.20, 0.25, 0.30)
	tablet_mat.metallic = 0.55
	tablet_mat.roughness = 0.30
	tablet.material_override = tablet_mat
	tablet.position = Vector3(0.40, 0.85, 0.20)
	tablet.rotation_degrees = Vector3(-25, 0, 0)
	npc.add_child(tablet)
	var screen: MeshInstance3D = MeshInstance3D.new()
	var scm: BoxMesh = BoxMesh.new()
	scm.size = Vector3(0.26, 0.36, 0.02)
	screen.mesh = scm
	var screen_mat: StandardMaterial3D = StandardMaterial3D.new()
	screen_mat.albedo_color = Color(0.30, 0.85, 1.0)
	screen_mat.emission_enabled = true
	screen_mat.emission = Color(0.30, 1.0, 1.0)
	screen_mat.emission_energy_multiplier = 2.5
	screen_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	screen.material_override = screen_mat
	screen.position = Vector3(0.40, 0.85, 0.25)
	screen.rotation_degrees = Vector3(-25, 0, 0)
	npc.add_child(screen)


func _build_d5_ice_fog(geom: Node) -> void:
	## Epic-5 T30: ground-level ice fog — slow-drifting GPU particles
	## providing atmospheric depth without using volumetric fog.
	var fog: GPUParticles3D = GPUParticles3D.new()
	fog.name = "IceFog"
	fog.position = Vector3(D5_CENTER.x, 0.5, 0.0)
	fog.amount = 80
	fog.lifetime = 14.0
	fog.preprocess = 7.0
	fog.explosiveness = 0.0
	fog.randomness = 0.85
	fog.visibility_aabb = AABB(Vector3(-40, -2, -25), Vector3(80, 8, 50))
	var pm: ParticleProcessMaterial = ParticleProcessMaterial.new()
	pm.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	pm.emission_box_extents = Vector3(32, 0.5, 20)
	pm.direction = Vector3(0.30, 0.10, 0.10)
	pm.spread = 65.0
	pm.gravity = Vector3(0.05, 0.06, 0.04)
	pm.initial_velocity_min = 0.10
	pm.initial_velocity_max = 0.35
	pm.scale_min = 0.45
	pm.scale_max = 1.10
	pm.color = Color(0.85, 0.92, 0.98, 0.35)
	fog.process_material = pm
	# Fog mesh — soft sphere
	var fog_mesh: SphereMesh = SphereMesh.new()
	fog_mesh.radius = 0.55
	fog_mesh.height = 1.10
	fog.draw_pass_1 = fog_mesh
	var fmat: StandardMaterial3D = StandardMaterial3D.new()
	fmat.albedo_color = Color(0.85, 0.92, 0.98, 0.25)
	fmat.emission_enabled = true
	fmat.emission = Color(0.65, 0.85, 0.95)
	fmat.emission_energy_multiplier = 0.40
	fmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	fmat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	fog_mesh.material = fmat
	geom.add_child(fog)


func _build_d5_dog_sled(geom: Node) -> void:
	## Epic-5 T31: traditional wooden dog sled — long curved runners,
	## a cargo basket, and a vertical handle for the musher.
	var sled: Node3D = Node3D.new()
	sled.name = "DogSled"
	sled.position = Vector3(D5_CENTER.x - 6.0, 0.0, 16.0)
	geom.add_child(sled)
	var wood_mat: StandardMaterial3D = StandardMaterial3D.new()
	wood_mat.albedo_color = Color(0.45, 0.28, 0.12)
	wood_mat.roughness = 0.85
	# 2 long runners
	for sz in [-0.45, 0.45]:
		var runner: MeshInstance3D = MeshInstance3D.new()
		var rm: BoxMesh = BoxMesh.new()
		rm.size = Vector3(2.40, 0.10, 0.18)
		runner.mesh = rm
		runner.material_override = wood_mat
		runner.position = Vector3(0, 0.10, sz)
		sled.add_child(runner)
		# Curved front (small angled box)
		var curl: MeshInstance3D = MeshInstance3D.new()
		var cm: BoxMesh = BoxMesh.new()
		cm.size = Vector3(0.45, 0.10, 0.18)
		curl.mesh = cm
		curl.material_override = wood_mat
		curl.position = Vector3(1.30, 0.25, sz)
		curl.rotation_degrees = Vector3(0, 0, 30)
		sled.add_child(curl)
	# Cargo basket (low box)
	var basket: MeshInstance3D = MeshInstance3D.new()
	var bmm: BoxMesh = BoxMesh.new()
	bmm.size = Vector3(2.0, 0.40, 0.85)
	basket.mesh = bmm
	basket.material_override = wood_mat
	basket.position = Vector3(0, 0.40, 0)
	sled.add_child(basket)
	# Side rails on basket
	for sz in [-0.40, 0.40]:
		var rail: MeshInstance3D = MeshInstance3D.new()
		var rmm: BoxMesh = BoxMesh.new()
		rmm.size = Vector3(2.0, 0.10, 0.06)
		rail.mesh = rmm
		rail.material_override = wood_mat
		rail.position = Vector3(0, 0.65, sz)
		sled.add_child(rail)
	# Vertical musher handle (tall U-shape via 2 posts + crossbar)
	for sx in [-0.85, -0.85]:
		pass  # placeholder so structure stays clean
	for sz_pair in [Vector3(-0.95, 0.85, -0.40), Vector3(-0.95, 0.85, 0.40)]:
		var post: MeshInstance3D = MeshInstance3D.new()
		var pmm: CylinderMesh = CylinderMesh.new()
		pmm.top_radius = 0.05
		pmm.bottom_radius = 0.06
		pmm.height = 0.85
		post.mesh = pmm
		post.material_override = wood_mat
		post.position = sz_pair
		sled.add_child(post)
	var crossbar: MeshInstance3D = MeshInstance3D.new()
	var cbm: CylinderMesh = CylinderMesh.new()
	cbm.top_radius = 0.05
	cbm.bottom_radius = 0.05
	cbm.height = 0.85
	crossbar.mesh = cbm
	crossbar.material_override = wood_mat
	crossbar.position = Vector3(-0.95, 1.30, 0)
	crossbar.rotation_degrees = Vector3(90, 0, 0)
	sled.add_child(crossbar)
	# Cargo blanket (red/blue)
	var blanket: MeshInstance3D = MeshInstance3D.new()
	var blm: BoxMesh = BoxMesh.new()
	blm.size = Vector3(1.85, 0.10, 0.75)
	blanket.mesh = blm
	var blanket_mat: StandardMaterial3D = StandardMaterial3D.new()
	blanket_mat.albedo_color = Color(0.85, 0.20, 0.30)
	blanket_mat.roughness = 0.85
	blanket.material_override = blanket_mat
	blanket.position = Vector3(0, 0.65, 0)
	sled.add_child(blanket)
	# Sled collision
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(2.85, 1.30, 1.10)
	cs.shape = cb
	cs.position = Vector3(-0.20, 0.65, 0)
	sb.add_child(cs)
	sled.add_child(sb)


func _build_d5_husky_team(geom: Node) -> void:
	## Epic-5 T32: 4 sled huskies in a 2-by-2 harness in front of the sled.
	## Black/white/grey fur, tongue out, tails up, mild bobbing.
	var team: Node3D = Node3D.new()
	team.name = "HuskyTeam"
	team.position = Vector3(D5_CENTER.x - 3.5, 0.0, 16.0)
	geom.add_child(team)
	var fur_colors: Array = [
		Color(0.30, 0.30, 0.30),
		Color(0.92, 0.92, 0.88),
		Color(0.55, 0.55, 0.55),
		Color(0.85, 0.85, 0.80),
	]
	var positions: Array = [
		Vector3(0.0, 0, -0.45),
		Vector3(0.0, 0,  0.45),
		Vector3(1.4, 0, -0.45),
		Vector3(1.4, 0,  0.45),
	]
	for i in 4:
		var husky: Node3D = Node3D.new()
		husky.position = positions[i]
		team.add_child(husky)
		var fur_mat: StandardMaterial3D = StandardMaterial3D.new()
		fur_mat.albedo_color = fur_colors[i]
		fur_mat.roughness = 0.85
		var white_mat: StandardMaterial3D = StandardMaterial3D.new()
		white_mat.albedo_color = Color(0.92, 0.92, 0.88)
		white_mat.roughness = 0.85
		# Body
		var body: MeshInstance3D = MeshInstance3D.new()
		var bm: SphereMesh = SphereMesh.new()
		bm.radius = 0.22
		bm.height = 0.40
		body.mesh = bm
		body.material_override = fur_mat
		body.position = Vector3(0, 0.32, 0)
		body.scale = Vector3(0.85, 0.75, 1.45)
		husky.add_child(body)
		# Head
		var head: MeshInstance3D = MeshInstance3D.new()
		var hm: SphereMesh = SphereMesh.new()
		hm.radius = 0.16
		hm.height = 0.28
		head.mesh = hm
		head.material_override = fur_mat
		head.position = Vector3(0, 0.45, 0.30)
		husky.add_child(head)
		# White muzzle
		var muzzle: MeshInstance3D = MeshInstance3D.new()
		var mm: BoxMesh = BoxMesh.new()
		mm.size = Vector3(0.10, 0.08, 0.16)
		muzzle.mesh = mm
		muzzle.material_override = white_mat
		muzzle.position = Vector3(0, 0.42, 0.42)
		husky.add_child(muzzle)
		# 2 ears (small prisms)
		for sx in [-0.08, 0.08]:
			var ear: MeshInstance3D = MeshInstance3D.new()
			var em: PrismMesh = PrismMesh.new()
			em.size = Vector3(0.06, 0.10, 0.04)
			ear.mesh = em
			ear.material_override = fur_mat
			ear.position = Vector3(sx, 0.58, 0.30)
			husky.add_child(ear)
		# 4 legs
		for lx in [-0.10, 0.10]:
			for lz in [-0.18, 0.18]:
				var leg: MeshInstance3D = MeshInstance3D.new()
				var lm: CylinderMesh = CylinderMesh.new()
				lm.top_radius = 0.04
				lm.bottom_radius = 0.04
				lm.height = 0.30
				leg.mesh = lm
				leg.material_override = fur_mat
				leg.position = Vector3(lx, 0.15, lz)
				husky.add_child(leg)
		# Tail (curved up cylinder)
		var tail: MeshInstance3D = MeshInstance3D.new()
		var tm: CylinderMesh = CylinderMesh.new()
		tm.top_radius = 0.04
		tm.bottom_radius = 0.06
		tm.height = 0.28
		tail.mesh = tm
		tail.material_override = fur_mat
		tail.position = Vector3(0, 0.42, -0.32)
		tail.rotation_degrees = Vector3(45, 0, 0)
		husky.add_child(tail)
		# Eyes (cyan glow — huskies have icy eyes)
		var eye_mat: StandardMaterial3D = StandardMaterial3D.new()
		eye_mat.albedo_color = Color(0.40, 0.95, 1.0)
		eye_mat.emission_enabled = true
		eye_mat.emission = Color(0.40, 1.0, 1.0)
		eye_mat.emission_energy_multiplier = 1.6
		eye_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		for ex in [-0.06, 0.06]:
			var eye: MeshInstance3D = MeshInstance3D.new()
			var emm: SphereMesh = SphereMesh.new()
			emm.radius = 0.025
			emm.height = 0.05
			eye.mesh = emm
			eye.material_override = eye_mat
			eye.position = Vector3(ex, 0.48, 0.42)
			husky.add_child(eye)
		# Bobbing tween (subtle running idle)
		var tw: Tween = husky.create_tween().set_loops()
		tw.tween_property(husky, "position:y", 0.04, 0.20 + randf() * 0.10)
		tw.tween_property(husky, "position:y", 0.0, 0.20 + randf() * 0.10)
	# Harness ropes (4 long thin cylinders from huskies back to sled)
	var rope_mat: StandardMaterial3D = StandardMaterial3D.new()
	rope_mat.albedo_color = Color(0.55, 0.45, 0.30)
	rope_mat.roughness = 0.85
	for sz in [-0.45, 0.45]:
		for x_offset in [0.0, 1.4]:
			var rope: MeshInstance3D = MeshInstance3D.new()
			var rm: CylinderMesh = CylinderMesh.new()
			rm.top_radius = 0.018
			rm.bottom_radius = 0.018
			rm.height = 1.30
			rope.mesh = rm
			rope.material_override = rope_mat
			rope.position = Vector3(x_offset - 1.3, 0.40, sz)
			rope.rotation_degrees = Vector3(0, 0, 90)
			team.add_child(rope)


func _build_d5_musher_npc(town: Node) -> void:
	## Epic-5 T33: musher NPC standing at the back handle of the sled.
	var npc_slots: Node3D = town.get_node_or_null("%NPCSlots") as Node3D
	if npc_slots == null:
		return
	var slot: Marker3D = Marker3D.new()
	slot.name = "MusherSlot"
	slot.position = Vector3(D5_CENTER.x - 7.2, 0.0, 16.0)
	npc_slots.add_child(slot)
	var npc_scene: PackedScene = load("res://scenes/entities/npcs/VillagerR3.tscn") as PackedScene
	if npc_scene == null:
		return
	var npc: Node3D = npc_scene.instantiate() as Node3D
	npc.name = "Musher"
	if "npc_name" in npc:
		npc.set("npc_name", "Cobalt")
	if "npc_id" in npc:
		npc.set("npc_id", "musher_d5")
	slot.add_child(npc)
	# Heavy black parka
	var parka: MeshInstance3D = MeshInstance3D.new()
	var pmm: BoxMesh = BoxMesh.new()
	pmm.size = Vector3(0.75, 1.10, 0.50)
	parka.mesh = pmm
	var parka_mat: StandardMaterial3D = StandardMaterial3D.new()
	parka_mat.albedo_color = Color(0.15, 0.20, 0.25)
	parka_mat.roughness = 0.85
	parka.material_override = parka_mat
	parka.position = Vector3(0, 0.60, 0)
	npc.add_child(parka)
	# Goggles strip across face (yellow tinted)
	var goggles: MeshInstance3D = MeshInstance3D.new()
	var gm: BoxMesh = BoxMesh.new()
	gm.size = Vector3(0.40, 0.10, 0.06)
	goggles.mesh = gm
	var gog_mat: StandardMaterial3D = StandardMaterial3D.new()
	gog_mat.albedo_color = Color(0.95, 0.85, 0.20, 0.85)
	gog_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	gog_mat.emission_enabled = true
	gog_mat.emission = Color(0.95, 0.85, 0.20)
	gog_mat.emission_energy_multiplier = 1.4
	gog_mat.metallic = 0.55
	gog_mat.roughness = 0.20
	goggles.material_override = gog_mat
	goggles.position = Vector3(0, 1.42, 0.20)
	npc.add_child(goggles)
	# Fur hood
	var hood: MeshInstance3D = MeshInstance3D.new()
	var hm: SphereMesh = SphereMesh.new()
	hm.radius = 0.26
	hm.height = 0.45
	hood.mesh = hm
	var fur_mat: StandardMaterial3D = StandardMaterial3D.new()
	fur_mat.albedo_color = Color(0.30, 0.30, 0.30)
	fur_mat.roughness = 0.95
	hood.material_override = fur_mat
	hood.position = Vector3(0, 1.45, -0.05)
	npc.add_child(hood)


func _build_d5_snow_fort(geom: Node) -> void:
	## Epic-5 T34: small snow fort — circular wall of stacked snow blocks
	## with crenellated top and a low entrance gap, made of pure white emissive
	## snow material. Fits the playful "kids built it" feel of D5.
	var fort: Node3D = Node3D.new()
	fort.name = "SnowFort"
	fort.position = Vector3(D5_CENTER.x - 16.0, 0.0, 4.0)
	geom.add_child(fort)
	var snow_mat: StandardMaterial3D = StandardMaterial3D.new()
	snow_mat.albedo_color = Color(0.95, 0.97, 1.0)
	snow_mat.emission_enabled = true
	snow_mat.emission = Color(0.75, 0.90, 1.0)
	snow_mat.emission_energy_multiplier = 0.30
	snow_mat.roughness = 0.55
	# 12 wall segments forming a circle, with a gap at the front (4 segments)
	for i in 12:
		if i >= 5 and i <= 7:
			continue  # entrance gap
		var ang: float = (TAU / 12.0) * i
		var block: MeshInstance3D = MeshInstance3D.new()
		var bm: BoxMesh = BoxMesh.new()
		bm.size = Vector3(1.10, 1.40, 0.85)
		block.mesh = bm
		block.material_override = snow_mat
		block.position = Vector3(cos(ang) * 2.85, 0.70, sin(ang) * 2.85)
		block.rotation = Vector3(0, -ang + PI * 0.5, 0)
		fort.add_child(block)
		# Crenellation (small block on top, every other position)
		if i % 2 == 0:
			var cren: MeshInstance3D = MeshInstance3D.new()
			var cm: BoxMesh = BoxMesh.new()
			cm.size = Vector3(0.55, 0.45, 0.85)
			cren.mesh = cm
			cren.material_override = snow_mat
			cren.position = Vector3(cos(ang) * 2.85, 1.62, sin(ang) * 2.85)
			cren.rotation = Vector3(0, -ang + PI * 0.5, 0)
			fort.add_child(cren)
		# Block collision
		var sb: StaticBody3D = StaticBody3D.new()
		sb.position = Vector3(cos(ang) * 2.85, 0.70, sin(ang) * 2.85)
		sb.rotation = Vector3(0, -ang + PI * 0.5, 0)
		var cs: CollisionShape3D = CollisionShape3D.new()
		var cb: BoxShape3D = BoxShape3D.new()
		cb.size = Vector3(1.10, 1.40, 0.85)
		cs.shape = cb
		sb.add_child(cs)
		fort.add_child(sb)
	# Stack of snowballs in the center (ammunition pile)
	var pile_positions: Array = [
		Vector3(-0.30, 0.20, 0.0),
		Vector3( 0.30, 0.20, 0.0),
		Vector3( 0.0, 0.20, 0.30),
		Vector3( 0.0, 0.20, -0.30),
		Vector3( 0.0, 0.55, 0.0),
	]
	for p in pile_positions:
		var ball: MeshInstance3D = MeshInstance3D.new()
		var bm: SphereMesh = SphereMesh.new()
		bm.radius = 0.20
		bm.height = 0.36
		ball.mesh = bm
		ball.material_override = snow_mat
		ball.position = p
		fort.add_child(ball)


func _build_d5_aurora_curtain(geom: Node) -> void:
	## Epic-5 T35: massive arching aurora curtain in the sky over D5 —
	## wide translucent multicolor sheet hovering at high altitude.
	var aurora: Node3D = Node3D.new()
	aurora.name = "AuroraCurtain"
	aurora.position = Vector3(D5_CENTER.x, 14.0, 0.0)
	geom.add_child(aurora)
	# 5 long curving sheets at different heights/colors
	var sheet_colors: Array = [
		Color(0.30, 0.95, 0.55),
		Color(0.30, 0.85, 0.95),
		Color(0.55, 0.40, 0.95),
		Color(0.30, 0.75, 0.65),
		Color(0.40, 0.85, 1.0),
	]
	for i in 5:
		var sheet: MeshInstance3D = MeshInstance3D.new()
		var sm: BoxMesh = BoxMesh.new()
		sm.size = Vector3(48.0, 0.10, 2.40)
		sheet.mesh = sm
		var smat: StandardMaterial3D = StandardMaterial3D.new()
		smat.albedo_color = Color(sheet_colors[i].r, sheet_colors[i].g, sheet_colors[i].b, 0.45)
		smat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		smat.emission_enabled = true
		smat.emission = sheet_colors[i]
		smat.emission_energy_multiplier = 1.6
		smat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		sheet.material_override = smat
		sheet.position = Vector3(0, i * 0.85, -8.0 + i * 1.40)
		sheet.rotation_degrees = Vector3(0, 0, sin(i) * 8.0)
		aurora.add_child(sheet)
		# Slow drift / shimmer (rotate slightly back and forth)
		var tw: Tween = sheet.create_tween().set_loops()
		tw.tween_property(sheet, "rotation_degrees:z", 12.0 + i, 6.0 + i * 0.4)
		tw.tween_property(sheet, "rotation_degrees:z", -12.0 - i, 6.0 + i * 0.4)


func _build_d5_ice_harvest_pit(geom: Node) -> void:
	## Epic-5 T36: rectangular ice harvesting pit dug into the snow with
	## chiseled walls and a row of ice saws/picks resting at one edge.
	var pit: Node3D = Node3D.new()
	pit.name = "IceHarvestPit"
	pit.position = Vector3(D5_CENTER.x + 14.0, 0.0, -16.0)
	geom.add_child(pit)
	# Dark recessed pit floor
	var floor_mat: StandardMaterial3D = StandardMaterial3D.new()
	floor_mat.albedo_color = Color(0.10, 0.20, 0.32)
	floor_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var floor_plane: MeshInstance3D = MeshInstance3D.new()
	var fpm: BoxMesh = BoxMesh.new()
	fpm.size = Vector3(4.50, 0.10, 3.20)
	floor_plane.mesh = fpm
	floor_plane.material_override = floor_mat
	floor_plane.position = Vector3(0, -0.20, 0)
	pit.add_child(floor_plane)
	# 4 chiseled wall slabs around the pit
	var ice_mat: StandardMaterial3D = StandardMaterial3D.new()
	ice_mat.albedo_color = Color(0.65, 0.85, 0.95, 0.85)
	ice_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	ice_mat.emission_enabled = true
	ice_mat.emission = Color(0.40, 0.85, 0.95)
	ice_mat.emission_energy_multiplier = 0.55
	ice_mat.metallic = 0.55
	ice_mat.roughness = 0.20
	var walls: Array = [
		{"size": Vector3(4.85, 0.55, 0.30), "pos": Vector3(0, 0.18,  1.65)},
		{"size": Vector3(4.85, 0.55, 0.30), "pos": Vector3(0, 0.18, -1.65)},
		{"size": Vector3(0.30, 0.55, 3.50), "pos": Vector3( 2.30, 0.18, 0)},
		{"size": Vector3(0.30, 0.55, 3.50), "pos": Vector3(-2.30, 0.18, 0)},
	]
	for w in walls:
		var wall: MeshInstance3D = MeshInstance3D.new()
		var wm: BoxMesh = BoxMesh.new()
		wm.size = w["size"]
		wall.mesh = wm
		wall.material_override = ice_mat
		wall.position = w["pos"]
		pit.add_child(wall)
	# Row of 3 ice saws/picks resting at the edge
	var metal_mat: StandardMaterial3D = StandardMaterial3D.new()
	metal_mat.albedo_color = Color(0.50, 0.55, 0.60)
	metal_mat.metallic = 0.85
	metal_mat.roughness = 0.30
	var wood_mat: StandardMaterial3D = StandardMaterial3D.new()
	wood_mat.albedo_color = Color(0.45, 0.28, 0.12)
	wood_mat.roughness = 0.85
	for i in 3:
		var handle: MeshInstance3D = MeshInstance3D.new()
		var hm: CylinderMesh = CylinderMesh.new()
		hm.top_radius = 0.05
		hm.bottom_radius = 0.06
		hm.height = 1.20
		handle.mesh = hm
		handle.material_override = wood_mat
		handle.position = Vector3(-1.85 + i * 1.80, 0.45, 1.85)
		handle.rotation_degrees = Vector3(70, 0, 0)
		pit.add_child(handle)
		var blade: MeshInstance3D = MeshInstance3D.new()
		var blm: BoxMesh = BoxMesh.new()
		blm.size = Vector3(0.30, 0.45, 0.06)
		blade.mesh = blm
		blade.material_override = metal_mat
		blade.position = Vector3(-1.85 + i * 1.80, 0.30, 1.20)
		blade.rotation_degrees = Vector3(20, 0, 0)
		pit.add_child(blade)


func _build_d5_ice_block_stacks(geom: Node) -> void:
	## Epic-5 T37: 3 stacks of harvested ice blocks ready for transport.
	var stacks: Node3D = Node3D.new()
	stacks.name = "IceBlockStacks"
	stacks.position = Vector3(D5_CENTER.x + 8.0, 0.0, -16.0)
	geom.add_child(stacks)
	var ice_mat: StandardMaterial3D = StandardMaterial3D.new()
	ice_mat.albedo_color = Color(0.70, 0.88, 0.95, 0.92)
	ice_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	ice_mat.emission_enabled = true
	ice_mat.emission = Color(0.45, 0.85, 0.95)
	ice_mat.emission_energy_multiplier = 0.55
	ice_mat.metallic = 0.55
	ice_mat.roughness = 0.15
	# 3 stacks of 4 blocks each (2x2 base + 2 top)
	for s in 3:
		var sx: float = s * 2.40
		# 4 base blocks (2×2)
		for i in 2:
			for j in 2:
				var block: MeshInstance3D = MeshInstance3D.new()
				var bm: BoxMesh = BoxMesh.new()
				bm.size = Vector3(0.85, 0.65, 0.85)
				block.mesh = bm
				block.material_override = ice_mat
				block.position = Vector3(sx + i * 0.90, 0.32, j * 0.90)
				stacks.add_child(block)
				# Block collision
				var sb: StaticBody3D = StaticBody3D.new()
				sb.position = block.position
				var cs: CollisionShape3D = CollisionShape3D.new()
				var cb: BoxShape3D = BoxShape3D.new()
				cb.size = bm.size
				cs.shape = cb
				sb.add_child(cs)
				stacks.add_child(sb)
		# 1 top block centered
		var top: MeshInstance3D = MeshInstance3D.new()
		var tm: BoxMesh = BoxMesh.new()
		tm.size = Vector3(0.85, 0.65, 0.85)
		top.mesh = tm
		top.material_override = ice_mat
		top.position = Vector3(sx + 0.45, 0.97, 0.45)
		stacks.add_child(top)


func _build_d5_data_analyst_npc(town: Node) -> void:
	## Epic-5 T38: data analyst NPC — slim grey suit (no parka, indoor type),
	## holding a glowing tablet, surrounded by tiny floating data cubes.
	var npc_slots: Node3D = town.get_node_or_null("%NPCSlots") as Node3D
	if npc_slots == null:
		return
	var slot: Marker3D = Marker3D.new()
	slot.name = "DataAnalystSlot"
	slot.position = Vector3(D5_CENTER.x - 12.0, 0.0, 8.0)
	npc_slots.add_child(slot)
	var npc_scene: PackedScene = load("res://scenes/entities/npcs/VillagerR3.tscn") as PackedScene
	if npc_scene == null:
		return
	var npc: Node3D = npc_scene.instantiate() as Node3D
	npc.name = "DataAnalyst"
	if "npc_name" in npc:
		npc.set("npc_name", "Indexa")
	if "npc_id" in npc:
		npc.set("npc_id", "analyst_d5")
	slot.add_child(npc)
	# Slim grey suit
	var suit: MeshInstance3D = MeshInstance3D.new()
	var sm: BoxMesh = BoxMesh.new()
	sm.size = Vector3(0.55, 1.05, 0.35)
	suit.mesh = sm
	var suit_mat: StandardMaterial3D = StandardMaterial3D.new()
	suit_mat.albedo_color = Color(0.40, 0.45, 0.50)
	suit_mat.metallic = 0.20
	suit_mat.roughness = 0.55
	suit.material_override = suit_mat
	suit.position = Vector3(0, 0.55, 0)
	npc.add_child(suit)
	# Tablet held in front
	var tablet: MeshInstance3D = MeshInstance3D.new()
	var tm: BoxMesh = BoxMesh.new()
	tm.size = Vector3(0.30, 0.40, 0.04)
	tablet.mesh = tm
	var tablet_mat: StandardMaterial3D = StandardMaterial3D.new()
	tablet_mat.albedo_color = Color(0.20, 0.25, 0.30)
	tablet_mat.metallic = 0.65
	tablet_mat.roughness = 0.20
	tablet.material_override = tablet_mat
	tablet.position = Vector3(0, 0.85, 0.35)
	tablet.rotation_degrees = Vector3(-30, 0, 0)
	npc.add_child(tablet)
	# Glowing screen
	var screen: MeshInstance3D = MeshInstance3D.new()
	var scm: BoxMesh = BoxMesh.new()
	scm.size = Vector3(0.27, 0.36, 0.02)
	screen.mesh = scm
	var screen_mat: StandardMaterial3D = StandardMaterial3D.new()
	screen_mat.albedo_color = Color(0.40, 0.95, 1.0)
	screen_mat.emission_enabled = true
	screen_mat.emission = Color(0.30, 1.0, 1.0)
	screen_mat.emission_energy_multiplier = 2.5
	screen_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	screen.material_override = screen_mat
	screen.position = Vector3(0, 0.85, 0.40)
	screen.rotation_degrees = Vector3(-30, 0, 0)
	npc.add_child(screen)
	# 4 floating tiny data cubes orbiting
	var cube_mat: StandardMaterial3D = StandardMaterial3D.new()
	cube_mat.albedo_color = Color(0.30, 0.85, 1.0)
	cube_mat.emission_enabled = true
	cube_mat.emission = Color(0.30, 0.95, 1.0)
	cube_mat.emission_energy_multiplier = 2.5
	cube_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var pivot: Node3D = Node3D.new()
	pivot.position = Vector3(0, 1.30, 0)
	npc.add_child(pivot)
	for i in 4:
		var cube: MeshInstance3D = MeshInstance3D.new()
		var cmm: BoxMesh = BoxMesh.new()
		cmm.size = Vector3(0.10, 0.10, 0.10)
		cube.mesh = cmm
		cube.material_override = cube_mat
		var ang: float = (TAU / 4.0) * i
		cube.position = Vector3(cos(ang) * 0.55, sin(i) * 0.10, sin(ang) * 0.55)
		pivot.add_child(cube)
	var trot: Tween = pivot.create_tween().set_loops()
	trot.tween_property(pivot, "rotation_degrees:y", 360.0, 5.0)
	trot.tween_property(pivot, "rotation_degrees:y", 0.0, 0.0)


func _build_d5_holo_charts(geom: Node) -> void:
	## Epic-5 T39: 3 large floating holographic chart panels showing
	## bar-graph data spikes, hovering above a small projector base.
	var charts: Node3D = Node3D.new()
	charts.name = "HoloCharts"
	charts.position = Vector3(D5_CENTER.x - 10.0, 0.0, 8.0)
	geom.add_child(charts)
	var metal_mat: StandardMaterial3D = StandardMaterial3D.new()
	metal_mat.albedo_color = Color(0.30, 0.35, 0.40)
	metal_mat.metallic = 0.85
	metal_mat.roughness = 0.30
	# Projector base
	var base: MeshInstance3D = MeshInstance3D.new()
	var bm: CylinderMesh = CylinderMesh.new()
	bm.top_radius = 0.85
	bm.bottom_radius = 0.95
	bm.height = 0.30
	base.mesh = bm
	base.material_override = metal_mat
	base.position = Vector3(0, 0.15, 0)
	charts.add_child(base)
	# 3 chart panels around the base
	var panel_mat: StandardMaterial3D = StandardMaterial3D.new()
	panel_mat.albedo_color = Color(0.30, 0.85, 1.0, 0.55)
	panel_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	panel_mat.emission_enabled = true
	panel_mat.emission = Color(0.30, 0.95, 1.0)
	panel_mat.emission_energy_multiplier = 1.4
	panel_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var bar_mat: StandardMaterial3D = StandardMaterial3D.new()
	bar_mat.albedo_color = Color(0.40, 1.0, 0.85)
	bar_mat.emission_enabled = true
	bar_mat.emission = Color(0.30, 1.0, 0.85)
	bar_mat.emission_energy_multiplier = 2.5
	bar_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for i in 3:
		var ang: float = (TAU / 3.0) * i
		var panel: MeshInstance3D = MeshInstance3D.new()
		var pm: BoxMesh = BoxMesh.new()
		pm.size = Vector3(1.20, 1.40, 0.06)
		panel.mesh = pm
		panel.material_override = panel_mat
		panel.position = Vector3(cos(ang) * 0.85, 1.30, sin(ang) * 0.85)
		panel.rotation = Vector3(0, -ang + PI * 0.5, 0)
		charts.add_child(panel)
		# 6 vertical bars on the panel (random heights)
		for b in 6:
			var bar: MeshInstance3D = MeshInstance3D.new()
			var bbm: BoxMesh = BoxMesh.new()
			var height: float = 0.20 + randf() * 0.85
			bbm.size = Vector3(0.10, height, 0.04)
			bar.mesh = bbm
			bar.material_override = bar_mat
			var local_x: float = -0.50 + b * 0.18
			bar.position = Vector3(
				cos(ang) * 0.85 + cos(ang + PI * 0.5) * local_x,
				1.30 - 0.55 + height * 0.5,
				sin(ang) * 0.85 + sin(ang + PI * 0.5) * local_x
			)
			bar.rotation = Vector3(0, -ang + PI * 0.5, 0)
			charts.add_child(bar)
			# Animate bar height
			var tw: Tween = bar.create_tween().set_loops()
			tw.tween_interval((i * 6 + b) * 0.10)
			tw.tween_property(bar, "scale:y", randf_range(0.40, 1.30), 0.85)
			tw.tween_property(bar, "scale:y", randf_range(0.40, 1.30), 0.85)
	# Light from projector
	var light: OmniLight3D = OmniLight3D.new()
	light.light_color = Color(0.40, 0.95, 1.0)
	light.light_energy = 1.4
	light.omni_range = 4.0
	light.position = Vector3(0, 0.50, 0)
	charts.add_child(light)
	# Base collision
	var sb: StaticBody3D = StaticBody3D.new()
	sb.position = Vector3(0, 0.15, 0)
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cap: CylinderShape3D = CylinderShape3D.new()
	cap.radius = 0.95
	cap.height = 0.30
	cs.shape = cap
	sb.add_child(cs)
	charts.add_child(sb)


func _build_d5_lab_hut(geom: Node) -> void:
	## Epic-5 T40: small frozen research lab hut — a low ice-block building
	## with a steel door and 2 glowing porthole windows.
	var hut: Node3D = Node3D.new()
	hut.name = "LabHut"
	hut.position = Vector3(D5_CENTER.x - 18.0, 0.0, 14.0)
	geom.add_child(hut)
	var ice_mat: StandardMaterial3D = StandardMaterial3D.new()
	ice_mat.albedo_color = Color(0.78, 0.90, 0.96)
	ice_mat.emission_enabled = true
	ice_mat.emission = Color(0.55, 0.85, 0.95)
	ice_mat.emission_energy_multiplier = 0.30
	ice_mat.roughness = 0.45
	# Main building (large box)
	var main: MeshInstance3D = MeshInstance3D.new()
	var mm: BoxMesh = BoxMesh.new()
	mm.size = Vector3(3.20, 2.40, 2.85)
	main.mesh = mm
	main.material_override = ice_mat
	main.position = Vector3(0, 1.20, 0)
	hut.add_child(main)
	# Sloped roof
	var roof: MeshInstance3D = MeshInstance3D.new()
	var rm: PrismMesh = PrismMesh.new()
	rm.size = Vector3(3.40, 0.85, 3.05)
	roof.mesh = rm
	roof.material_override = ice_mat
	roof.position = Vector3(0, 2.85, 0)
	hut.add_child(roof)
	# Steel door
	var door_mat: StandardMaterial3D = StandardMaterial3D.new()
	door_mat.albedo_color = Color(0.30, 0.35, 0.40)
	door_mat.metallic = 0.75
	door_mat.roughness = 0.35
	var door: MeshInstance3D = MeshInstance3D.new()
	var dm: BoxMesh = BoxMesh.new()
	dm.size = Vector3(0.85, 1.65, 0.10)
	door.mesh = dm
	door.material_override = door_mat
	door.position = Vector3(0, 0.85, 1.45)
	hut.add_child(door)
	# Door handle
	var handle: MeshInstance3D = MeshInstance3D.new()
	var hm: SphereMesh = SphereMesh.new()
	hm.radius = 0.05
	hm.height = 0.10
	handle.mesh = hm
	var handle_mat: StandardMaterial3D = StandardMaterial3D.new()
	handle_mat.albedo_color = Color(0.85, 0.85, 0.20)
	handle_mat.metallic = 0.85
	handle_mat.roughness = 0.20
	handle.material_override = handle_mat
	handle.position = Vector3(0.30, 0.85, 1.51)
	hut.add_child(handle)
	# 2 porthole windows on the side
	var window_mat: StandardMaterial3D = StandardMaterial3D.new()
	window_mat.albedo_color = Color(0.40, 0.95, 1.0, 0.85)
	window_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	window_mat.emission_enabled = true
	window_mat.emission = Color(0.40, 1.0, 1.0)
	window_mat.emission_energy_multiplier = 2.5
	window_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for sx in [-1.0, 1.0]:
		var win: MeshInstance3D = MeshInstance3D.new()
		var wm: SphereMesh = SphereMesh.new()
		wm.radius = 0.30
		wm.height = 0.55
		win.mesh = wm
		win.material_override = window_mat
		win.position = Vector3(sx * 1.65, 1.40, 0)
		win.scale = Vector3(0.18, 1.0, 1.0)
		hut.add_child(win)
		# Light from window
		var light: OmniLight3D = OmniLight3D.new()
		light.light_color = Color(0.40, 0.95, 1.0)
		light.light_energy = 1.4
		light.omni_range = 3.0
		light.position = Vector3(sx * 1.85, 1.40, 0)
		hut.add_child(light)
	# Building collision
	var sb: StaticBody3D = StaticBody3D.new()
	sb.position = Vector3(0, 1.20, 0)
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(3.20, 2.40, 2.85)
	cs.shape = cb
	sb.add_child(cs)
	hut.add_child(sb)


func _build_d5_ice_rink(geom: Node) -> void:
	## Epic-5 T41: large rectangular ice rink with low wooden barriers
	## around the perimeter, marked center circle, and 2 face-off dots.
	var rink: Node3D = Node3D.new()
	rink.name = "IceRink"
	rink.position = Vector3(D5_CENTER.x - 14.0, 0.0, -14.0)
	geom.add_child(rink)
	# Main rink surface — large flat ice cylinder
	var ice_mat: StandardMaterial3D = StandardMaterial3D.new()
	ice_mat.albedo_color = Color(0.78, 0.92, 1.0)
	ice_mat.emission_enabled = true
	ice_mat.emission = Color(0.55, 0.85, 1.0)
	ice_mat.emission_energy_multiplier = 0.45
	ice_mat.metallic = 0.40
	ice_mat.roughness = 0.10
	var surface: MeshInstance3D = MeshInstance3D.new()
	var sm: BoxMesh = BoxMesh.new()
	sm.size = Vector3(8.50, 0.10, 5.50)
	surface.mesh = sm
	surface.material_override = ice_mat
	surface.position = Vector3(0, 0.05, 0)
	rink.add_child(surface)
	# 4 wooden barrier walls
	var wood_mat: StandardMaterial3D = StandardMaterial3D.new()
	wood_mat.albedo_color = Color(0.55, 0.35, 0.18)
	wood_mat.roughness = 0.85
	var walls: Array = [
		{"size": Vector3(8.85, 0.55, 0.18), "pos": Vector3(0, 0.30,  2.85)},
		{"size": Vector3(8.85, 0.55, 0.18), "pos": Vector3(0, 0.30, -2.85)},
		{"size": Vector3(0.18, 0.55, 5.85), "pos": Vector3( 4.40, 0.30, 0)},
		{"size": Vector3(0.18, 0.55, 5.85), "pos": Vector3(-4.40, 0.30, 0)},
	]
	for w in walls:
		var wall: MeshInstance3D = MeshInstance3D.new()
		var wm: BoxMesh = BoxMesh.new()
		wm.size = w["size"]
		wall.mesh = wm
		wall.material_override = wood_mat
		wall.position = w["pos"]
		rink.add_child(wall)
		# Wall collision
		var sb: StaticBody3D = StaticBody3D.new()
		sb.position = w["pos"]
		var cs: CollisionShape3D = CollisionShape3D.new()
		var cb: BoxShape3D = BoxShape3D.new()
		cb.size = w["size"]
		cs.shape = cb
		sb.add_child(cs)
		rink.add_child(sb)
	# Center circle (red painted ring)
	var paint_mat: StandardMaterial3D = StandardMaterial3D.new()
	paint_mat.albedo_color = Color(0.85, 0.20, 0.20)
	paint_mat.emission_enabled = true
	paint_mat.emission = Color(0.85, 0.20, 0.20)
	paint_mat.emission_energy_multiplier = 0.45
	paint_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var ring: MeshInstance3D = MeshInstance3D.new()
	var rm: TorusMesh = TorusMesh.new()
	rm.inner_radius = 0.95
	rm.outer_radius = 1.10
	ring.mesh = rm
	ring.material_override = paint_mat
	ring.position = Vector3(0, 0.12, 0)
	rink.add_child(ring)
	# 2 face-off dots
	for sx in [-2.85, 2.85]:
		var dot: MeshInstance3D = MeshInstance3D.new()
		var dm: CylinderMesh = CylinderMesh.new()
		dm.top_radius = 0.30
		dm.bottom_radius = 0.30
		dm.height = 0.04
		dot.mesh = dm
		dot.material_override = paint_mat
		dot.position = Vector3(sx, 0.13, 0)
		rink.add_child(dot)


func _build_d5_skater_npc(geom: Node) -> void:
	## Epic-5 T42: skater character circling the rink center continuously.
	## Uses a self-built body (not the VillagerR3 prefab) so we can move it
	## freely inside the rink without an NPCSlot binding.
	var skater: Node3D = Node3D.new()
	skater.name = "IceSkater"
	skater.position = Vector3(D5_CENTER.x - 14.0, 0.0, -14.0)
	geom.add_child(skater)
	# Pivot for circling
	var pivot: Node3D = Node3D.new()
	skater.add_child(pivot)
	var body_root: Node3D = Node3D.new()
	body_root.position = Vector3(2.20, 0, 0)
	pivot.add_child(body_root)
	# Body — purple skating outfit
	var body_mat: StandardMaterial3D = StandardMaterial3D.new()
	body_mat.albedo_color = Color(0.55, 0.30, 0.85)
	body_mat.emission_enabled = true
	body_mat.emission = Color(0.45, 0.20, 0.85)
	body_mat.emission_energy_multiplier = 0.30
	body_mat.roughness = 0.55
	var body: MeshInstance3D = MeshInstance3D.new()
	var bm: BoxMesh = BoxMesh.new()
	bm.size = Vector3(0.55, 1.05, 0.35)
	body.mesh = bm
	body.material_override = body_mat
	body.position = Vector3(0, 0.85, 0)
	body_root.add_child(body)
	# Head
	var head: MeshInstance3D = MeshInstance3D.new()
	var hm: SphereMesh = SphereMesh.new()
	hm.radius = 0.18
	hm.height = 0.32
	head.mesh = hm
	var skin_mat: StandardMaterial3D = StandardMaterial3D.new()
	skin_mat.albedo_color = Color(0.95, 0.85, 0.75)
	skin_mat.roughness = 0.65
	head.material_override = skin_mat
	head.position = Vector3(0, 1.55, 0)
	body_root.add_child(head)
	# Skates (white blades)
	for sx in [-0.10, 0.10]:
		var skate: MeshInstance3D = MeshInstance3D.new()
		var skm: BoxMesh = BoxMesh.new()
		skm.size = Vector3(0.10, 0.06, 0.30)
		skate.mesh = skm
		var skate_mat: StandardMaterial3D = StandardMaterial3D.new()
		skate_mat.albedo_color = Color(0.95, 0.95, 0.92)
		skate_mat.metallic = 0.65
		skate_mat.roughness = 0.20
		skate.material_override = skate_mat
		skate.position = Vector3(sx, 0.22, 0)
		body_root.add_child(skate)
	# Trailing ice spray particles (small effect behind skater)
	var spray: GPUParticles3D = GPUParticles3D.new()
	spray.amount = 30
	spray.lifetime = 0.85
	spray.preprocess = 0.5
	spray.position = Vector3(0, 0.10, -0.30)
	var pm: ParticleProcessMaterial = ParticleProcessMaterial.new()
	pm.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_POINT
	pm.direction = Vector3(0, 0.5, -1.0)
	pm.spread = 35.0
	pm.gravity = Vector3.ZERO
	pm.initial_velocity_min = 1.0
	pm.initial_velocity_max = 2.5
	pm.scale_min = 0.05
	pm.scale_max = 0.10
	pm.color = Color(0.95, 0.95, 1.0, 0.85)
	spray.process_material = pm
	var spray_mesh: SphereMesh = SphereMesh.new()
	spray_mesh.radius = 0.04
	spray_mesh.height = 0.08
	spray.draw_pass_1 = spray_mesh
	var sp_mat: StandardMaterial3D = StandardMaterial3D.new()
	sp_mat.albedo_color = Color(0.95, 0.95, 1.0)
	sp_mat.emission_enabled = true
	sp_mat.emission = Color(0.85, 0.95, 1.0)
	sp_mat.emission_energy_multiplier = 1.4
	sp_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	spray_mesh.material = sp_mat
	body_root.add_child(spray)
	# Pivot circling tween
	var trot: Tween = pivot.create_tween().set_loops()
	trot.tween_property(pivot, "rotation_degrees:y", 360.0, 6.0)
	trot.tween_property(pivot, "rotation_degrees:y", 0.0, 0.0)
	# Subtle body lean during turns (sway)
	var tlean: Tween = body_root.create_tween().set_loops()
	tlean.tween_property(body_root, "rotation_degrees:z", -8.0, 1.5)
	tlean.tween_property(body_root, "rotation_degrees:z", 8.0, 1.5)


func _build_d5_warming_campfire(geom: Node) -> void:
	## Epic-5 T43: small warming campfire — stone ring + crossed logs +
	## flickering orange fire core + warm OmniLight.
	var fire: Node3D = Node3D.new()
	fire.name = "WarmingCampfire"
	fire.position = Vector3(D5_CENTER.x - 4.0, 0.0, 16.0)
	geom.add_child(fire)
	# Stone ring (8 small stones)
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.40, 0.42, 0.45)
	stone_mat.roughness = 0.92
	for i in 8:
		var ang: float = (TAU / 8.0) * i
		var stone: MeshInstance3D = MeshInstance3D.new()
		var sm: SphereMesh = SphereMesh.new()
		sm.radius = 0.20
		sm.height = 0.30
		stone.mesh = sm
		stone.material_override = stone_mat
		stone.position = Vector3(cos(ang) * 0.85, 0.10, sin(ang) * 0.85)
		stone.scale = Vector3(1.0, 0.65, 1.0)
		fire.add_child(stone)
	# Crossed logs
	var wood_mat: StandardMaterial3D = StandardMaterial3D.new()
	wood_mat.albedo_color = Color(0.30, 0.18, 0.10)
	wood_mat.roughness = 0.95
	for i in 3:
		var log_n: MeshInstance3D = MeshInstance3D.new()
		var lm: CylinderMesh = CylinderMesh.new()
		lm.top_radius = 0.10
		lm.bottom_radius = 0.10
		lm.height = 1.20
		log_n.mesh = lm
		log_n.material_override = wood_mat
		log_n.position = Vector3(0, 0.20, 0)
		log_n.rotation = Vector3(deg_to_rad(85), deg_to_rad(60 * i), 0)
		fire.add_child(log_n)
	# Fire core (glowing flame sphere stack)
	var fire_mat: StandardMaterial3D = StandardMaterial3D.new()
	fire_mat.albedo_color = Color(1.0, 0.65, 0.20)
	fire_mat.emission_enabled = true
	fire_mat.emission = Color(1.0, 0.55, 0.10)
	fire_mat.emission_energy_multiplier = 3.5
	fire_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for i in 3:
		var flame: MeshInstance3D = MeshInstance3D.new()
		var fm: SphereMesh = SphereMesh.new()
		fm.radius = 0.18 - i * 0.04
		fm.height = 0.30 - i * 0.05
		flame.mesh = fm
		flame.material_override = fire_mat
		flame.position = Vector3(0, 0.45 + i * 0.20, 0)
		fire.add_child(flame)
		# Flicker
		var tw: Tween = flame.create_tween().set_loops()
		tw.tween_interval(i * 0.10)
		tw.tween_property(flame, "scale", Vector3(1.20, 1.30, 1.20), 0.20)
		tw.tween_property(flame, "scale", Vector3(0.85, 0.85, 0.85), 0.20)
	# Warm OmniLight
	var light: OmniLight3D = OmniLight3D.new()
	light.light_color = Color(1.0, 0.65, 0.30)
	light.light_energy = 2.6
	light.omni_range = 6.0
	light.position = Vector3(0, 0.65, 0)
	fire.add_child(light)
	# Light pulse (fire flicker)
	var twl: Tween = light.create_tween().set_loops()
	twl.tween_property(light, "light_energy", 3.2, 0.30)
	twl.tween_property(light, "light_energy", 2.4, 0.30)


func _build_d5_cocoa_stand(geom: Node) -> void:
	## Epic-5 T44: hot cocoa vendor stand — wooden booth with a steaming
	## kettle, mugs, and a 'HOT COCOA' sign.
	var stand: Node3D = Node3D.new()
	stand.name = "CocoaStand"
	stand.position = Vector3(D5_CENTER.x - 2.0, 0.0, 16.0)
	geom.add_child(stand)
	var wood_mat: StandardMaterial3D = StandardMaterial3D.new()
	wood_mat.albedo_color = Color(0.55, 0.35, 0.18)
	wood_mat.roughness = 0.85
	# Counter
	var counter: MeshInstance3D = MeshInstance3D.new()
	var cm: BoxMesh = BoxMesh.new()
	cm.size = Vector3(2.20, 0.10, 0.85)
	counter.mesh = cm
	counter.material_override = wood_mat
	counter.position = Vector3(0, 1.10, 0)
	stand.add_child(counter)
	# Counter legs
	for sx in [-1.0, 1.0]:
		for sz in [-0.35, 0.35]:
			var leg: MeshInstance3D = MeshInstance3D.new()
			var lm: BoxMesh = BoxMesh.new()
			lm.size = Vector3(0.10, 1.10, 0.10)
			leg.mesh = lm
			leg.material_override = wood_mat
			leg.position = Vector3(sx, 0.55, sz)
			stand.add_child(leg)
	# Roof shade
	var roof: MeshInstance3D = MeshInstance3D.new()
	var rm: BoxMesh = BoxMesh.new()
	rm.size = Vector3(2.40, 0.10, 1.0)
	roof.mesh = rm
	var roof_mat: StandardMaterial3D = StandardMaterial3D.new()
	roof_mat.albedo_color = Color(0.85, 0.20, 0.20)
	roof_mat.roughness = 0.85
	roof.material_override = roof_mat
	roof.position = Vector3(0, 2.20, -0.10)
	roof.rotation_degrees = Vector3(-12, 0, 0)
	stand.add_child(roof)
	# Roof support posts
	for sx in [-1.10, 1.10]:
		var post: MeshInstance3D = MeshInstance3D.new()
		var pmm: CylinderMesh = CylinderMesh.new()
		pmm.top_radius = 0.05
		pmm.bottom_radius = 0.05
		pmm.height = 1.10
		post.mesh = pmm
		post.material_override = wood_mat
		post.position = Vector3(sx, 1.65, -0.30)
		stand.add_child(post)
	# Steaming kettle (large cylinder + handle arc + steam particles)
	var metal_mat: StandardMaterial3D = StandardMaterial3D.new()
	metal_mat.albedo_color = Color(0.40, 0.45, 0.50)
	metal_mat.metallic = 0.85
	metal_mat.roughness = 0.30
	var kettle: MeshInstance3D = MeshInstance3D.new()
	var km: CylinderMesh = CylinderMesh.new()
	km.top_radius = 0.20
	km.bottom_radius = 0.25
	km.height = 0.40
	kettle.mesh = km
	kettle.material_override = metal_mat
	kettle.position = Vector3(-0.55, 1.35, 0)
	stand.add_child(kettle)
	var spout: MeshInstance3D = MeshInstance3D.new()
	var spm: CylinderMesh = CylinderMesh.new()
	spm.top_radius = 0.03
	spm.bottom_radius = 0.05
	spm.height = 0.30
	spout.mesh = spm
	spout.material_override = metal_mat
	spout.position = Vector3(-0.30, 1.42, 0)
	spout.rotation_degrees = Vector3(0, 0, -55)
	stand.add_child(spout)
	# Steam particles
	var steam: GPUParticles3D = GPUParticles3D.new()
	steam.amount = 25
	steam.lifetime = 1.8
	steam.preprocess = 1.0
	steam.position = Vector3(-0.55, 1.65, 0)
	var pm_steam: ParticleProcessMaterial = ParticleProcessMaterial.new()
	pm_steam.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_POINT
	pm_steam.direction = Vector3(0, 1, 0)
	pm_steam.spread = 18.0
	pm_steam.gravity = Vector3(0.05, 0.45, 0)
	pm_steam.initial_velocity_min = 0.20
	pm_steam.initial_velocity_max = 0.55
	pm_steam.scale_min = 0.18
	pm_steam.scale_max = 0.40
	pm_steam.color = Color(0.95, 0.95, 1.0, 0.55)
	steam.process_material = pm_steam
	var sm_mesh: SphereMesh = SphereMesh.new()
	sm_mesh.radius = 0.18
	sm_mesh.height = 0.36
	steam.draw_pass_1 = sm_mesh
	var sm_mat: StandardMaterial3D = StandardMaterial3D.new()
	sm_mat.albedo_color = Color(0.95, 0.95, 1.0, 0.45)
	sm_mat.emission_enabled = true
	sm_mat.emission = Color(0.85, 0.92, 1.0)
	sm_mat.emission_energy_multiplier = 0.65
	sm_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	sm_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	sm_mesh.material = sm_mat
	stand.add_child(steam)
	# 4 mugs lined up on the counter
	var mug_mat: StandardMaterial3D = StandardMaterial3D.new()
	mug_mat.albedo_color = Color(0.85, 0.85, 0.80)
	mug_mat.roughness = 0.65
	for i in 4:
		var mug: MeshInstance3D = MeshInstance3D.new()
		var mm: CylinderMesh = CylinderMesh.new()
		mm.top_radius = 0.08
		mm.bottom_radius = 0.08
		mm.height = 0.16
		mug.mesh = mm
		mug.material_override = mug_mat
		mug.position = Vector3(0.10 + i * 0.22, 1.23, 0)
		stand.add_child(mug)
		# Cocoa surface (small dark brown disc)
		var cocoa: MeshInstance3D = MeshInstance3D.new()
		var cmm2: CylinderMesh = CylinderMesh.new()
		cmm2.top_radius = 0.07
		cmm2.bottom_radius = 0.07
		cmm2.height = 0.02
		cocoa.mesh = cmm2
		var cocoa_mat: StandardMaterial3D = StandardMaterial3D.new()
		cocoa_mat.albedo_color = Color(0.30, 0.18, 0.10)
		cocoa_mat.roughness = 0.55
		cocoa.material_override = cocoa_mat
		cocoa.position = Vector3(0.10 + i * 0.22, 1.32, 0)
		stand.add_child(cocoa)
	# 'HOT COCOA' sign hanging from the roof
	var sign: MeshInstance3D = MeshInstance3D.new()
	var snm: BoxMesh = BoxMesh.new()
	snm.size = Vector3(1.20, 0.40, 0.06)
	sign.mesh = snm
	var sign_mat: StandardMaterial3D = StandardMaterial3D.new()
	sign_mat.albedo_color = Color(0.95, 0.85, 0.55)
	sign_mat.roughness = 0.85
	sign.material_override = sign_mat
	sign.position = Vector3(0, 1.85, -0.20)
	stand.add_child(sign)
	var label: Label3D = Label3D.new()
	label.text = "HOT COCOA"
	label.modulate = Color(0.30, 0.18, 0.10)
	label.outline_modulate = Color(0.95, 0.85, 0.55)
	label.outline_size = 4
	label.font_size = 64
	label.pixel_size = 0.005
	label.position = Vector3(0, 1.88, -0.16)
	stand.add_child(label)
	# Counter collision
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(2.20, 1.30, 0.85)
	cs.shape = cb
	cs.position = Vector3(0, 0.65, 0)
	sb.add_child(cs)
	stand.add_child(sb)


func _build_d5_cocoa_vendor_npc(town: Node) -> void:
	## Epic-5 T45: cocoa vendor NPC at the cocoa stand — apron + chef hat.
	var npc_slots: Node3D = town.get_node_or_null("%NPCSlots") as Node3D
	if npc_slots == null:
		return
	var slot: Marker3D = Marker3D.new()
	slot.name = "CocoaVendorSlot"
	slot.position = Vector3(D5_CENTER.x - 2.0, 0.0, 15.0)
	npc_slots.add_child(slot)
	var npc_scene: PackedScene = load("res://scenes/entities/npcs/VillagerR3.tscn") as PackedScene
	if npc_scene == null:
		return
	var npc: Node3D = npc_scene.instantiate() as Node3D
	npc.name = "CocoaVendor"
	if "npc_name" in npc:
		npc.set("npc_name", "Mocha")
	if "npc_id" in npc:
		npc.set("npc_id", "cocoa_vendor_d5")
	slot.add_child(npc)
	# Apron (white/cream rectangle on chest)
	var apron: MeshInstance3D = MeshInstance3D.new()
	var am: BoxMesh = BoxMesh.new()
	am.size = Vector3(0.55, 0.85, 0.06)
	apron.mesh = am
	var apron_mat: StandardMaterial3D = StandardMaterial3D.new()
	apron_mat.albedo_color = Color(0.95, 0.92, 0.85)
	apron_mat.roughness = 0.85
	apron.material_override = apron_mat
	apron.position = Vector3(0, 0.55, 0.22)
	npc.add_child(apron)
	# Chef hat (white tall cylinder + sphere top)
	var hat: MeshInstance3D = MeshInstance3D.new()
	var hm: CylinderMesh = CylinderMesh.new()
	hm.top_radius = 0.22
	hm.bottom_radius = 0.20
	hm.height = 0.30
	hat.mesh = hm
	hat.material_override = apron_mat
	hat.position = Vector3(0, 1.55, 0)
	npc.add_child(hat)
	var puff: MeshInstance3D = MeshInstance3D.new()
	var pmm: SphereMesh = SphereMesh.new()
	pmm.radius = 0.28
	pmm.height = 0.40
	puff.mesh = pmm
	puff.material_override = apron_mat
	puff.position = Vector3(0, 1.85, 0)
	puff.scale = Vector3(1.0, 0.65, 1.0)
	npc.add_child(puff)
	# Mug in hand (small cylinder)
	var mug: MeshInstance3D = MeshInstance3D.new()
	var mm: CylinderMesh = CylinderMesh.new()
	mm.top_radius = 0.08
	mm.bottom_radius = 0.08
	mm.height = 0.16
	mug.mesh = mm
	var mug_mat: StandardMaterial3D = StandardMaterial3D.new()
	mug_mat.albedo_color = Color(0.85, 0.85, 0.80)
	mug.material_override = mug_mat
	mug.position = Vector3(0.40, 0.85, 0.18)
	npc.add_child(mug)


func _build_d5_cryo_prison(geom: Node) -> void:
	## Epic-5 T46: cryo prison cell — single tall reinforced ice cylinder
	## with steel bars containing a captured red glitch creature inside.
	var prison: Node3D = Node3D.new()
	prison.name = "CryoPrison"
	prison.position = Vector3(D5_CENTER.x + 16.0, 0.0, -2.0)
	geom.add_child(prison)
	# Stone base
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.40, 0.45, 0.50)
	stone_mat.roughness = 0.92
	var base: MeshInstance3D = MeshInstance3D.new()
	var bm: CylinderMesh = CylinderMesh.new()
	bm.top_radius = 1.10
	bm.bottom_radius = 1.30
	bm.height = 0.45
	base.mesh = bm
	base.material_override = stone_mat
	base.position = Vector3(0, 0.22, 0)
	prison.add_child(base)
	# Ice cylinder containment chamber
	var ice_mat: StandardMaterial3D = StandardMaterial3D.new()
	ice_mat.albedo_color = Color(0.55, 0.85, 0.95, 0.60)
	ice_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	ice_mat.emission_enabled = true
	ice_mat.emission = Color(0.40, 0.85, 0.95)
	ice_mat.emission_energy_multiplier = 0.85
	ice_mat.metallic = 0.55
	ice_mat.roughness = 0.10
	var chamber: MeshInstance3D = MeshInstance3D.new()
	var cm: CylinderMesh = CylinderMesh.new()
	cm.top_radius = 0.85
	cm.bottom_radius = 0.85
	cm.height = 3.40
	chamber.mesh = cm
	chamber.material_override = ice_mat
	chamber.position = Vector3(0, 2.15, 0)
	prison.add_child(chamber)
	# 8 vertical steel bars around the chamber
	var steel_mat: StandardMaterial3D = StandardMaterial3D.new()
	steel_mat.albedo_color = Color(0.30, 0.35, 0.40)
	steel_mat.metallic = 0.85
	steel_mat.roughness = 0.30
	for i in 8:
		var ang: float = (TAU / 8.0) * i
		var bar: MeshInstance3D = MeshInstance3D.new()
		var brm: CylinderMesh = CylinderMesh.new()
		brm.top_radius = 0.04
		brm.bottom_radius = 0.04
		brm.height = 3.40
		bar.mesh = brm
		bar.material_override = steel_mat
		bar.position = Vector3(cos(ang) * 0.95, 2.15, sin(ang) * 0.95)
		prison.add_child(bar)
	# Top metal cap
	var cap: MeshInstance3D = MeshInstance3D.new()
	var capm: CylinderMesh = CylinderMesh.new()
	capm.top_radius = 1.05
	capm.bottom_radius = 1.05
	capm.height = 0.30
	cap.mesh = capm
	cap.material_override = steel_mat
	cap.position = Vector3(0, 4.00, 0)
	prison.add_child(cap)
	# Captured glitch creature inside (red angry blob with twitching eye)
	var glitch_mat: StandardMaterial3D = StandardMaterial3D.new()
	glitch_mat.albedo_color = Color(0.95, 0.20, 0.20)
	glitch_mat.emission_enabled = true
	glitch_mat.emission = Color(0.95, 0.10, 0.10)
	glitch_mat.emission_energy_multiplier = 1.6
	glitch_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var glitch: MeshInstance3D = MeshInstance3D.new()
	var gm: SphereMesh = SphereMesh.new()
	gm.radius = 0.45
	gm.height = 0.85
	glitch.mesh = gm
	glitch.material_override = glitch_mat
	glitch.position = Vector3(0, 1.85, 0)
	prison.add_child(glitch)
	# Eye
	var eye: MeshInstance3D = MeshInstance3D.new()
	var em: SphereMesh = SphereMesh.new()
	em.radius = 0.10
	em.height = 0.18
	eye.mesh = em
	var eye_mat: StandardMaterial3D = StandardMaterial3D.new()
	eye_mat.albedo_color = Color(1.0, 1.0, 0.30)
	eye_mat.emission_enabled = true
	eye_mat.emission = Color(1.0, 1.0, 0.30)
	eye_mat.emission_energy_multiplier = 4.0
	eye_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	eye.material_override = eye_mat
	eye.position = Vector3(0, 1.92, 0.40)
	prison.add_child(eye)
	# Glitch pulse + jitter
	var tw: Tween = glitch.create_tween().set_loops()
	tw.tween_property(glitch, "scale", Vector3(1.20, 0.85, 1.20), 0.30)
	tw.tween_property(glitch, "scale", Vector3(0.85, 1.20, 0.85), 0.30)
	# Sign at base
	var label: Label3D = Label3D.new()
	label.text = "CONTAINMENT\nUNIT 0xDEADBEEF"
	label.modulate = Color(0.95, 0.85, 0.30)
	label.outline_modulate = Color(0.20, 0.10, 0.05)
	label.outline_size = 4
	label.font_size = 36
	label.pixel_size = 0.0045
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.position = Vector3(0, 0.85, 1.20)
	prison.add_child(label)
	# Base collision
	var sb: StaticBody3D = StaticBody3D.new()
	sb.position = Vector3(0, 2.10, 0)
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cyl: CylinderShape3D = CylinderShape3D.new()
	cyl.radius = 1.10
	cyl.height = 4.20
	cs.shape = cyl
	sb.add_child(cs)
	prison.add_child(sb)


func _build_d5_yeti_silhouette(geom: Node) -> void:
	## Epic-5 T47: large dark yeti silhouette on the far horizon — pure
	## flat dark unshaded material so it reads like a distant shape against
	## the snow. Visual storytelling: something hunts beyond the cache.
	var yeti: Node3D = Node3D.new()
	yeti.name = "YetiSilhouette"
	yeti.position = Vector3(D5_CENTER.x + 28.0, 0.0, -22.0)
	geom.add_child(yeti)
	var dark_mat: StandardMaterial3D = StandardMaterial3D.new()
	dark_mat.albedo_color = Color(0.10, 0.12, 0.15)
	dark_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	# Body (large box)
	var body: MeshInstance3D = MeshInstance3D.new()
	var bm: BoxMesh = BoxMesh.new()
	bm.size = Vector3(2.40, 4.20, 1.40)
	body.mesh = bm
	body.material_override = dark_mat
	body.position = Vector3(0, 2.50, 0)
	yeti.add_child(body)
	# Head
	var head: MeshInstance3D = MeshInstance3D.new()
	var hm: SphereMesh = SphereMesh.new()
	hm.radius = 0.85
	hm.height = 1.40
	head.mesh = hm
	head.material_override = dark_mat
	head.position = Vector3(0, 5.20, 0)
	yeti.add_child(head)
	# 2 huge arms (long boxes)
	for sx in [-1.85, 1.85]:
		var arm: MeshInstance3D = MeshInstance3D.new()
		var am: BoxMesh = BoxMesh.new()
		am.size = Vector3(0.85, 3.40, 0.85)
		arm.mesh = am
		arm.material_override = dark_mat
		arm.position = Vector3(sx, 2.50, 0)
		yeti.add_child(arm)
	# 2 glowing red eyes (the only color visible at distance)
	var eye_mat: StandardMaterial3D = StandardMaterial3D.new()
	eye_mat.albedo_color = Color(1.0, 0.20, 0.20)
	eye_mat.emission_enabled = true
	eye_mat.emission = Color(1.0, 0.10, 0.10)
	eye_mat.emission_energy_multiplier = 4.5
	eye_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for ex in [-0.30, 0.30]:
		var eye: MeshInstance3D = MeshInstance3D.new()
		var em: SphereMesh = SphereMesh.new()
		em.radius = 0.10
		em.height = 0.20
		eye.mesh = em
		eye.material_override = eye_mat
		eye.position = Vector3(ex, 5.40, 0.85)
		yeti.add_child(eye)
		# Slow blink (scale flicker)
		var tw: Tween = eye.create_tween().set_loops()
		tw.tween_interval(2.0 + randf() * 1.5)
		tw.tween_property(eye, "scale:y", 0.10, 0.10)
		tw.tween_property(eye, "scale:y", 1.0, 0.10)
	# Subtle sway in place to suggest breathing
	var ts: Tween = yeti.create_tween().set_loops()
	ts.tween_property(yeti, "rotation_degrees:y", 4.0, 3.0)
	ts.tween_property(yeti, "rotation_degrees:y", -4.0, 3.0)


func _build_d5_explorer_npc(town: Node) -> void:
	## Epic-5 T48: arctic explorer NPC carrying a tall pickaxe and wearing
	## a backpack and snow-goggles.
	var npc_slots: Node3D = town.get_node_or_null("%NPCSlots") as Node3D
	if npc_slots == null:
		return
	var slot: Marker3D = Marker3D.new()
	slot.name = "ExplorerSlot"
	slot.position = Vector3(D5_CENTER.x + 14.0, 0.0, 4.0)
	npc_slots.add_child(slot)
	var npc_scene: PackedScene = load("res://scenes/entities/npcs/VillagerR3.tscn") as PackedScene
	if npc_scene == null:
		return
	var npc: Node3D = npc_scene.instantiate() as Node3D
	npc.name = "Explorer"
	if "npc_name" in npc:
		npc.set("npc_name", "Tundratrek")
	if "npc_id" in npc:
		npc.set("npc_id", "explorer_d5")
	slot.add_child(npc)
	# Snowsuit (orange)
	var suit: MeshInstance3D = MeshInstance3D.new()
	var sm: BoxMesh = BoxMesh.new()
	sm.size = Vector3(0.75, 1.10, 0.50)
	suit.mesh = sm
	var suit_mat: StandardMaterial3D = StandardMaterial3D.new()
	suit_mat.albedo_color = Color(0.95, 0.55, 0.20)
	suit_mat.roughness = 0.85
	suit.material_override = suit_mat
	suit.position = Vector3(0, 0.55, 0)
	npc.add_child(suit)
	# Backpack
	var pack: MeshInstance3D = MeshInstance3D.new()
	var pm: BoxMesh = BoxMesh.new()
	pm.size = Vector3(0.55, 0.85, 0.30)
	pack.mesh = pm
	var pack_mat: StandardMaterial3D = StandardMaterial3D.new()
	pack_mat.albedo_color = Color(0.30, 0.35, 0.40)
	pack_mat.roughness = 0.85
	pack.material_override = pack_mat
	pack.position = Vector3(0, 0.65, -0.32)
	npc.add_child(pack)
	# Bedroll on backpack
	var roll: MeshInstance3D = MeshInstance3D.new()
	var rm: CylinderMesh = CylinderMesh.new()
	rm.top_radius = 0.10
	rm.bottom_radius = 0.10
	rm.height = 0.55
	roll.mesh = rm
	var roll_mat: StandardMaterial3D = StandardMaterial3D.new()
	roll_mat.albedo_color = Color(0.85, 0.65, 0.30)
	roll_mat.roughness = 0.85
	roll.material_override = roll_mat
	roll.position = Vector3(0, 1.10, -0.40)
	roll.rotation_degrees = Vector3(0, 0, 90)
	npc.add_child(roll)
	# Snow goggles strip
	var goggles: MeshInstance3D = MeshInstance3D.new()
	var gmm: BoxMesh = BoxMesh.new()
	gmm.size = Vector3(0.42, 0.10, 0.06)
	goggles.mesh = gmm
	var gog_mat: StandardMaterial3D = StandardMaterial3D.new()
	gog_mat.albedo_color = Color(0.30, 0.45, 0.95, 0.85)
	gog_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	gog_mat.emission_enabled = true
	gog_mat.emission = Color(0.30, 0.55, 0.95)
	gog_mat.emission_energy_multiplier = 1.4
	gog_mat.metallic = 0.55
	gog_mat.roughness = 0.20
	goggles.material_override = gog_mat
	goggles.position = Vector3(0, 1.42, 0.21)
	npc.add_child(goggles)
	# Pickaxe (handle + head)
	var wood_mat: StandardMaterial3D = StandardMaterial3D.new()
	wood_mat.albedo_color = Color(0.45, 0.28, 0.12)
	wood_mat.roughness = 0.85
	var handle: MeshInstance3D = MeshInstance3D.new()
	var hmm: CylinderMesh = CylinderMesh.new()
	hmm.top_radius = 0.04
	hmm.bottom_radius = 0.05
	hmm.height = 1.65
	handle.mesh = hmm
	handle.material_override = wood_mat
	handle.position = Vector3(0.45, 0.85, 0)
	npc.add_child(handle)
	var head: MeshInstance3D = MeshInstance3D.new()
	var hm2: PrismMesh = PrismMesh.new()
	hm2.size = Vector3(0.10, 0.10, 0.55)
	head.mesh = hm2
	var steel_mat: StandardMaterial3D = StandardMaterial3D.new()
	steel_mat.albedo_color = Color(0.50, 0.55, 0.60)
	steel_mat.metallic = 0.85
	steel_mat.roughness = 0.30
	head.material_override = steel_mat
	head.position = Vector3(0.45, 1.65, 0)
	head.rotation_degrees = Vector3(0, 0, 90)
	npc.add_child(head)


func _build_d5_ice_spike_traps(geom: Node) -> void:
	## Epic-5 T49: ice spike trap field — 12 sharp upward-pointing ice
	## spikes scattered in a hostile area, with a cyan glow base.
	var field: Node3D = Node3D.new()
	field.name = "IceSpikeTraps"
	field.position = Vector3(D5_CENTER.x + 22.0, 0.0, -10.0)
	geom.add_child(field)
	var ice_mat: StandardMaterial3D = StandardMaterial3D.new()
	ice_mat.albedo_color = Color(0.65, 0.85, 0.95, 0.92)
	ice_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	ice_mat.emission_enabled = true
	ice_mat.emission = Color(0.40, 0.85, 0.95)
	ice_mat.emission_energy_multiplier = 0.85
	ice_mat.metallic = 0.55
	ice_mat.roughness = 0.10
	var sharp_mat: StandardMaterial3D = StandardMaterial3D.new()
	sharp_mat.albedo_color = Color(0.85, 0.95, 1.0)
	sharp_mat.emission_enabled = true
	sharp_mat.emission = Color(0.65, 0.95, 1.0)
	sharp_mat.emission_energy_multiplier = 1.6
	sharp_mat.metallic = 0.55
	sharp_mat.roughness = 0.20
	for i in 12:
		var spike: Node3D = Node3D.new()
		spike.position = Vector3(
			randf_range(-3.5, 3.5),
			0.0,
			randf_range(-2.5, 2.5)
		)
		field.add_child(spike)
		# Base ice crystal
		var base: MeshInstance3D = MeshInstance3D.new()
		var bm: PrismMesh = PrismMesh.new()
		bm.size = Vector3(0.30, 0.40, 0.30)
		base.mesh = bm
		base.material_override = ice_mat
		base.position = Vector3(0, 0.20, 0)
		spike.add_child(base)
		# Sharp tall spike
		var s: MeshInstance3D = MeshInstance3D.new()
		var sm: PrismMesh = PrismMesh.new()
		sm.size = Vector3(0.20, 1.40 + randf() * 0.55, 0.20)
		s.mesh = sm
		s.material_override = sharp_mat
		s.position = Vector3(0, 1.05 + sm.size.y * 0.5 - 0.65, 0)
		spike.add_child(s)
		# Spike collision (capsule)
		var sb: StaticBody3D = StaticBody3D.new()
		sb.position = Vector3(0, 0.85, 0)
		var cs: CollisionShape3D = CollisionShape3D.new()
		var cap: CapsuleShape3D = CapsuleShape3D.new()
		cap.radius = 0.18
		cap.height = 1.85
		cs.shape = cap
		sb.add_child(cs)
		spike.add_child(sb)
	# Warning glow at field center
	var light: OmniLight3D = OmniLight3D.new()
	light.light_color = Color(0.95, 0.20, 0.20)
	light.light_energy = 1.4
	light.omni_range = 6.0
	light.position = Vector3(0, 1.85, 0)
	field.add_child(light)
	# Pulse warning
	var tw: Tween = light.create_tween().set_loops()
	tw.tween_property(light, "light_energy", 2.4, 0.55)
	tw.tween_property(light, "light_energy", 1.4, 0.55)


func _build_d5_glacial_warden(geom: Node) -> void:
	## Epic-5 T50: GLACIAL WARDEN — D5 mid-boss landmark. Tall ice knight
	## with a massive frost greatsword, tower shield, and a billboard label.
	var warden: Node3D = Node3D.new()
	warden.name = "GlacialWarden"
	warden.position = Vector3(D5_CENTER.x + 4.0, 0.0, -12.0)
	geom.add_child(warden)
	var ice_mat: StandardMaterial3D = StandardMaterial3D.new()
	ice_mat.albedo_color = Color(0.65, 0.85, 0.95)
	ice_mat.emission_enabled = true
	ice_mat.emission = Color(0.40, 0.80, 0.95)
	ice_mat.emission_energy_multiplier = 0.45
	ice_mat.metallic = 0.65
	ice_mat.roughness = 0.20
	var rune_mat: StandardMaterial3D = StandardMaterial3D.new()
	rune_mat.albedo_color = Color(0.30, 1.0, 1.0)
	rune_mat.emission_enabled = true
	rune_mat.emission = Color(0.30, 1.0, 1.0)
	rune_mat.emission_energy_multiplier = 3.5
	rune_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	# Stone pedestal
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.45, 0.50, 0.55)
	stone_mat.roughness = 0.92
	var ped: MeshInstance3D = MeshInstance3D.new()
	var pm: BoxMesh = BoxMesh.new()
	pm.size = Vector3(3.20, 0.55, 3.20)
	ped.mesh = pm
	ped.material_override = stone_mat
	ped.position = Vector3(0, 0.27, 0)
	warden.add_child(ped)
	# Body — massive ice torso
	var torso: MeshInstance3D = MeshInstance3D.new()
	var tm: BoxMesh = BoxMesh.new()
	tm.size = Vector3(1.65, 2.40, 1.10)
	torso.mesh = tm
	torso.material_override = ice_mat
	torso.position = Vector3(0, 1.95, 0)
	warden.add_child(torso)
	# Head — armored helm
	var helm: MeshInstance3D = MeshInstance3D.new()
	var hm: BoxMesh = BoxMesh.new()
	hm.size = Vector3(0.95, 0.85, 0.85)
	helm.mesh = hm
	helm.material_override = ice_mat
	helm.position = Vector3(0, 3.55, 0)
	warden.add_child(helm)
	# Glowing eye visor (cyan slit)
	var visor: MeshInstance3D = MeshInstance3D.new()
	var vm: BoxMesh = BoxMesh.new()
	vm.size = Vector3(0.65, 0.10, 0.04)
	visor.mesh = vm
	visor.material_override = rune_mat
	visor.position = Vector3(0, 3.65, 0.42)
	warden.add_child(visor)
	# Crown spikes on helm (3)
	for i in 3:
		var spike: MeshInstance3D = MeshInstance3D.new()
		var spm: PrismMesh = PrismMesh.new()
		spm.size = Vector3(0.18, 0.40, 0.18)
		spike.mesh = spm
		spike.material_override = ice_mat
		spike.position = Vector3(-0.30 + i * 0.30, 4.10, 0)
		warden.add_child(spike)
	# 2 shoulder pauldrons
	for sx in [-1.20, 1.20]:
		var pauldron: MeshInstance3D = MeshInstance3D.new()
		var prm: SphereMesh = SphereMesh.new()
		prm.radius = 0.55
		prm.height = 0.85
		pauldron.mesh = prm
		pauldron.material_override = ice_mat
		pauldron.position = Vector3(sx, 2.95, 0)
		pauldron.scale = Vector3(0.85, 0.65, 0.85)
		warden.add_child(pauldron)
	# Right arm (holding the sword)
	var right_arm: MeshInstance3D = MeshInstance3D.new()
	var ram: BoxMesh = BoxMesh.new()
	ram.size = Vector3(0.55, 1.85, 0.55)
	right_arm.mesh = ram
	right_arm.material_override = ice_mat
	right_arm.position = Vector3(1.30, 1.95, 0)
	warden.add_child(right_arm)
	# Left arm (holding the shield)
	var left_arm: MeshInstance3D = MeshInstance3D.new()
	var lam: BoxMesh = BoxMesh.new()
	lam.size = Vector3(0.55, 1.85, 0.55)
	left_arm.mesh = lam
	left_arm.material_override = ice_mat
	left_arm.position = Vector3(-1.30, 1.95, 0)
	warden.add_child(left_arm)
	# 2 legs
	for sx in [-0.45, 0.45]:
		var leg: MeshInstance3D = MeshInstance3D.new()
		var lgm: BoxMesh = BoxMesh.new()
		lgm.size = Vector3(0.55, 0.95, 0.55)
		leg.mesh = lgm
		leg.material_override = ice_mat
		leg.position = Vector3(sx, 1.05, 0)
		warden.add_child(leg)
	# Massive frost greatsword (long blade + crossguard + handle)
	var sword_root: Node3D = Node3D.new()
	sword_root.position = Vector3(1.85, 2.85, 0)
	sword_root.rotation_degrees = Vector3(0, 0, -25)
	warden.add_child(sword_root)
	var blade: MeshInstance3D = MeshInstance3D.new()
	var blm: PrismMesh = PrismMesh.new()
	blm.size = Vector3(0.35, 3.20, 0.10)
	blade.mesh = blm
	blade.material_override = ice_mat
	blade.position = Vector3(0, 1.60, 0)
	sword_root.add_child(blade)
	# Glowing rune line down the blade
	var rune: MeshInstance3D = MeshInstance3D.new()
	var rmm: BoxMesh = BoxMesh.new()
	rmm.size = Vector3(0.06, 2.85, 0.04)
	rune.mesh = rmm
	rune.material_override = rune_mat
	rune.position = Vector3(0, 1.60, 0.07)
	sword_root.add_child(rune)
	# Crossguard
	var guard: MeshInstance3D = MeshInstance3D.new()
	var gm2: BoxMesh = BoxMesh.new()
	gm2.size = Vector3(0.85, 0.18, 0.20)
	guard.mesh = gm2
	guard.material_override = ice_mat
	guard.position = Vector3(0, 0.0, 0)
	sword_root.add_child(guard)
	# Handle (wrapped in dark leather)
	var handle: MeshInstance3D = MeshInstance3D.new()
	var hndm: CylinderMesh = CylinderMesh.new()
	hndm.top_radius = 0.08
	hndm.bottom_radius = 0.08
	hndm.height = 0.55
	handle.mesh = hndm
	var leather_mat: StandardMaterial3D = StandardMaterial3D.new()
	leather_mat.albedo_color = Color(0.20, 0.18, 0.15)
	leather_mat.roughness = 0.85
	handle.material_override = leather_mat
	handle.position = Vector3(0, -0.40, 0)
	sword_root.add_child(handle)
	# Pommel
	var pommel: MeshInstance3D = MeshInstance3D.new()
	var pmm2: SphereMesh = SphereMesh.new()
	pmm2.radius = 0.14
	pmm2.height = 0.24
	pommel.mesh = pmm2
	pommel.material_override = rune_mat
	pommel.position = Vector3(0, -0.75, 0)
	sword_root.add_child(pommel)
	# Tower shield (large box on left arm)
	var shield: Node3D = Node3D.new()
	shield.position = Vector3(-1.85, 1.95, 0.65)
	warden.add_child(shield)
	var shield_face: MeshInstance3D = MeshInstance3D.new()
	var shfm: BoxMesh = BoxMesh.new()
	shfm.size = Vector3(1.30, 2.20, 0.20)
	shield_face.mesh = shfm
	shield_face.material_override = ice_mat
	shield.add_child(shield_face)
	# Shield rune emblem (cyan diamond)
	var emblem: MeshInstance3D = MeshInstance3D.new()
	var elm: PrismMesh = PrismMesh.new()
	elm.size = Vector3(0.55, 0.85, 0.06)
	emblem.mesh = elm
	emblem.material_override = rune_mat
	emblem.position = Vector3(0, 0, 0.13)
	shield.add_child(emblem)
	# Big aura light
	var light: OmniLight3D = OmniLight3D.new()
	light.light_color = Color(0.40, 0.85, 1.0)
	light.light_energy = 4.5
	light.omni_range = 14.0
	light.position = Vector3(0, 3.40, 0)
	warden.add_child(light)
	# Light pulse
	var tw: Tween = light.create_tween().set_loops()
	tw.tween_property(light, "light_energy", 5.5, 1.8)
	tw.tween_property(light, "light_energy", 4.0, 1.8)
	# Title labels
	var title: Label3D = Label3D.new()
	title.text = "THE GLACIAL WARDEN"
	title.modulate = Color(0.40, 0.95, 1.0)
	title.outline_modulate = Color(0.05, 0.20, 0.30)
	title.outline_size = 12
	title.font_size = 80
	title.pixel_size = 0.013
	title.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	title.position = Vector3(0, 5.80, 0)
	warden.add_child(title)
	var subtitle: Label3D = Label3D.new()
	subtitle.text = "Sworn keeper of frozen memory"
	subtitle.modulate = Color(0.85, 0.95, 1.0)
	subtitle.outline_modulate = Color(0.10, 0.20, 0.30)
	subtitle.outline_size = 8
	subtitle.font_size = 42
	subtitle.pixel_size = 0.010
	subtitle.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	subtitle.position = Vector3(0, 5.10, 0)
	warden.add_child(subtitle)
	# Body collision
	var sb: StaticBody3D = StaticBody3D.new()
	sb.position = Vector3(0, 1.95, 0)
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(2.40, 4.20, 1.40)
	cs.shape = cb
	sb.add_child(cs)
	warden.add_child(sb)
	# Pedestal collision
	var psb: StaticBody3D = StaticBody3D.new()
	psb.position = Vector3(0, 0.27, 0)
	var pcs: CollisionShape3D = CollisionShape3D.new()
	var pcb: BoxShape3D = BoxShape3D.new()
	pcb.size = Vector3(3.20, 0.55, 3.20)
	pcs.shape = pcb
	psb.add_child(pcs)
	warden.add_child(psb)


func _build_d5_telescope_observatory(geom: Node) -> void:
	## Epic-5 T51: small observatory — round ice base + half-dome ice top
	## with an open slit + protruding telescope barrel.
	var obs: Node3D = Node3D.new()
	obs.name = "TelescopeObservatory"
	obs.position = Vector3(D5_CENTER.x + 18.0, 0.0, -2.0)
	geom.add_child(obs)
	var ice_mat: StandardMaterial3D = StandardMaterial3D.new()
	ice_mat.albedo_color = Color(0.78, 0.92, 1.0)
	ice_mat.emission_enabled = true
	ice_mat.emission = Color(0.55, 0.85, 1.0)
	ice_mat.emission_energy_multiplier = 0.30
	ice_mat.roughness = 0.45
	# Round base wall
	var base: MeshInstance3D = MeshInstance3D.new()
	var bm: CylinderMesh = CylinderMesh.new()
	bm.top_radius = 1.85
	bm.bottom_radius = 2.10
	bm.height = 2.40
	base.mesh = bm
	base.material_override = ice_mat
	base.position = Vector3(0, 1.20, 0)
	obs.add_child(base)
	# Dome roof (half sphere)
	var dome: MeshInstance3D = MeshInstance3D.new()
	var dmm: SphereMesh = SphereMesh.new()
	dmm.radius = 2.00
	dmm.height = 4.00
	dome.mesh = dmm
	dome.material_override = ice_mat
	dome.position = Vector3(0, 2.40, 0)
	dome.scale = Vector3(1.0, 0.55, 1.0)
	obs.add_child(dome)
	# Open slit (dark thin box on the dome)
	var slit: MeshInstance3D = MeshInstance3D.new()
	var sltm: BoxMesh = BoxMesh.new()
	sltm.size = Vector3(0.45, 0.10, 1.85)
	slit.mesh = sltm
	var dark_mat: StandardMaterial3D = StandardMaterial3D.new()
	dark_mat.albedo_color = Color(0.05, 0.08, 0.12)
	dark_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	slit.material_override = dark_mat
	slit.position = Vector3(0, 3.40, 0)
	obs.add_child(slit)
	# Protruding telescope barrel (long cylinder angled outward)
	var metal_mat: StandardMaterial3D = StandardMaterial3D.new()
	metal_mat.albedo_color = Color(0.30, 0.35, 0.40)
	metal_mat.metallic = 0.85
	metal_mat.roughness = 0.30
	var scope: MeshInstance3D = MeshInstance3D.new()
	var sm: CylinderMesh = CylinderMesh.new()
	sm.top_radius = 0.30
	sm.bottom_radius = 0.40
	sm.height = 2.85
	scope.mesh = sm
	scope.material_override = metal_mat
	scope.position = Vector3(0, 3.20, 0.55)
	scope.rotation_degrees = Vector3(-25, 0, 0)
	obs.add_child(scope)
	# Lens (cyan emissive disc on the front of the scope)
	var lens: MeshInstance3D = MeshInstance3D.new()
	var lm: CylinderMesh = CylinderMesh.new()
	lm.top_radius = 0.32
	lm.bottom_radius = 0.32
	lm.height = 0.04
	lens.mesh = lm
	var lens_mat: StandardMaterial3D = StandardMaterial3D.new()
	lens_mat.albedo_color = Color(0.40, 0.95, 1.0)
	lens_mat.emission_enabled = true
	lens_mat.emission = Color(0.40, 1.0, 1.0)
	lens_mat.emission_energy_multiplier = 2.5
	lens_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	lens.material_override = lens_mat
	lens.position = Vector3(0, 4.40, 1.85)
	lens.rotation_degrees = Vector3(-25, 0, 0)
	obs.add_child(lens)
	# Door slit at base
	var door: MeshInstance3D = MeshInstance3D.new()
	var dom: BoxMesh = BoxMesh.new()
	dom.size = Vector3(0.85, 1.65, 0.10)
	door.mesh = dom
	var door_mat: StandardMaterial3D = StandardMaterial3D.new()
	door_mat.albedo_color = Color(0.30, 0.35, 0.40)
	door_mat.metallic = 0.65
	door_mat.roughness = 0.35
	door.material_override = door_mat
	door.position = Vector3(0, 0.85, 2.10)
	obs.add_child(door)
	# Base collision
	var sb: StaticBody3D = StaticBody3D.new()
	sb.position = Vector3(0, 1.20, 0)
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cap: CylinderShape3D = CylinderShape3D.new()
	cap.radius = 2.10
	cap.height = 2.40
	cs.shape = cap
	sb.add_child(cs)
	obs.add_child(sb)


func _build_d5_stargazer_npc(town: Node) -> void:
	## Epic-5 T52: stargazer NPC standing outside the observatory with a
	## small handheld star chart.
	var npc_slots: Node3D = town.get_node_or_null("%NPCSlots") as Node3D
	if npc_slots == null:
		return
	var slot: Marker3D = Marker3D.new()
	slot.name = "StargazerSlot"
	slot.position = Vector3(D5_CENTER.x + 20.0, 0.0, -2.0)
	npc_slots.add_child(slot)
	var npc_scene: PackedScene = load("res://scenes/entities/npcs/VillagerR3.tscn") as PackedScene
	if npc_scene == null:
		return
	var npc: Node3D = npc_scene.instantiate() as Node3D
	npc.name = "Stargazer"
	if "npc_name" in npc:
		npc.set("npc_name", "Polaris")
	if "npc_id" in npc:
		npc.set("npc_id", "stargazer_d5")
	slot.add_child(npc)
	# Dark blue robe
	var robe: MeshInstance3D = MeshInstance3D.new()
	var rm: BoxMesh = BoxMesh.new()
	rm.size = Vector3(0.65, 1.05, 0.45)
	robe.mesh = rm
	var robe_mat: StandardMaterial3D = StandardMaterial3D.new()
	robe_mat.albedo_color = Color(0.10, 0.18, 0.45)
	robe_mat.emission_enabled = true
	robe_mat.emission = Color(0.10, 0.18, 0.55)
	robe_mat.emission_energy_multiplier = 0.30
	robe_mat.roughness = 0.65
	robe.material_override = robe_mat
	robe.position = Vector3(0, 0.55, 0)
	npc.add_child(robe)
	# Tall pointed wizard hat
	var hat: MeshInstance3D = MeshInstance3D.new()
	var hm: PrismMesh = PrismMesh.new()
	hm.size = Vector3(0.40, 0.85, 0.40)
	hat.mesh = hm
	hat.material_override = robe_mat
	hat.position = Vector3(0, 1.65, 0)
	npc.add_child(hat)
	# Tiny stars sprinkled on the hat (4 small emissive spheres)
	var star_mat: StandardMaterial3D = StandardMaterial3D.new()
	star_mat.albedo_color = Color(1.0, 1.0, 0.85)
	star_mat.emission_enabled = true
	star_mat.emission = Color(1.0, 1.0, 0.85)
	star_mat.emission_energy_multiplier = 3.5
	star_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for i in 4:
		var star: MeshInstance3D = MeshInstance3D.new()
		var smm: SphereMesh = SphereMesh.new()
		smm.radius = 0.03
		smm.height = 0.06
		star.mesh = smm
		star.material_override = star_mat
		var ang: float = (TAU / 4.0) * i
		star.position = Vector3(cos(ang) * 0.12, 1.55 + i * 0.18, sin(ang) * 0.12)
		npc.add_child(star)
	# Star chart held in hand (small open scroll prism)
	var chart: MeshInstance3D = MeshInstance3D.new()
	var cmm: BoxMesh = BoxMesh.new()
	cmm.size = Vector3(0.40, 0.30, 0.04)
	chart.mesh = cmm
	var chart_mat: StandardMaterial3D = StandardMaterial3D.new()
	chart_mat.albedo_color = Color(0.95, 0.92, 0.75)
	chart_mat.emission_enabled = true
	chart_mat.emission = Color(0.55, 0.65, 0.85)
	chart_mat.emission_energy_multiplier = 0.45
	chart.material_override = chart_mat
	chart.position = Vector3(0.40, 0.85, 0.20)
	chart.rotation_degrees = Vector3(-30, 0, 0)
	npc.add_child(chart)


func _build_d5_comet_streaks(geom: Node) -> void:
	## Epic-5 T53: 3 comet streaks across the high sky — long emissive
	## tails that drift slowly across the district overhead.
	var comets: Node3D = Node3D.new()
	comets.name = "CometStreaks"
	comets.position = Vector3(D5_CENTER.x, 22.0, 0.0)
	geom.add_child(comets)
	var streak_colors: Array = [
		Color(1.0, 0.85, 0.65),
		Color(0.85, 0.95, 1.0),
		Color(1.0, 0.65, 0.85),
	]
	for i in 3:
		var comet: Node3D = Node3D.new()
		comet.position = Vector3(-25.0, i * 1.85, -8.0 + i * 4.0)
		comet.rotation_degrees = Vector3(0, 0, -8.0 + i * 5.0)
		comets.add_child(comet)
		# Head (bright sphere)
		var head: MeshInstance3D = MeshInstance3D.new()
		var hm: SphereMesh = SphereMesh.new()
		hm.radius = 0.40
		hm.height = 0.75
		head.mesh = hm
		var head_mat: StandardMaterial3D = StandardMaterial3D.new()
		head_mat.albedo_color = streak_colors[i]
		head_mat.emission_enabled = true
		head_mat.emission = streak_colors[i]
		head_mat.emission_energy_multiplier = 4.0
		head_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		head.material_override = head_mat
		comet.add_child(head)
		# Tail (long thin box trailing behind)
		var tail: MeshInstance3D = MeshInstance3D.new()
		var tm: BoxMesh = BoxMesh.new()
		tm.size = Vector3(8.0, 0.20, 0.20)
		tail.mesh = tm
		var tail_mat: StandardMaterial3D = StandardMaterial3D.new()
		tail_mat.albedo_color = Color(streak_colors[i].r, streak_colors[i].g, streak_colors[i].b, 0.65)
		tail_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		tail_mat.emission_enabled = true
		tail_mat.emission = streak_colors[i]
		tail_mat.emission_energy_multiplier = 2.0
		tail_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		tail.material_override = tail_mat
		tail.position = Vector3(-4.0, 0, 0)
		comet.add_child(tail)
		# Drift across the sky
		var tw: Tween = comet.create_tween().set_loops()
		tw.tween_property(comet, "position:x", 25.0, 22.0 + i * 2.0)
		tw.tween_property(comet, "position:x", -25.0, 0.0)


func _build_d5_rune_monument(geom: Node) -> void:
	## Epic-5 T54: ancient ice rune monument — pyramidal stack of carved
	## ice blocks with glowing cyan rune symbols on each face.
	var mono: Node3D = Node3D.new()
	mono.name = "IceRuneMonument"
	mono.position = Vector3(D5_CENTER.x - 24.0, 0.0, -10.0)
	geom.add_child(mono)
	var ice_mat: StandardMaterial3D = StandardMaterial3D.new()
	ice_mat.albedo_color = Color(0.65, 0.85, 0.95, 0.92)
	ice_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	ice_mat.emission_enabled = true
	ice_mat.emission = Color(0.40, 0.85, 0.95)
	ice_mat.emission_energy_multiplier = 0.55
	ice_mat.metallic = 0.55
	ice_mat.roughness = 0.20
	var rune_mat: StandardMaterial3D = StandardMaterial3D.new()
	rune_mat.albedo_color = Color(0.30, 1.0, 1.0)
	rune_mat.emission_enabled = true
	rune_mat.emission = Color(0.30, 1.0, 1.0)
	rune_mat.emission_energy_multiplier = 3.5
	rune_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	# 4-tier ice pyramid (each tier smaller and higher)
	var tier_sizes: Array = [
		Vector3(3.20, 0.85, 3.20),
		Vector3(2.40, 0.85, 2.40),
		Vector3(1.65, 0.85, 1.65),
		Vector3(0.95, 0.85, 0.95),
	]
	for i in tier_sizes.size():
		var size: Vector3 = tier_sizes[i]
		var tier: MeshInstance3D = MeshInstance3D.new()
		var tmm: BoxMesh = BoxMesh.new()
		tmm.size = size
		tier.mesh = tmm
		tier.material_override = ice_mat
		tier.position = Vector3(0, 0.42 + i * 0.85, 0)
		mono.add_child(tier)
		# Rune carving on the front face
		var rune: MeshInstance3D = MeshInstance3D.new()
		var rmm: BoxMesh = BoxMesh.new()
		rmm.size = Vector3(size.x * 0.45, size.y * 0.65, 0.04)
		rune.mesh = rmm
		rune.material_override = rune_mat
		rune.position = Vector3(0, 0.42 + i * 0.85, size.z * 0.5 + 0.02)
		mono.add_child(rune)
		# Pulse rune
		var tw: Tween = rune.create_tween().set_loops()
		tw.tween_interval(i * 0.25)
		tw.tween_property(rune, "scale:y", 1.20, 1.2)
		tw.tween_property(rune, "scale:y", 0.85, 1.2)
		# Tier collision
		var sb: StaticBody3D = StaticBody3D.new()
		sb.position = Vector3(0, 0.42 + i * 0.85, 0)
		var cs: CollisionShape3D = CollisionShape3D.new()
		var cb: BoxShape3D = BoxShape3D.new()
		cb.size = size
		cs.shape = cb
		sb.add_child(cs)
		mono.add_child(sb)
	# Topmost crystal capstone
	var capstone: MeshInstance3D = MeshInstance3D.new()
	var capm: PrismMesh = PrismMesh.new()
	capm.size = Vector3(0.55, 0.85, 0.55)
	capstone.mesh = capm
	capstone.material_override = rune_mat
	capstone.position = Vector3(0, 4.30, 0)
	mono.add_child(capstone)
	# Capstone hover + spin
	var ts: Tween = capstone.create_tween().set_loops()
	ts.tween_property(capstone, "rotation_degrees:y", 360.0, 6.0)
	ts.tween_property(capstone, "rotation_degrees:y", 0.0, 0.0)
	var th: Tween = capstone.create_tween().set_loops()
	th.tween_property(capstone, "position:y", 4.50, 1.6)
	th.tween_property(capstone, "position:y", 4.30, 1.6)


func _build_d5_arctic_fox(geom: Node) -> void:
	## Epic-5 T55: small arctic fox creature — pure white fur, dark eye dots,
	## bushy tail, with a hopping idle and slow patrol path.
	var fox: Node3D = Node3D.new()
	fox.name = "ArcticFox"
	fox.position = Vector3(D5_CENTER.x - 8.0, 0.0, -8.0)
	geom.add_child(fox)
	var fur_mat: StandardMaterial3D = StandardMaterial3D.new()
	fur_mat.albedo_color = Color(0.97, 0.98, 1.0)
	fur_mat.roughness = 0.85
	fur_mat.emission_enabled = true
	fur_mat.emission = Color(0.85, 0.92, 0.98)
	fur_mat.emission_energy_multiplier = 0.20
	# Body
	var body: MeshInstance3D = MeshInstance3D.new()
	var bm: SphereMesh = SphereMesh.new()
	bm.radius = 0.22
	bm.height = 0.40
	body.mesh = bm
	body.material_override = fur_mat
	body.position = Vector3(0, 0.30, 0)
	body.scale = Vector3(0.85, 0.75, 1.40)
	fox.add_child(body)
	# Head
	var head: MeshInstance3D = MeshInstance3D.new()
	var hm: SphereMesh = SphereMesh.new()
	hm.radius = 0.16
	hm.height = 0.28
	head.mesh = hm
	head.material_override = fur_mat
	head.position = Vector3(0, 0.42, 0.30)
	fox.add_child(head)
	# Snout (small prism)
	var snout: MeshInstance3D = MeshInstance3D.new()
	var snm: PrismMesh = PrismMesh.new()
	snm.size = Vector3(0.10, 0.08, 0.16)
	snout.mesh = snm
	snout.material_override = fur_mat
	snout.position = Vector3(0, 0.36, 0.45)
	snout.rotation_degrees = Vector3(90, 0, 0)
	fox.add_child(snout)
	# 2 black eye dots
	var eye_mat: StandardMaterial3D = StandardMaterial3D.new()
	eye_mat.albedo_color = Color(0.05, 0.05, 0.08)
	eye_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for ex in [-0.06, 0.06]:
		var eye: MeshInstance3D = MeshInstance3D.new()
		var em: SphereMesh = SphereMesh.new()
		em.radius = 0.025
		em.height = 0.05
		eye.mesh = em
		eye.material_override = eye_mat
		eye.position = Vector3(ex, 0.46, 0.42)
		fox.add_child(eye)
	# 2 perky ears
	for sx in [-0.08, 0.08]:
		var ear: MeshInstance3D = MeshInstance3D.new()
		var em: PrismMesh = PrismMesh.new()
		em.size = Vector3(0.06, 0.12, 0.04)
		ear.mesh = em
		ear.material_override = fur_mat
		ear.position = Vector3(sx, 0.58, 0.30)
		fox.add_child(ear)
	# 4 legs (small cylinders)
	for lx in [-0.08, 0.08]:
		for lz in [-0.18, 0.18]:
			var leg: MeshInstance3D = MeshInstance3D.new()
			var lm: CylinderMesh = CylinderMesh.new()
			lm.top_radius = 0.04
			lm.bottom_radius = 0.04
			lm.height = 0.22
			leg.mesh = lm
			leg.material_override = fur_mat
			leg.position = Vector3(lx, 0.11, lz)
			fox.add_child(leg)
	# Bushy tail (large fluffy sphere)
	var tail: MeshInstance3D = MeshInstance3D.new()
	var tm: SphereMesh = SphereMesh.new()
	tm.radius = 0.18
	tm.height = 0.30
	tail.mesh = tm
	tail.material_override = fur_mat
	tail.position = Vector3(0, 0.32, -0.30)
	tail.scale = Vector3(0.85, 0.85, 1.65)
	fox.add_child(tail)
	# Patrol tween — slow back and forth
	var tw: Tween = fox.create_tween().set_loops()
	tw.tween_property(fox, "position", Vector3(D5_CENTER.x - 6.0, 0, -6.0), 4.0)
	tw.tween_property(fox, "rotation_degrees:y", 180.0, 0.5)
	tw.tween_property(fox, "position", Vector3(D5_CENTER.x - 10.0, 0, -10.0), 4.0)
	tw.tween_property(fox, "rotation_degrees:y", 0.0, 0.5)
	# Hopping bob
	var th: Tween = fox.create_tween().set_loops()
	th.tween_property(fox, "position:y", 0.10, 0.30)
	th.tween_property(fox, "position:y", 0.0, 0.30)
	th.tween_interval(0.85)


func _build_d5_ice_fishing_huts(geom: Node) -> void:
	## Epic-5 T56: 3 small wooden ice fishing huts arranged on a frozen
	## flat — boxy houses with sloped prism roofs and a small chimney each.
	var village: Node3D = Node3D.new()
	village.name = "IceFishingHuts"
	village.position = Vector3(D5_CENTER.x + 14.0, 0.0, 8.0)
	geom.add_child(village)
	var wood_mat: StandardMaterial3D = StandardMaterial3D.new()
	wood_mat.albedo_color = Color(0.45, 0.28, 0.12)
	wood_mat.roughness = 0.85
	var roof_mat: StandardMaterial3D = StandardMaterial3D.new()
	roof_mat.albedo_color = Color(0.30, 0.18, 0.10)
	roof_mat.roughness = 0.85
	var window_mat: StandardMaterial3D = StandardMaterial3D.new()
	window_mat.albedo_color = Color(0.95, 0.85, 0.30)
	window_mat.emission_enabled = true
	window_mat.emission = Color(1.0, 0.85, 0.30)
	window_mat.emission_energy_multiplier = 2.5
	window_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var positions: Array = [
		Vector3(0, 0, 0),
		Vector3(2.85, 0, 1.40),
		Vector3(-2.40, 0, 1.85),
	]
	for i in positions.size():
		var hut: Node3D = Node3D.new()
		hut.position = positions[i]
		hut.rotation_degrees = Vector3(0, randf_range(-25, 25), 0)
		village.add_child(hut)
		# Box body
		var body: MeshInstance3D = MeshInstance3D.new()
		var bm: BoxMesh = BoxMesh.new()
		bm.size = Vector3(1.65, 1.40, 1.40)
		body.mesh = bm
		body.material_override = wood_mat
		body.position = Vector3(0, 0.70, 0)
		hut.add_child(body)
		# Sloped prism roof
		var roof: MeshInstance3D = MeshInstance3D.new()
		var rm: PrismMesh = PrismMesh.new()
		rm.size = Vector3(1.85, 0.65, 1.55)
		roof.mesh = rm
		roof.material_override = roof_mat
		roof.position = Vector3(0, 1.70, 0)
		hut.add_child(roof)
		# Door
		var door: MeshInstance3D = MeshInstance3D.new()
		var dm: BoxMesh = BoxMesh.new()
		dm.size = Vector3(0.40, 0.85, 0.06)
		door.mesh = dm
		door.material_override = roof_mat
		door.position = Vector3(0, 0.42, 0.72)
		hut.add_child(door)
		# Glowing window
		var win: MeshInstance3D = MeshInstance3D.new()
		var wm: BoxMesh = BoxMesh.new()
		wm.size = Vector3(0.30, 0.30, 0.04)
		win.mesh = wm
		win.material_override = window_mat
		win.position = Vector3(-0.45, 0.95, 0.72)
		hut.add_child(win)
		# Chimney
		var chimney: MeshInstance3D = MeshInstance3D.new()
		var cmm: BoxMesh = BoxMesh.new()
		cmm.size = Vector3(0.20, 0.55, 0.20)
		chimney.mesh = cmm
		chimney.material_override = roof_mat
		chimney.position = Vector3(0.45, 2.20, 0)
		hut.add_child(chimney)
		# Smoke (small steam particles from chimney)
		var smoke: GPUParticles3D = GPUParticles3D.new()
		smoke.amount = 18
		smoke.lifetime = 2.5
		smoke.preprocess = 1.0
		smoke.position = Vector3(0.45, 2.55, 0)
		var pm_smoke: ParticleProcessMaterial = ParticleProcessMaterial.new()
		pm_smoke.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_POINT
		pm_smoke.direction = Vector3(0.10, 1, 0.05)
		pm_smoke.spread = 18.0
		pm_smoke.gravity = Vector3(0.05, 0.55, 0)
		pm_smoke.initial_velocity_min = 0.20
		pm_smoke.initial_velocity_max = 0.55
		pm_smoke.scale_min = 0.18
		pm_smoke.scale_max = 0.40
		pm_smoke.color = Color(0.85, 0.85, 0.90, 0.55)
		smoke.process_material = pm_smoke
		var sm_mesh: SphereMesh = SphereMesh.new()
		sm_mesh.radius = 0.18
		sm_mesh.height = 0.36
		smoke.draw_pass_1 = sm_mesh
		var sm_mat: StandardMaterial3D = StandardMaterial3D.new()
		sm_mat.albedo_color = Color(0.85, 0.85, 0.90, 0.45)
		sm_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		sm_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		sm_mesh.material = sm_mat
		hut.add_child(smoke)
		# Window light
		var light: OmniLight3D = OmniLight3D.new()
		light.light_color = Color(1.0, 0.85, 0.30)
		light.light_energy = 1.4
		light.omni_range = 3.5
		light.position = Vector3(-0.45, 0.95, 0.85)
		hut.add_child(light)
		# Hut collision
		var sb: StaticBody3D = StaticBody3D.new()
		sb.position = Vector3(0, 0.70, 0)
		var cs: CollisionShape3D = CollisionShape3D.new()
		var cb: BoxShape3D = BoxShape3D.new()
		cb.size = Vector3(1.65, 1.40, 1.40)
		cs.shape = cb
		sb.add_child(cs)
		hut.add_child(sb)


func _build_d5_ice_angler_npc(town: Node) -> void:
	## Epic-5 T57: ice angler NPC seated outside one of the huts.
	var npc_slots: Node3D = town.get_node_or_null("%NPCSlots") as Node3D
	if npc_slots == null:
		return
	var slot: Marker3D = Marker3D.new()
	slot.name = "IceAnglerSlot"
	slot.position = Vector3(D5_CENTER.x + 12.0, 0.0, 8.0)
	npc_slots.add_child(slot)
	var npc_scene: PackedScene = load("res://scenes/entities/npcs/VillagerR3.tscn") as PackedScene
	if npc_scene == null:
		return
	var npc: Node3D = npc_scene.instantiate() as Node3D
	npc.name = "IceAngler"
	if "npc_name" in npc:
		npc.set("npc_name", "Hooksby")
	if "npc_id" in npc:
		npc.set("npc_id", "angler_d5")
	slot.add_child(npc)
	# Heavy green coat
	var coat: MeshInstance3D = MeshInstance3D.new()
	var cm: BoxMesh = BoxMesh.new()
	cm.size = Vector3(0.75, 1.05, 0.50)
	coat.mesh = cm
	var coat_mat: StandardMaterial3D = StandardMaterial3D.new()
	coat_mat.albedo_color = Color(0.20, 0.45, 0.20)
	coat_mat.roughness = 0.85
	coat.material_override = coat_mat
	coat.position = Vector3(0, 0.55, 0)
	npc.add_child(coat)
	# Knit beanie
	var beanie: MeshInstance3D = MeshInstance3D.new()
	var bm: SphereMesh = SphereMesh.new()
	bm.radius = 0.22
	bm.height = 0.34
	beanie.mesh = bm
	var beanie_mat: StandardMaterial3D = StandardMaterial3D.new()
	beanie_mat.albedo_color = Color(0.85, 0.20, 0.20)
	beanie_mat.roughness = 0.95
	beanie.material_override = beanie_mat
	beanie.position = Vector3(0, 1.50, 0)
	beanie.scale = Vector3(1.0, 0.65, 1.0)
	npc.add_child(beanie)
	# Pom-pom on top
	var pompom: MeshInstance3D = MeshInstance3D.new()
	var pm: SphereMesh = SphereMesh.new()
	pm.radius = 0.08
	pm.height = 0.16
	pompom.mesh = pm
	var pom_mat: StandardMaterial3D = StandardMaterial3D.new()
	pom_mat.albedo_color = Color(0.95, 0.95, 0.92)
	pompom.material_override = pom_mat
	pompom.position = Vector3(0, 1.65, 0)
	npc.add_child(pompom)
	# Held caught fish (small grey/silver prism)
	var fish: MeshInstance3D = MeshInstance3D.new()
	var fm: PrismMesh = PrismMesh.new()
	fm.size = Vector3(0.30, 0.10, 0.10)
	fish.mesh = fm
	var fish_mat: StandardMaterial3D = StandardMaterial3D.new()
	fish_mat.albedo_color = Color(0.65, 0.75, 0.85)
	fish_mat.metallic = 0.55
	fish_mat.roughness = 0.30
	fish.material_override = fish_mat
	fish.position = Vector3(0.45, 0.85, 0.20)
	fish.rotation_degrees = Vector3(0, 0, 90)
	npc.add_child(fish)
	# Held tail wiggle
	var tw: Tween = fish.create_tween().set_loops()
	tw.tween_property(fish, "rotation_degrees:x", 15.0, 0.30)
	tw.tween_property(fish, "rotation_degrees:x", -15.0, 0.30)


func _build_d5_aurora_altar(geom: Node) -> void:
	## Epic-5 T58: aurora data altar — a low circular ice altar with three
	## floating data shards spinning above it, gathering aurora light.
	var altar: Node3D = Node3D.new()
	altar.name = "AuroraDataAltar"
	altar.position = Vector3(D5_CENTER.x - 8.0, 0.0, -16.0)
	geom.add_child(altar)
	var ice_mat: StandardMaterial3D = StandardMaterial3D.new()
	ice_mat.albedo_color = Color(0.65, 0.85, 0.95, 0.85)
	ice_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	ice_mat.emission_enabled = true
	ice_mat.emission = Color(0.40, 0.85, 0.95)
	ice_mat.emission_energy_multiplier = 0.65
	ice_mat.metallic = 0.55
	ice_mat.roughness = 0.10
	# 2-tier circular altar
	var t1: MeshInstance3D = MeshInstance3D.new()
	var t1m: CylinderMesh = CylinderMesh.new()
	t1m.top_radius = 1.85
	t1m.bottom_radius = 2.10
	t1m.height = 0.30
	t1.mesh = t1m
	t1.material_override = ice_mat
	t1.position = Vector3(0, 0.15, 0)
	altar.add_child(t1)
	var t2: MeshInstance3D = MeshInstance3D.new()
	var t2m: CylinderMesh = CylinderMesh.new()
	t2m.top_radius = 1.30
	t2m.bottom_radius = 1.55
	t2m.height = 0.30
	t2.mesh = t2m
	t2.material_override = ice_mat
	t2.position = Vector3(0, 0.45, 0)
	altar.add_child(t2)
	# Center glow disc
	var glow_mat: StandardMaterial3D = StandardMaterial3D.new()
	glow_mat.albedo_color = Color(0.30, 1.0, 1.0)
	glow_mat.emission_enabled = true
	glow_mat.emission = Color(0.30, 1.0, 1.0)
	glow_mat.emission_energy_multiplier = 3.5
	glow_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var glow: MeshInstance3D = MeshInstance3D.new()
	var gm: CylinderMesh = CylinderMesh.new()
	gm.top_radius = 0.85
	gm.bottom_radius = 0.85
	gm.height = 0.04
	glow.mesh = gm
	glow.material_override = glow_mat
	glow.position = Vector3(0, 0.62, 0)
	altar.add_child(glow)
	# 3 floating shards on a pivot
	var pivot: Node3D = Node3D.new()
	pivot.position = Vector3(0, 1.85, 0)
	altar.add_child(pivot)
	for i in 3:
		var ang: float = (TAU / 3.0) * i
		var shard: MeshInstance3D = MeshInstance3D.new()
		var shm: PrismMesh = PrismMesh.new()
		shm.size = Vector3(0.30, 0.85, 0.30)
		shard.mesh = shm
		shard.material_override = glow_mat
		shard.position = Vector3(cos(ang) * 0.85, 0, sin(ang) * 0.85)
		shard.rotation = Vector3(0, ang, 0)
		pivot.add_child(shard)
	var trot: Tween = pivot.create_tween().set_loops()
	trot.tween_property(pivot, "rotation_degrees:y", 360.0, 8.0)
	trot.tween_property(pivot, "rotation_degrees:y", 0.0, 0.0)
	# Aura beam straight up
	var beam: MeshInstance3D = MeshInstance3D.new()
	var beam_m: CylinderMesh = CylinderMesh.new()
	beam_m.top_radius = 0.10
	beam_m.bottom_radius = 0.55
	beam_m.height = 9.0
	beam.mesh = beam_m
	var beam_mat: StandardMaterial3D = StandardMaterial3D.new()
	beam_mat.albedo_color = Color(0.40, 0.95, 1.0, 0.45)
	beam_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	beam_mat.emission_enabled = true
	beam_mat.emission = Color(0.30, 0.95, 1.0)
	beam_mat.emission_energy_multiplier = 1.8
	beam_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	beam.material_override = beam_mat
	beam.position = Vector3(0, 5.50, 0)
	altar.add_child(beam)
	# Aura light
	var light: OmniLight3D = OmniLight3D.new()
	light.light_color = Color(0.40, 0.95, 1.0)
	light.light_energy = 3.5
	light.omni_range = 8.0
	light.position = Vector3(0, 1.85, 0)
	altar.add_child(light)
	# Altar collision
	var sb: StaticBody3D = StaticBody3D.new()
	sb.position = Vector3(0, 0.30, 0)
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cap: CylinderShape3D = CylinderShape3D.new()
	cap.radius = 2.10
	cap.height = 0.65
	cs.shape = cap
	sb.add_child(cs)
	altar.add_child(sb)


func _build_d5_pine_grove(geom: Node) -> void:
	## Epic-5 T59: 8 snow-dusted pine trees clustered together — dark green
	## prism cones with white snow caps.
	var grove: Node3D = Node3D.new()
	grove.name = "PineGrove"
	grove.position = Vector3(D5_CENTER.x - 22.0, 0.0, -16.0)
	geom.add_child(grove)
	var trunk_mat: StandardMaterial3D = StandardMaterial3D.new()
	trunk_mat.albedo_color = Color(0.30, 0.20, 0.10)
	trunk_mat.roughness = 0.95
	var pine_mat: StandardMaterial3D = StandardMaterial3D.new()
	pine_mat.albedo_color = Color(0.20, 0.45, 0.20)
	pine_mat.emission_enabled = true
	pine_mat.emission = Color(0.15, 0.40, 0.15)
	pine_mat.emission_energy_multiplier = 0.18
	pine_mat.roughness = 0.85
	var snow_mat: StandardMaterial3D = StandardMaterial3D.new()
	snow_mat.albedo_color = Color(0.95, 0.97, 1.0)
	snow_mat.emission_enabled = true
	snow_mat.emission = Color(0.85, 0.92, 1.0)
	snow_mat.emission_energy_multiplier = 0.30
	snow_mat.roughness = 0.55
	for i in 8:
		var tree: Node3D = Node3D.new()
		tree.position = Vector3(
			randf_range(-3.5, 3.5),
			0.0,
			randf_range(-3.5, 3.5)
		)
		grove.add_child(tree)
		# Trunk
		var trunk: MeshInstance3D = MeshInstance3D.new()
		var trm: CylinderMesh = CylinderMesh.new()
		trm.top_radius = 0.12
		trm.bottom_radius = 0.18
		trm.height = 1.20
		trunk.mesh = trm
		trunk.material_override = trunk_mat
		trunk.position = Vector3(0, 0.60, 0)
		tree.add_child(trunk)
		# 3 stacked cone tiers
		for c in 3:
			var cone: MeshInstance3D = MeshInstance3D.new()
			var cmm: PrismMesh = PrismMesh.new()
			cmm.size = Vector3(1.40 - c * 0.30, 1.10 - c * 0.10, 1.40 - c * 0.30)
			cone.mesh = cmm
			cone.material_override = pine_mat
			cone.position = Vector3(0, 1.30 + c * 0.85, 0)
			tree.add_child(cone)
		# Snow caps on tiers (small white prisms on top)
		for c in 3:
			var snow_cap: MeshInstance3D = MeshInstance3D.new()
			var sm: PrismMesh = PrismMesh.new()
			sm.size = Vector3(0.85 - c * 0.20, 0.15, 0.85 - c * 0.20)
			snow_cap.mesh = sm
			snow_cap.material_override = snow_mat
			snow_cap.position = Vector3(0, 1.85 + c * 0.85, 0)
			tree.add_child(snow_cap)
		# Trunk collision
		var sb: StaticBody3D = StaticBody3D.new()
		sb.position = Vector3(0, 0.60, 0)
		var cs: CollisionShape3D = CollisionShape3D.new()
		var cap: CapsuleShape3D = CapsuleShape3D.new()
		cap.radius = 0.18
		cap.height = 1.20
		cs.shape = cap
		sb.add_child(cs)
		tree.add_child(sb)


func _build_d5_snowman(geom: Node) -> void:
	## Epic-5 T60: classic snowman — 3 stacked snow spheres + carrot nose +
	## coal eyes/buttons + stick arms + scarf + top hat.
	var snowman: Node3D = Node3D.new()
	snowman.name = "Snowman"
	snowman.position = Vector3(D5_CENTER.x - 4.0, 0.0, 12.0)
	geom.add_child(snowman)
	var snow_mat: StandardMaterial3D = StandardMaterial3D.new()
	snow_mat.albedo_color = Color(0.95, 0.97, 1.0)
	snow_mat.emission_enabled = true
	snow_mat.emission = Color(0.85, 0.92, 1.0)
	snow_mat.emission_energy_multiplier = 0.30
	snow_mat.roughness = 0.55
	# 3 stacked snow spheres (bottom → top)
	var sizes: Array = [0.55, 0.40, 0.30]
	var ys: Array = [0.55, 1.30, 1.85]
	for i in 3:
		var ball: MeshInstance3D = MeshInstance3D.new()
		var bm: SphereMesh = SphereMesh.new()
		bm.radius = sizes[i]
		bm.height = sizes[i] * 2.0
		ball.mesh = bm
		ball.material_override = snow_mat
		ball.position = Vector3(0, ys[i], 0)
		snowman.add_child(ball)
	# Carrot nose
	var nose: MeshInstance3D = MeshInstance3D.new()
	var nm: PrismMesh = PrismMesh.new()
	nm.size = Vector3(0.06, 0.06, 0.20)
	nose.mesh = nm
	var nose_mat: StandardMaterial3D = StandardMaterial3D.new()
	nose_mat.albedo_color = Color(0.95, 0.55, 0.10)
	nose_mat.emission_enabled = true
	nose_mat.emission = Color(0.95, 0.45, 0.05)
	nose_mat.emission_energy_multiplier = 0.30
	nose.material_override = nose_mat
	nose.position = Vector3(0, 1.85, 0.30)
	nose.rotation_degrees = Vector3(90, 0, 0)
	snowman.add_child(nose)
	# 2 coal eyes
	var coal_mat: StandardMaterial3D = StandardMaterial3D.new()
	coal_mat.albedo_color = Color(0.05, 0.05, 0.08)
	coal_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for ex in [-0.10, 0.10]:
		var eye: MeshInstance3D = MeshInstance3D.new()
		var em: SphereMesh = SphereMesh.new()
		em.radius = 0.045
		em.height = 0.09
		eye.mesh = em
		eye.material_override = coal_mat
		eye.position = Vector3(ex, 1.95, 0.25)
		snowman.add_child(eye)
	# 3 coal buttons on the body
	for i in 3:
		var btn: MeshInstance3D = MeshInstance3D.new()
		var bm: SphereMesh = SphereMesh.new()
		bm.radius = 0.05
		bm.height = 0.10
		btn.mesh = bm
		btn.material_override = coal_mat
		btn.position = Vector3(0, 1.10 + i * 0.18, 0.42 - i * 0.04)
		snowman.add_child(btn)
	# 2 stick arms (thin cylinders)
	var stick_mat: StandardMaterial3D = StandardMaterial3D.new()
	stick_mat.albedo_color = Color(0.40, 0.25, 0.10)
	stick_mat.roughness = 0.95
	for sx in [-1, 1]:
		var arm: MeshInstance3D = MeshInstance3D.new()
		var am: CylinderMesh = CylinderMesh.new()
		am.top_radius = 0.025
		am.bottom_radius = 0.035
		am.height = 0.85
		arm.mesh = am
		arm.material_override = stick_mat
		arm.position = Vector3(sx * 0.55, 1.30, 0)
		arm.rotation_degrees = Vector3(0, 0, sx * 35.0)
		snowman.add_child(arm)
	# Scarf (red box around the neck)
	var scarf: MeshInstance3D = MeshInstance3D.new()
	var scm: BoxMesh = BoxMesh.new()
	scm.size = Vector3(0.65, 0.10, 0.65)
	scarf.mesh = scm
	var scarf_mat: StandardMaterial3D = StandardMaterial3D.new()
	scarf_mat.albedo_color = Color(0.85, 0.20, 0.20)
	scarf_mat.roughness = 0.85
	scarf.material_override = scarf_mat
	scarf.position = Vector3(0, 1.65, 0)
	snowman.add_child(scarf)
	# Trailing scarf end
	var scarf_end: MeshInstance3D = MeshInstance3D.new()
	var sem: BoxMesh = BoxMesh.new()
	sem.size = Vector3(0.10, 0.45, 0.06)
	scarf_end.mesh = sem
	scarf_end.material_override = scarf_mat
	scarf_end.position = Vector3(0.20, 1.45, 0.20)
	snowman.add_child(scarf_end)
	# Black top hat (cylinder + flat brim disc)
	var hat_mat: StandardMaterial3D = StandardMaterial3D.new()
	hat_mat.albedo_color = Color(0.10, 0.10, 0.12)
	hat_mat.metallic = 0.30
	hat_mat.roughness = 0.40
	var brim: MeshInstance3D = MeshInstance3D.new()
	var brm: CylinderMesh = CylinderMesh.new()
	brm.top_radius = 0.32
	brm.bottom_radius = 0.32
	brm.height = 0.04
	brim.mesh = brm
	brim.material_override = hat_mat
	brim.position = Vector3(0, 2.18, 0)
	snowman.add_child(brim)
	var hat: MeshInstance3D = MeshInstance3D.new()
	var hm: CylinderMesh = CylinderMesh.new()
	hm.top_radius = 0.22
	hm.bottom_radius = 0.22
	hm.height = 0.40
	hat.mesh = hm
	hat.material_override = hat_mat
	hat.position = Vector3(0, 2.40, 0)
	snowman.add_child(hat)
	# Snowman collision (capsule)
	var sb: StaticBody3D = StaticBody3D.new()
	sb.position = Vector3(0, 1.20, 0)
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cap: CapsuleShape3D = CapsuleShape3D.new()
	cap.radius = 0.55
	cap.height = 2.20
	cs.shape = cap
	sb.add_child(cs)
	snowman.add_child(sb)


func _build_d5_caribou_herd(geom: Node) -> void:
	## Epic-5 T61: 4 caribou with branching antlers grazing in a small group.
	var herd: Node3D = Node3D.new()
	herd.name = "CaribouHerd"
	herd.position = Vector3(D5_CENTER.x - 18.0, 0.0, 8.0)
	geom.add_child(herd)
	var fur_mat: StandardMaterial3D = StandardMaterial3D.new()
	fur_mat.albedo_color = Color(0.50, 0.35, 0.20)
	fur_mat.roughness = 0.85
	var antler_mat: StandardMaterial3D = StandardMaterial3D.new()
	antler_mat.albedo_color = Color(0.85, 0.75, 0.55)
	antler_mat.roughness = 0.65
	var positions: Array = [
		Vector3( 0.0, 0,  0.0),
		Vector3( 2.4, 0,  1.2),
		Vector3(-2.0, 0,  0.6),
		Vector3( 0.8, 0, -2.0),
	]
	for p in positions:
		var caribou: Node3D = Node3D.new()
		caribou.position = p
		herd.add_child(caribou)
		# Body
		var body: MeshInstance3D = MeshInstance3D.new()
		var bm: SphereMesh = SphereMesh.new()
		bm.radius = 0.40
		bm.height = 0.65
		body.mesh = bm
		body.material_override = fur_mat
		body.position = Vector3(0, 0.85, 0)
		body.scale = Vector3(1.0, 0.85, 1.55)
		caribou.add_child(body)
		# Head
		var head: MeshInstance3D = MeshInstance3D.new()
		var hm: SphereMesh = SphereMesh.new()
		hm.radius = 0.20
		hm.height = 0.36
		head.mesh = hm
		head.material_override = fur_mat
		head.position = Vector3(0, 1.20, 0.55)
		caribou.add_child(head)
		# Snout
		var snout: MeshInstance3D = MeshInstance3D.new()
		var sm2: BoxMesh = BoxMesh.new()
		sm2.size = Vector3(0.14, 0.10, 0.20)
		snout.mesh = sm2
		snout.material_override = fur_mat
		snout.position = Vector3(0, 1.10, 0.75)
		caribou.add_child(snout)
		# 2 large branching antlers (multiple prism branches)
		for sx in [-0.18, 0.18]:
			# Main antler stem
			var stem: MeshInstance3D = MeshInstance3D.new()
			var stm: PrismMesh = PrismMesh.new()
			stm.size = Vector3(0.06, 0.65, 0.06)
			stem.mesh = stm
			stem.material_override = antler_mat
			stem.position = Vector3(sx, 1.55, 0.50)
			stem.rotation_degrees = Vector3(-15, 0, sx * 35.0)
			caribou.add_child(stem)
			# 3 smaller branches off the main stem
			for j in 3:
				var branch: MeshInstance3D = MeshInstance3D.new()
				var bbm: PrismMesh = PrismMesh.new()
				bbm.size = Vector3(0.04, 0.30, 0.04)
				branch.mesh = bbm
				branch.material_override = antler_mat
				branch.position = Vector3(sx + sx * 0.5 * j, 1.55 + j * 0.18, 0.50)
				branch.rotation_degrees = Vector3(-25, 0, sx * 70.0)
				caribou.add_child(branch)
		# 4 long legs
		for lx in [-0.22, 0.22]:
			for lz in [-0.32, 0.32]:
				var leg: MeshInstance3D = MeshInstance3D.new()
				var lm: CylinderMesh = CylinderMesh.new()
				lm.top_radius = 0.06
				lm.bottom_radius = 0.06
				lm.height = 0.85
				leg.mesh = lm
				leg.material_override = fur_mat
				leg.position = Vector3(lx, 0.42, lz)
				caribou.add_child(leg)
		# Grazing head bob
		var tw: Tween = head.create_tween().set_loops()
		tw.tween_property(head, "position:y", 0.85, 1.0 + randf() * 0.4)
		tw.tween_property(head, "position:y", 1.20, 1.0 + randf() * 0.4)
		# Body collision
		var sb: StaticBody3D = StaticBody3D.new()
		sb.position = Vector3(0, 0.85, 0)
		var cs: CollisionShape3D = CollisionShape3D.new()
		var cb: BoxShape3D = BoxShape3D.new()
		cb.size = Vector3(0.95, 1.40, 1.40)
		cs.shape = cb
		sb.add_child(cs)
		caribou.add_child(sb)


func _build_d5_caribou_herder_npc(town: Node) -> void:
	## Epic-5 T62: caribou herder NPC with a long staff and traditional
	## fur-trimmed coat.
	var npc_slots: Node3D = town.get_node_or_null("%NPCSlots") as Node3D
	if npc_slots == null:
		return
	var slot: Marker3D = Marker3D.new()
	slot.name = "CaribouHerderSlot"
	slot.position = Vector3(D5_CENTER.x - 14.0, 0.0, 8.0)
	npc_slots.add_child(slot)
	var npc_scene: PackedScene = load("res://scenes/entities/npcs/VillagerR3.tscn") as PackedScene
	if npc_scene == null:
		return
	var npc: Node3D = npc_scene.instantiate() as Node3D
	npc.name = "CaribouHerder"
	if "npc_name" in npc:
		npc.set("npc_name", "Tundratread")
	if "npc_id" in npc:
		npc.set("npc_id", "herder_d5")
	slot.add_child(npc)
	# Brown coat with fur trim
	var coat: MeshInstance3D = MeshInstance3D.new()
	var cm: BoxMesh = BoxMesh.new()
	cm.size = Vector3(0.75, 1.10, 0.55)
	coat.mesh = cm
	var coat_mat: StandardMaterial3D = StandardMaterial3D.new()
	coat_mat.albedo_color = Color(0.45, 0.28, 0.12)
	coat_mat.roughness = 0.85
	coat.material_override = coat_mat
	coat.position = Vector3(0, 0.55, 0)
	npc.add_child(coat)
	# Fur collar
	var collar: MeshInstance3D = MeshInstance3D.new()
	var clm: CylinderMesh = CylinderMesh.new()
	clm.top_radius = 0.30
	clm.bottom_radius = 0.30
	clm.height = 0.18
	collar.mesh = clm
	var fur_mat: StandardMaterial3D = StandardMaterial3D.new()
	fur_mat.albedo_color = Color(0.95, 0.95, 0.90)
	fur_mat.roughness = 0.95
	collar.material_override = fur_mat
	collar.position = Vector3(0, 1.10, 0)
	npc.add_child(collar)
	# Tall walking staff with antler-tip
	var wood_mat: StandardMaterial3D = StandardMaterial3D.new()
	wood_mat.albedo_color = Color(0.40, 0.25, 0.10)
	wood_mat.roughness = 0.85
	var staff: MeshInstance3D = MeshInstance3D.new()
	var stm: CylinderMesh = CylinderMesh.new()
	stm.top_radius = 0.04
	stm.bottom_radius = 0.05
	stm.height = 1.95
	staff.mesh = stm
	staff.material_override = wood_mat
	staff.position = Vector3(0.45, 0.97, 0)
	npc.add_child(staff)
	# Antler tip
	var tip: MeshInstance3D = MeshInstance3D.new()
	var tm: PrismMesh = PrismMesh.new()
	tm.size = Vector3(0.10, 0.30, 0.10)
	tip.mesh = tm
	var antler_mat: StandardMaterial3D = StandardMaterial3D.new()
	antler_mat.albedo_color = Color(0.85, 0.75, 0.55)
	antler_mat.roughness = 0.65
	tip.material_override = antler_mat
	tip.position = Vector3(0.45, 2.05, 0)
	npc.add_child(tip)


func _build_d5_ice_rails(geom: Node) -> void:
	## Epic-5 T63: 12m ice rail track running west-east through the lower
	## south of D5 — 2 long parallel ice rails + 6 wooden cross-ties.
	var rails: Node3D = Node3D.new()
	rails.name = "IceRails"
	rails.position = Vector3(D5_CENTER.x, 0.0, 18.0)
	geom.add_child(rails)
	var ice_mat: StandardMaterial3D = StandardMaterial3D.new()
	ice_mat.albedo_color = Color(0.75, 0.90, 1.0)
	ice_mat.emission_enabled = true
	ice_mat.emission = Color(0.55, 0.85, 0.95)
	ice_mat.emission_energy_multiplier = 0.55
	ice_mat.metallic = 0.65
	ice_mat.roughness = 0.20
	var wood_mat: StandardMaterial3D = StandardMaterial3D.new()
	wood_mat.albedo_color = Color(0.45, 0.28, 0.12)
	wood_mat.roughness = 0.85
	# 2 parallel rails
	for sz in [-0.55, 0.55]:
		var rail: MeshInstance3D = MeshInstance3D.new()
		var rm: BoxMesh = BoxMesh.new()
		rm.size = Vector3(14.0, 0.18, 0.18)
		rail.mesh = rm
		rail.material_override = ice_mat
		rail.position = Vector3(0, 0.18, sz)
		rails.add_child(rail)
	# 9 wooden cross-ties
	for i in 9:
		var tie: MeshInstance3D = MeshInstance3D.new()
		var tm: BoxMesh = BoxMesh.new()
		tm.size = Vector3(0.40, 0.10, 1.65)
		tie.mesh = tm
		tie.material_override = wood_mat
		tie.position = Vector3(-6.0 + i * 1.5, 0.05, 0)
		rails.add_child(tie)


func _build_d5_cable_car_station(geom: Node) -> void:
	## Epic-5 T64: cable car station — tall ice tower + horizontal cable +
	## hanging gondola cabin with cyan windows + a station platform.
	var station: Node3D = Node3D.new()
	station.name = "CableCarStation"
	station.position = Vector3(D5_CENTER.x + 26.0, 0.0, 4.0)
	geom.add_child(station)
	var ice_mat: StandardMaterial3D = StandardMaterial3D.new()
	ice_mat.albedo_color = Color(0.78, 0.92, 1.0)
	ice_mat.emission_enabled = true
	ice_mat.emission = Color(0.55, 0.85, 1.0)
	ice_mat.emission_energy_multiplier = 0.30
	ice_mat.roughness = 0.45
	var metal_mat: StandardMaterial3D = StandardMaterial3D.new()
	metal_mat.albedo_color = Color(0.40, 0.45, 0.50)
	metal_mat.metallic = 0.85
	metal_mat.roughness = 0.30
	# Tall tower
	var tower: MeshInstance3D = MeshInstance3D.new()
	var twm: BoxMesh = BoxMesh.new()
	twm.size = Vector3(1.85, 7.50, 1.85)
	tower.mesh = twm
	tower.material_override = ice_mat
	tower.position = Vector3(0, 3.75, 0)
	station.add_child(tower)
	# Top cable arm (horizontal cylinder)
	var arm: MeshInstance3D = MeshInstance3D.new()
	var arm_m: CylinderMesh = CylinderMesh.new()
	arm_m.top_radius = 0.10
	arm_m.bottom_radius = 0.10
	arm_m.height = 4.20
	arm.mesh = arm_m
	arm.material_override = metal_mat
	arm.position = Vector3(2.10, 7.20, 0)
	arm.rotation_degrees = Vector3(0, 0, 90)
	station.add_child(arm)
	# Cable hanging down to gondola
	var cable: MeshInstance3D = MeshInstance3D.new()
	var ccm: CylinderMesh = CylinderMesh.new()
	ccm.top_radius = 0.025
	ccm.bottom_radius = 0.025
	ccm.height = 2.20
	cable.mesh = ccm
	var cable_mat: StandardMaterial3D = StandardMaterial3D.new()
	cable_mat.albedo_color = Color(0.20, 0.22, 0.25)
	cable_mat.metallic = 0.85
	cable_mat.roughness = 0.30
	cable.material_override = cable_mat
	cable.position = Vector3(4.20, 6.10, 0)
	station.add_child(cable)
	# Gondola cabin
	var cabin: Node3D = Node3D.new()
	cabin.position = Vector3(4.20, 4.65, 0)
	station.add_child(cabin)
	var cabin_body: MeshInstance3D = MeshInstance3D.new()
	var cbm: BoxMesh = BoxMesh.new()
	cbm.size = Vector3(1.40, 1.65, 1.10)
	cabin_body.mesh = cbm
	var cabin_mat: StandardMaterial3D = StandardMaterial3D.new()
	cabin_mat.albedo_color = Color(0.85, 0.20, 0.30)
	cabin_mat.metallic = 0.30
	cabin_mat.roughness = 0.45
	cabin_body.material_override = cabin_mat
	cabin.add_child(cabin_body)
	# 2 cyan windows on cabin
	var window_mat: StandardMaterial3D = StandardMaterial3D.new()
	window_mat.albedo_color = Color(0.40, 0.95, 1.0, 0.85)
	window_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	window_mat.emission_enabled = true
	window_mat.emission = Color(0.40, 1.0, 1.0)
	window_mat.emission_energy_multiplier = 2.5
	window_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for sx in [-0.40, 0.40]:
		var win: MeshInstance3D = MeshInstance3D.new()
		var wm: BoxMesh = BoxMesh.new()
		wm.size = Vector3(0.30, 0.45, 0.04)
		win.mesh = wm
		win.material_override = window_mat
		win.position = Vector3(sx, 0.20, 0.58)
		cabin.add_child(win)
	# Cabin roof (sloped prism)
	var roof: MeshInstance3D = MeshInstance3D.new()
	var rfm: PrismMesh = PrismMesh.new()
	rfm.size = Vector3(1.55, 0.30, 1.20)
	roof.mesh = rfm
	roof.material_override = metal_mat
	roof.position = Vector3(0, 0.95, 0)
	cabin.add_child(roof)
	# Subtle cabin sway
	var tw: Tween = cabin.create_tween().set_loops()
	tw.tween_property(cabin, "rotation_degrees:z", 4.0, 2.5)
	tw.tween_property(cabin, "rotation_degrees:z", -4.0, 2.5)
	# Station platform
	var platform: MeshInstance3D = MeshInstance3D.new()
	var plm: BoxMesh = BoxMesh.new()
	plm.size = Vector3(2.85, 0.30, 2.85)
	platform.mesh = plm
	platform.material_override = ice_mat
	platform.position = Vector3(0, 0.15, 0)
	station.add_child(platform)
	# Platform collision
	var sb: StaticBody3D = StaticBody3D.new()
	sb.position = Vector3(0, 0.15, 0)
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(2.85, 0.30, 2.85)
	cs.shape = cb
	sb.add_child(cs)
	station.add_child(sb)
	# Tower collision
	var tsb: StaticBody3D = StaticBody3D.new()
	tsb.position = Vector3(0, 3.75, 0)
	var tcs: CollisionShape3D = CollisionShape3D.new()
	var tcb: BoxShape3D = BoxShape3D.new()
	tcb.size = Vector3(1.85, 7.50, 1.85)
	tcs.shape = tcb
	tsb.add_child(tcs)
	station.add_child(tsb)


func _build_d5_snow_sculpture(geom: Node) -> void:
	## Epic-5 T65: large snow sculpture — abstract spiral made of stacked
	## snow segments + a glowing rune embedded at its core. Public art.
	var sculpture: Node3D = Node3D.new()
	sculpture.name = "SnowSculpture"
	sculpture.position = Vector3(D5_CENTER.x + 4.0, 0.0, 14.0)
	geom.add_child(sculpture)
	var snow_mat: StandardMaterial3D = StandardMaterial3D.new()
	snow_mat.albedo_color = Color(0.95, 0.97, 1.0)
	snow_mat.emission_enabled = true
	snow_mat.emission = Color(0.85, 0.92, 1.0)
	snow_mat.emission_energy_multiplier = 0.30
	snow_mat.roughness = 0.55
	# Spiral via 12 stacked sphere segments offset around a vertical axis
	for i in 12:
		var t: float = i / 11.0
		var ang: float = t * TAU * 2.0
		var seg: MeshInstance3D = MeshInstance3D.new()
		var sm: SphereMesh = SphereMesh.new()
		sm.radius = 0.40 - t * 0.15
		sm.height = 0.65 - t * 0.18
		seg.mesh = sm
		seg.material_override = snow_mat
		seg.position = Vector3(cos(ang) * 0.85, 0.55 + i * 0.45, sin(ang) * 0.85)
		sculpture.add_child(seg)
	# Top crown rune (glowing cyan crystal)
	var rune_mat: StandardMaterial3D = StandardMaterial3D.new()
	rune_mat.albedo_color = Color(0.30, 0.95, 1.0)
	rune_mat.emission_enabled = true
	rune_mat.emission = Color(0.30, 1.0, 1.0)
	rune_mat.emission_energy_multiplier = 3.5
	rune_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var crown: MeshInstance3D = MeshInstance3D.new()
	var cm: PrismMesh = PrismMesh.new()
	cm.size = Vector3(0.55, 0.95, 0.55)
	crown.mesh = cm
	crown.material_override = rune_mat
	crown.position = Vector3(0, 6.40, 0)
	sculpture.add_child(crown)
	# Crown spin
	var ts: Tween = crown.create_tween().set_loops()
	ts.tween_property(crown, "rotation_degrees:y", 360.0, 7.0)
	ts.tween_property(crown, "rotation_degrees:y", 0.0, 0.0)
	# Light at the crown
	var light: OmniLight3D = OmniLight3D.new()
	light.light_color = Color(0.40, 0.95, 1.0)
	light.light_energy = 2.5
	light.omni_range = 5.0
	light.position = Vector3(0, 6.40, 0)
	sculpture.add_child(light)
	# Base collision
	var sb: StaticBody3D = StaticBody3D.new()
	sb.position = Vector3(0, 3.0, 0)
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cap: CapsuleShape3D = CapsuleShape3D.new()
	cap.radius = 1.10
	cap.height = 6.0
	cs.shape = cap
	sb.add_child(cs)
	sculpture.add_child(sb)


func _build_d5_thermal_vents(geom: Node) -> void:
	## Epic-5 T66: 5 small thermal vents in the ice — dark holes with rising
	## steam columns and faint orange glow underneath.
	var vents: Node3D = Node3D.new()
	vents.name = "ThermalVents"
	vents.position = Vector3(D5_CENTER.x + 14.0, 0.0, 0.0)
	geom.add_child(vents)
	var dark_mat: StandardMaterial3D = StandardMaterial3D.new()
	dark_mat.albedo_color = Color(0.05, 0.10, 0.18)
	dark_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for i in 5:
		var vent: Node3D = Node3D.new()
		vent.position = Vector3(
			randf_range(-2.5, 2.5),
			0.0,
			randf_range(-2.5, 2.5)
		)
		vents.add_child(vent)
		# Vent hole (dark disc)
		var hole: MeshInstance3D = MeshInstance3D.new()
		var hm: CylinderMesh = CylinderMesh.new()
		hm.top_radius = 0.30
		hm.bottom_radius = 0.30
		hm.height = 0.04
		hole.mesh = hm
		hole.material_override = dark_mat
		hole.position = Vector3(0, 0.04, 0)
		vent.add_child(hole)
		# Steam particles rising
		var steam: GPUParticles3D = GPUParticles3D.new()
		steam.amount = 22
		steam.lifetime = 2.2
		steam.preprocess = 1.0
		var pm: ParticleProcessMaterial = ParticleProcessMaterial.new()
		pm.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_POINT
		pm.direction = Vector3(0, 1, 0)
		pm.spread = 22.0
		pm.gravity = Vector3.ZERO
		pm.initial_velocity_min = 0.45
		pm.initial_velocity_max = 0.95
		pm.scale_min = 0.18
		pm.scale_max = 0.45
		pm.color = Color(0.95, 0.92, 0.85, 0.55)
		steam.process_material = pm
		var sm_mesh: SphereMesh = SphereMesh.new()
		sm_mesh.radius = 0.18
		sm_mesh.height = 0.36
		steam.draw_pass_1 = sm_mesh
		var sm_mat: StandardMaterial3D = StandardMaterial3D.new()
		sm_mat.albedo_color = Color(0.95, 0.92, 0.85, 0.45)
		sm_mat.emission_enabled = true
		sm_mat.emission = Color(0.95, 0.85, 0.65)
		sm_mat.emission_energy_multiplier = 0.65
		sm_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		sm_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		sm_mesh.material = sm_mat
		steam.position = Vector3(0, 0.20, 0)
		vent.add_child(steam)
		# Faint orange glow from below
		var light: OmniLight3D = OmniLight3D.new()
		light.light_color = Color(1.0, 0.55, 0.20)
		light.light_energy = 0.85
		light.omni_range = 1.85
		light.position = Vector3(0, -0.10, 0)
		vent.add_child(light)


func _build_d5_hot_spring(geom: Node) -> void:
	## Epic-5 T67: hot spring pool — circular stone-rim pool with steaming
	## warm water surface and an orange underglow.
	var spring: Node3D = Node3D.new()
	spring.name = "HotSpring"
	spring.position = Vector3(D5_CENTER.x + 12.0, 0.0, 4.0)
	geom.add_child(spring)
	# Stone rim
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.55, 0.50, 0.45)
	stone_mat.roughness = 0.92
	var rim: MeshInstance3D = MeshInstance3D.new()
	var rm: TorusMesh = TorusMesh.new()
	rm.inner_radius = 1.40
	rm.outer_radius = 1.85
	rim.mesh = rm
	rim.material_override = stone_mat
	rim.position = Vector3(0, 0.30, 0)
	spring.add_child(rim)
	# Water surface (warm cyan-green disc)
	var water: MeshInstance3D = MeshInstance3D.new()
	var wm: CylinderMesh = CylinderMesh.new()
	wm.top_radius = 1.55
	wm.bottom_radius = 1.55
	wm.height = 0.08
	water.mesh = wm
	var water_mat: StandardMaterial3D = StandardMaterial3D.new()
	water_mat.albedo_color = Color(0.30, 0.85, 0.75, 0.85)
	water_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	water_mat.emission_enabled = true
	water_mat.emission = Color(0.30, 0.95, 0.80)
	water_mat.emission_energy_multiplier = 0.85
	water_mat.metallic = 0.30
	water_mat.roughness = 0.10
	water.material_override = water_mat
	water.position = Vector3(0, 0.30, 0)
	spring.add_child(water)
	# Subtle bob
	var twb: Tween = water.create_tween().set_loops()
	twb.tween_property(water, "position:y", 0.34, 1.5)
	twb.tween_property(water, "position:y", 0.30, 1.5)
	# 3 stone benches around the pool
	for i in 3:
		var ang: float = (TAU / 3.0) * i + PI / 6.0
		var bench: MeshInstance3D = MeshInstance3D.new()
		var bm: BoxMesh = BoxMesh.new()
		bm.size = Vector3(1.10, 0.30, 0.40)
		bench.mesh = bm
		bench.material_override = stone_mat
		bench.position = Vector3(cos(ang) * 2.30, 0.18, sin(ang) * 2.30)
		bench.rotation = Vector3(0, -ang, 0)
		spring.add_child(bench)
	# Steam particles rising from the water
	var steam: GPUParticles3D = GPUParticles3D.new()
	steam.amount = 35
	steam.lifetime = 3.0
	steam.preprocess = 1.5
	steam.position = Vector3(0, 0.45, 0)
	var pm: ParticleProcessMaterial = ParticleProcessMaterial.new()
	pm.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	pm.emission_box_extents = Vector3(1.40, 0.10, 1.40)
	pm.direction = Vector3(0.10, 1, 0.05)
	pm.spread = 22.0
	pm.gravity = Vector3(0.05, 0.55, 0)
	pm.initial_velocity_min = 0.30
	pm.initial_velocity_max = 0.65
	pm.scale_min = 0.30
	pm.scale_max = 0.65
	pm.color = Color(0.95, 0.92, 0.85, 0.55)
	steam.process_material = pm
	var sm_mesh: SphereMesh = SphereMesh.new()
	sm_mesh.radius = 0.25
	sm_mesh.height = 0.50
	steam.draw_pass_1 = sm_mesh
	var sm_mat: StandardMaterial3D = StandardMaterial3D.new()
	sm_mat.albedo_color = Color(0.95, 0.95, 1.0, 0.45)
	sm_mat.emission_enabled = true
	sm_mat.emission = Color(0.85, 0.92, 1.0)
	sm_mat.emission_energy_multiplier = 0.55
	sm_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	sm_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	sm_mesh.material = sm_mat
	spring.add_child(steam)
	# Warm pool light from below
	var light: OmniLight3D = OmniLight3D.new()
	light.light_color = Color(0.85, 0.95, 0.70)
	light.light_energy = 2.5
	light.omni_range = 6.0
	light.position = Vector3(0, 0.20, 0)
	spring.add_child(light)
	# Rim collision
	var sb: StaticBody3D = StaticBody3D.new()
	sb.position = Vector3(0, 0.30, 0)
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cap: CylinderShape3D = CylinderShape3D.new()
	cap.radius = 1.85
	cap.height = 0.55
	cs.shape = cap
	sb.add_child(cs)
	spring.add_child(sb)


func _build_d5_bath_attendant_npc(town: Node) -> void:
	## Epic-5 T68: bath attendant NPC near the hot spring — short white robe,
	## carrying a stack of folded towels.
	var npc_slots: Node3D = town.get_node_or_null("%NPCSlots") as Node3D
	if npc_slots == null:
		return
	var slot: Marker3D = Marker3D.new()
	slot.name = "BathAttendantSlot"
	slot.position = Vector3(D5_CENTER.x + 10.0, 0.0, 4.0)
	npc_slots.add_child(slot)
	var npc_scene: PackedScene = load("res://scenes/entities/npcs/VillagerR3.tscn") as PackedScene
	if npc_scene == null:
		return
	var npc: Node3D = npc_scene.instantiate() as Node3D
	npc.name = "BathAttendant"
	if "npc_name" in npc:
		npc.set("npc_name", "Onsen")
	if "npc_id" in npc:
		npc.set("npc_id", "bath_d5")
	slot.add_child(npc)
	# White robe
	var robe: MeshInstance3D = MeshInstance3D.new()
	var rm: BoxMesh = BoxMesh.new()
	rm.size = Vector3(0.65, 0.95, 0.40)
	robe.mesh = rm
	var robe_mat: StandardMaterial3D = StandardMaterial3D.new()
	robe_mat.albedo_color = Color(0.95, 0.95, 0.92)
	robe_mat.roughness = 0.85
	robe.material_override = robe_mat
	robe.position = Vector3(0, 0.55, 0)
	npc.add_child(robe)
	# Stack of folded towels (3 colored boxes)
	var towel_colors: Array = [
		Color(0.85, 0.20, 0.30),
		Color(0.30, 0.65, 0.85),
		Color(0.95, 0.85, 0.30),
	]
	for i in 3:
		var towel: MeshInstance3D = MeshInstance3D.new()
		var tm: BoxMesh = BoxMesh.new()
		tm.size = Vector3(0.40, 0.10, 0.30)
		towel.mesh = tm
		var tmat: StandardMaterial3D = StandardMaterial3D.new()
		tmat.albedo_color = towel_colors[i]
		tmat.roughness = 0.85
		towel.material_override = tmat
		towel.position = Vector3(0.40, 0.85 + i * 0.11, 0.20)
		npc.add_child(towel)


func _build_d5_ice_climbing_wall(geom: Node) -> void:
	## Epic-5 T69: tall vertical ice climbing wall — large ice slab face
	## with embedded handhold prisms and 3 anchored ropes.
	var wall: Node3D = Node3D.new()
	wall.name = "IceClimbingWall"
	wall.position = Vector3(D5_CENTER.x + 22.0, 0.0, 16.0)
	geom.add_child(wall)
	var ice_mat: StandardMaterial3D = StandardMaterial3D.new()
	ice_mat.albedo_color = Color(0.65, 0.85, 0.95, 0.92)
	ice_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	ice_mat.emission_enabled = true
	ice_mat.emission = Color(0.40, 0.85, 0.95)
	ice_mat.emission_energy_multiplier = 0.55
	ice_mat.metallic = 0.55
	ice_mat.roughness = 0.20
	# Main slab
	var slab: MeshInstance3D = MeshInstance3D.new()
	var sm: BoxMesh = BoxMesh.new()
	sm.size = Vector3(5.50, 7.50, 1.10)
	slab.mesh = sm
	slab.material_override = ice_mat
	slab.position = Vector3(0, 3.75, 0)
	wall.add_child(slab)
	# 12 handhold prisms scattered on the front
	var hold_mat: StandardMaterial3D = StandardMaterial3D.new()
	hold_mat.albedo_color = Color(0.30, 0.95, 1.0)
	hold_mat.emission_enabled = true
	hold_mat.emission = Color(0.30, 1.0, 1.0)
	hold_mat.emission_energy_multiplier = 1.6
	hold_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for i in 12:
		var hold: MeshInstance3D = MeshInstance3D.new()
		var hm: PrismMesh = PrismMesh.new()
		hm.size = Vector3(0.20, 0.18, 0.20)
		hold.mesh = hm
		hold.material_override = hold_mat
		hold.position = Vector3(
			randf_range(-2.0, 2.0),
			0.85 + randf_range(0, 5.85),
			0.60
		)
		hold.rotation_degrees = Vector3(randf_range(-30, 30), randf_range(0, 360), randf_range(-30, 30))
		wall.add_child(hold)
	# 3 anchored ropes hanging from the top
	var rope_mat: StandardMaterial3D = StandardMaterial3D.new()
	rope_mat.albedo_color = Color(0.85, 0.55, 0.20)
	rope_mat.roughness = 0.85
	for sx in [-1.85, 0.0, 1.85]:
		var rope: MeshInstance3D = MeshInstance3D.new()
		var rm: CylinderMesh = CylinderMesh.new()
		rm.top_radius = 0.025
		rm.bottom_radius = 0.025
		rm.height = 6.50
		rope.mesh = rm
		rope.material_override = rope_mat
		rope.position = Vector3(sx, 4.20, 0.65)
		wall.add_child(rope)
	# Wall collision
	var sb: StaticBody3D = StaticBody3D.new()
	sb.position = Vector3(0, 3.75, 0)
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(5.50, 7.50, 1.10)
	cs.shape = cb
	sb.add_child(cs)
	wall.add_child(sb)


func _build_d5_ice_climber_npc(town: Node) -> void:
	## Epic-5 T70: ice climber NPC — bright orange jacket, helmet, and
	## holding a small ice axe.
	var npc_slots: Node3D = town.get_node_or_null("%NPCSlots") as Node3D
	if npc_slots == null:
		return
	var slot: Marker3D = Marker3D.new()
	slot.name = "IceClimberSlot"
	slot.position = Vector3(D5_CENTER.x + 20.0, 0.0, 16.0)
	npc_slots.add_child(slot)
	var npc_scene: PackedScene = load("res://scenes/entities/npcs/VillagerR3.tscn") as PackedScene
	if npc_scene == null:
		return
	var npc: Node3D = npc_scene.instantiate() as Node3D
	npc.name = "IceClimber"
	if "npc_name" in npc:
		npc.set("npc_name", "Crampon")
	if "npc_id" in npc:
		npc.set("npc_id", "climber_d5")
	slot.add_child(npc)
	# Bright orange jacket
	var jacket: MeshInstance3D = MeshInstance3D.new()
	var jm: BoxMesh = BoxMesh.new()
	jm.size = Vector3(0.75, 1.05, 0.50)
	jacket.mesh = jm
	var jacket_mat: StandardMaterial3D = StandardMaterial3D.new()
	jacket_mat.albedo_color = Color(0.95, 0.55, 0.10)
	jacket_mat.emission_enabled = true
	jacket_mat.emission = Color(0.95, 0.45, 0.05)
	jacket_mat.emission_energy_multiplier = 0.30
	jacket_mat.roughness = 0.65
	jacket.material_override = jacket_mat
	jacket.position = Vector3(0, 0.55, 0)
	npc.add_child(jacket)
	# White helmet
	var helmet: MeshInstance3D = MeshInstance3D.new()
	var hm: SphereMesh = SphereMesh.new()
	hm.radius = 0.22
	hm.height = 0.36
	helmet.mesh = hm
	var helmet_mat: StandardMaterial3D = StandardMaterial3D.new()
	helmet_mat.albedo_color = Color(0.95, 0.95, 0.92)
	helmet_mat.metallic = 0.30
	helmet_mat.roughness = 0.40
	helmet.material_override = helmet_mat
	helmet.position = Vector3(0, 1.45, 0)
	helmet.scale = Vector3(1.0, 0.85, 1.0)
	npc.add_child(helmet)
	# Small ice axe in hand
	var wood_mat: StandardMaterial3D = StandardMaterial3D.new()
	wood_mat.albedo_color = Color(0.45, 0.28, 0.12)
	wood_mat.roughness = 0.85
	var handle: MeshInstance3D = MeshInstance3D.new()
	var hmm: CylinderMesh = CylinderMesh.new()
	hmm.top_radius = 0.04
	hmm.bottom_radius = 0.05
	hmm.height = 0.85
	handle.mesh = hmm
	handle.material_override = wood_mat
	handle.position = Vector3(0.45, 0.85, 0.20)
	handle.rotation_degrees = Vector3(0, 0, -25)
	npc.add_child(handle)
	var pick: MeshInstance3D = MeshInstance3D.new()
	var pkm: PrismMesh = PrismMesh.new()
	pkm.size = Vector3(0.06, 0.10, 0.30)
	pick.mesh = pkm
	var steel_mat: StandardMaterial3D = StandardMaterial3D.new()
	steel_mat.albedo_color = Color(0.50, 0.55, 0.60)
	steel_mat.metallic = 0.85
	steel_mat.roughness = 0.30
	pick.material_override = steel_mat
	pick.position = Vector3(0.65, 1.20, 0.20)
	pick.rotation_degrees = Vector3(45, 0, 0)
	npc.add_child(pick)


func _build_d5_ice_maze(geom: Node) -> void:
	## Epic-5 T71: simple ice block maze — 5x5 grid pattern with some
	## blocks removed to form a winding path. Each block is a tall ice
	## cube with collision.
	var maze: Node3D = Node3D.new()
	maze.name = "IceMaze"
	maze.position = Vector3(D5_CENTER.x - 24.0, 0.0, 4.0)
	geom.add_child(maze)
	var ice_mat: StandardMaterial3D = StandardMaterial3D.new()
	ice_mat.albedo_color = Color(0.65, 0.85, 0.95, 0.85)
	ice_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	ice_mat.emission_enabled = true
	ice_mat.emission = Color(0.40, 0.85, 0.95)
	ice_mat.emission_energy_multiplier = 0.55
	ice_mat.metallic = 0.55
	ice_mat.roughness = 0.20
	# 5x5 grid layout (1 = block, 0 = empty path)
	var layout: Array = [
		[1, 1, 1, 1, 1],
		[1, 0, 0, 0, 1],
		[1, 0, 1, 0, 1],
		[1, 0, 0, 0, 0],
		[1, 1, 1, 1, 1],
	]
	for r in 5:
		for c in 5:
			if layout[r][c] == 1:
				var block: MeshInstance3D = MeshInstance3D.new()
				var bm: BoxMesh = BoxMesh.new()
				bm.size = Vector3(1.40, 1.85, 1.40)
				block.mesh = bm
				block.material_override = ice_mat
				block.position = Vector3(c * 1.50, 0.92, r * 1.50)
				maze.add_child(block)
				# Block collision
				var sb: StaticBody3D = StaticBody3D.new()
				sb.position = block.position
				var cs: CollisionShape3D = CollisionShape3D.new()
				var cb: BoxShape3D = BoxShape3D.new()
				cb.size = bm.size
				cs.shape = cb
				sb.add_child(cs)
				maze.add_child(sb)


func _build_d5_lost_wanderer_npc(town: Node) -> void:
	## Epic-5 T72: lost wanderer NPC inside the ice maze — looking
	## bewildered, holding a small lantern.
	var npc_slots: Node3D = town.get_node_or_null("%NPCSlots") as Node3D
	if npc_slots == null:
		return
	var slot: Marker3D = Marker3D.new()
	slot.name = "LostWandererSlot"
	slot.position = Vector3(D5_CENTER.x - 21.5, 0.0, 7.0)
	npc_slots.add_child(slot)
	var npc_scene: PackedScene = load("res://scenes/entities/npcs/VillagerR3.tscn") as PackedScene
	if npc_scene == null:
		return
	var npc: Node3D = npc_scene.instantiate() as Node3D
	npc.name = "LostWanderer"
	if "npc_name" in npc:
		npc.set("npc_name", "Misroute")
	if "npc_id" in npc:
		npc.set("npc_id", "wanderer_d5")
	slot.add_child(npc)
	# Tattered grey cloak
	var cloak: MeshInstance3D = MeshInstance3D.new()
	var cm: BoxMesh = BoxMesh.new()
	cm.size = Vector3(0.65, 1.10, 0.45)
	cloak.mesh = cm
	var cloak_mat: StandardMaterial3D = StandardMaterial3D.new()
	cloak_mat.albedo_color = Color(0.30, 0.32, 0.35)
	cloak_mat.roughness = 0.85
	cloak.material_override = cloak_mat
	cloak.position = Vector3(0, 0.55, 0)
	npc.add_child(cloak)
	# Hood
	var hood: MeshInstance3D = MeshInstance3D.new()
	var hm: SphereMesh = SphereMesh.new()
	hm.radius = 0.22
	hm.height = 0.40
	hood.mesh = hm
	hood.material_override = cloak_mat
	hood.position = Vector3(0, 1.45, 0)
	npc.add_child(hood)
	# Held lantern (small box with glowing core)
	var lantern: MeshInstance3D = MeshInstance3D.new()
	var lmm: BoxMesh = BoxMesh.new()
	lmm.size = Vector3(0.20, 0.30, 0.20)
	lantern.mesh = lmm
	var lantern_mat: StandardMaterial3D = StandardMaterial3D.new()
	lantern_mat.albedo_color = Color(0.30, 0.35, 0.40)
	lantern_mat.metallic = 0.65
	lantern_mat.roughness = 0.45
	lantern.material_override = lantern_mat
	lantern.position = Vector3(0.45, 0.85, 0.20)
	npc.add_child(lantern)
	var glow: MeshInstance3D = MeshInstance3D.new()
	var gm: SphereMesh = SphereMesh.new()
	gm.radius = 0.10
	gm.height = 0.18
	glow.mesh = gm
	var glow_mat: StandardMaterial3D = StandardMaterial3D.new()
	glow_mat.albedo_color = Color(1.0, 0.85, 0.30)
	glow_mat.emission_enabled = true
	glow_mat.emission = Color(1.0, 0.75, 0.20)
	glow_mat.emission_energy_multiplier = 3.5
	glow_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	glow.material_override = glow_mat
	glow.position = Vector3(0.45, 0.85, 0.20)
	npc.add_child(glow)
	# Lantern light
	var light: OmniLight3D = OmniLight3D.new()
	light.light_color = Color(1.0, 0.75, 0.30)
	light.light_energy = 1.6
	light.omni_range = 3.5
	light.position = Vector3(0.45, 0.85, 0.20)
	npc.add_child(light)


func _build_d5_glacial_chess(geom: Node) -> void:
	## Epic-5 T73: giant ice chess set on a checkerboard floor — 8x8
	## board pattern with 4 large ice chess pieces (king, queen, rook, knight).
	var chess: Node3D = Node3D.new()
	chess.name = "GlacialChess"
	chess.position = Vector3(D5_CENTER.x + 26.0, 0.0, -10.0)
	geom.add_child(chess)
	var light_mat: StandardMaterial3D = StandardMaterial3D.new()
	light_mat.albedo_color = Color(0.92, 0.96, 1.0)
	light_mat.emission_enabled = true
	light_mat.emission = Color(0.85, 0.95, 1.0)
	light_mat.emission_energy_multiplier = 0.45
	light_mat.roughness = 0.55
	var dark_mat: StandardMaterial3D = StandardMaterial3D.new()
	dark_mat.albedo_color = Color(0.20, 0.30, 0.40)
	dark_mat.emission_enabled = true
	dark_mat.emission = Color(0.15, 0.25, 0.35)
	dark_mat.emission_energy_multiplier = 0.25
	dark_mat.roughness = 0.55
	# 8x8 checkerboard tiles
	for r in 8:
		for c in 8:
			var tile: MeshInstance3D = MeshInstance3D.new()
			var tm: BoxMesh = BoxMesh.new()
			tm.size = Vector3(0.85, 0.10, 0.85)
			tile.mesh = tm
			tile.material_override = light_mat if (r + c) % 2 == 0 else dark_mat
			tile.position = Vector3(c * 0.85 - 3.0, 0.05, r * 0.85 - 3.0)
			chess.add_child(tile)
	# 4 large chess pieces (all light material to keep it simple)
	# Piece scale ~2x normal so they read as monumental
	var ice_mat: StandardMaterial3D = StandardMaterial3D.new()
	ice_mat.albedo_color = Color(0.78, 0.92, 1.0, 0.92)
	ice_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	ice_mat.emission_enabled = true
	ice_mat.emission = Color(0.55, 0.85, 1.0)
	ice_mat.emission_energy_multiplier = 0.65
	ice_mat.metallic = 0.55
	ice_mat.roughness = 0.10
	# King — tall central column with cross top
	var king: Node3D = Node3D.new()
	king.position = Vector3(-1.30, 0.10, -1.30)
	chess.add_child(king)
	var k_body: MeshInstance3D = MeshInstance3D.new()
	var kbm: CylinderMesh = CylinderMesh.new()
	kbm.top_radius = 0.18
	kbm.bottom_radius = 0.30
	kbm.height = 1.65
	k_body.mesh = kbm
	k_body.material_override = ice_mat
	k_body.position = Vector3(0, 0.85, 0)
	king.add_child(k_body)
	var k_head: MeshInstance3D = MeshInstance3D.new()
	var khm: SphereMesh = SphereMesh.new()
	khm.radius = 0.22
	khm.height = 0.40
	k_head.mesh = khm
	k_head.material_override = ice_mat
	k_head.position = Vector3(0, 1.85, 0)
	king.add_child(k_head)
	# Cross on top
	for axis in 2:
		var bar: MeshInstance3D = MeshInstance3D.new()
		var brm: BoxMesh = BoxMesh.new()
		brm.size = Vector3(0.25, 0.04, 0.04) if axis == 0 else Vector3(0.04, 0.25, 0.04)
		bar.mesh = brm
		bar.material_override = ice_mat
		bar.position = Vector3(0, 2.20, 0)
		king.add_child(bar)
	# King collision
	var ksb: StaticBody3D = StaticBody3D.new()
	ksb.position = Vector3(-1.30, 1.10, -1.30)
	var kcs: CollisionShape3D = CollisionShape3D.new()
	var kcap: CapsuleShape3D = CapsuleShape3D.new()
	kcap.radius = 0.30
	kcap.height = 2.20
	kcs.shape = kcap
	ksb.add_child(kcs)
	chess.add_child(ksb)
	# Queen — slim column with crown
	var queen: Node3D = Node3D.new()
	queen.position = Vector3(0.0, 0.10, -1.30)
	chess.add_child(queen)
	var q_body: MeshInstance3D = MeshInstance3D.new()
	var qbm: CylinderMesh = CylinderMesh.new()
	qbm.top_radius = 0.16
	qbm.bottom_radius = 0.28
	qbm.height = 1.55
	q_body.mesh = qbm
	q_body.material_override = ice_mat
	q_body.position = Vector3(0, 0.80, 0)
	queen.add_child(q_body)
	var q_head: MeshInstance3D = MeshInstance3D.new()
	var qhm: SphereMesh = SphereMesh.new()
	qhm.radius = 0.20
	qhm.height = 0.36
	q_head.mesh = qhm
	q_head.material_override = ice_mat
	q_head.position = Vector3(0, 1.75, 0)
	queen.add_child(q_head)
	# 5 crown spikes
	for i in 5:
		var ang: float = (TAU / 5.0) * i
		var spike: MeshInstance3D = MeshInstance3D.new()
		var spm: PrismMesh = PrismMesh.new()
		spm.size = Vector3(0.05, 0.18, 0.05)
		spike.mesh = spm
		spike.material_override = ice_mat
		spike.position = Vector3(cos(ang) * 0.18, 1.95, sin(ang) * 0.18)
		queen.add_child(spike)
	var qsb: StaticBody3D = StaticBody3D.new()
	qsb.position = Vector3(0, 1.10, -1.30)
	var qcs: CollisionShape3D = CollisionShape3D.new()
	var qcap: CapsuleShape3D = CapsuleShape3D.new()
	qcap.radius = 0.28
	qcap.height = 2.10
	qcs.shape = qcap
	qsb.add_child(qcs)
	chess.add_child(qsb)
	# Rook — square fortress on a column
	var rook: Node3D = Node3D.new()
	rook.position = Vector3(1.30, 0.10, -1.30)
	chess.add_child(rook)
	var r_body: MeshInstance3D = MeshInstance3D.new()
	var rbm: CylinderMesh = CylinderMesh.new()
	rbm.top_radius = 0.22
	rbm.bottom_radius = 0.30
	rbm.height = 1.40
	r_body.mesh = rbm
	r_body.material_override = ice_mat
	r_body.position = Vector3(0, 0.72, 0)
	rook.add_child(r_body)
	# Crenellated top
	var top: MeshInstance3D = MeshInstance3D.new()
	var tm2: BoxMesh = BoxMesh.new()
	tm2.size = Vector3(0.55, 0.30, 0.55)
	top.mesh = tm2
	top.material_override = ice_mat
	top.position = Vector3(0, 1.55, 0)
	rook.add_child(top)
	for cx in [-0.20, 0.20]:
		for cz in [-0.20, 0.20]:
			var cren: MeshInstance3D = MeshInstance3D.new()
			var cmm2: BoxMesh = BoxMesh.new()
			cmm2.size = Vector3(0.10, 0.18, 0.10)
			cren.mesh = cmm2
			cren.material_override = ice_mat
			cren.position = Vector3(cx, 1.85, cz)
			rook.add_child(cren)
	var rsb: StaticBody3D = StaticBody3D.new()
	rsb.position = Vector3(1.30, 1.0, -1.30)
	var rcs: CollisionShape3D = CollisionShape3D.new()
	var rcap: CapsuleShape3D = CapsuleShape3D.new()
	rcap.radius = 0.30
	rcap.height = 2.0
	rcs.shape = rcap
	rsb.add_child(rcs)
	chess.add_child(rsb)
	# Knight — angular horse-head shape
	var knight: Node3D = Node3D.new()
	knight.position = Vector3(2.55, 0.10, -1.30)
	chess.add_child(knight)
	var n_body: MeshInstance3D = MeshInstance3D.new()
	var nbm: CylinderMesh = CylinderMesh.new()
	nbm.top_radius = 0.22
	nbm.bottom_radius = 0.30
	nbm.height = 1.10
	n_body.mesh = nbm
	n_body.material_override = ice_mat
	n_body.position = Vector3(0, 0.55, 0)
	knight.add_child(n_body)
	# Horse head (angled prism)
	var n_head: MeshInstance3D = MeshInstance3D.new()
	var nhm: PrismMesh = PrismMesh.new()
	nhm.size = Vector3(0.40, 0.85, 0.30)
	n_head.mesh = nhm
	n_head.material_override = ice_mat
	n_head.position = Vector3(0.10, 1.55, 0)
	n_head.rotation_degrees = Vector3(0, 0, -25)
	knight.add_child(n_head)
	var nsb: StaticBody3D = StaticBody3D.new()
	nsb.position = Vector3(2.55, 1.0, -1.30)
	var ncs: CollisionShape3D = CollisionShape3D.new()
	var ncap: CapsuleShape3D = CapsuleShape3D.new()
	ncap.radius = 0.30
	ncap.height = 2.0
	ncs.shape = ncap
	nsb.add_child(ncs)
	chess.add_child(nsb)


func _build_d5_chess_player_npc(town: Node) -> void:
	## Epic-5 T74: chess player NPC pondering the board — chin in hand pose,
	## scholarly grey beard hint via colored hood.
	var npc_slots: Node3D = town.get_node_or_null("%NPCSlots") as Node3D
	if npc_slots == null:
		return
	var slot: Marker3D = Marker3D.new()
	slot.name = "ChessPlayerSlot"
	slot.position = Vector3(D5_CENTER.x + 26.0, 0.0, -6.5)
	npc_slots.add_child(slot)
	var npc_scene: PackedScene = load("res://scenes/entities/npcs/VillagerR3.tscn") as PackedScene
	if npc_scene == null:
		return
	var npc: Node3D = npc_scene.instantiate() as Node3D
	npc.name = "ChessPlayer"
	if "npc_name" in npc:
		npc.set("npc_name", "Endgame")
	if "npc_id" in npc:
		npc.set("npc_id", "chess_d5")
	slot.add_child(npc)
	# Long dark robe
	var robe: MeshInstance3D = MeshInstance3D.new()
	var rm: BoxMesh = BoxMesh.new()
	rm.size = Vector3(0.65, 1.10, 0.40)
	robe.mesh = rm
	var robe_mat: StandardMaterial3D = StandardMaterial3D.new()
	robe_mat.albedo_color = Color(0.20, 0.18, 0.30)
	robe_mat.roughness = 0.85
	robe.material_override = robe_mat
	robe.position = Vector3(0, 0.55, 0)
	npc.add_child(robe)
	# Grey beard hint (small grey sphere under chin)
	var beard: MeshInstance3D = MeshInstance3D.new()
	var bm: SphereMesh = SphereMesh.new()
	bm.radius = 0.14
	bm.height = 0.24
	beard.mesh = bm
	var beard_mat: StandardMaterial3D = StandardMaterial3D.new()
	beard_mat.albedo_color = Color(0.85, 0.85, 0.82)
	beard_mat.roughness = 0.95
	beard.material_override = beard_mat
	beard.position = Vector3(0, 1.20, 0.15)
	beard.scale = Vector3(0.85, 0.55, 0.55)
	npc.add_child(beard)
	# Pondering hand (small sphere near chin)
	var hand: MeshInstance3D = MeshInstance3D.new()
	var hmm: SphereMesh = SphereMesh.new()
	hmm.radius = 0.08
	hmm.height = 0.14
	hand.mesh = hmm
	var skin_mat: StandardMaterial3D = StandardMaterial3D.new()
	skin_mat.albedo_color = Color(0.95, 0.85, 0.75)
	skin_mat.roughness = 0.65
	hand.material_override = skin_mat
	hand.position = Vector3(0.12, 1.30, 0.18)
	npc.add_child(hand)


func _build_d5_crystal_cluster(geom: Node) -> void:
	## Epic-5 T75: large data crystal cluster landmark — central tall crystal
	## surrounded by 6 smaller satellite crystals + an aura beam.
	var cluster: Node3D = Node3D.new()
	cluster.name = "DataCrystalCluster"
	cluster.position = Vector3(D5_CENTER.x - 14.0, 0.0, -22.0)
	geom.add_child(cluster)
	var crystal_mat: StandardMaterial3D = StandardMaterial3D.new()
	crystal_mat.albedo_color = Color(0.40, 0.85, 1.0)
	crystal_mat.emission_enabled = true
	crystal_mat.emission = Color(0.30, 0.95, 1.0)
	crystal_mat.emission_energy_multiplier = 1.6
	crystal_mat.metallic = 0.55
	crystal_mat.roughness = 0.10
	crystal_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	# Stone base
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.45, 0.50, 0.55)
	stone_mat.roughness = 0.92
	var base: MeshInstance3D = MeshInstance3D.new()
	var bm: CylinderMesh = CylinderMesh.new()
	bm.top_radius = 1.85
	bm.bottom_radius = 2.10
	bm.height = 0.40
	base.mesh = bm
	base.material_override = stone_mat
	base.position = Vector3(0, 0.20, 0)
	cluster.add_child(base)
	# Central tall crystal
	var central: MeshInstance3D = MeshInstance3D.new()
	var cmm: PrismMesh = PrismMesh.new()
	cmm.size = Vector3(1.10, 4.85, 1.10)
	central.mesh = cmm
	central.material_override = crystal_mat
	central.position = Vector3(0, 2.85, 0)
	cluster.add_child(central)
	# 6 satellite crystals around the central one
	for i in 6:
		var ang: float = (TAU / 6.0) * i
		var sat: MeshInstance3D = MeshInstance3D.new()
		var sm: PrismMesh = PrismMesh.new()
		sm.size = Vector3(0.55, 2.40 + randf() * 0.85, 0.55)
		sat.mesh = sm
		sat.material_override = crystal_mat
		sat.position = Vector3(cos(ang) * 1.40, 1.65, sin(ang) * 1.40)
		sat.rotation_degrees = Vector3(15 * cos(ang), 0, 15 * sin(ang))
		cluster.add_child(sat)
	# Aura beam
	var beam: MeshInstance3D = MeshInstance3D.new()
	var beam_m: CylinderMesh = CylinderMesh.new()
	beam_m.top_radius = 0.10
	beam_m.bottom_radius = 0.55
	beam_m.height = 11.0
	beam.mesh = beam_m
	var beam_mat: StandardMaterial3D = StandardMaterial3D.new()
	beam_mat.albedo_color = Color(0.40, 0.95, 1.0, 0.45)
	beam_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	beam_mat.emission_enabled = true
	beam_mat.emission = Color(0.30, 0.95, 1.0)
	beam_mat.emission_energy_multiplier = 1.4
	beam_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	beam.material_override = beam_mat
	beam.position = Vector3(0, 9.85, 0)
	cluster.add_child(beam)
	# Pulse beam
	var tw: Tween = beam.create_tween().set_loops()
	tw.tween_property(beam, "scale:x", 1.30, 1.6)
	tw.tween_property(beam, "scale:x", 0.85, 1.6)
	# Aura light
	var light: OmniLight3D = OmniLight3D.new()
	light.light_color = Color(0.40, 0.95, 1.0)
	light.light_energy = 4.5
	light.omni_range = 14.0
	light.position = Vector3(0, 4.20, 0)
	cluster.add_child(light)
	# Base collision
	var sb: StaticBody3D = StaticBody3D.new()
	sb.position = Vector3(0, 0.20, 0)
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cap: CylinderShape3D = CylinderShape3D.new()
	cap.radius = 2.10
	cap.height = 0.40
	cs.shape = cap
	sb.add_child(cs)
	cluster.add_child(sb)


func _build_d5_snow_globe(geom: Node) -> void:
	## Epic-5 T76: giant snow globe sculpture — wooden base + huge clear
	## glass sphere containing a tiny ice village (3 huts) and slow GPU
	## "snow inside the globe" particles.
	var globe: Node3D = Node3D.new()
	globe.name = "SnowGlobeSculpture"
	globe.position = Vector3(D5_CENTER.x + 0.0, 0.0, 8.0)
	geom.add_child(globe)
	# Wooden base
	var wood_mat: StandardMaterial3D = StandardMaterial3D.new()
	wood_mat.albedo_color = Color(0.45, 0.28, 0.12)
	wood_mat.roughness = 0.85
	var base: MeshInstance3D = MeshInstance3D.new()
	var bm: CylinderMesh = CylinderMesh.new()
	bm.top_radius = 1.65
	bm.bottom_radius = 1.85
	bm.height = 0.65
	base.mesh = bm
	base.material_override = wood_mat
	base.position = Vector3(0, 0.32, 0)
	globe.add_child(base)
	# Glass sphere
	var glass: MeshInstance3D = MeshInstance3D.new()
	var gm: SphereMesh = SphereMesh.new()
	gm.radius = 1.85
	gm.height = 3.70
	glass.mesh = gm
	var glass_mat: StandardMaterial3D = StandardMaterial3D.new()
	glass_mat.albedo_color = Color(0.85, 0.95, 1.0, 0.30)
	glass_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	glass_mat.emission_enabled = true
	glass_mat.emission = Color(0.65, 0.85, 1.0)
	glass_mat.emission_energy_multiplier = 0.45
	glass_mat.metallic = 0.55
	glass_mat.roughness = 0.05
	glass.material_override = glass_mat
	glass.position = Vector3(0, 2.50, 0)
	globe.add_child(glass)
	# 3 tiny huts inside
	var hut_wood_mat: StandardMaterial3D = StandardMaterial3D.new()
	hut_wood_mat.albedo_color = Color(0.55, 0.35, 0.18)
	hut_wood_mat.roughness = 0.85
	var hut_roof_mat: StandardMaterial3D = StandardMaterial3D.new()
	hut_roof_mat.albedo_color = Color(0.30, 0.18, 0.10)
	hut_roof_mat.roughness = 0.85
	var hut_positions: Array = [
		Vector3( 0.0, 0,  0.0),
		Vector3( 0.55, 0, -0.45),
		Vector3(-0.50, 0,  0.45),
	]
	for pos in hut_positions:
		var body: MeshInstance3D = MeshInstance3D.new()
		var bbm: BoxMesh = BoxMesh.new()
		bbm.size = Vector3(0.40, 0.30, 0.40)
		body.mesh = bbm
		body.material_override = hut_wood_mat
		body.position = Vector3(pos.x, 1.95 + 0.15, pos.z)
		globe.add_child(body)
		var roof: MeshInstance3D = MeshInstance3D.new()
		var rm: PrismMesh = PrismMesh.new()
		rm.size = Vector3(0.50, 0.20, 0.45)
		roof.mesh = rm
		roof.material_override = hut_roof_mat
		roof.position = Vector3(pos.x, 1.95 + 0.40, pos.z)
		globe.add_child(roof)
	# Tiny snow particles inside the globe
	var snow: GPUParticles3D = GPUParticles3D.new()
	snow.amount = 40
	snow.lifetime = 5.0
	snow.preprocess = 3.0
	snow.position = Vector3(0, 3.85, 0)
	snow.visibility_aabb = AABB(Vector3(-2, -3, -2), Vector3(4, 4, 4))
	var pm: ParticleProcessMaterial = ParticleProcessMaterial.new()
	pm.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	pm.emission_sphere_radius = 1.65
	pm.direction = Vector3(0, -1, 0)
	pm.spread = 35.0
	pm.gravity = Vector3(0, -0.18, 0)
	pm.initial_velocity_min = 0.05
	pm.initial_velocity_max = 0.20
	pm.scale_min = 0.04
	pm.scale_max = 0.08
	pm.color = Color(0.95, 0.97, 1.0)
	snow.process_material = pm
	var flake_mesh: SphereMesh = SphereMesh.new()
	flake_mesh.radius = 0.04
	flake_mesh.height = 0.08
	snow.draw_pass_1 = flake_mesh
	var fmat: StandardMaterial3D = StandardMaterial3D.new()
	fmat.albedo_color = Color(0.95, 0.97, 1.0)
	fmat.emission_enabled = true
	fmat.emission = Color(0.85, 0.95, 1.0)
	fmat.emission_energy_multiplier = 1.4
	fmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	flake_mesh.material = fmat
	globe.add_child(snow)
	# Soft glow light inside
	var light: OmniLight3D = OmniLight3D.new()
	light.light_color = Color(0.55, 0.85, 1.0)
	light.light_energy = 2.5
	light.omni_range = 5.5
	light.position = Vector3(0, 2.50, 0)
	globe.add_child(light)
	# Base collision
	var sb: StaticBody3D = StaticBody3D.new()
	sb.position = Vector3(0, 2.10, 0)
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cap: SphereShape3D = SphereShape3D.new()
	cap.radius = 1.85
	cs.shape = cap
	sb.add_child(cs)
	globe.add_child(sb)


func _build_d5_cellist_npc(town: Node) -> void:
	## Epic-5 T77: cellist musician NPC playing an ice cello at the cocoa
	## stand area. Brown formal jacket + bowing motion.
	var npc_slots: Node3D = town.get_node_or_null("%NPCSlots") as Node3D
	if npc_slots == null:
		return
	var slot: Marker3D = Marker3D.new()
	slot.name = "CellistSlot"
	slot.position = Vector3(D5_CENTER.x + 2.0, 0.0, 14.0)
	npc_slots.add_child(slot)
	var npc_scene: PackedScene = load("res://scenes/entities/npcs/VillagerR3.tscn") as PackedScene
	if npc_scene == null:
		return
	var npc: Node3D = npc_scene.instantiate() as Node3D
	npc.name = "Cellist"
	if "npc_name" in npc:
		npc.set("npc_name", "Adagio")
	if "npc_id" in npc:
		npc.set("npc_id", "cellist_d5")
	slot.add_child(npc)
	# Brown formal jacket
	var jacket: MeshInstance3D = MeshInstance3D.new()
	var jm: BoxMesh = BoxMesh.new()
	jm.size = Vector3(0.65, 1.05, 0.40)
	jacket.mesh = jm
	var jacket_mat: StandardMaterial3D = StandardMaterial3D.new()
	jacket_mat.albedo_color = Color(0.45, 0.28, 0.12)
	jacket_mat.roughness = 0.65
	jacket.material_override = jacket_mat
	jacket.position = Vector3(0, 0.55, 0)
	npc.add_child(jacket)
	# Ice cello body (large translucent prism in front of NPC)
	var ice_mat: StandardMaterial3D = StandardMaterial3D.new()
	ice_mat.albedo_color = Color(0.65, 0.85, 0.95, 0.85)
	ice_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	ice_mat.emission_enabled = true
	ice_mat.emission = Color(0.40, 0.85, 0.95)
	ice_mat.emission_energy_multiplier = 0.85
	ice_mat.metallic = 0.55
	ice_mat.roughness = 0.10
	var cello: MeshInstance3D = MeshInstance3D.new()
	var cbm: BoxMesh = BoxMesh.new()
	cbm.size = Vector3(0.55, 1.20, 0.20)
	cello.mesh = cbm
	cello.material_override = ice_mat
	cello.position = Vector3(0, 0.85, 0.42)
	cello.scale = Vector3(1.0, 1.0, 0.85)
	npc.add_child(cello)
	# Cello neck (thin vertical cylinder above body)
	var neck: MeshInstance3D = MeshInstance3D.new()
	var nm: CylinderMesh = CylinderMesh.new()
	nm.top_radius = 0.04
	nm.bottom_radius = 0.05
	nm.height = 0.85
	neck.mesh = nm
	neck.material_override = ice_mat
	neck.position = Vector3(0, 1.85, 0.42)
	npc.add_child(neck)
	# Bow (long thin wooden cylinder + horsehair line)
	var wood_mat: StandardMaterial3D = StandardMaterial3D.new()
	wood_mat.albedo_color = Color(0.45, 0.28, 0.12)
	wood_mat.roughness = 0.85
	var bow: MeshInstance3D = MeshInstance3D.new()
	var bow_m: CylinderMesh = CylinderMesh.new()
	bow_m.top_radius = 0.02
	bow_m.bottom_radius = 0.03
	bow_m.height = 0.85
	bow.mesh = bow_m
	bow.material_override = wood_mat
	bow.position = Vector3(0.35, 0.85, 0.55)
	bow.rotation_degrees = Vector3(0, 0, 90)
	npc.add_child(bow)
	# Bow stroke tween (back and forth motion)
	var tw: Tween = bow.create_tween().set_loops()
	tw.tween_property(bow, "position:x", 0.65, 0.55)
	tw.tween_property(bow, "position:x", 0.05, 0.55)
	# 4 musical note glows floating up from the cello
	var note_mat: StandardMaterial3D = StandardMaterial3D.new()
	note_mat.albedo_color = Color(0.85, 0.55, 0.95)
	note_mat.emission_enabled = true
	note_mat.emission = Color(0.85, 0.45, 0.95)
	note_mat.emission_energy_multiplier = 2.5
	note_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for i in 4:
		var note: MeshInstance3D = MeshInstance3D.new()
		var nm2: SphereMesh = SphereMesh.new()
		nm2.radius = 0.06
		nm2.height = 0.12
		note.mesh = nm2
		note.material_override = note_mat
		note.position = Vector3(randf_range(-0.20, 0.20), 1.85 + i * 0.30, 0.55)
		npc.add_child(note)
		# Float up and fade
		var tn: Tween = note.create_tween().set_loops()
		tn.tween_interval(i * 0.40)
		tn.tween_property(note, "position:y", 3.20, 1.85)
		tn.tween_property(note, "position:y", 1.85, 0.0)


func _build_d5_frosted_lamps(geom: Node) -> void:
	## Epic-5 T78: 6 frosted lamp posts in a row leading toward the warden,
	## warm white glow contrasting with the cold cyan district lights.
	var lamps: Node3D = Node3D.new()
	lamps.name = "FrostedLamps"
	lamps.position = Vector3(D5_CENTER.x - 12.0, 0.0, -2.0)
	geom.add_child(lamps)
	var metal_mat: StandardMaterial3D = StandardMaterial3D.new()
	metal_mat.albedo_color = Color(0.30, 0.32, 0.35)
	metal_mat.metallic = 0.85
	metal_mat.roughness = 0.30
	var glass_mat: StandardMaterial3D = StandardMaterial3D.new()
	glass_mat.albedo_color = Color(0.95, 0.92, 0.85, 0.85)
	glass_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	glass_mat.emission_enabled = true
	glass_mat.emission = Color(1.0, 0.92, 0.75)
	glass_mat.emission_energy_multiplier = 2.5
	glass_mat.metallic = 0.30
	glass_mat.roughness = 0.10
	for i in 6:
		var lamp: Node3D = Node3D.new()
		lamp.position = Vector3(i * 2.40, 0, 0)
		lamps.add_child(lamp)
		# Tall metal post
		var post: MeshInstance3D = MeshInstance3D.new()
		var pm: CylinderMesh = CylinderMesh.new()
		pm.top_radius = 0.06
		pm.bottom_radius = 0.10
		pm.height = 2.85
		post.mesh = pm
		post.material_override = metal_mat
		post.position = Vector3(0, 1.42, 0)
		lamp.add_child(post)
		# Top arm (horizontal small cylinder)
		var arm: MeshInstance3D = MeshInstance3D.new()
		var am: CylinderMesh = CylinderMesh.new()
		am.top_radius = 0.05
		am.bottom_radius = 0.05
		am.height = 0.40
		arm.mesh = am
		arm.material_override = metal_mat
		arm.position = Vector3(0.20, 2.85, 0)
		arm.rotation_degrees = Vector3(0, 0, 90)
		lamp.add_child(arm)
		# Lamp head (frosted glass sphere)
		var head: MeshInstance3D = MeshInstance3D.new()
		var hm: SphereMesh = SphereMesh.new()
		hm.radius = 0.20
		hm.height = 0.36
		head.mesh = hm
		head.material_override = glass_mat
		head.position = Vector3(0.40, 2.65, 0)
		lamp.add_child(head)
		# Cone-shaped frost cap on top of head
		var cap: MeshInstance3D = MeshInstance3D.new()
		var cmm: PrismMesh = PrismMesh.new()
		cmm.size = Vector3(0.30, 0.18, 0.30)
		cap.mesh = cmm
		cap.material_override = metal_mat
		cap.position = Vector3(0.40, 2.92, 0)
		lamp.add_child(cap)
		# Light
		var light: OmniLight3D = OmniLight3D.new()
		light.light_color = Color(1.0, 0.92, 0.75)
		light.light_energy = 1.4
		light.omni_range = 4.0
		light.position = Vector3(0.40, 2.65, 0)
		lamp.add_child(light)
		# Subtle pulse offset per lamp
		var tw: Tween = light.create_tween().set_loops()
		tw.tween_interval(i * 0.20)
		tw.tween_property(light, "light_energy", 1.85, 1.0)
		tw.tween_property(light, "light_energy", 1.4, 1.0)
		# Post collision
		var sb: StaticBody3D = StaticBody3D.new()
		sb.position = Vector3(0, 1.42, 0)
		var cs: CollisionShape3D = CollisionShape3D.new()
		var capshape: CapsuleShape3D = CapsuleShape3D.new()
		capshape.radius = 0.10
		capshape.height = 2.85
		cs.shape = capshape
		sb.add_child(cs)
		lamp.add_child(sb)


func _build_d5_arctic_owl(geom: Node) -> void:
	## Epic-5 T79: small arctic owl perched on a high crystal — white
	## body, bright golden eyes, slow head turn animation.
	var owl: Node3D = Node3D.new()
	owl.name = "ArcticOwl"
	owl.position = Vector3(D5_CENTER.x - 10.0, 0.0, -22.0)
	geom.add_child(owl)
	# Perch crystal (small ice prism)
	var ice_mat: StandardMaterial3D = StandardMaterial3D.new()
	ice_mat.albedo_color = Color(0.65, 0.85, 0.95, 0.92)
	ice_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	ice_mat.emission_enabled = true
	ice_mat.emission = Color(0.40, 0.85, 0.95)
	ice_mat.emission_energy_multiplier = 0.55
	ice_mat.metallic = 0.55
	ice_mat.roughness = 0.20
	var perch: MeshInstance3D = MeshInstance3D.new()
	var pmm: PrismMesh = PrismMesh.new()
	pmm.size = Vector3(0.45, 1.85, 0.45)
	perch.mesh = pmm
	perch.material_override = ice_mat
	perch.position = Vector3(0, 0.92, 0)
	owl.add_child(perch)
	# Owl body (round white sphere)
	var fur_mat: StandardMaterial3D = StandardMaterial3D.new()
	fur_mat.albedo_color = Color(0.95, 0.97, 1.0)
	fur_mat.roughness = 0.85
	fur_mat.emission_enabled = true
	fur_mat.emission = Color(0.85, 0.92, 1.0)
	fur_mat.emission_energy_multiplier = 0.20
	var owl_pivot: Node3D = Node3D.new()
	owl_pivot.position = Vector3(0, 2.10, 0)
	owl.add_child(owl_pivot)
	var body: MeshInstance3D = MeshInstance3D.new()
	var bm: SphereMesh = SphereMesh.new()
	bm.radius = 0.30
	bm.height = 0.55
	body.mesh = bm
	body.material_override = fur_mat
	body.position = Vector3(0, 0, 0)
	body.scale = Vector3(0.95, 1.10, 0.85)
	owl_pivot.add_child(body)
	# 2 large golden eyes
	var eye_mat: StandardMaterial3D = StandardMaterial3D.new()
	eye_mat.albedo_color = Color(1.0, 0.85, 0.20)
	eye_mat.emission_enabled = true
	eye_mat.emission = Color(1.0, 0.85, 0.20)
	eye_mat.emission_energy_multiplier = 3.5
	eye_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for ex in [-0.10, 0.10]:
		var eye: MeshInstance3D = MeshInstance3D.new()
		var em: SphereMesh = SphereMesh.new()
		em.radius = 0.07
		em.height = 0.14
		eye.mesh = em
		eye.material_override = eye_mat
		eye.position = Vector3(ex, 0.10, 0.22)
		owl_pivot.add_child(eye)
		# Eye black pupil
		var pupil: MeshInstance3D = MeshInstance3D.new()
		var pmesh: SphereMesh = SphereMesh.new()
		pmesh.radius = 0.025
		pmesh.height = 0.05
		pupil.mesh = pmesh
		var pupil_mat: StandardMaterial3D = StandardMaterial3D.new()
		pupil_mat.albedo_color = Color(0.05, 0.05, 0.05)
		pupil_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		pupil.material_override = pupil_mat
		pupil.position = Vector3(ex, 0.10, 0.28)
		owl_pivot.add_child(pupil)
	# Beak
	var beak: MeshInstance3D = MeshInstance3D.new()
	var bkm: PrismMesh = PrismMesh.new()
	bkm.size = Vector3(0.06, 0.10, 0.10)
	beak.mesh = bkm
	var beak_mat: StandardMaterial3D = StandardMaterial3D.new()
	beak_mat.albedo_color = Color(0.95, 0.65, 0.10)
	beak.material_override = beak_mat
	beak.position = Vector3(0, 0.02, 0.28)
	beak.rotation_degrees = Vector3(180, 0, 0)
	owl_pivot.add_child(beak)
	# Slow head turn (owl)
	var tw: Tween = owl_pivot.create_tween().set_loops()
	tw.tween_property(owl_pivot, "rotation_degrees:y", 90.0, 2.5)
	tw.tween_interval(1.5)
	tw.tween_property(owl_pivot, "rotation_degrees:y", -90.0, 2.5)
	tw.tween_interval(1.5)
	tw.tween_property(owl_pivot, "rotation_degrees:y", 0.0, 0.5)
	# Perch collision
	var sb: StaticBody3D = StaticBody3D.new()
	sb.position = Vector3(0, 0.92, 0)
	var cs: CollisionShape3D = CollisionShape3D.new()
	var capsh: CapsuleShape3D = CapsuleShape3D.new()
	capsh.radius = 0.30
	capsh.height = 1.85
	cs.shape = capsh
	sb.add_child(cs)
	owl.add_child(sb)


func _build_d5_rune_ring(geom: Node) -> void:
	## Epic-5 T80: ring of 9 small rune stones — short ice pillars in a
	## perfect circle, each carved with a glowing cyan symbol.
	var ring: Node3D = Node3D.new()
	ring.name = "IceRuneRing"
	ring.position = Vector3(D5_CENTER.x - 14.0, 0.0, -2.0)
	geom.add_child(ring)
	var ice_mat: StandardMaterial3D = StandardMaterial3D.new()
	ice_mat.albedo_color = Color(0.65, 0.85, 0.95, 0.92)
	ice_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	ice_mat.emission_enabled = true
	ice_mat.emission = Color(0.40, 0.85, 0.95)
	ice_mat.emission_energy_multiplier = 0.55
	ice_mat.metallic = 0.55
	ice_mat.roughness = 0.20
	var rune_mat: StandardMaterial3D = StandardMaterial3D.new()
	rune_mat.albedo_color = Color(0.30, 0.95, 1.0)
	rune_mat.emission_enabled = true
	rune_mat.emission = Color(0.30, 1.0, 1.0)
	rune_mat.emission_energy_multiplier = 2.5
	rune_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for i in 9:
		var ang: float = (TAU / 9.0) * i
		var stone: Node3D = Node3D.new()
		stone.position = Vector3(cos(ang) * 3.40, 0, sin(ang) * 3.40)
		stone.rotation.y = -ang + PI * 0.5
		ring.add_child(stone)
		# Pillar
		var pillar: MeshInstance3D = MeshInstance3D.new()
		var pm: BoxMesh = BoxMesh.new()
		pm.size = Vector3(0.40, 1.40, 0.30)
		pillar.mesh = pm
		pillar.material_override = ice_mat
		pillar.position = Vector3(0, 0.70, 0)
		stone.add_child(pillar)
		# Rune carving
		var rune: MeshInstance3D = MeshInstance3D.new()
		var rm: BoxMesh = BoxMesh.new()
		rm.size = Vector3(0.18, 0.45, 0.04)
		rune.mesh = rm
		rune.material_override = rune_mat
		rune.position = Vector3(0, 0.70, 0.18)
		stone.add_child(rune)
		# Pulse the rune
		var tw: Tween = rune.create_tween().set_loops()
		tw.tween_interval(i * 0.18)
		tw.tween_property(rune, "scale:y", 1.20, 0.85)
		tw.tween_property(rune, "scale:y", 0.85, 0.85)
		# Stone collision
		var sb: StaticBody3D = StaticBody3D.new()
		sb.position = Vector3(0, 0.70, 0)
		var cs: CollisionShape3D = CollisionShape3D.new()
		var cb: BoxShape3D = BoxShape3D.new()
		cb.size = Vector3(0.40, 1.40, 0.30)
		cs.shape = cb
		sb.add_child(cs)
		stone.add_child(sb)
	# Central low altar disc
	var altar: MeshInstance3D = MeshInstance3D.new()
	var am: CylinderMesh = CylinderMesh.new()
	am.top_radius = 0.85
	am.bottom_radius = 0.95
	am.height = 0.30
	altar.mesh = am
	altar.material_override = ice_mat
	altar.position = Vector3(0, 0.15, 0)
	ring.add_child(altar)
	# Center light
	var light: OmniLight3D = OmniLight3D.new()
	light.light_color = Color(0.40, 0.95, 1.0)
	light.light_energy = 2.0
	light.omni_range = 6.0
	light.position = Vector3(0, 0.55, 0)
	ring.add_child(light)


func _build_d5_ice_slide(geom: Node) -> void:
	## Epic-5 T81: tall ice slide — staircase up + curved slide down,
	## marking a recreation spot for the Cache citizens.
	var slide: Node3D = Node3D.new()
	slide.name = "IceSlide"
	slide.position = Vector3(D5_CENTER.x - 6.0, 0.0, 8.0)
	geom.add_child(slide)
	var ice_mat: StandardMaterial3D = StandardMaterial3D.new()
	ice_mat.albedo_color = Color(0.78, 0.92, 1.0)
	ice_mat.emission_enabled = true
	ice_mat.emission = Color(0.55, 0.85, 1.0)
	ice_mat.emission_energy_multiplier = 0.55
	ice_mat.roughness = 0.20
	# Tall ice tower (climb area)
	var tower: MeshInstance3D = MeshInstance3D.new()
	var twm: BoxMesh = BoxMesh.new()
	twm.size = Vector3(1.85, 3.40, 1.85)
	tower.mesh = twm
	tower.material_override = ice_mat
	tower.position = Vector3(0, 1.70, 0)
	slide.add_child(tower)
	# 4 ice stair steps on the back of the tower
	for i in 4:
		var step: MeshInstance3D = MeshInstance3D.new()
		var stm: BoxMesh = BoxMesh.new()
		stm.size = Vector3(1.85, 0.30, 0.55)
		step.mesh = stm
		step.material_override = ice_mat
		step.position = Vector3(0, 0.30 + i * 0.85, -1.20 - i * 0.55)
		slide.add_child(step)
	# Slide chute (5 angled segments forming a curving slide downward)
	for i in 5:
		var chute: MeshInstance3D = MeshInstance3D.new()
		var cmm: BoxMesh = BoxMesh.new()
		cmm.size = Vector3(1.10, 0.18, 1.30)
		chute.mesh = cmm
		chute.material_override = ice_mat
		var t: float = i / 4.0
		var sx: float = sin(t * PI * 0.5) * 2.40
		chute.position = Vector3(sx, 3.20 - t * 2.85, 1.20 + t * 0.85)
		chute.rotation_degrees = Vector3(15.0 + i * 5.0, t * 60.0, 0)
		slide.add_child(chute)
	# Slide side rails
	for sx in [-0.55, 0.55]:
		var rail: MeshInstance3D = MeshInstance3D.new()
		var rm: CylinderMesh = CylinderMesh.new()
		rm.top_radius = 0.05
		rm.bottom_radius = 0.05
		rm.height = 4.20
		rail.mesh = rm
		rail.material_override = ice_mat
		rail.position = Vector3(sx, 2.40, 1.85)
		rail.rotation_degrees = Vector3(35, 0, 0)
		slide.add_child(rail)
	# Tower collision
	var sb: StaticBody3D = StaticBody3D.new()
	sb.position = Vector3(0, 1.70, 0)
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(1.85, 3.40, 1.85)
	cs.shape = cb
	sb.add_child(cs)
	slide.add_child(sb)


func _build_d5_skating_instructor_npc(town: Node) -> void:
	## Epic-5 T82: skating instructor NPC near the rink — bright pink coat,
	## holding a clipboard with a small whistle around their neck.
	var npc_slots: Node3D = town.get_node_or_null("%NPCSlots") as Node3D
	if npc_slots == null:
		return
	var slot: Marker3D = Marker3D.new()
	slot.name = "SkatingInstructorSlot"
	slot.position = Vector3(D5_CENTER.x - 14.0, 0.0, -10.0)
	npc_slots.add_child(slot)
	var npc_scene: PackedScene = load("res://scenes/entities/npcs/VillagerR3.tscn") as PackedScene
	if npc_scene == null:
		return
	var npc: Node3D = npc_scene.instantiate() as Node3D
	npc.name = "SkatingInstructor"
	if "npc_name" in npc:
		npc.set("npc_name", "Glide")
	if "npc_id" in npc:
		npc.set("npc_id", "instructor_d5")
	slot.add_child(npc)
	# Pink coat
	var coat: MeshInstance3D = MeshInstance3D.new()
	var cm: BoxMesh = BoxMesh.new()
	cm.size = Vector3(0.65, 1.05, 0.45)
	coat.mesh = cm
	var coat_mat: StandardMaterial3D = StandardMaterial3D.new()
	coat_mat.albedo_color = Color(0.95, 0.45, 0.75)
	coat_mat.emission_enabled = true
	coat_mat.emission = Color(0.95, 0.30, 0.75)
	coat_mat.emission_energy_multiplier = 0.30
	coat_mat.roughness = 0.65
	coat.material_override = coat_mat
	coat.position = Vector3(0, 0.55, 0)
	npc.add_child(coat)
	# Clipboard
	var clipboard: MeshInstance3D = MeshInstance3D.new()
	var clm: BoxMesh = BoxMesh.new()
	clm.size = Vector3(0.30, 0.40, 0.04)
	clipboard.mesh = clm
	var board_mat: StandardMaterial3D = StandardMaterial3D.new()
	board_mat.albedo_color = Color(0.45, 0.28, 0.12)
	board_mat.roughness = 0.85
	clipboard.material_override = board_mat
	clipboard.position = Vector3(0.40, 0.85, 0.18)
	npc.add_child(clipboard)
	# Paper on clipboard
	var paper: MeshInstance3D = MeshInstance3D.new()
	var pm: BoxMesh = BoxMesh.new()
	pm.size = Vector3(0.27, 0.36, 0.02)
	paper.mesh = pm
	var paper_mat: StandardMaterial3D = StandardMaterial3D.new()
	paper_mat.albedo_color = Color(0.95, 0.95, 0.92)
	paper.material_override = paper_mat
	paper.position = Vector3(0.40, 0.85, 0.21)
	npc.add_child(paper)
	# Whistle (small silver cylinder hanging)
	var whistle: MeshInstance3D = MeshInstance3D.new()
	var wm: CylinderMesh = CylinderMesh.new()
	wm.top_radius = 0.03
	wm.bottom_radius = 0.03
	wm.height = 0.10
	whistle.mesh = wm
	var silver_mat: StandardMaterial3D = StandardMaterial3D.new()
	silver_mat.albedo_color = Color(0.85, 0.85, 0.92)
	silver_mat.metallic = 0.85
	silver_mat.roughness = 0.20
	whistle.material_override = silver_mat
	whistle.position = Vector3(0, 0.95, 0.22)
	whistle.rotation_degrees = Vector3(90, 0, 0)
	npc.add_child(whistle)


func _build_d5_ice_harp(geom: Node) -> void:
	## Epic-5 T83: large ice harp sculpture — curved frame with 12 thin
	## glowing string cylinders inside.
	var harp: Node3D = Node3D.new()
	harp.name = "IceHarp"
	harp.position = Vector3(D5_CENTER.x + 4.0, 0.0, 14.0)
	geom.add_child(harp)
	var ice_mat: StandardMaterial3D = StandardMaterial3D.new()
	ice_mat.albedo_color = Color(0.65, 0.85, 0.95, 0.92)
	ice_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	ice_mat.emission_enabled = true
	ice_mat.emission = Color(0.40, 0.85, 0.95)
	ice_mat.emission_energy_multiplier = 0.55
	ice_mat.metallic = 0.55
	ice_mat.roughness = 0.20
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.45, 0.50, 0.55)
	stone_mat.roughness = 0.92
	# Stone base
	var base: MeshInstance3D = MeshInstance3D.new()
	var bm: BoxMesh = BoxMesh.new()
	bm.size = Vector3(1.40, 0.30, 0.85)
	base.mesh = bm
	base.material_override = stone_mat
	base.position = Vector3(0, 0.15, 0)
	harp.add_child(base)
	# Vertical column
	var col: MeshInstance3D = MeshInstance3D.new()
	var clm: CylinderMesh = CylinderMesh.new()
	clm.top_radius = 0.10
	clm.bottom_radius = 0.18
	clm.height = 3.40
	col.mesh = clm
	col.material_override = ice_mat
	col.position = Vector3(-0.55, 1.85, 0)
	harp.add_child(col)
	# Curved top neck
	var neck: MeshInstance3D = MeshInstance3D.new()
	var nm: PrismMesh = PrismMesh.new()
	nm.size = Vector3(0.18, 1.85, 0.30)
	neck.mesh = nm
	neck.material_override = ice_mat
	neck.position = Vector3(0.0, 3.40, 0)
	neck.rotation_degrees = Vector3(0, 0, 65)
	harp.add_child(neck)
	# Soundbox at the bottom
	var soundbox: MeshInstance3D = MeshInstance3D.new()
	var sbm: PrismMesh = PrismMesh.new()
	sbm.size = Vector3(1.10, 0.85, 0.55)
	soundbox.mesh = sbm
	soundbox.material_override = ice_mat
	soundbox.position = Vector3(0.45, 0.80, 0)
	soundbox.rotation_degrees = Vector3(0, 0, -25)
	harp.add_child(soundbox)
	# 12 strings (thin glowing cylinders)
	var string_mat: StandardMaterial3D = StandardMaterial3D.new()
	string_mat.albedo_color = Color(0.30, 0.95, 1.0)
	string_mat.emission_enabled = true
	string_mat.emission = Color(0.30, 1.0, 1.0)
	string_mat.emission_energy_multiplier = 2.5
	string_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for i in 12:
		var s: MeshInstance3D = MeshInstance3D.new()
		var sm: CylinderMesh = CylinderMesh.new()
		sm.top_radius = 0.012
		sm.bottom_radius = 0.012
		sm.height = 2.60 - i * 0.10
		s.mesh = sm
		s.material_override = string_mat
		s.position = Vector3(-0.30 + i * 0.06, 1.85 + i * 0.04, 0)
		harp.add_child(s)
	# Light from the harp
	var light: OmniLight3D = OmniLight3D.new()
	light.light_color = Color(0.40, 0.95, 1.0)
	light.light_energy = 1.6
	light.omni_range = 4.0
	light.position = Vector3(0, 1.85, 0)
	harp.add_child(light)
	# Base collision
	var sb: StaticBody3D = StaticBody3D.new()
	sb.position = Vector3(0, 1.85, 0)
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(1.40, 3.40, 0.85)
	cs.shape = cb
	sb.add_child(cs)
	harp.add_child(sb)


func _build_d5_harpist_npc(town: Node) -> void:
	## Epic-5 T84: harpist NPC seated at the ice harp.
	var npc_slots: Node3D = town.get_node_or_null("%NPCSlots") as Node3D
	if npc_slots == null:
		return
	var slot: Marker3D = Marker3D.new()
	slot.name = "HarpistSlot"
	slot.position = Vector3(D5_CENTER.x + 5.5, 0.0, 14.0)
	npc_slots.add_child(slot)
	var npc_scene: PackedScene = load("res://scenes/entities/npcs/VillagerR3.tscn") as PackedScene
	if npc_scene == null:
		return
	var npc: Node3D = npc_scene.instantiate() as Node3D
	npc.name = "Harpist"
	if "npc_name" in npc:
		npc.set("npc_name", "Cantata")
	if "npc_id" in npc:
		npc.set("npc_id", "harpist_d5")
	slot.add_child(npc)
	# Long elegant gown (light blue)
	var gown: MeshInstance3D = MeshInstance3D.new()
	var gm: BoxMesh = BoxMesh.new()
	gm.size = Vector3(0.65, 1.20, 0.40)
	gown.mesh = gm
	var gown_mat: StandardMaterial3D = StandardMaterial3D.new()
	gown_mat.albedo_color = Color(0.65, 0.85, 0.95)
	gown_mat.emission_enabled = true
	gown_mat.emission = Color(0.55, 0.85, 0.95)
	gown_mat.emission_energy_multiplier = 0.30
	gown_mat.roughness = 0.65
	gown.material_override = gown_mat
	gown.position = Vector3(0, 0.60, 0)
	npc.add_child(gown)
	# Hair (long black box)
	var hair: MeshInstance3D = MeshInstance3D.new()
	var hm: BoxMesh = BoxMesh.new()
	hm.size = Vector3(0.40, 0.55, 0.20)
	hair.mesh = hm
	var hair_mat: StandardMaterial3D = StandardMaterial3D.new()
	hair_mat.albedo_color = Color(0.10, 0.08, 0.10)
	hair_mat.roughness = 0.85
	hair.material_override = hair_mat
	hair.position = Vector3(0, 1.45, -0.10)
	npc.add_child(hair)


func _build_d5_data_prism_array(geom: Node) -> void:
	## Epic-5 T85: rotating prism array — 5 rotating triangular ice prisms
	## refracting cyan light. A "data refraction" decorative installation.
	var array: Node3D = Node3D.new()
	array.name = "DataPrismArray"
	array.position = Vector3(D5_CENTER.x + 8.0, 0.0, -22.0)
	geom.add_child(array)
	var ice_mat: StandardMaterial3D = StandardMaterial3D.new()
	ice_mat.albedo_color = Color(0.65, 0.85, 0.95, 0.85)
	ice_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	ice_mat.emission_enabled = true
	ice_mat.emission = Color(0.40, 0.95, 1.0)
	ice_mat.emission_energy_multiplier = 1.4
	ice_mat.metallic = 0.55
	ice_mat.roughness = 0.10
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.40, 0.45, 0.50)
	stone_mat.roughness = 0.92
	for i in 5:
		var stand: Node3D = Node3D.new()
		stand.position = Vector3(i * 1.85, 0, 0)
		array.add_child(stand)
		# Stone pedestal
		var ped: MeshInstance3D = MeshInstance3D.new()
		var pm: CylinderMesh = CylinderMesh.new()
		pm.top_radius = 0.30
		pm.bottom_radius = 0.40
		pm.height = 0.85
		ped.mesh = pm
		ped.material_override = stone_mat
		ped.position = Vector3(0, 0.42, 0)
		stand.add_child(ped)
		# Triangular prism on top, rotating
		var prism: MeshInstance3D = MeshInstance3D.new()
		var prm: PrismMesh = PrismMesh.new()
		prm.size = Vector3(0.55, 1.40, 0.55)
		prism.mesh = prm
		prism.material_override = ice_mat
		prism.position = Vector3(0, 1.55, 0)
		stand.add_child(prism)
		# Continuous spin tween (each at slightly different speed)
		var tw: Tween = prism.create_tween().set_loops()
		tw.tween_property(prism, "rotation_degrees:y", 360.0, 4.0 + i * 0.4)
		tw.tween_property(prism, "rotation_degrees:y", 0.0, 0.0)
		# Per-prism light
		var light: OmniLight3D = OmniLight3D.new()
		light.light_color = Color(0.40, 0.95, 1.0)
		light.light_energy = 1.6
		light.omni_range = 3.0
		light.position = Vector3(0, 1.55, 0)
		stand.add_child(light)
		# Pedestal collision
		var sb: StaticBody3D = StaticBody3D.new()
		sb.position = Vector3(0, 0.42, 0)
		var cs: CollisionShape3D = CollisionShape3D.new()
		var cyl: CylinderShape3D = CylinderShape3D.new()
		cyl.radius = 0.40
		cyl.height = 0.85
		cs.shape = cyl
		sb.add_child(cs)
		stand.add_child(sb)


func _build_d5_ice_fountain(geom: Node) -> void:
	## Epic-5 T86: large central ice fountain — circular basin + central
	## column + 4 outward water-jet arcs frozen mid-flight.
	var fountain: Node3D = Node3D.new()
	fountain.name = "IceFountain"
	fountain.position = Vector3(D5_CENTER.x - 4.0, 0.0, 4.0)
	geom.add_child(fountain)
	var ice_mat: StandardMaterial3D = StandardMaterial3D.new()
	ice_mat.albedo_color = Color(0.65, 0.85, 0.95, 0.85)
	ice_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	ice_mat.emission_enabled = true
	ice_mat.emission = Color(0.40, 0.85, 0.95)
	ice_mat.emission_energy_multiplier = 0.85
	ice_mat.metallic = 0.55
	ice_mat.roughness = 0.10
	# Outer basin (low cylinder)
	var basin: MeshInstance3D = MeshInstance3D.new()
	var bm: CylinderMesh = CylinderMesh.new()
	bm.top_radius = 2.20
	bm.bottom_radius = 2.40
	bm.height = 0.55
	basin.mesh = bm
	basin.material_override = ice_mat
	basin.position = Vector3(0, 0.27, 0)
	fountain.add_child(basin)
	# Inner water disc
	var water: MeshInstance3D = MeshInstance3D.new()
	var wm: CylinderMesh = CylinderMesh.new()
	wm.top_radius = 1.85
	wm.bottom_radius = 1.85
	wm.height = 0.06
	water.mesh = wm
	var water_mat: StandardMaterial3D = StandardMaterial3D.new()
	water_mat.albedo_color = Color(0.40, 0.85, 1.0, 0.65)
	water_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	water_mat.emission_enabled = true
	water_mat.emission = Color(0.30, 0.95, 1.0)
	water_mat.emission_energy_multiplier = 1.4
	water_mat.metallic = 0.30
	water_mat.roughness = 0.10
	water.material_override = water_mat
	water.position = Vector3(0, 0.50, 0)
	fountain.add_child(water)
	# Central tiered column
	for i in 3:
		var tier: MeshInstance3D = MeshInstance3D.new()
		var tm: CylinderMesh = CylinderMesh.new()
		tm.top_radius = 0.35 - i * 0.08
		tm.bottom_radius = 0.55 - i * 0.10
		tm.height = 0.40
		tier.mesh = tm
		tier.material_override = ice_mat
		tier.position = Vector3(0, 0.75 + i * 0.40, 0)
		fountain.add_child(tier)
	# Top crystal sphere
	var top_crystal: MeshInstance3D = MeshInstance3D.new()
	var tcm: SphereMesh = SphereMesh.new()
	tcm.radius = 0.30
	tcm.height = 0.55
	top_crystal.mesh = tcm
	top_crystal.material_override = ice_mat
	top_crystal.position = Vector3(0, 2.20, 0)
	fountain.add_child(top_crystal)
	# 4 frozen water-jet arcs (curved cylinders flaring outward)
	for i in 4:
		var ang: float = (TAU / 4.0) * i
		var arc: MeshInstance3D = MeshInstance3D.new()
		var am: CylinderMesh = CylinderMesh.new()
		am.top_radius = 0.06
		am.bottom_radius = 0.10
		am.height = 1.85
		arc.mesh = am
		arc.material_override = ice_mat
		arc.position = Vector3(cos(ang) * 1.10, 1.65, sin(ang) * 1.10)
		arc.rotation = Vector3(deg_to_rad(35) * sin(ang), ang, deg_to_rad(35) * cos(ang))
		fountain.add_child(arc)
	# Subtle water bob
	var tw: Tween = water.create_tween().set_loops()
	tw.tween_property(water, "position:y", 0.55, 1.6)
	tw.tween_property(water, "position:y", 0.50, 1.6)
	# Central light
	var light: OmniLight3D = OmniLight3D.new()
	light.light_color = Color(0.40, 0.95, 1.0)
	light.light_energy = 2.5
	light.omni_range = 6.0
	light.position = Vector3(0, 1.20, 0)
	fountain.add_child(light)
	# Basin collision
	var sb: StaticBody3D = StaticBody3D.new()
	sb.position = Vector3(0, 0.27, 0)
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cap: CylinderShape3D = CylinderShape3D.new()
	cap.radius = 2.40
	cap.height = 0.55
	cs.shape = cap
	sb.add_child(cs)
	fountain.add_child(sb)


func _build_d5_cryo_lantern_grove(geom: Node) -> void:
	## Epic-5 T87: 6 small cryo lanterns clustered as a grove around a path,
	## floating slowly with cyan light each.
	var grove: Node3D = Node3D.new()
	grove.name = "CryoLanternGrove"
	grove.position = Vector3(D5_CENTER.x - 22.0, 0.0, -4.0)
	geom.add_child(grove)
	var glass_mat: StandardMaterial3D = StandardMaterial3D.new()
	glass_mat.albedo_color = Color(0.40, 0.85, 1.0, 0.85)
	glass_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	glass_mat.emission_enabled = true
	glass_mat.emission = Color(0.30, 0.95, 1.0)
	glass_mat.emission_energy_multiplier = 2.5
	glass_mat.metallic = 0.30
	glass_mat.roughness = 0.10
	var metal_mat: StandardMaterial3D = StandardMaterial3D.new()
	metal_mat.albedo_color = Color(0.40, 0.45, 0.50)
	metal_mat.metallic = 0.85
	metal_mat.roughness = 0.30
	for i in 6:
		var ang: float = (TAU / 6.0) * i
		var lantern: Node3D = Node3D.new()
		lantern.position = Vector3(cos(ang) * 2.40, randf_range(0.0, 0.30), sin(ang) * 2.40)
		grove.add_child(lantern)
		# Lantern body (small box)
		var body: MeshInstance3D = MeshInstance3D.new()
		var bm: BoxMesh = BoxMesh.new()
		bm.size = Vector3(0.30, 0.40, 0.30)
		body.mesh = bm
		body.material_override = glass_mat
		body.position = Vector3(0, 1.40, 0)
		lantern.add_child(body)
		# Top metal cap
		var cap: MeshInstance3D = MeshInstance3D.new()
		var cmm: BoxMesh = BoxMesh.new()
		cmm.size = Vector3(0.40, 0.06, 0.40)
		cap.mesh = cmm
		cap.material_override = metal_mat
		cap.position = Vector3(0, 1.65, 0)
		lantern.add_child(cap)
		# Bottom metal cap
		var bcap: MeshInstance3D = MeshInstance3D.new()
		var bcm: BoxMesh = BoxMesh.new()
		bcm.size = Vector3(0.40, 0.06, 0.40)
		bcap.mesh = bcm
		bcap.material_override = metal_mat
		bcap.position = Vector3(0, 1.15, 0)
		lantern.add_child(bcap)
		# Light per lantern
		var light: OmniLight3D = OmniLight3D.new()
		light.light_color = Color(0.40, 0.95, 1.0)
		light.light_energy = 1.8
		light.omni_range = 3.5
		light.position = Vector3(0, 1.40, 0)
		lantern.add_child(light)
		# Float bob (each at slightly different rate)
		var tw: Tween = lantern.create_tween().set_loops()
		tw.tween_property(lantern, "position:y", lantern.position.y + 0.30, 1.6 + i * 0.18)
		tw.tween_property(lantern, "position:y", lantern.position.y, 1.6 + i * 0.18)


func _build_d5_signposts(geom: Node) -> void:
	## Epic-5 T88: 4-way signpost network — central post with 4 directional
	## arrow signs pointing toward each district.
	var post_root: Node3D = Node3D.new()
	post_root.name = "Signposts"
	post_root.position = Vector3(D5_CENTER.x - 28.0, 0.0, 0.0)
	geom.add_child(post_root)
	var wood_mat: StandardMaterial3D = StandardMaterial3D.new()
	wood_mat.albedo_color = Color(0.45, 0.28, 0.12)
	wood_mat.roughness = 0.85
	# Vertical post
	var post: MeshInstance3D = MeshInstance3D.new()
	var pm: CylinderMesh = CylinderMesh.new()
	pm.top_radius = 0.10
	pm.bottom_radius = 0.14
	pm.height = 2.85
	post.mesh = pm
	post.material_override = wood_mat
	post.position = Vector3(0, 1.42, 0)
	post_root.add_child(post)
	# 4 directional arrow signs
	var sign_data: Array = [
		{"text": "← BLOOM CLUSTER", "ang": 180.0, "y": 2.40, "color": Color(0.95, 0.55, 0.75)},
		{"text": "← MEMORY VAULT", "ang": 180.0, "y": 1.95, "color": Color(0.55, 0.40, 0.95)},
		{"text": "← STACK OUTSKIRTS", "ang": 180.0, "y": 1.50, "color": Color(0.95, 0.55, 0.30)},
		{"text": "← EAST PLAZA", "ang": 180.0, "y": 1.05, "color": Color(0.40, 0.95, 1.0)},
	]
	for sd in sign_data:
		var sign_box: MeshInstance3D = MeshInstance3D.new()
		var sm: BoxMesh = BoxMesh.new()
		sm.size = Vector3(1.85, 0.30, 0.06)
		sign_box.mesh = sm
		var sign_mat: StandardMaterial3D = StandardMaterial3D.new()
		sign_mat.albedo_color = sd["color"]
		sign_mat.emission_enabled = true
		sign_mat.emission = sd["color"]
		sign_mat.emission_energy_multiplier = 0.45
		sign_mat.roughness = 0.65
		sign_box.material_override = sign_mat
		sign_box.position = Vector3(-0.85, sd["y"], 0)
		post_root.add_child(sign_box)
		# Label
		var label: Label3D = Label3D.new()
		label.text = sd["text"]
		label.modulate = Color(0.10, 0.05, 0.05)
		label.outline_modulate = Color(0.95, 0.95, 0.95)
		label.outline_size = 4
		label.font_size = 36
		label.pixel_size = 0.0035
		label.position = Vector3(-0.85, sd["y"], 0.05)
		post_root.add_child(label)
	# Post collision
	var sb: StaticBody3D = StaticBody3D.new()
	sb.position = Vector3(0, 1.42, 0)
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cap: CapsuleShape3D = CapsuleShape3D.new()
	cap.radius = 0.14
	cap.height = 2.85
	cs.shape = cap
	sb.add_child(cs)
	post_root.add_child(sb)


func _build_d5_tablet_shrine(geom: Node) -> void:
	## Epic-5 T89: data tablet shrine — 3 floating glowing tablets above
	## a stone altar, simulating an offering of preserved knowledge.
	var shrine: Node3D = Node3D.new()
	shrine.name = "DataTabletShrine"
	shrine.position = Vector3(D5_CENTER.x - 18.0, 0.0, -10.0)
	geom.add_child(shrine)
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.55, 0.60, 0.65)
	stone_mat.roughness = 0.92
	# Stone altar
	var altar: MeshInstance3D = MeshInstance3D.new()
	var am: BoxMesh = BoxMesh.new()
	am.size = Vector3(2.20, 0.85, 1.40)
	altar.mesh = am
	altar.material_override = stone_mat
	altar.position = Vector3(0, 0.42, 0)
	shrine.add_child(altar)
	# 3 floating tablets in a fan
	var tablet_mat: StandardMaterial3D = StandardMaterial3D.new()
	tablet_mat.albedo_color = Color(0.40, 0.85, 1.0)
	tablet_mat.emission_enabled = true
	tablet_mat.emission = Color(0.30, 0.95, 1.0)
	tablet_mat.emission_energy_multiplier = 2.5
	tablet_mat.metallic = 0.55
	tablet_mat.roughness = 0.10
	tablet_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for i in 3:
		var tablet: Node3D = Node3D.new()
		tablet.position = Vector3(-0.85 + i * 0.85, 1.85, 0)
		shrine.add_child(tablet)
		var slab: MeshInstance3D = MeshInstance3D.new()
		var sm: BoxMesh = BoxMesh.new()
		sm.size = Vector3(0.55, 0.85, 0.06)
		slab.mesh = sm
		slab.material_override = tablet_mat
		tablet.add_child(slab)
		# Hover bob (offset)
		var tw: Tween = tablet.create_tween().set_loops()
		tw.tween_interval(i * 0.20)
		tw.tween_property(tablet, "position:y", 2.10, 1.4)
		tw.tween_property(tablet, "position:y", 1.85, 1.4)
		# Subtle rotation
		var ts: Tween = slab.create_tween().set_loops()
		ts.tween_property(slab, "rotation_degrees:y", 360.0, 8.0 + i * 0.6)
		ts.tween_property(slab, "rotation_degrees:y", 0.0, 0.0)
	# Aura light
	var light: OmniLight3D = OmniLight3D.new()
	light.light_color = Color(0.40, 0.95, 1.0)
	light.light_energy = 2.5
	light.omni_range = 6.0
	light.position = Vector3(0, 2.10, 0)
	shrine.add_child(light)
	# Altar collision
	var sb: StaticBody3D = StaticBody3D.new()
	sb.position = Vector3(0, 0.42, 0)
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(2.20, 0.85, 1.40)
	cs.shape = cb
	sb.add_child(cs)
	shrine.add_child(sb)


func _build_d5_ice_elemental(geom: Node) -> void:
	## Epic-5 T90: small floating ice elemental creature — 3 stacked ice
	## crystal segments with glowing eyes, hovering and slowly rotating
	## along a small patrol path.
	var elemental: Node3D = Node3D.new()
	elemental.name = "IceElemental"
	elemental.position = Vector3(D5_CENTER.x + 22.0, 1.5, -2.0)
	geom.add_child(elemental)
	var ice_mat: StandardMaterial3D = StandardMaterial3D.new()
	ice_mat.albedo_color = Color(0.55, 0.85, 0.95, 0.85)
	ice_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	ice_mat.emission_enabled = true
	ice_mat.emission = Color(0.40, 0.85, 0.95)
	ice_mat.emission_energy_multiplier = 1.4
	ice_mat.metallic = 0.55
	ice_mat.roughness = 0.10
	# 3 stacked crystal segments (large to small)
	var sizes: Array = [0.55, 0.40, 0.30]
	for i in 3:
		var crystal: MeshInstance3D = MeshInstance3D.new()
		var cm: PrismMesh = PrismMesh.new()
		cm.size = Vector3(sizes[i], sizes[i] * 1.4, sizes[i])
		crystal.mesh = cm
		crystal.material_override = ice_mat
		crystal.position = Vector3(0, i * 0.65, 0)
		crystal.rotation_degrees = Vector3(0, i * 60, 0)
		elemental.add_child(crystal)
	# 2 glowing cyan eyes on the top crystal
	var eye_mat: StandardMaterial3D = StandardMaterial3D.new()
	eye_mat.albedo_color = Color(0.30, 0.95, 1.0)
	eye_mat.emission_enabled = true
	eye_mat.emission = Color(0.30, 1.0, 1.0)
	eye_mat.emission_energy_multiplier = 4.0
	eye_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for ex in [-0.07, 0.07]:
		var eye: MeshInstance3D = MeshInstance3D.new()
		var em: SphereMesh = SphereMesh.new()
		em.radius = 0.05
		em.height = 0.10
		eye.mesh = em
		eye.material_override = eye_mat
		eye.position = Vector3(ex, 1.40, 0.20)
		elemental.add_child(eye)
	# Aura light
	var light: OmniLight3D = OmniLight3D.new()
	light.light_color = Color(0.40, 0.95, 1.0)
	light.light_energy = 2.0
	light.omni_range = 4.0
	light.position = Vector3(0, 0.85, 0)
	elemental.add_child(light)
	# Hover patrol tween
	var tw: Tween = elemental.create_tween().set_loops()
	tw.tween_property(elemental, "position", Vector3(D5_CENTER.x + 18.0, 2.0, -2.0), 4.0)
	tw.tween_property(elemental, "position", Vector3(D5_CENTER.x + 22.0, 1.5, -2.0), 4.0)
	tw.tween_property(elemental, "position", Vector3(D5_CENTER.x + 22.0, 1.8, -6.0), 4.0)
	tw.tween_property(elemental, "position", Vector3(D5_CENTER.x + 22.0, 1.5, -2.0), 4.0)
	# Continuous spin
	var ts: Tween = elemental.create_tween().set_loops()
	ts.tween_property(elemental, "rotation_degrees:y", 360.0, 10.0)
	ts.tween_property(elemental, "rotation_degrees:y", 0.0, 0.0)


func _build_d5_glacier_crab(geom: Node) -> void:
	## Epic-5 T91: glacier crab — pale blue crustacean with 6 legs, 2 large
	## claws, and an ice-shell back. Side-step shuffling animation.
	var crab: Node3D = Node3D.new()
	crab.name = "GlacierCrab"
	crab.position = Vector3(D5_CENTER.x + 16.0, 0.0, 12.0)
	geom.add_child(crab)
	var shell_mat: StandardMaterial3D = StandardMaterial3D.new()
	shell_mat.albedo_color = Color(0.55, 0.78, 0.92)
	shell_mat.emission_enabled = true
	shell_mat.emission = Color(0.40, 0.65, 0.85)
	shell_mat.emission_energy_multiplier = 0.30
	shell_mat.metallic = 0.45
	shell_mat.roughness = 0.30
	var leg_mat: StandardMaterial3D = StandardMaterial3D.new()
	leg_mat.albedo_color = Color(0.35, 0.50, 0.65)
	leg_mat.metallic = 0.30
	leg_mat.roughness = 0.45
	# Body shell (large flat sphere)
	var body: MeshInstance3D = MeshInstance3D.new()
	var bm: SphereMesh = SphereMesh.new()
	bm.radius = 0.65
	bm.height = 0.85
	body.mesh = bm
	body.material_override = shell_mat
	body.position = Vector3(0, 0.55, 0)
	body.scale = Vector3(1.0, 0.45, 1.20)
	crab.add_child(body)
	# 2 small eye stalks
	var eye_mat: StandardMaterial3D = StandardMaterial3D.new()
	eye_mat.albedo_color = Color(0.10, 0.10, 0.15)
	eye_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for ex in [-0.18, 0.18]:
		var stalk: MeshInstance3D = MeshInstance3D.new()
		var stm: CylinderMesh = CylinderMesh.new()
		stm.top_radius = 0.025
		stm.bottom_radius = 0.025
		stm.height = 0.20
		stalk.mesh = stm
		stalk.material_override = leg_mat
		stalk.position = Vector3(ex, 0.85, 0.30)
		crab.add_child(stalk)
		var eye: MeshInstance3D = MeshInstance3D.new()
		var em: SphereMesh = SphereMesh.new()
		em.radius = 0.06
		em.height = 0.12
		eye.mesh = em
		eye.material_override = eye_mat
		eye.position = Vector3(ex, 0.97, 0.30)
		crab.add_child(eye)
	# 2 large claws (front)
	for sx in [-0.55, 0.55]:
		var claw_arm: MeshInstance3D = MeshInstance3D.new()
		var cam: CylinderMesh = CylinderMesh.new()
		cam.top_radius = 0.08
		cam.bottom_radius = 0.08
		cam.height = 0.55
		claw_arm.mesh = cam
		claw_arm.material_override = leg_mat
		claw_arm.position = Vector3(sx, 0.55, 0.55)
		claw_arm.rotation_degrees = Vector3(0, 0, 90)
		crab.add_child(claw_arm)
		# Claw pincer (large sphere segment with prism teeth)
		var pincer: MeshInstance3D = MeshInstance3D.new()
		var prm: SphereMesh = SphereMesh.new()
		prm.radius = 0.22
		prm.height = 0.40
		pincer.mesh = prm
		pincer.material_override = shell_mat
		pincer.position = Vector3(sx + sx * 0.3, 0.55, 0.85)
		pincer.scale = Vector3(0.85, 0.85, 1.20)
		crab.add_child(pincer)
	# 6 walking legs (3 each side)
	for side_idx in 2:
		var sx: float = -0.50 + side_idx * 1.0
		for i in 3:
			var leg: MeshInstance3D = MeshInstance3D.new()
			var lm: CylinderMesh = CylinderMesh.new()
			lm.top_radius = 0.04
			lm.bottom_radius = 0.04
			lm.height = 0.55
			leg.mesh = lm
			leg.material_override = leg_mat
			leg.position = Vector3(sx, 0.30, -0.30 + i * 0.30)
			leg.rotation_degrees = Vector3(0, 0, 50.0 if sx > 0 else -50.0)
			crab.add_child(leg)
	# Side-step shuffle tween
	var tw: Tween = crab.create_tween().set_loops()
	tw.tween_property(crab, "position:x", D5_CENTER.x + 18.0, 2.0)
	tw.tween_property(crab, "position:x", D5_CENTER.x + 14.0, 2.0)
	# Body bob
	var tb: Tween = body.create_tween().set_loops()
	tb.tween_property(body, "position:y", 0.62, 0.40)
	tb.tween_property(body, "position:y", 0.55, 0.40)
	# Body collision
	var sb: StaticBody3D = StaticBody3D.new()
	sb.position = Vector3(0, 0.55, 0)
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(1.40, 0.55, 1.40)
	cs.shape = cb
	sb.add_child(cs)
	crab.add_child(sb)


func _build_d5_cryo_kiosk(geom: Node) -> void:
	## Epic-5 T92: cryo terminal kiosk — interactive standing terminal with
	## a glowing cyan screen, used as a save point hint location.
	var kiosk: Node3D = Node3D.new()
	kiosk.name = "CryoKiosk"
	kiosk.position = Vector3(D5_CENTER.x - 26.0, 0.0, 6.0)
	geom.add_child(kiosk)
	var metal_mat: StandardMaterial3D = StandardMaterial3D.new()
	metal_mat.albedo_color = Color(0.30, 0.35, 0.40)
	metal_mat.metallic = 0.85
	metal_mat.roughness = 0.30
	# Pedestal base
	var base: MeshInstance3D = MeshInstance3D.new()
	var bm: BoxMesh = BoxMesh.new()
	bm.size = Vector3(0.85, 0.30, 0.85)
	base.mesh = bm
	base.material_override = metal_mat
	base.position = Vector3(0, 0.15, 0)
	kiosk.add_child(base)
	# Stand column
	var col: MeshInstance3D = MeshInstance3D.new()
	var cm: BoxMesh = BoxMesh.new()
	cm.size = Vector3(0.55, 1.40, 0.55)
	col.mesh = cm
	col.material_override = metal_mat
	col.position = Vector3(0, 1.0, 0)
	kiosk.add_child(col)
	# Screen housing (angled box)
	var screen_box: MeshInstance3D = MeshInstance3D.new()
	var sbm: BoxMesh = BoxMesh.new()
	sbm.size = Vector3(0.85, 0.65, 0.18)
	screen_box.mesh = sbm
	screen_box.material_override = metal_mat
	screen_box.position = Vector3(0, 1.85, 0.20)
	screen_box.rotation_degrees = Vector3(-25, 0, 0)
	kiosk.add_child(screen_box)
	# Glowing screen
	var screen: MeshInstance3D = MeshInstance3D.new()
	var scm: BoxMesh = BoxMesh.new()
	scm.size = Vector3(0.75, 0.55, 0.04)
	screen.mesh = scm
	var screen_mat: StandardMaterial3D = StandardMaterial3D.new()
	screen_mat.albedo_color = Color(0.40, 0.95, 1.0)
	screen_mat.emission_enabled = true
	screen_mat.emission = Color(0.30, 1.0, 1.0)
	screen_mat.emission_energy_multiplier = 3.0
	screen_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	screen.material_override = screen_mat
	screen.position = Vector3(0, 1.85, 0.30)
	screen.rotation_degrees = Vector3(-25, 0, 0)
	kiosk.add_child(screen)
	# Label
	var label: Label3D = Label3D.new()
	label.text = "CRYO TERMINAL\n\n[SAVE POINT]\n0xCACHE_05"
	label.modulate = Color(0.05, 0.10, 0.20)
	label.outline_modulate = Color(0.40, 0.95, 1.0)
	label.outline_size = 4
	label.font_size = 32
	label.pixel_size = 0.0035
	label.position = Vector3(0, 1.85, 0.34)
	label.rotation_degrees = Vector3(-25, 0, 0)
	kiosk.add_child(label)
	# Light
	var light: OmniLight3D = OmniLight3D.new()
	light.light_color = Color(0.40, 0.95, 1.0)
	light.light_energy = 1.6
	light.omni_range = 4.0
	light.position = Vector3(0, 1.85, 0.50)
	kiosk.add_child(light)
	# Kiosk collision
	var sb: StaticBody3D = StaticBody3D.new()
	sb.position = Vector3(0, 1.0, 0)
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(0.85, 2.0, 0.85)
	cs.shape = cb
	sb.add_child(cs)
	kiosk.add_child(sb)


func _build_d5_seeker_npc(town: Node) -> void:
	## Epic-5 T93: hopeful seeker NPC — young traveler in pale blue cloak,
	## looking up toward the aurora curtain with hands clasped.
	var npc_slots: Node3D = town.get_node_or_null("%NPCSlots") as Node3D
	if npc_slots == null:
		return
	var slot: Marker3D = Marker3D.new()
	slot.name = "HopefulSeekerSlot"
	slot.position = Vector3(D5_CENTER.x - 8.0, 0.0, -4.0)
	npc_slots.add_child(slot)
	var npc_scene: PackedScene = load("res://scenes/entities/npcs/VillagerR3.tscn") as PackedScene
	if npc_scene == null:
		return
	var npc: Node3D = npc_scene.instantiate() as Node3D
	npc.name = "HopefulSeeker"
	if "npc_name" in npc:
		npc.set("npc_name", "Lumen")
	if "npc_id" in npc:
		npc.set("npc_id", "seeker_d5")
	slot.add_child(npc)
	# Pale blue cloak
	var cloak: MeshInstance3D = MeshInstance3D.new()
	var cm: BoxMesh = BoxMesh.new()
	cm.size = Vector3(0.65, 1.20, 0.45)
	cloak.mesh = cm
	var cloak_mat: StandardMaterial3D = StandardMaterial3D.new()
	cloak_mat.albedo_color = Color(0.55, 0.85, 0.95)
	cloak_mat.emission_enabled = true
	cloak_mat.emission = Color(0.40, 0.85, 0.95)
	cloak_mat.emission_energy_multiplier = 0.30
	cloak_mat.roughness = 0.65
	cloak.material_override = cloak_mat
	cloak.position = Vector3(0, 0.60, 0)
	npc.add_child(cloak)
	# Hood drawn back
	var hood: MeshInstance3D = MeshInstance3D.new()
	var hm: SphereMesh = SphereMesh.new()
	hm.radius = 0.22
	hm.height = 0.40
	hood.mesh = hm
	hood.material_override = cloak_mat
	hood.position = Vector3(0, 1.30, -0.18)
	hood.scale = Vector3(0.85, 0.45, 0.85)
	npc.add_child(hood)
	# Held small star fragment (small bright sphere clasped at chest)
	var star: MeshInstance3D = MeshInstance3D.new()
	var sm: SphereMesh = SphereMesh.new()
	sm.radius = 0.10
	sm.height = 0.20
	star.mesh = sm
	var star_mat: StandardMaterial3D = StandardMaterial3D.new()
	star_mat.albedo_color = Color(1.0, 0.95, 0.65)
	star_mat.emission_enabled = true
	star_mat.emission = Color(1.0, 0.85, 0.45)
	star_mat.emission_energy_multiplier = 4.0
	star_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	star.material_override = star_mat
	star.position = Vector3(0, 0.85, 0.25)
	npc.add_child(star)
	# Star pulse
	var tw: Tween = star.create_tween().set_loops()
	tw.tween_property(star, "scale", Vector3.ONE * 1.20, 0.85)
	tw.tween_property(star, "scale", Vector3.ONE * 0.85, 0.85)
	# Star light
	var light: OmniLight3D = OmniLight3D.new()
	light.light_color = Color(1.0, 0.85, 0.55)
	light.light_energy = 1.4
	light.omni_range = 3.0
	light.position = Vector3(0, 0.85, 0.25)
	npc.add_child(light)


func _build_d5_cryosleep_pods(geom: Node) -> void:
	## Epic-5 T94: row of 4 horizontal cryosleep medical pods — like the
	## standing cryo pods but laid down with sleeping subjects inside.
	var row: Node3D = Node3D.new()
	row.name = "CryosleepPods"
	row.position = Vector3(D5_CENTER.x - 22.0, 0.0, 14.0)
	geom.add_child(row)
	var metal_mat: StandardMaterial3D = StandardMaterial3D.new()
	metal_mat.albedo_color = Color(0.40, 0.50, 0.60)
	metal_mat.metallic = 0.85
	metal_mat.roughness = 0.30
	var glass_mat: StandardMaterial3D = StandardMaterial3D.new()
	glass_mat.albedo_color = Color(0.55, 0.85, 1.0, 0.55)
	glass_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	glass_mat.emission_enabled = true
	glass_mat.emission = Color(0.40, 0.85, 1.0)
	glass_mat.emission_energy_multiplier = 0.85
	glass_mat.metallic = 0.55
	glass_mat.roughness = 0.10
	var subject_mat: StandardMaterial3D = StandardMaterial3D.new()
	subject_mat.albedo_color = Color(0.40, 0.95, 1.0, 0.65)
	subject_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	subject_mat.emission_enabled = true
	subject_mat.emission = Color(0.30, 0.95, 1.0)
	subject_mat.emission_energy_multiplier = 1.4
	subject_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for i in 4:
		var pod: Node3D = Node3D.new()
		pod.position = Vector3(0, 0, i * 1.40)
		row.add_child(pod)
		# Metal cradle (low box)
		var cradle: MeshInstance3D = MeshInstance3D.new()
		var crm: BoxMesh = BoxMesh.new()
		crm.size = Vector3(2.20, 0.30, 0.85)
		cradle.mesh = crm
		cradle.material_override = metal_mat
		cradle.position = Vector3(0, 0.15, 0)
		pod.add_child(cradle)
		# Glass dome (long flat sphere)
		var dome: MeshInstance3D = MeshInstance3D.new()
		var dm: SphereMesh = SphereMesh.new()
		dm.radius = 1.10
		dm.height = 1.85
		dome.mesh = dm
		dome.material_override = glass_mat
		dome.position = Vector3(0, 0.55, 0)
		dome.scale = Vector3(1.0, 0.30, 0.45)
		pod.add_child(dome)
		# Sleeping subject silhouette
		var subject: MeshInstance3D = MeshInstance3D.new()
		var sm: SphereMesh = SphereMesh.new()
		sm.radius = 0.85
		sm.height = 0.55
		subject.mesh = sm
		subject.material_override = subject_mat
		subject.position = Vector3(0, 0.40, 0)
		subject.scale = Vector3(0.85, 0.35, 0.40)
		pod.add_child(subject)
		# Status LED at the head end
		var led_mat: StandardMaterial3D = StandardMaterial3D.new()
		led_mat.albedo_color = Color(0.30, 1.0, 0.55)
		led_mat.emission_enabled = true
		led_mat.emission = Color(0.30, 1.0, 0.55)
		led_mat.emission_energy_multiplier = 3.5
		led_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		var led: MeshInstance3D = MeshInstance3D.new()
		var lm: SphereMesh = SphereMesh.new()
		lm.radius = 0.05
		lm.height = 0.10
		led.mesh = lm
		led.material_override = led_mat
		led.position = Vector3(-0.85, 0.35, 0.32)
		pod.add_child(led)
		# Slow LED pulse
		var tw: Tween = led.create_tween().set_loops()
		tw.tween_interval(i * 0.35)
		tw.tween_property(led, "scale", Vector3.ONE * 1.50, 0.85)
		tw.tween_property(led, "scale", Vector3.ONE * 0.85, 0.85)
		# Pod collision
		var sb: StaticBody3D = StaticBody3D.new()
		sb.position = Vector3(0, 0.30, 0)
		var cs: CollisionShape3D = CollisionShape3D.new()
		var cb: BoxShape3D = BoxShape3D.new()
		cb.size = Vector3(2.20, 0.65, 0.85)
		cs.shape = cb
		sb.add_child(cs)
		pod.add_child(sb)


func _build_d5_starlight_projector(geom: Node) -> void:
	## Epic-5 T95: starlight projector — small dish device casting an
	## upward cone of starry blue light + 12 floating glow stars.
	var proj: Node3D = Node3D.new()
	proj.name = "StarlightProjector"
	proj.position = Vector3(D5_CENTER.x + 14.0, 0.0, 18.0)
	geom.add_child(proj)
	var metal_mat: StandardMaterial3D = StandardMaterial3D.new()
	metal_mat.albedo_color = Color(0.30, 0.35, 0.40)
	metal_mat.metallic = 0.85
	metal_mat.roughness = 0.30
	# Tripod stand (3 legs)
	for i in 3:
		var ang: float = (TAU / 3.0) * i
		var leg: MeshInstance3D = MeshInstance3D.new()
		var lm: CylinderMesh = CylinderMesh.new()
		lm.top_radius = 0.04
		lm.bottom_radius = 0.05
		lm.height = 1.30
		leg.mesh = lm
		leg.material_override = metal_mat
		leg.position = Vector3(cos(ang) * 0.40, 0.65, sin(ang) * 0.40)
		leg.rotation_degrees = Vector3(deg_to_rad(15) * sin(ang) * 60.0, 0, deg_to_rad(15) * cos(ang) * 60.0)
		proj.add_child(leg)
	# Dish on top (half sphere)
	var dish: MeshInstance3D = MeshInstance3D.new()
	var dmm: SphereMesh = SphereMesh.new()
	dmm.radius = 0.40
	dmm.height = 0.40
	dish.mesh = dmm
	dish.material_override = metal_mat
	dish.position = Vector3(0, 1.35, 0)
	dish.scale = Vector3(1.0, 0.45, 1.0)
	proj.add_child(dish)
	# Upward beam cone
	var beam: MeshInstance3D = MeshInstance3D.new()
	var beam_m: CylinderMesh = CylinderMesh.new()
	beam_m.top_radius = 1.40
	beam_m.bottom_radius = 0.20
	beam_m.height = 7.0
	beam.mesh = beam_m
	var beam_mat: StandardMaterial3D = StandardMaterial3D.new()
	beam_mat.albedo_color = Color(0.40, 0.65, 0.95, 0.30)
	beam_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	beam_mat.emission_enabled = true
	beam_mat.emission = Color(0.40, 0.75, 1.0)
	beam_mat.emission_energy_multiplier = 1.4
	beam_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	beam.material_override = beam_mat
	beam.position = Vector3(0, 5.05, 0)
	proj.add_child(beam)
	# 12 floating star points around the beam
	var star_mat: StandardMaterial3D = StandardMaterial3D.new()
	star_mat.albedo_color = Color(1.0, 1.0, 0.85)
	star_mat.emission_enabled = true
	star_mat.emission = Color(1.0, 0.95, 0.75)
	star_mat.emission_energy_multiplier = 3.5
	star_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for i in 12:
		var ang: float = (TAU / 12.0) * i + randf() * 0.4
		var radius: float = randf_range(0.40, 1.30)
		var star: MeshInstance3D = MeshInstance3D.new()
		var smm: SphereMesh = SphereMesh.new()
		smm.radius = 0.05
		smm.height = 0.10
		star.mesh = smm
		star.material_override = star_mat
		var star_y: float = randf_range(2.20, 7.85)
		star.position = Vector3(cos(ang) * radius, star_y, sin(ang) * radius)
		proj.add_child(star)
		# Slow drift up + reset
		var tw: Tween = star.create_tween().set_loops()
		tw.tween_interval(i * 0.20)
		tw.tween_property(star, "position:y", star_y + 1.20, 3.0)
		tw.tween_property(star, "position:y", star_y, 0.0)
	# Tripod collision
	var sb: StaticBody3D = StaticBody3D.new()
	sb.position = Vector3(0, 0.85, 0)
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cap: CapsuleShape3D = CapsuleShape3D.new()
	cap.radius = 0.50
	cap.height = 1.65
	cs.shape = cap
	sb.add_child(cs)
	proj.add_child(sb)


func _build_d5_welcome_banner(geom: Node) -> void:
	## Epic-5 T96: tall double-pole welcome banner — translucent ice fabric
	## with the district name and a crown of icicles hanging below.
	var banner: Node3D = Node3D.new()
	banner.name = "D5WelcomeBanner"
	banner.position = Vector3(D5_CENTER.x - 32.0, 0.0, -4.0)
	geom.add_child(banner)
	var metal_mat: StandardMaterial3D = StandardMaterial3D.new()
	metal_mat.albedo_color = Color(0.30, 0.40, 0.50)
	metal_mat.metallic = 0.85
	metal_mat.roughness = 0.30
	var ice_mat: StandardMaterial3D = StandardMaterial3D.new()
	ice_mat.albedo_color = Color(0.55, 0.85, 0.95, 0.85)
	ice_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	ice_mat.emission_enabled = true
	ice_mat.emission = Color(0.40, 0.85, 0.95)
	ice_mat.emission_energy_multiplier = 0.85
	ice_mat.metallic = 0.55
	ice_mat.roughness = 0.10
	for sx in [-2.40, 2.40]:
		var pole: MeshInstance3D = MeshInstance3D.new()
		var pm: CylinderMesh = CylinderMesh.new()
		pm.top_radius = 0.10
		pm.bottom_radius = 0.14
		pm.height = 5.50
		pole.mesh = pm
		pole.material_override = metal_mat
		pole.position = Vector3(sx, 2.75, 0)
		banner.add_child(pole)
		# Pole collision
		var sb: StaticBody3D = StaticBody3D.new()
		sb.position = Vector3(sx, 2.75, 0)
		var cs: CollisionShape3D = CollisionShape3D.new()
		var cap: CapsuleShape3D = CapsuleShape3D.new()
		cap.radius = 0.16
		cap.height = 5.50
		cs.shape = cap
		sb.add_child(cs)
		banner.add_child(sb)
	# Top crossbar
	var bar: MeshInstance3D = MeshInstance3D.new()
	var bm: CylinderMesh = CylinderMesh.new()
	bm.top_radius = 0.08
	bm.bottom_radius = 0.08
	bm.height = 5.20
	bar.mesh = bm
	bar.material_override = metal_mat
	bar.position = Vector3(0, 5.20, 0)
	bar.rotation_degrees = Vector3(0, 0, 90)
	banner.add_child(bar)
	# Banner cloth (translucent ice slab)
	var cloth: MeshInstance3D = MeshInstance3D.new()
	var cm: BoxMesh = BoxMesh.new()
	cm.size = Vector3(4.60, 2.80, 0.06)
	cloth.mesh = cm
	cloth.material_override = ice_mat
	cloth.position = Vector3(0, 3.50, 0)
	banner.add_child(cloth)
	# Title labels
	var label: Label3D = Label3D.new()
	label.text = "FROZEN CACHE"
	label.modulate = Color(0.95, 1.0, 1.0)
	label.outline_modulate = Color(0.10, 0.20, 0.35)
	label.outline_size = 12
	label.font_size = 96
	label.pixel_size = 0.012
	label.position = Vector3(0, 4.00, 0.05)
	banner.add_child(label)
	var subtitle: Label3D = Label3D.new()
	subtitle.text = "where the simulation remembers"
	subtitle.modulate = Color(0.85, 0.95, 1.0)
	subtitle.outline_modulate = Color(0.10, 0.20, 0.30)
	subtitle.outline_size = 8
	subtitle.font_size = 48
	subtitle.pixel_size = 0.010
	subtitle.position = Vector3(0, 3.10, 0.05)
	banner.add_child(subtitle)
	# 8 hanging icicles below the banner
	for i in 8:
		var ic: MeshInstance3D = MeshInstance3D.new()
		var im: PrismMesh = PrismMesh.new()
		im.size = Vector3(0.18, 0.65 + randf() * 0.40, 0.18)
		ic.mesh = im
		ic.material_override = ice_mat
		ic.position = Vector3(-2.10 + i * 0.60, 1.85, 0)
		ic.rotation_degrees = Vector3(180, 0, 0)
		banner.add_child(ic)


func _build_d5_crown_tower(geom: Node) -> void:
	## Epic-5 T97: crown ice tower — towering 4-tier ice spire with a
	## hovering crown of orbiting crystals at the peak. Visible from
	## across the entire eastern world half.
	var tower: Node3D = Node3D.new()
	tower.name = "CrownIceTower"
	tower.position = Vector3(D5_CENTER.x, 0.0, -2.0)
	geom.add_child(tower)
	var ice_mat: StandardMaterial3D = StandardMaterial3D.new()
	ice_mat.albedo_color = Color(0.65, 0.85, 0.95, 0.85)
	ice_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	ice_mat.emission_enabled = true
	ice_mat.emission = Color(0.40, 0.85, 0.95)
	ice_mat.emission_energy_multiplier = 1.4
	ice_mat.metallic = 0.55
	ice_mat.roughness = 0.10
	var bright_mat: StandardMaterial3D = StandardMaterial3D.new()
	bright_mat.albedo_color = Color(0.30, 1.0, 1.0)
	bright_mat.emission_enabled = true
	bright_mat.emission = Color(0.30, 1.0, 1.0)
	bright_mat.emission_energy_multiplier = 4.0
	bright_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	# Stone base
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.40, 0.45, 0.50)
	stone_mat.roughness = 0.92
	var base: MeshInstance3D = MeshInstance3D.new()
	var bm: BoxMesh = BoxMesh.new()
	bm.size = Vector3(5.50, 0.55, 5.50)
	base.mesh = bm
	base.material_override = stone_mat
	base.position = Vector3(0, 0.27, 0)
	tower.add_child(base)
	# 4 stacked tower tiers (each smaller and higher)
	var tier_sizes: Array = [
		{"radius": 1.85, "height": 3.40, "y": 2.20},
		{"radius": 1.40, "height": 3.40, "y": 5.85},
		{"radius": 1.0, "height": 3.40, "y": 9.50},
		{"radius": 0.65, "height": 3.40, "y": 13.15},
	]
	for tier in tier_sizes:
		var t: MeshInstance3D = MeshInstance3D.new()
		var tm: CylinderMesh = CylinderMesh.new()
		tm.top_radius = tier["radius"] * 0.85
		tm.bottom_radius = tier["radius"]
		tm.height = tier["height"]
		t.mesh = tm
		t.material_override = ice_mat
		t.position = Vector3(0, tier["y"], 0)
		tower.add_child(t)
	# Top crystal spire
	var spire: MeshInstance3D = MeshInstance3D.new()
	var spm: PrismMesh = PrismMesh.new()
	spm.size = Vector3(0.85, 2.85, 0.85)
	spire.mesh = spm
	spire.material_override = bright_mat
	spire.position = Vector3(0, 16.30, 0)
	tower.add_child(spire)
	# 6 orbiting crystal "crown jewels"
	var crown_pivot: Node3D = Node3D.new()
	crown_pivot.position = Vector3(0, 16.30, 0)
	tower.add_child(crown_pivot)
	for i in 6:
		var ang: float = (TAU / 6.0) * i
		var jewel: MeshInstance3D = MeshInstance3D.new()
		var jm: PrismMesh = PrismMesh.new()
		jm.size = Vector3(0.40, 0.85, 0.40)
		jewel.mesh = jm
		jewel.material_override = bright_mat
		jewel.position = Vector3(cos(ang) * 1.85, 0, sin(ang) * 1.85)
		crown_pivot.add_child(jewel)
	# Crown rotation
	var trot: Tween = crown_pivot.create_tween().set_loops()
	trot.tween_property(crown_pivot, "rotation_degrees:y", 360.0, 12.0)
	trot.tween_property(crown_pivot, "rotation_degrees:y", 0.0, 0.0)
	# Massive vertical light beam over the spire
	var beam: MeshInstance3D = MeshInstance3D.new()
	var beam_m: CylinderMesh = CylinderMesh.new()
	beam_m.top_radius = 0.30
	beam_m.bottom_radius = 0.95
	beam_m.height = 18.0
	beam.mesh = beam_m
	var beam_mat: StandardMaterial3D = StandardMaterial3D.new()
	beam_mat.albedo_color = Color(0.40, 0.85, 1.0, 0.45)
	beam_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	beam_mat.emission_enabled = true
	beam_mat.emission = Color(0.30, 0.95, 1.0)
	beam_mat.emission_energy_multiplier = 1.8
	beam_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	beam.material_override = beam_mat
	beam.position = Vector3(0, 26.0, 0)
	tower.add_child(beam)
	# Pulse beam
	var tw: Tween = beam.create_tween().set_loops()
	tw.tween_property(beam, "scale:x", 1.30, 2.0)
	tw.tween_property(beam, "scale:x", 0.85, 2.0)
	# Massive central light
	var light: OmniLight3D = OmniLight3D.new()
	light.light_color = Color(0.40, 0.95, 1.0)
	light.light_energy = 5.0
	light.omni_range = 24.0
	light.position = Vector3(0, 8.0, 0)
	tower.add_child(light)
	# Tower base collision
	var sb: StaticBody3D = StaticBody3D.new()
	sb.position = Vector3(0, 7.0, 0)
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cap: CylinderShape3D = CylinderShape3D.new()
	cap.radius = 1.85
	cap.height = 14.0
	cs.shape = cap
	sb.add_child(cs)
	tower.add_child(sb)


func _build_d5_district_plaque(geom: Node) -> void:
	## Epic-5 T98: dedication plaque on a stone pedestal at the entrance.
	var plaque: Node3D = Node3D.new()
	plaque.name = "D5Plaque"
	plaque.position = Vector3(D5_CENTER.x - 28.0, 0.0, 4.0)
	geom.add_child(plaque)
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.55, 0.62, 0.68)
	stone_mat.roughness = 0.92
	# Pedestal
	var ped: MeshInstance3D = MeshInstance3D.new()
	var pm: BoxMesh = BoxMesh.new()
	pm.size = Vector3(0.85, 1.20, 0.55)
	ped.mesh = pm
	ped.material_override = stone_mat
	ped.position = Vector3(0, 0.60, 0)
	plaque.add_child(ped)
	# Plaque face (silver)
	var face: MeshInstance3D = MeshInstance3D.new()
	var fm: BoxMesh = BoxMesh.new()
	fm.size = Vector3(0.75, 0.50, 0.06)
	face.mesh = fm
	var silver_mat: StandardMaterial3D = StandardMaterial3D.new()
	silver_mat.albedo_color = Color(0.75, 0.85, 0.95)
	silver_mat.metallic = 0.85
	silver_mat.roughness = 0.20
	face.material_override = silver_mat
	face.position = Vector3(0, 1.00, 0.30)
	face.rotation_degrees = Vector3(-15, 0, 0)
	plaque.add_child(face)
	var label: Label3D = Label3D.new()
	label.text = "FROZEN CACHE\nDistrict 05 — Iteration 05\nWhere code remembers what it was"
	label.modulate = Color(0.05, 0.10, 0.20)
	label.outline_modulate = Color(0.55, 0.85, 0.95)
	label.outline_size = 4
	label.font_size = 32
	label.pixel_size = 0.0035
	label.position = Vector3(0, 1.05, 0.36)
	label.rotation_degrees = Vector3(-15, 0, 0)
	plaque.add_child(label)
	# Pedestal collision
	var sb: StaticBody3D = StaticBody3D.new()
	sb.position = Vector3(0, 0.60, 0)
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(0.85, 1.20, 0.55)
	cs.shape = cb
	sb.add_child(cs)
	plaque.add_child(sb)


func _build_d5_ambient_tweak(geom: Node) -> void:
	## Epic-5 T99: cold ambient atmosphere — wide cyan fill light + pale
	## directional light from above.
	var amb: Node3D = Node3D.new()
	amb.name = "D5Ambient"
	amb.position = Vector3(D5_CENTER.x, 8.0, 0.0)
	geom.add_child(amb)
	var fill: OmniLight3D = OmniLight3D.new()
	fill.light_color = Color(0.55, 0.85, 1.0)
	fill.light_energy = 0.85
	fill.omni_range = 38.0
	amb.add_child(fill)
	var sun: DirectionalLight3D = DirectionalLight3D.new()
	sun.light_color = Color(0.85, 0.92, 1.0)
	sun.light_energy = 0.35
	sun.shadow_enabled = false
	sun.position = Vector3(0, 14.0, 0)
	sun.rotation_degrees = Vector3(-65, 35, 0)
	amb.add_child(sun)


func _build_d5_frost_monarch(geom: Node) -> void:
	## Epic-5 T100: FROST MONARCH — Epic 5 finale district boss. Tall
	## crowned ice queen with a flowing translucent gown, frost crown,
	## scepter, and a halo of orbiting frozen runes.
	var monarch: Node3D = Node3D.new()
	monarch.name = "FrostMonarch"
	monarch.position = Vector3(D5_CENTER.x + 24.0, 0.0, -22.0)
	geom.add_child(monarch)
	var ice_mat: StandardMaterial3D = StandardMaterial3D.new()
	ice_mat.albedo_color = Color(0.65, 0.85, 0.95, 0.85)
	ice_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	ice_mat.emission_enabled = true
	ice_mat.emission = Color(0.40, 0.85, 0.95)
	ice_mat.emission_energy_multiplier = 0.85
	ice_mat.metallic = 0.55
	ice_mat.roughness = 0.10
	var rune_mat: StandardMaterial3D = StandardMaterial3D.new()
	rune_mat.albedo_color = Color(0.30, 1.0, 1.0)
	rune_mat.emission_enabled = true
	rune_mat.emission = Color(0.30, 1.0, 1.0)
	rune_mat.emission_energy_multiplier = 4.0
	rune_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.45, 0.50, 0.55)
	stone_mat.roughness = 0.92
	# Stone pedestal
	var ped: MeshInstance3D = MeshInstance3D.new()
	var pm: BoxMesh = BoxMesh.new()
	pm.size = Vector3(3.85, 0.55, 3.85)
	ped.mesh = pm
	ped.material_override = stone_mat
	ped.position = Vector3(0, 0.27, 0)
	monarch.add_child(ped)
	# Body — flowing translucent gown (large tapered cone)
	var gown: MeshInstance3D = MeshInstance3D.new()
	var gm: CylinderMesh = CylinderMesh.new()
	gm.top_radius = 0.85
	gm.bottom_radius = 1.85
	gm.height = 4.20
	gown.mesh = gm
	gown.material_override = ice_mat
	gown.position = Vector3(0, 2.70, 0)
	monarch.add_child(gown)
	# Torso (smaller cylinder above gown)
	var torso: MeshInstance3D = MeshInstance3D.new()
	var tm: CylinderMesh = CylinderMesh.new()
	tm.top_radius = 0.55
	tm.bottom_radius = 0.85
	tm.height = 1.40
	torso.mesh = tm
	torso.material_override = ice_mat
	torso.position = Vector3(0, 5.50, 0)
	monarch.add_child(torso)
	# Head (sphere)
	var head: MeshInstance3D = MeshInstance3D.new()
	var hm: SphereMesh = SphereMesh.new()
	hm.radius = 0.45
	hm.height = 0.85
	head.mesh = hm
	head.material_override = ice_mat
	head.position = Vector3(0, 6.55, 0)
	monarch.add_child(head)
	# Frost crown — 6 spikes radiating up
	for i in 6:
		var ang: float = (TAU / 6.0) * i
		var spike: MeshInstance3D = MeshInstance3D.new()
		var spm: PrismMesh = PrismMesh.new()
		spm.size = Vector3(0.18, 0.85 + (i % 2) * 0.30, 0.18)
		spike.mesh = spm
		spike.material_override = rune_mat
		spike.position = Vector3(cos(ang) * 0.42, 7.20, sin(ang) * 0.42)
		monarch.add_child(spike)
	# Glowing eyes
	for ex in [-0.15, 0.15]:
		var eye: MeshInstance3D = MeshInstance3D.new()
		var em: SphereMesh = SphereMesh.new()
		em.radius = 0.07
		em.height = 0.14
		eye.mesh = em
		eye.material_override = rune_mat
		eye.position = Vector3(ex, 6.60, 0.42)
		monarch.add_child(eye)
		# Pulse
		var tw: Tween = eye.create_tween().set_loops()
		tw.tween_interval(randf() * 0.5)
		tw.tween_property(eye, "scale", Vector3.ONE * 1.30, 0.85)
		tw.tween_property(eye, "scale", Vector3.ONE * 0.85, 0.85)
	# Right arm holding scepter
	var right_arm: MeshInstance3D = MeshInstance3D.new()
	var ram: CylinderMesh = CylinderMesh.new()
	ram.top_radius = 0.18
	ram.bottom_radius = 0.18
	ram.height = 1.85
	right_arm.mesh = ram
	right_arm.material_override = ice_mat
	right_arm.position = Vector3(0.85, 5.30, 0)
	right_arm.rotation_degrees = Vector3(0, 0, -25)
	monarch.add_child(right_arm)
	# Left arm
	var left_arm: MeshInstance3D = MeshInstance3D.new()
	var lam: CylinderMesh = CylinderMesh.new()
	lam.top_radius = 0.18
	lam.bottom_radius = 0.18
	lam.height = 1.85
	left_arm.mesh = lam
	left_arm.material_override = ice_mat
	left_arm.position = Vector3(-0.85, 5.30, 0)
	left_arm.rotation_degrees = Vector3(0, 0, 25)
	monarch.add_child(left_arm)
	# Scepter (long staff + crystal orb top)
	var staff: MeshInstance3D = MeshInstance3D.new()
	var stm: CylinderMesh = CylinderMesh.new()
	stm.top_radius = 0.06
	stm.bottom_radius = 0.07
	stm.height = 4.20
	staff.mesh = stm
	staff.material_override = ice_mat
	staff.position = Vector3(1.55, 5.85, 0)
	staff.rotation_degrees = Vector3(0, 0, -10)
	monarch.add_child(staff)
	# Scepter orb
	var orb: MeshInstance3D = MeshInstance3D.new()
	var om: SphereMesh = SphereMesh.new()
	om.radius = 0.30
	om.height = 0.55
	orb.mesh = om
	orb.material_override = rune_mat
	orb.position = Vector3(1.85, 7.85, 0)
	monarch.add_child(orb)
	# Orb pulse
	var tor: Tween = orb.create_tween().set_loops()
	tor.tween_property(orb, "scale", Vector3.ONE * 1.20, 1.4)
	tor.tween_property(orb, "scale", Vector3.ONE * 0.85, 1.4)
	# 8 orbiting frozen runes around the head
	var halo: Node3D = Node3D.new()
	halo.position = Vector3(0, 7.20, 0)
	monarch.add_child(halo)
	for i in 8:
		var ang: float = (TAU / 8.0) * i
		var rune: MeshInstance3D = MeshInstance3D.new()
		var rm: BoxMesh = BoxMesh.new()
		rm.size = Vector3(0.20, 0.40, 0.04)
		rune.mesh = rm
		rune.material_override = rune_mat
		rune.position = Vector3(cos(ang) * 1.85, 0, sin(ang) * 1.85)
		rune.rotation = Vector3(0, ang + PI * 0.5, 0)
		halo.add_child(rune)
	var trot: Tween = halo.create_tween().set_loops()
	trot.tween_property(halo, "rotation_degrees:y", 360.0, 14.0)
	trot.tween_property(halo, "rotation_degrees:y", 0.0, 0.0)
	# Massive aura light
	var light: OmniLight3D = OmniLight3D.new()
	light.light_color = Color(0.40, 0.95, 1.0)
	light.light_energy = 5.5
	light.omni_range = 22.0
	light.position = Vector3(0, 6.55, 0)
	monarch.add_child(light)
	# Aura pulse
	var twl: Tween = light.create_tween().set_loops()
	twl.tween_property(light, "light_energy", 7.0, 2.4)
	twl.tween_property(light, "light_energy", 5.5, 2.4)
	# Title labels
	var title: Label3D = Label3D.new()
	title.text = "THE FROST MONARCH"
	title.modulate = Color(0.55, 0.95, 1.0)
	title.outline_modulate = Color(0.05, 0.20, 0.30)
	title.outline_size = 14
	title.font_size = 84
	title.pixel_size = 0.014
	title.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	title.position = Vector3(0, 9.50, 0)
	monarch.add_child(title)
	var subtitle: Label3D = Label3D.new()
	subtitle.text = "Sovereign of the cryogenic archive"
	subtitle.modulate = Color(0.85, 0.95, 1.0)
	subtitle.outline_modulate = Color(0.10, 0.20, 0.30)
	subtitle.outline_size = 8
	subtitle.font_size = 42
	subtitle.pixel_size = 0.011
	subtitle.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	subtitle.position = Vector3(0, 8.80, 0)
	monarch.add_child(subtitle)
	# Body collision
	var sb: StaticBody3D = StaticBody3D.new()
	sb.position = Vector3(0, 4.20, 0)
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cap: CapsuleShape3D = CapsuleShape3D.new()
	cap.radius = 1.85
	cap.height = 8.40
	cs.shape = cap
	sb.add_child(cs)
	monarch.add_child(sb)
	# Pedestal collision
	var psb: StaticBody3D = StaticBody3D.new()
	psb.position = Vector3(0, 0.27, 0)
	var pcs: CollisionShape3D = CollisionShape3D.new()
	var pcb: BoxShape3D = BoxShape3D.new()
	pcb.size = Vector3(3.85, 0.55, 3.85)
	pcs.shape = pcb
	psb.add_child(pcs)
	monarch.add_child(psb)
