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
