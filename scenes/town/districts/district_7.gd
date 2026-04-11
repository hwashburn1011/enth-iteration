class_name D7Builder
extends RefCounted
## Ascension Spires district builder — extracted from scenes/town/town.gd to keep
## the main town script modular and under control. All build helpers here are
## static and called from town.gd's _build_district_7() entry function.
##
## NPC helpers receive `town: Node` so they can resolve %NPCSlots; geom helpers
## receive `geom: Node` (the town's Geometry node). All other helpers are
## self-contained and only use Godot built-ins.

const D7_CENTER := Vector3(470, 0, 0)


static func extend_boundary(geom: Node) -> void:
	## Push the east boundary wall from x=430 out to x=530 to make room for D7.
	var east_wall: CSGBox3D = geom.get_node_or_null("BoundaryEast") as CSGBox3D
	if east_wall:
		east_wall.position.x = 530.0


static func build(town: Node, geom: Node) -> void:
	## Entry point — called from town.gd::_build_district_7(geom).
	print("[D7Builder] start")
	extend_boundary(geom)
	_build_d7_ground(geom)
	_build_d7_temple_gate(geom)
	_build_d7_great_spire(geom)
	_build_d7_monk_elder_npc(town)
	_build_d7_prayer_flags(geom)
	_build_d7_stone_cairns(geom)
	_build_d7_monk_acolyte_npc(town)
	_build_d7_incense_burner(geom)
	_build_d7_brass_gong(geom)
	_build_d7_stone_bridge(geom)
	_build_d7_spring_fountain(geom)
	_build_d7_bell_tower(geom)
	_build_d7_bellringer_npc(town)
	_build_d7_cliff_face(geom)
	_build_d7_meditation_pavilion(geom)
	_build_d7_meditating_monk_npc(town)
	_build_d7_zen_garden(geom)
	_build_d7_waterfall(geom)
	_build_d7_scroll_shelves(geom)
	_build_d7_stupa_shrine(geom)
	_build_d7_pilgrim_npc(town)
	_build_d7_mountain_goats(geom)
	_build_d7_lotus_pond(geom)
	_build_d7_stone_lanterns(geom)
	_build_d7_tea_house(geom)
	_build_d7_tea_master_npc(town)
	_build_d7_training_posts(geom)
	_build_d7_martial_artist_npc(town)
	_build_d7_rope_bridge(geom)
	_build_d7_stone_arch(geom)
	_build_d7_bonsai_garden(geom)
	_build_d7_d7_gardener_npc(town)
	_build_d7_cliff_stack(geom)
	_build_d7_stone_stairs(geom)
	_build_d7_weapon_rack(geom)
	_build_d7_d7_archer_npc(town)
	_build_d7_target_stands(geom)
	_build_d7_shrine_pillars(geom)
	_build_d7_spirit_braziers(geom)
	_build_d7_alms_bowls(geom)
	_build_d7_alms_collector_npc(town)
	_build_d7_buddha_statue(geom)
	_build_d7_incense_columns(geom)
	_build_d7_ancient_sage_npc(town)
	_build_d7_cave_entrance(geom)
	_build_d7_cave_hermit_npc(town)
	_build_d7_burial_cairns(geom)
	_build_d7_rune_monoliths(geom)
	_build_d7_stone_colossus(geom)
	_build_d7_hawks(geom)
	_build_d7_falconer_npc(town)
	_build_d7_obelisk(geom)
	_build_d7_cave_paintings(geom)
	_build_d7_shaman_npc(town)
	_build_d7_gate_ruin(geom)
	_build_d7_d7_archaeologist_npc(town)
	_build_d7_ancient_tomb(geom)
	_build_d7_tomb_guardian(geom)
	_build_d7_dust_motes(geom)
	_build_d7_dragon_statue(geom)
	_build_d7_dragon_priest_npc(town)
	_build_d7_ceremonial_fire(geom)
	_build_d7_divination_table(geom)
	_build_d7_d7_oracle_npc(town)
	_build_d7_arched_bridge(geom)
	_build_d7_yaks(geom)
	_build_d7_yak_herder_npc(town)
	_build_d7_hot_spring_d7(geom)
	_build_d7_bathing_monk_npc(town)
	_build_d7_wishing_well(geom)
	_build_d7_blacksmith_forge(geom)
	_build_d7_blacksmith_npc(town)
	_build_d7_weapon_display(geom)
	_build_d7_tea_garden_benches(geom)
	_build_d7_d7_rope_swing(geom)
	_build_d7_child_apprentice_npc(town)
	_build_d7_stone_pagoda(geom)
	_build_d7_pagoda_monk_npc(town)
	_build_d7_falling_leaves(geom)
	_build_d7_d7_gargoyles(geom)
	_build_d7_cloud_pavilion(geom)
	_build_d7_spirit_dancer_npc(town)
	_build_d7_outlook_telescope(geom)
	_build_d7_d7_stargazer_npc(town)
	_build_d7_prayer_wheels(geom)
	_build_d7_bell_shrine(geom)
	_build_d7_sweeper_monk_npc(town)
	_build_d7_water_mill(geom)
	_build_d7_cloud_mist(geom)
	_build_d7_stone_golem(geom)
	_build_d7_sky_lanterns(geom)
	_build_d7_lantern_releaser_npc(town)
	_build_d7_ancient_pine(geom)
	_build_d7_d7_scholar_npc(town)
	_build_d7_welcome_banner(geom)
	_build_d7_grand_peak(geom)
	_build_d7_district_plaque(geom)
	_build_d7_ambient_tweak(geom)
	_build_d7_mountain_sage(geom)
	print("[D7Builder] done")


static func _build_d7_ground(geom: Node) -> void:
	## Epic-7 T1b: D7 sandstone ground — warm tan plane with scattered
	## small rock and pebble decorations suggesting a dry highland.
	var plane: PlaneMesh = PlaneMesh.new()
	plane.size = Vector2(80, 40)
	var ground: MeshInstance3D = MeshInstance3D.new()
	ground.mesh = plane
	var sand_mat: StandardMaterial3D = StandardMaterial3D.new()
	sand_mat.albedo_color = Color(0.75, 0.55, 0.30)
	sand_mat.emission_enabled = true
	sand_mat.emission = Color(0.65, 0.45, 0.20)
	sand_mat.emission_energy_multiplier = 0.18
	sand_mat.roughness = 0.92
	ground.material_override = sand_mat
	ground.position = Vector3(D7_CENTER.x, 0.01, 0)
	ground.name = "D7SandstoneGround"
	geom.add_child(ground)
	# Sprinkle 50 small rocks for surface variation
	var rock_mat: StandardMaterial3D = StandardMaterial3D.new()
	rock_mat.albedo_color = Color(0.55, 0.40, 0.25)
	rock_mat.roughness = 0.95
	for i in 50:
		var rock: MeshInstance3D = MeshInstance3D.new()
		var rm: SphereMesh = SphereMesh.new()
		rm.radius = 0.20 + randf() * 0.30
		rm.height = 0.20 + randf() * 0.18
		rock.mesh = rm
		rock.material_override = rock_mat
		rock.position = Vector3(
			D7_CENTER.x + randf_range(-32, 32),
			0.10,
			randf_range(-18, 18)
		)
		rock.scale = Vector3(1.0, 0.45, 1.0)
		rock.rotation_degrees = Vector3(0, randf_range(0, 360), 0)
		geom.add_child(rock)


static func _build_d7_temple_gate(geom: Node) -> void:
	## Epic-7 T2: red torii-style temple gate — 2 wooden vertical posts
	## connected by 2 horizontal crossbars with upturned ends.
	var gate: Node3D = Node3D.new()
	gate.name = "D7TempleGate"
	gate.position = Vector3(D7_CENTER.x - 32.0, 0.0, 0.0)
	geom.add_child(gate)
	var red_mat: StandardMaterial3D = StandardMaterial3D.new()
	red_mat.albedo_color = Color(0.85, 0.20, 0.20)
	red_mat.emission_enabled = true
	red_mat.emission = Color(0.85, 0.25, 0.20)
	red_mat.emission_energy_multiplier = 0.45
	red_mat.roughness = 0.65
	# 2 vertical posts
	for sx in [-2.40, 2.40]:
		var post: MeshInstance3D = MeshInstance3D.new()
		var pm: CylinderMesh = CylinderMesh.new()
		pm.top_radius = 0.30
		pm.bottom_radius = 0.40
		pm.height = 5.50
		post.mesh = pm
		post.material_override = red_mat
		post.position = Vector3(sx, 2.75, 0)
		gate.add_child(post)
		# Post collision
		var sb: StaticBody3D = StaticBody3D.new()
		sb.position = Vector3(sx, 2.75, 0)
		var cs: CollisionShape3D = CollisionShape3D.new()
		var cap: CapsuleShape3D = CapsuleShape3D.new()
		cap.radius = 0.40
		cap.height = 5.50
		cs.shape = cap
		sb.add_child(cs)
		gate.add_child(sb)
	# Lower crossbar (rectangular)
	var lower: MeshInstance3D = MeshInstance3D.new()
	var lm: BoxMesh = BoxMesh.new()
	lm.size = Vector3(5.50, 0.30, 0.40)
	lower.mesh = lm
	lower.material_override = red_mat
	lower.position = Vector3(0, 4.40, 0)
	gate.add_child(lower)
	# Upper crossbar (longer with upturned ends)
	var upper: MeshInstance3D = MeshInstance3D.new()
	var um: BoxMesh = BoxMesh.new()
	um.size = Vector3(6.50, 0.55, 0.55)
	upper.mesh = um
	upper.material_override = red_mat
	upper.position = Vector3(0, 5.40, 0)
	gate.add_child(upper)
	# Upturned end caps (small angled boxes)
	for sx in [-3.30, 3.30]:
		var cap: MeshInstance3D = MeshInstance3D.new()
		var cm: BoxMesh = BoxMesh.new()
		cm.size = Vector3(0.85, 0.30, 0.55)
		cap.mesh = cm
		cap.material_override = red_mat
		cap.position = Vector3(sx, 5.55, 0)
		cap.rotation_degrees = Vector3(0, 0, -15.0 if sx > 0 else 15.0)
		gate.add_child(cap)
	# Center plaque
	var plaque_mat: StandardMaterial3D = StandardMaterial3D.new()
	plaque_mat.albedo_color = Color(0.95, 0.85, 0.45)
	plaque_mat.emission_enabled = true
	plaque_mat.emission = Color(0.95, 0.75, 0.30)
	plaque_mat.emission_energy_multiplier = 0.85
	var plaque: MeshInstance3D = MeshInstance3D.new()
	var pmm: BoxMesh = BoxMesh.new()
	pmm.size = Vector3(1.40, 0.55, 0.10)
	plaque.mesh = pmm
	plaque.material_override = plaque_mat
	plaque.position = Vector3(0, 4.85, 0.30)
	gate.add_child(plaque)
	# Light
	var light: OmniLight3D = OmniLight3D.new()
	light.light_color = Color(1.0, 0.65, 0.30)
	light.light_energy = 2.5
	light.omni_range = 8.0
	light.position = Vector3(0, 4.20, 0)
	gate.add_child(light)


static func _build_d7_great_spire(geom: Node) -> void:
	## Epic-7 T3: GREAT SANDSTONE SPIRE landmark — towering rock formation
	## stack of 4 cylinder tiers with a glowing amber crystal at the peak.
	var spire: Node3D = Node3D.new()
	spire.name = "GreatSandstoneSpire"
	spire.position = Vector3(D7_CENTER.x, 0.0, 0.0)
	geom.add_child(spire)
	var rock_mat: StandardMaterial3D = StandardMaterial3D.new()
	rock_mat.albedo_color = Color(0.65, 0.45, 0.20)
	rock_mat.emission_enabled = true
	rock_mat.emission = Color(0.55, 0.35, 0.15)
	rock_mat.emission_energy_multiplier = 0.18
	rock_mat.roughness = 0.92
	var darker_rock: StandardMaterial3D = StandardMaterial3D.new()
	darker_rock.albedo_color = Color(0.55, 0.38, 0.18)
	darker_rock.roughness = 0.92
	# 4 tapered tiers
	var tier_data: Array = [
		{"top": 1.85, "bot": 2.40, "h": 3.40, "y": 1.70},
		{"top": 1.40, "bot": 1.85, "h": 2.85, "y": 4.85},
		{"top": 0.95, "bot": 1.40, "h": 2.40, "y": 7.50},
		{"top": 0.55, "bot": 0.95, "h": 1.85, "y": 9.85},
	]
	for tier in tier_data:
		var t: MeshInstance3D = MeshInstance3D.new()
		var tm: CylinderMesh = CylinderMesh.new()
		tm.top_radius = tier["top"]
		tm.bottom_radius = tier["bot"]
		tm.height = tier["h"]
		t.mesh = tm
		t.material_override = rock_mat
		t.position = Vector3(0, tier["y"], 0)
		spire.add_child(t)
	# Top amber crystal
	var crystal: MeshInstance3D = MeshInstance3D.new()
	var crm: PrismMesh = PrismMesh.new()
	crm.size = Vector3(0.85, 1.85, 0.85)
	crystal.mesh = crm
	var crystal_mat: StandardMaterial3D = StandardMaterial3D.new()
	crystal_mat.albedo_color = Color(0.95, 0.65, 0.20)
	crystal_mat.emission_enabled = true
	crystal_mat.emission = Color(0.95, 0.55, 0.10)
	crystal_mat.emission_energy_multiplier = 3.5
	crystal_mat.metallic = 0.30
	crystal_mat.roughness = 0.10
	crystal_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	crystal.material_override = crystal_mat
	crystal.position = Vector3(0, 11.85, 0)
	spire.add_child(crystal)
	# Crystal pulse
	var tw: Tween = crystal.create_tween().set_loops()
	tw.tween_property(crystal, "scale", Vector3.ONE * 1.20, 1.4)
	tw.tween_property(crystal, "scale", Vector3.ONE * 0.85, 1.4)
	# 4 darker rock outcroppings around the base for visual texture
	for i in 4:
		var ang: float = (TAU / 4.0) * i + PI / 4.0
		var outcrop: MeshInstance3D = MeshInstance3D.new()
		var om: SphereMesh = SphereMesh.new()
		om.radius = 0.85
		om.height = 1.40
		outcrop.mesh = om
		outcrop.material_override = darker_rock
		outcrop.position = Vector3(cos(ang) * 2.85, 0.55, sin(ang) * 2.85)
		outcrop.scale = Vector3(1.0, 0.55, 1.0)
		spire.add_child(outcrop)
	# Massive aura light
	var light: OmniLight3D = OmniLight3D.new()
	light.light_color = Color(1.0, 0.65, 0.30)
	light.light_energy = 4.5
	light.omni_range = 18.0
	light.position = Vector3(0, 11.85, 0)
	spire.add_child(light)
	# Spire collision (single capsule covering all tiers)
	var sb: StaticBody3D = StaticBody3D.new()
	sb.position = Vector3(0, 5.85, 0)
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cap: CylinderShape3D = CylinderShape3D.new()
	cap.radius = 2.40
	cap.height = 11.0
	cs.shape = cap
	sb.add_child(cs)
	spire.add_child(sb)


static func _build_d7_monk_elder_npc(town: Node) -> void:
	## Epic-7 T4: monk elder NPC — orange robe + bald head + held wooden
	## prayer beads.
	var npc_slots: Node3D = town.get_node_or_null("%NPCSlots") as Node3D
	if npc_slots == null:
		return
	var slot: Marker3D = Marker3D.new()
	slot.name = "MonkElderSlot"
	slot.position = Vector3(D7_CENTER.x - 28.0, 0.0, 4.0)
	npc_slots.add_child(slot)
	var npc_scene: PackedScene = load("res://scenes/entities/npcs/VillagerR3.tscn") as PackedScene
	if npc_scene == null:
		return
	var npc: Node3D = npc_scene.instantiate() as Node3D
	npc.name = "MonkElder"
	if "npc_name" in npc:
		npc.set("npc_name", "Sutta")
	if "npc_id" in npc:
		npc.set("npc_id", "monk_elder_d7")
	slot.add_child(npc)
	# Orange robe
	var robe: MeshInstance3D = MeshInstance3D.new()
	var rm: BoxMesh = BoxMesh.new()
	rm.size = Vector3(0.65, 1.20, 0.45)
	robe.mesh = rm
	var robe_mat: StandardMaterial3D = StandardMaterial3D.new()
	robe_mat.albedo_color = Color(0.95, 0.55, 0.20)
	robe_mat.emission_enabled = true
	robe_mat.emission = Color(0.95, 0.45, 0.15)
	robe_mat.emission_energy_multiplier = 0.30
	robe_mat.roughness = 0.85
	robe.material_override = robe_mat
	robe.position = Vector3(0, 0.60, 0)
	npc.add_child(robe)
	# Bald head dome (small sphere)
	var dome: MeshInstance3D = MeshInstance3D.new()
	var dm: SphereMesh = SphereMesh.new()
	dm.radius = 0.20
	dm.height = 0.36
	dome.mesh = dm
	var skin_mat: StandardMaterial3D = StandardMaterial3D.new()
	skin_mat.albedo_color = Color(0.95, 0.85, 0.65)
	skin_mat.roughness = 0.65
	dome.material_override = skin_mat
	dome.position = Vector3(0, 1.50, 0)
	npc.add_child(dome)
	# Prayer beads (small torus around hand)
	var beads: MeshInstance3D = MeshInstance3D.new()
	var bm: TorusMesh = TorusMesh.new()
	bm.inner_radius = 0.10
	bm.outer_radius = 0.14
	beads.mesh = bm
	var bead_mat: StandardMaterial3D = StandardMaterial3D.new()
	bead_mat.albedo_color = Color(0.55, 0.30, 0.10)
	bead_mat.emission_enabled = true
	bead_mat.emission = Color(0.85, 0.55, 0.20)
	bead_mat.emission_energy_multiplier = 0.45
	bead_mat.metallic = 0.55
	bead_mat.roughness = 0.30
	beads.material_override = bead_mat
	beads.position = Vector3(0.40, 0.85, 0.20)
	beads.rotation_degrees = Vector3(0, 0, 90)
	npc.add_child(beads)


static func _build_d7_prayer_flags(geom: Node) -> void:
	## Epic-7 T6: long string of colorful prayer flags strung between 2
	## tall poles. 5 colors traditional: blue, white, red, green, yellow.
	var flags: Node3D = Node3D.new()
	flags.name = "PrayerFlags"
	flags.position = Vector3(D7_CENTER.x - 14.0, 0.0, 8.0)
	geom.add_child(flags)
	var wood_mat: StandardMaterial3D = StandardMaterial3D.new()
	wood_mat.albedo_color = Color(0.45, 0.28, 0.12)
	wood_mat.roughness = 0.85
	# 2 tall vertical poles
	for sx in [-3.20, 3.20]:
		var pole: MeshInstance3D = MeshInstance3D.new()
		var pm: CylinderMesh = CylinderMesh.new()
		pm.top_radius = 0.06
		pm.bottom_radius = 0.10
		pm.height = 4.20
		pole.mesh = pm
		pole.material_override = wood_mat
		pole.position = Vector3(sx, 2.10, 0)
		flags.add_child(pole)
		# Pole collision
		var sb: StaticBody3D = StaticBody3D.new()
		sb.position = Vector3(sx, 2.10, 0)
		var cs: CollisionShape3D = CollisionShape3D.new()
		var cap: CapsuleShape3D = CapsuleShape3D.new()
		cap.radius = 0.10
		cap.height = 4.20
		cs.shape = cap
		sb.add_child(cs)
		flags.add_child(sb)
	# Long horizontal wire connecting poles
	var wire: MeshInstance3D = MeshInstance3D.new()
	var wm: CylinderMesh = CylinderMesh.new()
	wm.top_radius = 0.018
	wm.bottom_radius = 0.018
	wm.height = 6.40
	wire.mesh = wm
	var wire_mat: StandardMaterial3D = StandardMaterial3D.new()
	wire_mat.albedo_color = Color(0.30, 0.25, 0.20)
	wire.material_override = wire_mat
	wire.position = Vector3(0, 4.0, 0)
	wire.rotation_degrees = Vector3(0, 0, 90)
	flags.add_child(wire)
	# 12 prayer flags hanging down (cycling 5 traditional colors)
	var flag_colors: Array = [
		Color(0.30, 0.40, 0.95),  # blue
		Color(0.95, 0.95, 0.92),  # white
		Color(0.95, 0.20, 0.30),  # red
		Color(0.30, 0.85, 0.30),  # green
		Color(0.95, 0.85, 0.20),  # yellow
	]
	for i in 12:
		var flag: MeshInstance3D = MeshInstance3D.new()
		var fm: BoxMesh = BoxMesh.new()
		fm.size = Vector3(0.40, 0.55, 0.04)
		flag.mesh = fm
		var col: Color = flag_colors[i % 5]
		var flag_mat: StandardMaterial3D = StandardMaterial3D.new()
		flag_mat.albedo_color = col
		flag_mat.emission_enabled = true
		flag_mat.emission = col
		flag_mat.emission_energy_multiplier = 0.65
		flag_mat.roughness = 0.85
		flag.material_override = flag_mat
		flag.position = Vector3(-2.85 + i * 0.55, 3.55, 0)
		flags.add_child(flag)
		# Sway tween (offset per flag)
		var tw: Tween = flag.create_tween().set_loops()
		tw.tween_interval(i * 0.08)
		tw.tween_property(flag, "rotation_degrees:y", 8.0, 1.4)
		tw.tween_property(flag, "rotation_degrees:y", -8.0, 1.4)


static func _build_d7_stone_cairns(geom: Node) -> void:
	## Epic-7 T7: 4 meditation stone cairns — stacks of 5 progressively
	## smaller flat rocks each.
	var cairns: Node3D = Node3D.new()
	cairns.name = "StoneCairns"
	cairns.position = Vector3(D7_CENTER.x - 8.0, 0.0, 14.0)
	geom.add_child(cairns)
	var rock_mat: StandardMaterial3D = StandardMaterial3D.new()
	rock_mat.albedo_color = Color(0.55, 0.45, 0.30)
	rock_mat.roughness = 0.92
	for i in 4:
		var cairn: Node3D = Node3D.new()
		cairn.position = Vector3(i * 1.85, 0, 0)
		cairns.add_child(cairn)
		# 5 stacked rocks (decreasing size)
		var sizes: Array = [0.55, 0.42, 0.30, 0.22, 0.15]
		var ys: Array = [0.10, 0.30, 0.50, 0.65, 0.78]
		for j in 5:
			var rock: MeshInstance3D = MeshInstance3D.new()
			var rm: SphereMesh = SphereMesh.new()
			rm.radius = sizes[j]
			rm.height = sizes[j] * 0.85
			rock.mesh = rm
			rock.material_override = rock_mat
			rock.position = Vector3(0, ys[j], 0)
			rock.scale = Vector3(1.0, 0.55, 1.0)
			rock.rotation_degrees = Vector3(0, randf_range(0, 360), 0)
			cairn.add_child(rock)
		# Cairn collision
		var sb: StaticBody3D = StaticBody3D.new()
		sb.position = Vector3(0, 0.45, 0)
		var cs: CollisionShape3D = CollisionShape3D.new()
		var cap: CapsuleShape3D = CapsuleShape3D.new()
		cap.radius = 0.55
		cap.height = 0.85
		cs.shape = cap
		sb.add_child(cs)
		cairn.add_child(sb)


static func _build_d7_monk_acolyte_npc(town: Node) -> void:
	## Epic-7 T8: monk acolyte NPC — smaller scale + saffron robe.
	var npc_slots: Node3D = town.get_node_or_null("%NPCSlots") as Node3D
	if npc_slots == null:
		return
	var slot: Marker3D = Marker3D.new()
	slot.name = "MonkAcolyteSlot"
	slot.position = Vector3(D7_CENTER.x - 4.0, 0.0, 14.0)
	npc_slots.add_child(slot)
	var npc_scene: PackedScene = load("res://scenes/entities/npcs/VillagerR3.tscn") as PackedScene
	if npc_scene == null:
		return
	var npc: Node3D = npc_scene.instantiate() as Node3D
	npc.name = "MonkAcolyte"
	if "npc_name" in npc:
		npc.set("npc_name", "Novice")
	if "npc_id" in npc:
		npc.set("npc_id", "acolyte_d7")
	npc.scale = Vector3(0.85, 0.85, 0.85)
	slot.add_child(npc)
	# Saffron robe
	var robe: MeshInstance3D = MeshInstance3D.new()
	var rm: BoxMesh = BoxMesh.new()
	rm.size = Vector3(0.65, 1.10, 0.45)
	robe.mesh = rm
	var robe_mat: StandardMaterial3D = StandardMaterial3D.new()
	robe_mat.albedo_color = Color(0.95, 0.65, 0.20)
	robe_mat.emission_enabled = true
	robe_mat.emission = Color(0.95, 0.55, 0.10)
	robe_mat.emission_energy_multiplier = 0.30
	robe_mat.roughness = 0.85
	robe.material_override = robe_mat
	robe.position = Vector3(0, 0.55, 0)
	npc.add_child(robe)
	# Bald head
	var dome: MeshInstance3D = MeshInstance3D.new()
	var dm: SphereMesh = SphereMesh.new()
	dm.radius = 0.20
	dm.height = 0.36
	dome.mesh = dm
	var skin_mat: StandardMaterial3D = StandardMaterial3D.new()
	skin_mat.albedo_color = Color(0.95, 0.85, 0.65)
	skin_mat.roughness = 0.65
	dome.material_override = skin_mat
	dome.position = Vector3(0, 1.42, 0)
	npc.add_child(dome)


static func _build_d7_incense_burner(geom: Node) -> void:
	## Epic-7 T9: incense burner — short bronze tripod cauldron with rising
	## smoke particles and a soft warm glow.
	var burner: Node3D = Node3D.new()
	burner.name = "IncenseBurner"
	burner.position = Vector3(D7_CENTER.x + 4.0, 0.0, 14.0)
	geom.add_child(burner)
	var bronze_mat: StandardMaterial3D = StandardMaterial3D.new()
	bronze_mat.albedo_color = Color(0.65, 0.45, 0.20)
	bronze_mat.metallic = 0.85
	bronze_mat.roughness = 0.30
	# 3 tripod legs
	for i in 3:
		var ang: float = (TAU / 3.0) * i
		var leg: MeshInstance3D = MeshInstance3D.new()
		var lm: CylinderMesh = CylinderMesh.new()
		lm.top_radius = 0.04
		lm.bottom_radius = 0.06
		lm.height = 0.85
		leg.mesh = lm
		leg.material_override = bronze_mat
		leg.position = Vector3(cos(ang) * 0.30, 0.42, sin(ang) * 0.30)
		leg.rotation = Vector3(deg_to_rad(15) * sin(ang), 0, deg_to_rad(15) * cos(ang))
		burner.add_child(leg)
	# Cauldron bowl (sphere)
	var bowl: MeshInstance3D = MeshInstance3D.new()
	var bm: SphereMesh = SphereMesh.new()
	bm.radius = 0.40
	bm.height = 0.55
	bowl.mesh = bm
	bowl.material_override = bronze_mat
	bowl.position = Vector3(0, 1.0, 0)
	bowl.scale = Vector3(1.0, 0.65, 1.0)
	burner.add_child(bowl)
	# Glowing coals inside (small bright sphere)
	var coals: MeshInstance3D = MeshInstance3D.new()
	var cm: SphereMesh = SphereMesh.new()
	cm.radius = 0.20
	cm.height = 0.18
	coals.mesh = cm
	var coal_mat: StandardMaterial3D = StandardMaterial3D.new()
	coal_mat.albedo_color = Color(1.0, 0.45, 0.10)
	coal_mat.emission_enabled = true
	coal_mat.emission = Color(1.0, 0.45, 0.10)
	coal_mat.emission_energy_multiplier = 3.5
	coal_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	coals.material_override = coal_mat
	coals.position = Vector3(0, 1.10, 0)
	burner.add_child(coals)
	# Smoke particles
	var smoke: GPUParticles3D = GPUParticles3D.new()
	smoke.amount = 30
	smoke.lifetime = 3.0
	smoke.preprocess = 1.5
	smoke.position = Vector3(0, 1.30, 0)
	var pm: ParticleProcessMaterial = ParticleProcessMaterial.new()
	pm.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_POINT
	pm.direction = Vector3(0, 1, 0)
	pm.spread = 18.0
	pm.gravity = Vector3.ZERO
	pm.initial_velocity_min = 0.30
	pm.initial_velocity_max = 0.65
	pm.scale_min = 0.18
	pm.scale_max = 0.40
	pm.color = Color(0.85, 0.75, 0.55, 0.65)
	smoke.process_material = pm
	var sm_mesh: SphereMesh = SphereMesh.new()
	sm_mesh.radius = 0.18
	sm_mesh.height = 0.36
	smoke.draw_pass_1 = sm_mesh
	var sm_mat: StandardMaterial3D = StandardMaterial3D.new()
	sm_mat.albedo_color = Color(0.85, 0.75, 0.55, 0.55)
	sm_mat.emission_enabled = true
	sm_mat.emission = Color(0.85, 0.65, 0.30)
	sm_mat.emission_energy_multiplier = 0.85
	sm_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	sm_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	sm_mesh.material = sm_mat
	burner.add_child(smoke)
	# Warm glow light
	var light: OmniLight3D = OmniLight3D.new()
	light.light_color = Color(1.0, 0.55, 0.20)
	light.light_energy = 1.6
	light.omni_range = 4.0
	light.position = Vector3(0, 1.10, 0)
	burner.add_child(light)
	# Burner collision
	var sb: StaticBody3D = StaticBody3D.new()
	sb.position = Vector3(0, 0.85, 0)
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cap: CapsuleShape3D = CapsuleShape3D.new()
	cap.radius = 0.40
	cap.height = 1.40
	cs.shape = cap
	sb.add_child(cs)
	burner.add_child(sb)


static func _build_d7_brass_gong(geom: Node) -> void:
	## Epic-7 T10: brass gong on a wooden frame — large flat brass disc
	## suspended between two pillars with a striker hammer beside it.
	var gong: Node3D = Node3D.new()
	gong.name = "BrassGong"
	gong.position = Vector3(D7_CENTER.x + 12.0, 0.0, 14.0)
	geom.add_child(gong)
	var wood_mat: StandardMaterial3D = StandardMaterial3D.new()
	wood_mat.albedo_color = Color(0.45, 0.28, 0.12)
	wood_mat.roughness = 0.85
	var brass_mat: StandardMaterial3D = StandardMaterial3D.new()
	brass_mat.albedo_color = Color(0.95, 0.75, 0.20)
	brass_mat.emission_enabled = true
	brass_mat.emission = Color(0.95, 0.65, 0.10)
	brass_mat.emission_energy_multiplier = 0.65
	brass_mat.metallic = 0.95
	brass_mat.roughness = 0.10
	# 2 wooden pillars
	for sx in [-1.40, 1.40]:
		var pillar: MeshInstance3D = MeshInstance3D.new()
		var pm: CylinderMesh = CylinderMesh.new()
		pm.top_radius = 0.10
		pm.bottom_radius = 0.14
		pm.height = 3.20
		pillar.mesh = pm
		pillar.material_override = wood_mat
		pillar.position = Vector3(sx, 1.60, 0)
		gong.add_child(pillar)
		# Pillar collision
		var sb: StaticBody3D = StaticBody3D.new()
		sb.position = Vector3(sx, 1.60, 0)
		var cs: CollisionShape3D = CollisionShape3D.new()
		var cap: CapsuleShape3D = CapsuleShape3D.new()
		cap.radius = 0.18
		cap.height = 3.20
		cs.shape = cap
		sb.add_child(cs)
		gong.add_child(sb)
	# Top crossbar
	var crossbar: MeshInstance3D = MeshInstance3D.new()
	var cm: CylinderMesh = CylinderMesh.new()
	cm.top_radius = 0.08
	cm.bottom_radius = 0.08
	cm.height = 3.20
	crossbar.mesh = cm
	crossbar.material_override = wood_mat
	crossbar.position = Vector3(0, 3.20, 0)
	crossbar.rotation_degrees = Vector3(0, 0, 90)
	gong.add_child(crossbar)
	# Brass gong disc (flat cylinder)
	var disc: MeshInstance3D = MeshInstance3D.new()
	var dm: CylinderMesh = CylinderMesh.new()
	dm.top_radius = 1.20
	dm.bottom_radius = 1.20
	dm.height = 0.10
	disc.mesh = dm
	disc.material_override = brass_mat
	disc.position = Vector3(0, 1.85, 0)
	disc.rotation_degrees = Vector3(90, 0, 0)
	gong.add_child(disc)
	# Subtle gong sway tween (suggesting a recent strike)
	var tw: Tween = disc.create_tween().set_loops()
	tw.tween_property(disc, "rotation_degrees:z", 4.0, 1.6)
	tw.tween_property(disc, "rotation_degrees:z", -4.0, 1.6)
	# Center boss (small bronze sphere on disc)
	var boss: MeshInstance3D = MeshInstance3D.new()
	var bsm: SphereMesh = SphereMesh.new()
	bsm.radius = 0.18
	bsm.height = 0.30
	boss.mesh = bsm
	boss.material_override = brass_mat
	boss.position = Vector3(0, 1.85, 0.10)
	gong.add_child(boss)
	# Striker hammer (wooden handle + soft head) leaning against pillar
	var hammer_handle: MeshInstance3D = MeshInstance3D.new()
	var hhm: CylinderMesh = CylinderMesh.new()
	hhm.top_radius = 0.04
	hhm.bottom_radius = 0.05
	hhm.height = 1.20
	hammer_handle.mesh = hhm
	hammer_handle.material_override = wood_mat
	hammer_handle.position = Vector3(1.85, 0.65, 0)
	hammer_handle.rotation_degrees = Vector3(0, 0, -25)
	gong.add_child(hammer_handle)
	var hammer_head: MeshInstance3D = MeshInstance3D.new()
	var hdm: SphereMesh = SphereMesh.new()
	hdm.radius = 0.18
	hdm.height = 0.30
	hammer_head.mesh = hdm
	var head_mat: StandardMaterial3D = StandardMaterial3D.new()
	head_mat.albedo_color = Color(0.85, 0.20, 0.30)
	head_mat.roughness = 0.85
	hammer_head.material_override = head_mat
	hammer_head.position = Vector3(1.55, 1.20, 0)
	gong.add_child(hammer_head)
	# Warm light from the gong
	var light: OmniLight3D = OmniLight3D.new()
	light.light_color = Color(1.0, 0.85, 0.30)
	light.light_energy = 1.6
	light.omni_range = 4.0
	light.position = Vector3(0, 1.85, 0.40)
	gong.add_child(light)


static func _build_d7_stone_bridge(geom: Node) -> void:
	## Epic-7 T11: long stone bridge across a small chasm — flat deck
	## with rounded ends + 2 stone railings + dark recessed chasm.
	var bridge: Node3D = Node3D.new()
	bridge.name = "D7StoneBridge"
	bridge.position = Vector3(D7_CENTER.x - 14.0, 0.0, -8.0)
	geom.add_child(bridge)
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.55, 0.45, 0.30)
	stone_mat.roughness = 0.92
	# Chasm (recessed dark cylinder)
	var chasm: MeshInstance3D = MeshInstance3D.new()
	var cm: BoxMesh = BoxMesh.new()
	cm.size = Vector3(7.0, 0.40, 4.20)
	chasm.mesh = cm
	var chasm_mat: StandardMaterial3D = StandardMaterial3D.new()
	chasm_mat.albedo_color = Color(0.10, 0.05, 0.05)
	chasm_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	chasm.material_override = chasm_mat
	chasm.position = Vector3(0, -0.18, 0)
	bridge.add_child(chasm)
	# Bridge deck (long slab)
	var deck: MeshInstance3D = MeshInstance3D.new()
	var dm: BoxMesh = BoxMesh.new()
	dm.size = Vector3(8.50, 0.30, 2.40)
	deck.mesh = dm
	deck.material_override = stone_mat
	deck.position = Vector3(0, 0.55, 0)
	bridge.add_child(deck)
	# 2 stone railings (lower)
	for sz in [-1.10, 1.10]:
		var rail: MeshInstance3D = MeshInstance3D.new()
		var rm: BoxMesh = BoxMesh.new()
		rm.size = Vector3(8.50, 0.65, 0.20)
		rail.mesh = rm
		rail.material_override = stone_mat
		rail.position = Vector3(0, 1.0, sz)
		bridge.add_child(rail)
	# 6 small balusters along each rail
	for sz in [-1.10, 1.10]:
		for i in 6:
			var bal: MeshInstance3D = MeshInstance3D.new()
			var bm: BoxMesh = BoxMesh.new()
			bm.size = Vector3(0.18, 0.65, 0.18)
			bal.mesh = bm
			bal.material_override = stone_mat
			bal.position = Vector3(-3.50 + i * 1.40, 1.0, sz)
			bridge.add_child(bal)
	# Deck collision
	var sb: StaticBody3D = StaticBody3D.new()
	sb.position = Vector3(0, 0.70, 0)
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(8.50, 0.40, 2.40)
	cs.shape = cb
	sb.add_child(cs)
	bridge.add_child(sb)
	# Rail collisions
	for sz in [-1.10, 1.10]:
		var rsb: StaticBody3D = StaticBody3D.new()
		rsb.position = Vector3(0, 1.0, sz)
		var rcs: CollisionShape3D = CollisionShape3D.new()
		var rcb: BoxShape3D = BoxShape3D.new()
		rcb.size = Vector3(8.50, 0.65, 0.20)
		rcs.shape = rcb
		rsb.add_child(rcs)
		bridge.add_child(rsb)


