class_name D9Builder
extends Node
## Volcanic Forge district builder — extracted from scenes/town/town.gd to keep
## the main town script modular and under control. All build helpers here are
## static and called from town.gd's _build_district_9() entry function.
##
## NPC helpers receive `town: Node` so they can resolve %NPCSlots; geom helpers
## receive `geom: Node` (the town's Geometry node). All other helpers are
## self-contained and only use Godot built-ins.

const D9_CENTER := Vector3(680, 0, 0)


func extend_boundary(geom: Node) -> void:
	## Push the east boundary wall from x=630 out to x=760 to make room for D9.
	var east_wall: CSGBox3D = geom.get_node_or_null("BoundaryEast") as CSGBox3D
	if east_wall:
		east_wall.position.x = 760.0


func build(town: Node, geom: Node) -> void:
	## Entry point — called from town.gd::_build_district_9(geom).
	print("[D9Builder] start")
	extend_boundary(geom)
	_build_d9_ground(geom)
	_build_d9_forge_gate(geom)
	_build_d9_great_forge_heart(geom)
	_build_d9_forge_master_npc(town)
	_build_d9_anvil_row(geom)
	_build_d9_apprentice_smith_npc(town)
	_build_d9_quench_barrels(geom)
	_build_d9_coal_piles(geom)
	_build_d9_giant_bellows(geom)
	_build_d9_lava_channels(geom)
	_build_d9_ore_cart(geom)
	_build_d9_miner_npc(town)
	_build_d9_smelting_furnace(geom)
	_build_d9_tool_rack(geom)
	_build_d9_iron_golem(geom)
	_build_d9_lava_pool(geom)
	_build_d9_forging_table(geom)
	_build_d9_weapon_mannequin(geom)
	_build_d9_soot_vents(geom)
	_build_d9_weapon_stall(geom)
	_build_d9_weapon_vendor_npc(town)
	_build_d9_smelter_pots(geom)
	_build_d9_repair_station(geom)
	_build_d9_ingot_stacks(geom)
	_build_d9_forge_engineer_npc(town)
	_build_d9_steam_pipes(geom)
	_build_d9_drilling_rig(geom)
	_build_d9_spark_waterfall(geom)
	_build_d9_cart_yard(geom)
	_build_d9_massive_crucible(geom)
	_build_d9_crucible_operator_npc(town)
	_build_d9_forge_spirits(geom)
	_build_d9_iron_rod_rack(geom)
	_build_d9_slag_heap(geom)
	_build_d9_obsidian_shards(geom)
	_build_d9_lava_lake(geom)
	_build_d9_geode_display(geom)
	_build_d9_forge_sage_npc(town)
	_build_d9_brimstone_fumaroles(geom)
	_build_d9_training_arena(geom)
	_build_d9_iron_dummy(geom)
	_build_d9_battle_smith_npc(town)
	_build_d9_practice_weapon_stand(geom)
	_build_d9_cooling_rack(geom)
	_build_d9_lava_forge_cracks(geom)
	_build_d9_chained_anvil_totem(geom)
	_build_d9_scorched_bone_pile(geom)
	_build_d9_smelter_trap_pillars(geom)
	_build_d9_molten_behemoth_midboss(geom)
	_build_d9_sky_lava_lantern(geom)
	_build_d9_forge_sentry_mech(geom)
	_build_d9_molten_cascade(geom)
	_build_d9_forge_priestess_npc(town)
	_build_d9_basalt_stepping_stones(geom)
	_build_d9_ember_elemental(geom)
	_build_d9_forge_anvil_shrine(geom)
	_build_d9_slag_golem_patroller(geom)
	_build_d9_forge_cart_caravan(geom)
	print("[D9Builder] done")


func _build_d9_ground(geom: Node) -> void:
	## Epic-9 T1b: D9 ground — dark cracked basalt with glowing magma veins
	## and a faint orange emission. Replaces the green grass plane at the D9
	## center patch and overlays cracked obsidian.
	var ground_root: Node3D = Node3D.new()
	ground_root.name = "D9VolcanicGround"
	ground_root.position = Vector3(D9_CENTER.x, 0.01, 0)
	geom.add_child(ground_root)
	# Base obsidian plane
	var base_mat: StandardMaterial3D = StandardMaterial3D.new()
	base_mat.albedo_color = Color(0.10, 0.08, 0.10)
	base_mat.metallic = 0.45
	base_mat.roughness = 0.55
	var base: MeshInstance3D = MeshInstance3D.new()
	var bm: PlaneMesh = PlaneMesh.new()
	bm.size = Vector2(80, 40)
	base.mesh = bm
	base.material_override = base_mat
	base.position = Vector3(0, 0, 0)
	ground_root.add_child(base)
	# Magma vein decals (4 long thin glowing strips crossing the ground)
	var vein_mat: StandardMaterial3D = StandardMaterial3D.new()
	vein_mat.albedo_color = Color(0.95, 0.45, 0.10)
	vein_mat.emission_enabled = true
	vein_mat.emission = Color(1.0, 0.55, 0.15)
	vein_mat.emission_energy_multiplier = 2.5
	vein_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for i in range(4):
		var vein: MeshInstance3D = MeshInstance3D.new()
		var vb: BoxMesh = BoxMesh.new()
		vb.size = Vector3(60.0, 0.06, 0.55)
		vein.mesh = vb
		vein.material_override = vein_mat
		vein.position = Vector3(0, 0.04, -12.0 + i * 8.0)
		vein.rotation_degrees = Vector3(0, float(i) * 6.0 - 9.0, 0)
		ground_root.add_child(vein)
		# Pulse the emission slightly per vein
		var pulse: Tween = vein.create_tween().set_loops()
		var off: float = float(i) * 0.3
		pulse.tween_property(vein_mat, "emission_energy_multiplier", 3.5, 1.6 + off)
		pulse.tween_property(vein_mat, "emission_energy_multiplier", 1.8, 1.6 + off)
	# 12 scattered scorch patches (small dark circles with red embers)
	for i in range(12):
		var patch: MeshInstance3D = MeshInstance3D.new()
		var pm: CylinderMesh = CylinderMesh.new()
		pm.top_radius = 1.20 + randf() * 0.6
		pm.bottom_radius = 1.20 + randf() * 0.6
		pm.height = 0.04
		patch.mesh = pm
		var pmat: StandardMaterial3D = StandardMaterial3D.new()
		pmat.albedo_color = Color(0.22, 0.10, 0.05)
		pmat.emission_enabled = true
		pmat.emission = Color(0.85, 0.30, 0.10)
		pmat.emission_energy_multiplier = 0.55
		patch.material_override = pmat
		patch.position = Vector3(-30.0 + i * 5.0, 0.05, -10.0 + float(i % 4) * 5.0)
		ground_root.add_child(patch)
	# Ambient orange light source for the district
	var amb: OmniLight3D = OmniLight3D.new()
	amb.light_color = Color(1.0, 0.55, 0.18)
	amb.light_energy = 1.4
	amb.omni_range = 30.0
	amb.position = Vector3(0, 8, 0)
	ground_root.add_child(amb)


func _build_d9_forge_gate(geom: Node) -> void:
	## Epic-9 T2: massive stone forge gate — twin obsidian pylons with
	## glowing rune-engraved arch and molten core dripping from the keystone.
	var gate: Node3D = Node3D.new()
	gate.name = "D9ForgeGate"
	gate.position = Vector3(D9_CENTER.x - 30, 0, 0)
	geom.add_child(gate)
	# Obsidian material
	var stone: StandardMaterial3D = StandardMaterial3D.new()
	stone.albedo_color = Color(0.12, 0.10, 0.12)
	stone.metallic = 0.55
	stone.roughness = 0.45
	# Two pylons
	for sx in [-3.0, 3.0]:
		var pylon: MeshInstance3D = MeshInstance3D.new()
		var pb: BoxMesh = BoxMesh.new()
		pb.size = Vector3(1.6, 7.5, 1.6)
		pylon.mesh = pb
		pylon.material_override = stone
		pylon.position = Vector3(sx, 3.75, 0)
		gate.add_child(pylon)
		# Per-pylon collision
		var sb: StaticBody3D = StaticBody3D.new()
		sb.position = Vector3(sx, 3.75, 0)
		var cs: CollisionShape3D = CollisionShape3D.new()
		var bs: BoxShape3D = BoxShape3D.new()
		bs.size = Vector3(1.6, 7.5, 1.6)
		cs.shape = bs
		sb.add_child(cs)
		gate.add_child(sb)
	# Arch lintel across the top (long box)
	var lintel: MeshInstance3D = MeshInstance3D.new()
	var lb: BoxMesh = BoxMesh.new()
	lb.size = Vector3(8.0, 1.20, 1.40)
	lintel.mesh = lb
	lintel.material_override = stone
	lintel.position = Vector3(0, 8.10, 0)
	gate.add_child(lintel)
	# Glowing rune-engraved emissive band on the lintel
	var rune_mat: StandardMaterial3D = StandardMaterial3D.new()
	rune_mat.albedo_color = Color(0.95, 0.50, 0.15)
	rune_mat.emission_enabled = true
	rune_mat.emission = Color(1.0, 0.55, 0.20)
	rune_mat.emission_energy_multiplier = 3.0
	rune_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for sz in [-0.72, 0.72]:
		var band: MeshInstance3D = MeshInstance3D.new()
		var bbm: BoxMesh = BoxMesh.new()
		bbm.size = Vector3(7.6, 0.18, 0.05)
		band.mesh = bbm
		band.material_override = rune_mat
		band.position = Vector3(0, 8.10, sz)
		gate.add_child(band)
	# Six rune cubes spaced along the lintel front
	for i in range(6):
		var rune: MeshInstance3D = MeshInstance3D.new()
		var rb: BoxMesh = BoxMesh.new()
		rb.size = Vector3(0.40, 0.40, 0.06)
		rune.mesh = rb
		rune.material_override = rune_mat
		rune.position = Vector3(-3.0 + i * 1.2, 8.10, 0.74)
		gate.add_child(rune)
		var pulse: Tween = rune.create_tween().set_loops()
		var phase: float = float(i) * 0.18
		pulse.tween_property(rune, "scale", Vector3(1.15, 1.15, 1.0), 0.7 + phase)
		pulse.tween_property(rune, "scale", Vector3(0.85, 0.85, 1.0), 0.7 + phase)
	# Molten keystone (spherical orange glowing core under the lintel center)
	var key_mat: StandardMaterial3D = StandardMaterial3D.new()
	key_mat.albedo_color = Color(1.0, 0.40, 0.10)
	key_mat.emission_enabled = true
	key_mat.emission = Color(1.0, 0.55, 0.18)
	key_mat.emission_energy_multiplier = 4.5
	key_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var keystone: MeshInstance3D = MeshInstance3D.new()
	var ksm: SphereMesh = SphereMesh.new()
	ksm.radius = 0.55
	ksm.height = 1.10
	keystone.mesh = ksm
	keystone.material_override = key_mat
	keystone.position = Vector3(0, 7.20, 0)
	gate.add_child(keystone)
	var key_pulse: Tween = keystone.create_tween().set_loops()
	key_pulse.tween_property(key_mat, "emission_energy_multiplier", 6.5, 1.2)
	key_pulse.tween_property(key_mat, "emission_energy_multiplier", 3.0, 1.2)
	# Strong orange light at the keystone
	var lt: OmniLight3D = OmniLight3D.new()
	lt.light_color = Color(1.0, 0.55, 0.18)
	lt.light_energy = 4.5
	lt.omni_range = 14.0
	lt.position = Vector3(0, 7.20, 0)
	gate.add_child(lt)
	# Spark particles falling from the keystone
	var sparks: GPUParticles3D = GPUParticles3D.new()
	sparks.position = Vector3(0, 6.80, 0)
	sparks.amount = 60
	sparks.lifetime = 1.8
	var pm: ParticleProcessMaterial = ParticleProcessMaterial.new()
	pm.direction = Vector3(0, -1, 0)
	pm.spread = 35.0
	pm.initial_velocity_min = 0.55
	pm.initial_velocity_max = 1.2
	pm.gravity = Vector3(0, -3.0, 0)
	pm.scale_min = 0.06
	pm.scale_max = 0.14
	pm.color = Color(1.0, 0.55, 0.18, 1.0)
	sparks.process_material = pm
	var spark_mesh: SphereMesh = SphereMesh.new()
	spark_mesh.radius = 0.05
	spark_mesh.height = 0.10
	sparks.draw_pass_1 = spark_mesh
	gate.add_child(sparks)


func _build_d9_great_forge_heart(geom: Node) -> void:
	## Epic-9 T3: GREAT FORGE HEART — massive central molten core surrounded
	## by stone pillars and a chained ring, the iconic landmark of D9.
	var heart: Node3D = Node3D.new()
	heart.name = "D9GreatForgeHeart"
	heart.position = Vector3(D9_CENTER.x, 0, 0)
	geom.add_child(heart)
	# Stone basin (wide cylinder)
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.18, 0.14, 0.16)
	stone_mat.roughness = 0.85
	var basin: MeshInstance3D = MeshInstance3D.new()
	var bcm: CylinderMesh = CylinderMesh.new()
	bcm.top_radius = 4.5
	bcm.bottom_radius = 5.2
	bcm.height = 1.40
	basin.mesh = bcm
	basin.material_override = stone_mat
	basin.position = Vector3(0, 0.70, 0)
	heart.add_child(basin)
	# Inner molten lava pool (smaller cylinder, emissive)
	var lava_mat: StandardMaterial3D = StandardMaterial3D.new()
	lava_mat.albedo_color = Color(1.0, 0.40, 0.10)
	lava_mat.emission_enabled = true
	lava_mat.emission = Color(1.0, 0.60, 0.20)
	lava_mat.emission_energy_multiplier = 3.5
	lava_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var lava: MeshInstance3D = MeshInstance3D.new()
	var lcm: CylinderMesh = CylinderMesh.new()
	lcm.top_radius = 3.8
	lcm.bottom_radius = 3.8
	lcm.height = 0.20
	lava.mesh = lcm
	lava.material_override = lava_mat
	lava.position = Vector3(0, 1.45, 0)
	heart.add_child(lava)
	# Central rising molten core (large sphere floating above the lava)
	var core_mat: StandardMaterial3D = StandardMaterial3D.new()
	core_mat.albedo_color = Color(1.0, 0.45, 0.12)
	core_mat.emission_enabled = true
	core_mat.emission = Color(1.0, 0.62, 0.20)
	core_mat.emission_energy_multiplier = 5.0
	core_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var core: MeshInstance3D = MeshInstance3D.new()
	var csm: SphereMesh = SphereMesh.new()
	csm.radius = 1.85
	csm.height = 3.7
	core.mesh = csm
	core.material_override = core_mat
	core.position = Vector3(0, 4.40, 0)
	heart.add_child(core)
	# Bob + pulse the core
	var bob: Tween = core.create_tween().set_loops()
	bob.tween_property(core, "position:y", 4.95, 2.5)
	bob.tween_property(core, "position:y", 4.40, 2.5)
	var pulse: Tween = core.create_tween().set_loops()
	pulse.tween_property(core_mat, "emission_energy_multiplier", 7.5, 1.4)
	pulse.tween_property(core_mat, "emission_energy_multiplier", 3.5, 1.4)
	# Strong orange omni light at the core
	var lt: OmniLight3D = OmniLight3D.new()
	lt.light_color = Color(1.0, 0.55, 0.18)
	lt.light_energy = 7.0
	lt.omni_range = 22.0
	lt.position = Vector3(0, 4.40, 0)
	heart.add_child(lt)
	# 8 stone pillars surrounding the basin in a ring
	for i in range(8):
		var ang: float = float(i) * (TAU / 8.0)
		var radius: float = 7.5
		var pillar: MeshInstance3D = MeshInstance3D.new()
		var pcm: CylinderMesh = CylinderMesh.new()
		pcm.top_radius = 0.55
		pcm.bottom_radius = 0.70
		pcm.height = 4.5
		pillar.mesh = pcm
		pillar.material_override = stone_mat
		pillar.position = Vector3(cos(ang) * radius, 2.25, sin(ang) * radius)
		heart.add_child(pillar)
		# Iron cap with glowing rune
		var cap_mat: StandardMaterial3D = StandardMaterial3D.new()
		cap_mat.albedo_color = Color(0.55, 0.30, 0.12)
		cap_mat.emission_enabled = true
		cap_mat.emission = Color(1.0, 0.55, 0.18)
		cap_mat.emission_energy_multiplier = 1.5
		var cap: MeshInstance3D = MeshInstance3D.new()
		var ccm: CylinderMesh = CylinderMesh.new()
		ccm.top_radius = 0.70
		ccm.bottom_radius = 0.70
		ccm.height = 0.18
		cap.mesh = ccm
		cap.material_override = cap_mat
		cap.position = Vector3(cos(ang) * radius, 4.60, sin(ang) * radius)
		heart.add_child(cap)
		# Pillar collision
		var sb: StaticBody3D = StaticBody3D.new()
		sb.position = Vector3(cos(ang) * radius, 2.25, sin(ang) * radius)
		var cs: CollisionShape3D = CollisionShape3D.new()
		var cap_shape: CapsuleShape3D = CapsuleShape3D.new()
		cap_shape.radius = 0.70
		cap_shape.height = 4.5
		cs.shape = cap_shape
		sb.add_child(cs)
		heart.add_child(sb)
	# Iron chain torus links between pillars
	var iron_mat: StandardMaterial3D = StandardMaterial3D.new()
	iron_mat.albedo_color = Color(0.20, 0.18, 0.18)
	iron_mat.metallic = 0.85
	iron_mat.roughness = 0.40
	for i in range(8):
		var ang_a: float = float(i) * (TAU / 8.0)
		var ang_b: float = float(i + 1) * (TAU / 8.0)
		var mid: Vector3 = Vector3(
			(cos(ang_a) + cos(ang_b)) * 0.5 * 7.5,
			3.0,
			(sin(ang_a) + sin(ang_b)) * 0.5 * 7.5
		)
		var link: MeshInstance3D = MeshInstance3D.new()
		var tm: TorusMesh = TorusMesh.new()
		tm.inner_radius = 0.22
		tm.outer_radius = 0.32
		link.mesh = tm
		link.material_override = iron_mat
		link.position = mid
		link.rotation_degrees = Vector3(90, -rad_to_deg((ang_a + ang_b) * 0.5), 0)
		heart.add_child(link)
	# Heat haze ember particles rising from the lava
	var embers: GPUParticles3D = GPUParticles3D.new()
	embers.position = Vector3(0, 1.55, 0)
	embers.amount = 120
	embers.lifetime = 3.5
	var pm: ParticleProcessMaterial = ParticleProcessMaterial.new()
	pm.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_RING
	pm.emission_ring_radius = 3.6
	pm.emission_ring_inner_radius = 1.5
	pm.emission_ring_height = 0.10
	pm.direction = Vector3(0, 1, 0)
	pm.spread = 12.0
	pm.initial_velocity_min = 0.85
	pm.initial_velocity_max = 1.65
	pm.gravity = Vector3(0, 0.15, 0)
	pm.scale_min = 0.10
	pm.scale_max = 0.22
	pm.color = Color(1.0, 0.55, 0.18, 0.85)
	embers.process_material = pm
	var ember_mesh: SphereMesh = SphereMesh.new()
	ember_mesh.radius = 0.10
	ember_mesh.height = 0.20
	embers.draw_pass_1 = ember_mesh
	heart.add_child(embers)
	# Basin collision
	var stb: StaticBody3D = StaticBody3D.new()
	stb.position = Vector3(0, 0.70, 0)
	var bcs: CollisionShape3D = CollisionShape3D.new()
	var cyl: CylinderShape3D = CylinderShape3D.new()
	cyl.radius = 5.2
	cyl.height = 1.40
	bcs.shape = cyl
	stb.add_child(bcs)
	heart.add_child(stb)


func _build_d9_forge_master_npc(town: Node) -> void:
	## Epic-9 T4: Forge Master Vulcan — D9 hero NPC. Stone-skinned blacksmith
	## with a heavy iron hammer and a glowing forge apron.
	var slots: Node3D = town.get_node_or_null("NPCSlots") as Node3D
	if slots == null:
		return
	var slot: Marker3D = Marker3D.new()
	slot.name = "D9ForgeMasterSlot"
	slot.position = Vector3(D9_CENTER.x - 12, 0, 4)
	slots.add_child(slot)
	var npc_scene: PackedScene = load("res://scenes/entities/npcs/VillagerR3.tscn") as PackedScene
	if npc_scene == null:
		return
	var npc: Node3D = npc_scene.instantiate() as Node3D
	npc.name = "D9ForgeMaster"
	if "npc_name" in npc:
		npc.set("npc_name", "Forge Master Vulcan")
	if "npc_id" in npc:
		npc.set("npc_id", "d9_forge_master")
	slot.add_child(npc)
	# Stone-grey skin overlay (thick chest box, dark)
	var skin_mat: StandardMaterial3D = StandardMaterial3D.new()
	skin_mat.albedo_color = Color(0.32, 0.28, 0.25)
	skin_mat.roughness = 0.85
	var torso: MeshInstance3D = MeshInstance3D.new()
	var tb: BoxMesh = BoxMesh.new()
	tb.size = Vector3(1.05, 1.10, 0.65)
	torso.mesh = tb
	torso.material_override = skin_mat
	torso.position = Vector3(0, 1.10, 0)
	npc.add_child(torso)
	# Glowing forge apron (orange emissive front plate)
	var apron_mat: StandardMaterial3D = StandardMaterial3D.new()
	apron_mat.albedo_color = Color(0.55, 0.20, 0.08)
	apron_mat.emission_enabled = true
	apron_mat.emission = Color(1.0, 0.50, 0.15)
	apron_mat.emission_energy_multiplier = 1.4
	var apron: MeshInstance3D = MeshInstance3D.new()
	var ab: BoxMesh = BoxMesh.new()
	ab.size = Vector3(0.95, 1.30, 0.08)
	apron.mesh = ab
	apron.material_override = apron_mat
	apron.position = Vector3(0, 0.95, 0.36)
	npc.add_child(apron)
	# Iron rivets across the apron
	var iron_mat: StandardMaterial3D = StandardMaterial3D.new()
	iron_mat.albedo_color = Color(0.20, 0.18, 0.20)
	iron_mat.metallic = 0.90
	iron_mat.roughness = 0.30
	for sx in [-0.30, 0.30]:
		for sy in [0.30, -0.10, -0.50]:
			var rivet: MeshInstance3D = MeshInstance3D.new()
			var rsm: SphereMesh = SphereMesh.new()
			rsm.radius = 0.05
			rsm.height = 0.08
			rivet.mesh = rsm
			rivet.material_override = iron_mat
			rivet.position = Vector3(sx, 0.95 + sy, 0.42)
			npc.add_child(rivet)
	# Heavy iron hammer held in right hand
	var hammer_root: Node3D = Node3D.new()
	hammer_root.position = Vector3(0.55, 1.05, 0.20)
	hammer_root.rotation_degrees = Vector3(0, 0, -25)
	npc.add_child(hammer_root)
	# Hammer haft (wooden)
	var wood_mat: StandardMaterial3D = StandardMaterial3D.new()
	wood_mat.albedo_color = Color(0.45, 0.30, 0.18)
	wood_mat.roughness = 0.85
	var haft: MeshInstance3D = MeshInstance3D.new()
	var hcm: CylinderMesh = CylinderMesh.new()
	hcm.top_radius = 0.06
	hcm.bottom_radius = 0.07
	hcm.height = 1.10
	haft.mesh = hcm
	haft.material_override = wood_mat
	haft.position = Vector3(0, 0, 0)
	hammer_root.add_child(haft)
	# Hammer head (iron block, glowing edge)
	var head_mat: StandardMaterial3D = StandardMaterial3D.new()
	head_mat.albedo_color = Color(0.22, 0.20, 0.20)
	head_mat.metallic = 0.92
	head_mat.roughness = 0.30
	head_mat.emission_enabled = true
	head_mat.emission = Color(1.0, 0.45, 0.12)
	head_mat.emission_energy_multiplier = 0.85
	var head: MeshInstance3D = MeshInstance3D.new()
	var hb: BoxMesh = BoxMesh.new()
	hb.size = Vector3(0.55, 0.30, 0.30)
	head.mesh = hb
	head.material_override = head_mat
	head.position = Vector3(0, 0.55, 0)
	hammer_root.add_child(head)
	# Forge helmet (dark visor with cyan slit)
	var helm_mat: StandardMaterial3D = StandardMaterial3D.new()
	helm_mat.albedo_color = Color(0.18, 0.18, 0.20)
	helm_mat.metallic = 0.7
	helm_mat.roughness = 0.4
	var helm: MeshInstance3D = MeshInstance3D.new()
	var hsm: SphereMesh = SphereMesh.new()
	hsm.radius = 0.34
	hsm.height = 0.55
	helm.mesh = hsm
	helm.material_override = helm_mat
	helm.position = Vector3(0, 1.95, 0)
	npc.add_child(helm)
	# Visor slit (cyan emissive)
	var slit_mat: StandardMaterial3D = StandardMaterial3D.new()
	slit_mat.albedo_color = Color(0.30, 0.85, 0.95)
	slit_mat.emission_enabled = true
	slit_mat.emission = Color(0.40, 0.95, 1.0)
	slit_mat.emission_energy_multiplier = 2.0
	slit_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var slit: MeshInstance3D = MeshInstance3D.new()
	var slm: BoxMesh = BoxMesh.new()
	slm.size = Vector3(0.42, 0.06, 0.04)
	slit.mesh = slm
	slit.material_override = slit_mat
	slit.position = Vector3(0, 1.95, 0.32)
	npc.add_child(slit)


func _build_d9_anvil_row(geom: Node) -> void:
	## Epic-9 T6: row of 3 working anvils with hammers laid on top.
	var row: Node3D = Node3D.new()
	row.name = "D9AnvilRow"
	row.position = Vector3(D9_CENTER.x - 14, 0, -6)
	geom.add_child(row)
	var iron: StandardMaterial3D = StandardMaterial3D.new()
	iron.albedo_color = Color(0.20, 0.18, 0.20)
	iron.metallic = 0.92
	iron.roughness = 0.30
	var wood: StandardMaterial3D = StandardMaterial3D.new()
	wood.albedo_color = Color(0.45, 0.30, 0.18)
	wood.roughness = 0.85
	for i in range(3):
		var anvil_root: Node3D = Node3D.new()
		anvil_root.position = Vector3(i * 3.0, 0, 0)
		row.add_child(anvil_root)
		# Wooden stump base
		var stump: MeshInstance3D = MeshInstance3D.new()
		var sm: CylinderMesh = CylinderMesh.new()
		sm.top_radius = 0.40
		sm.bottom_radius = 0.45
		sm.height = 0.85
		stump.mesh = sm
		stump.material_override = wood
		stump.position = Vector3(0, 0.42, 0)
		anvil_root.add_child(stump)
		# Anvil body (top trapezoid via prism + base box)
		var base: MeshInstance3D = MeshInstance3D.new()
		var bb: BoxMesh = BoxMesh.new()
		bb.size = Vector3(0.50, 0.18, 0.30)
		base.mesh = bb
		base.material_override = iron
		base.position = Vector3(0, 0.95, 0)
		anvil_root.add_child(base)
		var top: MeshInstance3D = MeshInstance3D.new()
		var tb: BoxMesh = BoxMesh.new()
		tb.size = Vector3(0.85, 0.20, 0.45)
		top.mesh = tb
		top.material_override = iron
		top.position = Vector3(0, 1.16, 0)
		anvil_root.add_child(top)
		# Pointed horn (cone facing forward)
		var horn: MeshInstance3D = MeshInstance3D.new()
		var hcm: CylinderMesh = CylinderMesh.new()
		hcm.top_radius = 0.0
		hcm.bottom_radius = 0.16
		hcm.height = 0.45
		horn.mesh = hcm
		horn.material_override = iron
		horn.position = Vector3(0, 1.18, 0.45)
		horn.rotation_degrees = Vector3(90, 0, 0)
		anvil_root.add_child(horn)
		# Hammer laid on top (haft + head)
		var ham_root: Node3D = Node3D.new()
		ham_root.position = Vector3(0, 1.30, 0)
		ham_root.rotation_degrees = Vector3(0, float(i) * 30 - 30, 90)
		anvil_root.add_child(ham_root)
		var haft: MeshInstance3D = MeshInstance3D.new()
		var hfm: CylinderMesh = CylinderMesh.new()
		hfm.top_radius = 0.04
		hfm.bottom_radius = 0.05
		hfm.height = 0.65
		haft.mesh = hfm
		haft.material_override = wood
		haft.position = Vector3(0, 0, 0)
		ham_root.add_child(haft)
		var head: MeshInstance3D = MeshInstance3D.new()
		var hdb: BoxMesh = BoxMesh.new()
		hdb.size = Vector3(0.30, 0.16, 0.16)
		head.mesh = hdb
		head.material_override = iron
		head.position = Vector3(0, 0.40, 0)
		ham_root.add_child(head)
		# Glowing iron bar lying on the anvil top (orange emissive)
		var bar_mat: StandardMaterial3D = StandardMaterial3D.new()
		bar_mat.albedo_color = Color(1.0, 0.45, 0.10)
		bar_mat.emission_enabled = true
		bar_mat.emission = Color(1.0, 0.55, 0.18)
		bar_mat.emission_energy_multiplier = 2.5
		bar_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		var bar: MeshInstance3D = MeshInstance3D.new()
		var bm: BoxMesh = BoxMesh.new()
		bm.size = Vector3(0.50, 0.05, 0.07)
		bar.mesh = bm
		bar.material_override = bar_mat
		bar.position = Vector3(0, 1.30, 0.05)
		anvil_root.add_child(bar)
		var pulse: Tween = bar.create_tween().set_loops()
		pulse.tween_property(bar_mat, "emission_energy_multiplier", 4.0, 0.9 + float(i) * 0.2)
		pulse.tween_property(bar_mat, "emission_energy_multiplier", 1.5, 0.9 + float(i) * 0.2)
		# Per-anvil collision
		var sb: StaticBody3D = StaticBody3D.new()
		sb.position = Vector3(0, 0.65, 0)
		var cs: CollisionShape3D = CollisionShape3D.new()
		var bs: BoxShape3D = BoxShape3D.new()
		bs.size = Vector3(0.85, 1.40, 0.55)
		cs.shape = bs
		sb.add_child(cs)
		anvil_root.add_child(sb)


