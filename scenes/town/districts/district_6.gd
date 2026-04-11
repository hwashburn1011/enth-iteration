class_name D6Builder
extends Node
## Neon Bazaar district builder — extracted from scenes/town/town.gd to keep
## the main town script modular and under control. All build helpers here are
## static and called from town.gd's _build_district_6() entry function.

const D6_CENTER := Vector3(400, 0, 0)


func extend_boundary(geom: Node) -> void:
	## Push the east boundary wall from x=330 out to x=430 to make room for D6.
	var east_wall: CSGBox3D = geom.get_node_or_null("BoundaryEast") as CSGBox3D
	if east_wall:
		east_wall.position.x = 430.0


func build(town: Node, geom: Node) -> void:
	## Entry point — called from town.gd::_build_district_6(geom).
	print("[D6Builder] start")
	extend_boundary(geom)
	_build_d6_ground(geom)
	_build_d6_entrance_arch(geom)
	_build_d6_great_sign(geom)
	_build_d6_bazaar_host_npc(town)
	_build_d6_food_stalls(geom)
	_build_d6_noodle_vendor_npc(town)
	_build_d6_delivery_drones(geom)
	_build_d6_night_crowd(geom)
	_build_d6_holo_billboard(geom)
	_build_d6_ramen_shop(geom)
	_build_d6_hacker_pods(geom)
	_build_d6_hacker_npc(town)
	_build_d6_rain(geom)
	_build_d6_cyber_rickshaw(geom)
	_build_d6_tattoo_parlor(geom)
	_build_d6_tattoo_artist_npc(town)
	_build_d6_arcade_cabinets(geom)
	_build_d6_arcade_kid_npc(town)
	_build_d6_puddles(geom)
	_build_d6_weapons_stall(geom)
	_build_d6_arms_dealer_npc(town)
	_build_d6_alley_dumpster(geom)
	_build_d6_street_cat(geom)
	_build_d6_vending_machines(geom)
	_build_d6_dance_club(geom)
	_build_d6_bouncer_npc(town)
	_build_d6_street_performer_npc(town)
	_build_d6_graffiti_walls(geom)
	_build_d6_power_transformer(geom)
	_build_d6_motorbikes(geom)
	_build_d6_courier_npc(town)
	_build_d6_phone_booth(geom)
	_build_d6_synth_musician_npc(town)
	_build_d6_satellite_dishes(geom)
	_build_d6_implant_clinic(geom)
	_build_d6_cyberdoc_npc(town)
	_build_d6_atm_row(geom)
	_build_d6_rave_dancers(geom)
	_build_d6_steam_vents(geom)
	_build_d6_pawn_shop(geom)
	_build_d6_pawn_broker_npc(town)
	_build_d6_train_tracks(geom)
	_build_d6_trash_piles(geom)
	_build_d6_ad_balloons(geom)
	_build_d6_gambling_den(geom)
	_build_d6_card_dealer_npc(town)
	_build_d6_smuggler_crates(geom)
	_build_d6_smuggler_boss_npc(town)
	_build_d6_neon_sovereign(geom)
	_build_d6_subway_entrance(geom)
	_build_d6_subway_map(geom)
	_build_d6_street_preacher_npc(town)
	_build_d6_pigeons(geom)
	_build_d6_ramen_customer_npc(town)
	_build_d6_pharmacy(geom)
	_build_d6_pharmacist_npc(town)
	_build_d6_fighter_dummy(geom)
	_build_d6_street_fighter_npc(town)
	_build_d6_hover_taxi(geom)
	_build_d6_bath_house(geom)
	_build_d6_d6_bath_attendant_npc(town)
	_build_d6_bike_rack(geom)
	_build_d6_mural_artist_npc(town)
	_build_d6_dance_billboard(geom)
	_build_d6_souvenir_cart(geom)
	_build_d6_souvenir_vendor_npc(town)
	_build_d6_holo_koi_pond(geom)
	_build_d6_koi_fish(geom)
	_build_d6_street_shrine(geom)
	_build_d6_barbershop(geom)
	_build_d6_barber_npc(town)
	_build_d6_lantern_string(geom)
	_build_d6_vending_bot(geom)
	_build_d6_cyber_mural(geom)
	_build_d6_holo_tower(geom)
	_build_d6_drone_shop(geom)
	_build_d6_drone_mechanic_npc(town)
	_build_d6_cyber_rats(geom)
	_build_d6_scrap_pile(geom)
	_build_d6_cyber_cafe(geom)
	_build_d6_cafe_customer_npc(town)
	_build_d6_dj_booth(geom)
	_build_d6_street_dj_npc(town)
	_build_d6_glow_drones(geom)
	_build_d6_city_map_terminal(geom)
	_build_d6_tour_guide_npc(town)
	_build_d6_protest_banner(geom)
	_build_d6_protester_npc(town)
	_build_d6_data_exchange_kiosk(geom)
	_build_d6_breakdancer_npc(town)
	_build_d6_sign_holder_npc(town)
	_build_d6_hoverboard(geom)
	_build_d6_neon_tree(geom)
	_build_d6_holo_butterflies(geom)
	_build_d6_welcome_banner(geom)
	_build_d6_grand_spire(geom)
	_build_d6_district_plaque(geom)
	_build_d6_ambient_tweak(geom)
	_build_d6_neon_empress(geom)
	print("[D6Builder] done")


func _build_d6_ground(geom: Node) -> void:
	## Epic-6 T1b: D6 ground — dark slate grid floor with magenta/cyan
	## emissive grid lines suggesting wet pavement at night.
	var plane: PlaneMesh = PlaneMesh.new()
	plane.size = Vector2(80, 40)
	var ground: MeshInstance3D = MeshInstance3D.new()
	ground.mesh = plane
	var ground_mat: StandardMaterial3D = StandardMaterial3D.new()
	ground_mat.albedo_color = Color(0.10, 0.08, 0.18)
	ground_mat.emission_enabled = true
	ground_mat.emission = Color(0.30, 0.10, 0.45)
	ground_mat.emission_energy_multiplier = 0.20
	ground_mat.metallic = 0.30
	ground_mat.roughness = 0.30
	ground.material_override = ground_mat
	ground.position = Vector3(D6_CENTER.x, 0.01, 0)
	ground.name = "D6NeonGround"
	geom.add_child(ground)
	# 5 magenta grid stripes running west-east + 3 cyan running north-south
	var magenta_mat: StandardMaterial3D = StandardMaterial3D.new()
	magenta_mat.albedo_color = Color(0.95, 0.20, 0.85)
	magenta_mat.emission_enabled = true
	magenta_mat.emission = Color(0.95, 0.20, 0.85)
	magenta_mat.emission_energy_multiplier = 1.6
	magenta_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for i in 5:
		var stripe: MeshInstance3D = MeshInstance3D.new()
		var sm: BoxMesh = BoxMesh.new()
		sm.size = Vector3(75.0, 0.04, 0.18)
		stripe.mesh = sm
		stripe.material_override = magenta_mat
		stripe.position = Vector3(D6_CENTER.x, 0.04, -16.0 + i * 8.0)
		geom.add_child(stripe)
	var cyan_mat: StandardMaterial3D = StandardMaterial3D.new()
	cyan_mat.albedo_color = Color(0.30, 0.95, 1.0)
	cyan_mat.emission_enabled = true
	cyan_mat.emission = Color(0.30, 0.95, 1.0)
	cyan_mat.emission_energy_multiplier = 1.6
	cyan_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for i in 3:
		var stripe: MeshInstance3D = MeshInstance3D.new()
		var sm: BoxMesh = BoxMesh.new()
		sm.size = Vector3(0.18, 0.04, 36.0)
		stripe.mesh = sm
		stripe.material_override = cyan_mat
		stripe.position = Vector3(D6_CENTER.x - 24.0 + i * 24.0, 0.04, 0)
		geom.add_child(stripe)


func _build_d6_entrance_arch(geom: Node) -> void:
	## Epic-6 T2: neon entrance arch — twin black metal pillars with bright
	## emissive magenta tubes outlining a doorway shape, with small bulbs.
	var arch: Node3D = Node3D.new()
	arch.name = "D6NeonArch"
	arch.position = Vector3(D6_CENTER.x - 32.0, 0.0, 0.0)
	geom.add_child(arch)
	var black_mat: StandardMaterial3D = StandardMaterial3D.new()
	black_mat.albedo_color = Color(0.10, 0.10, 0.15)
	black_mat.metallic = 0.85
	black_mat.roughness = 0.30
	var neon_mat: StandardMaterial3D = StandardMaterial3D.new()
	neon_mat.albedo_color = Color(0.95, 0.20, 0.85)
	neon_mat.emission_enabled = true
	neon_mat.emission = Color(0.95, 0.20, 0.85)
	neon_mat.emission_energy_multiplier = 3.5
	neon_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	# 2 black metal support pillars
	for sx in [-2.85, 2.85]:
		var pillar: MeshInstance3D = MeshInstance3D.new()
		var pm: BoxMesh = BoxMesh.new()
		pm.size = Vector3(0.55, 5.85, 0.55)
		pillar.mesh = pm
		pillar.material_override = black_mat
		pillar.position = Vector3(sx, 2.92, 0)
		arch.add_child(pillar)
		# Pillar collision
		var sb: StaticBody3D = StaticBody3D.new()
		sb.position = Vector3(sx, 2.92, 0)
		var cs: CollisionShape3D = CollisionShape3D.new()
		var cb: BoxShape3D = BoxShape3D.new()
		cb.size = Vector3(0.55, 5.85, 0.55)
		cs.shape = cb
		sb.add_child(cs)
		arch.add_child(sb)
		# Vertical neon tube on each pillar
		var tube: MeshInstance3D = MeshInstance3D.new()
		var tm: CylinderMesh = CylinderMesh.new()
		tm.top_radius = 0.06
		tm.bottom_radius = 0.06
		tm.height = 5.50
		tube.mesh = tm
		tube.material_override = neon_mat
		tube.position = Vector3(sx, 2.85, 0.32)
		arch.add_child(tube)
	# Top horizontal neon crossbar
	var crossbar: MeshInstance3D = MeshInstance3D.new()
	var cbm: CylinderMesh = CylinderMesh.new()
	cbm.top_radius = 0.06
	cbm.bottom_radius = 0.06
	cbm.height = 6.0
	crossbar.mesh = cbm
	crossbar.material_override = neon_mat
	crossbar.position = Vector3(0, 5.85, 0.32)
	crossbar.rotation_degrees = Vector3(0, 0, 90)
	arch.add_child(crossbar)
	# 8 hanging bulbs along the crossbar
	for i in 8:
		var bulb: MeshInstance3D = MeshInstance3D.new()
		var bm: SphereMesh = SphereMesh.new()
		bm.radius = 0.10
		bm.height = 0.20
		bulb.mesh = bm
		bulb.material_override = neon_mat
		bulb.position = Vector3(-2.50 + i * 0.71, 5.55, 0.32)
		arch.add_child(bulb)
	# Bright magenta light under the arch
	var light: OmniLight3D = OmniLight3D.new()
	light.light_color = Color(1.0, 0.30, 0.85)
	light.light_energy = 3.5
	light.omni_range = 10.0
	light.position = Vector3(0, 4.20, 0)
	arch.add_child(light)
	# Pulse the light
	var tw: Tween = light.create_tween().set_loops()
	tw.tween_property(light, "light_energy", 4.5, 1.4)
	tw.tween_property(light, "light_energy", 3.0, 1.4)


func _build_d6_great_sign(geom: Node) -> void:
	## Epic-6 T3: GREAT NEON SIGN landmark — towering vertical sign with
	## flashing "BAZAAR" letters + flickering tube outline + scrolling
	## arrow chase lights along the bottom edge.
	var sign: Node3D = Node3D.new()
	sign.name = "GreatNeonSign"
	sign.position = Vector3(D6_CENTER.x, 0.0, 0.0)
	geom.add_child(sign)
	var black_mat: StandardMaterial3D = StandardMaterial3D.new()
	black_mat.albedo_color = Color(0.10, 0.10, 0.15)
	black_mat.metallic = 0.85
	black_mat.roughness = 0.30
	var magenta_mat: StandardMaterial3D = StandardMaterial3D.new()
	magenta_mat.albedo_color = Color(0.95, 0.20, 0.85)
	magenta_mat.emission_enabled = true
	magenta_mat.emission = Color(0.95, 0.20, 0.85)
	magenta_mat.emission_energy_multiplier = 4.0
	magenta_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var cyan_mat: StandardMaterial3D = StandardMaterial3D.new()
	cyan_mat.albedo_color = Color(0.30, 0.95, 1.0)
	cyan_mat.emission_enabled = true
	cyan_mat.emission = Color(0.30, 1.0, 1.0)
	cyan_mat.emission_energy_multiplier = 4.0
	cyan_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var yellow_mat: StandardMaterial3D = StandardMaterial3D.new()
	yellow_mat.albedo_color = Color(1.0, 0.85, 0.20)
	yellow_mat.emission_enabled = true
	yellow_mat.emission = Color(1.0, 0.85, 0.20)
	yellow_mat.emission_energy_multiplier = 4.0
	yellow_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	# Tall central support post
	var post: MeshInstance3D = MeshInstance3D.new()
	var pm: BoxMesh = BoxMesh.new()
	pm.size = Vector3(0.55, 9.50, 0.55)
	post.mesh = pm
	post.material_override = black_mat
	post.position = Vector3(0, 4.75, -1.20)
	sign.add_child(post)
	# Sign face board (vertical large box)
	var board: MeshInstance3D = MeshInstance3D.new()
	var bm: BoxMesh = BoxMesh.new()
	bm.size = Vector3(4.20, 7.50, 0.30)
	board.mesh = bm
	board.material_override = black_mat
	board.position = Vector3(0, 6.50, 0)
	sign.add_child(board)
	# Magenta border tube outlining the board
	for w in [
		{"size": Vector3(4.20, 0.10, 0.04), "pos": Vector3(0,  3.85, 0.18)},
		{"size": Vector3(4.20, 0.10, 0.04), "pos": Vector3(0, 10.25, 0.18)},
		{"size": Vector3(0.10, 6.50, 0.04), "pos": Vector3(-2.10, 6.50, 0.18)},
		{"size": Vector3(0.10, 6.50, 0.04), "pos": Vector3( 2.10, 6.50, 0.18)},
	]:
		var border: MeshInstance3D = MeshInstance3D.new()
		var bom: BoxMesh = BoxMesh.new()
		bom.size = w["size"]
		border.mesh = bom
		border.material_override = magenta_mat
		border.position = w["pos"]
		sign.add_child(border)
	# Big "BAZAAR" Label3D
	var label: Label3D = Label3D.new()
	label.text = "BAZAAR"
	label.modulate = Color(1.0, 1.0, 1.0)
	label.outline_modulate = Color(0.95, 0.20, 0.85)
	label.outline_size = 18
	label.font_size = 144
	label.pixel_size = 0.018
	label.position = Vector3(0, 7.50, 0.20)
	sign.add_child(label)
	var sub: Label3D = Label3D.new()
	sub.text = "OPEN ALL HOURS"
	sub.modulate = Color(0.30, 1.0, 1.0)
	sub.outline_modulate = Color(0.05, 0.20, 0.30)
	sub.outline_size = 8
	sub.font_size = 56
	sub.pixel_size = 0.012
	sub.position = Vector3(0, 5.85, 0.20)
	sign.add_child(sub)
	# Flicker tween on the magenta border (cycle visibility)
	var tw: Tween = sign.create_tween().set_loops()
	tw.tween_interval(2.0)
	tw.tween_property(label, "modulate:a", 0.30, 0.05)
	tw.tween_property(label, "modulate:a", 1.0, 0.05)
	tw.tween_interval(0.5)
	tw.tween_property(label, "modulate:a", 0.30, 0.05)
	tw.tween_property(label, "modulate:a", 1.0, 0.10)
	# Bottom chase-arrow lights (8 yellow bulbs sequencing left → right)
	for i in 8:
		var bulb: MeshInstance3D = MeshInstance3D.new()
		var bbm: SphereMesh = SphereMesh.new()
		bbm.radius = 0.16
		bbm.height = 0.30
		bulb.mesh = bbm
		bulb.material_override = yellow_mat
		bulb.position = Vector3(-1.85 + i * 0.55, 3.20, 0.22)
		sign.add_child(bulb)
		# Sequenced flicker
		var tb: Tween = bulb.create_tween().set_loops()
		tb.tween_interval(i * 0.10)
		tb.tween_property(bulb, "scale", Vector3.ONE * 1.40, 0.08)
		tb.tween_property(bulb, "scale", Vector3.ONE * 0.85, 0.08)
		tb.tween_interval(0.55)
	# Massive central light
	var light: OmniLight3D = OmniLight3D.new()
	light.light_color = Color(1.0, 0.30, 0.85)
	light.light_energy = 5.5
	light.omni_range = 22.0
	light.position = Vector3(0, 6.50, 1.20)
	sign.add_child(light)
	# Light pulse
	var twl: Tween = light.create_tween().set_loops()
	twl.tween_property(light, "light_energy", 7.0, 1.4)
	twl.tween_property(light, "light_energy", 5.5, 1.4)
	# Sign + post collision
	var sb: StaticBody3D = StaticBody3D.new()
	sb.position = Vector3(0, 4.75, -0.45)
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(4.20, 9.50, 1.40)
	cs.shape = cb
	sb.add_child(cs)
	sign.add_child(sb)


func _build_d6_bazaar_host_npc(town: Node) -> void:
	## Epic-6 T4: bazaar host NPC at the entrance — gold-trimmed coat,
	## confident pose, top hat with a glowing magenta band.
	var npc_slots: Node3D = town.get_node_or_null("%NPCSlots") as Node3D
	if npc_slots == null:
		return
	var slot: Marker3D = Marker3D.new()
	slot.name = "BazaarHostSlot"
	slot.position = Vector3(D6_CENTER.x - 28.0, 0.0, 4.0)
	npc_slots.add_child(slot)
	var npc_scene: PackedScene = load("res://scenes/entities/npcs/VillagerR3.tscn") as PackedScene
	if npc_scene == null:
		return
	var npc: Node3D = npc_scene.instantiate() as Node3D
	npc.name = "BazaarHost"
	if "npc_name" in npc:
		npc.set("npc_name", "Argent")
	if "npc_id" in npc:
		npc.set("npc_id", "host_d6")
	slot.add_child(npc)
	# Long dark coat with gold trim hint
	var coat: MeshInstance3D = MeshInstance3D.new()
	var cm: BoxMesh = BoxMesh.new()
	cm.size = Vector3(0.65, 1.20, 0.45)
	coat.mesh = cm
	var coat_mat: StandardMaterial3D = StandardMaterial3D.new()
	coat_mat.albedo_color = Color(0.10, 0.08, 0.18)
	coat_mat.metallic = 0.25
	coat_mat.roughness = 0.55
	coat.material_override = coat_mat
	coat.position = Vector3(0, 0.60, 0)
	npc.add_child(coat)
	# Gold trim line down the front
	var trim: MeshInstance3D = MeshInstance3D.new()
	var tm: BoxMesh = BoxMesh.new()
	tm.size = Vector3(0.06, 1.10, 0.04)
	trim.mesh = tm
	var gold_mat: StandardMaterial3D = StandardMaterial3D.new()
	gold_mat.albedo_color = Color(1.0, 0.85, 0.30)
	gold_mat.emission_enabled = true
	gold_mat.emission = Color(1.0, 0.75, 0.20)
	gold_mat.emission_energy_multiplier = 0.85
	gold_mat.metallic = 0.85
	gold_mat.roughness = 0.20
	trim.material_override = gold_mat
	trim.position = Vector3(0, 0.60, 0.24)
	npc.add_child(trim)
	# Top hat (cylinder + flat brim)
	var brim: MeshInstance3D = MeshInstance3D.new()
	var brm: CylinderMesh = CylinderMesh.new()
	brm.top_radius = 0.32
	brm.bottom_radius = 0.32
	brm.height = 0.04
	brim.mesh = brm
	var hat_mat: StandardMaterial3D = StandardMaterial3D.new()
	hat_mat.albedo_color = Color(0.10, 0.08, 0.10)
	hat_mat.metallic = 0.30
	hat_mat.roughness = 0.40
	brim.material_override = hat_mat
	brim.position = Vector3(0, 1.45, 0)
	npc.add_child(brim)
	var hat: MeshInstance3D = MeshInstance3D.new()
	var hm: CylinderMesh = CylinderMesh.new()
	hm.top_radius = 0.22
	hm.bottom_radius = 0.22
	hm.height = 0.45
	hat.mesh = hm
	hat.material_override = hat_mat
	hat.position = Vector3(0, 1.70, 0)
	npc.add_child(hat)
	# Magenta hat band
	var band: MeshInstance3D = MeshInstance3D.new()
	var bm: CylinderMesh = CylinderMesh.new()
	bm.top_radius = 0.23
	bm.bottom_radius = 0.23
	bm.height = 0.06
	band.mesh = bm
	var band_mat: StandardMaterial3D = StandardMaterial3D.new()
	band_mat.albedo_color = Color(0.95, 0.20, 0.85)
	band_mat.emission_enabled = true
	band_mat.emission = Color(0.95, 0.20, 0.85)
	band_mat.emission_energy_multiplier = 2.5
	band_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	band.material_override = band_mat
	band.position = Vector3(0, 1.50, 0)
	npc.add_child(band)
	# Cane held in hand (thin black cylinder)
	var cane: MeshInstance3D = MeshInstance3D.new()
	var canem: CylinderMesh = CylinderMesh.new()
	canem.top_radius = 0.025
	canem.bottom_radius = 0.03
	canem.height = 1.40
	cane.mesh = canem
	cane.material_override = hat_mat
	cane.position = Vector3(0.45, 0.70, 0.10)
	npc.add_child(cane)


func _build_d6_food_stalls(geom: Node) -> void:
	## Epic-6 T6: 3 colorful street food stalls in a row — noodles, skewers,
	## and dumplings, each with a glowing sign.
	var stalls: Node3D = Node3D.new()
	stalls.name = "FoodStalls"
	stalls.position = Vector3(D6_CENTER.x - 16.0, 0.0, 8.0)
	geom.add_child(stalls)
	var wood_mat: StandardMaterial3D = StandardMaterial3D.new()
	wood_mat.albedo_color = Color(0.40, 0.25, 0.10)
	wood_mat.roughness = 0.85
	var stall_data: Array = [
		{"x": 0.0,  "color": Color(0.95, 0.20, 0.30), "text": "NOODLES"},
		{"x": 3.20, "color": Color(0.95, 0.65, 0.20), "text": "SKEWERS"},
		{"x": 6.40, "color": Color(0.30, 0.95, 0.55), "text": "DUMPLINGS"},
	]
	for sd in stall_data:
		var stall: Node3D = Node3D.new()
		stall.position = Vector3(sd["x"], 0, 0)
		stalls.add_child(stall)
		# Counter
		var counter: MeshInstance3D = MeshInstance3D.new()
		var cm: BoxMesh = BoxMesh.new()
		cm.size = Vector3(2.85, 0.10, 1.10)
		counter.mesh = cm
		counter.material_override = wood_mat
		counter.position = Vector3(0, 1.05, 0)
		stall.add_child(counter)
		# 4 legs
		for sx in [-1.20, 1.20]:
			for sz in [-0.45, 0.45]:
				var leg: MeshInstance3D = MeshInstance3D.new()
				var lm: BoxMesh = BoxMesh.new()
				lm.size = Vector3(0.10, 1.05, 0.10)
				leg.mesh = lm
				leg.material_override = wood_mat
				leg.position = Vector3(sx, 0.52, sz)
				stall.add_child(leg)
		# Slanted roof shade
		var roof: MeshInstance3D = MeshInstance3D.new()
		var rm: BoxMesh = BoxMesh.new()
		rm.size = Vector3(3.20, 0.10, 1.30)
		roof.mesh = rm
		var roof_mat: StandardMaterial3D = StandardMaterial3D.new()
		roof_mat.albedo_color = sd["color"]
		roof_mat.emission_enabled = true
		roof_mat.emission = sd["color"]
		roof_mat.emission_energy_multiplier = 0.65
		roof_mat.roughness = 0.65
		roof.material_override = roof_mat
		roof.position = Vector3(0, 2.20, -0.10)
		roof.rotation_degrees = Vector3(-12, 0, 0)
		stall.add_child(roof)
		# 2 roof support posts
		for sx in [-1.20, 1.20]:
			var post: MeshInstance3D = MeshInstance3D.new()
			var pmm: CylinderMesh = CylinderMesh.new()
			pmm.top_radius = 0.05
			pmm.bottom_radius = 0.05
			pmm.height = 1.10
			post.mesh = pmm
			post.material_override = wood_mat
			post.position = Vector3(sx, 1.65, -0.40)
			stall.add_child(post)
		# Glowing neon sign hanging at the front
		var sign: MeshInstance3D = MeshInstance3D.new()
		var sm: BoxMesh = BoxMesh.new()
		sm.size = Vector3(1.85, 0.45, 0.06)
		sign.mesh = sm
		var sign_mat: StandardMaterial3D = StandardMaterial3D.new()
		sign_mat.albedo_color = sd["color"]
		sign_mat.emission_enabled = true
		sign_mat.emission = sd["color"]
		sign_mat.emission_energy_multiplier = 2.0
		sign_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		sign.material_override = sign_mat
		sign.position = Vector3(0, 1.85, 0.55)
		stall.add_child(sign)
		var label: Label3D = Label3D.new()
		label.text = sd["text"]
		label.modulate = Color(0.10, 0.05, 0.05)
		label.outline_modulate = Color(1.0, 1.0, 1.0)
		label.outline_size = 4
		label.font_size = 56
		label.pixel_size = 0.005
		label.position = Vector3(0, 1.85, 0.60)
		stall.add_child(label)
		# Stall light
		var light: OmniLight3D = OmniLight3D.new()
		light.light_color = sd["color"]
		light.light_energy = 1.6
		light.omni_range = 4.0
		light.position = Vector3(0, 1.85, 0)
		stall.add_child(light)
		# Stall collision
		var sb: StaticBody3D = StaticBody3D.new()
		sb.position = Vector3(0, 1.10, 0)
		var cs: CollisionShape3D = CollisionShape3D.new()
		var cb: BoxShape3D = BoxShape3D.new()
		cb.size = Vector3(2.85, 2.20, 1.10)
		cs.shape = cb
		sb.add_child(cs)
		stall.add_child(sb)


func _build_d6_noodle_vendor_npc(town: Node) -> void:
	## Epic-6 T7: noodle vendor NPC behind the noodles stall — apron + headband.
	var npc_slots: Node3D = town.get_node_or_null("%NPCSlots") as Node3D
	if npc_slots == null:
		return
	var slot: Marker3D = Marker3D.new()
	slot.name = "NoodleVendorSlot"
	slot.position = Vector3(D6_CENTER.x - 16.0, 0.0, 7.0)
	npc_slots.add_child(slot)
	var npc_scene: PackedScene = load("res://scenes/entities/npcs/VillagerR3.tscn") as PackedScene
	if npc_scene == null:
		return
	var npc: Node3D = npc_scene.instantiate() as Node3D
	npc.name = "NoodleVendor"
	if "npc_name" in npc:
		npc.set("npc_name", "Slurp")
	if "npc_id" in npc:
		npc.set("npc_id", "noodle_d6")
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
	# Red headband
	var band: MeshInstance3D = MeshInstance3D.new()
	var bm: CylinderMesh = CylinderMesh.new()
	bm.top_radius = 0.22
	bm.bottom_radius = 0.22
	bm.height = 0.10
	band.mesh = bm
	var band_mat: StandardMaterial3D = StandardMaterial3D.new()
	band_mat.albedo_color = Color(0.95, 0.20, 0.20)
	band_mat.emission_enabled = true
	band_mat.emission = Color(0.95, 0.20, 0.20)
	band_mat.emission_energy_multiplier = 0.85
	band.material_override = band_mat
	band.position = Vector3(0, 1.40, 0)
	npc.add_child(band)
	# Bowl held in hand (small white cylinder)
	var bowl: MeshInstance3D = MeshInstance3D.new()
	var bwm: CylinderMesh = CylinderMesh.new()
	bwm.top_radius = 0.12
	bwm.bottom_radius = 0.10
	bwm.height = 0.10
	bowl.mesh = bwm
	bowl.material_override = apron_mat
	bowl.position = Vector3(0.40, 0.85, 0.20)
	npc.add_child(bowl)
	# Steam from bowl
	var steam: GPUParticles3D = GPUParticles3D.new()
	steam.amount = 15
	steam.lifetime = 1.4
	steam.preprocess = 0.5
	steam.position = Vector3(0.40, 0.92, 0.20)
	var pm: ParticleProcessMaterial = ParticleProcessMaterial.new()
	pm.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_POINT
	pm.direction = Vector3(0, 1, 0)
	pm.spread = 18.0
	pm.gravity = Vector3.ZERO
	pm.initial_velocity_min = 0.30
	pm.initial_velocity_max = 0.65
	pm.scale_min = 0.08
	pm.scale_max = 0.18
	pm.color = Color(0.95, 0.92, 0.85, 0.55)
	steam.process_material = pm
	var sm_mesh: SphereMesh = SphereMesh.new()
	sm_mesh.radius = 0.10
	sm_mesh.height = 0.20
	steam.draw_pass_1 = sm_mesh
	var sm_mat: StandardMaterial3D = StandardMaterial3D.new()
	sm_mat.albedo_color = Color(0.95, 0.95, 1.0, 0.45)
	sm_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	sm_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	sm_mesh.material = sm_mat
	npc.add_child(steam)


func _build_d6_delivery_drones(geom: Node) -> void:
	## Epic-6 T8: 4 hovering delivery drones zipping along set patrol paths
	## above the bazaar with parcel boxes hanging beneath them.
	var fleet: Node3D = Node3D.new()
	fleet.name = "DeliveryDrones"
	fleet.position = Vector3(D6_CENTER.x, 4.0, 0.0)
	geom.add_child(fleet)
	var metal_mat: StandardMaterial3D = StandardMaterial3D.new()
	metal_mat.albedo_color = Color(0.30, 0.35, 0.40)
	metal_mat.metallic = 0.85
	metal_mat.roughness = 0.30
	var rotor_mat: StandardMaterial3D = StandardMaterial3D.new()
	rotor_mat.albedo_color = Color(0.30, 0.95, 1.0, 0.55)
	rotor_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	rotor_mat.emission_enabled = true
	rotor_mat.emission = Color(0.30, 0.95, 1.0)
	rotor_mat.emission_energy_multiplier = 1.4
	rotor_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var box_colors: Array = [
		Color(0.95, 0.20, 0.30),
		Color(0.95, 0.65, 0.20),
		Color(0.30, 0.95, 0.55),
		Color(0.55, 0.40, 0.95),
	]
	for i in 4:
		var drone: Node3D = Node3D.new()
		drone.position = Vector3(-22.0 + i * 14.0, randf_range(0, 2.0), randf_range(-12, 12))
		fleet.add_child(drone)
		# Body (small dark sphere)
		var body: MeshInstance3D = MeshInstance3D.new()
		var bm: SphereMesh = SphereMesh.new()
		bm.radius = 0.30
		bm.height = 0.40
		body.mesh = bm
		body.material_override = metal_mat
		body.scale = Vector3(1.0, 0.65, 1.0)
		drone.add_child(body)
		# 4 rotor discs
		for sx in [-0.35, 0.35]:
			for sz in [-0.35, 0.35]:
				var rotor: MeshInstance3D = MeshInstance3D.new()
				var rm: CylinderMesh = CylinderMesh.new()
				rm.top_radius = 0.22
				rm.bottom_radius = 0.22
				rm.height = 0.04
				rotor.mesh = rm
				rotor.material_override = rotor_mat
				rotor.position = Vector3(sx, 0.18, sz)
				drone.add_child(rotor)
		# Hanging parcel
		var parcel: MeshInstance3D = MeshInstance3D.new()
		var pm: BoxMesh = BoxMesh.new()
		pm.size = Vector3(0.35, 0.30, 0.35)
		parcel.mesh = pm
		var parcel_mat: StandardMaterial3D = StandardMaterial3D.new()
		parcel_mat.albedo_color = box_colors[i]
		parcel_mat.roughness = 0.85
		parcel.material_override = parcel_mat
		parcel.position = Vector3(0, -0.35, 0)
		drone.add_child(parcel)
		# Patrol tween (long zigzag back and forth)
		var tw: Tween = drone.create_tween().set_loops()
		var d: Vector3 = drone.position
		tw.tween_property(drone, "position", d + Vector3(8.0, 0.5, 4.0), 4.0)
		tw.tween_property(drone, "position", d + Vector3(8.0, -0.5, -4.0), 4.0)
		tw.tween_property(drone, "position", d, 4.0)
		# Small bob
		var tb: Tween = body.create_tween().set_loops()
		tb.tween_property(body, "position:y", 0.04, 0.30)
		tb.tween_property(body, "position:y", 0.0, 0.30)


func _build_d6_night_crowd(geom: Node) -> void:
	## Epic-6 T9: 6 small night crowd shopper figures wandering between
	## the stalls — small bodies + colored shirts + slow drift.
	var crowd: Node3D = Node3D.new()
	crowd.name = "NightCrowd"
	crowd.position = Vector3(D6_CENTER.x - 12.0, 0.0, 0.0)
	geom.add_child(crowd)
	var shirt_colors: Array = [
		Color(0.95, 0.20, 0.30),
		Color(0.30, 0.65, 0.95),
		Color(0.30, 0.95, 0.55),
		Color(0.95, 0.85, 0.30),
		Color(0.85, 0.30, 0.85),
		Color(0.30, 0.95, 0.85),
	]
	for i in 6:
		var person: Node3D = Node3D.new()
		person.position = Vector3(
			randf_range(-8, 16),
			0,
			randf_range(-6, 6)
		)
		crowd.add_child(person)
		# Body (cylinder)
		var body: MeshInstance3D = MeshInstance3D.new()
		var bm: CylinderMesh = CylinderMesh.new()
		bm.top_radius = 0.22
		bm.bottom_radius = 0.22
		bm.height = 1.10
		body.mesh = bm
		var body_mat: StandardMaterial3D = StandardMaterial3D.new()
		body_mat.albedo_color = shirt_colors[i]
		body_mat.emission_enabled = true
		body_mat.emission = shirt_colors[i]
		body_mat.emission_energy_multiplier = 0.30
		body_mat.roughness = 0.65
		body.material_override = body_mat
		body.position = Vector3(0, 0.55, 0)
		person.add_child(body)
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
		head.position = Vector3(0, 1.32, 0)
		person.add_child(head)
		# Slow drift tween
		var tw: Tween = person.create_tween().set_loops()
		var p: Vector3 = person.position
		tw.tween_property(person, "position", p + Vector3(randf_range(-2, 2), 0, randf_range(-2, 2)), 3.0 + randf())
		tw.tween_property(person, "rotation_degrees:y", 180.0, 0.5)
		tw.tween_property(person, "position", p, 3.0 + randf())
		tw.tween_property(person, "rotation_degrees:y", 0.0, 0.5)
		# Walking bob
		var tb: Tween = body.create_tween().set_loops()
		tb.tween_property(body, "position:y", 0.62, 0.30)
		tb.tween_property(body, "position:y", 0.55, 0.30)


func _build_d6_holo_billboard(geom: Node) -> void:
	## Epic-6 T10: large holographic billboard panel hovering above the
	## bazaar — translucent cyan with shifting block patterns.
	var bb: Node3D = Node3D.new()
	bb.name = "HoloBillboard"
	bb.position = Vector3(D6_CENTER.x + 8.0, 0.0, -14.0)
	geom.add_child(bb)
	var metal_mat: StandardMaterial3D = StandardMaterial3D.new()
	metal_mat.albedo_color = Color(0.30, 0.30, 0.35)
	metal_mat.metallic = 0.85
	metal_mat.roughness = 0.30
	# Tall support post
	var post: MeshInstance3D = MeshInstance3D.new()
	var pm: BoxMesh = BoxMesh.new()
	pm.size = Vector3(0.30, 5.85, 0.30)
	post.mesh = pm
	post.material_override = metal_mat
	post.position = Vector3(0, 2.92, 0)
	bb.add_child(post)
	# Hovering panel
	var panel: MeshInstance3D = MeshInstance3D.new()
	var pmm: BoxMesh = BoxMesh.new()
	pmm.size = Vector3(4.20, 2.40, 0.06)
	panel.mesh = pmm
	var panel_mat: StandardMaterial3D = StandardMaterial3D.new()
	panel_mat.albedo_color = Color(0.30, 0.85, 1.0, 0.55)
	panel_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	panel_mat.emission_enabled = true
	panel_mat.emission = Color(0.30, 0.95, 1.0)
	panel_mat.emission_energy_multiplier = 1.6
	panel_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	panel.material_override = panel_mat
	panel.position = Vector3(0, 5.85, 0)
	bb.add_child(panel)
	# 12 small flickering "ad blocks" inside the panel
	var ad_mat: StandardMaterial3D = StandardMaterial3D.new()
	ad_mat.albedo_color = Color(0.95, 0.20, 0.85)
	ad_mat.emission_enabled = true
	ad_mat.emission = Color(0.95, 0.30, 0.95)
	ad_mat.emission_energy_multiplier = 2.5
	ad_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for r in 3:
		for c in 4:
			var block: MeshInstance3D = MeshInstance3D.new()
			var bbm: BoxMesh = BoxMesh.new()
			bbm.size = Vector3(0.85, 0.55, 0.04)
			block.mesh = bbm
			block.material_override = ad_mat
			block.position = Vector3(-1.55 + c * 1.10, 5.20 + r * 0.75, 0.06)
			bb.add_child(block)
			# Flicker
			var tw: Tween = block.create_tween().set_loops()
			tw.tween_interval((r * 4 + c) * 0.10)
			tw.tween_property(block, "scale:y", 1.20, 0.45)
			tw.tween_property(block, "scale:y", 0.55, 0.45)
	var label: Label3D = Label3D.new()
	label.text = "AD\nLOAD"
	label.modulate = Color(0.95, 0.95, 1.0)
	label.outline_modulate = Color(0.05, 0.20, 0.40)
	label.outline_size = 6
	label.font_size = 56
	label.pixel_size = 0.010
	label.position = Vector3(0, 5.85, 0.10)
	bb.add_child(label)
	# Light
	var light: OmniLight3D = OmniLight3D.new()
	light.light_color = Color(0.40, 0.95, 1.0)
	light.light_energy = 2.5
	light.omni_range = 8.0
	light.position = Vector3(0, 5.85, 1.20)
	bb.add_child(light)
	# Post collision
	var sb: StaticBody3D = StaticBody3D.new()
	sb.position = Vector3(0, 2.92, 0)
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cap: CapsuleShape3D = CapsuleShape3D.new()
	cap.radius = 0.30
	cap.height = 5.85
	cs.shape = cap
	sb.add_child(cs)
	bb.add_child(sb)


func _build_d6_ramen_shop(geom: Node) -> void:
	## Epic-6 T11: full ramen shop building — wooden facade with sliding
	## door, paper-lantern strings, slatted overhang, and glowing window.
	var shop: Node3D = Node3D.new()
	shop.name = "RamenShop"
	shop.position = Vector3(D6_CENTER.x + 12.0, 0.0, 14.0)
	geom.add_child(shop)
	var wood_mat: StandardMaterial3D = StandardMaterial3D.new()
	wood_mat.albedo_color = Color(0.40, 0.25, 0.10)
	wood_mat.roughness = 0.85
	var dark_wood: StandardMaterial3D = StandardMaterial3D.new()
	dark_wood.albedo_color = Color(0.20, 0.12, 0.06)
	dark_wood.roughness = 0.85
	# Main building box
	var building: MeshInstance3D = MeshInstance3D.new()
	var bm: BoxMesh = BoxMesh.new()
	bm.size = Vector3(5.50, 3.40, 4.20)
	building.mesh = bm
	building.material_override = wood_mat
	building.position = Vector3(0, 1.70, 0)
	shop.add_child(building)
	# Sloped roof (wide prism)
	var roof: MeshInstance3D = MeshInstance3D.new()
	var rm: PrismMesh = PrismMesh.new()
	rm.size = Vector3(6.0, 1.40, 4.50)
	roof.mesh = rm
	roof.material_override = dark_wood
	roof.position = Vector3(0, 4.10, 0)
	shop.add_child(roof)
	# Slatted overhang in front
	for i in 4:
		var slat: MeshInstance3D = MeshInstance3D.new()
		var sm: BoxMesh = BoxMesh.new()
		sm.size = Vector3(5.20, 0.06, 0.20)
		slat.mesh = sm
		slat.material_override = dark_wood
		slat.position = Vector3(0, 2.85 - i * 0.18, 2.30)
		shop.add_child(slat)
	# Sliding door (dark frame + paper panels)
	var door: MeshInstance3D = MeshInstance3D.new()
	var dm: BoxMesh = BoxMesh.new()
	dm.size = Vector3(1.40, 1.85, 0.08)
	door.mesh = dm
	var paper_mat: StandardMaterial3D = StandardMaterial3D.new()
	paper_mat.albedo_color = Color(0.95, 0.85, 0.55)
	paper_mat.emission_enabled = true
	paper_mat.emission = Color(0.95, 0.65, 0.30)
	paper_mat.emission_energy_multiplier = 1.4
	door.material_override = paper_mat
	door.position = Vector3(0, 1.0, 2.15)
	shop.add_child(door)
	# Glowing wide window
	var window: MeshInstance3D = MeshInstance3D.new()
	var wmm: BoxMesh = BoxMesh.new()
	wmm.size = Vector3(2.85, 0.85, 0.06)
	window.mesh = wmm
	window.material_override = paper_mat
	window.position = Vector3(-1.85, 2.20, 2.13)
	shop.add_child(window)
	# 3 hanging paper lanterns under the overhang
	var lantern_mat: StandardMaterial3D = StandardMaterial3D.new()
	lantern_mat.albedo_color = Color(0.95, 0.20, 0.20)
	lantern_mat.emission_enabled = true
	lantern_mat.emission = Color(0.95, 0.30, 0.20)
	lantern_mat.emission_energy_multiplier = 2.5
	lantern_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for i in 3:
		var lantern: MeshInstance3D = MeshInstance3D.new()
		var lm: SphereMesh = SphereMesh.new()
		lm.radius = 0.30
		lm.height = 0.55
		lantern.mesh = lm
		lantern.material_override = lantern_mat
		lantern.position = Vector3(-2.0 + i * 2.0, 2.40, 2.40)
		lantern.scale = Vector3(1.0, 1.30, 1.0)
		shop.add_child(lantern)
		# Small light per lantern
		var light: OmniLight3D = OmniLight3D.new()
		light.light_color = Color(1.0, 0.45, 0.30)
		light.light_energy = 1.4
		light.omni_range = 3.5
		light.position = Vector3(-2.0 + i * 2.0, 2.40, 2.40)
		shop.add_child(light)
	# RAMEN sign over the door
	var sign: MeshInstance3D = MeshInstance3D.new()
	var snm: BoxMesh = BoxMesh.new()
	snm.size = Vector3(2.40, 0.65, 0.10)
	sign.mesh = snm
	var sign_mat: StandardMaterial3D = StandardMaterial3D.new()
	sign_mat.albedo_color = Color(0.10, 0.08, 0.10)
	sign.material_override = sign_mat
	sign.position = Vector3(0, 3.20, 2.20)
	shop.add_child(sign)
	var label: Label3D = Label3D.new()
	label.text = "RAMEN"
	label.modulate = Color(1.0, 0.30, 0.20)
	label.outline_modulate = Color(1.0, 0.85, 0.55)
	label.outline_size = 6
	label.font_size = 96
	label.pixel_size = 0.012
	label.position = Vector3(0, 3.20, 2.30)
	shop.add_child(label)
	# Building collision
	var sb: StaticBody3D = StaticBody3D.new()
	sb.position = Vector3(0, 1.70, 0)
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(5.50, 3.40, 4.20)
	cs.shape = cb
	sb.add_child(cs)
	shop.add_child(sb)


func _build_d6_hacker_pods(geom: Node) -> void:
	## Epic-6 T12: 3 hacker terminal pods — recliner-style chairs facing
	## glowing screens. Public hacking stations.
	var pods: Node3D = Node3D.new()
	pods.name = "HackerPods"
	pods.position = Vector3(D6_CENTER.x - 18.0, 0.0, -10.0)
	geom.add_child(pods)
	var metal_mat: StandardMaterial3D = StandardMaterial3D.new()
	metal_mat.albedo_color = Color(0.30, 0.32, 0.40)
	metal_mat.metallic = 0.85
	metal_mat.roughness = 0.30
	var screen_mat: StandardMaterial3D = StandardMaterial3D.new()
	screen_mat.albedo_color = Color(0.30, 0.95, 0.30)
	screen_mat.emission_enabled = true
	screen_mat.emission = Color(0.30, 1.0, 0.30)
	screen_mat.emission_energy_multiplier = 3.0
	screen_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for i in 3:
		var pod: Node3D = Node3D.new()
		pod.position = Vector3(i * 2.40, 0, 0)
		pods.add_child(pod)
		# Recliner base
		var base: MeshInstance3D = MeshInstance3D.new()
		var bm: BoxMesh = BoxMesh.new()
		bm.size = Vector3(0.85, 0.30, 1.65)
		base.mesh = bm
		base.material_override = metal_mat
		base.position = Vector3(0, 0.30, 0)
		pod.add_child(base)
		# Recliner backrest (angled box)
		var back: MeshInstance3D = MeshInstance3D.new()
		var bcm: BoxMesh = BoxMesh.new()
		bcm.size = Vector3(0.85, 1.30, 0.18)
		back.mesh = bcm
		back.material_override = metal_mat
		back.position = Vector3(0, 0.95, -0.65)
		back.rotation_degrees = Vector3(-25, 0, 0)
		pod.add_child(back)
		# Display arm extending from base over the recliner
		var arm: MeshInstance3D = MeshInstance3D.new()
		var am: CylinderMesh = CylinderMesh.new()
		am.top_radius = 0.06
		am.bottom_radius = 0.08
		am.height = 1.85
		arm.mesh = am
		arm.material_override = metal_mat
		arm.position = Vector3(-0.45, 1.0, 0.65)
		arm.rotation_degrees = Vector3(45, 0, 0)
		pod.add_child(arm)
		# Display screen at the end of the arm
		var screen: MeshInstance3D = MeshInstance3D.new()
		var sm: BoxMesh = BoxMesh.new()
		sm.size = Vector3(0.85, 0.55, 0.04)
		screen.mesh = sm
		screen.material_override = screen_mat
		screen.position = Vector3(-0.45, 1.85, 0.85)
		screen.rotation_degrees = Vector3(-25, 0, 0)
		pod.add_child(screen)
		# Pulsing screen flicker
		var tw: Tween = screen.create_tween().set_loops()
		tw.tween_interval(i * 0.15)
		tw.tween_property(screen, "scale:y", 1.20, 0.55)
		tw.tween_property(screen, "scale:y", 0.85, 0.55)
		# Pod collision
		var sb: StaticBody3D = StaticBody3D.new()
		sb.position = Vector3(0, 0.65, 0)
		var cs: CollisionShape3D = CollisionShape3D.new()
		var cb: BoxShape3D = BoxShape3D.new()
		cb.size = Vector3(0.85, 1.30, 1.85)
		cs.shape = cb
		sb.add_child(cs)
		pod.add_child(sb)


func _build_d6_hacker_npc(town: Node) -> void:
	## Epic-6 T13: hacker NPC standing next to a pod with a holographic
	## glove and a glowing visor.
	var npc_slots: Node3D = town.get_node_or_null("%NPCSlots") as Node3D
	if npc_slots == null:
		return
	var slot: Marker3D = Marker3D.new()
	slot.name = "HackerSlot"
	slot.position = Vector3(D6_CENTER.x - 14.5, 0.0, -10.0)
	npc_slots.add_child(slot)
	var npc_scene: PackedScene = load("res://scenes/entities/npcs/VillagerR3.tscn") as PackedScene
	if npc_scene == null:
		return
	var npc: Node3D = npc_scene.instantiate() as Node3D
	npc.name = "Hacker"
	if "npc_name" in npc:
		npc.set("npc_name", "Sudo")
	if "npc_id" in npc:
		npc.set("npc_id", "hacker_d6")
	slot.add_child(npc)
	# Black hoodie
	var hoodie: MeshInstance3D = MeshInstance3D.new()
	var hm: BoxMesh = BoxMesh.new()
	hm.size = Vector3(0.65, 1.05, 0.45)
	hoodie.mesh = hm
	var hoodie_mat: StandardMaterial3D = StandardMaterial3D.new()
	hoodie_mat.albedo_color = Color(0.10, 0.10, 0.15)
	hoodie_mat.roughness = 0.85
	hoodie.material_override = hoodie_mat
	hoodie.position = Vector3(0, 0.55, 0)
	npc.add_child(hoodie)
	# Hood (sphere)
	var hood: MeshInstance3D = MeshInstance3D.new()
	var hdm: SphereMesh = SphereMesh.new()
	hdm.radius = 0.24
	hdm.height = 0.42
	hood.mesh = hdm
	hood.material_override = hoodie_mat
	hood.position = Vector3(0, 1.42, -0.05)
	npc.add_child(hood)
	# Glowing green visor
	var visor: MeshInstance3D = MeshInstance3D.new()
	var vm: BoxMesh = BoxMesh.new()
	vm.size = Vector3(0.40, 0.10, 0.04)
	visor.mesh = vm
	var visor_mat: StandardMaterial3D = StandardMaterial3D.new()
	visor_mat.albedo_color = Color(0.30, 1.0, 0.30)
	visor_mat.emission_enabled = true
	visor_mat.emission = Color(0.30, 1.0, 0.30)
	visor_mat.emission_energy_multiplier = 3.5
	visor_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	visor.material_override = visor_mat
	visor.position = Vector3(0, 1.40, 0.21)
	npc.add_child(visor)
	# Holographic glove (3 floating tiny green cubes around the right hand)
	var hand_pivot: Node3D = Node3D.new()
	hand_pivot.position = Vector3(0.40, 0.85, 0.20)
	npc.add_child(hand_pivot)
	for i in 3:
		var cube: MeshInstance3D = MeshInstance3D.new()
		var cmm: BoxMesh = BoxMesh.new()
		cmm.size = Vector3(0.08, 0.08, 0.08)
		cube.mesh = cmm
		cube.material_override = visor_mat
		var ang: float = (TAU / 3.0) * i
		cube.position = Vector3(cos(ang) * 0.18, 0, sin(ang) * 0.18)
		hand_pivot.add_child(cube)
	var trot: Tween = hand_pivot.create_tween().set_loops()
	trot.tween_property(hand_pivot, "rotation_degrees:y", 360.0, 3.0)
	trot.tween_property(hand_pivot, "rotation_degrees:y", 0.0, 0.0)


func _build_d6_rain(geom: Node) -> void:
	## Epic-6 T14: ambient cyberpunk rain — vertical streak particles
	## falling across the entire bazaar district.
	var rain: GPUParticles3D = GPUParticles3D.new()
	rain.name = "Rain"
	rain.position = Vector3(D6_CENTER.x, 12.0, 0.0)
	rain.amount = 350
	rain.lifetime = 1.6
	rain.preprocess = 1.0
	rain.explosiveness = 0.0
	rain.randomness = 0.4
	rain.visibility_aabb = AABB(Vector3(-45, -14, -25), Vector3(90, 28, 50))
	var pm: ParticleProcessMaterial = ParticleProcessMaterial.new()
	pm.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	pm.emission_box_extents = Vector3(40, 0.5, 22)
	pm.direction = Vector3(0, -1, 0)
	pm.spread = 4.0
	pm.gravity = Vector3(0, -8.5, 0)
	pm.initial_velocity_min = 4.5
	pm.initial_velocity_max = 6.5
	pm.scale_min = 0.45
	pm.scale_max = 0.85
	pm.color = Color(0.55, 0.85, 1.0, 0.65)
	rain.process_material = pm
	# Streak mesh — long thin box
	var streak_mesh: BoxMesh = BoxMesh.new()
	streak_mesh.size = Vector3(0.04, 0.55, 0.04)
	rain.draw_pass_1 = streak_mesh
	var smat: StandardMaterial3D = StandardMaterial3D.new()
	smat.albedo_color = Color(0.55, 0.85, 1.0, 0.65)
	smat.emission_enabled = true
	smat.emission = Color(0.40, 0.85, 1.0)
	smat.emission_energy_multiplier = 1.4
	smat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	smat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	streak_mesh.material = smat
	geom.add_child(rain)


func _build_d6_cyber_rickshaw(geom: Node) -> void:
	## Epic-6 T15: cyber rickshaw — 3-wheeled hover taxi with magenta neon
	## underglow, side handles, and a small canopy.
	var rick: Node3D = Node3D.new()
	rick.name = "CyberRickshaw"
	rick.position = Vector3(D6_CENTER.x - 8.0, 0.0, -4.0)
	geom.add_child(rick)
	var metal_mat: StandardMaterial3D = StandardMaterial3D.new()
	metal_mat.albedo_color = Color(0.30, 0.18, 0.30)
	metal_mat.metallic = 0.85
	metal_mat.roughness = 0.30
	var seat_mat: StandardMaterial3D = StandardMaterial3D.new()
	seat_mat.albedo_color = Color(0.85, 0.20, 0.30)
	seat_mat.metallic = 0.30
	seat_mat.roughness = 0.45
	# Body chassis (long box)
	var body: MeshInstance3D = MeshInstance3D.new()
	var bm: BoxMesh = BoxMesh.new()
	bm.size = Vector3(2.40, 0.65, 1.10)
	body.mesh = bm
	body.material_override = metal_mat
	body.position = Vector3(0, 0.55, 0)
	rick.add_child(body)
	# Bench seat (red)
	var seat: MeshInstance3D = MeshInstance3D.new()
	var sm: BoxMesh = BoxMesh.new()
	sm.size = Vector3(2.0, 0.20, 0.85)
	seat.mesh = sm
	seat.material_override = seat_mat
	seat.position = Vector3(0, 0.95, 0)
	rick.add_child(seat)
	# Backrest
	var back: MeshInstance3D = MeshInstance3D.new()
	var bckm: BoxMesh = BoxMesh.new()
	bckm.size = Vector3(2.0, 0.85, 0.18)
	back.mesh = bckm
	back.material_override = seat_mat
	back.position = Vector3(0, 1.40, -0.45)
	rick.add_child(back)
	# Front handle bars
	var bars: MeshInstance3D = MeshInstance3D.new()
	var bbm: CylinderMesh = CylinderMesh.new()
	bbm.top_radius = 0.04
	bbm.bottom_radius = 0.04
	bbm.height = 0.85
	bars.mesh = bbm
	bars.material_override = metal_mat
	bars.position = Vector3(1.30, 1.20, 0)
	bars.rotation_degrees = Vector3(0, 0, 90)
	rick.add_child(bars)
	# 3 wheels (1 front + 2 back)
	var wheel_mat: StandardMaterial3D = StandardMaterial3D.new()
	wheel_mat.albedo_color = Color(0.10, 0.08, 0.10)
	wheel_mat.roughness = 0.85
	var wheel_positions: Array = [
		Vector3( 1.20, 0.30,  0.0),
		Vector3(-1.10, 0.30,  0.55),
		Vector3(-1.10, 0.30, -0.55),
	]
	for wp in wheel_positions:
		var wheel: MeshInstance3D = MeshInstance3D.new()
		var wm: CylinderMesh = CylinderMesh.new()
		wm.top_radius = 0.30
		wm.bottom_radius = 0.30
		wm.height = 0.10
		wheel.mesh = wm
		wheel.material_override = wheel_mat
		wheel.position = wp
		wheel.rotation_degrees = Vector3(0, 0, 90)
		rick.add_child(wheel)
	# Magenta neon underglow strip
	var glow: MeshInstance3D = MeshInstance3D.new()
	var glm: BoxMesh = BoxMesh.new()
	glm.size = Vector3(2.30, 0.04, 1.0)
	glow.mesh = glm
	var glow_mat: StandardMaterial3D = StandardMaterial3D.new()
	glow_mat.albedo_color = Color(0.95, 0.20, 0.85)
	glow_mat.emission_enabled = true
	glow_mat.emission = Color(0.95, 0.20, 0.85)
	glow_mat.emission_energy_multiplier = 3.5
	glow_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	glow.material_override = glow_mat
	glow.position = Vector3(0, 0.18, 0)
	rick.add_child(glow)
	# Underglow light
	var light: OmniLight3D = OmniLight3D.new()
	light.light_color = Color(1.0, 0.30, 0.85)
	light.light_energy = 2.0
	light.omni_range = 3.5
	light.position = Vector3(0, 0.18, 0)
	rick.add_child(light)
	# Cyber rickshaw collision
	var sb: StaticBody3D = StaticBody3D.new()
	sb.position = Vector3(0, 0.85, 0)
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(2.85, 1.65, 1.10)
	cs.shape = cb
	sb.add_child(cs)
	rick.add_child(sb)


func _build_d6_tattoo_parlor(geom: Node) -> void:
	## Epic-6 T16: tattoo parlor — small storefront with neon "INK" sign,
	## a tattoo chair, and floating tattoo pattern holograms.
	var parlor: Node3D = Node3D.new()
	parlor.name = "TattooParlor"
	parlor.position = Vector3(D6_CENTER.x + 18.0, 0.0, 8.0)
	geom.add_child(parlor)
	var dark_mat: StandardMaterial3D = StandardMaterial3D.new()
	dark_mat.albedo_color = Color(0.18, 0.10, 0.20)
	dark_mat.metallic = 0.40
	dark_mat.roughness = 0.55
	# Storefront wall
	var wall: MeshInstance3D = MeshInstance3D.new()
	var wm: BoxMesh = BoxMesh.new()
	wm.size = Vector3(3.85, 3.40, 0.30)
	wall.mesh = wm
	wall.material_override = dark_mat
	wall.position = Vector3(0, 1.70, -1.20)
	parlor.add_child(wall)
	# Side walls
	for sx in [-1.85, 1.85]:
		var side: MeshInstance3D = MeshInstance3D.new()
		var swm: BoxMesh = BoxMesh.new()
		swm.size = Vector3(0.30, 3.40, 2.20)
		side.mesh = swm
		side.material_override = dark_mat
		side.position = Vector3(sx, 1.70, 0)
		parlor.add_child(side)
	# Roof
	var roof: MeshInstance3D = MeshInstance3D.new()
	var rm: BoxMesh = BoxMesh.new()
	rm.size = Vector3(3.85, 0.18, 2.40)
	roof.mesh = rm
	roof.material_override = dark_mat
	roof.position = Vector3(0, 3.50, 0)
	parlor.add_child(roof)
	# Neon "INK" sign
	var sign: MeshInstance3D = MeshInstance3D.new()
	var snm: BoxMesh = BoxMesh.new()
	snm.size = Vector3(2.20, 0.85, 0.06)
	sign.mesh = snm
	var neon_mat: StandardMaterial3D = StandardMaterial3D.new()
	neon_mat.albedo_color = Color(0.30, 1.0, 1.0)
	neon_mat.emission_enabled = true
	neon_mat.emission = Color(0.30, 1.0, 1.0)
	neon_mat.emission_energy_multiplier = 3.5
	neon_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	sign.material_override = neon_mat
	sign.position = Vector3(0, 2.85, 1.21)
	parlor.add_child(sign)
	var label: Label3D = Label3D.new()
	label.text = "INK"
	label.modulate = Color(0.05, 0.10, 0.20)
	label.outline_modulate = Color(0.30, 1.0, 1.0)
	label.outline_size = 8
	label.font_size = 84
	label.pixel_size = 0.012
	label.position = Vector3(0, 2.85, 1.26)
	parlor.add_child(label)
	# Tattoo chair (red, inside the parlor)
	var chair_mat: StandardMaterial3D = StandardMaterial3D.new()
	chair_mat.albedo_color = Color(0.85, 0.20, 0.30)
	chair_mat.metallic = 0.30
	chair_mat.roughness = 0.45
	var chair: MeshInstance3D = MeshInstance3D.new()
	var cm: BoxMesh = BoxMesh.new()
	cm.size = Vector3(0.85, 0.30, 1.65)
	chair.mesh = cm
	chair.material_override = chair_mat
	chair.position = Vector3(0, 0.55, -0.30)
	parlor.add_child(chair)
	# Chair backrest
	var back: MeshInstance3D = MeshInstance3D.new()
	var bm: BoxMesh = BoxMesh.new()
	bm.size = Vector3(0.85, 1.30, 0.18)
	back.mesh = bm
	back.material_override = chair_mat
	back.position = Vector3(0, 1.10, -1.0)
	back.rotation_degrees = Vector3(-25, 0, 0)
	parlor.add_child(back)
	# 3 floating tattoo pattern holograms above the chair
	var pattern_mat: StandardMaterial3D = StandardMaterial3D.new()
	pattern_mat.albedo_color = Color(0.95, 0.20, 0.85, 0.65)
	pattern_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	pattern_mat.emission_enabled = true
	pattern_mat.emission = Color(0.95, 0.20, 0.85)
	pattern_mat.emission_energy_multiplier = 2.5
	pattern_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for i in 3:
		var pattern: MeshInstance3D = MeshInstance3D.new()
		var pm: BoxMesh = BoxMesh.new()
		pm.size = Vector3(0.30, 0.30, 0.04)
		pattern.mesh = pm
		pattern.material_override = pattern_mat
		pattern.position = Vector3(-0.50 + i * 0.50, 2.40, 0.30)
		parlor.add_child(pattern)
		# Slow spin
		var tw: Tween = pattern.create_tween().set_loops()
		tw.tween_property(pattern, "rotation_degrees:y", 360.0, 4.0 + i * 0.4)
		tw.tween_property(pattern, "rotation_degrees:y", 0.0, 0.0)
	# Cyan light from sign
	var light: OmniLight3D = OmniLight3D.new()
	light.light_color = Color(0.30, 1.0, 1.0)
	light.light_energy = 2.5
	light.omni_range = 6.0
	light.position = Vector3(0, 2.85, 1.85)
	parlor.add_child(light)
	# Parlor box collision
	var sb: StaticBody3D = StaticBody3D.new()
	sb.position = Vector3(0, 1.70, 0)
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(3.85, 3.40, 2.40)
	cs.shape = cb
	sb.add_child(cs)
	parlor.add_child(sb)


func _build_d6_tattoo_artist_npc(town: Node) -> void:
	## Epic-6 T17: tattoo artist NPC — sleeveless dark shirt, glowing
	## tattoo gun in hand.
	var npc_slots: Node3D = town.get_node_or_null("%NPCSlots") as Node3D
	if npc_slots == null:
		return
	var slot: Marker3D = Marker3D.new()
	slot.name = "TattooArtistSlot"
	slot.position = Vector3(D6_CENTER.x + 18.0, 0.0, 9.0)
	npc_slots.add_child(slot)
	var npc_scene: PackedScene = load("res://scenes/entities/npcs/VillagerR3.tscn") as PackedScene
	if npc_scene == null:
		return
	var npc: Node3D = npc_scene.instantiate() as Node3D
	npc.name = "TattooArtist"
	if "npc_name" in npc:
		npc.set("npc_name", "Inkwell")
	if "npc_id" in npc:
		npc.set("npc_id", "tattoo_d6")
	slot.add_child(npc)
	# Sleeveless dark shirt
	var shirt: MeshInstance3D = MeshInstance3D.new()
	var sm: BoxMesh = BoxMesh.new()
	sm.size = Vector3(0.65, 1.05, 0.40)
	shirt.mesh = sm
	var shirt_mat: StandardMaterial3D = StandardMaterial3D.new()
	shirt_mat.albedo_color = Color(0.15, 0.10, 0.18)
	shirt_mat.roughness = 0.85
	shirt.material_override = shirt_mat
	shirt.position = Vector3(0, 0.55, 0)
	npc.add_child(shirt)
	# Tattoo gun (small handle + tip)
	var gun: MeshInstance3D = MeshInstance3D.new()
	var gm: BoxMesh = BoxMesh.new()
	gm.size = Vector3(0.10, 0.20, 0.10)
	gun.mesh = gm
	var gun_mat: StandardMaterial3D = StandardMaterial3D.new()
	gun_mat.albedo_color = Color(0.30, 0.30, 0.35)
	gun_mat.metallic = 0.85
	gun_mat.roughness = 0.30
	gun.material_override = gun_mat
	gun.position = Vector3(0.40, 0.85, 0.20)
	npc.add_child(gun)
	# Tip glow
	var tip: MeshInstance3D = MeshInstance3D.new()
	var tm: SphereMesh = SphereMesh.new()
	tm.radius = 0.04
	tm.height = 0.08
	tip.mesh = tm
	var tip_mat: StandardMaterial3D = StandardMaterial3D.new()
	tip_mat.albedo_color = Color(0.30, 1.0, 1.0)
	tip_mat.emission_enabled = true
	tip_mat.emission = Color(0.30, 1.0, 1.0)
	tip_mat.emission_energy_multiplier = 4.0
	tip_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	tip.material_override = tip_mat
	tip.position = Vector3(0.40, 1.0, 0.20)
	npc.add_child(tip)
	# Bandana (small dark sphere on head)
	var bandana: MeshInstance3D = MeshInstance3D.new()
	var bm: SphereMesh = SphereMesh.new()
	bm.radius = 0.20
	bm.height = 0.32
	bandana.mesh = bm
	var bandana_mat: StandardMaterial3D = StandardMaterial3D.new()
	bandana_mat.albedo_color = Color(0.85, 0.20, 0.30)
	bandana_mat.roughness = 0.85
	bandana.material_override = bandana_mat
	bandana.position = Vector3(0, 1.45, 0)
	bandana.scale = Vector3(1.0, 0.55, 1.0)
	npc.add_child(bandana)


func _build_d6_arcade_cabinets(geom: Node) -> void:
	## Epic-6 T18: row of 4 arcade cabinets — tall boxes with glowing screens
	## and joystick + button bumps on the front control panel.
	var arcade: Node3D = Node3D.new()
	arcade.name = "ArcadeCabinets"
	arcade.position = Vector3(D6_CENTER.x + 4.0, 0.0, 14.0)
	geom.add_child(arcade)
	var cab_mat: StandardMaterial3D = StandardMaterial3D.new()
	cab_mat.albedo_color = Color(0.20, 0.18, 0.30)
	cab_mat.metallic = 0.30
	cab_mat.roughness = 0.55
	var cab_colors: Array = [
		Color(0.95, 0.20, 0.30),
		Color(0.30, 0.95, 0.55),
		Color(0.95, 0.85, 0.20),
		Color(0.30, 0.65, 0.95),
	]
	for i in 4:
		var cab: Node3D = Node3D.new()
		cab.position = Vector3(i * 1.30, 0, 0)
		arcade.add_child(cab)
		# Tall cabinet
		var body: MeshInstance3D = MeshInstance3D.new()
		var bm: BoxMesh = BoxMesh.new()
		bm.size = Vector3(1.10, 2.40, 0.85)
		body.mesh = bm
		body.material_override = cab_mat
		body.position = Vector3(0, 1.20, 0)
		cab.add_child(body)
		# Glowing screen
		var screen: MeshInstance3D = MeshInstance3D.new()
		var sm: BoxMesh = BoxMesh.new()
		sm.size = Vector3(0.85, 0.65, 0.06)
		screen.mesh = sm
		var screen_mat: StandardMaterial3D = StandardMaterial3D.new()
		screen_mat.albedo_color = cab_colors[i]
		screen_mat.emission_enabled = true
		screen_mat.emission = cab_colors[i]
		screen_mat.emission_energy_multiplier = 3.5
		screen_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		screen.material_override = screen_mat
		screen.position = Vector3(0, 1.95, 0.42)
		cab.add_child(screen)
		# Marquee at top
		var marquee: MeshInstance3D = MeshInstance3D.new()
		var mm: BoxMesh = BoxMesh.new()
		mm.size = Vector3(1.10, 0.30, 0.20)
		marquee.mesh = mm
		var marquee_mat: StandardMaterial3D = StandardMaterial3D.new()
		marquee_mat.albedo_color = cab_colors[i]
		marquee_mat.emission_enabled = true
		marquee_mat.emission = cab_colors[i]
		marquee_mat.emission_energy_multiplier = 2.0
		marquee_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		marquee.material_override = marquee_mat
		marquee.position = Vector3(0, 2.45, 0.40)
		cab.add_child(marquee)
		# Control panel (slanted box)
		var panel: MeshInstance3D = MeshInstance3D.new()
		var pmm: BoxMesh = BoxMesh.new()
		pmm.size = Vector3(1.10, 0.30, 0.40)
		panel.mesh = pmm
		panel.material_override = cab_mat
		panel.position = Vector3(0, 1.30, 0.42)
		panel.rotation_degrees = Vector3(-25, 0, 0)
		cab.add_child(panel)
		# Joystick (small ball on stick)
		var stick: MeshInstance3D = MeshInstance3D.new()
		var stm: CylinderMesh = CylinderMesh.new()
		stm.top_radius = 0.025
		stm.bottom_radius = 0.025
		stm.height = 0.18
		stick.mesh = stm
		var stick_mat: StandardMaterial3D = StandardMaterial3D.new()
		stick_mat.albedo_color = Color(0.10, 0.10, 0.15)
		stick_mat.metallic = 0.85
		stick.material_override = stick_mat
		stick.position = Vector3(-0.25, 1.50, 0.55)
		cab.add_child(stick)
		var ball: MeshInstance3D = MeshInstance3D.new()
		var blm: SphereMesh = SphereMesh.new()
		blm.radius = 0.045
		blm.height = 0.09
		ball.mesh = blm
		var ball_mat: StandardMaterial3D = StandardMaterial3D.new()
		ball_mat.albedo_color = Color(0.95, 0.20, 0.20)
		ball.material_override = ball_mat
		ball.position = Vector3(-0.25, 1.60, 0.55)
		cab.add_child(ball)
		# 3 buttons (red, green, blue)
		var btn_colors: Array = [Color(0.95, 0.20, 0.20), Color(0.30, 0.95, 0.30), Color(0.30, 0.30, 0.95)]
		for b in 3:
			var btn: MeshInstance3D = MeshInstance3D.new()
			var bnm: SphereMesh = SphereMesh.new()
			bnm.radius = 0.05
			bnm.height = 0.08
			btn.mesh = bnm
			var bnm_mat: StandardMaterial3D = StandardMaterial3D.new()
			bnm_mat.albedo_color = btn_colors[b]
			bnm_mat.emission_enabled = true
			bnm_mat.emission = btn_colors[b]
			bnm_mat.emission_energy_multiplier = 1.4
			btn.material_override = bnm_mat
			btn.position = Vector3(0.10 + b * 0.15, 1.55, 0.55)
			cab.add_child(btn)
		# Screen flicker
		var tw: Tween = screen.create_tween().set_loops()
		tw.tween_interval(i * 0.20)
		tw.tween_property(screen, "scale:y", 1.20, 0.30)
		tw.tween_property(screen, "scale:y", 0.85, 0.30)
		# Cabinet collision
		var sb: StaticBody3D = StaticBody3D.new()
		sb.position = Vector3(0, 1.20, 0)
		var cs: CollisionShape3D = CollisionShape3D.new()
		var cb: BoxShape3D = BoxShape3D.new()
		cb.size = Vector3(1.10, 2.40, 0.85)
		cs.shape = cb
		sb.add_child(cs)
		cab.add_child(sb)


func _build_d6_arcade_kid_npc(town: Node) -> void:
	## Epic-6 T19: arcade kid NPC playing one of the cabinets — small scale
	## villager + bright t-shirt + backwards cap.
	var npc_slots: Node3D = town.get_node_or_null("%NPCSlots") as Node3D
	if npc_slots == null:
		return
	var slot: Marker3D = Marker3D.new()
	slot.name = "ArcadeKidSlot"
	slot.position = Vector3(D6_CENTER.x + 5.0, 0.0, 13.0)
	npc_slots.add_child(slot)
	var npc_scene: PackedScene = load("res://scenes/entities/npcs/VillagerR3.tscn") as PackedScene
	if npc_scene == null:
		return
	var npc: Node3D = npc_scene.instantiate() as Node3D
	npc.name = "ArcadeKid"
	if "npc_name" in npc:
		npc.set("npc_name", "Pixel")
	if "npc_id" in npc:
		npc.set("npc_id", "arcade_kid_d6")
	npc.scale = Vector3(0.75, 0.75, 0.75)
	slot.add_child(npc)
	# Bright t-shirt
	var shirt: MeshInstance3D = MeshInstance3D.new()
	var sm: BoxMesh = BoxMesh.new()
	sm.size = Vector3(0.55, 0.65, 0.30)
	shirt.mesh = sm
	var shirt_mat: StandardMaterial3D = StandardMaterial3D.new()
	shirt_mat.albedo_color = Color(0.30, 0.95, 0.55)
	shirt_mat.emission_enabled = true
	shirt_mat.emission = Color(0.30, 0.95, 0.55)
	shirt_mat.emission_energy_multiplier = 0.45
	shirt_mat.roughness = 0.65
	shirt.material_override = shirt_mat
	shirt.position = Vector3(0, 0.55, 0)
	npc.add_child(shirt)
	# Backwards cap (cylinder + small brim)
	var cap: MeshInstance3D = MeshInstance3D.new()
	var cm: CylinderMesh = CylinderMesh.new()
	cm.top_radius = 0.20
	cm.bottom_radius = 0.20
	cm.height = 0.18
	cap.mesh = cm
	var cap_mat: StandardMaterial3D = StandardMaterial3D.new()
	cap_mat.albedo_color = Color(0.85, 0.20, 0.30)
	cap.material_override = cap_mat
	cap.position = Vector3(0, 1.50, 0)
	npc.add_child(cap)
	# Brim (back-facing)
	var brim: MeshInstance3D = MeshInstance3D.new()
	var bbm: BoxMesh = BoxMesh.new()
	bbm.size = Vector3(0.30, 0.04, 0.20)
	brim.mesh = bbm
	brim.material_override = cap_mat
	brim.position = Vector3(0, 1.42, -0.20)
	npc.add_child(brim)


func _build_d6_puddles(geom: Node) -> void:
	## Epic-6 T20: 8 small puddle decals scattered across the bazaar floor —
	## thin emissive flat discs to suggest wet pavement reflections.
	var puddles: Node3D = Node3D.new()
	puddles.name = "Puddles"
	puddles.position = Vector3(D6_CENTER.x, 0.02, 0.0)
	geom.add_child(puddles)
	var puddle_mat: StandardMaterial3D = StandardMaterial3D.new()
	puddle_mat.albedo_color = Color(0.30, 0.55, 0.95, 0.65)
	puddle_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	puddle_mat.emission_enabled = true
	puddle_mat.emission = Color(0.30, 0.65, 0.95)
	puddle_mat.emission_energy_multiplier = 0.85
	puddle_mat.metallic = 0.55
	puddle_mat.roughness = 0.05
	for i in 8:
		var puddle: MeshInstance3D = MeshInstance3D.new()
		var pm: CylinderMesh = CylinderMesh.new()
		pm.top_radius = 0.85 + randf() * 0.45
		pm.bottom_radius = 0.85 + randf() * 0.45
		pm.height = 0.04
		puddle.mesh = pm
		puddle.material_override = puddle_mat
		puddle.position = Vector3(
			randf_range(-30, 30),
			0.02,
			randf_range(-15, 15)
		)
		puddle.scale = Vector3(1.0, 1.0, 0.65 + randf() * 0.55)
		puddles.add_child(puddle)


func _build_d6_weapons_stall(geom: Node) -> void:
	## Epic-6 T21: cyber weapons dealer stall — angled glass display case
	## with 3 floating cyber katanas + holographic price tags.
	var stall: Node3D = Node3D.new()
	stall.name = "WeaponsStall"
	stall.position = Vector3(D6_CENTER.x - 6.0, 0.0, 14.0)
	geom.add_child(stall)
	var metal_mat: StandardMaterial3D = StandardMaterial3D.new()
	metal_mat.albedo_color = Color(0.30, 0.30, 0.40)
	metal_mat.metallic = 0.85
	metal_mat.roughness = 0.30
	# Counter base
	var base: MeshInstance3D = MeshInstance3D.new()
	var bm: BoxMesh = BoxMesh.new()
	bm.size = Vector3(2.85, 0.85, 1.10)
	base.mesh = bm
	base.material_override = metal_mat
	base.position = Vector3(0, 0.42, 0)
	stall.add_child(base)
	# Glass display case (translucent box on top)
	var case_mat: StandardMaterial3D = StandardMaterial3D.new()
	case_mat.albedo_color = Color(0.40, 0.55, 0.85, 0.25)
	case_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	case_mat.emission_enabled = true
	case_mat.emission = Color(0.40, 0.85, 1.0)
	case_mat.emission_energy_multiplier = 0.55
	case_mat.metallic = 0.55
	case_mat.roughness = 0.05
	var case: MeshInstance3D = MeshInstance3D.new()
	var cm: BoxMesh = BoxMesh.new()
	cm.size = Vector3(2.85, 0.85, 1.10)
	case.mesh = cm
	case.material_override = case_mat
	case.position = Vector3(0, 1.30, 0)
	stall.add_child(case)
	# 3 floating cyber katanas inside
	var blade_mat: StandardMaterial3D = StandardMaterial3D.new()
	blade_mat.albedo_color = Color(0.85, 0.92, 1.0)
	blade_mat.emission_enabled = true
	blade_mat.emission = Color(0.85, 0.95, 1.0)
	blade_mat.emission_energy_multiplier = 0.85
	blade_mat.metallic = 0.85
	blade_mat.roughness = 0.10
	var grip_mat: StandardMaterial3D = StandardMaterial3D.new()
	grip_mat.albedo_color = Color(0.10, 0.08, 0.10)
	grip_mat.roughness = 0.85
	for i in 3:
		var katana: Node3D = Node3D.new()
		katana.position = Vector3(-0.85 + i * 0.85, 1.30, 0)
		stall.add_child(katana)
		# Blade (long thin prism)
		var blade: MeshInstance3D = MeshInstance3D.new()
		var blm: PrismMesh = PrismMesh.new()
		blm.size = Vector3(0.06, 0.20, 0.95)
		blade.mesh = blm
		blade.material_override = blade_mat
		blade.position = Vector3(0, 0, 0)
		blade.rotation_degrees = Vector3(0, 0, 90)
		katana.add_child(blade)
		# Grip
		var grip: MeshInstance3D = MeshInstance3D.new()
		var gm: CylinderMesh = CylinderMesh.new()
		gm.top_radius = 0.04
		gm.bottom_radius = 0.04
		gm.height = 0.30
		grip.mesh = gm
		grip.material_override = grip_mat
		grip.position = Vector3(0, 0, -0.55)
		grip.rotation_degrees = Vector3(0, 0, 90)
		katana.add_child(grip)
		# Hover bob
		var tw: Tween = katana.create_tween().set_loops()
		tw.tween_interval(i * 0.20)
		tw.tween_property(katana, "position:y", 1.45, 1.4)
		tw.tween_property(katana, "position:y", 1.30, 1.4)
		# Slow rotation
		var ts: Tween = katana.create_tween().set_loops()
		ts.tween_property(katana, "rotation_degrees:y", 360.0, 6.0 + i * 0.4)
		ts.tween_property(katana, "rotation_degrees:y", 0.0, 0.0)
	# Sign label "WEAPONS"
	var label: Label3D = Label3D.new()
	label.text = "WEAPONS"
	label.modulate = Color(0.95, 0.95, 1.0)
	label.outline_modulate = Color(0.95, 0.20, 0.30)
	label.outline_size = 6
	label.font_size = 56
	label.pixel_size = 0.008
	label.position = Vector3(0, 2.20, 0.30)
	stall.add_child(label)
	# Light
	var light: OmniLight3D = OmniLight3D.new()
	light.light_color = Color(0.40, 0.85, 1.0)
	light.light_energy = 1.6
	light.omni_range = 4.5
	light.position = Vector3(0, 1.30, 0.55)
	stall.add_child(light)
	# Stall collision
	var sb: StaticBody3D = StaticBody3D.new()
	sb.position = Vector3(0, 0.85, 0)
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(2.85, 1.85, 1.10)
	cs.shape = cb
	sb.add_child(cs)
	stall.add_child(sb)


func _build_d6_arms_dealer_npc(town: Node) -> void:
	## Epic-6 T22: arms dealer NPC — long leather coat, mirrored shades, gold chain.
	var npc_slots: Node3D = town.get_node_or_null("%NPCSlots") as Node3D
	if npc_slots == null:
		return
	var slot: Marker3D = Marker3D.new()
	slot.name = "ArmsDealerSlot"
	slot.position = Vector3(D6_CENTER.x - 6.0, 0.0, 13.0)
	npc_slots.add_child(slot)
	var npc_scene: PackedScene = load("res://scenes/entities/npcs/VillagerR3.tscn") as PackedScene
	if npc_scene == null:
		return
	var npc: Node3D = npc_scene.instantiate() as Node3D
	npc.name = "ArmsDealer"
	if "npc_name" in npc:
		npc.set("npc_name", "Switchblade")
	if "npc_id" in npc:
		npc.set("npc_id", "arms_d6")
	slot.add_child(npc)
	# Long leather coat
	var coat: MeshInstance3D = MeshInstance3D.new()
	var cm: BoxMesh = BoxMesh.new()
	cm.size = Vector3(0.75, 1.20, 0.50)
	coat.mesh = cm
	var coat_mat: StandardMaterial3D = StandardMaterial3D.new()
	coat_mat.albedo_color = Color(0.20, 0.10, 0.05)
	coat_mat.metallic = 0.30
	coat_mat.roughness = 0.45
	coat.material_override = coat_mat
	coat.position = Vector3(0, 0.60, 0)
	npc.add_child(coat)
	# Mirrored shades
	var shades: MeshInstance3D = MeshInstance3D.new()
	var smm: BoxMesh = BoxMesh.new()
	smm.size = Vector3(0.42, 0.08, 0.04)
	shades.mesh = smm
	var shades_mat: StandardMaterial3D = StandardMaterial3D.new()
	shades_mat.albedo_color = Color(0.30, 0.95, 1.0)
	shades_mat.emission_enabled = true
	shades_mat.emission = Color(0.30, 1.0, 1.0)
	shades_mat.emission_energy_multiplier = 1.4
	shades_mat.metallic = 0.85
	shades_mat.roughness = 0.05
	shades.material_override = shades_mat
	shades.position = Vector3(0, 1.40, 0.21)
	npc.add_child(shades)
	# Gold chain (small torus around neck)
	var chain: MeshInstance3D = MeshInstance3D.new()
	var ctm: TorusMesh = TorusMesh.new()
	ctm.inner_radius = 0.18
	ctm.outer_radius = 0.22
	chain.mesh = ctm
	var gold_mat: StandardMaterial3D = StandardMaterial3D.new()
	gold_mat.albedo_color = Color(1.0, 0.85, 0.30)
	gold_mat.emission_enabled = true
	gold_mat.emission = Color(1.0, 0.75, 0.20)
	gold_mat.emission_energy_multiplier = 0.85
	gold_mat.metallic = 0.95
	gold_mat.roughness = 0.10
	chain.material_override = gold_mat
	chain.position = Vector3(0, 1.10, 0.10)
	npc.add_child(chain)


func _build_d6_alley_dumpster(geom: Node) -> void:
	## Epic-6 T23: alley dumpster — large green metal bin with a flipped
	## lid, scattered trash, and the occasional small cyan code particle
	## leaking out.
	var dumpster: Node3D = Node3D.new()
	dumpster.name = "AlleyDumpster"
	dumpster.position = Vector3(D6_CENTER.x + 22.0, 0.0, -4.0)
	geom.add_child(dumpster)
	var green_mat: StandardMaterial3D = StandardMaterial3D.new()
	green_mat.albedo_color = Color(0.20, 0.45, 0.20)
	green_mat.metallic = 0.65
	green_mat.roughness = 0.45
	# Main bin (large box)
	var bin: MeshInstance3D = MeshInstance3D.new()
	var bm: BoxMesh = BoxMesh.new()
	bm.size = Vector3(2.20, 1.40, 1.10)
	bin.mesh = bm
	bin.material_override = green_mat
	bin.position = Vector3(0, 0.70, 0)
	dumpster.add_child(bin)
	# Lid (flipped open at angle behind)
	var lid: MeshInstance3D = MeshInstance3D.new()
	var lm: BoxMesh = BoxMesh.new()
	lm.size = Vector3(2.20, 0.10, 1.10)
	lid.mesh = lm
	lid.material_override = green_mat
	lid.position = Vector3(0, 1.85, -0.65)
	lid.rotation_degrees = Vector3(-30, 0, 0)
	dumpster.add_child(lid)
	# Trash bags (small dark spheres on top)
	var trash_mat: StandardMaterial3D = StandardMaterial3D.new()
	trash_mat.albedo_color = Color(0.12, 0.10, 0.10)
	trash_mat.roughness = 0.85
	for i in 4:
		var bag: MeshInstance3D = MeshInstance3D.new()
		var bgm: SphereMesh = SphereMesh.new()
		bgm.radius = 0.22
		bgm.height = 0.36
		bag.mesh = bgm
		bag.material_override = trash_mat
		bag.position = Vector3(
			randf_range(-0.85, 0.85),
			1.55,
			randf_range(-0.40, 0.40)
		)
		dumpster.add_child(bag)
	# Cyan code leak particles
	var leak: GPUParticles3D = GPUParticles3D.new()
	leak.amount = 18
	leak.lifetime = 2.5
	leak.preprocess = 1.0
	leak.position = Vector3(0, 1.55, 0.55)
	var pm: ParticleProcessMaterial = ParticleProcessMaterial.new()
	pm.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	pm.emission_box_extents = Vector3(0.85, 0.10, 0.40)
	pm.direction = Vector3(0, 1, 0.10)
	pm.spread = 25.0
	pm.gravity = Vector3(0, 0.30, 0)
	pm.initial_velocity_min = 0.20
	pm.initial_velocity_max = 0.55
	pm.scale_min = 0.04
	pm.scale_max = 0.10
	pm.color = Color(0.30, 0.95, 0.55, 0.85)
	leak.process_material = pm
	var leak_mesh: BoxMesh = BoxMesh.new()
	leak_mesh.size = Vector3(0.06, 0.06, 0.06)
	leak.draw_pass_1 = leak_mesh
	var leak_mat: StandardMaterial3D = StandardMaterial3D.new()
	leak_mat.albedo_color = Color(0.30, 0.95, 0.55)
	leak_mat.emission_enabled = true
	leak_mat.emission = Color(0.30, 1.0, 0.55)
	leak_mat.emission_energy_multiplier = 2.5
	leak_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	leak_mesh.material = leak_mat
	dumpster.add_child(leak)
	# Dumpster collision
	var sb: StaticBody3D = StaticBody3D.new()
	sb.position = Vector3(0, 0.70, 0)
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(2.20, 1.40, 1.10)
	cs.shape = cb
	sb.add_child(cs)
	dumpster.add_child(sb)


func _build_d6_street_cat(geom: Node) -> void:
	## Epic-6 T24: small dark street cat near the dumpster — black fur,
	## glowing magenta eyes, slow patrol.
	var cat: Node3D = Node3D.new()
	cat.name = "StreetCat"
	cat.position = Vector3(D6_CENTER.x + 20.0, 0.0, -4.0)
	geom.add_child(cat)
	var fur_mat: StandardMaterial3D = StandardMaterial3D.new()
	fur_mat.albedo_color = Color(0.10, 0.08, 0.12)
	fur_mat.roughness = 0.85
	# Body (sphere)
	var body: MeshInstance3D = MeshInstance3D.new()
	var bm: SphereMesh = SphereMesh.new()
	bm.radius = 0.18
	bm.height = 0.30
	body.mesh = bm
	body.material_override = fur_mat
	body.position = Vector3(0, 0.22, 0)
	body.scale = Vector3(0.85, 0.85, 1.40)
	cat.add_child(body)
	# Head
	var head: MeshInstance3D = MeshInstance3D.new()
	var hm: SphereMesh = SphereMesh.new()
	hm.radius = 0.14
	hm.height = 0.24
	head.mesh = hm
	head.material_override = fur_mat
	head.position = Vector3(0, 0.30, 0.20)
	cat.add_child(head)
	# 2 ears (small prisms)
	for sx in [-0.07, 0.07]:
		var ear: MeshInstance3D = MeshInstance3D.new()
		var em: PrismMesh = PrismMesh.new()
		em.size = Vector3(0.05, 0.10, 0.04)
		ear.mesh = em
		ear.material_override = fur_mat
		ear.position = Vector3(sx, 0.42, 0.20)
		cat.add_child(ear)
	# 2 glowing magenta eyes
	var eye_mat: StandardMaterial3D = StandardMaterial3D.new()
	eye_mat.albedo_color = Color(0.95, 0.20, 0.85)
	eye_mat.emission_enabled = true
	eye_mat.emission = Color(0.95, 0.30, 0.95)
	eye_mat.emission_energy_multiplier = 4.0
	eye_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for ex in [-0.05, 0.05]:
		var eye: MeshInstance3D = MeshInstance3D.new()
		var em: SphereMesh = SphereMesh.new()
		em.radius = 0.025
		em.height = 0.05
		eye.mesh = em
		eye.material_override = eye_mat
		eye.position = Vector3(ex, 0.32, 0.31)
		cat.add_child(eye)
	# Tail (curved cylinder up)
	var tail: MeshInstance3D = MeshInstance3D.new()
	var tm: CylinderMesh = CylinderMesh.new()
	tm.top_radius = 0.025
	tm.bottom_radius = 0.04
	tm.height = 0.30
	tail.mesh = tm
	tail.material_override = fur_mat
	tail.position = Vector3(0, 0.32, -0.25)
	tail.rotation_degrees = Vector3(45, 0, 0)
	cat.add_child(tail)
	# 4 small legs
	for lx in [-0.08, 0.08]:
		for lz in [-0.15, 0.15]:
			var leg: MeshInstance3D = MeshInstance3D.new()
			var lm: CylinderMesh = CylinderMesh.new()
			lm.top_radius = 0.025
			lm.bottom_radius = 0.025
			lm.height = 0.18
			leg.mesh = lm
			leg.material_override = fur_mat
			leg.position = Vector3(lx, 0.09, lz)
			cat.add_child(leg)
	# Slow patrol back and forth
	var tw: Tween = cat.create_tween().set_loops()
	tw.tween_property(cat, "position:x", D6_CENTER.x + 23.0, 3.0)
	tw.tween_property(cat, "rotation_degrees:y", 180.0, 0.4)
	tw.tween_property(cat, "position:x", D6_CENTER.x + 18.0, 3.0)
	tw.tween_property(cat, "rotation_degrees:y", 0.0, 0.4)


func _build_d6_vending_machines(geom: Node) -> void:
	## Epic-6 T25: 3 vending machines — tall lit cabinets with rows of
	## colored drink cans visible inside.
	var row: Node3D = Node3D.new()
	row.name = "VendingMachines"
	row.position = Vector3(D6_CENTER.x + 22.0, 0.0, 14.0)
	geom.add_child(row)
	var cab_colors: Array = [
		Color(0.95, 0.20, 0.30),
		Color(0.30, 0.65, 0.95),
		Color(0.30, 0.95, 0.55),
	]
	for i in 3:
		var machine: Node3D = Node3D.new()
		machine.position = Vector3(i * 1.20, 0, 0)
		row.add_child(machine)
		# Body
		var body: MeshInstance3D = MeshInstance3D.new()
		var bm: BoxMesh = BoxMesh.new()
		bm.size = Vector3(1.0, 2.20, 0.65)
		body.mesh = bm
		var body_mat: StandardMaterial3D = StandardMaterial3D.new()
		body_mat.albedo_color = cab_colors[i]
		body_mat.emission_enabled = true
		body_mat.emission = cab_colors[i]
		body_mat.emission_energy_multiplier = 0.55
		body_mat.metallic = 0.30
		body_mat.roughness = 0.45
		body.material_override = body_mat
		body.position = Vector3(0, 1.10, 0)
		machine.add_child(body)
		# Display window (translucent slab)
		var window: MeshInstance3D = MeshInstance3D.new()
		var wm: BoxMesh = BoxMesh.new()
		wm.size = Vector3(0.85, 1.40, 0.06)
		window.mesh = wm
		var window_mat: StandardMaterial3D = StandardMaterial3D.new()
		window_mat.albedo_color = Color(0.85, 0.95, 1.0, 0.45)
		window_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		window_mat.emission_enabled = true
		window_mat.emission = Color(0.85, 0.95, 1.0)
		window_mat.emission_energy_multiplier = 1.4
		window_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		window.material_override = window_mat
		window.position = Vector3(0, 1.30, 0.34)
		machine.add_child(window)
		# 6 small cans inside (3 rows of 2)
		for r in 3:
			for c in 2:
				var can: MeshInstance3D = MeshInstance3D.new()
				var cm: CylinderMesh = CylinderMesh.new()
				cm.top_radius = 0.10
				cm.bottom_radius = 0.10
				cm.height = 0.22
				can.mesh = cm
				var can_color: Color = cab_colors[(i + r + c) % 3]
				var can_mat: StandardMaterial3D = StandardMaterial3D.new()
				can_mat.albedo_color = can_color
				can_mat.emission_enabled = true
				can_mat.emission = can_color
				can_mat.emission_energy_multiplier = 0.85
				can_mat.metallic = 0.65
				can_mat.roughness = 0.30
				can.material_override = can_mat
				can.position = Vector3(-0.22 + c * 0.44, 0.85 + r * 0.40, 0.32)
				machine.add_child(can)
		# Coin slot label
		var label: Label3D = Label3D.new()
		label.text = "$1"
		label.modulate = Color(0.95, 0.95, 1.0)
		label.outline_modulate = Color(0.05, 0.20, 0.40)
		label.outline_size = 4
		label.font_size = 32
		label.pixel_size = 0.005
		label.position = Vector3(0, 0.45, 0.36)
		machine.add_child(label)
		# Light
		var light: OmniLight3D = OmniLight3D.new()
		light.light_color = cab_colors[i]
		light.light_energy = 1.4
		light.omni_range = 3.0
		light.position = Vector3(0, 1.30, 0.55)
		machine.add_child(light)
		# Machine collision
		var sb: StaticBody3D = StaticBody3D.new()
		sb.position = Vector3(0, 1.10, 0)
		var cs: CollisionShape3D = CollisionShape3D.new()
		var cb: BoxShape3D = BoxShape3D.new()
		cb.size = Vector3(1.0, 2.20, 0.65)
		cs.shape = cb
		sb.add_child(cs)
		machine.add_child(sb)


func _build_d6_dance_club(geom: Node) -> void:
	## Epic-6 T26: dance club entrance — dark facade with pulsing magenta
	## door arch + 2 strobe lights flanking + thumping speaker boxes.
	var club: Node3D = Node3D.new()
	club.name = "DanceClub"
	club.position = Vector3(D6_CENTER.x - 22.0, 0.0, 14.0)
	geom.add_child(club)
	var dark_mat: StandardMaterial3D = StandardMaterial3D.new()
	dark_mat.albedo_color = Color(0.10, 0.05, 0.15)
	dark_mat.metallic = 0.30
	dark_mat.roughness = 0.55
	# Facade wall
	var wall: MeshInstance3D = MeshInstance3D.new()
	var wm: BoxMesh = BoxMesh.new()
	wm.size = Vector3(5.50, 4.20, 0.40)
	wall.mesh = wm
	wall.material_override = dark_mat
	wall.position = Vector3(0, 2.10, -1.20)
	club.add_child(wall)
	# Side walls
	for sx in [-2.55, 2.55]:
		var side: MeshInstance3D = MeshInstance3D.new()
		var swm: BoxMesh = BoxMesh.new()
		swm.size = Vector3(0.40, 4.20, 2.85)
		side.mesh = swm
		side.material_override = dark_mat
		side.position = Vector3(sx, 2.10, 0)
		club.add_child(side)
	# Roof
	var roof: MeshInstance3D = MeshInstance3D.new()
	var rm: BoxMesh = BoxMesh.new()
	rm.size = Vector3(5.50, 0.20, 3.10)
	roof.mesh = rm
	roof.material_override = dark_mat
	roof.position = Vector3(0, 4.30, 0)
	club.add_child(roof)
	# Door arch (dark interior)
	var door: MeshInstance3D = MeshInstance3D.new()
	var dm: BoxMesh = BoxMesh.new()
	dm.size = Vector3(1.85, 2.85, 0.10)
	door.mesh = dm
	var door_mat: StandardMaterial3D = StandardMaterial3D.new()
	door_mat.albedo_color = Color(0.05, 0.02, 0.10)
	door_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	door.material_override = door_mat
	door.position = Vector3(0, 1.55, 1.45)
	club.add_child(door)
	# Magenta arch tube around the door
	var arch_mat: StandardMaterial3D = StandardMaterial3D.new()
	arch_mat.albedo_color = Color(0.95, 0.20, 0.85)
	arch_mat.emission_enabled = true
	arch_mat.emission = Color(0.95, 0.20, 0.85)
	arch_mat.emission_energy_multiplier = 4.0
	arch_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for w in [
		{"size": Vector3(2.10, 0.10, 0.06), "pos": Vector3(0, 0.10, 1.50)},
		{"size": Vector3(2.10, 0.10, 0.06), "pos": Vector3(0, 3.10, 1.50)},
		{"size": Vector3(0.10, 3.0, 0.06), "pos": Vector3(-1.0, 1.55, 1.50)},
		{"size": Vector3(0.10, 3.0, 0.06), "pos": Vector3( 1.0, 1.55, 1.50)},
	]:
		var tube: MeshInstance3D = MeshInstance3D.new()
		var tm: BoxMesh = BoxMesh.new()
		tm.size = w["size"]
		tube.mesh = tm
		tube.material_override = arch_mat
		tube.position = w["pos"]
		club.add_child(tube)
	# 2 strobe lights flanking the door
	for sx in [-2.20, 2.20]:
		var strobe: MeshInstance3D = MeshInstance3D.new()
		var sm: SphereMesh = SphereMesh.new()
		sm.radius = 0.18
		sm.height = 0.32
		strobe.mesh = sm
		var strobe_mat: StandardMaterial3D = StandardMaterial3D.new()
		strobe_mat.albedo_color = Color(0.95, 0.95, 1.0)
		strobe_mat.emission_enabled = true
		strobe_mat.emission = Color(0.95, 0.95, 1.0)
		strobe_mat.emission_energy_multiplier = 4.0
		strobe_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		strobe.material_override = strobe_mat
		strobe.position = Vector3(sx, 3.40, 1.45)
		club.add_child(strobe)
		# Strobe flicker
		var tw: Tween = strobe.create_tween().set_loops()
		tw.tween_property(strobe, "scale", Vector3.ONE * 1.40, 0.10)
		tw.tween_property(strobe, "scale", Vector3.ONE * 0.30, 0.10)
		tw.tween_interval(0.10)
	# 2 speaker boxes on the ground beside the entrance
	var speaker_mat: StandardMaterial3D = StandardMaterial3D.new()
	speaker_mat.albedo_color = Color(0.10, 0.10, 0.15)
	speaker_mat.metallic = 0.55
	speaker_mat.roughness = 0.55
	for sx in [-2.20, 2.20]:
		var spk: MeshInstance3D = MeshInstance3D.new()
		var spm: BoxMesh = BoxMesh.new()
		spm.size = Vector3(0.85, 1.40, 0.85)
		spk.mesh = spm
		spk.material_override = speaker_mat
		spk.position = Vector3(sx * 0.80, 0.70, 1.65)
		club.add_child(spk)
		# Speaker cone (dark sphere)
		var cone: MeshInstance3D = MeshInstance3D.new()
		var cm: SphereMesh = SphereMesh.new()
		cm.radius = 0.22
		cm.height = 0.40
		cone.mesh = cm
		var cone_mat: StandardMaterial3D = StandardMaterial3D.new()
		cone_mat.albedo_color = Color(0.20, 0.18, 0.22)
		cone.material_override = cone_mat
		cone.position = Vector3(sx * 0.80, 0.95, 2.05)
		cone.scale = Vector3(1.0, 1.0, 0.30)
		club.add_child(cone)
		# Subtle pulse (bass)
		var ts: Tween = cone.create_tween().set_loops()
		ts.tween_property(cone, "scale", Vector3(1.05, 1.05, 0.40), 0.20)
		ts.tween_property(cone, "scale", Vector3(0.95, 0.95, 0.30), 0.20)
	# Massive magenta light
	var light: OmniLight3D = OmniLight3D.new()
	light.light_color = Color(1.0, 0.30, 0.85)
	light.light_energy = 4.0
	light.omni_range = 9.0
	light.position = Vector3(0, 1.85, 1.45)
	club.add_child(light)
	# Light pulse
	var twl: Tween = light.create_tween().set_loops()
	twl.tween_property(light, "light_energy", 5.5, 0.40)
	twl.tween_property(light, "light_energy", 3.5, 0.40)
	# Club collision
	var sb: StaticBody3D = StaticBody3D.new()
	sb.position = Vector3(0, 2.10, 0)
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(5.50, 4.20, 2.85)
	cs.shape = cb
	sb.add_child(cs)
	club.add_child(sb)


func _build_d6_bouncer_npc(town: Node) -> void:
	## Epic-6 T27: club bouncer NPC — large frame, sunglasses, arms crossed,
	## standing in front of the club door.
	var npc_slots: Node3D = town.get_node_or_null("%NPCSlots") as Node3D
	if npc_slots == null:
		return
	var slot: Marker3D = Marker3D.new()
	slot.name = "BouncerSlot"
	slot.position = Vector3(D6_CENTER.x - 22.0, 0.0, 16.0)
	npc_slots.add_child(slot)
	var npc_scene: PackedScene = load("res://scenes/entities/npcs/VillagerR3.tscn") as PackedScene
	if npc_scene == null:
		return
	var npc: Node3D = npc_scene.instantiate() as Node3D
	npc.name = "Bouncer"
	if "npc_name" in npc:
		npc.set("npc_name", "Vault")
	if "npc_id" in npc:
		npc.set("npc_id", "bouncer_d6")
	npc.scale = Vector3(1.20, 1.10, 1.20)
	slot.add_child(npc)
	# Big black suit
	var suit: MeshInstance3D = MeshInstance3D.new()
	var sm: BoxMesh = BoxMesh.new()
	sm.size = Vector3(0.95, 1.20, 0.55)
	suit.mesh = sm
	var suit_mat: StandardMaterial3D = StandardMaterial3D.new()
	suit_mat.albedo_color = Color(0.10, 0.08, 0.12)
	suit_mat.roughness = 0.55
	suit.material_override = suit_mat
	suit.position = Vector3(0, 0.60, 0)
	npc.add_child(suit)
	# Black sunglasses
	var shades: MeshInstance3D = MeshInstance3D.new()
	var smm: BoxMesh = BoxMesh.new()
	smm.size = Vector3(0.40, 0.10, 0.06)
	shades.mesh = smm
	var shades_mat: StandardMaterial3D = StandardMaterial3D.new()
	shades_mat.albedo_color = Color(0.05, 0.05, 0.08)
	shades_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	shades.material_override = shades_mat
	shades.position = Vector3(0, 1.40, 0.21)
	npc.add_child(shades)
	# Crossed arms (2 horizontal box arms in front of chest)
	for sx in [-0.20, 0.20]:
		var arm: MeshInstance3D = MeshInstance3D.new()
		var am: BoxMesh = BoxMesh.new()
		am.size = Vector3(0.55, 0.18, 0.18)
		arm.mesh = am
		arm.material_override = suit_mat
		arm.position = Vector3(sx * 0.20, 0.85, 0.30)
		arm.rotation_degrees = Vector3(0, 0, 12.0 if sx > 0 else -12.0)
		npc.add_child(arm)
	# Earpiece (small white sphere on ear)
	var earpiece: MeshInstance3D = MeshInstance3D.new()
	var em: SphereMesh = SphereMesh.new()
	em.radius = 0.05
	em.height = 0.10
	earpiece.mesh = em
	var ear_mat: StandardMaterial3D = StandardMaterial3D.new()
	ear_mat.albedo_color = Color(0.95, 0.92, 0.85)
	earpiece.material_override = ear_mat
	earpiece.position = Vector3(0.18, 1.40, 0)
	npc.add_child(earpiece)


func _build_d6_street_performer_npc(town: Node) -> void:
	## Epic-6 T28: street performer NPC dancing — colorful jumpsuit + arm
	## raise tween animation. Hat on the ground for tips.
	var npc_slots: Node3D = town.get_node_or_null("%NPCSlots") as Node3D
	if npc_slots == null:
		return
	var slot: Marker3D = Marker3D.new()
	slot.name = "StreetPerformerSlot"
	slot.position = Vector3(D6_CENTER.x - 4.0, 0.0, -10.0)
	npc_slots.add_child(slot)
	var npc_scene: PackedScene = load("res://scenes/entities/npcs/VillagerR3.tscn") as PackedScene
	if npc_scene == null:
		return
	var npc: Node3D = npc_scene.instantiate() as Node3D
	npc.name = "StreetPerformer"
	if "npc_name" in npc:
		npc.set("npc_name", "Strobe")
	if "npc_id" in npc:
		npc.set("npc_id", "performer_d6")
	slot.add_child(npc)
	# Colorful jumpsuit (split bright colors)
	var top: MeshInstance3D = MeshInstance3D.new()
	var tm: BoxMesh = BoxMesh.new()
	tm.size = Vector3(0.65, 0.55, 0.40)
	top.mesh = tm
	var top_mat: StandardMaterial3D = StandardMaterial3D.new()
	top_mat.albedo_color = Color(0.95, 0.20, 0.85)
	top_mat.emission_enabled = true
	top_mat.emission = Color(0.95, 0.30, 0.85)
	top_mat.emission_energy_multiplier = 0.55
	top_mat.roughness = 0.55
	top.material_override = top_mat
	top.position = Vector3(0, 0.85, 0)
	npc.add_child(top)
	# Lower half (different color)
	var bottom: MeshInstance3D = MeshInstance3D.new()
	var bm: BoxMesh = BoxMesh.new()
	bm.size = Vector3(0.65, 0.55, 0.40)
	bottom.mesh = bm
	var bot_mat: StandardMaterial3D = StandardMaterial3D.new()
	bot_mat.albedo_color = Color(0.30, 0.95, 1.0)
	bot_mat.emission_enabled = true
	bot_mat.emission = Color(0.30, 1.0, 1.0)
	bot_mat.emission_energy_multiplier = 0.55
	bot_mat.roughness = 0.55
	bottom.material_override = bot_mat
	bottom.position = Vector3(0, 0.30, 0)
	npc.add_child(bottom)
	# Hat on ground for tips (small cylinder + flat brim)
	var hat_brim: MeshInstance3D = MeshInstance3D.new()
	var hbm: CylinderMesh = CylinderMesh.new()
	hbm.top_radius = 0.30
	hbm.bottom_radius = 0.30
	hbm.height = 0.04
	hat_brim.mesh = hbm
	var hat_mat: StandardMaterial3D = StandardMaterial3D.new()
	hat_mat.albedo_color = Color(0.10, 0.08, 0.10)
	hat_mat.metallic = 0.30
	hat_brim.material_override = hat_mat
	hat_brim.position = Vector3(0.85, 0.04, 0.20)
	npc.add_child(hat_brim)
	var hat: MeshInstance3D = MeshInstance3D.new()
	var hm: CylinderMesh = CylinderMesh.new()
	hm.top_radius = 0.20
	hm.bottom_radius = 0.20
	hm.height = 0.30
	hat.mesh = hm
	hat.material_override = hat_mat
	hat.position = Vector3(0.85, 0.18, 0.20)
	npc.add_child(hat)
	# Few coin sparkles in hat
	var coin_mat: StandardMaterial3D = StandardMaterial3D.new()
	coin_mat.albedo_color = Color(1.0, 0.85, 0.30)
	coin_mat.emission_enabled = true
	coin_mat.emission = Color(1.0, 0.85, 0.30)
	coin_mat.emission_energy_multiplier = 1.4
	coin_mat.metallic = 0.85
	coin_mat.roughness = 0.10
	for i in 4:
		var coin: MeshInstance3D = MeshInstance3D.new()
		var cmm: CylinderMesh = CylinderMesh.new()
		cmm.top_radius = 0.04
		cmm.bottom_radius = 0.04
		cmm.height = 0.02
		coin.mesh = cmm
		coin.material_override = coin_mat
		coin.position = Vector3(0.85 + randf_range(-0.10, 0.10), 0.32, 0.20 + randf_range(-0.10, 0.10))
		npc.add_child(coin)
	# Dance: tilt body left/right
	var tw: Tween = npc.create_tween().set_loops()
	tw.tween_property(npc, "rotation_degrees:z", 8.0, 0.30)
	tw.tween_property(npc, "rotation_degrees:z", -8.0, 0.30)


func _build_d6_graffiti_walls(geom: Node) -> void:
	## Epic-6 T29: 4 graffiti walls — small dark walls with bright colored
	## emissive splash decals.
	var walls: Node3D = Node3D.new()
	walls.name = "GraffitiWalls"
	walls.position = Vector3(D6_CENTER.x + 28.0, 0.0, -16.0)
	geom.add_child(walls)
	var dark_mat: StandardMaterial3D = StandardMaterial3D.new()
	dark_mat.albedo_color = Color(0.18, 0.15, 0.20)
	dark_mat.roughness = 0.85
	var splash_colors: Array = [
		Color(0.95, 0.20, 0.85),
		Color(0.30, 0.95, 0.55),
		Color(0.95, 0.85, 0.30),
		Color(0.30, 0.65, 0.95),
	]
	for i in 4:
		var wall: Node3D = Node3D.new()
		wall.position = Vector3(i * 2.40, 0, 0)
		walls.add_child(wall)
		# Wall slab
		var slab: MeshInstance3D = MeshInstance3D.new()
		var sm: BoxMesh = BoxMesh.new()
		sm.size = Vector3(2.20, 3.40, 0.30)
		slab.mesh = sm
		slab.material_override = dark_mat
		slab.position = Vector3(0, 1.70, 0)
		wall.add_child(slab)
		# Random splashes
		for s in 5:
			var splash: MeshInstance3D = MeshInstance3D.new()
			var spm: SphereMesh = SphereMesh.new()
			spm.radius = 0.30 + randf() * 0.20
			spm.height = 0.18
			splash.mesh = spm
			var col: Color = splash_colors[(i + s) % 4]
			var splash_mat: StandardMaterial3D = StandardMaterial3D.new()
			splash_mat.albedo_color = col
			splash_mat.emission_enabled = true
			splash_mat.emission = col
			splash_mat.emission_energy_multiplier = 1.4
			splash_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
			splash.material_override = splash_mat
			splash.position = Vector3(
				randf_range(-0.85, 0.85),
				0.55 + randf_range(0, 2.40),
				0.18
			)
			splash.scale = Vector3(1.0, 0.85, 0.10)
			wall.add_child(splash)
		# Wall collision
		var sb: StaticBody3D = StaticBody3D.new()
		sb.position = Vector3(0, 1.70, 0)
		var cs: CollisionShape3D = CollisionShape3D.new()
		var cb: BoxShape3D = BoxShape3D.new()
		cb.size = Vector3(2.20, 3.40, 0.30)
		cs.shape = cb
		sb.add_child(cs)
		wall.add_child(sb)


func _build_d6_power_transformer(geom: Node) -> void:
	## Epic-6 T30: tall electrical power transformer — metal box on a
	## concrete pad with an arcing cyan electricity sphere on top.
	var trans: Node3D = Node3D.new()
	trans.name = "PowerTransformer"
	trans.position = Vector3(D6_CENTER.x + 14.0, 0.0, 18.0)
	geom.add_child(trans)
	var concrete_mat: StandardMaterial3D = StandardMaterial3D.new()
	concrete_mat.albedo_color = Color(0.40, 0.42, 0.45)
	concrete_mat.roughness = 0.92
	var metal_mat: StandardMaterial3D = StandardMaterial3D.new()
	metal_mat.albedo_color = Color(0.30, 0.32, 0.38)
	metal_mat.metallic = 0.85
	metal_mat.roughness = 0.30
	# Concrete pad
	var pad: MeshInstance3D = MeshInstance3D.new()
	var pm: BoxMesh = BoxMesh.new()
	pm.size = Vector3(2.20, 0.20, 1.85)
	pad.mesh = pm
	pad.material_override = concrete_mat
	pad.position = Vector3(0, 0.10, 0)
	trans.add_child(pad)
	# Main transformer box
	var box: MeshInstance3D = MeshInstance3D.new()
	var bm: BoxMesh = BoxMesh.new()
	bm.size = Vector3(1.85, 2.40, 1.40)
	box.mesh = bm
	box.material_override = metal_mat
	box.position = Vector3(0, 1.40, 0)
	trans.add_child(box)
	# Caution stripes (yellow/black warning)
	for i in 3:
		var stripe: MeshInstance3D = MeshInstance3D.new()
		var sm: BoxMesh = BoxMesh.new()
		sm.size = Vector3(1.85, 0.10, 0.04)
		stripe.mesh = sm
		var stripe_mat: StandardMaterial3D = StandardMaterial3D.new()
		stripe_mat.albedo_color = Color(0.95, 0.85, 0.20) if i % 2 == 0 else Color(0.10, 0.08, 0.10)
		stripe_mat.emission_enabled = true
		stripe_mat.emission = Color(0.95, 0.85, 0.20) if i % 2 == 0 else Color(0.0, 0.0, 0.0)
		stripe_mat.emission_energy_multiplier = 0.65
		stripe.material_override = stripe_mat
		stripe.position = Vector3(0, 0.85 + i * 0.18, 0.72)
		trans.add_child(stripe)
	# Arcing electricity sphere on top
	var arc: MeshInstance3D = MeshInstance3D.new()
	var am: SphereMesh = SphereMesh.new()
	am.radius = 0.35
	am.height = 0.65
	arc.mesh = am
	var arc_mat: StandardMaterial3D = StandardMaterial3D.new()
	arc_mat.albedo_color = Color(0.40, 0.95, 1.0, 0.85)
	arc_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	arc_mat.emission_enabled = true
	arc_mat.emission = Color(0.30, 1.0, 1.0)
	arc_mat.emission_energy_multiplier = 4.0
	arc_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	arc.material_override = arc_mat
	arc.position = Vector3(0, 2.85, 0)
	trans.add_child(arc)
	# Arc flicker
	var tw: Tween = arc.create_tween().set_loops()
	tw.tween_property(arc, "scale", Vector3(1.20, 1.20, 1.20), 0.10)
	tw.tween_property(arc, "scale", Vector3(0.85, 0.85, 0.85), 0.10)
	# Arc OmniLight
	var light: OmniLight3D = OmniLight3D.new()
	light.light_color = Color(0.40, 0.95, 1.0)
	light.light_energy = 2.5
	light.omni_range = 6.0
	light.position = Vector3(0, 2.85, 0)
	trans.add_child(light)
	var twl: Tween = light.create_tween().set_loops()
	twl.tween_property(light, "light_energy", 3.5, 0.10)
	twl.tween_property(light, "light_energy", 2.5, 0.10)
	# Box collision
	var sb: StaticBody3D = StaticBody3D.new()
	sb.position = Vector3(0, 1.40, 0)
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(2.20, 2.40, 1.85)
	cs.shape = cb
	sb.add_child(cs)
	trans.add_child(sb)


func _build_d6_motorbikes(geom: Node) -> void:
	## Epic-6 T31: 3 parked cyber motorbikes — sleek body + 2 wheels each +
	## colored neon trim under the seat.
	var bikes: Node3D = Node3D.new()
	bikes.name = "Motorbikes"
	bikes.position = Vector3(D6_CENTER.x + 4.0, 0.0, -16.0)
	geom.add_child(bikes)
	var bike_colors: Array = [
		Color(0.95, 0.20, 0.85),
		Color(0.30, 0.95, 1.0),
		Color(0.95, 0.85, 0.20),
	]
	for i in 3:
		var bike: Node3D = Node3D.new()
		bike.position = Vector3(i * 2.0, 0, 0)
		bike.rotation_degrees = Vector3(0, randf_range(-15, 15), 0)
		bikes.add_child(bike)
		# Body chassis
		var body: MeshInstance3D = MeshInstance3D.new()
		var bm: BoxMesh = BoxMesh.new()
		bm.size = Vector3(1.40, 0.30, 0.40)
		body.mesh = bm
		var body_mat: StandardMaterial3D = StandardMaterial3D.new()
		body_mat.albedo_color = Color(0.10, 0.10, 0.15)
		body_mat.metallic = 0.85
		body_mat.roughness = 0.30
		body.material_override = body_mat
		body.position = Vector3(0, 0.55, 0)
		bike.add_child(body)
		# Seat
		var seat: MeshInstance3D = MeshInstance3D.new()
		var sm: BoxMesh = BoxMesh.new()
		sm.size = Vector3(0.55, 0.18, 0.30)
		seat.mesh = sm
		var seat_mat: StandardMaterial3D = StandardMaterial3D.new()
		seat_mat.albedo_color = Color(0.20, 0.18, 0.22)
		seat_mat.roughness = 0.55
		seat.material_override = seat_mat
		seat.position = Vector3(-0.10, 0.85, 0)
		bike.add_child(seat)
		# Front fairing (windshield prism)
		var fair: MeshInstance3D = MeshInstance3D.new()
		var fm: PrismMesh = PrismMesh.new()
		fm.size = Vector3(0.40, 0.40, 0.20)
		fair.mesh = fm
		fair.material_override = body_mat
		fair.position = Vector3(0.65, 0.85, 0)
		fair.rotation_degrees = Vector3(0, 0, -25)
		bike.add_child(fair)
		# Handlebars
		var bars: MeshInstance3D = MeshInstance3D.new()
		var brm: CylinderMesh = CylinderMesh.new()
		brm.top_radius = 0.025
		brm.bottom_radius = 0.025
		brm.height = 0.55
		bars.mesh = brm
		bars.material_override = body_mat
		bars.position = Vector3(0.55, 1.0, 0)
		bars.rotation_degrees = Vector3(90, 0, 0)
		bike.add_child(bars)
		# Front + rear wheels
		var wheel_mat: StandardMaterial3D = StandardMaterial3D.new()
		wheel_mat.albedo_color = Color(0.05, 0.05, 0.08)
		wheel_mat.roughness = 0.85
		for wx in [0.65, -0.65]:
			var wheel: MeshInstance3D = MeshInstance3D.new()
			var wm: CylinderMesh = CylinderMesh.new()
			wm.top_radius = 0.30
			wm.bottom_radius = 0.30
			wm.height = 0.18
			wheel.mesh = wm
			wheel.material_override = wheel_mat
			wheel.position = Vector3(wx, 0.30, 0)
			wheel.rotation_degrees = Vector3(0, 0, 90)
			bike.add_child(wheel)
		# Neon underglow strip
		var glow: MeshInstance3D = MeshInstance3D.new()
		var gm: BoxMesh = BoxMesh.new()
		gm.size = Vector3(1.40, 0.04, 0.30)
		glow.mesh = gm
		var glow_mat: StandardMaterial3D = StandardMaterial3D.new()
		glow_mat.albedo_color = bike_colors[i]
		glow_mat.emission_enabled = true
		glow_mat.emission = bike_colors[i]
		glow_mat.emission_energy_multiplier = 3.0
		glow_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		glow.material_override = glow_mat
		glow.position = Vector3(0, 0.40, 0)
		bike.add_child(glow)
		# Underglow light
		var light: OmniLight3D = OmniLight3D.new()
		light.light_color = bike_colors[i]
		light.light_energy = 1.4
		light.omni_range = 2.5
		light.position = Vector3(0, 0.30, 0)
		bike.add_child(light)
		# Bike collision
		var sb: StaticBody3D = StaticBody3D.new()
		sb.position = Vector3(0, 0.65, 0)
		var cs: CollisionShape3D = CollisionShape3D.new()
		var cb: BoxShape3D = BoxShape3D.new()
		cb.size = Vector3(1.85, 1.30, 0.55)
		cs.shape = cb
		sb.add_child(cs)
		bike.add_child(sb)


func _build_d6_courier_npc(town: Node) -> void:
	## Epic-6 T32: courier NPC — leather jacket + helmet + phone in hand,
	## stationed near the parked bikes.
	var npc_slots: Node3D = town.get_node_or_null("%NPCSlots") as Node3D
	if npc_slots == null:
		return
	var slot: Marker3D = Marker3D.new()
	slot.name = "CourierSlot"
	slot.position = Vector3(D6_CENTER.x + 8.0, 0.0, -16.0)
	npc_slots.add_child(slot)
	var npc_scene: PackedScene = load("res://scenes/entities/npcs/VillagerR3.tscn") as PackedScene
	if npc_scene == null:
		return
	var npc: Node3D = npc_scene.instantiate() as Node3D
	npc.name = "Courier"
	if "npc_name" in npc:
		npc.set("npc_name", "Lag")
	if "npc_id" in npc:
		npc.set("npc_id", "courier_d6")
	slot.add_child(npc)
	# Leather jacket
	var jacket: MeshInstance3D = MeshInstance3D.new()
	var jm: BoxMesh = BoxMesh.new()
	jm.size = Vector3(0.65, 1.05, 0.45)
	jacket.mesh = jm
	var jacket_mat: StandardMaterial3D = StandardMaterial3D.new()
	jacket_mat.albedo_color = Color(0.15, 0.10, 0.08)
	jacket_mat.metallic = 0.30
	jacket_mat.roughness = 0.45
	jacket.material_override = jacket_mat
	jacket.position = Vector3(0, 0.55, 0)
	npc.add_child(jacket)
	# Helmet (sphere)
	var helmet: MeshInstance3D = MeshInstance3D.new()
	var hm: SphereMesh = SphereMesh.new()
	hm.radius = 0.24
	hm.height = 0.42
	helmet.mesh = hm
	var helmet_mat: StandardMaterial3D = StandardMaterial3D.new()
	helmet_mat.albedo_color = Color(0.95, 0.20, 0.30)
	helmet_mat.metallic = 0.55
	helmet_mat.roughness = 0.20
	helmet.material_override = helmet_mat
	helmet.position = Vector3(0, 1.45, 0)
	npc.add_child(helmet)
	# Visor (cyan strip)
	var visor: MeshInstance3D = MeshInstance3D.new()
	var vm: BoxMesh = BoxMesh.new()
	vm.size = Vector3(0.40, 0.10, 0.04)
	visor.mesh = vm
	var visor_mat: StandardMaterial3D = StandardMaterial3D.new()
	visor_mat.albedo_color = Color(0.30, 0.95, 1.0)
	visor_mat.emission_enabled = true
	visor_mat.emission = Color(0.30, 1.0, 1.0)
	visor_mat.emission_energy_multiplier = 2.0
	visor_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	visor.material_override = visor_mat
	visor.position = Vector3(0, 1.42, 0.20)
	npc.add_child(visor)
	# Phone in hand (small flat box with cyan screen)
	var phone: MeshInstance3D = MeshInstance3D.new()
	var pmm: BoxMesh = BoxMesh.new()
	pmm.size = Vector3(0.12, 0.20, 0.03)
	phone.mesh = pmm
	var phone_mat: StandardMaterial3D = StandardMaterial3D.new()
	phone_mat.albedo_color = Color(0.30, 0.95, 1.0)
	phone_mat.emission_enabled = true
	phone_mat.emission = Color(0.30, 1.0, 1.0)
	phone_mat.emission_energy_multiplier = 2.5
	phone_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	phone.material_override = phone_mat
	phone.position = Vector3(0.40, 0.85, 0.22)
	phone.rotation_degrees = Vector3(-30, 0, 0)
	npc.add_child(phone)


func _build_d6_phone_booth(geom: Node) -> void:
	## Epic-6 T33: retro phone booth kiosk — tall translucent box with neon
	## frame outline and a glowing receiver inside.
	var booth: Node3D = Node3D.new()
	booth.name = "PhoneBooth"
	booth.position = Vector3(D6_CENTER.x + 18.0, 0.0, -10.0)
	geom.add_child(booth)
	var dark_mat: StandardMaterial3D = StandardMaterial3D.new()
	dark_mat.albedo_color = Color(0.10, 0.08, 0.15)
	dark_mat.metallic = 0.85
	dark_mat.roughness = 0.30
	var glass_mat: StandardMaterial3D = StandardMaterial3D.new()
	glass_mat.albedo_color = Color(0.40, 0.85, 1.0, 0.30)
	glass_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	glass_mat.emission_enabled = true
	glass_mat.emission = Color(0.40, 0.85, 1.0)
	glass_mat.emission_energy_multiplier = 0.45
	glass_mat.metallic = 0.55
	glass_mat.roughness = 0.05
	# Box body (translucent)
	var body: MeshInstance3D = MeshInstance3D.new()
	var bm: BoxMesh = BoxMesh.new()
	bm.size = Vector3(1.10, 2.40, 1.10)
	body.mesh = bm
	body.material_override = glass_mat
	body.position = Vector3(0, 1.20, 0)
	booth.add_child(body)
	# Frame outline (4 corner pillars)
	for sx in [-0.55, 0.55]:
		for sz in [-0.55, 0.55]:
			var pillar: MeshInstance3D = MeshInstance3D.new()
			var pm: BoxMesh = BoxMesh.new()
			pm.size = Vector3(0.10, 2.40, 0.10)
			pillar.mesh = pm
			pillar.material_override = dark_mat
			pillar.position = Vector3(sx, 1.20, sz)
			booth.add_child(pillar)
	# Top neon outline (magenta tube around the top)
	var neon_mat: StandardMaterial3D = StandardMaterial3D.new()
	neon_mat.albedo_color = Color(0.95, 0.20, 0.85)
	neon_mat.emission_enabled = true
	neon_mat.emission = Color(0.95, 0.20, 0.85)
	neon_mat.emission_energy_multiplier = 3.5
	neon_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for w in [
		{"size": Vector3(1.10, 0.06, 0.06), "pos": Vector3(0, 2.45,  0.55)},
		{"size": Vector3(1.10, 0.06, 0.06), "pos": Vector3(0, 2.45, -0.55)},
		{"size": Vector3(0.06, 0.06, 1.10), "pos": Vector3( 0.55, 2.45, 0)},
		{"size": Vector3(0.06, 0.06, 1.10), "pos": Vector3(-0.55, 2.45, 0)},
	]:
		var tube: MeshInstance3D = MeshInstance3D.new()
		var tm: BoxMesh = BoxMesh.new()
		tm.size = w["size"]
		tube.mesh = tm
		tube.material_override = neon_mat
		tube.position = w["pos"]
		booth.add_child(tube)
	# Phone receiver inside (small dark cylinder + cord)
	var receiver: MeshInstance3D = MeshInstance3D.new()
	var rm: BoxMesh = BoxMesh.new()
	rm.size = Vector3(0.06, 0.20, 0.10)
	receiver.mesh = rm
	receiver.material_override = dark_mat
	receiver.position = Vector3(0.30, 1.55, 0.40)
	booth.add_child(receiver)
	# Top "TEL" label
	var label: Label3D = Label3D.new()
	label.text = "TEL"
	label.modulate = Color(0.95, 0.95, 1.0)
	label.outline_modulate = Color(0.95, 0.20, 0.85)
	label.outline_size = 6
	label.font_size = 56
	label.pixel_size = 0.008
	label.position = Vector3(0, 2.65, 0.55)
	booth.add_child(label)
	# Light
	var light: OmniLight3D = OmniLight3D.new()
	light.light_color = Color(1.0, 0.30, 0.85)
	light.light_energy = 1.6
	light.omni_range = 3.5
	light.position = Vector3(0, 1.55, 0)
	booth.add_child(light)
	# Booth collision
	var sb: StaticBody3D = StaticBody3D.new()
	sb.position = Vector3(0, 1.20, 0)
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(1.10, 2.40, 1.10)
	cs.shape = cb
	sb.add_child(cs)
	booth.add_child(sb)


func _build_d6_synth_musician_npc(town: Node) -> void:
	## Epic-6 T34: synth musician NPC — colorful jacket + behind a small
	## floating keyboard with bright sequencer LEDs.
	var npc_slots: Node3D = town.get_node_or_null("%NPCSlots") as Node3D
	if npc_slots == null:
		return
	var slot: Marker3D = Marker3D.new()
	slot.name = "SynthMusicianSlot"
	slot.position = Vector3(D6_CENTER.x + 4.0, 0.0, -10.0)
	npc_slots.add_child(slot)
	var npc_scene: PackedScene = load("res://scenes/entities/npcs/VillagerR3.tscn") as PackedScene
	if npc_scene == null:
		return
	var npc: Node3D = npc_scene.instantiate() as Node3D
	npc.name = "SynthMusician"
	if "npc_name" in npc:
		npc.set("npc_name", "Bitcrush")
	if "npc_id" in npc:
		npc.set("npc_id", "synth_d6")
	slot.add_child(npc)
	# Holographic jacket
	var jacket: MeshInstance3D = MeshInstance3D.new()
	var jm: BoxMesh = BoxMesh.new()
	jm.size = Vector3(0.65, 1.05, 0.40)
	jacket.mesh = jm
	var jacket_mat: StandardMaterial3D = StandardMaterial3D.new()
	jacket_mat.albedo_color = Color(0.55, 0.30, 0.95)
	jacket_mat.emission_enabled = true
	jacket_mat.emission = Color(0.55, 0.30, 0.95)
	jacket_mat.emission_energy_multiplier = 0.45
	jacket_mat.metallic = 0.30
	jacket_mat.roughness = 0.55
	jacket.material_override = jacket_mat
	jacket.position = Vector3(0, 0.55, 0)
	npc.add_child(jacket)
	# Floating keyboard (long flat box in front)
	var key: MeshInstance3D = MeshInstance3D.new()
	var km: BoxMesh = BoxMesh.new()
	km.size = Vector3(1.40, 0.10, 0.40)
	key.mesh = km
	var key_mat: StandardMaterial3D = StandardMaterial3D.new()
	key_mat.albedo_color = Color(0.10, 0.10, 0.15)
	key_mat.metallic = 0.85
	key_mat.roughness = 0.30
	key.material_override = key_mat
	key.position = Vector3(0, 0.85, 0.40)
	npc.add_child(key)
	# 12 small LED keys on top of the keyboard
	var led_colors: Array = [
		Color(0.95, 0.20, 0.30),
		Color(0.30, 0.95, 0.55),
		Color(0.30, 0.65, 0.95),
		Color(0.95, 0.85, 0.20),
	]
	for i in 12:
		var led: MeshInstance3D = MeshInstance3D.new()
		var lm: BoxMesh = BoxMesh.new()
		lm.size = Vector3(0.08, 0.04, 0.30)
		led.mesh = lm
		var led_mat: StandardMaterial3D = StandardMaterial3D.new()
		led_mat.albedo_color = led_colors[i % 4]
		led_mat.emission_enabled = true
		led_mat.emission = led_colors[i % 4]
		led_mat.emission_energy_multiplier = 2.5
		led_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		led.material_override = led_mat
		led.position = Vector3(-0.65 + i * 0.12, 0.92, 0.40)
		npc.add_child(led)
		# Sequencer flicker
		var tw: Tween = led.create_tween().set_loops()
		tw.tween_interval(i * 0.08)
		tw.tween_property(led, "scale:y", 1.40, 0.20)
		tw.tween_property(led, "scale:y", 0.65, 0.20)
	# Hands hovering over the keyboard
	for sx in [-0.30, 0.30]:
		var hand: MeshInstance3D = MeshInstance3D.new()
		var hmm: SphereMesh = SphereMesh.new()
		hmm.radius = 0.08
		hmm.height = 0.16
		hand.mesh = hmm
		var skin_mat: StandardMaterial3D = StandardMaterial3D.new()
		skin_mat.albedo_color = Color(0.95, 0.85, 0.75)
		hand.material_override = skin_mat
		hand.position = Vector3(sx, 1.0, 0.30)
		npc.add_child(hand)


func _build_d6_satellite_dishes(geom: Node) -> void:
	## Epic-6 T35: cluster of 4 rooftop satellite dishes on a metal rack +
	## blinking red status lights.
	var dishes: Node3D = Node3D.new()
	dishes.name = "SatelliteDishes"
	dishes.position = Vector3(D6_CENTER.x - 14.0, 0.0, -16.0)
	geom.add_child(dishes)
	var metal_mat: StandardMaterial3D = StandardMaterial3D.new()
	metal_mat.albedo_color = Color(0.40, 0.45, 0.50)
	metal_mat.metallic = 0.85
	metal_mat.roughness = 0.30
	# Rack base
	var rack: MeshInstance3D = MeshInstance3D.new()
	var rm: BoxMesh = BoxMesh.new()
	rm.size = Vector3(3.40, 0.30, 1.40)
	rack.mesh = rm
	rack.material_override = metal_mat
	rack.position = Vector3(0, 0.15, 0)
	dishes.add_child(rack)
	# 4 vertical posts + dishes
	for i in 4:
		var post: MeshInstance3D = MeshInstance3D.new()
		var pm: CylinderMesh = CylinderMesh.new()
		pm.top_radius = 0.06
		pm.bottom_radius = 0.08
		pm.height = 1.85
		post.mesh = pm
		post.material_override = metal_mat
		post.position = Vector3(-1.30 + i * 0.85, 1.10, 0)
		dishes.add_child(post)
		# Dish (half sphere flattened)
		var dish: MeshInstance3D = MeshInstance3D.new()
		var dm: SphereMesh = SphereMesh.new()
		dm.radius = 0.55
		dm.height = 0.55
		dish.mesh = dm
		dish.material_override = metal_mat
		dish.position = Vector3(-1.30 + i * 0.85, 2.0, 0.20)
		dish.scale = Vector3(1.0, 0.30, 1.0)
		dish.rotation_degrees = Vector3(45 + i * 5, 0, 0)
		dishes.add_child(dish)
		# Receiver (small box at center of dish)
		var rec: MeshInstance3D = MeshInstance3D.new()
		var rcm: SphereMesh = SphereMesh.new()
		rcm.radius = 0.06
		rcm.height = 0.12
		rec.mesh = rcm
		var rec_mat: StandardMaterial3D = StandardMaterial3D.new()
		rec_mat.albedo_color = Color(0.30, 0.95, 1.0)
		rec_mat.emission_enabled = true
		rec_mat.emission = Color(0.30, 1.0, 1.0)
		rec_mat.emission_energy_multiplier = 2.5
		rec_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		rec.material_override = rec_mat
		rec.position = Vector3(-1.30 + i * 0.85, 2.0, 0.45)
		dishes.add_child(rec)
		# Red blinking status light
		var status: MeshInstance3D = MeshInstance3D.new()
		var stm: SphereMesh = SphereMesh.new()
		stm.radius = 0.05
		stm.height = 0.10
		status.mesh = stm
		var stat_mat: StandardMaterial3D = StandardMaterial3D.new()
		stat_mat.albedo_color = Color(0.95, 0.20, 0.20)
		stat_mat.emission_enabled = true
		stat_mat.emission = Color(0.95, 0.20, 0.20)
		stat_mat.emission_energy_multiplier = 4.0
		stat_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		status.material_override = stat_mat
		status.position = Vector3(-1.30 + i * 0.85, 0.55, 0.65)
		dishes.add_child(status)
		var tw: Tween = status.create_tween().set_loops()
		tw.tween_interval(i * 0.20)
		tw.tween_property(status, "scale", Vector3.ONE * 1.40, 0.30)
		tw.tween_property(status, "scale", Vector3.ONE * 0.40, 0.30)
	# Rack collision
	var sb: StaticBody3D = StaticBody3D.new()
	sb.position = Vector3(0, 0.85, 0)
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(3.40, 1.85, 1.40)
	cs.shape = cb
	sb.add_child(cs)
	dishes.add_child(sb)


func _build_d6_implant_clinic(geom: Node) -> void:
	## Epic-6 T36: cyber implant clinic — clean white storefront with a
	## green cross emblem, an operating chair visible inside, and a row
	## of glowing implant cylinders on display.
	var clinic: Node3D = Node3D.new()
	clinic.name = "ImplantClinic"
	clinic.position = Vector3(D6_CENTER.x - 14.0, 0.0, 14.0)
	geom.add_child(clinic)
	var white_mat: StandardMaterial3D = StandardMaterial3D.new()
	white_mat.albedo_color = Color(0.92, 0.95, 0.98)
	white_mat.emission_enabled = true
	white_mat.emission = Color(0.65, 0.85, 0.95)
	white_mat.emission_energy_multiplier = 0.30
	white_mat.roughness = 0.45
	# Storefront wall
	var wall: MeshInstance3D = MeshInstance3D.new()
	var wm: BoxMesh = BoxMesh.new()
	wm.size = Vector3(4.20, 3.40, 0.30)
	wall.mesh = wm
	wall.material_override = white_mat
	wall.position = Vector3(0, 1.70, -1.20)
	clinic.add_child(wall)
	# Side walls
	for sx in [-2.0, 2.0]:
		var side: MeshInstance3D = MeshInstance3D.new()
		var swm: BoxMesh = BoxMesh.new()
		swm.size = Vector3(0.30, 3.40, 2.40)
		side.mesh = swm
		side.material_override = white_mat
		side.position = Vector3(sx, 1.70, 0)
		clinic.add_child(side)
	# Roof
	var roof: MeshInstance3D = MeshInstance3D.new()
	var rm: BoxMesh = BoxMesh.new()
	rm.size = Vector3(4.20, 0.18, 2.55)
	roof.mesh = rm
	roof.material_override = white_mat
	roof.position = Vector3(0, 3.50, 0)
	clinic.add_child(roof)
	# Green cross emblem
	var cross_mat: StandardMaterial3D = StandardMaterial3D.new()
	cross_mat.albedo_color = Color(0.30, 0.95, 0.30)
	cross_mat.emission_enabled = true
	cross_mat.emission = Color(0.30, 1.0, 0.30)
	cross_mat.emission_energy_multiplier = 3.5
	cross_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for axis in 2:
		var bar: MeshInstance3D = MeshInstance3D.new()
		var bm: BoxMesh = BoxMesh.new()
		bm.size = Vector3(0.85, 0.30, 0.06) if axis == 0 else Vector3(0.30, 0.85, 0.06)
		bar.mesh = bm
		bar.material_override = cross_mat
		bar.position = Vector3(0, 2.65, 1.21)
		clinic.add_child(bar)
	# Operating chair (white box on a column)
	var chair: MeshInstance3D = MeshInstance3D.new()
	var cm: BoxMesh = BoxMesh.new()
	cm.size = Vector3(0.85, 0.20, 1.40)
	chair.mesh = cm
	chair.material_override = white_mat
	chair.position = Vector3(0, 0.85, -0.20)
	clinic.add_child(chair)
	var col: MeshInstance3D = MeshInstance3D.new()
	var clm: BoxMesh = BoxMesh.new()
	clm.size = Vector3(0.30, 0.55, 0.30)
	col.mesh = clm
	col.material_override = white_mat
	col.position = Vector3(0, 0.42, -0.20)
	clinic.add_child(col)
	# Implant cylinders display (3 small glowing tubes inside the clinic)
	var implant_mat: StandardMaterial3D = StandardMaterial3D.new()
	implant_mat.albedo_color = Color(0.30, 0.95, 0.55)
	implant_mat.emission_enabled = true
	implant_mat.emission = Color(0.30, 1.0, 0.55)
	implant_mat.emission_energy_multiplier = 2.5
	implant_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for i in 3:
		var implant: MeshInstance3D = MeshInstance3D.new()
		var im: CylinderMesh = CylinderMesh.new()
		im.top_radius = 0.08
		im.bottom_radius = 0.08
		im.height = 0.30
		implant.mesh = im
		implant.material_override = implant_mat
		implant.position = Vector3(-0.55 + i * 0.55, 1.85, 0.40)
		clinic.add_child(implant)
		var tw: Tween = implant.create_tween().set_loops()
		tw.tween_interval(i * 0.20)
		tw.tween_property(implant, "scale:y", 1.30, 0.85)
		tw.tween_property(implant, "scale:y", 0.85, 0.85)
	# Light
	var light: OmniLight3D = OmniLight3D.new()
	light.light_color = Color(0.30, 1.0, 0.55)
	light.light_energy = 2.0
	light.omni_range = 5.0
	light.position = Vector3(0, 2.20, 1.20)
	clinic.add_child(light)
	# Clinic collision
	var sb: StaticBody3D = StaticBody3D.new()
	sb.position = Vector3(0, 1.70, 0)
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(4.20, 3.40, 2.55)
	cs.shape = cb
	sb.add_child(cs)
	clinic.add_child(sb)


func _build_d6_cyberdoc_npc(town: Node) -> void:
	## Epic-6 T37: cyberdoc NPC — white lab coat + surgical mask + scalpel
	## glow in hand.
	var npc_slots: Node3D = town.get_node_or_null("%NPCSlots") as Node3D
	if npc_slots == null:
		return
	var slot: Marker3D = Marker3D.new()
	slot.name = "CyberDocSlot"
	slot.position = Vector3(D6_CENTER.x - 14.0, 0.0, 13.0)
	npc_slots.add_child(slot)
	var npc_scene: PackedScene = load("res://scenes/entities/npcs/VillagerR3.tscn") as PackedScene
	if npc_scene == null:
		return
	var npc: Node3D = npc_scene.instantiate() as Node3D
	npc.name = "CyberDoc"
	if "npc_name" in npc:
		npc.set("npc_name", "Splice")
	if "npc_id" in npc:
		npc.set("npc_id", "cyberdoc_d6")
	slot.add_child(npc)
	# White lab coat
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
	# Surgical mask (small box across face)
	var mask: MeshInstance3D = MeshInstance3D.new()
	var mm: BoxMesh = BoxMesh.new()
	mm.size = Vector3(0.40, 0.20, 0.06)
	mask.mesh = mm
	var mask_mat: StandardMaterial3D = StandardMaterial3D.new()
	mask_mat.albedo_color = Color(0.55, 0.85, 0.95)
	mask.material_override = mask_mat
	mask.position = Vector3(0, 1.30, 0.21)
	npc.add_child(mask)
	# Scalpel in hand
	var scalpel: MeshInstance3D = MeshInstance3D.new()
	var sm: BoxMesh = BoxMesh.new()
	sm.size = Vector3(0.04, 0.20, 0.10)
	scalpel.mesh = sm
	var scalpel_mat: StandardMaterial3D = StandardMaterial3D.new()
	scalpel_mat.albedo_color = Color(0.85, 0.92, 1.0)
	scalpel_mat.emission_enabled = true
	scalpel_mat.emission = Color(0.30, 0.95, 1.0)
	scalpel_mat.emission_energy_multiplier = 2.5
	scalpel_mat.metallic = 0.95
	scalpel_mat.roughness = 0.05
	scalpel.material_override = scalpel_mat
	scalpel.position = Vector3(0.40, 0.85, 0.20)
	npc.add_child(scalpel)


func _build_d6_atm_row(geom: Node) -> void:
	## Epic-6 T38: row of 4 ATM machines — wall-mounted screens with cash
	## slot below + green LED status.
	var row: Node3D = Node3D.new()
	row.name = "ATMRow"
	row.position = Vector3(D6_CENTER.x - 12.0, 0.0, -16.0)
	geom.add_child(row)
	var wall_mat: StandardMaterial3D = StandardMaterial3D.new()
	wall_mat.albedo_color = Color(0.20, 0.18, 0.25)
	wall_mat.metallic = 0.55
	wall_mat.roughness = 0.45
	# Backing wall slab
	var wall: MeshInstance3D = MeshInstance3D.new()
	var wm: BoxMesh = BoxMesh.new()
	wm.size = Vector3(8.50, 3.40, 0.30)
	wall.mesh = wm
	wall.material_override = wall_mat
	wall.position = Vector3(0, 1.70, -0.18)
	row.add_child(wall)
	for i in 4:
		var atm: Node3D = Node3D.new()
		atm.position = Vector3(-3.20 + i * 2.20, 0, 0)
		row.add_child(atm)
		# ATM body (recessed)
		var body: MeshInstance3D = MeshInstance3D.new()
		var bm: BoxMesh = BoxMesh.new()
		bm.size = Vector3(1.85, 2.40, 0.20)
		body.mesh = bm
		body.material_override = wall_mat
		body.position = Vector3(0, 1.40, 0)
		atm.add_child(body)
		# Screen
		var screen: MeshInstance3D = MeshInstance3D.new()
		var sm: BoxMesh = BoxMesh.new()
		sm.size = Vector3(1.40, 0.95, 0.06)
		screen.mesh = sm
		var screen_mat: StandardMaterial3D = StandardMaterial3D.new()
		screen_mat.albedo_color = Color(0.30, 0.95, 1.0)
		screen_mat.emission_enabled = true
		screen_mat.emission = Color(0.30, 1.0, 1.0)
		screen_mat.emission_energy_multiplier = 2.5
		screen_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		screen.material_override = screen_mat
		screen.position = Vector3(0, 1.85, 0.10)
		atm.add_child(screen)
		# Cash slot (small dark rectangle)
		var slot: MeshInstance3D = MeshInstance3D.new()
		var stm: BoxMesh = BoxMesh.new()
		stm.size = Vector3(1.10, 0.10, 0.04)
		slot.mesh = stm
		var slot_mat: StandardMaterial3D = StandardMaterial3D.new()
		slot_mat.albedo_color = Color(0.05, 0.05, 0.08)
		slot_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		slot.material_override = slot_mat
		slot.position = Vector3(0, 1.10, 0.10)
		atm.add_child(slot)
		# Green LED status
		var led: MeshInstance3D = MeshInstance3D.new()
		var lm: SphereMesh = SphereMesh.new()
		lm.radius = 0.05
		lm.height = 0.10
		led.mesh = lm
		var led_mat: StandardMaterial3D = StandardMaterial3D.new()
		led_mat.albedo_color = Color(0.30, 1.0, 0.30)
		led_mat.emission_enabled = true
		led_mat.emission = Color(0.30, 1.0, 0.30)
		led_mat.emission_energy_multiplier = 3.0
		led_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		led.material_override = led_mat
		led.position = Vector3(0.85, 2.30, 0.10)
		atm.add_child(led)
		# Slow blink
		var tw: Tween = led.create_tween().set_loops()
		tw.tween_interval(i * 0.30)
		tw.tween_property(led, "scale", Vector3.ONE * 1.40, 0.55)
		tw.tween_property(led, "scale", Vector3.ONE * 0.55, 0.55)
	# Wall collision
	var sb: StaticBody3D = StaticBody3D.new()
	sb.position = Vector3(0, 1.70, -0.18)
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(8.50, 3.40, 0.30)
	cs.shape = cb
	sb.add_child(cs)
	row.add_child(sb)


func _build_d6_rave_dancers(geom: Node) -> void:
	## Epic-6 T39: 5 small rave dancer figures jumping/swaying near the
	## dance club. Bright glowsticks tracing arcs.
	var crowd: Node3D = Node3D.new()
	crowd.name = "RaveDancers"
	crowd.position = Vector3(D6_CENTER.x - 22.0, 0.0, 8.0)
	geom.add_child(crowd)
	var dancer_colors: Array = [
		Color(0.95, 0.20, 0.85),
		Color(0.30, 0.95, 0.55),
		Color(0.30, 0.65, 0.95),
		Color(0.95, 0.85, 0.20),
		Color(0.95, 0.30, 0.30),
	]
	for i in 5:
		var dancer: Node3D = Node3D.new()
		dancer.position = Vector3(
			randf_range(-3.0, 3.0),
			0,
			randf_range(-2.5, 2.5)
		)
		crowd.add_child(dancer)
		# Body
		var body: MeshInstance3D = MeshInstance3D.new()
		var bm: BoxMesh = BoxMesh.new()
		bm.size = Vector3(0.55, 0.95, 0.30)
		body.mesh = bm
		var body_mat: StandardMaterial3D = StandardMaterial3D.new()
		body_mat.albedo_color = dancer_colors[i]
		body_mat.emission_enabled = true
		body_mat.emission = dancer_colors[i]
		body_mat.emission_energy_multiplier = 0.65
		body_mat.roughness = 0.65
		body.material_override = body_mat
		body.position = Vector3(0, 0.55, 0)
		dancer.add_child(body)
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
		dancer.add_child(head)
		# 2 glowsticks held overhead (small bright cylinders)
		var stick_mat: StandardMaterial3D = StandardMaterial3D.new()
		stick_mat.albedo_color = dancer_colors[(i + 2) % 5]
		stick_mat.emission_enabled = true
		stick_mat.emission = dancer_colors[(i + 2) % 5]
		stick_mat.emission_energy_multiplier = 4.0
		stick_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		for sx in [-0.30, 0.30]:
			var stick: MeshInstance3D = MeshInstance3D.new()
			var stm: CylinderMesh = CylinderMesh.new()
			stm.top_radius = 0.025
			stm.bottom_radius = 0.025
			stm.height = 0.30
			stick.mesh = stm
			stick.material_override = stick_mat
			stick.position = Vector3(sx, 1.65, 0)
			dancer.add_child(stick)
		# Jump tween
		var tw: Tween = dancer.create_tween().set_loops()
		tw.tween_property(dancer, "position:y", 0.30, 0.25)
		tw.tween_property(dancer, "position:y", 0.0, 0.25)
		# Sway tween
		var ts: Tween = dancer.create_tween().set_loops()
		ts.tween_property(dancer, "rotation_degrees:z", 12.0, 0.40)
		ts.tween_property(dancer, "rotation_degrees:z", -12.0, 0.40)


func _build_d6_steam_vents(geom: Node) -> void:
	## Epic-6 T40: 4 steam vents on the ground — small dark grates with
	## thick rising steam from below.
	var vents: Node3D = Node3D.new()
	vents.name = "SteamVents"
	vents.position = Vector3(D6_CENTER.x - 4.0, 0.0, 4.0)
	geom.add_child(vents)
	var grate_mat: StandardMaterial3D = StandardMaterial3D.new()
	grate_mat.albedo_color = Color(0.20, 0.18, 0.22)
	grate_mat.metallic = 0.85
	grate_mat.roughness = 0.45
	for i in 4:
		var vent: Node3D = Node3D.new()
		vent.position = Vector3(
			randf_range(-6, 6),
			0,
			randf_range(-4, 4)
		)
		vents.add_child(vent)
		# Grate (flat box with slits)
		var grate: MeshInstance3D = MeshInstance3D.new()
		var gm: BoxMesh = BoxMesh.new()
		gm.size = Vector3(0.85, 0.04, 0.85)
		grate.mesh = gm
		grate.material_override = grate_mat
		grate.position = Vector3(0, 0.04, 0)
		vent.add_child(grate)
		# Steam particles
		var steam: GPUParticles3D = GPUParticles3D.new()
		steam.amount = 30
		steam.lifetime = 2.5
		steam.preprocess = 1.0
		steam.position = Vector3(0, 0.20, 0)
		var pm: ParticleProcessMaterial = ParticleProcessMaterial.new()
		pm.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
		pm.emission_box_extents = Vector3(0.40, 0.05, 0.40)
		pm.direction = Vector3(0, 1, 0)
		pm.spread = 22.0
		pm.gravity = Vector3.ZERO
		pm.initial_velocity_min = 0.55
		pm.initial_velocity_max = 1.20
		pm.scale_min = 0.30
		pm.scale_max = 0.55
		pm.color = Color(0.92, 0.92, 0.95, 0.55)
		steam.process_material = pm
		var sm_mesh: SphereMesh = SphereMesh.new()
		sm_mesh.radius = 0.30
		sm_mesh.height = 0.60
		steam.draw_pass_1 = sm_mesh
		var sm_mat: StandardMaterial3D = StandardMaterial3D.new()
		sm_mat.albedo_color = Color(0.92, 0.92, 0.95, 0.45)
		sm_mat.emission_enabled = true
		sm_mat.emission = Color(0.85, 0.85, 0.95)
		sm_mat.emission_energy_multiplier = 0.55
		sm_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		sm_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		sm_mesh.material = sm_mat
		vent.add_child(steam)


func _build_d6_pawn_shop(geom: Node) -> void:
	## Epic-6 T41: pawn shop facade — barred windows, "PAWN" sign, and a
	## display case of mismatched cyber gear in the front.
	var shop: Node3D = Node3D.new()
	shop.name = "PawnShop"
	shop.position = Vector3(D6_CENTER.x + 30.0, 0.0, 8.0)
	geom.add_child(shop)
	var brick_mat: StandardMaterial3D = StandardMaterial3D.new()
	brick_mat.albedo_color = Color(0.40, 0.20, 0.15)
	brick_mat.roughness = 0.85
	# Facade wall
	var wall: MeshInstance3D = MeshInstance3D.new()
	var wm: BoxMesh = BoxMesh.new()
	wm.size = Vector3(4.85, 3.40, 0.40)
	wall.mesh = wm
	wall.material_override = brick_mat
	wall.position = Vector3(0, 1.70, -1.20)
	shop.add_child(wall)
	# Side walls
	for sx in [-2.30, 2.30]:
		var side: MeshInstance3D = MeshInstance3D.new()
		var swm: BoxMesh = BoxMesh.new()
		swm.size = Vector3(0.40, 3.40, 2.85)
		side.mesh = swm
		side.material_override = brick_mat
		side.position = Vector3(sx, 1.70, 0)
		shop.add_child(side)
	# Roof
	var roof: MeshInstance3D = MeshInstance3D.new()
	var rm: BoxMesh = BoxMesh.new()
	rm.size = Vector3(4.85, 0.20, 3.10)
	roof.mesh = rm
	var roof_mat: StandardMaterial3D = StandardMaterial3D.new()
	roof_mat.albedo_color = Color(0.20, 0.10, 0.08)
	roof.material_override = roof_mat
	roof.position = Vector3(0, 3.50, 0)
	shop.add_child(roof)
	# Barred window (dark interior + 4 vertical bars)
	var window_dark: MeshInstance3D = MeshInstance3D.new()
	var wdm: BoxMesh = BoxMesh.new()
	wdm.size = Vector3(2.85, 1.40, 0.10)
	window_dark.mesh = wdm
	var dark_mat: StandardMaterial3D = StandardMaterial3D.new()
	dark_mat.albedo_color = Color(0.05, 0.05, 0.10)
	dark_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	window_dark.material_override = dark_mat
	window_dark.position = Vector3(0, 1.85, -0.95)
	shop.add_child(window_dark)
	var bar_mat: StandardMaterial3D = StandardMaterial3D.new()
	bar_mat.albedo_color = Color(0.30, 0.32, 0.38)
	bar_mat.metallic = 0.85
	bar_mat.roughness = 0.30
	for i in 4:
		var bar: MeshInstance3D = MeshInstance3D.new()
		var bbm: CylinderMesh = CylinderMesh.new()
		bbm.top_radius = 0.04
		bbm.bottom_radius = 0.04
		bbm.height = 1.40
		bar.mesh = bbm
		bar.material_override = bar_mat
		bar.position = Vector3(-1.10 + i * 0.73, 1.85, -0.85)
		shop.add_child(bar)
	# "PAWN" yellow sign
	var sign: MeshInstance3D = MeshInstance3D.new()
	var snm: BoxMesh = BoxMesh.new()
	snm.size = Vector3(2.85, 0.85, 0.10)
	sign.mesh = snm
	var sign_mat: StandardMaterial3D = StandardMaterial3D.new()
	sign_mat.albedo_color = Color(0.95, 0.85, 0.20)
	sign_mat.emission_enabled = true
	sign_mat.emission = Color(0.95, 0.85, 0.20)
	sign_mat.emission_energy_multiplier = 2.0
	sign_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	sign.material_override = sign_mat
	sign.position = Vector3(0, 3.10, -0.93)
	shop.add_child(sign)
	var label: Label3D = Label3D.new()
	label.text = "PAWN"
	label.modulate = Color(0.10, 0.05, 0.05)
	label.outline_modulate = Color(0.95, 0.85, 0.20)
	label.outline_size = 6
	label.font_size = 96
	label.pixel_size = 0.012
	label.position = Vector3(0, 3.10, -0.85)
	shop.add_child(label)
	# 3 small cyber gear items in the window (different colored cubes)
	var gear_colors: Array = [
		Color(0.95, 0.20, 0.30),
		Color(0.30, 0.95, 0.55),
		Color(0.30, 0.65, 0.95),
	]
	for i in 3:
		var gear: MeshInstance3D = MeshInstance3D.new()
		var gm: BoxMesh = BoxMesh.new()
		gm.size = Vector3(0.30, 0.30, 0.30)
		gear.mesh = gm
		var gear_mat: StandardMaterial3D = StandardMaterial3D.new()
		gear_mat.albedo_color = gear_colors[i]
		gear_mat.emission_enabled = true
		gear_mat.emission = gear_colors[i]
		gear_mat.emission_energy_multiplier = 1.4
		gear.material_override = gear_mat
		gear.position = Vector3(-0.85 + i * 0.85, 1.85, -1.0)
		shop.add_child(gear)
	# Light
	var light: OmniLight3D = OmniLight3D.new()
	light.light_color = Color(1.0, 0.85, 0.30)
	light.light_energy = 1.6
	light.omni_range = 4.5
	light.position = Vector3(0, 2.85, 1.20)
	shop.add_child(light)
	# Shop collision
	var sb: StaticBody3D = StaticBody3D.new()
	sb.position = Vector3(0, 1.70, 0)
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(4.85, 3.40, 2.85)
	cs.shape = cb
	sb.add_child(cs)
	shop.add_child(sb)


func _build_d6_pawn_broker_npc(town: Node) -> void:
	## Epic-6 T42: pawn broker NPC — small green visor + leather vest, with
	## a small abacus held in front.
	var npc_slots: Node3D = town.get_node_or_null("%NPCSlots") as Node3D
	if npc_slots == null:
		return
	var slot: Marker3D = Marker3D.new()
	slot.name = "PawnBrokerSlot"
	slot.position = Vector3(D6_CENTER.x + 30.0, 0.0, 9.0)
	npc_slots.add_child(slot)
	var npc_scene: PackedScene = load("res://scenes/entities/npcs/VillagerR3.tscn") as PackedScene
	if npc_scene == null:
		return
	var npc: Node3D = npc_scene.instantiate() as Node3D
	npc.name = "PawnBroker"
	if "npc_name" in npc:
		npc.set("npc_name", "Tally")
	if "npc_id" in npc:
		npc.set("npc_id", "pawn_d6")
	slot.add_child(npc)
	# Leather vest
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
	# Green accountant visor
	var visor: MeshInstance3D = MeshInstance3D.new()
	var vmm: CylinderMesh = CylinderMesh.new()
	vmm.top_radius = 0.22
	vmm.bottom_radius = 0.22
	vmm.height = 0.06
	visor.mesh = vmm
	var visor_mat: StandardMaterial3D = StandardMaterial3D.new()
	visor_mat.albedo_color = Color(0.30, 0.95, 0.30)
	visor_mat.emission_enabled = true
	visor_mat.emission = Color(0.30, 0.95, 0.30)
	visor_mat.emission_energy_multiplier = 0.85
	visor.material_override = visor_mat
	visor.position = Vector3(0, 1.50, 0)
	npc.add_child(visor)
	# Visor brim (shorter cylinder)
	var brim: MeshInstance3D = MeshInstance3D.new()
	var bmm: CylinderMesh = CylinderMesh.new()
	bmm.top_radius = 0.30
	bmm.bottom_radius = 0.30
	bmm.height = 0.04
	brim.mesh = bmm
	brim.material_override = visor_mat
	brim.position = Vector3(0, 1.45, 0.10)
	npc.add_child(brim)
	# Abacus (box with 9 colored beads)
	var abacus: MeshInstance3D = MeshInstance3D.new()
	var amm: BoxMesh = BoxMesh.new()
	amm.size = Vector3(0.40, 0.20, 0.06)
	abacus.mesh = amm
	var abacus_mat: StandardMaterial3D = StandardMaterial3D.new()
	abacus_mat.albedo_color = Color(0.45, 0.28, 0.12)
	abacus.material_override = abacus_mat
	abacus.position = Vector3(0.40, 0.85, 0.20)
	npc.add_child(abacus)
	for i in 9:
		var bead: MeshInstance3D = MeshInstance3D.new()
		var bm: SphereMesh = SphereMesh.new()
		bm.radius = 0.018
		bm.height = 0.036
		bead.mesh = bm
		var bead_mat: StandardMaterial3D = StandardMaterial3D.new()
		bead_mat.albedo_color = Color(1.0, 0.85, 0.30)
		bead_mat.emission_enabled = true
		bead_mat.emission = Color(1.0, 0.85, 0.30)
		bead_mat.emission_energy_multiplier = 1.4
		bead.material_override = bead_mat
		bead.position = Vector3(0.40 + (i % 3) * 0.04 - 0.04, 0.85 + (i / 3) * 0.04 - 0.04, 0.23)
		npc.add_child(bead)


func _build_d6_train_tracks(geom: Node) -> void:
	## Epic-6 T43: elevated bullet train tracks running across the bazaar
	## sky overhead — 2 tall support pillars + horizontal track slab + 2
	## glowing rails on top.
	var tracks: Node3D = Node3D.new()
	tracks.name = "ElevatedTrainTracks"
	tracks.position = Vector3(D6_CENTER.x, 0.0, -8.0)
	geom.add_child(tracks)
	var concrete_mat: StandardMaterial3D = StandardMaterial3D.new()
	concrete_mat.albedo_color = Color(0.40, 0.42, 0.45)
	concrete_mat.roughness = 0.92
	# Support pillars
	for sx in [-18.0, -6.0, 6.0, 18.0]:
		var pillar: MeshInstance3D = MeshInstance3D.new()
		var pm: BoxMesh = BoxMesh.new()
		pm.size = Vector3(1.10, 8.50, 1.10)
		pillar.mesh = pm
		pillar.material_override = concrete_mat
		pillar.position = Vector3(sx, 4.25, 0)
		tracks.add_child(pillar)
		# Pillar collision
		var sb: StaticBody3D = StaticBody3D.new()
		sb.position = Vector3(sx, 4.25, 0)
		var cs: CollisionShape3D = CollisionShape3D.new()
		var cb: BoxShape3D = BoxShape3D.new()
		cb.size = Vector3(1.10, 8.50, 1.10)
		cs.shape = cb
		sb.add_child(cs)
		tracks.add_child(sb)
	# Horizontal track deck slab
	var deck: MeshInstance3D = MeshInstance3D.new()
	var dm: BoxMesh = BoxMesh.new()
	dm.size = Vector3(46.0, 0.55, 3.40)
	deck.mesh = dm
	deck.material_override = concrete_mat
	deck.position = Vector3(0, 8.80, 0)
	tracks.add_child(deck)
	# 2 glowing magenta rails on top
	var rail_mat: StandardMaterial3D = StandardMaterial3D.new()
	rail_mat.albedo_color = Color(0.95, 0.20, 0.85)
	rail_mat.emission_enabled = true
	rail_mat.emission = Color(0.95, 0.20, 0.85)
	rail_mat.emission_energy_multiplier = 3.0
	rail_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for sz in [-1.0, 1.0]:
		var rail: MeshInstance3D = MeshInstance3D.new()
		var rm: BoxMesh = BoxMesh.new()
		rm.size = Vector3(46.0, 0.10, 0.18)
		rail.mesh = rm
		rail.material_override = rail_mat
		rail.position = Vector3(0, 9.15, sz)
		tracks.add_child(rail)


func _build_d6_trash_piles(geom: Node) -> void:
	## Epic-6 T44: 4 piles of trash bags + scattered debris in alley areas.
	var trash: Node3D = Node3D.new()
	trash.name = "TrashPiles"
	trash.position = Vector3(D6_CENTER.x + 26.0, 0.0, 0.0)
	geom.add_child(trash)
	var bag_mat: StandardMaterial3D = StandardMaterial3D.new()
	bag_mat.albedo_color = Color(0.10, 0.08, 0.10)
	bag_mat.roughness = 0.85
	for i in 4:
		var pile: Node3D = Node3D.new()
		pile.position = Vector3(
			randf_range(-3.5, 3.5),
			0,
			randf_range(-2.5, 2.5)
		)
		trash.add_child(pile)
		# 4 stacked bags per pile
		for j in 4:
			var bag: MeshInstance3D = MeshInstance3D.new()
			var bm: SphereMesh = SphereMesh.new()
			bm.radius = 0.30
			bm.height = 0.55
			bag.mesh = bm
			bag.material_override = bag_mat
			bag.position = Vector3(
				randf_range(-0.20, 0.20),
				0.20 + j * 0.30,
				randf_range(-0.20, 0.20)
			)
			pile.add_child(bag)
		# Pile collision
		var sb: StaticBody3D = StaticBody3D.new()
		sb.position = Vector3(0, 0.55, 0)
		var cs: CollisionShape3D = CollisionShape3D.new()
		var cb: BoxShape3D = BoxShape3D.new()
		cb.size = Vector3(0.85, 1.10, 0.85)
		cs.shape = cb
		sb.add_child(cs)
		pile.add_child(sb)


func _build_d6_ad_balloons(geom: Node) -> void:
	## Epic-6 T45: 4 floating ad balloons in the upper sky tethered by
	## thin cables to the ground. Each is a colored sphere with a brand label.
	var balloons: Node3D = Node3D.new()
	balloons.name = "AdBalloons"
	balloons.position = Vector3(D6_CENTER.x, 0.0, 0.0)
	geom.add_child(balloons)
	var cable_mat: StandardMaterial3D = StandardMaterial3D.new()
	cable_mat.albedo_color = Color(0.30, 0.32, 0.35)
	cable_mat.roughness = 0.85
	var balloon_data: Array = [
		{"x": -16.0, "y": 8.0, "color": Color(0.95, 0.20, 0.30), "text": "BUY"},
		{"x": -6.0,  "y": 9.5, "color": Color(0.30, 0.95, 0.55), "text": "EAT"},
		{"x": 6.0,   "y": 8.5, "color": Color(0.95, 0.85, 0.20), "text": "WIN"},
		{"x": 16.0,  "y": 9.0, "color": Color(0.30, 0.65, 0.95), "text": "DRINK"},
	]
	for bd in balloon_data:
		var balloon: Node3D = Node3D.new()
		balloon.position = Vector3(bd["x"], 0, randf_range(-12, 12))
		balloons.add_child(balloon)
		# Balloon sphere
		var ball: MeshInstance3D = MeshInstance3D.new()
		var bm: SphereMesh = SphereMesh.new()
		bm.radius = 1.10
		bm.height = 2.0
		ball.mesh = bm
		var ball_mat: StandardMaterial3D = StandardMaterial3D.new()
		ball_mat.albedo_color = bd["color"]
		ball_mat.emission_enabled = true
		ball_mat.emission = bd["color"]
		ball_mat.emission_energy_multiplier = 0.85
		ball_mat.metallic = 0.30
		ball_mat.roughness = 0.20
		ball.material_override = ball_mat
		ball.position = Vector3(0, bd["y"], 0)
		balloon.add_child(ball)
		# Tether cable (thin cylinder going to the ground)
		var cable: MeshInstance3D = MeshInstance3D.new()
		var cm: CylinderMesh = CylinderMesh.new()
		cm.top_radius = 0.025
		cm.bottom_radius = 0.025
		cm.height = bd["y"] - 1.10
		cable.mesh = cm
		cable.material_override = cable_mat
		cable.position = Vector3(0, (bd["y"] - 1.10) * 0.5, 0)
		balloon.add_child(cable)
		# Brand label
		var label: Label3D = Label3D.new()
		label.text = bd["text"]
		label.modulate = Color(0.95, 0.95, 1.0)
		label.outline_modulate = Color(0.05, 0.10, 0.20)
		label.outline_size = 8
		label.font_size = 84
		label.pixel_size = 0.014
		label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		label.position = Vector3(0, bd["y"], 0)
		balloon.add_child(label)
		# Slow bob
		var tw: Tween = ball.create_tween().set_loops()
		tw.tween_property(ball, "position:y", bd["y"] + 0.45, 2.0 + randf())
		tw.tween_property(ball, "position:y", bd["y"], 2.0 + randf())


func _build_d6_gambling_den(geom: Node) -> void:
	## Epic-6 T46: gambling den — round velvet card table + chairs +
	## floating cards and chips, with low warm OmniLight overhead.
	var den: Node3D = Node3D.new()
	den.name = "GamblingDen"
	den.position = Vector3(D6_CENTER.x + 14.0, 0.0, -16.0)
	geom.add_child(den)
	# Round velvet table top (cylinder)
	var velvet_mat: StandardMaterial3D = StandardMaterial3D.new()
	velvet_mat.albedo_color = Color(0.20, 0.55, 0.20)
	velvet_mat.emission_enabled = true
	velvet_mat.emission = Color(0.20, 0.55, 0.20)
	velvet_mat.emission_energy_multiplier = 0.30
	velvet_mat.roughness = 0.85
	var top: MeshInstance3D = MeshInstance3D.new()
	var tm: CylinderMesh = CylinderMesh.new()
	tm.top_radius = 1.85
	tm.bottom_radius = 1.85
	tm.height = 0.10
	top.mesh = tm
	top.material_override = velvet_mat
	top.position = Vector3(0, 0.85, 0)
	den.add_child(top)
	# Table column
	var wood_mat: StandardMaterial3D = StandardMaterial3D.new()
	wood_mat.albedo_color = Color(0.40, 0.25, 0.10)
	wood_mat.roughness = 0.85
	var col: MeshInstance3D = MeshInstance3D.new()
	var cm: CylinderMesh = CylinderMesh.new()
	cm.top_radius = 0.30
	cm.bottom_radius = 0.45
	cm.height = 0.85
	col.mesh = cm
	col.material_override = wood_mat
	col.position = Vector3(0, 0.42, 0)
	den.add_child(col)
	# 4 chairs around the table
	for i in 4:
		var ang: float = (TAU / 4.0) * i
		var chair: MeshInstance3D = MeshInstance3D.new()
		var chm: BoxMesh = BoxMesh.new()
		chm.size = Vector3(0.55, 0.85, 0.55)
		chair.mesh = chm
		chair.material_override = wood_mat
		chair.position = Vector3(cos(ang) * 2.40, 0.42, sin(ang) * 2.40)
		den.add_child(chair)
		# Chair backrest
		var back: MeshInstance3D = MeshInstance3D.new()
		var bm: BoxMesh = BoxMesh.new()
		bm.size = Vector3(0.55, 0.85, 0.10)
		back.mesh = bm
		back.material_override = wood_mat
		back.position = Vector3(cos(ang) * 2.65, 1.0, sin(ang) * 2.65)
		back.rotation.y = -ang + PI * 0.5
		den.add_child(back)
	# 4 stacks of chips on the table
	var chip_colors: Array = [
		Color(0.95, 0.20, 0.30),
		Color(0.30, 0.65, 0.95),
		Color(0.30, 0.95, 0.55),
		Color(0.95, 0.85, 0.20),
	]
	for i in 4:
		var ang: float = (TAU / 4.0) * i + PI / 4.0
		for j in 4:
			var chip: MeshInstance3D = MeshInstance3D.new()
			var cmm: CylinderMesh = CylinderMesh.new()
			cmm.top_radius = 0.10
			cmm.bottom_radius = 0.10
			cmm.height = 0.04
			chip.mesh = cmm
			var chip_mat: StandardMaterial3D = StandardMaterial3D.new()
			chip_mat.albedo_color = chip_colors[i]
			chip_mat.emission_enabled = true
			chip_mat.emission = chip_colors[i]
			chip_mat.emission_energy_multiplier = 0.65
			chip.material_override = chip_mat
			chip.position = Vector3(cos(ang) * 0.85, 0.95 + j * 0.05, sin(ang) * 0.85)
			den.add_child(chip)
	# 5 floating playing cards above the table
	var card_mat: StandardMaterial3D = StandardMaterial3D.new()
	card_mat.albedo_color = Color(0.95, 0.92, 0.85)
	card_mat.emission_enabled = true
	card_mat.emission = Color(0.95, 0.92, 0.85)
	card_mat.emission_energy_multiplier = 0.65
	for i in 5:
		var card: MeshInstance3D = MeshInstance3D.new()
		var cdm: BoxMesh = BoxMesh.new()
		cdm.size = Vector3(0.18, 0.30, 0.02)
		card.mesh = cdm
		card.material_override = card_mat
		var ang: float = (TAU / 5.0) * i
		card.position = Vector3(cos(ang) * 0.55, 1.85, sin(ang) * 0.55)
		card.rotation_degrees = Vector3(0, ang * 60.0, 0)
		den.add_child(card)
		# Slow rotation
		var tw: Tween = card.create_tween().set_loops()
		tw.tween_property(card, "rotation_degrees:y", 360.0, 4.0 + i * 0.4)
		tw.tween_property(card, "rotation_degrees:y", 0.0, 0.0)
	# Warm overhead light
	var light: OmniLight3D = OmniLight3D.new()
	light.light_color = Color(1.0, 0.85, 0.55)
	light.light_energy = 2.0
	light.omni_range = 5.5
	light.position = Vector3(0, 2.85, 0)
	den.add_child(light)
	# Table collision
	var sb: StaticBody3D = StaticBody3D.new()
	sb.position = Vector3(0, 0.55, 0)
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cap: CylinderShape3D = CylinderShape3D.new()
	cap.radius = 1.85
	cap.height = 0.95
	cs.shape = cap
	sb.add_child(cs)
	den.add_child(sb)


func _build_d6_card_dealer_npc(town: Node) -> void:
	## Epic-6 T47: card dealer NPC at the gambling den — vest + bow tie +
	## holding a fanned hand of cards.
	var npc_slots: Node3D = town.get_node_or_null("%NPCSlots") as Node3D
	if npc_slots == null:
		return
	var slot: Marker3D = Marker3D.new()
	slot.name = "CardDealerSlot"
	slot.position = Vector3(D6_CENTER.x + 14.0, 0.0, -13.5)
	npc_slots.add_child(slot)
	var npc_scene: PackedScene = load("res://scenes/entities/npcs/VillagerR3.tscn") as PackedScene
	if npc_scene == null:
		return
	var npc: Node3D = npc_scene.instantiate() as Node3D
	npc.name = "CardDealer"
	if "npc_name" in npc:
		npc.set("npc_name", "Hex")
	if "npc_id" in npc:
		npc.set("npc_id", "dealer_d6")
	slot.add_child(npc)
	# Black vest
	var vest: MeshInstance3D = MeshInstance3D.new()
	var vm: BoxMesh = BoxMesh.new()
	vm.size = Vector3(0.65, 0.85, 0.40)
	vest.mesh = vm
	var vest_mat: StandardMaterial3D = StandardMaterial3D.new()
	vest_mat.albedo_color = Color(0.10, 0.10, 0.15)
	vest_mat.metallic = 0.30
	vest_mat.roughness = 0.45
	vest.material_override = vest_mat
	vest.position = Vector3(0, 0.65, 0)
	npc.add_child(vest)
	# Red bow tie
	var bow: MeshInstance3D = MeshInstance3D.new()
	var bm: BoxMesh = BoxMesh.new()
	bm.size = Vector3(0.18, 0.06, 0.06)
	bow.mesh = bm
	var bow_mat: StandardMaterial3D = StandardMaterial3D.new()
	bow_mat.albedo_color = Color(0.95, 0.20, 0.30)
	bow_mat.emission_enabled = true
	bow_mat.emission = Color(0.95, 0.20, 0.30)
	bow_mat.emission_energy_multiplier = 0.45
	bow.material_override = bow_mat
	bow.position = Vector3(0, 1.10, 0.20)
	npc.add_child(bow)
	# Fanned cards in hand (3 cards splayed)
	for i in 3:
		var card: MeshInstance3D = MeshInstance3D.new()
		var cmm: BoxMesh = BoxMesh.new()
		cmm.size = Vector3(0.14, 0.22, 0.02)
		card.mesh = cmm
		var card_mat: StandardMaterial3D = StandardMaterial3D.new()
		card_mat.albedo_color = Color(0.95, 0.92, 0.85)
		card.material_override = card_mat
		card.position = Vector3(0.40, 0.85, 0.20)
		card.rotation_degrees = Vector3(-30, 0, -15.0 + i * 15.0)
		npc.add_child(card)


func _build_d6_smuggler_crates(geom: Node) -> void:
	## Epic-6 T48: stack of 6 smuggler data crates with biohazard markings.
	var crates: Node3D = Node3D.new()
	crates.name = "SmugglerCrates"
	crates.position = Vector3(D6_CENTER.x + 18.0, 0.0, -16.0)
	geom.add_child(crates)
	var crate_mat: StandardMaterial3D = StandardMaterial3D.new()
	crate_mat.albedo_color = Color(0.20, 0.18, 0.25)
	crate_mat.metallic = 0.55
	crate_mat.roughness = 0.45
	var biohazard_mat: StandardMaterial3D = StandardMaterial3D.new()
	biohazard_mat.albedo_color = Color(0.95, 0.85, 0.20)
	biohazard_mat.emission_enabled = true
	biohazard_mat.emission = Color(0.95, 0.85, 0.20)
	biohazard_mat.emission_energy_multiplier = 1.4
	biohazard_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	# 6 crates: 4 base + 2 top
	var positions: Array = [
		Vector3(-0.55, 0.45, -0.55),
		Vector3( 0.55, 0.45, -0.55),
		Vector3(-0.55, 0.45,  0.55),
		Vector3( 0.55, 0.45,  0.55),
		Vector3( 0.0,  1.35, -0.30),
		Vector3( 0.0,  1.35,  0.30),
	]
	for p in positions:
		var crate: MeshInstance3D = MeshInstance3D.new()
		var cm: BoxMesh = BoxMesh.new()
		cm.size = Vector3(0.95, 0.85, 0.95)
		crate.mesh = cm
		crate.material_override = crate_mat
		crate.position = p
		crates.add_child(crate)
		# Biohazard sticker (small yellow circle on the crate front)
		var sticker: MeshInstance3D = MeshInstance3D.new()
		var sm: CylinderMesh = CylinderMesh.new()
		sm.top_radius = 0.20
		sm.bottom_radius = 0.20
		sm.height = 0.04
		sticker.mesh = sm
		sticker.material_override = biohazard_mat
		sticker.position = Vector3(p.x, p.y, p.z + 0.50)
		sticker.rotation_degrees = Vector3(90, 0, 0)
		crates.add_child(sticker)
	# Group collision (simpler one box around all)
	var sb: StaticBody3D = StaticBody3D.new()
	sb.position = Vector3(0, 0.85, 0)
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(2.20, 1.85, 2.20)
	cs.shape = cb
	sb.add_child(cs)
	crates.add_child(sb)


func _build_d6_smuggler_boss_npc(town: Node) -> void:
	## Epic-6 T49: smuggler boss NPC standing by the crates — fur-trimmed
	## coat, big rings, scar over one eye.
	var npc_slots: Node3D = town.get_node_or_null("%NPCSlots") as Node3D
	if npc_slots == null:
		return
	var slot: Marker3D = Marker3D.new()
	slot.name = "SmugglerBossSlot"
	slot.position = Vector3(D6_CENTER.x + 16.0, 0.0, -16.0)
	npc_slots.add_child(slot)
	var npc_scene: PackedScene = load("res://scenes/entities/npcs/VillagerR3.tscn") as PackedScene
	if npc_scene == null:
		return
	var npc: Node3D = npc_scene.instantiate() as Node3D
	npc.name = "SmugglerBoss"
	if "npc_name" in npc:
		npc.set("npc_name", "Crow")
	if "npc_id" in npc:
		npc.set("npc_id", "smuggler_boss_d6")
	npc.scale = Vector3(1.10, 1.10, 1.10)
	slot.add_child(npc)
	# Long fur-trimmed coat
	var coat: MeshInstance3D = MeshInstance3D.new()
	var cm: BoxMesh = BoxMesh.new()
	cm.size = Vector3(0.85, 1.30, 0.55)
	coat.mesh = cm
	var coat_mat: StandardMaterial3D = StandardMaterial3D.new()
	coat_mat.albedo_color = Color(0.10, 0.05, 0.10)
	coat_mat.metallic = 0.30
	coat_mat.roughness = 0.55
	coat.material_override = coat_mat
	coat.position = Vector3(0, 0.65, 0)
	npc.add_child(coat)
	# Fur collar (white sphere around shoulders)
	var fur: MeshInstance3D = MeshInstance3D.new()
	var fm: CylinderMesh = CylinderMesh.new()
	fm.top_radius = 0.40
	fm.bottom_radius = 0.40
	fm.height = 0.18
	fur.mesh = fm
	var fur_mat: StandardMaterial3D = StandardMaterial3D.new()
	fur_mat.albedo_color = Color(0.92, 0.92, 0.85)
	fur_mat.roughness = 0.95
	fur.material_override = fur_mat
	fur.position = Vector3(0, 1.20, 0)
	npc.add_child(fur)
	# Red scar over the eye (small red box)
	var scar: MeshInstance3D = MeshInstance3D.new()
	var sm: BoxMesh = BoxMesh.new()
	sm.size = Vector3(0.04, 0.18, 0.02)
	scar.mesh = sm
	var scar_mat: StandardMaterial3D = StandardMaterial3D.new()
	scar_mat.albedo_color = Color(0.85, 0.20, 0.20)
	scar_mat.emission_enabled = true
	scar_mat.emission = Color(0.85, 0.20, 0.20)
	scar_mat.emission_energy_multiplier = 0.85
	scar.material_override = scar_mat
	scar.position = Vector3(-0.10, 1.40, 0.21)
	scar.rotation_degrees = Vector3(0, 0, 15)
	npc.add_child(scar)
	# Big gold rings on hand (small torus)
	var ring: MeshInstance3D = MeshInstance3D.new()
	var rmm: TorusMesh = TorusMesh.new()
	rmm.inner_radius = 0.05
	rmm.outer_radius = 0.08
	ring.mesh = rmm
	var gold_mat: StandardMaterial3D = StandardMaterial3D.new()
	gold_mat.albedo_color = Color(1.0, 0.85, 0.30)
	gold_mat.emission_enabled = true
	gold_mat.emission = Color(1.0, 0.75, 0.20)
	gold_mat.emission_energy_multiplier = 0.85
	gold_mat.metallic = 0.95
	gold_mat.roughness = 0.10
	ring.material_override = gold_mat
	ring.position = Vector3(0.40, 0.85, 0.20)
	npc.add_child(ring)


func _build_d6_neon_sovereign(geom: Node) -> void:
	## Epic-6 T50: NEON SOVEREIGN — D6 mid-boss landmark. Towering cyber
	## gangster figure with magenta-cyan lit body, mirror-shade visor,
	## glowing katana, and floating neon glyphs.
	var sov: Node3D = Node3D.new()
	sov.name = "NeonSovereign"
	sov.position = Vector3(D6_CENTER.x + 4.0, 0.0, -22.0)
	geom.add_child(sov)
	var black_mat: StandardMaterial3D = StandardMaterial3D.new()
	black_mat.albedo_color = Color(0.10, 0.05, 0.15)
	black_mat.metallic = 0.85
	black_mat.roughness = 0.30
	var magenta_mat: StandardMaterial3D = StandardMaterial3D.new()
	magenta_mat.albedo_color = Color(0.95, 0.20, 0.85)
	magenta_mat.emission_enabled = true
	magenta_mat.emission = Color(0.95, 0.20, 0.85)
	magenta_mat.emission_energy_multiplier = 4.0
	magenta_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var cyan_mat: StandardMaterial3D = StandardMaterial3D.new()
	cyan_mat.albedo_color = Color(0.30, 0.95, 1.0)
	cyan_mat.emission_enabled = true
	cyan_mat.emission = Color(0.30, 1.0, 1.0)
	cyan_mat.emission_energy_multiplier = 4.0
	cyan_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	# Stone pedestal
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.30, 0.18, 0.30)
	stone_mat.metallic = 0.65
	stone_mat.roughness = 0.45
	var ped: MeshInstance3D = MeshInstance3D.new()
	var pm: BoxMesh = BoxMesh.new()
	pm.size = Vector3(3.20, 0.55, 3.20)
	ped.mesh = pm
	ped.material_override = stone_mat
	ped.position = Vector3(0, 0.27, 0)
	sov.add_child(ped)
	# Body torso (large box)
	var torso: MeshInstance3D = MeshInstance3D.new()
	var tm: BoxMesh = BoxMesh.new()
	tm.size = Vector3(1.85, 2.85, 1.10)
	torso.mesh = tm
	torso.material_override = black_mat
	torso.position = Vector3(0, 2.20, 0)
	sov.add_child(torso)
	# Magenta neon strip down the torso center
	var center_strip: MeshInstance3D = MeshInstance3D.new()
	var csm: BoxMesh = BoxMesh.new()
	csm.size = Vector3(0.12, 2.85, 0.06)
	center_strip.mesh = csm
	center_strip.material_override = magenta_mat
	center_strip.position = Vector3(0, 2.20, 0.55)
	sov.add_child(center_strip)
	# Cyan strips on the sides
	for sx in [-0.85, 0.85]:
		var strip: MeshInstance3D = MeshInstance3D.new()
		var sm: BoxMesh = BoxMesh.new()
		sm.size = Vector3(0.06, 2.85, 0.10)
		strip.mesh = sm
		strip.material_override = cyan_mat
		strip.position = Vector3(sx, 2.20, 0.55)
		sov.add_child(strip)
	# Head — armored helmet with mirror visor
	var helmet: MeshInstance3D = MeshInstance3D.new()
	var hm: BoxMesh = BoxMesh.new()
	hm.size = Vector3(1.10, 0.95, 0.95)
	helmet.mesh = hm
	helmet.material_override = black_mat
	helmet.position = Vector3(0, 4.10, 0)
	sov.add_child(helmet)
	# Mirror visor strip (large cyan band across the face)
	var visor: MeshInstance3D = MeshInstance3D.new()
	var vm: BoxMesh = BoxMesh.new()
	vm.size = Vector3(1.10, 0.18, 0.06)
	visor.mesh = vm
	visor.material_override = cyan_mat
	visor.position = Vector3(0, 4.20, 0.50)
	sov.add_child(visor)
	# 2 antenna spikes on the helmet
	for sx in [-0.30, 0.30]:
		var ant: MeshInstance3D = MeshInstance3D.new()
		var am: PrismMesh = PrismMesh.new()
		am.size = Vector3(0.10, 0.55, 0.10)
		ant.mesh = am
		ant.material_override = magenta_mat
		ant.position = Vector3(sx, 4.85, 0)
		sov.add_child(ant)
	# Shoulder pauldrons
	for sx in [-1.30, 1.30]:
		var paul: MeshInstance3D = MeshInstance3D.new()
		var prm: SphereMesh = SphereMesh.new()
		prm.radius = 0.55
		prm.height = 0.85
		paul.mesh = prm
		paul.material_override = black_mat
		paul.position = Vector3(sx, 3.20, 0)
		paul.scale = Vector3(0.85, 0.65, 0.85)
		sov.add_child(paul)
	# Right arm (long box) holding the katana
	var right_arm: MeshInstance3D = MeshInstance3D.new()
	var ram: BoxMesh = BoxMesh.new()
	ram.size = Vector3(0.55, 1.85, 0.55)
	right_arm.mesh = ram
	right_arm.material_override = black_mat
	right_arm.position = Vector3(1.40, 2.20, 0)
	sov.add_child(right_arm)
	# Left arm
	var left_arm: MeshInstance3D = MeshInstance3D.new()
	var lam: BoxMesh = BoxMesh.new()
	lam.size = Vector3(0.55, 1.85, 0.55)
	left_arm.mesh = lam
	left_arm.material_override = black_mat
	left_arm.position = Vector3(-1.40, 2.20, 0)
	sov.add_child(left_arm)
	# Legs
	for sx in [-0.55, 0.55]:
		var leg: MeshInstance3D = MeshInstance3D.new()
		var lm: BoxMesh = BoxMesh.new()
		lm.size = Vector3(0.65, 1.0, 0.65)
		leg.mesh = lm
		leg.material_override = black_mat
		leg.position = Vector3(sx, 1.10, 0)
		sov.add_child(leg)
	# Glowing magenta katana (held outward, blade angled)
	var sword_root: Node3D = Node3D.new()
	sword_root.position = Vector3(2.0, 3.20, 0)
	sword_root.rotation_degrees = Vector3(0, 0, -25)
	sov.add_child(sword_root)
	var blade: MeshInstance3D = MeshInstance3D.new()
	var blm: PrismMesh = PrismMesh.new()
	blm.size = Vector3(0.18, 2.85, 0.06)
	blade.mesh = blm
	blade.material_override = magenta_mat
	blade.position = Vector3(0, 1.40, 0)
	sword_root.add_child(blade)
	# Crossguard
	var guard: MeshInstance3D = MeshInstance3D.new()
	var gm: BoxMesh = BoxMesh.new()
	gm.size = Vector3(0.55, 0.10, 0.10)
	guard.mesh = gm
	guard.material_override = black_mat
	guard.position = Vector3(0, 0, 0)
	sword_root.add_child(guard)
	# Handle
	var handle: MeshInstance3D = MeshInstance3D.new()
	var hndm: CylinderMesh = CylinderMesh.new()
	hndm.top_radius = 0.06
	hndm.bottom_radius = 0.06
	hndm.height = 0.40
	handle.mesh = hndm
	handle.material_override = black_mat
	handle.position = Vector3(0, -0.30, 0)
	sword_root.add_child(handle)
	# 8 floating neon glyphs orbiting at chest level
	var halo: Node3D = Node3D.new()
	halo.position = Vector3(0, 2.85, 0)
	sov.add_child(halo)
	for i in 8:
		var ang: float = (TAU / 8.0) * i
		var glyph: MeshInstance3D = MeshInstance3D.new()
		var gmm: BoxMesh = BoxMesh.new()
		gmm.size = Vector3(0.18, 0.30, 0.04)
		glyph.mesh = gmm
		glyph.material_override = cyan_mat if i % 2 == 0 else magenta_mat
		glyph.position = Vector3(cos(ang) * 2.40, 0, sin(ang) * 2.40)
		glyph.rotation = Vector3(0, ang + PI * 0.5, 0)
		halo.add_child(glyph)
	var trot: Tween = halo.create_tween().set_loops()
	trot.tween_property(halo, "rotation_degrees:y", 360.0, 12.0)
	trot.tween_property(halo, "rotation_degrees:y", 0.0, 0.0)
	# Massive light
	var light: OmniLight3D = OmniLight3D.new()
	light.light_color = Color(1.0, 0.30, 0.85)
	light.light_energy = 5.5
	light.omni_range = 18.0
	light.position = Vector3(0, 3.40, 0)
	sov.add_child(light)
	var twl: Tween = light.create_tween().set_loops()
	twl.tween_property(light, "light_energy", 7.0, 1.4)
	twl.tween_property(light, "light_energy", 5.0, 1.4)
	# Title labels
	var title: Label3D = Label3D.new()
	title.text = "THE NEON SOVEREIGN"
	title.modulate = Color(0.95, 0.30, 0.85)
	title.outline_modulate = Color(0.10, 0.05, 0.20)
	title.outline_size = 12
	title.font_size = 80
	title.pixel_size = 0.013
	title.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	title.position = Vector3(0, 6.85, 0)
	sov.add_child(title)
	var subtitle: Label3D = Label3D.new()
	subtitle.text = "Lord of the all-night market"
	subtitle.modulate = Color(0.85, 0.95, 1.0)
	subtitle.outline_modulate = Color(0.20, 0.10, 0.30)
	subtitle.outline_size = 8
	subtitle.font_size = 42
	subtitle.pixel_size = 0.011
	subtitle.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	subtitle.position = Vector3(0, 6.20, 0)
	sov.add_child(subtitle)
	# Body collision
	var sb: StaticBody3D = StaticBody3D.new()
	sb.position = Vector3(0, 2.20, 0)
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(2.85, 4.40, 1.40)
	cs.shape = cb
	sb.add_child(cs)
	sov.add_child(sb)
	# Pedestal collision
	var psb: StaticBody3D = StaticBody3D.new()
	psb.position = Vector3(0, 0.27, 0)
	var pcs: CollisionShape3D = CollisionShape3D.new()
	var pcb: BoxShape3D = BoxShape3D.new()
	pcb.size = Vector3(3.20, 0.55, 3.20)
	pcs.shape = pcb
	psb.add_child(pcs)
	sov.add_child(psb)


func _build_d6_subway_entrance(geom: Node) -> void:
	## Epic-6 T51: subway entrance — recessed staircase descending into a
	## dark hole with a metal railing and "SUBWAY" sign overhead.
	var sub: Node3D = Node3D.new()
	sub.name = "SubwayEntrance"
	sub.position = Vector3(D6_CENTER.x + 6.0, 0.0, 18.0)
	geom.add_child(sub)
	var concrete_mat: StandardMaterial3D = StandardMaterial3D.new()
	concrete_mat.albedo_color = Color(0.40, 0.42, 0.45)
	concrete_mat.roughness = 0.92
	# Recessed pit (dark interior)
	var pit: MeshInstance3D = MeshInstance3D.new()
	var pm: BoxMesh = BoxMesh.new()
	pm.size = Vector3(2.85, 0.20, 2.20)
	pit.mesh = pm
	var pit_mat: StandardMaterial3D = StandardMaterial3D.new()
	pit_mat.albedo_color = Color(0.05, 0.04, 0.10)
	pit_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	pit.material_override = pit_mat
	pit.position = Vector3(0, -0.10, 0)
	sub.add_child(pit)
	# 4 stair steps descending
	for i in 4:
		var step: MeshInstance3D = MeshInstance3D.new()
		var sm: BoxMesh = BoxMesh.new()
		sm.size = Vector3(2.85, 0.18, 0.40)
		step.mesh = sm
		step.material_override = concrete_mat
		step.position = Vector3(0, 0.10 - i * 0.20, 0.85 - i * 0.40)
		sub.add_child(step)
	# 2 metal railings flanking the entrance
	var rail_mat: StandardMaterial3D = StandardMaterial3D.new()
	rail_mat.albedo_color = Color(0.30, 0.32, 0.40)
	rail_mat.metallic = 0.85
	rail_mat.roughness = 0.30
	for sx in [-1.40, 1.40]:
		var rail: MeshInstance3D = MeshInstance3D.new()
		var rm: CylinderMesh = CylinderMesh.new()
		rm.top_radius = 0.04
		rm.bottom_radius = 0.05
		rm.height = 1.85
		rail.mesh = rm
		rail.material_override = rail_mat
		rail.position = Vector3(sx, 0.92, 0.85)
		sub.add_child(rail)
		# Rail collision
		var sb: StaticBody3D = StaticBody3D.new()
		sb.position = Vector3(sx, 0.92, 0.85)
		var cs: CollisionShape3D = CollisionShape3D.new()
		var cap: CapsuleShape3D = CapsuleShape3D.new()
		cap.radius = 0.10
		cap.height = 1.85
		cs.shape = cap
		sb.add_child(cs)
		sub.add_child(sb)
	# Subway sign overhead
	var sign: MeshInstance3D = MeshInstance3D.new()
	var snm: BoxMesh = BoxMesh.new()
	snm.size = Vector3(2.85, 0.55, 0.10)
	sign.mesh = snm
	var sign_mat: StandardMaterial3D = StandardMaterial3D.new()
	sign_mat.albedo_color = Color(0.30, 0.65, 0.95)
	sign_mat.emission_enabled = true
	sign_mat.emission = Color(0.30, 0.95, 1.0)
	sign_mat.emission_energy_multiplier = 2.5
	sign_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	sign.material_override = sign_mat
	sign.position = Vector3(0, 2.85, 1.20)
	sub.add_child(sign)
	var label: Label3D = Label3D.new()
	label.text = "SUBWAY"
	label.modulate = Color(0.10, 0.05, 0.10)
	label.outline_modulate = Color(0.95, 0.95, 1.0)
	label.outline_size = 6
	label.font_size = 80
	label.pixel_size = 0.011
	label.position = Vector3(0, 2.85, 1.26)
	sub.add_child(label)
	# Light from sign
	var light: OmniLight3D = OmniLight3D.new()
	light.light_color = Color(0.40, 0.95, 1.0)
	light.light_energy = 1.6
	light.omni_range = 4.5
	light.position = Vector3(0, 2.85, 1.85)
	sub.add_child(light)


func _build_d6_subway_map(geom: Node) -> void:
	## Epic-6 T52: subway map kiosk — vertical illuminated box panel with
	## a colorful map of dots and lines.
	var map: Node3D = Node3D.new()
	map.name = "SubwayMapKiosk"
	map.position = Vector3(D6_CENTER.x + 9.0, 0.0, 18.0)
	geom.add_child(map)
	var metal_mat: StandardMaterial3D = StandardMaterial3D.new()
	metal_mat.albedo_color = Color(0.30, 0.32, 0.40)
	metal_mat.metallic = 0.85
	metal_mat.roughness = 0.30
	# Frame
	var frame: MeshInstance3D = MeshInstance3D.new()
	var fm: BoxMesh = BoxMesh.new()
	fm.size = Vector3(1.40, 2.40, 0.18)
	frame.mesh = fm
	frame.material_override = metal_mat
	frame.position = Vector3(0, 1.20, 0)
	map.add_child(frame)
	# Map screen (cyan glow)
	var screen: MeshInstance3D = MeshInstance3D.new()
	var sm: BoxMesh = BoxMesh.new()
	sm.size = Vector3(1.20, 2.0, 0.06)
	screen.mesh = sm
	var screen_mat: StandardMaterial3D = StandardMaterial3D.new()
	screen_mat.albedo_color = Color(0.10, 0.20, 0.30)
	screen_mat.emission_enabled = true
	screen_mat.emission = Color(0.20, 0.55, 0.85)
	screen_mat.emission_energy_multiplier = 1.4
	screen_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	screen.material_override = screen_mat
	screen.position = Vector3(0, 1.30, 0.10)
	map.add_child(screen)
	# 6 colored station dots
	var dot_colors: Array = [
		Color(0.95, 0.20, 0.30),
		Color(0.95, 0.65, 0.20),
		Color(0.95, 0.85, 0.20),
		Color(0.30, 0.95, 0.55),
		Color(0.30, 0.65, 0.95),
		Color(0.55, 0.30, 0.95),
	]
	var dot_positions: Array = [
		Vector3(-0.40,  0.70, 0.13),
		Vector3(-0.20,  1.20, 0.13),
		Vector3( 0.10,  1.55, 0.13),
		Vector3( 0.30,  1.0, 0.13),
		Vector3( 0.40,  1.85, 0.13),
		Vector3(-0.30,  1.85, 0.13),
	]
	for i in 6:
		var dot: MeshInstance3D = MeshInstance3D.new()
		var dm: SphereMesh = SphereMesh.new()
		dm.radius = 0.08
		dm.height = 0.16
		dot.mesh = dm
		var dot_mat: StandardMaterial3D = StandardMaterial3D.new()
		dot_mat.albedo_color = dot_colors[i]
		dot_mat.emission_enabled = true
		dot_mat.emission = dot_colors[i]
		dot_mat.emission_energy_multiplier = 3.0
		dot_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		dot.material_override = dot_mat
		dot.position = dot_positions[i]
		map.add_child(dot)
	# 4 connecting lines (thin emissive boxes between dots)
	var line_mat: StandardMaterial3D = StandardMaterial3D.new()
	line_mat.albedo_color = Color(0.85, 0.95, 1.0)
	line_mat.emission_enabled = true
	line_mat.emission = Color(0.85, 0.95, 1.0)
	line_mat.emission_energy_multiplier = 1.4
	line_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for line_data in [
		{"size": Vector3(0.40, 0.04, 0.03), "pos": Vector3(-0.20, 0.95, 0.14), "rot": -45.0},
		{"size": Vector3(0.40, 0.04, 0.03), "pos": Vector3(-0.05, 1.40, 0.14), "rot": -45.0},
		{"size": Vector3(0.40, 0.04, 0.03), "pos": Vector3(0.20, 1.30, 0.14), "rot": 30.0},
		{"size": Vector3(0.85, 0.04, 0.03), "pos": Vector3(0.05, 1.85, 0.14), "rot": 0.0},
	]:
		var line: MeshInstance3D = MeshInstance3D.new()
		var lm: BoxMesh = BoxMesh.new()
		lm.size = line_data["size"]
		line.mesh = lm
		line.material_override = line_mat
		line.position = line_data["pos"]
		line.rotation_degrees = Vector3(0, 0, line_data["rot"])
		map.add_child(line)
	# Map title label
	var label: Label3D = Label3D.new()
	label.text = "TRANSIT MAP"
	label.modulate = Color(0.95, 0.95, 1.0)
	label.outline_modulate = Color(0.05, 0.20, 0.40)
	label.outline_size = 4
	label.font_size = 32
	label.pixel_size = 0.005
	label.position = Vector3(0, 2.20, 0.16)
	map.add_child(label)
	# Frame collision
	var sb: StaticBody3D = StaticBody3D.new()
	sb.position = Vector3(0, 1.20, 0)
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(1.40, 2.40, 0.18)
	cs.shape = cb
	sb.add_child(cs)
	map.add_child(sb)


func _build_d6_street_preacher_npc(town: Node) -> void:
	## Epic-6 T53: street preacher NPC with a small megaphone, raised hand,
	## standing on a small wooden crate.
	var npc_slots: Node3D = town.get_node_or_null("%NPCSlots") as Node3D
	if npc_slots == null:
		return
	var slot: Marker3D = Marker3D.new()
	slot.name = "StreetPreacherSlot"
	slot.position = Vector3(D6_CENTER.x + 8.0, 0.0, 0.0)
	npc_slots.add_child(slot)
	var npc_scene: PackedScene = load("res://scenes/entities/npcs/VillagerR3.tscn") as PackedScene
	if npc_scene == null:
		return
	var npc: Node3D = npc_scene.instantiate() as Node3D
	npc.name = "StreetPreacher"
	if "npc_name" in npc:
		npc.set("npc_name", "Echo")
	if "npc_id" in npc:
		npc.set("npc_id", "preacher_d6")
	slot.add_child(npc)
	# Wooden crate stand under feet
	var crate: MeshInstance3D = MeshInstance3D.new()
	var crm: BoxMesh = BoxMesh.new()
	crm.size = Vector3(0.85, 0.30, 0.85)
	crate.mesh = crm
	var crate_mat: StandardMaterial3D = StandardMaterial3D.new()
	crate_mat.albedo_color = Color(0.45, 0.28, 0.12)
	crate.material_override = crate_mat
	crate.position = Vector3(0, 0.15, 0)
	npc.add_child(crate)
	# Brown trench coat (offset upward by crate height)
	var coat: MeshInstance3D = MeshInstance3D.new()
	var cm: BoxMesh = BoxMesh.new()
	cm.size = Vector3(0.65, 1.20, 0.45)
	coat.mesh = cm
	var coat_mat: StandardMaterial3D = StandardMaterial3D.new()
	coat_mat.albedo_color = Color(0.40, 0.25, 0.10)
	coat_mat.metallic = 0.20
	coat_mat.roughness = 0.65
	coat.material_override = coat_mat
	coat.position = Vector3(0, 0.90, 0)
	npc.add_child(coat)
	# Megaphone (small cone-shaped prism)
	var mega: MeshInstance3D = MeshInstance3D.new()
	var mm: PrismMesh = PrismMesh.new()
	mm.size = Vector3(0.20, 0.30, 0.30)
	mega.mesh = mm
	var mega_mat: StandardMaterial3D = StandardMaterial3D.new()
	mega_mat.albedo_color = Color(0.95, 0.30, 0.30)
	mega_mat.emission_enabled = true
	mega_mat.emission = Color(0.95, 0.30, 0.30)
	mega_mat.emission_energy_multiplier = 0.85
	mega.material_override = mega_mat
	mega.position = Vector3(0.40, 1.20, 0.30)
	mega.rotation_degrees = Vector3(0, 0, -90)
	npc.add_child(mega)


func _build_d6_pigeons(geom: Node) -> void:
	## Epic-6 T54: 4 pigeons flying in lazy circles overhead — small grey
	## bird bodies + 2 wings + slow rotation pivot.
	var flock: Node3D = Node3D.new()
	flock.name = "Pigeons"
	flock.position = Vector3(D6_CENTER.x, 5.5, 0.0)
	geom.add_child(flock)
	var grey_mat: StandardMaterial3D = StandardMaterial3D.new()
	grey_mat.albedo_color = Color(0.55, 0.55, 0.60)
	grey_mat.roughness = 0.65
	for i in 4:
		var pivot: Node3D = Node3D.new()
		pivot.position = Vector3(0, i * 0.40, 0)
		pivot.rotation_degrees = Vector3(0, i * 90.0, 0)
		flock.add_child(pivot)
		var bird: Node3D = Node3D.new()
		bird.position = Vector3(8.0 + i * 0.55, 0, 0)
		pivot.add_child(bird)
		# Body
		var body: MeshInstance3D = MeshInstance3D.new()
		var bm: SphereMesh = SphereMesh.new()
		bm.radius = 0.16
		bm.height = 0.28
		body.mesh = bm
		body.material_override = grey_mat
		body.scale = Vector3(0.85, 0.85, 1.40)
		bird.add_child(body)
		# Head
		var head: MeshInstance3D = MeshInstance3D.new()
		var hm: SphereMesh = SphereMesh.new()
		hm.radius = 0.10
		hm.height = 0.18
		head.mesh = hm
		head.material_override = grey_mat
		head.position = Vector3(0, 0.06, 0.18)
		bird.add_child(head)
		# 2 wings
		for sx in [-0.15, 0.15]:
			var wing: MeshInstance3D = MeshInstance3D.new()
			var wm: BoxMesh = BoxMesh.new()
			wm.size = Vector3(0.18, 0.04, 0.20)
			wing.mesh = wm
			wing.material_override = grey_mat
			wing.position = Vector3(sx, 0.04, 0)
			bird.add_child(wing)
			# Wing flap tween
			var twf: Tween = wing.create_tween().set_loops()
			twf.tween_property(wing, "rotation_degrees:z", 30.0 if sx < 0 else -30.0, 0.18)
			twf.tween_property(wing, "rotation_degrees:z", 0.0, 0.18)
		# Pivot rotation tween
		var trot: Tween = pivot.create_tween().set_loops()
		trot.tween_property(pivot, "rotation_degrees:y", i * 90.0 + 360.0, 8.0 + i * 0.6)
		trot.tween_property(pivot, "rotation_degrees:y", i * 90.0, 0.0)


func _build_d6_ramen_customer_npc(town: Node) -> void:
	## Epic-6 T55: ramen customer NPC seated at a small bowl bench eating ramen.
	var npc_slots: Node3D = town.get_node_or_null("%NPCSlots") as Node3D
	if npc_slots == null:
		return
	var slot: Marker3D = Marker3D.new()
	slot.name = "RamenCustomerSlot"
	slot.position = Vector3(D6_CENTER.x + 14.0, 0.0, 12.0)
	npc_slots.add_child(slot)
	var npc_scene: PackedScene = load("res://scenes/entities/npcs/VillagerR3.tscn") as PackedScene
	if npc_scene == null:
		return
	var npc: Node3D = npc_scene.instantiate() as Node3D
	npc.name = "RamenCustomer"
	if "npc_name" in npc:
		npc.set("npc_name", "Slurpy")
	if "npc_id" in npc:
		npc.set("npc_id", "ramen_customer_d6")
	slot.add_child(npc)
	# Salaryman business suit
	var suit: MeshInstance3D = MeshInstance3D.new()
	var sm: BoxMesh = BoxMesh.new()
	sm.size = Vector3(0.65, 1.05, 0.40)
	suit.mesh = sm
	var suit_mat: StandardMaterial3D = StandardMaterial3D.new()
	suit_mat.albedo_color = Color(0.20, 0.22, 0.30)
	suit_mat.metallic = 0.20
	suit_mat.roughness = 0.55
	suit.material_override = suit_mat
	suit.position = Vector3(0, 0.55, 0)
	npc.add_child(suit)
	# Red tie
	var tie: MeshInstance3D = MeshInstance3D.new()
	var tm: BoxMesh = BoxMesh.new()
	tm.size = Vector3(0.08, 0.55, 0.04)
	tie.mesh = tm
	var tie_mat: StandardMaterial3D = StandardMaterial3D.new()
	tie_mat.albedo_color = Color(0.85, 0.20, 0.30)
	tie.material_override = tie_mat
	tie.position = Vector3(0, 0.85, 0.22)
	npc.add_child(tie)
	# Ramen bowl held in front
	var bowl: MeshInstance3D = MeshInstance3D.new()
	var bm: CylinderMesh = CylinderMesh.new()
	bm.top_radius = 0.18
	bm.bottom_radius = 0.14
	bm.height = 0.14
	bowl.mesh = bm
	var bowl_mat: StandardMaterial3D = StandardMaterial3D.new()
	bowl_mat.albedo_color = Color(0.95, 0.92, 0.85)
	bowl.material_override = bowl_mat
	bowl.position = Vector3(0.30, 0.85, 0.30)
	npc.add_child(bowl)
	# Steam from bowl
	var steam: GPUParticles3D = GPUParticles3D.new()
	steam.amount = 12
	steam.lifetime = 1.4
	steam.preprocess = 0.5
	steam.position = Vector3(0.30, 0.92, 0.30)
	var pm: ParticleProcessMaterial = ParticleProcessMaterial.new()
	pm.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_POINT
	pm.direction = Vector3(0, 1, 0)
	pm.spread = 18.0
	pm.gravity = Vector3.ZERO
	pm.initial_velocity_min = 0.30
	pm.initial_velocity_max = 0.65
	pm.scale_min = 0.08
	pm.scale_max = 0.16
	pm.color = Color(0.95, 0.92, 0.85, 0.55)
	steam.process_material = pm
	var sm_mesh: SphereMesh = SphereMesh.new()
	sm_mesh.radius = 0.10
	sm_mesh.height = 0.20
	steam.draw_pass_1 = sm_mesh
	var sm_mat: StandardMaterial3D = StandardMaterial3D.new()
	sm_mat.albedo_color = Color(0.95, 0.95, 1.0, 0.45)
	sm_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	sm_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	sm_mesh.material = sm_mat
	npc.add_child(steam)


func _build_d6_pharmacy(geom: Node) -> void:
	## Epic-6 T56: cyber pharmacy storefront — green cross sign + shelves
	## of glowing pill bottles visible behind the counter.
	var pharm: Node3D = Node3D.new()
	pharm.name = "CyberPharmacy"
	pharm.position = Vector3(D6_CENTER.x - 28.0, 0.0, 14.0)
	geom.add_child(pharm)
	var wall_mat: StandardMaterial3D = StandardMaterial3D.new()
	wall_mat.albedo_color = Color(0.85, 0.92, 0.88)
	wall_mat.roughness = 0.55
	# Walls
	var wall: MeshInstance3D = MeshInstance3D.new()
	var wm: BoxMesh = BoxMesh.new()
	wm.size = Vector3(4.20, 3.20, 0.30)
	wall.mesh = wm
	wall.material_override = wall_mat
	wall.position = Vector3(0, 1.60, -1.20)
	pharm.add_child(wall)
	for sx in [-2.0, 2.0]:
		var side: MeshInstance3D = MeshInstance3D.new()
		var swm: BoxMesh = BoxMesh.new()
		swm.size = Vector3(0.30, 3.20, 2.55)
		side.mesh = swm
		side.material_override = wall_mat
		side.position = Vector3(sx, 1.60, 0)
		pharm.add_child(side)
	# Roof
	var roof: MeshInstance3D = MeshInstance3D.new()
	var rm: BoxMesh = BoxMesh.new()
	rm.size = Vector3(4.20, 0.18, 2.85)
	roof.mesh = rm
	roof.material_override = wall_mat
	roof.position = Vector3(0, 3.30, 0)
	pharm.add_child(roof)
	# Green cross sign
	var cross_mat: StandardMaterial3D = StandardMaterial3D.new()
	cross_mat.albedo_color = Color(0.30, 0.95, 0.30)
	cross_mat.emission_enabled = true
	cross_mat.emission = Color(0.30, 1.0, 0.30)
	cross_mat.emission_energy_multiplier = 4.0
	cross_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for axis in 2:
		var bar: MeshInstance3D = MeshInstance3D.new()
		var bm: BoxMesh = BoxMesh.new()
		bm.size = Vector3(0.95, 0.30, 0.06) if axis == 0 else Vector3(0.30, 0.95, 0.06)
		bar.mesh = bm
		bar.material_override = cross_mat
		bar.position = Vector3(0, 2.55, 1.21)
		pharm.add_child(bar)
	# Shelving inside (back wall row of pill bottles)
	var pill_colors: Array = [
		Color(0.95, 0.20, 0.30),
		Color(0.30, 0.95, 0.55),
		Color(0.95, 0.85, 0.20),
		Color(0.30, 0.65, 0.95),
		Color(0.95, 0.30, 0.85),
	]
	for i in 5:
		var bottle: MeshInstance3D = MeshInstance3D.new()
		var bm: CylinderMesh = CylinderMesh.new()
		bm.top_radius = 0.10
		bm.bottom_radius = 0.10
		bm.height = 0.30
		bottle.mesh = bm
		var bottle_mat: StandardMaterial3D = StandardMaterial3D.new()
		bottle_mat.albedo_color = pill_colors[i]
		bottle_mat.emission_enabled = true
		bottle_mat.emission = pill_colors[i]
		bottle_mat.emission_energy_multiplier = 1.4
		bottle_mat.metallic = 0.30
		bottle_mat.roughness = 0.20
		bottle.material_override = bottle_mat
		bottle.position = Vector3(-1.40 + i * 0.70, 1.85, -0.95)
		pharm.add_child(bottle)
	# Light
	var light: OmniLight3D = OmniLight3D.new()
	light.light_color = Color(0.30, 1.0, 0.55)
	light.light_energy = 2.0
	light.omni_range = 5.0
	light.position = Vector3(0, 2.20, 1.20)
	pharm.add_child(light)
	# Pharmacy collision
	var sb: StaticBody3D = StaticBody3D.new()
	sb.position = Vector3(0, 1.60, 0)
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(4.20, 3.20, 2.85)
	cs.shape = cb
	sb.add_child(cs)
	pharm.add_child(sb)


func _build_d6_pharmacist_npc(town: Node) -> void:
	## Epic-6 T57: pharmacist NPC — white coat + cyan tinted glasses +
	## holding a small green pill bottle.
	var npc_slots: Node3D = town.get_node_or_null("%NPCSlots") as Node3D
	if npc_slots == null:
		return
	var slot: Marker3D = Marker3D.new()
	slot.name = "PharmacistSlot"
	slot.position = Vector3(D6_CENTER.x - 28.0, 0.0, 13.0)
	npc_slots.add_child(slot)
	var npc_scene: PackedScene = load("res://scenes/entities/npcs/VillagerR3.tscn") as PackedScene
	if npc_scene == null:
		return
	var npc: Node3D = npc_scene.instantiate() as Node3D
	npc.name = "Pharmacist"
	if "npc_name" in npc:
		npc.set("npc_name", "Doseage")
	if "npc_id" in npc:
		npc.set("npc_id", "pharmacist_d6")
	slot.add_child(npc)
	# White lab coat
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
	# Cyan glasses
	var glasses: MeshInstance3D = MeshInstance3D.new()
	var gmm: BoxMesh = BoxMesh.new()
	gmm.size = Vector3(0.40, 0.10, 0.04)
	glasses.mesh = gmm
	var glasses_mat: StandardMaterial3D = StandardMaterial3D.new()
	glasses_mat.albedo_color = Color(0.30, 0.85, 1.0, 0.85)
	glasses_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	glasses_mat.emission_enabled = true
	glasses_mat.emission = Color(0.30, 0.95, 1.0)
	glasses_mat.emission_energy_multiplier = 1.4
	glasses_mat.metallic = 0.55
	glasses_mat.roughness = 0.10
	glasses.material_override = glasses_mat
	glasses.position = Vector3(0, 1.42, 0.21)
	npc.add_child(glasses)
	# Pill bottle
	var bottle: MeshInstance3D = MeshInstance3D.new()
	var bm: CylinderMesh = CylinderMesh.new()
	bm.top_radius = 0.08
	bm.bottom_radius = 0.08
	bm.height = 0.18
	bottle.mesh = bm
	var bottle_mat: StandardMaterial3D = StandardMaterial3D.new()
	bottle_mat.albedo_color = Color(0.30, 0.95, 0.55)
	bottle_mat.emission_enabled = true
	bottle_mat.emission = Color(0.30, 1.0, 0.55)
	bottle_mat.emission_energy_multiplier = 1.4
	bottle.material_override = bottle_mat
	bottle.position = Vector3(0.40, 0.85, 0.20)
	npc.add_child(bottle)


func _build_d6_fighter_dummy(geom: Node) -> void:
	## Epic-6 T58: street fighter training dummy — torso bag suspended on a
	## post with rope, with a damage particle puff each "hit".
	var dummy: Node3D = Node3D.new()
	dummy.name = "FighterDummy"
	dummy.position = Vector3(D6_CENTER.x + 26.0, 0.0, -8.0)
	geom.add_child(dummy)
	var metal_mat: StandardMaterial3D = StandardMaterial3D.new()
	metal_mat.albedo_color = Color(0.30, 0.32, 0.40)
	metal_mat.metallic = 0.85
	metal_mat.roughness = 0.30
	# Vertical post
	var post: MeshInstance3D = MeshInstance3D.new()
	var pm: CylinderMesh = CylinderMesh.new()
	pm.top_radius = 0.10
	pm.bottom_radius = 0.14
	pm.height = 3.40
	post.mesh = pm
	post.material_override = metal_mat
	post.position = Vector3(0, 1.70, 0)
	dummy.add_child(post)
	# Horizontal arm extending forward
	var arm: MeshInstance3D = MeshInstance3D.new()
	var am: CylinderMesh = CylinderMesh.new()
	am.top_radius = 0.06
	am.bottom_radius = 0.08
	am.height = 1.10
	arm.mesh = am
	arm.material_override = metal_mat
	arm.position = Vector3(0.55, 3.20, 0)
	arm.rotation_degrees = Vector3(0, 0, 90)
	dummy.add_child(arm)
	# Rope hanging down
	var rope: MeshInstance3D = MeshInstance3D.new()
	var rmm: CylinderMesh = CylinderMesh.new()
	rmm.top_radius = 0.025
	rmm.bottom_radius = 0.025
	rmm.height = 0.85
	rope.mesh = rmm
	var rope_mat: StandardMaterial3D = StandardMaterial3D.new()
	rope_mat.albedo_color = Color(0.55, 0.40, 0.20)
	rope_mat.roughness = 0.85
	rope.material_override = rope_mat
	rope.position = Vector3(1.10, 2.55, 0)
	dummy.add_child(rope)
	# Bag (large red cylinder)
	var bag: MeshInstance3D = MeshInstance3D.new()
	var bgm: CylinderMesh = CylinderMesh.new()
	bgm.top_radius = 0.30
	bgm.bottom_radius = 0.40
	bgm.height = 1.40
	bag.mesh = bgm
	var bag_mat: StandardMaterial3D = StandardMaterial3D.new()
	bag_mat.albedo_color = Color(0.85, 0.20, 0.30)
	bag_mat.metallic = 0.30
	bag_mat.roughness = 0.55
	bag.material_override = bag_mat
	bag.position = Vector3(1.10, 1.45, 0)
	dummy.add_child(bag)
	# Bag swing tween (suggests recent hits)
	var tw: Tween = bag.create_tween().set_loops()
	tw.tween_property(bag, "rotation_degrees:x", 8.0, 0.85)
	tw.tween_property(bag, "rotation_degrees:x", -8.0, 0.85)
	# Post collision
	var sb: StaticBody3D = StaticBody3D.new()
	sb.position = Vector3(0, 1.70, 0)
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cap: CapsuleShape3D = CapsuleShape3D.new()
	cap.radius = 0.14
	cap.height = 3.40
	cs.shape = cap
	sb.add_child(cs)
	dummy.add_child(sb)


func _build_d6_street_fighter_npc(town: Node) -> void:
	## Epic-6 T59: street fighter NPC training near the dummy — wraps on
	## fists, sleeveless top, fighting stance.
	var npc_slots: Node3D = town.get_node_or_null("%NPCSlots") as Node3D
	if npc_slots == null:
		return
	var slot: Marker3D = Marker3D.new()
	slot.name = "StreetFighterSlot"
	slot.position = Vector3(D6_CENTER.x + 24.0, 0.0, -8.0)
	npc_slots.add_child(slot)
	var npc_scene: PackedScene = load("res://scenes/entities/npcs/VillagerR3.tscn") as PackedScene
	if npc_scene == null:
		return
	var npc: Node3D = npc_scene.instantiate() as Node3D
	npc.name = "StreetFighter"
	if "npc_name" in npc:
		npc.set("npc_name", "Knockback")
	if "npc_id" in npc:
		npc.set("npc_id", "fighter_d6")
	slot.add_child(npc)
	# Sleeveless white shirt
	var shirt: MeshInstance3D = MeshInstance3D.new()
	var sm: BoxMesh = BoxMesh.new()
	sm.size = Vector3(0.55, 0.85, 0.40)
	shirt.mesh = sm
	var shirt_mat: StandardMaterial3D = StandardMaterial3D.new()
	shirt_mat.albedo_color = Color(0.95, 0.95, 0.92)
	shirt_mat.roughness = 0.85
	shirt.material_override = shirt_mat
	shirt.position = Vector3(0, 0.60, 0)
	npc.add_child(shirt)
	# Wrapped fists (2 white spheres)
	var wrap_mat: StandardMaterial3D = StandardMaterial3D.new()
	wrap_mat.albedo_color = Color(0.85, 0.85, 0.80)
	wrap_mat.roughness = 0.85
	for sx in [-0.30, 0.30]:
		var fist: MeshInstance3D = MeshInstance3D.new()
		var fm: SphereMesh = SphereMesh.new()
		fm.radius = 0.12
		fm.height = 0.22
		fist.mesh = fm
		fist.material_override = wrap_mat
		fist.position = Vector3(sx * 0.85, 0.85, 0.30)
		npc.add_child(fist)
	# Headband (red strip)
	var band: MeshInstance3D = MeshInstance3D.new()
	var bm: CylinderMesh = CylinderMesh.new()
	bm.top_radius = 0.22
	bm.bottom_radius = 0.22
	bm.height = 0.08
	band.mesh = bm
	var band_mat: StandardMaterial3D = StandardMaterial3D.new()
	band_mat.albedo_color = Color(0.95, 0.20, 0.20)
	band_mat.emission_enabled = true
	band_mat.emission = Color(0.95, 0.20, 0.20)
	band_mat.emission_energy_multiplier = 0.85
	band.material_override = band_mat
	band.position = Vector3(0, 1.40, 0)
	npc.add_child(band)
	# Punching tween (sway forward)
	var tw: Tween = npc.create_tween().set_loops()
	tw.tween_property(npc, "position:z", -7.85, 0.20)
	tw.tween_property(npc, "position:z", -8.0, 0.20)
	tw.tween_interval(0.40)


func _build_d6_hover_taxi(geom: Node) -> void:
	## Epic-6 T60: hover taxi vehicle — yellow checkered car with a side
	## "TAXI" sign on top, hovering above the ground.
	var taxi: Node3D = Node3D.new()
	taxi.name = "HoverTaxi"
	taxi.position = Vector3(D6_CENTER.x - 18.0, 1.40, -2.0)
	geom.add_child(taxi)
	var yellow_mat: StandardMaterial3D = StandardMaterial3D.new()
	yellow_mat.albedo_color = Color(0.95, 0.85, 0.20)
	yellow_mat.metallic = 0.55
	yellow_mat.roughness = 0.30
	var dark_mat: StandardMaterial3D = StandardMaterial3D.new()
	dark_mat.albedo_color = Color(0.10, 0.10, 0.15)
	dark_mat.metallic = 0.85
	dark_mat.roughness = 0.30
	# Body chassis (long box)
	var body: MeshInstance3D = MeshInstance3D.new()
	var bm: BoxMesh = BoxMesh.new()
	bm.size = Vector3(3.20, 0.85, 1.40)
	body.mesh = bm
	body.material_override = yellow_mat
	taxi.add_child(body)
	# Cabin (smaller box on top)
	var cabin: MeshInstance3D = MeshInstance3D.new()
	var cmm: BoxMesh = BoxMesh.new()
	cmm.size = Vector3(2.20, 0.95, 1.20)
	cabin.mesh = cmm
	cabin.material_override = yellow_mat
	cabin.position = Vector3(-0.20, 0.90, 0)
	taxi.add_child(cabin)
	# Black checker stripe along the side
	var checker: MeshInstance3D = MeshInstance3D.new()
	var chm: BoxMesh = BoxMesh.new()
	chm.size = Vector3(3.20, 0.20, 0.06)
	checker.mesh = chm
	checker.material_override = dark_mat
	checker.position = Vector3(0, 0.0, 0.72)
	taxi.add_child(checker)
	# Windows (cyan emissive)
	var window_mat: StandardMaterial3D = StandardMaterial3D.new()
	window_mat.albedo_color = Color(0.30, 0.85, 1.0, 0.65)
	window_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	window_mat.emission_enabled = true
	window_mat.emission = Color(0.30, 0.95, 1.0)
	window_mat.emission_energy_multiplier = 1.4
	window_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for sx in [-0.85, 0.45]:
		var win: MeshInstance3D = MeshInstance3D.new()
		var wm: BoxMesh = BoxMesh.new()
		wm.size = Vector3(0.95, 0.65, 0.06)
		win.mesh = wm
		win.material_override = window_mat
		win.position = Vector3(sx, 0.95, 0.62)
		taxi.add_child(win)
	# Top "TAXI" sign
	var sign: MeshInstance3D = MeshInstance3D.new()
	var snm: BoxMesh = BoxMesh.new()
	snm.size = Vector3(0.95, 0.30, 0.30)
	sign.mesh = snm
	var sign_mat: StandardMaterial3D = StandardMaterial3D.new()
	sign_mat.albedo_color = Color(0.95, 0.85, 0.20)
	sign_mat.emission_enabled = true
	sign_mat.emission = Color(0.95, 0.85, 0.20)
	sign_mat.emission_energy_multiplier = 2.5
	sign_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	sign.material_override = sign_mat
	sign.position = Vector3(0, 1.55, 0)
	taxi.add_child(sign)
	var label: Label3D = Label3D.new()
	label.text = "TAXI"
	label.modulate = Color(0.10, 0.05, 0.05)
	label.outline_modulate = Color(0.95, 0.85, 0.20)
	label.outline_size = 4
	label.font_size = 48
	label.pixel_size = 0.005
	label.position = Vector3(0, 1.55, 0.16)
	taxi.add_child(label)
	# Magenta underglow strip
	var glow: MeshInstance3D = MeshInstance3D.new()
	var glm: BoxMesh = BoxMesh.new()
	glm.size = Vector3(3.20, 0.06, 1.40)
	glow.mesh = glm
	var glow_mat: StandardMaterial3D = StandardMaterial3D.new()
	glow_mat.albedo_color = Color(0.95, 0.20, 0.85)
	glow_mat.emission_enabled = true
	glow_mat.emission = Color(0.95, 0.20, 0.85)
	glow_mat.emission_energy_multiplier = 4.0
	glow_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	glow.material_override = glow_mat
	glow.position = Vector3(0, -0.45, 0)
	taxi.add_child(glow)
	# Underglow light
	var light: OmniLight3D = OmniLight3D.new()
	light.light_color = Color(1.0, 0.30, 0.85)
	light.light_energy = 2.0
	light.omni_range = 4.0
	light.position = Vector3(0, -0.30, 0)
	taxi.add_child(light)
	# Hover bob tween
	var tw: Tween = taxi.create_tween().set_loops()
	tw.tween_property(taxi, "position:y", 1.55, 1.4)
	tw.tween_property(taxi, "position:y", 1.40, 1.4)
	# Body collision
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(3.20, 1.85, 1.40)
	cs.shape = cb
	cs.position = Vector3(0, 0.45, 0)
	sb.add_child(cs)
	taxi.add_child(sb)


func _build_d6_bath_house(geom: Node) -> void:
	## Epic-6 T61: cyber bath house — Japanese-style facade with curved
	## prism roof + 2 lit doorway lanterns + steaming pool visible inside.
	var bh: Node3D = Node3D.new()
	bh.name = "BathHouse"
	bh.position = Vector3(D6_CENTER.x - 4.0, 0.0, -22.0)
	geom.add_child(bh)
	var wood_mat: StandardMaterial3D = StandardMaterial3D.new()
	wood_mat.albedo_color = Color(0.40, 0.20, 0.10)
	wood_mat.roughness = 0.85
	# Main building (large box)
	var main: MeshInstance3D = MeshInstance3D.new()
	var bm: BoxMesh = BoxMesh.new()
	bm.size = Vector3(5.50, 3.40, 4.20)
	main.mesh = bm
	main.material_override = wood_mat
	main.position = Vector3(0, 1.70, 0)
	bh.add_child(main)
	# Curved upturned roof (large prism)
	var roof: MeshInstance3D = MeshInstance3D.new()
	var rm: PrismMesh = PrismMesh.new()
	rm.size = Vector3(6.50, 1.85, 4.85)
	roof.mesh = rm
	var roof_mat: StandardMaterial3D = StandardMaterial3D.new()
	roof_mat.albedo_color = Color(0.55, 0.20, 0.15)
	roof_mat.roughness = 0.85
	roof.material_override = roof_mat
	roof.position = Vector3(0, 4.10, 0)
	bh.add_child(roof)
	# Doorway opening (dark interior box)
	var door: MeshInstance3D = MeshInstance3D.new()
	var dm: BoxMesh = BoxMesh.new()
	dm.size = Vector3(1.85, 2.40, 0.10)
	door.mesh = dm
	var dark_mat: StandardMaterial3D = StandardMaterial3D.new()
	dark_mat.albedo_color = Color(0.55, 0.85, 0.95, 0.55)
	dark_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	dark_mat.emission_enabled = true
	dark_mat.emission = Color(0.55, 0.85, 0.95)
	dark_mat.emission_energy_multiplier = 1.6
	dark_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	door.material_override = dark_mat
	door.position = Vector3(0, 1.20, 2.15)
	bh.add_child(door)
	# 2 hanging red lanterns flanking the door
	for sx in [-1.40, 1.40]:
		var lantern: MeshInstance3D = MeshInstance3D.new()
		var lm: SphereMesh = SphereMesh.new()
		lm.radius = 0.30
		lm.height = 0.55
		lantern.mesh = lm
		var lantern_mat: StandardMaterial3D = StandardMaterial3D.new()
		lantern_mat.albedo_color = Color(0.95, 0.30, 0.30)
		lantern_mat.emission_enabled = true
		lantern_mat.emission = Color(0.95, 0.30, 0.30)
		lantern_mat.emission_energy_multiplier = 2.5
		lantern_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		lantern.material_override = lantern_mat
		lantern.position = Vector3(sx, 2.55, 2.20)
		lantern.scale = Vector3(1.0, 1.30, 1.0)
		bh.add_child(lantern)
		# Small light per lantern
		var light: OmniLight3D = OmniLight3D.new()
		light.light_color = Color(1.0, 0.45, 0.30)
		light.light_energy = 1.6
		light.omni_range = 4.0
		light.position = Vector3(sx, 2.55, 2.20)
		bh.add_child(light)
	# Small pool tile visible at the entrance (translucent cyan)
	var pool: MeshInstance3D = MeshInstance3D.new()
	var pmm: CylinderMesh = CylinderMesh.new()
	pmm.top_radius = 0.85
	pmm.bottom_radius = 0.85
	pmm.height = 0.06
	pool.mesh = pmm
	var pool_mat: StandardMaterial3D = StandardMaterial3D.new()
	pool_mat.albedo_color = Color(0.40, 0.85, 1.0, 0.65)
	pool_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	pool_mat.emission_enabled = true
	pool_mat.emission = Color(0.30, 0.95, 1.0)
	pool_mat.emission_energy_multiplier = 1.4
	pool_mat.metallic = 0.30
	pool_mat.roughness = 0.05
	pool.material_override = pool_mat
	pool.position = Vector3(0, 0.05, 2.85)
	bh.add_child(pool)
	# Steam particles from the pool
	var steam: GPUParticles3D = GPUParticles3D.new()
	steam.amount = 30
	steam.lifetime = 2.5
	steam.preprocess = 1.0
	steam.position = Vector3(0, 0.20, 2.85)
	var ppm: ParticleProcessMaterial = ParticleProcessMaterial.new()
	ppm.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	ppm.emission_box_extents = Vector3(0.85, 0.05, 0.85)
	ppm.direction = Vector3(0.10, 1, 0.10)
	ppm.spread = 22.0
	ppm.gravity = Vector3(0, 0.55, 0)
	ppm.initial_velocity_min = 0.30
	ppm.initial_velocity_max = 0.65
	ppm.scale_min = 0.30
	ppm.scale_max = 0.55
	ppm.color = Color(0.95, 0.92, 0.95, 0.55)
	steam.process_material = ppm
	var sm_mesh: SphereMesh = SphereMesh.new()
	sm_mesh.radius = 0.25
	sm_mesh.height = 0.50
	steam.draw_pass_1 = sm_mesh
	var sm_mat: StandardMaterial3D = StandardMaterial3D.new()
	sm_mat.albedo_color = Color(0.95, 0.95, 1.0, 0.45)
	sm_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	sm_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	sm_mesh.material = sm_mat
	bh.add_child(steam)
	# Building collision
	var sb: StaticBody3D = StaticBody3D.new()
	sb.position = Vector3(0, 1.70, 0)
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(5.50, 3.40, 4.20)
	cs.shape = cb
	sb.add_child(cs)
	bh.add_child(sb)


func _build_d6_d6_bath_attendant_npc(town: Node) -> void:
	## Epic-6 T62: D6 bath attendant — yukata robe + small towel.
	var npc_slots: Node3D = town.get_node_or_null("%NPCSlots") as Node3D
	if npc_slots == null:
		return
	var slot: Marker3D = Marker3D.new()
	slot.name = "D6BathAttendantSlot"
	slot.position = Vector3(D6_CENTER.x - 4.0, 0.0, -19.0)
	npc_slots.add_child(slot)
	var npc_scene: PackedScene = load("res://scenes/entities/npcs/VillagerR3.tscn") as PackedScene
	if npc_scene == null:
		return
	var npc: Node3D = npc_scene.instantiate() as Node3D
	npc.name = "D6BathAttendant"
	if "npc_name" in npc:
		npc.set("npc_name", "Sento")
	if "npc_id" in npc:
		npc.set("npc_id", "bath_d6")
	slot.add_child(npc)
	# Blue yukata robe
	var robe: MeshInstance3D = MeshInstance3D.new()
	var rm: BoxMesh = BoxMesh.new()
	rm.size = Vector3(0.65, 1.20, 0.45)
	robe.mesh = rm
	var robe_mat: StandardMaterial3D = StandardMaterial3D.new()
	robe_mat.albedo_color = Color(0.20, 0.40, 0.85)
	robe_mat.emission_enabled = true
	robe_mat.emission = Color(0.20, 0.45, 0.95)
	robe_mat.emission_energy_multiplier = 0.30
	robe_mat.roughness = 0.65
	robe.material_override = robe_mat
	robe.position = Vector3(0, 0.60, 0)
	npc.add_child(robe)
	# Small white towel folded in arms
	var towel: MeshInstance3D = MeshInstance3D.new()
	var tm: BoxMesh = BoxMesh.new()
	tm.size = Vector3(0.40, 0.10, 0.30)
	towel.mesh = tm
	var towel_mat: StandardMaterial3D = StandardMaterial3D.new()
	towel_mat.albedo_color = Color(0.95, 0.95, 0.92)
	towel_mat.roughness = 0.85
	towel.material_override = towel_mat
	towel.position = Vector3(0.30, 0.85, 0.20)
	npc.add_child(towel)


func _build_d6_bike_rack(geom: Node) -> void:
	## Epic-6 T63: bicycle rack — 4 cyber bikes parked at angled stands
	## with neon trim glow and slim wheels.
	var rack: Node3D = Node3D.new()
	rack.name = "BikeRack"
	rack.position = Vector3(D6_CENTER.x - 18.0, 0.0, -16.0)
	geom.add_child(rack)
	var rack_mat: StandardMaterial3D = StandardMaterial3D.new()
	rack_mat.albedo_color = Color(0.30, 0.32, 0.40)
	rack_mat.metallic = 0.85
	rack_mat.roughness = 0.30
	# Rack base bar
	var base: MeshInstance3D = MeshInstance3D.new()
	var bm: BoxMesh = BoxMesh.new()
	bm.size = Vector3(4.20, 0.18, 0.18)
	base.mesh = bm
	base.material_override = rack_mat
	base.position = Vector3(0, 0.10, 0)
	rack.add_child(base)
	# 5 vertical wave bars
	for i in 5:
		var bar: MeshInstance3D = MeshInstance3D.new()
		var brm: BoxMesh = BoxMesh.new()
		brm.size = Vector3(0.10, 0.85, 0.10)
		bar.mesh = brm
		bar.material_override = rack_mat
		bar.position = Vector3(-1.85 + i * 0.85, 0.55, 0)
		rack.add_child(bar)
	# 4 bikes
	var bike_colors: Array = [
		Color(0.30, 0.95, 1.0),
		Color(0.95, 0.30, 0.85),
		Color(0.30, 0.95, 0.55),
		Color(0.95, 0.85, 0.20),
	]
	for i in 4:
		var bike: Node3D = Node3D.new()
		bike.position = Vector3(-1.40 + i * 0.85, 0, 0.30)
		rack.add_child(bike)
		# Frame (thin angled box)
		var frame: MeshInstance3D = MeshInstance3D.new()
		var fm: BoxMesh = BoxMesh.new()
		fm.size = Vector3(0.85, 0.06, 0.06)
		frame.mesh = fm
		var frame_mat: StandardMaterial3D = StandardMaterial3D.new()
		frame_mat.albedo_color = bike_colors[i]
		frame_mat.emission_enabled = true
		frame_mat.emission = bike_colors[i]
		frame_mat.emission_energy_multiplier = 1.4
		frame.material_override = frame_mat
		frame.position = Vector3(0, 0.55, 0)
		bike.add_child(frame)
		# Seat
		var seat: MeshInstance3D = MeshInstance3D.new()
		var sm: BoxMesh = BoxMesh.new()
		sm.size = Vector3(0.18, 0.06, 0.10)
		seat.mesh = sm
		seat.material_override = rack_mat
		seat.position = Vector3(-0.30, 0.65, 0)
		bike.add_child(seat)
		# 2 wheels (thin rings)
		var wheel_mat: StandardMaterial3D = StandardMaterial3D.new()
		wheel_mat.albedo_color = Color(0.10, 0.08, 0.10)
		wheel_mat.roughness = 0.85
		for wx in [0.40, -0.40]:
			var wheel: MeshInstance3D = MeshInstance3D.new()
			var wmm: TorusMesh = TorusMesh.new()
			wmm.inner_radius = 0.15
			wmm.outer_radius = 0.20
			wheel.mesh = wmm
			wheel.material_override = wheel_mat
			wheel.position = Vector3(wx, 0.20, 0)
			wheel.rotation_degrees = Vector3(90, 0, 0)
			bike.add_child(wheel)
	# Rack collision
	var sb: StaticBody3D = StaticBody3D.new()
	sb.position = Vector3(0, 0.55, 0)
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(4.20, 0.85, 1.40)
	cs.shape = cb
	sb.add_child(cs)
	rack.add_child(sb)


func _build_d6_mural_artist_npc(town: Node) -> void:
	## Epic-6 T64: neon mural artist NPC — paint mask, spray can in hand,
	## standing in front of a wall with a colorful splash.
	var npc_slots: Node3D = town.get_node_or_null("%NPCSlots") as Node3D
	if npc_slots == null:
		return
	var slot: Marker3D = Marker3D.new()
	slot.name = "MuralArtistSlot"
	slot.position = Vector3(D6_CENTER.x + 28.0, 0.0, -16.0)
	npc_slots.add_child(slot)
	var npc_scene: PackedScene = load("res://scenes/entities/npcs/VillagerR3.tscn") as PackedScene
	if npc_scene == null:
		return
	var npc: Node3D = npc_scene.instantiate() as Node3D
	npc.name = "MuralArtist"
	if "npc_name" in npc:
		npc.set("npc_name", "Tagger")
	if "npc_id" in npc:
		npc.set("npc_id", "mural_d6")
	slot.add_child(npc)
	# Paint-splattered hoodie
	var hoodie: MeshInstance3D = MeshInstance3D.new()
	var hm: BoxMesh = BoxMesh.new()
	hm.size = Vector3(0.65, 1.05, 0.45)
	hoodie.mesh = hm
	var hoodie_mat: StandardMaterial3D = StandardMaterial3D.new()
	hoodie_mat.albedo_color = Color(0.20, 0.18, 0.25)
	hoodie_mat.roughness = 0.85
	hoodie.material_override = hoodie_mat
	hoodie.position = Vector3(0, 0.55, 0)
	npc.add_child(hoodie)
	# Paint splatter on chest (small bright box)
	var splatter: MeshInstance3D = MeshInstance3D.new()
	var sm: SphereMesh = SphereMesh.new()
	sm.radius = 0.10
	sm.height = 0.18
	splatter.mesh = sm
	var splat_mat: StandardMaterial3D = StandardMaterial3D.new()
	splat_mat.albedo_color = Color(0.30, 0.95, 0.55)
	splat_mat.emission_enabled = true
	splat_mat.emission = Color(0.30, 1.0, 0.55)
	splat_mat.emission_energy_multiplier = 1.4
	splatter.material_override = splat_mat
	splatter.position = Vector3(-0.10, 0.65, 0.22)
	splatter.scale = Vector3(1.40, 0.85, 0.10)
	npc.add_child(splatter)
	# Paint mask on face (white box)
	var mask: MeshInstance3D = MeshInstance3D.new()
	var mm: BoxMesh = BoxMesh.new()
	mm.size = Vector3(0.30, 0.18, 0.06)
	mask.mesh = mm
	var mask_mat: StandardMaterial3D = StandardMaterial3D.new()
	mask_mat.albedo_color = Color(0.95, 0.92, 0.85)
	mask.material_override = mask_mat
	mask.position = Vector3(0, 1.30, 0.21)
	npc.add_child(mask)
	# Spray can in hand (small red cylinder)
	var can: MeshInstance3D = MeshInstance3D.new()
	var cmm: CylinderMesh = CylinderMesh.new()
	cmm.top_radius = 0.06
	cmm.bottom_radius = 0.06
	cmm.height = 0.20
	can.mesh = cmm
	var can_mat: StandardMaterial3D = StandardMaterial3D.new()
	can_mat.albedo_color = Color(0.95, 0.20, 0.30)
	can_mat.metallic = 0.55
	can_mat.roughness = 0.30
	can.material_override = can_mat
	can.position = Vector3(0.40, 0.85, 0.20)
	npc.add_child(can)


func _build_d6_dance_billboard(geom: Node) -> void:
	## Epic-6 T65: holographic dance billboard — large translucent panel
	## with 3 silhouettes dancing (alternating left-right rotation tweens).
	var bb: Node3D = Node3D.new()
	bb.name = "DanceBillboard"
	bb.position = Vector3(D6_CENTER.x - 8.0, 0.0, -22.0)
	geom.add_child(bb)
	var metal_mat: StandardMaterial3D = StandardMaterial3D.new()
	metal_mat.albedo_color = Color(0.30, 0.30, 0.40)
	metal_mat.metallic = 0.85
	# Tall support post
	var post: MeshInstance3D = MeshInstance3D.new()
	var pm: BoxMesh = BoxMesh.new()
	pm.size = Vector3(0.30, 5.85, 0.30)
	post.mesh = pm
	post.material_override = metal_mat
	post.position = Vector3(0, 2.92, 0)
	bb.add_child(post)
	# Hovering panel
	var panel: MeshInstance3D = MeshInstance3D.new()
	var pmm: BoxMesh = BoxMesh.new()
	pmm.size = Vector3(4.20, 2.85, 0.06)
	panel.mesh = pmm
	var panel_mat: StandardMaterial3D = StandardMaterial3D.new()
	panel_mat.albedo_color = Color(0.20, 0.10, 0.30, 0.65)
	panel_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	panel_mat.emission_enabled = true
	panel_mat.emission = Color(0.55, 0.30, 0.85)
	panel_mat.emission_energy_multiplier = 1.4
	panel_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	panel.material_override = panel_mat
	panel.position = Vector3(0, 5.85, 0)
	bb.add_child(panel)
	# 3 dancer silhouettes (white boxes) inside the panel
	var dancer_mat: StandardMaterial3D = StandardMaterial3D.new()
	dancer_mat.albedo_color = Color(0.95, 0.95, 1.0)
	dancer_mat.emission_enabled = true
	dancer_mat.emission = Color(0.95, 0.95, 1.0)
	dancer_mat.emission_energy_multiplier = 2.5
	dancer_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for i in 3:
		var dancer: Node3D = Node3D.new()
		dancer.position = Vector3(-1.20 + i * 1.20, 5.85, 0.06)
		bb.add_child(dancer)
		# Body
		var body: MeshInstance3D = MeshInstance3D.new()
		var bm: BoxMesh = BoxMesh.new()
		bm.size = Vector3(0.30, 1.10, 0.04)
		body.mesh = bm
		body.material_override = dancer_mat
		body.position = Vector3(0, 0, 0)
		dancer.add_child(body)
		# Head
		var head: MeshInstance3D = MeshInstance3D.new()
		var hmm: SphereMesh = SphereMesh.new()
		hmm.radius = 0.15
		hmm.height = 0.30
		head.mesh = hmm
		head.material_override = dancer_mat
		head.position = Vector3(0, 0.75, 0)
		head.scale = Vector3(1.0, 1.0, 0.10)
		dancer.add_child(head)
		# Sway tween (alternating direction per dancer)
		var tw: Tween = dancer.create_tween().set_loops()
		tw.tween_property(dancer, "rotation_degrees:z", 25.0 if i % 2 == 0 else -25.0, 0.30)
		tw.tween_property(dancer, "rotation_degrees:z", -25.0 if i % 2 == 0 else 25.0, 0.30)
	# Light
	var light: OmniLight3D = OmniLight3D.new()
	light.light_color = Color(0.85, 0.30, 1.0)
	light.light_energy = 2.5
	light.omni_range = 7.0
	light.position = Vector3(0, 5.85, 1.20)
	bb.add_child(light)
	# Post collision
	var sb: StaticBody3D = StaticBody3D.new()
	sb.position = Vector3(0, 2.92, 0)
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cap: CapsuleShape3D = CapsuleShape3D.new()
	cap.radius = 0.30
	cap.height = 5.85
	cs.shape = cap
	sb.add_child(cs)
	bb.add_child(sb)


func _build_d6_souvenir_cart(geom: Node) -> void:
	## Epic-6 T66: souvenir vendor cart — small wheeled cart with shelves
	## of brightly colored trinkets.
	var cart: Node3D = Node3D.new()
	cart.name = "SouvenirCart"
	cart.position = Vector3(D6_CENTER.x - 8.0, 0.0, 18.0)
	geom.add_child(cart)
	var wood_mat: StandardMaterial3D = StandardMaterial3D.new()
	wood_mat.albedo_color = Color(0.40, 0.25, 0.10)
	wood_mat.roughness = 0.85
	# Body
	var body: MeshInstance3D = MeshInstance3D.new()
	var bm: BoxMesh = BoxMesh.new()
	bm.size = Vector3(2.20, 0.85, 1.10)
	body.mesh = bm
	body.material_override = wood_mat
	body.position = Vector3(0, 0.55, 0)
	cart.add_child(body)
	# 2 wheels
	var wheel_mat: StandardMaterial3D = StandardMaterial3D.new()
	wheel_mat.albedo_color = Color(0.20, 0.18, 0.10)
	wheel_mat.roughness = 0.85
	for sx in [-0.85, 0.85]:
		var wheel: MeshInstance3D = MeshInstance3D.new()
		var wm: CylinderMesh = CylinderMesh.new()
		wm.top_radius = 0.30
		wm.bottom_radius = 0.30
		wm.height = 0.10
		wheel.mesh = wm
		wheel.material_override = wheel_mat
		wheel.position = Vector3(sx, 0.30, 0.55)
		wheel.rotation_degrees = Vector3(0, 0, 90)
		cart.add_child(wheel)
	# Cart handle
	var handle: MeshInstance3D = MeshInstance3D.new()
	var hm: CylinderMesh = CylinderMesh.new()
	hm.top_radius = 0.05
	hm.bottom_radius = 0.05
	hm.height = 1.10
	handle.mesh = hm
	handle.material_override = wood_mat
	handle.position = Vector3(-1.40, 0.85, 0)
	handle.rotation_degrees = Vector3(0, 0, 60)
	cart.add_child(handle)
	# Slanted roof shade
	var roof: MeshInstance3D = MeshInstance3D.new()
	var rmm: BoxMesh = BoxMesh.new()
	rmm.size = Vector3(2.40, 0.10, 1.30)
	roof.mesh = rmm
	var roof_mat: StandardMaterial3D = StandardMaterial3D.new()
	roof_mat.albedo_color = Color(0.85, 0.20, 0.30)
	roof_mat.roughness = 0.85
	roof.material_override = roof_mat
	roof.position = Vector3(0, 1.85, -0.10)
	roof.rotation_degrees = Vector3(-12, 0, 0)
	cart.add_child(roof)
	# Roof support posts
	for sx in [-1.10, 1.10]:
		var post: MeshInstance3D = MeshInstance3D.new()
		var pm: CylinderMesh = CylinderMesh.new()
		pm.top_radius = 0.05
		pm.bottom_radius = 0.05
		pm.height = 0.85
		post.mesh = pm
		post.material_override = wood_mat
		post.position = Vector3(sx, 1.40, -0.30)
		cart.add_child(post)
	# 9 colored trinkets on the body top
	var trinket_colors: Array = [
		Color(0.95, 0.20, 0.30),
		Color(0.30, 0.95, 0.55),
		Color(0.95, 0.85, 0.20),
		Color(0.30, 0.65, 0.95),
		Color(0.95, 0.30, 0.85),
		Color(0.55, 0.30, 0.95),
		Color(0.30, 0.95, 0.85),
		Color(0.95, 0.55, 0.20),
		Color(0.95, 0.95, 0.20),
	]
	for i in 9:
		var trinket: MeshInstance3D = MeshInstance3D.new()
		var tm: SphereMesh = SphereMesh.new()
		tm.radius = 0.12
		tm.height = 0.20
		trinket.mesh = tm
		var t_mat: StandardMaterial3D = StandardMaterial3D.new()
		t_mat.albedo_color = trinket_colors[i]
		t_mat.emission_enabled = true
		t_mat.emission = trinket_colors[i]
		t_mat.emission_energy_multiplier = 1.4
		trinket.material_override = t_mat
		trinket.position = Vector3(-0.85 + (i % 3) * 0.85, 1.10, -0.30 + (i / 3) * 0.30)
		cart.add_child(trinket)
	# Cart collision
	var sb: StaticBody3D = StaticBody3D.new()
	sb.position = Vector3(0, 0.85, 0)
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(2.40, 1.85, 1.10)
	cs.shape = cb
	sb.add_child(cs)
	cart.add_child(sb)


func _build_d6_souvenir_vendor_npc(town: Node) -> void:
	## Epic-6 T67: souvenir vendor NPC — bright apron + holding a small
	## souvenir trinket up.
	var npc_slots: Node3D = town.get_node_or_null("%NPCSlots") as Node3D
	if npc_slots == null:
		return
	var slot: Marker3D = Marker3D.new()
	slot.name = "SouvenirVendorSlot"
	slot.position = Vector3(D6_CENTER.x - 8.0, 0.0, 17.0)
	npc_slots.add_child(slot)
	var npc_scene: PackedScene = load("res://scenes/entities/npcs/VillagerR3.tscn") as PackedScene
	if npc_scene == null:
		return
	var npc: Node3D = npc_scene.instantiate() as Node3D
	npc.name = "SouvenirVendor"
	if "npc_name" in npc:
		npc.set("npc_name", "Trinket")
	if "npc_id" in npc:
		npc.set("npc_id", "souvenir_d6")
	slot.add_child(npc)
	# Bright pink apron
	var apron: MeshInstance3D = MeshInstance3D.new()
	var am: BoxMesh = BoxMesh.new()
	am.size = Vector3(0.55, 0.85, 0.06)
	apron.mesh = am
	var apron_mat: StandardMaterial3D = StandardMaterial3D.new()
	apron_mat.albedo_color = Color(0.95, 0.45, 0.75)
	apron_mat.emission_enabled = true
	apron_mat.emission = Color(0.95, 0.30, 0.75)
	apron_mat.emission_energy_multiplier = 0.30
	apron.material_override = apron_mat
	apron.position = Vector3(0, 0.55, 0.22)
	npc.add_child(apron)
	# Held trinket (small bright sphere)
	var trinket: MeshInstance3D = MeshInstance3D.new()
	var tm: SphereMesh = SphereMesh.new()
	tm.radius = 0.10
	tm.height = 0.18
	trinket.mesh = tm
	var t_mat: StandardMaterial3D = StandardMaterial3D.new()
	t_mat.albedo_color = Color(0.30, 0.95, 1.0)
	t_mat.emission_enabled = true
	t_mat.emission = Color(0.30, 1.0, 1.0)
	t_mat.emission_energy_multiplier = 2.5
	t_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	trinket.material_override = t_mat
	trinket.position = Vector3(0.40, 1.10, 0.20)
	npc.add_child(trinket)


func _build_d6_holo_koi_pond(geom: Node) -> void:
	## Epic-6 T68: holographic koi pond — round translucent purple disc on
	## a stone rim, with cyan ripple textures.
	var pond: Node3D = Node3D.new()
	pond.name = "HoloKoiPond"
	pond.position = Vector3(D6_CENTER.x + 12.0, 0.0, 6.0)
	geom.add_child(pond)
	# Stone rim
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.30, 0.20, 0.30)
	stone_mat.roughness = 0.92
	var rim: MeshInstance3D = MeshInstance3D.new()
	var rm: TorusMesh = TorusMesh.new()
	rm.inner_radius = 1.85
	rm.outer_radius = 2.20
	rim.mesh = rm
	rim.material_override = stone_mat
	rim.position = Vector3(0, 0.18, 0)
	pond.add_child(rim)
	# Holographic water surface (translucent purple)
	var water: MeshInstance3D = MeshInstance3D.new()
	var wm: CylinderMesh = CylinderMesh.new()
	wm.top_radius = 1.95
	wm.bottom_radius = 1.95
	wm.height = 0.06
	water.mesh = wm
	var water_mat: StandardMaterial3D = StandardMaterial3D.new()
	water_mat.albedo_color = Color(0.40, 0.30, 0.85, 0.65)
	water_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	water_mat.emission_enabled = true
	water_mat.emission = Color(0.55, 0.40, 0.95)
	water_mat.emission_energy_multiplier = 1.4
	water_mat.metallic = 0.30
	water_mat.roughness = 0.10
	water.material_override = water_mat
	water.position = Vector3(0, 0.18, 0)
	pond.add_child(water)
	# Bob the water surface
	var tw: Tween = water.create_tween().set_loops()
	tw.tween_property(water, "position:y", 0.22, 1.6)
	tw.tween_property(water, "position:y", 0.18, 1.6)
	# 3 cyan ripple ring tweens (small tori expanding)
	for i in 3:
		var ripple: MeshInstance3D = MeshInstance3D.new()
		var rim2: TorusMesh = TorusMesh.new()
		rim2.inner_radius = 0.30
		rim2.outer_radius = 0.40
		ripple.mesh = rim2
		var ripple_mat: StandardMaterial3D = StandardMaterial3D.new()
		ripple_mat.albedo_color = Color(0.30, 0.95, 1.0, 0.85)
		ripple_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		ripple_mat.emission_enabled = true
		ripple_mat.emission = Color(0.30, 1.0, 1.0)
		ripple_mat.emission_energy_multiplier = 2.0
		ripple_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		ripple.material_override = ripple_mat
		ripple.position = Vector3(randf_range(-0.85, 0.85), 0.25, randf_range(-0.85, 0.85))
		ripple.rotation_degrees = Vector3(90, 0, 0)
		pond.add_child(ripple)
		# Expand and fade tween
		var twr: Tween = ripple.create_tween().set_loops()
		twr.tween_interval(i * 0.50)
		twr.tween_property(ripple, "scale", Vector3.ONE * 2.50, 1.40)
		twr.tween_property(ripple, "scale", Vector3.ONE * 1.0, 0.0)
	# Pond light
	var light: OmniLight3D = OmniLight3D.new()
	light.light_color = Color(0.55, 0.40, 0.95)
	light.light_energy = 1.6
	light.omni_range = 5.0
	light.position = Vector3(0, 0.85, 0)
	pond.add_child(light)
	# Rim collision
	var sb: StaticBody3D = StaticBody3D.new()
	sb.position = Vector3(0, 0.18, 0)
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cap: CylinderShape3D = CylinderShape3D.new()
	cap.radius = 2.20
	cap.height = 0.40
	cs.shape = cap
	sb.add_child(cs)
	pond.add_child(sb)


func _build_d6_koi_fish(geom: Node) -> void:
	## Epic-6 T69: 4 koi fish swimming in the holo pond — flat colored
	## prisms with rotation pivots.
	var koi: Node3D = Node3D.new()
	koi.name = "KoiFish"
	koi.position = Vector3(D6_CENTER.x + 12.0, 0.30, 6.0)
	geom.add_child(koi)
	var koi_colors: Array = [
		Color(0.95, 0.55, 0.20),
		Color(0.95, 0.95, 1.0),
		Color(0.95, 0.20, 0.30),
		Color(0.30, 0.55, 0.95),
	]
	for i in 4:
		var pivot: Node3D = Node3D.new()
		pivot.position = Vector3(0, 0, 0)
		pivot.rotation_degrees = Vector3(0, i * 90.0, 0)
		koi.add_child(pivot)
		var fish: Node3D = Node3D.new()
		fish.position = Vector3(1.0 + i * 0.20, 0, 0)
		pivot.add_child(fish)
		# Body (long flat prism)
		var body: MeshInstance3D = MeshInstance3D.new()
		var bm: PrismMesh = PrismMesh.new()
		bm.size = Vector3(0.18, 0.08, 0.40)
		body.mesh = bm
		var fish_mat: StandardMaterial3D = StandardMaterial3D.new()
		fish_mat.albedo_color = koi_colors[i]
		fish_mat.emission_enabled = true
		fish_mat.emission = koi_colors[i]
		fish_mat.emission_energy_multiplier = 1.4
		body.material_override = fish_mat
		fish.add_child(body)
		# Tail (small prism behind)
		var tail: MeshInstance3D = MeshInstance3D.new()
		var tm: PrismMesh = PrismMesh.new()
		tm.size = Vector3(0.04, 0.08, 0.18)
		tail.mesh = tm
		tail.material_override = fish_mat
		tail.position = Vector3(0, 0, -0.25)
		fish.add_child(tail)
		# Rotation tween
		var trot: Tween = pivot.create_tween().set_loops()
		trot.tween_property(pivot, "rotation_degrees:y", i * 90.0 + 360.0, 5.0 + i * 0.4)
		trot.tween_property(pivot, "rotation_degrees:y", i * 90.0, 0.0)


func _build_d6_street_shrine(geom: Node) -> void:
	## Epic-6 T70: small street shrine — wooden box with a glowing red
	## offering inside, paper lantern on top.
	var shrine: Node3D = Node3D.new()
	shrine.name = "StreetShrine"
	shrine.position = Vector3(D6_CENTER.x + 22.0, 0.0, 18.0)
	geom.add_child(shrine)
	var wood_mat: StandardMaterial3D = StandardMaterial3D.new()
	wood_mat.albedo_color = Color(0.40, 0.20, 0.10)
	wood_mat.roughness = 0.85
	# Pedestal
	var ped: MeshInstance3D = MeshInstance3D.new()
	var pm: BoxMesh = BoxMesh.new()
	pm.size = Vector3(0.85, 0.85, 0.85)
	ped.mesh = pm
	ped.material_override = wood_mat
	ped.position = Vector3(0, 0.42, 0)
	shrine.add_child(ped)
	# Shrine box
	var box: MeshInstance3D = MeshInstance3D.new()
	var bm: BoxMesh = BoxMesh.new()
	bm.size = Vector3(0.65, 0.85, 0.65)
	box.mesh = bm
	box.material_override = wood_mat
	box.position = Vector3(0, 1.30, 0)
	shrine.add_child(box)
	# Sloped roof
	var roof: MeshInstance3D = MeshInstance3D.new()
	var rm: PrismMesh = PrismMesh.new()
	rm.size = Vector3(0.85, 0.30, 0.85)
	roof.mesh = rm
	var roof_mat: StandardMaterial3D = StandardMaterial3D.new()
	roof_mat.albedo_color = Color(0.55, 0.20, 0.15)
	roof.material_override = roof_mat
	roof.position = Vector3(0, 1.85, 0)
	shrine.add_child(roof)
	# Glowing red offering inside (sphere)
	var offering: MeshInstance3D = MeshInstance3D.new()
	var om: SphereMesh = SphereMesh.new()
	om.radius = 0.18
	om.height = 0.32
	offering.mesh = om
	var off_mat: StandardMaterial3D = StandardMaterial3D.new()
	off_mat.albedo_color = Color(0.95, 0.20, 0.20)
	off_mat.emission_enabled = true
	off_mat.emission = Color(0.95, 0.30, 0.20)
	off_mat.emission_energy_multiplier = 3.5
	off_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	offering.material_override = off_mat
	offering.position = Vector3(0, 1.30, 0.30)
	shrine.add_child(offering)
	# Pulse the offering
	var tw: Tween = offering.create_tween().set_loops()
	tw.tween_property(offering, "scale", Vector3.ONE * 1.20, 0.85)
	tw.tween_property(offering, "scale", Vector3.ONE * 0.85, 0.85)
	# Hanging paper lantern overhead
	var lantern: MeshInstance3D = MeshInstance3D.new()
	var lm: SphereMesh = SphereMesh.new()
	lm.radius = 0.18
	lm.height = 0.30
	lantern.mesh = lm
	var lantern_mat: StandardMaterial3D = StandardMaterial3D.new()
	lantern_mat.albedo_color = Color(0.95, 0.85, 0.55)
	lantern_mat.emission_enabled = true
	lantern_mat.emission = Color(0.95, 0.65, 0.30)
	lantern_mat.emission_energy_multiplier = 2.5
	lantern.material_override = lantern_mat
	lantern.position = Vector3(0, 2.55, 0)
	shrine.add_child(lantern)
	# Light
	var light: OmniLight3D = OmniLight3D.new()
	light.light_color = Color(1.0, 0.65, 0.30)
	light.light_energy = 1.6
	light.omni_range = 4.0
	light.position = Vector3(0, 2.0, 0)
	shrine.add_child(light)
	# Shrine collision
	var sb: StaticBody3D = StaticBody3D.new()
	sb.position = Vector3(0, 0.85, 0)
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(0.85, 1.85, 0.85)
	cs.shape = cb
	sb.add_child(cs)
	shrine.add_child(sb)


func _build_d6_barbershop(geom: Node) -> void:
	## Epic-6 T71: cyber barbershop — slim storefront with the iconic
	## rotating red/white/blue pole + a styling chair + mirror.
	var shop: Node3D = Node3D.new()
	shop.name = "Barbershop"
	shop.position = Vector3(D6_CENTER.x + 12.0, 0.0, -22.0)
	geom.add_child(shop)
	var wall_mat: StandardMaterial3D = StandardMaterial3D.new()
	wall_mat.albedo_color = Color(0.85, 0.85, 0.92)
	wall_mat.roughness = 0.55
	# Walls
	var wall: MeshInstance3D = MeshInstance3D.new()
	var wm: BoxMesh = BoxMesh.new()
	wm.size = Vector3(3.85, 3.20, 0.30)
	wall.mesh = wm
	wall.material_override = wall_mat
	wall.position = Vector3(0, 1.60, -1.20)
	shop.add_child(wall)
	for sx in [-1.85, 1.85]:
		var side: MeshInstance3D = MeshInstance3D.new()
		var swm: BoxMesh = BoxMesh.new()
		swm.size = Vector3(0.30, 3.20, 2.55)
		side.mesh = swm
		side.material_override = wall_mat
		side.position = Vector3(sx, 1.60, 0)
		shop.add_child(side)
	# Roof
	var roof: MeshInstance3D = MeshInstance3D.new()
	var rm: BoxMesh = BoxMesh.new()
	rm.size = Vector3(3.85, 0.18, 2.85)
	roof.mesh = rm
	roof.material_override = wall_mat
	roof.position = Vector3(0, 3.30, 0)
	shop.add_child(roof)
	# Rotating barber pole (vertical cylinder with red+white+blue stripes)
	var pole_pivot: Node3D = Node3D.new()
	pole_pivot.position = Vector3(2.0, 1.40, 1.20)
	shop.add_child(pole_pivot)
	var pole: MeshInstance3D = MeshInstance3D.new()
	var pm: CylinderMesh = CylinderMesh.new()
	pm.top_radius = 0.10
	pm.bottom_radius = 0.10
	pm.height = 1.85
	pole.mesh = pm
	var pole_mat: StandardMaterial3D = StandardMaterial3D.new()
	pole_mat.albedo_color = Color(0.95, 0.92, 0.85)
	pole.material_override = pole_mat
	pole_pivot.add_child(pole)
	# Red and blue stripe (boxes wrapping the pole)
	var red_mat: StandardMaterial3D = StandardMaterial3D.new()
	red_mat.albedo_color = Color(0.95, 0.20, 0.20)
	red_mat.emission_enabled = true
	red_mat.emission = Color(0.95, 0.20, 0.20)
	red_mat.emission_energy_multiplier = 1.4
	var blue_mat: StandardMaterial3D = StandardMaterial3D.new()
	blue_mat.albedo_color = Color(0.20, 0.30, 0.95)
	blue_mat.emission_enabled = true
	blue_mat.emission = Color(0.20, 0.30, 0.95)
	blue_mat.emission_energy_multiplier = 1.4
	for i in 6:
		var stripe: MeshInstance3D = MeshInstance3D.new()
		var sm: BoxMesh = BoxMesh.new()
		sm.size = Vector3(0.22, 0.10, 0.02)
		stripe.mesh = sm
		stripe.material_override = red_mat if i % 2 == 0 else blue_mat
		stripe.position = Vector3(0, -0.85 + i * 0.30, 0.10)
		pole_pivot.add_child(stripe)
	# Spin pivot
	var tw: Tween = pole_pivot.create_tween().set_loops()
	tw.tween_property(pole_pivot, "rotation_degrees:y", 360.0, 4.0)
	tw.tween_property(pole_pivot, "rotation_degrees:y", 0.0, 0.0)
	# Styling chair (red leather)
	var chair: MeshInstance3D = MeshInstance3D.new()
	var cm: BoxMesh = BoxMesh.new()
	cm.size = Vector3(0.85, 0.30, 0.85)
	chair.mesh = cm
	var chair_mat: StandardMaterial3D = StandardMaterial3D.new()
	chair_mat.albedo_color = Color(0.85, 0.20, 0.30)
	chair.material_override = chair_mat
	chair.position = Vector3(0, 0.85, -0.30)
	shop.add_child(chair)
	# Chair backrest
	var back: MeshInstance3D = MeshInstance3D.new()
	var bm: BoxMesh = BoxMesh.new()
	bm.size = Vector3(0.85, 1.10, 0.18)
	back.mesh = bm
	back.material_override = chair_mat
	back.position = Vector3(0, 1.55, -0.65)
	shop.add_child(back)
	# Mirror behind chair (glowing rectangle)
	var mirror: MeshInstance3D = MeshInstance3D.new()
	var mm: BoxMesh = BoxMesh.new()
	mm.size = Vector3(0.85, 1.40, 0.04)
	mirror.mesh = mm
	var mirror_mat: StandardMaterial3D = StandardMaterial3D.new()
	mirror_mat.albedo_color = Color(0.65, 0.85, 1.0)
	mirror_mat.emission_enabled = true
	mirror_mat.emission = Color(0.65, 0.85, 1.0)
	mirror_mat.emission_energy_multiplier = 0.85
	mirror_mat.metallic = 0.85
	mirror_mat.roughness = 0.05
	mirror.material_override = mirror_mat
	mirror.position = Vector3(0, 2.0, -1.05)
	shop.add_child(mirror)
	# Light
	var light: OmniLight3D = OmniLight3D.new()
	light.light_color = Color(0.95, 0.95, 1.0)
	light.light_energy = 1.6
	light.omni_range = 4.0
	light.position = Vector3(0, 2.40, 0.50)
	shop.add_child(light)
	# Shop collision
	var sb: StaticBody3D = StaticBody3D.new()
	sb.position = Vector3(0, 1.60, 0)
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(3.85, 3.20, 2.85)
	cs.shape = cb
	sb.add_child(cs)
	shop.add_child(sb)


func _build_d6_barber_npc(town: Node) -> void:
	## Epic-6 T72: barber NPC — striped vest + holding scissors.
	var npc_slots: Node3D = town.get_node_or_null("%NPCSlots") as Node3D
	if npc_slots == null:
		return
	var slot: Marker3D = Marker3D.new()
	slot.name = "BarberSlot"
	slot.position = Vector3(D6_CENTER.x + 12.0, 0.0, -21.0)
	npc_slots.add_child(slot)
	var npc_scene: PackedScene = load("res://scenes/entities/npcs/VillagerR3.tscn") as PackedScene
	if npc_scene == null:
		return
	var npc: Node3D = npc_scene.instantiate() as Node3D
	npc.name = "Barber"
	if "npc_name" in npc:
		npc.set("npc_name", "Snip")
	if "npc_id" in npc:
		npc.set("npc_id", "barber_d6")
	slot.add_child(npc)
	# White vest
	var vest: MeshInstance3D = MeshInstance3D.new()
	var vm: BoxMesh = BoxMesh.new()
	vm.size = Vector3(0.65, 0.85, 0.40)
	vest.mesh = vm
	var vest_mat: StandardMaterial3D = StandardMaterial3D.new()
	vest_mat.albedo_color = Color(0.95, 0.95, 0.92)
	vest_mat.roughness = 0.65
	vest.material_override = vest_mat
	vest.position = Vector3(0, 0.65, 0)
	npc.add_child(vest)
	# Red bow tie
	var bow: MeshInstance3D = MeshInstance3D.new()
	var bm: BoxMesh = BoxMesh.new()
	bm.size = Vector3(0.18, 0.06, 0.06)
	bow.mesh = bm
	var bow_mat: StandardMaterial3D = StandardMaterial3D.new()
	bow_mat.albedo_color = Color(0.95, 0.20, 0.20)
	bow.material_override = bow_mat
	bow.position = Vector3(0, 1.10, 0.20)
	npc.add_child(bow)
	# Scissors (2 tiny crossed cylinders)
	var scissors: Node3D = Node3D.new()
	scissors.position = Vector3(0.40, 0.85, 0.20)
	npc.add_child(scissors)
	var blade_mat: StandardMaterial3D = StandardMaterial3D.new()
	blade_mat.albedo_color = Color(0.85, 0.92, 1.0)
	blade_mat.metallic = 0.95
	blade_mat.roughness = 0.05
	for i in 2:
		var blade: MeshInstance3D = MeshInstance3D.new()
		var bm2: BoxMesh = BoxMesh.new()
		bm2.size = Vector3(0.04, 0.20, 0.02)
		blade.mesh = bm2
		blade.material_override = blade_mat
		blade.rotation_degrees = Vector3(0, 0, 25.0 if i == 0 else -25.0)
		scissors.add_child(blade)


func _build_d6_lantern_string(geom: Node) -> void:
	## Epic-6 T73: long string of hanging colored paper lanterns running
	## across the bazaar at high altitude.
	var string: Node3D = Node3D.new()
	string.name = "LanternString"
	string.position = Vector3(D6_CENTER.x, 6.0, 0.0)
	geom.add_child(string)
	# Long horizontal wire
	var wire: MeshInstance3D = MeshInstance3D.new()
	var wm: CylinderMesh = CylinderMesh.new()
	wm.top_radius = 0.018
	wm.bottom_radius = 0.018
	wm.height = 50.0
	wire.mesh = wm
	var wire_mat: StandardMaterial3D = StandardMaterial3D.new()
	wire_mat.albedo_color = Color(0.20, 0.18, 0.22)
	wire_mat.roughness = 0.85
	wire.material_override = wire_mat
	wire.rotation_degrees = Vector3(0, 0, 90)
	string.add_child(wire)
	# 18 colored lanterns hanging
	var lantern_colors: Array = [
		Color(0.95, 0.20, 0.30),
		Color(0.95, 0.65, 0.20),
		Color(0.95, 0.85, 0.20),
		Color(0.30, 0.95, 0.55),
		Color(0.30, 0.65, 0.95),
		Color(0.55, 0.30, 0.95),
	]
	for i in 18:
		var lantern: MeshInstance3D = MeshInstance3D.new()
		var lm: SphereMesh = SphereMesh.new()
		lm.radius = 0.22
		lm.height = 0.40
		lantern.mesh = lm
		var lmat: StandardMaterial3D = StandardMaterial3D.new()
		lmat.albedo_color = lantern_colors[i % 6]
		lmat.emission_enabled = true
		lmat.emission = lantern_colors[i % 6]
		lmat.emission_energy_multiplier = 2.5
		lmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		lantern.material_override = lmat
		lantern.position = Vector3(-22.0 + i * 2.60, -0.30, 0)
		lantern.scale = Vector3(1.0, 1.30, 1.0)
		string.add_child(lantern)
		# Small light per lantern
		var light: OmniLight3D = OmniLight3D.new()
		light.light_color = lantern_colors[i % 6]
		light.light_energy = 1.0
		light.omni_range = 2.5
		light.position = Vector3(-22.0 + i * 2.60, -0.30, 0)
		string.add_child(light)
		# Subtle sway
		var tw: Tween = lantern.create_tween().set_loops()
		tw.tween_interval(i * 0.10)
		tw.tween_property(lantern, "rotation_degrees:z", 6.0, 1.4)
		tw.tween_property(lantern, "rotation_degrees:z", -6.0, 1.4)


func _build_d6_vending_bot(geom: Node) -> void:
	## Epic-6 T74: small wheeled vending bot — round body + 2 wheels +
	## floating menu screen + colored item slots.
	var bot: Node3D = Node3D.new()
	bot.name = "VendingBot"
	bot.position = Vector3(D6_CENTER.x - 16.0, 0.0, -22.0)
	geom.add_child(bot)
	var metal_mat: StandardMaterial3D = StandardMaterial3D.new()
	metal_mat.albedo_color = Color(0.30, 0.32, 0.40)
	metal_mat.metallic = 0.85
	metal_mat.roughness = 0.30
	# Body sphere
	var body: MeshInstance3D = MeshInstance3D.new()
	var bm: SphereMesh = SphereMesh.new()
	bm.radius = 0.55
	bm.height = 0.95
	body.mesh = bm
	body.material_override = metal_mat
	body.position = Vector3(0, 0.85, 0)
	bot.add_child(body)
	# 2 wheels
	for sx in [-0.40, 0.40]:
		var wheel: MeshInstance3D = MeshInstance3D.new()
		var wm: CylinderMesh = CylinderMesh.new()
		wm.top_radius = 0.20
		wm.bottom_radius = 0.20
		wm.height = 0.10
		wheel.mesh = wm
		var wheel_mat: StandardMaterial3D = StandardMaterial3D.new()
		wheel_mat.albedo_color = Color(0.10, 0.10, 0.15)
		wheel_mat.roughness = 0.85
		wheel.material_override = wheel_mat
		wheel.position = Vector3(sx, 0.20, 0)
		wheel.rotation_degrees = Vector3(0, 0, 90)
		bot.add_child(wheel)
	# Menu screen on body
	var screen: MeshInstance3D = MeshInstance3D.new()
	var smm: BoxMesh = BoxMesh.new()
	smm.size = Vector3(0.55, 0.40, 0.04)
	screen.mesh = smm
	var screen_mat: StandardMaterial3D = StandardMaterial3D.new()
	screen_mat.albedo_color = Color(0.30, 0.95, 1.0)
	screen_mat.emission_enabled = true
	screen_mat.emission = Color(0.30, 1.0, 1.0)
	screen_mat.emission_energy_multiplier = 2.5
	screen_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	screen.material_override = screen_mat
	screen.position = Vector3(0, 0.85, 0.55)
	bot.add_child(screen)
	# Item slot bumps (3 colored small spheres)
	var item_colors: Array = [
		Color(0.95, 0.20, 0.30),
		Color(0.30, 0.95, 0.55),
		Color(0.95, 0.85, 0.20),
	]
	for i in 3:
		var slot_bump: MeshInstance3D = MeshInstance3D.new()
		var sbm: SphereMesh = SphereMesh.new()
		sbm.radius = 0.06
		sbm.height = 0.12
		slot_bump.mesh = sbm
		var sb_mat: StandardMaterial3D = StandardMaterial3D.new()
		sb_mat.albedo_color = item_colors[i]
		sb_mat.emission_enabled = true
		sb_mat.emission = item_colors[i]
		sb_mat.emission_energy_multiplier = 2.0
		slot_bump.material_override = sb_mat
		slot_bump.position = Vector3(-0.18 + i * 0.18, 0.40, 0.50)
		bot.add_child(slot_bump)
	# Bot patrol back and forth
	var tw: Tween = bot.create_tween().set_loops()
	tw.tween_property(bot, "position:x", D6_CENTER.x - 14.0, 3.0)
	tw.tween_property(bot, "rotation_degrees:y", 180.0, 0.4)
	tw.tween_property(bot, "position:x", D6_CENTER.x - 18.0, 3.0)
	tw.tween_property(bot, "rotation_degrees:y", 0.0, 0.4)
	# Body collision
	var sb: StaticBody3D = StaticBody3D.new()
	sb.position = Vector3(0, 0.85, 0)
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cap: SphereShape3D = SphereShape3D.new()
	cap.radius = 0.55
	cs.shape = cap
	sb.add_child(cs)
	bot.add_child(sb)


func _build_d6_cyber_mural(geom: Node) -> void:
	## Epic-6 T75: large cyber graffiti mural — wide dark wall with a big
	## colorful spray-paint splash + text "404".
	var mural: Node3D = Node3D.new()
	mural.name = "CyberMural"
	mural.position = Vector3(D6_CENTER.x + 28.0, 0.0, -22.0)
	geom.add_child(mural)
	var dark_mat: StandardMaterial3D = StandardMaterial3D.new()
	dark_mat.albedo_color = Color(0.15, 0.12, 0.18)
	dark_mat.roughness = 0.85
	# Wide wall
	var wall: MeshInstance3D = MeshInstance3D.new()
	var wm: BoxMesh = BoxMesh.new()
	wm.size = Vector3(6.50, 4.20, 0.30)
	wall.mesh = wm
	wall.material_override = dark_mat
	wall.position = Vector3(0, 2.10, 0)
	mural.add_child(wall)
	# Background splash blob
	var blob_colors: Array = [
		Color(0.95, 0.20, 0.85),
		Color(0.30, 0.95, 0.55),
		Color(0.30, 0.65, 0.95),
		Color(0.95, 0.85, 0.20),
		Color(0.95, 0.30, 0.30),
	]
	for i in 12:
		var blob: MeshInstance3D = MeshInstance3D.new()
		var bm: SphereMesh = SphereMesh.new()
		bm.radius = 0.40 + randf() * 0.35
		bm.height = 0.20
		blob.mesh = bm
		var blob_mat: StandardMaterial3D = StandardMaterial3D.new()
		blob_mat.albedo_color = blob_colors[i % 5]
		blob_mat.emission_enabled = true
		blob_mat.emission = blob_colors[i % 5]
		blob_mat.emission_energy_multiplier = 2.0
		blob_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		blob.material_override = blob_mat
		blob.position = Vector3(
			randf_range(-2.85, 2.85),
			0.85 + randf_range(0, 2.85),
			0.18
		)
		blob.scale = Vector3(1.0, 0.85, 0.10)
		mural.add_child(blob)
	# Big "404" Label
	var label: Label3D = Label3D.new()
	label.text = "404"
	label.modulate = Color(0.95, 0.95, 1.0)
	label.outline_modulate = Color(0.10, 0.05, 0.20)
	label.outline_size = 16
	label.font_size = 144
	label.pixel_size = 0.018
	label.position = Vector3(0, 2.55, 0.20)
	mural.add_child(label)
	var sub: Label3D = Label3D.new()
	sub.text = "RESET FOUND"
	sub.modulate = Color(0.30, 1.0, 1.0)
	sub.outline_modulate = Color(0.05, 0.20, 0.30)
	sub.outline_size = 6
	sub.font_size = 48
	sub.pixel_size = 0.010
	sub.position = Vector3(0, 1.20, 0.20)
	mural.add_child(sub)
	# Light
	var light: OmniLight3D = OmniLight3D.new()
	light.light_color = Color(0.95, 0.30, 0.85)
	light.light_energy = 2.0
	light.omni_range = 6.5
	light.position = Vector3(0, 2.55, 1.85)
	mural.add_child(light)
	# Wall collision
	var sb: StaticBody3D = StaticBody3D.new()
	sb.position = Vector3(0, 2.10, 0)
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(6.50, 4.20, 0.30)
	cs.shape = cb
	sb.add_child(cs)
	mural.add_child(sb)


func _build_d6_holo_tower(geom: Node) -> void:
	## Epic-6 T76: tall hologram billboard tower with 3 stacked screens
	## displaying alternating colored ad blocks.
	var tower: Node3D = Node3D.new()
	tower.name = "HoloTower"
	tower.position = Vector3(D6_CENTER.x - 22.0, 0.0, -22.0)
	geom.add_child(tower)
	var metal_mat: StandardMaterial3D = StandardMaterial3D.new()
	metal_mat.albedo_color = Color(0.30, 0.30, 0.40)
	metal_mat.metallic = 0.85
	metal_mat.roughness = 0.30
	# Tall central support post
	var post: MeshInstance3D = MeshInstance3D.new()
	var pm: BoxMesh = BoxMesh.new()
	pm.size = Vector3(0.55, 9.50, 0.55)
	post.mesh = pm
	post.material_override = metal_mat
	post.position = Vector3(0, 4.75, 0)
	tower.add_child(post)
	# 3 stacked screens at different heights
	var screen_colors: Array = [
		Color(0.95, 0.20, 0.85),
		Color(0.30, 0.95, 0.55),
		Color(0.30, 0.65, 0.95),
	]
	for i in 3:
		var screen: MeshInstance3D = MeshInstance3D.new()
		var sm: BoxMesh = BoxMesh.new()
		sm.size = Vector3(2.85, 1.85, 0.18)
		screen.mesh = sm
		var screen_mat: StandardMaterial3D = StandardMaterial3D.new()
		screen_mat.albedo_color = screen_colors[i]
		screen_mat.emission_enabled = true
		screen_mat.emission = screen_colors[i]
		screen_mat.emission_energy_multiplier = 2.5
		screen_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		screen.material_override = screen_mat
		screen.position = Vector3(0, 2.40 + i * 2.40, 0.40)
		tower.add_child(screen)
		# Screen pulse
		var tw: Tween = screen.create_tween().set_loops()
		tw.tween_interval(i * 0.30)
		tw.tween_property(screen, "scale:y", 1.10, 0.55)
		tw.tween_property(screen, "scale:y", 0.85, 0.55)
		# Per-screen light
		var light: OmniLight3D = OmniLight3D.new()
		light.light_color = screen_colors[i]
		light.light_energy = 1.6
		light.omni_range = 5.0
		light.position = Vector3(0, 2.40 + i * 2.40, 1.20)
		tower.add_child(light)
	# Tower collision
	var sb: StaticBody3D = StaticBody3D.new()
	sb.position = Vector3(0, 4.75, 0)
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(0.55, 9.50, 0.55)
	cs.shape = cb
	sb.add_child(cs)
	tower.add_child(sb)


func _build_d6_drone_shop(geom: Node) -> void:
	## Epic-6 T77: drone repair shop — small workshop with 3 broken drones
	## hanging from racks and tool boxes scattered.
	var shop: Node3D = Node3D.new()
	shop.name = "DroneShop"
	shop.position = Vector3(D6_CENTER.x + 18.0, 0.0, -22.0)
	geom.add_child(shop)
	var dark_mat: StandardMaterial3D = StandardMaterial3D.new()
	dark_mat.albedo_color = Color(0.30, 0.30, 0.40)
	dark_mat.metallic = 0.55
	dark_mat.roughness = 0.45
	# Storefront wall
	var wall: MeshInstance3D = MeshInstance3D.new()
	var wm: BoxMesh = BoxMesh.new()
	wm.size = Vector3(4.20, 3.20, 0.30)
	wall.mesh = wm
	wall.material_override = dark_mat
	wall.position = Vector3(0, 1.60, -1.20)
	shop.add_child(wall)
	for sx in [-2.0, 2.0]:
		var side: MeshInstance3D = MeshInstance3D.new()
		var swm: BoxMesh = BoxMesh.new()
		swm.size = Vector3(0.30, 3.20, 2.40)
		side.mesh = swm
		side.material_override = dark_mat
		side.position = Vector3(sx, 1.60, 0)
		shop.add_child(side)
	# Roof
	var roof: MeshInstance3D = MeshInstance3D.new()
	var rm: BoxMesh = BoxMesh.new()
	rm.size = Vector3(4.20, 0.18, 2.55)
	roof.mesh = rm
	roof.material_override = dark_mat
	roof.position = Vector3(0, 3.30, 0)
	shop.add_child(roof)
	# 3 broken drones hanging from the ceiling
	var metal_mat: StandardMaterial3D = StandardMaterial3D.new()
	metal_mat.albedo_color = Color(0.40, 0.42, 0.50)
	metal_mat.metallic = 0.85
	for i in 3:
		var cable: MeshInstance3D = MeshInstance3D.new()
		var cmm: CylinderMesh = CylinderMesh.new()
		cmm.top_radius = 0.018
		cmm.bottom_radius = 0.018
		cmm.height = 1.0
		cable.mesh = cmm
		var cable_mat: StandardMaterial3D = StandardMaterial3D.new()
		cable_mat.albedo_color = Color(0.20, 0.20, 0.25)
		cable.material_override = cable_mat
		cable.position = Vector3(-1.20 + i * 1.20, 2.30, 0.30)
		shop.add_child(cable)
		# Drone body (sphere) — broken at angle
		var drone_body: MeshInstance3D = MeshInstance3D.new()
		var dbm: SphereMesh = SphereMesh.new()
		dbm.radius = 0.22
		dbm.height = 0.36
		drone_body.mesh = dbm
		drone_body.material_override = metal_mat
		drone_body.position = Vector3(-1.20 + i * 1.20, 1.55, 0.30)
		drone_body.rotation_degrees = Vector3(15, 0, 25)
		shop.add_child(drone_body)
	# Toolboxes (2 small boxes on the floor)
	var tool_mat: StandardMaterial3D = StandardMaterial3D.new()
	tool_mat.albedo_color = Color(0.85, 0.55, 0.20)
	tool_mat.metallic = 0.45
	for sx in [-0.85, 0.85]:
		var box: MeshInstance3D = MeshInstance3D.new()
		var bxm: BoxMesh = BoxMesh.new()
		bxm.size = Vector3(0.55, 0.30, 0.30)
		box.mesh = bxm
		box.material_override = tool_mat
		box.position = Vector3(sx, 0.15, 0.55)
		shop.add_child(box)
	# Sign
	var sign_mat: StandardMaterial3D = StandardMaterial3D.new()
	sign_mat.albedo_color = Color(0.30, 0.95, 1.0)
	sign_mat.emission_enabled = true
	sign_mat.emission = Color(0.30, 1.0, 1.0)
	sign_mat.emission_energy_multiplier = 2.5
	sign_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var sign: MeshInstance3D = MeshInstance3D.new()
	var snm: BoxMesh = BoxMesh.new()
	snm.size = Vector3(2.85, 0.55, 0.06)
	sign.mesh = snm
	sign.material_override = sign_mat
	sign.position = Vector3(0, 2.85, 1.21)
	shop.add_child(sign)
	var label: Label3D = Label3D.new()
	label.text = "DRONE FIX"
	label.modulate = Color(0.10, 0.05, 0.20)
	label.outline_modulate = Color(0.30, 1.0, 1.0)
	label.outline_size = 4
	label.font_size = 56
	label.pixel_size = 0.008
	label.position = Vector3(0, 2.85, 1.26)
	shop.add_child(label)
	# Light
	var light: OmniLight3D = OmniLight3D.new()
	light.light_color = Color(0.40, 0.95, 1.0)
	light.light_energy = 1.6
	light.omni_range = 4.5
	light.position = Vector3(0, 2.85, 1.85)
	shop.add_child(light)
	# Shop collision
	var sb: StaticBody3D = StaticBody3D.new()
	sb.position = Vector3(0, 1.60, 0)
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(4.20, 3.20, 2.55)
	cs.shape = cb
	sb.add_child(cs)
	shop.add_child(sb)


func _build_d6_drone_mechanic_npc(town: Node) -> void:
	## Epic-6 T78: drone mechanic NPC — coveralls + welding mask + holding
	## a small drone in their hand.
	var npc_slots: Node3D = town.get_node_or_null("%NPCSlots") as Node3D
	if npc_slots == null:
		return
	var slot: Marker3D = Marker3D.new()
	slot.name = "DroneMechanicSlot"
	slot.position = Vector3(D6_CENTER.x + 18.0, 0.0, -21.0)
	npc_slots.add_child(slot)
	var npc_scene: PackedScene = load("res://scenes/entities/npcs/VillagerR3.tscn") as PackedScene
	if npc_scene == null:
		return
	var npc: Node3D = npc_scene.instantiate() as Node3D
	npc.name = "DroneMechanic"
	if "npc_name" in npc:
		npc.set("npc_name", "Solder")
	if "npc_id" in npc:
		npc.set("npc_id", "drone_mech_d6")
	slot.add_child(npc)
	# Coveralls
	var suit: MeshInstance3D = MeshInstance3D.new()
	var sm: BoxMesh = BoxMesh.new()
	sm.size = Vector3(0.65, 1.20, 0.45)
	suit.mesh = sm
	var suit_mat: StandardMaterial3D = StandardMaterial3D.new()
	suit_mat.albedo_color = Color(0.40, 0.42, 0.50)
	suit_mat.metallic = 0.20
	suit_mat.roughness = 0.65
	suit.material_override = suit_mat
	suit.position = Vector3(0, 0.60, 0)
	npc.add_child(suit)
	# Welding mask
	var mask: MeshInstance3D = MeshInstance3D.new()
	var mm: BoxMesh = BoxMesh.new()
	mm.size = Vector3(0.42, 0.45, 0.04)
	mask.mesh = mm
	var mask_mat: StandardMaterial3D = StandardMaterial3D.new()
	mask_mat.albedo_color = Color(0.20, 0.18, 0.22)
	mask_mat.metallic = 0.85
	mask.material_override = mask_mat
	mask.position = Vector3(0, 1.42, 0.21)
	npc.add_child(mask)
	# Visor strip
	var visor: MeshInstance3D = MeshInstance3D.new()
	var vmm: BoxMesh = BoxMesh.new()
	vmm.size = Vector3(0.30, 0.08, 0.04)
	visor.mesh = vmm
	var visor_mat: StandardMaterial3D = StandardMaterial3D.new()
	visor_mat.albedo_color = Color(0.30, 1.0, 0.30)
	visor_mat.emission_enabled = true
	visor_mat.emission = Color(0.30, 1.0, 0.30)
	visor_mat.emission_energy_multiplier = 2.5
	visor_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	visor.material_override = visor_mat
	visor.position = Vector3(0, 1.45, 0.23)
	npc.add_child(visor)
	# Held drone (small dark sphere with cyan glow)
	var drone: MeshInstance3D = MeshInstance3D.new()
	var dm: SphereMesh = SphereMesh.new()
	dm.radius = 0.10
	dm.height = 0.18
	drone.mesh = dm
	var drone_mat: StandardMaterial3D = StandardMaterial3D.new()
	drone_mat.albedo_color = Color(0.40, 0.42, 0.50)
	drone_mat.metallic = 0.85
	drone_mat.emission_enabled = true
	drone_mat.emission = Color(0.30, 0.95, 1.0)
	drone_mat.emission_energy_multiplier = 0.85
	drone.material_override = drone_mat
	drone.position = Vector3(0.40, 0.85, 0.20)
	npc.add_child(drone)


func _build_d6_cyber_rats(geom: Node) -> void:
	## Epic-6 T79: 4 small cyber rats — dark furry bodies + magenta eyes
	## + tiny LED implants on their backs, slowly drifting through the alley.
	var rats: Node3D = Node3D.new()
	rats.name = "CyberRats"
	rats.position = Vector3(D6_CENTER.x + 24.0, 0.0, 4.0)
	geom.add_child(rats)
	var fur_mat: StandardMaterial3D = StandardMaterial3D.new()
	fur_mat.albedo_color = Color(0.18, 0.15, 0.20)
	fur_mat.roughness = 0.85
	for i in 4:
		var rat: Node3D = Node3D.new()
		rat.position = Vector3(
			randf_range(-2.5, 2.5),
			0,
			randf_range(-2.0, 2.0)
		)
		rats.add_child(rat)
		# Body
		var body: MeshInstance3D = MeshInstance3D.new()
		var bm: SphereMesh = SphereMesh.new()
		bm.radius = 0.14
		bm.height = 0.24
		body.mesh = bm
		body.material_override = fur_mat
		body.position = Vector3(0, 0.18, 0)
		body.scale = Vector3(0.85, 0.65, 1.40)
		rat.add_child(body)
		# LED implant (small magenta box on back)
		var led: MeshInstance3D = MeshInstance3D.new()
		var lm: BoxMesh = BoxMesh.new()
		lm.size = Vector3(0.06, 0.04, 0.06)
		led.mesh = lm
		var led_mat: StandardMaterial3D = StandardMaterial3D.new()
		led_mat.albedo_color = Color(0.95, 0.20, 0.85)
		led_mat.emission_enabled = true
		led_mat.emission = Color(0.95, 0.30, 0.95)
		led_mat.emission_energy_multiplier = 3.0
		led_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		led.material_override = led_mat
		led.position = Vector3(0, 0.32, 0)
		rat.add_child(led)
		# Magenta eyes
		var eye_mat: StandardMaterial3D = StandardMaterial3D.new()
		eye_mat.albedo_color = Color(0.95, 0.20, 0.85)
		eye_mat.emission_enabled = true
		eye_mat.emission = Color(0.95, 0.30, 0.95)
		eye_mat.emission_energy_multiplier = 3.0
		eye_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		for ex in [-0.04, 0.04]:
			var eye: MeshInstance3D = MeshInstance3D.new()
			var em: SphereMesh = SphereMesh.new()
			em.radius = 0.018
			em.height = 0.036
			eye.mesh = em
			eye.material_override = eye_mat
			eye.position = Vector3(ex, 0.22, 0.20)
			rat.add_child(eye)
		# Tail (curved cylinder)
		var tail: MeshInstance3D = MeshInstance3D.new()
		var tm: CylinderMesh = CylinderMesh.new()
		tm.top_radius = 0.018
		tm.bottom_radius = 0.025
		tm.height = 0.30
		tail.mesh = tm
		tail.material_override = fur_mat
		tail.position = Vector3(0, 0.18, -0.22)
		tail.rotation_degrees = Vector3(75, 0, 0)
		rat.add_child(tail)
		# Slow drift
		var tw: Tween = rat.create_tween().set_loops()
		var p: Vector3 = rat.position
		tw.tween_property(rat, "position", p + Vector3(randf_range(-1.5, 1.5), 0, randf_range(-1.5, 1.5)), 2.5 + randf())
		tw.tween_property(rat, "rotation_degrees:y", 180.0, 0.4)
		tw.tween_property(rat, "position", p, 2.5 + randf())
		tw.tween_property(rat, "rotation_degrees:y", 0.0, 0.4)


func _build_d6_scrap_pile(geom: Node) -> void:
	## Epic-6 T80: pile of scrap metal — random rusted boxes and pipes
	## stacked together with one glowing wire poking out.
	var pile: Node3D = Node3D.new()
	pile.name = "ScrapPile"
	pile.position = Vector3(D6_CENTER.x + 26.0, 0.0, 14.0)
	geom.add_child(pile)
	var rust_mat: StandardMaterial3D = StandardMaterial3D.new()
	rust_mat.albedo_color = Color(0.55, 0.30, 0.18)
	rust_mat.metallic = 0.55
	rust_mat.roughness = 0.85
	# 6 random scrap pieces
	for i in 6:
		var piece: MeshInstance3D = MeshInstance3D.new()
		if i % 2 == 0:
			var bm: BoxMesh = BoxMesh.new()
			bm.size = Vector3(0.55 + randf() * 0.30, 0.30, 0.40)
			piece.mesh = bm
		else:
			var cm: CylinderMesh = CylinderMesh.new()
			cm.top_radius = 0.10
			cm.bottom_radius = 0.10
			cm.height = 0.85 + randf() * 0.30
			piece.mesh = cm
		piece.material_override = rust_mat
		piece.position = Vector3(
			randf_range(-0.55, 0.55),
			0.30 + i * 0.18,
			randf_range(-0.30, 0.30)
		)
		piece.rotation_degrees = Vector3(
			randf_range(-30, 30),
			randf_range(0, 360),
			randf_range(-30, 30)
		)
		pile.add_child(piece)
	# Glowing wire poking out (small bright cylinder)
	var wire: MeshInstance3D = MeshInstance3D.new()
	var wm: CylinderMesh = CylinderMesh.new()
	wm.top_radius = 0.025
	wm.bottom_radius = 0.025
	wm.height = 0.55
	wire.mesh = wm
	var wire_mat: StandardMaterial3D = StandardMaterial3D.new()
	wire_mat.albedo_color = Color(0.30, 0.95, 1.0)
	wire_mat.emission_enabled = true
	wire_mat.emission = Color(0.30, 1.0, 1.0)
	wire_mat.emission_energy_multiplier = 3.5
	wire_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	wire.material_override = wire_mat
	wire.position = Vector3(0.20, 1.40, 0)
	wire.rotation_degrees = Vector3(0, 0, 30)
	pile.add_child(wire)
	# Subtle wire spark light
	var light: OmniLight3D = OmniLight3D.new()
	light.light_color = Color(0.40, 0.95, 1.0)
	light.light_energy = 1.0
	light.omni_range = 2.5
	light.position = Vector3(0.20, 1.40, 0)
	pile.add_child(light)
	# Pile collision
	var sb: StaticBody3D = StaticBody3D.new()
	sb.position = Vector3(0, 0.85, 0)
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(1.40, 1.85, 1.10)
	cs.shape = cb
	sb.add_child(cs)
	pile.add_child(sb)


func _build_d6_cyber_cafe(geom: Node) -> void:
	## Epic-6 T81: cyber café — open storefront with row of 4 terminal
	## stations + colored counter + signage.
	var cafe: Node3D = Node3D.new()
	cafe.name = "CyberCafe"
	cafe.position = Vector3(D6_CENTER.x - 18.0, 0.0, 22.0)
	geom.add_child(cafe)
	var dark_mat: StandardMaterial3D = StandardMaterial3D.new()
	dark_mat.albedo_color = Color(0.18, 0.15, 0.25)
	dark_mat.metallic = 0.30
	dark_mat.roughness = 0.55
	# Counter
	var counter: MeshInstance3D = MeshInstance3D.new()
	var cm: BoxMesh = BoxMesh.new()
	cm.size = Vector3(5.50, 1.0, 1.10)
	counter.mesh = cm
	counter.material_override = dark_mat
	counter.position = Vector3(0, 0.55, 0)
	cafe.add_child(counter)
	# 4 terminal stations on the counter
	var screen_colors: Array = [
		Color(0.30, 0.95, 0.55),
		Color(0.30, 0.65, 0.95),
		Color(0.95, 0.20, 0.85),
		Color(0.95, 0.85, 0.20),
	]
	for i in 4:
		# Terminal monitor
		var monitor: MeshInstance3D = MeshInstance3D.new()
		var mm: BoxMesh = BoxMesh.new()
		mm.size = Vector3(0.85, 0.65, 0.18)
		monitor.mesh = mm
		monitor.material_override = dark_mat
		monitor.position = Vector3(-1.85 + i * 1.30, 1.55, -0.20)
		cafe.add_child(monitor)
		# Screen
		var screen: MeshInstance3D = MeshInstance3D.new()
		var sm: BoxMesh = BoxMesh.new()
		sm.size = Vector3(0.75, 0.55, 0.04)
		screen.mesh = sm
		var screen_mat: StandardMaterial3D = StandardMaterial3D.new()
		screen_mat.albedo_color = screen_colors[i]
		screen_mat.emission_enabled = true
		screen_mat.emission = screen_colors[i]
		screen_mat.emission_energy_multiplier = 2.5
		screen_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		screen.material_override = screen_mat
		screen.position = Vector3(-1.85 + i * 1.30, 1.55, -0.10)
		cafe.add_child(screen)
		# Keyboard (small dark box on counter)
		var kb: MeshInstance3D = MeshInstance3D.new()
		var kbm: BoxMesh = BoxMesh.new()
		kbm.size = Vector3(0.85, 0.06, 0.30)
		kb.mesh = kbm
		var kb_mat: StandardMaterial3D = StandardMaterial3D.new()
		kb_mat.albedo_color = Color(0.10, 0.08, 0.12)
		kb_mat.metallic = 0.65
		kb.material_override = kb_mat
		kb.position = Vector3(-1.85 + i * 1.30, 1.10, 0.30)
		cafe.add_child(kb)
		# Screen flicker
		var tw: Tween = screen.create_tween().set_loops()
		tw.tween_interval(i * 0.15)
		tw.tween_property(screen, "scale:y", 1.10, 0.35)
		tw.tween_property(screen, "scale:y", 0.85, 0.35)
	# Sign on top
	var sign: MeshInstance3D = MeshInstance3D.new()
	var snm: BoxMesh = BoxMesh.new()
	snm.size = Vector3(4.20, 0.55, 0.10)
	sign.mesh = snm
	var sign_mat: StandardMaterial3D = StandardMaterial3D.new()
	sign_mat.albedo_color = Color(0.30, 0.95, 1.0)
	sign_mat.emission_enabled = true
	sign_mat.emission = Color(0.30, 1.0, 1.0)
	sign_mat.emission_energy_multiplier = 3.0
	sign_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	sign.material_override = sign_mat
	sign.position = Vector3(0, 2.55, -0.50)
	cafe.add_child(sign)
	var label: Label3D = Label3D.new()
	label.text = "NETCAFE"
	label.modulate = Color(0.05, 0.10, 0.20)
	label.outline_modulate = Color(0.30, 1.0, 1.0)
	label.outline_size = 4
	label.font_size = 64
	label.pixel_size = 0.009
	label.position = Vector3(0, 2.55, -0.42)
	cafe.add_child(label)
	# Light
	var light: OmniLight3D = OmniLight3D.new()
	light.light_color = Color(0.40, 0.95, 1.0)
	light.light_energy = 2.0
	light.omni_range = 6.0
	light.position = Vector3(0, 2.20, 0)
	cafe.add_child(light)
	# Counter collision
	var sb: StaticBody3D = StaticBody3D.new()
	sb.position = Vector3(0, 1.10, 0)
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(5.50, 2.20, 1.10)
	cs.shape = cb
	sb.add_child(cs)
	cafe.add_child(sb)


func _build_d6_cafe_customer_npc(town: Node) -> void:
	## Epic-6 T82: cafe customer NPC at one of the terminals — large
	## headphones + bright t-shirt.
	var npc_slots: Node3D = town.get_node_or_null("%NPCSlots") as Node3D
	if npc_slots == null:
		return
	var slot: Marker3D = Marker3D.new()
	slot.name = "CafeCustomerSlot"
	slot.position = Vector3(D6_CENTER.x - 17.0, 0.0, 22.5)
	npc_slots.add_child(slot)
	var npc_scene: PackedScene = load("res://scenes/entities/npcs/VillagerR3.tscn") as PackedScene
	if npc_scene == null:
		return
	var npc: Node3D = npc_scene.instantiate() as Node3D
	npc.name = "CafeCustomer"
	if "npc_name" in npc:
		npc.set("npc_name", "Lurker")
	if "npc_id" in npc:
		npc.set("npc_id", "cafe_d6")
	slot.add_child(npc)
	# Bright cyan t-shirt
	var shirt: MeshInstance3D = MeshInstance3D.new()
	var sm: BoxMesh = BoxMesh.new()
	sm.size = Vector3(0.65, 0.95, 0.40)
	shirt.mesh = sm
	var shirt_mat: StandardMaterial3D = StandardMaterial3D.new()
	shirt_mat.albedo_color = Color(0.30, 0.95, 1.0)
	shirt_mat.emission_enabled = true
	shirt_mat.emission = Color(0.30, 0.95, 1.0)
	shirt_mat.emission_energy_multiplier = 0.30
	shirt.material_override = shirt_mat
	shirt.position = Vector3(0, 0.55, 0)
	npc.add_child(shirt)
	# Large headphones (2 connected discs)
	var hp_mat: StandardMaterial3D = StandardMaterial3D.new()
	hp_mat.albedo_color = Color(0.20, 0.18, 0.25)
	hp_mat.metallic = 0.85
	hp_mat.roughness = 0.30
	for sx in [-0.22, 0.22]:
		var cup: MeshInstance3D = MeshInstance3D.new()
		var cm: CylinderMesh = CylinderMesh.new()
		cm.top_radius = 0.10
		cm.bottom_radius = 0.10
		cm.height = 0.06
		cup.mesh = cm
		cup.material_override = hp_mat
		cup.position = Vector3(sx, 1.40, 0)
		cup.rotation_degrees = Vector3(0, 0, 90)
		npc.add_child(cup)
	# Headphone arc (small torus)
	var arc: MeshInstance3D = MeshInstance3D.new()
	var arm: TorusMesh = TorusMesh.new()
	arm.inner_radius = 0.16
	arm.outer_radius = 0.20
	arc.mesh = arm
	arc.material_override = hp_mat
	arc.position = Vector3(0, 1.55, 0)
	arc.rotation_degrees = Vector3(0, 0, 90)
	arc.scale = Vector3(1.0, 0.40, 1.0)
	npc.add_child(arc)


func _build_d6_dj_booth(geom: Node) -> void:
	## Epic-6 T83: street DJ booth — turntable + 2 large speakers + a
	## glowing equalizer panel.
	var booth: Node3D = Node3D.new()
	booth.name = "DJBooth"
	booth.position = Vector3(D6_CENTER.x + 4.0, 0.0, 22.0)
	geom.add_child(booth)
	var dark_mat: StandardMaterial3D = StandardMaterial3D.new()
	dark_mat.albedo_color = Color(0.10, 0.10, 0.15)
	dark_mat.metallic = 0.85
	dark_mat.roughness = 0.30
	# Booth counter
	var counter: MeshInstance3D = MeshInstance3D.new()
	var cm: BoxMesh = BoxMesh.new()
	cm.size = Vector3(2.85, 1.0, 0.85)
	counter.mesh = cm
	counter.material_override = dark_mat
	counter.position = Vector3(0, 0.55, 0)
	booth.add_child(counter)
	# Turntable (large disc on counter)
	var turntable: MeshInstance3D = MeshInstance3D.new()
	var tm: CylinderMesh = CylinderMesh.new()
	tm.top_radius = 0.40
	tm.bottom_radius = 0.40
	tm.height = 0.06
	turntable.mesh = tm
	var disc_mat: StandardMaterial3D = StandardMaterial3D.new()
	disc_mat.albedo_color = Color(0.15, 0.12, 0.18)
	disc_mat.metallic = 0.55
	turntable.material_override = disc_mat
	turntable.position = Vector3(0, 1.10, 0)
	booth.add_child(turntable)
	# Center spindle (small magenta sphere)
	var spindle: MeshInstance3D = MeshInstance3D.new()
	var spm: SphereMesh = SphereMesh.new()
	spm.radius = 0.05
	spm.height = 0.10
	spindle.mesh = spm
	var spin_mat: StandardMaterial3D = StandardMaterial3D.new()
	spin_mat.albedo_color = Color(0.95, 0.20, 0.85)
	spin_mat.emission_enabled = true
	spin_mat.emission = Color(0.95, 0.20, 0.85)
	spin_mat.emission_energy_multiplier = 3.0
	spin_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	spindle.material_override = spin_mat
	spindle.position = Vector3(0, 1.16, 0)
	booth.add_child(spindle)
	# Spin tween on the turntable
	var tw: Tween = turntable.create_tween().set_loops()
	tw.tween_property(turntable, "rotation_degrees:y", 360.0, 1.6)
	tw.tween_property(turntable, "rotation_degrees:y", 0.0, 0.0)
	# 2 large speakers flanking
	for sx in [-2.40, 2.40]:
		var speaker: MeshInstance3D = MeshInstance3D.new()
		var sm: BoxMesh = BoxMesh.new()
		sm.size = Vector3(0.85, 1.85, 0.85)
		speaker.mesh = sm
		speaker.material_override = dark_mat
		speaker.position = Vector3(sx, 0.95, 0)
		booth.add_child(speaker)
		# 2 cones on the front
		for cy in [1.20, 0.65]:
			var cone: MeshInstance3D = MeshInstance3D.new()
			var cn_m: SphereMesh = SphereMesh.new()
			cn_m.radius = 0.18
			cn_m.height = 0.30
			cone.mesh = cn_m
			var cone_mat: StandardMaterial3D = StandardMaterial3D.new()
			cone_mat.albedo_color = Color(0.20, 0.18, 0.22)
			cone.material_override = cone_mat
			cone.position = Vector3(sx, cy, 0.42)
			cone.scale = Vector3(1.0, 1.0, 0.30)
			booth.add_child(cone)
			# Bass pulse tween
			var ts: Tween = cone.create_tween().set_loops()
			ts.tween_property(cone, "scale", Vector3(1.10, 1.10, 0.45), 0.20)
			ts.tween_property(cone, "scale", Vector3(0.90, 0.90, 0.30), 0.20)
		# Speaker collision
		var sb_spk: StaticBody3D = StaticBody3D.new()
		sb_spk.position = Vector3(sx, 0.95, 0)
		var cs_spk: CollisionShape3D = CollisionShape3D.new()
		var cb_spk: BoxShape3D = BoxShape3D.new()
		cb_spk.size = Vector3(0.85, 1.85, 0.85)
		cs_spk.shape = cb_spk
		sb_spk.add_child(cs_spk)
		booth.add_child(sb_spk)
	# Equalizer panel — 12 colored bars on the booth front
	var bar_colors: Array = [
		Color(0.30, 0.95, 1.0),
		Color(0.95, 0.20, 0.85),
	]
	for i in 12:
		var bar: MeshInstance3D = MeshInstance3D.new()
		var bm: BoxMesh = BoxMesh.new()
		bm.size = Vector3(0.10, 0.55, 0.04)
		bar.mesh = bm
		var bar_mat: StandardMaterial3D = StandardMaterial3D.new()
		bar_mat.albedo_color = bar_colors[i % 2]
		bar_mat.emission_enabled = true
		bar_mat.emission = bar_colors[i % 2]
		bar_mat.emission_energy_multiplier = 2.5
		bar_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		bar.material_override = bar_mat
		bar.position = Vector3(-1.20 + i * 0.22, 0.65, 0.45)
		booth.add_child(bar)
		# Equalizer flicker
		var tw_eq: Tween = bar.create_tween().set_loops()
		tw_eq.tween_interval(i * 0.05)
		tw_eq.tween_property(bar, "scale:y", randf_range(0.40, 1.40), 0.15)
		tw_eq.tween_property(bar, "scale:y", randf_range(0.40, 1.40), 0.15)
	# Light
	var light: OmniLight3D = OmniLight3D.new()
	light.light_color = Color(1.0, 0.30, 0.85)
	light.light_energy = 2.5
	light.omni_range = 6.0
	light.position = Vector3(0, 1.85, 0.85)
	booth.add_child(light)
	# Booth collision
	var sb: StaticBody3D = StaticBody3D.new()
	sb.position = Vector3(0, 0.55, 0)
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(2.85, 1.0, 0.85)
	cs.shape = cb
	sb.add_child(cs)
	booth.add_child(sb)


func _build_d6_street_dj_npc(town: Node) -> void:
	## Epic-6 T84: street DJ NPC behind the booth — bright jacket +
	## headphones + raised hand on a turntable.
	var npc_slots: Node3D = town.get_node_or_null("%NPCSlots") as Node3D
	if npc_slots == null:
		return
	var slot: Marker3D = Marker3D.new()
	slot.name = "StreetDJSlot"
	slot.position = Vector3(D6_CENTER.x + 4.0, 0.0, 21.0)
	npc_slots.add_child(slot)
	var npc_scene: PackedScene = load("res://scenes/entities/npcs/VillagerR3.tscn") as PackedScene
	if npc_scene == null:
		return
	var npc: Node3D = npc_scene.instantiate() as Node3D
	npc.name = "StreetDJ"
	if "npc_name" in npc:
		npc.set("npc_name", "Beatdrop")
	if "npc_id" in npc:
		npc.set("npc_id", "dj_d6")
	slot.add_child(npc)
	# Holographic jacket
	var jacket: MeshInstance3D = MeshInstance3D.new()
	var jm: BoxMesh = BoxMesh.new()
	jm.size = Vector3(0.65, 1.05, 0.40)
	jacket.mesh = jm
	var jacket_mat: StandardMaterial3D = StandardMaterial3D.new()
	jacket_mat.albedo_color = Color(0.30, 0.95, 0.55)
	jacket_mat.emission_enabled = true
	jacket_mat.emission = Color(0.30, 1.0, 0.55)
	jacket_mat.emission_energy_multiplier = 0.55
	jacket.material_override = jacket_mat
	jacket.position = Vector3(0, 0.55, 0)
	npc.add_child(jacket)
	# Headphones (2 cylinders + arc)
	var hp_mat: StandardMaterial3D = StandardMaterial3D.new()
	hp_mat.albedo_color = Color(0.10, 0.08, 0.12)
	hp_mat.metallic = 0.85
	for sx in [-0.22, 0.22]:
		var cup: MeshInstance3D = MeshInstance3D.new()
		var cm: CylinderMesh = CylinderMesh.new()
		cm.top_radius = 0.10
		cm.bottom_radius = 0.10
		cm.height = 0.06
		cup.mesh = cm
		cup.material_override = hp_mat
		cup.position = Vector3(sx, 1.40, 0)
		cup.rotation_degrees = Vector3(0, 0, 90)
		npc.add_child(cup)
	# Sway tween (DJ-ing)
	var tw: Tween = npc.create_tween().set_loops()
	tw.tween_property(npc, "rotation_degrees:z", 6.0, 0.30)
	tw.tween_property(npc, "rotation_degrees:z", -6.0, 0.30)


func _build_d6_glow_drones(geom: Node) -> void:
	## Epic-6 T85: 8 small glow drones drifting through the bazaar at
	## varying altitudes — bright colored orbs with halos.
	var swarm: Node3D = Node3D.new()
	swarm.name = "GlowDrones"
	swarm.position = Vector3(D6_CENTER.x, 4.0, 0.0)
	geom.add_child(swarm)
	var drone_colors: Array = [
		Color(0.95, 0.20, 0.85),
		Color(0.30, 0.95, 1.0),
		Color(0.30, 0.95, 0.55),
		Color(0.95, 0.85, 0.20),
		Color(0.55, 0.30, 0.95),
		Color(0.95, 0.30, 0.30),
		Color(0.30, 0.65, 0.95),
		Color(0.95, 0.95, 0.30),
	]
	for i in 8:
		var pivot: Node3D = Node3D.new()
		pivot.position = Vector3(0, randf_range(-1.0, 2.5), 0)
		pivot.rotation_degrees = Vector3(0, i * 45.0, 0)
		swarm.add_child(pivot)
		var drone: MeshInstance3D = MeshInstance3D.new()
		var dmm: SphereMesh = SphereMesh.new()
		dmm.radius = 0.18
		dmm.height = 0.32
		drone.mesh = dmm
		var drone_mat: StandardMaterial3D = StandardMaterial3D.new()
		drone_mat.albedo_color = drone_colors[i]
		drone_mat.emission_enabled = true
		drone_mat.emission = drone_colors[i]
		drone_mat.emission_energy_multiplier = 4.0
		drone_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		drone.material_override = drone_mat
		drone.position = Vector3(8.0 + i * 1.20, 0, 0)
		pivot.add_child(drone)
		# Per-drone halo light
		var light: OmniLight3D = OmniLight3D.new()
		light.light_color = drone_colors[i]
		light.light_energy = 1.0
		light.omni_range = 2.0
		light.position = Vector3.ZERO
		drone.add_child(light)
		# Patrol rotation
		var trot: Tween = pivot.create_tween().set_loops()
		trot.tween_property(pivot, "rotation_degrees:y", i * 45.0 + 360.0, 12.0 + i * 0.4)
		trot.tween_property(pivot, "rotation_degrees:y", i * 45.0, 0.0)
		# Bob
		var tb: Tween = drone.create_tween().set_loops()
		tb.tween_property(drone, "position:y", 0.65, 1.4 + randf() * 0.4)
		tb.tween_property(drone, "position:y", -0.20, 1.4 + randf() * 0.4)


func _build_d6_city_map_terminal(geom: Node) -> void:
	## Epic-6 T86: free-standing city map terminal — slim metal box +
	## angled cyan map screen + city grid pattern.
	var term: Node3D = Node3D.new()
	term.name = "CityMapTerminal"
	term.position = Vector3(D6_CENTER.x - 32.0, 0.0, 12.0)
	geom.add_child(term)
	var metal_mat: StandardMaterial3D = StandardMaterial3D.new()
	metal_mat.albedo_color = Color(0.30, 0.32, 0.40)
	metal_mat.metallic = 0.85
	metal_mat.roughness = 0.30
	# Pedestal column
	var col: MeshInstance3D = MeshInstance3D.new()
	var clm: BoxMesh = BoxMesh.new()
	clm.size = Vector3(0.55, 1.20, 0.40)
	col.mesh = clm
	col.material_override = metal_mat
	col.position = Vector3(0, 0.60, 0)
	term.add_child(col)
	# Angled screen housing
	var housing: MeshInstance3D = MeshInstance3D.new()
	var hm: BoxMesh = BoxMesh.new()
	hm.size = Vector3(1.10, 0.85, 0.18)
	housing.mesh = hm
	housing.material_override = metal_mat
	housing.position = Vector3(0, 1.55, 0.18)
	housing.rotation_degrees = Vector3(-30, 0, 0)
	term.add_child(housing)
	# Glowing map screen
	var screen: MeshInstance3D = MeshInstance3D.new()
	var sm: BoxMesh = BoxMesh.new()
	sm.size = Vector3(0.95, 0.75, 0.04)
	screen.mesh = sm
	var screen_mat: StandardMaterial3D = StandardMaterial3D.new()
	screen_mat.albedo_color = Color(0.10, 0.20, 0.30)
	screen_mat.emission_enabled = true
	screen_mat.emission = Color(0.30, 0.55, 0.95)
	screen_mat.emission_energy_multiplier = 1.4
	screen_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	screen.material_override = screen_mat
	screen.position = Vector3(0, 1.55, 0.30)
	screen.rotation_degrees = Vector3(-30, 0, 0)
	term.add_child(screen)
	# 6 city grid lines on the screen (white emissive cross-hatch)
	var line_mat: StandardMaterial3D = StandardMaterial3D.new()
	line_mat.albedo_color = Color(0.95, 0.95, 1.0)
	line_mat.emission_enabled = true
	line_mat.emission = Color(0.95, 0.95, 1.0)
	line_mat.emission_energy_multiplier = 2.5
	line_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for i in 3:
		# Horizontal lines
		var hl: MeshInstance3D = MeshInstance3D.new()
		var hlm: BoxMesh = BoxMesh.new()
		hlm.size = Vector3(0.85, 0.02, 0.02)
		hl.mesh = hlm
		hl.material_override = line_mat
		hl.position = Vector3(0, 1.55 + (i - 1) * 0.20, 0.32)
		hl.rotation_degrees = Vector3(-30, 0, 0)
		term.add_child(hl)
		# Vertical lines
		var vl: MeshInstance3D = MeshInstance3D.new()
		var vlm: BoxMesh = BoxMesh.new()
		vlm.size = Vector3(0.02, 0.65, 0.02)
		vl.mesh = vlm
		vl.material_override = line_mat
		vl.position = Vector3(-0.30 + i * 0.30, 1.55, 0.32)
		vl.rotation_degrees = Vector3(-30, 0, 0)
		term.add_child(vl)
	# 4 location dots (you-are-here marker + 3 districts)
	var dot_colors: Array = [
		Color(0.30, 0.95, 0.55),
		Color(0.55, 0.30, 0.95),
		Color(0.95, 0.30, 0.85),
		Color(0.30, 0.65, 0.95),
	]
	for i in 4:
		var dot: MeshInstance3D = MeshInstance3D.new()
		var dmm: SphereMesh = SphereMesh.new()
		dmm.radius = 0.05
		dmm.height = 0.10
		dot.mesh = dmm
		var dot_mat: StandardMaterial3D = StandardMaterial3D.new()
		dot_mat.albedo_color = dot_colors[i]
		dot_mat.emission_enabled = true
		dot_mat.emission = dot_colors[i]
		dot_mat.emission_energy_multiplier = 3.5
		dot_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		dot.material_override = dot_mat
		dot.position = Vector3(-0.30 + (i % 2) * 0.55, 1.55 + (i / 2) * 0.20, 0.34)
		dot.rotation_degrees = Vector3(-30, 0, 0)
		term.add_child(dot)
	# Light
	var light: OmniLight3D = OmniLight3D.new()
	light.light_color = Color(0.30, 0.65, 1.0)
	light.light_energy = 1.6
	light.omni_range = 4.0
	light.position = Vector3(0, 1.85, 0.65)
	term.add_child(light)
	# Terminal collision
	var sb: StaticBody3D = StaticBody3D.new()
	sb.position = Vector3(0, 1.0, 0)
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(0.55, 2.0, 0.65)
	cs.shape = cb
	sb.add_child(cs)
	term.add_child(sb)


func _build_d6_tour_guide_npc(town: Node) -> void:
	## Epic-6 T87: tour guide NPC by the city map — bright shirt + raised
	## arm holding a flag.
	var npc_slots: Node3D = town.get_node_or_null("%NPCSlots") as Node3D
	if npc_slots == null:
		return
	var slot: Marker3D = Marker3D.new()
	slot.name = "TourGuideSlot"
	slot.position = Vector3(D6_CENTER.x - 30.0, 0.0, 12.0)
	npc_slots.add_child(slot)
	var npc_scene: PackedScene = load("res://scenes/entities/npcs/VillagerR3.tscn") as PackedScene
	if npc_scene == null:
		return
	var npc: Node3D = npc_scene.instantiate() as Node3D
	npc.name = "TourGuide"
	if "npc_name" in npc:
		npc.set("npc_name", "Vista")
	if "npc_id" in npc:
		npc.set("npc_id", "tour_d6")
	slot.add_child(npc)
	# Bright orange shirt
	var shirt: MeshInstance3D = MeshInstance3D.new()
	var sm: BoxMesh = BoxMesh.new()
	sm.size = Vector3(0.65, 1.05, 0.40)
	shirt.mesh = sm
	var shirt_mat: StandardMaterial3D = StandardMaterial3D.new()
	shirt_mat.albedo_color = Color(0.95, 0.55, 0.20)
	shirt_mat.emission_enabled = true
	shirt_mat.emission = Color(0.95, 0.55, 0.20)
	shirt_mat.emission_energy_multiplier = 0.45
	shirt.material_override = shirt_mat
	shirt.position = Vector3(0, 0.55, 0)
	npc.add_child(shirt)
	# Tall flagpole
	var pole: MeshInstance3D = MeshInstance3D.new()
	var pm: CylinderMesh = CylinderMesh.new()
	pm.top_radius = 0.025
	pm.bottom_radius = 0.025
	pm.height = 1.85
	pole.mesh = pm
	var pole_mat: StandardMaterial3D = StandardMaterial3D.new()
	pole_mat.albedo_color = Color(0.30, 0.32, 0.40)
	pole_mat.metallic = 0.85
	pole.material_override = pole_mat
	pole.position = Vector3(0.45, 1.40, 0)
	npc.add_child(pole)
	# Flag (small red box at top)
	var flag: MeshInstance3D = MeshInstance3D.new()
	var fm: BoxMesh = BoxMesh.new()
	fm.size = Vector3(0.40, 0.30, 0.04)
	flag.mesh = fm
	var flag_mat: StandardMaterial3D = StandardMaterial3D.new()
	flag_mat.albedo_color = Color(0.95, 0.20, 0.30)
	flag_mat.emission_enabled = true
	flag_mat.emission = Color(0.95, 0.20, 0.30)
	flag_mat.emission_energy_multiplier = 0.85
	flag.material_override = flag_mat
	flag.position = Vector3(0.65, 2.10, 0)
	npc.add_child(flag)
	# Wave the flag
	var tw: Tween = flag.create_tween().set_loops()
	tw.tween_property(flag, "rotation_degrees:z", 8.0, 0.55)
	tw.tween_property(flag, "rotation_degrees:z", -8.0, 0.55)


func _build_d6_protest_banner(geom: Node) -> void:
	## Epic-6 T88: holographic protest banner — large translucent panel
	## with bold "FREE THE DATA" message and 2 vertical glow accents.
	var banner: Node3D = Node3D.new()
	banner.name = "ProtestBanner"
	banner.position = Vector3(D6_CENTER.x - 8.0, 0.0, 0.0)
	geom.add_child(banner)
	var metal_mat: StandardMaterial3D = StandardMaterial3D.new()
	metal_mat.albedo_color = Color(0.30, 0.30, 0.40)
	metal_mat.metallic = 0.85
	# 2 carrying poles
	for sx in [-1.85, 1.85]:
		var pole: MeshInstance3D = MeshInstance3D.new()
		var pm: CylinderMesh = CylinderMesh.new()
		pm.top_radius = 0.06
		pm.bottom_radius = 0.06
		pm.height = 2.85
		pole.mesh = pm
		pole.material_override = metal_mat
		pole.position = Vector3(sx, 1.42, 0)
		banner.add_child(pole)
	# Banner cloth (translucent red)
	var cloth: MeshInstance3D = MeshInstance3D.new()
	var cm: BoxMesh = BoxMesh.new()
	cm.size = Vector3(3.85, 1.40, 0.06)
	cloth.mesh = cm
	var cloth_mat: StandardMaterial3D = StandardMaterial3D.new()
	cloth_mat.albedo_color = Color(0.85, 0.20, 0.30, 0.85)
	cloth_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	cloth_mat.emission_enabled = true
	cloth_mat.emission = Color(0.95, 0.20, 0.30)
	cloth_mat.emission_energy_multiplier = 1.4
	cloth_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	cloth.material_override = cloth_mat
	cloth.position = Vector3(0, 2.10, 0)
	banner.add_child(cloth)
	# Label3D
	var label: Label3D = Label3D.new()
	label.text = "FREE THE DATA"
	label.modulate = Color(0.95, 0.95, 1.0)
	label.outline_modulate = Color(0.20, 0.05, 0.10)
	label.outline_size = 8
	label.font_size = 64
	label.pixel_size = 0.011
	label.position = Vector3(0, 2.10, 0.05)
	banner.add_child(label)
	# 2 vertical glow accents
	var glow_mat: StandardMaterial3D = StandardMaterial3D.new()
	glow_mat.albedo_color = Color(0.95, 0.85, 0.20)
	glow_mat.emission_enabled = true
	glow_mat.emission = Color(0.95, 0.85, 0.20)
	glow_mat.emission_energy_multiplier = 3.0
	glow_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for sx in [-1.85, 1.85]:
		var glow: MeshInstance3D = MeshInstance3D.new()
		var gmm: BoxMesh = BoxMesh.new()
		gmm.size = Vector3(0.06, 1.40, 0.06)
		glow.mesh = gmm
		glow.material_override = glow_mat
		glow.position = Vector3(sx, 2.10, 0.04)
		banner.add_child(glow)
	# Pole collisions
	for sx in [-1.85, 1.85]:
		var sb: StaticBody3D = StaticBody3D.new()
		sb.position = Vector3(sx, 1.42, 0)
		var cs: CollisionShape3D = CollisionShape3D.new()
		var cap: CapsuleShape3D = CapsuleShape3D.new()
		cap.radius = 0.10
		cap.height = 2.85
		cs.shape = cap
		sb.add_child(cs)
		banner.add_child(sb)


func _build_d6_protester_npc(town: Node) -> void:
	## Epic-6 T89: protester NPC — raised fist + black bandana over face.
	var npc_slots: Node3D = town.get_node_or_null("%NPCSlots") as Node3D
	if npc_slots == null:
		return
	var slot: Marker3D = Marker3D.new()
	slot.name = "ProtesterSlot"
	slot.position = Vector3(D6_CENTER.x - 8.0, 0.0, 1.5)
	npc_slots.add_child(slot)
	var npc_scene: PackedScene = load("res://scenes/entities/npcs/VillagerR3.tscn") as PackedScene
	if npc_scene == null:
		return
	var npc: Node3D = npc_scene.instantiate() as Node3D
	npc.name = "Protester"
	if "npc_name" in npc:
		npc.set("npc_name", "Riot")
	if "npc_id" in npc:
		npc.set("npc_id", "protest_d6")
	slot.add_child(npc)
	# Black hoodie
	var hoodie: MeshInstance3D = MeshInstance3D.new()
	var hm: BoxMesh = BoxMesh.new()
	hm.size = Vector3(0.65, 1.05, 0.45)
	hoodie.mesh = hm
	var hoodie_mat: StandardMaterial3D = StandardMaterial3D.new()
	hoodie_mat.albedo_color = Color(0.10, 0.08, 0.12)
	hoodie_mat.roughness = 0.85
	hoodie.material_override = hoodie_mat
	hoodie.position = Vector3(0, 0.55, 0)
	npc.add_child(hoodie)
	# Black bandana over face
	var bandana: MeshInstance3D = MeshInstance3D.new()
	var bm: BoxMesh = BoxMesh.new()
	bm.size = Vector3(0.42, 0.18, 0.06)
	bandana.mesh = bm
	bandana.material_override = hoodie_mat
	bandana.position = Vector3(0, 1.30, 0.21)
	npc.add_child(bandana)
	# Raised fist (small box arm)
	var arm: MeshInstance3D = MeshInstance3D.new()
	var am: BoxMesh = BoxMesh.new()
	am.size = Vector3(0.18, 0.55, 0.18)
	arm.mesh = am
	arm.material_override = hoodie_mat
	arm.position = Vector3(0.20, 1.55, 0)
	npc.add_child(arm)
	var fist: MeshInstance3D = MeshInstance3D.new()
	var fm: SphereMesh = SphereMesh.new()
	fm.radius = 0.12
	fm.height = 0.22
	fist.mesh = fm
	var skin_mat: StandardMaterial3D = StandardMaterial3D.new()
	skin_mat.albedo_color = Color(0.95, 0.85, 0.75)
	fist.material_override = skin_mat
	fist.position = Vector3(0.20, 1.85, 0)
	npc.add_child(fist)
	# Pump fist tween
	var tw: Tween = arm.create_tween().set_loops()
	tw.tween_property(arm, "position:y", 1.65, 0.30)
	tw.tween_property(arm, "position:y", 1.55, 0.30)


func _build_d6_data_exchange_kiosk(geom: Node) -> void:
	## Epic-6 T90: data exchange kiosk — black market style. Tall narrow
	## stand with cyan currency-rate display + mysterious dark slit.
	var kiosk: Node3D = Node3D.new()
	kiosk.name = "DataExchangeKiosk"
	kiosk.position = Vector3(D6_CENTER.x + 22.0, 0.0, 22.0)
	geom.add_child(kiosk)
	var dark_mat: StandardMaterial3D = StandardMaterial3D.new()
	dark_mat.albedo_color = Color(0.10, 0.08, 0.18)
	dark_mat.metallic = 0.85
	dark_mat.roughness = 0.30
	# Tall stand
	var stand: MeshInstance3D = MeshInstance3D.new()
	var sm: BoxMesh = BoxMesh.new()
	sm.size = Vector3(0.85, 2.85, 0.55)
	stand.mesh = sm
	stand.material_override = dark_mat
	stand.position = Vector3(0, 1.42, 0)
	kiosk.add_child(stand)
	# Currency rate screen at top
	var screen: MeshInstance3D = MeshInstance3D.new()
	var scm: BoxMesh = BoxMesh.new()
	scm.size = Vector3(0.75, 0.85, 0.04)
	screen.mesh = scm
	var screen_mat: StandardMaterial3D = StandardMaterial3D.new()
	screen_mat.albedo_color = Color(0.30, 0.95, 1.0)
	screen_mat.emission_enabled = true
	screen_mat.emission = Color(0.30, 1.0, 1.0)
	screen_mat.emission_energy_multiplier = 3.0
	screen_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	screen.material_override = screen_mat
	screen.position = Vector3(0, 2.40, 0.30)
	kiosk.add_child(screen)
	# 3 small ticker bars on screen
	var bar_mat: StandardMaterial3D = StandardMaterial3D.new()
	bar_mat.albedo_color = Color(0.30, 1.0, 0.55)
	bar_mat.emission_enabled = true
	bar_mat.emission = Color(0.30, 1.0, 0.55)
	bar_mat.emission_energy_multiplier = 3.5
	bar_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for i in 3:
		var bar: MeshInstance3D = MeshInstance3D.new()
		var bm: BoxMesh = BoxMesh.new()
		bm.size = Vector3(0.55, 0.10, 0.02)
		bar.mesh = bm
		bar.material_override = bar_mat
		bar.position = Vector3(0, 2.65 - i * 0.25, 0.32)
		kiosk.add_child(bar)
		var tw: Tween = bar.create_tween().set_loops()
		tw.tween_interval(i * 0.20)
		tw.tween_property(bar, "scale:x", 0.40, 0.40)
		tw.tween_property(bar, "scale:x", 1.20, 0.40)
	# Dark slit (dark box)
	var slit: MeshInstance3D = MeshInstance3D.new()
	var slm: BoxMesh = BoxMesh.new()
	slm.size = Vector3(0.55, 0.10, 0.06)
	slit.mesh = slm
	var slit_mat: StandardMaterial3D = StandardMaterial3D.new()
	slit_mat.albedo_color = Color(0.05, 0.04, 0.10)
	slit_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	slit.material_override = slit_mat
	slit.position = Vector3(0, 1.10, 0.30)
	kiosk.add_child(slit)
	# Light
	var light: OmniLight3D = OmniLight3D.new()
	light.light_color = Color(0.30, 1.0, 1.0)
	light.light_energy = 1.6
	light.omni_range = 4.0
	light.position = Vector3(0, 2.40, 0.85)
	kiosk.add_child(light)
	# Stand collision
	var sb: StaticBody3D = StaticBody3D.new()
	sb.position = Vector3(0, 1.42, 0)
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(0.85, 2.85, 0.55)
	cs.shape = cb
	sb.add_child(cs)
	kiosk.add_child(sb)


func _build_d6_breakdancer_npc(town: Node) -> void:
	## Epic-6 T91: breakdancer NPC — body lying on side spinning, leg out.
	## Created on its own pivot for windmill rotation.
	var npc_slots: Node3D = town.get_node_or_null("%NPCSlots") as Node3D
	if npc_slots == null:
		return
	var slot: Marker3D = Marker3D.new()
	slot.name = "BreakdancerSlot"
	slot.position = Vector3(D6_CENTER.x - 4.0, 0.0, 12.0)
	npc_slots.add_child(slot)
	# Build a body root that rotates as a windmill
	var body_root: Node3D = Node3D.new()
	body_root.position = Vector3.ZERO
	slot.add_child(body_root)
	# Bright track jacket (oriented horizontally)
	var jacket: MeshInstance3D = MeshInstance3D.new()
	var jm: BoxMesh = BoxMesh.new()
	jm.size = Vector3(0.55, 0.30, 1.0)
	jacket.mesh = jm
	var jacket_mat: StandardMaterial3D = StandardMaterial3D.new()
	jacket_mat.albedo_color = Color(0.95, 0.30, 0.30)
	jacket_mat.emission_enabled = true
	jacket_mat.emission = Color(0.95, 0.30, 0.30)
	jacket_mat.emission_energy_multiplier = 0.55
	jacket.material_override = jacket_mat
	jacket.position = Vector3(0, 0.30, 0)
	body_root.add_child(jacket)
	# Head (off to one side)
	var head: MeshInstance3D = MeshInstance3D.new()
	var hm: SphereMesh = SphereMesh.new()
	hm.radius = 0.18
	hm.height = 0.32
	head.mesh = hm
	var skin_mat: StandardMaterial3D = StandardMaterial3D.new()
	skin_mat.albedo_color = Color(0.95, 0.85, 0.75)
	head.material_override = skin_mat
	head.position = Vector3(0, 0.30, 0.65)
	body_root.add_child(head)
	# Outstretched leg
	var leg: MeshInstance3D = MeshInstance3D.new()
	var lm: BoxMesh = BoxMesh.new()
	lm.size = Vector3(0.18, 0.18, 0.85)
	leg.mesh = lm
	var pant_mat: StandardMaterial3D = StandardMaterial3D.new()
	pant_mat.albedo_color = Color(0.20, 0.20, 0.30)
	leg.material_override = pant_mat
	leg.position = Vector3(0.55, 0.30, -0.30)
	leg.rotation_degrees = Vector3(0, 25, 0)
	body_root.add_child(leg)
	# Windmill spin tween
	var tw: Tween = body_root.create_tween().set_loops()
	tw.tween_property(body_root, "rotation_degrees:y", 360.0, 1.5)
	tw.tween_property(body_root, "rotation_degrees:y", 0.0, 0.0)


func _build_d6_sign_holder_npc(town: Node) -> void:
	## Epic-6 T92: cardboard sign holder NPC — tattered coat + small sign
	## with "WORLD ENDS" text.
	var npc_slots: Node3D = town.get_node_or_null("%NPCSlots") as Node3D
	if npc_slots == null:
		return
	var slot: Marker3D = Marker3D.new()
	slot.name = "SignHolderSlot"
	slot.position = Vector3(D6_CENTER.x + 0.0, 0.0, 8.0)
	npc_slots.add_child(slot)
	var npc_scene: PackedScene = load("res://scenes/entities/npcs/VillagerR3.tscn") as PackedScene
	if npc_scene == null:
		return
	var npc: Node3D = npc_scene.instantiate() as Node3D
	npc.name = "SignHolder"
	if "npc_name" in npc:
		npc.set("npc_name", "Doomsayer")
	if "npc_id" in npc:
		npc.set("npc_id", "sign_d6")
	slot.add_child(npc)
	# Tattered coat
	var coat: MeshInstance3D = MeshInstance3D.new()
	var cm: BoxMesh = BoxMesh.new()
	cm.size = Vector3(0.65, 1.20, 0.45)
	coat.mesh = cm
	var coat_mat: StandardMaterial3D = StandardMaterial3D.new()
	coat_mat.albedo_color = Color(0.30, 0.25, 0.20)
	coat_mat.roughness = 0.95
	coat.material_override = coat_mat
	coat.position = Vector3(0, 0.60, 0)
	npc.add_child(coat)
	# Cardboard sign held up
	var sign: MeshInstance3D = MeshInstance3D.new()
	var sm: BoxMesh = BoxMesh.new()
	sm.size = Vector3(0.85, 0.55, 0.04)
	sign.mesh = sm
	var sign_mat: StandardMaterial3D = StandardMaterial3D.new()
	sign_mat.albedo_color = Color(0.85, 0.75, 0.55)
	sign_mat.roughness = 0.95
	sign.material_override = sign_mat
	sign.position = Vector3(0.30, 1.30, 0.30)
	sign.rotation_degrees = Vector3(-15, 0, 0)
	npc.add_child(sign)
	# Sign text
	var label: Label3D = Label3D.new()
	label.text = "STACK\nOVERFLOW\nSOON"
	label.modulate = Color(0.10, 0.05, 0.05)
	label.outline_modulate = Color(0.85, 0.75, 0.55)
	label.outline_size = 4
	label.font_size = 32
	label.pixel_size = 0.0035
	label.position = Vector3(0.30, 1.30, 0.34)
	label.rotation_degrees = Vector3(-15, 0, 0)
	npc.add_child(label)


func _build_d6_hoverboard(geom: Node) -> void:
	## Epic-6 T93: parked hoverboard — slim board hovering above the ground
	## with magenta underglow strip.
	var hb: Node3D = Node3D.new()
	hb.name = "Hoverboard"
	hb.position = Vector3(D6_CENTER.x + 6.0, 0.30, -2.0)
	geom.add_child(hb)
	var board_mat: StandardMaterial3D = StandardMaterial3D.new()
	board_mat.albedo_color = Color(0.10, 0.10, 0.15)
	board_mat.metallic = 0.85
	board_mat.roughness = 0.30
	# Board (slim flat box)
	var board: MeshInstance3D = MeshInstance3D.new()
	var bm: BoxMesh = BoxMesh.new()
	bm.size = Vector3(1.40, 0.10, 0.40)
	board.mesh = bm
	board.material_override = board_mat
	hb.add_child(board)
	# Underglow strip (magenta)
	var glow: MeshInstance3D = MeshInstance3D.new()
	var gm: BoxMesh = BoxMesh.new()
	gm.size = Vector3(1.40, 0.04, 0.40)
	glow.mesh = gm
	var glow_mat: StandardMaterial3D = StandardMaterial3D.new()
	glow_mat.albedo_color = Color(0.95, 0.20, 0.85)
	glow_mat.emission_enabled = true
	glow_mat.emission = Color(0.95, 0.20, 0.85)
	glow_mat.emission_energy_multiplier = 4.0
	glow_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	glow.material_override = glow_mat
	glow.position = Vector3(0, -0.07, 0)
	hb.add_child(glow)
	# Underglow light
	var light: OmniLight3D = OmniLight3D.new()
	light.light_color = Color(1.0, 0.30, 0.85)
	light.light_energy = 1.6
	light.omni_range = 2.5
	light.position = Vector3(0, -0.20, 0)
	hb.add_child(light)
	# Hover bob
	var tw: Tween = hb.create_tween().set_loops()
	tw.tween_property(hb, "position:y", 0.45, 1.0)
	tw.tween_property(hb, "position:y", 0.30, 1.0)


func _build_d6_neon_tree(geom: Node) -> void:
	## Epic-6 T94: decorative cyber neon tree — black metal trunk with
	## glowing magenta+cyan branches forming a stylized tree shape.
	var tree: Node3D = Node3D.new()
	tree.name = "NeonTree"
	tree.position = Vector3(D6_CENTER.x + 14.0, 0.0, 22.0)
	geom.add_child(tree)
	var trunk_mat: StandardMaterial3D = StandardMaterial3D.new()
	trunk_mat.albedo_color = Color(0.10, 0.08, 0.12)
	trunk_mat.metallic = 0.85
	trunk_mat.roughness = 0.30
	# Trunk
	var trunk: MeshInstance3D = MeshInstance3D.new()
	var trm: CylinderMesh = CylinderMesh.new()
	trm.top_radius = 0.10
	trm.bottom_radius = 0.18
	trm.height = 1.85
	trunk.mesh = trm
	trunk.material_override = trunk_mat
	trunk.position = Vector3(0, 0.92, 0)
	tree.add_child(trunk)
	# Branch glow material (alternating magenta + cyan)
	var magenta_mat: StandardMaterial3D = StandardMaterial3D.new()
	magenta_mat.albedo_color = Color(0.95, 0.20, 0.85)
	magenta_mat.emission_enabled = true
	magenta_mat.emission = Color(0.95, 0.20, 0.85)
	magenta_mat.emission_energy_multiplier = 3.5
	magenta_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var cyan_mat: StandardMaterial3D = StandardMaterial3D.new()
	cyan_mat.albedo_color = Color(0.30, 0.95, 1.0)
	cyan_mat.emission_enabled = true
	cyan_mat.emission = Color(0.30, 1.0, 1.0)
	cyan_mat.emission_energy_multiplier = 3.5
	cyan_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	# 6 angled branches with glowing tubes
	for i in 6:
		var ang: float = (TAU / 6.0) * i
		var branch: MeshInstance3D = MeshInstance3D.new()
		var bm: CylinderMesh = CylinderMesh.new()
		bm.top_radius = 0.04
		bm.bottom_radius = 0.06
		bm.height = 1.40
		branch.mesh = bm
		branch.material_override = magenta_mat if i % 2 == 0 else cyan_mat
		branch.position = Vector3(cos(ang) * 0.55, 2.20, sin(ang) * 0.55)
		branch.rotation = Vector3(deg_to_rad(35) * sin(ang), ang, deg_to_rad(35) * cos(ang))
		tree.add_child(branch)
		# Tip orb at the end of each branch
		var tip: MeshInstance3D = MeshInstance3D.new()
		var tm: SphereMesh = SphereMesh.new()
		tm.radius = 0.10
		tm.height = 0.18
		tip.mesh = tm
		tip.material_override = branch.material_override
		tip.position = Vector3(cos(ang) * 1.30, 2.85, sin(ang) * 1.30)
		tree.add_child(tip)
	# Top crown orb
	var crown: MeshInstance3D = MeshInstance3D.new()
	var cm: SphereMesh = SphereMesh.new()
	cm.radius = 0.18
	cm.height = 0.32
	crown.mesh = cm
	crown.material_override = magenta_mat
	crown.position = Vector3(0, 3.20, 0)
	tree.add_child(crown)
	# Aura light
	var light: OmniLight3D = OmniLight3D.new()
	light.light_color = Color(0.95, 0.30, 1.0)
	light.light_energy = 2.5
	light.omni_range = 6.0
	light.position = Vector3(0, 2.40, 0)
	tree.add_child(light)
	# Trunk collision
	var sb: StaticBody3D = StaticBody3D.new()
	sb.position = Vector3(0, 0.92, 0)
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cap: CapsuleShape3D = CapsuleShape3D.new()
	cap.radius = 0.18
	cap.height = 1.85
	cs.shape = cap
	sb.add_child(cs)
	tree.add_child(sb)


func _build_d6_holo_butterflies(geom: Node) -> void:
	## Epic-6 T95: 8 holographic glow butterflies drifting around the neon
	## tree — small wing pairs in alternating magenta + cyan.
	var swarm: Node3D = Node3D.new()
	swarm.name = "HoloButterflies"
	swarm.position = Vector3(D6_CENTER.x + 14.0, 2.0, 22.0)
	geom.add_child(swarm)
	for i in 8:
		var pivot: Node3D = Node3D.new()
		pivot.position = Vector3(0, randf_range(-0.85, 0.85), 0)
		pivot.rotation_degrees = Vector3(0, i * 45.0, 0)
		swarm.add_child(pivot)
		var bf: Node3D = Node3D.new()
		bf.position = Vector3(2.40 + randf() * 0.85, 0, 0)
		pivot.add_child(bf)
		var wing_mat: StandardMaterial3D = StandardMaterial3D.new()
		wing_mat.albedo_color = Color(0.95, 0.20, 0.85, 0.85) if i % 2 == 0 else Color(0.30, 0.95, 1.0, 0.85)
		wing_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		wing_mat.emission_enabled = true
		wing_mat.emission = Color(0.95, 0.20, 0.85) if i % 2 == 0 else Color(0.30, 0.95, 1.0)
		wing_mat.emission_energy_multiplier = 3.0
		wing_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		# 2 wings
		for sx in [-0.15, 0.15]:
			var wing: MeshInstance3D = MeshInstance3D.new()
			var wm: BoxMesh = BoxMesh.new()
			wm.size = Vector3(0.18, 0.04, 0.30)
			wing.mesh = wm
			wing.material_override = wing_mat
			wing.position = Vector3(sx, 0, 0)
			bf.add_child(wing)
			# Flap tween
			var twf: Tween = wing.create_tween().set_loops()
			twf.tween_property(wing, "rotation_degrees:z", 35.0 if sx < 0 else -35.0, 0.10)
			twf.tween_property(wing, "rotation_degrees:z", 0.0, 0.10)
		# Pivot rotation tween
		var trot: Tween = pivot.create_tween().set_loops()
		trot.tween_property(pivot, "rotation_degrees:y", i * 45.0 + 360.0, 8.0 + i * 0.4)
		trot.tween_property(pivot, "rotation_degrees:y", i * 45.0, 0.0)


func _build_d6_welcome_banner(geom: Node) -> void:
	## Epic-6 T96: tall double-pole welcome banner — black metal poles +
	## glowing magenta-bordered neon panel + "NEON BAZAAR" Label3D.
	var banner: Node3D = Node3D.new()
	banner.name = "D6WelcomeBanner"
	banner.position = Vector3(D6_CENTER.x - 36.0, 0.0, -4.0)
	geom.add_child(banner)
	var black_mat: StandardMaterial3D = StandardMaterial3D.new()
	black_mat.albedo_color = Color(0.10, 0.08, 0.15)
	black_mat.metallic = 0.85
	black_mat.roughness = 0.30
	var magenta_mat: StandardMaterial3D = StandardMaterial3D.new()
	magenta_mat.albedo_color = Color(0.95, 0.20, 0.85)
	magenta_mat.emission_enabled = true
	magenta_mat.emission = Color(0.95, 0.20, 0.85)
	magenta_mat.emission_energy_multiplier = 4.0
	magenta_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for sx in [-2.40, 2.40]:
		var pole: MeshInstance3D = MeshInstance3D.new()
		var pm: BoxMesh = BoxMesh.new()
		pm.size = Vector3(0.30, 5.85, 0.30)
		pole.mesh = pm
		pole.material_override = black_mat
		pole.position = Vector3(sx, 2.92, 0)
		banner.add_child(pole)
		# Pole collision
		var sb: StaticBody3D = StaticBody3D.new()
		sb.position = Vector3(sx, 2.92, 0)
		var cs: CollisionShape3D = CollisionShape3D.new()
		var cb: BoxShape3D = BoxShape3D.new()
		cb.size = Vector3(0.30, 5.85, 0.30)
		cs.shape = cb
		sb.add_child(cs)
		banner.add_child(sb)
	# Top crossbar
	var bar: MeshInstance3D = MeshInstance3D.new()
	var bm: BoxMesh = BoxMesh.new()
	bm.size = Vector3(5.20, 0.20, 0.20)
	bar.mesh = bm
	bar.material_override = black_mat
	bar.position = Vector3(0, 5.85, 0)
	banner.add_child(bar)
	# Banner panel (black background)
	var panel: MeshInstance3D = MeshInstance3D.new()
	var pmm: BoxMesh = BoxMesh.new()
	pmm.size = Vector3(4.85, 2.85, 0.10)
	panel.mesh = pmm
	panel.material_override = black_mat
	panel.position = Vector3(0, 3.85, 0)
	banner.add_child(panel)
	# Magenta neon border tubes
	for w in [
		{"size": Vector3(4.85, 0.10, 0.06), "pos": Vector3(0, 5.30, 0.10)},
		{"size": Vector3(4.85, 0.10, 0.06), "pos": Vector3(0, 2.40, 0.10)},
		{"size": Vector3(0.10, 2.85, 0.06), "pos": Vector3(-2.40, 3.85, 0.10)},
		{"size": Vector3(0.10, 2.85, 0.06), "pos": Vector3( 2.40, 3.85, 0.10)},
	]:
		var tube: MeshInstance3D = MeshInstance3D.new()
		var tm: BoxMesh = BoxMesh.new()
		tm.size = w["size"]
		tube.mesh = tm
		tube.material_override = magenta_mat
		tube.position = w["pos"]
		banner.add_child(tube)
	# Title labels
	var label: Label3D = Label3D.new()
	label.text = "NEON BAZAAR"
	label.modulate = Color(0.95, 0.95, 1.0)
	label.outline_modulate = Color(0.95, 0.20, 0.85)
	label.outline_size = 16
	label.font_size = 96
	label.pixel_size = 0.013
	label.position = Vector3(0, 4.30, 0.20)
	banner.add_child(label)
	var subtitle: Label3D = Label3D.new()
	subtitle.text = "open all hours, every iteration"
	subtitle.modulate = Color(0.30, 1.0, 1.0)
	subtitle.outline_modulate = Color(0.10, 0.05, 0.20)
	subtitle.outline_size = 6
	subtitle.font_size = 42
	subtitle.pixel_size = 0.010
	subtitle.position = Vector3(0, 3.20, 0.20)
	banner.add_child(subtitle)
	# Light
	var light: OmniLight3D = OmniLight3D.new()
	light.light_color = Color(1.0, 0.30, 0.85)
	light.light_energy = 3.5
	light.omni_range = 9.0
	light.position = Vector3(0, 3.85, 1.20)
	banner.add_child(light)


func _build_d6_grand_spire(geom: Node) -> void:
	## Epic-6 T97: GRAND NEON SPIRE — towering 3-tier metal/glass spire
	## with rotating crown of light beams. The new tallest D6 landmark.
	var spire: Node3D = Node3D.new()
	spire.name = "GrandNeonSpire"
	spire.position = Vector3(D6_CENTER.x, 0.0, -2.0)
	geom.add_child(spire)
	var black_mat: StandardMaterial3D = StandardMaterial3D.new()
	black_mat.albedo_color = Color(0.08, 0.06, 0.12)
	black_mat.metallic = 0.85
	black_mat.roughness = 0.30
	var magenta_mat: StandardMaterial3D = StandardMaterial3D.new()
	magenta_mat.albedo_color = Color(0.95, 0.20, 0.85)
	magenta_mat.emission_enabled = true
	magenta_mat.emission = Color(0.95, 0.20, 0.85)
	magenta_mat.emission_energy_multiplier = 4.0
	magenta_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var cyan_mat: StandardMaterial3D = StandardMaterial3D.new()
	cyan_mat.albedo_color = Color(0.30, 0.95, 1.0)
	cyan_mat.emission_enabled = true
	cyan_mat.emission = Color(0.30, 1.0, 1.0)
	cyan_mat.emission_energy_multiplier = 4.0
	cyan_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	# Stone pedestal
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.20, 0.15, 0.25)
	stone_mat.metallic = 0.55
	var pedestal: MeshInstance3D = MeshInstance3D.new()
	var pm: BoxMesh = BoxMesh.new()
	pm.size = Vector3(5.50, 0.55, 5.50)
	pedestal.mesh = pm
	pedestal.material_override = stone_mat
	pedestal.position = Vector3(0, 0.27, 0)
	spire.add_child(pedestal)
	# 3 tower tiers
	var tier_data: Array = [
		{"size": Vector3(2.85, 4.20, 2.85), "y": 2.40, "neon": magenta_mat},
		{"size": Vector3(2.0, 4.20, 2.0),   "y": 6.65, "neon": cyan_mat},
		{"size": Vector3(1.30, 4.20, 1.30), "y": 10.85, "neon": magenta_mat},
	]
	for tier in tier_data:
		var t: MeshInstance3D = MeshInstance3D.new()
		var tm: BoxMesh = BoxMesh.new()
		tm.size = tier["size"]
		t.mesh = tm
		t.material_override = black_mat
		t.position = Vector3(0, tier["y"], 0)
		spire.add_child(t)
		# Vertical neon strips on the front
		for sx in [-tier["size"].x * 0.40, tier["size"].x * 0.40]:
			var strip: MeshInstance3D = MeshInstance3D.new()
			var sm: BoxMesh = BoxMesh.new()
			sm.size = Vector3(0.06, tier["size"].y * 0.85, 0.06)
			strip.mesh = sm
			strip.material_override = tier["neon"]
			strip.position = Vector3(sx, tier["y"], tier["size"].z * 0.50 + 0.02)
			spire.add_child(strip)
	# Top crystal spike
	var spike: MeshInstance3D = MeshInstance3D.new()
	var spm: PrismMesh = PrismMesh.new()
	spm.size = Vector3(1.40, 3.40, 1.40)
	spike.mesh = spm
	spike.material_override = magenta_mat
	spike.position = Vector3(0, 14.65, 0)
	spire.add_child(spike)
	# Rotating crown of 6 light beams at the top
	var crown_pivot: Node3D = Node3D.new()
	crown_pivot.position = Vector3(0, 14.65, 0)
	spire.add_child(crown_pivot)
	for i in 6:
		var ang: float = (TAU / 6.0) * i
		var beam: MeshInstance3D = MeshInstance3D.new()
		var beam_m: CylinderMesh = CylinderMesh.new()
		beam_m.top_radius = 0.10
		beam_m.bottom_radius = 0.30
		beam_m.height = 8.0
		beam.mesh = beam_m
		var beam_mat: StandardMaterial3D = StandardMaterial3D.new()
		beam_mat.albedo_color = Color(0.95, 0.30, 0.85, 0.45) if i % 2 == 0 else Color(0.30, 0.95, 1.0, 0.45)
		beam_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		beam_mat.emission_enabled = true
		beam_mat.emission = Color(0.95, 0.30, 0.85) if i % 2 == 0 else Color(0.30, 0.95, 1.0)
		beam_mat.emission_energy_multiplier = 1.4
		beam_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		beam.material_override = beam_mat
		beam.position = Vector3(cos(ang) * 2.40, 4.0, sin(ang) * 2.40)
		beam.rotation_degrees = Vector3(0, deg_to_rad(ang) * 60.0, 30.0)
		crown_pivot.add_child(beam)
	var trot: Tween = crown_pivot.create_tween().set_loops()
	trot.tween_property(crown_pivot, "rotation_degrees:y", 360.0, 12.0)
	trot.tween_property(crown_pivot, "rotation_degrees:y", 0.0, 0.0)
	# Massive central light
	var light: OmniLight3D = OmniLight3D.new()
	light.light_color = Color(1.0, 0.30, 0.85)
	light.light_energy = 5.5
	light.omni_range = 24.0
	light.position = Vector3(0, 8.0, 0)
	spire.add_child(light)
	# Spire collision
	var sb: StaticBody3D = StaticBody3D.new()
	sb.position = Vector3(0, 6.65, 0)
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(2.85, 13.30, 2.85)
	cs.shape = cb
	sb.add_child(cs)
	spire.add_child(sb)


func _build_d6_district_plaque(geom: Node) -> void:
	## Epic-6 T98: dedication plaque on a stone pedestal at the entrance.
	var plaque: Node3D = Node3D.new()
	plaque.name = "D6Plaque"
	plaque.position = Vector3(D6_CENTER.x - 32.0, 0.0, 4.0)
	geom.add_child(plaque)
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.20, 0.15, 0.25)
	stone_mat.roughness = 0.92
	# Pedestal
	var ped: MeshInstance3D = MeshInstance3D.new()
	var pm: BoxMesh = BoxMesh.new()
	pm.size = Vector3(0.85, 1.20, 0.55)
	ped.mesh = pm
	ped.material_override = stone_mat
	ped.position = Vector3(0, 0.60, 0)
	plaque.add_child(ped)
	# Plaque face (chrome)
	var face: MeshInstance3D = MeshInstance3D.new()
	var fm: BoxMesh = BoxMesh.new()
	fm.size = Vector3(0.75, 0.50, 0.06)
	face.mesh = fm
	var chrome_mat: StandardMaterial3D = StandardMaterial3D.new()
	chrome_mat.albedo_color = Color(0.85, 0.85, 0.92)
	chrome_mat.metallic = 0.95
	chrome_mat.roughness = 0.05
	face.material_override = chrome_mat
	face.position = Vector3(0, 1.00, 0.30)
	face.rotation_degrees = Vector3(-15, 0, 0)
	plaque.add_child(face)
	var label: Label3D = Label3D.new()
	label.text = "NEON BAZAAR\nDistrict 06 — Iteration 06\nWhere code refuses to sleep"
	label.modulate = Color(0.10, 0.05, 0.15)
	label.outline_modulate = Color(0.95, 0.20, 0.85)
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


func _build_d6_ambient_tweak(geom: Node) -> void:
	## Epic-6 T99: cyber night ambient — magenta fill light + secondary
	## cyan directional from above.
	var amb: Node3D = Node3D.new()
	amb.name = "D6Ambient"
	amb.position = Vector3(D6_CENTER.x, 8.0, 0.0)
	geom.add_child(amb)
	var fill: OmniLight3D = OmniLight3D.new()
	fill.light_color = Color(1.0, 0.55, 0.85)
	fill.light_energy = 0.85
	fill.omni_range = 42.0
	amb.add_child(fill)
	# Slow color cycle
	var tw: Tween = fill.create_tween().set_loops()
	tw.tween_property(fill, "light_color", Color(0.55, 0.85, 1.0), 6.0)
	tw.tween_property(fill, "light_color", Color(1.0, 0.55, 0.85), 6.0)
	var sun: DirectionalLight3D = DirectionalLight3D.new()
	sun.light_color = Color(0.55, 0.85, 1.0)
	sun.light_energy = 0.30
	sun.shadow_enabled = false
	sun.position = Vector3(0, 14.0, 0)
	sun.rotation_degrees = Vector3(-65, 35, 0)
	amb.add_child(sun)


func _build_d6_neon_empress(geom: Node) -> void:
	## Epic-6 T100: NEON EMPRESS — Epic 6 finale boss. Towering geisha-cyborg
	## ruler with flowing neon kimono, masked face, glowing fan, and a
	## halo of orbiting holographic glyphs. Magenta+cyan dominant.
	var emp: Node3D = Node3D.new()
	emp.name = "NeonEmpress"
	emp.position = Vector3(D6_CENTER.x + 28.0, 0.0, -22.0)
	geom.add_child(emp)
	var black_mat: StandardMaterial3D = StandardMaterial3D.new()
	black_mat.albedo_color = Color(0.08, 0.06, 0.12)
	black_mat.metallic = 0.85
	black_mat.roughness = 0.30
	var magenta_mat: StandardMaterial3D = StandardMaterial3D.new()
	magenta_mat.albedo_color = Color(0.95, 0.20, 0.85, 0.85)
	magenta_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	magenta_mat.emission_enabled = true
	magenta_mat.emission = Color(0.95, 0.20, 0.85)
	magenta_mat.emission_energy_multiplier = 4.0
	magenta_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var cyan_mat: StandardMaterial3D = StandardMaterial3D.new()
	cyan_mat.albedo_color = Color(0.30, 0.95, 1.0)
	cyan_mat.emission_enabled = true
	cyan_mat.emission = Color(0.30, 1.0, 1.0)
	cyan_mat.emission_energy_multiplier = 4.0
	cyan_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.20, 0.15, 0.25)
	stone_mat.metallic = 0.65
	# Stone pedestal
	var ped: MeshInstance3D = MeshInstance3D.new()
	var pm: BoxMesh = BoxMesh.new()
	pm.size = Vector3(3.85, 0.55, 3.85)
	ped.mesh = pm
	ped.material_override = stone_mat
	ped.position = Vector3(0, 0.27, 0)
	emp.add_child(ped)
	# Flowing kimono — wide tapered cone (translucent magenta)
	var kimono: MeshInstance3D = MeshInstance3D.new()
	var km: CylinderMesh = CylinderMesh.new()
	km.top_radius = 0.95
	km.bottom_radius = 1.85
	km.height = 4.20
	kimono.mesh = km
	kimono.material_override = magenta_mat
	kimono.position = Vector3(0, 2.70, 0)
	emp.add_child(kimono)
	# Cyan obi (sash) — torus around the waist
	var obi: MeshInstance3D = MeshInstance3D.new()
	var om: TorusMesh = TorusMesh.new()
	om.inner_radius = 1.10
	om.outer_radius = 1.30
	obi.mesh = om
	obi.material_override = cyan_mat
	obi.position = Vector3(0, 3.40, 0)
	emp.add_child(obi)
	# Torso (smaller column above kimono)
	var torso: MeshInstance3D = MeshInstance3D.new()
	var tm: CylinderMesh = CylinderMesh.new()
	tm.top_radius = 0.65
	tm.bottom_radius = 0.95
	tm.height = 1.40
	torso.mesh = tm
	torso.material_override = black_mat
	torso.position = Vector3(0, 5.50, 0)
	emp.add_child(torso)
	# Head (sphere)
	var head: MeshInstance3D = MeshInstance3D.new()
	var hm: SphereMesh = SphereMesh.new()
	hm.radius = 0.55
	hm.height = 0.95
	head.mesh = hm
	head.material_override = black_mat
	head.position = Vector3(0, 6.65, 0)
	emp.add_child(head)
	# Glowing magenta mask covering the face
	var mask: MeshInstance3D = MeshInstance3D.new()
	var mskm: BoxMesh = BoxMesh.new()
	mskm.size = Vector3(0.85, 0.45, 0.06)
	mask.mesh = mskm
	mask.material_override = magenta_mat
	mask.position = Vector3(0, 6.65, 0.55)
	emp.add_child(mask)
	# Hair pins / antennae (3 cyan spikes from head)
	for i in 3:
		var ang: float = (TAU / 3.0) * i
		var pin: MeshInstance3D = MeshInstance3D.new()
		var pim: PrismMesh = PrismMesh.new()
		pim.size = Vector3(0.10, 0.85 + (i % 2) * 0.30, 0.10)
		pin.mesh = pim
		pin.material_override = cyan_mat
		pin.position = Vector3(cos(ang) * 0.35, 7.30, sin(ang) * 0.35)
		emp.add_child(pin)
	# 2 long sleeves trailing outward
	for sx in [-1.85, 1.85]:
		var sleeve: MeshInstance3D = MeshInstance3D.new()
		var slm: BoxMesh = BoxMesh.new()
		slm.size = Vector3(0.55, 1.85, 0.55)
		sleeve.mesh = slm
		sleeve.material_override = magenta_mat
		sleeve.position = Vector3(sx, 4.20, 0)
		sleeve.rotation_degrees = Vector3(0, 0, -25.0 if sx > 0 else 25.0)
		emp.add_child(sleeve)
	# Held glowing fan (semi-circle of cyan slats)
	var fan_pivot: Node3D = Node3D.new()
	fan_pivot.position = Vector3(2.40, 4.85, 0)
	emp.add_child(fan_pivot)
	for i in 7:
		var ang: float = lerp(deg_to_rad(-50.0), deg_to_rad(50.0), float(i) / 6.0)
		var slat: MeshInstance3D = MeshInstance3D.new()
		var slm: BoxMesh = BoxMesh.new()
		slm.size = Vector3(0.06, 1.30, 0.04)
		slat.mesh = slm
		slat.material_override = cyan_mat if i % 2 == 0 else magenta_mat
		slat.position = Vector3(sin(ang) * 0.65, 0.55, cos(ang) * 0.10)
		slat.rotation = Vector3(0, ang, deg_to_rad(35) * sin(ang))
		fan_pivot.add_child(slat)
	# Slow fan flutter
	var twf: Tween = fan_pivot.create_tween().set_loops()
	twf.tween_property(fan_pivot, "rotation_degrees:y", 8.0, 1.4)
	twf.tween_property(fan_pivot, "rotation_degrees:y", -8.0, 1.4)
	# 10 orbiting holographic glyphs around the head
	var halo: Node3D = Node3D.new()
	halo.position = Vector3(0, 7.30, 0)
	emp.add_child(halo)
	for i in 10:
		var ang: float = (TAU / 10.0) * i
		var glyph: MeshInstance3D = MeshInstance3D.new()
		var gmm: BoxMesh = BoxMesh.new()
		gmm.size = Vector3(0.18, 0.30, 0.04)
		glyph.mesh = gmm
		glyph.material_override = cyan_mat if i % 2 == 0 else magenta_mat
		glyph.position = Vector3(cos(ang) * 2.40, 0, sin(ang) * 2.40)
		glyph.rotation = Vector3(0, ang + PI * 0.5, 0)
		halo.add_child(glyph)
	var trot: Tween = halo.create_tween().set_loops()
	trot.tween_property(halo, "rotation_degrees:y", 360.0, 14.0)
	trot.tween_property(halo, "rotation_degrees:y", 0.0, 0.0)
	# Massive central light
	var light: OmniLight3D = OmniLight3D.new()
	light.light_color = Color(1.0, 0.30, 0.85)
	light.light_energy = 5.5
	light.omni_range = 22.0
	light.position = Vector3(0, 5.50, 0)
	emp.add_child(light)
	var twl: Tween = light.create_tween().set_loops()
	twl.tween_property(light, "light_energy", 7.0, 2.0)
	twl.tween_property(light, "light_energy", 4.5, 2.0)
	# Title labels
	var title: Label3D = Label3D.new()
	title.text = "THE NEON EMPRESS"
	title.modulate = Color(0.95, 0.30, 0.85)
	title.outline_modulate = Color(0.10, 0.05, 0.20)
	title.outline_size = 14
	title.font_size = 84
	title.pixel_size = 0.014
	title.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	title.position = Vector3(0, 9.50, 0)
	emp.add_child(title)
	var subtitle: Label3D = Label3D.new()
	subtitle.text = "Sovereign of perpetual midnight"
	subtitle.modulate = Color(0.30, 0.95, 1.0)
	subtitle.outline_modulate = Color(0.20, 0.05, 0.30)
	subtitle.outline_size = 8
	subtitle.font_size = 42
	subtitle.pixel_size = 0.011
	subtitle.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	subtitle.position = Vector3(0, 8.80, 0)
	emp.add_child(subtitle)
	# Body collision (capsule)
	var sb: StaticBody3D = StaticBody3D.new()
	sb.position = Vector3(0, 4.50, 0)
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cap: CapsuleShape3D = CapsuleShape3D.new()
	cap.radius = 1.85
	cap.height = 8.40
	cs.shape = cap
	sb.add_child(cs)
	emp.add_child(sb)
	# Pedestal collision
	var psb: StaticBody3D = StaticBody3D.new()
	psb.position = Vector3(0, 0.27, 0)
	var pcs: CollisionShape3D = CollisionShape3D.new()
	var pcb: BoxShape3D = BoxShape3D.new()
	pcb.size = Vector3(3.85, 0.55, 3.85)
	pcs.shape = pcb
	psb.add_child(pcs)
	emp.add_child(psb)