static func _build_d7_spring_fountain(geom: Node) -> void:
	## Epic-7 T12: small mountain spring fountain — round stone basin +
	## central column + cyan water disc + rising steam.
	var fountain: Node3D = Node3D.new()
	fountain.name = "SpringFountain"
	fountain.position = Vector3(D7_CENTER.x - 4.0, 0.0, -2.0)
	geom.add_child(fountain)
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.55, 0.45, 0.30)
	stone_mat.roughness = 0.92
	# Outer basin
	var basin: MeshInstance3D = MeshInstance3D.new()
	var bm: CylinderMesh = CylinderMesh.new()
	bm.top_radius = 1.40
	bm.bottom_radius = 1.55
	bm.height = 0.55
	basin.mesh = bm
	basin.material_override = stone_mat
	basin.position = Vector3(0, 0.27, 0)
	fountain.add_child(basin)
	# Water surface (translucent cyan)
	var water: MeshInstance3D = MeshInstance3D.new()
	var wm: CylinderMesh = CylinderMesh.new()
	wm.top_radius = 1.20
	wm.bottom_radius = 1.20
	wm.height = 0.06
	water.mesh = wm
	var water_mat: StandardMaterial3D = StandardMaterial3D.new()
	water_mat.albedo_color = Color(0.40, 0.85, 0.95, 0.65)
	water_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	water_mat.emission_enabled = true
	water_mat.emission = Color(0.30, 0.95, 1.0)
	water_mat.emission_energy_multiplier = 0.85
	water_mat.metallic = 0.30
	water_mat.roughness = 0.05
	water.material_override = water_mat
	water.position = Vector3(0, 0.50, 0)
	fountain.add_child(water)
	# Bob the water
	var tw: Tween = water.create_tween().set_loops()
	tw.tween_property(water, "position:y", 0.55, 1.4)
	tw.tween_property(water, "position:y", 0.50, 1.4)
	# Central column (small stone post)
	var col: MeshInstance3D = MeshInstance3D.new()
	var clm: CylinderMesh = CylinderMesh.new()
	clm.top_radius = 0.18
	clm.bottom_radius = 0.22
	clm.height = 0.85
	col.mesh = clm
	col.material_override = stone_mat
	col.position = Vector3(0, 0.85, 0)
	fountain.add_child(col)
	# Top spout (small bowl on column)
	var spout: MeshInstance3D = MeshInstance3D.new()
	var spm: CylinderMesh = CylinderMesh.new()
	spm.top_radius = 0.30
	spm.bottom_radius = 0.20
	spm.height = 0.18
	spout.mesh = spm
	spout.material_override = stone_mat
	spout.position = Vector3(0, 1.30, 0)
	fountain.add_child(spout)
	# Steam particles rising
	var steam: GPUParticles3D = GPUParticles3D.new()
	steam.amount = 25
	steam.lifetime = 2.5
	steam.preprocess = 1.0
	steam.position = Vector3(0, 0.75, 0)
	var pm: ParticleProcessMaterial = ParticleProcessMaterial.new()
	pm.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	pm.emission_box_extents = Vector3(0.85, 0.05, 0.85)
	pm.direction = Vector3(0, 1, 0)
	pm.spread = 22.0
	pm.gravity = Vector3(0, 0.45, 0)
	pm.initial_velocity_min = 0.30
	pm.initial_velocity_max = 0.65
	pm.scale_min = 0.18
	pm.scale_max = 0.40
	pm.color = Color(0.95, 0.92, 0.95, 0.55)
	steam.process_material = pm
	var sm_mesh: SphereMesh = SphereMesh.new()
	sm_mesh.radius = 0.18
	sm_mesh.height = 0.36
	steam.draw_pass_1 = sm_mesh
	var sm_mat: StandardMaterial3D = StandardMaterial3D.new()
	sm_mat.albedo_color = Color(0.95, 0.95, 1.0, 0.45)
	sm_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	sm_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	sm_mesh.material = sm_mat
	fountain.add_child(steam)
	# Soft warm light
	var light: OmniLight3D = OmniLight3D.new()
	light.light_color = Color(0.85, 0.95, 1.0)
	light.light_energy = 1.6
	light.omni_range = 4.0
	light.position = Vector3(0, 0.85, 0)
	fountain.add_child(light)
	# Basin collision
	var sb: StaticBody3D = StaticBody3D.new()
	sb.position = Vector3(0, 0.27, 0)
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cap: CylinderShape3D = CylinderShape3D.new()
	cap.radius = 1.55
	cap.height = 0.55
	cs.shape = cap
	sb.add_child(cs)
	fountain.add_child(sb)


static func _build_d7_bell_tower(geom: Node) -> void:
	## Epic-7 T13: tall stone bell tower — square stone base column +
	## sloped roof + large brass bell hanging in the open top room.
	var tower: Node3D = Node3D.new()
	tower.name = "BellTower"
	tower.position = Vector3(D7_CENTER.x + 4.0, 0.0, -8.0)
	geom.add_child(tower)
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.55, 0.45, 0.30)
	stone_mat.roughness = 0.92
	# Tall stone tower body
	var body: MeshInstance3D = MeshInstance3D.new()
	var bm: BoxMesh = BoxMesh.new()
	bm.size = Vector3(2.40, 5.50, 2.40)
	body.mesh = bm
	body.material_override = stone_mat
	body.position = Vector3(0, 2.75, 0)
	tower.add_child(body)
	# Bell room (smaller block on top)
	var bell_room: MeshInstance3D = MeshInstance3D.new()
	var brm: BoxMesh = BoxMesh.new()
	brm.size = Vector3(2.0, 1.40, 2.0)
	bell_room.mesh = brm
	bell_room.material_override = stone_mat
	bell_room.position = Vector3(0, 6.20, 0)
	tower.add_child(bell_room)
	# Open arches on bell room (4 dark cutouts)
	var dark_mat: StandardMaterial3D = StandardMaterial3D.new()
	dark_mat.albedo_color = Color(0.10, 0.08, 0.10)
	dark_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for d in [Vector3(0, 6.20, 1.0), Vector3(0, 6.20, -1.0), Vector3(1.0, 6.20, 0), Vector3(-1.0, 6.20, 0)]:
		var arch: MeshInstance3D = MeshInstance3D.new()
		var am: BoxMesh = BoxMesh.new()
		am.size = Vector3(0.85, 0.85, 0.10)
		arch.mesh = am
		arch.material_override = dark_mat
		arch.position = d
		if d.z == 0:
			arch.rotation_degrees = Vector3(0, 90, 0)
		tower.add_child(arch)
	# Sloped roof
	var roof: MeshInstance3D = MeshInstance3D.new()
	var rm: PrismMesh = PrismMesh.new()
	rm.size = Vector3(2.40, 0.85, 2.40)
	roof.mesh = rm
	var roof_mat: StandardMaterial3D = StandardMaterial3D.new()
	roof_mat.albedo_color = Color(0.40, 0.20, 0.15)
	roof.material_override = roof_mat
	roof.position = Vector3(0, 7.30, 0)
	tower.add_child(roof)
	# Brass bell hanging in the room
	var brass_mat: StandardMaterial3D = StandardMaterial3D.new()
	brass_mat.albedo_color = Color(0.95, 0.75, 0.20)
	brass_mat.emission_enabled = true
	brass_mat.emission = Color(0.95, 0.65, 0.10)
	brass_mat.emission_energy_multiplier = 0.65
	brass_mat.metallic = 0.95
	brass_mat.roughness = 0.10
	# Bell pivot for sway tween
	var bell_pivot: Node3D = Node3D.new()
	bell_pivot.position = Vector3(0, 6.85, 0)
	tower.add_child(bell_pivot)
	var bell: MeshInstance3D = MeshInstance3D.new()
	var bm2: SphereMesh = SphereMesh.new()
	bm2.radius = 0.45
	bm2.height = 0.85
	bell.mesh = bm2
	bell.material_override = brass_mat
	bell.position = Vector3(0, -0.55, 0)
	bell.scale = Vector3(1.0, 0.85, 1.0)
	bell_pivot.add_child(bell)
	# Slow bell sway tween
	var tw: Tween = bell_pivot.create_tween().set_loops()
	tw.tween_property(bell_pivot, "rotation_degrees:x", 8.0, 1.4)
	tw.tween_property(bell_pivot, "rotation_degrees:x", -8.0, 1.4)
	# Warm light from bell room
	var light: OmniLight3D = OmniLight3D.new()
	light.light_color = Color(1.0, 0.85, 0.30)
	light.light_energy = 2.5
	light.omni_range = 6.0
	light.position = Vector3(0, 6.20, 0)
	tower.add_child(light)
	# Tower body collision
	var sb: StaticBody3D = StaticBody3D.new()
	sb.position = Vector3(0, 2.75, 0)
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(2.40, 5.50, 2.40)
	cs.shape = cb
	sb.add_child(cs)
	tower.add_child(sb)


static func _build_d7_bellringer_npc(town: Node) -> void:
	## Epic-7 T14: bellringer NPC at the base of the bell tower —
	## brown robe + holding a long rope.
	var npc_slots: Node3D = town.get_node_or_null("%NPCSlots") as Node3D
	if npc_slots == null:
		return
	var slot: Marker3D = Marker3D.new()
	slot.name = "BellringerSlot"
	slot.position = Vector3(D7_CENTER.x + 5.0, 0.0, -7.0)
	npc_slots.add_child(slot)
	var npc_scene: PackedScene = load("res://scenes/entities/npcs/VillagerR3.tscn") as PackedScene
	if npc_scene == null:
		return
	var npc: Node3D = npc_scene.instantiate() as Node3D
	npc.name = "Bellringer"
	if "npc_name" in npc:
		npc.set("npc_name", "Tolling")
	if "npc_id" in npc:
		npc.set("npc_id", "bellringer_d7")
	slot.add_child(npc)
	# Brown robe
	var robe: MeshInstance3D = MeshInstance3D.new()
	var rm: BoxMesh = BoxMesh.new()
	rm.size = Vector3(0.65, 1.20, 0.45)
	robe.mesh = rm
	var robe_mat: StandardMaterial3D = StandardMaterial3D.new()
	robe_mat.albedo_color = Color(0.45, 0.28, 0.12)
	robe_mat.roughness = 0.85
	robe.material_override = robe_mat
	robe.position = Vector3(0, 0.60, 0)
	npc.add_child(robe)
	# Long thin rope going up (representing the bell pull)
	var rope: MeshInstance3D = MeshInstance3D.new()
	var rmm: CylinderMesh = CylinderMesh.new()
	rmm.top_radius = 0.025
	rmm.bottom_radius = 0.025
	rmm.height = 4.85
	rope.mesh = rmm
	var rope_mat: StandardMaterial3D = StandardMaterial3D.new()
	rope_mat.albedo_color = Color(0.55, 0.40, 0.20)
	rope_mat.roughness = 0.85
	rope.material_override = rope_mat
	rope.position = Vector3(0.40, 3.10, 0)
	npc.add_child(rope)


static func _build_d7_cliff_face(geom: Node) -> void:
	## Epic-7 T15: tall sandstone cliff face wall — large vertical rock
	## slab with a few horizontal stratification bands.
	var cliff: Node3D = Node3D.new()
	cliff.name = "CliffFace"
	cliff.position = Vector3(D7_CENTER.x + 14.0, 0.0, -16.0)
	geom.add_child(cliff)
	var rock_mat: StandardMaterial3D = StandardMaterial3D.new()
	rock_mat.albedo_color = Color(0.65, 0.45, 0.20)
	rock_mat.emission_enabled = true
	rock_mat.emission = Color(0.55, 0.35, 0.15)
	rock_mat.emission_energy_multiplier = 0.18
	rock_mat.roughness = 0.92
	var darker_rock: StandardMaterial3D = StandardMaterial3D.new()
	darker_rock.albedo_color = Color(0.45, 0.30, 0.15)
	darker_rock.roughness = 0.92
	# Main cliff slab
	var slab: MeshInstance3D = MeshInstance3D.new()
	var sm: BoxMesh = BoxMesh.new()
	sm.size = Vector3(14.0, 8.50, 1.40)
	slab.mesh = sm
	slab.material_override = rock_mat
	slab.position = Vector3(0, 4.25, 0)
	cliff.add_child(slab)
	# 5 horizontal stratification bands (darker thin slabs)
	for i in 5:
		var band: MeshInstance3D = MeshInstance3D.new()
		var bm: BoxMesh = BoxMesh.new()
		bm.size = Vector3(14.20, 0.18, 1.50)
		band.mesh = bm
		band.material_override = darker_rock
		band.position = Vector3(0, 1.40 + i * 1.40, 0)
		cliff.add_child(band)
	# Cliff collision
	var sb: StaticBody3D = StaticBody3D.new()
	sb.position = Vector3(0, 4.25, 0)
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(14.0, 8.50, 1.40)
	cs.shape = cb
	sb.add_child(cs)
	cliff.add_child(sb)


static func _build_d7_meditation_pavilion(geom: Node) -> void:
	## Epic-7 T16: open-air wooden meditation pavilion — square stone
	## platform + 4 corner pillars + curved upturned prism roof.
	var pav: Node3D = Node3D.new()
	pav.name = "MeditationPavilion"
	pav.position = Vector3(D7_CENTER.x - 18.0, 0.0, -2.0)
	geom.add_child(pav)
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.55, 0.45, 0.30)
	stone_mat.roughness = 0.92
	var wood_mat: StandardMaterial3D = StandardMaterial3D.new()
	wood_mat.albedo_color = Color(0.45, 0.28, 0.12)
	wood_mat.roughness = 0.85
	var roof_mat: StandardMaterial3D = StandardMaterial3D.new()
	roof_mat.albedo_color = Color(0.55, 0.20, 0.15)
	roof_mat.roughness = 0.85
	# Stone platform
	var platform: MeshInstance3D = MeshInstance3D.new()
	var pmm: BoxMesh = BoxMesh.new()
	pmm.size = Vector3(3.85, 0.30, 3.85)
	platform.mesh = pmm
	platform.material_override = stone_mat
	platform.position = Vector3(0, 0.15, 0)
	pav.add_child(platform)
	# 4 corner wooden pillars
	for sx in [-1.65, 1.65]:
		for sz in [-1.65, 1.65]:
			var pillar: MeshInstance3D = MeshInstance3D.new()
			var pm: CylinderMesh = CylinderMesh.new()
			pm.top_radius = 0.10
			pm.bottom_radius = 0.14
			pm.height = 2.85
			pillar.mesh = pm
			pillar.material_override = wood_mat
			pillar.position = Vector3(sx, 1.72, sz)
			pav.add_child(pillar)
			# Pillar collision
			var sb: StaticBody3D = StaticBody3D.new()
			sb.position = Vector3(sx, 1.72, sz)
			var cs: CollisionShape3D = CollisionShape3D.new()
			var cap: CapsuleShape3D = CapsuleShape3D.new()
			cap.radius = 0.18
			cap.height = 2.85
			cs.shape = cap
			sb.add_child(cs)
			pav.add_child(sb)
	# Curved upturned prism roof
	var roof: MeshInstance3D = MeshInstance3D.new()
	var rm: PrismMesh = PrismMesh.new()
	rm.size = Vector3(4.85, 1.40, 4.85)
	roof.mesh = rm
	roof.material_override = roof_mat
	roof.position = Vector3(0, 3.85, 0)
	pav.add_child(roof)
	# Subtle warm light
	var light: OmniLight3D = OmniLight3D.new()
	light.light_color = Color(1.0, 0.85, 0.55)
	light.light_energy = 1.6
	light.omni_range = 5.0
	light.position = Vector3(0, 2.50, 0)
	pav.add_child(light)
	# Platform collision
	var sb: StaticBody3D = StaticBody3D.new()
	sb.position = Vector3(0, 0.15, 0)
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(3.85, 0.30, 3.85)
	cs.shape = cb
	sb.add_child(cs)
	pav.add_child(sb)


static func _build_d7_meditating_monk_npc(town: Node) -> void:
	## Epic-7 T17: meditating monk NPC inside the pavilion — sitting in
	## lotus position, body lower than usual.
	var npc_slots: Node3D = town.get_node_or_null("%NPCSlots") as Node3D
	if npc_slots == null:
		return
	var slot: Marker3D = Marker3D.new()
	slot.name = "MeditatingMonkSlot"
	slot.position = Vector3(D7_CENTER.x - 18.0, 0.0, -2.0)
	npc_slots.add_child(slot)
	# Build a custom seated body (no VillagerR3 prefab — needs to look seated)
	var monk: Node3D = Node3D.new()
	monk.name = "MeditatingMonk"
	slot.add_child(monk)
	# Lower torso (squat sphere on the ground level)
	var robe_mat: StandardMaterial3D = StandardMaterial3D.new()
	robe_mat.albedo_color = Color(0.95, 0.55, 0.20)
	robe_mat.emission_enabled = true
	robe_mat.emission = Color(0.95, 0.45, 0.10)
	robe_mat.emission_energy_multiplier = 0.30
	robe_mat.roughness = 0.85
	var torso: MeshInstance3D = MeshInstance3D.new()
	var tm: SphereMesh = SphereMesh.new()
	tm.radius = 0.40
	tm.height = 0.55
	torso.mesh = tm
	torso.material_override = robe_mat
	torso.position = Vector3(0, 0.55, 0)
	torso.scale = Vector3(1.20, 0.85, 1.20)
	monk.add_child(torso)
	# Head sphere
	var head: MeshInstance3D = MeshInstance3D.new()
	var hm: SphereMesh = SphereMesh.new()
	hm.radius = 0.20
	hm.height = 0.36
	head.mesh = hm
	var skin_mat: StandardMaterial3D = StandardMaterial3D.new()
	skin_mat.albedo_color = Color(0.95, 0.85, 0.65)
	skin_mat.roughness = 0.65
	head.material_override = skin_mat
	head.position = Vector3(0, 1.10, 0)
	monk.add_child(head)
	# Folded knees (2 small spheres at sides)
	for sx in [-0.40, 0.40]:
		var knee: MeshInstance3D = MeshInstance3D.new()
		var km: SphereMesh = SphereMesh.new()
		km.radius = 0.18
		km.height = 0.32
		knee.mesh = km
		knee.material_override = robe_mat
		knee.position = Vector3(sx, 0.30, 0)
		knee.scale = Vector3(1.0, 0.65, 1.0)
		monk.add_child(knee)
	# Floating meditation halo (small torus above head)
	var halo: MeshInstance3D = MeshInstance3D.new()
	var hlm: TorusMesh = TorusMesh.new()
	hlm.inner_radius = 0.22
	hlm.outer_radius = 0.28
	halo.mesh = hlm
	var halo_mat: StandardMaterial3D = StandardMaterial3D.new()
	halo_mat.albedo_color = Color(1.0, 0.85, 0.30)
	halo_mat.emission_enabled = true
	halo_mat.emission = Color(1.0, 0.85, 0.30)
	halo_mat.emission_energy_multiplier = 3.0
	halo_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	halo.material_override = halo_mat
	halo.position = Vector3(0, 1.55, 0)
	halo.rotation_degrees = Vector3(90, 0, 0)
	monk.add_child(halo)
	# Slow halo rotation
	var tw: Tween = halo.create_tween().set_loops()
	tw.tween_property(halo, "rotation_degrees:y", 360.0, 6.0)
	tw.tween_property(halo, "rotation_degrees:y", 0.0, 0.0)
	# Subtle body bob (breathing)
	var tb: Tween = monk.create_tween().set_loops()
	tb.tween_property(monk, "position:y", 0.06, 1.85)
	tb.tween_property(monk, "position:y", 0.0, 1.85)


static func _build_d7_zen_garden(geom: Node) -> void:
	## Epic-7 T18: zen rock garden — flat sand patch with 3 large stones
	## arranged in a triangle and concentric ripple "waves" around them.
	var garden: Node3D = Node3D.new()
	garden.name = "ZenGarden"
	garden.position = Vector3(D7_CENTER.x - 6.0, 0.0, -14.0)
	geom.add_child(garden)
	var sand_mat: StandardMaterial3D = StandardMaterial3D.new()
	sand_mat.albedo_color = Color(0.92, 0.85, 0.65)
	sand_mat.emission_enabled = true
	sand_mat.emission = Color(0.85, 0.75, 0.45)
	sand_mat.emission_energy_multiplier = 0.18
	sand_mat.roughness = 0.92
	# Sand patch (low cylinder)
	var patch: MeshInstance3D = MeshInstance3D.new()
	var pm: CylinderMesh = CylinderMesh.new()
	pm.top_radius = 3.40
	pm.bottom_radius = 3.40
	pm.height = 0.10
	patch.mesh = pm
	patch.material_override = sand_mat
	patch.position = Vector3(0, 0.05, 0)
	garden.add_child(patch)
	# 3 large stones in a triangle
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.30, 0.25, 0.20)
	stone_mat.roughness = 0.92
	var stone_positions: Array = [
		{"pos": Vector3( 0.0, 0,  0.0), "scale": Vector3(0.85, 0.85, 0.85)},
		{"pos": Vector3( 1.40, 0, -0.85), "scale": Vector3(0.55, 0.55, 0.55)},
		{"pos": Vector3(-1.0, 0,  1.20), "scale": Vector3(0.65, 0.65, 0.65)},
	]
	for sd in stone_positions:
		var stone: MeshInstance3D = MeshInstance3D.new()
		var sm: SphereMesh = SphereMesh.new()
		sm.radius = 0.55
		sm.height = 0.85
		stone.mesh = sm
		stone.material_override = stone_mat
		stone.position = sd["pos"] + Vector3(0, 0.20, 0)
		stone.scale = sd["scale"]
		garden.add_child(stone)
		# Stone collision
		var sb: StaticBody3D = StaticBody3D.new()
		sb.position = sd["pos"] + Vector3(0, 0.20, 0)
		var cs: CollisionShape3D = CollisionShape3D.new()
		var cap: SphereShape3D = SphereShape3D.new()
		cap.radius = 0.55 * sd["scale"].x
		cs.shape = cap
		sb.add_child(cs)
		garden.add_child(sb)
	# 4 concentric ripple rings (thin tori on the sand)
	var ripple_mat: StandardMaterial3D = StandardMaterial3D.new()
	ripple_mat.albedo_color = Color(0.85, 0.75, 0.55)
	ripple_mat.emission_enabled = true
	ripple_mat.emission = Color(0.85, 0.75, 0.55)
	ripple_mat.emission_energy_multiplier = 0.45
	ripple_mat.roughness = 0.85
	for i in 4:
		var ring: MeshInstance3D = MeshInstance3D.new()
		var rm: TorusMesh = TorusMesh.new()
		rm.inner_radius = 1.0 + i * 0.55
		rm.outer_radius = 1.05 + i * 0.55
		ring.mesh = rm
		ring.material_override = ripple_mat
		ring.position = Vector3(0, 0.12, 0)
		garden.add_child(ring)


static func _build_d7_waterfall(geom: Node) -> void:
	## Epic-7 T19: small flowing waterfall — cliff slab with 2 vertical
	## blue water columns + a small pool at the bottom.
	var fall: Node3D = Node3D.new()
	fall.name = "Waterfall"
	fall.position = Vector3(D7_CENTER.x + 22.0, 0.0, -14.0)
	geom.add_child(fall)
	var rock_mat: StandardMaterial3D = StandardMaterial3D.new()
	rock_mat.albedo_color = Color(0.40, 0.30, 0.18)
	rock_mat.roughness = 0.92
	# Cliff backdrop
	var cliff: MeshInstance3D = MeshInstance3D.new()
	var cm: BoxMesh = BoxMesh.new()
	cm.size = Vector3(3.40, 4.20, 1.10)
	cliff.mesh = cm
	cliff.material_override = rock_mat
	cliff.position = Vector3(0, 2.10, -0.85)
	fall.add_child(cliff)
	# Water material
	var water_mat: StandardMaterial3D = StandardMaterial3D.new()
	water_mat.albedo_color = Color(0.40, 0.85, 1.0, 0.85)
	water_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	water_mat.emission_enabled = true
	water_mat.emission = Color(0.30, 0.85, 1.0)
	water_mat.emission_energy_multiplier = 1.4
	water_mat.metallic = 0.55
	water_mat.roughness = 0.10
	# 2 vertical water columns flowing down
	for sx in [-0.55, 0.55]:
		var col: MeshInstance3D = MeshInstance3D.new()
		var clm: CylinderMesh = CylinderMesh.new()
		clm.top_radius = 0.18
		clm.bottom_radius = 0.30
		clm.height = 4.0
		col.mesh = clm
		col.material_override = water_mat
		col.position = Vector3(sx, 2.0, 0)
		fall.add_child(col)
	# Pool at the base
	var pool: MeshInstance3D = MeshInstance3D.new()
	var pmm: CylinderMesh = CylinderMesh.new()
	pmm.top_radius = 1.40
	pmm.bottom_radius = 1.40
	pmm.height = 0.06
	pool.mesh = pmm
	pool.material_override = water_mat
	pool.position = Vector3(0, 0.10, 0.40)
	fall.add_child(pool)
	# Bob the pool
	var tw: Tween = pool.create_tween().set_loops()
	tw.tween_property(pool, "position:y", 0.14, 1.4)
	tw.tween_property(pool, "position:y", 0.10, 1.4)
	# Pool light
	var light: OmniLight3D = OmniLight3D.new()
	light.light_color = Color(0.40, 0.85, 1.0)
	light.light_energy = 1.85
	light.omni_range = 5.0
	light.position = Vector3(0, 0.55, 0.40)
	fall.add_child(light)
	# Cliff collision
	var sb: StaticBody3D = StaticBody3D.new()
	sb.position = Vector3(0, 2.10, -0.85)
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(3.40, 4.20, 1.10)
	cs.shape = cb
	sb.add_child(cs)
	fall.add_child(sb)


static func _build_d7_scroll_shelves(geom: Node) -> void:
	## Epic-7 T20: 3 wooden shelves of rolled scrolls — slim wooden frames
	## with horizontal racks of small scroll cylinders.
	var shelves: Node3D = Node3D.new()
	shelves.name = "ScrollShelves"
	shelves.position = Vector3(D7_CENTER.x - 24.0, 0.0, -2.0)
	geom.add_child(shelves)
	var wood_mat: StandardMaterial3D = StandardMaterial3D.new()
	wood_mat.albedo_color = Color(0.45, 0.28, 0.12)
	wood_mat.roughness = 0.85
	var scroll_mat: StandardMaterial3D = StandardMaterial3D.new()
	scroll_mat.albedo_color = Color(0.95, 0.85, 0.55)
	scroll_mat.emission_enabled = true
	scroll_mat.emission = Color(0.95, 0.75, 0.30)
	scroll_mat.emission_energy_multiplier = 0.45
	scroll_mat.roughness = 0.85
	for s in 3:
		var shelf: Node3D = Node3D.new()
		shelf.position = Vector3(s * 2.20, 0, 0)
		shelves.add_child(shelf)
		# Frame
		var frame: MeshInstance3D = MeshInstance3D.new()
		var fm: BoxMesh = BoxMesh.new()
		fm.size = Vector3(1.85, 3.20, 0.55)
		frame.mesh = fm
		frame.material_override = wood_mat
		frame.position = Vector3(0, 1.60, 0)
		shelf.add_child(frame)
		# 4 horizontal shelves with scrolls
		for r in 4:
			var plank: MeshInstance3D = MeshInstance3D.new()
			var pmm: BoxMesh = BoxMesh.new()
			pmm.size = Vector3(1.65, 0.06, 0.40)
			plank.mesh = pmm
			plank.material_override = wood_mat
			plank.position = Vector3(0, 0.45 + r * 0.75, 0)
			shelf.add_child(plank)
			# 6 scrolls per shelf (small horizontal cylinders)
			for c in 6:
				var scroll: MeshInstance3D = MeshInstance3D.new()
				var scmm: CylinderMesh = CylinderMesh.new()
				scmm.top_radius = 0.06
				scmm.bottom_radius = 0.06
				scmm.height = 0.30
				scroll.mesh = scmm
				scroll.material_override = scroll_mat
				scroll.position = Vector3(-0.65 + c * 0.22, 0.55 + r * 0.75, 0)
				scroll.rotation_degrees = Vector3(0, 0, 90)
				shelf.add_child(scroll)
		# Shelf collision
		var sb: StaticBody3D = StaticBody3D.new()
		sb.position = Vector3(0, 1.60, 0)
		var cs: CollisionShape3D = CollisionShape3D.new()
		var cb: BoxShape3D = BoxShape3D.new()
		cb.size = Vector3(1.85, 3.20, 0.55)
		cs.shape = cb
		sb.add_child(cs)
		shelf.add_child(sb)


static func _build_d7_stupa_shrine(geom: Node) -> void:
	## Epic-7 T21: stupa shrine — square pedestal + dome + tall spire stack.
	var stupa: Node3D = Node3D.new()
	stupa.name = "StupaShrine"
	stupa.position = Vector3(D7_CENTER.x + 6.0, 0.0, 4.0)
	geom.add_child(stupa)
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.85, 0.78, 0.65)
	stone_mat.emission_enabled = true
	stone_mat.emission = Color(0.85, 0.75, 0.55)
	stone_mat.emission_energy_multiplier = 0.18
	stone_mat.roughness = 0.85
	# Square pedestal (3 tiers)
	var ped_sizes: Array = [
		Vector3(2.85, 0.30, 2.85),
		Vector3(2.20, 0.30, 2.20),
		Vector3(1.65, 0.30, 1.65),
	]
	for i in 3:
		var tier: MeshInstance3D = MeshInstance3D.new()
		var tm: BoxMesh = BoxMesh.new()
		tm.size = ped_sizes[i]
		tier.mesh = tm
		tier.material_override = stone_mat
		tier.position = Vector3(0, 0.15 + i * 0.30, 0)
		stupa.add_child(tier)
	# Hemispheric dome
	var dome: MeshInstance3D = MeshInstance3D.new()
	var dm: SphereMesh = SphereMesh.new()
	dm.radius = 1.40
	dm.height = 1.40
	dome.mesh = dm
	dome.material_override = stone_mat
	dome.position = Vector3(0, 1.40, 0)
	dome.scale = Vector3(1.0, 0.85, 1.0)
	stupa.add_child(dome)
	# Spire stack — 5 small flat discs decreasing in size
	for i in 5:
		var disc: MeshInstance3D = MeshInstance3D.new()
		var dcm: CylinderMesh = CylinderMesh.new()
		dcm.top_radius = 0.30 - i * 0.04
		dcm.bottom_radius = 0.30 - i * 0.04
		dcm.height = 0.12
		disc.mesh = dcm
		disc.material_override = stone_mat
		disc.position = Vector3(0, 2.30 + i * 0.18, 0)
		stupa.add_child(disc)
	# Top crystal finial
	var finial: MeshInstance3D = MeshInstance3D.new()
	var fm: PrismMesh = PrismMesh.new()
	fm.size = Vector3(0.30, 0.85, 0.30)
	finial.mesh = fm
	var crystal_mat: StandardMaterial3D = StandardMaterial3D.new()
	crystal_mat.albedo_color = Color(1.0, 0.85, 0.30)
	crystal_mat.emission_enabled = true
	crystal_mat.emission = Color(1.0, 0.85, 0.30)
	crystal_mat.emission_energy_multiplier = 3.0
	crystal_mat.metallic = 0.85
	crystal_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	finial.material_override = crystal_mat
	finial.position = Vector3(0, 3.55, 0)
	stupa.add_child(finial)
	# Pulse the finial
	var tw: Tween = finial.create_tween().set_loops()
	tw.tween_property(finial, "scale", Vector3.ONE * 1.20, 1.4)
	tw.tween_property(finial, "scale", Vector3.ONE * 0.85, 1.4)
	# Aura light
	var light: OmniLight3D = OmniLight3D.new()
	light.light_color = Color(1.0, 0.85, 0.30)
	light.light_energy = 2.5
	light.omni_range = 6.0
	light.position = Vector3(0, 2.85, 0)
	stupa.add_child(light)
	# Stupa collision
	var sb: StaticBody3D = StaticBody3D.new()
	sb.position = Vector3(0, 1.85, 0)
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cap: CylinderShape3D = CylinderShape3D.new()
	cap.radius = 1.40
	cap.height = 3.40
	cs.shape = cap
	sb.add_child(cs)
	stupa.add_child(sb)


static func _build_d7_pilgrim_npc(town: Node) -> void:
	## Epic-7 T22: pilgrim NPC — travel cloak + walking staff + carrying
	## a small backpack.
	var npc_slots: Node3D = town.get_node_or_null("%NPCSlots") as Node3D
	if npc_slots == null:
		return
	var slot: Marker3D = Marker3D.new()
	slot.name = "PilgrimSlot"
	slot.position = Vector3(D7_CENTER.x + 4.0, 0.0, 4.0)
	npc_slots.add_child(slot)
	var npc_scene: PackedScene = load("res://scenes/entities/npcs/VillagerR3.tscn") as PackedScene
	if npc_scene == null:
		return
	var npc: Node3D = npc_scene.instantiate() as Node3D
	npc.name = "Pilgrim"
	if "npc_name" in npc:
		npc.set("npc_name", "Wayfarer")
	if "npc_id" in npc:
		npc.set("npc_id", "pilgrim_d7")
	slot.add_child(npc)
	# Brown travel cloak
	var cloak: MeshInstance3D = MeshInstance3D.new()
	var cm: BoxMesh = BoxMesh.new()
	cm.size = Vector3(0.65, 1.20, 0.45)
	cloak.mesh = cm
	var cloak_mat: StandardMaterial3D = StandardMaterial3D.new()
	cloak_mat.albedo_color = Color(0.40, 0.25, 0.10)
	cloak_mat.roughness = 0.85
	cloak.material_override = cloak_mat
	cloak.position = Vector3(0, 0.60, 0)
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
	# Backpack
	var pack: MeshInstance3D = MeshInstance3D.new()
	var pm: BoxMesh = BoxMesh.new()
	pm.size = Vector3(0.45, 0.65, 0.30)
	pack.mesh = pm
	var pack_mat: StandardMaterial3D = StandardMaterial3D.new()
	pack_mat.albedo_color = Color(0.55, 0.35, 0.18)
	pack.material_override = pack_mat
	pack.position = Vector3(0, 0.85, -0.30)
	npc.add_child(pack)
	# Walking staff
	var wood_mat: StandardMaterial3D = StandardMaterial3D.new()
	wood_mat.albedo_color = Color(0.40, 0.25, 0.10)
	wood_mat.roughness = 0.85
	var staff: MeshInstance3D = MeshInstance3D.new()
	var stm: CylinderMesh = CylinderMesh.new()
	stm.top_radius = 0.04
	stm.bottom_radius = 0.05
	stm.height = 1.85
	staff.mesh = stm
	staff.material_override = wood_mat
	staff.position = Vector3(0.45, 0.92, 0)
	npc.add_child(staff)


static func _build_d7_mountain_goats(geom: Node) -> void:
	## Epic-7 T23: 4 mountain goats — small white woolly bodies + curved
	## horns + slow patrol.
	var herd: Node3D = Node3D.new()
	herd.name = "MountainGoats"
	herd.position = Vector3(D7_CENTER.x + 16.0, 0.0, 8.0)
	geom.add_child(herd)
	var fur_mat: StandardMaterial3D = StandardMaterial3D.new()
	fur_mat.albedo_color = Color(0.92, 0.92, 0.85)
	fur_mat.roughness = 0.85
	var horn_mat: StandardMaterial3D = StandardMaterial3D.new()
	horn_mat.albedo_color = Color(0.30, 0.20, 0.10)
	horn_mat.roughness = 0.65
	var positions: Array = [
		Vector3( 0.0, 0,  0.0),
		Vector3( 1.85, 0,  0.85),
		Vector3(-1.40, 0,  0.55),
		Vector3( 0.85, 0, -1.40),
	]
	for p in positions:
		var goat: Node3D = Node3D.new()
		goat.position = p
		herd.add_child(goat)
		# Body
		var body: MeshInstance3D = MeshInstance3D.new()
		var bm: SphereMesh = SphereMesh.new()
		bm.radius = 0.32
		bm.height = 0.55
		body.mesh = bm
		body.material_override = fur_mat
		body.position = Vector3(0, 0.55, 0)
		body.scale = Vector3(0.85, 0.85, 1.40)
		goat.add_child(body)
		# Head
		var head: MeshInstance3D = MeshInstance3D.new()
		var hm: SphereMesh = SphereMesh.new()
		hm.radius = 0.18
		hm.height = 0.32
		head.mesh = hm
		head.material_override = fur_mat
		head.position = Vector3(0, 0.65, 0.42)
		goat.add_child(head)
		# Snout
		var snout: MeshInstance3D = MeshInstance3D.new()
		var sn: BoxMesh = BoxMesh.new()
		sn.size = Vector3(0.12, 0.08, 0.18)
		snout.mesh = sn
		snout.material_override = fur_mat
		snout.position = Vector3(0, 0.55, 0.55)
		goat.add_child(snout)
		# 2 curved horns
		for sx in [-0.10, 0.10]:
			var horn: MeshInstance3D = MeshInstance3D.new()
			var hrm: PrismMesh = PrismMesh.new()
			hrm.size = Vector3(0.08, 0.30, 0.08)
			horn.mesh = hrm
			horn.material_override = horn_mat
			horn.position = Vector3(sx, 0.85, 0.30)
			horn.rotation_degrees = Vector3(-25, 0, sx * 60.0)
			goat.add_child(horn)
		# 4 legs
		for lx in [-0.18, 0.18]:
			for lz in [-0.30, 0.30]:
				var leg: MeshInstance3D = MeshInstance3D.new()
				var lm: CylinderMesh = CylinderMesh.new()
				lm.top_radius = 0.05
				lm.bottom_radius = 0.05
				lm.height = 0.45
				leg.mesh = lm
				leg.material_override = horn_mat
				leg.position = Vector3(lx, 0.22, lz)
				goat.add_child(leg)
		# Slow patrol
		var tw: Tween = goat.create_tween().set_loops()
		var p2: Vector3 = p
		tw.tween_property(goat, "position", p2 + Vector3(randf_range(-1.5, 1.5), 0, randf_range(-1.5, 1.5)), 4.0)
		tw.tween_property(goat, "rotation_degrees:y", 180.0, 0.4)
		tw.tween_property(goat, "position", p2, 4.0)
		tw.tween_property(goat, "rotation_degrees:y", 0.0, 0.4)
		# Body collision
		var sb: StaticBody3D = StaticBody3D.new()
		sb.position = Vector3(0, 0.55, 0)
		var cs: CollisionShape3D = CollisionShape3D.new()
		var cb: BoxShape3D = BoxShape3D.new()
		cb.size = Vector3(0.85, 0.85, 1.20)
		cs.shape = cb
		sb.add_child(cs)
		goat.add_child(sb)


static func _build_d7_lotus_pond(geom: Node) -> void:
	## Epic-7 T24: round lotus pond — stone rim + cyan water + 5 lotus
	## flowers floating on the surface.
	var pond: Node3D = Node3D.new()
	pond.name = "LotusPond"
	pond.position = Vector3(D7_CENTER.x + 14.0, 0.0, 0.0)
	geom.add_child(pond)
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.55, 0.45, 0.30)
	stone_mat.roughness = 0.92
	# Stone rim (torus)
	var rim: MeshInstance3D = MeshInstance3D.new()
	var rm: TorusMesh = TorusMesh.new()
	rm.inner_radius = 1.85
	rm.outer_radius = 2.20
	rim.mesh = rm
	rim.material_override = stone_mat
	rim.position = Vector3(0, 0.18, 0)
	pond.add_child(rim)
	# Water disc
	var water: MeshInstance3D = MeshInstance3D.new()
	var wm: CylinderMesh = CylinderMesh.new()
	wm.top_radius = 1.95
	wm.bottom_radius = 1.95
	wm.height = 0.06
	water.mesh = wm
	var water_mat: StandardMaterial3D = StandardMaterial3D.new()
	water_mat.albedo_color = Color(0.30, 0.85, 1.0, 0.65)
	water_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	water_mat.emission_enabled = true
	water_mat.emission = Color(0.30, 0.95, 1.0)
	water_mat.emission_energy_multiplier = 0.85
	water_mat.metallic = 0.30
	water_mat.roughness = 0.05
	water.material_override = water_mat
	water.position = Vector3(0, 0.18, 0)
	pond.add_child(water)
	# 5 lotus flowers (white pads + pink centers)
	var pad_mat: StandardMaterial3D = StandardMaterial3D.new()
	pad_mat.albedo_color = Color(0.30, 0.55, 0.20)
	pad_mat.emission_enabled = true
	pad_mat.emission = Color(0.20, 0.45, 0.15)
	pad_mat.emission_energy_multiplier = 0.45
	pad_mat.roughness = 0.85
	var flower_mat: StandardMaterial3D = StandardMaterial3D.new()
	flower_mat.albedo_color = Color(0.95, 0.65, 0.85)
	flower_mat.emission_enabled = true
	flower_mat.emission = Color(0.95, 0.55, 0.85)
	flower_mat.emission_energy_multiplier = 0.85
	for i in 5:
		var ang: float = (TAU / 5.0) * i
		var pad: MeshInstance3D = MeshInstance3D.new()
		var pmm: CylinderMesh = CylinderMesh.new()
		pmm.top_radius = 0.30
		pmm.bottom_radius = 0.30
		pmm.height = 0.04
		pad.mesh = pmm
		pad.material_override = pad_mat
		pad.position = Vector3(cos(ang) * 1.10, 0.22, sin(ang) * 1.10)
		pond.add_child(pad)
		# Flower (small sphere on the pad)
		var flower: MeshInstance3D = MeshInstance3D.new()
		var fm: SphereMesh = SphereMesh.new()
		fm.radius = 0.12
		fm.height = 0.20
		flower.mesh = fm
		flower.material_override = flower_mat
		flower.position = Vector3(cos(ang) * 1.10, 0.34, sin(ang) * 1.10)
		pond.add_child(flower)
	# Light
	var light: OmniLight3D = OmniLight3D.new()
	light.light_color = Color(0.40, 0.95, 1.0)
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