func _build_d9_apprentice_smith_npc(town: Node) -> void:
	## Epic-9 T7: apprentice smith NPC working at the anvil row.
	var slots: Node3D = town.get_node_or_null("NPCSlots") as Node3D
	if slots == null:
		return
	var slot: Marker3D = Marker3D.new()
	slot.name = "D9ApprenticeSmithSlot"
	slot.position = Vector3(D9_CENTER.x - 14, 0, -7.4)
	slots.add_child(slot)
	var npc_scene: PackedScene = load("res://scenes/entities/npcs/VillagerR3.tscn") as PackedScene
	if npc_scene == null:
		return
	var npc: Node3D = npc_scene.instantiate() as Node3D
	npc.name = "D9ApprenticeSmith"
	if "npc_name" in npc:
		npc.set("npc_name", "Apprentice Cinder")
	if "npc_id" in npc:
		npc.set("npc_id", "d9_apprentice_smith")
	slot.add_child(npc)
	# Sooty leather smock (dark brown body)
	var smock_mat: StandardMaterial3D = StandardMaterial3D.new()
	smock_mat.albedo_color = Color(0.30, 0.20, 0.12)
	smock_mat.roughness = 0.85
	var smock: MeshInstance3D = MeshInstance3D.new()
	var sb: BoxMesh = BoxMesh.new()
	sb.size = Vector3(0.85, 1.10, 0.55)
	smock.mesh = sb
	smock.material_override = smock_mat
	smock.position = Vector3(0, 1.10, 0)
	npc.add_child(smock)
	# Belt (lighter band)
	var belt_mat: StandardMaterial3D = StandardMaterial3D.new()
	belt_mat.albedo_color = Color(0.18, 0.12, 0.06)
	var belt: MeshInstance3D = MeshInstance3D.new()
	var bb: BoxMesh = BoxMesh.new()
	bb.size = Vector3(0.95, 0.10, 0.65)
	belt.mesh = bb
	belt.material_override = belt_mat
	belt.position = Vector3(0, 0.85, 0)
	npc.add_child(belt)
	# Brass belt buckle
	var brass: StandardMaterial3D = StandardMaterial3D.new()
	brass.albedo_color = Color(0.85, 0.65, 0.20)
	brass.metallic = 0.95
	brass.roughness = 0.20
	var buckle: MeshInstance3D = MeshInstance3D.new()
	var bkb: BoxMesh = BoxMesh.new()
	bkb.size = Vector3(0.16, 0.12, 0.04)
	buckle.mesh = bkb
	buckle.material_override = brass
	buckle.position = Vector3(0, 0.85, 0.34)
	npc.add_child(buckle)
	# Small hammer in right hand
	var wood: StandardMaterial3D = StandardMaterial3D.new()
	wood.albedo_color = Color(0.45, 0.30, 0.18)
	var iron: StandardMaterial3D = StandardMaterial3D.new()
	iron.albedo_color = Color(0.22, 0.20, 0.20)
	iron.metallic = 0.90
	iron.roughness = 0.30
	var hammer_root: Node3D = Node3D.new()
	hammer_root.position = Vector3(0.55, 1.05, 0.20)
	hammer_root.rotation_degrees = Vector3(0, 0, -45)
	npc.add_child(hammer_root)
	var haft: MeshInstance3D = MeshInstance3D.new()
	var hfm: CylinderMesh = CylinderMesh.new()
	hfm.top_radius = 0.04
	hfm.bottom_radius = 0.05
	hfm.height = 0.55
	haft.mesh = hfm
	haft.material_override = wood
	haft.position = Vector3(0, 0, 0)
	hammer_root.add_child(haft)
	var head: MeshInstance3D = MeshInstance3D.new()
	var hdb: BoxMesh = BoxMesh.new()
	hdb.size = Vector3(0.22, 0.14, 0.14)
	head.mesh = hdb
	head.material_override = iron
	head.position = Vector3(0, 0.30, 0)
	hammer_root.add_child(head)
	# Hammer swing tween
	var swing: Tween = hammer_root.create_tween().set_loops()
	swing.tween_property(hammer_root, "rotation_degrees:z", -100.0, 0.4)
	swing.tween_property(hammer_root, "rotation_degrees:z", -45.0, 0.4)
	# Soot smudge cap (small cap)
	var cap_mat: StandardMaterial3D = StandardMaterial3D.new()
	cap_mat.albedo_color = Color(0.20, 0.15, 0.10)
	var cap: MeshInstance3D = MeshInstance3D.new()
	var ccm: CylinderMesh = CylinderMesh.new()
	ccm.top_radius = 0.30
	ccm.bottom_radius = 0.32
	ccm.height = 0.16
	cap.mesh = ccm
	cap.material_override = cap_mat
	cap.position = Vector3(0, 1.95, 0)
	npc.add_child(cap)


func _build_d9_quench_barrels(geom: Node) -> void:
	## Epic-9 T8: 3 wooden water-filled quench barrels with rising steam.
	var row: Node3D = Node3D.new()
	row.name = "D9QuenchBarrels"
	row.position = Vector3(D9_CENTER.x - 8, 0, -3)
	geom.add_child(row)
	var wood: StandardMaterial3D = StandardMaterial3D.new()
	wood.albedo_color = Color(0.45, 0.28, 0.15)
	wood.roughness = 0.85
	var iron: StandardMaterial3D = StandardMaterial3D.new()
	iron.albedo_color = Color(0.20, 0.18, 0.18)
	iron.metallic = 0.7
	iron.roughness = 0.45
	var water_mat: StandardMaterial3D = StandardMaterial3D.new()
	water_mat.albedo_color = Color(0.20, 0.45, 0.55, 0.85)
	water_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	water_mat.metallic = 0.4
	water_mat.roughness = 0.20
	for i in range(3):
		var barrel: Node3D = Node3D.new()
		barrel.position = Vector3(i * 1.4, 0, 0)
		row.add_child(barrel)
		# Body
		var body: MeshInstance3D = MeshInstance3D.new()
		var bm: CylinderMesh = CylinderMesh.new()
		bm.top_radius = 0.50
		bm.bottom_radius = 0.55
		bm.height = 1.20
		body.mesh = bm
		body.material_override = wood
		body.position = Vector3(0, 0.60, 0)
		barrel.add_child(body)
		# Iron bands
		for sy in [0.20, 0.60, 1.00]:
			var band: MeshInstance3D = MeshInstance3D.new()
			var tm: TorusMesh = TorusMesh.new()
			tm.inner_radius = 0.50
			tm.outer_radius = 0.56
			band.mesh = tm
			band.material_override = iron
			band.position = Vector3(0, sy, 0)
			barrel.add_child(band)
		# Water surface (cylinder disc inside top)
		var water: MeshInstance3D = MeshInstance3D.new()
		var wcm: CylinderMesh = CylinderMesh.new()
		wcm.top_radius = 0.46
		wcm.bottom_radius = 0.46
		wcm.height = 0.04
		water.mesh = wcm
		water.material_override = water_mat
		water.position = Vector3(0, 1.14, 0)
		barrel.add_child(water)
		# Steam GPU particles
		var steam: GPUParticles3D = GPUParticles3D.new()
		steam.position = Vector3(0, 1.20, 0)
		steam.amount = 30
		steam.lifetime = 2.8
		var pm: ParticleProcessMaterial = ParticleProcessMaterial.new()
		pm.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_RING
		pm.emission_ring_radius = 0.40
		pm.emission_ring_inner_radius = 0.0
		pm.emission_ring_height = 0.05
		pm.direction = Vector3(0, 1, 0)
		pm.spread = 18.0
		pm.initial_velocity_min = 0.45
		pm.initial_velocity_max = 0.85
		pm.gravity = Vector3(0, 0.30, 0)
		pm.scale_min = 0.20
		pm.scale_max = 0.45
		pm.color = Color(0.85, 0.92, 0.95, 0.55)
		steam.process_material = pm
		var steam_mesh: SphereMesh = SphereMesh.new()
		steam_mesh.radius = 0.18
		steam_mesh.height = 0.36
		steam.draw_pass_1 = steam_mesh
		barrel.add_child(steam)
		# Per-barrel collision
		var stb: StaticBody3D = StaticBody3D.new()
		stb.position = Vector3(0, 0.60, 0)
		var cs: CollisionShape3D = CollisionShape3D.new()
		var cyl: CylinderShape3D = CylinderShape3D.new()
		cyl.radius = 0.55
		cyl.height = 1.20
		cs.shape = cyl
		stb.add_child(cs)
		barrel.add_child(stb)


func _build_d9_coal_piles(geom: Node) -> void:
	## Epic-9 T9: 4 piles of coal nuggets at the corners of the smithing area.
	var piles: Node3D = Node3D.new()
	piles.name = "D9CoalPiles"
	piles.position = Vector3(D9_CENTER.x, 0, 0)
	geom.add_child(piles)
	var coal_mat: StandardMaterial3D = StandardMaterial3D.new()
	coal_mat.albedo_color = Color(0.06, 0.05, 0.06)
	coal_mat.metallic = 0.30
	coal_mat.roughness = 0.55
	var ember_mat: StandardMaterial3D = StandardMaterial3D.new()
	ember_mat.albedo_color = Color(0.85, 0.30, 0.10)
	ember_mat.emission_enabled = true
	ember_mat.emission = Color(1.0, 0.45, 0.12)
	ember_mat.emission_energy_multiplier = 1.5
	var spots: Array[Vector3] = [
		Vector3(-12, 0, 8),
		Vector3(12, 0, 8),
		Vector3(-12, 0, -10),
		Vector3(12, 0, -10),
	]
	for spot in spots:
		var pile: Node3D = Node3D.new()
		pile.position = spot
		piles.add_child(pile)
		# 7 coal nuggets stacked
		for j in range(7):
			var lump: MeshInstance3D = MeshInstance3D.new()
			var sm: SphereMesh = SphereMesh.new()
			sm.radius = 0.20 + randf() * 0.10
			sm.height = 0.40 + randf() * 0.18
			lump.mesh = sm
			lump.material_override = coal_mat
			lump.position = Vector3(
				-0.35 + randf() * 0.7,
				0.18 + float(j) * 0.18,
				-0.35 + randf() * 0.7
			)
			pile.add_child(lump)
		# 2 glowing embers nestled in the top
		for k in range(2):
			var ember: MeshInstance3D = MeshInstance3D.new()
			var esm: SphereMesh = SphereMesh.new()
			esm.radius = 0.10
			esm.height = 0.20
			ember.mesh = esm
			ember.material_override = ember_mat
			ember.position = Vector3(-0.15 + float(k) * 0.30, 1.40, 0)
			pile.add_child(ember)
		# Pile collision
		var stb: StaticBody3D = StaticBody3D.new()
		stb.position = Vector3(0, 0.65, 0)
		var cs: CollisionShape3D = CollisionShape3D.new()
		var cyl: CylinderShape3D = CylinderShape3D.new()
		cyl.radius = 0.85
		cyl.height = 1.30
		cs.shape = cyl
		stb.add_child(cs)
		pile.add_child(stb)


func _build_d9_giant_bellows(geom: Node) -> void:
	## Epic-9 T10: pair of giant leather bellows with wooden frames pumping
	## air into the great forge — wide leather body with iron bands and a
	## subtle compress/expand tween.
	var bellows: Node3D = Node3D.new()
	bellows.name = "D9GiantBellows"
	bellows.position = Vector3(D9_CENTER.x + 12, 0, -6)
	geom.add_child(bellows)
	var leather_mat: StandardMaterial3D = StandardMaterial3D.new()
	leather_mat.albedo_color = Color(0.42, 0.22, 0.10)
	leather_mat.roughness = 0.85
	var wood_mat: StandardMaterial3D = StandardMaterial3D.new()
	wood_mat.albedo_color = Color(0.45, 0.30, 0.18)
	wood_mat.roughness = 0.85
	var iron_mat: StandardMaterial3D = StandardMaterial3D.new()
	iron_mat.albedo_color = Color(0.20, 0.18, 0.18)
	iron_mat.metallic = 0.8
	iron_mat.roughness = 0.40
	for sx in [-2.5, 2.5]:
		var unit: Node3D = Node3D.new()
		unit.position = Vector3(sx, 0, 0)
		bellows.add_child(unit)
		# Wooden top board
		var top: MeshInstance3D = MeshInstance3D.new()
		var tb: BoxMesh = BoxMesh.new()
		tb.size = Vector3(1.85, 0.12, 1.20)
		top.mesh = tb
		top.material_override = wood_mat
		top.position = Vector3(0, 1.85, 0)
		unit.add_child(top)
		# Wooden bottom board
		var bot: MeshInstance3D = MeshInstance3D.new()
		var bb: BoxMesh = BoxMesh.new()
		bb.size = Vector3(1.85, 0.12, 1.20)
		bot.mesh = bb
		bot.material_override = wood_mat
		bot.position = Vector3(0, 0.55, 0)
		unit.add_child(bot)
		# Leather body (thick prism between top and bottom)
		var body: MeshInstance3D = MeshInstance3D.new()
		var bdb: BoxMesh = BoxMesh.new()
		bdb.size = Vector3(1.65, 1.18, 1.05)
		body.mesh = bdb
		body.material_override = leather_mat
		body.position = Vector3(0, 1.20, 0)
		unit.add_child(body)
		# Iron straps (3 horizontal bands across the leather body)
		for sy in [0.85, 1.20, 1.55]:
			var strap: MeshInstance3D = MeshInstance3D.new()
			var sbm: BoxMesh = BoxMesh.new()
			sbm.size = Vector3(1.70, 0.08, 1.10)
			strap.mesh = sbm
			strap.material_override = iron_mat
			strap.position = Vector3(0, sy, 0)
			unit.add_child(strap)
		# Nozzle pointing toward the forge heart (cylindrical pipe out the back)
		var nozzle: MeshInstance3D = MeshInstance3D.new()
		var ncm: CylinderMesh = CylinderMesh.new()
		ncm.top_radius = 0.16
		ncm.bottom_radius = 0.20
		ncm.height = 1.40
		nozzle.mesh = ncm
		nozzle.material_override = iron_mat
		nozzle.position = Vector3(-0.85 if sx < 0 else 0.85, 1.20, 0)
		nozzle.rotation_degrees = Vector3(0, 0, 90)
		unit.add_child(nozzle)
		# Long handle on top
		var handle: MeshInstance3D = MeshInstance3D.new()
		var hcm: CylinderMesh = CylinderMesh.new()
		hcm.top_radius = 0.06
		hcm.bottom_radius = 0.06
		hcm.height = 2.00
		handle.mesh = hcm
		handle.material_override = wood_mat
		handle.position = Vector3(0.90 if sx < 0 else -0.90, 2.10, 0)
		handle.rotation_degrees = Vector3(0, 0, 75)
		unit.add_child(handle)
		# Compress tween — body scales y between 0.85 and 1.0
		var tw: Tween = body.create_tween().set_loops()
		var phase: float = 0.0 if sx < 0 else 0.6
		tw.tween_property(body, "scale:y", 0.78, 1.4 + phase)
		tw.tween_property(body, "scale:y", 1.0, 1.4 + phase)
		# Per-bellows collision
		var stb: StaticBody3D = StaticBody3D.new()
		stb.position = Vector3(0, 1.20, 0)
		var cs: CollisionShape3D = CollisionShape3D.new()
		var bs: BoxShape3D = BoxShape3D.new()
		bs.size = Vector3(1.85, 1.85, 1.20)
		cs.shape = bs
		stb.add_child(cs)
		unit.add_child(stb)


func _build_d9_lava_channels(geom: Node) -> void:
	## Epic-9 T11: 3 long flowing lava channels carved into the volcanic
	## ground around the forge heart, with stone curbs and pulsing emission.
	var channels: Node3D = Node3D.new()
	channels.name = "D9LavaChannels"
	channels.position = Vector3(D9_CENTER.x, 0.05, 0)
	geom.add_child(channels)
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.18, 0.14, 0.16)
	stone_mat.roughness = 0.85
	var lava_mat: StandardMaterial3D = StandardMaterial3D.new()
	lava_mat.albedo_color = Color(1.0, 0.42, 0.10)
	lava_mat.emission_enabled = true
	lava_mat.emission = Color(1.0, 0.55, 0.18)
	lava_mat.emission_energy_multiplier = 3.5
	lava_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	# 3 channels at different angles
	var channel_data: Array = [
		[Vector3(-15, 0, -8), 0.0],
		[Vector3(0, 0, 12), 90.0],
		[Vector3(14, 0, -6), 30.0],
	]
	for ch in channel_data:
		var pos: Vector3 = ch[0]
		var ang: float = ch[1]
		var ch_root: Node3D = Node3D.new()
		ch_root.position = pos
		ch_root.rotation_degrees = Vector3(0, ang, 0)
		channels.add_child(ch_root)
		# Stone curb left
		var curb_l: MeshInstance3D = MeshInstance3D.new()
		var clb: BoxMesh = BoxMesh.new()
		clb.size = Vector3(8.0, 0.30, 0.45)
		curb_l.mesh = clb
		curb_l.material_override = stone_mat
		curb_l.position = Vector3(0, 0.15, -0.55)
		ch_root.add_child(curb_l)
		# Stone curb right
		var curb_r: MeshInstance3D = MeshInstance3D.new()
		curb_r.mesh = clb
		curb_r.material_override = stone_mat
		curb_r.position = Vector3(0, 0.15, 0.55)
		ch_root.add_child(curb_r)
		# Lava strip down the middle
		var lava: MeshInstance3D = MeshInstance3D.new()
		var lb: BoxMesh = BoxMesh.new()
		lb.size = Vector3(8.0, 0.10, 0.65)
		lava.mesh = lb
		lava.material_override = lava_mat
		lava.position = Vector3(0, 0.10, 0)
		ch_root.add_child(lava)
		var pulse: Tween = lava.create_tween().set_loops()
		pulse.tween_property(lava_mat, "emission_energy_multiplier", 5.0, 1.4)
		pulse.tween_property(lava_mat, "emission_energy_multiplier", 2.5, 1.4)


func _build_d9_ore_cart(geom: Node) -> void:
	## Epic-9 T12: mine cart on iron rails carrying glowing iron ore.
	var cart_root: Node3D = Node3D.new()
	cart_root.name = "D9OreCart"
	cart_root.position = Vector3(D9_CENTER.x - 16, 0, 8)
	geom.add_child(cart_root)
	var iron: StandardMaterial3D = StandardMaterial3D.new()
	iron.albedo_color = Color(0.22, 0.20, 0.20)
	iron.metallic = 0.85
	iron.roughness = 0.40
	var wood: StandardMaterial3D = StandardMaterial3D.new()
	wood.albedo_color = Color(0.45, 0.30, 0.18)
	wood.roughness = 0.85
	# Two long iron rails
	for sz in [-0.45, 0.45]:
		var rail: MeshInstance3D = MeshInstance3D.new()
		var rb: BoxMesh = BoxMesh.new()
		rb.size = Vector3(10.0, 0.10, 0.10)
		rail.mesh = rb
		rail.material_override = iron
		rail.position = Vector3(0, 0.05, sz)
		cart_root.add_child(rail)
	# 6 wooden ties
	for i in range(6):
		var tie: MeshInstance3D = MeshInstance3D.new()
		var tb: BoxMesh = BoxMesh.new()
		tb.size = Vector3(0.30, 0.06, 1.30)
		tie.mesh = tb
		tie.material_override = wood
		tie.position = Vector3(-4.5 + i * 1.8, 0.02, 0)
		cart_root.add_child(tie)
	# Mine cart body (wooden box on iron frame)
	var cart: Node3D = Node3D.new()
	cart.position = Vector3(0, 0.30, 0)
	cart_root.add_child(cart)
	var body: MeshInstance3D = MeshInstance3D.new()
	var bdb: BoxMesh = BoxMesh.new()
	bdb.size = Vector3(1.40, 0.85, 1.10)
	body.mesh = bdb
	body.material_override = wood
	body.position = Vector3(0, 0.55, 0)
	cart.add_child(body)
	# Iron rim around top
	var rim: MeshInstance3D = MeshInstance3D.new()
	var rb: BoxMesh = BoxMesh.new()
	rb.size = Vector3(1.50, 0.08, 1.20)
	rim.mesh = rb
	rim.material_override = iron
	rim.position = Vector3(0, 0.92, 0)
	cart.add_child(rim)
	# 4 iron wheels (torus)
	for sx in [-0.55, 0.55]:
		for sz in [-0.45, 0.45]:
			var wheel: MeshInstance3D = MeshInstance3D.new()
			var tm: TorusMesh = TorusMesh.new()
			tm.inner_radius = 0.18
			tm.outer_radius = 0.28
			wheel.mesh = tm
			wheel.material_override = iron
			wheel.position = Vector3(sx, 0.20, sz)
			wheel.rotation_degrees = Vector3(0, 0, 90)
			cart.add_child(wheel)
	# Iron ore inside (4 emissive lumps)
	var ore_mat: StandardMaterial3D = StandardMaterial3D.new()
	ore_mat.albedo_color = Color(0.55, 0.30, 0.15)
	ore_mat.metallic = 0.55
	ore_mat.roughness = 0.55
	ore_mat.emission_enabled = true
	ore_mat.emission = Color(1.0, 0.45, 0.12)
	ore_mat.emission_energy_multiplier = 0.85
	for i in range(4):
		var lump: MeshInstance3D = MeshInstance3D.new()
		var sm: SphereMesh = SphereMesh.new()
		sm.radius = 0.20 + randf() * 0.08
		sm.height = 0.40 + randf() * 0.12
		lump.mesh = sm
		lump.material_override = ore_mat
		lump.position = Vector3(-0.35 + float(i) * 0.22, 1.05, -0.20 + randf() * 0.40)
		cart.add_child(lump)
	# Cart collision
	var stb: StaticBody3D = StaticBody3D.new()
	stb.position = Vector3(0, 0.55, 0)
	var cs: CollisionShape3D = CollisionShape3D.new()
	var bs: BoxShape3D = BoxShape3D.new()
	bs.size = Vector3(1.50, 1.10, 1.20)
	cs.shape = bs
	stb.add_child(cs)
	cart.add_child(stb)


func _build_d9_miner_npc(town: Node) -> void:
	## Epic-9 T13: miner NPC with leather coat and a heavy pickaxe.
	var slots: Node3D = town.get_node_or_null("NPCSlots") as Node3D
	if slots == null:
		return
	var slot: Marker3D = Marker3D.new()
	slot.name = "D9MinerSlot"
	slot.position = Vector3(D9_CENTER.x - 18, 0, 8)
	slots.add_child(slot)
	var npc_scene: PackedScene = load("res://scenes/entities/npcs/VillagerR3.tscn") as PackedScene
	if npc_scene == null:
		return
	var npc: Node3D = npc_scene.instantiate() as Node3D
	npc.name = "D9Miner"
	if "npc_name" in npc:
		npc.set("npc_name", "Pickaxe Pete")
	if "npc_id" in npc:
		npc.set("npc_id", "d9_miner")
	slot.add_child(npc)
	# Leather coat
	var coat_mat: StandardMaterial3D = StandardMaterial3D.new()
	coat_mat.albedo_color = Color(0.38, 0.24, 0.12)
	coat_mat.roughness = 0.85
	var coat: MeshInstance3D = MeshInstance3D.new()
	var cb: BoxMesh = BoxMesh.new()
	cb.size = Vector3(0.95, 1.20, 0.55)
	coat.mesh = cb
	coat.material_override = coat_mat
	coat.position = Vector3(0, 1.05, 0)
	npc.add_child(coat)
	# Headlamp helmet (dark with cyan beam)
	var helm_mat: StandardMaterial3D = StandardMaterial3D.new()
	helm_mat.albedo_color = Color(0.20, 0.18, 0.20)
	helm_mat.metallic = 0.6
	helm_mat.roughness = 0.45
	var helm: MeshInstance3D = MeshInstance3D.new()
	var hsm: SphereMesh = SphereMesh.new()
	hsm.radius = 0.32
	hsm.height = 0.50
	helm.mesh = hsm
	helm.material_override = helm_mat
	helm.position = Vector3(0, 1.95, 0)
	npc.add_child(helm)
	# Headlamp light (cyan emissive disc + omni light)
	var lamp_mat: StandardMaterial3D = StandardMaterial3D.new()
	lamp_mat.albedo_color = Color(0.55, 0.92, 1.0)
	lamp_mat.emission_enabled = true
	lamp_mat.emission = Color(0.55, 0.92, 1.0)
	lamp_mat.emission_energy_multiplier = 3.0
	lamp_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var lamp: MeshInstance3D = MeshInstance3D.new()
	var lsm: SphereMesh = SphereMesh.new()
	lsm.radius = 0.10
	lsm.height = 0.10
	lamp.mesh = lsm
	lamp.material_override = lamp_mat
	lamp.position = Vector3(0, 2.00, 0.30)
	npc.add_child(lamp)
	var spot: OmniLight3D = OmniLight3D.new()
	spot.light_color = Color(0.55, 0.92, 1.0)
	spot.light_energy = 2.5
	spot.omni_range = 5.0
	spot.position = Vector3(0, 2.00, 0.40)
	npc.add_child(spot)
	# Pickaxe held over the shoulder
	var wood: StandardMaterial3D = StandardMaterial3D.new()
	wood.albedo_color = Color(0.45, 0.30, 0.18)
	var iron: StandardMaterial3D = StandardMaterial3D.new()
	iron.albedo_color = Color(0.22, 0.20, 0.20)
	iron.metallic = 0.90
	iron.roughness = 0.30
	var pick_root: Node3D = Node3D.new()
	pick_root.position = Vector3(0.45, 1.30, 0)
	pick_root.rotation_degrees = Vector3(0, 0, -65)
	npc.add_child(pick_root)
	# Pickaxe haft
	var haft: MeshInstance3D = MeshInstance3D.new()
	var hcm: CylinderMesh = CylinderMesh.new()
	hcm.top_radius = 0.05
	hcm.bottom_radius = 0.06
	hcm.height = 1.40
	haft.mesh = hcm
	haft.material_override = wood
	haft.position = Vector3(0, 0, 0)
	pick_root.add_child(haft)
	# Pick head (horizontal iron bar across the top)
	var ph: MeshInstance3D = MeshInstance3D.new()
	var phb: BoxMesh = BoxMesh.new()
	phb.size = Vector3(0.10, 0.10, 0.65)
	ph.mesh = phb
	ph.material_override = iron
	ph.position = Vector3(0, 0.70, 0)
	pick_root.add_child(ph)
	# Pick points (two cones)
	for sz in [-0.32, 0.32]:
		var pt: MeshInstance3D = MeshInstance3D.new()
		var pcm: CylinderMesh = CylinderMesh.new()
		pcm.top_radius = 0.0
		pcm.bottom_radius = 0.08
		pcm.height = 0.30
		pt.mesh = pcm
		pt.material_override = iron
		pt.position = Vector3(0, 0.70, sz)
		pt.rotation_degrees = Vector3(0, 0, 90 if sz < 0 else -90)
		pick_root.add_child(pt)


func _build_d9_smelting_furnace(geom: Node) -> void:
	## Epic-9 T14: tall stone smelting furnace with fire glow inside and a
	## smoke chimney venting upward.
	var furnace: Node3D = Node3D.new()
	furnace.name = "D9SmeltingFurnace"
	furnace.position = Vector3(D9_CENTER.x + 8, 0, 8)
	geom.add_child(furnace)
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.45, 0.42, 0.40)
	stone_mat.roughness = 0.85
	# Wide tapered cylindrical body
	var body: MeshInstance3D = MeshInstance3D.new()
	var bcm: CylinderMesh = CylinderMesh.new()
	bcm.top_radius = 1.20
	bcm.bottom_radius = 1.85
	bcm.height = 4.20
	body.mesh = bcm
	body.material_override = stone_mat
	body.position = Vector3(0, 2.10, 0)
	furnace.add_child(body)
	# Open mouth (dark hole at the front, lower)
	var mouth_mat: StandardMaterial3D = StandardMaterial3D.new()
	mouth_mat.albedo_color = Color(0.05, 0.04, 0.06)
	mouth_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var mouth: MeshInstance3D = MeshInstance3D.new()
	var msm: SphereMesh = SphereMesh.new()
	msm.radius = 0.65
	msm.height = 1.30
	mouth.mesh = msm
	mouth.material_override = mouth_mat
	mouth.scale = Vector3(0.85, 1.0, 0.55)
	mouth.position = Vector3(0, 1.40, 1.55)
	furnace.add_child(mouth)
	# Fire glow inside the mouth (orange emissive sphere)
	var fire_mat: StandardMaterial3D = StandardMaterial3D.new()
	fire_mat.albedo_color = Color(1.0, 0.45, 0.10)
	fire_mat.emission_enabled = true
	fire_mat.emission = Color(1.0, 0.55, 0.18)
	fire_mat.emission_energy_multiplier = 4.5
	fire_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var fire: MeshInstance3D = MeshInstance3D.new()
	var fsm: SphereMesh = SphereMesh.new()
	fsm.radius = 0.40
	fsm.height = 0.85
	fire.mesh = fsm
	fire.material_override = fire_mat
	fire.position = Vector3(0, 1.40, 1.30)
	furnace.add_child(fire)
	var pulse: Tween = fire.create_tween().set_loops()
	pulse.tween_property(fire, "scale", Vector3(1.20, 1.30, 1.20), 0.6)
	pulse.tween_property(fire, "scale", Vector3(0.88, 0.85, 0.88), 0.6)
	# Strong orange light from the mouth
	var lt: OmniLight3D = OmniLight3D.new()
	lt.light_color = Color(1.0, 0.55, 0.18)
	lt.light_energy = 3.5
	lt.omni_range = 9.0
	lt.position = Vector3(0, 1.40, 1.85)
	furnace.add_child(lt)
	# Stone chimney pipe rising from the top
	var chimney: MeshInstance3D = MeshInstance3D.new()
	var ccm: CylinderMesh = CylinderMesh.new()
	ccm.top_radius = 0.55
	ccm.bottom_radius = 0.75
	ccm.height = 2.20
	chimney.mesh = ccm
	chimney.material_override = stone_mat
	chimney.position = Vector3(0, 5.30, 0)
	furnace.add_child(chimney)
	# Smoke particles from chimney top
	var smoke: GPUParticles3D = GPUParticles3D.new()
	smoke.position = Vector3(0, 6.50, 0)
	smoke.amount = 60
	smoke.lifetime = 4.5
	var pm: ParticleProcessMaterial = ParticleProcessMaterial.new()
	pm.direction = Vector3(0, 1, 0)
	pm.spread = 22.0
	pm.initial_velocity_min = 0.65
	pm.initial_velocity_max = 1.35
	pm.gravity = Vector3(0.10, 0.45, 0)
	pm.scale_min = 0.35
	pm.scale_max = 0.85
	pm.color = Color(0.55, 0.50, 0.45, 0.65)
	smoke.process_material = pm
	var smoke_mesh: SphereMesh = SphereMesh.new()
	smoke_mesh.radius = 0.28
	smoke_mesh.height = 0.55
	smoke.draw_pass_1 = smoke_mesh
	furnace.add_child(smoke)
	# Furnace collision (capsule for the body)
	var stb: StaticBody3D = StaticBody3D.new()
	stb.position = Vector3(0, 2.10, 0)
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cap_shape: CapsuleShape3D = CapsuleShape3D.new()
	cap_shape.radius = 1.85
	cap_shape.height = 4.20
	cs.shape = cap_shape
	stb.add_child(cs)
	furnace.add_child(stb)


