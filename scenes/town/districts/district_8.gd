class_name D8Builder
extends RefCounted
## Tidal Harbor district builder — extracted from scenes/town/town.gd to keep
## the main town script modular and under control. All build helpers here are
## static and called from town.gd's _build_district_8() entry function.
##
## NPC helpers receive `town: Node` so they can resolve %NPCSlots; geom helpers
## receive `geom: Node` (the town's Geometry node). All other helpers are
## self-contained and only use Godot built-ins.

const D8_CENTER := Vector3(540, 0, 0)


static func extend_boundary(geom: Node) -> void:
	## Push the east boundary wall from x=530 out to x=630 to make room for D8.
	var east_wall: CSGBox3D = geom.get_node_or_null("BoundaryEast") as CSGBox3D
	if east_wall:
		east_wall.position.x = 630.0


static func build(town: Node, geom: Node) -> void:
	## Entry point — called from town.gd::_build_district_8(geom).
	print("[D8Builder] start")
	extend_boundary(geom)
	_build_d8_ground(geom)
	_build_d8_dock_entrance(geom)
	_build_d8_great_lighthouse(geom)
	_build_d8_harbor_master_npc(town)
	_build_d8_fishing_boat(geom)
	_build_d8_d8_fisherman_npc(town)
	_build_d8_fish_crates(geom)
	_build_d8_seagulls(geom)
	_build_d8_sea_spray(geom)
	_build_d8_shipwreck(geom)
	_build_d8_sailor_npc(town)
	_build_d8_giant_anchor(geom)
	_build_d8_pilings_row(geom)
	_build_d8_dolphins(geom)
	_build_d8_tavern(geom)
	_build_d8_tavern_keeper_npc(town)
	_build_d8_barrel_stack(geom)
	_build_d8_rope_coils(geom)
	_build_d8_lantern_posts(geom)
	_build_d8_clam_digger_npc(town)
	_build_d8_tide_pools(geom)
	_build_d8_starfish(geom)
	_build_d8_warning_bell(geom)
	_build_d8_net_mending(geom)
	_build_d8_kraken(geom)
	_build_d8_harpooner_npc(town)
	_build_d8_signal_flags(geom)
	_build_d8_buoys(geom)
	_build_d8_jellyfish_glow(geom)
	_build_d8_shipyard_scaffold(geom)
	_build_d8_shipwright_npc(town)
	_build_d8_cargo_crane(geom)
	_build_d8_dock_workers(geom)
	_build_d8_tide_gauge(geom)
	_build_d8_treasure_chest(geom)
	_build_d8_treasure_hunter_npc(town)
	_build_d8_bottle_display(geom)
	_build_d8_bottle_artisan_npc(town)
	_build_d8_mines(geom)
	_build_d8_warship(geom)
	_build_d8_navy_captain_npc(town)
	_build_d8_cannons_row(geom)
	_build_d8_gunpowder_barrels(geom)
	_build_d8_lifeguard_tower(geom)
	_build_d8_pirate_flag(geom)
	_build_d8_pirate_captain_npc(town)
	_build_d8_pirate_crew(geom)
	_build_d8_parrots(geom)
	_build_d8_sea_tyrant(geom)
	_build_d8_rowboats(geom)
	_build_d8_oar_maker_npc(town)
	_build_d8_fish_market(geom)
	_build_d8_fishmonger_npc(town)
	_build_d8_fish_dryer(geom)
	_build_d8_sea_turtles(geom)
	_build_d8_marine_biologist_npc(town)
	_build_d8_aquarium_tank(geom)
	_build_d8_specimen_jars(geom)
	_build_d8_diving_rig(geom)
	_build_d8_pearl_diver_npc(town)
	_build_d8_oysters(geom)
	_build_d8_crabs(geom)
	_build_d8_dock_bridge(geom)
	_build_d8_anemones(geom)
	_build_d8_lighthouse(geom)
	_build_d8_cargo_containers(geom)
	_build_d8_quay_master_npc(town)
	_build_d8_buoy_field(geom)
	_build_d8_tied_fishing_boat(geom)
	_build_d8_sailing_yacht(geom)
	_build_d8_shanty_singer_npc(town)
	_build_d8_crows_nest(geom)
	_build_d8_message_bottles(geom)
	_build_d8_tide_markers(geom)
	_build_d8_customs_office(geom)
	_build_d8_customs_officer_npc(town)
	_build_d8_anchor_chain(geom)
	_build_d8_whale_watch_tower(geom)
	_build_d8_tied_barrels(geom)
	_build_d8_mermaid_fountain(geom)
	_build_d8_cartographer_npc(town)
	_build_d8_market_raft(geom)
	_build_d8_smokehouse(geom)
	_build_d8_wind_chimes(geom)
	_build_d8_sea_cave(geom)
	_build_d8_submarine(geom)
	_build_d8_rope_coil_pyramid(geom)
	_build_d8_shore_patrol_npc(town)
	_build_d8_circling_gulls(geom)
	_build_d8_whirlpool_teaser(geom)
	_build_d8_ship_graveyard(geom)
	_build_d8_storm_clouds(geom)
	_build_d8_tentacle_silhouettes(geom)
	_build_d8_warning_siren(geom)
	_build_d8_welcome_banner(geom)
	_build_d8_storm_fog(geom)
	_build_d8_finale_plaque(geom)
	_build_d8_boss_arena_fortifications(geom)
	_build_d8_tide_leviathan(geom)
	print("[D8Builder] done")


static func _build_d8_ground(geom: Node) -> void:
	## Epic-8 T1b: D8 ground — translucent teal water plane with a wood
	## boardwalk pattern overlaid for the dock area.
	var plane: PlaneMesh = PlaneMesh.new()
	plane.size = Vector2(80, 40)
	var ground: MeshInstance3D = MeshInstance3D.new()
	ground.mesh = plane
	var water_mat: StandardMaterial3D = StandardMaterial3D.new()
	water_mat.albedo_color = Color(0.20, 0.55, 0.65)
	water_mat.emission_enabled = true
	water_mat.emission = Color(0.20, 0.65, 0.75)
	water_mat.emission_energy_multiplier = 0.30
	water_mat.metallic = 0.30
	water_mat.roughness = 0.20
	ground.material_override = water_mat
	ground.position = Vector3(D8_CENTER.x, 0.01, 0)
	ground.name = "D8WaterGround"
	geom.add_child(ground)
	# 4 wooden boardwalk planks running east-west
	var wood_mat: StandardMaterial3D = StandardMaterial3D.new()
	wood_mat.albedo_color = Color(0.45, 0.28, 0.12)
	wood_mat.roughness = 0.85
	for i in 4:
		var plank: MeshInstance3D = MeshInstance3D.new()
		var pm: BoxMesh = BoxMesh.new()
		pm.size = Vector3(75.0, 0.18, 1.40)
		plank.mesh = pm
		plank.material_override = wood_mat
		plank.position = Vector3(D8_CENTER.x, 0.10, -10.0 + i * 6.85)
		geom.add_child(plank)
	# 30 small bubble particles randomly placed (water atmosphere)
	var bubble_mat: StandardMaterial3D = StandardMaterial3D.new()
	bubble_mat.albedo_color = Color(0.85, 0.95, 1.0, 0.55)
	bubble_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	bubble_mat.emission_enabled = true
	bubble_mat.emission = Color(0.85, 0.95, 1.0)
	bubble_mat.emission_energy_multiplier = 0.65
	bubble_mat.metallic = 0.65
	bubble_mat.roughness = 0.05
	for i in 30:
		var bubble: MeshInstance3D = MeshInstance3D.new()
		var bm: SphereMesh = SphereMesh.new()
		bm.radius = 0.08 + randf() * 0.10
		bm.height = 0.16 + randf() * 0.18
		bubble.mesh = bm
		bubble.material_override = bubble_mat
		bubble.position = Vector3(
			D8_CENTER.x + randf_range(-32, 32),
			0.18,
			randf_range(-18, 18)
		)
		geom.add_child(bubble)


static func _build_d8_dock_entrance(geom: Node) -> void:
	## Epic-8 T2: dock entrance arch — 2 wooden pilings with a curved
	## driftwood crossbar + hanging fishing nets.
	var arch: Node3D = Node3D.new()
	arch.name = "D8DockEntrance"
	arch.position = Vector3(D8_CENTER.x - 32.0, 0.0, 0.0)
	geom.add_child(arch)
	var wood_mat: StandardMaterial3D = StandardMaterial3D.new()
	wood_mat.albedo_color = Color(0.40, 0.25, 0.10)
	wood_mat.roughness = 0.92
	var weathered: StandardMaterial3D = StandardMaterial3D.new()
	weathered.albedo_color = Color(0.55, 0.45, 0.30)
	weathered.roughness = 0.92
	# 2 thick wooden pilings
	for sx in [-2.40, 2.40]:
		var piling: MeshInstance3D = MeshInstance3D.new()
		var pm: CylinderMesh = CylinderMesh.new()
		pm.top_radius = 0.30
		pm.bottom_radius = 0.40
		pm.height = 5.85
		piling.mesh = pm
		piling.material_override = wood_mat
		piling.position = Vector3(sx, 2.92, 0)
		arch.add_child(piling)
		# Piling collision
		var sb: StaticBody3D = StaticBody3D.new()
		sb.position = Vector3(sx, 2.92, 0)
		var cs: CollisionShape3D = CollisionShape3D.new()
		var cap: CapsuleShape3D = CapsuleShape3D.new()
		cap.radius = 0.40
		cap.height = 5.85
		cs.shape = cap
		sb.add_child(cs)
		arch.add_child(sb)
	# Curved driftwood crossbar
	var crossbar: MeshInstance3D = MeshInstance3D.new()
	var cbm: CylinderMesh = CylinderMesh.new()
	cbm.top_radius = 0.18
	cbm.bottom_radius = 0.22
	cbm.height = 5.50
	crossbar.mesh = cbm
	crossbar.material_override = weathered
	crossbar.position = Vector3(0, 5.85, 0)
	crossbar.rotation_degrees = Vector3(0, 0, 90)
	arch.add_child(crossbar)
	# Hanging fishing nets (2 large translucent meshy boxes)
	var net_mat: StandardMaterial3D = StandardMaterial3D.new()
	net_mat.albedo_color = Color(0.95, 0.85, 0.55, 0.55)
	net_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	net_mat.emission_enabled = true
	net_mat.emission = Color(0.95, 0.75, 0.30)
	net_mat.emission_energy_multiplier = 0.45
	net_mat.roughness = 0.85
	for sx in [-1.40, 1.40]:
		var net: MeshInstance3D = MeshInstance3D.new()
		var nm: BoxMesh = BoxMesh.new()
		nm.size = Vector3(1.40, 1.85, 0.10)
		net.mesh = nm
		net.material_override = net_mat
		net.position = Vector3(sx, 4.20, 0.10)
		arch.add_child(net)
	# Glowing brass sign at center
	var sign: MeshInstance3D = MeshInstance3D.new()
	var snm: BoxMesh = BoxMesh.new()
	snm.size = Vector3(2.40, 0.85, 0.10)
	sign.mesh = snm
	var sign_mat: StandardMaterial3D = StandardMaterial3D.new()
	sign_mat.albedo_color = Color(0.85, 0.65, 0.20)
	sign_mat.emission_enabled = true
	sign_mat.emission = Color(0.95, 0.65, 0.10)
	sign_mat.emission_energy_multiplier = 1.4
	sign_mat.metallic = 0.55
	sign.material_override = sign_mat
	sign.position = Vector3(0, 5.30, 0.30)
	arch.add_child(sign)
	# Light
	var light: OmniLight3D = OmniLight3D.new()
	light.light_color = Color(0.40, 0.85, 1.0)
	light.light_energy = 2.5
	light.omni_range = 8.0
	light.position = Vector3(0, 4.20, 0)
	arch.add_child(light)


static func _build_d8_great_lighthouse(geom: Node) -> void:
	## Epic-8 T3: GREAT LIGHTHOUSE landmark — towering tapered cylinder +
	## red and white striped paint + bright rotating top beacon.
	var lh: Node3D = Node3D.new()
	lh.name = "GreatLighthouse"
	lh.position = Vector3(D8_CENTER.x, 0.0, 0.0)
	geom.add_child(lh)
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.65, 0.62, 0.55)
	stone_mat.roughness = 0.85
	var white_mat: StandardMaterial3D = StandardMaterial3D.new()
	white_mat.albedo_color = Color(0.95, 0.95, 0.92)
	white_mat.roughness = 0.65
	var red_mat: StandardMaterial3D = StandardMaterial3D.new()
	red_mat.albedo_color = Color(0.85, 0.20, 0.20)
	red_mat.emission_enabled = true
	red_mat.emission = Color(0.85, 0.20, 0.20)
	red_mat.emission_energy_multiplier = 0.45
	red_mat.roughness = 0.65
	# Stone base
	var base: MeshInstance3D = MeshInstance3D.new()
	var bm: CylinderMesh = CylinderMesh.new()
	bm.top_radius = 2.20
	bm.bottom_radius = 2.85
	bm.height = 1.40
	base.mesh = bm
	base.material_override = stone_mat
	base.position = Vector3(0, 0.70, 0)
	lh.add_child(base)
	# Tall tapered tower (5 stacked sections alternating white/red stripes)
	for i in 5:
		var section: MeshInstance3D = MeshInstance3D.new()
		var sm: CylinderMesh = CylinderMesh.new()
		sm.top_radius = 1.85 - i * 0.20
		sm.bottom_radius = 2.0 - i * 0.20
		sm.height = 2.40
		section.mesh = sm
		section.material_override = white_mat if i % 2 == 0 else red_mat
		section.position = Vector3(0, 2.40 + i * 2.40, 0)
		lh.add_child(section)
	# Top dome with windows (open look-out room)
	var dome: MeshInstance3D = MeshInstance3D.new()
	var dm: SphereMesh = SphereMesh.new()
	dm.radius = 1.40
	dm.height = 1.10
	dome.mesh = dm
	dome.material_override = stone_mat
	dome.position = Vector3(0, 14.85, 0)
	lh.add_child(dome)
	# Rotating beacon (bright sphere on a pivot)
	var beacon_pivot: Node3D = Node3D.new()
	beacon_pivot.position = Vector3(0, 14.40, 0)
	lh.add_child(beacon_pivot)
	var beacon: MeshInstance3D = MeshInstance3D.new()
	var bcm: SphereMesh = SphereMesh.new()
	bcm.radius = 0.55
	bcm.height = 0.95
	beacon.mesh = bcm
	var beacon_mat: StandardMaterial3D = StandardMaterial3D.new()
	beacon_mat.albedo_color = Color(1.0, 0.95, 0.30)
	beacon_mat.emission_enabled = true
	beacon_mat.emission = Color(1.0, 0.85, 0.20)
	beacon_mat.emission_energy_multiplier = 5.0
	beacon_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	beacon.material_override = beacon_mat
	beacon.position = Vector3(0, 0, 0)
	beacon_pivot.add_child(beacon)
	# Light beam (long thin cylinder rotating with the beacon)
	var beam: MeshInstance3D = MeshInstance3D.new()
	var beam_m: CylinderMesh = CylinderMesh.new()
	beam_m.top_radius = 0.10
	beam_m.bottom_radius = 0.85
	beam_m.height = 28.0
	beam.mesh = beam_m
	var beam_mat: StandardMaterial3D = StandardMaterial3D.new()
	beam_mat.albedo_color = Color(1.0, 0.95, 0.55, 0.45)
	beam_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	beam_mat.emission_enabled = true
	beam_mat.emission = Color(1.0, 0.85, 0.30)
	beam_mat.emission_energy_multiplier = 2.0
	beam_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	beam.material_override = beam_mat
	beam.position = Vector3(14.0, 0, 0)
	beam.rotation_degrees = Vector3(0, 0, 90)
	beacon_pivot.add_child(beam)
	# Beacon rotation (sweeps around)
	var trot: Tween = beacon_pivot.create_tween().set_loops()
	trot.tween_property(beacon_pivot, "rotation_degrees:y", 360.0, 8.0)
	trot.tween_property(beacon_pivot, "rotation_degrees:y", 0.0, 0.0)
	# Massive central light
	var light: OmniLight3D = OmniLight3D.new()
	light.light_color = Color(1.0, 0.95, 0.55)
	light.light_energy = 5.5
	light.omni_range = 24.0
	light.position = Vector3(0, 14.40, 0)
	lh.add_child(light)
	# Light pulse
	var twl: Tween = light.create_tween().set_loops()
	twl.tween_property(light, "light_energy", 7.0, 1.6)
	twl.tween_property(light, "light_energy", 5.0, 1.6)
	# Tower collision (single capsule)
	var sb: StaticBody3D = StaticBody3D.new()
	sb.position = Vector3(0, 7.40, 0)
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cap: CylinderShape3D = CylinderShape3D.new()
	cap.radius = 2.40
	cap.height = 14.0
	cs.shape = cap
	sb.add_child(cs)
	lh.add_child(sb)


static func _build_d8_harbor_master_npc(town: Node) -> void:
	## Epic-8 T4: harbor master NPC — navy blue captain's coat + cap +
	## held brass spyglass.
	var npc_slots: Node3D = town.get_node_or_null("%NPCSlots") as Node3D
	if npc_slots == null:
		return
	var slot: Marker3D = Marker3D.new()
	slot.name = "HarborMasterSlot"
	slot.position = Vector3(D8_CENTER.x - 28.0, 0.0, 4.0)
	npc_slots.add_child(slot)
	var npc_scene: PackedScene = load("res://scenes/entities/npcs/VillagerR3.tscn") as PackedScene
	if npc_scene == null:
		return
	var npc: Node3D = npc_scene.instantiate() as Node3D
	npc.name = "HarborMaster"
	if "npc_name" in npc:
		npc.set("npc_name", "Tideturn")
	if "npc_id" in npc:
		npc.set("npc_id", "harbor_master_d8")
	slot.add_child(npc)
	# Navy blue captain's coat
	var coat: MeshInstance3D = MeshInstance3D.new()
	var cm: BoxMesh = BoxMesh.new()
	cm.size = Vector3(0.65, 1.20, 0.45)
	coat.mesh = cm
	var coat_mat: StandardMaterial3D = StandardMaterial3D.new()
	coat_mat.albedo_color = Color(0.10, 0.20, 0.55)
	coat_mat.metallic = 0.30
	coat_mat.roughness = 0.55
	coat.material_override = coat_mat
	coat.position = Vector3(0, 0.60, 0)
	npc.add_child(coat)
	# Captain's cap (cylinder + flat brim)
	var cap: MeshInstance3D = MeshInstance3D.new()
	var cmm: CylinderMesh = CylinderMesh.new()
	cmm.top_radius = 0.22
	cmm.bottom_radius = 0.22
	cmm.height = 0.18
	cap.mesh = cmm
	cap.material_override = coat_mat
	cap.position = Vector3(0, 1.50, 0)
	npc.add_child(cap)
	var brim: MeshInstance3D = MeshInstance3D.new()
	var brm: CylinderMesh = CylinderMesh.new()
	brm.top_radius = 0.30
	brm.bottom_radius = 0.30
	brm.height = 0.04
	brim.mesh = brm
	brim.material_override = coat_mat
	brim.position = Vector3(0, 1.42, 0.10)
	npc.add_child(brim)
	# Gold cap badge
	var badge: MeshInstance3D = MeshInstance3D.new()
	var bdm: BoxMesh = BoxMesh.new()
	bdm.size = Vector3(0.10, 0.06, 0.04)
	badge.mesh = bdm
	var gold_mat: StandardMaterial3D = StandardMaterial3D.new()
	gold_mat.albedo_color = Color(1.0, 0.85, 0.30)
	gold_mat.emission_enabled = true
	gold_mat.emission = Color(1.0, 0.75, 0.20)
	gold_mat.emission_energy_multiplier = 1.4
	gold_mat.metallic = 0.95
	badge.material_override = gold_mat
	badge.position = Vector3(0, 1.55, 0.20)
	npc.add_child(badge)
	# Brass spyglass (small cylinder)
	var spy: MeshInstance3D = MeshInstance3D.new()
	var spm: CylinderMesh = CylinderMesh.new()
	spm.top_radius = 0.05
	spm.bottom_radius = 0.06
	spm.height = 0.30
	spy.mesh = spm
	var brass_mat: StandardMaterial3D = StandardMaterial3D.new()
	brass_mat.albedo_color = Color(0.85, 0.65, 0.20)
	brass_mat.metallic = 0.95
	brass_mat.roughness = 0.30
	spy.material_override = brass_mat
	spy.position = Vector3(0.40, 0.85, 0.20)
	spy.rotation_degrees = Vector3(0, 0, 90)
	npc.add_child(spy)


static func _build_d8_fishing_boat(geom: Node) -> void:
	## Epic-8 T6: small wooden fishing boat — curved hull + cabin + mast +
	## furled sail with gentle bobbing tween.
	var boat: Node3D = Node3D.new()
	boat.name = "FishingBoat"
	boat.position = Vector3(D8_CENTER.x - 14.0, 0.30, 8.0)
	geom.add_child(boat)
	var wood_mat: StandardMaterial3D = StandardMaterial3D.new()
	wood_mat.albedo_color = Color(0.45, 0.28, 0.12)
	wood_mat.roughness = 0.85
	var dark_wood: StandardMaterial3D = StandardMaterial3D.new()
	dark_wood.albedo_color = Color(0.30, 0.18, 0.08)
	dark_wood.roughness = 0.85
	# Hull (large curved bottom box)
	var hull: MeshInstance3D = MeshInstance3D.new()
	var hm: BoxMesh = BoxMesh.new()
	hm.size = Vector3(4.20, 0.85, 1.85)
	hull.mesh = hm
	hull.material_override = wood_mat
	hull.position = Vector3(0, 0.42, 0)
	boat.add_child(hull)
	# Pointed bow (front prism)
	var bow: MeshInstance3D = MeshInstance3D.new()
	var bwm: PrismMesh = PrismMesh.new()
	bwm.size = Vector3(1.85, 0.85, 0.85)
	bow.mesh = bwm
	bow.material_override = wood_mat
	bow.position = Vector3(2.85, 0.42, 0)
	bow.rotation_degrees = Vector3(0, 0, -90)
	boat.add_child(bow)
	# Small cabin
	var cabin: MeshInstance3D = MeshInstance3D.new()
	var cm: BoxMesh = BoxMesh.new()
	cm.size = Vector3(1.40, 1.10, 1.40)
	cabin.mesh = cm
	cabin.material_override = wood_mat
	cabin.position = Vector3(-0.85, 1.30, 0)
	boat.add_child(cabin)
	# Cabin window
	var window: MeshInstance3D = MeshInstance3D.new()
	var wm: BoxMesh = BoxMesh.new()
	wm.size = Vector3(0.55, 0.40, 0.04)
	window.mesh = wm
	var window_mat: StandardMaterial3D = StandardMaterial3D.new()
	window_mat.albedo_color = Color(0.95, 0.85, 0.30)
	window_mat.emission_enabled = true
	window_mat.emission = Color(1.0, 0.85, 0.30)
	window_mat.emission_energy_multiplier = 2.0
	window_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	window.material_override = window_mat
	window.position = Vector3(-0.85, 1.55, 0.72)
	boat.add_child(window)
	# Tall mast
	var mast: MeshInstance3D = MeshInstance3D.new()
	var mm: CylinderMesh = CylinderMesh.new()
	mm.top_radius = 0.06
	mm.bottom_radius = 0.10
	mm.height = 4.20
	mast.mesh = mm
	mast.material_override = dark_wood
	mast.position = Vector3(0.55, 2.95, 0)
	boat.add_child(mast)
	# Furled sail (small wrapped white box)
	var sail: MeshInstance3D = MeshInstance3D.new()
	var sm: BoxMesh = BoxMesh.new()
	sm.size = Vector3(0.18, 1.85, 0.18)
	sail.mesh = sm
	var sail_mat: StandardMaterial3D = StandardMaterial3D.new()
	sail_mat.albedo_color = Color(0.92, 0.92, 0.85)
	sail_mat.roughness = 0.85
	sail.material_override = sail_mat
	sail.position = Vector3(0.55, 3.40, 0)
	boat.add_child(sail)
	# Bobbing tween
	var tw: Tween = boat.create_tween().set_loops()
	tw.tween_property(boat, "position:y", 0.45, 1.4)
	tw.tween_property(boat, "position:y", 0.30, 1.4)
	# Hull collision
	var sb: StaticBody3D = StaticBody3D.new()
	sb.position = Vector3(0, 0.42, 0)
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(5.50, 1.40, 1.85)
	cs.shape = cb
	sb.add_child(cs)
	boat.add_child(sb)


static func _build_d8_d8_fisherman_npc(town: Node) -> void:
	## Epic-8 T7: fisherman NPC — yellow rain coat + hat + held fishing
	## rod with line.
	var npc_slots: Node3D = town.get_node_or_null("%NPCSlots") as Node3D
	if npc_slots == null:
		return
	var slot: Marker3D = Marker3D.new()
	slot.name = "D8FishermanSlot"
	slot.position = Vector3(D8_CENTER.x - 12.0, 0.0, 8.0)
	npc_slots.add_child(slot)
	var npc_scene: PackedScene = load("res://scenes/entities/npcs/VillagerR3.tscn") as PackedScene
	if npc_scene == null:
		return
	var npc: Node3D = npc_scene.instantiate() as Node3D
	npc.name = "D8Fisherman"
	if "npc_name" in npc:
		npc.set("npc_name", "Brine")
	if "npc_id" in npc:
		npc.set("npc_id", "fisherman_d8")
	slot.add_child(npc)
	# Yellow rain coat
	var coat: MeshInstance3D = MeshInstance3D.new()
	var cm: BoxMesh = BoxMesh.new()
	cm.size = Vector3(0.65, 1.20, 0.45)
	coat.mesh = cm
	var coat_mat: StandardMaterial3D = StandardMaterial3D.new()
	coat_mat.albedo_color = Color(0.95, 0.85, 0.20)
	coat_mat.emission_enabled = true
	coat_mat.emission = Color(0.95, 0.85, 0.20)
	coat_mat.emission_energy_multiplier = 0.45
	coat_mat.roughness = 0.65
	coat.material_override = coat_mat
	coat.position = Vector3(0, 0.60, 0)
	npc.add_child(coat)
	# Yellow rain hat (wide brim disc + dome)
	var brim: MeshInstance3D = MeshInstance3D.new()
	var brm: CylinderMesh = CylinderMesh.new()
	brm.top_radius = 0.30
	brm.bottom_radius = 0.30
	brm.height = 0.04
	brim.mesh = brm
	brim.material_override = coat_mat
	brim.position = Vector3(0, 1.45, 0)
	npc.add_child(brim)
	var dome: MeshInstance3D = MeshInstance3D.new()
	var dmm: SphereMesh = SphereMesh.new()
	dmm.radius = 0.20
	dmm.height = 0.30
	dome.mesh = dmm
	dome.material_override = coat_mat
	dome.position = Vector3(0, 1.55, 0)
	dome.scale = Vector3(1.0, 0.85, 1.0)
	npc.add_child(dome)
	# Fishing rod (long thin cylinder)
	var wood_mat: StandardMaterial3D = StandardMaterial3D.new()
	wood_mat.albedo_color = Color(0.45, 0.28, 0.12)
	wood_mat.roughness = 0.85
	var rod: MeshInstance3D = MeshInstance3D.new()
	var rmm: CylinderMesh = CylinderMesh.new()
	rmm.top_radius = 0.025
	rmm.bottom_radius = 0.04
	rmm.height = 1.85
	rod.mesh = rmm
	rod.material_override = wood_mat
	rod.position = Vector3(0.65, 0.85, 0.30)
	rod.rotation_degrees = Vector3(0, 0, 65)
	npc.add_child(rod)
	# Fishing line (thin white cylinder dangling)
	var line: MeshInstance3D = MeshInstance3D.new()
	var lmm: CylinderMesh = CylinderMesh.new()
	lmm.top_radius = 0.005
	lmm.bottom_radius = 0.005
	lmm.height = 1.20
	line.mesh = lmm
	var line_mat: StandardMaterial3D = StandardMaterial3D.new()
	line_mat.albedo_color = Color(0.95, 0.95, 0.92)
	line.material_override = line_mat
	line.position = Vector3(1.65, 0.65, 0.30)
	npc.add_child(line)


static func _build_d8_fish_crates(geom: Node) -> void:
	## Epic-8 T8: 3 dock crates filled with silver fish + ice.
	var crates: Node3D = Node3D.new()
	crates.name = "FishCrates"
	crates.position = Vector3(D8_CENTER.x - 8.0, 0.0, 8.0)
	geom.add_child(crates)
	var wood_mat: StandardMaterial3D = StandardMaterial3D.new()
	wood_mat.albedo_color = Color(0.55, 0.40, 0.20)
	wood_mat.roughness = 0.92
	var fish_mat: StandardMaterial3D = StandardMaterial3D.new()
	fish_mat.albedo_color = Color(0.65, 0.75, 0.85)
	fish_mat.metallic = 0.55
	fish_mat.roughness = 0.30
	var ice_mat: StandardMaterial3D = StandardMaterial3D.new()
	ice_mat.albedo_color = Color(0.85, 0.95, 1.0, 0.65)
	ice_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	ice_mat.emission_enabled = true
	ice_mat.emission = Color(0.85, 0.95, 1.0)
	ice_mat.emission_energy_multiplier = 0.85
	for i in 3:
		var crate: Node3D = Node3D.new()
		crate.position = Vector3(i * 1.20, 0, 0)
		crates.add_child(crate)
		# Wooden crate box
		var box: MeshInstance3D = MeshInstance3D.new()
		var bm: BoxMesh = BoxMesh.new()
		bm.size = Vector3(0.95, 0.55, 0.85)
		box.mesh = bm
		box.material_override = wood_mat
		box.position = Vector3(0, 0.27, 0)
		crate.add_child(box)
		# 6 silver fish prisms inside
		for j in 6:
			var fish: MeshInstance3D = MeshInstance3D.new()
			var fm: PrismMesh = PrismMesh.new()
			fm.size = Vector3(0.22, 0.10, 0.10)
			fish.mesh = fm
			fish.material_override = fish_mat
			fish.position = Vector3(
				randf_range(-0.30, 0.30),
				0.55,
				randf_range(-0.25, 0.25)
			)
			fish.rotation_degrees = Vector3(0, randf_range(0, 360), 90)
			crate.add_child(fish)
		# Ice chips (3 small cubes)
		for j in 3:
			var ice: MeshInstance3D = MeshInstance3D.new()
			var im: BoxMesh = BoxMesh.new()
			im.size = Vector3(0.10, 0.06, 0.10)
			ice.mesh = im
			ice.material_override = ice_mat
			ice.position = Vector3(
				randf_range(-0.30, 0.30),
				0.62,
				randf_range(-0.25, 0.25)
			)
			crate.add_child(ice)
		# Crate collision
		var sb: StaticBody3D = StaticBody3D.new()
		sb.position = Vector3(0, 0.27, 0)
		var cs: CollisionShape3D = CollisionShape3D.new()
		var cb: BoxShape3D = BoxShape3D.new()
		cb.size = Vector3(0.95, 0.65, 0.85)
		cs.shape = cb
		sb.add_child(cs)
		crate.add_child(sb)


static func _build_d8_seagulls(geom: Node) -> void:
	## Epic-8 T9: 5 seagulls flying in slow circling pattern over the harbor.
	var gulls: Node3D = Node3D.new()
	gulls.name = "Seagulls"
	gulls.position = Vector3(D8_CENTER.x, 5.0, 0.0)
	geom.add_child(gulls)
	var white_mat: StandardMaterial3D = StandardMaterial3D.new()
	white_mat.albedo_color = Color(0.95, 0.95, 0.92)
	white_mat.roughness = 0.65
	var grey_mat: StandardMaterial3D = StandardMaterial3D.new()
	grey_mat.albedo_color = Color(0.55, 0.55, 0.60)
	grey_mat.roughness = 0.65
	for i in 5:
		var pivot: Node3D = Node3D.new()
		pivot.position = Vector3(0, i * 0.55, 0)
		pivot.rotation_degrees = Vector3(0, i * 72.0, 0)
		gulls.add_child(pivot)
		var gull: Node3D = Node3D.new()
		gull.position = Vector3(8.0 + i * 0.95, 0, 0)
		pivot.add_child(gull)
		# White body
		var body: MeshInstance3D = MeshInstance3D.new()
		var bm: SphereMesh = SphereMesh.new()
		bm.radius = 0.16
		bm.height = 0.28
		body.mesh = bm
		body.material_override = white_mat
		body.scale = Vector3(0.85, 0.85, 1.30)
		gull.add_child(body)
		# Grey wings
		for sx in [-0.40, 0.40]:
			var wing: MeshInstance3D = MeshInstance3D.new()
			var wm: BoxMesh = BoxMesh.new()
			wm.size = Vector3(0.55, 0.04, 0.18)
			wing.mesh = wm
			wing.material_override = grey_mat
			wing.position = Vector3(sx, 0.04, 0)
			gull.add_child(wing)
			# Wing flap tween
			var twf: Tween = wing.create_tween().set_loops()
			twf.tween_property(wing, "rotation_degrees:z", 18.0 if sx < 0 else -18.0, 0.30)
			twf.tween_property(wing, "rotation_degrees:z", 0.0, 0.30)
		# Yellow beak
		var beak: MeshInstance3D = MeshInstance3D.new()
		var bkm: PrismMesh = PrismMesh.new()
		bkm.size = Vector3(0.04, 0.04, 0.10)
		beak.mesh = bkm
		var beak_mat: StandardMaterial3D = StandardMaterial3D.new()
		beak_mat.albedo_color = Color(0.95, 0.85, 0.20)
		beak.material_override = beak_mat
		beak.position = Vector3(0, 0.04, 0.18)
		beak.rotation_degrees = Vector3(90, 0, 0)
		gull.add_child(beak)
		# Pivot rotation tween
		var trot: Tween = pivot.create_tween().set_loops()
		trot.tween_property(pivot, "rotation_degrees:y", i * 72.0 + 360.0, 12.0 + i * 0.6)
		trot.tween_property(pivot, "rotation_degrees:y", i * 72.0, 0.0)


static func _build_d8_sea_spray(geom: Node) -> void:
	## Epic-8 T10: ambient sea spray particles drifting up from the water.
	var spray: GPUParticles3D = GPUParticles3D.new()
	spray.name = "SeaSpray"
	spray.position = Vector3(D8_CENTER.x, 0.5, 0.0)
	spray.amount = 80
	spray.lifetime = 4.0
	spray.preprocess = 2.0
	spray.explosiveness = 0.0
	spray.randomness = 0.7
	spray.visibility_aabb = AABB(Vector3(-40, -2, -25), Vector3(80, 12, 50))
	var pm: ParticleProcessMaterial = ParticleProcessMaterial.new()
	pm.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	pm.emission_box_extents = Vector3(35, 0.5, 22)
	pm.direction = Vector3(0.20, 1, 0.10)
	pm.spread = 30.0
	pm.gravity = Vector3(0.10, 0.45, 0.05)
	pm.initial_velocity_min = 0.55
	pm.initial_velocity_max = 1.20
	pm.scale_min = 0.06
	pm.scale_max = 0.14
	pm.color = Color(0.85, 0.95, 1.0, 0.65)
	spray.process_material = pm
	# Spray mesh
	var spray_mesh: SphereMesh = SphereMesh.new()
	spray_mesh.radius = 0.06
	spray_mesh.height = 0.12
	spray.draw_pass_1 = spray_mesh
	var spray_mat: StandardMaterial3D = StandardMaterial3D.new()
	spray_mat.albedo_color = Color(0.85, 0.95, 1.0)
	spray_mat.emission_enabled = true
	spray_mat.emission = Color(0.65, 0.85, 1.0)
	spray_mat.emission_energy_multiplier = 1.4
	spray_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	spray_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	spray_mesh.material = spray_mat
	geom.add_child(spray)


static func _build_d8_shipwreck(geom: Node) -> void:
	## Epic-8 T11: shipwreck remnants — broken hull half-sunken + tilted
	## mast + scattered planks + green seaweed.
	var wreck: Node3D = Node3D.new()
	wreck.name = "Shipwreck"
	wreck.position = Vector3(D8_CENTER.x + 14.0, 0.0, -16.0)
	geom.add_child(wreck)
	var dark_wood: StandardMaterial3D = StandardMaterial3D.new()
	dark_wood.albedo_color = Color(0.30, 0.18, 0.08)
	dark_wood.roughness = 0.92
	var algae_mat: StandardMaterial3D = StandardMaterial3D.new()
	algae_mat.albedo_color = Color(0.20, 0.55, 0.30)
	algae_mat.emission_enabled = true
	algae_mat.emission = Color(0.20, 0.65, 0.30)
	algae_mat.emission_energy_multiplier = 0.45
	algae_mat.roughness = 0.85
	# Tilted broken hull (large angled box)
	var hull: MeshInstance3D = MeshInstance3D.new()
	var hm: BoxMesh = BoxMesh.new()
	hm.size = Vector3(5.50, 1.85, 2.40)
	hull.mesh = hm
	hull.material_override = dark_wood
	hull.position = Vector3(0, 0.85, 0)
	hull.rotation_degrees = Vector3(0, 0, 25)
	wreck.add_child(hull)
	# Tilted broken mast
	var mast: MeshInstance3D = MeshInstance3D.new()
	var mm: CylinderMesh = CylinderMesh.new()
	mm.top_radius = 0.10
	mm.bottom_radius = 0.18
	mm.height = 4.20
	mast.mesh = mm
	mast.material_override = dark_wood
	mast.position = Vector3(1.85, 2.85, 0)
	mast.rotation_degrees = Vector3(0, 0, 65)
	wreck.add_child(mast)
	# 4 scattered planks
	for i in 4:
		var plank: MeshInstance3D = MeshInstance3D.new()
		var pm: BoxMesh = BoxMesh.new()
		pm.size = Vector3(1.40, 0.10, 0.30)
		plank.mesh = pm
		plank.material_override = dark_wood
		plank.position = Vector3(
			randf_range(-2.85, 2.85),
			0.18,
			randf_range(-1.85, 1.85)
		)
		plank.rotation_degrees = Vector3(0, randf_range(0, 360), 0)
		wreck.add_child(plank)
	# 5 algae clumps growing on the wreck
	for i in 5:
		var algae: MeshInstance3D = MeshInstance3D.new()
		var am: SphereMesh = SphereMesh.new()
		am.radius = 0.30
		am.height = 0.45
		algae.mesh = am
		algae.material_override = algae_mat
		algae.position = Vector3(
			randf_range(-2.0, 2.0),
			0.85 + randf_range(0, 0.85),
			randf_range(-1.0, 1.0)
		)
		algae.scale = Vector3(1.0, 0.55, 1.0)
		wreck.add_child(algae)
	# Hull collision
	var sb: StaticBody3D = StaticBody3D.new()
	sb.position = Vector3(0, 0.85, 0)
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(5.50, 1.85, 2.40)
	cs.shape = cb
	sb.add_child(cs)
	wreck.add_child(sb)


static func _build_d8_sailor_npc(town: Node) -> void:
	## Epic-8 T12: sailor NPC — striped shirt + red bandana + held bottle.
	var npc_slots: Node3D = town.get_node_or_null("%NPCSlots") as Node3D
	if npc_slots == null:
		return
	var slot: Marker3D = Marker3D.new()
	slot.name = "SailorSlot"
	slot.position = Vector3(D8_CENTER.x - 4.0, 0.0, 8.0)
	npc_slots.add_child(slot)
	var npc_scene: PackedScene = load("res://scenes/entities/npcs/VillagerR3.tscn") as PackedScene
	if npc_scene == null:
		return
	var npc: Node3D = npc_scene.instantiate() as Node3D
	npc.name = "Sailor"
	if "npc_name" in npc:
		npc.set("npc_name", "Saltwake")
	if "npc_id" in npc:
		npc.set("npc_id", "sailor_d8")
	slot.add_child(npc)
	# Blue striped shirt
	var shirt: MeshInstance3D = MeshInstance3D.new()
	var sm: BoxMesh = BoxMesh.new()
	sm.size = Vector3(0.65, 1.05, 0.40)
	shirt.mesh = sm
	var shirt_mat: StandardMaterial3D = StandardMaterial3D.new()
	shirt_mat.albedo_color = Color(0.20, 0.30, 0.55)
	shirt_mat.emission_enabled = true
	shirt_mat.emission = Color(0.20, 0.30, 0.55)
	shirt_mat.emission_energy_multiplier = 0.30
	shirt.material_override = shirt_mat
	shirt.position = Vector3(0, 0.55, 0)
	npc.add_child(shirt)
	# 3 white horizontal stripes on the shirt
	var stripe_mat: StandardMaterial3D = StandardMaterial3D.new()
	stripe_mat.albedo_color = Color(0.95, 0.95, 0.92)
	for sy in [0.40, 0.55, 0.70]:
		var stripe: MeshInstance3D = MeshInstance3D.new()
		var stm: BoxMesh = BoxMesh.new()
		stm.size = Vector3(0.65, 0.06, 0.06)
		stripe.mesh = stm
		stripe.material_override = stripe_mat
		stripe.position = Vector3(0, sy, 0.21)
		npc.add_child(stripe)
	# Red bandana
	var bandana: MeshInstance3D = MeshInstance3D.new()
	var bm: CylinderMesh = CylinderMesh.new()
	bm.top_radius = 0.22
	bm.bottom_radius = 0.22
	bm.height = 0.08
	bandana.mesh = bm
	var bandana_mat: StandardMaterial3D = StandardMaterial3D.new()
	bandana_mat.albedo_color = Color(0.85, 0.20, 0.20)
	bandana_mat.emission_enabled = true
	bandana_mat.emission = Color(0.85, 0.20, 0.20)
	bandana_mat.emission_energy_multiplier = 0.85
	bandana.material_override = bandana_mat
	bandana.position = Vector3(0, 1.45, 0)
	npc.add_child(bandana)
	# Held bottle
	var bottle: MeshInstance3D = MeshInstance3D.new()
	var btm: CylinderMesh = CylinderMesh.new()
	btm.top_radius = 0.05
	btm.bottom_radius = 0.06
	btm.height = 0.30
	bottle.mesh = btm
	var bottle_mat: StandardMaterial3D = StandardMaterial3D.new()
	bottle_mat.albedo_color = Color(0.20, 0.55, 0.20, 0.65)
	bottle_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	bottle_mat.emission_enabled = true
	bottle_mat.emission = Color(0.20, 0.65, 0.20)
	bottle_mat.emission_energy_multiplier = 0.65
	bottle_mat.metallic = 0.65
	bottle_mat.roughness = 0.10
	bottle.material_override = bottle_mat
	bottle.position = Vector3(0.40, 0.85, 0.20)
	npc.add_child(bottle)


static func _build_d8_giant_anchor(geom: Node) -> void:
	## Epic-8 T13: giant dock anchor — large dark metal anchor leaning
	## against the boardwalk.
	var anchor: Node3D = Node3D.new()
	anchor.name = "GiantAnchor"
	anchor.position = Vector3(D8_CENTER.x - 22.0, 0.0, -8.0)
	geom.add_child(anchor)
	var iron_mat: StandardMaterial3D = StandardMaterial3D.new()
	iron_mat.albedo_color = Color(0.20, 0.20, 0.25)
	iron_mat.metallic = 0.85
	iron_mat.roughness = 0.40
	# Vertical shaft
	var shaft: MeshInstance3D = MeshInstance3D.new()
	var sm: CylinderMesh = CylinderMesh.new()
	sm.top_radius = 0.12
	sm.bottom_radius = 0.18
	sm.height = 2.40
	shaft.mesh = sm
	shaft.material_override = iron_mat
	shaft.position = Vector3(0, 1.20, 0)
	shaft.rotation_degrees = Vector3(0, 0, 25)
	anchor.add_child(shaft)
	# Top ring (torus)
	var ring: MeshInstance3D = MeshInstance3D.new()
	var rm: TorusMesh = TorusMesh.new()
	rm.inner_radius = 0.18
	rm.outer_radius = 0.30
	ring.mesh = rm
	ring.material_override = iron_mat
	ring.position = Vector3(0.45, 2.40, 0)
	anchor.add_child(ring)
	# Crossbar (perpendicular at top of shaft)
	var cross: MeshInstance3D = MeshInstance3D.new()
	var cm: CylinderMesh = CylinderMesh.new()
	cm.top_radius = 0.08
	cm.bottom_radius = 0.08
	cm.height = 1.40
	cross.mesh = cm
	cross.material_override = iron_mat
	cross.position = Vector3(0.30, 1.85, 0)
	cross.rotation_degrees = Vector3(0, 0, 90)
	anchor.add_child(cross)
	# Left + right anchor flukes (curved boxes at base)
	for sx in [-0.55, 0.55]:
		var fluke: MeshInstance3D = MeshInstance3D.new()
		var fm: PrismMesh = PrismMesh.new()
		fm.size = Vector3(0.18, 0.85, 0.18)
		fluke.mesh = fm
		fluke.material_override = iron_mat
		fluke.position = Vector3(sx, 0.35, 0)
		fluke.rotation_degrees = Vector3(0, 0, sx * 90.0)
		anchor.add_child(fluke)
	# Anchor collision
	var sb: StaticBody3D = StaticBody3D.new()
	sb.position = Vector3(0, 1.20, 0)
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(1.85, 2.40, 0.55)
	cs.shape = cb
	sb.add_child(cs)
	anchor.add_child(sb)


static func _build_d8_pilings_row(geom: Node) -> void:
	## Epic-8 T14: row of 8 wooden dock pilings rising from the water,
	## marking the edge of a long dock.
	var pilings: Node3D = Node3D.new()
	pilings.name = "PilingsRow"
	pilings.position = Vector3(D8_CENTER.x, 0.0, 18.0)
	geom.add_child(pilings)
	var wood_mat: StandardMaterial3D = StandardMaterial3D.new()
	wood_mat.albedo_color = Color(0.40, 0.25, 0.10)
	wood_mat.roughness = 0.92
	var algae_mat: StandardMaterial3D = StandardMaterial3D.new()
	algae_mat.albedo_color = Color(0.20, 0.55, 0.30)
	algae_mat.emission_enabled = true
	algae_mat.emission = Color(0.20, 0.65, 0.30)
	algae_mat.emission_energy_multiplier = 0.45
	for i in 8:
		var piling: Node3D = Node3D.new()
		piling.position = Vector3(-12.0 + i * 3.40, 0, 0)
		pilings.add_child(piling)
		# Tall thick wooden piling
		var post: MeshInstance3D = MeshInstance3D.new()
		var pm: CylinderMesh = CylinderMesh.new()
		pm.top_radius = 0.22
		pm.bottom_radius = 0.30
		pm.height = 2.85
		post.mesh = pm
		post.material_override = wood_mat
		post.position = Vector3(0, 1.42, 0)
		piling.add_child(post)
		# Algae growth at the base (waterline)
		var algae: MeshInstance3D = MeshInstance3D.new()
		var am: CylinderMesh = CylinderMesh.new()
		am.top_radius = 0.30
		am.bottom_radius = 0.30
		am.height = 0.30
		algae.mesh = am
		algae.material_override = algae_mat
		algae.position = Vector3(0, 0.40, 0)
		piling.add_child(algae)
		# Top cap (small disc)
		var cap: MeshInstance3D = MeshInstance3D.new()
		var cmm: CylinderMesh = CylinderMesh.new()
		cmm.top_radius = 0.30
		cmm.bottom_radius = 0.30
		cmm.height = 0.08
		cap.mesh = cmm
		var cap_mat: StandardMaterial3D = StandardMaterial3D.new()
		cap_mat.albedo_color = Color(0.30, 0.18, 0.08)
		cap.material_override = cap_mat
		cap.position = Vector3(0, 2.85, 0)
		piling.add_child(cap)
		# Piling collision
		var sb: StaticBody3D = StaticBody3D.new()
		sb.position = Vector3(0, 1.42, 0)
		var cs: CollisionShape3D = CollisionShape3D.new()
		var capsh: CapsuleShape3D = CapsuleShape3D.new()
		capsh.radius = 0.30
		capsh.height = 2.85
		cs.shape = capsh
		sb.add_child(cs)
		piling.add_child(sb)


static func _build_d8_dolphins(geom: Node) -> void:
	## Epic-8 T15: 3 dolphins jumping out of the water in slow arcs.
	var dolphins: Node3D = Node3D.new()
	dolphins.name = "Dolphins"
	dolphins.position = Vector3(D8_CENTER.x + 8.0, 0.0, 14.0)
	geom.add_child(dolphins)
	var grey_mat: StandardMaterial3D = StandardMaterial3D.new()
	grey_mat.albedo_color = Color(0.40, 0.50, 0.60)
	grey_mat.metallic = 0.30
	grey_mat.roughness = 0.55
	var positions: Array = [
		Vector3( 0.0, 0,  0.0),
		Vector3( 3.40, 0,  1.40),
		Vector3(-2.85, 0,  0.85),
	]
	for i in positions.size():
		var dolphin: Node3D = Node3D.new()
		dolphin.position = positions[i]
		dolphins.add_child(dolphin)
		# Body (long sphere)
		var body: MeshInstance3D = MeshInstance3D.new()
		var bm: SphereMesh = SphereMesh.new()
		bm.radius = 0.30
		bm.height = 0.55
		body.mesh = bm
		body.material_override = grey_mat
		body.scale = Vector3(0.85, 0.65, 1.85)
		dolphin.add_child(body)
		# Snout (small prism)
		var snout: MeshInstance3D = MeshInstance3D.new()
		var snm: PrismMesh = PrismMesh.new()
		snm.size = Vector3(0.12, 0.10, 0.30)
		snout.mesh = snm
		snout.material_override = grey_mat
		snout.position = Vector3(0, 0.04, 0.55)
		dolphin.add_child(snout)
		# Dorsal fin
		var fin: MeshInstance3D = MeshInstance3D.new()
		var fmm: PrismMesh = PrismMesh.new()
		fmm.size = Vector3(0.04, 0.30, 0.20)
		fin.mesh = fmm
		fin.material_override = grey_mat
		fin.position = Vector3(0, 0.40, 0)
		dolphin.add_child(fin)
		# Tail flukes
		var tail: MeshInstance3D = MeshInstance3D.new()
		var tm: BoxMesh = BoxMesh.new()
		tm.size = Vector3(0.30, 0.04, 0.18)
		tail.mesh = tm
		tail.material_override = grey_mat
		tail.position = Vector3(0, 0, -0.55)
		dolphin.add_child(tail)
		# Jumping arc tween — rises and falls
		var tw: Tween = dolphin.create_tween().set_loops()
		tw.tween_interval(i * 0.85)
		tw.tween_property(dolphin, "position:y", 1.85, 0.85)
		tw.tween_property(dolphin, "rotation_degrees:x", -25.0, 0.55)
		tw.tween_property(dolphin, "position:y", 0.20, 0.85)
		tw.tween_property(dolphin, "rotation_degrees:x", 0.0, 0.55)
		tw.tween_interval(2.0)


static func _build_d8_tavern(geom: Node) -> void:
	## Epic-8 T16: harbor tavern — wooden building with sloped roof + 2
	## glowing windows + hanging signboard.
	var tavern: Node3D = Node3D.new()
	tavern.name = "HarborTavern"
	tavern.position = Vector3(D8_CENTER.x - 22.0, 0.0, 14.0)
	geom.add_child(tavern)
	var wood_mat: StandardMaterial3D = StandardMaterial3D.new()
	wood_mat.albedo_color = Color(0.45, 0.28, 0.12)
	wood_mat.roughness = 0.85
	var dark_wood: StandardMaterial3D = StandardMaterial3D.new()
	dark_wood.albedo_color = Color(0.30, 0.18, 0.08)
	dark_wood.roughness = 0.85
	# Building body
	var body: MeshInstance3D = MeshInstance3D.new()
	var bm: BoxMesh = BoxMesh.new()
	bm.size = Vector3(5.50, 3.40, 4.20)
	body.mesh = bm
	body.material_override = wood_mat
	body.position = Vector3(0, 1.70, 0)
	tavern.add_child(body)
	# Sloped prism roof
	var roof: MeshInstance3D = MeshInstance3D.new()
	var rm: PrismMesh = PrismMesh.new()
	rm.size = Vector3(6.0, 1.40, 4.50)
	roof.mesh = rm
	roof.material_override = dark_wood
	roof.position = Vector3(0, 4.10, 0)
	tavern.add_child(roof)
	# 2 glowing windows
	var window_mat: StandardMaterial3D = StandardMaterial3D.new()
	window_mat.albedo_color = Color(1.0, 0.85, 0.30)
	window_mat.emission_enabled = true
	window_mat.emission = Color(1.0, 0.75, 0.20)
	window_mat.emission_energy_multiplier = 2.5
	window_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for sx in [-1.40, 1.40]:
		var win: MeshInstance3D = MeshInstance3D.new()
		var wm: BoxMesh = BoxMesh.new()
		wm.size = Vector3(0.85, 0.85, 0.06)
		win.mesh = wm
		win.material_override = window_mat
		win.position = Vector3(sx, 2.20, 2.13)
		tavern.add_child(win)
	# Door
	var door: MeshInstance3D = MeshInstance3D.new()
	var dm: BoxMesh = BoxMesh.new()
	dm.size = Vector3(0.95, 1.85, 0.10)
	door.mesh = dm
	door.material_override = dark_wood
	door.position = Vector3(0, 1.0, 2.15)
	tavern.add_child(door)
	# Hanging signboard
	var sign: MeshInstance3D = MeshInstance3D.new()
	var snm: BoxMesh = BoxMesh.new()
	snm.size = Vector3(1.85, 0.85, 0.10)
	sign.mesh = snm
	var sign_mat: StandardMaterial3D = StandardMaterial3D.new()
	sign_mat.albedo_color = Color(0.85, 0.65, 0.20)
	sign_mat.emission_enabled = true
	sign_mat.emission = Color(0.85, 0.55, 0.10)
	sign_mat.emission_energy_multiplier = 1.4
	sign.material_override = sign_mat
	sign.position = Vector3(0, 3.40, 2.40)
	tavern.add_child(sign)
	# Sign chain
	for sx in [-0.55, 0.55]:
		var chain: MeshInstance3D = MeshInstance3D.new()
		var cmm: CylinderMesh = CylinderMesh.new()
		cmm.top_radius = 0.018
		cmm.bottom_radius = 0.018
		cmm.height = 0.45
		chain.mesh = cmm
		chain.material_override = dark_wood
		chain.position = Vector3(sx, 3.85, 2.40)
		tavern.add_child(chain)
	# Warm interior light
	var light: OmniLight3D = OmniLight3D.new()
	light.light_color = Color(1.0, 0.75, 0.30)
	light.light_energy = 2.5
	light.omni_range = 6.0
	light.position = Vector3(0, 2.20, 1.20)
	tavern.add_child(light)
	# Tavern collision
	var sb: StaticBody3D = StaticBody3D.new()
	sb.position = Vector3(0, 1.70, 0)
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(5.50, 3.40, 4.20)
	cs.shape = cb
	sb.add_child(cs)
	tavern.add_child(sb)


static func _build_d8_tavern_keeper_npc(town: Node) -> void:
	## Epic-8 T17: tavern keeper NPC — apron + held tankard with foam.
	var npc_slots: Node3D = town.get_node_or_null("%NPCSlots") as Node3D
	if npc_slots == null:
		return
	var slot: Marker3D = Marker3D.new()
	slot.name = "TavernKeeperSlot"
	slot.position = Vector3(D8_CENTER.x - 22.0, 0.0, 16.0)
	npc_slots.add_child(slot)
	var npc_scene: PackedScene = load("res://scenes/entities/npcs/VillagerR3.tscn") as PackedScene
	if npc_scene == null:
		return
	var npc: Node3D = npc_scene.instantiate() as Node3D
	npc.name = "TavernKeeper"
	if "npc_name" in npc:
		npc.set("npc_name", "Barnacle")
	if "npc_id" in npc:
		npc.set("npc_id", "tavern_keeper_d8")
	slot.add_child(npc)
	# Brown apron
	var apron: MeshInstance3D = MeshInstance3D.new()
	var am: BoxMesh = BoxMesh.new()
	am.size = Vector3(0.55, 0.85, 0.06)
	apron.mesh = am
	var apron_mat: StandardMaterial3D = StandardMaterial3D.new()
	apron_mat.albedo_color = Color(0.55, 0.40, 0.20)
	apron_mat.roughness = 0.85
	apron.material_override = apron_mat
	apron.position = Vector3(0, 0.55, 0.22)
	npc.add_child(apron)
	# Tankard (small cylinder)
	var tankard: MeshInstance3D = MeshInstance3D.new()
	var tm: CylinderMesh = CylinderMesh.new()
	tm.top_radius = 0.10
	tm.bottom_radius = 0.10
	tm.height = 0.20
	tankard.mesh = tm
	var tankard_mat: StandardMaterial3D = StandardMaterial3D.new()
	tankard_mat.albedo_color = Color(0.40, 0.30, 0.15)
	tankard_mat.metallic = 0.65
	tankard_mat.roughness = 0.30
	tankard.material_override = tankard_mat
	tankard.position = Vector3(0.40, 0.85, 0.20)
	npc.add_child(tankard)
	# Foam (small white sphere on top)
	var foam: MeshInstance3D = MeshInstance3D.new()
	var fm: SphereMesh = SphereMesh.new()
	fm.radius = 0.10
	fm.height = 0.10
	foam.mesh = fm
	var foam_mat: StandardMaterial3D = StandardMaterial3D.new()
	foam_mat.albedo_color = Color(0.95, 0.92, 0.85)
	foam_mat.emission_enabled = true
	foam_mat.emission = Color(0.95, 0.92, 0.85)
	foam_mat.emission_energy_multiplier = 0.45
	foam_mat.roughness = 0.85
	foam.material_override = foam_mat
	foam.position = Vector3(0.40, 0.97, 0.20)
	foam.scale = Vector3(1.0, 0.55, 1.0)
	npc.add_child(foam)


static func _build_d8_barrel_stack(geom: Node) -> void:
	## Epic-8 T18: stack of 6 wooden barrels — 3 base + 2 middle + 1 top.
	var stack: Node3D = Node3D.new()
	stack.name = "BarrelStack"
	stack.position = Vector3(D8_CENTER.x - 18.0, 0.0, 14.0)
	geom.add_child(stack)
	var wood_mat: StandardMaterial3D = StandardMaterial3D.new()
	wood_mat.albedo_color = Color(0.45, 0.28, 0.12)
	wood_mat.roughness = 0.92
	var hoop_mat: StandardMaterial3D = StandardMaterial3D.new()
	hoop_mat.albedo_color = Color(0.20, 0.18, 0.20)
	hoop_mat.metallic = 0.85
	hoop_mat.roughness = 0.40
	var positions: Array = [
		Vector3(-0.55, 0.42, 0),
		Vector3( 0.55, 0.42, 0),
		Vector3( 0.0,  0.42, 0.85),
		Vector3(-0.30, 1.30, 0.40),
		Vector3( 0.30, 1.30, 0.40),
		Vector3( 0.0,  2.20, 0.40),
	]
	for p in positions:
		var barrel: MeshInstance3D = MeshInstance3D.new()
		var bm: CylinderMesh = CylinderMesh.new()
		bm.top_radius = 0.30
		bm.bottom_radius = 0.30
		bm.height = 0.85
		barrel.mesh = bm
		barrel.material_override = wood_mat
		barrel.position = p
		stack.add_child(barrel)
		# 2 metal hoops on each barrel
		for hy in [-0.30, 0.30]:
			var hoop: MeshInstance3D = MeshInstance3D.new()
			var hmm: CylinderMesh = CylinderMesh.new()
			hmm.top_radius = 0.32
			hmm.bottom_radius = 0.32
			hmm.height = 0.04
			hoop.mesh = hmm
			hoop.material_override = hoop_mat
			hoop.position = Vector3(p.x, p.y + hy, p.z)
			stack.add_child(hoop)
	# Group collision (single box)
	var sb: StaticBody3D = StaticBody3D.new()
	sb.position = Vector3(0, 1.30, 0.30)
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(1.40, 2.85, 1.40)
	cs.shape = cb
	sb.add_child(cs)
	stack.add_child(sb)


static func _build_d8_rope_coils(geom: Node) -> void:
	## Epic-8 T19: 3 large coiled ropes on the dock — concentric torus rings.
	var coils: Node3D = Node3D.new()
	coils.name = "RopeCoils"
	coils.position = Vector3(D8_CENTER.x + 4.0, 0.0, 18.0)
	geom.add_child(coils)
	var rope_mat: StandardMaterial3D = StandardMaterial3D.new()
	rope_mat.albedo_color = Color(0.55, 0.40, 0.20)
	rope_mat.roughness = 0.85
	for i in 3:
		var coil: Node3D = Node3D.new()
		coil.position = Vector3(i * 1.40, 0, 0)
		coils.add_child(coil)
		# 4 concentric torus rings forming a coiled rope
		for j in 4:
			var ring: MeshInstance3D = MeshInstance3D.new()
			var rm: TorusMesh = TorusMesh.new()
			rm.inner_radius = 0.30 - j * 0.05
			rm.outer_radius = 0.40 - j * 0.05
			ring.mesh = rm
			ring.material_override = rope_mat
			ring.position = Vector3(0, 0.18 + j * 0.10, 0)
			coil.add_child(ring)


static func _build_d8_lantern_posts(geom: Node) -> void:
	## Epic-8 T20: row of 6 dock lantern posts — wooden pole + hanging
	## warm yellow glass lantern.
	var row: Node3D = Node3D.new()
	row.name = "LanternPosts"
	row.position = Vector3(D8_CENTER.x - 14.0, 0.0, -2.0)
	geom.add_child(row)
	var wood_mat: StandardMaterial3D = StandardMaterial3D.new()
	wood_mat.albedo_color = Color(0.45, 0.28, 0.12)
	wood_mat.roughness = 0.85
	var glass_mat: StandardMaterial3D = StandardMaterial3D.new()
	glass_mat.albedo_color = Color(1.0, 0.85, 0.30, 0.85)
	glass_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	glass_mat.emission_enabled = true
	glass_mat.emission = Color(1.0, 0.75, 0.20)
	glass_mat.emission_energy_multiplier = 2.5
	for i in 6:
		var lamp: Node3D = Node3D.new()
		lamp.position = Vector3(i * 2.20, 0, 0)
		row.add_child(lamp)
		# Wooden post
		var post: MeshInstance3D = MeshInstance3D.new()
		var pmm: CylinderMesh = CylinderMesh.new()
		pmm.top_radius = 0.08
		pmm.bottom_radius = 0.10
		pmm.height = 2.85
		post.mesh = pmm
		post.material_override = wood_mat
		post.position = Vector3(0, 1.42, 0)
		lamp.add_child(post)
		# Top arm
		var arm: MeshInstance3D = MeshInstance3D.new()
		var am: CylinderMesh = CylinderMesh.new()
		am.top_radius = 0.05
		am.bottom_radius = 0.05
		am.height = 0.40
		arm.mesh = am
		arm.material_override = wood_mat
		arm.position = Vector3(0.20, 2.85, 0)
		arm.rotation_degrees = Vector3(0, 0, 90)
		lamp.add_child(arm)
		# Hanging glass lantern (sphere)
		var lantern: MeshInstance3D = MeshInstance3D.new()
		var lm: SphereMesh = SphereMesh.new()
		lm.radius = 0.18
		lm.height = 0.32
		lantern.mesh = lm
		lantern.material_override = glass_mat
		lantern.position = Vector3(0.40, 2.65, 0)
		lamp.add_child(lantern)
		# Light
		var light: OmniLight3D = OmniLight3D.new()
		light.light_color = Color(1.0, 0.75, 0.30)
		light.light_energy = 1.4
		light.omni_range = 3.5
		light.position = Vector3(0.40, 2.65, 0)
		lamp.add_child(light)
		# Subtle pulse offset
		var tw: Tween = light.create_tween().set_loops()
		tw.tween_interval(i * 0.18)
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


static func _build_d8_clam_digger_npc(town: Node) -> void:
	## Epic-8 T21: clam digger NPC — rolled-up trousers + held bucket and
	## small spade.
	var npc_slots: Node3D = town.get_node_or_null("%NPCSlots") as Node3D
	if npc_slots == null:
		return
	var slot: Marker3D = Marker3D.new()
	slot.name = "ClamDiggerSlot"
	slot.position = Vector3(D8_CENTER.x + 4.0, 0.0, -8.0)
	npc_slots.add_child(slot)
	var npc_scene: PackedScene = load("res://scenes/entities/npcs/VillagerR3.tscn") as PackedScene
	if npc_scene == null:
		return
	var npc: Node3D = npc_scene.instantiate() as Node3D
	npc.name = "ClamDigger"
	if "npc_name" in npc:
		npc.set("npc_name", "Mudfoot")
	if "npc_id" in npc:
		npc.set("npc_id", "clam_digger_d8")
	slot.add_child(npc)
	# Tan rolled-up shirt
	var shirt: MeshInstance3D = MeshInstance3D.new()
	var sm: BoxMesh = BoxMesh.new()
	sm.size = Vector3(0.65, 0.85, 0.40)
	shirt.mesh = sm
	var shirt_mat: StandardMaterial3D = StandardMaterial3D.new()
	shirt_mat.albedo_color = Color(0.85, 0.75, 0.45)
	shirt_mat.roughness = 0.85
	shirt.material_override = shirt_mat
	shirt.position = Vector3(0, 0.65, 0)
	npc.add_child(shirt)
	# Bucket
	var bucket: MeshInstance3D = MeshInstance3D.new()
	var bm: CylinderMesh = CylinderMesh.new()
	bm.top_radius = 0.18
	bm.bottom_radius = 0.14
	bm.height = 0.30
	bucket.mesh = bm
	var bucket_mat: StandardMaterial3D = StandardMaterial3D.new()
	bucket_mat.albedo_color = Color(0.40, 0.30, 0.15)
	bucket_mat.roughness = 0.85
	bucket.material_override = bucket_mat
	bucket.position = Vector3(0.40, 0.85, 0.20)
	npc.add_child(bucket)
	# Small spade (handle + blade)
	var wood_mat: StandardMaterial3D = StandardMaterial3D.new()
	wood_mat.albedo_color = Color(0.45, 0.28, 0.12)
	wood_mat.roughness = 0.85
	var handle: MeshInstance3D = MeshInstance3D.new()
	var hm: CylinderMesh = CylinderMesh.new()
	hm.top_radius = 0.025
	hm.bottom_radius = 0.025
	hm.height = 0.55
	handle.mesh = hm
	handle.material_override = wood_mat
	handle.position = Vector3(0.65, 0.85, 0.20)
	npc.add_child(handle)
	var blade: MeshInstance3D = MeshInstance3D.new()
	var blm: BoxMesh = BoxMesh.new()
	blm.size = Vector3(0.10, 0.18, 0.04)
	blade.mesh = blm
	var blade_mat: StandardMaterial3D = StandardMaterial3D.new()
	blade_mat.albedo_color = Color(0.85, 0.92, 1.0)
	blade_mat.metallic = 0.95
	blade_mat.roughness = 0.05
	blade.material_override = blade_mat
	blade.position = Vector3(0.65, 1.20, 0.20)
	npc.add_child(blade)


static func _build_d8_tide_pools(geom: Node) -> void:
	## Epic-8 T22: 4 small tide pools — round shallow pools of water
	## with stone rims at varying positions on the dock.
	var pools: Node3D = Node3D.new()
	pools.name = "TidePools"
	pools.position = Vector3(D8_CENTER.x + 14.0, 0.0, 8.0)
	geom.add_child(pools)
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.45, 0.40, 0.35)
	stone_mat.roughness = 0.92
	var water_mat: StandardMaterial3D = StandardMaterial3D.new()
	water_mat.albedo_color = Color(0.30, 0.65, 0.85, 0.85)
	water_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	water_mat.emission_enabled = true
	water_mat.emission = Color(0.30, 0.85, 1.0)
	water_mat.emission_energy_multiplier = 0.85
	water_mat.metallic = 0.30
	water_mat.roughness = 0.05
	for i in 4:
		var pool: Node3D = Node3D.new()
		pool.position = Vector3(
			randf_range(-3.5, 3.5),
			0,
			randf_range(-2.5, 2.5)
		)
		pools.add_child(pool)
		# Stone rim (small torus)
		var rim: MeshInstance3D = MeshInstance3D.new()
		var rm: TorusMesh = TorusMesh.new()
		rm.inner_radius = 0.55
		rm.outer_radius = 0.75
		rim.mesh = rm
		rim.material_override = stone_mat
		rim.position = Vector3(0, 0.10, 0)
		pool.add_child(rim)
		# Shallow water disc
		var water: MeshInstance3D = MeshInstance3D.new()
		var wm: CylinderMesh = CylinderMesh.new()
		wm.top_radius = 0.65
		wm.bottom_radius = 0.65
		wm.height = 0.04
		water.mesh = wm
		water.material_override = water_mat
		water.position = Vector3(0, 0.08, 0)
		pool.add_child(water)
		# Subtle bob
		var tw: Tween = water.create_tween().set_loops()
		tw.tween_interval(i * 0.20)
		tw.tween_property(water, "position:y", 0.10, 1.0)
		tw.tween_property(water, "position:y", 0.08, 1.0)


static func _build_d8_starfish(geom: Node) -> void:
	## Epic-8 T23: 4 starfish creatures on the dock — orange/red 5-pointed
	## stars made from a center sphere + 5 prism arms.
	var stars: Node3D = Node3D.new()
	stars.name = "Starfish"
	stars.position = Vector3(D8_CENTER.x + 14.0, 0.0, 14.0)
	geom.add_child(stars)
	var orange_mat: StandardMaterial3D = StandardMaterial3D.new()
	orange_mat.albedo_color = Color(0.95, 0.55, 0.20)
	orange_mat.emission_enabled = true
	orange_mat.emission = Color(0.95, 0.45, 0.10)
	orange_mat.emission_energy_multiplier = 0.65
	orange_mat.roughness = 0.85
	var red_mat: StandardMaterial3D = StandardMaterial3D.new()
	red_mat.albedo_color = Color(0.85, 0.20, 0.20)
	red_mat.emission_enabled = true
	red_mat.emission = Color(0.85, 0.20, 0.20)
	red_mat.emission_energy_multiplier = 0.65
	red_mat.roughness = 0.85
	var positions: Array = [
		Vector3( 0.0, 0,  0.0),
		Vector3( 1.85, 0,  0.85),
		Vector3(-1.40, 0,  1.40),
		Vector3( 1.0, 0, -1.40),
	]
	for i in positions.size():
		var star: Node3D = Node3D.new()
		star.position = positions[i]
		stars.add_child(star)
		# Center disc
		var center: MeshInstance3D = MeshInstance3D.new()
		var cm: SphereMesh = SphereMesh.new()
		cm.radius = 0.18
		cm.height = 0.10
		center.mesh = cm
		var mat: StandardMaterial3D = orange_mat if i % 2 == 0 else red_mat
		center.material_override = mat
		center.position = Vector3(0, 0.05, 0)
		center.scale = Vector3(1.0, 0.45, 1.0)
		star.add_child(center)
		# 5 arms radiating outward (prisms)
		for j in 5:
			var ang: float = (TAU / 5.0) * j
			var arm: MeshInstance3D = MeshInstance3D.new()
			var am: PrismMesh = PrismMesh.new()
			am.size = Vector3(0.10, 0.30, 0.06)
			arm.mesh = am
			arm.material_override = mat
			arm.position = Vector3(cos(ang) * 0.20, 0.05, sin(ang) * 0.20)
			arm.rotation = Vector3(0, -ang + PI * 0.5, PI * 0.5)
			star.add_child(arm)


static func _build_d8_warning_bell(geom: Node) -> void:
	## Epic-8 T24: warning bell mounted on a tall wooden pole — used to
	## signal storms or arrivals.
	var bell: Node3D = Node3D.new()
	bell.name = "WarningBell"
	bell.position = Vector3(D8_CENTER.x - 8.0, 0.0, -16.0)
	geom.add_child(bell)
	var wood_mat: StandardMaterial3D = StandardMaterial3D.new()
	wood_mat.albedo_color = Color(0.40, 0.25, 0.10)
	wood_mat.roughness = 0.85
	var brass_mat: StandardMaterial3D = StandardMaterial3D.new()
	brass_mat.albedo_color = Color(0.95, 0.75, 0.20)
	brass_mat.emission_enabled = true
	brass_mat.emission = Color(0.95, 0.65, 0.10)
	brass_mat.emission_energy_multiplier = 0.85
	brass_mat.metallic = 0.95
	brass_mat.roughness = 0.10
	# Tall wooden pole
	var pole: MeshInstance3D = MeshInstance3D.new()
	var pm: CylinderMesh = CylinderMesh.new()
	pm.top_radius = 0.10
	pm.bottom_radius = 0.18
	pm.height = 4.20
	pole.mesh = pm
	pole.material_override = wood_mat
	pole.position = Vector3(0, 2.10, 0)
	bell.add_child(pole)
	# Top bracket arm
	var arm: MeshInstance3D = MeshInstance3D.new()
	var am: CylinderMesh = CylinderMesh.new()
	am.top_radius = 0.06
	am.bottom_radius = 0.06
	am.height = 0.55
	arm.mesh = am
	arm.material_override = wood_mat
	arm.position = Vector3(0.20, 4.20, 0)
	arm.rotation_degrees = Vector3(0, 0, 90)
	bell.add_child(arm)
	# Bell pivot for sway
	var bell_pivot: Node3D = Node3D.new()
	bell_pivot.position = Vector3(0.40, 4.0, 0)
	bell.add_child(bell_pivot)
	# Brass bell
	var bell_body: MeshInstance3D = MeshInstance3D.new()
	var bbm: SphereMesh = SphereMesh.new()
	bbm.radius = 0.30
	bbm.height = 0.55
	bell_body.mesh = bbm
	bell_body.material_override = brass_mat
	bell_body.position = Vector3(0, -0.30, 0)
	bell_body.scale = Vector3(1.0, 0.85, 1.0)
	bell_pivot.add_child(bell_body)
	# Slow sway tween
	var tw: Tween = bell_pivot.create_tween().set_loops()
	tw.tween_property(bell_pivot, "rotation_degrees:x", 6.0, 1.4)
	tw.tween_property(bell_pivot, "rotation_degrees:x", -6.0, 1.4)
	# Pole collision
	var sb: StaticBody3D = StaticBody3D.new()
	sb.position = Vector3(0, 2.10, 0)
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cap: CapsuleShape3D = CapsuleShape3D.new()
	cap.radius = 0.18
	cap.height = 4.20
	cs.shape = cap
	sb.add_child(cs)
	bell.add_child(sb)


static func _build_d8_net_mending(geom: Node) -> void:
	## Epic-8 T25: net mending station — wooden frame with a large draped
	## fishing net + small wooden stool.
	var station: Node3D = Node3D.new()
	station.name = "NetMending"
	station.position = Vector3(D8_CENTER.x - 14.0, 0.0, -16.0)
	geom.add_child(station)
	var wood_mat: StandardMaterial3D = StandardMaterial3D.new()
	wood_mat.albedo_color = Color(0.45, 0.28, 0.12)
	wood_mat.roughness = 0.85
	var net_mat: StandardMaterial3D = StandardMaterial3D.new()
	net_mat.albedo_color = Color(0.85, 0.75, 0.45, 0.55)
	net_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	net_mat.emission_enabled = true
	net_mat.emission = Color(0.85, 0.65, 0.30)
	net_mat.emission_energy_multiplier = 0.45
	net_mat.roughness = 0.85
	# Frame (square wooden frame)
	for i in 4:
		var post: MeshInstance3D = MeshInstance3D.new()
		var pm: CylinderMesh = CylinderMesh.new()
		pm.top_radius = 0.06
		pm.bottom_radius = 0.06
		pm.height = 1.85
		post.mesh = pm
		var ang: float = (TAU / 4.0) * i + PI / 4.0
		post.material_override = wood_mat
		post.position = Vector3(cos(ang) * 0.85, 0.92, sin(ang) * 0.85)
		station.add_child(post)
	# Top horizontal frame bars
	for i in 2:
		var bar: MeshInstance3D = MeshInstance3D.new()
		var bm: CylinderMesh = CylinderMesh.new()
		bm.top_radius = 0.04
		bm.bottom_radius = 0.04
		bm.height = 1.70
		bar.mesh = bm
		bar.material_override = wood_mat
		bar.position = Vector3(0, 1.85, 0)
		bar.rotation_degrees = Vector3(0, i * 90.0, 90)
		station.add_child(bar)
	# Net draped over (large translucent box)
	var net: MeshInstance3D = MeshInstance3D.new()
	var nm: BoxMesh = BoxMesh.new()
	nm.size = Vector3(1.85, 0.85, 1.85)
	net.mesh = nm
	net.material_override = net_mat
	net.position = Vector3(0, 1.40, 0)
	station.add_child(net)
	# Small wooden stool beside it
	var stool: MeshInstance3D = MeshInstance3D.new()
	var stm: CylinderMesh = CylinderMesh.new()
	stm.top_radius = 0.30
	stm.bottom_radius = 0.30
	stm.height = 0.55
	stool.mesh = stm
	stool.material_override = wood_mat
	stool.position = Vector3(1.40, 0.27, 0)
	station.add_child(stool)
	# Frame collision
	var sb: StaticBody3D = StaticBody3D.new()
	sb.position = Vector3(0, 0.92, 0)
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(2.20, 1.85, 2.20)
	cs.shape = cb
	sb.add_child(cs)
	station.add_child(sb)


static func _build_d8_kraken(geom: Node) -> void:
	## Epic-8 T26: distant kraken silhouette — large dark tentacles
	## emerging from the water + 2 glowing red eyes peeking out.
	var kraken: Node3D = Node3D.new()
	kraken.name = "Kraken"
	kraken.position = Vector3(D8_CENTER.x + 28.0, 0.0, -22.0)
	geom.add_child(kraken)
	var dark_mat: StandardMaterial3D = StandardMaterial3D.new()
	dark_mat.albedo_color = Color(0.10, 0.12, 0.18)
	dark_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	# Body lump (large flat sphere)
	var body: MeshInstance3D = MeshInstance3D.new()
	var bm: SphereMesh = SphereMesh.new()
	bm.radius = 2.40
	bm.height = 2.85
	body.mesh = bm
	body.material_override = dark_mat
	body.position = Vector3(0, 1.40, 0)
	body.scale = Vector3(1.30, 0.55, 1.30)
	kraken.add_child(body)
	# 6 large tentacles emerging upward
	for i in 6:
		var ang: float = (TAU / 6.0) * i
		var tentacle: MeshInstance3D = MeshInstance3D.new()
		var tm: CylinderMesh = CylinderMesh.new()
		tm.top_radius = 0.30
		tm.bottom_radius = 0.85
		tm.height = 5.50 + (i % 3) * 1.40
		tentacle.mesh = tm
		tentacle.material_override = dark_mat
		tentacle.position = Vector3(cos(ang) * 1.85, 2.85 + (i % 3) * 0.85, sin(ang) * 1.85)
		tentacle.rotation = Vector3(deg_to_rad(15) * sin(ang), 0, deg_to_rad(15) * cos(ang))
		kraken.add_child(tentacle)
		# Subtle wave tween per tentacle
		var tw: Tween = tentacle.create_tween().set_loops()
		tw.tween_interval(i * 0.20)
		tw.tween_property(tentacle, "rotation_degrees:z", 6.0, 1.85)
		tw.tween_property(tentacle, "rotation_degrees:z", -6.0, 1.85)
	# 2 glowing red eyes peeking out
	var eye_mat: StandardMaterial3D = StandardMaterial3D.new()
	eye_mat.albedo_color = Color(1.0, 0.20, 0.20)
	eye_mat.emission_enabled = true
	eye_mat.emission = Color(1.0, 0.10, 0.10)
	eye_mat.emission_energy_multiplier = 4.5
	eye_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for ex in [-0.55, 0.55]:
		var eye: MeshInstance3D = MeshInstance3D.new()
		var em: SphereMesh = SphereMesh.new()
		em.radius = 0.22
		em.height = 0.40
		eye.mesh = em
		eye.material_override = eye_mat
		eye.position = Vector3(ex, 1.85, 1.40)
		kraken.add_child(eye)
		# Slow blink tween
		var tw: Tween = eye.create_tween().set_loops()
		tw.tween_interval(2.5 + randf() * 1.5)
		tw.tween_property(eye, "scale:y", 0.10, 0.10)
		tw.tween_property(eye, "scale:y", 1.0, 0.10)


static func _build_d8_harpooner_npc(town: Node) -> void:
	## Epic-8 T27: harpooner NPC — leather vest + held large harpoon spear.
	var npc_slots: Node3D = town.get_node_or_null("%NPCSlots") as Node3D
	if npc_slots == null:
		return
	var slot: Marker3D = Marker3D.new()
	slot.name = "HarpoonerSlot"
	slot.position = Vector3(D8_CENTER.x + 12.0, 0.0, -16.0)
	npc_slots.add_child(slot)
	var npc_scene: PackedScene = load("res://scenes/entities/npcs/VillagerR3.tscn") as PackedScene
	if npc_scene == null:
		return
	var npc: Node3D = npc_scene.instantiate() as Node3D
	npc.name = "Harpooner"
	if "npc_name" in npc:
		npc.set("npc_name", "Spinepoint")
	if "npc_id" in npc:
		npc.set("npc_id", "harpooner_d8")
	slot.add_child(npc)
	# Brown leather vest
	var vest: MeshInstance3D = MeshInstance3D.new()
	var vm: BoxMesh = BoxMesh.new()
	vm.size = Vector3(0.65, 0.85, 0.40)
	vest.mesh = vm
	var vest_mat: StandardMaterial3D = StandardMaterial3D.new()
	vest_mat.albedo_color = Color(0.30, 0.18, 0.10)
	vest_mat.metallic = 0.30
	vest_mat.roughness = 0.55
	vest.material_override = vest_mat
	vest.position = Vector3(0, 0.65, 0)
	npc.add_child(vest)
	# Large harpoon spear (long handle + spearhead)
	var wood_mat: StandardMaterial3D = StandardMaterial3D.new()
	wood_mat.albedo_color = Color(0.45, 0.28, 0.12)
	wood_mat.roughness = 0.85
	var handle: MeshInstance3D = MeshInstance3D.new()
	var hmm: CylinderMesh = CylinderMesh.new()
	hmm.top_radius = 0.05
	hmm.bottom_radius = 0.06
	hmm.height = 2.40
	handle.mesh = hmm
	handle.material_override = wood_mat
	handle.position = Vector3(0.45, 1.20, 0)
	npc.add_child(handle)
	# Steel spearhead
	var head: MeshInstance3D = MeshInstance3D.new()
	var hmm2: PrismMesh = PrismMesh.new()
	hmm2.size = Vector3(0.10, 0.55, 0.10)
	head.mesh = hmm2
	var steel_mat: StandardMaterial3D = StandardMaterial3D.new()
	steel_mat.albedo_color = Color(0.85, 0.92, 1.0)
	steel_mat.metallic = 0.95
	steel_mat.roughness = 0.05
	head.material_override = steel_mat
	head.position = Vector3(0.45, 2.55, 0)
	npc.add_child(head)


static func _build_d8_signal_flags(geom: Node) -> void:
	## Epic-8 T28: tall signal flag pole — wooden mast with 4 colored
	## semaphore-style flags hanging.
	var flags: Node3D = Node3D.new()
	flags.name = "SignalFlags"
	flags.position = Vector3(D8_CENTER.x + 22.0, 0.0, -8.0)
	geom.add_child(flags)
	var wood_mat: StandardMaterial3D = StandardMaterial3D.new()
	wood_mat.albedo_color = Color(0.45, 0.28, 0.12)
	wood_mat.roughness = 0.85
	# Tall pole
	var pole: MeshInstance3D = MeshInstance3D.new()
	var pm: CylinderMesh = CylinderMesh.new()
	pm.top_radius = 0.06
	pm.bottom_radius = 0.10
	pm.height = 5.85
	pole.mesh = pm
	pole.material_override = wood_mat
	pole.position = Vector3(0, 2.92, 0)
	flags.add_child(pole)
	# Pole collision
	var sb: StaticBody3D = StaticBody3D.new()
	sb.position = Vector3(0, 2.92, 0)
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cap: CapsuleShape3D = CapsuleShape3D.new()
	cap.radius = 0.10
	cap.height = 5.85
	cs.shape = cap
	sb.add_child(cs)
	flags.add_child(sb)
	# 4 colored signal flags
	var flag_colors: Array = [
		Color(0.95, 0.20, 0.20),
		Color(0.20, 0.30, 0.85),
		Color(0.95, 0.85, 0.20),
		Color(0.30, 0.85, 0.30),
	]
	for i in 4:
		var flag: MeshInstance3D = MeshInstance3D.new()
		var fm: BoxMesh = BoxMesh.new()
		fm.size = Vector3(0.65, 0.40, 0.04)
		flag.mesh = fm
		var col: Color = flag_colors[i]
		var flag_mat: StandardMaterial3D = StandardMaterial3D.new()
		flag_mat.albedo_color = col
		flag_mat.emission_enabled = true
		flag_mat.emission = col
		flag_mat.emission_energy_multiplier = 0.65
		flag_mat.roughness = 0.85
		flag.material_override = flag_mat
		flag.position = Vector3(0.40, 4.85 - i * 0.85, 0)
		flags.add_child(flag)
		# Sway
		var tw: Tween = flag.create_tween().set_loops()
		tw.tween_interval(i * 0.15)
		tw.tween_property(flag, "rotation_degrees:y", 8.0, 1.4)
		tw.tween_property(flag, "rotation_degrees:y", -8.0, 1.4)


static func _build_d8_buoys(geom: Node) -> void:
	## Epic-8 T29: 5 floating buoys — colorful round floats with bobbing
	## tweens, marking a channel.
	var buoys: Node3D = Node3D.new()
	buoys.name = "Buoys"
	buoys.position = Vector3(D8_CENTER.x + 8.0, 0.20, 8.0)
	geom.add_child(buoys)
	var buoy_colors: Array = [
		Color(0.95, 0.20, 0.20),
		Color(0.95, 0.85, 0.20),
		Color(0.30, 0.85, 0.30),
		Color(0.95, 0.55, 0.20),
		Color(0.30, 0.65, 0.95),
	]
	for i in 5:
		var buoy: Node3D = Node3D.new()
		buoy.position = Vector3(i * 2.40, 0, 0)
		buoys.add_child(buoy)
		# Float ball
		var ball: MeshInstance3D = MeshInstance3D.new()
		var bm: SphereMesh = SphereMesh.new()
		bm.radius = 0.30
		bm.height = 0.55
		ball.mesh = bm
		var col: Color = buoy_colors[i]
		var ball_mat: StandardMaterial3D = StandardMaterial3D.new()
		ball_mat.albedo_color = col
		ball_mat.emission_enabled = true
		ball_mat.emission = col
		ball_mat.emission_energy_multiplier = 1.4
		ball_mat.metallic = 0.30
		ball_mat.roughness = 0.30
		ball.material_override = ball_mat
		buoy.add_child(ball)
		# Top stick (mast with flag)
		var stick: MeshInstance3D = MeshInstance3D.new()
		var stm: CylinderMesh = CylinderMesh.new()
		stm.top_radius = 0.025
		stm.bottom_radius = 0.025
		stm.height = 0.55
		stick.mesh = stm
		var stick_mat: StandardMaterial3D = StandardMaterial3D.new()
		stick_mat.albedo_color = Color(0.45, 0.28, 0.12)
		stick_mat.roughness = 0.85
		stick.material_override = stick_mat
		stick.position = Vector3(0, 0.55, 0)
		buoy.add_child(stick)
		# Bobbing tween
		var tw: Tween = buoy.create_tween().set_loops()
		tw.tween_interval(i * 0.20)
		tw.tween_property(buoy, "position:y", 0.40, 1.4)
		tw.tween_property(buoy, "position:y", 0.20, 1.4)


static func _build_d8_jellyfish_glow(geom: Node) -> void:
	## Epic-8 T30: jellyfish glow particles — soft purple/pink GPU particles
	## floating gently across the harbor like bioluminescent jellyfish.
	var jellies: GPUParticles3D = GPUParticles3D.new()
	jellies.name = "JellyfishGlow"
	jellies.position = Vector3(D8_CENTER.x, 1.5, 0.0)
	jellies.amount = 50
	jellies.lifetime = 14.0
	jellies.preprocess = 7.0
	jellies.explosiveness = 0.0
	jellies.randomness = 0.85
	jellies.visibility_aabb = AABB(Vector3(-40, -2, -25), Vector3(80, 8, 50))
	var pm: ParticleProcessMaterial = ParticleProcessMaterial.new()
	pm.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	pm.emission_box_extents = Vector3(35, 1, 22)
	pm.direction = Vector3(0.20, 0.10, 0.05)
	pm.spread = 65.0
	pm.gravity = Vector3(0.05, 0.10, 0.04)
	pm.initial_velocity_min = 0.10
	pm.initial_velocity_max = 0.30
	pm.scale_min = 0.18
	pm.scale_max = 0.40
	pm.color = Color(0.85, 0.55, 0.95, 0.65)
	jellies.process_material = pm
	# Jelly mesh
	var jelly_mesh: SphereMesh = SphereMesh.new()
	jelly_mesh.radius = 0.18
	jelly_mesh.height = 0.30
	jellies.draw_pass_1 = jelly_mesh
	var jelly_mat: StandardMaterial3D = StandardMaterial3D.new()
	jelly_mat.albedo_color = Color(0.85, 0.55, 0.95, 0.55)
	jelly_mat.emission_enabled = true
	jelly_mat.emission = Color(0.95, 0.55, 0.95)
	jelly_mat.emission_energy_multiplier = 1.85
	jelly_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	jelly_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	jelly_mesh.material = jelly_mat
	geom.add_child(jellies)


static func _build_d8_shipyard_scaffold(geom: Node) -> void:
	## Epic-8 T31: shipyard scaffolding — wooden frame structure
	## supporting an under-construction boat hull.
	var yard: Node3D = Node3D.new()
	yard.name = "ShipyardScaffold"
	yard.position = Vector3(D8_CENTER.x - 18.0, 0.0, -22.0)
	geom.add_child(yard)
	var wood_mat: StandardMaterial3D = StandardMaterial3D.new()
	wood_mat.albedo_color = Color(0.45, 0.28, 0.12)
	wood_mat.roughness = 0.85
	# 4 corner scaffolding posts
	for sx in [-2.0, 2.0]:
		for sz in [-1.40, 1.40]:
			var post: MeshInstance3D = MeshInstance3D.new()
			var pm: BoxMesh = BoxMesh.new()
			pm.size = Vector3(0.18, 3.40, 0.18)
			post.mesh = pm
			post.material_override = wood_mat
			post.position = Vector3(sx, 1.70, sz)
			yard.add_child(post)
	# 4 horizontal cross beams
	for h in [1.0, 2.40]:
		for axis in 2:
			var beam: MeshInstance3D = MeshInstance3D.new()
			var bm: BoxMesh = BoxMesh.new()
			bm.size = Vector3(4.20, 0.10, 0.10) if axis == 0 else Vector3(0.10, 0.10, 3.0)
			beam.mesh = bm
			beam.material_override = wood_mat
			beam.position = Vector3(0, h, 0)
			yard.add_child(beam)
	# Under-construction boat hull (tapered prism)
	var hull: MeshInstance3D = MeshInstance3D.new()
	var hm: PrismMesh = PrismMesh.new()
	hm.size = Vector3(3.40, 1.40, 1.85)
	hull.mesh = hm
	var hull_mat: StandardMaterial3D = StandardMaterial3D.new()
	hull_mat.albedo_color = Color(0.55, 0.35, 0.18)
	hull_mat.roughness = 0.85
	hull.material_override = hull_mat
	hull.position = Vector3(0, 0.85, 0)
	hull.rotation_degrees = Vector3(0, 0, -90)
	yard.add_child(hull)
	# Yard collision (single box around the scaffold)
	var sb: StaticBody3D = StaticBody3D.new()
	sb.position = Vector3(0, 1.70, 0)
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(4.20, 3.40, 3.0)
	cs.shape = cb
	sb.add_child(cs)
	yard.add_child(sb)


static func _build_d8_shipwright_npc(town: Node) -> void:
	## Epic-8 T32: shipwright NPC — leather apron + held wood plane.
	var npc_slots: Node3D = town.get_node_or_null("%NPCSlots") as Node3D
	if npc_slots == null:
		return
	var slot: Marker3D = Marker3D.new()
	slot.name = "ShipwrightSlot"
	slot.position = Vector3(D8_CENTER.x - 14.0, 0.0, -22.0)
	npc_slots.add_child(slot)
	var npc_scene: PackedScene = load("res://scenes/entities/npcs/VillagerR3.tscn") as PackedScene
	if npc_scene == null:
		return
	var npc: Node3D = npc_scene.instantiate() as Node3D
	npc.name = "Shipwright"
	if "npc_name" in npc:
		npc.set("npc_name", "Carven")
	if "npc_id" in npc:
		npc.set("npc_id", "shipwright_d8")
	slot.add_child(npc)
	# Leather apron
	var apron: MeshInstance3D = MeshInstance3D.new()
	var am: BoxMesh = BoxMesh.new()
	am.size = Vector3(0.55, 0.85, 0.06)
	apron.mesh = am
	var apron_mat: StandardMaterial3D = StandardMaterial3D.new()
	apron_mat.albedo_color = Color(0.40, 0.25, 0.12)
	apron_mat.metallic = 0.30
	apron_mat.roughness = 0.65
	apron.material_override = apron_mat
	apron.position = Vector3(0, 0.55, 0.22)
	npc.add_child(apron)
	# Wood plane (small wooden block + handle)
	var wood_mat: StandardMaterial3D = StandardMaterial3D.new()
	wood_mat.albedo_color = Color(0.45, 0.28, 0.12)
	wood_mat.roughness = 0.85
	var plane: MeshInstance3D = MeshInstance3D.new()
	var pm: BoxMesh = BoxMesh.new()
	pm.size = Vector3(0.30, 0.18, 0.10)
	plane.mesh = pm
	plane.material_override = wood_mat
	plane.position = Vector3(0.40, 0.85, 0.20)
	npc.add_child(plane)


static func _build_d8_cargo_crane(geom: Node) -> void:
	## Epic-8 T33: dockside cargo crane — tall metal frame + horizontal arm
	## with a hanging hook + crate dangling.
	var crane: Node3D = Node3D.new()
	crane.name = "CargoCrane"
	crane.position = Vector3(D8_CENTER.x - 6.0, 0.0, -22.0)
	geom.add_child(crane)
	var metal_mat: StandardMaterial3D = StandardMaterial3D.new()
	metal_mat.albedo_color = Color(0.55, 0.40, 0.20)
	metal_mat.metallic = 0.85
	metal_mat.roughness = 0.30
	var dark_metal: StandardMaterial3D = StandardMaterial3D.new()
	dark_metal.albedo_color = Color(0.20, 0.18, 0.20)
	dark_metal.metallic = 0.85
	# Tall vertical column
	var col: MeshInstance3D = MeshInstance3D.new()
	var cm: BoxMesh = BoxMesh.new()
	cm.size = Vector3(0.85, 7.40, 0.85)
	col.mesh = cm
	col.material_override = metal_mat
	col.position = Vector3(0, 3.70, 0)
	crane.add_child(col)
	# Horizontal arm (extending outward)
	var arm: MeshInstance3D = MeshInstance3D.new()
	var arm_m: BoxMesh = BoxMesh.new()
	arm_m.size = Vector3(4.20, 0.40, 0.40)
	arm.mesh = arm_m
	arm.material_override = metal_mat
	arm.position = Vector3(2.10, 6.85, 0)
	crane.add_child(arm)
	# Counterweight (small box on opposite side)
	var counter: MeshInstance3D = MeshInstance3D.new()
	var cwm: BoxMesh = BoxMesh.new()
	cwm.size = Vector3(0.85, 0.85, 0.85)
	counter.mesh = cwm
	counter.material_override = dark_metal
	counter.position = Vector3(-0.85, 6.85, 0)
	crane.add_child(counter)
	# Hanging cable
	var cable: MeshInstance3D = MeshInstance3D.new()
	var ccm: CylinderMesh = CylinderMesh.new()
	ccm.top_radius = 0.025
	ccm.bottom_radius = 0.025
	ccm.height = 3.20
	cable.mesh = ccm
	cable.material_override = dark_metal
	cable.position = Vector3(3.85, 5.0, 0)
	crane.add_child(cable)
	# Hanging crate
	var crate: MeshInstance3D = MeshInstance3D.new()
	var crt_m: BoxMesh = BoxMesh.new()
	crt_m.size = Vector3(0.85, 0.85, 0.85)
	crate.mesh = crt_m
	var wood_mat: StandardMaterial3D = StandardMaterial3D.new()
	wood_mat.albedo_color = Color(0.45, 0.28, 0.12)
	wood_mat.roughness = 0.92
	crate.material_override = wood_mat
	crate.position = Vector3(3.85, 2.85, 0)
	crane.add_child(crate)
	# Crate sway tween
	var tw: Tween = crate.create_tween().set_loops()
	tw.tween_property(crate, "position:x", 4.20, 1.4)
	tw.tween_property(crate, "position:x", 3.50, 1.4)
	# Column collision
	var sb: StaticBody3D = StaticBody3D.new()
	sb.position = Vector3(0, 3.70, 0)
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(0.85, 7.40, 0.85)
	cs.shape = cb
	sb.add_child(cs)
	crane.add_child(sb)


static func _build_d8_dock_workers(geom: Node) -> void:
	## Epic-8 T34: 3 dock worker NPCs carrying crates — small worker
	## figures with carry-poses around the harbor.
	var workers: Node3D = Node3D.new()
	workers.name = "DockWorkers"
	workers.position = Vector3(D8_CENTER.x + 4.0, 0.0, -8.0)
	geom.add_child(workers)
	var positions: Array = [
		Vector3( 0.0, 0,  0.0),
		Vector3( 2.85, 0,  1.40),
		Vector3(-2.40, 0,  0.85),
	]
	var shirt_colors: Array = [
		Color(0.85, 0.20, 0.30),
		Color(0.30, 0.65, 0.95),
		Color(0.95, 0.85, 0.20),
	]
	for i in 3:
		var worker: Node3D = Node3D.new()
		worker.position = positions[i]
		workers.add_child(worker)
		# Body
		var body: MeshInstance3D = MeshInstance3D.new()
		var bm: BoxMesh = BoxMesh.new()
		bm.size = Vector3(0.55, 0.95, 0.30)
		body.mesh = bm
		var body_mat: StandardMaterial3D = StandardMaterial3D.new()
		body_mat.albedo_color = shirt_colors[i]
		body_mat.emission_enabled = true
		body_mat.emission = shirt_colors[i]
		body_mat.emission_energy_multiplier = 0.30
		body.material_override = body_mat
		body.position = Vector3(0, 0.55, 0)
		worker.add_child(body)
		# Head
		var head: MeshInstance3D = MeshInstance3D.new()
		var hm: SphereMesh = SphereMesh.new()
		hm.radius = 0.18
		hm.height = 0.32
		head.mesh = hm
		var skin_mat: StandardMaterial3D = StandardMaterial3D.new()
		skin_mat.albedo_color = Color(0.95, 0.85, 0.75)
		head.material_override = skin_mat
		head.position = Vector3(0, 1.20, 0)
		worker.add_child(head)
		# Carried crate above head
		var crate: MeshInstance3D = MeshInstance3D.new()
		var cm: BoxMesh = BoxMesh.new()
		cm.size = Vector3(0.55, 0.30, 0.55)
		crate.mesh = cm
		var crate_mat: StandardMaterial3D = StandardMaterial3D.new()
		crate_mat.albedo_color = Color(0.45, 0.28, 0.12)
		crate.material_override = crate_mat
		crate.position = Vector3(0, 1.65, 0)
		worker.add_child(crate)
		# Walk bob
		var tw: Tween = worker.create_tween().set_loops()
		tw.tween_property(worker, "position:y", 0.10, 0.30)
		tw.tween_property(worker, "position:y", 0.0, 0.30)


static func _build_d8_tide_gauge(geom: Node) -> void:
	## Epic-8 T35: tide gauge measuring stick — vertical wooden pole with
	## colored measurement bands.
	var gauge: Node3D = Node3D.new()
	gauge.name = "TideGauge"
	gauge.position = Vector3(D8_CENTER.x + 22.0, 0.0, 18.0)
	geom.add_child(gauge)
	var wood_mat: StandardMaterial3D = StandardMaterial3D.new()
	wood_mat.albedo_color = Color(0.45, 0.28, 0.12)
	wood_mat.roughness = 0.85
	# Pole
	var pole: MeshInstance3D = MeshInstance3D.new()
	var pm: BoxMesh = BoxMesh.new()
	pm.size = Vector3(0.18, 3.40, 0.18)
	pole.mesh = pm
	pole.material_override = wood_mat
	pole.position = Vector3(0, 1.70, 0)
	gauge.add_child(pole)
	# Measurement bands (alternating red and white)
	var red_mat: StandardMaterial3D = StandardMaterial3D.new()
	red_mat.albedo_color = Color(0.85, 0.20, 0.20)
	red_mat.emission_enabled = true
	red_mat.emission = Color(0.85, 0.20, 0.20)
	red_mat.emission_energy_multiplier = 0.45
	var white_mat: StandardMaterial3D = StandardMaterial3D.new()
	white_mat.albedo_color = Color(0.95, 0.95, 0.92)
	for i in 8:
		var band: MeshInstance3D = MeshInstance3D.new()
		var bm: BoxMesh = BoxMesh.new()
		bm.size = Vector3(0.20, 0.30, 0.20)
		band.mesh = bm
		band.material_override = red_mat if i % 2 == 0 else white_mat
		band.position = Vector3(0, 0.30 + i * 0.40, 0)
		gauge.add_child(band)
	# Top arrow indicator
	var arrow: MeshInstance3D = MeshInstance3D.new()
	var am: PrismMesh = PrismMesh.new()
	am.size = Vector3(0.30, 0.18, 0.10)
	arrow.mesh = am
	var arrow_mat: StandardMaterial3D = StandardMaterial3D.new()
	arrow_mat.albedo_color = Color(0.30, 0.85, 1.0)
	arrow_mat.emission_enabled = true
	arrow_mat.emission = Color(0.30, 0.95, 1.0)
	arrow_mat.emission_energy_multiplier = 1.4
	arrow_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	arrow.material_override = arrow_mat
	arrow.position = Vector3(0.30, 3.40, 0)
	arrow.rotation_degrees = Vector3(0, 0, 90)
	gauge.add_child(arrow)
	# Pole collision
	var sb: StaticBody3D = StaticBody3D.new()
	sb.position = Vector3(0, 1.70, 0)
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cap: CapsuleShape3D = CapsuleShape3D.new()
	cap.radius = 0.18
	cap.height = 3.40
	cs.shape = cap
	sb.add_child(cs)
	gauge.add_child(sb)


static func _build_d8_treasure_chest(geom: Node) -> void:
	## Epic-8 T36: half-sunken treasure chest with glowing gold spilling out.
	var chest: Node3D = Node3D.new()
	chest.name = "TreasureChest"
	chest.position = Vector3(D8_CENTER.x + 18.0, 0.30, 8.0)
	geom.add_child(chest)
	var wood_mat: StandardMaterial3D = StandardMaterial3D.new()
	wood_mat.albedo_color = Color(0.30, 0.18, 0.08)
	wood_mat.roughness = 0.92
	var gold_mat: StandardMaterial3D = StandardMaterial3D.new()
	gold_mat.albedo_color = Color(1.0, 0.85, 0.30)
	gold_mat.emission_enabled = true
	gold_mat.emission = Color(1.0, 0.75, 0.20)
	gold_mat.emission_energy_multiplier = 2.5
	gold_mat.metallic = 0.95
	gold_mat.roughness = 0.10
	var iron_mat: StandardMaterial3D = StandardMaterial3D.new()
	iron_mat.albedo_color = Color(0.20, 0.18, 0.20)
	iron_mat.metallic = 0.85
	iron_mat.roughness = 0.40
	# Chest base
	var base: MeshInstance3D = MeshInstance3D.new()
	var bm: BoxMesh = BoxMesh.new()
	bm.size = Vector3(1.40, 0.65, 0.85)
	base.mesh = bm
	base.material_override = wood_mat
	base.position = Vector3(0, 0.32, 0)
	chest.add_child(base)
	# Curved lid (open at angle)
	var lid: MeshInstance3D = MeshInstance3D.new()
	var lm: BoxMesh = BoxMesh.new()
	lm.size = Vector3(1.40, 0.55, 0.85)
	lid.mesh = lm
	lid.material_override = wood_mat
	lid.position = Vector3(0, 0.85, -0.30)
	lid.rotation_degrees = Vector3(-35, 0, 0)
	chest.add_child(lid)
	# Iron bands (3 horizontal hoops)
	for hy in [-0.10, 0.10, 0.30]:
		var band: MeshInstance3D = MeshInstance3D.new()
		var bdm: BoxMesh = BoxMesh.new()
		bdm.size = Vector3(1.42, 0.06, 0.87)
		band.mesh = bdm
		band.material_override = iron_mat
		band.position = Vector3(0, 0.32 + hy, 0)
		chest.add_child(band)
	# Gold coins spilling out
	for i in 5:
		var coin: MeshInstance3D = MeshInstance3D.new()
		var cmm: CylinderMesh = CylinderMesh.new()
		cmm.top_radius = 0.10
		cmm.bottom_radius = 0.10
		cmm.height = 0.04
		coin.mesh = cmm
		coin.material_override = gold_mat
		coin.position = Vector3(
			randf_range(-0.40, 0.40),
			0.65 + randf_range(0, 0.10),
			randf_range(0.20, 0.55)
		)
		coin.rotation_degrees = Vector3(randf_range(-30, 30), randf_range(0, 360), 90)
		chest.add_child(coin)
	# Bobbing tween
	var tw: Tween = chest.create_tween().set_loops()
	tw.tween_property(chest, "position:y", 0.45, 1.6)
	tw.tween_property(chest, "position:y", 0.30, 1.6)
	# Aura light
	var light: OmniLight3D = OmniLight3D.new()
	light.light_color = Color(1.0, 0.85, 0.30)
	light.light_energy = 2.5
	light.omni_range = 5.5
	light.position = Vector3(0, 1.20, 0)
	chest.add_child(light)
	# Chest collision
	var sb: StaticBody3D = StaticBody3D.new()
	sb.position = Vector3(0, 0.55, 0)
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(1.40, 1.10, 0.85)
	cs.shape = cb
	sb.add_child(cs)
	chest.add_child(sb)


static func _build_d8_treasure_hunter_npc(town: Node) -> void:
	## Epic-8 T37: treasure hunter NPC — pirate-style coat + tricorn hat +
	## eye patch + held gold coin.
	var npc_slots: Node3D = town.get_node_or_null("%NPCSlots") as Node3D
	if npc_slots == null:
		return
	var slot: Marker3D = Marker3D.new()
	slot.name = "TreasureHunterSlot"
	slot.position = Vector3(D8_CENTER.x + 16.0, 0.0, 8.0)
	npc_slots.add_child(slot)
	var npc_scene: PackedScene = load("res://scenes/entities/npcs/VillagerR3.tscn") as PackedScene
	if npc_scene == null:
		return
	var npc: Node3D = npc_scene.instantiate() as Node3D
	npc.name = "TreasureHunter"
	if "npc_name" in npc:
		npc.set("npc_name", "Doubloon")
	if "npc_id" in npc:
		npc.set("npc_id", "treasure_hunter_d8")
	slot.add_child(npc)
	# Long pirate coat
	var coat: MeshInstance3D = MeshInstance3D.new()
	var cm: BoxMesh = BoxMesh.new()
	cm.size = Vector3(0.75, 1.20, 0.50)
	coat.mesh = cm
	var coat_mat: StandardMaterial3D = StandardMaterial3D.new()
	coat_mat.albedo_color = Color(0.55, 0.20, 0.20)
	coat_mat.metallic = 0.30
	coat_mat.roughness = 0.55
	coat.material_override = coat_mat
	coat.position = Vector3(0, 0.60, 0)
	npc.add_child(coat)
	# Tricorn hat (3-pointed brim + dome)
	var hat_mat: StandardMaterial3D = StandardMaterial3D.new()
	hat_mat.albedo_color = Color(0.10, 0.08, 0.10)
	hat_mat.metallic = 0.30
	hat_mat.roughness = 0.55
	for i in 3:
		var ang: float = (TAU / 3.0) * i
		var brim: MeshInstance3D = MeshInstance3D.new()
		var brm: BoxMesh = BoxMesh.new()
		brm.size = Vector3(0.40, 0.04, 0.18)
		brim.mesh = brm
		brim.material_override = hat_mat
		brim.position = Vector3(cos(ang) * 0.18, 1.45, sin(ang) * 0.18)
		brim.rotation = Vector3(0, -ang + PI * 0.5, 0)
		npc.add_child(brim)
	var dome: MeshInstance3D = MeshInstance3D.new()
	var dmm: SphereMesh = SphereMesh.new()
	dmm.radius = 0.20
	dmm.height = 0.30
	dome.mesh = dmm
	dome.material_override = hat_mat
	dome.position = Vector3(0, 1.55, 0)
	dome.scale = Vector3(1.0, 0.85, 1.0)
	npc.add_child(dome)
	# Eye patch (small dark box)
	var patch: MeshInstance3D = MeshInstance3D.new()
	var pmm: BoxMesh = BoxMesh.new()
	pmm.size = Vector3(0.10, 0.10, 0.04)
	patch.mesh = pmm
	patch.material_override = hat_mat
	patch.position = Vector3(0.10, 1.30, 0.21)
	npc.add_child(patch)
	# Held gold coin
	var coin: MeshInstance3D = MeshInstance3D.new()
	var cn_m: CylinderMesh = CylinderMesh.new()
	cn_m.top_radius = 0.12
	cn_m.bottom_radius = 0.12
	cn_m.height = 0.04
	coin.mesh = cn_m
	var gold_mat: StandardMaterial3D = StandardMaterial3D.new()
	gold_mat.albedo_color = Color(1.0, 0.85, 0.30)
	gold_mat.emission_enabled = true
	gold_mat.emission = Color(1.0, 0.75, 0.20)
	gold_mat.emission_energy_multiplier = 2.0
	gold_mat.metallic = 0.95
	gold_mat.roughness = 0.10
	coin.material_override = gold_mat
	coin.position = Vector3(0.40, 0.85, 0.20)
	coin.rotation_degrees = Vector3(0, 0, 90)
	npc.add_child(coin)


static func _build_d8_bottle_display(geom: Node) -> void:
	## Epic-8 T38: ship in a bottle display — wooden table with 3 sealed
	## glass bottles each containing a tiny boat.
	var disp: Node3D = Node3D.new()
	disp.name = "BottleDisplay"
	disp.position = Vector3(D8_CENTER.x + 26.0, 0.0, 8.0)
	geom.add_child(disp)
	var wood_mat: StandardMaterial3D = StandardMaterial3D.new()
	wood_mat.albedo_color = Color(0.45, 0.28, 0.12)
	wood_mat.roughness = 0.85
	var glass_mat: StandardMaterial3D = StandardMaterial3D.new()
	glass_mat.albedo_color = Color(0.85, 0.95, 1.0, 0.45)
	glass_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	glass_mat.emission_enabled = true
	glass_mat.emission = Color(0.65, 0.85, 1.0)
	glass_mat.emission_energy_multiplier = 0.85
	glass_mat.metallic = 0.55
	glass_mat.roughness = 0.05
	# Wooden display table
	var table: MeshInstance3D = MeshInstance3D.new()
	var tm: BoxMesh = BoxMesh.new()
	tm.size = Vector3(2.40, 0.85, 0.85)
	table.mesh = tm
	table.material_override = wood_mat
	table.position = Vector3(0, 0.42, 0)
	disp.add_child(table)
	# 3 glass bottles
	for i in 3:
		var bottle: MeshInstance3D = MeshInstance3D.new()
		var bm: CylinderMesh = CylinderMesh.new()
		bm.top_radius = 0.18
		bm.bottom_radius = 0.18
		bm.height = 0.55
		bottle.mesh = bm
		bottle.material_override = glass_mat
		bottle.position = Vector3(-0.85 + i * 0.85, 1.10, 0)
		bottle.rotation_degrees = Vector3(0, 0, 90)
		disp.add_child(bottle)
		# Tiny boat inside
		var boat: MeshInstance3D = MeshInstance3D.new()
		var bom: BoxMesh = BoxMesh.new()
		bom.size = Vector3(0.20, 0.08, 0.08)
		boat.mesh = bom
		var boat_mat: StandardMaterial3D = StandardMaterial3D.new()
		boat_mat.albedo_color = Color(0.45, 0.28, 0.12)
		boat.material_override = boat_mat
		boat.position = Vector3(-0.85 + i * 0.85, 1.10, 0)
		disp.add_child(boat)
		# Tiny mast
		var mast: MeshInstance3D = MeshInstance3D.new()
		var mmm: CylinderMesh = CylinderMesh.new()
		mmm.top_radius = 0.012
		mmm.bottom_radius = 0.012
		mmm.height = 0.18
		mast.mesh = mmm
		mast.material_override = boat_mat
		mast.position = Vector3(-0.85 + i * 0.85, 1.20, 0)
		disp.add_child(mast)
	# Table collision
	var sb: StaticBody3D = StaticBody3D.new()
	sb.position = Vector3(0, 0.42, 0)
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(2.40, 0.85, 0.85)
	cs.shape = cb
	sb.add_child(cs)
	disp.add_child(sb)


static func _build_d8_bottle_artisan_npc(town: Node) -> void:
	## Epic-8 T39: ship in a bottle artisan NPC — small magnifying glass +
	## brown vest.
	var npc_slots: Node3D = town.get_node_or_null("%NPCSlots") as Node3D
	if npc_slots == null:
		return
	var slot: Marker3D = Marker3D.new()
	slot.name = "BottleArtisanSlot"
	slot.position = Vector3(D8_CENTER.x + 26.0, 0.0, 6.0)
	npc_slots.add_child(slot)
	var npc_scene: PackedScene = load("res://scenes/entities/npcs/VillagerR3.tscn") as PackedScene
	if npc_scene == null:
		return
	var npc: Node3D = npc_scene.instantiate() as Node3D
	npc.name = "BottleArtisan"
	if "npc_name" in npc:
		npc.set("npc_name", "Tinkerwave")
	if "npc_id" in npc:
		npc.set("npc_id", "bottle_artisan_d8")
	slot.add_child(npc)
	# Brown vest
	var vest: MeshInstance3D = MeshInstance3D.new()
	var vm: BoxMesh = BoxMesh.new()
	vm.size = Vector3(0.65, 0.85, 0.40)
	vest.mesh = vm
	var vest_mat: StandardMaterial3D = StandardMaterial3D.new()
	vest_mat.albedo_color = Color(0.40, 0.25, 0.10)
	vest_mat.metallic = 0.30
	vest_mat.roughness = 0.55
	vest.material_override = vest_mat
	vest.position = Vector3(0, 0.65, 0)
	npc.add_child(vest)
	# Magnifying glass (small torus + tiny handle)
	var glass: MeshInstance3D = MeshInstance3D.new()
	var gtm: TorusMesh = TorusMesh.new()
	gtm.inner_radius = 0.10
	gtm.outer_radius = 0.14
	glass.mesh = gtm
	var brass_mat: StandardMaterial3D = StandardMaterial3D.new()
	brass_mat.albedo_color = Color(0.85, 0.65, 0.20)
	brass_mat.emission_enabled = true
	brass_mat.emission = Color(0.85, 0.65, 0.20)
	brass_mat.emission_energy_multiplier = 0.65
	brass_mat.metallic = 0.95
	brass_mat.roughness = 0.30
	glass.material_override = brass_mat
	glass.position = Vector3(0.40, 0.85, 0.20)
	glass.rotation_degrees = Vector3(0, 0, 90)
	npc.add_child(glass)
	var handle: MeshInstance3D = MeshInstance3D.new()
	var hmm: CylinderMesh = CylinderMesh.new()
	hmm.top_radius = 0.018
	hmm.bottom_radius = 0.018
	hmm.height = 0.18
	handle.mesh = hmm
	handle.material_override = brass_mat
	handle.position = Vector3(0.55, 0.85, 0.20)
	handle.rotation_degrees = Vector3(0, 0, 90)
	npc.add_child(handle)


static func _build_d8_mines(geom: Node) -> void:
	## Epic-8 T40: 3 floating warning sea mines — round dark spheres with
	## metal spikes + small red glowing fuse.
	var mines: Node3D = Node3D.new()
	mines.name = "SeaMines"
	mines.position = Vector3(D8_CENTER.x + 18.0, 1.20, 14.0)
	geom.add_child(mines)
	var dark_mat: StandardMaterial3D = StandardMaterial3D.new()
	dark_mat.albedo_color = Color(0.20, 0.20, 0.25)
	dark_mat.metallic = 0.85
	dark_mat.roughness = 0.40
	for i in 3:
		var mine: Node3D = Node3D.new()
		mine.position = Vector3(i * 2.40, 0, 0)
		mines.add_child(mine)
		# Round body
		var body: MeshInstance3D = MeshInstance3D.new()
		var bm: SphereMesh = SphereMesh.new()
		bm.radius = 0.40
		bm.height = 0.65
		body.mesh = bm
		body.material_override = dark_mat
		mine.add_child(body)
		# 8 spikes radiating
		for j in 8:
			var ang: float = (TAU / 8.0) * j
			var spike: MeshInstance3D = MeshInstance3D.new()
			var sm: PrismMesh = PrismMesh.new()
			sm.size = Vector3(0.06, 0.30, 0.06)
			spike.mesh = sm
			spike.material_override = dark_mat
			spike.position = Vector3(cos(ang) * 0.45, 0, sin(ang) * 0.45)
			spike.rotation = Vector3(0, ang, deg_to_rad(90 if cos(ang) >= 0 else -90))
			mine.add_child(spike)
		# Small red fuse light
		var fuse: MeshInstance3D = MeshInstance3D.new()
		var fm: SphereMesh = SphereMesh.new()
		fm.radius = 0.06
		fm.height = 0.10
		fuse.mesh = fm
		var fuse_mat: StandardMaterial3D = StandardMaterial3D.new()
		fuse_mat.albedo_color = Color(0.95, 0.20, 0.20)
		fuse_mat.emission_enabled = true
		fuse_mat.emission = Color(0.95, 0.20, 0.20)
		fuse_mat.emission_energy_multiplier = 4.0
		fuse_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		fuse.material_override = fuse_mat
		fuse.position = Vector3(0, 0.45, 0)
		mine.add_child(fuse)
		# Fuse blink
		var tw: Tween = fuse.create_tween().set_loops()
		tw.tween_interval(i * 0.20)
		tw.tween_property(fuse, "scale", Vector3.ONE * 1.40, 0.30)
		tw.tween_property(fuse, "scale", Vector3.ONE * 0.55, 0.30)
		# Bob tween
		var twb: Tween = mine.create_tween().set_loops()
		twb.tween_property(mine, "position:y", 0.18, 1.6)
		twb.tween_property(mine, "position:y", 0.0, 1.6)


static func _build_d8_warship(geom: Node) -> void:
	## Epic-8 T41: large naval warship — long hull + 3 masts + cannon
	## ports along the side + decorative bow.
	var ship: Node3D = Node3D.new()
	ship.name = "Warship"
	ship.position = Vector3(D8_CENTER.x - 4.0, 0.30, -16.0)
	geom.add_child(ship)
	var dark_wood: StandardMaterial3D = StandardMaterial3D.new()
	dark_wood.albedo_color = Color(0.30, 0.18, 0.08)
	dark_wood.roughness = 0.92
	var wood_mat: StandardMaterial3D = StandardMaterial3D.new()
	wood_mat.albedo_color = Color(0.45, 0.28, 0.12)
	wood_mat.roughness = 0.85
	# Long hull
	var hull: MeshInstance3D = MeshInstance3D.new()
	var hm: BoxMesh = BoxMesh.new()
	hm.size = Vector3(8.50, 1.85, 2.85)
	hull.mesh = hm
	hull.material_override = dark_wood
	hull.position = Vector3(0, 0.92, 0)
	ship.add_child(hull)
	# Pointed bow
	var bow: MeshInstance3D = MeshInstance3D.new()
	var bwm: PrismMesh = PrismMesh.new()
	bwm.size = Vector3(2.85, 1.85, 1.40)
	bow.mesh = bwm
	bow.material_override = dark_wood
	bow.position = Vector3(5.40, 0.92, 0)
	bow.rotation_degrees = Vector3(0, 0, -90)
	ship.add_child(bow)
	# Upper deck
	var deck: MeshInstance3D = MeshInstance3D.new()
	var dm: BoxMesh = BoxMesh.new()
	dm.size = Vector3(8.0, 0.30, 2.40)
	deck.mesh = dm
	deck.material_override = wood_mat
	deck.position = Vector3(0, 2.0, 0)
	ship.add_child(deck)
	# 3 cannon ports along the side
	var dark_mat: StandardMaterial3D = StandardMaterial3D.new()
	dark_mat.albedo_color = Color(0.05, 0.04, 0.05)
	dark_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for i in 3:
		var port: MeshInstance3D = MeshInstance3D.new()
		var pmm: BoxMesh = BoxMesh.new()
		pmm.size = Vector3(0.55, 0.55, 0.06)
		port.mesh = pmm
		port.material_override = dark_mat
		port.position = Vector3(-2.40 + i * 2.40, 1.20, 1.45)
		ship.add_child(port)
	# 3 tall masts
	for sx in [-2.85, 0.0, 2.85]:
		var mast: MeshInstance3D = MeshInstance3D.new()
		var mm: CylinderMesh = CylinderMesh.new()
		mm.top_radius = 0.10
		mm.bottom_radius = 0.18
		mm.height = 6.85
		mast.mesh = mm
		mast.material_override = dark_wood
		mast.position = Vector3(sx, 5.40, 0)
		ship.add_child(mast)
		# Sail (large white box)
		var sail: MeshInstance3D = MeshInstance3D.new()
		var sm: BoxMesh = BoxMesh.new()
		sm.size = Vector3(1.85, 2.85, 0.10)
		sail.mesh = sm
		var sail_mat: StandardMaterial3D = StandardMaterial3D.new()
		sail_mat.albedo_color = Color(0.92, 0.92, 0.85)
		sail_mat.roughness = 0.85
		sail.material_override = sail_mat
		sail.position = Vector3(sx, 5.40, 0)
		ship.add_child(sail)
	# Bobbing tween
	var tw: Tween = ship.create_tween().set_loops()
	tw.tween_property(ship, "position:y", 0.45, 1.8)
	tw.tween_property(ship, "position:y", 0.30, 1.8)
	# Hull collision
	var sb: StaticBody3D = StaticBody3D.new()
	sb.position = Vector3(0, 0.92, 0)
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(11.0, 1.85, 2.85)
	cs.shape = cb
	sb.add_child(cs)
	ship.add_child(sb)


static func _build_d8_navy_captain_npc(town: Node) -> void:
	## Epic-8 T42: navy captain NPC — formal navy uniform + bicorne hat +
	## held cutlass.
	var npc_slots: Node3D = town.get_node_or_null("%NPCSlots") as Node3D
	if npc_slots == null:
		return
	var slot: Marker3D = Marker3D.new()
	slot.name = "NavyCaptainSlot"
	slot.position = Vector3(D8_CENTER.x - 8.0, 0.0, -8.0)
	npc_slots.add_child(slot)
	var npc_scene: PackedScene = load("res://scenes/entities/npcs/VillagerR3.tscn") as PackedScene
	if npc_scene == null:
		return
	var npc: Node3D = npc_scene.instantiate() as Node3D
	npc.name = "NavyCaptain"
	if "npc_name" in npc:
		npc.set("npc_name", "Riptide")
	if "npc_id" in npc:
		npc.set("npc_id", "navy_captain_d8")
	slot.add_child(npc)
	# Navy uniform
	var coat: MeshInstance3D = MeshInstance3D.new()
	var cm: BoxMesh = BoxMesh.new()
	cm.size = Vector3(0.65, 1.20, 0.45)
	coat.mesh = cm
	var coat_mat: StandardMaterial3D = StandardMaterial3D.new()
	coat_mat.albedo_color = Color(0.10, 0.20, 0.55)
	coat_mat.metallic = 0.30
	coat_mat.roughness = 0.55
	coat.material_override = coat_mat
	coat.position = Vector3(0, 0.60, 0)
	npc.add_child(coat)
	# Gold trim down the front
	var trim: MeshInstance3D = MeshInstance3D.new()
	var tm: BoxMesh = BoxMesh.new()
	tm.size = Vector3(0.06, 1.10, 0.04)
	trim.mesh = tm
	var gold_mat: StandardMaterial3D = StandardMaterial3D.new()
	gold_mat.albedo_color = Color(1.0, 0.85, 0.30)
	gold_mat.emission_enabled = true
	gold_mat.emission = Color(1.0, 0.75, 0.20)
	gold_mat.emission_energy_multiplier = 0.85
	gold_mat.metallic = 0.95
	trim.material_override = gold_mat
	trim.position = Vector3(0, 0.60, 0.24)
	npc.add_child(trim)
	# Bicorne hat (2 angled brim pieces)
	var hat_mat: StandardMaterial3D = StandardMaterial3D.new()
	hat_mat.albedo_color = Color(0.10, 0.20, 0.55)
	hat_mat.metallic = 0.30
	for sz in [-1, 1]:
		var brim: MeshInstance3D = MeshInstance3D.new()
		var brm: BoxMesh = BoxMesh.new()
		brm.size = Vector3(0.18, 0.04, 0.42)
		brim.mesh = brm
		brim.material_override = hat_mat
		brim.position = Vector3(0, 1.55, sz * 0.18)
		brim.rotation_degrees = Vector3(0, 0, sz * 25.0)
		npc.add_child(brim)
	# Cutlass (curved blade simulated with prism + handle)
	var blade: MeshInstance3D = MeshInstance3D.new()
	var blm: PrismMesh = PrismMesh.new()
	blm.size = Vector3(0.06, 0.85, 0.06)
	blade.mesh = blm
	var blade_mat: StandardMaterial3D = StandardMaterial3D.new()
	blade_mat.albedo_color = Color(0.85, 0.92, 1.0)
	blade_mat.metallic = 0.95
	blade_mat.roughness = 0.05
	blade.material_override = blade_mat
	blade.position = Vector3(0.45, 1.0, 0.20)
	blade.rotation_degrees = Vector3(0, 0, -25)
	npc.add_child(blade)


static func _build_d8_cannons_row(geom: Node) -> void:
	## Epic-8 T43: row of 4 dock cannons — dark metal barrels on wooden
	## carriages.
	var cannons: Node3D = Node3D.new()
	cannons.name = "CannonsRow"
	cannons.position = Vector3(D8_CENTER.x + 14.0, 0.0, -22.0)
	geom.add_child(cannons)
	var iron_mat: StandardMaterial3D = StandardMaterial3D.new()
	iron_mat.albedo_color = Color(0.18, 0.16, 0.20)
	iron_mat.metallic = 0.85
	iron_mat.roughness = 0.40
	var wood_mat: StandardMaterial3D = StandardMaterial3D.new()
	wood_mat.albedo_color = Color(0.45, 0.28, 0.12)
	wood_mat.roughness = 0.85
	for i in 4:
		var cannon: Node3D = Node3D.new()
		cannon.position = Vector3(i * 1.85, 0, 0)
		cannons.add_child(cannon)
		# Wooden carriage base
		var carriage: MeshInstance3D = MeshInstance3D.new()
		var cm: BoxMesh = BoxMesh.new()
		cm.size = Vector3(0.85, 0.40, 0.85)
		carriage.mesh = cm
		carriage.material_override = wood_mat
		carriage.position = Vector3(0, 0.20, 0)
		cannon.add_child(carriage)
		# 2 wheels
		for sx in [-0.40, 0.40]:
			var wheel: MeshInstance3D = MeshInstance3D.new()
			var wm: CylinderMesh = CylinderMesh.new()
			wm.top_radius = 0.20
			wm.bottom_radius = 0.20
			wm.height = 0.10
			wheel.mesh = wm
			wheel.material_override = wood_mat
			wheel.position = Vector3(sx, 0.20, 0.40)
			wheel.rotation_degrees = Vector3(0, 0, 90)
			cannon.add_child(wheel)
		# Iron cannon barrel (long cylinder)
		var barrel: MeshInstance3D = MeshInstance3D.new()
		var brm: CylinderMesh = CylinderMesh.new()
		brm.top_radius = 0.14
		brm.bottom_radius = 0.18
		brm.height = 1.10
		barrel.mesh = brm
		barrel.material_override = iron_mat
		barrel.position = Vector3(0, 0.65, 0.30)
		barrel.rotation_degrees = Vector3(75, 0, 0)
		cannon.add_child(barrel)
		# Cannon collision
		var sb: StaticBody3D = StaticBody3D.new()
		sb.position = Vector3(0, 0.42, 0)
		var cs: CollisionShape3D = CollisionShape3D.new()
		var cb: BoxShape3D = BoxShape3D.new()
		cb.size = Vector3(0.85, 0.85, 1.10)
		cs.shape = cb
		sb.add_child(cs)
		cannon.add_child(sb)


static func _build_d8_gunpowder_barrels(geom: Node) -> void:
	## Epic-8 T44: stack of 4 gunpowder barrels with red warning markings.
	var barrels: Node3D = Node3D.new()
	barrels.name = "GunpowderBarrels"
	barrels.position = Vector3(D8_CENTER.x + 22.0, 0.0, -22.0)
	geom.add_child(barrels)
	var wood_mat: StandardMaterial3D = StandardMaterial3D.new()
	wood_mat.albedo_color = Color(0.45, 0.28, 0.12)
	wood_mat.roughness = 0.92
	var hoop_mat: StandardMaterial3D = StandardMaterial3D.new()
	hoop_mat.albedo_color = Color(0.20, 0.18, 0.20)
	hoop_mat.metallic = 0.85
	var warning_mat: StandardMaterial3D = StandardMaterial3D.new()
	warning_mat.albedo_color = Color(0.85, 0.20, 0.20)
	warning_mat.emission_enabled = true
	warning_mat.emission = Color(0.85, 0.20, 0.20)
	warning_mat.emission_energy_multiplier = 1.4
	warning_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var positions: Array = [
		Vector3(-0.55, 0.42, 0),
		Vector3( 0.55, 0.42, 0),
		Vector3(-0.55, 0.42, 0.85),
		Vector3( 0.55, 0.42, 0.85),
	]
	for p in positions:
		var barrel: MeshInstance3D = MeshInstance3D.new()
		var bm: CylinderMesh = CylinderMesh.new()
		bm.top_radius = 0.30
		bm.bottom_radius = 0.30
		bm.height = 0.85
		barrel.mesh = bm
		barrel.material_override = wood_mat
		barrel.position = p
		barrels.add_child(barrel)
		# 2 hoops
		for hy in [-0.30, 0.30]:
			var hoop: MeshInstance3D = MeshInstance3D.new()
			var hmm: CylinderMesh = CylinderMesh.new()
			hmm.top_radius = 0.32
			hmm.bottom_radius = 0.32
			hmm.height = 0.04
			hoop.mesh = hmm
			hoop.material_override = hoop_mat
			hoop.position = Vector3(p.x, p.y + hy, p.z)
			barrels.add_child(hoop)
		# Red warning X on the front
		var warning: MeshInstance3D = MeshInstance3D.new()
		var wm: BoxMesh = BoxMesh.new()
		wm.size = Vector3(0.30, 0.06, 0.04)
		warning.mesh = wm
		warning.material_override = warning_mat
		warning.position = Vector3(p.x, p.y, p.z + 0.32)
		barrels.add_child(warning)
	# Group collision
	var sb: StaticBody3D = StaticBody3D.new()
	sb.position = Vector3(0, 0.42, 0.42)
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(1.40, 0.85, 1.40)
	cs.shape = cb
	sb.add_child(cs)
	barrels.add_child(sb)


static func _build_d8_lifeguard_tower(geom: Node) -> void:
	## Epic-8 T45: small wooden lifeguard tower — elevated platform on
	## angled posts + sloped roof + warning sign.
	var tower: Node3D = Node3D.new()
	tower.name = "LifeguardTower"
	tower.position = Vector3(D8_CENTER.x + 4.0, 0.0, 18.0)
	geom.add_child(tower)
	var wood_mat: StandardMaterial3D = StandardMaterial3D.new()
	wood_mat.albedo_color = Color(0.85, 0.55, 0.20)
	wood_mat.emission_enabled = true
	wood_mat.emission = Color(0.95, 0.55, 0.10)
	wood_mat.emission_energy_multiplier = 0.30
	wood_mat.roughness = 0.85
	var dark_wood: StandardMaterial3D = StandardMaterial3D.new()
	dark_wood.albedo_color = Color(0.45, 0.28, 0.12)
	dark_wood.roughness = 0.85
	# 4 angled support posts
	for sx in [-0.85, 0.85]:
		for sz in [-0.85, 0.85]:
			var post: MeshInstance3D = MeshInstance3D.new()
			var pm: BoxMesh = BoxMesh.new()
			pm.size = Vector3(0.18, 2.40, 0.18)
			post.mesh = pm
			post.material_override = dark_wood
			post.position = Vector3(sx, 1.20, sz)
			tower.add_child(post)
	# Elevated platform
	var platform: MeshInstance3D = MeshInstance3D.new()
	var pmm: BoxMesh = BoxMesh.new()
	pmm.size = Vector3(2.20, 0.20, 2.20)
	platform.mesh = pmm
	platform.material_override = wood_mat
	platform.position = Vector3(0, 2.40, 0)
	tower.add_child(platform)
	# 3 walls (side walls + back, leaving the front open)
	for w in [
		{"size": Vector3(2.20, 1.40, 0.10), "pos": Vector3(0, 3.20, -1.05)},
		{"size": Vector3(0.10, 1.40, 2.20), "pos": Vector3(-1.05, 3.20, 0)},
		{"size": Vector3(0.10, 1.40, 2.20), "pos": Vector3( 1.05, 3.20, 0)},
	]:
		var wall: MeshInstance3D = MeshInstance3D.new()
		var wm: BoxMesh = BoxMesh.new()
		wm.size = w["size"]
		wall.mesh = wm
		wall.material_override = wood_mat
		wall.position = w["pos"]
		tower.add_child(wall)
	# Sloped roof
	var roof: MeshInstance3D = MeshInstance3D.new()
	var rm: PrismMesh = PrismMesh.new()
	rm.size = Vector3(2.40, 0.55, 2.40)
	roof.mesh = rm
	roof.material_override = dark_wood
	roof.position = Vector3(0, 4.20, 0)
	tower.add_child(roof)
	# Tower collision
	var sb: StaticBody3D = StaticBody3D.new()
	sb.position = Vector3(0, 2.50, 0)
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(2.20, 4.85, 2.20)
	cs.shape = cb
	sb.add_child(cs)
	tower.add_child(sb)


static func _build_d8_pirate_flag(geom: Node) -> void:
	## Epic-8 T46: tall pirate flag pole — black skull and crossbones flag
	## flying high, marking pirate territory.
	var flag: Node3D = Node3D.new()
	flag.name = "PirateFlag"
	flag.position = Vector3(D8_CENTER.x + 4.0, 0.0, -22.0)
	geom.add_child(flag)
	var wood_mat: StandardMaterial3D = StandardMaterial3D.new()
	wood_mat.albedo_color = Color(0.30, 0.18, 0.08)
	wood_mat.roughness = 0.92
	# Tall pole
	var pole: MeshInstance3D = MeshInstance3D.new()
	var pm: CylinderMesh = CylinderMesh.new()
	pm.top_radius = 0.10
	pm.bottom_radius = 0.18
	pm.height = 6.85
	pole.mesh = pm
	pole.material_override = wood_mat
	pole.position = Vector3(0, 3.42, 0)
	flag.add_child(pole)
	# Pole collision
	var sb: StaticBody3D = StaticBody3D.new()
	sb.position = Vector3(0, 3.42, 0)
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cap: CapsuleShape3D = CapsuleShape3D.new()
	cap.radius = 0.18
	cap.height = 6.85
	cs.shape = cap
	sb.add_child(cs)
	flag.add_child(sb)
	# Black flag cloth
	var cloth: MeshInstance3D = MeshInstance3D.new()
	var cm: BoxMesh = BoxMesh.new()
	cm.size = Vector3(2.40, 1.40, 0.06)
	cloth.mesh = cm
	var cloth_mat: StandardMaterial3D = StandardMaterial3D.new()
	cloth_mat.albedo_color = Color(0.05, 0.04, 0.08)
	cloth_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	cloth.material_override = cloth_mat
	cloth.position = Vector3(1.20, 5.85, 0)
	flag.add_child(cloth)
	# White skull (sphere)
	var skull: MeshInstance3D = MeshInstance3D.new()
	var skm: SphereMesh = SphereMesh.new()
	skm.radius = 0.30
	skm.height = 0.45
	skull.mesh = skm
	var white_mat: StandardMaterial3D = StandardMaterial3D.new()
	white_mat.albedo_color = Color(0.95, 0.95, 0.92)
	white_mat.emission_enabled = true
	white_mat.emission = Color(0.95, 0.95, 0.92)
	white_mat.emission_energy_multiplier = 0.85
	skull.material_override = white_mat
	skull.position = Vector3(1.20, 6.0, 0.10)
	flag.add_child(skull)
	# Crossbones (2 small white bars)
	for i in 2:
		var bone: MeshInstance3D = MeshInstance3D.new()
		var bmm: BoxMesh = BoxMesh.new()
		bmm.size = Vector3(0.55, 0.06, 0.04)
		bone.mesh = bmm
		bone.material_override = white_mat
		bone.position = Vector3(1.20, 5.55, 0.10)
		bone.rotation_degrees = Vector3(0, 0, 45.0 if i == 0 else -45.0)
		flag.add_child(bone)
	# Subtle flag wave
	var tw: Tween = cloth.create_tween().set_loops()
	tw.tween_property(cloth, "rotation_degrees:y", 6.0, 1.4)
	tw.tween_property(cloth, "rotation_degrees:y", -6.0, 1.4)


static func _build_d8_pirate_captain_npc(town: Node) -> void:
	## Epic-8 T47: pirate captain NPC — long red coat + tricorn hat +
	## peg leg + held cutlass.
	var npc_slots: Node3D = town.get_node_or_null("%NPCSlots") as Node3D
	if npc_slots == null:
		return
	var slot: Marker3D = Marker3D.new()
	slot.name = "PirateCaptainSlot"
	slot.position = Vector3(D8_CENTER.x + 6.0, 0.0, -22.0)
	npc_slots.add_child(slot)
	var npc_scene: PackedScene = load("res://scenes/entities/npcs/VillagerR3.tscn") as PackedScene
	if npc_scene == null:
		return
	var npc: Node3D = npc_scene.instantiate() as Node3D
	npc.name = "PirateCaptain"
	if "npc_name" in npc:
		npc.set("npc_name", "Blackcurrent")
	if "npc_id" in npc:
		npc.set("npc_id", "pirate_captain_d8")
	slot.add_child(npc)
	# Long red coat
	var coat: MeshInstance3D = MeshInstance3D.new()
	var cm: BoxMesh = BoxMesh.new()
	cm.size = Vector3(0.75, 1.30, 0.50)
	coat.mesh = cm
	var coat_mat: StandardMaterial3D = StandardMaterial3D.new()
	coat_mat.albedo_color = Color(0.65, 0.10, 0.10)
	coat_mat.metallic = 0.30
	coat_mat.roughness = 0.55
	coat.material_override = coat_mat
	coat.position = Vector3(0, 0.65, 0)
	npc.add_child(coat)
	# Tricorn hat
	var hat_mat: StandardMaterial3D = StandardMaterial3D.new()
	hat_mat.albedo_color = Color(0.10, 0.08, 0.10)
	hat_mat.metallic = 0.30
	for i in 3:
		var ang: float = (TAU / 3.0) * i
		var brim: MeshInstance3D = MeshInstance3D.new()
		var brm: BoxMesh = BoxMesh.new()
		brm.size = Vector3(0.40, 0.04, 0.18)
		brim.mesh = brm
		brim.material_override = hat_mat
		brim.position = Vector3(cos(ang) * 0.18, 1.45, sin(ang) * 0.18)
		brim.rotation = Vector3(0, -ang + PI * 0.5, 0)
		npc.add_child(brim)
	var dome: MeshInstance3D = MeshInstance3D.new()
	var dmm: SphereMesh = SphereMesh.new()
	dmm.radius = 0.20
	dmm.height = 0.30
	dome.mesh = dmm
	dome.material_override = hat_mat
	dome.position = Vector3(0, 1.55, 0)
	dome.scale = Vector3(1.0, 0.85, 1.0)
	npc.add_child(dome)
	# Peg leg (small wooden cylinder where right leg should be)
	var peg: MeshInstance3D = MeshInstance3D.new()
	var pgm: CylinderMesh = CylinderMesh.new()
	pgm.top_radius = 0.05
	pgm.bottom_radius = 0.08
	pgm.height = 0.55
	peg.mesh = pgm
	var wood_mat: StandardMaterial3D = StandardMaterial3D.new()
	wood_mat.albedo_color = Color(0.45, 0.28, 0.12)
	peg.material_override = wood_mat
	peg.position = Vector3(0.18, 0.18, 0)
	npc.add_child(peg)
	# Cutlass (curved blade)
	var blade: MeshInstance3D = MeshInstance3D.new()
	var blm: PrismMesh = PrismMesh.new()
	blm.size = Vector3(0.06, 0.85, 0.06)
	blade.mesh = blm
	var blade_mat: StandardMaterial3D = StandardMaterial3D.new()
	blade_mat.albedo_color = Color(0.85, 0.92, 1.0)
	blade_mat.metallic = 0.95
	blade_mat.roughness = 0.05
	blade.material_override = blade_mat
	blade.position = Vector3(0.45, 1.0, 0.20)
	blade.rotation_degrees = Vector3(0, 0, -25)
	npc.add_child(blade)


static func _build_d8_pirate_crew(geom: Node) -> void:
	## Epic-8 T48: 3 pirate crew member figures with bandanas + striped shirts.
	var crew: Node3D = Node3D.new()
	crew.name = "PirateCrew"
	crew.position = Vector3(D8_CENTER.x + 8.0, 0.0, -22.0)
	geom.add_child(crew)
	var stripe_colors: Array = [
		Color(0.85, 0.20, 0.30),
		Color(0.20, 0.30, 0.55),
		Color(0.30, 0.65, 0.30),
	]
	var bandana_colors: Array = [
		Color(0.85, 0.20, 0.20),
		Color(0.20, 0.30, 0.85),
		Color(0.95, 0.85, 0.20),
	]
	var positions: Array = [
		Vector3( 0.0, 0,  0.0),
		Vector3( 1.40, 0,  0.85),
		Vector3(-1.20, 0,  0.55),
	]
	for i in 3:
		var pirate: Node3D = Node3D.new()
		pirate.position = positions[i]
		crew.add_child(pirate)
		# Body shirt
		var body: MeshInstance3D = MeshInstance3D.new()
		var bm: BoxMesh = BoxMesh.new()
		bm.size = Vector3(0.55, 1.05, 0.40)
		body.mesh = bm
		var body_mat: StandardMaterial3D = StandardMaterial3D.new()
		body_mat.albedo_color = stripe_colors[i]
		body_mat.emission_enabled = true
		body_mat.emission = stripe_colors[i]
		body_mat.emission_energy_multiplier = 0.30
		body.material_override = body_mat
		body.position = Vector3(0, 0.55, 0)
		pirate.add_child(body)
		# 2 white horizontal stripes
		var stripe_mat: StandardMaterial3D = StandardMaterial3D.new()
		stripe_mat.albedo_color = Color(0.95, 0.95, 0.92)
		for sy in [0.45, 0.65]:
			var stripe: MeshInstance3D = MeshInstance3D.new()
			var stm: BoxMesh = BoxMesh.new()
			stm.size = Vector3(0.55, 0.06, 0.06)
			stripe.mesh = stm
			stripe.material_override = stripe_mat
			stripe.position = Vector3(0, sy, 0.21)
			pirate.add_child(stripe)
		# Head
		var head: MeshInstance3D = MeshInstance3D.new()
		var hm: SphereMesh = SphereMesh.new()
		hm.radius = 0.18
		hm.height = 0.32
		head.mesh = hm
		var skin_mat: StandardMaterial3D = StandardMaterial3D.new()
		skin_mat.albedo_color = Color(0.95, 0.85, 0.75)
		head.material_override = skin_mat
		head.position = Vector3(0, 1.20, 0)
		pirate.add_child(head)
		# Bandana on top
		var bandana: MeshInstance3D = MeshInstance3D.new()
		var bdm: CylinderMesh = CylinderMesh.new()
		bdm.top_radius = 0.20
		bdm.bottom_radius = 0.20
		bdm.height = 0.10
		bandana.mesh = bdm
		var bandana_mat: StandardMaterial3D = StandardMaterial3D.new()
		bandana_mat.albedo_color = bandana_colors[i]
		bandana_mat.emission_enabled = true
		bandana_mat.emission = bandana_colors[i]
		bandana_mat.emission_energy_multiplier = 0.85
		bandana.material_override = bandana_mat
		bandana.position = Vector3(0, 1.30, 0)
		pirate.add_child(bandana)


static func _build_d8_parrots(geom: Node) -> void:
	## Epic-8 T49: 3 colorful parrots perched on small wooden posts.
	var parrots: Node3D = Node3D.new()
	parrots.name = "Parrots"
	parrots.position = Vector3(D8_CENTER.x + 12.0, 0.0, -22.0)
	geom.add_child(parrots)
	var wood_mat: StandardMaterial3D = StandardMaterial3D.new()
	wood_mat.albedo_color = Color(0.45, 0.28, 0.12)
	wood_mat.roughness = 0.85
	var parrot_colors: Array = [
		Color(0.95, 0.20, 0.20),
		Color(0.20, 0.65, 0.95),
		Color(0.30, 0.95, 0.30),
	]
	for i in 3:
		var perch: Node3D = Node3D.new()
		perch.position = Vector3(i * 1.40, 0, 0)
		parrots.add_child(perch)
		# Wooden perch post
		var post: MeshInstance3D = MeshInstance3D.new()
		var pm: CylinderMesh = CylinderMesh.new()
		pm.top_radius = 0.06
		pm.bottom_radius = 0.10
		pm.height = 1.85
		post.mesh = pm
		post.material_override = wood_mat
		post.position = Vector3(0, 0.92, 0)
		perch.add_child(post)
		# Parrot body
		var body: MeshInstance3D = MeshInstance3D.new()
		var bm: SphereMesh = SphereMesh.new()
		bm.radius = 0.18
		bm.height = 0.32
		body.mesh = bm
		var body_mat: StandardMaterial3D = StandardMaterial3D.new()
		body_mat.albedo_color = parrot_colors[i]
		body_mat.emission_enabled = true
		body_mat.emission = parrot_colors[i]
		body_mat.emission_energy_multiplier = 0.85
		body.material_override = body_mat
		body.position = Vector3(0, 2.0, 0)
		body.scale = Vector3(0.85, 1.0, 1.30)
		perch.add_child(body)
		# Beak (small yellow prism)
		var beak: MeshInstance3D = MeshInstance3D.new()
		var bkm: PrismMesh = PrismMesh.new()
		bkm.size = Vector3(0.05, 0.05, 0.10)
		beak.mesh = bkm
		var beak_mat: StandardMaterial3D = StandardMaterial3D.new()
		beak_mat.albedo_color = Color(0.95, 0.85, 0.20)
		beak.material_override = beak_mat
		beak.position = Vector3(0, 2.0, 0.20)
		beak.rotation_degrees = Vector3(90, 0, 0)
		perch.add_child(beak)
		# Tail (small contrasting prism)
		var tail: MeshInstance3D = MeshInstance3D.new()
		var tm: PrismMesh = PrismMesh.new()
		tm.size = Vector3(0.10, 0.30, 0.06)
		tail.mesh = tm
		var tail_mat: StandardMaterial3D = StandardMaterial3D.new()
		tail_mat.albedo_color = parrot_colors[(i + 1) % 3]
		tail_mat.emission_enabled = true
		tail_mat.emission = parrot_colors[(i + 1) % 3]
		tail_mat.emission_energy_multiplier = 0.85
		tail.material_override = tail_mat
		tail.position = Vector3(0, 1.85, -0.20)
		tail.rotation_degrees = Vector3(-25, 0, 0)
		perch.add_child(tail)
		# Slow head bob
		var tw: Tween = body.create_tween().set_loops()
		tw.tween_interval(i * 0.20)
		tw.tween_property(body, "position:y", 2.10, 0.55)
		tw.tween_property(body, "position:y", 2.0, 0.55)


static func _build_d8_sea_tyrant(geom: Node) -> void:
	## Epic-8 T50: SEA TYRANT — D8 mid-boss landmark. Massive dark sea
	## monster figurehead with multiple tentacles, glowing red eyes, and
	## a halo of orbiting jellyfish.
	var tyrant: Node3D = Node3D.new()
	tyrant.name = "SeaTyrant"
	tyrant.position = Vector3(D8_CENTER.x + 22.0, 0.0, -22.0)
	geom.add_child(tyrant)
	var dark_mat: StandardMaterial3D = StandardMaterial3D.new()
	dark_mat.albedo_color = Color(0.15, 0.20, 0.25)
	dark_mat.metallic = 0.55
	dark_mat.roughness = 0.45
	var darker_mat: StandardMaterial3D = StandardMaterial3D.new()
	darker_mat.albedo_color = Color(0.10, 0.15, 0.20)
	darker_mat.metallic = 0.55
	darker_mat.roughness = 0.45
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.30, 0.35, 0.40)
	stone_mat.metallic = 0.65
	# Stone pedestal
	var ped: MeshInstance3D = MeshInstance3D.new()
	var pm: BoxMesh = BoxMesh.new()
	pm.size = Vector3(4.20, 0.55, 4.20)
	ped.mesh = pm
	ped.material_override = stone_mat
	ped.position = Vector3(0, 0.27, 0)
	tyrant.add_child(ped)
	# Massive body (large flat sphere)
	var body: MeshInstance3D = MeshInstance3D.new()
	var bm: SphereMesh = SphereMesh.new()
	bm.radius = 2.40
	bm.height = 3.40
	body.mesh = bm
	body.material_override = dark_mat
	body.position = Vector3(0, 2.40, 0)
	body.scale = Vector3(1.20, 1.0, 1.40)
	tyrant.add_child(body)
	# 8 large tentacles emerging from the body
	for i in 8:
		var ang: float = (TAU / 8.0) * i
		var tentacle: MeshInstance3D = MeshInstance3D.new()
		var tm: CylinderMesh = CylinderMesh.new()
		tm.top_radius = 0.30
		tm.bottom_radius = 0.85
		tm.height = 5.50 + (i % 4) * 1.40
		tentacle.mesh = tm
		tentacle.material_override = darker_mat
		tentacle.position = Vector3(cos(ang) * 1.85, 4.0 + (i % 4) * 1.10, sin(ang) * 1.85)
		tentacle.rotation = Vector3(deg_to_rad(20) * sin(ang), 0, deg_to_rad(20) * cos(ang))
		tyrant.add_child(tentacle)
		# Wave tween
		var tw: Tween = tentacle.create_tween().set_loops()
		tw.tween_interval(i * 0.15)
		tw.tween_property(tentacle, "rotation_degrees:z", 8.0, 1.6)
		tw.tween_property(tentacle, "rotation_degrees:z", -8.0, 1.6)
	# 3 glowing red eyes on the body
	var eye_mat: StandardMaterial3D = StandardMaterial3D.new()
	eye_mat.albedo_color = Color(1.0, 0.20, 0.20)
	eye_mat.emission_enabled = true
	eye_mat.emission = Color(1.0, 0.10, 0.10)
	eye_mat.emission_energy_multiplier = 5.0
	eye_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for i in 3:
		var ang: float = (TAU / 3.0) * i + PI * 0.5
		var eye: MeshInstance3D = MeshInstance3D.new()
		var em: SphereMesh = SphereMesh.new()
		em.radius = 0.30
		em.height = 0.55
		eye.mesh = em
		eye.material_override = eye_mat
		eye.position = Vector3(cos(ang) * 1.40, 2.85, sin(ang) * 1.40 + 1.85)
		tyrant.add_child(eye)
		# Pulse
		var twe: Tween = eye.create_tween().set_loops()
		twe.tween_interval(i * 0.30)
		twe.tween_property(eye, "scale", Vector3.ONE * 1.30, 0.85)
		twe.tween_property(eye, "scale", Vector3.ONE * 0.85, 0.85)
	# Halo of 8 orbiting jellyfish (small purple spheres)
	var halo: Node3D = Node3D.new()
	halo.position = Vector3(0, 4.85, 0)
	tyrant.add_child(halo)
	var jelly_mat: StandardMaterial3D = StandardMaterial3D.new()
	jelly_mat.albedo_color = Color(0.85, 0.30, 0.95)
	jelly_mat.emission_enabled = true
	jelly_mat.emission = Color(0.95, 0.30, 0.95)
	jelly_mat.emission_energy_multiplier = 3.5
	jelly_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for i in 8:
		var ang: float = (TAU / 8.0) * i
		var jelly: MeshInstance3D = MeshInstance3D.new()
		var jmm: SphereMesh = SphereMesh.new()
		jmm.radius = 0.30
		jmm.height = 0.55
		jelly.mesh = jmm
		jelly.material_override = jelly_mat
		jelly.position = Vector3(cos(ang) * 4.20, 0, sin(ang) * 4.20)
		halo.add_child(jelly)
	var trot: Tween = halo.create_tween().set_loops()
	trot.tween_property(halo, "rotation_degrees:y", 360.0, 14.0)
	trot.tween_property(halo, "rotation_degrees:y", 0.0, 0.0)
	# Massive aura light
	var light: OmniLight3D = OmniLight3D.new()
	light.light_color = Color(0.40, 0.30, 0.95)
	light.light_energy = 5.5
	light.omni_range = 22.0
	light.position = Vector3(0, 4.20, 0)
	tyrant.add_child(light)
	var twl: Tween = light.create_tween().set_loops()
	twl.tween_property(light, "light_energy", 7.0, 2.0)
	twl.tween_property(light, "light_energy", 4.5, 2.0)
	# Title labels
	var title: Label3D = Label3D.new()
	title.text = "THE SEA TYRANT"
	title.modulate = Color(0.85, 0.30, 0.95)
	title.outline_modulate = Color(0.05, 0.10, 0.20)
	title.outline_size = 12
	title.font_size = 80
	title.pixel_size = 0.013
	title.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	title.position = Vector3(0, 9.0, 0)
	tyrant.add_child(title)
	var subtitle: Label3D = Label3D.new()
	subtitle.text = "Devourer of forgotten data"
	subtitle.modulate = Color(0.85, 0.95, 1.0)
	subtitle.outline_modulate = Color(0.05, 0.10, 0.20)
	subtitle.outline_size = 8
	subtitle.font_size = 42
	subtitle.pixel_size = 0.011
	subtitle.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	subtitle.position = Vector3(0, 8.30, 0)
	tyrant.add_child(subtitle)
	# Body collision
	var sb: StaticBody3D = StaticBody3D.new()
	sb.position = Vector3(0, 2.40, 0)
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cap: SphereShape3D = SphereShape3D.new()
	cap.radius = 3.40
	cs.shape = cap
	sb.add_child(cs)
	tyrant.add_child(sb)
	# Pedestal collision
	var psb: StaticBody3D = StaticBody3D.new()
	psb.position = Vector3(0, 0.27, 0)
	var pcs: CollisionShape3D = CollisionShape3D.new()
	var pcb: BoxShape3D = BoxShape3D.new()
	pcb.size = Vector3(4.20, 0.55, 4.20)
	pcs.shape = pcb
	psb.add_child(pcs)
	tyrant.add_child(psb)


static func _build_d8_rowboats(geom: Node) -> void:
	## Epic-8 T51: 4 small rowboats lined up — long curved hulls + 2
	## oars laid across each + bobbing tweens.
	var line: Node3D = Node3D.new()
	line.name = "Rowboats"
	line.position = Vector3(D8_CENTER.x - 22.0, 0.30, 8.0)
	geom.add_child(line)
	var wood_mat: StandardMaterial3D = StandardMaterial3D.new()
	wood_mat.albedo_color = Color(0.45, 0.28, 0.12)
	wood_mat.roughness = 0.85
	for i in 4:
		var boat: Node3D = Node3D.new()
		boat.position = Vector3(0, 0, i * 2.40)
		line.add_child(boat)
		# Long hull (box scaled long)
		var hull: MeshInstance3D = MeshInstance3D.new()
		var hm: BoxMesh = BoxMesh.new()
		hm.size = Vector3(2.40, 0.40, 0.85)
		hull.mesh = hm
		hull.material_override = wood_mat
		hull.position = Vector3(0, 0.20, 0)
		boat.add_child(hull)
		# Pointed ends
		for sx in [-1.40, 1.40]:
			var end: MeshInstance3D = MeshInstance3D.new()
			var em: PrismMesh = PrismMesh.new()
			em.size = Vector3(0.85, 0.40, 0.55)
			end.mesh = em
			end.material_override = wood_mat
			end.position = Vector3(sx, 0.20, 0)
			end.rotation_degrees = Vector3(0, 0, 90.0 if sx > 0 else -90.0)
			boat.add_child(end)
		# 2 oars laid across the boat
		for sz in [-0.30, 0.30]:
			var oar: MeshInstance3D = MeshInstance3D.new()
			var omm: CylinderMesh = CylinderMesh.new()
			omm.top_radius = 0.04
			omm.bottom_radius = 0.04
			omm.height = 1.85
			oar.mesh = omm
			oar.material_override = wood_mat
			oar.position = Vector3(0, 0.45, sz)
			oar.rotation_degrees = Vector3(0, 0, 90)
			boat.add_child(oar)
			# Oar paddle (small flat box)
			var paddle: MeshInstance3D = MeshInstance3D.new()
			var pmm: BoxMesh = BoxMesh.new()
			pmm.size = Vector3(0.30, 0.06, 0.18)
			paddle.mesh = pmm
			paddle.material_override = wood_mat
			paddle.position = Vector3(0.85, 0.45, sz)
			boat.add_child(paddle)
		# Bobbing tween
		var tw: Tween = boat.create_tween().set_loops()
		tw.tween_interval(i * 0.20)
		tw.tween_property(boat, "position:y", 0.18, 1.4)
		tw.tween_property(boat, "position:y", 0.0, 1.4)
		# Boat collision
		var sb: StaticBody3D = StaticBody3D.new()
		sb.position = Vector3(0, 0.20, 0)
		var cs: CollisionShape3D = CollisionShape3D.new()
		var cb: BoxShape3D = BoxShape3D.new()
		cb.size = Vector3(3.40, 0.85, 0.85)
		cs.shape = cb
		sb.add_child(cs)
		boat.add_child(sb)


static func _build_d8_oar_maker_npc(town: Node) -> void:
	## Epic-8 T52: oar maker NPC — leather apron + held wooden oar shaft.
	var npc_slots: Node3D = town.get_node_or_null("%NPCSlots") as Node3D
	if npc_slots == null:
		return
	var slot: Marker3D = Marker3D.new()
	slot.name = "OarMakerSlot"
	slot.position = Vector3(D8_CENTER.x - 18.0, 0.0, 8.0)
	npc_slots.add_child(slot)
	var npc_scene: PackedScene = load("res://scenes/entities/npcs/VillagerR3.tscn") as PackedScene
	if npc_scene == null:
		return
	var npc: Node3D = npc_scene.instantiate() as Node3D
	npc.name = "OarMaker"
	if "npc_name" in npc:
		npc.set("npc_name", "Splinter")
	if "npc_id" in npc:
		npc.set("npc_id", "oar_maker_d8")
	slot.add_child(npc)
	# Apron
	var apron: MeshInstance3D = MeshInstance3D.new()
	var am: BoxMesh = BoxMesh.new()
	am.size = Vector3(0.55, 0.85, 0.06)
	apron.mesh = am
	var apron_mat: StandardMaterial3D = StandardMaterial3D.new()
	apron_mat.albedo_color = Color(0.40, 0.25, 0.12)
	apron_mat.roughness = 0.65
	apron.material_override = apron_mat
	apron.position = Vector3(0, 0.55, 0.22)
	npc.add_child(apron)
	# Held oar (long thin cylinder + paddle)
	var wood_mat: StandardMaterial3D = StandardMaterial3D.new()
	wood_mat.albedo_color = Color(0.45, 0.28, 0.12)
	wood_mat.roughness = 0.85
	var oar: MeshInstance3D = MeshInstance3D.new()
	var om: CylinderMesh = CylinderMesh.new()
	om.top_radius = 0.04
	om.bottom_radius = 0.05
	om.height = 1.85
	oar.mesh = om
	oar.material_override = wood_mat
	oar.position = Vector3(0.45, 1.0, 0.20)
	oar.rotation_degrees = Vector3(0, 0, -25)
	npc.add_child(oar)
	# Paddle blade
	var paddle: MeshInstance3D = MeshInstance3D.new()
	var pmm: BoxMesh = BoxMesh.new()
	pmm.size = Vector3(0.20, 0.04, 0.18)
	paddle.mesh = pmm
	paddle.material_override = wood_mat
	paddle.position = Vector3(1.30, 1.55, 0.20)
	paddle.rotation_degrees = Vector3(0, 0, -25)
	npc.add_child(paddle)


static func _build_d8_fish_market(geom: Node) -> void:
	## Epic-8 T53: fish market stall — wooden counter with displayed fish
	## on ice + colorful awning.
	var market: Node3D = Node3D.new()
	market.name = "FishMarket"
	market.position = Vector3(D8_CENTER.x - 12.0, 0.0, 22.0)
	geom.add_child(market)
	var wood_mat: StandardMaterial3D = StandardMaterial3D.new()
	wood_mat.albedo_color = Color(0.45, 0.28, 0.12)
	wood_mat.roughness = 0.85
	# Counter
	var counter: MeshInstance3D = MeshInstance3D.new()
	var cm: BoxMesh = BoxMesh.new()
	cm.size = Vector3(2.85, 1.0, 1.10)
	counter.mesh = cm
	counter.material_override = wood_mat
	counter.position = Vector3(0, 0.55, 0)
	market.add_child(counter)
	# Slanted blue awning
	var awning: MeshInstance3D = MeshInstance3D.new()
	var amm: BoxMesh = BoxMesh.new()
	amm.size = Vector3(3.20, 0.10, 1.30)
	awning.mesh = amm
	var awning_mat: StandardMaterial3D = StandardMaterial3D.new()
	awning_mat.albedo_color = Color(0.20, 0.55, 0.85)
	awning_mat.emission_enabled = true
	awning_mat.emission = Color(0.20, 0.55, 0.85)
	awning_mat.emission_energy_multiplier = 0.45
	awning.material_override = awning_mat
	awning.position = Vector3(0, 2.20, -0.10)
	awning.rotation_degrees = Vector3(-12, 0, 0)
	market.add_child(awning)
	# 2 awning support posts
	for sx in [-1.20, 1.20]:
		var post: MeshInstance3D = MeshInstance3D.new()
		var pmm: CylinderMesh = CylinderMesh.new()
		pmm.top_radius = 0.05
		pmm.bottom_radius = 0.05
		pmm.height = 1.20
		post.mesh = pmm
		post.material_override = wood_mat
		post.position = Vector3(sx, 1.65, -0.40)
		market.add_child(post)
	# Ice chips on counter
	var ice_mat: StandardMaterial3D = StandardMaterial3D.new()
	ice_mat.albedo_color = Color(0.85, 0.95, 1.0, 0.65)
	ice_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	ice_mat.emission_enabled = true
	ice_mat.emission = Color(0.85, 0.95, 1.0)
	ice_mat.emission_energy_multiplier = 0.85
	for i in 8:
		var ice: MeshInstance3D = MeshInstance3D.new()
		var im: BoxMesh = BoxMesh.new()
		im.size = Vector3(0.18, 0.10, 0.18)
		ice.mesh = im
		ice.material_override = ice_mat
		ice.position = Vector3(
			randf_range(-1.0, 1.0),
			1.10,
			randf_range(-0.40, 0.40)
		)
		market.add_child(ice)
	# 6 displayed fish (silver prisms)
	var fish_mat: StandardMaterial3D = StandardMaterial3D.new()
	fish_mat.albedo_color = Color(0.65, 0.75, 0.85)
	fish_mat.metallic = 0.55
	fish_mat.roughness = 0.30
	for i in 6:
		var fish: MeshInstance3D = MeshInstance3D.new()
		var fmm: PrismMesh = PrismMesh.new()
		fmm.size = Vector3(0.30, 0.10, 0.10)
		fish.mesh = fmm
		fish.material_override = fish_mat
		fish.position = Vector3(
			-0.85 + (i % 3) * 0.85,
			1.18,
			-0.20 + (i / 3) * 0.40
		)
		fish.rotation_degrees = Vector3(0, randf_range(-25, 25), 90)
		market.add_child(fish)
	# Counter collision
	var sb: StaticBody3D = StaticBody3D.new()
	sb.position = Vector3(0, 0.55, 0)
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(2.85, 2.20, 1.10)
	cs.shape = cb
	sb.add_child(cs)
	market.add_child(sb)


static func _build_d8_fishmonger_npc(town: Node) -> void:
	## Epic-8 T54: fishmonger NPC — apron + held large fish.
	var npc_slots: Node3D = town.get_node_or_null("%NPCSlots") as Node3D
	if npc_slots == null:
		return
	var slot: Marker3D = Marker3D.new()
	slot.name = "FishmongerSlot"
	slot.position = Vector3(D8_CENTER.x - 12.0, 0.0, 21.0)
	npc_slots.add_child(slot)
	var npc_scene: PackedScene = load("res://scenes/entities/npcs/VillagerR3.tscn") as PackedScene
	if npc_scene == null:
		return
	var npc: Node3D = npc_scene.instantiate() as Node3D
	npc.name = "Fishmonger"
	if "npc_name" in npc:
		npc.set("npc_name", "Scaler")
	if "npc_id" in npc:
		npc.set("npc_id", "fishmonger_d8")
	slot.add_child(npc)
	# White apron
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
	# Held large fish
	var fish: MeshInstance3D = MeshInstance3D.new()
	var fm: PrismMesh = PrismMesh.new()
	fm.size = Vector3(0.30, 0.18, 0.18)
	fish.mesh = fm
	var fish_mat: StandardMaterial3D = StandardMaterial3D.new()
	fish_mat.albedo_color = Color(0.65, 0.75, 0.85)
	fish_mat.metallic = 0.55
	fish_mat.roughness = 0.30
	fish.material_override = fish_mat
	fish.position = Vector3(0.40, 0.85, 0.20)
	fish.rotation_degrees = Vector3(0, 0, 90)
	npc.add_child(fish)


static func _build_d8_fish_dryer(geom: Node) -> void:
	## Epic-8 T55: hanging fish dryer — wooden frame with rope between
	## 2 posts + 6 fish hanging.
	var dryer: Node3D = Node3D.new()
	dryer.name = "FishDryer"
	dryer.position = Vector3(D8_CENTER.x - 6.0, 0.0, 22.0)
	geom.add_child(dryer)
	var wood_mat: StandardMaterial3D = StandardMaterial3D.new()
	wood_mat.albedo_color = Color(0.45, 0.28, 0.12)
	wood_mat.roughness = 0.85
	# 2 vertical posts
	for sx in [-1.85, 1.85]:
		var post: MeshInstance3D = MeshInstance3D.new()
		var pm: CylinderMesh = CylinderMesh.new()
		pm.top_radius = 0.08
		pm.bottom_radius = 0.10
		pm.height = 2.85
		post.mesh = pm
		post.material_override = wood_mat
		post.position = Vector3(sx, 1.42, 0)
		dryer.add_child(post)
		# Post collision
		var sb: StaticBody3D = StaticBody3D.new()
		sb.position = Vector3(sx, 1.42, 0)
		var cs: CollisionShape3D = CollisionShape3D.new()
		var cap: CapsuleShape3D = CapsuleShape3D.new()
		cap.radius = 0.10
		cap.height = 2.85
		cs.shape = cap
		sb.add_child(cs)
		dryer.add_child(sb)
	# Top rope
	var rope: MeshInstance3D = MeshInstance3D.new()
	var rmm: CylinderMesh = CylinderMesh.new()
	rmm.top_radius = 0.025
	rmm.bottom_radius = 0.025
	rmm.height = 3.85
	rope.mesh = rmm
	var rope_mat: StandardMaterial3D = StandardMaterial3D.new()
	rope_mat.albedo_color = Color(0.55, 0.40, 0.20)
	rope.material_override = rope_mat
	rope.position = Vector3(0, 2.85, 0)
	rope.rotation_degrees = Vector3(0, 0, 90)
	dryer.add_child(rope)
	# 6 hanging fish
	var fish_mat: StandardMaterial3D = StandardMaterial3D.new()
	fish_mat.albedo_color = Color(0.65, 0.55, 0.30)
	fish_mat.roughness = 0.85
	for i in 6:
		var fish: MeshInstance3D = MeshInstance3D.new()
		var fmm: PrismMesh = PrismMesh.new()
		fmm.size = Vector3(0.10, 0.55, 0.18)
		fish.mesh = fmm
		fish.material_override = fish_mat
		fish.position = Vector3(-1.40 + i * 0.55, 2.30, 0)
		dryer.add_child(fish)
		# Subtle sway
		var tw: Tween = fish.create_tween().set_loops()
		tw.tween_interval(i * 0.10)
		tw.tween_property(fish, "rotation_degrees:z", 4.0, 1.4)
		tw.tween_property(fish, "rotation_degrees:z", -4.0, 1.4)


static func _build_d8_sea_turtles(geom: Node) -> void:
	## Epic-8 T56: 3 sea turtles slowly swimming — round green shell + 4
	## flippers + slow drift tween.
	var turtles: Node3D = Node3D.new()
	turtles.name = "SeaTurtles"
	turtles.position = Vector3(D8_CENTER.x + 0.0, 0.30, 18.0)
	geom.add_child(turtles)
	var shell_mat: StandardMaterial3D = StandardMaterial3D.new()
	shell_mat.albedo_color = Color(0.20, 0.55, 0.30)
	shell_mat.emission_enabled = true
	shell_mat.emission = Color(0.20, 0.65, 0.30)
	shell_mat.emission_energy_multiplier = 0.45
	shell_mat.metallic = 0.30
	shell_mat.roughness = 0.45
	var skin_mat: StandardMaterial3D = StandardMaterial3D.new()
	skin_mat.albedo_color = Color(0.30, 0.45, 0.30)
	skin_mat.roughness = 0.65
	var positions: Array = [
		Vector3( 0.0, 0,  0.0),
		Vector3( 2.85, 0,  1.40),
		Vector3(-2.40, 0,  0.85),
	]
	for p in positions:
		var turtle: Node3D = Node3D.new()
		turtle.position = p
		turtles.add_child(turtle)
		# Round shell (flat sphere)
		var shell: MeshInstance3D = MeshInstance3D.new()
		var sm: SphereMesh = SphereMesh.new()
		sm.radius = 0.55
		sm.height = 0.40
		shell.mesh = sm
		shell.material_override = shell_mat
		shell.position = Vector3(0, 0.20, 0)
		shell.scale = Vector3(1.0, 0.45, 1.30)
		turtle.add_child(shell)
		# Head
		var head: MeshInstance3D = MeshInstance3D.new()
		var hm: SphereMesh = SphereMesh.new()
		hm.radius = 0.18
		hm.height = 0.32
		head.mesh = hm
		head.material_override = skin_mat
		head.position = Vector3(0, 0.20, 0.55)
		turtle.add_child(head)
		# 4 flippers
		for sx in [-0.40, 0.40]:
			for sz in [-0.30, 0.30]:
				var flipper: MeshInstance3D = MeshInstance3D.new()
				var flm: BoxMesh = BoxMesh.new()
				flm.size = Vector3(0.30, 0.06, 0.18)
				flipper.mesh = flm
				flipper.material_override = skin_mat
				flipper.position = Vector3(sx, 0.20, sz)
				turtle.add_child(flipper)
				# Slow flap tween
				var twf: Tween = flipper.create_tween().set_loops()
				twf.tween_property(flipper, "rotation_degrees:z", 8.0 if sx > 0 else -8.0, 1.4)
				twf.tween_property(flipper, "rotation_degrees:z", -8.0 if sx > 0 else 8.0, 1.4)
		# Slow drift tween
		var tw: Tween = turtle.create_tween().set_loops()
		var p2: Vector3 = p
		tw.tween_property(turtle, "position", p2 + Vector3(randf_range(-1.5, 1.5), 0, randf_range(-1.5, 1.5)), 4.0)
		tw.tween_property(turtle, "rotation_degrees:y", 180.0, 0.5)
		tw.tween_property(turtle, "position", p2, 4.0)
		tw.tween_property(turtle, "rotation_degrees:y", 0.0, 0.5)


static func _build_d8_marine_biologist_npc(town: Node) -> void:
	## Epic-8 T57: marine biologist NPC — white lab coat + held magnifier +
	## small clipboard.
	var npc_slots: Node3D = town.get_node_or_null("%NPCSlots") as Node3D
	if npc_slots == null:
		return
	var slot: Marker3D = Marker3D.new()
	slot.name = "MarineBiologistSlot"
	slot.position = Vector3(D8_CENTER.x + 4.0, 0.0, 22.0)
	npc_slots.add_child(slot)
	var npc_scene: PackedScene = load("res://scenes/entities/npcs/VillagerR3.tscn") as PackedScene
	if npc_scene == null:
		return
	var npc: Node3D = npc_scene.instantiate() as Node3D
	npc.name = "MarineBiologist"
	if "npc_name" in npc:
		npc.set("npc_name", "Plankton")
	if "npc_id" in npc:
		npc.set("npc_id", "marine_bio_d8")
	slot.add_child(npc)
	# Lab coat
	var coat: MeshInstance3D = MeshInstance3D.new()
	var cm: BoxMesh = BoxMesh.new()
	cm.size = Vector3(0.65, 1.20, 0.45)
	coat.mesh = cm
	var coat_mat: StandardMaterial3D = StandardMaterial3D.new()
	coat_mat.albedo_color = Color(0.95, 0.95, 0.92)
	coat_mat.roughness = 0.55
	coat.material_override = coat_mat
	coat.position = Vector3(0, 0.60, 0)
	npc.add_child(coat)
	# Clipboard
	var clip: MeshInstance3D = MeshInstance3D.new()
	var clm: BoxMesh = BoxMesh.new()
	clm.size = Vector3(0.30, 0.40, 0.04)
	clip.mesh = clm
	var clip_mat: StandardMaterial3D = StandardMaterial3D.new()
	clip_mat.albedo_color = Color(0.45, 0.28, 0.12)
	clip.material_override = clip_mat
	clip.position = Vector3(0.40, 0.85, 0.20)
	clip.rotation_degrees = Vector3(-25, 0, 0)
	npc.add_child(clip)
	# Paper
	var paper: MeshInstance3D = MeshInstance3D.new()
	var pm: BoxMesh = BoxMesh.new()
	pm.size = Vector3(0.27, 0.36, 0.02)
	paper.mesh = pm
	var paper_mat: StandardMaterial3D = StandardMaterial3D.new()
	paper_mat.albedo_color = Color(0.95, 0.95, 0.92)
	paper.material_override = paper_mat
	paper.position = Vector3(0.40, 0.85, 0.23)
	paper.rotation_degrees = Vector3(-25, 0, 0)
	npc.add_child(paper)


static func _build_d8_aquarium_tank(geom: Node) -> void:
	## Epic-8 T58: aquarium tank — translucent glass cube with cyan water
	## inside + 4 small fish swimming + bubble particles.
	var tank: Node3D = Node3D.new()
	tank.name = "AquariumTank"
	tank.position = Vector3(D8_CENTER.x + 8.0, 0.0, 22.0)
	geom.add_child(tank)
	var stand_mat: StandardMaterial3D = StandardMaterial3D.new()
	stand_mat.albedo_color = Color(0.30, 0.30, 0.40)
	stand_mat.metallic = 0.55
	stand_mat.roughness = 0.45
	# Stand
	var stand: MeshInstance3D = MeshInstance3D.new()
	var sm: BoxMesh = BoxMesh.new()
	sm.size = Vector3(2.0, 0.85, 1.10)
	stand.mesh = sm
	stand.material_override = stand_mat
	stand.position = Vector3(0, 0.42, 0)
	tank.add_child(stand)
	# Glass tank
	var glass: MeshInstance3D = MeshInstance3D.new()
	var gm: BoxMesh = BoxMesh.new()
	gm.size = Vector3(1.85, 1.40, 0.95)
	glass.mesh = gm
	var glass_mat: StandardMaterial3D = StandardMaterial3D.new()
	glass_mat.albedo_color = Color(0.30, 0.85, 1.0, 0.45)
	glass_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	glass_mat.emission_enabled = true
	glass_mat.emission = Color(0.30, 0.95, 1.0)
	glass_mat.emission_energy_multiplier = 1.4
	glass_mat.metallic = 0.55
	glass_mat.roughness = 0.05
	glass.material_override = glass_mat
	glass.position = Vector3(0, 1.55, 0)
	tank.add_child(glass)
	# 4 small fish swimming inside
	var fish_colors: Array = [
		Color(0.95, 0.55, 0.20),
		Color(0.85, 0.20, 0.30),
		Color(0.95, 0.85, 0.20),
		Color(0.30, 0.65, 0.95),
	]
	for i in 4:
		var pivot: Node3D = Node3D.new()
		pivot.position = Vector3(0, 1.55, 0)
		pivot.rotation_degrees = Vector3(0, i * 90.0, 0)
		tank.add_child(pivot)
		var fish: MeshInstance3D = MeshInstance3D.new()
		var fmm: PrismMesh = PrismMesh.new()
		fmm.size = Vector3(0.12, 0.06, 0.20)
		fish.mesh = fmm
		var fish_mat: StandardMaterial3D = StandardMaterial3D.new()
		fish_mat.albedo_color = fish_colors[i]
		fish_mat.emission_enabled = true
		fish_mat.emission = fish_colors[i]
		fish_mat.emission_energy_multiplier = 1.4
		fish.material_override = fish_mat
		fish.position = Vector3(0.55, 0, 0)
		pivot.add_child(fish)
		# Pivot rotation tween
		var trot: Tween = pivot.create_tween().set_loops()
		trot.tween_property(pivot, "rotation_degrees:y", i * 90.0 + 360.0, 5.0 + i * 0.4)
		trot.tween_property(pivot, "rotation_degrees:y", i * 90.0, 0.0)
	# Cyan light
	var light: OmniLight3D = OmniLight3D.new()
	light.light_color = Color(0.40, 0.95, 1.0)
	light.light_energy = 1.85
	light.omni_range = 4.5
	light.position = Vector3(0, 1.55, 0)
	tank.add_child(light)
	# Stand collision
	var sb: StaticBody3D = StaticBody3D.new()
	sb.position = Vector3(0, 1.0, 0)
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(2.0, 2.40, 1.10)
	cs.shape = cb
	sb.add_child(cs)
	tank.add_child(sb)


static func _build_d8_specimen_jars(geom: Node) -> void:
	## Epic-8 T59: row of 5 glass specimen jars on a wooden shelf — each
	## containing a different colored marine specimen.
	var jars: Node3D = Node3D.new()
	jars.name = "SpecimenJars"
	jars.position = Vector3(D8_CENTER.x + 12.0, 0.0, 22.0)
	geom.add_child(jars)
	var wood_mat: StandardMaterial3D = StandardMaterial3D.new()
	wood_mat.albedo_color = Color(0.45, 0.28, 0.12)
	wood_mat.roughness = 0.85
	var glass_mat: StandardMaterial3D = StandardMaterial3D.new()
	glass_mat.albedo_color = Color(0.85, 0.95, 1.0, 0.45)
	glass_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	glass_mat.emission_enabled = true
	glass_mat.emission = Color(0.85, 0.95, 1.0)
	glass_mat.emission_energy_multiplier = 0.85
	glass_mat.metallic = 0.55
	glass_mat.roughness = 0.05
	var specimen_colors: Array = [
		Color(0.95, 0.20, 0.30),
		Color(0.20, 0.65, 0.95),
		Color(0.30, 0.95, 0.55),
		Color(0.95, 0.85, 0.20),
		Color(0.85, 0.30, 0.85),
	]
	# Wooden shelf
	var shelf: MeshInstance3D = MeshInstance3D.new()
	var sm: BoxMesh = BoxMesh.new()
	sm.size = Vector3(3.40, 0.18, 0.55)
	shelf.mesh = sm
	shelf.material_override = wood_mat
	shelf.position = Vector3(0, 1.10, 0)
	jars.add_child(shelf)
	# 2 shelf brackets
	for sx in [-1.40, 1.40]:
		var bracket: MeshInstance3D = MeshInstance3D.new()
		var bm: BoxMesh = BoxMesh.new()
		bm.size = Vector3(0.10, 1.10, 0.10)
		bracket.mesh = bm
		bracket.material_override = wood_mat
		bracket.position = Vector3(sx, 0.55, 0)
		jars.add_child(bracket)
	# 5 jars
	for i in 5:
		var jar: MeshInstance3D = MeshInstance3D.new()
		var jm: CylinderMesh = CylinderMesh.new()
		jm.top_radius = 0.18
		jm.bottom_radius = 0.18
		jm.height = 0.55
		jar.mesh = jm
		jar.material_override = glass_mat
		jar.position = Vector3(-1.20 + i * 0.60, 1.45, 0)
		jars.add_child(jar)
		# Specimen inside (small bright sphere)
		var spec: MeshInstance3D = MeshInstance3D.new()
		var spmm: SphereMesh = SphereMesh.new()
		spmm.radius = 0.12
		spmm.height = 0.20
		spec.mesh = spmm
		var spec_mat: StandardMaterial3D = StandardMaterial3D.new()
		spec_mat.albedo_color = specimen_colors[i]
		spec_mat.emission_enabled = true
		spec_mat.emission = specimen_colors[i]
		spec_mat.emission_energy_multiplier = 1.85
		spec.material_override = spec_mat
		spec.position = Vector3(-1.20 + i * 0.60, 1.42, 0)
		jars.add_child(spec)
	# Shelf collision
	var sb: StaticBody3D = StaticBody3D.new()
	sb.position = Vector3(0, 1.10, 0)
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(3.40, 0.85, 0.55)
	cs.shape = cb
	sb.add_child(cs)
	jars.add_child(sb)


static func _build_d8_diving_rig(geom: Node) -> void:
	## Epic-8 T60: diving rig — old-style brass diving helmet on a stand
	## with hose connection.
	var rig: Node3D = Node3D.new()
	rig.name = "DivingRig"
	rig.position = Vector3(D8_CENTER.x + 18.0, 0.0, 22.0)
	geom.add_child(rig)
	var brass_mat: StandardMaterial3D = StandardMaterial3D.new()
	brass_mat.albedo_color = Color(0.85, 0.65, 0.20)
	brass_mat.metallic = 0.95
	brass_mat.roughness = 0.20
	var glass_mat: StandardMaterial3D = StandardMaterial3D.new()
	glass_mat.albedo_color = Color(0.40, 0.85, 1.0, 0.85)
	glass_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	glass_mat.emission_enabled = true
	glass_mat.emission = Color(0.30, 0.95, 1.0)
	glass_mat.emission_energy_multiplier = 2.5
	# Wooden stand
	var stand: MeshInstance3D = MeshInstance3D.new()
	var sm: BoxMesh = BoxMesh.new()
	sm.size = Vector3(0.85, 0.85, 0.85)
	stand.mesh = sm
	var wood_mat: StandardMaterial3D = StandardMaterial3D.new()
	wood_mat.albedo_color = Color(0.45, 0.28, 0.12)
	wood_mat.roughness = 0.85
	stand.material_override = wood_mat
	stand.position = Vector3(0, 0.42, 0)
	rig.add_child(stand)
	# Brass diving helmet (round dome)
	var helmet: MeshInstance3D = MeshInstance3D.new()
	var hm: SphereMesh = SphereMesh.new()
	hm.radius = 0.40
	hm.height = 0.65
	helmet.mesh = hm
	helmet.material_override = brass_mat
	helmet.position = Vector3(0, 1.20, 0)
	rig.add_child(helmet)
	# Round front porthole window
	var port: MeshInstance3D = MeshInstance3D.new()
	var pmm: CylinderMesh = CylinderMesh.new()
	pmm.top_radius = 0.18
	pmm.bottom_radius = 0.18
	pmm.height = 0.06
	port.mesh = pmm
	port.material_override = glass_mat
	port.position = Vector3(0, 1.20, 0.40)
	port.rotation_degrees = Vector3(90, 0, 0)
	rig.add_child(port)
	# 3 small bolts around the porthole
	for i in 3:
		var ang: float = (TAU / 3.0) * i
		var bolt: MeshInstance3D = MeshInstance3D.new()
		var btm: SphereMesh = SphereMesh.new()
		btm.radius = 0.04
		btm.height = 0.08
		bolt.mesh = btm
		bolt.material_override = brass_mat
		bolt.position = Vector3(cos(ang) * 0.25, 1.20 + sin(ang) * 0.25, 0.42)
		rig.add_child(bolt)
	# Hose connection (curved cylinder going down)
	var hose: MeshInstance3D = MeshInstance3D.new()
	var hmm2: CylinderMesh = CylinderMesh.new()
	hmm2.top_radius = 0.06
	hmm2.bottom_radius = 0.08
	hmm2.height = 0.55
	hose.mesh = hmm2
	var hose_mat: StandardMaterial3D = StandardMaterial3D.new()
	hose_mat.albedo_color = Color(0.30, 0.20, 0.10)
	hose_mat.roughness = 0.85
	hose.material_override = hose_mat
	hose.position = Vector3(0, 1.65, -0.18)
	rig.add_child(hose)
	# Stand collision
	var sb: StaticBody3D = StaticBody3D.new()
	sb.position = Vector3(0, 0.85, 0)
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(0.85, 1.85, 0.85)
	cs.shape = cb
	sb.add_child(cs)
	rig.add_child(sb)


static func _build_d8_pearl_diver_npc(town: Node) -> void:
	## Epic-8 T61: pearl diver NPC — wetsuit + breathing mask + held pearl.
	var npc_slots: Node3D = town.get_node_or_null("%NPCSlots") as Node3D
	if npc_slots == null:
		return
	var slot: Marker3D = Marker3D.new()
	slot.name = "PearlDiverSlot"
	slot.position = Vector3(D8_CENTER.x + 16.0, 0.0, 22.0)
	npc_slots.add_child(slot)
	var npc_scene: PackedScene = load("res://scenes/entities/npcs/VillagerR3.tscn") as PackedScene
	if npc_scene == null:
		return
	var npc: Node3D = npc_scene.instantiate() as Node3D
	npc.name = "PearlDiver"
	if "npc_name" in npc:
		npc.set("npc_name", "Nautilus")
	if "npc_id" in npc:
		npc.set("npc_id", "pearl_diver_d8")
	slot.add_child(npc)
	# Black wetsuit
	var suit: MeshInstance3D = MeshInstance3D.new()
	var sm: BoxMesh = BoxMesh.new()
	sm.size = Vector3(0.65, 1.10, 0.40)
	suit.mesh = sm
	var suit_mat: StandardMaterial3D = StandardMaterial3D.new()
	suit_mat.albedo_color = Color(0.10, 0.10, 0.15)
	suit_mat.metallic = 0.30
	suit_mat.roughness = 0.45
	suit.material_override = suit_mat
	suit.position = Vector3(0, 0.55, 0)
	npc.add_child(suit)
	# Breathing mask
	var mask: MeshInstance3D = MeshInstance3D.new()
	var mm: BoxMesh = BoxMesh.new()
	mm.size = Vector3(0.40, 0.20, 0.06)
	mask.mesh = mm
	var mask_mat: StandardMaterial3D = StandardMaterial3D.new()
	mask_mat.albedo_color = Color(0.30, 0.85, 1.0, 0.85)
	mask_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mask_mat.emission_enabled = true
	mask_mat.emission = Color(0.30, 0.95, 1.0)
	mask_mat.emission_energy_multiplier = 1.4
	mask_mat.metallic = 0.55
	mask_mat.roughness = 0.10
	mask.material_override = mask_mat
	mask.position = Vector3(0, 1.30, 0.21)
	npc.add_child(mask)
	# Held pearl (small white sphere)
	var pearl: MeshInstance3D = MeshInstance3D.new()
	var pmm: SphereMesh = SphereMesh.new()
	pmm.radius = 0.08
	pmm.height = 0.16
	pearl.mesh = pmm
	var pearl_mat: StandardMaterial3D = StandardMaterial3D.new()
	pearl_mat.albedo_color = Color(0.95, 0.95, 0.92)
	pearl_mat.emission_enabled = true
	pearl_mat.emission = Color(0.95, 0.95, 0.92)
	pearl_mat.emission_energy_multiplier = 2.5
	pearl_mat.metallic = 0.65
	pearl_mat.roughness = 0.05
	pearl.material_override = pearl_mat
	pearl.position = Vector3(0.40, 0.85, 0.20)
	npc.add_child(pearl)


static func _build_d8_oysters(geom: Node) -> void:
	## Epic-8 T62: 5 open oysters scattered on a stone slab — half-shell
	## sphere + glowing pearl visible inside each.
	var oysters: Node3D = Node3D.new()
	oysters.name = "Oysters"
	oysters.position = Vector3(D8_CENTER.x + 22.0, 0.0, 8.0)
	geom.add_child(oysters)
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.45, 0.40, 0.35)
	stone_mat.roughness = 0.92
	# Stone slab base
	var slab: MeshInstance3D = MeshInstance3D.new()
	var sm: BoxMesh = BoxMesh.new()
	sm.size = Vector3(2.85, 0.20, 1.85)
	slab.mesh = sm
	slab.material_override = stone_mat
	slab.position = Vector3(0, 0.10, 0)
	oysters.add_child(slab)
	# Oyster colors
	var shell_mat: StandardMaterial3D = StandardMaterial3D.new()
	shell_mat.albedo_color = Color(0.65, 0.55, 0.40)
	shell_mat.roughness = 0.85
	var pearl_mat: StandardMaterial3D = StandardMaterial3D.new()
	pearl_mat.albedo_color = Color(0.95, 0.95, 0.92)
	pearl_mat.emission_enabled = true
	pearl_mat.emission = Color(0.95, 0.95, 0.92)
	pearl_mat.emission_energy_multiplier = 2.5
	pearl_mat.metallic = 0.65
	pearl_mat.roughness = 0.05
	for i in 5:
		var oyster: Node3D = Node3D.new()
		oyster.position = Vector3(
			randf_range(-1.0, 1.0),
			0.18,
			randf_range(-0.65, 0.65)
		)
		oysters.add_child(oyster)
		# Bottom half-shell
		var bot: MeshInstance3D = MeshInstance3D.new()
		var bm: SphereMesh = SphereMesh.new()
		bm.radius = 0.18
		bm.height = 0.10
		bot.mesh = bm
		bot.material_override = shell_mat
		bot.position = Vector3(0, 0.05, 0)
		bot.scale = Vector3(1.0, 0.40, 1.0)
		oyster.add_child(bot)
		# Top half-shell (lifted)
		var top: MeshInstance3D = MeshInstance3D.new()
		var tm: SphereMesh = SphereMesh.new()
		tm.radius = 0.18
		tm.height = 0.10
		top.mesh = tm
		top.material_override = shell_mat
		top.position = Vector3(0, 0.18, 0)
		top.scale = Vector3(1.0, 0.40, 1.0)
		top.rotation_degrees = Vector3(15, 0, 0)
		oyster.add_child(top)
		# Pearl inside
		var pearl: MeshInstance3D = MeshInstance3D.new()
		var pmm: SphereMesh = SphereMesh.new()
		pmm.radius = 0.06
		pmm.height = 0.12
		pearl.mesh = pmm
		pearl.material_override = pearl_mat
		pearl.position = Vector3(0, 0.10, 0)
		oyster.add_child(pearl)


static func _build_d8_crabs(geom: Node) -> void:
	## Epic-8 T63: 4 small crabs scattered around the dock — round body +
	## 2 claws + 6 legs + side-step shuffle.
	var crabs: Node3D = Node3D.new()
	crabs.name = "Crabs"
	crabs.position = Vector3(D8_CENTER.x + 4.0, 0.0, -2.0)
	geom.add_child(crabs)
	var crab_mat: StandardMaterial3D = StandardMaterial3D.new()
	crab_mat.albedo_color = Color(0.85, 0.30, 0.20)
	crab_mat.emission_enabled = true
	crab_mat.emission = Color(0.85, 0.20, 0.10)
	crab_mat.emission_energy_multiplier = 0.45
	crab_mat.roughness = 0.65
	for i in 4:
		var crab: Node3D = Node3D.new()
		crab.position = Vector3(
			randf_range(-3.5, 3.5),
			0,
			randf_range(-2.5, 2.5)
		)
		crabs.add_child(crab)
		# Body (flat sphere)
		var body: MeshInstance3D = MeshInstance3D.new()
		var bm: SphereMesh = SphereMesh.new()
		bm.radius = 0.18
		bm.height = 0.18
		body.mesh = bm
		body.material_override = crab_mat
		body.position = Vector3(0, 0.10, 0)
		body.scale = Vector3(1.0, 0.55, 1.20)
		crab.add_child(body)
		# 2 claws (small spheres)
		for sx in [-0.18, 0.18]:
			var claw: MeshInstance3D = MeshInstance3D.new()
			var cm: SphereMesh = SphereMesh.new()
			cm.radius = 0.08
			cm.height = 0.10
			claw.mesh = cm
			claw.material_override = crab_mat
			claw.position = Vector3(sx, 0.10, 0.18)
			crab.add_child(claw)
		# 6 small legs
		for sx in [-0.18, 0.18]:
			for sz in [-0.12, 0, 0.12]:
				var leg: MeshInstance3D = MeshInstance3D.new()
				var lm: CylinderMesh = CylinderMesh.new()
				lm.top_radius = 0.018
				lm.bottom_radius = 0.018
				lm.height = 0.18
				leg.mesh = lm
				leg.material_override = crab_mat
				leg.position = Vector3(sx, 0.06, sz)
				leg.rotation_degrees = Vector3(0, 0, 60.0 if sx > 0 else -60.0)
				crab.add_child(leg)
		# Side-step shuffle tween
		var tw: Tween = crab.create_tween().set_loops()
		tw.tween_property(crab, "position:x", crab.position.x + 1.0, 1.4)
		tw.tween_property(crab, "position:x", crab.position.x - 1.0, 1.4)


static func _build_d8_dock_bridge(geom: Node) -> void:
	## Epic-8 T64: small wooden plank bridge connecting two dock sections
	## across a small water gap.
	var bridge: Node3D = Node3D.new()
	bridge.name = "D8DockBridge"
	bridge.position = Vector3(D8_CENTER.x + 8.0, 0.0, 4.0)
	geom.add_child(bridge)
	var wood_mat: StandardMaterial3D = StandardMaterial3D.new()
	wood_mat.albedo_color = Color(0.45, 0.28, 0.12)
	wood_mat.roughness = 0.85
	# 5 wooden plank steps
	for i in 5:
		var plank: MeshInstance3D = MeshInstance3D.new()
		var pm: BoxMesh = BoxMesh.new()
		pm.size = Vector3(1.85, 0.10, 0.40)
		plank.mesh = pm
		plank.material_override = wood_mat
		plank.position = Vector3(0, 0.30, -0.85 + i * 0.42)
		bridge.add_child(plank)
	# 2 side rope rails
	var rope_mat: StandardMaterial3D = StandardMaterial3D.new()
	rope_mat.albedo_color = Color(0.55, 0.40, 0.20)
	rope_mat.roughness = 0.85
	for sx in [-0.85, 0.85]:
		var rope: MeshInstance3D = MeshInstance3D.new()
		var rmm: CylinderMesh = CylinderMesh.new()
		rmm.top_radius = 0.025
		rmm.bottom_radius = 0.025
		rmm.height = 1.85
		rope.mesh = rmm
		rope.material_override = rope_mat
		rope.position = Vector3(sx, 0.85, 0)
		rope.rotation_degrees = Vector3(90, 0, 0)
		bridge.add_child(rope)
	# 4 vertical post supports
	for sx in [-0.85, 0.85]:
		for sz in [-0.85, 0.85]:
			var post: MeshInstance3D = MeshInstance3D.new()
			var pmm: CylinderMesh = CylinderMesh.new()
			pmm.top_radius = 0.06
			pmm.bottom_radius = 0.06
			pmm.height = 0.85
			post.mesh = pmm
			post.material_override = wood_mat
			post.position = Vector3(sx, 0.42, sz)
			bridge.add_child(post)
	# Bridge collision
	var sb: StaticBody3D = StaticBody3D.new()
	sb.position = Vector3(0, 0.55, 0)
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(1.85, 1.10, 1.85)
	cs.shape = cb
	sb.add_child(cs)
	bridge.add_child(sb)


static func _build_d8_anemones(geom: Node) -> void:
	## Epic-8 T65: 5 sea anemones — colorful column bases with tentacle
	## clusters waving from the top.
	var anemones: Node3D = Node3D.new()
	anemones.name = "SeaAnemones"
	anemones.position = Vector3(D8_CENTER.x - 4.0, 0.0, -22.0)
	geom.add_child(anemones)
	var colors: Array = [
		Color(0.85, 0.30, 0.85),
		Color(0.95, 0.55, 0.20),
		Color(0.30, 0.95, 0.55),
		Color(0.95, 0.85, 0.20),
		Color(0.30, 0.65, 0.95),
	]
	for i in 5:
		var anem: Node3D = Node3D.new()
		anem.position = Vector3(i * 1.85, 0, 0)
		anemones.add_child(anem)
		var col: Color = colors[i]
		var col_mat: StandardMaterial3D = StandardMaterial3D.new()
		col_mat.albedo_color = col
		col_mat.emission_enabled = true
		col_mat.emission = col
		col_mat.emission_energy_multiplier = 1.4
		col_mat.roughness = 0.65
		# Cylinder column body
		var col_body: MeshInstance3D = MeshInstance3D.new()
		var cm: CylinderMesh = CylinderMesh.new()
		cm.top_radius = 0.30
		cm.bottom_radius = 0.40
		cm.height = 0.85
		col_body.mesh = cm
		col_body.material_override = col_mat
		col_body.position = Vector3(0, 0.42, 0)
		anem.add_child(col_body)
		# 8 tentacle prisms waving from the top
		for j in 8:
			var ang: float = (TAU / 8.0) * j
			var tent: MeshInstance3D = MeshInstance3D.new()
			var tm: PrismMesh = PrismMesh.new()
			tm.size = Vector3(0.06, 0.55, 0.06)
			tent.mesh = tm
			tent.material_override = col_mat
			tent.position = Vector3(cos(ang) * 0.25, 1.10, sin(ang) * 0.25)
			tent.rotation_degrees = Vector3(0, randf_range(-15, 15), 0)
			anem.add_child(tent)
			# Sway tween
			var tw: Tween = tent.create_tween().set_loops()
			tw.tween_interval(j * 0.10)
			tw.tween_property(tent, "rotation_degrees:z", 8.0, 1.0)
			tw.tween_property(tent, "rotation_degrees:z", -8.0, 1.0)
		# Anemone collision
		var sb: StaticBody3D = StaticBody3D.new()
		sb.position = Vector3(0, 0.42, 0)
		var cs: CollisionShape3D = CollisionShape3D.new()
		var cap: CapsuleShape3D = CapsuleShape3D.new()
		cap.radius = 0.40
		cap.height = 0.85
		cs.shape = cap
		sb.add_child(cs)
		anem.add_child(sb)


static func _build_d8_lighthouse(geom: Node) -> void:
	## Epic-8 T66: lighthouse beacon — tall striped stone tower with rotating
	## emissive lamp on top, anchored at far east edge of the harbor.
	var house: Node3D = Node3D.new()
	house.name = "D8Lighthouse"
	house.position = Vector3(D8_CENTER.x + 75, 0, -22)
	geom.add_child(house)
	# Base platform: wide stone disc
	var base_mat: StandardMaterial3D = StandardMaterial3D.new()
	base_mat.albedo_color = Color(0.45, 0.45, 0.50)
	base_mat.roughness = 0.85
	var base: MeshInstance3D = MeshInstance3D.new()
	var base_mesh: CylinderMesh = CylinderMesh.new()
	base_mesh.top_radius = 2.6
	base_mesh.bottom_radius = 3.0
	base_mesh.height = 0.5
	base.mesh = base_mesh
	base.material_override = base_mat
	base.position = Vector3(0, 0.25, 0)
	house.add_child(base)
	# Tower body: 3 striped segments (white / red / white)
	var white_mat: StandardMaterial3D = StandardMaterial3D.new()
	white_mat.albedo_color = Color(0.90, 0.90, 0.88)
	white_mat.roughness = 0.7
	var red_mat: StandardMaterial3D = StandardMaterial3D.new()
	red_mat.albedo_color = Color(0.75, 0.18, 0.18)
	red_mat.roughness = 0.7
	for i in range(3):
		var seg: MeshInstance3D = MeshInstance3D.new()
		var sm: CylinderMesh = CylinderMesh.new()
		sm.top_radius = 1.5 - i * 0.18
		sm.bottom_radius = 1.7 - i * 0.18
		sm.height = 2.4
		seg.mesh = sm
		seg.material_override = red_mat if i == 1 else white_mat
		seg.position = Vector3(0, 0.5 + 1.2 + i * 2.4, 0)
		house.add_child(seg)
	# Lamp room: glass cylinder
	var lamp_glass: StandardMaterial3D = StandardMaterial3D.new()
	lamp_glass.albedo_color = Color(0.85, 0.95, 1.0, 0.45)
	lamp_glass.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	lamp_glass.metallic = 0.3
	lamp_glass.roughness = 0.15
	var lamp_room: MeshInstance3D = MeshInstance3D.new()
	var lr_mesh: CylinderMesh = CylinderMesh.new()
	lr_mesh.top_radius = 1.05
	lr_mesh.bottom_radius = 1.05
	lr_mesh.height = 1.4
	lamp_room.mesh = lr_mesh
	lamp_room.material_override = lamp_glass
	lamp_room.position = Vector3(0, 0.5 + 1.2 + 7.2 + 0.7, 0)
	house.add_child(lamp_room)
	# Roof cone (red)
	var roof: MeshInstance3D = MeshInstance3D.new()
	var rm: CylinderMesh = CylinderMesh.new()
	rm.top_radius = 0.0
	rm.bottom_radius = 1.2
	rm.height = 1.1
	roof.mesh = rm
	roof.material_override = red_mat
	roof.position = Vector3(0, 0.5 + 1.2 + 7.2 + 1.4 + 0.55, 0)
	house.add_child(roof)
	# Rotating beam: a long emissive prism inside the lamp room
	var beam_pivot: Node3D = Node3D.new()
	beam_pivot.position = Vector3(0, 0.5 + 1.2 + 7.2 + 0.7, 0)
	house.add_child(beam_pivot)
	var beam_mat: StandardMaterial3D = StandardMaterial3D.new()
	beam_mat.albedo_color = Color(1.0, 0.95, 0.65)
	beam_mat.emission_enabled = true
	beam_mat.emission = Color(1.0, 0.92, 0.55)
	beam_mat.emission_energy_multiplier = 3.5
	beam_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var beam: MeshInstance3D = MeshInstance3D.new()
	var bm: BoxMesh = BoxMesh.new()
	bm.size = Vector3(8.0, 0.4, 0.6)
	beam.mesh = bm
	beam.material_override = beam_mat
	beam.position = Vector3(4.0, 0, 0)
	beam_pivot.add_child(beam)
	var lamp_light: OmniLight3D = OmniLight3D.new()
	lamp_light.light_color = Color(1.0, 0.92, 0.55)
	lamp_light.light_energy = 4.0
	lamp_light.omni_range = 18.0
	lamp_light.position = Vector3(0, 0, 0)
	beam_pivot.add_child(lamp_light)
	var spin: Tween = beam_pivot.create_tween().set_loops()
	spin.tween_property(beam_pivot, "rotation_degrees:y", 360.0, 6.0).from(0.0)
	# Tower collision
	var sb: StaticBody3D = StaticBody3D.new()
	sb.position = Vector3(0, 4.5, 0)
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cap: CapsuleShape3D = CapsuleShape3D.new()
	cap.radius = 1.7
	cap.height = 8.5
	cs.shape = cap
	sb.add_child(cs)
	house.add_child(sb)


static func _build_d8_cargo_containers(geom: Node) -> void:
	## Epic-8 T67: stacked colorful shipping containers on the dock — 6
	## containers in a 3x2 stack with weathered metal materials.
	var stack: Node3D = Node3D.new()
	stack.name = "D8CargoStack"
	stack.position = Vector3(D8_CENTER.x + 60, 0, 8)
	geom.add_child(stack)
	var hues: Array[Color] = [
		Color(0.78, 0.22, 0.18),
		Color(0.18, 0.42, 0.72),
		Color(0.85, 0.62, 0.20),
		Color(0.30, 0.58, 0.30),
		Color(0.62, 0.32, 0.55),
		Color(0.20, 0.55, 0.62),
	]
	var positions: Array[Vector3] = [
		Vector3(0, 1.25, 0),
		Vector3(2.6, 1.25, 0),
		Vector3(5.2, 1.25, 0),
		Vector3(0, 3.75, 0),
		Vector3(2.6, 3.75, 0),
		Vector3(5.2, 3.75, 0),
	]
	for i in range(6):
		var cont: MeshInstance3D = MeshInstance3D.new()
		var box: BoxMesh = BoxMesh.new()
		box.size = Vector3(2.4, 2.4, 5.4)
		cont.mesh = box
		var cm: StandardMaterial3D = StandardMaterial3D.new()
		cm.albedo_color = hues[i]
		cm.metallic = 0.55
		cm.roughness = 0.65
		cont.material_override = cm
		cont.position = positions[i]
		stack.add_child(cont)
		# Door lines: two thin dark stripes on the front
		for sx in [-0.6, 0.6]:
			var line: MeshInstance3D = MeshInstance3D.new()
			var lb: BoxMesh = BoxMesh.new()
			lb.size = Vector3(0.04, 2.2, 0.05)
			line.mesh = lb
			var lm: StandardMaterial3D = StandardMaterial3D.new()
			lm.albedo_color = Color(0.10, 0.10, 0.10)
			line.material_override = lm
			line.position = Vector3(sx, 0, 2.72)
			cont.add_child(line)
		# Per-container collision
		var sb: StaticBody3D = StaticBody3D.new()
		var cs: CollisionShape3D = CollisionShape3D.new()
		var bs: BoxShape3D = BoxShape3D.new()
		bs.size = Vector3(2.4, 2.4, 5.4)
		cs.shape = bs
		sb.add_child(cs)
		cont.add_child(sb)


static func _build_d8_quay_master_npc(town: Node) -> void:
	## Epic-8 T68: harbor master NPC — uniformed dockworker with clipboard.
	var slots: Node3D = town.get_node_or_null("NPCSlots") as Node3D
	if slots == null:
		return
	var slot: Marker3D = Marker3D.new()
	slot.name = "D8QuayMasterSlot"
	slot.position = Vector3(D8_CENTER.x + 50, 0, 4)
	slots.add_child(slot)
	var npc_scene: PackedScene = load("res://scenes/entities/npcs/VillagerR3.tscn") as PackedScene
	if npc_scene == null:
		return
	var npc: Node3D = npc_scene.instantiate() as Node3D
	npc.name = "D8HarborMaster"
	if "npc_name" in npc:
		npc.set("npc_name", "Harbormaster Quay")
	if "npc_id" in npc:
		npc.set("npc_id", "d8_harbor_master")
	slot.add_child(npc)
	# Navy peacoat
	var coat_mat: StandardMaterial3D = StandardMaterial3D.new()
	coat_mat.albedo_color = Color(0.10, 0.18, 0.32)
	coat_mat.roughness = 0.75
	var coat: MeshInstance3D = MeshInstance3D.new()
	var cb: BoxMesh = BoxMesh.new()
	cb.size = Vector3(0.85, 1.0, 0.55)
	coat.mesh = cb
	coat.material_override = coat_mat
	coat.position = Vector3(0, 1.05, 0)
	npc.add_child(coat)
	# Brass buttons (3)
	for i in range(3):
		var btn: MeshInstance3D = MeshInstance3D.new()
		var sm: SphereMesh = SphereMesh.new()
		sm.radius = 0.05
		sm.height = 0.10
		btn.mesh = sm
		var bmat: StandardMaterial3D = StandardMaterial3D.new()
		bmat.albedo_color = Color(0.85, 0.65, 0.20)
		bmat.metallic = 0.95
		bmat.roughness = 0.20
		btn.material_override = bmat
		btn.position = Vector3(0, 1.30 - i * 0.22, 0.30)
		npc.add_child(btn)
	# Captain's hat
	var hat_mat: StandardMaterial3D = StandardMaterial3D.new()
	hat_mat.albedo_color = Color(0.08, 0.10, 0.18)
	var hat: MeshInstance3D = MeshInstance3D.new()
	var hcb: CylinderMesh = CylinderMesh.new()
	hcb.top_radius = 0.32
	hcb.bottom_radius = 0.32
	hcb.height = 0.18
	hat.mesh = hcb
	hat.material_override = hat_mat
	hat.position = Vector3(0, 1.95, 0)
	npc.add_child(hat)
	var brim: MeshInstance3D = MeshInstance3D.new()
	var brim_mesh: CylinderMesh = CylinderMesh.new()
	brim_mesh.top_radius = 0.42
	brim_mesh.bottom_radius = 0.42
	brim_mesh.height = 0.04
	brim.mesh = brim_mesh
	brim.material_override = hat_mat
	brim.position = Vector3(0, 1.86, 0.05)
	npc.add_child(brim)
	# Clipboard in front
	var clip: MeshInstance3D = MeshInstance3D.new()
	var clb: BoxMesh = BoxMesh.new()
	clb.size = Vector3(0.32, 0.42, 0.03)
	clip.mesh = clb
	var clmat: StandardMaterial3D = StandardMaterial3D.new()
	clmat.albedo_color = Color(0.85, 0.78, 0.55)
	clip.material_override = clmat
	clip.position = Vector3(0, 0.95, 0.42)
	clip.rotation_degrees = Vector3(-15, 0, 0)
	npc.add_child(clip)


static func _build_d8_buoy_field(geom: Node) -> void:
	## Epic-8 T69: 6 bobbing harbor buoys with red navigation lights, scattered
	## offshore. Each buoy has its own bob tween offset.
	var field: Node3D = Node3D.new()
	field.name = "D8BuoyField"
	field.position = Vector3(D8_CENTER.x + 35, 0.2, -15)
	geom.add_child(field)
	var positions: Array[Vector2] = [
		Vector2(0, 0),
		Vector2(6, 3),
		Vector2(12, -2),
		Vector2(18, 4),
		Vector2(24, -1),
		Vector2(30, 2),
	]
	for i in range(positions.size()):
		var p: Vector2 = positions[i]
		var buoy: Node3D = Node3D.new()
		buoy.position = Vector3(p.x, 0, p.y)
		field.add_child(buoy)
		# Hull: red sphere flattened
		var hull: MeshInstance3D = MeshInstance3D.new()
		var hm: SphereMesh = SphereMesh.new()
		hm.radius = 0.40
		hm.height = 0.55
		hull.mesh = hm
		var hmat: StandardMaterial3D = StandardMaterial3D.new()
		hmat.albedo_color = Color(0.78, 0.18, 0.18)
		hmat.roughness = 0.6
		hull.material_override = hmat
		hull.position = Vector3(0, 0.30, 0)
		buoy.add_child(hull)
		# Mast
		var mast: MeshInstance3D = MeshInstance3D.new()
		var mm: CylinderMesh = CylinderMesh.new()
		mm.top_radius = 0.04
		mm.bottom_radius = 0.04
		mm.height = 0.85
		mast.mesh = mm
		var mmat: StandardMaterial3D = StandardMaterial3D.new()
		mmat.albedo_color = Color(0.75, 0.75, 0.78)
		mmat.metallic = 0.6
		mmat.roughness = 0.4
		mast.material_override = mmat
		mast.position = Vector3(0, 0.85, 0)
		buoy.add_child(mast)
		# Red top light
		var light_mat: StandardMaterial3D = StandardMaterial3D.new()
		light_mat.albedo_color = Color(1.0, 0.25, 0.25)
		light_mat.emission_enabled = true
		light_mat.emission = Color(1.0, 0.20, 0.20)
		light_mat.emission_energy_multiplier = 2.5
		light_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		var light_orb: MeshInstance3D = MeshInstance3D.new()
		var lo: SphereMesh = SphereMesh.new()
		lo.radius = 0.10
		lo.height = 0.20
		light_orb.mesh = lo
		light_orb.material_override = light_mat
		light_orb.position = Vector3(0, 1.30, 0)
		buoy.add_child(light_orb)
		# Bob tween
		var tw: Tween = buoy.create_tween().set_loops()
		var off: float = float(i) * 0.35
		tw.tween_property(buoy, "position:y", 0.18, 1.4 + off).from(0.0)
		tw.tween_property(buoy, "position:y", 0.0, 1.4 + off)
		# Pulse light
		var pulse: Tween = light_orb.create_tween().set_loops()
		pulse.tween_property(light_mat, "emission_energy_multiplier", 4.0, 0.8)
		pulse.tween_property(light_mat, "emission_energy_multiplier", 1.5, 0.8)


static func _build_d8_tied_fishing_boat(geom: Node) -> void:
	## Epic-8 T70: small wooden fishing boat tied to the dock — bobbing hull,
	## simple cabin, mast with net hanging off the side.
	var boat: Node3D = Node3D.new()
	boat.name = "D8TiedFishingBoat"
	boat.position = Vector3(D8_CENTER.x + 20, 0.3, 14)
	geom.add_child(boat)
	# Hull (wide flat box)
	var hull_mat: StandardMaterial3D = StandardMaterial3D.new()
	hull_mat.albedo_color = Color(0.45, 0.28, 0.15)
	hull_mat.roughness = 0.85
	var hull: MeshInstance3D = MeshInstance3D.new()
	var hb: BoxMesh = BoxMesh.new()
	hb.size = Vector3(2.4, 0.85, 5.6)
	hull.mesh = hb
	hull.material_override = hull_mat
	hull.position = Vector3(0, 0.40, 0)
	boat.add_child(hull)
	# Pointed bow prism
	var bow: MeshInstance3D = MeshInstance3D.new()
	var bp: PrismMesh = PrismMesh.new()
	bp.size = Vector3(2.4, 0.85, 1.4)
	bow.mesh = bp
	bow.material_override = hull_mat
	bow.position = Vector3(0, 0.40, -3.5)
	bow.rotation_degrees = Vector3(0, 90, 0)
	boat.add_child(bow)
	# Cabin (small box at stern)
	var cabin_mat: StandardMaterial3D = StandardMaterial3D.new()
	cabin_mat.albedo_color = Color(0.85, 0.82, 0.72)
	cabin_mat.roughness = 0.6
	var cabin: MeshInstance3D = MeshInstance3D.new()
	var cb: BoxMesh = BoxMesh.new()
	cb.size = Vector3(1.8, 1.1, 1.6)
	cabin.mesh = cb
	cabin.material_override = cabin_mat
	cabin.position = Vector3(0, 1.35, 1.4)
	boat.add_child(cabin)
	# Cabin window (cyan emissive)
	var win_mat: StandardMaterial3D = StandardMaterial3D.new()
	win_mat.albedo_color = Color(0.55, 0.85, 0.95)
	win_mat.emission_enabled = true
	win_mat.emission = Color(0.45, 0.80, 0.90)
	win_mat.emission_energy_multiplier = 0.9
	var win: MeshInstance3D = MeshInstance3D.new()
	var wb: BoxMesh = BoxMesh.new()
	wb.size = Vector3(1.0, 0.5, 0.04)
	win.mesh = wb
	win.material_override = win_mat
	win.position = Vector3(0, 1.45, 0.62)
	boat.add_child(win)
	# Mast
	var mast_mat: StandardMaterial3D = StandardMaterial3D.new()
	mast_mat.albedo_color = Color(0.55, 0.40, 0.25)
	var mast: MeshInstance3D = MeshInstance3D.new()
	var mm: CylinderMesh = CylinderMesh.new()
	mm.top_radius = 0.08
	mm.bottom_radius = 0.10
	mm.height = 3.5
	mast.mesh = mm
	mast.material_override = mast_mat
	mast.position = Vector3(0, 2.6, -1.0)
	boat.add_child(mast)
	# Hanging net (translucent dark mesh box)
	var net_mat: StandardMaterial3D = StandardMaterial3D.new()
	net_mat.albedo_color = Color(0.20, 0.25, 0.20, 0.6)
	net_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	var net: MeshInstance3D = MeshInstance3D.new()
	var nb: BoxMesh = BoxMesh.new()
	nb.size = Vector3(0.05, 1.6, 1.4)
	net.mesh = nb
	net.material_override = net_mat
	net.position = Vector3(1.25, 1.3, -0.5)
	boat.add_child(net)
	# Tie rope (cylinder to dock)
	var rope_mat: StandardMaterial3D = StandardMaterial3D.new()
	rope_mat.albedo_color = Color(0.78, 0.70, 0.45)
	var rope: MeshInstance3D = MeshInstance3D.new()
	var rm: CylinderMesh = CylinderMesh.new()
	rm.top_radius = 0.04
	rm.bottom_radius = 0.04
	rm.height = 1.6
	rope.mesh = rm
	rope.material_override = rope_mat
	rope.position = Vector3(-1.4, 0.6, -2.0)
	rope.rotation_degrees = Vector3(0, 0, 60)
	boat.add_child(rope)
	# Bob tween for the whole boat
	var tw: Tween = boat.create_tween().set_loops()
	tw.tween_property(boat, "position:y", 0.55, 2.2).from(0.30)
	tw.tween_property(boat, "position:y", 0.30, 2.2)
	var sway: Tween = boat.create_tween().set_loops()
	sway.tween_property(boat, "rotation_degrees:z", 2.5, 1.8)
	sway.tween_property(boat, "rotation_degrees:z", -2.5, 1.8)
	# Hull collision
	var sb: StaticBody3D = StaticBody3D.new()
	sb.position = Vector3(0, 0.7, 0)
	var cs: CollisionShape3D = CollisionShape3D.new()
	var bs: BoxShape3D = BoxShape3D.new()
	bs.size = Vector3(2.4, 1.4, 6.8)
	cs.shape = bs
	sb.add_child(cs)
	boat.add_child(sb)


static func _build_d8_sailing_yacht(geom: Node) -> void:
	## Epic-8 T71: elegant white sailing yacht — sleek hull, tall mast, big
	## triangular mainsail and small jib, gently bobbing offshore.
	var yacht: Node3D = Node3D.new()
	yacht.name = "D8SailingYacht"
	yacht.position = Vector3(D8_CENTER.x + 10, 0.4, -18)
	geom.add_child(yacht)
	# Hull: long flattened white sphere
	var hull_mat: StandardMaterial3D = StandardMaterial3D.new()
	hull_mat.albedo_color = Color(0.95, 0.95, 0.92)
	hull_mat.metallic = 0.2
	hull_mat.roughness = 0.35
	var hull: MeshInstance3D = MeshInstance3D.new()
	var hb: SphereMesh = SphereMesh.new()
	hb.radius = 1.0
	hb.height = 1.0
	hull.mesh = hb
	hull.material_override = hull_mat
	hull.scale = Vector3(1.0, 0.6, 3.5)
	hull.position = Vector3(0, 0.5, 0)
	yacht.add_child(hull)
	# Deck: flat box on top
	var deck_mat: StandardMaterial3D = StandardMaterial3D.new()
	deck_mat.albedo_color = Color(0.78, 0.62, 0.42)
	deck_mat.roughness = 0.7
	var deck: MeshInstance3D = MeshInstance3D.new()
	var db: BoxMesh = BoxMesh.new()
	db.size = Vector3(1.5, 0.12, 5.6)
	deck.mesh = db
	deck.material_override = deck_mat
	deck.position = Vector3(0, 0.95, 0)
	yacht.add_child(deck)
	# Mast
	var mast_mat: StandardMaterial3D = StandardMaterial3D.new()
	mast_mat.albedo_color = Color(0.85, 0.85, 0.88)
	mast_mat.metallic = 0.7
	mast_mat.roughness = 0.3
	var mast: MeshInstance3D = MeshInstance3D.new()
	var mm: CylinderMesh = CylinderMesh.new()
	mm.top_radius = 0.05
	mm.bottom_radius = 0.07
	mm.height = 5.5
	mast.mesh = mm
	mast.material_override = mast_mat
	mast.position = Vector3(0, 3.7, -0.4)
	yacht.add_child(mast)
	# Boom (horizontal pole at base of mainsail)
	var boom: MeshInstance3D = MeshInstance3D.new()
	var boom_mesh: CylinderMesh = CylinderMesh.new()
	boom_mesh.top_radius = 0.05
	boom_mesh.bottom_radius = 0.05
	boom_mesh.height = 2.5
	boom.mesh = boom_mesh
	boom.material_override = mast_mat
	boom.position = Vector3(0, 1.6, 0.85)
	boom.rotation_degrees = Vector3(90, 0, 0)
	yacht.add_child(boom)
	# Mainsail: white triangular prism (we use a thin scaled box rotated)
	var sail_mat: StandardMaterial3D = StandardMaterial3D.new()
	sail_mat.albedo_color = Color(0.98, 0.98, 0.95)
	sail_mat.roughness = 0.85
	sail_mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	var mainsail: MeshInstance3D = MeshInstance3D.new()
	var sail_mesh: PrismMesh = PrismMesh.new()
	sail_mesh.size = Vector3(2.4, 4.5, 0.04)
	sail_mesh.left_to_right = 0.0
	mainsail.mesh = sail_mesh
	mainsail.material_override = sail_mat
	mainsail.position = Vector3(0, 3.6, 0.4)
	mainsail.rotation_degrees = Vector3(0, 90, 0)
	yacht.add_child(mainsail)
	# Jib (small front sail)
	var jib: MeshInstance3D = MeshInstance3D.new()
	var jib_mesh: PrismMesh = PrismMesh.new()
	jib_mesh.size = Vector3(1.6, 3.0, 0.04)
	jib.mesh = jib_mesh
	jib.material_override = sail_mat
	jib.position = Vector3(0, 2.8, -1.7)
	jib.rotation_degrees = Vector3(0, 90, 0)
	yacht.add_child(jib)
	# Bob + sway tween
	var tw: Tween = yacht.create_tween().set_loops()
	tw.tween_property(yacht, "position:y", 0.65, 2.5).from(0.35)
	tw.tween_property(yacht, "position:y", 0.35, 2.5)
	var sway: Tween = yacht.create_tween().set_loops()
	sway.tween_property(yacht, "rotation_degrees:z", 3.0, 2.0)
	sway.tween_property(yacht, "rotation_degrees:z", -3.0, 2.0)
	# Hull collision
	var sb: StaticBody3D = StaticBody3D.new()
	sb.position = Vector3(0, 0.7, 0)
	var cs: CollisionShape3D = CollisionShape3D.new()
	var bs: BoxShape3D = BoxShape3D.new()
	bs.size = Vector3(2.0, 1.4, 7.0)
	cs.shape = bs
	sb.add_child(cs)
	yacht.add_child(sb)


static func _build_d8_shanty_singer_npc(town: Node) -> void:
	## Epic-8 T72: sea shanty singer NPC — old sailor with concertina box,
	## striped shirt, and a big floppy hat. Sways while singing.
	var slots: Node3D = town.get_node_or_null("NPCSlots") as Node3D
	if slots == null:
		return
	var slot: Marker3D = Marker3D.new()
	slot.name = "D8ShantySingerSlot"
	slot.position = Vector3(D8_CENTER.x + 8, 0, 8)
	slots.add_child(slot)
	var npc_scene: PackedScene = load("res://scenes/entities/npcs/VillagerR3.tscn") as PackedScene
	if npc_scene == null:
		return
	var npc: Node3D = npc_scene.instantiate() as Node3D
	npc.name = "D8ShantySinger"
	if "npc_name" in npc:
		npc.set("npc_name", "Old Salt Murphy")
	if "npc_id" in npc:
		npc.set("npc_id", "d8_shanty_singer")
	slot.add_child(npc)
	# Striped shirt: 4 horizontal bands red/white
	for i in range(4):
		var band: MeshInstance3D = MeshInstance3D.new()
		var bb: BoxMesh = BoxMesh.new()
		bb.size = Vector3(0.78, 0.18, 0.50)
		band.mesh = bb
		var bm: StandardMaterial3D = StandardMaterial3D.new()
		bm.albedo_color = Color(0.92, 0.92, 0.88) if (i % 2 == 0) else Color(0.78, 0.18, 0.18)
		bm.roughness = 0.7
		band.material_override = bm
		band.position = Vector3(0, 1.40 - i * 0.20, 0)
		npc.add_child(band)
	# Floppy hat (wide brim)
	var hat_mat: StandardMaterial3D = StandardMaterial3D.new()
	hat_mat.albedo_color = Color(0.45, 0.32, 0.18)
	hat_mat.roughness = 0.85
	var brim: MeshInstance3D = MeshInstance3D.new()
	var brim_mesh: CylinderMesh = CylinderMesh.new()
	brim_mesh.top_radius = 0.55
	brim_mesh.bottom_radius = 0.55
	brim_mesh.height = 0.05
	brim.mesh = brim_mesh
	brim.material_override = hat_mat
	brim.position = Vector3(0, 1.85, 0)
	npc.add_child(brim)
	var crown: MeshInstance3D = MeshInstance3D.new()
	var cm: CylinderMesh = CylinderMesh.new()
	cm.top_radius = 0.30
	cm.bottom_radius = 0.32
	cm.height = 0.30
	crown.mesh = cm
	crown.material_override = hat_mat
	crown.position = Vector3(0, 2.0, 0)
	npc.add_child(crown)
	# Concertina (small box held in front)
	var box_mat: StandardMaterial3D = StandardMaterial3D.new()
	box_mat.albedo_color = Color(0.20, 0.10, 0.08)
	box_mat.roughness = 0.5
	box_mat.metallic = 0.3
	var concertina: MeshInstance3D = MeshInstance3D.new()
	var cb: BoxMesh = BoxMesh.new()
	cb.size = Vector3(0.50, 0.32, 0.32)
	concertina.mesh = cb
	concertina.material_override = box_mat
	concertina.position = Vector3(0, 1.05, 0.45)
	npc.add_child(concertina)
	# Brass corners on concertina
	for sx in [-0.20, 0.20]:
		for sy in [-0.12, 0.12]:
			var stud: MeshInstance3D = MeshInstance3D.new()
			var sm2: SphereMesh = SphereMesh.new()
			sm2.radius = 0.04
			sm2.height = 0.08
			stud.mesh = sm2
			var smat: StandardMaterial3D = StandardMaterial3D.new()
			smat.albedo_color = Color(0.85, 0.65, 0.20)
			smat.metallic = 0.95
			smat.roughness = 0.20
			stud.material_override = smat
			stud.position = Vector3(sx, 1.05 + sy, 0.62)
			npc.add_child(stud)
	# Sway tween (whole body)
	var tw: Tween = npc.create_tween().set_loops()
	tw.tween_property(npc, "rotation_degrees:z", 4.0, 0.9)
	tw.tween_property(npc, "rotation_degrees:z", -4.0, 0.9)


static func _build_d8_crows_nest(geom: Node) -> void:
	## Epic-8 T73: tall wooden lookout post with a circular crow's nest at top
	## containing a small lookout figure peering through a brass spyglass.
	var nest: Node3D = Node3D.new()
	nest.name = "D8CrowsNest"
	nest.position = Vector3(D8_CENTER.x + 30, 0, 18)
	geom.add_child(nest)
	# Tall post
	var post_mat: StandardMaterial3D = StandardMaterial3D.new()
	post_mat.albedo_color = Color(0.45, 0.30, 0.18)
	post_mat.roughness = 0.85
	var post: MeshInstance3D = MeshInstance3D.new()
	var pm: CylinderMesh = CylinderMesh.new()
	pm.top_radius = 0.18
	pm.bottom_radius = 0.32
	pm.height = 8.5
	post.mesh = pm
	post.material_override = post_mat
	post.position = Vector3(0, 4.25, 0)
	nest.add_child(post)
	# Cross-braces (4 X-shaped)
	for ang in [0.0, 90.0]:
		var brace: MeshInstance3D = MeshInstance3D.new()
		var bm: BoxMesh = BoxMesh.new()
		bm.size = Vector3(0.10, 1.6, 0.10)
		brace.mesh = bm
		brace.material_override = post_mat
		brace.position = Vector3(0, 1.8, 0)
		brace.rotation_degrees = Vector3(0, ang, 35)
		nest.add_child(brace)
	# Crow's nest barrel: cylinder open top
	var nest_mat: StandardMaterial3D = StandardMaterial3D.new()
	nest_mat.albedo_color = Color(0.55, 0.40, 0.22)
	nest_mat.roughness = 0.8
	var barrel: MeshInstance3D = MeshInstance3D.new()
	var bm2: CylinderMesh = CylinderMesh.new()
	bm2.top_radius = 0.95
	bm2.bottom_radius = 0.85
	bm2.height = 1.0
	barrel.mesh = bm2
	barrel.material_override = nest_mat
	barrel.position = Vector3(0, 8.7, 0)
	nest.add_child(barrel)
	# Lookout figure (small head + body inside the nest)
	var skin_mat: StandardMaterial3D = StandardMaterial3D.new()
	skin_mat.albedo_color = Color(0.88, 0.72, 0.58)
	var head: MeshInstance3D = MeshInstance3D.new()
	var hm: SphereMesh = SphereMesh.new()
	hm.radius = 0.18
	hm.height = 0.36
	head.mesh = hm
	head.material_override = skin_mat
	head.position = Vector3(0, 9.40, 0)
	nest.add_child(head)
	# Spyglass (small brass cylinder in front of head)
	var brass: StandardMaterial3D = StandardMaterial3D.new()
	brass.albedo_color = Color(0.85, 0.65, 0.20)
	brass.metallic = 0.95
	brass.roughness = 0.2
	var glass: MeshInstance3D = MeshInstance3D.new()
	var gm: CylinderMesh = CylinderMesh.new()
	gm.top_radius = 0.06
	gm.bottom_radius = 0.04
	gm.height = 0.36
	glass.mesh = gm
	glass.material_override = brass
	glass.position = Vector3(0.0, 9.40, 0.30)
	glass.rotation_degrees = Vector3(90, 0, 0)
	nest.add_child(glass)
	# Pennant flag at very top
	var pole_top: MeshInstance3D = MeshInstance3D.new()
	var pmh: CylinderMesh = CylinderMesh.new()
	pmh.top_radius = 0.04
	pmh.bottom_radius = 0.04
	pmh.height = 1.0
	pole_top.mesh = pmh
	pole_top.material_override = post_mat
	pole_top.position = Vector3(0, 9.7, 0)
	nest.add_child(pole_top)
	var flag_mat: StandardMaterial3D = StandardMaterial3D.new()
	flag_mat.albedo_color = Color(0.92, 0.18, 0.18)
	flag_mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	var flag: MeshInstance3D = MeshInstance3D.new()
	var fm: BoxMesh = BoxMesh.new()
	fm.size = Vector3(0.04, 0.40, 0.65)
	flag.mesh = fm
	flag.material_override = flag_mat
	flag.position = Vector3(0.35, 9.95, 0)
	nest.add_child(flag)
	var fwave: Tween = flag.create_tween().set_loops()
	fwave.tween_property(flag, "rotation_degrees:y", 12.0, 0.7)
	fwave.tween_property(flag, "rotation_degrees:y", -12.0, 0.7)
	# Post collision
	var sb: StaticBody3D = StaticBody3D.new()
	sb.position = Vector3(0, 4.25, 0)
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cap: CapsuleShape3D = CapsuleShape3D.new()
	cap.radius = 0.35
	cap.height = 8.5
	cs.shape = cap
	sb.add_child(cs)
	nest.add_child(sb)


static func _build_d8_message_bottles(geom: Node) -> void:
	## Epic-8 T74: 6 drifting glass message bottles bobbing in the harbor —
	## clear amber bottles with rolled paper scrolls visible inside.
	var bottles: Node3D = Node3D.new()
	bottles.name = "D8MessageBottles"
	bottles.position = Vector3(D8_CENTER.x + 25, 0.25, -8)
	geom.add_child(bottles)
	var spots: Array[Vector2] = [
		Vector2(0, 0),
		Vector2(2.5, 1.8),
		Vector2(-1.8, 2.4),
		Vector2(3.6, -1.2),
		Vector2(-2.6, -0.8),
		Vector2(1.4, -2.6),
	]
	for i in range(spots.size()):
		var p: Vector2 = spots[i]
		var bottle: Node3D = Node3D.new()
		bottle.position = Vector3(p.x, 0, p.y)
		bottles.add_child(bottle)
		# Glass body (translucent amber)
		var glass_mat: StandardMaterial3D = StandardMaterial3D.new()
		glass_mat.albedo_color = Color(0.85, 0.65, 0.30, 0.55)
		glass_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		glass_mat.metallic = 0.2
		glass_mat.roughness = 0.10
		var body: MeshInstance3D = MeshInstance3D.new()
		var bm: CylinderMesh = CylinderMesh.new()
		bm.top_radius = 0.10
		bm.bottom_radius = 0.13
		bm.height = 0.42
		body.mesh = bm
		body.material_override = glass_mat
		body.position = Vector3(0, 0.21, 0)
		body.rotation_degrees = Vector3(90, 0, 0)
		bottle.add_child(body)
		# Bottle neck
		var neck: MeshInstance3D = MeshInstance3D.new()
		var nm: CylinderMesh = CylinderMesh.new()
		nm.top_radius = 0.05
		nm.bottom_radius = 0.07
		nm.height = 0.12
		neck.mesh = nm
		neck.material_override = glass_mat
		neck.position = Vector3(0.27, 0.21, 0)
		neck.rotation_degrees = Vector3(0, 0, 90)
		bottle.add_child(neck)
		# Cork stopper
		var cork_mat: StandardMaterial3D = StandardMaterial3D.new()
		cork_mat.albedo_color = Color(0.55, 0.38, 0.20)
		cork_mat.roughness = 0.85
		var cork: MeshInstance3D = MeshInstance3D.new()
		var cm: CylinderMesh = CylinderMesh.new()
		cm.top_radius = 0.05
		cm.bottom_radius = 0.05
		cm.height = 0.06
		cork.mesh = cm
		cork.material_override = cork_mat
		cork.position = Vector3(0.36, 0.21, 0)
		cork.rotation_degrees = Vector3(0, 0, 90)
		bottle.add_child(cork)
		# Scroll inside (small cream cylinder)
		var paper: StandardMaterial3D = StandardMaterial3D.new()
		paper.albedo_color = Color(0.92, 0.86, 0.65)
		var scroll: MeshInstance3D = MeshInstance3D.new()
		var sm: CylinderMesh = CylinderMesh.new()
		sm.top_radius = 0.04
		sm.bottom_radius = 0.04
		sm.height = 0.28
		scroll.mesh = sm
		scroll.material_override = paper
		scroll.position = Vector3(-0.05, 0.21, 0)
		scroll.rotation_degrees = Vector3(0, 0, 90)
		bottle.add_child(scroll)
		# Bob + spin tween
		var tw: Tween = bottle.create_tween().set_loops()
		var phase: float = float(i) * 0.4
		tw.tween_property(bottle, "position:y", 0.10, 1.0 + phase * 0.3).from(-0.05)
		tw.tween_property(bottle, "position:y", -0.05, 1.0 + phase * 0.3)
		var spin: Tween = bottle.create_tween().set_loops()
		spin.tween_property(bottle, "rotation_degrees:y", 360.0, 8.0 + phase).from(0.0)


static func _build_d8_tide_markers(geom: Node) -> void:
	## Epic-8 T75: 4 striped wooden tide-depth markers — tall poles with
	## red/white bands and a small numeric placard at top.
	var posts: Node3D = Node3D.new()
	posts.name = "D8TideMarkers"
	posts.position = Vector3(D8_CENTER.x + 5, 0, -10)
	geom.add_child(posts)
	for i in range(4):
		var post: Node3D = Node3D.new()
		post.position = Vector3(i * 3.5, 0, 0)
		posts.add_child(post)
		# 5 striped bands red/white alternating
		for b in range(5):
			var band: MeshInstance3D = MeshInstance3D.new()
			var bm: CylinderMesh = CylinderMesh.new()
			bm.top_radius = 0.15
			bm.bottom_radius = 0.15
			bm.height = 0.50
			band.mesh = bm
			var bmat: StandardMaterial3D = StandardMaterial3D.new()
			bmat.albedo_color = Color(0.78, 0.18, 0.18) if (b % 2 == 0) else Color(0.95, 0.95, 0.92)
			bmat.roughness = 0.7
			band.material_override = bmat
			band.position = Vector3(0, 0.25 + b * 0.50, 0)
			post.add_child(band)
		# Top placard (small white box)
		var placard_mat: StandardMaterial3D = StandardMaterial3D.new()
		placard_mat.albedo_color = Color(0.95, 0.95, 0.92)
		placard_mat.emission_enabled = true
		placard_mat.emission = Color(0.85, 0.92, 1.0)
		placard_mat.emission_energy_multiplier = 0.4
		var placard: MeshInstance3D = MeshInstance3D.new()
		var pb: BoxMesh = BoxMesh.new()
		pb.size = Vector3(0.55, 0.40, 0.05)
		placard.mesh = pb
		placard.material_override = placard_mat
		placard.position = Vector3(0, 3.0, 0.18)
		post.add_child(placard)
		# Per-post collision
		var sb: StaticBody3D = StaticBody3D.new()
		sb.position = Vector3(0, 1.4, 0)
		var cs: CollisionShape3D = CollisionShape3D.new()
		var cap: CapsuleShape3D = CapsuleShape3D.new()
		cap.radius = 0.18
		cap.height = 2.6
		cs.shape = cap
		sb.add_child(cs)
		post.add_child(sb)


static func _build_d8_customs_office(geom: Node) -> void:
	## Epic-8 T76: small wooden customs office — square building with sloped
	## roof, two windows, hanging sign reading "CUSTOMS".
	var office: Node3D = Node3D.new()
	office.name = "D8CustomsOffice"
	office.position = Vector3(D8_CENTER.x + 40, 0, -6)
	geom.add_child(office)
	# Walls (warm tan wood)
	var wall_mat: StandardMaterial3D = StandardMaterial3D.new()
	wall_mat.albedo_color = Color(0.62, 0.48, 0.30)
	wall_mat.roughness = 0.78
	var walls: MeshInstance3D = MeshInstance3D.new()
	var wb: BoxMesh = BoxMesh.new()
	wb.size = Vector3(4.4, 3.0, 4.0)
	walls.mesh = wb
	walls.material_override = wall_mat
	walls.position = Vector3(0, 1.5, 0)
	office.add_child(walls)
	# Roof (red prism)
	var roof_mat: StandardMaterial3D = StandardMaterial3D.new()
	roof_mat.albedo_color = Color(0.55, 0.18, 0.15)
	roof_mat.roughness = 0.65
	var roof: MeshInstance3D = MeshInstance3D.new()
	var pm: PrismMesh = PrismMesh.new()
	pm.size = Vector3(4.6, 1.4, 4.2)
	roof.mesh = pm
	roof.material_override = roof_mat
	roof.position = Vector3(0, 3.7, 0)
	office.add_child(roof)
	# Door (dark wood)
	var door_mat: StandardMaterial3D = StandardMaterial3D.new()
	door_mat.albedo_color = Color(0.30, 0.18, 0.10)
	door_mat.roughness = 0.7
	var door: MeshInstance3D = MeshInstance3D.new()
	var db: BoxMesh = BoxMesh.new()
	db.size = Vector3(0.85, 1.85, 0.06)
	door.mesh = db
	door.material_override = door_mat
	door.position = Vector3(0, 0.95, 2.03)
	office.add_child(door)
	# Door handle
	var handle_mat: StandardMaterial3D = StandardMaterial3D.new()
	handle_mat.albedo_color = Color(0.85, 0.65, 0.20)
	handle_mat.metallic = 0.95
	handle_mat.roughness = 0.20
	var handle: MeshInstance3D = MeshInstance3D.new()
	var hm: SphereMesh = SphereMesh.new()
	hm.radius = 0.04
	hm.height = 0.08
	handle.mesh = hm
	handle.material_override = handle_mat
	handle.position = Vector3(0.30, 0.95, 2.07)
	office.add_child(handle)
	# Two windows (cyan emissive)
	var win_mat: StandardMaterial3D = StandardMaterial3D.new()
	win_mat.albedo_color = Color(0.55, 0.85, 0.95)
	win_mat.emission_enabled = true
	win_mat.emission = Color(0.45, 0.85, 0.95)
	win_mat.emission_energy_multiplier = 0.95
	for sx in [-1.3, 1.3]:
		var win: MeshInstance3D = MeshInstance3D.new()
		var wbm: BoxMesh = BoxMesh.new()
		wbm.size = Vector3(0.85, 0.85, 0.06)
		win.mesh = wbm
		win.material_override = win_mat
		win.position = Vector3(sx, 1.65, 2.03)
		office.add_child(win)
		# Window frame cross
		var fmat: StandardMaterial3D = StandardMaterial3D.new()
		fmat.albedo_color = Color(0.30, 0.18, 0.10)
		var fh: MeshInstance3D = MeshInstance3D.new()
		var fhb: BoxMesh = BoxMesh.new()
		fhb.size = Vector3(0.85, 0.05, 0.07)
		fh.mesh = fhb
		fh.material_override = fmat
		fh.position = Vector3(sx, 1.65, 2.05)
		office.add_child(fh)
		var fv: MeshInstance3D = MeshInstance3D.new()
		var fvb: BoxMesh = BoxMesh.new()
		fvb.size = Vector3(0.05, 0.85, 0.07)
		fv.mesh = fvb
		fv.material_override = fmat
		fv.position = Vector3(sx, 1.65, 2.05)
		office.add_child(fv)
	# Hanging sign bracket
	var bracket: MeshInstance3D = MeshInstance3D.new()
	var brb: BoxMesh = BoxMesh.new()
	brb.size = Vector3(0.06, 0.06, 0.85)
	bracket.mesh = brb
	bracket.material_override = door_mat
	bracket.position = Vector3(2.3, 2.7, 2.40)
	office.add_child(bracket)
	# Sign body
	var sign_mat: StandardMaterial3D = StandardMaterial3D.new()
	sign_mat.albedo_color = Color(0.92, 0.85, 0.65)
	sign_mat.emission_enabled = true
	sign_mat.emission = Color(0.85, 0.75, 0.55)
	sign_mat.emission_energy_multiplier = 0.45
	var sign_node: MeshInstance3D = MeshInstance3D.new()
	var sb: BoxMesh = BoxMesh.new()
	sb.size = Vector3(0.06, 0.65, 1.05)
	sign_node.mesh = sb
	sign_node.material_override = sign_mat
	sign_node.position = Vector3(2.3, 2.30, 2.85)
	office.add_child(sign_node)
	# Sign label "CUSTOMS"
	var label: Label3D = Label3D.new()
	label.text = "CUSTOMS"
	label.font_size = 64
	label.modulate = Color(0.20, 0.10, 0.05)
	label.billboard = BaseMaterial3D.BILLBOARD_DISABLED
	label.position = Vector3(2.36, 2.30, 2.85)
	label.rotation_degrees = Vector3(0, 90, 0)
	office.add_child(label)
	# Sway tween for sign
	var sway: Tween = sign_node.create_tween().set_loops()
	sway.tween_property(sign_node, "rotation_degrees:x", 5.0, 1.4)
	sway.tween_property(sign_node, "rotation_degrees:x", -5.0, 1.4)
	# Building collision
	var stb: StaticBody3D = StaticBody3D.new()
	stb.position = Vector3(0, 1.5, 0)
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cbs: BoxShape3D = BoxShape3D.new()
	cbs.size = Vector3(4.4, 3.0, 4.0)
	cs.shape = cbs
	stb.add_child(cs)
	office.add_child(stb)


static func _build_d8_customs_officer_npc(town: Node) -> void:
	## Epic-8 T77: customs officer NPC — green uniform with badge, peaked cap,
	## holding a leather ledger and a brass stamp.
	var slots: Node3D = town.get_node_or_null("NPCSlots") as Node3D
	if slots == null:
		return
	var slot: Marker3D = Marker3D.new()
	slot.name = "D8CustomsOfficerSlot"
	slot.position = Vector3(D8_CENTER.x + 38, 0, -3)
	slots.add_child(slot)
	var npc_scene: PackedScene = load("res://scenes/entities/npcs/VillagerR3.tscn") as PackedScene
	if npc_scene == null:
		return
	var npc: Node3D = npc_scene.instantiate() as Node3D
	npc.name = "D8CustomsOfficer"
	if "npc_name" in npc:
		npc.set("npc_name", "Inspector Tariff")
	if "npc_id" in npc:
		npc.set("npc_id", "d8_customs_officer")
	slot.add_child(npc)
	# Olive green uniform
	var uni_mat: StandardMaterial3D = StandardMaterial3D.new()
	uni_mat.albedo_color = Color(0.30, 0.35, 0.18)
	uni_mat.roughness = 0.75
	var uni: MeshInstance3D = MeshInstance3D.new()
	var ub: BoxMesh = BoxMesh.new()
	ub.size = Vector3(0.85, 1.05, 0.55)
	uni.mesh = ub
	uni.material_override = uni_mat
	uni.position = Vector3(0, 1.05, 0)
	npc.add_child(uni)
	# Brass badge (round emissive disc)
	var badge_mat: StandardMaterial3D = StandardMaterial3D.new()
	badge_mat.albedo_color = Color(0.95, 0.75, 0.25)
	badge_mat.metallic = 0.95
	badge_mat.roughness = 0.15
	badge_mat.emission_enabled = true
	badge_mat.emission = Color(0.95, 0.75, 0.25)
	badge_mat.emission_energy_multiplier = 0.6
	var badge: MeshInstance3D = MeshInstance3D.new()
	var bsm: SphereMesh = SphereMesh.new()
	bsm.radius = 0.10
	bsm.height = 0.06
	badge.mesh = bsm
	badge.material_override = badge_mat
	badge.position = Vector3(-0.20, 1.30, 0.30)
	npc.add_child(badge)
	# Peaked cap
	var cap_mat: StandardMaterial3D = StandardMaterial3D.new()
	cap_mat.albedo_color = Color(0.20, 0.25, 0.12)
	cap_mat.roughness = 0.7
	var cap: MeshInstance3D = MeshInstance3D.new()
	var cm: CylinderMesh = CylinderMesh.new()
	cm.top_radius = 0.32
	cm.bottom_radius = 0.34
	cm.height = 0.18
	cap.mesh = cm
	cap.material_override = cap_mat
	cap.position = Vector3(0, 1.95, 0)
	npc.add_child(cap)
	var peak: MeshInstance3D = MeshInstance3D.new()
	var pkb: BoxMesh = BoxMesh.new()
	pkb.size = Vector3(0.50, 0.04, 0.20)
	peak.mesh = pkb
	peak.material_override = cap_mat
	peak.position = Vector3(0, 1.86, 0.28)
	npc.add_child(peak)
	# Cap badge (small brass square on front)
	var cb: MeshInstance3D = MeshInstance3D.new()
	var cbm: BoxMesh = BoxMesh.new()
	cbm.size = Vector3(0.12, 0.10, 0.02)
	cb.mesh = cbm
	cb.material_override = badge_mat
	cb.position = Vector3(0, 1.96, 0.34)
	npc.add_child(cb)
	# Leather ledger held in left hand
	var ldg_mat: StandardMaterial3D = StandardMaterial3D.new()
	ldg_mat.albedo_color = Color(0.30, 0.18, 0.10)
	ldg_mat.roughness = 0.6
	var ledger: MeshInstance3D = MeshInstance3D.new()
	var ldb: BoxMesh = BoxMesh.new()
	ldb.size = Vector3(0.40, 0.50, 0.10)
	ledger.mesh = ldb
	ledger.material_override = ldg_mat
	ledger.position = Vector3(-0.40, 1.05, 0.35)
	ledger.rotation_degrees = Vector3(-15, -10, 0)
	npc.add_child(ledger)
	# Brass stamp (small cylinder)
	var stamp: MeshInstance3D = MeshInstance3D.new()
	var stm: CylinderMesh = CylinderMesh.new()
	stm.top_radius = 0.06
	stm.bottom_radius = 0.06
	stm.height = 0.18
	stamp.mesh = stm
	stamp.material_override = badge_mat
	stamp.position = Vector3(0.40, 1.10, 0.35)
	stamp.rotation_degrees = Vector3(-30, 0, 0)
	npc.add_child(stamp)


static func _build_d8_anchor_chain(geom: Node) -> void:
	## Epic-8 T78: heavy iron anchor chain coiled on the dock — concentric
	## rings of dark metal links with a big iron anchor at the center.
	var pile: Node3D = Node3D.new()
	pile.name = "D8AnchorChain"
	pile.position = Vector3(D8_CENTER.x + 12, 0, 5)
	geom.add_child(pile)
	# Iron material
	var iron: StandardMaterial3D = StandardMaterial3D.new()
	iron.albedo_color = Color(0.18, 0.18, 0.20)
	iron.metallic = 0.85
	iron.roughness = 0.55
	# Coil: 4 concentric torus rings
	for i in range(4):
		var ring: MeshInstance3D = MeshInstance3D.new()
		var tm: TorusMesh = TorusMesh.new()
		tm.inner_radius = 1.0 - i * 0.22
		tm.outer_radius = 1.18 - i * 0.22
		ring.mesh = tm
		ring.material_override = iron
		ring.position = Vector3(0, 0.10 + i * 0.12, 0)
		pile.add_child(ring)
	# Big anchor at center
	var anchor: Node3D = Node3D.new()
	anchor.position = Vector3(0, 0.55, 0)
	pile.add_child(anchor)
	# Shank (vertical bar)
	var shank: MeshInstance3D = MeshInstance3D.new()
	var skm: BoxMesh = BoxMesh.new()
	skm.size = Vector3(0.18, 1.40, 0.18)
	shank.mesh = skm
	shank.material_override = iron
	shank.position = Vector3(0, 0.70, 0)
	anchor.add_child(shank)
	# Stock (horizontal bar at top)
	var stock: MeshInstance3D = MeshInstance3D.new()
	var stm2: BoxMesh = BoxMesh.new()
	stm2.size = Vector3(1.10, 0.12, 0.12)
	stock.mesh = stm2
	stock.material_override = iron
	stock.position = Vector3(0, 1.30, 0)
	anchor.add_child(stock)
	# Top ring
	var ring_top: MeshInstance3D = MeshInstance3D.new()
	var rtm: TorusMesh = TorusMesh.new()
	rtm.inner_radius = 0.10
	rtm.outer_radius = 0.18
	ring_top.mesh = rtm
	ring_top.material_override = iron
	ring_top.position = Vector3(0, 1.50, 0)
	anchor.add_child(ring_top)
	# Two flukes (curved arms at bottom — use prism)
	for sx in [-0.45, 0.45]:
		var fluke: MeshInstance3D = MeshInstance3D.new()
		var fpm: PrismMesh = PrismMesh.new()
		fpm.size = Vector3(0.55, 0.60, 0.16)
		fluke.mesh = fpm
		fluke.material_override = iron
		fluke.position = Vector3(sx, 0.20, 0)
		fluke.rotation_degrees = Vector3(0, 0, -25 if sx < 0 else 25)
		anchor.add_child(fluke)
	# Pile collision
	var sb: StaticBody3D = StaticBody3D.new()
	sb.position = Vector3(0, 0.55, 0)
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cyl: CylinderShape3D = CylinderShape3D.new()
	cyl.radius = 1.30
	cyl.height = 1.10
	cs.shape = cyl
	sb.add_child(cs)
	pile.add_child(sb)


static func _build_d8_whale_watch_tower(geom: Node) -> void:
	## Epic-8 T79: tall whale-watching observation platform — wooden tower with
	## ladder and big mounted brass binoculars at the top.
	var tower: Node3D = Node3D.new()
	tower.name = "D8WhaleWatchTower"
	tower.position = Vector3(D8_CENTER.x + 55, 0, -14)
	geom.add_child(tower)
	# 4 corner posts
	var wood_mat: StandardMaterial3D = StandardMaterial3D.new()
	wood_mat.albedo_color = Color(0.45, 0.30, 0.18)
	wood_mat.roughness = 0.85
	for sx in [-1.0, 1.0]:
		for sz in [-1.0, 1.0]:
			var leg: MeshInstance3D = MeshInstance3D.new()
			var lb: BoxMesh = BoxMesh.new()
			lb.size = Vector3(0.20, 6.0, 0.20)
			leg.mesh = lb
			leg.material_override = wood_mat
			leg.position = Vector3(sx, 3.0, sz)
			tower.add_child(leg)
	# Cross-braces (X on each side)
	for ang_z in [0.0, 180.0]:
		var brace: MeshInstance3D = MeshInstance3D.new()
		var bb: BoxMesh = BoxMesh.new()
		bb.size = Vector3(2.8, 0.10, 0.10)
		brace.mesh = bb
		brace.material_override = wood_mat
		brace.position = Vector3(0, 2.0, sin(deg_to_rad(ang_z)) * 0.0 + (1.0 if ang_z == 0 else -1.0))
		brace.rotation_degrees = Vector3(0, 0, 35)
		tower.add_child(brace)
	# Top platform
	var deck_mat: StandardMaterial3D = StandardMaterial3D.new()
	deck_mat.albedo_color = Color(0.55, 0.40, 0.25)
	deck_mat.roughness = 0.8
	var deck: MeshInstance3D = MeshInstance3D.new()
	var dm: BoxMesh = BoxMesh.new()
	dm.size = Vector3(2.6, 0.18, 2.6)
	deck.mesh = dm
	deck.material_override = deck_mat
	deck.position = Vector3(0, 6.0, 0)
	tower.add_child(deck)
	# Railing (4 sides — thin boxes)
	for r in range(4):
		var rail: MeshInstance3D = MeshInstance3D.new()
		var rb: BoxMesh = BoxMesh.new()
		rb.size = Vector3(2.6, 0.08, 0.06)
		rail.mesh = rb
		rail.material_override = wood_mat
		rail.position = Vector3(0, 6.55, 0)
		rail.rotation_degrees = Vector3(0, r * 90, 0)
		var off: float = 1.30
		if r == 0: rail.position += Vector3(0, 0, off)
		elif r == 1: rail.position += Vector3(off, 0, 0)
		elif r == 2: rail.position += Vector3(0, 0, -off)
		else: rail.position += Vector3(-off, 0, 0)
		tower.add_child(rail)
	# Brass binoculars (two large cylinders side by side)
	var brass: StandardMaterial3D = StandardMaterial3D.new()
	brass.albedo_color = Color(0.85, 0.65, 0.20)
	brass.metallic = 0.95
	brass.roughness = 0.15
	for sx in [-0.18, 0.18]:
		var tube: MeshInstance3D = MeshInstance3D.new()
		var tcm: CylinderMesh = CylinderMesh.new()
		tcm.top_radius = 0.16
		tcm.bottom_radius = 0.20
		tcm.height = 0.85
		tube.mesh = tcm
		tube.material_override = brass
		tube.position = Vector3(sx, 6.95, 0.30)
		tube.rotation_degrees = Vector3(75, 0, 0)
		tower.add_child(tube)
	# Mount post
	var mount: MeshInstance3D = MeshInstance3D.new()
	var mpm: CylinderMesh = CylinderMesh.new()
	mpm.top_radius = 0.10
	mpm.bottom_radius = 0.15
	mpm.height = 0.50
	mount.mesh = mpm
	mount.material_override = brass
	mount.position = Vector3(0, 6.40, 0.30)
	tower.add_child(mount)
	# Ladder (vertical bar with rungs)
	for i in range(8):
		var rung: MeshInstance3D = MeshInstance3D.new()
		var rgm: BoxMesh = BoxMesh.new()
		rgm.size = Vector3(0.55, 0.06, 0.06)
		rung.mesh = rgm
		rung.material_override = wood_mat
		rung.position = Vector3(0, 0.30 + i * 0.70, 1.10)
		tower.add_child(rung)
	# Tower collision (4 leg posts as a single box)
	var sb: StaticBody3D = StaticBody3D.new()
	sb.position = Vector3(0, 3.0, 0)
	var cs: CollisionShape3D = CollisionShape3D.new()
	var bs: BoxShape3D = BoxShape3D.new()
	bs.size = Vector3(2.4, 6.0, 2.4)
	cs.shape = bs
	sb.add_child(cs)
	tower.add_child(sb)


static func _build_d8_tied_barrels(geom: Node) -> void:
	## Epic-8 T80: 5 wooden barrels tied together at the dock edge, bobbing
	## gently with rope strung between them.
	var dock_barrels: Node3D = Node3D.new()
	dock_barrels.name = "D8TiedBarrels"
	dock_barrels.position = Vector3(D8_CENTER.x - 5, 0.4, 12)
	geom.add_child(dock_barrels)
	# Wood + iron band materials
	var wood: StandardMaterial3D = StandardMaterial3D.new()
	wood.albedo_color = Color(0.48, 0.30, 0.15)
	wood.roughness = 0.85
	var band_mat: StandardMaterial3D = StandardMaterial3D.new()
	band_mat.albedo_color = Color(0.20, 0.18, 0.18)
	band_mat.metallic = 0.7
	band_mat.roughness = 0.45
	for i in range(5):
		var barrel: Node3D = Node3D.new()
		barrel.position = Vector3(i * 1.10, 0, 0)
		dock_barrels.add_child(barrel)
		# Body
		var body: MeshInstance3D = MeshInstance3D.new()
		var bm: CylinderMesh = CylinderMesh.new()
		bm.top_radius = 0.36
		bm.bottom_radius = 0.36
		bm.height = 0.85
		body.mesh = bm
		body.material_override = wood
		body.position = Vector3(0, 0.42, 0)
		barrel.add_child(body)
		# Iron bands (top + bottom)
		for sy in [0.15, 0.65]:
			var band: MeshInstance3D = MeshInstance3D.new()
			var tm: TorusMesh = TorusMesh.new()
			tm.inner_radius = 0.36
			tm.outer_radius = 0.40
			band.mesh = tm
			band.material_override = band_mat
			band.position = Vector3(0, sy, 0)
			barrel.add_child(band)
		# Per-barrel bob tween (offset phases)
		var tw: Tween = barrel.create_tween().set_loops()
		var phase: float = float(i) * 0.18
		tw.tween_property(barrel, "position:y", 0.18 + phase, 1.6).from(-0.05)
		tw.tween_property(barrel, "position:y", -0.05, 1.6)
		# Per-barrel collision
		var sb: StaticBody3D = StaticBody3D.new()
		sb.position = Vector3(0, 0.42, 0)
		var cs: CollisionShape3D = CollisionShape3D.new()
		var cyl: CylinderShape3D = CylinderShape3D.new()
		cyl.radius = 0.36
		cyl.height = 0.85
		cs.shape = cyl
		sb.add_child(cs)
		barrel.add_child(sb)
	# Connecting rope (long thin cylinder spanning all barrels)
	var rope_mat: StandardMaterial3D = StandardMaterial3D.new()
	rope_mat.albedo_color = Color(0.78, 0.65, 0.40)
	rope_mat.roughness = 0.85
	var rope: MeshInstance3D = MeshInstance3D.new()
	var rcm: CylinderMesh = CylinderMesh.new()
	rcm.top_radius = 0.04
	rcm.bottom_radius = 0.04
	rcm.height = 5.0
	rope.mesh = rcm
	rope.material_override = rope_mat
	rope.position = Vector3(2.20, 0.85, 0)
	rope.rotation_degrees = Vector3(0, 0, 90)
	dock_barrels.add_child(rope)


static func _build_d8_mermaid_fountain(geom: Node) -> void:
	## Epic-8 T81: bronze mermaid statue on a stone basin — decorative
	## fountain with a particle water spray and a soft cyan light.
	var fountain: Node3D = Node3D.new()
	fountain.name = "D8MermaidFountain"
	fountain.position = Vector3(D8_CENTER.x + 45, 0, 6)
	geom.add_child(fountain)
	# Stone basin (wide flat cylinder)
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.62, 0.60, 0.58)
	stone_mat.roughness = 0.85
	var basin: MeshInstance3D = MeshInstance3D.new()
	var bm: CylinderMesh = CylinderMesh.new()
	bm.top_radius = 2.4
	bm.bottom_radius = 2.6
	bm.height = 0.55
	basin.mesh = bm
	basin.material_override = stone_mat
	basin.position = Vector3(0, 0.28, 0)
	fountain.add_child(basin)
	# Inner water disc (cyan emissive)
	var water_mat: StandardMaterial3D = StandardMaterial3D.new()
	water_mat.albedo_color = Color(0.30, 0.65, 0.85, 0.75)
	water_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	water_mat.emission_enabled = true
	water_mat.emission = Color(0.35, 0.75, 0.95)
	water_mat.emission_energy_multiplier = 0.45
	var water: MeshInstance3D = MeshInstance3D.new()
	var wm: CylinderMesh = CylinderMesh.new()
	wm.top_radius = 2.20
	wm.bottom_radius = 2.20
	wm.height = 0.10
	water.mesh = wm
	water.material_override = water_mat
	water.position = Vector3(0, 0.55, 0)
	fountain.add_child(water)
	# Bronze mermaid statue (stylized)
	var bronze: StandardMaterial3D = StandardMaterial3D.new()
	bronze.albedo_color = Color(0.55, 0.40, 0.20)
	bronze.metallic = 0.85
	bronze.roughness = 0.35
	var mermaid: Node3D = Node3D.new()
	mermaid.position = Vector3(0, 0.60, 0)
	fountain.add_child(mermaid)
	# Tail (curved prism — wide at base)
	var tail: MeshInstance3D = MeshInstance3D.new()
	var tcm: CylinderMesh = CylinderMesh.new()
	tcm.top_radius = 0.20
	tcm.bottom_radius = 0.45
	tcm.height = 1.30
	tail.mesh = tcm
	tail.material_override = bronze
	tail.position = Vector3(0, 0.65, 0)
	tail.rotation_degrees = Vector3(-12, 0, 0)
	mermaid.add_child(tail)
	# Tail fin (flat horizontal prism)
	var fin: MeshInstance3D = MeshInstance3D.new()
	var fpm: PrismMesh = PrismMesh.new()
	fpm.size = Vector3(0.85, 0.45, 0.10)
	fin.mesh = fpm
	fin.material_override = bronze
	fin.position = Vector3(0, 1.50, -0.15)
	fin.rotation_degrees = Vector3(-90, 0, 0)
	mermaid.add_child(fin)
	# Torso
	var torso: MeshInstance3D = MeshInstance3D.new()
	var tsm: SphereMesh = SphereMesh.new()
	tsm.radius = 0.35
	tsm.height = 0.85
	torso.mesh = tsm
	torso.material_override = bronze
	torso.position = Vector3(0, 1.55, 0.10)
	mermaid.add_child(torso)
	# Head
	var head: MeshInstance3D = MeshInstance3D.new()
	var hsm: SphereMesh = SphereMesh.new()
	hsm.radius = 0.22
	hsm.height = 0.44
	head.mesh = hsm
	head.material_override = bronze
	head.position = Vector3(0, 2.10, 0.10)
	mermaid.add_child(head)
	# Arms raised (two thin cylinders)
	for sx in [-0.35, 0.35]:
		var arm: MeshInstance3D = MeshInstance3D.new()
		var am: CylinderMesh = CylinderMesh.new()
		am.top_radius = 0.07
		am.bottom_radius = 0.08
		am.height = 0.95
		arm.mesh = am
		arm.material_override = bronze
		arm.position = Vector3(sx, 2.10, 0.05)
		arm.rotation_degrees = Vector3(0, 0, 35 if sx < 0 else -35)
		mermaid.add_child(arm)
	# Conch shell at top (small spiral)
	var conch: MeshInstance3D = MeshInstance3D.new()
	var ccm: SphereMesh = SphereMesh.new()
	ccm.radius = 0.14
	ccm.height = 0.28
	conch.mesh = ccm
	conch.material_override = bronze
	conch.position = Vector3(0, 2.55, 0)
	mermaid.add_child(conch)
	# Particle water spray from conch
	var spray: GPUParticles3D = GPUParticles3D.new()
	spray.position = Vector3(0, 2.65, 0)
	spray.amount = 60
	spray.lifetime = 1.6
	var pm: ParticleProcessMaterial = ParticleProcessMaterial.new()
	pm.direction = Vector3(0, 1, 0)
	pm.spread = 25.0
	pm.initial_velocity_min = 1.5
	pm.initial_velocity_max = 2.6
	pm.gravity = Vector3(0, -3.5, 0)
	pm.scale_min = 0.06
	pm.scale_max = 0.12
	pm.color = Color(0.55, 0.85, 0.95, 0.8)
	spray.process_material = pm
	var sphere_drop: SphereMesh = SphereMesh.new()
	sphere_drop.radius = 0.05
	sphere_drop.height = 0.10
	spray.draw_pass_1 = sphere_drop
	mermaid.add_child(spray)
	# Soft cyan light
	var lt: OmniLight3D = OmniLight3D.new()
	lt.light_color = Color(0.55, 0.85, 0.95)
	lt.light_energy = 1.8
	lt.omni_range = 6.0
	lt.position = Vector3(0, 1.5, 0)
	fountain.add_child(lt)
	# Basin collision
	var sb: StaticBody3D = StaticBody3D.new()
	sb.position = Vector3(0, 0.30, 0)
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cyl: CylinderShape3D = CylinderShape3D.new()
	cyl.radius = 2.5
	cyl.height = 0.6
	cs.shape = cyl
	sb.add_child(cs)
	fountain.add_child(sb)


static func _build_d8_cartographer_npc(town: Node) -> void:
	## Epic-8 T82: cartographer NPC — hunched figure with rolled maps slung
	## across the back, holding a quill and a half-unrolled chart.
	var slots: Node3D = town.get_node_or_null("NPCSlots") as Node3D
	if slots == null:
		return
	var slot: Marker3D = Marker3D.new()
	slot.name = "D8CartographerSlot"
	slot.position = Vector3(D8_CENTER.x + 42, 0, 8)
	slots.add_child(slot)
	var npc_scene: PackedScene = load("res://scenes/entities/npcs/VillagerR3.tscn") as PackedScene
	if npc_scene == null:
		return
	var npc: Node3D = npc_scene.instantiate() as Node3D
	npc.name = "D8Cartographer"
	if "npc_name" in npc:
		npc.set("npc_name", "Charteress Vellum")
	if "npc_id" in npc:
		npc.set("npc_id", "d8_cartographer")
	slot.add_child(npc)
	# Hooded brown coat
	var coat_mat: StandardMaterial3D = StandardMaterial3D.new()
	coat_mat.albedo_color = Color(0.42, 0.28, 0.16)
	coat_mat.roughness = 0.85
	var coat: MeshInstance3D = MeshInstance3D.new()
	var cb: BoxMesh = BoxMesh.new()
	cb.size = Vector3(0.85, 1.20, 0.55)
	coat.mesh = cb
	coat.material_override = coat_mat
	coat.position = Vector3(0, 0.95, 0)
	coat.rotation_degrees = Vector3(8, 0, 0)
	npc.add_child(coat)
	# Hood (sphere top)
	var hood: MeshInstance3D = MeshInstance3D.new()
	var hsm: SphereMesh = SphereMesh.new()
	hsm.radius = 0.32
	hsm.height = 0.55
	hood.mesh = hsm
	hood.material_override = coat_mat
	hood.position = Vector3(0, 1.85, -0.05)
	npc.add_child(hood)
	# Map tube on back (long cylinder slung across)
	var leather: StandardMaterial3D = StandardMaterial3D.new()
	leather.albedo_color = Color(0.30, 0.18, 0.10)
	leather.roughness = 0.65
	var tube: MeshInstance3D = MeshInstance3D.new()
	var tm: CylinderMesh = CylinderMesh.new()
	tm.top_radius = 0.10
	tm.bottom_radius = 0.10
	tm.height = 1.10
	tube.mesh = tm
	tube.material_override = leather
	tube.position = Vector3(0.20, 1.20, -0.32)
	tube.rotation_degrees = Vector3(0, 0, 65)
	npc.add_child(tube)
	# Half-unrolled chart held in front
	var paper: StandardMaterial3D = StandardMaterial3D.new()
	paper.albedo_color = Color(0.92, 0.85, 0.62)
	paper.emission_enabled = true
	paper.emission = Color(0.85, 0.78, 0.55)
	paper.emission_energy_multiplier = 0.30
	var chart: MeshInstance3D = MeshInstance3D.new()
	var chb: BoxMesh = BoxMesh.new()
	chb.size = Vector3(0.65, 0.45, 0.04)
	chart.mesh = chb
	chart.material_override = paper
	chart.position = Vector3(0, 1.05, 0.42)
	chart.rotation_degrees = Vector3(-25, 0, 0)
	npc.add_child(chart)
	# Quill (thin white feather cylinder at angle)
	var feather_mat: StandardMaterial3D = StandardMaterial3D.new()
	feather_mat.albedo_color = Color(0.95, 0.95, 0.92)
	var quill: MeshInstance3D = MeshInstance3D.new()
	var qm: CylinderMesh = CylinderMesh.new()
	qm.top_radius = 0.015
	qm.bottom_radius = 0.025
	qm.height = 0.40
	quill.mesh = qm
	quill.material_override = feather_mat
	quill.position = Vector3(0.30, 1.25, 0.50)
	quill.rotation_degrees = Vector3(60, 0, -25)
	npc.add_child(quill)


static func _build_d8_market_raft(geom: Node) -> void:
	## Epic-8 T83: small floating market raft — square wooden raft with a
	## striped awning and 6 colorful goods crates on top, bobbing offshore.
	var raft: Node3D = Node3D.new()
	raft.name = "D8MarketRaft"
	raft.position = Vector3(D8_CENTER.x + 18, 0.30, 16)
	geom.add_child(raft)
	# Raft base (wide flat box)
	var deck_mat: StandardMaterial3D = StandardMaterial3D.new()
	deck_mat.albedo_color = Color(0.55, 0.38, 0.20)
	deck_mat.roughness = 0.85
	var deck: MeshInstance3D = MeshInstance3D.new()
	var db: BoxMesh = BoxMesh.new()
	db.size = Vector3(3.6, 0.20, 3.0)
	deck.mesh = db
	deck.material_override = deck_mat
	deck.position = Vector3(0, 0.10, 0)
	raft.add_child(deck)
	# 4 corner posts holding the awning
	var post_mat: StandardMaterial3D = StandardMaterial3D.new()
	post_mat.albedo_color = Color(0.45, 0.30, 0.18)
	for sx in [-1.6, 1.6]:
		for sz in [-1.2, 1.2]:
			var post: MeshInstance3D = MeshInstance3D.new()
			var pcm: CylinderMesh = CylinderMesh.new()
			pcm.top_radius = 0.05
			pcm.bottom_radius = 0.06
			pcm.height = 1.85
			post.mesh = pcm
			post.material_override = post_mat
			post.position = Vector3(sx, 1.10, sz)
			raft.add_child(post)
	# Striped awning (4 alternating colored strips)
	var stripe_colors: Array[Color] = [
		Color(0.85, 0.20, 0.20),
		Color(0.92, 0.92, 0.88),
		Color(0.85, 0.20, 0.20),
		Color(0.92, 0.92, 0.88),
	]
	for i in range(4):
		var strip: MeshInstance3D = MeshInstance3D.new()
		var sb: BoxMesh = BoxMesh.new()
		sb.size = Vector3(3.6, 0.05, 0.70)
		strip.mesh = sb
		var smat: StandardMaterial3D = StandardMaterial3D.new()
		smat.albedo_color = stripe_colors[i]
		smat.roughness = 0.7
		smat.cull_mode = BaseMaterial3D.CULL_DISABLED
		strip.material_override = smat
		strip.position = Vector3(0, 2.05, -1.05 + i * 0.70)
		raft.add_child(strip)
	# 6 goods crates (small colorful boxes on the deck)
	var crate_hues: Array[Color] = [
		Color(0.85, 0.55, 0.20),
		Color(0.30, 0.65, 0.30),
		Color(0.55, 0.30, 0.65),
		Color(0.20, 0.55, 0.85),
		Color(0.85, 0.85, 0.30),
		Color(0.85, 0.30, 0.55),
	]
	var crate_pos: Array[Vector3] = [
		Vector3(-1.0, 0.42, -0.8),
		Vector3(0.0, 0.42, -0.8),
		Vector3(1.0, 0.42, -0.8),
		Vector3(-1.0, 0.42, 0.8),
		Vector3(0.0, 0.42, 0.8),
		Vector3(1.0, 0.42, 0.8),
	]
	for i in range(6):
		var crate: MeshInstance3D = MeshInstance3D.new()
		var ccb: BoxMesh = BoxMesh.new()
		ccb.size = Vector3(0.55, 0.45, 0.55)
		crate.mesh = ccb
		var ccmat: StandardMaterial3D = StandardMaterial3D.new()
		ccmat.albedo_color = crate_hues[i]
		ccmat.roughness = 0.65
		crate.material_override = ccmat
		crate.position = crate_pos[i]
		raft.add_child(crate)
	# Bob + sway tweens
	var tw: Tween = raft.create_tween().set_loops()
	tw.tween_property(raft, "position:y", 0.55, 2.4).from(0.25)
	tw.tween_property(raft, "position:y", 0.25, 2.4)
	var sway: Tween = raft.create_tween().set_loops()
	sway.tween_property(raft, "rotation_degrees:z", 2.5, 1.9)
	sway.tween_property(raft, "rotation_degrees:z", -2.5, 1.9)
	# Raft collision
	var stb: StaticBody3D = StaticBody3D.new()
	stb.position = Vector3(0, 0.10, 0)
	var cs: CollisionShape3D = CollisionShape3D.new()
	var bs: BoxShape3D = BoxShape3D.new()
	bs.size = Vector3(3.6, 0.30, 3.0)
	cs.shape = bs
	stb.add_child(cs)
	raft.add_child(stb)


static func _build_d8_smokehouse(geom: Node) -> void:
	## Epic-8 T84: small fish smokehouse — wooden shed with a stone chimney
	## emitting a slow particle smoke trail.
	var shed: Node3D = Node3D.new()
	shed.name = "D8Smokehouse"
	shed.position = Vector3(D8_CENTER.x + 28, 0, 12)
	geom.add_child(shed)
	# Walls
	var wall_mat: StandardMaterial3D = StandardMaterial3D.new()
	wall_mat.albedo_color = Color(0.40, 0.25, 0.12)
	wall_mat.roughness = 0.85
	var walls: MeshInstance3D = MeshInstance3D.new()
	var wb: BoxMesh = BoxMesh.new()
	wb.size = Vector3(2.6, 2.4, 2.6)
	walls.mesh = wb
	walls.material_override = wall_mat
	walls.position = Vector3(0, 1.20, 0)
	shed.add_child(walls)
	# Sloped roof
	var roof_mat: StandardMaterial3D = StandardMaterial3D.new()
	roof_mat.albedo_color = Color(0.30, 0.18, 0.08)
	roof_mat.roughness = 0.75
	var roof: MeshInstance3D = MeshInstance3D.new()
	var pm: PrismMesh = PrismMesh.new()
	pm.size = Vector3(2.8, 1.0, 2.8)
	roof.mesh = pm
	roof.material_override = roof_mat
	roof.position = Vector3(0, 2.85, 0)
	shed.add_child(roof)
	# Door (small dark)
	var door_mat: StandardMaterial3D = StandardMaterial3D.new()
	door_mat.albedo_color = Color(0.18, 0.10, 0.05)
	var door: MeshInstance3D = MeshInstance3D.new()
	var ddb: BoxMesh = BoxMesh.new()
	ddb.size = Vector3(0.65, 1.4, 0.05)
	door.mesh = ddb
	door.material_override = door_mat
	door.position = Vector3(0, 0.75, 1.32)
	shed.add_child(door)
	# Stone chimney
	var stone: StandardMaterial3D = StandardMaterial3D.new()
	stone.albedo_color = Color(0.55, 0.52, 0.50)
	stone.roughness = 0.85
	var chimney: MeshInstance3D = MeshInstance3D.new()
	var cb: BoxMesh = BoxMesh.new()
	cb.size = Vector3(0.55, 1.6, 0.55)
	chimney.mesh = cb
	chimney.material_override = stone
	chimney.position = Vector3(0.85, 3.30, -0.55)
	shed.add_child(chimney)
	# Smoke particles from chimney top
	var smoke: GPUParticles3D = GPUParticles3D.new()
	smoke.position = Vector3(0.85, 4.10, -0.55)
	smoke.amount = 30
	smoke.lifetime = 3.5
	var spm: ParticleProcessMaterial = ParticleProcessMaterial.new()
	spm.direction = Vector3(0, 1, 0)
	spm.spread = 18.0
	spm.initial_velocity_min = 0.45
	spm.initial_velocity_max = 0.85
	spm.gravity = Vector3(0.15, 0.4, 0)
	spm.scale_min = 0.30
	spm.scale_max = 0.75
	spm.color = Color(0.65, 0.62, 0.58, 0.55)
	smoke.process_material = spm
	var smoke_mesh: SphereMesh = SphereMesh.new()
	smoke_mesh.radius = 0.20
	smoke_mesh.height = 0.40
	smoke.draw_pass_1 = smoke_mesh
	shed.add_child(smoke)
	# Warm glow inside the door cracks
	var glow: OmniLight3D = OmniLight3D.new()
	glow.light_color = Color(1.0, 0.55, 0.20)
	glow.light_energy = 1.4
	glow.omni_range = 4.0
	glow.position = Vector3(0, 0.9, 1.30)
	shed.add_child(glow)
	# Building collision
	var stb: StaticBody3D = StaticBody3D.new()
	stb.position = Vector3(0, 1.20, 0)
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cbs: BoxShape3D = BoxShape3D.new()
	cbs.size = Vector3(2.6, 2.4, 2.6)
	cs.shape = cbs
	stb.add_child(cs)
	shed.add_child(stb)


static func _build_d8_wind_chimes(geom: Node) -> void:
	## Epic-8 T85: tall post with hanging wind chimes — 6 brass tubes of
	## varying lengths suspended from a horizontal cross-bar, gentle sway.
	var chime: Node3D = Node3D.new()
	chime.name = "D8WindChimes"
	chime.position = Vector3(D8_CENTER.x + 35, 0, 4)
	geom.add_child(chime)
	# Vertical post
	var post_mat: StandardMaterial3D = StandardMaterial3D.new()
	post_mat.albedo_color = Color(0.45, 0.30, 0.18)
	post_mat.roughness = 0.85
	var post: MeshInstance3D = MeshInstance3D.new()
	var pcm: CylinderMesh = CylinderMesh.new()
	pcm.top_radius = 0.10
	pcm.bottom_radius = 0.14
	pcm.height = 3.8
	post.mesh = pcm
	post.material_override = post_mat
	post.position = Vector3(0, 1.90, 0)
	chime.add_child(post)
	# Cross-bar
	var bar: MeshInstance3D = MeshInstance3D.new()
	var bb: BoxMesh = BoxMesh.new()
	bb.size = Vector3(1.4, 0.08, 0.08)
	bar.mesh = bb
	bar.material_override = post_mat
	bar.position = Vector3(0, 3.70, 0)
	chime.add_child(bar)
	# Brass tubes hanging (6 different lengths)
	var brass: StandardMaterial3D = StandardMaterial3D.new()
	brass.albedo_color = Color(0.85, 0.65, 0.20)
	brass.metallic = 0.95
	brass.roughness = 0.20
	var tube_lengths: Array[float] = [0.95, 0.85, 0.75, 0.65, 0.55, 0.45]
	for i in range(6):
		var pivot: Node3D = Node3D.new()
		pivot.position = Vector3(-0.55 + i * 0.22, 3.65, 0)
		chime.add_child(pivot)
		var tube: MeshInstance3D = MeshInstance3D.new()
		var tcm: CylinderMesh = CylinderMesh.new()
		tcm.top_radius = 0.05
		tcm.bottom_radius = 0.05
		tcm.height = tube_lengths[i]
		tube.mesh = tcm
		tube.material_override = brass
		tube.position = Vector3(0, -tube_lengths[i] * 0.5, 0)
		pivot.add_child(tube)
		# Per-tube sway tween (offset phase)
		var tw: Tween = pivot.create_tween().set_loops()
		var phase: float = float(i) * 0.15
		tw.tween_property(pivot, "rotation_degrees:x", 6.0, 1.2 + phase)
		tw.tween_property(pivot, "rotation_degrees:x", -6.0, 1.2 + phase)
	# Top cap (decorative copper sphere)
	var cap_mat: StandardMaterial3D = StandardMaterial3D.new()
	cap_mat.albedo_color = Color(0.75, 0.45, 0.18)
	cap_mat.metallic = 0.85
	cap_mat.roughness = 0.30
	var cap: MeshInstance3D = MeshInstance3D.new()
	var csm: SphereMesh = SphereMesh.new()
	csm.radius = 0.16
	csm.height = 0.32
	cap.mesh = csm
	cap.material_override = cap_mat
	cap.position = Vector3(0, 3.92, 0)
	chime.add_child(cap)
	# Post collision
	var sb: StaticBody3D = StaticBody3D.new()
	sb.position = Vector3(0, 1.90, 0)
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cap_shape: CapsuleShape3D = CapsuleShape3D.new()
	cap_shape.radius = 0.16
	cap_shape.height = 3.8
	cs.shape = cap_shape
	sb.add_child(cs)
	chime.add_child(sb)


static func _build_d8_sea_cave(geom: Node) -> void:
	## Epic-8 T86: sea cave entrance — dark stone archway with mossy hangings
	## and a soft inner cyan glow hinting at hidden depths.
	var cave: Node3D = Node3D.new()
	cave.name = "D8SeaCave"
	cave.position = Vector3(D8_CENTER.x + 78, 0, 14)
	geom.add_child(cave)
	# Outer cliff blob (large dark stone half-sphere)
	var stone: StandardMaterial3D = StandardMaterial3D.new()
	stone.albedo_color = Color(0.20, 0.22, 0.25)
	stone.roughness = 0.92
	var cliff: MeshInstance3D = MeshInstance3D.new()
	var csm: SphereMesh = SphereMesh.new()
	csm.radius = 4.5
	csm.height = 8.0
	cliff.mesh = csm
	cliff.material_override = stone
	cliff.position = Vector3(0, 4.0, -2.5)
	cliff.scale = Vector3(1.2, 1.0, 0.85)
	cave.add_child(cliff)
	# Dark archway (large flat black box embedded in front)
	var dark: StandardMaterial3D = StandardMaterial3D.new()
	dark.albedo_color = Color(0.04, 0.05, 0.08)
	dark.roughness = 0.95
	dark.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var arch: MeshInstance3D = MeshInstance3D.new()
	var asm: SphereMesh = SphereMesh.new()
	asm.radius = 2.0
	asm.height = 4.5
	arch.mesh = asm
	arch.material_override = dark
	arch.position = Vector3(0, 2.3, 0.8)
	arch.scale = Vector3(0.85, 1.0, 0.55)
	cave.add_child(arch)
	# Inner cyan glow (deep emissive sphere set back in the arch)
	var glow_mat: StandardMaterial3D = StandardMaterial3D.new()
	glow_mat.albedo_color = Color(0.15, 0.55, 0.75)
	glow_mat.emission_enabled = true
	glow_mat.emission = Color(0.25, 0.85, 0.95)
	glow_mat.emission_energy_multiplier = 2.5
	glow_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var glow: MeshInstance3D = MeshInstance3D.new()
	var gsm: SphereMesh = SphereMesh.new()
	gsm.radius = 0.85
	gsm.height = 1.7
	glow.mesh = gsm
	glow.material_override = glow_mat
	glow.position = Vector3(0, 2.3, -0.5)
	cave.add_child(glow)
	var pulse: Tween = glow.create_tween().set_loops()
	pulse.tween_property(glow_mat, "emission_energy_multiplier", 3.5, 2.0)
	pulse.tween_property(glow_mat, "emission_energy_multiplier", 1.8, 2.0)
	# Cyan light source
	var lt: OmniLight3D = OmniLight3D.new()
	lt.light_color = Color(0.30, 0.80, 0.95)
	lt.light_energy = 3.5
	lt.omni_range = 7.0
	lt.position = Vector3(0, 2.3, 0.0)
	cave.add_child(lt)
	# Moss hangings (3 vertical green prisms over the arch)
	var moss_mat: StandardMaterial3D = StandardMaterial3D.new()
	moss_mat.albedo_color = Color(0.20, 0.45, 0.20)
	moss_mat.roughness = 0.85
	moss_mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	for i in range(5):
		var moss: MeshInstance3D = MeshInstance3D.new()
		var mb: BoxMesh = BoxMesh.new()
		mb.size = Vector3(0.30, 0.85 + randf() * 0.40, 0.05)
		moss.mesh = mb
		moss.material_override = moss_mat
		moss.position = Vector3(-1.0 + i * 0.5, 4.20, 1.10)
		var sway: Tween = moss.create_tween().set_loops()
		var phase: float = float(i) * 0.20
		sway.tween_property(moss, "rotation_degrees:z", 4.0, 1.6 + phase)
		sway.tween_property(moss, "rotation_degrees:z", -4.0, 1.6 + phase)
		cave.add_child(moss)
	# Stones at the base of the cave
	for i in range(4):
		var rock: MeshInstance3D = MeshInstance3D.new()
		var rsm: SphereMesh = SphereMesh.new()
		rsm.radius = 0.30 + randf() * 0.15
		rsm.height = 0.45 + randf() * 0.20
		rock.mesh = rsm
		rock.material_override = stone
		rock.position = Vector3(-1.6 + i * 1.1, 0.20, 1.30)
		rock.scale = Vector3(1.2, 0.6, 1.0)
		cave.add_child(rock)
	# Cliff collision (big block)
	var sb: StaticBody3D = StaticBody3D.new()
	sb.position = Vector3(0, 3.5, -2.0)
	var cs: CollisionShape3D = CollisionShape3D.new()
	var bs: BoxShape3D = BoxShape3D.new()
	bs.size = Vector3(7.5, 7.0, 5.0)
	cs.shape = bs
	sb.add_child(cs)
	cave.add_child(sb)


static func _build_d8_submarine(geom: Node) -> void:
	## Epic-8 T87: retro submarine half-emerged at dock — long dark hull,
	## conning tower with portholes and antenna, periscope on top.
	var sub: Node3D = Node3D.new()
	sub.name = "D8Submarine"
	sub.position = Vector3(D8_CENTER.x - 8, 0.30, -10)
	geom.add_child(sub)
	# Hull (long dark cigar)
	var hull_mat: StandardMaterial3D = StandardMaterial3D.new()
	hull_mat.albedo_color = Color(0.18, 0.20, 0.22)
	hull_mat.metallic = 0.75
	hull_mat.roughness = 0.45
	var hull: MeshInstance3D = MeshInstance3D.new()
	var hb: SphereMesh = SphereMesh.new()
	hb.radius = 1.0
	hb.height = 2.0
	hull.mesh = hb
	hull.material_override = hull_mat
	hull.scale = Vector3(1.2, 0.65, 5.5)
	hull.position = Vector3(0, 0.55, 0)
	sub.add_child(hull)
	# Conning tower (rounded box on top)
	var tower: MeshInstance3D = MeshInstance3D.new()
	var tb: BoxMesh = BoxMesh.new()
	tb.size = Vector3(0.85, 0.95, 1.40)
	tower.mesh = tb
	tower.material_override = hull_mat
	tower.position = Vector3(0, 1.55, -0.5)
	sub.add_child(tower)
	# Portholes (3 cyan emissive discs along the hull)
	var port_mat: StandardMaterial3D = StandardMaterial3D.new()
	port_mat.albedo_color = Color(0.55, 0.85, 0.95)
	port_mat.emission_enabled = true
	port_mat.emission = Color(0.35, 0.85, 1.00)
	port_mat.emission_energy_multiplier = 1.3
	for sz in [-2.0, -0.6, 0.8, 2.2]:
		var port: MeshInstance3D = MeshInstance3D.new()
		var psm: SphereMesh = SphereMesh.new()
		psm.radius = 0.16
		psm.height = 0.10
		port.mesh = psm
		port.material_override = port_mat
		port.position = Vector3(1.20, 0.85, sz)
		port.rotation_degrees = Vector3(0, 0, 90)
		sub.add_child(port)
	# Periscope (thin tall cylinder + small head)
	var brass: StandardMaterial3D = StandardMaterial3D.new()
	brass.albedo_color = Color(0.85, 0.65, 0.20)
	brass.metallic = 0.95
	brass.roughness = 0.18
	var peri: MeshInstance3D = MeshInstance3D.new()
	var pcm: CylinderMesh = CylinderMesh.new()
	pcm.top_radius = 0.06
	pcm.bottom_radius = 0.06
	pcm.height = 1.30
	peri.mesh = pcm
	peri.material_override = brass
	peri.position = Vector3(0, 2.65, -0.5)
	sub.add_child(peri)
	var peri_head: MeshInstance3D = MeshInstance3D.new()
	var phb: BoxMesh = BoxMesh.new()
	phb.size = Vector3(0.18, 0.18, 0.30)
	peri_head.mesh = phb
	peri_head.material_override = brass
	peri_head.position = Vector3(0, 3.30, -0.4)
	sub.add_child(peri_head)
	# Antenna
	var ant: MeshInstance3D = MeshInstance3D.new()
	var acm: CylinderMesh = CylinderMesh.new()
	acm.top_radius = 0.02
	acm.bottom_radius = 0.03
	acm.height = 0.95
	ant.mesh = acm
	ant.material_override = hull_mat
	ant.position = Vector3(0.20, 2.50, -0.95)
	sub.add_child(ant)
	# Front fins (two small flaps)
	for sx in [-1.0, 1.0]:
		var fin: MeshInstance3D = MeshInstance3D.new()
		var fpm: PrismMesh = PrismMesh.new()
		fpm.size = Vector3(0.08, 0.45, 0.55)
		fin.mesh = fpm
		fin.material_override = hull_mat
		fin.position = Vector3(sx * 1.15, 0.55, 1.85)
		sub.add_child(fin)
	# Rear propeller (3-blade fan)
	var prop_mat: StandardMaterial3D = StandardMaterial3D.new()
	prop_mat.albedo_color = Color(0.72, 0.55, 0.22)
	prop_mat.metallic = 0.85
	prop_mat.roughness = 0.30
	var prop_pivot: Node3D = Node3D.new()
	prop_pivot.position = Vector3(0, 0.55, -3.10)
	sub.add_child(prop_pivot)
	for b in range(3):
		var blade: MeshInstance3D = MeshInstance3D.new()
		var bpm: BoxMesh = BoxMesh.new()
		bpm.size = Vector3(0.85, 0.06, 0.18)
		blade.mesh = bpm
		blade.material_override = prop_mat
		blade.rotation_degrees = Vector3(0, 0, b * 120)
		prop_pivot.add_child(blade)
	var spin: Tween = prop_pivot.create_tween().set_loops()
	spin.tween_property(prop_pivot, "rotation_degrees:z", 360.0, 4.0).from(0.0)
	# Bob tween
	var tw: Tween = sub.create_tween().set_loops()
	tw.tween_property(sub, "position:y", 0.50, 3.0).from(0.20)
	tw.tween_property(sub, "position:y", 0.20, 3.0)
	# Hull collision
	var stb: StaticBody3D = StaticBody3D.new()
	stb.position = Vector3(0, 0.75, 0)
	var cs: CollisionShape3D = CollisionShape3D.new()
	var bs: BoxShape3D = BoxShape3D.new()
	bs.size = Vector3(2.4, 1.5, 11.0)
	cs.shape = bs
	stb.add_child(cs)
	sub.add_child(stb)


static func _build_d8_rope_coil_pyramid(geom: Node) -> void:
	## Epic-8 T88: large pyramid stack of thick rope coils — 3 levels with
	## 6 coils on the bottom, 3 in the middle, 1 on top.
	var pile: Node3D = Node3D.new()
	pile.name = "D8RopeCoilPyramid"
	pile.position = Vector3(D8_CENTER.x + 18, 0, -2)
	geom.add_child(pile)
	var rope_mat: StandardMaterial3D = StandardMaterial3D.new()
	rope_mat.albedo_color = Color(0.78, 0.65, 0.40)
	rope_mat.roughness = 0.85
	# Bottom layer (6 coils)
	var bottom_pos: Array[Vector2] = [
		Vector2(-1.4, -0.7), Vector2(0.0, -0.7), Vector2(1.4, -0.7),
		Vector2(-1.4, 0.7), Vector2(0.0, 0.7), Vector2(1.4, 0.7),
	]
	for p in bottom_pos:
		_make_rope_coil(pile, rope_mat, Vector3(p.x, 0.20, p.y), 0.65)
	# Middle layer (3 coils)
	var mid_pos: Array[Vector2] = [Vector2(-0.7, 0), Vector2(0.7, 0), Vector2(0, 0)]
	mid_pos = [Vector2(-0.7, -0.4), Vector2(0.7, -0.4), Vector2(0, 0.5)]
	for p in mid_pos:
		_make_rope_coil(pile, rope_mat, Vector3(p.x, 0.55, p.y), 0.55)
	# Top coil
	_make_rope_coil(pile, rope_mat, Vector3(0, 0.90, 0), 0.45)
	# Pile collision (one box for the whole pyramid)
	var sb: StaticBody3D = StaticBody3D.new()
	sb.position = Vector3(0, 0.55, 0)
	var cs: CollisionShape3D = CollisionShape3D.new()
	var bs: BoxShape3D = BoxShape3D.new()
	bs.size = Vector3(3.6, 1.10, 2.4)
	cs.shape = bs
	sb.add_child(cs)
	pile.add_child(sb)


func _make_rope_coil(parent: Node3D, mat: Material, pos: Vector3, radius: float) -> void:
	## Helper for T88: create a single torus rope coil at the given position.
	var coil: MeshInstance3D = MeshInstance3D.new()
	var tm: TorusMesh = TorusMesh.new()
	tm.inner_radius = radius * 0.65
	tm.outer_radius = radius
	coil.mesh = tm
	coil.material_override = mat
	coil.position = pos
	parent.add_child(coil)


static func _build_d8_shore_patrol_npc(town: Node) -> void:
	## Epic-8 T89: armored shore patrol NPC — chest plate with naval insignia,
	## helmet, and a tall halberd polearm with a bright cyan blade.
	var slots: Node3D = town.get_node_or_null("NPCSlots") as Node3D
	if slots == null:
		return
	var slot: Marker3D = Marker3D.new()
	slot.name = "D8ShorePatrolSlot"
	slot.position = Vector3(D8_CENTER.x + 32, 0, -3)
	slots.add_child(slot)
	var npc_scene: PackedScene = load("res://scenes/entities/npcs/VillagerR3.tscn") as PackedScene
	if npc_scene == null:
		return
	var npc: Node3D = npc_scene.instantiate() as Node3D
	npc.name = "D8ShorePatrol"
	if "npc_name" in npc:
		npc.set("npc_name", "Patrol Captain Reef")
	if "npc_id" in npc:
		npc.set("npc_id", "d8_shore_patrol")
	slot.add_child(npc)
	# Steel chest plate
	var steel: StandardMaterial3D = StandardMaterial3D.new()
	steel.albedo_color = Color(0.55, 0.60, 0.68)
	steel.metallic = 0.85
	steel.roughness = 0.30
	var chest: MeshInstance3D = MeshInstance3D.new()
	var cb: BoxMesh = BoxMesh.new()
	cb.size = Vector3(0.90, 1.00, 0.55)
	chest.mesh = cb
	chest.material_override = steel
	chest.position = Vector3(0, 1.10, 0)
	npc.add_child(chest)
	# Cyan emissive insignia (anchor shape stylized as small disc)
	var insig_mat: StandardMaterial3D = StandardMaterial3D.new()
	insig_mat.albedo_color = Color(0.30, 0.85, 0.95)
	insig_mat.emission_enabled = true
	insig_mat.emission = Color(0.30, 0.85, 0.95)
	insig_mat.emission_energy_multiplier = 1.4
	insig_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var insig: MeshInstance3D = MeshInstance3D.new()
	var ism: SphereMesh = SphereMesh.new()
	ism.radius = 0.14
	ism.height = 0.08
	insig.mesh = ism
	insig.material_override = insig_mat
	insig.position = Vector3(0, 1.30, 0.30)
	npc.add_child(insig)
	# Helmet
	var helm: MeshInstance3D = MeshInstance3D.new()
	var hsm: SphereMesh = SphereMesh.new()
	hsm.radius = 0.32
	hsm.height = 0.50
	helm.mesh = hsm
	helm.material_override = steel
	helm.position = Vector3(0, 1.95, 0)
	npc.add_child(helm)
	# Helmet ridge (cyan crest)
	var crest: MeshInstance3D = MeshInstance3D.new()
	var crm: BoxMesh = BoxMesh.new()
	crm.size = Vector3(0.05, 0.18, 0.45)
	crest.mesh = crm
	var crmat: StandardMaterial3D = StandardMaterial3D.new()
	crmat.albedo_color = Color(0.30, 0.85, 0.95)
	crmat.emission_enabled = true
	crmat.emission = Color(0.30, 0.85, 0.95)
	crmat.emission_energy_multiplier = 1.0
	crest.material_override = crmat
	crest.position = Vector3(0, 2.15, 0)
	npc.add_child(crest)
	# Halberd shaft (long cylinder held to side)
	var wood_mat: StandardMaterial3D = StandardMaterial3D.new()
	wood_mat.albedo_color = Color(0.45, 0.30, 0.18)
	var shaft: MeshInstance3D = MeshInstance3D.new()
	var scm: CylinderMesh = CylinderMesh.new()
	scm.top_radius = 0.04
	scm.bottom_radius = 0.05
	scm.height = 2.6
	shaft.mesh = scm
	shaft.material_override = wood_mat
	shaft.position = Vector3(0.55, 1.30, 0)
	npc.add_child(shaft)
	# Halberd blade (cyan emissive prism)
	var blade_mat: StandardMaterial3D = StandardMaterial3D.new()
	blade_mat.albedo_color = Color(0.55, 0.92, 1.0)
	blade_mat.emission_enabled = true
	blade_mat.emission = Color(0.45, 0.85, 0.95)
	blade_mat.emission_energy_multiplier = 1.6
	blade_mat.metallic = 0.7
	blade_mat.roughness = 0.18
	var blade: MeshInstance3D = MeshInstance3D.new()
	var bpm: PrismMesh = PrismMesh.new()
	bpm.size = Vector3(0.45, 0.55, 0.06)
	blade.mesh = bpm
	blade.material_override = blade_mat
	blade.position = Vector3(0.55, 2.65, 0)
	npc.add_child(blade)
	# Spike at top of halberd
	var spike: MeshInstance3D = MeshInstance3D.new()
	var sptm: CylinderMesh = CylinderMesh.new()
	sptm.top_radius = 0.0
	sptm.bottom_radius = 0.05
	sptm.height = 0.35
	spike.mesh = sptm
	spike.material_override = blade_mat
	spike.position = Vector3(0.55, 3.05, 0)
	npc.add_child(spike)


static func _build_d8_circling_gulls(geom: Node) -> void:
	## Epic-8 T90: ambient flock of 8 seagulls circling overhead — each on
	## its own pivot rotating about a shared center, slight bob.
	var flock: Node3D = Node3D.new()
	flock.name = "D8CirclingGulls"
	flock.position = Vector3(D8_CENTER.x + 25, 12, -5)
	geom.add_child(flock)
	var white: StandardMaterial3D = StandardMaterial3D.new()
	white.albedo_color = Color(0.95, 0.95, 0.92)
	white.roughness = 0.65
	var gray: StandardMaterial3D = StandardMaterial3D.new()
	gray.albedo_color = Color(0.55, 0.58, 0.62)
	gray.roughness = 0.65
	for i in range(8):
		var pivot: Node3D = Node3D.new()
		pivot.rotation_degrees = Vector3(0, float(i) * 45.0, 0)
		flock.add_child(pivot)
		var gull: Node3D = Node3D.new()
		gull.position = Vector3(8.0 + float(i % 3) * 1.5, float(i % 4) * 0.8, 0)
		pivot.add_child(gull)
		# Body
		var body: MeshInstance3D = MeshInstance3D.new()
		var bsm: SphereMesh = SphereMesh.new()
		bsm.radius = 0.18
		bsm.height = 0.40
		body.mesh = bsm
		body.material_override = white
		body.scale = Vector3(1.0, 0.7, 1.6)
		gull.add_child(body)
		# Wings (two flat prisms)
		for sx in [-1, 1]:
			var wing: MeshInstance3D = MeshInstance3D.new()
			var wpm: PrismMesh = PrismMesh.new()
			wpm.size = Vector3(0.55, 0.04, 0.20)
			wing.mesh = wpm
			wing.material_override = gray
			wing.position = Vector3(sx * 0.30, 0.06, 0)
			wing.rotation_degrees = Vector3(0, 90 if sx > 0 else -90, 0)
			gull.add_child(wing)
			# Per-wing flap tween
			var flap: Tween = wing.create_tween().set_loops()
			flap.tween_property(wing, "rotation_degrees:z", 18.0 * sx, 0.35)
			flap.tween_property(wing, "rotation_degrees:z", -18.0 * sx, 0.35)
		# Per-pivot orbit tween
		var orbit: Tween = pivot.create_tween().set_loops()
		var phase: float = float(i) * 0.5
		orbit.tween_property(pivot, "rotation_degrees:y", float(i) * 45.0 + 360.0, 18.0 + phase).from(float(i) * 45.0)


static func _build_d8_whirlpool_teaser(geom: Node) -> void:
	## Epic-8 T91: boss arena teaser — large dark whirlpool circle in the
	## water with concentric spinning rings and glowing violet runes around
	## the perimeter. Sets up the finale boss arrival.
	var pool: Node3D = Node3D.new()
	pool.name = "D8WhirlpoolTeaser"
	pool.position = Vector3(D8_CENTER.x + 70, 0.05, -2)
	geom.add_child(pool)
	# Outer dark water disc
	var dark_water: StandardMaterial3D = StandardMaterial3D.new()
	dark_water.albedo_color = Color(0.05, 0.08, 0.15)
	dark_water.metallic = 0.4
	dark_water.roughness = 0.20
	var disc: MeshInstance3D = MeshInstance3D.new()
	var dcm: CylinderMesh = CylinderMesh.new()
	dcm.top_radius = 6.0
	dcm.bottom_radius = 6.0
	dcm.height = 0.05
	disc.mesh = dcm
	disc.material_override = dark_water
	disc.position = Vector3(0, 0.05, 0)
	pool.add_child(disc)
	# 3 concentric spinning ring meshes (torus)
	var swirl_mat: StandardMaterial3D = StandardMaterial3D.new()
	swirl_mat.albedo_color = Color(0.20, 0.10, 0.35)
	swirl_mat.emission_enabled = true
	swirl_mat.emission = Color(0.55, 0.30, 0.85)
	swirl_mat.emission_energy_multiplier = 1.4
	for i in range(3):
		var ring: MeshInstance3D = MeshInstance3D.new()
		var tm: TorusMesh = TorusMesh.new()
		tm.inner_radius = 4.5 - i * 1.2
		tm.outer_radius = 4.7 - i * 1.2
		ring.mesh = tm
		ring.material_override = swirl_mat
		ring.position = Vector3(0, 0.10 + i * 0.02, 0)
		pool.add_child(ring)
		var spin: Tween = ring.create_tween().set_loops()
		var dir: float = 1.0 if (i % 2 == 0) else -1.0
		spin.tween_property(ring, "rotation_degrees:y", dir * 360.0, 5.0 + i * 1.5).from(0.0)
	# Central dark sink (smaller deep cylinder)
	var sink_mat: StandardMaterial3D = StandardMaterial3D.new()
	sink_mat.albedo_color = Color(0.0, 0.02, 0.05)
	sink_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var sink: MeshInstance3D = MeshInstance3D.new()
	var scm: CylinderMesh = CylinderMesh.new()
	scm.top_radius = 1.4
	scm.bottom_radius = 0.4
	scm.height = 0.85
	sink.mesh = scm
	sink.material_override = sink_mat
	sink.position = Vector3(0, -0.30, 0)
	pool.add_child(sink)
	# 8 violet rune pillars around the perimeter
	var rune_mat: StandardMaterial3D = StandardMaterial3D.new()
	rune_mat.albedo_color = Color(0.55, 0.30, 0.85)
	rune_mat.emission_enabled = true
	rune_mat.emission = Color(0.65, 0.35, 0.95)
	rune_mat.emission_energy_multiplier = 2.2
	rune_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for i in range(8):
		var ang: float = float(i) * (TAU / 8.0)
		var rune: MeshInstance3D = MeshInstance3D.new()
		var rb: BoxMesh = BoxMesh.new()
		rb.size = Vector3(0.30, 1.10, 0.30)
		rune.mesh = rb
		rune.material_override = rune_mat
		rune.position = Vector3(cos(ang) * 5.5, 0.55, sin(ang) * 5.5)
		pool.add_child(rune)
		var pulse: Tween = rune.create_tween().set_loops()
		pulse.tween_property(rune_mat, "emission_energy_multiplier", 3.5, 1.2)
		pulse.tween_property(rune_mat, "emission_energy_multiplier", 1.5, 1.2)
	# Violet light source
	var lt: OmniLight3D = OmniLight3D.new()
	lt.light_color = Color(0.65, 0.35, 0.95)
	lt.light_energy = 3.0
	lt.omni_range = 12.0
	lt.position = Vector3(0, 1.0, 0)
	pool.add_child(lt)


static func _build_d8_ship_graveyard(geom: Node) -> void:
	## Epic-8 T92: broken mast graveyard — 6 splintered ship masts sticking
	## out of the water at irregular angles, ropes hanging off, faded sails.
	var grave: Node3D = Node3D.new()
	grave.name = "D8ShipGraveyard"
	grave.position = Vector3(D8_CENTER.x + 60, 0, -22)
	geom.add_child(grave)
	var wood_mat: StandardMaterial3D = StandardMaterial3D.new()
	wood_mat.albedo_color = Color(0.30, 0.20, 0.12)
	wood_mat.roughness = 0.92
	var sail_mat: StandardMaterial3D = StandardMaterial3D.new()
	sail_mat.albedo_color = Color(0.65, 0.60, 0.52, 0.85)
	sail_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	sail_mat.roughness = 0.85
	sail_mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	var spots: Array[Vector3] = [
		Vector3(-7, 0, -3),
		Vector3(-3, 0, 4),
		Vector3(2, 0, -2),
		Vector3(6, 0, 5),
		Vector3(9, 0, -4),
		Vector3(-9, 0, 2),
	]
	for i in range(spots.size()):
		var spot: Vector3 = spots[i]
		var mast_root: Node3D = Node3D.new()
		mast_root.position = spot
		mast_root.rotation_degrees = Vector3(
			-15.0 + float(i % 3) * 8.0,
			float(i) * 47.0,
			-12.0 + float(i % 4) * 6.0,
		)
		grave.add_child(mast_root)
		# Mast pole
		var height: float = 4.5 + float(i % 3) * 1.0
		var mast: MeshInstance3D = MeshInstance3D.new()
		var mcm: CylinderMesh = CylinderMesh.new()
		mcm.top_radius = 0.10
		mcm.bottom_radius = 0.20
		mcm.height = height
		mast.mesh = mcm
		mast.material_override = wood_mat
		mast.position = Vector3(0, height * 0.5, 0)
		mast_root.add_child(mast)
		# Cross-yard
		if i % 2 == 0:
			var yard: MeshInstance3D = MeshInstance3D.new()
			var yb: BoxMesh = BoxMesh.new()
			yb.size = Vector3(2.4, 0.10, 0.10)
			yard.mesh = yb
			yard.material_override = wood_mat
			yard.position = Vector3(0, height * 0.65, 0)
			mast_root.add_child(yard)
			# Tattered sail (small box)
			var sail: MeshInstance3D = MeshInstance3D.new()
			var sbm: BoxMesh = BoxMesh.new()
			sbm.size = Vector3(2.0, 1.20, 0.04)
			sail.mesh = sbm
			sail.material_override = sail_mat
			sail.position = Vector3(0, height * 0.50, 0)
			mast_root.add_child(sail)
			var sway: Tween = sail.create_tween().set_loops()
			sway.tween_property(sail, "rotation_degrees:y", 6.0, 1.4)
			sway.tween_property(sail, "rotation_degrees:y", -6.0, 1.4)
		# Mast collision (capsule)
		var sb: StaticBody3D = StaticBody3D.new()
		sb.position = Vector3(0, height * 0.5, 0)
		var cs: CollisionShape3D = CollisionShape3D.new()
		var cap: CapsuleShape3D = CapsuleShape3D.new()
		cap.radius = 0.18
		cap.height = height
		cs.shape = cap
		sb.add_child(cs)
		mast_root.add_child(sb)


static func _build_d8_storm_clouds(geom: Node) -> void:
	## Epic-8 T93: dark storm cloud volume above the harbor — large flat
	## dark sphere with violet rim emission and slow drift, foreshadows
	## the gathering finale storm.
	var clouds: Node3D = Node3D.new()
	clouds.name = "D8StormClouds"
	clouds.position = Vector3(D8_CENTER.x + 50, 18, -5)
	geom.add_child(clouds)
	var cloud_mat: StandardMaterial3D = StandardMaterial3D.new()
	cloud_mat.albedo_color = Color(0.10, 0.08, 0.18, 0.85)
	cloud_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	cloud_mat.emission_enabled = true
	cloud_mat.emission = Color(0.20, 0.10, 0.35)
	cloud_mat.emission_energy_multiplier = 0.55
	cloud_mat.roughness = 0.95
	# 5 overlapping cloud blobs
	var positions: Array[Vector3] = [
		Vector3(0, 0, 0),
		Vector3(7, 1, 4),
		Vector3(-7, -0.5, 3),
		Vector3(5, 0.5, -5),
		Vector3(-6, 1, -4),
	]
	for i in range(positions.size()):
		var blob: MeshInstance3D = MeshInstance3D.new()
		var bsm: SphereMesh = SphereMesh.new()
		bsm.radius = 4.5 + float(i % 3) * 0.8
		bsm.height = 4.0 + float(i % 3) * 0.5
		blob.mesh = bsm
		blob.material_override = cloud_mat
		blob.scale = Vector3(1.4, 0.55, 1.4)
		blob.position = positions[i]
		clouds.add_child(blob)
		# Per-blob slow drift
		var drift: Tween = blob.create_tween().set_loops()
		var off: float = float(i) * 0.6
		var base: Vector3 = positions[i]
		drift.tween_property(blob, "position", base + Vector3(1.0, 0.4, 0.5), 4.0 + off)
		drift.tween_property(blob, "position", base, 4.0 + off)
	# Lightning flash light (low energy normally, periodic flash via tween)
	var flash: OmniLight3D = OmniLight3D.new()
	flash.light_color = Color(0.85, 0.65, 0.95)
	flash.light_energy = 0.5
	flash.omni_range = 25.0
	flash.position = Vector3(0, 0, 0)
	clouds.add_child(flash)
	var pulse: Tween = flash.create_tween().set_loops()
	pulse.tween_property(flash, "light_energy", 4.5, 0.10)
	pulse.tween_property(flash, "light_energy", 0.5, 0.20)
	pulse.tween_property(flash, "light_energy", 3.5, 0.08)
	pulse.tween_property(flash, "light_energy", 0.5, 4.0)


static func _build_d8_tentacle_silhouettes(geom: Node) -> void:
	## Epic-8 T94: ominous tentacle silhouettes rising from deep water around
	## the whirlpool — 5 dark tapered tentacles with cyan suckers.
	var tents: Node3D = Node3D.new()
	tents.name = "D8TentacleSilhouettes"
	tents.position = Vector3(D8_CENTER.x + 70, 0, -2)
	geom.add_child(tents)
	var dark_mat: StandardMaterial3D = StandardMaterial3D.new()
	dark_mat.albedo_color = Color(0.08, 0.10, 0.18)
	dark_mat.metallic = 0.4
	dark_mat.roughness = 0.55
	var sucker_mat: StandardMaterial3D = StandardMaterial3D.new()
	sucker_mat.albedo_color = Color(0.30, 0.85, 0.95)
	sucker_mat.emission_enabled = true
	sucker_mat.emission = Color(0.45, 0.92, 1.0)
	sucker_mat.emission_energy_multiplier = 1.6
	sucker_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for i in range(5):
		var ang: float = float(i) * (TAU / 5.0) + 0.4
		var radius: float = 7.0
		var tent: Node3D = Node3D.new()
		tent.position = Vector3(cos(ang) * radius, 0, sin(ang) * radius)
		tent.rotation_degrees = Vector3(0, -rad_to_deg(ang) - 90, 0)
		tents.add_child(tent)
		# Tentacle: 5 stacked tapered cylinder segments curving outward
		for s in range(5):
			var seg: MeshInstance3D = MeshInstance3D.new()
			var sm: CylinderMesh = CylinderMesh.new()
			sm.top_radius = 0.18 - s * 0.025
			sm.bottom_radius = 0.30 - s * 0.025
			sm.height = 0.95
			seg.mesh = sm
			seg.material_override = dark_mat
			var lean: float = float(s) * 0.15
			seg.position = Vector3(lean, 0.50 + s * 0.85, lean * 0.4)
			seg.rotation_degrees = Vector3(0, 0, -float(s) * 8.0)
			tent.add_child(seg)
			# 2 cyan suckers per segment
			for sk in range(2):
				var sucker: MeshInstance3D = MeshInstance3D.new()
				var spm: SphereMesh = SphereMesh.new()
				spm.radius = 0.06
				spm.height = 0.08
				sucker.mesh = spm
				sucker.material_override = sucker_mat
				sucker.position = Vector3(lean + 0.18, 0.50 + s * 0.85 + (-0.15 if sk == 0 else 0.20), lean * 0.4)
				tent.add_child(sucker)
		# Per-tentacle slow sway tween
		var sway: Tween = tent.create_tween().set_loops()
		var phase: float = float(i) * 0.4
		sway.tween_property(tent, "rotation_degrees:z", 6.0, 1.8 + phase)
		sway.tween_property(tent, "rotation_degrees:z", -6.0, 1.8 + phase)


static func _build_d8_warning_siren(geom: Node) -> void:
	## Epic-8 T95: tall warning siren post — striped pole with a rotating
	## red emergency light and a horn megaphone, foreshadowing imminent
	## boss arrival.
	var siren: Node3D = Node3D.new()
	siren.name = "D8WarningSiren"
	siren.position = Vector3(D8_CENTER.x + 58, 0, 8)
	geom.add_child(siren)
	# Striped pole (yellow/black hazard bands)
	var yellow_mat: StandardMaterial3D = StandardMaterial3D.new()
	yellow_mat.albedo_color = Color(0.95, 0.85, 0.20)
	yellow_mat.emission_enabled = true
	yellow_mat.emission = Color(0.92, 0.82, 0.20)
	yellow_mat.emission_energy_multiplier = 0.30
	var black_mat: StandardMaterial3D = StandardMaterial3D.new()
	black_mat.albedo_color = Color(0.10, 0.10, 0.12)
	for i in range(8):
		var band: MeshInstance3D = MeshInstance3D.new()
		var bm: CylinderMesh = CylinderMesh.new()
		bm.top_radius = 0.12
		bm.bottom_radius = 0.13
		bm.height = 0.55
		band.mesh = bm
		band.material_override = yellow_mat if (i % 2 == 0) else black_mat
		band.position = Vector3(0, 0.30 + i * 0.55, 0)
		siren.add_child(band)
	# Top platform
	var platform: MeshInstance3D = MeshInstance3D.new()
	var pcm: CylinderMesh = CylinderMesh.new()
	pcm.top_radius = 0.30
	pcm.bottom_radius = 0.30
	pcm.height = 0.10
	platform.mesh = pcm
	platform.material_override = black_mat
	platform.position = Vector3(0, 4.80, 0)
	siren.add_child(platform)
	# Rotating red beacon (emissive sphere on a pivot)
	var beacon_pivot: Node3D = Node3D.new()
	beacon_pivot.position = Vector3(0, 5.10, 0)
	siren.add_child(beacon_pivot)
	var beacon_mat: StandardMaterial3D = StandardMaterial3D.new()
	beacon_mat.albedo_color = Color(1.0, 0.20, 0.18)
	beacon_mat.emission_enabled = true
	beacon_mat.emission = Color(1.0, 0.20, 0.15)
	beacon_mat.emission_energy_multiplier = 3.5
	beacon_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var beacon: MeshInstance3D = MeshInstance3D.new()
	var bsm: SphereMesh = SphereMesh.new()
	bsm.radius = 0.22
	bsm.height = 0.44
	beacon.mesh = bsm
	beacon.material_override = beacon_mat
	beacon.position = Vector3(0, 0, 0)
	beacon_pivot.add_child(beacon)
	# Beam emitter (long red emissive prism)
	var beam: MeshInstance3D = MeshInstance3D.new()
	var bbm: BoxMesh = BoxMesh.new()
	bbm.size = Vector3(6.0, 0.18, 0.32)
	beam.mesh = bbm
	beam.material_override = beacon_mat
	beam.position = Vector3(3.0, 0, 0)
	beacon_pivot.add_child(beam)
	# Red light source
	var lt: OmniLight3D = OmniLight3D.new()
	lt.light_color = Color(1.0, 0.20, 0.18)
	lt.light_energy = 3.0
	lt.omni_range = 14.0
	beacon_pivot.add_child(lt)
	var spin: Tween = beacon_pivot.create_tween().set_loops()
	spin.tween_property(beacon_pivot, "rotation_degrees:y", 360.0, 2.5).from(0.0)
	# Pulse beacon brightness
	var pulse: Tween = beacon.create_tween().set_loops()
	pulse.tween_property(beacon_mat, "emission_energy_multiplier", 5.0, 0.6)
	pulse.tween_property(beacon_mat, "emission_energy_multiplier", 2.0, 0.6)
	# Megaphone horn (cone pointing outward)
	var horn_mat: StandardMaterial3D = StandardMaterial3D.new()
	horn_mat.albedo_color = Color(0.45, 0.42, 0.40)
	horn_mat.metallic = 0.65
	horn_mat.roughness = 0.45
	var horn: MeshInstance3D = MeshInstance3D.new()
	var hcm: CylinderMesh = CylinderMesh.new()
	hcm.top_radius = 0.45
	hcm.bottom_radius = 0.10
	hcm.height = 0.65
	horn.mesh = hcm
	horn.material_override = horn_mat
	horn.position = Vector3(0.55, 4.20, 0)
	horn.rotation_degrees = Vector3(0, 0, -90)
	siren.add_child(horn)
	# Pole collision
	var sb: StaticBody3D = StaticBody3D.new()
	sb.position = Vector3(0, 2.40, 0)
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cap: CapsuleShape3D = CapsuleShape3D.new()
	cap.radius = 0.18
	cap.height = 5.0
	cs.shape = cap
	sb.add_child(cs)
	siren.add_child(sb)


static func _build_d8_welcome_banner(geom: Node) -> void:
	## Epic-8 T96: welcome banner — large rope-strung canvas at the harbor
	## entrance reading "TIDAL HARBOR" with a billowing wind tween.
	var banner: Node3D = Node3D.new()
	banner.name = "D8WelcomeBanner"
	banner.position = Vector3(D8_CENTER.x - 18, 0, 0)
	geom.add_child(banner)
	# Two tall posts
	var post_mat: StandardMaterial3D = StandardMaterial3D.new()
	post_mat.albedo_color = Color(0.45, 0.30, 0.18)
	post_mat.roughness = 0.85
	for sx in [-3.5, 3.5]:
		var post: MeshInstance3D = MeshInstance3D.new()
		var pcm: CylinderMesh = CylinderMesh.new()
		pcm.top_radius = 0.15
		pcm.bottom_radius = 0.20
		pcm.height = 5.5
		post.mesh = pcm
		post.material_override = post_mat
		post.position = Vector3(sx, 2.75, 0)
		banner.add_child(post)
		# Per-post collision
		var sb: StaticBody3D = StaticBody3D.new()
		sb.position = Vector3(sx, 2.75, 0)
		var cs: CollisionShape3D = CollisionShape3D.new()
		var cap: CapsuleShape3D = CapsuleShape3D.new()
		cap.radius = 0.22
		cap.height = 5.5
		cs.shape = cap
		sb.add_child(cs)
		banner.add_child(sb)
	# Top rope
	var rope_mat: StandardMaterial3D = StandardMaterial3D.new()
	rope_mat.albedo_color = Color(0.78, 0.65, 0.40)
	var rope: MeshInstance3D = MeshInstance3D.new()
	var rcm: CylinderMesh = CylinderMesh.new()
	rcm.top_radius = 0.05
	rcm.bottom_radius = 0.05
	rcm.height = 7.0
	rope.mesh = rcm
	rope.material_override = rope_mat
	rope.position = Vector3(0, 5.30, 0)
	rope.rotation_degrees = Vector3(0, 0, 90)
	banner.add_child(rope)
	# Canvas (cyan-trimmed cream banner)
	var canvas_mat: StandardMaterial3D = StandardMaterial3D.new()
	canvas_mat.albedo_color = Color(0.92, 0.88, 0.72)
	canvas_mat.emission_enabled = true
	canvas_mat.emission = Color(0.85, 0.80, 0.65)
	canvas_mat.emission_energy_multiplier = 0.35
	canvas_mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	var canvas: MeshInstance3D = MeshInstance3D.new()
	var cb: BoxMesh = BoxMesh.new()
	cb.size = Vector3(6.5, 1.85, 0.06)
	canvas.mesh = cb
	canvas.material_override = canvas_mat
	canvas.position = Vector3(0, 4.20, 0)
	banner.add_child(canvas)
	# Cyan trim strips
	var trim_mat: StandardMaterial3D = StandardMaterial3D.new()
	trim_mat.albedo_color = Color(0.30, 0.85, 0.95)
	trim_mat.emission_enabled = true
	trim_mat.emission = Color(0.30, 0.85, 0.95)
	trim_mat.emission_energy_multiplier = 1.4
	for sy in [0.85, -0.85]:
		var trim: MeshInstance3D = MeshInstance3D.new()
		var tb: BoxMesh = BoxMesh.new()
		tb.size = Vector3(6.5, 0.10, 0.07)
		trim.mesh = tb
		trim.material_override = trim_mat
		trim.position = Vector3(0, 4.20 + sy, 0.01)
		banner.add_child(trim)
	# Title label
	var label: Label3D = Label3D.new()
	label.text = "TIDAL HARBOR"
	label.font_size = 80
	label.modulate = Color(0.10, 0.20, 0.45)
	label.outline_size = 8
	label.outline_modulate = Color(0.30, 0.85, 0.95)
	label.position = Vector3(0, 4.20, 0.10)
	label.billboard = BaseMaterial3D.BILLBOARD_DISABLED
	banner.add_child(label)
	# Billow tween
	var billow: Tween = canvas.create_tween().set_loops()
	billow.tween_property(canvas, "rotation_degrees:x", 4.0, 1.8)
	billow.tween_property(canvas, "rotation_degrees:x", -4.0, 1.8)


static func _build_d8_storm_fog(geom: Node) -> void:
	## Epic-8 T97: storm fog ambient — large translucent dark gray fog volume
	## hanging low over the harbor with slow drift, plus a few violet
	## lightning-aftermath particles.
	var fog: Node3D = Node3D.new()
	fog.name = "D8StormFog"
	fog.position = Vector3(D8_CENTER.x + 40, 1.5, 0)
	geom.add_child(fog)
	var fog_mat: StandardMaterial3D = StandardMaterial3D.new()
	fog_mat.albedo_color = Color(0.30, 0.32, 0.40, 0.30)
	fog_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	fog_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	# 4 wide low-lying fog discs
	var positions: Array[Vector3] = [
		Vector3(0, 0, 0),
		Vector3(15, 0, 8),
		Vector3(-15, 0, -8),
		Vector3(8, 0, -12),
	]
	for i in range(positions.size()):
		var disc: MeshInstance3D = MeshInstance3D.new()
		var dcm: CylinderMesh = CylinderMesh.new()
		dcm.top_radius = 12.0 + float(i) * 1.5
		dcm.bottom_radius = 12.0 + float(i) * 1.5
		dcm.height = 0.85
		disc.mesh = dcm
		disc.material_override = fog_mat
		disc.position = positions[i]
		fog.add_child(disc)
		var drift: Tween = disc.create_tween().set_loops()
		drift.tween_property(disc, "position", positions[i] + Vector3(2.0, 0.20, 1.5), 5.0 + float(i) * 0.5)
		drift.tween_property(disc, "position", positions[i], 5.0 + float(i) * 0.5)
	# Violet ember particles
	var emb: GPUParticles3D = GPUParticles3D.new()
	emb.position = Vector3(0, 6, 0)
	emb.amount = 60
	emb.lifetime = 4.0
	var pm: ParticleProcessMaterial = ParticleProcessMaterial.new()
	pm.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	pm.emission_box_extents = Vector3(20, 1, 12)
	pm.direction = Vector3(0, -1, 0)
	pm.spread = 30.0
	pm.initial_velocity_min = 0.20
	pm.initial_velocity_max = 0.55
	pm.gravity = Vector3(0, -0.4, 0)
	pm.scale_min = 0.06
	pm.scale_max = 0.14
	pm.color = Color(0.65, 0.35, 0.95, 0.85)
	emb.process_material = pm
	var ember_mesh: SphereMesh = SphereMesh.new()
	ember_mesh.radius = 0.08
	ember_mesh.height = 0.16
	emb.draw_pass_1 = ember_mesh
	fog.add_child(emb)


static func _build_d8_finale_plaque(geom: Node) -> void:
	## Epic-8 T98: dock plaque — bronze marker at the entrance to the boss
	## arena dedicated to harbor history.
	var plaque: Node3D = Node3D.new()
	plaque.name = "D8FinalePlaque"
	plaque.position = Vector3(D8_CENTER.x + 65, 0, 4)
	geom.add_child(plaque)
	# Stone base
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.55, 0.52, 0.50)
	stone_mat.roughness = 0.9
	var base: MeshInstance3D = MeshInstance3D.new()
	var bb: BoxMesh = BoxMesh.new()
	bb.size = Vector3(1.40, 0.85, 0.55)
	base.mesh = bb
	base.material_override = stone_mat
	base.position = Vector3(0, 0.42, 0)
	plaque.add_child(base)
	# Bronze plaque face
	var bronze_mat: StandardMaterial3D = StandardMaterial3D.new()
	bronze_mat.albedo_color = Color(0.65, 0.45, 0.18)
	bronze_mat.metallic = 0.92
	bronze_mat.roughness = 0.30
	bronze_mat.emission_enabled = true
	bronze_mat.emission = Color(0.65, 0.45, 0.18)
	bronze_mat.emission_energy_multiplier = 0.35
	var face: MeshInstance3D = MeshInstance3D.new()
	var fb: BoxMesh = BoxMesh.new()
	fb.size = Vector3(1.20, 0.65, 0.05)
	face.mesh = fb
	face.material_override = bronze_mat
	face.position = Vector3(0, 0.65, 0.30)
	plaque.add_child(face)
	# Inscription label
	var label: Label3D = Label3D.new()
	label.text = "TIDAL HARBOR\nWHERE TIDES KEEP TIME"
	label.font_size = 40
	label.modulate = Color(0.20, 0.10, 0.05)
	label.position = Vector3(0, 0.65, 0.34)
	label.billboard = BaseMaterial3D.BILLBOARD_DISABLED
	plaque.add_child(label)
	# Plaque collision
	var sb: StaticBody3D = StaticBody3D.new()
	sb.position = Vector3(0, 0.42, 0)
	var cs: CollisionShape3D = CollisionShape3D.new()
	var bs: BoxShape3D = BoxShape3D.new()
	bs.size = Vector3(1.40, 0.85, 0.55)
	cs.shape = bs
	sb.add_child(cs)
	plaque.add_child(sb)


static func _build_d8_boss_arena_fortifications(geom: Node) -> void:
	## Epic-8 T99: ring of stone breakwater pillars and chain barriers around
	## the boss arena, plus four corner braziers with violet flame.
	var fort: Node3D = Node3D.new()
	fort.name = "D8BossArenaFortifications"
	fort.position = Vector3(D8_CENTER.x + 70, 0, -2)
	geom.add_child(fort)
	# 12 stone breakwater pillars in a wide ring
	var stone: StandardMaterial3D = StandardMaterial3D.new()
	stone.albedo_color = Color(0.40, 0.42, 0.45)
	stone.roughness = 0.92
	var iron: StandardMaterial3D = StandardMaterial3D.new()
	iron.albedo_color = Color(0.18, 0.18, 0.20)
	iron.metallic = 0.85
	iron.roughness = 0.50
	for i in range(12):
		var ang: float = float(i) * (TAU / 12.0)
		var radius: float = 12.5
		var pillar: MeshInstance3D = MeshInstance3D.new()
		var pcm: CylinderMesh = CylinderMesh.new()
		pcm.top_radius = 0.50
		pcm.bottom_radius = 0.65
		pcm.height = 2.40
		pillar.mesh = pcm
		pillar.material_override = stone
		pillar.position = Vector3(cos(ang) * radius, 1.20, sin(ang) * radius)
		fort.add_child(pillar)
		# Iron cap
		var cap: MeshInstance3D = MeshInstance3D.new()
		var ccm: CylinderMesh = CylinderMesh.new()
		ccm.top_radius = 0.60
		ccm.bottom_radius = 0.60
		ccm.height = 0.18
		cap.mesh = ccm
		cap.material_override = iron
		cap.position = Vector3(cos(ang) * radius, 2.50, sin(ang) * radius)
		fort.add_child(cap)
		# Per-pillar collision
		var sb: StaticBody3D = StaticBody3D.new()
		sb.position = Vector3(cos(ang) * radius, 1.20, sin(ang) * radius)
		var cs: CollisionShape3D = CollisionShape3D.new()
		var cap_shape: CapsuleShape3D = CapsuleShape3D.new()
		cap_shape.radius = 0.65
		cap_shape.height = 2.40
		cs.shape = cap_shape
		sb.add_child(cs)
		fort.add_child(sb)
	# Chain links between adjacent pillars (low torus per gap)
	for i in range(12):
		var ang_a: float = float(i) * (TAU / 12.0)
		var ang_b: float = float(i + 1) * (TAU / 12.0)
		var mid: Vector3 = Vector3(
			(cos(ang_a) + cos(ang_b)) * 0.5 * 12.5,
			0.85,
			(sin(ang_a) + sin(ang_b)) * 0.5 * 12.5
		)
		var link: MeshInstance3D = MeshInstance3D.new()
		var tm: TorusMesh = TorusMesh.new()
		tm.inner_radius = 0.20
		tm.outer_radius = 0.30
		link.mesh = tm
		link.material_override = iron
		link.position = mid
		link.rotation_degrees = Vector3(90, -rad_to_deg((ang_a + ang_b) * 0.5), 0)
		fort.add_child(link)
	# 4 corner braziers with violet flame
	var brazier_mat: StandardMaterial3D = StandardMaterial3D.new()
	brazier_mat.albedo_color = Color(0.30, 0.30, 0.32)
	brazier_mat.metallic = 0.7
	brazier_mat.roughness = 0.45
	var flame_mat: StandardMaterial3D = StandardMaterial3D.new()
	flame_mat.albedo_color = Color(0.55, 0.30, 0.95)
	flame_mat.emission_enabled = true
	flame_mat.emission = Color(0.65, 0.35, 0.95)
	flame_mat.emission_energy_multiplier = 3.0
	flame_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for i in range(4):
		var ang: float = float(i) * (TAU / 4.0) + PI / 4.0
		var pos: Vector3 = Vector3(cos(ang) * 14.5, 0, sin(ang) * 14.5)
		# Bowl
		var bowl: MeshInstance3D = MeshInstance3D.new()
		var bcm: CylinderMesh = CylinderMesh.new()
		bcm.top_radius = 0.55
		bcm.bottom_radius = 0.30
		bcm.height = 0.45
		bowl.mesh = bcm
		bowl.material_override = brazier_mat
		bowl.position = pos + Vector3(0, 1.90, 0)
		fort.add_child(bowl)
		# Tripod legs (3 cylinders)
		for l in range(3):
			var lang: float = float(l) * (TAU / 3.0)
			var leg: MeshInstance3D = MeshInstance3D.new()
			var lcm: CylinderMesh = CylinderMesh.new()
			lcm.top_radius = 0.06
			lcm.bottom_radius = 0.08
			lcm.height = 1.85
			leg.mesh = lcm
			leg.material_override = brazier_mat
			leg.position = pos + Vector3(cos(lang) * 0.30, 0.90, sin(lang) * 0.30)
			leg.rotation_degrees = Vector3(rad_to_deg(sin(lang) * 0.18), 0, -rad_to_deg(cos(lang) * 0.18))
			fort.add_child(leg)
		# Flame core (sphere)
		var flame: MeshInstance3D = MeshInstance3D.new()
		var fsm: SphereMesh = SphereMesh.new()
		fsm.radius = 0.40
		fsm.height = 0.85
		flame.mesh = fsm
		flame.material_override = flame_mat
		flame.position = pos + Vector3(0, 2.40, 0)
		fort.add_child(flame)
		var pulse: Tween = flame.create_tween().set_loops()
		pulse.tween_property(flame, "scale", Vector3(1.20, 1.30, 1.20), 0.7)
		pulse.tween_property(flame, "scale", Vector3(0.90, 0.85, 0.90), 0.7)
		# Violet light
		var lt: OmniLight3D = OmniLight3D.new()
		lt.light_color = Color(0.65, 0.35, 0.95)
		lt.light_energy = 2.5
		lt.omni_range = 8.0
		lt.position = pos + Vector3(0, 2.40, 0)
		fort.add_child(lt)


static func _build_d8_tide_leviathan(geom: Node) -> void:
	## Epic-8 T100 FINALE: TIDE LEVIATHAN — massive serpentine sea boss with
	## 8 dark body segments arching above the whirlpool, glowing single eye,
	## fanged maw, dorsal spines, and a billboard title with dark aura.
	var boss: Node3D = Node3D.new()
	boss.name = "D8TideLeviathan"
	boss.position = Vector3(D8_CENTER.x + 70, 0, -2)
	geom.add_child(boss)
	# Body materials
	var hide_mat: StandardMaterial3D = StandardMaterial3D.new()
	hide_mat.albedo_color = Color(0.06, 0.10, 0.18)
	hide_mat.metallic = 0.55
	hide_mat.roughness = 0.40
	var rim_mat: StandardMaterial3D = StandardMaterial3D.new()
	rim_mat.albedo_color = Color(0.25, 0.55, 0.85)
	rim_mat.emission_enabled = true
	rim_mat.emission = Color(0.30, 0.65, 0.95)
	rim_mat.emission_energy_multiplier = 1.8
	rim_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var spine_mat: StandardMaterial3D = StandardMaterial3D.new()
	spine_mat.albedo_color = Color(0.55, 0.30, 0.95)
	spine_mat.emission_enabled = true
	spine_mat.emission = Color(0.65, 0.35, 0.95)
	spine_mat.emission_energy_multiplier = 2.2
	spine_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	# Body: 8 spheres arching up out of the water
	var seg_count: int = 8
	for i in range(seg_count):
		var t: float = float(i) / float(seg_count - 1)
		var arch_x: float = -8.0 + t * 16.0
		var arch_y: float = 1.0 + sin(t * PI) * 4.5
		var arch_z: float = sin(t * PI * 0.5) * 2.5
		var seg: MeshInstance3D = MeshInstance3D.new()
		var ssm: SphereMesh = SphereMesh.new()
		var rad: float = 1.30 - t * 0.55
		ssm.radius = rad
		ssm.height = rad * 2.0
		seg.mesh = ssm
		seg.material_override = hide_mat
		seg.position = Vector3(arch_x, arch_y, arch_z)
		boss.add_child(seg)
		# Rim glow ring around segment
		var rim: MeshInstance3D = MeshInstance3D.new()
		var rtm: TorusMesh = TorusMesh.new()
		rtm.inner_radius = rad
		rtm.outer_radius = rad + 0.10
		rim.mesh = rtm
		rim.material_override = rim_mat
		rim.position = Vector3(arch_x, arch_y, arch_z)
		rim.rotation_degrees = Vector3(0, 0, 90)
		boss.add_child(rim)
		# Dorsal spine (prism)
		var spine: MeshInstance3D = MeshInstance3D.new()
		var spm: PrismMesh = PrismMesh.new()
		spm.size = Vector3(0.18, 0.85 - t * 0.30, 0.30)
		spine.mesh = spm
		spine.material_override = spine_mat
		spine.position = Vector3(arch_x, arch_y + rad + 0.20, arch_z)
		boss.add_child(spine)
		# Per-segment slow bob
		var bob: Tween = seg.create_tween().set_loops()
		var phase: float = float(i) * 0.25
		var ybase: float = arch_y
		bob.tween_property(seg, "position:y", ybase + 0.40, 1.5 + phase)
		bob.tween_property(seg, "position:y", ybase, 1.5 + phase)
	# Head: large dark sphere with details
	var head: Node3D = Node3D.new()
	head.position = Vector3(-9.0, 4.5, 0.5)
	boss.add_child(head)
	var head_mesh: MeshInstance3D = MeshInstance3D.new()
	var hsm: SphereMesh = SphereMesh.new()
	hsm.radius = 1.85
	hsm.height = 3.4
	head_mesh.mesh = hsm
	head_mesh.material_override = hide_mat
	head_mesh.scale = Vector3(1.30, 1.0, 1.0)
	head.add_child(head_mesh)
	# Single glowing cyclops eye
	var eye_mat: StandardMaterial3D = StandardMaterial3D.new()
	eye_mat.albedo_color = Color(1.0, 0.85, 0.30)
	eye_mat.emission_enabled = true
	eye_mat.emission = Color(1.0, 0.75, 0.25)
	eye_mat.emission_energy_multiplier = 4.5
	eye_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var eye: MeshInstance3D = MeshInstance3D.new()
	var esm: SphereMesh = SphereMesh.new()
	esm.radius = 0.55
	esm.height = 1.10
	eye.mesh = esm
	eye.material_override = eye_mat
	eye.position = Vector3(-1.55, 0.30, 0)
	head.add_child(eye)
	var eye_pulse: Tween = eye.create_tween().set_loops()
	eye_pulse.tween_property(eye_mat, "emission_energy_multiplier", 6.5, 1.0)
	eye_pulse.tween_property(eye_mat, "emission_energy_multiplier", 3.5, 1.0)
	# Eye light
	var eye_lt: OmniLight3D = OmniLight3D.new()
	eye_lt.light_color = Color(1.0, 0.75, 0.25)
	eye_lt.light_energy = 5.0
	eye_lt.omni_range = 14.0
	eye_lt.position = Vector3(-1.85, 0.30, 0)
	head.add_child(eye_lt)
	# Fanged maw: 6 cone fangs around a dark mouth
	var fang_mat: StandardMaterial3D = StandardMaterial3D.new()
	fang_mat.albedo_color = Color(0.92, 0.88, 0.78)
	fang_mat.roughness = 0.4
	for i in range(6):
		var ang: float = float(i) * (TAU / 6.0) - PI / 2.0
		var fang: MeshInstance3D = MeshInstance3D.new()
		var fcm: CylinderMesh = CylinderMesh.new()
		fcm.top_radius = 0.0
		fcm.bottom_radius = 0.14
		fcm.height = 0.55
		fang.mesh = fcm
		fang.material_override = fang_mat
		fang.position = Vector3(-2.10, -0.55 + cos(ang) * 0.35, sin(ang) * 0.50)
		fang.rotation_degrees = Vector3(0, 0, 90 + cos(ang) * 12.0)
		head.add_child(fang)
	# Two side horns
	for sz in [-1, 1]:
		var horn: MeshInstance3D = MeshInstance3D.new()
		var hcm: CylinderMesh = CylinderMesh.new()
		hcm.top_radius = 0.0
		hcm.bottom_radius = 0.30
		hcm.height = 1.40
		horn.mesh = hcm
		horn.material_override = spine_mat
		horn.position = Vector3(-0.60, 1.40, sz * 1.20)
		horn.rotation_degrees = Vector3(rad_to_deg(sz * 0.45), 0, 25)
		head.add_child(horn)
	# Slow head sway
	var sway: Tween = head.create_tween().set_loops()
	sway.tween_property(head, "rotation_degrees:y", 12.0, 2.0)
	sway.tween_property(head, "rotation_degrees:y", -12.0, 2.0)
	# Dark aura particles
	var aura: GPUParticles3D = GPUParticles3D.new()
	aura.position = Vector3(0, 4, 0)
	aura.amount = 120
	aura.lifetime = 3.0
	var pm: ParticleProcessMaterial = ParticleProcessMaterial.new()
	pm.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	pm.emission_box_extents = Vector3(10, 3, 4)
	pm.direction = Vector3(0, 1, 0)
	pm.spread = 35.0
	pm.initial_velocity_min = 0.30
	pm.initial_velocity_max = 0.85
	pm.gravity = Vector3(0, -0.10, 0)
	pm.scale_min = 0.18
	pm.scale_max = 0.40
	pm.color = Color(0.25, 0.10, 0.45, 0.70)
	aura.process_material = pm
	var aura_mesh: SphereMesh = SphereMesh.new()
	aura_mesh.radius = 0.18
	aura_mesh.height = 0.36
	aura.draw_pass_1 = aura_mesh
	boss.add_child(aura)
	# Title billboard label
	var title: Label3D = Label3D.new()
	title.text = "TIDE LEVIATHAN"
	title.font_size = 96
	title.modulate = Color(0.30, 0.85, 0.95)
	title.outline_size = 12
	title.outline_modulate = Color(0.10, 0.05, 0.20)
	title.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	title.position = Vector3(0, 9.5, 0)
	boss.add_child(title)
	# Boss arena dim atmosphere light (cyan rim from above)
	var atmos: DirectionalLight3D = DirectionalLight3D.new()
	atmos.light_color = Color(0.30, 0.55, 0.95)
	atmos.light_energy = 0.45
	atmos.position = Vector3(0, 12, 0)
	atmos.rotation_degrees = Vector3(-65, 25, 0)
	boss.add_child(atmos)
	# Heavy collision (5 capsules along the body for combat)
	for i in range(5):
		var t: float = float(i) / 4.0
		var arch_x: float = -8.0 + t * 16.0
		var arch_y: float = 1.0 + sin(t * PI) * 4.5
		var sb: StaticBody3D = StaticBody3D.new()
		sb.position = Vector3(arch_x, arch_y, sin(t * PI * 0.5) * 2.5)
		var cs: CollisionShape3D = CollisionShape3D.new()
		var cap: CapsuleShape3D = CapsuleShape3D.new()
		cap.radius = 1.20 - t * 0.40
		cap.height = 2.40
		cs.shape = cap
		sb.add_child(cs)
		boss.add_child(sb)