static func _build_d7_stone_lanterns(geom: Node) -> void:
	## Epic-7 T25: 6 traditional stone lanterns in a row — 3-section
	## stack (base + body + roof) with warm internal glow.
	var row: Node3D = Node3D.new()
	row.name = "StoneLanterns"
	row.position = Vector3(D7_CENTER.x - 14.0, 0.0, -2.0)
	geom.add_child(row)
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.55, 0.45, 0.30)
	stone_mat.roughness = 0.92
	for i in 6:
		var lantern: Node3D = Node3D.new()
		lantern.position = Vector3(i * 1.85, 0, 0)
		row.add_child(lantern)
		# Base
		var base: MeshInstance3D = MeshInstance3D.new()
		var bm: BoxMesh = BoxMesh.new()
		bm.size = Vector3(0.55, 0.55, 0.55)
		base.mesh = bm
		base.material_override = stone_mat
		base.position = Vector3(0, 0.27, 0)
		lantern.add_child(base)
		# Body (smaller box)
		var body: MeshInstance3D = MeshInstance3D.new()
		var bdm: BoxMesh = BoxMesh.new()
		bdm.size = Vector3(0.40, 0.40, 0.40)
		body.mesh = bdm
		body.material_override = stone_mat
		body.position = Vector3(0, 0.75, 0)
		lantern.add_child(body)
		# Inside glow box
		var glow: MeshInstance3D = MeshInstance3D.new()
		var gm: BoxMesh = BoxMesh.new()
		gm.size = Vector3(0.30, 0.30, 0.30)
		glow.mesh = gm
		var glow_mat: StandardMaterial3D = StandardMaterial3D.new()
		glow_mat.albedo_color = Color(1.0, 0.85, 0.30)
		glow_mat.emission_enabled = true
		glow_mat.emission = Color(1.0, 0.75, 0.20)
		glow_mat.emission_energy_multiplier = 3.0
		glow_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		glow.material_override = glow_mat
		glow.position = Vector3(0, 0.75, 0)
		lantern.add_child(glow)
		# Roof (sloped prism)
		var roof: MeshInstance3D = MeshInstance3D.new()
		var rmm: PrismMesh = PrismMesh.new()
		rmm.size = Vector3(0.65, 0.30, 0.65)
		roof.mesh = rmm
		roof.material_override = stone_mat
		roof.position = Vector3(0, 1.10, 0)
		lantern.add_child(roof)
		# Warm light per lantern
		var light: OmniLight3D = OmniLight3D.new()
		light.light_color = Color(1.0, 0.75, 0.30)
		light.light_energy = 1.2
		light.omni_range = 3.0
		light.position = Vector3(0, 0.75, 0)
		lantern.add_child(light)
		# Lantern collision
		var sb: StaticBody3D = StaticBody3D.new()
		sb.position = Vector3(0, 0.55, 0)
		var cs: CollisionShape3D = CollisionShape3D.new()
		var cb: BoxShape3D = BoxShape3D.new()
		cb.size = Vector3(0.55, 1.40, 0.55)
		cs.shape = cb
		sb.add_child(cs)
		lantern.add_child(sb)


static func _build_d7_tea_house(geom: Node) -> void:
	## Epic-7 T26: small wooden tea house — square wooden frame + curved
	## upturned roof + paper sliding doors + hanging lanterns flanking entrance.
	var house: Node3D = Node3D.new()
	house.name = "TeaHouse"
	house.position = Vector3(D7_CENTER.x - 24.0, 0.0, 14.0)
	geom.add_child(house)
	var wood_mat: StandardMaterial3D = StandardMaterial3D.new()
	wood_mat.albedo_color = Color(0.45, 0.28, 0.12)
	wood_mat.roughness = 0.85
	# Walls
	var main: MeshInstance3D = MeshInstance3D.new()
	var mm: BoxMesh = BoxMesh.new()
	mm.size = Vector3(4.20, 2.85, 3.40)
	main.mesh = mm
	main.material_override = wood_mat
	main.position = Vector3(0, 1.42, 0)
	house.add_child(main)
	# Curved upturned roof
	var roof: MeshInstance3D = MeshInstance3D.new()
	var rm: PrismMesh = PrismMesh.new()
	rm.size = Vector3(4.85, 1.40, 3.85)
	roof.mesh = rm
	var roof_mat: StandardMaterial3D = StandardMaterial3D.new()
	roof_mat.albedo_color = Color(0.40, 0.20, 0.15)
	roof.material_override = roof_mat
	roof.position = Vector3(0, 3.55, 0)
	house.add_child(roof)
	# Sliding paper door (translucent panel)
	var door_mat: StandardMaterial3D = StandardMaterial3D.new()
	door_mat.albedo_color = Color(0.95, 0.85, 0.55, 0.85)
	door_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	door_mat.emission_enabled = true
	door_mat.emission = Color(0.95, 0.65, 0.30)
	door_mat.emission_energy_multiplier = 1.4
	var door: MeshInstance3D = MeshInstance3D.new()
	var dm: BoxMesh = BoxMesh.new()
	dm.size = Vector3(1.85, 2.40, 0.10)
	door.mesh = dm
	door.material_override = door_mat
	door.position = Vector3(0, 1.20, 1.75)
	house.add_child(door)
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
		lantern.position = Vector3(sx, 2.40, 1.85)
		lantern.scale = Vector3(1.0, 1.30, 1.0)
		house.add_child(lantern)
		var light: OmniLight3D = OmniLight3D.new()
		light.light_color = Color(1.0, 0.45, 0.30)
		light.light_energy = 1.6
		light.omni_range = 4.0
		light.position = Vector3(sx, 2.40, 1.85)
		house.add_child(light)
	# Tea house collision
	var sb: StaticBody3D = StaticBody3D.new()
	sb.position = Vector3(0, 1.42, 0)
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(4.20, 2.85, 3.40)
	cs.shape = cb
	sb.add_child(cs)
	house.add_child(sb)


static func _build_d7_tea_master_npc(town: Node) -> void:
	## Epic-7 T27: tea master NPC — green robe + holding a small teacup
	## with steam rising.
	var npc_slots: Node3D = town.get_node_or_null("%NPCSlots") as Node3D
	if npc_slots == null:
		return
	var slot: Marker3D = Marker3D.new()
	slot.name = "TeaMasterSlot"
	slot.position = Vector3(D7_CENTER.x - 24.0, 0.0, 16.5)
	npc_slots.add_child(slot)
	var npc_scene: PackedScene = load("res://scenes/entities/npcs/VillagerR3.tscn") as PackedScene
	if npc_scene == null:
		return
	var npc: Node3D = npc_scene.instantiate() as Node3D
	npc.name = "TeaMaster"
	if "npc_name" in npc:
		npc.set("npc_name", "Steeped")
	if "npc_id" in npc:
		npc.set("npc_id", "tea_master_d7")
	slot.add_child(npc)
	# Green robe
	var robe: MeshInstance3D = MeshInstance3D.new()
	var rm: BoxMesh = BoxMesh.new()
	rm.size = Vector3(0.65, 1.20, 0.45)
	robe.mesh = rm
	var robe_mat: StandardMaterial3D = StandardMaterial3D.new()
	robe_mat.albedo_color = Color(0.20, 0.55, 0.20)
	robe_mat.emission_enabled = true
	robe_mat.emission = Color(0.20, 0.55, 0.20)
	robe_mat.emission_energy_multiplier = 0.30
	robe.material_override = robe_mat
	robe.position = Vector3(0, 0.60, 0)
	npc.add_child(robe)
	# Teacup (small cylinder)
	var cup: MeshInstance3D = MeshInstance3D.new()
	var cm: CylinderMesh = CylinderMesh.new()
	cm.top_radius = 0.08
	cm.bottom_radius = 0.06
	cm.height = 0.10
	cup.mesh = cm
	var cup_mat: StandardMaterial3D = StandardMaterial3D.new()
	cup_mat.albedo_color = Color(0.92, 0.85, 0.65)
	cup.material_override = cup_mat
	cup.position = Vector3(0.40, 0.85, 0.20)
	npc.add_child(cup)
	# Steam from cup
	var steam: GPUParticles3D = GPUParticles3D.new()
	steam.amount = 12
	steam.lifetime = 1.4
	steam.preprocess = 0.5
	steam.position = Vector3(0.40, 0.92, 0.20)
	var pm: ParticleProcessMaterial = ParticleProcessMaterial.new()
	pm.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_POINT
	pm.direction = Vector3(0, 1, 0)
	pm.spread = 18.0
	pm.gravity = Vector3.ZERO
	pm.initial_velocity_min = 0.30
	pm.initial_velocity_max = 0.55
	pm.scale_min = 0.06
	pm.scale_max = 0.14
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


static func _build_d7_training_posts(geom: Node) -> void:
	## Epic-7 T28: 5 wooden training posts (mok jong style) at varying
	## heights for martial training.
	var posts: Node3D = Node3D.new()
	posts.name = "TrainingPosts"
	posts.position = Vector3(D7_CENTER.x - 14.0, 0.0, -16.0)
	geom.add_child(posts)
	var wood_mat: StandardMaterial3D = StandardMaterial3D.new()
	wood_mat.albedo_color = Color(0.45, 0.28, 0.12)
	wood_mat.roughness = 0.85
	var heights: Array = [1.85, 2.40, 1.40, 2.20, 1.85]
	for i in 5:
		var post: MeshInstance3D = MeshInstance3D.new()
		var pm: CylinderMesh = CylinderMesh.new()
		pm.top_radius = 0.18
		pm.bottom_radius = 0.22
		pm.height = heights[i]
		post.mesh = pm
		post.material_override = wood_mat
		post.position = Vector3(i * 1.10, heights[i] * 0.5, 0)
		posts.add_child(post)
		# Post collision
		var sb: StaticBody3D = StaticBody3D.new()
		sb.position = Vector3(i * 1.10, heights[i] * 0.5, 0)
		var cs: CollisionShape3D = CollisionShape3D.new()
		var cap: CapsuleShape3D = CapsuleShape3D.new()
		cap.radius = 0.22
		cap.height = heights[i]
		cs.shape = cap
		sb.add_child(cs)
		posts.add_child(sb)
		# Top cap (small darker disc)
		var cap_disc: MeshInstance3D = MeshInstance3D.new()
		var cdm: CylinderMesh = CylinderMesh.new()
		cdm.top_radius = 0.22
		cdm.bottom_radius = 0.22
		cdm.height = 0.08
		cap_disc.mesh = cdm
		var cap_mat: StandardMaterial3D = StandardMaterial3D.new()
		cap_mat.albedo_color = Color(0.30, 0.18, 0.08)
		cap_disc.material_override = cap_mat
		cap_disc.position = Vector3(i * 1.10, heights[i] + 0.04, 0)
		posts.add_child(cap_disc)


static func _build_d7_martial_artist_npc(town: Node) -> void:
	## Epic-7 T29: martial artist NPC — white gi + black belt + striking
	## stance with raised fist tween.
	var npc_slots: Node3D = town.get_node_or_null("%NPCSlots") as Node3D
	if npc_slots == null:
		return
	var slot: Marker3D = Marker3D.new()
	slot.name = "MartialArtistSlot"
	slot.position = Vector3(D7_CENTER.x - 11.0, 0.0, -16.0)
	npc_slots.add_child(slot)
	var npc_scene: PackedScene = load("res://scenes/entities/npcs/VillagerR3.tscn") as PackedScene
	if npc_scene == null:
		return
	var npc: Node3D = npc_scene.instantiate() as Node3D
	npc.name = "MartialArtist"
	if "npc_name" in npc:
		npc.set("npc_name", "Iron Stance")
	if "npc_id" in npc:
		npc.set("npc_id", "martial_d7")
	slot.add_child(npc)
	# White gi
	var gi: MeshInstance3D = MeshInstance3D.new()
	var gm: BoxMesh = BoxMesh.new()
	gm.size = Vector3(0.65, 1.05, 0.40)
	gi.mesh = gm
	var gi_mat: StandardMaterial3D = StandardMaterial3D.new()
	gi_mat.albedo_color = Color(0.95, 0.95, 0.92)
	gi_mat.roughness = 0.85
	gi.material_override = gi_mat
	gi.position = Vector3(0, 0.55, 0)
	npc.add_child(gi)
	# Black belt
	var belt: MeshInstance3D = MeshInstance3D.new()
	var bm: BoxMesh = BoxMesh.new()
	bm.size = Vector3(0.70, 0.10, 0.45)
	belt.mesh = bm
	var belt_mat: StandardMaterial3D = StandardMaterial3D.new()
	belt_mat.albedo_color = Color(0.10, 0.08, 0.10)
	belt.material_override = belt_mat
	belt.position = Vector3(0, 0.65, 0)
	npc.add_child(belt)
	# Raised fist arm
	var arm: MeshInstance3D = MeshInstance3D.new()
	var am: BoxMesh = BoxMesh.new()
	am.size = Vector3(0.18, 0.55, 0.18)
	arm.mesh = am
	arm.material_override = gi_mat
	arm.position = Vector3(0.20, 1.55, 0.20)
	npc.add_child(arm)
	var fist: MeshInstance3D = MeshInstance3D.new()
	var fm: SphereMesh = SphereMesh.new()
	fm.radius = 0.12
	fm.height = 0.22
	fist.mesh = fm
	var skin_mat: StandardMaterial3D = StandardMaterial3D.new()
	skin_mat.albedo_color = Color(0.95, 0.85, 0.75)
	fist.material_override = skin_mat
	fist.position = Vector3(0.20, 1.85, 0.20)
	npc.add_child(fist)
	# Punch tween
	var tw: Tween = arm.create_tween().set_loops()
	tw.tween_property(arm, "position:z", 0.40, 0.20)
	tw.tween_property(arm, "position:z", 0.20, 0.20)
	tw.tween_interval(0.40)


static func _build_d7_rope_bridge(geom: Node) -> void:
	## Epic-7 T30: long rope bridge across a chasm — 4 wooden plank
	## sections + 2 hanging ropes + 4 vertical support cables.
	var bridge: Node3D = Node3D.new()
	bridge.name = "RopeBridge"
	bridge.position = Vector3(D7_CENTER.x + 22.0, 0.0, 0.0)
	geom.add_child(bridge)
	var rope_mat: StandardMaterial3D = StandardMaterial3D.new()
	rope_mat.albedo_color = Color(0.55, 0.40, 0.20)
	rope_mat.roughness = 0.85
	var wood_mat: StandardMaterial3D = StandardMaterial3D.new()
	wood_mat.albedo_color = Color(0.45, 0.28, 0.12)
	wood_mat.roughness = 0.85
	# Chasm visible below
	var chasm: MeshInstance3D = MeshInstance3D.new()
	var cm: BoxMesh = BoxMesh.new()
	cm.size = Vector3(8.50, 0.40, 4.20)
	chasm.mesh = cm
	var chasm_mat: StandardMaterial3D = StandardMaterial3D.new()
	chasm_mat.albedo_color = Color(0.08, 0.05, 0.05)
	chasm_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	chasm.material_override = chasm_mat
	chasm.position = Vector3(0, -0.18, 0)
	bridge.add_child(chasm)
	# 8 wooden planks across
	for i in 8:
		var plank: MeshInstance3D = MeshInstance3D.new()
		var pmm: BoxMesh = BoxMesh.new()
		pmm.size = Vector3(0.85, 0.10, 1.85)
		plank.mesh = pmm
		plank.material_override = wood_mat
		plank.position = Vector3(-3.50 + i * 1.0, 1.20, 0)
		bridge.add_child(plank)
	# 2 long horizontal hanging ropes (sides)
	for sz in [-1.0, 1.0]:
		var rope: MeshInstance3D = MeshInstance3D.new()
		var rm: CylinderMesh = CylinderMesh.new()
		rm.top_radius = 0.04
		rm.bottom_radius = 0.04
		rm.height = 8.50
		rope.mesh = rm
		rope.material_override = rope_mat
		rope.position = Vector3(0, 1.85, sz)
		rope.rotation_degrees = Vector3(0, 0, 90)
		bridge.add_child(rope)
	# 4 vertical posts at the ends
	for sx in [-4.20, 4.20]:
		for sz in [-1.0, 1.0]:
			var post: MeshInstance3D = MeshInstance3D.new()
			var pm: BoxMesh = BoxMesh.new()
			pm.size = Vector3(0.20, 2.20, 0.20)
			post.mesh = pm
			post.material_override = wood_mat
			post.position = Vector3(sx, 1.10, sz)
			bridge.add_child(post)
			# Post collision
			var sb: StaticBody3D = StaticBody3D.new()
			sb.position = Vector3(sx, 1.10, sz)
			var cs: CollisionShape3D = CollisionShape3D.new()
			var cb: BoxShape3D = BoxShape3D.new()
			cb.size = Vector3(0.20, 2.20, 0.20)
			cs.shape = cb
			sb.add_child(cs)
			bridge.add_child(sb)
	# Plank deck collision (single slab)
	var dsb: StaticBody3D = StaticBody3D.new()
	dsb.position = Vector3(0, 1.20, 0)
	var dcs: CollisionShape3D = CollisionShape3D.new()
	var dcb: BoxShape3D = BoxShape3D.new()
	dcb.size = Vector3(8.50, 0.20, 1.85)
	dcs.shape = dcb
	dsb.add_child(dcs)
	bridge.add_child(dsb)


static func _build_d7_stone_arch(geom: Node) -> void:
	## Epic-7 T31: ancient stone archway — 2 weathered stone pillars +
	## curved torus arch top + decorative carving line.
	var arch: Node3D = Node3D.new()
	arch.name = "AncientStoneArch"
	arch.position = Vector3(D7_CENTER.x + 14.0, 0.0, -2.0)
	geom.add_child(arch)
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.55, 0.45, 0.30)
	stone_mat.roughness = 0.92
	# 2 weathered stone pillars
	for sx in [-1.85, 1.85]:
		var pillar: MeshInstance3D = MeshInstance3D.new()
		var pm: BoxMesh = BoxMesh.new()
		pm.size = Vector3(0.85, 4.20, 0.85)
		pillar.mesh = pm
		pillar.material_override = stone_mat
		pillar.position = Vector3(sx, 2.10, 0)
		arch.add_child(pillar)
		# Pillar collision
		var sb: StaticBody3D = StaticBody3D.new()
		sb.position = Vector3(sx, 2.10, 0)
		var cs: CollisionShape3D = CollisionShape3D.new()
		var cb: BoxShape3D = BoxShape3D.new()
		cb.size = Vector3(0.85, 4.20, 0.85)
		cs.shape = cb
		sb.add_child(cs)
		arch.add_child(sb)
	# Curved arch top (half torus)
	var top: MeshInstance3D = MeshInstance3D.new()
	var tm: TorusMesh = TorusMesh.new()
	tm.inner_radius = 1.55
	tm.outer_radius = 2.0
	top.mesh = tm
	top.material_override = stone_mat
	top.position = Vector3(0, 4.20, 0)
	top.rotation_degrees = Vector3(90, 0, 0)
	top.scale = Vector3(1.0, 1.0, 0.40)
	arch.add_child(top)
	# Center keystone (small box)
	var keystone: MeshInstance3D = MeshInstance3D.new()
	var km: BoxMesh = BoxMesh.new()
	km.size = Vector3(0.55, 0.65, 0.85)
	keystone.mesh = km
	var key_mat: StandardMaterial3D = StandardMaterial3D.new()
	key_mat.albedo_color = Color(0.75, 0.55, 0.30)
	key_mat.emission_enabled = true
	key_mat.emission = Color(0.85, 0.55, 0.20)
	key_mat.emission_energy_multiplier = 0.65
	keystone.material_override = key_mat
	keystone.position = Vector3(0, 5.50, 0)
	arch.add_child(keystone)


static func _build_d7_bonsai_garden(geom: Node) -> void:
	## Epic-7 T32: bonsai garden — 3 stylized small bonsai trees on stone
	## pedestals, each with twisted trunk + small leaf canopy.
	var garden: Node3D = Node3D.new()
	garden.name = "BonsaiGarden"
	garden.position = Vector3(D7_CENTER.x + 22.0, 0.0, 8.0)
	geom.add_child(garden)
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.55, 0.45, 0.30)
	stone_mat.roughness = 0.92
	var trunk_mat: StandardMaterial3D = StandardMaterial3D.new()
	trunk_mat.albedo_color = Color(0.30, 0.18, 0.10)
	trunk_mat.roughness = 0.92
	var leaf_colors: Array = [
		Color(0.30, 0.65, 0.20),
		Color(0.95, 0.55, 0.30),
		Color(0.55, 0.85, 0.20),
	]
	for i in 3:
		var bonsai: Node3D = Node3D.new()
		bonsai.position = Vector3(i * 1.85, 0, 0)
		garden.add_child(bonsai)
		# Stone pedestal
		var ped: MeshInstance3D = MeshInstance3D.new()
		var pm: BoxMesh = BoxMesh.new()
		pm.size = Vector3(0.85, 0.85, 0.85)
		ped.mesh = pm
		ped.material_override = stone_mat
		ped.position = Vector3(0, 0.42, 0)
		bonsai.add_child(ped)
		# Twisted trunk (3 stacked angled cylinders)
		for j in 3:
			var seg: MeshInstance3D = MeshInstance3D.new()
			var cm: CylinderMesh = CylinderMesh.new()
			cm.top_radius = 0.06 - j * 0.01
			cm.bottom_radius = 0.10 - j * 0.01
			cm.height = 0.30
			seg.mesh = cm
			seg.material_override = trunk_mat
			seg.position = Vector3(sin(j * 1.5) * 0.06, 1.0 + j * 0.30, cos(j * 1.5) * 0.06)
			seg.rotation_degrees = Vector3(15.0 * sin(j * 1.5), 0, 15.0 * cos(j * 1.5))
			bonsai.add_child(seg)
		# 3 small leaf canopy spheres
		var leaf_mat: StandardMaterial3D = StandardMaterial3D.new()
		leaf_mat.albedo_color = leaf_colors[i]
		leaf_mat.emission_enabled = true
		leaf_mat.emission = leaf_colors[i]
		leaf_mat.emission_energy_multiplier = 0.45
		leaf_mat.roughness = 0.85
		for j in 3:
			var leaf: MeshInstance3D = MeshInstance3D.new()
			var lm: SphereMesh = SphereMesh.new()
			lm.radius = 0.30
			lm.height = 0.55
			leaf.mesh = lm
			leaf.material_override = leaf_mat
			leaf.position = Vector3(
				randf_range(-0.30, 0.30),
				1.85 + randf_range(0, 0.30),
				randf_range(-0.30, 0.30)
			)
			leaf.scale = Vector3(1.0, 0.55, 1.0)
			bonsai.add_child(leaf)
		# Pedestal collision
		var sb: StaticBody3D = StaticBody3D.new()
		sb.position = Vector3(0, 0.42, 0)
		var cs: CollisionShape3D = CollisionShape3D.new()
		var cb: BoxShape3D = BoxShape3D.new()
		cb.size = Vector3(0.85, 0.85, 0.85)
		cs.shape = cb
		sb.add_child(cs)
		bonsai.add_child(sb)


static func _build_d7_d7_gardener_npc(town: Node) -> void:
	## Epic-7 T33: D7 gardener NPC — green apron + holding small pruning shears.
	var npc_slots: Node3D = town.get_node_or_null("%NPCSlots") as Node3D
	if npc_slots == null:
		return
	var slot: Marker3D = Marker3D.new()
	slot.name = "D7GardenerSlot"
	slot.position = Vector3(D7_CENTER.x + 22.0, 0.0, 6.0)
	npc_slots.add_child(slot)
	var npc_scene: PackedScene = load("res://scenes/entities/npcs/VillagerR3.tscn") as PackedScene
	if npc_scene == null:
		return
	var npc: Node3D = npc_scene.instantiate() as Node3D
	npc.name = "D7Gardener"
	if "npc_name" in npc:
		npc.set("npc_name", "Tendril")
	if "npc_id" in npc:
		npc.set("npc_id", "gardener_d7")
	slot.add_child(npc)
	# Green apron
	var apron: MeshInstance3D = MeshInstance3D.new()
	var am: BoxMesh = BoxMesh.new()
	am.size = Vector3(0.55, 0.85, 0.06)
	apron.mesh = am
	var apron_mat: StandardMaterial3D = StandardMaterial3D.new()
	apron_mat.albedo_color = Color(0.20, 0.55, 0.20)
	apron_mat.emission_enabled = true
	apron_mat.emission = Color(0.20, 0.55, 0.20)
	apron_mat.emission_energy_multiplier = 0.30
	apron.material_override = apron_mat
	apron.position = Vector3(0, 0.55, 0.22)
	npc.add_child(apron)
	# Pruning shears (small crossed metal blades)
	var blade_mat: StandardMaterial3D = StandardMaterial3D.new()
	blade_mat.albedo_color = Color(0.85, 0.92, 1.0)
	blade_mat.metallic = 0.95
	blade_mat.roughness = 0.05
	for i in 2:
		var blade: MeshInstance3D = MeshInstance3D.new()
		var bm: BoxMesh = BoxMesh.new()
		bm.size = Vector3(0.04, 0.20, 0.02)
		blade.mesh = bm
		blade.material_override = blade_mat
		blade.position = Vector3(0.40, 0.85, 0.20)
		blade.rotation_degrees = Vector3(0, 0, 25.0 if i == 0 else -25.0)
		npc.add_child(blade)


static func _build_d7_cliff_stack(geom: Node) -> void:
	## Epic-7 T34: tall cliff stack — 4 progressively narrower sandstone
	## blocks stacked tall, suggesting a natural rock formation.
	var stack: Node3D = Node3D.new()
	stack.name = "CliffStack"
	stack.position = Vector3(D7_CENTER.x + 28.0, 0.0, -16.0)
	geom.add_child(stack)
	var rock_mat: StandardMaterial3D = StandardMaterial3D.new()
	rock_mat.albedo_color = Color(0.65, 0.45, 0.20)
	rock_mat.emission_enabled = true
	rock_mat.emission = Color(0.55, 0.35, 0.15)
	rock_mat.emission_energy_multiplier = 0.18
	rock_mat.roughness = 0.92
	var sizes: Array = [
		Vector3(2.85, 2.85, 2.85),
		Vector3(2.20, 2.40, 2.20),
		Vector3(1.65, 2.20, 1.65),
		Vector3(1.10, 1.85, 1.10),
	]
	var ys: Array = [1.42, 4.0, 6.30, 8.30]
	for i in 4:
		var block: MeshInstance3D = MeshInstance3D.new()
		var bm: BoxMesh = BoxMesh.new()
		bm.size = sizes[i]
		block.mesh = bm
		block.material_override = rock_mat
		block.position = Vector3(randf_range(-0.20, 0.20), ys[i], randf_range(-0.20, 0.20))
		block.rotation_degrees = Vector3(0, randf_range(-15, 15), 0)
		stack.add_child(block)
	# Stack collision (single capsule covering all)
	var sb: StaticBody3D = StaticBody3D.new()
	sb.position = Vector3(0, 4.85, 0)
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cap: CylinderShape3D = CylinderShape3D.new()
	cap.radius = 1.85
	cap.height = 9.0
	cs.shape = cap
	sb.add_child(cs)
	stack.add_child(sb)


static func _build_d7_stone_stairs(geom: Node) -> void:
	## Epic-7 T35: long stone staircase climbing upward — 12 steps with
	## stone railings on each side.
	var stairs: Node3D = Node3D.new()
	stairs.name = "StoneStairs"
	stairs.position = Vector3(D7_CENTER.x - 24.0, 0.0, -16.0)
	geom.add_child(stairs)
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.55, 0.45, 0.30)
	stone_mat.roughness = 0.92
	# 12 steps climbing up
	for i in 12:
		var step: MeshInstance3D = MeshInstance3D.new()
		var sm: BoxMesh = BoxMesh.new()
		sm.size = Vector3(2.85, 0.30, 0.55)
		step.mesh = sm
		step.material_override = stone_mat
		step.position = Vector3(0, 0.15 + i * 0.30, i * 0.55)
		stairs.add_child(step)
		# Step collision
		var sb: StaticBody3D = StaticBody3D.new()
		sb.position = Vector3(0, 0.15 + i * 0.30, i * 0.55)
		var cs: CollisionShape3D = CollisionShape3D.new()
		var cb: BoxShape3D = BoxShape3D.new()
		cb.size = Vector3(2.85, 0.30, 0.55)
		cs.shape = cb
		sb.add_child(cs)
		stairs.add_child(sb)
	# 2 stone railings climbing the sides
	for sx in [-1.55, 1.55]:
		var rail: MeshInstance3D = MeshInstance3D.new()
		var rm: BoxMesh = BoxMesh.new()
		rm.size = Vector3(0.20, 0.65, 6.85)
		rail.mesh = rm
		rail.material_override = stone_mat
		rail.position = Vector3(sx, 1.85, 3.20)
		rail.rotation_degrees = Vector3(-30, 0, 0)
		stairs.add_child(rail)


static func _build_d7_weapon_rack(geom: Node) -> void:
	## Epic-7 T36: wooden weapon rack with 4 staves and 2 hanging swords.
	var rack: Node3D = Node3D.new()
	rack.name = "WeaponRack"
	rack.position = Vector3(D7_CENTER.x - 8.0, 0.0, -16.0)
	geom.add_child(rack)
	var wood_mat: StandardMaterial3D = StandardMaterial3D.new()
	wood_mat.albedo_color = Color(0.45, 0.28, 0.12)
	wood_mat.roughness = 0.85
	# Frame
	var frame: MeshInstance3D = MeshInstance3D.new()
	var fm: BoxMesh = BoxMesh.new()
	fm.size = Vector3(2.85, 2.40, 0.40)
	frame.mesh = fm
	frame.material_override = wood_mat
	frame.position = Vector3(0, 1.20, 0)
	rack.add_child(frame)
	# 4 vertical staves leaning against rack
	for i in 4:
		var staff: MeshInstance3D = MeshInstance3D.new()
		var sm: CylinderMesh = CylinderMesh.new()
		sm.top_radius = 0.05
		sm.bottom_radius = 0.06
		sm.height = 2.20
		staff.mesh = sm
		staff.material_override = wood_mat
		staff.position = Vector3(-1.10 + i * 0.45, 1.10, 0.30)
		staff.rotation_degrees = Vector3(0, 0, 5)
		rack.add_child(staff)
	# 2 hanging swords (slim cylinders + small handles)
	var blade_mat: StandardMaterial3D = StandardMaterial3D.new()
	blade_mat.albedo_color = Color(0.85, 0.92, 1.0)
	blade_mat.metallic = 0.95
	blade_mat.roughness = 0.05
	for sx in [-0.85, 0.85]:
		var sword: MeshInstance3D = MeshInstance3D.new()
		var swm: BoxMesh = BoxMesh.new()
		swm.size = Vector3(0.06, 1.40, 0.04)
		sword.mesh = swm
		sword.material_override = blade_mat
		sword.position = Vector3(sx, 1.85, 0.25)
		rack.add_child(sword)
		# Handle
		var handle: MeshInstance3D = MeshInstance3D.new()
		var hm: BoxMesh = BoxMesh.new()
		hm.size = Vector3(0.10, 0.20, 0.06)
		handle.mesh = hm
		var handle_mat: StandardMaterial3D = StandardMaterial3D.new()
		handle_mat.albedo_color = Color(0.20, 0.18, 0.10)
		handle.material_override = handle_mat
		handle.position = Vector3(sx, 2.65, 0.25)
		rack.add_child(handle)
	# Rack collision
	var sb: StaticBody3D = StaticBody3D.new()
	sb.position = Vector3(0, 1.20, 0)
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(2.85, 2.40, 0.40)
	cs.shape = cb
	sb.add_child(cs)
	rack.add_child(sb)


static func _build_d7_d7_archer_npc(town: Node) -> void:
	## Epic-7 T37: D7 archer NPC — green tunic + held longbow.
	var npc_slots: Node3D = town.get_node_or_null("%NPCSlots") as Node3D
	if npc_slots == null:
		return
	var slot: Marker3D = Marker3D.new()
	slot.name = "D7ArcherSlot"
	slot.position = Vector3(D7_CENTER.x - 6.0, 0.0, -16.0)
	npc_slots.add_child(slot)
	var npc_scene: PackedScene = load("res://scenes/entities/npcs/VillagerR3.tscn") as PackedScene
	if npc_scene == null:
		return
	var npc: Node3D = npc_scene.instantiate() as Node3D
	npc.name = "D7Archer"
	if "npc_name" in npc:
		npc.set("npc_name", "Quill")
	if "npc_id" in npc:
		npc.set("npc_id", "archer_d7")
	slot.add_child(npc)
	# Green tunic
	var tunic: MeshInstance3D = MeshInstance3D.new()
	var tm: BoxMesh = BoxMesh.new()
	tm.size = Vector3(0.65, 1.05, 0.40)
	tunic.mesh = tm
	var tunic_mat: StandardMaterial3D = StandardMaterial3D.new()
	tunic_mat.albedo_color = Color(0.20, 0.55, 0.20)
	tunic_mat.roughness = 0.85
	tunic.material_override = tunic_mat
	tunic.position = Vector3(0, 0.55, 0)
	npc.add_child(tunic)
	# Longbow (curved torus)
	var bow: MeshInstance3D = MeshInstance3D.new()
	var bm: TorusMesh = TorusMesh.new()
	bm.inner_radius = 0.55
	bm.outer_radius = 0.60
	bow.mesh = bm
	var wood_mat: StandardMaterial3D = StandardMaterial3D.new()
	wood_mat.albedo_color = Color(0.45, 0.28, 0.12)
	wood_mat.roughness = 0.85
	bow.material_override = wood_mat
	bow.position = Vector3(0.45, 0.85, 0)
	bow.rotation_degrees = Vector3(0, 0, 90)
	bow.scale = Vector3(1.0, 0.40, 1.0)
	npc.add_child(bow)


static func _build_d7_target_stands(geom: Node) -> void:
	## Epic-7 T38: 3 archery target stands — wooden frames with concentric
	## bullseye discs (like the East Plaza but with wood theme).
	var stands: Node3D = Node3D.new()
	stands.name = "D7TargetStands"
	stands.position = Vector3(D7_CENTER.x - 4.0, 0.0, -22.0)
	geom.add_child(stands)
	var wood_mat: StandardMaterial3D = StandardMaterial3D.new()
	wood_mat.albedo_color = Color(0.45, 0.28, 0.12)
	wood_mat.roughness = 0.85
	var ring_white: Color = Color(0.92, 0.92, 0.85)
	var ring_red: Color = Color(0.85, 0.20, 0.20)
	var ring_yellow: Color = Color(0.95, 0.85, 0.20)
	var rings: Array = [
		{"r": 0.55, "c": ring_white},
		{"r": 0.40, "c": ring_red},
		{"r": 0.25, "c": ring_white},
		{"r": 0.10, "c": ring_yellow},
	]
	for i in 3:
		var stand: Node3D = Node3D.new()
		stand.position = Vector3(i * 2.40, 0, 0)
		stands.add_child(stand)
		# 2 vertical posts
		for sx in [-0.50, 0.50]:
			var post: MeshInstance3D = MeshInstance3D.new()
			var pm: BoxMesh = BoxMesh.new()
			pm.size = Vector3(0.10, 1.85, 0.10)
			post.mesh = pm
			post.material_override = wood_mat
			post.position = Vector3(sx, 0.92, 0)
			stand.add_child(post)
		# Bullseye rings
		for ring in rings:
			var disc: MeshInstance3D = MeshInstance3D.new()
			var dm: CylinderMesh = CylinderMesh.new()
			dm.top_radius = ring["r"]
			dm.bottom_radius = ring["r"]
			dm.height = 0.04
			disc.mesh = dm
			var dmat: StandardMaterial3D = StandardMaterial3D.new()
			dmat.albedo_color = ring["c"]
			dmat.emission_enabled = true
			dmat.emission = ring["c"]
			dmat.emission_energy_multiplier = 0.45
			dmat.roughness = 0.55
			disc.material_override = dmat
			disc.position = Vector3(0, 1.20, 0.0 - rings.find(ring) * 0.005)
			disc.rotation_degrees = Vector3(90, 0, 0)
			stand.add_child(disc)
		# Stand collision
		var sb: StaticBody3D = StaticBody3D.new()
		sb.position = Vector3(0, 0.92, 0)
		var cs: CollisionShape3D = CollisionShape3D.new()
		var cb: BoxShape3D = BoxShape3D.new()
		cb.size = Vector3(1.20, 1.85, 0.30)
		cs.shape = cb
		sb.add_child(cs)
		stand.add_child(sb)


static func _build_d7_shrine_pillars(geom: Node) -> void:
	## Epic-7 T39: 6 small shrine pillars in a row, each with a tiny
	## glowing offering bowl on top.
	var pillars: Node3D = Node3D.new()
	pillars.name = "ShrinePillars"
	pillars.position = Vector3(D7_CENTER.x + 8.0, 0.0, -22.0)
	geom.add_child(pillars)
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.55, 0.45, 0.30)
	stone_mat.roughness = 0.92
	var glow_mat: StandardMaterial3D = StandardMaterial3D.new()
	glow_mat.albedo_color = Color(1.0, 0.65, 0.30)
	glow_mat.emission_enabled = true
	glow_mat.emission = Color(1.0, 0.55, 0.20)
	glow_mat.emission_energy_multiplier = 3.0
	glow_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for i in 6:
		var pillar: Node3D = Node3D.new()
		pillar.position = Vector3(i * 1.40, 0, 0)
		pillars.add_child(pillar)
		# Stone column
		var col: MeshInstance3D = MeshInstance3D.new()
		var cm: CylinderMesh = CylinderMesh.new()
		cm.top_radius = 0.22
		cm.bottom_radius = 0.30
		cm.height = 1.40
		col.mesh = cm
		col.material_override = stone_mat
		col.position = Vector3(0, 0.70, 0)
		pillar.add_child(col)
		# Top bowl
		var bowl: MeshInstance3D = MeshInstance3D.new()
		var bm: SphereMesh = SphereMesh.new()
		bm.radius = 0.22
		bm.height = 0.18
		bowl.mesh = bm
		bowl.material_override = stone_mat
		bowl.position = Vector3(0, 1.50, 0)
		pillar.add_child(bowl)
		# Offering glow (small bright sphere)
		var offering: MeshInstance3D = MeshInstance3D.new()
		var om: SphereMesh = SphereMesh.new()
		om.radius = 0.10
		om.height = 0.18
		offering.mesh = om
		offering.material_override = glow_mat
		offering.position = Vector3(0, 1.65, 0)
		pillar.add_child(offering)
		# Pulse offering
		var tw: Tween = offering.create_tween().set_loops()
		tw.tween_interval(i * 0.20)
		tw.tween_property(offering, "scale", Vector3.ONE * 1.30, 0.85)
		tw.tween_property(offering, "scale", Vector3.ONE * 0.85, 0.85)
		# Pillar collision
		var sb: StaticBody3D = StaticBody3D.new()
		sb.position = Vector3(0, 0.70, 0)
		var cs: CollisionShape3D = CollisionShape3D.new()
		var cap: CapsuleShape3D = CapsuleShape3D.new()
		cap.radius = 0.30
		cap.height = 1.40
		cs.shape = cap
		sb.add_child(cs)
		pillar.add_child(sb)