func _build_d9_tool_rack(geom: Node) -> void:
	## Epic-9 T15: wall-mounted tool rack with 5 smithing tools (tongs,
	## hammers, chisel, file).
	var rack: Node3D = Node3D.new()
	rack.name = "D9ToolRack"
	rack.position = Vector3(D9_CENTER.x - 6, 0, -10)
	geom.add_child(rack)
	var wood: StandardMaterial3D = StandardMaterial3D.new()
	wood.albedo_color = Color(0.45, 0.30, 0.18)
	wood.roughness = 0.85
	var iron: StandardMaterial3D = StandardMaterial3D.new()
	iron.albedo_color = Color(0.22, 0.20, 0.20)
	iron.metallic = 0.90
	iron.roughness = 0.30
	# Backboard plank
	var board: MeshInstance3D = MeshInstance3D.new()
	var bb: BoxMesh = BoxMesh.new()
	bb.size = Vector3(2.80, 1.85, 0.10)
	board.mesh = bb
	board.material_override = wood
	board.position = Vector3(0, 1.70, 0)
	rack.add_child(board)
	# Top crossbar
	var bar: MeshInstance3D = MeshInstance3D.new()
	var bbm: BoxMesh = BoxMesh.new()
	bbm.size = Vector3(2.80, 0.10, 0.18)
	bar.mesh = bbm
	bar.material_override = wood
	bar.position = Vector3(0, 2.55, 0.10)
	rack.add_child(bar)
	# 5 tools hanging from the bar
	# Tool 1: tongs (two long curved cylinders)
	for sx in [-0.04, 0.04]:
		var tong: MeshInstance3D = MeshInstance3D.new()
		var tm: CylinderMesh = CylinderMesh.new()
		tm.top_radius = 0.04
		tm.bottom_radius = 0.05
		tm.height = 1.00
		tong.mesh = tm
		tong.material_override = iron
		tong.position = Vector3(-1.10 + sx, 1.95, 0.10)
		rack.add_child(tong)
	# Tool 2: hammer
	var ham_haft: MeshInstance3D = MeshInstance3D.new()
	var hcm: CylinderMesh = CylinderMesh.new()
	hcm.top_radius = 0.05
	hcm.bottom_radius = 0.06
	hcm.height = 1.10
	ham_haft.mesh = hcm
	ham_haft.material_override = wood
	ham_haft.position = Vector3(-0.55, 1.90, 0.10)
	rack.add_child(ham_haft)
	var ham_head: MeshInstance3D = MeshInstance3D.new()
	var hdb: BoxMesh = BoxMesh.new()
	hdb.size = Vector3(0.30, 0.16, 0.16)
	ham_head.mesh = hdb
	ham_head.material_override = iron
	ham_head.position = Vector3(-0.55, 2.45, 0.10)
	rack.add_child(ham_head)
	# Tool 3: bigger sledgehammer (centered)
	var sl_haft: MeshInstance3D = MeshInstance3D.new()
	var sm: CylinderMesh = CylinderMesh.new()
	sm.top_radius = 0.07
	sm.bottom_radius = 0.08
	sm.height = 1.30
	sl_haft.mesh = sm
	sl_haft.material_override = wood
	sl_haft.position = Vector3(0, 1.85, 0.10)
	rack.add_child(sl_haft)
	var sl_head: MeshInstance3D = MeshInstance3D.new()
	var slb: BoxMesh = BoxMesh.new()
	slb.size = Vector3(0.45, 0.22, 0.22)
	sl_head.mesh = slb
	sl_head.material_override = iron
	sl_head.position = Vector3(0, 2.50, 0.10)
	rack.add_child(sl_head)
	# Tool 4: chisel
	var ch_haft: MeshInstance3D = MeshInstance3D.new()
	var cb: CylinderMesh = CylinderMesh.new()
	cb.top_radius = 0.04
	cb.bottom_radius = 0.05
	cb.height = 0.85
	ch_haft.mesh = cb
	ch_haft.material_override = wood
	ch_haft.position = Vector3(0.55, 2.05, 0.10)
	rack.add_child(ch_haft)
	var ch_blade: MeshInstance3D = MeshInstance3D.new()
	var cpm: CylinderMesh = CylinderMesh.new()
	cpm.top_radius = 0.0
	cpm.bottom_radius = 0.06
	cpm.height = 0.30
	ch_blade.mesh = cpm
	ch_blade.material_override = iron
	ch_blade.position = Vector3(0.55, 1.55, 0.10)
	rack.add_child(ch_blade)
	# Tool 5: file (long thin box)
	var file_mesh: MeshInstance3D = MeshInstance3D.new()
	var flb: BoxMesh = BoxMesh.new()
	flb.size = Vector3(0.10, 1.10, 0.06)
	file_mesh.mesh = flb
	file_mesh.material_override = iron
	file_mesh.position = Vector3(1.10, 1.95, 0.10)
	rack.add_child(file_mesh)
	# Rack collision
	var stb: StaticBody3D = StaticBody3D.new()
	stb.position = Vector3(0, 1.70, 0)
	var cs: CollisionShape3D = CollisionShape3D.new()
	var bs: BoxShape3D = BoxShape3D.new()
	bs.size = Vector3(2.80, 1.85, 0.20)
	cs.shape = bs
	stb.add_child(cs)
	rack.add_child(stb)


func _build_d9_iron_golem(geom: Node) -> void:
	## Epic-9 T16: massive standing iron golem guardian — boxy humanoid
	## construct with glowing orange forge-eyes and a hammer-fist.
	var golem: Node3D = Node3D.new()
	golem.name = "D9IronGolem"
	golem.position = Vector3(D9_CENTER.x + 4, 0, -12)
	geom.add_child(golem)
	# Iron base material
	var iron: StandardMaterial3D = StandardMaterial3D.new()
	iron.albedo_color = Color(0.30, 0.28, 0.30)
	iron.metallic = 0.92
	iron.roughness = 0.45
	# Stone-pad base
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.45, 0.42, 0.40)
	stone_mat.roughness = 0.85
	var pad: MeshInstance3D = MeshInstance3D.new()
	var pcm: CylinderMesh = CylinderMesh.new()
	pcm.top_radius = 1.65
	pcm.bottom_radius = 1.85
	pcm.height = 0.30
	pad.mesh = pcm
	pad.material_override = stone_mat
	pad.position = Vector3(0, 0.15, 0)
	golem.add_child(pad)
	# Legs (2 thick boxes)
	for sx in [-0.45, 0.45]:
		var leg: MeshInstance3D = MeshInstance3D.new()
		var lb: BoxMesh = BoxMesh.new()
		lb.size = Vector3(0.55, 1.85, 0.55)
		leg.mesh = lb
		leg.material_override = iron
		leg.position = Vector3(sx, 1.20, 0)
		golem.add_child(leg)
	# Torso (big chest box)
	var torso: MeshInstance3D = MeshInstance3D.new()
	var tb: BoxMesh = BoxMesh.new()
	tb.size = Vector3(1.85, 1.85, 1.10)
	torso.mesh = tb
	torso.material_override = iron
	torso.position = Vector3(0, 3.05, 0)
	golem.add_child(torso)
	# Glowing chest core (orange emissive disc)
	var core_mat: StandardMaterial3D = StandardMaterial3D.new()
	core_mat.albedo_color = Color(1.0, 0.45, 0.10)
	core_mat.emission_enabled = true
	core_mat.emission = Color(1.0, 0.55, 0.18)
	core_mat.emission_energy_multiplier = 3.5
	core_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var core: MeshInstance3D = MeshInstance3D.new()
	var csm: SphereMesh = SphereMesh.new()
	csm.radius = 0.40
	csm.height = 0.20
	core.mesh = csm
	core.material_override = core_mat
	core.position = Vector3(0, 3.10, 0.58)
	golem.add_child(core)
	var pulse: Tween = core.create_tween().set_loops()
	pulse.tween_property(core_mat, "emission_energy_multiplier", 5.5, 1.0)
	pulse.tween_property(core_mat, "emission_energy_multiplier", 2.0, 1.0)
	# Head (smaller iron box on top)
	var head: MeshInstance3D = MeshInstance3D.new()
	var hb: BoxMesh = BoxMesh.new()
	hb.size = Vector3(0.95, 0.85, 0.85)
	head.mesh = hb
	head.material_override = iron
	head.position = Vector3(0, 4.40, 0)
	golem.add_child(head)
	# Glowing forge eyes (2 emissive boxes)
	var eye_mat: StandardMaterial3D = StandardMaterial3D.new()
	eye_mat.albedo_color = Color(1.0, 0.55, 0.18)
	eye_mat.emission_enabled = true
	eye_mat.emission = Color(1.0, 0.62, 0.22)
	eye_mat.emission_energy_multiplier = 4.5
	eye_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for sx in [-0.20, 0.20]:
		var eye: MeshInstance3D = MeshInstance3D.new()
		var eb: BoxMesh = BoxMesh.new()
		eb.size = Vector3(0.18, 0.10, 0.04)
		eye.mesh = eb
		eye.material_override = eye_mat
		eye.position = Vector3(sx, 4.45, 0.44)
		golem.add_child(eye)
	# Eye omni light
	var eye_lt: OmniLight3D = OmniLight3D.new()
	eye_lt.light_color = Color(1.0, 0.55, 0.18)
	eye_lt.light_energy = 2.0
	eye_lt.omni_range = 5.0
	eye_lt.position = Vector3(0, 4.45, 0.55)
	golem.add_child(eye_lt)
	# Left arm (regular box arm)
	var arm_l: MeshInstance3D = MeshInstance3D.new()
	var alb: BoxMesh = BoxMesh.new()
	alb.size = Vector3(0.50, 1.85, 0.50)
	arm_l.mesh = alb
	arm_l.material_override = iron
	arm_l.position = Vector3(-1.20, 3.05, 0)
	golem.add_child(arm_l)
	# Right arm with hammer-fist (oversized iron box at the end)
	var arm_r: MeshInstance3D = MeshInstance3D.new()
	arm_r.mesh = alb
	arm_r.material_override = iron
	arm_r.position = Vector3(1.20, 3.05, 0)
	golem.add_child(arm_r)
	var fist: MeshInstance3D = MeshInstance3D.new()
	var fb: BoxMesh = BoxMesh.new()
	fb.size = Vector3(0.85, 0.85, 0.85)
	fist.mesh = fb
	fist.material_override = iron
	fist.position = Vector3(1.20, 1.85, 0)
	golem.add_child(fist)
	# Slow head sway tween
	var sway: Tween = head.create_tween().set_loops()
	sway.tween_property(head, "rotation_degrees:y", 8.0, 2.5)
	sway.tween_property(head, "rotation_degrees:y", -8.0, 2.5)
	# Golem collision (single capsule)
	var stb: StaticBody3D = StaticBody3D.new()
	stb.position = Vector3(0, 2.35, 0)
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cap_shape: CapsuleShape3D = CapsuleShape3D.new()
	cap_shape.radius = 1.20
	cap_shape.height = 4.7
	cs.shape = cap_shape
	stb.add_child(cs)
	golem.add_child(stb)


func _build_d9_lava_pool(geom: Node) -> void:
	## Epic-9 T17: sunken bubbling lava pool — wide circular pit with stone
	## rim, glowing emissive lava surface, and rising lava droplet particles.
	var pool: Node3D = Node3D.new()
	pool.name = "D9LavaPool"
	pool.position = Vector3(D9_CENTER.x - 18, 0.05, -2)
	geom.add_child(pool)
	# Stone rim (wide low cylinder)
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.18, 0.14, 0.16)
	stone_mat.roughness = 0.85
	var rim: MeshInstance3D = MeshInstance3D.new()
	var rcm: CylinderMesh = CylinderMesh.new()
	rcm.top_radius = 3.20
	rcm.bottom_radius = 3.50
	rcm.height = 0.45
	rim.mesh = rcm
	rim.material_override = stone_mat
	rim.position = Vector3(0, 0.22, 0)
	pool.add_child(rim)
	# Lava surface (slightly recessed emissive disc)
	var lava_mat: StandardMaterial3D = StandardMaterial3D.new()
	lava_mat.albedo_color = Color(1.0, 0.42, 0.10)
	lava_mat.emission_enabled = true
	lava_mat.emission = Color(1.0, 0.58, 0.18)
	lava_mat.emission_energy_multiplier = 4.0
	lava_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var lava: MeshInstance3D = MeshInstance3D.new()
	var lcm: CylinderMesh = CylinderMesh.new()
	lcm.top_radius = 2.85
	lcm.bottom_radius = 2.85
	lcm.height = 0.10
	lava.mesh = lcm
	lava.material_override = lava_mat
	lava.position = Vector3(0, 0.30, 0)
	pool.add_child(lava)
	var pulse: Tween = lava.create_tween().set_loops()
	pulse.tween_property(lava_mat, "emission_energy_multiplier", 6.0, 1.6)
	pulse.tween_property(lava_mat, "emission_energy_multiplier", 2.5, 1.6)
	# 3 stone rocks poking out of the lava
	for i in range(3):
		var ang: float = float(i) * (TAU / 3.0)
		var rock: MeshInstance3D = MeshInstance3D.new()
		var rsm: SphereMesh = SphereMesh.new()
		rsm.radius = 0.45
		rsm.height = 0.85
		rock.mesh = rsm
		rock.material_override = stone_mat
		rock.position = Vector3(cos(ang) * 1.6, 0.50, sin(ang) * 1.6)
		rock.scale = Vector3(1.0, 0.6, 1.0)
		pool.add_child(rock)
	# Bright orange omni light
	var lt: OmniLight3D = OmniLight3D.new()
	lt.light_color = Color(1.0, 0.55, 0.18)
	lt.light_energy = 5.0
	lt.omni_range = 14.0
	lt.position = Vector3(0, 1.5, 0)
	pool.add_child(lt)
	# Lava droplet GPU particles rising up and falling back
	var drops: GPUParticles3D = GPUParticles3D.new()
	drops.position = Vector3(0, 0.4, 0)
	drops.amount = 80
	drops.lifetime = 2.4
	var pm: ParticleProcessMaterial = ParticleProcessMaterial.new()
	pm.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_RING
	pm.emission_ring_radius = 2.6
	pm.emission_ring_inner_radius = 0.5
	pm.emission_ring_height = 0.05
	pm.direction = Vector3(0, 1, 0)
	pm.spread = 25.0
	pm.initial_velocity_min = 1.5
	pm.initial_velocity_max = 3.0
	pm.gravity = Vector3(0, -4.0, 0)
	pm.scale_min = 0.10
	pm.scale_max = 0.22
	pm.color = Color(1.0, 0.55, 0.18, 1.0)
	drops.process_material = pm
	var drop_mesh: SphereMesh = SphereMesh.new()
	drop_mesh.radius = 0.10
	drop_mesh.height = 0.20
	drops.draw_pass_1 = drop_mesh
	pool.add_child(drops)
	# Pool collision (rim only — center is impassable lava but no actual hit body needed since stone rim blocks entry)
	var stb: StaticBody3D = StaticBody3D.new()
	stb.position = Vector3(0, 0.22, 0)
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cyl: CylinderShape3D = CylinderShape3D.new()
	cyl.radius = 3.30
	cyl.height = 0.60
	cs.shape = cyl
	stb.add_child(cs)
	pool.add_child(stb)


func _build_d9_forging_table(geom: Node) -> void:
	## Epic-9 T18: stone forging table with a glowing weapon blueprint laid
	## across the top — ancient runes etched into the surface.
	var table: Node3D = Node3D.new()
	table.name = "D9ForgingTable"
	table.position = Vector3(D9_CENTER.x - 4, 0, -8)
	geom.add_child(table)
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.42, 0.40, 0.42)
	stone_mat.roughness = 0.85
	# Tabletop (wide flat box)
	var top: MeshInstance3D = MeshInstance3D.new()
	var tb: BoxMesh = BoxMesh.new()
	tb.size = Vector3(2.40, 0.18, 1.40)
	top.mesh = tb
	top.material_override = stone_mat
	top.position = Vector3(0, 0.95, 0)
	table.add_child(top)
	# 4 stone legs
	for sx in [-1.0, 1.0]:
		for sz in [-0.55, 0.55]:
			var leg: MeshInstance3D = MeshInstance3D.new()
			var lb: BoxMesh = BoxMesh.new()
			lb.size = Vector3(0.20, 0.85, 0.20)
			leg.mesh = lb
			leg.material_override = stone_mat
			leg.position = Vector3(sx, 0.42, sz)
			table.add_child(leg)
	# Glowing parchment blueprint on the table (cyan emissive box)
	var blue_mat: StandardMaterial3D = StandardMaterial3D.new()
	blue_mat.albedo_color = Color(0.20, 0.55, 0.85)
	blue_mat.emission_enabled = true
	blue_mat.emission = Color(0.30, 0.65, 0.95)
	blue_mat.emission_energy_multiplier = 1.6
	blue_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var blueprint: MeshInstance3D = MeshInstance3D.new()
	var bb: BoxMesh = BoxMesh.new()
	bb.size = Vector3(1.40, 0.04, 0.95)
	blueprint.mesh = bb
	blueprint.material_override = blue_mat
	blueprint.position = Vector3(0, 1.06, 0)
	table.add_child(blueprint)
	# Stylized weapon outline on the blueprint (white emissive thin boxes)
	var line_mat: StandardMaterial3D = StandardMaterial3D.new()
	line_mat.albedo_color = Color(0.92, 0.95, 1.0)
	line_mat.emission_enabled = true
	line_mat.emission = Color(0.92, 0.95, 1.0)
	line_mat.emission_energy_multiplier = 2.0
	line_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	# Sword silhouette: long blade + cross guard + short hilt
	var blade: MeshInstance3D = MeshInstance3D.new()
	var blb: BoxMesh = BoxMesh.new()
	blb.size = Vector3(0.85, 0.02, 0.10)
	blade.mesh = blb
	blade.material_override = line_mat
	blade.position = Vector3(0.0, 1.10, 0)
	table.add_child(blade)
	var guard: MeshInstance3D = MeshInstance3D.new()
	var gb: BoxMesh = BoxMesh.new()
	gb.size = Vector3(0.04, 0.02, 0.40)
	guard.mesh = gb
	guard.material_override = line_mat
	guard.position = Vector3(0.45, 1.10, 0)
	table.add_child(guard)
	var hilt: MeshInstance3D = MeshInstance3D.new()
	var hb: BoxMesh = BoxMesh.new()
	hb.size = Vector3(0.20, 0.02, 0.06)
	hilt.mesh = hb
	hilt.material_override = line_mat
	hilt.position = Vector3(0.60, 1.10, 0)
	table.add_child(hilt)
	# Cyan blueprint pulse
	var pulse: Tween = blueprint.create_tween().set_loops()
	pulse.tween_property(blue_mat, "emission_energy_multiplier", 2.4, 1.4)
	pulse.tween_property(blue_mat, "emission_energy_multiplier", 1.0, 1.4)
	# Table collision
	var stb: StaticBody3D = StaticBody3D.new()
	stb.position = Vector3(0, 0.55, 0)
	var cs: CollisionShape3D = CollisionShape3D.new()
	var bs: BoxShape3D = BoxShape3D.new()
	bs.size = Vector3(2.40, 1.10, 1.40)
	cs.shape = bs
	stb.add_child(cs)
	table.add_child(stb)


func _build_d9_weapon_mannequin(geom: Node) -> void:
	## Epic-9 T19: armored display mannequin with full plate armor + sword,
	## standing on a stone pedestal.
	var mann: Node3D = Node3D.new()
	mann.name = "D9WeaponMannequin"
	mann.position = Vector3(D9_CENTER.x + 16, 0, -2)
	geom.add_child(mann)
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.42, 0.40, 0.42)
	stone_mat.roughness = 0.85
	var iron: StandardMaterial3D = StandardMaterial3D.new()
	iron.albedo_color = Color(0.55, 0.58, 0.62)
	iron.metallic = 0.92
	iron.roughness = 0.30
	# Stone pedestal
	var ped: MeshInstance3D = MeshInstance3D.new()
	var pcm: CylinderMesh = CylinderMesh.new()
	pcm.top_radius = 0.85
	pcm.bottom_radius = 0.95
	pcm.height = 0.65
	ped.mesh = pcm
	ped.material_override = stone_mat
	ped.position = Vector3(0, 0.32, 0)
	mann.add_child(ped)
	# Boots (2 wide boxes)
	for sx in [-0.20, 0.20]:
		var boot: MeshInstance3D = MeshInstance3D.new()
		var bb: BoxMesh = BoxMesh.new()
		bb.size = Vector3(0.22, 0.18, 0.32)
		boot.mesh = bb
		boot.material_override = iron
		boot.position = Vector3(sx, 0.78, 0.04)
		mann.add_child(boot)
	# Greaves (calves)
	for sx in [-0.20, 0.20]:
		var greave: MeshInstance3D = MeshInstance3D.new()
		var gb: BoxMesh = BoxMesh.new()
		gb.size = Vector3(0.22, 0.65, 0.22)
		greave.mesh = gb
		greave.material_override = iron
		greave.position = Vector3(sx, 1.20, 0)
		mann.add_child(greave)
	# Cuirass (chest piece)
	var cuirass: MeshInstance3D = MeshInstance3D.new()
	var cb: BoxMesh = BoxMesh.new()
	cb.size = Vector3(0.85, 0.95, 0.55)
	cuirass.mesh = cb
	cuirass.material_override = iron
	cuirass.position = Vector3(0, 2.05, 0)
	mann.add_child(cuirass)
	# Brass shoulder pauldrons
	var brass: StandardMaterial3D = StandardMaterial3D.new()
	brass.albedo_color = Color(0.85, 0.65, 0.20)
	brass.metallic = 0.95
	brass.roughness = 0.20
	for sx in [-0.50, 0.50]:
		var pld: MeshInstance3D = MeshInstance3D.new()
		var psm: SphereMesh = SphereMesh.new()
		psm.radius = 0.20
		psm.height = 0.40
		pld.mesh = psm
		pld.material_override = brass
		pld.position = Vector3(sx, 2.40, 0)
		mann.add_child(pld)
	# Helmet (full bucket helm)
	var helm: MeshInstance3D = MeshInstance3D.new()
	var hb: BoxMesh = BoxMesh.new()
	hb.size = Vector3(0.50, 0.55, 0.50)
	helm.mesh = hb
	helm.material_override = iron
	helm.position = Vector3(0, 2.85, 0)
	mann.add_child(helm)
	# Visor slit (dark)
	var slit_mat: StandardMaterial3D = StandardMaterial3D.new()
	slit_mat.albedo_color = Color(0.05, 0.05, 0.08)
	slit_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var slit: MeshInstance3D = MeshInstance3D.new()
	var slm: BoxMesh = BoxMesh.new()
	slm.size = Vector3(0.32, 0.06, 0.04)
	slit.mesh = slm
	slit.material_override = slit_mat
	slit.position = Vector3(0, 2.85, 0.27)
	mann.add_child(slit)
	# Sword hanging at the side (straight blade prism + hilt)
	var blade_mat: StandardMaterial3D = StandardMaterial3D.new()
	blade_mat.albedo_color = Color(0.78, 0.82, 0.88)
	blade_mat.metallic = 0.92
	blade_mat.roughness = 0.20
	var blade: MeshInstance3D = MeshInstance3D.new()
	var blb: BoxMesh = BoxMesh.new()
	blb.size = Vector3(0.10, 1.30, 0.04)
	blade.mesh = blb
	blade.material_override = blade_mat
	blade.position = Vector3(0.55, 1.40, 0)
	mann.add_child(blade)
	var hilt: MeshInstance3D = MeshInstance3D.new()
	var hb2: BoxMesh = BoxMesh.new()
	hb2.size = Vector3(0.06, 0.30, 0.04)
	hilt.mesh = hb2
	hilt.material_override = brass
	hilt.position = Vector3(0.55, 2.20, 0)
	mann.add_child(hilt)
	var crossguard: MeshInstance3D = MeshInstance3D.new()
	var cgb: BoxMesh = BoxMesh.new()
	cgb.size = Vector3(0.30, 0.05, 0.05)
	crossguard.mesh = cgb
	crossguard.material_override = brass
	crossguard.position = Vector3(0.55, 2.05, 0)
	mann.add_child(crossguard)
	# Mannequin collision
	var stb: StaticBody3D = StaticBody3D.new()
	stb.position = Vector3(0, 1.55, 0)
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cap_shape: CapsuleShape3D = CapsuleShape3D.new()
	cap_shape.radius = 0.55
	cap_shape.height = 3.0
	cs.shape = cap_shape
	stb.add_child(cs)
	mann.add_child(stb)


func _build_d9_soot_vents(geom: Node) -> void:
	## Epic-9 T20: 5 ground soot vents puffing dark smoke at irregular spots.
	var vents: Node3D = Node3D.new()
	vents.name = "D9SootVents"
	vents.position = Vector3(D9_CENTER.x, 0.05, 0)
	geom.add_child(vents)
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.18, 0.14, 0.16)
	stone_mat.roughness = 0.85
	var spots: Array[Vector3] = [
		Vector3(-22, 0, 6),
		Vector3(20, 0, -8),
		Vector3(-8, 0, 12),
		Vector3(15, 0, 9),
		Vector3(-15, 0, -12),
	]
	for i in range(spots.size()):
		var pos: Vector3 = spots[i]
		var vent: Node3D = Node3D.new()
		vent.position = pos
		vents.add_child(vent)
		# Stone rim ring
		var ring: MeshInstance3D = MeshInstance3D.new()
		var tm: TorusMesh = TorusMesh.new()
		tm.inner_radius = 0.40
		tm.outer_radius = 0.55
		ring.mesh = tm
		ring.material_override = stone_mat
		ring.position = Vector3(0, 0.10, 0)
		vent.add_child(ring)
		# Dark hole disc
		var hole_mat: StandardMaterial3D = StandardMaterial3D.new()
		hole_mat.albedo_color = Color(0.04, 0.03, 0.05)
		hole_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		var hole: MeshInstance3D = MeshInstance3D.new()
		var hcm: CylinderMesh = CylinderMesh.new()
		hcm.top_radius = 0.40
		hcm.bottom_radius = 0.40
		hcm.height = 0.05
		hole.mesh = hcm
		hole.material_override = hole_mat
		hole.position = Vector3(0, 0.05, 0)
		vent.add_child(hole)
		# Smoke puff GPU particles
		var smoke: GPUParticles3D = GPUParticles3D.new()
		smoke.position = Vector3(0, 0.10, 0)
		smoke.amount = 20
		smoke.lifetime = 3.5
		var pm: ParticleProcessMaterial = ParticleProcessMaterial.new()
		pm.direction = Vector3(0, 1, 0)
		pm.spread = 22.0
		pm.initial_velocity_min = 0.55
		pm.initial_velocity_max = 1.10
		pm.gravity = Vector3(0, 0.20, 0)
		pm.scale_min = 0.30
		pm.scale_max = 0.65
		pm.color = Color(0.20, 0.18, 0.20, 0.65)
		smoke.process_material = pm
		var smoke_mesh: SphereMesh = SphereMesh.new()
		smoke_mesh.radius = 0.20
		smoke_mesh.height = 0.40
		smoke.draw_pass_1 = smoke_mesh
		vent.add_child(smoke)


func _build_d9_weapon_stall(geom: Node) -> void:
	## Epic-9 T21: stone counter weapon stall with 4 weapons displayed on top
	## (axe, mace, dagger, longsword) and a stone awning behind.
	var stall: Node3D = Node3D.new()
	stall.name = "D9WeaponStall"
	stall.position = Vector3(D9_CENTER.x + 14, 0, 6)
	geom.add_child(stall)
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.42, 0.40, 0.42)
	stone_mat.roughness = 0.85
	var iron: StandardMaterial3D = StandardMaterial3D.new()
	iron.albedo_color = Color(0.55, 0.58, 0.62)
	iron.metallic = 0.92
	iron.roughness = 0.30
	var wood: StandardMaterial3D = StandardMaterial3D.new()
	wood.albedo_color = Color(0.45, 0.30, 0.18)
	wood.roughness = 0.85
	# Stone counter (long box)
	var counter: MeshInstance3D = MeshInstance3D.new()
	var cb: BoxMesh = BoxMesh.new()
	cb.size = Vector3(3.40, 1.10, 0.85)
	counter.mesh = cb
	counter.material_override = stone_mat
	counter.position = Vector3(0, 0.55, 0)
	stall.add_child(counter)
	# Stone back wall (tall thin box behind)
	var back: MeshInstance3D = MeshInstance3D.new()
	var bb: BoxMesh = BoxMesh.new()
	bb.size = Vector3(3.40, 2.20, 0.18)
	back.mesh = bb
	back.material_override = stone_mat
	back.position = Vector3(0, 1.10, -0.50)
	stall.add_child(back)
	# Awning (sloped overhead box)
	var awn: MeshInstance3D = MeshInstance3D.new()
	var ab: BoxMesh = BoxMesh.new()
	ab.size = Vector3(3.60, 0.18, 1.20)
	awn.mesh = ab
	awn.material_override = wood
	awn.position = Vector3(0, 2.30, 0.10)
	awn.rotation_degrees = Vector3(-12, 0, 0)
	stall.add_child(awn)
	# Weapon 1: axe (haft + curved blade box)
	var axe_root: Node3D = Node3D.new()
	axe_root.position = Vector3(-1.20, 1.20, 0)
	axe_root.rotation_degrees = Vector3(0, 0, 90)
	stall.add_child(axe_root)
	var axe_haft: MeshInstance3D = MeshInstance3D.new()
	var ahcm: CylinderMesh = CylinderMesh.new()
	ahcm.top_radius = 0.04
	ahcm.bottom_radius = 0.05
	ahcm.height = 1.10
	axe_haft.mesh = ahcm
	axe_haft.material_override = wood
	axe_root.add_child(axe_haft)
	var axe_head: MeshInstance3D = MeshInstance3D.new()
	var ahb: BoxMesh = BoxMesh.new()
	ahb.size = Vector3(0.30, 0.45, 0.06)
	axe_head.mesh = ahb
	axe_head.material_override = iron
	axe_head.position = Vector3(0.20, 0.45, 0)
	axe_root.add_child(axe_head)
	# Weapon 2: mace (haft + spiked spherical head)
	var mace_root: Node3D = Node3D.new()
	mace_root.position = Vector3(-0.40, 1.20, 0)
	mace_root.rotation_degrees = Vector3(0, 0, 90)
	stall.add_child(mace_root)
	var mace_haft: MeshInstance3D = MeshInstance3D.new()
	mace_haft.mesh = ahcm
	mace_haft.material_override = wood
	mace_root.add_child(mace_haft)
	var mace_head: MeshInstance3D = MeshInstance3D.new()
	var mhsm: SphereMesh = SphereMesh.new()
	mhsm.radius = 0.18
	mhsm.height = 0.36
	mace_head.mesh = mhsm
	mace_head.material_override = iron
	mace_head.position = Vector3(0, 0.50, 0)
	mace_root.add_child(mace_head)
	# Weapon 3: dagger (small straight blade)
	var dagger: MeshInstance3D = MeshInstance3D.new()
	var dgb: BoxMesh = BoxMesh.new()
	dgb.size = Vector3(0.06, 0.55, 0.04)
	dagger.mesh = dgb
	dagger.material_override = iron
	dagger.position = Vector3(0.40, 1.40, 0)
	dagger.rotation_degrees = Vector3(0, 0, 90)
	stall.add_child(dagger)
	var dagger_hilt: MeshInstance3D = MeshInstance3D.new()
	var dhb: BoxMesh = BoxMesh.new()
	dhb.size = Vector3(0.04, 0.18, 0.04)
	dagger_hilt.mesh = dhb
	dagger_hilt.material_override = wood
	dagger_hilt.position = Vector3(0.70, 1.40, 0)
	dagger_hilt.rotation_degrees = Vector3(0, 0, 90)
	stall.add_child(dagger_hilt)
	# Weapon 4: longsword
	var sword: MeshInstance3D = MeshInstance3D.new()
	var sb: BoxMesh = BoxMesh.new()
	sb.size = Vector3(0.10, 1.30, 0.04)
	sword.mesh = sb
	sword.material_override = iron
	sword.position = Vector3(1.20, 1.40, 0)
	sword.rotation_degrees = Vector3(0, 0, 90)
	stall.add_child(sword)
	var brass: StandardMaterial3D = StandardMaterial3D.new()
	brass.albedo_color = Color(0.85, 0.65, 0.20)
	brass.metallic = 0.95
	brass.roughness = 0.20
	var sword_guard: MeshInstance3D = MeshInstance3D.new()
	var sgb: BoxMesh = BoxMesh.new()
	sgb.size = Vector3(0.30, 0.06, 0.06)
	sword_guard.mesh = sgb
	sword_guard.material_override = brass
	sword_guard.position = Vector3(0.55, 1.40, 0)
	stall.add_child(sword_guard)
	# Counter collision
	var stb: StaticBody3D = StaticBody3D.new()
	stb.position = Vector3(0, 0.55, 0)
	var cs: CollisionShape3D = CollisionShape3D.new()
	var bs: BoxShape3D = BoxShape3D.new()
	bs.size = Vector3(3.40, 1.10, 0.85)
	cs.shape = bs
	stb.add_child(cs)
	stall.add_child(stb)


