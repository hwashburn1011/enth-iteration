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