static func _build_d7_spirit_braziers(geom: Node) -> void:
	## Epic-7 T40: 4 spirit braziers — large bronze cauldrons with bright
	## blue flame cores and rising sparks.
	var braziers: Node3D = Node3D.new()
	braziers.name = "SpiritBraziers"
	braziers.position = Vector3(D7_CENTER.x + 14.0, 0.0, -8.0)
	geom.add_child(braziers)
	var bronze_mat: StandardMaterial3D = StandardMaterial3D.new()
	bronze_mat.albedo_color = Color(0.65, 0.45, 0.20)
	bronze_mat.metallic = 0.85
	bronze_mat.roughness = 0.30
	for i in 4:
		var brazier: Node3D = Node3D.new()
		brazier.position = Vector3(i * 1.85, 0, 0)
		braziers.add_child(brazier)
		# Large cauldron sphere
		var bowl: MeshInstance3D = MeshInstance3D.new()
		var bm: SphereMesh = SphereMesh.new()
		bm.radius = 0.55
		bm.height = 0.65
		bowl.mesh = bm
		bowl.material_override = bronze_mat
		bowl.position = Vector3(0, 1.0, 0)
		bowl.scale = Vector3(1.0, 0.85, 1.0)
		brazier.add_child(bowl)
		# 3 tripod legs
		for j in 3:
			var ang: float = (TAU / 3.0) * j
			var leg: MeshInstance3D = MeshInstance3D.new()
			var lm: CylinderMesh = CylinderMesh.new()
			lm.top_radius = 0.06
			lm.bottom_radius = 0.08
			lm.height = 0.85
			leg.mesh = lm
			leg.material_override = bronze_mat
			leg.position = Vector3(cos(ang) * 0.30, 0.42, sin(ang) * 0.30)
			leg.rotation = Vector3(deg_to_rad(15) * sin(ang), 0, deg_to_rad(15) * cos(ang))
			brazier.add_child(leg)
		# Blue flame core
		var flame: MeshInstance3D = MeshInstance3D.new()
		var fm: SphereMesh = SphereMesh.new()
		fm.radius = 0.30
		fm.height = 0.55
		flame.mesh = fm
		var flame_mat: StandardMaterial3D = StandardMaterial3D.new()
		flame_mat.albedo_color = Color(0.30, 0.65, 1.0)
		flame_mat.emission_enabled = true
		flame_mat.emission = Color(0.30, 0.85, 1.0)
		flame_mat.emission_energy_multiplier = 4.0
		flame_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		flame.material_override = flame_mat
		flame.position = Vector3(0, 1.20, 0)
		brazier.add_child(flame)
		# Flicker
		var tw: Tween = flame.create_tween().set_loops()
		tw.tween_interval(i * 0.10)
		tw.tween_property(flame, "scale", Vector3(1.20, 1.30, 1.20), 0.20)
		tw.tween_property(flame, "scale", Vector3(0.85, 0.85, 0.85), 0.20)
		# Spark particles
		var sparks: GPUParticles3D = GPUParticles3D.new()
		sparks.amount = 25
		sparks.lifetime = 1.85
		sparks.preprocess = 1.0
		sparks.position = Vector3(0, 1.40, 0)
		var pm: ParticleProcessMaterial = ParticleProcessMaterial.new()
		pm.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_POINT
		pm.direction = Vector3(0, 1, 0)
		pm.spread = 25.0
		pm.gravity = Vector3.ZERO
		pm.initial_velocity_min = 0.55
		pm.initial_velocity_max = 1.30
		pm.scale_min = 0.04
		pm.scale_max = 0.10
		pm.color = Color(0.30, 0.85, 1.0, 0.85)
		sparks.process_material = pm
		var sm_mesh: SphereMesh = SphereMesh.new()
		sm_mesh.radius = 0.04
		sm_mesh.height = 0.08
		sparks.draw_pass_1 = sm_mesh
		var sm_mat: StandardMaterial3D = StandardMaterial3D.new()
		sm_mat.albedo_color = Color(0.30, 0.85, 1.0)
		sm_mat.emission_enabled = true
		sm_mat.emission = Color(0.30, 0.95, 1.0)
		sm_mat.emission_energy_multiplier = 3.0
		sm_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		sm_mesh.material = sm_mat
		brazier.add_child(sparks)
		# Light
		var light: OmniLight3D = OmniLight3D.new()
		light.light_color = Color(0.40, 0.85, 1.0)
		light.light_energy = 2.5
		light.omni_range = 5.5
		light.position = Vector3(0, 1.20, 0)
		brazier.add_child(light)
		# Brazier collision
		var sb: StaticBody3D = StaticBody3D.new()
		sb.position = Vector3(0, 0.85, 0)
		var cs: CollisionShape3D = CollisionShape3D.new()
		var cap: CapsuleShape3D = CapsuleShape3D.new()
		cap.radius = 0.55
		cap.height = 1.40
		cs.shape = cap
		sb.add_child(cs)
		brazier.add_child(sb)


static func _build_d7_alms_bowls(geom: Node) -> void:
	## Epic-7 T41: row of 5 bronze alms bowls on small wooden pedestals.
	var bowls: Node3D = Node3D.new()
	bowls.name = "AlmsBowls"
	bowls.position = Vector3(D7_CENTER.x - 18.0, 0.0, 22.0)
	geom.add_child(bowls)
	var wood_mat: StandardMaterial3D = StandardMaterial3D.new()
	wood_mat.albedo_color = Color(0.45, 0.28, 0.12)
	wood_mat.roughness = 0.85
	var bronze_mat: StandardMaterial3D = StandardMaterial3D.new()
	bronze_mat.albedo_color = Color(0.65, 0.45, 0.20)
	bronze_mat.metallic = 0.85
	bronze_mat.roughness = 0.30
	for i in 5:
		var stand: Node3D = Node3D.new()
		stand.position = Vector3(i * 1.10, 0, 0)
		bowls.add_child(stand)
		# Wooden pedestal
		var ped: MeshInstance3D = MeshInstance3D.new()
		var pm: BoxMesh = BoxMesh.new()
		pm.size = Vector3(0.55, 0.85, 0.55)
		ped.mesh = pm
		ped.material_override = wood_mat
		ped.position = Vector3(0, 0.42, 0)
		stand.add_child(ped)
		# Bronze bowl on top
		var bowl: MeshInstance3D = MeshInstance3D.new()
		var bm: SphereMesh = SphereMesh.new()
		bm.radius = 0.22
		bm.height = 0.20
		bowl.mesh = bm
		bowl.material_override = bronze_mat
		bowl.position = Vector3(0, 0.95, 0)
		bowl.scale = Vector3(1.0, 0.55, 1.0)
		stand.add_child(bowl)
		# Glow inside (small bright sphere)
		var glow: MeshInstance3D = MeshInstance3D.new()
		var gm: SphereMesh = SphereMesh.new()
		gm.radius = 0.08
		gm.height = 0.10
		glow.mesh = gm
		var glow_mat: StandardMaterial3D = StandardMaterial3D.new()
		glow_mat.albedo_color = Color(1.0, 0.85, 0.30)
		glow_mat.emission_enabled = true
		glow_mat.emission = Color(1.0, 0.75, 0.20)
		glow_mat.emission_energy_multiplier = 2.5
		glow_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		glow.material_override = glow_mat
		glow.position = Vector3(0, 0.99, 0)
		stand.add_child(glow)
		# Pedestal collision
		var sb: StaticBody3D = StaticBody3D.new()
		sb.position = Vector3(0, 0.42, 0)
		var cs: CollisionShape3D = CollisionShape3D.new()
		var cb: BoxShape3D = BoxShape3D.new()
		cb.size = Vector3(0.55, 0.85, 0.55)
		cs.shape = cb
		sb.add_child(cs)
		stand.add_child(sb)


static func _build_d7_alms_collector_npc(town: Node) -> void:
	## Epic-7 T42: alms collector NPC — simple brown robe + holding a
	## small wooden bowl.
	var npc_slots: Node3D = town.get_node_or_null("%NPCSlots") as Node3D
	if npc_slots == null:
		return
	var slot: Marker3D = Marker3D.new()
	slot.name = "AlmsCollectorSlot"
	slot.position = Vector3(D7_CENTER.x - 14.0, 0.0, 22.0)
	npc_slots.add_child(slot)
	var npc_scene: PackedScene = load("res://scenes/entities/npcs/VillagerR3.tscn") as PackedScene
	if npc_scene == null:
		return
	var npc: Node3D = npc_scene.instantiate() as Node3D
	npc.name = "AlmsCollector"
	if "npc_name" in npc:
		npc.set("npc_name", "Mendicant")
	if "npc_id" in npc:
		npc.set("npc_id", "alms_d7")
	slot.add_child(npc)
	# Brown robe
	var robe: MeshInstance3D = MeshInstance3D.new()
	var rm: BoxMesh = BoxMesh.new()
	rm.size = Vector3(0.65, 1.20, 0.45)
	robe.mesh = rm
	var robe_mat: StandardMaterial3D = StandardMaterial3D.new()
	robe_mat.albedo_color = Color(0.45, 0.28, 0.12)
	robe.material_override = robe_mat
	robe.position = Vector3(0, 0.60, 0)
	npc.add_child(robe)
	# Wooden bowl
	var bowl: MeshInstance3D = MeshInstance3D.new()
	var bm: SphereMesh = SphereMesh.new()
	bm.radius = 0.18
	bm.height = 0.18
	bowl.mesh = bm
	bowl.material_override = robe_mat
	bowl.position = Vector3(0.40, 0.85, 0.20)
	bowl.scale = Vector3(1.0, 0.55, 1.0)
	npc.add_child(bowl)


static func _build_d7_buddha_statue(geom: Node) -> void:
	## Epic-7 T43: large stone Buddha statue — round seated pose with
	## crossed legs, robes draped over, halo behind head.
	var statue: Node3D = Node3D.new()
	statue.name = "BuddhaStatue"
	statue.position = Vector3(D7_CENTER.x - 4.0, 0.0, 22.0)
	geom.add_child(statue)
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.75, 0.65, 0.45)
	stone_mat.emission_enabled = true
	stone_mat.emission = Color(0.85, 0.65, 0.30)
	stone_mat.emission_energy_multiplier = 0.30
	stone_mat.roughness = 0.85
	# Stone base/lotus pedestal
	var ped: MeshInstance3D = MeshInstance3D.new()
	var pm: CylinderMesh = CylinderMesh.new()
	pm.top_radius = 1.40
	pm.bottom_radius = 1.65
	pm.height = 0.55
	ped.mesh = pm
	ped.material_override = stone_mat
	ped.position = Vector3(0, 0.27, 0)
	statue.add_child(ped)
	# Crossed legs (large flat sphere)
	var legs: MeshInstance3D = MeshInstance3D.new()
	var lm: SphereMesh = SphereMesh.new()
	lm.radius = 1.10
	lm.height = 0.85
	legs.mesh = lm
	legs.material_override = stone_mat
	legs.position = Vector3(0, 0.85, 0)
	legs.scale = Vector3(1.30, 0.55, 1.10)
	statue.add_child(legs)
	# Torso (rounded sphere)
	var torso: MeshInstance3D = MeshInstance3D.new()
	var tm: SphereMesh = SphereMesh.new()
	tm.radius = 0.85
	tm.height = 1.40
	torso.mesh = tm
	torso.material_override = stone_mat
	torso.position = Vector3(0, 1.85, 0)
	torso.scale = Vector3(1.0, 0.85, 0.85)
	statue.add_child(torso)
	# Head
	var head: MeshInstance3D = MeshInstance3D.new()
	var hm: SphereMesh = SphereMesh.new()
	hm.radius = 0.55
	hm.height = 0.95
	head.mesh = hm
	head.material_override = stone_mat
	head.position = Vector3(0, 3.10, 0)
	statue.add_child(head)
	# Topknot (small sphere on head)
	var topknot: MeshInstance3D = MeshInstance3D.new()
	var tnm: SphereMesh = SphereMesh.new()
	tnm.radius = 0.18
	tnm.height = 0.32
	topknot.mesh = tnm
	topknot.material_override = stone_mat
	topknot.position = Vector3(0, 3.65, 0)
	statue.add_child(topknot)
	# Halo (torus behind head)
	var halo: MeshInstance3D = MeshInstance3D.new()
	var halm: TorusMesh = TorusMesh.new()
	halm.inner_radius = 0.85
	halm.outer_radius = 1.0
	halo.mesh = halm
	var halo_mat: StandardMaterial3D = StandardMaterial3D.new()
	halo_mat.albedo_color = Color(1.0, 0.85, 0.30)
	halo_mat.emission_enabled = true
	halo_mat.emission = Color(1.0, 0.85, 0.30)
	halo_mat.emission_energy_multiplier = 3.0
	halo_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	halo.material_override = halo_mat
	halo.position = Vector3(0, 3.10, -0.30)
	halo.rotation_degrees = Vector3(90, 0, 0)
	statue.add_child(halo)
	# Aura light
	var light: OmniLight3D = OmniLight3D.new()
	light.light_color = Color(1.0, 0.85, 0.30)
	light.light_energy = 3.5
	light.omni_range = 9.0
	light.position = Vector3(0, 3.10, 0)
	statue.add_child(light)
	# Statue collision
	var sb: StaticBody3D = StaticBody3D.new()
	sb.position = Vector3(0, 1.85, 0)
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cap: CapsuleShape3D = CapsuleShape3D.new()
	cap.radius = 1.30
	cap.height = 3.85
	cs.shape = cap
	sb.add_child(cs)
	statue.add_child(sb)


static func _build_d7_incense_columns(geom: Node) -> void:
	## Epic-7 T44: 6 thin incense smoke columns rising from the ground —
	## tall ground-anchored GPU particle smoke trails.
	var cols: Node3D = Node3D.new()
	cols.name = "IncenseColumns"
	cols.position = Vector3(D7_CENTER.x + 4.0, 0.0, 18.0)
	geom.add_child(cols)
	for i in 6:
		var col: Node3D = Node3D.new()
		col.position = Vector3(
			randf_range(-3.5, 3.5),
			0,
			randf_range(-2.5, 2.5)
		)
		cols.add_child(col)
		# Tiny grey base stick (incense)
		var stick: MeshInstance3D = MeshInstance3D.new()
		var stm: CylinderMesh = CylinderMesh.new()
		stm.top_radius = 0.025
		stm.bottom_radius = 0.025
		stm.height = 0.85
		stick.mesh = stm
		var stick_mat: StandardMaterial3D = StandardMaterial3D.new()
		stick_mat.albedo_color = Color(0.30, 0.20, 0.10)
		stick.material_override = stick_mat
		stick.position = Vector3(0, 0.42, 0)
		col.add_child(stick)
		# Tiny glow tip
		var tip: MeshInstance3D = MeshInstance3D.new()
		var tm: SphereMesh = SphereMesh.new()
		tm.radius = 0.04
		tm.height = 0.08
		tip.mesh = tm
		var tip_mat: StandardMaterial3D = StandardMaterial3D.new()
		tip_mat.albedo_color = Color(1.0, 0.45, 0.20)
		tip_mat.emission_enabled = true
		tip_mat.emission = Color(1.0, 0.45, 0.20)
		tip_mat.emission_energy_multiplier = 3.5
		tip_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		tip.material_override = tip_mat
		tip.position = Vector3(0, 0.85, 0)
		col.add_child(tip)
		# Smoke particles rising
		var smoke: GPUParticles3D = GPUParticles3D.new()
		smoke.amount = 22
		smoke.lifetime = 4.0
		smoke.preprocess = 2.0
		smoke.position = Vector3(0, 0.85, 0)
		var pm: ParticleProcessMaterial = ParticleProcessMaterial.new()
		pm.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_POINT
		pm.direction = Vector3(0, 1, 0)
		pm.spread = 8.0
		pm.gravity = Vector3.ZERO
		pm.initial_velocity_min = 0.30
		pm.initial_velocity_max = 0.55
		pm.scale_min = 0.08
		pm.scale_max = 0.18
		pm.color = Color(0.92, 0.85, 0.65, 0.65)
		smoke.process_material = pm
		var sm_mesh: SphereMesh = SphereMesh.new()
		sm_mesh.radius = 0.12
		sm_mesh.height = 0.24
		smoke.draw_pass_1 = sm_mesh
		var sm_mat: StandardMaterial3D = StandardMaterial3D.new()
		sm_mat.albedo_color = Color(0.95, 0.85, 0.65, 0.45)
		sm_mat.emission_enabled = true
		sm_mat.emission = Color(0.85, 0.65, 0.30)
		sm_mat.emission_energy_multiplier = 0.55
		sm_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		sm_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		sm_mesh.material = sm_mat
		col.add_child(smoke)


static func _build_d7_ancient_sage_npc(town: Node) -> void:
	## Epic-7 T45: ancient sage NPC — long white robe + extremely long
	## white beard sphere + walking staff.
	var npc_slots: Node3D = town.get_node_or_null("%NPCSlots") as Node3D
	if npc_slots == null:
		return
	var slot: Marker3D = Marker3D.new()
	slot.name = "AncientSageSlot"
	slot.position = Vector3(D7_CENTER.x + 6.0, 0.0, 18.0)
	npc_slots.add_child(slot)
	var npc_scene: PackedScene = load("res://scenes/entities/npcs/VillagerR3.tscn") as PackedScene
	if npc_scene == null:
		return
	var npc: Node3D = npc_scene.instantiate() as Node3D
	npc.name = "AncientSage"
	if "npc_name" in npc:
		npc.set("npc_name", "Cloudwhite")
	if "npc_id" in npc:
		npc.set("npc_id", "sage_d7")
	slot.add_child(npc)
	# Long white robe
	var robe: MeshInstance3D = MeshInstance3D.new()
	var rm: BoxMesh = BoxMesh.new()
	rm.size = Vector3(0.65, 1.30, 0.45)
	robe.mesh = rm
	var robe_mat: StandardMaterial3D = StandardMaterial3D.new()
	robe_mat.albedo_color = Color(0.92, 0.92, 0.85)
	robe_mat.emission_enabled = true
	robe_mat.emission = Color(0.85, 0.85, 0.85)
	robe_mat.emission_energy_multiplier = 0.30
	robe_mat.roughness = 0.75
	robe.material_override = robe_mat
	robe.position = Vector3(0, 0.65, 0)
	npc.add_child(robe)
	# Long white beard (long elongated sphere)
	var beard: MeshInstance3D = MeshInstance3D.new()
	var bm: SphereMesh = SphereMesh.new()
	bm.radius = 0.18
	bm.height = 0.85
	beard.mesh = bm
	var beard_mat: StandardMaterial3D = StandardMaterial3D.new()
	beard_mat.albedo_color = Color(0.95, 0.95, 0.92)
	beard_mat.roughness = 0.95
	beard.material_override = beard_mat
	beard.position = Vector3(0, 1.0, 0.20)
	beard.scale = Vector3(0.85, 1.85, 0.55)
	npc.add_child(beard)
	# Walking staff
	var wood_mat: StandardMaterial3D = StandardMaterial3D.new()
	wood_mat.albedo_color = Color(0.40, 0.25, 0.10)
	wood_mat.roughness = 0.85
	var staff: MeshInstance3D = MeshInstance3D.new()
	var stm: CylinderMesh = CylinderMesh.new()
	stm.top_radius = 0.04
	stm.bottom_radius = 0.05
	stm.height = 1.85
	staff.mesh = stm
	staff.material_override = wood_mat
	staff.position = Vector3(0.45, 0.92, 0)
	npc.add_child(staff)


static func _build_d7_cave_entrance(geom: Node) -> void:
	## Epic-7 T46: hidden cave entrance — flattened sphere half-dome of dark
	## rock + dark interior plug + soft amber inner light.
	var cave: Node3D = Node3D.new()
	cave.name = "D7CaveEntrance"
	cave.position = Vector3(D7_CENTER.x + 28.0, 0.0, 12.0)
	geom.add_child(cave)
	var rock_mat: StandardMaterial3D = StandardMaterial3D.new()
	rock_mat.albedo_color = Color(0.30, 0.20, 0.10)
	rock_mat.roughness = 0.92
	# Half-dome
	var dome: MeshInstance3D = MeshInstance3D.new()
	var dm: SphereMesh = SphereMesh.new()
	dm.radius = 3.40
	dm.height = 5.40
	dome.mesh = dm
	dome.material_override = rock_mat
	dome.position = Vector3(0, 2.20, 0)
	dome.scale = Vector3(1.0, 0.85, 1.0)
	cave.add_child(dome)
	# Dark interior plug
	var dark: MeshInstance3D = MeshInstance3D.new()
	var darkm: CylinderMesh = CylinderMesh.new()
	darkm.top_radius = 1.85
	darkm.bottom_radius = 1.85
	darkm.height = 0.20
	dark.mesh = darkm
	var dark_mat: StandardMaterial3D = StandardMaterial3D.new()
	dark_mat.albedo_color = Color(0.04, 0.03, 0.05)
	dark_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	dark.material_override = dark_mat
	dark.position = Vector3(0, 1.85, 1.40)
	dark.rotation_degrees = Vector3(90, 0, 0)
	cave.add_child(dark)
	# Inner amber light
	var inner: OmniLight3D = OmniLight3D.new()
	inner.light_color = Color(1.0, 0.65, 0.30)
	inner.light_energy = 1.85
	inner.omni_range = 5.5
	inner.position = Vector3(0, 1.55, 0.85)
	cave.add_child(inner)
	# Cave dome collision (sphere shape)
	var sb: StaticBody3D = StaticBody3D.new()
	sb.position = Vector3(0, 2.20, 0)
	var cs: CollisionShape3D = CollisionShape3D.new()
	var sphere: SphereShape3D = SphereShape3D.new()
	sphere.radius = 2.85
	cs.shape = sphere
	sb.add_child(cs)
	cave.add_child(sb)


static func _build_d7_cave_hermit_npc(town: Node) -> void:
	## Epic-7 T47: cave hermit NPC at the cave entrance — ragged grey
	## cloak + held gnarled staff with crystal head.
	var npc_slots: Node3D = town.get_node_or_null("%NPCSlots") as Node3D
	if npc_slots == null:
		return
	var slot: Marker3D = Marker3D.new()
	slot.name = "CaveHermitSlot"
	slot.position = Vector3(D7_CENTER.x + 26.0, 0.0, 12.0)
	npc_slots.add_child(slot)
	var npc_scene: PackedScene = load("res://scenes/entities/npcs/VillagerR3.tscn") as PackedScene
	if npc_scene == null:
		return
	var npc: Node3D = npc_scene.instantiate() as Node3D
	npc.name = "CaveHermit"
	if "npc_name" in npc:
		npc.set("npc_name", "Stoneheart")
	if "npc_id" in npc:
		npc.set("npc_id", "hermit_d7")
	slot.add_child(npc)
	# Ragged grey cloak
	var cloak: MeshInstance3D = MeshInstance3D.new()
	var cm: BoxMesh = BoxMesh.new()
	cm.size = Vector3(0.65, 1.20, 0.45)
	cloak.mesh = cm
	var cloak_mat: StandardMaterial3D = StandardMaterial3D.new()
	cloak_mat.albedo_color = Color(0.30, 0.30, 0.32)
	cloak_mat.roughness = 0.95
	cloak.material_override = cloak_mat
	cloak.position = Vector3(0, 0.60, 0)
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
	# Gnarled wooden staff
	var wood_mat: StandardMaterial3D = StandardMaterial3D.new()
	wood_mat.albedo_color = Color(0.30, 0.18, 0.10)
	wood_mat.roughness = 0.92
	var staff: MeshInstance3D = MeshInstance3D.new()
	var stm: CylinderMesh = CylinderMesh.new()
	stm.top_radius = 0.05
	stm.bottom_radius = 0.07
	stm.height = 1.85
	staff.mesh = stm
	staff.material_override = wood_mat
	staff.position = Vector3(0.45, 0.92, 0)
	npc.add_child(staff)
	# Crystal head on staff (small bright sphere)
	var crystal: MeshInstance3D = MeshInstance3D.new()
	var cmm: SphereMesh = SphereMesh.new()
	cmm.radius = 0.12
	cmm.height = 0.20
	crystal.mesh = cmm
	var crystal_mat: StandardMaterial3D = StandardMaterial3D.new()
	crystal_mat.albedo_color = Color(0.85, 0.65, 0.30)
	crystal_mat.emission_enabled = true
	crystal_mat.emission = Color(1.0, 0.65, 0.20)
	crystal_mat.emission_energy_multiplier = 3.0
	crystal_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	crystal.material_override = crystal_mat
	crystal.position = Vector3(0.45, 1.92, 0)
	npc.add_child(crystal)


static func _build_d7_burial_cairns(geom: Node) -> void:
	## Epic-7 T48: 5 small burial cairns spread out — mounds of stones
	## with small stick markers.
	var cairns: Node3D = Node3D.new()
	cairns.name = "BurialCairns"
	cairns.position = Vector3(D7_CENTER.x + 18.0, 0.0, -22.0)
	geom.add_child(cairns)
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.45, 0.35, 0.25)
	stone_mat.roughness = 0.92
	var wood_mat: StandardMaterial3D = StandardMaterial3D.new()
	wood_mat.albedo_color = Color(0.30, 0.18, 0.10)
	wood_mat.roughness = 0.92
	for i in 5:
		var cairn: Node3D = Node3D.new()
		cairn.position = Vector3(
			randf_range(-3.5, 3.5),
			0,
			randf_range(-2.5, 2.5)
		)
		cairns.add_child(cairn)
		# 4 stones forming a small mound
		for j in 4:
			var stone: MeshInstance3D = MeshInstance3D.new()
			var sm: SphereMesh = SphereMesh.new()
			sm.radius = 0.30
			sm.height = 0.40
			stone.mesh = sm
			stone.material_override = stone_mat
			stone.position = Vector3(
				randf_range(-0.18, 0.18),
				0.18 + j * 0.20,
				randf_range(-0.18, 0.18)
			)
			stone.scale = Vector3(1.0, 0.55, 1.0)
			cairn.add_child(stone)
		# Small stick marker
		var stick: MeshInstance3D = MeshInstance3D.new()
		var stm: CylinderMesh = CylinderMesh.new()
		stm.top_radius = 0.025
		stm.bottom_radius = 0.025
		stm.height = 0.55
		stick.mesh = stm
		stick.material_override = wood_mat
		stick.position = Vector3(0, 1.10, 0)
		cairn.add_child(stick)


static func _build_d7_rune_monoliths(geom: Node) -> void:
	## Epic-7 T49: 5 ancient rune monoliths in a row — tall narrow stone
	## slabs with carved glowing rune symbols.
	var monos: Node3D = Node3D.new()
	monos.name = "RuneMonoliths"
	monos.position = Vector3(D7_CENTER.x + 22.0, 0.0, -8.0)
	geom.add_child(monos)
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.55, 0.45, 0.30)
	stone_mat.roughness = 0.92
	var rune_mat: StandardMaterial3D = StandardMaterial3D.new()
	rune_mat.albedo_color = Color(1.0, 0.65, 0.20)
	rune_mat.emission_enabled = true
	rune_mat.emission = Color(1.0, 0.65, 0.20)
	rune_mat.emission_energy_multiplier = 3.0
	rune_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for i in 5:
		var mono: Node3D = Node3D.new()
		mono.position = Vector3(i * 1.85, 0, 0)
		monos.add_child(mono)
		# Stone slab
		var slab: MeshInstance3D = MeshInstance3D.new()
		var sm: BoxMesh = BoxMesh.new()
		sm.size = Vector3(0.85, 3.40 + (i % 3) * 0.30, 0.40)
		slab.mesh = sm
		slab.material_override = stone_mat
		slab.position = Vector3(0, sm.size.y * 0.5, 0)
		mono.add_child(slab)
		# Rune carving
		var rune: MeshInstance3D = MeshInstance3D.new()
		var rm: BoxMesh = BoxMesh.new()
		rm.size = Vector3(0.40, 1.40, 0.04)
		rune.mesh = rm
		rune.material_override = rune_mat
		rune.position = Vector3(0, sm.size.y * 0.5, 0.22)
		mono.add_child(rune)
		# Pulse rune
		var tw: Tween = rune.create_tween().set_loops()
		tw.tween_interval(i * 0.20)
		tw.tween_property(rune, "scale:y", 1.20, 0.85)
		tw.tween_property(rune, "scale:y", 0.85, 0.85)
		# Slab collision
		var sb: StaticBody3D = StaticBody3D.new()
		sb.position = Vector3(0, sm.size.y * 0.5, 0)
		var cs: CollisionShape3D = CollisionShape3D.new()
		var cb: BoxShape3D = BoxShape3D.new()
		cb.size = sm.size
		cs.shape = cb
		sb.add_child(cs)
		mono.add_child(sb)


static func _build_d7_stone_colossus(geom: Node) -> void:
	## Epic-7 T50: STONE COLOSSUS — D7 mid-boss landmark. Massive stone
	## titan with hammer, glowing amber rune body cracks, and a halo of
	## floating boulders.
	var col: Node3D = Node3D.new()
	col.name = "StoneColossus"
	col.position = Vector3(D7_CENTER.x + 4.0, 0.0, -22.0)
	geom.add_child(col)
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.55, 0.45, 0.30)
	stone_mat.roughness = 0.92
	var dark_stone: StandardMaterial3D = StandardMaterial3D.new()
	dark_stone.albedo_color = Color(0.40, 0.30, 0.20)
	dark_stone.roughness = 0.92
	var rune_mat: StandardMaterial3D = StandardMaterial3D.new()
	rune_mat.albedo_color = Color(1.0, 0.65, 0.20)
	rune_mat.emission_enabled = true
	rune_mat.emission = Color(1.0, 0.55, 0.10)
	rune_mat.emission_energy_multiplier = 4.0
	rune_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	# Stone pedestal
	var ped: MeshInstance3D = MeshInstance3D.new()
	var pm: BoxMesh = BoxMesh.new()
	pm.size = Vector3(3.85, 0.55, 3.85)
	ped.mesh = pm
	ped.material_override = dark_stone
	ped.position = Vector3(0, 0.27, 0)
	col.add_child(ped)
	# Massive torso block
	var torso: MeshInstance3D = MeshInstance3D.new()
	var tm: BoxMesh = BoxMesh.new()
	tm.size = Vector3(2.40, 3.40, 1.85)
	torso.mesh = tm
	torso.material_override = stone_mat
	torso.position = Vector3(0, 2.40, 0)
	col.add_child(torso)
	# 3 vertical rune cracks down the torso
	for i in 3:
		var crack: MeshInstance3D = MeshInstance3D.new()
		var crm: BoxMesh = BoxMesh.new()
		crm.size = Vector3(0.10, 2.40, 0.06)
		crack.mesh = crm
		crack.material_override = rune_mat
		crack.position = Vector3(-0.65 + i * 0.65, 2.40, 0.95)
		col.add_child(crack)
		# Pulse cracks
		var tw: Tween = crack.create_tween().set_loops()
		tw.tween_interval(i * 0.20)
		tw.tween_property(crack, "scale:y", 1.20, 1.0)
		tw.tween_property(crack, "scale:y", 0.85, 1.0)
	# Helmet/head block
	var head: MeshInstance3D = MeshInstance3D.new()
	var hm: BoxMesh = BoxMesh.new()
	hm.size = Vector3(1.40, 1.30, 1.30)
	head.mesh = hm
	head.material_override = stone_mat
	head.position = Vector3(0, 4.85, 0)
	col.add_child(head)
	# 2 glowing eye slits
	for sx in [-0.30, 0.30]:
		var eye: MeshInstance3D = MeshInstance3D.new()
		var em: BoxMesh = BoxMesh.new()
		em.size = Vector3(0.18, 0.10, 0.04)
		eye.mesh = em
		eye.material_override = rune_mat
		eye.position = Vector3(sx, 4.95, 0.65)
		col.add_child(eye)
	# Crown spikes (3 angular shards)
	for i in 3:
		var spike: MeshInstance3D = MeshInstance3D.new()
		var spm: PrismMesh = PrismMesh.new()
		spm.size = Vector3(0.20, 0.55 + i * 0.10, 0.20)
		spike.mesh = spm
		spike.material_override = stone_mat
		spike.position = Vector3(-0.40 + i * 0.40, 5.85, 0)
		col.add_child(spike)
	# Shoulder pauldrons
	for sx in [-1.65, 1.65]:
		var paul: MeshInstance3D = MeshInstance3D.new()
		var prm: BoxMesh = BoxMesh.new()
		prm.size = Vector3(0.95, 0.65, 1.10)
		paul.mesh = prm
		paul.material_override = stone_mat
		paul.position = Vector3(sx, 3.95, 0)
		col.add_child(paul)
	# 2 thick arms
	for sx in [-1.85, 1.85]:
		var arm: MeshInstance3D = MeshInstance3D.new()
		var am: BoxMesh = BoxMesh.new()
		am.size = Vector3(0.85, 2.40, 0.85)
		arm.mesh = am
		arm.material_override = stone_mat
		arm.position = Vector3(sx, 2.40, 0)
		col.add_child(arm)
	# 2 legs
	for sx in [-0.65, 0.65]:
		var leg: MeshInstance3D = MeshInstance3D.new()
		var lm: BoxMesh = BoxMesh.new()
		lm.size = Vector3(0.85, 1.10, 1.10)
		leg.mesh = lm
		leg.material_override = stone_mat
		leg.position = Vector3(sx, 1.10, 0)
		col.add_child(leg)
	# Massive stone hammer (held by right arm)
	var hammer_root: Node3D = Node3D.new()
	hammer_root.position = Vector3(2.40, 3.20, 0)
	hammer_root.rotation_degrees = Vector3(0, 0, -25)
	col.add_child(hammer_root)
	# Handle
	var handle: MeshInstance3D = MeshInstance3D.new()
	var hndm: CylinderMesh = CylinderMesh.new()
	hndm.top_radius = 0.10
	hndm.bottom_radius = 0.10
	hndm.height = 2.85
	handle.mesh = hndm
	var wood_mat: StandardMaterial3D = StandardMaterial3D.new()
	wood_mat.albedo_color = Color(0.30, 0.18, 0.10)
	wood_mat.roughness = 0.92
	handle.material_override = wood_mat
	handle.position = Vector3(0, 1.40, 0)
	hammer_root.add_child(handle)
	# Hammer head (huge stone block)
	var hammer_head: MeshInstance3D = MeshInstance3D.new()
	var hhm: BoxMesh = BoxMesh.new()
	hhm.size = Vector3(0.95, 0.85, 1.40)
	hammer_head.mesh = hhm
	hammer_head.material_override = stone_mat
	hammer_head.position = Vector3(0, 2.85, 0)
	hammer_root.add_child(hammer_head)
	# Glowing rune line on hammer head
	var hrune: MeshInstance3D = MeshInstance3D.new()
	var hrm: BoxMesh = BoxMesh.new()
	hrm.size = Vector3(0.06, 0.55, 0.10)
	hrune.mesh = hrm
	hrune.material_override = rune_mat
	hrune.position = Vector3(0, 2.85, 0.75)
	hammer_root.add_child(hrune)
	# 6 floating boulders orbiting the head
	var halo: Node3D = Node3D.new()
	halo.position = Vector3(0, 5.50, 0)
	col.add_child(halo)
	for i in 6:
		var ang: float = (TAU / 6.0) * i
		var boulder: MeshInstance3D = MeshInstance3D.new()
		var bm: BoxMesh = BoxMesh.new()
		bm.size = Vector3(0.40, 0.40, 0.40)
		boulder.mesh = bm
		boulder.material_override = stone_mat
		boulder.position = Vector3(cos(ang) * 2.40, 0, sin(ang) * 2.40)
		boulder.rotation_degrees = Vector3(randf_range(-30, 30), randf_range(0, 360), randf_range(-30, 30))
		halo.add_child(boulder)
	var trot: Tween = halo.create_tween().set_loops()
	trot.tween_property(halo, "rotation_degrees:y", 360.0, 14.0)
	trot.tween_property(halo, "rotation_degrees:y", 0.0, 0.0)
	# Massive aura light
	var light: OmniLight3D = OmniLight3D.new()
	light.light_color = Color(1.0, 0.65, 0.20)
	light.light_energy = 5.5
	light.omni_range = 18.0
	light.position = Vector3(0, 4.20, 0)
	col.add_child(light)
	var twl: Tween = light.create_tween().set_loops()
	twl.tween_property(light, "light_energy", 7.0, 1.6)
	twl.tween_property(light, "light_energy", 5.0, 1.6)
	# Title labels
	var title: Label3D = Label3D.new()
	title.text = "THE STONE COLOSSUS"
	title.modulate = Color(1.0, 0.85, 0.45)
	title.outline_modulate = Color(0.20, 0.10, 0.05)
	title.outline_size = 12
	title.font_size = 80
	title.pixel_size = 0.013
	title.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	title.position = Vector3(0, 7.40, 0)
	col.add_child(title)
	var subtitle: Label3D = Label3D.new()
	subtitle.text = "Carved from the first iteration"
	subtitle.modulate = Color(0.85, 0.95, 1.0)
	subtitle.outline_modulate = Color(0.20, 0.10, 0.05)
	subtitle.outline_size = 8
	subtitle.font_size = 42
	subtitle.pixel_size = 0.011
	subtitle.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	subtitle.position = Vector3(0, 6.80, 0)
	col.add_child(subtitle)
	# Body collision
	var sb: StaticBody3D = StaticBody3D.new()
	sb.position = Vector3(0, 3.20, 0)
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(2.85, 5.85, 1.85)
	cs.shape = cb
	sb.add_child(cs)
	col.add_child(sb)
	# Pedestal collision
	var psb: StaticBody3D = StaticBody3D.new()
	psb.position = Vector3(0, 0.27, 0)
	var pcs: CollisionShape3D = CollisionShape3D.new()
	var pcb: BoxShape3D = BoxShape3D.new()
	pcb.size = Vector3(3.85, 0.55, 3.85)
	pcs.shape = pcb
	psb.add_child(pcs)
	col.add_child(psb)


static func _build_d7_hawks(geom: Node) -> void:
	## Epic-7 T51: 4 hawks soaring overhead in slow circling pattern at
	## different altitudes.
	var hawks: Node3D = Node3D.new()
	hawks.name = "Hawks"
	hawks.position = Vector3(D7_CENTER.x, 6.0, 0.0)
	geom.add_child(hawks)
	var brown_mat: StandardMaterial3D = StandardMaterial3D.new()
	brown_mat.albedo_color = Color(0.45, 0.28, 0.15)
	brown_mat.roughness = 0.85
	for i in 4:
		var pivot: Node3D = Node3D.new()
		pivot.position = Vector3(0, i * 0.65, 0)
		pivot.rotation_degrees = Vector3(0, i * 90.0, 0)
		hawks.add_child(pivot)
		var hawk: Node3D = Node3D.new()
		hawk.position = Vector3(10.0 + i * 1.40, 0, 0)
		pivot.add_child(hawk)
		# Body
		var body: MeshInstance3D = MeshInstance3D.new()
		var bm: SphereMesh = SphereMesh.new()
		bm.radius = 0.22
		bm.height = 0.40
		body.mesh = bm
		body.material_override = brown_mat
		body.scale = Vector3(0.85, 0.65, 1.40)
		hawk.add_child(body)
		# Wide wings (long flat boxes)
		for sx in [-0.55, 0.55]:
			var wing: MeshInstance3D = MeshInstance3D.new()
			var wm: BoxMesh = BoxMesh.new()
			wm.size = Vector3(0.85, 0.04, 0.30)
			wing.mesh = wm
			wing.material_override = brown_mat
			wing.position = Vector3(sx, 0.04, 0)
			hawk.add_child(wing)
			# Slow soaring rock
			var twf: Tween = wing.create_tween().set_loops()
			twf.tween_property(wing, "rotation_degrees:z", 8.0 if sx < 0 else -8.0, 1.0)
			twf.tween_property(wing, "rotation_degrees:z", 0.0, 1.0)
		# Pivot rotation tween (slow circling)
		var trot: Tween = pivot.create_tween().set_loops()
		trot.tween_property(pivot, "rotation_degrees:y", i * 90.0 + 360.0, 14.0 + i * 0.6)
		trot.tween_property(pivot, "rotation_degrees:y", i * 90.0, 0.0)