func _build_d9_weapon_vendor_npc(town: Node) -> void:
	## Epic-9 T22: weapon vendor NPC behind the stall — burly figure with
	## a leather vest and braided beard.
	var slots: Node3D = town.get_node_or_null("NPCSlots") as Node3D
	if slots == null:
		return
	var slot: Marker3D = Marker3D.new()
	slot.name = "D9WeaponVendorSlot"
	slot.position = Vector3(D9_CENTER.x + 14, 0, 5)
	slots.add_child(slot)
	var npc_scene: PackedScene = load("res://scenes/entities/npcs/VillagerR3.tscn") as PackedScene
	if npc_scene == null:
		return
	var npc: Node3D = npc_scene.instantiate() as Node3D
	npc.name = "D9WeaponVendor"
	if "npc_name" in npc:
		npc.set("npc_name", "Brunhild Ironarm")
	if "npc_id" in npc:
		npc.set("npc_id", "d9_weapon_vendor")
	slot.add_child(npc)
	# Leather vest (burly chest)
	var vest_mat: StandardMaterial3D = StandardMaterial3D.new()
	vest_mat.albedo_color = Color(0.42, 0.22, 0.10)
	vest_mat.roughness = 0.85
	var vest: MeshInstance3D = MeshInstance3D.new()
	var vb: BoxMesh = BoxMesh.new()
	vb.size = Vector3(1.05, 1.10, 0.65)
	vest.mesh = vb
	vest.material_override = vest_mat
	vest.position = Vector3(0, 1.10, 0)
	npc.add_child(vest)
	# Brass studs across the vest (8)
	var brass: StandardMaterial3D = StandardMaterial3D.new()
	brass.albedo_color = Color(0.85, 0.65, 0.20)
	brass.metallic = 0.95
	brass.roughness = 0.20
	for sx in [-0.30, -0.10, 0.10, 0.30]:
		for sy in [0.30, -0.10]:
			var stud: MeshInstance3D = MeshInstance3D.new()
			var ssm: SphereMesh = SphereMesh.new()
			ssm.radius = 0.04
			ssm.height = 0.08
			stud.mesh = ssm
			stud.material_override = brass
			stud.position = Vector3(sx, 1.10 + sy, 0.34)
			npc.add_child(stud)
	# Braided beard (dark prism hanging from chin)
	var beard_mat: StandardMaterial3D = StandardMaterial3D.new()
	beard_mat.albedo_color = Color(0.20, 0.15, 0.10)
	beard_mat.roughness = 0.85
	var beard: MeshInstance3D = MeshInstance3D.new()
	var bpm: PrismMesh = PrismMesh.new()
	bpm.size = Vector3(0.40, 0.50, 0.18)
	beard.mesh = bpm
	beard.material_override = beard_mat
	beard.position = Vector3(0, 1.62, 0.30)
	beard.rotation_degrees = Vector3(180, 0, 0)
	npc.add_child(beard)
	# Brass beard rings (2 small toruses)
	for sy in [1.50, 1.32]:
		var ring: MeshInstance3D = MeshInstance3D.new()
		var tm: TorusMesh = TorusMesh.new()
		tm.inner_radius = 0.07
		tm.outer_radius = 0.10
		ring.mesh = tm
		ring.material_override = brass
		ring.position = Vector3(0, sy, 0.32)
		ring.rotation_degrees = Vector3(0, 0, 90)
		npc.add_child(ring)
	# Sledgehammer leaning against the side
	var wood_mat: StandardMaterial3D = StandardMaterial3D.new()
	wood_mat.albedo_color = Color(0.45, 0.30, 0.18)
	var iron_mat: StandardMaterial3D = StandardMaterial3D.new()
	iron_mat.albedo_color = Color(0.22, 0.20, 0.20)
	iron_mat.metallic = 0.90
	iron_mat.roughness = 0.30
	var ham_root: Node3D = Node3D.new()
	ham_root.position = Vector3(-0.55, 1.05, 0.20)
	ham_root.rotation_degrees = Vector3(0, 0, 18)
	npc.add_child(ham_root)
	var haft: MeshInstance3D = MeshInstance3D.new()
	var hcm: CylinderMesh = CylinderMesh.new()
	hcm.top_radius = 0.06
	hcm.bottom_radius = 0.07
	hcm.height = 1.40
	haft.mesh = hcm
	haft.material_override = wood_mat
	haft.position = Vector3(0, 0, 0)
	ham_root.add_child(haft)
	var head: MeshInstance3D = MeshInstance3D.new()
	var hdb: BoxMesh = BoxMesh.new()
	hdb.size = Vector3(0.45, 0.22, 0.22)
	head.mesh = hdb
	head.material_override = iron_mat
	head.position = Vector3(0, 0.70, 0)
	ham_root.add_child(head)


func _build_d9_smelter_pots(geom: Node) -> void:
	## Epic-9 T23: 2 hanging cauldrons of molten metal suspended from iron
	## frames, glowing orange and pulsing.
	var pots: Node3D = Node3D.new()
	pots.name = "D9SmelterPots"
	pots.position = Vector3(D9_CENTER.x - 12, 0, 12)
	geom.add_child(pots)
	var iron: StandardMaterial3D = StandardMaterial3D.new()
	iron.albedo_color = Color(0.22, 0.20, 0.20)
	iron.metallic = 0.85
	iron.roughness = 0.45
	var lava_mat: StandardMaterial3D = StandardMaterial3D.new()
	lava_mat.albedo_color = Color(1.0, 0.45, 0.10)
	lava_mat.emission_enabled = true
	lava_mat.emission = Color(1.0, 0.55, 0.18)
	lava_mat.emission_energy_multiplier = 4.0
	lava_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for i in range(2):
		var unit: Node3D = Node3D.new()
		unit.position = Vector3(i * 4.0, 0, 0)
		pots.add_child(unit)
		# A-frame: 2 angled posts and a top cross-bar
		for sx in [-1.0, 1.0]:
			var post: MeshInstance3D = MeshInstance3D.new()
			var pcm: CylinderMesh = CylinderMesh.new()
			pcm.top_radius = 0.10
			pcm.bottom_radius = 0.14
			pcm.height = 3.50
			post.mesh = pcm
			post.material_override = iron
			post.position = Vector3(sx * 0.85, 1.75, 0)
			post.rotation_degrees = Vector3(0, 0, sx * 18.0)
			unit.add_child(post)
			# Per-post collision
			var sb: StaticBody3D = StaticBody3D.new()
			sb.position = Vector3(sx * 0.85, 1.75, 0)
			var cs: CollisionShape3D = CollisionShape3D.new()
			var cap: CapsuleShape3D = CapsuleShape3D.new()
			cap.radius = 0.18
			cap.height = 3.0
			cs.shape = cap
			sb.add_child(cs)
			unit.add_child(sb)
		# Top cross-bar
		var bar: MeshInstance3D = MeshInstance3D.new()
		var bcm: CylinderMesh = CylinderMesh.new()
		bcm.top_radius = 0.08
		bcm.bottom_radius = 0.08
		bcm.height = 2.20
		bar.mesh = bcm
		bar.material_override = iron
		bar.position = Vector3(0, 3.40, 0)
		bar.rotation_degrees = Vector3(0, 0, 90)
		unit.add_child(bar)
		# Chain (two thin cylinders dropping down)
		for sx in [-0.20, 0.20]:
			var chain: MeshInstance3D = MeshInstance3D.new()
			var chm: CylinderMesh = CylinderMesh.new()
			chm.top_radius = 0.05
			chm.bottom_radius = 0.05
			chm.height = 1.20
			chain.mesh = chm
			chain.material_override = iron
			chain.position = Vector3(sx, 2.65, 0)
			unit.add_child(chain)
		# Cauldron (wide cylinder with rounded bottom)
		var pot: MeshInstance3D = MeshInstance3D.new()
		var pcm2: CylinderMesh = CylinderMesh.new()
		pcm2.top_radius = 0.85
		pcm2.bottom_radius = 0.55
		pcm2.height = 0.95
		pot.mesh = pcm2
		pot.material_override = iron
		pot.position = Vector3(0, 1.55, 0)
		unit.add_child(pot)
		# Molten content (emissive disc at the rim)
		var lava: MeshInstance3D = MeshInstance3D.new()
		var lcm: CylinderMesh = CylinderMesh.new()
		lcm.top_radius = 0.78
		lcm.bottom_radius = 0.78
		lcm.height = 0.10
		lava.mesh = lcm
		lava.material_override = lava_mat
		lava.position = Vector3(0, 1.95, 0)
		unit.add_child(lava)
		var pulse: Tween = lava.create_tween().set_loops()
		var phase: float = float(i) * 0.4
		pulse.tween_property(lava_mat, "emission_energy_multiplier", 5.5, 1.0 + phase)
		pulse.tween_property(lava_mat, "emission_energy_multiplier", 2.5, 1.0 + phase)
		# Light from the cauldron
		var lt: OmniLight3D = OmniLight3D.new()
		lt.light_color = Color(1.0, 0.55, 0.18)
		lt.light_energy = 3.0
		lt.omni_range = 7.0
		lt.position = Vector3(0, 2.10, 0)
		unit.add_child(lt)


func _build_d9_repair_station(geom: Node) -> void:
	## Epic-9 T24: small specialized repair anvil with a tongs and a stack
	## of repair scrap on a stone bench beside it.
	var station: Node3D = Node3D.new()
	station.name = "D9RepairStation"
	station.position = Vector3(D9_CENTER.x + 6, 0, -8)
	geom.add_child(station)
	var iron: StandardMaterial3D = StandardMaterial3D.new()
	iron.albedo_color = Color(0.22, 0.20, 0.20)
	iron.metallic = 0.92
	iron.roughness = 0.30
	var wood: StandardMaterial3D = StandardMaterial3D.new()
	wood.albedo_color = Color(0.45, 0.30, 0.18)
	wood.roughness = 0.85
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.42, 0.40, 0.42)
	stone_mat.roughness = 0.85
	# Smaller anvil (compact)
	var stump: MeshInstance3D = MeshInstance3D.new()
	var scm: CylinderMesh = CylinderMesh.new()
	scm.top_radius = 0.32
	scm.bottom_radius = 0.36
	scm.height = 0.70
	stump.mesh = scm
	stump.material_override = wood
	stump.position = Vector3(0, 0.35, 0)
	station.add_child(stump)
	var top: MeshInstance3D = MeshInstance3D.new()
	var tb: BoxMesh = BoxMesh.new()
	tb.size = Vector3(0.65, 0.16, 0.32)
	top.mesh = tb
	top.material_override = iron
	top.position = Vector3(0, 0.78, 0)
	station.add_child(top)
	# Tongs lying across the top (2 thin curved cylinders)
	var tongs_root: Node3D = Node3D.new()
	tongs_root.position = Vector3(0, 0.92, 0)
	tongs_root.rotation_degrees = Vector3(0, 25, 0)
	station.add_child(tongs_root)
	for sz in [-0.04, 0.04]:
		var tg: MeshInstance3D = MeshInstance3D.new()
		var tcm: CylinderMesh = CylinderMesh.new()
		tcm.top_radius = 0.03
		tcm.bottom_radius = 0.04
		tcm.height = 0.65
		tg.mesh = tcm
		tg.material_override = iron
		tg.position = Vector3(0, 0, sz)
		tg.rotation_degrees = Vector3(0, 0, 90)
		tongs_root.add_child(tg)
	# Stone bench (long box) beside the anvil
	var bench: MeshInstance3D = MeshInstance3D.new()
	var bb: BoxMesh = BoxMesh.new()
	bb.size = Vector3(1.20, 0.65, 0.55)
	bench.mesh = bb
	bench.material_override = stone_mat
	bench.position = Vector3(1.20, 0.32, 0)
	station.add_child(bench)
	# Repair scrap pile (3 small bent iron bars)
	for i in range(3):
		var scrap: MeshInstance3D = MeshInstance3D.new()
		var sb: BoxMesh = BoxMesh.new()
		sb.size = Vector3(0.30 + randf() * 0.15, 0.05, 0.08)
		scrap.mesh = sb
		scrap.material_override = iron
		scrap.position = Vector3(1.10 + randf() * 0.20, 0.70, -0.10 + float(i) * 0.10)
		scrap.rotation_degrees = Vector3(0, randf_range(-25, 25), randf_range(-15, 15))
		station.add_child(scrap)
	# Combined collision
	var stb: StaticBody3D = StaticBody3D.new()
	stb.position = Vector3(0.55, 0.45, 0)
	var cs: CollisionShape3D = CollisionShape3D.new()
	var bs: BoxShape3D = BoxShape3D.new()
	bs.size = Vector3(2.50, 1.10, 0.85)
	cs.shape = bs
	stb.add_child(cs)
	station.add_child(stb)


func _build_d9_ingot_stacks(geom: Node) -> void:
	## Epic-9 T25: 3 organized stacks of finished iron ingot bars at the
	## edge of the smithing area.
	var stacks: Node3D = Node3D.new()
	stacks.name = "D9IngotStacks"
	stacks.position = Vector3(D9_CENTER.x - 4, 0, 12)
	geom.add_child(stacks)
	var iron: StandardMaterial3D = StandardMaterial3D.new()
	iron.albedo_color = Color(0.55, 0.55, 0.58)
	iron.metallic = 0.90
	iron.roughness = 0.30
	for i in range(3):
		var stack: Node3D = Node3D.new()
		stack.position = Vector3(i * 1.30, 0, 0)
		stacks.add_child(stack)
		# 6 ingots stacked in a brick-like pattern (3 bottom, 2 middle, 1 top)
		var positions: Array[Vector3] = [
			Vector3(-0.35, 0.10, 0),
			Vector3(0.0, 0.10, 0),
			Vector3(0.35, 0.10, 0),
			Vector3(-0.18, 0.30, 0),
			Vector3(0.18, 0.30, 0),
			Vector3(0.0, 0.50, 0),
		]
		for p in positions:
			var ingot: MeshInstance3D = MeshInstance3D.new()
			var ib: BoxMesh = BoxMesh.new()
			ib.size = Vector3(0.32, 0.18, 0.55)
			ingot.mesh = ib
			ingot.material_override = iron
			ingot.position = p
			stack.add_child(ingot)
		# Stack collision
		var stb: StaticBody3D = StaticBody3D.new()
		stb.position = Vector3(0, 0.35, 0)
		var cs: CollisionShape3D = CollisionShape3D.new()
		var bs: BoxShape3D = BoxShape3D.new()
		bs.size = Vector3(1.10, 0.70, 0.65)
		cs.shape = bs
		stb.add_child(cs)
		stack.add_child(stb)


func _build_d9_forge_engineer_npc(town: Node) -> void:
	## Epic-9 T26: forge engineer NPC with a mechanical arm and a heavy wrench.
	var slots: Node3D = town.get_node_or_null("NPCSlots") as Node3D
	if slots == null:
		return
	var slot: Marker3D = Marker3D.new()
	slot.name = "D9ForgeEngineerSlot"
	slot.position = Vector3(D9_CENTER.x + 8, 0, 4)
	slots.add_child(slot)
	var npc_scene: PackedScene = load("res://scenes/entities/npcs/VillagerR3.tscn") as PackedScene
	if npc_scene == null:
		return
	var npc: Node3D = npc_scene.instantiate() as Node3D
	npc.name = "D9ForgeEngineer"
	if "npc_name" in npc:
		npc.set("npc_name", "Engineer Cogwright")
	if "npc_id" in npc:
		npc.set("npc_id", "d9_forge_engineer")
	slot.add_child(npc)
	# Khaki overall jumpsuit
	var suit_mat: StandardMaterial3D = StandardMaterial3D.new()
	suit_mat.albedo_color = Color(0.55, 0.45, 0.25)
	suit_mat.roughness = 0.85
	var suit: MeshInstance3D = MeshInstance3D.new()
	var sb: BoxMesh = BoxMesh.new()
	sb.size = Vector3(0.95, 1.20, 0.55)
	suit.mesh = sb
	suit.material_override = suit_mat
	suit.position = Vector3(0, 1.05, 0)
	npc.add_child(suit)
	# Goggles (cyan emissive lenses on a strap)
	var lens_mat: StandardMaterial3D = StandardMaterial3D.new()
	lens_mat.albedo_color = Color(0.30, 0.85, 0.95)
	lens_mat.emission_enabled = true
	lens_mat.emission = Color(0.40, 0.95, 1.0)
	lens_mat.emission_energy_multiplier = 1.8
	lens_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for sx in [-0.16, 0.16]:
		var lens: MeshInstance3D = MeshInstance3D.new()
		var lsm: SphereMesh = SphereMesh.new()
		lsm.radius = 0.12
		lsm.height = 0.08
		lens.mesh = lsm
		lens.material_override = lens_mat
		lens.position = Vector3(sx, 1.92, 0.30)
		npc.add_child(lens)
	# Goggle strap (dark band)
	var strap_mat: StandardMaterial3D = StandardMaterial3D.new()
	strap_mat.albedo_color = Color(0.20, 0.15, 0.10)
	var strap: MeshInstance3D = MeshInstance3D.new()
	var stb: BoxMesh = BoxMesh.new()
	stb.size = Vector3(0.70, 0.08, 0.06)
	strap.mesh = stb
	strap.material_override = strap_mat
	strap.position = Vector3(0, 1.92, 0)
	npc.add_child(strap)
	# Mechanical right arm (iron segments instead of normal arm)
	var iron_mat: StandardMaterial3D = StandardMaterial3D.new()
	iron_mat.albedo_color = Color(0.55, 0.55, 0.58)
	iron_mat.metallic = 0.92
	iron_mat.roughness = 0.30
	var brass_mat: StandardMaterial3D = StandardMaterial3D.new()
	brass_mat.albedo_color = Color(0.85, 0.65, 0.20)
	brass_mat.metallic = 0.95
	brass_mat.roughness = 0.20
	# Upper arm
	var upper: MeshInstance3D = MeshInstance3D.new()
	var ucm: CylinderMesh = CylinderMesh.new()
	ucm.top_radius = 0.10
	ucm.bottom_radius = 0.12
	ucm.height = 0.55
	upper.mesh = ucm
	upper.material_override = iron_mat
	upper.position = Vector3(0.55, 1.30, 0)
	npc.add_child(upper)
	# Brass elbow joint
	var elbow: MeshInstance3D = MeshInstance3D.new()
	var esm: SphereMesh = SphereMesh.new()
	esm.radius = 0.14
	esm.height = 0.28
	elbow.mesh = esm
	elbow.material_override = brass_mat
	elbow.position = Vector3(0.55, 1.00, 0)
	npc.add_child(elbow)
	# Forearm
	var fore: MeshInstance3D = MeshInstance3D.new()
	fore.mesh = ucm
	fore.material_override = iron_mat
	fore.position = Vector3(0.55, 0.70, 0)
	npc.add_child(fore)
	# Iron pincer hand (2 small box claws)
	for sz in [-0.06, 0.06]:
		var claw: MeshInstance3D = MeshInstance3D.new()
		var ccb: BoxMesh = BoxMesh.new()
		ccb.size = Vector3(0.10, 0.20, 0.05)
		claw.mesh = ccb
		claw.material_override = iron_mat
		claw.position = Vector3(0.55, 0.40, sz)
		npc.add_child(claw)
	# Heavy wrench in left hand (long iron bar with curved jaw)
	var wrench_root: Node3D = Node3D.new()
	wrench_root.position = Vector3(-0.50, 0.95, 0.25)
	wrench_root.rotation_degrees = Vector3(0, 0, 12)
	npc.add_child(wrench_root)
	var wr_haft: MeshInstance3D = MeshInstance3D.new()
	var wcm: CylinderMesh = CylinderMesh.new()
	wcm.top_radius = 0.05
	wcm.bottom_radius = 0.05
	wcm.height = 0.85
	wr_haft.mesh = wcm
	wr_haft.material_override = iron_mat
	wrench_root.add_child(wr_haft)
	var wr_jaw: MeshInstance3D = MeshInstance3D.new()
	var wjb: BoxMesh = BoxMesh.new()
	wjb.size = Vector3(0.18, 0.18, 0.08)
	wr_jaw.mesh = wjb
	wr_jaw.material_override = iron_mat
	wr_jaw.position = Vector3(0, 0.50, 0)
	wrench_root.add_child(wr_jaw)


func _build_d9_steam_pipes(geom: Node) -> void:
	## Epic-9 T27: overhead industrial pipe network — long horizontal pipes
	## with elbow joints and small steam vent puffs.
	var pipes: Node3D = Node3D.new()
	pipes.name = "D9SteamPipes"
	pipes.position = Vector3(D9_CENTER.x, 0, 0)
	geom.add_child(pipes)
	var iron_mat: StandardMaterial3D = StandardMaterial3D.new()
	iron_mat.albedo_color = Color(0.45, 0.42, 0.40)
	iron_mat.metallic = 0.7
	iron_mat.roughness = 0.45
	# 2 long horizontal pipes high overhead
	for i in range(2):
		var pipe: MeshInstance3D = MeshInstance3D.new()
		var pcm: CylinderMesh = CylinderMesh.new()
		pcm.top_radius = 0.30
		pcm.bottom_radius = 0.30
		pcm.height = 28.0
		pipe.mesh = pcm
		pipe.material_override = iron_mat
		pipe.position = Vector3(0, 7.0, -8.0 + i * 16.0)
		pipe.rotation_degrees = Vector3(0, 0, 90)
		pipes.add_child(pipe)
	# 4 vertical drop pipes connecting the horizontals to the ground
	for sx in [-12.0, -4.0, 4.0, 12.0]:
		var drop: MeshInstance3D = MeshInstance3D.new()
		var dcm: CylinderMesh = CylinderMesh.new()
		dcm.top_radius = 0.22
		dcm.bottom_radius = 0.25
		dcm.height = 7.0
		drop.mesh = dcm
		drop.material_override = iron_mat
		drop.position = Vector3(sx, 3.5, -8.0)
		pipes.add_child(drop)
		# Brass elbow joint
		var brass: StandardMaterial3D = StandardMaterial3D.new()
		brass.albedo_color = Color(0.85, 0.65, 0.20)
		brass.metallic = 0.95
		brass.roughness = 0.20
		var elbow: MeshInstance3D = MeshInstance3D.new()
		var esm: SphereMesh = SphereMesh.new()
		esm.radius = 0.32
		esm.height = 0.55
		elbow.mesh = esm
		elbow.material_override = brass
		elbow.position = Vector3(sx, 7.0, -8.0)
		pipes.add_child(elbow)
		# Steam vent particles at the base
		var steam: GPUParticles3D = GPUParticles3D.new()
		steam.position = Vector3(sx, 0.20, -8.0)
		steam.amount = 25
		steam.lifetime = 2.5
		var pm: ParticleProcessMaterial = ParticleProcessMaterial.new()
		pm.direction = Vector3(0, 1, 0)
		pm.spread = 18.0
		pm.initial_velocity_min = 0.50
		pm.initial_velocity_max = 1.10
		pm.gravity = Vector3(0, 0.30, 0)
		pm.scale_min = 0.20
		pm.scale_max = 0.45
		pm.color = Color(0.85, 0.92, 0.95, 0.55)
		steam.process_material = pm
		var sm: SphereMesh = SphereMesh.new()
		sm.radius = 0.18
		sm.height = 0.36
		steam.draw_pass_1 = sm
		pipes.add_child(steam)
	# Pressure gauges (small brass discs on the horizontals)
	var brass: StandardMaterial3D = StandardMaterial3D.new()
	brass.albedo_color = Color(0.85, 0.65, 0.20)
	brass.metallic = 0.95
	brass.roughness = 0.20
	for sx in [-8.0, 0.0, 8.0]:
		for sz in [-8.0, 8.0]:
			var gauge: MeshInstance3D = MeshInstance3D.new()
			var gcm: CylinderMesh = CylinderMesh.new()
			gcm.top_radius = 0.18
			gcm.bottom_radius = 0.18
			gcm.height = 0.10
			gauge.mesh = gcm
			gauge.material_override = brass
			gauge.position = Vector3(sx, 7.0, sz + (0.32 if sz < 0 else -0.32))
			gauge.rotation_degrees = Vector3(90, 0, 0)
			pipes.add_child(gauge)


func _build_d9_drilling_rig(geom: Node) -> void:
	## Epic-9 T28: industrial drilling rig — vertical iron mast with a
	## spinning drill bit at the bottom and ore dust ring around the impact.
	var rig: Node3D = Node3D.new()
	rig.name = "D9DrillingRig"
	rig.position = Vector3(D9_CENTER.x + 22, 0, 8)
	geom.add_child(rig)
	var iron_mat: StandardMaterial3D = StandardMaterial3D.new()
	iron_mat.albedo_color = Color(0.45, 0.42, 0.40)
	iron_mat.metallic = 0.85
	iron_mat.roughness = 0.45
	# 4 corner posts forming a tower frame
	for sx in [-1.0, 1.0]:
		for sz in [-1.0, 1.0]:
			var post: MeshInstance3D = MeshInstance3D.new()
			var pcm: CylinderMesh = CylinderMesh.new()
			pcm.top_radius = 0.10
			pcm.bottom_radius = 0.14
			pcm.height = 6.50
			post.mesh = pcm
			post.material_override = iron_mat
			post.position = Vector3(sx, 3.25, sz)
			rig.add_child(post)
	# Top platform
	var top: MeshInstance3D = MeshInstance3D.new()
	var tb: BoxMesh = BoxMesh.new()
	tb.size = Vector3(2.40, 0.18, 2.40)
	top.mesh = tb
	top.material_override = iron_mat
	top.position = Vector3(0, 6.55, 0)
	rig.add_child(top)
	# Vertical drill mast (long thin cylinder)
	var mast: MeshInstance3D = MeshInstance3D.new()
	var mcm: CylinderMesh = CylinderMesh.new()
	mcm.top_radius = 0.18
	mcm.bottom_radius = 0.22
	mcm.height = 5.50
	mast.mesh = mcm
	mast.material_override = iron_mat
	mast.position = Vector3(0, 3.50, 0)
	rig.add_child(mast)
	# Spinning drill bit (cone tapering to a point)
	var bit_pivot: Node3D = Node3D.new()
	bit_pivot.position = Vector3(0, 0.85, 0)
	rig.add_child(bit_pivot)
	var bit: MeshInstance3D = MeshInstance3D.new()
	var bcm: CylinderMesh = CylinderMesh.new()
	bcm.top_radius = 0.18
	bcm.bottom_radius = 0.0
	bcm.height = 1.20
	bit.mesh = bcm
	bit.material_override = iron_mat
	bit_pivot.add_child(bit)
	# Spiral flutes around the bit (3 thin boxes at angles)
	for i in range(3):
		var flute: MeshInstance3D = MeshInstance3D.new()
		var flb: BoxMesh = BoxMesh.new()
		flb.size = Vector3(0.04, 1.10, 0.10)
		flute.mesh = flb
		flute.material_override = iron_mat
		flute.rotation_degrees = Vector3(0, float(i) * 120, 8)
		flute.position = Vector3(cos(deg_to_rad(i * 120)) * 0.16, 0, sin(deg_to_rad(i * 120)) * 0.16)
		bit_pivot.add_child(flute)
	# Spin tween
	var spin: Tween = bit_pivot.create_tween().set_loops()
	spin.tween_property(bit_pivot, "rotation_degrees:y", 360.0, 1.5).from(0.0)
	# Ore dust ring particles at the impact point
	var dust: GPUParticles3D = GPUParticles3D.new()
	dust.position = Vector3(0, 0.10, 0)
	dust.amount = 50
	dust.lifetime = 1.4
	var pm: ParticleProcessMaterial = ParticleProcessMaterial.new()
	pm.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_RING
	pm.emission_ring_radius = 0.40
	pm.emission_ring_inner_radius = 0.15
	pm.emission_ring_height = 0.05
	pm.direction = Vector3(0, 0.5, 0)
	pm.spread = 60.0
	pm.initial_velocity_min = 0.85
	pm.initial_velocity_max = 1.65
	pm.gravity = Vector3(0, -1.5, 0)
	pm.scale_min = 0.06
	pm.scale_max = 0.16
	pm.color = Color(0.55, 0.40, 0.20, 0.85)
	dust.process_material = pm
	var dust_mesh: SphereMesh = SphereMesh.new()
	dust_mesh.radius = 0.06
	dust_mesh.height = 0.12
	dust.draw_pass_1 = dust_mesh
	rig.add_child(dust)
	# Rig collision (single box for the tower)
	var stb: StaticBody3D = StaticBody3D.new()
	stb.position = Vector3(0, 3.25, 0)
	var cs: CollisionShape3D = CollisionShape3D.new()
	var bs: BoxShape3D = BoxShape3D.new()
	bs.size = Vector3(2.40, 6.50, 2.40)
	cs.shape = bs
	stb.add_child(cs)
	rig.add_child(stb)


func _build_d9_spark_waterfall(geom: Node) -> void:
	## Epic-9 T29: a waterfall of sparks cascading from a high stone ledge
	## down into a small lava basin at its base.
	var fall: Node3D = Node3D.new()
	fall.name = "D9SparkWaterfall"
	fall.position = Vector3(D9_CENTER.x + 26, 0, -10)
	geom.add_child(fall)
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.18, 0.14, 0.16)
	stone_mat.roughness = 0.85
	# Tall stone ledge (cliff block)
	var ledge: MeshInstance3D = MeshInstance3D.new()
	var lb: BoxMesh = BoxMesh.new()
	lb.size = Vector3(3.40, 5.50, 2.20)
	ledge.mesh = lb
	ledge.material_override = stone_mat
	ledge.position = Vector3(0, 2.75, 0)
	fall.add_child(ledge)
	# Small basin at the base
	var basin: MeshInstance3D = MeshInstance3D.new()
	var bcm: CylinderMesh = CylinderMesh.new()
	bcm.top_radius = 1.55
	bcm.bottom_radius = 1.85
	bcm.height = 0.55
	basin.mesh = bcm
	basin.material_override = stone_mat
	basin.position = Vector3(0, 0.27, 1.85)
	fall.add_child(basin)
	# Lava puddle in the basin
	var lava_mat: StandardMaterial3D = StandardMaterial3D.new()
	lava_mat.albedo_color = Color(1.0, 0.45, 0.10)
	lava_mat.emission_enabled = true
	lava_mat.emission = Color(1.0, 0.55, 0.18)
	lava_mat.emission_energy_multiplier = 4.5
	lava_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var lava: MeshInstance3D = MeshInstance3D.new()
	var lcm: CylinderMesh = CylinderMesh.new()
	lcm.top_radius = 1.30
	lcm.bottom_radius = 1.30
	lcm.height = 0.10
	lava.mesh = lcm
	lava.material_override = lava_mat
	lava.position = Vector3(0, 0.55, 1.85)
	fall.add_child(lava)
	# Spark waterfall GPU particles falling from the top of the ledge
	var sparks: GPUParticles3D = GPUParticles3D.new()
	sparks.position = Vector3(0, 5.40, 1.10)
	sparks.amount = 140
	sparks.lifetime = 2.5
	var pm: ParticleProcessMaterial = ParticleProcessMaterial.new()
	pm.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	pm.emission_box_extents = Vector3(1.40, 0.05, 0.10)
	pm.direction = Vector3(0, -1, 0)
	pm.spread = 12.0
	pm.initial_velocity_min = 0.85
	pm.initial_velocity_max = 1.65
	pm.gravity = Vector3(0, -3.5, 0)
	pm.scale_min = 0.08
	pm.scale_max = 0.18
	pm.color = Color(1.0, 0.55, 0.18, 1.0)
	sparks.process_material = pm
	var spark_mesh: SphereMesh = SphereMesh.new()
	spark_mesh.radius = 0.06
	spark_mesh.height = 0.12
	sparks.draw_pass_1 = spark_mesh
	fall.add_child(sparks)
	# Bright orange omni light at the lava basin
	var lt: OmniLight3D = OmniLight3D.new()
	lt.light_color = Color(1.0, 0.55, 0.18)
	lt.light_energy = 4.0
	lt.omni_range = 10.0
	lt.position = Vector3(0, 1.0, 1.85)
	fall.add_child(lt)
	# Cliff collision
	var stb: StaticBody3D = StaticBody3D.new()
	stb.position = Vector3(0, 2.75, 0)
	var cs: CollisionShape3D = CollisionShape3D.new()
	var bs: BoxShape3D = BoxShape3D.new()
	bs.size = Vector3(3.40, 5.50, 2.20)
	cs.shape = bs
	stb.add_child(cs)
	fall.add_child(stb)


