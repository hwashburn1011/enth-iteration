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
	#print("[D9Builder] start")
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
	_build_d9_ore_vein_cliff(geom)
	_build_d9_mine_foreman_npc(town)
	_build_d9_hammer_target_dummy(geom)
	_build_d9_lava_ferry_boat(geom)
	_build_d9_obsidian_merchant_stall(geom)
	_build_d9_forge_guildhall(geom)
	_build_d9_guildmaster_vorn_npc(town)
	_build_d9_guildhall_banners(geom)
	_build_d9_guildhall_approach_path(geom)
	_build_d9_guildhall_training_yard(geom)
	_build_d9_apprentice_brun_npc(town)
	_build_d9_molten_geyser(geom)
	_build_d9_lava_bomb_scatter(geom)
	_build_d9_geyser_observation_deck(geom)
	_build_d9_vulcanologist_cinder_npc(town)
	_build_d9_forge_memorial(geom)
	_build_d9_memorial_keeper_ash_npc(town)
	_build_d9_collapsed_skyforge_ruin(geom)
	_build_d9_salvager_rax_npc(town)
	_build_d9_lava_brook(geom)
	_build_d9_lava_brook_bridge(geom)
	_build_d9_basalt_monolith_ridge(geom)
	_build_d9_obsidian_shard_field(geom)
	_build_d9_forge_imp_pack(geom)
	_build_d9_iron_sentinel_statues(geom)
	_build_d9_drift_lava_pool(geom)
	_build_d9_sentinel_oath_wall(geom)
	_build_d9_slag_heap_pit(geom)
	_build_d9_slagmaster_borg_npc(town)
	_build_d9_sky_cinder_fall(geom)
	_build_d9_forge_heart_acolyte_npc(town)
	_build_d9_boss_approach_gate(geom)
	_build_d9_boss_approach_skull_pile(geom)
	_build_d9_boss_approach_sentinels(geom)
	_build_d9_boss_approach_altars(geom)
	_build_d9_boss_arena_floor(geom)
	_build_d9_forge_lord(geom)
	_build_d9_welcome_banner(geom)
	_build_d9_ambient_atmosphere(geom)
	_build_d9_district_plaque(geom)
	_build_d9_arena_fortifications(geom)
	#print("[D9Builder] done")


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
		var rmb: BoxMesh = BoxMesh.new()
		rmb.size = Vector3(10.0, 0.10, 0.10)
		rail.mesh = rmb
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
		var elbow_brass: StandardMaterial3D = StandardMaterial3D.new()
		elbow_brass.albedo_color = Color(0.85, 0.65, 0.20)
		elbow_brass.metallic = 0.95
		elbow_brass.roughness = 0.20
		var elbow: MeshInstance3D = MeshInstance3D.new()
		var esm: SphereMesh = SphereMesh.new()
		esm.radius = 0.32
		esm.height = 0.55
		elbow.mesh = esm
		elbow.material_override = elbow_brass
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
	var sand_floor: MeshInstance3D = MeshInstance3D.new()
	var fcm: CylinderMesh = CylinderMesh.new()
	fcm.top_radius = 4.50
	fcm.bottom_radius = 4.50
	fcm.height = 0.10
	sand_floor.mesh = fcm
	sand_floor.material_override = sand_mat
	sand_floor.position = Vector3(0, 0.05, 0)
	arena.add_child(sand_floor)
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


func _build_d9_ore_vein_cliff(geom: Node) -> void:
	## Epic-9 T60: massive cliff wall with embedded glowing ore veins.
	## Marks the source of the cart caravan ore. Wide basalt slab with
	## diagonal ember vein streaks + a mine entrance opening + light.
	var pivot: Node3D = Node3D.new()
	pivot.name = "D9_OreVeinCliff"
	pivot.position = D9_CENTER + Vector3(58, 0, 26)
	geom.add_child(pivot)
	# Cliff slab — wide tall basalt
	var cliff: MeshInstance3D = MeshInstance3D.new()
	var cm: BoxMesh = BoxMesh.new()
	cm.size = Vector3(14.0, 9.0, 1.6)
	cliff.mesh = cm
	var rock_mat: StandardMaterial3D = StandardMaterial3D.new()
	rock_mat.albedo_color = Color(0.10, 0.08, 0.07)
	rock_mat.metallic = 0.20
	rock_mat.roughness = 0.85
	rock_mat.emission_enabled = true
	rock_mat.emission = Color(1.0, 0.30, 0.05)
	rock_mat.emission_energy_multiplier = 0.18
	cliff.material_override = rock_mat
	cliff.position = Vector3(0, 4.5, 0.50)
	pivot.add_child(cliff)
	# Vein material (unshaded amber)
	var vein_mat: StandardMaterial3D = StandardMaterial3D.new()
	vein_mat.albedo_color = Color(1.0, 0.55, 0.10)
	vein_mat.emission_enabled = true
	vein_mat.emission = Color(1.0, 0.55, 0.10)
	vein_mat.emission_energy_multiplier = 4.5
	vein_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	# 8 diagonal vein streaks across the cliff face
	for i in 8:
		var t: float = float(i) / 7.0
		var x_off: float = lerp(-5.5, 5.5, t)
		var y_off: float = 1.5 + sin(float(i) * 1.2) * 2.5
		var vein_len: float = 1.20 + float(i % 3) * 0.40
		var thickness: float = 0.10 + float(i % 2) * 0.05
		var vein: MeshInstance3D = MeshInstance3D.new()
		var vm: BoxMesh = BoxMesh.new()
		vm.size = Vector3(thickness, vein_len, 0.05)
		vein.mesh = vm
		vein.material_override = vein_mat
		vein.position = Vector3(x_off, y_off + vein_len * 0.5, -0.34)
		vein.rotation.z = (float(i % 3) - 1.0) * 0.55
		pivot.add_child(vein)
	# Mine entrance — dark archway box (recessed)
	var arch: MeshInstance3D = MeshInstance3D.new()
	var am: BoxMesh = BoxMesh.new()
	am.size = Vector3(2.80, 3.20, 0.85)
	arch.mesh = am
	var dark_mat: StandardMaterial3D = StandardMaterial3D.new()
	dark_mat.albedo_color = Color(0.02, 0.015, 0.01)
	dark_mat.roughness = 0.95
	arch.material_override = dark_mat
	arch.position = Vector3(0, 1.60, -0.20)
	pivot.add_child(arch)
	# Arch frame top — small amber bar across the top of entrance
	var frame_top: MeshInstance3D = MeshInstance3D.new()
	var fm: BoxMesh = BoxMesh.new()
	fm.size = Vector3(3.10, 0.20, 0.20)
	frame_top.mesh = fm
	frame_top.material_override = vein_mat
	frame_top.position = Vector3(0, 3.20, -0.30)
	pivot.add_child(frame_top)
	# 2 frame side posts
	for sx in [-1.45, 1.45]:
		var post: MeshInstance3D = MeshInstance3D.new()
		var fpm: BoxMesh = BoxMesh.new()
		fpm.size = Vector3(0.18, 3.20, 0.18)
		post.mesh = fpm
		post.material_override = vein_mat
		post.position = Vector3(sx, 1.60, -0.30)
		pivot.add_child(post)
	# Mine entrance OmniLight — warm amber spilling out
	var lt: OmniLight3D = OmniLight3D.new()
	lt.position = Vector3(0, 1.80, -0.50)
	lt.light_color = Color(1.0, 0.50, 0.12)
	lt.light_energy = 3.6
	lt.omni_range = 8.5
	pivot.add_child(lt)
	# 3 ore chunk piles at the base of the cliff (loose ore)
	for i in 3:
		var px: float = -3.0 + float(i) * 3.0
		var pile: MeshInstance3D = MeshInstance3D.new()
		var psm: SphereMesh = SphereMesh.new()
		psm.radius = 0.45 + float(i % 2) * 0.10
		psm.height = 0.65 + float(i % 2) * 0.10
		pile.mesh = psm
		pile.material_override = vein_mat
		pile.position = Vector3(px, 0.30, -0.85)
		pivot.add_child(pile)
	# Per-vein ember pulse (staggered)
	# Cycle the cliff emission pulse so the whole face throbs
	var cliff_pulse: Tween = pivot.create_tween().set_loops()
	cliff_pulse.tween_property(vein_mat, "emission_energy_multiplier", 6.5, 1.6).set_ease(Tween.EASE_IN_OUT)
	cliff_pulse.tween_property(vein_mat, "emission_energy_multiplier", 3.0, 1.6).set_ease(Tween.EASE_IN_OUT)
	# Cliff collision — big box
	var stb: StaticBody3D = StaticBody3D.new()
	stb.position = Vector3(0, 4.5, 0.50)
	var cs: CollisionShape3D = CollisionShape3D.new()
	var bs: BoxShape3D = BoxShape3D.new()
	bs.size = Vector3(14.0, 9.0, 1.6)
	cs.shape = bs
	stb.add_child(cs)
	pivot.add_child(stb)


func _build_d9_mine_foreman_npc(town: Node) -> void:
	## Epic-9 T61: Mine Foreman Vex — heavy-set NPC standing at the
	## ore vein cliff entrance with a pickaxe propped at his side and
	## a hard hat with a glowing front lamp. Boss of the mining op.
	var slots: Node3D = town.get_node_or_null("NPCSlots") as Node3D
	if slots == null:
		return
	var slot: Marker3D = Marker3D.new()
	slot.name = "D9MineForemanSlot"
	slot.position = Vector3(D9_CENTER.x + 56, 0, 24)
	slots.add_child(slot)
	var npc_scene: PackedScene = load("res://scenes/entities/npcs/VillagerR3.tscn") as PackedScene
	if npc_scene == null:
		return
	var npc: Node3D = npc_scene.instantiate() as Node3D
	npc.name = "D9MineForeman"
	if "npc_name" in npc:
		npc.set("npc_name", "Mine Foreman Vex")
	if "npc_id" in npc:
		npc.set("npc_id", "d9_mine_foreman")
	slot.add_child(npc)
	# Heavy work overalls — wide chest box
	var overall_mat: StandardMaterial3D = StandardMaterial3D.new()
	overall_mat.albedo_color = Color(0.18, 0.13, 0.10)
	overall_mat.roughness = 0.85
	overall_mat.metallic = 0.20
	var overalls: MeshInstance3D = MeshInstance3D.new()
	var ob: BoxMesh = BoxMesh.new()
	ob.size = Vector3(1.05, 1.20, 0.65)
	overalls.mesh = ob
	overalls.material_override = overall_mat
	overalls.position = Vector3(0, 1.10, 0)
	npc.add_child(overalls)
	# Reflective safety stripe across chest
	var stripe: MeshInstance3D = MeshInstance3D.new()
	var stm: BoxMesh = BoxMesh.new()
	stm.size = Vector3(1.10, 0.10, 0.04)
	stripe.mesh = stm
	var stripe_mat: StandardMaterial3D = StandardMaterial3D.new()
	stripe_mat.albedo_color = Color(1.0, 0.85, 0.20)
	stripe_mat.emission_enabled = true
	stripe_mat.emission = Color(1.0, 0.85, 0.20)
	stripe_mat.emission_energy_multiplier = 2.5
	stripe_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	stripe.material_override = stripe_mat
	stripe.position = Vector3(0, 1.30, -0.34)
	npc.add_child(stripe)
	# Hard hat — wide flat dome on the head
	var hat: MeshInstance3D = MeshInstance3D.new()
	var hm: SphereMesh = SphereMesh.new()
	hm.radius = 0.32
	hm.height = 0.55
	hat.mesh = hm
	var hat_mat: StandardMaterial3D = StandardMaterial3D.new()
	hat_mat.albedo_color = Color(0.95, 0.50, 0.10)
	hat_mat.metallic = 0.20
	hat_mat.roughness = 0.55
	hat.material_override = hat_mat
	hat.position = Vector3(0, 2.00, 0)
	hat.scale = Vector3(1.0, 0.55, 1.0)
	npc.add_child(hat)
	# Hard hat brim — flat torus
	var brim: MeshInstance3D = MeshInstance3D.new()
	var brm: TorusMesh = TorusMesh.new()
	brm.inner_radius = 0.30
	brm.outer_radius = 0.42
	brim.mesh = brm
	brim.material_override = hat_mat
	brim.position = Vector3(0, 1.93, 0)
	brim.rotation.x = PI / 2.0
	npc.add_child(brim)
	# Glowing front headlamp on the hat
	var lamp: MeshInstance3D = MeshInstance3D.new()
	var lmm: SphereMesh = SphereMesh.new()
	lmm.radius = 0.08
	lmm.height = 0.16
	lamp.mesh = lmm
	var lamp_mat: StandardMaterial3D = StandardMaterial3D.new()
	lamp_mat.albedo_color = Color(1.0, 0.95, 0.55)
	lamp_mat.emission_enabled = true
	lamp_mat.emission = Color(1.0, 0.95, 0.60)
	lamp_mat.emission_energy_multiplier = 8.0
	lamp_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	lamp.material_override = lamp_mat
	lamp.position = Vector3(0, 2.05, -0.32)
	npc.add_child(lamp)
	# Pickaxe propped at his side — shaft + head
	var iron_mat: StandardMaterial3D = StandardMaterial3D.new()
	iron_mat.albedo_color = Color(0.18, 0.14, 0.11)
	iron_mat.metallic = 0.85
	iron_mat.roughness = 0.40
	var wood_mat: StandardMaterial3D = StandardMaterial3D.new()
	wood_mat.albedo_color = Color(0.32, 0.20, 0.12)
	wood_mat.roughness = 0.80
	var pick_shaft: MeshInstance3D = MeshInstance3D.new()
	var psm: CylinderMesh = CylinderMesh.new()
	psm.top_radius = 0.05
	psm.bottom_radius = 0.06
	psm.height = 1.45
	pick_shaft.mesh = psm
	pick_shaft.material_override = wood_mat
	pick_shaft.position = Vector3(0.55, 1.00, 0.05)
	pick_shaft.rotation.z = -0.20
	npc.add_child(pick_shaft)
	# Pickaxe head — angled prism
	var pick_head: MeshInstance3D = MeshInstance3D.new()
	var phm: PrismMesh = PrismMesh.new()
	phm.size = Vector3(0.20, 0.65, 0.18)
	pick_head.mesh = phm
	pick_head.material_override = iron_mat
	pick_head.position = Vector3(0.40, 1.78, 0.05)
	pick_head.rotation.z = PI / 2.0 + 0.20
	npc.add_child(pick_head)
	# Foreman OmniLight (subtle warm wash from the lamp)
	var lt: OmniLight3D = OmniLight3D.new()
	lt.position = Vector3(0, 2.05, -0.40)
	lt.light_color = Color(1.0, 0.85, 0.45)
	lt.light_energy = 2.4
	lt.omni_range = 5.5
	npc.add_child(lt)
	# Lamp pulse — subtle blink as if scanning
	var blink: Tween = npc.create_tween().set_loops()
	blink.tween_property(lamp_mat, "emission_energy_multiplier", 10.0, 1.8).set_ease(Tween.EASE_IN_OUT)
	blink.tween_property(lamp_mat, "emission_energy_multiplier", 6.0, 1.8).set_ease(Tween.EASE_IN_OUT)


func _build_d9_hammer_target_dummy(geom: Node) -> void:
	## Epic-9 T62: heavy iron training target dummy near the forge anvil
	## shrine. Stout iron post with a target ring, dent decals on the
	## front face, swaying recoil animation when hit (idle subtle wobble).
	var pivot: Node3D = Node3D.new()
	pivot.name = "D9_HammerTargetDummy"
	pivot.position = D9_CENTER + Vector3(64, 0, 2)
	geom.add_child(pivot)
	# Iron material
	var iron_mat: StandardMaterial3D = StandardMaterial3D.new()
	iron_mat.albedo_color = Color(0.18, 0.14, 0.11)
	iron_mat.metallic = 0.85
	iron_mat.roughness = 0.40
	iron_mat.emission_enabled = true
	iron_mat.emission = Color(1.0, 0.30, 0.05)
	iron_mat.emission_energy_multiplier = 0.30
	# Stone base anchor
	var base: MeshInstance3D = MeshInstance3D.new()
	var bcm: CylinderMesh = CylinderMesh.new()
	bcm.top_radius = 0.85
	bcm.bottom_radius = 1.00
	bcm.height = 0.35
	base.mesh = bcm
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.10, 0.08, 0.07)
	stone_mat.roughness = 0.85
	base.material_override = stone_mat
	base.position = Vector3(0, 0.18, 0)
	pivot.add_child(base)
	# Main post — tall iron cylinder
	var post: MeshInstance3D = MeshInstance3D.new()
	var pcm: CylinderMesh = CylinderMesh.new()
	pcm.top_radius = 0.45
	pcm.bottom_radius = 0.55
	pcm.height = 2.20
	post.mesh = pcm
	post.material_override = iron_mat
	post.position = Vector3(0, 1.45, 0)
	pivot.add_child(post)
	# Target ring on the front of the post — torus facing camera
	var ring: MeshInstance3D = MeshInstance3D.new()
	var trm: TorusMesh = TorusMesh.new()
	trm.inner_radius = 0.30
	trm.outer_radius = 0.40
	ring.mesh = trm
	var ring_mat: StandardMaterial3D = StandardMaterial3D.new()
	ring_mat.albedo_color = Color(1.0, 0.55, 0.10)
	ring_mat.emission_enabled = true
	ring_mat.emission = Color(1.0, 0.55, 0.10)
	ring_mat.emission_energy_multiplier = 5.5
	ring_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	ring.material_override = ring_mat
	ring.position = Vector3(0, 1.85, -0.55)
	ring.rotation.x = PI / 2.0
	pivot.add_child(ring)
	# Bullseye dot in the center of the ring
	var dot: MeshInstance3D = MeshInstance3D.new()
	var dm: SphereMesh = SphereMesh.new()
	dm.radius = 0.10
	dm.height = 0.20
	dot.mesh = dm
	var dot_mat: StandardMaterial3D = StandardMaterial3D.new()
	dot_mat.albedo_color = Color(1.0, 0.85, 0.30)
	dot_mat.emission_enabled = true
	dot_mat.emission = Color(1.0, 0.85, 0.30)
	dot_mat.emission_energy_multiplier = 7.0
	dot_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	dot.material_override = dot_mat
	dot.position = Vector3(0, 1.85, -0.62)
	pivot.add_child(dot)
	# 3 dent decals around the ring (small dark unshaded boxes for "scuffs")
	var dent_mat: StandardMaterial3D = StandardMaterial3D.new()
	dent_mat.albedo_color = Color(0.05, 0.04, 0.03)
	dent_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for i in 3:
		var ang: float = (TAU / 3.0) * float(i) + 0.40
		var dent: MeshInstance3D = MeshInstance3D.new()
		var dnt_box: BoxMesh = BoxMesh.new()
		dnt_box.size = Vector3(0.18, 0.04, 0.04)
		dent.mesh = dnt_box
		dent.material_override = dent_mat
		dent.position = Vector3(cos(ang) * 0.55, 1.85 + sin(ang) * 0.55, -0.55)
		dent.rotation.z = ang
		pivot.add_child(dent)
	# Score marks scratched in the side of the post — short emissive bars
	for i in 5:
		var mark: MeshInstance3D = MeshInstance3D.new()
		var mb: BoxMesh = BoxMesh.new()
		mb.size = Vector3(0.04, 0.20, 0.04)
		mark.mesh = mb
		mark.material_override = ring_mat
		mark.position = Vector3(0.50, 0.65 + float(i) * 0.10, 0.40)
		mark.rotation.z = -0.20
		pivot.add_child(mark)
	# Swaying idle wobble — subtle so it reads as "ready to be hit"
	var wobble: Tween = pivot.create_tween().set_loops()
	wobble.tween_property(post, "rotation:z", 0.025, 1.5).set_ease(Tween.EASE_IN_OUT)
	wobble.tween_property(post, "rotation:z", -0.025, 1.5).set_ease(Tween.EASE_IN_OUT)
	# Bullseye dot pulse to call attention
	var dpulse: Tween = pivot.create_tween().set_loops()
	dpulse.tween_property(dot_mat, "emission_energy_multiplier", 9.0, 0.85).set_ease(Tween.EASE_IN_OUT)
	dpulse.tween_property(dot_mat, "emission_energy_multiplier", 5.0, 0.85).set_ease(Tween.EASE_IN_OUT)
	# Target light
	var lt: OmniLight3D = OmniLight3D.new()
	lt.position = Vector3(0, 1.85, -0.70)
	lt.light_color = Color(1.0, 0.55, 0.15)
	lt.light_energy = 2.4
	lt.omni_range = 5.5
	pivot.add_child(lt)
	# Solid post collision so the player can't walk through
	var stb: StaticBody3D = StaticBody3D.new()
	stb.position = Vector3(0, 1.45, 0)
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cyl: CylinderShape3D = CylinderShape3D.new()
	cyl.height = 2.20
	cyl.radius = 0.55
	cs.shape = cyl
	stb.add_child(cs)
	pivot.add_child(stb)


func _build_d9_lava_ferry_boat(geom: Node) -> void:
	## Epic-9 T63: small iron skiff floating on the cascade pool, ferries
	## ore cargo across. Slow drift along the pool surface from one bank
	## to the other, with rocking idle bob and a glowing cargo crate.
	var pivot: Node3D = Node3D.new()
	pivot.name = "D9_LavaFerryBoat"
	pivot.position = D9_CENTER + Vector3(50, 0.30, 5)
	geom.add_child(pivot)
	# Iron hull material
	var hull_mat: StandardMaterial3D = StandardMaterial3D.new()
	hull_mat.albedo_color = Color(0.18, 0.14, 0.11)
	hull_mat.metallic = 0.85
	hull_mat.roughness = 0.40
	hull_mat.emission_enabled = true
	hull_mat.emission = Color(1.0, 0.30, 0.05)
	hull_mat.emission_energy_multiplier = 0.45
	# Hull — wide flat box
	var hull: MeshInstance3D = MeshInstance3D.new()
	var hm: BoxMesh = BoxMesh.new()
	hm.size = Vector3(2.40, 0.30, 1.20)
	hull.mesh = hm
	hull.material_override = hull_mat
	hull.position = Vector3(0, 0.20, 0)
	pivot.add_child(hull)
	# Bow prow — pointed prism on the front
	var prow: MeshInstance3D = MeshInstance3D.new()
	var prm: PrismMesh = PrismMesh.new()
	prm.size = Vector3(0.55, 0.30, 0.95)
	prow.mesh = prm
	prow.material_override = hull_mat
	prow.position = Vector3(1.45, 0.20, 0)
	prow.rotation.z = -PI / 2.0
	pivot.add_child(prow)
	# 4 hull rivets along each side (small unshaded amber dots)
	var rivet_mat: StandardMaterial3D = StandardMaterial3D.new()
	rivet_mat.albedo_color = Color(1.0, 0.55, 0.10)
	rivet_mat.emission_enabled = true
	rivet_mat.emission = Color(1.0, 0.55, 0.10)
	rivet_mat.emission_energy_multiplier = 4.0
	rivet_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for sx in [-0.85, -0.30, 0.30, 0.85]:
		for sz in [-0.55, 0.55]:
			var rivet: MeshInstance3D = MeshInstance3D.new()
			var rm: SphereMesh = SphereMesh.new()
			rm.radius = 0.04
			rm.height = 0.08
			rivet.mesh = rm
			rivet.material_override = rivet_mat
			rivet.position = Vector3(sx, 0.30, sz)
			pivot.add_child(rivet)
	# Cargo crate amidships — wood box with glowing ore inside
	var wood_mat: StandardMaterial3D = StandardMaterial3D.new()
	wood_mat.albedo_color = Color(0.32, 0.20, 0.12)
	wood_mat.roughness = 0.80
	var crate: MeshInstance3D = MeshInstance3D.new()
	var cm: BoxMesh = BoxMesh.new()
	cm.size = Vector3(0.85, 0.55, 0.85)
	crate.mesh = cm
	crate.material_override = wood_mat
	crate.position = Vector3(0, 0.65, 0)
	pivot.add_child(crate)
	# Glowing ore chunks on top of crate
	var ore_mat: StandardMaterial3D = StandardMaterial3D.new()
	ore_mat.albedo_color = Color(1.0, 0.55, 0.10)
	ore_mat.emission_enabled = true
	ore_mat.emission = Color(1.0, 0.55, 0.10)
	ore_mat.emission_energy_multiplier = 5.0
	ore_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for i in 3:
		var ore: MeshInstance3D = MeshInstance3D.new()
		var osm: SphereMesh = SphereMesh.new()
		osm.radius = 0.16 + float(i % 2) * 0.05
		osm.height = 0.30 + float(i % 2) * 0.06
		ore.mesh = osm
		ore.material_override = ore_mat
		ore.position = Vector3(-0.25 + float(i) * 0.25, 1.05, 0)
		pivot.add_child(ore)
	# Mast at the stern
	var mast: MeshInstance3D = MeshInstance3D.new()
	var msm: CylinderMesh = CylinderMesh.new()
	msm.top_radius = 0.04
	msm.bottom_radius = 0.05
	msm.height = 1.50
	mast.mesh = msm
	mast.material_override = hull_mat
	mast.position = Vector3(-1.00, 1.10, 0)
	pivot.add_child(mast)
	# Mast lamp at the top — unshaded amber sphere
	var lamp: MeshInstance3D = MeshInstance3D.new()
	var lmm: SphereMesh = SphereMesh.new()
	lmm.radius = 0.12
	lmm.height = 0.24
	lamp.mesh = lmm
	var lamp_mat: StandardMaterial3D = StandardMaterial3D.new()
	lamp_mat.albedo_color = Color(1.0, 0.65, 0.20)
	lamp_mat.emission_enabled = true
	lamp_mat.emission = Color(1.0, 0.65, 0.20)
	lamp_mat.emission_energy_multiplier = 7.0
	lamp_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	lamp.material_override = lamp_mat
	lamp.position = Vector3(-1.00, 1.95, 0)
	pivot.add_child(lamp)
	# Lamp light
	var lt: OmniLight3D = OmniLight3D.new()
	lt.position = Vector3(-1.00, 1.95, 0)
	lt.light_color = Color(1.0, 0.55, 0.15)
	lt.light_energy = 2.6
	lt.omni_range = 6.5
	pivot.add_child(lt)
	# Slow drift along X across the cascade pool (loop)
	var origin: Vector3 = pivot.position
	var drift: Tween = pivot.create_tween().set_loops()
	drift.tween_property(pivot, "position:x", origin.x + 8.0, 12.0).set_ease(Tween.EASE_IN_OUT)
	drift.tween_property(pivot, "rotation:y", PI, 0.8)
	drift.tween_property(pivot, "position:x", origin.x, 12.0).set_ease(Tween.EASE_IN_OUT)
	drift.tween_property(pivot, "rotation:y", 0.0, 0.8)
	# Idle rocking bob
	var bob: Tween = pivot.create_tween().set_loops()
	bob.tween_property(hull, "position:y", 0.28, 1.6).set_ease(Tween.EASE_IN_OUT)
	bob.tween_property(hull, "position:y", 0.16, 1.6).set_ease(Tween.EASE_IN_OUT)
	# Mast lamp pulse
	var lpulse: Tween = pivot.create_tween().set_loops()
	lpulse.tween_property(lamp_mat, "emission_energy_multiplier", 9.0, 1.1).set_ease(Tween.EASE_IN_OUT)
	lpulse.tween_property(lamp_mat, "emission_energy_multiplier", 5.0, 1.1).set_ease(Tween.EASE_IN_OUT)


func _build_d9_obsidian_merchant_stall(geom: Node) -> void:
	## Epic-9 T64: obsidian merchant stall — a vendor booth on the cascade
	## pool's near bank with polished obsidian counter, brass canopy poles,
	## hanging amber lanterns, and three glowing wares laid out for sale.
	var pivot: Node3D = Node3D.new()
	pivot.name = "D9_ObsidianMerchantStall"
	pivot.position = D9_CENTER + Vector3(46, 0.0, -8)
	geom.add_child(pivot)
	# Polished obsidian counter
	var obs_mat: StandardMaterial3D = StandardMaterial3D.new()
	obs_mat.albedo_color = Color(0.06, 0.05, 0.08)
	obs_mat.metallic = 0.55
	obs_mat.roughness = 0.18
	obs_mat.emission_enabled = true
	obs_mat.emission = Color(0.40, 0.18, 0.55)
	obs_mat.emission_energy_multiplier = 0.30
	var counter: MeshInstance3D = MeshInstance3D.new()
	var ctm: BoxMesh = BoxMesh.new()
	ctm.size = Vector3(3.20, 1.00, 1.10)
	counter.mesh = ctm
	counter.material_override = obs_mat
	counter.position = Vector3(0, 0.50, 0)
	pivot.add_child(counter)
	# Counter collision so player can lean on it
	var sb: StaticBody3D = StaticBody3D.new()
	sb.position = Vector3(0, 0.50, 0)
	var cs: CollisionShape3D = CollisionShape3D.new()
	var bs: BoxShape3D = BoxShape3D.new()
	bs.size = Vector3(3.20, 1.00, 1.10)
	cs.shape = bs
	sb.add_child(cs)
	pivot.add_child(sb)
	# Counter lip — slightly brighter slab on the customer side
	var lip: MeshInstance3D = MeshInstance3D.new()
	var lm: BoxMesh = BoxMesh.new()
	lm.size = Vector3(3.30, 0.10, 0.20)
	lip.mesh = lm
	lip.material_override = obs_mat
	lip.position = Vector3(0, 1.05, -0.55)
	pivot.add_child(lip)
	# Brass support poles (4 corners)
	var brass_mat: StandardMaterial3D = StandardMaterial3D.new()
	brass_mat.albedo_color = Color(0.85, 0.55, 0.18)
	brass_mat.metallic = 0.95
	brass_mat.roughness = 0.30
	brass_mat.emission_enabled = true
	brass_mat.emission = Color(1.0, 0.50, 0.10)
	brass_mat.emission_energy_multiplier = 0.45
	var pole_positions: Array = [
		Vector3(-1.55, 1.50, -0.50),
		Vector3(1.55, 1.50, -0.50),
		Vector3(-1.55, 1.50, 0.50),
		Vector3(1.55, 1.50, 0.50),
	]
	for pp in pole_positions:
		var pole: MeshInstance3D = MeshInstance3D.new()
		var pm: CylinderMesh = CylinderMesh.new()
		pm.top_radius = 0.05
		pm.bottom_radius = 0.06
		pm.height = 1.80
		pole.mesh = pm
		pole.material_override = brass_mat
		pole.position = pp
		pivot.add_child(pole)
	# Brass canopy beam (front)
	var beam_front: MeshInstance3D = MeshInstance3D.new()
	var bfm: BoxMesh = BoxMesh.new()
	bfm.size = Vector3(3.40, 0.12, 0.10)
	beam_front.mesh = bfm
	beam_front.material_override = brass_mat
	beam_front.position = Vector3(0, 2.40, -0.50)
	pivot.add_child(beam_front)
	# Canopy back beam
	var beam_back: MeshInstance3D = MeshInstance3D.new()
	beam_back.mesh = bfm
	beam_back.material_override = brass_mat
	beam_back.position = Vector3(0, 2.40, 0.50)
	pivot.add_child(beam_back)
	# Canopy cloth (red drape)
	var drape_mat: StandardMaterial3D = StandardMaterial3D.new()
	drape_mat.albedo_color = Color(0.55, 0.10, 0.08)
	drape_mat.roughness = 0.85
	drape_mat.emission_enabled = true
	drape_mat.emission = Color(0.65, 0.15, 0.05)
	drape_mat.emission_energy_multiplier = 0.30
	var drape: MeshInstance3D = MeshInstance3D.new()
	var dm: BoxMesh = BoxMesh.new()
	dm.size = Vector3(3.40, 0.06, 1.20)
	drape.mesh = dm
	drape.material_override = drape_mat
	drape.position = Vector3(0, 2.46, 0)
	pivot.add_child(drape)
	# 3 hanging amber lanterns under the canopy
	var lan_mat: StandardMaterial3D = StandardMaterial3D.new()
	lan_mat.albedo_color = Color(1.0, 0.55, 0.10)
	lan_mat.emission_enabled = true
	lan_mat.emission = Color(1.0, 0.55, 0.10)
	lan_mat.emission_energy_multiplier = 6.0
	lan_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for lx in [-1.10, 0.0, 1.10]:
		# Cord
		var cord: MeshInstance3D = MeshInstance3D.new()
		var crm: CylinderMesh = CylinderMesh.new()
		crm.top_radius = 0.012
		crm.bottom_radius = 0.012
		crm.height = 0.40
		cord.mesh = crm
		cord.material_override = brass_mat
		cord.position = Vector3(lx, 2.20, 0)
		pivot.add_child(cord)
		# Lantern bulb
		var lan: MeshInstance3D = MeshInstance3D.new()
		var lansm: SphereMesh = SphereMesh.new()
		lansm.radius = 0.13
		lansm.height = 0.26
		lan.mesh = lansm
		lan.material_override = lan_mat
		lan.position = Vector3(lx, 1.95, 0)
		pivot.add_child(lan)
		# Light source per lantern
		var lt: OmniLight3D = OmniLight3D.new()
		lt.position = Vector3(lx, 1.95, 0)
		lt.light_color = Color(1.0, 0.55, 0.15)
		lt.light_energy = 1.6
		lt.omni_range = 4.5
		pivot.add_child(lt)
	# 3 wares displayed on the counter — small unshaded forge trinkets
	var ware_mat: StandardMaterial3D = StandardMaterial3D.new()
	ware_mat.albedo_color = Color(1.0, 0.65, 0.20)
	ware_mat.emission_enabled = true
	ware_mat.emission = Color(1.0, 0.50, 0.10)
	ware_mat.emission_energy_multiplier = 5.0
	ware_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	# Ware 1 — small dagger (box)
	var w1: MeshInstance3D = MeshInstance3D.new()
	var w1m: BoxMesh = BoxMesh.new()
	w1m.size = Vector3(0.08, 0.08, 0.55)
	w1.mesh = w1m
	w1.material_override = ware_mat
	w1.position = Vector3(-1.05, 1.06, 0)
	pivot.add_child(w1)
	# Ware 2 — gem cluster (sphere)
	var w2: MeshInstance3D = MeshInstance3D.new()
	var w2m: SphereMesh = SphereMesh.new()
	w2m.radius = 0.14
	w2m.height = 0.28
	w2.mesh = w2m
	w2.material_override = ware_mat
	w2.position = Vector3(0, 1.18, 0)
	pivot.add_child(w2)
	# Ware 3 — torus ring
	var w3: MeshInstance3D = MeshInstance3D.new()
	var w3m: TorusMesh = TorusMesh.new()
	w3m.inner_radius = 0.10
	w3m.outer_radius = 0.18
	w3.mesh = w3m
	w3.material_override = ware_mat
	w3.position = Vector3(1.05, 1.06, 0)
	w3.rotation.x = PI / 2.0
	pivot.add_child(w3)
	# Spinning wares — slow rotation on the gem cluster and ring
	var spin: Tween = pivot.create_tween().set_loops()
	spin.tween_property(w2, "rotation:y", TAU, 6.0)
	var spin2: Tween = pivot.create_tween().set_loops()
	spin2.tween_property(w3, "rotation:z", TAU, 4.5)
	# Lantern pulse for ambience
	var lpulse: Tween = pivot.create_tween().set_loops()
	lpulse.tween_property(lan_mat, "emission_energy_multiplier", 7.5, 1.4).set_ease(Tween.EASE_IN_OUT)
	lpulse.tween_property(lan_mat, "emission_energy_multiplier", 5.0, 1.4).set_ease(Tween.EASE_IN_OUT)


func _build_d9_forge_guildhall(geom: Node) -> void:
	## Epic-9 T65: forge guildhall — a stone-and-brass building landmark
	## anchoring the cascade pool's western edge. Walls of dark basalt with
	## glowing window slits, brass roof trim, twin chimneys belching ember
	## smoke, an iron double-door, and a hammer-and-anvil guild crest above.
	var pivot: Node3D = Node3D.new()
	pivot.name = "D9_ForgeGuildhall"
	pivot.position = D9_CENTER + Vector3(38, 0.0, -16)
	geom.add_child(pivot)
	# Basalt wall material
	var wall_mat: StandardMaterial3D = StandardMaterial3D.new()
	wall_mat.albedo_color = Color(0.14, 0.11, 0.10)
	wall_mat.metallic = 0.20
	wall_mat.roughness = 0.85
	wall_mat.emission_enabled = true
	wall_mat.emission = Color(0.50, 0.18, 0.05)
	wall_mat.emission_energy_multiplier = 0.20
	# Main hall body
	var body: MeshInstance3D = MeshInstance3D.new()
	var bm: BoxMesh = BoxMesh.new()
	bm.size = Vector3(8.0, 5.0, 6.0)
	body.mesh = bm
	body.material_override = wall_mat
	body.position = Vector3(0, 2.50, 0)
	pivot.add_child(body)
	# Body collision
	var sb: StaticBody3D = StaticBody3D.new()
	sb.position = Vector3(0, 2.50, 0)
	var cs: CollisionShape3D = CollisionShape3D.new()
	var bs: BoxShape3D = BoxShape3D.new()
	bs.size = Vector3(8.0, 5.0, 6.0)
	cs.shape = bs
	sb.add_child(cs)
	pivot.add_child(sb)
	# Brass trim material
	var brass_mat: StandardMaterial3D = StandardMaterial3D.new()
	brass_mat.albedo_color = Color(0.85, 0.55, 0.18)
	brass_mat.metallic = 0.95
	brass_mat.roughness = 0.30
	brass_mat.emission_enabled = true
	brass_mat.emission = Color(1.0, 0.50, 0.10)
	brass_mat.emission_energy_multiplier = 0.55
	# Roof trim — flat slab
	var roof: MeshInstance3D = MeshInstance3D.new()
	var rm: BoxMesh = BoxMesh.new()
	rm.size = Vector3(8.40, 0.40, 6.40)
	roof.mesh = rm
	roof.material_override = brass_mat
	roof.position = Vector3(0, 5.20, 0)
	pivot.add_child(roof)
	# Roof crest peak (prism)
	var crest_peak: MeshInstance3D = MeshInstance3D.new()
	var cpm: PrismMesh = PrismMesh.new()
	cpm.size = Vector3(8.0, 1.20, 6.0)
	crest_peak.mesh = cpm
	crest_peak.material_override = wall_mat
	crest_peak.position = Vector3(0, 6.00, 0)
	pivot.add_child(crest_peak)
	# 4 glowing window slits along the front
	var win_mat: StandardMaterial3D = StandardMaterial3D.new()
	win_mat.albedo_color = Color(1.0, 0.55, 0.10)
	win_mat.emission_enabled = true
	win_mat.emission = Color(1.0, 0.55, 0.10)
	win_mat.emission_energy_multiplier = 6.0
	win_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for wx in [-2.80, -1.20, 1.20, 2.80]:
		var win: MeshInstance3D = MeshInstance3D.new()
		var wm: BoxMesh = BoxMesh.new()
		wm.size = Vector3(0.40, 1.40, 0.10)
		win.mesh = wm
		win.material_override = win_mat
		win.position = Vector3(wx, 3.00, -3.05)
		pivot.add_child(win)
	# Iron double doors
	var door_mat: StandardMaterial3D = StandardMaterial3D.new()
	door_mat.albedo_color = Color(0.16, 0.13, 0.11)
	door_mat.metallic = 0.85
	door_mat.roughness = 0.40
	door_mat.emission_enabled = true
	door_mat.emission = Color(0.65, 0.20, 0.05)
	door_mat.emission_energy_multiplier = 0.30
	for dx in [-0.40, 0.40]:
		var door: MeshInstance3D = MeshInstance3D.new()
		var dmesh: BoxMesh = BoxMesh.new()
		dmesh.size = Vector3(0.78, 2.40, 0.18)
		door.mesh = dmesh
		door.material_override = door_mat
		door.position = Vector3(dx, 1.20, -3.05)
		pivot.add_child(door)
	# Door brass studs
	for sx in [-0.65, -0.15, 0.15, 0.65]:
		for sy in [0.50, 1.20, 1.90]:
			var stud: MeshInstance3D = MeshInstance3D.new()
			var stm: SphereMesh = SphereMesh.new()
			stm.radius = 0.06
			stm.height = 0.12
			stud.mesh = stm
			stud.material_override = brass_mat
			stud.position = Vector3(sx, sy, -3.10)
			pivot.add_child(stud)
	# Twin chimneys
	for cxx in [-2.50, 2.50]:
		var chim: MeshInstance3D = MeshInstance3D.new()
		var chm: BoxMesh = BoxMesh.new()
		chm.size = Vector3(1.10, 2.40, 1.10)
		chim.mesh = chm
		chim.material_override = wall_mat
		chim.position = Vector3(cxx, 7.00, 0)
		pivot.add_child(chim)
		# Chimney brass cap
		var cap: MeshInstance3D = MeshInstance3D.new()
		var capm: BoxMesh = BoxMesh.new()
		capm.size = Vector3(1.30, 0.18, 1.30)
		cap.mesh = capm
		cap.material_override = brass_mat
		cap.position = Vector3(cxx, 8.30, 0)
		pivot.add_child(cap)
		# Ember smoke particles
		var smoke: GPUParticles3D = GPUParticles3D.new()
		smoke.position = Vector3(cxx, 8.50, 0)
		smoke.amount = 24
		smoke.lifetime = 3.0
		var pmat: ParticleProcessMaterial = ParticleProcessMaterial.new()
		pmat.direction = Vector3(0, 1, 0)
		pmat.spread = 12.0
		pmat.initial_velocity_min = 0.6
		pmat.initial_velocity_max = 1.2
		pmat.gravity = Vector3(0, 0.4, 0)
		pmat.scale_min = 0.18
		pmat.scale_max = 0.35
		pmat.color = Color(1.0, 0.45, 0.10, 0.85)
		smoke.process_material = pmat
		var psmesh: SphereMesh = SphereMesh.new()
		psmesh.radius = 0.10
		psmesh.height = 0.20
		smoke.draw_pass_1 = psmesh
		pivot.add_child(smoke)
	# Hammer-and-anvil guild crest above the doors
	# Anvil base
	var anvil: MeshInstance3D = MeshInstance3D.new()
	var anm: BoxMesh = BoxMesh.new()
	anm.size = Vector3(0.90, 0.30, 0.30)
	anvil.mesh = anm
	anvil.material_override = brass_mat
	anvil.position = Vector3(0, 4.20, -3.10)
	pivot.add_child(anvil)
	# Anvil horn (small box on the side)
	var horn: MeshInstance3D = MeshInstance3D.new()
	var hnm: BoxMesh = BoxMesh.new()
	hnm.size = Vector3(0.30, 0.18, 0.30)
	horn.mesh = hnm
	horn.material_override = brass_mat
	horn.position = Vector3(0.50, 4.30, -3.10)
	pivot.add_child(horn)
	# Hammer head crossing the anvil
	var hamhead: MeshInstance3D = MeshInstance3D.new()
	var hhm: BoxMesh = BoxMesh.new()
	hhm.size = Vector3(0.50, 0.22, 0.30)
	hamhead.mesh = hhm
	hamhead.material_override = brass_mat
	hamhead.position = Vector3(-0.20, 4.55, -3.10)
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
	hamhandle.position = Vector3(0.20, 4.95, -3.10)
	hamhandle.rotation.z = PI / 8.0
	pivot.add_child(hamhandle)
	# Two flanking torches at the door
	var torch_mat: StandardMaterial3D = StandardMaterial3D.new()
	torch_mat.albedo_color = Color(1.0, 0.65, 0.20)
	torch_mat.emission_enabled = true
	torch_mat.emission = Color(1.0, 0.55, 0.10)
	torch_mat.emission_energy_multiplier = 8.0
	torch_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for tx in [-1.40, 1.40]:
		# Bracket
		var bkt: MeshInstance3D = MeshInstance3D.new()
		var bktm: CylinderMesh = CylinderMesh.new()
		bktm.top_radius = 0.05
		bktm.bottom_radius = 0.05
		bktm.height = 0.40
		bkt.mesh = bktm
		bkt.material_override = brass_mat
		bkt.position = Vector3(tx, 2.40, -3.20)
		bkt.rotation.x = PI / 2.0
		pivot.add_child(bkt)
		# Flame ball
		var flame: MeshInstance3D = MeshInstance3D.new()
		var flm: SphereMesh = SphereMesh.new()
		flm.radius = 0.20
		flm.height = 0.40
		flame.mesh = flm
		flame.material_override = torch_mat
		flame.position = Vector3(tx, 2.65, -3.30)
		pivot.add_child(flame)
		# Light
		var lt: OmniLight3D = OmniLight3D.new()
		lt.position = Vector3(tx, 2.65, -3.30)
		lt.light_color = Color(1.0, 0.55, 0.15)
		lt.light_energy = 3.0
		lt.omni_range = 7.0
		pivot.add_child(lt)
	# Window pulse animation
	var winpulse: Tween = pivot.create_tween().set_loops()
	winpulse.tween_property(win_mat, "emission_energy_multiplier", 8.0, 1.8).set_ease(Tween.EASE_IN_OUT)
	winpulse.tween_property(win_mat, "emission_energy_multiplier", 5.0, 1.8).set_ease(Tween.EASE_IN_OUT)
	# Torch flicker
	var flick: Tween = pivot.create_tween().set_loops()
	flick.tween_property(torch_mat, "emission_energy_multiplier", 10.0, 0.35).set_ease(Tween.EASE_IN_OUT)
	flick.tween_property(torch_mat, "emission_energy_multiplier", 7.0, 0.35).set_ease(Tween.EASE_IN_OUT)


func _build_d9_guildmaster_vorn_npc(town: Node) -> void:
	## Epic-9 T66: Guildmaster Vorn — proud, decorated NPC standing at the
	## forge guildhall front doors. Brass-trimmed leather robe, ceremonial
	## guild medallion, two-handed warhammer planted at his side, and a
	## brazier helm with rising ember motes.
	var slots: Node3D = town.get_node_or_null("NPCSlots") as Node3D
	if slots == null:
		return
	var slot: Marker3D = Marker3D.new()
	slot.name = "D9GuildmasterVornSlot"
	# Stand just in front of the guildhall doors (guildhall at +38, -16; doors face -Z)
	slot.position = Vector3(D9_CENTER.x + 38, 0, -20)
	slots.add_child(slot)
	var npc_scene: PackedScene = load("res://scenes/entities/npcs/VillagerR3.tscn") as PackedScene
	if npc_scene == null:
		return
	var npc: Node3D = npc_scene.instantiate() as Node3D
	npc.name = "D9GuildmasterVorn"
	if "npc_name" in npc:
		npc.set("npc_name", "Guildmaster Vorn")
	if "npc_id" in npc:
		npc.set("npc_id", "d9_guildmaster_vorn")
	slot.add_child(npc)
	# Leather robe — wide chest box
	var robe_mat: StandardMaterial3D = StandardMaterial3D.new()
	robe_mat.albedo_color = Color(0.18, 0.10, 0.08)
	robe_mat.roughness = 0.80
	robe_mat.metallic = 0.15
	robe_mat.emission_enabled = true
	robe_mat.emission = Color(0.55, 0.18, 0.05)
	robe_mat.emission_energy_multiplier = 0.18
	var robe: MeshInstance3D = MeshInstance3D.new()
	var rb: BoxMesh = BoxMesh.new()
	rb.size = Vector3(1.10, 1.40, 0.65)
	robe.mesh = rb
	robe.material_override = robe_mat
	robe.position = Vector3(0, 1.05, 0)
	npc.add_child(robe)
	# Brass robe trim — vertical strip down the chest
	var brass_mat: StandardMaterial3D = StandardMaterial3D.new()
	brass_mat.albedo_color = Color(0.85, 0.55, 0.18)
	brass_mat.metallic = 0.95
	brass_mat.roughness = 0.30
	brass_mat.emission_enabled = true
	brass_mat.emission = Color(1.0, 0.50, 0.10)
	brass_mat.emission_energy_multiplier = 1.0
	var trim: MeshInstance3D = MeshInstance3D.new()
	var tm: BoxMesh = BoxMesh.new()
	tm.size = Vector3(0.18, 1.30, 0.06)
	trim.mesh = tm
	trim.material_override = brass_mat
	trim.position = Vector3(0, 1.05, -0.34)
	npc.add_child(trim)
	# Brass shoulder pauldrons
	for sx in [-0.62, 0.62]:
		var paul: MeshInstance3D = MeshInstance3D.new()
		var pm: SphereMesh = SphereMesh.new()
		pm.radius = 0.22
		pm.height = 0.44
		paul.mesh = pm
		paul.material_override = brass_mat
		paul.position = Vector3(sx, 1.65, 0)
		paul.scale = Vector3(1.0, 0.55, 1.0)
		npc.add_child(paul)
	# Guild medallion — glowing torus on chest
	var med_mat: StandardMaterial3D = StandardMaterial3D.new()
	med_mat.albedo_color = Color(1.0, 0.65, 0.20)
	med_mat.emission_enabled = true
	med_mat.emission = Color(1.0, 0.50, 0.10)
	med_mat.emission_energy_multiplier = 5.5
	med_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var medallion: MeshInstance3D = MeshInstance3D.new()
	var medm: TorusMesh = TorusMesh.new()
	medm.inner_radius = 0.10
	medm.outer_radius = 0.18
	medallion.mesh = medm
	medallion.material_override = med_mat
	medallion.position = Vector3(0, 1.55, -0.36)
	medallion.rotation.x = PI / 2.0
	npc.add_child(medallion)
	# Brazier helm — wide bowl on the head
	var helm: MeshInstance3D = MeshInstance3D.new()
	var hmm: SphereMesh = SphereMesh.new()
	hmm.radius = 0.35
	hmm.height = 0.65
	helm.mesh = hmm
	helm.material_override = brass_mat
	helm.position = Vector3(0, 1.95, 0)
	helm.scale = Vector3(1.0, 0.70, 1.0)
	npc.add_child(helm)
	# Helm crown rim — torus
	var rim: MeshInstance3D = MeshInstance3D.new()
	var rmm: TorusMesh = TorusMesh.new()
	rmm.inner_radius = 0.30
	rmm.outer_radius = 0.40
	rim.mesh = rmm
	rim.material_override = brass_mat
	rim.position = Vector3(0, 1.92, 0)
	rim.rotation.x = PI / 2.0
	npc.add_child(rim)
	# Ember motes rising from the helm bowl
	var motes: GPUParticles3D = GPUParticles3D.new()
	motes.position = Vector3(0, 2.15, 0)
	motes.amount = 16
	motes.lifetime = 2.0
	var pmat: ParticleProcessMaterial = ParticleProcessMaterial.new()
	pmat.direction = Vector3(0, 1, 0)
	pmat.spread = 14.0
	pmat.initial_velocity_min = 0.5
	pmat.initial_velocity_max = 1.0
	pmat.gravity = Vector3(0, 0.3, 0)
	pmat.scale_min = 0.05
	pmat.scale_max = 0.10
	pmat.color = Color(1.0, 0.55, 0.10, 1.0)
	motes.process_material = pmat
	var psmesh: SphereMesh = SphereMesh.new()
	psmesh.radius = 0.04
	psmesh.height = 0.08
	motes.draw_pass_1 = psmesh
	npc.add_child(motes)
	# Two-handed warhammer planted at his side — long shaft + massive head
	var iron_mat: StandardMaterial3D = StandardMaterial3D.new()
	iron_mat.albedo_color = Color(0.18, 0.14, 0.11)
	iron_mat.metallic = 0.85
	iron_mat.roughness = 0.40
	iron_mat.emission_enabled = true
	iron_mat.emission = Color(1.0, 0.30, 0.05)
	iron_mat.emission_energy_multiplier = 0.50
	var wood_mat: StandardMaterial3D = StandardMaterial3D.new()
	wood_mat.albedo_color = Color(0.32, 0.20, 0.12)
	wood_mat.roughness = 0.80
	var shaft: MeshInstance3D = MeshInstance3D.new()
	var shm: CylinderMesh = CylinderMesh.new()
	shm.top_radius = 0.07
	shm.bottom_radius = 0.08
	shm.height = 1.85
	shaft.mesh = shm
	shaft.material_override = wood_mat
	shaft.position = Vector3(0.62, 0.95, 0)
	npc.add_child(shaft)
	# Hammer head — chunky double-faced box
	var head: MeshInstance3D = MeshInstance3D.new()
	var headm: BoxMesh = BoxMesh.new()
	headm.size = Vector3(0.45, 0.40, 0.55)
	head.mesh = headm
	head.material_override = iron_mat
	head.position = Vector3(0.62, 1.95, 0)
	npc.add_child(head)
	# Hammer head brass cap
	for capz in [-0.30, 0.30]:
		var cap: MeshInstance3D = MeshInstance3D.new()
		var capm: BoxMesh = BoxMesh.new()
		capm.size = Vector3(0.50, 0.45, 0.06)
		cap.mesh = capm
		cap.material_override = brass_mat
		cap.position = Vector3(0.62, 1.95, capz)
		npc.add_child(cap)
	# Helm warm glow OmniLight
	var lt: OmniLight3D = OmniLight3D.new()
	lt.position = Vector3(0, 2.20, 0)
	lt.light_color = Color(1.0, 0.55, 0.15)
	lt.light_energy = 2.4
	lt.omni_range = 5.5
	npc.add_child(lt)
	# Medallion pulse
	var med_pulse: Tween = npc.create_tween().set_loops()
	med_pulse.tween_property(med_mat, "emission_energy_multiplier", 7.5, 1.6).set_ease(Tween.EASE_IN_OUT)
	med_pulse.tween_property(med_mat, "emission_energy_multiplier", 4.0, 1.6).set_ease(Tween.EASE_IN_OUT)


func _build_d9_guildhall_banners(geom: Node) -> void:
	## Epic-9 T67: tall ceremonial banner pair flanking the forge guildhall
	## doorway. Each banner: brass pole, brass crown finial with a glowing
	## ember orb, long red drape with a gold guild stripe, and a slow
	## wind sway. Frames Guildmaster Vorn and the guildhall entrance.
	var pivot: Node3D = Node3D.new()
	pivot.name = "D9_GuildhallBanners"
	pivot.position = D9_CENTER + Vector3(38, 0.0, -19)
	geom.add_child(pivot)
	# Shared materials
	var brass_mat: StandardMaterial3D = StandardMaterial3D.new()
	brass_mat.albedo_color = Color(0.85, 0.55, 0.18)
	brass_mat.metallic = 0.95
	brass_mat.roughness = 0.30
	brass_mat.emission_enabled = true
	brass_mat.emission = Color(1.0, 0.50, 0.10)
	brass_mat.emission_energy_multiplier = 0.55
	var drape_mat: StandardMaterial3D = StandardMaterial3D.new()
	drape_mat.albedo_color = Color(0.55, 0.10, 0.08)
	drape_mat.roughness = 0.85
	drape_mat.emission_enabled = true
	drape_mat.emission = Color(0.65, 0.15, 0.05)
	drape_mat.emission_energy_multiplier = 0.40
	var stripe_mat: StandardMaterial3D = StandardMaterial3D.new()
	stripe_mat.albedo_color = Color(1.0, 0.65, 0.20)
	stripe_mat.emission_enabled = true
	stripe_mat.emission = Color(1.0, 0.55, 0.10)
	stripe_mat.emission_energy_multiplier = 3.5
	stripe_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var ember_mat: StandardMaterial3D = StandardMaterial3D.new()
	ember_mat.albedo_color = Color(1.0, 0.55, 0.10)
	ember_mat.emission_enabled = true
	ember_mat.emission = Color(1.0, 0.55, 0.10)
	ember_mat.emission_energy_multiplier = 8.0
	ember_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	# Build a banner at +/- offset
	for bx in [-2.20, 2.20]:
		var bgroup: Node3D = Node3D.new()
		bgroup.name = "Banner_" + str(int(bx))
		bgroup.position = Vector3(bx, 0, 0)
		pivot.add_child(bgroup)
		# Pole
		var pole: MeshInstance3D = MeshInstance3D.new()
		var pm: CylinderMesh = CylinderMesh.new()
		pm.top_radius = 0.06
		pm.bottom_radius = 0.08
		pm.height = 4.50
		pole.mesh = pm
		pole.material_override = brass_mat
		pole.position = Vector3(0, 2.25, 0)
		bgroup.add_child(pole)
		# Pole base — brass disc
		var base: MeshInstance3D = MeshInstance3D.new()
		var basm: CylinderMesh = CylinderMesh.new()
		basm.top_radius = 0.22
		basm.bottom_radius = 0.28
		basm.height = 0.18
		base.mesh = basm
		base.material_override = brass_mat
		base.position = Vector3(0, 0.09, 0)
		bgroup.add_child(base)
		# Crown finial — small inverted prism + sphere ember
		var finial: MeshInstance3D = MeshInstance3D.new()
		var fm: PrismMesh = PrismMesh.new()
		fm.size = Vector3(0.30, 0.40, 0.30)
		finial.mesh = fm
		finial.material_override = brass_mat
		finial.position = Vector3(0, 4.60, 0)
		bgroup.add_child(finial)
		# Ember orb at the very top
		var ember: MeshInstance3D = MeshInstance3D.new()
		var em: SphereMesh = SphereMesh.new()
		em.radius = 0.14
		em.height = 0.28
		ember.mesh = em
		ember.material_override = ember_mat
		ember.position = Vector3(0, 5.00, 0)
		bgroup.add_child(ember)
		# Ember OmniLight
		var lt: OmniLight3D = OmniLight3D.new()
		lt.position = Vector3(0, 5.00, 0)
		lt.light_color = Color(1.0, 0.55, 0.15)
		lt.light_energy = 2.0
		lt.omni_range = 5.0
		bgroup.add_child(lt)
		# Cross-arm holding the drape (small horizontal bar at top)
		var arm: MeshInstance3D = MeshInstance3D.new()
		var arm_m: CylinderMesh = CylinderMesh.new()
		arm_m.top_radius = 0.04
		arm_m.bottom_radius = 0.04
		arm_m.height = 1.10
		arm.mesh = arm_m
		arm.material_override = brass_mat
		arm.position = Vector3(0, 4.20, 0)
		arm.rotation.z = PI / 2.0
		bgroup.add_child(arm)
		# Long red drape hanging from the cross-arm — pivot at top so sway looks right
		var drape_pivot: Node3D = Node3D.new()
		drape_pivot.position = Vector3(0, 4.20, 0)
		bgroup.add_child(drape_pivot)
		var drape: MeshInstance3D = MeshInstance3D.new()
		var dmesh: BoxMesh = BoxMesh.new()
		dmesh.size = Vector3(1.05, 2.40, 0.04)
		drape.mesh = dmesh
		drape.material_override = drape_mat
		drape.position = Vector3(0, -1.20, 0)
		drape_pivot.add_child(drape)
		# Gold guild stripe down the center of the drape
		var stripe: MeshInstance3D = MeshInstance3D.new()
		var smm: BoxMesh = BoxMesh.new()
		smm.size = Vector3(0.18, 2.30, 0.06)
		stripe.mesh = smm
		stripe.material_override = stripe_mat
		stripe.position = Vector3(0, -1.20, -0.05)
		drape_pivot.add_child(stripe)
		# Guild crest — small unshaded torus on the stripe
		var crest: MeshInstance3D = MeshInstance3D.new()
		var ctm: TorusMesh = TorusMesh.new()
		ctm.inner_radius = 0.10
		ctm.outer_radius = 0.18
		crest.mesh = ctm
		crest.material_override = ember_mat
		crest.position = Vector3(0, -1.40, -0.08)
		crest.rotation.x = PI / 2.0
		drape_pivot.add_child(crest)
		# Drape sway tween — small rotation around Z
		var sway: Tween = drape_pivot.create_tween().set_loops()
		sway.tween_property(drape_pivot, "rotation:z", 0.08, 1.6).set_ease(Tween.EASE_IN_OUT)
		sway.tween_property(drape_pivot, "rotation:z", -0.08, 1.6).set_ease(Tween.EASE_IN_OUT)
		# Ember pulse
		var epulse: Tween = bgroup.create_tween().set_loops()
		epulse.tween_property(ember_mat, "emission_energy_multiplier", 10.0, 1.3).set_ease(Tween.EASE_IN_OUT)
		epulse.tween_property(ember_mat, "emission_energy_multiplier", 6.0, 1.3).set_ease(Tween.EASE_IN_OUT)


func _build_d9_guildhall_approach_path(geom: Node) -> void:
	## Epic-9 T68: basalt slab walkway connecting the cascade pool area to
	## the guildhall doors. 8 large basalt tiles with glowing magma seams
	## between them, plus 4 small ember braziers along the sides. Establishes
	## wayfinding and ties the new building to the rest of the cascade zone.
	var pivot: Node3D = Node3D.new()
	pivot.name = "D9_GuildhallApproachPath"
	# Path runs from the obsidian merchant stall (~46, -8) toward the
	# guildhall doors (~38, -19), so anchor partway along the line
	pivot.position = D9_CENTER + Vector3(42, 0.02, -13)
	geom.add_child(pivot)
	# Basalt slab material
	var slab_mat: StandardMaterial3D = StandardMaterial3D.new()
	slab_mat.albedo_color = Color(0.10, 0.08, 0.07)
	slab_mat.metallic = 0.18
	slab_mat.roughness = 0.85
	slab_mat.emission_enabled = true
	slab_mat.emission = Color(0.35, 0.12, 0.04)
	slab_mat.emission_energy_multiplier = 0.18
	# Magma seam material — bright unshaded amber
	var seam_mat: StandardMaterial3D = StandardMaterial3D.new()
	seam_mat.albedo_color = Color(1.0, 0.55, 0.10)
	seam_mat.emission_enabled = true
	seam_mat.emission = Color(1.0, 0.55, 0.10)
	seam_mat.emission_energy_multiplier = 4.5
	seam_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	# 8 slabs laid along a diagonal toward the guildhall (-X, -Z direction)
	# Each step: -1.0 X, -1.5 Z
	for i in 8:
		var sx: float = float(i) * -1.0
		var sz: float = float(i) * -1.5
		# Slab
		var slab: MeshInstance3D = MeshInstance3D.new()
		var sm: BoxMesh = BoxMesh.new()
		sm.size = Vector3(2.40, 0.18, 1.60)
		slab.mesh = sm
		slab.material_override = slab_mat
		slab.position = Vector3(sx, 0.09, sz)
		# Slight Y rotation to align with diagonal direction
		slab.rotation.y = atan2(-1.0, -1.5)
		pivot.add_child(slab)
		# Glowing seam line embedded in the slab
		var seam: MeshInstance3D = MeshInstance3D.new()
		var seamesh: BoxMesh = BoxMesh.new()
		seamesh.size = Vector3(2.20, 0.05, 0.10)
		seam.mesh = seamesh
		seam.material_override = seam_mat
		seam.position = Vector3(sx, 0.20, sz)
		seam.rotation.y = atan2(-1.0, -1.5)
		pivot.add_child(seam)
	# 4 small ember braziers along the path sides (alternating L/R)
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
	var brazier_positions: Array = [
		Vector3(0.5, 0, -0.0),
		Vector3(-2.5, 0, -3.0),
		Vector3(-4.5, 0, -6.0),
		Vector3(-6.5, 0, -9.0),
	]
	var side_offsets: Array = [Vector3(1.4, 0, -0.9), Vector3(-1.4, 0, 0.9), Vector3(1.4, 0, -0.9), Vector3(-1.4, 0, 0.9)]
	for i in 4:
		var bp: Vector3 = brazier_positions[i] + side_offsets[i]
		# Brazier post
		var post: MeshInstance3D = MeshInstance3D.new()
		var pm: CylinderMesh = CylinderMesh.new()
		pm.top_radius = 0.10
		pm.bottom_radius = 0.14
		pm.height = 0.85
		post.mesh = pm
		post.material_override = brass_mat
		post.position = bp + Vector3(0, 0.42, 0)
		pivot.add_child(post)
		# Brazier bowl
		var bowl: MeshInstance3D = MeshInstance3D.new()
		var bowm: SphereMesh = SphereMesh.new()
		bowm.radius = 0.20
		bowm.height = 0.35
		bowl.mesh = bowm
		bowl.material_override = brass_mat
		bowl.position = bp + Vector3(0, 0.92, 0)
		bowl.scale = Vector3(1.0, 0.55, 1.0)
		pivot.add_child(bowl)
		# Flame
		var flame: MeshInstance3D = MeshInstance3D.new()
		var flm: SphereMesh = SphereMesh.new()
		flm.radius = 0.16
		flm.height = 0.32
		flame.mesh = flm
		flame.material_override = flame_mat
		flame.position = bp + Vector3(0, 1.10, 0)
		pivot.add_child(flame)
		# OmniLight
		var lt: OmniLight3D = OmniLight3D.new()
		lt.position = bp + Vector3(0, 1.10, 0)
		lt.light_color = Color(1.0, 0.55, 0.15)
		lt.light_energy = 1.8
		lt.omni_range = 5.0
		pivot.add_child(lt)
		# Ember motes rising from each brazier
		var motes: GPUParticles3D = GPUParticles3D.new()
		motes.position = bp + Vector3(0, 1.20, 0)
		motes.amount = 12
		motes.lifetime = 1.8
		var pmat: ParticleProcessMaterial = ParticleProcessMaterial.new()
		pmat.direction = Vector3(0, 1, 0)
		pmat.spread = 12.0
		pmat.initial_velocity_min = 0.4
		pmat.initial_velocity_max = 0.8
		pmat.gravity = Vector3(0, 0.3, 0)
		pmat.scale_min = 0.04
		pmat.scale_max = 0.08
		pmat.color = Color(1.0, 0.55, 0.10, 1.0)
		motes.process_material = pmat
		var psmesh: SphereMesh = SphereMesh.new()
		psmesh.radius = 0.03
		psmesh.height = 0.06
		motes.draw_pass_1 = psmesh
		pivot.add_child(motes)
	# Seam pulse — slowly breathe magma color along the whole path
	var seam_pulse: Tween = pivot.create_tween().set_loops()
	seam_pulse.tween_property(seam_mat, "emission_energy_multiplier", 6.0, 2.2).set_ease(Tween.EASE_IN_OUT)
	seam_pulse.tween_property(seam_mat, "emission_energy_multiplier", 3.5, 2.2).set_ease(Tween.EASE_IN_OUT)
	# Brazier flicker
	var fpulse: Tween = pivot.create_tween().set_loops()
	fpulse.tween_property(flame_mat, "emission_energy_multiplier", 10.0, 0.4).set_ease(Tween.EASE_IN_OUT)
	fpulse.tween_property(flame_mat, "emission_energy_multiplier", 7.0, 0.4).set_ease(Tween.EASE_IN_OUT)


func _build_d9_guildhall_training_yard(geom: Node) -> void:
	## Epic-9 T69: small fenced training yard tucked beside the forge
	## guildhall. Iron post-and-rail fence enclosing a sand pit, a weapon
	## rack with 4 unshaded amber weapons, a wooden sparring dummy with a
	## glowing chest core, and a brass corner brazier. Deepens the guild
	## quarter without needing interior geometry.
	var pivot: Node3D = Node3D.new()
	pivot.name = "D9_GuildhallTrainingYard"
	# Yard sits to the east side of the guildhall (guildhall at +38, -16; yard +46, -18)
	pivot.position = D9_CENTER + Vector3(46, 0.0, -18)
	geom.add_child(pivot)
	# ---- Yard footprint: ~5.5 x 5.5 ----
	# Sand pit floor — slightly raised dusty tan slab
	var sand_mat: StandardMaterial3D = StandardMaterial3D.new()
	sand_mat.albedo_color = Color(0.42, 0.30, 0.18)
	sand_mat.roughness = 0.95
	sand_mat.emission_enabled = true
	sand_mat.emission = Color(0.55, 0.25, 0.05)
	sand_mat.emission_energy_multiplier = 0.20
	var sand: MeshInstance3D = MeshInstance3D.new()
	var sm: BoxMesh = BoxMesh.new()
	sm.size = Vector3(5.40, 0.10, 5.40)
	sand.mesh = sm
	sand.material_override = sand_mat
	sand.position = Vector3(0, 0.05, 0)
	pivot.add_child(sand)
	# ---- Iron post-and-rail fence (6 posts + 4 rails) ----
	var iron_mat: StandardMaterial3D = StandardMaterial3D.new()
	iron_mat.albedo_color = Color(0.18, 0.14, 0.11)
	iron_mat.metallic = 0.85
	iron_mat.roughness = 0.40
	iron_mat.emission_enabled = true
	iron_mat.emission = Color(0.85, 0.25, 0.05)
	iron_mat.emission_energy_multiplier = 0.40
	# 4 corner posts + 2 mid posts on the open (front) side
	var post_positions: Array = [
		Vector3(-2.70, 0, -2.70),
		Vector3(2.70, 0, -2.70),
		Vector3(-2.70, 0, 2.70),
		Vector3(2.70, 0, 2.70),
		Vector3(0.0, 0, 2.70),
		Vector3(-2.70, 0, 0.0),
	]
	for pp in post_positions:
		var post: MeshInstance3D = MeshInstance3D.new()
		var pm: CylinderMesh = CylinderMesh.new()
		pm.top_radius = 0.07
		pm.bottom_radius = 0.09
		pm.height = 1.10
		post.mesh = pm
		post.material_override = iron_mat
		post.position = pp + Vector3(0, 0.55, 0)
		pivot.add_child(post)
		# Brass post cap
		var cap: MeshInstance3D = MeshInstance3D.new()
		var cm: SphereMesh = SphereMesh.new()
		cm.radius = 0.09
		cm.height = 0.18
		cap.mesh = cm
		var brass_mat: StandardMaterial3D = StandardMaterial3D.new()
		brass_mat.albedo_color = Color(0.85, 0.55, 0.18)
		brass_mat.metallic = 0.95
		brass_mat.roughness = 0.30
		brass_mat.emission_enabled = true
		brass_mat.emission = Color(1.0, 0.50, 0.10)
		brass_mat.emission_energy_multiplier = 0.55
		cap.material_override = brass_mat
		cap.position = pp + Vector3(0, 1.18, 0)
		pivot.add_child(cap)
	# Top rails — back, left, right (front is open as the yard entry)
	var rail_specs: Array = [
		# back rail
		{"size": Vector3(5.50, 0.08, 0.08), "pos": Vector3(0, 0.85, -2.70)},
		# left rail
		{"size": Vector3(0.08, 0.08, 5.50), "pos": Vector3(-2.70, 0.85, 0)},
		# right rail
		{"size": Vector3(0.08, 0.08, 5.50), "pos": Vector3(2.70, 0.85, 0)},
		# front partial rails (one on each side, with a gap in the middle)
		{"size": Vector3(2.20, 0.08, 0.08), "pos": Vector3(-1.65, 0.85, 2.70)},
		{"size": Vector3(2.20, 0.08, 0.08), "pos": Vector3(1.65, 0.85, 2.70)},
	]
	for rs in rail_specs:
		var rail: MeshInstance3D = MeshInstance3D.new()
		var rm: BoxMesh = BoxMesh.new()
		rm.size = rs["size"]
		rail.mesh = rm
		rail.material_override = iron_mat
		rail.position = rs["pos"]
		pivot.add_child(rail)
	# ---- Weapon rack along the back wall ----
	var wood_mat: StandardMaterial3D = StandardMaterial3D.new()
	wood_mat.albedo_color = Color(0.32, 0.20, 0.12)
	wood_mat.roughness = 0.80
	# Rack base
	var rack_base: MeshInstance3D = MeshInstance3D.new()
	var rbm: BoxMesh = BoxMesh.new()
	rbm.size = Vector3(2.40, 0.18, 0.40)
	rack_base.mesh = rbm
	rack_base.material_override = wood_mat
	rack_base.position = Vector3(0, 0.20, -2.40)
	pivot.add_child(rack_base)
	# Rack back vertical board
	var rack_back: MeshInstance3D = MeshInstance3D.new()
	var rbk: BoxMesh = BoxMesh.new()
	rbk.size = Vector3(2.40, 1.10, 0.06)
	rack_back.mesh = rbk
	rack_back.material_override = wood_mat
	rack_back.position = Vector3(0, 0.85, -2.55)
	pivot.add_child(rack_back)
	# 4 unshaded amber weapons hanging on the rack
	var weapon_mat: StandardMaterial3D = StandardMaterial3D.new()
	weapon_mat.albedo_color = Color(1.0, 0.65, 0.20)
	weapon_mat.emission_enabled = true
	weapon_mat.emission = Color(1.0, 0.50, 0.10)
	weapon_mat.emission_energy_multiplier = 5.0
	weapon_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	# Sword 1 — long box
	var w1: MeshInstance3D = MeshInstance3D.new()
	var w1m: BoxMesh = BoxMesh.new()
	w1m.size = Vector3(0.10, 1.05, 0.06)
	w1.mesh = w1m
	w1.material_override = weapon_mat
	w1.position = Vector3(-0.85, 0.95, -2.50)
	pivot.add_child(w1)
	# Spear — long thin cylinder
	var w2: MeshInstance3D = MeshInstance3D.new()
	var w2m: CylinderMesh = CylinderMesh.new()
	w2m.top_radius = 0.04
	w2m.bottom_radius = 0.04
	w2m.height = 1.20
	w2.mesh = w2m
	w2.material_override = weapon_mat
	w2.position = Vector3(-0.30, 0.90, -2.50)
	pivot.add_child(w2)
	# Mace — short shaft + sphere head
	var w3_shaft: MeshInstance3D = MeshInstance3D.new()
	var w3sm: CylinderMesh = CylinderMesh.new()
	w3sm.top_radius = 0.04
	w3sm.bottom_radius = 0.05
	w3sm.height = 0.85
	w3_shaft.mesh = w3sm
	w3_shaft.material_override = weapon_mat
	w3_shaft.position = Vector3(0.30, 0.80, -2.50)
	pivot.add_child(w3_shaft)
	var w3_head: MeshInstance3D = MeshInstance3D.new()
	var w3hm: SphereMesh = SphereMesh.new()
	w3hm.radius = 0.12
	w3hm.height = 0.24
	w3_head.mesh = w3hm
	w3_head.material_override = weapon_mat
	w3_head.position = Vector3(0.30, 1.30, -2.50)
	pivot.add_child(w3_head)
	# Axe — short box for handle + prism for blade
	var w4_h: MeshInstance3D = MeshInstance3D.new()
	var w4hm: CylinderMesh = CylinderMesh.new()
	w4hm.top_radius = 0.04
	w4hm.bottom_radius = 0.05
	w4hm.height = 0.95
	w4_h.mesh = w4hm
	w4_h.material_override = weapon_mat
	w4_h.position = Vector3(0.85, 0.85, -2.50)
	pivot.add_child(w4_h)
	var w4_blade: MeshInstance3D = MeshInstance3D.new()
	var w4bm: PrismMesh = PrismMesh.new()
	w4bm.size = Vector3(0.30, 0.30, 0.10)
	w4_blade.mesh = w4bm
	w4_blade.material_override = weapon_mat
	w4_blade.position = Vector3(0.95, 1.25, -2.50)
	w4_blade.rotation.z = -PI / 2.0
	pivot.add_child(w4_blade)
	# ---- Wooden sparring dummy with glowing chest core ----
	var dummy_pivot: Node3D = Node3D.new()
	dummy_pivot.position = Vector3(0, 0, 0.5)
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
	# Body
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
	# Glowing chest core — unshaded amber sphere
	var core_mat: StandardMaterial3D = StandardMaterial3D.new()
	core_mat.albedo_color = Color(1.0, 0.55, 0.10)
	core_mat.emission_enabled = true
	core_mat.emission = Color(1.0, 0.55, 0.10)
	core_mat.emission_energy_multiplier = 6.0
	core_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var core: MeshInstance3D = MeshInstance3D.new()
	var corem: SphereMesh = SphereMesh.new()
	corem.radius = 0.14
	corem.height = 0.28
	core.mesh = corem
	core.material_override = core_mat
	core.position = Vector3(0, 1.30, -0.22)
	dummy_pivot.add_child(core)
	# Dummy collision so player can swing on it
	var sb: StaticBody3D = StaticBody3D.new()
	sb.position = Vector3(0, 1.30, 0)
	var cs: CollisionShape3D = CollisionShape3D.new()
	var caps: CapsuleShape3D = CapsuleShape3D.new()
	caps.radius = 0.40
	caps.height = 1.80
	cs.shape = caps
	sb.add_child(cs)
	dummy_pivot.add_child(sb)
	# Dummy idle wobble — slow back-and-forth lean
	var wobble: Tween = dummy_pivot.create_tween().set_loops()
	wobble.tween_property(dummy_pivot, "rotation:x", 0.05, 1.4).set_ease(Tween.EASE_IN_OUT)
	wobble.tween_property(dummy_pivot, "rotation:x", -0.05, 1.4).set_ease(Tween.EASE_IN_OUT)
	# ---- Brass corner brazier ----
	var brass_mat2: StandardMaterial3D = StandardMaterial3D.new()
	brass_mat2.albedo_color = Color(0.85, 0.55, 0.18)
	brass_mat2.metallic = 0.95
	brass_mat2.roughness = 0.30
	brass_mat2.emission_enabled = true
	brass_mat2.emission = Color(1.0, 0.50, 0.10)
	brass_mat2.emission_energy_multiplier = 0.55
	var braz_pos: Vector3 = Vector3(2.30, 0, -2.30)
	var brazier: MeshInstance3D = MeshInstance3D.new()
	var brzm: CylinderMesh = CylinderMesh.new()
	brzm.top_radius = 0.18
	brzm.bottom_radius = 0.10
	brzm.height = 1.10
	brazier.mesh = brzm
	brazier.material_override = brass_mat2
	brazier.position = braz_pos + Vector3(0, 0.55, 0)
	pivot.add_child(brazier)
	# Brazier flame
	var flame_mat: StandardMaterial3D = StandardMaterial3D.new()
	flame_mat.albedo_color = Color(1.0, 0.65, 0.20)
	flame_mat.emission_enabled = true
	flame_mat.emission = Color(1.0, 0.55, 0.10)
	flame_mat.emission_energy_multiplier = 8.0
	flame_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var flame: MeshInstance3D = MeshInstance3D.new()
	var flm: SphereMesh = SphereMesh.new()
	flm.radius = 0.22
	flm.height = 0.45
	flame.mesh = flm
	flame.material_override = flame_mat
	flame.position = braz_pos + Vector3(0, 1.25, 0)
	pivot.add_child(flame)
	# Brazier OmniLight
	var lt: OmniLight3D = OmniLight3D.new()
	lt.position = braz_pos + Vector3(0, 1.30, 0)
	lt.light_color = Color(1.0, 0.55, 0.15)
	lt.light_energy = 2.6
	lt.omni_range = 6.0
	pivot.add_child(lt)
	# Brazier ember motes
	var motes: GPUParticles3D = GPUParticles3D.new()
	motes.position = braz_pos + Vector3(0, 1.40, 0)
	motes.amount = 18
	motes.lifetime = 2.0
	var pmat: ParticleProcessMaterial = ParticleProcessMaterial.new()
	pmat.direction = Vector3(0, 1, 0)
	pmat.spread = 12.0
	pmat.initial_velocity_min = 0.5
	pmat.initial_velocity_max = 1.0
	pmat.gravity = Vector3(0, 0.3, 0)
	pmat.scale_min = 0.05
	pmat.scale_max = 0.10
	pmat.color = Color(1.0, 0.55, 0.10, 1.0)
	motes.process_material = pmat
	var psmesh: SphereMesh = SphereMesh.new()
	psmesh.radius = 0.04
	psmesh.height = 0.08
	motes.draw_pass_1 = psmesh
	pivot.add_child(motes)
	# Core pulse + flame flicker tweens
	var corep: Tween = pivot.create_tween().set_loops()
	corep.tween_property(core_mat, "emission_energy_multiplier", 8.0, 1.2).set_ease(Tween.EASE_IN_OUT)
	corep.tween_property(core_mat, "emission_energy_multiplier", 4.0, 1.2).set_ease(Tween.EASE_IN_OUT)
	var fpulse: Tween = pivot.create_tween().set_loops()
	fpulse.tween_property(flame_mat, "emission_energy_multiplier", 10.0, 0.4).set_ease(Tween.EASE_IN_OUT)
	fpulse.tween_property(flame_mat, "emission_energy_multiplier", 7.0, 0.4).set_ease(Tween.EASE_IN_OUT)


func _build_d9_apprentice_brun_npc(town: Node) -> void:
	## Epic-9 T70: Apprentice Brun — young smith trainee inside the
	## guildhall training yard, swinging a practice hammer at the dummy.
	## Leather apron over rust shirt, soot bandana, and a glowing
	## ember-burn cheek mark.
	var slots: Node3D = town.get_node_or_null("NPCSlots") as Node3D
	if slots == null:
		return
	var slot: Marker3D = Marker3D.new()
	slot.name = "D9ApprenticeBrunSlot"
	slot.position = Vector3(D9_CENTER.x + 46.5, 0, -16.5)
	slots.add_child(slot)
	var npc_scene: PackedScene = load("res://scenes/entities/npcs/VillagerR3.tscn") as PackedScene
	if npc_scene == null:
		return
	var npc: Node3D = npc_scene.instantiate() as Node3D
	npc.name = "D9ApprenticeBrun"
	if "npc_name" in npc:
		npc.set("npc_name", "Apprentice Brun")
	if "npc_id" in npc:
		npc.set("npc_id", "d9_apprentice_brun")
	npc.rotation.y = PI / 2.0
	slot.add_child(npc)
	# Rust shirt
	var shirt_mat: StandardMaterial3D = StandardMaterial3D.new()
	shirt_mat.albedo_color = Color(0.55, 0.20, 0.10)
	shirt_mat.roughness = 0.85
	shirt_mat.metallic = 0.10
	var shirt: MeshInstance3D = MeshInstance3D.new()
	var sm: BoxMesh = BoxMesh.new()
	sm.size = Vector3(0.95, 1.10, 0.55)
	shirt.mesh = sm
	shirt.material_override = shirt_mat
	shirt.position = Vector3(0, 1.10, 0)
	npc.add_child(shirt)
	# Leather apron
	var apron_mat: StandardMaterial3D = StandardMaterial3D.new()
	apron_mat.albedo_color = Color(0.22, 0.13, 0.08)
	apron_mat.roughness = 0.85
	apron_mat.metallic = 0.15
	apron_mat.emission_enabled = true
	apron_mat.emission = Color(0.55, 0.18, 0.05)
	apron_mat.emission_energy_multiplier = 0.18
	var apron: MeshInstance3D = MeshInstance3D.new()
	var apm: BoxMesh = BoxMesh.new()
	apm.size = Vector3(0.85, 1.00, 0.10)
	apron.mesh = apm
	apron.material_override = apron_mat
	apron.position = Vector3(0, 1.00, -0.30)
	npc.add_child(apron)
	# Apron strap (top)
	var strap: MeshInstance3D = MeshInstance3D.new()
	var stm: BoxMesh = BoxMesh.new()
	stm.size = Vector3(0.85, 0.08, 0.06)
	strap.mesh = stm
	strap.material_override = apron_mat
	strap.position = Vector3(0, 1.55, -0.30)
	npc.add_child(strap)
	# Bandana on the head
	var bandana_mat: StandardMaterial3D = StandardMaterial3D.new()
	bandana_mat.albedo_color = Color(0.65, 0.18, 0.12)
	bandana_mat.roughness = 0.85
	bandana_mat.emission_enabled = true
	bandana_mat.emission = Color(0.85, 0.18, 0.05)
	bandana_mat.emission_energy_multiplier = 0.30
	var bandana: MeshInstance3D = MeshInstance3D.new()
	var bdm: BoxMesh = BoxMesh.new()
	bdm.size = Vector3(0.55, 0.18, 0.50)
	bandana.mesh = bdm
	bandana.material_override = bandana_mat
	bandana.position = Vector3(0, 1.92, 0)
	npc.add_child(bandana)
	# Ember-burn cheek mark — unshaded amber dot
	var ember_mat: StandardMaterial3D = StandardMaterial3D.new()
	ember_mat.albedo_color = Color(1.0, 0.55, 0.10)
	ember_mat.emission_enabled = true
	ember_mat.emission = Color(1.0, 0.55, 0.10)
	ember_mat.emission_energy_multiplier = 5.0
	ember_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var burn: MeshInstance3D = MeshInstance3D.new()
	var burnm: SphereMesh = SphereMesh.new()
	burnm.radius = 0.04
	burnm.height = 0.08
	burn.mesh = burnm
	burn.material_override = ember_mat
	burn.position = Vector3(0.18, 1.78, -0.27)
	npc.add_child(burn)
	# Practice hammer — handle + head, swung
	var wood_mat: StandardMaterial3D = StandardMaterial3D.new()
	wood_mat.albedo_color = Color(0.32, 0.20, 0.12)
	wood_mat.roughness = 0.80
	var iron_mat: StandardMaterial3D = StandardMaterial3D.new()
	iron_mat.albedo_color = Color(0.18, 0.14, 0.11)
	iron_mat.metallic = 0.85
	iron_mat.roughness = 0.40
	iron_mat.emission_enabled = true
	iron_mat.emission = Color(1.0, 0.30, 0.05)
	iron_mat.emission_energy_multiplier = 0.50
	var hammer_pivot: Node3D = Node3D.new()
	hammer_pivot.position = Vector3(-0.30, 1.40, -0.30)
	npc.add_child(hammer_pivot)
	var handle: MeshInstance3D = MeshInstance3D.new()
	var hcm: CylinderMesh = CylinderMesh.new()
	hcm.top_radius = 0.04
	hcm.bottom_radius = 0.05
	hcm.height = 0.95
	handle.mesh = hcm
	handle.material_override = wood_mat
	handle.position = Vector3(0, -0.45, 0)
	hammer_pivot.add_child(handle)
	var head: MeshInstance3D = MeshInstance3D.new()
	var headm: BoxMesh = BoxMesh.new()
	headm.size = Vector3(0.22, 0.18, 0.30)
	head.mesh = headm
	head.material_override = iron_mat
	head.position = Vector3(0, -0.95, 0)
	hammer_pivot.add_child(head)
	# Warm aura OmniLight
	var lt: OmniLight3D = OmniLight3D.new()
	lt.position = Vector3(0, 1.50, 0)
	lt.light_color = Color(1.0, 0.65, 0.20)
	lt.light_energy = 1.4
	lt.omni_range = 4.0
	npc.add_child(lt)
	# Hammer swing — chop down, snap recoil, brief reset hold
	var swing: Tween = npc.create_tween().set_loops()
	swing.tween_property(hammer_pivot, "rotation:x", -1.20, 0.55).set_ease(Tween.EASE_OUT)
	swing.tween_property(hammer_pivot, "rotation:x", -0.10, 0.18).set_ease(Tween.EASE_IN)
	swing.tween_property(hammer_pivot, "rotation:x", -0.10, 0.45)
	# Burn pulse
	var bpulse: Tween = npc.create_tween().set_loops()
	bpulse.tween_property(ember_mat, "emission_energy_multiplier", 7.0, 1.4).set_ease(Tween.EASE_IN_OUT)
	bpulse.tween_property(ember_mat, "emission_energy_multiplier", 4.0, 1.4).set_ease(Tween.EASE_IN_OUT)


func _build_d9_molten_geyser(geom: Node) -> void:
	## Epic-9 T71: tall periodic molten geyser feature in D9's NE quadrant.
	## Basalt cone vent with a glowing inner ring, a tall lava jet column
	## that pulses up-and-down (eruption cycle), drifting steam plume
	## particles, ember mote shower, and a strong base OmniLight. Adds
	## vertical drama far from existing landmarks.
	var pivot: Node3D = Node3D.new()
	pivot.name = "D9_MoltenGeyser"
	pivot.position = D9_CENTER + Vector3(60, 0, -10)
	geom.add_child(pivot)
	# ---- Vent cone (basalt) ----
	var basalt_mat: StandardMaterial3D = StandardMaterial3D.new()
	basalt_mat.albedo_color = Color(0.10, 0.08, 0.07)
	basalt_mat.metallic = 0.18
	basalt_mat.roughness = 0.85
	basalt_mat.emission_enabled = true
	basalt_mat.emission = Color(0.55, 0.18, 0.05)
	basalt_mat.emission_energy_multiplier = 0.30
	# Outer cone — wider base, narrower top
	var cone: MeshInstance3D = MeshInstance3D.new()
	var cm: CylinderMesh = CylinderMesh.new()
	cm.top_radius = 1.10
	cm.bottom_radius = 2.40
	cm.height = 1.40
	cone.mesh = cm
	cone.material_override = basalt_mat
	cone.position = Vector3(0, 0.70, 0)
	pivot.add_child(cone)
	# Vent collision (so player can't walk through it)
	var sb: StaticBody3D = StaticBody3D.new()
	sb.position = Vector3(0, 0.70, 0)
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cylsh: CylinderShape3D = CylinderShape3D.new()
	cylsh.radius = maxf(1.10, 2.40)
	cylsh.height = 1.40
	cs.shape = cylsh
	sb.add_child(cs)
	pivot.add_child(sb)
	# Inner glowing ring at the vent rim
	var lava_mat: StandardMaterial3D = StandardMaterial3D.new()
	lava_mat.albedo_color = Color(1.0, 0.45, 0.05)
	lava_mat.emission_enabled = true
	lava_mat.emission = Color(1.0, 0.45, 0.05)
	lava_mat.emission_energy_multiplier = 8.0
	lava_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var ring: MeshInstance3D = MeshInstance3D.new()
	var rmesh: TorusMesh = TorusMesh.new()
	rmesh.inner_radius = 0.85
	rmesh.outer_radius = 1.10
	ring.mesh = rmesh
	ring.material_override = lava_mat
	ring.position = Vector3(0, 1.42, 0)
	pivot.add_child(ring)
	# Inner lava pool plug — flat disc filling the vent
	var plug: MeshInstance3D = MeshInstance3D.new()
	var plugm: CylinderMesh = CylinderMesh.new()
	plugm.top_radius = 0.95
	plugm.bottom_radius = 0.95
	plugm.height = 0.10
	plug.mesh = plugm
	plug.material_override = lava_mat
	plug.position = Vector3(0, 1.40, 0)
	pivot.add_child(plug)
	# ---- Lava jet column (eruption stalk) ----
	# Pivot we can scale on Y to simulate eruption rise/fall
	var jet_pivot: Node3D = Node3D.new()
	jet_pivot.position = Vector3(0, 1.45, 0)
	pivot.add_child(jet_pivot)
	# Tall thin cylinder for the main jet
	var jet: MeshInstance3D = MeshInstance3D.new()
	var jm: CylinderMesh = CylinderMesh.new()
	jm.top_radius = 0.20
	jm.bottom_radius = 0.55
	jm.height = 6.50
	jet.mesh = jm
	jet.material_override = lava_mat
	jet.position = Vector3(0, 3.25, 0)
	jet_pivot.add_child(jet)
	# Smaller inner core jet (whiter hot)
	var hot_mat: StandardMaterial3D = StandardMaterial3D.new()
	hot_mat.albedo_color = Color(1.0, 0.85, 0.55)
	hot_mat.emission_enabled = true
	hot_mat.emission = Color(1.0, 0.80, 0.50)
	hot_mat.emission_energy_multiplier = 12.0
	hot_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var core_jet: MeshInstance3D = MeshInstance3D.new()
	var cjm: CylinderMesh = CylinderMesh.new()
	cjm.top_radius = 0.08
	cjm.bottom_radius = 0.22
	cjm.height = 6.20
	core_jet.mesh = cjm
	core_jet.material_override = hot_mat
	core_jet.position = Vector3(0, 3.10, 0)
	jet_pivot.add_child(core_jet)
	# Crown blob at jet top
	var crown: MeshInstance3D = MeshInstance3D.new()
	var crownm: SphereMesh = SphereMesh.new()
	crownm.radius = 0.55
	crownm.height = 1.10
	crown.mesh = crownm
	crown.material_override = lava_mat
	crown.position = Vector3(0, 6.40, 0)
	jet_pivot.add_child(crown)
	# Start the jet collapsed
	jet_pivot.scale = Vector3(0.4, 0.10, 0.4)
	# Eruption tween — collapsed → high → collapsed in a 5s cycle
	var erupt: Tween = pivot.create_tween().set_loops()
	erupt.tween_property(jet_pivot, "scale", Vector3(1.0, 1.0, 1.0), 1.2).set_ease(Tween.EASE_OUT)
	erupt.tween_property(jet_pivot, "scale", Vector3(1.0, 1.0, 1.0), 1.6)
	erupt.tween_property(jet_pivot, "scale", Vector3(0.4, 0.10, 0.4), 1.0).set_ease(Tween.EASE_IN)
	erupt.tween_property(jet_pivot, "scale", Vector3(0.4, 0.10, 0.4), 1.2)
	# ---- Steam plume particles (white drift up) ----
	var steam: GPUParticles3D = GPUParticles3D.new()
	steam.position = Vector3(0, 1.80, 0)
	steam.amount = 32
	steam.lifetime = 4.0
	var spmat: ParticleProcessMaterial = ParticleProcessMaterial.new()
	spmat.direction = Vector3(0, 1, 0)
	spmat.spread = 22.0
	spmat.initial_velocity_min = 0.8
	spmat.initial_velocity_max = 1.6
	spmat.gravity = Vector3(0, 0.5, 0)
	spmat.scale_min = 0.30
	spmat.scale_max = 0.60
	spmat.color = Color(0.90, 0.85, 0.85, 0.65)
	steam.process_material = spmat
	var ssmesh: SphereMesh = SphereMesh.new()
	ssmesh.radius = 0.20
	ssmesh.height = 0.40
	steam.draw_pass_1 = ssmesh
	pivot.add_child(steam)
	# ---- Ember mote shower (bright fast embers) ----
	var embers: GPUParticles3D = GPUParticles3D.new()
	embers.position = Vector3(0, 2.20, 0)
	embers.amount = 48
	embers.lifetime = 2.5
	var emat: ParticleProcessMaterial = ParticleProcessMaterial.new()
	emat.direction = Vector3(0, 1, 0)
	emat.spread = 30.0
	emat.initial_velocity_min = 2.5
	emat.initial_velocity_max = 4.5
	emat.gravity = Vector3(0, -2.5, 0)
	emat.scale_min = 0.06
	emat.scale_max = 0.14
	emat.color = Color(1.0, 0.55, 0.10, 1.0)
	embers.process_material = emat
	var esmesh: SphereMesh = SphereMesh.new()
	esmesh.radius = 0.05
	esmesh.height = 0.10
	embers.draw_pass_1 = esmesh
	pivot.add_child(embers)
	# ---- Strong base OmniLight ----
	var lt: OmniLight3D = OmniLight3D.new()
	lt.position = Vector3(0, 2.40, 0)
	lt.light_color = Color(1.0, 0.55, 0.15)
	lt.light_energy = 4.5
	lt.omni_range = 14.0
	pivot.add_child(lt)
	# Ring + plug pulse to match eruption rhythm
	var rpulse: Tween = pivot.create_tween().set_loops()
	rpulse.tween_property(lava_mat, "emission_energy_multiplier", 11.0, 1.4).set_ease(Tween.EASE_IN_OUT)
	rpulse.tween_property(lava_mat, "emission_energy_multiplier", 6.0, 1.4).set_ease(Tween.EASE_IN_OUT)


func _build_d9_lava_bomb_scatter(geom: Node) -> void:
	## Epic-9 T72: scattered cooled lava-bomb boulders fallen around the
	## molten geyser from past eruptions. 9 dark basalt spheres of varying
	## size with collision, three of them cracked open showing glowing
	## magma cores with rising ember motes. Establishes geyser history
	## and gives the splash zone visual weight.
	var pivot: Node3D = Node3D.new()
	pivot.name = "D9_LavaBombScatter"
	pivot.position = D9_CENTER + Vector3(60, 0, -10)
	geom.add_child(pivot)
	# Shared materials
	var rock_mat: StandardMaterial3D = StandardMaterial3D.new()
	rock_mat.albedo_color = Color(0.10, 0.08, 0.07)
	rock_mat.metallic = 0.20
	rock_mat.roughness = 0.90
	rock_mat.emission_enabled = true
	rock_mat.emission = Color(0.45, 0.15, 0.04)
	rock_mat.emission_energy_multiplier = 0.18
	var crack_mat: StandardMaterial3D = StandardMaterial3D.new()
	crack_mat.albedo_color = Color(1.0, 0.45, 0.05)
	crack_mat.emission_enabled = true
	crack_mat.emission = Color(1.0, 0.45, 0.05)
	crack_mat.emission_energy_multiplier = 7.0
	crack_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	# Boulder placements: position relative to geyser, size, and "is_cracked"
	# (cracked ones get an embedded glow + ember motes)
	var bombs: Array = [
		{"pos": Vector3(4.5, 0, 1.2), "r": 0.95, "cracked": true},
		{"pos": Vector3(-3.8, 0, 2.4), "r": 0.75, "cracked": false},
		{"pos": Vector3(-5.2, 0, -1.8), "r": 0.85, "cracked": true},
		{"pos": Vector3(2.8, 0, -4.5), "r": 0.65, "cracked": false},
		{"pos": Vector3(5.6, 0, -2.4), "r": 0.55, "cracked": false},
		{"pos": Vector3(-2.4, 0, -4.8), "r": 0.70, "cracked": true},
		{"pos": Vector3(6.8, 0, 3.2), "r": 0.45, "cracked": false},
		{"pos": Vector3(-6.2, 0, 0.8), "r": 0.60, "cracked": false},
		{"pos": Vector3(3.4, 0, 5.4), "r": 0.50, "cracked": false},
	]
	for b in bombs:
		var bp: Vector3 = b["pos"]
		var r: float = b["r"]
		var cracked: bool = b["cracked"]
		# Boulder body
		var rock: MeshInstance3D = MeshInstance3D.new()
		var rmesh: SphereMesh = SphereMesh.new()
		rmesh.radius = r
		rmesh.height = r * 1.85
		rock.mesh = rmesh
		rock.material_override = rock_mat
		rock.position = bp + Vector3(0, r * 0.85, 0)
		# Slight random tilt for variety
		rock.rotation = Vector3(randf() * 0.4, randf() * TAU, randf() * 0.4)
		pivot.add_child(rock)
		# Boulder collision (sphere)
		var sb: StaticBody3D = StaticBody3D.new()
		sb.position = bp + Vector3(0, r * 0.85, 0)
		var cs: CollisionShape3D = CollisionShape3D.new()
		var ssh: SphereShape3D = SphereShape3D.new()
		ssh.radius = r * 0.95
		cs.shape = ssh
		sb.add_child(cs)
		pivot.add_child(sb)
		# If cracked, add a glowing magma core nub poking out + ember motes
		if cracked:
			# Crack core — smaller bright sphere offset to one side
			var core: MeshInstance3D = MeshInstance3D.new()
			var cm: SphereMesh = SphereMesh.new()
			cm.radius = r * 0.40
			cm.height = r * 0.80
			core.mesh = cm
			core.material_override = crack_mat
			core.position = bp + Vector3(r * 0.55, r * 1.10, 0)
			pivot.add_child(core)
			# Crack stripe — thin glowing box across the boulder top
			var stripe: MeshInstance3D = MeshInstance3D.new()
			var smm: BoxMesh = BoxMesh.new()
			smm.size = Vector3(r * 1.40, 0.06, 0.10)
			stripe.mesh = smm
			stripe.material_override = crack_mat
			stripe.position = bp + Vector3(0, r * 1.55, 0)
			stripe.rotation.y = randf() * TAU
			pivot.add_child(stripe)
			# Small OmniLight for the crack glow
			var lt: OmniLight3D = OmniLight3D.new()
			lt.position = bp + Vector3(0, r * 1.30, 0)
			lt.light_color = Color(1.0, 0.55, 0.15)
			lt.light_energy = 1.6
			lt.omni_range = 4.0
			pivot.add_child(lt)
			# Rising ember motes from the crack
			var motes: GPUParticles3D = GPUParticles3D.new()
			motes.position = bp + Vector3(r * 0.55, r * 1.40, 0)
			motes.amount = 10
			motes.lifetime = 1.8
			var pmat: ParticleProcessMaterial = ParticleProcessMaterial.new()
			pmat.direction = Vector3(0, 1, 0)
			pmat.spread = 14.0
			pmat.initial_velocity_min = 0.4
			pmat.initial_velocity_max = 0.9
			pmat.gravity = Vector3(0, 0.3, 0)
			pmat.scale_min = 0.04
			pmat.scale_max = 0.08
			pmat.color = Color(1.0, 0.55, 0.10, 1.0)
			motes.process_material = pmat
			var psmesh: SphereMesh = SphereMesh.new()
			psmesh.radius = 0.03
			psmesh.height = 0.06
			motes.draw_pass_1 = psmesh
			pivot.add_child(motes)
	# Crack pulse — slowly breathe magma color across all cracked cores
	var cpulse: Tween = pivot.create_tween().set_loops()
	cpulse.tween_property(crack_mat, "emission_energy_multiplier", 9.0, 1.6).set_ease(Tween.EASE_IN_OUT)
	cpulse.tween_property(crack_mat, "emission_energy_multiplier", 5.0, 1.6).set_ease(Tween.EASE_IN_OUT)


func _build_d9_geyser_observation_deck(geom: Node) -> void:
	## Epic-9 T73: raised basalt observation deck overlooking the molten
	## geyser. Hex-ish basalt platform with collision, brass-capped iron
	## post-and-rail safety perimeter (open back for entry), instrument
	## tripod with a glowing readout disc + brass focus ring, two corner
	## braziers, and a small wall plaque with the guild crest.
	var pivot: Node3D = Node3D.new()
	pivot.name = "D9_GeyserObservationDeck"
	# Place to the south side of the geyser (geyser at +60, -10), facing it
	pivot.position = D9_CENTER + Vector3(60, 0, -2)
	geom.add_child(pivot)
	# Materials
	var basalt_mat: StandardMaterial3D = StandardMaterial3D.new()
	basalt_mat.albedo_color = Color(0.10, 0.08, 0.07)
	basalt_mat.metallic = 0.18
	basalt_mat.roughness = 0.85
	basalt_mat.emission_enabled = true
	basalt_mat.emission = Color(0.45, 0.15, 0.04)
	basalt_mat.emission_energy_multiplier = 0.20
	var iron_mat: StandardMaterial3D = StandardMaterial3D.new()
	iron_mat.albedo_color = Color(0.18, 0.14, 0.11)
	iron_mat.metallic = 0.85
	iron_mat.roughness = 0.40
	iron_mat.emission_enabled = true
	iron_mat.emission = Color(0.85, 0.25, 0.05)
	iron_mat.emission_energy_multiplier = 0.40
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
	amber_mat.emission_energy_multiplier = 6.0
	amber_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	# ---- Raised basalt platform ----
	var deck: MeshInstance3D = MeshInstance3D.new()
	var dm: CylinderMesh = CylinderMesh.new()
	dm.top_radius = 3.20
	dm.bottom_radius = 3.40
	dm.height = 0.55
	deck.mesh = dm
	deck.material_override = basalt_mat
	deck.position = Vector3(0, 0.28, 0)
	pivot.add_child(deck)
	# Deck collision
	var sb: StaticBody3D = StaticBody3D.new()
	sb.position = Vector3(0, 0.28, 0)
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cylsh: CylinderShape3D = CylinderShape3D.new()
	cylsh.radius = maxf(3.30, 3.40)
	cylsh.height = 0.55
	cs.shape = cylsh
	sb.add_child(cs)
	pivot.add_child(sb)
	# Glowing magma seam ring around the deck rim
	var rim_seam: MeshInstance3D = MeshInstance3D.new()
	var rsm: TorusMesh = TorusMesh.new()
	rsm.inner_radius = 3.10
	rsm.outer_radius = 3.30
	rim_seam.mesh = rsm
	rim_seam.material_override = amber_mat
	rim_seam.position = Vector3(0, 0.58, 0)
	pivot.add_child(rim_seam)
	# ---- Iron post-and-rail safety perimeter (8 posts around the rim) ----
	# Skip 2 posts on the back (south) side to leave an entry gap
	var post_count: int = 8
	for i in post_count:
		# Skip posts roughly behind the deck (near +Z, the entry side)
		if i == 0 or i == 7:
			continue
		var ang: float = float(i) / float(post_count) * TAU
		var px: float = cos(ang) * 3.05
		var pz: float = sin(ang) * 3.05
		var post: MeshInstance3D = MeshInstance3D.new()
		var pm: CylinderMesh = CylinderMesh.new()
		pm.top_radius = 0.07
		pm.bottom_radius = 0.09
		pm.height = 1.10
		post.mesh = pm
		post.material_override = iron_mat
		post.position = Vector3(px, 1.05, pz)
		pivot.add_child(post)
		# Brass post cap
		var cap: MeshInstance3D = MeshInstance3D.new()
		var capm: SphereMesh = SphereMesh.new()
		capm.radius = 0.09
		capm.height = 0.18
		cap.mesh = capm
		cap.material_override = brass_mat
		cap.position = Vector3(px, 1.65, pz)
		pivot.add_child(cap)
	# Top rail — torus around the perimeter (visible all around, the gap is just visual)
	var rail: MeshInstance3D = MeshInstance3D.new()
	var rmesh: TorusMesh = TorusMesh.new()
	rmesh.inner_radius = 2.95
	rmesh.outer_radius = 3.15
	rail.mesh = rmesh
	rail.material_override = iron_mat
	rail.position = Vector3(0, 1.50, 0)
	pivot.add_child(rail)
	# ---- Instrument tripod (center of deck, facing geyser) ----
	# Tripod legs (3 angled cylinders)
	var tripod_pivot: Node3D = Node3D.new()
	tripod_pivot.position = Vector3(0, 0.55, -0.5)
	pivot.add_child(tripod_pivot)
	for i in 3:
		var ang: float = float(i) / 3.0 * TAU
		var leg: MeshInstance3D = MeshInstance3D.new()
		var lm: CylinderMesh = CylinderMesh.new()
		lm.top_radius = 0.04
		lm.bottom_radius = 0.05
		lm.height = 1.20
		leg.mesh = lm
		leg.material_override = brass_mat
		leg.position = Vector3(cos(ang) * 0.20, 0.55, sin(ang) * 0.20)
		# Splay outward from vertical
		leg.rotation = Vector3(sin(ang) * 0.20, 0, -cos(ang) * 0.20)
		tripod_pivot.add_child(leg)
	# Tripod head — small brass box
	var t_head: MeshInstance3D = MeshInstance3D.new()
	var thm: BoxMesh = BoxMesh.new()
	thm.size = Vector3(0.30, 0.18, 0.30)
	t_head.mesh = thm
	t_head.material_override = brass_mat
	t_head.position = Vector3(0, 1.20, 0)
	tripod_pivot.add_child(t_head)
	# Readout disc — glowing amber dial
	var disc: MeshInstance3D = MeshInstance3D.new()
	var disc_m: CylinderMesh = CylinderMesh.new()
	disc_m.top_radius = 0.18
	disc_m.bottom_radius = 0.18
	disc_m.height = 0.05
	disc.mesh = disc_m
	disc.material_override = amber_mat
	disc.position = Vector3(0, 1.30, -0.20)
	disc.rotation.x = PI / 2.0
	tripod_pivot.add_child(disc)
	# Brass focus ring around the disc
	var focus: MeshInstance3D = MeshInstance3D.new()
	var focm: TorusMesh = TorusMesh.new()
	focm.inner_radius = 0.18
	focm.outer_radius = 0.24
	focus.mesh = focm
	focus.material_override = brass_mat
	focus.position = Vector3(0, 1.30, -0.20)
	tripod_pivot.add_child(focus)
	# Disc indicator needle — small unshaded amber bar that rotates
	var needle: MeshInstance3D = MeshInstance3D.new()
	var nm: BoxMesh = BoxMesh.new()
	nm.size = Vector3(0.02, 0.18, 0.02)
	needle.mesh = nm
	needle.material_override = amber_mat
	needle.position = Vector3(0, 1.30, -0.22)
	tripod_pivot.add_child(needle)
	# ---- Two corner braziers ----
	for bx in [-2.40, 2.40]:
		var bp: Vector3 = Vector3(bx, 0.55, 1.80)
		# Brazier post
		var bpost: MeshInstance3D = MeshInstance3D.new()
		var bpm: CylinderMesh = CylinderMesh.new()
		bpm.top_radius = 0.10
		bpm.bottom_radius = 0.14
		bpm.height = 0.85
		bpost.mesh = bpm
		bpost.material_override = brass_mat
		bpost.position = bp + Vector3(0, 0.42, 0)
		pivot.add_child(bpost)
		# Brazier bowl
		var bowl: MeshInstance3D = MeshInstance3D.new()
		var bowm: SphereMesh = SphereMesh.new()
		bowm.radius = 0.20
		bowm.height = 0.35
		bowl.mesh = bowm
		bowl.material_override = brass_mat
		bowl.position = bp + Vector3(0, 0.92, 0)
		bowl.scale = Vector3(1.0, 0.55, 1.0)
		pivot.add_child(bowl)
		# Flame
		var flame: MeshInstance3D = MeshInstance3D.new()
		var flm: SphereMesh = SphereMesh.new()
		flm.radius = 0.18
		flm.height = 0.36
		flame.mesh = flm
		flame.material_override = amber_mat
		flame.position = bp + Vector3(0, 1.10, 0)
		pivot.add_child(flame)
		# OmniLight
		var lt: OmniLight3D = OmniLight3D.new()
		lt.position = bp + Vector3(0, 1.10, 0)
		lt.light_color = Color(1.0, 0.55, 0.15)
		lt.light_energy = 2.0
		lt.omni_range = 5.0
		pivot.add_child(lt)
	# ---- Wall plaque (small brass plate with crest) ----
	var plaque: MeshInstance3D = MeshInstance3D.new()
	var plm: BoxMesh = BoxMesh.new()
	plm.size = Vector3(0.85, 0.50, 0.06)
	plaque.mesh = plm
	plaque.material_override = brass_mat
	plaque.position = Vector3(0, 1.10, 2.95)
	pivot.add_child(plaque)
	# Crest torus on the plaque
	var crest: MeshInstance3D = MeshInstance3D.new()
	var ctm: TorusMesh = TorusMesh.new()
	ctm.inner_radius = 0.10
	ctm.outer_radius = 0.18
	crest.mesh = ctm
	crest.material_override = amber_mat
	crest.position = Vector3(0, 1.10, 2.92)
	crest.rotation.x = PI / 2.0
	pivot.add_child(crest)
	# Needle rotation tween — slow sweep like reading lava pressure
	var nspin: Tween = pivot.create_tween().set_loops()
	nspin.tween_property(needle, "rotation:z", PI / 2.0, 2.4).set_ease(Tween.EASE_IN_OUT)
	nspin.tween_property(needle, "rotation:z", -PI / 2.0, 2.4).set_ease(Tween.EASE_IN_OUT)
	# Disc + rim pulse
	var dpulse: Tween = pivot.create_tween().set_loops()
	dpulse.tween_property(amber_mat, "emission_energy_multiplier", 8.0, 1.4).set_ease(Tween.EASE_IN_OUT)
	dpulse.tween_property(amber_mat, "emission_energy_multiplier", 5.0, 1.4).set_ease(Tween.EASE_IN_OUT)


func _build_d9_vulcanologist_cinder_npc(town: Node) -> void:
	## Epic-9 T74: Vulcanologist Cinder — observer NPC stationed at the
	## geyser observation deck tripod. Long heat-resistant coat, leather
	## gloves, brass goggles with glowing amber lenses, clipboard tucked
	## under arm, and a slow note-taking head bob.
	var slots: Node3D = town.get_node_or_null("NPCSlots") as Node3D
	if slots == null:
		return
	var slot: Marker3D = Marker3D.new()
	slot.name = "D9VulcanologistCinderSlot"
	# Stand on the deck, just behind the tripod, facing the geyser (-Z forward)
	slot.position = Vector3(D9_CENTER.x + 60, 0.55, -1.8)
	slots.add_child(slot)
	var npc_scene: PackedScene = load("res://scenes/entities/npcs/VillagerR3.tscn") as PackedScene
	if npc_scene == null:
		return
	var npc: Node3D = npc_scene.instantiate() as Node3D
	npc.name = "D9VulcanologistCinder"
	if "npc_name" in npc:
		npc.set("npc_name", "Vulcanologist Cinder")
	if "npc_id" in npc:
		npc.set("npc_id", "d9_vulcanologist_cinder")
	# Face the geyser (-Z direction)
	npc.rotation.y = PI
	slot.add_child(npc)
	# Long heat-resistant coat — narrow tall box
	var coat_mat: StandardMaterial3D = StandardMaterial3D.new()
	coat_mat.albedo_color = Color(0.32, 0.18, 0.10)
	coat_mat.roughness = 0.85
	coat_mat.metallic = 0.18
	coat_mat.emission_enabled = true
	coat_mat.emission = Color(0.65, 0.20, 0.05)
	coat_mat.emission_energy_multiplier = 0.20
	var coat: MeshInstance3D = MeshInstance3D.new()
	var cmesh: BoxMesh = BoxMesh.new()
	cmesh.size = Vector3(0.95, 1.65, 0.55)
	coat.mesh = cmesh
	coat.material_override = coat_mat
	coat.position = Vector3(0, 0.85, 0)
	npc.add_child(coat)
	# Brass collar trim
	var brass_mat: StandardMaterial3D = StandardMaterial3D.new()
	brass_mat.albedo_color = Color(0.85, 0.55, 0.18)
	brass_mat.metallic = 0.95
	brass_mat.roughness = 0.30
	brass_mat.emission_enabled = true
	brass_mat.emission = Color(1.0, 0.50, 0.10)
	brass_mat.emission_energy_multiplier = 0.55
	var collar: MeshInstance3D = MeshInstance3D.new()
	var colm: BoxMesh = BoxMesh.new()
	colm.size = Vector3(0.95, 0.10, 0.55)
	collar.mesh = colm
	collar.material_override = brass_mat
	collar.position = Vector3(0, 1.65, 0)
	npc.add_child(collar)
	# Coat front buttons (3 brass studs down the chest)
	for by in [1.45, 1.20, 0.95]:
		var btn: MeshInstance3D = MeshInstance3D.new()
		var bm: SphereMesh = SphereMesh.new()
		bm.radius = 0.05
		bm.height = 0.10
		btn.mesh = bm
		btn.material_override = brass_mat
		btn.position = Vector3(0, by, -0.30)
		npc.add_child(btn)
	# Leather gloves — 2 small dark boxes at the wrists
	var glove_mat: StandardMaterial3D = StandardMaterial3D.new()
	glove_mat.albedo_color = Color(0.18, 0.10, 0.06)
	glove_mat.roughness = 0.85
	glove_mat.metallic = 0.10
	for gx in [-0.55, 0.55]:
		var glove: MeshInstance3D = MeshInstance3D.new()
		var gm: BoxMesh = BoxMesh.new()
		gm.size = Vector3(0.18, 0.18, 0.16)
		glove.mesh = gm
		glove.material_override = glove_mat
		glove.position = Vector3(gx, 1.05, -0.10)
		npc.add_child(glove)
	# Goggles head pivot — small Node3D for the head + goggles
	var head_pivot: Node3D = Node3D.new()
	head_pivot.position = Vector3(0, 1.95, 0)
	npc.add_child(head_pivot)
	# Goggles strap (brass band around the head)
	var strap: MeshInstance3D = MeshInstance3D.new()
	var stm: TorusMesh = TorusMesh.new()
	stm.inner_radius = 0.30
	stm.outer_radius = 0.36
	strap.mesh = stm
	strap.material_override = brass_mat
	strap.position = Vector3(0, 0.05, 0)
	strap.rotation.x = PI / 2.0
	head_pivot.add_child(strap)
	# Goggles lenses — two unshaded amber discs
	var lens_mat: StandardMaterial3D = StandardMaterial3D.new()
	lens_mat.albedo_color = Color(1.0, 0.55, 0.10)
	lens_mat.emission_enabled = true
	lens_mat.emission = Color(1.0, 0.55, 0.10)
	lens_mat.emission_energy_multiplier = 6.0
	lens_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for lx in [-0.13, 0.13]:
		var lens: MeshInstance3D = MeshInstance3D.new()
		var lm: CylinderMesh = CylinderMesh.new()
		lm.top_radius = 0.09
		lm.bottom_radius = 0.09
		lm.height = 0.04
		lens.mesh = lm
		lens.material_override = lens_mat
		lens.position = Vector3(lx, 0.0, -0.30)
		lens.rotation.x = PI / 2.0
		head_pivot.add_child(lens)
	# Clipboard tucked under his right arm — flat dark box + glowing amber stripe
	var board_mat: StandardMaterial3D = StandardMaterial3D.new()
	board_mat.albedo_color = Color(0.20, 0.14, 0.10)
	board_mat.roughness = 0.85
	board_mat.metallic = 0.20
	var clipboard: MeshInstance3D = MeshInstance3D.new()
	var clm: BoxMesh = BoxMesh.new()
	clm.size = Vector3(0.50, 0.65, 0.05)
	clipboard.mesh = clm
	clipboard.material_override = board_mat
	clipboard.position = Vector3(0.55, 1.10, 0.20)
	clipboard.rotation.z = -0.20
	npc.add_child(clipboard)
	# Clipboard glowing notes stripe
	var notes: MeshInstance3D = MeshInstance3D.new()
	var nm: BoxMesh = BoxMesh.new()
	nm.size = Vector3(0.40, 0.05, 0.04)
	notes.mesh = nm
	notes.material_override = lens_mat
	notes.position = Vector3(0.55, 1.20, 0.22)
	notes.rotation.z = -0.20
	npc.add_child(notes)
	# Subtle warm OmniLight aura
	var lt: OmniLight3D = OmniLight3D.new()
	lt.position = Vector3(0, 1.90, -0.20)
	lt.light_color = Color(1.0, 0.65, 0.20)
	lt.light_energy = 1.4
	lt.omni_range = 4.0
	npc.add_child(lt)
	# Note-taking head bob — slow up-down nod
	var nod: Tween = npc.create_tween().set_loops()
	nod.tween_property(head_pivot, "rotation:x", 0.18, 1.6).set_ease(Tween.EASE_IN_OUT)
	nod.tween_property(head_pivot, "rotation:x", -0.05, 1.6).set_ease(Tween.EASE_IN_OUT)
	# Lens + notes pulse
	var lpulse: Tween = npc.create_tween().set_loops()
	lpulse.tween_property(lens_mat, "emission_energy_multiplier", 8.0, 1.3).set_ease(Tween.EASE_IN_OUT)
	lpulse.tween_property(lens_mat, "emission_energy_multiplier", 5.0, 1.3).set_ease(Tween.EASE_IN_OUT)


func _build_d9_forge_memorial(geom: Node) -> void:
	## Epic-9 T75: tall basalt obelisk monument honoring fallen smiths,
	## ringed by 6 brass burning urns. Stepped basalt base + tapered
	## obelisk shaft with embedded glowing rune stripe + crowning ember
	## flame, surrounded by 6 brass urns each with steady flame, light,
	## and rising ember motes. Adds narrative weight to D9's SW quadrant.
	var pivot: Node3D = Node3D.new()
	pivot.name = "D9_ForgeMemorial"
	pivot.position = D9_CENTER + Vector3(-18, 0, 14)
	geom.add_child(pivot)
	# Materials
	var basalt_mat: StandardMaterial3D = StandardMaterial3D.new()
	basalt_mat.albedo_color = Color(0.10, 0.08, 0.07)
	basalt_mat.metallic = 0.18
	basalt_mat.roughness = 0.85
	basalt_mat.emission_enabled = true
	basalt_mat.emission = Color(0.45, 0.15, 0.04)
	basalt_mat.emission_energy_multiplier = 0.20
	var brass_mat: StandardMaterial3D = StandardMaterial3D.new()
	brass_mat.albedo_color = Color(0.85, 0.55, 0.18)
	brass_mat.metallic = 0.95
	brass_mat.roughness = 0.30
	brass_mat.emission_enabled = true
	brass_mat.emission = Color(1.0, 0.50, 0.10)
	brass_mat.emission_energy_multiplier = 0.55
	var rune_mat: StandardMaterial3D = StandardMaterial3D.new()
	rune_mat.albedo_color = Color(1.0, 0.45, 0.05)
	rune_mat.emission_enabled = true
	rune_mat.emission = Color(1.0, 0.45, 0.05)
	rune_mat.emission_energy_multiplier = 6.0
	rune_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var flame_mat: StandardMaterial3D = StandardMaterial3D.new()
	flame_mat.albedo_color = Color(1.0, 0.65, 0.20)
	flame_mat.emission_enabled = true
	flame_mat.emission = Color(1.0, 0.55, 0.10)
	flame_mat.emission_energy_multiplier = 8.0
	flame_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	# ---- Stepped basalt base (3 stacked rings, descending size) ----
	var base_steps: Array = [
		{"r": 3.20, "h": 0.30, "y": 0.15},
		{"r": 2.55, "h": 0.30, "y": 0.45},
		{"r": 1.90, "h": 0.30, "y": 0.75},
	]
	for step in base_steps:
		var s: MeshInstance3D = MeshInstance3D.new()
		var smesh: CylinderMesh = CylinderMesh.new()
		smesh.top_radius = step["r"]
		smesh.bottom_radius = step["r"] + 0.10
		smesh.height = step["h"]
		s.mesh = smesh
		s.material_override = basalt_mat
		s.position = Vector3(0, step["y"], 0)
		pivot.add_child(s)
	# Base collision (covers all 3 steps as one cylinder)
	var sb: StaticBody3D = StaticBody3D.new()
	sb.position = Vector3(0, 0.45, 0)
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cylsh: CylinderShape3D = CylinderShape3D.new()
	cylsh.radius = maxf(1.90, 3.20)
	cylsh.height = 0.90
	cs.shape = cylsh
	sb.add_child(cs)
	pivot.add_child(sb)
	# ---- Tapered obelisk shaft ----
	var shaft: MeshInstance3D = MeshInstance3D.new()
	var shm: BoxMesh = BoxMesh.new()
	shm.size = Vector3(1.20, 6.00, 1.20)
	shaft.mesh = shm
	shaft.material_override = basalt_mat
	shaft.position = Vector3(0, 3.90, 0)
	pivot.add_child(shaft)
	# Shaft collision
	var sb2: StaticBody3D = StaticBody3D.new()
	sb2.position = Vector3(0, 3.90, 0)
	var cs2: CollisionShape3D = CollisionShape3D.new()
	var bsh: BoxShape3D = BoxShape3D.new()
	bsh.size = Vector3(1.20, 6.00, 1.20)
	cs2.shape = bsh
	sb2.add_child(cs2)
	pivot.add_child(sb2)
	# Pyramid cap (using PrismMesh, rotated)
	var cap: MeshInstance3D = MeshInstance3D.new()
	var capm: PrismMesh = PrismMesh.new()
	capm.size = Vector3(1.20, 0.90, 1.20)
	cap.mesh = capm
	cap.material_override = basalt_mat
	cap.position = Vector3(0, 7.35, 0)
	pivot.add_child(cap)
	# Glowing rune stripe — vertical box embedded in the shaft front
	var rune_stripe: MeshInstance3D = MeshInstance3D.new()
	var rsm: BoxMesh = BoxMesh.new()
	rsm.size = Vector3(0.20, 4.50, 0.06)
	rune_stripe.mesh = rsm
	rune_stripe.material_override = rune_mat
	rune_stripe.position = Vector3(0, 3.90, -0.62)
	pivot.add_child(rune_stripe)
	# 4 rune crossbars on the stripe (small horizontal segments)
	for ry in [2.40, 3.40, 4.40, 5.40]:
		var cross: MeshInstance3D = MeshInstance3D.new()
		var cmm: BoxMesh = BoxMesh.new()
		cmm.size = Vector3(0.50, 0.10, 0.06)
		cross.mesh = cmm
		cross.material_override = rune_mat
		cross.position = Vector3(0, ry, -0.62)
		pivot.add_child(cross)
	# Crowning ember flame on top of the cap
	var crown: MeshInstance3D = MeshInstance3D.new()
	var crm: SphereMesh = SphereMesh.new()
	crm.radius = 0.30
	crm.height = 0.65
	crown.mesh = crm
	crown.material_override = flame_mat
	crown.position = Vector3(0, 8.10, 0)
	pivot.add_child(crown)
	# Crown OmniLight
	var clt: OmniLight3D = OmniLight3D.new()
	clt.position = Vector3(0, 8.10, 0)
	clt.light_color = Color(1.0, 0.55, 0.15)
	clt.light_energy = 4.0
	clt.omni_range = 12.0
	pivot.add_child(clt)
	# ---- 6 brass burning urns around the base ring ----
	for i in 6:
		var ang: float = float(i) / 6.0 * TAU
		var ux: float = cos(ang) * 4.20
		var uz: float = sin(ang) * 4.20
		# Urn body — wide bowl
		var urn: MeshInstance3D = MeshInstance3D.new()
		var urm: SphereMesh = SphereMesh.new()
		urm.radius = 0.32
		urm.height = 0.55
		urn.mesh = urm
		urn.material_override = brass_mat
		urn.position = Vector3(ux, 0.30, uz)
		urn.scale = Vector3(1.0, 0.85, 1.0)
		pivot.add_child(urn)
		# Urn neck — small cylinder
		var neck: MeshInstance3D = MeshInstance3D.new()
		var nmm: CylinderMesh = CylinderMesh.new()
		nmm.top_radius = 0.22
		nmm.bottom_radius = 0.20
		nmm.height = 0.18
		neck.mesh = nmm
		neck.material_override = brass_mat
		neck.position = Vector3(ux, 0.62, uz)
		pivot.add_child(neck)
		# Urn flame
		var flame: MeshInstance3D = MeshInstance3D.new()
		var flm: SphereMesh = SphereMesh.new()
		flm.radius = 0.20
		flm.height = 0.42
		flame.mesh = flm
		flame.material_override = flame_mat
		flame.position = Vector3(ux, 0.85, uz)
		pivot.add_child(flame)
		# OmniLight
		var lt: OmniLight3D = OmniLight3D.new()
		lt.position = Vector3(ux, 0.85, uz)
		lt.light_color = Color(1.0, 0.55, 0.15)
		lt.light_energy = 1.8
		lt.omni_range = 5.0
		pivot.add_child(lt)
		# Rising ember motes
		var motes: GPUParticles3D = GPUParticles3D.new()
		motes.position = Vector3(ux, 1.00, uz)
		motes.amount = 14
		motes.lifetime = 2.0
		var pmat: ParticleProcessMaterial = ParticleProcessMaterial.new()
		pmat.direction = Vector3(0, 1, 0)
		pmat.spread = 14.0
		pmat.initial_velocity_min = 0.4
		pmat.initial_velocity_max = 0.9
		pmat.gravity = Vector3(0, 0.3, 0)
		pmat.scale_min = 0.04
		pmat.scale_max = 0.08
		pmat.color = Color(1.0, 0.55, 0.10, 1.0)
		motes.process_material = pmat
		var psmesh: SphereMesh = SphereMesh.new()
		psmesh.radius = 0.03
		psmesh.height = 0.06
		motes.draw_pass_1 = psmesh
		pivot.add_child(motes)
	# Crown flame slow scale pulse (looks like the eternal flame breathing)
	var crown_pulse: Tween = pivot.create_tween().set_loops()
	crown_pulse.tween_property(crown, "scale", Vector3(1.20, 1.30, 1.20), 1.6).set_ease(Tween.EASE_IN_OUT)
	crown_pulse.tween_property(crown, "scale", Vector3(0.95, 0.90, 0.95), 1.6).set_ease(Tween.EASE_IN_OUT)
	# Rune pulse — slow breathe
	var rpulse: Tween = pivot.create_tween().set_loops()
	rpulse.tween_property(rune_mat, "emission_energy_multiplier", 8.0, 2.0).set_ease(Tween.EASE_IN_OUT)
	rpulse.tween_property(rune_mat, "emission_energy_multiplier", 4.5, 2.0).set_ease(Tween.EASE_IN_OUT)
	# Urn flame flicker
	var fpulse: Tween = pivot.create_tween().set_loops()
	fpulse.tween_property(flame_mat, "emission_energy_multiplier", 10.0, 0.4).set_ease(Tween.EASE_IN_OUT)
	fpulse.tween_property(flame_mat, "emission_energy_multiplier", 7.0, 0.4).set_ease(Tween.EASE_IN_OUT)


func _build_d9_memorial_keeper_ash_npc(town: Node) -> void:
	## Epic-9 T76: Memorial Keeper Ash — solemn hooded NPC tending the
	## forge memorial obelisk's eternal flame. Long ash-grey hooded robe,
	## brass hand censer (chained burning bowl) held forward, brass
	## prayer beads at the waist, and a slow bowed-head sway.
	var slots: Node3D = town.get_node_or_null("NPCSlots") as Node3D
	if slots == null:
		return
	var slot: Marker3D = Marker3D.new()
	slot.name = "D9MemorialKeeperAshSlot"
	# Stand just outside the memorial base ring (memorial at -18, 14)
	slot.position = Vector3(D9_CENTER.x - 18, 0, 19)
	slots.add_child(slot)
	var npc_scene: PackedScene = load("res://scenes/entities/npcs/VillagerR3.tscn") as PackedScene
	if npc_scene == null:
		return
	var npc: Node3D = npc_scene.instantiate() as Node3D
	npc.name = "D9MemorialKeeperAsh"
	if "npc_name" in npc:
		npc.set("npc_name", "Memorial Keeper Ash")
	if "npc_id" in npc:
		npc.set("npc_id", "d9_memorial_keeper_ash")
	# Face toward the obelisk (-Z direction)
	npc.rotation.y = PI
	slot.add_child(npc)
	# ---- Ash-grey hooded robe (long box) ----
	var robe_mat: StandardMaterial3D = StandardMaterial3D.new()
	robe_mat.albedo_color = Color(0.30, 0.28, 0.27)
	robe_mat.roughness = 0.92
	robe_mat.metallic = 0.05
	robe_mat.emission_enabled = true
	robe_mat.emission = Color(0.50, 0.20, 0.05)
	robe_mat.emission_energy_multiplier = 0.12
	var robe: MeshInstance3D = MeshInstance3D.new()
	var rmesh: BoxMesh = BoxMesh.new()
	rmesh.size = Vector3(0.95, 1.85, 0.55)
	robe.mesh = rmesh
	robe.material_override = robe_mat
	robe.position = Vector3(0, 0.95, 0)
	npc.add_child(robe)
	# Hood — wider rounded box on top of the robe shoulders
	var hood: MeshInstance3D = MeshInstance3D.new()
	var hmesh: SphereMesh = SphereMesh.new()
	hmesh.radius = 0.40
	hmesh.height = 0.65
	hood.mesh = hmesh
	hood.material_override = robe_mat
	hood.position = Vector3(0, 1.95, 0)
	hood.scale = Vector3(1.0, 0.85, 1.0)
	npc.add_child(hood)
	# Hood inner shadow — black box just inside the hood opening
	var shadow_mat: StandardMaterial3D = StandardMaterial3D.new()
	shadow_mat.albedo_color = Color(0.02, 0.02, 0.02)
	shadow_mat.roughness = 1.0
	shadow_mat.metallic = 0.0
	var shadow: MeshInstance3D = MeshInstance3D.new()
	var shm: BoxMesh = BoxMesh.new()
	shm.size = Vector3(0.40, 0.30, 0.04)
	shadow.mesh = shm
	shadow.material_override = shadow_mat
	shadow.position = Vector3(0, 1.92, -0.34)
	npc.add_child(shadow)
	# Two glowing ember eye-dots inside the hood
	var ember_mat: StandardMaterial3D = StandardMaterial3D.new()
	ember_mat.albedo_color = Color(1.0, 0.55, 0.10)
	ember_mat.emission_enabled = true
	ember_mat.emission = Color(1.0, 0.55, 0.10)
	ember_mat.emission_energy_multiplier = 6.0
	ember_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for ex in [-0.10, 0.10]:
		var eye: MeshInstance3D = MeshInstance3D.new()
		var em: SphereMesh = SphereMesh.new()
		em.radius = 0.04
		em.height = 0.08
		eye.mesh = em
		eye.material_override = ember_mat
		eye.position = Vector3(ex, 1.95, -0.36)
		npc.add_child(eye)
	# Brass hand censer — chained burning bowl held in front
	var brass_mat: StandardMaterial3D = StandardMaterial3D.new()
	brass_mat.albedo_color = Color(0.85, 0.55, 0.18)
	brass_mat.metallic = 0.95
	brass_mat.roughness = 0.30
	brass_mat.emission_enabled = true
	brass_mat.emission = Color(1.0, 0.50, 0.10)
	brass_mat.emission_energy_multiplier = 0.55
	# Censer pivot so we can sway it
	var censer_pivot: Node3D = Node3D.new()
	censer_pivot.position = Vector3(0, 1.40, -0.45)
	npc.add_child(censer_pivot)
	# Chain — thin cylinder hanging from the wrist
	var chain: MeshInstance3D = MeshInstance3D.new()
	var chm: CylinderMesh = CylinderMesh.new()
	chm.top_radius = 0.012
	chm.bottom_radius = 0.012
	chm.height = 0.40
	chain.mesh = chm
	chain.material_override = brass_mat
	chain.position = Vector3(0, -0.20, 0)
	censer_pivot.add_child(chain)
	# Censer bowl
	var bowl: MeshInstance3D = MeshInstance3D.new()
	var bm: SphereMesh = SphereMesh.new()
	bm.radius = 0.14
	bm.height = 0.22
	bowl.mesh = bm
	bowl.material_override = brass_mat
	bowl.position = Vector3(0, -0.45, 0)
	bowl.scale = Vector3(1.0, 0.65, 1.0)
	censer_pivot.add_child(bowl)
	# Censer flame
	var flame_mat: StandardMaterial3D = StandardMaterial3D.new()
	flame_mat.albedo_color = Color(1.0, 0.65, 0.20)
	flame_mat.emission_enabled = true
	flame_mat.emission = Color(1.0, 0.55, 0.10)
	flame_mat.emission_energy_multiplier = 8.0
	flame_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var flame: MeshInstance3D = MeshInstance3D.new()
	var flm: SphereMesh = SphereMesh.new()
	flm.radius = 0.10
	flm.height = 0.20
	flame.mesh = flm
	flame.material_override = flame_mat
	flame.position = Vector3(0, -0.32, 0)
	censer_pivot.add_child(flame)
	# Censer light
	var clt: OmniLight3D = OmniLight3D.new()
	clt.position = Vector3(0, -0.32, 0)
	clt.light_color = Color(1.0, 0.55, 0.15)
	clt.light_energy = 1.6
	clt.omni_range = 3.5
	censer_pivot.add_child(clt)
	# Censer rising smoke motes
	var motes: GPUParticles3D = GPUParticles3D.new()
	motes.position = Vector3(0, -0.20, 0)
	motes.amount = 12
	motes.lifetime = 1.8
	var pmat: ParticleProcessMaterial = ParticleProcessMaterial.new()
	pmat.direction = Vector3(0, 1, 0)
	pmat.spread = 12.0
	pmat.initial_velocity_min = 0.4
	pmat.initial_velocity_max = 0.8
	pmat.gravity = Vector3(0, 0.3, 0)
	pmat.scale_min = 0.04
	pmat.scale_max = 0.08
	pmat.color = Color(0.85, 0.50, 0.20, 0.85)
	motes.process_material = pmat
	var psmesh: SphereMesh = SphereMesh.new()
	psmesh.radius = 0.04
	psmesh.height = 0.08
	motes.draw_pass_1 = psmesh
	censer_pivot.add_child(motes)
	# Brass prayer beads at the waist — 5 small spheres in a hanging arc
	for i in 5:
		var bead: MeshInstance3D = MeshInstance3D.new()
		var bsm: SphereMesh = SphereMesh.new()
		bsm.radius = 0.04
		bsm.height = 0.08
		bead.mesh = bsm
		bead.material_override = brass_mat
		bead.position = Vector3(-0.45 + float(i) * 0.08, 1.05 - float(i) * 0.04, -0.30)
		npc.add_child(bead)
	# Body sway — slow bowed-head left/right sway
	var sway: Tween = npc.create_tween().set_loops()
	sway.tween_property(npc, "rotation:z", 0.05, 2.0).set_ease(Tween.EASE_IN_OUT)
	sway.tween_property(npc, "rotation:z", -0.05, 2.0).set_ease(Tween.EASE_IN_OUT)
	# Censer slow sway
	var cswing: Tween = npc.create_tween().set_loops()
	cswing.tween_property(censer_pivot, "rotation:z", 0.18, 1.6).set_ease(Tween.EASE_IN_OUT)
	cswing.tween_property(censer_pivot, "rotation:z", -0.18, 1.6).set_ease(Tween.EASE_IN_OUT)
	# Eye + censer flame pulse
	var epulse: Tween = npc.create_tween().set_loops()
	epulse.tween_property(ember_mat, "emission_energy_multiplier", 8.0, 1.6).set_ease(Tween.EASE_IN_OUT)
	epulse.tween_property(ember_mat, "emission_energy_multiplier", 4.5, 1.6).set_ease(Tween.EASE_IN_OUT)


func _build_d9_collapsed_skyforge_ruin(geom: Node) -> void:
	## Epic-9 T77: collapsed sky-forge ironworks ruin in D9's NW quadrant.
	## Half-fallen iron scaffold (4 standing posts at varying heights, 2
	## bowed cross-girders), a snapped crane arm angled into the ground,
	## a cracked anvil block, scattered fallen girders, and a smoldering
	## ember pile at the impact site. Tells a story of an old collapse.
	var pivot: Node3D = Node3D.new()
	pivot.name = "D9_CollapsedSkyforgeRuin"
	pivot.position = D9_CENTER + Vector3(-22, 0, -16)
	geom.add_child(pivot)
	# Materials
	var iron_mat: StandardMaterial3D = StandardMaterial3D.new()
	iron_mat.albedo_color = Color(0.18, 0.14, 0.11)
	iron_mat.metallic = 0.85
	iron_mat.roughness = 0.50
	iron_mat.emission_enabled = true
	iron_mat.emission = Color(0.65, 0.20, 0.05)
	iron_mat.emission_energy_multiplier = 0.25
	var rust_mat: StandardMaterial3D = StandardMaterial3D.new()
	rust_mat.albedo_color = Color(0.40, 0.18, 0.08)
	rust_mat.metallic = 0.35
	rust_mat.roughness = 0.85
	rust_mat.emission_enabled = true
	rust_mat.emission = Color(0.85, 0.25, 0.05)
	rust_mat.emission_energy_multiplier = 0.30
	var ember_mat: StandardMaterial3D = StandardMaterial3D.new()
	ember_mat.albedo_color = Color(1.0, 0.55, 0.10)
	ember_mat.emission_enabled = true
	ember_mat.emission = Color(1.0, 0.55, 0.10)
	ember_mat.emission_energy_multiplier = 6.0
	ember_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	# ---- 4 standing scaffold posts at varying heights (one snapped) ----
	var post_data: Array = [
		{"pos": Vector3(-3.5, 0, -3.0), "h": 5.50, "tilt": 0.00},
		{"pos": Vector3(3.5, 0, -3.0), "h": 4.20, "tilt": 0.05},
		{"pos": Vector3(-3.5, 0, 3.0), "h": 2.80, "tilt": -0.12},
		{"pos": Vector3(3.5, 0, 3.0), "h": 1.50, "tilt": 0.20},
	]
	for pd in post_data:
		var pp: Vector3 = pd["pos"]
		var h: float = pd["h"]
		var tilt: float = pd["tilt"]
		var post: MeshInstance3D = MeshInstance3D.new()
		var pm: BoxMesh = BoxMesh.new()
		pm.size = Vector3(0.40, h, 0.40)
		post.mesh = pm
		post.material_override = rust_mat
		post.position = pp + Vector3(0, h * 0.5, 0)
		post.rotation.z = tilt
		pivot.add_child(post)
		# Post collision
		var sb: StaticBody3D = StaticBody3D.new()
		sb.position = pp + Vector3(0, h * 0.5, 0)
		var cs: CollisionShape3D = CollisionShape3D.new()
		var bsh: BoxShape3D = BoxShape3D.new()
		bsh.size = Vector3(0.40, h, 0.40)
		cs.shape = bsh
		sb.add_child(cs)
		pivot.add_child(sb)
	# ---- 2 bowed cross-girders connecting top corners ----
	# Front girder — between the 2 tallest posts (left/right back)
	var girder_a: MeshInstance3D = MeshInstance3D.new()
	var gam: BoxMesh = BoxMesh.new()
	gam.size = Vector3(7.20, 0.30, 0.30)
	girder_a.mesh = gam
	girder_a.material_override = rust_mat
	girder_a.position = Vector3(0, 4.80, -3.00)
	girder_a.rotation.z = -0.05
	pivot.add_child(girder_a)
	# Side girder — between left back tall post and left front shorter (broken/sagging)
	var girder_b: MeshInstance3D = MeshInstance3D.new()
	var gbm: BoxMesh = BoxMesh.new()
	gbm.size = Vector3(0.30, 0.30, 6.00)
	girder_b.mesh = gbm
	girder_b.material_override = rust_mat
	girder_b.position = Vector3(-3.50, 4.10, 0)
	girder_b.rotation.x = -0.18
	pivot.add_child(girder_b)
	# ---- Snapped crane arm angled into the ground ----
	var crane_arm: MeshInstance3D = MeshInstance3D.new()
	var cam: BoxMesh = BoxMesh.new()
	cam.size = Vector3(0.45, 5.50, 0.55)
	crane_arm.mesh = cam
	crane_arm.material_override = rust_mat
	crane_arm.position = Vector3(-1.20, 1.85, -1.20)
	crane_arm.rotation = Vector3(0.85, 0.6, 0.30)
	pivot.add_child(crane_arm)
	# Crane arm collision
	var arm_sb: StaticBody3D = StaticBody3D.new()
	arm_sb.position = Vector3(-1.20, 1.85, -1.20)
	arm_sb.rotation = Vector3(0.85, 0.6, 0.30)
	var arm_cs: CollisionShape3D = CollisionShape3D.new()
	var arm_bsh: BoxShape3D = BoxShape3D.new()
	arm_bsh.size = Vector3(0.45, 5.50, 0.55)
	arm_cs.shape = arm_bsh
	arm_sb.add_child(arm_cs)
	pivot.add_child(arm_sb)
	# Crane hook chain (cylinder) hanging from arm tip
	var chain: MeshInstance3D = MeshInstance3D.new()
	var chm: CylinderMesh = CylinderMesh.new()
	chm.top_radius = 0.05
	chm.bottom_radius = 0.05
	chm.height = 1.20
	chain.mesh = chm
	chain.material_override = iron_mat
	chain.position = Vector3(-2.40, 4.20, -3.30)
	pivot.add_child(chain)
	# Hook ring at the chain bottom
	var hook: MeshInstance3D = MeshInstance3D.new()
	var hkm: TorusMesh = TorusMesh.new()
	hkm.inner_radius = 0.18
	hkm.outer_radius = 0.30
	hook.mesh = hkm
	hook.material_override = iron_mat
	hook.position = Vector3(-2.40, 3.55, -3.30)
	pivot.add_child(hook)
	# ---- Cracked anvil block at impact site ----
	var anvil: MeshInstance3D = MeshInstance3D.new()
	var anm: BoxMesh = BoxMesh.new()
	anm.size = Vector3(1.40, 0.85, 0.85)
	anvil.mesh = anm
	anvil.material_override = iron_mat
	anvil.position = Vector3(0.5, 0.42, -0.5)
	anvil.rotation.z = 0.18
	pivot.add_child(anvil)
	# Anvil collision
	var anv_sb: StaticBody3D = StaticBody3D.new()
	anv_sb.position = Vector3(0.5, 0.42, -0.5)
	anv_sb.rotation.z = 0.18
	var anv_cs: CollisionShape3D = CollisionShape3D.new()
	var anv_bsh: BoxShape3D = BoxShape3D.new()
	anv_bsh.size = Vector3(1.40, 0.85, 0.85)
	anv_cs.shape = anv_bsh
	anv_sb.add_child(anv_cs)
	pivot.add_child(anv_sb)
	# Anvil glowing crack — thin amber stripe across the top
	var anvil_crack: MeshInstance3D = MeshInstance3D.new()
	var ackm: BoxMesh = BoxMesh.new()
	ackm.size = Vector3(1.30, 0.05, 0.10)
	anvil_crack.mesh = ackm
	anvil_crack.material_override = ember_mat
	anvil_crack.position = Vector3(0.5, 0.86, -0.5)
	anvil_crack.rotation.z = 0.18
	pivot.add_child(anvil_crack)
	# ---- 5 scattered fallen girders (boxes lying around) ----
	var fallen_data: Array = [
		{"pos": Vector3(2.50, 0.20, 1.20), "size": Vector3(3.20, 0.25, 0.30), "rot": Vector3(0, 0.40, 0)},
		{"pos": Vector3(-2.20, 0.20, -1.50), "size": Vector3(2.40, 0.22, 0.28), "rot": Vector3(0, -0.80, 0.05)},
		{"pos": Vector3(0.0, 0.18, 2.40), "size": Vector3(2.80, 0.22, 0.28), "rot": Vector3(0, 1.20, 0)},
		{"pos": Vector3(-1.50, 0.20, 1.80), "size": Vector3(1.80, 0.20, 0.25), "rot": Vector3(0, 0.20, 0)},
		{"pos": Vector3(2.20, 0.20, -2.50), "size": Vector3(2.20, 0.22, 0.28), "rot": Vector3(0, -0.30, -0.10)},
	]
	for fd in fallen_data:
		var f: MeshInstance3D = MeshInstance3D.new()
		var fm: BoxMesh = BoxMesh.new()
		fm.size = fd["size"]
		f.mesh = fm
		f.material_override = rust_mat
		f.position = fd["pos"]
		f.rotation = fd["rot"]
		pivot.add_child(f)
	# ---- Smoldering ember pile at the impact site ----
	# Pile of small dark rocks
	var rock_mat: StandardMaterial3D = StandardMaterial3D.new()
	rock_mat.albedo_color = Color(0.10, 0.08, 0.07)
	rock_mat.metallic = 0.20
	rock_mat.roughness = 0.90
	rock_mat.emission_enabled = true
	rock_mat.emission = Color(0.55, 0.18, 0.05)
	rock_mat.emission_energy_multiplier = 0.30
	var pile_offsets: Array = [
		Vector3(0.0, 0.10, 0.30), Vector3(0.30, 0.12, 0.10),
		Vector3(-0.20, 0.10, -0.10), Vector3(0.10, 0.18, -0.30),
		Vector3(-0.30, 0.14, 0.20),
	]
	for po in pile_offsets:
		var rock: MeshInstance3D = MeshInstance3D.new()
		var rmm: SphereMesh = SphereMesh.new()
		rmm.radius = 0.18
		rmm.height = 0.34
		rock.mesh = rmm
		rock.material_override = rock_mat
		rock.position = Vector3(0.0, 0, 1.20) + po
		pivot.add_child(rock)
	# Glowing ember cluster on top of the pile
	var ember_cluster: MeshInstance3D = MeshInstance3D.new()
	var ecm: SphereMesh = SphereMesh.new()
	ecm.radius = 0.22
	ecm.height = 0.40
	ember_cluster.mesh = ecm
	ember_cluster.material_override = ember_mat
	ember_cluster.position = Vector3(0.0, 0.30, 1.20)
	pivot.add_child(ember_cluster)
	# OmniLight for the smoldering pile
	var lt: OmniLight3D = OmniLight3D.new()
	lt.position = Vector3(0.0, 0.45, 1.20)
	lt.light_color = Color(1.0, 0.55, 0.15)
	lt.light_energy = 2.4
	lt.omni_range = 6.0
	pivot.add_child(lt)
	# Ember mote particles rising from the pile
	var motes: GPUParticles3D = GPUParticles3D.new()
	motes.position = Vector3(0.0, 0.55, 1.20)
	motes.amount = 24
	motes.lifetime = 2.4
	var pmat: ParticleProcessMaterial = ParticleProcessMaterial.new()
	pmat.direction = Vector3(0, 1, 0)
	pmat.spread = 18.0
	pmat.initial_velocity_min = 0.5
	pmat.initial_velocity_max = 1.0
	pmat.gravity = Vector3(0, 0.3, 0)
	pmat.scale_min = 0.05
	pmat.scale_max = 0.10
	pmat.color = Color(1.0, 0.55, 0.10, 1.0)
	motes.process_material = pmat
	var psmesh: SphereMesh = SphereMesh.new()
	psmesh.radius = 0.04
	psmesh.height = 0.08
	motes.draw_pass_1 = psmesh
	pivot.add_child(motes)
	# Smoke drift particles (darker, larger, slower)
	var smoke: GPUParticles3D = GPUParticles3D.new()
	smoke.position = Vector3(0.0, 0.80, 1.20)
	smoke.amount = 18
	smoke.lifetime = 4.0
	var smat: ParticleProcessMaterial = ParticleProcessMaterial.new()
	smat.direction = Vector3(0, 1, 0)
	smat.spread = 25.0
	smat.initial_velocity_min = 0.5
	smat.initial_velocity_max = 0.9
	smat.gravity = Vector3(0, 0.4, 0)
	smat.scale_min = 0.20
	smat.scale_max = 0.40
	smat.color = Color(0.30, 0.25, 0.20, 0.65)
	smoke.process_material = smat
	var smkm: SphereMesh = SphereMesh.new()
	smkm.radius = 0.15
	smkm.height = 0.30
	smoke.draw_pass_1 = smkm
	pivot.add_child(smoke)
	# Ember + crack pulse
	var epulse2: Tween = pivot.create_tween().set_loops()
	epulse2.tween_property(ember_mat, "emission_energy_multiplier", 8.0, 1.4).set_ease(Tween.EASE_IN_OUT)
	epulse2.tween_property(ember_mat, "emission_energy_multiplier", 4.5, 1.4).set_ease(Tween.EASE_IN_OUT)
	# Crane arm subtle creak — tiny rotation wobble
	var creak: Tween = pivot.create_tween().set_loops()
	creak.tween_property(crane_arm, "rotation:z", 0.32, 2.6).set_ease(Tween.EASE_IN_OUT)
	creak.tween_property(crane_arm, "rotation:z", 0.28, 2.6).set_ease(Tween.EASE_IN_OUT)


func _build_d9_salvager_rax_npc(town: Node) -> void:
	## Epic-9 T77b/T78: Salvager Rax — scrapper NPC working the collapsed
	## sky-forge ironworks ruin. Patchwork leather coat + scrap-iron
	## shoulder plate, sack of salvaged ingots over one shoulder, head
	## torch lamp on a brass headband, prybar in hand. Bent forward
	## scavenging pose with a periodic dig motion.
	var slots: Node3D = town.get_node_or_null("NPCSlots") as Node3D
	if slots == null:
		return
	var slot: Marker3D = Marker3D.new()
	slot.name = "D9SalvagerRaxSlot"
	# Stand inside the ruin, near the cracked anvil (ruin at -22, -16; anvil at +0.5, -0.5)
	slot.position = Vector3(D9_CENTER.x - 21, 0, -16.5)
	slots.add_child(slot)
	var npc_scene: PackedScene = load("res://scenes/entities/npcs/VillagerR3.tscn") as PackedScene
	if npc_scene == null:
		return
	var npc: Node3D = npc_scene.instantiate() as Node3D
	npc.name = "D9SalvagerRax"
	if "npc_name" in npc:
		npc.set("npc_name", "Salvager Rax")
	if "npc_id" in npc:
		npc.set("npc_id", "d9_salvager_rax")
	# Face into the ruin
	npc.rotation.y = -PI / 2.0
	# Bent-forward scavenging pose
	npc.rotation.x = 0.18
	slot.add_child(npc)
	# ---- Patchwork leather coat ----
	var coat_mat: StandardMaterial3D = StandardMaterial3D.new()
	coat_mat.albedo_color = Color(0.30, 0.18, 0.10)
	coat_mat.roughness = 0.92
	coat_mat.metallic = 0.10
	coat_mat.emission_enabled = true
	coat_mat.emission = Color(0.55, 0.18, 0.05)
	coat_mat.emission_energy_multiplier = 0.18
	var coat: MeshInstance3D = MeshInstance3D.new()
	var cmesh: BoxMesh = BoxMesh.new()
	cmesh.size = Vector3(1.00, 1.30, 0.55)
	coat.mesh = cmesh
	coat.material_override = coat_mat
	coat.position = Vector3(0, 1.00, 0)
	npc.add_child(coat)
	# 3 patchwork leather "patch" boxes on the coat (different shades)
	var patch_specs: Array = [
		{"pos": Vector3(-0.30, 1.20, -0.30), "size": Vector3(0.30, 0.25, 0.04), "color": Color(0.40, 0.22, 0.10)},
		{"pos": Vector3(0.25, 0.95, -0.30), "size": Vector3(0.25, 0.30, 0.04), "color": Color(0.22, 0.13, 0.06)},
		{"pos": Vector3(0.05, 0.65, -0.30), "size": Vector3(0.40, 0.18, 0.04), "color": Color(0.35, 0.20, 0.08)},
	]
	for p in patch_specs:
		var patch_mat: StandardMaterial3D = StandardMaterial3D.new()
		patch_mat.albedo_color = p["color"]
		patch_mat.roughness = 0.90
		patch_mat.metallic = 0.10
		var patch: MeshInstance3D = MeshInstance3D.new()
		var pmm: BoxMesh = BoxMesh.new()
		pmm.size = p["size"]
		patch.mesh = pmm
		patch.material_override = patch_mat
		patch.position = p["pos"]
		npc.add_child(patch)
	# ---- Scrap-iron shoulder plate (left shoulder) ----
	var iron_mat: StandardMaterial3D = StandardMaterial3D.new()
	iron_mat.albedo_color = Color(0.18, 0.14, 0.11)
	iron_mat.metallic = 0.85
	iron_mat.roughness = 0.50
	iron_mat.emission_enabled = true
	iron_mat.emission = Color(0.85, 0.25, 0.05)
	iron_mat.emission_energy_multiplier = 0.30
	var pauldron: MeshInstance3D = MeshInstance3D.new()
	var paum: SphereMesh = SphereMesh.new()
	paum.radius = 0.22
	paum.height = 0.42
	pauldron.mesh = paum
	pauldron.material_override = iron_mat
	pauldron.position = Vector3(-0.55, 1.55, 0)
	pauldron.scale = Vector3(1.0, 0.55, 1.0)
	npc.add_child(pauldron)
	# Scrap rivets on the pauldron (3 small brass dots)
	var brass_mat: StandardMaterial3D = StandardMaterial3D.new()
	brass_mat.albedo_color = Color(0.85, 0.55, 0.18)
	brass_mat.metallic = 0.95
	brass_mat.roughness = 0.30
	brass_mat.emission_enabled = true
	brass_mat.emission = Color(1.0, 0.50, 0.10)
	brass_mat.emission_energy_multiplier = 0.55
	for rx in [-0.65, -0.55, -0.45]:
		var rv: MeshInstance3D = MeshInstance3D.new()
		var rvm: SphereMesh = SphereMesh.new()
		rvm.radius = 0.04
		rvm.height = 0.08
		rv.mesh = rvm
		rv.material_override = brass_mat
		rv.position = Vector3(rx, 1.62, 0.18)
		npc.add_child(rv)
	# ---- Sack of salvaged ingots over the right shoulder ----
	var sack_mat: StandardMaterial3D = StandardMaterial3D.new()
	sack_mat.albedo_color = Color(0.32, 0.20, 0.12)
	sack_mat.roughness = 0.95
	sack_mat.metallic = 0.05
	var sack: MeshInstance3D = MeshInstance3D.new()
	var sm: SphereMesh = SphereMesh.new()
	sm.radius = 0.30
	sm.height = 0.55
	sack.mesh = sm
	sack.material_override = sack_mat
	sack.position = Vector3(0.50, 1.40, 0.20)
	sack.scale = Vector3(0.95, 1.20, 0.85)
	npc.add_child(sack)
	# Sack rope strap across his chest
	var rope: MeshInstance3D = MeshInstance3D.new()
	var rope_m: BoxMesh = BoxMesh.new()
	rope_m.size = Vector3(0.04, 0.95, 0.04)
	rope.mesh = rope_m
	rope.material_override = sack_mat
	rope.position = Vector3(0.10, 1.30, -0.28)
	rope.rotation.z = 0.40
	npc.add_child(rope)
	# 2 glowing ingot tips poking out of the sack
	var ingot_mat: StandardMaterial3D = StandardMaterial3D.new()
	ingot_mat.albedo_color = Color(1.0, 0.55, 0.10)
	ingot_mat.emission_enabled = true
	ingot_mat.emission = Color(1.0, 0.55, 0.10)
	ingot_mat.emission_energy_multiplier = 5.0
	ingot_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for ix in [-0.05, 0.10]:
		var ing: MeshInstance3D = MeshInstance3D.new()
		var im: BoxMesh = BoxMesh.new()
		im.size = Vector3(0.10, 0.18, 0.10)
		ing.mesh = im
		ing.material_override = ingot_mat
		ing.position = Vector3(0.50 + ix, 1.65, 0.22)
		npc.add_child(ing)
	# ---- Brass headband + head torch lamp ----
	var headband: MeshInstance3D = MeshInstance3D.new()
	var hbm: TorusMesh = TorusMesh.new()
	hbm.inner_radius = 0.30
	hbm.outer_radius = 0.36
	headband.mesh = hbm
	headband.material_override = brass_mat
	headband.position = Vector3(0, 1.85, 0)
	headband.rotation.x = PI / 2.0
	npc.add_child(headband)
	# Head lamp — small brass cylinder + bright unshaded amber lens
	var lamp_housing: MeshInstance3D = MeshInstance3D.new()
	var lhm: CylinderMesh = CylinderMesh.new()
	lhm.top_radius = 0.10
	lhm.bottom_radius = 0.10
	lhm.height = 0.12
	lamp_housing.mesh = lhm
	lamp_housing.material_override = brass_mat
	lamp_housing.position = Vector3(0, 1.92, -0.30)
	lamp_housing.rotation.x = PI / 2.0
	npc.add_child(lamp_housing)
	var lamp_lens: MeshInstance3D = MeshInstance3D.new()
	var llm: SphereMesh = SphereMesh.new()
	llm.radius = 0.09
	llm.height = 0.18
	lamp_lens.mesh = llm
	var lamp_mat: StandardMaterial3D = StandardMaterial3D.new()
	lamp_mat.albedo_color = Color(1.0, 0.95, 0.55)
	lamp_mat.emission_enabled = true
	lamp_mat.emission = Color(1.0, 0.95, 0.60)
	lamp_mat.emission_energy_multiplier = 9.0
	lamp_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	lamp_lens.material_override = lamp_mat
	lamp_lens.position = Vector3(0, 1.92, -0.40)
	npc.add_child(lamp_lens)
	# Head lamp OmniLight
	var hlt: OmniLight3D = OmniLight3D.new()
	hlt.position = Vector3(0, 1.92, -0.45)
	hlt.light_color = Color(1.0, 0.85, 0.45)
	hlt.light_energy = 2.6
	hlt.omni_range = 5.5
	npc.add_child(hlt)
	# ---- Prybar in hand — long iron bar with hooked end ----
	# Prybar pivot for dig animation
	var prybar_pivot: Node3D = Node3D.new()
	prybar_pivot.position = Vector3(0.40, 1.20, -0.35)
	npc.add_child(prybar_pivot)
	var bar_shaft: MeshInstance3D = MeshInstance3D.new()
	var bsm: CylinderMesh = CylinderMesh.new()
	bsm.top_radius = 0.04
	bsm.bottom_radius = 0.05
	bsm.height = 1.05
	bar_shaft.mesh = bsm
	bar_shaft.material_override = iron_mat
	bar_shaft.position = Vector3(0, -0.45, 0)
	prybar_pivot.add_child(bar_shaft)
	# Hooked tip
	var bar_hook: MeshInstance3D = MeshInstance3D.new()
	var bhm: BoxMesh = BoxMesh.new()
	bhm.size = Vector3(0.20, 0.10, 0.06)
	bar_hook.mesh = bhm
	bar_hook.material_override = iron_mat
	bar_hook.position = Vector3(0.10, -0.95, 0)
	bar_hook.rotation.z = -0.40
	prybar_pivot.add_child(bar_hook)
	# Prybar dig tween — quick down-and-up like he's prying
	var dig: Tween = npc.create_tween().set_loops()
	dig.tween_property(prybar_pivot, "rotation:x", 0.45, 0.55).set_ease(Tween.EASE_OUT)
	dig.tween_property(prybar_pivot, "rotation:x", -0.05, 0.30).set_ease(Tween.EASE_IN)
	dig.tween_property(prybar_pivot, "rotation:x", -0.05, 0.50)
	# Ingot pulse
	var ipulse: Tween = npc.create_tween().set_loops()
	ipulse.tween_property(ingot_mat, "emission_energy_multiplier", 7.0, 1.4).set_ease(Tween.EASE_IN_OUT)
	ipulse.tween_property(ingot_mat, "emission_energy_multiplier", 4.5, 1.4).set_ease(Tween.EASE_IN_OUT)
	# Lamp slow flicker
	var lflick: Tween = npc.create_tween().set_loops()
	lflick.tween_property(lamp_mat, "emission_energy_multiplier", 11.0, 0.45).set_ease(Tween.EASE_IN_OUT)
	lflick.tween_property(lamp_mat, "emission_energy_multiplier", 8.0, 0.45).set_ease(Tween.EASE_IN_OUT)


func _build_d9_lava_brook(geom: Node) -> void:
	## Epic-9 T79: winding lava brook connecting the molten geyser (NE)
	## to the cascade pool (SE) area. 8 chained lava segments laid along
	## a curve, basalt rim borders on each side of every segment, 4
	## ember mote emitters, 4 OmniLights along the channel, and a slow
	## emission pulse to make the lava feel like it's flowing.
	var pivot: Node3D = Node3D.new()
	pivot.name = "D9_LavaBrook"
	# Anchor at midpoint between geyser (60,-10) and cascade ferry (50,5)
	pivot.position = D9_CENTER + Vector3(55, 0.05, -2)
	geom.add_child(pivot)
	# Materials
	var lava_mat: StandardMaterial3D = StandardMaterial3D.new()
	lava_mat.albedo_color = Color(1.0, 0.45, 0.05)
	lava_mat.emission_enabled = true
	lava_mat.emission = Color(1.0, 0.45, 0.05)
	lava_mat.emission_energy_multiplier = 6.0
	lava_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var basalt_mat: StandardMaterial3D = StandardMaterial3D.new()
	basalt_mat.albedo_color = Color(0.10, 0.08, 0.07)
	basalt_mat.metallic = 0.20
	basalt_mat.roughness = 0.90
	basalt_mat.emission_enabled = true
	basalt_mat.emission = Color(0.55, 0.18, 0.05)
	basalt_mat.emission_energy_multiplier = 0.30
	# 8 segments laid along a curving path from NE → SE
	# Each segment defined by relative offset from pivot (running -X, +Z)
	var seg_offsets: Array = [
		Vector3(5.5, 0, -7.0),
		Vector3(4.0, 0, -5.0),
		Vector3(2.5, 0, -3.0),
		Vector3(1.0, 0, -1.0),
		Vector3(-0.5, 0, 1.0),
		Vector3(-2.0, 0, 3.0),
		Vector3(-3.5, 0, 5.0),
		Vector3(-5.0, 0, 7.0),
	]
	# Each segment is a flat box rotated to face the next segment
	for i in seg_offsets.size():
		var p: Vector3 = seg_offsets[i]
		# Determine angle by looking ahead to the next segment
		var next_p: Vector3
		if i < seg_offsets.size() - 1:
			next_p = seg_offsets[i + 1]
		else:
			next_p = p + (p - seg_offsets[i - 1])
		var dir: Vector3 = next_p - p
		var ang: float = atan2(dir.x, dir.z)
		# Lava channel slab
		var seg_len: float = dir.length() + 0.20
		var slab: MeshInstance3D = MeshInstance3D.new()
		var sm: BoxMesh = BoxMesh.new()
		sm.size = Vector3(0.85, 0.10, seg_len)
		slab.mesh = sm
		slab.material_override = lava_mat
		slab.position = p + Vector3(0, 0.05, 0)
		slab.rotation.y = ang
		pivot.add_child(slab)
		# Basalt rim borders — left and right of the slab
		for sx in [-0.55, 0.55]:
			var rim: MeshInstance3D = MeshInstance3D.new()
			var rim_m: BoxMesh = BoxMesh.new()
			rim_m.size = Vector3(0.25, 0.20, seg_len)
			rim.mesh = rim_m
			rim.material_override = basalt_mat
			# Compute the rim offset perpendicular to the segment direction
			var perp: Vector3 = Vector3(-sin(ang), 0, cos(ang)).cross(Vector3(0, 1, 0)).normalized()
			rim.position = p + Vector3(0, 0.10, 0) + perp * sx
			rim.rotation.y = ang
			pivot.add_child(rim)
	# 4 ember mote emitters along the channel (every other segment)
	for i in [0, 2, 4, 6]:
		var p: Vector3 = seg_offsets[i]
		var motes: GPUParticles3D = GPUParticles3D.new()
		motes.position = p + Vector3(0, 0.20, 0)
		motes.amount = 14
		motes.lifetime = 1.8
		var pmat: ParticleProcessMaterial = ParticleProcessMaterial.new()
		pmat.direction = Vector3(0, 1, 0)
		pmat.spread = 18.0
		pmat.initial_velocity_min = 0.4
		pmat.initial_velocity_max = 0.9
		pmat.gravity = Vector3(0, 0.3, 0)
		pmat.scale_min = 0.04
		pmat.scale_max = 0.08
		pmat.color = Color(1.0, 0.55, 0.10, 1.0)
		motes.process_material = pmat
		var psmesh: SphereMesh = SphereMesh.new()
		psmesh.radius = 0.03
		psmesh.height = 0.06
		motes.draw_pass_1 = psmesh
		pivot.add_child(motes)
	# 4 OmniLights along the channel for ground glow
	for i in [1, 3, 5, 7]:
		var p: Vector3 = seg_offsets[i]
		var lt: OmniLight3D = OmniLight3D.new()
		lt.position = p + Vector3(0, 0.30, 0)
		lt.light_color = Color(1.0, 0.55, 0.15)
		lt.light_energy = 1.6
		lt.omni_range = 4.5
		pivot.add_child(lt)
	# Lava emission pulse — slow breathe like flowing molten
	var pulse: Tween = pivot.create_tween().set_loops()
	pulse.tween_property(lava_mat, "emission_energy_multiplier", 8.0, 1.6).set_ease(Tween.EASE_IN_OUT)
	pulse.tween_property(lava_mat, "emission_energy_multiplier", 4.5, 1.6).set_ease(Tween.EASE_IN_OUT)


func _build_d9_lava_brook_bridge(geom: Node) -> void:
	## Epic-9 T80: arched iron bridge spanning the lava brook midway. Two
	## stone abutments + iron deck arch + 4 brass-capped iron rail posts
	## with 2 horizontal rails per side, 2 hanging amber lanterns, and a
	## guild-crest centerpiece on each side. Lets the player cross safely
	## between the geyser pocket and cascade pool zones.
	var pivot: Node3D = Node3D.new()
	pivot.name = "D9_LavaBrookBridge"
	# Brook anchor was at +55, -2 with seg index 3-4 around (1,-1)→(-0.5,1)
	# So the brook midpoint world is roughly +55+0.25, +0.05, -2+0
	pivot.position = D9_CENTER + Vector3(55, 0.05, -1)
	# Rotate the bridge so its long axis is perpendicular to the brook flow
	# (brook runs roughly along the +X / -Z diagonal)
	pivot.rotation.y = PI / 4.0
	geom.add_child(pivot)
	# Materials
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.18, 0.14, 0.11)
	stone_mat.metallic = 0.20
	stone_mat.roughness = 0.85
	stone_mat.emission_enabled = true
	stone_mat.emission = Color(0.55, 0.18, 0.05)
	stone_mat.emission_energy_multiplier = 0.18
	var iron_mat: StandardMaterial3D = StandardMaterial3D.new()
	iron_mat.albedo_color = Color(0.20, 0.16, 0.13)
	iron_mat.metallic = 0.85
	iron_mat.roughness = 0.40
	iron_mat.emission_enabled = true
	iron_mat.emission = Color(0.85, 0.25, 0.05)
	iron_mat.emission_energy_multiplier = 0.35
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
	amber_mat.emission_energy_multiplier = 6.0
	amber_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	# ---- Two stone abutments at the bridge ends ----
	for ax in [-2.20, 2.20]:
		var ab: MeshInstance3D = MeshInstance3D.new()
		var am: BoxMesh = BoxMesh.new()
		am.size = Vector3(1.10, 0.65, 1.20)
		ab.mesh = am
		ab.material_override = stone_mat
		ab.position = Vector3(ax, 0.30, 0)
		pivot.add_child(ab)
		# Abutment collision
		var sb: StaticBody3D = StaticBody3D.new()
		sb.position = Vector3(ax, 0.30, 0)
		var cs: CollisionShape3D = CollisionShape3D.new()
		var bsh: BoxShape3D = BoxShape3D.new()
		bsh.size = Vector3(1.10, 0.65, 1.20)
		cs.shape = bsh
		sb.add_child(cs)
		pivot.add_child(sb)
	# ---- Iron deck (arched slightly via 3 stacked thin slabs) ----
	# Main flat deck slab
	var deck: MeshInstance3D = MeshInstance3D.new()
	var dm: BoxMesh = BoxMesh.new()
	dm.size = Vector3(4.40, 0.18, 1.20)
	deck.mesh = dm
	deck.material_override = iron_mat
	deck.position = Vector3(0, 0.72, 0)
	pivot.add_child(deck)
	# Deck collision so player can walk on it
	var dsb: StaticBody3D = StaticBody3D.new()
	dsb.position = Vector3(0, 0.72, 0)
	var dcs: CollisionShape3D = CollisionShape3D.new()
	var dbsh: BoxShape3D = BoxShape3D.new()
	dbsh.size = Vector3(4.40, 0.18, 1.20)
	dcs.shape = dbsh
	dsb.add_child(dcs)
	pivot.add_child(dsb)
	# Brass deck trim (front + back)
	for tz in [-0.62, 0.62]:
		var trim: MeshInstance3D = MeshInstance3D.new()
		var tm: BoxMesh = BoxMesh.new()
		tm.size = Vector3(4.40, 0.10, 0.06)
		trim.mesh = tm
		trim.material_override = brass_mat
		trim.position = Vector3(0, 0.78, tz)
		pivot.add_child(trim)
	# ---- 4 iron rail posts (2 per side) with brass caps ----
	var post_xs: Array = [-1.60, 1.60]
	var post_zs: Array = [-0.55, 0.55]
	for px in post_xs:
		for pz in post_zs:
			var post: MeshInstance3D = MeshInstance3D.new()
			var pm: CylinderMesh = CylinderMesh.new()
			pm.top_radius = 0.06
			pm.bottom_radius = 0.08
			pm.height = 1.00
			post.mesh = pm
			post.material_override = iron_mat
			post.position = Vector3(px, 1.30, pz)
			pivot.add_child(post)
			# Brass cap
			var cap: MeshInstance3D = MeshInstance3D.new()
			var capm: SphereMesh = SphereMesh.new()
			capm.radius = 0.08
			capm.height = 0.16
			cap.mesh = capm
			cap.material_override = brass_mat
			cap.position = Vector3(px, 1.85, pz)
			pivot.add_child(cap)
	# ---- 2 horizontal rails per side (top + mid) ----
	for rz in [-0.55, 0.55]:
		for ry in [1.30, 1.65]:
			var rail: MeshInstance3D = MeshInstance3D.new()
			var rmesh: BoxMesh = BoxMesh.new()
			rmesh.size = Vector3(3.40, 0.06, 0.06)
			rail.mesh = rmesh
			rail.material_override = iron_mat
			rail.position = Vector3(0, ry, rz)
			pivot.add_child(rail)
	# ---- 2 hanging amber lanterns at the rail mid-points (inboard, above the deck) ----
	for lz in [-0.40, 0.40]:
		# Lantern cord
		var cord: MeshInstance3D = MeshInstance3D.new()
		var crm: CylinderMesh = CylinderMesh.new()
		crm.top_radius = 0.02
		crm.bottom_radius = 0.02
		crm.height = 0.30
		cord.mesh = crm
		cord.material_override = brass_mat
		cord.position = Vector3(0, 1.50, lz)
		pivot.add_child(cord)
		# Lantern bulb
		var bulb: MeshInstance3D = MeshInstance3D.new()
		var bm: SphereMesh = SphereMesh.new()
		bm.radius = 0.13
		bm.height = 0.26
		bulb.mesh = bm
		bulb.material_override = amber_mat
		bulb.position = Vector3(0, 1.20, lz)
		pivot.add_child(bulb)
		# Lantern OmniLight
		var lt: OmniLight3D = OmniLight3D.new()
		lt.position = Vector3(0, 1.20, lz)
		lt.light_color = Color(1.0, 0.55, 0.15)
		lt.light_energy = 1.8
		lt.omni_range = 4.5
		pivot.add_child(lt)
	# ---- Guild crest medallion on each side rail (small unshaded torus) ----
	for cz in [-0.62, 0.62]:
		var crest: MeshInstance3D = MeshInstance3D.new()
		var ctm: TorusMesh = TorusMesh.new()
		ctm.inner_radius = 0.10
		ctm.outer_radius = 0.18
		crest.mesh = ctm
		crest.material_override = amber_mat
		crest.position = Vector3(0, 1.55, cz)
		crest.rotation.x = PI / 2.0
		pivot.add_child(crest)
	# Lantern + crest pulse — same material so synced
	var lpulse: Tween = pivot.create_tween().set_loops()
	lpulse.tween_property(amber_mat, "emission_energy_multiplier", 8.0, 1.4).set_ease(Tween.EASE_IN_OUT)
	lpulse.tween_property(amber_mat, "emission_energy_multiplier", 5.0, 1.4).set_ease(Tween.EASE_IN_OUT)


func _build_d9_basalt_monolith_ridge(geom: Node) -> void:
	## Epic-9 T81: tall jagged basalt monoliths framing D9's far north
	## border. 9 monoliths in a staggered row, varying height + width +
	## tilt + glowing magma seam stripe. Acts as a horizon ridge that
	## sells "ancient volcano looming behind the district".
	var pivot: Node3D = Node3D.new()
	pivot.name = "D9_BasaltMonolithRidge"
	pivot.position = D9_CENTER + Vector3(0, 0, -32)
	geom.add_child(pivot)
	# Materials
	var basalt_mat: StandardMaterial3D = StandardMaterial3D.new()
	basalt_mat.albedo_color = Color(0.08, 0.07, 0.06)
	basalt_mat.metallic = 0.18
	basalt_mat.roughness = 0.92
	basalt_mat.emission_enabled = true
	basalt_mat.emission = Color(0.40, 0.12, 0.04)
	basalt_mat.emission_energy_multiplier = 0.18
	var seam_mat: StandardMaterial3D = StandardMaterial3D.new()
	seam_mat.albedo_color = Color(1.0, 0.45, 0.05)
	seam_mat.emission_enabled = true
	seam_mat.emission = Color(1.0, 0.45, 0.05)
	seam_mat.emission_energy_multiplier = 5.5
	seam_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	# 9 monoliths spaced ~6 units apart along X, tallest in the middle
	var monolith_data: Array = [
		{"x": -24.0, "h": 5.5, "w": 2.4, "tilt": -0.04},
		{"x": -18.0, "h": 7.2, "w": 2.6, "tilt": 0.03},
		{"x": -12.0, "h": 8.8, "w": 2.8, "tilt": -0.06},
		{"x": -6.0, "h": 10.5, "w": 3.0, "tilt": 0.02},
		{"x": 0.0, "h": 12.0, "w": 3.4, "tilt": 0.00},
		{"x": 6.0, "h": 10.8, "w": 3.0, "tilt": -0.03},
		{"x": 12.0, "h": 9.0, "w": 2.7, "tilt": 0.05},
		{"x": 18.0, "h": 7.5, "w": 2.6, "tilt": -0.02},
		{"x": 24.0, "h": 6.0, "w": 2.4, "tilt": 0.04},
	]
	for i in monolith_data.size():
		var md: Dictionary = monolith_data[i]
		var mx: float = md["x"]
		var mh: float = md["h"]
		var mw: float = md["w"]
		var tilt: float = md["tilt"]
		# Random small Z-jitter for staggered row
		var jz: float = sin(float(i) * 1.7) * 1.4
		# Monolith body — tapered tall box
		var mono: MeshInstance3D = MeshInstance3D.new()
		var mm: BoxMesh = BoxMesh.new()
		mm.size = Vector3(mw, mh, mw * 0.85)
		mono.mesh = mm
		mono.material_override = basalt_mat
		mono.position = Vector3(mx, mh * 0.5, jz)
		mono.rotation.z = tilt
		mono.rotation.y = sin(float(i) * 0.9) * 0.20
		pivot.add_child(mono)
		# Monolith collision — keep player out of the ridge
		var sb: StaticBody3D = StaticBody3D.new()
		sb.position = Vector3(mx, mh * 0.5, jz)
		sb.rotation.z = tilt
		sb.rotation.y = mono.rotation.y
		var cs: CollisionShape3D = CollisionShape3D.new()
		var bsh: BoxShape3D = BoxShape3D.new()
		bsh.size = Vector3(mw, mh, mw * 0.85)
		cs.shape = bsh
		sb.add_child(cs)
		pivot.add_child(sb)
		# Pyramid-cap top (PrismMesh)
		var cap: MeshInstance3D = MeshInstance3D.new()
		var capm: PrismMesh = PrismMesh.new()
		capm.size = Vector3(mw, mw * 0.65, mw * 0.85)
		cap.mesh = capm
		cap.material_override = basalt_mat
		cap.position = Vector3(mx, mh + (mw * 0.32), jz)
		cap.rotation.z = tilt
		cap.rotation.y = mono.rotation.y
		pivot.add_child(cap)
		# Vertical glowing magma seam stripe down the front face
		var seam: MeshInstance3D = MeshInstance3D.new()
		var sm: BoxMesh = BoxMesh.new()
		sm.size = Vector3(0.18, mh * 0.85, 0.06)
		seam.mesh = sm
		seam.material_override = seam_mat
		seam.position = Vector3(mx, mh * 0.50, jz + mw * 0.45)
		seam.rotation.z = tilt
		seam.rotation.y = mono.rotation.y
		pivot.add_child(seam)
		# Subtle ridge OmniLight at the seam top — every other monolith
		if i % 2 == 0:
			var lt: OmniLight3D = OmniLight3D.new()
			lt.position = Vector3(mx, mh * 0.85, jz + mw * 0.55)
			lt.light_color = Color(1.0, 0.55, 0.15)
			lt.light_energy = 1.6
			lt.omni_range = 6.0
			pivot.add_child(lt)
	# Slow ridge seam pulse — single shared material so all monoliths breathe together
	var rpulse: Tween = pivot.create_tween().set_loops()
	rpulse.tween_property(seam_mat, "emission_energy_multiplier", 7.5, 2.4).set_ease(Tween.EASE_IN_OUT)
	rpulse.tween_property(seam_mat, "emission_energy_multiplier", 4.0, 2.4).set_ease(Tween.EASE_IN_OUT)


func _build_d9_obsidian_shard_field(geom: Node) -> void:
	## Epic-9 T82: obsidian shard field along D9's far south border. 18
	## tall slim glassy obsidian prisms scattered along the south edge,
	## varying height + tilt + rotation. Each shard has a faint inner
	## glow and 6 of them have a brighter unshaded amber crack along
	## the front face. Frames the south horizon and mirrors T81's
	## monolith ridge.
	var pivot: Node3D = Node3D.new()
	pivot.name = "D9_ObsidianShardField"
	pivot.position = D9_CENTER + Vector3(0, 0, 32)
	geom.add_child(pivot)
	# Materials
	var obsidian_mat: StandardMaterial3D = StandardMaterial3D.new()
	obsidian_mat.albedo_color = Color(0.06, 0.05, 0.08)
	obsidian_mat.metallic = 0.55
	obsidian_mat.roughness = 0.18
	obsidian_mat.emission_enabled = true
	obsidian_mat.emission = Color(0.50, 0.20, 0.55)
	obsidian_mat.emission_energy_multiplier = 0.35
	var crack_mat: StandardMaterial3D = StandardMaterial3D.new()
	crack_mat.albedo_color = Color(1.0, 0.55, 0.10)
	crack_mat.emission_enabled = true
	crack_mat.emission = Color(1.0, 0.55, 0.10)
	crack_mat.emission_energy_multiplier = 6.0
	crack_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	# 18 shards spaced ~3 units apart along X, varying Z jitter
	for i in 18:
		var sx: float = -25.5 + float(i) * 3.0
		var jz: float = sin(float(i) * 1.3) * 1.2
		var h: float = 3.2 + sin(float(i) * 0.7) * 1.4 + (1.0 if i % 4 == 0 else 0.0)
		var w: float = 0.55 + cos(float(i) * 0.5) * 0.10
		var tilt_x: float = sin(float(i) * 1.1) * 0.18
		var tilt_z: float = cos(float(i) * 0.9) * 0.20
		var roty: float = float(i) * 0.7
		# Shard body — thin tall prism (PrismMesh)
		var shard: MeshInstance3D = MeshInstance3D.new()
		var sm: PrismMesh = PrismMesh.new()
		sm.size = Vector3(w, h, w * 0.55)
		shard.mesh = sm
		shard.material_override = obsidian_mat
		shard.position = Vector3(sx, h * 0.5, jz)
		shard.rotation = Vector3(tilt_x, roty, tilt_z)
		pivot.add_child(shard)
		# Shard collision
		var sb: StaticBody3D = StaticBody3D.new()
		sb.position = Vector3(sx, h * 0.5, jz)
		sb.rotation = Vector3(tilt_x, roty, tilt_z)
		var cs: CollisionShape3D = CollisionShape3D.new()
		var bsh: BoxShape3D = BoxShape3D.new()
		bsh.size = Vector3(w, h, w * 0.55)
		cs.shape = bsh
		sb.add_child(cs)
		pivot.add_child(sb)
		# Every 3rd shard gets a glowing crack stripe along its front face
		if i % 3 == 0:
			var crack: MeshInstance3D = MeshInstance3D.new()
			var cmm: BoxMesh = BoxMesh.new()
			cmm.size = Vector3(0.06, h * 0.70, 0.04)
			crack.mesh = cmm
			crack.material_override = crack_mat
			crack.position = Vector3(sx, h * 0.50, jz - w * 0.30)
			crack.rotation = Vector3(tilt_x, roty, tilt_z)
			pivot.add_child(crack)
			# Subtle OmniLight on the crack
			var lt: OmniLight3D = OmniLight3D.new()
			lt.position = Vector3(sx, h * 0.65, jz - w * 0.35)
			lt.light_color = Color(1.0, 0.55, 0.15)
			lt.light_energy = 1.4
			lt.omni_range = 4.5
			pivot.add_child(lt)
	# 4 small ground shard clusters scattered between the tall ones
	var cluster_xs: Array = [-18.0, -6.0, 6.0, 18.0]
	for cx in cluster_xs:
		for j in 4:
			var off_x: float = randf_range(-1.2, 1.2)
			var off_z: float = randf_range(-1.0, 1.0)
			var ch: float = randf_range(0.45, 0.85)
			var cw: float = randf_range(0.20, 0.32)
			var small: MeshInstance3D = MeshInstance3D.new()
			var smm: PrismMesh = PrismMesh.new()
			smm.size = Vector3(cw, ch, cw * 0.55)
			small.mesh = smm
			small.material_override = obsidian_mat
			small.position = Vector3(cx + off_x, ch * 0.5, off_z)
			small.rotation = Vector3(randf_range(-0.30, 0.30), randf() * TAU, randf_range(-0.30, 0.30))
			pivot.add_child(small)
	# Slow obsidian violet glow + crack pulse
	var opulse: Tween = pivot.create_tween().set_loops()
	opulse.tween_property(obsidian_mat, "emission_energy_multiplier", 0.55, 2.2).set_ease(Tween.EASE_IN_OUT)
	opulse.tween_property(obsidian_mat, "emission_energy_multiplier", 0.25, 2.2).set_ease(Tween.EASE_IN_OUT)
	var cpulse: Tween = pivot.create_tween().set_loops()
	cpulse.tween_property(crack_mat, "emission_energy_multiplier", 8.0, 1.4).set_ease(Tween.EASE_IN_OUT)
	cpulse.tween_property(crack_mat, "emission_energy_multiplier", 4.5, 1.4).set_ease(Tween.EASE_IN_OUT)


func _build_d9_forge_imp_pack(geom: Node) -> void:
	## Epic-9 T83: 4 forge imp creatures hovering near the geyser as wild
	## forge fauna. Each imp is a small floating molten body with a
	## glowing core, two stubby arms, two tiny eye-glows, ember tail
	## particles, and a hover bob + drift loop. Combat-preview enemies
	## that establish "wild forge fauna" in central D9.
	var pivot: Node3D = Node3D.new()
	pivot.name = "D9_ForgeImpPack"
	pivot.position = D9_CENTER + Vector3(56, 0, -6)
	geom.add_child(pivot)
	# Shared materials
	var molten_mat: StandardMaterial3D = StandardMaterial3D.new()
	molten_mat.albedo_color = Color(1.0, 0.45, 0.05)
	molten_mat.emission_enabled = true
	molten_mat.emission = Color(1.0, 0.45, 0.05)
	molten_mat.emission_energy_multiplier = 5.5
	molten_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var rind_mat: StandardMaterial3D = StandardMaterial3D.new()
	rind_mat.albedo_color = Color(0.18, 0.10, 0.06)
	rind_mat.metallic = 0.30
	rind_mat.roughness = 0.85
	rind_mat.emission_enabled = true
	rind_mat.emission = Color(0.85, 0.30, 0.05)
	rind_mat.emission_energy_multiplier = 0.45
	# Place 4 imps in a loose ring around the geyser
	var imp_positions: Array = [
		Vector3(2.50, 1.20, 0.0),
		Vector3(-2.50, 1.40, 1.5),
		Vector3(0.0, 1.10, -2.50),
		Vector3(1.80, 1.30, -1.80),
	]
	for i in imp_positions.size():
		var ip: Vector3 = imp_positions[i]
		# Imp pivot — root for hover and drift
		var imp: Node3D = Node3D.new()
		imp.name = "ForgeImp_" + str(i)
		imp.position = ip
		pivot.add_child(imp)
		# ---- Outer charred rind shell ----
		var shell: MeshInstance3D = MeshInstance3D.new()
		var shm: SphereMesh = SphereMesh.new()
		shm.radius = 0.35
		shm.height = 0.65
		shell.mesh = shm
		shell.material_override = rind_mat
		shell.position = Vector3(0, 0, 0)
		imp.add_child(shell)
		# ---- Inner glowing molten core (smaller, brighter) ----
		var core: MeshInstance3D = MeshInstance3D.new()
		var cmm: SphereMesh = SphereMesh.new()
		cmm.radius = 0.22
		cmm.height = 0.40
		core.mesh = cmm
		core.material_override = molten_mat
		core.position = Vector3(0, 0, 0)
		imp.add_child(core)
		# ---- Two stubby arms — small bent boxes ----
		for ax in [-0.40, 0.40]:
			var arm: MeshInstance3D = MeshInstance3D.new()
			var amm: BoxMesh = BoxMesh.new()
			amm.size = Vector3(0.10, 0.10, 0.30)
			arm.mesh = amm
			arm.material_override = rind_mat
			arm.position = Vector3(ax, -0.05, 0)
			arm.rotation.z = 0.50 * sign(ax)
			imp.add_child(arm)
		# ---- Two tiny eye-glow dots on the front face ----
		for ex in [-0.10, 0.10]:
			var eye: MeshInstance3D = MeshInstance3D.new()
			var em: SphereMesh = SphereMesh.new()
			em.radius = 0.04
			em.height = 0.08
			eye.mesh = em
			eye.material_override = molten_mat
			eye.position = Vector3(ex, 0.05, -0.32)
			imp.add_child(eye)
		# ---- Ember tail particles trailing below ----
		var tail: GPUParticles3D = GPUParticles3D.new()
		tail.position = Vector3(0, -0.30, 0)
		tail.amount = 14
		tail.lifetime = 1.4
		var pmat: ParticleProcessMaterial = ParticleProcessMaterial.new()
		pmat.direction = Vector3(0, -1, 0)
		pmat.spread = 18.0
		pmat.initial_velocity_min = 0.5
		pmat.initial_velocity_max = 1.0
		pmat.gravity = Vector3(0, -1.5, 0)
		pmat.scale_min = 0.05
		pmat.scale_max = 0.10
		pmat.color = Color(1.0, 0.55, 0.10, 1.0)
		tail.process_material = pmat
		var psmesh: SphereMesh = SphereMesh.new()
		psmesh.radius = 0.04
		psmesh.height = 0.08
		tail.draw_pass_1 = psmesh
		imp.add_child(tail)
		# ---- Per-imp OmniLight ----
		var lt: OmniLight3D = OmniLight3D.new()
		lt.position = Vector3(0, 0, 0)
		lt.light_color = Color(1.0, 0.55, 0.15)
		lt.light_energy = 1.8
		lt.omni_range = 4.5
		imp.add_child(lt)
		# ---- Hover bob (per-imp Y oscillation, varied period) ----
		var bob_period: float = 1.2 + float(i) * 0.18
		var bob: Tween = imp.create_tween().set_loops()
		bob.tween_property(imp, "position:y", ip.y + 0.40, bob_period).set_ease(Tween.EASE_IN_OUT)
		bob.tween_property(imp, "position:y", ip.y - 0.10, bob_period).set_ease(Tween.EASE_IN_OUT)
		# ---- Slow yaw spin so the imps face different directions over time ----
		var spin: Tween = imp.create_tween().set_loops()
		spin.tween_property(imp, "rotation:y", TAU, 4.5 + float(i) * 0.5)
	# Shared molten core pulse
	var mpulse: Tween = pivot.create_tween().set_loops()
	mpulse.tween_property(molten_mat, "emission_energy_multiplier", 7.5, 1.2).set_ease(Tween.EASE_IN_OUT)
	mpulse.tween_property(molten_mat, "emission_energy_multiplier", 4.0, 1.2).set_ease(Tween.EASE_IN_OUT)


func _build_d9_iron_sentinel_statues(geom: Node) -> void:
	## Epic-9 T84: monumental iron sentinel statues flanking D9's central
	## main path. Two 6m armored guardian figures on basalt plinths,
	## each holding a vertical forge sword with a glowing core stripe.
	## Helm visor slits glow amber. Adds heroic combat-themed scenery.
	var pivot: Node3D = Node3D.new()
	pivot.name = "D9_IronSentinelStatues"
	pivot.position = D9_CENTER + Vector3(20, 0, 0)
	geom.add_child(pivot)
	# Materials
	var iron_mat: StandardMaterial3D = StandardMaterial3D.new()
	iron_mat.albedo_color = Color(0.18, 0.14, 0.11)
	iron_mat.metallic = 0.85
	iron_mat.roughness = 0.45
	iron_mat.emission_enabled = true
	iron_mat.emission = Color(0.65, 0.20, 0.05)
	iron_mat.emission_energy_multiplier = 0.30
	var basalt_mat: StandardMaterial3D = StandardMaterial3D.new()
	basalt_mat.albedo_color = Color(0.10, 0.08, 0.07)
	basalt_mat.metallic = 0.20
	basalt_mat.roughness = 0.85
	basalt_mat.emission_enabled = true
	basalt_mat.emission = Color(0.45, 0.15, 0.04)
	basalt_mat.emission_energy_multiplier = 0.20
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
	ember_mat.emission_energy_multiplier = 6.0
	ember_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	# Build a sentinel at +/- offset
	for sx in [-7.0, 7.0]:
		var sgroup: Node3D = Node3D.new()
		sgroup.name = "Sentinel_" + str(int(sx))
		sgroup.position = Vector3(sx, 0, 0)
		# Inner sentinels face the path center, outer also faces center
		if sx > 0:
			sgroup.rotation.y = -PI / 2.0
		else:
			sgroup.rotation.y = PI / 2.0
		pivot.add_child(sgroup)
		# ---- Stepped basalt plinth (2 levels) ----
		var plinth1: MeshInstance3D = MeshInstance3D.new()
		var p1m: BoxMesh = BoxMesh.new()
		p1m.size = Vector3(2.40, 0.40, 2.40)
		plinth1.mesh = p1m
		plinth1.material_override = basalt_mat
		plinth1.position = Vector3(0, 0.20, 0)
		sgroup.add_child(plinth1)
		var plinth2: MeshInstance3D = MeshInstance3D.new()
		var p2m: BoxMesh = BoxMesh.new()
		p2m.size = Vector3(1.90, 0.55, 1.90)
		plinth2.mesh = p2m
		plinth2.material_override = basalt_mat
		plinth2.position = Vector3(0, 0.68, 0)
		sgroup.add_child(plinth2)
		# Plinth collision
		var psb: StaticBody3D = StaticBody3D.new()
		psb.position = Vector3(0, 0.45, 0)
		var pcs: CollisionShape3D = CollisionShape3D.new()
		var pbsh: BoxShape3D = BoxShape3D.new()
		pbsh.size = Vector3(2.40, 0.95, 2.40)
		pcs.shape = pbsh
		psb.add_child(pcs)
		sgroup.add_child(psb)
		# ---- Sentinel body (armored torso box) ----
		var torso: MeshInstance3D = MeshInstance3D.new()
		var tm: BoxMesh = BoxMesh.new()
		tm.size = Vector3(1.50, 2.40, 1.05)
		torso.mesh = tm
		torso.material_override = iron_mat
		torso.position = Vector3(0, 2.15, 0)
		sgroup.add_child(torso)
		# Torso collision
		var tsb: StaticBody3D = StaticBody3D.new()
		tsb.position = Vector3(0, 2.15, 0)
		var tcs: CollisionShape3D = CollisionShape3D.new()
		var tbsh: BoxShape3D = BoxShape3D.new()
		tbsh.size = Vector3(1.50, 2.40, 1.05)
		tcs.shape = tbsh
		tsb.add_child(tcs)
		sgroup.add_child(tsb)
		# Brass chest plate seam — vertical stripe down the front
		var chest_seam: MeshInstance3D = MeshInstance3D.new()
		var csm: BoxMesh = BoxMesh.new()
		csm.size = Vector3(0.18, 2.20, 0.06)
		chest_seam.mesh = csm
		chest_seam.material_override = brass_mat
		chest_seam.position = Vector3(0, 2.15, -0.55)
		sgroup.add_child(chest_seam)
		# Glowing chest core — unshaded amber sphere over the seam
		var chest_core: MeshInstance3D = MeshInstance3D.new()
		var ccm: SphereMesh = SphereMesh.new()
		ccm.radius = 0.20
		ccm.height = 0.40
		chest_core.mesh = ccm
		chest_core.material_override = ember_mat
		chest_core.position = Vector3(0, 2.30, -0.62)
		sgroup.add_child(chest_core)
		# ---- Pauldrons (brass shoulder caps) ----
		for px in [-0.85, 0.85]:
			var paul: MeshInstance3D = MeshInstance3D.new()
			var paum: SphereMesh = SphereMesh.new()
			paum.radius = 0.32
			paum.height = 0.60
			paul.mesh = paum
			paul.material_override = brass_mat
			paul.position = Vector3(px, 3.10, 0)
			paul.scale = Vector3(1.0, 0.55, 1.0)
			sgroup.add_child(paul)
		# ---- Helm (rounded box with visor slit) ----
		var helm: MeshInstance3D = MeshInstance3D.new()
		var hmm: BoxMesh = BoxMesh.new()
		hmm.size = Vector3(0.95, 0.85, 0.85)
		helm.mesh = hmm
		helm.material_override = iron_mat
		helm.position = Vector3(0, 3.85, 0)
		sgroup.add_child(helm)
		# Helm crown ridge — small prism on top
		var crown_ridge: MeshInstance3D = MeshInstance3D.new()
		var crm: PrismMesh = PrismMesh.new()
		crm.size = Vector3(0.30, 0.30, 0.95)
		crown_ridge.mesh = crm
		crown_ridge.material_override = brass_mat
		crown_ridge.position = Vector3(0, 4.40, 0)
		sgroup.add_child(crown_ridge)
		# Glowing visor slit — narrow horizontal box
		var visor: MeshInstance3D = MeshInstance3D.new()
		var vm: BoxMesh = BoxMesh.new()
		vm.size = Vector3(0.65, 0.10, 0.04)
		visor.mesh = vm
		visor.material_override = ember_mat
		visor.position = Vector3(0, 3.95, -0.45)
		sgroup.add_child(visor)
		# ---- Vertical forge sword held in front of the body ----
		# Sword pommel (brass sphere)
		var pommel: MeshInstance3D = MeshInstance3D.new()
		var pom: SphereMesh = SphereMesh.new()
		pom.radius = 0.10
		pom.height = 0.20
		pommel.mesh = pom
		pommel.material_override = brass_mat
		pommel.position = Vector3(0, 1.05, -0.85)
		sgroup.add_child(pommel)
		# Sword grip (wood cylinder)
		var wood_mat: StandardMaterial3D = StandardMaterial3D.new()
		wood_mat.albedo_color = Color(0.32, 0.20, 0.12)
		wood_mat.roughness = 0.85
		var grip: MeshInstance3D = MeshInstance3D.new()
		var gm: CylinderMesh = CylinderMesh.new()
		gm.top_radius = 0.06
		gm.bottom_radius = 0.06
		gm.height = 0.45
		grip.mesh = gm
		grip.material_override = wood_mat
		grip.position = Vector3(0, 1.40, -0.85)
		sgroup.add_child(grip)
		# Sword crossguard (brass bar)
		var guard: MeshInstance3D = MeshInstance3D.new()
		var gdm: BoxMesh = BoxMesh.new()
		gdm.size = Vector3(0.65, 0.10, 0.10)
		guard.mesh = gdm
		guard.material_override = brass_mat
		guard.position = Vector3(0, 1.65, -0.85)
		sgroup.add_child(guard)
		# Sword blade (long iron box) with glowing core stripe
		var blade: MeshInstance3D = MeshInstance3D.new()
		var bm: BoxMesh = BoxMesh.new()
		bm.size = Vector3(0.20, 2.60, 0.05)
		blade.mesh = bm
		blade.material_override = iron_mat
		blade.position = Vector3(0, 3.00, -0.85)
		sgroup.add_child(blade)
		# Blade core stripe (unshaded amber)
		var blade_core: MeshInstance3D = MeshInstance3D.new()
		var bcm: BoxMesh = BoxMesh.new()
		bcm.size = Vector3(0.06, 2.40, 0.06)
		blade_core.mesh = bcm
		blade_core.material_override = ember_mat
		blade_core.position = Vector3(0, 3.00, -0.86)
		sgroup.add_child(blade_core)
		# Blade tip (small prism)
		var tip: MeshInstance3D = MeshInstance3D.new()
		var tipm: PrismMesh = PrismMesh.new()
		tipm.size = Vector3(0.20, 0.30, 0.05)
		tip.mesh = tipm
		tip.material_override = iron_mat
		tip.position = Vector3(0, 4.45, -0.85)
		sgroup.add_child(tip)
		# Sentinel OmniLight (warm wash from chest core)
		var lt: OmniLight3D = OmniLight3D.new()
		lt.position = Vector3(0, 2.40, -0.80)
		lt.light_color = Color(1.0, 0.55, 0.15)
		lt.light_energy = 2.4
		lt.omni_range = 7.0
		sgroup.add_child(lt)
	# Shared chest core + visor + blade-core pulse
	var sentpulse: Tween = pivot.create_tween().set_loops()
	sentpulse.tween_property(ember_mat, "emission_energy_multiplier", 8.0, 1.6).set_ease(Tween.EASE_IN_OUT)
	sentpulse.tween_property(ember_mat, "emission_energy_multiplier", 4.5, 1.6).set_ease(Tween.EASE_IN_OUT)


func _build_d9_drift_lava_pool(geom: Node) -> void:
	## Epic-9 T85: small surface lava pool in central D9 with ancient anvil
	## chunks and discarded tools floating/cooling on the surface. Round
	## basalt rim, glowing lava disc, 3 anvil chunks bobbing, 1 tongs head,
	## 1 hammer head, sparse smoke and ember motes.
	var pivot: Node3D = Node3D.new()
	pivot.name = "D9_DriftLavaPool"
	pivot.position = D9_CENTER + Vector3(28, 0, 8)
	geom.add_child(pivot)
	# Materials
	var basalt_mat: StandardMaterial3D = StandardMaterial3D.new()
	basalt_mat.albedo_color = Color(0.10, 0.08, 0.07)
	basalt_mat.metallic = 0.20
	basalt_mat.roughness = 0.85
	basalt_mat.emission_enabled = true
	basalt_mat.emission = Color(0.55, 0.18, 0.05)
	basalt_mat.emission_energy_multiplier = 0.30
	var lava_mat: StandardMaterial3D = StandardMaterial3D.new()
	lava_mat.albedo_color = Color(1.0, 0.45, 0.05)
	lava_mat.emission_enabled = true
	lava_mat.emission = Color(1.0, 0.45, 0.05)
	lava_mat.emission_energy_multiplier = 7.0
	lava_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var iron_mat: StandardMaterial3D = StandardMaterial3D.new()
	iron_mat.albedo_color = Color(0.18, 0.14, 0.11)
	iron_mat.metallic = 0.85
	iron_mat.roughness = 0.45
	iron_mat.emission_enabled = true
	iron_mat.emission = Color(0.85, 0.25, 0.05)
	iron_mat.emission_energy_multiplier = 0.45
	var brass_mat: StandardMaterial3D = StandardMaterial3D.new()
	brass_mat.albedo_color = Color(0.85, 0.55, 0.18)
	brass_mat.metallic = 0.95
	brass_mat.roughness = 0.30
	brass_mat.emission_enabled = true
	brass_mat.emission = Color(1.0, 0.50, 0.10)
	brass_mat.emission_energy_multiplier = 0.55
	# ---- Round basalt rim ring ----
	var rim: MeshInstance3D = MeshInstance3D.new()
	var rim_m: TorusMesh = TorusMesh.new()
	rim_m.inner_radius = 2.40
	rim_m.outer_radius = 2.85
	rim.mesh = rim_m
	rim.material_override = basalt_mat
	rim.position = Vector3(0, 0.18, 0)
	pivot.add_child(rim)
	# Rim collision (cylinder ring approximation)
	var rim_sb: StaticBody3D = StaticBody3D.new()
	rim_sb.position = Vector3(0, 0.18, 0)
	var rim_cs: CollisionShape3D = CollisionShape3D.new()
	var rim_cyl: CylinderShape3D = CylinderShape3D.new()
	rim_cyl.radius = maxf(2.85, 2.85)
	rim_cyl.height = 0.30
	rim_cs.shape = rim_cyl
	rim_sb.add_child(rim_cs)
	pivot.add_child(rim_sb)
	# ---- Lava surface disc ----
	var lava_disc: MeshInstance3D = MeshInstance3D.new()
	var ldm: CylinderMesh = CylinderMesh.new()
	ldm.top_radius = 2.40
	ldm.bottom_radius = 2.40
	ldm.height = 0.10
	lava_disc.mesh = ldm
	lava_disc.material_override = lava_mat
	lava_disc.position = Vector3(0, 0.18, 0)
	pivot.add_child(lava_disc)
	# ---- 3 anvil chunks bobbing on the surface ----
	var chunk_data: Array = [
		{"pos": Vector3(0.85, 0.32, 0.0), "size": Vector3(0.50, 0.30, 0.30), "tilt": 0.20},
		{"pos": Vector3(-0.95, 0.32, 0.55), "size": Vector3(0.45, 0.28, 0.32), "tilt": -0.30},
		{"pos": Vector3(0.20, 0.32, -1.10), "size": Vector3(0.55, 0.32, 0.28), "tilt": 0.15},
	]
	for cd in chunk_data:
		var chunk: MeshInstance3D = MeshInstance3D.new()
		var cm: BoxMesh = BoxMesh.new()
		cm.size = cd["size"]
		chunk.mesh = cm
		chunk.material_override = iron_mat
		chunk.position = cd["pos"]
		chunk.rotation.z = cd["tilt"]
		chunk.rotation.y = randf() * TAU
		pivot.add_child(chunk)
		# Bob each chunk with its own period
		var bob: Tween = pivot.create_tween().set_loops()
		var by: float = cd["pos"].y
		bob.tween_property(chunk, "position:y", by + 0.08, 1.4 + randf() * 0.4).set_ease(Tween.EASE_IN_OUT)
		bob.tween_property(chunk, "position:y", by - 0.04, 1.4 + randf() * 0.4).set_ease(Tween.EASE_IN_OUT)
	# ---- 1 floating tongs head (small brass U-shape made of 3 boxes) ----
	var tongs_root: Node3D = Node3D.new()
	tongs_root.position = Vector3(-1.30, 0.32, -0.80)
	pivot.add_child(tongs_root)
	# Tongs base
	var t_base: MeshInstance3D = MeshInstance3D.new()
	var tbm: BoxMesh = BoxMesh.new()
	tbm.size = Vector3(0.32, 0.06, 0.10)
	t_base.mesh = tbm
	t_base.material_override = brass_mat
	t_base.position = Vector3(0, 0, 0)
	tongs_root.add_child(t_base)
	# Tongs left arm
	var t_l: MeshInstance3D = MeshInstance3D.new()
	var tlm: BoxMesh = BoxMesh.new()
	tlm.size = Vector3(0.06, 0.06, 0.30)
	t_l.mesh = tlm
	t_l.material_override = brass_mat
	t_l.position = Vector3(-0.13, 0.0, 0.18)
	tongs_root.add_child(t_l)
	# Tongs right arm
	var t_r: MeshInstance3D = MeshInstance3D.new()
	t_r.mesh = tlm
	t_r.material_override = brass_mat
	t_r.position = Vector3(0.13, 0.0, 0.18)
	tongs_root.add_child(t_r)
	# Bob tongs
	var tbob: Tween = pivot.create_tween().set_loops()
	tbob.tween_property(tongs_root, "position:y", 0.40, 1.5).set_ease(Tween.EASE_IN_OUT)
	tbob.tween_property(tongs_root, "position:y", 0.28, 1.5).set_ease(Tween.EASE_IN_OUT)
	# ---- 1 floating hammer head (iron box) ----
	var hammer_head: MeshInstance3D = MeshInstance3D.new()
	var hhm: BoxMesh = BoxMesh.new()
	hhm.size = Vector3(0.45, 0.18, 0.20)
	hammer_head.mesh = hhm
	hammer_head.material_override = iron_mat
	hammer_head.position = Vector3(1.40, 0.32, 1.10)
	hammer_head.rotation.y = 0.4
	pivot.add_child(hammer_head)
	var hbob: Tween = pivot.create_tween().set_loops()
	hbob.tween_property(hammer_head, "position:y", 0.42, 1.7).set_ease(Tween.EASE_IN_OUT)
	hbob.tween_property(hammer_head, "position:y", 0.30, 1.7).set_ease(Tween.EASE_IN_OUT)
	# ---- Pool OmniLight (warm wash from the lava surface) ----
	var lt: OmniLight3D = OmniLight3D.new()
	lt.position = Vector3(0, 0.80, 0)
	lt.light_color = Color(1.0, 0.55, 0.15)
	lt.light_energy = 3.4
	lt.omni_range = 9.0
	pivot.add_child(lt)
	# ---- Sparse smoke drift particles ----
	var smoke: GPUParticles3D = GPUParticles3D.new()
	smoke.position = Vector3(0, 0.50, 0)
	smoke.amount = 16
	smoke.lifetime = 3.5
	var smat: ParticleProcessMaterial = ParticleProcessMaterial.new()
	smat.direction = Vector3(0, 1, 0)
	smat.spread = 22.0
	smat.initial_velocity_min = 0.4
	smat.initial_velocity_max = 0.8
	smat.gravity = Vector3(0, 0.4, 0)
	smat.scale_min = 0.15
	smat.scale_max = 0.30
	smat.color = Color(0.30, 0.25, 0.20, 0.65)
	smoke.process_material = smat
	var smkm: SphereMesh = SphereMesh.new()
	smkm.radius = 0.12
	smkm.height = 0.24
	smoke.draw_pass_1 = smkm
	pivot.add_child(smoke)
	# ---- Ember motes ----
	var motes: GPUParticles3D = GPUParticles3D.new()
	motes.position = Vector3(0, 0.40, 0)
	motes.amount = 18
	motes.lifetime = 2.0
	var emat: ParticleProcessMaterial = ParticleProcessMaterial.new()
	emat.direction = Vector3(0, 1, 0)
	emat.spread = 18.0
	emat.initial_velocity_min = 0.5
	emat.initial_velocity_max = 1.0
	emat.gravity = Vector3(0, 0.3, 0)
	emat.scale_min = 0.05
	emat.scale_max = 0.10
	emat.color = Color(1.0, 0.55, 0.10, 1.0)
	motes.process_material = emat
	var psmesh: SphereMesh = SphereMesh.new()
	psmesh.radius = 0.04
	psmesh.height = 0.08
	motes.draw_pass_1 = psmesh
	pivot.add_child(motes)
	# Lava pulse
	var lpulse: Tween = pivot.create_tween().set_loops()
	lpulse.tween_property(lava_mat, "emission_energy_multiplier", 9.0, 1.6).set_ease(Tween.EASE_IN_OUT)
	lpulse.tween_property(lava_mat, "emission_energy_multiplier", 5.5, 1.6).set_ease(Tween.EASE_IN_OUT)


func _build_d9_sentinel_oath_wall(geom: Node) -> void:
	## Epic-9 T86: long basalt inscription wall standing behind the iron
	## sentinel statues (T84). Carved with the sentinels' oath as 4 rows
	## of glowing rune blocks plus a central guild crest plaque, framed
	## by 4 brass torch sconces along the wall length.
	var pivot: Node3D = Node3D.new()
	pivot.name = "D9_SentinelOathWall"
	# Behind the iron sentinels (T84 at +20, 0, 0; statues at +/-7 X with -PI/2 yaw)
	# The sentinels face the center; "behind" them is a couple meters further out
	# We'll place the wall at the +20 X line, slightly south of the statues
	pivot.position = D9_CENTER + Vector3(20, 0, 6)
	geom.add_child(pivot)
	# Materials
	var basalt_mat: StandardMaterial3D = StandardMaterial3D.new()
	basalt_mat.albedo_color = Color(0.10, 0.08, 0.07)
	basalt_mat.metallic = 0.20
	basalt_mat.roughness = 0.85
	basalt_mat.emission_enabled = true
	basalt_mat.emission = Color(0.45, 0.15, 0.04)
	basalt_mat.emission_energy_multiplier = 0.18
	var brass_mat: StandardMaterial3D = StandardMaterial3D.new()
	brass_mat.albedo_color = Color(0.85, 0.55, 0.18)
	brass_mat.metallic = 0.95
	brass_mat.roughness = 0.30
	brass_mat.emission_enabled = true
	brass_mat.emission = Color(1.0, 0.50, 0.10)
	brass_mat.emission_energy_multiplier = 0.55
	var rune_mat: StandardMaterial3D = StandardMaterial3D.new()
	rune_mat.albedo_color = Color(1.0, 0.55, 0.10)
	rune_mat.emission_enabled = true
	rune_mat.emission = Color(1.0, 0.55, 0.10)
	rune_mat.emission_energy_multiplier = 5.0
	rune_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var flame_mat: StandardMaterial3D = StandardMaterial3D.new()
	flame_mat.albedo_color = Color(1.0, 0.65, 0.20)
	flame_mat.emission_enabled = true
	flame_mat.emission = Color(1.0, 0.55, 0.10)
	flame_mat.emission_energy_multiplier = 8.0
	flame_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	# ---- Main wall slab ----
	var wall: MeshInstance3D = MeshInstance3D.new()
	var wm: BoxMesh = BoxMesh.new()
	wm.size = Vector3(18.0, 4.20, 0.65)
	wall.mesh = wm
	wall.material_override = basalt_mat
	wall.position = Vector3(0, 2.10, 0)
	pivot.add_child(wall)
	# Wall collision
	var wsb: StaticBody3D = StaticBody3D.new()
	wsb.position = Vector3(0, 2.10, 0)
	var wcs: CollisionShape3D = CollisionShape3D.new()
	var wbsh: BoxShape3D = BoxShape3D.new()
	wbsh.size = Vector3(18.0, 4.20, 0.65)
	wcs.shape = wbsh
	wsb.add_child(wcs)
	pivot.add_child(wsb)
	# Brass top trim
	var top_trim: MeshInstance3D = MeshInstance3D.new()
	var ttm: BoxMesh = BoxMesh.new()
	ttm.size = Vector3(18.20, 0.20, 0.85)
	top_trim.mesh = ttm
	top_trim.material_override = brass_mat
	top_trim.position = Vector3(0, 4.30, 0)
	pivot.add_child(top_trim)
	# Brass bottom trim
	var bot_trim: MeshInstance3D = MeshInstance3D.new()
	var btm: BoxMesh = BoxMesh.new()
	btm.size = Vector3(18.20, 0.20, 0.85)
	bot_trim.mesh = btm
	bot_trim.material_override = brass_mat
	bot_trim.position = Vector3(0, 0.10, 0)
	pivot.add_child(bot_trim)
	# ---- 4 rows of glowing rune blocks (small horizontal stripes) ----
	# 12 rune segments per row, distributed across the wall length, with the
	# center 2 segments left empty for the guild crest plaque
	var row_ys: Array = [1.10, 1.85, 2.60, 3.35]
	for ry in row_ys:
		for col in 12:
			# Skip center 2 columns to leave room for the crest plaque
			if col == 5 or col == 6:
				continue
			var rx: float = -8.25 + float(col) * 1.50
			var rune: MeshInstance3D = MeshInstance3D.new()
			var rmesh: BoxMesh = BoxMesh.new()
			rmesh.size = Vector3(1.10, 0.18, 0.06)
			rune.mesh = rmesh
			rune.material_override = rune_mat
			rune.position = Vector3(rx, ry, -0.34)
			pivot.add_child(rune)
	# ---- Central guild crest plaque ----
	var plaque: MeshInstance3D = MeshInstance3D.new()
	var plm: BoxMesh = BoxMesh.new()
	plm.size = Vector3(2.40, 2.80, 0.10)
	plaque.mesh = plm
	plaque.material_override = brass_mat
	plaque.position = Vector3(0, 2.20, -0.36)
	pivot.add_child(plaque)
	# Crest torus on the plaque
	var crest: MeshInstance3D = MeshInstance3D.new()
	var ctm: TorusMesh = TorusMesh.new()
	ctm.inner_radius = 0.45
	ctm.outer_radius = 0.65
	crest.mesh = ctm
	crest.material_override = rune_mat
	crest.position = Vector3(0, 2.50, -0.42)
	crest.rotation.x = PI / 2.0
	pivot.add_child(crest)
	# Crest center bar (hammer crossing the torus)
	var crest_bar: MeshInstance3D = MeshInstance3D.new()
	var cbm: BoxMesh = BoxMesh.new()
	cbm.size = Vector3(0.18, 1.20, 0.06)
	crest_bar.mesh = cbm
	crest_bar.material_override = rune_mat
	crest_bar.position = Vector3(0, 2.50, -0.44)
	pivot.add_child(crest_bar)
	# ---- 4 brass torch sconces along the wall length ----
	for tx in [-7.50, -3.00, 3.00, 7.50]:
		# Bracket — small box mounted on the wall
		var bracket: MeshInstance3D = MeshInstance3D.new()
		var bkm: BoxMesh = BoxMesh.new()
		bkm.size = Vector3(0.30, 0.18, 0.45)
		bracket.mesh = bkm
		bracket.material_override = brass_mat
		bracket.position = Vector3(tx, 2.40, -0.55)
		pivot.add_child(bracket)
		# Torch flame
		var flame: MeshInstance3D = MeshInstance3D.new()
		var flm: SphereMesh = SphereMesh.new()
		flm.radius = 0.20
		flm.height = 0.42
		flame.mesh = flm
		flame.material_override = flame_mat
		flame.position = Vector3(tx, 2.65, -0.78)
		pivot.add_child(flame)
		# Torch OmniLight
		var lt: OmniLight3D = OmniLight3D.new()
		lt.position = Vector3(tx, 2.65, -0.85)
		lt.light_color = Color(1.0, 0.55, 0.15)
		lt.light_energy = 2.4
		lt.omni_range = 6.5
		pivot.add_child(lt)
	# Rune pulse — slow breathe like words being read aloud
	var rpulse: Tween = pivot.create_tween().set_loops()
	rpulse.tween_property(rune_mat, "emission_energy_multiplier", 7.0, 2.0).set_ease(Tween.EASE_IN_OUT)
	rpulse.tween_property(rune_mat, "emission_energy_multiplier", 3.5, 2.0).set_ease(Tween.EASE_IN_OUT)
	# Torch flicker
	var fpulse: Tween = pivot.create_tween().set_loops()
	fpulse.tween_property(flame_mat, "emission_energy_multiplier", 10.0, 0.4).set_ease(Tween.EASE_IN_OUT)
	fpulse.tween_property(flame_mat, "emission_energy_multiplier", 7.0, 0.4).set_ease(Tween.EASE_IN_OUT)


func _build_d9_slag_heap_pit(geom: Node) -> void:
	## Epic-9 T87: large open pit with a glowing molten slag pile at the
	## bottom and a warning chain perimeter. Wide cylinder pit rim with
	## collision, sunken slag floor, central glowing slag mound made of
	## stacked rocks, 8 brass posts holding warning chains around the rim,
	## 4 hazard signs, and rising smoke + ember motes.
	var pivot: Node3D = Node3D.new()
	pivot.name = "D9_SlagHeapPit"
	pivot.position = D9_CENTER + Vector3(-32, 0, 0)
	geom.add_child(pivot)
	# Materials
	var basalt_mat: StandardMaterial3D = StandardMaterial3D.new()
	basalt_mat.albedo_color = Color(0.10, 0.08, 0.07)
	basalt_mat.metallic = 0.20
	basalt_mat.roughness = 0.85
	basalt_mat.emission_enabled = true
	basalt_mat.emission = Color(0.45, 0.15, 0.04)
	basalt_mat.emission_energy_multiplier = 0.20
	var slag_mat: StandardMaterial3D = StandardMaterial3D.new()
	slag_mat.albedo_color = Color(0.16, 0.10, 0.07)
	slag_mat.metallic = 0.40
	slag_mat.roughness = 0.85
	slag_mat.emission_enabled = true
	slag_mat.emission = Color(1.0, 0.30, 0.05)
	slag_mat.emission_energy_multiplier = 0.85
	var molten_mat: StandardMaterial3D = StandardMaterial3D.new()
	molten_mat.albedo_color = Color(1.0, 0.45, 0.05)
	molten_mat.emission_enabled = true
	molten_mat.emission = Color(1.0, 0.45, 0.05)
	molten_mat.emission_energy_multiplier = 7.5
	molten_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var brass_mat: StandardMaterial3D = StandardMaterial3D.new()
	brass_mat.albedo_color = Color(0.85, 0.55, 0.18)
	brass_mat.metallic = 0.95
	brass_mat.roughness = 0.30
	brass_mat.emission_enabled = true
	brass_mat.emission = Color(1.0, 0.50, 0.10)
	brass_mat.emission_energy_multiplier = 0.55
	var iron_mat: StandardMaterial3D = StandardMaterial3D.new()
	iron_mat.albedo_color = Color(0.18, 0.14, 0.11)
	iron_mat.metallic = 0.85
	iron_mat.roughness = 0.45
	# ---- Pit rim ring (collar) — wide low torus around the lip ----
	var rim: MeshInstance3D = MeshInstance3D.new()
	var rim_m: TorusMesh = TorusMesh.new()
	rim_m.inner_radius = 4.20
	rim_m.outer_radius = 5.00
	rim.mesh = rim_m
	rim.material_override = basalt_mat
	rim.position = Vector3(0, 0.20, 0)
	pivot.add_child(rim)
	# Rim collision (cylinder ring approximation)
	var rim_sb: StaticBody3D = StaticBody3D.new()
	rim_sb.position = Vector3(0, 0.20, 0)
	var rim_cs: CollisionShape3D = CollisionShape3D.new()
	var rim_cyl: CylinderShape3D = CylinderShape3D.new()
	rim_cyl.radius = maxf(5.00, 5.00)
	rim_cyl.height = 0.40
	rim_cs.shape = rim_cyl
	rim_sb.add_child(rim_cs)
	pivot.add_child(rim_sb)
	# ---- Sunken slag floor disc ----
	var floor_disc: MeshInstance3D = MeshInstance3D.new()
	var fdm: CylinderMesh = CylinderMesh.new()
	fdm.top_radius = 4.20
	fdm.bottom_radius = 4.20
	fdm.height = 0.10
	floor_disc.mesh = fdm
	floor_disc.material_override = slag_mat
	floor_disc.position = Vector3(0, 0.05, 0)
	pivot.add_child(floor_disc)
	# ---- Central slag pile (3 stacked rocks of decreasing size + glowing core) ----
	var pile_data: Array = [
		{"r": 1.40, "h": 2.55, "y": 0.65},
		{"r": 1.05, "h": 1.85, "y": 1.45},
		{"r": 0.65, "h": 1.20, "y": 2.05},
	]
	for pd in pile_data:
		var p: MeshInstance3D = MeshInstance3D.new()
		var pm: SphereMesh = SphereMesh.new()
		pm.radius = pd["r"]
		pm.height = pd["h"]
		p.mesh = pm
		p.material_override = slag_mat
		p.position = Vector3(0, pd["y"], 0)
		p.scale = Vector3(1.0, 0.65, 1.0)
		pivot.add_child(p)
	# Glowing core sphere on top of the pile
	var core: MeshInstance3D = MeshInstance3D.new()
	var corem: SphereMesh = SphereMesh.new()
	corem.radius = 0.45
	corem.height = 0.85
	core.mesh = corem
	core.material_override = molten_mat
	core.position = Vector3(0, 2.50, 0)
	pivot.add_child(core)
	# Strong central OmniLight from the slag pile
	var lt: OmniLight3D = OmniLight3D.new()
	lt.position = Vector3(0, 2.40, 0)
	lt.light_color = Color(1.0, 0.45, 0.10)
	lt.light_energy = 4.5
	lt.omni_range = 13.0
	pivot.add_child(lt)
	# ---- 8 brass posts holding warning chains around the rim ----
	var post_count: int = 8
	for i in post_count:
		var ang: float = float(i) / float(post_count) * TAU
		var px: float = cos(ang) * 4.60
		var pz: float = sin(ang) * 4.60
		# Brass post
		var post: MeshInstance3D = MeshInstance3D.new()
		var pm: CylinderMesh = CylinderMesh.new()
		pm.top_radius = 0.08
		pm.bottom_radius = 0.10
		pm.height = 1.20
		post.mesh = pm
		post.material_override = brass_mat
		post.position = Vector3(px, 0.80, pz)
		pivot.add_child(post)
		# Post cap (small sphere)
		var cap: MeshInstance3D = MeshInstance3D.new()
		var capm: SphereMesh = SphereMesh.new()
		capm.radius = 0.10
		capm.height = 0.20
		cap.mesh = capm
		cap.material_override = brass_mat
		cap.position = Vector3(px, 1.45, pz)
		pivot.add_child(cap)
		# Hanging chain to the next post — straight box approximation
		var next_ang: float = float(i + 1) / float(post_count) * TAU
		var nx: float = cos(next_ang) * 4.60
		var nz: float = sin(next_ang) * 4.60
		var mid: Vector3 = Vector3((px + nx) * 0.5, 1.05, (pz + nz) * 0.5)
		var dir: Vector3 = Vector3(nx - px, 0, nz - pz)
		var chain_len: float = dir.length()
		var chain: MeshInstance3D = MeshInstance3D.new()
		var cchm: BoxMesh = BoxMesh.new()
		cchm.size = Vector3(chain_len, 0.08, 0.08)
		chain.mesh = cchm
		chain.material_override = iron_mat
		chain.position = mid
		chain.rotation.y = atan2(dir.z, dir.x)
		pivot.add_child(chain)
	# ---- 4 hazard signs at every other post position ----
	for i in [0, 2, 4, 6]:
		var ang: float = float(i) / float(post_count) * TAU
		var px: float = cos(ang) * 4.60
		var pz: float = sin(ang) * 4.60
		# Sign post extension upward
		var ext: MeshInstance3D = MeshInstance3D.new()
		var em: BoxMesh = BoxMesh.new()
		em.size = Vector3(0.06, 0.50, 0.06)
		ext.mesh = em
		ext.material_override = brass_mat
		ext.position = Vector3(px, 1.70, pz)
		pivot.add_child(ext)
		# Hazard sign — small unshaded amber prism
		var sign_mat: StandardMaterial3D = StandardMaterial3D.new()
		sign_mat.albedo_color = Color(1.0, 0.65, 0.10)
		sign_mat.emission_enabled = true
		sign_mat.emission = Color(1.0, 0.55, 0.10)
		sign_mat.emission_energy_multiplier = 5.5
		sign_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		var sign_node: MeshInstance3D = MeshInstance3D.new()
		var sgm: PrismMesh = PrismMesh.new()
		sgm.size = Vector3(0.45, 0.45, 0.06)
		sign_node.mesh = sgm
		sign_node.material_override = sign_mat
		sign_node.position = Vector3(px, 2.00, pz)
		# Face the center
		sign_node.rotation.y = atan2(-pz, -px) + PI
		pivot.add_child(sign_node)
	# ---- Rising smoke from the slag pile ----
	var smoke: GPUParticles3D = GPUParticles3D.new()
	smoke.position = Vector3(0, 2.80, 0)
	smoke.amount = 26
	smoke.lifetime = 4.0
	var smat: ParticleProcessMaterial = ParticleProcessMaterial.new()
	smat.direction = Vector3(0, 1, 0)
	smat.spread = 22.0
	smat.initial_velocity_min = 0.6
	smat.initial_velocity_max = 1.2
	smat.gravity = Vector3(0, 0.4, 0)
	smat.scale_min = 0.25
	smat.scale_max = 0.50
	smat.color = Color(0.30, 0.25, 0.20, 0.65)
	smoke.process_material = smat
	var smkm: SphereMesh = SphereMesh.new()
	smkm.radius = 0.20
	smkm.height = 0.40
	smoke.draw_pass_1 = smkm
	pivot.add_child(smoke)
	# ---- Ember mote shower from the slag core ----
	var motes: GPUParticles3D = GPUParticles3D.new()
	motes.position = Vector3(0, 2.60, 0)
	motes.amount = 32
	motes.lifetime = 2.4
	var emat: ParticleProcessMaterial = ParticleProcessMaterial.new()
	emat.direction = Vector3(0, 1, 0)
	emat.spread = 30.0
	emat.initial_velocity_min = 1.0
	emat.initial_velocity_max = 2.0
	emat.gravity = Vector3(0, -1.5, 0)
	emat.scale_min = 0.05
	emat.scale_max = 0.10
	emat.color = Color(1.0, 0.55, 0.10, 1.0)
	motes.process_material = emat
	var psmesh: SphereMesh = SphereMesh.new()
	psmesh.radius = 0.04
	psmesh.height = 0.08
	motes.draw_pass_1 = psmesh
	pivot.add_child(motes)
	# Slag pulse + core pulse
	var spulse: Tween = pivot.create_tween().set_loops()
	spulse.tween_property(slag_mat, "emission_energy_multiplier", 1.20, 1.8).set_ease(Tween.EASE_IN_OUT)
	spulse.tween_property(slag_mat, "emission_energy_multiplier", 0.55, 1.8).set_ease(Tween.EASE_IN_OUT)
	var cpulse: Tween = pivot.create_tween().set_loops()
	cpulse.tween_property(molten_mat, "emission_energy_multiplier", 10.0, 1.4).set_ease(Tween.EASE_IN_OUT)
	cpulse.tween_property(molten_mat, "emission_energy_multiplier", 5.5, 1.4).set_ease(Tween.EASE_IN_OUT)


func _build_d9_slagmaster_borg_npc(town: Node) -> void:
	## Epic-9 T88: Slagmaster Borg — broad-shouldered foreman NPC standing
	## at the slag heap pit. Heavy heat-shielded body suit, oversized
	## brass forearm plates, full-face respirator with two glowing amber
	## filter cannisters, long iron rake held in front (stirring the slag).
	var slots: Node3D = town.get_node_or_null("NPCSlots") as Node3D
	if slots == null:
		return
	var slot: Marker3D = Marker3D.new()
	slot.name = "D9SlagmasterBorgSlot"
	# Stand at the south edge of the slag pit (pit at -32, 0; rim at radius 5)
	slot.position = Vector3(D9_CENTER.x - 32, 0, 6)
	slots.add_child(slot)
	var npc_scene: PackedScene = load("res://scenes/entities/npcs/VillagerR3.tscn") as PackedScene
	if npc_scene == null:
		return
	var npc: Node3D = npc_scene.instantiate() as Node3D
	npc.name = "D9SlagmasterBorg"
	if "npc_name" in npc:
		npc.set("npc_name", "Slagmaster Borg")
	if "npc_id" in npc:
		npc.set("npc_id", "d9_slagmaster_borg")
	# Face the pit (-Z direction)
	npc.rotation.y = PI
	slot.add_child(npc)
	# Materials
	var suit_mat: StandardMaterial3D = StandardMaterial3D.new()
	suit_mat.albedo_color = Color(0.20, 0.16, 0.13)
	suit_mat.roughness = 0.85
	suit_mat.metallic = 0.20
	suit_mat.emission_enabled = true
	suit_mat.emission = Color(0.65, 0.20, 0.05)
	suit_mat.emission_energy_multiplier = 0.18
	var brass_mat: StandardMaterial3D = StandardMaterial3D.new()
	brass_mat.albedo_color = Color(0.85, 0.55, 0.18)
	brass_mat.metallic = 0.95
	brass_mat.roughness = 0.30
	brass_mat.emission_enabled = true
	brass_mat.emission = Color(1.0, 0.50, 0.10)
	brass_mat.emission_energy_multiplier = 0.55
	var iron_mat: StandardMaterial3D = StandardMaterial3D.new()
	iron_mat.albedo_color = Color(0.18, 0.14, 0.11)
	iron_mat.metallic = 0.85
	iron_mat.roughness = 0.45
	iron_mat.emission_enabled = true
	iron_mat.emission = Color(0.85, 0.25, 0.05)
	iron_mat.emission_energy_multiplier = 0.30
	var amber_mat: StandardMaterial3D = StandardMaterial3D.new()
	amber_mat.albedo_color = Color(1.0, 0.55, 0.10)
	amber_mat.emission_enabled = true
	amber_mat.emission = Color(1.0, 0.55, 0.10)
	amber_mat.emission_energy_multiplier = 6.0
	amber_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	# ---- Heavy heat-shielded body suit (wide chest box) ----
	var torso: MeshInstance3D = MeshInstance3D.new()
	var tm: BoxMesh = BoxMesh.new()
	tm.size = Vector3(1.30, 1.55, 0.85)
	torso.mesh = tm
	torso.material_override = suit_mat
	torso.position = Vector3(0, 1.20, 0)
	npc.add_child(torso)
	# Brass chest plate seam
	var chest_seam: MeshInstance3D = MeshInstance3D.new()
	var csm: BoxMesh = BoxMesh.new()
	csm.size = Vector3(0.20, 1.40, 0.06)
	chest_seam.mesh = csm
	chest_seam.material_override = brass_mat
	chest_seam.position = Vector3(0, 1.20, -0.44)
	npc.add_child(chest_seam)
	# Glowing amber chest core dot
	var chest_core: MeshInstance3D = MeshInstance3D.new()
	var ccm: SphereMesh = SphereMesh.new()
	ccm.radius = 0.08
	ccm.height = 0.16
	chest_core.mesh = ccm
	chest_core.material_override = amber_mat
	chest_core.position = Vector3(0, 1.45, -0.46)
	npc.add_child(chest_core)
	# ---- Oversized brass forearm plates ----
	for ax in [-0.75, 0.75]:
		var arm: MeshInstance3D = MeshInstance3D.new()
		var amm: BoxMesh = BoxMesh.new()
		amm.size = Vector3(0.30, 0.65, 0.32)
		arm.mesh = amm
		arm.material_override = brass_mat
		arm.position = Vector3(ax, 1.10, 0.10)
		npc.add_child(arm)
	# ---- Full-face respirator helm ----
	var helm: MeshInstance3D = MeshInstance3D.new()
	var hmm: BoxMesh = BoxMesh.new()
	hmm.size = Vector3(0.85, 0.85, 0.80)
	helm.mesh = hmm
	helm.material_override = iron_mat
	helm.position = Vector3(0, 2.15, 0)
	npc.add_child(helm)
	# Helm crown ridge (small prism)
	var crown: MeshInstance3D = MeshInstance3D.new()
	var crm: PrismMesh = PrismMesh.new()
	crm.size = Vector3(0.85, 0.20, 0.30)
	crown.mesh = crm
	crown.material_override = brass_mat
	crown.position = Vector3(0, 2.65, 0)
	npc.add_child(crown)
	# Two glowing amber filter cannisters jutting from each side of the helm
	for fx in [-0.50, 0.50]:
		var cannister: MeshInstance3D = MeshInstance3D.new()
		var cnm: CylinderMesh = CylinderMesh.new()
		cnm.top_radius = 0.10
		cnm.bottom_radius = 0.12
		cnm.height = 0.30
		cannister.mesh = cnm
		cannister.material_override = brass_mat
		cannister.position = Vector3(fx, 2.10, -0.35)
		cannister.rotation.x = PI / 2.0
		npc.add_child(cannister)
		# Glowing filter end-cap
		var cap: MeshInstance3D = MeshInstance3D.new()
		var capm: SphereMesh = SphereMesh.new()
		capm.radius = 0.10
		capm.height = 0.20
		cap.mesh = capm
		cap.material_override = amber_mat
		cap.position = Vector3(fx, 2.10, -0.50)
		npc.add_child(cap)
	# Helm visor band — thin glowing horizontal stripe across the front
	var visor: MeshInstance3D = MeshInstance3D.new()
	var vm: BoxMesh = BoxMesh.new()
	vm.size = Vector3(0.65, 0.06, 0.04)
	visor.mesh = vm
	visor.material_override = amber_mat
	visor.position = Vector3(0, 2.20, -0.42)
	npc.add_child(visor)
	# ---- Long iron rake held in front (stirring the slag) ----
	var rake_pivot: Node3D = Node3D.new()
	rake_pivot.position = Vector3(0, 1.20, -0.50)
	npc.add_child(rake_pivot)
	# Rake shaft (long cylinder)
	var rake_shaft: MeshInstance3D = MeshInstance3D.new()
	var rsm: CylinderMesh = CylinderMesh.new()
	rsm.top_radius = 0.05
	rsm.bottom_radius = 0.06
	rsm.height = 2.10
	rake_shaft.mesh = rsm
	rake_shaft.material_override = iron_mat
	rake_shaft.position = Vector3(0, 0, -0.70)
	rake_shaft.rotation.x = PI / 2.0
	rake_pivot.add_child(rake_shaft)
	# Rake head (wide flat box)
	var rake_head: MeshInstance3D = MeshInstance3D.new()
	var rhm: BoxMesh = BoxMesh.new()
	rhm.size = Vector3(0.55, 0.10, 0.20)
	rake_head.mesh = rhm
	rake_head.material_override = iron_mat
	rake_head.position = Vector3(0, 0, -1.80)
	rake_pivot.add_child(rake_head)
	# 4 rake teeth (small box prongs)
	for tx in [-0.20, -0.07, 0.07, 0.20]:
		var tooth: MeshInstance3D = MeshInstance3D.new()
		var thm: BoxMesh = BoxMesh.new()
		thm.size = Vector3(0.05, 0.20, 0.05)
		tooth.mesh = thm
		tooth.material_override = iron_mat
		tooth.position = Vector3(tx, -0.13, -1.80)
		rake_pivot.add_child(tooth)
	# Rake stir tween — slow horizontal sweep like stirring the pit
	var stir: Tween = npc.create_tween().set_loops()
	stir.tween_property(rake_pivot, "rotation:y", 0.35, 2.0).set_ease(Tween.EASE_IN_OUT)
	stir.tween_property(rake_pivot, "rotation:y", -0.35, 2.0).set_ease(Tween.EASE_IN_OUT)
	# Warm OmniLight from helm filters
	var lt: OmniLight3D = OmniLight3D.new()
	lt.position = Vector3(0, 2.20, -0.40)
	lt.light_color = Color(1.0, 0.55, 0.15)
	lt.light_energy = 2.0
	lt.omni_range = 5.0
	npc.add_child(lt)
	# Filter + visor pulse
	var fpulse: Tween = npc.create_tween().set_loops()
	fpulse.tween_property(amber_mat, "emission_energy_multiplier", 8.0, 1.4).set_ease(Tween.EASE_IN_OUT)
	fpulse.tween_property(amber_mat, "emission_energy_multiplier", 5.0, 1.4).set_ease(Tween.EASE_IN_OUT)


func _build_d9_sky_cinder_fall(geom: Node) -> void:
	## Epic-9 T89: district-wide sky-cinder fall ambient. 4 GPUParticles3D
	## emitters spaced across D9 raining downward ember motes from the
	## sky to give the whole district volcanic ashfall ambience. Each
	## emitter covers a wide horizontal box and uses a slow downward
	## drift with mild gravity.
	var pivot: Node3D = Node3D.new()
	pivot.name = "D9_SkyCinderFall"
	pivot.position = D9_CENTER + Vector3(0, 18.0, 0)
	geom.add_child(pivot)
	# Cinder mote material — small unshaded amber dots
	var ember_mesh: SphereMesh = SphereMesh.new()
	ember_mesh.radius = 0.05
	ember_mesh.height = 0.10
	# 4 emitters spread across D9's footprint
	# Use overlapping wide boxes so the rain feels continuous
	var emitter_data: Array = [
		{"pos": Vector3(-25.0, 0, -15.0), "amount": 60, "color": Color(1.0, 0.55, 0.10, 1.0)},
		{"pos": Vector3(25.0, 0, -15.0), "amount": 60, "color": Color(1.0, 0.55, 0.10, 1.0)},
		{"pos": Vector3(-25.0, 0, 15.0), "amount": 60, "color": Color(1.0, 0.50, 0.10, 1.0)},
		{"pos": Vector3(25.0, 0, 15.0), "amount": 60, "color": Color(1.0, 0.50, 0.10, 1.0)},
	]
	for ed in emitter_data:
		var emit: GPUParticles3D = GPUParticles3D.new()
		emit.position = ed["pos"]
		emit.amount = ed["amount"]
		emit.lifetime = 8.0
		var pmat: ParticleProcessMaterial = ParticleProcessMaterial.new()
		pmat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
		pmat.emission_box_extents = Vector3(18.0, 0.5, 18.0)
		pmat.direction = Vector3(0, -1, 0)
		pmat.spread = 8.0
		pmat.initial_velocity_min = 0.6
		pmat.initial_velocity_max = 1.2
		pmat.gravity = Vector3(0, -0.4, 0)
		pmat.scale_min = 0.6
		pmat.scale_max = 1.2
		pmat.color = ed["color"]
		emit.process_material = pmat
		emit.draw_pass_1 = ember_mesh
		pivot.add_child(emit)
	# Subtle ash drift overlay — slower, larger, darker particles for variety
	var ash: GPUParticles3D = GPUParticles3D.new()
	ash.position = Vector3(0, 0, 0)
	ash.amount = 80
	ash.lifetime = 12.0
	var amat: ParticleProcessMaterial = ParticleProcessMaterial.new()
	amat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	amat.emission_box_extents = Vector3(35.0, 0.5, 35.0)
	amat.direction = Vector3(0, -1, 0)
	amat.spread = 12.0
	amat.initial_velocity_min = 0.3
	amat.initial_velocity_max = 0.6
	amat.gravity = Vector3(0.4, -0.25, 0)
	amat.scale_min = 0.20
	amat.scale_max = 0.40
	amat.color = Color(0.45, 0.30, 0.18, 0.55)
	ash.process_material = amat
	var amesh: SphereMesh = SphereMesh.new()
	amesh.radius = 0.10
	amesh.height = 0.20
	ash.draw_pass_1 = amesh
	pivot.add_child(ash)


func _build_d9_forge_heart_acolyte_npc(town: Node) -> void:
	## Epic-9 T90: Forge Heart Acolyte — kneeling worshipper at the central
	## forge heart. Long red-orange ceremonial robe, tall conical hood,
	## brass forge-hammer offering held in front, sash with 3 brass tokens
	## at the waist, and a slow forward-bow tween that sells the prayer.
	var slots: Node3D = town.get_node_or_null("NPCSlots") as Node3D
	if slots == null:
		return
	var slot: Marker3D = Marker3D.new()
	slot.name = "D9ForgeHeartAcolyteSlot"
	# Stand near the forge heart at D9 center, just south of it
	slot.position = Vector3(D9_CENTER.x + 4, 0, 6)
	slots.add_child(slot)
	var npc_scene: PackedScene = load("res://scenes/entities/npcs/VillagerR3.tscn") as PackedScene
	if npc_scene == null:
		return
	var npc: Node3D = npc_scene.instantiate() as Node3D
	npc.name = "D9ForgeHeartAcolyte"
	if "npc_name" in npc:
		npc.set("npc_name", "Forge Heart Acolyte")
	if "npc_id" in npc:
		npc.set("npc_id", "d9_forge_heart_acolyte")
	# Face the forge heart (-Z direction)
	npc.rotation.y = PI
	slot.add_child(npc)
	# Materials
	var robe_mat: StandardMaterial3D = StandardMaterial3D.new()
	robe_mat.albedo_color = Color(0.55, 0.18, 0.10)
	robe_mat.roughness = 0.85
	robe_mat.metallic = 0.10
	robe_mat.emission_enabled = true
	robe_mat.emission = Color(0.85, 0.30, 0.05)
	robe_mat.emission_energy_multiplier = 0.30
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
	amber_mat.emission_energy_multiplier = 6.0
	amber_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	# ---- Long red-orange ceremonial robe (tall narrow box) ----
	var robe: MeshInstance3D = MeshInstance3D.new()
	var rmesh: BoxMesh = BoxMesh.new()
	rmesh.size = Vector3(0.95, 1.75, 0.55)
	robe.mesh = rmesh
	robe.material_override = robe_mat
	robe.position = Vector3(0, 0.90, 0)
	npc.add_child(robe)
	# Brass robe collar trim
	var collar: MeshInstance3D = MeshInstance3D.new()
	var colm: BoxMesh = BoxMesh.new()
	colm.size = Vector3(0.95, 0.10, 0.55)
	collar.mesh = colm
	collar.material_override = brass_mat
	collar.position = Vector3(0, 1.75, 0)
	npc.add_child(collar)
	# Brass vertical front stripe (chest seam)
	var seam: MeshInstance3D = MeshInstance3D.new()
	var sm: BoxMesh = BoxMesh.new()
	sm.size = Vector3(0.16, 1.55, 0.06)
	seam.mesh = sm
	seam.material_override = brass_mat
	seam.position = Vector3(0, 0.92, -0.30)
	npc.add_child(seam)
	# Glowing chest core dot
	var chest_core: MeshInstance3D = MeshInstance3D.new()
	var ccm: SphereMesh = SphereMesh.new()
	ccm.radius = 0.07
	ccm.height = 0.14
	chest_core.mesh = ccm
	chest_core.material_override = amber_mat
	chest_core.position = Vector3(0, 1.30, -0.32)
	npc.add_child(chest_core)
	# ---- Tall conical hood — prism cap ----
	var hood: MeshInstance3D = MeshInstance3D.new()
	var hmm: PrismMesh = PrismMesh.new()
	hmm.size = Vector3(0.65, 1.05, 0.65)
	hood.mesh = hmm
	hood.material_override = robe_mat
	hood.position = Vector3(0, 2.30, 0)
	npc.add_child(hood)
	# Hood brass base trim
	var hood_trim: MeshInstance3D = MeshInstance3D.new()
	var htm: BoxMesh = BoxMesh.new()
	htm.size = Vector3(0.75, 0.08, 0.75)
	hood_trim.mesh = htm
	hood_trim.material_override = brass_mat
	hood_trim.position = Vector3(0, 1.85, 0)
	npc.add_child(hood_trim)
	# Hood glowing tip ember
	var hood_tip: MeshInstance3D = MeshInstance3D.new()
	var htipm: SphereMesh = SphereMesh.new()
	htipm.radius = 0.08
	htipm.height = 0.16
	hood_tip.mesh = htipm
	hood_tip.material_override = amber_mat
	hood_tip.position = Vector3(0, 2.80, 0)
	npc.add_child(hood_tip)
	# ---- Brass forge-hammer offering held in front of the body ----
	# Hammer pivot — anchor at his cupped hands
	var hammer_pivot: Node3D = Node3D.new()
	hammer_pivot.position = Vector3(0, 1.05, -0.45)
	npc.add_child(hammer_pivot)
	# Hammer handle (brass cylinder)
	var handle: MeshInstance3D = MeshInstance3D.new()
	var hcm: CylinderMesh = CylinderMesh.new()
	hcm.top_radius = 0.04
	hcm.bottom_radius = 0.05
	hcm.height = 0.50
	handle.mesh = hcm
	handle.material_override = brass_mat
	handle.position = Vector3(0, 0, 0)
	handle.rotation.x = PI / 2.0
	hammer_pivot.add_child(handle)
	# Hammer head (brass box)
	var head: MeshInstance3D = MeshInstance3D.new()
	var headm: BoxMesh = BoxMesh.new()
	headm.size = Vector3(0.20, 0.18, 0.30)
	head.mesh = headm
	head.material_override = brass_mat
	head.position = Vector3(0, 0, -0.30)
	hammer_pivot.add_child(head)
	# Glowing hammer core stripe — unshaded amber
	var hcore: MeshInstance3D = MeshInstance3D.new()
	var hcormesh: BoxMesh = BoxMesh.new()
	hcormesh.size = Vector3(0.06, 0.20, 0.06)
	hcore.mesh = hcormesh
	hcore.material_override = amber_mat
	hcore.position = Vector3(0, 0, -0.30)
	hammer_pivot.add_child(hcore)
	# ---- Sash with 3 brass tokens at the waist ----
	# Sash band
	var sash: MeshInstance3D = MeshInstance3D.new()
	var sashm: BoxMesh = BoxMesh.new()
	sashm.size = Vector3(0.95, 0.12, 0.58)
	sash.mesh = sashm
	sash.material_override = brass_mat
	sash.position = Vector3(0, 0.95, 0)
	npc.add_child(sash)
	# 3 small brass token spheres hanging from the sash front
	for tx in [-0.25, 0.0, 0.25]:
		var token: MeshInstance3D = MeshInstance3D.new()
		var tkm: SphereMesh = SphereMesh.new()
		tkm.radius = 0.06
		tkm.height = 0.12
		token.mesh = tkm
		token.material_override = brass_mat
		token.position = Vector3(tx, 0.78, -0.32)
		npc.add_child(token)
	# Warm OmniLight aura
	var lt: OmniLight3D = OmniLight3D.new()
	lt.position = Vector3(0, 1.50, -0.30)
	lt.light_color = Color(1.0, 0.55, 0.15)
	lt.light_energy = 1.8
	lt.omni_range = 4.5
	npc.add_child(lt)
	# ---- Slow forward-bow tween — body rocks forward to sell the prayer ----
	var bow: Tween = npc.create_tween().set_loops()
	bow.tween_property(npc, "rotation:x", 0.22, 2.0).set_ease(Tween.EASE_IN_OUT)
	bow.tween_property(npc, "rotation:x", 0.05, 2.0).set_ease(Tween.EASE_IN_OUT)
	# Hood-tip + chest core + hammer core pulse (shared amber material)
	var apulse: Tween = npc.create_tween().set_loops()
	apulse.tween_property(amber_mat, "emission_energy_multiplier", 8.0, 1.6).set_ease(Tween.EASE_IN_OUT)
	apulse.tween_property(amber_mat, "emission_energy_multiplier", 4.5, 1.6).set_ease(Tween.EASE_IN_OUT)


func _build_d9_boss_approach_gate(geom: Node) -> void:
	## Epic-9 T91: pair of tall runic warning pillars marking the entrance
	## to the FORGE LORD's approach. 8m basalt obelisk pillars with brass
	## bands, vertical glowing rune stripes, crowning ember braziers, and
	## warning chains hanging between them across the path.
	var pivot: Node3D = Node3D.new()
	pivot.name = "D9_BossApproachGate"
	# South of the boss arena (which will go at -22 Z)
	pivot.position = D9_CENTER + Vector3(0, 0, -16)
	geom.add_child(pivot)
	# Materials
	var basalt_mat: StandardMaterial3D = StandardMaterial3D.new()
	basalt_mat.albedo_color = Color(0.10, 0.08, 0.07)
	basalt_mat.metallic = 0.20
	basalt_mat.roughness = 0.85
	basalt_mat.emission_enabled = true
	basalt_mat.emission = Color(0.55, 0.18, 0.05)
	basalt_mat.emission_energy_multiplier = 0.20
	var brass_mat: StandardMaterial3D = StandardMaterial3D.new()
	brass_mat.albedo_color = Color(0.85, 0.55, 0.18)
	brass_mat.metallic = 0.95
	brass_mat.roughness = 0.30
	brass_mat.emission_enabled = true
	brass_mat.emission = Color(1.0, 0.50, 0.10)
	brass_mat.emission_energy_multiplier = 0.55
	var iron_mat: StandardMaterial3D = StandardMaterial3D.new()
	iron_mat.albedo_color = Color(0.18, 0.14, 0.11)
	iron_mat.metallic = 0.85
	iron_mat.roughness = 0.45
	var rune_mat: StandardMaterial3D = StandardMaterial3D.new()
	rune_mat.albedo_color = Color(1.0, 0.45, 0.05)
	rune_mat.emission_enabled = true
	rune_mat.emission = Color(1.0, 0.45, 0.05)
	rune_mat.emission_energy_multiplier = 6.5
	rune_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var flame_mat: StandardMaterial3D = StandardMaterial3D.new()
	flame_mat.albedo_color = Color(1.0, 0.65, 0.20)
	flame_mat.emission_enabled = true
	flame_mat.emission = Color(1.0, 0.55, 0.10)
	flame_mat.emission_energy_multiplier = 9.0
	flame_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	# Build a pillar at +/- offset
	for px in [-5.5, 5.5]:
		var pgroup: Node3D = Node3D.new()
		pgroup.name = "Pillar_" + str(int(px))
		pgroup.position = Vector3(px, 0, 0)
		pivot.add_child(pgroup)
		# ---- Stepped basalt base (2 levels) ----
		var base1: MeshInstance3D = MeshInstance3D.new()
		var b1m: BoxMesh = BoxMesh.new()
		b1m.size = Vector3(2.20, 0.50, 2.20)
		base1.mesh = b1m
		base1.material_override = basalt_mat
		base1.position = Vector3(0, 0.25, 0)
		pgroup.add_child(base1)
		var base2: MeshInstance3D = MeshInstance3D.new()
		var b2m: BoxMesh = BoxMesh.new()
		b2m.size = Vector3(1.70, 0.40, 1.70)
		base2.mesh = b2m
		base2.material_override = basalt_mat
		base2.position = Vector3(0, 0.70, 0)
		pgroup.add_child(base2)
		# Base collision
		var base_sb: StaticBody3D = StaticBody3D.new()
		base_sb.position = Vector3(0, 0.45, 0)
		var base_cs: CollisionShape3D = CollisionShape3D.new()
		var base_bsh: BoxShape3D = BoxShape3D.new()
		base_bsh.size = Vector3(2.20, 0.90, 2.20)
		base_cs.shape = base_bsh
		base_sb.add_child(base_cs)
		pgroup.add_child(base_sb)
		# ---- Tall pillar shaft (8m basalt obelisk) ----
		var shaft: MeshInstance3D = MeshInstance3D.new()
		var sm: BoxMesh = BoxMesh.new()
		sm.size = Vector3(1.20, 8.00, 1.20)
		shaft.mesh = sm
		shaft.material_override = basalt_mat
		shaft.position = Vector3(0, 4.90, 0)
		pgroup.add_child(shaft)
		# Shaft collision
		var sb: StaticBody3D = StaticBody3D.new()
		sb.position = Vector3(0, 4.90, 0)
		var cs: CollisionShape3D = CollisionShape3D.new()
		var bsh: BoxShape3D = BoxShape3D.new()
		bsh.size = Vector3(1.20, 8.00, 1.20)
		cs.shape = bsh
		sb.add_child(cs)
		pgroup.add_child(sb)
		# ---- 3 brass bands wrapping the shaft ----
		for by in [2.40, 5.20, 7.80]:
			var band: MeshInstance3D = MeshInstance3D.new()
			var bm: BoxMesh = BoxMesh.new()
			bm.size = Vector3(1.30, 0.18, 1.30)
			band.mesh = bm
			band.material_override = brass_mat
			band.position = Vector3(0, by, 0)
			pgroup.add_child(band)
		# ---- Vertical glowing rune stripe down the inner face ----
		# Inner face = side facing the path center (+/- X depending on side)
		var inner_z_sign: float = 1.0 if px > 0 else -1.0
		var rune: MeshInstance3D = MeshInstance3D.new()
		var rmesh: BoxMesh = BoxMesh.new()
		rmesh.size = Vector3(0.18, 6.50, 0.06)
		rune.mesh = rmesh
		rune.material_override = rune_mat
		rune.position = Vector3(-0.62 * inner_z_sign, 4.90, 0)
		pgroup.add_child(rune)
		# 4 rune crossbars on the stripe
		for ry in [3.00, 4.50, 6.00, 7.50]:
			var cross: MeshInstance3D = MeshInstance3D.new()
			var cmm: BoxMesh = BoxMesh.new()
			cmm.size = Vector3(0.06, 0.10, 0.40)
			cross.mesh = cmm
			cross.material_override = rune_mat
			cross.position = Vector3(-0.65 * inner_z_sign, ry, 0)
			pgroup.add_child(cross)
		# ---- Crowning ember brazier on top ----
		# Brazier bowl
		var bowl: MeshInstance3D = MeshInstance3D.new()
		var bowm: SphereMesh = SphereMesh.new()
		bowm.radius = 0.45
		bowm.height = 0.75
		bowl.mesh = bowm
		bowl.material_override = brass_mat
		bowl.position = Vector3(0, 9.30, 0)
		bowl.scale = Vector3(1.0, 0.55, 1.0)
		pgroup.add_child(bowl)
		# Brazier flame
		var flame: MeshInstance3D = MeshInstance3D.new()
		var flm: SphereMesh = SphereMesh.new()
		flm.radius = 0.35
		flm.height = 0.70
		flame.mesh = flm
		flame.material_override = flame_mat
		flame.position = Vector3(0, 9.65, 0)
		pgroup.add_child(flame)
		# Brazier OmniLight
		var lt: OmniLight3D = OmniLight3D.new()
		lt.position = Vector3(0, 9.65, 0)
		lt.light_color = Color(1.0, 0.55, 0.15)
		lt.light_energy = 4.5
		lt.omni_range = 14.0
		pgroup.add_child(lt)
		# Ember mote shower from each brazier
		var motes: GPUParticles3D = GPUParticles3D.new()
		motes.position = Vector3(0, 9.85, 0)
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
	# ---- Iron warning chains hanging between the pillars (3 sagging rows) ----
	for cy in [3.20, 5.20, 7.20]:
		var chain: MeshInstance3D = MeshInstance3D.new()
		var chm: BoxMesh = BoxMesh.new()
		chm.size = Vector3(11.00, 0.10, 0.10)
		chain.mesh = chm
		chain.material_override = iron_mat
		chain.position = Vector3(0, cy, 0)
		pivot.add_child(chain)
	# ---- Pulse: rune + flame breathe ----
	var rpulse: Tween = pivot.create_tween().set_loops()
	rpulse.tween_property(rune_mat, "emission_energy_multiplier", 9.0, 1.8).set_ease(Tween.EASE_IN_OUT)
	rpulse.tween_property(rune_mat, "emission_energy_multiplier", 5.0, 1.8).set_ease(Tween.EASE_IN_OUT)
	var fpulse: Tween = pivot.create_tween().set_loops()
	fpulse.tween_property(flame_mat, "emission_energy_multiplier", 11.0, 0.5).set_ease(Tween.EASE_IN_OUT)
	fpulse.tween_property(flame_mat, "emission_energy_multiplier", 8.0, 0.5).set_ease(Tween.EASE_IN_OUT)


func _build_d9_boss_approach_skull_pile(geom: Node) -> void:
	## Epic-9 T92: dramatic warning pile of charred skulls and broken
	## weapons past the boss approach gate. 12 skull spheres in a low
	## mound, 4 broken weapon shafts jutting out, scorch decals, and
	## ember motes rising from the pile. Tells players "many died here".
	var pivot: Node3D = Node3D.new()
	pivot.name = "D9_BossApproachSkullPile"
	# Just past the approach gate (gate at -16 Z), on the centerline
	pivot.position = D9_CENTER + Vector3(0, 0, -18)
	geom.add_child(pivot)
	# Materials
	var skull_mat: StandardMaterial3D = StandardMaterial3D.new()
	skull_mat.albedo_color = Color(0.62, 0.55, 0.45)
	skull_mat.roughness = 0.85
	skull_mat.metallic = 0.10
	skull_mat.emission_enabled = true
	skull_mat.emission = Color(0.55, 0.20, 0.05)
	skull_mat.emission_energy_multiplier = 0.30
	var charred_mat: StandardMaterial3D = StandardMaterial3D.new()
	charred_mat.albedo_color = Color(0.18, 0.13, 0.10)
	charred_mat.roughness = 0.92
	charred_mat.metallic = 0.10
	charred_mat.emission_enabled = true
	charred_mat.emission = Color(0.85, 0.25, 0.05)
	charred_mat.emission_energy_multiplier = 0.45
	var iron_mat: StandardMaterial3D = StandardMaterial3D.new()
	iron_mat.albedo_color = Color(0.18, 0.14, 0.11)
	iron_mat.metallic = 0.85
	iron_mat.roughness = 0.45
	iron_mat.emission_enabled = true
	iron_mat.emission = Color(0.85, 0.25, 0.05)
	iron_mat.emission_energy_multiplier = 0.30
	var ember_mat: StandardMaterial3D = StandardMaterial3D.new()
	ember_mat.albedo_color = Color(1.0, 0.55, 0.10)
	ember_mat.emission_enabled = true
	ember_mat.emission = Color(1.0, 0.55, 0.10)
	ember_mat.emission_energy_multiplier = 5.0
	ember_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	# ---- Charred ground patch (low circular slab) ----
	var ground: MeshInstance3D = MeshInstance3D.new()
	var gm: CylinderMesh = CylinderMesh.new()
	gm.top_radius = 2.20
	gm.bottom_radius = 2.30
	gm.height = 0.06
	ground.mesh = gm
	ground.material_override = charred_mat
	ground.position = Vector3(0, 0.04, 0)
	pivot.add_child(ground)
	# ---- 12 charred skull spheres in a low mound ----
	# Skulls have a body sphere + 2 dark eye sockets each
	var skull_data: Array = [
		# Bottom layer — 7 skulls
		{"pos": Vector3(0.0, 0.30, 0.0), "rot": 0.0},
		{"pos": Vector3(0.55, 0.30, 0.20), "rot": 0.6},
		{"pos": Vector3(-0.55, 0.30, 0.20), "rot": -0.6},
		{"pos": Vector3(0.30, 0.30, -0.55), "rot": 0.3},
		{"pos": Vector3(-0.30, 0.30, -0.55), "rot": -0.3},
		{"pos": Vector3(0.85, 0.30, -0.20), "rot": 1.0},
		{"pos": Vector3(-0.85, 0.30, -0.20), "rot": -1.0},
		# Mid layer — 4 skulls
		{"pos": Vector3(0.20, 0.65, 0.10), "rot": 0.20},
		{"pos": Vector3(-0.20, 0.65, 0.10), "rot": -0.20},
		{"pos": Vector3(0.0, 0.65, -0.40), "rot": 0.50},
		{"pos": Vector3(0.40, 0.65, -0.30), "rot": -0.30},
		# Top — 1 crowning skull
		{"pos": Vector3(0.0, 0.95, -0.10), "rot": 0.80},
	]
	for sd in skull_data:
		var sp: Vector3 = sd["pos"]
		# Skull body
		var skull: MeshInstance3D = MeshInstance3D.new()
		var smm: SphereMesh = SphereMesh.new()
		smm.radius = 0.18
		smm.height = 0.34
		skull.mesh = smm
		skull.material_override = skull_mat
		skull.position = sp
		skull.rotation.y = sd["rot"]
		skull.scale = Vector3(1.0, 0.95, 1.05)
		pivot.add_child(skull)
		# 2 dark eye sockets — small dark boxes pressed into the front
		var eye_dir: Vector3 = Vector3(sin(sd["rot"]), 0, -cos(sd["rot"]))
		for ex in [-0.06, 0.06]:
			var perp: Vector3 = Vector3(cos(sd["rot"]), 0, sin(sd["rot"]))
			var eye: MeshInstance3D = MeshInstance3D.new()
			var em: BoxMesh = BoxMesh.new()
			em.size = Vector3(0.05, 0.05, 0.04)
			eye.mesh = em
			eye.material_override = charred_mat
			eye.position = sp + eye_dir * 0.14 + perp * ex + Vector3(0, 0.02, 0)
			pivot.add_child(eye)
	# ---- 4 broken weapon shafts jutting out of the pile ----
	var weapon_data: Array = [
		{"pos": Vector3(1.20, 0.55, 0.40), "len": 1.40, "tilt_x": -0.30, "tilt_z": 0.50},
		{"pos": Vector3(-1.10, 0.50, -0.30), "len": 1.20, "tilt_x": 0.40, "tilt_z": -0.40},
		{"pos": Vector3(0.40, 0.70, -0.95), "len": 1.55, "tilt_x": -0.50, "tilt_z": 0.20},
		{"pos": Vector3(-0.50, 0.65, 0.85), "len": 1.10, "tilt_x": 0.30, "tilt_z": -0.60},
	]
	for wd in weapon_data:
		var wp: Vector3 = wd["pos"]
		var wlen: float = wd["len"]
		var shaft: MeshInstance3D = MeshInstance3D.new()
		var sm: CylinderMesh = CylinderMesh.new()
		sm.top_radius = 0.04
		sm.bottom_radius = 0.05
		sm.height = wlen
		shaft.mesh = sm
		shaft.material_override = iron_mat
		shaft.position = wp + Vector3(0, wlen * 0.40, 0)
		shaft.rotation = Vector3(wd["tilt_x"], 0, wd["tilt_z"])
		pivot.add_child(shaft)
		# Broken jagged tip — small prism at the top
		var tip: MeshInstance3D = MeshInstance3D.new()
		var tipm: PrismMesh = PrismMesh.new()
		tipm.size = Vector3(0.10, 0.20, 0.06)
		tip.mesh = tipm
		tip.material_override = iron_mat
		# Estimate tip position by extrapolating along the rotation
		var tip_dir: Vector3 = Vector3(sin(wd["tilt_z"]), cos(wd["tilt_z"]) * cos(wd["tilt_x"]), -sin(wd["tilt_x"]) * cos(wd["tilt_z"]))
		tip.position = wp + tip_dir * (wlen * 0.85)
		tip.rotation = Vector3(wd["tilt_x"], 0, wd["tilt_z"])
		pivot.add_child(tip)
	# ---- Glowing ember cluster on top of the pile ----
	var cluster: MeshInstance3D = MeshInstance3D.new()
	var clm: SphereMesh = SphereMesh.new()
	clm.radius = 0.18
	clm.height = 0.36
	cluster.mesh = clm
	cluster.material_override = ember_mat
	cluster.position = Vector3(0, 1.18, -0.10)
	pivot.add_child(cluster)
	# Pile OmniLight
	var lt: OmniLight3D = OmniLight3D.new()
	lt.position = Vector3(0, 1.30, 0)
	lt.light_color = Color(1.0, 0.55, 0.15)
	lt.light_energy = 2.6
	lt.omni_range = 7.5
	pivot.add_child(lt)
	# Rising ember motes from the pile
	var motes: GPUParticles3D = GPUParticles3D.new()
	motes.position = Vector3(0, 1.20, 0)
	motes.amount = 22
	motes.lifetime = 2.2
	var pmat: ParticleProcessMaterial = ParticleProcessMaterial.new()
	pmat.direction = Vector3(0, 1, 0)
	pmat.spread = 22.0
	pmat.initial_velocity_min = 0.5
	pmat.initial_velocity_max = 1.0
	pmat.gravity = Vector3(0, 0.3, 0)
	pmat.scale_min = 0.05
	pmat.scale_max = 0.10
	pmat.color = Color(1.0, 0.55, 0.10, 1.0)
	motes.process_material = pmat
	var psmesh: SphereMesh = SphereMesh.new()
	psmesh.radius = 0.04
	psmesh.height = 0.08
	motes.draw_pass_1 = psmesh
	pivot.add_child(motes)
	# Ember pulse
	var epulse: Tween = pivot.create_tween().set_loops()
	epulse.tween_property(ember_mat, "emission_energy_multiplier", 7.0, 1.4).set_ease(Tween.EASE_IN_OUT)
	epulse.tween_property(ember_mat, "emission_energy_multiplier", 4.0, 1.4).set_ease(Tween.EASE_IN_OUT)


func _build_d9_boss_approach_sentinels(geom: Node) -> void:
	## Epic-9 T93: 6 small armored forge guardian sentinels flanking the
	## boss approach path between the gate and the arena. 3 per side, each
	## a stocky armored body box on a basalt plinth, helm with glowing
	## visor slit, vertical sword held in front, and a glowing chest core.
	var pivot: Node3D = Node3D.new()
	pivot.name = "D9_BossApproachSentinels"
	pivot.position = D9_CENTER + Vector3(0, 0, -20)
	geom.add_child(pivot)
	# Materials
	var basalt_mat: StandardMaterial3D = StandardMaterial3D.new()
	basalt_mat.albedo_color = Color(0.10, 0.08, 0.07)
	basalt_mat.metallic = 0.20
	basalt_mat.roughness = 0.85
	basalt_mat.emission_enabled = true
	basalt_mat.emission = Color(0.45, 0.15, 0.04)
	basalt_mat.emission_energy_multiplier = 0.20
	var iron_mat: StandardMaterial3D = StandardMaterial3D.new()
	iron_mat.albedo_color = Color(0.18, 0.14, 0.11)
	iron_mat.metallic = 0.85
	iron_mat.roughness = 0.45
	iron_mat.emission_enabled = true
	iron_mat.emission = Color(0.65, 0.20, 0.05)
	iron_mat.emission_energy_multiplier = 0.30
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
	ember_mat.emission_energy_multiplier = 6.0
	ember_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	# 6 sentinels — 3 per side, marching toward the arena
	# Side X is +/- 3.5 (path is ~7m wide), Z spaced 0, -3, -6 along the path
	var sentinel_positions: Array = [
		{"x": -3.50, "z": 0.0},
		{"x": 3.50, "z": 0.0},
		{"x": -3.50, "z": -3.0},
		{"x": 3.50, "z": -3.0},
		{"x": -3.50, "z": -6.0},
		{"x": 3.50, "z": -6.0},
	]
	for sp in sentinel_positions:
		var sgroup: Node3D = Node3D.new()
		sgroup.name = "Sentinel_" + str(sp["x"]) + "_" + str(sp["z"])
		sgroup.position = Vector3(sp["x"], 0, sp["z"])
		# Inner-facing
		if sp["x"] > 0:
			sgroup.rotation.y = -PI / 2.0
		else:
			sgroup.rotation.y = PI / 2.0
		pivot.add_child(sgroup)
		# ---- Basalt plinth ----
		var plinth: MeshInstance3D = MeshInstance3D.new()
		var pm: BoxMesh = BoxMesh.new()
		pm.size = Vector3(1.20, 0.45, 1.20)
		plinth.mesh = pm
		plinth.material_override = basalt_mat
		plinth.position = Vector3(0, 0.22, 0)
		sgroup.add_child(plinth)
		# Plinth collision
		var plsb: StaticBody3D = StaticBody3D.new()
		plsb.position = Vector3(0, 0.22, 0)
		var plcs: CollisionShape3D = CollisionShape3D.new()
		var plbsh: BoxShape3D = BoxShape3D.new()
		plbsh.size = Vector3(1.20, 0.45, 1.20)
		plcs.shape = plbsh
		plsb.add_child(plcs)
		sgroup.add_child(plsb)
		# ---- Stocky armored body box ----
		var body: MeshInstance3D = MeshInstance3D.new()
		var bm: BoxMesh = BoxMesh.new()
		bm.size = Vector3(0.85, 1.55, 0.65)
		body.mesh = bm
		body.material_override = iron_mat
		body.position = Vector3(0, 1.22, 0)
		sgroup.add_child(body)
		# Body collision
		var bsb: StaticBody3D = StaticBody3D.new()
		bsb.position = Vector3(0, 1.22, 0)
		var bcs: CollisionShape3D = CollisionShape3D.new()
		var bbsh: BoxShape3D = BoxShape3D.new()
		bbsh.size = Vector3(0.85, 1.55, 0.65)
		bcs.shape = bbsh
		bsb.add_child(bcs)
		sgroup.add_child(bsb)
		# Brass chest seam
		var seam: MeshInstance3D = MeshInstance3D.new()
		var smm: BoxMesh = BoxMesh.new()
		smm.size = Vector3(0.14, 1.40, 0.06)
		seam.mesh = smm
		seam.material_override = brass_mat
		seam.position = Vector3(0, 1.22, -0.34)
		sgroup.add_child(seam)
		# Glowing chest core sphere
		var core: MeshInstance3D = MeshInstance3D.new()
		var ccm: SphereMesh = SphereMesh.new()
		ccm.radius = 0.10
		ccm.height = 0.20
		core.mesh = ccm
		core.material_override = ember_mat
		core.position = Vector3(0, 1.40, -0.36)
		sgroup.add_child(core)
		# ---- Pauldrons (small brass cap shoulders) ----
		for px in [-0.50, 0.50]:
			var paul: MeshInstance3D = MeshInstance3D.new()
			var paum: SphereMesh = SphereMesh.new()
			paum.radius = 0.18
			paum.height = 0.34
			paul.mesh = paum
			paul.material_override = brass_mat
			paul.position = Vector3(px, 1.85, 0)
			paul.scale = Vector3(1.0, 0.55, 1.0)
			sgroup.add_child(paul)
		# ---- Helm (rounded box with glowing visor slit) ----
		var helm: MeshInstance3D = MeshInstance3D.new()
		var hmm: BoxMesh = BoxMesh.new()
		hmm.size = Vector3(0.55, 0.55, 0.55)
		helm.mesh = hmm
		helm.material_override = iron_mat
		helm.position = Vector3(0, 2.30, 0)
		sgroup.add_child(helm)
		# Visor slit
		var visor: MeshInstance3D = MeshInstance3D.new()
		var vm: BoxMesh = BoxMesh.new()
		vm.size = Vector3(0.40, 0.06, 0.04)
		visor.mesh = vm
		visor.material_override = ember_mat
		visor.position = Vector3(0, 2.35, -0.30)
		sgroup.add_child(visor)
		# Helm crown ridge (small prism)
		var crown_ridge: MeshInstance3D = MeshInstance3D.new()
		var crm: PrismMesh = PrismMesh.new()
		crm.size = Vector3(0.18, 0.18, 0.55)
		crown_ridge.mesh = crm
		crown_ridge.material_override = brass_mat
		crown_ridge.position = Vector3(0, 2.65, 0)
		sgroup.add_child(crown_ridge)
		# ---- Vertical sword held in front ----
		# Pommel
		var pommel: MeshInstance3D = MeshInstance3D.new()
		var pomm: SphereMesh = SphereMesh.new()
		pomm.radius = 0.07
		pomm.height = 0.14
		pommel.mesh = pomm
		pommel.material_override = brass_mat
		pommel.position = Vector3(0, 0.55, -0.50)
		sgroup.add_child(pommel)
		# Grip
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
		grip.position = Vector3(0, 0.78, -0.50)
		sgroup.add_child(grip)
		# Crossguard
		var guard: MeshInstance3D = MeshInstance3D.new()
		var gdm: BoxMesh = BoxMesh.new()
		gdm.size = Vector3(0.45, 0.07, 0.07)
		guard.mesh = gdm
		guard.material_override = brass_mat
		guard.position = Vector3(0, 0.95, -0.50)
		sgroup.add_child(guard)
		# Blade
		var blade: MeshInstance3D = MeshInstance3D.new()
		var bldm: BoxMesh = BoxMesh.new()
		bldm.size = Vector3(0.16, 1.40, 0.04)
		blade.mesh = bldm
		blade.material_override = iron_mat
		blade.position = Vector3(0, 1.70, -0.50)
		sgroup.add_child(blade)
		# Blade core stripe
		var blade_core: MeshInstance3D = MeshInstance3D.new()
		var bcm: BoxMesh = BoxMesh.new()
		bcm.size = Vector3(0.04, 1.30, 0.05)
		blade_core.mesh = bcm
		blade_core.material_override = ember_mat
		blade_core.position = Vector3(0, 1.70, -0.51)
		sgroup.add_child(blade_core)
		# Blade tip
		var tip: MeshInstance3D = MeshInstance3D.new()
		var tipm: PrismMesh = PrismMesh.new()
		tipm.size = Vector3(0.16, 0.20, 0.04)
		tip.mesh = tipm
		tip.material_override = iron_mat
		tip.position = Vector3(0, 2.50, -0.50)
		sgroup.add_child(tip)
		# Subtle OmniLight per sentinel
		var lt: OmniLight3D = OmniLight3D.new()
		lt.position = Vector3(0, 1.50, -0.45)
		lt.light_color = Color(1.0, 0.55, 0.15)
		lt.light_energy = 1.6
		lt.omni_range = 4.5
		sgroup.add_child(lt)
	# Shared chest core + visor + blade core pulse
	var pulse: Tween = pivot.create_tween().set_loops()
	pulse.tween_property(ember_mat, "emission_energy_multiplier", 8.0, 1.6).set_ease(Tween.EASE_IN_OUT)
	pulse.tween_property(ember_mat, "emission_energy_multiplier", 4.5, 1.6).set_ease(Tween.EASE_IN_OUT)


func _build_d9_boss_approach_altars(geom: Node) -> void:
	## Epic-9 T94: pair of basalt offering altars flanking the boss
	## approach path between the sentinels and the arena. Each altar:
	## tiered basalt block, brass top plate, glowing offering bowl with
	## an eternal flame, brass anvil-and-hammer crest on the front face.
	var pivot: Node3D = Node3D.new()
	pivot.name = "D9_BossApproachAltars"
	pivot.position = D9_CENTER + Vector3(0, 0, -27)
	geom.add_child(pivot)
	# Materials
	var basalt_mat: StandardMaterial3D = StandardMaterial3D.new()
	basalt_mat.albedo_color = Color(0.10, 0.08, 0.07)
	basalt_mat.metallic = 0.20
	basalt_mat.roughness = 0.85
	basalt_mat.emission_enabled = true
	basalt_mat.emission = Color(0.55, 0.18, 0.05)
	basalt_mat.emission_energy_multiplier = 0.20
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
	# Build an altar at +/- offset
	for ax in [-4.50, 4.50]:
		var agroup: Node3D = Node3D.new()
		agroup.name = "Altar_" + str(int(ax))
		agroup.position = Vector3(ax, 0, 0)
		# Inner-facing
		if ax > 0:
			agroup.rotation.y = -PI / 2.0
		else:
			agroup.rotation.y = PI / 2.0
		pivot.add_child(agroup)
		# ---- Tiered basalt block (2 levels) ----
		var base: MeshInstance3D = MeshInstance3D.new()
		var bsm: BoxMesh = BoxMesh.new()
		bsm.size = Vector3(2.20, 0.45, 1.60)
		base.mesh = bsm
		base.material_override = basalt_mat
		base.position = Vector3(0, 0.22, 0)
		agroup.add_child(base)
		var top_block: MeshInstance3D = MeshInstance3D.new()
		var tbm: BoxMesh = BoxMesh.new()
		tbm.size = Vector3(1.80, 0.65, 1.30)
		top_block.mesh = tbm
		top_block.material_override = basalt_mat
		top_block.position = Vector3(0, 0.78, 0)
		agroup.add_child(top_block)
		# Combined collision
		var sb: StaticBody3D = StaticBody3D.new()
		sb.position = Vector3(0, 0.55, 0)
		var cs: CollisionShape3D = CollisionShape3D.new()
		var bsh: BoxShape3D = BoxShape3D.new()
		bsh.size = Vector3(2.20, 1.10, 1.60)
		cs.shape = bsh
		sb.add_child(cs)
		agroup.add_child(sb)
		# ---- Brass top plate ----
		var top_plate: MeshInstance3D = MeshInstance3D.new()
		var tpm: BoxMesh = BoxMesh.new()
		tpm.size = Vector3(1.85, 0.10, 1.35)
		top_plate.mesh = tpm
		top_plate.material_override = brass_mat
		top_plate.position = Vector3(0, 1.16, 0)
		agroup.add_child(top_plate)
		# ---- Brass offering bowl on top ----
		var bowl: MeshInstance3D = MeshInstance3D.new()
		var bowm: SphereMesh = SphereMesh.new()
		bowm.radius = 0.45
		bowm.height = 0.85
		bowl.mesh = bowm
		bowl.material_override = brass_mat
		bowl.position = Vector3(0, 1.40, 0)
		bowl.scale = Vector3(1.0, 0.55, 1.0)
		agroup.add_child(bowl)
		# Bowl rim torus
		var rim: MeshInstance3D = MeshInstance3D.new()
		var rmm: TorusMesh = TorusMesh.new()
		rmm.inner_radius = 0.40
		rmm.outer_radius = 0.50
		rim.mesh = rmm
		rim.material_override = brass_mat
		rim.position = Vector3(0, 1.55, 0)
		agroup.add_child(rim)
		# ---- Eternal flame in the bowl ----
		var flame: MeshInstance3D = MeshInstance3D.new()
		var flm: SphereMesh = SphereMesh.new()
		flm.radius = 0.32
		flm.height = 0.65
		flame.mesh = flm
		flame.material_override = flame_mat
		flame.position = Vector3(0, 1.85, 0)
		agroup.add_child(flame)
		# Flame OmniLight
		var lt: OmniLight3D = OmniLight3D.new()
		lt.position = Vector3(0, 1.95, 0)
		lt.light_color = Color(1.0, 0.55, 0.15)
		lt.light_energy = 3.4
		lt.omni_range = 9.0
		agroup.add_child(lt)
		# Rising ember motes
		var motes: GPUParticles3D = GPUParticles3D.new()
		motes.position = Vector3(0, 2.10, 0)
		motes.amount = 18
		motes.lifetime = 2.2
		var pmat: ParticleProcessMaterial = ParticleProcessMaterial.new()
		pmat.direction = Vector3(0, 1, 0)
		pmat.spread = 14.0
		pmat.initial_velocity_min = 0.5
		pmat.initial_velocity_max = 1.0
		pmat.gravity = Vector3(0, 0.3, 0)
		pmat.scale_min = 0.05
		pmat.scale_max = 0.10
		pmat.color = Color(1.0, 0.55, 0.10, 1.0)
		motes.process_material = pmat
		var psmesh: SphereMesh = SphereMesh.new()
		psmesh.radius = 0.04
		psmesh.height = 0.08
		motes.draw_pass_1 = psmesh
		agroup.add_child(motes)
		# ---- Brass anvil-and-hammer crest on the front face ----
		# Front face = -Z (in local space, after the agroup rotation, this faces the path center)
		# Anvil base
		var anvil: MeshInstance3D = MeshInstance3D.new()
		var anm: BoxMesh = BoxMesh.new()
		anm.size = Vector3(0.65, 0.20, 0.10)
		anvil.mesh = anm
		anvil.material_override = amber_mat
		anvil.position = Vector3(0, 0.65, -0.66)
		agroup.add_child(anvil)
		# Anvil horn (small box on the side)
		var horn: MeshInstance3D = MeshInstance3D.new()
		var hnm: BoxMesh = BoxMesh.new()
		hnm.size = Vector3(0.20, 0.12, 0.10)
		horn.mesh = hnm
		horn.material_override = amber_mat
		horn.position = Vector3(0.30, 0.72, -0.66)
		agroup.add_child(horn)
		# Hammer head crossing the anvil
		var hamhead: MeshInstance3D = MeshInstance3D.new()
		var hhm: BoxMesh = BoxMesh.new()
		hhm.size = Vector3(0.35, 0.16, 0.10)
		hamhead.mesh = hhm
		hamhead.material_override = amber_mat
		hamhead.position = Vector3(-0.10, 0.92, -0.66)
		hamhead.rotation.z = -PI / 8.0
		agroup.add_child(hamhead)
		# Hammer handle
		var hamhandle: MeshInstance3D = MeshInstance3D.new()
		var hhdm: CylinderMesh = CylinderMesh.new()
		hhdm.top_radius = 0.03
		hhdm.bottom_radius = 0.03
		hhdm.height = 0.55
		hamhandle.mesh = hhdm
		hamhandle.material_override = amber_mat
		hamhandle.position = Vector3(0.15, 1.16, -0.66)
		hamhandle.rotation.z = PI / 8.0
		agroup.add_child(hamhandle)
	# Flame flicker + crest pulse
	var fpulse: Tween = pivot.create_tween().set_loops()
	fpulse.tween_property(flame_mat, "emission_energy_multiplier", 10.5, 0.45).set_ease(Tween.EASE_IN_OUT)
	fpulse.tween_property(flame_mat, "emission_energy_multiplier", 7.5, 0.45).set_ease(Tween.EASE_IN_OUT)
	var apulse: Tween = pivot.create_tween().set_loops()
	apulse.tween_property(amber_mat, "emission_energy_multiplier", 8.5, 1.6).set_ease(Tween.EASE_IN_OUT)
	apulse.tween_property(amber_mat, "emission_energy_multiplier", 5.0, 1.6).set_ease(Tween.EASE_IN_OUT)


func _build_d9_boss_arena_floor(geom: Node) -> void:
	## Epic-9 T95: FORGE LORD arena floor — round stepped basalt platform
	## with a central glowing rune circle, 4 cardinal rune crossbars, and
	## 8 perimeter braziers ringing the rim. Combat ground for the finale.
	var pivot: Node3D = Node3D.new()
	pivot.name = "D9_BossArenaFloor"
	pivot.position = D9_CENTER + Vector3(0, 0, -34)
	geom.add_child(pivot)
	# Materials
	var basalt_mat: StandardMaterial3D = StandardMaterial3D.new()
	basalt_mat.albedo_color = Color(0.10, 0.08, 0.07)
	basalt_mat.metallic = 0.20
	basalt_mat.roughness = 0.85
	basalt_mat.emission_enabled = true
	basalt_mat.emission = Color(0.55, 0.18, 0.05)
	basalt_mat.emission_energy_multiplier = 0.25
	var brass_mat: StandardMaterial3D = StandardMaterial3D.new()
	brass_mat.albedo_color = Color(0.85, 0.55, 0.18)
	brass_mat.metallic = 0.95
	brass_mat.roughness = 0.30
	brass_mat.emission_enabled = true
	brass_mat.emission = Color(1.0, 0.50, 0.10)
	brass_mat.emission_energy_multiplier = 0.55
	var rune_mat: StandardMaterial3D = StandardMaterial3D.new()
	rune_mat.albedo_color = Color(1.0, 0.45, 0.05)
	rune_mat.emission_enabled = true
	rune_mat.emission = Color(1.0, 0.45, 0.05)
	rune_mat.emission_energy_multiplier = 7.0
	rune_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var flame_mat: StandardMaterial3D = StandardMaterial3D.new()
	flame_mat.albedo_color = Color(1.0, 0.65, 0.20)
	flame_mat.emission_enabled = true
	flame_mat.emission = Color(1.0, 0.55, 0.10)
	flame_mat.emission_energy_multiplier = 9.0
	flame_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	# ---- Stepped basalt platform (3 concentric tiers, descending) ----
	var tier_data: Array = [
		{"r": 11.00, "h": 0.40, "y": 0.20},
		{"r": 9.50, "h": 0.40, "y": 0.60},
		{"r": 8.00, "h": 0.30, "y": 0.95},
	]
	for td in tier_data:
		var t: MeshInstance3D = MeshInstance3D.new()
		var tm: CylinderMesh = CylinderMesh.new()
		tm.top_radius = td["r"]
		tm.bottom_radius = td["r"] + 0.20
		tm.height = td["h"]
		t.mesh = tm
		t.material_override = basalt_mat
		t.position = Vector3(0, td["y"], 0)
		pivot.add_child(t)
	# Combined arena collision
	var sb: StaticBody3D = StaticBody3D.new()
	sb.position = Vector3(0, 0.55, 0)
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cylsh: CylinderShape3D = CylinderShape3D.new()
	cylsh.radius = maxf(8.00, 11.00)
	cylsh.height = 1.10
	cs.shape = cylsh
	sb.add_child(cs)
	pivot.add_child(sb)
	# ---- Central rune circle ----
	# Outer ring (large torus)
	var rune_outer: MeshInstance3D = MeshInstance3D.new()
	var rom: TorusMesh = TorusMesh.new()
	rom.inner_radius = 5.40
	rom.outer_radius = 5.80
	rune_outer.mesh = rom
	rune_outer.material_override = rune_mat
	rune_outer.position = Vector3(0, 1.12, 0)
	pivot.add_child(rune_outer)
	# Inner ring (smaller torus)
	var rune_inner: MeshInstance3D = MeshInstance3D.new()
	var rim_in: TorusMesh = TorusMesh.new()
	rim_in.inner_radius = 2.40
	rim_in.outer_radius = 2.65
	rune_inner.mesh = rim_in
	rune_inner.material_override = rune_mat
	rune_inner.position = Vector3(0, 1.12, 0)
	pivot.add_child(rune_inner)
	# Center disc — small bright unshaded amber pad
	var center_pad: MeshInstance3D = MeshInstance3D.new()
	var cdm: CylinderMesh = CylinderMesh.new()
	cdm.top_radius = 1.20
	cdm.bottom_radius = 1.20
	cdm.height = 0.06
	center_pad.mesh = cdm
	center_pad.material_override = rune_mat
	center_pad.position = Vector3(0, 1.13, 0)
	pivot.add_child(center_pad)
	# 4 cardinal rune crossbars connecting outer to inner ring
	for i in 4:
		var ang: float = float(i) / 4.0 * TAU
		var dx: float = cos(ang)
		var dz: float = sin(ang)
		var bar: MeshInstance3D = MeshInstance3D.new()
		var bm: BoxMesh = BoxMesh.new()
		bm.size = Vector3(2.80, 0.06, 0.20)
		bar.mesh = bm
		bar.material_override = rune_mat
		bar.position = Vector3(dx * 4.05, 1.13, dz * 4.05)
		bar.rotation.y = ang
		pivot.add_child(bar)
	# 8 small rune sigil dots between the inner ring and the outer ring (octagonal)
	for i in 8:
		var ang: float = (float(i) + 0.5) / 8.0 * TAU
		var dot: MeshInstance3D = MeshInstance3D.new()
		var dm: SphereMesh = SphereMesh.new()
		dm.radius = 0.25
		dm.height = 0.10
		dot.mesh = dm
		dot.material_override = rune_mat
		dot.position = Vector3(cos(ang) * 4.00, 1.16, sin(ang) * 4.00)
		dot.scale = Vector3(1.0, 0.30, 1.0)
		pivot.add_child(dot)
	# ---- 8 brass perimeter braziers ringing the arena rim ----
	for i in 8:
		var ang: float = float(i) / 8.0 * TAU
		var bx: float = cos(ang) * 10.50
		var bz: float = sin(ang) * 10.50
		# Brazier post
		var post: MeshInstance3D = MeshInstance3D.new()
		var pmm: CylinderMesh = CylinderMesh.new()
		pmm.top_radius = 0.14
		pmm.bottom_radius = 0.18
		pmm.height = 1.40
		post.mesh = pmm
		post.material_override = brass_mat
		post.position = Vector3(bx, 1.15, bz)
		pivot.add_child(post)
		# Brazier bowl
		var bowl: MeshInstance3D = MeshInstance3D.new()
		var bowm: SphereMesh = SphereMesh.new()
		bowm.radius = 0.40
		bowm.height = 0.70
		bowl.mesh = bowm
		bowl.material_override = brass_mat
		bowl.position = Vector3(bx, 1.95, bz)
		bowl.scale = Vector3(1.0, 0.55, 1.0)
		pivot.add_child(bowl)
		# Brazier flame
		var flame: MeshInstance3D = MeshInstance3D.new()
		var flm: SphereMesh = SphereMesh.new()
		flm.radius = 0.32
		flm.height = 0.65
		flame.mesh = flm
		flame.material_override = flame_mat
		flame.position = Vector3(bx, 2.20, bz)
		pivot.add_child(flame)
		# OmniLight
		var lt: OmniLight3D = OmniLight3D.new()
		lt.position = Vector3(bx, 2.30, bz)
		lt.light_color = Color(1.0, 0.55, 0.15)
		lt.light_energy = 3.4
		lt.omni_range = 11.0
		pivot.add_child(lt)
		# Ember mote shower per brazier
		var motes: GPUParticles3D = GPUParticles3D.new()
		motes.position = Vector3(bx, 2.40, bz)
		motes.amount = 16
		motes.lifetime = 2.2
		var pmat: ParticleProcessMaterial = ParticleProcessMaterial.new()
		pmat.direction = Vector3(0, 1, 0)
		pmat.spread = 16.0
		pmat.initial_velocity_min = 0.5
		pmat.initial_velocity_max = 1.0
		pmat.gravity = Vector3(0, 0.3, 0)
		pmat.scale_min = 0.05
		pmat.scale_max = 0.10
		pmat.color = Color(1.0, 0.55, 0.10, 1.0)
		motes.process_material = pmat
		var psmesh: SphereMesh = SphereMesh.new()
		psmesh.radius = 0.04
		psmesh.height = 0.08
		motes.draw_pass_1 = psmesh
		pivot.add_child(motes)
	# ---- Strong central arena OmniLight (warm wash from the rune pad) ----
	var central_lt: OmniLight3D = OmniLight3D.new()
	central_lt.position = Vector3(0, 2.50, 0)
	central_lt.light_color = Color(1.0, 0.55, 0.15)
	central_lt.light_energy = 5.0
	central_lt.omni_range = 16.0
	pivot.add_child(central_lt)
	# Rune pulse + flame flicker tweens
	var rpulse: Tween = pivot.create_tween().set_loops()
	rpulse.tween_property(rune_mat, "emission_energy_multiplier", 9.5, 1.8).set_ease(Tween.EASE_IN_OUT)
	rpulse.tween_property(rune_mat, "emission_energy_multiplier", 5.5, 1.8).set_ease(Tween.EASE_IN_OUT)
	var fpulse: Tween = pivot.create_tween().set_loops()
	fpulse.tween_property(flame_mat, "emission_energy_multiplier", 11.0, 0.5).set_ease(Tween.EASE_IN_OUT)
	fpulse.tween_property(flame_mat, "emission_energy_multiplier", 7.5, 0.5).set_ease(Tween.EASE_IN_OUT)


func _build_d9_forge_lord(geom: Node) -> void:
	## Epic-9 T96: FORGE LORD — massive humanoid boss landmark standing
	## at the center of the arena. 9m towering iron-and-flame god-king
	## holding a giant 6m warhammer overhead. Crown of horns, glowing
	## molten chest forge core, glowing visor band, scorched cape behind,
	## ember mote shower, and strong central red OmniLight.
	var pivot: Node3D = Node3D.new()
	pivot.name = "D9_ForgeLord"
	# Stand at the center of the arena (arena floor at -34, deck height ~1.1)
	pivot.position = D9_CENTER + Vector3(0, 1.10, -34)
	geom.add_child(pivot)
	# Materials
	var iron_mat: StandardMaterial3D = StandardMaterial3D.new()
	iron_mat.albedo_color = Color(0.16, 0.12, 0.09)
	iron_mat.metallic = 0.90
	iron_mat.roughness = 0.45
	iron_mat.emission_enabled = true
	iron_mat.emission = Color(0.85, 0.25, 0.05)
	iron_mat.emission_energy_multiplier = 0.45
	var brass_mat: StandardMaterial3D = StandardMaterial3D.new()
	brass_mat.albedo_color = Color(0.85, 0.55, 0.18)
	brass_mat.metallic = 0.95
	brass_mat.roughness = 0.30
	brass_mat.emission_enabled = true
	brass_mat.emission = Color(1.0, 0.50, 0.10)
	brass_mat.emission_energy_multiplier = 0.85
	var molten_mat: StandardMaterial3D = StandardMaterial3D.new()
	molten_mat.albedo_color = Color(1.0, 0.45, 0.05)
	molten_mat.emission_enabled = true
	molten_mat.emission = Color(1.0, 0.45, 0.05)
	molten_mat.emission_energy_multiplier = 9.0
	molten_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var ember_mat: StandardMaterial3D = StandardMaterial3D.new()
	ember_mat.albedo_color = Color(1.0, 0.55, 0.10)
	ember_mat.emission_enabled = true
	ember_mat.emission = Color(1.0, 0.55, 0.10)
	ember_mat.emission_energy_multiplier = 7.5
	ember_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var cape_mat: StandardMaterial3D = StandardMaterial3D.new()
	cape_mat.albedo_color = Color(0.40, 0.10, 0.06)
	cape_mat.roughness = 0.85
	cape_mat.emission_enabled = true
	cape_mat.emission = Color(0.85, 0.20, 0.05)
	cape_mat.emission_energy_multiplier = 0.45
	# ---- Lower body (massive armored greaves + waist) ----
	var legs: MeshInstance3D = MeshInstance3D.new()
	var lgm: BoxMesh = BoxMesh.new()
	lgm.size = Vector3(2.40, 2.20, 1.40)
	legs.mesh = lgm
	legs.material_override = iron_mat
	legs.position = Vector3(0, 1.10, 0)
	pivot.add_child(legs)
	# Greave brass trim (waist band)
	var waist: MeshInstance3D = MeshInstance3D.new()
	var wsm: BoxMesh = BoxMesh.new()
	wsm.size = Vector3(2.60, 0.30, 1.55)
	waist.mesh = wsm
	waist.material_override = brass_mat
	waist.position = Vector3(0, 2.30, 0)
	pivot.add_child(waist)
	# Lower body collision (cover legs)
	var legs_sb: StaticBody3D = StaticBody3D.new()
	legs_sb.position = Vector3(0, 1.10, 0)
	var legs_cs: CollisionShape3D = CollisionShape3D.new()
	var legs_bsh: BoxShape3D = BoxShape3D.new()
	legs_bsh.size = Vector3(2.40, 2.20, 1.40)
	legs_cs.shape = legs_bsh
	legs_sb.add_child(legs_cs)
	pivot.add_child(legs_sb)
	# ---- Massive armored torso ----
	var torso: MeshInstance3D = MeshInstance3D.new()
	var tm: BoxMesh = BoxMesh.new()
	tm.size = Vector3(3.20, 3.00, 1.65)
	torso.mesh = tm
	torso.material_override = iron_mat
	torso.position = Vector3(0, 4.00, 0)
	pivot.add_child(torso)
	# Torso collision
	var torso_sb: StaticBody3D = StaticBody3D.new()
	torso_sb.position = Vector3(0, 4.00, 0)
	var torso_cs: CollisionShape3D = CollisionShape3D.new()
	var torso_bsh: BoxShape3D = BoxShape3D.new()
	torso_bsh.size = Vector3(3.20, 3.00, 1.65)
	torso_cs.shape = torso_bsh
	torso_sb.add_child(torso_cs)
	pivot.add_child(torso_sb)
	# Brass chest plates (3 vertical bands)
	for px in [-0.85, 0.0, 0.85]:
		var plate: MeshInstance3D = MeshInstance3D.new()
		var ppm: BoxMesh = BoxMesh.new()
		ppm.size = Vector3(0.50, 2.85, 0.10)
		plate.mesh = ppm
		plate.material_override = brass_mat
		plate.position = Vector3(px, 4.00, -0.85)
		pivot.add_child(plate)
	# ---- Glowing molten chest forge core ----
	# Outer rim torus
	var core_rim: MeshInstance3D = MeshInstance3D.new()
	var crm: TorusMesh = TorusMesh.new()
	crm.inner_radius = 0.55
	crm.outer_radius = 0.75
	core_rim.mesh = crm
	core_rim.material_override = brass_mat
	core_rim.position = Vector3(0, 4.20, -0.90)
	pivot.add_child(core_rim)
	# Bright molten center sphere
	var core: MeshInstance3D = MeshInstance3D.new()
	var corem: SphereMesh = SphereMesh.new()
	corem.radius = 0.50
	corem.height = 0.95
	core.mesh = corem
	core.material_override = molten_mat
	core.position = Vector3(0, 4.20, -0.92)
	pivot.add_child(core)
	# ---- Pauldrons (massive brass shoulder caps) ----
	for sx in [-1.95, 1.95]:
		var paul: MeshInstance3D = MeshInstance3D.new()
		var pmm: SphereMesh = SphereMesh.new()
		pmm.radius = 0.85
		pmm.height = 1.55
		paul.mesh = pmm
		paul.material_override = brass_mat
		paul.position = Vector3(sx, 5.10, 0)
		paul.scale = Vector3(1.0, 0.55, 1.10)
		pivot.add_child(paul)
		# Spike on each pauldron (small prism)
		var spike: MeshInstance3D = MeshInstance3D.new()
		var spm: PrismMesh = PrismMesh.new()
		spm.size = Vector3(0.45, 0.85, 0.45)
		spike.mesh = spm
		spike.material_override = iron_mat
		spike.position = Vector3(sx, 5.55, 0)
		pivot.add_child(spike)
	# ---- Helm ----
	var helm: MeshInstance3D = MeshInstance3D.new()
	var hmm: BoxMesh = BoxMesh.new()
	hmm.size = Vector3(1.60, 1.40, 1.30)
	helm.mesh = hmm
	helm.material_override = iron_mat
	helm.position = Vector3(0, 6.30, 0)
	pivot.add_child(helm)
	# Helm collision
	var helm_sb: StaticBody3D = StaticBody3D.new()
	helm_sb.position = Vector3(0, 6.30, 0)
	var helm_cs: CollisionShape3D = CollisionShape3D.new()
	var helm_bsh: BoxShape3D = BoxShape3D.new()
	helm_bsh.size = Vector3(1.60, 1.40, 1.30)
	helm_cs.shape = helm_bsh
	helm_sb.add_child(helm_cs)
	pivot.add_child(helm_sb)
	# Glowing visor band — wide horizontal stripe across the helm front
	var visor: MeshInstance3D = MeshInstance3D.new()
	var vm: BoxMesh = BoxMesh.new()
	vm.size = Vector3(1.30, 0.20, 0.06)
	visor.mesh = vm
	visor.material_override = molten_mat
	visor.position = Vector3(0, 6.40, -0.68)
	pivot.add_child(visor)
	# ---- Crown of horns (5 brass horns radiating up from the helm) ----
	for i in 5:
		var ang: float = (float(i) - 2.0) * 0.45
		var horn: MeshInstance3D = MeshInstance3D.new()
		var honm: PrismMesh = PrismMesh.new()
		honm.size = Vector3(0.30, 1.30, 0.30)
		horn.mesh = honm
		horn.material_override = brass_mat
		horn.position = Vector3(sin(ang) * 0.65, 7.40, -0.20)
		horn.rotation.z = ang
		pivot.add_child(horn)
	# ---- Massive 6m warhammer held overhead ----
	# Hammer pivot anchored at the right hand position
	var hammer_pivot: Node3D = Node3D.new()
	hammer_pivot.position = Vector3(2.80, 5.50, 0)
	pivot.add_child(hammer_pivot)
	# Hammer shaft
	var shaft: MeshInstance3D = MeshInstance3D.new()
	var shm: CylinderMesh = CylinderMesh.new()
	shm.top_radius = 0.18
	shm.bottom_radius = 0.22
	shm.height = 6.00
	shaft.mesh = shm
	shaft.material_override = iron_mat
	shaft.position = Vector3(0.5, 2.50, 0)
	shaft.rotation.z = -0.5
	hammer_pivot.add_child(shaft)
	# Hammer brass binding rings
	for ry in [1.0, 3.0, 5.0]:
		var ring: MeshInstance3D = MeshInstance3D.new()
		var rmm: TorusMesh = TorusMesh.new()
		rmm.inner_radius = 0.18
		rmm.outer_radius = 0.30
		ring.mesh = rmm
		ring.material_override = brass_mat
		ring.position = Vector3(0.5 + ry * 0.12, ry, 0)
		ring.rotation.z = -0.5 + PI / 2.0
		hammer_pivot.add_child(ring)
	# Massive hammer head (huge box)
	var head: MeshInstance3D = MeshInstance3D.new()
	var headm: BoxMesh = BoxMesh.new()
	headm.size = Vector3(2.20, 1.60, 2.40)
	head.mesh = headm
	head.material_override = iron_mat
	head.position = Vector3(1.20, 5.40, 0)
	pivot.add_child(head)
	# Hammer head collision
	var head_sb: StaticBody3D = StaticBody3D.new()
	head_sb.position = Vector3(1.20, 5.40, 0)
	var head_cs: CollisionShape3D = CollisionShape3D.new()
	var head_bsh: BoxShape3D = BoxShape3D.new()
	head_bsh.size = Vector3(2.20, 1.60, 2.40)
	head_cs.shape = head_bsh
	head_sb.add_child(head_cs)
	pivot.add_child(head_sb)
	# Glowing molten core stripe through the hammer head
	var head_core: MeshInstance3D = MeshInstance3D.new()
	var hcm: BoxMesh = BoxMesh.new()
	hcm.size = Vector3(2.40, 0.40, 0.40)
	head_core.mesh = hcm
	head_core.material_override = molten_mat
	head_core.position = Vector3(1.20, 5.40, 0)
	pivot.add_child(head_core)
	# Brass hammer head end-caps
	for hcz in [-1.20, 1.20]:
		var cap: MeshInstance3D = MeshInstance3D.new()
		var capm: BoxMesh = BoxMesh.new()
		capm.size = Vector3(2.30, 1.70, 0.18)
		cap.mesh = capm
		cap.material_override = brass_mat
		cap.position = Vector3(1.20, 5.40, hcz)
		pivot.add_child(cap)
	# ---- Scorched cape behind (wide drape) ----
	var cape: MeshInstance3D = MeshInstance3D.new()
	var capem: BoxMesh = BoxMesh.new()
	capem.size = Vector3(3.40, 4.20, 0.10)
	cape.mesh = capem
	cape.material_override = cape_mat
	cape.position = Vector3(0, 3.80, 0.95)
	cape.rotation.x = 0.18
	pivot.add_child(cape)
	# Cape glowing edge stripe (bottom hem)
	var hem: MeshInstance3D = MeshInstance3D.new()
	var hemm: BoxMesh = BoxMesh.new()
	hemm.size = Vector3(3.40, 0.20, 0.06)
	hem.mesh = hemm
	hem.material_override = ember_mat
	hem.position = Vector3(0, 1.80, 1.30)
	pivot.add_child(hem)
	# ---- Strong central red OmniLight ----
	var lt: OmniLight3D = OmniLight3D.new()
	lt.position = Vector3(0, 5.00, -0.50)
	lt.light_color = Color(1.0, 0.40, 0.10)
	lt.light_energy = 6.0
	lt.omni_range = 22.0
	pivot.add_child(lt)
	# ---- Ember mote shower from the helm + chest core ----
	var motes: GPUParticles3D = GPUParticles3D.new()
	motes.position = Vector3(0, 6.80, -0.20)
	motes.amount = 40
	motes.lifetime = 3.0
	var pmat: ParticleProcessMaterial = ParticleProcessMaterial.new()
	pmat.direction = Vector3(0, 1, 0)
	pmat.spread = 28.0
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
	# ---- Pulses ----
	# Molten core + visor + hammer core pulse
	var mpulse: Tween = pivot.create_tween().set_loops()
	mpulse.tween_property(molten_mat, "emission_energy_multiplier", 12.0, 1.6).set_ease(Tween.EASE_IN_OUT)
	mpulse.tween_property(molten_mat, "emission_energy_multiplier", 7.5, 1.6).set_ease(Tween.EASE_IN_OUT)
	# Brass pulse (subtle)
	var bpulse: Tween = pivot.create_tween().set_loops()
	bpulse.tween_property(brass_mat, "emission_energy_multiplier", 1.20, 2.0).set_ease(Tween.EASE_IN_OUT)
	bpulse.tween_property(brass_mat, "emission_energy_multiplier", 0.65, 2.0).set_ease(Tween.EASE_IN_OUT)
	# Slow body sway — entire god-king rocks slightly side-to-side as if "alive"
	var sway: Tween = pivot.create_tween().set_loops()
	sway.tween_property(pivot, "rotation:y", 0.05, 3.5).set_ease(Tween.EASE_IN_OUT)
	sway.tween_property(pivot, "rotation:y", -0.05, 3.5).set_ease(Tween.EASE_IN_OUT)


func _build_d9_welcome_banner(geom: Node) -> void:
	## Epic-9 T97: D9 welcome banner at the district's south entry. Two
	## tall basalt pillars flanking the path, brass crossbar arch overhead,
	## central red drape with glowing district nameplate, hanging amber
	## guild crest medallion, and torches on each pillar.
	var pivot: Node3D = Node3D.new()
	pivot.name = "D9_WelcomeBanner"
	pivot.position = D9_CENTER + Vector3(0, 0, 28)
	geom.add_child(pivot)
	# Materials
	var basalt_mat: StandardMaterial3D = StandardMaterial3D.new()
	basalt_mat.albedo_color = Color(0.10, 0.08, 0.07)
	basalt_mat.metallic = 0.20
	basalt_mat.roughness = 0.85
	basalt_mat.emission_enabled = true
	basalt_mat.emission = Color(0.55, 0.18, 0.05)
	basalt_mat.emission_energy_multiplier = 0.20
	var brass_mat: StandardMaterial3D = StandardMaterial3D.new()
	brass_mat.albedo_color = Color(0.85, 0.55, 0.18)
	brass_mat.metallic = 0.95
	brass_mat.roughness = 0.30
	brass_mat.emission_enabled = true
	brass_mat.emission = Color(1.0, 0.50, 0.10)
	brass_mat.emission_energy_multiplier = 0.55
	var drape_mat: StandardMaterial3D = StandardMaterial3D.new()
	drape_mat.albedo_color = Color(0.55, 0.10, 0.08)
	drape_mat.roughness = 0.85
	drape_mat.emission_enabled = true
	drape_mat.emission = Color(0.85, 0.20, 0.05)
	drape_mat.emission_energy_multiplier = 0.40
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
	flame_mat.emission_energy_multiplier = 9.0
	flame_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	# ---- Two basalt pillars flanking the entry path ----
	for px in [-6.0, 6.0]:
		var pgroup: Node3D = Node3D.new()
		pgroup.name = "Pillar_" + str(int(px))
		pgroup.position = Vector3(px, 0, 0)
		pivot.add_child(pgroup)
		# Stepped base
		var base: MeshInstance3D = MeshInstance3D.new()
		var bm: BoxMesh = BoxMesh.new()
		bm.size = Vector3(1.85, 0.55, 1.85)
		base.mesh = bm
		base.material_override = basalt_mat
		base.position = Vector3(0, 0.27, 0)
		pgroup.add_child(base)
		# Pillar shaft
		var shaft: MeshInstance3D = MeshInstance3D.new()
		var sm: BoxMesh = BoxMesh.new()
		sm.size = Vector3(1.10, 6.50, 1.10)
		shaft.mesh = sm
		shaft.material_override = basalt_mat
		shaft.position = Vector3(0, 3.80, 0)
		pgroup.add_child(shaft)
		# Pillar collision (combined)
		var sb: StaticBody3D = StaticBody3D.new()
		sb.position = Vector3(0, 3.80, 0)
		var cs: CollisionShape3D = CollisionShape3D.new()
		var bsh: BoxShape3D = BoxShape3D.new()
		bsh.size = Vector3(1.85, 7.00, 1.85)
		cs.shape = bsh
		sb.add_child(cs)
		pgroup.add_child(sb)
		# Brass top cap
		var cap: MeshInstance3D = MeshInstance3D.new()
		var capm: BoxMesh = BoxMesh.new()
		capm.size = Vector3(1.40, 0.30, 1.40)
		cap.mesh = capm
		cap.material_override = brass_mat
		cap.position = Vector3(0, 7.20, 0)
		pgroup.add_child(cap)
		# Brass mid band
		var band: MeshInstance3D = MeshInstance3D.new()
		var bdm: BoxMesh = BoxMesh.new()
		bdm.size = Vector3(1.20, 0.18, 1.20)
		band.mesh = bdm
		band.material_override = brass_mat
		band.position = Vector3(0, 4.20, 0)
		pgroup.add_child(band)
		# Pillar torch — bracket + flame + light
		var bracket: MeshInstance3D = MeshInstance3D.new()
		var bktm: BoxMesh = BoxMesh.new()
		bktm.size = Vector3(0.30, 0.18, 0.50)
		bracket.mesh = bktm
		bracket.material_override = brass_mat
		# Inner-facing torch (faces the path center)
		var inner_z: float = -0.65
		bracket.position = Vector3(0, 5.20, inner_z)
		pgroup.add_child(bracket)
		var flame: MeshInstance3D = MeshInstance3D.new()
		var flm: SphereMesh = SphereMesh.new()
		flm.radius = 0.22
		flm.height = 0.45
		flame.mesh = flm
		flame.material_override = flame_mat
		flame.position = Vector3(0, 5.45, inner_z - 0.30)
		pgroup.add_child(flame)
		var lt: OmniLight3D = OmniLight3D.new()
		lt.position = Vector3(0, 5.45, inner_z - 0.30)
		lt.light_color = Color(1.0, 0.55, 0.15)
		lt.light_energy = 3.4
		lt.omni_range = 9.0
		pgroup.add_child(lt)
	# ---- Brass crossbar arch overhead between the pillars ----
	var crossbar: MeshInstance3D = MeshInstance3D.new()
	var cbm: BoxMesh = BoxMesh.new()
	cbm.size = Vector3(13.50, 0.40, 1.20)
	crossbar.mesh = cbm
	crossbar.material_override = brass_mat
	crossbar.position = Vector3(0, 7.30, 0)
	pivot.add_child(crossbar)
	# Crossbar bottom trim (small lip)
	var trim: MeshInstance3D = MeshInstance3D.new()
	var trm: BoxMesh = BoxMesh.new()
	trm.size = Vector3(13.20, 0.10, 1.30)
	trim.mesh = trm
	trim.material_override = brass_mat
	trim.position = Vector3(0, 7.05, 0)
	pivot.add_child(trim)
	# ---- Central hanging red drape ----
	var drape: MeshInstance3D = MeshInstance3D.new()
	var dm: BoxMesh = BoxMesh.new()
	dm.size = Vector3(7.80, 3.40, 0.10)
	drape.mesh = dm
	drape.material_override = drape_mat
	drape.position = Vector3(0, 5.30, 0)
	pivot.add_child(drape)
	# Drape top brass rod
	var rod: MeshInstance3D = MeshInstance3D.new()
	var rm: CylinderMesh = CylinderMesh.new()
	rm.top_radius = 0.06
	rm.bottom_radius = 0.06
	rm.height = 8.00
	rod.mesh = rm
	rod.material_override = brass_mat
	rod.position = Vector3(0, 7.00, 0)
	rod.rotation.z = PI / 2.0
	pivot.add_child(rod)
	# ---- Glowing district nameplate (large brass plaque centered on the drape) ----
	var nameplate: MeshInstance3D = MeshInstance3D.new()
	var npm: BoxMesh = BoxMesh.new()
	npm.size = Vector3(5.00, 1.40, 0.12)
	nameplate.mesh = npm
	nameplate.material_override = brass_mat
	nameplate.position = Vector3(0, 5.70, -0.10)
	pivot.add_child(nameplate)
	# Nameplate glowing letter blocks (10 amber boxes spelling out "VOLCANIC FORGE" pattern)
	for i in 10:
		var lx: float = -2.10 + float(i) * 0.46
		var letter: MeshInstance3D = MeshInstance3D.new()
		var lm: BoxMesh = BoxMesh.new()
		lm.size = Vector3(0.30, 0.55, 0.06)
		letter.mesh = lm
		letter.material_override = amber_mat
		letter.position = Vector3(lx, 5.75, -0.18)
		pivot.add_child(letter)
	# ---- Hanging amber guild crest medallion below the nameplate ----
	# Brass chain
	var chain: MeshInstance3D = MeshInstance3D.new()
	var chm: CylinderMesh = CylinderMesh.new()
	chm.top_radius = 0.04
	chm.bottom_radius = 0.04
	chm.height = 0.80
	chain.mesh = chm
	chain.material_override = brass_mat
	chain.position = Vector3(0, 4.55, -0.10)
	pivot.add_child(chain)
	# Crest torus
	var crest: MeshInstance3D = MeshInstance3D.new()
	var ctm: TorusMesh = TorusMesh.new()
	ctm.inner_radius = 0.45
	ctm.outer_radius = 0.65
	crest.mesh = ctm
	crest.material_override = amber_mat
	crest.position = Vector3(0, 3.95, -0.18)
	crest.rotation.x = PI / 2.0
	pivot.add_child(crest)
	# Crest center bar (hammer crossing)
	var cbar: MeshInstance3D = MeshInstance3D.new()
	var cbar_m: BoxMesh = BoxMesh.new()
	cbar_m.size = Vector3(0.18, 1.20, 0.06)
	cbar.mesh = cbar_m
	cbar.material_override = amber_mat
	cbar.position = Vector3(0, 3.95, -0.20)
	pivot.add_child(cbar)
	# ---- Pulses ----
	# Nameplate + crest amber pulse
	var apulse: Tween = pivot.create_tween().set_loops()
	apulse.tween_property(amber_mat, "emission_energy_multiplier", 8.5, 1.6).set_ease(Tween.EASE_IN_OUT)
	apulse.tween_property(amber_mat, "emission_energy_multiplier", 5.0, 1.6).set_ease(Tween.EASE_IN_OUT)
	# Torch flicker
	var fpulse: Tween = pivot.create_tween().set_loops()
	fpulse.tween_property(flame_mat, "emission_energy_multiplier", 11.0, 0.5).set_ease(Tween.EASE_IN_OUT)
	fpulse.tween_property(flame_mat, "emission_energy_multiplier", 7.5, 0.5).set_ease(Tween.EASE_IN_OUT)


func _build_d9_ambient_atmosphere(geom: Node) -> void:
	## Epic-9 T98: D9 ambient volcanic atmosphere — 6 large red ember fog
	## puffs floating across the district at low altitude (semi-transparent
	## emissive spheres acting as poor man's volumetric fog), 4 distant
	## warm-glow OmniLights at altitude to add ambient red wash, and 2
	## wide ash plume drift particle emitters.
	var pivot: Node3D = Node3D.new()
	pivot.name = "D9_AmbientAtmosphere"
	pivot.position = D9_CENTER
	geom.add_child(pivot)
	# Materials
	var fog_mat: StandardMaterial3D = StandardMaterial3D.new()
	fog_mat.albedo_color = Color(0.85, 0.30, 0.10, 0.18)
	fog_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	fog_mat.emission_enabled = true
	fog_mat.emission = Color(1.0, 0.40, 0.10)
	fog_mat.emission_energy_multiplier = 1.20
	fog_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	# ---- 6 large red fog puffs spread across D9 at low altitude ----
	var fog_positions: Array = [
		Vector3(-15.0, 4.0, -10.0),
		Vector3(15.0, 4.0, -8.0),
		Vector3(0.0, 5.0, 0.0),
		Vector3(-12.0, 4.0, 12.0),
		Vector3(20.0, 4.5, 5.0),
		Vector3(-25.0, 5.0, -22.0),
	]
	for fp in fog_positions:
		var puff: MeshInstance3D = MeshInstance3D.new()
		var psm: SphereMesh = SphereMesh.new()
		psm.radius = 5.50
		psm.height = 11.00
		puff.mesh = psm
		puff.material_override = fog_mat
		puff.position = fp
		puff.scale = Vector3(1.0, 0.55, 1.0)
		pivot.add_child(puff)
	# ---- 4 distant ambient warm OmniLights at altitude (red wash) ----
	var altitude_lights: Array = [
		Vector3(-20.0, 14.0, -12.0),
		Vector3(20.0, 14.0, -12.0),
		Vector3(-20.0, 14.0, 12.0),
		Vector3(20.0, 14.0, 12.0),
	]
	for ap in altitude_lights:
		var lt: OmniLight3D = OmniLight3D.new()
		lt.position = ap
		lt.light_color = Color(1.0, 0.45, 0.15)
		lt.light_energy = 1.6
		lt.omni_range = 28.0
		pivot.add_child(lt)
	# ---- 2 wide ash plume drift particle emitters at altitude ----
	for ax in [-20.0, 20.0]:
		var plume: GPUParticles3D = GPUParticles3D.new()
		plume.position = Vector3(ax, 12.0, 0)
		plume.amount = 50
		plume.lifetime = 6.0
		var pmat: ParticleProcessMaterial = ParticleProcessMaterial.new()
		pmat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
		pmat.emission_box_extents = Vector3(8.0, 0.5, 25.0)
		pmat.direction = Vector3(0, 1, 0)
		pmat.spread = 28.0
		pmat.initial_velocity_min = 0.5
		pmat.initial_velocity_max = 1.0
		pmat.gravity = Vector3(0.3, 0.4, 0)
		pmat.scale_min = 0.45
		pmat.scale_max = 0.85
		pmat.color = Color(0.85, 0.35, 0.15, 0.50)
		plume.process_material = pmat
		var pmesh: SphereMesh = SphereMesh.new()
		pmesh.radius = 0.30
		pmesh.height = 0.60
		plume.draw_pass_1 = pmesh
		pivot.add_child(plume)
	# Slow fog pulse — material breathes its emission
	var fpulse: Tween = pivot.create_tween().set_loops()
	fpulse.tween_property(fog_mat, "emission_energy_multiplier", 1.65, 2.4).set_ease(Tween.EASE_IN_OUT)
	fpulse.tween_property(fog_mat, "emission_energy_multiplier", 0.95, 2.4).set_ease(Tween.EASE_IN_OUT)


func _build_d9_district_plaque(geom: Node) -> void:
	## Epic-9 T99: D9 commemorative ground plaque near the welcome banner.
	## Stepped basalt base, angled brass plaque face with 3 rows of glowing
	## amber inscription stripes, brass guild crest at the top, 2 small
	## reading lanterns on either side, and a glowing rune ring on the
	## ground at the base.
	var pivot: Node3D = Node3D.new()
	pivot.name = "D9_DistrictPlaque"
	# Just inside the welcome banner (banner at +0,+28; plaque at +0,+24)
	pivot.position = D9_CENTER + Vector3(0, 0, 24)
	geom.add_child(pivot)
	# Materials
	var basalt_mat: StandardMaterial3D = StandardMaterial3D.new()
	basalt_mat.albedo_color = Color(0.10, 0.08, 0.07)
	basalt_mat.metallic = 0.20
	basalt_mat.roughness = 0.85
	basalt_mat.emission_enabled = true
	basalt_mat.emission = Color(0.55, 0.18, 0.05)
	basalt_mat.emission_energy_multiplier = 0.20
	var brass_mat: StandardMaterial3D = StandardMaterial3D.new()
	brass_mat.albedo_color = Color(0.85, 0.55, 0.18)
	brass_mat.metallic = 0.95
	brass_mat.roughness = 0.30
	brass_mat.emission_enabled = true
	brass_mat.emission = Color(1.0, 0.50, 0.10)
	brass_mat.emission_energy_multiplier = 0.65
	var amber_mat: StandardMaterial3D = StandardMaterial3D.new()
	amber_mat.albedo_color = Color(1.0, 0.55, 0.10)
	amber_mat.emission_enabled = true
	amber_mat.emission = Color(1.0, 0.55, 0.10)
	amber_mat.emission_energy_multiplier = 6.0
	amber_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var flame_mat: StandardMaterial3D = StandardMaterial3D.new()
	flame_mat.albedo_color = Color(1.0, 0.65, 0.20)
	flame_mat.emission_enabled = true
	flame_mat.emission = Color(1.0, 0.55, 0.10)
	flame_mat.emission_energy_multiplier = 8.0
	flame_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	# ---- Stepped basalt base (2 levels) ----
	var base1: MeshInstance3D = MeshInstance3D.new()
	var b1m: BoxMesh = BoxMesh.new()
	b1m.size = Vector3(3.20, 0.40, 1.80)
	base1.mesh = b1m
	base1.material_override = basalt_mat
	base1.position = Vector3(0, 0.20, 0)
	pivot.add_child(base1)
	var base2: MeshInstance3D = MeshInstance3D.new()
	var b2m: BoxMesh = BoxMesh.new()
	b2m.size = Vector3(2.70, 0.50, 1.40)
	base2.mesh = b2m
	base2.material_override = basalt_mat
	base2.position = Vector3(0, 0.65, 0)
	pivot.add_child(base2)
	# Combined collision
	var sb: StaticBody3D = StaticBody3D.new()
	sb.position = Vector3(0, 0.50, 0)
	var cs: CollisionShape3D = CollisionShape3D.new()
	var bsh: BoxShape3D = BoxShape3D.new()
	bsh.size = Vector3(3.20, 1.00, 1.80)
	cs.shape = bsh
	sb.add_child(cs)
	pivot.add_child(sb)
	# ---- Angled brass plaque face (tilted slightly back so it reads from above) ----
	var plaque: MeshInstance3D = MeshInstance3D.new()
	var plm: BoxMesh = BoxMesh.new()
	plm.size = Vector3(2.40, 1.30, 0.10)
	plaque.mesh = plm
	plaque.material_override = brass_mat
	plaque.position = Vector3(0, 1.40, -0.20)
	plaque.rotation.x = -PI / 5.0
	pivot.add_child(plaque)
	# ---- 3 rows of glowing amber inscription stripes (3 columns each) ----
	for row in 3:
		var ry: float = 1.65 - float(row) * 0.30
		var rz: float = -0.10 - float(row) * 0.18
		for col in 3:
			var rx: float = -0.65 + float(col) * 0.65
			var stripe: MeshInstance3D = MeshInstance3D.new()
			var sm: BoxMesh = BoxMesh.new()
			sm.size = Vector3(0.55, 0.10, 0.05)
			stripe.mesh = sm
			stripe.material_override = amber_mat
			stripe.position = Vector3(rx, ry, rz)
			stripe.rotation.x = -PI / 5.0
			pivot.add_child(stripe)
	# ---- Brass guild crest at the top of the plaque (torus + hammer crossbar) ----
	var crest: MeshInstance3D = MeshInstance3D.new()
	var ctm: TorusMesh = TorusMesh.new()
	ctm.inner_radius = 0.20
	ctm.outer_radius = 0.30
	crest.mesh = ctm
	crest.material_override = amber_mat
	crest.position = Vector3(0, 2.05, 0.05)
	crest.rotation.x = PI / 2.0 - PI / 5.0
	pivot.add_child(crest)
	var crest_bar: MeshInstance3D = MeshInstance3D.new()
	var cbm: BoxMesh = BoxMesh.new()
	cbm.size = Vector3(0.10, 0.55, 0.06)
	crest_bar.mesh = cbm
	crest_bar.material_override = amber_mat
	crest_bar.position = Vector3(0, 2.05, 0.04)
	crest_bar.rotation.x = -PI / 5.0
	pivot.add_child(crest_bar)
	# ---- 2 small reading lanterns on either side of the plaque ----
	for lx in [-1.55, 1.55]:
		# Lantern post
		var post: MeshInstance3D = MeshInstance3D.new()
		var pm: CylinderMesh = CylinderMesh.new()
		pm.top_radius = 0.07
		pm.bottom_radius = 0.10
		pm.height = 1.85
		post.mesh = pm
		post.material_override = brass_mat
		post.position = Vector3(lx, 1.85, 0)
		pivot.add_child(post)
		# Lantern cage box at the top
		var cage: MeshInstance3D = MeshInstance3D.new()
		var cgm: BoxMesh = BoxMesh.new()
		cgm.size = Vector3(0.30, 0.40, 0.30)
		cage.mesh = cgm
		cage.material_override = brass_mat
		cage.position = Vector3(lx, 2.95, 0)
		pivot.add_child(cage)
		# Lantern flame inside
		var flame: MeshInstance3D = MeshInstance3D.new()
		var flm: SphereMesh = SphereMesh.new()
		flm.radius = 0.16
		flm.height = 0.32
		flame.mesh = flm
		flame.material_override = flame_mat
		flame.position = Vector3(lx, 2.95, 0)
		pivot.add_child(flame)
		# Lantern OmniLight
		var lt: OmniLight3D = OmniLight3D.new()
		lt.position = Vector3(lx, 2.95, 0)
		lt.light_color = Color(1.0, 0.55, 0.15)
		lt.light_energy = 2.6
		lt.omni_range = 6.5
		pivot.add_child(lt)
	# ---- Glowing rune ring on the ground at the base ----
	var ring: MeshInstance3D = MeshInstance3D.new()
	var rngm: TorusMesh = TorusMesh.new()
	rngm.inner_radius = 1.95
	rngm.outer_radius = 2.20
	ring.mesh = rngm
	ring.material_override = amber_mat
	ring.position = Vector3(0, 0.05, 0)
	pivot.add_child(ring)
	# 4 cardinal rune dots on the ring
	for i in 4:
		var ang: float = float(i) / 4.0 * TAU
		var dot: MeshInstance3D = MeshInstance3D.new()
		var dm: SphereMesh = SphereMesh.new()
		dm.radius = 0.14
		dm.height = 0.06
		dot.mesh = dm
		dot.material_override = amber_mat
		dot.position = Vector3(cos(ang) * 2.10, 0.06, sin(ang) * 2.10)
		dot.scale = Vector3(1.0, 0.30, 1.0)
		pivot.add_child(dot)
	# Pulses — amber breathe + flame flicker
	var apulse: Tween = pivot.create_tween().set_loops()
	apulse.tween_property(amber_mat, "emission_energy_multiplier", 8.0, 1.8).set_ease(Tween.EASE_IN_OUT)
	apulse.tween_property(amber_mat, "emission_energy_multiplier", 4.5, 1.8).set_ease(Tween.EASE_IN_OUT)
	var fpulse: Tween = pivot.create_tween().set_loops()
	fpulse.tween_property(flame_mat, "emission_energy_multiplier", 10.5, 0.45).set_ease(Tween.EASE_IN_OUT)
	fpulse.tween_property(flame_mat, "emission_energy_multiplier", 7.0, 0.45).set_ease(Tween.EASE_IN_OUT)


func _build_d9_arena_fortifications(geom: Node) -> void:
	## Epic-9 T100 (FINALE): 4 corner fortification pillars surrounding the
	## FORGE LORD arena, chained to each other with hanging iron warning
	## chains, each pillar topped with a massive ember brazier and flanked
	## by glowing rune banners. The closing flourish that locks down the
	## boss arena and completes Epic 9.
	var pivot: Node3D = Node3D.new()
	pivot.name = "D9_ArenaFortifications"
	# Centered on the FORGE LORD arena (which sits at -34 Z)
	pivot.position = D9_CENTER + Vector3(0, 0, -34)
	geom.add_child(pivot)
	# Materials
	var basalt_mat: StandardMaterial3D = StandardMaterial3D.new()
	basalt_mat.albedo_color = Color(0.10, 0.08, 0.07)
	basalt_mat.metallic = 0.20
	basalt_mat.roughness = 0.85
	basalt_mat.emission_enabled = true
	basalt_mat.emission = Color(0.55, 0.18, 0.05)
	basalt_mat.emission_energy_multiplier = 0.25
	var brass_mat: StandardMaterial3D = StandardMaterial3D.new()
	brass_mat.albedo_color = Color(0.85, 0.55, 0.18)
	brass_mat.metallic = 0.95
	brass_mat.roughness = 0.30
	brass_mat.emission_enabled = true
	brass_mat.emission = Color(1.0, 0.50, 0.10)
	brass_mat.emission_energy_multiplier = 0.65
	var iron_mat: StandardMaterial3D = StandardMaterial3D.new()
	iron_mat.albedo_color = Color(0.18, 0.14, 0.11)
	iron_mat.metallic = 0.85
	iron_mat.roughness = 0.45
	iron_mat.emission_enabled = true
	iron_mat.emission = Color(0.85, 0.25, 0.05)
	iron_mat.emission_energy_multiplier = 0.35
	var rune_mat: StandardMaterial3D = StandardMaterial3D.new()
	rune_mat.albedo_color = Color(1.0, 0.45, 0.05)
	rune_mat.emission_enabled = true
	rune_mat.emission = Color(1.0, 0.45, 0.05)
	rune_mat.emission_energy_multiplier = 7.0
	rune_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var flame_mat: StandardMaterial3D = StandardMaterial3D.new()
	flame_mat.albedo_color = Color(1.0, 0.65, 0.20)
	flame_mat.emission_enabled = true
	flame_mat.emission = Color(1.0, 0.55, 0.10)
	flame_mat.emission_energy_multiplier = 10.0
	flame_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var drape_mat: StandardMaterial3D = StandardMaterial3D.new()
	drape_mat.albedo_color = Color(0.55, 0.10, 0.08)
	drape_mat.roughness = 0.85
	drape_mat.emission_enabled = true
	drape_mat.emission = Color(0.85, 0.20, 0.05)
	drape_mat.emission_energy_multiplier = 0.45
	# ---- 4 corner pillars at radius ~14 from arena center ----
	var pillar_positions: Array = [
		Vector3(-13.0, 0, -13.0),
		Vector3(13.0, 0, -13.0),
		Vector3(-13.0, 0, 13.0),
		Vector3(13.0, 0, 13.0),
	]
	for pp in pillar_positions:
		var pgroup: Node3D = Node3D.new()
		pgroup.name = "FortPillar_" + str(int(pp.x)) + "_" + str(int(pp.z))
		pgroup.position = pp
		# Rotate so the rune banner faces the arena center
		pgroup.rotation.y = atan2(-pp.x, -pp.z)
		pivot.add_child(pgroup)
		# ---- Stepped basalt base (2 levels) ----
		var base1: MeshInstance3D = MeshInstance3D.new()
		var b1m: BoxMesh = BoxMesh.new()
		b1m.size = Vector3(2.40, 0.55, 2.40)
		base1.mesh = b1m
		base1.material_override = basalt_mat
		base1.position = Vector3(0, 0.27, 0)
		pgroup.add_child(base1)
		var base2: MeshInstance3D = MeshInstance3D.new()
		var b2m: BoxMesh = BoxMesh.new()
		b2m.size = Vector3(1.95, 0.45, 1.95)
		base2.mesh = b2m
		base2.material_override = basalt_mat
		base2.position = Vector3(0, 0.78, 0)
		pgroup.add_child(base2)
		# ---- Tall basalt pillar shaft (10m) ----
		var shaft: MeshInstance3D = MeshInstance3D.new()
		var sm: BoxMesh = BoxMesh.new()
		sm.size = Vector3(1.40, 10.00, 1.40)
		shaft.mesh = sm
		shaft.material_override = basalt_mat
		shaft.position = Vector3(0, 6.00, 0)
		pgroup.add_child(shaft)
		# Combined collision (base + shaft)
		var sb: StaticBody3D = StaticBody3D.new()
		sb.position = Vector3(0, 5.50, 0)
		var cs: CollisionShape3D = CollisionShape3D.new()
		var bsh: BoxShape3D = BoxShape3D.new()
		bsh.size = Vector3(2.40, 11.00, 2.40)
		cs.shape = bsh
		sb.add_child(cs)
		pgroup.add_child(sb)
		# ---- 3 brass bands wrapping the shaft ----
		for by in [3.50, 6.50, 9.50]:
			var band: MeshInstance3D = MeshInstance3D.new()
			var bdm: BoxMesh = BoxMesh.new()
			bdm.size = Vector3(1.55, 0.20, 1.55)
			band.mesh = bdm
			band.material_override = brass_mat
			band.position = Vector3(0, by, 0)
			pgroup.add_child(band)
		# ---- Crowning brass brazier ----
		var bowl: MeshInstance3D = MeshInstance3D.new()
		var bowm: SphereMesh = SphereMesh.new()
		bowm.radius = 0.65
		bowm.height = 1.10
		bowl.mesh = bowm
		bowl.material_override = brass_mat
		bowl.position = Vector3(0, 11.30, 0)
		bowl.scale = Vector3(1.0, 0.55, 1.0)
		pgroup.add_child(bowl)
		# Brazier flame
		var flame: MeshInstance3D = MeshInstance3D.new()
		var flm: SphereMesh = SphereMesh.new()
		flm.radius = 0.50
		flm.height = 1.00
		flame.mesh = flm
		flame.material_override = flame_mat
		flame.position = Vector3(0, 11.85, 0)
		pgroup.add_child(flame)
		# Brazier OmniLight
		var lt: OmniLight3D = OmniLight3D.new()
		lt.position = Vector3(0, 11.85, 0)
		lt.light_color = Color(1.0, 0.50, 0.10)
		lt.light_energy = 5.0
		lt.omni_range = 18.0
		pgroup.add_child(lt)
		# Ember mote shower per pillar
		var motes: GPUParticles3D = GPUParticles3D.new()
		motes.position = Vector3(0, 12.10, 0)
		motes.amount = 28
		motes.lifetime = 2.6
		var pmat: ParticleProcessMaterial = ParticleProcessMaterial.new()
		pmat.direction = Vector3(0, 1, 0)
		pmat.spread = 22.0
		pmat.initial_velocity_min = 0.7
		pmat.initial_velocity_max = 1.4
		pmat.gravity = Vector3(0, 0.4, 0)
		pmat.scale_min = 0.07
		pmat.scale_max = 0.14
		pmat.color = Color(1.0, 0.55, 0.10, 1.0)
		motes.process_material = pmat
		var psmesh: SphereMesh = SphereMesh.new()
		psmesh.radius = 0.05
		psmesh.height = 0.10
		motes.draw_pass_1 = psmesh
		pgroup.add_child(motes)
		# ---- Hanging rune banner facing the arena center (inner-Z face) ----
		# Banner backdrop drape
		var drape: MeshInstance3D = MeshInstance3D.new()
		var dm: BoxMesh = BoxMesh.new()
		dm.size = Vector3(1.10, 4.20, 0.06)
		drape.mesh = dm
		drape.material_override = drape_mat
		drape.position = Vector3(0, 7.00, -0.74)
		pgroup.add_child(drape)
		# Drape brass top rod
		var rod: MeshInstance3D = MeshInstance3D.new()
		var rmm: CylinderMesh = CylinderMesh.new()
		rmm.top_radius = 0.05
		rmm.bottom_radius = 0.05
		rmm.height = 1.30
		rod.mesh = rmm
		rod.material_override = brass_mat
		rod.position = Vector3(0, 9.05, -0.74)
		rod.rotation.z = PI / 2.0
		pgroup.add_child(rod)
		# 4 glowing rune crossbars on the drape
		for ry in [5.30, 6.30, 7.30, 8.30]:
			var rune: MeshInstance3D = MeshInstance3D.new()
			var rcm: BoxMesh = BoxMesh.new()
			rcm.size = Vector3(0.85, 0.10, 0.04)
			rune.mesh = rcm
			rune.material_override = rune_mat
			rune.position = Vector3(0, ry, -0.78)
			pgroup.add_child(rune)
		# Glowing torus crest at the top of the banner
		var crest: MeshInstance3D = MeshInstance3D.new()
		var ctm: TorusMesh = TorusMesh.new()
		ctm.inner_radius = 0.20
		ctm.outer_radius = 0.32
		crest.mesh = ctm
		crest.material_override = rune_mat
		crest.position = Vector3(0, 9.10, -0.78)
		crest.rotation.x = PI / 2.0
		pgroup.add_child(crest)
	# ---- Iron warning chains hanging between adjacent corner pillars ----
	# 4 chains forming a square perimeter around the arena
	var chain_pairs: Array = [
		[Vector3(-13.0, 0, -13.0), Vector3(13.0, 0, -13.0)],
		[Vector3(13.0, 0, -13.0), Vector3(13.0, 0, 13.0)],
		[Vector3(13.0, 0, 13.0), Vector3(-13.0, 0, 13.0)],
		[Vector3(-13.0, 0, 13.0), Vector3(-13.0, 0, -13.0)],
	]
	for pair in chain_pairs:
		var a: Vector3 = pair[0]
		var b: Vector3 = pair[1]
		var mid: Vector3 = (a + b) * 0.5
		var dir: Vector3 = b - a
		var ang: float = atan2(dir.x, dir.z)
		var span: float = dir.length()
		# Top chain
		var top_chain: MeshInstance3D = MeshInstance3D.new()
		var tcm: BoxMesh = BoxMesh.new()
		tcm.size = Vector3(0.18, 0.18, span)
		top_chain.mesh = tcm
		top_chain.material_override = iron_mat
		top_chain.position = Vector3(mid.x, 4.50, mid.z)
		top_chain.rotation.y = ang
		pivot.add_child(top_chain)
		# Mid chain (slightly lower)
		var mid_chain: MeshInstance3D = MeshInstance3D.new()
		mid_chain.mesh = tcm
		mid_chain.material_override = iron_mat
		mid_chain.position = Vector3(mid.x, 3.20, mid.z)
		mid_chain.rotation.y = ang
		pivot.add_child(mid_chain)
	# ---- Pulses ----
	# Brazier flame flicker
	var fpulse: Tween = pivot.create_tween().set_loops()
	fpulse.tween_property(flame_mat, "emission_energy_multiplier", 12.0, 0.5).set_ease(Tween.EASE_IN_OUT)
	fpulse.tween_property(flame_mat, "emission_energy_multiplier", 8.5, 0.5).set_ease(Tween.EASE_IN_OUT)
	# Rune crossbar + crest pulse
	var rpulse: Tween = pivot.create_tween().set_loops()
	rpulse.tween_property(rune_mat, "emission_energy_multiplier", 9.5, 1.6).set_ease(Tween.EASE_IN_OUT)
	rpulse.tween_property(rune_mat, "emission_energy_multiplier", 5.5, 1.6).set_ease(Tween.EASE_IN_OUT)