static func _build_d7_falconer_npc(town: Node) -> void:
	## Epic-7 T52: falconer NPC — leather glove with a perched falcon.
	var npc_slots: Node3D = town.get_node_or_null("%NPCSlots") as Node3D
	if npc_slots == null:
		return
	var slot: Marker3D = Marker3D.new()
	slot.name = "FalconerSlot"
	slot.position = Vector3(D7_CENTER.x - 8.0, 0.0, 22.0)
	npc_slots.add_child(slot)
	var npc_scene: PackedScene = load("res://scenes/entities/npcs/VillagerR3.tscn") as PackedScene
	if npc_scene == null:
		return
	var npc: Node3D = npc_scene.instantiate() as Node3D
	npc.name = "Falconer"
	if "npc_name" in npc:
		npc.set("npc_name", "Skywatch")
	if "npc_id" in npc:
		npc.set("npc_id", "falconer_d7")
	slot.add_child(npc)
	# Brown leather tunic
	var tunic: MeshInstance3D = MeshInstance3D.new()
	var tm: BoxMesh = BoxMesh.new()
	tm.size = Vector3(0.65, 1.05, 0.40)
	tunic.mesh = tm
	var tunic_mat: StandardMaterial3D = StandardMaterial3D.new()
	tunic_mat.albedo_color = Color(0.45, 0.28, 0.12)
	tunic_mat.roughness = 0.65
	tunic.material_override = tunic_mat
	tunic.position = Vector3(0, 0.55, 0)
	npc.add_child(tunic)
	# Outstretched leather glove arm
	var arm: MeshInstance3D = MeshInstance3D.new()
	var am: BoxMesh = BoxMesh.new()
	am.size = Vector3(0.18, 0.55, 0.18)
	arm.mesh = am
	arm.material_override = tunic_mat
	arm.position = Vector3(0.40, 1.10, 0.30)
	arm.rotation_degrees = Vector3(60, 0, 0)
	npc.add_child(arm)
	# Perched falcon (small bird on glove)
	var brown_mat: StandardMaterial3D = StandardMaterial3D.new()
	brown_mat.albedo_color = Color(0.45, 0.28, 0.15)
	brown_mat.roughness = 0.85
	var falcon: MeshInstance3D = MeshInstance3D.new()
	var fm: SphereMesh = SphereMesh.new()
	fm.radius = 0.14
	fm.height = 0.24
	falcon.mesh = fm
	falcon.material_override = brown_mat
	falcon.position = Vector3(0.60, 1.40, 0.55)
	falcon.scale = Vector3(0.85, 1.20, 0.85)
	npc.add_child(falcon)


static func _build_d7_obelisk(geom: Node) -> void:
	## Epic-7 T53: tall narrow stone obelisk with carved glyphs on the front.
	var ob: Node3D = Node3D.new()
	ob.name = "Obelisk"
	ob.position = Vector3(D7_CENTER.x + 12.0, 0.0, 18.0)
	geom.add_child(ob)
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.55, 0.45, 0.30)
	stone_mat.emission_enabled = true
	stone_mat.emission = Color(0.55, 0.40, 0.20)
	stone_mat.emission_energy_multiplier = 0.18
	stone_mat.roughness = 0.92
	# Square base
	var base: MeshInstance3D = MeshInstance3D.new()
	var bm: BoxMesh = BoxMesh.new()
	bm.size = Vector3(1.85, 0.55, 1.85)
	base.mesh = bm
	base.material_override = stone_mat
	base.position = Vector3(0, 0.27, 0)
	ob.add_child(base)
	# Tall narrow shaft (tapered)
	var shaft: MeshInstance3D = MeshInstance3D.new()
	var sm: BoxMesh = BoxMesh.new()
	sm.size = Vector3(0.85, 6.85, 0.85)
	shaft.mesh = sm
	shaft.material_override = stone_mat
	shaft.position = Vector3(0, 3.95, 0)
	ob.add_child(shaft)
	# Pyramidal top (small prism)
	var top: MeshInstance3D = MeshInstance3D.new()
	var tm: PrismMesh = PrismMesh.new()
	tm.size = Vector3(0.85, 0.85, 0.85)
	top.mesh = tm
	top.material_override = stone_mat
	top.position = Vector3(0, 7.85, 0)
	ob.add_child(top)
	# 5 glowing rune carvings down the front face
	var rune_mat: StandardMaterial3D = StandardMaterial3D.new()
	rune_mat.albedo_color = Color(1.0, 0.65, 0.20)
	rune_mat.emission_enabled = true
	rune_mat.emission = Color(1.0, 0.65, 0.20)
	rune_mat.emission_energy_multiplier = 2.5
	rune_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for i in 5:
		var rune: MeshInstance3D = MeshInstance3D.new()
		var rmm: BoxMesh = BoxMesh.new()
		rmm.size = Vector3(0.30, 0.30, 0.04)
		rune.mesh = rmm
		rune.material_override = rune_mat
		rune.position = Vector3(0, 1.85 + i * 1.30, 0.45)
		ob.add_child(rune)
		# Pulse
		var tw: Tween = rune.create_tween().set_loops()
		tw.tween_interval(i * 0.20)
		tw.tween_property(rune, "scale:y", 1.20, 0.85)
		tw.tween_property(rune, "scale:y", 0.85, 0.85)
	# Aura light
	var light: OmniLight3D = OmniLight3D.new()
	light.light_color = Color(1.0, 0.85, 0.30)
	light.light_energy = 2.5
	light.omni_range = 7.0
	light.position = Vector3(0, 5.55, 0)
	ob.add_child(light)
	# Obelisk collision
	var sb: StaticBody3D = StaticBody3D.new()
	sb.position = Vector3(0, 4.20, 0)
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(1.10, 8.40, 1.10)
	cs.shape = cb
	sb.add_child(cs)
	ob.add_child(sb)


static func _build_d7_cave_paintings(geom: Node) -> void:
	## Epic-7 T54: cave painting wall — dark rock surface with primitive
	## colored handprints + animal silhouettes.
	var wall: Node3D = Node3D.new()
	wall.name = "CavePaintings"
	wall.position = Vector3(D7_CENTER.x + 22.0, 0.0, 12.0)
	geom.add_child(wall)
	var rock_mat: StandardMaterial3D = StandardMaterial3D.new()
	rock_mat.albedo_color = Color(0.30, 0.20, 0.10)
	rock_mat.roughness = 0.92
	# Wall slab
	var slab: MeshInstance3D = MeshInstance3D.new()
	var sm: BoxMesh = BoxMesh.new()
	sm.size = Vector3(4.85, 3.40, 0.40)
	slab.mesh = sm
	slab.material_override = rock_mat
	slab.position = Vector3(0, 1.70, -2.85)
	wall.add_child(slab)
	# Painting colors
	var paint_colors: Array = [
		Color(0.85, 0.20, 0.15),  # red ochre
		Color(0.95, 0.55, 0.20),  # orange
		Color(0.85, 0.75, 0.45),  # yellow ochre
		Color(0.20, 0.10, 0.05),  # dark
	]
	# 6 handprint sphere clusters
	for i in 6:
		for j in 5:
			var dot: MeshInstance3D = MeshInstance3D.new()
			var dm: SphereMesh = SphereMesh.new()
			dm.radius = 0.06 + randf() * 0.04
			dm.height = 0.10
			dot.mesh = dm
			var dot_mat: StandardMaterial3D = StandardMaterial3D.new()
			dot_mat.albedo_color = paint_colors[i % 4]
			dot_mat.emission_enabled = true
			dot_mat.emission = paint_colors[i % 4]
			dot_mat.emission_energy_multiplier = 0.85
			dot_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
			dot.material_override = dot_mat
			dot.position = Vector3(
				-2.0 + i * 0.85 + randf_range(-0.18, 0.18),
				0.85 + j * 0.40 + randf_range(-0.10, 0.10),
				-2.65
			)
			wall.add_child(dot)
	# 2 large animal silhouette boxes (running animal shapes)
	for i in 2:
		var animal: MeshInstance3D = MeshInstance3D.new()
		var am: BoxMesh = BoxMesh.new()
		am.size = Vector3(0.85, 0.55, 0.04)
		animal.mesh = am
		var animal_mat: StandardMaterial3D = StandardMaterial3D.new()
		animal_mat.albedo_color = Color(0.85, 0.30, 0.15)
		animal_mat.emission_enabled = true
		animal_mat.emission = Color(0.85, 0.30, 0.15)
		animal_mat.emission_energy_multiplier = 1.0
		animal_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		animal.material_override = animal_mat
		animal.position = Vector3(-1.0 + i * 2.0, 2.40, -2.65)
		wall.add_child(animal)
	# Wall collision
	var sb: StaticBody3D = StaticBody3D.new()
	sb.position = Vector3(0, 1.70, -2.85)
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(4.85, 3.40, 0.40)
	cs.shape = cb
	sb.add_child(cs)
	wall.add_child(sb)


static func _build_d7_shaman_npc(town: Node) -> void:
	## Epic-7 T55: mountain shaman NPC — feathered headdress + bone necklace
	## + held drum.
	var npc_slots: Node3D = town.get_node_or_null("%NPCSlots") as Node3D
	if npc_slots == null:
		return
	var slot: Marker3D = Marker3D.new()
	slot.name = "ShamanSlot"
	slot.position = Vector3(D7_CENTER.x + 22.0, 0.0, 14.0)
	npc_slots.add_child(slot)
	var npc_scene: PackedScene = load("res://scenes/entities/npcs/VillagerR3.tscn") as PackedScene
	if npc_scene == null:
		return
	var npc: Node3D = npc_scene.instantiate() as Node3D
	npc.name = "Shaman"
	if "npc_name" in npc:
		npc.set("npc_name", "Spiritcaller")
	if "npc_id" in npc:
		npc.set("npc_id", "shaman_d7")
	slot.add_child(npc)
	# Brown robe
	var robe: MeshInstance3D = MeshInstance3D.new()
	var rm: BoxMesh = BoxMesh.new()
	rm.size = Vector3(0.65, 1.20, 0.45)
	robe.mesh = rm
	var robe_mat: StandardMaterial3D = StandardMaterial3D.new()
	robe_mat.albedo_color = Color(0.45, 0.28, 0.12)
	robe_mat.roughness = 0.85
	robe.material_override = robe_mat
	robe.position = Vector3(0, 0.60, 0)
	npc.add_child(robe)
	# Feathered headdress (4 colored feather prisms)
	var feather_colors: Array = [
		Color(0.95, 0.20, 0.30),
		Color(0.95, 0.85, 0.20),
		Color(0.30, 0.65, 0.95),
		Color(0.30, 0.95, 0.55),
	]
	for i in 4:
		var feather: MeshInstance3D = MeshInstance3D.new()
		var fm: PrismMesh = PrismMesh.new()
		fm.size = Vector3(0.10, 0.40, 0.04)
		feather.mesh = fm
		var fmat: StandardMaterial3D = StandardMaterial3D.new()
		fmat.albedo_color = feather_colors[i]
		fmat.emission_enabled = true
		fmat.emission = feather_colors[i]
		fmat.emission_energy_multiplier = 0.85
		feather.material_override = fmat
		var ang: float = (TAU / 4.0) * i
		feather.position = Vector3(cos(ang) * 0.18, 1.85, sin(ang) * 0.18)
		feather.rotation_degrees = Vector3(0, ang * 60.0, -25.0)
		npc.add_child(feather)
	# Bone necklace (small white torus)
	var bone: MeshInstance3D = MeshInstance3D.new()
	var btm: TorusMesh = TorusMesh.new()
	btm.inner_radius = 0.18
	btm.outer_radius = 0.22
	bone.mesh = btm
	var bone_mat: StandardMaterial3D = StandardMaterial3D.new()
	bone_mat.albedo_color = Color(0.92, 0.92, 0.85)
	bone_mat.roughness = 0.65
	bone.material_override = bone_mat
	bone.position = Vector3(0, 1.10, 0.10)
	npc.add_child(bone)
	# Drum (small cylinder held in hand)
	var drum: MeshInstance3D = MeshInstance3D.new()
	var drm: CylinderMesh = CylinderMesh.new()
	drm.top_radius = 0.18
	drm.bottom_radius = 0.18
	drm.height = 0.18
	drum.mesh = drm
	var drum_mat: StandardMaterial3D = StandardMaterial3D.new()
	drum_mat.albedo_color = Color(0.55, 0.35, 0.18)
	drum_mat.roughness = 0.85
	drum.material_override = drum_mat
	drum.position = Vector3(0.40, 0.85, 0.20)
	drum.rotation_degrees = Vector3(0, 0, 90)
	npc.add_child(drum)


static func _build_d7_gate_ruin(geom: Node) -> void:
	## Epic-7 T56: ancient gate ruin — broken stone arch with one
	## collapsed pillar + scattered rubble.
	var ruin: Node3D = Node3D.new()
	ruin.name = "GateRuin"
	ruin.position = Vector3(D7_CENTER.x - 12.0, 0.0, -22.0)
	geom.add_child(ruin)
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.50, 0.40, 0.25)
	stone_mat.roughness = 0.92
	# Standing pillar
	var standing: MeshInstance3D = MeshInstance3D.new()
	var sm: BoxMesh = BoxMesh.new()
	sm.size = Vector3(0.85, 4.20, 0.85)
	standing.mesh = sm
	standing.material_override = stone_mat
	standing.position = Vector3(-1.85, 2.10, 0)
	ruin.add_child(standing)
	# Collapsed pillar (lying on its side)
	var fallen: MeshInstance3D = MeshInstance3D.new()
	var fm: BoxMesh = BoxMesh.new()
	fm.size = Vector3(0.85, 4.20, 0.85)
	fallen.mesh = fm
	fallen.material_override = stone_mat
	fallen.position = Vector3(1.85, 0.42, 0.85)
	fallen.rotation_degrees = Vector3(0, 0, 90)
	ruin.add_child(fallen)
	# Broken arch top fragment (small angled box)
	var arch_frag: MeshInstance3D = MeshInstance3D.new()
	var afm: BoxMesh = BoxMesh.new()
	afm.size = Vector3(2.0, 0.55, 0.85)
	arch_frag.mesh = afm
	arch_frag.material_override = stone_mat
	arch_frag.position = Vector3(-1.20, 4.20, 0)
	arch_frag.rotation_degrees = Vector3(0, 0, -25)
	ruin.add_child(arch_frag)
	# 5 scattered rubble blocks
	for i in 5:
		var rub: MeshInstance3D = MeshInstance3D.new()
		var rm: BoxMesh = BoxMesh.new()
		rm.size = Vector3(0.40 + randf() * 0.30, 0.30, 0.40 + randf() * 0.30)
		rub.mesh = rm
		rub.material_override = stone_mat
		rub.position = Vector3(
			randf_range(-2.5, 2.5),
			0.18,
			randf_range(-1.85, 1.85)
		)
		rub.rotation_degrees = Vector3(0, randf_range(0, 360), 0)
		ruin.add_child(rub)
	# Standing pillar collision
	var sb1: StaticBody3D = StaticBody3D.new()
	sb1.position = Vector3(-1.85, 2.10, 0)
	var cs1: CollisionShape3D = CollisionShape3D.new()
	var cb1: BoxShape3D = BoxShape3D.new()
	cb1.size = Vector3(0.85, 4.20, 0.85)
	cs1.shape = cb1
	sb1.add_child(cs1)
	ruin.add_child(sb1)
	# Fallen pillar collision (large box)
	var sb2: StaticBody3D = StaticBody3D.new()
	sb2.position = Vector3(1.85, 0.42, 0.85)
	var cs2: CollisionShape3D = CollisionShape3D.new()
	var cb2: BoxShape3D = BoxShape3D.new()
	cb2.size = Vector3(4.20, 0.85, 0.85)
	cs2.shape = cb2
	sb2.add_child(cs2)
	ruin.add_child(sb2)


static func _build_d7_d7_archaeologist_npc(town: Node) -> void:
	## Epic-7 T57: D7 archaeologist NPC — beige expedition hat + dusty
	## brown coat + small dig brush in hand.
	var npc_slots: Node3D = town.get_node_or_null("%NPCSlots") as Node3D
	if npc_slots == null:
		return
	var slot: Marker3D = Marker3D.new()
	slot.name = "D7ArchaeologistSlot"
	slot.position = Vector3(D7_CENTER.x - 10.0, 0.0, -22.0)
	npc_slots.add_child(slot)
	var npc_scene: PackedScene = load("res://scenes/entities/npcs/VillagerR3.tscn") as PackedScene
	if npc_scene == null:
		return
	var npc: Node3D = npc_scene.instantiate() as Node3D
	npc.name = "D7Archaeologist"
	if "npc_name" in npc:
		npc.set("npc_name", "Sandsift")
	if "npc_id" in npc:
		npc.set("npc_id", "archaeo_d7")
	slot.add_child(npc)
	# Dusty brown coat
	var coat: MeshInstance3D = MeshInstance3D.new()
	var cm: BoxMesh = BoxMesh.new()
	cm.size = Vector3(0.65, 1.05, 0.45)
	coat.mesh = cm
	var coat_mat: StandardMaterial3D = StandardMaterial3D.new()
	coat_mat.albedo_color = Color(0.55, 0.40, 0.20)
	coat_mat.roughness = 0.85
	coat.material_override = coat_mat
	coat.position = Vector3(0, 0.55, 0)
	npc.add_child(coat)
	# Beige expedition hat (wide brim disc + dome)
	var brim: MeshInstance3D = MeshInstance3D.new()
	var brm: CylinderMesh = CylinderMesh.new()
	brm.top_radius = 0.30
	brm.bottom_radius = 0.30
	brm.height = 0.04
	brim.mesh = brm
	var hat_mat: StandardMaterial3D = StandardMaterial3D.new()
	hat_mat.albedo_color = Color(0.85, 0.75, 0.55)
	hat_mat.roughness = 0.85
	brim.material_override = hat_mat
	brim.position = Vector3(0, 1.45, 0)
	npc.add_child(brim)
	var dome: MeshInstance3D = MeshInstance3D.new()
	var dmm: CylinderMesh = CylinderMesh.new()
	dmm.top_radius = 0.20
	dmm.bottom_radius = 0.20
	dmm.height = 0.20
	dome.mesh = dmm
	dome.material_override = hat_mat
	dome.position = Vector3(0, 1.55, 0)
	npc.add_child(dome)
	# Dig brush (small wooden cylinder + tan bristle tip)
	var brush_handle: MeshInstance3D = MeshInstance3D.new()
	var bhm: CylinderMesh = CylinderMesh.new()
	bhm.top_radius = 0.025
	bhm.bottom_radius = 0.025
	bhm.height = 0.20
	brush_handle.mesh = bhm
	var wood_mat: StandardMaterial3D = StandardMaterial3D.new()
	wood_mat.albedo_color = Color(0.45, 0.28, 0.12)
	wood_mat.roughness = 0.85
	brush_handle.material_override = wood_mat
	brush_handle.position = Vector3(0.40, 0.85, 0.20)
	npc.add_child(brush_handle)


static func _build_d7_ancient_tomb(geom: Node) -> void:
	## Epic-7 T58: ancient tomb — large rectangular stone sarcophagus
	## with carved lid + 2 short candles at the corners.
	var tomb: Node3D = Node3D.new()
	tomb.name = "AncientTomb"
	tomb.position = Vector3(D7_CENTER.x - 4.0, 0.0, -22.0)
	geom.add_child(tomb)
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.55, 0.45, 0.30)
	stone_mat.roughness = 0.92
	# Sarcophagus base
	var base: MeshInstance3D = MeshInstance3D.new()
	var bm: BoxMesh = BoxMesh.new()
	bm.size = Vector3(2.20, 1.10, 0.95)
	base.mesh = bm
	base.material_override = stone_mat
	base.position = Vector3(0, 0.55, 0)
	tomb.add_child(base)
	# Carved lid (slightly larger box on top)
	var lid: MeshInstance3D = MeshInstance3D.new()
	var lm: BoxMesh = BoxMesh.new()
	lm.size = Vector3(2.40, 0.30, 1.10)
	lid.mesh = lm
	var lid_mat: StandardMaterial3D = StandardMaterial3D.new()
	lid_mat.albedo_color = Color(0.65, 0.55, 0.35)
	lid_mat.emission_enabled = true
	lid_mat.emission = Color(0.55, 0.40, 0.15)
	lid_mat.emission_energy_multiplier = 0.30
	lid_mat.roughness = 0.85
	lid.material_override = lid_mat
	lid.position = Vector3(0, 1.25, 0)
	tomb.add_child(lid)
	# Engraved symbol on lid (small glowing rune)
	var rune: MeshInstance3D = MeshInstance3D.new()
	var rmm: BoxMesh = BoxMesh.new()
	rmm.size = Vector3(0.55, 0.04, 0.40)
	rune.mesh = rmm
	var rune_mat: StandardMaterial3D = StandardMaterial3D.new()
	rune_mat.albedo_color = Color(1.0, 0.65, 0.20)
	rune_mat.emission_enabled = true
	rune_mat.emission = Color(1.0, 0.65, 0.20)
	rune_mat.emission_energy_multiplier = 2.5
	rune_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	rune.material_override = rune_mat
	rune.position = Vector3(0, 1.42, 0)
	tomb.add_child(rune)
	# 2 corner candles
	for sx in [-1.0, 1.0]:
		var candle: MeshInstance3D = MeshInstance3D.new()
		var ccm: CylinderMesh = CylinderMesh.new()
		ccm.top_radius = 0.06
		ccm.bottom_radius = 0.06
		ccm.height = 0.45
		candle.mesh = ccm
		var wax_mat: StandardMaterial3D = StandardMaterial3D.new()
		wax_mat.albedo_color = Color(0.92, 0.85, 0.65)
		wax_mat.roughness = 0.85
		candle.material_override = wax_mat
		candle.position = Vector3(sx, 1.65, -0.40)
		tomb.add_child(candle)
		# Flame
		var flame: MeshInstance3D = MeshInstance3D.new()
		var fm: SphereMesh = SphereMesh.new()
		fm.radius = 0.06
		fm.height = 0.12
		flame.mesh = fm
		var flame_mat: StandardMaterial3D = StandardMaterial3D.new()
		flame_mat.albedo_color = Color(1.0, 0.65, 0.20)
		flame_mat.emission_enabled = true
		flame_mat.emission = Color(1.0, 0.55, 0.10)
		flame_mat.emission_energy_multiplier = 3.5
		flame_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		flame.material_override = flame_mat
		flame.position = Vector3(sx, 1.92, -0.40)
		tomb.add_child(flame)
		# Flicker
		var tw: Tween = flame.create_tween().set_loops()
		tw.tween_property(flame, "scale", Vector3(1.20, 1.30, 1.20), 0.20)
		tw.tween_property(flame, "scale", Vector3(0.85, 0.85, 0.85), 0.20)
	# Light
	var light: OmniLight3D = OmniLight3D.new()
	light.light_color = Color(1.0, 0.65, 0.30)
	light.light_energy = 1.85
	light.omni_range = 4.5
	light.position = Vector3(0, 1.85, 0)
	tomb.add_child(light)
	# Tomb collision
	var sb: StaticBody3D = StaticBody3D.new()
	sb.position = Vector3(0, 0.85, 0)
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(2.40, 1.85, 1.10)
	cs.shape = cb
	sb.add_child(cs)
	tomb.add_child(sb)


static func _build_d7_tomb_guardian(geom: Node) -> void:
	## Epic-7 T59: stone guardian statue beside the tomb — animal-headed
	## sentinel with crossed arms.
	var guard: Node3D = Node3D.new()
	guard.name = "TombGuardian"
	guard.position = Vector3(D7_CENTER.x - 1.0, 0.0, -22.0)
	geom.add_child(guard)
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.55, 0.45, 0.30)
	stone_mat.roughness = 0.92
	# Body
	var body: MeshInstance3D = MeshInstance3D.new()
	var bm: BoxMesh = BoxMesh.new()
	bm.size = Vector3(0.85, 1.85, 0.55)
	body.mesh = bm
	body.material_override = stone_mat
	body.position = Vector3(0, 1.20, 0)
	guard.add_child(body)
	# Animal head (sphere with snout box for jackal/wolf look)
	var head: MeshInstance3D = MeshInstance3D.new()
	var hm: SphereMesh = SphereMesh.new()
	hm.radius = 0.30
	hm.height = 0.55
	head.mesh = hm
	head.material_override = stone_mat
	head.position = Vector3(0, 2.40, 0)
	head.scale = Vector3(0.85, 1.0, 1.20)
	guard.add_child(head)
	# Snout
	var snout: MeshInstance3D = MeshInstance3D.new()
	var snm: BoxMesh = BoxMesh.new()
	snm.size = Vector3(0.18, 0.18, 0.30)
	snout.mesh = snm
	snout.material_override = stone_mat
	snout.position = Vector3(0, 2.30, 0.30)
	guard.add_child(snout)
	# 2 ears (small prisms)
	for sx in [-0.18, 0.18]:
		var ear: MeshInstance3D = MeshInstance3D.new()
		var em: PrismMesh = PrismMesh.new()
		em.size = Vector3(0.10, 0.20, 0.06)
		ear.mesh = em
		ear.material_override = stone_mat
		ear.position = Vector3(sx, 2.85, 0)
		guard.add_child(ear)
	# 2 crossed arms (thin horizontal boxes)
	for i in 2:
		var arm: MeshInstance3D = MeshInstance3D.new()
		var am: BoxMesh = BoxMesh.new()
		am.size = Vector3(0.65, 0.18, 0.18)
		arm.mesh = am
		arm.material_override = stone_mat
		arm.position = Vector3(0, 0.95, 0.30)
		arm.rotation_degrees = Vector3(0, 0, 12.0 if i == 0 else -12.0)
		guard.add_child(arm)
	# Glowing amber eyes
	var eye_mat: StandardMaterial3D = StandardMaterial3D.new()
	eye_mat.albedo_color = Color(1.0, 0.85, 0.30)
	eye_mat.emission_enabled = true
	eye_mat.emission = Color(1.0, 0.65, 0.20)
	eye_mat.emission_energy_multiplier = 3.5
	eye_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for ex in [-0.10, 0.10]:
		var eye: MeshInstance3D = MeshInstance3D.new()
		var em: SphereMesh = SphereMesh.new()
		em.radius = 0.05
		em.height = 0.10
		eye.mesh = em
		eye.material_override = eye_mat
		eye.position = Vector3(ex, 2.40, 0.32)
		guard.add_child(eye)
	# Body collision
	var sb: StaticBody3D = StaticBody3D.new()
	sb.position = Vector3(0, 1.42, 0)
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(0.85, 2.85, 0.55)
	cs.shape = cb
	sb.add_child(cs)
	guard.add_child(sb)


static func _build_d7_dust_motes(geom: Node) -> void:
	## Epic-7 T60: ambient dust motes drifting through the air — gentle
	## warm GPU particles giving the district atmospheric depth.
	var motes: GPUParticles3D = GPUParticles3D.new()
	motes.name = "DustMotes"
	motes.position = Vector3(D7_CENTER.x, 4.0, 0.0)
	motes.amount = 100
	motes.lifetime = 12.0
	motes.preprocess = 6.0
	motes.explosiveness = 0.0
	motes.randomness = 0.85
	motes.visibility_aabb = AABB(Vector3(-40, -4, -20), Vector3(80, 12, 40))
	var pm: ParticleProcessMaterial = ParticleProcessMaterial.new()
	pm.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	pm.emission_box_extents = Vector3(35, 4, 20)
	pm.direction = Vector3(0.20, 0.10, 0.10)
	pm.spread = 65.0
	pm.gravity = Vector3(0.05, -0.05, 0.02)
	pm.initial_velocity_min = 0.10
	pm.initial_velocity_max = 0.30
	pm.scale_min = 0.04
	pm.scale_max = 0.10
	pm.color = Color(0.95, 0.85, 0.55, 0.65)
	motes.process_material = pm
	var mote_mesh: SphereMesh = SphereMesh.new()
	mote_mesh.radius = 0.04
	mote_mesh.height = 0.08
	motes.draw_pass_1 = mote_mesh
	var mote_mat: StandardMaterial3D = StandardMaterial3D.new()
	mote_mat.albedo_color = Color(0.95, 0.85, 0.55)
	mote_mat.emission_enabled = true
	mote_mat.emission = Color(0.95, 0.75, 0.30)
	mote_mat.emission_energy_multiplier = 1.4
	mote_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mote_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mote_mesh.material = mote_mat
	geom.add_child(motes)


static func _build_d7_dragon_statue(geom: Node) -> void:
	## Epic-7 T61: stone dragon statue — long curved body sphere chain +
	## angular head + back ridge spikes + glowing eyes.
	var dragon: Node3D = Node3D.new()
	dragon.name = "DragonStatue"
	dragon.position = Vector3(D7_CENTER.x - 22.0, 0.0, -22.0)
	geom.add_child(dragon)
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.55, 0.45, 0.30)
	stone_mat.roughness = 0.92
	# Stone pedestal slab
	var ped: MeshInstance3D = MeshInstance3D.new()
	var pm: BoxMesh = BoxMesh.new()
	pm.size = Vector3(4.85, 0.30, 1.85)
	ped.mesh = pm
	ped.material_override = stone_mat
	ped.position = Vector3(0, 0.15, 0)
	dragon.add_child(ped)
	# Body sphere chain (5 spheres curving)
	for i in 5:
		var seg: MeshInstance3D = MeshInstance3D.new()
		var sm: SphereMesh = SphereMesh.new()
		sm.radius = 0.55 - i * 0.06
		sm.height = 0.95 - i * 0.10
		seg.mesh = sm
		seg.material_override = stone_mat
		seg.position = Vector3(-1.85 + i * 0.95, 0.85 + sin(i * 0.85) * 0.30, 0)
		dragon.add_child(seg)
	# Head (angular box at the front)
	var head: MeshInstance3D = MeshInstance3D.new()
	var hm: BoxMesh = BoxMesh.new()
	hm.size = Vector3(0.65, 0.55, 0.95)
	head.mesh = hm
	head.material_override = stone_mat
	head.position = Vector3(2.85, 1.10, 0)
	dragon.add_child(head)
	# 2 horns (small angled prisms)
	for sx in [-0.18, 0.18]:
		var horn: MeshInstance3D = MeshInstance3D.new()
		var hrm: PrismMesh = PrismMesh.new()
		hrm.size = Vector3(0.10, 0.40, 0.10)
		horn.mesh = hrm
		horn.material_override = stone_mat
		horn.position = Vector3(2.85 + sx, 1.55, 0)
		horn.rotation_degrees = Vector3(-25, 0, 0)
		dragon.add_child(horn)
	# Glowing amber eyes
	var eye_mat: StandardMaterial3D = StandardMaterial3D.new()
	eye_mat.albedo_color = Color(1.0, 0.65, 0.20)
	eye_mat.emission_enabled = true
	eye_mat.emission = Color(1.0, 0.65, 0.20)
	eye_mat.emission_energy_multiplier = 4.0
	eye_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for sx in [-0.18, 0.18]:
		var eye: MeshInstance3D = MeshInstance3D.new()
		var em: SphereMesh = SphereMesh.new()
		em.radius = 0.06
		em.height = 0.12
		eye.mesh = em
		eye.material_override = eye_mat
		eye.position = Vector3(2.85 + sx, 1.20, 0.45)
		dragon.add_child(eye)
	# 5 back spikes along the body
	for i in 5:
		var spike: MeshInstance3D = MeshInstance3D.new()
		var spm: PrismMesh = PrismMesh.new()
		spm.size = Vector3(0.12, 0.30, 0.12)
		spike.mesh = spm
		spike.material_override = stone_mat
		spike.position = Vector3(-1.85 + i * 0.95, 1.40 + sin(i * 0.85) * 0.30, 0)
		dragon.add_child(spike)
	# Pedestal collision
	var sb: StaticBody3D = StaticBody3D.new()
	sb.position = Vector3(0, 0.85, 0)
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(4.85, 1.85, 1.85)
	cs.shape = cb
	sb.add_child(cs)
	dragon.add_child(sb)


static func _build_d7_dragon_priest_npc(town: Node) -> void:
	## Epic-7 T62: dragon priest NPC — red and gold robe + horned crown.
	var npc_slots: Node3D = town.get_node_or_null("%NPCSlots") as Node3D
	if npc_slots == null:
		return
	var slot: Marker3D = Marker3D.new()
	slot.name = "DragonPriestSlot"
	slot.position = Vector3(D7_CENTER.x - 24.0, 0.0, -22.0)
	npc_slots.add_child(slot)
	var npc_scene: PackedScene = load("res://scenes/entities/npcs/VillagerR3.tscn") as PackedScene
	if npc_scene == null:
		return
	var npc: Node3D = npc_scene.instantiate() as Node3D
	npc.name = "DragonPriest"
	if "npc_name" in npc:
		npc.set("npc_name", "Wyrmkeeper")
	if "npc_id" in npc:
		npc.set("npc_id", "dragon_priest_d7")
	slot.add_child(npc)
	# Red robe
	var robe: MeshInstance3D = MeshInstance3D.new()
	var rm: BoxMesh = BoxMesh.new()
	rm.size = Vector3(0.65, 1.20, 0.45)
	robe.mesh = rm
	var robe_mat: StandardMaterial3D = StandardMaterial3D.new()
	robe_mat.albedo_color = Color(0.85, 0.20, 0.20)
	robe_mat.emission_enabled = true
	robe_mat.emission = Color(0.85, 0.20, 0.20)
	robe_mat.emission_energy_multiplier = 0.30
	robe_mat.roughness = 0.65
	robe.material_override = robe_mat
	robe.position = Vector3(0, 0.60, 0)
	npc.add_child(robe)
	# Gold trim line down center
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
	# Horned crown (2 prism horns on a band)
	var band: MeshInstance3D = MeshInstance3D.new()
	var bm: CylinderMesh = CylinderMesh.new()
	bm.top_radius = 0.22
	bm.bottom_radius = 0.22
	bm.height = 0.10
	band.mesh = bm
	var band_mat: StandardMaterial3D = StandardMaterial3D.new()
	band_mat.albedo_color = Color(0.20, 0.18, 0.10)
	band_mat.metallic = 0.55
	band.material_override = band_mat
	band.position = Vector3(0, 1.50, 0)
	npc.add_child(band)
	for sx in [-0.18, 0.18]:
		var horn: MeshInstance3D = MeshInstance3D.new()
		var hm: PrismMesh = PrismMesh.new()
		hm.size = Vector3(0.10, 0.30, 0.10)
		horn.mesh = hm
		horn.material_override = gold_mat
		horn.position = Vector3(sx, 1.65, 0)
		horn.rotation_degrees = Vector3(-15, 0, 0)
		npc.add_child(horn)


static func _build_d7_ceremonial_fire(geom: Node) -> void:
	## Epic-7 T63: large ceremonial fire pit — circular stone ring + tall
	## crackling flame + smoke + warm bright light.
	var fire: Node3D = Node3D.new()
	fire.name = "CeremonialFire"
	fire.position = Vector3(D7_CENTER.x - 18.0, 0.0, -22.0)
	geom.add_child(fire)
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.40, 0.35, 0.25)
	stone_mat.roughness = 0.92
	# Stone ring (8 stones)
	for i in 8:
		var ang: float = (TAU / 8.0) * i
		var stone: MeshInstance3D = MeshInstance3D.new()
		var sm: SphereMesh = SphereMesh.new()
		sm.radius = 0.30
		sm.height = 0.40
		stone.mesh = sm
		stone.material_override = stone_mat
		stone.position = Vector3(cos(ang) * 1.40, 0.18, sin(ang) * 1.40)
		stone.scale = Vector3(1.0, 0.55, 1.0)
		fire.add_child(stone)
	# Crossed logs
	var wood_mat: StandardMaterial3D = StandardMaterial3D.new()
	wood_mat.albedo_color = Color(0.30, 0.18, 0.10)
	wood_mat.roughness = 0.92
	for i in 4:
		var log_n: MeshInstance3D = MeshInstance3D.new()
		var lm: CylinderMesh = CylinderMesh.new()
		lm.top_radius = 0.12
		lm.bottom_radius = 0.12
		lm.height = 1.85
		log_n.mesh = lm
		log_n.material_override = wood_mat
		log_n.position = Vector3(0, 0.30, 0)
		log_n.rotation = Vector3(deg_to_rad(85), deg_to_rad(45 * i), 0)
		fire.add_child(log_n)
	# Tall crackling flame stack (4 spheres)
	var fire_mat: StandardMaterial3D = StandardMaterial3D.new()
	fire_mat.albedo_color = Color(1.0, 0.55, 0.10)
	fire_mat.emission_enabled = true
	fire_mat.emission = Color(1.0, 0.45, 0.05)
	fire_mat.emission_energy_multiplier = 4.0
	fire_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for i in 4:
		var flame: MeshInstance3D = MeshInstance3D.new()
		var fm: SphereMesh = SphereMesh.new()
		fm.radius = 0.40 - i * 0.06
		fm.height = 0.55 - i * 0.10
		flame.mesh = fm
		flame.material_override = fire_mat
		flame.position = Vector3(0, 0.85 + i * 0.45, 0)
		fire.add_child(flame)
		# Flicker
		var tw: Tween = flame.create_tween().set_loops()
		tw.tween_interval(i * 0.10)
		tw.tween_property(flame, "scale", Vector3(1.20, 1.30, 1.20), 0.20)
		tw.tween_property(flame, "scale", Vector3(0.85, 0.85, 0.85), 0.20)
	# GPU smoke
	var smoke: GPUParticles3D = GPUParticles3D.new()
	smoke.amount = 30
	smoke.lifetime = 3.5
	smoke.preprocess = 1.5
	smoke.position = Vector3(0, 2.40, 0)
	var pm: ParticleProcessMaterial = ParticleProcessMaterial.new()
	pm.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_POINT
	pm.direction = Vector3(0, 1, 0)
	pm.spread = 22.0
	pm.gravity = Vector3.ZERO
	pm.initial_velocity_min = 0.55
	pm.initial_velocity_max = 1.10
	pm.scale_min = 0.20
	pm.scale_max = 0.45
	pm.color = Color(0.55, 0.45, 0.30, 0.65)
	smoke.process_material = pm
	var sm_mesh: SphereMesh = SphereMesh.new()
	sm_mesh.radius = 0.20
	sm_mesh.height = 0.40
	smoke.draw_pass_1 = sm_mesh
	var sm_mat: StandardMaterial3D = StandardMaterial3D.new()
	sm_mat.albedo_color = Color(0.55, 0.45, 0.30, 0.55)
	sm_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	sm_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	sm_mesh.material = sm_mat
	fire.add_child(smoke)
	# Bright warm light
	var light: OmniLight3D = OmniLight3D.new()
	light.light_color = Color(1.0, 0.65, 0.20)
	light.light_energy = 4.0
	light.omni_range = 9.0
	light.position = Vector3(0, 1.30, 0)
	fire.add_child(light)
	# Light pulse
	var twl: Tween = light.create_tween().set_loops()
	twl.tween_property(light, "light_energy", 5.0, 0.30)
	twl.tween_property(light, "light_energy", 3.5, 0.30)