func _build_d9_cart_yard(geom: Node) -> void:
	## Epic-9 T30: yard of 3 parked mine carts on parallel rails — empty
	## carts waiting for ore loading.
	var yard: Node3D = Node3D.new()
	yard.name = "D9CartYard"
	yard.position = Vector3(D9_CENTER.x + 18, 0, -16)
	geom.add_child(yard)
	var iron: StandardMaterial3D = StandardMaterial3D.new()
	iron.albedo_color = Color(0.22, 0.20, 0.20)
	iron.metallic = 0.85
	iron.roughness = 0.40
	var wood: StandardMaterial3D = StandardMaterial3D.new()
	wood.albedo_color = Color(0.45, 0.30, 0.18)
	wood.roughness = 0.85
	for i in range(3):
		var slot_root: Node3D = Node3D.new()
		slot_root.position = Vector3(0, 0, i * 2.40)
		yard.add_child(slot_root)
		# Two short rails
		for sz in [-0.45, 0.45]:
			var rail: MeshInstance3D = MeshInstance3D.new()
			var rb: BoxMesh = BoxMesh.new()
			rb.size = Vector3(2.40, 0.10, 0.10)
			rail.mesh = rb
			rail.material_override = iron
			rail.position = Vector3(0, 0.05, sz)
			slot_root.add_child(rail)
		# 3 wooden ties
		for j in range(3):
			var tie: MeshInstance3D = MeshInstance3D.new()
			var tb: BoxMesh = BoxMesh.new()
			tb.size = Vector3(0.30, 0.06, 1.30)
			tie.mesh = tb
			tie.material_override = wood
			tie.position = Vector3(-0.85 + float(j) * 0.85, 0.02, 0)
			slot_root.add_child(tie)
		# Mine cart body (slightly varied positions, mostly empty)
		var cart: MeshInstance3D = MeshInstance3D.new()
		var cb: BoxMesh = BoxMesh.new()
		cb.size = Vector3(1.40, 0.85, 1.10)
		cart.mesh = cb
		cart.material_override = wood
		cart.position = Vector3(-0.20 + float(i) * 0.10, 0.55, 0)
		slot_root.add_child(cart)
		# Iron rim
		var rim: MeshInstance3D = MeshInstance3D.new()
		var rmb: BoxMesh = BoxMesh.new()
		rmb.size = Vector3(1.50, 0.08, 1.20)
		rim.mesh = rmb
		rim.material_override = iron
		rim.position = Vector3(-0.20 + float(i) * 0.10, 0.92, 0)
		slot_root.add_child(rim)
		# 4 torus wheels
		for sx in [-0.55, 0.55]:
			for sz in [-0.45, 0.45]:
				var wheel: MeshInstance3D = MeshInstance3D.new()
				var tm: TorusMesh = TorusMesh.new()
				tm.inner_radius = 0.18
				tm.outer_radius = 0.28
				wheel.mesh = tm
				wheel.material_override = iron
				wheel.position = Vector3(-0.20 + float(i) * 0.10 + sx, 0.20, sz)
				wheel.rotation_degrees = Vector3(0, 0, 90)
				slot_root.add_child(wheel)
		# Cart collision
		var stb: StaticBody3D = StaticBody3D.new()
		stb.position = Vector3(-0.20 + float(i) * 0.10, 0.55, 0)
		var cs: CollisionShape3D = CollisionShape3D.new()
		var bs: BoxShape3D = BoxShape3D.new()
		bs.size = Vector3(1.50, 1.10, 1.20)
		cs.shape = bs
		stb.add_child(cs)
		slot_root.add_child(stb)


func _build_d9_massive_crucible(geom: Node) -> void:
	## Epic-9 T31: massive industrial crucible mounted on a heavy iron swing
	## frame, full of molten metal with a slow tilt animation.
	var crucible: Node3D = Node3D.new()
	crucible.name = "D9MassiveCrucible"
	crucible.position = Vector3(D9_CENTER.x - 22, 0, 6)
	geom.add_child(crucible)
	var iron: StandardMaterial3D = StandardMaterial3D.new()
	iron.albedo_color = Color(0.30, 0.28, 0.30)
	iron.metallic = 0.92
	iron.roughness = 0.40
	var lava_mat: StandardMaterial3D = StandardMaterial3D.new()
	lava_mat.albedo_color = Color(1.0, 0.45, 0.10)
	lava_mat.emission_enabled = true
	lava_mat.emission = Color(1.0, 0.55, 0.18)
	lava_mat.emission_energy_multiplier = 4.5
	lava_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	# Heavy iron base (wide low cylinder)
	var base: MeshInstance3D = MeshInstance3D.new()
	var bcm: CylinderMesh = CylinderMesh.new()
	bcm.top_radius = 1.85
	bcm.bottom_radius = 2.20
	bcm.height = 0.55
	base.mesh = bcm
	base.material_override = iron
	base.position = Vector3(0, 0.27, 0)
	crucible.add_child(base)
	# Two upright support posts
	for sx in [-1.85, 1.85]:
		var post: MeshInstance3D = MeshInstance3D.new()
		var pcm: CylinderMesh = CylinderMesh.new()
		pcm.top_radius = 0.20
		pcm.bottom_radius = 0.25
		pcm.height = 4.20
		post.mesh = pcm
		post.material_override = iron
		post.position = Vector3(sx, 2.65, 0)
		crucible.add_child(post)
		# Per-post collision
		var sb: StaticBody3D = StaticBody3D.new()
		sb.position = Vector3(sx, 2.65, 0)
		var cs: CollisionShape3D = CollisionShape3D.new()
		var cap: CapsuleShape3D = CapsuleShape3D.new()
		cap.radius = 0.30
		cap.height = 4.20
		cs.shape = cap
		sb.add_child(cs)
		crucible.add_child(sb)
	# Pivot axle (horizontal cross-bar at the top of the posts)
	var axle: MeshInstance3D = MeshInstance3D.new()
	var acm: CylinderMesh = CylinderMesh.new()
	acm.top_radius = 0.18
	acm.bottom_radius = 0.18
	acm.height = 4.30
	axle.mesh = acm
	axle.material_override = iron
	axle.position = Vector3(0, 4.50, 0)
	axle.rotation_degrees = Vector3(0, 0, 90)
	crucible.add_child(axle)
	# Crucible body — pivot for tilt animation
	var pivot: Node3D = Node3D.new()
	pivot.position = Vector3(0, 4.50, 0)
	crucible.add_child(pivot)
	# Pot body (deep wide cylinder)
	var pot: MeshInstance3D = MeshInstance3D.new()
	var pcm2: CylinderMesh = CylinderMesh.new()
	pcm2.top_radius = 1.40
	pcm2.bottom_radius = 0.95
	pcm2.height = 1.85
	pot.mesh = pcm2
	pot.material_override = iron
	pot.position = Vector3(0, -0.85, 0)
	pivot.add_child(pot)
	# Reinforcing rim band at the top
	var rim: MeshInstance3D = MeshInstance3D.new()
	var rim_t: TorusMesh = TorusMesh.new()
	rim_t.inner_radius = 1.40
	rim_t.outer_radius = 1.55
	rim.mesh = rim_t
	rim.material_override = iron
	rim.position = Vector3(0, 0.05, 0)
	pivot.add_child(rim)
	# Molten content disc inside
	var lava: MeshInstance3D = MeshInstance3D.new()
	var lcm: CylinderMesh = CylinderMesh.new()
	lcm.top_radius = 1.30
	lcm.bottom_radius = 1.30
	lcm.height = 0.10
	lava.mesh = lcm
	lava.material_override = lava_mat
	lava.position = Vector3(0, -0.05, 0)
	pivot.add_child(lava)
	var pulse: Tween = lava.create_tween().set_loops()
	pulse.tween_property(lava_mat, "emission_energy_multiplier", 6.0, 1.4)
	pulse.tween_property(lava_mat, "emission_energy_multiplier", 3.0, 1.4)
	# Tilt tween (slow oscillation)
	var tilt: Tween = pivot.create_tween().set_loops()
	tilt.tween_property(pivot, "rotation_degrees:z", 8.0, 3.0)
	tilt.tween_property(pivot, "rotation_degrees:z", -8.0, 3.0)
	# Strong omni light
	var lt: OmniLight3D = OmniLight3D.new()
	lt.light_color = Color(1.0, 0.55, 0.18)
	lt.light_energy = 4.5
	lt.omni_range = 12.0
	lt.position = Vector3(0, 4.50, 0)
	crucible.add_child(lt)


func _build_d9_crucible_operator_npc(town: Node) -> void:
	## Epic-9 T32: crucible operator NPC — leather hood, heat-resistant gloves
	## and a long control lever to tilt the crucible.
	var slots: Node3D = town.get_node_or_null("NPCSlots") as Node3D
	if slots == null:
		return
	var slot: Marker3D = Marker3D.new()
	slot.name = "D9CrucibleOperatorSlot"
	slot.position = Vector3(D9_CENTER.x - 25, 0, 6)
	slots.add_child(slot)
	var npc_scene: PackedScene = load("res://scenes/entities/npcs/VillagerR3.tscn") as PackedScene
	if npc_scene == null:
		return
	var npc: Node3D = npc_scene.instantiate() as Node3D
	npc.name = "D9CrucibleOperator"
	if "npc_name" in npc:
		npc.set("npc_name", "Crucible-Hand Smedge")
	if "npc_id" in npc:
		npc.set("npc_id", "d9_crucible_operator")
	slot.add_child(npc)
	# Heavy heat-resistant coat (dark grey)
	var coat_mat: StandardMaterial3D = StandardMaterial3D.new()
	coat_mat.albedo_color = Color(0.32, 0.30, 0.32)
	coat_mat.roughness = 0.85
	var coat: MeshInstance3D = MeshInstance3D.new()
	var cb: BoxMesh = BoxMesh.new()
	cb.size = Vector3(1.05, 1.30, 0.65)
	coat.mesh = cb
	coat.material_override = coat_mat
	coat.position = Vector3(0, 1.05, 0)
	npc.add_child(coat)
	# Hood (sphere top)
	var hood: MeshInstance3D = MeshInstance3D.new()
	var hsm: SphereMesh = SphereMesh.new()
	hsm.radius = 0.40
	hsm.height = 0.70
	hood.mesh = hsm
	hood.material_override = coat_mat
	hood.position = Vector3(0, 1.95, -0.10)
	npc.add_child(hood)
	# Visor slit (orange emissive — heat-tinted glass)
	var visor_mat: StandardMaterial3D = StandardMaterial3D.new()
	visor_mat.albedo_color = Color(1.0, 0.55, 0.18)
	visor_mat.emission_enabled = true
	visor_mat.emission = Color(1.0, 0.55, 0.18)
	visor_mat.emission_energy_multiplier = 1.8
	visor_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var visor: MeshInstance3D = MeshInstance3D.new()
	var vb: BoxMesh = BoxMesh.new()
	vb.size = Vector3(0.45, 0.08, 0.04)
	visor.mesh = vb
	visor.material_override = visor_mat
	visor.position = Vector3(0, 1.95, 0.30)
	npc.add_child(visor)
	# Heavy gloves (oversized box hands)
	var glove_mat: StandardMaterial3D = StandardMaterial3D.new()
	glove_mat.albedo_color = Color(0.28, 0.18, 0.10)
	for sx in [-0.55, 0.55]:
		var glove: MeshInstance3D = MeshInstance3D.new()
		var gb: BoxMesh = BoxMesh.new()
		gb.size = Vector3(0.30, 0.30, 0.30)
		glove.mesh = gb
		glove.material_override = glove_mat
		glove.position = Vector3(sx, 0.85, 0.08)
		npc.add_child(glove)
	# Long control lever held with both hands (long iron pole going up at angle)
	var iron_mat: StandardMaterial3D = StandardMaterial3D.new()
	iron_mat.albedo_color = Color(0.55, 0.55, 0.58)
	iron_mat.metallic = 0.92
	iron_mat.roughness = 0.30
	var lever: MeshInstance3D = MeshInstance3D.new()
	var lcm: CylinderMesh = CylinderMesh.new()
	lcm.top_radius = 0.05
	lcm.bottom_radius = 0.06
	lcm.height = 2.40
	lever.mesh = lcm
	lever.material_override = iron_mat
	lever.position = Vector3(0, 1.50, 0.50)
	lever.rotation_degrees = Vector3(45, 0, 0)
	npc.add_child(lever)
	# Brass grip on the lever
	var brass: StandardMaterial3D = StandardMaterial3D.new()
	brass.albedo_color = Color(0.85, 0.65, 0.20)
	brass.metallic = 0.95
	brass.roughness = 0.20
	var grip: MeshInstance3D = MeshInstance3D.new()
	var gcm: CylinderMesh = CylinderMesh.new()
	gcm.top_radius = 0.08
	gcm.bottom_radius = 0.08
	gcm.height = 0.30
	grip.mesh = gcm
	grip.material_override = brass
	grip.position = Vector3(0, 0.85, -0.15)
	grip.rotation_degrees = Vector3(45, 0, 0)
	npc.add_child(grip)


func _build_d9_forge_spirits(geom: Node) -> void:
	## Epic-9 T33: 8 floating ember spirits drifting around the forge area —
	## small glowing orange spheres on slow orbiting paths.
	var spirits: Node3D = Node3D.new()
	spirits.name = "D9ForgeSpirits"
	spirits.position = Vector3(D9_CENTER.x, 4, 0)
	geom.add_child(spirits)
	var ember_mat: StandardMaterial3D = StandardMaterial3D.new()
	ember_mat.albedo_color = Color(1.0, 0.45, 0.10)
	ember_mat.emission_enabled = true
	ember_mat.emission = Color(1.0, 0.55, 0.18)
	ember_mat.emission_energy_multiplier = 4.5
	ember_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for i in range(8):
		var pivot: Node3D = Node3D.new()
		pivot.rotation_degrees = Vector3(0, float(i) * 45.0, 0)
		spirits.add_child(pivot)
		var spirit: Node3D = Node3D.new()
		spirit.position = Vector3(8.0 + float(i % 3) * 1.5, float(i % 4) * 1.0, 0)
		pivot.add_child(spirit)
		# Ember core
		var core: MeshInstance3D = MeshInstance3D.new()
		var sm: SphereMesh = SphereMesh.new()
		sm.radius = 0.18
		sm.height = 0.36
		core.mesh = sm
		core.material_override = ember_mat
		spirit.add_child(core)
		# Pulse the ember
		var pulse: Tween = core.create_tween().set_loops()
		var phase: float = float(i) * 0.18
		pulse.tween_property(core, "scale", Vector3(1.30, 1.30, 1.30), 0.8 + phase)
		pulse.tween_property(core, "scale", Vector3(0.85, 0.85, 0.85), 0.8 + phase)
		# Orbit tween
		var orbit: Tween = pivot.create_tween().set_loops()
		var orbit_phase: float = float(i) * 0.35
		orbit.tween_property(pivot, "rotation_degrees:y", float(i) * 45.0 + 360.0, 22.0 + orbit_phase).from(float(i) * 45.0)
		# Vertical bob on the spirit itself
		var bob: Tween = spirit.create_tween().set_loops()
		var base_y: float = float(i % 4) * 1.0
		bob.tween_property(spirit, "position:y", base_y + 0.55, 1.4 + phase)
		bob.tween_property(spirit, "position:y", base_y, 1.4 + phase)


func _build_d9_iron_rod_rack(geom: Node) -> void:
	## Epic-9 T34: vertical wooden rack holding 6 glowing-hot iron rods
	## sticking up out of slots, freshly pulled from the forge.
	var rack: Node3D = Node3D.new()
	rack.name = "D9IronRodRack"
	rack.position = Vector3(D9_CENTER.x + 4, 0, 6)
	geom.add_child(rack)
	var wood: StandardMaterial3D = StandardMaterial3D.new()
	wood.albedo_color = Color(0.45, 0.30, 0.18)
	wood.roughness = 0.85
	# Wooden base block (low long box)
	var base: MeshInstance3D = MeshInstance3D.new()
	var bb: BoxMesh = BoxMesh.new()
	bb.size = Vector3(2.20, 0.32, 0.55)
	base.mesh = bb
	base.material_override = wood
	base.position = Vector3(0, 0.16, 0)
	rack.add_child(base)
	# Rod material (glowing emissive iron)
	var rod_mat: StandardMaterial3D = StandardMaterial3D.new()
	rod_mat.albedo_color = Color(1.0, 0.45, 0.10)
	rod_mat.emission_enabled = true
	rod_mat.emission = Color(1.0, 0.55, 0.18)
	rod_mat.emission_energy_multiplier = 3.5
	rod_mat.metallic = 0.55
	rod_mat.roughness = 0.55
	rod_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	# 6 rods sticking up (slightly angled)
	for i in range(6):
		var rod: MeshInstance3D = MeshInstance3D.new()
		var rcm: CylinderMesh = CylinderMesh.new()
		rcm.top_radius = 0.05
		rcm.bottom_radius = 0.06
		rcm.height = 1.40
		rod.mesh = rcm
		rod.material_override = rod_mat
		rod.position = Vector3(-0.85 + float(i) * 0.34, 1.05, 0)
		rod.rotation_degrees = Vector3(randf_range(-4, 4), 0, randf_range(-4, 4))
		rack.add_child(rod)
		# Per-rod ember pulse
		var pulse: Tween = rod.create_tween().set_loops()
		var phase: float = float(i) * 0.12
		pulse.tween_property(rod_mat, "emission_energy_multiplier", 5.0, 0.8 + phase)
		pulse.tween_property(rod_mat, "emission_energy_multiplier", 2.0, 0.8 + phase)
	# Strong orange light from the rack
	var lt: OmniLight3D = OmniLight3D.new()
	lt.light_color = Color(1.0, 0.55, 0.18)
	lt.light_energy = 2.8
	lt.omni_range = 6.0
	lt.position = Vector3(0, 1.40, 0)
	rack.add_child(lt)
	# Rack collision
	var stb: StaticBody3D = StaticBody3D.new()
	stb.position = Vector3(0, 0.85, 0)
	var cs: CollisionShape3D = CollisionShape3D.new()
	var bs: BoxShape3D = BoxShape3D.new()
	bs.size = Vector3(2.20, 1.85, 0.55)
	cs.shape = bs
	stb.add_child(cs)
	rack.add_child(stb)


func _build_d9_slag_heap(geom: Node) -> void:
	## Epic-9 T35: large pile of cooled black slag — irregular dark chunks
	## stacked into a small mound with one or two faintly glowing remnants.
	var heap: Node3D = Node3D.new()
	heap.name = "D9SlagHeap"
	heap.position = Vector3(D9_CENTER.x + 22, 0, 14)
	geom.add_child(heap)
	var slag_mat: StandardMaterial3D = StandardMaterial3D.new()
	slag_mat.albedo_color = Color(0.08, 0.06, 0.08)
	slag_mat.metallic = 0.30
	slag_mat.roughness = 0.55
	# 14 randomized chunk spheres
	for i in range(14):
		var chunk: MeshInstance3D = MeshInstance3D.new()
		var sm: SphereMesh = SphereMesh.new()
		sm.radius = 0.28 + randf() * 0.18
		sm.height = 0.55 + randf() * 0.25
		chunk.mesh = sm
		chunk.material_override = slag_mat
		var ang: float = randf() * TAU
		var rad: float = randf() * 0.85
		chunk.position = Vector3(
			cos(ang) * rad,
			0.18 + float(i) * 0.10,
			sin(ang) * rad
		)
		chunk.scale = Vector3(1.0, 0.65, 1.0)
		heap.add_child(chunk)
	# 2 faintly glowing leftover ember chunks
	var ember_mat: StandardMaterial3D = StandardMaterial3D.new()
	ember_mat.albedo_color = Color(0.55, 0.20, 0.05)
	ember_mat.emission_enabled = true
	ember_mat.emission = Color(1.0, 0.40, 0.10)
	ember_mat.emission_energy_multiplier = 1.4
	for k in range(2):
		var ember: MeshInstance3D = MeshInstance3D.new()
		var esm: SphereMesh = SphereMesh.new()
		esm.radius = 0.18
		esm.height = 0.36
		ember.mesh = esm
		ember.material_override = ember_mat
		ember.position = Vector3(-0.35 + float(k) * 0.65, 1.45, 0)
		heap.add_child(ember)
	# Heap collision
	var stb: StaticBody3D = StaticBody3D.new()
	stb.position = Vector3(0, 0.75, 0)
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cyl: CylinderShape3D = CylinderShape3D.new()
	cyl.radius = 1.40
	cyl.height = 1.50
	cs.shape = cyl
	stb.add_child(cs)
	heap.add_child(stb)


func _build_d9_obsidian_shards(geom: Node) -> void:
	## Epic-9 T36: 6 angular obsidian shard formations rising from the ground
	## like dark crystal blades, with subtle red inner emission.
	var shards: Node3D = Node3D.new()
	shards.name = "D9ObsidianShards"
	shards.position = Vector3(D9_CENTER.x, 0, 0)
	geom.add_child(shards)
	var obs_mat: StandardMaterial3D = StandardMaterial3D.new()
	obs_mat.albedo_color = Color(0.06, 0.05, 0.08)
	obs_mat.metallic = 0.7
	obs_mat.roughness = 0.20
	obs_mat.emission_enabled = true
	obs_mat.emission = Color(0.85, 0.18, 0.10)
	obs_mat.emission_energy_multiplier = 0.40
	var spots: Array[Vector3] = [
		Vector3(-26, 0, -16),
		Vector3(28, 0, -14),
		Vector3(-24, 0, 14),
		Vector3(26, 0, 16),
		Vector3(-30, 0, 0),
		Vector3(30, 0, 4),
	]
	for i in range(spots.size()):
		var pos: Vector3 = spots[i]
		var formation: Node3D = Node3D.new()
		formation.position = pos
		formation.rotation_degrees = Vector3(0, float(i) * 32.0, 0)
		shards.add_child(formation)
		# 3 shards per formation (different sizes)
		var heights: Array[float] = [3.5, 2.6, 2.2]
		var offsets: Array[Vector3] = [
			Vector3(0, 0, 0),
			Vector3(0.85, 0, 0.45),
			Vector3(-0.65, 0, 0.55),
		]
		for j in range(3):
			var shard: MeshInstance3D = MeshInstance3D.new()
			var pm: PrismMesh = PrismMesh.new()
			pm.size = Vector3(0.85, heights[j], 0.55)
			shard.mesh = pm
			shard.material_override = obs_mat
			shard.position = offsets[j] + Vector3(0, heights[j] * 0.5, 0)
			shard.rotation_degrees = Vector3(randf_range(-12, 12), randf_range(-30, 30), randf_range(-12, 12))
			formation.add_child(shard)
		# Single capsule collision per formation
		var stb: StaticBody3D = StaticBody3D.new()
		stb.position = Vector3(0, 1.75, 0)
		var cs: CollisionShape3D = CollisionShape3D.new()
		var cap: CapsuleShape3D = CapsuleShape3D.new()
		cap.radius = 0.85
		cap.height = 3.50
		cs.shape = cap
		stb.add_child(cs)
		formation.add_child(stb)


func _build_d9_lava_lake(geom: Node) -> void:
	## Epic-9 T37: large lava lake with 5 stone stepping stones across it.
	var lake: Node3D = Node3D.new()
	lake.name = "D9LavaLake"
	lake.position = Vector3(D9_CENTER.x + 32, 0.05, 0)
	geom.add_child(lake)
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.18, 0.14, 0.16)
	stone_mat.roughness = 0.85
	var lava_mat: StandardMaterial3D = StandardMaterial3D.new()
	lava_mat.albedo_color = Color(1.0, 0.42, 0.10)
	lava_mat.emission_enabled = true
	lava_mat.emission = Color(1.0, 0.55, 0.18)
	lava_mat.emission_energy_multiplier = 4.0
	lava_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	# Stone curb (low ring around the lake)
	var curb: MeshInstance3D = MeshInstance3D.new()
	var ccm: TorusMesh = TorusMesh.new()
	ccm.inner_radius = 5.5
	ccm.outer_radius = 6.5
	curb.mesh = ccm
	curb.material_override = stone_mat
	curb.position = Vector3(0, 0.10, 0)
	curb.rotation_degrees = Vector3(90, 0, 0)
	lake.add_child(curb)
	# Lava surface (wide flat cylinder)
	var surface: MeshInstance3D = MeshInstance3D.new()
	var lcm: CylinderMesh = CylinderMesh.new()
	lcm.top_radius = 5.50
	lcm.bottom_radius = 5.50
	lcm.height = 0.10
	surface.mesh = lcm
	surface.material_override = lava_mat
	surface.position = Vector3(0, 0.18, 0)
	lake.add_child(surface)
	var pulse: Tween = surface.create_tween().set_loops()
	pulse.tween_property(lava_mat, "emission_energy_multiplier", 5.5, 1.6)
	pulse.tween_property(lava_mat, "emission_energy_multiplier", 2.5, 1.6)
	# 5 stone stepping stones across the middle (a curving path)
	var step_pos: Array[Vector3] = [
		Vector3(-3.5, 0.45, -1.5),
		Vector3(-1.8, 0.45, 0.5),
		Vector3(0.0, 0.45, -0.8),
		Vector3(1.8, 0.45, 0.5),
		Vector3(3.5, 0.45, -1.5),
	]
	for p in step_pos:
		var stone: MeshInstance3D = MeshInstance3D.new()
		var sm: SphereMesh = SphereMesh.new()
		sm.radius = 0.55
		sm.height = 0.65
		stone.mesh = sm
		stone.material_override = stone_mat
		stone.position = p
		stone.scale = Vector3(1.0, 0.45, 1.0)
		lake.add_child(stone)
		# Per-stone collision (small)
		var sb: StaticBody3D = StaticBody3D.new()
		sb.position = p
		var cs: CollisionShape3D = CollisionShape3D.new()
		var cyl: CylinderShape3D = CylinderShape3D.new()
		cyl.radius = 0.55
		cyl.height = 0.40
		cs.shape = cyl
		sb.add_child(cs)
		lake.add_child(sb)
	# Strong omni light
	var lt: OmniLight3D = OmniLight3D.new()
	lt.light_color = Color(1.0, 0.55, 0.18)
	lt.light_energy = 6.0
	lt.omni_range = 18.0
	lt.position = Vector3(0, 1.5, 0)
	lake.add_child(lt)


func _build_d9_geode_display(geom: Node) -> void:
	## Epic-9 T38: cracked open geode on a stone pedestal — outer dark shell
	## hides a cluster of glowing cyan crystals inside.
	var geode: Node3D = Node3D.new()
	geode.name = "D9GeodeDisplay"
	geode.position = Vector3(D9_CENTER.x - 8, 0, 14)
	geom.add_child(geode)
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.42, 0.40, 0.42)
	stone_mat.roughness = 0.85
	var shell_mat: StandardMaterial3D = StandardMaterial3D.new()
	shell_mat.albedo_color = Color(0.30, 0.22, 0.18)
	shell_mat.roughness = 0.75
	var crystal_mat: StandardMaterial3D = StandardMaterial3D.new()
	crystal_mat.albedo_color = Color(0.30, 0.85, 0.95)
	crystal_mat.emission_enabled = true
	crystal_mat.emission = Color(0.40, 0.95, 1.0)
	crystal_mat.emission_energy_multiplier = 2.5
	crystal_mat.metallic = 0.55
	crystal_mat.roughness = 0.20
	# Stone pedestal
	var ped: MeshInstance3D = MeshInstance3D.new()
	var pcm: CylinderMesh = CylinderMesh.new()
	pcm.top_radius = 0.85
	pcm.bottom_radius = 1.00
	pcm.height = 1.10
	ped.mesh = pcm
	ped.material_override = stone_mat
	ped.position = Vector3(0, 0.55, 0)
	geode.add_child(ped)
	# Geode bottom half (open cup)
	var bowl: MeshInstance3D = MeshInstance3D.new()
	var bsm: SphereMesh = SphereMesh.new()
	bsm.radius = 0.85
	bsm.height = 1.40
	bowl.mesh = bsm
	bowl.material_override = shell_mat
	bowl.scale = Vector3(1.0, 0.55, 1.0)
	bowl.position = Vector3(0, 1.30, 0)
	geode.add_child(bowl)
	# Inner crystals (5 cone spires of varying heights)
	var heights: Array[float] = [0.65, 0.85, 0.55, 0.75, 0.45]
	var positions: Array[Vector3] = [
		Vector3(0, 0, 0),
		Vector3(0.30, 0, 0.10),
		Vector3(-0.30, 0, -0.05),
		Vector3(0.10, 0, -0.30),
		Vector3(-0.20, 0, 0.30),
	]
	for i in range(5):
		var crystal: MeshInstance3D = MeshInstance3D.new()
		var ccm: CylinderMesh = CylinderMesh.new()
		ccm.top_radius = 0.0
		ccm.bottom_radius = 0.14
		ccm.height = heights[i]
		crystal.mesh = ccm
		crystal.material_override = crystal_mat
		crystal.position = positions[i] + Vector3(0, 1.45 + heights[i] * 0.5, 0)
		crystal.rotation_degrees = Vector3(randf_range(-8, 8), 0, randf_range(-8, 8))
		geode.add_child(crystal)
	# Pulse the crystals together
	var pulse: Tween = bowl.create_tween().set_loops()
	pulse.tween_property(crystal_mat, "emission_energy_multiplier", 4.0, 1.4)
	pulse.tween_property(crystal_mat, "emission_energy_multiplier", 1.8, 1.4)
	# Cyan light from the geode
	var lt: OmniLight3D = OmniLight3D.new()
	lt.light_color = Color(0.40, 0.85, 0.95)
	lt.light_energy = 2.5
	lt.omni_range = 5.5
	lt.position = Vector3(0, 1.65, 0)
	geode.add_child(lt)
	# Pedestal collision
	var stb: StaticBody3D = StaticBody3D.new()
	stb.position = Vector3(0, 0.55, 0)
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cyl: CylinderShape3D = CylinderShape3D.new()
	cyl.radius = 1.00
	cyl.height = 1.10
	cs.shape = cyl
	stb.add_child(cs)
	geode.add_child(stb)


func _build_d9_forge_sage_npc(town: Node) -> void:
	## Epic-9 T39: mystic forge sage NPC — robed figure with a glowing
	## staff topped by a forge ember orb.
	var slots: Node3D = town.get_node_or_null("NPCSlots") as Node3D
	if slots == null:
		return
	var slot: Marker3D = Marker3D.new()
	slot.name = "D9ForgeSageSlot"
	slot.position = Vector3(D9_CENTER.x - 6, 0, 14)
	slots.add_child(slot)
	var npc_scene: PackedScene = load("res://scenes/entities/npcs/VillagerR3.tscn") as PackedScene
	if npc_scene == null:
		return
	var npc: Node3D = npc_scene.instantiate() as Node3D
	npc.name = "D9ForgeSage"
	if "npc_name" in npc:
		npc.set("npc_name", "Sage Ember")
	if "npc_id" in npc:
		npc.set("npc_id", "d9_forge_sage")
	slot.add_child(npc)
	# Long dark red robe
	var robe_mat: StandardMaterial3D = StandardMaterial3D.new()
	robe_mat.albedo_color = Color(0.40, 0.10, 0.05)
	robe_mat.roughness = 0.85
	var robe: MeshInstance3D = MeshInstance3D.new()
	var rb: BoxMesh = BoxMesh.new()
	rb.size = Vector3(0.95, 1.75, 0.65)
	robe.mesh = rb
	robe.material_override = robe_mat
	robe.position = Vector3(0, 0.95, 0)
	npc.add_child(robe)
	# Hood
	var hood: MeshInstance3D = MeshInstance3D.new()
	var hsm: SphereMesh = SphereMesh.new()
	hsm.radius = 0.40
	hsm.height = 0.65
	hood.mesh = hsm
	hood.material_override = robe_mat
	hood.position = Vector3(0, 1.95, -0.05)
	npc.add_child(hood)
	# Glowing forge mark on chest (orange disc)
	var mark_mat: StandardMaterial3D = StandardMaterial3D.new()
	mark_mat.albedo_color = Color(1.0, 0.55, 0.18)
	mark_mat.emission_enabled = true
	mark_mat.emission = Color(1.0, 0.55, 0.18)
	mark_mat.emission_energy_multiplier = 2.2
	mark_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var mark: MeshInstance3D = MeshInstance3D.new()
	var mscm: SphereMesh = SphereMesh.new()
	mscm.radius = 0.18
	mscm.height = 0.10
	mark.mesh = mscm
	mark.material_override = mark_mat
	mark.position = Vector3(0, 1.20, 0.34)
	npc.add_child(mark)
	# Forge staff (wooden haft + ember orb on top)
	var wood_mat: StandardMaterial3D = StandardMaterial3D.new()
	wood_mat.albedo_color = Color(0.45, 0.30, 0.18)
	wood_mat.roughness = 0.85
	var staff: MeshInstance3D = MeshInstance3D.new()
	var scm: CylinderMesh = CylinderMesh.new()
	scm.top_radius = 0.05
	scm.bottom_radius = 0.06
	scm.height = 2.20
	staff.mesh = scm
	staff.material_override = wood_mat
	staff.position = Vector3(0.55, 1.10, 0)
	npc.add_child(staff)
	# Ember orb
	var orb_mat: StandardMaterial3D = StandardMaterial3D.new()
	orb_mat.albedo_color = Color(1.0, 0.45, 0.10)
	orb_mat.emission_enabled = true
	orb_mat.emission = Color(1.0, 0.55, 0.18)
	orb_mat.emission_energy_multiplier = 4.5
	orb_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var orb: MeshInstance3D = MeshInstance3D.new()
	var osm: SphereMesh = SphereMesh.new()
	osm.radius = 0.20
	osm.height = 0.40
	orb.mesh = osm
	orb.material_override = orb_mat
	orb.position = Vector3(0.55, 2.30, 0)
	npc.add_child(orb)
	var pulse: Tween = orb.create_tween().set_loops()
	pulse.tween_property(orb_mat, "emission_energy_multiplier", 6.5, 1.0)
	pulse.tween_property(orb_mat, "emission_energy_multiplier", 2.5, 1.0)
	# Orange light from the staff orb
	var lt: OmniLight3D = OmniLight3D.new()
	lt.light_color = Color(1.0, 0.55, 0.18)
	lt.light_energy = 2.5
	lt.omni_range = 5.5
	lt.position = Vector3(0.55, 2.30, 0)
	npc.add_child(lt)


