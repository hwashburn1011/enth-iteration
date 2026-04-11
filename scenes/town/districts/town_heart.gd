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