static func _build_d7_divination_table(geom: Node) -> void:
	## Epic-7 T64: low wooden table with 6 small "bone" sticks scattered
	## on top — divination spot.
	var table: Node3D = Node3D.new()
	table.name = "DivinationTable"
	table.position = Vector3(D7_CENTER.x - 14.0, 0.0, -22.0)
	geom.add_child(table)
	var wood_mat: StandardMaterial3D = StandardMaterial3D.new()
	wood_mat.albedo_color = Color(0.45, 0.28, 0.12)
	wood_mat.roughness = 0.85
	# Tabletop
	var top: MeshInstance3D = MeshInstance3D.new()
	var tm: BoxMesh = BoxMesh.new()
	tm.size = Vector3(1.40, 0.10, 1.10)
	top.mesh = tm
	top.material_override = wood_mat
	top.position = Vector3(0, 0.65, 0)
	table.add_child(top)
	# 4 legs
	for sx in [-0.55, 0.55]:
		for sz in [-0.40, 0.40]:
			var leg: MeshInstance3D = MeshInstance3D.new()
			var lm: BoxMesh = BoxMesh.new()
			lm.size = Vector3(0.10, 0.65, 0.10)
			leg.mesh = lm
			leg.material_override = wood_mat
			leg.position = Vector3(sx, 0.32, sz)
			table.add_child(leg)
	# 6 bone sticks
	var bone_mat: StandardMaterial3D = StandardMaterial3D.new()
	bone_mat.albedo_color = Color(0.95, 0.92, 0.82)
	bone_mat.emission_enabled = true
	bone_mat.emission = Color(0.95, 0.92, 0.82)
	bone_mat.emission_energy_multiplier = 0.45
	bone_mat.roughness = 0.65
	for i in 6:
		var bone: MeshInstance3D = MeshInstance3D.new()
		var bm: CylinderMesh = CylinderMesh.new()
		bm.top_radius = 0.025
		bm.bottom_radius = 0.025
		bm.height = 0.30
		bone.mesh = bm
		bone.material_override = bone_mat
		bone.position = Vector3(
			randf_range(-0.45, 0.45),
			0.74,
			randf_range(-0.30, 0.30)
		)
		bone.rotation_degrees = Vector3(0, randf_range(0, 360), 90)
		table.add_child(bone)
	# Table collision
	var sb: StaticBody3D = StaticBody3D.new()
	sb.position = Vector3(0, 0.42, 0)
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(1.40, 0.85, 1.10)
	cs.shape = cb
	sb.add_child(cs)
	table.add_child(sb)


static func _build_d7_d7_oracle_npc(town: Node) -> void:
	## Epic-7 T65: D7 oracle NPC at the divination table — purple robe +
	## third eye gem on forehead + held crystal ball.
	var npc_slots: Node3D = town.get_node_or_null("%NPCSlots") as Node3D
	if npc_slots == null:
		return
	var slot: Marker3D = Marker3D.new()
	slot.name = "D7OracleSlot"
	slot.position = Vector3(D7_CENTER.x - 13.0, 0.0, -22.0)
	npc_slots.add_child(slot)
	var npc_scene: PackedScene = load("res://scenes/entities/npcs/VillagerR3.tscn") as PackedScene
	if npc_scene == null:
		return
	var npc: Node3D = npc_scene.instantiate() as Node3D
	npc.name = "D7Oracle"
	if "npc_name" in npc:
		npc.set("npc_name", "Foresight")
	if "npc_id" in npc:
		npc.set("npc_id", "oracle_d7")
	slot.add_child(npc)
	# Purple robe
	var robe: MeshInstance3D = MeshInstance3D.new()
	var rm: BoxMesh = BoxMesh.new()
	rm.size = Vector3(0.65, 1.20, 0.45)
	robe.mesh = rm
	var robe_mat: StandardMaterial3D = StandardMaterial3D.new()
	robe_mat.albedo_color = Color(0.45, 0.20, 0.65)
	robe_mat.emission_enabled = true
	robe_mat.emission = Color(0.55, 0.30, 0.95)
	robe_mat.emission_energy_multiplier = 0.30
	robe.material_override = robe_mat
	robe.position = Vector3(0, 0.60, 0)
	npc.add_child(robe)
	# Third eye gem on forehead
	var gem: MeshInstance3D = MeshInstance3D.new()
	var gm: PrismMesh = PrismMesh.new()
	gm.size = Vector3(0.10, 0.18, 0.06)
	gem.mesh = gm
	var gem_mat: StandardMaterial3D = StandardMaterial3D.new()
	gem_mat.albedo_color = Color(0.95, 0.30, 0.85)
	gem_mat.emission_enabled = true
	gem_mat.emission = Color(0.95, 0.30, 0.85)
	gem_mat.emission_energy_multiplier = 4.0
	gem_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	gem.material_override = gem_mat
	gem.position = Vector3(0, 1.50, 0.21)
	npc.add_child(gem)
	# Crystal ball held in hand
	var ball: MeshInstance3D = MeshInstance3D.new()
	var bm: SphereMesh = SphereMesh.new()
	bm.radius = 0.12
	bm.height = 0.22
	ball.mesh = bm
	var ball_mat: StandardMaterial3D = StandardMaterial3D.new()
	ball_mat.albedo_color = Color(0.85, 0.95, 1.0, 0.65)
	ball_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	ball_mat.emission_enabled = true
	ball_mat.emission = Color(0.55, 0.85, 1.0)
	ball_mat.emission_energy_multiplier = 2.5
	ball_mat.metallic = 0.55
	ball_mat.roughness = 0.05
	ball.material_override = ball_mat
	ball.position = Vector3(0.40, 0.85, 0.20)
	npc.add_child(ball)
	# Pulse the ball
	var tw: Tween = ball.create_tween().set_loops()
	tw.tween_property(ball, "scale", Vector3.ONE * 1.20, 1.4)
	tw.tween_property(ball, "scale", Vector3.ONE * 0.85, 1.4)


static func _build_d7_arched_bridge(geom: Node) -> void:
	## Epic-7 T66: large stone bridge with curved arch span — wide deck +
	## 2 arched supports underneath + decorative railings.
	var bridge: Node3D = Node3D.new()
	bridge.name = "ArchedStoneBridge"
	bridge.position = Vector3(D7_CENTER.x + 6.0, 0.0, 12.0)
	geom.add_child(bridge)
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.55, 0.45, 0.30)
	stone_mat.roughness = 0.92
	# Wide deck (long box)
	var deck: MeshInstance3D = MeshInstance3D.new()
	var dm: BoxMesh = BoxMesh.new()
	dm.size = Vector3(9.50, 0.40, 3.20)
	deck.mesh = dm
	deck.material_override = stone_mat
	deck.position = Vector3(0, 1.10, 0)
	bridge.add_child(deck)
	# 2 arched supports underneath (half torus)
	for sx in [-2.40, 2.40]:
		var arch: MeshInstance3D = MeshInstance3D.new()
		var atm: TorusMesh = TorusMesh.new()
		atm.inner_radius = 1.40
		atm.outer_radius = 1.55
		arch.mesh = atm
		arch.material_override = stone_mat
		arch.position = Vector3(sx, 0.55, 0)
		arch.rotation_degrees = Vector3(0, 0, 0)
		arch.scale = Vector3(1.0, 1.0, 0.40)
		bridge.add_child(arch)
	# 2 stone side railings
	for sz in [-1.40, 1.40]:
		var rail: MeshInstance3D = MeshInstance3D.new()
		var rm: BoxMesh = BoxMesh.new()
		rm.size = Vector3(9.50, 0.65, 0.20)
		rail.mesh = rm
		rail.material_override = stone_mat
		rail.position = Vector3(0, 1.65, sz)
		bridge.add_child(rail)
	# 8 small balusters along each rail
	for sz in [-1.40, 1.40]:
		for i in 8:
			var bal: MeshInstance3D = MeshInstance3D.new()
			var bm: BoxMesh = BoxMesh.new()
			bm.size = Vector3(0.18, 0.65, 0.18)
			bal.mesh = bm
			bal.material_override = stone_mat
			bal.position = Vector3(-4.20 + i * 1.20, 1.65, sz)
			bridge.add_child(bal)
	# Deck collision
	var sb: StaticBody3D = StaticBody3D.new()
	sb.position = Vector3(0, 1.30, 0)
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(9.50, 0.40, 3.20)
	cs.shape = cb
	sb.add_child(cs)
	bridge.add_child(sb)
	# Rail collisions
	for sz in [-1.40, 1.40]:
		var rsb: StaticBody3D = StaticBody3D.new()
		rsb.position = Vector3(0, 1.65, sz)
		var rcs: CollisionShape3D = CollisionShape3D.new()
		var rcb: BoxShape3D = BoxShape3D.new()
		rcb.size = Vector3(9.50, 0.65, 0.20)
		rcs.shape = rcb
		rsb.add_child(rcs)
		bridge.add_child(rsb)


static func _build_d7_yaks(geom: Node) -> void:
	## Epic-7 T67: 3 mountain yak creatures — large dark furry bodies +
	## curved horns + slow grazing tween.
	var herd: Node3D = Node3D.new()
	herd.name = "Yaks"
	herd.position = Vector3(D7_CENTER.x + 16.0, 0.0, -22.0)
	geom.add_child(herd)
	var fur_mat: StandardMaterial3D = StandardMaterial3D.new()
	fur_mat.albedo_color = Color(0.20, 0.15, 0.10)
	fur_mat.roughness = 0.95
	var horn_mat: StandardMaterial3D = StandardMaterial3D.new()
	horn_mat.albedo_color = Color(0.85, 0.75, 0.55)
	horn_mat.roughness = 0.65
	var positions: Array = [
		Vector3( 0.0, 0,  0.0),
		Vector3( 2.85, 0,  1.40),
		Vector3(-2.40, 0,  0.85),
	]
	for p in positions:
		var yak: Node3D = Node3D.new()
		yak.position = p
		herd.add_child(yak)
		# Body (large rounded sphere)
		var body: MeshInstance3D = MeshInstance3D.new()
		var bm: SphereMesh = SphereMesh.new()
		bm.radius = 0.55
		bm.height = 0.95
		body.mesh = bm
		body.material_override = fur_mat
		body.position = Vector3(0, 0.85, 0)
		body.scale = Vector3(1.0, 0.95, 1.55)
		yak.add_child(body)
		# Long shaggy fur skirt (lower box)
		var skirt: MeshInstance3D = MeshInstance3D.new()
		var skm: BoxMesh = BoxMesh.new()
		skm.size = Vector3(1.10, 0.55, 1.65)
		skirt.mesh = skm
		skirt.material_override = fur_mat
		skirt.position = Vector3(0, 0.30, 0)
		yak.add_child(skirt)
		# Head
		var head: MeshInstance3D = MeshInstance3D.new()
		var hm: SphereMesh = SphereMesh.new()
		hm.radius = 0.30
		hm.height = 0.55
		head.mesh = hm
		head.material_override = fur_mat
		head.position = Vector3(0, 0.95, 0.95)
		yak.add_child(head)
		# 2 long curved horns
		for sx in [-0.20, 0.20]:
			var horn: MeshInstance3D = MeshInstance3D.new()
			var hrm: PrismMesh = PrismMesh.new()
			hrm.size = Vector3(0.10, 0.55, 0.10)
			horn.mesh = hrm
			horn.material_override = horn_mat
			horn.position = Vector3(sx, 1.30, 0.85)
			horn.rotation_degrees = Vector3(0, 0, sx * 75.0)
			yak.add_child(horn)
		# 4 short legs
		for lx in [-0.30, 0.30]:
			for lz in [-0.55, 0.55]:
				var leg: MeshInstance3D = MeshInstance3D.new()
				var lm: CylinderMesh = CylinderMesh.new()
				lm.top_radius = 0.10
				lm.bottom_radius = 0.10
				lm.height = 0.55
				leg.mesh = lm
				leg.material_override = fur_mat
				leg.position = Vector3(lx, 0.27, lz)
				yak.add_child(leg)
		# Slow head grazing bob
		var tw: Tween = head.create_tween().set_loops()
		tw.tween_property(head, "position:y", 0.55, 1.4 + randf() * 0.4)
		tw.tween_property(head, "position:y", 0.95, 1.4 + randf() * 0.4)
		# Body collision
		var sb: StaticBody3D = StaticBody3D.new()
		sb.position = Vector3(0, 0.85, 0)
		var cs: CollisionShape3D = CollisionShape3D.new()
		var cb: BoxShape3D = BoxShape3D.new()
		cb.size = Vector3(1.40, 1.40, 1.85)
		cs.shape = cb
		sb.add_child(cs)
		yak.add_child(sb)


static func _build_d7_yak_herder_npc(town: Node) -> void:
	## Epic-7 T68: yak herder NPC — heavy fur cloak + tall shepherd's
	## crook + warm yellow scarf.
	var npc_slots: Node3D = town.get_node_or_null("%NPCSlots") as Node3D
	if npc_slots == null:
		return
	var slot: Marker3D = Marker3D.new()
	slot.name = "YakHerderSlot"
	slot.position = Vector3(D7_CENTER.x + 12.0, 0.0, -22.0)
	npc_slots.add_child(slot)
	var npc_scene: PackedScene = load("res://scenes/entities/npcs/VillagerR3.tscn") as PackedScene
	if npc_scene == null:
		return
	var npc: Node3D = npc_scene.instantiate() as Node3D
	npc.name = "YakHerder"
	if "npc_name" in npc:
		npc.set("npc_name", "Highvalley")
	if "npc_id" in npc:
		npc.set("npc_id", "yak_herder_d7")
	slot.add_child(npc)
	# Fur cloak
	var cloak: MeshInstance3D = MeshInstance3D.new()
	var cm: BoxMesh = BoxMesh.new()
	cm.size = Vector3(0.85, 1.30, 0.55)
	cloak.mesh = cm
	var cloak_mat: StandardMaterial3D = StandardMaterial3D.new()
	cloak_mat.albedo_color = Color(0.40, 0.30, 0.18)
	cloak_mat.roughness = 0.95
	cloak.material_override = cloak_mat
	cloak.position = Vector3(0, 0.65, 0)
	npc.add_child(cloak)
	# Yellow scarf
	var scarf: MeshInstance3D = MeshInstance3D.new()
	var sm: BoxMesh = BoxMesh.new()
	sm.size = Vector3(0.65, 0.10, 0.30)
	scarf.mesh = sm
	var scarf_mat: StandardMaterial3D = StandardMaterial3D.new()
	scarf_mat.albedo_color = Color(0.95, 0.85, 0.20)
	scarf_mat.emission_enabled = true
	scarf_mat.emission = Color(0.95, 0.85, 0.20)
	scarf_mat.emission_energy_multiplier = 0.45
	scarf.material_override = scarf_mat
	scarf.position = Vector3(0, 1.30, 0)
	npc.add_child(scarf)
	# Tall shepherd's crook
	var wood_mat: StandardMaterial3D = StandardMaterial3D.new()
	wood_mat.albedo_color = Color(0.40, 0.25, 0.10)
	wood_mat.roughness = 0.85
	var staff: MeshInstance3D = MeshInstance3D.new()
	var stm: CylinderMesh = CylinderMesh.new()
	stm.top_radius = 0.04
	stm.bottom_radius = 0.05
	stm.height = 1.85
	staff.mesh = stm
	staff.material_override = wood_mat
	staff.position = Vector3(0.45, 0.92, 0)
	npc.add_child(staff)
	# Crook curl (small torus)
	var curl: MeshInstance3D = MeshInstance3D.new()
	var ctm: TorusMesh = TorusMesh.new()
	ctm.inner_radius = 0.13
	ctm.outer_radius = 0.18
	curl.mesh = ctm
	curl.material_override = wood_mat
	curl.position = Vector3(0.45, 1.92, 0)
	curl.rotation_degrees = Vector3(90, 0, 0)
	npc.add_child(curl)


static func _build_d7_hot_spring_d7(geom: Node) -> void:
	## Epic-7 T69: D7 hot spring — round natural pool with stone-rim +
	## warm green water + steam particles.
	var spring: Node3D = Node3D.new()
	spring.name = "HotSpringD7"
	spring.position = Vector3(D7_CENTER.x + 22.0, 0.0, 22.0)
	geom.add_child(spring)
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.45, 0.35, 0.25)
	stone_mat.roughness = 0.92
	# Stone rim
	var rim: MeshInstance3D = MeshInstance3D.new()
	var rm: TorusMesh = TorusMesh.new()
	rm.inner_radius = 1.85
	rm.outer_radius = 2.20
	rim.mesh = rm
	rim.material_override = stone_mat
	rim.position = Vector3(0, 0.30, 0)
	spring.add_child(rim)
	# Warm water disc
	var water: MeshInstance3D = MeshInstance3D.new()
	var wm: CylinderMesh = CylinderMesh.new()
	wm.top_radius = 1.85
	wm.bottom_radius = 1.85
	wm.height = 0.06
	water.mesh = wm
	var water_mat: StandardMaterial3D = StandardMaterial3D.new()
	water_mat.albedo_color = Color(0.30, 0.85, 0.55, 0.85)
	water_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	water_mat.emission_enabled = true
	water_mat.emission = Color(0.30, 0.95, 0.65)
	water_mat.emission_energy_multiplier = 0.85
	water_mat.metallic = 0.30
	water_mat.roughness = 0.05
	water.material_override = water_mat
	water.position = Vector3(0, 0.30, 0)
	spring.add_child(water)
	# Bob
	var tw: Tween = water.create_tween().set_loops()
	tw.tween_property(water, "position:y", 0.34, 1.5)
	tw.tween_property(water, "position:y", 0.30, 1.5)
	# Steam particles
	var steam: GPUParticles3D = GPUParticles3D.new()
	steam.amount = 35
	steam.lifetime = 3.0
	steam.preprocess = 1.5
	steam.position = Vector3(0, 0.45, 0)
	var pm: ParticleProcessMaterial = ParticleProcessMaterial.new()
	pm.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	pm.emission_box_extents = Vector3(1.85, 0.10, 1.85)
	pm.direction = Vector3(0.10, 1, 0.10)
	pm.spread = 22.0
	pm.gravity = Vector3(0, 0.55, 0)
	pm.initial_velocity_min = 0.30
	pm.initial_velocity_max = 0.65
	pm.scale_min = 0.30
	pm.scale_max = 0.65
	pm.color = Color(0.95, 0.95, 1.0, 0.55)
	steam.process_material = pm
	var sm_mesh: SphereMesh = SphereMesh.new()
	sm_mesh.radius = 0.30
	sm_mesh.height = 0.55
	steam.draw_pass_1 = sm_mesh
	var sm_mat: StandardMaterial3D = StandardMaterial3D.new()
	sm_mat.albedo_color = Color(0.95, 0.95, 1.0, 0.45)
	sm_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	sm_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	sm_mesh.material = sm_mat
	spring.add_child(steam)
	# Warm light
	var light: OmniLight3D = OmniLight3D.new()
	light.light_color = Color(0.85, 0.95, 0.70)
	light.light_energy = 2.0
	light.omni_range = 5.5
	light.position = Vector3(0, 0.85, 0)
	spring.add_child(light)
	# Rim collision
	var sb: StaticBody3D = StaticBody3D.new()
	sb.position = Vector3(0, 0.30, 0)
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cap: CylinderShape3D = CylinderShape3D.new()
	cap.radius = 2.20
	cap.height = 0.55
	cs.shape = cap
	sb.add_child(cs)
	spring.add_child(sb)


static func _build_d7_bathing_monk_npc(town: Node) -> void:
	## Epic-7 T70: bathing monk NPC near the spring — wrapped in towel,
	## peaceful expression.
	var npc_slots: Node3D = town.get_node_or_null("%NPCSlots") as Node3D
	if npc_slots == null:
		return
	var slot: Marker3D = Marker3D.new()
	slot.name = "BathingMonkSlot"
	slot.position = Vector3(D7_CENTER.x + 24.0, 0.0, 22.0)
	npc_slots.add_child(slot)
	var npc_scene: PackedScene = load("res://scenes/entities/npcs/VillagerR3.tscn") as PackedScene
	if npc_scene == null:
		return
	var npc: Node3D = npc_scene.instantiate() as Node3D
	npc.name = "BathingMonk"
	if "npc_name" in npc:
		npc.set("npc_name", "Hotspring")
	if "npc_id" in npc:
		npc.set("npc_id", "bathing_monk_d7")
	slot.add_child(npc)
	# White towel wrap
	var towel: MeshInstance3D = MeshInstance3D.new()
	var tm: BoxMesh = BoxMesh.new()
	tm.size = Vector3(0.65, 0.85, 0.45)
	towel.mesh = tm
	var towel_mat: StandardMaterial3D = StandardMaterial3D.new()
	towel_mat.albedo_color = Color(0.95, 0.92, 0.85)
	towel_mat.roughness = 0.85
	towel.material_override = towel_mat
	towel.position = Vector3(0, 0.55, 0)
	npc.add_child(towel)
	# Bald head
	var dome: MeshInstance3D = MeshInstance3D.new()
	var dm: SphereMesh = SphereMesh.new()
	dm.radius = 0.20
	dm.height = 0.36
	dome.mesh = dm
	var skin_mat: StandardMaterial3D = StandardMaterial3D.new()
	skin_mat.albedo_color = Color(0.95, 0.85, 0.65)
	skin_mat.roughness = 0.65
	dome.material_override = skin_mat
	dome.position = Vector3(0, 1.30, 0)
	npc.add_child(dome)


static func _build_d7_wishing_well(geom: Node) -> void:
	## Epic-7 T71: stone wishing well — round stone base + 2 wooden uprights +
	## sloped roof + a bucket dangling from a rope.
	var well: Node3D = Node3D.new()
	well.name = "WishingWell"
	well.position = Vector3(D7_CENTER.x + 16.0, 0.0, 22.0)
	geom.add_child(well)
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.55, 0.45, 0.30)
	stone_mat.roughness = 0.92
	var wood_mat: StandardMaterial3D = StandardMaterial3D.new()
	wood_mat.albedo_color = Color(0.45, 0.28, 0.12)
	wood_mat.roughness = 0.85
	# Round stone base
	var base: MeshInstance3D = MeshInstance3D.new()
	var bm: CylinderMesh = CylinderMesh.new()
	bm.top_radius = 0.85
	bm.bottom_radius = 1.0
	bm.height = 0.85
	base.mesh = bm
	base.material_override = stone_mat
	base.position = Vector3(0, 0.42, 0)
	well.add_child(base)
	# Dark water at bottom
	var water: MeshInstance3D = MeshInstance3D.new()
	var wm: CylinderMesh = CylinderMesh.new()
	wm.top_radius = 0.65
	wm.bottom_radius = 0.65
	wm.height = 0.04
	water.mesh = wm
	var water_mat: StandardMaterial3D = StandardMaterial3D.new()
	water_mat.albedo_color = Color(0.05, 0.10, 0.20)
	water_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	water.material_override = water_mat
	water.position = Vector3(0, 0.85, 0)
	well.add_child(water)
	# 2 wooden uprights
	for sx in [-0.85, 0.85]:
		var post: MeshInstance3D = MeshInstance3D.new()
		var pm: BoxMesh = BoxMesh.new()
		pm.size = Vector3(0.18, 1.85, 0.18)
		post.mesh = pm
		post.material_override = wood_mat
		post.position = Vector3(sx, 1.85, 0)
		well.add_child(post)
	# Crossbar at top
	var bar: MeshInstance3D = MeshInstance3D.new()
	var brm: CylinderMesh = CylinderMesh.new()
	brm.top_radius = 0.06
	brm.bottom_radius = 0.06
	brm.height = 1.85
	bar.mesh = brm
	bar.material_override = wood_mat
	bar.position = Vector3(0, 2.85, 0)
	bar.rotation_degrees = Vector3(0, 0, 90)
	well.add_child(bar)
	# Sloped roof
	var roof: MeshInstance3D = MeshInstance3D.new()
	var rm: PrismMesh = PrismMesh.new()
	rm.size = Vector3(2.20, 0.55, 1.10)
	roof.mesh = rm
	var roof_mat: StandardMaterial3D = StandardMaterial3D.new()
	roof_mat.albedo_color = Color(0.40, 0.20, 0.15)
	roof.material_override = roof_mat
	roof.position = Vector3(0, 3.30, 0)
	well.add_child(roof)
	# Rope + bucket
	var rope: MeshInstance3D = MeshInstance3D.new()
	var rmm: CylinderMesh = CylinderMesh.new()
	rmm.top_radius = 0.025
	rmm.bottom_radius = 0.025
	rmm.height = 1.40
	rope.mesh = rmm
	var rope_mat: StandardMaterial3D = StandardMaterial3D.new()
	rope_mat.albedo_color = Color(0.55, 0.40, 0.20)
	rope.material_override = rope_mat
	rope.position = Vector3(0.30, 2.10, 0)
	well.add_child(rope)
	var bucket: MeshInstance3D = MeshInstance3D.new()
	var bm2: CylinderMesh = CylinderMesh.new()
	bm2.top_radius = 0.18
	bm2.bottom_radius = 0.14
	bm2.height = 0.20
	bucket.mesh = bm2
	bucket.material_override = wood_mat
	bucket.position = Vector3(0.30, 1.30, 0)
	well.add_child(bucket)
	# Well collision
	var sb: StaticBody3D = StaticBody3D.new()
	sb.position = Vector3(0, 0.85, 0)
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cap: CylinderShape3D = CylinderShape3D.new()
	cap.radius = 1.0
	cap.height = 1.85
	cs.shape = cap
	sb.add_child(cs)
	well.add_child(sb)


static func _build_d7_blacksmith_forge(geom: Node) -> void:
	## Epic-7 T72: blacksmith forge — stone fire pit + anvil + bellows.
	var forge: Node3D = Node3D.new()
	forge.name = "BlacksmithForge"
	forge.position = Vector3(D7_CENTER.x + 24.0, 0.0, -2.0)
	geom.add_child(forge)
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.40, 0.30, 0.20)
	stone_mat.roughness = 0.92
	var dark_metal: StandardMaterial3D = StandardMaterial3D.new()
	dark_metal.albedo_color = Color(0.20, 0.18, 0.20)
	dark_metal.metallic = 0.85
	dark_metal.roughness = 0.30
	# Forge box
	var fbox: MeshInstance3D = MeshInstance3D.new()
	var fbm: BoxMesh = BoxMesh.new()
	fbm.size = Vector3(1.85, 1.10, 1.85)
	fbox.mesh = fbm
	fbox.material_override = stone_mat
	fbox.position = Vector3(0, 0.55, 0)
	forge.add_child(fbox)
	# Hot fire core
	var fire: MeshInstance3D = MeshInstance3D.new()
	var fm: SphereMesh = SphereMesh.new()
	fm.radius = 0.45
	fm.height = 0.55
	fire.mesh = fm
	var fire_mat: StandardMaterial3D = StandardMaterial3D.new()
	fire_mat.albedo_color = Color(1.0, 0.55, 0.10)
	fire_mat.emission_enabled = true
	fire_mat.emission = Color(1.0, 0.45, 0.05)
	fire_mat.emission_energy_multiplier = 4.5
	fire_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	fire.material_override = fire_mat
	fire.position = Vector3(0, 1.40, 0)
	forge.add_child(fire)
	var tw: Tween = fire.create_tween().set_loops()
	tw.tween_property(fire, "scale", Vector3(1.20, 1.30, 1.20), 0.20)
	tw.tween_property(fire, "scale", Vector3(0.85, 0.85, 0.85), 0.20)
	# Hot light
	var light: OmniLight3D = OmniLight3D.new()
	light.light_color = Color(1.0, 0.55, 0.10)
	light.light_energy = 4.0
	light.omni_range = 7.0
	light.position = Vector3(0, 1.40, 0)
	forge.add_child(light)
	# Anvil
	var anvil_block: MeshInstance3D = MeshInstance3D.new()
	var abm: BoxMesh = BoxMesh.new()
	abm.size = Vector3(0.55, 0.85, 0.40)
	anvil_block.mesh = abm
	anvil_block.material_override = dark_metal
	anvil_block.position = Vector3(2.40, 0.42, 0)
	forge.add_child(anvil_block)
	var anvil_top: MeshInstance3D = MeshInstance3D.new()
	var atm: BoxMesh = BoxMesh.new()
	atm.size = Vector3(0.85, 0.20, 0.55)
	anvil_top.mesh = atm
	anvil_top.material_override = dark_metal
	anvil_top.position = Vector3(2.40, 0.95, 0)
	forge.add_child(anvil_top)
	# Bellows
	var bellows: MeshInstance3D = MeshInstance3D.new()
	var bem: SphereMesh = SphereMesh.new()
	bem.radius = 0.55
	bem.height = 0.55
	bellows.mesh = bem
	var bellows_mat: StandardMaterial3D = StandardMaterial3D.new()
	bellows_mat.albedo_color = Color(0.45, 0.28, 0.12)
	bellows_mat.roughness = 0.85
	bellows.material_override = bellows_mat
	bellows.position = Vector3(-2.0, 0.55, 0)
	bellows.scale = Vector3(0.85, 0.65, 1.40)
	forge.add_child(bellows)
	var twp: Tween = bellows.create_tween().set_loops()
	twp.tween_property(bellows, "scale", Vector3(0.85, 0.45, 1.40), 0.55)
	twp.tween_property(bellows, "scale", Vector3(0.85, 0.65, 1.40), 0.55)
	# Forge collision
	var sb: StaticBody3D = StaticBody3D.new()
	sb.position = Vector3(0, 0.55, 0)
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(1.85, 1.10, 1.85)
	cs.shape = cb
	sb.add_child(cs)
	forge.add_child(sb)
	# Anvil collision
	var asb: StaticBody3D = StaticBody3D.new()
	asb.position = Vector3(2.40, 0.55, 0)
	var acs: CollisionShape3D = CollisionShape3D.new()
	var acb: BoxShape3D = BoxShape3D.new()
	acb.size = Vector3(0.85, 1.10, 0.55)
	acs.shape = acb
	asb.add_child(acs)
	forge.add_child(asb)


static func _build_d7_blacksmith_npc(town: Node) -> void:
	## Epic-7 T73: D7 blacksmith NPC — leather apron + held hammer.
	var npc_slots: Node3D = town.get_node_or_null("%NPCSlots") as Node3D
	if npc_slots == null:
		return
	var slot: Marker3D = Marker3D.new()
	slot.name = "D7BlacksmithSlot"
	slot.position = Vector3(D7_CENTER.x + 23.0, 0.0, -2.0)
	npc_slots.add_child(slot)
	var npc_scene: PackedScene = load("res://scenes/entities/npcs/VillagerR3.tscn") as PackedScene
	if npc_scene == null:
		return
	var npc: Node3D = npc_scene.instantiate() as Node3D
	npc.name = "D7Blacksmith"
	if "npc_name" in npc:
		npc.set("npc_name", "Forgewright")
	if "npc_id" in npc:
		npc.set("npc_id", "blacksmith_d7")
	slot.add_child(npc)
	# Leather apron
	var apron: MeshInstance3D = MeshInstance3D.new()
	var am: BoxMesh = BoxMesh.new()
	am.size = Vector3(0.55, 0.95, 0.06)
	apron.mesh = am
	var apron_mat: StandardMaterial3D = StandardMaterial3D.new()
	apron_mat.albedo_color = Color(0.30, 0.18, 0.10)
	apron_mat.metallic = 0.30
	apron_mat.roughness = 0.65
	apron.material_override = apron_mat
	apron.position = Vector3(0, 0.55, 0.22)
	npc.add_child(apron)
	# Held hammer
	var wood_mat: StandardMaterial3D = StandardMaterial3D.new()
	wood_mat.albedo_color = Color(0.45, 0.28, 0.12)
	wood_mat.roughness = 0.85
	var handle: MeshInstance3D = MeshInstance3D.new()
	var hm: CylinderMesh = CylinderMesh.new()
	hm.top_radius = 0.04
	hm.bottom_radius = 0.05
	hm.height = 0.55
	handle.mesh = hm
	handle.material_override = wood_mat
	handle.position = Vector3(0.40, 0.85, 0.20)
	npc.add_child(handle)
	var head: MeshInstance3D = MeshInstance3D.new()
	var hdm: BoxMesh = BoxMesh.new()
	hdm.size = Vector3(0.18, 0.18, 0.30)
	head.mesh = hdm
	var metal_mat: StandardMaterial3D = StandardMaterial3D.new()
	metal_mat.albedo_color = Color(0.30, 0.30, 0.40)
	metal_mat.metallic = 0.85
	metal_mat.roughness = 0.30
	head.material_override = metal_mat
	head.position = Vector3(0.40, 1.10, 0.20)
	npc.add_child(head)


static func _build_d7_weapon_display(geom: Node) -> void:
	## Epic-7 T74: crafted weapon display rack — wood frame with 5 weapons.
	var disp: Node3D = Node3D.new()
	disp.name = "WeaponDisplay"
	disp.position = Vector3(D7_CENTER.x + 28.0, 0.0, -2.0)
	geom.add_child(disp)
	var wood_mat: StandardMaterial3D = StandardMaterial3D.new()
	wood_mat.albedo_color = Color(0.45, 0.28, 0.12)
	wood_mat.roughness = 0.85
	# Frame
	var frame: MeshInstance3D = MeshInstance3D.new()
	var fm: BoxMesh = BoxMesh.new()
	fm.size = Vector3(2.85, 2.40, 0.30)
	frame.mesh = fm
	frame.material_override = wood_mat
	frame.position = Vector3(0, 1.20, 0)
	disp.add_child(frame)
	# 5 weapons
	var blade_mat: StandardMaterial3D = StandardMaterial3D.new()
	blade_mat.albedo_color = Color(0.85, 0.92, 1.0)
	blade_mat.metallic = 0.95
	blade_mat.roughness = 0.05
	var bronze_mat: StandardMaterial3D = StandardMaterial3D.new()
	bronze_mat.albedo_color = Color(0.85, 0.65, 0.20)
	bronze_mat.metallic = 0.85
	bronze_mat.roughness = 0.30
	var x_positions: Array = [-1.10, -0.55, 0.0, 0.55, 1.10]
	for i in 5:
		var x: float = x_positions[i]
		# Handle
		var handle: MeshInstance3D = MeshInstance3D.new()
		var hm: CylinderMesh = CylinderMesh.new()
		hm.top_radius = 0.025
		hm.bottom_radius = 0.025
		hm.height = 1.40
		handle.mesh = hm
		handle.material_override = wood_mat
		handle.position = Vector3(x, 1.20, 0.18)
		disp.add_child(handle)
		# Different weapon head
		var head: MeshInstance3D = MeshInstance3D.new()
		if i == 0 or i == 4:
			# Sword/dagger blade
			var bmm: BoxMesh = BoxMesh.new()
			bmm.size = Vector3(0.06, 0.85 if i == 0 else 0.55, 0.04)
			head.mesh = bmm
			head.material_override = blade_mat
		elif i == 1:
			# Axe
			var pm2: PrismMesh = PrismMesh.new()
			pm2.size = Vector3(0.18, 0.40, 0.06)
			head.mesh = pm2
			head.material_override = blade_mat
		elif i == 2:
			# Spear tip
			var pm2: PrismMesh = PrismMesh.new()
			pm2.size = Vector3(0.08, 0.40, 0.04)
			head.mesh = pm2
			head.material_override = blade_mat
		else:
			# Hammer head
			var bmm: BoxMesh = BoxMesh.new()
			bmm.size = Vector3(0.18, 0.20, 0.30)
			head.mesh = bmm
			head.material_override = bronze_mat
		head.position = Vector3(x, 1.95, 0.20)
		disp.add_child(head)
	# Frame collision
	var sb: StaticBody3D = StaticBody3D.new()
	sb.position = Vector3(0, 1.20, 0)
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(2.85, 2.40, 0.30)
	cs.shape = cb
	sb.add_child(cs)
	disp.add_child(sb)


static func _build_d7_tea_garden_benches(geom: Node) -> void:
	## Epic-7 T75: 4 wooden tea garden benches arranged in a small group.
	var benches: Node3D = Node3D.new()
	benches.name = "TeaGardenBenches"
	benches.position = Vector3(D7_CENTER.x - 22.0, 0.0, 8.0)
	geom.add_child(benches)
	var wood_mat: StandardMaterial3D = StandardMaterial3D.new()
	wood_mat.albedo_color = Color(0.45, 0.28, 0.12)
	wood_mat.roughness = 0.85
	var positions: Array = [
		Vector3( 0.0, 0,  0.0),
		Vector3( 2.85, 0,  0.0),
		Vector3( 0.0, 0,  2.40),
		Vector3( 2.85, 0,  2.40),
	]
	var rotations: Array = [0.0, 180.0, 0.0, 180.0]
	for i in 4:
		var bench: Node3D = Node3D.new()
		bench.position = positions[i]
		bench.rotation_degrees = Vector3(0, rotations[i], 0)
		benches.add_child(bench)
		# Seat
		var seat: MeshInstance3D = MeshInstance3D.new()
		var sm: BoxMesh = BoxMesh.new()
		sm.size = Vector3(1.85, 0.18, 0.55)
		seat.mesh = sm
		seat.material_override = wood_mat
		seat.position = Vector3(0, 0.55, 0)
		bench.add_child(seat)
		# 2 legs
		for sx in [-0.85, 0.85]:
			var leg: MeshInstance3D = MeshInstance3D.new()
			var lm: BoxMesh = BoxMesh.new()
			lm.size = Vector3(0.18, 0.55, 0.40)
			leg.mesh = lm
			leg.material_override = wood_mat
			leg.position = Vector3(sx, 0.27, 0)
			bench.add_child(leg)
		# Backrest
		var back: MeshInstance3D = MeshInstance3D.new()
		var bm: BoxMesh = BoxMesh.new()
		bm.size = Vector3(1.85, 0.65, 0.10)
		back.mesh = bm
		back.material_override = wood_mat
		back.position = Vector3(0, 0.95, -0.20)
		bench.add_child(back)
		# Bench collision
		var sb: StaticBody3D = StaticBody3D.new()
		sb.position = Vector3(0, 0.65, 0)
		var cs: CollisionShape3D = CollisionShape3D.new()
		var cb: BoxShape3D = BoxShape3D.new()
		cb.size = Vector3(1.85, 1.30, 0.55)
		cs.shape = cb
		sb.add_child(cs)
		bench.add_child(sb)