func _build_d9_brimstone_fumaroles(geom: Node) -> void:
	## Epic-9 T40: 5 small brimstone fumaroles puffing yellow sulphur gas.
	var fums: Node3D = Node3D.new()
	fums.name = "D9BrimstoneFumaroles"
	fums.position = Vector3(D9_CENTER.x, 0.05, 0)
	geom.add_child(fums)
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.55, 0.45, 0.18)
	stone_mat.roughness = 0.85
	var spots: Array[Vector3] = [
		Vector3(-20, 0, -4),
		Vector3(18, 0, 14),
		Vector3(-6, 0, -16),
		Vector3(20, 0, 4),
		Vector3(-22, 0, 18),
	]
	for i in range(spots.size()):
		var pos: Vector3 = spots[i]
		var fum: Node3D = Node3D.new()
		fum.position = pos
		fums.add_child(fum)
		# Sulphur-stained stone mound (small flat cone)
		var mound: MeshInstance3D = MeshInstance3D.new()
		var mcm: CylinderMesh = CylinderMesh.new()
		mcm.top_radius = 0.20
		mcm.bottom_radius = 0.55
		mcm.height = 0.40
		mound.mesh = mcm
		mound.material_override = stone_mat
		mound.position = Vector3(0, 0.20, 0)
		fum.add_child(mound)
		# Yellow gas GPU particles
		var gas: GPUParticles3D = GPUParticles3D.new()
		gas.position = Vector3(0, 0.45, 0)
		gas.amount = 30
		gas.lifetime = 3.5
		var pm: ParticleProcessMaterial = ParticleProcessMaterial.new()
		pm.direction = Vector3(0, 1, 0)
		pm.spread = 22.0
		pm.initial_velocity_min = 0.45
		pm.initial_velocity_max = 0.95
		pm.gravity = Vector3(0, 0.30, 0)
		pm.scale_min = 0.22
		pm.scale_max = 0.55
		pm.color = Color(0.92, 0.92, 0.30, 0.55)
		gas.process_material = pm
		var sm: SphereMesh = SphereMesh.new()
		sm.radius = 0.20
		sm.height = 0.40
		gas.draw_pass_1 = sm
		fum.add_child(gas)


func _build_d9_training_arena(geom: Node) -> void:
	## Epic-9 T41: combat training arena — circular sand pit ringed by 8
	## stone bollards with iron chain links between them.
	var arena: Node3D = Node3D.new()
	arena.name = "D9TrainingArena"
	arena.position = Vector3(D9_CENTER.x + 2, 0.05, -16)
	geom.add_child(arena)
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.42, 0.40, 0.42)
	stone_mat.roughness = 0.85
	var sand_mat: StandardMaterial3D = StandardMaterial3D.new()
	sand_mat.albedo_color = Color(0.55, 0.42, 0.25)
	sand_mat.roughness = 0.85
	var iron_mat: StandardMaterial3D = StandardMaterial3D.new()
	iron_mat.albedo_color = Color(0.20, 0.18, 0.20)
	iron_mat.metallic = 0.85
	iron_mat.roughness = 0.40
	# Sand floor (wide flat cylinder)
	var floor: MeshInstance3D = MeshInstance3D.new()
	var fcm: CylinderMesh = CylinderMesh.new()
	fcm.top_radius = 4.50
	fcm.bottom_radius = 4.50
	fcm.height = 0.10
	floor.mesh = fcm
	floor.material_override = sand_mat
	floor.position = Vector3(0, 0.05, 0)
	arena.add_child(floor)
	# 8 bollards in a ring
	for i in range(8):
		var ang: float = float(i) * (TAU / 8.0)
		var radius: float = 4.85
		var bollard: MeshInstance3D = MeshInstance3D.new()
		var pcm: CylinderMesh = CylinderMesh.new()
		pcm.top_radius = 0.30
		pcm.bottom_radius = 0.36
		pcm.height = 1.20
		bollard.mesh = pcm
		bollard.material_override = stone_mat
		bollard.position = Vector3(cos(ang) * radius, 0.60, sin(ang) * radius)
		arena.add_child(bollard)
		# Per-bollard collision
		var sb: StaticBody3D = StaticBody3D.new()
		sb.position = Vector3(cos(ang) * radius, 0.60, sin(ang) * radius)
		var cs: CollisionShape3D = CollisionShape3D.new()
		var cap: CapsuleShape3D = CapsuleShape3D.new()
		cap.radius = 0.36
		cap.height = 1.20
		cs.shape = cap
		sb.add_child(cs)
		arena.add_child(sb)
	# Iron chain torus links between adjacent bollards
	for i in range(8):
		var ang_a: float = float(i) * (TAU / 8.0)
		var ang_b: float = float(i + 1) * (TAU / 8.0)
		var mid: Vector3 = Vector3(
			(cos(ang_a) + cos(ang_b)) * 0.5 * 4.85,
			0.95,
			(sin(ang_a) + sin(ang_b)) * 0.5 * 4.85
		)
		var link: MeshInstance3D = MeshInstance3D.new()
		var tm: TorusMesh = TorusMesh.new()
		tm.inner_radius = 0.18
		tm.outer_radius = 0.26
		link.mesh = tm
		link.material_override = iron_mat
		link.position = mid
		link.rotation_degrees = Vector3(90, -rad_to_deg((ang_a + ang_b) * 0.5), 0)
		arena.add_child(link)


func _build_d9_iron_dummy(geom: Node) -> void:
	## Epic-9 T42: iron training dummy — stone pedestal with a tall iron
	## post and a humanoid torso, slightly dented and battered.
	var dummy: Node3D = Node3D.new()
	dummy.name = "D9IronDummy"
	dummy.position = Vector3(D9_CENTER.x + 2, 0, -16)
	geom.add_child(dummy)
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.42, 0.40, 0.42)
	stone_mat.roughness = 0.85
	var iron_mat: StandardMaterial3D = StandardMaterial3D.new()
	iron_mat.albedo_color = Color(0.45, 0.45, 0.50)
	iron_mat.metallic = 0.85
	iron_mat.roughness = 0.50
	# Stone pedestal
	var ped: MeshInstance3D = MeshInstance3D.new()
	var pcm: CylinderMesh = CylinderMesh.new()
	pcm.top_radius = 0.55
	pcm.bottom_radius = 0.65
	pcm.height = 0.45
	ped.mesh = pcm
	ped.material_override = stone_mat
	ped.position = Vector3(0, 0.22, 0)
	dummy.add_child(ped)
	# Vertical iron post
	var post: MeshInstance3D = MeshInstance3D.new()
	var post_cm: CylinderMesh = CylinderMesh.new()
	post_cm.top_radius = 0.12
	post_cm.bottom_radius = 0.15
	post_cm.height = 1.85
	post.mesh = post_cm
	post.material_override = iron_mat
	post.position = Vector3(0, 1.40, 0)
	dummy.add_child(post)
	# Iron torso (chest box)
	var torso: MeshInstance3D = MeshInstance3D.new()
	var tb: BoxMesh = BoxMesh.new()
	tb.size = Vector3(0.85, 0.95, 0.55)
	torso.mesh = tb
	torso.material_override = iron_mat
	torso.position = Vector3(0, 2.00, 0)
	dummy.add_child(torso)
	# Iron head (sphere)
	var head: MeshInstance3D = MeshInstance3D.new()
	var hsm: SphereMesh = SphereMesh.new()
	hsm.radius = 0.28
	hsm.height = 0.55
	head.mesh = hsm
	head.material_override = iron_mat
	head.position = Vector3(0, 2.75, 0)
	dummy.add_child(head)
	# Battle scars (3 small dark scratch boxes on the torso)
	var scar_mat: StandardMaterial3D = StandardMaterial3D.new()
	scar_mat.albedo_color = Color(0.10, 0.08, 0.10)
	for sy in [0.25, -0.05, -0.30]:
		var scar: MeshInstance3D = MeshInstance3D.new()
		var scrb: BoxMesh = BoxMesh.new()
		scrb.size = Vector3(0.45, 0.04, 0.04)
		scar.mesh = scrb
		scar.material_override = scar_mat
		scar.position = Vector3(0, 2.00 + sy, 0.30)
		scar.rotation_degrees = Vector3(0, 0, randf_range(-15, 15))
		dummy.add_child(scar)
	# Slight wobble tween
	var wobble: Tween = post.create_tween().set_loops()
	wobble.tween_property(post, "rotation_degrees:z", 3.0, 1.6)
	wobble.tween_property(post, "rotation_degrees:z", -3.0, 1.6)
	# Dummy collision
	var stb: StaticBody3D = StaticBody3D.new()
	stb.position = Vector3(0, 1.40, 0)
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cap: CapsuleShape3D = CapsuleShape3D.new()
	cap.radius = 0.55
	cap.height = 2.85
	cs.shape = cap
	stb.add_child(cs)
	dummy.add_child(stb)


func _build_d9_battle_smith_npc(town: Node) -> void:
	## Epic-9 T43: battle smith trainer NPC — half-armored figure with a
	## demonstration sword raised in a guard stance.
	var slots: Node3D = town.get_node_or_null("NPCSlots") as Node3D
	if slots == null:
		return
	var slot: Marker3D = Marker3D.new()
	slot.name = "D9BattleSmithSlot"
	slot.position = Vector3(D9_CENTER.x + 6, 0, -14)
	slots.add_child(slot)
	var npc_scene: PackedScene = load("res://scenes/entities/npcs/VillagerR3.tscn") as PackedScene
	if npc_scene == null:
		return
	var npc: Node3D = npc_scene.instantiate() as Node3D
	npc.name = "D9BattleSmith"
	if "npc_name" in npc:
		npc.set("npc_name", "Battle Smith Vael")
	if "npc_id" in npc:
		npc.set("npc_id", "d9_battle_smith")
	slot.add_child(npc)
	# Steel chest plate
	var steel: StandardMaterial3D = StandardMaterial3D.new()
	steel.albedo_color = Color(0.55, 0.58, 0.62)
	steel.metallic = 0.85
	steel.roughness = 0.30
	var chest: MeshInstance3D = MeshInstance3D.new()
	var cb: BoxMesh = BoxMesh.new()
	cb.size = Vector3(0.95, 1.00, 0.55)
	chest.mesh = cb
	chest.material_override = steel
	chest.position = Vector3(0, 1.10, 0)
	npc.add_child(chest)
	# Brass shoulder pauldrons
	var brass: StandardMaterial3D = StandardMaterial3D.new()
	brass.albedo_color = Color(0.85, 0.65, 0.20)
	brass.metallic = 0.95
	brass.roughness = 0.20
	for sx in [-0.55, 0.55]:
		var pld: MeshInstance3D = MeshInstance3D.new()
		var psm: SphereMesh = SphereMesh.new()
		psm.radius = 0.22
		psm.height = 0.40
		pld.mesh = psm
		pld.material_override = brass
		pld.position = Vector3(sx, 1.50, 0)
		npc.add_child(pld)
	# Open helmet (no visor — face exposed)
	var helm: MeshInstance3D = MeshInstance3D.new()
	var hsm: SphereMesh = SphereMesh.new()
	hsm.radius = 0.30
	hsm.height = 0.50
	helm.mesh = hsm
	helm.material_override = steel
	helm.position = Vector3(0, 1.95, -0.05)
	npc.add_child(helm)
	# Demonstration sword raised in guard (vertical, hand grip)
	var sword_root: Node3D = Node3D.new()
	sword_root.position = Vector3(0.55, 1.20, 0.20)
	sword_root.rotation_degrees = Vector3(0, 0, 0)
	npc.add_child(sword_root)
	var blade_mat: StandardMaterial3D = StandardMaterial3D.new()
	blade_mat.albedo_color = Color(0.78, 0.82, 0.88)
	blade_mat.metallic = 0.92
	blade_mat.roughness = 0.20
	blade_mat.emission_enabled = true
	blade_mat.emission = Color(0.85, 0.92, 1.0)
	blade_mat.emission_energy_multiplier = 0.35
	var blade: MeshInstance3D = MeshInstance3D.new()
	var blb: BoxMesh = BoxMesh.new()
	blb.size = Vector3(0.10, 1.30, 0.04)
	blade.mesh = blb
	blade.material_override = blade_mat
	blade.position = Vector3(0, 0.95, 0)
	sword_root.add_child(blade)
	var crossguard: MeshInstance3D = MeshInstance3D.new()
	var cgb: BoxMesh = BoxMesh.new()
	cgb.size = Vector3(0.30, 0.05, 0.05)
	crossguard.mesh = cgb
	crossguard.material_override = brass
	crossguard.position = Vector3(0, 0.25, 0)
	sword_root.add_child(crossguard)
	var hilt: MeshInstance3D = MeshInstance3D.new()
	var hb: BoxMesh = BoxMesh.new()
	hb.size = Vector3(0.06, 0.20, 0.04)
	hilt.mesh = hb
	hilt.material_override = brass
	hilt.position = Vector3(0, 0.10, 0)
	sword_root.add_child(hilt)
	# Slow guard adjustment tween
	var sway: Tween = sword_root.create_tween().set_loops()
	sway.tween_property(sword_root, "rotation_degrees:z", 5.0, 1.4)
	sway.tween_property(sword_root, "rotation_degrees:z", -5.0, 1.4)


func _build_d9_practice_weapon_stand(geom: Node) -> void:
	## Epic-9 T44: stand of 4 wooden practice weapons leaning against a
	## stone block — bokken, training axe, training mace, training spear.
	var stand: Node3D = Node3D.new()
	stand.name = "D9PracticeWeaponStand"
	stand.position = Vector3(D9_CENTER.x - 4, 0, -14)
	geom.add_child(stand)
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.42, 0.40, 0.42)
	stone_mat.roughness = 0.85
	var wood: StandardMaterial3D = StandardMaterial3D.new()
	wood.albedo_color = Color(0.55, 0.38, 0.22)
	wood.roughness = 0.85
	# Stone block base
	var block: MeshInstance3D = MeshInstance3D.new()
	var bb: BoxMesh = BoxMesh.new()
	bb.size = Vector3(1.40, 0.85, 0.85)
	block.mesh = bb
	block.material_override = stone_mat
	block.position = Vector3(0, 0.42, 0)
	stand.add_child(block)
	# 4 weapons leaning against the block
	# Bokken (long wooden sword)
	var bokken: MeshInstance3D = MeshInstance3D.new()
	var bok: BoxMesh = BoxMesh.new()
	bok.size = Vector3(0.10, 1.30, 0.04)
	bokken.mesh = bok
	bokken.material_override = wood
	bokken.position = Vector3(-0.55, 1.10, -0.45)
	bokken.rotation_degrees = Vector3(0, 0, 22)
	stand.add_child(bokken)
	# Training axe (haft + wooden head)
	var axe_haft: MeshInstance3D = MeshInstance3D.new()
	var ahcm: CylinderMesh = CylinderMesh.new()
	ahcm.top_radius = 0.05
	ahcm.bottom_radius = 0.06
	ahcm.height = 1.30
	axe_haft.mesh = ahcm
	axe_haft.material_override = wood
	axe_haft.position = Vector3(-0.20, 1.10, -0.45)
	axe_haft.rotation_degrees = Vector3(0, 0, 18)
	stand.add_child(axe_haft)
	var axe_head: MeshInstance3D = MeshInstance3D.new()
	var ahb: BoxMesh = BoxMesh.new()
	ahb.size = Vector3(0.30, 0.18, 0.06)
	axe_head.mesh = ahb
	axe_head.material_override = wood
	axe_head.position = Vector3(-0.04, 1.65, -0.45)
	axe_head.rotation_degrees = Vector3(0, 0, 18)
	stand.add_child(axe_head)
	# Training mace (haft + spherical head)
	var mace_haft: MeshInstance3D = MeshInstance3D.new()
	mace_haft.mesh = ahcm
	mace_haft.material_override = wood
	mace_haft.position = Vector3(0.20, 1.10, -0.45)
	mace_haft.rotation_degrees = Vector3(0, 0, 14)
	stand.add_child(mace_haft)
	var mace_head: MeshInstance3D = MeshInstance3D.new()
	var mhsm: SphereMesh = SphereMesh.new()
	mhsm.radius = 0.16
	mhsm.height = 0.32
	mace_head.mesh = mhsm
	mace_head.material_override = wood
	mace_head.position = Vector3(0.36, 1.70, -0.45)
	stand.add_child(mace_head)
	# Training spear (long thin pole + small wooden tip)
	var spear: MeshInstance3D = MeshInstance3D.new()
	var spcm: CylinderMesh = CylinderMesh.new()
	spcm.top_radius = 0.04
	spcm.bottom_radius = 0.05
	spcm.height = 1.85
	spear.mesh = spcm
	spear.material_override = wood
	spear.position = Vector3(0.55, 1.30, -0.45)
	spear.rotation_degrees = Vector3(0, 0, 10)
	stand.add_child(spear)
	var spear_tip: MeshInstance3D = MeshInstance3D.new()
	var sptm: CylinderMesh = CylinderMesh.new()
	sptm.top_radius = 0.0
	sptm.bottom_radius = 0.06
	sptm.height = 0.20
	spear_tip.mesh = sptm
	spear_tip.material_override = wood
	spear_tip.position = Vector3(0.66, 2.20, -0.45)
	stand.add_child(spear_tip)
	# Stand collision (block)
	var stb: StaticBody3D = StaticBody3D.new()
	stb.position = Vector3(0, 0.42, 0)
	var cs: CollisionShape3D = CollisionShape3D.new()
	var bs: BoxShape3D = BoxShape3D.new()
	bs.size = Vector3(1.40, 0.85, 0.85)
	cs.shape = bs
	stb.add_child(cs)
	stand.add_child(stb)


func _build_d9_cooling_rack(geom: Node) -> void:
	## Epic-9 T45: long iron cooling rack with 5 finished blade swords laid
	## across the bars, glowing red and slowly cooling.
	var rack: Node3D = Node3D.new()
	rack.name = "D9CoolingRack"
	rack.position = Vector3(D9_CENTER.x - 12, 0, -8)
	geom.add_child(rack)
	var iron_mat: StandardMaterial3D = StandardMaterial3D.new()
	iron_mat.albedo_color = Color(0.45, 0.42, 0.40)
	iron_mat.metallic = 0.7
	iron_mat.roughness = 0.45
	# Two long parallel iron bars on legs
	for sz in [-0.30, 0.30]:
		var bar: MeshInstance3D = MeshInstance3D.new()
		var bcm: CylinderMesh = CylinderMesh.new()
		bcm.top_radius = 0.06
		bcm.bottom_radius = 0.06
		bcm.height = 2.20
		bar.mesh = bcm
		bar.material_override = iron_mat
		bar.position = Vector3(0, 1.05, sz)
		bar.rotation_degrees = Vector3(0, 0, 90)
		rack.add_child(bar)
	# 4 corner legs
	for sx in [-1.0, 1.0]:
		for sz in [-0.30, 0.30]:
			var leg: MeshInstance3D = MeshInstance3D.new()
			var lcm: CylinderMesh = CylinderMesh.new()
			lcm.top_radius = 0.06
			lcm.bottom_radius = 0.08
			lcm.height = 1.05
			leg.mesh = lcm
			leg.material_override = iron_mat
			leg.position = Vector3(sx, 0.52, sz)
			rack.add_child(leg)
	# 5 cooling blade swords laid across
	var hot_mat: StandardMaterial3D = StandardMaterial3D.new()
	hot_mat.albedo_color = Color(0.85, 0.30, 0.10)
	hot_mat.metallic = 0.55
	hot_mat.roughness = 0.55
	hot_mat.emission_enabled = true
	hot_mat.emission = Color(1.0, 0.40, 0.10)
	hot_mat.emission_energy_multiplier = 2.5
	for i in range(5):
		var blade: MeshInstance3D = MeshInstance3D.new()
		var blb: BoxMesh = BoxMesh.new()
		blb.size = Vector3(1.10, 0.05, 0.10)
		blade.mesh = blb
		blade.material_override = hot_mat
		blade.position = Vector3(-0.85 + float(i) * 0.42, 1.13, 0)
		blade.rotation_degrees = Vector3(0, 0, 0)
		rack.add_child(blade)
		var pulse: Tween = blade.create_tween().set_loops()
		var phase: float = float(i) * 0.18
		pulse.tween_property(hot_mat, "emission_energy_multiplier", 4.0, 1.0 + phase)
		pulse.tween_property(hot_mat, "emission_energy_multiplier", 1.4, 1.0 + phase)
	# Orange omni light
	var lt: OmniLight3D = OmniLight3D.new()
	lt.light_color = Color(1.0, 0.55, 0.18)
	lt.light_energy = 2.5
	lt.omni_range = 5.5
	lt.position = Vector3(0, 1.40, 0)
	rack.add_child(lt)
	# Rack collision
	var stb: StaticBody3D = StaticBody3D.new()
	stb.position = Vector3(0, 0.85, 0)
	var cs: CollisionShape3D = CollisionShape3D.new()
	var bs: BoxShape3D = BoxShape3D.new()
	bs.size = Vector3(2.20, 1.40, 0.85)
	cs.shape = bs
	stb.add_child(cs)
	rack.add_child(stb)


func _build_d9_lava_forge_cracks(geom: Node) -> void:
	## Epic-9 T46: 12 jagged emissive crack planes radiating from the
	## mid-boss arena center. Visual warning that the player is entering
	## a high-danger combat zone.
	var pivot: Node3D = Node3D.new()
	pivot.name = "D9_LavaForgeCracks"
	pivot.position = D9_CENTER + Vector3(28, 0.02, 0)
	geom.add_child(pivot)
	for i in 12:
		var angle: float = (TAU / 12.0) * float(i)
		var dist: float = 4.0 + float(i % 3) * 2.5
		var crack: MeshInstance3D = MeshInstance3D.new()
		var pm: PlaneMesh = PlaneMesh.new()
		pm.size = Vector2(0.55 + float(i % 4) * 0.18, 5.0 + float(i % 3) * 1.2)
		crack.mesh = pm
		var mat: StandardMaterial3D = StandardMaterial3D.new()
		mat.albedo_color = Color(0.08, 0.04, 0.02)
		mat.emission_enabled = true
		mat.emission = Color(1.0, 0.32, 0.05)
		mat.emission_energy_multiplier = 3.4
		mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		crack.material_override = mat
		crack.position = Vector3(cos(angle) * dist, 0, sin(angle) * dist)
		crack.rotation.y = angle
		pivot.add_child(crack)


func _build_d9_chained_anvil_totem(geom: Node) -> void:
	## Epic-9 T47: massive iron anvil hoisted on a 4-pillar chained scaffold
	## marking the entrance to the mid-boss arena. The warning monument.
	var pivot: Node3D = Node3D.new()
	pivot.name = "D9_ChainedAnvilTotem"
	pivot.position = D9_CENTER + Vector3(20, 0, -6)
	geom.add_child(pivot)
	# Stone pedestal base
	var base: MeshInstance3D = MeshInstance3D.new()
	var bm: CylinderMesh = CylinderMesh.new()
	bm.top_radius = 1.6
	bm.bottom_radius = 1.85
	bm.height = 1.1
	base.mesh = bm
	var bmat: StandardMaterial3D = StandardMaterial3D.new()
	bmat.albedo_color = Color(0.12, 0.10, 0.09)
	bmat.metallic = 0.20
	bmat.roughness = 0.85
	base.material_override = bmat
	base.position = Vector3(0, 0.55, 0)
	pivot.add_child(base)
	# 4 chain pillars
	var pillar_mat: StandardMaterial3D = StandardMaterial3D.new()
	pillar_mat.albedo_color = Color(0.18, 0.14, 0.11)
	pillar_mat.metallic = 0.65
	pillar_mat.roughness = 0.45
	for i in 4:
		var ang: float = (TAU / 4.0) * float(i) + PI / 4.0
		var pillar: MeshInstance3D = MeshInstance3D.new()
		var pmsh: BoxMesh = BoxMesh.new()
		pmsh.size = Vector3(0.30, 4.5, 0.30)
		pillar.mesh = pmsh
		pillar.material_override = pillar_mat
		pillar.position = Vector3(cos(ang) * 1.45, 2.35, sin(ang) * 1.45)
		pivot.add_child(pillar)
	# Suspended anvil at the top
	var anvil: MeshInstance3D = MeshInstance3D.new()
	var am: BoxMesh = BoxMesh.new()
	am.size = Vector3(2.10, 0.85, 1.20)
	anvil.mesh = am
	var amat: StandardMaterial3D = StandardMaterial3D.new()
	amat.albedo_color = Color(0.16, 0.12, 0.10)
	amat.metallic = 0.85
	amat.roughness = 0.30
	amat.emission_enabled = true
	amat.emission = Color(1.0, 0.40, 0.10)
	amat.emission_energy_multiplier = 0.8
	anvil.material_override = amat
	anvil.position = Vector3(0, 4.10, 0)
	pivot.add_child(anvil)
	# Anvil horn nub on the side
	var horn: MeshInstance3D = MeshInstance3D.new()
	var hm: PrismMesh = PrismMesh.new()
	hm.size = Vector3(0.50, 0.65, 1.10)
	horn.mesh = hm
	horn.material_override = amat
	horn.position = Vector3(1.20, 4.10, 0)
	horn.rotation.z = -PI / 2.0
	pivot.add_child(horn)
	# Sway the anvil slowly on the chains
	var sway: Tween = pivot.create_tween().set_loops()
	sway.tween_property(anvil, "rotation:z", 0.06, 2.4).set_ease(Tween.EASE_IN_OUT)
	sway.tween_property(anvil, "rotation:z", -0.06, 2.4).set_ease(Tween.EASE_IN_OUT)
	# Amber light from the heated anvil
	var lt: OmniLight3D = OmniLight3D.new()
	lt.position = Vector3(0, 4.50, 0)
	lt.light_color = Color(1.0, 0.45, 0.15)
	lt.light_energy = 2.6
	lt.omni_range = 12.0
	pivot.add_child(lt)
	# Solid base collision so the player can't walk through the totem
	var stb: StaticBody3D = StaticBody3D.new()
	stb.position = Vector3(0, 0.55, 0)
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cyl: CylinderShape3D = CylinderShape3D.new()
	cyl.height = 1.1
	cyl.radius = 1.85
	cs.shape = cyl
	stb.add_child(cs)
	pivot.add_child(stb)


func _build_d9_scorched_bone_pile(geom: Node) -> void:
	## Epic-9 T48: a charred pile of long bones, a skull, and a broken sword.
	## Remains of warriors who challenged the Molten Behemoth and lost.
	## Visual storytelling for the mid-boss arena approach.
	var pivot: Node3D = Node3D.new()
	pivot.name = "D9_ScorchedBonePile"
	pivot.position = D9_CENTER + Vector3(24, 0, 6)
	geom.add_child(pivot)
	# Two material variants — pale bone vs charred black
	var bone_mat: StandardMaterial3D = StandardMaterial3D.new()
	bone_mat.albedo_color = Color(0.45, 0.40, 0.32)
	bone_mat.roughness = 0.85
	var char_mat: StandardMaterial3D = StandardMaterial3D.new()
	char_mat.albedo_color = Color(0.10, 0.08, 0.07)
	char_mat.roughness = 0.95
	# 8 long bones in a chaotic stack
	for i in 8:
		var bone: MeshInstance3D = MeshInstance3D.new()
		var bm: CylinderMesh = CylinderMesh.new()
		bm.top_radius = 0.10
		bm.bottom_radius = 0.13
		bm.height = 1.10 + float(i % 3) * 0.18
		bone.mesh = bm
		bone.material_override = bone_mat if (i % 2 == 0) else char_mat
		var ang: float = (TAU / 8.0) * float(i)
		var r: float = 0.40 + float(i % 3) * 0.18
		bone.position = Vector3(cos(ang) * r, 0.30 + float(i % 3) * 0.15, sin(ang) * r)
		bone.rotation.z = (TAU / 8.0) * float(i % 4)
		bone.rotation.x = float(i) * 0.18
		pivot.add_child(bone)
	# Skull on top of the pile
	var skull: MeshInstance3D = MeshInstance3D.new()
	var sm: SphereMesh = SphereMesh.new()
	sm.radius = 0.32
	sm.height = 0.55
	skull.mesh = sm
	skull.material_override = bone_mat
	skull.position = Vector3(0, 0.95, 0)
	pivot.add_child(skull)
	# Broken sword stuck in the pile
	var sword: MeshInstance3D = MeshInstance3D.new()
	var swm: BoxMesh = BoxMesh.new()
	swm.size = Vector3(0.10, 1.30, 0.04)
	sword.mesh = swm
	var swmat: StandardMaterial3D = StandardMaterial3D.new()
	swmat.albedo_color = Color(0.25, 0.20, 0.15)
	swmat.metallic = 0.55
	swmat.roughness = 0.65
	sword.material_override = swmat
	sword.position = Vector3(0.40, 0.85, 0.30)
	sword.rotation.z = 0.55
	pivot.add_child(sword)
	# Faint smoke wisp rising from the pile
	var smoke: GPUParticles3D = GPUParticles3D.new()
	smoke.amount = 12
	smoke.lifetime = 4.0
	smoke.position = Vector3(0, 0.65, 0)
	var pmat: ParticleProcessMaterial = ParticleProcessMaterial.new()
	pmat.direction = Vector3(0, 1, 0)
	pmat.initial_velocity_min = 0.20
	pmat.initial_velocity_max = 0.45
	pmat.gravity = Vector3(0, 0.10, 0)
	pmat.scale_min = 0.20
	pmat.scale_max = 0.45
	pmat.color = Color(0.30, 0.25, 0.22, 0.55)
	smoke.process_material = pmat
	var qm: QuadMesh = QuadMesh.new()
	qm.size = Vector2(0.55, 0.55)
	smoke.draw_pass_1 = qm
	pivot.add_child(smoke)


