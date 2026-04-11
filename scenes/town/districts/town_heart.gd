class_name TownHeartBuilder
extends Node

# ============================================================================
# Epic 10: Town Heart Plaza
# ============================================================================
# Grand central hub at world origin (0, 0, 0) where all 9 districts radiate
# from. Acts as the player's home base and the visual anchor of the town.
# Contains the Town Heart Beacon, 9 directional district markers, central
# fountain, paved compass plaza, and surrounding ceremonial features.
#
# All Epic 10 helpers live here. Each task adds an instance method called
# from build() in numerical order.

const TOWN_CENTER: Vector3 = Vector3(0, 0, 0)


func build(town: Node, geom: Node) -> void:
	print("[TownHeartBuilder] start")
	_build_th_beacon_monument(geom)
	_build_th_compass_plaza(geom)
	_build_th_district_nameplates(geom)
	_build_th_bench_ring(geom)
	_build_th_caretaker_npc(town)
	_build_th_perimeter_lampposts(geom)
	_build_th_save_shrine(geom)
	_build_th_quest_board(geom)
	_build_th_stash_chest(geom)
	_build_th_vendor_kiosk(geom)
	_build_th_data_fountain(geom)
	_build_th_practice_dummy(geom)
	_build_th_district_map_kiosk(geom)
	_build_th_banner_streamers(geom)
	_build_th_ambient_data_motes(geom)
	_build_th_vendor_npc(town)
	_build_th_combat_trainer_npc(town)
	_build_th_cartographer_npc(town)
	_build_th_shrine_keeper_npc(town)
	_build_th_quest_master_npc(town)
	_build_th_banker_npc(town)
	_build_th_fountain_wisher_npc(town)
	_build_th_planter_ring(geom)
	_build_th_welcome_arch(geom)
	_build_th_district_tribute_statues(geom)
	_build_th_bell_tower(geom)
	_build_th_archive_tower(geom)
	_build_th_forge_brazier_monument(geom)
	_build_th_observatory_dome(geom)
	_build_th_sky_lanterns(geom)
	_build_th_west_entry_arch(geom)
	_build_th_food_cart(geom)
	_build_th_food_cart_chef_npc(town)
	_build_th_busker_npc(town)
	_build_th_courier_drones(geom)
	_build_th_north_entry_arch(geom)
	_build_th_south_entry_arch(geom)
	_build_th_patrol_guard_npc(town)
	_build_th_running_child_npc(town)
	_build_th_sky_data_highway(geom)
	_build_th_east_approach_road(geom)
	_build_th_north_approach_road(geom)
	_build_th_west_approach_road(geom)
	_build_th_south_approach_road(geom)
	_build_th_waystones(geom)
	_build_th_sky_trams(geom)
	_build_th_data_tree_grove(geom)
	_build_th_corner_mini_fountains(geom)
	_build_th_open_pavilion(geom)
	_build_th_hex_gazebo(geom)
	_build_th_road_junctions(geom)
	_build_th_ground_runes(geom)
	_build_th_road_benches(geom)
	_build_th_road_planters(geom)
	_build_th_courier_hut(geom)
	_build_th_bookstall(geom)
	_build_th_postman_npc(town)
	_build_th_bookkeeper_npc(town)
	_build_th_sweeper_bot_npc(town)
	_build_th_bellringer_npc(town)
	_build_th_fountain_cherub_sprites(geom)
	_build_th_iterations_memorial_wall(geom)
	_build_th_memorial_mourner_npc(town)
	_build_th_wishing_pond(geom)
	_build_th_pond_caretaker_npc(town)
	_build_th_botanical_conservatory(geom)
	_build_th_botanist_npc(town)
	_build_th_constellation_map(geom)
	_build_th_stargazer_npc(town)
	_build_th_combat_trial_pit(geom)
	_build_th_pit_master_npc(town)
	print("[TownHeartBuilder] done")


func _build_th_beacon_monument(geom: Node) -> void:
	## Epic-10 T1: Town Heart Beacon — central monument at world origin.
	## Stepped basalt-and-brass pedestal with a tall iron spire crowned by
	## a glowing cyan-orange dual-color core (the "data heart" of the town),
	## ringed by 8 small directional markers (one per cardinal + ordinal),
	## with an OmniLight wash and ambient cinder/data motes drifting above.
	var pivot: Node3D = Node3D.new()
	pivot.name = "TH_BeaconMonument"
	pivot.position = TOWN_CENTER + Vector3(0, 0, 0)
	geom.add_child(pivot)
	# ---- Materials ----
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.20, 0.22, 0.26)
	stone_mat.metallic = 0.18
	stone_mat.roughness = 0.85
	stone_mat.emission_enabled = true
	stone_mat.emission = Color(0.30, 0.45, 0.65)
	stone_mat.emission_energy_multiplier = 0.18
	var brass_mat: StandardMaterial3D = StandardMaterial3D.new()
	brass_mat.albedo_color = Color(0.85, 0.55, 0.18)
	brass_mat.metallic = 0.95
	brass_mat.roughness = 0.30
	brass_mat.emission_enabled = true
	brass_mat.emission = Color(1.0, 0.50, 0.10)
	brass_mat.emission_energy_multiplier = 0.55
	var iron_mat: StandardMaterial3D = StandardMaterial3D.new()
	iron_mat.albedo_color = Color(0.18, 0.16, 0.18)
	iron_mat.metallic = 0.85
	iron_mat.roughness = 0.45
	iron_mat.emission_enabled = true
	iron_mat.emission = Color(0.45, 0.55, 0.65)
	iron_mat.emission_energy_multiplier = 0.30
	var data_mat: StandardMaterial3D = StandardMaterial3D.new()
	data_mat.albedo_color = Color(0.30, 0.85, 1.0)
	data_mat.emission_enabled = true
	data_mat.emission = Color(0.40, 0.85, 1.0)
	data_mat.emission_energy_multiplier = 8.5
	data_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var ember_mat: StandardMaterial3D = StandardMaterial3D.new()
	ember_mat.albedo_color = Color(1.0, 0.55, 0.10)
	ember_mat.emission_enabled = true
	ember_mat.emission = Color(1.0, 0.55, 0.10)
	ember_mat.emission_energy_multiplier = 7.5
	ember_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	# ---- 3-tier basalt pedestal ----
	var tier_data: Array = [
		{"r": 4.20, "h": 0.45, "y": 0.22},
		{"r": 3.40, "h": 0.45, "y": 0.67},
		{"r": 2.55, "h": 0.45, "y": 1.12},
	]
	for td in tier_data:
		var t: MeshInstance3D = MeshInstance3D.new()
		var tm: CylinderMesh = CylinderMesh.new()
		tm.top_radius = td["r"]
		tm.bottom_radius = td["r"] + 0.20
		tm.height = td["h"]
		t.mesh = tm
		t.material_override = stone_mat
		t.position = Vector3(0, td["y"], 0)
		pivot.add_child(t)
	# Combined pedestal collision
	var ped_sb: StaticBody3D = StaticBody3D.new()
	ped_sb.position = Vector3(0, 0.70, 0)
	var ped_cs: CollisionShape3D = CollisionShape3D.new()
	var ped_cyl: CylinderShape3D = CylinderShape3D.new()
	ped_cyl.top_radius = 2.55
	ped_cyl.bottom_radius = 4.40
	ped_cyl.height = 1.40
	ped_cs.shape = ped_cyl
	ped_sb.add_child(ped_cs)
	pivot.add_child(ped_sb)
	# Brass top plate on the pedestal
	var top_plate: MeshInstance3D = MeshInstance3D.new()
	var tpm: CylinderMesh = CylinderMesh.new()
	tpm.top_radius = 2.65
	tpm.bottom_radius = 2.65
	tpm.height = 0.10
	top_plate.mesh = tpm
	top_plate.material_override = brass_mat
	top_plate.position = Vector3(0, 1.40, 0)
	pivot.add_child(top_plate)
	# ---- Tall iron spire ----
	var spire: MeshInstance3D = MeshInstance3D.new()
	var spm: CylinderMesh = CylinderMesh.new()
	spm.top_radius = 0.20
	spm.bottom_radius = 0.55
	spm.height = 8.00
	spire.mesh = spm
	spire.material_override = iron_mat
	spire.position = Vector3(0, 5.45, 0)
	pivot.add_child(spire)
	# Spire collision
	var sp_sb: StaticBody3D = StaticBody3D.new()
	sp_sb.position = Vector3(0, 5.45, 0)
	var sp_cs: CollisionShape3D = CollisionShape3D.new()
	var sp_cyl: CylinderShape3D = CylinderShape3D.new()
	sp_cyl.top_radius = 0.20
	sp_cyl.bottom_radius = 0.55
	sp_cyl.height = 8.00
	sp_cs.shape = sp_cyl
	sp_sb.add_child(sp_cs)
	pivot.add_child(sp_sb)
	# Brass spire bands (3 wraps)
	for by in [3.20, 5.50, 7.80]:
		var band: MeshInstance3D = MeshInstance3D.new()
		var bdm: TorusMesh = TorusMesh.new()
		bdm.inner_radius = 0.32
		bdm.outer_radius = 0.45
		band.mesh = bdm
		band.material_override = brass_mat
		band.position = Vector3(0, by, 0)
		pivot.add_child(band)
	# ---- Glowing dual-core data heart at the spire's top ----
	# Outer brass cage (torus)
	var cage: MeshInstance3D = MeshInstance3D.new()
	var cm: TorusMesh = TorusMesh.new()
	cm.inner_radius = 0.55
	cm.outer_radius = 0.85
	cage.mesh = cm
	cage.material_override = brass_mat
	cage.position = Vector3(0, 9.80, 0)
	pivot.add_child(cage)
	# Inner data core (cyan unshaded sphere)
	var data_core: MeshInstance3D = MeshInstance3D.new()
	var dcm: SphereMesh = SphereMesh.new()
	dcm.radius = 0.55
	dcm.height = 1.05
	data_core.mesh = dcm
	data_core.material_override = data_mat
	data_core.position = Vector3(0, 9.80, 0)
	pivot.add_child(data_core)
	# Inner ember core (smaller amber sphere overlaid for warm contrast)
	var ember_core: MeshInstance3D = MeshInstance3D.new()
	var ecm: SphereMesh = SphereMesh.new()
	ecm.radius = 0.32
	ecm.height = 0.62
	ember_core.mesh = ecm
	ember_core.material_override = ember_mat
	ember_core.position = Vector3(0, 9.80, 0)
	pivot.add_child(ember_core)
	# ---- 8 directional cardinal/ordinal markers around the pedestal ----
	# Each marker is a small brass arrow pointing outward, with a glowing tip
	for i in 8:
		var ang: float = float(i) / 8.0 * TAU
		var dx: float = cos(ang)
		var dz: float = sin(ang)
		# Arrow shaft (small box pointing outward)
		var arrow: MeshInstance3D = MeshInstance3D.new()
		var am: BoxMesh = BoxMesh.new()
		am.size = Vector3(0.85, 0.16, 0.20)
		arrow.mesh = am
		arrow.material_override = brass_mat
		arrow.position = Vector3(dx * 3.10, 1.50, dz * 3.10)
		arrow.rotation.y = ang
		pivot.add_child(arrow)
		# Arrow tip (small prism)
		var tip: MeshInstance3D = MeshInstance3D.new()
		var tipm: PrismMesh = PrismMesh.new()
		tipm.size = Vector3(0.20, 0.16, 0.30)
		tip.mesh = tipm
		tip.material_override = data_mat
		tip.position = Vector3(dx * 3.55, 1.55, dz * 3.55)
		tip.rotation.y = ang - PI / 2.0
		pivot.add_child(tip)
	# ---- Strong central OmniLight (cyan-tinted wash) ----
	var lt_data: OmniLight3D = OmniLight3D.new()
	lt_data.position = Vector3(0, 9.80, 0)
	lt_data.light_color = Color(0.45, 0.85, 1.0)
	lt_data.light_energy = 5.5
	lt_data.omni_range = 22.0
	pivot.add_child(lt_data)
	# Warmer ground OmniLight at the brass top plate
	var lt_warm: OmniLight3D = OmniLight3D.new()
	lt_warm.position = Vector3(0, 1.80, 0)
	lt_warm.light_color = Color(1.0, 0.55, 0.15)
	lt_warm.light_energy = 3.0
	lt_warm.omni_range = 12.0
	pivot.add_child(lt_warm)
	# ---- Drifting data motes around the core ----
	var motes: GPUParticles3D = GPUParticles3D.new()
	motes.position = Vector3(0, 9.80, 0)
	motes.amount = 36
	motes.lifetime = 3.5
	var pmat: ParticleProcessMaterial = ParticleProcessMaterial.new()
	pmat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	pmat.emission_sphere_radius = 1.10
	pmat.direction = Vector3(0, 1, 0)
	pmat.spread = 180.0
	pmat.initial_velocity_min = 0.4
	pmat.initial_velocity_max = 0.9
	pmat.gravity = Vector3(0, 0.0, 0)
	pmat.scale_min = 0.06
	pmat.scale_max = 0.12
	pmat.color = Color(0.45, 0.85, 1.0, 1.0)
	motes.process_material = pmat
	var psmesh: SphereMesh = SphereMesh.new()
	psmesh.radius = 0.05
	psmesh.height = 0.10
	motes.draw_pass_1 = psmesh
	pivot.add_child(motes)
	# ---- Pulses ----
	# Data core pulse — slow breath (5s cycle)
	var dpulse: Tween = pivot.create_tween().set_loops()
	dpulse.tween_property(data_mat, "emission_energy_multiplier", 11.0, 2.5).set_ease(Tween.EASE_IN_OUT)
	dpulse.tween_property(data_mat, "emission_energy_multiplier", 6.0, 2.5).set_ease(Tween.EASE_IN_OUT)
	# Ember core pulse — faster heartbeat (3s cycle)
	var epulse: Tween = pivot.create_tween().set_loops()
	epulse.tween_property(ember_mat, "emission_energy_multiplier", 10.0, 1.5).set_ease(Tween.EASE_IN_OUT)
	epulse.tween_property(ember_mat, "emission_energy_multiplier", 5.0, 1.5).set_ease(Tween.EASE_IN_OUT)
	# Slow spire spin so the cage rotates around the cores
	var spin: Tween = pivot.create_tween().set_loops()
	spin.tween_property(cage, "rotation:y", TAU, 8.0)


func _build_th_compass_plaza(geom: Node) -> void:
	## Epic-10 T2: paved compass plaza floor surrounding the beacon, with
	## 8 radial paths shooting out in cardinal/ordinal directions, a
	## central rune ring, and concentric paving circles. The actual hub
	## ground that the player walks on around the beacon monument.
	var pivot: Node3D = Node3D.new()
	pivot.name = "TH_CompassPlaza"
	pivot.position = TOWN_CENTER + Vector3(0, 0, 0)
	geom.add_child(pivot)
	# ---- Materials ----
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.22, 0.24, 0.28)
	stone_mat.metallic = 0.18
	stone_mat.roughness = 0.85
	stone_mat.emission_enabled = true
	stone_mat.emission = Color(0.30, 0.45, 0.60)
	stone_mat.emission_energy_multiplier = 0.18
	var dark_stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	dark_stone_mat.albedo_color = Color(0.16, 0.18, 0.22)
	dark_stone_mat.metallic = 0.18
	dark_stone_mat.roughness = 0.85
	dark_stone_mat.emission_enabled = true
	dark_stone_mat.emission = Color(0.25, 0.40, 0.55)
	dark_stone_mat.emission_energy_multiplier = 0.18
	var brass_mat: StandardMaterial3D = StandardMaterial3D.new()
	brass_mat.albedo_color = Color(0.85, 0.55, 0.18)
	brass_mat.metallic = 0.95
	brass_mat.roughness = 0.30
	brass_mat.emission_enabled = true
	brass_mat.emission = Color(1.0, 0.50, 0.10)
	brass_mat.emission_energy_multiplier = 0.55
	var seam_mat: StandardMaterial3D = StandardMaterial3D.new()
	seam_mat.albedo_color = Color(0.45, 0.85, 1.0)
	seam_mat.emission_enabled = true
	seam_mat.emission = Color(0.45, 0.85, 1.0)
	seam_mat.emission_energy_multiplier = 5.5
	seam_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	# ---- Wide outer plaza disc (low ground slab) ----
	var outer: MeshInstance3D = MeshInstance3D.new()
	var om: CylinderMesh = CylinderMesh.new()
	om.top_radius = 14.00
	om.bottom_radius = 14.20
	om.height = 0.10
	outer.mesh = om
	outer.material_override = stone_mat
	outer.position = Vector3(0, 0.05, 0)
	pivot.add_child(outer)
	# Plaza collision (so player has solid ground under the beacon)
	var plaza_sb: StaticBody3D = StaticBody3D.new()
	plaza_sb.position = Vector3(0, 0.05, 0)
	var plaza_cs: CollisionShape3D = CollisionShape3D.new()
	var plaza_cyl: CylinderShape3D = CylinderShape3D.new()
	plaza_cyl.top_radius = 14.00
	plaza_cyl.bottom_radius = 14.20
	plaza_cyl.height = 0.20
	plaza_cs.shape = plaza_cyl
	plaza_sb.add_child(plaza_cs)
	pivot.add_child(plaza_sb)
	# ---- Inner ring (lighter accent disc) ----
	var inner: MeshInstance3D = MeshInstance3D.new()
	var im: CylinderMesh = CylinderMesh.new()
	im.top_radius = 9.50
	im.bottom_radius = 9.50
	im.height = 0.08
	inner.mesh = im
	inner.material_override = dark_stone_mat
	inner.position = Vector3(0, 0.10, 0)
	pivot.add_child(inner)
	# ---- Brass concentric ring trim (between outer and inner) ----
	var trim_outer: MeshInstance3D = MeshInstance3D.new()
	var tom: TorusMesh = TorusMesh.new()
	tom.inner_radius = 13.40
	tom.outer_radius = 13.85
	trim_outer.mesh = tom
	trim_outer.material_override = brass_mat
	trim_outer.position = Vector3(0, 0.13, 0)
	pivot.add_child(trim_outer)
	var trim_inner: MeshInstance3D = MeshInstance3D.new()
	var tim: TorusMesh = TorusMesh.new()
	tim.inner_radius = 9.10
	tim.outer_radius = 9.45
	trim_inner.mesh = tim
	trim_inner.material_override = brass_mat
	trim_inner.position = Vector3(0, 0.13, 0)
	pivot.add_child(trim_inner)
	# ---- Central rune ring (just outside the beacon pedestal at radius ~5) ----
	var rune_ring: MeshInstance3D = MeshInstance3D.new()
	var rrm: TorusMesh = TorusMesh.new()
	rrm.inner_radius = 4.80
	rrm.outer_radius = 5.20
	rune_ring.mesh = rrm
	rune_ring.material_override = seam_mat
	rune_ring.position = Vector3(0, 0.14, 0)
	pivot.add_child(rune_ring)
	# ---- 8 radial paths shooting out from the rune ring to the outer rim ----
	# Each path is a long narrow box laid flat on the plaza
	for i in 8:
		var ang: float = float(i) / 8.0 * TAU
		var dx: float = cos(ang)
		var dz: float = sin(ang)
		# Path slab — center of the path is at radius (5.5 + 13) / 2 ≈ 9.25
		var path: MeshInstance3D = MeshInstance3D.new()
		var pm: BoxMesh = BoxMesh.new()
		pm.size = Vector3(8.20, 0.06, 1.40)
		path.mesh = pm
		path.material_override = brass_mat
		path.position = Vector3(dx * 9.40, 0.16, dz * 9.40)
		path.rotation.y = ang
		pivot.add_child(path)
		# Glowing center seam stripe down the middle of each path
		var seam: MeshInstance3D = MeshInstance3D.new()
		var sm: BoxMesh = BoxMesh.new()
		sm.size = Vector3(7.80, 0.05, 0.20)
		seam.mesh = sm
		seam.material_override = seam_mat
		seam.position = Vector3(dx * 9.40, 0.20, dz * 9.40)
		seam.rotation.y = ang
		pivot.add_child(seam)
	# ---- Inner ring of 16 small brass paving studs at radius ~7.5 ----
	for i in 16:
		var ang: float = float(i) / 16.0 * TAU
		var stud: MeshInstance3D = MeshInstance3D.new()
		var stm: CylinderMesh = CylinderMesh.new()
		stm.top_radius = 0.18
		stm.bottom_radius = 0.18
		stm.height = 0.05
		stud.mesh = stm
		stud.material_override = brass_mat
		stud.position = Vector3(cos(ang) * 7.50, 0.15, sin(ang) * 7.50)
		pivot.add_child(stud)
	# ---- Outer ring of 24 small brass paving studs at radius ~12 ----
	for i in 24:
		var ang: float = float(i) / 24.0 * TAU
		var stud: MeshInstance3D = MeshInstance3D.new()
		var stm: CylinderMesh = CylinderMesh.new()
		stm.top_radius = 0.16
		stm.bottom_radius = 0.16
		stm.height = 0.05
		stud.mesh = stm
		stud.material_override = brass_mat
		stud.position = Vector3(cos(ang) * 12.00, 0.15, sin(ang) * 12.00)
		pivot.add_child(stud)
	# ---- Slow seam pulse ----
	var spulse: Tween = pivot.create_tween().set_loops()
	spulse.tween_property(seam_mat, "emission_energy_multiplier", 7.5, 2.4).set_ease(Tween.EASE_IN_OUT)
	spulse.tween_property(seam_mat, "emission_energy_multiplier", 4.0, 2.4).set_ease(Tween.EASE_IN_OUT)


func _build_th_district_nameplates(geom: Node) -> void:
	## Epic-10 T3: 8 directional district nameplates at the end of each
	## radial path. Each nameplate: stepped basalt stand, brass plate face,
	## 6 glowing letter blocks (representing the district name), brass
	## emblem disc with district-themed accent color, and a small reading
	## lantern. Tells players which way to travel for each destination.
	var pivot: Node3D = Node3D.new()
	pivot.name = "TH_DistrictNameplates"
	pivot.position = TOWN_CENTER + Vector3(0, 0, 0)
	geom.add_child(pivot)
	# ---- Materials ----
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.20, 0.22, 0.26)
	stone_mat.metallic = 0.18
	stone_mat.roughness = 0.85
	stone_mat.emission_enabled = true
	stone_mat.emission = Color(0.30, 0.45, 0.60)
	stone_mat.emission_energy_multiplier = 0.18
	var brass_mat: StandardMaterial3D = StandardMaterial3D.new()
	brass_mat.albedo_color = Color(0.85, 0.55, 0.18)
	brass_mat.metallic = 0.95
	brass_mat.roughness = 0.30
	brass_mat.emission_enabled = true
	brass_mat.emission = Color(1.0, 0.50, 0.10)
	brass_mat.emission_energy_multiplier = 0.55
	var flame_mat: StandardMaterial3D = StandardMaterial3D.new()
	flame_mat.albedo_color = Color(1.0, 0.65, 0.20)
	flame_mat.emission_enabled = true
	flame_mat.emission = Color(1.0, 0.55, 0.10)
	flame_mat.emission_energy_multiplier = 8.0
	flame_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	# District accent colors — one per direction (matches each district's theme)
	# Order: E, NE, N, NW, W, SW, S, SE
	# E=D1 cyan/orange data, NE=D2 toxic green, N=D3 violet, NW=D4 green
	# W=D5 ice blue, SW=D6 magenta, S=D7 sandstone, SE=D8 ocean blue, [D9 amber via beacon]
	var accent_colors: Array = [
		Color(0.40, 0.85, 1.0),   # E — D1 data cyan
		Color(0.55, 1.0, 0.40),   # NE — D2 toxic green
		Color(0.75, 0.45, 1.0),   # N — D3 violet
		Color(0.40, 0.95, 0.55),  # NW — D4 bloom green
		Color(0.65, 0.85, 1.0),   # W — D5 ice blue
		Color(1.0, 0.40, 0.85),   # SW — D6 neon magenta
		Color(1.0, 0.75, 0.40),   # S — D7 sandstone amber
		Color(0.30, 0.55, 1.0),   # SE — D8 ocean blue
	]
	# Letter widths spelling 6-letter abbreviations of each district
	# (cosmetic — they're just unshaded blocks, not actual text)
	for i in 8:
		var ang: float = float(i) / 8.0 * TAU
		var dx: float = cos(ang)
		var dz: float = sin(ang)
		# Stand position — at the end of each radial path (radius ~13.5)
		var sp: Vector3 = Vector3(dx * 13.50, 0, dz * 13.50)
		var sgroup: Node3D = Node3D.new()
		sgroup.name = "Nameplate_" + str(i)
		sgroup.position = sp
		# Face inward toward the beacon
		sgroup.rotation.y = atan2(-dz, -dx) - PI / 2.0
		pivot.add_child(sgroup)
		# Per-stand accent material (so all elements of this stand share its color)
		var accent_mat: StandardMaterial3D = StandardMaterial3D.new()
		accent_mat.albedo_color = accent_colors[i]
		accent_mat.emission_enabled = true
		accent_mat.emission = accent_colors[i]
		accent_mat.emission_energy_multiplier = 6.0
		accent_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		# ---- Stepped basalt stand ----
		# Base
		var base: MeshInstance3D = MeshInstance3D.new()
		var bm: BoxMesh = BoxMesh.new()
		bm.size = Vector3(2.40, 0.40, 1.10)
		base.mesh = bm
		base.material_override = stone_mat
		base.position = Vector3(0, 0.20, 0)
		sgroup.add_child(base)
		# Top
		var top: MeshInstance3D = MeshInstance3D.new()
		var tm: BoxMesh = BoxMesh.new()
		tm.size = Vector3(2.00, 0.30, 0.85)
		top.mesh = tm
		top.material_override = stone_mat
		top.position = Vector3(0, 0.55, 0)
		sgroup.add_child(top)
		# Stand collision
		var sb: StaticBody3D = StaticBody3D.new()
		sb.position = Vector3(0, 0.35, 0)
		var cs: CollisionShape3D = CollisionShape3D.new()
		var bsh: BoxShape3D = BoxShape3D.new()
		bsh.size = Vector3(2.40, 0.70, 1.10)
		cs.shape = bsh
		sb.add_child(cs)
		sgroup.add_child(sb)
		# ---- Brass plate face (vertical, facing the beacon center) ----
		var plate: MeshInstance3D = MeshInstance3D.new()
		var plm: BoxMesh = BoxMesh.new()
		plm.size = Vector3(2.10, 1.30, 0.10)
		plate.mesh = plm
		plate.material_override = brass_mat
		plate.position = Vector3(0, 1.40, -0.30)
		sgroup.add_child(plate)
		# Plate brass support posts (2 vertical posts holding the plate up)
		for spx in [-0.85, 0.85]:
			var post: MeshInstance3D = MeshInstance3D.new()
			var pm: CylinderMesh = CylinderMesh.new()
			pm.top_radius = 0.06
			pm.bottom_radius = 0.07
			pm.height = 0.85
			post.mesh = pm
			post.material_override = brass_mat
			post.position = Vector3(spx, 1.10, -0.30)
			sgroup.add_child(post)
		# ---- 6 glowing letter blocks across the brass plate ----
		for col in 6:
			var lx: float = -0.85 + float(col) * 0.34
			var letter: MeshInstance3D = MeshInstance3D.new()
			var lm: BoxMesh = BoxMesh.new()
			lm.size = Vector3(0.22, 0.55, 0.05)
			letter.mesh = lm
			letter.material_override = accent_mat
			letter.position = Vector3(lx, 1.40, -0.36)
			sgroup.add_child(letter)
		# ---- Brass emblem disc above the letters (district crest) ----
		var disc: MeshInstance3D = MeshInstance3D.new()
		var dm: TorusMesh = TorusMesh.new()
		dm.inner_radius = 0.18
		dm.outer_radius = 0.30
		disc.mesh = dm
		disc.material_override = accent_mat
		disc.position = Vector3(0, 2.05, -0.36)
		disc.rotation.x = PI / 2.0
		sgroup.add_child(disc)
		# Disc crossbar
		var dbar: MeshInstance3D = MeshInstance3D.new()
		var dbm: BoxMesh = BoxMesh.new()
		dbm.size = Vector3(0.10, 0.55, 0.06)
		dbar.mesh = dbm
		dbar.material_override = accent_mat
		dbar.position = Vector3(0, 2.05, -0.38)
		sgroup.add_child(dbar)
		# ---- Reading lantern on top of the stand (left side) ----
		var lan_post: MeshInstance3D = MeshInstance3D.new()
		var lpm: CylinderMesh = CylinderMesh.new()
		lpm.top_radius = 0.05
		lpm.bottom_radius = 0.06
		lpm.height = 1.20
		lan_post.mesh = lpm
		lan_post.material_override = brass_mat
		lan_post.position = Vector3(-0.85, 1.30, 0.30)
		sgroup.add_child(lan_post)
		# Lantern bulb
		var lan: MeshInstance3D = MeshInstance3D.new()
		var lansm: SphereMesh = SphereMesh.new()
		lansm.radius = 0.13
		lansm.height = 0.26
		lan.mesh = lansm
		lan.material_override = flame_mat
		lan.position = Vector3(-0.85, 1.95, 0.30)
		sgroup.add_child(lan)
		# Lantern OmniLight
		var lt: OmniLight3D = OmniLight3D.new()
		lt.position = Vector3(-0.85, 1.95, 0.30)
		lt.light_color = Color(1.0, 0.55, 0.15)
		lt.light_energy = 1.8
		lt.omni_range = 5.5
		sgroup.add_child(lt)
		# ---- Per-stand accent pulse — slow breath ----
		var apulse: Tween = sgroup.create_tween().set_loops()
		apulse.tween_property(accent_mat, "emission_energy_multiplier", 8.0, 1.8).set_ease(Tween.EASE_IN_OUT)
		apulse.tween_property(accent_mat, "emission_energy_multiplier", 4.5, 1.8).set_ease(Tween.EASE_IN_OUT)
	# ---- Shared lantern flame flicker for all 8 nameplates ----
	var fpulse: Tween = pivot.create_tween().set_loops()
	fpulse.tween_property(flame_mat, "emission_energy_multiplier", 10.0, 0.45).set_ease(Tween.EASE_IN_OUT)
	fpulse.tween_property(flame_mat, "emission_energy_multiplier", 7.0, 0.45).set_ease(Tween.EASE_IN_OUT)


func _build_th_bench_ring(geom: Node) -> void:
	## Epic-10 T4: 8 stone benches arranged between the radial paths around
	## the plaza perimeter. Each bench: 2 short basalt legs + long basalt
	## seat slab + brass back rail + small under-seat glow strip. Player
	## can sit/lean on them between district trips.
	var pivot: Node3D = Node3D.new()
	pivot.name = "TH_BenchRing"
	pivot.position = TOWN_CENTER + Vector3(0, 0, 0)
	geom.add_child(pivot)
	# ---- Materials ----
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.20, 0.22, 0.26)
	stone_mat.metallic = 0.18
	stone_mat.roughness = 0.85
	stone_mat.emission_enabled = true
	stone_mat.emission = Color(0.30, 0.45, 0.60)
	stone_mat.emission_energy_multiplier = 0.18
	var brass_mat: StandardMaterial3D = StandardMaterial3D.new()
	brass_mat.albedo_color = Color(0.85, 0.55, 0.18)
	brass_mat.metallic = 0.95
	brass_mat.roughness = 0.30
	brass_mat.emission_enabled = true
	brass_mat.emission = Color(1.0, 0.50, 0.10)
	brass_mat.emission_energy_multiplier = 0.45
	var glow_mat: StandardMaterial3D = StandardMaterial3D.new()
	glow_mat.albedo_color = Color(0.45, 0.85, 1.0)
	glow_mat.emission_enabled = true
	glow_mat.emission = Color(0.45, 0.85, 1.0)
	glow_mat.emission_energy_multiplier = 4.5
	glow_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	# Bench positions — between the radial paths (offset by half a sector)
	for i in 8:
		var ang: float = (float(i) + 0.5) / 8.0 * TAU
		var dx: float = cos(ang)
		var dz: float = sin(ang)
		var bp: Vector3 = Vector3(dx * 11.50, 0, dz * 11.50)
		var bgroup: Node3D = Node3D.new()
		bgroup.name = "Bench_" + str(i)
		bgroup.position = bp
		# Face inward toward the beacon
		bgroup.rotation.y = atan2(-dz, -dx) - PI / 2.0
		pivot.add_child(bgroup)
		# ---- 2 short basalt legs ----
		for lx in [-0.95, 0.95]:
			var leg: MeshInstance3D = MeshInstance3D.new()
			var lm: BoxMesh = BoxMesh.new()
			lm.size = Vector3(0.30, 0.55, 0.45)
			leg.mesh = lm
			leg.material_override = stone_mat
			leg.position = Vector3(lx, 0.27, 0)
			bgroup.add_child(leg)
		# ---- Long basalt seat slab ----
		var seat: MeshInstance3D = MeshInstance3D.new()
		var sm: BoxMesh = BoxMesh.new()
		sm.size = Vector3(2.40, 0.16, 0.65)
		seat.mesh = sm
		seat.material_override = stone_mat
		seat.position = Vector3(0, 0.62, 0)
		bgroup.add_child(seat)
		# Bench collision (so player can stand on it)
		var sb: StaticBody3D = StaticBody3D.new()
		sb.position = Vector3(0, 0.40, 0)
		var cs: CollisionShape3D = CollisionShape3D.new()
		var bsh: BoxShape3D = BoxShape3D.new()
		bsh.size = Vector3(2.40, 0.80, 0.65)
		cs.shape = bsh
		sb.add_child(cs)
		bgroup.add_child(sb)
		# ---- Brass back rail (2 vertical posts + 1 horizontal top bar) ----
		for rpx in [-1.05, 1.05]:
			var post: MeshInstance3D = MeshInstance3D.new()
			var pm: CylinderMesh = CylinderMesh.new()
			pm.top_radius = 0.04
			pm.bottom_radius = 0.05
			pm.height = 0.55
			post.mesh = pm
			post.material_override = brass_mat
			post.position = Vector3(rpx, 0.95, 0.30)
			bgroup.add_child(post)
		var rail: MeshInstance3D = MeshInstance3D.new()
		var rm: BoxMesh = BoxMesh.new()
		rm.size = Vector3(2.20, 0.06, 0.06)
		rail.mesh = rm
		rail.material_override = brass_mat
		rail.position = Vector3(0, 1.20, 0.30)
		bgroup.add_child(rail)
		# ---- Small under-seat cyan glow strip ----
		var glow: MeshInstance3D = MeshInstance3D.new()
		var gm: BoxMesh = BoxMesh.new()
		gm.size = Vector3(2.20, 0.05, 0.06)
		glow.mesh = gm
		glow.material_override = glow_mat
		glow.position = Vector3(0, 0.50, -0.30)
		bgroup.add_child(glow)
	# Shared bench glow pulse
	var gpulse: Tween = pivot.create_tween().set_loops()
	gpulse.tween_property(glow_mat, "emission_energy_multiplier", 6.0, 2.2).set_ease(Tween.EASE_IN_OUT)
	gpulse.tween_property(glow_mat, "emission_energy_multiplier", 3.5, 2.2).set_ease(Tween.EASE_IN_OUT)


func _build_th_caretaker_npc(town: Node) -> void:
	## Epic-10 T5: Town Caretaker Cipher — friendly hub keeper standing
	## just outside the beacon at the south radial path. Robe in town
	## hub colors (slate + brass + cyan accents), holding a glowing data
	## tablet, with a brass headset visor and a slow welcoming wave.
	var slots: Node3D = town.get_node_or_null("NPCSlots") as Node3D
	if slots == null:
		return
	var slot: Marker3D = Marker3D.new()
	slot.name = "THCaretakerSlot"
	# Stand on the south radial path, just outside the rune ring
	slot.position = TOWN_CENTER + Vector3(0, 0, 6.5)
	slots.add_child(slot)
	var npc_scene: PackedScene = load("res://scenes/entities/npcs/VillagerR3.tscn") as PackedScene
	if npc_scene == null:
		return
	var npc: Node3D = npc_scene.instantiate() as Node3D
	npc.name = "THCaretaker"
	if "npc_name" in npc:
		npc.set("npc_name", "Caretaker Cipher")
	if "npc_id" in npc:
		npc.set("npc_id", "th_caretaker_cipher")
	# Face the beacon (-Z direction)
	npc.rotation.y = PI
	slot.add_child(npc)
	# Materials
	var robe_mat: StandardMaterial3D = StandardMaterial3D.new()
	robe_mat.albedo_color = Color(0.22, 0.26, 0.32)
	robe_mat.roughness = 0.85
	robe_mat.metallic = 0.18
	robe_mat.emission_enabled = true
	robe_mat.emission = Color(0.30, 0.45, 0.65)
	robe_mat.emission_energy_multiplier = 0.25
	var brass_mat: StandardMaterial3D = StandardMaterial3D.new()
	brass_mat.albedo_color = Color(0.85, 0.55, 0.18)
	brass_mat.metallic = 0.95
	brass_mat.roughness = 0.30
	brass_mat.emission_enabled = true
	brass_mat.emission = Color(1.0, 0.50, 0.10)
	brass_mat.emission_energy_multiplier = 0.55
	var data_mat: StandardMaterial3D = StandardMaterial3D.new()
	data_mat.albedo_color = Color(0.45, 0.85, 1.0)
	data_mat.emission_enabled = true
	data_mat.emission = Color(0.45, 0.85, 1.0)
	data_mat.emission_energy_multiplier = 7.0
	data_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	# ---- Long slate robe ----
	var robe: MeshInstance3D = MeshInstance3D.new()
	var rmesh: BoxMesh = BoxMesh.new()
	rmesh.size = Vector3(0.95, 1.65, 0.55)
	robe.mesh = rmesh
	robe.material_override = robe_mat
	robe.position = Vector3(0, 0.85, 0)
	npc.add_child(robe)
	# Brass collar trim
	var collar: MeshInstance3D = MeshInstance3D.new()
	var colm: BoxMesh = BoxMesh.new()
	colm.size = Vector3(0.95, 0.10, 0.55)
	collar.mesh = colm
	collar.material_override = brass_mat
	collar.position = Vector3(0, 1.65, 0)
	npc.add_child(collar)
	# Cyan vertical accent stripe down the chest (data seam)
	var seam: MeshInstance3D = MeshInstance3D.new()
	var seamesh: BoxMesh = BoxMesh.new()
	seamesh.size = Vector3(0.16, 1.50, 0.06)
	seam.mesh = seamesh
	seam.material_override = data_mat
	seam.position = Vector3(0, 0.92, -0.30)
	npc.add_child(seam)
	# Brass shoulder pauldrons (small)
	for sx in [-0.55, 0.55]:
		var paul: MeshInstance3D = MeshInstance3D.new()
		var pm: SphereMesh = SphereMesh.new()
		pm.radius = 0.18
		pm.height = 0.35
		paul.mesh = pm
		paul.material_override = brass_mat
		paul.position = Vector3(sx, 1.55, 0)
		paul.scale = Vector3(1.0, 0.55, 1.0)
		npc.add_child(paul)
	# ---- Brass headset visor band over the head ----
	var visor: MeshInstance3D = MeshInstance3D.new()
	var vm: TorusMesh = TorusMesh.new()
	vm.inner_radius = 0.30
	vm.outer_radius = 0.36
	visor.mesh = vm
	visor.material_override = brass_mat
	visor.position = Vector3(0, 1.95, 0)
	visor.rotation.x = PI / 2.0
	npc.add_child(visor)
	# Glowing visor lens (front)
	var lens: MeshInstance3D = MeshInstance3D.new()
	var lm: BoxMesh = BoxMesh.new()
	lm.size = Vector3(0.55, 0.10, 0.04)
	lens.mesh = lm
	lens.material_override = data_mat
	lens.position = Vector3(0, 1.92, -0.32)
	npc.add_child(lens)
	# Headset side dish (small disc on the left side)
	var ear_dish: MeshInstance3D = MeshInstance3D.new()
	var edm: CylinderMesh = CylinderMesh.new()
	edm.top_radius = 0.10
	edm.bottom_radius = 0.10
	edm.height = 0.05
	ear_dish.mesh = edm
	ear_dish.material_override = brass_mat
	ear_dish.position = Vector3(-0.32, 1.92, 0)
	ear_dish.rotation.z = PI / 2.0
	npc.add_child(ear_dish)
	# ---- Data tablet held in the right hand on a tween pivot ----
	# Hand pivot — small Node3D anchored at his right wrist
	var hand_pivot: Node3D = Node3D.new()
	hand_pivot.position = Vector3(0.55, 1.20, -0.10)
	npc.add_child(hand_pivot)
	# Tablet body — flat brass box
	var tablet: MeshInstance3D = MeshInstance3D.new()
	var tm: BoxMesh = BoxMesh.new()
	tm.size = Vector3(0.40, 0.55, 0.05)
	tablet.mesh = tm
	tablet.material_override = brass_mat
	tablet.position = Vector3(0, 0, 0)
	hand_pivot.add_child(tablet)
	# Tablet glowing screen (smaller cyan rectangle on the front)
	var screen: MeshInstance3D = MeshInstance3D.new()
	var scrm: BoxMesh = BoxMesh.new()
	scrm.size = Vector3(0.32, 0.45, 0.03)
	screen.mesh = scrm
	screen.material_override = data_mat
	screen.position = Vector3(0, 0, -0.04)
	hand_pivot.add_child(screen)
	# 3 small data icon dots glowing on the screen
	for iy in [0.12, 0.0, -0.12]:
		var icon: MeshInstance3D = MeshInstance3D.new()
		var icm: SphereMesh = SphereMesh.new()
		icm.radius = 0.04
		icm.height = 0.08
		icon.mesh = icm
		icon.material_override = data_mat
		icon.position = Vector3(0, iy, -0.06)
		hand_pivot.add_child(icon)
	# ---- Subtle warm OmniLight aura ----
	var lt: OmniLight3D = OmniLight3D.new()
	lt.position = Vector3(0, 1.50, -0.20)
	lt.light_color = Color(0.65, 0.85, 1.0)
	lt.light_energy = 1.6
	lt.omni_range = 4.5
	npc.add_child(lt)
	# ---- Welcoming wave tween — slow tablet hand rocking back and forth ----
	var wave: Tween = npc.create_tween().set_loops()
	wave.tween_property(hand_pivot, "rotation:z", 0.30, 1.6).set_ease(Tween.EASE_IN_OUT)
	wave.tween_property(hand_pivot, "rotation:z", -0.10, 1.6).set_ease(Tween.EASE_IN_OUT)
	# Visor lens + tablet screen pulse (shared data material)
	var dpulse: Tween = npc.create_tween().set_loops()
	dpulse.tween_property(data_mat, "emission_energy_multiplier", 9.0, 1.8).set_ease(Tween.EASE_IN_OUT)
	dpulse.tween_property(data_mat, "emission_energy_multiplier", 5.0, 1.8).set_ease(Tween.EASE_IN_OUT)


func _build_th_perimeter_lampposts(geom: Node) -> void:
	## Epic-10 T6: 8 tall brass lampposts at the plaza's outer edge,
	## offset between the radial paths so they don't block the corridors.
	## Each lamppost: stepped basalt base, 4.5m brass shaft with 2 wrap
	## bands, brass arched top, large unshaded amber lantern bulb in a
	## brass cage, strong OmniLight, and 2 small data motes drifting
	## around the bulb.
	var pivot: Node3D = Node3D.new()
	pivot.name = "TH_PerimeterLampposts"
	pivot.position = TOWN_CENTER + Vector3(0, 0, 0)
	geom.add_child(pivot)
	# ---- Materials ----
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.20, 0.22, 0.26)
	stone_mat.metallic = 0.18
	stone_mat.roughness = 0.85
	stone_mat.emission_enabled = true
	stone_mat.emission = Color(0.30, 0.45, 0.60)
	stone_mat.emission_energy_multiplier = 0.18
	var brass_mat: StandardMaterial3D = StandardMaterial3D.new()
	brass_mat.albedo_color = Color(0.85, 0.55, 0.18)
	brass_mat.metallic = 0.95
	brass_mat.roughness = 0.30
	brass_mat.emission_enabled = true
	brass_mat.emission = Color(1.0, 0.50, 0.10)
	brass_mat.emission_energy_multiplier = 0.55
	var bulb_mat: StandardMaterial3D = StandardMaterial3D.new()
	bulb_mat.albedo_color = Color(1.0, 0.75, 0.30)
	bulb_mat.emission_enabled = true
	bulb_mat.emission = Color(1.0, 0.65, 0.20)
	bulb_mat.emission_energy_multiplier = 9.0
	bulb_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	# Place 8 lampposts between the radial paths at radius 13 (just inside outer rim)
	for i in 8:
		var ang: float = (float(i) + 0.5) / 8.0 * TAU
		var dx: float = cos(ang)
		var dz: float = sin(ang)
		var lp: Vector3 = Vector3(dx * 13.20, 0, dz * 13.20)
		var lgroup: Node3D = Node3D.new()
		lgroup.name = "Lamppost_" + str(i)
		lgroup.position = lp
		# Face inward
		lgroup.rotation.y = atan2(-dz, -dx) - PI / 2.0
		pivot.add_child(lgroup)
		# ---- Stepped basalt base ----
		var base1: MeshInstance3D = MeshInstance3D.new()
		var b1m: BoxMesh = BoxMesh.new()
		b1m.size = Vector3(0.85, 0.30, 0.85)
		base1.mesh = b1m
		base1.material_override = stone_mat
		base1.position = Vector3(0, 0.15, 0)
		lgroup.add_child(base1)
		var base2: MeshInstance3D = MeshInstance3D.new()
		var b2m: BoxMesh = BoxMesh.new()
		b2m.size = Vector3(0.65, 0.20, 0.65)
		base2.mesh = b2m
		base2.material_override = stone_mat
		base2.position = Vector3(0, 0.40, 0)
		lgroup.add_child(base2)
		# Base collision
		var base_sb: StaticBody3D = StaticBody3D.new()
		base_sb.position = Vector3(0, 0.25, 0)
		var base_cs: CollisionShape3D = CollisionShape3D.new()
		var base_bsh: BoxShape3D = BoxShape3D.new()
		base_bsh.size = Vector3(0.85, 0.50, 0.85)
		base_cs.shape = base_bsh
		base_sb.add_child(base_cs)
		lgroup.add_child(base_sb)
		# ---- Brass shaft (4.5m tall, slight taper) ----
		var shaft: MeshInstance3D = MeshInstance3D.new()
		var sm: CylinderMesh = CylinderMesh.new()
		sm.top_radius = 0.10
		sm.bottom_radius = 0.14
		sm.height = 4.50
		shaft.mesh = sm
		shaft.material_override = brass_mat
		shaft.position = Vector3(0, 2.75, 0)
		lgroup.add_child(shaft)
		# Shaft collision
		var shaft_sb: StaticBody3D = StaticBody3D.new()
		shaft_sb.position = Vector3(0, 2.75, 0)
		var shaft_cs: CollisionShape3D = CollisionShape3D.new()
		var shaft_cyl: CylinderShape3D = CylinderShape3D.new()
		shaft_cyl.top_radius = 0.10
		shaft_cyl.bottom_radius = 0.14
		shaft_cyl.height = 4.50
		shaft_cs.shape = shaft_cyl
		shaft_sb.add_child(shaft_cs)
		lgroup.add_child(shaft_sb)
		# ---- 2 brass wrap bands on the shaft ----
		for by in [1.50, 3.80]:
			var band: MeshInstance3D = MeshInstance3D.new()
			var bdm: TorusMesh = TorusMesh.new()
			bdm.inner_radius = 0.13
			bdm.outer_radius = 0.20
			band.mesh = bdm
			band.material_override = brass_mat
			band.position = Vector3(0, by, 0)
			lgroup.add_child(band)
		# ---- Arched top crossbar (extending inward over the path) ----
		var arch: MeshInstance3D = MeshInstance3D.new()
		var am: BoxMesh = BoxMesh.new()
		am.size = Vector3(0.10, 0.12, 0.85)
		arch.mesh = am
		arch.material_override = brass_mat
		arch.position = Vector3(0, 5.05, -0.40)
		lgroup.add_child(arch)
		# Top finial decorative ball
		var finial: MeshInstance3D = MeshInstance3D.new()
		var fm: SphereMesh = SphereMesh.new()
		fm.radius = 0.12
		fm.height = 0.24
		finial.mesh = fm
		finial.material_override = brass_mat
		finial.position = Vector3(0, 5.18, 0)
		lgroup.add_child(finial)
		# ---- Lantern cage (4 thin brass pillars + top + bottom rings) ----
		var cage_top: MeshInstance3D = MeshInstance3D.new()
		var ctm: TorusMesh = TorusMesh.new()
		ctm.inner_radius = 0.22
		ctm.outer_radius = 0.30
		cage_top.mesh = ctm
		cage_top.material_override = brass_mat
		cage_top.position = Vector3(0, 4.95, -0.80)
		lgroup.add_child(cage_top)
		var cage_bot: MeshInstance3D = MeshInstance3D.new()
		cage_bot.mesh = ctm
		cage_bot.material_override = brass_mat
		cage_bot.position = Vector3(0, 4.40, -0.80)
		lgroup.add_child(cage_bot)
		for cpx in [-0.22, 0.22]:
			for cpz in [-1.02, -0.58]:
				var cpost: MeshInstance3D = MeshInstance3D.new()
				var cpm: CylinderMesh = CylinderMesh.new()
				cpm.top_radius = 0.025
				cpm.bottom_radius = 0.025
				cpm.height = 0.55
				cpost.mesh = cpm
				cpost.material_override = brass_mat
				cpost.position = Vector3(cpx, 4.67, cpz)
				lgroup.add_child(cpost)
		# ---- Large unshaded amber lantern bulb ----
		var bulb: MeshInstance3D = MeshInstance3D.new()
		var bm: SphereMesh = SphereMesh.new()
		bm.radius = 0.30
		bm.height = 0.60
		bulb.mesh = bm
		bulb.material_override = bulb_mat
		bulb.position = Vector3(0, 4.67, -0.80)
		lgroup.add_child(bulb)
		# ---- Strong OmniLight from the bulb ----
		var lt: OmniLight3D = OmniLight3D.new()
		lt.position = Vector3(0, 4.67, -0.80)
		lt.light_color = Color(1.0, 0.65, 0.20)
		lt.light_energy = 4.5
		lt.omni_range = 14.0
		lgroup.add_child(lt)
		# ---- 2 small drifting data motes around the bulb ----
		var motes: GPUParticles3D = GPUParticles3D.new()
		motes.position = Vector3(0, 4.67, -0.80)
		motes.amount = 8
		motes.lifetime = 2.4
		var pmat: ParticleProcessMaterial = ParticleProcessMaterial.new()
		pmat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
		pmat.emission_sphere_radius = 0.40
		pmat.direction = Vector3(0, 1, 0)
		pmat.spread = 180.0
		pmat.initial_velocity_min = 0.2
		pmat.initial_velocity_max = 0.5
		pmat.gravity = Vector3(0, 0.0, 0)
		pmat.scale_min = 0.04
		pmat.scale_max = 0.08
		pmat.color = Color(1.0, 0.65, 0.20, 1.0)
		motes.process_material = pmat
		var psmesh: SphereMesh = SphereMesh.new()
		psmesh.radius = 0.04
		psmesh.height = 0.08
		motes.draw_pass_1 = psmesh
		lgroup.add_child(motes)
	# Shared bulb pulse for all 8 lampposts
	var bpulse: Tween = pivot.create_tween().set_loops()
	bpulse.tween_property(bulb_mat, "emission_energy_multiplier", 11.0, 1.6).set_ease(Tween.EASE_IN_OUT)
	bpulse.tween_property(bulb_mat, "emission_energy_multiplier", 7.5, 1.6).set_ease(Tween.EASE_IN_OUT)


func _build_th_save_shrine(geom: Node) -> void:
	## Epic-10 T7: small save/rest shrine just outside the rune ring on
	## the north radial path. Stepped basalt altar with brass top, central
	## glowing save crystal pillar, brass arch over the crystal, 4 candle
	## tapers around the corners, and a glowing rune circle on the ground.
	var pivot: Node3D = Node3D.new()
	pivot.name = "TH_SaveShrine"
	# North radial path, just outside the rune ring at radius 6.5
	pivot.position = TOWN_CENTER + Vector3(0, 0, -6.5)
	geom.add_child(pivot)
	# Materials
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.20, 0.22, 0.26)
	stone_mat.metallic = 0.18
	stone_mat.roughness = 0.85
	stone_mat.emission_enabled = true
	stone_mat.emission = Color(0.30, 0.45, 0.60)
	stone_mat.emission_energy_multiplier = 0.20
	var brass_mat: StandardMaterial3D = StandardMaterial3D.new()
	brass_mat.albedo_color = Color(0.85, 0.55, 0.18)
	brass_mat.metallic = 0.95
	brass_mat.roughness = 0.30
	brass_mat.emission_enabled = true
	brass_mat.emission = Color(1.0, 0.50, 0.10)
	brass_mat.emission_energy_multiplier = 0.55
	var crystal_mat: StandardMaterial3D = StandardMaterial3D.new()
	crystal_mat.albedo_color = Color(0.45, 0.85, 1.0)
	crystal_mat.emission_enabled = true
	crystal_mat.emission = Color(0.45, 0.85, 1.0)
	crystal_mat.emission_energy_multiplier = 8.5
	crystal_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var flame_mat: StandardMaterial3D = StandardMaterial3D.new()
	flame_mat.albedo_color = Color(1.0, 0.65, 0.20)
	flame_mat.emission_enabled = true
	flame_mat.emission = Color(1.0, 0.55, 0.10)
	flame_mat.emission_energy_multiplier = 7.5
	flame_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	# ---- Stepped basalt altar (2 levels) ----
	var base1: MeshInstance3D = MeshInstance3D.new()
	var b1m: BoxMesh = BoxMesh.new()
	b1m.size = Vector3(2.40, 0.40, 2.40)
	base1.mesh = b1m
	base1.material_override = stone_mat
	base1.position = Vector3(0, 0.20, 0)
	pivot.add_child(base1)
	var base2: MeshInstance3D = MeshInstance3D.new()
	var b2m: BoxMesh = BoxMesh.new()
	b2m.size = Vector3(1.85, 0.55, 1.85)
	base2.mesh = b2m
	base2.material_override = stone_mat
	base2.position = Vector3(0, 0.68, 0)
	pivot.add_child(base2)
	# Combined collision
	var sb: StaticBody3D = StaticBody3D.new()
	sb.position = Vector3(0, 0.50, 0)
	var cs: CollisionShape3D = CollisionShape3D.new()
	var bsh: BoxShape3D = BoxShape3D.new()
	bsh.size = Vector3(2.40, 1.00, 2.40)
	cs.shape = bsh
	sb.add_child(cs)
	pivot.add_child(sb)
	# Brass top plate
	var top_plate: MeshInstance3D = MeshInstance3D.new()
	var tpm: BoxMesh = BoxMesh.new()
	tpm.size = Vector3(1.95, 0.10, 1.95)
	top_plate.mesh = tpm
	top_plate.material_override = brass_mat
	top_plate.position = Vector3(0, 1.00, 0)
	pivot.add_child(top_plate)
	# ---- Central save crystal pillar ----
	# Crystal pedestal (small brass disc)
	var pedestal: MeshInstance3D = MeshInstance3D.new()
	var pedm: CylinderMesh = CylinderMesh.new()
	pedm.top_radius = 0.30
	pedm.bottom_radius = 0.40
	pedm.height = 0.18
	pedestal.mesh = pedm
	pedestal.material_override = brass_mat
	pedestal.position = Vector3(0, 1.14, 0)
	pivot.add_child(pedestal)
	# Crystal body (tall prism)
	var crystal: MeshInstance3D = MeshInstance3D.new()
	var crm: PrismMesh = PrismMesh.new()
	crm.size = Vector3(0.55, 1.65, 0.55)
	crystal.mesh = crm
	crystal.material_override = crystal_mat
	crystal.position = Vector3(0, 2.05, 0)
	pivot.add_child(crystal)
	# Crystal collision so player has something to interact with
	var crys_sb: StaticBody3D = StaticBody3D.new()
	crys_sb.position = Vector3(0, 2.05, 0)
	var crys_cs: CollisionShape3D = CollisionShape3D.new()
	var crys_bsh: BoxShape3D = BoxShape3D.new()
	crys_bsh.size = Vector3(0.55, 1.65, 0.55)
	crys_cs.shape = crys_bsh
	crys_sb.add_child(crys_cs)
	pivot.add_child(crys_sb)
	# ---- Brass arch over the crystal ----
	# 2 vertical posts at the corners of the top plate
	for px in [-0.85, 0.85]:
		var post: MeshInstance3D = MeshInstance3D.new()
		var pm: CylinderMesh = CylinderMesh.new()
		pm.top_radius = 0.07
		pm.bottom_radius = 0.08
		pm.height = 2.20
		post.mesh = pm
		post.material_override = brass_mat
		post.position = Vector3(px, 2.15, 0)
		pivot.add_child(post)
	# Top crossbar
	var crossbar: MeshInstance3D = MeshInstance3D.new()
	var cbm: BoxMesh = BoxMesh.new()
	cbm.size = Vector3(2.00, 0.18, 0.18)
	crossbar.mesh = cbm
	crossbar.material_override = brass_mat
	crossbar.position = Vector3(0, 3.20, 0)
	pivot.add_child(crossbar)
	# Hanging crystal ornament from the crossbar (small upside-down prism)
	var orn: MeshInstance3D = MeshInstance3D.new()
	var ornm: PrismMesh = PrismMesh.new()
	ornm.size = Vector3(0.25, 0.40, 0.25)
	orn.mesh = ornm
	orn.material_override = crystal_mat
	orn.position = Vector3(0, 2.95, 0)
	orn.rotation.x = PI
	pivot.add_child(orn)
	# ---- 4 candle tapers at the corners of the top plate ----
	for cpos in [Vector3(-0.80, 1.10, -0.80), Vector3(0.80, 1.10, -0.80), Vector3(-0.80, 1.10, 0.80), Vector3(0.80, 1.10, 0.80)]:
		# Candle body
		var candle: MeshInstance3D = MeshInstance3D.new()
		var cm: CylinderMesh = CylinderMesh.new()
		cm.top_radius = 0.05
		cm.bottom_radius = 0.06
		cm.height = 0.40
		candle.mesh = cm
		candle.material_override = brass_mat
		candle.position = cpos + Vector3(0, 0.15, 0)
		pivot.add_child(candle)
		# Flame
		var flame: MeshInstance3D = MeshInstance3D.new()
		var flm: SphereMesh = SphereMesh.new()
		flm.radius = 0.08
		flm.height = 0.18
		flame.mesh = flm
		flame.material_override = flame_mat
		flame.position = cpos + Vector3(0, 0.42, 0)
		pivot.add_child(flame)
		# Tiny OmniLight
		var lt: OmniLight3D = OmniLight3D.new()
		lt.position = cpos + Vector3(0, 0.42, 0)
		lt.light_color = Color(1.0, 0.55, 0.15)
		lt.light_energy = 1.2
		lt.omni_range = 3.5
		pivot.add_child(lt)
	# ---- Strong central crystal OmniLight ----
	var clt: OmniLight3D = OmniLight3D.new()
	clt.position = Vector3(0, 2.30, 0)
	clt.light_color = Color(0.45, 0.85, 1.0)
	clt.light_energy = 4.0
	clt.omni_range = 11.0
	pivot.add_child(clt)
	# ---- Glowing rune circle on the ground in front of the altar ----
	var rune_ring: MeshInstance3D = MeshInstance3D.new()
	var rrm: TorusMesh = TorusMesh.new()
	rrm.inner_radius = 1.00
	rrm.outer_radius = 1.20
	rune_ring.mesh = rrm
	rune_ring.material_override = crystal_mat
	rune_ring.position = Vector3(0, 0.06, 1.85)
	pivot.add_child(rune_ring)
	# 4 small rune dots on the ring
	for i in 4:
		var ang: float = float(i) / 4.0 * TAU
		var dot: MeshInstance3D = MeshInstance3D.new()
		var dm: SphereMesh = SphereMesh.new()
		dm.radius = 0.10
		dm.height = 0.05
		dot.mesh = dm
		dot.material_override = crystal_mat
		dot.position = Vector3(cos(ang) * 1.10, 0.07, 1.85 + sin(ang) * 1.10)
		dot.scale = Vector3(1.0, 0.30, 1.0)
		pivot.add_child(dot)
	# ---- Drifting data motes around the crystal ----
	var motes: GPUParticles3D = GPUParticles3D.new()
	motes.position = Vector3(0, 2.20, 0)
	motes.amount = 22
	motes.lifetime = 2.6
	var pmat: ParticleProcessMaterial = ParticleProcessMaterial.new()
	pmat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	pmat.emission_sphere_radius = 0.50
	pmat.direction = Vector3(0, 1, 0)
	pmat.spread = 180.0
	pmat.initial_velocity_min = 0.3
	pmat.initial_velocity_max = 0.7
	pmat.gravity = Vector3(0, 0.0, 0)
	pmat.scale_min = 0.05
	pmat.scale_max = 0.10
	pmat.color = Color(0.45, 0.85, 1.0, 1.0)
	motes.process_material = pmat
	var psmesh: SphereMesh = SphereMesh.new()
	psmesh.radius = 0.05
	psmesh.height = 0.10
	motes.draw_pass_1 = psmesh
	pivot.add_child(motes)
	# ---- Pulses ----
	# Crystal + ornament + rune ring pulse
	var cpulse: Tween = pivot.create_tween().set_loops()
	cpulse.tween_property(crystal_mat, "emission_energy_multiplier", 10.0, 1.6).set_ease(Tween.EASE_IN_OUT)
	cpulse.tween_property(crystal_mat, "emission_energy_multiplier", 6.5, 1.6).set_ease(Tween.EASE_IN_OUT)
	# Candle flame flicker
	var fpulse: Tween = pivot.create_tween().set_loops()
	fpulse.tween_property(flame_mat, "emission_energy_multiplier", 9.0, 0.4).set_ease(Tween.EASE_IN_OUT)
	fpulse.tween_property(flame_mat, "emission_energy_multiplier", 6.5, 0.4).set_ease(Tween.EASE_IN_OUT)


func _build_th_quest_board(geom: Node) -> void:
	## Epic-10 T8: outdoor quest board on the SE radial path. Stepped
	## basalt base, brass frame, large central glowing data screen, 3
	## hanging quest poster panels along the bottom, brass top crest
	## with the town heart emblem, and 2 small pin-up lanterns above.
	var pivot: Node3D = Node3D.new()
	pivot.name = "TH_QuestBoard"
	# SE radial path (angle = pi/4 from +X), at radius 6.5
	pivot.position = TOWN_CENTER + Vector3(cos(PI / 4.0) * 6.5, 0, sin(PI / 4.0) * 6.5)
	# Face the beacon center (pointing inward)
	pivot.rotation.y = -PI / 4.0 - PI / 2.0
	geom.add_child(pivot)
	# Materials
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.20, 0.22, 0.26)
	stone_mat.metallic = 0.18
	stone_mat.roughness = 0.85
	stone_mat.emission_enabled = true
	stone_mat.emission = Color(0.30, 0.45, 0.60)
	stone_mat.emission_energy_multiplier = 0.18
	var brass_mat: StandardMaterial3D = StandardMaterial3D.new()
	brass_mat.albedo_color = Color(0.85, 0.55, 0.18)
	brass_mat.metallic = 0.95
	brass_mat.roughness = 0.30
	brass_mat.emission_enabled = true
	brass_mat.emission = Color(1.0, 0.50, 0.10)
	brass_mat.emission_energy_multiplier = 0.55
	var screen_mat: StandardMaterial3D = StandardMaterial3D.new()
	screen_mat.albedo_color = Color(0.45, 0.85, 1.0)
	screen_mat.emission_enabled = true
	screen_mat.emission = Color(0.45, 0.85, 1.0)
	screen_mat.emission_energy_multiplier = 6.5
	screen_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var poster_mat: StandardMaterial3D = StandardMaterial3D.new()
	poster_mat.albedo_color = Color(0.95, 0.85, 0.55)
	poster_mat.roughness = 0.85
	poster_mat.emission_enabled = true
	poster_mat.emission = Color(1.0, 0.65, 0.20)
	poster_mat.emission_energy_multiplier = 0.45
	var flame_mat: StandardMaterial3D = StandardMaterial3D.new()
	flame_mat.albedo_color = Color(1.0, 0.65, 0.20)
	flame_mat.emission_enabled = true
	flame_mat.emission = Color(1.0, 0.55, 0.10)
	flame_mat.emission_energy_multiplier = 7.5
	flame_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	# ---- Stepped basalt base ----
	var base: MeshInstance3D = MeshInstance3D.new()
	var bm: BoxMesh = BoxMesh.new()
	bm.size = Vector3(2.40, 0.40, 1.20)
	base.mesh = bm
	base.material_override = stone_mat
	base.position = Vector3(0, 0.20, 0)
	pivot.add_child(base)
	# Base collision
	var sb: StaticBody3D = StaticBody3D.new()
	sb.position = Vector3(0, 0.20, 0)
	var cs: CollisionShape3D = CollisionShape3D.new()
	var bsh: BoxShape3D = BoxShape3D.new()
	bsh.size = Vector3(2.40, 0.40, 1.20)
	cs.shape = bsh
	sb.add_child(cs)
	pivot.add_child(sb)
	# ---- 2 brass support posts ----
	for px in [-1.05, 1.05]:
		var post: MeshInstance3D = MeshInstance3D.new()
		var pm: CylinderMesh = CylinderMesh.new()
		pm.top_radius = 0.07
		pm.bottom_radius = 0.09
		pm.height = 3.20
		post.mesh = pm
		post.material_override = brass_mat
		post.position = Vector3(px, 1.95, 0)
		pivot.add_child(post)
		# Post collision
		var post_sb: StaticBody3D = StaticBody3D.new()
		post_sb.position = Vector3(px, 1.95, 0)
		var post_cs: CollisionShape3D = CollisionShape3D.new()
		var post_cyl: CylinderShape3D = CylinderShape3D.new()
		post_cyl.top_radius = 0.10
		post_cyl.bottom_radius = 0.10
		post_cyl.height = 3.20
		post_cs.shape = post_cyl
		post_sb.add_child(post_cs)
		pivot.add_child(post_sb)
	# ---- Brass frame around the central data screen ----
	var frame: MeshInstance3D = MeshInstance3D.new()
	var fm: BoxMesh = BoxMesh.new()
	fm.size = Vector3(2.30, 1.55, 0.10)
	frame.mesh = fm
	frame.material_override = brass_mat
	frame.position = Vector3(0, 2.50, -0.20)
	pivot.add_child(frame)
	# ---- Large central glowing data screen ----
	var screen: MeshInstance3D = MeshInstance3D.new()
	var smm: BoxMesh = BoxMesh.new()
	smm.size = Vector3(2.05, 1.30, 0.05)
	screen.mesh = smm
	screen.material_override = screen_mat
	screen.position = Vector3(0, 2.50, -0.27)
	pivot.add_child(screen)
	# ---- 4 horizontal data text rows on the screen (small dim stripe boxes) ----
	for row in 4:
		var ry: float = 2.95 - float(row) * 0.30
		var stripe: MeshInstance3D = MeshInstance3D.new()
		var stm: BoxMesh = BoxMesh.new()
		stm.size = Vector3(1.65, 0.10, 0.04)
		stripe.mesh = stm
		stripe.material_override = brass_mat
		stripe.position = Vector3(0, ry, -0.30)
		pivot.add_child(stripe)
	# ---- Brass top crest with town heart emblem ----
	var top_crest: MeshInstance3D = MeshInstance3D.new()
	var tcm: BoxMesh = BoxMesh.new()
	tcm.size = Vector3(2.40, 0.30, 0.20)
	top_crest.mesh = tcm
	top_crest.material_override = brass_mat
	top_crest.position = Vector3(0, 3.45, -0.20)
	pivot.add_child(top_crest)
	# Crest center torus emblem (cyan unshaded)
	var emblem: MeshInstance3D = MeshInstance3D.new()
	var emm: TorusMesh = TorusMesh.new()
	emm.inner_radius = 0.12
	emm.outer_radius = 0.20
	emblem.mesh = emm
	emblem.material_override = screen_mat
	emblem.position = Vector3(0, 3.45, -0.32)
	emblem.rotation.x = PI / 2.0
	pivot.add_child(emblem)
	# Emblem center bar
	var ebar: MeshInstance3D = MeshInstance3D.new()
	var ebm: BoxMesh = BoxMesh.new()
	ebm.size = Vector3(0.06, 0.40, 0.04)
	ebar.mesh = ebm
	ebar.material_override = screen_mat
	ebar.position = Vector3(0, 3.45, -0.34)
	pivot.add_child(ebar)
	# ---- 3 hanging quest poster panels along the base of the frame ----
	for i in 3:
		var px: float = -0.65 + float(i) * 0.65
		# Poster body (papyrus rectangle)
		var poster: MeshInstance3D = MeshInstance3D.new()
		var pmm: BoxMesh = BoxMesh.new()
		pmm.size = Vector3(0.50, 0.65, 0.04)
		poster.mesh = pmm
		poster.material_override = poster_mat
		poster.position = Vector3(px, 1.20, -0.18)
		pivot.add_child(poster)
		# Brass nail at the top
		var nail: MeshInstance3D = MeshInstance3D.new()
		var nm: SphereMesh = SphereMesh.new()
		nm.radius = 0.04
		nm.height = 0.08
		nail.mesh = nm
		nail.material_override = brass_mat
		nail.position = Vector3(px, 1.50, -0.22)
		pivot.add_child(nail)
	# ---- 2 small pin-up brass lanterns above the frame ----
	for lx in [-0.85, 0.85]:
		# Lantern bracket
		var bracket: MeshInstance3D = MeshInstance3D.new()
		var bktm: BoxMesh = BoxMesh.new()
		bktm.size = Vector3(0.10, 0.20, 0.30)
		bracket.mesh = bktm
		bracket.material_override = brass_mat
		bracket.position = Vector3(lx, 3.15, -0.28)
		pivot.add_child(bracket)
		# Lantern flame
		var flame: MeshInstance3D = MeshInstance3D.new()
		var flm: SphereMesh = SphereMesh.new()
		flm.radius = 0.13
		flm.height = 0.26
		flame.mesh = flm
		flame.material_override = flame_mat
		flame.position = Vector3(lx, 3.30, -0.40)
		pivot.add_child(flame)
		# Lantern OmniLight
		var lt: OmniLight3D = OmniLight3D.new()
		lt.position = Vector3(lx, 3.30, -0.40)
		lt.light_color = Color(1.0, 0.55, 0.15)
		lt.light_energy = 1.8
		lt.omni_range = 5.0
		pivot.add_child(lt)
	# ---- Strong screen OmniLight (cyan wash on the brass) ----
	var screen_lt: OmniLight3D = OmniLight3D.new()
	screen_lt.position = Vector3(0, 2.50, -0.40)
	screen_lt.light_color = Color(0.45, 0.85, 1.0)
	screen_lt.light_energy = 2.4
	screen_lt.omni_range = 7.0
	pivot.add_child(screen_lt)
	# ---- Pulses ----
	# Screen + emblem cyan pulse
	var spulse: Tween = pivot.create_tween().set_loops()
	spulse.tween_property(screen_mat, "emission_energy_multiplier", 8.0, 1.8).set_ease(Tween.EASE_IN_OUT)
	spulse.tween_property(screen_mat, "emission_energy_multiplier", 5.0, 1.8).set_ease(Tween.EASE_IN_OUT)
	# Lantern flame flicker
	var fpulse2: Tween = pivot.create_tween().set_loops()
	fpulse2.tween_property(flame_mat, "emission_energy_multiplier", 9.0, 0.45).set_ease(Tween.EASE_IN_OUT)
	fpulse2.tween_property(flame_mat, "emission_energy_multiplier", 6.5, 0.45).set_ease(Tween.EASE_IN_OUT)


func _build_th_stash_chest(geom: Node) -> void:
	## Epic-10 T9: large stash chest on the SW radial path. Stepped basalt
	## stand, brass-bound iron chest body with 4 brass corner reinforcements
	## and 3 iron strap bands, glowing cyan data lock at the front, brass
	## hinges along the lid, and a small holographic inventory icon
	## hovering above the lid.
	var pivot: Node3D = Node3D.new()
	pivot.name = "TH_StashChest"
	# SW radial path (angle = 5*pi/4 from +X), at radius 6.5
	var ang: float = 5.0 * PI / 4.0
	pivot.position = TOWN_CENTER + Vector3(cos(ang) * 6.5, 0, sin(ang) * 6.5)
	# Face the beacon (perpendicular to the radial direction, facing inward)
	pivot.rotation.y = -ang - PI / 2.0
	geom.add_child(pivot)
	# Materials
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.20, 0.22, 0.26)
	stone_mat.metallic = 0.18
	stone_mat.roughness = 0.85
	stone_mat.emission_enabled = true
	stone_mat.emission = Color(0.30, 0.45, 0.60)
	stone_mat.emission_energy_multiplier = 0.18
	var iron_mat: StandardMaterial3D = StandardMaterial3D.new()
	iron_mat.albedo_color = Color(0.18, 0.16, 0.18)
	iron_mat.metallic = 0.85
	iron_mat.roughness = 0.45
	iron_mat.emission_enabled = true
	iron_mat.emission = Color(0.45, 0.55, 0.65)
	iron_mat.emission_energy_multiplier = 0.30
	var brass_mat: StandardMaterial3D = StandardMaterial3D.new()
	brass_mat.albedo_color = Color(0.85, 0.55, 0.18)
	brass_mat.metallic = 0.95
	brass_mat.roughness = 0.30
	brass_mat.emission_enabled = true
	brass_mat.emission = Color(1.0, 0.50, 0.10)
	brass_mat.emission_energy_multiplier = 0.55
	var data_mat: StandardMaterial3D = StandardMaterial3D.new()
	data_mat.albedo_color = Color(0.45, 0.85, 1.0)
	data_mat.emission_enabled = true
	data_mat.emission = Color(0.45, 0.85, 1.0)
	data_mat.emission_energy_multiplier = 7.0
	data_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	# ---- Stepped basalt stand ----
	var stand: MeshInstance3D = MeshInstance3D.new()
	var stm: BoxMesh = BoxMesh.new()
	stm.size = Vector3(2.20, 0.40, 1.40)
	stand.mesh = stm
	stand.material_override = stone_mat
	stand.position = Vector3(0, 0.20, 0)
	pivot.add_child(stand)
	# Stand collision
	var stand_sb: StaticBody3D = StaticBody3D.new()
	stand_sb.position = Vector3(0, 0.20, 0)
	var stand_cs: CollisionShape3D = CollisionShape3D.new()
	var stand_bsh: BoxShape3D = BoxShape3D.new()
	stand_bsh.size = Vector3(2.20, 0.40, 1.40)
	stand_cs.shape = stand_bsh
	stand_sb.add_child(stand_cs)
	pivot.add_child(stand_sb)
	# ---- Iron chest body ----
	var body: MeshInstance3D = MeshInstance3D.new()
	var bm: BoxMesh = BoxMesh.new()
	bm.size = Vector3(1.85, 1.10, 1.10)
	body.mesh = bm
	body.material_override = iron_mat
	body.position = Vector3(0, 0.95, 0)
	pivot.add_child(body)
	# Chest collision
	var body_sb: StaticBody3D = StaticBody3D.new()
	body_sb.position = Vector3(0, 0.95, 0)
	var body_cs: CollisionShape3D = CollisionShape3D.new()
	var body_bsh: BoxShape3D = BoxShape3D.new()
	body_bsh.size = Vector3(1.85, 1.10, 1.10)
	body_cs.shape = body_bsh
	body_sb.add_child(body_cs)
	pivot.add_child(body_sb)
	# ---- 4 brass corner reinforcements (small box caps at each top corner) ----
	for cx in [-0.85, 0.85]:
		for cz in [-0.50, 0.50]:
			var corner: MeshInstance3D = MeshInstance3D.new()
			var cmm: BoxMesh = BoxMesh.new()
			cmm.size = Vector3(0.20, 0.20, 0.20)
			corner.mesh = cmm
			corner.material_override = brass_mat
			corner.position = Vector3(cx, 1.40, cz)
			pivot.add_child(corner)
	# ---- 3 iron strap bands wrapping around the body ----
	for sx in [-0.50, 0.0, 0.50]:
		var strap: MeshInstance3D = MeshInstance3D.new()
		var smm: BoxMesh = BoxMesh.new()
		smm.size = Vector3(0.10, 1.20, 1.18)
		strap.mesh = smm
		strap.material_override = brass_mat
		strap.position = Vector3(sx, 0.95, 0)
		pivot.add_child(strap)
	# ---- Glowing cyan data lock at the front center ----
	# Lock body
	var lock: MeshInstance3D = MeshInstance3D.new()
	var lm: BoxMesh = BoxMesh.new()
	lm.size = Vector3(0.30, 0.40, 0.10)
	lock.mesh = lm
	lock.material_override = brass_mat
	lock.position = Vector3(0, 0.85, -0.62)
	pivot.add_child(lock)
	# Lock keyhole (small unshaded cyan circle)
	var keyhole: MeshInstance3D = MeshInstance3D.new()
	var khm: SphereMesh = SphereMesh.new()
	khm.radius = 0.08
	khm.height = 0.16
	keyhole.mesh = khm
	keyhole.material_override = data_mat
	keyhole.position = Vector3(0, 0.95, -0.68)
	pivot.add_child(keyhole)
	# ---- Brass hinges along the back of the lid (3 small box hinges) ----
	for hx in [-0.65, 0.0, 0.65]:
		var hinge: MeshInstance3D = MeshInstance3D.new()
		var hgm: BoxMesh = BoxMesh.new()
		hgm.size = Vector3(0.18, 0.10, 0.20)
		hinge.mesh = hgm
		hinge.material_override = brass_mat
		hinge.position = Vector3(hx, 1.50, 0.50)
		pivot.add_child(hinge)
	# ---- Small holographic inventory icon hovering above the chest ----
	# Brass post mount on the back of the chest
	var icon_post: MeshInstance3D = MeshInstance3D.new()
	var ipm: CylinderMesh = CylinderMesh.new()
	ipm.top_radius = 0.04
	ipm.bottom_radius = 0.05
	ipm.height = 0.85
	icon_post.mesh = ipm
	icon_post.material_override = brass_mat
	icon_post.position = Vector3(0, 1.85, 0.45)
	pivot.add_child(icon_post)
	# Floating inventory icon — small unshaded cyan grid (4 boxes in a 2x2)
	var icon_pivot: Node3D = Node3D.new()
	icon_pivot.position = Vector3(0, 2.40, 0.45)
	pivot.add_child(icon_pivot)
	for ix in [-0.10, 0.10]:
		for iy in [-0.10, 0.10]:
			var cell: MeshInstance3D = MeshInstance3D.new()
			var cellm: BoxMesh = BoxMesh.new()
			cellm.size = Vector3(0.16, 0.16, 0.04)
			cell.mesh = cellm
			cell.material_override = data_mat
			cell.position = Vector3(ix, iy, 0)
			icon_pivot.add_child(cell)
	# ---- Strong cyan OmniLight from the lock + icon ----
	var lt: OmniLight3D = OmniLight3D.new()
	lt.position = Vector3(0, 1.50, -0.40)
	lt.light_color = Color(0.45, 0.85, 1.0)
	lt.light_energy = 2.6
	lt.omni_range = 7.5
	pivot.add_child(lt)
	# ---- Pulses ----
	# Data material pulse — keyhole + icon grid breathe together
	var dpulse: Tween = pivot.create_tween().set_loops()
	dpulse.tween_property(data_mat, "emission_energy_multiplier", 9.0, 1.8).set_ease(Tween.EASE_IN_OUT)
	dpulse.tween_property(data_mat, "emission_energy_multiplier", 5.5, 1.8).set_ease(Tween.EASE_IN_OUT)
	# Slow icon spin so the holographic grid rotates above the chest
	var spin: Tween = pivot.create_tween().set_loops()
	spin.tween_property(icon_pivot, "rotation:y", TAU, 6.0)
	# Subtle hover bob on the icon
	var bob: Tween = pivot.create_tween().set_loops()
	bob.tween_property(icon_pivot, "position:y", 2.55, 1.4).set_ease(Tween.EASE_IN_OUT)
	bob.tween_property(icon_pivot, "position:y", 2.30, 1.4).set_ease(Tween.EASE_IN_OUT)


func _build_th_vendor_kiosk(geom: Node) -> void:
	## Epic-10 T10: vendor kiosk on the NW radial path. Brass merchant
	## counter with stepped basalt base, brass overhead canopy held by 2
	## posts, 4 floating holo wares spinning above the counter, brass
	## coin stack on the counter, and a glowing data till at the front.
	var pivot: Node3D = Node3D.new()
	pivot.name = "TH_VendorKiosk"
	# NW radial path (angle = 3*pi/4 from +X), at radius 6.5
	var ang: float = 3.0 * PI / 4.0
	pivot.position = TOWN_CENTER + Vector3(cos(ang) * 6.5, 0, sin(ang) * 6.5)
	pivot.rotation.y = -ang - PI / 2.0
	geom.add_child(pivot)
	# Materials
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.20, 0.22, 0.26)
	stone_mat.metallic = 0.18
	stone_mat.roughness = 0.85
	stone_mat.emission_enabled = true
	stone_mat.emission = Color(0.30, 0.45, 0.60)
	stone_mat.emission_energy_multiplier = 0.18
	var brass_mat: StandardMaterial3D = StandardMaterial3D.new()
	brass_mat.albedo_color = Color(0.85, 0.55, 0.18)
	brass_mat.metallic = 0.95
	brass_mat.roughness = 0.30
	brass_mat.emission_enabled = true
	brass_mat.emission = Color(1.0, 0.50, 0.10)
	brass_mat.emission_energy_multiplier = 0.55
	var data_mat: StandardMaterial3D = StandardMaterial3D.new()
	data_mat.albedo_color = Color(0.45, 0.85, 1.0)
	data_mat.emission_enabled = true
	data_mat.emission = Color(0.45, 0.85, 1.0)
	data_mat.emission_energy_multiplier = 6.5
	data_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var ware_mat: StandardMaterial3D = StandardMaterial3D.new()
	ware_mat.albedo_color = Color(1.0, 0.65, 0.20)
	ware_mat.emission_enabled = true
	ware_mat.emission = Color(1.0, 0.55, 0.10)
	ware_mat.emission_energy_multiplier = 6.5
	ware_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	# ---- Stepped basalt base ----
	var base: MeshInstance3D = MeshInstance3D.new()
	var bm: BoxMesh = BoxMesh.new()
	bm.size = Vector3(2.60, 0.40, 1.30)
	base.mesh = bm
	base.material_override = stone_mat
	base.position = Vector3(0, 0.20, 0)
	pivot.add_child(base)
	# Base collision
	var base_sb: StaticBody3D = StaticBody3D.new()
	base_sb.position = Vector3(0, 0.20, 0)
	var base_cs: CollisionShape3D = CollisionShape3D.new()
	var base_bsh: BoxShape3D = BoxShape3D.new()
	base_bsh.size = Vector3(2.60, 0.40, 1.30)
	base_cs.shape = base_bsh
	base_sb.add_child(base_cs)
	pivot.add_child(base_sb)
	# ---- Brass merchant counter ----
	var counter: MeshInstance3D = MeshInstance3D.new()
	var cm: BoxMesh = BoxMesh.new()
	cm.size = Vector3(2.40, 0.85, 1.05)
	counter.mesh = cm
	counter.material_override = brass_mat
	counter.position = Vector3(0, 0.83, 0)
	pivot.add_child(counter)
	# Counter collision
	var counter_sb: StaticBody3D = StaticBody3D.new()
	counter_sb.position = Vector3(0, 0.83, 0)
	var counter_cs: CollisionShape3D = CollisionShape3D.new()
	var counter_bsh: BoxShape3D = BoxShape3D.new()
	counter_bsh.size = Vector3(2.40, 0.85, 1.05)
	counter_cs.shape = counter_bsh
	counter_sb.add_child(counter_cs)
	pivot.add_child(counter_sb)
	# Counter top plate (slightly bigger overhang)
	var top_plate: MeshInstance3D = MeshInstance3D.new()
	var tpm: BoxMesh = BoxMesh.new()
	tpm.size = Vector3(2.55, 0.10, 1.20)
	top_plate.mesh = tpm
	top_plate.material_override = brass_mat
	top_plate.position = Vector3(0, 1.30, 0)
	pivot.add_child(top_plate)
	# ---- 2 brass canopy support posts ----
	for px in [-1.10, 1.10]:
		var post: MeshInstance3D = MeshInstance3D.new()
		var pm: CylinderMesh = CylinderMesh.new()
		pm.top_radius = 0.07
		pm.bottom_radius = 0.09
		pm.height = 2.50
		post.mesh = pm
		post.material_override = brass_mat
		post.position = Vector3(px, 2.55, 0)
		pivot.add_child(post)
	# ---- Brass overhead canopy ----
	var canopy: MeshInstance3D = MeshInstance3D.new()
	var canm: BoxMesh = BoxMesh.new()
	canm.size = Vector3(2.60, 0.20, 1.40)
	canopy.mesh = canm
	canopy.material_override = brass_mat
	canopy.position = Vector3(0, 3.85, 0)
	pivot.add_child(canopy)
	# Canopy front fringe (small box hanging down at the front)
	var fringe: MeshInstance3D = MeshInstance3D.new()
	var frm: BoxMesh = BoxMesh.new()
	frm.size = Vector3(2.60, 0.18, 0.06)
	fringe.mesh = frm
	fringe.material_override = brass_mat
	fringe.position = Vector3(0, 3.65, -0.65)
	pivot.add_child(fringe)
	# ---- 4 floating holo wares spinning above the counter ----
	# Each ware is a small unshaded amber primitive in a row, on a hover pivot
	var ware_pivot: Node3D = Node3D.new()
	ware_pivot.position = Vector3(0, 2.10, 0)
	pivot.add_child(ware_pivot)
	# Ware 1 — small sword (vertical box)
	var w1: MeshInstance3D = MeshInstance3D.new()
	var w1m: BoxMesh = BoxMesh.new()
	w1m.size = Vector3(0.10, 0.55, 0.06)
	w1.mesh = w1m
	w1.material_override = ware_mat
	w1.position = Vector3(-0.85, 0, 0)
	ware_pivot.add_child(w1)
	# Ware 2 — gem cluster (sphere)
	var w2: MeshInstance3D = MeshInstance3D.new()
	var w2m: SphereMesh = SphereMesh.new()
	w2m.radius = 0.18
	w2m.height = 0.36
	w2.mesh = w2m
	w2.material_override = ware_mat
	w2.position = Vector3(-0.30, 0, 0)
	ware_pivot.add_child(w2)
	# Ware 3 — torus ring
	var w3: MeshInstance3D = MeshInstance3D.new()
	var w3m: TorusMesh = TorusMesh.new()
	w3m.inner_radius = 0.10
	w3m.outer_radius = 0.18
	w3.mesh = w3m
	w3.material_override = ware_mat
	w3.position = Vector3(0.30, 0, 0)
	w3.rotation.x = PI / 2.0
	ware_pivot.add_child(w3)
	# Ware 4 — potion vial (small cylinder)
	var w4: MeshInstance3D = MeshInstance3D.new()
	var w4m: CylinderMesh = CylinderMesh.new()
	w4m.top_radius = 0.08
	w4m.bottom_radius = 0.10
	w4m.height = 0.40
	w4.mesh = w4m
	w4.material_override = ware_mat
	w4.position = Vector3(0.85, 0, 0)
	ware_pivot.add_child(w4)
	# ---- Brass coin stack on the counter (4 stacked discs) ----
	for stk in 4:
		var coin: MeshInstance3D = MeshInstance3D.new()
		var cmm: CylinderMesh = CylinderMesh.new()
		cmm.top_radius = 0.13
		cmm.bottom_radius = 0.13
		cmm.height = 0.04
		coin.mesh = cmm
		coin.material_override = brass_mat
		coin.position = Vector3(0.85, 1.38 + float(stk) * 0.05, -0.20)
		pivot.add_child(coin)
	# ---- Glowing data till at the front of the counter ----
	var till: MeshInstance3D = MeshInstance3D.new()
	var tlm: BoxMesh = BoxMesh.new()
	tlm.size = Vector3(0.65, 0.30, 0.10)
	till.mesh = tlm
	till.material_override = data_mat
	till.position = Vector3(-0.65, 1.10, -0.55)
	pivot.add_child(till)
	# Till brass frame
	var till_frame: MeshInstance3D = MeshInstance3D.new()
	var tfm: BoxMesh = BoxMesh.new()
	tfm.size = Vector3(0.75, 0.40, 0.06)
	till_frame.mesh = tfm
	till_frame.material_override = brass_mat
	till_frame.position = Vector3(-0.65, 1.10, -0.58)
	pivot.add_child(till_frame)
	# ---- Strong canopy OmniLight ----
	var lt: OmniLight3D = OmniLight3D.new()
	lt.position = Vector3(0, 2.80, -0.10)
	lt.light_color = Color(1.0, 0.65, 0.20)
	lt.light_energy = 3.0
	lt.omni_range = 8.5
	pivot.add_child(lt)
	# ---- Pulses ----
	# Wares + till glow pulse (separate materials but matching cadence)
	var wpulse: Tween = pivot.create_tween().set_loops()
	wpulse.tween_property(ware_mat, "emission_energy_multiplier", 8.5, 1.6).set_ease(Tween.EASE_IN_OUT)
	wpulse.tween_property(ware_mat, "emission_energy_multiplier", 5.0, 1.6).set_ease(Tween.EASE_IN_OUT)
	var dpulse: Tween = pivot.create_tween().set_loops()
	dpulse.tween_property(data_mat, "emission_energy_multiplier", 8.5, 1.6).set_ease(Tween.EASE_IN_OUT)
	dpulse.tween_property(data_mat, "emission_energy_multiplier", 5.0, 1.6).set_ease(Tween.EASE_IN_OUT)
	# Wares spin slowly
	var spin: Tween = pivot.create_tween().set_loops()
	spin.tween_property(ware_pivot, "rotation:y", TAU, 7.0)
	# Wares hover bob
	var bob: Tween = pivot.create_tween().set_loops()
	bob.tween_property(ware_pivot, "position:y", 2.25, 1.6).set_ease(Tween.EASE_IN_OUT)
	bob.tween_property(ware_pivot, "position:y", 1.95, 1.6).set_ease(Tween.EASE_IN_OUT)


func _build_th_data_fountain(geom: Node) -> void:
	## Epic-10 T11: circular data fountain on the E radial path. Round
	## basalt rim basin filled with glowing cyan data, central tiered
	## brass spire with 3 cascading levels, upward jet stream of cyan
	## particles + downward fall particles, 4 small spout figures around
	## the rim, and rim ambient glow.
	var pivot: Node3D = Node3D.new()
	pivot.name = "TH_DataFountain"
	# E radial path (angle = 0), at radius 6.5
	pivot.position = TOWN_CENTER + Vector3(6.5, 0, 0)
	geom.add_child(pivot)
	# Materials
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.20, 0.22, 0.26)
	stone_mat.metallic = 0.18
	stone_mat.roughness = 0.85
	stone_mat.emission_enabled = true
	stone_mat.emission = Color(0.30, 0.45, 0.60)
	stone_mat.emission_energy_multiplier = 0.18
	var brass_mat: StandardMaterial3D = StandardMaterial3D.new()
	brass_mat.albedo_color = Color(0.85, 0.55, 0.18)
	brass_mat.metallic = 0.95
	brass_mat.roughness = 0.30
	brass_mat.emission_enabled = true
	brass_mat.emission = Color(1.0, 0.50, 0.10)
	brass_mat.emission_energy_multiplier = 0.55
	var data_mat: StandardMaterial3D = StandardMaterial3D.new()
	data_mat.albedo_color = Color(0.45, 0.85, 1.0)
	data_mat.emission_enabled = true
	data_mat.emission = Color(0.45, 0.85, 1.0)
	data_mat.emission_energy_multiplier = 7.0
	data_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	# ---- Round basalt rim basin ----
	var rim: MeshInstance3D = MeshInstance3D.new()
	var rmm: TorusMesh = TorusMesh.new()
	rmm.inner_radius = 1.95
	rmm.outer_radius = 2.40
	rim.mesh = rmm
	rim.material_override = stone_mat
	rim.position = Vector3(0, 0.30, 0)
	pivot.add_child(rim)
	# Rim collision (cylinder ring approximation)
	var rim_sb: StaticBody3D = StaticBody3D.new()
	rim_sb.position = Vector3(0, 0.30, 0)
	var rim_cs: CollisionShape3D = CollisionShape3D.new()
	var rim_cyl: CylinderShape3D = CylinderShape3D.new()
	rim_cyl.top_radius = 2.40
	rim_cyl.bottom_radius = 2.40
	rim_cyl.height = 0.50
	rim_cs.shape = rim_cyl
	rim_sb.add_child(rim_cs)
	pivot.add_child(rim_sb)
	# Brass rim trim torus on top of the basalt rim
	var trim: MeshInstance3D = MeshInstance3D.new()
	var trm: TorusMesh = TorusMesh.new()
	trm.inner_radius = 2.20
	trm.outer_radius = 2.40
	trim.mesh = trm
	trim.material_override = brass_mat
	trim.position = Vector3(0, 0.55, 0)
	pivot.add_child(trim)
	# ---- Glowing cyan basin water disc ----
	var water: MeshInstance3D = MeshInstance3D.new()
	var wm: CylinderMesh = CylinderMesh.new()
	wm.top_radius = 1.95
	wm.bottom_radius = 1.95
	wm.height = 0.10
	water.mesh = wm
	water.material_override = data_mat
	water.position = Vector3(0, 0.50, 0)
	pivot.add_child(water)
	# ---- Central tiered brass spire (3 cascading levels) ----
	# Tier 1 — wide brass dish with rim
	var t1: MeshInstance3D = MeshInstance3D.new()
	var t1m: CylinderMesh = CylinderMesh.new()
	t1m.top_radius = 0.85
	t1m.bottom_radius = 0.85
	t1m.height = 0.10
	t1.mesh = t1m
	t1.material_override = brass_mat
	t1.position = Vector3(0, 1.10, 0)
	pivot.add_child(t1)
	# Tier 1 stem
	var s1: MeshInstance3D = MeshInstance3D.new()
	var s1m: CylinderMesh = CylinderMesh.new()
	s1m.top_radius = 0.12
	s1m.bottom_radius = 0.18
	s1m.height = 0.65
	s1.mesh = s1m
	s1.material_override = brass_mat
	s1.position = Vector3(0, 0.78, 0)
	pivot.add_child(s1)
	# Tier 2 — medium brass dish
	var t2: MeshInstance3D = MeshInstance3D.new()
	var t2m: CylinderMesh = CylinderMesh.new()
	t2m.top_radius = 0.55
	t2m.bottom_radius = 0.55
	t2m.height = 0.08
	t2.mesh = t2m
	t2.material_override = brass_mat
	t2.position = Vector3(0, 1.55, 0)
	pivot.add_child(t2)
	# Tier 2 stem
	var s2: MeshInstance3D = MeshInstance3D.new()
	var s2m: CylinderMesh = CylinderMesh.new()
	s2m.top_radius = 0.10
	s2m.bottom_radius = 0.13
	s2m.height = 0.45
	s2.mesh = s2m
	s2.material_override = brass_mat
	s2.position = Vector3(0, 1.32, 0)
	pivot.add_child(s2)
	# Tier 3 — small brass dish (top)
	var t3: MeshInstance3D = MeshInstance3D.new()
	var t3m: CylinderMesh = CylinderMesh.new()
	t3m.top_radius = 0.30
	t3m.bottom_radius = 0.30
	t3m.height = 0.06
	t3.mesh = t3m
	t3.material_override = brass_mat
	t3.position = Vector3(0, 1.95, 0)
	pivot.add_child(t3)
	# Tier 3 stem
	var s3: MeshInstance3D = MeshInstance3D.new()
	var s3m: CylinderMesh = CylinderMesh.new()
	s3m.top_radius = 0.08
	s3m.bottom_radius = 0.10
	s3m.height = 0.35
	s3.mesh = s3m
	s3.material_override = brass_mat
	s3.position = Vector3(0, 1.77, 0)
	pivot.add_child(s3)
	# Top finial sphere — bright unshaded data sphere
	var finial: MeshInstance3D = MeshInstance3D.new()
	var fm: SphereMesh = SphereMesh.new()
	fm.radius = 0.18
	fm.height = 0.36
	finial.mesh = fm
	finial.material_override = data_mat
	finial.position = Vector3(0, 2.20, 0)
	pivot.add_child(finial)
	# ---- Upward jet stream of cyan data particles from the top finial ----
	var jet: GPUParticles3D = GPUParticles3D.new()
	jet.position = Vector3(0, 2.30, 0)
	jet.amount = 36
	jet.lifetime = 1.8
	var jmat: ParticleProcessMaterial = ParticleProcessMaterial.new()
	jmat.direction = Vector3(0, 1, 0)
	jmat.spread = 16.0
	jmat.initial_velocity_min = 1.5
	jmat.initial_velocity_max = 2.5
	jmat.gravity = Vector3(0, -2.5, 0)
	jmat.scale_min = 0.06
	jmat.scale_max = 0.12
	jmat.color = Color(0.45, 0.85, 1.0, 1.0)
	jet.process_material = jmat
	var jmesh: SphereMesh = SphereMesh.new()
	jmesh.radius = 0.05
	jmesh.height = 0.10
	jet.draw_pass_1 = jmesh
	pivot.add_child(jet)
	# ---- 3 downward cascade emitters from each tier dish edge ----
	var tier_ys: Array = [1.18, 1.62, 2.02]
	var tier_radii: Array = [0.85, 0.55, 0.30]
	for i in tier_ys.size():
		var cascade: GPUParticles3D = GPUParticles3D.new()
		cascade.position = Vector3(0, tier_ys[i], 0)
		cascade.amount = 18
		cascade.lifetime = 1.5
		var cmat: ParticleProcessMaterial = ParticleProcessMaterial.new()
		cmat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_RING
		cmat.emission_ring_radius = tier_radii[i]
		cmat.emission_ring_height = 0.05
		cmat.emission_ring_axis = Vector3(0, 1, 0)
		cmat.direction = Vector3(0, -1, 0)
		cmat.spread = 8.0
		cmat.initial_velocity_min = 0.4
		cmat.initial_velocity_max = 0.8
		cmat.gravity = Vector3(0, -2.5, 0)
		cmat.scale_min = 0.04
		cmat.scale_max = 0.08
		cmat.color = Color(0.45, 0.85, 1.0, 1.0)
		cascade.process_material = cmat
		var cmesh: SphereMesh = SphereMesh.new()
		cmesh.radius = 0.04
		cmesh.height = 0.08
		cascade.draw_pass_1 = cmesh
		pivot.add_child(cascade)
	# ---- 4 small brass spout figures around the rim (small fish-head boxes) ----
	for i in 4:
		var ang: float = float(i) / 4.0 * TAU
		var dx: float = cos(ang)
		var dz: float = sin(ang)
		var spout: MeshInstance3D = MeshInstance3D.new()
		var spm: PrismMesh = PrismMesh.new()
		spm.size = Vector3(0.18, 0.16, 0.30)
		spout.mesh = spm
		spout.material_override = brass_mat
		spout.position = Vector3(dx * 2.20, 0.65, dz * 2.20)
		spout.rotation.y = ang + PI / 2.0
		pivot.add_child(spout)
		# Spout glowing dot at the tip
		var tip: MeshInstance3D = MeshInstance3D.new()
		var tm: SphereMesh = SphereMesh.new()
		tm.radius = 0.05
		tm.height = 0.10
		tip.mesh = tm
		tip.material_override = data_mat
		tip.position = Vector3(dx * 2.05, 0.65, dz * 2.05)
		pivot.add_child(tip)
	# ---- Strong cyan OmniLight from the basin ----
	var lt: OmniLight3D = OmniLight3D.new()
	lt.position = Vector3(0, 1.50, 0)
	lt.light_color = Color(0.45, 0.85, 1.0)
	lt.light_energy = 3.5
	lt.omni_range = 9.0
	pivot.add_child(lt)
	# ---- Pulses ----
	# Data pulse — basin water + finial + spout tips breathe together
	var dpulse: Tween = pivot.create_tween().set_loops()
	dpulse.tween_property(data_mat, "emission_energy_multiplier", 9.0, 1.8).set_ease(Tween.EASE_IN_OUT)
	dpulse.tween_property(data_mat, "emission_energy_multiplier", 5.5, 1.8).set_ease(Tween.EASE_IN_OUT)


func _build_th_practice_dummy(geom: Node) -> void:
	## Epic-10 T12: practice dummy training spot on the W radial path.
	## Wooden sparring dummy with glowing chest core and capsule collision,
	## a small 3-weapon rack beside it (sword/spear/axe), and a sand pit
	## floor patch under the dummy.
	var pivot: Node3D = Node3D.new()
	pivot.name = "TH_PracticeDummy"
	# W radial path (angle = pi from +X), at radius 6.5
	pivot.position = TOWN_CENTER + Vector3(-6.5, 0, 0)
	# Face the beacon (+X direction)
	pivot.rotation.y = PI / 2.0
	geom.add_child(pivot)
	# Materials
	var sand_mat: StandardMaterial3D = StandardMaterial3D.new()
	sand_mat.albedo_color = Color(0.42, 0.30, 0.18)
	sand_mat.roughness = 0.95
	sand_mat.emission_enabled = true
	sand_mat.emission = Color(0.55, 0.30, 0.10)
	sand_mat.emission_energy_multiplier = 0.18
	var wood_mat: StandardMaterial3D = StandardMaterial3D.new()
	wood_mat.albedo_color = Color(0.32, 0.20, 0.12)
	wood_mat.roughness = 0.85
	wood_mat.metallic = 0.10
	var brass_mat: StandardMaterial3D = StandardMaterial3D.new()
	brass_mat.albedo_color = Color(0.85, 0.55, 0.18)
	brass_mat.metallic = 0.95
	brass_mat.roughness = 0.30
	brass_mat.emission_enabled = true
	brass_mat.emission = Color(1.0, 0.50, 0.10)
	brass_mat.emission_energy_multiplier = 0.55
	var weapon_mat: StandardMaterial3D = StandardMaterial3D.new()
	weapon_mat.albedo_color = Color(1.0, 0.65, 0.20)
	weapon_mat.emission_enabled = true
	weapon_mat.emission = Color(1.0, 0.55, 0.10)
	weapon_mat.emission_energy_multiplier = 5.5
	weapon_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var core_mat: StandardMaterial3D = StandardMaterial3D.new()
	core_mat.albedo_color = Color(1.0, 0.55, 0.10)
	core_mat.emission_enabled = true
	core_mat.emission = Color(1.0, 0.55, 0.10)
	core_mat.emission_energy_multiplier = 6.5
	core_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	# ---- Sand pit floor patch ----
	var sand: MeshInstance3D = MeshInstance3D.new()
	var sm: CylinderMesh = CylinderMesh.new()
	sm.top_radius = 1.85
	sm.bottom_radius = 1.95
	sm.height = 0.08
	sand.mesh = sm
	sand.material_override = sand_mat
	sand.position = Vector3(0, 0.05, 0)
	pivot.add_child(sand)
	# ---- Wooden sparring dummy ----
	var dummy_pivot: Node3D = Node3D.new()
	dummy_pivot.position = Vector3(0, 0, 0)
	pivot.add_child(dummy_pivot)
	# Base post
	var dummy_post: MeshInstance3D = MeshInstance3D.new()
	var dpm: CylinderMesh = CylinderMesh.new()
	dpm.top_radius = 0.10
	dpm.bottom_radius = 0.14
	dpm.height = 0.85
	dummy_post.mesh = dpm
	dummy_post.material_override = wood_mat
	dummy_post.position = Vector3(0, 0.42, 0)
	dummy_pivot.add_child(dummy_post)
	# Body box
	var dummy_body: MeshInstance3D = MeshInstance3D.new()
	var dbm: BoxMesh = BoxMesh.new()
	dbm.size = Vector3(0.65, 0.95, 0.40)
	dummy_body.mesh = dbm
	dummy_body.material_override = wood_mat
	dummy_body.position = Vector3(0, 1.30, 0)
	dummy_pivot.add_child(dummy_body)
	# Arms — sticking out boxes
	for ax in [-0.55, 0.55]:
		var arm: MeshInstance3D = MeshInstance3D.new()
		var amesh: BoxMesh = BoxMesh.new()
		amesh.size = Vector3(0.50, 0.16, 0.16)
		arm.mesh = amesh
		arm.material_override = wood_mat
		arm.position = Vector3(ax, 1.45, 0)
		dummy_pivot.add_child(arm)
	# Head — small sphere
	var dummy_head: MeshInstance3D = MeshInstance3D.new()
	var dhm: SphereMesh = SphereMesh.new()
	dhm.radius = 0.18
	dhm.height = 0.36
	dummy_head.mesh = dhm
	dummy_head.material_override = wood_mat
	dummy_head.position = Vector3(0, 2.00, 0)
	dummy_pivot.add_child(dummy_head)
	# Glowing chest core
	var core: MeshInstance3D = MeshInstance3D.new()
	var corem: SphereMesh = SphereMesh.new()
	corem.radius = 0.14
	corem.height = 0.28
	core.mesh = corem
	core.material_override = core_mat
	core.position = Vector3(0, 1.30, -0.22)
	dummy_pivot.add_child(core)
	# Capsule collision
	var sb: StaticBody3D = StaticBody3D.new()
	sb.position = Vector3(0, 1.30, 0)
	var cs: CollisionShape3D = CollisionShape3D.new()
	var caps: CapsuleShape3D = CapsuleShape3D.new()
	caps.radius = 0.40
	caps.height = 1.80
	cs.shape = caps
	sb.add_child(cs)
	dummy_pivot.add_child(sb)
	# Idle wobble
	var wobble: Tween = dummy_pivot.create_tween().set_loops()
	wobble.tween_property(dummy_pivot, "rotation:x", 0.05, 1.4).set_ease(Tween.EASE_IN_OUT)
	wobble.tween_property(dummy_pivot, "rotation:x", -0.05, 1.4).set_ease(Tween.EASE_IN_OUT)
	# ---- Small 3-weapon rack to the side ----
	# Rack base
	var rack_base: MeshInstance3D = MeshInstance3D.new()
	var rbm: BoxMesh = BoxMesh.new()
	rbm.size = Vector3(1.20, 0.18, 0.40)
	rack_base.mesh = rbm
	rack_base.material_override = wood_mat
	rack_base.position = Vector3(-1.10, 0.20, 0.85)
	pivot.add_child(rack_base)
	# Rack back vertical board
	var rack_back: MeshInstance3D = MeshInstance3D.new()
	var rbk: BoxMesh = BoxMesh.new()
	rbk.size = Vector3(1.20, 1.10, 0.06)
	rack_back.mesh = rbk
	rack_back.material_override = wood_mat
	rack_back.position = Vector3(-1.10, 0.85, 1.00)
	pivot.add_child(rack_back)
	# Rack collision
	var rack_sb: StaticBody3D = StaticBody3D.new()
	rack_sb.position = Vector3(-1.10, 0.55, 0.92)
	var rack_cs: CollisionShape3D = CollisionShape3D.new()
	var rack_bsh: BoxShape3D = BoxShape3D.new()
	rack_bsh.size = Vector3(1.20, 1.20, 0.40)
	rack_cs.shape = rack_bsh
	rack_sb.add_child(rack_cs)
	pivot.add_child(rack_sb)
	# Sword (vertical box)
	var sword: MeshInstance3D = MeshInstance3D.new()
	var swm: BoxMesh = BoxMesh.new()
	swm.size = Vector3(0.10, 1.00, 0.06)
	sword.mesh = swm
	sword.material_override = weapon_mat
	sword.position = Vector3(-1.40, 0.92, 0.95)
	pivot.add_child(sword)
	# Spear (long thin cylinder)
	var spear: MeshInstance3D = MeshInstance3D.new()
	var sprm: CylinderMesh = CylinderMesh.new()
	sprm.top_radius = 0.04
	sprm.bottom_radius = 0.04
	sprm.height = 1.15
	spear.mesh = sprm
	spear.material_override = weapon_mat
	spear.position = Vector3(-1.10, 0.92, 0.95)
	pivot.add_child(spear)
	# Axe (handle + prism blade)
	var axe_h: MeshInstance3D = MeshInstance3D.new()
	var axm: CylinderMesh = CylinderMesh.new()
	axm.top_radius = 0.04
	axm.bottom_radius = 0.05
	axm.height = 0.90
	axe_h.mesh = axm
	axe_h.material_override = weapon_mat
	axe_h.position = Vector3(-0.80, 0.85, 0.95)
	pivot.add_child(axe_h)
	var axe_blade: MeshInstance3D = MeshInstance3D.new()
	var abm: PrismMesh = PrismMesh.new()
	abm.size = Vector3(0.28, 0.28, 0.08)
	axe_blade.mesh = abm
	axe_blade.material_override = weapon_mat
	axe_blade.position = Vector3(-0.72, 1.20, 0.95)
	axe_blade.rotation.z = -PI / 2.0
	pivot.add_child(axe_blade)
	# Subtle warm OmniLight from the dummy core + weapons
	var lt: OmniLight3D = OmniLight3D.new()
	lt.position = Vector3(-0.50, 1.30, -0.10)
	lt.light_color = Color(1.0, 0.55, 0.15)
	lt.light_energy = 1.8
	lt.omni_range = 5.5
	pivot.add_child(lt)
	# Pulses
	var cpulse: Tween = pivot.create_tween().set_loops()
	cpulse.tween_property(core_mat, "emission_energy_multiplier", 8.0, 1.4).set_ease(Tween.EASE_IN_OUT)
	cpulse.tween_property(core_mat, "emission_energy_multiplier", 4.5, 1.4).set_ease(Tween.EASE_IN_OUT)
	var wpulse: Tween = pivot.create_tween().set_loops()
	wpulse.tween_property(weapon_mat, "emission_energy_multiplier", 7.0, 1.6).set_ease(Tween.EASE_IN_OUT)
	wpulse.tween_property(weapon_mat, "emission_energy_multiplier", 4.0, 1.6).set_ease(Tween.EASE_IN_OUT)


func _build_th_district_map_kiosk(geom: Node) -> void:
	## Epic-10 T13: holographic district map kiosk on the NE radial path.
	## Brass kiosk pedestal with a wide angled screen, central floating
	## hologram of all 9 district markers (small unshaded spheres in
	## district accent colors arranged in a 3x3 grid), brass legend bar
	## along the bottom, and 2 small lantern brackets.
	var pivot: Node3D = Node3D.new()
	pivot.name = "TH_DistrictMapKiosk"
	# NE radial path (angle = pi/4 from +X), at radius 6.5
	var ang: float = PI / 4.0
	pivot.position = TOWN_CENTER + Vector3(cos(ang) * 6.5, 0, sin(ang) * 6.5)
	pivot.rotation.y = -ang - PI / 2.0
	geom.add_child(pivot)
	# Materials
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.20, 0.22, 0.26)
	stone_mat.metallic = 0.18
	stone_mat.roughness = 0.85
	stone_mat.emission_enabled = true
	stone_mat.emission = Color(0.30, 0.45, 0.60)
	stone_mat.emission_energy_multiplier = 0.18
	var brass_mat: StandardMaterial3D = StandardMaterial3D.new()
	brass_mat.albedo_color = Color(0.85, 0.55, 0.18)
	brass_mat.metallic = 0.95
	brass_mat.roughness = 0.30
	brass_mat.emission_enabled = true
	brass_mat.emission = Color(1.0, 0.50, 0.10)
	brass_mat.emission_energy_multiplier = 0.55
	var screen_mat: StandardMaterial3D = StandardMaterial3D.new()
	screen_mat.albedo_color = Color(0.45, 0.85, 1.0)
	screen_mat.emission_enabled = true
	screen_mat.emission = Color(0.45, 0.85, 1.0)
	screen_mat.emission_energy_multiplier = 6.0
	screen_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var flame_mat: StandardMaterial3D = StandardMaterial3D.new()
	flame_mat.albedo_color = Color(1.0, 0.65, 0.20)
	flame_mat.emission_enabled = true
	flame_mat.emission = Color(1.0, 0.55, 0.10)
	flame_mat.emission_energy_multiplier = 7.5
	flame_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	# District accent colors for the 9 map markers (D1..D9)
	var district_colors: Array = [
		Color(0.40, 0.85, 1.0),    # D1 data cyan
		Color(0.55, 1.0, 0.40),    # D2 toxic green
		Color(0.75, 0.45, 1.0),    # D3 violet
		Color(0.40, 0.95, 0.55),   # D4 bloom green
		Color(0.65, 0.85, 1.0),    # D5 ice blue
		Color(1.0, 0.40, 0.85),    # D6 neon magenta
		Color(1.0, 0.75, 0.40),    # D7 sandstone amber
		Color(0.30, 0.55, 1.0),    # D8 ocean blue
		Color(1.0, 0.45, 0.10),    # D9 forge amber
	]
	# ---- Stepped basalt pedestal ----
	var pedestal: MeshInstance3D = MeshInstance3D.new()
	var pmm: BoxMesh = BoxMesh.new()
	pmm.size = Vector3(2.20, 0.95, 1.20)
	pedestal.mesh = pmm
	pedestal.material_override = stone_mat
	pedestal.position = Vector3(0, 0.48, 0)
	pivot.add_child(pedestal)
	# Pedestal collision
	var ped_sb: StaticBody3D = StaticBody3D.new()
	ped_sb.position = Vector3(0, 0.48, 0)
	var ped_cs: CollisionShape3D = CollisionShape3D.new()
	var ped_bsh: BoxShape3D = BoxShape3D.new()
	ped_bsh.size = Vector3(2.20, 0.95, 1.20)
	ped_cs.shape = ped_bsh
	ped_sb.add_child(ped_cs)
	pivot.add_child(ped_sb)
	# Brass top trim
	var top_trim: MeshInstance3D = MeshInstance3D.new()
	var ttm: BoxMesh = BoxMesh.new()
	ttm.size = Vector3(2.30, 0.10, 1.30)
	top_trim.mesh = ttm
	top_trim.material_override = brass_mat
	top_trim.position = Vector3(0, 1.00, 0)
	pivot.add_child(top_trim)
	# ---- Wide angled screen mounted on the pedestal ----
	# Brass frame
	var frame: MeshInstance3D = MeshInstance3D.new()
	var fmm: BoxMesh = BoxMesh.new()
	fmm.size = Vector3(2.20, 1.50, 0.10)
	frame.mesh = fmm
	frame.material_override = brass_mat
	frame.position = Vector3(0, 1.85, -0.20)
	frame.rotation.x = -PI / 6.0
	pivot.add_child(frame)
	# Screen face
	var screen: MeshInstance3D = MeshInstance3D.new()
	var smesh: BoxMesh = BoxMesh.new()
	smesh.size = Vector3(2.00, 1.30, 0.05)
	screen.mesh = smesh
	screen.material_override = screen_mat
	screen.position = Vector3(0, 1.85, -0.27)
	screen.rotation.x = -PI / 6.0
	pivot.add_child(screen)
	# ---- 9 district marker spheres in a 3x3 grid on the screen ----
	for row in 3:
		for col in 3:
			var idx: int = row * 3 + col
			# Per-marker accent material
			var accent_mat: StandardMaterial3D = StandardMaterial3D.new()
			accent_mat.albedo_color = district_colors[idx]
			accent_mat.emission_enabled = true
			accent_mat.emission = district_colors[idx]
			accent_mat.emission_energy_multiplier = 7.0
			accent_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
			var marker: MeshInstance3D = MeshInstance3D.new()
			var mmm: SphereMesh = SphereMesh.new()
			mmm.radius = 0.13
			mmm.height = 0.26
			marker.mesh = mmm
			marker.material_override = accent_mat
			# Position relative to the screen center, accounting for tilt
			var lx: float = -0.65 + float(col) * 0.65
			var ly: float = 0.40 - float(row) * 0.40
			# Rotate the local offset around X by the screen's tilt to land on the surface
			var offset_local: Vector3 = Vector3(lx, ly, -0.04)
			var tilt: float = -PI / 6.0
			var ty: float = offset_local.y * cos(tilt) - offset_local.z * sin(tilt)
			var tz: float = offset_local.y * sin(tilt) + offset_local.z * cos(tilt)
			marker.position = Vector3(offset_local.x, 1.85 + ty, -0.27 + tz)
			pivot.add_child(marker)
			# Per-marker pulse so each district light breathes independently
			var mpulse: Tween = pivot.create_tween().set_loops()
			var period: float = 1.4 + float(idx) * 0.12
			mpulse.tween_property(accent_mat, "emission_energy_multiplier", 9.0, period).set_ease(Tween.EASE_IN_OUT)
			mpulse.tween_property(accent_mat, "emission_energy_multiplier", 5.0, period).set_ease(Tween.EASE_IN_OUT)
	# ---- Brass legend bar along the bottom of the screen ----
	var legend: MeshInstance3D = MeshInstance3D.new()
	var lgm: BoxMesh = BoxMesh.new()
	lgm.size = Vector3(2.10, 0.18, 0.08)
	legend.mesh = lgm
	legend.material_override = brass_mat
	legend.position = Vector3(0, 1.20, -0.10)
	legend.rotation.x = -PI / 6.0
	pivot.add_child(legend)
	# ---- 2 small lantern brackets on the corners of the pedestal top ----
	for lx in [-0.95, 0.95]:
		# Bracket
		var bracket: MeshInstance3D = MeshInstance3D.new()
		var bktm: BoxMesh = BoxMesh.new()
		bktm.size = Vector3(0.12, 0.40, 0.12)
		bracket.mesh = bktm
		bracket.material_override = brass_mat
		bracket.position = Vector3(lx, 1.25, 0.55)
		pivot.add_child(bracket)
		# Lantern flame
		var flame: MeshInstance3D = MeshInstance3D.new()
		var flm: SphereMesh = SphereMesh.new()
		flm.radius = 0.10
		flm.height = 0.20
		flame.mesh = flm
		flame.material_override = flame_mat
		flame.position = Vector3(lx, 1.50, 0.55)
		pivot.add_child(flame)
		# Lantern OmniLight
		var lt: OmniLight3D = OmniLight3D.new()
		lt.position = Vector3(lx, 1.50, 0.55)
		lt.light_color = Color(1.0, 0.55, 0.15)
		lt.light_energy = 1.6
		lt.omni_range = 4.5
		pivot.add_child(lt)
	# ---- Strong cyan screen OmniLight ----
	var screen_lt: OmniLight3D = OmniLight3D.new()
	screen_lt.position = Vector3(0, 2.10, -0.40)
	screen_lt.light_color = Color(0.45, 0.85, 1.0)
	screen_lt.light_energy = 2.4
	screen_lt.omni_range = 7.0
	pivot.add_child(screen_lt)
	# Screen base pulse
	var spulse: Tween = pivot.create_tween().set_loops()
	spulse.tween_property(screen_mat, "emission_energy_multiplier", 7.5, 2.0).set_ease(Tween.EASE_IN_OUT)
	spulse.tween_property(screen_mat, "emission_energy_multiplier", 4.5, 2.0).set_ease(Tween.EASE_IN_OUT)
	# Lantern flame flicker
	var fpulse: Tween = pivot.create_tween().set_loops()
	fpulse.tween_property(flame_mat, "emission_energy_multiplier", 9.0, 0.45).set_ease(Tween.EASE_IN_OUT)
	fpulse.tween_property(flame_mat, "emission_energy_multiplier", 6.5, 0.45).set_ease(Tween.EASE_IN_OUT)


func _build_th_banner_streamers(geom: Node) -> void:
	## Epic-10 T14: 8 strings of small flag triangles connecting the
	## perimeter lampposts in a ring. Each string spans between two
	## adjacent lampposts at lantern height. 5 small triangle flags per
	## string in alternating district accent colors. Adds a festive arched
	## canopy effect tying the lampposts together visually.
	var pivot: Node3D = Node3D.new()
	pivot.name = "TH_BannerStreamers"
	pivot.position = TOWN_CENTER + Vector3(0, 0, 0)
	geom.add_child(pivot)
	# Materials
	var rope_mat: StandardMaterial3D = StandardMaterial3D.new()
	rope_mat.albedo_color = Color(0.32, 0.20, 0.12)
	rope_mat.roughness = 0.85
	rope_mat.metallic = 0.10
	# 5 flag colors that cycle around the ring (mixed accents)
	var flag_colors: Array = [
		Color(0.45, 0.85, 1.0),  # cyan
		Color(1.0, 0.55, 0.10),  # amber
		Color(0.75, 0.45, 1.0),  # violet
		Color(0.40, 0.95, 0.55), # green
		Color(1.0, 0.40, 0.85),  # magenta
	]
	# Lamppost positions (must match T6 lamppost ring at radius 13.20)
	var lamp_radius: float = 13.20
	var lamp_height: float = 4.67
	# 8 strings, each connecting lamppost i to lamppost i+1
	for i in 8:
		var ang_a: float = (float(i) + 0.5) / 8.0 * TAU
		var ang_b: float = (float(i + 1) + 0.5) / 8.0 * TAU
		var pa: Vector3 = Vector3(cos(ang_a) * lamp_radius, lamp_height, sin(ang_a) * lamp_radius)
		var pb: Vector3 = Vector3(cos(ang_b) * lamp_radius, lamp_height, sin(ang_b) * lamp_radius)
		var mid: Vector3 = (pa + pb) * 0.5
		# Sag the rope midpoint slightly downward
		mid.y -= 0.30
		var dir: Vector3 = pb - pa
		var span: float = dir.length()
		var rope_ang: float = atan2(dir.x, dir.z)
		# ---- Rope (long thin box) ----
		var rope: MeshInstance3D = MeshInstance3D.new()
		var rm: BoxMesh = BoxMesh.new()
		rm.size = Vector3(0.04, 0.04, span)
		rope.mesh = rm
		rope.material_override = rope_mat
		rope.position = mid
		rope.rotation.y = rope_ang
		pivot.add_child(rope)
		# ---- 5 flag triangles hanging from the rope ----
		for j in 5:
			var t: float = (float(j) + 0.5) / 5.0
			# Linear interpolation along the rope
			var fp: Vector3 = pa.lerp(pb, t)
			# Sag pull (deeper toward the middle)
			var sag: float = sin(t * PI) * 0.40
			fp.y -= sag
			# Per-flag accent material
			var col_idx: int = (i * 5 + j) % flag_colors.size()
			var flag_mat: StandardMaterial3D = StandardMaterial3D.new()
			flag_mat.albedo_color = flag_colors[col_idx]
			flag_mat.emission_enabled = true
			flag_mat.emission = flag_colors[col_idx]
			flag_mat.emission_energy_multiplier = 4.5
			flag_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
			# Triangle flag (PrismMesh, narrow)
			var flag: MeshInstance3D = MeshInstance3D.new()
			var fmm: PrismMesh = PrismMesh.new()
			fmm.size = Vector3(0.18, 0.30, 0.04)
			flag.mesh = fmm
			flag.material_override = flag_mat
			flag.position = fp + Vector3(0, -0.20, 0)
			flag.rotation.y = rope_ang
			# Slight per-flag tilt for variety
			flag.rotation.z = sin(float(i * 5 + j) * 0.7) * 0.20
			pivot.add_child(flag)
			# Per-flag accent pulse with offset period for shimmer effect
			var period: float = 1.4 + float(j) * 0.10 + float(i) * 0.05
			var fpulse2: Tween = pivot.create_tween().set_loops()
			fpulse2.tween_property(flag_mat, "emission_energy_multiplier", 6.5, period).set_ease(Tween.EASE_IN_OUT)
			fpulse2.tween_property(flag_mat, "emission_energy_multiplier", 3.0, period).set_ease(Tween.EASE_IN_OUT)


func _build_th_ambient_data_motes(geom: Node) -> void:
	## Epic-10 T15: plaza-wide ambient data motes — 4 GPUParticles3D
	## emitters spaced across the plaza quadrants, each emitting drifting
	## cyan motes upward from a wide box area, plus 1 wide central
	## upward column of brighter motes from the beacon pad. Reads as
	## "the data heart sheds sparks across the plaza".
	var pivot: Node3D = Node3D.new()
	pivot.name = "TH_AmbientDataMotes"
	pivot.position = TOWN_CENTER + Vector3(0, 0, 0)
	geom.add_child(pivot)
	# Mote mesh — small unshaded sphere
	var mote_mesh: SphereMesh = SphereMesh.new()
	mote_mesh.radius = 0.05
	mote_mesh.height = 0.10
	# 4 quadrant emitters
	var quad_data: Array = [
		{"pos": Vector3(-7.0, 0.30, -7.0), "color": Color(0.45, 0.85, 1.0, 1.0)},
		{"pos": Vector3(7.0, 0.30, -7.0), "color": Color(0.55, 0.90, 1.0, 1.0)},
		{"pos": Vector3(-7.0, 0.30, 7.0), "color": Color(0.45, 0.85, 1.0, 1.0)},
		{"pos": Vector3(7.0, 0.30, 7.0), "color": Color(0.55, 0.90, 1.0, 1.0)},
	]
	for qd in quad_data:
		var emit: GPUParticles3D = GPUParticles3D.new()
		emit.position = qd["pos"]
		emit.amount = 28
		emit.lifetime = 5.0
		var pmat: ParticleProcessMaterial = ParticleProcessMaterial.new()
		pmat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
		pmat.emission_box_extents = Vector3(5.0, 0.30, 5.0)
		pmat.direction = Vector3(0, 1, 0)
		pmat.spread = 14.0
		pmat.initial_velocity_min = 0.3
		pmat.initial_velocity_max = 0.6
		pmat.gravity = Vector3(0, 0.05, 0)
		pmat.scale_min = 0.6
		pmat.scale_max = 1.2
		pmat.color = qd["color"]
		emit.process_material = pmat
		emit.draw_pass_1 = mote_mesh
		pivot.add_child(emit)
	# Central upward column from the beacon pad — brighter, denser
	var central_emit: GPUParticles3D = GPUParticles3D.new()
	central_emit.position = Vector3(0, 1.20, 0)
	central_emit.amount = 60
	central_emit.lifetime = 6.0
	var cpmat: ParticleProcessMaterial = ParticleProcessMaterial.new()
	cpmat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_RING
	cpmat.emission_ring_radius = 2.50
	cpmat.emission_ring_inner_radius = 2.00
	cpmat.emission_ring_height = 0.05
	cpmat.emission_ring_axis = Vector3(0, 1, 0)
	cpmat.direction = Vector3(0, 1, 0)
	cpmat.spread = 8.0
	cpmat.initial_velocity_min = 0.5
	cpmat.initial_velocity_max = 1.0
	cpmat.gravity = Vector3(0, 0.10, 0)
	cpmat.scale_min = 0.8
	cpmat.scale_max = 1.4
	cpmat.color = Color(0.55, 0.90, 1.0, 1.0)
	central_emit.process_material = cpmat
	central_emit.draw_pass_1 = mote_mesh
	pivot.add_child(central_emit)


func _build_th_vendor_npc(town: Node) -> void:
	## Epic-10 T16: Vendor Merchant Trex — flamboyant merchant standing
	## behind the vendor kiosk, calling out wares with his right arm
	## raised. Wide brass-trimmed coat with multi-pocket apron, brass
	## hat with a feather plume, and an arm-wave tween.
	var slots: Node3D = town.get_node_or_null("NPCSlots") as Node3D
	if slots == null:
		return
	var slot: Marker3D = Marker3D.new()
	slot.name = "THVendorMerchantTrexSlot"
	# Stand behind the vendor kiosk (kiosk at NW radial path radius 6.5)
	# Position is just behind the kiosk counter (slightly further out)
	var ang: float = 3.0 * PI / 4.0
	slot.position = TOWN_CENTER + Vector3(cos(ang) * 7.5, 0, sin(ang) * 7.5)
	slots.add_child(slot)
	var npc_scene: PackedScene = load("res://scenes/entities/npcs/VillagerR3.tscn") as PackedScene
	if npc_scene == null:
		return
	var npc: Node3D = npc_scene.instantiate() as Node3D
	npc.name = "THVendorMerchantTrex"
	if "npc_name" in npc:
		npc.set("npc_name", "Merchant Trex")
	if "npc_id" in npc:
		npc.set("npc_id", "th_vendor_merchant_trex")
	# Face inward toward the beacon (along ang+pi)
	npc.rotation.y = -ang + PI / 2.0
	slot.add_child(npc)
	# Materials
	var coat_mat: StandardMaterial3D = StandardMaterial3D.new()
	coat_mat.albedo_color = Color(0.30, 0.18, 0.10)
	coat_mat.roughness = 0.85
	coat_mat.metallic = 0.18
	coat_mat.emission_enabled = true
	coat_mat.emission = Color(0.65, 0.30, 0.05)
	coat_mat.emission_energy_multiplier = 0.20
	var brass_mat: StandardMaterial3D = StandardMaterial3D.new()
	brass_mat.albedo_color = Color(0.85, 0.55, 0.18)
	brass_mat.metallic = 0.95
	brass_mat.roughness = 0.30
	brass_mat.emission_enabled = true
	brass_mat.emission = Color(1.0, 0.50, 0.10)
	brass_mat.emission_energy_multiplier = 0.55
	var apron_mat: StandardMaterial3D = StandardMaterial3D.new()
	apron_mat.albedo_color = Color(0.55, 0.18, 0.10)
	apron_mat.roughness = 0.85
	apron_mat.metallic = 0.10
	apron_mat.emission_enabled = true
	apron_mat.emission = Color(0.85, 0.20, 0.05)
	apron_mat.emission_energy_multiplier = 0.30
	var feather_mat: StandardMaterial3D = StandardMaterial3D.new()
	feather_mat.albedo_color = Color(1.0, 0.55, 0.10)
	feather_mat.emission_enabled = true
	feather_mat.emission = Color(1.0, 0.55, 0.10)
	feather_mat.emission_energy_multiplier = 5.0
	feather_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	# ---- Wide brass-trimmed coat (chest box) ----
	var coat: MeshInstance3D = MeshInstance3D.new()
	var cmesh: BoxMesh = BoxMesh.new()
	cmesh.size = Vector3(1.10, 1.40, 0.65)
	coat.mesh = cmesh
	coat.material_override = coat_mat
	coat.position = Vector3(0, 1.05, 0)
	npc.add_child(coat)
	# Brass collar trim
	var collar: MeshInstance3D = MeshInstance3D.new()
	var colm: BoxMesh = BoxMesh.new()
	colm.size = Vector3(1.10, 0.10, 0.65)
	collar.mesh = colm
	collar.material_override = brass_mat
	collar.position = Vector3(0, 1.75, 0)
	npc.add_child(collar)
	# Coat front brass buttons (4 stud spheres down the chest)
	for by in [1.55, 1.30, 1.05, 0.80]:
		var btn: MeshInstance3D = MeshInstance3D.new()
		var bm: SphereMesh = SphereMesh.new()
		bm.radius = 0.05
		bm.height = 0.10
		btn.mesh = bm
		btn.material_override = brass_mat
		btn.position = Vector3(0, by, -0.34)
		npc.add_child(btn)
	# ---- Multi-pocket apron front (a smaller apron box overlay) ----
	var apron: MeshInstance3D = MeshInstance3D.new()
	var apm: BoxMesh = BoxMesh.new()
	apm.size = Vector3(0.95, 0.85, 0.06)
	apron.mesh = apm
	apron.material_override = apron_mat
	apron.position = Vector3(0, 0.90, -0.36)
	npc.add_child(apron)
	# 4 small brass pocket slot bars on the apron
	for px in [-0.30, 0.30]:
		for py in [1.00, 0.75]:
			var pocket: MeshInstance3D = MeshInstance3D.new()
			var pm: BoxMesh = BoxMesh.new()
			pm.size = Vector3(0.32, 0.06, 0.04)
			pocket.mesh = pm
			pocket.material_override = brass_mat
			pocket.position = Vector3(px, py, -0.40)
			npc.add_child(pocket)
	# ---- Brass hat (wide-brimmed cylinder with feather plume) ----
	# Hat brim (wide flat torus)
	var brim: MeshInstance3D = MeshInstance3D.new()
	var brm: TorusMesh = TorusMesh.new()
	brm.inner_radius = 0.32
	brm.outer_radius = 0.50
	brim.mesh = brm
	brim.material_override = coat_mat
	brim.position = Vector3(0, 1.95, 0)
	brim.rotation.x = PI / 2.0
	npc.add_child(brim)
	# Hat crown (cylinder)
	var crown: MeshInstance3D = MeshInstance3D.new()
	var crm: CylinderMesh = CylinderMesh.new()
	crm.top_radius = 0.30
	crm.bottom_radius = 0.32
	crm.height = 0.30
	crown.mesh = crm
	crown.material_override = coat_mat
	crown.position = Vector3(0, 2.10, 0)
	npc.add_child(crown)
	# Hat brass band
	var hat_band: MeshInstance3D = MeshInstance3D.new()
	var hbm: TorusMesh = TorusMesh.new()
	hbm.inner_radius = 0.28
	hbm.outer_radius = 0.34
	hat_band.mesh = hbm
	hat_band.material_override = brass_mat
	hat_band.position = Vector3(0, 2.00, 0)
	hat_band.rotation.x = PI / 2.0
	npc.add_child(hat_band)
	# Feather plume (long thin prism on the side of the hat)
	var feather: MeshInstance3D = MeshInstance3D.new()
	var fmm: PrismMesh = PrismMesh.new()
	fmm.size = Vector3(0.10, 0.55, 0.06)
	feather.mesh = fmm
	feather.material_override = feather_mat
	feather.position = Vector3(0.25, 2.45, -0.10)
	feather.rotation.z = -0.40
	npc.add_child(feather)
	# ---- Arms ----
	# Left arm (down at his side)
	var left_arm: MeshInstance3D = MeshInstance3D.new()
	var lam: BoxMesh = BoxMesh.new()
	lam.size = Vector3(0.20, 0.85, 0.20)
	left_arm.mesh = lam
	left_arm.material_override = coat_mat
	left_arm.position = Vector3(-0.65, 1.05, 0)
	npc.add_child(left_arm)
	# Right arm — pivot at the shoulder so we can wave it
	var right_arm_pivot: Node3D = Node3D.new()
	right_arm_pivot.position = Vector3(0.65, 1.55, 0)
	npc.add_child(right_arm_pivot)
	var right_arm: MeshInstance3D = MeshInstance3D.new()
	var ram: BoxMesh = BoxMesh.new()
	ram.size = Vector3(0.20, 0.85, 0.20)
	right_arm.mesh = ram
	right_arm.material_override = coat_mat
	right_arm.position = Vector3(0, -0.42, 0)
	right_arm_pivot.add_child(right_arm)
	# Right hand (small box at the end of the arm)
	var right_hand: MeshInstance3D = MeshInstance3D.new()
	var rhm: BoxMesh = BoxMesh.new()
	rhm.size = Vector3(0.20, 0.18, 0.20)
	right_hand.mesh = rhm
	right_hand.material_override = brass_mat
	right_hand.position = Vector3(0, -0.92, 0)
	right_arm_pivot.add_child(right_hand)
	# ---- Subtle warm OmniLight ----
	var lt: OmniLight3D = OmniLight3D.new()
	lt.position = Vector3(0, 1.50, -0.20)
	lt.light_color = Color(1.0, 0.65, 0.20)
	lt.light_energy = 1.6
	lt.omni_range = 4.5
	npc.add_child(lt)
	# ---- Arm-wave tween — right arm rotates up + down repeatedly ----
	var wave: Tween = npc.create_tween().set_loops()
	wave.tween_property(right_arm_pivot, "rotation:z", -2.20, 0.85).set_ease(Tween.EASE_IN_OUT)
	wave.tween_property(right_arm_pivot, "rotation:z", -1.40, 0.45).set_ease(Tween.EASE_IN_OUT)
	wave.tween_property(right_arm_pivot, "rotation:z", -2.20, 0.85).set_ease(Tween.EASE_IN_OUT)
	wave.tween_property(right_arm_pivot, "rotation:z", -0.10, 0.55).set_ease(Tween.EASE_IN_OUT)
	wave.tween_property(right_arm_pivot, "rotation:z", -0.10, 1.00)
	# Feather pulse
	var fpulse: Tween = npc.create_tween().set_loops()
	fpulse.tween_property(feather_mat, "emission_energy_multiplier", 7.0, 1.4).set_ease(Tween.EASE_IN_OUT)
	fpulse.tween_property(feather_mat, "emission_energy_multiplier", 4.0, 1.4).set_ease(Tween.EASE_IN_OUT)


func _build_th_combat_trainer_npc(town: Node) -> void:
	## Epic-10 T17: Combat Trainer Vex — armored swordsman NPC at the
	## practice dummy stand on the W radial path. Iron breastplate +
	## brass shoulder pauldrons, brass helm with glowing amber visor
	## slit, and a glowing sword on a pivot doing a continuous overhead
	## chop swing demonstrating combat technique.
	var slots: Node3D = town.get_node_or_null("NPCSlots") as Node3D
	if slots == null:
		return
	var slot: Marker3D = Marker3D.new()
	slot.name = "THCombatTrainerVexSlot"
	# Stand near the practice dummy at W radial path radius 6.5, slightly offset
	slot.position = TOWN_CENTER + Vector3(-5.5, 0, 0.85)
	slots.add_child(slot)
	var npc_scene: PackedScene = load("res://scenes/entities/npcs/VillagerR3.tscn") as PackedScene
	if npc_scene == null:
		return
	var npc: Node3D = npc_scene.instantiate() as Node3D
	npc.name = "THCombatTrainerVex"
	if "npc_name" in npc:
		npc.set("npc_name", "Combat Trainer Vex")
	if "npc_id" in npc:
		npc.set("npc_id", "th_combat_trainer_vex")
	# Face the dummy (-X direction)
	npc.rotation.y = -PI / 2.0
	slot.add_child(npc)
	# Materials
	var iron_mat: StandardMaterial3D = StandardMaterial3D.new()
	iron_mat.albedo_color = Color(0.18, 0.16, 0.18)
	iron_mat.metallic = 0.85
	iron_mat.roughness = 0.45
	iron_mat.emission_enabled = true
	iron_mat.emission = Color(0.45, 0.55, 0.65)
	iron_mat.emission_energy_multiplier = 0.30
	var brass_mat: StandardMaterial3D = StandardMaterial3D.new()
	brass_mat.albedo_color = Color(0.85, 0.55, 0.18)
	brass_mat.metallic = 0.95
	brass_mat.roughness = 0.30
	brass_mat.emission_enabled = true
	brass_mat.emission = Color(1.0, 0.50, 0.10)
	brass_mat.emission_energy_multiplier = 0.55
	var amber_mat: StandardMaterial3D = StandardMaterial3D.new()
	amber_mat.albedo_color = Color(1.0, 0.55, 0.10)
	amber_mat.emission_enabled = true
	amber_mat.emission = Color(1.0, 0.55, 0.10)
	amber_mat.emission_energy_multiplier = 6.5
	amber_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var leather_mat: StandardMaterial3D = StandardMaterial3D.new()
	leather_mat.albedo_color = Color(0.30, 0.18, 0.10)
	leather_mat.roughness = 0.85
	leather_mat.metallic = 0.10
	# ---- Iron breastplate (chest box) ----
	var torso: MeshInstance3D = MeshInstance3D.new()
	var tm: BoxMesh = BoxMesh.new()
	tm.size = Vector3(1.05, 1.30, 0.55)
	torso.mesh = tm
	torso.material_override = iron_mat
	torso.position = Vector3(0, 1.20, 0)
	npc.add_child(torso)
	# Brass chest plate seam
	var seam: MeshInstance3D = MeshInstance3D.new()
	var seamesh: BoxMesh = BoxMesh.new()
	seamesh.size = Vector3(0.18, 1.20, 0.06)
	seam.mesh = seamesh
	seam.material_override = brass_mat
	seam.position = Vector3(0, 1.20, -0.30)
	npc.add_child(seam)
	# Glowing chest core sphere
	var core: MeshInstance3D = MeshInstance3D.new()
	var ccm: SphereMesh = SphereMesh.new()
	ccm.radius = 0.10
	ccm.height = 0.20
	core.mesh = ccm
	core.material_override = amber_mat
	core.position = Vector3(0, 1.40, -0.32)
	npc.add_child(core)
	# Leather belt at the waist
	var belt: MeshInstance3D = MeshInstance3D.new()
	var belt_m: BoxMesh = BoxMesh.new()
	belt_m.size = Vector3(1.10, 0.18, 0.60)
	belt.mesh = belt_m
	belt.material_override = leather_mat
	belt.position = Vector3(0, 0.65, 0)
	npc.add_child(belt)
	# Brass belt buckle
	var buckle: MeshInstance3D = MeshInstance3D.new()
	var bkm: BoxMesh = BoxMesh.new()
	bkm.size = Vector3(0.20, 0.18, 0.06)
	buckle.mesh = bkm
	buckle.material_override = brass_mat
	buckle.position = Vector3(0, 0.65, -0.32)
	npc.add_child(buckle)
	# ---- Brass shoulder pauldrons ----
	for sx in [-0.65, 0.65]:
		var paul: MeshInstance3D = MeshInstance3D.new()
		var pm: SphereMesh = SphereMesh.new()
		pm.radius = 0.25
		pm.height = 0.45
		paul.mesh = pm
		paul.material_override = brass_mat
		paul.position = Vector3(sx, 1.80, 0)
		paul.scale = Vector3(1.0, 0.55, 1.0)
		npc.add_child(paul)
	# ---- Brass helm with visor slit ----
	var helm: MeshInstance3D = MeshInstance3D.new()
	var hmm: BoxMesh = BoxMesh.new()
	hmm.size = Vector3(0.65, 0.65, 0.65)
	helm.mesh = hmm
	helm.material_override = iron_mat
	helm.position = Vector3(0, 2.15, 0)
	npc.add_child(helm)
	# Helm crown ridge (small prism)
	var crown_ridge: MeshInstance3D = MeshInstance3D.new()
	var crm: PrismMesh = PrismMesh.new()
	crm.size = Vector3(0.20, 0.20, 0.65)
	crown_ridge.mesh = crm
	crown_ridge.material_override = brass_mat
	crown_ridge.position = Vector3(0, 2.55, 0)
	npc.add_child(crown_ridge)
	# Visor slit (glowing horizontal stripe)
	var visor: MeshInstance3D = MeshInstance3D.new()
	var vm: BoxMesh = BoxMesh.new()
	vm.size = Vector3(0.45, 0.08, 0.04)
	visor.mesh = vm
	visor.material_override = amber_mat
	visor.position = Vector3(0, 2.18, -0.34)
	npc.add_child(visor)
	# ---- Left arm (down with shield) ----
	var left_arm: MeshInstance3D = MeshInstance3D.new()
	var lam: BoxMesh = BoxMesh.new()
	lam.size = Vector3(0.20, 0.85, 0.20)
	left_arm.mesh = lam
	left_arm.material_override = iron_mat
	left_arm.position = Vector3(-0.65, 1.20, 0)
	npc.add_child(left_arm)
	# Round brass shield held in left hand
	var shield: MeshInstance3D = MeshInstance3D.new()
	var shm: CylinderMesh = CylinderMesh.new()
	shm.top_radius = 0.30
	shm.bottom_radius = 0.30
	shm.height = 0.10
	shield.mesh = shm
	shield.material_override = brass_mat
	shield.position = Vector3(-0.85, 0.80, -0.20)
	shield.rotation.x = PI / 2.0
	shield.rotation.z = PI / 2.0
	npc.add_child(shield)
	# Shield glowing center boss
	var boss: MeshInstance3D = MeshInstance3D.new()
	var bossm: SphereMesh = SphereMesh.new()
	bossm.radius = 0.10
	bossm.height = 0.20
	boss.mesh = bossm
	boss.material_override = amber_mat
	boss.position = Vector3(-0.92, 0.80, -0.20)
	npc.add_child(boss)
	# ---- Right arm with sword on a pivot at the shoulder ----
	var sword_pivot: Node3D = Node3D.new()
	sword_pivot.position = Vector3(0.65, 1.65, 0)
	npc.add_child(sword_pivot)
	# Right arm box
	var right_arm: MeshInstance3D = MeshInstance3D.new()
	var ram: BoxMesh = BoxMesh.new()
	ram.size = Vector3(0.18, 0.85, 0.18)
	right_arm.mesh = ram
	right_arm.material_override = iron_mat
	right_arm.position = Vector3(0, -0.42, 0)
	sword_pivot.add_child(right_arm)
	# Sword grip (wood cylinder)
	var wood_mat: StandardMaterial3D = StandardMaterial3D.new()
	wood_mat.albedo_color = Color(0.32, 0.20, 0.12)
	wood_mat.roughness = 0.85
	var grip: MeshInstance3D = MeshInstance3D.new()
	var gm: CylinderMesh = CylinderMesh.new()
	gm.top_radius = 0.05
	gm.bottom_radius = 0.05
	gm.height = 0.32
	grip.mesh = gm
	grip.material_override = wood_mat
	grip.position = Vector3(0, -0.95, 0)
	sword_pivot.add_child(grip)
	# Brass crossguard
	var guard: MeshInstance3D = MeshInstance3D.new()
	var gdm: BoxMesh = BoxMesh.new()
	gdm.size = Vector3(0.40, 0.07, 0.08)
	guard.mesh = gdm
	guard.material_override = brass_mat
	guard.position = Vector3(0, -1.13, 0)
	sword_pivot.add_child(guard)
	# Iron blade (long box)
	var blade: MeshInstance3D = MeshInstance3D.new()
	var bldm: BoxMesh = BoxMesh.new()
	bldm.size = Vector3(0.16, 1.30, 0.05)
	blade.mesh = bldm
	blade.material_override = iron_mat
	blade.position = Vector3(0, -1.85, 0)
	sword_pivot.add_child(blade)
	# Glowing blade core stripe
	var blade_core: MeshInstance3D = MeshInstance3D.new()
	var bcm: BoxMesh = BoxMesh.new()
	bcm.size = Vector3(0.04, 1.20, 0.06)
	blade_core.mesh = bcm
	blade_core.material_override = amber_mat
	blade_core.position = Vector3(0, -1.85, 0)
	sword_pivot.add_child(blade_core)
	# Blade tip prism
	var tip: MeshInstance3D = MeshInstance3D.new()
	var tipm: PrismMesh = PrismMesh.new()
	tipm.size = Vector3(0.16, 0.20, 0.05)
	tip.mesh = tipm
	tip.material_override = iron_mat
	tip.position = Vector3(0, -2.55, 0)
	tip.rotation.x = PI
	sword_pivot.add_child(tip)
	# Initial pose — sword rests at his side
	sword_pivot.rotation.x = 0.10
	# ---- Subtle warm OmniLight ----
	var lt: OmniLight3D = OmniLight3D.new()
	lt.position = Vector3(0, 1.80, -0.30)
	lt.light_color = Color(1.0, 0.65, 0.20)
	lt.light_energy = 1.6
	lt.omni_range = 4.5
	npc.add_child(lt)
	# ---- Overhead chop swing tween — sword raises high then chops down ----
	var chop: Tween = npc.create_tween().set_loops()
	chop.tween_property(sword_pivot, "rotation:x", -2.40, 0.65).set_ease(Tween.EASE_OUT)
	chop.tween_property(sword_pivot, "rotation:x", -2.40, 0.40)
	chop.tween_property(sword_pivot, "rotation:x", 0.85, 0.30).set_ease(Tween.EASE_IN)
	chop.tween_property(sword_pivot, "rotation:x", 0.10, 0.40).set_ease(Tween.EASE_OUT)
	chop.tween_property(sword_pivot, "rotation:x", 0.10, 0.80)
	# Shared chest core + visor + blade core + shield boss pulse
	var apulse: Tween = npc.create_tween().set_loops()
	apulse.tween_property(amber_mat, "emission_energy_multiplier", 8.5, 1.6).set_ease(Tween.EASE_IN_OUT)
	apulse.tween_property(amber_mat, "emission_energy_multiplier", 5.0, 1.6).set_ease(Tween.EASE_IN_OUT)


func _build_th_cartographer_npc(town: Node) -> void:
	## Epic-10 T18: Cartographer Atlas — scholarly NPC at the district map
	## kiosk on the NE radial path. Long blue robe with brass trim, brass
	## monocle eyepiece, oversized scroll tube on his back, and a pointing
	## right hand on a pivot doing a tutorial-style "map gesture".
	var slots: Node3D = town.get_node_or_null("NPCSlots") as Node3D
	if slots == null:
		return
	var slot: Marker3D = Marker3D.new()
	slot.name = "THCartographerAtlasSlot"
	# Stand beside the district map kiosk on the NE radial path
	var ang: float = PI / 4.0
	slot.position = TOWN_CENTER + Vector3(cos(ang) * 7.6, 0, sin(ang) * 7.6)
	slots.add_child(slot)
	var npc_scene: PackedScene = load("res://scenes/entities/npcs/VillagerR3.tscn") as PackedScene
	if npc_scene == null:
		return
	var npc: Node3D = npc_scene.instantiate() as Node3D
	npc.name = "THCartographerAtlas"
	if "npc_name" in npc:
		npc.set("npc_name", "Cartographer Atlas")
	if "npc_id" in npc:
		npc.set("npc_id", "th_cartographer_atlas")
	# Face the kiosk (toward beacon center, perpendicular to radial direction)
	npc.rotation.y = -ang + PI / 2.0
	slot.add_child(npc)
	# Materials
	var robe_mat: StandardMaterial3D = StandardMaterial3D.new()
	robe_mat.albedo_color = Color(0.18, 0.30, 0.55)
	robe_mat.roughness = 0.85
	robe_mat.metallic = 0.18
	robe_mat.emission_enabled = true
	robe_mat.emission = Color(0.30, 0.55, 1.0)
	robe_mat.emission_energy_multiplier = 0.30
	var brass_mat: StandardMaterial3D = StandardMaterial3D.new()
	brass_mat.albedo_color = Color(0.85, 0.55, 0.18)
	brass_mat.metallic = 0.95
	brass_mat.roughness = 0.30
	brass_mat.emission_enabled = true
	brass_mat.emission = Color(1.0, 0.50, 0.10)
	brass_mat.emission_energy_multiplier = 0.55
	var data_mat: StandardMaterial3D = StandardMaterial3D.new()
	data_mat.albedo_color = Color(0.45, 0.85, 1.0)
	data_mat.emission_enabled = true
	data_mat.emission = Color(0.45, 0.85, 1.0)
	data_mat.emission_energy_multiplier = 6.5
	data_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var paper_mat: StandardMaterial3D = StandardMaterial3D.new()
	paper_mat.albedo_color = Color(0.95, 0.85, 0.55)
	paper_mat.roughness = 0.85
	paper_mat.emission_enabled = true
	paper_mat.emission = Color(1.0, 0.65, 0.20)
	paper_mat.emission_energy_multiplier = 0.30
	# ---- Long blue robe ----
	var robe: MeshInstance3D = MeshInstance3D.new()
	var rmesh: BoxMesh = BoxMesh.new()
	rmesh.size = Vector3(0.95, 1.75, 0.55)
	robe.mesh = rmesh
	robe.material_override = robe_mat
	robe.position = Vector3(0, 0.90, 0)
	npc.add_child(robe)
	# Brass collar trim
	var collar: MeshInstance3D = MeshInstance3D.new()
	var colm: BoxMesh = BoxMesh.new()
	colm.size = Vector3(0.95, 0.10, 0.55)
	collar.mesh = colm
	collar.material_override = brass_mat
	collar.position = Vector3(0, 1.80, 0)
	npc.add_child(collar)
	# Vertical brass robe trim down the chest
	var seam: MeshInstance3D = MeshInstance3D.new()
	var seamesh: BoxMesh = BoxMesh.new()
	seamesh.size = Vector3(0.16, 1.65, 0.06)
	seam.mesh = seamesh
	seam.material_override = brass_mat
	seam.position = Vector3(0, 0.95, -0.30)
	npc.add_child(seam)
	# Brass shoulder pauldrons (small)
	for sx in [-0.55, 0.55]:
		var paul: MeshInstance3D = MeshInstance3D.new()
		var pm: SphereMesh = SphereMesh.new()
		pm.radius = 0.18
		pm.height = 0.34
		paul.mesh = pm
		paul.material_override = brass_mat
		paul.position = Vector3(sx, 1.65, 0)
		paul.scale = Vector3(1.0, 0.55, 1.0)
		npc.add_child(paul)
	# ---- Brass monocle eyepiece on the right side of the head ----
	var monocle_frame: MeshInstance3D = MeshInstance3D.new()
	var mfm: TorusMesh = TorusMesh.new()
	mfm.inner_radius = 0.10
	mfm.outer_radius = 0.14
	monocle_frame.mesh = mfm
	monocle_frame.material_override = brass_mat
	monocle_frame.position = Vector3(0.18, 1.92, -0.30)
	monocle_frame.rotation.y = PI / 2.0
	npc.add_child(monocle_frame)
	# Glowing monocle lens
	var lens: MeshInstance3D = MeshInstance3D.new()
	var lm: SphereMesh = SphereMesh.new()
	lm.radius = 0.09
	lm.height = 0.10
	lens.mesh = lm
	lens.material_override = data_mat
	lens.position = Vector3(0.18, 1.92, -0.30)
	lens.scale = Vector3(1.0, 1.0, 0.30)
	npc.add_child(lens)
	# Monocle chain (small thin cylinder draping down to the collar)
	var chain: MeshInstance3D = MeshInstance3D.new()
	var chm: CylinderMesh = CylinderMesh.new()
	chm.top_radius = 0.012
	chm.bottom_radius = 0.012
	chm.height = 0.55
	chain.mesh = chm
	chain.material_override = brass_mat
	chain.position = Vector3(0.30, 1.65, -0.30)
	chain.rotation.z = -0.4
	npc.add_child(chain)
	# ---- Oversized scroll tube on his back ----
	var tube: MeshInstance3D = MeshInstance3D.new()
	var tm: CylinderMesh = CylinderMesh.new()
	tm.top_radius = 0.10
	tm.bottom_radius = 0.10
	tm.height = 1.10
	tube.mesh = tm
	tube.material_override = brass_mat
	tube.position = Vector3(0, 1.30, 0.30)
	tube.rotation.z = -0.30
	npc.add_child(tube)
	# Scroll paper sticking out the top of the tube
	var scroll: MeshInstance3D = MeshInstance3D.new()
	var sm: CylinderMesh = CylinderMesh.new()
	sm.top_radius = 0.08
	sm.bottom_radius = 0.08
	sm.height = 0.45
	scroll.mesh = sm
	scroll.material_override = paper_mat
	scroll.position = Vector3(0.18, 1.95, 0.30)
	scroll.rotation.z = -0.30
	npc.add_child(scroll)
	# Tube end caps (brass disc on top + bottom)
	for cy in [0.78, 1.85]:
		var cap: MeshInstance3D = MeshInstance3D.new()
		var cpm: CylinderMesh = CylinderMesh.new()
		cpm.top_radius = 0.13
		cpm.bottom_radius = 0.13
		cpm.height = 0.06
		cap.mesh = cpm
		cap.material_override = brass_mat
		cap.position = Vector3(0, cy, 0.30 + (cy - 1.30) * 0.30)
		npc.add_child(cap)
	# ---- Left arm at his side ----
	var left_arm: MeshInstance3D = MeshInstance3D.new()
	var lam: BoxMesh = BoxMesh.new()
	lam.size = Vector3(0.18, 0.85, 0.18)
	left_arm.mesh = lam
	left_arm.material_override = robe_mat
	left_arm.position = Vector3(-0.55, 1.05, 0)
	npc.add_child(left_arm)
	# ---- Right arm pointing at the kiosk on a pivot ----
	var point_pivot: Node3D = Node3D.new()
	point_pivot.position = Vector3(0.55, 1.50, 0)
	npc.add_child(point_pivot)
	var right_arm: MeshInstance3D = MeshInstance3D.new()
	var ram: BoxMesh = BoxMesh.new()
	ram.size = Vector3(0.18, 0.85, 0.18)
	right_arm.mesh = ram
	right_arm.material_override = robe_mat
	right_arm.position = Vector3(0, -0.42, 0)
	point_pivot.add_child(right_arm)
	# Pointing finger box at the end of the arm
	var finger: MeshInstance3D = MeshInstance3D.new()
	var fmm: BoxMesh = BoxMesh.new()
	fmm.size = Vector3(0.12, 0.30, 0.10)
	finger.mesh = fmm
	finger.material_override = brass_mat
	finger.position = Vector3(0, -0.95, 0)
	point_pivot.add_child(finger)
	# Initial pose — arm raised pointing forward
	point_pivot.rotation.x = -1.20
	# ---- Subtle warm OmniLight ----
	var lt: OmniLight3D = OmniLight3D.new()
	lt.position = Vector3(0, 1.65, -0.20)
	lt.light_color = Color(0.65, 0.85, 1.0)
	lt.light_energy = 1.6
	lt.omni_range = 4.5
	npc.add_child(lt)
	# ---- Map gesture tween — arm sweeps left-right + slight nod ----
	var gesture: Tween = npc.create_tween().set_loops()
	gesture.tween_property(point_pivot, "rotation:y", -0.40, 1.4).set_ease(Tween.EASE_IN_OUT)
	gesture.tween_property(point_pivot, "rotation:y", 0.40, 1.4).set_ease(Tween.EASE_IN_OUT)
	# Monocle lens pulse
	var lpulse: Tween = npc.create_tween().set_loops()
	lpulse.tween_property(data_mat, "emission_energy_multiplier", 9.0, 1.8).set_ease(Tween.EASE_IN_OUT)
	lpulse.tween_property(data_mat, "emission_energy_multiplier", 5.0, 1.8).set_ease(Tween.EASE_IN_OUT)


func _build_th_shrine_keeper_npc(town: Node) -> void:
	## Epic-10 T19: Shrine Keeper Lumen — serene priest NPC at the save
	## shrine on the N radial path. Long white robe with cyan trim, brass
	## halo ring above the head, glowing data orb cupped in both hands at
	## chest height with a slow forward bowing prayer tween.
	var slots: Node3D = town.get_node_or_null("NPCSlots") as Node3D
	if slots == null:
		return
	var slot: Marker3D = Marker3D.new()
	slot.name = "THShrineKeeperLumenSlot"
	# Stand beside the save shrine on the N radial path
	slot.position = TOWN_CENTER + Vector3(2.20, 0, -6.5)
	slots.add_child(slot)
	var npc_scene: PackedScene = load("res://scenes/entities/npcs/VillagerR3.tscn") as PackedScene
	if npc_scene == null:
		return
	var npc: Node3D = npc_scene.instantiate() as Node3D
	npc.name = "THShrineKeeperLumen"
	if "npc_name" in npc:
		npc.set("npc_name", "Shrine Keeper Lumen")
	if "npc_id" in npc:
		npc.set("npc_id", "th_shrine_keeper_lumen")
	# Face the shrine altar (-X direction toward the altar)
	npc.rotation.y = -PI / 2.0
	slot.add_child(npc)
	# Materials
	var robe_mat: StandardMaterial3D = StandardMaterial3D.new()
	robe_mat.albedo_color = Color(0.85, 0.88, 0.92)
	robe_mat.roughness = 0.85
	robe_mat.metallic = 0.10
	robe_mat.emission_enabled = true
	robe_mat.emission = Color(0.65, 0.85, 1.0)
	robe_mat.emission_energy_multiplier = 0.30
	var trim_mat: StandardMaterial3D = StandardMaterial3D.new()
	trim_mat.albedo_color = Color(0.45, 0.85, 1.0)
	trim_mat.roughness = 0.65
	trim_mat.metallic = 0.40
	trim_mat.emission_enabled = true
	trim_mat.emission = Color(0.45, 0.85, 1.0)
	trim_mat.emission_energy_multiplier = 1.20
	var brass_mat: StandardMaterial3D = StandardMaterial3D.new()
	brass_mat.albedo_color = Color(0.85, 0.55, 0.18)
	brass_mat.metallic = 0.95
	brass_mat.roughness = 0.30
	brass_mat.emission_enabled = true
	brass_mat.emission = Color(1.0, 0.50, 0.10)
	brass_mat.emission_energy_multiplier = 0.55
	var orb_mat: StandardMaterial3D = StandardMaterial3D.new()
	orb_mat.albedo_color = Color(0.45, 0.85, 1.0)
	orb_mat.emission_enabled = true
	orb_mat.emission = Color(0.45, 0.85, 1.0)
	orb_mat.emission_energy_multiplier = 9.0
	orb_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	# ---- Long white robe ----
	var robe: MeshInstance3D = MeshInstance3D.new()
	var rmesh: BoxMesh = BoxMesh.new()
	rmesh.size = Vector3(0.95, 1.85, 0.55)
	robe.mesh = rmesh
	robe.material_override = robe_mat
	robe.position = Vector3(0, 0.95, 0)
	npc.add_child(robe)
	# Cyan vertical chest stripe (the data trim)
	var seam: MeshInstance3D = MeshInstance3D.new()
	var seamesh: BoxMesh = BoxMesh.new()
	seamesh.size = Vector3(0.18, 1.75, 0.06)
	seam.mesh = seamesh
	seam.material_override = trim_mat
	seam.position = Vector3(0, 0.95, -0.30)
	npc.add_child(seam)
	# Cyan horizontal trim band at the waist
	var waist: MeshInstance3D = MeshInstance3D.new()
	var wmm: BoxMesh = BoxMesh.new()
	wmm.size = Vector3(0.95, 0.10, 0.55)
	waist.mesh = wmm
	waist.material_override = trim_mat
	waist.position = Vector3(0, 0.85, 0)
	npc.add_child(waist)
	# Robe collar (white box)
	var collar: MeshInstance3D = MeshInstance3D.new()
	var colm: BoxMesh = BoxMesh.new()
	colm.size = Vector3(0.95, 0.12, 0.55)
	collar.mesh = colm
	collar.material_override = robe_mat
	collar.position = Vector3(0, 1.85, 0)
	npc.add_child(collar)
	# ---- Brass halo ring above the head ----
	var halo: MeshInstance3D = MeshInstance3D.new()
	var hmm: TorusMesh = TorusMesh.new()
	hmm.inner_radius = 0.32
	hmm.outer_radius = 0.40
	halo.mesh = hmm
	halo.material_override = brass_mat
	halo.position = Vector3(0, 2.40, 0)
	pivot_set_axis_x(halo)
	npc.add_child(halo)
	# Halo glowing inner ring (cyan torus inside the brass halo)
	var inner_halo: MeshInstance3D = MeshInstance3D.new()
	var ihm: TorusMesh = TorusMesh.new()
	ihm.inner_radius = 0.30
	ihm.outer_radius = 0.34
	inner_halo.mesh = ihm
	inner_halo.material_override = orb_mat
	inner_halo.position = Vector3(0, 2.40, 0)
	pivot_set_axis_x(inner_halo)
	npc.add_child(inner_halo)
	# ---- Cupped hands holding the data orb at chest height ----
	# Left hand (cupping from left)
	var left_hand: MeshInstance3D = MeshInstance3D.new()
	var lhm: BoxMesh = BoxMesh.new()
	lhm.size = Vector3(0.18, 0.12, 0.20)
	left_hand.mesh = lhm
	left_hand.material_override = robe_mat
	left_hand.position = Vector3(-0.20, 1.30, -0.40)
	left_hand.rotation.z = 0.30
	npc.add_child(left_hand)
	# Right hand (cupping from right)
	var right_hand: MeshInstance3D = MeshInstance3D.new()
	right_hand.mesh = lhm
	right_hand.material_override = robe_mat
	right_hand.position = Vector3(0.20, 1.30, -0.40)
	right_hand.rotation.z = -0.30
	npc.add_child(right_hand)
	# Glowing data orb cradled between the hands
	var orb: MeshInstance3D = MeshInstance3D.new()
	var orm: SphereMesh = SphereMesh.new()
	orm.radius = 0.18
	orm.height = 0.36
	orb.mesh = orm
	orb.material_override = orb_mat
	orb.position = Vector3(0, 1.45, -0.45)
	npc.add_child(orb)
	# Data motes drifting up from the orb
	var motes: GPUParticles3D = GPUParticles3D.new()
	motes.position = Vector3(0, 1.55, -0.45)
	motes.amount = 14
	motes.lifetime = 1.8
	var pmat: ParticleProcessMaterial = ParticleProcessMaterial.new()
	pmat.direction = Vector3(0, 1, 0)
	pmat.spread = 18.0
	pmat.initial_velocity_min = 0.4
	pmat.initial_velocity_max = 0.8
	pmat.gravity = Vector3(0, 0.10, 0)
	pmat.scale_min = 0.04
	pmat.scale_max = 0.08
	pmat.color = Color(0.45, 0.85, 1.0, 1.0)
	motes.process_material = pmat
	var psmesh: SphereMesh = SphereMesh.new()
	psmesh.radius = 0.04
	psmesh.height = 0.08
	motes.draw_pass_1 = psmesh
	npc.add_child(motes)
	# ---- Strong cyan OmniLight from the orb ----
	var lt: OmniLight3D = OmniLight3D.new()
	lt.position = Vector3(0, 1.50, -0.50)
	lt.light_color = Color(0.45, 0.85, 1.0)
	lt.light_energy = 2.6
	lt.omni_range = 6.5
	npc.add_child(lt)
	# ---- Slow forward bowing prayer tween ----
	var bow: Tween = npc.create_tween().set_loops()
	bow.tween_property(npc, "rotation:x", 0.18, 2.2).set_ease(Tween.EASE_IN_OUT)
	bow.tween_property(npc, "rotation:x", 0.02, 2.2).set_ease(Tween.EASE_IN_OUT)
	# Orb pulse
	var opulse: Tween = npc.create_tween().set_loops()
	opulse.tween_property(orb_mat, "emission_energy_multiplier", 11.0, 1.8).set_ease(Tween.EASE_IN_OUT)
	opulse.tween_property(orb_mat, "emission_energy_multiplier", 6.5, 1.8).set_ease(Tween.EASE_IN_OUT)


func pivot_set_axis_x(n: Node3D) -> void:
	## Helper: rotate a torus 90 degrees around X so it lies flat (horizontal halo).
	n.rotation.x = PI / 2.0


func _build_th_quest_master_npc(town: Node) -> void:
	## Epic-10 T20: Quest Master Echo — courier-style NPC standing beside
	## the quest board on the SE radial path. Brown leather field jacket
	## with brass shoulder straps, courier satchel slung across the chest,
	## brass clipboard held in left hand, right hand pointing at the
	## quest board with a slow tap-and-trace gesture.
	var slots: Node3D = town.get_node_or_null("NPCSlots") as Node3D
	if slots == null:
		return
	var slot: Marker3D = Marker3D.new()
	slot.name = "THQuestMasterEchoSlot"
	# Stand beside the quest board on the SE radial path
	var ang: float = PI / 4.0
	slot.position = TOWN_CENTER + Vector3(cos(ang) * 7.6, 0, sin(ang) * 7.6)
	slots.add_child(slot)
	var npc_scene: PackedScene = load("res://scenes/entities/npcs/VillagerR3.tscn") as PackedScene
	if npc_scene == null:
		return
	var npc: Node3D = npc_scene.instantiate() as Node3D
	npc.name = "THQuestMasterEcho"
	if "npc_name" in npc:
		npc.set("npc_name", "Quest Master Echo")
	if "npc_id" in npc:
		npc.set("npc_id", "th_quest_master_echo")
	# Face the quest board (toward beacon center along the radial line)
	npc.rotation.y = -ang + PI / 2.0
	slot.add_child(npc)
	# Materials
	var jacket_mat: StandardMaterial3D = StandardMaterial3D.new()
	jacket_mat.albedo_color = Color(0.30, 0.20, 0.12)
	jacket_mat.roughness = 0.85
	jacket_mat.metallic = 0.18
	jacket_mat.emission_enabled = true
	jacket_mat.emission = Color(0.55, 0.30, 0.10)
	jacket_mat.emission_energy_multiplier = 0.20
	var brass_mat: StandardMaterial3D = StandardMaterial3D.new()
	brass_mat.albedo_color = Color(0.85, 0.55, 0.18)
	brass_mat.metallic = 0.95
	brass_mat.roughness = 0.30
	brass_mat.emission_enabled = true
	brass_mat.emission = Color(1.0, 0.50, 0.10)
	brass_mat.emission_energy_multiplier = 0.55
	var data_mat: StandardMaterial3D = StandardMaterial3D.new()
	data_mat.albedo_color = Color(0.45, 0.85, 1.0)
	data_mat.emission_enabled = true
	data_mat.emission = Color(0.45, 0.85, 1.0)
	data_mat.emission_energy_multiplier = 6.5
	data_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var leather_mat: StandardMaterial3D = StandardMaterial3D.new()
	leather_mat.albedo_color = Color(0.18, 0.10, 0.06)
	leather_mat.roughness = 0.85
	leather_mat.metallic = 0.10
	# ---- Brown leather field jacket ----
	var jacket: MeshInstance3D = MeshInstance3D.new()
	var jmesh: BoxMesh = BoxMesh.new()
	jmesh.size = Vector3(1.05, 1.45, 0.55)
	jacket.mesh = jmesh
	jacket.material_override = jacket_mat
	jacket.position = Vector3(0, 1.10, 0)
	npc.add_child(jacket)
	# Brass shoulder straps (small box pads)
	for sx in [-0.45, 0.45]:
		var strap: MeshInstance3D = MeshInstance3D.new()
		var stm: BoxMesh = BoxMesh.new()
		stm.size = Vector3(0.30, 0.10, 0.55)
		strap.mesh = stm
		strap.material_override = brass_mat
		strap.position = Vector3(sx, 1.78, 0)
		npc.add_child(strap)
	# Brass front collar trim
	var collar: MeshInstance3D = MeshInstance3D.new()
	var colm: BoxMesh = BoxMesh.new()
	colm.size = Vector3(1.05, 0.10, 0.55)
	collar.mesh = colm
	collar.material_override = brass_mat
	collar.position = Vector3(0, 1.85, 0)
	npc.add_child(collar)
	# 3 brass front buttons down the chest
	for by in [1.55, 1.30, 1.05]:
		var btn: MeshInstance3D = MeshInstance3D.new()
		var bm: SphereMesh = SphereMesh.new()
		bm.radius = 0.05
		bm.height = 0.10
		btn.mesh = bm
		btn.material_override = brass_mat
		btn.position = Vector3(0, by, -0.30)
		npc.add_child(btn)
	# ---- Courier satchel slung across the chest (diagonal box) ----
	var satchel_strap: MeshInstance3D = MeshInstance3D.new()
	var sasm: BoxMesh = BoxMesh.new()
	sasm.size = Vector3(0.10, 1.30, 0.06)
	satchel_strap.mesh = sasm
	satchel_strap.material_override = leather_mat
	satchel_strap.position = Vector3(0, 1.40, -0.32)
	satchel_strap.rotation.z = 0.45
	npc.add_child(satchel_strap)
	# Satchel bag (slung at his right hip)
	var satchel: MeshInstance3D = MeshInstance3D.new()
	var sbm: BoxMesh = BoxMesh.new()
	sbm.size = Vector3(0.50, 0.45, 0.18)
	satchel.mesh = sbm
	satchel.material_override = leather_mat
	satchel.position = Vector3(0.55, 0.90, -0.05)
	npc.add_child(satchel)
	# Satchel brass clasp
	var clasp: MeshInstance3D = MeshInstance3D.new()
	var clm: BoxMesh = BoxMesh.new()
	clm.size = Vector3(0.16, 0.10, 0.06)
	clasp.mesh = clm
	clasp.material_override = brass_mat
	clasp.position = Vector3(0.55, 1.05, -0.16)
	npc.add_child(clasp)
	# ---- Brass clipboard held in left hand at chest height ----
	var clipboard: MeshInstance3D = MeshInstance3D.new()
	var clbm: BoxMesh = BoxMesh.new()
	clbm.size = Vector3(0.40, 0.55, 0.06)
	clipboard.mesh = clbm
	clipboard.material_override = brass_mat
	clipboard.position = Vector3(-0.55, 1.20, -0.30)
	clipboard.rotation.x = -0.20
	npc.add_child(clipboard)
	# Glowing notes stripe on the clipboard
	var notes: MeshInstance3D = MeshInstance3D.new()
	var nm: BoxMesh = BoxMesh.new()
	nm.size = Vector3(0.30, 0.10, 0.04)
	notes.mesh = nm
	notes.material_override = data_mat
	notes.position = Vector3(-0.55, 1.25, -0.34)
	notes.rotation.x = -0.20
	npc.add_child(notes)
	# ---- Right arm pointing at the board on a pivot ----
	var point_pivot: Node3D = Node3D.new()
	point_pivot.position = Vector3(0.55, 1.55, 0)
	npc.add_child(point_pivot)
	var right_arm: MeshInstance3D = MeshInstance3D.new()
	var ram: BoxMesh = BoxMesh.new()
	ram.size = Vector3(0.18, 0.85, 0.18)
	right_arm.mesh = ram
	right_arm.material_override = jacket_mat
	right_arm.position = Vector3(0, -0.42, 0)
	point_pivot.add_child(right_arm)
	# Pointing finger box at the end of the arm
	var finger: MeshInstance3D = MeshInstance3D.new()
	var fmm: BoxMesh = BoxMesh.new()
	fmm.size = Vector3(0.12, 0.30, 0.10)
	finger.mesh = fmm
	finger.material_override = brass_mat
	finger.position = Vector3(0, -0.95, 0)
	point_pivot.add_child(finger)
	# Glowing fingertip dot (data)
	var fingertip: MeshInstance3D = MeshInstance3D.new()
	var ftm: SphereMesh = SphereMesh.new()
	ftm.radius = 0.05
	ftm.height = 0.10
	fingertip.mesh = ftm
	fingertip.material_override = data_mat
	fingertip.position = Vector3(0, -1.10, 0)
	point_pivot.add_child(fingertip)
	# Initial pose — arm raised forward in tutorial gesture
	point_pivot.rotation.x = -1.20
	# ---- Subtle warm OmniLight ----
	var lt: OmniLight3D = OmniLight3D.new()
	lt.position = Vector3(0, 1.55, -0.30)
	lt.light_color = Color(0.65, 0.85, 1.0)
	lt.light_energy = 1.6
	lt.omni_range = 4.5
	npc.add_child(lt)
	# ---- Tap-and-trace gesture tween — finger taps then traces along the board ----
	var trace: Tween = npc.create_tween().set_loops()
	trace.tween_property(point_pivot, "rotation:x", -1.40, 0.30).set_ease(Tween.EASE_OUT)
	trace.tween_property(point_pivot, "rotation:x", -1.10, 0.30).set_ease(Tween.EASE_IN)
	trace.tween_property(point_pivot, "rotation:y", 0.30, 1.0).set_ease(Tween.EASE_IN_OUT)
	trace.tween_property(point_pivot, "rotation:y", -0.30, 1.0).set_ease(Tween.EASE_IN_OUT)
	trace.tween_property(point_pivot, "rotation:y", 0.0, 0.5).set_ease(Tween.EASE_IN_OUT)
	# Notes + fingertip pulse
	var dpulse: Tween = npc.create_tween().set_loops()
	dpulse.tween_property(data_mat, "emission_energy_multiplier", 9.0, 1.6).set_ease(Tween.EASE_IN_OUT)
	dpulse.tween_property(data_mat, "emission_energy_multiplier", 5.0, 1.6).set_ease(Tween.EASE_IN_OUT)


func _build_th_banker_npc(town: Node) -> void:
	## Epic-10 T21: Banker Numera — meticulous accountant NPC standing
	## beside the stash chest on the SW radial path. Black-and-brass
	## formal vest with gold pinstripes, brass coin pouch on his belt,
	## leather tally book held in left hand, right hand making a
	## counting tap-tap gesture toward the chest.
	var slots: Node3D = town.get_node_or_null("NPCSlots") as Node3D
	if slots == null:
		return
	var slot: Marker3D = Marker3D.new()
	slot.name = "THBankerNumeraSlot"
	# Stand beside the stash chest on the SW radial path
	var ang: float = 5.0 * PI / 4.0
	slot.position = TOWN_CENTER + Vector3(cos(ang) * 7.6, 0, sin(ang) * 7.6)
	slots.add_child(slot)
	var npc_scene: PackedScene = load("res://scenes/entities/npcs/VillagerR3.tscn") as PackedScene
	if npc_scene == null:
		return
	var npc: Node3D = npc_scene.instantiate() as Node3D
	npc.name = "THBankerNumera"
	if "npc_name" in npc:
		npc.set("npc_name", "Banker Numera")
	if "npc_id" in npc:
		npc.set("npc_id", "th_banker_numera")
	# Face the chest (toward beacon center)
	npc.rotation.y = -ang + PI / 2.0
	slot.add_child(npc)
	# Materials
	var vest_mat: StandardMaterial3D = StandardMaterial3D.new()
	vest_mat.albedo_color = Color(0.10, 0.08, 0.10)
	vest_mat.roughness = 0.55
	vest_mat.metallic = 0.30
	vest_mat.emission_enabled = true
	vest_mat.emission = Color(0.30, 0.30, 0.40)
	vest_mat.emission_energy_multiplier = 0.18
	var brass_mat: StandardMaterial3D = StandardMaterial3D.new()
	brass_mat.albedo_color = Color(0.85, 0.55, 0.18)
	brass_mat.metallic = 0.95
	brass_mat.roughness = 0.30
	brass_mat.emission_enabled = true
	brass_mat.emission = Color(1.0, 0.50, 0.10)
	brass_mat.emission_energy_multiplier = 0.55
	var data_mat: StandardMaterial3D = StandardMaterial3D.new()
	data_mat.albedo_color = Color(0.45, 0.85, 1.0)
	data_mat.emission_enabled = true
	data_mat.emission = Color(0.45, 0.85, 1.0)
	data_mat.emission_energy_multiplier = 6.0
	data_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var leather_mat: StandardMaterial3D = StandardMaterial3D.new()
	leather_mat.albedo_color = Color(0.32, 0.20, 0.12)
	leather_mat.roughness = 0.85
	leather_mat.metallic = 0.10
	# ---- Black formal vest ----
	var vest: MeshInstance3D = MeshInstance3D.new()
	var vmesh: BoxMesh = BoxMesh.new()
	vmesh.size = Vector3(1.05, 1.40, 0.55)
	vest.mesh = vmesh
	vest.material_override = vest_mat
	vest.position = Vector3(0, 1.10, 0)
	npc.add_child(vest)
	# 3 brass pinstripes down the chest
	for sx in [-0.30, 0.0, 0.30]:
		var stripe: MeshInstance3D = MeshInstance3D.new()
		var stm: BoxMesh = BoxMesh.new()
		stm.size = Vector3(0.04, 1.30, 0.04)
		stripe.mesh = stm
		stripe.material_override = brass_mat
		stripe.position = Vector3(sx, 1.10, -0.30)
		npc.add_child(stripe)
	# Brass formal collar trim
	var collar: MeshInstance3D = MeshInstance3D.new()
	var colm: BoxMesh = BoxMesh.new()
	colm.size = Vector3(1.05, 0.10, 0.55)
	collar.mesh = colm
	collar.material_override = brass_mat
	collar.position = Vector3(0, 1.80, 0)
	npc.add_child(collar)
	# Glowing data tie pin (small unshaded cyan dot at the throat)
	var pin: MeshInstance3D = MeshInstance3D.new()
	var pm: SphereMesh = SphereMesh.new()
	pm.radius = 0.06
	pm.height = 0.12
	pin.mesh = pm
	pin.material_override = data_mat
	pin.position = Vector3(0, 1.70, -0.32)
	npc.add_child(pin)
	# ---- Leather belt at waist ----
	var belt: MeshInstance3D = MeshInstance3D.new()
	var btm: BoxMesh = BoxMesh.new()
	btm.size = Vector3(1.10, 0.18, 0.60)
	belt.mesh = btm
	belt.material_override = leather_mat
	belt.position = Vector3(0, 0.55, 0)
	npc.add_child(belt)
	# Brass belt buckle
	var buckle: MeshInstance3D = MeshInstance3D.new()
	var bkm: BoxMesh = BoxMesh.new()
	bkm.size = Vector3(0.20, 0.18, 0.06)
	buckle.mesh = bkm
	buckle.material_override = brass_mat
	buckle.position = Vector3(0, 0.55, -0.32)
	npc.add_child(buckle)
	# ---- Brass coin pouch on the right hip ----
	var pouch: MeshInstance3D = MeshInstance3D.new()
	var poum: SphereMesh = SphereMesh.new()
	poum.radius = 0.18
	poum.height = 0.32
	pouch.mesh = poum
	pouch.material_override = brass_mat
	pouch.position = Vector3(0.45, 0.45, -0.05)
	pouch.scale = Vector3(0.95, 1.10, 0.85)
	npc.add_child(pouch)
	# Pouch top tie (small box)
	var tie: MeshInstance3D = MeshInstance3D.new()
	var tmm: BoxMesh = BoxMesh.new()
	tmm.size = Vector3(0.10, 0.08, 0.10)
	tie.mesh = tmm
	tie.material_override = leather_mat
	tie.position = Vector3(0.45, 0.62, -0.05)
	npc.add_child(tie)
	# 2 small glowing coin tip dots peeking out the top of the pouch
	for ix in [-0.04, 0.05]:
		var coin: MeshInstance3D = MeshInstance3D.new()
		var cmm: SphereMesh = SphereMesh.new()
		cmm.radius = 0.04
		cmm.height = 0.08
		coin.mesh = cmm
		coin.material_override = data_mat
		coin.position = Vector3(0.45 + ix, 0.65, -0.06)
		npc.add_child(coin)
	# ---- Leather tally book held in left hand ----
	var book: MeshInstance3D = MeshInstance3D.new()
	var bmm: BoxMesh = BoxMesh.new()
	bmm.size = Vector3(0.40, 0.55, 0.10)
	book.mesh = bmm
	book.material_override = leather_mat
	book.position = Vector3(-0.55, 1.20, -0.30)
	book.rotation.x = -0.20
	npc.add_child(book)
	# Glowing data ledger stripe on the open page
	var ledger: MeshInstance3D = MeshInstance3D.new()
	var lm: BoxMesh = BoxMesh.new()
	lm.size = Vector3(0.32, 0.10, 0.04)
	ledger.mesh = lm
	ledger.material_override = data_mat
	ledger.position = Vector3(-0.55, 1.25, -0.34)
	ledger.rotation.x = -0.20
	npc.add_child(ledger)
	# Brass book corner caps (4 small box accents)
	for cx in [-0.74, -0.36]:
		for cy in [1.42, 0.98]:
			var corner: MeshInstance3D = MeshInstance3D.new()
			var ccm: BoxMesh = BoxMesh.new()
			ccm.size = Vector3(0.06, 0.06, 0.06)
			corner.mesh = ccm
			corner.material_override = brass_mat
			corner.position = Vector3(cx, cy, -0.32)
			npc.add_child(corner)
	# ---- Right arm + counting hand on a pivot ----
	var count_pivot: Node3D = Node3D.new()
	count_pivot.position = Vector3(0.55, 1.50, 0)
	npc.add_child(count_pivot)
	var right_arm: MeshInstance3D = MeshInstance3D.new()
	var ram: BoxMesh = BoxMesh.new()
	ram.size = Vector3(0.18, 0.85, 0.18)
	right_arm.mesh = ram
	right_arm.material_override = vest_mat
	right_arm.position = Vector3(0, -0.42, 0)
	count_pivot.add_child(right_arm)
	# Right hand (small brass box at the end of the arm)
	var right_hand: MeshInstance3D = MeshInstance3D.new()
	var rhm: BoxMesh = BoxMesh.new()
	rhm.size = Vector3(0.18, 0.16, 0.20)
	right_hand.mesh = rhm
	right_hand.material_override = brass_mat
	right_hand.position = Vector3(0, -0.92, 0)
	count_pivot.add_child(right_hand)
	# Initial pose — arm raised forward in counting position
	count_pivot.rotation.x = -1.10
	# ---- Subtle warm OmniLight ----
	var lt: OmniLight3D = OmniLight3D.new()
	lt.position = Vector3(0, 1.55, -0.30)
	lt.light_color = Color(0.65, 0.85, 1.0)
	lt.light_energy = 1.6
	lt.omni_range = 4.5
	npc.add_child(lt)
	# ---- Counting tap-tap gesture tween — short jab forward + recover, repeat ----
	var count: Tween = npc.create_tween().set_loops()
	count.tween_property(count_pivot, "rotation:x", -1.40, 0.30).set_ease(Tween.EASE_OUT)
	count.tween_property(count_pivot, "rotation:x", -1.10, 0.30).set_ease(Tween.EASE_IN)
	count.tween_property(count_pivot, "rotation:x", -1.40, 0.30).set_ease(Tween.EASE_OUT)
	count.tween_property(count_pivot, "rotation:x", -1.10, 0.30).set_ease(Tween.EASE_IN)
	count.tween_property(count_pivot, "rotation:x", -1.10, 0.80)
	# Pin + ledger + coin pulse
	var dpulse2: Tween = npc.create_tween().set_loops()
	dpulse2.tween_property(data_mat, "emission_energy_multiplier", 8.5, 1.6).set_ease(Tween.EASE_IN_OUT)
	dpulse2.tween_property(data_mat, "emission_energy_multiplier", 4.5, 1.6).set_ease(Tween.EASE_IN_OUT)


func _build_th_fountain_wisher_npc(town: Node) -> void:
	## Epic-10 T22: Wishing Wanderer Solace — casual visitor NPC standing
	## beside the data fountain on the E radial path. Plain green tunic
	## with brass belt + small data coin held between thumb and forefinger
	## of the right hand, raised toward the fountain in a "tossing a wish
	## coin" pose. Slow toss tween + glowing coin pulse.
	var slots: Node3D = town.get_node_or_null("NPCSlots") as Node3D
	if slots == null:
		return
	var slot: Marker3D = Marker3D.new()
	slot.name = "THWishingWandererSolaceSlot"
	# Stand beside the data fountain on the E radial path
	slot.position = TOWN_CENTER + Vector3(7.6, 0, 0)
	slots.add_child(slot)
	var npc_scene: PackedScene = load("res://scenes/entities/npcs/VillagerR3.tscn") as PackedScene
	if npc_scene == null:
		return
	var npc: Node3D = npc_scene.instantiate() as Node3D
	npc.name = "THWishingWandererSolace"
	if "npc_name" in npc:
		npc.set("npc_name", "Wishing Wanderer Solace")
	if "npc_id" in npc:
		npc.set("npc_id", "th_wishing_wanderer_solace")
	# Face the fountain (-X direction)
	npc.rotation.y = -PI / 2.0
	slot.add_child(npc)
	# Materials
	var tunic_mat: StandardMaterial3D = StandardMaterial3D.new()
	tunic_mat.albedo_color = Color(0.18, 0.45, 0.22)
	tunic_mat.roughness = 0.85
	tunic_mat.metallic = 0.10
	tunic_mat.emission_enabled = true
	tunic_mat.emission = Color(0.30, 0.65, 0.30)
	tunic_mat.emission_energy_multiplier = 0.20
	var brass_mat: StandardMaterial3D = StandardMaterial3D.new()
	brass_mat.albedo_color = Color(0.85, 0.55, 0.18)
	brass_mat.metallic = 0.95
	brass_mat.roughness = 0.30
	brass_mat.emission_enabled = true
	brass_mat.emission = Color(1.0, 0.50, 0.10)
	brass_mat.emission_energy_multiplier = 0.55
	var data_mat: StandardMaterial3D = StandardMaterial3D.new()
	data_mat.albedo_color = Color(0.45, 0.85, 1.0)
	data_mat.emission_enabled = true
	data_mat.emission = Color(0.45, 0.85, 1.0)
	data_mat.emission_energy_multiplier = 7.5
	data_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var leather_mat: StandardMaterial3D = StandardMaterial3D.new()
	leather_mat.albedo_color = Color(0.32, 0.20, 0.12)
	leather_mat.roughness = 0.85
	leather_mat.metallic = 0.10
	# ---- Plain green tunic ----
	var tunic: MeshInstance3D = MeshInstance3D.new()
	var tmesh: BoxMesh = BoxMesh.new()
	tmesh.size = Vector3(1.00, 1.30, 0.55)
	tunic.mesh = tmesh
	tunic.material_override = tunic_mat
	tunic.position = Vector3(0, 1.05, 0)
	npc.add_child(tunic)
	# Brass collar trim
	var collar: MeshInstance3D = MeshInstance3D.new()
	var colm: BoxMesh = BoxMesh.new()
	colm.size = Vector3(1.00, 0.10, 0.55)
	collar.mesh = colm
	collar.material_override = brass_mat
	collar.position = Vector3(0, 1.65, 0)
	npc.add_child(collar)
	# ---- Leather waist belt + brass buckle ----
	var belt: MeshInstance3D = MeshInstance3D.new()
	var btm: BoxMesh = BoxMesh.new()
	btm.size = Vector3(1.05, 0.16, 0.60)
	belt.mesh = btm
	belt.material_override = leather_mat
	belt.position = Vector3(0, 0.55, 0)
	npc.add_child(belt)
	var buckle: MeshInstance3D = MeshInstance3D.new()
	var bkm: BoxMesh = BoxMesh.new()
	bkm.size = Vector3(0.18, 0.16, 0.06)
	buckle.mesh = bkm
	buckle.material_override = brass_mat
	buckle.position = Vector3(0, 0.55, -0.32)
	npc.add_child(buckle)
	# ---- Small drawstring pouch on the left hip (where wish coins come from) ----
	var pouch: MeshInstance3D = MeshInstance3D.new()
	var poum: SphereMesh = SphereMesh.new()
	poum.radius = 0.14
	poum.height = 0.26
	pouch.mesh = poum
	pouch.material_override = leather_mat
	pouch.position = Vector3(-0.42, 0.42, 0)
	pouch.scale = Vector3(0.95, 1.10, 0.85)
	npc.add_child(pouch)
	# ---- Left arm at his side ----
	var left_arm: MeshInstance3D = MeshInstance3D.new()
	var lam: BoxMesh = BoxMesh.new()
	lam.size = Vector3(0.18, 0.85, 0.18)
	left_arm.mesh = lam
	left_arm.material_override = tunic_mat
	left_arm.position = Vector3(-0.55, 1.00, 0)
	npc.add_child(left_arm)
	# ---- Right arm + wish coin on a pivot ----
	var toss_pivot: Node3D = Node3D.new()
	toss_pivot.position = Vector3(0.55, 1.50, 0)
	npc.add_child(toss_pivot)
	var right_arm: MeshInstance3D = MeshInstance3D.new()
	var ram: BoxMesh = BoxMesh.new()
	ram.size = Vector3(0.18, 0.85, 0.18)
	right_arm.mesh = ram
	right_arm.material_override = tunic_mat
	right_arm.position = Vector3(0, -0.42, 0)
	toss_pivot.add_child(right_arm)
	# Right hand box
	var right_hand: MeshInstance3D = MeshInstance3D.new()
	var rhm: BoxMesh = BoxMesh.new()
	rhm.size = Vector3(0.16, 0.16, 0.20)
	right_hand.mesh = rhm
	right_hand.material_override = brass_mat
	right_hand.position = Vector3(0, -0.92, 0)
	toss_pivot.add_child(right_hand)
	# Glowing wish coin (small unshaded cyan disc) held between fingers
	var coin: MeshInstance3D = MeshInstance3D.new()
	var cmm: CylinderMesh = CylinderMesh.new()
	cmm.top_radius = 0.07
	cmm.bottom_radius = 0.07
	cmm.height = 0.04
	coin.mesh = cmm
	coin.material_override = data_mat
	coin.position = Vector3(0, -1.05, 0)
	coin.rotation.x = PI / 2.0
	toss_pivot.add_child(coin)
	# Initial pose — arm raised forward toward the fountain
	toss_pivot.rotation.x = -1.30
	# ---- Subtle warm cyan OmniLight ----
	var lt: OmniLight3D = OmniLight3D.new()
	lt.position = Vector3(0, 1.50, -0.30)
	lt.light_color = Color(0.65, 0.85, 1.0)
	lt.light_energy = 1.6
	lt.omni_range = 4.5
	npc.add_child(lt)
	# ---- Toss-and-recover gesture tween ----
	var toss: Tween = npc.create_tween().set_loops()
	toss.tween_property(toss_pivot, "rotation:x", -1.80, 0.45).set_ease(Tween.EASE_OUT)
	toss.tween_property(toss_pivot, "rotation:x", -0.90, 0.30).set_ease(Tween.EASE_IN)
	toss.tween_property(toss_pivot, "rotation:x", -1.30, 0.50).set_ease(Tween.EASE_IN_OUT)
	toss.tween_property(toss_pivot, "rotation:x", -1.30, 1.00)
	# Coin pulse
	var dpulse3: Tween = npc.create_tween().set_loops()
	dpulse3.tween_property(data_mat, "emission_energy_multiplier", 9.5, 1.4).set_ease(Tween.EASE_IN_OUT)
	dpulse3.tween_property(data_mat, "emission_energy_multiplier", 5.5, 1.4).set_ease(Tween.EASE_IN_OUT)


func _build_th_planter_ring(geom: Node) -> void:
	## Epic-10 T23: 8 small basalt planters with glowing data plants
	## arranged at the plaza perimeter at radius 12.5 (between the inner
	## benches and the outer lampposts). Each planter: stepped basalt pot
	## with brass rim, dark soil disc, central tall data crystal stem,
	## 4 glowing leaf prisms radiating out, and a slow leaf shimmer pulse.
	var pivot: Node3D = Node3D.new()
	pivot.name = "TH_PlanterRing"
	pivot.position = TOWN_CENTER + Vector3(0, 0, 0)
	geom.add_child(pivot)
	# Materials
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.20, 0.22, 0.26)
	stone_mat.metallic = 0.18
	stone_mat.roughness = 0.85
	stone_mat.emission_enabled = true
	stone_mat.emission = Color(0.30, 0.45, 0.60)
	stone_mat.emission_energy_multiplier = 0.18
	var brass_mat: StandardMaterial3D = StandardMaterial3D.new()
	brass_mat.albedo_color = Color(0.85, 0.55, 0.18)
	brass_mat.metallic = 0.95
	brass_mat.roughness = 0.30
	brass_mat.emission_enabled = true
	brass_mat.emission = Color(1.0, 0.50, 0.10)
	brass_mat.emission_energy_multiplier = 0.55
	var soil_mat: StandardMaterial3D = StandardMaterial3D.new()
	soil_mat.albedo_color = Color(0.18, 0.13, 0.10)
	soil_mat.roughness = 0.90
	soil_mat.metallic = 0.05
	var stem_mat: StandardMaterial3D = StandardMaterial3D.new()
	stem_mat.albedo_color = Color(0.45, 0.85, 1.0)
	stem_mat.emission_enabled = true
	stem_mat.emission = Color(0.45, 0.85, 1.0)
	stem_mat.emission_energy_multiplier = 6.5
	stem_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var leaf_mat: StandardMaterial3D = StandardMaterial3D.new()
	leaf_mat.albedo_color = Color(0.55, 1.0, 0.65)
	leaf_mat.emission_enabled = true
	leaf_mat.emission = Color(0.55, 1.0, 0.65)
	leaf_mat.emission_energy_multiplier = 5.5
	leaf_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	# Place 8 planters between the radial paths at radius 12.5
	for i in 8:
		var ang: float = (float(i) + 0.5) / 8.0 * TAU
		var dx: float = cos(ang)
		var dz: float = sin(ang)
		var pp: Vector3 = Vector3(dx * 12.50, 0, dz * 12.50)
		var pgroup: Node3D = Node3D.new()
		pgroup.name = "Planter_" + str(i)
		pgroup.position = pp
		pivot.add_child(pgroup)
		# ---- Stepped basalt pot (cylinder with tapered bottom) ----
		var pot: MeshInstance3D = MeshInstance3D.new()
		var pmm: CylinderMesh = CylinderMesh.new()
		pmm.top_radius = 0.55
		pmm.bottom_radius = 0.45
		pmm.height = 0.65
		pot.mesh = pmm
		pot.material_override = stone_mat
		pot.position = Vector3(0, 0.32, 0)
		pgroup.add_child(pot)
		# Pot collision
		var pot_sb: StaticBody3D = StaticBody3D.new()
		pot_sb.position = Vector3(0, 0.32, 0)
		var pot_cs: CollisionShape3D = CollisionShape3D.new()
		var pot_cyl: CylinderShape3D = CylinderShape3D.new()
		pot_cyl.top_radius = 0.55
		pot_cyl.bottom_radius = 0.50
		pot_cyl.height = 0.65
		pot_cs.shape = pot_cyl
		pot_sb.add_child(pot_cs)
		pgroup.add_child(pot_sb)
		# Brass rim torus
		var rim: MeshInstance3D = MeshInstance3D.new()
		var rmm: TorusMesh = TorusMesh.new()
		rmm.inner_radius = 0.50
		rmm.outer_radius = 0.60
		rim.mesh = rmm
		rim.material_override = brass_mat
		rim.position = Vector3(0, 0.66, 0)
		pgroup.add_child(rim)
		# ---- Dark soil disc ----
		var soil: MeshInstance3D = MeshInstance3D.new()
		var sm: CylinderMesh = CylinderMesh.new()
		sm.top_radius = 0.50
		sm.bottom_radius = 0.50
		sm.height = 0.06
		soil.mesh = sm
		soil.material_override = soil_mat
		soil.position = Vector3(0, 0.65, 0)
		pgroup.add_child(soil)
		# ---- Central tall data crystal stem ----
		var stem: MeshInstance3D = MeshInstance3D.new()
		var stmm: CylinderMesh = CylinderMesh.new()
		stmm.top_radius = 0.05
		stmm.bottom_radius = 0.08
		stmm.height = 1.10
		stem.mesh = stmm
		stem.material_override = stem_mat
		stem.position = Vector3(0, 1.20, 0)
		pgroup.add_child(stem)
		# ---- 4 glowing leaf prisms radiating out from the top of the stem ----
		for j in 4:
			var leaf_ang: float = float(j) / 4.0 * TAU
			var leaf: MeshInstance3D = MeshInstance3D.new()
			var lmesh: PrismMesh = PrismMesh.new()
			lmesh.size = Vector3(0.32, 0.12, 0.18)
			leaf.mesh = lmesh
			leaf.material_override = leaf_mat
			# Position leaf at the top of the stem, pointing outward
			leaf.position = Vector3(cos(leaf_ang) * 0.22, 1.65, sin(leaf_ang) * 0.22)
			leaf.rotation.y = leaf_ang
			leaf.rotation.z = -PI / 2.0
			pgroup.add_child(leaf)
		# ---- Top crown bud (small unshaded sphere) ----
		var bud: MeshInstance3D = MeshInstance3D.new()
		var bmm: SphereMesh = SphereMesh.new()
		bmm.radius = 0.10
		bmm.height = 0.20
		bud.mesh = bmm
		bud.material_override = stem_mat
		bud.position = Vector3(0, 1.85, 0)
		pgroup.add_child(bud)
		# Subtle planter glow OmniLight (small, varied per planter)
		var lt: OmniLight3D = OmniLight3D.new()
		lt.position = Vector3(0, 1.55, 0)
		lt.light_color = Color(0.55, 0.95, 1.0)
		lt.light_energy = 0.85
		lt.omni_range = 3.5
		pgroup.add_child(lt)
	# Shared stem + leaf shimmer pulses
	var spulse: Tween = pivot.create_tween().set_loops()
	spulse.tween_property(stem_mat, "emission_energy_multiplier", 8.5, 2.0).set_ease(Tween.EASE_IN_OUT)
	spulse.tween_property(stem_mat, "emission_energy_multiplier", 5.0, 2.0).set_ease(Tween.EASE_IN_OUT)
	var lpulse: Tween = pivot.create_tween().set_loops()
	lpulse.tween_property(leaf_mat, "emission_energy_multiplier", 7.0, 2.4).set_ease(Tween.EASE_IN_OUT)
	lpulse.tween_property(leaf_mat, "emission_energy_multiplier", 4.0, 2.4).set_ease(Tween.EASE_IN_OUT)


func _build_th_welcome_arch(geom: Node) -> void:
	## Epic-10 T24: grand welcome arch over the E radial entry path (where
	## players arrive from D1 East Plaza). 2 tall basalt pillars flanking
	## the path at the outer edge, brass crossbar arch overhead, central
	## hanging brass nameplate with "TOWN HEART" letters, 2 corner finial
	## torches with flames, and 4 hanging chains with bell pendants.
	var pivot: Node3D = Node3D.new()
	pivot.name = "TH_WelcomeArch"
	# E radial path, just outside the outer plaza rim
	pivot.position = TOWN_CENTER + Vector3(15.50, 0, 0)
	# Rotate so the arch spans perpendicular to the radial direction
	pivot.rotation.y = PI / 2.0
	geom.add_child(pivot)
	# Materials
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.20, 0.22, 0.26)
	stone_mat.metallic = 0.18
	stone_mat.roughness = 0.85
	stone_mat.emission_enabled = true
	stone_mat.emission = Color(0.30, 0.45, 0.60)
	stone_mat.emission_energy_multiplier = 0.18
	var brass_mat: StandardMaterial3D = StandardMaterial3D.new()
	brass_mat.albedo_color = Color(0.85, 0.55, 0.18)
	brass_mat.metallic = 0.95
	brass_mat.roughness = 0.30
	brass_mat.emission_enabled = true
	brass_mat.emission = Color(1.0, 0.50, 0.10)
	brass_mat.emission_energy_multiplier = 0.55
	var data_mat: StandardMaterial3D = StandardMaterial3D.new()
	data_mat.albedo_color = Color(0.45, 0.85, 1.0)
	data_mat.emission_enabled = true
	data_mat.emission = Color(0.45, 0.85, 1.0)
	data_mat.emission_energy_multiplier = 7.0
	data_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var flame_mat: StandardMaterial3D = StandardMaterial3D.new()
	flame_mat.albedo_color = Color(1.0, 0.65, 0.20)
	flame_mat.emission_enabled = true
	flame_mat.emission = Color(1.0, 0.55, 0.10)
	flame_mat.emission_energy_multiplier = 9.0
	flame_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var iron_mat: StandardMaterial3D = StandardMaterial3D.new()
	iron_mat.albedo_color = Color(0.18, 0.16, 0.18)
	iron_mat.metallic = 0.85
	iron_mat.roughness = 0.45
	# ---- 2 tall basalt pillars at +/- offset along the arch axis ----
	for px in [-5.5, 5.5]:
		var pgroup: Node3D = Node3D.new()
		pgroup.name = "ArchPillar_" + str(int(px))
		pgroup.position = Vector3(px, 0, 0)
		pivot.add_child(pgroup)
		# Stepped base
		var base1: MeshInstance3D = MeshInstance3D.new()
		var b1m: BoxMesh = BoxMesh.new()
		b1m.size = Vector3(1.85, 0.50, 1.85)
		base1.mesh = b1m
		base1.material_override = stone_mat
		base1.position = Vector3(0, 0.25, 0)
		pgroup.add_child(base1)
		var base2: MeshInstance3D = MeshInstance3D.new()
		var b2m: BoxMesh = BoxMesh.new()
		b2m.size = Vector3(1.55, 0.40, 1.55)
		base2.mesh = b2m
		base2.material_override = stone_mat
		base2.position = Vector3(0, 0.70, 0)
		pgroup.add_child(base2)
		# Tall pillar shaft
		var shaft: MeshInstance3D = MeshInstance3D.new()
		var sm: BoxMesh = BoxMesh.new()
		sm.size = Vector3(1.20, 7.50, 1.20)
		shaft.mesh = sm
		shaft.material_override = stone_mat
		shaft.position = Vector3(0, 4.65, 0)
		pgroup.add_child(shaft)
		# Combined collision
		var sb: StaticBody3D = StaticBody3D.new()
		sb.position = Vector3(0, 4.50, 0)
		var cs: CollisionShape3D = CollisionShape3D.new()
		var bsh: BoxShape3D = BoxShape3D.new()
		bsh.size = Vector3(1.85, 9.00, 1.85)
		cs.shape = bsh
		sb.add_child(cs)
		pgroup.add_child(sb)
		# Brass mid band
		var band: MeshInstance3D = MeshInstance3D.new()
		var bdm: BoxMesh = BoxMesh.new()
		bdm.size = Vector3(1.30, 0.20, 1.30)
		band.mesh = bdm
		band.material_override = brass_mat
		band.position = Vector3(0, 5.00, 0)
		pgroup.add_child(band)
		# Brass top cap
		var cap: MeshInstance3D = MeshInstance3D.new()
		var capm: BoxMesh = BoxMesh.new()
		capm.size = Vector3(1.50, 0.30, 1.50)
		cap.mesh = capm
		cap.material_override = brass_mat
		cap.position = Vector3(0, 8.55, 0)
		pgroup.add_child(cap)
		# ---- Corner finial torch on top of each pillar ----
		# Brazier bowl
		var bowl: MeshInstance3D = MeshInstance3D.new()
		var bowm: SphereMesh = SphereMesh.new()
		bowm.radius = 0.40
		bowm.height = 0.65
		bowl.mesh = bowm
		bowl.material_override = brass_mat
		bowl.position = Vector3(0, 9.05, 0)
		bowl.scale = Vector3(1.0, 0.55, 1.0)
		pgroup.add_child(bowl)
		# Flame
		var flame: MeshInstance3D = MeshInstance3D.new()
		var flm: SphereMesh = SphereMesh.new()
		flm.radius = 0.32
		flm.height = 0.65
		flame.mesh = flm
		flame.material_override = flame_mat
		flame.position = Vector3(0, 9.40, 0)
		pgroup.add_child(flame)
		# OmniLight
		var lt: OmniLight3D = OmniLight3D.new()
		lt.position = Vector3(0, 9.40, 0)
		lt.light_color = Color(1.0, 0.55, 0.15)
		lt.light_energy = 4.5
		lt.omni_range = 14.0
		pgroup.add_child(lt)
		# Ember mote shower
		var motes: GPUParticles3D = GPUParticles3D.new()
		motes.position = Vector3(0, 9.65, 0)
		motes.amount = 22
		motes.lifetime = 2.4
		var pmat: ParticleProcessMaterial = ParticleProcessMaterial.new()
		pmat.direction = Vector3(0, 1, 0)
		pmat.spread = 18.0
		pmat.initial_velocity_min = 0.6
		pmat.initial_velocity_max = 1.2
		pmat.gravity = Vector3(0, 0.4, 0)
		pmat.scale_min = 0.06
		pmat.scale_max = 0.12
		pmat.color = Color(1.0, 0.55, 0.10, 1.0)
		motes.process_material = pmat
		var psmesh: SphereMesh = SphereMesh.new()
		psmesh.radius = 0.05
		psmesh.height = 0.10
		motes.draw_pass_1 = psmesh
		pgroup.add_child(motes)
	# ---- Brass crossbar arch overhead ----
	var crossbar: MeshInstance3D = MeshInstance3D.new()
	var cbm: BoxMesh = BoxMesh.new()
	cbm.size = Vector3(12.50, 0.55, 1.20)
	crossbar.mesh = cbm
	crossbar.material_override = brass_mat
	crossbar.position = Vector3(0, 8.85, 0)
	pivot.add_child(crossbar)
	# Crossbar bottom trim lip
	var trim: MeshInstance3D = MeshInstance3D.new()
	var trm: BoxMesh = BoxMesh.new()
	trm.size = Vector3(12.20, 0.18, 1.30)
	trim.mesh = trm
	trim.material_override = brass_mat
	trim.position = Vector3(0, 8.50, 0)
	pivot.add_child(trim)
	# ---- Central hanging brass nameplate ----
	# Brass plate body
	var plate: MeshInstance3D = MeshInstance3D.new()
	var plm: BoxMesh = BoxMesh.new()
	plm.size = Vector3(5.50, 1.40, 0.18)
	plate.mesh = plm
	plate.material_override = brass_mat
	plate.position = Vector3(0, 7.00, 0)
	pivot.add_child(plate)
	# 10 glowing letter blocks across the plate ("TOWN HEART" pattern)
	for i in 10:
		var lx: float = -2.20 + float(i) * 0.49
		var letter: MeshInstance3D = MeshInstance3D.new()
		var lm: BoxMesh = BoxMesh.new()
		lm.size = Vector3(0.30, 0.65, 0.06)
		letter.mesh = lm
		letter.material_override = data_mat
		letter.position = Vector3(lx, 7.00, -0.13)
		pivot.add_child(letter)
	# 2 brass support chains from the crossbar to the plate (4 chains total: 2 per side)
	for cx in [-2.30, 2.30]:
		var chain: MeshInstance3D = MeshInstance3D.new()
		var chmm: CylinderMesh = CylinderMesh.new()
		chmm.top_radius = 0.05
		chmm.bottom_radius = 0.05
		chmm.height = 1.40
		chain.mesh = chmm
		chain.material_override = iron_mat
		chain.position = Vector3(cx, 7.95, 0)
		pivot.add_child(chain)
	# ---- 4 hanging bell pendants from the crossbar (decorative) ----
	for bx in [-4.50, -1.50, 1.50, 4.50]:
		# Pendant chain
		var pendant_chain: MeshInstance3D = MeshInstance3D.new()
		var pcm: CylinderMesh = CylinderMesh.new()
		pcm.top_radius = 0.03
		pcm.bottom_radius = 0.03
		pcm.height = 0.65
		pendant_chain.mesh = pcm
		pendant_chain.material_override = iron_mat
		pendant_chain.position = Vector3(bx, 8.20, 0)
		pivot.add_child(pendant_chain)
		# Brass bell
		var bell: MeshInstance3D = MeshInstance3D.new()
		var blm: SphereMesh = SphereMesh.new()
		blm.radius = 0.16
		blm.height = 0.30
		bell.mesh = blm
		bell.material_override = brass_mat
		bell.position = Vector3(bx, 7.75, 0)
		bell.scale = Vector3(0.95, 1.10, 0.95)
		pivot.add_child(bell)
	# ---- Pulses ----
	# Letters cyan pulse
	var lpulse2: Tween = pivot.create_tween().set_loops()
	lpulse2.tween_property(data_mat, "emission_energy_multiplier", 9.0, 1.8).set_ease(Tween.EASE_IN_OUT)
	lpulse2.tween_property(data_mat, "emission_energy_multiplier", 5.5, 1.8).set_ease(Tween.EASE_IN_OUT)
	# Torch flame flicker
	var fpulse: Tween = pivot.create_tween().set_loops()
	fpulse.tween_property(flame_mat, "emission_energy_multiplier", 11.0, 0.5).set_ease(Tween.EASE_IN_OUT)
	fpulse.tween_property(flame_mat, "emission_energy_multiplier", 7.5, 0.5).set_ease(Tween.EASE_IN_OUT)


func _build_th_district_tribute_statues(geom: Node) -> void:
	## Epic-10 T25: 9 small district tribute statues arranged in a ring
	## just outside the central beacon rune circle, each honoring a
	## district master in their accent color. Each statue: small basalt
	## plinth, robed humanoid figure (body box + head sphere), brass
	## accent base trim, and a glowing district crest sphere held in the
	## figure's hands.
	var pivot: Node3D = Node3D.new()
	pivot.name = "TH_DistrictTributeStatues"
	pivot.position = TOWN_CENTER + Vector3(0, 0, 0)
	geom.add_child(pivot)
	# Materials
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.20, 0.22, 0.26)
	stone_mat.metallic = 0.18
	stone_mat.roughness = 0.85
	stone_mat.emission_enabled = true
	stone_mat.emission = Color(0.30, 0.45, 0.60)
	stone_mat.emission_energy_multiplier = 0.18
	var brass_mat: StandardMaterial3D = StandardMaterial3D.new()
	brass_mat.albedo_color = Color(0.85, 0.55, 0.18)
	brass_mat.metallic = 0.95
	brass_mat.roughness = 0.30
	brass_mat.emission_enabled = true
	brass_mat.emission = Color(1.0, 0.50, 0.10)
	brass_mat.emission_energy_multiplier = 0.55
	# 9 district accent colors (D1..D9)
	var district_colors: Array = [
		Color(0.40, 0.85, 1.0),    # D1 data cyan
		Color(0.55, 1.0, 0.40),    # D2 toxic green
		Color(0.75, 0.45, 1.0),    # D3 violet
		Color(0.40, 0.95, 0.55),   # D4 bloom green
		Color(0.65, 0.85, 1.0),    # D5 ice blue
		Color(1.0, 0.40, 0.85),    # D6 neon magenta
		Color(1.0, 0.75, 0.40),    # D7 sandstone amber
		Color(0.30, 0.55, 1.0),    # D8 ocean blue
		Color(1.0, 0.45, 0.10),    # D9 forge amber
	]
	# Place 9 statues in a ring at radius 7.0, starting at +X
	for i in 9:
		var ang: float = float(i) / 9.0 * TAU
		var dx: float = cos(ang)
		var dz: float = sin(ang)
		var sp: Vector3 = Vector3(dx * 7.00, 0, dz * 7.00)
		var sgroup: Node3D = Node3D.new()
		sgroup.name = "Tribute_D" + str(i + 1)
		sgroup.position = sp
		# Face inward toward the beacon center
		sgroup.rotation.y = atan2(-dz, -dx) - PI / 2.0
		pivot.add_child(sgroup)
		# Per-statue accent material
		var accent_mat: StandardMaterial3D = StandardMaterial3D.new()
		accent_mat.albedo_color = district_colors[i]
		accent_mat.emission_enabled = true
		accent_mat.emission = district_colors[i]
		accent_mat.emission_energy_multiplier = 6.5
		accent_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		# ---- Small basalt plinth ----
		var plinth: MeshInstance3D = MeshInstance3D.new()
		var pmm: BoxMesh = BoxMesh.new()
		pmm.size = Vector3(0.85, 0.55, 0.85)
		plinth.mesh = pmm
		plinth.material_override = stone_mat
		plinth.position = Vector3(0, 0.27, 0)
		sgroup.add_child(plinth)
		# Plinth collision
		var plinth_sb: StaticBody3D = StaticBody3D.new()
		plinth_sb.position = Vector3(0, 0.27, 0)
		var plinth_cs: CollisionShape3D = CollisionShape3D.new()
		var plinth_bsh: BoxShape3D = BoxShape3D.new()
		plinth_bsh.size = Vector3(0.85, 0.55, 0.85)
		plinth_cs.shape = plinth_bsh
		plinth_sb.add_child(plinth_cs)
		sgroup.add_child(plinth_sb)
		# Brass accent base trim
		var trim: MeshInstance3D = MeshInstance3D.new()
		var trm: BoxMesh = BoxMesh.new()
		trm.size = Vector3(0.95, 0.10, 0.95)
		trim.mesh = trm
		trim.material_override = brass_mat
		trim.position = Vector3(0, 0.55, 0)
		sgroup.add_child(trim)
		# ---- Robed figure body (tapered box) ----
		var body: MeshInstance3D = MeshInstance3D.new()
		var bmm: BoxMesh = BoxMesh.new()
		bmm.size = Vector3(0.55, 1.20, 0.40)
		body.mesh = bmm
		body.material_override = stone_mat
		body.position = Vector3(0, 1.20, 0)
		sgroup.add_child(body)
		# Body collision
		var body_sb: StaticBody3D = StaticBody3D.new()
		body_sb.position = Vector3(0, 1.20, 0)
		var body_cs: CollisionShape3D = CollisionShape3D.new()
		var body_bsh: BoxShape3D = BoxShape3D.new()
		body_bsh.size = Vector3(0.55, 1.20, 0.40)
		body_cs.shape = body_bsh
		body_sb.add_child(body_cs)
		sgroup.add_child(body_sb)
		# Head sphere
		var head: MeshInstance3D = MeshInstance3D.new()
		var hmm: SphereMesh = SphereMesh.new()
		hmm.radius = 0.20
		hmm.height = 0.40
		head.mesh = hmm
		head.material_override = stone_mat
		head.position = Vector3(0, 2.00, 0)
		sgroup.add_child(head)
		# Brass crown band on head
		var crown: MeshInstance3D = MeshInstance3D.new()
		var crmm: TorusMesh = TorusMesh.new()
		crmm.inner_radius = 0.18
		crmm.outer_radius = 0.22
		crown.mesh = crmm
		crown.material_override = brass_mat
		crown.position = Vector3(0, 2.05, 0)
		crown.rotation.x = PI / 2.0
		sgroup.add_child(crown)
		# ---- Glowing district crest sphere held in cupped hands at chest ----
		var crest: MeshInstance3D = MeshInstance3D.new()
		var crmesh: SphereMesh = SphereMesh.new()
		crmesh.radius = 0.16
		crmesh.height = 0.32
		crest.mesh = crmesh
		crest.material_override = accent_mat
		crest.position = Vector3(0, 1.30, -0.30)
		sgroup.add_child(crest)
		# Per-statue accent OmniLight
		var lt: OmniLight3D = OmniLight3D.new()
		lt.position = Vector3(0, 1.30, -0.40)
		lt.light_color = district_colors[i]
		lt.light_energy = 1.4
		lt.omni_range = 4.0
		sgroup.add_child(lt)
		# Per-statue accent pulse with offset period (shimmer effect across the ring)
		var period: float = 1.8 + float(i) * 0.13
		var apulse: Tween = sgroup.create_tween().set_loops()
		apulse.tween_property(accent_mat, "emission_energy_multiplier", 8.5, period).set_ease(Tween.EASE_IN_OUT)
		apulse.tween_property(accent_mat, "emission_energy_multiplier", 4.5, period).set_ease(Tween.EASE_IN_OUT)


func _build_th_bell_tower(geom: Node) -> void:
	## Epic-10 T26: tall basalt bell tower at the NE outer corner of the
	## plaza, visible from far across the town. Stepped basalt base + 14m
	## tower shaft with 4 brass band wraps + 4 narrow window slits, brass
	## crown roof, hanging brass bell with iron clapper, top finial spire,
	## and 4 corner brazier braziers near the bell housing.
	var pivot: Node3D = Node3D.new()
	pivot.name = "TH_BellTower"
	# NE outer corner, just past the lamppost ring at radius ~16.5
	var ang: float = PI / 4.0
	pivot.position = TOWN_CENTER + Vector3(cos(ang) * 16.50, 0, sin(ang) * 16.50)
	geom.add_child(pivot)
	# Materials
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.20, 0.22, 0.26)
	stone_mat.metallic = 0.18
	stone_mat.roughness = 0.85
	stone_mat.emission_enabled = true
	stone_mat.emission = Color(0.30, 0.45, 0.60)
	stone_mat.emission_energy_multiplier = 0.18
	var brass_mat: StandardMaterial3D = StandardMaterial3D.new()
	brass_mat.albedo_color = Color(0.85, 0.55, 0.18)
	brass_mat.metallic = 0.95
	brass_mat.roughness = 0.30
	brass_mat.emission_enabled = true
	brass_mat.emission = Color(1.0, 0.50, 0.10)
	brass_mat.emission_energy_multiplier = 0.55
	var iron_mat: StandardMaterial3D = StandardMaterial3D.new()
	iron_mat.albedo_color = Color(0.18, 0.16, 0.18)
	iron_mat.metallic = 0.85
	iron_mat.roughness = 0.45
	var window_mat: StandardMaterial3D = StandardMaterial3D.new()
	window_mat.albedo_color = Color(0.45, 0.85, 1.0)
	window_mat.emission_enabled = true
	window_mat.emission = Color(0.45, 0.85, 1.0)
	window_mat.emission_energy_multiplier = 6.5
	window_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var flame_mat: StandardMaterial3D = StandardMaterial3D.new()
	flame_mat.albedo_color = Color(1.0, 0.65, 0.20)
	flame_mat.emission_enabled = true
	flame_mat.emission = Color(1.0, 0.55, 0.10)
	flame_mat.emission_energy_multiplier = 8.5
	flame_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	# ---- Stepped basalt base (3 levels) ----
	var base1: MeshInstance3D = MeshInstance3D.new()
	var b1m: BoxMesh = BoxMesh.new()
	b1m.size = Vector3(3.50, 0.55, 3.50)
	base1.mesh = b1m
	base1.material_override = stone_mat
	base1.position = Vector3(0, 0.27, 0)
	pivot.add_child(base1)
	var base2: MeshInstance3D = MeshInstance3D.new()
	var b2m: BoxMesh = BoxMesh.new()
	b2m.size = Vector3(3.00, 0.45, 3.00)
	base2.mesh = b2m
	base2.material_override = stone_mat
	base2.position = Vector3(0, 0.77, 0)
	pivot.add_child(base2)
	var base3: MeshInstance3D = MeshInstance3D.new()
	var b3m: BoxMesh = BoxMesh.new()
	b3m.size = Vector3(2.55, 0.40, 2.55)
	base3.mesh = b3m
	base3.material_override = stone_mat
	base3.position = Vector3(0, 1.20, 0)
	pivot.add_child(base3)
	# Combined base collision
	var base_sb: StaticBody3D = StaticBody3D.new()
	base_sb.position = Vector3(0, 0.70, 0)
	var base_cs: CollisionShape3D = CollisionShape3D.new()
	var base_bsh: BoxShape3D = BoxShape3D.new()
	base_bsh.size = Vector3(3.50, 1.40, 3.50)
	base_cs.shape = base_bsh
	base_sb.add_child(base_cs)
	pivot.add_child(base_sb)
	# ---- 14m tower shaft ----
	var shaft: MeshInstance3D = MeshInstance3D.new()
	var sm: BoxMesh = BoxMesh.new()
	sm.size = Vector3(2.00, 14.00, 2.00)
	shaft.mesh = sm
	shaft.material_override = stone_mat
	shaft.position = Vector3(0, 8.40, 0)
	pivot.add_child(shaft)
	# Shaft collision
	var shaft_sb: StaticBody3D = StaticBody3D.new()
	shaft_sb.position = Vector3(0, 8.40, 0)
	var shaft_cs: CollisionShape3D = CollisionShape3D.new()
	var shaft_bsh: BoxShape3D = BoxShape3D.new()
	shaft_bsh.size = Vector3(2.00, 14.00, 2.00)
	shaft_cs.shape = shaft_bsh
	shaft_sb.add_child(shaft_cs)
	pivot.add_child(shaft_sb)
	# 4 brass band wraps
	for by in [3.50, 6.50, 9.50, 12.50]:
		var band: MeshInstance3D = MeshInstance3D.new()
		var bdm: BoxMesh = BoxMesh.new()
		bdm.size = Vector3(2.20, 0.20, 2.20)
		band.mesh = bdm
		band.material_override = brass_mat
		band.position = Vector3(0, by, 0)
		pivot.add_child(band)
	# 4 narrow glowing window slits down the front face (one between each band)
	for wy in [4.80, 7.80, 10.80, 13.80]:
		var window: MeshInstance3D = MeshInstance3D.new()
		var wmm: BoxMesh = BoxMesh.new()
		wmm.size = Vector3(0.30, 0.85, 0.06)
		window.mesh = wmm
		window.material_override = window_mat
		window.position = Vector3(0, wy, -1.04)
		pivot.add_child(window)
	# ---- Bell housing platform at the top of the shaft ----
	var housing: MeshInstance3D = MeshInstance3D.new()
	var hmm: BoxMesh = BoxMesh.new()
	hmm.size = Vector3(2.85, 0.45, 2.85)
	housing.mesh = hmm
	housing.material_override = stone_mat
	housing.position = Vector3(0, 15.65, 0)
	pivot.add_child(housing)
	# Brass top trim on housing
	var housing_trim: MeshInstance3D = MeshInstance3D.new()
	var htm: BoxMesh = BoxMesh.new()
	htm.size = Vector3(3.00, 0.18, 3.00)
	housing_trim.mesh = htm
	housing_trim.material_override = brass_mat
	housing_trim.position = Vector3(0, 15.95, 0)
	pivot.add_child(housing_trim)
	# 4 brass corner posts holding the roof
	for cpx in [-1.20, 1.20]:
		for cpz in [-1.20, 1.20]:
			var post: MeshInstance3D = MeshInstance3D.new()
			var pmm: CylinderMesh = CylinderMesh.new()
			pmm.top_radius = 0.10
			pmm.bottom_radius = 0.12
			pmm.height = 1.85
			post.mesh = pmm
			post.material_override = brass_mat
			post.position = Vector3(cpx, 16.95, cpz)
			pivot.add_child(post)
	# ---- Brass crown roof (pyramid prism) ----
	var roof: MeshInstance3D = MeshInstance3D.new()
	var rmm: PrismMesh = PrismMesh.new()
	rmm.size = Vector3(3.00, 1.50, 3.00)
	roof.mesh = rmm
	roof.material_override = brass_mat
	roof.position = Vector3(0, 18.65, 0)
	pivot.add_child(roof)
	# Top finial spire
	var finial: MeshInstance3D = MeshInstance3D.new()
	var fmm: PrismMesh = PrismMesh.new()
	fmm.size = Vector3(0.40, 0.85, 0.40)
	finial.mesh = fmm
	finial.material_override = brass_mat
	finial.position = Vector3(0, 19.85, 0)
	pivot.add_child(finial)
	# Finial top dot (small unshaded cyan sphere)
	var finial_dot: MeshInstance3D = MeshInstance3D.new()
	var fdm: SphereMesh = SphereMesh.new()
	fdm.radius = 0.12
	fdm.height = 0.24
	finial_dot.mesh = fdm
	finial_dot.material_override = window_mat
	finial_dot.position = Vector3(0, 20.40, 0)
	pivot.add_child(finial_dot)
	# ---- Hanging brass bell ----
	# Bell yoke beam (small box across the housing top)
	var yoke: MeshInstance3D = MeshInstance3D.new()
	var ym: BoxMesh = BoxMesh.new()
	ym.size = Vector3(2.20, 0.18, 0.30)
	yoke.mesh = ym
	yoke.material_override = brass_mat
	yoke.position = Vector3(0, 18.05, 0)
	pivot.add_child(yoke)
	# Bell pivot for swing animation
	var bell_pivot: Node3D = Node3D.new()
	bell_pivot.position = Vector3(0, 18.05, 0)
	pivot.add_child(bell_pivot)
	# Bell body (sphere stretched into bell shape)
	var bell: MeshInstance3D = MeshInstance3D.new()
	var blm: SphereMesh = SphereMesh.new()
	blm.radius = 0.65
	blm.height = 1.20
	bell.mesh = blm
	bell.material_override = brass_mat
	bell.position = Vector3(0, -0.85, 0)
	bell.scale = Vector3(1.0, 0.95, 1.0)
	bell_pivot.add_child(bell)
	# Bell skirt rim torus
	var skirt: MeshInstance3D = MeshInstance3D.new()
	var skm: TorusMesh = TorusMesh.new()
	skm.inner_radius = 0.55
	skm.outer_radius = 0.70
	skirt.mesh = skm
	skirt.material_override = brass_mat
	skirt.position = Vector3(0, -1.35, 0)
	bell_pivot.add_child(skirt)
	# Iron clapper (small sphere hanging inside the bell)
	var clapper: MeshInstance3D = MeshInstance3D.new()
	var clm: SphereMesh = SphereMesh.new()
	clm.radius = 0.14
	clm.height = 0.28
	clapper.mesh = clm
	clapper.material_override = iron_mat
	clapper.position = Vector3(0, -1.10, 0)
	bell_pivot.add_child(clapper)
	# ---- 4 corner braziers near the bell housing (one per corner post) ----
	for cpx in [-1.20, 1.20]:
		for cpz in [-1.20, 1.20]:
			var bowl: MeshInstance3D = MeshInstance3D.new()
			var bowm: SphereMesh = SphereMesh.new()
			bowm.radius = 0.22
			bowm.height = 0.40
			bowl.mesh = bowm
			bowl.material_override = brass_mat
			bowl.position = Vector3(cpx, 17.95, cpz)
			bowl.scale = Vector3(1.0, 0.55, 1.0)
			pivot.add_child(bowl)
			# Flame
			var flame: MeshInstance3D = MeshInstance3D.new()
			var flm: SphereMesh = SphereMesh.new()
			flm.radius = 0.18
			flm.height = 0.36
			flame.mesh = flm
			flame.material_override = flame_mat
			flame.position = Vector3(cpx, 18.15, cpz)
			pivot.add_child(flame)
			# Corner OmniLight
			var lt: OmniLight3D = OmniLight3D.new()
			lt.position = Vector3(cpx, 18.15, cpz)
			lt.light_color = Color(1.0, 0.55, 0.15)
			lt.light_energy = 3.0
			lt.omni_range = 9.5
			pivot.add_child(lt)
	# ---- Strong central bell housing OmniLight ----
	var bell_lt: OmniLight3D = OmniLight3D.new()
	bell_lt.position = Vector3(0, 17.50, 0)
	bell_lt.light_color = Color(1.0, 0.65, 0.20)
	bell_lt.light_energy = 4.0
	bell_lt.omni_range = 16.0
	pivot.add_child(bell_lt)
	# ---- Pulses + bell sway tween ----
	# Bell slow gentle sway
	var sway: Tween = pivot.create_tween().set_loops()
	sway.tween_property(bell_pivot, "rotation:z", 0.18, 2.0).set_ease(Tween.EASE_IN_OUT)
	sway.tween_property(bell_pivot, "rotation:z", -0.18, 2.0).set_ease(Tween.EASE_IN_OUT)
	# Window pulse
	var wpulse: Tween = pivot.create_tween().set_loops()
	wpulse.tween_property(window_mat, "emission_energy_multiplier", 8.5, 1.8).set_ease(Tween.EASE_IN_OUT)
	wpulse.tween_property(window_mat, "emission_energy_multiplier", 5.0, 1.8).set_ease(Tween.EASE_IN_OUT)
	# Brazier flame flicker
	var fpulse: Tween = pivot.create_tween().set_loops()
	fpulse.tween_property(flame_mat, "emission_energy_multiplier", 10.5, 0.5).set_ease(Tween.EASE_IN_OUT)
	fpulse.tween_property(flame_mat, "emission_energy_multiplier", 7.5, 0.5).set_ease(Tween.EASE_IN_OUT)


func _build_th_archive_tower(geom: Node) -> void:
	## Epic-10 T27: tall archive tower at the NW outer corner of the
	## plaza, complementing the bell tower visually. Stepped basalt base,
	## 14m hexagon-style shaft (2.4m wide) with 6 brass band wraps + 6
	## glowing window slits, brass dome roof with finial, 6 floating
	## holographic data scroll discs spinning around the dome, and 4
	## corner data lanterns at the top.
	var pivot: Node3D = Node3D.new()
	pivot.name = "TH_ArchiveTower"
	# NW outer corner at radius ~16.5
	var ang: float = 3.0 * PI / 4.0
	pivot.position = TOWN_CENTER + Vector3(cos(ang) * 16.50, 0, sin(ang) * 16.50)
	geom.add_child(pivot)
	# Materials
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.20, 0.22, 0.26)
	stone_mat.metallic = 0.18
	stone_mat.roughness = 0.85
	stone_mat.emission_enabled = true
	stone_mat.emission = Color(0.30, 0.45, 0.60)
	stone_mat.emission_energy_multiplier = 0.18
	var brass_mat: StandardMaterial3D = StandardMaterial3D.new()
	brass_mat.albedo_color = Color(0.85, 0.55, 0.18)
	brass_mat.metallic = 0.95
	brass_mat.roughness = 0.30
	brass_mat.emission_enabled = true
	brass_mat.emission = Color(1.0, 0.50, 0.10)
	brass_mat.emission_energy_multiplier = 0.55
	var data_mat: StandardMaterial3D = StandardMaterial3D.new()
	data_mat.albedo_color = Color(0.45, 0.85, 1.0)
	data_mat.emission_enabled = true
	data_mat.emission = Color(0.45, 0.85, 1.0)
	data_mat.emission_energy_multiplier = 6.5
	data_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	# ---- Stepped basalt base (3 levels) ----
	var base1: MeshInstance3D = MeshInstance3D.new()
	var b1m: BoxMesh = BoxMesh.new()
	b1m.size = Vector3(3.50, 0.55, 3.50)
	base1.mesh = b1m
	base1.material_override = stone_mat
	base1.position = Vector3(0, 0.27, 0)
	pivot.add_child(base1)
	var base2: MeshInstance3D = MeshInstance3D.new()
	var b2m: BoxMesh = BoxMesh.new()
	b2m.size = Vector3(3.00, 0.45, 3.00)
	base2.mesh = b2m
	base2.material_override = stone_mat
	base2.position = Vector3(0, 0.77, 0)
	pivot.add_child(base2)
	var base3: MeshInstance3D = MeshInstance3D.new()
	var b3m: BoxMesh = BoxMesh.new()
	b3m.size = Vector3(2.55, 0.40, 2.55)
	base3.mesh = b3m
	base3.material_override = stone_mat
	base3.position = Vector3(0, 1.20, 0)
	pivot.add_child(base3)
	# Combined base collision
	var base_sb: StaticBody3D = StaticBody3D.new()
	base_sb.position = Vector3(0, 0.70, 0)
	var base_cs: CollisionShape3D = CollisionShape3D.new()
	var base_bsh: BoxShape3D = BoxShape3D.new()
	base_bsh.size = Vector3(3.50, 1.40, 3.50)
	base_cs.shape = base_bsh
	base_sb.add_child(base_cs)
	pivot.add_child(base_sb)
	# ---- 14m hexagon-style cylinder shaft ----
	var shaft: MeshInstance3D = MeshInstance3D.new()
	var sm: CylinderMesh = CylinderMesh.new()
	sm.top_radius = 1.20
	sm.bottom_radius = 1.20
	sm.height = 14.00
	shaft.mesh = sm
	shaft.material_override = stone_mat
	shaft.position = Vector3(0, 8.40, 0)
	pivot.add_child(shaft)
	# Shaft collision
	var shaft_sb: StaticBody3D = StaticBody3D.new()
	shaft_sb.position = Vector3(0, 8.40, 0)
	var shaft_cs: CollisionShape3D = CollisionShape3D.new()
	var shaft_cyl: CylinderShape3D = CylinderShape3D.new()
	shaft_cyl.top_radius = 1.20
	shaft_cyl.bottom_radius = 1.20
	shaft_cyl.height = 14.00
	shaft_cs.shape = shaft_cyl
	shaft_sb.add_child(shaft_cs)
	pivot.add_child(shaft_sb)
	# ---- 6 brass band wraps (torus rings) ----
	for by in [3.00, 5.40, 7.80, 10.20, 12.60, 14.80]:
		var band: MeshInstance3D = MeshInstance3D.new()
		var bdm: TorusMesh = TorusMesh.new()
		bdm.inner_radius = 1.18
		bdm.outer_radius = 1.32
		band.mesh = bdm
		band.material_override = brass_mat
		band.position = Vector3(0, by, 0)
		pivot.add_child(band)
	# ---- 6 glowing window slits arranged around the shaft (one per side) ----
	for i in 6:
		var w_ang: float = float(i) / 6.0 * TAU
		var dx: float = cos(w_ang)
		var dz: float = sin(w_ang)
		var window: MeshInstance3D = MeshInstance3D.new()
		var wmm: BoxMesh = BoxMesh.new()
		wmm.size = Vector3(0.30, 1.10, 0.05)
		window.mesh = wmm
		window.material_override = data_mat
		window.position = Vector3(dx * 1.22, 9.00, dz * 1.22)
		window.rotation.y = w_ang + PI / 2.0
		pivot.add_child(window)
	# ---- Brass dome roof (sphere top half) ----
	var dome: MeshInstance3D = MeshInstance3D.new()
	var dmm: SphereMesh = SphereMesh.new()
	dmm.radius = 1.55
	dmm.height = 3.10
	dome.mesh = dmm
	dome.material_override = brass_mat
	dome.position = Vector3(0, 16.20, 0)
	dome.scale = Vector3(1.0, 0.55, 1.0)
	pivot.add_child(dome)
	# Dome top finial — small prism + cyan dot
	var finial: MeshInstance3D = MeshInstance3D.new()
	var fmm: PrismMesh = PrismMesh.new()
	fmm.size = Vector3(0.35, 0.85, 0.35)
	finial.mesh = fmm
	finial.material_override = brass_mat
	finial.position = Vector3(0, 17.55, 0)
	pivot.add_child(finial)
	var finial_dot: MeshInstance3D = MeshInstance3D.new()
	var fdm: SphereMesh = SphereMesh.new()
	fdm.radius = 0.14
	fdm.height = 0.28
	finial_dot.mesh = fdm
	finial_dot.material_override = data_mat
	finial_dot.position = Vector3(0, 18.10, 0)
	pivot.add_child(finial_dot)
	# ---- 6 floating holographic data scroll discs spinning around the dome ----
	# All children of a spin pivot so the whole ring rotates
	var scroll_pivot: Node3D = Node3D.new()
	scroll_pivot.position = Vector3(0, 16.30, 0)
	pivot.add_child(scroll_pivot)
	for i in 6:
		var s_ang: float = float(i) / 6.0 * TAU
		var dx: float = cos(s_ang)
		var dz: float = sin(s_ang)
		# Disc body — small flat cylinder
		var disc: MeshInstance3D = MeshInstance3D.new()
		var dscm: CylinderMesh = CylinderMesh.new()
		dscm.top_radius = 0.32
		dscm.bottom_radius = 0.32
		dscm.height = 0.08
		disc.mesh = dscm
		disc.material_override = data_mat
		disc.position = Vector3(dx * 2.20, 0, dz * 2.20)
		# Stand the disc on edge facing outward (rotate so its face points along the radial)
		disc.rotation.x = PI / 2.0
		disc.rotation.y = s_ang
		scroll_pivot.add_child(disc)
		# Brass disc rim torus
		var rim: MeshInstance3D = MeshInstance3D.new()
		var rmm: TorusMesh = TorusMesh.new()
		rmm.inner_radius = 0.30
		rmm.outer_radius = 0.36
		rim.mesh = rmm
		rim.material_override = brass_mat
		rim.position = Vector3(dx * 2.22, 0, dz * 2.22)
		rim.rotation.y = s_ang + PI / 2.0
		scroll_pivot.add_child(rim)
	# ---- 4 corner data lanterns at the top of the shaft ----
	for cpx in [-1.00, 1.00]:
		for cpz in [-1.00, 1.00]:
			# Lantern bracket
			var bracket: MeshInstance3D = MeshInstance3D.new()
			var bktm: BoxMesh = BoxMesh.new()
			bktm.size = Vector3(0.18, 0.65, 0.18)
			bracket.mesh = bktm
			bracket.material_override = brass_mat
			bracket.position = Vector3(cpx, 14.95, cpz)
			pivot.add_child(bracket)
			# Lantern bulb (unshaded cyan sphere)
			var bulb: MeshInstance3D = MeshInstance3D.new()
			var blm: SphereMesh = SphereMesh.new()
			blm.radius = 0.18
			blm.height = 0.36
			bulb.mesh = blm
			bulb.material_override = data_mat
			bulb.position = Vector3(cpx, 15.30, cpz)
			pivot.add_child(bulb)
			# Lantern OmniLight
			var lt: OmniLight3D = OmniLight3D.new()
			lt.position = Vector3(cpx, 15.30, cpz)
			lt.light_color = Color(0.45, 0.85, 1.0)
			lt.light_energy = 2.6
			lt.omni_range = 8.5
			pivot.add_child(lt)
	# ---- Strong central dome OmniLight ----
	var dome_lt: OmniLight3D = OmniLight3D.new()
	dome_lt.position = Vector3(0, 16.50, 0)
	dome_lt.light_color = Color(0.55, 0.90, 1.0)
	dome_lt.light_energy = 4.0
	dome_lt.omni_range = 16.0
	pivot.add_child(dome_lt)
	# ---- Pulses + scroll spin tween ----
	# Slow scroll ring spin (the 6 scroll discs orbit the dome)
	var spin: Tween = pivot.create_tween().set_loops()
	spin.tween_property(scroll_pivot, "rotation:y", TAU, 12.0)
	# Window + scroll + lantern data pulse (shared material)
	var dpulse: Tween = pivot.create_tween().set_loops()
	dpulse.tween_property(data_mat, "emission_energy_multiplier", 8.5, 1.8).set_ease(Tween.EASE_IN_OUT)
	dpulse.tween_property(data_mat, "emission_energy_multiplier", 5.0, 1.8).set_ease(Tween.EASE_IN_OUT)


func _build_th_forge_brazier_monument(geom: Node) -> void:
	## Epic-10 T28: large standing brazier monument at the SW outer
	## corner of the plaza, honoring the forge guild visually. Stepped
	## basalt pedestal with brass anvil-and-hammer totem on the front,
	## tall brass brazier bowl on a tapered stem, perpetual flame with
	## strong OmniLight + ember mote shower, and 4 small ground torches
	## around the pedestal corners.
	var pivot: Node3D = Node3D.new()
	pivot.name = "TH_ForgeBrazierMonument"
	# SW outer corner at radius ~16.5
	var ang: float = 5.0 * PI / 4.0
	pivot.position = TOWN_CENTER + Vector3(cos(ang) * 16.50, 0, sin(ang) * 16.50)
	# Face the beacon (toward town center)
	pivot.rotation.y = -ang - PI / 2.0
	geom.add_child(pivot)
	# Materials
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.20, 0.22, 0.26)
	stone_mat.metallic = 0.18
	stone_mat.roughness = 0.85
	stone_mat.emission_enabled = true
	stone_mat.emission = Color(0.45, 0.18, 0.05)
	stone_mat.emission_energy_multiplier = 0.20
	var brass_mat: StandardMaterial3D = StandardMaterial3D.new()
	brass_mat.albedo_color = Color(0.85, 0.55, 0.18)
	brass_mat.metallic = 0.95
	brass_mat.roughness = 0.30
	brass_mat.emission_enabled = true
	brass_mat.emission = Color(1.0, 0.50, 0.10)
	brass_mat.emission_energy_multiplier = 0.65
	var iron_mat: StandardMaterial3D = StandardMaterial3D.new()
	iron_mat.albedo_color = Color(0.18, 0.16, 0.18)
	iron_mat.metallic = 0.85
	iron_mat.roughness = 0.45
	var flame_mat: StandardMaterial3D = StandardMaterial3D.new()
	flame_mat.albedo_color = Color(1.0, 0.65, 0.20)
	flame_mat.emission_enabled = true
	flame_mat.emission = Color(1.0, 0.55, 0.10)
	flame_mat.emission_energy_multiplier = 9.5
	flame_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var amber_mat: StandardMaterial3D = StandardMaterial3D.new()
	amber_mat.albedo_color = Color(1.0, 0.55, 0.10)
	amber_mat.emission_enabled = true
	amber_mat.emission = Color(1.0, 0.55, 0.10)
	amber_mat.emission_energy_multiplier = 7.0
	amber_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	# ---- Stepped basalt pedestal (3 levels) ----
	var base1: MeshInstance3D = MeshInstance3D.new()
	var b1m: BoxMesh = BoxMesh.new()
	b1m.size = Vector3(3.20, 0.55, 3.20)
	base1.mesh = b1m
	base1.material_override = stone_mat
	base1.position = Vector3(0, 0.27, 0)
	pivot.add_child(base1)
	var base2: MeshInstance3D = MeshInstance3D.new()
	var b2m: BoxMesh = BoxMesh.new()
	b2m.size = Vector3(2.70, 0.45, 2.70)
	base2.mesh = b2m
	base2.material_override = stone_mat
	base2.position = Vector3(0, 0.77, 0)
	pivot.add_child(base2)
	var base3: MeshInstance3D = MeshInstance3D.new()
	var b3m: BoxMesh = BoxMesh.new()
	b3m.size = Vector3(2.20, 0.55, 2.20)
	base3.mesh = b3m
	base3.material_override = stone_mat
	base3.position = Vector3(0, 1.27, 0)
	pivot.add_child(base3)
	# Combined pedestal collision
	var ped_sb: StaticBody3D = StaticBody3D.new()
	ped_sb.position = Vector3(0, 0.77, 0)
	var ped_cs: CollisionShape3D = CollisionShape3D.new()
	var ped_bsh: BoxShape3D = BoxShape3D.new()
	ped_bsh.size = Vector3(3.20, 1.55, 3.20)
	ped_cs.shape = ped_bsh
	ped_sb.add_child(ped_cs)
	pivot.add_child(ped_sb)
	# Brass top plate
	var top_plate: MeshInstance3D = MeshInstance3D.new()
	var tpm: BoxMesh = BoxMesh.new()
	tpm.size = Vector3(2.30, 0.10, 2.30)
	top_plate.mesh = tpm
	top_plate.material_override = brass_mat
	top_plate.position = Vector3(0, 1.60, 0)
	pivot.add_child(top_plate)
	# ---- Brass anvil-and-hammer totem on the front face of the pedestal ----
	# Anvil base box
	var anvil: MeshInstance3D = MeshInstance3D.new()
	var anm: BoxMesh = BoxMesh.new()
	anm.size = Vector3(0.85, 0.30, 0.30)
	anvil.mesh = anm
	anvil.material_override = brass_mat
	anvil.position = Vector3(0, 0.95, -1.10)
	pivot.add_child(anvil)
	# Anvil horn (small box on the side)
	var horn: MeshInstance3D = MeshInstance3D.new()
	var hnm: BoxMesh = BoxMesh.new()
	hnm.size = Vector3(0.30, 0.18, 0.30)
	horn.mesh = hnm
	horn.material_override = brass_mat
	horn.position = Vector3(0.50, 1.00, -1.10)
	pivot.add_child(horn)
	# Hammer head crossing the anvil
	var hamhead: MeshInstance3D = MeshInstance3D.new()
	var hhm: BoxMesh = BoxMesh.new()
	hhm.size = Vector3(0.50, 0.22, 0.30)
	hamhead.mesh = hhm
	hamhead.material_override = brass_mat
	hamhead.position = Vector3(-0.20, 1.30, -1.10)
	hamhead.rotation.z = -PI / 8.0
	pivot.add_child(hamhead)
	# Hammer handle
	var hamhandle: MeshInstance3D = MeshInstance3D.new()
	var hhdm: CylinderMesh = CylinderMesh.new()
	hhdm.top_radius = 0.04
	hhdm.bottom_radius = 0.04
	hhdm.height = 0.85
	hamhandle.mesh = hhdm
	hamhandle.material_override = brass_mat
	hamhandle.position = Vector3(0.20, 1.65, -1.10)
	hamhandle.rotation.z = PI / 8.0
	pivot.add_child(hamhandle)
	# ---- Tapered brass stem rising from the top plate ----
	var stem: MeshInstance3D = MeshInstance3D.new()
	var stm: CylinderMesh = CylinderMesh.new()
	stm.top_radius = 0.30
	stm.bottom_radius = 0.55
	stm.height = 4.00
	stem.mesh = stm
	stem.material_override = brass_mat
	stem.position = Vector3(0, 3.65, 0)
	pivot.add_child(stem)
	# Stem brass rings (3 wraps)
	for sy in [2.50, 4.00, 5.20]:
		var ring: MeshInstance3D = MeshInstance3D.new()
		var rmm: TorusMesh = TorusMesh.new()
		rmm.inner_radius = 0.32
		rmm.outer_radius = 0.45
		ring.mesh = rmm
		ring.material_override = brass_mat
		ring.position = Vector3(0, sy, 0)
		pivot.add_child(ring)
	# ---- Tall brass brazier bowl ----
	var bowl: MeshInstance3D = MeshInstance3D.new()
	var bowm: SphereMesh = SphereMesh.new()
	bowm.radius = 1.10
	bowm.height = 1.85
	bowl.mesh = bowm
	bowl.material_override = brass_mat
	bowl.position = Vector3(0, 6.00, 0)
	bowl.scale = Vector3(1.0, 0.55, 1.0)
	pivot.add_child(bowl)
	# Bowl rim torus
	var rim: MeshInstance3D = MeshInstance3D.new()
	var rim_m: TorusMesh = TorusMesh.new()
	rim_m.inner_radius = 1.00
	rim_m.outer_radius = 1.20
	rim.mesh = rim_m
	rim.material_override = brass_mat
	rim.position = Vector3(0, 6.45, 0)
	pivot.add_child(rim)
	# ---- Perpetual flame inside the bowl ----
	var flame: MeshInstance3D = MeshInstance3D.new()
	var flm: SphereMesh = SphereMesh.new()
	flm.radius = 0.85
	flm.height = 1.65
	flame.mesh = flm
	flame.material_override = flame_mat
	flame.position = Vector3(0, 7.10, 0)
	pivot.add_child(flame)
	# Strong central flame OmniLight
	var lt: OmniLight3D = OmniLight3D.new()
	lt.position = Vector3(0, 7.20, 0)
	lt.light_color = Color(1.0, 0.55, 0.15)
	lt.light_energy = 6.0
	lt.omni_range = 18.0
	pivot.add_child(lt)
	# Ember mote shower
	var motes: GPUParticles3D = GPUParticles3D.new()
	motes.position = Vector3(0, 7.85, 0)
	motes.amount = 48
	motes.lifetime = 3.0
	var pmat: ParticleProcessMaterial = ParticleProcessMaterial.new()
	pmat.direction = Vector3(0, 1, 0)
	pmat.spread = 24.0
	pmat.initial_velocity_min = 0.8
	pmat.initial_velocity_max = 1.6
	pmat.gravity = Vector3(0, 0.4, 0)
	pmat.scale_min = 0.08
	pmat.scale_max = 0.16
	pmat.color = Color(1.0, 0.55, 0.10, 1.0)
	motes.process_material = pmat
	var psmesh: SphereMesh = SphereMesh.new()
	psmesh.radius = 0.06
	psmesh.height = 0.12
	motes.draw_pass_1 = psmesh
	pivot.add_child(motes)
	# ---- 4 small ground torches around the pedestal corners ----
	for cpx in [-1.40, 1.40]:
		for cpz in [-1.40, 1.40]:
			# Torch post (small iron cylinder)
			var post: MeshInstance3D = MeshInstance3D.new()
			var pmm: CylinderMesh = CylinderMesh.new()
			pmm.top_radius = 0.06
			pmm.bottom_radius = 0.08
			pmm.height = 1.30
			post.mesh = pmm
			post.material_override = iron_mat
			post.position = Vector3(cpx, 0.65, cpz)
			pivot.add_child(post)
			# Brass torch bowl
			var t_bowl: MeshInstance3D = MeshInstance3D.new()
			var tbm: SphereMesh = SphereMesh.new()
			tbm.radius = 0.18
			tbm.height = 0.32
			t_bowl.mesh = tbm
			t_bowl.material_override = brass_mat
			t_bowl.position = Vector3(cpx, 1.40, cpz)
			t_bowl.scale = Vector3(1.0, 0.55, 1.0)
			pivot.add_child(t_bowl)
			# Torch flame
			var t_flame: MeshInstance3D = MeshInstance3D.new()
			var tflm: SphereMesh = SphereMesh.new()
			tflm.radius = 0.16
			tflm.height = 0.32
			t_flame.mesh = tflm
			t_flame.material_override = flame_mat
			t_flame.position = Vector3(cpx, 1.55, cpz)
			pivot.add_child(t_flame)
			# Corner OmniLight
			var ct_lt: OmniLight3D = OmniLight3D.new()
			ct_lt.position = Vector3(cpx, 1.55, cpz)
			ct_lt.light_color = Color(1.0, 0.55, 0.15)
			ct_lt.light_energy = 1.8
			ct_lt.omni_range = 5.5
			pivot.add_child(ct_lt)
	# ---- Pulses ----
	# Flame flicker
	var fpulse: Tween = pivot.create_tween().set_loops()
	fpulse.tween_property(flame_mat, "emission_energy_multiplier", 11.5, 0.5).set_ease(Tween.EASE_IN_OUT)
	fpulse.tween_property(flame_mat, "emission_energy_multiplier", 8.0, 0.5).set_ease(Tween.EASE_IN_OUT)
	# Brass + amber slow pulse
	var apulse: Tween = pivot.create_tween().set_loops()
	apulse.tween_property(amber_mat, "emission_energy_multiplier", 9.0, 1.6).set_ease(Tween.EASE_IN_OUT)
	apulse.tween_property(amber_mat, "emission_energy_multiplier", 5.5, 1.6).set_ease(Tween.EASE_IN_OUT)


func _build_th_observatory_dome(geom: Node) -> void:
	## Epic-10 T29: short observatory dome at the SE outer corner of the
	## plaza, completing the 4-corner outer landmark ring. 3-step basalt
	## platform with brass top trim, half-sphere brass dome roof with
	## radial seams, central tall brass telescope on a tripod pointed
	## skyward + slow swivel tween, 6 floating cyan star points around the
	## dome rim, and 4 small corner data crystals on the platform.
	var pivot: Node3D = Node3D.new()
	pivot.name = "TH_ObservatoryDome"
	# SE outer corner at radius ~16.5
	var ang: float = 7.0 * PI / 4.0
	pivot.position = TOWN_CENTER + Vector3(cos(ang) * 16.50, 0, sin(ang) * 16.50)
	pivot.rotation.y = -ang - PI / 2.0
	geom.add_child(pivot)
	# Materials
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.20, 0.22, 0.26)
	stone_mat.metallic = 0.18
	stone_mat.roughness = 0.85
	stone_mat.emission_enabled = true
	stone_mat.emission = Color(0.30, 0.45, 0.60)
	stone_mat.emission_energy_multiplier = 0.18
	var brass_mat: StandardMaterial3D = StandardMaterial3D.new()
	brass_mat.albedo_color = Color(0.85, 0.55, 0.18)
	brass_mat.metallic = 0.95
	brass_mat.roughness = 0.30
	brass_mat.emission_enabled = true
	brass_mat.emission = Color(1.0, 0.50, 0.10)
	brass_mat.emission_energy_multiplier = 0.55
	var data_mat: StandardMaterial3D = StandardMaterial3D.new()
	data_mat.albedo_color = Color(0.45, 0.85, 1.0)
	data_mat.emission_enabled = true
	data_mat.emission = Color(0.45, 0.85, 1.0)
	data_mat.emission_energy_multiplier = 7.0
	data_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var iron_mat: StandardMaterial3D = StandardMaterial3D.new()
	iron_mat.albedo_color = Color(0.18, 0.16, 0.18)
	iron_mat.metallic = 0.85
	iron_mat.roughness = 0.45
	# ---- 3-step basalt platform ----
	var base1: MeshInstance3D = MeshInstance3D.new()
	var b1m: CylinderMesh = CylinderMesh.new()
	b1m.top_radius = 3.40
	b1m.bottom_radius = 3.50
	b1m.height = 0.45
	base1.mesh = b1m
	base1.material_override = stone_mat
	base1.position = Vector3(0, 0.22, 0)
	pivot.add_child(base1)
	var base2: MeshInstance3D = MeshInstance3D.new()
	var b2m: CylinderMesh = CylinderMesh.new()
	b2m.top_radius = 2.90
	b2m.bottom_radius = 2.95
	b2m.height = 0.40
	base2.mesh = b2m
	base2.material_override = stone_mat
	base2.position = Vector3(0, 0.65, 0)
	pivot.add_child(base2)
	var base3: MeshInstance3D = MeshInstance3D.new()
	var b3m: CylinderMesh = CylinderMesh.new()
	b3m.top_radius = 2.50
	b3m.bottom_radius = 2.55
	b3m.height = 0.35
	base3.mesh = b3m
	base3.material_override = stone_mat
	base3.position = Vector3(0, 1.02, 0)
	pivot.add_child(base3)
	# Combined platform collision (cylinder)
	var plat_sb: StaticBody3D = StaticBody3D.new()
	plat_sb.position = Vector3(0, 0.60, 0)
	var plat_cs: CollisionShape3D = CollisionShape3D.new()
	var plat_cyl: CylinderShape3D = CylinderShape3D.new()
	plat_cyl.top_radius = 2.50
	plat_cyl.bottom_radius = 3.50
	plat_cyl.height = 1.20
	plat_cs.shape = plat_cyl
	plat_sb.add_child(plat_cs)
	pivot.add_child(plat_sb)
	# Brass top trim torus
	var top_trim: MeshInstance3D = MeshInstance3D.new()
	var ttm: TorusMesh = TorusMesh.new()
	ttm.inner_radius = 2.40
	ttm.outer_radius = 2.65
	top_trim.mesh = ttm
	top_trim.material_override = brass_mat
	top_trim.position = Vector3(0, 1.22, 0)
	pivot.add_child(top_trim)
	# ---- Half-sphere brass dome roof ----
	var dome: MeshInstance3D = MeshInstance3D.new()
	var dmm: SphereMesh = SphereMesh.new()
	dmm.radius = 2.55
	dmm.height = 5.10
	dome.mesh = dmm
	dome.material_override = brass_mat
	dome.position = Vector3(0, 2.00, 0)
	dome.scale = Vector3(1.0, 0.55, 1.0)
	pivot.add_child(dome)
	# 6 radial dome seams (small box stripes from base to top)
	for i in 6:
		var sang: float = float(i) / 6.0 * TAU
		var dx: float = cos(sang)
		var dz: float = sin(sang)
		var seam: MeshInstance3D = MeshInstance3D.new()
		var sm: BoxMesh = BoxMesh.new()
		sm.size = Vector3(0.10, 1.40, 0.06)
		seam.mesh = sm
		seam.material_override = brass_mat
		seam.position = Vector3(dx * 1.30, 2.55, dz * 1.30)
		seam.rotation.y = sang
		seam.rotation.x = -PI / 6.0 + sin(sang) * 0.10
		pivot.add_child(seam)
	# Top finial sphere
	var finial: MeshInstance3D = MeshInstance3D.new()
	var fmm: SphereMesh = SphereMesh.new()
	fmm.radius = 0.18
	fmm.height = 0.36
	finial.mesh = fmm
	finial.material_override = data_mat
	finial.position = Vector3(0, 3.55, 0)
	pivot.add_child(finial)
	# ---- Tall brass telescope on a tripod (centered, pointed skyward) ----
	# Telescope pivot for swivel animation
	var scope_pivot: Node3D = Node3D.new()
	scope_pivot.position = Vector3(0, 1.30, 0)
	pivot.add_child(scope_pivot)
	# Tripod legs (3 angled iron cylinders)
	for i in 3:
		var ang_t: float = float(i) / 3.0 * TAU
		var leg: MeshInstance3D = MeshInstance3D.new()
		var lm: CylinderMesh = CylinderMesh.new()
		lm.top_radius = 0.05
		lm.bottom_radius = 0.07
		lm.height = 1.30
		leg.mesh = lm
		leg.material_override = iron_mat
		leg.position = Vector3(cos(ang_t) * 0.30, 0.55, sin(ang_t) * 0.30)
		leg.rotation = Vector3(sin(ang_t) * 0.30, 0, -cos(ang_t) * 0.30)
		scope_pivot.add_child(leg)
	# Tripod head — small brass box
	var t_head: MeshInstance3D = MeshInstance3D.new()
	var thm: BoxMesh = BoxMesh.new()
	thm.size = Vector3(0.40, 0.18, 0.40)
	t_head.mesh = thm
	t_head.material_override = brass_mat
	t_head.position = Vector3(0, 1.20, 0)
	scope_pivot.add_child(t_head)
	# Telescope tube — long brass cylinder, angled upward 60 degrees
	var tube_pivot: Node3D = Node3D.new()
	tube_pivot.position = Vector3(0, 1.30, 0)
	scope_pivot.add_child(tube_pivot)
	var tube: MeshInstance3D = MeshInstance3D.new()
	var tum: CylinderMesh = CylinderMesh.new()
	tum.top_radius = 0.18
	tum.bottom_radius = 0.22
	tum.height = 2.40
	tube.mesh = tum
	tube.material_override = brass_mat
	tube.position = Vector3(0, 1.05, 0)
	tube_pivot.add_child(tube)
	# Tube brass band wraps
	for ty in [0.35, 1.05, 1.75]:
		var band: MeshInstance3D = MeshInstance3D.new()
		var bdm: TorusMesh = TorusMesh.new()
		bdm.inner_radius = 0.18
		bdm.outer_radius = 0.26
		band.mesh = bdm
		band.material_override = brass_mat
		band.position = Vector3(0, ty, 0)
		band.rotation.x = PI / 2.0
		tube_pivot.add_child(band)
	# Tube top objective lens (glowing cyan disc)
	var lens: MeshInstance3D = MeshInstance3D.new()
	var lm: CylinderMesh = CylinderMesh.new()
	lm.top_radius = 0.18
	lm.bottom_radius = 0.18
	lm.height = 0.06
	lens.mesh = lm
	lens.material_override = data_mat
	lens.position = Vector3(0, 2.30, 0)
	tube_pivot.add_child(lens)
	# Tube bottom eyepiece (small brass cylinder)
	var eyepiece: MeshInstance3D = MeshInstance3D.new()
	var em: CylinderMesh = CylinderMesh.new()
	em.top_radius = 0.10
	em.bottom_radius = 0.10
	em.height = 0.20
	eyepiece.mesh = em
	eyepiece.material_override = brass_mat
	eyepiece.position = Vector3(0, -0.20, 0)
	tube_pivot.add_child(eyepiece)
	# Angle the tube upward 60 degrees so the telescope points to the sky
	tube_pivot.rotation.x = -PI / 3.0
	# ---- 6 floating cyan star points around the dome rim ----
	var star_pivot: Node3D = Node3D.new()
	star_pivot.position = Vector3(0, 3.30, 0)
	pivot.add_child(star_pivot)
	for i in 6:
		var sang2: float = float(i) / 6.0 * TAU
		var dx: float = cos(sang2)
		var dz: float = sin(sang2)
		var star: MeshInstance3D = MeshInstance3D.new()
		var smm: SphereMesh = SphereMesh.new()
		smm.radius = 0.10
		smm.height = 0.20
		star.mesh = smm
		star.material_override = data_mat
		star.position = Vector3(dx * 1.85, 0, dz * 1.85)
		star_pivot.add_child(star)
	# ---- 4 small corner data crystals on the platform ----
	for cpx in [-1.85, 1.85]:
		for cpz in [-1.85, 1.85]:
			var crystal: MeshInstance3D = MeshInstance3D.new()
			var crm: PrismMesh = PrismMesh.new()
			crm.size = Vector3(0.20, 0.55, 0.20)
			crystal.mesh = crm
			crystal.material_override = data_mat
			crystal.position = Vector3(cpx, 1.50, cpz)
			pivot.add_child(crystal)
	# ---- Strong cyan dome OmniLight ----
	var dome_lt: OmniLight3D = OmniLight3D.new()
	dome_lt.position = Vector3(0, 3.00, 0)
	dome_lt.light_color = Color(0.55, 0.90, 1.0)
	dome_lt.light_energy = 4.0
	dome_lt.omni_range = 14.0
	pivot.add_child(dome_lt)
	# ---- Pulses + tweens ----
	# Slow telescope swivel — entire scope_pivot rotates around Y
	var swivel: Tween = pivot.create_tween().set_loops()
	swivel.tween_property(scope_pivot, "rotation:y", 0.50, 4.0).set_ease(Tween.EASE_IN_OUT)
	swivel.tween_property(scope_pivot, "rotation:y", -0.50, 4.0).set_ease(Tween.EASE_IN_OUT)
	# Slow star ring spin around the dome
	var spin: Tween = pivot.create_tween().set_loops()
	spin.tween_property(star_pivot, "rotation:y", TAU, 10.0)
	# Shared cyan data pulse
	var dpulse2: Tween = pivot.create_tween().set_loops()
	dpulse2.tween_property(data_mat, "emission_energy_multiplier", 9.0, 1.8).set_ease(Tween.EASE_IN_OUT)
	dpulse2.tween_property(data_mat, "emission_energy_multiplier", 5.5, 1.8).set_ease(Tween.EASE_IN_OUT)


func _build_th_sky_lanterns(geom: Node) -> void:
	## Epic-10 T30: 12 drifting glowing sky lanterns floating high above
	## the plaza, forming an ambient overhead sky layer. Each lantern is
	## a small brass cage with an unshaded amber bulb inside, hanging
	## from a long thin chain anchored at sky height. Each lantern bobs
	## up-and-down on its own period.
	var pivot: Node3D = Node3D.new()
	pivot.name = "TH_SkyLanterns"
	pivot.position = TOWN_CENTER + Vector3(0, 0, 0)
	geom.add_child(pivot)
	# Materials
	var brass_mat: StandardMaterial3D = StandardMaterial3D.new()
	brass_mat.albedo_color = Color(0.85, 0.55, 0.18)
	brass_mat.metallic = 0.95
	brass_mat.roughness = 0.30
	brass_mat.emission_enabled = true
	brass_mat.emission = Color(1.0, 0.50, 0.10)
	brass_mat.emission_energy_multiplier = 0.55
	var iron_mat: StandardMaterial3D = StandardMaterial3D.new()
	iron_mat.albedo_color = Color(0.18, 0.16, 0.18)
	iron_mat.metallic = 0.85
	iron_mat.roughness = 0.45
	# Mix of warm amber and cool cyan lantern colors for variety
	var bulb_colors: Array = [
		Color(1.0, 0.65, 0.20),    # warm amber
		Color(0.45, 0.85, 1.0),    # data cyan
		Color(1.0, 0.55, 0.10),    # forge amber
		Color(0.55, 0.95, 1.0),    # ice cyan
	]
	# 12 lantern positions distributed in a wide ring at radius 11, height 12
	for i in 12:
		var ang: float = float(i) / 12.0 * TAU
		# Slight ring radius variation for organic feel
		var r: float = 9.0 + sin(float(i) * 1.7) * 2.0
		var lp: Vector3 = Vector3(cos(ang) * r, 12.0 + sin(float(i) * 0.9) * 1.5, sin(ang) * r)
		var lgroup: Node3D = Node3D.new()
		lgroup.name = "SkyLantern_" + str(i)
		lgroup.position = lp
		pivot.add_child(lgroup)
		# Per-lantern bulb material (cycled color)
		var col: Color = bulb_colors[i % bulb_colors.size()]
		var bulb_mat: StandardMaterial3D = StandardMaterial3D.new()
		bulb_mat.albedo_color = col
		bulb_mat.emission_enabled = true
		bulb_mat.emission = col
		bulb_mat.emission_energy_multiplier = 7.5
		bulb_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		# ---- Long thin iron anchor chain reaching up out of sight ----
		var chain: MeshInstance3D = MeshInstance3D.new()
		var chm: CylinderMesh = CylinderMesh.new()
		chm.top_radius = 0.025
		chm.bottom_radius = 0.025
		chm.height = 8.00
		chain.mesh = chm
		chain.material_override = iron_mat
		chain.position = Vector3(0, 4.0, 0)
		lgroup.add_child(chain)
		# ---- Brass lantern top cap ----
		var cap: MeshInstance3D = MeshInstance3D.new()
		var capm: BoxMesh = BoxMesh.new()
		capm.size = Vector3(0.36, 0.10, 0.36)
		cap.mesh = capm
		cap.material_override = brass_mat
		cap.position = Vector3(0, 0.20, 0)
		lgroup.add_child(cap)
		# ---- Brass cage (4 thin corner posts forming the lantern frame) ----
		for cpx in [-0.13, 0.13]:
			for cpz in [-0.13, 0.13]:
				var cpost: MeshInstance3D = MeshInstance3D.new()
				var cpm: CylinderMesh = CylinderMesh.new()
				cpm.top_radius = 0.018
				cpm.bottom_radius = 0.018
				cpm.height = 0.40
				cpost.mesh = cpm
				cpost.material_override = brass_mat
				cpost.position = Vector3(cpx, -0.05, cpz)
				lgroup.add_child(cpost)
		# Bottom rim torus
		var bot_rim: MeshInstance3D = MeshInstance3D.new()
		var brm: TorusMesh = TorusMesh.new()
		brm.inner_radius = 0.13
		brm.outer_radius = 0.18
		bot_rim.mesh = brm
		bot_rim.material_override = brass_mat
		bot_rim.position = Vector3(0, -0.30, 0)
		lgroup.add_child(bot_rim)
		# ---- Unshaded bulb sphere inside the cage ----
		var bulb: MeshInstance3D = MeshInstance3D.new()
		var bm: SphereMesh = SphereMesh.new()
		bm.radius = 0.16
		bm.height = 0.32
		bulb.mesh = bm
		bulb.material_override = bulb_mat
		bulb.position = Vector3(0, -0.10, 0)
		lgroup.add_child(bulb)
		# ---- Per-lantern OmniLight ----
		var lt: OmniLight3D = OmniLight3D.new()
		lt.position = Vector3(0, -0.10, 0)
		lt.light_color = col
		lt.light_energy = 1.4
		lt.omni_range = 6.0
		lgroup.add_child(lt)
		# ---- Per-lantern bob tween (Y oscillation, varied period) ----
		var bob_period: float = 2.0 + float(i) * 0.18
		var bob: Tween = lgroup.create_tween().set_loops()
		bob.tween_property(lgroup, "position:y", lp.y + 0.85, bob_period).set_ease(Tween.EASE_IN_OUT)
		bob.tween_property(lgroup, "position:y", lp.y - 0.30, bob_period).set_ease(Tween.EASE_IN_OUT)
		# ---- Per-lantern bulb pulse ----
		var bulb_period: float = 1.6 + float(i) * 0.12
		var bpulse: Tween = lgroup.create_tween().set_loops()
		bpulse.tween_property(bulb_mat, "emission_energy_multiplier", 9.5, bulb_period).set_ease(Tween.EASE_IN_OUT)
		bpulse.tween_property(bulb_mat, "emission_energy_multiplier", 5.5, bulb_period).set_ease(Tween.EASE_IN_OUT)


func _build_th_west_entry_arch(geom: Node) -> void:
	## Epic-10 T31: secondary entry arch over the W radial path, mirroring
	## the E welcome arch but smaller and warmer-toned. 2 basalt pillars
	## flanking the path with brass top caps, brass crossbar arch, central
	## hanging brass plate with 8 glowing amber letters, 2 hanging chains
	## with brass coin pendants, and 2 corner torches at pillar mid-height.
	var pivot: Node3D = Node3D.new()
	pivot.name = "TH_WestEntryArch"
	# W radial path, just outside the outer plaza rim
	pivot.position = TOWN_CENTER + Vector3(-15.50, 0, 0)
	# Rotate to match the path orientation (perpendicular to the radial)
	pivot.rotation.y = PI / 2.0
	geom.add_child(pivot)
	# Materials
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.20, 0.22, 0.26)
	stone_mat.metallic = 0.18
	stone_mat.roughness = 0.85
	stone_mat.emission_enabled = true
	stone_mat.emission = Color(0.30, 0.45, 0.60)
	stone_mat.emission_energy_multiplier = 0.18
	var brass_mat: StandardMaterial3D = StandardMaterial3D.new()
	brass_mat.albedo_color = Color(0.85, 0.55, 0.18)
	brass_mat.metallic = 0.95
	brass_mat.roughness = 0.30
	brass_mat.emission_enabled = true
	brass_mat.emission = Color(1.0, 0.50, 0.10)
	brass_mat.emission_energy_multiplier = 0.55
	var amber_mat: StandardMaterial3D = StandardMaterial3D.new()
	amber_mat.albedo_color = Color(1.0, 0.55, 0.10)
	amber_mat.emission_enabled = true
	amber_mat.emission = Color(1.0, 0.55, 0.10)
	amber_mat.emission_energy_multiplier = 6.5
	amber_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var flame_mat: StandardMaterial3D = StandardMaterial3D.new()
	flame_mat.albedo_color = Color(1.0, 0.65, 0.20)
	flame_mat.emission_enabled = true
	flame_mat.emission = Color(1.0, 0.55, 0.10)
	flame_mat.emission_energy_multiplier = 8.5
	flame_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var iron_mat: StandardMaterial3D = StandardMaterial3D.new()
	iron_mat.albedo_color = Color(0.18, 0.16, 0.18)
	iron_mat.metallic = 0.85
	iron_mat.roughness = 0.45
	# ---- 2 basalt pillars at +/- offset along the arch axis ----
	for px in [-4.50, 4.50]:
		var pgroup: Node3D = Node3D.new()
		pgroup.name = "WestArchPillar_" + str(int(px))
		pgroup.position = Vector3(px, 0, 0)
		pivot.add_child(pgroup)
		# Stepped base
		var base1: MeshInstance3D = MeshInstance3D.new()
		var b1m: BoxMesh = BoxMesh.new()
		b1m.size = Vector3(1.55, 0.45, 1.55)
		base1.mesh = b1m
		base1.material_override = stone_mat
		base1.position = Vector3(0, 0.22, 0)
		pgroup.add_child(base1)
		var base2: MeshInstance3D = MeshInstance3D.new()
		var b2m: BoxMesh = BoxMesh.new()
		b2m.size = Vector3(1.30, 0.35, 1.30)
		base2.mesh = b2m
		base2.material_override = stone_mat
		base2.position = Vector3(0, 0.62, 0)
		pgroup.add_child(base2)
		# Pillar shaft (6m, smaller than the east arch's 7.5m)
		var shaft: MeshInstance3D = MeshInstance3D.new()
		var sm: BoxMesh = BoxMesh.new()
		sm.size = Vector3(1.00, 6.00, 1.00)
		shaft.mesh = sm
		shaft.material_override = stone_mat
		shaft.position = Vector3(0, 3.80, 0)
		pgroup.add_child(shaft)
		# Combined collision
		var sb: StaticBody3D = StaticBody3D.new()
		sb.position = Vector3(0, 3.65, 0)
		var cs: CollisionShape3D = CollisionShape3D.new()
		var bsh: BoxShape3D = BoxShape3D.new()
		bsh.size = Vector3(1.55, 7.30, 1.55)
		cs.shape = bsh
		sb.add_child(cs)
		pgroup.add_child(sb)
		# Brass mid band
		var band: MeshInstance3D = MeshInstance3D.new()
		var bdm: BoxMesh = BoxMesh.new()
		bdm.size = Vector3(1.10, 0.18, 1.10)
		band.mesh = bdm
		band.material_override = brass_mat
		band.position = Vector3(0, 4.00, 0)
		pgroup.add_child(band)
		# Brass top cap
		var cap: MeshInstance3D = MeshInstance3D.new()
		var capm: BoxMesh = BoxMesh.new()
		capm.size = Vector3(1.30, 0.25, 1.30)
		cap.mesh = capm
		cap.material_override = brass_mat
		cap.position = Vector3(0, 6.95, 0)
		pgroup.add_child(cap)
		# ---- Pillar mid-height torch (bracket + flame + light) ----
		var bracket: MeshInstance3D = MeshInstance3D.new()
		var bktm: BoxMesh = BoxMesh.new()
		bktm.size = Vector3(0.18, 0.20, 0.45)
		bracket.mesh = bktm
		bracket.material_override = brass_mat
		# Inner-facing torch
		var inner_z: float = -0.62
		bracket.position = Vector3(0, 4.55, inner_z)
		pgroup.add_child(bracket)
		var flame: MeshInstance3D = MeshInstance3D.new()
		var flm: SphereMesh = SphereMesh.new()
		flm.radius = 0.18
		flm.height = 0.36
		flame.mesh = flm
		flame.material_override = flame_mat
		flame.position = Vector3(0, 4.80, inner_z - 0.25)
		pgroup.add_child(flame)
		var lt: OmniLight3D = OmniLight3D.new()
		lt.position = Vector3(0, 4.80, inner_z - 0.25)
		lt.light_color = Color(1.0, 0.55, 0.15)
		lt.light_energy = 2.6
		lt.omni_range = 7.0
		pgroup.add_child(lt)
	# ---- Brass crossbar arch overhead ----
	var crossbar: MeshInstance3D = MeshInstance3D.new()
	var cbm: BoxMesh = BoxMesh.new()
	cbm.size = Vector3(10.50, 0.40, 1.00)
	crossbar.mesh = cbm
	crossbar.material_override = brass_mat
	crossbar.position = Vector3(0, 7.10, 0)
	pivot.add_child(crossbar)
	# Crossbar bottom trim lip
	var trim: MeshInstance3D = MeshInstance3D.new()
	var trm: BoxMesh = BoxMesh.new()
	trm.size = Vector3(10.20, 0.14, 1.10)
	trim.mesh = trm
	trim.material_override = brass_mat
	trim.position = Vector3(0, 6.85, 0)
	pivot.add_child(trim)
	# ---- Central hanging brass plate with 8 glowing amber letters ----
	var plate: MeshInstance3D = MeshInstance3D.new()
	var plm: BoxMesh = BoxMesh.new()
	plm.size = Vector3(4.20, 1.10, 0.16)
	plate.mesh = plm
	plate.material_override = brass_mat
	plate.position = Vector3(0, 5.50, 0)
	pivot.add_child(plate)
	# 8 glowing amber letters across the plate
	for i in 8:
		var lx: float = -1.65 + float(i) * 0.47
		var letter: MeshInstance3D = MeshInstance3D.new()
		var lm: BoxMesh = BoxMesh.new()
		lm.size = Vector3(0.26, 0.50, 0.06)
		letter.mesh = lm
		letter.material_override = amber_mat
		letter.position = Vector3(lx, 5.50, -0.12)
		pivot.add_child(letter)
	# 2 brass support chains from the crossbar to the plate
	for cx in [-1.80, 1.80]:
		var chain: MeshInstance3D = MeshInstance3D.new()
		var chmm: CylinderMesh = CylinderMesh.new()
		chmm.top_radius = 0.04
		chmm.bottom_radius = 0.04
		chmm.height = 1.10
		chain.mesh = chmm
		chain.material_override = iron_mat
		chain.position = Vector3(cx, 6.30, 0)
		pivot.add_child(chain)
	# ---- 2 hanging coin pendants from the crossbar (decorative) ----
	for cnx in [-3.50, 3.50]:
		# Pendant chain
		var pendant_chain: MeshInstance3D = MeshInstance3D.new()
		var pcm: CylinderMesh = CylinderMesh.new()
		pcm.top_radius = 0.025
		pcm.bottom_radius = 0.025
		pcm.height = 0.55
		pendant_chain.mesh = pcm
		pendant_chain.material_override = iron_mat
		pendant_chain.position = Vector3(cnx, 6.55, 0)
		pivot.add_child(pendant_chain)
		# Brass coin disc
		var coin: MeshInstance3D = MeshInstance3D.new()
		var cnm: CylinderMesh = CylinderMesh.new()
		cnm.top_radius = 0.16
		cnm.bottom_radius = 0.16
		cnm.height = 0.05
		coin.mesh = cnm
		coin.material_override = brass_mat
		coin.position = Vector3(cnx, 6.20, 0)
		coin.rotation.x = PI / 2.0
		pivot.add_child(coin)
	# ---- Pulses ----
	# Letters amber pulse
	var lpulse2: Tween = pivot.create_tween().set_loops()
	lpulse2.tween_property(amber_mat, "emission_energy_multiplier", 8.5, 1.8).set_ease(Tween.EASE_IN_OUT)
	lpulse2.tween_property(amber_mat, "emission_energy_multiplier", 5.0, 1.8).set_ease(Tween.EASE_IN_OUT)
	# Torch flame flicker
	var fpulse: Tween = pivot.create_tween().set_loops()
	fpulse.tween_property(flame_mat, "emission_energy_multiplier", 10.5, 0.5).set_ease(Tween.EASE_IN_OUT)
	fpulse.tween_property(flame_mat, "emission_energy_multiplier", 7.0, 0.5).set_ease(Tween.EASE_IN_OUT)


func _build_th_food_cart(geom: Node) -> void:
	## Epic-10 T32: small mobile food vendor cart parked between the south
	## benches. Wood + brass cart body on 2 cylinder wheels, brass top
	## counter, hot pot with steam, 3 floating food holos above the counter
	## (a noodle bowl, a fruit, a meat skewer), small chimney pipe, and a
	## warm hood OmniLight.
	var pivot: Node3D = Node3D.new()
	pivot.name = "TH_FoodCart"
	# Park near the south radial path between the south benches
	pivot.position = TOWN_CENTER + Vector3(2.50, 0, 11.50)
	# Face inward toward the beacon
	pivot.rotation.y = PI
	geom.add_child(pivot)
	# Materials
	var wood_mat: StandardMaterial3D = StandardMaterial3D.new()
	wood_mat.albedo_color = Color(0.32, 0.20, 0.12)
	wood_mat.roughness = 0.85
	wood_mat.metallic = 0.10
	var brass_mat: StandardMaterial3D = StandardMaterial3D.new()
	brass_mat.albedo_color = Color(0.85, 0.55, 0.18)
	brass_mat.metallic = 0.95
	brass_mat.roughness = 0.30
	brass_mat.emission_enabled = true
	brass_mat.emission = Color(1.0, 0.50, 0.10)
	brass_mat.emission_energy_multiplier = 0.55
	var iron_mat: StandardMaterial3D = StandardMaterial3D.new()
	iron_mat.albedo_color = Color(0.18, 0.16, 0.18)
	iron_mat.metallic = 0.85
	iron_mat.roughness = 0.45
	var holo_mat: StandardMaterial3D = StandardMaterial3D.new()
	holo_mat.albedo_color = Color(1.0, 0.65, 0.20)
	holo_mat.emission_enabled = true
	holo_mat.emission = Color(1.0, 0.55, 0.10)
	holo_mat.emission_energy_multiplier = 6.0
	holo_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var pot_mat: StandardMaterial3D = StandardMaterial3D.new()
	pot_mat.albedo_color = Color(0.18, 0.16, 0.18)
	pot_mat.metallic = 0.85
	pot_mat.roughness = 0.45
	pot_mat.emission_enabled = true
	pot_mat.emission = Color(1.0, 0.40, 0.10)
	pot_mat.emission_energy_multiplier = 0.45
	# ---- Cart body (wood box) ----
	var body: MeshInstance3D = MeshInstance3D.new()
	var bm: BoxMesh = BoxMesh.new()
	bm.size = Vector3(1.85, 0.85, 1.05)
	body.mesh = bm
	body.material_override = wood_mat
	body.position = Vector3(0, 0.85, 0)
	pivot.add_child(body)
	# Body collision
	var body_sb: StaticBody3D = StaticBody3D.new()
	body_sb.position = Vector3(0, 0.85, 0)
	var body_cs: CollisionShape3D = CollisionShape3D.new()
	var body_bsh: BoxShape3D = BoxShape3D.new()
	body_bsh.size = Vector3(1.85, 0.85, 1.05)
	body_cs.shape = body_bsh
	body_sb.add_child(body_cs)
	pivot.add_child(body_sb)
	# Brass top counter plate
	var counter: MeshInstance3D = MeshInstance3D.new()
	var ctm: BoxMesh = BoxMesh.new()
	ctm.size = Vector3(2.00, 0.10, 1.20)
	counter.mesh = ctm
	counter.material_override = brass_mat
	counter.position = Vector3(0, 1.32, 0)
	pivot.add_child(counter)
	# Brass cart side trim bands (front + back)
	for tz in [-0.55, 0.55]:
		var trim: MeshInstance3D = MeshInstance3D.new()
		var tmm: BoxMesh = BoxMesh.new()
		tmm.size = Vector3(1.95, 0.08, 0.06)
		trim.mesh = tmm
		trim.material_override = brass_mat
		trim.position = Vector3(0, 1.20, tz)
		pivot.add_child(trim)
	# ---- 2 large cart wheels ----
	for wx in [-0.85, 0.85]:
		var wheel: MeshInstance3D = MeshInstance3D.new()
		var wm: CylinderMesh = CylinderMesh.new()
		wm.top_radius = 0.42
		wm.bottom_radius = 0.42
		wm.height = 0.12
		wheel.mesh = wm
		wheel.material_override = wood_mat
		wheel.position = Vector3(wx, 0.42, 0.62)
		wheel.rotation.x = PI / 2.0
		pivot.add_child(wheel)
		# Brass wheel hub torus
		var hub: MeshInstance3D = MeshInstance3D.new()
		var hbm: TorusMesh = TorusMesh.new()
		hbm.inner_radius = 0.10
		hbm.outer_radius = 0.16
		hub.mesh = hbm
		hub.material_override = brass_mat
		hub.position = Vector3(wx, 0.42, 0.62)
		pivot.add_child(hub)
	# ---- Hot pot on top of the counter (iron pot with brass rim) ----
	var pot: MeshInstance3D = MeshInstance3D.new()
	var pmm: CylinderMesh = CylinderMesh.new()
	pmm.top_radius = 0.32
	pmm.bottom_radius = 0.28
	pmm.height = 0.42
	pot.mesh = pmm
	pot.material_override = pot_mat
	pot.position = Vector3(-0.45, 1.58, 0)
	pivot.add_child(pot)
	# Pot brass rim torus
	var pot_rim: MeshInstance3D = MeshInstance3D.new()
	var prm: TorusMesh = TorusMesh.new()
	prm.inner_radius = 0.30
	prm.outer_radius = 0.38
	pot_rim.mesh = prm
	pot_rim.material_override = brass_mat
	pot_rim.position = Vector3(-0.45, 1.78, 0)
	pivot.add_child(pot_rim)
	# Pot lid (small dome)
	var lid: MeshInstance3D = MeshInstance3D.new()
	var lm: SphereMesh = SphereMesh.new()
	lm.radius = 0.30
	lm.height = 0.22
	lid.mesh = lm
	lid.material_override = brass_mat
	lid.position = Vector3(-0.45, 1.85, 0)
	lid.scale = Vector3(1.0, 0.55, 1.0)
	pivot.add_child(lid)
	# Lid handle (small brass knob)
	var knob: MeshInstance3D = MeshInstance3D.new()
	var knm: SphereMesh = SphereMesh.new()
	knm.radius = 0.07
	knm.height = 0.14
	knob.mesh = knm
	knob.material_override = brass_mat
	knob.position = Vector3(-0.45, 1.97, 0)
	pivot.add_child(knob)
	# ---- Steam particles rising from the pot ----
	var steam: GPUParticles3D = GPUParticles3D.new()
	steam.position = Vector3(-0.45, 2.10, 0)
	steam.amount = 22
	steam.lifetime = 3.5
	var smat: ParticleProcessMaterial = ParticleProcessMaterial.new()
	smat.direction = Vector3(0, 1, 0)
	smat.spread = 22.0
	smat.initial_velocity_min = 0.5
	smat.initial_velocity_max = 1.0
	smat.gravity = Vector3(0, 0.4, 0)
	smat.scale_min = 0.18
	smat.scale_max = 0.35
	smat.color = Color(0.85, 0.80, 0.75, 0.65)
	steam.process_material = smat
	var smkm: SphereMesh = SphereMesh.new()
	smkm.radius = 0.12
	smkm.height = 0.24
	steam.draw_pass_1 = smkm
	pivot.add_child(steam)
	# ---- 3 floating food holos above the right side of the counter ----
	var holo_pivot: Node3D = Node3D.new()
	holo_pivot.position = Vector3(0.55, 1.95, 0)
	pivot.add_child(holo_pivot)
	# Holo 1 — noodle bowl (small flat torus)
	var noodle: MeshInstance3D = MeshInstance3D.new()
	var nrm: TorusMesh = TorusMesh.new()
	nrm.inner_radius = 0.10
	nrm.outer_radius = 0.16
	noodle.mesh = nrm
	noodle.material_override = holo_mat
	noodle.position = Vector3(-0.30, 0, 0)
	noodle.rotation.x = PI / 2.0
	holo_pivot.add_child(noodle)
	# Holo 2 — fruit (small sphere)
	var fruit: MeshInstance3D = MeshInstance3D.new()
	var frm: SphereMesh = SphereMesh.new()
	frm.radius = 0.13
	frm.height = 0.26
	fruit.mesh = frm
	fruit.material_override = holo_mat
	fruit.position = Vector3(0, 0, 0)
	holo_pivot.add_child(fruit)
	# Holo 3 — meat skewer (small box on a thin cylinder)
	var skewer_stick: MeshInstance3D = MeshInstance3D.new()
	var ssm: CylinderMesh = CylinderMesh.new()
	ssm.top_radius = 0.018
	ssm.bottom_radius = 0.018
	ssm.height = 0.30
	skewer_stick.mesh = ssm
	skewer_stick.material_override = holo_mat
	skewer_stick.position = Vector3(0.30, 0, 0)
	skewer_stick.rotation.z = PI / 2.0
	holo_pivot.add_child(skewer_stick)
	var skewer_meat: MeshInstance3D = MeshInstance3D.new()
	var smm: BoxMesh = BoxMesh.new()
	smm.size = Vector3(0.20, 0.10, 0.10)
	skewer_meat.mesh = smm
	skewer_meat.material_override = holo_mat
	skewer_meat.position = Vector3(0.30, 0, 0)
	holo_pivot.add_child(skewer_meat)
	# ---- Small chimney pipe behind the cart ----
	var chimney: MeshInstance3D = MeshInstance3D.new()
	var cmm: CylinderMesh = CylinderMesh.new()
	cmm.top_radius = 0.07
	cmm.bottom_radius = 0.10
	cmm.height = 1.10
	chimney.mesh = cmm
	chimney.material_override = iron_mat
	chimney.position = Vector3(-0.85, 1.95, 0.40)
	pivot.add_child(chimney)
	# Chimney brass top cap
	var chim_cap: MeshInstance3D = MeshInstance3D.new()
	var chcm: TorusMesh = TorusMesh.new()
	chcm.inner_radius = 0.08
	chcm.outer_radius = 0.14
	chim_cap.mesh = chcm
	chim_cap.material_override = brass_mat
	chim_cap.position = Vector3(-0.85, 2.50, 0.40)
	pivot.add_child(chim_cap)
	# Chimney smoke particles
	var chim_smoke: GPUParticles3D = GPUParticles3D.new()
	chim_smoke.position = Vector3(-0.85, 2.65, 0.40)
	chim_smoke.amount = 18
	chim_smoke.lifetime = 3.0
	var csmat: ParticleProcessMaterial = ParticleProcessMaterial.new()
	csmat.direction = Vector3(0, 1, 0)
	csmat.spread = 16.0
	csmat.initial_velocity_min = 0.6
	csmat.initial_velocity_max = 1.0
	csmat.gravity = Vector3(0.2, 0.4, 0)
	csmat.scale_min = 0.12
	csmat.scale_max = 0.24
	csmat.color = Color(0.30, 0.25, 0.20, 0.65)
	chim_smoke.process_material = csmat
	var cssm: SphereMesh = SphereMesh.new()
	cssm.radius = 0.10
	cssm.height = 0.20
	chim_smoke.draw_pass_1 = cssm
	pivot.add_child(chim_smoke)
	# ---- Warm hood OmniLight ----
	var lt: OmniLight3D = OmniLight3D.new()
	lt.position = Vector3(0, 1.80, 0)
	lt.light_color = Color(1.0, 0.65, 0.20)
	lt.light_energy = 2.0
	lt.omni_range = 5.5
	pivot.add_child(lt)
	# ---- Pulses + tweens ----
	# Slow holo spin (the food platter rotates slowly)
	var spin: Tween = pivot.create_tween().set_loops()
	spin.tween_property(holo_pivot, "rotation:y", TAU, 7.0)
	# Holo bob
	var bob: Tween = pivot.create_tween().set_loops()
	bob.tween_property(holo_pivot, "position:y", 2.10, 1.6).set_ease(Tween.EASE_IN_OUT)
	bob.tween_property(holo_pivot, "position:y", 1.80, 1.6).set_ease(Tween.EASE_IN_OUT)
	# Holo amber pulse
	var hpulse: Tween = pivot.create_tween().set_loops()
	hpulse.tween_property(holo_mat, "emission_energy_multiplier", 7.5, 1.6).set_ease(Tween.EASE_IN_OUT)
	hpulse.tween_property(holo_mat, "emission_energy_multiplier", 4.5, 1.6).set_ease(Tween.EASE_IN_OUT)


func _build_th_food_cart_chef_npc(town: Node) -> void:
	## Epic-10 T33: Food Cart Chef Mira — chef NPC standing behind the
	## food cart, stirring a pot. White chef coat with brass collar trim,
	## red apron over the front, tall white chef's hat, brass ladle held
	## in right hand on a stir pivot.
	var slots: Node3D = town.get_node_or_null("NPCSlots") as Node3D
	if slots == null:
		return
	var slot: Marker3D = Marker3D.new()
	slot.name = "THFoodCartChefMiraSlot"
	# Stand just behind the food cart (cart at +2.5, +11.5; chef at +2.5, +12.4)
	slot.position = TOWN_CENTER + Vector3(2.50, 0, 12.40)
	slots.add_child(slot)
	var npc_scene: PackedScene = load("res://scenes/entities/npcs/VillagerR3.tscn") as PackedScene
	if npc_scene == null:
		return
	var npc: Node3D = npc_scene.instantiate() as Node3D
	npc.name = "THFoodCartChefMira"
	if "npc_name" in npc:
		npc.set("npc_name", "Chef Mira")
	if "npc_id" in npc:
		npc.set("npc_id", "th_food_cart_chef_mira")
	# Face the cart (-Z direction toward the beacon side)
	npc.rotation.y = PI
	slot.add_child(npc)
	# Materials
	var coat_mat: StandardMaterial3D = StandardMaterial3D.new()
	coat_mat.albedo_color = Color(0.92, 0.92, 0.95)
	coat_mat.roughness = 0.85
	coat_mat.metallic = 0.10
	coat_mat.emission_enabled = true
	coat_mat.emission = Color(0.65, 0.85, 1.0)
	coat_mat.emission_energy_multiplier = 0.18
	var brass_mat: StandardMaterial3D = StandardMaterial3D.new()
	brass_mat.albedo_color = Color(0.85, 0.55, 0.18)
	brass_mat.metallic = 0.95
	brass_mat.roughness = 0.30
	brass_mat.emission_enabled = true
	brass_mat.emission = Color(1.0, 0.50, 0.10)
	brass_mat.emission_energy_multiplier = 0.55
	var apron_mat: StandardMaterial3D = StandardMaterial3D.new()
	apron_mat.albedo_color = Color(0.55, 0.18, 0.10)
	apron_mat.roughness = 0.85
	apron_mat.metallic = 0.10
	apron_mat.emission_enabled = true
	apron_mat.emission = Color(0.85, 0.20, 0.05)
	apron_mat.emission_energy_multiplier = 0.30
	var amber_mat: StandardMaterial3D = StandardMaterial3D.new()
	amber_mat.albedo_color = Color(1.0, 0.55, 0.10)
	amber_mat.emission_enabled = true
	amber_mat.emission = Color(1.0, 0.55, 0.10)
	amber_mat.emission_energy_multiplier = 6.0
	amber_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	# ---- White chef coat ----
	var coat: MeshInstance3D = MeshInstance3D.new()
	var cmesh: BoxMesh = BoxMesh.new()
	cmesh.size = Vector3(1.00, 1.40, 0.55)
	coat.mesh = cmesh
	coat.material_override = coat_mat
	coat.position = Vector3(0, 1.10, 0)
	npc.add_child(coat)
	# Brass collar trim
	var collar: MeshInstance3D = MeshInstance3D.new()
	var colm: BoxMesh = BoxMesh.new()
	colm.size = Vector3(1.00, 0.10, 0.55)
	collar.mesh = colm
	collar.material_override = brass_mat
	collar.position = Vector3(0, 1.80, 0)
	npc.add_child(collar)
	# 4 brass front buttons
	for by in [1.55, 1.30, 1.05, 0.80]:
		var btn: MeshInstance3D = MeshInstance3D.new()
		var bm: SphereMesh = SphereMesh.new()
		bm.radius = 0.05
		bm.height = 0.10
		btn.mesh = bm
		btn.material_override = brass_mat
		btn.position = Vector3(0, by, -0.30)
		npc.add_child(btn)
	# ---- Red apron over the front ----
	var apron: MeshInstance3D = MeshInstance3D.new()
	var apm: BoxMesh = BoxMesh.new()
	apm.size = Vector3(0.90, 1.05, 0.06)
	apron.mesh = apm
	apron.material_override = apron_mat
	apron.position = Vector3(0, 0.85, -0.30)
	npc.add_child(apron)
	# Apron strap (top)
	var strap: MeshInstance3D = MeshInstance3D.new()
	var stm: BoxMesh = BoxMesh.new()
	stm.size = Vector3(0.90, 0.08, 0.04)
	strap.mesh = stm
	strap.material_override = apron_mat
	strap.position = Vector3(0, 1.40, -0.32)
	npc.add_child(strap)
	# ---- Tall white chef's hat (cylinder + dome top) ----
	var hat_band: MeshInstance3D = MeshInstance3D.new()
	var hbm: CylinderMesh = CylinderMesh.new()
	hbm.top_radius = 0.32
	hbm.bottom_radius = 0.32
	hbm.height = 0.30
	hat_band.mesh = hbm
	hat_band.material_override = coat_mat
	hat_band.position = Vector3(0, 2.05, 0)
	npc.add_child(hat_band)
	var hat_top: MeshInstance3D = MeshInstance3D.new()
	var htm: SphereMesh = SphereMesh.new()
	htm.radius = 0.42
	htm.height = 0.85
	hat_top.mesh = htm
	hat_top.material_override = coat_mat
	hat_top.position = Vector3(0, 2.55, 0)
	hat_top.scale = Vector3(1.0, 1.10, 1.0)
	npc.add_child(hat_top)
	# Brass hat band trim
	var hat_trim: MeshInstance3D = MeshInstance3D.new()
	var ht_m: TorusMesh = TorusMesh.new()
	ht_m.inner_radius = 0.30
	ht_m.outer_radius = 0.36
	hat_trim.mesh = ht_m
	hat_trim.material_override = brass_mat
	hat_trim.position = Vector3(0, 1.92, 0)
	hat_trim.rotation.x = PI / 2.0
	npc.add_child(hat_trim)
	# ---- Left arm at his side ----
	var left_arm: MeshInstance3D = MeshInstance3D.new()
	var lam: BoxMesh = BoxMesh.new()
	lam.size = Vector3(0.18, 0.85, 0.18)
	left_arm.mesh = lam
	left_arm.material_override = coat_mat
	left_arm.position = Vector3(-0.55, 1.10, 0)
	npc.add_child(left_arm)
	# ---- Right arm + ladle on a stir pivot at the shoulder ----
	var stir_pivot: Node3D = Node3D.new()
	stir_pivot.position = Vector3(0.55, 1.55, 0)
	npc.add_child(stir_pivot)
	var right_arm: MeshInstance3D = MeshInstance3D.new()
	var ram: BoxMesh = BoxMesh.new()
	ram.size = Vector3(0.18, 0.85, 0.18)
	right_arm.mesh = ram
	right_arm.material_override = coat_mat
	right_arm.position = Vector3(0, -0.42, 0)
	stir_pivot.add_child(right_arm)
	# Ladle handle (long brass cylinder)
	var ladle_handle: MeshInstance3D = MeshInstance3D.new()
	var lhm: CylinderMesh = CylinderMesh.new()
	lhm.top_radius = 0.04
	lhm.bottom_radius = 0.04
	lhm.height = 0.85
	ladle_handle.mesh = lhm
	ladle_handle.material_override = brass_mat
	ladle_handle.position = Vector3(0, -1.30, 0)
	stir_pivot.add_child(ladle_handle)
	# Ladle bowl (small brass half-sphere at the end)
	var ladle_bowl: MeshInstance3D = MeshInstance3D.new()
	var lbm: SphereMesh = SphereMesh.new()
	lbm.radius = 0.13
	lbm.height = 0.20
	ladle_bowl.mesh = lbm
	ladle_bowl.material_override = brass_mat
	ladle_bowl.position = Vector3(0, -1.75, 0)
	ladle_bowl.scale = Vector3(1.0, 0.55, 1.0)
	stir_pivot.add_child(ladle_bowl)
	# Glowing sauce drip dot below the ladle bowl
	var drip: MeshInstance3D = MeshInstance3D.new()
	var dm: SphereMesh = SphereMesh.new()
	dm.radius = 0.05
	dm.height = 0.10
	drip.mesh = dm
	drip.material_override = amber_mat
	drip.position = Vector3(0, -1.85, 0)
	stir_pivot.add_child(drip)
	# Initial pose — arm raised forward holding ladle over the pot
	stir_pivot.rotation.x = -1.40
	# ---- Subtle warm OmniLight ----
	var lt: OmniLight3D = OmniLight3D.new()
	lt.position = Vector3(0, 1.55, -0.30)
	lt.light_color = Color(1.0, 0.65, 0.20)
	lt.light_energy = 1.6
	lt.omni_range = 4.5
	npc.add_child(lt)
	# ---- Stirring tween — ladle rotates around Y over the pot in a circular stir motion ----
	var stir: Tween = npc.create_tween().set_loops()
	stir.tween_property(stir_pivot, "rotation:y", 0.70, 1.2).set_ease(Tween.EASE_IN_OUT)
	stir.tween_property(stir_pivot, "rotation:y", -0.70, 1.2).set_ease(Tween.EASE_IN_OUT)
	# Drip pulse
	var dpulse: Tween = npc.create_tween().set_loops()
	dpulse.tween_property(amber_mat, "emission_energy_multiplier", 8.0, 1.4).set_ease(Tween.EASE_IN_OUT)
	dpulse.tween_property(amber_mat, "emission_energy_multiplier", 4.5, 1.4).set_ease(Tween.EASE_IN_OUT)


func _build_th_busker_npc(town: Node) -> void:
	## Epic-10 T34: Busker Lyra — street musician NPC standing near the
	## east bench area strumming a glowing data lyre. Long teal robe with
	## brass collar trim, brass headband with feather plume, lyre held in
	## both hands at chest height with strumming finger pivot. Floating
	## music note holos drifting up from the lyre.
	var slots: Node3D = town.get_node_or_null("NPCSlots") as Node3D
	if slots == null:
		return
	var slot: Marker3D = Marker3D.new()
	slot.name = "THBuskerLyraSlot"
	# Stand near the east bench area at radius 11.5, between the E and SE benches
	var ang: float = -PI / 8.0
	slot.position = TOWN_CENTER + Vector3(cos(ang) * 11.50, 0, sin(ang) * 11.50)
	slots.add_child(slot)
	var npc_scene: PackedScene = load("res://scenes/entities/npcs/VillagerR3.tscn") as PackedScene
	if npc_scene == null:
		return
	var npc: Node3D = npc_scene.instantiate() as Node3D
	npc.name = "THBuskerLyra"
	if "npc_name" in npc:
		npc.set("npc_name", "Busker Lyra")
	if "npc_id" in npc:
		npc.set("npc_id", "th_busker_lyra")
	# Face inward toward the beacon
	npc.rotation.y = -ang + PI / 2.0
	slot.add_child(npc)
	# Materials
	var robe_mat: StandardMaterial3D = StandardMaterial3D.new()
	robe_mat.albedo_color = Color(0.18, 0.55, 0.55)
	robe_mat.roughness = 0.85
	robe_mat.metallic = 0.18
	robe_mat.emission_enabled = true
	robe_mat.emission = Color(0.30, 0.85, 0.85)
	robe_mat.emission_energy_multiplier = 0.30
	var brass_mat: StandardMaterial3D = StandardMaterial3D.new()
	brass_mat.albedo_color = Color(0.85, 0.55, 0.18)
	brass_mat.metallic = 0.95
	brass_mat.roughness = 0.30
	brass_mat.emission_enabled = true
	brass_mat.emission = Color(1.0, 0.50, 0.10)
	brass_mat.emission_energy_multiplier = 0.55
	var data_mat: StandardMaterial3D = StandardMaterial3D.new()
	data_mat.albedo_color = Color(0.45, 0.85, 1.0)
	data_mat.emission_enabled = true
	data_mat.emission = Color(0.45, 0.85, 1.0)
	data_mat.emission_energy_multiplier = 7.0
	data_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	# ---- Long teal robe ----
	var robe: MeshInstance3D = MeshInstance3D.new()
	var rmesh: BoxMesh = BoxMesh.new()
	rmesh.size = Vector3(0.95, 1.65, 0.55)
	robe.mesh = rmesh
	robe.material_override = robe_mat
	robe.position = Vector3(0, 0.85, 0)
	npc.add_child(robe)
	# Brass collar trim
	var collar: MeshInstance3D = MeshInstance3D.new()
	var colm: BoxMesh = BoxMesh.new()
	colm.size = Vector3(0.95, 0.10, 0.55)
	collar.mesh = colm
	collar.material_override = brass_mat
	collar.position = Vector3(0, 1.65, 0)
	npc.add_child(collar)
	# ---- Brass headband ----
	var headband: MeshInstance3D = MeshInstance3D.new()
	var hbm: TorusMesh = TorusMesh.new()
	hbm.inner_radius = 0.30
	hbm.outer_radius = 0.36
	headband.mesh = hbm
	headband.material_override = brass_mat
	headband.position = Vector3(0, 1.95, 0)
	headband.rotation.x = PI / 2.0
	npc.add_child(headband)
	# Feather plume on the side of the headband
	var feather: MeshInstance3D = MeshInstance3D.new()
	var fmm: PrismMesh = PrismMesh.new()
	fmm.size = Vector3(0.10, 0.55, 0.06)
	feather.mesh = fmm
	feather.material_override = data_mat
	feather.position = Vector3(0.30, 2.30, -0.10)
	feather.rotation.z = -0.40
	npc.add_child(feather)
	# ---- Lyre held in both hands at chest height ----
	# Lyre frame (small brass U-shape: bottom bar + 2 vertical posts)
	var lyre_pivot: Node3D = Node3D.new()
	lyre_pivot.position = Vector3(0, 1.10, -0.45)
	npc.add_child(lyre_pivot)
	# Lyre bottom bar
	var bottom_bar: MeshInstance3D = MeshInstance3D.new()
	var bbm: BoxMesh = BoxMesh.new()
	bbm.size = Vector3(0.55, 0.12, 0.10)
	bottom_bar.mesh = bbm
	bottom_bar.material_override = brass_mat
	bottom_bar.position = Vector3(0, 0, 0)
	lyre_pivot.add_child(bottom_bar)
	# 2 vertical posts (small angled prisms forming a U/V)
	for px in [-0.25, 0.25]:
		var post: MeshInstance3D = MeshInstance3D.new()
		var pm: BoxMesh = BoxMesh.new()
		pm.size = Vector3(0.06, 0.55, 0.08)
		post.mesh = pm
		post.material_override = brass_mat
		post.position = Vector3(px * 1.10, 0.30, 0)
		post.rotation.z = -px * 0.40
		lyre_pivot.add_child(post)
	# Top crossbar connecting the posts
	var top_bar: MeshInstance3D = MeshInstance3D.new()
	var tbm: BoxMesh = BoxMesh.new()
	tbm.size = Vector3(0.65, 0.08, 0.10)
	top_bar.mesh = tbm
	top_bar.material_override = brass_mat
	top_bar.position = Vector3(0, 0.65, 0)
	lyre_pivot.add_child(top_bar)
	# 5 glowing data string lines (small thin boxes vertically between bars)
	for i in 5:
		var sx: float = -0.20 + float(i) * 0.10
		var string: MeshInstance3D = MeshInstance3D.new()
		var sm: BoxMesh = BoxMesh.new()
		sm.size = Vector3(0.02, 0.55, 0.02)
		string.mesh = sm
		string.material_override = data_mat
		string.position = Vector3(sx, 0.32, -0.04)
		lyre_pivot.add_child(string)
	# ---- Strumming finger pivot — small brass box on rotation pivot ----
	var strum_pivot: Node3D = Node3D.new()
	strum_pivot.position = Vector3(0.50, 1.30, -0.35)
	npc.add_child(strum_pivot)
	var finger: MeshInstance3D = MeshInstance3D.new()
	var fnm: BoxMesh = BoxMesh.new()
	fnm.size = Vector3(0.10, 0.20, 0.10)
	finger.mesh = fnm
	finger.material_override = brass_mat
	finger.position = Vector3(0, -0.18, 0)
	strum_pivot.add_child(finger)
	# ---- Floating music note holos drifting up from the lyre ----
	var notes: GPUParticles3D = GPUParticles3D.new()
	notes.position = Vector3(0, 1.55, -0.50)
	notes.amount = 12
	notes.lifetime = 2.6
	var pmat: ParticleProcessMaterial = ParticleProcessMaterial.new()
	pmat.direction = Vector3(0, 1, 0)
	pmat.spread = 14.0
	pmat.initial_velocity_min = 0.4
	pmat.initial_velocity_max = 0.9
	pmat.gravity = Vector3(0, 0.10, 0)
	pmat.scale_min = 0.06
	pmat.scale_max = 0.12
	pmat.color = Color(0.45, 0.85, 1.0, 1.0)
	notes.process_material = pmat
	var psmesh: SphereMesh = SphereMesh.new()
	psmesh.radius = 0.05
	psmesh.height = 0.10
	notes.draw_pass_1 = psmesh
	npc.add_child(notes)
	# ---- Subtle warm cyan OmniLight ----
	var lt: OmniLight3D = OmniLight3D.new()
	lt.position = Vector3(0, 1.30, -0.30)
	lt.light_color = Color(0.65, 0.85, 1.0)
	lt.light_energy = 1.6
	lt.omni_range = 4.5
	npc.add_child(lt)
	# ---- Strumming tween — finger sweeps up-and-down rapidly ----
	var strum: Tween = npc.create_tween().set_loops()
	strum.tween_property(strum_pivot, "rotation:x", -0.30, 0.20).set_ease(Tween.EASE_IN_OUT)
	strum.tween_property(strum_pivot, "rotation:x", 0.30, 0.20).set_ease(Tween.EASE_IN_OUT)
	strum.tween_property(strum_pivot, "rotation:x", -0.30, 0.20).set_ease(Tween.EASE_IN_OUT)
	strum.tween_property(strum_pivot, "rotation:x", 0.30, 0.20).set_ease(Tween.EASE_IN_OUT)
	strum.tween_property(strum_pivot, "rotation:x", 0.0, 0.30)
	# String + feather + note pulse (shared data material)
	var dpulse: Tween = npc.create_tween().set_loops()
	dpulse.tween_property(data_mat, "emission_energy_multiplier", 9.0, 1.4).set_ease(Tween.EASE_IN_OUT)
	dpulse.tween_property(data_mat, "emission_energy_multiplier", 5.0, 1.4).set_ease(Tween.EASE_IN_OUT)


func _build_th_courier_drones(geom: Node) -> void:
	## Epic-10 T35: 4 small floating brass courier drones orbiting the
	## plaza at altitude, each carrying a tiny glowing data parcel. Each
	## drone: brass spherical body with 4 brass propeller blades on top,
	## glowing cyan eye dot, glowing amber tail thruster, dangling parcel
	## box. Each drone follows a circular orbit pivot at varied radius
	## and altitude, with its own slow yaw spin and parcel bob.
	var pivot: Node3D = Node3D.new()
	pivot.name = "TH_CourierDrones"
	pivot.position = TOWN_CENTER + Vector3(0, 0, 0)
	geom.add_child(pivot)
	# Materials
	var brass_mat: StandardMaterial3D = StandardMaterial3D.new()
	brass_mat.albedo_color = Color(0.85, 0.55, 0.18)
	brass_mat.metallic = 0.95
	brass_mat.roughness = 0.30
	brass_mat.emission_enabled = true
	brass_mat.emission = Color(1.0, 0.50, 0.10)
	brass_mat.emission_energy_multiplier = 0.55
	var data_mat: StandardMaterial3D = StandardMaterial3D.new()
	data_mat.albedo_color = Color(0.45, 0.85, 1.0)
	data_mat.emission_enabled = true
	data_mat.emission = Color(0.45, 0.85, 1.0)
	data_mat.emission_energy_multiplier = 7.0
	data_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var thruster_mat: StandardMaterial3D = StandardMaterial3D.new()
	thruster_mat.albedo_color = Color(1.0, 0.55, 0.10)
	thruster_mat.emission_enabled = true
	thruster_mat.emission = Color(1.0, 0.55, 0.10)
	thruster_mat.emission_energy_multiplier = 7.5
	thruster_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	# 4 drones — each on its own orbit pivot at varied radius/altitude
	var drone_data: Array = [
		{"radius": 7.0, "altitude": 9.0, "period": 14.0, "phase": 0.0},
		{"radius": 9.5, "altitude": 11.0, "period": 18.0, "phase": PI / 2.0},
		{"radius": 6.5, "altitude": 8.0, "period": 16.0, "phase": PI},
		{"radius": 8.5, "altitude": 10.0, "period": 20.0, "phase": 3.0 * PI / 2.0},
	]
	for i in drone_data.size():
		var dd: Dictionary = drone_data[i]
		# Orbit pivot — rotates around Y to make the drone fly in a circle
		var orbit_pivot: Node3D = Node3D.new()
		orbit_pivot.name = "DroneOrbit_" + str(i)
		orbit_pivot.position = Vector3(0, 0, 0)
		# Set the initial phase rotation
		orbit_pivot.rotation.y = dd["phase"]
		pivot.add_child(orbit_pivot)
		# Drone group — offset from the orbit pivot so it traces a circle
		var dgroup: Node3D = Node3D.new()
		dgroup.name = "Drone_" + str(i)
		dgroup.position = Vector3(dd["radius"], dd["altitude"], 0)
		# Face the orbit direction (perpendicular to the radial vector)
		dgroup.rotation.y = -PI / 2.0
		orbit_pivot.add_child(dgroup)
		# ---- Brass spherical body ----
		var body: MeshInstance3D = MeshInstance3D.new()
		var bm: SphereMesh = SphereMesh.new()
		bm.radius = 0.25
		bm.height = 0.45
		body.mesh = bm
		body.material_override = brass_mat
		body.position = Vector3(0, 0, 0)
		dgroup.add_child(body)
		# ---- 4 brass propeller blades on top ----
		var prop_pivot: Node3D = Node3D.new()
		prop_pivot.position = Vector3(0, 0.30, 0)
		dgroup.add_child(prop_pivot)
		for p in 4:
			var pang: float = float(p) / 4.0 * TAU
			var blade: MeshInstance3D = MeshInstance3D.new()
			var blm: BoxMesh = BoxMesh.new()
			blm.size = Vector3(0.45, 0.04, 0.10)
			blade.mesh = blm
			blade.material_override = brass_mat
			blade.position = Vector3(cos(pang) * 0.20, 0, sin(pang) * 0.20)
			blade.rotation.y = pang
			prop_pivot.add_child(blade)
		# Prop hub (small brass cap)
		var hub: MeshInstance3D = MeshInstance3D.new()
		var hbm: SphereMesh = SphereMesh.new()
		hbm.radius = 0.06
		hbm.height = 0.12
		hub.mesh = hbm
		hub.material_override = brass_mat
		hub.position = Vector3(0, 0.04, 0)
		prop_pivot.add_child(hub)
		# ---- Glowing cyan eye dot on the front of the body ----
		var eye: MeshInstance3D = MeshInstance3D.new()
		var em: SphereMesh = SphereMesh.new()
		em.radius = 0.06
		em.height = 0.12
		eye.mesh = em
		eye.material_override = data_mat
		eye.position = Vector3(0, 0.05, -0.22)
		dgroup.add_child(eye)
		# ---- Glowing amber tail thruster on the back ----
		var thruster: MeshInstance3D = MeshInstance3D.new()
		var thm: SphereMesh = SphereMesh.new()
		thm.radius = 0.08
		thm.height = 0.16
		thruster.mesh = thm
		thruster.material_override = thruster_mat
		thruster.position = Vector3(0, 0, 0.30)
		dgroup.add_child(thruster)
		# ---- Dangling parcel box ----
		# Brass tether (small thin cylinder)
		var tether: MeshInstance3D = MeshInstance3D.new()
		var ttm: CylinderMesh = CylinderMesh.new()
		ttm.top_radius = 0.018
		ttm.bottom_radius = 0.018
		ttm.height = 0.30
		tether.mesh = ttm
		tether.material_override = brass_mat
		tether.position = Vector3(0, -0.30, 0)
		dgroup.add_child(tether)
		# Parcel box
		var parcel: MeshInstance3D = MeshInstance3D.new()
		var pmm: BoxMesh = BoxMesh.new()
		pmm.size = Vector3(0.22, 0.20, 0.22)
		parcel.mesh = pmm
		parcel.material_override = brass_mat
		parcel.position = Vector3(0, -0.55, 0)
		dgroup.add_child(parcel)
		# Glowing data wrap on the parcel (small unshaded cyan stripe)
		var wrap: MeshInstance3D = MeshInstance3D.new()
		var wm: BoxMesh = BoxMesh.new()
		wm.size = Vector3(0.24, 0.04, 0.24)
		wrap.mesh = wm
		wrap.material_override = data_mat
		wrap.position = Vector3(0, -0.55, 0)
		dgroup.add_child(wrap)
		# ---- Per-drone OmniLight (warm wash) ----
		var lt: OmniLight3D = OmniLight3D.new()
		lt.position = Vector3(0, 0, 0)
		lt.light_color = Color(1.0, 0.65, 0.20)
		lt.light_energy = 1.4
		lt.omni_range = 4.5
		dgroup.add_child(lt)
		# ---- Tweens ----
		# Slow propeller spin
		var prop_spin: Tween = pivot.create_tween().set_loops()
		prop_spin.tween_property(prop_pivot, "rotation:y", TAU, 1.5)
		# Orbit rotation around the plaza
		var orbit: Tween = pivot.create_tween().set_loops()
		orbit.tween_property(orbit_pivot, "rotation:y", dd["phase"] + TAU, dd["period"])
		# Per-drone Y bob (parcel sway feel)
		var bob_period: float = 1.6 + float(i) * 0.20
		var bob: Tween = pivot.create_tween().set_loops()
		bob.tween_property(dgroup, "position:y", dd["altitude"] + 0.30, bob_period).set_ease(Tween.EASE_IN_OUT)
		bob.tween_property(dgroup, "position:y", dd["altitude"] - 0.30, bob_period).set_ease(Tween.EASE_IN_OUT)
	# Shared data + thruster pulse
	var dpulse2: Tween = pivot.create_tween().set_loops()
	dpulse2.tween_property(data_mat, "emission_energy_multiplier", 9.0, 1.6).set_ease(Tween.EASE_IN_OUT)
	dpulse2.tween_property(data_mat, "emission_energy_multiplier", 5.5, 1.6).set_ease(Tween.EASE_IN_OUT)
	var tpulse: Tween = pivot.create_tween().set_loops()
	tpulse.tween_property(thruster_mat, "emission_energy_multiplier", 9.5, 0.9).set_ease(Tween.EASE_IN_OUT)
	tpulse.tween_property(thruster_mat, "emission_energy_multiplier", 6.0, 0.9).set_ease(Tween.EASE_IN_OUT)


func _build_th_north_entry_arch(geom: Node) -> void:
	## Epic-10 T36: north entry arch over the N radial path. Same scale and
	## treatment as the W secondary arch (T31), with cyan letter blocks
	## instead of amber to evoke the data-side aesthetic. 2 basalt pillars
	## flanking the path, brass crossbar, central nameplate with letters,
	## hanging chains, and 2 corner pillar torches.
	var pivot: Node3D = Node3D.new()
	pivot.name = "TH_NorthEntryArch"
	# N radial path, just outside the outer plaza rim
	pivot.position = TOWN_CENTER + Vector3(0, 0, -15.50)
	# Arch spans X (perpendicular to N radial direction), no rotation needed
	geom.add_child(pivot)
	# Materials
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.20, 0.22, 0.26)
	stone_mat.metallic = 0.18
	stone_mat.roughness = 0.85
	stone_mat.emission_enabled = true
	stone_mat.emission = Color(0.30, 0.45, 0.60)
	stone_mat.emission_energy_multiplier = 0.18
	var brass_mat: StandardMaterial3D = StandardMaterial3D.new()
	brass_mat.albedo_color = Color(0.85, 0.55, 0.18)
	brass_mat.metallic = 0.95
	brass_mat.roughness = 0.30
	brass_mat.emission_enabled = true
	brass_mat.emission = Color(1.0, 0.50, 0.10)
	brass_mat.emission_energy_multiplier = 0.55
	var data_mat: StandardMaterial3D = StandardMaterial3D.new()
	data_mat.albedo_color = Color(0.45, 0.85, 1.0)
	data_mat.emission_enabled = true
	data_mat.emission = Color(0.45, 0.85, 1.0)
	data_mat.emission_energy_multiplier = 6.5
	data_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var flame_mat: StandardMaterial3D = StandardMaterial3D.new()
	flame_mat.albedo_color = Color(1.0, 0.65, 0.20)
	flame_mat.emission_enabled = true
	flame_mat.emission = Color(1.0, 0.55, 0.10)
	flame_mat.emission_energy_multiplier = 8.5
	flame_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var iron_mat: StandardMaterial3D = StandardMaterial3D.new()
	iron_mat.albedo_color = Color(0.18, 0.16, 0.18)
	iron_mat.metallic = 0.85
	iron_mat.roughness = 0.45
	# ---- 2 basalt pillars at +/- offset along the arch axis ----
	for px in [-4.50, 4.50]:
		var pgroup: Node3D = Node3D.new()
		pgroup.name = "NorthArchPillar_" + str(int(px))
		pgroup.position = Vector3(px, 0, 0)
		pivot.add_child(pgroup)
		# Stepped base
		var base1: MeshInstance3D = MeshInstance3D.new()
		var b1m: BoxMesh = BoxMesh.new()
		b1m.size = Vector3(1.55, 0.45, 1.55)
		base1.mesh = b1m
		base1.material_override = stone_mat
		base1.position = Vector3(0, 0.22, 0)
		pgroup.add_child(base1)
		var base2: MeshInstance3D = MeshInstance3D.new()
		var b2m: BoxMesh = BoxMesh.new()
		b2m.size = Vector3(1.30, 0.35, 1.30)
		base2.mesh = b2m
		base2.material_override = stone_mat
		base2.position = Vector3(0, 0.62, 0)
		pgroup.add_child(base2)
		# Pillar shaft (6m)
		var shaft: MeshInstance3D = MeshInstance3D.new()
		var sm: BoxMesh = BoxMesh.new()
		sm.size = Vector3(1.00, 6.00, 1.00)
		shaft.mesh = sm
		shaft.material_override = stone_mat
		shaft.position = Vector3(0, 3.80, 0)
		pgroup.add_child(shaft)
		# Combined collision
		var sb: StaticBody3D = StaticBody3D.new()
		sb.position = Vector3(0, 3.65, 0)
		var cs: CollisionShape3D = CollisionShape3D.new()
		var bsh: BoxShape3D = BoxShape3D.new()
		bsh.size = Vector3(1.55, 7.30, 1.55)
		cs.shape = bsh
		sb.add_child(cs)
		pgroup.add_child(sb)
		# Brass mid band
		var band: MeshInstance3D = MeshInstance3D.new()
		var bdm: BoxMesh = BoxMesh.new()
		bdm.size = Vector3(1.10, 0.18, 1.10)
		band.mesh = bdm
		band.material_override = brass_mat
		band.position = Vector3(0, 4.00, 0)
		pgroup.add_child(band)
		# Brass top cap
		var cap: MeshInstance3D = MeshInstance3D.new()
		var capm: BoxMesh = BoxMesh.new()
		capm.size = Vector3(1.30, 0.25, 1.30)
		cap.mesh = capm
		cap.material_override = brass_mat
		cap.position = Vector3(0, 6.95, 0)
		pgroup.add_child(cap)
		# ---- Pillar mid-height torch (inner-facing toward the +Z plaza side) ----
		var bracket: MeshInstance3D = MeshInstance3D.new()
		var bktm: BoxMesh = BoxMesh.new()
		bktm.size = Vector3(0.18, 0.20, 0.45)
		bracket.mesh = bktm
		bracket.material_override = brass_mat
		bracket.position = Vector3(0, 4.55, 0.62)
		pgroup.add_child(bracket)
		var flame: MeshInstance3D = MeshInstance3D.new()
		var flm: SphereMesh = SphereMesh.new()
		flm.radius = 0.18
		flm.height = 0.36
		flame.mesh = flm
		flame.material_override = flame_mat
		flame.position = Vector3(0, 4.80, 0.87)
		pgroup.add_child(flame)
		var lt: OmniLight3D = OmniLight3D.new()
		lt.position = Vector3(0, 4.80, 0.87)
		lt.light_color = Color(1.0, 0.55, 0.15)
		lt.light_energy = 2.6
		lt.omni_range = 7.0
		pgroup.add_child(lt)
	# ---- Brass crossbar arch overhead ----
	var crossbar: MeshInstance3D = MeshInstance3D.new()
	var cbm: BoxMesh = BoxMesh.new()
	cbm.size = Vector3(10.50, 0.40, 1.00)
	crossbar.mesh = cbm
	crossbar.material_override = brass_mat
	crossbar.position = Vector3(0, 7.10, 0)
	pivot.add_child(crossbar)
	# Crossbar bottom trim lip
	var trim: MeshInstance3D = MeshInstance3D.new()
	var trm: BoxMesh = BoxMesh.new()
	trm.size = Vector3(10.20, 0.14, 1.10)
	trim.mesh = trm
	trim.material_override = brass_mat
	trim.position = Vector3(0, 6.85, 0)
	pivot.add_child(trim)
	# ---- Central hanging brass plate with 8 glowing cyan letters ----
	var plate: MeshInstance3D = MeshInstance3D.new()
	var plm: BoxMesh = BoxMesh.new()
	plm.size = Vector3(4.20, 1.10, 0.16)
	plate.mesh = plm
	plate.material_override = brass_mat
	plate.position = Vector3(0, 5.50, 0)
	pivot.add_child(plate)
	# 8 glowing cyan letters across the plate (data side)
	for i in 8:
		var lx: float = -1.65 + float(i) * 0.47
		var letter: MeshInstance3D = MeshInstance3D.new()
		var lm: BoxMesh = BoxMesh.new()
		lm.size = Vector3(0.26, 0.50, 0.06)
		letter.mesh = lm
		letter.material_override = data_mat
		letter.position = Vector3(lx, 5.50, -0.12)
		pivot.add_child(letter)
	# 2 brass support chains from the crossbar to the plate
	for cx in [-1.80, 1.80]:
		var chain: MeshInstance3D = MeshInstance3D.new()
		var chmm: CylinderMesh = CylinderMesh.new()
		chmm.top_radius = 0.04
		chmm.bottom_radius = 0.04
		chmm.height = 1.10
		chain.mesh = chmm
		chain.material_override = iron_mat
		chain.position = Vector3(cx, 6.30, 0)
		pivot.add_child(chain)
	# ---- 2 hanging cyan crystal pendants from the crossbar (decorative) ----
	for cnx in [-3.50, 3.50]:
		# Pendant chain
		var pendant_chain: MeshInstance3D = MeshInstance3D.new()
		var pcm: CylinderMesh = CylinderMesh.new()
		pcm.top_radius = 0.025
		pcm.bottom_radius = 0.025
		pcm.height = 0.55
		pendant_chain.mesh = pcm
		pendant_chain.material_override = iron_mat
		pendant_chain.position = Vector3(cnx, 6.55, 0)
		pivot.add_child(pendant_chain)
		# Cyan crystal prism
		var crystal: MeshInstance3D = MeshInstance3D.new()
		var crm: PrismMesh = PrismMesh.new()
		crm.size = Vector3(0.20, 0.35, 0.20)
		crystal.mesh = crm
		crystal.material_override = data_mat
		crystal.position = Vector3(cnx, 6.10, 0)
		pivot.add_child(crystal)
	# ---- Pulses ----
	var lpulse: Tween = pivot.create_tween().set_loops()
	lpulse.tween_property(data_mat, "emission_energy_multiplier", 8.5, 1.8).set_ease(Tween.EASE_IN_OUT)
	lpulse.tween_property(data_mat, "emission_energy_multiplier", 5.0, 1.8).set_ease(Tween.EASE_IN_OUT)
	var fpulse: Tween = pivot.create_tween().set_loops()
	fpulse.tween_property(flame_mat, "emission_energy_multiplier", 10.5, 0.5).set_ease(Tween.EASE_IN_OUT)
	fpulse.tween_property(flame_mat, "emission_energy_multiplier", 7.0, 0.5).set_ease(Tween.EASE_IN_OUT)


func _build_th_south_entry_arch(geom: Node) -> void:
	## Epic-10 T37: south entry arch over the S radial path, completing
	## the 4-arch cardinal entry ring. Same scale as the N arch but with
	## amber letters and brass coin pendants for the warm/forge side
	## aesthetic, balancing the data-side N arch.
	var pivot: Node3D = Node3D.new()
	pivot.name = "TH_SouthEntryArch"
	# S radial path, just outside the outer plaza rim
	pivot.position = TOWN_CENTER + Vector3(0, 0, 15.50)
	geom.add_child(pivot)
	# Materials
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.20, 0.22, 0.26)
	stone_mat.metallic = 0.18
	stone_mat.roughness = 0.85
	stone_mat.emission_enabled = true
	stone_mat.emission = Color(0.30, 0.45, 0.60)
	stone_mat.emission_energy_multiplier = 0.18
	var brass_mat: StandardMaterial3D = StandardMaterial3D.new()
	brass_mat.albedo_color = Color(0.85, 0.55, 0.18)
	brass_mat.metallic = 0.95
	brass_mat.roughness = 0.30
	brass_mat.emission_enabled = true
	brass_mat.emission = Color(1.0, 0.50, 0.10)
	brass_mat.emission_energy_multiplier = 0.55
	var amber_mat: StandardMaterial3D = StandardMaterial3D.new()
	amber_mat.albedo_color = Color(1.0, 0.55, 0.10)
	amber_mat.emission_enabled = true
	amber_mat.emission = Color(1.0, 0.55, 0.10)
	amber_mat.emission_energy_multiplier = 6.5
	amber_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var flame_mat: StandardMaterial3D = StandardMaterial3D.new()
	flame_mat.albedo_color = Color(1.0, 0.65, 0.20)
	flame_mat.emission_enabled = true
	flame_mat.emission = Color(1.0, 0.55, 0.10)
	flame_mat.emission_energy_multiplier = 8.5
	flame_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var iron_mat: StandardMaterial3D = StandardMaterial3D.new()
	iron_mat.albedo_color = Color(0.18, 0.16, 0.18)
	iron_mat.metallic = 0.85
	iron_mat.roughness = 0.45
	# ---- 2 basalt pillars at +/- offset along the arch axis ----
	for px in [-4.50, 4.50]:
		var pgroup: Node3D = Node3D.new()
		pgroup.name = "SouthArchPillar_" + str(int(px))
		pgroup.position = Vector3(px, 0, 0)
		pivot.add_child(pgroup)
		# Stepped base
		var base1: MeshInstance3D = MeshInstance3D.new()
		var b1m: BoxMesh = BoxMesh.new()
		b1m.size = Vector3(1.55, 0.45, 1.55)
		base1.mesh = b1m
		base1.material_override = stone_mat
		base1.position = Vector3(0, 0.22, 0)
		pgroup.add_child(base1)
		var base2: MeshInstance3D = MeshInstance3D.new()
		var b2m: BoxMesh = BoxMesh.new()
		b2m.size = Vector3(1.30, 0.35, 1.30)
		base2.mesh = b2m
		base2.material_override = stone_mat
		base2.position = Vector3(0, 0.62, 0)
		pgroup.add_child(base2)
		# Pillar shaft (6m)
		var shaft: MeshInstance3D = MeshInstance3D.new()
		var sm: BoxMesh = BoxMesh.new()
		sm.size = Vector3(1.00, 6.00, 1.00)
		shaft.mesh = sm
		shaft.material_override = stone_mat
		shaft.position = Vector3(0, 3.80, 0)
		pgroup.add_child(shaft)
		# Combined collision
		var sb: StaticBody3D = StaticBody3D.new()
		sb.position = Vector3(0, 3.65, 0)
		var cs: CollisionShape3D = CollisionShape3D.new()
		var bsh: BoxShape3D = BoxShape3D.new()
		bsh.size = Vector3(1.55, 7.30, 1.55)
		cs.shape = bsh
		sb.add_child(cs)
		pgroup.add_child(sb)
		# Brass mid band
		var band: MeshInstance3D = MeshInstance3D.new()
		var bdm: BoxMesh = BoxMesh.new()
		bdm.size = Vector3(1.10, 0.18, 1.10)
		band.mesh = bdm
		band.material_override = brass_mat
		band.position = Vector3(0, 4.00, 0)
		pgroup.add_child(band)
		# Brass top cap
		var cap: MeshInstance3D = MeshInstance3D.new()
		var capm: BoxMesh = BoxMesh.new()
		capm.size = Vector3(1.30, 0.25, 1.30)
		cap.mesh = capm
		cap.material_override = brass_mat
		cap.position = Vector3(0, 6.95, 0)
		pgroup.add_child(cap)
		# ---- Pillar mid-height torch (inner-facing toward -Z plaza side) ----
		var bracket: MeshInstance3D = MeshInstance3D.new()
		var bktm: BoxMesh = BoxMesh.new()
		bktm.size = Vector3(0.18, 0.20, 0.45)
		bracket.mesh = bktm
		bracket.material_override = brass_mat
		bracket.position = Vector3(0, 4.55, -0.62)
		pgroup.add_child(bracket)
		var flame: MeshInstance3D = MeshInstance3D.new()
		var flm: SphereMesh = SphereMesh.new()
		flm.radius = 0.18
		flm.height = 0.36
		flame.mesh = flm
		flame.material_override = flame_mat
		flame.position = Vector3(0, 4.80, -0.87)
		pgroup.add_child(flame)
		var lt: OmniLight3D = OmniLight3D.new()
		lt.position = Vector3(0, 4.80, -0.87)
		lt.light_color = Color(1.0, 0.55, 0.15)
		lt.light_energy = 2.6
		lt.omni_range = 7.0
		pgroup.add_child(lt)
	# ---- Brass crossbar arch overhead ----
	var crossbar: MeshInstance3D = MeshInstance3D.new()
	var cbm: BoxMesh = BoxMesh.new()
	cbm.size = Vector3(10.50, 0.40, 1.00)
	crossbar.mesh = cbm
	crossbar.material_override = brass_mat
	crossbar.position = Vector3(0, 7.10, 0)
	pivot.add_child(crossbar)
	# Crossbar bottom trim lip
	var trim: MeshInstance3D = MeshInstance3D.new()
	var trm: BoxMesh = BoxMesh.new()
	trm.size = Vector3(10.20, 0.14, 1.10)
	trim.mesh = trm
	trim.material_override = brass_mat
	trim.position = Vector3(0, 6.85, 0)
	pivot.add_child(trim)
	# ---- Central hanging brass plate with 8 glowing amber letters ----
	var plate: MeshInstance3D = MeshInstance3D.new()
	var plm: BoxMesh = BoxMesh.new()
	plm.size = Vector3(4.20, 1.10, 0.16)
	plate.mesh = plm
	plate.material_override = brass_mat
	plate.position = Vector3(0, 5.50, 0)
	pivot.add_child(plate)
	# 8 glowing amber letters (forge side)
	for i in 8:
		var lx: float = -1.65 + float(i) * 0.47
		var letter: MeshInstance3D = MeshInstance3D.new()
		var lm: BoxMesh = BoxMesh.new()
		lm.size = Vector3(0.26, 0.50, 0.06)
		letter.mesh = lm
		letter.material_override = amber_mat
		letter.position = Vector3(lx, 5.50, -0.12)
		pivot.add_child(letter)
	# 2 brass support chains
	for cx in [-1.80, 1.80]:
		var chain: MeshInstance3D = MeshInstance3D.new()
		var chmm: CylinderMesh = CylinderMesh.new()
		chmm.top_radius = 0.04
		chmm.bottom_radius = 0.04
		chmm.height = 1.10
		chain.mesh = chmm
		chain.material_override = iron_mat
		chain.position = Vector3(cx, 6.30, 0)
		pivot.add_child(chain)
	# ---- 2 hanging brass coin pendants from the crossbar (forge-side decoration) ----
	for cnx in [-3.50, 3.50]:
		var pendant_chain: MeshInstance3D = MeshInstance3D.new()
		var pcm: CylinderMesh = CylinderMesh.new()
		pcm.top_radius = 0.025
		pcm.bottom_radius = 0.025
		pcm.height = 0.55
		pendant_chain.mesh = pcm
		pendant_chain.material_override = iron_mat
		pendant_chain.position = Vector3(cnx, 6.55, 0)
		pivot.add_child(pendant_chain)
		var coin: MeshInstance3D = MeshInstance3D.new()
		var cnm: CylinderMesh = CylinderMesh.new()
		cnm.top_radius = 0.16
		cnm.bottom_radius = 0.16
		cnm.height = 0.05
		coin.mesh = cnm
		coin.material_override = brass_mat
		coin.position = Vector3(cnx, 6.20, 0)
		coin.rotation.x = PI / 2.0
		pivot.add_child(coin)
	# ---- Pulses ----
	var lpulse: Tween = pivot.create_tween().set_loops()
	lpulse.tween_property(amber_mat, "emission_energy_multiplier", 8.5, 1.8).set_ease(Tween.EASE_IN_OUT)
	lpulse.tween_property(amber_mat, "emission_energy_multiplier", 5.0, 1.8).set_ease(Tween.EASE_IN_OUT)
	var fpulse: Tween = pivot.create_tween().set_loops()
	fpulse.tween_property(flame_mat, "emission_energy_multiplier", 10.5, 0.5).set_ease(Tween.EASE_IN_OUT)
	fpulse.tween_property(flame_mat, "emission_energy_multiplier", 7.0, 0.5).set_ease(Tween.EASE_IN_OUT)


func _build_th_patrol_guard_npc(town: Node) -> void:
	## Epic-10 T38: Patrol Guard Drift — city guard NPC who walks a slow
	## circular patrol path around the plaza using an orbit pivot tween.
	## Iron breastplate + brass shoulder pauldrons, brass helm with
	## crown ridge + glowing visor, halberd held in right hand. Orbit
	## pivot rotates so the guard walks the perimeter loop.
	var slots: Node3D = town.get_node_or_null("NPCSlots") as Node3D
	if slots == null:
		return
	# An orbit pivot is the slot — the npc is offset from it so rotating
	# the orbit pivot moves the npc around the plaza in a circle.
	var orbit_slot: Marker3D = Marker3D.new()
	orbit_slot.name = "THPatrolGuardOrbit"
	orbit_slot.position = TOWN_CENTER + Vector3(0, 0, 0)
	slots.add_child(orbit_slot)
	var npc_scene: PackedScene = load("res://scenes/entities/npcs/VillagerR3.tscn") as PackedScene
	if npc_scene == null:
		return
	var npc: Node3D = npc_scene.instantiate() as Node3D
	npc.name = "THPatrolGuardDrift"
	if "npc_name" in npc:
		npc.set("npc_name", "Patrol Guard Drift")
	if "npc_id" in npc:
		npc.set("npc_id", "th_patrol_guard_drift")
	# Offset the npc from the orbit center along +X so rotation makes a circle
	npc.position = Vector3(10.50, 0, 0)
	# Face perpendicular to the radial (so the guard walks forward along the loop)
	npc.rotation.y = -PI / 2.0
	orbit_slot.add_child(npc)
	# Materials
	var iron_mat: StandardMaterial3D = StandardMaterial3D.new()
	iron_mat.albedo_color = Color(0.18, 0.16, 0.18)
	iron_mat.metallic = 0.85
	iron_mat.roughness = 0.45
	iron_mat.emission_enabled = true
	iron_mat.emission = Color(0.45, 0.55, 0.65)
	iron_mat.emission_energy_multiplier = 0.30
	var brass_mat: StandardMaterial3D = StandardMaterial3D.new()
	brass_mat.albedo_color = Color(0.85, 0.55, 0.18)
	brass_mat.metallic = 0.95
	brass_mat.roughness = 0.30
	brass_mat.emission_enabled = true
	brass_mat.emission = Color(1.0, 0.50, 0.10)
	brass_mat.emission_energy_multiplier = 0.55
	var data_mat: StandardMaterial3D = StandardMaterial3D.new()
	data_mat.albedo_color = Color(0.45, 0.85, 1.0)
	data_mat.emission_enabled = true
	data_mat.emission = Color(0.45, 0.85, 1.0)
	data_mat.emission_energy_multiplier = 7.0
	data_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	# ---- Iron breastplate body ----
	var torso: MeshInstance3D = MeshInstance3D.new()
	var tm: BoxMesh = BoxMesh.new()
	tm.size = Vector3(1.05, 1.30, 0.55)
	torso.mesh = tm
	torso.material_override = iron_mat
	torso.position = Vector3(0, 1.20, 0)
	npc.add_child(torso)
	# Brass chest seam
	var seam: MeshInstance3D = MeshInstance3D.new()
	var seamesh: BoxMesh = BoxMesh.new()
	seamesh.size = Vector3(0.18, 1.20, 0.06)
	seam.mesh = seamesh
	seam.material_override = brass_mat
	seam.position = Vector3(0, 1.20, -0.30)
	npc.add_child(seam)
	# Glowing chest core
	var core: MeshInstance3D = MeshInstance3D.new()
	var ccm: SphereMesh = SphereMesh.new()
	ccm.radius = 0.10
	ccm.height = 0.20
	core.mesh = ccm
	core.material_override = data_mat
	core.position = Vector3(0, 1.40, -0.32)
	npc.add_child(core)
	# Brass shoulder pauldrons
	for sx in [-0.65, 0.65]:
		var paul: MeshInstance3D = MeshInstance3D.new()
		var pm: SphereMesh = SphereMesh.new()
		pm.radius = 0.25
		pm.height = 0.45
		paul.mesh = pm
		paul.material_override = brass_mat
		paul.position = Vector3(sx, 1.80, 0)
		paul.scale = Vector3(1.0, 0.55, 1.0)
		npc.add_child(paul)
	# Leather waist belt + brass buckle
	var leather_mat: StandardMaterial3D = StandardMaterial3D.new()
	leather_mat.albedo_color = Color(0.30, 0.18, 0.10)
	leather_mat.roughness = 0.85
	leather_mat.metallic = 0.10
	var belt: MeshInstance3D = MeshInstance3D.new()
	var btm: BoxMesh = BoxMesh.new()
	btm.size = Vector3(1.10, 0.18, 0.60)
	belt.mesh = btm
	belt.material_override = leather_mat
	belt.position = Vector3(0, 0.65, 0)
	npc.add_child(belt)
	var buckle: MeshInstance3D = MeshInstance3D.new()
	var bkm: BoxMesh = BoxMesh.new()
	bkm.size = Vector3(0.20, 0.18, 0.06)
	buckle.mesh = bkm
	buckle.material_override = brass_mat
	buckle.position = Vector3(0, 0.65, -0.32)
	npc.add_child(buckle)
	# ---- Brass helm ----
	var helm: MeshInstance3D = MeshInstance3D.new()
	var hmm: BoxMesh = BoxMesh.new()
	hmm.size = Vector3(0.65, 0.65, 0.65)
	helm.mesh = hmm
	helm.material_override = iron_mat
	helm.position = Vector3(0, 2.15, 0)
	npc.add_child(helm)
	# Helm crown ridge prism
	var crown_ridge: MeshInstance3D = MeshInstance3D.new()
	var crm: PrismMesh = PrismMesh.new()
	crm.size = Vector3(0.20, 0.20, 0.65)
	crown_ridge.mesh = crm
	crown_ridge.material_override = brass_mat
	crown_ridge.position = Vector3(0, 2.55, 0)
	npc.add_child(crown_ridge)
	# Glowing visor slit
	var visor: MeshInstance3D = MeshInstance3D.new()
	var vm: BoxMesh = BoxMesh.new()
	vm.size = Vector3(0.45, 0.08, 0.04)
	visor.mesh = vm
	visor.material_override = data_mat
	visor.position = Vector3(0, 2.18, -0.34)
	npc.add_child(visor)
	# ---- Left arm at his side ----
	var left_arm: MeshInstance3D = MeshInstance3D.new()
	var lam: BoxMesh = BoxMesh.new()
	lam.size = Vector3(0.20, 0.85, 0.20)
	left_arm.mesh = lam
	left_arm.material_override = iron_mat
	left_arm.position = Vector3(-0.65, 1.20, 0)
	npc.add_child(left_arm)
	# ---- Right arm holding a halberd ----
	var right_arm: MeshInstance3D = MeshInstance3D.new()
	var ram: BoxMesh = BoxMesh.new()
	ram.size = Vector3(0.20, 0.85, 0.20)
	right_arm.mesh = ram
	right_arm.material_override = iron_mat
	right_arm.position = Vector3(0.65, 1.20, 0)
	npc.add_child(right_arm)
	# Halberd shaft (long wooden cylinder held vertically)
	var wood_mat: StandardMaterial3D = StandardMaterial3D.new()
	wood_mat.albedo_color = Color(0.32, 0.20, 0.12)
	wood_mat.roughness = 0.85
	var shaft: MeshInstance3D = MeshInstance3D.new()
	var shm: CylinderMesh = CylinderMesh.new()
	shm.top_radius = 0.06
	shm.bottom_radius = 0.07
	shm.height = 2.65
	shaft.mesh = shm
	shaft.material_override = wood_mat
	shaft.position = Vector3(0.85, 1.30, 0)
	npc.add_child(shaft)
	# Halberd brass binding rings
	for hy in [0.50, 1.30, 2.10]:
		var ring: MeshInstance3D = MeshInstance3D.new()
		var rmm: TorusMesh = TorusMesh.new()
		rmm.inner_radius = 0.07
		rmm.outer_radius = 0.10
		ring.mesh = rmm
		ring.material_override = brass_mat
		ring.position = Vector3(0.85, hy, 0)
		npc.add_child(ring)
	# Halberd head — wide axe blade prism
	var blade: MeshInstance3D = MeshInstance3D.new()
	var blm: PrismMesh = PrismMesh.new()
	blm.size = Vector3(0.45, 0.55, 0.10)
	blade.mesh = blm
	blade.material_override = iron_mat
	blade.position = Vector3(1.10, 2.40, 0)
	blade.rotation.z = -PI / 2.0
	npc.add_child(blade)
	# Halberd top spike (thin prism)
	var spike: MeshInstance3D = MeshInstance3D.new()
	var spm: PrismMesh = PrismMesh.new()
	spm.size = Vector3(0.10, 0.45, 0.10)
	spike.mesh = spm
	spike.material_override = iron_mat
	spike.position = Vector3(0.85, 2.85, 0)
	npc.add_child(spike)
	# Glowing data spike tip dot
	var spike_tip: MeshInstance3D = MeshInstance3D.new()
	var stm: SphereMesh = SphereMesh.new()
	stm.radius = 0.06
	stm.height = 0.12
	spike_tip.mesh = stm
	spike_tip.material_override = data_mat
	spike_tip.position = Vector3(0.85, 3.10, 0)
	npc.add_child(spike_tip)
	# ---- Subtle warm OmniLight ----
	var lt: OmniLight3D = OmniLight3D.new()
	lt.position = Vector3(0, 1.70, -0.20)
	lt.light_color = Color(0.65, 0.85, 1.0)
	lt.light_energy = 1.6
	lt.omni_range = 4.5
	npc.add_child(lt)
	# ---- Patrol orbit tween — orbit_slot rotates around Y so the guard
	# walks a circle around the plaza at radius 10.5 (between benches and lampposts).
	# Slow period (~30s) for a leisurely patrol pace.
	var patrol: Tween = npc.create_tween().set_loops()
	patrol.tween_property(orbit_slot, "rotation:y", TAU, 32.0)
	# Chest core + visor + spike tip pulse
	var dpulse: Tween = npc.create_tween().set_loops()
	dpulse.tween_property(data_mat, "emission_energy_multiplier", 9.0, 1.8).set_ease(Tween.EASE_IN_OUT)
	dpulse.tween_property(data_mat, "emission_energy_multiplier", 5.0, 1.8).set_ease(Tween.EASE_IN_OUT)


func _build_th_running_child_npc(town: Node) -> void:
	## Epic-10 T39: Running Child Echo — small playful child NPC running
	## in a tighter inner orbit (radius ~8.5) faster than the patrol guard
	## (~12s loop) and in the OPPOSITE direction. Bright orange tunic with
	## brass collar, two short stubby legs, head with cyan crown band,
	## tiny brass bell held in right hand jingling as she runs.
	var slots: Node3D = town.get_node_or_null("NPCSlots") as Node3D
	if slots == null:
		return
	# Orbit pivot for the child's running circle
	var orbit_slot: Marker3D = Marker3D.new()
	orbit_slot.name = "THRunningChildOrbit"
	orbit_slot.position = TOWN_CENTER + Vector3(0, 0, 0)
	# Start at a different phase than the guard so they don't overlap
	orbit_slot.rotation.y = PI
	slots.add_child(orbit_slot)
	var npc_scene: PackedScene = load("res://scenes/entities/npcs/VillagerR3.tscn") as PackedScene
	if npc_scene == null:
		return
	var npc: Node3D = npc_scene.instantiate() as Node3D
	npc.name = "THRunningChildEcho"
	if "npc_name" in npc:
		npc.set("npc_name", "Echo (child)")
	if "npc_id" in npc:
		npc.set("npc_id", "th_running_child_echo")
	# Offset the child from the orbit center along +X (radius 8.5)
	npc.position = Vector3(8.50, 0, 0)
	# Face the orbit forward direction
	npc.rotation.y = PI / 2.0
	orbit_slot.add_child(npc)
	# Materials
	var tunic_mat: StandardMaterial3D = StandardMaterial3D.new()
	tunic_mat.albedo_color = Color(1.0, 0.55, 0.18)
	tunic_mat.roughness = 0.85
	tunic_mat.metallic = 0.10
	tunic_mat.emission_enabled = true
	tunic_mat.emission = Color(1.0, 0.55, 0.10)
	tunic_mat.emission_energy_multiplier = 0.45
	var brass_mat: StandardMaterial3D = StandardMaterial3D.new()
	brass_mat.albedo_color = Color(0.85, 0.55, 0.18)
	brass_mat.metallic = 0.95
	brass_mat.roughness = 0.30
	brass_mat.emission_enabled = true
	brass_mat.emission = Color(1.0, 0.50, 0.10)
	brass_mat.emission_energy_multiplier = 0.55
	var data_mat: StandardMaterial3D = StandardMaterial3D.new()
	data_mat.albedo_color = Color(0.45, 0.85, 1.0)
	data_mat.emission_enabled = true
	data_mat.emission = Color(0.45, 0.85, 1.0)
	data_mat.emission_energy_multiplier = 6.5
	data_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	# ---- Bright orange tunic body (smaller than adult NPCs) ----
	var tunic: MeshInstance3D = MeshInstance3D.new()
	var tmesh: BoxMesh = BoxMesh.new()
	tmesh.size = Vector3(0.65, 0.85, 0.40)
	tunic.mesh = tmesh
	tunic.material_override = tunic_mat
	tunic.position = Vector3(0, 0.85, 0)
	npc.add_child(tunic)
	# Brass collar trim
	var collar: MeshInstance3D = MeshInstance3D.new()
	var colm: BoxMesh = BoxMesh.new()
	colm.size = Vector3(0.65, 0.08, 0.40)
	collar.mesh = colm
	collar.material_override = brass_mat
	collar.position = Vector3(0, 1.30, 0)
	npc.add_child(collar)
	# Belt rope
	var belt: MeshInstance3D = MeshInstance3D.new()
	var btm: BoxMesh = BoxMesh.new()
	btm.size = Vector3(0.70, 0.08, 0.45)
	belt.mesh = btm
	belt.material_override = brass_mat
	belt.position = Vector3(0, 0.55, 0)
	npc.add_child(belt)
	# ---- 2 stubby legs (small boxes) on a leg pivot for run animation ----
	var leg_pivot: Node3D = Node3D.new()
	leg_pivot.position = Vector3(0, 0.30, 0)
	npc.add_child(leg_pivot)
	# Left leg
	var l_leg: MeshInstance3D = MeshInstance3D.new()
	var llm: BoxMesh = BoxMesh.new()
	llm.size = Vector3(0.20, 0.40, 0.20)
	l_leg.mesh = llm
	l_leg.material_override = tunic_mat
	l_leg.position = Vector3(-0.18, -0.05, 0)
	leg_pivot.add_child(l_leg)
	# Right leg (separate so we can swap heights for run feel)
	var r_leg: MeshInstance3D = MeshInstance3D.new()
	r_leg.mesh = llm
	r_leg.material_override = tunic_mat
	r_leg.position = Vector3(0.18, -0.05, 0)
	leg_pivot.add_child(r_leg)
	# ---- Head sphere ----
	var head: MeshInstance3D = MeshInstance3D.new()
	var hmm: SphereMesh = SphereMesh.new()
	hmm.radius = 0.22
	hmm.height = 0.44
	head.mesh = hmm
	head.material_override = tunic_mat
	head.position = Vector3(0, 1.55, 0)
	npc.add_child(head)
	# Cyan crown band torus on the head
	var crown: MeshInstance3D = MeshInstance3D.new()
	var crm: TorusMesh = TorusMesh.new()
	crm.inner_radius = 0.22
	crm.outer_radius = 0.27
	crown.mesh = crm
	crown.material_override = data_mat
	crown.position = Vector3(0, 1.55, 0)
	crown.rotation.x = PI / 2.0
	npc.add_child(crown)
	# 2 small dark eye dots on the front of the head
	for ex in [-0.07, 0.07]:
		var eye: MeshInstance3D = MeshInstance3D.new()
		var em: SphereMesh = SphereMesh.new()
		em.radius = 0.04
		em.height = 0.08
		eye.mesh = em
		eye.material_override = brass_mat
		eye.position = Vector3(ex, 1.58, -0.20)
		npc.add_child(eye)
	# ---- Tiny brass bell held in right hand on a jingle pivot ----
	var bell_pivot: Node3D = Node3D.new()
	bell_pivot.position = Vector3(0.40, 0.95, 0)
	npc.add_child(bell_pivot)
	var bell: MeshInstance3D = MeshInstance3D.new()
	var blm: SphereMesh = SphereMesh.new()
	blm.radius = 0.10
	blm.height = 0.18
	bell.mesh = blm
	bell.material_override = brass_mat
	bell.position = Vector3(0, -0.10, 0)
	bell.scale = Vector3(0.95, 1.20, 0.95)
	bell_pivot.add_child(bell)
	# Bell glowing dot on the bottom
	var bell_dot: MeshInstance3D = MeshInstance3D.new()
	var bdm: SphereMesh = SphereMesh.new()
	bdm.radius = 0.04
	bdm.height = 0.08
	bell_dot.mesh = bdm
	bell_dot.material_override = data_mat
	bell_dot.position = Vector3(0, -0.20, 0)
	bell_pivot.add_child(bell_dot)
	# ---- Subtle warm OmniLight (smaller, since the child is smaller) ----
	var lt: OmniLight3D = OmniLight3D.new()
	lt.position = Vector3(0, 1.20, 0)
	lt.light_color = Color(1.0, 0.65, 0.20)
	lt.light_energy = 1.2
	lt.omni_range = 3.5
	npc.add_child(lt)
	# ---- Run orbit tween — orbit_slot rotates around Y in 12 seconds, COUNTER-CLOCKWISE
	# (negative TAU) so the child runs in the opposite direction from the guard.
	var run: Tween = npc.create_tween().set_loops()
	run.tween_property(orbit_slot, "rotation:y", PI - TAU, 12.0)
	# ---- Run leg pivot bob — vertical hop while running ----
	var hop: Tween = npc.create_tween().set_loops()
	hop.tween_property(npc, "position:y", 0.18, 0.30).set_ease(Tween.EASE_OUT)
	hop.tween_property(npc, "position:y", 0.0, 0.30).set_ease(Tween.EASE_IN)
	# ---- Bell jingle tween — fast left-right rotation ----
	var jingle: Tween = npc.create_tween().set_loops()
	jingle.tween_property(bell_pivot, "rotation:z", 0.40, 0.18).set_ease(Tween.EASE_IN_OUT)
	jingle.tween_property(bell_pivot, "rotation:z", -0.40, 0.18).set_ease(Tween.EASE_IN_OUT)
	# Crown + bell dot pulse
	var dpulse2: Tween = npc.create_tween().set_loops()
	dpulse2.tween_property(data_mat, "emission_energy_multiplier", 8.5, 1.4).set_ease(Tween.EASE_IN_OUT)
	dpulse2.tween_property(data_mat, "emission_energy_multiplier", 5.0, 1.4).set_ease(Tween.EASE_IN_OUT)


func _build_th_sky_data_highway(geom: Node) -> void:
	## Epic-10 T40: 2 long glowing cyan data lines stretching diagonally
	## over the plaza connecting the 4 corner towers in an X pattern
	## (NE bell tower ↔ SW forge brazier, NW archive tower ↔ SE observatory).
	## Each line is a long thin glowing cyan box rotated to align with its
	## endpoints, with a beam particle emitter at each endpoint sending
	## data packets along the line.
	var pivot: Node3D = Node3D.new()
	pivot.name = "TH_SkyDataHighway"
	pivot.position = TOWN_CENTER + Vector3(0, 0, 0)
	geom.add_child(pivot)
	# Materials
	var data_mat: StandardMaterial3D = StandardMaterial3D.new()
	data_mat.albedo_color = Color(0.45, 0.85, 1.0)
	data_mat.emission_enabled = true
	data_mat.emission = Color(0.45, 0.85, 1.0)
	data_mat.emission_energy_multiplier = 6.5
	data_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	# Corner tower endpoints (matching T26-T29 positions at radius 16.5)
	# NE bell tower
	var ne: Vector3 = Vector3(cos(PI / 4.0) * 16.50, 18.0, sin(PI / 4.0) * 16.50)
	# NW archive tower
	var nw: Vector3 = Vector3(cos(3.0 * PI / 4.0) * 16.50, 16.0, sin(3.0 * PI / 4.0) * 16.50)
	# SW forge brazier monument
	var sw: Vector3 = Vector3(cos(5.0 * PI / 4.0) * 16.50, 7.0, sin(5.0 * PI / 4.0) * 16.50)
	# SE observatory dome
	var se: Vector3 = Vector3(cos(7.0 * PI / 4.0) * 16.50, 4.0, sin(7.0 * PI / 4.0) * 16.50)
	# 2 diagonal beam pairs
	var beam_pairs: Array = [
		[ne, sw],  # NE bell tower → SW forge brazier
		[nw, se],  # NW archive tower → SE observatory
	]
	for pair in beam_pairs:
		var a: Vector3 = pair[0]
		var b: Vector3 = pair[1]
		var mid: Vector3 = (a + b) * 0.5
		var diff: Vector3 = b - a
		var span: float = diff.length()
		# Beam line (long thin glowing cyan box rotated to align with the diagonal)
		var beam: MeshInstance3D = MeshInstance3D.new()
		var bm: BoxMesh = BoxMesh.new()
		bm.size = Vector3(span, 0.18, 0.18)
		beam.mesh = bm
		beam.material_override = data_mat
		beam.position = mid
		# Rotate the beam so its X axis aligns with the diagonal
		beam.look_at_from_position(mid, b, Vector3.UP)
		beam.rotation.y += PI / 2.0
		pivot.add_child(beam)
		# Data packet particles flowing along the beam from A → B
		var packets: GPUParticles3D = GPUParticles3D.new()
		packets.position = a
		packets.amount = 18
		packets.lifetime = max(span / 6.0, 4.0)
		var pmat: ParticleProcessMaterial = ParticleProcessMaterial.new()
		pmat.direction = (b - a).normalized()
		pmat.spread = 4.0
		pmat.initial_velocity_min = 5.0
		pmat.initial_velocity_max = 6.5
		pmat.gravity = Vector3(0, 0, 0)
		pmat.scale_min = 0.18
		pmat.scale_max = 0.30
		pmat.color = Color(0.55, 0.95, 1.0, 1.0)
		packets.process_material = pmat
		var psmesh: SphereMesh = SphereMesh.new()
		psmesh.radius = 0.10
		psmesh.height = 0.20
		packets.draw_pass_1 = psmesh
		pivot.add_child(packets)
		# Reverse data flow B → A using a second emitter
		var packets_rev: GPUParticles3D = GPUParticles3D.new()
		packets_rev.position = b
		packets_rev.amount = 18
		packets_rev.lifetime = max(span / 6.0, 4.0)
		var prmat: ParticleProcessMaterial = ParticleProcessMaterial.new()
		prmat.direction = (a - b).normalized()
		prmat.spread = 4.0
		prmat.initial_velocity_min = 5.0
		prmat.initial_velocity_max = 6.5
		prmat.gravity = Vector3(0, 0, 0)
		prmat.scale_min = 0.18
		prmat.scale_max = 0.30
		prmat.color = Color(0.95, 0.55, 0.20, 1.0)  # warm amber for reverse direction
		packets_rev.process_material = prmat
		packets_rev.draw_pass_1 = psmesh
		pivot.add_child(packets_rev)
	# Shared beam pulse
	var bpulse: Tween = pivot.create_tween().set_loops()
	bpulse.tween_property(data_mat, "emission_energy_multiplier", 8.5, 1.8).set_ease(Tween.EASE_IN_OUT)
	bpulse.tween_property(data_mat, "emission_energy_multiplier", 5.0, 1.8).set_ease(Tween.EASE_IN_OUT)


func _build_th_east_approach_road(geom: Node) -> void:
	## Epic-10 T41: long paved approach road extending east from the welcome
	## arch toward D1 East Plaza. 8 wide road slabs laid in a row, with a
	## glowing cyan center seam stripe down the middle. 6 small flanking
	## lampposts (3 per side) along the road. Bridges the Town Heart and
	## D1 visually for travelers.
	var pivot: Node3D = Node3D.new()
	pivot.name = "TH_EastApproachRoad"
	# Start just past the welcome arch (E radial outer rim ~16.5)
	pivot.position = TOWN_CENTER + Vector3(17.50, 0, 0)
	geom.add_child(pivot)
	# Materials
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.22, 0.24, 0.28)
	stone_mat.metallic = 0.18
	stone_mat.roughness = 0.85
	stone_mat.emission_enabled = true
	stone_mat.emission = Color(0.30, 0.45, 0.60)
	stone_mat.emission_energy_multiplier = 0.18
	var brass_mat: StandardMaterial3D = StandardMaterial3D.new()
	brass_mat.albedo_color = Color(0.85, 0.55, 0.18)
	brass_mat.metallic = 0.95
	brass_mat.roughness = 0.30
	brass_mat.emission_enabled = true
	brass_mat.emission = Color(1.0, 0.50, 0.10)
	brass_mat.emission_energy_multiplier = 0.55
	var seam_mat: StandardMaterial3D = StandardMaterial3D.new()
	seam_mat.albedo_color = Color(0.45, 0.85, 1.0)
	seam_mat.emission_enabled = true
	seam_mat.emission = Color(0.45, 0.85, 1.0)
	seam_mat.emission_energy_multiplier = 5.5
	seam_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var bulb_mat: StandardMaterial3D = StandardMaterial3D.new()
	bulb_mat.albedo_color = Color(1.0, 0.75, 0.30)
	bulb_mat.emission_enabled = true
	bulb_mat.emission = Color(1.0, 0.65, 0.20)
	bulb_mat.emission_energy_multiplier = 8.5
	bulb_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	# ---- 8 wide road slabs laid in a row going east (+X), each 3.5m long ----
	for i in 8:
		var sx: float = float(i) * 3.50
		# Road slab
		var slab: MeshInstance3D = MeshInstance3D.new()
		var sm: BoxMesh = BoxMesh.new()
		sm.size = Vector3(3.50, 0.10, 4.20)
		slab.mesh = sm
		slab.material_override = stone_mat
		slab.position = Vector3(sx, 0.05, 0)
		pivot.add_child(slab)
		# Slab collision (so player has solid ground)
		var sb: StaticBody3D = StaticBody3D.new()
		sb.position = Vector3(sx, 0.05, 0)
		var cs: CollisionShape3D = CollisionShape3D.new()
		var bsh: BoxShape3D = BoxShape3D.new()
		bsh.size = Vector3(3.50, 0.20, 4.20)
		cs.shape = bsh
		sb.add_child(cs)
		pivot.add_child(sb)
		# Brass slab edge trim (front + back of each slab)
		for tz in [-2.05, 2.05]:
			var trim: MeshInstance3D = MeshInstance3D.new()
			var tmm: BoxMesh = BoxMesh.new()
			tmm.size = Vector3(3.50, 0.10, 0.18)
			trim.mesh = tmm
			trim.material_override = brass_mat
			trim.position = Vector3(sx, 0.10, tz)
			pivot.add_child(trim)
		# Center seam stripe (glowing cyan box down the middle of each slab)
		var seam: MeshInstance3D = MeshInstance3D.new()
		var seamesh: BoxMesh = BoxMesh.new()
		seamesh.size = Vector3(3.20, 0.06, 0.30)
		seam.mesh = seamesh
		seam.material_override = seam_mat
		seam.position = Vector3(sx, 0.13, 0)
		pivot.add_child(seam)
	# ---- 6 flanking lampposts (3 per side) along the road ----
	# Spacing: every other slab (4 segments along ~28m road length)
	var lamp_xs: Array = [3.5, 14.0, 24.5]
	for lx in lamp_xs:
		for sz in [-2.50, 2.50]:
			var lgroup: Node3D = Node3D.new()
			lgroup.position = Vector3(lx, 0, sz)
			pivot.add_child(lgroup)
			# Stepped basalt base
			var base: MeshInstance3D = MeshInstance3D.new()
			var bm: BoxMesh = BoxMesh.new()
			bm.size = Vector3(0.65, 0.30, 0.65)
			base.mesh = bm
			base.material_override = stone_mat
			base.position = Vector3(0, 0.15, 0)
			lgroup.add_child(base)
			# Brass shaft (3.8m, slightly shorter than the plaza lampposts)
			var shaft: MeshInstance3D = MeshInstance3D.new()
			var smm: CylinderMesh = CylinderMesh.new()
			smm.top_radius = 0.08
			smm.bottom_radius = 0.12
			smm.height = 3.80
			shaft.mesh = smm
			shaft.material_override = brass_mat
			shaft.position = Vector3(0, 2.20, 0)
			lgroup.add_child(shaft)
			# Shaft collision
			var shaft_sb: StaticBody3D = StaticBody3D.new()
			shaft_sb.position = Vector3(0, 2.20, 0)
			var shaft_cs: CollisionShape3D = CollisionShape3D.new()
			var shaft_cyl: CylinderShape3D = CylinderShape3D.new()
			shaft_cyl.top_radius = 0.10
			shaft_cyl.bottom_radius = 0.12
			shaft_cyl.height = 3.80
			shaft_cs.shape = shaft_cyl
			shaft_sb.add_child(shaft_cs)
			lgroup.add_child(shaft_sb)
			# Brass mid band wrap
			var band: MeshInstance3D = MeshInstance3D.new()
			var bdm: TorusMesh = TorusMesh.new()
			bdm.inner_radius = 0.10
			bdm.outer_radius = 0.16
			band.mesh = bdm
			band.material_override = brass_mat
			band.position = Vector3(0, 2.40, 0)
			lgroup.add_child(band)
			# Brass arched top crossbar extending inward (toward the road centerline)
			var inner_z: float = 0.0 if sz > 0 else 0.0
			# Bracket
			var arch: MeshInstance3D = MeshInstance3D.new()
			var am: BoxMesh = BoxMesh.new()
			am.size = Vector3(0.10, 0.10, 0.65)
			arch.mesh = am
			arch.material_override = brass_mat
			# Position toward road centerline (negate sz to point inward)
			arch.position = Vector3(0, 4.20, -sz * 0.30)
			lgroup.add_child(arch)
			# Lantern bulb at the inner end of the arch
			var bulb: MeshInstance3D = MeshInstance3D.new()
			var blm: SphereMesh = SphereMesh.new()
			blm.radius = 0.20
			blm.height = 0.40
			bulb.mesh = blm
			bulb.material_override = bulb_mat
			bulb.position = Vector3(0, 4.05, -sz * 0.55)
			lgroup.add_child(bulb)
			# Lantern OmniLight
			var lt: OmniLight3D = OmniLight3D.new()
			lt.position = Vector3(0, 4.05, -sz * 0.55)
			lt.light_color = Color(1.0, 0.65, 0.20)
			lt.light_energy = 3.5
			lt.omni_range = 11.0
			lgroup.add_child(lt)
	# Slow seam pulse + bulb pulse
	var spulse: Tween = pivot.create_tween().set_loops()
	spulse.tween_property(seam_mat, "emission_energy_multiplier", 7.0, 2.0).set_ease(Tween.EASE_IN_OUT)
	spulse.tween_property(seam_mat, "emission_energy_multiplier", 4.0, 2.0).set_ease(Tween.EASE_IN_OUT)
	var bpulse2: Tween = pivot.create_tween().set_loops()
	bpulse2.tween_property(bulb_mat, "emission_energy_multiplier", 10.5, 1.5).set_ease(Tween.EASE_IN_OUT)
	bpulse2.tween_property(bulb_mat, "emission_energy_multiplier", 7.0, 1.5).set_ease(Tween.EASE_IN_OUT)


func _build_th_north_approach_road(geom: Node) -> void:
	## Epic-10 T42: long paved approach road extending north from the
	## north entry arch. Mirrors the east approach road but rotated 90°
	## so the road runs along -Z. 8 stone road slabs, brass edge trim,
	## glowing cyan center seam, and 6 flanking lampposts.
	var pivot: Node3D = Node3D.new()
	pivot.name = "TH_NorthApproachRoad"
	# Start just past the north entry arch outer rim (~-17.5)
	pivot.position = TOWN_CENTER + Vector3(0, 0, -17.50)
	geom.add_child(pivot)
	# Materials
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.22, 0.24, 0.28)
	stone_mat.metallic = 0.18
	stone_mat.roughness = 0.85
	stone_mat.emission_enabled = true
	stone_mat.emission = Color(0.30, 0.45, 0.60)
	stone_mat.emission_energy_multiplier = 0.18
	var brass_mat: StandardMaterial3D = StandardMaterial3D.new()
	brass_mat.albedo_color = Color(0.85, 0.55, 0.18)
	brass_mat.metallic = 0.95
	brass_mat.roughness = 0.30
	brass_mat.emission_enabled = true
	brass_mat.emission = Color(1.0, 0.50, 0.10)
	brass_mat.emission_energy_multiplier = 0.55
	var seam_mat: StandardMaterial3D = StandardMaterial3D.new()
	seam_mat.albedo_color = Color(0.45, 0.85, 1.0)
	seam_mat.emission_enabled = true
	seam_mat.emission = Color(0.45, 0.85, 1.0)
	seam_mat.emission_energy_multiplier = 5.5
	seam_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var bulb_mat: StandardMaterial3D = StandardMaterial3D.new()
	bulb_mat.albedo_color = Color(1.0, 0.75, 0.30)
	bulb_mat.emission_enabled = true
	bulb_mat.emission = Color(1.0, 0.65, 0.20)
	bulb_mat.emission_energy_multiplier = 8.5
	bulb_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	# ---- 8 wide road slabs laid in a row going north (-Z), each 3.5m long ----
	for i in 8:
		var sz: float = -float(i) * 3.50
		# Road slab — flipped: longer in Z (road direction), wider in X
		var slab: MeshInstance3D = MeshInstance3D.new()
		var sm: BoxMesh = BoxMesh.new()
		sm.size = Vector3(4.20, 0.10, 3.50)
		slab.mesh = sm
		slab.material_override = stone_mat
		slab.position = Vector3(0, 0.05, sz)
		pivot.add_child(slab)
		# Slab collision
		var sb: StaticBody3D = StaticBody3D.new()
		sb.position = Vector3(0, 0.05, sz)
		var cs: CollisionShape3D = CollisionShape3D.new()
		var bsh: BoxShape3D = BoxShape3D.new()
		bsh.size = Vector3(4.20, 0.20, 3.50)
		cs.shape = bsh
		sb.add_child(cs)
		pivot.add_child(sb)
		# Brass slab edge trim (left + right of each slab — perpendicular to road direction)
		for tx in [-2.05, 2.05]:
			var trim: MeshInstance3D = MeshInstance3D.new()
			var tmm: BoxMesh = BoxMesh.new()
			tmm.size = Vector3(0.18, 0.10, 3.50)
			trim.mesh = tmm
			trim.material_override = brass_mat
			trim.position = Vector3(tx, 0.10, sz)
			pivot.add_child(trim)
		# Center seam stripe (oriented along Z this time)
		var seam: MeshInstance3D = MeshInstance3D.new()
		var seamesh: BoxMesh = BoxMesh.new()
		seamesh.size = Vector3(0.30, 0.06, 3.20)
		seam.mesh = seamesh
		seam.material_override = seam_mat
		seam.position = Vector3(0, 0.13, sz)
		pivot.add_child(seam)
	# ---- 6 flanking lampposts (3 per side) along the road ----
	# Spacing along the road direction (-Z), placed at varied Z values
	var lamp_zs: Array = [-3.5, -14.0, -24.5]
	for lz in lamp_zs:
		for sx in [-2.50, 2.50]:
			var lgroup: Node3D = Node3D.new()
			lgroup.position = Vector3(sx, 0, lz)
			pivot.add_child(lgroup)
			# Stepped basalt base
			var base: MeshInstance3D = MeshInstance3D.new()
			var bm: BoxMesh = BoxMesh.new()
			bm.size = Vector3(0.65, 0.30, 0.65)
			base.mesh = bm
			base.material_override = stone_mat
			base.position = Vector3(0, 0.15, 0)
			lgroup.add_child(base)
			# Brass shaft (3.8m)
			var shaft: MeshInstance3D = MeshInstance3D.new()
			var smm: CylinderMesh = CylinderMesh.new()
			smm.top_radius = 0.08
			smm.bottom_radius = 0.12
			smm.height = 3.80
			shaft.mesh = smm
			shaft.material_override = brass_mat
			shaft.position = Vector3(0, 2.20, 0)
			lgroup.add_child(shaft)
			# Shaft collision
			var shaft_sb: StaticBody3D = StaticBody3D.new()
			shaft_sb.position = Vector3(0, 2.20, 0)
			var shaft_cs: CollisionShape3D = CollisionShape3D.new()
			var shaft_cyl: CylinderShape3D = CylinderShape3D.new()
			shaft_cyl.top_radius = 0.10
			shaft_cyl.bottom_radius = 0.12
			shaft_cyl.height = 3.80
			shaft_cs.shape = shaft_cyl
			shaft_sb.add_child(shaft_cs)
			lgroup.add_child(shaft_sb)
			# Brass mid band wrap
			var band: MeshInstance3D = MeshInstance3D.new()
			var bdm: TorusMesh = TorusMesh.new()
			bdm.inner_radius = 0.10
			bdm.outer_radius = 0.16
			band.mesh = bdm
			band.material_override = brass_mat
			band.position = Vector3(0, 2.40, 0)
			lgroup.add_child(band)
			# Arched top crossbar pointing inward (toward road centerline)
			var arch: MeshInstance3D = MeshInstance3D.new()
			var am: BoxMesh = BoxMesh.new()
			am.size = Vector3(0.65, 0.10, 0.10)
			arch.mesh = am
			arch.material_override = brass_mat
			arch.position = Vector3(-sx * 0.30, 4.20, 0)
			lgroup.add_child(arch)
			# Lantern bulb at the inner end of the arch
			var bulb: MeshInstance3D = MeshInstance3D.new()
			var blm: SphereMesh = SphereMesh.new()
			blm.radius = 0.20
			blm.height = 0.40
			bulb.mesh = blm
			bulb.material_override = bulb_mat
			bulb.position = Vector3(-sx * 0.55, 4.05, 0)
			lgroup.add_child(bulb)
			# Lantern OmniLight
			var lt: OmniLight3D = OmniLight3D.new()
			lt.position = Vector3(-sx * 0.55, 4.05, 0)
			lt.light_color = Color(1.0, 0.65, 0.20)
			lt.light_energy = 3.5
			lt.omni_range = 11.0
			lgroup.add_child(lt)
	# Slow seam pulse + bulb pulse
	var spulse: Tween = pivot.create_tween().set_loops()
	spulse.tween_property(seam_mat, "emission_energy_multiplier", 7.0, 2.0).set_ease(Tween.EASE_IN_OUT)
	spulse.tween_property(seam_mat, "emission_energy_multiplier", 4.0, 2.0).set_ease(Tween.EASE_IN_OUT)
	var bpulse: Tween = pivot.create_tween().set_loops()
	bpulse.tween_property(bulb_mat, "emission_energy_multiplier", 10.5, 1.5).set_ease(Tween.EASE_IN_OUT)
	bpulse.tween_property(bulb_mat, "emission_energy_multiplier", 7.0, 1.5).set_ease(Tween.EASE_IN_OUT)


func _build_th_west_approach_road(geom: Node) -> void:
	## Epic-10 T43: long paved approach road extending west from the
	## west entry arch (T31). Mirror of the east approach road but laid
	## along -X. 8 stone road slabs, brass edge trim, glowing cyan center
	## seam, and 6 flanking lampposts (3 per side).
	var pivot: Node3D = Node3D.new()
	pivot.name = "TH_WestApproachRoad"
	# Start just past the west entry arch outer rim (~-17.5)
	pivot.position = TOWN_CENTER + Vector3(-17.50, 0, 0)
	geom.add_child(pivot)
	# Materials
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.22, 0.24, 0.28)
	stone_mat.metallic = 0.18
	stone_mat.roughness = 0.85
	stone_mat.emission_enabled = true
	stone_mat.emission = Color(0.30, 0.45, 0.60)
	stone_mat.emission_energy_multiplier = 0.18
	var brass_mat: StandardMaterial3D = StandardMaterial3D.new()
	brass_mat.albedo_color = Color(0.85, 0.55, 0.18)
	brass_mat.metallic = 0.95
	brass_mat.roughness = 0.30
	brass_mat.emission_enabled = true
	brass_mat.emission = Color(1.0, 0.50, 0.10)
	brass_mat.emission_energy_multiplier = 0.55
	var seam_mat: StandardMaterial3D = StandardMaterial3D.new()
	seam_mat.albedo_color = Color(0.45, 0.85, 1.0)
	seam_mat.emission_enabled = true
	seam_mat.emission = Color(0.45, 0.85, 1.0)
	seam_mat.emission_energy_multiplier = 5.5
	seam_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var bulb_mat: StandardMaterial3D = StandardMaterial3D.new()
	bulb_mat.albedo_color = Color(1.0, 0.75, 0.30)
	bulb_mat.emission_enabled = true
	bulb_mat.emission = Color(1.0, 0.65, 0.20)
	bulb_mat.emission_energy_multiplier = 8.5
	bulb_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	# ---- 8 wide road slabs laid in a row going west (-X), each 3.5m long ----
	for i in 8:
		var sx: float = -float(i) * 3.50
		# Road slab
		var slab: MeshInstance3D = MeshInstance3D.new()
		var sm: BoxMesh = BoxMesh.new()
		sm.size = Vector3(3.50, 0.10, 4.20)
		slab.mesh = sm
		slab.material_override = stone_mat
		slab.position = Vector3(sx, 0.05, 0)
		pivot.add_child(slab)
		# Slab collision
		var sb: StaticBody3D = StaticBody3D.new()
		sb.position = Vector3(sx, 0.05, 0)
		var cs: CollisionShape3D = CollisionShape3D.new()
		var bsh: BoxShape3D = BoxShape3D.new()
		bsh.size = Vector3(3.50, 0.20, 4.20)
		cs.shape = bsh
		sb.add_child(cs)
		pivot.add_child(sb)
		# Brass slab edge trim (front + back)
		for tz in [-2.05, 2.05]:
			var trim: MeshInstance3D = MeshInstance3D.new()
			var tmm: BoxMesh = BoxMesh.new()
			tmm.size = Vector3(3.50, 0.10, 0.18)
			trim.mesh = tmm
			trim.material_override = brass_mat
			trim.position = Vector3(sx, 0.10, tz)
			pivot.add_child(trim)
		# Center seam stripe
		var seam: MeshInstance3D = MeshInstance3D.new()
		var seamesh: BoxMesh = BoxMesh.new()
		seamesh.size = Vector3(3.20, 0.06, 0.30)
		seam.mesh = seamesh
		seam.material_override = seam_mat
		seam.position = Vector3(sx, 0.13, 0)
		pivot.add_child(seam)
	# ---- 6 flanking lampposts (3 per side) along the road ----
	var lamp_xs: Array = [-3.5, -14.0, -24.5]
	for lx in lamp_xs:
		for sz in [-2.50, 2.50]:
			var lgroup: Node3D = Node3D.new()
			lgroup.position = Vector3(lx, 0, sz)
			pivot.add_child(lgroup)
			# Stepped basalt base
			var base: MeshInstance3D = MeshInstance3D.new()
			var bm: BoxMesh = BoxMesh.new()
			bm.size = Vector3(0.65, 0.30, 0.65)
			base.mesh = bm
			base.material_override = stone_mat
			base.position = Vector3(0, 0.15, 0)
			lgroup.add_child(base)
			# Brass shaft (3.8m)
			var shaft: MeshInstance3D = MeshInstance3D.new()
			var smm: CylinderMesh = CylinderMesh.new()
			smm.top_radius = 0.08
			smm.bottom_radius = 0.12
			smm.height = 3.80
			shaft.mesh = smm
			shaft.material_override = brass_mat
			shaft.position = Vector3(0, 2.20, 0)
			lgroup.add_child(shaft)
			# Shaft collision
			var shaft_sb: StaticBody3D = StaticBody3D.new()
			shaft_sb.position = Vector3(0, 2.20, 0)
			var shaft_cs: CollisionShape3D = CollisionShape3D.new()
			var shaft_cyl: CylinderShape3D = CylinderShape3D.new()
			shaft_cyl.top_radius = 0.10
			shaft_cyl.bottom_radius = 0.12
			shaft_cyl.height = 3.80
			shaft_cs.shape = shaft_cyl
			shaft_sb.add_child(shaft_cs)
			lgroup.add_child(shaft_sb)
			# Brass mid band wrap
			var band: MeshInstance3D = MeshInstance3D.new()
			var bdm: TorusMesh = TorusMesh.new()
			bdm.inner_radius = 0.10
			bdm.outer_radius = 0.16
			band.mesh = bdm
			band.material_override = brass_mat
			band.position = Vector3(0, 2.40, 0)
			lgroup.add_child(band)
			# Arched top crossbar pointing inward (toward road centerline)
			var arch: MeshInstance3D = MeshInstance3D.new()
			var am: BoxMesh = BoxMesh.new()
			am.size = Vector3(0.10, 0.10, 0.65)
			arch.mesh = am
			arch.material_override = brass_mat
			arch.position = Vector3(0, 4.20, -sz * 0.30)
			lgroup.add_child(arch)
			# Lantern bulb at the inner end of the arch
			var bulb: MeshInstance3D = MeshInstance3D.new()
			var blm: SphereMesh = SphereMesh.new()
			blm.radius = 0.20
			blm.height = 0.40
			bulb.mesh = blm
			bulb.material_override = bulb_mat
			bulb.position = Vector3(0, 4.05, -sz * 0.55)
			lgroup.add_child(bulb)
			# Lantern OmniLight
			var lt: OmniLight3D = OmniLight3D.new()
			lt.position = Vector3(0, 4.05, -sz * 0.55)
			lt.light_color = Color(1.0, 0.65, 0.20)
			lt.light_energy = 3.5
			lt.omni_range = 11.0
			lgroup.add_child(lt)
	# Slow seam pulse + bulb pulse
	var spulse: Tween = pivot.create_tween().set_loops()
	spulse.tween_property(seam_mat, "emission_energy_multiplier", 7.0, 2.0).set_ease(Tween.EASE_IN_OUT)
	spulse.tween_property(seam_mat, "emission_energy_multiplier", 4.0, 2.0).set_ease(Tween.EASE_IN_OUT)
	var bpulse: Tween = pivot.create_tween().set_loops()
	bpulse.tween_property(bulb_mat, "emission_energy_multiplier", 10.5, 1.5).set_ease(Tween.EASE_IN_OUT)
	bpulse.tween_property(bulb_mat, "emission_energy_multiplier", 7.0, 1.5).set_ease(Tween.EASE_IN_OUT)


func _build_th_south_approach_road(geom: Node) -> void:
	## Epic-10 T44: long paved approach road extending south from the
	## south entry arch (T37). Mirror of the north approach road but
	## laid along +Z. Completes the 4-cardinal arterial road network
	## around the Town Heart Plaza.
	var pivot: Node3D = Node3D.new()
	pivot.name = "TH_SouthApproachRoad"
	pivot.position = TOWN_CENTER + Vector3(0, 0, 17.50)
	geom.add_child(pivot)
	# Materials
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.22, 0.24, 0.28)
	stone_mat.metallic = 0.18
	stone_mat.roughness = 0.85
	stone_mat.emission_enabled = true
	stone_mat.emission = Color(0.30, 0.45, 0.60)
	stone_mat.emission_energy_multiplier = 0.18
	var brass_mat: StandardMaterial3D = StandardMaterial3D.new()
	brass_mat.albedo_color = Color(0.85, 0.55, 0.18)
	brass_mat.metallic = 0.95
	brass_mat.roughness = 0.30
	brass_mat.emission_enabled = true
	brass_mat.emission = Color(1.0, 0.50, 0.10)
	brass_mat.emission_energy_multiplier = 0.55
	var seam_mat: StandardMaterial3D = StandardMaterial3D.new()
	seam_mat.albedo_color = Color(0.45, 0.85, 1.0)
	seam_mat.emission_enabled = true
	seam_mat.emission = Color(0.45, 0.85, 1.0)
	seam_mat.emission_energy_multiplier = 5.5
	seam_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var bulb_mat: StandardMaterial3D = StandardMaterial3D.new()
	bulb_mat.albedo_color = Color(1.0, 0.75, 0.30)
	bulb_mat.emission_enabled = true
	bulb_mat.emission = Color(1.0, 0.65, 0.20)
	bulb_mat.emission_energy_multiplier = 8.5
	bulb_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	# 8 wide road slabs going south (+Z)
	for i in 8:
		var sz: float = float(i) * 3.50
		var slab: MeshInstance3D = MeshInstance3D.new()
		var sm: BoxMesh = BoxMesh.new()
		sm.size = Vector3(4.20, 0.10, 3.50)
		slab.mesh = sm
		slab.material_override = stone_mat
		slab.position = Vector3(0, 0.05, sz)
		pivot.add_child(slab)
		var sb: StaticBody3D = StaticBody3D.new()
		sb.position = Vector3(0, 0.05, sz)
		var cs: CollisionShape3D = CollisionShape3D.new()
		var bsh: BoxShape3D = BoxShape3D.new()
		bsh.size = Vector3(4.20, 0.20, 3.50)
		cs.shape = bsh
		sb.add_child(cs)
		pivot.add_child(sb)
		for tx in [-2.05, 2.05]:
			var trim: MeshInstance3D = MeshInstance3D.new()
			var tmm: BoxMesh = BoxMesh.new()
			tmm.size = Vector3(0.18, 0.10, 3.50)
			trim.mesh = tmm
			trim.material_override = brass_mat
			trim.position = Vector3(tx, 0.10, sz)
			pivot.add_child(trim)
		var seam: MeshInstance3D = MeshInstance3D.new()
		var seamesh: BoxMesh = BoxMesh.new()
		seamesh.size = Vector3(0.30, 0.06, 3.20)
		seam.mesh = seamesh
		seam.material_override = seam_mat
		seam.position = Vector3(0, 0.13, sz)
		pivot.add_child(seam)
	# 6 flanking lampposts (3 per side)
	var lamp_zs: Array = [3.5, 14.0, 24.5]
	for lz in lamp_zs:
		for sx in [-2.50, 2.50]:
			var lgroup: Node3D = Node3D.new()
			lgroup.position = Vector3(sx, 0, lz)
			pivot.add_child(lgroup)
			var base: MeshInstance3D = MeshInstance3D.new()
			var bm: BoxMesh = BoxMesh.new()
			bm.size = Vector3(0.65, 0.30, 0.65)
			base.mesh = bm
			base.material_override = stone_mat
			base.position = Vector3(0, 0.15, 0)
			lgroup.add_child(base)
			var shaft: MeshInstance3D = MeshInstance3D.new()
			var smm: CylinderMesh = CylinderMesh.new()
			smm.top_radius = 0.08
			smm.bottom_radius = 0.12
			smm.height = 3.80
			shaft.mesh = smm
			shaft.material_override = brass_mat
			shaft.position = Vector3(0, 2.20, 0)
			lgroup.add_child(shaft)
			var shaft_sb: StaticBody3D = StaticBody3D.new()
			shaft_sb.position = Vector3(0, 2.20, 0)
			var shaft_cs: CollisionShape3D = CollisionShape3D.new()
			var shaft_cyl: CylinderShape3D = CylinderShape3D.new()
			shaft_cyl.top_radius = 0.10
			shaft_cyl.bottom_radius = 0.12
			shaft_cyl.height = 3.80
			shaft_cs.shape = shaft_cyl
			shaft_sb.add_child(shaft_cs)
			lgroup.add_child(shaft_sb)
			var band: MeshInstance3D = MeshInstance3D.new()
			var bdm: TorusMesh = TorusMesh.new()
			bdm.inner_radius = 0.10
			bdm.outer_radius = 0.16
			band.mesh = bdm
			band.material_override = brass_mat
			band.position = Vector3(0, 2.40, 0)
			lgroup.add_child(band)
			var arch: MeshInstance3D = MeshInstance3D.new()
			var am: BoxMesh = BoxMesh.new()
			am.size = Vector3(0.65, 0.10, 0.10)
			arch.mesh = am
			arch.material_override = brass_mat
			arch.position = Vector3(-sx * 0.30, 4.20, 0)
			lgroup.add_child(arch)
			var bulb: MeshInstance3D = MeshInstance3D.new()
			var blm: SphereMesh = SphereMesh.new()
			blm.radius = 0.20
			blm.height = 0.40
			bulb.mesh = blm
			bulb.material_override = bulb_mat
			bulb.position = Vector3(-sx * 0.55, 4.05, 0)
			lgroup.add_child(bulb)
			var lt: OmniLight3D = OmniLight3D.new()
			lt.position = Vector3(-sx * 0.55, 4.05, 0)
			lt.light_color = Color(1.0, 0.65, 0.20)
			lt.light_energy = 3.5
			lt.omni_range = 11.0
			lgroup.add_child(lt)
	# Pulses
	var spulse2: Tween = pivot.create_tween().set_loops()
	spulse2.tween_property(seam_mat, "emission_energy_multiplier", 7.0, 2.0).set_ease(Tween.EASE_IN_OUT)
	spulse2.tween_property(seam_mat, "emission_energy_multiplier", 4.0, 2.0).set_ease(Tween.EASE_IN_OUT)
	var bpulse2: Tween = pivot.create_tween().set_loops()
	bpulse2.tween_property(bulb_mat, "emission_energy_multiplier", 10.5, 1.5).set_ease(Tween.EASE_IN_OUT)
	bpulse2.tween_property(bulb_mat, "emission_energy_multiplier", 7.0, 1.5).set_ease(Tween.EASE_IN_OUT)


func _build_th_waystones(geom: Node) -> void:
	## Epic-10 T45: 4 basalt waystone obelisks at the end of each cardinal
	## approach road, marking the boundary of the Town Heart territory.
	## Each waystone: stepped basalt base, tapered obelisk shaft, brass cap,
	## glowing inscription stripe, and a small lantern bulb on top. Marks
	## "you are leaving the Town Heart" for outbound travelers.
	var pivot: Node3D = Node3D.new()
	pivot.name = "TH_Waystones"
	pivot.position = TOWN_CENTER + Vector3(0, 0, 0)
	geom.add_child(pivot)
	# Materials
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.20, 0.22, 0.26)
	stone_mat.metallic = 0.18
	stone_mat.roughness = 0.85
	stone_mat.emission_enabled = true
	stone_mat.emission = Color(0.30, 0.45, 0.60)
	stone_mat.emission_energy_multiplier = 0.18
	var brass_mat: StandardMaterial3D = StandardMaterial3D.new()
	brass_mat.albedo_color = Color(0.85, 0.55, 0.18)
	brass_mat.metallic = 0.95
	brass_mat.roughness = 0.30
	brass_mat.emission_enabled = true
	brass_mat.emission = Color(1.0, 0.50, 0.10)
	brass_mat.emission_energy_multiplier = 0.55
	var data_mat: StandardMaterial3D = StandardMaterial3D.new()
	data_mat.albedo_color = Color(0.45, 0.85, 1.0)
	data_mat.emission_enabled = true
	data_mat.emission = Color(0.45, 0.85, 1.0)
	data_mat.emission_energy_multiplier = 6.5
	data_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var bulb_mat: StandardMaterial3D = StandardMaterial3D.new()
	bulb_mat.albedo_color = Color(1.0, 0.75, 0.30)
	bulb_mat.emission_enabled = true
	bulb_mat.emission = Color(1.0, 0.65, 0.20)
	bulb_mat.emission_energy_multiplier = 8.0
	bulb_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	# Place 4 waystones at the END of each approach road (~46 from town center).
	# Roads start at 17.5 and span 28m, so end is at 17.5 + 28 = 45.5
	var waystone_data: Array = [
		{"pos": Vector3(46.0, 0, 0), "rot": -PI / 2.0},   # E end of east road
		{"pos": Vector3(0, 0, -46.0), "rot": 0.0},        # N end of north road
		{"pos": Vector3(-46.0, 0, 0), "rot": PI / 2.0},   # W end of west road
		{"pos": Vector3(0, 0, 46.0), "rot": PI},          # S end of south road
	]
	for wd in waystone_data:
		var wgroup: Node3D = Node3D.new()
		wgroup.position = wd["pos"]
		wgroup.rotation.y = wd["rot"]
		pivot.add_child(wgroup)
		# ---- Stepped basalt base (2 levels) ----
		var base1: MeshInstance3D = MeshInstance3D.new()
		var b1m: BoxMesh = BoxMesh.new()
		b1m.size = Vector3(1.85, 0.45, 1.85)
		base1.mesh = b1m
		base1.material_override = stone_mat
		base1.position = Vector3(0, 0.22, 0)
		wgroup.add_child(base1)
		var base2: MeshInstance3D = MeshInstance3D.new()
		var b2m: BoxMesh = BoxMesh.new()
		b2m.size = Vector3(1.55, 0.40, 1.55)
		base2.mesh = b2m
		base2.material_override = stone_mat
		base2.position = Vector3(0, 0.65, 0)
		wgroup.add_child(base2)
		# Combined base collision
		var base_sb: StaticBody3D = StaticBody3D.new()
		base_sb.position = Vector3(0, 0.42, 0)
		var base_cs: CollisionShape3D = CollisionShape3D.new()
		var base_bsh: BoxShape3D = BoxShape3D.new()
		base_bsh.size = Vector3(1.85, 0.85, 1.85)
		base_cs.shape = base_bsh
		base_sb.add_child(base_cs)
		wgroup.add_child(base_sb)
		# ---- Tapered obelisk shaft ----
		var shaft: MeshInstance3D = MeshInstance3D.new()
		var sm: BoxMesh = BoxMesh.new()
		sm.size = Vector3(0.95, 4.50, 0.95)
		shaft.mesh = sm
		shaft.material_override = stone_mat
		shaft.position = Vector3(0, 3.10, 0)
		wgroup.add_child(shaft)
		# Shaft collision
		var shaft_sb: StaticBody3D = StaticBody3D.new()
		shaft_sb.position = Vector3(0, 3.10, 0)
		var shaft_cs: CollisionShape3D = CollisionShape3D.new()
		var shaft_bsh: BoxShape3D = BoxShape3D.new()
		shaft_bsh.size = Vector3(0.95, 4.50, 0.95)
		shaft_cs.shape = shaft_bsh
		shaft_sb.add_child(shaft_cs)
		wgroup.add_child(shaft_sb)
		# ---- Brass mid band wrap ----
		var band: MeshInstance3D = MeshInstance3D.new()
		var bdm: BoxMesh = BoxMesh.new()
		bdm.size = Vector3(1.05, 0.18, 1.05)
		band.mesh = bdm
		band.material_override = brass_mat
		band.position = Vector3(0, 3.30, 0)
		wgroup.add_child(band)
		# ---- Brass top cap ----
		var cap: MeshInstance3D = MeshInstance3D.new()
		var capm: BoxMesh = BoxMesh.new()
		capm.size = Vector3(1.20, 0.25, 1.20)
		cap.mesh = capm
		cap.material_override = brass_mat
		cap.position = Vector3(0, 5.50, 0)
		wgroup.add_child(cap)
		# Pyramid finial peak (PrismMesh)
		var finial: MeshInstance3D = MeshInstance3D.new()
		var fmm: PrismMesh = PrismMesh.new()
		fmm.size = Vector3(0.90, 0.85, 0.90)
		finial.mesh = fmm
		finial.material_override = stone_mat
		finial.position = Vector3(0, 6.05, 0)
		wgroup.add_child(finial)
		# ---- Glowing cyan inscription stripe down the front face ----
		var stripe: MeshInstance3D = MeshInstance3D.new()
		var stm: BoxMesh = BoxMesh.new()
		stm.size = Vector3(0.18, 3.20, 0.06)
		stripe.mesh = stm
		stripe.material_override = data_mat
		stripe.position = Vector3(0, 3.10, -0.50)
		wgroup.add_child(stripe)
		# 3 horizontal rune crossbars on the stripe
		for ry in [2.20, 3.10, 4.00]:
			var cross: MeshInstance3D = MeshInstance3D.new()
			var cmm: BoxMesh = BoxMesh.new()
			cmm.size = Vector3(0.50, 0.10, 0.06)
			cross.mesh = cmm
			cross.material_override = data_mat
			cross.position = Vector3(0, ry, -0.50)
			wgroup.add_child(cross)
		# ---- Small lantern bulb on top of the finial ----
		var bulb: MeshInstance3D = MeshInstance3D.new()
		var blm: SphereMesh = SphereMesh.new()
		blm.radius = 0.18
		blm.height = 0.36
		bulb.mesh = blm
		bulb.material_override = bulb_mat
		bulb.position = Vector3(0, 6.65, 0)
		wgroup.add_child(bulb)
		# Bulb OmniLight
		var lt: OmniLight3D = OmniLight3D.new()
		lt.position = Vector3(0, 6.65, 0)
		lt.light_color = Color(1.0, 0.65, 0.20)
		lt.light_energy = 3.5
		lt.omni_range = 12.0
		wgroup.add_child(lt)
	# Shared pulses
	var spulse: Tween = pivot.create_tween().set_loops()
	spulse.tween_property(data_mat, "emission_energy_multiplier", 8.5, 1.8).set_ease(Tween.EASE_IN_OUT)
	spulse.tween_property(data_mat, "emission_energy_multiplier", 5.0, 1.8).set_ease(Tween.EASE_IN_OUT)
	var bpulse: Tween = pivot.create_tween().set_loops()
	bpulse.tween_property(bulb_mat, "emission_energy_multiplier", 10.0, 1.5).set_ease(Tween.EASE_IN_OUT)
	bpulse.tween_property(bulb_mat, "emission_energy_multiplier", 6.5, 1.5).set_ease(Tween.EASE_IN_OUT)


func _build_th_sky_trams(geom: Node) -> void:
	## Epic-10 T46: 2 small floating sky-tram cable cars sliding back and
	## forth along the sky data highway diagonals between corner towers
	## (NE bell tower ↔ SW forge brazier, NW archive tower ↔ SE
	## observatory). Each tram: brass cabin with cyan window strip,
	## hanging brass arm + iron gripper attached to the diagonal beam,
	## glowing cyan headlight. Position tween slides each tram along
	## its full diagonal back and forth.
	var pivot: Node3D = Node3D.new()
	pivot.name = "TH_SkyTrams"
	pivot.position = TOWN_CENTER + Vector3(0, 0, 0)
	geom.add_child(pivot)
	# Materials
	var brass_mat: StandardMaterial3D = StandardMaterial3D.new()
	brass_mat.albedo_color = Color(0.85, 0.55, 0.18)
	brass_mat.metallic = 0.95
	brass_mat.roughness = 0.30
	brass_mat.emission_enabled = true
	brass_mat.emission = Color(1.0, 0.50, 0.10)
	brass_mat.emission_energy_multiplier = 0.55
	var iron_mat: StandardMaterial3D = StandardMaterial3D.new()
	iron_mat.albedo_color = Color(0.18, 0.16, 0.18)
	iron_mat.metallic = 0.85
	iron_mat.roughness = 0.45
	var data_mat: StandardMaterial3D = StandardMaterial3D.new()
	data_mat.albedo_color = Color(0.45, 0.85, 1.0)
	data_mat.emission_enabled = true
	data_mat.emission = Color(0.45, 0.85, 1.0)
	data_mat.emission_energy_multiplier = 7.0
	data_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	# Same corner endpoints as the sky data highway (T40)
	var ne: Vector3 = Vector3(cos(PI / 4.0) * 16.50, 18.0, sin(PI / 4.0) * 16.50)
	var nw: Vector3 = Vector3(cos(3.0 * PI / 4.0) * 16.50, 16.0, sin(3.0 * PI / 4.0) * 16.50)
	var sw: Vector3 = Vector3(cos(5.0 * PI / 4.0) * 16.50, 7.0, sin(5.0 * PI / 4.0) * 16.50)
	var se_pos: Vector3 = Vector3(cos(7.0 * PI / 4.0) * 16.50, 4.0, sin(7.0 * PI / 4.0) * 16.50)
	var tram_pairs: Array = [
		{"a": ne, "b": sw, "period": 16.0},
		{"a": nw, "b": se_pos, "period": 18.0},
	]
	for tp in tram_pairs:
		var a: Vector3 = tp["a"]
		var b: Vector3 = tp["b"]
		var period: float = tp["period"]
		var tgroup: Node3D = Node3D.new()
		tgroup.name = "SkyTram"
		# Start at the midpoint
		tgroup.position = (a + b) * 0.5
		# Face along the diagonal
		tgroup.look_at_from_position((a + b) * 0.5, b, Vector3.UP)
		pivot.add_child(tgroup)
		# ---- Brass cabin body ----
		var cabin: MeshInstance3D = MeshInstance3D.new()
		var cm: BoxMesh = BoxMesh.new()
		cm.size = Vector3(1.20, 0.85, 0.85)
		cabin.mesh = cm
		cabin.material_override = brass_mat
		cabin.position = Vector3(0, 0, 0)
		tgroup.add_child(cabin)
		# Cyan window strip wrapping the cabin (front + back faces)
		for wz in [-0.45, 0.45]:
			var window: MeshInstance3D = MeshInstance3D.new()
			var wm: BoxMesh = BoxMesh.new()
			wm.size = Vector3(1.00, 0.30, 0.04)
			window.mesh = wm
			window.material_override = data_mat
			window.position = Vector3(0, 0.15, wz)
			tgroup.add_child(window)
		# Side window strips (left + right)
		for wx in [-0.65, 0.65]:
			var sw_window: MeshInstance3D = MeshInstance3D.new()
			var swm: BoxMesh = BoxMesh.new()
			swm.size = Vector3(0.04, 0.30, 0.65)
			sw_window.mesh = swm
			sw_window.material_override = data_mat
			sw_window.position = Vector3(wx, 0.15, 0)
			tgroup.add_child(sw_window)
		# Brass roof trim
		var roof: MeshInstance3D = MeshInstance3D.new()
		var rm: BoxMesh = BoxMesh.new()
		rm.size = Vector3(1.30, 0.10, 0.95)
		roof.mesh = rm
		roof.material_override = brass_mat
		roof.position = Vector3(0, 0.50, 0)
		tgroup.add_child(roof)
		# ---- Hanging brass arm + iron gripper attached to the beam above ----
		var arm: MeshInstance3D = MeshInstance3D.new()
		var arm_m: BoxMesh = BoxMesh.new()
		arm_m.size = Vector3(0.10, 0.85, 0.10)
		arm.mesh = arm_m
		arm.material_override = brass_mat
		arm.position = Vector3(0, 0.95, 0)
		tgroup.add_child(arm)
		# Iron gripper claw at the top of the arm
		var gripper: MeshInstance3D = MeshInstance3D.new()
		var gm: BoxMesh = BoxMesh.new()
		gm.size = Vector3(0.30, 0.18, 0.30)
		gripper.mesh = gm
		gripper.material_override = iron_mat
		gripper.position = Vector3(0, 1.45, 0)
		tgroup.add_child(gripper)
		# ---- Glowing cyan headlight on the front of the cabin ----
		var headlight: MeshInstance3D = MeshInstance3D.new()
		var hlm: SphereMesh = SphereMesh.new()
		hlm.radius = 0.10
		hlm.height = 0.20
		headlight.mesh = hlm
		headlight.material_override = data_mat
		headlight.position = Vector3(0, 0, -0.50)
		tgroup.add_child(headlight)
		# Headlight OmniLight
		var lt: OmniLight3D = OmniLight3D.new()
		lt.position = Vector3(0, 0, -0.55)
		lt.light_color = Color(0.45, 0.85, 1.0)
		lt.light_energy = 2.5
		lt.omni_range = 8.0
		tgroup.add_child(lt)
		# ---- Slide tween — tram slides A → B → A on a loop ----
		# Use position tween (the tram is at the midpoint, slides to A then to B)
		var slide: Tween = pivot.create_tween().set_loops()
		slide.tween_property(tgroup, "position", a, period * 0.5).set_ease(Tween.EASE_IN_OUT)
		slide.tween_property(tgroup, "position", b, period).set_ease(Tween.EASE_IN_OUT)
		slide.tween_property(tgroup, "position", (a + b) * 0.5, period * 0.5).set_ease(Tween.EASE_IN_OUT)
	# Shared cyan pulse for windows + headlights
	var dpulse: Tween = pivot.create_tween().set_loops()
	dpulse.tween_property(data_mat, "emission_energy_multiplier", 9.0, 1.8).set_ease(Tween.EASE_IN_OUT)
	dpulse.tween_property(data_mat, "emission_energy_multiplier", 5.5, 1.8).set_ease(Tween.EASE_IN_OUT)


func _build_th_data_tree_grove(geom: Node) -> void:
	## Epic-10 T47: 8 stylized brass-and-cyan crystal data trees scattered
	## around the plaza perimeter at radius 14.5 (between the lampposts at
	## 13.2 and the corner monuments at 16.5). Each tree: brass trunk with
	## tapered widening at the base, 5 glowing cyan crystal leaf clusters
	## arranged in a canopy at the top, and a small basalt root mound.
	var pivot: Node3D = Node3D.new()
	pivot.name = "TH_DataTreeGrove"
	pivot.position = TOWN_CENTER + Vector3(0, 0, 0)
	geom.add_child(pivot)
	# Materials
	var brass_mat: StandardMaterial3D = StandardMaterial3D.new()
	brass_mat.albedo_color = Color(0.85, 0.55, 0.18)
	brass_mat.metallic = 0.95
	brass_mat.roughness = 0.30
	brass_mat.emission_enabled = true
	brass_mat.emission = Color(1.0, 0.50, 0.10)
	brass_mat.emission_energy_multiplier = 0.55
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.20, 0.22, 0.26)
	stone_mat.metallic = 0.18
	stone_mat.roughness = 0.85
	stone_mat.emission_enabled = true
	stone_mat.emission = Color(0.30, 0.45, 0.60)
	stone_mat.emission_energy_multiplier = 0.18
	var leaf_mat: StandardMaterial3D = StandardMaterial3D.new()
	leaf_mat.albedo_color = Color(0.45, 0.85, 1.0)
	leaf_mat.emission_enabled = true
	leaf_mat.emission = Color(0.45, 0.85, 1.0)
	leaf_mat.emission_energy_multiplier = 6.5
	leaf_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	# 8 trees at varied angles around the plaza perimeter, slightly offset from
	# the lamppost positions so they don't collide
	for i in 8:
		var ang: float = (float(i) + 0.25) / 8.0 * TAU
		var dx: float = cos(ang)
		var dz: float = sin(ang)
		var tp: Vector3 = Vector3(dx * 14.50, 0, dz * 14.50)
		var tgroup: Node3D = Node3D.new()
		tgroup.name = "DataTree_" + str(i)
		tgroup.position = tp
		pivot.add_child(tgroup)
		# ---- Small basalt root mound at the base ----
		var mound: MeshInstance3D = MeshInstance3D.new()
		var mm: SphereMesh = SphereMesh.new()
		mm.radius = 0.55
		mm.height = 0.40
		mound.mesh = mm
		mound.material_override = stone_mat
		mound.position = Vector3(0, 0.20, 0)
		mound.scale = Vector3(1.0, 0.55, 1.0)
		tgroup.add_child(mound)
		# Mound collision
		var mound_sb: StaticBody3D = StaticBody3D.new()
		mound_sb.position = Vector3(0, 0.20, 0)
		var mound_cs: CollisionShape3D = CollisionShape3D.new()
		var mound_cyl: CylinderShape3D = CylinderShape3D.new()
		mound_cyl.top_radius = 0.40
		mound_cyl.bottom_radius = 0.55
		mound_cyl.height = 0.40
		mound_cs.shape = mound_cyl
		mound_sb.add_child(mound_cs)
		tgroup.add_child(mound_sb)
		# ---- Brass trunk (tapered cylinder, widening at the base) ----
		var trunk: MeshInstance3D = MeshInstance3D.new()
		var trm: CylinderMesh = CylinderMesh.new()
		trm.top_radius = 0.10
		trm.bottom_radius = 0.22
		trm.height = 3.20
		trunk.mesh = trm
		trunk.material_override = brass_mat
		trunk.position = Vector3(0, 1.85, 0)
		tgroup.add_child(trunk)
		# Trunk collision
		var trunk_sb: StaticBody3D = StaticBody3D.new()
		trunk_sb.position = Vector3(0, 1.85, 0)
		var trunk_cs: CollisionShape3D = CollisionShape3D.new()
		var trunk_cyl: CylinderShape3D = CylinderShape3D.new()
		trunk_cyl.top_radius = 0.15
		trunk_cyl.bottom_radius = 0.22
		trunk_cyl.height = 3.20
		trunk_cs.shape = trunk_cyl
		trunk_sb.add_child(trunk_cs)
		tgroup.add_child(trunk_sb)
		# ---- 3 brass branch wraps along the trunk for visual texture ----
		for by in [1.20, 2.30, 3.20]:
			var band: MeshInstance3D = MeshInstance3D.new()
			var bdm: TorusMesh = TorusMesh.new()
			bdm.inner_radius = 0.13
			bdm.outer_radius = 0.18
			band.mesh = bdm
			band.material_override = brass_mat
			band.position = Vector3(0, by, 0)
			tgroup.add_child(band)
		# ---- 5 glowing cyan crystal leaf clusters arranged at the top ----
		var canopy_pivot: Node3D = Node3D.new()
		canopy_pivot.position = Vector3(0, 3.65, 0)
		tgroup.add_child(canopy_pivot)
		# Center large crystal
		var center_crystal: MeshInstance3D = MeshInstance3D.new()
		var ccm: PrismMesh = PrismMesh.new()
		ccm.size = Vector3(0.50, 0.95, 0.50)
		center_crystal.mesh = ccm
		center_crystal.material_override = leaf_mat
		center_crystal.position = Vector3(0, 0.30, 0)
		canopy_pivot.add_child(center_crystal)
		# 4 angled side crystal leaves around the center
		for j in 4:
			var lang: float = float(j) / 4.0 * TAU
			var leaf: MeshInstance3D = MeshInstance3D.new()
			var lm: PrismMesh = PrismMesh.new()
			lm.size = Vector3(0.32, 0.70, 0.32)
			leaf.mesh = lm
			leaf.material_override = leaf_mat
			leaf.position = Vector3(cos(lang) * 0.45, 0.10, sin(lang) * 0.45)
			leaf.rotation.y = lang
			leaf.rotation.z = -0.40
			canopy_pivot.add_child(leaf)
		# Per-tree subtle OmniLight
		var lt: OmniLight3D = OmniLight3D.new()
		lt.position = Vector3(0, 3.85, 0)
		lt.light_color = Color(0.55, 0.90, 1.0)
		lt.light_energy = 1.4
		lt.omni_range = 4.5
		tgroup.add_child(lt)
		# Per-tree slow canopy spin (very subtle, organic feel)
		var spin: Tween = tgroup.create_tween().set_loops()
		var spin_dir: float = 1.0 if i % 2 == 0 else -1.0
		spin.tween_property(canopy_pivot, "rotation:y", spin_dir * TAU, 18.0 + float(i) * 0.5)
	# Shared leaf cyan pulse
	var lpulse: Tween = pivot.create_tween().set_loops()
	lpulse.tween_property(leaf_mat, "emission_energy_multiplier", 8.5, 2.0).set_ease(Tween.EASE_IN_OUT)
	lpulse.tween_property(leaf_mat, "emission_energy_multiplier", 5.0, 2.0).set_ease(Tween.EASE_IN_OUT)


func _build_th_corner_mini_fountains(geom: Node) -> void:
	## Epic-10 T48: 4 small auxiliary data fountains at the NE/NW/SW/SE
	## perimeter positions slightly inside the corner monuments. Each
	## mini-fountain: round basalt rim basin + brass top trim + glowing
	## cyan water disc + small brass spire + upward jet stream particles.
	## Smaller siblings of the central T11 data fountain.
	var pivot: Node3D = Node3D.new()
	pivot.name = "TH_CornerMiniFountains"
	pivot.position = TOWN_CENTER + Vector3(0, 0, 0)
	geom.add_child(pivot)
	# Materials
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.20, 0.22, 0.26)
	stone_mat.metallic = 0.18
	stone_mat.roughness = 0.85
	stone_mat.emission_enabled = true
	stone_mat.emission = Color(0.30, 0.45, 0.60)
	stone_mat.emission_energy_multiplier = 0.18
	var brass_mat: StandardMaterial3D = StandardMaterial3D.new()
	brass_mat.albedo_color = Color(0.85, 0.55, 0.18)
	brass_mat.metallic = 0.95
	brass_mat.roughness = 0.30
	brass_mat.emission_enabled = true
	brass_mat.emission = Color(1.0, 0.50, 0.10)
	brass_mat.emission_energy_multiplier = 0.55
	var data_mat: StandardMaterial3D = StandardMaterial3D.new()
	data_mat.albedo_color = Color(0.45, 0.85, 1.0)
	data_mat.emission_enabled = true
	data_mat.emission = Color(0.45, 0.85, 1.0)
	data_mat.emission_energy_multiplier = 7.0
	data_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	# 4 mini-fountains at the ordinal positions inside the plaza outer ring
	# Place at radius ~10 between the inner station ring and the bench ring
	for i in 4:
		var ang: float = (PI / 4.0) + float(i) * (PI / 2.0)
		var dx: float = cos(ang)
		var dz: float = sin(ang)
		var fp: Vector3 = Vector3(dx * 10.0, 0, dz * 10.0)
		var fgroup: Node3D = Node3D.new()
		fgroup.name = "MiniFountain_" + str(i)
		fgroup.position = fp
		pivot.add_child(fgroup)
		# ---- Round basalt rim basin ----
		var rim: MeshInstance3D = MeshInstance3D.new()
		var rmm: TorusMesh = TorusMesh.new()
		rmm.inner_radius = 0.95
		rmm.outer_radius = 1.20
		rim.mesh = rmm
		rim.material_override = stone_mat
		rim.position = Vector3(0, 0.20, 0)
		fgroup.add_child(rim)
		# Rim collision (cylinder ring approximation)
		var rim_sb: StaticBody3D = StaticBody3D.new()
		rim_sb.position = Vector3(0, 0.20, 0)
		var rim_cs: CollisionShape3D = CollisionShape3D.new()
		var rim_cyl: CylinderShape3D = CylinderShape3D.new()
		rim_cyl.top_radius = 1.20
		rim_cyl.bottom_radius = 1.20
		rim_cyl.height = 0.40
		rim_cs.shape = rim_cyl
		rim_sb.add_child(rim_cs)
		fgroup.add_child(rim_sb)
		# Brass rim top trim torus
		var trim: MeshInstance3D = MeshInstance3D.new()
		var trm: TorusMesh = TorusMesh.new()
		trm.inner_radius = 1.05
		trm.outer_radius = 1.20
		trim.mesh = trm
		trim.material_override = brass_mat
		trim.position = Vector3(0, 0.42, 0)
		fgroup.add_child(trim)
		# ---- Glowing cyan basin water disc ----
		var water: MeshInstance3D = MeshInstance3D.new()
		var wm: CylinderMesh = CylinderMesh.new()
		wm.top_radius = 0.95
		wm.bottom_radius = 0.95
		wm.height = 0.08
		water.mesh = wm
		water.material_override = data_mat
		water.position = Vector3(0, 0.36, 0)
		fgroup.add_child(water)
		# ---- Small central brass spire (single tier) ----
		# Spire stem
		var stem: MeshInstance3D = MeshInstance3D.new()
		var sm: CylinderMesh = CylinderMesh.new()
		sm.top_radius = 0.06
		sm.bottom_radius = 0.10
		sm.height = 0.95
		stem.mesh = sm
		stem.material_override = brass_mat
		stem.position = Vector3(0, 0.85, 0)
		fgroup.add_child(stem)
		# Tier dish
		var dish: MeshInstance3D = MeshInstance3D.new()
		var dmm: CylinderMesh = CylinderMesh.new()
		dmm.top_radius = 0.30
		dmm.bottom_radius = 0.30
		dmm.height = 0.06
		dish.mesh = dmm
		dish.material_override = brass_mat
		dish.position = Vector3(0, 1.32, 0)
		fgroup.add_child(dish)
		# Top finial sphere (cyan)
		var finial: MeshInstance3D = MeshInstance3D.new()
		var fmm: SphereMesh = SphereMesh.new()
		fmm.radius = 0.12
		fmm.height = 0.24
		finial.mesh = fmm
		finial.material_override = data_mat
		finial.position = Vector3(0, 1.55, 0)
		fgroup.add_child(finial)
		# ---- Upward jet stream particles from the finial ----
		var jet: GPUParticles3D = GPUParticles3D.new()
		jet.position = Vector3(0, 1.65, 0)
		jet.amount = 18
		jet.lifetime = 1.5
		var jmat: ParticleProcessMaterial = ParticleProcessMaterial.new()
		jmat.direction = Vector3(0, 1, 0)
		jmat.spread = 14.0
		jmat.initial_velocity_min = 1.0
		jmat.initial_velocity_max = 1.8
		jmat.gravity = Vector3(0, -2.0, 0)
		jmat.scale_min = 0.05
		jmat.scale_max = 0.10
		jmat.color = Color(0.45, 0.85, 1.0, 1.0)
		jet.process_material = jmat
		var jmesh: SphereMesh = SphereMesh.new()
		jmesh.radius = 0.05
		jmesh.height = 0.10
		jet.draw_pass_1 = jmesh
		fgroup.add_child(jet)
		# ---- Small per-fountain cyan OmniLight ----
		var lt: OmniLight3D = OmniLight3D.new()
		lt.position = Vector3(0, 1.10, 0)
		lt.light_color = Color(0.45, 0.85, 1.0)
		lt.light_energy = 1.8
		lt.omni_range = 5.5
		fgroup.add_child(lt)
	# Shared cyan pulse for water + finial
	var dpulse: Tween = pivot.create_tween().set_loops()
	dpulse.tween_property(data_mat, "emission_energy_multiplier", 8.5, 1.6).set_ease(Tween.EASE_IN_OUT)
	dpulse.tween_property(data_mat, "emission_energy_multiplier", 5.0, 1.6).set_ease(Tween.EASE_IN_OUT)


func _build_th_open_pavilion(geom: Node) -> void:
	## Epic-10 T49: small open-roofed pavilion shelter placed in the
	## south-west area between the bench ring and the corner brazier
	## monument. Stepped stone foundation, 4 brass corner posts, dome
	## brass roof + finial, central wooden bench, and 4 hanging lanterns
	## from the corners. The Town Heart's first actual enclosed building.
	var pivot: Node3D = Node3D.new()
	pivot.name = "TH_OpenPavilion"
	# Place between the SW bench area and the SW forge brazier monument
	var ang: float = 5.0 * PI / 4.0
	pivot.position = TOWN_CENTER + Vector3(cos(ang) * 11.50, 0, sin(ang) * 11.50)
	# Face inward toward the beacon
	pivot.rotation.y = -ang - PI / 2.0
	geom.add_child(pivot)
	# Materials
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.20, 0.22, 0.26)
	stone_mat.metallic = 0.18
	stone_mat.roughness = 0.85
	stone_mat.emission_enabled = true
	stone_mat.emission = Color(0.30, 0.45, 0.60)
	stone_mat.emission_energy_multiplier = 0.18
	var brass_mat: StandardMaterial3D = StandardMaterial3D.new()
	brass_mat.albedo_color = Color(0.85, 0.55, 0.18)
	brass_mat.metallic = 0.95
	brass_mat.roughness = 0.30
	brass_mat.emission_enabled = true
	brass_mat.emission = Color(1.0, 0.50, 0.10)
	brass_mat.emission_energy_multiplier = 0.55
	var wood_mat: StandardMaterial3D = StandardMaterial3D.new()
	wood_mat.albedo_color = Color(0.32, 0.20, 0.12)
	wood_mat.roughness = 0.85
	wood_mat.metallic = 0.10
	var bulb_mat: StandardMaterial3D = StandardMaterial3D.new()
	bulb_mat.albedo_color = Color(1.0, 0.75, 0.30)
	bulb_mat.emission_enabled = true
	bulb_mat.emission = Color(1.0, 0.65, 0.20)
	bulb_mat.emission_energy_multiplier = 8.0
	bulb_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var data_mat: StandardMaterial3D = StandardMaterial3D.new()
	data_mat.albedo_color = Color(0.45, 0.85, 1.0)
	data_mat.emission_enabled = true
	data_mat.emission = Color(0.45, 0.85, 1.0)
	data_mat.emission_energy_multiplier = 6.0
	data_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	# ---- Stepped stone foundation (2-step circular) ----
	var base1: MeshInstance3D = MeshInstance3D.new()
	var b1m: CylinderMesh = CylinderMesh.new()
	b1m.top_radius = 2.40
	b1m.bottom_radius = 2.55
	b1m.height = 0.30
	base1.mesh = b1m
	base1.material_override = stone_mat
	base1.position = Vector3(0, 0.15, 0)
	pivot.add_child(base1)
	var base2: MeshInstance3D = MeshInstance3D.new()
	var b2m: CylinderMesh = CylinderMesh.new()
	b2m.top_radius = 2.10
	b2m.bottom_radius = 2.20
	b2m.height = 0.25
	base2.mesh = b2m
	base2.material_override = stone_mat
	base2.position = Vector3(0, 0.42, 0)
	pivot.add_child(base2)
	# Foundation collision
	var found_sb: StaticBody3D = StaticBody3D.new()
	found_sb.position = Vector3(0, 0.30, 0)
	var found_cs: CollisionShape3D = CollisionShape3D.new()
	var found_cyl: CylinderShape3D = CylinderShape3D.new()
	found_cyl.top_radius = 2.10
	found_cyl.bottom_radius = 2.55
	found_cyl.height = 0.55
	found_cs.shape = found_cyl
	found_sb.add_child(found_cs)
	pivot.add_child(found_sb)
	# Brass top trim torus on the foundation
	var trim: MeshInstance3D = MeshInstance3D.new()
	var trm: TorusMesh = TorusMesh.new()
	trm.inner_radius = 2.05
	trm.outer_radius = 2.15
	trim.mesh = trm
	trim.material_override = brass_mat
	trim.position = Vector3(0, 0.58, 0)
	pivot.add_child(trim)
	# ---- 4 brass corner posts holding up the roof ----
	for i in 4:
		var pang: float = float(i) / 4.0 * TAU + PI / 4.0
		var px: float = cos(pang) * 1.85
		var pz: float = sin(pang) * 1.85
		var post: MeshInstance3D = MeshInstance3D.new()
		var pmm: CylinderMesh = CylinderMesh.new()
		pmm.top_radius = 0.10
		pmm.bottom_radius = 0.13
		pmm.height = 3.20
		post.mesh = pmm
		post.material_override = brass_mat
		post.position = Vector3(px, 2.15, pz)
		pivot.add_child(post)
		# Post collision
		var post_sb: StaticBody3D = StaticBody3D.new()
		post_sb.position = Vector3(px, 2.15, pz)
		var post_cs: CollisionShape3D = CollisionShape3D.new()
		var post_cyl: CylinderShape3D = CylinderShape3D.new()
		post_cyl.top_radius = 0.13
		post_cyl.bottom_radius = 0.13
		post_cyl.height = 3.20
		post_cs.shape = post_cyl
		post_sb.add_child(post_cs)
		pivot.add_child(post_sb)
		# Post mid band
		var band: MeshInstance3D = MeshInstance3D.new()
		var bdm: TorusMesh = TorusMesh.new()
		bdm.inner_radius = 0.13
		bdm.outer_radius = 0.18
		band.mesh = bdm
		band.material_override = brass_mat
		band.position = Vector3(px, 2.20, pz)
		pivot.add_child(band)
		# ---- Hanging brass lantern at the post top ----
		# Bracket arm pointing inward
		var bracket: MeshInstance3D = MeshInstance3D.new()
		var bktm: BoxMesh = BoxMesh.new()
		bktm.size = Vector3(0.55, 0.10, 0.10)
		bracket.mesh = bktm
		bracket.material_override = brass_mat
		# Rotate bracket to face inward toward the pavilion center
		bracket.position = Vector3(px * 0.75, 3.55, pz * 0.75)
		bracket.look_at_from_position(Vector3(px * 0.75, 3.55, pz * 0.75), Vector3(0, 3.55, 0), Vector3.UP)
		pivot.add_child(bracket)
		# Lantern bulb at the inner end of the bracket
		var bulb: MeshInstance3D = MeshInstance3D.new()
		var blm: SphereMesh = SphereMesh.new()
		blm.radius = 0.16
		blm.height = 0.32
		bulb.mesh = blm
		bulb.material_override = bulb_mat
		bulb.position = Vector3(px * 0.40, 3.40, pz * 0.40)
		pivot.add_child(bulb)
		# Lantern OmniLight
		var lt: OmniLight3D = OmniLight3D.new()
		lt.position = Vector3(px * 0.40, 3.40, pz * 0.40)
		lt.light_color = Color(1.0, 0.65, 0.20)
		lt.light_energy = 2.4
		lt.omni_range = 6.5
		pivot.add_child(lt)
	# ---- Brass dome roof (sphere top half) ----
	var dome: MeshInstance3D = MeshInstance3D.new()
	var dmm: SphereMesh = SphereMesh.new()
	dmm.radius = 2.30
	dmm.height = 4.60
	dome.mesh = dmm
	dome.material_override = brass_mat
	dome.position = Vector3(0, 4.10, 0)
	dome.scale = Vector3(1.0, 0.55, 1.0)
	pivot.add_child(dome)
	# Brass roof base ring (just below the dome)
	var roof_ring: MeshInstance3D = MeshInstance3D.new()
	var rrm: TorusMesh = TorusMesh.new()
	rrm.inner_radius = 2.10
	rrm.outer_radius = 2.30
	roof_ring.mesh = rrm
	roof_ring.material_override = brass_mat
	roof_ring.position = Vector3(0, 3.85, 0)
	pivot.add_child(roof_ring)
	# Top finial spire + cyan dot
	var finial: MeshInstance3D = MeshInstance3D.new()
	var fmm: PrismMesh = PrismMesh.new()
	fmm.size = Vector3(0.30, 0.85, 0.30)
	finial.mesh = fmm
	finial.material_override = brass_mat
	finial.position = Vector3(0, 5.30, 0)
	pivot.add_child(finial)
	var finial_dot: MeshInstance3D = MeshInstance3D.new()
	var fdm: SphereMesh = SphereMesh.new()
	fdm.radius = 0.13
	fdm.height = 0.26
	finial_dot.mesh = fdm
	finial_dot.material_override = data_mat
	finial_dot.position = Vector3(0, 5.85, 0)
	pivot.add_child(finial_dot)
	# ---- Central wooden bench (2 short legs + long slab + brass back rail) ----
	# Legs
	for lx in [-0.85, 0.85]:
		var leg: MeshInstance3D = MeshInstance3D.new()
		var lmesh: BoxMesh = BoxMesh.new()
		lmesh.size = Vector3(0.20, 0.45, 0.40)
		leg.mesh = lmesh
		leg.material_override = wood_mat
		leg.position = Vector3(lx, 0.85, 0)
		pivot.add_child(leg)
	# Seat slab
	var seat: MeshInstance3D = MeshInstance3D.new()
	var smm: BoxMesh = BoxMesh.new()
	smm.size = Vector3(2.10, 0.14, 0.55)
	seat.mesh = smm
	seat.material_override = wood_mat
	seat.position = Vector3(0, 1.15, 0)
	pivot.add_child(seat)
	# Bench collision
	var seat_sb: StaticBody3D = StaticBody3D.new()
	seat_sb.position = Vector3(0, 0.95, 0)
	var seat_cs: CollisionShape3D = CollisionShape3D.new()
	var seat_bsh: BoxShape3D = BoxShape3D.new()
	seat_bsh.size = Vector3(2.10, 0.55, 0.55)
	seat_cs.shape = seat_bsh
	seat_sb.add_child(seat_cs)
	pivot.add_child(seat_sb)
	# Brass back rail
	var rail: MeshInstance3D = MeshInstance3D.new()
	var rm: BoxMesh = BoxMesh.new()
	rm.size = Vector3(2.00, 0.06, 0.06)
	rail.mesh = rm
	rail.material_override = brass_mat
	rail.position = Vector3(0, 1.55, 0.30)
	pivot.add_child(rail)
	# Back rail support posts
	for rsx in [-0.90, 0.90]:
		var rsp: MeshInstance3D = MeshInstance3D.new()
		var rspm: CylinderMesh = CylinderMesh.new()
		rspm.top_radius = 0.04
		rspm.bottom_radius = 0.05
		rspm.height = 0.45
		rsp.mesh = rspm
		rsp.material_override = brass_mat
		rsp.position = Vector3(rsx, 1.35, 0.30)
		pivot.add_child(rsp)
	# Strong cyan finial OmniLight (under the dome)
	var dome_lt: OmniLight3D = OmniLight3D.new()
	dome_lt.position = Vector3(0, 4.50, 0)
	dome_lt.light_color = Color(0.55, 0.90, 1.0)
	dome_lt.light_energy = 2.5
	dome_lt.omni_range = 7.5
	pivot.add_child(dome_lt)
	# Pulses
	var bpulse: Tween = pivot.create_tween().set_loops()
	bpulse.tween_property(bulb_mat, "emission_energy_multiplier", 9.5, 1.6).set_ease(Tween.EASE_IN_OUT)
	bpulse.tween_property(bulb_mat, "emission_energy_multiplier", 6.5, 1.6).set_ease(Tween.EASE_IN_OUT)
	var dpulse2: Tween = pivot.create_tween().set_loops()
	dpulse2.tween_property(data_mat, "emission_energy_multiplier", 8.0, 1.8).set_ease(Tween.EASE_IN_OUT)
	dpulse2.tween_property(data_mat, "emission_energy_multiplier", 5.0, 1.8).set_ease(Tween.EASE_IN_OUT)


func _build_th_hex_gazebo(geom: Node) -> void:
	## Epic-10 T50 (HALFWAY MILESTONE): hexagonal gazebo shelter at the
	## NE area between the bench ring and bell tower, balancing the SW
	## round pavilion (T49) with a different silhouette. 6-sided stone
	## hex floor, 6 brass corner posts, hex pyramid prism roof, 6 small
	## round bench segments inside (one between each pair of posts), and
	## hanging amber lanterns from the underside of the roof.
	var pivot: Node3D = Node3D.new()
	pivot.name = "TH_HexGazebo"
	# NE position at radius 11.5 between the bench ring and bell tower
	var ang: float = PI / 4.0
	pivot.position = TOWN_CENTER + Vector3(cos(ang) * 11.50, 0, sin(ang) * 11.50)
	pivot.rotation.y = -ang - PI / 2.0
	geom.add_child(pivot)
	# Materials
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.20, 0.22, 0.26)
	stone_mat.metallic = 0.18
	stone_mat.roughness = 0.85
	stone_mat.emission_enabled = true
	stone_mat.emission = Color(0.30, 0.45, 0.60)
	stone_mat.emission_energy_multiplier = 0.18
	var brass_mat: StandardMaterial3D = StandardMaterial3D.new()
	brass_mat.albedo_color = Color(0.85, 0.55, 0.18)
	brass_mat.metallic = 0.95
	brass_mat.roughness = 0.30
	brass_mat.emission_enabled = true
	brass_mat.emission = Color(1.0, 0.50, 0.10)
	brass_mat.emission_energy_multiplier = 0.55
	var wood_mat: StandardMaterial3D = StandardMaterial3D.new()
	wood_mat.albedo_color = Color(0.32, 0.20, 0.12)
	wood_mat.roughness = 0.85
	wood_mat.metallic = 0.10
	var bulb_mat: StandardMaterial3D = StandardMaterial3D.new()
	bulb_mat.albedo_color = Color(1.0, 0.75, 0.30)
	bulb_mat.emission_enabled = true
	bulb_mat.emission = Color(1.0, 0.65, 0.20)
	bulb_mat.emission_energy_multiplier = 8.0
	bulb_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var data_mat: StandardMaterial3D = StandardMaterial3D.new()
	data_mat.albedo_color = Color(0.45, 0.85, 1.0)
	data_mat.emission_enabled = true
	data_mat.emission = Color(0.45, 0.85, 1.0)
	data_mat.emission_energy_multiplier = 6.5
	data_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	# ---- Hexagonal stone floor (cylinder approximation, 6-sided look from torus rim) ----
	var floor: MeshInstance3D = MeshInstance3D.new()
	var fm: CylinderMesh = CylinderMesh.new()
	fm.top_radius = 2.10
	fm.bottom_radius = 2.10
	fm.height = 0.30
	floor.mesh = fm
	floor.material_override = stone_mat
	floor.position = Vector3(0, 0.15, 0)
	pivot.add_child(floor)
	# Floor collision
	var floor_sb: StaticBody3D = StaticBody3D.new()
	floor_sb.position = Vector3(0, 0.15, 0)
	var floor_cs: CollisionShape3D = CollisionShape3D.new()
	var floor_cyl: CylinderShape3D = CylinderShape3D.new()
	floor_cyl.top_radius = 2.10
	floor_cyl.bottom_radius = 2.10
	floor_cyl.height = 0.30
	floor_cs.shape = floor_cyl
	floor_sb.add_child(floor_cs)
	pivot.add_child(floor_sb)
	# Brass top trim torus on the floor
	var trim: MeshInstance3D = MeshInstance3D.new()
	var trm: TorusMesh = TorusMesh.new()
	trm.inner_radius = 2.00
	trm.outer_radius = 2.10
	trim.mesh = trm
	trim.material_override = brass_mat
	trim.position = Vector3(0, 0.32, 0)
	pivot.add_child(trim)
	# ---- 6 brass corner posts at hex vertices ----
	for i in 6:
		var pang: float = float(i) / 6.0 * TAU
		var px: float = cos(pang) * 1.95
		var pz: float = sin(pang) * 1.95
		var post: MeshInstance3D = MeshInstance3D.new()
		var pmm: CylinderMesh = CylinderMesh.new()
		pmm.top_radius = 0.10
		pmm.bottom_radius = 0.13
		pmm.height = 3.20
		post.mesh = pmm
		post.material_override = brass_mat
		post.position = Vector3(px, 1.95, pz)
		pivot.add_child(post)
		# Post collision
		var post_sb: StaticBody3D = StaticBody3D.new()
		post_sb.position = Vector3(px, 1.95, pz)
		var post_cs: CollisionShape3D = CollisionShape3D.new()
		var post_cyl: CylinderShape3D = CylinderShape3D.new()
		post_cyl.top_radius = 0.13
		post_cyl.bottom_radius = 0.13
		post_cyl.height = 3.20
		post_cs.shape = post_cyl
		post_sb.add_child(post_cs)
		pivot.add_child(post_sb)
		# Post brass mid band
		var band: MeshInstance3D = MeshInstance3D.new()
		var bdm: TorusMesh = TorusMesh.new()
		bdm.inner_radius = 0.13
		bdm.outer_radius = 0.18
		band.mesh = bdm
		band.material_override = brass_mat
		band.position = Vector3(px, 1.85, pz)
		pivot.add_child(band)
	# ---- Hex pyramid prism roof (PrismMesh stretched) ----
	# Use 6 box panels arranged radially around the center for a hex roof feel
	for i in 6:
		var pang: float = float(i) / 6.0 * TAU
		var dx: float = cos(pang)
		var dz: float = sin(pang)
		var panel: MeshInstance3D = MeshInstance3D.new()
		var panm: PrismMesh = PrismMesh.new()
		panm.size = Vector3(2.20, 1.20, 1.10)
		panel.mesh = panm
		panel.material_override = brass_mat
		# Position the panel at an angled position above the post ring, pointing inward up
		panel.position = Vector3(dx * 1.10, 4.00, dz * 1.10)
		panel.rotation.y = pang + PI / 2.0
		panel.rotation.x = -PI / 4.0
		pivot.add_child(panel)
	# Top central hex finial cap (small cylinder)
	var cap: MeshInstance3D = MeshInstance3D.new()
	var capm: CylinderMesh = CylinderMesh.new()
	capm.top_radius = 0.30
	capm.bottom_radius = 0.40
	capm.height = 0.40
	cap.mesh = capm
	cap.material_override = brass_mat
	cap.position = Vector3(0, 4.85, 0)
	pivot.add_child(cap)
	# Top finial spire prism
	var finial: MeshInstance3D = MeshInstance3D.new()
	var fmm: PrismMesh = PrismMesh.new()
	fmm.size = Vector3(0.30, 0.85, 0.30)
	finial.mesh = fmm
	finial.material_override = brass_mat
	finial.position = Vector3(0, 5.40, 0)
	pivot.add_child(finial)
	# Top finial cyan dot
	var finial_dot: MeshInstance3D = MeshInstance3D.new()
	var fdm: SphereMesh = SphereMesh.new()
	fdm.radius = 0.13
	fdm.height = 0.26
	finial_dot.mesh = fdm
	finial_dot.material_override = data_mat
	finial_dot.position = Vector3(0, 5.95, 0)
	pivot.add_child(finial_dot)
	# ---- 6 round bench segments inside the gazebo, one between each pair of posts ----
	for i in 6:
		var bang: float = (float(i) + 0.5) / 6.0 * TAU
		var bx: float = cos(bang) * 1.40
		var bz: float = sin(bang) * 1.40
		# Bench seat slab
		var seat: MeshInstance3D = MeshInstance3D.new()
		var smm: BoxMesh = BoxMesh.new()
		smm.size = Vector3(1.10, 0.12, 0.45)
		seat.mesh = smm
		seat.material_override = wood_mat
		seat.position = Vector3(bx, 0.65, bz)
		seat.rotation.y = bang + PI / 2.0
		pivot.add_child(seat)
		# Bench collision
		var seat_sb: StaticBody3D = StaticBody3D.new()
		seat_sb.position = Vector3(bx, 0.45, bz)
		seat_sb.rotation.y = bang + PI / 2.0
		var seat_cs: CollisionShape3D = CollisionShape3D.new()
		var seat_bsh: BoxShape3D = BoxShape3D.new()
		seat_bsh.size = Vector3(1.10, 0.40, 0.45)
		seat_cs.shape = seat_bsh
		seat_sb.add_child(seat_cs)
		pivot.add_child(seat_sb)
	# ---- 6 hanging amber lanterns from the underside of the roof (one per panel) ----
	for i in 6:
		var lang: float = float(i) / 6.0 * TAU
		var lx: float = cos(lang) * 1.30
		var lz: float = sin(lang) * 1.30
		# Lantern cord
		var cord: MeshInstance3D = MeshInstance3D.new()
		var crm: CylinderMesh = CylinderMesh.new()
		crm.top_radius = 0.018
		crm.bottom_radius = 0.018
		crm.height = 0.65
		cord.mesh = crm
		cord.material_override = brass_mat
		cord.position = Vector3(lx, 3.65, lz)
		pivot.add_child(cord)
		# Bulb
		var bulb: MeshInstance3D = MeshInstance3D.new()
		var blm: SphereMesh = SphereMesh.new()
		blm.radius = 0.16
		blm.height = 0.32
		bulb.mesh = blm
		bulb.material_override = bulb_mat
		bulb.position = Vector3(lx, 3.20, lz)
		pivot.add_child(bulb)
		# Light
		var lt: OmniLight3D = OmniLight3D.new()
		lt.position = Vector3(lx, 3.20, lz)
		lt.light_color = Color(1.0, 0.65, 0.20)
		lt.light_energy = 2.2
		lt.omni_range = 6.0
		pivot.add_child(lt)
	# Strong central cyan finial OmniLight
	var finial_lt: OmniLight3D = OmniLight3D.new()
	finial_lt.position = Vector3(0, 5.20, 0)
	finial_lt.light_color = Color(0.55, 0.90, 1.0)
	finial_lt.light_energy = 2.5
	finial_lt.omni_range = 7.5
	pivot.add_child(finial_lt)
	# Pulses
	var bpulse2: Tween = pivot.create_tween().set_loops()
	bpulse2.tween_property(bulb_mat, "emission_energy_multiplier", 9.5, 1.6).set_ease(Tween.EASE_IN_OUT)
	bpulse2.tween_property(bulb_mat, "emission_energy_multiplier", 6.5, 1.6).set_ease(Tween.EASE_IN_OUT)
	var dpulse3: Tween = pivot.create_tween().set_loops()
	dpulse3.tween_property(data_mat, "emission_energy_multiplier", 8.0, 1.8).set_ease(Tween.EASE_IN_OUT)
	dpulse3.tween_property(data_mat, "emission_energy_multiplier", 5.0, 1.8).set_ease(Tween.EASE_IN_OUT)


func _build_th_road_junctions(geom: Node) -> void:
	## Epic-10 T51: 4 small octagonal transition plazas where each cardinal
	## entry arch meets the start of the approach road. Each junction:
	## small basalt octagonal disc, brass center disc with glowing rune
	## ring, brass perimeter trim torus, and 4 small accent lamps at the
	## diagonal corners.
	var pivot: Node3D = Node3D.new()
	pivot.name = "TH_RoadJunctions"
	pivot.position = TOWN_CENTER + Vector3(0, 0, 0)
	geom.add_child(pivot)
	# Materials
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.20, 0.22, 0.26)
	stone_mat.metallic = 0.18
	stone_mat.roughness = 0.85
	stone_mat.emission_enabled = true
	stone_mat.emission = Color(0.30, 0.45, 0.60)
	stone_mat.emission_energy_multiplier = 0.18
	var brass_mat: StandardMaterial3D = StandardMaterial3D.new()
	brass_mat.albedo_color = Color(0.85, 0.55, 0.18)
	brass_mat.metallic = 0.95
	brass_mat.roughness = 0.30
	brass_mat.emission_enabled = true
	brass_mat.emission = Color(1.0, 0.50, 0.10)
	brass_mat.emission_energy_multiplier = 0.55
	var rune_mat: StandardMaterial3D = StandardMaterial3D.new()
	rune_mat.albedo_color = Color(0.45, 0.85, 1.0)
	rune_mat.emission_enabled = true
	rune_mat.emission = Color(0.45, 0.85, 1.0)
	rune_mat.emission_energy_multiplier = 6.0
	rune_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var bulb_mat: StandardMaterial3D = StandardMaterial3D.new()
	bulb_mat.albedo_color = Color(1.0, 0.75, 0.30)
	bulb_mat.emission_enabled = true
	bulb_mat.emission = Color(1.0, 0.65, 0.20)
	bulb_mat.emission_energy_multiplier = 7.5
	bulb_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	# 4 junction positions — at radius 16 (between the entry arches at 15.5 and the road starts at 17.5)
	var junction_positions: Array = [
		Vector3(16.0, 0, 0),    # E
		Vector3(0, 0, -16.0),   # N
		Vector3(-16.0, 0, 0),   # W
		Vector3(0, 0, 16.0),    # S
	]
	for jp in junction_positions:
		var jgroup: Node3D = Node3D.new()
		jgroup.position = jp
		pivot.add_child(jgroup)
		# ---- Octagonal stone disc (cylinder approximation, 16 segments) ----
		var disc: MeshInstance3D = MeshInstance3D.new()
		var dm: CylinderMesh = CylinderMesh.new()
		dm.top_radius = 2.40
		dm.bottom_radius = 2.50
		dm.height = 0.10
		disc.mesh = dm
		disc.material_override = stone_mat
		disc.position = Vector3(0, 0.05, 0)
		jgroup.add_child(disc)
		# Disc collision
		var disc_sb: StaticBody3D = StaticBody3D.new()
		disc_sb.position = Vector3(0, 0.05, 0)
		var disc_cs: CollisionShape3D = CollisionShape3D.new()
		var disc_cyl: CylinderShape3D = CylinderShape3D.new()
		disc_cyl.top_radius = 2.50
		disc_cyl.bottom_radius = 2.50
		disc_cyl.height = 0.20
		disc_cs.shape = disc_cyl
		disc_sb.add_child(disc_cs)
		jgroup.add_child(disc_sb)
		# ---- Brass perimeter trim torus ----
		var trim: MeshInstance3D = MeshInstance3D.new()
		var trm: TorusMesh = TorusMesh.new()
		trm.inner_radius = 2.30
		trm.outer_radius = 2.45
		trim.mesh = trm
		trim.material_override = brass_mat
		trim.position = Vector3(0, 0.13, 0)
		jgroup.add_child(trim)
		# ---- Brass center disc ----
		var center: MeshInstance3D = MeshInstance3D.new()
		var cmm: CylinderMesh = CylinderMesh.new()
		cmm.top_radius = 0.95
		cmm.bottom_radius = 0.95
		cmm.height = 0.06
		center.mesh = cmm
		center.material_override = brass_mat
		center.position = Vector3(0, 0.13, 0)
		jgroup.add_child(center)
		# ---- Glowing cyan rune ring on the center disc ----
		var rune_ring: MeshInstance3D = MeshInstance3D.new()
		var rrm: TorusMesh = TorusMesh.new()
		rrm.inner_radius = 0.65
		rrm.outer_radius = 0.85
		rune_ring.mesh = rrm
		rune_ring.material_override = rune_mat
		rune_ring.position = Vector3(0, 0.18, 0)
		jgroup.add_child(rune_ring)
		# 4 small rune dots on the ring
		for i in 4:
			var ang: float = float(i) / 4.0 * TAU
			var dot: MeshInstance3D = MeshInstance3D.new()
			var dotm: SphereMesh = SphereMesh.new()
			dotm.radius = 0.10
			dotm.height = 0.05
			dot.mesh = dotm
			dot.material_override = rune_mat
			dot.position = Vector3(cos(ang) * 0.75, 0.20, sin(ang) * 0.75)
			dot.scale = Vector3(1.0, 0.30, 1.0)
			jgroup.add_child(dot)
		# ---- 4 small accent lamps at the diagonal corners ----
		for i in 4:
			var lang: float = float(i) / 4.0 * TAU + PI / 4.0
			var lx: float = cos(lang) * 1.85
			var lz: float = sin(lang) * 1.85
			# Small brass post
			var lpost: MeshInstance3D = MeshInstance3D.new()
			var lpm: CylinderMesh = CylinderMesh.new()
			lpm.top_radius = 0.05
			lpm.bottom_radius = 0.07
			lpm.height = 0.85
			lpost.mesh = lpm
			lpost.material_override = brass_mat
			lpost.position = Vector3(lx, 0.55, lz)
			jgroup.add_child(lpost)
			# Bulb on top of the post
			var bulb: MeshInstance3D = MeshInstance3D.new()
			var blm: SphereMesh = SphereMesh.new()
			blm.radius = 0.10
			blm.height = 0.20
			bulb.mesh = blm
			bulb.material_override = bulb_mat
			bulb.position = Vector3(lx, 1.05, lz)
			jgroup.add_child(bulb)
			# OmniLight per lamp
			var lt: OmniLight3D = OmniLight3D.new()
			lt.position = Vector3(lx, 1.05, lz)
			lt.light_color = Color(1.0, 0.65, 0.20)
			lt.light_energy = 1.4
			lt.omni_range = 4.0
			jgroup.add_child(lt)
	# Shared cyan rune pulse + bulb pulse
	var rpulse: Tween = pivot.create_tween().set_loops()
	rpulse.tween_property(rune_mat, "emission_energy_multiplier", 8.0, 1.8).set_ease(Tween.EASE_IN_OUT)
	rpulse.tween_property(rune_mat, "emission_energy_multiplier", 4.5, 1.8).set_ease(Tween.EASE_IN_OUT)
	var bpulse: Tween = pivot.create_tween().set_loops()
	bpulse.tween_property(bulb_mat, "emission_energy_multiplier", 9.0, 1.4).set_ease(Tween.EASE_IN_OUT)
	bpulse.tween_property(bulb_mat, "emission_energy_multiplier", 6.0, 1.4).set_ease(Tween.EASE_IN_OUT)


func _build_th_ground_runes(geom: Node) -> void:
	## Epic-10 T52: 16 small glowing rune accent decals inlaid in the
	## plaza floor between the central beacon ring (radius 5) and the
	## bench ring (radius 11.5). 8 outer at radius 9 (1 per radial) +
	## 8 inner at radius 6.5 (offset 22.5 degrees). Each decal is a
	## small flat torus + 4 satellite dots in alternating amber/cyan.
	var pivot: Node3D = Node3D.new()
	pivot.name = "TH_GroundRunes"
	pivot.position = TOWN_CENTER + Vector3(0, 0, 0)
	geom.add_child(pivot)
	# Materials
	var cyan_mat: StandardMaterial3D = StandardMaterial3D.new()
	cyan_mat.albedo_color = Color(0.45, 0.85, 1.0)
	cyan_mat.emission_enabled = true
	cyan_mat.emission = Color(0.45, 0.85, 1.0)
	cyan_mat.emission_energy_multiplier = 5.5
	cyan_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var amber_mat: StandardMaterial3D = StandardMaterial3D.new()
	amber_mat.albedo_color = Color(1.0, 0.55, 0.10)
	amber_mat.emission_enabled = true
	amber_mat.emission = Color(1.0, 0.55, 0.10)
	amber_mat.emission_energy_multiplier = 5.5
	amber_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	# Outer ring — 8 decals at radius 9, one per cardinal/ordinal direction
	for i in 8:
		var ang: float = float(i) / 8.0 * TAU
		var dx: float = cos(ang)
		var dz: float = sin(ang)
		# Alternate cyan and amber per slot for variety
		var mat: StandardMaterial3D = cyan_mat if i % 2 == 0 else amber_mat
		# Decal torus (flat ring on the ground)
		var ring: MeshInstance3D = MeshInstance3D.new()
		var rmm: TorusMesh = TorusMesh.new()
		rmm.inner_radius = 0.45
		rmm.outer_radius = 0.60
		ring.mesh = rmm
		ring.material_override = mat
		ring.position = Vector3(dx * 9.00, 0.18, dz * 9.00)
		pivot.add_child(ring)
		# 4 satellite dots around the ring
		for j in 4:
			var sang: float = float(j) / 4.0 * TAU
			var dot: MeshInstance3D = MeshInstance3D.new()
			var dmm: SphereMesh = SphereMesh.new()
			dmm.radius = 0.10
			dmm.height = 0.05
			dot.mesh = dmm
			dot.material_override = mat
			dot.position = Vector3(dx * 9.00 + cos(sang) * 0.65, 0.18, dz * 9.00 + sin(sang) * 0.65)
			dot.scale = Vector3(1.0, 0.30, 1.0)
			pivot.add_child(dot)
	# Inner ring — 8 decals at radius 6.5, offset by 22.5 degrees
	for i in 8:
		var ang: float = (float(i) + 0.5) / 8.0 * TAU
		var dx: float = cos(ang)
		var dz: float = sin(ang)
		# Alternate the OPPOSITE color so the inner ring is offset from the outer
		var mat: StandardMaterial3D = amber_mat if i % 2 == 0 else cyan_mat
		# Smaller decal torus
		var ring: MeshInstance3D = MeshInstance3D.new()
		var rmm: TorusMesh = TorusMesh.new()
		rmm.inner_radius = 0.30
		rmm.outer_radius = 0.42
		ring.mesh = rmm
		ring.material_override = mat
		ring.position = Vector3(dx * 6.50, 0.18, dz * 6.50)
		pivot.add_child(ring)
		# Center dot
		var center: MeshInstance3D = MeshInstance3D.new()
		var ccm: SphereMesh = SphereMesh.new()
		ccm.radius = 0.08
		ccm.height = 0.04
		center.mesh = ccm
		center.material_override = mat
		center.position = Vector3(dx * 6.50, 0.20, dz * 6.50)
		center.scale = Vector3(1.0, 0.30, 1.0)
		pivot.add_child(center)
	# Shared pulses for each color
	var cpulse: Tween = pivot.create_tween().set_loops()
	cpulse.tween_property(cyan_mat, "emission_energy_multiplier", 7.5, 2.0).set_ease(Tween.EASE_IN_OUT)
	cpulse.tween_property(cyan_mat, "emission_energy_multiplier", 4.0, 2.0).set_ease(Tween.EASE_IN_OUT)
	var apulse: Tween = pivot.create_tween().set_loops()
	apulse.tween_property(amber_mat, "emission_energy_multiplier", 7.5, 2.4).set_ease(Tween.EASE_IN_OUT)
	apulse.tween_property(amber_mat, "emission_energy_multiplier", 4.0, 2.4).set_ease(Tween.EASE_IN_OUT)


func _build_th_road_benches(geom: Node) -> void:
	## Epic-10 T53: 8 small wooden benches placed along the 4 approach
	## roads (2 per road, at the road midpoint, one on each side just
	## outside the lampposts). Provides traveler rest spots along each
	## arterial corridor.
	var pivot: Node3D = Node3D.new()
	pivot.name = "TH_RoadBenches"
	pivot.position = TOWN_CENTER + Vector3(0, 0, 0)
	geom.add_child(pivot)
	# Materials
	var wood_mat: StandardMaterial3D = StandardMaterial3D.new()
	wood_mat.albedo_color = Color(0.32, 0.20, 0.12)
	wood_mat.roughness = 0.85
	wood_mat.metallic = 0.10
	var brass_mat: StandardMaterial3D = StandardMaterial3D.new()
	brass_mat.albedo_color = Color(0.85, 0.55, 0.18)
	brass_mat.metallic = 0.95
	brass_mat.roughness = 0.30
	brass_mat.emission_enabled = true
	brass_mat.emission = Color(1.0, 0.50, 0.10)
	brass_mat.emission_energy_multiplier = 0.45
	var glow_mat: StandardMaterial3D = StandardMaterial3D.new()
	glow_mat.albedo_color = Color(0.45, 0.85, 1.0)
	glow_mat.emission_enabled = true
	glow_mat.emission = Color(0.45, 0.85, 1.0)
	glow_mat.emission_energy_multiplier = 4.5
	glow_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	# Bench placements: each road has 2 benches at its midpoint,
	# one on each side just outside the lampposts (~3.4 from road centerline)
	# Roads start at +/-17.5 and span 28m, midpoint is at radius 31.5 from center
	var bench_data: Array = [
		# E road (along +X), midpoint x=31.5, benches at +/-3.4 z
		{"pos": Vector3(31.5, 0, -3.40), "rot": 0.0},
		{"pos": Vector3(31.5, 0, 3.40), "rot": PI},
		# N road (along -Z), midpoint z=-31.5
		{"pos": Vector3(-3.40, 0, -31.5), "rot": -PI / 2.0},
		{"pos": Vector3(3.40, 0, -31.5), "rot": PI / 2.0},
		# W road (along -X), midpoint x=-31.5
		{"pos": Vector3(-31.5, 0, -3.40), "rot": 0.0},
		{"pos": Vector3(-31.5, 0, 3.40), "rot": PI},
		# S road (along +Z), midpoint z=31.5
		{"pos": Vector3(-3.40, 0, 31.5), "rot": -PI / 2.0},
		{"pos": Vector3(3.40, 0, 31.5), "rot": PI / 2.0},
	]
	for bd in bench_data:
		var bgroup: Node3D = Node3D.new()
		bgroup.position = bd["pos"]
		bgroup.rotation.y = bd["rot"]
		pivot.add_child(bgroup)
		# 2 short wood legs
		for lx in [-0.85, 0.85]:
			var leg: MeshInstance3D = MeshInstance3D.new()
			var lm: BoxMesh = BoxMesh.new()
			lm.size = Vector3(0.20, 0.45, 0.40)
			leg.mesh = lm
			leg.material_override = wood_mat
			leg.position = Vector3(lx, 0.22, 0)
			bgroup.add_child(leg)
		# Long wood seat slab
		var seat: MeshInstance3D = MeshInstance3D.new()
		var sm: BoxMesh = BoxMesh.new()
		sm.size = Vector3(2.10, 0.14, 0.55)
		seat.mesh = sm
		seat.material_override = wood_mat
		seat.position = Vector3(0, 0.55, 0)
		bgroup.add_child(seat)
		# Bench collision
		var sb: StaticBody3D = StaticBody3D.new()
		sb.position = Vector3(0, 0.30, 0)
		var cs: CollisionShape3D = CollisionShape3D.new()
		var bsh: BoxShape3D = BoxShape3D.new()
		bsh.size = Vector3(2.10, 0.65, 0.55)
		cs.shape = bsh
		sb.add_child(cs)
		bgroup.add_child(sb)
		# Brass back rail
		var rail: MeshInstance3D = MeshInstance3D.new()
		var rm: BoxMesh = BoxMesh.new()
		rm.size = Vector3(2.00, 0.06, 0.06)
		rail.mesh = rm
		rail.material_override = brass_mat
		rail.position = Vector3(0, 1.00, 0.25)
		bgroup.add_child(rail)
		# Back rail support posts
		for rsx in [-0.85, 0.85]:
			var rsp: MeshInstance3D = MeshInstance3D.new()
			var rspm: CylinderMesh = CylinderMesh.new()
			rspm.top_radius = 0.04
			rspm.bottom_radius = 0.05
			rspm.height = 0.45
			rsp.mesh = rspm
			rsp.material_override = brass_mat
			rsp.position = Vector3(rsx, 0.80, 0.25)
			bgroup.add_child(rsp)
		# Glowing under-seat cyan strip
		var glow: MeshInstance3D = MeshInstance3D.new()
		var gm: BoxMesh = BoxMesh.new()
		gm.size = Vector3(2.00, 0.05, 0.06)
		glow.mesh = gm
		glow.material_override = glow_mat
		glow.position = Vector3(0, 0.40, -0.25)
		bgroup.add_child(glow)
	# Shared cyan glow pulse
	var gpulse: Tween = pivot.create_tween().set_loops()
	gpulse.tween_property(glow_mat, "emission_energy_multiplier", 6.0, 2.2).set_ease(Tween.EASE_IN_OUT)
	gpulse.tween_property(glow_mat, "emission_energy_multiplier", 3.5, 2.2).set_ease(Tween.EASE_IN_OUT)


func _build_th_road_planters(geom: Node) -> void:
	## Epic-10 T54: 12 small data plant pots along the approach roads
	## (3 per road, between the lampposts on alternating sides). Each
	## pot: small basalt cylinder pot, brass rim, soil disc, central
	## green leaf cluster + tiny cyan crystal bud.
	var pivot: Node3D = Node3D.new()
	pivot.name = "TH_RoadPlanters"
	pivot.position = TOWN_CENTER + Vector3(0, 0, 0)
	geom.add_child(pivot)
	# Materials
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.20, 0.22, 0.26)
	stone_mat.metallic = 0.18
	stone_mat.roughness = 0.85
	stone_mat.emission_enabled = true
	stone_mat.emission = Color(0.30, 0.45, 0.60)
	stone_mat.emission_energy_multiplier = 0.18
	var brass_mat: StandardMaterial3D = StandardMaterial3D.new()
	brass_mat.albedo_color = Color(0.85, 0.55, 0.18)
	brass_mat.metallic = 0.95
	brass_mat.roughness = 0.30
	brass_mat.emission_enabled = true
	brass_mat.emission = Color(1.0, 0.50, 0.10)
	brass_mat.emission_energy_multiplier = 0.45
	var soil_mat: StandardMaterial3D = StandardMaterial3D.new()
	soil_mat.albedo_color = Color(0.18, 0.13, 0.10)
	soil_mat.roughness = 0.92
	var leaf_mat: StandardMaterial3D = StandardMaterial3D.new()
	leaf_mat.albedo_color = Color(0.55, 1.0, 0.65)
	leaf_mat.emission_enabled = true
	leaf_mat.emission = Color(0.55, 1.0, 0.65)
	leaf_mat.emission_energy_multiplier = 5.0
	leaf_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var crystal_mat: StandardMaterial3D = StandardMaterial3D.new()
	crystal_mat.albedo_color = Color(0.45, 0.85, 1.0)
	crystal_mat.emission_enabled = true
	crystal_mat.emission = Color(0.45, 0.85, 1.0)
	crystal_mat.emission_energy_multiplier = 6.5
	crystal_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	# Each road has 3 planters spaced along its length, alternating sides
	# Roads run from radius 17.5 to 45.5, so spaced at 24, 32, 40 from town center
	# Side offset matches the lamppost +/-2.5 outer side
	var road_axes: Array = [
		# E road: along +X, side offset along Z
		{"axis": Vector3(1, 0, 0), "side": Vector3(0, 0, 1)},
		# N road: along -Z, side offset along X
		{"axis": Vector3(0, 0, -1), "side": Vector3(1, 0, 0)},
		# W road: along -X, side offset along Z
		{"axis": Vector3(-1, 0, 0), "side": Vector3(0, 0, 1)},
		# S road: along +Z, side offset along X
		{"axis": Vector3(0, 0, 1), "side": Vector3(1, 0, 0)},
	]
	var distances: Array = [24.0, 32.0, 40.0]
	# Side multipliers — alternate left/right per planter so they don't all line up on one side
	var side_mults: Array = [-3.40, 3.40, -3.40]
	for road in road_axes:
		var axis: Vector3 = road["axis"]
		var side: Vector3 = road["side"]
		for i in distances.size():
			var dist: float = distances[i]
			var smul: float = side_mults[i]
			var pp: Vector3 = axis * dist + side * smul
			var pgroup: Node3D = Node3D.new()
			pgroup.position = pp
			pivot.add_child(pgroup)
			# ---- Stepped basalt pot (cylinder with tapered bottom) ----
			var pot: MeshInstance3D = MeshInstance3D.new()
			var pmm: CylinderMesh = CylinderMesh.new()
			pmm.top_radius = 0.45
			pmm.bottom_radius = 0.38
			pmm.height = 0.55
			pot.mesh = pmm
			pot.material_override = stone_mat
			pot.position = Vector3(0, 0.27, 0)
			pgroup.add_child(pot)
			# Pot collision
			var pot_sb: StaticBody3D = StaticBody3D.new()
			pot_sb.position = Vector3(0, 0.27, 0)
			var pot_cs: CollisionShape3D = CollisionShape3D.new()
			var pot_cyl: CylinderShape3D = CylinderShape3D.new()
			pot_cyl.top_radius = 0.45
			pot_cyl.bottom_radius = 0.42
			pot_cyl.height = 0.55
			pot_cs.shape = pot_cyl
			pot_sb.add_child(pot_cs)
			pgroup.add_child(pot_sb)
			# Brass rim torus
			var rim: MeshInstance3D = MeshInstance3D.new()
			var rmm: TorusMesh = TorusMesh.new()
			rmm.inner_radius = 0.40
			rmm.outer_radius = 0.50
			rim.mesh = rmm
			rim.material_override = brass_mat
			rim.position = Vector3(0, 0.56, 0)
			pgroup.add_child(rim)
			# Soil disc
			var soil: MeshInstance3D = MeshInstance3D.new()
			var sm: CylinderMesh = CylinderMesh.new()
			sm.top_radius = 0.40
			sm.bottom_radius = 0.40
			sm.height = 0.06
			soil.mesh = sm
			soil.material_override = soil_mat
			soil.position = Vector3(0, 0.55, 0)
			pgroup.add_child(soil)
			# ---- 3 leaf prisms radiating outward from the soil center ----
			for j in 3:
				var lang: float = float(j) / 3.0 * TAU
				var leaf: MeshInstance3D = MeshInstance3D.new()
				var lmesh: PrismMesh = PrismMesh.new()
				lmesh.size = Vector3(0.28, 0.10, 0.18)
				leaf.mesh = lmesh
				leaf.material_override = leaf_mat
				leaf.position = Vector3(cos(lang) * 0.18, 0.85, sin(lang) * 0.18)
				leaf.rotation.y = lang
				leaf.rotation.z = -PI / 2.5
				pgroup.add_child(leaf)
			# ---- Tiny cyan crystal bud at the top ----
			var bud: MeshInstance3D = MeshInstance3D.new()
			var bm: SphereMesh = SphereMesh.new()
			bm.radius = 0.08
			bm.height = 0.16
			bud.mesh = bm
			bud.material_override = crystal_mat
			bud.position = Vector3(0, 1.05, 0)
			pgroup.add_child(bud)
			# Subtle per-pot cyan OmniLight
			var lt: OmniLight3D = OmniLight3D.new()
			lt.position = Vector3(0, 0.85, 0)
			lt.light_color = Color(0.55, 0.95, 1.0)
			lt.light_energy = 0.65
			lt.omni_range = 2.5
			pgroup.add_child(lt)
	# Shared leaf + crystal pulses
	var lpulse: Tween = pivot.create_tween().set_loops()
	lpulse.tween_property(leaf_mat, "emission_energy_multiplier", 6.5, 2.4).set_ease(Tween.EASE_IN_OUT)
	lpulse.tween_property(leaf_mat, "emission_energy_multiplier", 3.5, 2.4).set_ease(Tween.EASE_IN_OUT)
	var cpulse: Tween = pivot.create_tween().set_loops()
	cpulse.tween_property(crystal_mat, "emission_energy_multiplier", 8.5, 1.8).set_ease(Tween.EASE_IN_OUT)
	cpulse.tween_property(crystal_mat, "emission_energy_multiplier", 5.0, 1.8).set_ease(Tween.EASE_IN_OUT)


func _build_th_courier_hut(geom: Node) -> void:
	## Epic-10 T55: small wooden + brass cabin building on the NW outer
	## perimeter (between the bench ring and the archive tower) acting as
	## a courier post hut. 4 walls forming an enclosed building with
	## collision, pitched 2-panel roof, doorway opening on the front,
	## glowing cyan window on the side, brass chimney with smoke, and a
	## brass sign over the door.
	var pivot: Node3D = Node3D.new()
	pivot.name = "TH_CourierHut"
	# NW outer perimeter at radius 12 between bench ring and archive tower
	var ang: float = 3.0 * PI / 4.0
	pivot.position = TOWN_CENTER + Vector3(cos(ang) * 12.50, 0, sin(ang) * 12.50)
	# Face the beacon
	pivot.rotation.y = -ang - PI / 2.0
	geom.add_child(pivot)
	# Materials
	var wood_mat: StandardMaterial3D = StandardMaterial3D.new()
	wood_mat.albedo_color = Color(0.32, 0.20, 0.12)
	wood_mat.roughness = 0.85
	wood_mat.metallic = 0.10
	wood_mat.emission_enabled = true
	wood_mat.emission = Color(0.65, 0.40, 0.10)
	wood_mat.emission_energy_multiplier = 0.18
	var brass_mat: StandardMaterial3D = StandardMaterial3D.new()
	brass_mat.albedo_color = Color(0.85, 0.55, 0.18)
	brass_mat.metallic = 0.95
	brass_mat.roughness = 0.30
	brass_mat.emission_enabled = true
	brass_mat.emission = Color(1.0, 0.50, 0.10)
	brass_mat.emission_energy_multiplier = 0.55
	var iron_mat: StandardMaterial3D = StandardMaterial3D.new()
	iron_mat.albedo_color = Color(0.18, 0.16, 0.18)
	iron_mat.metallic = 0.85
	iron_mat.roughness = 0.45
	var window_mat: StandardMaterial3D = StandardMaterial3D.new()
	window_mat.albedo_color = Color(0.45, 0.85, 1.0)
	window_mat.emission_enabled = true
	window_mat.emission = Color(0.45, 0.85, 1.0)
	window_mat.emission_energy_multiplier = 7.0
	window_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	# ---- Stone foundation ----
	var foundation: MeshInstance3D = MeshInstance3D.new()
	var fm: BoxMesh = BoxMesh.new()
	fm.size = Vector3(3.40, 0.30, 2.85)
	foundation.mesh = fm
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.20, 0.22, 0.26)
	stone_mat.metallic = 0.18
	stone_mat.roughness = 0.85
	foundation.material_override = stone_mat
	foundation.position = Vector3(0, 0.15, 0)
	pivot.add_child(foundation)
	# ---- 4 wooden walls ----
	# Back wall (full)
	var back: MeshInstance3D = MeshInstance3D.new()
	var bm: BoxMesh = BoxMesh.new()
	bm.size = Vector3(3.20, 2.50, 0.18)
	back.mesh = bm
	back.material_override = wood_mat
	back.position = Vector3(0, 1.55, 1.30)
	pivot.add_child(back)
	# Back wall collision
	var back_sb: StaticBody3D = StaticBody3D.new()
	back_sb.position = Vector3(0, 1.55, 1.30)
	var back_cs: CollisionShape3D = CollisionShape3D.new()
	var back_bsh: BoxShape3D = BoxShape3D.new()
	back_bsh.size = Vector3(3.20, 2.50, 0.18)
	back_cs.shape = back_bsh
	back_sb.add_child(back_cs)
	pivot.add_child(back_sb)
	# Left wall (full)
	var left: MeshInstance3D = MeshInstance3D.new()
	var lm: BoxMesh = BoxMesh.new()
	lm.size = Vector3(0.18, 2.50, 2.85)
	left.mesh = lm
	left.material_override = wood_mat
	left.position = Vector3(-1.60, 1.55, 0)
	pivot.add_child(left)
	# Left wall collision
	var left_sb: StaticBody3D = StaticBody3D.new()
	left_sb.position = Vector3(-1.60, 1.55, 0)
	var left_cs: CollisionShape3D = CollisionShape3D.new()
	var left_bsh: BoxShape3D = BoxShape3D.new()
	left_bsh.size = Vector3(0.18, 2.50, 2.85)
	left_cs.shape = left_bsh
	left_sb.add_child(left_cs)
	pivot.add_child(left_sb)
	# Right wall (with glowing cyan window cut out)
	# Right wall has 2 segments: front + back of the window
	var right_top: MeshInstance3D = MeshInstance3D.new()
	var rtm: BoxMesh = BoxMesh.new()
	rtm.size = Vector3(0.18, 0.85, 2.85)
	right_top.mesh = rtm
	right_top.material_override = wood_mat
	right_top.position = Vector3(1.60, 2.38, 0)
	pivot.add_child(right_top)
	var right_bot: MeshInstance3D = MeshInstance3D.new()
	var rbm: BoxMesh = BoxMesh.new()
	rbm.size = Vector3(0.18, 0.65, 2.85)
	right_bot.mesh = rbm
	right_bot.material_override = wood_mat
	right_bot.position = Vector3(1.60, 0.62, 0)
	pivot.add_child(right_bot)
	# Right wall front + back segments (around the central window)
	var right_front: MeshInstance3D = MeshInstance3D.new()
	var rfm: BoxMesh = BoxMesh.new()
	rfm.size = Vector3(0.18, 1.00, 0.95)
	right_front.mesh = rfm
	right_front.material_override = wood_mat
	right_front.position = Vector3(1.60, 1.55, -0.95)
	pivot.add_child(right_front)
	var right_back: MeshInstance3D = MeshInstance3D.new()
	right_back.mesh = rfm
	right_back.material_override = wood_mat
	right_back.position = Vector3(1.60, 1.55, 0.95)
	pivot.add_child(right_back)
	# Right wall collision (full slab)
	var right_sb: StaticBody3D = StaticBody3D.new()
	right_sb.position = Vector3(1.60, 1.55, 0)
	var right_cs: CollisionShape3D = CollisionShape3D.new()
	var right_bsh: BoxShape3D = BoxShape3D.new()
	right_bsh.size = Vector3(0.18, 2.50, 2.85)
	right_cs.shape = right_bsh
	right_sb.add_child(right_cs)
	pivot.add_child(right_sb)
	# Glowing cyan window on the right wall
	var window: MeshInstance3D = MeshInstance3D.new()
	var wmesh: BoxMesh = BoxMesh.new()
	wmesh.size = Vector3(0.10, 0.95, 0.95)
	window.mesh = wmesh
	window.material_override = window_mat
	window.position = Vector3(1.62, 1.55, 0)
	pivot.add_child(window)
	# Front wall (with doorway opening — 2 segments left and right of the door)
	var front_left: MeshInstance3D = MeshInstance3D.new()
	var flm: BoxMesh = BoxMesh.new()
	flm.size = Vector3(1.00, 2.50, 0.18)
	front_left.mesh = flm
	front_left.material_override = wood_mat
	front_left.position = Vector3(-1.10, 1.55, -1.30)
	pivot.add_child(front_left)
	var front_right: MeshInstance3D = MeshInstance3D.new()
	front_right.mesh = flm
	front_right.material_override = wood_mat
	front_right.position = Vector3(1.10, 1.55, -1.30)
	pivot.add_child(front_right)
	# Front wall top header (above the doorway)
	var front_top: MeshInstance3D = MeshInstance3D.new()
	var ftm: BoxMesh = BoxMesh.new()
	ftm.size = Vector3(1.20, 0.55, 0.18)
	front_top.mesh = ftm
	front_top.material_override = wood_mat
	front_top.position = Vector3(0, 2.55, -1.30)
	pivot.add_child(front_top)
	# Front wall collision (segments only — leave doorway open)
	var fl_sb: StaticBody3D = StaticBody3D.new()
	fl_sb.position = Vector3(-1.10, 1.55, -1.30)
	var fl_cs: CollisionShape3D = CollisionShape3D.new()
	var fl_bsh: BoxShape3D = BoxShape3D.new()
	fl_bsh.size = Vector3(1.00, 2.50, 0.18)
	fl_cs.shape = fl_bsh
	fl_sb.add_child(fl_cs)
	pivot.add_child(fl_sb)
	var fr_sb: StaticBody3D = StaticBody3D.new()
	fr_sb.position = Vector3(1.10, 1.55, -1.30)
	var fr_cs: CollisionShape3D = CollisionShape3D.new()
	fr_cs.shape = fl_bsh
	fr_sb.add_child(fr_cs)
	pivot.add_child(fr_sb)
	# ---- Pitched roof (2 angled wood panels) ----
	for ry in 2:
		var rmult: float = -1.0 if ry == 0 else 1.0
		var roof_panel: MeshInstance3D = MeshInstance3D.new()
		var rmm: BoxMesh = BoxMesh.new()
		rmm.size = Vector3(3.60, 0.18, 1.85)
		roof_panel.mesh = rmm
		roof_panel.material_override = wood_mat
		roof_panel.position = Vector3(0, 3.20, rmult * 0.85)
		roof_panel.rotation.x = rmult * 0.45
		pivot.add_child(roof_panel)
	# Brass roof ridge cap
	var ridge: MeshInstance3D = MeshInstance3D.new()
	var rim: BoxMesh = BoxMesh.new()
	rim.size = Vector3(3.40, 0.14, 0.20)
	ridge.mesh = rim
	ridge.material_override = brass_mat
	ridge.position = Vector3(0, 3.55, 0)
	pivot.add_child(ridge)
	# ---- Brass chimney with smoke ----
	var chimney: MeshInstance3D = MeshInstance3D.new()
	var chm: BoxMesh = BoxMesh.new()
	chm.size = Vector3(0.40, 1.10, 0.40)
	chimney.mesh = chm
	chimney.material_override = brass_mat
	chimney.position = Vector3(-1.00, 3.95, 0.65)
	pivot.add_child(chimney)
	# Chimney smoke particles
	var smoke: GPUParticles3D = GPUParticles3D.new()
	smoke.position = Vector3(-1.00, 4.65, 0.65)
	smoke.amount = 18
	smoke.lifetime = 3.0
	var smat: ParticleProcessMaterial = ParticleProcessMaterial.new()
	smat.direction = Vector3(0, 1, 0)
	smat.spread = 16.0
	smat.initial_velocity_min = 0.5
	smat.initial_velocity_max = 1.0
	smat.gravity = Vector3(0.2, 0.4, 0)
	smat.scale_min = 0.12
	smat.scale_max = 0.24
	smat.color = Color(0.30, 0.25, 0.20, 0.65)
	smoke.process_material = smat
	var smkm: SphereMesh = SphereMesh.new()
	smkm.radius = 0.10
	smkm.height = 0.20
	smoke.draw_pass_1 = smkm
	pivot.add_child(smoke)
	# ---- Brass sign over the door (with glowing cyan center letter) ----
	var sign: MeshInstance3D = MeshInstance3D.new()
	var sgm: BoxMesh = BoxMesh.new()
	sgm.size = Vector3(1.30, 0.45, 0.10)
	sign.mesh = sgm
	sign.material_override = brass_mat
	sign.position = Vector3(0, 2.30, -1.40)
	pivot.add_child(sign)
	var sign_letter: MeshInstance3D = MeshInstance3D.new()
	var sllm: BoxMesh = BoxMesh.new()
	sllm.size = Vector3(0.95, 0.30, 0.06)
	sign_letter.mesh = sllm
	sign_letter.material_override = window_mat
	sign_letter.position = Vector3(0, 2.30, -1.46)
	pivot.add_child(sign_letter)
	# Sign hanging chains
	for hcx in [-0.55, 0.55]:
		var chain: MeshInstance3D = MeshInstance3D.new()
		var chm2: CylinderMesh = CylinderMesh.new()
		chm2.top_radius = 0.025
		chm2.bottom_radius = 0.025
		chm2.height = 0.30
		chain.mesh = chm2
		chain.material_override = iron_mat
		chain.position = Vector3(hcx, 2.65, -1.40)
		pivot.add_child(chain)
	# ---- 2 hanging brass lanterns flanking the doorway ----
	for hlx in [-1.30, 1.30]:
		# Bracket
		var bracket: MeshInstance3D = MeshInstance3D.new()
		var bktm: BoxMesh = BoxMesh.new()
		bktm.size = Vector3(0.15, 0.18, 0.30)
		bracket.mesh = bktm
		bracket.material_override = brass_mat
		bracket.position = Vector3(hlx, 2.05, -1.45)
		pivot.add_child(bracket)
		# Lantern bulb
		var bulb: MeshInstance3D = MeshInstance3D.new()
		var blm: SphereMesh = SphereMesh.new()
		blm.radius = 0.14
		blm.height = 0.28
		bulb.mesh = blm
		var bulb_mat: StandardMaterial3D = StandardMaterial3D.new()
		bulb_mat.albedo_color = Color(1.0, 0.75, 0.30)
		bulb_mat.emission_enabled = true
		bulb_mat.emission = Color(1.0, 0.65, 0.20)
		bulb_mat.emission_energy_multiplier = 8.0
		bulb_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		bulb.material_override = bulb_mat
		bulb.position = Vector3(hlx, 1.85, -1.55)
		pivot.add_child(bulb)
		# Lantern OmniLight
		var lt: OmniLight3D = OmniLight3D.new()
		lt.position = Vector3(hlx, 1.85, -1.55)
		lt.light_color = Color(1.0, 0.65, 0.20)
		lt.light_energy = 2.4
		lt.omni_range = 6.0
		pivot.add_child(lt)
	# ---- Strong cyan window OmniLight (interior glow leaking out) ----
	var lt: OmniLight3D = OmniLight3D.new()
	lt.position = Vector3(1.95, 1.55, 0)
	lt.light_color = Color(0.45, 0.85, 1.0)
	lt.light_energy = 2.2
	lt.omni_range = 6.5
	pivot.add_child(lt)
	# Window pulse
	var wpulse: Tween = pivot.create_tween().set_loops()
	wpulse.tween_property(window_mat, "emission_energy_multiplier", 8.5, 1.8).set_ease(Tween.EASE_IN_OUT)
	wpulse.tween_property(window_mat, "emission_energy_multiplier", 5.5, 1.8).set_ease(Tween.EASE_IN_OUT)


func _build_th_bookstall(geom: Node) -> void:
	## Epic-10 T56: small open-front bookstall building on the SE outer
	## perimeter mirroring the NW courier hut. Wooden frame with 3 walls
	## (no front), wood plank back wall covered in 3 rows of glowing
	## cyan book spines, slanted roof, brass counter on the open front,
	## hanging brass lanterns, and a brass nameplate sign.
	var pivot: Node3D = Node3D.new()
	pivot.name = "TH_Bookstall"
	# SE outer perimeter at radius 12.5 between bench ring and observatory
	var ang: float = 7.0 * PI / 4.0
	pivot.position = TOWN_CENTER + Vector3(cos(ang) * 12.50, 0, sin(ang) * 12.50)
	pivot.rotation.y = -ang - PI / 2.0
	geom.add_child(pivot)
	# Materials
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.20, 0.22, 0.26)
	stone_mat.metallic = 0.18
	stone_mat.roughness = 0.85
	var wood_mat: StandardMaterial3D = StandardMaterial3D.new()
	wood_mat.albedo_color = Color(0.32, 0.20, 0.12)
	wood_mat.roughness = 0.85
	wood_mat.metallic = 0.10
	wood_mat.emission_enabled = true
	wood_mat.emission = Color(0.65, 0.40, 0.10)
	wood_mat.emission_energy_multiplier = 0.18
	var brass_mat: StandardMaterial3D = StandardMaterial3D.new()
	brass_mat.albedo_color = Color(0.85, 0.55, 0.18)
	brass_mat.metallic = 0.95
	brass_mat.roughness = 0.30
	brass_mat.emission_enabled = true
	brass_mat.emission = Color(1.0, 0.50, 0.10)
	brass_mat.emission_energy_multiplier = 0.55
	var iron_mat: StandardMaterial3D = StandardMaterial3D.new()
	iron_mat.albedo_color = Color(0.18, 0.16, 0.18)
	iron_mat.metallic = 0.85
	iron_mat.roughness = 0.45
	var book_mat: StandardMaterial3D = StandardMaterial3D.new()
	book_mat.albedo_color = Color(0.45, 0.85, 1.0)
	book_mat.emission_enabled = true
	book_mat.emission = Color(0.45, 0.85, 1.0)
	book_mat.emission_energy_multiplier = 5.5
	book_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var bulb_mat: StandardMaterial3D = StandardMaterial3D.new()
	bulb_mat.albedo_color = Color(1.0, 0.75, 0.30)
	bulb_mat.emission_enabled = true
	bulb_mat.emission = Color(1.0, 0.65, 0.20)
	bulb_mat.emission_energy_multiplier = 8.0
	bulb_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	# ---- Stone foundation slab ----
	var foundation: MeshInstance3D = MeshInstance3D.new()
	var fm: BoxMesh = BoxMesh.new()
	fm.size = Vector3(3.40, 0.30, 2.85)
	foundation.mesh = fm
	foundation.material_override = stone_mat
	foundation.position = Vector3(0, 0.15, 0)
	pivot.add_child(foundation)
	# ---- Back wall (full wooden plank slab — books mounted on this) ----
	var back: MeshInstance3D = MeshInstance3D.new()
	var bm: BoxMesh = BoxMesh.new()
	bm.size = Vector3(3.20, 2.50, 0.18)
	back.mesh = bm
	back.material_override = wood_mat
	back.position = Vector3(0, 1.55, 1.30)
	pivot.add_child(back)
	# Back wall collision
	var back_sb: StaticBody3D = StaticBody3D.new()
	back_sb.position = Vector3(0, 1.55, 1.30)
	var back_cs: CollisionShape3D = CollisionShape3D.new()
	var back_bsh: BoxShape3D = BoxShape3D.new()
	back_bsh.size = Vector3(3.20, 2.50, 0.18)
	back_cs.shape = back_bsh
	back_sb.add_child(back_cs)
	pivot.add_child(back_sb)
	# Left wall (full)
	var left: MeshInstance3D = MeshInstance3D.new()
	var lm: BoxMesh = BoxMesh.new()
	lm.size = Vector3(0.18, 2.50, 2.85)
	left.mesh = lm
	left.material_override = wood_mat
	left.position = Vector3(-1.60, 1.55, 0)
	pivot.add_child(left)
	# Left wall collision
	var left_sb: StaticBody3D = StaticBody3D.new()
	left_sb.position = Vector3(-1.60, 1.55, 0)
	var left_cs: CollisionShape3D = CollisionShape3D.new()
	var left_bsh: BoxShape3D = BoxShape3D.new()
	left_bsh.size = Vector3(0.18, 2.50, 2.85)
	left_cs.shape = left_bsh
	left_sb.add_child(left_cs)
	pivot.add_child(left_sb)
	# Right wall (full)
	var right: MeshInstance3D = MeshInstance3D.new()
	right.mesh = lm
	right.material_override = wood_mat
	right.position = Vector3(1.60, 1.55, 0)
	pivot.add_child(right)
	# Right wall collision
	var right_sb: StaticBody3D = StaticBody3D.new()
	right_sb.position = Vector3(1.60, 1.55, 0)
	var right_cs: CollisionShape3D = CollisionShape3D.new()
	right_cs.shape = left_bsh
	right_sb.add_child(right_cs)
	pivot.add_child(right_sb)
	# ---- 3 rows of glowing cyan book spines on the back wall ----
	# 8 books per row, evenly spaced
	for row in 3:
		var ry: float = 0.85 + float(row) * 0.65
		for col in 8:
			var bx: float = -1.40 + float(col) * 0.40
			# Slight per-book height variation for organic shelf look
			var bh: float = 0.45 + (sin(float(row * 8 + col) * 1.7) * 0.05)
			var book: MeshInstance3D = MeshInstance3D.new()
			var bkm: BoxMesh = BoxMesh.new()
			bkm.size = Vector3(0.30, bh, 0.06)
			book.mesh = bkm
			book.material_override = book_mat
			book.position = Vector3(bx, ry, 1.18)
			pivot.add_child(book)
	# 3 brass shelf bars (one under each book row)
	for row in 3:
		var ry: float = 0.55 + float(row) * 0.65
		var shelf: MeshInstance3D = MeshInstance3D.new()
		var shm: BoxMesh = BoxMesh.new()
		shm.size = Vector3(3.10, 0.06, 0.20)
		shelf.mesh = shm
		shelf.material_override = brass_mat
		shelf.position = Vector3(0, ry, 1.10)
		pivot.add_child(shelf)
	# ---- Brass counter on the open front ----
	var counter: MeshInstance3D = MeshInstance3D.new()
	var cm: BoxMesh = BoxMesh.new()
	cm.size = Vector3(3.20, 0.85, 0.55)
	counter.mesh = cm
	counter.material_override = brass_mat
	counter.position = Vector3(0, 0.73, -1.05)
	pivot.add_child(counter)
	# Counter collision
	var counter_sb: StaticBody3D = StaticBody3D.new()
	counter_sb.position = Vector3(0, 0.73, -1.05)
	var counter_cs: CollisionShape3D = CollisionShape3D.new()
	var counter_bsh: BoxShape3D = BoxShape3D.new()
	counter_bsh.size = Vector3(3.20, 0.85, 0.55)
	counter_cs.shape = counter_bsh
	counter_sb.add_child(counter_cs)
	pivot.add_child(counter_sb)
	# Counter top trim
	var counter_top: MeshInstance3D = MeshInstance3D.new()
	var ctm: BoxMesh = BoxMesh.new()
	ctm.size = Vector3(3.30, 0.10, 0.65)
	counter_top.mesh = ctm
	counter_top.material_override = brass_mat
	counter_top.position = Vector3(0, 1.18, -1.05)
	pivot.add_child(counter_top)
	# ---- Slanted wooden roof (single panel sloping forward) ----
	var roof: MeshInstance3D = MeshInstance3D.new()
	var rm: BoxMesh = BoxMesh.new()
	rm.size = Vector3(3.60, 0.18, 3.20)
	roof.mesh = rm
	roof.material_override = wood_mat
	roof.position = Vector3(0, 3.30, 0)
	roof.rotation.x = -0.30
	pivot.add_child(roof)
	# Brass roof front edge trim
	var roof_trim: MeshInstance3D = MeshInstance3D.new()
	var rtm: BoxMesh = BoxMesh.new()
	rtm.size = Vector3(3.60, 0.10, 0.10)
	roof_trim.mesh = rtm
	roof_trim.material_override = brass_mat
	roof_trim.position = Vector3(0, 2.85, -1.55)
	pivot.add_child(roof_trim)
	# ---- Brass nameplate sign hanging over the counter ----
	var sign: MeshInstance3D = MeshInstance3D.new()
	var sgm: BoxMesh = BoxMesh.new()
	sgm.size = Vector3(2.40, 0.55, 0.10)
	sign.mesh = sgm
	sign.material_override = brass_mat
	sign.position = Vector3(0, 2.50, -1.40)
	pivot.add_child(sign)
	# Sign hanging chains
	for hcx in [-0.95, 0.95]:
		var chain: MeshInstance3D = MeshInstance3D.new()
		var chm: CylinderMesh = CylinderMesh.new()
		chm.top_radius = 0.025
		chm.bottom_radius = 0.025
		chm.height = 0.45
		chain.mesh = chm
		chain.material_override = iron_mat
		chain.position = Vector3(hcx, 2.95, -1.40)
		pivot.add_child(chain)
	# Sign letter blocks (5 glowing cyan letters)
	for i in 5:
		var lx: float = -0.85 + float(i) * 0.42
		var letter: MeshInstance3D = MeshInstance3D.new()
		var llm: BoxMesh = BoxMesh.new()
		llm.size = Vector3(0.25, 0.35, 0.06)
		letter.mesh = llm
		letter.material_override = book_mat
		letter.position = Vector3(lx, 2.50, -1.46)
		pivot.add_child(letter)
	# ---- 2 hanging brass lanterns from the roof front edge ----
	for hlx in [-1.30, 1.30]:
		# Cord
		var cord: MeshInstance3D = MeshInstance3D.new()
		var crm: CylinderMesh = CylinderMesh.new()
		crm.top_radius = 0.025
		crm.bottom_radius = 0.025
		crm.height = 0.55
		cord.mesh = crm
		cord.material_override = iron_mat
		cord.position = Vector3(hlx, 2.55, -1.55)
		pivot.add_child(cord)
		# Bulb
		var bulb: MeshInstance3D = MeshInstance3D.new()
		var blm: SphereMesh = SphereMesh.new()
		blm.radius = 0.16
		blm.height = 0.32
		bulb.mesh = blm
		bulb.material_override = bulb_mat
		bulb.position = Vector3(hlx, 2.20, -1.55)
		pivot.add_child(bulb)
		# Lantern OmniLight
		var lt: OmniLight3D = OmniLight3D.new()
		lt.position = Vector3(hlx, 2.20, -1.55)
		lt.light_color = Color(1.0, 0.65, 0.20)
		lt.light_energy = 2.6
		lt.omni_range = 6.5
		pivot.add_child(lt)
	# ---- Strong cyan book glow OmniLight ----
	var lt: OmniLight3D = OmniLight3D.new()
	lt.position = Vector3(0, 1.55, 0.50)
	lt.light_color = Color(0.45, 0.85, 1.0)
	lt.light_energy = 2.4
	lt.omni_range = 7.5
	pivot.add_child(lt)
	# Pulse for books
	var bpulse2: Tween = pivot.create_tween().set_loops()
	bpulse2.tween_property(book_mat, "emission_energy_multiplier", 7.5, 2.0).set_ease(Tween.EASE_IN_OUT)
	bpulse2.tween_property(book_mat, "emission_energy_multiplier", 4.0, 2.0).set_ease(Tween.EASE_IN_OUT)


func _build_th_postman_npc(town: Node) -> void:
	## Epic-10 T57: Postman Quill — courier NPC standing in the courier
	## hut doorway. Brown leather courier coat, brass shoulder strap +
	## leather satchel, peaked brass cap, sealed letter held in his right
	## hand on a present pivot.
	var slots: Node3D = town.get_node_or_null("NPCSlots") as Node3D
	if slots == null:
		return
	var slot: Marker3D = Marker3D.new()
	slot.name = "THPostmanQuillSlot"
	# Stand in front of the courier hut doorway (NW radial at 12.5, hut faces inward)
	var ang: float = 3.0 * PI / 4.0
	# Slightly outside the hut along the inward direction
	slot.position = TOWN_CENTER + Vector3(cos(ang) * 11.20, 0, sin(ang) * 11.20)
	slots.add_child(slot)
	var npc_scene: PackedScene = load("res://scenes/entities/npcs/VillagerR3.tscn") as PackedScene
	if npc_scene == null:
		return
	var npc: Node3D = npc_scene.instantiate() as Node3D
	npc.name = "THPostmanQuill"
	if "npc_name" in npc:
		npc.set("npc_name", "Postman Quill")
	if "npc_id" in npc:
		npc.set("npc_id", "th_postman_quill")
	# Face inward toward the beacon
	npc.rotation.y = -ang + PI / 2.0
	slot.add_child(npc)
	# Materials
	var coat_mat: StandardMaterial3D = StandardMaterial3D.new()
	coat_mat.albedo_color = Color(0.30, 0.20, 0.12)
	coat_mat.roughness = 0.85
	coat_mat.metallic = 0.18
	coat_mat.emission_enabled = true
	coat_mat.emission = Color(0.55, 0.30, 0.10)
	coat_mat.emission_energy_multiplier = 0.20
	var leather_mat: StandardMaterial3D = StandardMaterial3D.new()
	leather_mat.albedo_color = Color(0.18, 0.10, 0.06)
	leather_mat.roughness = 0.85
	leather_mat.metallic = 0.10
	var brass_mat: StandardMaterial3D = StandardMaterial3D.new()
	brass_mat.albedo_color = Color(0.85, 0.55, 0.18)
	brass_mat.metallic = 0.95
	brass_mat.roughness = 0.30
	brass_mat.emission_enabled = true
	brass_mat.emission = Color(1.0, 0.50, 0.10)
	brass_mat.emission_energy_multiplier = 0.55
	var paper_mat: StandardMaterial3D = StandardMaterial3D.new()
	paper_mat.albedo_color = Color(0.95, 0.85, 0.55)
	paper_mat.roughness = 0.85
	paper_mat.emission_enabled = true
	paper_mat.emission = Color(1.0, 0.65, 0.20)
	paper_mat.emission_energy_multiplier = 0.40
	var seal_mat: StandardMaterial3D = StandardMaterial3D.new()
	seal_mat.albedo_color = Color(1.0, 0.55, 0.10)
	seal_mat.emission_enabled = true
	seal_mat.emission = Color(1.0, 0.55, 0.10)
	seal_mat.emission_energy_multiplier = 6.5
	seal_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	# ---- Brown leather courier coat ----
	var coat: MeshInstance3D = MeshInstance3D.new()
	var cmesh: BoxMesh = BoxMesh.new()
	cmesh.size = Vector3(1.05, 1.45, 0.55)
	coat.mesh = cmesh
	coat.material_override = coat_mat
	coat.position = Vector3(0, 1.10, 0)
	npc.add_child(coat)
	# Brass collar trim
	var collar: MeshInstance3D = MeshInstance3D.new()
	var colm: BoxMesh = BoxMesh.new()
	colm.size = Vector3(1.05, 0.10, 0.55)
	collar.mesh = colm
	collar.material_override = brass_mat
	collar.position = Vector3(0, 1.85, 0)
	npc.add_child(collar)
	# 3 brass front buttons
	for by in [1.55, 1.30, 1.05]:
		var btn: MeshInstance3D = MeshInstance3D.new()
		var bm: SphereMesh = SphereMesh.new()
		bm.radius = 0.05
		bm.height = 0.10
		btn.mesh = bm
		btn.material_override = brass_mat
		btn.position = Vector3(0, by, -0.30)
		npc.add_child(btn)
	# ---- Diagonal brass shoulder strap (left shoulder to right hip) ----
	var strap: MeshInstance3D = MeshInstance3D.new()
	var stm: BoxMesh = BoxMesh.new()
	stm.size = Vector3(0.10, 1.30, 0.06)
	strap.mesh = stm
	strap.material_override = brass_mat
	strap.position = Vector3(0, 1.40, -0.32)
	strap.rotation.z = 0.45
	npc.add_child(strap)
	# Leather satchel at his right hip
	var satchel: MeshInstance3D = MeshInstance3D.new()
	var sbm: BoxMesh = BoxMesh.new()
	sbm.size = Vector3(0.50, 0.45, 0.18)
	satchel.mesh = sbm
	satchel.material_override = leather_mat
	satchel.position = Vector3(0.55, 0.90, -0.05)
	npc.add_child(satchel)
	# Satchel brass clasp
	var clasp: MeshInstance3D = MeshInstance3D.new()
	var clm: BoxMesh = BoxMesh.new()
	clm.size = Vector3(0.16, 0.10, 0.06)
	clasp.mesh = clm
	clasp.material_override = brass_mat
	clasp.position = Vector3(0.55, 1.05, -0.16)
	npc.add_child(clasp)
	# Glowing data tag on the satchel (small unshaded amber dot)
	var tag: MeshInstance3D = MeshInstance3D.new()
	var tgm: SphereMesh = SphereMesh.new()
	tgm.radius = 0.06
	tgm.height = 0.12
	tag.mesh = tgm
	tag.material_override = seal_mat
	tag.position = Vector3(0.55, 0.85, -0.18)
	npc.add_child(tag)
	# ---- Peaked brass cap on the head ----
	var cap_band: MeshInstance3D = MeshInstance3D.new()
	var cbm: TorusMesh = TorusMesh.new()
	cbm.inner_radius = 0.30
	cbm.outer_radius = 0.36
	cap_band.mesh = cbm
	cap_band.material_override = brass_mat
	cap_band.position = Vector3(0, 1.95, 0)
	cap_band.rotation.x = PI / 2.0
	npc.add_child(cap_band)
	# Cap top (small dome)
	var cap_top: MeshInstance3D = MeshInstance3D.new()
	var ctm: SphereMesh = SphereMesh.new()
	ctm.radius = 0.32
	ctm.height = 0.45
	cap_top.mesh = ctm
	cap_top.material_override = coat_mat
	cap_top.position = Vector3(0, 2.10, 0)
	cap_top.scale = Vector3(1.0, 0.55, 1.0)
	npc.add_child(cap_top)
	# Cap front bill (small flat box poking forward)
	var bill: MeshInstance3D = MeshInstance3D.new()
	var blm: BoxMesh = BoxMesh.new()
	blm.size = Vector3(0.40, 0.06, 0.20)
	bill.mesh = blm
	bill.material_override = brass_mat
	bill.position = Vector3(0, 1.90, -0.30)
	npc.add_child(bill)
	# ---- Left arm at his side ----
	var left_arm: MeshInstance3D = MeshInstance3D.new()
	var lam: BoxMesh = BoxMesh.new()
	lam.size = Vector3(0.18, 0.85, 0.18)
	left_arm.mesh = lam
	left_arm.material_override = coat_mat
	left_arm.position = Vector3(-0.55, 1.05, 0)
	npc.add_child(left_arm)
	# ---- Right arm + sealed letter on a present pivot ----
	var present_pivot: Node3D = Node3D.new()
	present_pivot.position = Vector3(0.55, 1.50, 0)
	npc.add_child(present_pivot)
	var right_arm: MeshInstance3D = MeshInstance3D.new()
	var ram: BoxMesh = BoxMesh.new()
	ram.size = Vector3(0.18, 0.85, 0.18)
	right_arm.mesh = ram
	right_arm.material_override = coat_mat
	right_arm.position = Vector3(0, -0.42, 0)
	present_pivot.add_child(right_arm)
	# Sealed letter (small flat papyrus rectangle)
	var letter: MeshInstance3D = MeshInstance3D.new()
	var ltm: BoxMesh = BoxMesh.new()
	ltm.size = Vector3(0.32, 0.40, 0.04)
	letter.mesh = ltm
	letter.material_override = paper_mat
	letter.position = Vector3(0, -0.95, 0)
	present_pivot.add_child(letter)
	# Glowing wax seal on the letter (small unshaded amber dot)
	var seal: MeshInstance3D = MeshInstance3D.new()
	var slm: SphereMesh = SphereMesh.new()
	slm.radius = 0.06
	slm.height = 0.12
	seal.mesh = slm
	seal.material_override = seal_mat
	seal.position = Vector3(0, -0.95, -0.04)
	present_pivot.add_child(seal)
	# Initial pose — arm raised forward presenting the letter
	present_pivot.rotation.x = -1.20
	# ---- Subtle warm OmniLight ----
	var lt: OmniLight3D = OmniLight3D.new()
	lt.position = Vector3(0, 1.55, -0.30)
	lt.light_color = Color(1.0, 0.65, 0.20)
	lt.light_energy = 1.6
	lt.omni_range = 4.5
	npc.add_child(lt)
	# ---- Slow present-and-recover gesture tween (offers letter forward then back) ----
	var present: Tween = npc.create_tween().set_loops()
	present.tween_property(present_pivot, "rotation:x", -1.55, 0.55).set_ease(Tween.EASE_OUT)
	present.tween_property(present_pivot, "rotation:x", -1.20, 0.45).set_ease(Tween.EASE_IN)
	present.tween_property(present_pivot, "rotation:x", -1.20, 1.60)
	# Seal + tag pulse
	var spulse: Tween = npc.create_tween().set_loops()
	spulse.tween_property(seal_mat, "emission_energy_multiplier", 8.5, 1.4).set_ease(Tween.EASE_IN_OUT)
	spulse.tween_property(seal_mat, "emission_energy_multiplier", 5.0, 1.4).set_ease(Tween.EASE_IN_OUT)


func _build_th_bookkeeper_npc(town: Node) -> void:
	## Epic-10 T58: Bookstall Keeper Inkwell — librarian NPC standing
	## behind the bookstall counter, holding an open glowing book.
	## Long blue scholar robe with brass collar trim, brass quill pinned
	## at the shoulder, monocle eyepiece, open book held in both hands
	## at chest height with cyan glowing pages.
	var slots: Node3D = town.get_node_or_null("NPCSlots") as Node3D
	if slots == null:
		return
	var slot: Marker3D = Marker3D.new()
	slot.name = "THBookstallKeeperSlot"
	# Stand behind the bookstall counter (SE perimeter at radius 13.0, slightly inside the building)
	var ang: float = 7.0 * PI / 4.0
	slot.position = TOWN_CENTER + Vector3(cos(ang) * 13.20, 0, sin(ang) * 13.20)
	slots.add_child(slot)
	var npc_scene: PackedScene = load("res://scenes/entities/npcs/VillagerR3.tscn") as PackedScene
	if npc_scene == null:
		return
	var npc: Node3D = npc_scene.instantiate() as Node3D
	npc.name = "THBookstallKeeperInkwell"
	if "npc_name" in npc:
		npc.set("npc_name", "Bookstall Keeper Inkwell")
	if "npc_id" in npc:
		npc.set("npc_id", "th_bookstall_keeper_inkwell")
	# Face inward toward the beacon
	npc.rotation.y = -ang + PI / 2.0
	slot.add_child(npc)
	# Materials
	var robe_mat: StandardMaterial3D = StandardMaterial3D.new()
	robe_mat.albedo_color = Color(0.18, 0.30, 0.55)
	robe_mat.roughness = 0.85
	robe_mat.metallic = 0.18
	robe_mat.emission_enabled = true
	robe_mat.emission = Color(0.30, 0.55, 1.0)
	robe_mat.emission_energy_multiplier = 0.30
	var brass_mat: StandardMaterial3D = StandardMaterial3D.new()
	brass_mat.albedo_color = Color(0.85, 0.55, 0.18)
	brass_mat.metallic = 0.95
	brass_mat.roughness = 0.30
	brass_mat.emission_enabled = true
	brass_mat.emission = Color(1.0, 0.50, 0.10)
	brass_mat.emission_energy_multiplier = 0.55
	var data_mat: StandardMaterial3D = StandardMaterial3D.new()
	data_mat.albedo_color = Color(0.45, 0.85, 1.0)
	data_mat.emission_enabled = true
	data_mat.emission = Color(0.45, 0.85, 1.0)
	data_mat.emission_energy_multiplier = 6.5
	data_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var leather_mat: StandardMaterial3D = StandardMaterial3D.new()
	leather_mat.albedo_color = Color(0.32, 0.20, 0.12)
	leather_mat.roughness = 0.85
	leather_mat.metallic = 0.10
	# ---- Long blue scholar robe ----
	var robe: MeshInstance3D = MeshInstance3D.new()
	var rmesh: BoxMesh = BoxMesh.new()
	rmesh.size = Vector3(0.95, 1.75, 0.55)
	robe.mesh = rmesh
	robe.material_override = robe_mat
	robe.position = Vector3(0, 0.90, 0)
	npc.add_child(robe)
	# Brass collar trim
	var collar: MeshInstance3D = MeshInstance3D.new()
	var colm: BoxMesh = BoxMesh.new()
	colm.size = Vector3(0.95, 0.10, 0.55)
	collar.mesh = colm
	collar.material_override = brass_mat
	collar.position = Vector3(0, 1.80, 0)
	npc.add_child(collar)
	# Vertical brass robe trim
	var seam: MeshInstance3D = MeshInstance3D.new()
	var seamesh: BoxMesh = BoxMesh.new()
	seamesh.size = Vector3(0.16, 1.65, 0.06)
	seam.mesh = seamesh
	seam.material_override = brass_mat
	seam.position = Vector3(0, 0.95, -0.30)
	npc.add_child(seam)
	# ---- Brass quill pinned at the shoulder ----
	var quill_post: MeshInstance3D = MeshInstance3D.new()
	var qpm: SphereMesh = SphereMesh.new()
	qpm.radius = 0.08
	qpm.height = 0.16
	quill_post.mesh = qpm
	quill_post.material_override = brass_mat
	quill_post.position = Vector3(-0.40, 1.65, -0.20)
	npc.add_child(quill_post)
	var quill_feather: MeshInstance3D = MeshInstance3D.new()
	var qfm: PrismMesh = PrismMesh.new()
	qfm.size = Vector3(0.10, 0.40, 0.06)
	quill_feather.mesh = qfm
	quill_feather.material_override = data_mat
	quill_feather.position = Vector3(-0.40, 1.95, -0.30)
	quill_feather.rotation.z = -0.40
	npc.add_child(quill_feather)
	# ---- Brass monocle eyepiece on the right side of the head ----
	var monocle_frame: MeshInstance3D = MeshInstance3D.new()
	var mfm: TorusMesh = TorusMesh.new()
	mfm.inner_radius = 0.10
	mfm.outer_radius = 0.14
	monocle_frame.mesh = mfm
	monocle_frame.material_override = brass_mat
	monocle_frame.position = Vector3(0.18, 1.92, -0.30)
	monocle_frame.rotation.y = PI / 2.0
	npc.add_child(monocle_frame)
	# Glowing monocle lens
	var lens: MeshInstance3D = MeshInstance3D.new()
	var lm: SphereMesh = SphereMesh.new()
	lm.radius = 0.09
	lm.height = 0.10
	lens.mesh = lm
	lens.material_override = data_mat
	lens.position = Vector3(0.18, 1.92, -0.30)
	lens.scale = Vector3(1.0, 1.0, 0.30)
	npc.add_child(lens)
	# Monocle chain to the collar
	var chain: MeshInstance3D = MeshInstance3D.new()
	var chm: CylinderMesh = CylinderMesh.new()
	chm.top_radius = 0.012
	chm.bottom_radius = 0.012
	chm.height = 0.55
	chain.mesh = chm
	chain.material_override = brass_mat
	chain.position = Vector3(0.30, 1.65, -0.30)
	chain.rotation.z = -0.40
	npc.add_child(chain)
	# ---- Open book held in both hands at chest height ----
	# Book base (closed leather cover behind the open pages)
	var book_back: MeshInstance3D = MeshInstance3D.new()
	var bbm: BoxMesh = BoxMesh.new()
	bbm.size = Vector3(0.65, 0.45, 0.08)
	book_back.mesh = bbm
	book_back.material_override = leather_mat
	book_back.position = Vector3(0, 1.20, -0.45)
	book_back.rotation.x = 0.30
	npc.add_child(book_back)
	# Open page (glowing cyan rectangle on top of the cover)
	var page: MeshInstance3D = MeshInstance3D.new()
	var pmm: BoxMesh = BoxMesh.new()
	pmm.size = Vector3(0.55, 0.40, 0.04)
	page.mesh = pmm
	page.material_override = data_mat
	page.position = Vector3(0, 1.27, -0.50)
	page.rotation.x = 0.30
	npc.add_child(page)
	# Page center seam (where the book opens)
	var page_seam: MeshInstance3D = MeshInstance3D.new()
	var psm: BoxMesh = BoxMesh.new()
	psm.size = Vector3(0.04, 0.40, 0.06)
	page_seam.mesh = psm
	page_seam.material_override = brass_mat
	page_seam.position = Vector3(0, 1.27, -0.51)
	page_seam.rotation.x = 0.30
	npc.add_child(page_seam)
	# Floating data motes rising from the open page
	var motes: GPUParticles3D = GPUParticles3D.new()
	motes.position = Vector3(0, 1.40, -0.55)
	motes.amount = 12
	motes.lifetime = 1.8
	var pmat: ParticleProcessMaterial = ParticleProcessMaterial.new()
	pmat.direction = Vector3(0, 1, 0)
	pmat.spread = 14.0
	pmat.initial_velocity_min = 0.4
	pmat.initial_velocity_max = 0.8
	pmat.gravity = Vector3(0, 0.10, 0)
	pmat.scale_min = 0.04
	pmat.scale_max = 0.08
	pmat.color = Color(0.45, 0.85, 1.0, 1.0)
	motes.process_material = pmat
	var psmesh: SphereMesh = SphereMesh.new()
	psmesh.radius = 0.04
	psmesh.height = 0.08
	motes.draw_pass_1 = psmesh
	npc.add_child(motes)
	# ---- Subtle warm cyan OmniLight ----
	var lt: OmniLight3D = OmniLight3D.new()
	lt.position = Vector3(0, 1.55, -0.30)
	lt.light_color = Color(0.65, 0.85, 1.0)
	lt.light_energy = 1.6
	lt.omni_range = 4.5
	npc.add_child(lt)
	# ---- Slow head bob (reading the book) tween ----
	var read: Tween = npc.create_tween().set_loops()
	read.tween_property(npc, "rotation:x", 0.18, 1.8).set_ease(Tween.EASE_IN_OUT)
	read.tween_property(npc, "rotation:x", 0.05, 1.8).set_ease(Tween.EASE_IN_OUT)
	# Pages + monocle pulse
	var dpulse: Tween = npc.create_tween().set_loops()
	dpulse.tween_property(data_mat, "emission_energy_multiplier", 8.5, 1.6).set_ease(Tween.EASE_IN_OUT)
	dpulse.tween_property(data_mat, "emission_energy_multiplier", 5.0, 1.6).set_ease(Tween.EASE_IN_OUT)


func _build_th_sweeper_bot_npc(town: Node) -> void:
	## Epic-10 T59: Sweeper Bot Tidy — small floating cleaning drone NPC
	## that orbits at ground level around the central beacon. Brass disc
	## body with cyan eye + 2 brushy underside arms (small cyan strips
	## that drag on the ground), tiny brass propeller cap on top.
	## Different from the patrol guard / running child / courier drones
	## by orbiting tighter and lower (ground level, 6m radius, 8s loop).
	var slots: Node3D = town.get_node_or_null("NPCSlots") as Node3D
	if slots == null:
		return
	# Orbit pivot — the slot itself, will be rotated around Y for orbit
	var orbit_slot: Marker3D = Marker3D.new()
	orbit_slot.name = "THSweeperBotOrbit"
	orbit_slot.position = TOWN_CENTER + Vector3(0, 0, 0)
	# Different starting phase from the other moving NPCs
	orbit_slot.rotation.y = PI / 3.0
	slots.add_child(orbit_slot)
	var npc_scene: PackedScene = load("res://scenes/entities/npcs/VillagerR3.tscn") as PackedScene
	if npc_scene == null:
		return
	var npc: Node3D = npc_scene.instantiate() as Node3D
	npc.name = "THSweeperBotTidy"
	if "npc_name" in npc:
		npc.set("npc_name", "Sweeper Bot Tidy")
	if "npc_id" in npc:
		npc.set("npc_id", "th_sweeper_bot_tidy")
	# Offset the bot from the orbit center along +X (radius 6, low altitude 0.6)
	npc.position = Vector3(6.00, 0.55, 0)
	npc.rotation.y = PI / 2.0
	orbit_slot.add_child(npc)
	# Materials
	var brass_mat: StandardMaterial3D = StandardMaterial3D.new()
	brass_mat.albedo_color = Color(0.85, 0.55, 0.18)
	brass_mat.metallic = 0.95
	brass_mat.roughness = 0.30
	brass_mat.emission_enabled = true
	brass_mat.emission = Color(1.0, 0.50, 0.10)
	brass_mat.emission_energy_multiplier = 0.55
	var data_mat: StandardMaterial3D = StandardMaterial3D.new()
	data_mat.albedo_color = Color(0.45, 0.85, 1.0)
	data_mat.emission_enabled = true
	data_mat.emission = Color(0.45, 0.85, 1.0)
	data_mat.emission_energy_multiplier = 7.0
	data_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	# ---- Brass disc body (flat cylinder) ----
	var body: MeshInstance3D = MeshInstance3D.new()
	var bm: CylinderMesh = CylinderMesh.new()
	bm.top_radius = 0.30
	bm.bottom_radius = 0.30
	bm.height = 0.18
	body.mesh = bm
	body.material_override = brass_mat
	body.position = Vector3(0, 0, 0)
	npc.add_child(body)
	# Brass rim trim torus
	var rim: MeshInstance3D = MeshInstance3D.new()
	var rim_m: TorusMesh = TorusMesh.new()
	rim_m.inner_radius = 0.27
	rim_m.outer_radius = 0.32
	rim.mesh = rim_m
	rim.material_override = brass_mat
	rim.position = Vector3(0, 0.10, 0)
	npc.add_child(rim)
	# ---- Glowing cyan eye dot on the front of the body ----
	var eye: MeshInstance3D = MeshInstance3D.new()
	var em: SphereMesh = SphereMesh.new()
	em.radius = 0.06
	em.height = 0.12
	eye.mesh = em
	eye.material_override = data_mat
	eye.position = Vector3(0, 0.08, -0.27)
	npc.add_child(eye)
	# ---- 2 brush-strip underside arms (small cyan strips dragging on the ground) ----
	for bx in [-0.20, 0.20]:
		var brush: MeshInstance3D = MeshInstance3D.new()
		var brm: BoxMesh = BoxMesh.new()
		brm.size = Vector3(0.10, 0.06, 0.40)
		brush.mesh = brm
		brush.material_override = data_mat
		brush.position = Vector3(bx, -0.40, 0)
		npc.add_child(brush)
	# ---- Tiny brass propeller cap on top ----
	var prop_pivot: Node3D = Node3D.new()
	prop_pivot.position = Vector3(0, 0.18, 0)
	npc.add_child(prop_pivot)
	# 4 small propeller blades
	for p in 4:
		var pang: float = float(p) / 4.0 * TAU
		var blade: MeshInstance3D = MeshInstance3D.new()
		var blm: BoxMesh = BoxMesh.new()
		blm.size = Vector3(0.30, 0.03, 0.06)
		blade.mesh = blm
		blade.material_override = brass_mat
		blade.position = Vector3(cos(pang) * 0.13, 0, sin(pang) * 0.13)
		blade.rotation.y = pang
		prop_pivot.add_child(blade)
	# Prop hub cap
	var hub: MeshInstance3D = MeshInstance3D.new()
	var hbm: SphereMesh = SphereMesh.new()
	hbm.radius = 0.05
	hbm.height = 0.10
	hub.mesh = hbm
	hub.material_override = brass_mat
	hub.position = Vector3(0, 0.04, 0)
	prop_pivot.add_child(hub)
	# ---- Subtle cyan ground glow OmniLight ----
	var lt: OmniLight3D = OmniLight3D.new()
	lt.position = Vector3(0, -0.30, 0)
	lt.light_color = Color(0.55, 0.95, 1.0)
	lt.light_energy = 1.2
	lt.omni_range = 3.0
	npc.add_child(lt)
	# ---- Tweens ----
	# Fast prop spin
	var prop_spin: Tween = npc.create_tween().set_loops()
	prop_spin.tween_property(prop_pivot, "rotation:y", TAU, 0.8)
	# Orbit (8s loop, opposite direction from the patrol guard so the 3 movers
	# never converge — guard CW 32s, child CCW 12s, sweeper CW 8s)
	var orbit: Tween = npc.create_tween().set_loops()
	orbit.tween_property(orbit_slot, "rotation:y", PI / 3.0 + TAU, 8.0)
	# Subtle hover bob (Y oscillation)
	var bob: Tween = npc.create_tween().set_loops()
	bob.tween_property(npc, "position:y", 0.70, 1.4).set_ease(Tween.EASE_IN_OUT)
	bob.tween_property(npc, "position:y", 0.45, 1.4).set_ease(Tween.EASE_IN_OUT)
	# Eye + brush pulse
	var dpulse2: Tween = npc.create_tween().set_loops()
	dpulse2.tween_property(data_mat, "emission_energy_multiplier", 8.5, 1.4).set_ease(Tween.EASE_IN_OUT)
	dpulse2.tween_property(data_mat, "emission_energy_multiplier", 5.0, 1.4).set_ease(Tween.EASE_IN_OUT)


func _build_th_bellringer_npc(town: Node) -> void:
	## Epic-10 T60: Bellringer Tolling — bellringer NPC standing at the
	## base of the bell tower (T26 NE outer corner), pulling a rope that
	## disappears up into the tower base. Brown homespun robe with rope
	## belt, both arms grasping the rope, body sway tween synced with
	## the bell tower's bell sway.
	var slots: Node3D = town.get_node_or_null("NPCSlots") as Node3D
	if slots == null:
		return
	var slot: Marker3D = Marker3D.new()
	slot.name = "THBellringerSlot"
	# Stand at the base of the bell tower (T26 NE outer corner at radius 16.5)
	# Position slightly inside the tower toward the plaza
	var ang: float = PI / 4.0
	slot.position = TOWN_CENTER + Vector3(cos(ang) * 14.50, 0, sin(ang) * 14.50)
	slots.add_child(slot)
	var npc_scene: PackedScene = load("res://scenes/entities/npcs/VillagerR3.tscn") as PackedScene
	if npc_scene == null:
		return
	var npc: Node3D = npc_scene.instantiate() as Node3D
	npc.name = "THBellringerTolling"
	if "npc_name" in npc:
		npc.set("npc_name", "Bellringer Tolling")
	if "npc_id" in npc:
		npc.set("npc_id", "th_bellringer_tolling")
	# Face the bell tower (outward toward NE corner)
	npc.rotation.y = -ang + PI / 2.0
	slot.add_child(npc)
	# Materials
	var robe_mat: StandardMaterial3D = StandardMaterial3D.new()
	robe_mat.albedo_color = Color(0.32, 0.20, 0.12)
	robe_mat.roughness = 0.92
	robe_mat.metallic = 0.05
	robe_mat.emission_enabled = true
	robe_mat.emission = Color(0.65, 0.40, 0.10)
	robe_mat.emission_energy_multiplier = 0.20
	var rope_mat: StandardMaterial3D = StandardMaterial3D.new()
	rope_mat.albedo_color = Color(0.42, 0.32, 0.18)
	rope_mat.roughness = 0.95
	rope_mat.metallic = 0.05
	var brass_mat: StandardMaterial3D = StandardMaterial3D.new()
	brass_mat.albedo_color = Color(0.85, 0.55, 0.18)
	brass_mat.metallic = 0.95
	brass_mat.roughness = 0.30
	brass_mat.emission_enabled = true
	brass_mat.emission = Color(1.0, 0.50, 0.10)
	brass_mat.emission_energy_multiplier = 0.55
	var ember_mat: StandardMaterial3D = StandardMaterial3D.new()
	ember_mat.albedo_color = Color(1.0, 0.55, 0.10)
	ember_mat.emission_enabled = true
	ember_mat.emission = Color(1.0, 0.55, 0.10)
	ember_mat.emission_energy_multiplier = 5.5
	ember_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	# ---- Brown homespun robe (full-body box) ----
	var robe: MeshInstance3D = MeshInstance3D.new()
	var rmesh: BoxMesh = BoxMesh.new()
	rmesh.size = Vector3(0.95, 1.85, 0.55)
	robe.mesh = rmesh
	robe.material_override = robe_mat
	robe.position = Vector3(0, 0.95, 0)
	npc.add_child(robe)
	# Hood (rounded sphere on top)
	var hood: MeshInstance3D = MeshInstance3D.new()
	var hmm: SphereMesh = SphereMesh.new()
	hmm.radius = 0.40
	hmm.height = 0.65
	hood.mesh = hmm
	hood.material_override = robe_mat
	hood.position = Vector3(0, 1.95, 0)
	hood.scale = Vector3(1.0, 0.85, 1.0)
	npc.add_child(hood)
	# Hood inner shadow box
	var shadow_mat: StandardMaterial3D = StandardMaterial3D.new()
	shadow_mat.albedo_color = Color(0.02, 0.02, 0.02)
	shadow_mat.roughness = 1.0
	shadow_mat.metallic = 0.0
	var shadow: MeshInstance3D = MeshInstance3D.new()
	var shmm: BoxMesh = BoxMesh.new()
	shmm.size = Vector3(0.40, 0.30, 0.04)
	shadow.mesh = shmm
	shadow.material_override = shadow_mat
	shadow.position = Vector3(0, 1.92, -0.34)
	npc.add_child(shadow)
	# 2 ember eye dots inside the hood
	for ex in [-0.10, 0.10]:
		var eye: MeshInstance3D = MeshInstance3D.new()
		var em: SphereMesh = SphereMesh.new()
		em.radius = 0.04
		em.height = 0.08
		eye.mesh = em
		eye.material_override = ember_mat
		eye.position = Vector3(ex, 1.95, -0.36)
		npc.add_child(eye)
	# ---- Rope belt at the waist ----
	var belt: MeshInstance3D = MeshInstance3D.new()
	var btm: TorusMesh = TorusMesh.new()
	btm.inner_radius = 0.42
	btm.outer_radius = 0.50
	belt.mesh = btm
	belt.material_override = rope_mat
	belt.position = Vector3(0, 0.90, 0)
	belt.rotation.x = PI / 2.0
	npc.add_child(belt)
	# Belt knot dangling at the front
	var knot: MeshInstance3D = MeshInstance3D.new()
	var knm: SphereMesh = SphereMesh.new()
	knm.radius = 0.10
	knm.height = 0.20
	knot.mesh = knm
	knot.material_override = rope_mat
	knot.position = Vector3(0, 0.80, -0.42)
	npc.add_child(knot)
	# ---- Both arms grasping the rope ----
	# Left arm at chest height
	var left_arm: MeshInstance3D = MeshInstance3D.new()
	var lam: BoxMesh = BoxMesh.new()
	lam.size = Vector3(0.18, 0.85, 0.18)
	left_arm.mesh = lam
	left_arm.material_override = robe_mat
	left_arm.position = Vector3(-0.40, 1.40, -0.30)
	left_arm.rotation.x = -PI / 4.0
	npc.add_child(left_arm)
	# Right arm at chest height
	var right_arm: MeshInstance3D = MeshInstance3D.new()
	right_arm.mesh = lam
	right_arm.material_override = robe_mat
	right_arm.position = Vector3(0.40, 1.40, -0.30)
	right_arm.rotation.x = -PI / 4.0
	npc.add_child(right_arm)
	# ---- Bell rope reaching from the hands up out of sight ----
	# The rope visually disappears upward toward the bell tower
	var rope: MeshInstance3D = MeshInstance3D.new()
	var rpmm: CylinderMesh = CylinderMesh.new()
	rpmm.top_radius = 0.05
	rpmm.bottom_radius = 0.05
	rpmm.height = 4.50
	rope.mesh = rpmm
	rope.material_override = rope_mat
	rope.position = Vector3(0, 3.85, -0.55)
	npc.add_child(rope)
	# Rope grip handle (small brass loop where the hands hold)
	var grip: MeshInstance3D = MeshInstance3D.new()
	var gmm: TorusMesh = TorusMesh.new()
	gmm.inner_radius = 0.10
	gmm.outer_radius = 0.13
	grip.mesh = gmm
	grip.material_override = brass_mat
	grip.position = Vector3(0, 1.55, -0.55)
	grip.rotation.x = PI / 2.0
	npc.add_child(grip)
	# ---- Subtle warm OmniLight ----
	var lt: OmniLight3D = OmniLight3D.new()
	lt.position = Vector3(0, 1.65, -0.30)
	lt.light_color = Color(1.0, 0.55, 0.15)
	lt.light_energy = 1.4
	lt.omni_range = 4.0
	npc.add_child(lt)
	# ---- Body sway tween (synchronized with the bell tower's bell) ----
	# Use the entire npc node so body + arms + rope all sway together
	var sway: Tween = npc.create_tween().set_loops()
	sway.tween_property(npc, "rotation:z", 0.18, 2.0).set_ease(Tween.EASE_IN_OUT)
	sway.tween_property(npc, "rotation:z", -0.18, 2.0).set_ease(Tween.EASE_IN_OUT)
	# Eye pulse
	var epulse: Tween = npc.create_tween().set_loops()
	epulse.tween_property(ember_mat, "emission_energy_multiplier", 7.5, 1.6).set_ease(Tween.EASE_IN_OUT)
	epulse.tween_property(ember_mat, "emission_energy_multiplier", 4.5, 1.6).set_ease(Tween.EASE_IN_OUT)


func _build_th_fountain_cherub_sprites(geom: Node) -> void:
	## Epic-10 T61: Fountain Cherub Sprites — 4 small data-sprite cherub statues
	## perched on the rim of the central data fountain at the cardinal points,
	## each holding a glowing data orb above its head. Orbs pulse in a chase
	## sequence (N→E→S→W) creating a rotating "data heartbeat" around the pool.
	var pivot: Node3D = Node3D.new()
	pivot.name = "TH_FountainCherubSprites"
	pivot.position = TOWN_CENTER + Vector3(0, 0, 0)
	geom.add_child(pivot)
	# ---- Materials ----
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.55, 0.62, 0.72)
	stone_mat.metallic = 0.20
	stone_mat.roughness = 0.78
	stone_mat.emission_enabled = true
	stone_mat.emission = Color(0.40, 0.55, 0.85)
	stone_mat.emission_energy_multiplier = 0.22
	var moss_mat: StandardMaterial3D = StandardMaterial3D.new()
	moss_mat.albedo_color = Color(0.18, 0.42, 0.28)
	moss_mat.metallic = 0.05
	moss_mat.roughness = 0.95
	moss_mat.emission_enabled = true
	moss_mat.emission = Color(0.20, 0.55, 0.30)
	moss_mat.emission_energy_multiplier = 0.18
	var brass_mat: StandardMaterial3D = StandardMaterial3D.new()
	brass_mat.albedo_color = Color(0.85, 0.55, 0.18)
	brass_mat.metallic = 0.95
	brass_mat.roughness = 0.30
	brass_mat.emission_enabled = true
	brass_mat.emission = Color(1.0, 0.55, 0.12)
	brass_mat.emission_energy_multiplier = 0.50
	# Cherub geometry helper data
	var radius: float = 2.85  # fountain rim radius
	var rim_y: float = 0.55
	var orb_mats: Array[StandardMaterial3D] = []
	for i in range(4):
		var ang: float = float(i) * (PI / 2.0)  # N, E, S, W
		var px: float = cos(ang) * radius
		var pz: float = sin(ang) * radius
		var face_in: float = atan2(-px, -pz)
		var ch: Node3D = Node3D.new()
		ch.name = "Cherub_%d" % i
		ch.position = Vector3(px, rim_y, pz)
		ch.rotation.y = face_in
		pivot.add_child(ch)
		# Pedestal disc
		var ped: MeshInstance3D = MeshInstance3D.new()
		var pmm: CylinderMesh = CylinderMesh.new()
		pmm.top_radius = 0.32
		pmm.bottom_radius = 0.36
		pmm.height = 0.10
		ped.mesh = pmm
		ped.material_override = stone_mat
		ped.position = Vector3(0, 0.05, 0)
		ch.add_child(ped)
		# Body (small chubby torso)
		var body: MeshInstance3D = MeshInstance3D.new()
		var bmm: SphereMesh = SphereMesh.new()
		bmm.radius = 0.22
		bmm.height = 0.42
		body.mesh = bmm
		body.material_override = stone_mat
		body.position = Vector3(0, 0.32, 0)
		ch.add_child(body)
		# Head
		var head: MeshInstance3D = MeshInstance3D.new()
		var hmm: SphereMesh = SphereMesh.new()
		hmm.radius = 0.16
		hmm.height = 0.32
		head.mesh = hmm
		head.material_override = stone_mat
		head.position = Vector3(0, 0.62, 0)
		ch.add_child(head)
		# Tiny wings (two angled prisms)
		for s in [-1.0, 1.0]:
			var wing: MeshInstance3D = MeshInstance3D.new()
			var wmm: PrismMesh = PrismMesh.new()
			wmm.size = Vector3(0.10, 0.32, 0.05)
			wing.mesh = wmm
			wing.material_override = stone_mat
			wing.position = Vector3(0.18 * s, 0.40, 0.10)
			wing.rotation.z = 0.45 * s
			wing.rotation.y = 0.35 * s
			ch.add_child(wing)
		# Arms raised holding orb above head
		for s2 in [-1.0, 1.0]:
			var arm: MeshInstance3D = MeshInstance3D.new()
			var amm: CylinderMesh = CylinderMesh.new()
			amm.top_radius = 0.05
			amm.bottom_radius = 0.06
			amm.height = 0.34
			arm.mesh = amm
			arm.material_override = stone_mat
			arm.position = Vector3(0.10 * s2, 0.55, 0)
			arm.rotation.z = -0.50 * s2
			ch.add_child(arm)
		# Moss patches (flecks on the pedestal)
		for k in range(3):
			var moss: MeshInstance3D = MeshInstance3D.new()
			var mmm: SphereMesh = SphereMesh.new()
			mmm.radius = 0.04
			mmm.height = 0.04
			moss.mesh = mmm
			moss.material_override = moss_mat
			var ma: float = float(k) * (TAU / 3.0) + float(i) * 0.5
			moss.position = Vector3(cos(ma) * 0.30, 0.10, sin(ma) * 0.30)
			ch.add_child(moss)
		# Crown brass band on head
		var crown: MeshInstance3D = MeshInstance3D.new()
		var cmm: TorusMesh = TorusMesh.new()
		cmm.inner_radius = 0.14
		cmm.outer_radius = 0.17
		crown.mesh = cmm
		crown.material_override = brass_mat
		crown.position = Vector3(0, 0.66, 0)
		crown.rotation.x = PI / 2.0
		ch.add_child(crown)
		# Glowing data orb (held above head)
		var orb_mat: StandardMaterial3D = StandardMaterial3D.new()
		orb_mat.albedo_color = Color(0.40, 0.85, 1.0)
		orb_mat.emission_enabled = true
		orb_mat.emission = Color(0.45, 0.90, 1.0)
		orb_mat.emission_energy_multiplier = 5.5
		orb_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		orb_mats.append(orb_mat)
		var orb: MeshInstance3D = MeshInstance3D.new()
		var omm: SphereMesh = SphereMesh.new()
		omm.radius = 0.12
		omm.height = 0.24
		orb.mesh = omm
		orb.material_override = orb_mat
		orb.position = Vector3(0, 0.96, 0)
		ch.add_child(orb)
		# Subtle cyan light from orb
		var lt: OmniLight3D = OmniLight3D.new()
		lt.position = Vector3(0, 0.96, 0)
		lt.light_color = Color(0.45, 0.85, 1.0)
		lt.light_energy = 1.1
		lt.omni_range = 3.5
		ch.add_child(lt)
		# Tiny bob tween (per cherub)
		var bob: Tween = ch.create_tween().set_loops()
		bob.tween_property(orb, "position:y", 1.04, 1.4).set_ease(Tween.EASE_IN_OUT)
		bob.tween_property(orb, "position:y", 0.96, 1.4).set_ease(Tween.EASE_IN_OUT)
	# ---- Chase pulse: orbs flash N→E→S→W in sequence ----
	# Drive each orb's emission via a single tween chain on the pivot
	var chase: Tween = pivot.create_tween().set_loops()
	for i2 in range(4):
		var m: StandardMaterial3D = orb_mats[i2]
		chase.tween_property(m, "emission_energy_multiplier", 11.0, 0.18).set_ease(Tween.EASE_OUT)
		chase.tween_property(m, "emission_energy_multiplier", 5.5, 0.42).set_ease(Tween.EASE_IN)


func _build_th_iterations_memorial_wall(geom: Node) -> void:
	## Epic-10 T62: Heroes Memorial Wall — curved basalt-and-brass commemorative
	## wall in the SSE mid-plaza honoring the fallen heroes of the past 9
	## iterations. 9 small portrait niches (one per iteration), each lit by a
	## tiny brass candle, framed by a low arc wall and an offering bowl in
	## front. Faces toward the central beacon. Story-rich landmark.
	var pivot: Node3D = Node3D.new()
	pivot.name = "TH_IterationsMemorialWall"
	# SSE position at radius 12, angle ~-PI/3 (south-southeast)
	var ang_pos: float = -PI / 3.0
	var rad_pos: float = 12.0
	var px_p: float = cos(ang_pos) * rad_pos
	var pz_p: float = sin(ang_pos) * rad_pos
	pivot.position = TOWN_CENTER + Vector3(px_p, 0, pz_p)
	# Face toward town center
	pivot.rotation.y = atan2(-px_p, -pz_p)
	geom.add_child(pivot)
	# ---- Materials ----
	var basalt_mat: StandardMaterial3D = StandardMaterial3D.new()
	basalt_mat.albedo_color = Color(0.18, 0.20, 0.24)
	basalt_mat.metallic = 0.20
	basalt_mat.roughness = 0.85
	basalt_mat.emission_enabled = true
	basalt_mat.emission = Color(0.25, 0.40, 0.60)
	basalt_mat.emission_energy_multiplier = 0.20
	var brass_mat: StandardMaterial3D = StandardMaterial3D.new()
	brass_mat.albedo_color = Color(0.85, 0.55, 0.18)
	brass_mat.metallic = 0.95
	brass_mat.roughness = 0.30
	brass_mat.emission_enabled = true
	brass_mat.emission = Color(1.0, 0.50, 0.10)
	brass_mat.emission_energy_multiplier = 0.55
	var niche_mat: StandardMaterial3D = StandardMaterial3D.new()
	niche_mat.albedo_color = Color(0.10, 0.12, 0.16)
	niche_mat.metallic = 0.25
	niche_mat.roughness = 0.65
	niche_mat.emission_enabled = true
	niche_mat.emission = Color(0.20, 0.50, 0.85)
	niche_mat.emission_energy_multiplier = 0.30
	var flame_mat: StandardMaterial3D = StandardMaterial3D.new()
	flame_mat.albedo_color = Color(1.0, 0.55, 0.10)
	flame_mat.emission_enabled = true
	flame_mat.emission = Color(1.0, 0.60, 0.15)
	flame_mat.emission_energy_multiplier = 9.0
	flame_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var portrait_mat: StandardMaterial3D = StandardMaterial3D.new()
	portrait_mat.albedo_color = Color(0.45, 0.85, 1.0)
	portrait_mat.emission_enabled = true
	portrait_mat.emission = Color(0.50, 0.90, 1.0)
	portrait_mat.emission_energy_multiplier = 4.0
	portrait_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	# ---- Wall base plinth (long, curved-feel via 3 segments) ----
	var seg_count: int = 9
	var seg_w: float = 0.95
	var seg_gap: float = 0.05
	var total_w: float = seg_count * seg_w + (seg_count - 1) * seg_gap
	var start_x: float = -total_w * 0.5 + seg_w * 0.5
	# Long basalt floor footing
	var foot: MeshInstance3D = MeshInstance3D.new()
	var fmm: BoxMesh = BoxMesh.new()
	fmm.size = Vector3(total_w + 0.6, 0.20, 1.10)
	foot.mesh = fmm
	foot.material_override = basalt_mat
	foot.position = Vector3(0, 0.10, 0)
	pivot.add_child(foot)
	# Brass front trim along footing
	var trim: MeshInstance3D = MeshInstance3D.new()
	var tmm: BoxMesh = BoxMesh.new()
	tmm.size = Vector3(total_w + 0.6, 0.04, 0.06)
	trim.mesh = tmm
	trim.material_override = brass_mat
	trim.position = Vector3(0, 0.21, -0.55)
	pivot.add_child(trim)
	# Wall collision (single combined static body so player can't walk through)
	var sb: StaticBody3D = StaticBody3D.new()
	sb.position = Vector3(0, 0, 0)
	pivot.add_child(sb)
	var col: CollisionShape3D = CollisionShape3D.new()
	var cs: BoxShape3D = BoxShape3D.new()
	cs.size = Vector3(total_w + 0.6, 1.85, 0.55)
	col.shape = cs
	col.position = Vector3(0, 0.92, 0.1)
	sb.add_child(col)
	# ---- 9 niches (one per iteration) ----
	var iter_colors: Array[Color] = [
		Color(0.40, 0.85, 1.0),  # I1 - cyan (data)
		Color(0.95, 0.30, 0.30),  # I2 - red (decay)
		Color(0.65, 0.40, 0.95),  # I3 - violet (memory)
		Color(0.40, 0.85, 0.30),  # I4 - green (bloom)
		Color(0.55, 0.85, 1.0),  # I5 - ice blue (frost)
		Color(1.0, 0.30, 0.65),  # I6 - magenta (neon)
		Color(0.95, 0.75, 0.30),  # I7 - gold (ascension)
		Color(0.30, 0.55, 0.95),  # I8 - deep blue (tidal)
		Color(1.0, 0.45, 0.10),  # I9 - amber (forge)
	]
	for n in range(seg_count):
		var nx: float = start_x + float(n) * (seg_w + seg_gap)
		var seg_pivot: Node3D = Node3D.new()
		seg_pivot.position = Vector3(nx, 0, 0)
		pivot.add_child(seg_pivot)
		# Wall pillar segment
		var pil: MeshInstance3D = MeshInstance3D.new()
		var pmm: BoxMesh = BoxMesh.new()
		pmm.size = Vector3(seg_w, 1.85, 0.45)
		pil.mesh = pmm
		pil.material_override = basalt_mat
		pil.position = Vector3(0, 1.13, 0.20)
		seg_pivot.add_child(pil)
		# Cap stone
		var cap: MeshInstance3D = MeshInstance3D.new()
		var cmm: BoxMesh = BoxMesh.new()
		cmm.size = Vector3(seg_w + 0.10, 0.10, 0.55)
		cap.mesh = cmm
		cap.material_override = brass_mat
		cap.position = Vector3(0, 2.10, 0.15)
		seg_pivot.add_child(cap)
		# Inset niche (dark plate behind portrait)
		var nich: MeshInstance3D = MeshInstance3D.new()
		var nmm: BoxMesh = BoxMesh.new()
		nmm.size = Vector3(seg_w - 0.18, 0.85, 0.04)
		nich.mesh = nmm
		nich.material_override = niche_mat
		nich.position = Vector3(0, 1.40, -0.025)
		seg_pivot.add_child(nich)
		# Portrait disc (per-iteration colored)
		var pmat: StandardMaterial3D = portrait_mat.duplicate()
		pmat.albedo_color = iter_colors[n]
		pmat.emission = iter_colors[n] * 1.15
		var port: MeshInstance3D = MeshInstance3D.new()
		var pgm: SphereMesh = SphereMesh.new()
		pgm.radius = 0.18
		pgm.height = 0.36
		port.mesh = pgm
		port.material_override = pmat
		port.position = Vector3(0, 1.55, -0.10)
		seg_pivot.add_child(port)
		# Iteration numeral plate (small brass square)
		var num: MeshInstance3D = MeshInstance3D.new()
		var nbm: BoxMesh = BoxMesh.new()
		nbm.size = Vector3(0.18, 0.10, 0.03)
		num.mesh = nbm
		num.material_override = brass_mat
		num.position = Vector3(0, 1.05, -0.10)
		seg_pivot.add_child(num)
		# Brass candle holder + flame at base of niche
		var holder: MeshInstance3D = MeshInstance3D.new()
		var hmm: CylinderMesh = CylinderMesh.new()
		hmm.top_radius = 0.05
		hmm.bottom_radius = 0.07
		hmm.height = 0.12
		holder.mesh = hmm
		holder.material_override = brass_mat
		holder.position = Vector3(0, 0.30, -0.18)
		seg_pivot.add_child(holder)
		# Candle wax
		var wax: MeshInstance3D = MeshInstance3D.new()
		var wmm: CylinderMesh = CylinderMesh.new()
		wmm.top_radius = 0.035
		wmm.bottom_radius = 0.04
		wmm.height = 0.18
		wax.mesh = wmm
		wax.material_override = niche_mat
		wax.position = Vector3(0, 0.45, -0.18)
		seg_pivot.add_child(wax)
		# Flame (sphere)
		var flame: MeshInstance3D = MeshInstance3D.new()
		var flmm: SphereMesh = SphereMesh.new()
		flmm.radius = 0.05
		flmm.height = 0.10
		flame.mesh = flmm
		flame.material_override = flame_mat
		flame.position = Vector3(0, 0.60, -0.18)
		seg_pivot.add_child(flame)
		# Tiny warm flame light
		var fl: OmniLight3D = OmniLight3D.new()
		fl.position = Vector3(0, 0.65, -0.18)
		fl.light_color = Color(1.0, 0.55, 0.15)
		fl.light_energy = 0.85
		fl.omni_range = 1.8
		seg_pivot.add_child(fl)
		# Portrait pulse + flame flicker (slight phase offset per niche)
		var phase: float = float(n) * 0.18
		var ppulse: Tween = seg_pivot.create_tween().set_loops()
		ppulse.tween_interval(phase)
		ppulse.tween_property(pmat, "emission_energy_multiplier", 5.5, 1.6).set_ease(Tween.EASE_IN_OUT)
		ppulse.tween_property(pmat, "emission_energy_multiplier", 3.0, 1.6).set_ease(Tween.EASE_IN_OUT)
		var ff: Tween = seg_pivot.create_tween().set_loops()
		ff.tween_interval(phase * 0.5)
		ff.tween_property(flame, "scale", Vector3(1.2, 1.4, 1.2), 0.35).set_ease(Tween.EASE_IN_OUT)
		ff.tween_property(flame, "scale", Vector3(0.9, 1.1, 0.9), 0.45).set_ease(Tween.EASE_IN_OUT)
	# ---- Front offering bowl (brass dish on tripod) ----
	var bowl_pivot: Node3D = Node3D.new()
	bowl_pivot.position = Vector3(0, 0, -1.40)
	pivot.add_child(bowl_pivot)
	# Tripod legs
	for k in range(3):
		var leg: MeshInstance3D = MeshInstance3D.new()
		var lmm: CylinderMesh = CylinderMesh.new()
		lmm.top_radius = 0.04
		lmm.bottom_radius = 0.06
		lmm.height = 0.85
		leg.mesh = lmm
		leg.material_override = brass_mat
		var lang: float = float(k) * (TAU / 3.0)
		leg.position = Vector3(cos(lang) * 0.18, 0.45, sin(lang) * 0.18)
		leg.rotation.x = sin(lang) * 0.18
		leg.rotation.z = -cos(lang) * 0.18
		bowl_pivot.add_child(leg)
	# Bowl
	var bowl: MeshInstance3D = MeshInstance3D.new()
	var bmm: CylinderMesh = CylinderMesh.new()
	bmm.top_radius = 0.32
	bmm.bottom_radius = 0.18
	bmm.height = 0.18
	bowl.mesh = bmm
	bowl.material_override = brass_mat
	bowl.position = Vector3(0, 0.95, 0)
	bowl_pivot.add_child(bowl)
	# Eternal flame in the bowl
	var ef_mat: StandardMaterial3D = flame_mat.duplicate()
	ef_mat.emission_energy_multiplier = 11.0
	var ef: MeshInstance3D = MeshInstance3D.new()
	var efmm: SphereMesh = SphereMesh.new()
	efmm.radius = 0.18
	efmm.height = 0.36
	ef.mesh = efmm
	ef.material_override = ef_mat
	ef.position = Vector3(0, 1.16, 0)
	bowl_pivot.add_child(ef)
	# Strong warm light from offering bowl
	var blt: OmniLight3D = OmniLight3D.new()
	blt.position = Vector3(0, 1.20, 0)
	blt.light_color = Color(1.0, 0.55, 0.15)
	blt.light_energy = 2.4
	blt.omni_range = 6.0
	bowl_pivot.add_child(blt)
	# Eternal flame breathing
	var ebf: Tween = bowl_pivot.create_tween().set_loops()
	ebf.tween_property(ef, "scale", Vector3(1.15, 1.30, 1.15), 1.4).set_ease(Tween.EASE_IN_OUT)
	ebf.tween_property(ef, "scale", Vector3(0.92, 1.05, 0.92), 1.4).set_ease(Tween.EASE_IN_OUT)
	# Ember motes drifting up from the offering bowl
	var emb: GPUParticles3D = GPUParticles3D.new()
	var ep: ParticleProcessMaterial = ParticleProcessMaterial.new()
	ep.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	ep.emission_sphere_radius = 0.20
	ep.direction = Vector3(0, 1, 0)
	ep.spread = 18.0
	ep.gravity = Vector3(0, 0.4, 0)
	ep.initial_velocity_min = 0.6
	ep.initial_velocity_max = 1.2
	ep.scale_min = 0.04
	ep.scale_max = 0.10
	ep.color = Color(1.0, 0.6, 0.15, 0.9)
	emb.process_material = ep
	var emb_mesh: SphereMesh = SphereMesh.new()
	emb_mesh.radius = 0.04
	emb_mesh.height = 0.08
	emb.draw_pass_1 = emb_mesh
	emb.amount = 18
	emb.lifetime = 2.4
	emb.position = Vector3(0, 1.20, 0)
	bowl_pivot.add_child(emb)


func _build_th_memorial_mourner_npc(town: Node) -> void:
	## Epic-10 T63: Memorial Mourner Keeper Solem — hooded NPC standing
	## before the offering bowl of the Iterations Memorial Wall, head bowed
	## in mourning. Slow breathing sway. Anchors the memorial wall with
	## a quiet, contemplative narrative presence.
	var npc_scene: PackedScene = load("res://scenes/entities/npcs/VillagerR3.tscn") as PackedScene
	if npc_scene == null:
		return
	var npc: Node = npc_scene.instantiate()
	npc.name = "Mourner_Solem"
	# Position: just in front of the offering bowl (which sits 1.40 in front
	# of the wall pivot at SSE, ang -PI/3 r=12). Place at SSE, slightly
	# closer in toward the plaza so the player approaches from behind.
	var ang_pos: float = -PI / 3.0
	var rad_pos: float = 9.85
	var px: float = cos(ang_pos) * rad_pos
	var pz: float = sin(ang_pos) * rad_pos
	if npc is Node3D:
		(npc as Node3D).position = TOWN_CENTER + Vector3(px, 0, pz)
		# Face the wall (away from town center)
		(npc as Node3D).rotation.y = atan2(px, pz)
	# Set NPC name and ID via property if available
	if "npc_name" in npc:
		npc.set("npc_name", "Keeper Solem")
	if "npc_id" in npc:
		npc.set("npc_id", "th_memorial_mourner")
	town.add_child(npc)
	# ---- Add a hood + dark mourning robe overlay (cosmetic Node3D child) ----
	var ovl: Node3D = Node3D.new()
	ovl.name = "MournerOverlay"
	ovl.position = Vector3(0, 0, 0)
	if npc is Node3D:
		(npc as Node3D).add_child(ovl)
	# Materials
	var robe_mat: StandardMaterial3D = StandardMaterial3D.new()
	robe_mat.albedo_color = Color(0.10, 0.11, 0.16)
	robe_mat.metallic = 0.05
	robe_mat.roughness = 0.92
	robe_mat.emission_enabled = true
	robe_mat.emission = Color(0.20, 0.30, 0.55)
	robe_mat.emission_energy_multiplier = 0.10
	var hood_mat: StandardMaterial3D = StandardMaterial3D.new()
	hood_mat.albedo_color = Color(0.08, 0.09, 0.13)
	hood_mat.metallic = 0.05
	hood_mat.roughness = 0.95
	hood_mat.emission_enabled = true
	hood_mat.emission = Color(0.25, 0.35, 0.55)
	hood_mat.emission_energy_multiplier = 0.12
	var sash_mat: StandardMaterial3D = StandardMaterial3D.new()
	sash_mat.albedo_color = Color(0.85, 0.55, 0.18)
	sash_mat.metallic = 0.85
	sash_mat.roughness = 0.35
	sash_mat.emission_enabled = true
	sash_mat.emission = Color(1.0, 0.55, 0.12)
	sash_mat.emission_energy_multiplier = 0.55
	var glow_mat: StandardMaterial3D = StandardMaterial3D.new()
	glow_mat.albedo_color = Color(0.50, 0.85, 1.0)
	glow_mat.emission_enabled = true
	glow_mat.emission = Color(0.55, 0.90, 1.0)
	glow_mat.emission_energy_multiplier = 4.5
	glow_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	# Long mourning robe (covers body)
	var robe: MeshInstance3D = MeshInstance3D.new()
	var rmm: BoxMesh = BoxMesh.new()
	rmm.size = Vector3(0.95, 1.95, 0.55)
	robe.mesh = rmm
	robe.material_override = robe_mat
	robe.position = Vector3(0, 1.00, 0)
	ovl.add_child(robe)
	# Robe lower flare (wider hem)
	var hem: MeshInstance3D = MeshInstance3D.new()
	var hmm: CylinderMesh = CylinderMesh.new()
	hmm.top_radius = 0.45
	hmm.bottom_radius = 0.65
	hmm.height = 0.55
	hem.mesh = hmm
	hem.material_override = robe_mat
	hem.position = Vector3(0, 0.30, 0)
	ovl.add_child(hem)
	# Hood (dome over head, head bowed forward — tilt slightly)
	var hood: MeshInstance3D = MeshInstance3D.new()
	var hdmm: SphereMesh = SphereMesh.new()
	hdmm.radius = 0.32
	hdmm.height = 0.55
	hood.mesh = hdmm
	hood.material_override = hood_mat
	hood.position = Vector3(0, 1.92, 0.05)
	hood.rotation.x = 0.25  # bowed forward
	ovl.add_child(hood)
	# Hood inner shadow (dark disc inside hood opening)
	var shadow: MeshInstance3D = MeshInstance3D.new()
	var smm: SphereMesh = SphereMesh.new()
	smm.radius = 0.20
	smm.height = 0.40
	shadow.mesh = smm
	var shadow_mat: StandardMaterial3D = StandardMaterial3D.new()
	shadow_mat.albedo_color = Color(0.02, 0.02, 0.04)
	shadow_mat.metallic = 0.0
	shadow_mat.roughness = 1.0
	shadow.material_override = shadow_mat
	shadow.position = Vector3(0, 1.85, 0.18)
	ovl.add_child(shadow)
	# Dim cyan ember "eye" inside the shadow
	var eye: MeshInstance3D = MeshInstance3D.new()
	var emm: SphereMesh = SphereMesh.new()
	emm.radius = 0.04
	emm.height = 0.08
	eye.mesh = emm
	eye.material_override = glow_mat
	eye.position = Vector3(0, 1.82, 0.30)
	ovl.add_child(eye)
	# Brass mourning sash across chest
	var sash: MeshInstance3D = MeshInstance3D.new()
	var ssm: BoxMesh = BoxMesh.new()
	ssm.size = Vector3(1.05, 0.10, 0.06)
	sash.mesh = ssm
	sash.material_override = sash_mat
	sash.position = Vector3(0, 1.30, -0.30)
	sash.rotation.z = -0.12
	ovl.add_child(sash)
	# Hands clasped at the front (two small spheres at waist height)
	for s in [-1.0, 1.0]:
		var hand: MeshInstance3D = MeshInstance3D.new()
		var hndmm: SphereMesh = SphereMesh.new()
		hndmm.radius = 0.08
		hndmm.height = 0.16
		hand.mesh = hndmm
		hand.material_override = hood_mat
		hand.position = Vector3(0.06 * s, 0.95, -0.30)
		ovl.add_child(hand)
	# Brass memorial pendant hanging from neck
	var chain: MeshInstance3D = MeshInstance3D.new()
	var chmm: CylinderMesh = CylinderMesh.new()
	chmm.top_radius = 0.01
	chmm.bottom_radius = 0.01
	chmm.height = 0.30
	chain.mesh = chmm
	chain.material_override = sash_mat
	chain.position = Vector3(0, 1.50, -0.32)
	ovl.add_child(chain)
	var pendant: MeshInstance3D = MeshInstance3D.new()
	var pmm: TorusMesh = TorusMesh.new()
	pmm.inner_radius = 0.05
	pmm.outer_radius = 0.08
	pendant.mesh = pmm
	pendant.material_override = sash_mat
	pendant.position = Vector3(0, 1.34, -0.34)
	pendant.rotation.x = PI / 2.0
	ovl.add_child(pendant)
	# Subtle warm aura light
	var lt: OmniLight3D = OmniLight3D.new()
	lt.position = Vector3(0, 1.45, -0.20)
	lt.light_color = Color(1.0, 0.65, 0.30)
	lt.light_energy = 0.95
	lt.omni_range = 3.5
	ovl.add_child(lt)
	# ---- Slow mourning breath sway (gentle 4s cycle) ----
	var sway: Tween = ovl.create_tween().set_loops()
	sway.tween_property(ovl, "scale:y", 1.018, 2.0).set_ease(Tween.EASE_IN_OUT)
	sway.tween_property(ovl, "scale:y", 0.992, 2.0).set_ease(Tween.EASE_IN_OUT)
	# Eye ember slow pulse
	var epulse: Tween = ovl.create_tween().set_loops()
	epulse.tween_property(glow_mat, "emission_energy_multiplier", 6.5, 2.2).set_ease(Tween.EASE_IN_OUT)
	epulse.tween_property(glow_mat, "emission_energy_multiplier", 3.0, 2.2).set_ease(Tween.EASE_IN_OUT)


func _build_th_wishing_pond(geom: Node) -> void:
	## Epic-10 T64: Wishing Pond — small reflective square pool in the NNW
	## mid-plaza area, balancing the SSE memorial wall. Brass-rimmed shallow
	## basin with a glowing cyan water surface, 4 floating data lily pads,
	## a scattering of glowing wishing coins on the bottom, and gentle
	## upward ripple particles. Peaceful counterpoint to the memorial.
	var pivot: Node3D = Node3D.new()
	pivot.name = "TH_WishingPond"
	# NNW position at radius 11.5, angle ~PI*0.62 (between N and NW)
	var ang_pos: float = PI * 0.62
	var rad_pos: float = 11.5
	var px_p: float = cos(ang_pos) * rad_pos
	var pz_p: float = sin(ang_pos) * rad_pos
	pivot.position = TOWN_CENTER + Vector3(px_p, 0, pz_p)
	pivot.rotation.y = atan2(-px_p, -pz_p)
	geom.add_child(pivot)
	# ---- Materials ----
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.42, 0.46, 0.55)
	stone_mat.metallic = 0.20
	stone_mat.roughness = 0.85
	stone_mat.emission_enabled = true
	stone_mat.emission = Color(0.30, 0.45, 0.65)
	stone_mat.emission_energy_multiplier = 0.18
	var brass_mat: StandardMaterial3D = StandardMaterial3D.new()
	brass_mat.albedo_color = Color(0.85, 0.55, 0.18)
	brass_mat.metallic = 0.95
	brass_mat.roughness = 0.30
	brass_mat.emission_enabled = true
	brass_mat.emission = Color(1.0, 0.55, 0.12)
	brass_mat.emission_energy_multiplier = 0.55
	var water_mat: StandardMaterial3D = StandardMaterial3D.new()
	water_mat.albedo_color = Color(0.18, 0.55, 0.85, 0.85)
	water_mat.metallic = 0.85
	water_mat.roughness = 0.05
	water_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	water_mat.emission_enabled = true
	water_mat.emission = Color(0.30, 0.75, 1.0)
	water_mat.emission_energy_multiplier = 1.5
	var lily_mat: StandardMaterial3D = StandardMaterial3D.new()
	lily_mat.albedo_color = Color(0.30, 0.85, 0.45)
	lily_mat.metallic = 0.10
	lily_mat.roughness = 0.65
	lily_mat.emission_enabled = true
	lily_mat.emission = Color(0.40, 0.95, 0.50)
	lily_mat.emission_energy_multiplier = 1.20
	var coin_mat: StandardMaterial3D = StandardMaterial3D.new()
	coin_mat.albedo_color = Color(1.0, 0.78, 0.20)
	coin_mat.metallic = 0.95
	coin_mat.roughness = 0.20
	coin_mat.emission_enabled = true
	coin_mat.emission = Color(1.0, 0.80, 0.20)
	coin_mat.emission_energy_multiplier = 2.5
	# ---- Pond basin (square) ----
	var pond_w: float = 3.20
	# Stone footing under the pond
	var foot: MeshInstance3D = MeshInstance3D.new()
	var fmm: BoxMesh = BoxMesh.new()
	fmm.size = Vector3(pond_w + 0.50, 0.18, pond_w + 0.50)
	foot.mesh = fmm
	foot.material_override = stone_mat
	foot.position = Vector3(0, 0.09, 0)
	pivot.add_child(foot)
	# Brass rim (4 boxes around perimeter)
	var rim_h: float = 0.18
	var rim_t: float = 0.10
	var sides: Array = [
		Vector3(0, 0.27, (pond_w * 0.5) + (rim_t * 0.5)),
		Vector3(0, 0.27, -(pond_w * 0.5) - (rim_t * 0.5)),
		Vector3((pond_w * 0.5) + (rim_t * 0.5), 0.27, 0),
		Vector3(-(pond_w * 0.5) - (rim_t * 0.5), 0.27, 0),
	]
	for i in range(4):
		var rim: MeshInstance3D = MeshInstance3D.new()
		var rmm: BoxMesh = BoxMesh.new()
		if i < 2:
			rmm.size = Vector3(pond_w + (rim_t * 2.0), rim_h, rim_t)
		else:
			rmm.size = Vector3(rim_t, rim_h, pond_w + (rim_t * 2.0))
		rim.mesh = rmm
		rim.material_override = brass_mat
		rim.position = sides[i]
		pivot.add_child(rim)
	# Pond bottom (dark stone slab)
	var bottom_mat: StandardMaterial3D = StandardMaterial3D.new()
	bottom_mat.albedo_color = Color(0.10, 0.18, 0.28)
	bottom_mat.metallic = 0.20
	bottom_mat.roughness = 0.90
	bottom_mat.emission_enabled = true
	bottom_mat.emission = Color(0.15, 0.40, 0.65)
	bottom_mat.emission_energy_multiplier = 0.25
	var bot: MeshInstance3D = MeshInstance3D.new()
	var bmm: BoxMesh = BoxMesh.new()
	bmm.size = Vector3(pond_w, 0.04, pond_w)
	bot.mesh = bmm
	bot.material_override = bottom_mat
	bot.position = Vector3(0, 0.20, 0)
	pivot.add_child(bot)
	# Water surface (slightly below rim top)
	var water: MeshInstance3D = MeshInstance3D.new()
	var wmm: BoxMesh = BoxMesh.new()
	wmm.size = Vector3(pond_w - 0.04, 0.05, pond_w - 0.04)
	water.mesh = wmm
	water.material_override = water_mat
	water.position = Vector3(0, 0.32, 0)
	pivot.add_child(water)
	# Collision (player can't walk in)
	var sb: StaticBody3D = StaticBody3D.new()
	pivot.add_child(sb)
	var col: CollisionShape3D = CollisionShape3D.new()
	var cs: BoxShape3D = BoxShape3D.new()
	cs.size = Vector3(pond_w + 0.30, 0.50, pond_w + 0.30)
	col.shape = cs
	col.position = Vector3(0, 0.25, 0)
	sb.add_child(col)
	# ---- 4 lily pads (data lilies) ----
	var lily_positions: Array = [
		Vector3(-0.85, 0.355, -0.85),
		Vector3(0.85, 0.355, 0.85),
		Vector3(0.85, 0.355, -0.85),
		Vector3(-0.85, 0.355, 0.85),
	]
	for i2 in range(4):
		var lp: Node3D = Node3D.new()
		lp.position = lily_positions[i2]
		pivot.add_child(lp)
		# Pad disc
		var pad: MeshInstance3D = MeshInstance3D.new()
		var pmm: CylinderMesh = CylinderMesh.new()
		pmm.top_radius = 0.32
		pmm.bottom_radius = 0.32
		pmm.height = 0.04
		pad.mesh = pmm
		pad.material_override = lily_mat
		pad.position = Vector3(0, 0, 0)
		lp.add_child(pad)
		# Tiny flower bud (sphere)
		var bud_mat: StandardMaterial3D = StandardMaterial3D.new()
		bud_mat.albedo_color = Color(1.0, 0.65, 0.85)
		bud_mat.emission_enabled = true
		bud_mat.emission = Color(1.0, 0.70, 0.90)
		bud_mat.emission_energy_multiplier = 4.0
		bud_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		var bud: MeshInstance3D = MeshInstance3D.new()
		var bdm: SphereMesh = SphereMesh.new()
		bdm.radius = 0.10
		bdm.height = 0.20
		bud.mesh = bdm
		bud.material_override = bud_mat
		bud.position = Vector3(0, 0.10, 0)
		lp.add_child(bud)
		# Tiny rim brass particles (4 dots around the pad)
		for k in range(4):
			var dot: MeshInstance3D = MeshInstance3D.new()
			var ddm: SphereMesh = SphereMesh.new()
			ddm.radius = 0.025
			ddm.height = 0.05
			dot.mesh = ddm
			dot.material_override = brass_mat
			var ka: float = float(k) * (PI / 2.0)
			dot.position = Vector3(cos(ka) * 0.27, 0.04, sin(ka) * 0.27)
			lp.add_child(dot)
		# Bud pulse
		var pulse: Tween = lp.create_tween().set_loops()
		pulse.tween_interval(float(i2) * 0.30)
		pulse.tween_property(bud_mat, "emission_energy_multiplier", 6.5, 1.2).set_ease(Tween.EASE_IN_OUT)
		pulse.tween_property(bud_mat, "emission_energy_multiplier", 2.5, 1.2).set_ease(Tween.EASE_IN_OUT)
		# Pad slight horizontal drift (subtle X+Z sway)
		var drift: Tween = lp.create_tween().set_loops()
		drift.tween_property(lp, "position:y", lily_positions[i2].y + 0.018, 1.6).set_ease(Tween.EASE_IN_OUT)
		drift.tween_property(lp, "position:y", lily_positions[i2].y - 0.018, 1.6).set_ease(Tween.EASE_IN_OUT)
	# ---- Wishing coins on the pond bottom (8 scattered coins) ----
	var coin_positions: Array = [
		Vector3(-0.35, 0.235, 0.30),
		Vector3(0.55, 0.235, -0.20),
		Vector3(0.10, 0.235, 0.65),
		Vector3(-0.55, 0.235, -0.40),
		Vector3(0.40, 0.235, 0.45),
		Vector3(-0.20, 0.235, -0.55),
		Vector3(0.75, 0.235, 0.10),
		Vector3(-0.65, 0.235, 0.05),
	]
	for i3 in range(8):
		var coin: MeshInstance3D = MeshInstance3D.new()
		var cmm: CylinderMesh = CylinderMesh.new()
		cmm.top_radius = 0.045
		cmm.bottom_radius = 0.045
		cmm.height = 0.02
		coin.mesh = cmm
		coin.material_override = coin_mat
		coin.position = coin_positions[i3]
		coin.rotation.y = float(i3) * 0.35
		pivot.add_child(coin)
	# ---- Central inscription stone (small) ----
	var stone: MeshInstance3D = MeshInstance3D.new()
	var stmm: BoxMesh = BoxMesh.new()
	stmm.size = Vector3(0.45, 0.08, 0.30)
	stone.mesh = stmm
	stone.material_override = stone_mat
	stone.position = Vector3(0, 0.40, -1.20)
	pivot.add_child(stone)
	# Brass plate inset on stone
	var plate: MeshInstance3D = MeshInstance3D.new()
	var pltm: BoxMesh = BoxMesh.new()
	pltm.size = Vector3(0.36, 0.02, 0.22)
	plate.mesh = pltm
	plate.material_override = brass_mat
	plate.position = Vector3(0, 0.46, -1.20)
	pivot.add_child(plate)
	# ---- Ripple particles (gentle upward shimmer) ----
	var rip: GPUParticles3D = GPUParticles3D.new()
	var rp: ParticleProcessMaterial = ParticleProcessMaterial.new()
	rp.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	rp.emission_box_extents = Vector3(pond_w * 0.45, 0.02, pond_w * 0.45)
	rp.direction = Vector3(0, 1, 0)
	rp.spread = 8.0
	rp.gravity = Vector3(0, 0.10, 0)
	rp.initial_velocity_min = 0.20
	rp.initial_velocity_max = 0.45
	rp.scale_min = 0.03
	rp.scale_max = 0.07
	rp.color = Color(0.55, 0.95, 1.0, 0.85)
	rip.process_material = rp
	var rip_mesh: SphereMesh = SphereMesh.new()
	rip_mesh.radius = 0.03
	rip_mesh.height = 0.06
	rip.draw_pass_1 = rip_mesh
	rip.amount = 22
	rip.lifetime = 2.6
	rip.position = Vector3(0, 0.34, 0)
	pivot.add_child(rip)
	# ---- Cool aura light over the pond ----
	var lt2: OmniLight3D = OmniLight3D.new()
	lt2.position = Vector3(0, 1.0, 0)
	lt2.light_color = Color(0.40, 0.85, 1.0)
	lt2.light_energy = 1.4
	lt2.omni_range = 5.0
	pivot.add_child(lt2)
	# Subtle water surface emission breathing
	var wpulse: Tween = pivot.create_tween().set_loops()
	wpulse.tween_property(water_mat, "emission_energy_multiplier", 2.2, 2.4).set_ease(Tween.EASE_IN_OUT)
	wpulse.tween_property(water_mat, "emission_energy_multiplier", 1.0, 2.4).set_ease(Tween.EASE_IN_OUT)


func _build_th_pond_caretaker_npc(town: Node) -> void:
	## Epic-10 T65: Pond Caretaker Sage Mira NPC — elder NPC tending the
	## wishing pond. Stands beside it holding a brass long-handled scoop,
	## with cyan-trimmed teal robe matching the pond theme. Slow tending sway,
	## scoop gently rises and falls as if scooping ripples.
	var npc_scene: PackedScene = load("res://scenes/entities/npcs/VillagerR3.tscn") as PackedScene
	if npc_scene == null:
		return
	var npc: Node = npc_scene.instantiate()
	npc.name = "Sage_Mira_PondCaretaker"
	# Position: just beside the wishing pond (NNW radius 11.5, ang ~PI*0.62)
	# Place at the same angle but pulled slightly inward + offset to one side
	var ang_pos: float = PI * 0.62
	var rad_pos: float = 9.40
	var px: float = cos(ang_pos) * rad_pos + 0.85
	var pz: float = sin(ang_pos) * rad_pos - 0.45
	if npc is Node3D:
		(npc as Node3D).position = TOWN_CENTER + Vector3(px, 0, pz)
		# Face the pond
		var pond_x: float = cos(ang_pos) * 11.5
		var pond_z: float = sin(ang_pos) * 11.5
		(npc as Node3D).rotation.y = atan2(pond_x - px, pond_z - pz)
	if "npc_name" in npc:
		npc.set("npc_name", "Sage Mira")
	if "npc_id" in npc:
		npc.set("npc_id", "th_pond_caretaker")
	town.add_child(npc)
	# ---- Cosmetic overlay (teal-and-brass robe) ----
	var ovl: Node3D = Node3D.new()
	ovl.name = "PondCaretakerOverlay"
	if npc is Node3D:
		(npc as Node3D).add_child(ovl)
	# Materials
	var robe_mat: StandardMaterial3D = StandardMaterial3D.new()
	robe_mat.albedo_color = Color(0.18, 0.45, 0.55)
	robe_mat.metallic = 0.10
	robe_mat.roughness = 0.85
	robe_mat.emission_enabled = true
	robe_mat.emission = Color(0.30, 0.75, 0.95)
	robe_mat.emission_energy_multiplier = 0.30
	var trim_mat: StandardMaterial3D = StandardMaterial3D.new()
	trim_mat.albedo_color = Color(0.40, 0.95, 1.0)
	trim_mat.metallic = 0.30
	trim_mat.roughness = 0.55
	trim_mat.emission_enabled = true
	trim_mat.emission = Color(0.50, 0.95, 1.0)
	trim_mat.emission_energy_multiplier = 1.40
	var brass_mat: StandardMaterial3D = StandardMaterial3D.new()
	brass_mat.albedo_color = Color(0.85, 0.55, 0.18)
	brass_mat.metallic = 0.95
	brass_mat.roughness = 0.30
	brass_mat.emission_enabled = true
	brass_mat.emission = Color(1.0, 0.55, 0.12)
	brass_mat.emission_energy_multiplier = 0.55
	var skin_mat: StandardMaterial3D = StandardMaterial3D.new()
	skin_mat.albedo_color = Color(0.85, 0.78, 0.65)
	skin_mat.roughness = 0.85
	# Long teal robe (covers torso + legs)
	var robe: MeshInstance3D = MeshInstance3D.new()
	var rmm: BoxMesh = BoxMesh.new()
	rmm.size = Vector3(0.92, 1.85, 0.55)
	robe.mesh = rmm
	robe.material_override = robe_mat
	robe.position = Vector3(0, 1.00, 0)
	ovl.add_child(robe)
	# Robe hem flare
	var hem: MeshInstance3D = MeshInstance3D.new()
	var hmm: CylinderMesh = CylinderMesh.new()
	hmm.top_radius = 0.45
	hmm.bottom_radius = 0.62
	hmm.height = 0.55
	hem.mesh = hmm
	hem.material_override = robe_mat
	hem.position = Vector3(0, 0.30, 0)
	ovl.add_child(hem)
	# Cyan trim band at the chest
	var trim: MeshInstance3D = MeshInstance3D.new()
	var tmm: BoxMesh = BoxMesh.new()
	tmm.size = Vector3(0.95, 0.08, 0.58)
	trim.mesh = tmm
	trim.material_override = trim_mat
	trim.position = Vector3(0, 1.40, 0)
	ovl.add_child(trim)
	# Head (silver-haired elder)
	var head: MeshInstance3D = MeshInstance3D.new()
	var hdm: SphereMesh = SphereMesh.new()
	hdm.radius = 0.20
	hdm.height = 0.42
	head.mesh = hdm
	head.material_override = skin_mat
	head.position = Vector3(0, 1.95, 0)
	ovl.add_child(head)
	# Silver hair cap
	var hair: MeshInstance3D = MeshInstance3D.new()
	var hrm: SphereMesh = SphereMesh.new()
	hrm.radius = 0.21
	hrm.height = 0.30
	hair.mesh = hrm
	var hair_mat: StandardMaterial3D = StandardMaterial3D.new()
	hair_mat.albedo_color = Color(0.82, 0.85, 0.90)
	hair_mat.roughness = 0.78
	hair_mat.emission_enabled = true
	hair_mat.emission = Color(0.85, 0.90, 1.0)
	hair_mat.emission_energy_multiplier = 0.20
	hair.material_override = hair_mat
	hair.position = Vector3(0, 2.10, -0.02)
	ovl.add_child(hair)
	# Two small cyan eye dots
	for s in [-1.0, 1.0]:
		var eye: MeshInstance3D = MeshInstance3D.new()
		var emm: SphereMesh = SphereMesh.new()
		emm.radius = 0.025
		emm.height = 0.05
		eye.mesh = emm
		var eye_mat: StandardMaterial3D = StandardMaterial3D.new()
		eye_mat.albedo_color = Color(0.55, 0.95, 1.0)
		eye_mat.emission_enabled = true
		eye_mat.emission = Color(0.55, 0.95, 1.0)
		eye_mat.emission_energy_multiplier = 5.0
		eye_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		eye.material_override = eye_mat
		eye.position = Vector3(0.07 * s, 1.97, 0.18)
		ovl.add_child(eye)
	# Brass shoulder clasp
	var clasp: MeshInstance3D = MeshInstance3D.new()
	var clm: SphereMesh = SphereMesh.new()
	clm.radius = 0.07
	clm.height = 0.14
	clasp.mesh = clm
	clasp.material_override = brass_mat
	clasp.position = Vector3(0.30, 1.65, 0)
	ovl.add_child(clasp)
	# ---- Long brass scoop staff (held in front) ----
	var scoop_pivot: Node3D = Node3D.new()
	scoop_pivot.position = Vector3(0.20, 1.20, -0.20)
	scoop_pivot.rotation.x = -0.35  # angled forward+down toward pond
	ovl.add_child(scoop_pivot)
	# Staff shaft
	var shaft: MeshInstance3D = MeshInstance3D.new()
	var shm: CylinderMesh = CylinderMesh.new()
	shm.top_radius = 0.025
	shm.bottom_radius = 0.030
	shm.height = 1.40
	shaft.mesh = shm
	shaft.material_override = brass_mat
	shaft.position = Vector3(0, 0, -0.70)
	shaft.rotation.x = PI / 2.0
	scoop_pivot.add_child(shaft)
	# Scoop bowl at the end
	var scoop: MeshInstance3D = MeshInstance3D.new()
	var sbm: SphereMesh = SphereMesh.new()
	sbm.radius = 0.10
	sbm.height = 0.18
	scoop.mesh = sbm
	scoop.material_override = brass_mat
	scoop.position = Vector3(0, -0.04, -1.45)
	scoop_pivot.add_child(scoop)
	# Tiny shimmer drop hovering near scoop tip
	var drop_mat: StandardMaterial3D = StandardMaterial3D.new()
	drop_mat.albedo_color = Color(0.40, 0.85, 1.0)
	drop_mat.emission_enabled = true
	drop_mat.emission = Color(0.55, 0.95, 1.0)
	drop_mat.emission_energy_multiplier = 5.5
	drop_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var drop: MeshInstance3D = MeshInstance3D.new()
	var dpm: SphereMesh = SphereMesh.new()
	dpm.radius = 0.04
	dpm.height = 0.08
	drop.mesh = dpm
	drop.material_override = drop_mat
	drop.position = Vector3(0, 0.04, -1.45)
	scoop_pivot.add_child(drop)
	# Subtle warm light from the caretaker
	var lt: OmniLight3D = OmniLight3D.new()
	lt.position = Vector3(0, 1.55, -0.20)
	lt.light_color = Color(0.55, 0.95, 1.0)
	lt.light_energy = 1.10
	lt.omni_range = 3.0
	ovl.add_child(lt)
	# ---- Tending sway: scoop arm rises and falls ----
	var stir: Tween = scoop_pivot.create_tween().set_loops()
	stir.tween_property(scoop_pivot, "rotation:x", -0.18, 1.8).set_ease(Tween.EASE_IN_OUT)
	stir.tween_property(scoop_pivot, "rotation:x", -0.45, 1.8).set_ease(Tween.EASE_IN_OUT)
	# Drop pulse + gentle bob
	var dpulse: Tween = scoop_pivot.create_tween().set_loops()
	dpulse.tween_property(drop_mat, "emission_energy_multiplier", 8.0, 1.4).set_ease(Tween.EASE_IN_OUT)
	dpulse.tween_property(drop_mat, "emission_energy_multiplier", 4.0, 1.4).set_ease(Tween.EASE_IN_OUT)
	# Slow body breathing
	var breath: Tween = ovl.create_tween().set_loops()
	breath.tween_property(ovl, "scale:y", 1.012, 2.2).set_ease(Tween.EASE_IN_OUT)
	breath.tween_property(ovl, "scale:y", 0.992, 2.2).set_ease(Tween.EASE_IN_OUT)


func _build_th_botanical_conservatory(geom: Node) -> void:
	## Epic-10 T66: Botanical Conservatory Dome — small glass-dome structure
	## in the NNE mid-plaza. A circular brass-rimmed planter holds 4 exotic
	## data plants with crystalline leaves, enclosed by a translucent
	## hemispherical glass dome. Pulsing aura inside, sparkle particles drift
	## upward. Balances the NNW wishing pond on the opposite side.
	var pivot: Node3D = Node3D.new()
	pivot.name = "TH_BotanicalConservatory"
	# NNE position at radius 11.5, angle ~PI*0.38 (between N and NE)
	var ang_pos: float = PI * 0.38
	var rad_pos: float = 11.5
	var px_p: float = cos(ang_pos) * rad_pos
	var pz_p: float = sin(ang_pos) * rad_pos
	pivot.position = TOWN_CENTER + Vector3(px_p, 0, pz_p)
	pivot.rotation.y = atan2(-px_p, -pz_p)
	geom.add_child(pivot)
	# ---- Materials ----
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.42, 0.46, 0.55)
	stone_mat.metallic = 0.20
	stone_mat.roughness = 0.85
	stone_mat.emission_enabled = true
	stone_mat.emission = Color(0.30, 0.45, 0.65)
	stone_mat.emission_energy_multiplier = 0.18
	var brass_mat: StandardMaterial3D = StandardMaterial3D.new()
	brass_mat.albedo_color = Color(0.85, 0.55, 0.18)
	brass_mat.metallic = 0.95
	brass_mat.roughness = 0.30
	brass_mat.emission_enabled = true
	brass_mat.emission = Color(1.0, 0.55, 0.12)
	brass_mat.emission_energy_multiplier = 0.55
	var glass_mat: StandardMaterial3D = StandardMaterial3D.new()
	glass_mat.albedo_color = Color(0.55, 0.85, 1.0, 0.22)
	glass_mat.metallic = 0.10
	glass_mat.roughness = 0.05
	glass_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	glass_mat.emission_enabled = true
	glass_mat.emission = Color(0.55, 0.95, 1.0)
	glass_mat.emission_energy_multiplier = 0.40
	glass_mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	var soil_mat: StandardMaterial3D = StandardMaterial3D.new()
	soil_mat.albedo_color = Color(0.25, 0.18, 0.12)
	soil_mat.roughness = 0.95
	# ---- Stone footing pad ----
	var pad: MeshInstance3D = MeshInstance3D.new()
	var pmm: CylinderMesh = CylinderMesh.new()
	pmm.top_radius = 1.85
	pmm.bottom_radius = 2.05
	pmm.height = 0.20
	pad.mesh = pmm
	pad.material_override = stone_mat
	pad.position = Vector3(0, 0.10, 0)
	pivot.add_child(pad)
	# Brass rim
	var rim: MeshInstance3D = MeshInstance3D.new()
	var rtm: TorusMesh = TorusMesh.new()
	rtm.inner_radius = 1.78
	rtm.outer_radius = 1.92
	rim.mesh = rtm
	rim.material_override = brass_mat
	rim.position = Vector3(0, 0.22, 0)
	rim.rotation.x = PI / 2.0
	pivot.add_child(rim)
	# Inner planter (lower disc with soil)
	var planter: MeshInstance3D = MeshInstance3D.new()
	var pltm: CylinderMesh = CylinderMesh.new()
	pltm.top_radius = 1.55
	pltm.bottom_radius = 1.55
	pltm.height = 0.08
	planter.mesh = pltm
	planter.material_override = soil_mat
	planter.position = Vector3(0, 0.24, 0)
	pivot.add_child(planter)
	# Collision (player can't walk through)
	var sb: StaticBody3D = StaticBody3D.new()
	pivot.add_child(sb)
	var col: CollisionShape3D = CollisionShape3D.new()
	var cs: CylinderShape3D = CylinderShape3D.new()
	cs.radius = 1.95
	cs.height = 2.40
	col.shape = cs
	col.position = Vector3(0, 1.20, 0)
	sb.add_child(col)
	# ---- 4 brass support columns (vertical glass dome ribs) ----
	for i in range(4):
		var ang: float = float(i) * (PI / 2.0) + PI / 4.0
		var col_m: MeshInstance3D = MeshInstance3D.new()
		var cmm: CylinderMesh = CylinderMesh.new()
		cmm.top_radius = 0.05
		cmm.bottom_radius = 0.06
		cmm.height = 1.80
		col_m.mesh = cmm
		col_m.material_override = brass_mat
		col_m.position = Vector3(cos(ang) * 1.78, 1.20, sin(ang) * 1.78)
		pivot.add_child(col_m)
	# ---- Glass dome (hemisphere via SphereMesh, top half only) ----
	var dome: MeshInstance3D = MeshInstance3D.new()
	var dmm: SphereMesh = SphereMesh.new()
	dmm.radius = 1.80
	dmm.height = 3.60
	dmm.is_hemisphere = true
	dome.mesh = dmm
	dome.material_override = glass_mat
	dome.position = Vector3(0, 0.30, 0)
	pivot.add_child(dome)
	# Brass ring at the top of the dome
	var top_ring: MeshInstance3D = MeshInstance3D.new()
	var trtm: TorusMesh = TorusMesh.new()
	trtm.inner_radius = 0.18
	trtm.outer_radius = 0.26
	top_ring.mesh = trtm
	top_ring.material_override = brass_mat
	top_ring.position = Vector3(0, 2.10, 0)
	top_ring.rotation.x = PI / 2.0
	pivot.add_child(top_ring)
	# Brass finial spike on top
	var finial: MeshInstance3D = MeshInstance3D.new()
	var fmm: PrismMesh = PrismMesh.new()
	fmm.size = Vector3(0.12, 0.45, 0.12)
	finial.mesh = fmm
	finial.material_override = brass_mat
	finial.position = Vector3(0, 2.36, 0)
	pivot.add_child(finial)
	# ---- 4 exotic data plants inside ----
	var plant_palette: Array[Color] = [
		Color(0.45, 0.95, 0.50),  # cyan-green
		Color(1.0, 0.55, 0.85),   # pink
		Color(0.55, 0.85, 1.0),   # cyan
		Color(0.95, 0.85, 0.30),  # gold
	]
	for j in range(4):
		var ang2: float = float(j) * (PI / 2.0) + PI / 4.0
		var plant_pivot: Node3D = Node3D.new()
		plant_pivot.position = Vector3(cos(ang2) * 0.85, 0.30, sin(ang2) * 0.85)
		pivot.add_child(plant_pivot)
		# Plant pot
		var pot: MeshInstance3D = MeshInstance3D.new()
		var potm: CylinderMesh = CylinderMesh.new()
		potm.top_radius = 0.18
		potm.bottom_radius = 0.14
		potm.height = 0.18
		pot.mesh = potm
		pot.material_override = brass_mat
		pot.position = Vector3(0, 0.09, 0)
		plant_pivot.add_child(pot)
		# Plant stem
		var stem_mat: StandardMaterial3D = StandardMaterial3D.new()
		stem_mat.albedo_color = Color(0.25, 0.55, 0.30)
		stem_mat.roughness = 0.75
		stem_mat.emission_enabled = true
		stem_mat.emission = Color(0.30, 0.85, 0.40)
		stem_mat.emission_energy_multiplier = 0.40
		var stem: MeshInstance3D = MeshInstance3D.new()
		var stmm: CylinderMesh = CylinderMesh.new()
		stmm.top_radius = 0.025
		stmm.bottom_radius = 0.035
		stmm.height = 0.85
		stem.mesh = stmm
		stem.material_override = stem_mat
		stem.position = Vector3(0, 0.60, 0)
		plant_pivot.add_child(stem)
		# Crystalline leaves (3 prisms angled outward)
		var leaf_mat: StandardMaterial3D = StandardMaterial3D.new()
		leaf_mat.albedo_color = plant_palette[j]
		leaf_mat.metallic = 0.40
		leaf_mat.roughness = 0.25
		leaf_mat.emission_enabled = true
		leaf_mat.emission = plant_palette[j]
		leaf_mat.emission_energy_multiplier = 2.5
		for k in range(3):
			var lang: float = float(k) * (TAU / 3.0) + float(j) * 0.4
			var leaf: MeshInstance3D = MeshInstance3D.new()
			var lmm: PrismMesh = PrismMesh.new()
			lmm.size = Vector3(0.10, 0.32, 0.05)
			leaf.mesh = lmm
			leaf.material_override = leaf_mat
			leaf.position = Vector3(cos(lang) * 0.10, 1.00, sin(lang) * 0.10)
			leaf.rotation.z = sin(lang) * 0.55
			leaf.rotation.x = -cos(lang) * 0.55
			plant_pivot.add_child(leaf)
		# Crowning bloom (sphere)
		var bloom_mat: StandardMaterial3D = StandardMaterial3D.new()
		bloom_mat.albedo_color = plant_palette[j] * 1.2
		bloom_mat.emission_enabled = true
		bloom_mat.emission = plant_palette[j] * 1.3
		bloom_mat.emission_energy_multiplier = 5.5
		bloom_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		var bloom: MeshInstance3D = MeshInstance3D.new()
		var bmm: SphereMesh = SphereMesh.new()
		bmm.radius = 0.12
		bmm.height = 0.24
		bloom.mesh = bmm
		bloom.material_override = bloom_mat
		bloom.position = Vector3(0, 1.18, 0)
		plant_pivot.add_child(bloom)
		# Bloom pulse (phase offset)
		var phase: float = float(j) * 0.40
		var bp: Tween = plant_pivot.create_tween().set_loops()
		bp.tween_interval(phase)
		bp.tween_property(bloom_mat, "emission_energy_multiplier", 8.0, 1.6).set_ease(Tween.EASE_IN_OUT)
		bp.tween_property(bloom_mat, "emission_energy_multiplier", 3.5, 1.6).set_ease(Tween.EASE_IN_OUT)
		# Slight stem sway
		var sw: Tween = plant_pivot.create_tween().set_loops()
		sw.tween_interval(phase * 0.5)
		sw.tween_property(plant_pivot, "rotation:z", 0.04, 1.4).set_ease(Tween.EASE_IN_OUT)
		sw.tween_property(plant_pivot, "rotation:z", -0.04, 1.4).set_ease(Tween.EASE_IN_OUT)
	# ---- Sparkle particles drifting upward inside the dome ----
	var sparkle: GPUParticles3D = GPUParticles3D.new()
	var sp: ParticleProcessMaterial = ParticleProcessMaterial.new()
	sp.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	sp.emission_sphere_radius = 1.0
	sp.direction = Vector3(0, 1, 0)
	sp.spread = 25.0
	sp.gravity = Vector3(0, 0.15, 0)
	sp.initial_velocity_min = 0.15
	sp.initial_velocity_max = 0.40
	sp.scale_min = 0.025
	sp.scale_max = 0.055
	sp.color = Color(0.65, 0.95, 1.0, 0.85)
	sparkle.process_material = sp
	var spm: SphereMesh = SphereMesh.new()
	spm.radius = 0.025
	spm.height = 0.05
	sparkle.draw_pass_1 = spm
	sparkle.amount = 24
	sparkle.lifetime = 3.0
	sparkle.position = Vector3(0, 0.80, 0)
	pivot.add_child(sparkle)
	# ---- Inner aura light ----
	var lt: OmniLight3D = OmniLight3D.new()
	lt.position = Vector3(0, 1.30, 0)
	lt.light_color = Color(0.55, 0.95, 1.0)
	lt.light_energy = 1.85
	lt.omni_range = 5.5
	pivot.add_child(lt)
	# Subtle dome glass emission breathing
	var gp: Tween = pivot.create_tween().set_loops()
	gp.tween_property(glass_mat, "emission_energy_multiplier", 0.65, 2.4).set_ease(Tween.EASE_IN_OUT)
	gp.tween_property(glass_mat, "emission_energy_multiplier", 0.30, 2.4).set_ease(Tween.EASE_IN_OUT)


func _build_th_botanist_npc(town: Node) -> void:
	## Epic-10 T67: Botanist Verdant NPC — botanist NPC standing beside the
	## conservatory dome with a glowing magnifying lens, examining the data
	## plants. Brown gardening apron over a green robe, leather gloves,
	## small notebook tucked under one arm. Slow examining sway.
	var npc_scene: PackedScene = load("res://scenes/entities/npcs/VillagerR3.tscn") as PackedScene
	if npc_scene == null:
		return
	var npc: Node = npc_scene.instantiate()
	npc.name = "Botanist_Verdant"
	# Position: just outside the conservatory dome (NNE radius 11.5, ang ~PI*0.38)
	# Slightly inward toward plaza, offset to one side
	var ang_pos: float = PI * 0.38
	var rad_pos: float = 9.40
	var px: float = cos(ang_pos) * rad_pos - 0.85
	var pz: float = sin(ang_pos) * rad_pos - 0.45
	if npc is Node3D:
		(npc as Node3D).position = TOWN_CENTER + Vector3(px, 0, pz)
		# Face the conservatory dome
		var dome_x: float = cos(ang_pos) * 11.5
		var dome_z: float = sin(ang_pos) * 11.5
		(npc as Node3D).rotation.y = atan2(dome_x - px, dome_z - pz)
	if "npc_name" in npc:
		npc.set("npc_name", "Botanist Verdant")
	if "npc_id" in npc:
		npc.set("npc_id", "th_botanist")
	town.add_child(npc)
	# ---- Cosmetic overlay ----
	var ovl: Node3D = Node3D.new()
	ovl.name = "BotanistOverlay"
	if npc is Node3D:
		(npc as Node3D).add_child(ovl)
	# Materials
	var robe_mat: StandardMaterial3D = StandardMaterial3D.new()
	robe_mat.albedo_color = Color(0.20, 0.50, 0.30)
	robe_mat.metallic = 0.10
	robe_mat.roughness = 0.85
	robe_mat.emission_enabled = true
	robe_mat.emission = Color(0.30, 0.85, 0.40)
	robe_mat.emission_energy_multiplier = 0.25
	var apron_mat: StandardMaterial3D = StandardMaterial3D.new()
	apron_mat.albedo_color = Color(0.42, 0.28, 0.18)
	apron_mat.metallic = 0.05
	apron_mat.roughness = 0.92
	var brass_mat: StandardMaterial3D = StandardMaterial3D.new()
	brass_mat.albedo_color = Color(0.85, 0.55, 0.18)
	brass_mat.metallic = 0.95
	brass_mat.roughness = 0.30
	brass_mat.emission_enabled = true
	brass_mat.emission = Color(1.0, 0.55, 0.12)
	brass_mat.emission_energy_multiplier = 0.55
	var skin_mat: StandardMaterial3D = StandardMaterial3D.new()
	skin_mat.albedo_color = Color(0.85, 0.78, 0.65)
	skin_mat.roughness = 0.85
	var glow_mat: StandardMaterial3D = StandardMaterial3D.new()
	glow_mat.albedo_color = Color(0.45, 0.95, 0.55)
	glow_mat.emission_enabled = true
	glow_mat.emission = Color(0.50, 0.95, 0.55)
	glow_mat.emission_energy_multiplier = 5.5
	glow_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	# Green robe (torso + legs)
	var robe: MeshInstance3D = MeshInstance3D.new()
	var rmm: BoxMesh = BoxMesh.new()
	rmm.size = Vector3(0.92, 1.85, 0.55)
	robe.mesh = rmm
	robe.material_override = robe_mat
	robe.position = Vector3(0, 1.00, 0)
	ovl.add_child(robe)
	# Brown apron (front of robe)
	var apron: MeshInstance3D = MeshInstance3D.new()
	var apm: BoxMesh = BoxMesh.new()
	apm.size = Vector3(0.85, 1.20, 0.06)
	apron.mesh = apm
	apron.material_override = apron_mat
	apron.position = Vector3(0, 1.00, -0.32)
	ovl.add_child(apron)
	# Apron pocket (small front box)
	var pocket: MeshInstance3D = MeshInstance3D.new()
	var pkm: BoxMesh = BoxMesh.new()
	pkm.size = Vector3(0.40, 0.28, 0.08)
	pocket.mesh = pkm
	pocket.material_override = apron_mat
	pocket.position = Vector3(0, 0.80, -0.36)
	ovl.add_child(pocket)
	# Brass apron tie clasp
	var clasp: MeshInstance3D = MeshInstance3D.new()
	var clm: SphereMesh = SphereMesh.new()
	clm.radius = 0.07
	clm.height = 0.14
	clasp.mesh = clm
	clasp.material_override = brass_mat
	clasp.position = Vector3(0, 1.55, -0.34)
	ovl.add_child(clasp)
	# Head
	var head: MeshInstance3D = MeshInstance3D.new()
	var hdm: SphereMesh = SphereMesh.new()
	hdm.radius = 0.20
	hdm.height = 0.42
	head.mesh = hdm
	head.material_override = skin_mat
	head.position = Vector3(0, 1.95, 0)
	ovl.add_child(head)
	# Sun hat (wide brim straw hat)
	var hat_mat: StandardMaterial3D = StandardMaterial3D.new()
	hat_mat.albedo_color = Color(0.78, 0.62, 0.32)
	hat_mat.roughness = 0.92
	var brim: MeshInstance3D = MeshInstance3D.new()
	var brmm: CylinderMesh = CylinderMesh.new()
	brmm.top_radius = 0.42
	brmm.bottom_radius = 0.42
	brmm.height = 0.04
	brim.mesh = brmm
	brim.material_override = hat_mat
	brim.position = Vector3(0, 2.18, 0)
	ovl.add_child(brim)
	# Hat top dome
	var hat_top: MeshInstance3D = MeshInstance3D.new()
	var htm: CylinderMesh = CylinderMesh.new()
	htm.top_radius = 0.18
	htm.bottom_radius = 0.22
	htm.height = 0.18
	hat_top.mesh = htm
	hat_top.material_override = hat_mat
	hat_top.position = Vector3(0, 2.30, 0)
	ovl.add_child(hat_top)
	# Two cyan eye dots
	for s in [-1.0, 1.0]:
		var eye: MeshInstance3D = MeshInstance3D.new()
		var emm: SphereMesh = SphereMesh.new()
		emm.radius = 0.025
		emm.height = 0.05
		eye.mesh = emm
		var eye_mat: StandardMaterial3D = StandardMaterial3D.new()
		eye_mat.albedo_color = Color(0.55, 0.95, 1.0)
		eye_mat.emission_enabled = true
		eye_mat.emission = Color(0.55, 0.95, 1.0)
		eye_mat.emission_energy_multiplier = 5.0
		eye_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		eye.material_override = eye_mat
		eye.position = Vector3(0.07 * s, 1.97, 0.18)
		ovl.add_child(eye)
	# ---- Magnifying lens (held forward in right hand) ----
	var lens_pivot: Node3D = Node3D.new()
	lens_pivot.position = Vector3(0.28, 1.45, -0.45)
	lens_pivot.rotation.x = -0.20
	ovl.add_child(lens_pivot)
	# Lens handle (cylinder)
	var handle: MeshInstance3D = MeshInstance3D.new()
	var hndm: CylinderMesh = CylinderMesh.new()
	hndm.top_radius = 0.025
	hndm.bottom_radius = 0.030
	hndm.height = 0.30
	handle.mesh = hndm
	handle.material_override = brass_mat
	handle.position = Vector3(0, 0, 0)
	handle.rotation.x = PI / 2.0
	lens_pivot.add_child(handle)
	# Lens rim (torus)
	var lrim: MeshInstance3D = MeshInstance3D.new()
	var lrm: TorusMesh = TorusMesh.new()
	lrm.inner_radius = 0.10
	lrm.outer_radius = 0.13
	lrim.mesh = lrm
	lrim.material_override = brass_mat
	lrim.position = Vector3(0, 0, -0.18)
	lrim.rotation.x = PI / 2.0
	lens_pivot.add_child(lrim)
	# Lens glass disc
	var lens_glass_mat: StandardMaterial3D = StandardMaterial3D.new()
	lens_glass_mat.albedo_color = Color(0.55, 0.95, 1.0, 0.55)
	lens_glass_mat.metallic = 0.20
	lens_glass_mat.roughness = 0.10
	lens_glass_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	lens_glass_mat.emission_enabled = true
	lens_glass_mat.emission = Color(0.55, 0.95, 1.0)
	lens_glass_mat.emission_energy_multiplier = 1.40
	var lens_glass: MeshInstance3D = MeshInstance3D.new()
	var lgm: CylinderMesh = CylinderMesh.new()
	lgm.top_radius = 0.10
	lgm.bottom_radius = 0.10
	lgm.height = 0.02
	lens_glass.mesh = lgm
	lens_glass.material_override = lens_glass_mat
	lens_glass.position = Vector3(0, 0, -0.18)
	lens_glass.rotation.x = PI / 2.0
	lens_pivot.add_child(lens_glass)
	# ---- Notebook tucked under left arm ----
	var book: MeshInstance3D = MeshInstance3D.new()
	var bkm: BoxMesh = BoxMesh.new()
	bkm.size = Vector3(0.22, 0.32, 0.05)
	book.mesh = bkm
	book.material_override = apron_mat
	book.position = Vector3(-0.35, 1.10, -0.05)
	book.rotation.z = -0.20
	ovl.add_child(book)
	# Tiny brass page corner glow on book
	var corner: MeshInstance3D = MeshInstance3D.new()
	var crm: SphereMesh = SphereMesh.new()
	crm.radius = 0.03
	crm.height = 0.06
	corner.mesh = crm
	corner.material_override = glow_mat
	corner.position = Vector3(-0.30, 1.25, -0.05)
	ovl.add_child(corner)
	# Subtle warm light
	var lt: OmniLight3D = OmniLight3D.new()
	lt.position = Vector3(0, 1.55, -0.20)
	lt.light_color = Color(0.55, 0.95, 0.65)
	lt.light_energy = 1.1
	lt.omni_range = 3.2
	ovl.add_child(lt)
	# ---- Examining sway: lens hand moves slightly up and down ----
	var stir: Tween = lens_pivot.create_tween().set_loops()
	stir.tween_property(lens_pivot, "rotation:x", -0.12, 1.6).set_ease(Tween.EASE_IN_OUT)
	stir.tween_property(lens_pivot, "rotation:x", -0.32, 1.6).set_ease(Tween.EASE_IN_OUT)
	# Lens emission pulse (faint heartbeat as it scans)
	var lpulse: Tween = lens_pivot.create_tween().set_loops()
	lpulse.tween_property(lens_glass_mat, "emission_energy_multiplier", 2.4, 1.0).set_ease(Tween.EASE_IN_OUT)
	lpulse.tween_property(lens_glass_mat, "emission_energy_multiplier", 1.0, 1.0).set_ease(Tween.EASE_IN_OUT)
	# Slow body breathing
	var breath: Tween = ovl.create_tween().set_loops()
	breath.tween_property(ovl, "scale:y", 1.012, 2.0).set_ease(Tween.EASE_IN_OUT)
	breath.tween_property(ovl, "scale:y", 0.992, 2.0).set_ease(Tween.EASE_IN_OUT)


func _build_th_constellation_map(geom: Node) -> void:
	## Epic-10 T68: 3D Constellation Map — floating holographic 3D world map
	## on a brass plinth at WSW mid-plaza. Shows the 9 districts as glowing
	## colored nodes connected by data beams, slowly rotating like a
	## constellation projection above the plinth. The Town Heart sits at
	## the center as a brighter cyan-amber dual-tone node.
	var pivot: Node3D = Node3D.new()
	pivot.name = "TH_ConstellationMap"
	# WSW position at radius 11.5, angle ~PI*1.15 (between W and SW)
	var ang_pos: float = PI * 1.15
	var rad_pos: float = 11.5
	var px_p: float = cos(ang_pos) * rad_pos
	var pz_p: float = sin(ang_pos) * rad_pos
	pivot.position = TOWN_CENTER + Vector3(px_p, 0, pz_p)
	pivot.rotation.y = atan2(-px_p, -pz_p)
	geom.add_child(pivot)
	# ---- Materials ----
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.42, 0.46, 0.55)
	stone_mat.metallic = 0.20
	stone_mat.roughness = 0.85
	stone_mat.emission_enabled = true
	stone_mat.emission = Color(0.30, 0.45, 0.65)
	stone_mat.emission_energy_multiplier = 0.18
	var brass_mat: StandardMaterial3D = StandardMaterial3D.new()
	brass_mat.albedo_color = Color(0.85, 0.55, 0.18)
	brass_mat.metallic = 0.95
	brass_mat.roughness = 0.30
	brass_mat.emission_enabled = true
	brass_mat.emission = Color(1.0, 0.55, 0.12)
	brass_mat.emission_energy_multiplier = 0.55
	var beam_mat: StandardMaterial3D = StandardMaterial3D.new()
	beam_mat.albedo_color = Color(0.40, 0.85, 1.0)
	beam_mat.emission_enabled = true
	beam_mat.emission = Color(0.50, 0.90, 1.0)
	beam_mat.emission_energy_multiplier = 4.5
	beam_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	# ---- Brass plinth ----
	var plinth: MeshInstance3D = MeshInstance3D.new()
	var pmm: CylinderMesh = CylinderMesh.new()
	pmm.top_radius = 0.85
	pmm.bottom_radius = 1.05
	pmm.height = 1.20
	plinth.mesh = pmm
	plinth.material_override = stone_mat
	plinth.position = Vector3(0, 0.60, 0)
	pivot.add_child(plinth)
	# Brass cap on plinth
	var cap: MeshInstance3D = MeshInstance3D.new()
	var cmm: CylinderMesh = CylinderMesh.new()
	cmm.top_radius = 0.92
	cmm.bottom_radius = 0.95
	cmm.height = 0.10
	cap.mesh = cmm
	cap.material_override = brass_mat
	cap.position = Vector3(0, 1.25, 0)
	pivot.add_child(cap)
	# Brass control ring on the cap (interactive feel)
	var ring: MeshInstance3D = MeshInstance3D.new()
	var rtm: TorusMesh = TorusMesh.new()
	rtm.inner_radius = 0.65
	rtm.outer_radius = 0.78
	ring.mesh = rtm
	ring.material_override = brass_mat
	ring.position = Vector3(0, 1.32, 0)
	ring.rotation.x = PI / 2.0
	pivot.add_child(ring)
	# Collision
	var sb: StaticBody3D = StaticBody3D.new()
	pivot.add_child(sb)
	var col: CollisionShape3D = CollisionShape3D.new()
	var cs: CylinderShape3D = CylinderShape3D.new()
	cs.radius = 1.10
	cs.height = 1.40
	col.shape = cs
	col.position = Vector3(0, 0.70, 0)
	sb.add_child(col)
	# ---- Hologram pivot (this is what rotates) ----
	var holo_pivot: Node3D = Node3D.new()
	holo_pivot.position = Vector3(0, 2.30, 0)
	pivot.add_child(holo_pivot)
	# Holographic base disc (brass-cyan transparent disc under the constellation)
	var base_mat: StandardMaterial3D = StandardMaterial3D.new()
	base_mat.albedo_color = Color(0.40, 0.85, 1.0, 0.45)
	base_mat.metallic = 0.20
	base_mat.roughness = 0.10
	base_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	base_mat.emission_enabled = true
	base_mat.emission = Color(0.55, 0.95, 1.0)
	base_mat.emission_energy_multiplier = 1.80
	var base_disc: MeshInstance3D = MeshInstance3D.new()
	var bdm: CylinderMesh = CylinderMesh.new()
	bdm.top_radius = 0.65
	bdm.bottom_radius = 0.65
	bdm.height = 0.04
	base_disc.mesh = bdm
	base_disc.material_override = base_mat
	base_disc.position = Vector3(0, -0.85, 0)
	holo_pivot.add_child(base_disc)
	# Vertical cone of light projecting from cap to constellation
	var beam_proj_mat: StandardMaterial3D = StandardMaterial3D.new()
	beam_proj_mat.albedo_color = Color(0.55, 0.95, 1.0, 0.18)
	beam_proj_mat.metallic = 0.0
	beam_proj_mat.roughness = 1.0
	beam_proj_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	beam_proj_mat.emission_enabled = true
	beam_proj_mat.emission = Color(0.55, 0.95, 1.0)
	beam_proj_mat.emission_energy_multiplier = 1.20
	beam_proj_mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	var proj: MeshInstance3D = MeshInstance3D.new()
	var prm: CylinderMesh = CylinderMesh.new()
	prm.top_radius = 0.65
	prm.bottom_radius = 0.10
	prm.height = 1.0
	proj.mesh = prm
	proj.material_override = beam_proj_mat
	proj.position = Vector3(0, -1.40, 0)
	holo_pivot.add_child(proj)
	# ---- 9 district nodes arranged in a circle ----
	var district_colors: Array[Color] = [
		Color(0.40, 0.85, 1.0),  # D1 cyan
		Color(0.95, 0.30, 0.30),  # D2 red
		Color(0.65, 0.40, 0.95),  # D3 violet
		Color(0.40, 0.85, 0.30),  # D4 green
		Color(0.55, 0.85, 1.0),  # D5 ice
		Color(1.0, 0.30, 0.65),  # D6 magenta
		Color(0.95, 0.75, 0.30),  # D7 gold
		Color(0.30, 0.55, 0.95),  # D8 deep blue
		Color(1.0, 0.45, 0.10),  # D9 amber
	]
	var node_positions: Array[Vector3] = []
	for i in range(9):
		var ang: float = float(i) * (TAU / 9.0)
		var nx: float = cos(ang) * 0.60
		var nz: float = sin(ang) * 0.60
		# Vary y slightly so it feels 3D
		var ny: float = sin(float(i) * 0.85) * 0.18
		node_positions.append(Vector3(nx, ny, nz))
		# District node sphere
		var dn_mat: StandardMaterial3D = StandardMaterial3D.new()
		dn_mat.albedo_color = district_colors[i]
		dn_mat.emission_enabled = true
		dn_mat.emission = district_colors[i] * 1.2
		dn_mat.emission_energy_multiplier = 6.0
		dn_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		var node: MeshInstance3D = MeshInstance3D.new()
		var nmm: SphereMesh = SphereMesh.new()
		nmm.radius = 0.07
		nmm.height = 0.14
		node.mesh = nmm
		node.material_override = dn_mat
		node.position = Vector3(nx, ny, nz)
		holo_pivot.add_child(node)
		# Node pulse with phase offset
		var phase: float = float(i) * 0.22
		var npulse: Tween = node.create_tween().set_loops()
		npulse.tween_interval(phase)
		npulse.tween_property(dn_mat, "emission_energy_multiplier", 9.0, 1.4).set_ease(Tween.EASE_IN_OUT)
		npulse.tween_property(dn_mat, "emission_energy_multiplier", 4.5, 1.4).set_ease(Tween.EASE_IN_OUT)
	# ---- Center "Town Heart" dual-color node ----
	var th_mat: StandardMaterial3D = StandardMaterial3D.new()
	th_mat.albedo_color = Color(1.0, 0.85, 0.55)
	th_mat.emission_enabled = true
	th_mat.emission = Color(1.0, 0.80, 0.40)
	th_mat.emission_energy_multiplier = 9.0
	th_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var th_node: MeshInstance3D = MeshInstance3D.new()
	var thm: SphereMesh = SphereMesh.new()
	thm.radius = 0.11
	thm.height = 0.22
	th_node.mesh = thm
	th_node.material_override = th_mat
	th_node.position = Vector3(0, 0, 0)
	holo_pivot.add_child(th_node)
	# Outer glow ring around center
	var glow_ring: MeshInstance3D = MeshInstance3D.new()
	var gtm: TorusMesh = TorusMesh.new()
	gtm.inner_radius = 0.16
	gtm.outer_radius = 0.20
	glow_ring.mesh = gtm
	glow_ring.material_override = th_mat
	glow_ring.position = Vector3(0, 0, 0)
	glow_ring.rotation.x = PI / 2.0
	holo_pivot.add_child(glow_ring)
	# ---- Connection beams from each district node to the Town Heart center ----
	for j in range(9):
		var endp: Vector3 = node_positions[j]
		var beam: MeshInstance3D = MeshInstance3D.new()
		var bmm: CylinderMesh = CylinderMesh.new()
		bmm.top_radius = 0.012
		bmm.bottom_radius = 0.012
		bmm.height = endp.length()
		beam.mesh = bmm
		beam.material_override = beam_mat
		beam.position = endp * 0.5
		# Align cylinder along the vector to the endpoint
		beam.look_at_from_position(endp * 0.5, endp, Vector3(0, 1, 0))
		beam.rotate_object_local(Vector3(1, 0, 0), PI / 2.0)
		holo_pivot.add_child(beam)
	# ---- Center column light (bright cyan) ----
	var lt: OmniLight3D = OmniLight3D.new()
	lt.position = Vector3(0, 2.10, 0)
	lt.light_color = Color(0.55, 0.95, 1.0)
	lt.light_energy = 2.10
	lt.omni_range = 5.5
	pivot.add_child(lt)
	# ---- Slow rotation of the constellation hologram ----
	var rot: Tween = holo_pivot.create_tween().set_loops()
	rot.tween_property(holo_pivot, "rotation:y", TAU, 18.0).from(0.0)
	# ---- Center heart pulse ----
	var hp: Tween = holo_pivot.create_tween().set_loops()
	hp.tween_property(th_mat, "emission_energy_multiplier", 12.0, 1.8).set_ease(Tween.EASE_IN_OUT)
	hp.tween_property(th_mat, "emission_energy_multiplier", 6.0, 1.8).set_ease(Tween.EASE_IN_OUT)
	# Drifting sparkle particles around the constellation
	var sk: GPUParticles3D = GPUParticles3D.new()
	var sp: ParticleProcessMaterial = ParticleProcessMaterial.new()
	sp.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	sp.emission_sphere_radius = 0.85
	sp.direction = Vector3(0, 1, 0)
	sp.spread = 35.0
	sp.gravity = Vector3(0, 0.05, 0)
	sp.initial_velocity_min = 0.10
	sp.initial_velocity_max = 0.35
	sp.scale_min = 0.02
	sp.scale_max = 0.05
	sp.color = Color(0.55, 0.95, 1.0, 0.85)
	sk.process_material = sp
	var skm: SphereMesh = SphereMesh.new()
	skm.radius = 0.02
	skm.height = 0.04
	sk.draw_pass_1 = skm
	sk.amount = 22
	sk.lifetime = 3.0
	sk.position = Vector3(0, 2.30, 0)
	pivot.add_child(sk)


func _build_th_stargazer_npc(town: Node) -> void:
	## Epic-10 T69: Stargazer Astrid NPC — astronomer NPC standing beside the
	## 3D Constellation Map, looking up through a small brass telescope.
	## Indigo robe with cyan star-embroidery, brass spaulder, telescope held
	## in both hands tilted upward toward the holographic constellation.
	var npc_scene: PackedScene = load("res://scenes/entities/npcs/VillagerR3.tscn") as PackedScene
	if npc_scene == null:
		return
	var npc: Node = npc_scene.instantiate()
	npc.name = "Stargazer_Astrid"
	# Position: just beside the constellation map (WSW radius 11.5, ang ~PI*1.15)
	var ang_pos: float = PI * 1.15
	var rad_pos: float = 9.40
	var px: float = cos(ang_pos) * rad_pos + 0.85
	var pz: float = sin(ang_pos) * rad_pos + 0.45
	if npc is Node3D:
		(npc as Node3D).position = TOWN_CENTER + Vector3(px, 0, pz)
		# Face the constellation map (which is at WSW r=11.5)
		var map_x: float = cos(ang_pos) * 11.5
		var map_z: float = sin(ang_pos) * 11.5
		(npc as Node3D).rotation.y = atan2(map_x - px, map_z - pz)
	if "npc_name" in npc:
		npc.set("npc_name", "Stargazer Astrid")
	if "npc_id" in npc:
		npc.set("npc_id", "th_stargazer")
	town.add_child(npc)
	# ---- Cosmetic overlay ----
	var ovl: Node3D = Node3D.new()
	ovl.name = "StargazerOverlay"
	if npc is Node3D:
		(npc as Node3D).add_child(ovl)
	# Materials
	var robe_mat: StandardMaterial3D = StandardMaterial3D.new()
	robe_mat.albedo_color = Color(0.12, 0.10, 0.30)
	robe_mat.metallic = 0.10
	robe_mat.roughness = 0.85
	robe_mat.emission_enabled = true
	robe_mat.emission = Color(0.30, 0.45, 0.85)
	robe_mat.emission_energy_multiplier = 0.30
	var trim_mat: StandardMaterial3D = StandardMaterial3D.new()
	trim_mat.albedo_color = Color(0.55, 0.95, 1.0)
	trim_mat.metallic = 0.30
	trim_mat.roughness = 0.45
	trim_mat.emission_enabled = true
	trim_mat.emission = Color(0.55, 0.95, 1.0)
	trim_mat.emission_energy_multiplier = 1.85
	var brass_mat: StandardMaterial3D = StandardMaterial3D.new()
	brass_mat.albedo_color = Color(0.85, 0.55, 0.18)
	brass_mat.metallic = 0.95
	brass_mat.roughness = 0.30
	brass_mat.emission_enabled = true
	brass_mat.emission = Color(1.0, 0.55, 0.12)
	brass_mat.emission_energy_multiplier = 0.55
	var skin_mat: StandardMaterial3D = StandardMaterial3D.new()
	skin_mat.albedo_color = Color(0.85, 0.78, 0.65)
	skin_mat.roughness = 0.85
	# Indigo star robe
	var robe: MeshInstance3D = MeshInstance3D.new()
	var rmm: BoxMesh = BoxMesh.new()
	rmm.size = Vector3(0.92, 1.85, 0.55)
	robe.mesh = rmm
	robe.material_override = robe_mat
	robe.position = Vector3(0, 1.00, 0)
	ovl.add_child(robe)
	# Robe hem flare
	var hem: MeshInstance3D = MeshInstance3D.new()
	var hmm: CylinderMesh = CylinderMesh.new()
	hmm.top_radius = 0.45
	hmm.bottom_radius = 0.62
	hmm.height = 0.55
	hem.mesh = hmm
	hem.material_override = robe_mat
	hem.position = Vector3(0, 0.30, 0)
	ovl.add_child(hem)
	# Star embroidery dots scattered on the robe (5 small cyan stars)
	var star_positions: Array[Vector3] = [
		Vector3(-0.20, 1.30, -0.30),
		Vector3(0.25, 1.10, -0.30),
		Vector3(0.10, 0.85, -0.30),
		Vector3(-0.25, 0.95, -0.30),
		Vector3(0.18, 1.45, -0.30),
	]
	for sp_pos in star_positions:
		var star: MeshInstance3D = MeshInstance3D.new()
		var smm: SphereMesh = SphereMesh.new()
		smm.radius = 0.025
		smm.height = 0.05
		star.mesh = smm
		star.material_override = trim_mat
		star.position = sp_pos
		ovl.add_child(star)
	# Brass spaulder on right shoulder
	var spaulder: MeshInstance3D = MeshInstance3D.new()
	var spm: SphereMesh = SphereMesh.new()
	spm.radius = 0.18
	spm.height = 0.30
	spaulder.mesh = spm
	spaulder.material_override = brass_mat
	spaulder.position = Vector3(0.40, 1.65, 0)
	ovl.add_child(spaulder)
	# Head
	var head: MeshInstance3D = MeshInstance3D.new()
	var hdm: SphereMesh = SphereMesh.new()
	hdm.radius = 0.20
	hdm.height = 0.42
	head.mesh = hdm
	head.material_override = skin_mat
	head.position = Vector3(0, 1.95, 0)
	# Tilt head up slightly toward constellation
	head.rotation.x = -0.30
	ovl.add_child(head)
	# Indigo skullcap
	var cap_mat: StandardMaterial3D = StandardMaterial3D.new()
	cap_mat.albedo_color = Color(0.10, 0.08, 0.25)
	cap_mat.roughness = 0.85
	cap_mat.emission_enabled = true
	cap_mat.emission = Color(0.30, 0.45, 0.85)
	cap_mat.emission_energy_multiplier = 0.30
	var skullcap: MeshInstance3D = MeshInstance3D.new()
	var scm: SphereMesh = SphereMesh.new()
	scm.radius = 0.21
	scm.height = 0.25
	skullcap.mesh = scm
	skullcap.material_override = cap_mat
	skullcap.position = Vector3(0, 2.10, -0.02)
	ovl.add_child(skullcap)
	# Cyan star pin on the skullcap
	var pin: MeshInstance3D = MeshInstance3D.new()
	var pmn: SphereMesh = SphereMesh.new()
	pmn.radius = 0.04
	pmn.height = 0.08
	pin.mesh = pmn
	pin.material_override = trim_mat
	pin.position = Vector3(0, 2.18, 0.15)
	ovl.add_child(pin)
	# Two cyan eye dots
	for s in [-1.0, 1.0]:
		var eye: MeshInstance3D = MeshInstance3D.new()
		var emm: SphereMesh = SphereMesh.new()
		emm.radius = 0.025
		emm.height = 0.05
		eye.mesh = emm
		var eye_mat: StandardMaterial3D = StandardMaterial3D.new()
		eye_mat.albedo_color = Color(0.55, 0.95, 1.0)
		eye_mat.emission_enabled = true
		eye_mat.emission = Color(0.55, 0.95, 1.0)
		eye_mat.emission_energy_multiplier = 5.0
		eye_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		eye.material_override = eye_mat
		eye.position = Vector3(0.07 * s, 1.94, 0.21)
		ovl.add_child(eye)
	# ---- Telescope (held in both hands, angled upward toward constellation) ----
	var scope_pivot: Node3D = Node3D.new()
	scope_pivot.position = Vector3(0.10, 1.45, -0.40)
	scope_pivot.rotation.x = -0.85  # angled steeply upward
	ovl.add_child(scope_pivot)
	# Telescope barrel (long brass cylinder)
	var barrel: MeshInstance3D = MeshInstance3D.new()
	var bmm: CylinderMesh = CylinderMesh.new()
	bmm.top_radius = 0.06
	bmm.bottom_radius = 0.08
	bmm.height = 0.95
	barrel.mesh = bmm
	barrel.material_override = brass_mat
	barrel.position = Vector3(0, 0, -0.45)
	barrel.rotation.x = PI / 2.0
	scope_pivot.add_child(barrel)
	# Eyepiece (smaller cylinder at near end)
	var eyepc: MeshInstance3D = MeshInstance3D.new()
	var epm: CylinderMesh = CylinderMesh.new()
	epm.top_radius = 0.04
	epm.bottom_radius = 0.05
	epm.height = 0.12
	eyepc.mesh = epm
	eyepc.material_override = brass_mat
	eyepc.position = Vector3(0, 0, 0.06)
	eyepc.rotation.x = PI / 2.0
	scope_pivot.add_child(eyepc)
	# Front lens (cyan glow)
	var lens_mat: StandardMaterial3D = StandardMaterial3D.new()
	lens_mat.albedo_color = Color(0.55, 0.95, 1.0)
	lens_mat.emission_enabled = true
	lens_mat.emission = Color(0.55, 0.95, 1.0)
	lens_mat.emission_energy_multiplier = 5.5
	lens_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var lens: MeshInstance3D = MeshInstance3D.new()
	var lmm: CylinderMesh = CylinderMesh.new()
	lmm.top_radius = 0.07
	lmm.bottom_radius = 0.07
	lmm.height = 0.02
	lens.mesh = lmm
	lens.material_override = lens_mat
	lens.position = Vector3(0, 0, -0.93)
	lens.rotation.x = PI / 2.0
	scope_pivot.add_child(lens)
	# Brass focus rings (2 small toruses around barrel)
	for k in range(2):
		var ftm: TorusMesh = TorusMesh.new()
		ftm.inner_radius = 0.07
		ftm.outer_radius = 0.10
		var fring: MeshInstance3D = MeshInstance3D.new()
		fring.mesh = ftm
		fring.material_override = brass_mat
		fring.position = Vector3(0, 0, -0.30 - float(k) * 0.30)
		fring.rotation.y = PI / 2.0
		scope_pivot.add_child(fring)
	# Subtle cool light from astronomer
	var lt: OmniLight3D = OmniLight3D.new()
	lt.position = Vector3(0, 1.55, -0.20)
	lt.light_color = Color(0.55, 0.85, 1.0)
	lt.light_energy = 1.10
	lt.omni_range = 3.2
	ovl.add_child(lt)
	# ---- Telescope tilt sway (subtle scanning motion) ----
	var stir: Tween = scope_pivot.create_tween().set_loops()
	stir.tween_property(scope_pivot, "rotation:x", -0.70, 2.4).set_ease(Tween.EASE_IN_OUT)
	stir.tween_property(scope_pivot, "rotation:x", -1.00, 2.4).set_ease(Tween.EASE_IN_OUT)
	# Also pan slightly side-to-side
	var pan: Tween = scope_pivot.create_tween().set_loops()
	pan.tween_property(scope_pivot, "rotation:y", 0.10, 2.0).set_ease(Tween.EASE_IN_OUT)
	pan.tween_property(scope_pivot, "rotation:y", -0.10, 2.0).set_ease(Tween.EASE_IN_OUT)
	# Lens pulse
	var lpulse: Tween = scope_pivot.create_tween().set_loops()
	lpulse.tween_property(lens_mat, "emission_energy_multiplier", 8.0, 1.4).set_ease(Tween.EASE_IN_OUT)
	lpulse.tween_property(lens_mat, "emission_energy_multiplier", 4.0, 1.4).set_ease(Tween.EASE_IN_OUT)
	# Slow body breathing
	var breath: Tween = ovl.create_tween().set_loops()
	breath.tween_property(ovl, "scale:y", 1.012, 2.0).set_ease(Tween.EASE_IN_OUT)
	breath.tween_property(ovl, "scale:y", 0.992, 2.0).set_ease(Tween.EASE_IN_OUT)


func _build_th_combat_trial_pit(geom: Node) -> void:
	## Epic-10 T70 (70/100 milestone): Combat Trial Pit — sunken sand-floor
	## combat practice arena at ESE mid-plaza. Brass-ringed perimeter wall,
	## 4 corner torch posts, 2 stone training golems standing inside, low
	## entry step at the front. Real combat-themed practice space for the
	## player to test their attacks against stationary targets.
	var pivot: Node3D = Node3D.new()
	pivot.name = "TH_CombatTrialPit"
	# ESE position at radius 11.5, angle ~-PI*0.20 (between E and SE)
	var ang_pos: float = -PI * 0.20
	var rad_pos: float = 11.5
	var px_p: float = cos(ang_pos) * rad_pos
	var pz_p: float = sin(ang_pos) * rad_pos
	pivot.position = TOWN_CENTER + Vector3(px_p, 0, pz_p)
	pivot.rotation.y = atan2(-px_p, -pz_p)
	geom.add_child(pivot)
	# ---- Materials ----
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.42, 0.46, 0.55)
	stone_mat.metallic = 0.20
	stone_mat.roughness = 0.85
	stone_mat.emission_enabled = true
	stone_mat.emission = Color(0.30, 0.45, 0.65)
	stone_mat.emission_energy_multiplier = 0.18
	var brass_mat: StandardMaterial3D = StandardMaterial3D.new()
	brass_mat.albedo_color = Color(0.85, 0.55, 0.18)
	brass_mat.metallic = 0.95
	brass_mat.roughness = 0.30
	brass_mat.emission_enabled = true
	brass_mat.emission = Color(1.0, 0.55, 0.12)
	brass_mat.emission_energy_multiplier = 0.55
	var sand_mat: StandardMaterial3D = StandardMaterial3D.new()
	sand_mat.albedo_color = Color(0.78, 0.62, 0.35)
	sand_mat.roughness = 0.95
	sand_mat.emission_enabled = true
	sand_mat.emission = Color(0.85, 0.65, 0.30)
	sand_mat.emission_energy_multiplier = 0.10
	var golem_mat: StandardMaterial3D = StandardMaterial3D.new()
	golem_mat.albedo_color = Color(0.32, 0.36, 0.42)
	golem_mat.metallic = 0.40
	golem_mat.roughness = 0.65
	golem_mat.emission_enabled = true
	golem_mat.emission = Color(0.45, 0.55, 0.70)
	golem_mat.emission_energy_multiplier = 0.25
	var rune_mat: StandardMaterial3D = StandardMaterial3D.new()
	rune_mat.albedo_color = Color(0.55, 0.95, 1.0)
	rune_mat.emission_enabled = true
	rune_mat.emission = Color(0.55, 0.95, 1.0)
	rune_mat.emission_energy_multiplier = 4.5
	rune_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var flame_mat: StandardMaterial3D = StandardMaterial3D.new()
	flame_mat.albedo_color = Color(1.0, 0.55, 0.10)
	flame_mat.emission_enabled = true
	flame_mat.emission = Color(1.0, 0.60, 0.15)
	flame_mat.emission_energy_multiplier = 9.0
	flame_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	# ---- Pit dimensions ----
	var pit_w: float = 4.50
	var pit_d: float = 0.45
	# ---- Stone perimeter wall (4 sides) ----
	var wall_h: float = 0.55
	var wall_t: float = 0.30
	var wall_positions: Array = [
		Vector3(0, wall_h * 0.5, (pit_w * 0.5) + (wall_t * 0.5)),
		Vector3(0, wall_h * 0.5, -(pit_w * 0.5) - (wall_t * 0.5)),
		Vector3((pit_w * 0.5) + (wall_t * 0.5), wall_h * 0.5, 0),
		Vector3(-(pit_w * 0.5) - (wall_t * 0.5), wall_h * 0.5, 0),
	]
	var sb: StaticBody3D = StaticBody3D.new()
	pivot.add_child(sb)
	for i in range(4):
		var wall: MeshInstance3D = MeshInstance3D.new()
		var wmm: BoxMesh = BoxMesh.new()
		if i < 2:
			wmm.size = Vector3(pit_w + (wall_t * 2.0), wall_h, wall_t)
		else:
			wmm.size = Vector3(wall_t, wall_h, pit_w + (wall_t * 2.0))
		wall.mesh = wmm
		wall.material_override = stone_mat
		wall.position = wall_positions[i]
		pivot.add_child(wall)
		# Brass cap on top of wall
		var cap: MeshInstance3D = MeshInstance3D.new()
		var cmm: BoxMesh = BoxMesh.new()
		if i < 2:
			cmm.size = Vector3(pit_w + (wall_t * 2.0) + 0.05, 0.06, wall_t + 0.05)
		else:
			cmm.size = Vector3(wall_t + 0.05, 0.06, pit_w + (wall_t * 2.0) + 0.05)
		cap.mesh = cmm
		cap.material_override = brass_mat
		cap.position = Vector3(wall_positions[i].x, wall_h + 0.03, wall_positions[i].z)
		pivot.add_child(cap)
		# Wall collision (skip front-facing wall to allow entry)
		if i != 1:  # i==1 is the negative-Z (front) side relative to pivot rotation
			var col: CollisionShape3D = CollisionShape3D.new()
			var cs: BoxShape3D = BoxShape3D.new()
			if i < 2:
				cs.size = Vector3(pit_w + (wall_t * 2.0), wall_h + 0.06, wall_t)
			else:
				cs.size = Vector3(wall_t, wall_h + 0.06, pit_w + (wall_t * 2.0))
			col.shape = cs
			col.position = wall_positions[i]
			sb.add_child(col)
	# ---- Sand floor (slightly recessed) ----
	var sand: MeshInstance3D = MeshInstance3D.new()
	var sdm: BoxMesh = BoxMesh.new()
	sdm.size = Vector3(pit_w, 0.10, pit_w)
	sand.mesh = sdm
	sand.material_override = sand_mat
	sand.position = Vector3(0, 0.05, 0)
	pivot.add_child(sand)
	# Center cyan combat circle rune
	var ring: MeshInstance3D = MeshInstance3D.new()
	var rtm: TorusMesh = TorusMesh.new()
	rtm.inner_radius = 1.10
	rtm.outer_radius = 1.25
	ring.mesh = rtm
	ring.material_override = rune_mat
	ring.position = Vector3(0, 0.11, 0)
	ring.rotation.x = PI / 2.0
	pivot.add_child(ring)
	# Inner cross runes (4 thin tiles forming a "+")
	for k in range(4):
		var ang: float = float(k) * (PI / 2.0)
		var tile: MeshInstance3D = MeshInstance3D.new()
		var tmm: BoxMesh = BoxMesh.new()
		tmm.size = Vector3(0.08, 0.02, 0.45)
		tile.mesh = tmm
		tile.material_override = rune_mat
		tile.position = Vector3(cos(ang) * 0.55, 0.12, sin(ang) * 0.55)
		tile.rotation.y = ang
		pivot.add_child(tile)
	# ---- 2 stone training golems inside the pit ----
	var golem_positions: Array = [
		Vector3(-1.30, 0.10, -0.40),
		Vector3(1.30, 0.10, 0.40),
	]
	var glow_orbs: Array[StandardMaterial3D] = []
	for j in range(2):
		var golem: Node3D = Node3D.new()
		golem.position = golem_positions[j]
		# Face roughly toward pit center
		golem.rotation.y = atan2(-golem_positions[j].x, -golem_positions[j].z)
		pivot.add_child(golem)
		# Stone base block
		var base: MeshInstance3D = MeshInstance3D.new()
		var bmm: BoxMesh = BoxMesh.new()
		bmm.size = Vector3(0.55, 0.18, 0.55)
		base.mesh = bmm
		base.material_override = stone_mat
		base.position = Vector3(0, 0.09, 0)
		golem.add_child(base)
		# Body (chunky stone torso)
		var body: MeshInstance3D = MeshInstance3D.new()
		var bdm: BoxMesh = BoxMesh.new()
		bdm.size = Vector3(0.85, 1.10, 0.55)
		body.mesh = bdm
		body.material_override = golem_mat
		body.position = Vector3(0, 0.75, 0)
		golem.add_child(body)
		# Head
		var head: MeshInstance3D = MeshInstance3D.new()
		var hdm: BoxMesh = BoxMesh.new()
		hdm.size = Vector3(0.42, 0.42, 0.42)
		head.mesh = hdm
		head.material_override = golem_mat
		head.position = Vector3(0, 1.55, 0)
		golem.add_child(head)
		# 2 cyan eye dots
		for s in [-1.0, 1.0]:
			var eye_mat: StandardMaterial3D = StandardMaterial3D.new()
			eye_mat.albedo_color = Color(0.55, 0.95, 1.0)
			eye_mat.emission_enabled = true
			eye_mat.emission = Color(0.55, 0.95, 1.0)
			eye_mat.emission_energy_multiplier = 6.0
			eye_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
			var eye: MeshInstance3D = MeshInstance3D.new()
			var emm: SphereMesh = SphereMesh.new()
			emm.radius = 0.045
			emm.height = 0.09
			eye.mesh = emm
			eye.material_override = eye_mat
			eye.position = Vector3(0.10 * s, 1.58, 0.21)
			golem.add_child(eye)
		# Brass shoulder bands
		for s2 in [-1.0, 1.0]:
			var pad: MeshInstance3D = MeshInstance3D.new()
			var pdm: BoxMesh = BoxMesh.new()
			pdm.size = Vector3(0.20, 0.12, 0.60)
			pad.mesh = pdm
			pad.material_override = brass_mat
			pad.position = Vector3(0.50 * s2, 1.20, 0)
			golem.add_child(pad)
		# Arms (cylinders hanging at sides)
		for s3 in [-1.0, 1.0]:
			var arm: MeshInstance3D = MeshInstance3D.new()
			var amm: CylinderMesh = CylinderMesh.new()
			amm.top_radius = 0.10
			amm.bottom_radius = 0.12
			amm.height = 0.95
			arm.mesh = amm
			arm.material_override = golem_mat
			arm.position = Vector3(0.55 * s3, 0.85, 0)
			golem.add_child(arm)
		# Brass core orb on chest (this is the "weak point" target)
		var orb_mat: StandardMaterial3D = StandardMaterial3D.new()
		orb_mat.albedo_color = Color(1.0, 0.55, 0.15)
		orb_mat.emission_enabled = true
		orb_mat.emission = Color(1.0, 0.60, 0.20)
		orb_mat.emission_energy_multiplier = 6.5
		orb_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		glow_orbs.append(orb_mat)
		var orb: MeshInstance3D = MeshInstance3D.new()
		var omm: SphereMesh = SphereMesh.new()
		omm.radius = 0.13
		omm.height = 0.26
		orb.mesh = omm
		orb.material_override = orb_mat
		orb.position = Vector3(0, 0.95, 0.32)
		golem.add_child(orb)
		# Golem collision (so player attacks register)
		var gsb: StaticBody3D = StaticBody3D.new()
		golem.add_child(gsb)
		var gcol: CollisionShape3D = CollisionShape3D.new()
		var gcs: BoxShape3D = BoxShape3D.new()
		gcs.size = Vector3(0.95, 1.85, 0.65)
		gcol.shape = gcs
		gcol.position = Vector3(0, 0.95, 0)
		gsb.add_child(gcol)
		# Slight idle sway (lean side to side)
		var phase: float = float(j) * 0.6
		var idle: Tween = golem.create_tween().set_loops()
		idle.tween_interval(phase)
		idle.tween_property(golem, "rotation:z", 0.04, 1.6).set_ease(Tween.EASE_IN_OUT)
		idle.tween_property(golem, "rotation:z", -0.04, 1.6).set_ease(Tween.EASE_IN_OUT)
		# Eye/orb pulse
		var op: Tween = golem.create_tween().set_loops()
		op.tween_property(orb_mat, "emission_energy_multiplier", 9.0, 1.2).set_ease(Tween.EASE_IN_OUT)
		op.tween_property(orb_mat, "emission_energy_multiplier", 4.5, 1.2).set_ease(Tween.EASE_IN_OUT)
	# ---- 4 corner torch posts ----
	var torch_offsets: Array = [
		Vector3((pit_w * 0.5) + 0.18, 0, (pit_w * 0.5) + 0.18),
		Vector3(-(pit_w * 0.5) - 0.18, 0, (pit_w * 0.5) + 0.18),
		Vector3((pit_w * 0.5) + 0.18, 0, -(pit_w * 0.5) - 0.18),
		Vector3(-(pit_w * 0.5) - 0.18, 0, -(pit_w * 0.5) - 0.18),
	]
	for t in range(4):
		var post: MeshInstance3D = MeshInstance3D.new()
		var pmm: CylinderMesh = CylinderMesh.new()
		pmm.top_radius = 0.06
		pmm.bottom_radius = 0.10
		pmm.height = 1.45
		post.mesh = pmm
		post.material_override = brass_mat
		post.position = torch_offsets[t] + Vector3(0, 0.72, 0)
		pivot.add_child(post)
		# Torch bowl
		var bowl: MeshInstance3D = MeshInstance3D.new()
		var bwm: CylinderMesh = CylinderMesh.new()
		bwm.top_radius = 0.18
		bwm.bottom_radius = 0.10
		bwm.height = 0.10
		bowl.mesh = bwm
		bowl.material_override = brass_mat
		bowl.position = torch_offsets[t] + Vector3(0, 1.50, 0)
		pivot.add_child(bowl)
		# Flame
		var flame: MeshInstance3D = MeshInstance3D.new()
		var flmm: SphereMesh = SphereMesh.new()
		flmm.radius = 0.13
		flmm.height = 0.26
		flame.mesh = flmm
		flame.material_override = flame_mat
		flame.position = torch_offsets[t] + Vector3(0, 1.65, 0)
		pivot.add_child(flame)
		# Torch light
		var lt: OmniLight3D = OmniLight3D.new()
		lt.position = torch_offsets[t] + Vector3(0, 1.70, 0)
		lt.light_color = Color(1.0, 0.55, 0.15)
		lt.light_energy = 1.45
		lt.omni_range = 4.5
		pivot.add_child(lt)
		# Flame flicker
		var ff: Tween = flame.create_tween().set_loops()
		ff.tween_interval(float(t) * 0.20)
		ff.tween_property(flame, "scale", Vector3(1.20, 1.40, 1.20), 0.30).set_ease(Tween.EASE_IN_OUT)
		ff.tween_property(flame, "scale", Vector3(0.90, 1.10, 0.90), 0.40).set_ease(Tween.EASE_IN_OUT)
	# ---- Front entry step (low brass plate at the front of the pit) ----
	var step: MeshInstance3D = MeshInstance3D.new()
	var stmm: BoxMesh = BoxMesh.new()
	stmm.size = Vector3(1.40, 0.08, 0.45)
	step.mesh = stmm
	step.material_override = brass_mat
	step.position = Vector3(0, 0.04, -(pit_w * 0.5) - (wall_t * 0.5))
	pivot.add_child(step)


func _build_th_pit_master_npc(town: Node) -> void:
	## Epic-10 T71: Pit Master Krell NPC — battle-scarred trainer NPC standing
	## just outside the front entry step of the combat pit, arms folded across
	## chest, watching the training golems. Iron-plated brown vest, brass
	## shoulder spikes, scar across one eye, broader muscular build.
	var npc_scene: PackedScene = load("res://scenes/entities/npcs/VillagerR3.tscn") as PackedScene
	if npc_scene == null:
		return
	var npc: Node = npc_scene.instantiate()
	npc.name = "PitMaster_Krell"
	# Position: just outside the combat pit's front step (ESE r=11.5, ang ~-PI*0.20)
	# Place slightly inward (closer to plaza center) and offset to the side
	var ang_pos: float = -PI * 0.20
	var rad_pos: float = 9.10
	var px: float = cos(ang_pos) * rad_pos - 0.30
	var pz: float = sin(ang_pos) * rad_pos - 0.85
	if npc is Node3D:
		(npc as Node3D).position = TOWN_CENTER + Vector3(px, 0, pz)
		# Face the combat pit
		var pit_x: float = cos(ang_pos) * 11.5
		var pit_z: float = sin(ang_pos) * 11.5
		(npc as Node3D).rotation.y = atan2(pit_x - px, pit_z - pz)
	if "npc_name" in npc:
		npc.set("npc_name", "Pit Master Krell")
	if "npc_id" in npc:
		npc.set("npc_id", "th_pit_master")
	town.add_child(npc)
	# ---- Cosmetic overlay ----
	var ovl: Node3D = Node3D.new()
	ovl.name = "PitMasterOverlay"
	if npc is Node3D:
		(npc as Node3D).add_child(ovl)
	# Materials
	var vest_mat: StandardMaterial3D = StandardMaterial3D.new()
	vest_mat.albedo_color = Color(0.32, 0.20, 0.12)
	vest_mat.metallic = 0.10
	vest_mat.roughness = 0.92
	var iron_mat: StandardMaterial3D = StandardMaterial3D.new()
	iron_mat.albedo_color = Color(0.30, 0.32, 0.38)
	iron_mat.metallic = 0.85
	iron_mat.roughness = 0.40
	iron_mat.emission_enabled = true
	iron_mat.emission = Color(0.45, 0.55, 0.70)
	iron_mat.emission_energy_multiplier = 0.20
	var brass_mat: StandardMaterial3D = StandardMaterial3D.new()
	brass_mat.albedo_color = Color(0.85, 0.55, 0.18)
	brass_mat.metallic = 0.95
	brass_mat.roughness = 0.30
	brass_mat.emission_enabled = true
	brass_mat.emission = Color(1.0, 0.55, 0.12)
	brass_mat.emission_energy_multiplier = 0.55
	var skin_mat: StandardMaterial3D = StandardMaterial3D.new()
	skin_mat.albedo_color = Color(0.78, 0.62, 0.48)
	skin_mat.roughness = 0.85
	var pant_mat: StandardMaterial3D = StandardMaterial3D.new()
	pant_mat.albedo_color = Color(0.18, 0.20, 0.25)
	pant_mat.roughness = 0.92
	# Wide brown vest (broader than standard NPC torso)
	var vest: MeshInstance3D = MeshInstance3D.new()
	var vmm: BoxMesh = BoxMesh.new()
	vmm.size = Vector3(1.10, 0.95, 0.62)
	vest.mesh = vmm
	vest.material_override = vest_mat
	vest.position = Vector3(0, 1.30, 0)
	ovl.add_child(vest)
	# Iron plate strapped to chest
	var plate: MeshInstance3D = MeshInstance3D.new()
	var pmm: BoxMesh = BoxMesh.new()
	pmm.size = Vector3(0.85, 0.65, 0.06)
	plate.mesh = pmm
	plate.material_override = iron_mat
	plate.position = Vector3(0, 1.40, -0.36)
	ovl.add_child(plate)
	# Brass rivets on the iron plate (4 corners)
	for s in [-1.0, 1.0]:
		for s2 in [-1.0, 1.0]:
			var rivet: MeshInstance3D = MeshInstance3D.new()
			var rmm: SphereMesh = SphereMesh.new()
			rmm.radius = 0.04
			rmm.height = 0.08
			rivet.mesh = rmm
			rivet.material_override = brass_mat
			rivet.position = Vector3(0.32 * s, 1.40 + 0.22 * s2, -0.40)
			ovl.add_child(rivet)
	# Wide pants/skirt section
	var pants: MeshInstance3D = MeshInstance3D.new()
	var psm: BoxMesh = BoxMesh.new()
	psm.size = Vector3(0.95, 0.95, 0.55)
	pants.mesh = psm
	pants.material_override = pant_mat
	pants.position = Vector3(0, 0.45, 0)
	ovl.add_child(pants)
	# Brass belt buckle
	var belt: MeshInstance3D = MeshInstance3D.new()
	var blm: BoxMesh = BoxMesh.new()
	blm.size = Vector3(1.05, 0.10, 0.62)
	belt.mesh = blm
	belt.material_override = brass_mat
	belt.position = Vector3(0, 0.95, 0)
	ovl.add_child(belt)
	# Brass shoulder spikes (2)
	for s3 in [-1.0, 1.0]:
		var spike_pivot: Node3D = Node3D.new()
		spike_pivot.position = Vector3(0.55 * s3, 1.75, 0)
		ovl.add_child(spike_pivot)
		# Shoulder cap
		var spc: MeshInstance3D = MeshInstance3D.new()
		var spcm: SphereMesh = SphereMesh.new()
		spcm.radius = 0.18
		spcm.height = 0.30
		spc.mesh = spcm
		spc.material_override = brass_mat
		spc.position = Vector3(0, 0, 0)
		spike_pivot.add_child(spc)
		# Spike (PrismMesh tip)
		var spike: MeshInstance3D = MeshInstance3D.new()
		var spkm: PrismMesh = PrismMesh.new()
		spkm.size = Vector3(0.10, 0.32, 0.10)
		spike.mesh = spkm
		spike.material_override = brass_mat
		spike.position = Vector3(0.04 * s3, 0.18, 0)
		spike.rotation.z = -0.30 * s3
		spike_pivot.add_child(spike)
	# Head
	var head: MeshInstance3D = MeshInstance3D.new()
	var hdm: SphereMesh = SphereMesh.new()
	hdm.radius = 0.22
	hdm.height = 0.46
	head.mesh = hdm
	head.material_override = skin_mat
	head.position = Vector3(0, 1.97, 0)
	ovl.add_child(head)
	# Bald head dome (no hair) — slight darker tone for shaved look already
	# Two cyan eye dots
	for s4 in [-1.0, 1.0]:
		var eye: MeshInstance3D = MeshInstance3D.new()
		var emm: SphereMesh = SphereMesh.new()
		emm.radius = 0.027
		emm.height = 0.054
		eye.mesh = emm
		var eye_mat: StandardMaterial3D = StandardMaterial3D.new()
		eye_mat.albedo_color = Color(0.55, 0.95, 1.0)
		eye_mat.emission_enabled = true
		eye_mat.emission = Color(0.55, 0.95, 1.0)
		eye_mat.emission_energy_multiplier = 5.5
		eye_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		eye.material_override = eye_mat
		eye.position = Vector3(0.08 * s4, 1.99, 0.20)
		ovl.add_child(eye)
	# Diagonal scar across one eye (small brass-amber line)
	var scar_mat: StandardMaterial3D = StandardMaterial3D.new()
	scar_mat.albedo_color = Color(0.95, 0.45, 0.25)
	scar_mat.emission_enabled = true
	scar_mat.emission = Color(0.95, 0.45, 0.20)
	scar_mat.emission_energy_multiplier = 1.20
	var scar: MeshInstance3D = MeshInstance3D.new()
	var scrm: BoxMesh = BoxMesh.new()
	scrm.size = Vector3(0.025, 0.18, 0.025)
	scar.mesh = scrm
	scar.material_override = scar_mat
	scar.position = Vector3(-0.08, 1.99, 0.21)
	scar.rotation.z = 0.50
	ovl.add_child(scar)
	# ---- Folded arms (two arms crossed across chest) ----
	for s5 in [-1.0, 1.0]:
		var arm: MeshInstance3D = MeshInstance3D.new()
		var amm: CylinderMesh = CylinderMesh.new()
		amm.top_radius = 0.10
		amm.bottom_radius = 0.13
		amm.height = 0.65
		arm.mesh = amm
		arm.material_override = skin_mat
		arm.position = Vector3(0.10 * s5, 1.30, -0.32)
		# Cross arms — rotate so each arm goes across chest
		arm.rotation.z = (PI / 2.5) * -s5
		ovl.add_child(arm)
		# Brass wristband
		var wrist: MeshInstance3D = MeshInstance3D.new()
		var wtm: TorusMesh = TorusMesh.new()
		wtm.inner_radius = 0.10
		wtm.outer_radius = 0.14
		wrist.mesh = wtm
		wrist.material_override = brass_mat
		wrist.position = Vector3(-0.30 * s5, 1.30, -0.32)
		wrist.rotation.z = PI / 2.0
		ovl.add_child(wrist)
	# Subtle warm authority light
	var lt: OmniLight3D = OmniLight3D.new()
	lt.position = Vector3(0, 1.65, -0.20)
	lt.light_color = Color(1.0, 0.65, 0.30)
	lt.light_energy = 1.20
	lt.omni_range = 3.4
	ovl.add_child(lt)
	# ---- Slow imposing breathing (chest expansion) ----
	var breath: Tween = ovl.create_tween().set_loops()
	breath.tween_property(ovl, "scale:y", 1.018, 2.4).set_ease(Tween.EASE_IN_OUT)
	breath.tween_property(ovl, "scale:y", 0.988, 2.4).set_ease(Tween.EASE_IN_OUT)
	# Eye ember slow pulse
	var epulse: Tween = ovl.create_tween().set_loops()
	epulse.tween_property(scar_mat, "emission_energy_multiplier", 2.4, 1.8).set_ease(Tween.EASE_IN_OUT)
	epulse.tween_property(scar_mat, "emission_energy_multiplier", 0.80, 1.8).set_ease(Tween.EASE_IN_OUT)