static func _build_d7_d7_rope_swing(geom: Node) -> void:
	## Epic-7 T76: rope swing under a tree branch — tall trunk + horizontal
	## branch + 2 ropes + plank seat with sway tween.
	var swing: Node3D = Node3D.new()
	swing.name = "D7RopeSwing"
	swing.position = Vector3(D7_CENTER.x - 18.0, 0.0, 18.0)
	geom.add_child(swing)
	var trunk_mat: StandardMaterial3D = StandardMaterial3D.new()
	trunk_mat.albedo_color = Color(0.30, 0.20, 0.10)
	trunk_mat.roughness = 0.92
	# Trunk
	var trunk: MeshInstance3D = MeshInstance3D.new()
	var trm: CylinderMesh = CylinderMesh.new()
	trm.top_radius = 0.18
	trm.bottom_radius = 0.30
	trm.height = 4.0
	trunk.mesh = trm
	trunk.material_override = trunk_mat
	trunk.position = Vector3(-1.5, 2.0, 0)
	swing.add_child(trunk)
	# Horizontal branch
	var branch: MeshInstance3D = MeshInstance3D.new()
	var brm: CylinderMesh = CylinderMesh.new()
	brm.top_radius = 0.10
	brm.bottom_radius = 0.12
	brm.height = 2.4
	branch.mesh = brm
	branch.material_override = trunk_mat
	branch.position = Vector3(0, 3.5, 0)
	branch.rotation_degrees = Vector3(0, 0, 90)
	swing.add_child(branch)
	# Pivot for swing motion
	var pivot: Node3D = Node3D.new()
	pivot.position = Vector3(0, 3.5, 0)
	swing.add_child(pivot)
	# 2 ropes
	var rope_mat: StandardMaterial3D = StandardMaterial3D.new()
	rope_mat.albedo_color = Color(0.55, 0.40, 0.20)
	rope_mat.roughness = 0.85
	for sx in [-0.40, 0.40]:
		var rope: MeshInstance3D = MeshInstance3D.new()
		var rrm: CylinderMesh = CylinderMesh.new()
		rrm.top_radius = 0.025
		rrm.bottom_radius = 0.025
		rrm.height = 2.4
		rope.mesh = rrm
		rope.material_override = rope_mat
		rope.position = Vector3(sx, -1.20, 0)
		pivot.add_child(rope)
	# Plank seat
	var seat: MeshInstance3D = MeshInstance3D.new()
	var sm: BoxMesh = BoxMesh.new()
	sm.size = Vector3(1.10, 0.08, 0.35)
	seat.mesh = sm
	var seat_mat: StandardMaterial3D = StandardMaterial3D.new()
	seat_mat.albedo_color = Color(0.55, 0.35, 0.18)
	seat_mat.roughness = 0.85
	seat.material_override = seat_mat
	seat.position = Vector3(0, -2.40, 0)
	pivot.add_child(seat)
	# Swing tween
	var tw: Tween = pivot.create_tween().set_loops()
	tw.tween_property(pivot, "rotation_degrees:x", 12.0, 1.4)
	tw.tween_property(pivot, "rotation_degrees:x", -12.0, 1.4)
	# Trunk collision
	var sb: StaticBody3D = StaticBody3D.new()
	sb.position = Vector3(-1.5, 2.0, 0)
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cap: CapsuleShape3D = CapsuleShape3D.new()
	cap.radius = 0.30
	cap.height = 4.0
	cs.shape = cap
	sb.add_child(cs)
	swing.add_child(sb)


static func _build_d7_child_apprentice_npc(town: Node) -> void:
	## Epic-7 T77: small child apprentice NPC — saffron robe + small wood
	## practice sword.
	var npc_slots: Node3D = town.get_node_or_null("%NPCSlots") as Node3D
	if npc_slots == null:
		return
	var slot: Marker3D = Marker3D.new()
	slot.name = "ChildApprenticeSlot"
	slot.position = Vector3(D7_CENTER.x - 18.0, 0.0, 17.0)
	npc_slots.add_child(slot)
	var npc_scene: PackedScene = load("res://scenes/entities/npcs/VillagerR3.tscn") as PackedScene
	if npc_scene == null:
		return
	var npc: Node3D = npc_scene.instantiate() as Node3D
	npc.name = "ChildApprentice"
	if "npc_name" in npc:
		npc.set("npc_name", "Pebble")
	if "npc_id" in npc:
		npc.set("npc_id", "child_apprentice_d7")
	npc.scale = Vector3(0.65, 0.65, 0.65)
	slot.add_child(npc)
	# Small saffron robe
	var robe: MeshInstance3D = MeshInstance3D.new()
	var rm: BoxMesh = BoxMesh.new()
	rm.size = Vector3(0.55, 0.95, 0.40)
	robe.mesh = rm
	var robe_mat: StandardMaterial3D = StandardMaterial3D.new()
	robe_mat.albedo_color = Color(0.95, 0.65, 0.20)
	robe_mat.emission_enabled = true
	robe_mat.emission = Color(0.95, 0.55, 0.10)
	robe_mat.emission_energy_multiplier = 0.30
	robe.material_override = robe_mat
	robe.position = Vector3(0, 0.55, 0)
	npc.add_child(robe)
	# Bald head
	var dome: MeshInstance3D = MeshInstance3D.new()
	var dm: SphereMesh = SphereMesh.new()
	dm.radius = 0.20
	dm.height = 0.36
	dome.mesh = dm
	var skin_mat: StandardMaterial3D = StandardMaterial3D.new()
	skin_mat.albedo_color = Color(0.95, 0.85, 0.65)
	skin_mat.roughness = 0.65
	dome.material_override = skin_mat
	dome.position = Vector3(0, 1.40, 0)
	npc.add_child(dome)
	# Small wooden practice sword
	var wood_mat: StandardMaterial3D = StandardMaterial3D.new()
	wood_mat.albedo_color = Color(0.45, 0.28, 0.12)
	wood_mat.roughness = 0.85
	var sword: MeshInstance3D = MeshInstance3D.new()
	var swm: BoxMesh = BoxMesh.new()
	swm.size = Vector3(0.06, 0.85, 0.06)
	sword.mesh = swm
	sword.material_override = wood_mat
	sword.position = Vector3(0.40, 0.85, 0.20)
	npc.add_child(sword)


static func _build_d7_stone_pagoda(geom: Node) -> void:
	## Epic-7 T78: tall multi-tier stone pagoda — 4 stacked roofs of
	## decreasing size on a square stone column.
	var pagoda: Node3D = Node3D.new()
	pagoda.name = "StonePagoda"
	pagoda.position = Vector3(D7_CENTER.x + 0.0, 0.0, 22.0)
	geom.add_child(pagoda)
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.55, 0.45, 0.30)
	stone_mat.roughness = 0.92
	var roof_mat: StandardMaterial3D = StandardMaterial3D.new()
	roof_mat.albedo_color = Color(0.40, 0.20, 0.15)
	roof_mat.roughness = 0.85
	# Square base
	var base: MeshInstance3D = MeshInstance3D.new()
	var bm: BoxMesh = BoxMesh.new()
	bm.size = Vector3(2.85, 0.55, 2.85)
	base.mesh = bm
	base.material_override = stone_mat
	base.position = Vector3(0, 0.27, 0)
	pagoda.add_child(base)
	# 4 stacked tiers (each smaller, with a roof on top)
	var tier_sizes: Array = [
		{"col": Vector3(2.20, 1.85, 2.20), "roof": Vector3(2.85, 0.40, 2.85), "y": 1.40, "ry": 2.40},
		{"col": Vector3(1.85, 1.65, 1.85), "roof": Vector3(2.40, 0.40, 2.40), "y": 3.20, "ry": 4.20},
		{"col": Vector3(1.50, 1.40, 1.50), "roof": Vector3(2.0, 0.40, 2.0),   "y": 4.85, "ry": 5.85},
		{"col": Vector3(1.10, 1.10, 1.10), "roof": Vector3(1.55, 0.40, 1.55), "y": 6.40, "ry": 7.10},
	]
	for tier in tier_sizes:
		# Stone column
		var col: MeshInstance3D = MeshInstance3D.new()
		var cmm: BoxMesh = BoxMesh.new()
		cmm.size = tier["col"]
		col.mesh = cmm
		col.material_override = stone_mat
		col.position = Vector3(0, tier["y"], 0)
		pagoda.add_child(col)
		# Sloped roof box
		var roof: MeshInstance3D = MeshInstance3D.new()
		var rmm: PrismMesh = PrismMesh.new()
		rmm.size = tier["roof"]
		roof.mesh = rmm
		roof.material_override = roof_mat
		roof.position = Vector3(0, tier["ry"], 0)
		pagoda.add_child(roof)
	# Top finial (tall thin spike)
	var finial: MeshInstance3D = MeshInstance3D.new()
	var ftm: PrismMesh = PrismMesh.new()
	ftm.size = Vector3(0.30, 1.40, 0.30)
	finial.mesh = ftm
	var bronze_mat: StandardMaterial3D = StandardMaterial3D.new()
	bronze_mat.albedo_color = Color(0.85, 0.65, 0.20)
	bronze_mat.emission_enabled = true
	bronze_mat.emission = Color(0.95, 0.65, 0.10)
	bronze_mat.emission_energy_multiplier = 1.4
	bronze_mat.metallic = 0.85
	finial.material_override = bronze_mat
	finial.position = Vector3(0, 8.0, 0)
	pagoda.add_child(finial)
	# Aura light
	var light: OmniLight3D = OmniLight3D.new()
	light.light_color = Color(1.0, 0.85, 0.30)
	light.light_energy = 3.0
	light.omni_range = 9.0
	light.position = Vector3(0, 4.20, 0)
	pagoda.add_child(light)
	# Pagoda collision (large box)
	var sb: StaticBody3D = StaticBody3D.new()
	sb.position = Vector3(0, 3.85, 0)
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(2.85, 7.50, 2.85)
	cs.shape = cb
	sb.add_child(cs)
	pagoda.add_child(sb)


static func _build_d7_pagoda_monk_npc(town: Node) -> void:
	## Epic-7 T79: pagoda guardian monk NPC — yellow robe + held bell.
	var npc_slots: Node3D = town.get_node_or_null("%NPCSlots") as Node3D
	if npc_slots == null:
		return
	var slot: Marker3D = Marker3D.new()
	slot.name = "PagodaMonkSlot"
	slot.position = Vector3(D7_CENTER.x + 2.0, 0.0, 22.0)
	npc_slots.add_child(slot)
	var npc_scene: PackedScene = load("res://scenes/entities/npcs/VillagerR3.tscn") as PackedScene
	if npc_scene == null:
		return
	var npc: Node3D = npc_scene.instantiate() as Node3D
	npc.name = "PagodaMonk"
	if "npc_name" in npc:
		npc.set("npc_name", "Stillpeak")
	if "npc_id" in npc:
		npc.set("npc_id", "pagoda_monk_d7")
	slot.add_child(npc)
	# Yellow robe
	var robe: MeshInstance3D = MeshInstance3D.new()
	var rm: BoxMesh = BoxMesh.new()
	rm.size = Vector3(0.65, 1.20, 0.45)
	robe.mesh = rm
	var robe_mat: StandardMaterial3D = StandardMaterial3D.new()
	robe_mat.albedo_color = Color(0.95, 0.85, 0.20)
	robe_mat.emission_enabled = true
	robe_mat.emission = Color(0.95, 0.85, 0.20)
	robe_mat.emission_energy_multiplier = 0.30
	robe_mat.roughness = 0.85
	robe.material_override = robe_mat
	robe.position = Vector3(0, 0.60, 0)
	npc.add_child(robe)
	# Bald head
	var dome: MeshInstance3D = MeshInstance3D.new()
	var dm: SphereMesh = SphereMesh.new()
	dm.radius = 0.20
	dm.height = 0.36
	dome.mesh = dm
	var skin_mat: StandardMaterial3D = StandardMaterial3D.new()
	skin_mat.albedo_color = Color(0.95, 0.85, 0.65)
	dome.material_override = skin_mat
	dome.position = Vector3(0, 1.50, 0)
	npc.add_child(dome)
	# Small held brass bell
	var bell: MeshInstance3D = MeshInstance3D.new()
	var bm: SphereMesh = SphereMesh.new()
	bm.radius = 0.10
	bm.height = 0.18
	bell.mesh = bm
	var brass_mat: StandardMaterial3D = StandardMaterial3D.new()
	brass_mat.albedo_color = Color(0.95, 0.75, 0.20)
	brass_mat.emission_enabled = true
	brass_mat.emission = Color(0.95, 0.65, 0.10)
	brass_mat.emission_energy_multiplier = 0.85
	brass_mat.metallic = 0.95
	bell.material_override = brass_mat
	bell.position = Vector3(0.40, 0.85, 0.20)
	bell.scale = Vector3(1.0, 0.85, 1.0)
	npc.add_child(bell)


static func _build_d7_falling_leaves(geom: Node) -> void:
	## Epic-7 T80: ambient falling autumn leaves — GPU particles drifting
	## down across the entire D7 area in warm orange/yellow colors.
	var leaves: GPUParticles3D = GPUParticles3D.new()
	leaves.name = "FallingLeaves"
	leaves.position = Vector3(D7_CENTER.x, 12.0, 0.0)
	leaves.amount = 80
	leaves.lifetime = 8.0
	leaves.preprocess = 4.0
	leaves.explosiveness = 0.0
	leaves.randomness = 0.6
	leaves.visibility_aabb = AABB(Vector3(-40, -14, -25), Vector3(80, 28, 50))
	var pm: ParticleProcessMaterial = ParticleProcessMaterial.new()
	pm.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	pm.emission_box_extents = Vector3(35, 0.5, 22)
	pm.direction = Vector3(0.20, -1, 0.10)
	pm.spread = 30.0
	pm.gravity = Vector3(0.10, -0.50, 0.05)
	pm.initial_velocity_min = 0.30
	pm.initial_velocity_max = 0.65
	pm.angular_velocity_min = -90.0
	pm.angular_velocity_max = 90.0
	pm.scale_min = 0.10
	pm.scale_max = 0.18
	pm.color = Color(0.95, 0.55, 0.20, 0.85)
	leaves.process_material = pm
	# Leaf mesh
	var leaf_mesh: BoxMesh = BoxMesh.new()
	leaf_mesh.size = Vector3(0.18, 0.02, 0.10)
	leaves.draw_pass_1 = leaf_mesh
	var leaf_mat: StandardMaterial3D = StandardMaterial3D.new()
	leaf_mat.albedo_color = Color(0.95, 0.55, 0.20)
	leaf_mat.emission_enabled = true
	leaf_mat.emission = Color(0.95, 0.45, 0.10)
	leaf_mat.emission_energy_multiplier = 1.4
	leaf_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	leaf_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	leaf_mesh.material = leaf_mat
	geom.add_child(leaves)


static func _build_d7_d7_gargoyles(geom: Node) -> void:
	## Epic-7 T81: row of 4 stone gargoyles on small pedestals — animal-headed
	## crouching figures with wings.
	var gargs: Node3D = Node3D.new()
	gargs.name = "D7Gargoyles"
	gargs.position = Vector3(D7_CENTER.x - 8.0, 0.0, 22.0)
	geom.add_child(gargs)
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.45, 0.40, 0.30)
	stone_mat.roughness = 0.92
	for i in 4:
		var garg: Node3D = Node3D.new()
		garg.position = Vector3(i * 1.85, 0, 0)
		gargs.add_child(garg)
		# Stone pedestal
		var ped: MeshInstance3D = MeshInstance3D.new()
		var pm: BoxMesh = BoxMesh.new()
		pm.size = Vector3(0.85, 0.85, 0.85)
		ped.mesh = pm
		ped.material_override = stone_mat
		ped.position = Vector3(0, 0.42, 0)
		garg.add_child(ped)
		# Crouching body (sphere)
		var body: MeshInstance3D = MeshInstance3D.new()
		var bm: SphereMesh = SphereMesh.new()
		bm.radius = 0.40
		bm.height = 0.55
		body.mesh = bm
		body.material_override = stone_mat
		body.position = Vector3(0, 1.0, 0)
		body.scale = Vector3(1.0, 0.85, 1.0)
		garg.add_child(body)
		# Animal-style head
		var head: MeshInstance3D = MeshInstance3D.new()
		var hm: BoxMesh = BoxMesh.new()
		hm.size = Vector3(0.30, 0.30, 0.40)
		head.mesh = hm
		head.material_override = stone_mat
		head.position = Vector3(0, 1.45, 0.18)
		garg.add_child(head)
		# 2 spiky horns/ears
		for sx in [-0.10, 0.10]:
			var horn: MeshInstance3D = MeshInstance3D.new()
			var prm: PrismMesh = PrismMesh.new()
			prm.size = Vector3(0.06, 0.18, 0.06)
			horn.mesh = prm
			horn.material_override = stone_mat
			horn.position = Vector3(sx, 1.65, 0.10)
			garg.add_child(horn)
		# 2 small folded wings
		for sx in [-0.30, 0.30]:
			var wing: MeshInstance3D = MeshInstance3D.new()
			var wm: PrismMesh = PrismMesh.new()
			wm.size = Vector3(0.10, 0.55, 0.18)
			wing.mesh = wm
			wing.material_override = stone_mat
			wing.position = Vector3(sx, 1.10, -0.15)
			wing.rotation_degrees = Vector3(-25, 0, 0)
			garg.add_child(wing)
		# Glowing red eyes
		var eye_mat: StandardMaterial3D = StandardMaterial3D.new()
		eye_mat.albedo_color = Color(0.95, 0.20, 0.20)
		eye_mat.emission_enabled = true
		eye_mat.emission = Color(0.95, 0.20, 0.20)
		eye_mat.emission_energy_multiplier = 3.0
		eye_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		for ex in [-0.06, 0.06]:
			var eye: MeshInstance3D = MeshInstance3D.new()
			var em: SphereMesh = SphereMesh.new()
			em.radius = 0.025
			em.height = 0.05
			eye.mesh = em
			eye.material_override = eye_mat
			eye.position = Vector3(ex, 1.45, 0.40)
			garg.add_child(eye)
		# Pedestal collision
		var sb: StaticBody3D = StaticBody3D.new()
		sb.position = Vector3(0, 0.85, 0)
		var cs: CollisionShape3D = CollisionShape3D.new()
		var cb: BoxShape3D = BoxShape3D.new()
		cb.size = Vector3(0.85, 1.85, 0.85)
		cs.shape = cb
		sb.add_child(cs)
		garg.add_child(sb)


static func _build_d7_cloud_pavilion(geom: Node) -> void:
	## Epic-7 T82: small floating cloud pavilion — translucent platform
	## with pillars hovering above the ground.
	var pav: Node3D = Node3D.new()
	pav.name = "CloudPavilion"
	pav.position = Vector3(D7_CENTER.x + 12.0, 2.40, 22.0)
	geom.add_child(pav)
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.85, 0.92, 1.0, 0.65)
	stone_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	stone_mat.emission_enabled = true
	stone_mat.emission = Color(0.85, 0.92, 1.0)
	stone_mat.emission_energy_multiplier = 1.4
	stone_mat.metallic = 0.30
	stone_mat.roughness = 0.20
	# Floating platform
	var platform: MeshInstance3D = MeshInstance3D.new()
	var pmm: CylinderMesh = CylinderMesh.new()
	pmm.top_radius = 1.85
	pmm.bottom_radius = 2.20
	pmm.height = 0.30
	platform.mesh = pmm
	platform.material_override = stone_mat
	platform.position = Vector3(0, 0, 0)
	pav.add_child(platform)
	# 4 corner translucent pillars
	for i in 4:
		var ang: float = (TAU / 4.0) * i + PI / 4.0
		var pillar: MeshInstance3D = MeshInstance3D.new()
		var pm2: CylinderMesh = CylinderMesh.new()
		pm2.top_radius = 0.10
		pm2.bottom_radius = 0.14
		pm2.height = 1.85
		pillar.mesh = pm2
		pillar.material_override = stone_mat
		pillar.position = Vector3(cos(ang) * 1.40, 1.10, sin(ang) * 1.40)
		pav.add_child(pillar)
	# Roof dome
	var dome: MeshInstance3D = MeshInstance3D.new()
	var dm: SphereMesh = SphereMesh.new()
	dm.radius = 1.85
	dm.height = 1.40
	dome.mesh = dm
	dome.material_override = stone_mat
	dome.position = Vector3(0, 2.30, 0)
	dome.scale = Vector3(1.0, 0.55, 1.0)
	pav.add_child(dome)
	# Slow hover bob
	var tw: Tween = pav.create_tween().set_loops()
	tw.tween_property(pav, "position:y", 2.85, 2.0)
	tw.tween_property(pav, "position:y", 2.40, 2.0)
	# Aura light
	var light: OmniLight3D = OmniLight3D.new()
	light.light_color = Color(0.85, 0.92, 1.0)
	light.light_energy = 2.5
	light.omni_range = 6.5
	light.position = Vector3(0, 1.40, 0)
	pav.add_child(light)
	# Platform collision
	var sb: StaticBody3D = StaticBody3D.new()
	sb.position = Vector3(0, 0, 0)
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cap: CylinderShape3D = CylinderShape3D.new()
	cap.radius = 2.20
	cap.height = 0.30
	cs.shape = cap
	sb.add_child(cs)
	pav.add_child(sb)


static func _build_d7_spirit_dancer_npc(town: Node) -> void:
	## Epic-7 T83: spirit dancer NPC — translucent flowing robe + raised
	## arms + spinning rotation tween.
	var npc_slots: Node3D = town.get_node_or_null("%NPCSlots") as Node3D
	if npc_slots == null:
		return
	var slot: Marker3D = Marker3D.new()
	slot.name = "SpiritDancerSlot"
	slot.position = Vector3(D7_CENTER.x + 12.0, 0.0, 22.0)
	npc_slots.add_child(slot)
	# Custom-built dancer (no VillagerR3 — needs full rotation freedom)
	var dancer: Node3D = Node3D.new()
	dancer.name = "SpiritDancer"
	slot.add_child(dancer)
	# Translucent flowing robe (tapered cone)
	var robe: MeshInstance3D = MeshInstance3D.new()
	var rm: CylinderMesh = CylinderMesh.new()
	rm.top_radius = 0.30
	rm.bottom_radius = 0.65
	rm.height = 1.40
	robe.mesh = rm
	var robe_mat: StandardMaterial3D = StandardMaterial3D.new()
	robe_mat.albedo_color = Color(0.95, 0.85, 1.0, 0.75)
	robe_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	robe_mat.emission_enabled = true
	robe_mat.emission = Color(0.85, 0.65, 0.95)
	robe_mat.emission_energy_multiplier = 1.4
	robe_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	robe.material_override = robe_mat
	robe.position = Vector3(0, 0.85, 0)
	dancer.add_child(robe)
	# Head
	var head: MeshInstance3D = MeshInstance3D.new()
	var hm: SphereMesh = SphereMesh.new()
	hm.radius = 0.18
	hm.height = 0.32
	head.mesh = hm
	head.material_override = robe_mat
	head.position = Vector3(0, 1.85, 0)
	dancer.add_child(head)
	# 2 raised arms (long tapered prisms reaching upward)
	for sx in [-0.30, 0.30]:
		var arm: MeshInstance3D = MeshInstance3D.new()
		var am: PrismMesh = PrismMesh.new()
		am.size = Vector3(0.10, 0.85, 0.10)
		arm.mesh = am
		arm.material_override = robe_mat
		arm.position = Vector3(sx, 2.0, 0)
		arm.rotation_degrees = Vector3(0, 0, -25.0 if sx > 0 else 25.0)
		dancer.add_child(arm)
	# Spin tween
	var tw: Tween = dancer.create_tween().set_loops()
	tw.tween_property(dancer, "rotation_degrees:y", 360.0, 4.0)
	tw.tween_property(dancer, "rotation_degrees:y", 0.0, 0.0)


static func _build_d7_outlook_telescope(geom: Node) -> void:
	## Epic-7 T84: rocky outlook point with a brass telescope on a tripod.
	var look: Node3D = Node3D.new()
	look.name = "OutlookTelescope"
	look.position = Vector3(D7_CENTER.x + 22.0, 0.0, 22.0)
	geom.add_child(look)
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.55, 0.45, 0.30)
	stone_mat.roughness = 0.92
	# Stone outlook platform
	var pad: MeshInstance3D = MeshInstance3D.new()
	var pm: BoxMesh = BoxMesh.new()
	pm.size = Vector3(2.85, 0.30, 2.85)
	pad.mesh = pm
	pad.material_override = stone_mat
	pad.position = Vector3(0, 0.15, 0)
	look.add_child(pad)
	# Brass telescope tripod (3 legs)
	var brass_mat: StandardMaterial3D = StandardMaterial3D.new()
	brass_mat.albedo_color = Color(0.85, 0.65, 0.20)
	brass_mat.metallic = 0.85
	brass_mat.roughness = 0.30
	for i in 3:
		var ang: float = (TAU / 3.0) * i
		var leg: MeshInstance3D = MeshInstance3D.new()
		var lm: CylinderMesh = CylinderMesh.new()
		lm.top_radius = 0.04
		lm.bottom_radius = 0.05
		lm.height = 1.40
		leg.mesh = lm
		leg.material_override = brass_mat
		leg.position = Vector3(cos(ang) * 0.30, 0.85, sin(ang) * 0.30)
		leg.rotation = Vector3(deg_to_rad(15) * sin(ang), 0, deg_to_rad(15) * cos(ang))
		look.add_child(leg)
	# Telescope barrel (long angled cylinder)
	var scope: MeshInstance3D = MeshInstance3D.new()
	var sm: CylinderMesh = CylinderMesh.new()
	sm.top_radius = 0.10
	sm.bottom_radius = 0.14
	sm.height = 1.40
	scope.mesh = sm
	scope.material_override = brass_mat
	scope.position = Vector3(0, 1.85, 0)
	scope.rotation_degrees = Vector3(-25, 0, 0)
	look.add_child(scope)
	# Lens (small bright glass disc)
	var lens: MeshInstance3D = MeshInstance3D.new()
	var lm: CylinderMesh = CylinderMesh.new()
	lm.top_radius = 0.10
	lm.bottom_radius = 0.10
	lm.height = 0.04
	lens.mesh = lm
	var lens_mat: StandardMaterial3D = StandardMaterial3D.new()
	lens_mat.albedo_color = Color(0.40, 0.95, 1.0)
	lens_mat.emission_enabled = true
	lens_mat.emission = Color(0.40, 1.0, 1.0)
	lens_mat.emission_energy_multiplier = 2.5
	lens_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	lens.material_override = lens_mat
	lens.position = Vector3(0, 2.40, 0.55)
	lens.rotation_degrees = Vector3(-25, 0, 0)
	look.add_child(lens)
	# Pad collision
	var sb: StaticBody3D = StaticBody3D.new()
	sb.position = Vector3(0, 0.15, 0)
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(2.85, 0.30, 2.85)
	cs.shape = cb
	sb.add_child(cs)
	look.add_child(sb)


static func _build_d7_d7_stargazer_npc(town: Node) -> void:
	## Epic-7 T85: D7 stargazer NPC — purple robe + tall pointed hat with
	## small star symbols.
	var npc_slots: Node3D = town.get_node_or_null("%NPCSlots") as Node3D
	if npc_slots == null:
		return
	var slot: Marker3D = Marker3D.new()
	slot.name = "D7StargazerSlot"
	slot.position = Vector3(D7_CENTER.x + 24.0, 0.0, 22.0)
	npc_slots.add_child(slot)
	var npc_scene: PackedScene = load("res://scenes/entities/npcs/VillagerR3.tscn") as PackedScene
	if npc_scene == null:
		return
	var npc: Node3D = npc_scene.instantiate() as Node3D
	npc.name = "D7Stargazer"
	if "npc_name" in npc:
		npc.set("npc_name", "Skywise")
	if "npc_id" in npc:
		npc.set("npc_id", "stargazer_d7")
	slot.add_child(npc)
	# Purple robe
	var robe: MeshInstance3D = MeshInstance3D.new()
	var rm: BoxMesh = BoxMesh.new()
	rm.size = Vector3(0.65, 1.20, 0.45)
	robe.mesh = rm
	var robe_mat: StandardMaterial3D = StandardMaterial3D.new()
	robe_mat.albedo_color = Color(0.30, 0.18, 0.55)
	robe_mat.emission_enabled = true
	robe_mat.emission = Color(0.30, 0.20, 0.65)
	robe_mat.emission_energy_multiplier = 0.30
	robe.material_override = robe_mat
	robe.position = Vector3(0, 0.60, 0)
	npc.add_child(robe)
	# Tall pointed hat
	var hat: MeshInstance3D = MeshInstance3D.new()
	var hm: PrismMesh = PrismMesh.new()
	hm.size = Vector3(0.40, 0.85, 0.40)
	hat.mesh = hm
	hat.material_override = robe_mat
	hat.position = Vector3(0, 1.65, 0)
	npc.add_child(hat)
	# 4 small star sprinkles on the hat
	var star_mat: StandardMaterial3D = StandardMaterial3D.new()
	star_mat.albedo_color = Color(1.0, 0.95, 0.55)
	star_mat.emission_enabled = true
	star_mat.emission = Color(1.0, 0.95, 0.55)
	star_mat.emission_energy_multiplier = 3.5
	star_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for i in 4:
		var star: MeshInstance3D = MeshInstance3D.new()
		var sm: SphereMesh = SphereMesh.new()
		sm.radius = 0.03
		sm.height = 0.06
		star.mesh = sm
		star.material_override = star_mat
		var ang: float = (TAU / 4.0) * i
		star.position = Vector3(cos(ang) * 0.10, 1.55 + i * 0.18, sin(ang) * 0.10)
		npc.add_child(star)


static func _build_d7_prayer_wheels(geom: Node) -> void:
	## Epic-7 T86: row of 6 spinning prayer wheels — bronze drums on
	## wooden axles, each rotating slowly around its vertical axis.
	var wheels: Node3D = Node3D.new()
	wheels.name = "PrayerWheels"
	wheels.position = Vector3(D7_CENTER.x - 14.0, 0.0, 8.0)
	geom.add_child(wheels)
	var wood_mat: StandardMaterial3D = StandardMaterial3D.new()
	wood_mat.albedo_color = Color(0.45, 0.28, 0.12)
	wood_mat.roughness = 0.85
	var bronze_mat: StandardMaterial3D = StandardMaterial3D.new()
	bronze_mat.albedo_color = Color(0.85, 0.55, 0.20)
	bronze_mat.emission_enabled = true
	bronze_mat.emission = Color(0.95, 0.55, 0.10)
	bronze_mat.emission_energy_multiplier = 0.65
	bronze_mat.metallic = 0.85
	bronze_mat.roughness = 0.30
	for i in 6:
		var wheel: Node3D = Node3D.new()
		wheel.position = Vector3(i * 1.30, 0, 0)
		wheels.add_child(wheel)
		# Wood axle base
		var base: MeshInstance3D = MeshInstance3D.new()
		var bm: BoxMesh = BoxMesh.new()
		bm.size = Vector3(0.18, 0.40, 0.30)
		base.mesh = bm
		base.material_override = wood_mat
		base.position = Vector3(0, 0.20, 0)
		wheel.add_child(base)
		# Top wood pillar
		var top: MeshInstance3D = MeshInstance3D.new()
		var tm: BoxMesh = BoxMesh.new()
		tm.size = Vector3(0.18, 0.40, 0.30)
		top.mesh = tm
		top.material_override = wood_mat
		top.position = Vector3(0, 1.65, 0)
		wheel.add_child(top)
		# Bronze drum (spinning)
		var drum: MeshInstance3D = MeshInstance3D.new()
		var dmm: CylinderMesh = CylinderMesh.new()
		dmm.top_radius = 0.30
		dmm.bottom_radius = 0.30
		dmm.height = 1.0
		drum.mesh = dmm
		drum.material_override = bronze_mat
		drum.position = Vector3(0, 0.95, 0)
		wheel.add_child(drum)
		# Spin tween
		var tw: Tween = drum.create_tween().set_loops()
		tw.tween_property(drum, "rotation_degrees:y", 360.0, 4.0 + i * 0.3)
		tw.tween_property(drum, "rotation_degrees:y", 0.0, 0.0)
		# Wheel collision
		var sb: StaticBody3D = StaticBody3D.new()
		sb.position = Vector3(0, 0.95, 0)
		var cs: CollisionShape3D = CollisionShape3D.new()
		var cap: CapsuleShape3D = CapsuleShape3D.new()
		cap.radius = 0.30
		cap.height = 1.85
		cs.shape = cap
		sb.add_child(cs)
		wheel.add_child(sb)


static func _build_d7_bell_shrine(geom: Node) -> void:
	## Epic-7 T87: small bell shrine — wooden frame with 3 hanging brass
	## bells of varying sizes that sway slowly.
	var shrine: Node3D = Node3D.new()
	shrine.name = "BellShrine"
	shrine.position = Vector3(D7_CENTER.x - 6.0, 0.0, 8.0)
	geom.add_child(shrine)
	var wood_mat: StandardMaterial3D = StandardMaterial3D.new()
	wood_mat.albedo_color = Color(0.45, 0.28, 0.12)
	wood_mat.roughness = 0.85
	var brass_mat: StandardMaterial3D = StandardMaterial3D.new()
	brass_mat.albedo_color = Color(0.95, 0.75, 0.20)
	brass_mat.emission_enabled = true
	brass_mat.emission = Color(0.95, 0.65, 0.10)
	brass_mat.emission_energy_multiplier = 0.65
	brass_mat.metallic = 0.95
	brass_mat.roughness = 0.10
	# 2 vertical wood pillars
	for sx in [-1.40, 1.40]:
		var pillar: MeshInstance3D = MeshInstance3D.new()
		var pm: CylinderMesh = CylinderMesh.new()
		pm.top_radius = 0.10
		pm.bottom_radius = 0.14
		pm.height = 2.85
		pillar.mesh = pm
		pillar.material_override = wood_mat
		pillar.position = Vector3(sx, 1.42, 0)
		shrine.add_child(pillar)
		# Pillar collision
		var sb: StaticBody3D = StaticBody3D.new()
		sb.position = Vector3(sx, 1.42, 0)
		var cs: CollisionShape3D = CollisionShape3D.new()
		var cap: CapsuleShape3D = CapsuleShape3D.new()
		cap.radius = 0.18
		cap.height = 2.85
		cs.shape = cap
		sb.add_child(cs)
		shrine.add_child(sb)
	# Top crossbar
	var cross: MeshInstance3D = MeshInstance3D.new()
	var crm: CylinderMesh = CylinderMesh.new()
	crm.top_radius = 0.06
	crm.bottom_radius = 0.06
	crm.height = 2.85
	cross.mesh = crm
	cross.material_override = wood_mat
	cross.position = Vector3(0, 2.85, 0)
	cross.rotation_degrees = Vector3(0, 0, 90)
	shrine.add_child(cross)
	# 3 hanging bells of varying sizes
	var sizes: Array = [0.30, 0.40, 0.30]
	for i in 3:
		var bell_pivot: Node3D = Node3D.new()
		bell_pivot.position = Vector3(-1.0 + i * 1.0, 2.85, 0)
		shrine.add_child(bell_pivot)
		var bell: MeshInstance3D = MeshInstance3D.new()
		var bm: SphereMesh = SphereMesh.new()
		bm.radius = sizes[i]
		bm.height = sizes[i] * 1.6
		bell.mesh = bm
		bell.material_override = brass_mat
		bell.position = Vector3(0, -0.55, 0)
		bell_pivot.add_child(bell)
		# Sway tween (offset per bell)
		var tw: Tween = bell_pivot.create_tween().set_loops()
		tw.tween_interval(i * 0.30)
		tw.tween_property(bell_pivot, "rotation_degrees:x", 6.0, 1.4 + i * 0.2)
		tw.tween_property(bell_pivot, "rotation_degrees:x", -6.0, 1.4 + i * 0.2)
	# Light
	var light: OmniLight3D = OmniLight3D.new()
	light.light_color = Color(1.0, 0.85, 0.30)
	light.light_energy = 1.85
	light.omni_range = 5.0
	light.position = Vector3(0, 2.40, 0)
	shrine.add_child(light)


static func _build_d7_sweeper_monk_npc(town: Node) -> void:
	## Epic-7 T88: sweeper monk NPC — orange robe + held broom + sweeping
	## arm motion tween.
	var npc_slots: Node3D = town.get_node_or_null("%NPCSlots") as Node3D
	if npc_slots == null:
		return
	var slot: Marker3D = Marker3D.new()
	slot.name = "SweeperMonkSlot"
	slot.position = Vector3(D7_CENTER.x - 6.0, 0.0, 18.0)
	npc_slots.add_child(slot)
	var npc_scene: PackedScene = load("res://scenes/entities/npcs/VillagerR3.tscn") as PackedScene
	if npc_scene == null:
		return
	var npc: Node3D = npc_scene.instantiate() as Node3D
	npc.name = "SweeperMonk"
	if "npc_name" in npc:
		npc.set("npc_name", "Dustquiet")
	if "npc_id" in npc:
		npc.set("npc_id", "sweeper_d7")
	slot.add_child(npc)
	# Orange robe
	var robe: MeshInstance3D = MeshInstance3D.new()
	var rm: BoxMesh = BoxMesh.new()
	rm.size = Vector3(0.65, 1.20, 0.45)
	robe.mesh = rm
	var robe_mat: StandardMaterial3D = StandardMaterial3D.new()
	robe_mat.albedo_color = Color(0.95, 0.55, 0.20)
	robe_mat.emission_enabled = true
	robe_mat.emission = Color(0.95, 0.45, 0.15)
	robe_mat.emission_energy_multiplier = 0.30
	robe.material_override = robe_mat
	robe.position = Vector3(0, 0.60, 0)
	npc.add_child(robe)
	# Bald head
	var dome: MeshInstance3D = MeshInstance3D.new()
	var dm: SphereMesh = SphereMesh.new()
	dm.radius = 0.20
	dm.height = 0.36
	dome.mesh = dm
	var skin_mat: StandardMaterial3D = StandardMaterial3D.new()
	skin_mat.albedo_color = Color(0.95, 0.85, 0.65)
	dome.material_override = skin_mat
	dome.position = Vector3(0, 1.50, 0)
	npc.add_child(dome)
	# Broom (handle + bristle bundle)
	var wood_mat: StandardMaterial3D = StandardMaterial3D.new()
	wood_mat.albedo_color = Color(0.45, 0.28, 0.12)
	wood_mat.roughness = 0.85
	var handle: MeshInstance3D = MeshInstance3D.new()
	var hmm: CylinderMesh = CylinderMesh.new()
	hmm.top_radius = 0.04
	hmm.bottom_radius = 0.04
	hmm.height = 1.40
	handle.mesh = hmm
	handle.material_override = wood_mat
	handle.position = Vector3(0.45, 0.85, 0.20)
	handle.rotation_degrees = Vector3(0, 0, 25)
	npc.add_child(handle)
	# Bristle bundle (wide thin box)
	var bristles: MeshInstance3D = MeshInstance3D.new()
	var bsm: BoxMesh = BoxMesh.new()
	bsm.size = Vector3(0.30, 0.20, 0.40)
	bristles.mesh = bsm
	var br_mat: StandardMaterial3D = StandardMaterial3D.new()
	br_mat.albedo_color = Color(0.85, 0.65, 0.30)
	br_mat.roughness = 0.95
	bristles.material_override = br_mat
	bristles.position = Vector3(0.95, 0.20, 0.20)
	npc.add_child(bristles)
	# Sweeping motion
	var tw: Tween = handle.create_tween().set_loops()
	tw.tween_property(handle, "rotation_degrees:z", 35.0, 0.55)
	tw.tween_property(handle, "rotation_degrees:z", 15.0, 0.55)