func _build_d9_smelter_trap_pillars(geom: Node) -> void:
	## Epic-9 T49: 4 tall smelter pillars at the corners of the mid-boss arena.
	## Each pillar has a glowing molten cap, an erupting molten plume, an
	## amber light, and a collision body. Frames the arena perimeter with
	## environmental danger.
	var pivot: Node3D = Node3D.new()
	pivot.name = "D9_SmelterTrapPillars"
	pivot.position = D9_CENTER + Vector3(32, 0, 0)
	geom.add_child(pivot)
	for i in 4:
		var ang: float = (TAU / 4.0) * float(i) + PI / 4.0
		var col: Node3D = Node3D.new()
		col.position = Vector3(cos(ang) * 7.5, 0, sin(ang) * 7.5)
		pivot.add_child(col)
		# Pillar shaft (tapered cylinder)
		var shaft: MeshInstance3D = MeshInstance3D.new()
		var sm: CylinderMesh = CylinderMesh.new()
		sm.top_radius = 0.55
		sm.bottom_radius = 0.85
		sm.height = 4.5
		shaft.mesh = sm
		var smat: StandardMaterial3D = StandardMaterial3D.new()
		smat.albedo_color = Color(0.18, 0.12, 0.10)
		smat.metallic = 0.55
		smat.roughness = 0.55
		shaft.material_override = smat
		shaft.position = Vector3(0, 2.25, 0)
		col.add_child(shaft)
		# Glowing molten cap on top
		var cap: MeshInstance3D = MeshInstance3D.new()
		var cm: CylinderMesh = CylinderMesh.new()
		cm.top_radius = 0.50
		cm.bottom_radius = 0.50
		cm.height = 0.20
		cap.mesh = cm
		var cmat: StandardMaterial3D = StandardMaterial3D.new()
		cmat.albedo_color = Color(1.0, 0.55, 0.10)
		cmat.emission_enabled = true
		cmat.emission = Color(1.0, 0.55, 0.15)
		cmat.emission_energy_multiplier = 4.5
		cmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		cap.material_override = cmat
		cap.position = Vector3(0, 4.55, 0)
		col.add_child(cap)
		# Molten plume particles erupting upward
		var plume: GPUParticles3D = GPUParticles3D.new()
		plume.amount = 40
		plume.lifetime = 1.8
		plume.position = Vector3(0, 4.65, 0)
		var pmat: ParticleProcessMaterial = ParticleProcessMaterial.new()
		pmat.direction = Vector3(0, 1, 0)
		pmat.spread = 18.0
		pmat.initial_velocity_min = 1.20
		pmat.initial_velocity_max = 2.40
		pmat.gravity = Vector3(0, -1.0, 0)
		pmat.scale_min = 0.10
		pmat.scale_max = 0.22
		pmat.color = Color(1.0, 0.50, 0.10, 0.95)
		plume.process_material = pmat
		var qm: QuadMesh = QuadMesh.new()
		qm.size = Vector2(0.18, 0.18)
		plume.draw_pass_1 = qm
		col.add_child(plume)
		# Amber light at the cap
		var lt: OmniLight3D = OmniLight3D.new()
		lt.position = Vector3(0, 4.80, 0)
		lt.light_color = Color(1.0, 0.42, 0.10)
		lt.light_energy = 3.4
		lt.omni_range = 9.0
		col.add_child(lt)
		# Pillar collision so the player can't walk through
		var stb: StaticBody3D = StaticBody3D.new()
		stb.position = Vector3(0, 2.25, 0)
		var cs: CollisionShape3D = CollisionShape3D.new()
		var cyl: CylinderShape3D = CylinderShape3D.new()
		cyl.height = 4.5
		cyl.radius = 0.85
		cs.shape = cyl
		stb.add_child(cs)
		col.add_child(stb)


func _build_d9_molten_behemoth_midboss(geom: Node) -> void:
	## Epic-9 T50: MOLTEN BEHEMOTH mid-boss landmark — centerpiece of the
	## D9 mid-boss arena. Massive hulking molten-iron beast with glowing
	## seam emissions, hovering name plate, ember plume, hot-iron core
	## that pulses through chest cavity.
	var pivot: Node3D = Node3D.new()
	pivot.name = "D9_MoltenBehemoth_MidBoss"
	pivot.position = D9_CENTER + Vector3(32, 0, 0)
	geom.add_child(pivot)
	# Body — large lumpy ovoid
	var body: MeshInstance3D = MeshInstance3D.new()
	var bm: SphereMesh = SphereMesh.new()
	bm.radius = 2.20
	bm.height = 3.80
	body.mesh = bm
	var bmat: StandardMaterial3D = StandardMaterial3D.new()
	bmat.albedo_color = Color(0.10, 0.06, 0.04)
	bmat.metallic = 0.85
	bmat.roughness = 0.40
	bmat.emission_enabled = true
	bmat.emission = Color(1.0, 0.30, 0.05)
	bmat.emission_energy_multiplier = 1.30
	body.material_override = bmat
	body.position = Vector3(0, 2.40, 0)
	pivot.add_child(body)
	# Hunched head bulb
	var head: MeshInstance3D = MeshInstance3D.new()
	var hm: SphereMesh = SphereMesh.new()
	hm.radius = 1.10
	hm.height = 1.65
	head.mesh = hm
	head.material_override = bmat
	head.position = Vector3(0, 4.85, 1.50)
	pivot.add_child(head)
	# Two glowing eyes
	for ex in [-0.45, 0.45]:
		var eye: MeshInstance3D = MeshInstance3D.new()
		var em: SphereMesh = SphereMesh.new()
		em.radius = 0.16
		em.height = 0.32
		eye.mesh = em
		var emat: StandardMaterial3D = StandardMaterial3D.new()
		emat.albedo_color = Color(1.0, 0.85, 0.40)
		emat.emission_enabled = true
		emat.emission = Color(1.0, 0.85, 0.40)
		emat.emission_energy_multiplier = 6.0
		emat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		eye.material_override = emat
		eye.position = Vector3(ex, 5.05, 2.30)
		pivot.add_child(eye)
	# 4 spike shoulder plates
	for i in 4:
		var ang: float = (TAU / 4.0) * float(i)
		var spike: MeshInstance3D = MeshInstance3D.new()
		var spm: PrismMesh = PrismMesh.new()
		spm.size = Vector3(0.55, 1.40, 0.55)
		spike.mesh = spm
		spike.material_override = bmat
		spike.position = Vector3(cos(ang) * 1.85, 4.20, sin(ang) * 1.85)
		spike.rotation.x = -0.30
		pivot.add_child(spike)
	# Two massive forearms resting on the ground
	for ax in [-1.95, 1.95]:
		var arm: MeshInstance3D = MeshInstance3D.new()
		var am: BoxMesh = BoxMesh.new()
		am.size = Vector3(0.95, 0.85, 2.40)
		arm.mesh = am
		arm.material_override = bmat
		arm.position = Vector3(ax, 0.85, 1.10)
		arm.rotation.x = 0.20
		pivot.add_child(arm)
		# Fist
		var fist: MeshInstance3D = MeshInstance3D.new()
		var fm: SphereMesh = SphereMesh.new()
		fm.radius = 0.70
		fm.height = 1.20
		fist.mesh = fm
		fist.material_override = bmat
		fist.position = Vector3(ax, 0.75, 2.25)
		pivot.add_child(fist)
	# Heart core — bright glowing sphere visible through chest seams
	var core: MeshInstance3D = MeshInstance3D.new()
	var cm: SphereMesh = SphereMesh.new()
	cm.radius = 0.55
	cm.height = 1.10
	core.mesh = cm
	var cmat: StandardMaterial3D = StandardMaterial3D.new()
	cmat.albedo_color = Color(1.0, 0.55, 0.10)
	cmat.emission_enabled = true
	cmat.emission = Color(1.0, 0.55, 0.10)
	cmat.emission_energy_multiplier = 8.0
	cmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	core.material_override = cmat
	core.position = Vector3(0, 2.40, 0.45)
	pivot.add_child(core)
	# Heart pulse animation
	var pulse: Tween = pivot.create_tween().set_loops()
	pulse.tween_property(core, "scale", Vector3(1.18, 1.18, 1.18), 0.85).set_ease(Tween.EASE_IN_OUT)
	pulse.tween_property(core, "scale", Vector3(0.92, 0.92, 0.92), 0.85).set_ease(Tween.EASE_IN_OUT)
	# Body breathing
	var breath: Tween = pivot.create_tween().set_loops()
	breath.tween_property(body, "scale", Vector3(1.04, 1.02, 1.04), 1.6).set_ease(Tween.EASE_IN_OUT)
	breath.tween_property(body, "scale", Vector3(1.0, 1.0, 1.0), 1.6).set_ease(Tween.EASE_IN_OUT)
	# Ember plume from the back
	var embers: GPUParticles3D = GPUParticles3D.new()
	embers.amount = 80
	embers.lifetime = 3.0
	embers.position = Vector3(0, 4.80, -1.20)
	var pmat: ParticleProcessMaterial = ParticleProcessMaterial.new()
	pmat.direction = Vector3(0, 1, -0.30)
	pmat.spread = 30.0
	pmat.initial_velocity_min = 0.85
	pmat.initial_velocity_max = 2.20
	pmat.gravity = Vector3(0, -0.40, 0)
	pmat.scale_min = 0.10
	pmat.scale_max = 0.22
	pmat.color = Color(1.0, 0.55, 0.15, 0.95)
	embers.process_material = pmat
	var qm: QuadMesh = QuadMesh.new()
	qm.size = Vector2(0.20, 0.20)
	embers.draw_pass_1 = qm
	pivot.add_child(embers)
	# Body OmniLight casting orange light over the arena
	var lt: OmniLight3D = OmniLight3D.new()
	lt.position = Vector3(0, 3.20, 0)
	lt.light_color = Color(1.0, 0.40, 0.08)
	lt.light_energy = 4.8
	lt.omni_range = 22.0
	lt.omni_attenuation = 1.6
	pivot.add_child(lt)
	# Floating boss title above the behemoth
	var label: Label3D = Label3D.new()
	label.text = "MOLTEN BEHEMOTH"
	label.position = Vector3(0, 7.20, 0)
	label.modulate = Color(1.0, 0.55, 0.20)
	label.outline_modulate = Color(0, 0, 0, 0.90)
	label.outline_size = 7
	label.font_size = 28
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	pivot.add_child(label)
	# Title bob
	var label_bob: Tween = pivot.create_tween().set_loops()
	label_bob.tween_property(label, "position:y", 7.45, 1.4).set_ease(Tween.EASE_IN_OUT)
	label_bob.tween_property(label, "position:y", 7.20, 1.4).set_ease(Tween.EASE_IN_OUT)
	# Collision body so the player can't walk through the boss
	var stb: StaticBody3D = StaticBody3D.new()
	stb.position = Vector3(0, 2.20, 0)
	var cs: CollisionShape3D = CollisionShape3D.new()
	var caps: CapsuleShape3D = CapsuleShape3D.new()
	caps.height = 4.40
	caps.radius = 2.30
	cs.shape = caps
	stb.add_child(cs)
	pivot.add_child(stb)


func _build_d9_sky_lava_lantern(geom: Node) -> void:
	## Epic-9 T51: a massive drifting molten lantern hovering above the
	## D9 mid-boss arena. Caged iron frame with a glowing orange core
	## inside. Slow vertical bob + slow yaw rotation.
	var pivot: Node3D = Node3D.new()
	pivot.name = "D9_SkyLavaLantern"
	pivot.position = D9_CENTER + Vector3(38, 11.0, 4)
	geom.add_child(pivot)
	# Iron cage frame — top ring + bottom ring + 6 vertical bars
	var frame_mat: StandardMaterial3D = StandardMaterial3D.new()
	frame_mat.albedo_color = Color(0.18, 0.13, 0.10)
	frame_mat.metallic = 0.75
	frame_mat.roughness = 0.40
	frame_mat.emission_enabled = true
	frame_mat.emission = Color(1.0, 0.42, 0.10)
	frame_mat.emission_energy_multiplier = 0.45
	# Top ring
	var top_ring: MeshInstance3D = MeshInstance3D.new()
	var trm: TorusMesh = TorusMesh.new()
	trm.inner_radius = 0.85
	trm.outer_radius = 0.95
	top_ring.mesh = trm
	top_ring.material_override = frame_mat
	top_ring.position = Vector3(0, 1.10, 0)
	pivot.add_child(top_ring)
	# Bottom ring
	var bot_ring: MeshInstance3D = MeshInstance3D.new()
	bot_ring.mesh = trm
	bot_ring.material_override = frame_mat
	bot_ring.position = Vector3(0, -1.10, 0)
	pivot.add_child(bot_ring)
	# 6 vertical bars
	for i in 6:
		var ang: float = (TAU / 6.0) * float(i)
		var bar: MeshInstance3D = MeshInstance3D.new()
		var bm: CylinderMesh = CylinderMesh.new()
		bm.top_radius = 0.045
		bm.bottom_radius = 0.045
		bm.height = 2.20
		bar.mesh = bm
		bar.material_override = frame_mat
		bar.position = Vector3(cos(ang) * 0.90, 0, sin(ang) * 0.90)
		pivot.add_child(bar)
	# Glowing molten core inside the cage
	var core: MeshInstance3D = MeshInstance3D.new()
	var cm: SphereMesh = SphereMesh.new()
	cm.radius = 0.65
	cm.height = 1.30
	core.mesh = cm
	var cmat: StandardMaterial3D = StandardMaterial3D.new()
	cmat.albedo_color = Color(1.0, 0.55, 0.10)
	cmat.emission_enabled = true
	cmat.emission = Color(1.0, 0.55, 0.10)
	cmat.emission_energy_multiplier = 7.0
	cmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	core.material_override = cmat
	pivot.add_child(core)
	# Hanging chain from above
	var chain: MeshInstance3D = MeshInstance3D.new()
	var chm: CylinderMesh = CylinderMesh.new()
	chm.top_radius = 0.04
	chm.bottom_radius = 0.04
	chm.height = 4.5
	chain.mesh = chm
	chain.material_override = frame_mat
	chain.position = Vector3(0, 3.35, 0)
	pivot.add_child(chain)
	# OmniLight at the core
	var lt: OmniLight3D = OmniLight3D.new()
	lt.position = Vector3(0, 0, 0)
	lt.light_color = Color(1.0, 0.50, 0.12)
	lt.light_energy = 3.6
	lt.omni_range = 14.0
	lt.omni_attenuation = 1.5
	pivot.add_child(lt)
	# Slow vertical bob
	var bob: Tween = pivot.create_tween().set_loops()
	bob.tween_property(pivot, "position:y", 12.0, 3.5).set_ease(Tween.EASE_IN_OUT)
	bob.tween_property(pivot, "position:y", 10.4, 3.5).set_ease(Tween.EASE_IN_OUT)
	# Slow yaw rotation
	var spin: Tween = pivot.create_tween().set_loops()
	spin.tween_property(pivot, "rotation:y", TAU, 18.0)
	# Core pulse
	var pulse: Tween = pivot.create_tween().set_loops()
	pulse.tween_property(cmat, "emission_energy_multiplier", 9.0, 1.2).set_ease(Tween.EASE_IN_OUT)
	pulse.tween_property(cmat, "emission_energy_multiplier", 5.5, 1.2).set_ease(Tween.EASE_IN_OUT)


func _build_d9_forge_sentry_mech(geom: Node) -> void:
	## Epic-9 T52: a heavy iron guardian mech patrolling the path past
	## the mid-boss arena. Squat humanoid silhouette with a glowing visor
	## slit, two arms, two legs, a backpack vent, and a slow side-step
	## patrol tween. Decorative — sets up the heavy combat units of D9.
	var pivot: Node3D = Node3D.new()
	pivot.name = "D9_ForgeSentryMech"
	pivot.position = D9_CENTER + Vector3(46, 0, -8)
	geom.add_child(pivot)
	# Body — chunky iron torso
	var torso: MeshInstance3D = MeshInstance3D.new()
	var tm: BoxMesh = BoxMesh.new()
	tm.size = Vector3(1.30, 1.50, 0.95)
	torso.mesh = tm
	var iron_mat: StandardMaterial3D = StandardMaterial3D.new()
	iron_mat.albedo_color = Color(0.16, 0.13, 0.11)
	iron_mat.metallic = 0.85
	iron_mat.roughness = 0.40
	iron_mat.emission_enabled = true
	iron_mat.emission = Color(1.0, 0.30, 0.05)
	iron_mat.emission_energy_multiplier = 0.30
	torso.material_override = iron_mat
	torso.position = Vector3(0, 1.45, 0)
	pivot.add_child(torso)
	# Chest seam emissive line
	var seam: MeshInstance3D = MeshInstance3D.new()
	var sm: BoxMesh = BoxMesh.new()
	sm.size = Vector3(0.10, 0.85, 0.04)
	seam.mesh = sm
	var seam_mat: StandardMaterial3D = StandardMaterial3D.new()
	seam_mat.albedo_color = Color(1.0, 0.50, 0.10)
	seam_mat.emission_enabled = true
	seam_mat.emission = Color(1.0, 0.55, 0.10)
	seam_mat.emission_energy_multiplier = 4.5
	seam_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	seam.material_override = seam_mat
	seam.position = Vector3(0, 1.45, -0.50)
	pivot.add_child(seam)
	# Head block with visor slit
	var head: MeshInstance3D = MeshInstance3D.new()
	var hm: BoxMesh = BoxMesh.new()
	hm.size = Vector3(0.85, 0.60, 0.75)
	head.mesh = hm
	head.material_override = iron_mat
	head.position = Vector3(0, 2.55, 0)
	pivot.add_child(head)
	# Visor slit (unshaded amber bar)
	var visor: MeshInstance3D = MeshInstance3D.new()
	var vm: BoxMesh = BoxMesh.new()
	vm.size = Vector3(0.65, 0.10, 0.05)
	visor.mesh = vm
	var vmat: StandardMaterial3D = StandardMaterial3D.new()
	vmat.albedo_color = Color(1.0, 0.55, 0.10)
	vmat.emission_enabled = true
	vmat.emission = Color(1.0, 0.60, 0.15)
	vmat.emission_energy_multiplier = 5.5
	vmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	visor.material_override = vmat
	visor.position = Vector3(0, 2.55, -0.40)
	pivot.add_child(visor)
	# Two shoulders + arms hanging at sides
	for side in [-1.0, 1.0]:
		var shoulder: MeshInstance3D = MeshInstance3D.new()
		var shm: SphereMesh = SphereMesh.new()
		shm.radius = 0.30
		shm.height = 0.55
		shoulder.mesh = shm
		shoulder.material_override = iron_mat
		shoulder.position = Vector3(side * 0.85, 1.95, 0)
		pivot.add_child(shoulder)
		var arm: MeshInstance3D = MeshInstance3D.new()
		var am: BoxMesh = BoxMesh.new()
		am.size = Vector3(0.32, 1.20, 0.32)
		arm.mesh = am
		arm.material_override = iron_mat
		arm.position = Vector3(side * 0.85, 1.20, 0)
		pivot.add_child(arm)
		# Fist
		var fist: MeshInstance3D = MeshInstance3D.new()
		var fm: BoxMesh = BoxMesh.new()
		fm.size = Vector3(0.40, 0.40, 0.40)
		fist.mesh = fm
		fist.material_override = iron_mat
		fist.position = Vector3(side * 0.85, 0.50, 0.05)
		pivot.add_child(fist)
	# Two legs + foot plates
	for side in [-0.32, 0.32]:
		var leg: MeshInstance3D = MeshInstance3D.new()
		var lm: BoxMesh = BoxMesh.new()
		lm.size = Vector3(0.42, 0.95, 0.42)
		leg.mesh = lm
		leg.material_override = iron_mat
		leg.position = Vector3(side, 0.70, 0)
		pivot.add_child(leg)
		var foot: MeshInstance3D = MeshInstance3D.new()
		var fm2: BoxMesh = BoxMesh.new()
		fm2.size = Vector3(0.55, 0.18, 0.75)
		foot.mesh = fm2
		foot.material_override = iron_mat
		foot.position = Vector3(side, 0.10, 0.10)
		pivot.add_child(foot)
	# Backpack vent with subtle ember plume
	var pack: MeshInstance3D = MeshInstance3D.new()
	var pm: BoxMesh = BoxMesh.new()
	pm.size = Vector3(0.95, 0.85, 0.30)
	pack.mesh = pm
	pack.material_override = iron_mat
	pack.position = Vector3(0, 1.65, 0.55)
	pivot.add_child(pack)
	# Ember plume from the vent
	var embers: GPUParticles3D = GPUParticles3D.new()
	embers.amount = 30
	embers.lifetime = 2.0
	embers.position = Vector3(0, 2.20, 0.65)
	var pmat: ParticleProcessMaterial = ParticleProcessMaterial.new()
	pmat.direction = Vector3(0, 1, 0.20)
	pmat.spread = 18.0
	pmat.initial_velocity_min = 0.55
	pmat.initial_velocity_max = 1.20
	pmat.gravity = Vector3(0, -0.30, 0)
	pmat.scale_min = 0.06
	pmat.scale_max = 0.14
	pmat.color = Color(1.0, 0.55, 0.15, 0.95)
	embers.process_material = pmat
	var qm: QuadMesh = QuadMesh.new()
	qm.size = Vector2(0.14, 0.14)
	embers.draw_pass_1 = qm
	pivot.add_child(embers)
	# Visor light at front of head
	var lt: OmniLight3D = OmniLight3D.new()
	lt.position = Vector3(0, 2.55, -0.45)
	lt.light_color = Color(1.0, 0.50, 0.12)
	lt.light_energy = 1.8
	lt.omni_range = 5.5
	pivot.add_child(lt)
	# Slow side-step patrol along Z axis
	var origin_z: float = pivot.position.z
	var patrol: Tween = pivot.create_tween().set_loops()
	patrol.tween_property(pivot, "position:z", origin_z + 4.0, 4.0).set_ease(Tween.EASE_IN_OUT)
	patrol.tween_property(pivot, "rotation:y", PI, 0.4)
	patrol.tween_property(pivot, "position:z", origin_z, 4.0).set_ease(Tween.EASE_IN_OUT)
	patrol.tween_property(pivot, "rotation:y", 0.0, 0.4)
	# Visor pulse
	var vpulse: Tween = pivot.create_tween().set_loops()
	vpulse.tween_property(vmat, "emission_energy_multiplier", 7.5, 1.6).set_ease(Tween.EASE_IN_OUT)
	vpulse.tween_property(vmat, "emission_energy_multiplier", 4.5, 1.6).set_ease(Tween.EASE_IN_OUT)
	# Capsule collision so the player can't walk through
	var stb: StaticBody3D = StaticBody3D.new()
	stb.position = Vector3(0, 1.30, 0)
	var cs: CollisionShape3D = CollisionShape3D.new()
	var caps: CapsuleShape3D = CapsuleShape3D.new()
	caps.height = 2.40
	caps.radius = 0.75
	cs.shape = caps
	stb.add_child(cs)
	pivot.add_child(stb)


func _build_d9_molten_cascade(geom: Node) -> void:
	## Epic-9 T53: a molten lava cascade pouring from a basalt cliff face
	## into a glowing pool below. Vertical sheet mesh + a wider splash pool
	## with rising particle haze. Hero scenery for the second half of D9.
	var pivot: Node3D = Node3D.new()
	pivot.name = "D9_MoltenCascade"
	pivot.position = D9_CENTER + Vector3(54, 0, 8)
	geom.add_child(pivot)
	# Cliff backdrop — tall basalt slab
	var cliff: MeshInstance3D = MeshInstance3D.new()
	var cm: BoxMesh = BoxMesh.new()
	cm.size = Vector3(7.5, 8.0, 1.2)
	cliff.mesh = cm
	var cliff_mat: StandardMaterial3D = StandardMaterial3D.new()
	cliff_mat.albedo_color = Color(0.10, 0.08, 0.07)
	cliff_mat.metallic = 0.20
	cliff_mat.roughness = 0.85
	cliff_mat.emission_enabled = true
	cliff_mat.emission = Color(1.0, 0.30, 0.05)
	cliff_mat.emission_energy_multiplier = 0.18
	cliff.material_override = cliff_mat
	cliff.position = Vector3(0, 4.0, 0.50)
	pivot.add_child(cliff)
	# Falling lava sheet (vertical plane)
	var sheet: MeshInstance3D = MeshInstance3D.new()
	var pm: PlaneMesh = PlaneMesh.new()
	pm.size = Vector2(2.40, 7.50)
	sheet.mesh = pm
	var lava_mat: StandardMaterial3D = StandardMaterial3D.new()
	lava_mat.albedo_color = Color(1.0, 0.45, 0.10)
	lava_mat.emission_enabled = true
	lava_mat.emission = Color(1.0, 0.55, 0.10)
	lava_mat.emission_energy_multiplier = 5.5
	lava_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	lava_mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	sheet.material_override = lava_mat
	sheet.position = Vector3(0, 4.0, -0.10)
	sheet.rotation.x = PI / 2.0
	pivot.add_child(sheet)
	# Pool basin — wide flat cylinder at the base
	var pool: MeshInstance3D = MeshInstance3D.new()
	var pcm: CylinderMesh = CylinderMesh.new()
	pcm.top_radius = 3.20
	pcm.bottom_radius = 3.20
	pcm.height = 0.30
	pool.mesh = pcm
	var pool_mat: StandardMaterial3D = StandardMaterial3D.new()
	pool_mat.albedo_color = Color(1.0, 0.50, 0.12)
	pool_mat.emission_enabled = true
	pool_mat.emission = Color(1.0, 0.55, 0.10)
	pool_mat.emission_energy_multiplier = 4.0
	pool_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	pool.material_override = pool_mat
	pool.position = Vector3(0, 0.15, -1.80)
	pivot.add_child(pool)
	# Rising heat particles from the splash zone
	var haze: GPUParticles3D = GPUParticles3D.new()
	haze.amount = 60
	haze.lifetime = 3.0
	haze.position = Vector3(0, 0.40, -1.80)
	var hmat: ParticleProcessMaterial = ParticleProcessMaterial.new()
	hmat.direction = Vector3(0, 1, 0)
	hmat.spread = 25.0
	hmat.initial_velocity_min = 0.55
	hmat.initial_velocity_max = 1.40
	hmat.gravity = Vector3(0, 0.20, 0)
	hmat.scale_min = 0.30
	hmat.scale_max = 0.65
	hmat.color = Color(1.0, 0.55, 0.20, 0.55)
	haze.process_material = hmat
	var qm: QuadMesh = QuadMesh.new()
	qm.size = Vector2(0.55, 0.55)
	haze.draw_pass_1 = qm
	pivot.add_child(haze)
	# Bright splash glow at the impact point
	var splash: MeshInstance3D = MeshInstance3D.new()
	var sm: SphereMesh = SphereMesh.new()
	sm.radius = 0.85
	sm.height = 1.10
	splash.mesh = sm
	var smat: StandardMaterial3D = StandardMaterial3D.new()
	smat.albedo_color = Color(1.0, 0.70, 0.20)
	smat.emission_enabled = true
	smat.emission = Color(1.0, 0.65, 0.20)
	smat.emission_energy_multiplier = 7.5
	smat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	splash.material_override = smat
	splash.position = Vector3(0, 0.55, -0.95)
	splash.scale = Vector3(1.0, 0.45, 1.0)
	pivot.add_child(splash)
	# Two amber lights flanking the cascade
	for ox in [-2.0, 2.0]:
		var lt: OmniLight3D = OmniLight3D.new()
		lt.position = Vector3(ox, 2.0, -1.20)
		lt.light_color = Color(1.0, 0.45, 0.10)
		lt.light_energy = 3.4
		lt.omni_range = 9.0
		pivot.add_child(lt)
	# Subtle vertical UV-style scroll on the falling sheet via emission tween
	var stream: Tween = pivot.create_tween().set_loops()
	stream.tween_property(lava_mat, "emission_energy_multiplier", 7.0, 0.7).set_ease(Tween.EASE_IN_OUT)
	stream.tween_property(lava_mat, "emission_energy_multiplier", 4.5, 0.7).set_ease(Tween.EASE_IN_OUT)
	# Splash bulb pulse
	var spulse: Tween = pivot.create_tween().set_loops()
	spulse.tween_property(splash, "scale", Vector3(1.18, 0.55, 1.18), 0.55).set_ease(Tween.EASE_IN_OUT)
	spulse.tween_property(splash, "scale", Vector3(0.92, 0.40, 0.92), 0.55).set_ease(Tween.EASE_IN_OUT)
	# Cliff collision
	var stb: StaticBody3D = StaticBody3D.new()
	stb.position = Vector3(0, 4.0, 0.50)
	var cs: CollisionShape3D = CollisionShape3D.new()
	var bs: BoxShape3D = BoxShape3D.new()
	bs.size = Vector3(7.5, 8.0, 1.2)
	cs.shape = bs
	stb.add_child(cs)
	pivot.add_child(stb)


func _build_d9_forge_priestess_npc(town: Node) -> void:
	## Epic-9 T54: Forge Priestess Ember — caretaker of the molten cascade.
	## Robed NPC standing beside the lava pool with a glowing brazier-staff
	## and a heated halo above her head.
	var slots: Node3D = town.get_node_or_null("NPCSlots") as Node3D
	if slots == null:
		return
	var slot: Marker3D = Marker3D.new()
	slot.name = "D9ForgePriestessSlot"
	slot.position = Vector3(D9_CENTER.x + 50, 0, 11)
	slots.add_child(slot)
	var npc_scene: PackedScene = load("res://scenes/entities/npcs/VillagerR3.tscn") as PackedScene
	if npc_scene == null:
		return
	var npc: Node3D = npc_scene.instantiate() as Node3D
	npc.name = "D9ForgePriestess"
	if "npc_name" in npc:
		npc.set("npc_name", "Forge Priestess Ember")
	if "npc_id" in npc:
		npc.set("npc_id", "d9_forge_priestess")
	slot.add_child(npc)
	# Dark robe overlay (long body box)
	var robe_mat: StandardMaterial3D = StandardMaterial3D.new()
	robe_mat.albedo_color = Color(0.14, 0.10, 0.09)
	robe_mat.roughness = 0.85
	robe_mat.metallic = 0.10
	var robe: MeshInstance3D = MeshInstance3D.new()
	var rb: BoxMesh = BoxMesh.new()
	rb.size = Vector3(0.85, 1.40, 0.55)
	robe.mesh = rb
	robe.material_override = robe_mat
	robe.position = Vector3(0, 0.95, 0)
	npc.add_child(robe)
	# Glowing chest pendant (small unshaded amber sphere)
	var pendant: MeshInstance3D = MeshInstance3D.new()
	var pm: SphereMesh = SphereMesh.new()
	pm.radius = 0.10
	pm.height = 0.20
	pendant.mesh = pm
	var pmat: StandardMaterial3D = StandardMaterial3D.new()
	pmat.albedo_color = Color(1.0, 0.55, 0.10)
	pmat.emission_enabled = true
	pmat.emission = Color(1.0, 0.55, 0.10)
	pmat.emission_energy_multiplier = 6.0
	pmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	pendant.material_override = pmat
	pendant.position = Vector3(0, 1.20, -0.30)
	npc.add_child(pendant)
	# Hooded head shroud (darker box on top)
	var hood: MeshInstance3D = MeshInstance3D.new()
	var hb: BoxMesh = BoxMesh.new()
	hb.size = Vector3(0.55, 0.40, 0.45)
	hood.mesh = hb
	hood.material_override = robe_mat
	hood.position = Vector3(0, 1.85, 0)
	npc.add_child(hood)
	# Brazier staff — long shaft with a flaming bowl on top
	var staff: MeshInstance3D = MeshInstance3D.new()
	var sm: CylinderMesh = CylinderMesh.new()
	sm.top_radius = 0.04
	sm.bottom_radius = 0.04
	sm.height = 2.10
	staff.mesh = sm
	var staff_mat: StandardMaterial3D = StandardMaterial3D.new()
	staff_mat.albedo_color = Color(0.18, 0.13, 0.10)
	staff_mat.metallic = 0.65
	staff_mat.roughness = 0.45
	staff.material_override = staff_mat
	staff.position = Vector3(0.45, 1.05, 0)
	npc.add_child(staff)
	# Brazier bowl on top of staff
	var bowl: MeshInstance3D = MeshInstance3D.new()
	var bm: SphereMesh = SphereMesh.new()
	bm.radius = 0.18
	bm.height = 0.24
	bowl.mesh = bm
	var bowl_mat: StandardMaterial3D = StandardMaterial3D.new()
	bowl_mat.albedo_color = Color(1.0, 0.55, 0.10)
	bowl_mat.emission_enabled = true
	bowl_mat.emission = Color(1.0, 0.60, 0.15)
	bowl_mat.emission_energy_multiplier = 7.0
	bowl_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	bowl.material_override = bowl_mat
	bowl.position = Vector3(0.45, 2.15, 0)
	bowl.scale = Vector3(1.0, 0.55, 1.0)
	npc.add_child(bowl)
	# Flame particles rising from the bowl
	var flame: GPUParticles3D = GPUParticles3D.new()
	flame.amount = 25
	flame.lifetime = 1.2
	flame.position = Vector3(0.45, 2.25, 0)
	var fmat: ParticleProcessMaterial = ParticleProcessMaterial.new()
	fmat.direction = Vector3(0, 1, 0)
	fmat.spread = 18.0
	fmat.initial_velocity_min = 0.50
	fmat.initial_velocity_max = 1.20
	fmat.gravity = Vector3(0, -0.20, 0)
	fmat.scale_min = 0.10
	fmat.scale_max = 0.22
	fmat.color = Color(1.0, 0.55, 0.15, 0.95)
	flame.process_material = fmat
	var qm: QuadMesh = QuadMesh.new()
	qm.size = Vector2(0.20, 0.20)
	flame.draw_pass_1 = qm
	npc.add_child(flame)
	# Heated halo above her head — torus
	var halo: MeshInstance3D = MeshInstance3D.new()
	var trm: TorusMesh = TorusMesh.new()
	trm.inner_radius = 0.45
	trm.outer_radius = 0.50
	halo.mesh = trm
	var hmat: StandardMaterial3D = StandardMaterial3D.new()
	hmat.albedo_color = Color(1.0, 0.50, 0.10)
	hmat.emission_enabled = true
	hmat.emission = Color(1.0, 0.55, 0.15)
	hmat.emission_energy_multiplier = 4.5
	hmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	halo.material_override = hmat
	halo.position = Vector3(0, 2.30, 0)
	halo.rotation.x = PI / 2.0
	npc.add_child(halo)
	# Halo slow spin
	var spin: Tween = npc.create_tween().set_loops()
	spin.tween_property(halo, "rotation:y", TAU, 6.0)
	# Brazier light at the bowl
	var lt: OmniLight3D = OmniLight3D.new()
	lt.position = Vector3(0.45, 2.20, 0)
	lt.light_color = Color(1.0, 0.50, 0.12)
	lt.light_energy = 2.6
	lt.omni_range = 6.5
	npc.add_child(lt)


func _build_d9_basalt_stepping_stones(geom: Node) -> void:
	## Epic-9 T55: 7 basalt stepping stones crossing the cascade pool from
	## the priestess platform to the base of the cascade. Each stone has
	## subtle ember underglow + collision so the player can walk across.
	var pivot: Node3D = Node3D.new()
	pivot.name = "D9_BasaltSteppingStones"
	pivot.position = D9_CENTER + Vector3(54, 0, 8)
	geom.add_child(pivot)
	# Material — dark basalt with faint ember underlight
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.10, 0.08, 0.07)
	stone_mat.metallic = 0.20
	stone_mat.roughness = 0.85
	stone_mat.emission_enabled = true
	stone_mat.emission = Color(1.0, 0.35, 0.08)
	stone_mat.emission_energy_multiplier = 0.55
	# 7 stones in a gentle arc from pool edge to cascade base
	for i in 7:
		var t: float = float(i) / 6.0
		var angle: float = lerp(-PI * 0.55, -PI * 0.05, t)
		var radius: float = 2.85
		var pos: Vector3 = Vector3(cos(angle) * radius, 0.05, sin(angle) * radius - 1.80)
		var stone: MeshInstance3D = MeshInstance3D.new()
		var sm: CylinderMesh = CylinderMesh.new()
		sm.top_radius = 0.42 + (float(i % 3) * 0.05)
		sm.bottom_radius = 0.50 + (float(i % 3) * 0.05)
		sm.height = 0.30
		stone.mesh = sm
		stone.material_override = stone_mat
		stone.position = pos
		stone.rotation.y = float(i) * 0.42
		pivot.add_child(stone)
		# Small embers ring decoration around each stone base
		var ring: MeshInstance3D = MeshInstance3D.new()
		var trm: TorusMesh = TorusMesh.new()
		trm.inner_radius = sm.top_radius * 0.95
		trm.outer_radius = sm.top_radius * 1.05
		ring.mesh = trm
		var rmat: StandardMaterial3D = StandardMaterial3D.new()
		rmat.albedo_color = Color(1.0, 0.55, 0.10)
		rmat.emission_enabled = true
		rmat.emission = Color(1.0, 0.55, 0.10)
		rmat.emission_energy_multiplier = 3.5
		rmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		ring.material_override = rmat
		ring.position = pos + Vector3(0, 0.16, 0)
		ring.rotation.x = PI / 2.0
		pivot.add_child(ring)
		# Step collision so player can walk on top
		var stb: StaticBody3D = StaticBody3D.new()
		stb.position = pos
		var cs: CollisionShape3D = CollisionShape3D.new()
		var cyl: CylinderShape3D = CylinderShape3D.new()
		cyl.height = 0.30
		cyl.radius = sm.bottom_radius
		cs.shape = cyl
		stb.add_child(cs)
		pivot.add_child(stb)
		# Per-step ember pulse on the ring (staggered)
		var pulse: Tween = pivot.create_tween().set_loops()
		pulse.tween_property(rmat, "emission_energy_multiplier", 5.0, 1.1 + float(i) * 0.12).set_ease(Tween.EASE_IN_OUT)
		pulse.tween_property(rmat, "emission_energy_multiplier", 2.5, 1.1 + float(i) * 0.12).set_ease(Tween.EASE_IN_OUT)


func _build_d9_ember_elemental(geom: Node) -> void:
	## Epic-9 T56: small ember elemental hovering near the cascade pool.
	## Floating fire spirit body with two glowing eye dots, swirling
	## flame particles, slow orbital drift around the priestess area.
	## Decorative preview of D9 caster enemies.
	var pivot: Node3D = Node3D.new()
	pivot.name = "D9_EmberElemental"
	pivot.position = D9_CENTER + Vector3(46, 1.85, 14)
	geom.add_child(pivot)
	# Core body — bright unshaded ember sphere
	var core: MeshInstance3D = MeshInstance3D.new()
	var cm: SphereMesh = SphereMesh.new()
	cm.radius = 0.55
	cm.height = 1.10
	core.mesh = cm
	var cmat: StandardMaterial3D = StandardMaterial3D.new()
	cmat.albedo_color = Color(1.0, 0.55, 0.10)
	cmat.emission_enabled = true
	cmat.emission = Color(1.0, 0.60, 0.15)
	cmat.emission_energy_multiplier = 6.5
	cmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	core.material_override = cmat
	pivot.add_child(core)
	# Two glowing eye dots
	for ex in [-0.18, 0.18]:
		var eye: MeshInstance3D = MeshInstance3D.new()
		var em: SphereMesh = SphereMesh.new()
		em.radius = 0.07
		em.height = 0.14
		eye.mesh = em
		var emat: StandardMaterial3D = StandardMaterial3D.new()
		emat.albedo_color = Color(1.0, 0.95, 0.55)
		emat.emission_enabled = true
		emat.emission = Color(1.0, 0.95, 0.60)
		emat.emission_energy_multiplier = 9.0
		emat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		eye.material_override = emat
		eye.position = Vector3(ex, 0.10, -0.50)
		pivot.add_child(eye)
	# Trailing wisp tail particles below the body
	var wisps: GPUParticles3D = GPUParticles3D.new()
	wisps.amount = 50
	wisps.lifetime = 1.6
	wisps.position = Vector3(0, -0.20, 0)
	var wmat: ParticleProcessMaterial = ParticleProcessMaterial.new()
	wmat.direction = Vector3(0, -1, 0)
	wmat.spread = 22.0
	wmat.initial_velocity_min = 0.55
	wmat.initial_velocity_max = 1.20
	wmat.gravity = Vector3(0, -0.40, 0)
	wmat.scale_min = 0.16
	wmat.scale_max = 0.32
	wmat.color = Color(1.0, 0.55, 0.15, 0.85)
	wisps.process_material = wmat
	var qm: QuadMesh = QuadMesh.new()
	qm.size = Vector2(0.30, 0.30)
	wisps.draw_pass_1 = qm
	pivot.add_child(wisps)
	# Crown of orbiting ember motes — 4 small unshaded spheres
	for i in 4:
		var ang: float = (TAU / 4.0) * float(i)
		var mote: MeshInstance3D = MeshInstance3D.new()
		var msm: SphereMesh = SphereMesh.new()
		msm.radius = 0.10
		msm.height = 0.20
		mote.mesh = msm
		var mmat: StandardMaterial3D = StandardMaterial3D.new()
		mmat.albedo_color = Color(1.0, 0.65, 0.20)
		mmat.emission_enabled = true
		mmat.emission = Color(1.0, 0.65, 0.20)
		mmat.emission_energy_multiplier = 7.0
		mmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		mote.material_override = mmat
		mote.position = Vector3(cos(ang) * 0.85, 0.55, sin(ang) * 0.85)
		pivot.add_child(mote)
	# OmniLight at the body
	var lt: OmniLight3D = OmniLight3D.new()
	lt.position = Vector3(0, 0, 0)
	lt.light_color = Color(1.0, 0.55, 0.15)
	lt.light_energy = 2.4
	lt.omni_range = 6.5
	pivot.add_child(lt)
	# Slow orbital drift in a small circle around the spawn point
	var origin: Vector3 = pivot.position
	var orbit: Tween = pivot.create_tween().set_loops()
	orbit.tween_property(pivot, "position", origin + Vector3(2.5, 0.40, 0), 3.0).set_ease(Tween.EASE_IN_OUT)
	orbit.tween_property(pivot, "position", origin + Vector3(0, 0.80, 2.5), 3.0).set_ease(Tween.EASE_IN_OUT)
	orbit.tween_property(pivot, "position", origin + Vector3(-2.5, 0.40, 0), 3.0).set_ease(Tween.EASE_IN_OUT)
	orbit.tween_property(pivot, "position", origin + Vector3(0, 0.0, -2.5), 3.0).set_ease(Tween.EASE_IN_OUT)
	orbit.tween_property(pivot, "position", origin, 3.0).set_ease(Tween.EASE_IN_OUT)
	# Self-rotation so motes swirl around
	var spin: Tween = pivot.create_tween().set_loops()
	spin.tween_property(pivot, "rotation:y", TAU, 5.0)
	# Core breathing pulse
	var pulse2: Tween = pivot.create_tween().set_loops()
	pulse2.tween_property(core, "scale", Vector3(1.18, 1.18, 1.18), 0.85).set_ease(Tween.EASE_IN_OUT)
	pulse2.tween_property(core, "scale", Vector3(0.92, 0.92, 0.92), 0.85).set_ease(Tween.EASE_IN_OUT)


func _build_d9_forge_anvil_shrine(geom: Node) -> void:
	## Epic-9 T57: small forge shrine — anvil on a basalt plinth with a
	## propped hammer, ringed by a glowing rune circle. Suggests a
	## save/rest point in the second half of D9.
	var pivot: Node3D = Node3D.new()
	pivot.name = "D9_ForgeAnvilShrine"
	pivot.position = D9_CENTER + Vector3(60, 0, -4)
	geom.add_child(pivot)
	# Basalt plinth — wide stone disc
	var plinth: MeshInstance3D = MeshInstance3D.new()
	var pcm: CylinderMesh = CylinderMesh.new()
	pcm.top_radius = 1.40
	pcm.bottom_radius = 1.55
	pcm.height = 0.80
	plinth.mesh = pcm
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.12, 0.10, 0.09)
	stone_mat.metallic = 0.18
	stone_mat.roughness = 0.85
	stone_mat.emission_enabled = true
	stone_mat.emission = Color(1.0, 0.32, 0.05)
	stone_mat.emission_energy_multiplier = 0.30
	plinth.material_override = stone_mat
	plinth.position = Vector3(0, 0.40, 0)
	pivot.add_child(plinth)
	# Anvil body on top of plinth
	var anvil: MeshInstance3D = MeshInstance3D.new()
	var am: BoxMesh = BoxMesh.new()
	am.size = Vector3(1.20, 0.55, 0.80)
	anvil.mesh = am
	var iron_mat: StandardMaterial3D = StandardMaterial3D.new()
	iron_mat.albedo_color = Color(0.18, 0.14, 0.11)
	iron_mat.metallic = 0.85
	iron_mat.roughness = 0.35
	iron_mat.emission_enabled = true
	iron_mat.emission = Color(1.0, 0.40, 0.10)
	iron_mat.emission_energy_multiplier = 0.55
	anvil.material_override = iron_mat
	anvil.position = Vector3(0, 1.10, 0)
	pivot.add_child(anvil)
	# Anvil horn nub
	var horn: MeshInstance3D = MeshInstance3D.new()
	var hm: PrismMesh = PrismMesh.new()
	hm.size = Vector3(0.40, 0.45, 0.65)
	horn.mesh = hm
	horn.material_override = iron_mat
	horn.position = Vector3(0.75, 1.10, 0)
	horn.rotation.z = -PI / 2.0
	pivot.add_child(horn)
	# Hammer propped against the anvil — head + shaft
	var hammer_head: MeshInstance3D = MeshInstance3D.new()
	var hhm: BoxMesh = BoxMesh.new()
	hhm.size = Vector3(0.32, 0.32, 0.55)
	hammer_head.mesh = hhm
	hammer_head.material_override = iron_mat
	hammer_head.position = Vector3(-0.85, 1.30, 0.05)
	hammer_head.rotation.z = 0.40
	pivot.add_child(hammer_head)
	var hammer_shaft: MeshInstance3D = MeshInstance3D.new()
	var hsm: CylinderMesh = CylinderMesh.new()
	hsm.top_radius = 0.05
	hsm.bottom_radius = 0.055
	hsm.height = 1.10
	hammer_shaft.mesh = hsm
	var wood_mat: StandardMaterial3D = StandardMaterial3D.new()
	wood_mat.albedo_color = Color(0.32, 0.20, 0.12)
	wood_mat.roughness = 0.80
	hammer_shaft.material_override = wood_mat
	hammer_shaft.position = Vector3(-0.55, 0.85, 0.05)
	hammer_shaft.rotation.z = 0.40
	pivot.add_child(hammer_shaft)
	# Glowing rune circle on the ground around the plinth
	var ring: MeshInstance3D = MeshInstance3D.new()
	var trm: TorusMesh = TorusMesh.new()
	trm.inner_radius = 2.20
	trm.outer_radius = 2.35
	ring.mesh = trm
	var ring_mat: StandardMaterial3D = StandardMaterial3D.new()
	ring_mat.albedo_color = Color(1.0, 0.55, 0.10)
	ring_mat.emission_enabled = true
	ring_mat.emission = Color(1.0, 0.55, 0.10)
	ring_mat.emission_energy_multiplier = 4.5
	ring_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	ring.material_override = ring_mat
	ring.position = Vector3(0, 0.04, 0)
	pivot.add_child(ring)
	# 4 rune symbols around the ring (small unshaded box decals)
	for i in 4:
		var ang: float = (TAU / 4.0) * float(i) + PI / 4.0
		var rune: MeshInstance3D = MeshInstance3D.new()
		var rmsh: BoxMesh = BoxMesh.new()
		rmsh.size = Vector3(0.40, 0.04, 0.40)
		rune.mesh = rmsh
		rune.material_override = ring_mat
		rune.position = Vector3(cos(ang) * 2.27, 0.05, sin(ang) * 2.27)
		rune.rotation.y = ang
		pivot.add_child(rune)
	# Glowing focus orb floating above the anvil
	var orb: MeshInstance3D = MeshInstance3D.new()
	var om: SphereMesh = SphereMesh.new()
	om.radius = 0.18
	om.height = 0.36
	orb.mesh = om
	var orb_mat: StandardMaterial3D = StandardMaterial3D.new()
	orb_mat.albedo_color = Color(1.0, 0.65, 0.20)
	orb_mat.emission_enabled = true
	orb_mat.emission = Color(1.0, 0.70, 0.25)
	orb_mat.emission_energy_multiplier = 8.0
	orb_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	orb.material_override = orb_mat
	orb.position = Vector3(0, 2.20, 0)
	pivot.add_child(orb)
	# Orb bob + ring slow rotation
	var bob: Tween = pivot.create_tween().set_loops()
	bob.tween_property(orb, "position:y", 2.45, 1.5).set_ease(Tween.EASE_IN_OUT)
	bob.tween_property(orb, "position:y", 2.00, 1.5).set_ease(Tween.EASE_IN_OUT)
	var spin: Tween = pivot.create_tween().set_loops()
	spin.tween_property(ring, "rotation:y", TAU, 12.0)
	# Ring emission pulse
	var rpulse: Tween = pivot.create_tween().set_loops()
	rpulse.tween_property(ring_mat, "emission_energy_multiplier", 6.0, 1.4).set_ease(Tween.EASE_IN_OUT)
	rpulse.tween_property(ring_mat, "emission_energy_multiplier", 3.2, 1.4).set_ease(Tween.EASE_IN_OUT)
	# Shrine OmniLight
	var lt: OmniLight3D = OmniLight3D.new()
	lt.position = Vector3(0, 1.80, 0)
	lt.light_color = Color(1.0, 0.55, 0.15)
	lt.light_energy = 3.4
	lt.omni_range = 9.0
	pivot.add_child(lt)
	# Plinth + anvil collision
	var stb: StaticBody3D = StaticBody3D.new()
	stb.position = Vector3(0, 0.40, 0)
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cyl: CylinderShape3D = CylinderShape3D.new()
	cyl.height = 0.80
	cyl.radius = 1.55
	cs.shape = cyl
	stb.add_child(cs)
	pivot.add_child(stb)


func _build_d9_slag_golem_patroller(geom: Node) -> void:
	## Epic-9 T58: a chunky molten-rock golem patrolling the path near
	## the forge anvil shrine. Charred basalt body with glowing lava seams,
	## hunched silhouette, slow ground-pound walking gait via Z patrol.
	var pivot: Node3D = Node3D.new()
	pivot.name = "D9_SlagGolemPatroller"
	pivot.position = D9_CENTER + Vector3(56, 0, -10)
	geom.add_child(pivot)
	# Charred body material
	var rock_mat: StandardMaterial3D = StandardMaterial3D.new()
	rock_mat.albedo_color = Color(0.10, 0.07, 0.06)
	rock_mat.metallic = 0.20
	rock_mat.roughness = 0.85
	rock_mat.emission_enabled = true
	rock_mat.emission = Color(1.0, 0.32, 0.05)
	rock_mat.emission_energy_multiplier = 0.55
	# Lava seam material (unshaded bright orange for cracks)
	var seam_mat: StandardMaterial3D = StandardMaterial3D.new()
	seam_mat.albedo_color = Color(1.0, 0.55, 0.10)
	seam_mat.emission_enabled = true
	seam_mat.emission = Color(1.0, 0.55, 0.10)
	seam_mat.emission_energy_multiplier = 5.0
	seam_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	# Hunched torso — wide flattened sphere
	var torso: MeshInstance3D = MeshInstance3D.new()
	var tm: SphereMesh = SphereMesh.new()
	tm.radius = 1.05
	tm.height = 1.65
	torso.mesh = tm
	torso.material_override = rock_mat
	torso.position = Vector3(0, 1.30, 0)
	torso.scale = Vector3(1.15, 0.85, 0.95)
	pivot.add_child(torso)
	# Lava seam crack across chest (vertical bar)
	var seam: MeshInstance3D = MeshInstance3D.new()
	var sm: BoxMesh = BoxMesh.new()
	sm.size = Vector3(0.10, 0.95, 0.06)
	seam.mesh = sm
	seam.material_override = seam_mat
	seam.position = Vector3(0, 1.30, -0.85)
	pivot.add_child(seam)
	# Head — small lumpy sphere
	var head: MeshInstance3D = MeshInstance3D.new()
	var hm: SphereMesh = SphereMesh.new()
	hm.radius = 0.55
	hm.height = 0.95
	head.mesh = hm
	head.material_override = rock_mat
	head.position = Vector3(0, 2.45, 0.40)
	head.scale = Vector3(1.0, 0.85, 1.0)
	pivot.add_child(head)
	# Two eye slits (small unshaded amber bars)
	for ex in [-0.18, 0.18]:
		var eye: MeshInstance3D = MeshInstance3D.new()
		var em: BoxMesh = BoxMesh.new()
		em.size = Vector3(0.14, 0.06, 0.04)
		eye.mesh = em
		eye.material_override = seam_mat
		eye.position = Vector3(ex, 2.50, 0.85)
		pivot.add_child(eye)
	# Two heavy arms hanging at sides
	for side in [-1.10, 1.10]:
		var shoulder: MeshInstance3D = MeshInstance3D.new()
		var shm: SphereMesh = SphereMesh.new()
		shm.radius = 0.42
		shm.height = 0.75
		shoulder.mesh = shm
		shoulder.material_override = rock_mat
		shoulder.position = Vector3(side, 1.85, 0)
		pivot.add_child(shoulder)
		var arm: MeshInstance3D = MeshInstance3D.new()
		var am: BoxMesh = BoxMesh.new()
		am.size = Vector3(0.55, 1.30, 0.55)
		arm.mesh = am
		arm.material_override = rock_mat
		arm.position = Vector3(side, 1.05, 0.10)
		pivot.add_child(arm)
		# Heavy boulder fist
		var fist: MeshInstance3D = MeshInstance3D.new()
		var fm: SphereMesh = SphereMesh.new()
		fm.radius = 0.50
		fm.height = 0.95
		fist.mesh = fm
		fist.material_override = rock_mat
		fist.position = Vector3(side, 0.30, 0.25)
		pivot.add_child(fist)
		# Lava seam ring on the arm (small accent)
		var aring: MeshInstance3D = MeshInstance3D.new()
		var arm_torus: TorusMesh = TorusMesh.new()
		arm_torus.inner_radius = 0.30
		arm_torus.outer_radius = 0.34
		aring.mesh = arm_torus
		aring.material_override = seam_mat
		aring.position = Vector3(side, 1.55, 0.10)
		pivot.add_child(aring)
	# Two stumpy legs
	for side in [-0.42, 0.42]:
		var leg: MeshInstance3D = MeshInstance3D.new()
		var lm: BoxMesh = BoxMesh.new()
		lm.size = Vector3(0.55, 0.55, 0.55)
		leg.mesh = lm
		leg.material_override = rock_mat
		leg.position = Vector3(side, 0.30, 0)
		pivot.add_child(leg)
	# Ember plume rising from the chest seam crack
	var embers: GPUParticles3D = GPUParticles3D.new()
	embers.amount = 30
	embers.lifetime = 1.6
	embers.position = Vector3(0, 1.85, -0.85)
	var pmat: ParticleProcessMaterial = ParticleProcessMaterial.new()
	pmat.direction = Vector3(0, 1, -0.20)
	pmat.spread = 18.0
	pmat.initial_velocity_min = 0.55
	pmat.initial_velocity_max = 1.20
	pmat.gravity = Vector3(0, -0.30, 0)
	pmat.scale_min = 0.10
	pmat.scale_max = 0.18
	pmat.color = Color(1.0, 0.55, 0.15, 0.95)
	embers.process_material = pmat
	var qm: QuadMesh = QuadMesh.new()
	qm.size = Vector2(0.18, 0.18)
	embers.draw_pass_1 = qm
	pivot.add_child(embers)
	# Heavy amber light at the body
	var lt: OmniLight3D = OmniLight3D.new()
	lt.position = Vector3(0, 1.30, 0)
	lt.light_color = Color(1.0, 0.45, 0.10)
	lt.light_energy = 2.6
	lt.omni_range = 8.0
	pivot.add_child(lt)
	# Slow Z-patrol with rotation flip on each end
	var origin_z: float = pivot.position.z
	var patrol: Tween = pivot.create_tween().set_loops()
	patrol.tween_property(pivot, "position:z", origin_z + 6.0, 5.5).set_ease(Tween.EASE_IN_OUT)
	patrol.tween_property(pivot, "rotation:y", PI, 0.5)
	patrol.tween_property(pivot, "position:z", origin_z, 5.5).set_ease(Tween.EASE_IN_OUT)
	patrol.tween_property(pivot, "rotation:y", 0.0, 0.5)
	# Body bob — gives a heavy lumbering walk
	var bob: Tween = pivot.create_tween().set_loops()
	bob.tween_property(torso, "position:y", 1.40, 0.8).set_ease(Tween.EASE_IN_OUT)
	bob.tween_property(torso, "position:y", 1.30, 0.8).set_ease(Tween.EASE_IN_OUT)
	# Seam pulse breathing
	var spulse: Tween = pivot.create_tween().set_loops()
	spulse.tween_property(seam_mat, "emission_energy_multiplier", 7.0, 1.2).set_ease(Tween.EASE_IN_OUT)
	spulse.tween_property(seam_mat, "emission_energy_multiplier", 3.5, 1.2).set_ease(Tween.EASE_IN_OUT)
	# Capsule collision
	var stb2: StaticBody3D = StaticBody3D.new()
	stb2.position = Vector3(0, 1.30, 0)
	var cs2: CollisionShape3D = CollisionShape3D.new()
	var caps: CapsuleShape3D = CapsuleShape3D.new()
	caps.height = 2.60
	caps.radius = 1.05
	cs2.shape = caps
	stb2.add_child(cs2)
	pivot.add_child(stb2)


func _build_d9_forge_cart_caravan(geom: Node) -> void:
	## Epic-9 T59: 3 ore-laden minecarts moving in a line along a track
	## past the forge anvil shrine. Iron rails + wood ties on the ground,
	## carts loaded with glowing ore chunks, slow tween convoy along X.
	var pivot: Node3D = Node3D.new()
	pivot.name = "D9_ForgeCartCaravan"
	pivot.position = D9_CENTER + Vector3(45, 0, 22)
	geom.add_child(pivot)
	# === TRACK: 2 parallel iron rails + wood ties ===
	var rail_mat: StandardMaterial3D = StandardMaterial3D.new()
	rail_mat.albedo_color = Color(0.18, 0.16, 0.14)
	rail_mat.metallic = 0.85
	rail_mat.roughness = 0.30
	var tie_mat: StandardMaterial3D = StandardMaterial3D.new()
	tie_mat.albedo_color = Color(0.22, 0.14, 0.08)
	tie_mat.roughness = 0.85
	# Rails — 2 long thin boxes
	for rz in [-0.55, 0.55]:
		var rail: MeshInstance3D = MeshInstance3D.new()
		var rm: BoxMesh = BoxMesh.new()
		rm.size = Vector3(28.0, 0.10, 0.10)
		rail.mesh = rm
		rail.material_override = rail_mat
		rail.position = Vector3(0, 0.10, rz)
		pivot.add_child(rail)
	# Wood ties spaced along the track
	for i in 14:
		var tie: MeshInstance3D = MeshInstance3D.new()
		var tm: BoxMesh = BoxMesh.new()
		tm.size = Vector3(0.45, 0.12, 1.40)
		tie.mesh = tm
		tie.material_override = tie_mat
		tie.position = Vector3(-13.0 + float(i) * 2.0, 0.06, 0)
		pivot.add_child(tie)
	# === CARTS: 3 minecarts loaded with glowing ore ===
	var iron_mat: StandardMaterial3D = StandardMaterial3D.new()
	iron_mat.albedo_color = Color(0.20, 0.16, 0.13)
	iron_mat.metallic = 0.80
	iron_mat.roughness = 0.40
	var ore_mat: StandardMaterial3D = StandardMaterial3D.new()
	ore_mat.albedo_color = Color(1.0, 0.55, 0.10)
	ore_mat.emission_enabled = true
	ore_mat.emission = Color(1.0, 0.55, 0.10)
	ore_mat.emission_energy_multiplier = 5.0
	ore_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	# Build carts (offsets along X for the convoy spacing)
	for i in 3:
		var cart: Node3D = Node3D.new()
		cart.name = "ForgeCart_%d" % i
		cart.position = Vector3(-8.0 + float(i) * 4.0, 0.0, 0)
		pivot.add_child(cart)
		# Cart body box (open top)
		var bin: MeshInstance3D = MeshInstance3D.new()
		var bm: BoxMesh = BoxMesh.new()
		bm.size = Vector3(2.10, 0.85, 1.40)
		bin.mesh = bm
		bin.material_override = iron_mat
		bin.position = Vector3(0, 0.65, 0)
		cart.add_child(bin)
		# 4 wheels (small cylinders rotated to roll)
		for sx in [-0.85, 0.85]:
			for sz in [-0.55, 0.55]:
				var wheel: MeshInstance3D = MeshInstance3D.new()
				var wm: CylinderMesh = CylinderMesh.new()
				wm.top_radius = 0.18
				wm.bottom_radius = 0.18
				wm.height = 0.10
				wheel.mesh = wm
				wheel.material_override = iron_mat
				wheel.position = Vector3(sx, 0.18, sz)
				wheel.rotation.z = PI / 2.0
				cart.add_child(wheel)
		# Ore chunks piled inside (3 unshaded ember spheres)
		for j in 3:
			var ore: MeshInstance3D = MeshInstance3D.new()
			var om: SphereMesh = SphereMesh.new()
			om.radius = 0.30 + float(j) * 0.04
			om.height = 0.55 + float(j) * 0.06
			ore.mesh = om
			ore.material_override = ore_mat
			ore.position = Vector3(-0.55 + float(j) * 0.55, 1.18, 0)
			cart.add_child(ore)
		# Per-cart amber glow
		var clt: OmniLight3D = OmniLight3D.new()
		clt.position = Vector3(0, 1.10, 0)
		clt.light_color = Color(1.0, 0.50, 0.12)
		clt.light_energy = 2.4
		clt.omni_range = 4.5
		cart.add_child(clt)
		# Slow caravan motion: cart moves +X 16m and resets, staggered offsets
		var origin_x: float = cart.position.x
		var convoy: Tween = pivot.create_tween().set_loops()
		convoy.tween_property(cart, "position:x", origin_x + 16.0, 22.0)
		convoy.tween_property(cart, "position:x", origin_x, 0.001)
	# Track-side warning lamp post
	var post: MeshInstance3D = MeshInstance3D.new()
	var pm: CylinderMesh = CylinderMesh.new()
	pm.top_radius = 0.06
	pm.bottom_radius = 0.10
	pm.height = 2.40
	post.mesh = pm
	post.material_override = iron_mat
	post.position = Vector3(11.0, 1.20, 1.50)
	pivot.add_child(post)
	# Lamp head — unshaded amber sphere
	var lamp: MeshInstance3D = MeshInstance3D.new()
	var lm: SphereMesh = SphereMesh.new()
	lm.radius = 0.22
	lm.height = 0.44
	lamp.mesh = lm
	var lamp_mat: StandardMaterial3D = StandardMaterial3D.new()
	lamp_mat.albedo_color = Color(1.0, 0.55, 0.10)
	lamp_mat.emission_enabled = true
	lamp_mat.emission = Color(1.0, 0.55, 0.10)
	lamp_mat.emission_energy_multiplier = 6.0
	lamp_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	lamp.material_override = lamp_mat
	lamp.position = Vector3(11.0, 2.45, 1.50)
	pivot.add_child(lamp)
	# Lamp light
	var llt: OmniLight3D = OmniLight3D.new()
	llt.position = Vector3(11.0, 2.45, 1.50)
	llt.light_color = Color(1.0, 0.55, 0.15)
	llt.light_energy = 2.8
	llt.omni_range = 6.0
	pivot.add_child(llt)
	# Lamp blink
	var blink: Tween = pivot.create_tween().set_loops()
	blink.tween_property(lamp_mat, "emission_energy_multiplier", 8.5, 0.9).set_ease(Tween.EASE_IN_OUT)
	blink.tween_property(lamp_mat, "emission_energy_multiplier", 4.0, 0.9).set_ease(Tween.EASE_IN_OUT)