static func _build_d7_water_mill(geom: Node) -> void:
	## Epic-7 T89: small water mill — wooden building + large rotating
	## water wheel on the side + small water trough at the base.
	var mill: Node3D = Node3D.new()
	mill.name = "WaterMill"
	mill.position = Vector3(D7_CENTER.x + 0.0, 0.0, 18.0)
	geom.add_child(mill)
	var wood_mat: StandardMaterial3D = StandardMaterial3D.new()
	wood_mat.albedo_color = Color(0.45, 0.28, 0.12)
	wood_mat.roughness = 0.85
	var dark_wood: StandardMaterial3D = StandardMaterial3D.new()
	dark_wood.albedo_color = Color(0.25, 0.15, 0.08)
	dark_wood.roughness = 0.85
	# Mill building
	var body: MeshInstance3D = MeshInstance3D.new()
	var bm: BoxMesh = BoxMesh.new()
	bm.size = Vector3(2.85, 3.40, 2.85)
	body.mesh = bm
	body.material_override = wood_mat
	body.position = Vector3(0, 1.70, 0)
	mill.add_child(body)
	# Sloped roof
	var roof: MeshInstance3D = MeshInstance3D.new()
	var rm: PrismMesh = PrismMesh.new()
	rm.size = Vector3(3.20, 1.10, 3.20)
	roof.mesh = rm
	roof.material_override = dark_wood
	roof.position = Vector3(0, 3.95, 0)
	mill.add_child(roof)
	# Large water wheel on the side (vertical disc + spokes)
	var wheel_pivot: Node3D = Node3D.new()
	wheel_pivot.position = Vector3(2.40, 1.40, 0)
	mill.add_child(wheel_pivot)
	var wheel_disc: MeshInstance3D = MeshInstance3D.new()
	var wdm: CylinderMesh = CylinderMesh.new()
	wdm.top_radius = 1.40
	wdm.bottom_radius = 1.40
	wdm.height = 0.18
	wheel_disc.mesh = wdm
	wheel_disc.material_override = dark_wood
	wheel_disc.rotation_degrees = Vector3(0, 0, 90)
	wheel_pivot.add_child(wheel_disc)
	# 8 spoke paddles around the wheel
	for i in 8:
		var ang: float = (TAU / 8.0) * i
		var paddle: MeshInstance3D = MeshInstance3D.new()
		var pm: BoxMesh = BoxMesh.new()
		pm.size = Vector3(0.30, 0.85, 0.04)
		paddle.mesh = pm
		paddle.material_override = wood_mat
		paddle.position = Vector3(0, sin(ang) * 1.20, cos(ang) * 1.20)
		paddle.rotation = Vector3(ang, 0, 0)
		wheel_pivot.add_child(paddle)
	# Spin tween for the wheel
	var tw: Tween = wheel_pivot.create_tween().set_loops()
	tw.tween_property(wheel_pivot, "rotation_degrees:x", 360.0, 8.0)
	tw.tween_property(wheel_pivot, "rotation_degrees:x", 0.0, 0.0)
	# Small water trough below (translucent)
	var trough: MeshInstance3D = MeshInstance3D.new()
	var tm: BoxMesh = BoxMesh.new()
	tm.size = Vector3(1.40, 0.20, 0.85)
	trough.mesh = tm
	var water_mat: StandardMaterial3D = StandardMaterial3D.new()
	water_mat.albedo_color = Color(0.40, 0.85, 1.0, 0.65)
	water_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	water_mat.emission_enabled = true
	water_mat.emission = Color(0.30, 0.85, 1.0)
	water_mat.emission_energy_multiplier = 0.85
	trough.material_override = water_mat
	trough.position = Vector3(2.85, 0.10, 0)
	mill.add_child(trough)
	# Mill collision
	var sb: StaticBody3D = StaticBody3D.new()
	sb.position = Vector3(0, 1.70, 0)
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(2.85, 3.40, 2.85)
	cs.shape = cb
	sb.add_child(cs)
	mill.add_child(sb)


static func _build_d7_cloud_mist(geom: Node) -> void:
	## Epic-7 T90: high-altitude cloud mist — large pale GPU particles
	## drifting around at upper height giving the area a cloudy feel.
	var mist: GPUParticles3D = GPUParticles3D.new()
	mist.name = "CloudMist"
	mist.position = Vector3(D7_CENTER.x, 8.0, 0.0)
	mist.amount = 60
	mist.lifetime = 16.0
	mist.preprocess = 8.0
	mist.explosiveness = 0.0
	mist.randomness = 0.85
	mist.visibility_aabb = AABB(Vector3(-40, -8, -25), Vector3(80, 24, 50))
	var pm: ParticleProcessMaterial = ParticleProcessMaterial.new()
	pm.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	pm.emission_box_extents = Vector3(35, 4, 22)
	pm.direction = Vector3(0.30, 0.10, 0.10)
	pm.spread = 75.0
	pm.gravity = Vector3(0.05, 0.04, 0.02)
	pm.initial_velocity_min = 0.10
	pm.initial_velocity_max = 0.30
	pm.scale_min = 1.10
	pm.scale_max = 2.20
	pm.color = Color(0.95, 0.95, 1.0, 0.30)
	mist.process_material = pm
	# Cloud mesh — large soft sphere
	var cloud_mesh: SphereMesh = SphereMesh.new()
	cloud_mesh.radius = 0.85
	cloud_mesh.height = 1.40
	mist.draw_pass_1 = cloud_mesh
	var cloud_mat: StandardMaterial3D = StandardMaterial3D.new()
	cloud_mat.albedo_color = Color(0.95, 0.95, 1.0, 0.18)
	cloud_mat.emission_enabled = true
	cloud_mat.emission = Color(0.92, 0.92, 1.0)
	cloud_mat.emission_energy_multiplier = 0.40
	cloud_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	cloud_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	cloud_mesh.material = cloud_mat
	geom.add_child(mist)


static func _build_d7_stone_golem(geom: Node) -> void:
	## Epic-7 T91: small stone golem — chunky humanoid built from stone
	## blocks with glowing amber rune eyes + slow patrol.
	var golem: Node3D = Node3D.new()
	golem.name = "D7StoneGolem"
	golem.position = Vector3(D7_CENTER.x + 16.0, 0.0, -8.0)
	geom.add_child(golem)
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.55, 0.45, 0.30)
	stone_mat.roughness = 0.92
	# Body block
	var body: MeshInstance3D = MeshInstance3D.new()
	var bm: BoxMesh = BoxMesh.new()
	bm.size = Vector3(1.10, 1.40, 0.85)
	body.mesh = bm
	body.material_override = stone_mat
	body.position = Vector3(0, 0.85, 0)
	golem.add_child(body)
	# Head block
	var head: MeshInstance3D = MeshInstance3D.new()
	var hm: BoxMesh = BoxMesh.new()
	hm.size = Vector3(0.65, 0.55, 0.55)
	head.mesh = hm
	head.material_override = stone_mat
	head.position = Vector3(0, 1.85, 0)
	golem.add_child(head)
	# 2 amber eyes
	var eye_mat: StandardMaterial3D = StandardMaterial3D.new()
	eye_mat.albedo_color = Color(1.0, 0.65, 0.20)
	eye_mat.emission_enabled = true
	eye_mat.emission = Color(1.0, 0.65, 0.20)
	eye_mat.emission_energy_multiplier = 4.0
	eye_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for ex in [-0.15, 0.15]:
		var eye: MeshInstance3D = MeshInstance3D.new()
		var em: BoxMesh = BoxMesh.new()
		em.size = Vector3(0.10, 0.06, 0.04)
		eye.mesh = em
		eye.material_override = eye_mat
		eye.position = Vector3(ex, 1.92, 0.30)
		golem.add_child(eye)
	# 2 chunky arms
	for sx in [-0.85, 0.85]:
		var arm: MeshInstance3D = MeshInstance3D.new()
		var am: BoxMesh = BoxMesh.new()
		am.size = Vector3(0.40, 1.10, 0.40)
		arm.mesh = am
		arm.material_override = stone_mat
		arm.position = Vector3(sx, 0.85, 0)
		golem.add_child(arm)
	# 2 legs
	for sx in [-0.30, 0.30]:
		var leg: MeshInstance3D = MeshInstance3D.new()
		var lm: BoxMesh = BoxMesh.new()
		lm.size = Vector3(0.40, 0.30, 0.40)
		leg.mesh = lm
		leg.material_override = stone_mat
		leg.position = Vector3(sx, 0.15, 0)
		golem.add_child(leg)
	# Slow patrol
	var tw: Tween = golem.create_tween().set_loops()
	tw.tween_property(golem, "position", Vector3(D7_CENTER.x + 18.0, 0.0, -8.0), 4.0)
	tw.tween_property(golem, "rotation_degrees:y", 180.0, 0.5)
	tw.tween_property(golem, "position", Vector3(D7_CENTER.x + 14.0, 0.0, -8.0), 4.0)
	tw.tween_property(golem, "rotation_degrees:y", 0.0, 0.5)
	# Body collision
	var sb: StaticBody3D = StaticBody3D.new()
	sb.position = Vector3(0, 0.85, 0)
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(1.85, 1.85, 0.85)
	cs.shape = cb
	sb.add_child(cs)
	golem.add_child(sb)


static func _build_d7_sky_lanterns(geom: Node) -> void:
	## Epic-7 T92: 6 paper sky lanterns rising slowly into the air —
	## warm orange spheres with hover/rise tweens.
	var lanterns: Node3D = Node3D.new()
	lanterns.name = "SkyLanterns"
	lanterns.position = Vector3(D7_CENTER.x + 8.0, 0.0, -16.0)
	geom.add_child(lanterns)
	var lantern_mat: StandardMaterial3D = StandardMaterial3D.new()
	lantern_mat.albedo_color = Color(0.95, 0.65, 0.30, 0.85)
	lantern_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	lantern_mat.emission_enabled = true
	lantern_mat.emission = Color(1.0, 0.55, 0.10)
	lantern_mat.emission_energy_multiplier = 3.0
	lantern_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for i in 6:
		var lantern: Node3D = Node3D.new()
		lantern.position = Vector3(
			randf_range(-3.5, 3.5),
			randf_range(0.85, 4.0),
			randf_range(-2.5, 2.5)
		)
		lanterns.add_child(lantern)
		# Lantern body (sphere)
		var body: MeshInstance3D = MeshInstance3D.new()
		var bm: SphereMesh = SphereMesh.new()
		bm.radius = 0.30
		bm.height = 0.55
		body.mesh = bm
		body.material_override = lantern_mat
		body.scale = Vector3(1.0, 1.20, 1.0)
		lantern.add_child(body)
		# Tiny light
		var light: OmniLight3D = OmniLight3D.new()
		light.light_color = Color(1.0, 0.55, 0.20)
		light.light_energy = 1.4
		light.omni_range = 3.0
		light.position = Vector3.ZERO
		lantern.add_child(light)
		# Slow rise + reset tween
		var tw: Tween = lantern.create_tween().set_loops()
		var start_y: float = lantern.position.y
		tw.tween_interval(i * 0.85)
		tw.tween_property(lantern, "position:y", start_y + 4.85, 6.0 + i * 0.4)
		tw.tween_property(lantern, "position:y", start_y, 0.0)


static func _build_d7_lantern_releaser_npc(town: Node) -> void:
	## Epic-7 T93: lantern releaser NPC — cream robe + held lit lantern
	## raised upward.
	var npc_slots: Node3D = town.get_node_or_null("%NPCSlots") as Node3D
	if npc_slots == null:
		return
	var slot: Marker3D = Marker3D.new()
	slot.name = "LanternReleaserSlot"
	slot.position = Vector3(D7_CENTER.x + 6.0, 0.0, -16.0)
	npc_slots.add_child(slot)
	var npc_scene: PackedScene = load("res://scenes/entities/npcs/VillagerR3.tscn") as PackedScene
	if npc_scene == null:
		return
	var npc: Node3D = npc_scene.instantiate() as Node3D
	npc.name = "LanternReleaser"
	if "npc_name" in npc:
		npc.set("npc_name", "Skylight")
	if "npc_id" in npc:
		npc.set("npc_id", "lantern_releaser_d7")
	slot.add_child(npc)
	# Cream robe
	var robe: MeshInstance3D = MeshInstance3D.new()
	var rm: BoxMesh = BoxMesh.new()
	rm.size = Vector3(0.65, 1.20, 0.45)
	robe.mesh = rm
	var robe_mat: StandardMaterial3D = StandardMaterial3D.new()
	robe_mat.albedo_color = Color(0.95, 0.92, 0.75)
	robe_mat.emission_enabled = true
	robe_mat.emission = Color(0.95, 0.85, 0.55)
	robe_mat.emission_energy_multiplier = 0.30
	robe.material_override = robe_mat
	robe.position = Vector3(0, 0.60, 0)
	npc.add_child(robe)
	# Lifted lantern overhead (orange sphere)
	var lantern: MeshInstance3D = MeshInstance3D.new()
	var lm: SphereMesh = SphereMesh.new()
	lm.radius = 0.18
	lm.height = 0.30
	lantern.mesh = lm
	var lantern_mat: StandardMaterial3D = StandardMaterial3D.new()
	lantern_mat.albedo_color = Color(0.95, 0.55, 0.20)
	lantern_mat.emission_enabled = true
	lantern_mat.emission = Color(1.0, 0.55, 0.10)
	lantern_mat.emission_energy_multiplier = 3.0
	lantern_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	lantern.material_override = lantern_mat
	lantern.position = Vector3(0.40, 1.85, 0.20)
	npc.add_child(lantern)
	# Light
	var light: OmniLight3D = OmniLight3D.new()
	light.light_color = Color(1.0, 0.55, 0.20)
	light.light_energy = 1.6
	light.omni_range = 3.5
	light.position = Vector3(0.40, 1.85, 0.20)
	npc.add_child(light)


static func _build_d7_ancient_pine(geom: Node) -> void:
	## Epic-7 T94: gnarled ancient pine tree — twisted trunk + 4 angled
	## branches + dark green canopy clusters.
	var tree: Node3D = Node3D.new()
	tree.name = "AncientPine"
	tree.position = Vector3(D7_CENTER.x - 16.0, 0.0, -8.0)
	geom.add_child(tree)
	var trunk_mat: StandardMaterial3D = StandardMaterial3D.new()
	trunk_mat.albedo_color = Color(0.30, 0.20, 0.10)
	trunk_mat.roughness = 0.95
	var pine_mat: StandardMaterial3D = StandardMaterial3D.new()
	pine_mat.albedo_color = Color(0.20, 0.45, 0.20)
	pine_mat.emission_enabled = true
	pine_mat.emission = Color(0.15, 0.40, 0.15)
	pine_mat.emission_energy_multiplier = 0.18
	pine_mat.roughness = 0.85
	# Twisted trunk (3 angled segments)
	for i in 3:
		var seg: MeshInstance3D = MeshInstance3D.new()
		var sm: CylinderMesh = CylinderMesh.new()
		sm.top_radius = 0.30 - i * 0.05
		sm.bottom_radius = 0.45 - i * 0.05
		sm.height = 1.40
		seg.mesh = sm
		seg.material_override = trunk_mat
		seg.position = Vector3(sin(i * 1.5) * 0.20, 0.70 + i * 1.40, cos(i * 1.5) * 0.20)
		seg.rotation_degrees = Vector3(8.0 * sin(i * 1.5), 0, 8.0 * cos(i * 1.5))
		tree.add_child(seg)
	# 4 angled branches
	for i in 4:
		var ang: float = (TAU / 4.0) * i
		var branch: MeshInstance3D = MeshInstance3D.new()
		var bm: CylinderMesh = CylinderMesh.new()
		bm.top_radius = 0.06
		bm.bottom_radius = 0.10
		bm.height = 1.40
		branch.mesh = bm
		branch.material_override = trunk_mat
		branch.position = Vector3(cos(ang) * 0.55, 4.20, sin(ang) * 0.55)
		branch.rotation = Vector3(deg_to_rad(45) * sin(ang), ang, deg_to_rad(45) * cos(ang))
		tree.add_child(branch)
		# Dark canopy cluster at branch tip
		var cluster: MeshInstance3D = MeshInstance3D.new()
		var cm: SphereMesh = SphereMesh.new()
		cm.radius = 0.65
		cm.height = 0.95
		cluster.mesh = cm
		cluster.material_override = pine_mat
		cluster.position = Vector3(cos(ang) * 1.40, 4.85, sin(ang) * 1.40)
		cluster.scale = Vector3(1.0, 0.65, 1.0)
		tree.add_child(cluster)
	# Top crown cluster
	var crown: MeshInstance3D = MeshInstance3D.new()
	var crm: SphereMesh = SphereMesh.new()
	crm.radius = 0.85
	crm.height = 1.10
	crown.mesh = crm
	crown.material_override = pine_mat
	crown.position = Vector3(0, 5.55, 0)
	tree.add_child(crown)
	# Trunk collision
	var sb: StaticBody3D = StaticBody3D.new()
	sb.position = Vector3(0, 2.10, 0)
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cap: CapsuleShape3D = CapsuleShape3D.new()
	cap.radius = 0.45
	cap.height = 4.20
	cs.shape = cap
	sb.add_child(cs)
	tree.add_child(sb)


static func _build_d7_d7_scholar_npc(town: Node) -> void:
	## Epic-7 T95: D7 scholar NPC — long scholarly robe + held open
	## scroll/book.
	var npc_slots: Node3D = town.get_node_or_null("%NPCSlots") as Node3D
	if npc_slots == null:
		return
	var slot: Marker3D = Marker3D.new()
	slot.name = "D7ScholarSlot"
	slot.position = Vector3(D7_CENTER.x - 22.0, 0.0, -2.0)
	npc_slots.add_child(slot)
	var npc_scene: PackedScene = load("res://scenes/entities/npcs/VillagerR3.tscn") as PackedScene
	if npc_scene == null:
		return
	var npc: Node3D = npc_scene.instantiate() as Node3D
	npc.name = "D7Scholar"
	if "npc_name" in npc:
		npc.set("npc_name", "Quill")
	if "npc_id" in npc:
		npc.set("npc_id", "scholar_d7")
	slot.add_child(npc)
	# Long scholarly grey robe
	var robe: MeshInstance3D = MeshInstance3D.new()
	var rm: BoxMesh = BoxMesh.new()
	rm.size = Vector3(0.65, 1.20, 0.45)
	robe.mesh = rm
	var robe_mat: StandardMaterial3D = StandardMaterial3D.new()
	robe_mat.albedo_color = Color(0.40, 0.42, 0.45)
	robe_mat.roughness = 0.85
	robe.material_override = robe_mat
	robe.position = Vector3(0, 0.60, 0)
	npc.add_child(robe)
	# Open book held in hands (small flat box)
	var book: MeshInstance3D = MeshInstance3D.new()
	var bm: BoxMesh = BoxMesh.new()
	bm.size = Vector3(0.40, 0.04, 0.30)
	book.mesh = bm
	var book_mat: StandardMaterial3D = StandardMaterial3D.new()
	book_mat.albedo_color = Color(0.95, 0.92, 0.85)
	book_mat.emission_enabled = true
	book_mat.emission = Color(0.95, 0.85, 0.55)
	book_mat.emission_energy_multiplier = 0.45
	book.material_override = book_mat
	book.position = Vector3(0.40, 0.85, 0.20)
	book.rotation_degrees = Vector3(-25, 0, 0)
	npc.add_child(book)


static func _build_d7_welcome_banner(geom: Node) -> void:
	## Epic-7 T96: tall double-pole welcome banner — wooden poles + draped
	## red cloth + golden trim + Label3D titles.
	var banner: Node3D = Node3D.new()
	banner.name = "D7WelcomeBanner"
	banner.position = Vector3(D7_CENTER.x - 36.0, 0.0, -4.0)
	geom.add_child(banner)
	var wood_mat: StandardMaterial3D = StandardMaterial3D.new()
	wood_mat.albedo_color = Color(0.45, 0.28, 0.12)
	wood_mat.roughness = 0.85
	var cloth_mat: StandardMaterial3D = StandardMaterial3D.new()
	cloth_mat.albedo_color = Color(0.85, 0.20, 0.20)
	cloth_mat.emission_enabled = true
	cloth_mat.emission = Color(0.85, 0.25, 0.20)
	cloth_mat.emission_energy_multiplier = 0.45
	cloth_mat.roughness = 0.65
	var gold_mat: StandardMaterial3D = StandardMaterial3D.new()
	gold_mat.albedo_color = Color(1.0, 0.85, 0.30)
	gold_mat.emission_enabled = true
	gold_mat.emission = Color(1.0, 0.75, 0.20)
	gold_mat.emission_energy_multiplier = 1.4
	gold_mat.metallic = 0.95
	# 2 wooden poles (with capsule collisions)
	for sx in [-2.40, 2.40]:
		var pole: MeshInstance3D = MeshInstance3D.new()
		var pm: CylinderMesh = CylinderMesh.new()
		pm.top_radius = 0.14
		pm.bottom_radius = 0.20
		pm.height = 5.85
		pole.mesh = pm
		pole.material_override = wood_mat
		pole.position = Vector3(sx, 2.92, 0)
		banner.add_child(pole)
		# Pole collision
		var sb: StaticBody3D = StaticBody3D.new()
		sb.position = Vector3(sx, 2.92, 0)
		var cs: CollisionShape3D = CollisionShape3D.new()
		var cap: CapsuleShape3D = CapsuleShape3D.new()
		cap.radius = 0.20
		cap.height = 5.85
		cs.shape = cap
		sb.add_child(cs)
		banner.add_child(sb)
	# Top crossbar
	var bar: MeshInstance3D = MeshInstance3D.new()
	var bm: CylinderMesh = CylinderMesh.new()
	bm.top_radius = 0.10
	bm.bottom_radius = 0.10
	bm.height = 5.20
	bar.mesh = bm
	bar.material_override = wood_mat
	bar.position = Vector3(0, 5.85, 0)
	bar.rotation_degrees = Vector3(0, 0, 90)
	banner.add_child(bar)
	# Banner cloth
	var cloth: MeshInstance3D = MeshInstance3D.new()
	var cmm: BoxMesh = BoxMesh.new()
	cmm.size = Vector3(4.85, 2.85, 0.06)
	cloth.mesh = cmm
	cloth.material_override = cloth_mat
	cloth.position = Vector3(0, 4.0, 0)
	banner.add_child(cloth)
	# Gold trim borders (top + bottom)
	for trim_y in [5.40, 2.55]:
		var trim: MeshInstance3D = MeshInstance3D.new()
		var tm: BoxMesh = BoxMesh.new()
		tm.size = Vector3(4.85, 0.18, 0.06)
		trim.mesh = tm
		trim.material_override = gold_mat
		trim.position = Vector3(0, trim_y, 0.04)
		banner.add_child(trim)
	# Title labels
	var label: Label3D = Label3D.new()
	label.text = "ASCENSION SPIRES"
	label.modulate = Color(1.0, 0.85, 0.30)
	label.outline_modulate = Color(0.20, 0.10, 0.05)
	label.outline_size = 14
	label.font_size = 88
	label.pixel_size = 0.013
	label.position = Vector3(0, 4.40, 0.08)
	banner.add_child(label)
	var subtitle: Label3D = Label3D.new()
	subtitle.text = "where the simulation reaches the sky"
	subtitle.modulate = Color(0.95, 0.92, 0.85)
	subtitle.outline_modulate = Color(0.30, 0.10, 0.05)
	subtitle.outline_size = 8
	subtitle.font_size = 42
	subtitle.pixel_size = 0.010
	subtitle.position = Vector3(0, 3.30, 0.08)
	banner.add_child(subtitle)
	# Light
	var light: OmniLight3D = OmniLight3D.new()
	light.light_color = Color(1.0, 0.65, 0.30)
	light.light_energy = 3.0
	light.omni_range = 9.0
	light.position = Vector3(0, 4.20, 1.20)
	banner.add_child(light)


static func _build_d7_grand_peak(geom: Node) -> void:
	## Epic-7 T97: GRAND MOUNTAIN PEAK landmark — towering 5-tier sandstone
	## peak crowned with a glowing amber crystal + 8 orbiting stone
	## fragments + massive aura beam.
	var peak: Node3D = Node3D.new()
	peak.name = "GrandMountainPeak"
	peak.position = Vector3(D7_CENTER.x, 0.0, -2.0)
	geom.add_child(peak)
	var rock_mat: StandardMaterial3D = StandardMaterial3D.new()
	rock_mat.albedo_color = Color(0.65, 0.45, 0.20)
	rock_mat.emission_enabled = true
	rock_mat.emission = Color(0.55, 0.35, 0.15)
	rock_mat.emission_energy_multiplier = 0.18
	rock_mat.roughness = 0.92
	var dark_rock: StandardMaterial3D = StandardMaterial3D.new()
	dark_rock.albedo_color = Color(0.45, 0.30, 0.15)
	dark_rock.roughness = 0.92
	var crystal_mat: StandardMaterial3D = StandardMaterial3D.new()
	crystal_mat.albedo_color = Color(1.0, 0.65, 0.20)
	crystal_mat.emission_enabled = true
	crystal_mat.emission = Color(1.0, 0.55, 0.10)
	crystal_mat.emission_energy_multiplier = 4.5
	crystal_mat.metallic = 0.55
	crystal_mat.roughness = 0.10
	crystal_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	# Stone pedestal
	var ped: MeshInstance3D = MeshInstance3D.new()
	var pm: BoxMesh = BoxMesh.new()
	pm.size = Vector3(6.50, 0.55, 6.50)
	ped.mesh = pm
	ped.material_override = dark_rock
	ped.position = Vector3(0, 0.27, 0)
	peak.add_child(ped)
	# 5 tapered tiers climbing higher than the spire
	var tier_data: Array = [
		{"top": 2.40, "bot": 2.85, "h": 3.40, "y": 2.20},
		{"top": 1.85, "bot": 2.40, "h": 3.40, "y": 5.55},
		{"top": 1.40, "bot": 1.85, "h": 3.40, "y": 8.85},
		{"top": 0.95, "bot": 1.40, "h": 3.40, "y": 12.0},
		{"top": 0.55, "bot": 0.95, "h": 2.85, "y": 14.85},
	]
	for tier in tier_data:
		var t: MeshInstance3D = MeshInstance3D.new()
		var tm: CylinderMesh = CylinderMesh.new()
		tm.top_radius = tier["top"]
		tm.bottom_radius = tier["bot"]
		tm.height = tier["h"]
		t.mesh = tm
		t.material_override = rock_mat
		t.position = Vector3(0, tier["y"], 0)
		peak.add_child(t)
	# Top giant amber crystal
	var crystal: MeshInstance3D = MeshInstance3D.new()
	var crm: PrismMesh = PrismMesh.new()
	crm.size = Vector3(1.40, 3.40, 1.40)
	crystal.mesh = crm
	crystal.material_override = crystal_mat
	crystal.position = Vector3(0, 17.85, 0)
	peak.add_child(crystal)
	# Pulse + spin the crystal
	var ts: Tween = crystal.create_tween().set_loops()
	ts.tween_property(crystal, "rotation_degrees:y", 360.0, 12.0)
	ts.tween_property(crystal, "rotation_degrees:y", 0.0, 0.0)
	var tp: Tween = crystal.create_tween().set_loops()
	tp.tween_property(crystal, "scale", Vector3.ONE * 1.20, 1.6)
	tp.tween_property(crystal, "scale", Vector3.ONE * 0.85, 1.6)
	# 8 orbiting stone fragments around the crystal
	var halo_pivot: Node3D = Node3D.new()
	halo_pivot.position = Vector3(0, 17.85, 0)
	peak.add_child(halo_pivot)
	for i in 8:
		var ang: float = (TAU / 8.0) * i
		var frag: MeshInstance3D = MeshInstance3D.new()
		var fm: BoxMesh = BoxMesh.new()
		fm.size = Vector3(0.55, 0.55, 0.55)
		frag.mesh = fm
		frag.material_override = rock_mat
		frag.position = Vector3(cos(ang) * 2.85, 0, sin(ang) * 2.85)
		frag.rotation_degrees = Vector3(randf_range(-30, 30), randf_range(0, 360), randf_range(-30, 30))
		halo_pivot.add_child(frag)
	var trot: Tween = halo_pivot.create_tween().set_loops()
	trot.tween_property(halo_pivot, "rotation_degrees:y", 360.0, 14.0)
	trot.tween_property(halo_pivot, "rotation_degrees:y", 0.0, 0.0)
	# Vertical aura beam reaching upward
	var beam: MeshInstance3D = MeshInstance3D.new()
	var beam_m: CylinderMesh = CylinderMesh.new()
	beam_m.top_radius = 0.30
	beam_m.bottom_radius = 0.95
	beam_m.height = 18.0
	beam.mesh = beam_m
	var beam_mat: StandardMaterial3D = StandardMaterial3D.new()
	beam_mat.albedo_color = Color(1.0, 0.65, 0.30, 0.45)
	beam_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	beam_mat.emission_enabled = true
	beam_mat.emission = Color(1.0, 0.55, 0.20)
	beam_mat.emission_energy_multiplier = 1.8
	beam_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	beam.material_override = beam_mat
	beam.position = Vector3(0, 28.85, 0)
	peak.add_child(beam)
	# Pulse beam
	var twb: Tween = beam.create_tween().set_loops()
	twb.tween_property(beam, "scale:x", 1.30, 2.0)
	twb.tween_property(beam, "scale:x", 0.85, 2.0)
	# Massive central light
	var light: OmniLight3D = OmniLight3D.new()
	light.light_color = Color(1.0, 0.65, 0.20)
	light.light_energy = 5.5
	light.omni_range = 26.0
	light.position = Vector3(0, 9.0, 0)
	peak.add_child(light)
	# Peak collision (single capsule covering all)
	var sb: StaticBody3D = StaticBody3D.new()
	sb.position = Vector3(0, 9.0, 0)
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cap: CylinderShape3D = CylinderShape3D.new()
	cap.radius = 2.85
	cap.height = 17.0
	cs.shape = cap
	sb.add_child(cs)
	peak.add_child(sb)


static func _build_d7_district_plaque(geom: Node) -> void:
	## Epic-7 T98: dedication plaque on a stone pedestal at the entrance.
	var plaque: Node3D = Node3D.new()
	plaque.name = "D7Plaque"
	plaque.position = Vector3(D7_CENTER.x - 32.0, 0.0, 4.0)
	geom.add_child(plaque)
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.55, 0.45, 0.30)
	stone_mat.roughness = 0.92
	# Pedestal
	var ped: MeshInstance3D = MeshInstance3D.new()
	var pm: BoxMesh = BoxMesh.new()
	pm.size = Vector3(0.85, 1.20, 0.55)
	ped.mesh = pm
	ped.material_override = stone_mat
	ped.position = Vector3(0, 0.60, 0)
	plaque.add_child(ped)
	# Plaque face (brass)
	var face: MeshInstance3D = MeshInstance3D.new()
	var fm: BoxMesh = BoxMesh.new()
	fm.size = Vector3(0.75, 0.50, 0.06)
	face.mesh = fm
	var brass_mat: StandardMaterial3D = StandardMaterial3D.new()
	brass_mat.albedo_color = Color(0.85, 0.65, 0.20)
	brass_mat.metallic = 0.85
	brass_mat.roughness = 0.30
	face.material_override = brass_mat
	face.position = Vector3(0, 1.00, 0.30)
	face.rotation_degrees = Vector3(-15, 0, 0)
	plaque.add_child(face)
	var label: Label3D = Label3D.new()
	label.text = "ASCENSION SPIRES\nDistrict 07 — Iteration 07\nWhere code seeks the heights"
	label.modulate = Color(0.10, 0.05, 0.05)
	label.outline_modulate = Color(1.0, 0.85, 0.30)
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


static func _build_d7_ambient_tweak(geom: Node) -> void:
	## Epic-7 T99: warm sandstone ambient — wide amber fill light + soft
	## warm directional sun.
	var amb: Node3D = Node3D.new()
	amb.name = "D7Ambient"
	amb.position = Vector3(D7_CENTER.x, 8.0, 0.0)
	geom.add_child(amb)
	var fill: OmniLight3D = OmniLight3D.new()
	fill.light_color = Color(1.0, 0.85, 0.55)
	fill.light_energy = 0.75
	fill.omni_range = 42.0
	amb.add_child(fill)
	# Slow color cycle (warm to cool sunset)
	var tw: Tween = fill.create_tween().set_loops()
	tw.tween_property(fill, "light_color", Color(0.95, 0.65, 0.45), 8.0)
	tw.tween_property(fill, "light_color", Color(1.0, 0.85, 0.55), 8.0)
	var sun: DirectionalLight3D = DirectionalLight3D.new()
	sun.light_color = Color(1.0, 0.92, 0.75)
	sun.light_energy = 0.40
	sun.shadow_enabled = false
	sun.position = Vector3(0, 14.0, 0)
	sun.rotation_degrees = Vector3(-65, 35, 0)
	amb.add_child(sun)


static func _build_d7_mountain_sage(geom: Node) -> void:
	## Epic-7 T100: MOUNTAIN SAGE — Epic 7 finale boss. Towering monk
	## elder seated in lotus on a high stone pedestal, with a massive
	## halo of orbiting glyph stones and a glowing third eye.
	var sage: Node3D = Node3D.new()
	sage.name = "MountainSage"
	sage.position = Vector3(D7_CENTER.x + 28.0, 0.0, -22.0)
	geom.add_child(sage)
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.55, 0.45, 0.30)
	stone_mat.roughness = 0.92
	var robe_mat: StandardMaterial3D = StandardMaterial3D.new()
	robe_mat.albedo_color = Color(1.0, 0.65, 0.20)
	robe_mat.emission_enabled = true
	robe_mat.emission = Color(1.0, 0.55, 0.10)
	robe_mat.emission_energy_multiplier = 0.85
	robe_mat.roughness = 0.65
	var gold_mat: StandardMaterial3D = StandardMaterial3D.new()
	gold_mat.albedo_color = Color(1.0, 0.85, 0.30)
	gold_mat.emission_enabled = true
	gold_mat.emission = Color(1.0, 0.85, 0.20)
	gold_mat.emission_energy_multiplier = 4.0
	gold_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	# Tall stone pedestal (3-tier)
	var ped_sizes: Array = [
		Vector3(4.20, 0.55, 4.20),
		Vector3(3.40, 0.55, 3.40),
		Vector3(2.85, 0.55, 2.85),
	]
	for i in 3:
		var tier: MeshInstance3D = MeshInstance3D.new()
		var tm: BoxMesh = BoxMesh.new()
		tm.size = ped_sizes[i]
		tier.mesh = tm
		tier.material_override = stone_mat
		tier.position = Vector3(0, 0.27 + i * 0.55, 0)
		sage.add_child(tier)
	# Crossed legs (large flat sphere)
	var legs: MeshInstance3D = MeshInstance3D.new()
	var lm: SphereMesh = SphereMesh.new()
	lm.radius = 1.85
	lm.height = 1.30
	legs.mesh = lm
	legs.material_override = robe_mat
	legs.position = Vector3(0, 2.40, 0)
	legs.scale = Vector3(1.30, 0.55, 1.30)
	sage.add_child(legs)
	# Torso (rounded sphere)
	var torso: MeshInstance3D = MeshInstance3D.new()
	var tm: SphereMesh = SphereMesh.new()
	tm.radius = 1.40
	tm.height = 2.40
	torso.mesh = tm
	torso.material_override = robe_mat
	torso.position = Vector3(0, 4.20, 0)
	torso.scale = Vector3(1.0, 0.85, 0.85)
	sage.add_child(torso)
	# Head (sphere)
	var head: MeshInstance3D = MeshInstance3D.new()
	var hm: SphereMesh = SphereMesh.new()
	hm.radius = 0.85
	hm.height = 1.40
	head.mesh = hm
	var skin_mat: StandardMaterial3D = StandardMaterial3D.new()
	skin_mat.albedo_color = Color(0.95, 0.85, 0.65)
	skin_mat.roughness = 0.65
	head.material_override = skin_mat
	head.position = Vector3(0, 6.20, 0)
	sage.add_child(head)
	# Glowing third eye gem
	var third_eye: MeshInstance3D = MeshInstance3D.new()
	var em: PrismMesh = PrismMesh.new()
	em.size = Vector3(0.18, 0.30, 0.10)
	third_eye.mesh = em
	third_eye.material_override = gold_mat
	third_eye.position = Vector3(0, 6.55, 0.85)
	sage.add_child(third_eye)
	# Eye pulse
	var twe: Tween = third_eye.create_tween().set_loops()
	twe.tween_property(third_eye, "scale", Vector3.ONE * 1.30, 1.4)
	twe.tween_property(third_eye, "scale", Vector3.ONE * 0.85, 1.4)
	# Topknot
	var topknot: MeshInstance3D = MeshInstance3D.new()
	var tnm: SphereMesh = SphereMesh.new()
	tnm.radius = 0.22
	tnm.height = 0.40
	topknot.mesh = tnm
	topknot.material_override = skin_mat
	topknot.position = Vector3(0, 7.20, 0)
	sage.add_child(topknot)
	# 12 orbiting glyph stones around the head as a halo
	var halo: Node3D = Node3D.new()
	halo.position = Vector3(0, 6.20, 0)
	sage.add_child(halo)
	for i in 12:
		var ang: float = (TAU / 12.0) * i
		var glyph: MeshInstance3D = MeshInstance3D.new()
		var gmm: BoxMesh = BoxMesh.new()
		gmm.size = Vector3(0.30, 0.55, 0.10)
		glyph.mesh = gmm
		glyph.material_override = gold_mat
		glyph.position = Vector3(cos(ang) * 2.85, 0, sin(ang) * 2.85)
		glyph.rotation = Vector3(0, ang + PI * 0.5, 0)
		halo.add_child(glyph)
	# Slow halo rotation
	var trot: Tween = halo.create_tween().set_loops()
	trot.tween_property(halo, "rotation_degrees:y", 360.0, 16.0)
	trot.tween_property(halo, "rotation_degrees:y", 0.0, 0.0)
	# Massive aura light
	var light: OmniLight3D = OmniLight3D.new()
	light.light_color = Color(1.0, 0.85, 0.30)
	light.light_energy = 5.5
	light.omni_range = 22.0
	light.position = Vector3(0, 5.0, 0)
	sage.add_child(light)
	var twl: Tween = light.create_tween().set_loops()
	twl.tween_property(light, "light_energy", 7.0, 2.4)
	twl.tween_property(light, "light_energy", 4.5, 2.4)
	# Title labels
	var title: Label3D = Label3D.new()
	title.text = "THE MOUNTAIN SAGE"
	title.modulate = Color(1.0, 0.85, 0.30)
	title.outline_modulate = Color(0.20, 0.10, 0.05)
	title.outline_size = 14
	title.font_size = 84
	title.pixel_size = 0.014
	title.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	title.position = Vector3(0, 9.0, 0)
	sage.add_child(title)
	var subtitle: Label3D = Label3D.new()
	subtitle.text = "Eternal in lotus, between iterations"
	subtitle.modulate = Color(0.95, 0.92, 0.85)
	subtitle.outline_modulate = Color(0.20, 0.10, 0.05)
	subtitle.outline_size = 8
	subtitle.font_size = 42
	subtitle.pixel_size = 0.011
	subtitle.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	subtitle.position = Vector3(0, 8.30, 0)
	sage.add_child(subtitle)
	# Body collision
	var sb: StaticBody3D = StaticBody3D.new()
	sb.position = Vector3(0, 4.20, 0)
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cap: CapsuleShape3D = CapsuleShape3D.new()
	cap.radius = 2.0
	cap.height = 7.40
	cs.shape = cap
	sb.add_child(cs)
	sage.add_child(sb)
	# Pedestal collision
	var psb: StaticBody3D = StaticBody3D.new()
	psb.position = Vector3(0, 0.85, 0)
	var pcs: CollisionShape3D = CollisionShape3D.new()
	var pcb: BoxShape3D = BoxShape3D.new()
	pcb.size = Vector3(4.20, 1.65, 4.20)
	pcs.shape = pcb
	psb.add_child(pcs)
	sage.add_child(psb)
