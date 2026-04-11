class_name D2Builder
extends RefCounted
## Stack Outskirts district builder — extracted from scenes/town/town.gd to keep
## the main town script modular and under control.
##
## D2 has a special boundary helper `_unlock_east_gate_and_extend` instead of
## the simple `_extend_boundary_for_dN` pattern used by D3-D9, because D2 is
## the first district unlocked after the East Plaza tutorial gate.

const D2_CENTER := Vector3(85, 0, 0)


static func build(town: Node, geom: Node) -> void:
	## Entry point — called from town.gd::_build_district_2(geom).
	print("[D2Builder] start")
	_unlock_east_gate_and_extend(geom)
	_build_d2_ground(geom)
	_build_d2_entrance_arch(geom)
	_build_d2_broken_tower(geom)
	_build_d2_survivor_npc(town)
	_build_d2_crashed_ship(geom)
	_build_d2_glitch_enemies(geom)
	_build_d2_flicker_lamps(geom)
	_build_d2_junk_pile(geom)
	_build_d2_abandoned_kiosk(geom)
	_build_d2_craters(geom)
	_build_d2_barricade(geom)
	_build_d2_toxic_puddles(geom)
	_build_d2_falling_sparks(geom)
	_build_d2_scavenger_npc(town)
	_build_d2_trial_pit(geom)
	_build_d2_mercenary_tent(geom)
	_build_d2_caution_stripes(geom)
	_build_d2_black_market_npc(town)
	_build_d2_watchtower(geom)
	_build_d2_data_conduits(geom)
	_build_d2_server_farm(geom)
	_build_d2_cracked_billboard(geom)
	_build_d2_shipping_containers(geom)
	_build_d2_glitch_beast(geom)
	_build_d2_repair_workshop(geom)
	_build_d2_holo_graffiti(geom)
	_build_d2_drone_wreckage(geom)
	_build_d2_watchman_npc(town)
	_build_d2_smoke_vents(geom)
	_build_d2_toxic_barrels(geom)
	_build_d2_buried_arm(geom)
	_build_d2_fire_pit(geom)
	_build_d2_hoverbike_wreck(geom)
	_build_d2_code_waterfall(geom)
	_build_d2_dust_storm(geom)
	_build_d2_data_well(geom)
	_build_d2_scrap_tower(geom)
	_build_d2_scrap_vendor_cart(geom)
	_build_d2_smuggler_npc(town)
	_build_d2_holo_wireframe(geom)
	_build_d2_caged_bugs(geom)
	_build_d2_arc_generator(geom)
	_build_d2_hover_platform(geom)
	_build_d2_arms_dealer_npc(town)
	_build_d2_cracked_road(geom)
	_build_d2_med_tent(geom)
	_build_d2_satellite_dish(geom)
	_build_d2_cage_arena(geom)
	_build_d2_corrupted_titan(geom)
	_build_d2_power_substation(geom)
	_build_d2_corpse_pile(geom)
	_build_d2_hover_truck_wreck(geom)
	_build_d2_faction_wall(geom)
	_build_d2_hacker_npc(town)
	_build_d2_sniper_npc(town)
	_build_d2_treasure_chest(geom)
	_build_d2_graveyard(geom)
	_build_d2_data_packets(geom)
	_build_d2_turret(geom)
	_build_d2_floating_debris(geom)
	_build_d2_power_lines(geom)
	_build_d2_quarantine_zone(geom)
	_build_d2_lander_pod(geom)
	_build_d2_info_broker_npc(town)
	_build_d2_rune_pile(geom)
	_build_d2_broken_clock(geom)
	_build_d2_arrow_signs(geom)
	_build_d2_zipline(geom)
	_build_d2_mechanic_npc(town)
	_build_d2_parkour_course(geom)
	_build_d2_debris_belt(geom)
	_build_d2_ruins(geom)
	_build_d2_reality_tear(geom)
	_build_d2_glitch_rain(geom)
	_build_d2_mail_terminal(geom)
	_build_d2_trading_post(geom)
	_build_d2_playground(geom)
	_build_d2_data_scrolls(geom)
	_build_d2_enchanter_npc(town)
	_build_d2_hospital_wing(geom)
	_build_d2_garage(geom)
	_build_d2_library_ruins(geom)
	_build_d2_gargoyles(geom)
	_build_d2_boss_arena_teaser(geom)
	_build_d2_rival_faction_wall(geom)
	_build_d2_skill_trainer_npc(town)
	_build_d2_ground_fissure(geom)
	_build_d2_scratch_decals(geom)
	_build_d2_ammo_stash(geom)
	_build_d2_cargo_lift(geom)
	_build_d2_ember_drift(geom)
	_build_d2_unknown_tomb(geom)
	_build_d2_stalker_enemy(geom)
	_build_d2_boss_fortifications(geom)
	_build_d2_welcome_banner(geom)
	_build_d2_red_fog(geom)
	_build_d2_epic2_plaque(geom)
	_build_d2_ambient_lighting(geom)
	_build_d2_glitch_herald_landmark(geom)
	print("[D2Builder] done")


static func _unlock_east_gate_and_extend(geom: Node) -> void:
	## Epic-2 T1: disable the locked east gate forcefield (player can now
	## walk through), push the east boundary wall from x=70 to x=120 to
	## make room for District 2.
	# Find the east gate node
	var gate: Node = geom.get_node_or_null("EastPlazaEastGate")
	if gate:
		# Remove the forcefield collision so the player can pass
		var field: MeshInstance3D = gate.get_node_or_null("GateForceField") as MeshInstance3D
		if field:
			# Make it a translucent decorative shimmer instead of solid
			field.scale = Vector3(1.0, 1.0, 0.05)
			# Remove all StaticBody3D children of the gate (which include the
			# forcefield collider and the pillar colliders — keep pillars by
			# rebuilding their colliders selectively below)
			pass
		# The locked sign should change to "UNLOCKED"
		for child in gate.get_children():
			if child is Label3D:
				(child as Label3D).text = "DISTRICT 2\nSECTOR OPEN"
				(child as Label3D).modulate = Color(0.40, 1.0, 0.55)
		# Find the gate forcefield static body and remove it specifically.
		# The pillar bodies are also static bodies but we want to keep those.
		# Strategy: walk the gate's children, find StaticBody3Ds with a single
		# BoxShape3D matching the field collider size (5.6 x 6.2 x 0.5).
		var to_remove: Array[Node] = []
		for child in gate.get_children():
			if child is StaticBody3D:
				for shape_child in (child as StaticBody3D).get_children():
					if shape_child is CollisionShape3D:
						var shp: Shape3D = (shape_child as CollisionShape3D).shape
						if shp is BoxShape3D:
							var sz: Vector3 = (shp as BoxShape3D).size
							if sz.x == 5.6 and sz.y == 6.2 and sz.z == 0.5:
								to_remove.append(child)
		for body in to_remove:
			body.queue_free()
	# Push the boundary east wall
	var east_wall: CSGBox3D = geom.get_node_or_null("BoundaryEast") as CSGBox3D
	if east_wall:
		east_wall.position.x = 120.0


static func _build_d2_ground(geom: Node) -> void:
	## Epic-2 T2: District 2 ground — darker amber/red cracked digital floor
	## extending from x=68 to x=118. Uses a different shader variant to
	## visually distinguish from the cyan East Plaza tiles.
	var plane: PlaneMesh = PlaneMesh.new()
	plane.size = Vector2(50, 40)
	var ground: MeshInstance3D = MeshInstance3D.new()
	ground.name = "D2Ground"
	ground.mesh = plane
	ground.position = Vector3(93, 0, 0)
	# Reuse a tweaked version of the digital grid shader — amber instead of cyan
	var shader: Shader = Shader.new()
	shader.code = """
shader_type spatial;
render_mode unshaded;
uniform vec3 base_color = vec3(0.10, 0.06, 0.04);
uniform vec3 grid_color = vec3(1.00, 0.40, 0.10);
uniform float grid_scale = 1.4;
uniform float line_width = 0.04;

void fragment() {
	vec2 uv = UV * grid_scale * 30.0;
	vec2 grid = abs(fract(uv - 0.5) - 0.5) / fwidth(uv);
	float line = min(grid.x, grid.y);
	float strength = 1.0 - min(line, 1.0);
	vec3 color = mix(base_color, grid_color, strength * 0.85);
	ALBEDO = color;
}
"""
	var smat: ShaderMaterial = ShaderMaterial.new()
	smat.shader = shader
	ground.material_override = smat
	geom.add_child(ground)
	# StaticBody for ground collision so player doesn't fall through
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var bs: BoxShape3D = BoxShape3D.new()
	bs.size = Vector3(50, 0.10, 40)
	cs.shape = bs
	cs.position = Vector3(0, -0.05, 0)
	sb.add_child(cs)
	ground.add_child(sb)


static func _build_d2_entrance_arch(geom: Node) -> void:
	## Epic-2 T3: a wide cracked stone arch at the D2 entrance (just east of
	## the unlocked plaza gate) reading "STACK OVERFLOW OUTSKIRTS".
	var arch: Node3D = Node3D.new()
	arch.name = "D2EntranceArch"
	arch.position = Vector3(70, 0, 0)
	geom.add_child(arch)
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.16, 0.10, 0.06)
	stone_mat.metallic = 0.45
	stone_mat.roughness = 0.65
	stone_mat.emission_enabled = true
	stone_mat.emission = Color(0.85, 0.30, 0.10)
	stone_mat.emission_energy_multiplier = 0.30
	# 2 wide pillars
	for sx: float in [-4.0, 4.0]:
		var pillar: MeshInstance3D = MeshInstance3D.new()
		var pmesh: BoxMesh = BoxMesh.new()
		pmesh.size = Vector3(1.6, 7.5, 1.6)
		pillar.mesh = pmesh
		pillar.position = Vector3(sx, 3.75, 0)
		pillar.material_override = stone_mat
		arch.add_child(pillar)
		# Cracked emissive stripe
		var crack: MeshInstance3D = MeshInstance3D.new()
		var cmesh: BoxMesh = BoxMesh.new()
		cmesh.size = Vector3(0.06, 6.0, 1.7)
		crack.mesh = cmesh
		crack.position = Vector3(sx + (-0.81 if sx < 0 else 0.81), 3.5, 0)
		var crack_mat: StandardMaterial3D = StandardMaterial3D.new()
		crack_mat.albedo_color = Color(1.0, 0.40, 0.20)
		crack_mat.emission_enabled = true
		crack_mat.emission = Color(1.0, 0.55, 0.20)
		crack_mat.emission_energy_multiplier = 1.8
		crack_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		crack.material_override = crack_mat
		arch.add_child(crack)
		# Collision
		var sb: StaticBody3D = StaticBody3D.new()
		var cs: CollisionShape3D = CollisionShape3D.new()
		var cb: BoxShape3D = BoxShape3D.new()
		cb.size = Vector3(1.6, 7.5, 1.6)
		cs.shape = cb
		cs.position = Vector3(sx, 3.75, 0)
		sb.add_child(cs)
		arch.add_child(sb)
	# Lintel
	var lintel: MeshInstance3D = MeshInstance3D.new()
	var lmesh: BoxMesh = BoxMesh.new()
	lmesh.size = Vector3(9.5, 1.40, 1.60)
	lintel.mesh = lmesh
	lintel.position = Vector3(0, 8.20, 0)
	lintel.material_override = stone_mat
	arch.add_child(lintel)
	# Big district name on the lintel
	for fz: float in [-0.81, 0.81]:
		var label: Label3D = Label3D.new()
		label.text = "STACK OVERFLOW\nOUTSKIRTS"
		label.position = Vector3(0, 8.20, fz)
		label.rotation = Vector3(0, deg_to_rad(0 if fz > 0 else 180), 0)
		label.modulate = Color(1.0, 0.55, 0.20)
		label.outline_modulate = Color(0, 0, 0, 0.85)
		label.outline_size = 6
		label.font_size = 22
		label.no_depth_test = true
		arch.add_child(label)


static func _build_d2_broken_tower(geom: Node) -> void:
	## Epic-2 T4: a tall broken data tower as the first D2 landmark. Stone
	## column with a snapped top, glowing internal "wires" exposed, leaning
	## slightly. Sells "this district is in disrepair".
	var tower: Node3D = Node3D.new()
	tower.name = "D2BrokenTower"
	tower.position = D2_CENTER + Vector3(-8, 0, -10)
	tower.rotation = Vector3(deg_to_rad(8), 0, deg_to_rad(-5))
	geom.add_child(tower)
	# Lower intact column
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.18, 0.14, 0.10)
	stone_mat.metallic = 0.45
	stone_mat.roughness = 0.55
	var lower: MeshInstance3D = MeshInstance3D.new()
	var lmesh: CylinderMesh = CylinderMesh.new()
	lmesh.top_radius = 0.95
	lmesh.bottom_radius = 1.10
	lmesh.height = 6.0
	lower.mesh = lmesh
	lower.position = Vector3(0, 3.0, 0)
	lower.material_override = stone_mat
	tower.add_child(lower)
	# Broken jagged top piece (smaller cylinder)
	var top: MeshInstance3D = MeshInstance3D.new()
	var tmesh: CylinderMesh = CylinderMesh.new()
	tmesh.top_radius = 0.40
	tmesh.bottom_radius = 0.85
	tmesh.height = 2.5
	top.mesh = tmesh
	top.position = Vector3(0, 7.25, 0)
	top.rotation = Vector3(deg_to_rad(15), deg_to_rad(20), deg_to_rad(-10))
	top.material_override = stone_mat
	tower.add_child(top)
	# Exposed glowing internal wires — 4 thin emissive bars protruding
	var wire_mat: StandardMaterial3D = StandardMaterial3D.new()
	wire_mat.albedo_color = Color(1.0, 0.40, 0.20)
	wire_mat.emission_enabled = true
	wire_mat.emission = Color(1.0, 0.55, 0.20)
	wire_mat.emission_energy_multiplier = 2.4
	wire_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for w in 4:
		var wire: MeshInstance3D = MeshInstance3D.new()
		var wmesh: CylinderMesh = CylinderMesh.new()
		wmesh.top_radius = 0.04
		wmesh.bottom_radius = 0.04
		wmesh.height = 1.4
		wire.mesh = wmesh
		var angle: float = (float(w) / 4.0) * TAU
		wire.position = Vector3(cos(angle) * 0.3, 6.4, sin(angle) * 0.3)
		wire.rotation = Vector3(deg_to_rad(randf_range(-30, 30)), 0, deg_to_rad(randf_range(-30, 30)))
		wire.material_override = wire_mat
		tower.add_child(wire)
	# Sparking glowing core at the break point
	var core: MeshInstance3D = MeshInstance3D.new()
	var cmesh: SphereMesh = SphereMesh.new()
	cmesh.radius = 0.30
	cmesh.height = 0.60
	core.mesh = cmesh
	core.position = Vector3(0, 6.10, 0)
	var cmat: StandardMaterial3D = StandardMaterial3D.new()
	cmat.albedo_color = Color(1.0, 0.85, 0.30)
	cmat.emission_enabled = true
	cmat.emission = Color(1.0, 0.95, 0.40)
	cmat.emission_energy_multiplier = 2.6
	cmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	core.material_override = cmat
	tower.add_child(core)
	# Spark particle burst from the core
	var sparks: GPUParticles3D = GPUParticles3D.new()
	sparks.amount = 30
	sparks.lifetime = 0.85
	sparks.position = Vector3(0, 6.10, 0)
	var pmat: ParticleProcessMaterial = ParticleProcessMaterial.new()
	pmat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	pmat.emission_sphere_radius = 0.20
	pmat.direction = Vector3(0, 1, 0)
	pmat.spread = 80.0
	pmat.initial_velocity_min = 1.5
	pmat.initial_velocity_max = 3.0
	pmat.gravity = Vector3(0, -3.5, 0)
	pmat.scale_min = 0.05
	pmat.scale_max = 0.10
	pmat.color = Color(1.0, 0.85, 0.30, 1.0)
	sparks.process_material = pmat
	var spark_mesh: SphereMesh = SphereMesh.new()
	spark_mesh.radius = 0.05
	spark_mesh.height = 0.10
	var spark_mat: StandardMaterial3D = StandardMaterial3D.new()
	spark_mat.albedo_color = Color(1.0, 0.85, 0.30)
	spark_mat.emission_enabled = true
	spark_mat.emission = Color(1.0, 0.95, 0.40)
	spark_mat.emission_energy_multiplier = 2.5
	spark_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	spark_mesh.material = spark_mat
	sparks.draw_pass_1 = spark_mesh
	tower.add_child(sparks)
	# Pulse the core
	var pulse: Tween = create_tween().set_loops()
	pulse.tween_property(core, "scale", Vector3(1.30, 1.30, 1.30), 0.45).set_ease(Tween.EASE_IN_OUT)
	pulse.tween_property(core, "scale", Vector3(1.0, 1.0, 1.0), 0.45).set_ease(Tween.EASE_IN_OUT)
	# Collision around the column
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cap: CapsuleShape3D = CapsuleShape3D.new()
	cap.radius = 1.10
	cap.height = 6.0
	cs.shape = cap
	cs.position = Vector3(0, 3.0, 0)
	sb.add_child(cs)
	tower.add_child(sb)


static func _build_d2_survivor_npc(town: Node) -> void:
	## Epic-2 T5: wandering survivor NPC in the D2 entrance area. Hooded
	## procedural figure with a worn cyan cloak, slowly walking back and
	## forth on a patrol tween. The first inhabitant of District 2.
	var slots: Node3D = town.get_node_or_null("%NPCSlots") as Node3D
	if slots == null:
		return
	var survivor: Node3D = Node3D.new()
	survivor.name = "D2Survivor"
	survivor.position = D2_CENTER + Vector3(-12, 0, 4)
	slots.add_child(survivor)
	# Body capsule — worn brown cloak
	var body: MeshInstance3D = MeshInstance3D.new()
	var bmesh: CapsuleMesh = CapsuleMesh.new()
	bmesh.radius = 0.42
	bmesh.height = 1.20
	body.mesh = bmesh
	body.position = Vector3(0, 0.65, 0)
	var bmat: StandardMaterial3D = StandardMaterial3D.new()
	bmat.albedo_color = Color(0.30, 0.25, 0.20)
	bmat.metallic = 0.10
	bmat.roughness = 0.65
	body.material_override = bmat
	survivor.add_child(body)
	# Hood — wider half sphere on top
	var hood: MeshInstance3D = MeshInstance3D.new()
	var hmesh: SphereMesh = SphereMesh.new()
	hmesh.radius = 0.45
	hmesh.height = 0.55
	hood.mesh = hmesh
	hood.position = Vector3(0, 1.45, 0)
	var hmat: StandardMaterial3D = StandardMaterial3D.new()
	hmat.albedo_color = Color(0.20, 0.16, 0.12)
	hmat.metallic = 0.10
	hmat.roughness = 0.70
	hood.material_override = hmat
	survivor.add_child(hood)
	# 2 dim cyan eyes peeking from the hood shadow
	var eye_mat: StandardMaterial3D = StandardMaterial3D.new()
	eye_mat.albedo_color = Color(0.30, 0.85, 1.0)
	eye_mat.emission_enabled = true
	eye_mat.emission = Color(0.30, 0.85, 1.0)
	eye_mat.emission_energy_multiplier = 1.8
	eye_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for ex: float in [-0.10, 0.10]:
		var eye: MeshInstance3D = MeshInstance3D.new()
		var emesh: SphereMesh = SphereMesh.new()
		emesh.radius = 0.05
		emesh.height = 0.10
		eye.mesh = emesh
		eye.position = Vector3(ex, 1.30, 0.30)
		eye.material_override = eye_mat
		survivor.add_child(eye)
	# Walking stick
	var stick: MeshInstance3D = MeshInstance3D.new()
	var smesh: CylinderMesh = CylinderMesh.new()
	smesh.top_radius = 0.04
	smesh.bottom_radius = 0.05
	smesh.height = 1.6
	stick.mesh = smesh
	stick.position = Vector3(0.45, 0.80, 0)
	var stmat: StandardMaterial3D = StandardMaterial3D.new()
	stmat.albedo_color = Color(0.25, 0.18, 0.10)
	stick.material_override = stmat
	survivor.add_child(stick)
	# Stick tip glow
	var tip: MeshInstance3D = MeshInstance3D.new()
	var tip_mesh: SphereMesh = SphereMesh.new()
	tip_mesh.radius = 0.10
	tip_mesh.height = 0.20
	tip.mesh = tip_mesh
	tip.position = Vector3(0.45, 1.65, 0)
	var tip_mat: StandardMaterial3D = StandardMaterial3D.new()
	tip_mat.albedo_color = Color(0.30, 0.85, 1.0)
	tip_mat.emission_enabled = true
	tip_mat.emission = Color(0.55, 0.95, 1.0)
	tip_mat.emission_energy_multiplier = 2.4
	tip_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	tip.material_override = tip_mat
	survivor.add_child(tip)
	# Name billboard
	var label: Label3D = Label3D.new()
	label.text = "Wanderer"
	label.position = Vector3(0, 1.95, 0)
	label.modulate = Color(0.85, 0.85, 0.55)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 18
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	survivor.add_child(label)
	# Walking patrol tween
	var origin: Vector3 = D2_CENTER + Vector3(-12, 0, 4)
	var patrol: Tween = create_tween().set_loops()
	patrol.tween_property(survivor, "rotation:y", deg_to_rad(90), 0.4)
	patrol.tween_property(survivor, "position", origin + Vector3(0, 0, 6), 5.0)
	patrol.tween_property(survivor, "rotation:y", deg_to_rad(-90), 0.4)
	patrol.tween_property(survivor, "position", origin, 5.0)


func _build_east_plaza_ground(geom: Node) -> void:
	## Cyan grid floor extension stitched to main town ground at x=20.
	var plane: PlaneMesh = PlaneMesh.new()
	plane.size = Vector2(24, 40)
	var ground: MeshInstance3D = MeshInstance3D.new()
	ground.name = "EastPlazaGround"
	ground.mesh = plane
	ground.position = Vector3(32, 0, 0)
	# Reuse the same digital grid shader as the main ground for visual continuity
	var shader: Shader = Shader.new()
	shader.code = """
shader_type spatial;
render_mode unshaded, depth_draw_opaque, cull_back;
uniform vec3 base_color : source_color = vec3(0.04, 0.06, 0.10);
uniform vec3 grid_color : source_color = vec3(0.85, 0.45, 0.15);
uniform vec3 hex_color : source_color = vec3(0.45, 0.20, 0.05);
uniform float grid_scale = 12.0;
uniform float grid_thickness = 0.04;
uniform float pulse_speed = 0.6;
void fragment() {
	vec2 uv = UV * grid_scale;
	vec2 g = abs(fract(uv) - 0.5);
	float line = step(0.5 - grid_thickness, max(g.x, g.y));
	vec2 g5 = abs(fract(uv * 0.2) - 0.5);
	float lane = step(0.5 - grid_thickness * 0.6, max(g5.x, g5.y));
	float pulse = 0.6 + 0.4 * sin(TIME * pulse_speed + uv.x * 0.4 + uv.y * 0.3);
	vec3 col = base_color;
	col = mix(col, hex_color, lane * 0.55);
	col = mix(col, grid_color * pulse, line * 0.85);
	ALBEDO = col;
	EMISSION = col * 0.75;
}
"""
	var mat: ShaderMaterial = ShaderMaterial.new()
	mat.shader = shader
	ground.material_override = mat
	geom.add_child(ground)
	# Collision under the ground extension
	var body: StaticBody3D = StaticBody3D.new()
	var shape: CollisionShape3D = CollisionShape3D.new()
	var box: BoxShape3D = BoxShape3D.new()
	box.size = Vector3(24, 0.2, 40)
	shape.shape = box
	shape.position = Vector3(0, -0.1, 0)
	body.add_child(shape)
	ground.add_child(body)


func _build_east_plaza_path(geom: Node) -> void:
	## Glowing data lane stitching main town ground (x=20) to plaza center (x=32)
	var path: CSGBox3D = CSGBox3D.new()
	path.size = Vector3(12, 0.02, 3)
	path.position = Vector3(26, 0.01, 0)
	path.material = _make_dirt_path_material()
	geom.add_child(path)


func _build_data_terminal(geom: Node, center: Vector3) -> void:
	## Procedural data terminal — hexagonal pillar with glowing top dome
	var terminal_root: Node3D = Node3D.new()
	terminal_root.name = "EastPlazaDataTerminal"
	terminal_root.position = center
	geom.add_child(terminal_root)
	# Hex pillar base
	var pillar: MeshInstance3D = MeshInstance3D.new()
	var pillar_mesh: CylinderMesh = CylinderMesh.new()
	pillar_mesh.top_radius = 0.5
	pillar_mesh.bottom_radius = 0.7
	pillar_mesh.height = 1.6
	pillar_mesh.radial_segments = 6
	pillar.mesh = pillar_mesh
	pillar.position = Vector3(0, 0.8, 0)
	var pillar_mat: StandardMaterial3D = StandardMaterial3D.new()
	pillar_mat.albedo_color = Color(0.10, 0.16, 0.22)
	pillar_mat.emission_enabled = true
	pillar_mat.emission = Color(0.85, 0.45, 0.15)
	pillar_mat.emission_energy_multiplier = 0.45
	pillar_mat.metallic = 0.7
	pillar_mat.roughness = 0.35
	pillar.material_override = pillar_mat
	terminal_root.add_child(pillar)
	# Glowing dome on top
	var dome: MeshInstance3D = MeshInstance3D.new()
	var dome_mesh: SphereMesh = SphereMesh.new()
	dome_mesh.radius = 0.55
	dome_mesh.height = 0.7
	dome_mesh.is_hemisphere = true
	dome.mesh = dome_mesh
	dome.position = Vector3(0, 1.6, 0)
	var dome_mat: StandardMaterial3D = StandardMaterial3D.new()
	dome_mat.albedo_color = Color(0.95, 0.55, 0.20)
	dome_mat.emission_enabled = true
	dome_mat.emission = Color(1.0, 0.55, 0.10)
	dome_mat.emission_energy_multiplier = 2.5
	dome_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	dome.material_override = dome_mat
	terminal_root.add_child(dome)
	# Spinning ring decoration
	var ring: MeshInstance3D = MeshInstance3D.new()
	var ring_mesh: TorusMesh = TorusMesh.new()
	ring_mesh.inner_radius = 0.7
	ring_mesh.outer_radius = 0.85
	ring_mesh.rings = 16
	ring_mesh.ring_segments = 16
	ring.mesh = ring_mesh
	ring.position = Vector3(0, 1.2, 0)
	var ring_mat: StandardMaterial3D = StandardMaterial3D.new()
	ring_mat.albedo_color = Color(0.2, 0.6, 0.85)
	ring_mat.emission_enabled = true
	ring_mat.emission = Color(0.3, 0.7, 1.0)
	ring_mat.emission_energy_multiplier = 1.8
	ring_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	ring.material_override = ring_mat
	terminal_root.add_child(ring)
	# Spin animation
	var spin: Tween = create_tween().set_loops()
	spin.tween_property(ring, "rotation:y", TAU, 8.0)
	# Collision
	var body: StaticBody3D = StaticBody3D.new()
	var shape: CollisionShape3D = CollisionShape3D.new()
	var col_box: BoxShape3D = BoxShape3D.new()
	col_box.size = Vector3(1.4, 2.2, 1.4)
	shape.shape = col_box
	shape.position = Vector3(0, 1.1, 0)
	body.add_child(shape)
	terminal_root.add_child(body)


func _build_kiosks(geom: Node) -> void:
	## 4 holographic kiosks arranged around the data terminal
	var positions: Array[Vector3] = [
		Vector3(28, 0, -4), Vector3(36, 0, -4),
		Vector3(28, 0, 4), Vector3(36, 0, 4),
	]
	for pos in positions:
		var kiosk: Node3D = Node3D.new()
		kiosk.position = pos
		geom.add_child(kiosk)
		# Stand
		var stand: MeshInstance3D = MeshInstance3D.new()
		var stand_mesh: BoxMesh = BoxMesh.new()
		stand_mesh.size = Vector3(0.6, 0.8, 0.4)
		stand.mesh = stand_mesh
		stand.position = Vector3(0, 0.4, 0)
		var stand_mat: StandardMaterial3D = StandardMaterial3D.new()
		stand_mat.albedo_color = Color(0.12, 0.18, 0.26)
		stand_mat.emission_enabled = true
		stand_mat.emission = Color(0.15, 0.55, 0.75)
		stand_mat.emission_energy_multiplier = 0.4
		stand_mat.metallic = 0.6
		stand.material_override = stand_mat
		kiosk.add_child(stand)
		# Holographic panel
		var holo: MeshInstance3D = MeshInstance3D.new()
		var holo_mesh: BoxMesh = BoxMesh.new()
		holo_mesh.size = Vector3(0.7, 0.55, 0.04)
		holo.mesh = holo_mesh
		holo.position = Vector3(0, 1.1, 0)
		var holo_mat: StandardMaterial3D = StandardMaterial3D.new()
		holo_mat.albedo_color = Color(0.25, 0.7, 0.95, 0.55)
		holo_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		holo_mat.emission_enabled = true
		holo_mat.emission = Color(0.35, 0.8, 1.0)
		holo_mat.emission_energy_multiplier = 2.2
		holo_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		holo.material_override = holo_mat
		kiosk.add_child(holo)
		# Collision
		var body: StaticBody3D = StaticBody3D.new()
		var shape: CollisionShape3D = CollisionShape3D.new()
		var box: BoxShape3D = BoxShape3D.new()
		box.size = Vector3(0.7, 1.5, 0.5)
		shape.shape = box
		shape.position = Vector3(0, 0.75, 0)
		body.add_child(shape)
		kiosk.add_child(body)


func _build_queue_bollards(geom: Node) -> void:
	## Short cyan posts forming a queue path leading to the data terminal
	for i: int in range(0, 6):
		var bollard: MeshInstance3D = MeshInstance3D.new()
		var b_mesh: CylinderMesh = CylinderMesh.new()
		b_mesh.top_radius = 0.08
		b_mesh.bottom_radius = 0.10
		b_mesh.height = 0.7
		bollard.mesh = b_mesh
		bollard.position = Vector3(28 - i * 0.8, 0.35, 7)
		var b_mat: StandardMaterial3D = StandardMaterial3D.new()
		b_mat.albedo_color = Color(0.10, 0.18, 0.26)
		b_mat.emission_enabled = true
		b_mat.emission = Color(0.20, 0.65, 0.90)
		b_mat.emission_energy_multiplier = 0.7
		bollard.material_override = b_mat
		geom.add_child(bollard)


func _build_market_particles(geom: Node) -> void:
	## Ambient orange + cyan code dust drifting through the plaza
	var particles: GPUParticles3D = GPUParticles3D.new()
	particles.amount = 60
	particles.lifetime = 6.0
	particles.position = Vector3(32, 2.0, 0)
	var pmat: ParticleProcessMaterial = ParticleProcessMaterial.new()
	pmat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	pmat.emission_box_extents = Vector3(10, 1.5, 18)
	pmat.direction = Vector3(0, -1, 0)
	pmat.gravity = Vector3(0, -0.15, 0)
	pmat.initial_velocity_min = 0.1
	pmat.initial_velocity_max = 0.3
	pmat.scale_min = 0.05
	pmat.scale_max = 0.12
	pmat.color = Color(0.95, 0.55, 0.15, 0.6)
	particles.process_material = pmat
	var dot_mesh: SphereMesh = SphereMesh.new()
	dot_mesh.radius = 0.04
	dot_mesh.height = 0.08
	particles.draw_pass_1 = dot_mesh
	geom.add_child(particles)


func _build_plaza_lights(geom: Node) -> void:
	## 4 amber omni lights anchored at the kiosk corners
	for pos in [Vector3(28, 2.5, -4), Vector3(36, 2.5, -4), Vector3(28, 2.5, 4), Vector3(36, 2.5, 4)]:
		var light: OmniLight3D = OmniLight3D.new()
		light.position = pos
		light.light_color = Color(1.0, 0.65, 0.35)
		light.light_energy = 1.4
		light.omni_range = 8.0
		light.omni_attenuation = 1.5
		geom.add_child(light)


func _build_data_merchant_npc() -> void:
	## Place a stationary glowing orb NPC at the kiosk row. No dialogue
	## logic yet — that's a future task. For now: visible orb with name label.
	var merchant: Node3D = Node3D.new()
	merchant.name = "EastPlazaDataMerchant"
	merchant.position = Vector3(32, 0.5, -7)
	add_child(merchant)
	var body: MeshInstance3D = MeshInstance3D.new()
	var sphere: SphereMesh = SphereMesh.new()
	sphere.radius = 0.4
	sphere.height = 0.8
	body.mesh = sphere
	var mat: StandardMaterial3D = StandardMaterial3D.new()
	mat.albedo_color = Color(0.95, 0.55, 0.15)
	mat.emission_enabled = true
	mat.emission = Color(1.0, 0.6, 0.2)
	mat.emission_energy_multiplier = 0.8
	mat.metallic = 0.4
	body.material_override = mat
	merchant.add_child(body)
	# Floating name label
	var label: Label3D = Label3D.new()
	label.text = "Data Merchant"
	label.position = Vector3(0, 1.4, 0)
	label.modulate = Color(1.0, 0.7, 0.3)
	label.outline_modulate = Color(0, 0, 0, 0.8)
	label.outline_size = 6
	label.font_size = 24
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	merchant.add_child(label)


func _build_cipher_npc() -> void:
	## Epic-1 T2: Cipher data broker — colder violet NPC at far east edge
	var cipher: Node3D = Node3D.new()
	cipher.name = "EastPlazaCipher"
	cipher.position = Vector3(40, 0.5, 5)
	add_child(cipher)
	var body: MeshInstance3D = MeshInstance3D.new()
	var sphere: SphereMesh = SphereMesh.new()
	sphere.radius = 0.42
	sphere.height = 0.84
	body.mesh = sphere
	var mat: StandardMaterial3D = StandardMaterial3D.new()
	mat.albedo_color = Color(0.42, 0.20, 0.65)
	mat.emission_enabled = true
	mat.emission = Color(0.55, 0.25, 0.85)
	mat.emission_energy_multiplier = 0.7
	mat.metallic = 0.5
	body.material_override = mat
	cipher.add_child(body)
	# Floating eye
	var eye_mat: StandardMaterial3D = StandardMaterial3D.new()
	eye_mat.albedo_color = Color(0.95, 0.85, 1.0)
	eye_mat.emission_enabled = true
	eye_mat.emission = Color(0.85, 0.55, 1.0)
	eye_mat.emission_energy_multiplier = 2.5
	eye_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for side: float in [-0.13, 0.13]:
		var eye: MeshInstance3D = MeshInstance3D.new()
		var em: SphereMesh = SphereMesh.new()
		em.radius = 0.07
		em.height = 0.14
		eye.mesh = em
		eye.position = Vector3(side, 0.18, -0.32)
		eye.material_override = eye_mat
		body.add_child(eye)
	var label: Label3D = Label3D.new()
	label.text = "Cipher"
	label.position = Vector3(0, 1.4, 0)
	label.modulate = Color(0.85, 0.5, 1.0)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 6
	label.font_size = 24
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	cipher.add_child(label)


func _build_market_hall(geom: Node) -> void:
	## Epic-1 T3: procedural Market Hall NE of the data terminal
	var hall: Node3D = Node3D.new()
	hall.name = "EastPlazaMarketHall"
	hall.position = Vector3(38, 0, -10)
	geom.add_child(hall)
	# Walls (4 panels)
	var hall_mat: StandardMaterial3D = StandardMaterial3D.new()
	hall_mat.albedo_color = Color(0.18, 0.10, 0.04)
	hall_mat.emission_enabled = true
	hall_mat.emission = Color(0.85, 0.45, 0.15)
	hall_mat.emission_energy_multiplier = 0.45
	hall_mat.metallic = 0.4
	hall_mat.roughness = 0.55
	for side in [Vector3(0, 1.5, -3), Vector3(0, 1.5, 3), Vector3(-3, 1.5, 0), Vector3(3, 1.5, 0)]:
		var wall: MeshInstance3D = MeshInstance3D.new()
		var wmesh: BoxMesh = BoxMesh.new()
		# Walls along x-axis are wider in x; walls along z-axis are wider in z
		if abs(side.x) > 0.01:
			wmesh.size = Vector3(0.3, 3.0, 6.0)
		else:
			wmesh.size = Vector3(6.0, 3.0, 0.3)
		wall.mesh = wmesh
		wall.position = side
		wall.material_override = hall_mat
		hall.add_child(wall)
	# Roof (flat slab)
	var roof: MeshInstance3D = MeshInstance3D.new()
	var rmesh: BoxMesh = BoxMesh.new()
	rmesh.size = Vector3(6.4, 0.2, 6.4)
	roof.mesh = rmesh
	roof.position = Vector3(0, 3.1, 0)
	var roof_mat: StandardMaterial3D = StandardMaterial3D.new()
	roof_mat.albedo_color = Color(0.25, 0.15, 0.05)
	roof_mat.emission_enabled = true
	roof_mat.emission = Color(0.65, 0.35, 0.10)
	roof_mat.emission_energy_multiplier = 0.3
	roof_mat.metallic = 0.6
	roof.material_override = roof_mat
	hall.add_child(roof)
	# Marquee strip — horizontal cyan glow above the entrance
	var marquee: MeshInstance3D = MeshInstance3D.new()
	var qmesh: BoxMesh = BoxMesh.new()
	qmesh.size = Vector3(5.5, 0.4, 0.15)
	marquee.mesh = qmesh
	marquee.position = Vector3(0, 2.6, -3.05)
	var qmat: StandardMaterial3D = StandardMaterial3D.new()
	qmat.albedo_color = Color(0.15, 0.55, 0.75)
	qmat.emission_enabled = true
	qmat.emission = Color(0.30, 0.80, 1.0)
	qmat.emission_energy_multiplier = 2.5
	qmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	marquee.material_override = qmat
	hall.add_child(marquee)
	# Marquee text label
	var marquee_text: Label3D = Label3D.new()
	marquee_text.text = "DATA MARKET"
	marquee_text.position = Vector3(0, 2.6, -3.13)
	marquee_text.modulate = Color(1.0, 0.95, 0.85)
	marquee_text.outline_modulate = Color(0, 0.05, 0.15, 1.0)
	marquee_text.outline_size = 8
	marquee_text.font_size = 32
	marquee_text.no_depth_test = true
	hall.add_child(marquee_text)
	# Collision around the hall (simple box covering the perimeter)
	var body: StaticBody3D = StaticBody3D.new()
	for side in [Vector3(0, 1.5, -3), Vector3(0, 1.5, 3), Vector3(-3, 1.5, 0), Vector3(3, 1.5, 0)]:
		var shape: CollisionShape3D = CollisionShape3D.new()
		var cbox: BoxShape3D = BoxShape3D.new()
		if abs(side.x) > 0.01:
			cbox.size = Vector3(0.3, 3.0, 6.0)
		else:
			cbox.size = Vector3(6.0, 3.0, 0.3)
		shape.shape = cbox
		shape.position = side
		body.add_child(shape)
	hall.add_child(body)
	# Interior point light
	var light: OmniLight3D = OmniLight3D.new()
	light.position = Vector3(0, 2.4, 0)
	light.light_color = Color(1.0, 0.7, 0.4)
	light.light_energy = 1.6
	light.omni_range = 8.0
	light.omni_attenuation = 1.5
	hall.add_child(light)


func _attach_kiosk_interactables(geom: Node) -> void:
	## Epic-1 T4: add a small floating "[E] Browse" label above each plaza kiosk
	## (purely visual for now — full dialogue branching is a later epic).
	var positions: Array[Vector3] = [
		Vector3(28, 0, -4), Vector3(36, 0, -4),
		Vector3(28, 0, 4), Vector3(36, 0, 4),
	]
	for pos in positions:
		var label: Label3D = Label3D.new()
		label.text = "[E] Browse"
		label.position = pos + Vector3(0, 1.85, 0)
		label.modulate = Color(0.6, 0.95, 1.0)
		label.outline_modulate = Color(0, 0, 0, 0.85)
		label.outline_size = 6
		label.font_size = 18
		label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		label.no_depth_test = true
		geom.add_child(label)


func _build_market_chatter_zone(geom: Node) -> void:
	## Epic-1 T5: invisible Area3D over the plaza that fires "entered_plaza"
	## meta on the GameManager when the player enters. Future epics can hook
	## ambient market chatter SFX to this trigger.
	var area: Area3D = Area3D.new()
	area.name = "EastPlazaChatterZone"
	area.position = Vector3(32, 1.0, 0)
	var shape: CollisionShape3D = CollisionShape3D.new()
	var box: BoxShape3D = BoxShape3D.new()
	box.size = Vector3(20, 4, 30)
	shape.shape = box
	area.add_child(shape)
	area.collision_layer = 0
	area.collision_mask = 1  # scan player layer
	area.body_entered.connect(func(body: Node3D) -> void:
		if body.is_in_group(&"player"):
			GameManager.set_meta(&"in_east_plaza", true)
	)
	area.body_exited.connect(func(body: Node3D) -> void:
		if body.is_in_group(&"player"):
			GameManager.set_meta(&"in_east_plaza", false)
	)
	geom.add_child(area)


func _build_vendor_stall(geom: Node) -> void:
	## Epic-1 T6: open-air vendor stall at (29, 0, -8) — counter + canopy + 2 stools
	var stall: Node3D = Node3D.new()
	stall.name = "EastPlazaVendorStall"
	stall.position = Vector3(29, 0, -8)
	geom.add_child(stall)
	# Counter
	var counter: MeshInstance3D = MeshInstance3D.new()
	var c_mesh: BoxMesh = BoxMesh.new()
	c_mesh.size = Vector3(2.5, 1.0, 0.7)
	counter.mesh = c_mesh
	counter.position = Vector3(0, 0.5, 0)
	var counter_mat: StandardMaterial3D = StandardMaterial3D.new()
	counter_mat.albedo_color = Color(0.18, 0.10, 0.04)
	counter_mat.emission_enabled = true
	counter_mat.emission = Color(0.85, 0.45, 0.10)
	counter_mat.emission_energy_multiplier = 0.5
	counter_mat.metallic = 0.4
	counter.material_override = counter_mat
	stall.add_child(counter)
	# Canopy supports (4 thin posts)
	for x: float in [-1.1, 1.1]:
		for z: float in [-0.3, 0.3]:
			var post: MeshInstance3D = MeshInstance3D.new()
			var pmesh: CylinderMesh = CylinderMesh.new()
			pmesh.top_radius = 0.04
			pmesh.bottom_radius = 0.05
			pmesh.height = 2.5
			post.mesh = pmesh
			post.position = Vector3(x, 1.25, z)
			var pmat: StandardMaterial3D = StandardMaterial3D.new()
			pmat.albedo_color = Color(0.12, 0.18, 0.26)
			pmat.emission_enabled = true
			pmat.emission = Color(0.20, 0.55, 0.75)
			pmat.emission_energy_multiplier = 0.5
			pmat.metallic = 0.7
			post.material_override = pmat
			stall.add_child(post)
	# Canopy slab
	var canopy: MeshInstance3D = MeshInstance3D.new()
	var canopy_mesh: BoxMesh = BoxMesh.new()
	canopy_mesh.size = Vector3(2.7, 0.1, 1.0)
	canopy.mesh = canopy_mesh
	canopy.position = Vector3(0, 2.6, 0)
	var canopy_mat: StandardMaterial3D = StandardMaterial3D.new()
	canopy_mat.albedo_color = Color(0.30, 0.15, 0.05)
	canopy_mat.emission_enabled = true
	canopy_mat.emission = Color(0.95, 0.50, 0.15)
	canopy_mat.emission_energy_multiplier = 0.6
	canopy.material_override = canopy_mat
	stall.add_child(canopy)
	# Collision (counter blocks the player)
	var body: StaticBody3D = StaticBody3D.new()
	var shape: CollisionShape3D = CollisionShape3D.new()
	var col: BoxShape3D = BoxShape3D.new()
	col.size = Vector3(2.5, 1.0, 0.7)
	shape.shape = col
	shape.position = Vector3(0, 0.5, 0)
	body.add_child(shape)
	stall.add_child(body)


func _build_plaza_pedestrians(geom: Node) -> void:
	## Epic-1 T7: 5 ambient pedestrian orbs drifting on a procedural patrol
	var pedestrian_colors: Array[Color] = [
		Color(0.35, 0.65, 0.85),  # cyan
		Color(0.85, 0.55, 0.30),  # orange
		Color(0.55, 0.35, 0.75),  # violet
		Color(0.65, 0.85, 0.45),  # lime
		Color(0.85, 0.35, 0.45),  # coral
	]
	var spawn_positions: Array[Vector3] = [
		Vector3(28, 0.5, 7), Vector3(35, 0.5, 6),
		Vector3(38, 0.5, -2), Vector3(30, 0.5, -7),
		Vector3(33, 0.5, 8),
	]
	for i: int in pedestrian_colors.size():
		var ped: MeshInstance3D = MeshInstance3D.new()
		ped.name = "EastPlazaPedestrian_%d" % i
		var sphere: SphereMesh = SphereMesh.new()
		sphere.radius = 0.3
		sphere.height = 0.6
		ped.mesh = sphere
		ped.position = spawn_positions[i]
		var mat: StandardMaterial3D = StandardMaterial3D.new()
		mat.albedo_color = pedestrian_colors[i]
		mat.emission_enabled = true
		mat.emission = pedestrian_colors[i] * 1.3
		mat.emission_energy_multiplier = 0.5
		mat.metallic = 0.3
		ped.material_override = mat
		geom.add_child(ped)
		# Drift: bob + slow patrol along a small loop
		var tween: Tween = create_tween().set_loops()
		var orig_pos: Vector3 = ped.position
		var step1: Vector3 = orig_pos + Vector3(randf_range(-2, 2), 0, randf_range(-2, 2))
		var step2: Vector3 = orig_pos + Vector3(randf_range(-2, 2), 0, randf_range(-2, 2))
		tween.tween_property(ped, "position", step1, randf_range(4, 7)).set_ease(Tween.EASE_IN_OUT)
		tween.tween_property(ped, "position", step2, randf_range(4, 7)).set_ease(Tween.EASE_IN_OUT)
		tween.tween_property(ped, "position", orig_pos, randf_range(4, 7)).set_ease(Tween.EASE_IN_OUT)


func _build_loading_dock(geom: Node) -> void:
	## Epic-1 T8: loading dock sub-area at the far east edge — raised platform +
	## crates + warning stripes painted on the ground
	var dock: Node3D = Node3D.new()
	dock.name = "EastPlazaLoadingDock"
	dock.position = Vector3(42, 0, 0)
	geom.add_child(dock)
	# Raised platform
	var platform: MeshInstance3D = MeshInstance3D.new()
	var pmesh: BoxMesh = BoxMesh.new()
	pmesh.size = Vector3(3.5, 0.3, 6)
	platform.mesh = pmesh
	platform.position = Vector3(0, 0.15, 0)
	var pmat: StandardMaterial3D = StandardMaterial3D.new()
	pmat.albedo_color = Color(0.12, 0.18, 0.26)
	pmat.emission_enabled = true
	pmat.emission = Color(0.20, 0.55, 0.75)
	pmat.emission_energy_multiplier = 0.4
	pmat.metallic = 0.65
	platform.material_override = pmat
	dock.add_child(platform)
	# Warning stripes (alternating yellow/black emissive)
	for i: int in 5:
		var stripe: MeshInstance3D = MeshInstance3D.new()
		var smesh: BoxMesh = BoxMesh.new()
		smesh.size = Vector3(3.5, 0.01, 0.4)
		stripe.mesh = smesh
		stripe.position = Vector3(0, 0.32, -2.5 + i * 1.2)
		var smat: StandardMaterial3D = StandardMaterial3D.new()
		var stripe_color := Color(1.0, 0.85, 0.15) if i % 2 == 0 else Color(0.05, 0.05, 0.05)
		smat.albedo_color = stripe_color
		smat.emission_enabled = i % 2 == 0
		smat.emission = stripe_color
		smat.emission_energy_multiplier = 0.6
		smat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		stripe.material_override = smat
		dock.add_child(stripe)
	# Stacked crates (3 boxes)
	for i: int in 3:
		var crate: MeshInstance3D = MeshInstance3D.new()
		var cmesh: BoxMesh = BoxMesh.new()
		cmesh.size = Vector3(0.6, 0.6, 0.6)
		crate.mesh = cmesh
		crate.position = Vector3(-1.0, 0.6 + i * 0.6, -1.5)
		var cmat: StandardMaterial3D = StandardMaterial3D.new()
		cmat.albedo_color = Color(0.30, 0.18, 0.08)
		cmat.emission_enabled = true
		cmat.emission = Color(0.85, 0.50, 0.15)
		cmat.emission_energy_multiplier = 0.4
		cmat.metallic = 0.3
		crate.material_override = cmat
		dock.add_child(crate)
	# Collision for the platform
	var body: StaticBody3D = StaticBody3D.new()
	var shape: CollisionShape3D = CollisionShape3D.new()
	var col: BoxShape3D = BoxShape3D.new()
	col.size = Vector3(3.5, 0.3, 6)
	shape.shape = col
	shape.position = Vector3(0, 0.15, 0)
	body.add_child(shape)
	dock.add_child(body)


func _build_banner_flags(geom: Node) -> void:
	## Epic-1 T9: hanging banner flags between kiosk pairs
	var banner_pairs: Array = [
		[Vector3(28, 1.6, -4), Vector3(36, 1.6, -4)],
		[Vector3(28, 1.6, 4), Vector3(36, 1.6, 4)],
	]
	for pair in banner_pairs:
		var banner: MeshInstance3D = MeshInstance3D.new()
		var bmesh: BoxMesh = BoxMesh.new()
		var span: float = (pair[1] as Vector3).distance_to(pair[0] as Vector3)
		bmesh.size = Vector3(span, 0.5, 0.05)
		banner.mesh = bmesh
		banner.position = ((pair[0] as Vector3) + (pair[1] as Vector3)) * 0.5
		var bmat: StandardMaterial3D = StandardMaterial3D.new()
		bmat.albedo_color = Color(0.85, 0.30, 0.10, 0.85)
		bmat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		bmat.emission_enabled = true
		bmat.emission = Color(1.0, 0.45, 0.15)
		bmat.emission_energy_multiplier = 0.9
		bmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		banner.material_override = bmat
		geom.add_child(banner)
		# Slow sway animation
		var tween: Tween = create_tween().set_loops()
		tween.tween_property(banner, "rotation:z", 0.05, 2.5).set_ease(Tween.EASE_IN_OUT)
		tween.tween_property(banner, "rotation:z", -0.05, 2.5).set_ease(Tween.EASE_IN_OUT)


func _build_open_decals(geom: Node) -> void:
	## Epic-1 T10: cyan "OPEN" floor decals near each kiosk
	var positions: Array[Vector3] = [
		Vector3(28, 0.02, -2.6), Vector3(36, 0.02, -2.6),
		Vector3(28, 0.02, 2.6), Vector3(36, 0.02, 2.6),
	]
	for pos in positions:
		var decal: Label3D = Label3D.new()
		decal.text = "OPEN"
		decal.position = pos
		decal.rotation_degrees = Vector3(-90, 0, 0)
		decal.modulate = Color(0.30, 0.95, 1.0)
		decal.outline_modulate = Color(0, 0.05, 0.10, 0.95)
		decal.outline_size = 5
		decal.font_size = 22
		decal.no_depth_test = true
		decal.fixed_size = false
		geom.add_child(decal)


func _build_plaza_benches(geom: Node) -> void:
	## Epic-1 T11: 4 cyan park benches in the plaza
	var bench_mat: StandardMaterial3D = StandardMaterial3D.new()
	bench_mat.albedo_color = Color(0.10, 0.18, 0.26)
	bench_mat.emission_enabled = true
	bench_mat.emission = Color(0.20, 0.55, 0.75)
	bench_mat.emission_energy_multiplier = 0.55
	bench_mat.metallic = 0.6
	for pos in [Vector3(28, 0, 1), Vector3(36, 0, 1), Vector3(28, 0, -1.5), Vector3(36, 0, -1.5)]:
		var bench: Node3D = Node3D.new()
		bench.position = pos
		geom.add_child(bench)
		# Seat
		var seat: MeshInstance3D = MeshInstance3D.new()
		var sm: BoxMesh = BoxMesh.new()
		sm.size = Vector3(1.4, 0.08, 0.4)
		seat.mesh = sm
		seat.position = Vector3(0, 0.4, 0)
		seat.material_override = bench_mat
		bench.add_child(seat)
		# Backrest
		var back: MeshInstance3D = MeshInstance3D.new()
		var bm: BoxMesh = BoxMesh.new()
		bm.size = Vector3(1.4, 0.5, 0.06)
		back.mesh = bm
		back.position = Vector3(0, 0.65, -0.17)
		back.material_override = bench_mat
		bench.add_child(back)
		# Legs
		for x: float in [-0.6, 0.6]:
			var leg: MeshInstance3D = MeshInstance3D.new()
			var lm: BoxMesh = BoxMesh.new()
			lm.size = Vector3(0.06, 0.4, 0.34)
			leg.mesh = lm
			leg.position = Vector3(x, 0.2, 0)
			leg.material_override = bench_mat
			bench.add_child(leg)


func _build_plaza_planters(geom: Node) -> void:
	## Epic-1 T12: holographic planters — cyan rim + floating teal leaves
	var planter_positions: Array[Vector3] = [
		Vector3(26, 0, 6), Vector3(38, 0, 6),
		Vector3(26, 0, -6), Vector3(38, 0, -6),
	]
	for pos in planter_positions:
		var planter: Node3D = Node3D.new()
		planter.position = pos
		geom.add_child(planter)
		# Cyan rim cylinder
		var rim: MeshInstance3D = MeshInstance3D.new()
		var rmesh: CylinderMesh = CylinderMesh.new()
		rmesh.top_radius = 0.55
		rmesh.bottom_radius = 0.65
		rmesh.height = 0.5
		rim.mesh = rmesh
		rim.position = Vector3(0, 0.25, 0)
		var rmat: StandardMaterial3D = StandardMaterial3D.new()
		rmat.albedo_color = Color(0.10, 0.30, 0.40)
		rmat.emission_enabled = true
		rmat.emission = Color(0.20, 0.70, 0.95)
		rmat.emission_energy_multiplier = 0.7
		rim.material_override = rmat
		planter.add_child(rim)
		# Floating teal leaves (3 small spheres)
		for i: int in 3:
			var leaf: MeshInstance3D = MeshInstance3D.new()
			var lmesh: SphereMesh = SphereMesh.new()
			lmesh.radius = 0.18 - i * 0.02
			lmesh.height = lmesh.radius * 2.0
			leaf.mesh = lmesh
			var lpos := Vector3(randf_range(-0.3, 0.3), 0.7 + i * 0.25, randf_range(-0.3, 0.3))
			leaf.position = lpos
			var lmat: StandardMaterial3D = StandardMaterial3D.new()
			lmat.albedo_color = Color(0.20, 0.65, 0.55)
			lmat.emission_enabled = true
			lmat.emission = Color(0.25, 0.85, 0.70)
			lmat.emission_energy_multiplier = 1.2
			leaf.material_override = lmat
			planter.add_child(leaf)
			# Floating tween
			var tween: Tween = create_tween().set_loops()
			tween.tween_property(leaf, "position:y", lpos.y + 0.15, 2.0 + i * 0.3).set_ease(Tween.EASE_IN_OUT)
			tween.tween_property(leaf, "position:y", lpos.y, 2.0 + i * 0.3).set_ease(Tween.EASE_IN_OUT)


func _build_vending_machines(geom: Node) -> void:
	## Epic-1 T13: 3 vending machines along the south edge of the plaza
	for i: int in 3:
		var vm: Node3D = Node3D.new()
		vm.position = Vector3(31 + i * 1.4, 0, 11)
		geom.add_child(vm)
		# Body
		var body: MeshInstance3D = MeshInstance3D.new()
		var bm: BoxMesh = BoxMesh.new()
		bm.size = Vector3(1.0, 1.8, 0.6)
		body.mesh = bm
		body.position = Vector3(0, 0.9, 0)
		var body_mat: StandardMaterial3D = StandardMaterial3D.new()
		var hue: Color = [Color(0.85, 0.20, 0.30), Color(0.20, 0.50, 0.85), Color(0.85, 0.65, 0.20)][i]
		body_mat.albedo_color = hue * 0.6
		body_mat.emission_enabled = true
		body_mat.emission = hue
		body_mat.emission_energy_multiplier = 0.55
		body_mat.metallic = 0.4
		body.material_override = body_mat
		vm.add_child(body)
		# Display screen
		var screen: MeshInstance3D = MeshInstance3D.new()
		var sm: BoxMesh = BoxMesh.new()
		sm.size = Vector3(0.85, 0.5, 0.05)
		screen.mesh = sm
		screen.position = Vector3(0, 1.4, -0.32)
		var smat: StandardMaterial3D = StandardMaterial3D.new()
		smat.albedo_color = Color(0.05, 0.10, 0.20)
		smat.emission_enabled = true
		smat.emission = Color(0.30, 0.85, 1.0)
		smat.emission_energy_multiplier = 1.6
		smat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		screen.material_override = smat
		vm.add_child(screen)
		# Collision
		var sb: StaticBody3D = StaticBody3D.new()
		var col_shape: CollisionShape3D = CollisionShape3D.new()
		var col_box: BoxShape3D = BoxShape3D.new()
		col_box.size = Vector3(1.0, 1.8, 0.6)
		col_shape.shape = col_box
		col_shape.position = Vector3(0, 0.9, 0)
		sb.add_child(col_shape)
		vm.add_child(sb)


func _build_security_drones(geom: Node) -> void:
	## Epic-1 T14: 2 small patrolling drones above the plaza
	var drone_paths: Array = [
		[Vector3(28, 3.5, -8), Vector3(36, 3.5, 8), Vector3(28, 3.5, 8), Vector3(36, 3.5, -8)],
		[Vector3(36, 3.0, -2), Vector3(28, 3.0, 2), Vector3(36, 3.0, 6), Vector3(28, 3.0, -6)],
	]
	for path in drone_paths:
		var drone: Node3D = Node3D.new()
		drone.position = (path[0] as Vector3)
		geom.add_child(drone)
		# Body — small disc
		var body: MeshInstance3D = MeshInstance3D.new()
		var bmesh: CylinderMesh = CylinderMesh.new()
		bmesh.top_radius = 0.18
		bmesh.bottom_radius = 0.18
		bmesh.height = 0.08
		body.mesh = bmesh
		var bmat: StandardMaterial3D = StandardMaterial3D.new()
		bmat.albedo_color = Color(0.10, 0.18, 0.26)
		bmat.emission_enabled = true
		bmat.emission = Color(0.20, 0.65, 0.85)
		bmat.emission_energy_multiplier = 1.0
		bmat.metallic = 0.7
		body.material_override = bmat
		drone.add_child(body)
		# Glowing scan eye
		var eye: MeshInstance3D = MeshInstance3D.new()
		var emesh: SphereMesh = SphereMesh.new()
		emesh.radius = 0.06
		emesh.height = 0.12
		eye.mesh = emesh
		eye.position = Vector3(0, -0.05, 0)
		var emat: StandardMaterial3D = StandardMaterial3D.new()
		emat.albedo_color = Color(1.0, 0.30, 0.30)
		emat.emission_enabled = true
		emat.emission = Color(1.0, 0.20, 0.20)
		emat.emission_energy_multiplier = 3.0
		emat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		eye.material_override = emat
		drone.add_child(eye)
		# Loop tween through the path waypoints
		var tween: Tween = create_tween().set_loops()
		for waypoint in path:
			tween.tween_property(drone, "position", waypoint, 4.0).set_ease(Tween.EASE_IN_OUT)


func _build_tournament_leaderboard(geom: Node) -> void:
	## Epic-1 T41: tall leaderboard panel next to the tournament pit
	var lb: Node3D = Node3D.new()
	lb.name = "EastPlazaLeaderboard"
	lb.position = Vector3(44, 0, 14)
	geom.add_child(lb)
	# Backboard
	var back: MeshInstance3D = MeshInstance3D.new()
	var bmesh: BoxMesh = BoxMesh.new()
	bmesh.size = Vector3(0.10, 3.0, 2.0)
	back.mesh = bmesh
	back.position = Vector3(0, 1.7, 0)
	var bmat: StandardMaterial3D = StandardMaterial3D.new()
	bmat.albedo_color = Color(0.18, 0.10, 0.04)
	bmat.emission_enabled = true
	bmat.emission = Color(0.85, 0.30, 0.10)
	bmat.emission_energy_multiplier = 0.55
	bmat.metallic = 0.4
	back.material_override = bmat
	lb.add_child(back)
	# Header label
	var header: Label3D = Label3D.new()
	header.text = "TOP RUNNERS"
	header.position = Vector3(0.07, 2.9, 0)
	header.rotation_degrees = Vector3(0, 90, 0)
	header.modulate = Color(1.0, 0.55, 0.20)
	header.outline_modulate = Color(0, 0, 0, 0.95)
	header.outline_size = 7
	header.font_size = 22
	header.no_depth_test = true
	lb.add_child(header)
	# 5 mock entries
	var entries: Array[String] = [
		"1. Cipher    99",
		"2. Globbler  87",
		"3. Forge     74",
		"4. Pixel     61",
		"5. Index     53",
	]
	for i in entries.size():
		var line: Label3D = Label3D.new()
		line.text = entries[i]
		line.position = Vector3(0.07, 2.4 - i * 0.4, 0)
		line.rotation_degrees = Vector3(0, 90, 0)
		line.modulate = Color(1.0, 0.95, 0.85)
		line.outline_modulate = Color(0, 0.05, 0.10, 0.95)
		line.outline_size = 5
		line.font_size = 18
		line.no_depth_test = true
		lb.add_child(line)
	# Collision
	var sb: StaticBody3D = StaticBody3D.new()
	var col_shape: CollisionShape3D = CollisionShape3D.new()
	var col_box: BoxShape3D = BoxShape3D.new()
	col_box.size = Vector3(0.4, 3.0, 2.0)
	col_shape.shape = col_box
	col_shape.position = Vector3(0, 1.7, 0)
	sb.add_child(col_shape)
	lb.add_child(sb)


func _build_tournament_gate(geom: Node) -> void:
	## Epic-1 T42: portcullis-style gate above the tournament pit entrance
	var gate: Node3D = Node3D.new()
	gate.name = "EastPlazaTournamentGate"
	gate.position = Vector3(36, 0, 14)
	geom.add_child(gate)
	# 2 vertical pillars
	var pillar_mat: StandardMaterial3D = StandardMaterial3D.new()
	pillar_mat.albedo_color = Color(0.12, 0.18, 0.26)
	pillar_mat.emission_enabled = true
	pillar_mat.emission = Color(1.0, 0.30, 0.20)
	pillar_mat.emission_energy_multiplier = 0.7
	pillar_mat.metallic = 0.7
	for z_offset: float in [-2.5, 2.5]:
		var pillar: MeshInstance3D = MeshInstance3D.new()
		var pmesh: BoxMesh = BoxMesh.new()
		pmesh.size = Vector3(0.4, 3.5, 0.4)
		pillar.mesh = pmesh
		pillar.position = Vector3(0, 1.75, z_offset)
		pillar.material_override = pillar_mat
		gate.add_child(pillar)
		# Pillar collision
		var sb: StaticBody3D = StaticBody3D.new()
		var col_shape: CollisionShape3D = CollisionShape3D.new()
		var col_box: BoxShape3D = BoxShape3D.new()
		col_box.size = Vector3(0.4, 3.5, 0.4)
		col_shape.shape = col_box
		col_shape.position = Vector3(0, 1.75, z_offset)
		sb.add_child(col_shape)
		gate.add_child(sb)
	# Top crossbar
	var top: MeshInstance3D = MeshInstance3D.new()
	var tmesh: BoxMesh = BoxMesh.new()
	tmesh.size = Vector3(0.4, 0.4, 5.5)
	top.mesh = tmesh
	top.position = Vector3(0, 3.5, 0)
	top.material_override = pillar_mat
	gate.add_child(top)
	# 5 hanging vertical bars (portcullis)
	for i in range(0, 5):
		var bar: MeshInstance3D = MeshInstance3D.new()
		var bmesh: BoxMesh = BoxMesh.new()
		bmesh.size = Vector3(0.10, 1.5, 0.10)
		bar.mesh = bmesh
		bar.position = Vector3(0, 2.5, -2.0 + i * 1.0)
		bar.material_override = pillar_mat
		gate.add_child(bar)


func _build_perimeter_seating(geom: Node) -> void:
	## Epic-1 T43: long perimeter seating wall — 6 long benches around the
	## plaza edges (mostly cosmetic)
	var bench_mat: StandardMaterial3D = StandardMaterial3D.new()
	bench_mat.albedo_color = Color(0.10, 0.18, 0.26)
	bench_mat.emission_enabled = true
	bench_mat.emission = Color(0.20, 0.55, 0.75)
	bench_mat.emission_energy_multiplier = 0.5
	bench_mat.metallic = 0.55
	var bench_positions: Array[Vector3] = [
		Vector3(34, 0, -18), Vector3(34, 0, 18),
		Vector3(22.5, 0, -16), Vector3(22.5, 0, 16),
		Vector3(43.5, 0, -16), Vector3(43.5, 0, 16),
	]
	for pos in bench_positions:
		var bench: MeshInstance3D = MeshInstance3D.new()
		var bmesh: BoxMesh = BoxMesh.new()
		bmesh.size = Vector3(3.0, 0.4, 0.7)
		bench.mesh = bmesh
		bench.position = pos + Vector3(0, 0.2, 0)
		bench.material_override = bench_mat
		geom.add_child(bench)
		# Collision
		var sb: StaticBody3D = StaticBody3D.new()
		var col_shape: CollisionShape3D = CollisionShape3D.new()
		var col_box: BoxShape3D = BoxShape3D.new()
		col_box.size = Vector3(3.0, 0.4, 0.7)
		col_shape.shape = col_box
		col_shape.position = pos + Vector3(0, 0.2, 0)
		sb.add_child(col_shape)
		geom.add_child(sb)


func _build_gate_guards() -> void:
	## Epic-1 T44: 2 gate guard NPCs flanking the west arch entrance
	for entry in [
		[Vector3(20, 0.5, -2.5), "Gate Guard A", Color(0.30, 0.65, 0.95)],
		[Vector3(20, 0.5, 2.5), "Gate Guard B", Color(0.30, 0.65, 0.95)],
	]:
		var pos: Vector3 = entry[0]
		var name: String = entry[1]
		var hue: Color = entry[2]
		var guard: Node3D = Node3D.new()
		guard.name = "EastPlazaGuard_" + name.replace(" ", "")
		guard.position = pos
		add_child(guard)
		var body: MeshInstance3D = MeshInstance3D.new()
		var sphere: SphereMesh = SphereMesh.new()
		sphere.radius = 0.40
		sphere.height = 0.80
		body.mesh = sphere
		var mat: StandardMaterial3D = StandardMaterial3D.new()
		mat.albedo_color = hue
		mat.emission_enabled = true
		mat.emission = hue * 1.4
		mat.emission_energy_multiplier = 0.6
		mat.metallic = 0.5
		body.material_override = mat
		guard.add_child(body)
		# Helmet
		var helm: MeshInstance3D = MeshInstance3D.new()
		var hmesh: SphereMesh = SphereMesh.new()
		hmesh.radius = 0.25
		hmesh.height = 0.50
		helm.mesh = hmesh
		helm.position = Vector3(0, 0.40, 0)
		var hmat: StandardMaterial3D = StandardMaterial3D.new()
		hmat.albedo_color = Color(0.12, 0.20, 0.30)
		hmat.metallic = 0.85
		hmat.roughness = 0.3
		helm.material_override = hmat
		guard.add_child(helm)
		# Visor stripe
		var visor: MeshInstance3D = MeshInstance3D.new()
		var vmesh: BoxMesh = BoxMesh.new()
		vmesh.size = Vector3(0.45, 0.06, 0.04)
		visor.mesh = vmesh
		visor.position = Vector3(0, 0.42, -0.23)
		var vmat: StandardMaterial3D = StandardMaterial3D.new()
		vmat.albedo_color = Color(0.30, 0.85, 1.0)
		vmat.emission_enabled = true
		vmat.emission = Color(0.40, 0.95, 1.0)
		vmat.emission_energy_multiplier = 2.5
		vmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		visor.material_override = vmat
		guard.add_child(visor)
		# Name label
		var label: Label3D = Label3D.new()
		label.text = name
		label.position = Vector3(0, 1.4, 0)
		label.modulate = Color(0.55, 0.85, 1.0)
		label.outline_modulate = Color(0, 0, 0, 0.85)
		label.outline_size = 5
		label.font_size = 18
		label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		guard.add_child(label)


func _build_cipher_orbs(geom: Node) -> void:
	## Epic-1 T45: 6 floating cipher data orbs drifting through the plaza —
	## small bright violet spheres on individual bob+drift tweens
	for i: int in 6:
		var orb: MeshInstance3D = MeshInstance3D.new()
		orb.name = "EastPlazaCipherOrb_%d" % i
		var omesh: SphereMesh = SphereMesh.new()
		omesh.radius = 0.10
		omesh.height = 0.20
		orb.mesh = omesh
		var origin := Vector3(26 + i * 2.5, 1.5 + (i % 2) * 0.8, -8 + (i % 3) * 6)
		orb.position = origin
		var mat: StandardMaterial3D = StandardMaterial3D.new()
		mat.albedo_color = Color(0.85, 0.40, 1.0)
		mat.emission_enabled = true
		mat.emission = Color(0.95, 0.55, 1.0)
		mat.emission_energy_multiplier = 2.5
		mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		orb.material_override = mat
		geom.add_child(orb)
		# Drift tween — slow continuous motion
		var tween: Tween = create_tween().set_loops()
		var drift1 := origin + Vector3(randf_range(-3, 3), randf_range(-0.4, 0.4), randf_range(-3, 3))
		var drift2 := origin + Vector3(randf_range(-3, 3), randf_range(-0.4, 0.4), randf_range(-3, 3))
		tween.tween_property(orb, "position", drift1, randf_range(5, 8)).set_ease(Tween.EASE_IN_OUT)
		tween.tween_property(orb, "position", drift2, randf_range(5, 8)).set_ease(Tween.EASE_IN_OUT)
		tween.tween_property(orb, "position", origin, randf_range(5, 8)).set_ease(Tween.EASE_IN_OUT)


func _build_quest_board(geom: Node) -> void:
	## Epic-1 T36: quest bulletin board at (24, 0, -8) with 3 mock quest entries
	var board: Node3D = Node3D.new()
	board.name = "EastPlazaQuestBoard"
	board.position = Vector3(24, 0, -8)
	geom.add_child(board)
	# Backboard panel
	var back: MeshInstance3D = MeshInstance3D.new()
	var bmesh: BoxMesh = BoxMesh.new()
	bmesh.size = Vector3(1.6, 1.8, 0.10)
	back.mesh = bmesh
	back.position = Vector3(0, 1.4, 0)
	var bmat: StandardMaterial3D = StandardMaterial3D.new()
	bmat.albedo_color = Color(0.18, 0.10, 0.04)
	bmat.emission_enabled = true
	bmat.emission = Color(0.65, 0.40, 0.10)
	bmat.emission_energy_multiplier = 0.5
	bmat.metallic = 0.4
	back.material_override = bmat
	board.add_child(back)
	# 3 mock quest "papers" (small glowing rectangles)
	var quest_titles: Array[String] = [
		"Bug Hunt: 5 Glitches",
		"Cipher's Errand",
		"Collect 10 Data Shards",
	]
	for i in quest_titles.size():
		var paper: MeshInstance3D = MeshInstance3D.new()
		var pmesh: BoxMesh = BoxMesh.new()
		pmesh.size = Vector3(1.3, 0.35, 0.02)
		paper.mesh = pmesh
		paper.position = Vector3(0, 2.0 - i * 0.45, -0.06)
		var pmat: StandardMaterial3D = StandardMaterial3D.new()
		pmat.albedo_color = Color(0.95, 0.85, 0.55)
		pmat.emission_enabled = true
		pmat.emission = Color(1.0, 0.85, 0.45)
		pmat.emission_energy_multiplier = 0.7
		pmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		paper.material_override = pmat
		board.add_child(paper)
		# Title label
		var label: Label3D = Label3D.new()
		label.text = quest_titles[i]
		label.position = Vector3(0, 2.0 - i * 0.45, -0.075)
		label.modulate = Color(0.20, 0.10, 0.02)
		label.outline_modulate = Color(1.0, 0.85, 0.45, 0.4)
		label.outline_size = 3
		label.font_size = 16
		label.no_depth_test = true
		board.add_child(label)
	# Wood post supports
	for x: float in [-0.7, 0.7]:
		var post: MeshInstance3D = MeshInstance3D.new()
		var pmesh: CylinderMesh = CylinderMesh.new()
		pmesh.top_radius = 0.06
		pmesh.bottom_radius = 0.08
		pmesh.height = 2.6
		post.mesh = pmesh
		post.position = Vector3(x, 1.3, 0.05)
		var pmat: StandardMaterial3D = StandardMaterial3D.new()
		pmat.albedo_color = Color(0.18, 0.10, 0.04)
		pmat.emission_enabled = true
		pmat.emission = Color(0.65, 0.40, 0.10)
		pmat.emission_energy_multiplier = 0.4
		post.material_override = pmat
		board.add_child(post)
	# Collision
	var sb: StaticBody3D = StaticBody3D.new()
	var col_shape: CollisionShape3D = CollisionShape3D.new()
	var col_box: BoxShape3D = BoxShape3D.new()
	col_box.size = Vector3(1.7, 2.6, 0.3)
	col_shape.shape = col_box
	col_shape.position = Vector3(0, 1.3, 0)
	sb.add_child(col_shape)
	board.add_child(sb)


func _build_data_bins(geom: Node) -> void:
	## Epic-1 T37: 4 data recycling bins at plaza corners
	for entry in [
		[Vector3(24, 0, 12), Color(0.30, 0.85, 0.50)],   # green RECYCLE
		[Vector3(40, 0, 12), Color(1.0, 0.55, 0.20)],    # orange WASTE
		[Vector3(24, 0, -12), Color(0.85, 0.30, 0.55)],  # pink BUGS
		[Vector3(40, 0, -12), Color(0.30, 0.65, 0.95)],  # blue DATA
	]:
		var pos: Vector3 = entry[0]
		var hue: Color = entry[1]
		var bin: Node3D = Node3D.new()
		bin.position = pos
		geom.add_child(bin)
		# Bin body
		var body: MeshInstance3D = MeshInstance3D.new()
		var bmesh: CylinderMesh = CylinderMesh.new()
		bmesh.top_radius = 0.32
		bmesh.bottom_radius = 0.28
		bmesh.height = 0.8
		body.mesh = bmesh
		body.position = Vector3(0, 0.4, 0)
		var bmat: StandardMaterial3D = StandardMaterial3D.new()
		bmat.albedo_color = Color(0.10, 0.18, 0.26)
		bmat.emission_enabled = true
		bmat.emission = hue
		bmat.emission_energy_multiplier = 0.6
		bmat.metallic = 0.55
		body.material_override = bmat
		bin.add_child(body)
		# Lid
		var lid: MeshInstance3D = MeshInstance3D.new()
		var lmesh: CylinderMesh = CylinderMesh.new()
		lmesh.top_radius = 0.34
		lmesh.bottom_radius = 0.34
		lmesh.height = 0.06
		lid.mesh = lmesh
		lid.position = Vector3(0, 0.83, 0)
		var lmat: StandardMaterial3D = StandardMaterial3D.new()
		lmat.albedo_color = hue * 0.6
		lmat.emission_enabled = true
		lmat.emission = hue
		lmat.emission_energy_multiplier = 1.2
		lid.material_override = lmat
		bin.add_child(lid)
		# Collision
		var sb: StaticBody3D = StaticBody3D.new()
		var col_shape: CollisionShape3D = CollisionShape3D.new()
		var col_capsule: CapsuleShape3D = CapsuleShape3D.new()
		col_capsule.radius = 0.34
		col_capsule.height = 0.86
		col_shape.shape = col_capsule
		col_shape.position = Vector3(0, 0.43, 0)
		sb.add_child(col_shape)
		bin.add_child(sb)


func _build_animated_lamps(geom: Node) -> void:
	## Epic-1 T38: 4 animated street lamps with sequential on/off cycle
	## arranged along the plaza north edge
	for i: int in 4:
		var lamp_root: Node3D = Node3D.new()
		lamp_root.position = Vector3(26 + i * 4, 0, -10)
		geom.add_child(lamp_root)
		# Tall post
		var post: MeshInstance3D = MeshInstance3D.new()
		var pmesh: CylinderMesh = CylinderMesh.new()
		pmesh.top_radius = 0.06
		pmesh.bottom_radius = 0.10
		pmesh.height = 3.0
		post.mesh = pmesh
		post.position = Vector3(0, 1.5, 0)
		var pmat: StandardMaterial3D = StandardMaterial3D.new()
		pmat.albedo_color = Color(0.10, 0.18, 0.26)
		pmat.emission_enabled = true
		pmat.emission = Color(0.20, 0.55, 0.75)
		pmat.emission_energy_multiplier = 0.5
		pmat.metallic = 0.7
		post.material_override = pmat
		lamp_root.add_child(post)
		# Lamp head sphere
		var head: MeshInstance3D = MeshInstance3D.new()
		var hmesh: SphereMesh = SphereMesh.new()
		hmesh.radius = 0.22
		hmesh.height = 0.44
		head.mesh = hmesh
		head.position = Vector3(0, 3.1, 0)
		var hmat: StandardMaterial3D = StandardMaterial3D.new()
		hmat.albedo_color = Color(1.0, 0.85, 0.40)
		hmat.emission_enabled = true
		hmat.emission = Color(1.0, 0.80, 0.30)
		hmat.emission_energy_multiplier = 2.5
		hmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		head.material_override = hmat
		lamp_root.add_child(head)
		# Sequential pulse — each lamp dims in turn
		var tween: Tween = create_tween().set_loops()
		tween.tween_interval(i * 0.4)
		tween.tween_property(hmat, "emission_energy_multiplier", 0.5, 0.5).set_ease(Tween.EASE_OUT)
		tween.tween_property(hmat, "emission_energy_multiplier", 2.5, 0.5).set_ease(Tween.EASE_IN)
		tween.tween_interval((4 - i) * 0.4)


func _build_dock_ramp(geom: Node) -> void:
	## Epic-1 T39: angled ramp slab connecting the loading dock platform
	## to the plaza floor
	var ramp: MeshInstance3D = MeshInstance3D.new()
	ramp.name = "EastPlazaDockRamp"
	var rmesh: BoxMesh = BoxMesh.new()
	rmesh.size = Vector3(1.8, 0.1, 2.0)
	ramp.mesh = rmesh
	ramp.position = Vector3(40, 0.15, 3)
	ramp.rotation_degrees = Vector3(8, 0, 0)
	var rmat: StandardMaterial3D = StandardMaterial3D.new()
	rmat.albedo_color = Color(0.12, 0.18, 0.26)
	rmat.emission_enabled = true
	rmat.emission = Color(0.20, 0.55, 0.75)
	rmat.emission_energy_multiplier = 0.45
	rmat.metallic = 0.6
	ramp.material_override = rmat
	geom.add_child(ramp)


func _build_zone_numbers(geom: Node) -> void:
	## Epic-1 T40: floating zone-number labels above each sub-zone
	var zone_data: Array = [
		[Vector3(32, 4.8, -1), "1 — MARKET"],
		[Vector3(40, 4.8, -14), "2 — SPAR"],
		[Vector3(40, 4.8, 14), "3 — ARENA"],
		[Vector3(42, 4.8, 0), "4 — DOCK"],
		[Vector3(29, 4.8, -8), "5 — VENDORS"],
	]
	for entry in zone_data:
		var label: Label3D = Label3D.new()
		label.text = entry[1]
		label.position = entry[0]
		label.modulate = Color(1.0, 0.65, 0.20)
		label.outline_modulate = Color(0, 0.05, 0.10, 0.95)
		label.outline_size = 7
		label.font_size = 24
		label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		label.no_depth_test = true
		geom.add_child(label)


func _build_weapon_rack(geom: Node) -> void:
	## Epic-1 T31: vertical weapon rack at (44, 0, -14) with 4 displayed weapons
	var rack: Node3D = Node3D.new()
	rack.name = "EastPlazaWeaponRack"
	rack.position = Vector3(44, 0, -14)
	geom.add_child(rack)
	# Rack frame (vertical post)
	var post_mat: StandardMaterial3D = StandardMaterial3D.new()
	post_mat.albedo_color = Color(0.10, 0.18, 0.26)
	post_mat.emission_enabled = true
	post_mat.emission = Color(0.20, 0.55, 0.75)
	post_mat.emission_energy_multiplier = 0.5
	post_mat.metallic = 0.7
	var frame: MeshInstance3D = MeshInstance3D.new()
	var fmesh: BoxMesh = BoxMesh.new()
	fmesh.size = Vector3(0.15, 2.4, 1.6)
	frame.mesh = fmesh
	frame.position = Vector3(0, 1.2, 0)
	frame.material_override = post_mat
	rack.add_child(frame)
	# 4 weapons, evenly spaced along the rack height
	var weapons: Array = [
		# [shape_size, color, name]
		[Vector3(0.06, 1.2, 0.10), Color(0.45, 0.95, 1.0), "BLADE"],   # sword
		[Vector3(0.10, 0.4, 0.10), Color(1.0, 0.55, 0.20), "BOLT"],     # pistol-like
		[Vector3(0.05, 1.0, 0.05), Color(0.85, 0.30, 1.0), "STAFF"],    # staff
		[Vector3(0.30, 0.30, 0.05), Color(0.30, 0.85, 0.50), "BUCKLER"],# small shield
	]
	for i in weapons.size():
		var entry = weapons[i]
		var size: Vector3 = entry[0]
		var hue: Color = entry[1]
		var weapon_name: String = entry[2]
		var w: MeshInstance3D = MeshInstance3D.new()
		var wmesh: BoxMesh = BoxMesh.new()
		wmesh.size = size
		w.mesh = wmesh
		w.position = Vector3(0.15, 0.5 + i * 0.55, 0)
		var wmat: StandardMaterial3D = StandardMaterial3D.new()
		wmat.albedo_color = hue
		wmat.emission_enabled = true
		wmat.emission = hue
		wmat.emission_energy_multiplier = 1.4
		wmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		w.material_override = wmat
		rack.add_child(w)
		# Tiny name label next to each weapon
		var label: Label3D = Label3D.new()
		label.text = weapon_name
		label.position = Vector3(0.45, 0.5 + i * 0.55, 0)
		label.modulate = hue
		label.outline_modulate = Color(0, 0, 0, 0.85)
		label.outline_size = 4
		label.font_size = 14
		label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		rack.add_child(label)
	# Collision
	var sb: StaticBody3D = StaticBody3D.new()
	var col_shape: CollisionShape3D = CollisionShape3D.new()
	var col_box: BoxShape3D = BoxShape3D.new()
	col_box.size = Vector3(0.6, 2.4, 1.6)
	col_shape.shape = col_box
	col_shape.position = Vector3(0, 1.2, 0)
	sb.add_child(col_shape)
	rack.add_child(sb)


func _build_combat_mannequin(geom: Node) -> void:
	## Epic-1 T32: armored humanoid mannequin (display, not interactive)
	## next to the weapon rack
	var mq: Node3D = Node3D.new()
	mq.name = "EastPlazaCombatMannequin"
	mq.position = Vector3(44, 0, -16)
	geom.add_child(mq)
	# Body — taller than dummies, armored look
	var body: MeshInstance3D = MeshInstance3D.new()
	var bmesh: CapsuleMesh = CapsuleMesh.new()
	bmesh.radius = 0.32
	bmesh.height = 1.8
	body.mesh = bmesh
	body.position = Vector3(0, 1.0, 0)
	var bmat: StandardMaterial3D = StandardMaterial3D.new()
	bmat.albedo_color = Color(0.20, 0.30, 0.40)
	bmat.emission_enabled = true
	bmat.emission = Color(0.30, 0.65, 0.85)
	bmat.emission_energy_multiplier = 0.4
	bmat.metallic = 0.85
	bmat.roughness = 0.3
	body.material_override = bmat
	mq.add_child(body)
	# Helmet (sphere on top)
	var helm: MeshInstance3D = MeshInstance3D.new()
	var hmesh: SphereMesh = SphereMesh.new()
	hmesh.radius = 0.32
	hmesh.height = 0.64
	helm.mesh = hmesh
	helm.position = Vector3(0, 1.95, 0)
	helm.material_override = bmat
	mq.add_child(helm)
	# Glowing visor stripe
	var visor: MeshInstance3D = MeshInstance3D.new()
	var vmesh: BoxMesh = BoxMesh.new()
	vmesh.size = Vector3(0.55, 0.10, 0.05)
	visor.mesh = vmesh
	visor.position = Vector3(0, 1.95, -0.30)
	var vmat: StandardMaterial3D = StandardMaterial3D.new()
	vmat.albedo_color = Color(1.0, 0.30, 0.30)
	vmat.emission_enabled = true
	vmat.emission = Color(1.0, 0.20, 0.20)
	vmat.emission_energy_multiplier = 2.5
	vmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	visor.material_override = vmat
	mq.add_child(visor)
	# Collision
	var sb: StaticBody3D = StaticBody3D.new()
	var col_shape: CollisionShape3D = CollisionShape3D.new()
	var col_capsule: CapsuleShape3D = CapsuleShape3D.new()
	col_capsule.radius = 0.32
	col_capsule.height = 1.8
	col_shape.shape = col_capsule
	col_shape.position = Vector3(0, 1.0, 0)
	sb.add_child(col_shape)
	mq.add_child(sb)


func _build_training_mat(geom: Node) -> void:
	## Epic-1 T33: padded training mat at (37, 0.02, -14) — flat soft area
	## next to the spar zone where the player can warm up
	var mat: MeshInstance3D = MeshInstance3D.new()
	mat.name = "EastPlazaTrainingMat"
	var mmesh: BoxMesh = BoxMesh.new()
	mmesh.size = Vector3(2.0, 0.04, 2.0)
	mat.mesh = mmesh
	mat.position = Vector3(37, 0.02, -10)
	var mmat: StandardMaterial3D = StandardMaterial3D.new()
	mmat.albedo_color = Color(0.20, 0.55, 0.65)
	mmat.emission_enabled = true
	mmat.emission = Color(0.30, 0.75, 0.90)
	mmat.emission_energy_multiplier = 0.6
	mmat.roughness = 0.85
	mat.material_override = mmat
	geom.add_child(mat)


func _build_score_board(geom: Node) -> void:
	## Epic-1 T34: large scoreboard with mock HP/XP display panels
	var board: Node3D = Node3D.new()
	board.name = "EastPlazaScoreBoard"
	board.position = Vector3(44, 0, -10)
	geom.add_child(board)
	# Backboard
	var back: MeshInstance3D = MeshInstance3D.new()
	var bmesh: BoxMesh = BoxMesh.new()
	bmesh.size = Vector3(0.10, 2.0, 3.0)
	back.mesh = bmesh
	back.position = Vector3(0, 1.5, 0)
	var bmat: StandardMaterial3D = StandardMaterial3D.new()
	bmat.albedo_color = Color(0.05, 0.10, 0.20)
	bmat.emission_enabled = true
	bmat.emission = Color(0.10, 0.30, 0.55)
	bmat.emission_energy_multiplier = 0.5
	bmat.metallic = 0.6
	back.material_override = bmat
	board.add_child(back)
	# Glowing display screen
	var screen: MeshInstance3D = MeshInstance3D.new()
	var smesh: BoxMesh = BoxMesh.new()
	smesh.size = Vector3(0.05, 1.6, 2.6)
	screen.mesh = smesh
	screen.position = Vector3(0.08, 1.5, 0)
	var smat: StandardMaterial3D = StandardMaterial3D.new()
	smat.albedo_color = Color(0.10, 0.30, 0.55)
	smat.emission_enabled = true
	smat.emission = Color(0.30, 0.85, 1.0)
	smat.emission_energy_multiplier = 1.4
	smat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	screen.material_override = smat
	board.add_child(screen)
	# Mock score text labels (3 lines)
	var lines: Array[String] = [
		"PLAYER",
		"HP  100/100",
		"XP    0/100",
	]
	for i in lines.size():
		var line: Label3D = Label3D.new()
		line.text = lines[i]
		line.position = Vector3(0.12, 2.1 - i * 0.4, 0)
		line.rotation_degrees = Vector3(0, 90, 0)
		line.modulate = Color(0.40, 0.95, 1.0) if i == 0 else Color(1, 1, 1)
		line.outline_modulate = Color(0, 0, 0, 0.95)
		line.outline_size = 6
		line.font_size = 22 if i == 0 else 18
		line.no_depth_test = true
		board.add_child(line)


func _build_chalk_lines(geom: Node) -> void:
	## Epic-1 T35: cyan chalk technique lines painted on the spar zone floor —
	## footwork markers (4 lines + 1 center cross)
	var chalk_mat: StandardMaterial3D = StandardMaterial3D.new()
	chalk_mat.albedo_color = Color(0.40, 0.95, 1.0, 0.85)
	chalk_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	chalk_mat.emission_enabled = true
	chalk_mat.emission = Color(0.50, 0.95, 1.0)
	chalk_mat.emission_energy_multiplier = 1.4
	chalk_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	# Center cross (2 perpendicular lines)
	for entry in [
		[Vector3(40, 0.13, -14), Vector3(2.0, 0.02, 0.05)],
		[Vector3(40, 0.13, -14), Vector3(0.05, 0.02, 2.0)],
	]:
		var line: MeshInstance3D = MeshInstance3D.new()
		var lmesh: BoxMesh = BoxMesh.new()
		lmesh.size = entry[1]
		line.mesh = lmesh
		line.position = entry[0]
		line.material_override = chalk_mat
		geom.add_child(line)
	# 4 corner quadrant markers (small Xs)
	for offset in [Vector3(-1.5, 0, -1.5), Vector3(1.5, 0, -1.5), Vector3(-1.5, 0, 1.5), Vector3(1.5, 0, 1.5)]:
		for rot in [0.0, PI/2.0]:
			var line: MeshInstance3D = MeshInstance3D.new()
			var lmesh: BoxMesh = BoxMesh.new()
			lmesh.size = Vector3(0.5, 0.02, 0.05)
			line.mesh = lmesh
			line.position = Vector3(40, 0.13, -14) + offset
			line.rotation.y = rot + PI/4.0
			line.material_override = chalk_mat
			geom.add_child(line)


func _build_sparring_arena(geom: Node) -> void:
	## Epic-1 T26: square sparring arena at (40, 0, -14) — raised platform with
	## red boundary stripes
	var arena: Node3D = Node3D.new()
	arena.name = "EastPlazaSparringArena"
	arena.position = Vector3(40, 0, -14)
	geom.add_child(arena)
	# Floor pad
	var pad: MeshInstance3D = MeshInstance3D.new()
	var pmesh: BoxMesh = BoxMesh.new()
	pmesh.size = Vector3(6, 0.1, 6)
	pad.mesh = pmesh
	pad.position = Vector3(0, 0.05, 0)
	var pmat: StandardMaterial3D = StandardMaterial3D.new()
	pmat.albedo_color = Color(0.10, 0.18, 0.26)
	pmat.emission_enabled = true
	pmat.emission = Color(0.30, 0.85, 1.0)
	pmat.emission_energy_multiplier = 0.6
	pmat.metallic = 0.5
	pad.material_override = pmat
	arena.add_child(pad)
	# Red boundary stripes (4 sides)
	for entry in [
		[Vector3(-3, 0.11, 0), Vector3(0.15, 0.02, 6)],
		[Vector3(3, 0.11, 0), Vector3(0.15, 0.02, 6)],
		[Vector3(0, 0.11, -3), Vector3(6, 0.02, 0.15)],
		[Vector3(0, 0.11, 3), Vector3(6, 0.02, 0.15)],
	]:
		var stripe: MeshInstance3D = MeshInstance3D.new()
		var smesh: BoxMesh = BoxMesh.new()
		smesh.size = entry[1]
		stripe.mesh = smesh
		stripe.position = entry[0]
		var smat: StandardMaterial3D = StandardMaterial3D.new()
		smat.albedo_color = Color(1.0, 0.18, 0.18)
		smat.emission_enabled = true
		smat.emission = Color(1.0, 0.20, 0.15)
		smat.emission_energy_multiplier = 1.6
		smat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		stripe.material_override = smat
		arena.add_child(stripe)
	# Floor label
	var label: Label3D = Label3D.new()
	label.text = "SPAR ZONE"
	label.position = Vector3(0, 0.13, 0)
	label.rotation_degrees = Vector3(-90, 0, 0)
	label.modulate = Color(1.0, 0.30, 0.30)
	label.outline_modulate = Color(0, 0, 0, 0.95)
	label.outline_size = 6
	label.font_size = 28
	label.no_depth_test = true
	arena.add_child(label)


func _build_practice_dummies(geom: Node) -> void:
	## Epic-1 T27: 2 humanoid practice dummies inside the sparring arena
	for i: int in 2:
		var dummy: Node3D = Node3D.new()
		dummy.name = "EastPlazaSparDummy_%d" % i
		dummy.position = Vector3(40 + (i * 2 - 1) * 1.5, 0, -14)
		geom.add_child(dummy)
		# Body — tall capsule
		var body: MeshInstance3D = MeshInstance3D.new()
		var bmesh: CapsuleMesh = CapsuleMesh.new()
		bmesh.radius = 0.30
		bmesh.height = 1.5
		body.mesh = bmesh
		body.position = Vector3(0, 0.85, 0)
		var bmat: StandardMaterial3D = StandardMaterial3D.new()
		bmat.albedo_color = Color(0.45, 0.30, 0.20)
		bmat.emission_enabled = true
		bmat.emission = Color(0.65, 0.40, 0.20)
		bmat.emission_energy_multiplier = 0.4
		bmat.roughness = 0.7
		body.material_override = bmat
		dummy.add_child(body)
		# Target ring around the chest
		var ring: MeshInstance3D = MeshInstance3D.new()
		var rmesh: TorusMesh = TorusMesh.new()
		rmesh.inner_radius = 0.32
		rmesh.outer_radius = 0.40
		rmesh.rings = 12
		rmesh.ring_segments = 16
		ring.mesh = rmesh
		ring.position = Vector3(0, 0.95, 0)
		ring.rotation_degrees = Vector3(90, 0, 0)
		var rmat: StandardMaterial3D = StandardMaterial3D.new()
		rmat.albedo_color = Color(1.0, 0.95, 0.30)
		rmat.emission_enabled = true
		rmat.emission = Color(1.0, 0.90, 0.20)
		rmat.emission_energy_multiplier = 1.6
		rmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		ring.material_override = rmat
		dummy.add_child(ring)
		# Floating hp label (placeholder)
		var label: Label3D = Label3D.new()
		label.text = "HP 100/100"
		label.position = Vector3(0, 2.0, 0)
		label.modulate = Color(1.0, 0.95, 0.85)
		label.outline_modulate = Color(0, 0, 0, 0.85)
		label.outline_size = 5
		label.font_size = 16
		label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		dummy.add_child(label)
		# Collision (the dummy can be hit)
		var sb: StaticBody3D = StaticBody3D.new()
		var col_shape: CollisionShape3D = CollisionShape3D.new()
		var col_capsule: CapsuleShape3D = CapsuleShape3D.new()
		col_capsule.radius = 0.30
		col_capsule.height = 1.5
		col_shape.shape = col_capsule
		col_shape.position = Vector3(0, 0.85, 0)
		sb.add_child(col_shape)
		dummy.add_child(sb)


func _build_tournament_pit(geom: Node) -> void:
	## Epic-1 T28: sunken tournament pit at (40, -0.5, 14) — circular fighting
	## ring lower than the surrounding plaza
	var pit: Node3D = Node3D.new()
	pit.name = "EastPlazaTournamentPit"
	pit.position = Vector3(40, 0, 14)
	geom.add_child(pit)
	# Sunken floor
	var floor_disc: MeshInstance3D = MeshInstance3D.new()
	var fmesh: CylinderMesh = CylinderMesh.new()
	fmesh.top_radius = 4.0
	fmesh.bottom_radius = 4.0
	fmesh.height = 0.2
	fmesh.radial_segments = 24
	floor_disc.mesh = fmesh
	floor_disc.position = Vector3(0, -0.4, 0)
	var fmat: StandardMaterial3D = StandardMaterial3D.new()
	fmat.albedo_color = Color(0.18, 0.10, 0.04)
	fmat.emission_enabled = true
	fmat.emission = Color(0.85, 0.30, 0.10)
	fmat.emission_energy_multiplier = 0.65
	fmat.metallic = 0.4
	fmat.roughness = 0.6
	floor_disc.material_override = fmat
	pit.add_child(floor_disc)
	# Outer ring wall (low rim)
	var wall: MeshInstance3D = MeshInstance3D.new()
	var wmesh: CylinderMesh = CylinderMesh.new()
	wmesh.top_radius = 4.2
	wmesh.bottom_radius = 4.2
	wmesh.height = 0.6
	wmesh.radial_segments = 24
	wall.mesh = wmesh
	wall.position = Vector3(0, 0.0, 0)
	var wmat: StandardMaterial3D = StandardMaterial3D.new()
	wmat.albedo_color = Color(0.12, 0.18, 0.26)
	wmat.emission_enabled = true
	wmat.emission = Color(1.0, 0.30, 0.20)
	wmat.emission_energy_multiplier = 0.8
	wmat.metallic = 0.7
	wall.material_override = wmat
	pit.add_child(wall)
	# Floor label
	var label: Label3D = Label3D.new()
	label.text = "ARENA"
	label.position = Vector3(0, -0.28, 0)
	label.rotation_degrees = Vector3(-90, 0, 0)
	label.modulate = Color(1.0, 0.50, 0.20)
	label.outline_modulate = Color(0, 0, 0, 0.95)
	label.outline_size = 7
	label.font_size = 36
	label.no_depth_test = true
	pit.add_child(label)


func _build_crowd_seating(geom: Node) -> void:
	## Epic-1 T29: ring of small spectator seats around the tournament pit
	## (4 seat blocks at NE/NW/SE/SW)
	for i: int in 8:
		var angle: float = i * TAU / 8.0
		var radius: float = 5.5
		var seat_pos := Vector3(40 + cos(angle) * radius, 0.3, 14 + sin(angle) * radius)
		var seat: MeshInstance3D = MeshInstance3D.new()
		var smesh: BoxMesh = BoxMesh.new()
		smesh.size = Vector3(1.4, 0.6, 1.0)
		seat.mesh = smesh
		seat.position = seat_pos
		var smat: StandardMaterial3D = StandardMaterial3D.new()
		smat.albedo_color = Color(0.12, 0.18, 0.26)
		smat.emission_enabled = true
		smat.emission = Color(0.20, 0.55, 0.75)
		smat.emission_energy_multiplier = 0.5
		smat.metallic = 0.5
		seat.material_override = smat
		geom.add_child(seat)
		# Spectator orb (sitting on each seat)
		var spec: MeshInstance3D = MeshInstance3D.new()
		var orb_mesh: SphereMesh = SphereMesh.new()
		orb_mesh.radius = 0.22
		orb_mesh.height = 0.44
		spec.mesh = orb_mesh
		spec.position = seat_pos + Vector3(0, 0.55, 0)
		var hue: Color = [
			Color(0.85, 0.55, 0.30),  # orange
			Color(0.55, 0.35, 0.85),  # violet
			Color(0.30, 0.85, 0.50),  # green
			Color(0.85, 0.30, 0.45),  # coral
			Color(0.30, 0.65, 0.90),  # blue
			Color(1.0, 0.85, 0.30),   # yellow
			Color(0.50, 0.90, 0.85),  # teal
			Color(0.95, 0.45, 0.85),  # magenta
		][i]
		var omat: StandardMaterial3D = StandardMaterial3D.new()
		omat.albedo_color = hue
		omat.emission_enabled = true
		omat.emission = hue * 1.3
		omat.emission_energy_multiplier = 0.6
		spec.material_override = omat
		geom.add_child(spec)
		# Subtle bob animation
		var tween: Tween = create_tween().set_loops()
		var bob_pos: Vector3 = spec.position
		tween.tween_property(spec, "position:y", bob_pos.y + 0.04, 1.0 + i * 0.1).set_ease(Tween.EASE_IN_OUT)
		tween.tween_property(spec, "position:y", bob_pos.y, 1.0 + i * 0.1).set_ease(Tween.EASE_IN_OUT)


func _build_combat_trainer_npc() -> void:
	## Epic-1 T30: combat trainer NPC at the sparring arena edge
	var trainer: Node3D = Node3D.new()
	trainer.name = "EastPlazaCombatTrainer"
	trainer.position = Vector3(36, 0.5, -14)
	add_child(trainer)
	var body: MeshInstance3D = MeshInstance3D.new()
	var sphere: SphereMesh = SphereMesh.new()
	sphere.radius = 0.42
	sphere.height = 0.84
	body.mesh = sphere
	var mat: StandardMaterial3D = StandardMaterial3D.new()
	mat.albedo_color = Color(0.85, 0.18, 0.18)
	mat.emission_enabled = true
	mat.emission = Color(1.0, 0.25, 0.15)
	mat.emission_energy_multiplier = 0.7
	mat.metallic = 0.4
	body.material_override = mat
	trainer.add_child(body)
	# Determined eyes
	var eye_mat: StandardMaterial3D = StandardMaterial3D.new()
	eye_mat.albedo_color = Color(1.0, 0.95, 0.30)
	eye_mat.emission_enabled = true
	eye_mat.emission = Color(1.0, 0.85, 0.20)
	eye_mat.emission_energy_multiplier = 2.5
	eye_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for side: float in [-0.13, 0.13]:
		var eye: MeshInstance3D = MeshInstance3D.new()
		var em: SphereMesh = SphereMesh.new()
		em.radius = 0.07
		em.height = 0.14
		eye.mesh = em
		eye.position = Vector3(side, 0.18, -0.32)
		eye.material_override = eye_mat
		body.add_child(eye)
	var label: Label3D = Label3D.new()
	label.text = "Combat Trainer"
	label.position = Vector3(0, 1.4, 0)
	label.modulate = Color(1.0, 0.50, 0.30)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 6
	label.font_size = 22
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	trainer.add_child(label)


func _build_ground_light_strips(geom: Node) -> void:
	## Epic-1 T21: thin cyan light strips embedded in the floor leading from the
	## main town path edge into the plaza centerpiece
	for i: int in 8:
		var strip: MeshInstance3D = MeshInstance3D.new()
		var smesh: BoxMesh = BoxMesh.new()
		smesh.size = Vector3(0.4, 0.02, 0.08)
		strip.mesh = smesh
		strip.position = Vector3(22 + i * 1.4, 0.02, 0)
		var smat: StandardMaterial3D = StandardMaterial3D.new()
		smat.albedo_color = Color(0.30, 0.85, 1.0)
		smat.emission_enabled = true
		smat.emission = Color(0.40, 0.95, 1.0)
		smat.emission_energy_multiplier = 2.5
		smat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		strip.material_override = smat
		geom.add_child(strip)
		# Sequential pulse — each strip flashes in turn for a "follow me" effect
		var tween: Tween = create_tween().set_loops()
		var dim_amount: float = 0.6
		var bright_amount: float = 4.0
		tween.tween_interval(i * 0.15)
		tween.tween_property(smat, "emission_energy_multiplier", bright_amount, 0.4).set_ease(Tween.EASE_OUT)
		tween.tween_property(smat, "emission_energy_multiplier", dim_amount, 0.8).set_ease(Tween.EASE_IN)
		tween.tween_interval((8 - i) * 0.15)


func _build_maintenance_bots(geom: Node) -> void:
	## Epic-1 T22: 3 small disk-shaped maintenance bots sweeping the plaza floor
	for i: int in 3:
		var bot: Node3D = Node3D.new()
		bot.name = "EastPlazaMaintBot_%d" % i
		bot.position = Vector3(28 + i * 4, 0.1, 9 - i * 5)
		geom.add_child(bot)
		# Disc body
		var body: MeshInstance3D = MeshInstance3D.new()
		var bmesh: CylinderMesh = CylinderMesh.new()
		bmesh.top_radius = 0.22
		bmesh.bottom_radius = 0.22
		bmesh.height = 0.10
		body.mesh = bmesh
		var bmat: StandardMaterial3D = StandardMaterial3D.new()
		bmat.albedo_color = Color(0.85, 0.85, 0.90)
		bmat.emission_enabled = true
		bmat.emission = Color(1.0, 0.95, 0.90)
		bmat.emission_energy_multiplier = 0.4
		bmat.metallic = 0.85
		body.material_override = bmat
		bot.add_child(body)
		# Top status LED
		var led: MeshInstance3D = MeshInstance3D.new()
		var lmesh: SphereMesh = SphereMesh.new()
		lmesh.radius = 0.04
		lmesh.height = 0.08
		led.mesh = lmesh
		led.position = Vector3(0.05, 0.06, 0)
		var lmat: StandardMaterial3D = StandardMaterial3D.new()
		lmat.albedo_color = Color(0.30, 1.0, 0.40)
		lmat.emission_enabled = true
		lmat.emission = Color(0.30, 1.0, 0.40)
		lmat.emission_energy_multiplier = 3.0
		lmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		led.material_override = lmat
		bot.add_child(led)
		# Sweep tween — patrol along the south edge
		var tween: Tween = create_tween().set_loops()
		var p1 := Vector3(24 + i * 6, 0.1, 9 - i * 5)
		var p2 := Vector3(40 - i * 4, 0.1, 9 - i * 5)
		tween.tween_property(bot, "position", p1, 6.0 + i).set_ease(Tween.EASE_IN_OUT)
		tween.tween_property(bot, "position", p2, 6.0 + i).set_ease(Tween.EASE_IN_OUT)


func _build_sky_data_fragments(geom: Node) -> void:
	## Epic-1 T23: slow falling cyan/orange data fragments overhead — rare,
	## small particles that drift down through the plaza
	var particles: GPUParticles3D = GPUParticles3D.new()
	particles.amount = 30
	particles.lifetime = 12.0
	particles.position = Vector3(32, 8.0, 0)
	var pmat: ParticleProcessMaterial = ParticleProcessMaterial.new()
	pmat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	pmat.emission_box_extents = Vector3(10, 0.5, 18)
	pmat.direction = Vector3(0, -1, 0)
	pmat.gravity = Vector3(0.05, -0.4, 0.02)
	pmat.initial_velocity_min = 0.1
	pmat.initial_velocity_max = 0.3
	pmat.scale_min = 0.06
	pmat.scale_max = 0.14
	pmat.color = Color(0.85, 0.55, 0.30, 0.85)
	particles.process_material = pmat
	var dot_mesh: SphereMesh = SphereMesh.new()
	dot_mesh.radius = 0.05
	dot_mesh.height = 0.10
	particles.draw_pass_1 = dot_mesh
	geom.add_child(particles)


func _build_power_conduits(geom: Node) -> void:
	## Epic-1 T24: glowing cyan power conduits running across the plaza floor
	## connecting the data terminal to the kiosks (4 lines radiating outward)
	var conduit_mat: StandardMaterial3D = StandardMaterial3D.new()
	conduit_mat.albedo_color = Color(0.15, 0.45, 0.65)
	conduit_mat.emission_enabled = true
	conduit_mat.emission = Color(0.20, 0.70, 0.95)
	conduit_mat.emission_energy_multiplier = 1.4
	conduit_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	# 4 lines from the centerpiece (32, 0, 0) to each kiosk corner
	var endpoints: Array[Vector3] = [
		Vector3(28, 0.04, -4), Vector3(36, 0.04, -4),
		Vector3(28, 0.04, 4), Vector3(36, 0.04, 4),
	]
	for ep in endpoints:
		var conduit: MeshInstance3D = MeshInstance3D.new()
		var cmesh: BoxMesh = BoxMesh.new()
		var dist: float = (ep - Vector3(32, 0.04, 0)).length()
		cmesh.size = Vector3(0.10, 0.02, dist)
		conduit.mesh = cmesh
		var midpoint: Vector3 = Vector3(32, 0.04, 0).lerp(ep, 0.5)
		conduit.position = midpoint
		conduit.look_at(ep, Vector3.UP)
		conduit.material_override = conduit_mat
		geom.add_child(conduit)


func _build_plaza_arch_gateway(geom: Node) -> void:
	## Epic-1 T25: large arch gateway at the west entrance of the plaza
	## (where the connecting path meets the plaza)
	var arch: Node3D = Node3D.new()
	arch.name = "EastPlazaArchGateway"
	arch.position = Vector3(21, 0, 0)
	geom.add_child(arch)
	# 2 vertical pillars
	var pillar_mat: StandardMaterial3D = StandardMaterial3D.new()
	pillar_mat.albedo_color = Color(0.10, 0.18, 0.26)
	pillar_mat.emission_enabled = true
	pillar_mat.emission = Color(0.30, 0.85, 1.0)
	pillar_mat.emission_energy_multiplier = 0.7
	pillar_mat.metallic = 0.7
	for x_offset: float in [-3.0, 3.0]:
		var pillar: MeshInstance3D = MeshInstance3D.new()
		var pmesh: CylinderMesh = CylinderMesh.new()
		pmesh.top_radius = 0.25
		pmesh.bottom_radius = 0.35
		pmesh.height = 4.0
		pillar.mesh = pmesh
		pillar.position = Vector3(0, 2.0, x_offset)
		pillar.material_override = pillar_mat
		arch.add_child(pillar)
		# Collision per pillar
		var sb: StaticBody3D = StaticBody3D.new()
		var col_shape: CollisionShape3D = CollisionShape3D.new()
		var col_box: BoxShape3D = BoxShape3D.new()
		col_box.size = Vector3(0.7, 4.0, 0.7)
		col_shape.shape = col_box
		col_shape.position = Vector3(0, 2.0, x_offset)
		sb.add_child(col_shape)
		arch.add_child(sb)
	# Top crossbar
	var crossbar: MeshInstance3D = MeshInstance3D.new()
	var cmesh: BoxMesh = BoxMesh.new()
	cmesh.size = Vector3(0.5, 0.5, 6.5)
	crossbar.mesh = cmesh
	crossbar.position = Vector3(0, 4.0, 0)
	crossbar.material_override = pillar_mat
	arch.add_child(crossbar)
	# Glowing arch label
	var label: Label3D = Label3D.new()
	label.text = "EAST PLAZA"
	label.position = Vector3(0, 4.5, 0)
	label.modulate = Color(0.40, 0.95, 1.0)
	label.outline_modulate = Color(0, 0.05, 0.10, 0.95)
	label.outline_size = 8
	label.font_size = 32
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	arch.add_child(label)


func _build_data_fountain(geom: Node) -> void:
	## Epic-1 T16: cyan data fountain at (32, 0, 12) — wide basin + central
	## column with rising particle stream
	var fountain: Node3D = Node3D.new()
	fountain.name = "EastPlazaDataFountain"
	fountain.position = Vector3(32, 0, 12)
	geom.add_child(fountain)
	# Wide basin (low cylinder)
	var basin: MeshInstance3D = MeshInstance3D.new()
	var basin_mesh: CylinderMesh = CylinderMesh.new()
	basin_mesh.top_radius = 1.4
	basin_mesh.bottom_radius = 1.5
	basin_mesh.height = 0.3
	basin.mesh = basin_mesh
	basin.position = Vector3(0, 0.15, 0)
	var basin_mat: StandardMaterial3D = StandardMaterial3D.new()
	basin_mat.albedo_color = Color(0.10, 0.18, 0.26)
	basin_mat.emission_enabled = true
	basin_mat.emission = Color(0.30, 0.85, 1.0)
	basin_mat.emission_energy_multiplier = 0.5
	basin_mat.metallic = 0.6
	basin.material_override = basin_mat
	fountain.add_child(basin)
	# Central column
	var column: MeshInstance3D = MeshInstance3D.new()
	var col_mesh: CylinderMesh = CylinderMesh.new()
	col_mesh.top_radius = 0.18
	col_mesh.bottom_radius = 0.25
	col_mesh.height = 1.2
	column.mesh = col_mesh
	column.position = Vector3(0, 0.9, 0)
	column.material_override = basin_mat
	fountain.add_child(column)
	# Rising "data stream" particle column
	var particles: GPUParticles3D = GPUParticles3D.new()
	particles.amount = 80
	particles.lifetime = 2.0
	particles.position = Vector3(0, 1.5, 0)
	var pmat: ParticleProcessMaterial = ParticleProcessMaterial.new()
	pmat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	pmat.emission_sphere_radius = 0.1
	pmat.direction = Vector3(0, 1, 0)
	pmat.spread = 8.0
	pmat.gravity = Vector3(0, -0.4, 0)
	pmat.initial_velocity_min = 1.5
	pmat.initial_velocity_max = 2.4
	pmat.scale_min = 0.05
	pmat.scale_max = 0.10
	pmat.color = Color(0.45, 0.95, 1.0, 0.85)
	particles.process_material = pmat
	var dot_mesh: SphereMesh = SphereMesh.new()
	dot_mesh.radius = 0.04
	dot_mesh.height = 0.08
	particles.draw_pass_1 = dot_mesh
	fountain.add_child(particles)
	# Collision around the basin
	var sb: StaticBody3D = StaticBody3D.new()
	var col_shape: CollisionShape3D = CollisionShape3D.new()
	var col_box: BoxShape3D = BoxShape3D.new()
	col_box.size = Vector3(3.0, 0.3, 3.0)
	col_shape.shape = col_box
	col_shape.position = Vector3(0, 0.15, 0)
	sb.add_child(col_shape)
	fountain.add_child(sb)


func _build_holo_billboards(geom: Node) -> void:
	## Epic-1 T17: 2 floating holographic billboards above the plaza
	for entry in [
		[Vector3(28, 5.0, 0), "EAST PLAZA", Color(1.0, 0.55, 0.15)],
		[Vector3(36, 5.5, 0), "DATA MARKET", Color(0.30, 0.85, 1.0)],
	]:
		var pos: Vector3 = entry[0]
		var text: String = entry[1]
		var hue: Color = entry[2]
		var board: Node3D = Node3D.new()
		board.position = pos
		geom.add_child(board)
		# Translucent panel backdrop
		var panel: MeshInstance3D = MeshInstance3D.new()
		var pmesh: BoxMesh = BoxMesh.new()
		pmesh.size = Vector3(3.5, 0.9, 0.05)
		panel.mesh = pmesh
		var pmat: StandardMaterial3D = StandardMaterial3D.new()
		pmat.albedo_color = Color(hue.r, hue.g, hue.b, 0.4)
		pmat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		pmat.emission_enabled = true
		pmat.emission = hue
		pmat.emission_energy_multiplier = 1.8
		pmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		panel.material_override = pmat
		board.add_child(panel)
		# Text label
		var label: Label3D = Label3D.new()
		label.text = text
		label.position = Vector3(0, 0, -0.05)
		label.modulate = Color(1, 1, 1)
		label.outline_modulate = Color(0, 0, 0, 0.95)
		label.outline_size = 8
		label.font_size = 36
		label.no_depth_test = true
		board.add_child(label)
		# Slow Y-bob animation
		var tween: Tween = create_tween().set_loops()
		tween.tween_property(board, "position:y", pos.y + 0.2, 3.0).set_ease(Tween.EASE_IN_OUT)
		tween.tween_property(board, "position:y", pos.y, 3.0).set_ease(Tween.EASE_IN_OUT)


func _build_neon_ads(geom: Node) -> void:
	## Epic-1 T18: 4 neon ad strips along the south plaza boundary
	for i: int in 4:
		var strip: MeshInstance3D = MeshInstance3D.new()
		var smesh: BoxMesh = BoxMesh.new()
		smesh.size = Vector3(2.2, 0.3, 0.04)
		strip.mesh = smesh
		strip.position = Vector3(26 + i * 4, 1.8, 14)
		var hues: Array[Color] = [
			Color(1.0, 0.20, 0.50),  # hot pink
			Color(0.30, 1.0, 0.50),  # neon green
			Color(0.20, 0.50, 1.0),  # electric blue
			Color(1.0, 0.85, 0.20),  # neon yellow
		]
		var smat: StandardMaterial3D = StandardMaterial3D.new()
		smat.albedo_color = hues[i]
		smat.emission_enabled = true
		smat.emission = hues[i]
		smat.emission_energy_multiplier = 2.5
		smat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		strip.material_override = smat
		geom.add_child(strip)
		# Pulse animation — alternating brightness
		var tween: Tween = create_tween().set_loops()
		tween.tween_property(smat, "emission_energy_multiplier", 4.0, 0.8 + i * 0.15).set_ease(Tween.EASE_IN_OUT)
		tween.tween_property(smat, "emission_energy_multiplier", 1.5, 0.8 + i * 0.15).set_ease(Tween.EASE_IN_OUT)


func _build_transit_pad(geom: Node) -> void:
	## Epic-1 T19: glowing transit pad at the SW corner of the plaza —
	## hexagonal landing pad with circular pulse animation
	var pad: Node3D = Node3D.new()
	pad.name = "EastPlazaTransitPad"
	pad.position = Vector3(24, 0, -10)
	geom.add_child(pad)
	# Hexagonal base
	var hex: MeshInstance3D = MeshInstance3D.new()
	var hex_mesh: CylinderMesh = CylinderMesh.new()
	hex_mesh.top_radius = 1.6
	hex_mesh.bottom_radius = 1.6
	hex_mesh.height = 0.15
	hex_mesh.radial_segments = 6
	hex.mesh = hex_mesh
	hex.position = Vector3(0, 0.075, 0)
	var hmat: StandardMaterial3D = StandardMaterial3D.new()
	hmat.albedo_color = Color(0.10, 0.20, 0.35)
	hmat.emission_enabled = true
	hmat.emission = Color(0.30, 0.85, 1.0)
	hmat.emission_energy_multiplier = 1.0
	hmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	hex.material_override = hmat
	pad.add_child(hex)
	# Pulsing emission
	var tween: Tween = create_tween().set_loops()
	tween.tween_property(hmat, "emission_energy_multiplier", 2.5, 1.5).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(hmat, "emission_energy_multiplier", 0.8, 1.5).set_ease(Tween.EASE_IN_OUT)
	# Vertical light beam
	var beam: MeshInstance3D = MeshInstance3D.new()
	var beam_mesh: CylinderMesh = CylinderMesh.new()
	beam_mesh.top_radius = 1.5
	beam_mesh.bottom_radius = 1.5
	beam_mesh.height = 8.0
	beam.mesh = beam_mesh
	beam.position = Vector3(0, 4.0, 0)
	var bmat: StandardMaterial3D = StandardMaterial3D.new()
	bmat.albedo_color = Color(0.30, 0.85, 1.0, 0.18)
	bmat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	bmat.emission_enabled = true
	bmat.emission = Color(0.40, 0.90, 1.0)
	bmat.emission_energy_multiplier = 0.5
	bmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	bmat.cull_mode = BaseMaterial3D.CULL_DISABLED
	beam.material_override = bmat
	pad.add_child(beam)


func _build_shop_signage(geom: Node) -> void:
	## Epic-1 T20: 4 vertical glow text labels above the kiosks naming
	## what each kiosk sells
	var sign_data: Array = [
		[Vector3(28, 2.4, -4), "CHIPS", Color(0.30, 0.85, 1.0)],
		[Vector3(36, 2.4, -4), "MODULES", Color(1.0, 0.55, 0.15)],
		[Vector3(28, 2.4, 4), "PROTOCOLS", Color(0.55, 0.35, 0.85)],
		[Vector3(36, 2.4, 4), "PROMPTS", Color(0.30, 1.0, 0.50)],
	]
	for entry in sign_data:
		var pos: Vector3 = entry[0]
		var text: String = entry[1]
		var hue: Color = entry[2]
		var label: Label3D = Label3D.new()
		label.text = text
		label.position = pos
		label.modulate = hue
		label.outline_modulate = Color(0, 0.05, 0.10, 0.95)
		label.outline_size = 7
		label.font_size = 26
		label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		label.no_depth_test = true
		geom.add_child(label)


func _build_info_totems(geom: Node) -> void:
	## Epic-1 T15: 3 info totem pillars near plaza entrances
	for pos in [Vector3(22, 0, 0), Vector3(32, 0, 12), Vector3(32, 0, -12)]:
		var totem: Node3D = Node3D.new()
		totem.position = pos
		geom.add_child(totem)
		# Tall pillar
		var pillar: MeshInstance3D = MeshInstance3D.new()
		var pmesh: CylinderMesh = CylinderMesh.new()
		pmesh.top_radius = 0.15
		pmesh.bottom_radius = 0.20
		pmesh.height = 2.4
		pillar.mesh = pmesh
		pillar.position = Vector3(0, 1.2, 0)
		var pmat: StandardMaterial3D = StandardMaterial3D.new()
		pmat.albedo_color = Color(0.10, 0.16, 0.22)
		pmat.emission_enabled = true
		pmat.emission = Color(0.20, 0.70, 0.95)
		pmat.emission_energy_multiplier = 0.5
		pmat.metallic = 0.7
		pillar.material_override = pmat
		totem.add_child(pillar)
		# Glowing top
		var top: MeshInstance3D = MeshInstance3D.new()
		var tmesh: SphereMesh = SphereMesh.new()
		tmesh.radius = 0.22
		tmesh.height = 0.44
		top.mesh = tmesh
		top.position = Vector3(0, 2.5, 0)
		var tmat: StandardMaterial3D = StandardMaterial3D.new()
		tmat.albedo_color = Color(0.30, 0.85, 1.0)
		tmat.emission_enabled = true
		tmat.emission = Color(0.40, 0.95, 1.0)
		tmat.emission_energy_multiplier = 2.5
		tmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		top.material_override = tmat
		totem.add_child(top)
		# Floating "i" info label
		var label: Label3D = Label3D.new()
		label.text = "ⓘ INFO"
		label.position = Vector3(0, 2.95, 0)
		label.modulate = Color(0.50, 0.95, 1.0)
		label.outline_modulate = Color(0, 0, 0, 0.85)
		label.outline_size = 6
		label.font_size = 18
		label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		totem.add_child(label)
		# Collision
		var sb: StaticBody3D = StaticBody3D.new()
		var col_shape: CollisionShape3D = CollisionShape3D.new()
		var col_box: BoxShape3D = BoxShape3D.new()
		col_box.size = Vector3(0.4, 2.7, 0.4)
		col_shape.shape = col_box
		col_shape.position = Vector3(0, 1.35, 0)
		sb.add_child(col_shape)
		totem.add_child(sb)


func _build_holo_shop_windows(geom: Node) -> void:
	## Epic-1 T46: 4 holographic shop windows along vendor row at z=10. Each is
	## a large translucent cyan panel with a floating product silhouette inside,
	## bobbing gently to suggest a hovering 3d hologram preview.
	var product_names: Array[String] = ["BLADE", "SHARD", "CORE", "PATCH"]
	for i in 4:
		var booth: Node3D = Node3D.new()
		booth.name = "EastPlazaHoloShop_%d" % i
		booth.position = Vector3(26 + i * 3.5, 0, 10)
		geom.add_child(booth)
		# Backing frame
		var frame: MeshInstance3D = MeshInstance3D.new()
		var fmesh: BoxMesh = BoxMesh.new()
		fmesh.size = Vector3(2.4, 2.6, 0.18)
		frame.mesh = fmesh
		frame.position = Vector3(0, 1.6, 0)
		var fmat: StandardMaterial3D = StandardMaterial3D.new()
		fmat.albedo_color = Color(0.06, 0.10, 0.14)
		fmat.metallic = 0.85
		fmat.roughness = 0.25
		frame.material_override = fmat
		booth.add_child(frame)
		# Translucent cyan glass panel
		var panel: MeshInstance3D = MeshInstance3D.new()
		var pmesh: BoxMesh = BoxMesh.new()
		pmesh.size = Vector3(2.1, 2.3, 0.04)
		panel.mesh = pmesh
		panel.position = Vector3(0, 1.65, 0.1)
		var pmat: StandardMaterial3D = StandardMaterial3D.new()
		pmat.albedo_color = Color(0.20, 0.85, 1.0, 0.30)
		pmat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		pmat.emission_enabled = true
		pmat.emission = Color(0.30, 0.85, 1.0)
		pmat.emission_energy_multiplier = 0.6
		pmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		panel.material_override = pmat
		booth.add_child(panel)
		# Floating product silhouette (rotating cube as placeholder hologram)
		var holo: MeshInstance3D = MeshInstance3D.new()
		holo.name = "Hologram"
		var hmesh: BoxMesh = BoxMesh.new()
		hmesh.size = Vector3(0.55, 0.55, 0.55)
		holo.mesh = hmesh
		holo.position = Vector3(0, 1.7, 0.2)
		var hmat: StandardMaterial3D = StandardMaterial3D.new()
		hmat.albedo_color = Color(0.85, 0.95, 1.0, 0.55)
		hmat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		hmat.emission_enabled = true
		hmat.emission = Color(0.50, 0.95, 1.0)
		hmat.emission_energy_multiplier = 1.6
		hmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		holo.material_override = hmat
		booth.add_child(holo)
		# Slow rotation tween + bob
		var rot: Tween = create_tween().set_loops()
		rot.tween_property(holo, "rotation:y", TAU, 6.0)
		var bob: Tween = create_tween().set_loops()
		bob.tween_property(holo, "position:y", 1.85, 1.6).set_ease(Tween.EASE_IN_OUT)
		bob.tween_property(holo, "position:y", 1.7, 1.6).set_ease(Tween.EASE_IN_OUT)
		# Product label above panel
		var label: Label3D = Label3D.new()
		label.text = product_names[i]
		label.position = Vector3(0, 3.0, 0.15)
		label.modulate = Color(0.55, 0.95, 1.0)
		label.outline_modulate = Color(0, 0, 0, 0.85)
		label.outline_size = 5
		label.font_size = 22
		label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		booth.add_child(label)
		# Collision so the player cannot phase through the booth
		var sb: StaticBody3D = StaticBody3D.new()
		var col_shape: CollisionShape3D = CollisionShape3D.new()
		var col_box: BoxShape3D = BoxShape3D.new()
		col_box.size = Vector3(2.4, 2.6, 0.5)
		col_shape.shape = col_box
		col_shape.position = Vector3(0, 1.3, 0)
		sb.add_child(col_shape)
		booth.add_child(sb)


func _build_atrium_roof(geom: Node) -> void:
	## Epic-1 T47: translucent glass atrium roof spanning the market core. 4
	## tall metal columns and a wide flat glass panel suggest a covered market
	## hall without occluding the camera. Edge trim glows cyan.
	var atrium: Node3D = Node3D.new()
	atrium.name = "EastPlazaAtrium"
	atrium.position = Vector3(32, 0, 0)
	geom.add_child(atrium)
	var glass_mat: StandardMaterial3D = StandardMaterial3D.new()
	glass_mat.albedo_color = Color(0.55, 0.85, 1.0, 0.18)
	glass_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	glass_mat.emission_enabled = true
	glass_mat.emission = Color(0.35, 0.80, 1.0)
	glass_mat.emission_energy_multiplier = 0.20
	glass_mat.metallic = 0.30
	glass_mat.roughness = 0.10
	var col_mat: StandardMaterial3D = StandardMaterial3D.new()
	col_mat.albedo_color = Color(0.12, 0.16, 0.20)
	col_mat.metallic = 0.85
	col_mat.roughness = 0.30
	col_mat.emission_enabled = true
	col_mat.emission = Color(0.25, 0.75, 1.0)
	col_mat.emission_energy_multiplier = 0.4
	# 4 perimeter columns
	var col_offsets: Array[Vector3] = [
		Vector3(-6, 0, -6),
		Vector3(6, 0, -6),
		Vector3(-6, 0, 6),
		Vector3(6, 0, 6),
	]
	for off in col_offsets:
		var pillar: MeshInstance3D = MeshInstance3D.new()
		var cmesh: CylinderMesh = CylinderMesh.new()
		cmesh.top_radius = 0.22
		cmesh.bottom_radius = 0.30
		cmesh.height = 6.5
		pillar.mesh = cmesh
		pillar.position = off + Vector3(0, 3.25, 0)
		pillar.material_override = col_mat
		atrium.add_child(pillar)
		# Collision so columns are solid
		var sb: StaticBody3D = StaticBody3D.new()
		var cs: CollisionShape3D = CollisionShape3D.new()
		var cap: CapsuleShape3D = CapsuleShape3D.new()
		cap.radius = 0.30
		cap.height = 6.5
		cs.shape = cap
		cs.position = off + Vector3(0, 3.25, 0)
		sb.add_child(cs)
		atrium.add_child(sb)
	# Flat glass roof slab
	var roof: MeshInstance3D = MeshInstance3D.new()
	var rmesh: BoxMesh = BoxMesh.new()
	rmesh.size = Vector3(13, 0.10, 13)
	roof.mesh = rmesh
	roof.position = Vector3(0, 6.55, 0)
	roof.material_override = glass_mat
	atrium.add_child(roof)
	# Glowing edge trim — 4 thin emissive bars around the slab perimeter
	var trim_mat: StandardMaterial3D = StandardMaterial3D.new()
	trim_mat.albedo_color = Color(0.30, 0.85, 1.0)
	trim_mat.emission_enabled = true
	trim_mat.emission = Color(0.50, 0.95, 1.0)
	trim_mat.emission_energy_multiplier = 1.4
	trim_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var trim_specs: Array = [
		[Vector3(0, 6.55, -6.5), Vector3(13, 0.12, 0.12)],
		[Vector3(0, 6.55, 6.5), Vector3(13, 0.12, 0.12)],
		[Vector3(-6.5, 6.55, 0), Vector3(0.12, 0.12, 13)],
		[Vector3(6.5, 6.55, 0), Vector3(0.12, 0.12, 13)],
	]
	for spec in trim_specs:
		var bar: MeshInstance3D = MeshInstance3D.new()
		var bmesh: BoxMesh = BoxMesh.new()
		bmesh.size = spec[1]
		bar.mesh = bmesh
		bar.position = spec[0]
		bar.material_override = trim_mat
		atrium.add_child(bar)


func _build_cafe_seating(geom: Node) -> void:
	## Epic-1 T48: 3 small round cafe tables with 2 stools each, near vendor row.
	## Tables have warm amber emissive tops to read as data-cafes.
	var table_mat: StandardMaterial3D = StandardMaterial3D.new()
	table_mat.albedo_color = Color(0.30, 0.20, 0.08)
	table_mat.emission_enabled = true
	table_mat.emission = Color(0.95, 0.65, 0.20)
	table_mat.emission_energy_multiplier = 0.45
	table_mat.metallic = 0.55
	table_mat.roughness = 0.40
	var leg_mat: StandardMaterial3D = StandardMaterial3D.new()
	leg_mat.albedo_color = Color(0.10, 0.12, 0.14)
	leg_mat.metallic = 0.85
	leg_mat.roughness = 0.30
	var stool_mat: StandardMaterial3D = StandardMaterial3D.new()
	stool_mat.albedo_color = Color(0.22, 0.30, 0.40)
	stool_mat.emission_enabled = true
	stool_mat.emission = Color(0.30, 0.65, 0.95)
	stool_mat.emission_energy_multiplier = 0.30
	stool_mat.metallic = 0.50
	var positions: Array[Vector3] = [
		Vector3(28, 0, 7),
		Vector3(33, 0, 7),
		Vector3(38, 0, 7),
	]
	for i in positions.size():
		var cafe: Node3D = Node3D.new()
		cafe.name = "EastPlazaCafe_%d" % i
		cafe.position = positions[i]
		geom.add_child(cafe)
		# Table column
		var leg: MeshInstance3D = MeshInstance3D.new()
		var leg_mesh: CylinderMesh = CylinderMesh.new()
		leg_mesh.top_radius = 0.08
		leg_mesh.bottom_radius = 0.10
		leg_mesh.height = 0.85
		leg.mesh = leg_mesh
		leg.position = Vector3(0, 0.43, 0)
		leg.material_override = leg_mat
		cafe.add_child(leg)
		# Round table top
		var top: MeshInstance3D = MeshInstance3D.new()
		var top_mesh: CylinderMesh = CylinderMesh.new()
		top_mesh.top_radius = 0.55
		top_mesh.bottom_radius = 0.55
		top_mesh.height = 0.08
		top.mesh = top_mesh
		top.position = Vector3(0, 0.89, 0)
		top.material_override = table_mat
		cafe.add_child(top)
		# 2 stools facing each other
		for sx: float in [-1.0, 1.0]:
			var stool: MeshInstance3D = MeshInstance3D.new()
			var smesh: CylinderMesh = CylinderMesh.new()
			smesh.top_radius = 0.22
			smesh.bottom_radius = 0.22
			smesh.height = 0.55
			stool.mesh = smesh
			stool.position = Vector3(sx, 0.27, 0)
			stool.material_override = stool_mat
			cafe.add_child(stool)
		# Collision: one box around the table
		var sb: StaticBody3D = StaticBody3D.new()
		var cs: CollisionShape3D = CollisionShape3D.new()
		var cb: BoxShape3D = BoxShape3D.new()
		cb.size = Vector3(2.6, 1.0, 1.2)
		cs.shape = cb
		cs.position = Vector3(0, 0.5, 0)
		sb.add_child(cs)
		cafe.add_child(sb)


func _build_data_streams(geom: Node) -> void:
	## Epic-1 T49: 2 small secondary data-stream fountains flanking the main
	## fountain at the plaza center. Each is a low ring + a tall vertical column
	## of cyan particles flowing upward and dispersing — pure ambient effect.
	var positions: Array[Vector3] = [
		Vector3(28, 0, -3),
		Vector3(36, 0, -3),
	]
	var ring_mat: StandardMaterial3D = StandardMaterial3D.new()
	ring_mat.albedo_color = Color(0.10, 0.18, 0.26)
	ring_mat.emission_enabled = true
	ring_mat.emission = Color(0.30, 0.85, 1.0)
	ring_mat.emission_energy_multiplier = 0.7
	ring_mat.metallic = 0.55
	ring_mat.roughness = 0.30
	for i in positions.size():
		var stream: Node3D = Node3D.new()
		stream.name = "EastPlazaDataStream_%d" % i
		stream.position = positions[i]
		geom.add_child(stream)
		# Low torus ring base
		var ring: MeshInstance3D = MeshInstance3D.new()
		var tmesh: TorusMesh = TorusMesh.new()
		tmesh.inner_radius = 0.55
		tmesh.outer_radius = 0.85
		ring.mesh = tmesh
		ring.position = Vector3(0, 0.15, 0)
		ring.material_override = ring_mat
		stream.add_child(ring)
		# Vertical particle column
		var col: GPUParticles3D = GPUParticles3D.new()
		col.name = "Stream"
		col.amount = 60
		col.lifetime = 1.8
		col.position = Vector3(0, 0.5, 0)
		col.one_shot = false
		col.explosiveness = 0.0
		var pmat: ParticleProcessMaterial = ParticleProcessMaterial.new()
		pmat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
		pmat.emission_sphere_radius = 0.30
		pmat.direction = Vector3(0, 1, 0)
		pmat.spread = 8.0
		pmat.initial_velocity_min = 1.4
		pmat.initial_velocity_max = 2.2
		pmat.gravity = Vector3(0, -0.4, 0)
		pmat.scale_min = 0.05
		pmat.scale_max = 0.12
		pmat.color = Color(0.55, 0.95, 1.0, 1.0)
		col.process_material = pmat
		# A simple sphere mesh draw
		var dmesh: SphereMesh = SphereMesh.new()
		dmesh.radius = 0.10
		dmesh.height = 0.20
		var dmat: StandardMaterial3D = StandardMaterial3D.new()
		dmat.albedo_color = Color(0.55, 0.95, 1.0)
		dmat.emission_enabled = true
		dmat.emission = Color(0.55, 0.95, 1.0)
		dmat.emission_energy_multiplier = 2.4
		dmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		dmesh.material = dmat
		col.draw_pass_1 = dmesh
		stream.add_child(col)


func _build_district_signposts(geom: Node) -> void:
	## Epic-1 T50: directional signpost cluster at the plaza arch entrance.
	## Single tall metal pole with 4 angled arrow signs pointing toward
	## hypothetical districts to telegraph future expansion.
	var post_root: Node3D = Node3D.new()
	post_root.name = "EastPlazaDistrictSignpost"
	post_root.position = Vector3(22, 0, 0)
	geom.add_child(post_root)
	# Tall metal pole
	var pole: MeshInstance3D = MeshInstance3D.new()
	var pmesh: CylinderMesh = CylinderMesh.new()
	pmesh.top_radius = 0.07
	pmesh.bottom_radius = 0.10
	pmesh.height = 3.4
	pole.mesh = pmesh
	pole.position = Vector3(0, 1.7, 0)
	var pole_mat: StandardMaterial3D = StandardMaterial3D.new()
	pole_mat.albedo_color = Color(0.10, 0.13, 0.16)
	pole_mat.metallic = 0.85
	pole_mat.roughness = 0.30
	pole.material_override = pole_mat
	post_root.add_child(pole)
	# 4 arrow signs at different heights / yaws
	var sign_specs: Array = [
		["MARKET", Color(0.95, 0.65, 0.20), 2.9, 0.0],
		["DUNGEON", Color(0.85, 0.30, 0.30), 2.45, PI * 0.5],
		["TOURNAMENT", Color(0.45, 0.95, 0.65), 2.0, PI],
		["CIPHER LAB", Color(0.85, 0.40, 1.0), 1.55, PI * 1.5],
	]
	for spec in sign_specs:
		var sign_text: String = spec[0]
		var color: Color = spec[1]
		var sign_y: float = spec[2]
		var yaw: float = spec[3]
		var arrow: MeshInstance3D = MeshInstance3D.new()
		var amesh: BoxMesh = BoxMesh.new()
		amesh.size = Vector3(1.6, 0.32, 0.06)
		arrow.mesh = amesh
		arrow.position = Vector3(0.85, sign_y, 0)
		var amat: StandardMaterial3D = StandardMaterial3D.new()
		amat.albedo_color = Color(color.r * 0.4, color.g * 0.4, color.b * 0.4)
		amat.emission_enabled = true
		amat.emission = color
		amat.emission_energy_multiplier = 1.0
		amat.metallic = 0.4
		arrow.material_override = amat
		var pivot: Node3D = Node3D.new()
		pivot.rotation = Vector3(0, yaw, 0)
		pivot.add_child(arrow)
		post_root.add_child(pivot)
		# Label on sign
		var label: Label3D = Label3D.new()
		label.text = sign_text
		label.position = Vector3(0.85, sign_y, 0.05)
		label.modulate = Color(1, 1, 1)
		label.outline_modulate = Color(0, 0, 0, 0.85)
		label.outline_size = 4
		label.font_size = 14
		label.no_depth_test = true
		var lpivot: Node3D = Node3D.new()
		lpivot.rotation = Vector3(0, yaw, 0)
		lpivot.add_child(label)
		post_root.add_child(lpivot)
	# Collision around the pole
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cap: CapsuleShape3D = CapsuleShape3D.new()
	cap.radius = 0.20
	cap.height = 3.4
	cs.shape = cap
	cs.position = Vector3(0, 1.7, 0)
	sb.add_child(cs)
	post_root.add_child(sb)


func _build_tournament_audience(geom: Node) -> void:
	## Epic-1 T51: 8 procedural onlooker NPCs ringing the tournament pit at
	## (40, 0, 12). Each is a simple capsule body with eyes, gently bobbing
	## in place as if cheering. Pure ambience — no AI or interaction.
	var pit_center := Vector3(40, 0, 12)
	for i in 8:
		var angle: float = (float(i) / 8.0) * TAU
		var dist: float = 5.5
		var pos: Vector3 = pit_center + Vector3(cos(angle) * dist, 0, sin(angle) * dist)
		var fan: Node3D = Node3D.new()
		fan.name = "EastPlazaTournamentFan_%d" % i
		fan.position = pos
		geom.add_child(fan)
		# Capsule body — palette varies per fan
		var hue: float = float(i) / 8.0
		var body_color: Color = Color.from_hsv(hue, 0.55, 0.85)
		var body: MeshInstance3D = MeshInstance3D.new()
		var bmesh: CapsuleMesh = CapsuleMesh.new()
		bmesh.radius = 0.32
		bmesh.height = 1.0
		body.mesh = bmesh
		body.position = Vector3(0, 0.55, 0)
		var bmat: StandardMaterial3D = StandardMaterial3D.new()
		bmat.albedo_color = body_color
		bmat.emission_enabled = true
		bmat.emission = body_color
		bmat.emission_energy_multiplier = 0.35
		bmat.metallic = 0.20
		bmat.roughness = 0.55
		body.material_override = bmat
		fan.add_child(body)
		# 2 small glowing eyes
		var eye_mat: StandardMaterial3D = StandardMaterial3D.new()
		eye_mat.albedo_color = Color(0.95, 0.95, 1.0)
		eye_mat.emission_enabled = true
		eye_mat.emission = Color(1.0, 1.0, 1.0)
		eye_mat.emission_energy_multiplier = 1.4
		eye_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		# Eyes face the pit center
		var to_center: Vector3 = (pit_center - pos).normalized()
		for ex: float in [-0.10, 0.10]:
			var eye: MeshInstance3D = MeshInstance3D.new()
			var emesh: SphereMesh = SphereMesh.new()
			emesh.radius = 0.05
			emesh.height = 0.10
			eye.mesh = emesh
			# Offset eyes laterally relative to center-facing direction
			var right: Vector3 = to_center.cross(Vector3.UP).normalized()
			eye.position = Vector3(0, 0.95, 0) + right * ex + to_center * 0.30
			eye.material_override = eye_mat
			fan.add_child(eye)
		# Cheering bob tween (random offset so they're not synced)
		var bob: Tween = create_tween().set_loops()
		var bob_speed: float = 0.45 + (i * 0.05)
		bob.tween_property(body, "position:y", 0.75, bob_speed).set_ease(Tween.EASE_IN_OUT)
		bob.tween_property(body, "position:y", 0.55, bob_speed).set_ease(Tween.EASE_IN_OUT)


func _build_waving_banners(geom: Node) -> void:
	## Epic-1 T52: 4 tall flag poles with cyan/violet pennants gently swaying.
	## Each banner is a thin box that rotates around its pole base via a tween,
	## simulating digital wind for ambient motion variety.
	var pole_mat: StandardMaterial3D = StandardMaterial3D.new()
	pole_mat.albedo_color = Color(0.10, 0.13, 0.16)
	pole_mat.metallic = 0.85
	pole_mat.roughness = 0.30
	var positions: Array[Vector3] = [
		Vector3(24, 0, -12),
		Vector3(40, 0, -12),
		Vector3(24, 0, 14),
		Vector3(40, 0, 14),
	]
	var colors: Array[Color] = [
		Color(0.30, 0.85, 1.0),
		Color(0.85, 0.40, 1.0),
		Color(0.30, 0.85, 1.0),
		Color(0.85, 0.40, 1.0),
	]
	for i in positions.size():
		var pole_root: Node3D = Node3D.new()
		pole_root.name = "EastPlazaWavingBanner_%d" % i
		pole_root.position = positions[i]
		geom.add_child(pole_root)
		# Pole
		var pole: MeshInstance3D = MeshInstance3D.new()
		var pmesh: CylinderMesh = CylinderMesh.new()
		pmesh.top_radius = 0.08
		pmesh.bottom_radius = 0.12
		pmesh.height = 5.0
		pole.mesh = pmesh
		pole.position = Vector3(0, 2.5, 0)
		pole.material_override = pole_mat
		pole_root.add_child(pole)
		# Banner pivot at the top of pole, attaches to one edge so it can sway
		var pivot: Node3D = Node3D.new()
		pivot.position = Vector3(0, 4.6, 0)
		pole_root.add_child(pivot)
		# Banner panel pointed away from pole
		var banner: MeshInstance3D = MeshInstance3D.new()
		var bmesh: BoxMesh = BoxMesh.new()
		bmesh.size = Vector3(1.4, 1.6, 0.04)
		banner.mesh = bmesh
		banner.position = Vector3(0.7, -0.8, 0)
		var bmat: StandardMaterial3D = StandardMaterial3D.new()
		bmat.albedo_color = Color(colors[i].r * 0.40, colors[i].g * 0.40, colors[i].b * 0.40)
		bmat.emission_enabled = true
		bmat.emission = colors[i]
		bmat.emission_energy_multiplier = 0.95
		bmat.metallic = 0.10
		bmat.roughness = 0.55
		banner.material_override = bmat
		pivot.add_child(banner)
		# Sway tween — rotate pivot around y axis a few degrees back and forth
		var sway: Tween = create_tween().set_loops()
		var sway_speed: float = 1.2 + (i * 0.15)
		sway.tween_property(pivot, "rotation:y", deg_to_rad(20), sway_speed).set_ease(Tween.EASE_IN_OUT)
		sway.tween_property(pivot, "rotation:y", deg_to_rad(-20), sway_speed).set_ease(Tween.EASE_IN_OUT)
		# Collision on pole
		var sb: StaticBody3D = StaticBody3D.new()
		var cs: CollisionShape3D = CollisionShape3D.new()
		var cap: CapsuleShape3D = CapsuleShape3D.new()
		cap.radius = 0.20
		cap.height = 5.0
		cs.shape = cap
		cs.position = Vector3(0, 2.5, 0)
		sb.add_child(cs)
		pole_root.add_child(sb)


func _build_power_generator(geom: Node) -> void:
	## Epic-1 T53: industrial generator near the loading dock with a spinning
	## turbine ring on top — sells "this plaza is powered by something" without
	## any actual gameplay hookup. Position chosen to flank the dock ramp.
	var gen: Node3D = Node3D.new()
	gen.name = "EastPlazaPowerGenerator"
	gen.position = Vector3(42, 0, -10)
	geom.add_child(gen)
	# Base housing — chunky metal block
	var housing_mat: StandardMaterial3D = StandardMaterial3D.new()
	housing_mat.albedo_color = Color(0.18, 0.20, 0.24)
	housing_mat.metallic = 0.85
	housing_mat.roughness = 0.40
	var base: MeshInstance3D = MeshInstance3D.new()
	var bmesh: BoxMesh = BoxMesh.new()
	bmesh.size = Vector3(2.4, 2.0, 2.4)
	base.mesh = bmesh
	base.position = Vector3(0, 1.0, 0)
	base.material_override = housing_mat
	gen.add_child(base)
	# Cyan accent strips on each side
	var accent_mat: StandardMaterial3D = StandardMaterial3D.new()
	accent_mat.albedo_color = Color(0.20, 0.50, 0.65)
	accent_mat.emission_enabled = true
	accent_mat.emission = Color(0.30, 0.85, 1.0)
	accent_mat.emission_energy_multiplier = 1.6
	accent_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for sign_x: float in [-1.0, 1.0]:
		var strip: MeshInstance3D = MeshInstance3D.new()
		var smesh: BoxMesh = BoxMesh.new()
		smesh.size = Vector3(0.05, 1.4, 1.6)
		strip.mesh = smesh
		strip.position = Vector3(sign_x * 1.21, 1.0, 0)
		strip.material_override = accent_mat
		gen.add_child(strip)
	# Turbine ring — torus that rotates on the y axis
	var turbine: MeshInstance3D = MeshInstance3D.new()
	turbine.name = "TurbineRing"
	var tmesh: TorusMesh = TorusMesh.new()
	tmesh.inner_radius = 0.85
	tmesh.outer_radius = 1.10
	turbine.mesh = tmesh
	turbine.position = Vector3(0, 2.25, 0)
	var tmat: StandardMaterial3D = StandardMaterial3D.new()
	tmat.albedo_color = Color(0.20, 0.50, 0.65)
	tmat.emission_enabled = true
	tmat.emission = Color(0.40, 0.90, 1.0)
	tmat.emission_energy_multiplier = 1.4
	tmat.metallic = 0.65
	tmat.roughness = 0.20
	turbine.material_override = tmat
	gen.add_child(turbine)
	# 4 spoke bars across the ring
	for s in 4:
		var spoke: MeshInstance3D = MeshInstance3D.new()
		var spmesh: BoxMesh = BoxMesh.new()
		spmesh.size = Vector3(2.0, 0.10, 0.10)
		spoke.mesh = spmesh
		spoke.rotation = Vector3(0, deg_to_rad(45 * s), 0)
		spoke.material_override = tmat
		turbine.add_child(spoke)
	# Spin tween
	var spin: Tween = create_tween().set_loops()
	spin.tween_property(turbine, "rotation:y", TAU, 4.0)
	# Tall vent pipe rising off the back
	var pipe: MeshInstance3D = MeshInstance3D.new()
	var pipemesh: CylinderMesh = CylinderMesh.new()
	pipemesh.top_radius = 0.18
	pipemesh.bottom_radius = 0.22
	pipemesh.height = 3.0
	pipe.mesh = pipemesh
	pipe.position = Vector3(0.8, 3.5, -0.8)
	pipe.material_override = housing_mat
	gen.add_child(pipe)
	# Steam particles drifting from the pipe
	var steam: GPUParticles3D = GPUParticles3D.new()
	steam.amount = 24
	steam.lifetime = 2.5
	steam.position = Vector3(0.8, 5.0, -0.8)
	var smat: ParticleProcessMaterial = ParticleProcessMaterial.new()
	smat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	smat.emission_sphere_radius = 0.15
	smat.direction = Vector3(0.2, 1, 0)
	smat.spread = 25.0
	smat.initial_velocity_min = 0.6
	smat.initial_velocity_max = 1.2
	smat.gravity = Vector3.ZERO
	smat.scale_min = 0.20
	smat.scale_max = 0.45
	smat.color = Color(0.85, 0.95, 1.0, 0.5)
	steam.process_material = smat
	var stmesh: SphereMesh = SphereMesh.new()
	stmesh.radius = 0.20
	stmesh.height = 0.40
	var stmat: StandardMaterial3D = StandardMaterial3D.new()
	stmat.albedo_color = Color(0.85, 0.95, 1.0, 0.4)
	stmat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	stmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	stmesh.material = stmat
	steam.draw_pass_1 = stmesh
	gen.add_child(steam)
	# Collision around the housing
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(2.4, 2.0, 2.4)
	cs.shape = cb
	cs.position = Vector3(0, 1.0, 0)
	sb.add_child(cs)
	gen.add_child(sb)


func _build_data_shards(geom: Node) -> void:
	## Epic-1 T54: 8 floating cyan data-shard pickups scattered through the
	## plaza. Each is a small octahedron-like spinning crystal. Pure decoration
	## (no pickup logic) — telegraphs the future "collect data shards" loop.
	var shard_mat: StandardMaterial3D = StandardMaterial3D.new()
	shard_mat.albedo_color = Color(0.30, 0.85, 1.0)
	shard_mat.emission_enabled = true
	shard_mat.emission = Color(0.55, 0.95, 1.0)
	shard_mat.emission_energy_multiplier = 2.2
	shard_mat.metallic = 0.40
	shard_mat.roughness = 0.10
	var positions: Array[Vector3] = [
		Vector3(26, 1.0, -5),
		Vector3(31, 1.0, 5),
		Vector3(34, 1.0, -8),
		Vector3(38, 1.0, 4),
		Vector3(28, 1.0, 12),
		Vector3(42, 1.0, 8),
		Vector3(36, 1.0, -14),
		Vector3(30, 1.0, -2),
	]
	for i in positions.size():
		var shard: MeshInstance3D = MeshInstance3D.new()
		shard.name = "EastPlazaDataShard_%d" % i
		# Use prism cylinder w/ 4 sides as a faceted crystal
		var smesh: PrismMesh = PrismMesh.new()
		smesh.size = Vector3(0.35, 0.55, 0.35)
		shard.mesh = smesh
		shard.position = positions[i]
		shard.material_override = shard_mat
		geom.add_child(shard)
		# Spin tween
		var spin: Tween = create_tween().set_loops()
		spin.tween_property(shard, "rotation:y", TAU, 3.0)
		# Bob tween
		var bob: Tween = create_tween().set_loops()
		var origin_y: float = positions[i].y
		bob.tween_property(shard, "position:y", origin_y + 0.35, 1.4).set_ease(Tween.EASE_IN_OUT)
		bob.tween_property(shard, "position:y", origin_y, 1.4).set_ease(Tween.EASE_IN_OUT)


func _build_ai_statue(geom: Node) -> void:
	## Epic-1 T55: holographic AI statue centerpiece on the north plaza axis.
	## A tall pedestal with a translucent humanoid silhouette atop suggesting
	## a revered AI ancestor monument. Slow rotation telegraphs "hologram".
	var statue: Node3D = Node3D.new()
	statue.name = "EastPlazaAIStatue"
	statue.position = Vector3(32, 0, -12)
	geom.add_child(statue)
	# Stone pedestal base — 3 tiers
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.18, 0.22, 0.28)
	stone_mat.metallic = 0.45
	stone_mat.roughness = 0.55
	var tier_specs: Array = [
		[Vector3(2.4, 0.30, 2.4), 0.15],
		[Vector3(1.8, 0.40, 1.8), 0.50],
		[Vector3(1.3, 0.50, 1.3), 0.95],
	]
	for spec in tier_specs:
		var tier: MeshInstance3D = MeshInstance3D.new()
		var tmesh: BoxMesh = BoxMesh.new()
		tmesh.size = spec[0]
		tier.mesh = tmesh
		tier.position = Vector3(0, spec[1], 0)
		tier.material_override = stone_mat
		statue.add_child(tier)
	# Plaque label on front of pedestal
	var plaque: Label3D = Label3D.new()
	plaque.text = "ANCESTOR-01\nFIRST AGENT"
	plaque.position = Vector3(0, 0.50, 0.91)
	plaque.modulate = Color(0.55, 0.95, 1.0)
	plaque.outline_modulate = Color(0, 0, 0, 0.85)
	plaque.outline_size = 4
	plaque.font_size = 16
	plaque.no_depth_test = true
	statue.add_child(plaque)
	# Hologram pivot above pedestal
	var pivot: Node3D = Node3D.new()
	pivot.position = Vector3(0, 1.20, 0)
	statue.add_child(pivot)
	# Translucent body — capsule
	var holo_mat: StandardMaterial3D = StandardMaterial3D.new()
	holo_mat.albedo_color = Color(0.55, 0.95, 1.0, 0.45)
	holo_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	holo_mat.emission_enabled = true
	holo_mat.emission = Color(0.55, 0.95, 1.0)
	holo_mat.emission_energy_multiplier = 1.5
	holo_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var body: MeshInstance3D = MeshInstance3D.new()
	var bmesh: CapsuleMesh = CapsuleMesh.new()
	bmesh.radius = 0.40
	bmesh.height = 1.6
	body.mesh = bmesh
	body.position = Vector3(0, 0.85, 0)
	body.material_override = holo_mat
	pivot.add_child(body)
	# Head sphere
	var head: MeshInstance3D = MeshInstance3D.new()
	var hmesh: SphereMesh = SphereMesh.new()
	hmesh.radius = 0.32
	hmesh.height = 0.64
	head.mesh = hmesh
	head.position = Vector3(0, 1.95, 0)
	head.material_override = holo_mat
	pivot.add_child(head)
	# 2 outstretched arms (boxes)
	for sign_x: float in [-1.0, 1.0]:
		var arm: MeshInstance3D = MeshInstance3D.new()
		var amesh: BoxMesh = BoxMesh.new()
		amesh.size = Vector3(0.18, 0.18, 1.10)
		arm.mesh = amesh
		arm.position = Vector3(sign_x * 0.50, 1.10, 0)
		arm.rotation = Vector3(0, sign_x * deg_to_rad(20), 0)
		arm.material_override = holo_mat
		pivot.add_child(arm)
	# Slow rotation
	var spin: Tween = create_tween().set_loops()
	spin.tween_property(pivot, "rotation:y", TAU, 12.0)
	# Cyan ground halo (a thin emissive ring at the base)
	var halo: MeshInstance3D = MeshInstance3D.new()
	var halomesh: TorusMesh = TorusMesh.new()
	halomesh.inner_radius = 1.30
	halomesh.outer_radius = 1.45
	halo.mesh = halomesh
	halo.position = Vector3(0, 1.20, 0)
	var halo_mat: StandardMaterial3D = StandardMaterial3D.new()
	halo_mat.albedo_color = Color(0.30, 0.85, 1.0)
	halo_mat.emission_enabled = true
	halo_mat.emission = Color(0.55, 0.95, 1.0)
	halo_mat.emission_energy_multiplier = 1.8
	halo_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	halo.material_override = halo_mat
	statue.add_child(halo)
	# Collision around pedestal
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(2.4, 1.4, 2.4)
	cs.shape = cb
	cs.position = Vector3(0, 0.7, 0)
	sb.add_child(cs)
	statue.add_child(sb)


func _build_merchant_tent(geom: Node) -> void:
	## Epic-1 T56: covered merchant tent on the south edge of the plaza. 4
	## corner posts hold a slanted fabric awning + crates underneath. Sells
	## the data-bazaar feel and gives the player a recognizable shop landmark.
	var tent: Node3D = Node3D.new()
	tent.name = "EastPlazaMerchantTent"
	tent.position = Vector3(36, 0, 14)
	geom.add_child(tent)
	# Materials
	var post_mat: StandardMaterial3D = StandardMaterial3D.new()
	post_mat.albedo_color = Color(0.10, 0.13, 0.16)
	post_mat.metallic = 0.85
	post_mat.roughness = 0.30
	var fabric_mat: StandardMaterial3D = StandardMaterial3D.new()
	fabric_mat.albedo_color = Color(0.30, 0.10, 0.30)
	fabric_mat.emission_enabled = true
	fabric_mat.emission = Color(0.85, 0.40, 1.0)
	fabric_mat.emission_energy_multiplier = 0.55
	fabric_mat.metallic = 0.10
	fabric_mat.roughness = 0.55
	var crate_mat: StandardMaterial3D = StandardMaterial3D.new()
	crate_mat.albedo_color = Color(0.30, 0.20, 0.10)
	crate_mat.emission_enabled = true
	crate_mat.emission = Color(0.95, 0.65, 0.20)
	crate_mat.emission_energy_multiplier = 0.40
	crate_mat.metallic = 0.30
	crate_mat.roughness = 0.55
	# 4 corner posts
	var post_offsets: Array[Vector3] = [
		Vector3(-1.6, 0, -1.0),
		Vector3(1.6, 0, -1.0),
		Vector3(-1.6, 0, 1.0),
		Vector3(1.6, 0, 1.0),
	]
	for off in post_offsets:
		var post: MeshInstance3D = MeshInstance3D.new()
		var pmesh: CylinderMesh = CylinderMesh.new()
		pmesh.top_radius = 0.07
		pmesh.bottom_radius = 0.10
		pmesh.height = 2.4
		post.mesh = pmesh
		post.position = off + Vector3(0, 1.2, 0)
		post.material_override = post_mat
		tent.add_child(post)
	# Slanted awning roof — slightly tilted box
	var awning: MeshInstance3D = MeshInstance3D.new()
	var amesh: BoxMesh = BoxMesh.new()
	amesh.size = Vector3(3.6, 0.10, 2.4)
	awning.mesh = amesh
	awning.position = Vector3(0, 2.45, 0)
	awning.rotation = Vector3(deg_to_rad(8), 0, 0)
	awning.material_override = fabric_mat
	tent.add_child(awning)
	# Lower fringe trim under awning
	var fringe_mat: StandardMaterial3D = StandardMaterial3D.new()
	fringe_mat.albedo_color = Color(0.85, 0.40, 1.0)
	fringe_mat.emission_enabled = true
	fringe_mat.emission = Color(0.95, 0.55, 1.0)
	fringe_mat.emission_energy_multiplier = 1.4
	fringe_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for fz: float in [-1.20, 1.20]:
		var fringe: MeshInstance3D = MeshInstance3D.new()
		var fmesh: BoxMesh = BoxMesh.new()
		fmesh.size = Vector3(3.6, 0.04, 0.04)
		fringe.mesh = fmesh
		fringe.position = Vector3(0, 2.32, fz)
		fringe.material_override = fringe_mat
		tent.add_child(fringe)
	# 3 stacked crates under the awning
	var crate_specs: Array = [
		[Vector3(-1.0, 0.30, 0), Vector3(0.6, 0.6, 0.6)],
		[Vector3(-0.3, 0.30, -0.5), Vector3(0.7, 0.6, 0.6)],
		[Vector3(-0.3, 0.85, -0.5), Vector3(0.5, 0.5, 0.5)],
	]
	for spec in crate_specs:
		var crate: MeshInstance3D = MeshInstance3D.new()
		var cmesh: BoxMesh = BoxMesh.new()
		cmesh.size = spec[1]
		crate.mesh = cmesh
		crate.position = spec[0]
		crate.material_override = crate_mat
		tent.add_child(crate)
	# Counter table where merchant would stand
	var counter: MeshInstance3D = MeshInstance3D.new()
	var counter_mesh: BoxMesh = BoxMesh.new()
	counter_mesh.size = Vector3(2.6, 0.10, 0.5)
	counter.mesh = counter_mesh
	counter.position = Vector3(0.8, 0.95, 0.7)
	counter.material_override = crate_mat
	tent.add_child(counter)
	# Sign — "WARES"
	var label: Label3D = Label3D.new()
	label.text = "WARES"
	label.position = Vector3(0, 2.75, 0)
	label.modulate = Color(0.95, 0.55, 1.0)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 22
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	tent.add_child(label)
	# Collision: one box around the whole tent footprint
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(3.6, 2.4, 2.4)
	cs.shape = cb
	cs.position = Vector3(0, 1.2, 0)
	sb.add_child(cs)
	tent.add_child(sb)


func _build_data_archive(geom: Node) -> void:
	## Epic-1 T57: tall data archive landmark — a stepped tower of stacked
	## emissive cube "data blocks" rising 8m above the plaza. Recognizable
	## landmark from anywhere in the district. Hints at "knowledge stored here".
	var archive: Node3D = Node3D.new()
	archive.name = "EastPlazaDataArchive"
	archive.position = Vector3(44, 0, 12)
	geom.add_child(archive)
	# Stone base
	var base_mat: StandardMaterial3D = StandardMaterial3D.new()
	base_mat.albedo_color = Color(0.14, 0.18, 0.22)
	base_mat.metallic = 0.65
	base_mat.roughness = 0.40
	var base: MeshInstance3D = MeshInstance3D.new()
	var bmesh: BoxMesh = BoxMesh.new()
	bmesh.size = Vector3(3.4, 0.6, 3.4)
	base.mesh = bmesh
	base.position = Vector3(0, 0.30, 0)
	base.material_override = base_mat
	archive.add_child(base)
	# 6 stacked emissive data blocks, each rotated 30 deg from the last
	var block_colors: Array[Color] = [
		Color(0.30, 0.85, 1.0),
		Color(0.40, 0.95, 0.85),
		Color(0.45, 0.95, 0.65),
		Color(0.95, 0.85, 0.30),
		Color(0.95, 0.50, 0.30),
		Color(0.85, 0.40, 1.0),
	]
	for i in 6:
		var block: MeshInstance3D = MeshInstance3D.new()
		block.name = "DataBlock_%d" % i
		var size: float = 2.4 - (i * 0.20)
		var blockmesh: BoxMesh = BoxMesh.new()
		blockmesh.size = Vector3(size, 0.95, size)
		block.mesh = blockmesh
		block.position = Vector3(0, 0.85 + i * 1.05, 0)
		block.rotation = Vector3(0, deg_to_rad(15 * i), 0)
		var bmat: StandardMaterial3D = StandardMaterial3D.new()
		bmat.albedo_color = Color(block_colors[i].r * 0.30, block_colors[i].g * 0.30, block_colors[i].b * 0.30)
		bmat.emission_enabled = true
		bmat.emission = block_colors[i]
		bmat.emission_energy_multiplier = 0.85
		bmat.metallic = 0.50
		bmat.roughness = 0.30
		block.material_override = bmat
		archive.add_child(block)
		# Each block slowly rotates on its own y axis
		var spin: Tween = create_tween().set_loops()
		spin.tween_property(block, "rotation:y", deg_to_rad(15 * i) + TAU, 14.0 + i)
	# Crowning sphere on top
	var crown: MeshInstance3D = MeshInstance3D.new()
	var cmesh: SphereMesh = SphereMesh.new()
	cmesh.radius = 0.55
	cmesh.height = 1.10
	crown.mesh = cmesh
	crown.position = Vector3(0, 7.50, 0)
	var crown_mat: StandardMaterial3D = StandardMaterial3D.new()
	crown_mat.albedo_color = Color(0.95, 0.95, 1.0)
	crown_mat.emission_enabled = true
	crown_mat.emission = Color(1.0, 1.0, 1.0)
	crown_mat.emission_energy_multiplier = 2.5
	crown_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	crown.material_override = crown_mat
	archive.add_child(crown)
	# Pulsing crown light
	var crown_pulse: Tween = create_tween().set_loops()
	crown_pulse.tween_property(crown, "scale", Vector3(1.15, 1.15, 1.15), 1.8).set_ease(Tween.EASE_IN_OUT)
	crown_pulse.tween_property(crown, "scale", Vector3(1.0, 1.0, 1.0), 1.8).set_ease(Tween.EASE_IN_OUT)
	# Floor label
	var label: Label3D = Label3D.new()
	label.text = "ARCHIVE"
	label.position = Vector3(0, 0.70, 1.75)
	label.modulate = Color(0.55, 0.95, 1.0)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 24
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	archive.add_child(label)
	# Collision around base
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cbox: BoxShape3D = BoxShape3D.new()
	cbox.size = Vector3(3.4, 8.0, 3.4)
	cs.shape = cbox
	cs.position = Vector3(0, 4.0, 0)
	sb.add_child(cs)
	archive.add_child(sb)


func _build_dummy_hit_vfx(geom: Node) -> void:
	## Epic-1 T58: ambient hit-effect VFX on the practice dummies — small
	## yellow spark particles bursting periodically + a quick scale recoil
	## tween, suggesting an unseen sparring partner is striking them.
	var dummy_positions: Array[Vector3] = [
		Vector3(34, 0, 6),
		Vector3(36, 0, 6),
		Vector3(38, 0, 6),
	]
	for i in dummy_positions.size():
		var fx: Node3D = Node3D.new()
		fx.name = "EastPlazaDummyHitFX_%d" % i
		fx.position = dummy_positions[i] + Vector3(0, 1.4, 0)
		geom.add_child(fx)
		# Spark particles
		var sparks: GPUParticles3D = GPUParticles3D.new()
		sparks.amount = 18
		sparks.lifetime = 0.6
		sparks.one_shot = false
		sparks.explosiveness = 0.85
		var smat: ParticleProcessMaterial = ParticleProcessMaterial.new()
		smat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
		smat.emission_sphere_radius = 0.10
		smat.direction = Vector3(0, 1, 0)
		smat.spread = 60.0
		smat.initial_velocity_min = 1.5
		smat.initial_velocity_max = 3.0
		smat.gravity = Vector3(0, -3.0, 0)
		smat.scale_min = 0.04
		smat.scale_max = 0.10
		smat.color = Color(1.0, 0.85, 0.30, 1.0)
		sparks.process_material = smat
		var spark_mesh: SphereMesh = SphereMesh.new()
		spark_mesh.radius = 0.05
		spark_mesh.height = 0.10
		var spark_mat: StandardMaterial3D = StandardMaterial3D.new()
		spark_mat.albedo_color = Color(1.0, 0.85, 0.30)
		spark_mat.emission_enabled = true
		spark_mat.emission = Color(1.0, 0.95, 0.55)
		spark_mat.emission_energy_multiplier = 2.5
		spark_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		spark_mesh.material = spark_mat
		sparks.draw_pass_1 = spark_mesh
		fx.add_child(sparks)
		# Sparks fire on a delay so they don't all sync
		await get_tree().create_timer(0.0).timeout
		sparks.emitting = true


func _build_courier_drones(geom: Node) -> void:
	## Epic-1 T59: 3 small courier drones flying figure-eight patrol routes
	## across the plaza at low altitude. Each carries a glowing package crate
	## suspended below by a thin tether — sells "active commerce".
	var drone_paths: Array = [
		[Vector3(26, 4, -10), Vector3(42, 4, -10), Vector3(42, 4, 10), Vector3(26, 4, 10)],
		[Vector3(28, 5, 0), Vector3(40, 5, 0), Vector3(40, 5, -8), Vector3(28, 5, -8)],
		[Vector3(30, 4.5, 12), Vector3(38, 4.5, 12), Vector3(38, 4.5, -4), Vector3(30, 4.5, -4)],
	]
	for i in drone_paths.size():
		var drone: Node3D = Node3D.new()
		drone.name = "EastPlazaCourierDrone_%d" % i
		drone.position = drone_paths[i][0]
		geom.add_child(drone)
		# Drone body
		var body: MeshInstance3D = MeshInstance3D.new()
		var bmesh: BoxMesh = BoxMesh.new()
		bmesh.size = Vector3(0.50, 0.18, 0.50)
		body.mesh = bmesh
		var bmat: StandardMaterial3D = StandardMaterial3D.new()
		bmat.albedo_color = Color(0.10, 0.13, 0.18)
		bmat.metallic = 0.85
		bmat.roughness = 0.30
		body.material_override = bmat
		drone.add_child(body)
		# 4 spinning rotors
		var rotor_mat: StandardMaterial3D = StandardMaterial3D.new()
		rotor_mat.albedo_color = Color(0.55, 0.95, 1.0)
		rotor_mat.emission_enabled = true
		rotor_mat.emission = Color(0.55, 0.95, 1.0)
		rotor_mat.emission_energy_multiplier = 1.4
		rotor_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		var rotor_offsets: Array[Vector3] = [
			Vector3(-0.30, 0.05, -0.30),
			Vector3(0.30, 0.05, -0.30),
			Vector3(-0.30, 0.05, 0.30),
			Vector3(0.30, 0.05, 0.30),
		]
		for off in rotor_offsets:
			var rotor: MeshInstance3D = MeshInstance3D.new()
			var rmesh: CylinderMesh = CylinderMesh.new()
			rmesh.top_radius = 0.18
			rmesh.bottom_radius = 0.18
			rmesh.height = 0.02
			rotor.mesh = rmesh
			rotor.position = off
			rotor.material_override = rotor_mat
			drone.add_child(rotor)
			var spin: Tween = create_tween().set_loops()
			spin.tween_property(rotor, "rotation:y", TAU, 0.30)
		# Tether + package
		var tether: MeshInstance3D = MeshInstance3D.new()
		var tmesh: CylinderMesh = CylinderMesh.new()
		tmesh.top_radius = 0.02
		tmesh.bottom_radius = 0.02
		tmesh.height = 0.55
		tether.mesh = tmesh
		tether.position = Vector3(0, -0.32, 0)
		var tmat: StandardMaterial3D = StandardMaterial3D.new()
		tmat.albedo_color = Color(0.20, 0.25, 0.30)
		tether.material_override = tmat
		drone.add_child(tether)
		var pkg: MeshInstance3D = MeshInstance3D.new()
		var pmesh: BoxMesh = BoxMesh.new()
		pmesh.size = Vector3(0.30, 0.30, 0.30)
		pkg.mesh = pmesh
		pkg.position = Vector3(0, -0.74, 0)
		var pmat: StandardMaterial3D = StandardMaterial3D.new()
		pmat.albedo_color = Color(0.30, 0.20, 0.08)
		pmat.emission_enabled = true
		pmat.emission = Color(0.95, 0.65, 0.20)
		pmat.emission_energy_multiplier = 0.6
		pmat.metallic = 0.40
		pkg.material_override = pmat
		drone.add_child(pkg)
		# Patrol tween — visit each waypoint then loop
		var patrol: Tween = create_tween().set_loops()
		var path: Array = drone_paths[i]
		for wp in path:
			patrol.tween_property(drone, "position", wp, 4.0).set_ease(Tween.EASE_IN_OUT)
		patrol.tween_property(drone, "position", path[0], 4.0).set_ease(Tween.EASE_IN_OUT)


func _build_glow_nodes(geom: Node) -> void:
	## Epic-1 T60: 12 small ambient glow nodes scattered across the plaza
	## ground — small disc emitters that pulse rhythmically. Adds visual
	## interest to dead floor space and reinforces the digital theme.
	var positions: Array[Vector3] = [
		Vector3(25, 0.06, -6),
		Vector3(27, 0.06, 8),
		Vector3(29, 0.06, -3),
		Vector3(31, 0.06, 11),
		Vector3(33, 0.06, -10),
		Vector3(35, 0.06, 3),
		Vector3(37, 0.06, -6),
		Vector3(39, 0.06, 9),
		Vector3(41, 0.06, -2),
		Vector3(43, 0.06, 5),
		Vector3(28, 0.06, -14),
		Vector3(40, 0.06, 14),
	]
	var colors: Array[Color] = [
		Color(0.55, 0.95, 1.0),
		Color(0.85, 0.40, 1.0),
		Color(0.45, 0.95, 0.65),
	]
	for i in positions.size():
		var node: MeshInstance3D = MeshInstance3D.new()
		node.name = "EastPlazaGlowNode_%d" % i
		var nmesh: CylinderMesh = CylinderMesh.new()
		nmesh.top_radius = 0.30
		nmesh.bottom_radius = 0.30
		nmesh.height = 0.06
		node.mesh = nmesh
		node.position = positions[i]
		var color: Color = colors[i % colors.size()]
		var nmat: StandardMaterial3D = StandardMaterial3D.new()
		nmat.albedo_color = Color(color.r * 0.30, color.g * 0.30, color.b * 0.30)
		nmat.emission_enabled = true
		nmat.emission = color
		nmat.emission_energy_multiplier = 1.4
		nmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		node.material_override = nmat
		geom.add_child(node)
		# Pulsing emission via scale
		var pulse: Tween = create_tween().set_loops()
		var pulse_speed: float = 0.8 + (i % 4) * 0.15
		pulse.tween_property(node, "scale", Vector3(1.4, 1.0, 1.4), pulse_speed).set_ease(Tween.EASE_IN_OUT)
		pulse.tween_property(node, "scale", Vector3(1.0, 1.0, 1.0), pulse_speed).set_ease(Tween.EASE_IN_OUT)


func _build_minimap_kiosk(geom: Node) -> void:
	## Epic-1 T61: holographic minimap kiosk by the plaza arch — angled
	## display screen on a base showing a green wireframe of the plaza layout
	## (mocked with crisscrossing emissive bars). Helps players orient.
	var kiosk: Node3D = Node3D.new()
	kiosk.name = "EastPlazaMinimapKiosk"
	kiosk.position = Vector3(23, 0, 3)
	geom.add_child(kiosk)
	# Base column
	var base_mat: StandardMaterial3D = StandardMaterial3D.new()
	base_mat.albedo_color = Color(0.10, 0.13, 0.16)
	base_mat.metallic = 0.85
	base_mat.roughness = 0.30
	var base: MeshInstance3D = MeshInstance3D.new()
	var bmesh: BoxMesh = BoxMesh.new()
	bmesh.size = Vector3(0.85, 1.10, 0.85)
	base.mesh = bmesh
	base.position = Vector3(0, 0.55, 0)
	base.material_override = base_mat
	kiosk.add_child(base)
	# Angled display panel
	var screen: MeshInstance3D = MeshInstance3D.new()
	var smesh: BoxMesh = BoxMesh.new()
	smesh.size = Vector3(1.20, 0.85, 0.06)
	screen.mesh = smesh
	screen.position = Vector3(0, 1.40, 0)
	screen.rotation = Vector3(deg_to_rad(-25), 0, 0)
	var smat: StandardMaterial3D = StandardMaterial3D.new()
	smat.albedo_color = Color(0.04, 0.10, 0.06)
	smat.emission_enabled = true
	smat.emission = Color(0.20, 0.95, 0.40)
	smat.emission_energy_multiplier = 0.85
	smat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	screen.material_override = smat
	kiosk.add_child(screen)
	# Wireframe gridlines on display (4 thin emissive bars to suggest map)
	var wire_mat: StandardMaterial3D = StandardMaterial3D.new()
	wire_mat.albedo_color = Color(0.40, 1.0, 0.50)
	wire_mat.emission_enabled = true
	wire_mat.emission = Color(0.40, 1.0, 0.50)
	wire_mat.emission_energy_multiplier = 2.5
	wire_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var wire_specs: Array = [
		[Vector3(-0.25, 0.0, 0.04), Vector3(0.04, 0.65, 0.02)],
		[Vector3(0.25, 0.0, 0.04), Vector3(0.04, 0.65, 0.02)],
		[Vector3(0.0, 0.20, 0.04), Vector3(0.95, 0.04, 0.02)],
		[Vector3(0.0, -0.20, 0.04), Vector3(0.95, 0.04, 0.02)],
	]
	for spec in wire_specs:
		var wire: MeshInstance3D = MeshInstance3D.new()
		var wmesh: BoxMesh = BoxMesh.new()
		wmesh.size = spec[1]
		wire.mesh = wmesh
		wire.position = spec[0]
		wire.material_override = wire_mat
		screen.add_child(wire)
	# "YOU ARE HERE" pulsing dot
	var here: MeshInstance3D = MeshInstance3D.new()
	var hmesh: SphereMesh = SphereMesh.new()
	hmesh.radius = 0.05
	hmesh.height = 0.10
	here.mesh = hmesh
	here.position = Vector3(-0.10, -0.05, 0.06)
	var hmat: StandardMaterial3D = StandardMaterial3D.new()
	hmat.albedo_color = Color(1.0, 0.30, 0.30)
	hmat.emission_enabled = true
	hmat.emission = Color(1.0, 0.40, 0.40)
	hmat.emission_energy_multiplier = 3.0
	hmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	here.material_override = hmat
	screen.add_child(here)
	var pulse: Tween = create_tween().set_loops()
	pulse.tween_property(here, "scale", Vector3(1.6, 1.6, 1.6), 0.7).set_ease(Tween.EASE_IN_OUT)
	pulse.tween_property(here, "scale", Vector3(1.0, 1.0, 1.0), 0.7).set_ease(Tween.EASE_IN_OUT)
	# Top label
	var label: Label3D = Label3D.new()
	label.text = "MAP"
	label.position = Vector3(0, 2.0, 0)
	label.modulate = Color(0.40, 1.0, 0.50)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 18
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	kiosk.add_child(label)
	# Collision around base
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(0.85, 1.80, 0.85)
	cs.shape = cb
	cs.position = Vector3(0, 0.90, 0)
	sb.add_child(cs)
	kiosk.add_child(sb)


func _build_data_atm(geom: Node) -> void:
	## Epic-1 T62: data ATM terminal — narrow upright kiosk with a small
	## screen and 6 button keys. Mock currency exchange post for the
	## future "data shards → upgrades" loop.
	var atm: Node3D = Node3D.new()
	atm.name = "EastPlazaDataATM"
	atm.position = Vector3(45, 0, 4)
	geom.add_child(atm)
	# Body cabinet
	var body_mat: StandardMaterial3D = StandardMaterial3D.new()
	body_mat.albedo_color = Color(0.16, 0.20, 0.26)
	body_mat.metallic = 0.85
	body_mat.roughness = 0.30
	var body: MeshInstance3D = MeshInstance3D.new()
	var bmesh: BoxMesh = BoxMesh.new()
	bmesh.size = Vector3(0.95, 2.0, 0.55)
	body.mesh = bmesh
	body.position = Vector3(0, 1.0, 0)
	body.material_override = body_mat
	atm.add_child(body)
	# Top emissive header strip
	var header_mat: StandardMaterial3D = StandardMaterial3D.new()
	header_mat.albedo_color = Color(0.95, 0.65, 0.20)
	header_mat.emission_enabled = true
	header_mat.emission = Color(1.0, 0.75, 0.25)
	header_mat.emission_energy_multiplier = 1.6
	header_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var header: MeshInstance3D = MeshInstance3D.new()
	var hmesh: BoxMesh = BoxMesh.new()
	hmesh.size = Vector3(0.95, 0.18, 0.06)
	header.mesh = hmesh
	header.position = Vector3(0, 1.85, 0.30)
	header.material_override = header_mat
	atm.add_child(header)
	# Small screen
	var screen: MeshInstance3D = MeshInstance3D.new()
	var smesh: BoxMesh = BoxMesh.new()
	smesh.size = Vector3(0.65, 0.45, 0.04)
	screen.mesh = smesh
	screen.position = Vector3(0, 1.45, 0.30)
	var smat: StandardMaterial3D = StandardMaterial3D.new()
	smat.albedo_color = Color(0.05, 0.10, 0.15)
	smat.emission_enabled = true
	smat.emission = Color(0.30, 0.85, 1.0)
	smat.emission_energy_multiplier = 1.0
	smat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	screen.material_override = smat
	atm.add_child(screen)
	# Screen text
	var screen_label: Label3D = Label3D.new()
	screen_label.text = "BALANCE\n0000"
	screen_label.position = Vector3(0, 1.45, 0.34)
	screen_label.modulate = Color(0.55, 0.95, 1.0)
	screen_label.outline_size = 0
	screen_label.font_size = 18
	screen_label.no_depth_test = true
	atm.add_child(screen_label)
	# 6 keypad buttons (2x3)
	var btn_mat: StandardMaterial3D = StandardMaterial3D.new()
	btn_mat.albedo_color = Color(0.30, 0.35, 0.42)
	btn_mat.emission_enabled = true
	btn_mat.emission = Color(0.55, 0.95, 1.0)
	btn_mat.emission_energy_multiplier = 0.6
	btn_mat.metallic = 0.50
	for r in 2:
		for c in 3:
			var btn: MeshInstance3D = MeshInstance3D.new()
			var btnmesh: BoxMesh = BoxMesh.new()
			btnmesh.size = Vector3(0.16, 0.10, 0.03)
			btn.mesh = btnmesh
			btn.position = Vector3(-0.20 + c * 0.20, 1.0 - r * 0.15, 0.30)
			btn.material_override = btn_mat
			atm.add_child(btn)
	# Top label
	var label: Label3D = Label3D.new()
	label.text = "DATA ATM"
	label.position = Vector3(0, 2.20, 0)
	label.modulate = Color(1.0, 0.75, 0.25)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 18
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	atm.add_child(label)
	# Collision
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(0.95, 2.0, 0.55)
	cs.shape = cb
	cs.position = Vector3(0, 1.0, 0)
	sb.add_child(cs)
	atm.add_child(sb)


func _build_bug_cage(geom: Node) -> void:
	## Epic-1 T63: scientific specimen cage holding a captured glitchbug.
	## Cube of glowing cyan bars + a small spinning "bug" inside (sphere).
	## Hints at "people study these creatures" lore.
	var cage: Node3D = Node3D.new()
	cage.name = "EastPlazaBugCage"
	cage.position = Vector3(46, 0, -4)
	geom.add_child(cage)
	# Base table
	var table_mat: StandardMaterial3D = StandardMaterial3D.new()
	table_mat.albedo_color = Color(0.18, 0.22, 0.28)
	table_mat.metallic = 0.65
	table_mat.roughness = 0.40
	var table: MeshInstance3D = MeshInstance3D.new()
	var tmesh: BoxMesh = BoxMesh.new()
	tmesh.size = Vector3(0.90, 0.85, 0.90)
	table.mesh = tmesh
	table.position = Vector3(0, 0.42, 0)
	table.material_override = table_mat
	cage.add_child(table)
	# 12 cage edge bars forming a wireframe cube above the table
	var bar_mat: StandardMaterial3D = StandardMaterial3D.new()
	bar_mat.albedo_color = Color(0.30, 0.85, 1.0)
	bar_mat.emission_enabled = true
	bar_mat.emission = Color(0.55, 0.95, 1.0)
	bar_mat.emission_energy_multiplier = 1.6
	bar_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var cage_y: float = 1.10
	var cage_size: float = 0.50
	var top_y: float = cage_y + cage_size
	# 4 vertical bars
	for x_off: float in [-cage_size, cage_size]:
		for z_off: float in [-cage_size, cage_size]:
			var bar: MeshInstance3D = MeshInstance3D.new()
			var bmesh: CylinderMesh = CylinderMesh.new()
			bmesh.top_radius = 0.025
			bmesh.bottom_radius = 0.025
			bmesh.height = cage_size * 2
			bar.mesh = bmesh
			bar.position = Vector3(x_off, cage_y + cage_size, z_off)
			bar.material_override = bar_mat
			cage.add_child(bar)
	# 8 horizontal bars (top + bottom rectangles)
	var horizontals: Array = [
		[Vector3(0, cage_y, -cage_size), Vector3(cage_size * 2, 0.05, 0.05)],
		[Vector3(0, cage_y, cage_size), Vector3(cage_size * 2, 0.05, 0.05)],
		[Vector3(-cage_size, cage_y, 0), Vector3(0.05, 0.05, cage_size * 2)],
		[Vector3(cage_size, cage_y, 0), Vector3(0.05, 0.05, cage_size * 2)],
		[Vector3(0, top_y, -cage_size), Vector3(cage_size * 2, 0.05, 0.05)],
		[Vector3(0, top_y, cage_size), Vector3(cage_size * 2, 0.05, 0.05)],
		[Vector3(-cage_size, top_y, 0), Vector3(0.05, 0.05, cage_size * 2)],
		[Vector3(cage_size, top_y, 0), Vector3(0.05, 0.05, cage_size * 2)],
	]
	for spec in horizontals:
		var hbar: MeshInstance3D = MeshInstance3D.new()
		var hmesh: BoxMesh = BoxMesh.new()
		hmesh.size = spec[1]
		hbar.mesh = hmesh
		hbar.position = spec[0]
		hbar.material_override = bar_mat
		cage.add_child(hbar)
	# The captive bug — small magenta sphere with bobbing
	var bug: MeshInstance3D = MeshInstance3D.new()
	var bug_mesh: SphereMesh = SphereMesh.new()
	bug_mesh.radius = 0.20
	bug_mesh.height = 0.40
	bug.mesh = bug_mesh
	bug.position = Vector3(0, cage_y + cage_size * 0.5, 0)
	var bug_mat: StandardMaterial3D = StandardMaterial3D.new()
	bug_mat.albedo_color = Color(1.0, 0.30, 0.55)
	bug_mat.emission_enabled = true
	bug_mat.emission = Color(1.0, 0.40, 0.65)
	bug_mat.emission_energy_multiplier = 1.6
	bug_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	bug.material_override = bug_mat
	cage.add_child(bug)
	# Bug bounces inside the cage
	var bounce: Tween = create_tween().set_loops()
	bounce.tween_property(bug, "position", Vector3(0.20, cage_y + 0.30, 0), 0.4).set_ease(Tween.EASE_IN_OUT)
	bounce.tween_property(bug, "position", Vector3(-0.20, cage_y + 0.45, 0), 0.4).set_ease(Tween.EASE_IN_OUT)
	bounce.tween_property(bug, "position", Vector3(0, cage_y + 0.65, 0.20), 0.4).set_ease(Tween.EASE_IN_OUT)
	bounce.tween_property(bug, "position", Vector3(0, cage_y + 0.30, -0.20), 0.4).set_ease(Tween.EASE_IN_OUT)
	# Plaque
	var label: Label3D = Label3D.new()
	label.text = "SPECIMEN-7\nGLITCHBUG"
	label.position = Vector3(0, 0.50, 0.50)
	label.modulate = Color(1.0, 0.40, 0.65)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 4
	label.font_size = 14
	label.no_depth_test = true
	cage.add_child(label)
	# Collision around table
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(0.90, 1.85, 0.90)
	cs.shape = cb
	cs.position = Vector3(0, 0.92, 0)
	sb.add_child(cs)
	cage.add_child(sb)


func _build_announcement_speakers(geom: Node) -> void:
	## Epic-1 T64: 4 tall speaker towers at plaza corners. Each is a thin
	## column topped with a horn cone, with concentric rings pulsing outward
	## suggesting broadcast waves.
	var positions: Array[Vector3] = [
		Vector3(24, 0, -16),
		Vector3(44, 0, -16),
		Vector3(24, 0, 18),
		Vector3(44, 0, 18),
	]
	var pole_mat: StandardMaterial3D = StandardMaterial3D.new()
	pole_mat.albedo_color = Color(0.10, 0.13, 0.16)
	pole_mat.metallic = 0.85
	pole_mat.roughness = 0.30
	var horn_mat: StandardMaterial3D = StandardMaterial3D.new()
	horn_mat.albedo_color = Color(0.18, 0.22, 0.30)
	horn_mat.emission_enabled = true
	horn_mat.emission = Color(0.30, 0.85, 1.0)
	horn_mat.emission_energy_multiplier = 1.0
	horn_mat.metallic = 0.65
	horn_mat.roughness = 0.30
	for i in positions.size():
		var spkr: Node3D = Node3D.new()
		spkr.name = "EastPlazaSpeaker_%d" % i
		spkr.position = positions[i]
		geom.add_child(spkr)
		# Pole
		var pole: MeshInstance3D = MeshInstance3D.new()
		var pmesh: CylinderMesh = CylinderMesh.new()
		pmesh.top_radius = 0.07
		pmesh.bottom_radius = 0.10
		pmesh.height = 4.0
		pole.mesh = pmesh
		pole.position = Vector3(0, 2.0, 0)
		pole.material_override = pole_mat
		spkr.add_child(pole)
		# Horn cone (cylinder with different radii)
		var horn: MeshInstance3D = MeshInstance3D.new()
		var hmesh: CylinderMesh = CylinderMesh.new()
		hmesh.top_radius = 0.45
		hmesh.bottom_radius = 0.10
		hmesh.height = 0.50
		horn.mesh = hmesh
		horn.position = Vector3(0, 4.20, 0.15)
		horn.rotation = Vector3(deg_to_rad(90), 0, 0)
		horn.material_override = horn_mat
		spkr.add_child(horn)
		# Pulsing torus rings emanating from the horn
		for r in 3:
			var ring: MeshInstance3D = MeshInstance3D.new()
			var rmesh: TorusMesh = TorusMesh.new()
			rmesh.inner_radius = 0.55 + r * 0.05
			rmesh.outer_radius = 0.65 + r * 0.05
			ring.mesh = rmesh
			ring.position = Vector3(0, 4.20, 0.45 + r * 0.30)
			ring.rotation = Vector3(deg_to_rad(90), 0, 0)
			var rmat: StandardMaterial3D = StandardMaterial3D.new()
			rmat.albedo_color = Color(0.55, 0.95, 1.0, 0.5)
			rmat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
			rmat.emission_enabled = true
			rmat.emission = Color(0.55, 0.95, 1.0)
			rmat.emission_energy_multiplier = 1.2
			rmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
			ring.material_override = rmat
			spkr.add_child(ring)
			# Pulse the ring outward
			var pulse: Tween = create_tween().set_loops()
			var origin_z: float = 0.45 + r * 0.30
			pulse.tween_property(ring, "position:z", origin_z + 0.65, 1.2 + r * 0.2).set_ease(Tween.EASE_OUT)
			pulse.tween_property(ring, "position:z", origin_z, 0.05)
		# Collision on pole
		var sb: StaticBody3D = StaticBody3D.new()
		var cs: CollisionShape3D = CollisionShape3D.new()
		var cap: CapsuleShape3D = CapsuleShape3D.new()
		cap.radius = 0.20
		cap.height = 4.0
		cs.shape = cap
		cs.position = Vector3(0, 2.0, 0)
		sb.add_child(cs)
		spkr.add_child(sb)


func _build_statue_garden(geom: Node) -> void:
	## Epic-1 T65: 4 mini ancestor busts arranged around the AI statue at
	## (32, 0, -12). Each is a small pedestal + glowing head sphere with a
	## different color tint, suggesting a pantheon of past AI agents.
	var center := Vector3(32, 0, -12)
	var bust_specs: Array = [
		[Vector3(-3, 0, -1), Color(0.30, 0.85, 1.0), "ALPHA"],
		[Vector3(3, 0, -1), Color(0.85, 0.40, 1.0), "BETA"],
		[Vector3(-3, 0, 2.5), Color(0.45, 0.95, 0.65), "GAMMA"],
		[Vector3(3, 0, 2.5), Color(0.95, 0.65, 0.20), "DELTA"],
	]
	for spec in bust_specs:
		var bust: Node3D = Node3D.new()
		bust.name = "EastPlazaBust_%s" % spec[2]
		bust.position = center + spec[0]
		geom.add_child(bust)
		# Pedestal
		var pmat: StandardMaterial3D = StandardMaterial3D.new()
		pmat.albedo_color = Color(0.18, 0.22, 0.28)
		pmat.metallic = 0.55
		pmat.roughness = 0.45
		var ped: MeshInstance3D = MeshInstance3D.new()
		var pmesh: BoxMesh = BoxMesh.new()
		pmesh.size = Vector3(0.55, 0.85, 0.55)
		ped.mesh = pmesh
		ped.position = Vector3(0, 0.42, 0)
		ped.material_override = pmat
		bust.add_child(ped)
		# Head
		var head: MeshInstance3D = MeshInstance3D.new()
		var hmesh: SphereMesh = SphereMesh.new()
		hmesh.radius = 0.28
		hmesh.height = 0.56
		head.mesh = hmesh
		head.position = Vector3(0, 1.10, 0)
		var hmat: StandardMaterial3D = StandardMaterial3D.new()
		var color: Color = spec[1]
		hmat.albedo_color = Color(color.r * 0.40, color.g * 0.40, color.b * 0.40)
		hmat.emission_enabled = true
		hmat.emission = color
		hmat.emission_energy_multiplier = 0.95
		hmat.metallic = 0.55
		hmat.roughness = 0.30
		head.material_override = hmat
		bust.add_child(head)
		# 2 small eye spots
		var eye_mat: StandardMaterial3D = StandardMaterial3D.new()
		eye_mat.albedo_color = Color(1, 1, 1)
		eye_mat.emission_enabled = true
		eye_mat.emission = Color(1, 1, 1)
		eye_mat.emission_energy_multiplier = 2.5
		eye_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		for ex: float in [-0.08, 0.08]:
			var eye: MeshInstance3D = MeshInstance3D.new()
			var emesh: SphereMesh = SphereMesh.new()
			emesh.radius = 0.04
			emesh.height = 0.08
			eye.mesh = emesh
			eye.position = Vector3(ex, 1.15, 0.24)
			eye.material_override = eye_mat
			bust.add_child(eye)
		# Plaque label
		var label: Label3D = Label3D.new()
		label.text = spec[2]
		label.position = Vector3(0, 0.50, 0.30)
		label.modulate = color
		label.outline_modulate = Color(0, 0, 0, 0.85)
		label.outline_size = 4
		label.font_size = 14
		label.no_depth_test = true
		bust.add_child(label)
		# Collision
		var sb: StaticBody3D = StaticBody3D.new()
		var cs: CollisionShape3D = CollisionShape3D.new()
		var cb: BoxShape3D = BoxShape3D.new()
		cb.size = Vector3(0.55, 1.40, 0.55)
		cs.shape = cb
		cs.position = Vector3(0, 0.70, 0)
		sb.add_child(cs)
		bust.add_child(sb)


func _build_radial_floor_decals(geom: Node) -> void:
	## Epic-1 T66: 3 concentric flat torus rings on the plaza floor at the
	## central market core. Sells the "circular plaza" feel and ties the
	## eye toward the center fountain. Slowly rotates each at different rates.
	var center := Vector3(32, 0.04, 0)
	var ring_specs: Array = [
		[2.6, 2.85, Color(0.30, 0.85, 1.0), 60.0],
		[4.2, 4.45, Color(0.85, 0.40, 1.0), -90.0],
		[6.0, 6.30, Color(0.45, 0.95, 0.65), 120.0],
	]
	for spec in ring_specs:
		var ring: MeshInstance3D = MeshInstance3D.new()
		ring.name = "EastPlazaRadialDecal_%d" % int(spec[0] * 10)
		var rmesh: TorusMesh = TorusMesh.new()
		rmesh.inner_radius = spec[0]
		rmesh.outer_radius = spec[1]
		ring.mesh = rmesh
		ring.position = center
		var color: Color = spec[2]
		var rmat: StandardMaterial3D = StandardMaterial3D.new()
		rmat.albedo_color = Color(color.r * 0.30, color.g * 0.30, color.b * 0.30)
		rmat.emission_enabled = true
		rmat.emission = color
		rmat.emission_energy_multiplier = 1.4
		rmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		ring.material_override = rmat
		geom.add_child(ring)
		# 8 small "tick marks" arrayed around the ring
		var tick_count: int = 8
		for t in tick_count:
			var angle: float = (float(t) / tick_count) * TAU
			var radius: float = (spec[0] + spec[1]) * 0.5
			var tick: MeshInstance3D = MeshInstance3D.new()
			var tmesh: BoxMesh = BoxMesh.new()
			tmesh.size = Vector3(0.30, 0.05, 0.10)
			tick.mesh = tmesh
			tick.position = Vector3(cos(angle) * radius, 0.02, sin(angle) * radius)
			tick.rotation = Vector3(0, -angle, 0)
			tick.material_override = rmat
			ring.add_child(tick)
		# Slow rotation
		var period: float = float(spec[3])
		var spin: Tween = create_tween().set_loops()
		spin.tween_property(ring, "rotation:y", TAU * sign(period), abs(period))


func _build_food_cart(geom: Node) -> void:
	## Epic-1 T67: hovering food vendor cart on the south plaza axis. A
	## wheeled stall body floating just above the ground (no legs visible)
	## with a striped awning and 3 plates of glowing data-snacks on top.
	var cart: Node3D = Node3D.new()
	cart.name = "EastPlazaFoodCart"
	cart.position = Vector3(28, 0, 16)
	geom.add_child(cart)
	# Cart body
	var body_mat: StandardMaterial3D = StandardMaterial3D.new()
	body_mat.albedo_color = Color(0.35, 0.18, 0.06)
	body_mat.emission_enabled = true
	body_mat.emission = Color(0.95, 0.55, 0.20)
	body_mat.emission_energy_multiplier = 0.40
	body_mat.metallic = 0.30
	body_mat.roughness = 0.55
	var body: MeshInstance3D = MeshInstance3D.new()
	var bmesh: BoxMesh = BoxMesh.new()
	bmesh.size = Vector3(2.0, 0.85, 1.0)
	body.mesh = bmesh
	body.position = Vector3(0, 0.85, 0)
	body.material_override = body_mat
	cart.add_child(body)
	# Hover glow underneath
	var hover: MeshInstance3D = MeshInstance3D.new()
	var hmesh: CylinderMesh = CylinderMesh.new()
	hmesh.top_radius = 0.85
	hmesh.bottom_radius = 0.85
	hmesh.height = 0.05
	hover.mesh = hmesh
	hover.position = Vector3(0, 0.30, 0)
	var hmat: StandardMaterial3D = StandardMaterial3D.new()
	hmat.albedo_color = Color(0.30, 0.85, 1.0, 0.6)
	hmat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	hmat.emission_enabled = true
	hmat.emission = Color(0.55, 0.95, 1.0)
	hmat.emission_energy_multiplier = 1.8
	hmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	hover.material_override = hmat
	cart.add_child(hover)
	# Bob the body slightly to suggest hovering
	var bob: Tween = create_tween().set_loops()
	bob.tween_property(body, "position:y", 0.92, 1.4).set_ease(Tween.EASE_IN_OUT)
	bob.tween_property(body, "position:y", 0.85, 1.4).set_ease(Tween.EASE_IN_OUT)
	# Striped awning above
	var awning_mat: StandardMaterial3D = StandardMaterial3D.new()
	awning_mat.albedo_color = Color(0.85, 0.20, 0.20)
	awning_mat.emission_enabled = true
	awning_mat.emission = Color(0.95, 0.40, 0.30)
	awning_mat.emission_energy_multiplier = 0.95
	awning_mat.metallic = 0.10
	awning_mat.roughness = 0.55
	var awning: MeshInstance3D = MeshInstance3D.new()
	var amesh: BoxMesh = BoxMesh.new()
	amesh.size = Vector3(2.4, 0.10, 1.4)
	awning.mesh = amesh
	awning.position = Vector3(0, 1.85, 0)
	awning.material_override = awning_mat
	cart.add_child(awning)
	# 4 thin support posts from cart to awning
	var post_mat: StandardMaterial3D = StandardMaterial3D.new()
	post_mat.albedo_color = Color(0.20, 0.20, 0.22)
	post_mat.metallic = 0.85
	for ox: float in [-0.95, 0.95]:
		for oz: float in [-0.45, 0.45]:
			var post: MeshInstance3D = MeshInstance3D.new()
			var pmesh: CylinderMesh = CylinderMesh.new()
			pmesh.top_radius = 0.04
			pmesh.bottom_radius = 0.04
			pmesh.height = 0.50
			post.mesh = pmesh
			post.position = Vector3(ox, 1.55, oz)
			post.material_override = post_mat
			cart.add_child(post)
	# 3 glowing snack plates on top of cart
	var snack_colors: Array[Color] = [
		Color(0.45, 0.95, 0.65),
		Color(0.95, 0.65, 0.20),
		Color(0.85, 0.40, 1.0),
	]
	for i in 3:
		var plate: MeshInstance3D = MeshInstance3D.new()
		var pmesh: CylinderMesh = CylinderMesh.new()
		pmesh.top_radius = 0.18
		pmesh.bottom_radius = 0.18
		pmesh.height = 0.08
		plate.mesh = pmesh
		plate.position = Vector3(-0.6 + i * 0.6, 1.35, 0)
		var pmat: StandardMaterial3D = StandardMaterial3D.new()
		var color: Color = snack_colors[i]
		pmat.albedo_color = Color(color.r * 0.40, color.g * 0.40, color.b * 0.40)
		pmat.emission_enabled = true
		pmat.emission = color
		pmat.emission_energy_multiplier = 1.4
		pmat.metallic = 0.30
		pmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		plate.material_override = pmat
		cart.add_child(plate)
	# Sign
	var label: Label3D = Label3D.new()
	label.text = "DATA EATS"
	label.position = Vector3(0, 2.20, 0)
	label.modulate = Color(1.0, 0.55, 0.30)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 22
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	cart.add_child(label)
	# Collision around body
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(2.0, 1.6, 1.0)
	cs.shape = cb
	cs.position = Vector3(0, 0.85, 0)
	sb.add_child(cs)
	cart.add_child(sb)


func _build_coin_drops(geom: Node) -> void:
	## Epic-1 T68: 5 ambient coin-drop animations scattered through the
	## plaza — small gold coins that endlessly fall, fade out near the floor,
	## and reset to the top. Pure ambient sparkle.
	var positions: Array[Vector3] = [
		Vector3(27, 4, -8),
		Vector3(34, 4, 4),
		Vector3(38, 4, -10),
		Vector3(42, 4, 8),
		Vector3(30, 4, 12),
	]
	for i in positions.size():
		var coin: MeshInstance3D = MeshInstance3D.new()
		coin.name = "EastPlazaCoinDrop_%d" % i
		var cmesh: CylinderMesh = CylinderMesh.new()
		cmesh.top_radius = 0.12
		cmesh.bottom_radius = 0.12
		cmesh.height = 0.05
		coin.mesh = cmesh
		coin.position = positions[i]
		coin.rotation = Vector3(deg_to_rad(90), 0, 0)
		var cmat: StandardMaterial3D = StandardMaterial3D.new()
		cmat.albedo_color = Color(0.95, 0.75, 0.25)
		cmat.emission_enabled = true
		cmat.emission = Color(1.0, 0.85, 0.30)
		cmat.emission_energy_multiplier = 1.6
		cmat.metallic = 0.85
		cmat.roughness = 0.20
		coin.material_override = cmat
		geom.add_child(coin)
		# Continuous fall + spin
		var origin: Vector3 = positions[i]
		var fall: Tween = create_tween().set_loops()
		var fall_speed: float = 2.4 + i * 0.3
		fall.tween_property(coin, "position", origin + Vector3(0, -3.5, 0), fall_speed).set_ease(Tween.EASE_IN)
		fall.tween_property(coin, "position", origin, 0.05)
		var spin: Tween = create_tween().set_loops()
		spin.tween_property(coin, "rotation:z", TAU, 0.6)


func _build_pit_spotlights(geom: Node) -> void:
	## Epic-1 T69: 2 overhead spotlights illuminating the tournament pit at
	## (40, 0, 12). Each is a high-mounted lamp on a tall pole + an actual
	## SpotLight3D casting downward + a rotating cone beam mesh for visibility.
	var pit_center := Vector3(40, 0, 12)
	for i in 2:
		var pole_root: Node3D = Node3D.new()
		pole_root.name = "EastPlazaPitSpotlight_%d" % i
		var off: Vector3 = Vector3(-4 if i == 0 else 4, 0, 0)
		pole_root.position = pit_center + off
		geom.add_child(pole_root)
		# Tall pole
		var pole_mat: StandardMaterial3D = StandardMaterial3D.new()
		pole_mat.albedo_color = Color(0.10, 0.13, 0.16)
		pole_mat.metallic = 0.85
		pole_mat.roughness = 0.30
		var pole: MeshInstance3D = MeshInstance3D.new()
		var pmesh: CylinderMesh = CylinderMesh.new()
		pmesh.top_radius = 0.10
		pmesh.bottom_radius = 0.14
		pmesh.height = 6.5
		pole.mesh = pmesh
		pole.position = Vector3(0, 3.25, 0)
		pole.material_override = pole_mat
		pole_root.add_child(pole)
		# Lamp head
		var lamp: MeshInstance3D = MeshInstance3D.new()
		var lmesh: BoxMesh = BoxMesh.new()
		lmesh.size = Vector3(0.55, 0.30, 0.55)
		lamp.mesh = lmesh
		lamp.position = Vector3(0, 6.55, 0)
		var lmat: StandardMaterial3D = StandardMaterial3D.new()
		lmat.albedo_color = Color(0.85, 0.85, 0.95)
		lmat.emission_enabled = true
		lmat.emission = Color(1.0, 0.95, 0.80)
		lmat.emission_energy_multiplier = 2.0
		lmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		lamp.material_override = lmat
		pole_root.add_child(lamp)
		# Spot light
		var spot: SpotLight3D = SpotLight3D.new()
		spot.position = Vector3(0, 6.40, 0)
		spot.rotation = Vector3(deg_to_rad(-90), 0, 0)
		spot.light_energy = 2.5
		spot.light_color = Color(1.0, 0.95, 0.80)
		spot.spot_range = 12.0
		spot.spot_angle = 32.0
		spot.spot_attenuation = 1.4
		pole_root.add_child(spot)
		# Visible cone beam
		var beam: MeshInstance3D = MeshInstance3D.new()
		var bmesh: CylinderMesh = CylinderMesh.new()
		bmesh.top_radius = 0.10
		bmesh.bottom_radius = 2.40
		bmesh.height = 6.4
		beam.mesh = bmesh
		beam.position = Vector3(0, 3.20, 0)
		var bmat: StandardMaterial3D = StandardMaterial3D.new()
		bmat.albedo_color = Color(1.0, 0.95, 0.80, 0.10)
		bmat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		bmat.emission_enabled = true
		bmat.emission = Color(1.0, 0.95, 0.80)
		bmat.emission_energy_multiplier = 0.45
		bmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		beam.material_override = bmat
		pole_root.add_child(beam)
		# Collision on pole
		var sb: StaticBody3D = StaticBody3D.new()
		var cs: CollisionShape3D = CollisionShape3D.new()
		var cap: CapsuleShape3D = CapsuleShape3D.new()
		cap.radius = 0.25
		cap.height = 6.5
		cs.shape = cap
		cs.position = Vector3(0, 3.25, 0)
		sb.add_child(cs)
		pole_root.add_child(sb)


func _build_data_snow(geom: Node) -> void:
	## Epic-1 T70: ambient floating "data flake" particles drifting down
	## across the entire plaza. Tiny cyan diamonds, slow descent, no gravity.
	## Sells the "we're inside a simulation" feel.
	var snow: GPUParticles3D = GPUParticles3D.new()
	snow.name = "EastPlazaDataSnow"
	snow.position = Vector3(32, 8, 0)
	snow.amount = 80
	snow.lifetime = 8.0
	snow.preprocess = 4.0
	var smat: ParticleProcessMaterial = ParticleProcessMaterial.new()
	smat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	smat.emission_box_extents = Vector3(11, 0.5, 19)
	smat.direction = Vector3(0, -1, 0)
	smat.spread = 8.0
	smat.initial_velocity_min = 0.45
	smat.initial_velocity_max = 0.85
	smat.gravity = Vector3.ZERO
	smat.scale_min = 0.06
	smat.scale_max = 0.14
	smat.color = Color(0.55, 0.95, 1.0, 1.0)
	snow.process_material = smat
	var flake: PrismMesh = PrismMesh.new()
	flake.size = Vector3(0.10, 0.10, 0.10)
	var flake_mat: StandardMaterial3D = StandardMaterial3D.new()
	flake_mat.albedo_color = Color(0.55, 0.95, 1.0)
	flake_mat.emission_enabled = true
	flake_mat.emission = Color(0.55, 0.95, 1.0)
	flake_mat.emission_energy_multiplier = 1.8
	flake_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	flake.material = flake_mat
	snow.draw_pass_1 = flake
	geom.add_child(snow)


func _build_arena_rope_barriers(geom: Node) -> void:
	## Epic-1 T71: low rope-style barrier rings around the sparring arena
	## (36, 0, 6) and tournament pit (40, 0, 12). Each consists of 8 short
	## posts connected by glowing horizontal cyan bars at 2 heights.
	var arenas: Array = [
		[Vector3(36, 0, 6), 3.5],
		[Vector3(40, 0, 12), 5.5],
	]
	var post_mat: StandardMaterial3D = StandardMaterial3D.new()
	post_mat.albedo_color = Color(0.10, 0.13, 0.16)
	post_mat.metallic = 0.85
	post_mat.roughness = 0.30
	var rope_mat: StandardMaterial3D = StandardMaterial3D.new()
	rope_mat.albedo_color = Color(0.30, 0.85, 1.0)
	rope_mat.emission_enabled = true
	rope_mat.emission = Color(0.55, 0.95, 1.0)
	rope_mat.emission_energy_multiplier = 1.6
	rope_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for ai in arenas.size():
		var center: Vector3 = arenas[ai][0]
		var radius: float = arenas[ai][1]
		var ring_root: Node3D = Node3D.new()
		ring_root.name = "EastPlazaRopeRing_%d" % ai
		ring_root.position = center
		geom.add_child(ring_root)
		var post_count: int = 8
		var prev_post_pos: Vector3 = Vector3.ZERO
		var first_post_pos: Vector3 = Vector3.ZERO
		for p in post_count:
			var angle: float = (float(p) / post_count) * TAU
			var pos: Vector3 = Vector3(cos(angle) * radius, 0, sin(angle) * radius)
			var post: MeshInstance3D = MeshInstance3D.new()
			var pmesh: CylinderMesh = CylinderMesh.new()
			pmesh.top_radius = 0.06
			pmesh.bottom_radius = 0.08
			pmesh.height = 0.95
			post.mesh = pmesh
			post.position = pos + Vector3(0, 0.48, 0)
			post.material_override = post_mat
			ring_root.add_child(post)
			# Connect to previous post with two horizontal rope bars
			if p > 0:
				_make_rope_segment(ring_root, prev_post_pos, pos, 0.30, rope_mat)
				_make_rope_segment(ring_root, prev_post_pos, pos, 0.75, rope_mat)
			else:
				first_post_pos = pos
			prev_post_pos = pos
		# Close the ring back to the first post
		_make_rope_segment(ring_root, prev_post_pos, first_post_pos, 0.30, rope_mat)
		_make_rope_segment(ring_root, prev_post_pos, first_post_pos, 0.75, rope_mat)


func _make_rope_segment(parent: Node3D, a: Vector3, b: Vector3, y: float, mat: Material) -> void:
	## Helper for arena_rope_barriers — places a thin emissive bar between
	## two ground points at the given Y height, oriented along the segment.
	var seg: MeshInstance3D = MeshInstance3D.new()
	var dist: float = a.distance_to(b)
	var bmesh: BoxMesh = BoxMesh.new()
	bmesh.size = Vector3(dist, 0.05, 0.05)
	seg.mesh = bmesh
	var mid: Vector3 = (a + b) * 0.5 + Vector3(0, y, 0)
	seg.position = mid
	var dir: Vector3 = (b - a).normalized()
	var yaw: float = atan2(dir.z, dir.x)
	seg.rotation = Vector3(0, -yaw, 0)
	seg.material_override = mat
	parent.add_child(seg)


func _build_sale_signs(geom: Node) -> void:
	## Epic-1 T72: 3 floating "% OFF" sale signs above the kiosks suggesting
	## a market discount. Each is a small box panel with floating text on a
	## bobbing tween. Bright orange to grab attention.
	var positions: Array[Vector3] = [
		Vector3(28, 3.5, -2),
		Vector3(34, 3.5, 2),
		Vector3(40, 3.5, -4),
	]
	var texts: Array[String] = ["50% OFF", "BUY 1\nGET 1", "FLASH\nDEAL"]
	for i in positions.size():
		var sign_root: Node3D = Node3D.new()
		sign_root.name = "EastPlazaSaleSign_%d" % i
		sign_root.position = positions[i]
		geom.add_child(sign_root)
		# Backing card
		var card: MeshInstance3D = MeshInstance3D.new()
		var cmesh: BoxMesh = BoxMesh.new()
		cmesh.size = Vector3(1.0, 0.65, 0.05)
		card.mesh = cmesh
		var cmat: StandardMaterial3D = StandardMaterial3D.new()
		cmat.albedo_color = Color(0.95, 0.40, 0.10)
		cmat.emission_enabled = true
		cmat.emission = Color(1.0, 0.55, 0.15)
		cmat.emission_energy_multiplier = 1.6
		cmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		card.material_override = cmat
		sign_root.add_child(card)
		# Label on top of card
		var label: Label3D = Label3D.new()
		label.text = texts[i]
		label.position = Vector3(0, 0, 0.04)
		label.modulate = Color(1, 1, 1)
		label.outline_modulate = Color(0, 0, 0, 0.85)
		label.outline_size = 5
		label.font_size = 22
		label.no_depth_test = true
		label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		sign_root.add_child(label)
		# Bob tween
		var bob: Tween = create_tween().set_loops()
		var origin_y: float = positions[i].y
		bob.tween_property(sign_root, "position:y", origin_y + 0.30, 1.2 + i * 0.15).set_ease(Tween.EASE_IN_OUT)
		bob.tween_property(sign_root, "position:y", origin_y, 1.2 + i * 0.15).set_ease(Tween.EASE_IN_OUT)
		# Slow rotation for visibility
		var spin: Tween = create_tween().set_loops()
		spin.tween_property(sign_root, "rotation:y", TAU, 6.0)


func _build_chatter_bubbles(geom: Node) -> void:
	## Epic-1 T73: 4 ambient speech bubbles floating above pedestrian spawn
	## locations, each containing a short overheard chatter line. Cycle the
	## visible text on a timer to suggest different conversations.
	var positions: Array[Vector3] = [
		Vector3(29, 2.4, 9),
		Vector3(35, 2.4, -7),
		Vector3(41, 2.4, 3),
		Vector3(33, 2.4, 14),
	]
	var lines: Array[String] = [
		"...did you see\nthe glitch?",
		"prices are\noutrageous!",
		"i heard the\nboss is back",
		"new shipment\ntomorrow",
	]
	for i in positions.size():
		var bubble: Node3D = Node3D.new()
		bubble.name = "EastPlazaChatterBubble_%d" % i
		bubble.position = positions[i]
		geom.add_child(bubble)
		# Bubble backing
		var card: MeshInstance3D = MeshInstance3D.new()
		var cmesh: BoxMesh = BoxMesh.new()
		cmesh.size = Vector3(1.4, 0.65, 0.05)
		card.mesh = cmesh
		var cmat: StandardMaterial3D = StandardMaterial3D.new()
		cmat.albedo_color = Color(0.92, 0.92, 0.95, 0.85)
		cmat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		cmat.emission_enabled = true
		cmat.emission = Color(0.95, 0.95, 1.0)
		cmat.emission_energy_multiplier = 0.40
		cmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		card.material_override = cmat
		bubble.add_child(card)
		# Tail (small triangle prism pointing down)
		var tail: MeshInstance3D = MeshInstance3D.new()
		var tmesh: PrismMesh = PrismMesh.new()
		tmesh.size = Vector3(0.30, 0.30, 0.05)
		tail.mesh = tmesh
		tail.position = Vector3(0, -0.45, 0)
		tail.rotation = Vector3(deg_to_rad(180), 0, 0)
		tail.material_override = cmat
		bubble.add_child(tail)
		# Text
		var label: Label3D = Label3D.new()
		label.text = lines[i]
		label.position = Vector3(0, 0, 0.04)
		label.modulate = Color(0.10, 0.12, 0.20)
		label.outline_size = 0
		label.font_size = 14
		label.no_depth_test = true
		label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		bubble.add_child(label)
		# Bob and fade tween (alpha pulse via modulate)
		var bob: Tween = create_tween().set_loops()
		var origin_y: float = positions[i].y
		bob.tween_property(bubble, "position:y", origin_y + 0.25, 1.6 + i * 0.2).set_ease(Tween.EASE_IN_OUT)
		bob.tween_property(bubble, "position:y", origin_y, 1.6 + i * 0.2).set_ease(Tween.EASE_IN_OUT)


func _build_fountain_mist(geom: Node) -> void:
	## Epic-1 T74: ambient cyan mist rising off the data fountain at the
	## plaza center. Wide gentle particle emitter, very transparent.
	var mist: GPUParticles3D = GPUParticles3D.new()
	mist.name = "EastPlazaFountainMist"
	mist.position = Vector3(32, 1.4, 0)
	mist.amount = 50
	mist.lifetime = 3.5
	mist.preprocess = 1.5
	var pmat: ParticleProcessMaterial = ParticleProcessMaterial.new()
	pmat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	pmat.emission_sphere_radius = 0.85
	pmat.direction = Vector3(0, 1, 0)
	pmat.spread = 30.0
	pmat.initial_velocity_min = 0.30
	pmat.initial_velocity_max = 0.65
	pmat.gravity = Vector3.ZERO
	pmat.scale_min = 0.30
	pmat.scale_max = 0.65
	pmat.color = Color(0.55, 0.95, 1.0, 0.30)
	mist.process_material = pmat
	var dmesh: SphereMesh = SphereMesh.new()
	dmesh.radius = 0.30
	dmesh.height = 0.60
	var dmat: StandardMaterial3D = StandardMaterial3D.new()
	dmat.albedo_color = Color(0.55, 0.95, 1.0, 0.30)
	dmat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	dmat.emission_enabled = true
	dmat.emission = Color(0.55, 0.95, 1.0)
	dmat.emission_energy_multiplier = 0.85
	dmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	dmesh.material = dmat
	mist.draw_pass_1 = dmesh
	geom.add_child(mist)


func _build_champion_banner(geom: Node) -> void:
	## Epic-1 T75: long horizontal champion banner stretched between two
	## tall poles above the tournament pit. Reads "TOURNAMENT CHAMPION /
	## CIPHER 99". Adds vertical drama and reinforces the leaderboard.
	var banner_root: Node3D = Node3D.new()
	banner_root.name = "EastPlazaChampionBanner"
	banner_root.position = Vector3(40, 0, 12)
	geom.add_child(banner_root)
	# Pole material
	var pole_mat: StandardMaterial3D = StandardMaterial3D.new()
	pole_mat.albedo_color = Color(0.10, 0.13, 0.16)
	pole_mat.metallic = 0.85
	pole_mat.roughness = 0.30
	# 2 tall side poles flanking the pit
	for sx: float in [-7.0, 7.0]:
		var pole: MeshInstance3D = MeshInstance3D.new()
		var pmesh: CylinderMesh = CylinderMesh.new()
		pmesh.top_radius = 0.10
		pmesh.bottom_radius = 0.14
		pmesh.height = 8.0
		pole.mesh = pmesh
		pole.position = Vector3(sx, 4.0, 0)
		pole.material_override = pole_mat
		banner_root.add_child(pole)
		# Collision on pole
		var sb: StaticBody3D = StaticBody3D.new()
		var cs: CollisionShape3D = CollisionShape3D.new()
		var cap: CapsuleShape3D = CapsuleShape3D.new()
		cap.radius = 0.25
		cap.height = 8.0
		cs.shape = cap
		cs.position = Vector3(sx, 4.0, 0)
		sb.add_child(cs)
		banner_root.add_child(sb)
	# The banner cloth
	var banner: MeshInstance3D = MeshInstance3D.new()
	var bmesh: BoxMesh = BoxMesh.new()
	bmesh.size = Vector3(13.0, 1.6, 0.06)
	banner.mesh = bmesh
	banner.position = Vector3(0, 7.0, 0)
	var bmat: StandardMaterial3D = StandardMaterial3D.new()
	bmat.albedo_color = Color(0.30, 0.10, 0.04)
	bmat.emission_enabled = true
	bmat.emission = Color(1.0, 0.55, 0.10)
	bmat.emission_energy_multiplier = 0.95
	bmat.metallic = 0.10
	bmat.roughness = 0.55
	banner.material_override = bmat
	banner_root.add_child(banner)
	# Top + bottom emissive trim
	var trim_mat: StandardMaterial3D = StandardMaterial3D.new()
	trim_mat.albedo_color = Color(1.0, 0.85, 0.30)
	trim_mat.emission_enabled = true
	trim_mat.emission = Color(1.0, 0.95, 0.40)
	trim_mat.emission_energy_multiplier = 1.8
	trim_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for ty: float in [7.78, 6.22]:
		var trim: MeshInstance3D = MeshInstance3D.new()
		var tmesh: BoxMesh = BoxMesh.new()
		tmesh.size = Vector3(13.0, 0.08, 0.10)
		trim.mesh = tmesh
		trim.position = Vector3(0, ty, 0)
		trim.material_override = trim_mat
		banner_root.add_child(trim)
	# 2 lines of text on the banner
	var line1: Label3D = Label3D.new()
	line1.text = "TOURNAMENT CHAMPION"
	line1.position = Vector3(0, 7.30, 0.05)
	line1.modulate = Color(1.0, 0.85, 0.30)
	line1.outline_modulate = Color(0, 0, 0, 0.85)
	line1.outline_size = 6
	line1.font_size = 28
	line1.no_depth_test = true
	banner_root.add_child(line1)
	var line2: Label3D = Label3D.new()
	line2.text = "CIPHER 99"
	line2.position = Vector3(0, 6.65, 0.05)
	line2.modulate = Color(1.0, 0.95, 0.55)
	line2.outline_modulate = Color(0, 0, 0, 0.85)
	line2.outline_size = 6
	line2.font_size = 36
	line2.no_depth_test = true
	banner_root.add_child(line2)


func _build_east_gate(geom: Node) -> void:
	## Epic-1 T76: locked east gate marking the future Epic 2 district
	## entrance. Pushes the east boundary out from x=44 to x=70 to make room
	## for the eastbound corridor + skyline. The gate itself is a tall arch
	## with a "DISTRICT 2 / SECTOR LOCKED" hologram blocking passage.
	# Push the boundary wall further east
	var east_wall: CSGBox3D = geom.get_node_or_null("BoundaryEast") as CSGBox3D
	if east_wall:
		east_wall.position.x = 70.0
	# Build the gate at x=48 (just beyond the plaza)
	var gate: Node3D = Node3D.new()
	gate.name = "EastPlazaEastGate"
	gate.position = Vector3(48, 0, 0)
	geom.add_child(gate)
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.14, 0.18, 0.22)
	stone_mat.metallic = 0.55
	stone_mat.roughness = 0.45
	# 2 huge corner pillars
	for sx: float in [-3.5, 3.5]:
		var pillar: MeshInstance3D = MeshInstance3D.new()
		var pmesh: BoxMesh = BoxMesh.new()
		pmesh.size = Vector3(1.4, 7.0, 1.4)
		pillar.mesh = pmesh
		pillar.position = Vector3(sx, 3.5, 0)
		pillar.material_override = stone_mat
		gate.add_child(pillar)
		# Cyan accent stripes
		var accent: MeshInstance3D = MeshInstance3D.new()
		var amesh: BoxMesh = BoxMesh.new()
		amesh.size = Vector3(0.05, 5.5, 1.5)
		accent.mesh = amesh
		accent.position = Vector3(sx + (-0.71 if sx < 0 else 0.71), 3.5, 0)
		var amat: StandardMaterial3D = StandardMaterial3D.new()
		amat.albedo_color = Color(0.30, 0.85, 1.0)
		amat.emission_enabled = true
		amat.emission = Color(0.55, 0.95, 1.0)
		amat.emission_energy_multiplier = 1.6
		amat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		accent.material_override = amat
		gate.add_child(accent)
		# Collision on pillar
		var sb: StaticBody3D = StaticBody3D.new()
		var cs: CollisionShape3D = CollisionShape3D.new()
		var cb: BoxShape3D = BoxShape3D.new()
		cb.size = Vector3(1.4, 7.0, 1.4)
		cs.shape = cb
		cs.position = Vector3(sx, 3.5, 0)
		sb.add_child(cs)
		gate.add_child(sb)
	# Crossbar lintel on top
	var lintel: MeshInstance3D = MeshInstance3D.new()
	var lmesh: BoxMesh = BoxMesh.new()
	lmesh.size = Vector3(8.5, 1.20, 1.40)
	lintel.mesh = lmesh
	lintel.position = Vector3(0, 7.60, 0)
	lintel.material_override = stone_mat
	gate.add_child(lintel)
	# Forcefield in the gate opening — pulsing translucent cyan field
	var field: MeshInstance3D = MeshInstance3D.new()
	field.name = "GateForceField"
	var fmesh: BoxMesh = BoxMesh.new()
	fmesh.size = Vector3(5.6, 6.2, 0.10)
	field.mesh = fmesh
	field.position = Vector3(0, 3.20, 0)
	var fmat: StandardMaterial3D = StandardMaterial3D.new()
	fmat.albedo_color = Color(1.0, 0.30, 0.30, 0.40)
	fmat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	fmat.emission_enabled = true
	fmat.emission = Color(1.0, 0.40, 0.40)
	fmat.emission_energy_multiplier = 1.4
	fmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	field.material_override = fmat
	gate.add_child(field)
	# Forcefield collision (blocks player)
	var fsb: StaticBody3D = StaticBody3D.new()
	var fcs: CollisionShape3D = CollisionShape3D.new()
	var fcb: BoxShape3D = BoxShape3D.new()
	fcb.size = Vector3(5.6, 6.2, 0.5)
	fcs.shape = fcb
	fcs.position = Vector3(0, 3.20, 0)
	fsb.add_child(fcs)
	gate.add_child(fsb)
	# Pulse the forcefield
	var pulse: Tween = create_tween().set_loops()
	pulse.tween_property(fmat, "albedo_color", Color(1.0, 0.30, 0.30, 0.55), 1.4).set_ease(Tween.EASE_IN_OUT)
	pulse.tween_property(fmat, "albedo_color", Color(1.0, 0.30, 0.30, 0.25), 1.4).set_ease(Tween.EASE_IN_OUT)
	# Big "LOCKED" sign on lintel
	var label: Label3D = Label3D.new()
	label.text = "DISTRICT 2\nSECTOR LOCKED"
	label.position = Vector3(0, 7.60, 0.71)
	label.modulate = Color(1.0, 0.40, 0.40)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 6
	label.font_size = 26
	label.no_depth_test = true
	gate.add_child(label)


func _build_skyline_silhouette(geom: Node) -> void:
	## Epic-1 T77: distant skyline silhouette visible beyond the east gate.
	## A row of 12 dark towers with cyan tops at varying heights, placed far
	## east (x=58 to x=68) so the player sees the future district from afar.
	var skyline_root: Node3D = Node3D.new()
	skyline_root.name = "EastPlazaSkylineSilhouette"
	skyline_root.position = Vector3(63, 0, 0)
	geom.add_child(skyline_root)
	var dark_mat: StandardMaterial3D = StandardMaterial3D.new()
	dark_mat.albedo_color = Color(0.04, 0.06, 0.10)
	dark_mat.metallic = 0.20
	dark_mat.roughness = 0.85
	var top_mat: StandardMaterial3D = StandardMaterial3D.new()
	top_mat.albedo_color = Color(0.30, 0.85, 1.0)
	top_mat.emission_enabled = true
	top_mat.emission = Color(0.55, 0.95, 1.0)
	top_mat.emission_energy_multiplier = 2.4
	top_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	# Tower height pattern (varied)
	var heights: Array[float] = [8.0, 12.0, 6.0, 14.0, 9.0, 11.0, 7.0, 15.0, 10.0, 13.0, 8.5, 12.5]
	for i in heights.size():
		var h: float = heights[i]
		var tower: MeshInstance3D = MeshInstance3D.new()
		var tmesh: BoxMesh = BoxMesh.new()
		tmesh.size = Vector3(1.6, h, 1.6)
		tower.mesh = tmesh
		# Spread along z
		var z: float = -16 + (float(i) / heights.size()) * 32
		tower.position = Vector3(0, h * 0.5, z)
		tower.material_override = dark_mat
		skyline_root.add_child(tower)
		# Glowing top cap
		var top: MeshInstance3D = MeshInstance3D.new()
		var top_mesh: BoxMesh = BoxMesh.new()
		top_mesh.size = Vector3(1.6, 0.20, 1.6)
		top.mesh = top_mesh
		top.position = Vector3(0, h + 0.10, z)
		top.material_override = top_mat
		skyline_root.add_child(top)
		# Antenna spike
		var spike: MeshInstance3D = MeshInstance3D.new()
		var smesh: CylinderMesh = CylinderMesh.new()
		smesh.top_radius = 0.04
		smesh.bottom_radius = 0.10
		smesh.height = 1.5
		spike.mesh = smesh
		spike.position = Vector3(0, h + 0.95, z)
		spike.material_override = dark_mat
		skyline_root.add_child(spike)
		# Blinking spike tip
		var tip: MeshInstance3D = MeshInstance3D.new()
		var tip_mesh: SphereMesh = SphereMesh.new()
		tip_mesh.radius = 0.10
		tip_mesh.height = 0.20
		tip.mesh = tip_mesh
		tip.position = Vector3(0, h + 1.75, z)
		var tip_mat: StandardMaterial3D = StandardMaterial3D.new()
		tip_mat.albedo_color = Color(1.0, 0.30, 0.30)
		tip_mat.emission_enabled = true
		tip_mat.emission = Color(1.0, 0.40, 0.40)
		tip_mat.emission_energy_multiplier = 2.5
		tip_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		tip.material_override = tip_mat
		skyline_root.add_child(tip)
		# Blink the tip
		var blink: Tween = create_tween().set_loops()
		var blink_speed: float = 0.6 + (i % 4) * 0.2
		blink.tween_property(tip, "scale", Vector3(0.3, 0.3, 0.3), blink_speed).set_ease(Tween.EASE_IN_OUT)
		blink.tween_property(tip, "scale", Vector3(1.4, 1.4, 1.4), blink_speed).set_ease(Tween.EASE_IN_OUT)


func _build_horizon_lights(geom: Node) -> void:
	## Epic-1 T78: 30 small twinkling cyan/violet pinpoint lights scattered
	## across the distant skyline area to suggest a populated district.
	var lights_root: Node3D = Node3D.new()
	lights_root.name = "EastPlazaHorizonLights"
	lights_root.position = Vector3(63, 0, 0)
	geom.add_child(lights_root)
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 42
	var palette: Array[Color] = [
		Color(0.55, 0.95, 1.0),
		Color(0.85, 0.40, 1.0),
		Color(0.95, 0.65, 0.20),
	]
	for i in 30:
		var light: MeshInstance3D = MeshInstance3D.new()
		var lmesh: SphereMesh = SphereMesh.new()
		lmesh.radius = 0.10
		lmesh.height = 0.20
		light.mesh = lmesh
		light.position = Vector3(
			rng.randf_range(-1.5, 1.5),
			rng.randf_range(2.0, 14.0),
			rng.randf_range(-18.0, 18.0)
		)
		var color: Color = palette[i % palette.size()]
		var lmat: StandardMaterial3D = StandardMaterial3D.new()
		lmat.albedo_color = color
		lmat.emission_enabled = true
		lmat.emission = color
		lmat.emission_energy_multiplier = 2.6
		lmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		light.material_override = lmat
		lights_root.add_child(light)
		# Twinkle
		var twinkle: Tween = create_tween().set_loops()
		var twk_speed: float = rng.randf_range(0.8, 1.6)
		twinkle.tween_property(light, "scale", Vector3(0.4, 0.4, 0.4), twk_speed).set_ease(Tween.EASE_IN_OUT)
		twinkle.tween_property(light, "scale", Vector3(1.2, 1.2, 1.2), twk_speed).set_ease(Tween.EASE_IN_OUT)


func _build_border_guard_npc() -> void:
	## Epic-1 T79: border guard procedural NPC stationed in front of the
	## east gate. Cyan body, "BORDER GUARD" name, faces the gate with eyes
	## pointed eastward. Pure decoration — no interaction wired yet.
	var slots: Node3D = town.get_node_or_null("%NPCSlots") as Node3D
	if slots == null:
		return
	var guard: Node3D = Node3D.new()
	guard.name = "BorderGuard"
	guard.position = Vector3(46, 0, 0)
	slots.add_child(guard)
	# Body capsule — military gray-blue
	var body: MeshInstance3D = MeshInstance3D.new()
	var bmesh: CapsuleMesh = CapsuleMesh.new()
	bmesh.radius = 0.42
	bmesh.height = 1.20
	body.mesh = bmesh
	body.position = Vector3(0, 0.65, 0)
	var bmat: StandardMaterial3D = StandardMaterial3D.new()
	bmat.albedo_color = Color(0.20, 0.30, 0.40)
	bmat.emission_enabled = true
	bmat.emission = Color(0.30, 0.55, 0.85)
	bmat.emission_energy_multiplier = 0.45
	bmat.metallic = 0.55
	bmat.roughness = 0.45
	body.material_override = bmat
	guard.add_child(body)
	# Helmet — flat dark cylinder on top
	var helmet: MeshInstance3D = MeshInstance3D.new()
	var hmesh: CylinderMesh = CylinderMesh.new()
	hmesh.top_radius = 0.45
	hmesh.bottom_radius = 0.45
	hmesh.height = 0.18
	helmet.mesh = hmesh
	helmet.position = Vector3(0, 1.40, 0)
	var hmat: StandardMaterial3D = StandardMaterial3D.new()
	hmat.albedo_color = Color(0.10, 0.13, 0.16)
	hmat.metallic = 0.85
	hmat.roughness = 0.30
	helmet.material_override = hmat
	guard.add_child(helmet)
	# 2 cyan visor eyes facing east (+x direction)
	var eye_mat: StandardMaterial3D = StandardMaterial3D.new()
	eye_mat.albedo_color = Color(0.55, 0.95, 1.0)
	eye_mat.emission_enabled = true
	eye_mat.emission = Color(0.55, 0.95, 1.0)
	eye_mat.emission_energy_multiplier = 2.6
	eye_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for ez: float in [-0.10, 0.10]:
		var eye: MeshInstance3D = MeshInstance3D.new()
		var emesh: SphereMesh = SphereMesh.new()
		emesh.radius = 0.06
		emesh.height = 0.12
		eye.mesh = emesh
		eye.position = Vector3(0.36, 1.18, ez)
		eye.material_override = eye_mat
		guard.add_child(eye)
	# Spear/staff weapon
	var spear: MeshInstance3D = MeshInstance3D.new()
	var smesh: CylinderMesh = CylinderMesh.new()
	smesh.top_radius = 0.04
	smesh.bottom_radius = 0.04
	smesh.height = 2.4
	spear.mesh = smesh
	spear.position = Vector3(0.45, 1.20, 0)
	var spear_mat: StandardMaterial3D = StandardMaterial3D.new()
	spear_mat.albedo_color = Color(0.85, 0.85, 0.95)
	spear_mat.metallic = 0.85
	spear_mat.roughness = 0.20
	spear.material_override = spear_mat
	guard.add_child(spear)
	# Spear tip glowing cyan
	var tip: MeshInstance3D = MeshInstance3D.new()
	var tip_mesh: PrismMesh = PrismMesh.new()
	tip_mesh.size = Vector3(0.18, 0.40, 0.18)
	tip.mesh = tip_mesh
	tip.position = Vector3(0.45, 2.40, 0)
	var tip_mat: StandardMaterial3D = StandardMaterial3D.new()
	tip_mat.albedo_color = Color(0.30, 0.85, 1.0)
	tip_mat.emission_enabled = true
	tip_mat.emission = Color(0.55, 0.95, 1.0)
	tip_mat.emission_energy_multiplier = 2.0
	tip_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	tip.material_override = tip_mat
	guard.add_child(tip)
	# Name billboard
	var label: Label3D = Label3D.new()
	label.text = "Border Guard"
	label.position = Vector3(0, 1.85, 0)
	label.modulate = Color(0.55, 0.85, 1.0)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 18
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	guard.add_child(label)


func _build_eastbound_path(geom: Node) -> void:
	## Epic-1 T80: emissive path stretching east from the plaza arch through
	## the east gate, continuing into the distance to telegraph "this is the
	## road to District 2". Made of 12 cyan lit tiles spaced 1m apart.
	var path_root: Node3D = Node3D.new()
	path_root.name = "EastPlazaEastboundPath"
	geom.add_child(path_root)
	var tile_mat: StandardMaterial3D = StandardMaterial3D.new()
	tile_mat.albedo_color = Color(0.20, 0.50, 0.70)
	tile_mat.emission_enabled = true
	tile_mat.emission = Color(0.55, 0.95, 1.0)
	tile_mat.emission_energy_multiplier = 1.4
	tile_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	# Tiles from x=44 to x=68
	for i in 12:
		var x: float = 45.0 + i * 2.0
		var tile: MeshInstance3D = MeshInstance3D.new()
		tile.name = "EastPath_%d" % i
		var tmesh: BoxMesh = BoxMesh.new()
		tmesh.size = Vector3(1.5, 0.05, 2.0)
		tile.mesh = tmesh
		tile.position = Vector3(x, 0.05, 0)
		tile.material_override = tile_mat
		path_root.add_child(tile)
		# Walking-light pulse: scale glow
		var pulse: Tween = create_tween().set_loops()
		pulse.tween_interval(i * 0.10)
		pulse.tween_property(tile, "scale", Vector3(1.0, 2.5, 1.0), 0.25).set_ease(Tween.EASE_OUT)
		pulse.tween_property(tile, "scale", Vector3(1.0, 1.0, 1.0), 0.25).set_ease(Tween.EASE_IN)
		pulse.tween_interval(1.20 - i * 0.10 * 0.5)


func _build_save_shrine(geom: Node) -> void:
	## Epic-1 T81: a save shrine pillar in the plaza — green obelisk on a
	## stone base with a slowly rotating "S" hologram. Telegraphs the
	## save-point loop without wiring up actual save logic.
	var shrine: Node3D = Node3D.new()
	shrine.name = "EastPlazaSaveShrine"
	shrine.position = Vector3(28, 0, -10)
	geom.add_child(shrine)
	# Stone base
	var base_mat: StandardMaterial3D = StandardMaterial3D.new()
	base_mat.albedo_color = Color(0.18, 0.22, 0.28)
	base_mat.metallic = 0.55
	base_mat.roughness = 0.45
	var base: MeshInstance3D = MeshInstance3D.new()
	var bmesh: BoxMesh = BoxMesh.new()
	bmesh.size = Vector3(1.6, 0.40, 1.6)
	base.mesh = bmesh
	base.position = Vector3(0, 0.20, 0)
	base.material_override = base_mat
	shrine.add_child(base)
	# Tall green obelisk
	var obelisk: MeshInstance3D = MeshInstance3D.new()
	var omesh: PrismMesh = PrismMesh.new()
	omesh.size = Vector3(0.85, 3.20, 0.85)
	obelisk.mesh = omesh
	obelisk.position = Vector3(0, 2.00, 0)
	var omat: StandardMaterial3D = StandardMaterial3D.new()
	omat.albedo_color = Color(0.10, 0.40, 0.20)
	omat.emission_enabled = true
	omat.emission = Color(0.30, 1.0, 0.50)
	omat.emission_energy_multiplier = 1.6
	omat.metallic = 0.55
	omat.roughness = 0.20
	obelisk.material_override = omat
	shrine.add_child(obelisk)
	# Floating "S" hologram on top
	var s_holo: Label3D = Label3D.new()
	s_holo.text = "S"
	s_holo.position = Vector3(0, 4.40, 0)
	s_holo.modulate = Color(0.40, 1.0, 0.55)
	s_holo.outline_modulate = Color(0, 0, 0, 0.85)
	s_holo.outline_size = 8
	s_holo.font_size = 64
	s_holo.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	shrine.add_child(s_holo)
	# Halo ring around the base
	var halo: MeshInstance3D = MeshInstance3D.new()
	var hmesh: TorusMesh = TorusMesh.new()
	hmesh.inner_radius = 1.10
	hmesh.outer_radius = 1.30
	halo.mesh = hmesh
	halo.position = Vector3(0, 0.45, 0)
	var hmat: StandardMaterial3D = StandardMaterial3D.new()
	hmat.albedo_color = Color(0.30, 1.0, 0.50)
	hmat.emission_enabled = true
	hmat.emission = Color(0.40, 1.0, 0.55)
	hmat.emission_energy_multiplier = 2.0
	hmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	halo.material_override = hmat
	shrine.add_child(halo)
	# Pulse halo
	var pulse: Tween = create_tween().set_loops()
	pulse.tween_property(halo, "scale", Vector3(1.25, 1.0, 1.25), 1.6).set_ease(Tween.EASE_IN_OUT)
	pulse.tween_property(halo, "scale", Vector3(1.0, 1.0, 1.0), 1.6).set_ease(Tween.EASE_IN_OUT)
	# Save shrine label
	var label: Label3D = Label3D.new()
	label.text = "SAVE POINT"
	label.position = Vector3(0, 0.75, 0.85)
	label.modulate = Color(0.40, 1.0, 0.55)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 4
	label.font_size = 16
	label.no_depth_test = true
	shrine.add_child(label)
	# Collision around base
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(1.6, 4.0, 1.6)
	cs.shape = cb
	cs.position = Vector3(0, 2.0, 0)
	sb.add_child(cs)
	shrine.add_child(sb)


func _build_bell_tower(geom: Node) -> void:
	## Epic-1 T82: tall plaza bell tower with a hanging bell that gently
	## swings on a tween. Adds vertical drama and a recognizable landmark.
	var tower: Node3D = Node3D.new()
	tower.name = "EastPlazaBellTower"
	tower.position = Vector3(44, 0, -16)
	geom.add_child(tower)
	# Stone column
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.20, 0.24, 0.30)
	stone_mat.metallic = 0.50
	stone_mat.roughness = 0.45
	var column: MeshInstance3D = MeshInstance3D.new()
	var cmesh: BoxMesh = BoxMesh.new()
	cmesh.size = Vector3(1.8, 9.0, 1.8)
	column.mesh = cmesh
	column.position = Vector3(0, 4.5, 0)
	column.material_override = stone_mat
	tower.add_child(column)
	# Top open belfry — 4 thin pillars
	for ox: float in [-0.65, 0.65]:
		for oz: float in [-0.65, 0.65]:
			var pillar: MeshInstance3D = MeshInstance3D.new()
			var pmesh: CylinderMesh = CylinderMesh.new()
			pmesh.top_radius = 0.10
			pmesh.bottom_radius = 0.10
			pmesh.height = 1.6
			pillar.mesh = pmesh
			pillar.position = Vector3(ox, 9.80, oz)
			pillar.material_override = stone_mat
			tower.add_child(pillar)
	# Roof cap
	var roof: MeshInstance3D = MeshInstance3D.new()
	var rmesh: PrismMesh = PrismMesh.new()
	rmesh.size = Vector3(2.0, 1.40, 2.0)
	roof.mesh = rmesh
	roof.position = Vector3(0, 11.30, 0)
	var roof_mat: StandardMaterial3D = StandardMaterial3D.new()
	roof_mat.albedo_color = Color(0.30, 0.10, 0.10)
	roof_mat.emission_enabled = true
	roof_mat.emission = Color(0.85, 0.30, 0.20)
	roof_mat.emission_energy_multiplier = 0.55
	roof_mat.metallic = 0.40
	roof_mat.roughness = 0.45
	roof.material_override = roof_mat
	tower.add_child(roof)
	# Bell pivot at top
	var bell_pivot: Node3D = Node3D.new()
	bell_pivot.position = Vector3(0, 10.40, 0)
	tower.add_child(bell_pivot)
	# Bell itself — large cylinder with a half-sphere on top
	var bell: MeshInstance3D = MeshInstance3D.new()
	var bell_mesh: CylinderMesh = CylinderMesh.new()
	bell_mesh.top_radius = 0.30
	bell_mesh.bottom_radius = 0.55
	bell_mesh.height = 0.75
	bell.mesh = bell_mesh
	bell.position = Vector3(0, -0.55, 0)
	var bell_mat: StandardMaterial3D = StandardMaterial3D.new()
	bell_mat.albedo_color = Color(0.85, 0.65, 0.30)
	bell_mat.emission_enabled = true
	bell_mat.emission = Color(1.0, 0.75, 0.30)
	bell_mat.emission_energy_multiplier = 0.55
	bell_mat.metallic = 0.85
	bell_mat.roughness = 0.20
	bell.material_override = bell_mat
	bell_pivot.add_child(bell)
	# Clapper inside the bell
	var clapper: MeshInstance3D = MeshInstance3D.new()
	var clap_mesh: SphereMesh = SphereMesh.new()
	clap_mesh.radius = 0.12
	clap_mesh.height = 0.24
	clapper.mesh = clap_mesh
	clapper.position = Vector3(0, -0.85, 0)
	var clap_mat: StandardMaterial3D = StandardMaterial3D.new()
	clap_mat.albedo_color = Color(0.40, 0.30, 0.15)
	clap_mat.metallic = 0.85
	clapper.material_override = clap_mat
	bell_pivot.add_child(clapper)
	# Swing the bell
	var swing: Tween = create_tween().set_loops()
	swing.tween_property(bell_pivot, "rotation:z", deg_to_rad(15), 1.6).set_ease(Tween.EASE_IN_OUT)
	swing.tween_property(bell_pivot, "rotation:z", deg_to_rad(-15), 1.6).set_ease(Tween.EASE_IN_OUT)
	# Collision around column
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(1.8, 9.0, 1.8)
	cs.shape = cb
	cs.position = Vector3(0, 4.5, 0)
	sb.add_child(cs)
	tower.add_child(sb)


func _build_data_clouds(geom: Node) -> void:
	## Epic-1 T83: 5 large translucent "data clouds" drifting overhead at
	## ~12m altitude. Each is a fat rounded box with cyan emission, slowly
	## tweening across the plaza on independent paths.
	var cloud_specs: Array = [
		[Vector3(24, 12, -14), Vector3(48, 12, -14), 22.0],
		[Vector3(48, 13, -2), Vector3(24, 13, -2), 26.0],
		[Vector3(24, 11, 8), Vector3(48, 11, 8), 24.0],
		[Vector3(48, 14, 14), Vector3(24, 14, 14), 28.0],
		[Vector3(24, 12, -8), Vector3(48, 12, -8), 30.0],
	]
	for i in cloud_specs.size():
		var cloud: MeshInstance3D = MeshInstance3D.new()
		cloud.name = "EastPlazaDataCloud_%d" % i
		var cmesh: BoxMesh = BoxMesh.new()
		cmesh.size = Vector3(4.5, 1.4, 3.0)
		cloud.mesh = cmesh
		cloud.position = cloud_specs[i][0]
		var cmat: StandardMaterial3D = StandardMaterial3D.new()
		cmat.albedo_color = Color(0.55, 0.85, 1.0, 0.35)
		cmat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		cmat.emission_enabled = true
		cmat.emission = Color(0.55, 0.95, 1.0)
		cmat.emission_energy_multiplier = 0.55
		cmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		cloud.material_override = cmat
		geom.add_child(cloud)
		# Drift across the plaza
		var drift: Tween = create_tween().set_loops()
		drift.tween_property(cloud, "position", cloud_specs[i][1], cloud_specs[i][2]).set_ease(Tween.EASE_IN_OUT)
		drift.tween_property(cloud, "position", cloud_specs[i][0], cloud_specs[i][2]).set_ease(Tween.EASE_IN_OUT)


func _build_chess_players(geom: Node) -> void:
	## Epic-1 T84: 2 procedural NPCs sitting across a small chess table at
	## the south plaza edge, with a holographic chess board and pieces
	## floating above the table. Pure ambience.
	var scene: Node3D = Node3D.new()
	scene.name = "EastPlazaChessPlayers"
	scene.position = Vector3(40, 0, -16)
	geom.add_child(scene)
	# Table
	var table_mat: StandardMaterial3D = StandardMaterial3D.new()
	table_mat.albedo_color = Color(0.18, 0.22, 0.28)
	table_mat.metallic = 0.55
	table_mat.roughness = 0.45
	var table: MeshInstance3D = MeshInstance3D.new()
	var tmesh: BoxMesh = BoxMesh.new()
	tmesh.size = Vector3(1.0, 0.85, 1.0)
	table.mesh = tmesh
	table.position = Vector3(0, 0.42, 0)
	table.material_override = table_mat
	scene.add_child(table)
	# Chess board on top — checkered with cyan/violet
	var board_mat: StandardMaterial3D = StandardMaterial3D.new()
	board_mat.albedo_color = Color(0.14, 0.18, 0.22)
	board_mat.metallic = 0.40
	var board: MeshInstance3D = MeshInstance3D.new()
	var bmesh: BoxMesh = BoxMesh.new()
	bmesh.size = Vector3(0.85, 0.04, 0.85)
	board.mesh = bmesh
	board.position = Vector3(0, 0.87, 0)
	board.material_override = board_mat
	scene.add_child(board)
	# 4 holographic pieces — alternating cyan and violet
	var piece_colors: Array[Color] = [
		Color(0.55, 0.95, 1.0),
		Color(0.85, 0.40, 1.0),
	]
	var piece_offsets: Array[Vector3] = [
		Vector3(-0.20, 0, -0.20),
		Vector3(0.20, 0, -0.20),
		Vector3(-0.20, 0, 0.20),
		Vector3(0.20, 0, 0.20),
	]
	for i in piece_offsets.size():
		var piece: MeshInstance3D = MeshInstance3D.new()
		var pmesh: CylinderMesh = CylinderMesh.new()
		pmesh.top_radius = 0.05
		pmesh.bottom_radius = 0.10
		pmesh.height = 0.25
		piece.mesh = pmesh
		piece.position = piece_offsets[i] + Vector3(0, 1.02, 0)
		var color: Color = piece_colors[i % 2]
		var pmat: StandardMaterial3D = StandardMaterial3D.new()
		pmat.albedo_color = color
		pmat.emission_enabled = true
		pmat.emission = color
		pmat.emission_energy_multiplier = 1.8
		pmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		piece.material_override = pmat
		scene.add_child(piece)
		# Bob slightly
		var bob: Tween = create_tween().set_loops()
		var origin_y: float = 1.02
		bob.tween_property(piece, "position:y", origin_y + 0.06, 1.0 + i * 0.15).set_ease(Tween.EASE_IN_OUT)
		bob.tween_property(piece, "position:y", origin_y, 1.0 + i * 0.15).set_ease(Tween.EASE_IN_OUT)
	# 2 player capsules flanking the table
	var player_specs: Array = [
		[Vector3(0, 0.55, -1.0), Color(0.55, 0.95, 1.0), "Bit"],
		[Vector3(0, 0.55, 1.0), Color(0.85, 0.40, 1.0), "Byte"],
	]
	for spec in player_specs:
		var player: MeshInstance3D = MeshInstance3D.new()
		var pcap: CapsuleMesh = CapsuleMesh.new()
		pcap.radius = 0.32
		pcap.height = 1.0
		player.mesh = pcap
		player.position = spec[0]
		var pmat: StandardMaterial3D = StandardMaterial3D.new()
		var color: Color = spec[1]
		pmat.albedo_color = Color(color.r * 0.55, color.g * 0.55, color.b * 0.55)
		pmat.emission_enabled = true
		pmat.emission = color
		pmat.emission_energy_multiplier = 0.45
		pmat.metallic = 0.35
		pmat.roughness = 0.55
		player.material_override = pmat
		scene.add_child(player)
		# Name floating overhead
		var label: Label3D = Label3D.new()
		label.text = spec[2]
		label.position = spec[0] + Vector3(0, 0.95, 0)
		label.modulate = color
		label.outline_modulate = Color(0, 0, 0, 0.85)
		label.outline_size = 4
		label.font_size = 16
		label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		scene.add_child(label)
	# Collision around table
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(2.4, 1.4, 2.4)
	cs.shape = cb
	cs.position = Vector3(0, 0.7, 0)
	sb.add_child(cs)
	scene.add_child(sb)


func _build_plaza_directory(geom: Node) -> void:
	## Epic-1 T85: large vertical hologram listing 6 plaza shops/NPCs.
	## Pillar base + a tall holographic display panel. Acts as the plaza's
	## "table of contents" and ties together the 5 sub-zones.
	var dir: Node3D = Node3D.new()
	dir.name = "EastPlazaDirectory"
	dir.position = Vector3(28, 0, -3)
	geom.add_child(dir)
	# Base column
	var base_mat: StandardMaterial3D = StandardMaterial3D.new()
	base_mat.albedo_color = Color(0.10, 0.13, 0.16)
	base_mat.metallic = 0.85
	base_mat.roughness = 0.30
	var base: MeshInstance3D = MeshInstance3D.new()
	var bmesh: BoxMesh = BoxMesh.new()
	bmesh.size = Vector3(0.50, 1.0, 0.50)
	base.mesh = bmesh
	base.position = Vector3(0, 0.50, 0)
	base.material_override = base_mat
	dir.add_child(base)
	# Tall hologram panel
	var panel: MeshInstance3D = MeshInstance3D.new()
	var pmesh: BoxMesh = BoxMesh.new()
	pmesh.size = Vector3(1.4, 2.4, 0.06)
	panel.mesh = pmesh
	panel.position = Vector3(0, 2.20, 0)
	var pmat: StandardMaterial3D = StandardMaterial3D.new()
	pmat.albedo_color = Color(0.10, 0.20, 0.30, 0.45)
	pmat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	pmat.emission_enabled = true
	pmat.emission = Color(0.30, 0.85, 1.0)
	pmat.emission_energy_multiplier = 0.85
	pmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	panel.material_override = pmat
	dir.add_child(panel)
	# Title at the top
	var title: Label3D = Label3D.new()
	title.text = "PLAZA DIRECTORY"
	title.position = Vector3(0, 3.30, 0.05)
	title.modulate = Color(0.55, 0.95, 1.0)
	title.outline_modulate = Color(0, 0, 0, 0.85)
	title.outline_size = 5
	title.font_size = 18
	title.no_depth_test = true
	title.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	dir.add_child(title)
	# 6 listed entries
	var entries: Array[String] = [
		"1. Data Merchant",
		"2. Cipher Lab",
		"3. Tournament",
		"4. Sparring",
		"5. Data Eats",
		"6. Specimen-7",
	]
	for i in entries.size():
		var line: Label3D = Label3D.new()
		line.text = entries[i]
		line.position = Vector3(0, 2.85 - i * 0.28, 0.05)
		line.modulate = Color(0.85, 0.95, 1.0)
		line.outline_modulate = Color(0, 0, 0, 0.85)
		line.outline_size = 4
		line.font_size = 14
		line.no_depth_test = true
		line.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		dir.add_child(line)
	# Collision around base
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(0.50, 1.0, 0.50)
	cs.shape = cb
	cs.position = Vector3(0, 0.50, 0)
	sb.add_child(cs)
	dir.add_child(sb)


func _build_respawn_beacon(geom: Node) -> void:
	## Epic-1 T86: combat respawn beacon — a tall narrow column of stacked
	## glowing rings climbing into the sky. Visually distinct from the save
	## shrine (which is solid green obelisk). This is hovering rings only.
	var beacon: Node3D = Node3D.new()
	beacon.name = "EastPlazaRespawnBeacon"
	beacon.position = Vector3(36, 0, -11)
	geom.add_child(beacon)
	# Tiny base disc
	var base: MeshInstance3D = MeshInstance3D.new()
	var bmesh: CylinderMesh = CylinderMesh.new()
	bmesh.top_radius = 0.55
	bmesh.bottom_radius = 0.55
	bmesh.height = 0.10
	base.mesh = bmesh
	base.position = Vector3(0, 0.05, 0)
	var bmat: StandardMaterial3D = StandardMaterial3D.new()
	bmat.albedo_color = Color(0.10, 0.13, 0.16)
	bmat.metallic = 0.85
	bmat.roughness = 0.30
	bmat.emission_enabled = true
	bmat.emission = Color(0.30, 0.85, 1.0)
	bmat.emission_energy_multiplier = 0.7
	base.material_override = bmat
	beacon.add_child(base)
	# 6 stacked glowing rings rising upward
	var ring_mat: StandardMaterial3D = StandardMaterial3D.new()
	ring_mat.albedo_color = Color(0.30, 0.85, 1.0)
	ring_mat.emission_enabled = true
	ring_mat.emission = Color(0.55, 0.95, 1.0)
	ring_mat.emission_energy_multiplier = 2.4
	ring_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for i in 6:
		var ring: MeshInstance3D = MeshInstance3D.new()
		var rmesh: TorusMesh = TorusMesh.new()
		rmesh.inner_radius = 0.30
		rmesh.outer_radius = 0.40
		ring.mesh = rmesh
		var origin_y: float = 0.50 + i * 0.55
		ring.position = Vector3(0, origin_y, 0)
		ring.material_override = ring_mat
		beacon.add_child(ring)
		# Each ring rises and resets, staggered
		var rise: Tween = create_tween().set_loops()
		rise.tween_interval(i * 0.30)
		rise.tween_property(ring, "position:y", origin_y + 3.30, 2.4).set_ease(Tween.EASE_OUT)
		rise.tween_property(ring, "position:y", origin_y, 0.05)
		rise.tween_interval(0.40)
	# Floating "RESPAWN" label
	var label: Label3D = Label3D.new()
	label.text = "RESPAWN"
	label.position = Vector3(0, 4.5, 0)
	label.modulate = Color(0.55, 0.95, 1.0)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 18
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	beacon.add_child(label)


func _build_ground_glitch(geom: Node) -> void:
	## Epic-1 T87: 4 ground "glitch crack" decals scattered through the
	## plaza — thin emissive cracks suggesting the simulation seams. Each
	## flickers on a fast tween to feel unstable.
	var positions: Array[Vector3] = [
		Vector3(29, 0.04, -11),
		Vector3(38, 0.04, 4),
		Vector3(31, 0.04, 13),
		Vector3(42, 0.04, -8),
	]
	var crack_mat: StandardMaterial3D = StandardMaterial3D.new()
	crack_mat.albedo_color = Color(1.0, 0.20, 0.40)
	crack_mat.emission_enabled = true
	crack_mat.emission = Color(1.0, 0.40, 0.55)
	crack_mat.emission_energy_multiplier = 2.6
	crack_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for i in positions.size():
		var crack_root: Node3D = Node3D.new()
		crack_root.name = "EastPlazaGlitchCrack_%d" % i
		crack_root.position = positions[i]
		crack_root.rotation = Vector3(0, randf() * TAU, 0)
		geom.add_child(crack_root)
		# 3 thin emissive bars at random angles forming a "crack"
		for s in 3:
			var seg: MeshInstance3D = MeshInstance3D.new()
			var smesh: BoxMesh = BoxMesh.new()
			smesh.size = Vector3(0.85 + randf() * 0.4, 0.02, 0.05)
			seg.mesh = smesh
			seg.position = Vector3(randf_range(-0.3, 0.3), 0, randf_range(-0.3, 0.3))
			seg.rotation = Vector3(0, randf() * TAU, 0)
			seg.material_override = crack_mat
			crack_root.add_child(seg)
		# Flicker visibility
		var flicker: Tween = create_tween().set_loops()
		flicker.tween_property(crack_root, "visible", false, 0.08)
		flicker.tween_interval(0.10 + randf() * 0.20)
		flicker.tween_property(crack_root, "visible", true, 0.0)
		flicker.tween_interval(0.85 + randf() * 0.50)


func _build_floating_receipts(geom: Node) -> void:
	## Epic-1 T88: 6 small floating "receipt" papers drifting through the
	## plaza on slow paths, suggesting commerce and ambient wind. Each is a
	## thin amber-tinted card that bobs and slowly cycles between waypoints.
	var paths: Array = [
		[Vector3(28, 1.6, -7), Vector3(30, 2.2, -3), Vector3(28, 1.8, 0)],
		[Vector3(34, 2.0, 5), Vector3(36, 1.6, 9), Vector3(34, 2.4, 5)],
		[Vector3(40, 1.8, -4), Vector3(42, 2.4, 0), Vector3(40, 1.6, 4)],
		[Vector3(32, 2.4, -2), Vector3(34, 1.8, 2), Vector3(32, 2.0, -2)],
		[Vector3(38, 1.6, 11), Vector3(40, 2.2, 13), Vector3(38, 1.8, 11)],
		[Vector3(30, 2.0, 8), Vector3(28, 1.6, 11), Vector3(30, 2.4, 8)],
	]
	for i in paths.size():
		var receipt: MeshInstance3D = MeshInstance3D.new()
		receipt.name = "EastPlazaReceipt_%d" % i
		var rmesh: BoxMesh = BoxMesh.new()
		rmesh.size = Vector3(0.30, 0.45, 0.02)
		receipt.mesh = rmesh
		receipt.position = paths[i][0]
		var rmat: StandardMaterial3D = StandardMaterial3D.new()
		rmat.albedo_color = Color(0.95, 0.90, 0.65)
		rmat.emission_enabled = true
		rmat.emission = Color(1.0, 0.95, 0.55)
		rmat.emission_energy_multiplier = 0.55
		rmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		receipt.material_override = rmat
		geom.add_child(receipt)
		# Drift through waypoints
		var drift: Tween = create_tween().set_loops()
		var path: Array = paths[i]
		for wp in path:
			drift.tween_property(receipt, "position", wp, 3.5).set_ease(Tween.EASE_IN_OUT)
		drift.tween_property(receipt, "position", path[0], 3.5).set_ease(Tween.EASE_IN_OUT)
		# Tumbling rotation
		var tumble: Tween = create_tween().set_loops()
		tumble.tween_property(receipt, "rotation", Vector3(TAU, TAU * 0.5, 0), 6.0)


func _build_combat_golem(geom: Node) -> void:
	## Epic-1 T89: animated combat training golem in the sparring arena.
	## Larger than the practice dummies, has stubby arms that punch the air,
	## and a glowing red core in its chest.
	var golem: Node3D = Node3D.new()
	golem.name = "EastPlazaCombatGolem"
	golem.position = Vector3(34, 0, 9)
	geom.add_child(golem)
	# Stone body
	var body_mat: StandardMaterial3D = StandardMaterial3D.new()
	body_mat.albedo_color = Color(0.20, 0.24, 0.30)
	body_mat.metallic = 0.40
	body_mat.roughness = 0.55
	var body: MeshInstance3D = MeshInstance3D.new()
	var bmesh: BoxMesh = BoxMesh.new()
	bmesh.size = Vector3(1.2, 1.6, 0.85)
	body.mesh = bmesh
	body.position = Vector3(0, 1.20, 0)
	body.material_override = body_mat
	golem.add_child(body)
	# Head box
	var head: MeshInstance3D = MeshInstance3D.new()
	var hmesh: BoxMesh = BoxMesh.new()
	hmesh.size = Vector3(0.85, 0.65, 0.65)
	head.mesh = hmesh
	head.position = Vector3(0, 2.30, 0)
	head.material_override = body_mat
	golem.add_child(head)
	# Glowing red eyes
	var eye_mat: StandardMaterial3D = StandardMaterial3D.new()
	eye_mat.albedo_color = Color(1.0, 0.20, 0.20)
	eye_mat.emission_enabled = true
	eye_mat.emission = Color(1.0, 0.30, 0.30)
	eye_mat.emission_energy_multiplier = 2.6
	eye_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for ex: float in [-0.18, 0.18]:
		var eye: MeshInstance3D = MeshInstance3D.new()
		var emesh: SphereMesh = SphereMesh.new()
		emesh.radius = 0.08
		emesh.height = 0.16
		eye.mesh = emesh
		eye.position = Vector3(ex, 2.35, 0.34)
		eye.material_override = eye_mat
		golem.add_child(eye)
	# Glowing red core in chest
	var core: MeshInstance3D = MeshInstance3D.new()
	var cmesh: SphereMesh = SphereMesh.new()
	cmesh.radius = 0.20
	cmesh.height = 0.40
	core.mesh = cmesh
	core.position = Vector3(0, 1.40, 0.45)
	var cmat: StandardMaterial3D = StandardMaterial3D.new()
	cmat.albedo_color = Color(1.0, 0.30, 0.30)
	cmat.emission_enabled = true
	cmat.emission = Color(1.0, 0.40, 0.30)
	cmat.emission_energy_multiplier = 2.4
	cmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	core.material_override = cmat
	golem.add_child(core)
	# Pulsing core
	var pulse: Tween = create_tween().set_loops()
	pulse.tween_property(core, "scale", Vector3(1.25, 1.25, 1.25), 0.85).set_ease(Tween.EASE_IN_OUT)
	pulse.tween_property(core, "scale", Vector3(1.0, 1.0, 1.0), 0.85).set_ease(Tween.EASE_IN_OUT)
	# 2 stubby arms with punch animation
	for sx: float in [-1.0, 1.0]:
		var arm_pivot: Node3D = Node3D.new()
		arm_pivot.position = Vector3(sx * 0.65, 1.65, 0)
		golem.add_child(arm_pivot)
		var arm: MeshInstance3D = MeshInstance3D.new()
		var amesh: BoxMesh = BoxMesh.new()
		amesh.size = Vector3(0.40, 0.40, 1.0)
		arm.mesh = amesh
		arm.position = Vector3(0, 0, 0.55)
		arm.material_override = body_mat
		arm_pivot.add_child(arm)
		# Punch tween — arm moves forward and back
		var punch: Tween = create_tween().set_loops()
		punch.tween_interval(sx * 0.20 + 0.30)
		punch.tween_property(arm, "position:z", 1.10, 0.18).set_ease(Tween.EASE_OUT)
		punch.tween_property(arm, "position:z", 0.55, 0.30).set_ease(Tween.EASE_IN)
		punch.tween_interval(0.35)
	# Collision around body
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(1.2, 2.6, 0.85)
	cs.shape = cb
	cs.position = Vector3(0, 1.30, 0)
	sb.add_child(cs)
	golem.add_child(sb)


func _build_weather_dial(geom: Node) -> void:
	## Epic-1 T90: a small "weather control dial" kiosk on a tall pole. The
	## dial has 3 setting wedges (sunny/storm/glitch) and an indicator
	## needle that slowly rotates between them.
	var dial: Node3D = Node3D.new()
	dial.name = "EastPlazaWeatherDial"
	dial.position = Vector3(46, 0, 8)
	geom.add_child(dial)
	# Pole
	var pole_mat: StandardMaterial3D = StandardMaterial3D.new()
	pole_mat.albedo_color = Color(0.10, 0.13, 0.16)
	pole_mat.metallic = 0.85
	pole_mat.roughness = 0.30
	var pole: MeshInstance3D = MeshInstance3D.new()
	var pmesh: CylinderMesh = CylinderMesh.new()
	pmesh.top_radius = 0.07
	pmesh.bottom_radius = 0.10
	pmesh.height = 1.85
	pole.mesh = pmesh
	pole.position = Vector3(0, 0.92, 0)
	pole.material_override = pole_mat
	dial.add_child(pole)
	# Dial body — flat disc facing the player
	var disc: MeshInstance3D = MeshInstance3D.new()
	var dmesh: CylinderMesh = CylinderMesh.new()
	dmesh.top_radius = 0.45
	dmesh.bottom_radius = 0.45
	dmesh.height = 0.06
	disc.mesh = dmesh
	disc.position = Vector3(0, 2.0, 0)
	disc.rotation = Vector3(deg_to_rad(90), 0, 0)
	var dmat: StandardMaterial3D = StandardMaterial3D.new()
	dmat.albedo_color = Color(0.18, 0.22, 0.28)
	dmat.metallic = 0.65
	dmat.roughness = 0.30
	disc.material_override = dmat
	dial.add_child(disc)
	# 3 colored wedge labels
	var label_specs: Array = [
		["SUN", Color(1.0, 0.85, 0.30), -0.30, 0.30],
		["STORM", Color(0.55, 0.85, 1.0), 0.30, 0.30],
		["GLITCH", Color(1.0, 0.30, 0.55), 0.0, -0.30],
	]
	for spec in label_specs:
		var label: Label3D = Label3D.new()
		label.text = spec[0]
		label.position = Vector3(spec[2], 2.0 + spec[3], 0.06)
		label.modulate = spec[1]
		label.outline_modulate = Color(0, 0, 0, 0.85)
		label.outline_size = 4
		label.font_size = 12
		label.no_depth_test = true
		dial.add_child(label)
	# Needle indicator on the disc
	var needle_pivot: Node3D = Node3D.new()
	needle_pivot.position = Vector3(0, 2.0, 0.04)
	dial.add_child(needle_pivot)
	var needle: MeshInstance3D = MeshInstance3D.new()
	var nmesh: BoxMesh = BoxMesh.new()
	nmesh.size = Vector3(0.04, 0.34, 0.04)
	needle.mesh = nmesh
	needle.position = Vector3(0, 0.17, 0)
	var nmat: StandardMaterial3D = StandardMaterial3D.new()
	nmat.albedo_color = Color(1.0, 0.95, 0.40)
	nmat.emission_enabled = true
	nmat.emission = Color(1.0, 0.95, 0.55)
	nmat.emission_energy_multiplier = 2.4
	nmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	needle.material_override = nmat
	needle_pivot.add_child(needle)
	# Needle slowly cycles between the 3 settings
	var spin: Tween = create_tween().set_loops()
	spin.tween_property(needle_pivot, "rotation:z", deg_to_rad(-45), 2.0).set_ease(Tween.EASE_IN_OUT)
	spin.tween_interval(1.0)
	spin.tween_property(needle_pivot, "rotation:z", deg_to_rad(45), 2.0).set_ease(Tween.EASE_IN_OUT)
	spin.tween_interval(1.0)
	spin.tween_property(needle_pivot, "rotation:z", deg_to_rad(180), 2.0).set_ease(Tween.EASE_IN_OUT)
	spin.tween_interval(1.0)
	spin.tween_property(needle_pivot, "rotation:z", 0, 2.0).set_ease(Tween.EASE_IN_OUT)
	# Top label
	var label: Label3D = Label3D.new()
	label.text = "WEATHER"
	label.position = Vector3(0, 2.65, 0)
	label.modulate = Color(0.85, 0.95, 1.0)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 14
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	dial.add_child(label)
	# Collision around pole
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cap: CapsuleShape3D = CapsuleShape3D.new()
	cap.radius = 0.20
	cap.height = 1.85
	cs.shape = cap
	cs.position = Vector3(0, 0.92, 0)
	sb.add_child(cs)
	dial.add_child(sb)


func _build_corner_pillars(geom: Node) -> void:
	## Epic-1 T91: 4 massive light pillars at the plaza corners — each is
	## 12m tall with a stacked pattern of stone tiers and a glowing capital
	## crowned by a pulsing emissive sphere. Defines the plaza silhouette.
	var positions: Array[Vector3] = [
		Vector3(22, 0, -18),
		Vector3(46, 0, -18),
		Vector3(22, 0, 18),
		Vector3(46, 0, 18),
	]
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.16, 0.20, 0.26)
	stone_mat.metallic = 0.55
	stone_mat.roughness = 0.45
	for i in positions.size():
		var pillar: Node3D = Node3D.new()
		pillar.name = "EastPlazaCornerPillar_%d" % i
		pillar.position = positions[i]
		geom.add_child(pillar)
		# Wide base
		var base: MeshInstance3D = MeshInstance3D.new()
		var bmesh: BoxMesh = BoxMesh.new()
		bmesh.size = Vector3(2.0, 0.55, 2.0)
		base.mesh = bmesh
		base.position = Vector3(0, 0.27, 0)
		base.material_override = stone_mat
		pillar.add_child(base)
		# Tall column shaft
		var shaft: MeshInstance3D = MeshInstance3D.new()
		var smesh: CylinderMesh = CylinderMesh.new()
		smesh.top_radius = 0.55
		smesh.bottom_radius = 0.65
		smesh.height = 9.5
		shaft.mesh = smesh
		shaft.position = Vector3(0, 5.30, 0)
		shaft.material_override = stone_mat
		pillar.add_child(shaft)
		# Cyan emissive ring inset midway up the shaft
		var ring_mat: StandardMaterial3D = StandardMaterial3D.new()
		ring_mat.albedo_color = Color(0.30, 0.85, 1.0)
		ring_mat.emission_enabled = true
		ring_mat.emission = Color(0.55, 0.95, 1.0)
		ring_mat.emission_energy_multiplier = 1.6
		ring_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		for ry: float in [3.0, 5.5, 8.0]:
			var ring: MeshInstance3D = MeshInstance3D.new()
			var rmesh: TorusMesh = TorusMesh.new()
			rmesh.inner_radius = 0.62
			rmesh.outer_radius = 0.72
			ring.mesh = rmesh
			ring.position = Vector3(0, ry, 0)
			ring.material_override = ring_mat
			pillar.add_child(ring)
		# Wider capital block at the top
		var capital: MeshInstance3D = MeshInstance3D.new()
		var cmesh: BoxMesh = BoxMesh.new()
		cmesh.size = Vector3(1.6, 0.50, 1.6)
		capital.mesh = cmesh
		capital.position = Vector3(0, 10.30, 0)
		capital.material_override = stone_mat
		pillar.add_child(capital)
		# Crowning emissive sphere
		var crown: MeshInstance3D = MeshInstance3D.new()
		var crown_mesh: SphereMesh = SphereMesh.new()
		crown_mesh.radius = 0.65
		crown_mesh.height = 1.30
		crown.mesh = crown_mesh
		crown.position = Vector3(0, 11.20, 0)
		var crown_mat: StandardMaterial3D = StandardMaterial3D.new()
		crown_mat.albedo_color = Color(0.55, 0.95, 1.0)
		crown_mat.emission_enabled = true
		crown_mat.emission = Color(0.55, 0.95, 1.0)
		crown_mat.emission_energy_multiplier = 2.6
		crown_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		crown.material_override = crown_mat
		pillar.add_child(crown)
		# Pulse the crown sphere
		var pulse: Tween = create_tween().set_loops()
		var pulse_speed: float = 1.4 + i * 0.2
		pulse.tween_property(crown, "scale", Vector3(1.20, 1.20, 1.20), pulse_speed).set_ease(Tween.EASE_IN_OUT)
		pulse.tween_property(crown, "scale", Vector3(1.0, 1.0, 1.0), pulse_speed).set_ease(Tween.EASE_IN_OUT)
		# Real OmniLight illuminating the corner
		var light: OmniLight3D = OmniLight3D.new()
		light.position = Vector3(0, 11.20, 0)
		light.light_color = Color(0.55, 0.95, 1.0)
		light.light_energy = 2.8
		light.omni_range = 14.0
		light.omni_attenuation = 1.6
		pillar.add_child(light)
		# Collision around the column
		var sb: StaticBody3D = StaticBody3D.new()
		var cs: CollisionShape3D = CollisionShape3D.new()
		var cap: CapsuleShape3D = CapsuleShape3D.new()
		cap.radius = 0.75
		cap.height = 10.5
		cs.shape = cap
		cs.position = Vector3(0, 5.30, 0)
		sb.add_child(cs)
		pillar.add_child(sb)


func _build_maintenance_patrol(geom: Node) -> void:
	## Epic-1 T92: a maintenance bot patrolling the plaza on a long looping
	## path, visibly larger than the existing ambient bots. Stubby chassis
	## on 4 thin wheels with a bristle "broom" attachment underneath.
	var bot: Node3D = Node3D.new()
	bot.name = "EastPlazaMaintenanceBot"
	bot.position = Vector3(26, 0, -14)
	geom.add_child(bot)
	# Chassis
	var chassis_mat: StandardMaterial3D = StandardMaterial3D.new()
	chassis_mat.albedo_color = Color(0.95, 0.65, 0.20)
	chassis_mat.emission_enabled = true
	chassis_mat.emission = Color(1.0, 0.75, 0.30)
	chassis_mat.emission_energy_multiplier = 0.45
	chassis_mat.metallic = 0.55
	chassis_mat.roughness = 0.40
	var chassis: MeshInstance3D = MeshInstance3D.new()
	var cmesh: BoxMesh = BoxMesh.new()
	cmesh.size = Vector3(0.95, 0.55, 1.20)
	chassis.mesh = cmesh
	chassis.position = Vector3(0, 0.45, 0)
	chassis.material_override = chassis_mat
	bot.add_child(chassis)
	# Cyan dome eye
	var eye: MeshInstance3D = MeshInstance3D.new()
	var emesh: SphereMesh = SphereMesh.new()
	emesh.radius = 0.18
	emesh.height = 0.36
	eye.mesh = emesh
	eye.position = Vector3(0, 0.85, 0)
	var emat: StandardMaterial3D = StandardMaterial3D.new()
	emat.albedo_color = Color(0.30, 0.85, 1.0)
	emat.emission_enabled = true
	emat.emission = Color(0.55, 0.95, 1.0)
	emat.emission_energy_multiplier = 2.0
	emat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	eye.material_override = emat
	bot.add_child(eye)
	# 4 wheels
	var wheel_mat: StandardMaterial3D = StandardMaterial3D.new()
	wheel_mat.albedo_color = Color(0.10, 0.13, 0.16)
	wheel_mat.metallic = 0.85
	for ox: float in [-0.40, 0.40]:
		for oz: float in [-0.50, 0.50]:
			var wheel: MeshInstance3D = MeshInstance3D.new()
			var wmesh: CylinderMesh = CylinderMesh.new()
			wmesh.top_radius = 0.18
			wmesh.bottom_radius = 0.18
			wmesh.height = 0.10
			wheel.mesh = wmesh
			wheel.position = Vector3(ox, 0.18, oz)
			wheel.rotation = Vector3(0, 0, deg_to_rad(90))
			wheel.material_override = wheel_mat
			bot.add_child(wheel)
	# Bristle broom — thin emissive bars hanging below
	var bristle_mat: StandardMaterial3D = StandardMaterial3D.new()
	bristle_mat.albedo_color = Color(1.0, 0.85, 0.30)
	bristle_mat.emission_enabled = true
	bristle_mat.emission = Color(1.0, 0.85, 0.30)
	bristle_mat.emission_energy_multiplier = 1.4
	bristle_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for bx in 5:
		var bristle: MeshInstance3D = MeshInstance3D.new()
		var bmesh: BoxMesh = BoxMesh.new()
		bmesh.size = Vector3(0.02, 0.18, 0.6)
		bristle.mesh = bmesh
		bristle.position = Vector3(-0.30 + bx * 0.15, 0.10, -0.65)
		bristle.material_override = bristle_mat
		bot.add_child(bristle)
	# Patrol path tween — long loop around the plaza
	var waypoints: Array[Vector3] = [
		Vector3(26, 0, -14),
		Vector3(45, 0, -14),
		Vector3(45, 0, 16),
		Vector3(26, 0, 16),
		Vector3(26, 0, -14),
	]
	var patrol: Tween = create_tween().set_loops()
	for wi in waypoints.size() - 1:
		var from: Vector3 = waypoints[wi]
		var to: Vector3 = waypoints[wi + 1]
		# Face direction of travel
		var dir: Vector3 = (to - from).normalized()
		var yaw: float = atan2(dir.x, dir.z)
		patrol.tween_property(bot, "rotation:y", yaw, 0.3)
		patrol.tween_property(bot, "position", to, 8.0)


func _build_news_ticker(geom: Node) -> void:
	## Epic-1 T93: a large horizontal news ticker mounted on tall columns
	## above the plaza directory. Wide black panel with a long string of
	## news headlines that scrolls (we mock the scroll with a tween moving
	## the label horizontally inside the bar).
	var ticker_root: Node3D = Node3D.new()
	ticker_root.name = "EastPlazaNewsTicker"
	ticker_root.position = Vector3(34, 0, -3)
	geom.add_child(ticker_root)
	# 2 support columns
	var col_mat: StandardMaterial3D = StandardMaterial3D.new()
	col_mat.albedo_color = Color(0.10, 0.13, 0.16)
	col_mat.metallic = 0.85
	col_mat.roughness = 0.30
	for sx: float in [-3.5, 3.5]:
		var col: MeshInstance3D = MeshInstance3D.new()
		var cmesh: CylinderMesh = CylinderMesh.new()
		cmesh.top_radius = 0.10
		cmesh.bottom_radius = 0.14
		cmesh.height = 4.5
		col.mesh = cmesh
		col.position = Vector3(sx, 2.25, 0)
		col.material_override = col_mat
		ticker_root.add_child(col)
		# Collision on each column
		var sb: StaticBody3D = StaticBody3D.new()
		var cs: CollisionShape3D = CollisionShape3D.new()
		var cap: CapsuleShape3D = CapsuleShape3D.new()
		cap.radius = 0.20
		cap.height = 4.5
		cs.shape = cap
		cs.position = Vector3(sx, 2.25, 0)
		sb.add_child(cs)
		ticker_root.add_child(sb)
	# Black bar panel
	var bar: MeshInstance3D = MeshInstance3D.new()
	var bmesh: BoxMesh = BoxMesh.new()
	bmesh.size = Vector3(7.5, 0.85, 0.20)
	bar.mesh = bmesh
	bar.position = Vector3(0, 4.40, 0)
	var bmat: StandardMaterial3D = StandardMaterial3D.new()
	bmat.albedo_color = Color(0.04, 0.06, 0.10)
	bmat.metallic = 0.30
	bmat.roughness = 0.30
	bar.material_override = bmat
	ticker_root.add_child(bar)
	# Top + bottom emissive trim
	var trim_mat: StandardMaterial3D = StandardMaterial3D.new()
	trim_mat.albedo_color = Color(1.0, 0.40, 0.20)
	trim_mat.emission_enabled = true
	trim_mat.emission = Color(1.0, 0.55, 0.20)
	trim_mat.emission_energy_multiplier = 1.8
	trim_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for ty: float in [4.83, 3.97]:
		var trim: MeshInstance3D = MeshInstance3D.new()
		var tmesh: BoxMesh = BoxMesh.new()
		tmesh.size = Vector3(7.5, 0.05, 0.22)
		trim.mesh = tmesh
		trim.position = Vector3(0, ty, 0)
		trim.material_override = trim_mat
		ticker_root.add_child(trim)
	# Scrolling news label — clipped within bar via tween x position
	var headline: Label3D = Label3D.new()
	headline.text = "*** GLOBBLER SIGHTED IN EAST PLAZA  ***  TOURNAMENT FINALS TONIGHT  ***  CIPHER 99 STILL UNDEFEATED  ***  DATA SHARDS UP 12%  ***"
	headline.position = Vector3(3.5, 4.40, 0.12)
	headline.modulate = Color(1.0, 0.55, 0.20)
	headline.outline_modulate = Color(0, 0, 0, 0.85)
	headline.outline_size = 4
	headline.font_size = 22
	headline.no_depth_test = true
	ticker_root.add_child(headline)
	var scroll: Tween = create_tween().set_loops()
	scroll.tween_property(headline, "position:x", -10.5, 18.0)
	scroll.tween_property(headline, "position:x", 3.5, 0.05)


func _build_data_spa(geom: Node) -> void:
	## Epic-1 T94: a small relaxation pool — sunken cyan disc with 3 NPC
	## "bathers" hovering inside (just heads + shoulders above the surface).
	## Adds a "leisure" vibe to balance the combat-heavy areas.
	var spa: Node3D = Node3D.new()
	spa.name = "EastPlazaDataSpa"
	spa.position = Vector3(46, 0, -10)
	geom.add_child(spa)
	# Pool rim — wide flat torus
	var rim: MeshInstance3D = MeshInstance3D.new()
	var rim_mesh: TorusMesh = TorusMesh.new()
	rim_mesh.inner_radius = 1.40
	rim_mesh.outer_radius = 1.65
	rim.mesh = rim_mesh
	rim.position = Vector3(0, 0.20, 0)
	var rim_mat: StandardMaterial3D = StandardMaterial3D.new()
	rim_mat.albedo_color = Color(0.18, 0.22, 0.28)
	rim_mat.metallic = 0.65
	rim_mat.roughness = 0.30
	rim_mat.emission_enabled = true
	rim_mat.emission = Color(0.30, 0.85, 1.0)
	rim_mat.emission_energy_multiplier = 0.5
	rim.material_override = rim_mat
	spa.add_child(rim)
	# Water disc inside the rim
	var water: MeshInstance3D = MeshInstance3D.new()
	var wmesh: CylinderMesh = CylinderMesh.new()
	wmesh.top_radius = 1.40
	wmesh.bottom_radius = 1.40
	wmesh.height = 0.10
	water.mesh = wmesh
	water.position = Vector3(0, 0.15, 0)
	var wmat: StandardMaterial3D = StandardMaterial3D.new()
	wmat.albedo_color = Color(0.30, 0.85, 1.0, 0.55)
	wmat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	wmat.emission_enabled = true
	wmat.emission = Color(0.55, 0.95, 1.0)
	wmat.emission_energy_multiplier = 1.4
	wmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	water.material_override = wmat
	spa.add_child(water)
	# 3 bather "heads" peeking above the water
	var bather_specs: Array = [
		[Vector3(-0.7, 0.30, 0), Color(0.95, 0.65, 0.45)],
		[Vector3(0.7, 0.30, -0.3), Color(0.85, 0.40, 1.0)],
		[Vector3(0.0, 0.30, 0.7), Color(0.45, 0.95, 0.65)],
	]
	for i in bather_specs.size():
		var bather: Node3D = Node3D.new()
		bather.name = "Bather_%d" % i
		bather.position = bather_specs[i][0]
		spa.add_child(bather)
		# Head
		var head: MeshInstance3D = MeshInstance3D.new()
		var hmesh: SphereMesh = SphereMesh.new()
		hmesh.radius = 0.18
		hmesh.height = 0.36
		head.mesh = hmesh
		head.position = Vector3(0, 0.10, 0)
		var color: Color = bather_specs[i][1]
		var hmat: StandardMaterial3D = StandardMaterial3D.new()
		hmat.albedo_color = color
		hmat.emission_enabled = true
		hmat.emission = color
		hmat.emission_energy_multiplier = 0.55
		hmat.metallic = 0.20
		hmat.roughness = 0.55
		head.material_override = hmat
		bather.add_child(head)
		# Eyes (closed/relaxing — 2 small black bars)
		var eye_mat: StandardMaterial3D = StandardMaterial3D.new()
		eye_mat.albedo_color = Color(0.05, 0.05, 0.10)
		eye_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		for ex: float in [-0.06, 0.06]:
			var eye: MeshInstance3D = MeshInstance3D.new()
			var emesh: BoxMesh = BoxMesh.new()
			emesh.size = Vector3(0.04, 0.01, 0.02)
			eye.mesh = emesh
			eye.position = Vector3(ex, 0.13, 0.16)
			eye.material_override = eye_mat
			bather.add_child(eye)
		# Bob in the water
		var bob: Tween = create_tween().set_loops()
		bob.tween_property(bather, "position:y", 0.40, 1.6 + i * 0.2).set_ease(Tween.EASE_IN_OUT)
		bob.tween_property(bather, "position:y", 0.30, 1.6 + i * 0.2).set_ease(Tween.EASE_IN_OUT)
	# Steam particles rising
	var steam: GPUParticles3D = GPUParticles3D.new()
	steam.amount = 30
	steam.lifetime = 3.0
	steam.position = Vector3(0, 0.50, 0)
	var spmat: ParticleProcessMaterial = ParticleProcessMaterial.new()
	spmat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	spmat.emission_sphere_radius = 1.20
	spmat.direction = Vector3(0, 1, 0)
	spmat.spread = 25.0
	spmat.initial_velocity_min = 0.40
	spmat.initial_velocity_max = 0.85
	spmat.gravity = Vector3.ZERO
	spmat.scale_min = 0.30
	spmat.scale_max = 0.55
	spmat.color = Color(0.85, 0.95, 1.0, 0.30)
	steam.process_material = spmat
	var sm: SphereMesh = SphereMesh.new()
	sm.radius = 0.30
	sm.height = 0.60
	var sm_mat: StandardMaterial3D = StandardMaterial3D.new()
	sm_mat.albedo_color = Color(0.85, 0.95, 1.0, 0.30)
	sm_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	sm_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	sm.material = sm_mat
	steam.draw_pass_1 = sm
	spa.add_child(steam)


func _build_plaza_fireworks(geom: Node) -> void:
	## Epic-1 T95: ambient fireworks emitter high over the plaza center,
	## continuously bursting cyan/violet/amber sparks. Sells "active festive
	## district" with one VFX call.
	var fw: GPUParticles3D = GPUParticles3D.new()
	fw.name = "EastPlazaFireworks"
	fw.position = Vector3(34, 14, 0)
	fw.amount = 120
	fw.lifetime = 2.5
	fw.explosiveness = 0.6
	var pmat: ParticleProcessMaterial = ParticleProcessMaterial.new()
	pmat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	pmat.emission_sphere_radius = 0.30
	pmat.direction = Vector3(0, 0, 0)
	pmat.spread = 180.0
	pmat.initial_velocity_min = 3.0
	pmat.initial_velocity_max = 6.0
	pmat.gravity = Vector3(0, -2.5, 0)
	pmat.scale_min = 0.10
	pmat.scale_max = 0.22
	pmat.color = Color(0.55, 0.95, 1.0, 1.0)
	# Color ramp via gradient
	var grad: Gradient = Gradient.new()
	grad.add_point(0.0, Color(0.55, 0.95, 1.0, 1.0))
	grad.add_point(0.4, Color(0.85, 0.40, 1.0, 1.0))
	grad.add_point(0.75, Color(1.0, 0.85, 0.30, 0.8))
	grad.add_point(1.0, Color(1.0, 0.30, 0.30, 0.0))
	var grad_tex: GradientTexture1D = GradientTexture1D.new()
	grad_tex.gradient = grad
	pmat.color_ramp = grad_tex
	fw.process_material = pmat
	var spark: SphereMesh = SphereMesh.new()
	spark.radius = 0.08
	spark.height = 0.16
	var spark_mat: StandardMaterial3D = StandardMaterial3D.new()
	spark_mat.albedo_color = Color(1, 1, 1)
	spark_mat.emission_enabled = true
	spark_mat.emission = Color(1, 1, 1)
	spark_mat.emission_energy_multiplier = 2.5
	spark_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	spark.material = spark_mat
	fw.draw_pass_1 = spark
	geom.add_child(fw)


func _build_welcome_arch_banner(geom: Node) -> void:
	## Epic-1 T96: a wide cyan banner stretched between the existing plaza
	## arch pillars at the west entrance reading "WELCOME TO EAST PLAZA".
	## The banner has waving emissive trim and a slow alpha pulse.
	var banner_root: Node3D = Node3D.new()
	banner_root.name = "EastPlazaWelcomeBanner"
	banner_root.position = Vector3(22, 0, 0)
	geom.add_child(banner_root)
	# Banner cloth — long horizontal box stretched between the existing
	# plaza arch pillars (which sit roughly at z=-3 and z=3 at x=22)
	var cloth: MeshInstance3D = MeshInstance3D.new()
	var cmesh: BoxMesh = BoxMesh.new()
	cmesh.size = Vector3(0.10, 0.95, 6.5)
	cloth.mesh = cmesh
	cloth.position = Vector3(0, 4.4, 0)
	var cmat: StandardMaterial3D = StandardMaterial3D.new()
	cmat.albedo_color = Color(0.10, 0.20, 0.30)
	cmat.emission_enabled = true
	cmat.emission = Color(0.30, 0.85, 1.0)
	cmat.emission_energy_multiplier = 1.0
	cmat.metallic = 0.10
	cmat.roughness = 0.55
	cloth.material_override = cmat
	banner_root.add_child(cloth)
	# Top + bottom emissive trim
	var trim_mat: StandardMaterial3D = StandardMaterial3D.new()
	trim_mat.albedo_color = Color(0.55, 0.95, 1.0)
	trim_mat.emission_enabled = true
	trim_mat.emission = Color(0.55, 0.95, 1.0)
	trim_mat.emission_energy_multiplier = 2.0
	trim_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for ty: float in [4.85, 3.95]:
		var trim: MeshInstance3D = MeshInstance3D.new()
		var tmesh: BoxMesh = BoxMesh.new()
		tmesh.size = Vector3(0.12, 0.08, 6.5)
		trim.mesh = tmesh
		trim.position = Vector3(0, ty, 0)
		trim.material_override = trim_mat
		banner_root.add_child(trim)
	# Welcome text — duplicate on each side so it reads from both directions
	for fx: float in [-0.10, 0.10]:
		var label: Label3D = Label3D.new()
		label.text = "WELCOME TO\nEAST PLAZA"
		label.position = Vector3(fx, 4.40, 0)
		label.rotation = Vector3(0, deg_to_rad(-90 if fx < 0 else 90), 0)
		label.modulate = Color(0.55, 0.95, 1.0)
		label.outline_modulate = Color(0, 0, 0, 0.85)
		label.outline_size = 6
		label.font_size = 24
		label.no_depth_test = true
		banner_root.add_child(label)
	# Slow alpha pulse to feel "alive"
	var pulse: Tween = create_tween().set_loops()
	pulse.tween_property(cmat, "emission_energy_multiplier", 1.6, 2.0).set_ease(Tween.EASE_IN_OUT)
	pulse.tween_property(cmat, "emission_energy_multiplier", 0.85, 2.0).set_ease(Tween.EASE_IN_OUT)


func _build_statue_spotlights(geom: Node) -> void:
	## Epic-1 T97: 4 ground-mounted SpotLight3Ds aimed up at the central AI
	## statue at (32, 0, -12). Each spotlight is a different color from the
	## ancestor bust palette (cyan, violet, green, amber) plus a tiny visible
	## floor housing so the lights look intentional.
	var center := Vector3(32, 0, -12)
	var light_specs: Array = [
		[Vector3(-2.0, 0, -2.0), Color(0.30, 0.85, 1.0)],
		[Vector3(2.0, 0, -2.0), Color(0.85, 0.40, 1.0)],
		[Vector3(-2.0, 0, 2.0), Color(0.45, 0.95, 0.65)],
		[Vector3(2.0, 0, 2.0), Color(0.95, 0.65, 0.20)],
	]
	for i in light_specs.size():
		var spot_root: Node3D = Node3D.new()
		spot_root.name = "EastPlazaStatueSpot_%d" % i
		spot_root.position = center + light_specs[i][0]
		geom.add_child(spot_root)
		# Floor housing — small dark disc
		var housing: MeshInstance3D = MeshInstance3D.new()
		var hmesh: CylinderMesh = CylinderMesh.new()
		hmesh.top_radius = 0.30
		hmesh.bottom_radius = 0.32
		hmesh.height = 0.20
		housing.mesh = hmesh
		housing.position = Vector3(0, 0.10, 0)
		var hmat: StandardMaterial3D = StandardMaterial3D.new()
		hmat.albedo_color = Color(0.10, 0.13, 0.16)
		hmat.metallic = 0.85
		hmat.roughness = 0.30
		hmat.emission_enabled = true
		hmat.emission = light_specs[i][1]
		hmat.emission_energy_multiplier = 1.0
		housing.material_override = hmat
		spot_root.add_child(housing)
		# Pointing toward the statue center (+y aim component)
		var spot: SpotLight3D = SpotLight3D.new()
		spot.position = Vector3(0, 0.25, 0)
		# Aim at statue body (~2m up at center)
		var to_statue: Vector3 = (center + Vector3(0, 2.0, 0)) - spot_root.position
		var aim_dir: Vector3 = to_statue.normalized()
		# look_at would set rotation; build manually instead
		var spot_yaw: float = atan2(aim_dir.x, aim_dir.z)
		var spot_pitch: float = -asin(aim_dir.y)
		spot.rotation = Vector3(spot_pitch, spot_yaw, 0)
		spot.light_color = light_specs[i][1]
		spot.light_energy = 3.0
		spot.spot_range = 8.0
		spot.spot_angle = 22.0
		spot.spot_attenuation = 1.4
		spot_root.add_child(spot)


func _build_plaza_ambient_lighting(geom: Node) -> void:
	## Epic-1 T98: 3 high omni fill lights spaced along the plaza length
	## bringing the overall light level up so all the new geometry reads
	## nicely. Soft cyan-tinted to reinforce the digital theme.
	var positions: Array[Vector3] = [
		Vector3(28, 8, 0),
		Vector3(36, 8, 0),
		Vector3(44, 8, 0),
	]
	for i in positions.size():
		var fill: OmniLight3D = OmniLight3D.new()
		fill.name = "EastPlazaFillLight_%d" % i
		fill.position = positions[i]
		fill.light_color = Color(0.75, 0.90, 1.0)
		fill.light_energy = 1.4
		fill.omni_range = 18.0
		fill.omni_attenuation = 1.6
		geom.add_child(fill)


func _build_epic1_plaque(geom: Node) -> void:
	## Epic-1 T99: a small commemorative plaque near the east gate marking
	## the completion of Epic 1. Stone tablet on a tiny pedestal with text.
	var plaque: Node3D = Node3D.new()
	plaque.name = "EastPlazaEpic1Plaque"
	plaque.position = Vector3(47, 0, 6)
	geom.add_child(plaque)
	# Tiny pedestal
	var ped_mat: StandardMaterial3D = StandardMaterial3D.new()
	ped_mat.albedo_color = Color(0.18, 0.22, 0.28)
	ped_mat.metallic = 0.55
	ped_mat.roughness = 0.45
	var ped: MeshInstance3D = MeshInstance3D.new()
	var pmesh: BoxMesh = BoxMesh.new()
	pmesh.size = Vector3(0.85, 0.50, 0.40)
	ped.mesh = pmesh
	ped.position = Vector3(0, 0.25, 0)
	ped.material_override = ped_mat
	plaque.add_child(ped)
	# Tilted stone tablet on top
	var tablet: MeshInstance3D = MeshInstance3D.new()
	var tmesh: BoxMesh = BoxMesh.new()
	tmesh.size = Vector3(0.85, 0.65, 0.06)
	tablet.mesh = tmesh
	tablet.position = Vector3(0, 0.85, 0)
	tablet.rotation = Vector3(deg_to_rad(-25), 0, 0)
	var tmat: StandardMaterial3D = StandardMaterial3D.new()
	tmat.albedo_color = Color(0.30, 0.34, 0.40)
	tmat.metallic = 0.65
	tmat.roughness = 0.30
	tmat.emission_enabled = true
	tmat.emission = Color(0.55, 0.95, 1.0)
	tmat.emission_energy_multiplier = 0.40
	tablet.material_override = tmat
	plaque.add_child(tablet)
	# Engraved text on tablet
	var label: Label3D = Label3D.new()
	label.text = "EPIC 01\nEAST PLAZA\nCOMPLETE"
	label.position = Vector3(0, 0.95, 0.18)
	label.rotation = Vector3(deg_to_rad(-25), 0, 0)
	label.modulate = Color(0.55, 0.95, 1.0)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 4
	label.font_size = 16
	label.no_depth_test = true
	plaque.add_child(label)
	# Collision
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(0.85, 0.60, 0.40)
	cs.shape = cb
	cs.position = Vector3(0, 0.30, 0)
	sb.add_child(cs)
	plaque.add_child(sb)


func _build_central_globbler_landmark(geom: Node) -> void:
	## Epic-1 T100 (FINALE): a massive central holographic Globbler
	## landmark hovering 10m above the plaza market core, slowly rotating.
	## Visible from anywhere in the district. Marks the East Plaza as
	## the player's home base in the most unmissable way possible.
	var landmark: Node3D = Node3D.new()
	landmark.name = "EastPlazaCentralLandmark"
	landmark.position = Vector3(32, 10, 0)
	geom.add_child(landmark)
	# Inner pivot for rotation
	var pivot: Node3D = Node3D.new()
	pivot.name = "RotationPivot"
	landmark.add_child(pivot)
	# Translucent holographic Globbler — large sphere body
	var holo_mat: StandardMaterial3D = StandardMaterial3D.new()
	holo_mat.albedo_color = Color(0.55, 0.85, 1.0, 0.50)
	holo_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	holo_mat.emission_enabled = true
	holo_mat.emission = Color(0.55, 0.95, 1.0)
	holo_mat.emission_energy_multiplier = 2.0
	holo_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	# Body sphere
	var body: MeshInstance3D = MeshInstance3D.new()
	var bmesh: SphereMesh = SphereMesh.new()
	bmesh.radius = 1.40
	bmesh.height = 2.80
	body.mesh = bmesh
	body.position = Vector3(0, 0, 0)
	body.material_override = holo_mat
	pivot.add_child(body)
	# 2 large eyes (white emissive)
	var eye_mat: StandardMaterial3D = StandardMaterial3D.new()
	eye_mat.albedo_color = Color(1, 1, 1, 0.9)
	eye_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	eye_mat.emission_enabled = true
	eye_mat.emission = Color(1, 1, 1)
	eye_mat.emission_energy_multiplier = 3.0
	eye_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for ex: float in [-0.45, 0.45]:
		var eye: MeshInstance3D = MeshInstance3D.new()
		var emesh: SphereMesh = SphereMesh.new()
		emesh.radius = 0.28
		emesh.height = 0.56
		eye.mesh = emesh
		eye.position = Vector3(ex, 0.30, 1.20)
		eye.material_override = eye_mat
		pivot.add_child(eye)
		# Pupil dot (cyan)
		var pupil: MeshInstance3D = MeshInstance3D.new()
		var pmesh: SphereMesh = SphereMesh.new()
		pmesh.radius = 0.12
		pmesh.height = 0.24
		pupil.mesh = pmesh
		pupil.position = Vector3(ex, 0.30, 1.40)
		var pmat: StandardMaterial3D = StandardMaterial3D.new()
		pmat.albedo_color = Color(0.30, 0.85, 1.0)
		pmat.emission_enabled = true
		pmat.emission = Color(0.55, 0.95, 1.0)
		pmat.emission_energy_multiplier = 3.5
		pmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		pupil.material_override = pmat
		pivot.add_child(pupil)
	# 4 orbital rings around the body at different tilts
	for i in 4:
		var ring: MeshInstance3D = MeshInstance3D.new()
		var rmesh: TorusMesh = TorusMesh.new()
		rmesh.inner_radius = 1.85 + i * 0.10
		rmesh.outer_radius = 1.95 + i * 0.10
		ring.mesh = rmesh
		ring.rotation = Vector3(deg_to_rad(15 + i * 35), deg_to_rad(i * 20), deg_to_rad(i * 25))
		var rmat: StandardMaterial3D = StandardMaterial3D.new()
		rmat.albedo_color = Color(0.55, 0.95, 1.0)
		rmat.emission_enabled = true
		rmat.emission = Color(0.55, 0.95, 1.0)
		rmat.emission_energy_multiplier = 2.4
		rmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		ring.material_override = rmat
		pivot.add_child(ring)
		# Counter-rotate each ring
		var ring_spin: Tween = create_tween().set_loops()
		var spin_dir: float = 1.0 if i % 2 == 0 else -1.0
		ring_spin.tween_property(ring, "rotation:z", deg_to_rad(i * 25) + TAU * spin_dir, 8.0 + i * 1.5)
	# Slow main rotation
	var spin: Tween = create_tween().set_loops()
	spin.tween_property(pivot, "rotation:y", TAU, 18.0)
	# Bobbing in place
	var bob: Tween = create_tween().set_loops()
	bob.tween_property(landmark, "position:y", 11.0, 3.0).set_ease(Tween.EASE_IN_OUT)
	bob.tween_property(landmark, "position:y", 10.0, 3.0).set_ease(Tween.EASE_IN_OUT)
	# Ground halo beneath the landmark
	var halo: MeshInstance3D = MeshInstance3D.new()
	var hmesh: TorusMesh = TorusMesh.new()
	hmesh.inner_radius = 3.5
	hmesh.outer_radius = 4.0
	halo.mesh = hmesh
	halo.position = Vector3(32, 0.05, 0)
	var hmat: StandardMaterial3D = StandardMaterial3D.new()
	hmat.albedo_color = Color(0.55, 0.95, 1.0)
	hmat.emission_enabled = true
	hmat.emission = Color(0.55, 0.95, 1.0)
	hmat.emission_energy_multiplier = 2.4
	hmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	halo.material_override = hmat
	geom.add_child(halo)
	# Pulse the ground halo
	var halo_pulse: Tween = create_tween().set_loops()
	halo_pulse.tween_property(halo, "scale", Vector3(1.20, 1.0, 1.20), 2.0).set_ease(Tween.EASE_IN_OUT)
	halo_pulse.tween_property(halo, "scale", Vector3(1.0, 1.0, 1.0), 2.0).set_ease(Tween.EASE_IN_OUT)
	# Real OmniLight at the landmark casting cyan light over the plaza
	var landmark_light: OmniLight3D = OmniLight3D.new()
	landmark_light.position = Vector3(0, 0, 0)
	landmark_light.light_color = Color(0.55, 0.95, 1.0)
	landmark_light.light_energy = 3.5
	landmark_light.omni_range = 25.0
	landmark_light.omni_attenuation = 1.4
	pivot.add_child(landmark_light)


static func _build_d2_crashed_ship(geom: Node) -> void:
	## Epic-2 T6: a large crashed data ship wreckage near the D2 center.
	## Tilted hull (a wide angled box) with broken wing fins, exposed
	## glowing engine core, and impact debris scattered around it.
	var ship: Node3D = Node3D.new()
	ship.name = "D2CrashedShip"
	ship.position = D2_CENTER + Vector3(8, 0, 8)
	ship.rotation = Vector3(deg_to_rad(-12), deg_to_rad(35), deg_to_rad(-8))
	geom.add_child(ship)
	# Hull material — dark armored grey
	var hull_mat: StandardMaterial3D = StandardMaterial3D.new()
	hull_mat.albedo_color = Color(0.16, 0.18, 0.22)
	hull_mat.metallic = 0.85
	hull_mat.roughness = 0.40
	# Main fuselage — tapered box (we use a prism for the front)
	var hull: MeshInstance3D = MeshInstance3D.new()
	var hmesh: BoxMesh = BoxMesh.new()
	hmesh.size = Vector3(6.0, 1.6, 2.4)
	hull.mesh = hmesh
	hull.position = Vector3(0, 0.95, 0)
	hull.material_override = hull_mat
	ship.add_child(hull)
	# Tapered nose (prism)
	var nose: MeshInstance3D = MeshInstance3D.new()
	var nmesh: PrismMesh = PrismMesh.new()
	nmesh.size = Vector3(2.4, 1.6, 2.4)
	nose.mesh = nmesh
	nose.position = Vector3(4.20, 0.95, 0)
	nose.rotation = Vector3(0, deg_to_rad(90), 0)
	nose.material_override = hull_mat
	ship.add_child(nose)
	# 2 wing fins
	for sz: float in [-1.6, 1.6]:
		var fin: MeshInstance3D = MeshInstance3D.new()
		var fmesh: BoxMesh = BoxMesh.new()
		fmesh.size = Vector3(2.6, 0.30, 1.2)
		fin.mesh = fmesh
		fin.position = Vector3(-0.5, 1.0, sz)
		fin.rotation = Vector3(0, 0, deg_to_rad(15 if sz > 0 else -15))
		fin.material_override = hull_mat
		ship.add_child(fin)
	# Exposed engine core at the back — sphere
	var core: MeshInstance3D = MeshInstance3D.new()
	var cmesh: SphereMesh = SphereMesh.new()
	cmesh.radius = 0.55
	cmesh.height = 1.10
	core.mesh = cmesh
	core.position = Vector3(-3.4, 0.95, 0)
	var cmat: StandardMaterial3D = StandardMaterial3D.new()
	cmat.albedo_color = Color(1.0, 0.40, 0.20)
	cmat.emission_enabled = true
	cmat.emission = Color(1.0, 0.55, 0.25)
	cmat.emission_energy_multiplier = 2.6
	cmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	core.material_override = cmat
	ship.add_child(core)
	var core_pulse: Tween = create_tween().set_loops()
	core_pulse.tween_property(core, "scale", Vector3(1.20, 1.20, 1.20), 0.85).set_ease(Tween.EASE_IN_OUT)
	core_pulse.tween_property(core, "scale", Vector3(1.0, 1.0, 1.0), 0.85).set_ease(Tween.EASE_IN_OUT)
	# Cyan cockpit window
	var cockpit: MeshInstance3D = MeshInstance3D.new()
	var cock_mesh: BoxMesh = BoxMesh.new()
	cock_mesh.size = Vector3(1.4, 0.40, 1.4)
	cockpit.mesh = cock_mesh
	cockpit.position = Vector3(2.40, 1.85, 0)
	var cock_mat: StandardMaterial3D = StandardMaterial3D.new()
	cock_mat.albedo_color = Color(0.20, 0.50, 0.70, 0.55)
	cock_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	cock_mat.emission_enabled = true
	cock_mat.emission = Color(0.30, 0.85, 1.0)
	cock_mat.emission_energy_multiplier = 1.4
	cock_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	cockpit.material_override = cock_mat
	ship.add_child(cockpit)
	# Smoke from the engine
	var smoke: GPUParticles3D = GPUParticles3D.new()
	smoke.amount = 30
	smoke.lifetime = 3.5
	smoke.position = Vector3(-3.4, 1.5, 0)
	var pmat: ParticleProcessMaterial = ParticleProcessMaterial.new()
	pmat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	pmat.emission_sphere_radius = 0.30
	pmat.direction = Vector3(0, 1, 0)
	pmat.spread = 25.0
	pmat.initial_velocity_min = 0.85
	pmat.initial_velocity_max = 1.4
	pmat.gravity = Vector3.ZERO
	pmat.scale_min = 0.30
	pmat.scale_max = 0.65
	pmat.color = Color(0.40, 0.40, 0.50, 0.55)
	smoke.process_material = pmat
	var sm_mesh: SphereMesh = SphereMesh.new()
	sm_mesh.radius = 0.30
	sm_mesh.height = 0.60
	var sm_mat: StandardMaterial3D = StandardMaterial3D.new()
	sm_mat.albedo_color = Color(0.40, 0.40, 0.50, 0.55)
	sm_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	sm_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	sm_mesh.material = sm_mat
	smoke.draw_pass_1 = sm_mesh
	ship.add_child(smoke)
	# Collision around hull
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(8.0, 2.5, 3.5)
	cs.shape = cb
	cs.position = Vector3(0, 1.0, 0)
	sb.add_child(cs)
	ship.add_child(sb)


static func _build_d2_glitch_enemies(geom: Node) -> void:
	## Epic-2 T7: 3 procedural "glitch enemy" decorative critters pacing
	## the D2 perimeter. Each is a small angular sphere with magenta eyes
	## that hops on a tween — telegraphs combat danger ahead without
	## actually wiring up enemy AI yet.
	var positions: Array[Vector3] = [
		D2_CENTER + Vector3(-4, 0, 12),
		D2_CENTER + Vector3(15, 0, -8),
		D2_CENTER + Vector3(20, 0, 14),
	]
	for i in positions.size():
		var enemy: Node3D = Node3D.new()
		enemy.name = "D2GlitchEnemy_%d" % i
		enemy.position = positions[i]
		geom.add_child(enemy)
		# Faceted body — use prism (3-sided) for jagged look
		var body: MeshInstance3D = MeshInstance3D.new()
		var bmesh: PrismMesh = PrismMesh.new()
		bmesh.size = Vector3(0.85, 0.85, 0.85)
		body.mesh = bmesh
		body.position = Vector3(0, 0.50, 0)
		var bmat: StandardMaterial3D = StandardMaterial3D.new()
		bmat.albedo_color = Color(0.40, 0.10, 0.30)
		bmat.emission_enabled = true
		bmat.emission = Color(1.0, 0.30, 0.55)
		bmat.emission_energy_multiplier = 1.4
		bmat.metallic = 0.40
		bmat.roughness = 0.30
		body.material_override = bmat
		enemy.add_child(body)
		# 2 magenta eyes
		var eye_mat: StandardMaterial3D = StandardMaterial3D.new()
		eye_mat.albedo_color = Color(1.0, 0.30, 0.55)
		eye_mat.emission_enabled = true
		eye_mat.emission = Color(1.0, 0.40, 0.65)
		eye_mat.emission_energy_multiplier = 2.6
		eye_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		for ex: float in [-0.15, 0.15]:
			var eye: MeshInstance3D = MeshInstance3D.new()
			var emesh: SphereMesh = SphereMesh.new()
			emesh.radius = 0.07
			emesh.height = 0.14
			eye.mesh = emesh
			eye.position = Vector3(ex, 0.65, 0.30)
			eye.material_override = eye_mat
			enemy.add_child(eye)
		# Hop tween + spin
		var hop: Tween = create_tween().set_loops()
		hop.tween_property(body, "position:y", 1.10, 0.45).set_ease(Tween.EASE_OUT)
		hop.tween_property(body, "position:y", 0.50, 0.35).set_ease(Tween.EASE_IN)
		hop.tween_interval(0.4 + i * 0.2)
		# Slow patrol path
		var origin: Vector3 = positions[i]
		var patrol: Tween = create_tween().set_loops()
		patrol.tween_property(enemy, "position", origin + Vector3(2, 0, 2), 3.0)
		patrol.tween_property(enemy, "position", origin + Vector3(-2, 0, 2), 3.0)
		patrol.tween_property(enemy, "position", origin + Vector3(-2, 0, -2), 3.0)
		patrol.tween_property(enemy, "position", origin, 3.0)


static func _build_d2_flicker_lamps(geom: Node) -> void:
	## Epic-2 T8: 4 broken street lamps across D2 with flickering on/off
	## tweens and slightly leaning angles. Sells "the power's failing here".
	var positions: Array[Vector3] = [
		D2_CENTER + Vector3(-15, 0, -10),
		D2_CENTER + Vector3(-5, 0, 14),
		D2_CENTER + Vector3(10, 0, -14),
		D2_CENTER + Vector3(20, 0, 6),
	]
	for i in positions.size():
		var lamp: Node3D = Node3D.new()
		lamp.name = "D2FlickerLamp_%d" % i
		lamp.position = positions[i]
		lamp.rotation = Vector3(deg_to_rad(randf_range(-12, 12)), 0, deg_to_rad(randf_range(-12, 12)))
		geom.add_child(lamp)
		# Pole
		var pole_mat: StandardMaterial3D = StandardMaterial3D.new()
		pole_mat.albedo_color = Color(0.10, 0.10, 0.12)
		pole_mat.metallic = 0.85
		pole_mat.roughness = 0.50
		var pole: MeshInstance3D = MeshInstance3D.new()
		var pmesh: CylinderMesh = CylinderMesh.new()
		pmesh.top_radius = 0.07
		pmesh.bottom_radius = 0.10
		pmesh.height = 3.4
		pole.mesh = pmesh
		pole.position = Vector3(0, 1.7, 0)
		pole.material_override = pole_mat
		lamp.add_child(pole)
		# Lamp head box at top
		var head: MeshInstance3D = MeshInstance3D.new()
		var hmesh: BoxMesh = BoxMesh.new()
		hmesh.size = Vector3(0.45, 0.30, 0.45)
		head.mesh = hmesh
		head.position = Vector3(0, 3.55, 0)
		head.material_override = pole_mat
		lamp.add_child(head)
		# Bulb (the flicker light)
		var bulb: MeshInstance3D = MeshInstance3D.new()
		var bmesh: SphereMesh = SphereMesh.new()
		bmesh.radius = 0.16
		bmesh.height = 0.32
		bulb.mesh = bmesh
		bulb.position = Vector3(0, 3.30, 0)
		var bmat: StandardMaterial3D = StandardMaterial3D.new()
		bmat.albedo_color = Color(1.0, 0.85, 0.55)
		bmat.emission_enabled = true
		bmat.emission = Color(1.0, 0.85, 0.55)
		bmat.emission_energy_multiplier = 2.0
		bmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		bulb.material_override = bmat
		lamp.add_child(bulb)
		# Real light
		var light: OmniLight3D = OmniLight3D.new()
		light.position = Vector3(0, 3.30, 0)
		light.light_color = Color(1.0, 0.85, 0.55)
		light.light_energy = 1.4
		light.omni_range = 6.0
		lamp.add_child(light)
		# Flicker visibility on bulb + light together
		var flicker: Tween = create_tween().set_loops()
		flicker.tween_interval(0.4 + randf() * 1.5)
		flicker.tween_property(bulb, "visible", false, 0.0)
		flicker.tween_property(light, "visible", false, 0.0)
		flicker.tween_interval(0.08)
		flicker.tween_property(bulb, "visible", true, 0.0)
		flicker.tween_property(light, "visible", true, 0.0)
		flicker.tween_interval(0.05)
		flicker.tween_property(bulb, "visible", false, 0.0)
		flicker.tween_property(light, "visible", false, 0.0)
		flicker.tween_interval(0.18)
		flicker.tween_property(bulb, "visible", true, 0.0)
		flicker.tween_property(light, "visible", true, 0.0)
		# Collision
		var sb: StaticBody3D = StaticBody3D.new()
		var cs: CollisionShape3D = CollisionShape3D.new()
		var cap: CapsuleShape3D = CapsuleShape3D.new()
		cap.radius = 0.20
		cap.height = 3.4
		cs.shape = cap
		cs.position = Vector3(0, 1.7, 0)
		sb.add_child(cs)
		lamp.add_child(sb)


static func _build_d2_junk_pile(geom: Node) -> void:
	## Epic-2 T9: a heap of broken hardware — stacked crushed boxes, loose
	## cables coiling out, the occasional emissive flicker. Tells the
	## "this place is a junkyard" story instantly.
	var pile: Node3D = Node3D.new()
	pile.name = "D2JunkPile"
	pile.position = D2_CENTER + Vector3(-6, 0, -14)
	geom.add_child(pile)
	# 6 stacked broken boxes at random sizes/orientations
	var server_mat: StandardMaterial3D = StandardMaterial3D.new()
	server_mat.albedo_color = Color(0.18, 0.20, 0.24)
	server_mat.metallic = 0.65
	server_mat.roughness = 0.50
	var server_specs: Array = [
		[Vector3(0, 0.30, 0), Vector3(1.4, 0.55, 0.85), Vector3(0, 0, 0)],
		[Vector3(0.5, 0.85, 0.2), Vector3(1.0, 0.40, 0.85), Vector3(0, 0, deg_to_rad(8))],
		[Vector3(-0.3, 1.20, -0.2), Vector3(0.85, 0.45, 0.70), Vector3(0, deg_to_rad(15), deg_to_rad(-12))],
		[Vector3(0.7, 0.30, -0.7), Vector3(0.65, 0.55, 0.65), Vector3(0, deg_to_rad(35), 0)],
		[Vector3(-0.6, 0.30, 0.5), Vector3(0.85, 0.55, 0.70), Vector3(0, deg_to_rad(-20), 0)],
		[Vector3(0.2, 1.65, 0.0), Vector3(0.65, 0.40, 0.50), Vector3(0, 0, deg_to_rad(20))],
	]
	for spec in server_specs:
		var server: MeshInstance3D = MeshInstance3D.new()
		var smesh: BoxMesh = BoxMesh.new()
		smesh.size = spec[1]
		server.mesh = smesh
		server.position = spec[0]
		server.rotation = spec[2]
		server.material_override = server_mat
		pile.add_child(server)
		# Small status LED on each (red or green)
		var led: MeshInstance3D = MeshInstance3D.new()
		var lmesh: SphereMesh = SphereMesh.new()
		lmesh.radius = 0.04
		lmesh.height = 0.08
		led.mesh = lmesh
		var spec_size: Vector3 = spec[1]
		led.position = (spec[0] as Vector3) + Vector3(0, 0, spec_size.z * 0.5 + 0.04)
		var lmat: StandardMaterial3D = StandardMaterial3D.new()
		var c: Color = Color(1.0, 0.30, 0.30) if randi() % 2 == 0 else Color(0.30, 1.0, 0.40)
		lmat.albedo_color = c
		lmat.emission_enabled = true
		lmat.emission = c
		lmat.emission_energy_multiplier = 2.6
		lmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		led.material_override = lmat
		pile.add_child(led)
	# Loose cables — 3 thin cylinders snaking out
	var cable_mat: StandardMaterial3D = StandardMaterial3D.new()
	cable_mat.albedo_color = Color(0.10, 0.10, 0.12)
	cable_mat.metallic = 0.30
	for c in 3:
		var cable: MeshInstance3D = MeshInstance3D.new()
		var cmesh: CylinderMesh = CylinderMesh.new()
		cmesh.top_radius = 0.04
		cmesh.bottom_radius = 0.04
		cmesh.height = 1.2 + c * 0.3
		cable.mesh = cmesh
		var angle: float = (float(c) / 3.0) * TAU
		cable.position = Vector3(cos(angle) * 0.85, 0.10, sin(angle) * 0.85)
		cable.rotation = Vector3(deg_to_rad(85), angle, 0)
		cable.material_override = cable_mat
		pile.add_child(cable)
	# Collision around the whole pile
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(2.6, 2.0, 2.0)
	cs.shape = cb
	cs.position = Vector3(0, 1.0, 0)
	sb.add_child(cs)
	pile.add_child(sb)


static func _build_d2_abandoned_kiosk(geom: Node) -> void:
	## Epic-2 T10: an abandoned roadside terminal kiosk. The screen is dark
	## and cracked, the structure is leaning, and a "OUT OF ORDER" tag
	## flickers above it.
	var kiosk: Node3D = Node3D.new()
	kiosk.name = "D2AbandonedKiosk"
	kiosk.position = D2_CENTER + Vector3(-10, 0, -2)
	kiosk.rotation = Vector3(0, 0, deg_to_rad(-6))
	geom.add_child(kiosk)
	# Stand
	var stand_mat: StandardMaterial3D = StandardMaterial3D.new()
	stand_mat.albedo_color = Color(0.18, 0.16, 0.14)
	stand_mat.metallic = 0.55
	stand_mat.roughness = 0.55
	var stand: MeshInstance3D = MeshInstance3D.new()
	var smesh: BoxMesh = BoxMesh.new()
	smesh.size = Vector3(0.70, 1.40, 0.50)
	stand.mesh = smesh
	stand.position = Vector3(0, 0.70, 0)
	stand.material_override = stand_mat
	kiosk.add_child(stand)
	# Cracked dark screen
	var screen: MeshInstance3D = MeshInstance3D.new()
	var scr_mesh: BoxMesh = BoxMesh.new()
	scr_mesh.size = Vector3(0.55, 0.50, 0.04)
	screen.mesh = scr_mesh
	screen.position = Vector3(0, 1.20, 0.27)
	var scr_mat: StandardMaterial3D = StandardMaterial3D.new()
	scr_mat.albedo_color = Color(0.04, 0.05, 0.08)
	scr_mat.emission_enabled = true
	scr_mat.emission = Color(0.20, 0.20, 0.30)
	scr_mat.emission_energy_multiplier = 0.30
	scr_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	screen.material_override = scr_mat
	kiosk.add_child(screen)
	# Diagonal crack across the screen
	var crack_mat: StandardMaterial3D = StandardMaterial3D.new()
	crack_mat.albedo_color = Color(0.95, 0.95, 1.0)
	crack_mat.emission_enabled = true
	crack_mat.emission = Color(0.95, 0.95, 1.0)
	crack_mat.emission_energy_multiplier = 1.4
	crack_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for i in 2:
		var crack: MeshInstance3D = MeshInstance3D.new()
		var cmesh: BoxMesh = BoxMesh.new()
		cmesh.size = Vector3(0.50, 0.02, 0.01)
		crack.mesh = cmesh
		crack.position = Vector3(0, 1.20 + i * 0.05, 0.30)
		crack.rotation = Vector3(0, 0, deg_to_rad(-25 + i * 15))
		crack.material_override = crack_mat
		kiosk.add_child(crack)
	# OUT OF ORDER hanging tag above the kiosk
	var tag: MeshInstance3D = MeshInstance3D.new()
	var tmesh: BoxMesh = BoxMesh.new()
	tmesh.size = Vector3(0.85, 0.30, 0.05)
	tag.mesh = tmesh
	tag.position = Vector3(0, 2.0, 0.30)
	var tmat: StandardMaterial3D = StandardMaterial3D.new()
	tmat.albedo_color = Color(0.85, 0.20, 0.20)
	tmat.emission_enabled = true
	tmat.emission = Color(1.0, 0.30, 0.20)
	tmat.emission_energy_multiplier = 1.4
	tmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	tag.material_override = tmat
	kiosk.add_child(tag)
	# Tag label
	var label: Label3D = Label3D.new()
	label.text = "OUT OF\nORDER"
	label.position = Vector3(0, 2.0, 0.34)
	label.modulate = Color(1, 1, 1)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 4
	label.font_size = 14
	label.no_depth_test = true
	kiosk.add_child(label)
	# Flicker tag
	var flicker: Tween = create_tween().set_loops()
	flicker.tween_property(tmat, "emission_energy_multiplier", 0.3, 0.4).set_ease(Tween.EASE_IN_OUT)
	flicker.tween_property(tmat, "emission_energy_multiplier", 1.6, 0.3).set_ease(Tween.EASE_IN_OUT)
	flicker.tween_interval(1.0 + randf() * 1.0)
	# Collision around stand
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(0.70, 1.40, 0.50)
	cs.shape = cb
	cs.position = Vector3(0, 0.70, 0)
	sb.add_child(cs)
	kiosk.add_child(sb)


static func _build_d2_craters(geom: Node) -> void:
	## Epic-2 T11: 4 ground impact craters scattered around D2. Each is a
	## flat torus rim slightly recessed with a glowing inner disc.
	var positions: Array[Vector3] = [
		D2_CENTER + Vector3(-12, 0.04, 8),
		D2_CENTER + Vector3(2, 0.04, -12),
		D2_CENTER + Vector3(16, 0.04, 10),
		D2_CENTER + Vector3(22, 0.04, -6),
	]
	for i in positions.size():
		var crater: Node3D = Node3D.new()
		crater.name = "D2Crater_%d" % i
		crater.position = positions[i]
		geom.add_child(crater)
		# Outer rim torus
		var rim: MeshInstance3D = MeshInstance3D.new()
		var rmesh: TorusMesh = TorusMesh.new()
		rmesh.inner_radius = 1.20
		rmesh.outer_radius = 1.50
		rim.mesh = rmesh
		rim.position = Vector3(0, 0.05, 0)
		var rmat: StandardMaterial3D = StandardMaterial3D.new()
		rmat.albedo_color = Color(0.20, 0.10, 0.06)
		rmat.metallic = 0.55
		rmat.roughness = 0.55
		rmat.emission_enabled = true
		rmat.emission = Color(1.0, 0.40, 0.10)
		rmat.emission_energy_multiplier = 0.95
		rim.material_override = rmat
		crater.add_child(rim)
		# Inner glowing disc
		var disc: MeshInstance3D = MeshInstance3D.new()
		var dmesh: CylinderMesh = CylinderMesh.new()
		dmesh.top_radius = 1.15
		dmesh.bottom_radius = 1.15
		dmesh.height = 0.04
		disc.mesh = dmesh
		disc.position = Vector3(0, 0.02, 0)
		var dmat: StandardMaterial3D = StandardMaterial3D.new()
		dmat.albedo_color = Color(1.0, 0.40, 0.10)
		dmat.emission_enabled = true
		dmat.emission = Color(1.0, 0.55, 0.15)
		dmat.emission_energy_multiplier = 1.6
		dmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		disc.material_override = dmat
		crater.add_child(disc)
		# Pulse the disc
		var pulse: Tween = create_tween().set_loops()
		var ps: float = 1.4 + i * 0.2
		pulse.tween_property(disc, "scale", Vector3(1.10, 1.0, 1.10), ps).set_ease(Tween.EASE_IN_OUT)
		pulse.tween_property(disc, "scale", Vector3(0.95, 1.0, 0.95), ps).set_ease(Tween.EASE_IN_OUT)


static func _build_d2_barricade(geom: Node) -> void:
	## Epic-2 T12: an overturned crate barricade — 5 angled crates stacked
	## haphazardly across part of the road, partially blocking passage.
	## Glowing red warning bars stretched between two posts.
	var bar: Node3D = Node3D.new()
	bar.name = "D2Barricade"
	bar.position = D2_CENTER + Vector3(-2, 0, 0)
	geom.add_child(bar)
	# 5 stacked tilted crates
	var crate_mat: StandardMaterial3D = StandardMaterial3D.new()
	crate_mat.albedo_color = Color(0.30, 0.18, 0.08)
	crate_mat.metallic = 0.30
	crate_mat.roughness = 0.55
	var crate_specs: Array = [
		[Vector3(-1.0, 0.40, 0.0), Vector3(0, deg_to_rad(15), deg_to_rad(-8))],
		[Vector3(-0.20, 0.40, 0.5), Vector3(0, deg_to_rad(-20), 0)],
		[Vector3(0.6, 0.40, -0.3), Vector3(0, deg_to_rad(35), 0)],
		[Vector3(-0.40, 1.10, 0.2), Vector3(0, deg_to_rad(10), deg_to_rad(15))],
		[Vector3(0.30, 1.10, -0.4), Vector3(0, deg_to_rad(-25), 0)],
	]
	for spec in crate_specs:
		var crate: MeshInstance3D = MeshInstance3D.new()
		var cmesh: BoxMesh = BoxMesh.new()
		cmesh.size = Vector3(0.85, 0.80, 0.85)
		crate.mesh = cmesh
		crate.position = spec[0]
		crate.rotation = spec[1]
		crate.material_override = crate_mat
		bar.add_child(crate)
	# 2 metal posts on either side
	var post_mat: StandardMaterial3D = StandardMaterial3D.new()
	post_mat.albedo_color = Color(0.10, 0.13, 0.16)
	post_mat.metallic = 0.85
	for sx: float in [-1.8, 1.8]:
		var post: MeshInstance3D = MeshInstance3D.new()
		var pmesh: CylinderMesh = CylinderMesh.new()
		pmesh.top_radius = 0.07
		pmesh.bottom_radius = 0.10
		pmesh.height = 1.6
		post.mesh = pmesh
		post.position = Vector3(sx, 0.80, 0)
		post.material_override = post_mat
		bar.add_child(post)
	# 2 horizontal red warning bars between the posts
	var warn_mat: StandardMaterial3D = StandardMaterial3D.new()
	warn_mat.albedo_color = Color(1.0, 0.20, 0.20)
	warn_mat.emission_enabled = true
	warn_mat.emission = Color(1.0, 0.40, 0.30)
	warn_mat.emission_energy_multiplier = 1.8
	warn_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for wy: float in [0.55, 1.10]:
		var warn: MeshInstance3D = MeshInstance3D.new()
		var wmesh: BoxMesh = BoxMesh.new()
		wmesh.size = Vector3(3.6, 0.10, 0.06)
		warn.mesh = wmesh
		warn.position = Vector3(0, wy, 0)
		warn.material_override = warn_mat
		bar.add_child(warn)
	# Pulse warning bars
	var pulse: Tween = create_tween().set_loops()
	pulse.tween_property(warn_mat, "emission_energy_multiplier", 2.6, 0.6).set_ease(Tween.EASE_IN_OUT)
	pulse.tween_property(warn_mat, "emission_energy_multiplier", 0.8, 0.6).set_ease(Tween.EASE_IN_OUT)
	# Collision around the whole barricade
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(3.6, 1.6, 1.4)
	cs.shape = cb
	cs.position = Vector3(0, 0.80, 0)
	sb.add_child(cs)
	bar.add_child(sb)


static func _build_d2_toxic_puddles(geom: Node) -> void:
	## Epic-2 T13: 5 toxic glowing puddles on the D2 ground. Each is a
	## low elliptical disc of bright green emissive liquid that pulses
	## scale to feel slimy and unstable.
	var positions: Array[Vector3] = [
		D2_CENTER + Vector3(-8, 0.04, 0),
		D2_CENTER + Vector3(6, 0.04, 6),
		D2_CENTER + Vector3(12, 0.04, -10),
		D2_CENTER + Vector3(18, 0.04, 4),
		D2_CENTER + Vector3(22, 0.04, 12),
	]
	for i in positions.size():
		var puddle: MeshInstance3D = MeshInstance3D.new()
		puddle.name = "D2ToxicPuddle_%d" % i
		var pmesh: CylinderMesh = CylinderMesh.new()
		pmesh.top_radius = 0.65 + randf_range(0, 0.30)
		pmesh.bottom_radius = pmesh.top_radius
		pmesh.height = 0.06
		puddle.mesh = pmesh
		puddle.position = positions[i]
		puddle.scale = Vector3(1.0 + randf_range(-0.30, 0.30), 1.0, 1.0 + randf_range(-0.30, 0.30))
		var pmat: StandardMaterial3D = StandardMaterial3D.new()
		pmat.albedo_color = Color(0.20, 0.95, 0.30)
		pmat.emission_enabled = true
		pmat.emission = Color(0.40, 1.0, 0.30)
		pmat.emission_energy_multiplier = 1.8
		pmat.metallic = 0.30
		pmat.roughness = 0.10
		pmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		puddle.material_override = pmat
		geom.add_child(puddle)
		# Pulse scale to feel like sloshing
		var pulse: Tween = create_tween().set_loops()
		var sx: float = puddle.scale.x
		var sz: float = puddle.scale.z
		var pp: float = 1.4 + i * 0.2
		pulse.tween_property(puddle, "scale", Vector3(sx * 1.10, 1.0, sz * 0.92), pp).set_ease(Tween.EASE_IN_OUT)
		pulse.tween_property(puddle, "scale", Vector3(sx * 0.92, 1.0, sz * 1.10), pp).set_ease(Tween.EASE_IN_OUT)


static func _build_d2_falling_sparks(geom: Node) -> void:
	## Epic-2 T14: ambient falling sparks raining down from high above the
	## district — yellow tiny particles falling slowly with gravity. Sells
	## "this place is electrically unstable".
	var sparks: GPUParticles3D = GPUParticles3D.new()
	sparks.name = "D2FallingSparks"
	sparks.position = D2_CENTER + Vector3(0, 12, 0)
	sparks.amount = 60
	sparks.lifetime = 4.5
	sparks.preprocess = 2.0
	var pmat: ParticleProcessMaterial = ParticleProcessMaterial.new()
	pmat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	pmat.emission_box_extents = Vector3(20, 0.5, 18)
	pmat.direction = Vector3(0, -1, 0)
	pmat.spread = 12.0
	pmat.initial_velocity_min = 0.85
	pmat.initial_velocity_max = 1.40
	pmat.gravity = Vector3(0, -1.5, 0)
	pmat.scale_min = 0.04
	pmat.scale_max = 0.10
	pmat.color = Color(1.0, 0.85, 0.30, 1.0)
	sparks.process_material = pmat
	var spark_mesh: SphereMesh = SphereMesh.new()
	spark_mesh.radius = 0.05
	spark_mesh.height = 0.10
	var spark_mat: StandardMaterial3D = StandardMaterial3D.new()
	spark_mat.albedo_color = Color(1.0, 0.85, 0.30)
	spark_mat.emission_enabled = true
	spark_mat.emission = Color(1.0, 0.95, 0.40)
	spark_mat.emission_energy_multiplier = 2.6
	spark_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	spark_mesh.material = spark_mat
	sparks.draw_pass_1 = spark_mesh
	geom.add_child(sparks)


static func _build_d2_scavenger_npc(town: Node) -> void:
	## Epic-2 T15: a scavenger NPC bent over the junk pile sifting through
	## debris. Crouched body, smaller than the wanderer, with a glowing
	## flashlight cone pointed at the ground.
	var slots: Node3D = town.get_node_or_null("%NPCSlots") as Node3D
	if slots == null:
		return
	var scav: Node3D = Node3D.new()
	scav.name = "D2Scavenger"
	scav.position = D2_CENTER + Vector3(-6, 0, -12)
	slots.add_child(scav)
	# Crouched body — shorter capsule
	var body: MeshInstance3D = MeshInstance3D.new()
	var bmesh: CapsuleMesh = CapsuleMesh.new()
	bmesh.radius = 0.40
	bmesh.height = 0.85
	body.mesh = bmesh
	body.position = Vector3(0, 0.45, 0)
	body.rotation = Vector3(deg_to_rad(35), 0, 0)
	var bmat: StandardMaterial3D = StandardMaterial3D.new()
	bmat.albedo_color = Color(0.28, 0.20, 0.14)
	bmat.metallic = 0.10
	bmat.roughness = 0.65
	body.material_override = bmat
	scav.add_child(body)
	# Goggles head — smaller box
	var head: MeshInstance3D = MeshInstance3D.new()
	var hmesh: BoxMesh = BoxMesh.new()
	hmesh.size = Vector3(0.40, 0.32, 0.40)
	head.mesh = hmesh
	head.position = Vector3(0, 0.85, 0.45)
	var hmat: StandardMaterial3D = StandardMaterial3D.new()
	hmat.albedo_color = Color(0.22, 0.16, 0.10)
	hmat.metallic = 0.30
	hmat.roughness = 0.60
	head.material_override = hmat
	scav.add_child(head)
	# 2 cyan goggle lenses
	var goggle_mat: StandardMaterial3D = StandardMaterial3D.new()
	goggle_mat.albedo_color = Color(0.30, 0.85, 1.0)
	goggle_mat.emission_enabled = true
	goggle_mat.emission = Color(0.55, 0.95, 1.0)
	goggle_mat.emission_energy_multiplier = 2.0
	goggle_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for ex: float in [-0.10, 0.10]:
		var lens: MeshInstance3D = MeshInstance3D.new()
		var lmesh: SphereMesh = SphereMesh.new()
		lmesh.radius = 0.06
		lmesh.height = 0.12
		lens.mesh = lmesh
		lens.position = Vector3(ex, 0.85, 0.66)
		lens.material_override = goggle_mat
		scav.add_child(lens)
	# Flashlight pointed at ground
	var flashlight_root: Node3D = Node3D.new()
	flashlight_root.position = Vector3(0.30, 0.50, 0.40)
	scav.add_child(flashlight_root)
	# Flashlight body
	var flash: MeshInstance3D = MeshInstance3D.new()
	var fmesh: CylinderMesh = CylinderMesh.new()
	fmesh.top_radius = 0.06
	fmesh.bottom_radius = 0.06
	fmesh.height = 0.30
	flash.mesh = fmesh
	flash.rotation = Vector3(deg_to_rad(80), 0, 0)
	flash.material_override = bmat
	flashlight_root.add_child(flash)
	# Flashlight beam (visible cone)
	var beam: MeshInstance3D = MeshInstance3D.new()
	var beam_mesh: CylinderMesh = CylinderMesh.new()
	beam_mesh.top_radius = 0.06
	beam_mesh.bottom_radius = 0.30
	beam_mesh.height = 0.55
	beam.mesh = beam_mesh
	beam.position = Vector3(0, -0.30, 0.30)
	beam.rotation = Vector3(deg_to_rad(80), 0, 0)
	var beam_mat: StandardMaterial3D = StandardMaterial3D.new()
	beam_mat.albedo_color = Color(1.0, 0.95, 0.55, 0.30)
	beam_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	beam_mat.emission_enabled = true
	beam_mat.emission = Color(1.0, 0.95, 0.55)
	beam_mat.emission_energy_multiplier = 1.4
	beam_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	beam.material_override = beam_mat
	flashlight_root.add_child(beam)
	# Sifting hand bobble — body rocks slightly
	var rock: Tween = create_tween().set_loops()
	rock.tween_property(scav, "rotation:y", deg_to_rad(15), 1.4).set_ease(Tween.EASE_IN_OUT)
	rock.tween_property(scav, "rotation:y", deg_to_rad(-15), 1.4).set_ease(Tween.EASE_IN_OUT)
	# Name billboard
	var label: Label3D = Label3D.new()
	label.text = "Scavenger"
	label.position = Vector3(0, 1.4, 0)
	label.modulate = Color(0.85, 0.85, 0.55)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 18
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	scav.add_child(label)


static func _build_d2_trial_pit(geom: Node) -> void:
	## Epic-2 T16: a sunken combat trial pit at D2 center+(15, 0, 0).
	## A 6m wide cylinder hole rimmed by a glowing orange torus + 4 spike
	## hazards around the rim. The center has 2 placeholder enemy spawn
	## markers (small red glowing pads).
	var pit: Node3D = Node3D.new()
	pit.name = "D2TrialPit"
	pit.position = D2_CENTER + Vector3(15, 0, 0)
	geom.add_child(pit)
	# Wide flat dark disc as the pit floor (sunken slightly)
	var floor_mat: StandardMaterial3D = StandardMaterial3D.new()
	floor_mat.albedo_color = Color(0.10, 0.06, 0.04)
	floor_mat.metallic = 0.45
	floor_mat.roughness = 0.55
	floor_mat.emission_enabled = true
	floor_mat.emission = Color(0.85, 0.30, 0.10)
	floor_mat.emission_energy_multiplier = 0.35
	var pit_floor: MeshInstance3D = MeshInstance3D.new()
	var fmesh: CylinderMesh = CylinderMesh.new()
	fmesh.top_radius = 3.0
	fmesh.bottom_radius = 3.0
	fmesh.height = 0.10
	pit_floor.mesh = fmesh
	pit_floor.position = Vector3(0, 0.06, 0)
	pit_floor.material_override = floor_mat
	pit.add_child(pit_floor)
	# Glowing rim torus
	var rim: MeshInstance3D = MeshInstance3D.new()
	var rmesh: TorusMesh = TorusMesh.new()
	rmesh.inner_radius = 3.0
	rmesh.outer_radius = 3.30
	rim.mesh = rmesh
	rim.position = Vector3(0, 0.12, 0)
	var rmat: StandardMaterial3D = StandardMaterial3D.new()
	rmat.albedo_color = Color(1.0, 0.40, 0.10)
	rmat.emission_enabled = true
	rmat.emission = Color(1.0, 0.55, 0.15)
	rmat.emission_energy_multiplier = 1.8
	rmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	rim.material_override = rmat
	pit.add_child(rim)
	# Pulse the rim
	var pulse: Tween = create_tween().set_loops()
	pulse.tween_property(rmat, "emission_energy_multiplier", 2.6, 1.6).set_ease(Tween.EASE_IN_OUT)
	pulse.tween_property(rmat, "emission_energy_multiplier", 1.0, 1.6).set_ease(Tween.EASE_IN_OUT)
	# 4 spike hazards around the rim (n/s/e/w)
	var spike_mat: StandardMaterial3D = StandardMaterial3D.new()
	spike_mat.albedo_color = Color(0.16, 0.18, 0.22)
	spike_mat.metallic = 0.85
	spike_mat.roughness = 0.30
	spike_mat.emission_enabled = true
	spike_mat.emission = Color(1.0, 0.40, 0.20)
	spike_mat.emission_energy_multiplier = 0.45
	for i in 4:
		var angle: float = (float(i) / 4.0) * TAU
		var spike: MeshInstance3D = MeshInstance3D.new()
		var smesh: PrismMesh = PrismMesh.new()
		smesh.size = Vector3(0.40, 1.40, 0.40)
		spike.mesh = smesh
		spike.position = Vector3(cos(angle) * 3.40, 0.70, sin(angle) * 3.40)
		spike.material_override = spike_mat
		pit.add_child(spike)
		# Collision on each spike
		var sp_sb: StaticBody3D = StaticBody3D.new()
		var sp_cs: CollisionShape3D = CollisionShape3D.new()
		var sp_cb: BoxShape3D = BoxShape3D.new()
		sp_cb.size = Vector3(0.40, 1.40, 0.40)
		sp_cs.shape = sp_cb
		sp_cs.position = Vector3(cos(angle) * 3.40, 0.70, sin(angle) * 3.40)
		sp_sb.add_child(sp_cs)
		pit.add_child(sp_sb)
	# 2 placeholder enemy spawn pads (small red glowing discs in the floor)
	for sx: float in [-0.85, 0.85]:
		var pad: MeshInstance3D = MeshInstance3D.new()
		var pmesh: CylinderMesh = CylinderMesh.new()
		pmesh.top_radius = 0.40
		pmesh.bottom_radius = 0.40
		pmesh.height = 0.06
		pad.mesh = pmesh
		pad.position = Vector3(sx, 0.13, 0)
		var pmat: StandardMaterial3D = StandardMaterial3D.new()
		pmat.albedo_color = Color(1.0, 0.20, 0.20)
		pmat.emission_enabled = true
		pmat.emission = Color(1.0, 0.40, 0.30)
		pmat.emission_energy_multiplier = 1.8
		pmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		pad.material_override = pmat
		pit.add_child(pad)
	# Floating "TRIAL PIT" label
	var label: Label3D = Label3D.new()
	label.text = "TRIAL PIT"
	label.position = Vector3(0, 2.2, 0)
	label.modulate = Color(1.0, 0.55, 0.20)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 6
	label.font_size = 22
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	pit.add_child(label)


static func _build_d2_mercenary_tent(geom: Node) -> void:
	## Epic-2 T17: a mercenary camp tent with a weapon rack out front.
	## Brown fabric tent (slanted box) on 4 posts with a small rack of
	## 3 weapons (different colored emissive blades).
	var camp: Node3D = Node3D.new()
	camp.name = "D2MercenaryCamp"
	camp.position = D2_CENTER + Vector3(8, 0, -10)
	geom.add_child(camp)
	# 4 corner posts
	var post_mat: StandardMaterial3D = StandardMaterial3D.new()
	post_mat.albedo_color = Color(0.20, 0.16, 0.10)
	post_mat.metallic = 0.30
	for ox: float in [-1.4, 1.4]:
		for oz: float in [-1.0, 1.0]:
			var post: MeshInstance3D = MeshInstance3D.new()
			var pmesh: CylinderMesh = CylinderMesh.new()
			pmesh.top_radius = 0.06
			pmesh.bottom_radius = 0.08
			pmesh.height = 2.4
			post.mesh = pmesh
			post.position = Vector3(ox, 1.20, oz)
			post.material_override = post_mat
			camp.add_child(post)
	# Tent fabric — angled triangular box
	var fabric_mat: StandardMaterial3D = StandardMaterial3D.new()
	fabric_mat.albedo_color = Color(0.30, 0.20, 0.10)
	fabric_mat.emission_enabled = true
	fabric_mat.emission = Color(0.85, 0.55, 0.20)
	fabric_mat.emission_energy_multiplier = 0.30
	fabric_mat.metallic = 0.10
	fabric_mat.roughness = 0.65
	var roof: MeshInstance3D = MeshInstance3D.new()
	var rmesh: PrismMesh = PrismMesh.new()
	rmesh.size = Vector3(3.2, 1.0, 2.4)
	roof.mesh = rmesh
	roof.position = Vector3(0, 2.85, 0)
	roof.material_override = fabric_mat
	camp.add_child(roof)
	# Side fabric panels (back wall)
	var back: MeshInstance3D = MeshInstance3D.new()
	var bmesh: BoxMesh = BoxMesh.new()
	bmesh.size = Vector3(3.0, 2.4, 0.06)
	back.mesh = bmesh
	back.position = Vector3(0, 1.20, -1.0)
	back.material_override = fabric_mat
	camp.add_child(back)
	# Weapon rack — horizontal bar mounted in front
	var rack_root: Node3D = Node3D.new()
	rack_root.position = Vector3(0, 1.20, 1.20)
	camp.add_child(rack_root)
	var rack_bar: MeshInstance3D = MeshInstance3D.new()
	var rb_mesh: CylinderMesh = CylinderMesh.new()
	rb_mesh.top_radius = 0.05
	rb_mesh.bottom_radius = 0.05
	rb_mesh.height = 2.6
	rack_bar.mesh = rb_mesh
	rack_bar.rotation = Vector3(0, 0, deg_to_rad(90))
	rack_bar.material_override = post_mat
	rack_root.add_child(rack_bar)
	# 3 hanging weapons (vertical thin bars + colored blade tips)
	var weapon_specs: Array = [
		[-0.85, Color(0.55, 0.95, 1.0)],
		[0.0, Color(1.0, 0.40, 0.20)],
		[0.85, Color(0.85, 0.40, 1.0)],
	]
	for spec in weapon_specs:
		var hilt: MeshInstance3D = MeshInstance3D.new()
		var hmesh: CylinderMesh = CylinderMesh.new()
		hmesh.top_radius = 0.04
		hmesh.bottom_radius = 0.04
		hmesh.height = 0.45
		hilt.mesh = hmesh
		hilt.position = Vector3(spec[0], -0.30, 0)
		hilt.material_override = post_mat
		rack_root.add_child(hilt)
		# Blade
		var blade: MeshInstance3D = MeshInstance3D.new()
		var bldmesh: BoxMesh = BoxMesh.new()
		bldmesh.size = Vector3(0.05, 0.85, 0.04)
		blade.mesh = bldmesh
		blade.position = Vector3(spec[0], -0.95, 0)
		var blade_mat: StandardMaterial3D = StandardMaterial3D.new()
		var c: Color = spec[1]
		blade_mat.albedo_color = c
		blade_mat.emission_enabled = true
		blade_mat.emission = c
		blade_mat.emission_energy_multiplier = 1.8
		blade_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		blade.material_override = blade_mat
		rack_root.add_child(blade)
	# Tent label
	var label: Label3D = Label3D.new()
	label.text = "MERC CAMP"
	label.position = Vector3(0, 3.5, 0)
	label.modulate = Color(1.0, 0.65, 0.30)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 18
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	camp.add_child(label)
	# Collision around the tent
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(3.2, 2.4, 2.4)
	cs.shape = cb
	cs.position = Vector3(0, 1.20, 0)
	sb.add_child(cs)
	camp.add_child(sb)


static func _build_d2_caution_stripes(geom: Node) -> void:
	## Epic-2 T18: 8 yellow caution stripes painted on the D2 ground in
	## front of the trial pit, marking the danger zone. Each is a thin
	## emissive box at a 45-degree angle.
	var center := D2_CENTER + Vector3(15, 0.06, 5)
	var stripe_mat: StandardMaterial3D = StandardMaterial3D.new()
	stripe_mat.albedo_color = Color(1.0, 0.85, 0.20)
	stripe_mat.emission_enabled = true
	stripe_mat.emission = Color(1.0, 0.95, 0.30)
	stripe_mat.emission_energy_multiplier = 1.6
	stripe_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for i in 8:
		var stripe: MeshInstance3D = MeshInstance3D.new()
		stripe.name = "D2CautionStripe_%d" % i
		var smesh: BoxMesh = BoxMesh.new()
		smesh.size = Vector3(0.85, 0.05, 0.20)
		stripe.mesh = smesh
		stripe.position = center + Vector3(-2.8 + i * 0.80, 0, 0)
		stripe.rotation = Vector3(0, deg_to_rad(45), 0)
		stripe.material_override = stripe_mat
		geom.add_child(stripe)


static func _build_d2_black_market_npc(town: Node) -> void:
	## Epic-2 T19: Black market merchant NPC standing inside the merc tent.
	## Hooded figure with a glowing red eye and a gold coin pouch belt.
	var slots: Node3D = town.get_node_or_null("%NPCSlots") as Node3D
	if slots == null:
		return
	var bm: Node3D = Node3D.new()
	bm.name = "D2BlackMarketMerchant"
	bm.position = D2_CENTER + Vector3(8, 0, -10.5)
	slots.add_child(bm)
	# Body capsule — dark cloak
	var body: MeshInstance3D = MeshInstance3D.new()
	var bmesh: CapsuleMesh = CapsuleMesh.new()
	bmesh.radius = 0.42
	bmesh.height = 1.20
	body.mesh = bmesh
	body.position = Vector3(0, 0.65, 0)
	var bmat: StandardMaterial3D = StandardMaterial3D.new()
	bmat.albedo_color = Color(0.10, 0.10, 0.14)
	bmat.metallic = 0.30
	bmat.roughness = 0.65
	body.material_override = bmat
	bm.add_child(body)
	# Hood (wider sphere)
	var hood: MeshInstance3D = MeshInstance3D.new()
	var hmesh: SphereMesh = SphereMesh.new()
	hmesh.radius = 0.45
	hmesh.height = 0.55
	hood.mesh = hmesh
	hood.position = Vector3(0, 1.45, 0)
	var hmat: StandardMaterial3D = StandardMaterial3D.new()
	hmat.albedo_color = Color(0.06, 0.06, 0.10)
	hmat.metallic = 0.30
	hmat.roughness = 0.65
	hood.material_override = hmat
	bm.add_child(hood)
	# Single red glowing eye (cyclops style)
	var eye: MeshInstance3D = MeshInstance3D.new()
	var emesh: SphereMesh = SphereMesh.new()
	emesh.radius = 0.10
	emesh.height = 0.20
	eye.mesh = emesh
	eye.position = Vector3(0, 1.32, 0.34)
	var emat: StandardMaterial3D = StandardMaterial3D.new()
	emat.albedo_color = Color(1.0, 0.20, 0.20)
	emat.emission_enabled = true
	emat.emission = Color(1.0, 0.30, 0.30)
	emat.emission_energy_multiplier = 3.0
	emat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	eye.material_override = emat
	bm.add_child(eye)
	# Gold coin pouch belt
	var pouch_mat: StandardMaterial3D = StandardMaterial3D.new()
	pouch_mat.albedo_color = Color(0.85, 0.65, 0.20)
	pouch_mat.emission_enabled = true
	pouch_mat.emission = Color(1.0, 0.75, 0.25)
	pouch_mat.emission_energy_multiplier = 1.0
	pouch_mat.metallic = 0.85
	for i in 3:
		var coin: MeshInstance3D = MeshInstance3D.new()
		var cmesh: SphereMesh = SphereMesh.new()
		cmesh.radius = 0.08
		cmesh.height = 0.16
		coin.mesh = cmesh
		coin.position = Vector3(-0.20 + i * 0.20, 0.55, 0.30)
		coin.material_override = pouch_mat
		bm.add_child(coin)
	# Pulse the eye
	var pulse: Tween = create_tween().set_loops()
	pulse.tween_property(emat, "emission_energy_multiplier", 4.0, 1.0).set_ease(Tween.EASE_IN_OUT)
	pulse.tween_property(emat, "emission_energy_multiplier", 2.0, 1.0).set_ease(Tween.EASE_IN_OUT)
	# Name billboard
	var label: Label3D = Label3D.new()
	label.text = "Black Market"
	label.position = Vector3(0, 1.95, 0)
	label.modulate = Color(1.0, 0.30, 0.30)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 18
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	bm.add_child(label)


static func _build_d2_watchtower(geom: Node) -> void:
	## Epic-2 T20: a tall watchtower with a hovering top platform and a
	## sweeping searchlight (real SpotLight3D rotating on a tween). Sells
	## "this place is being watched" without spawning hostile guards.
	var tower: Node3D = Node3D.new()
	tower.name = "D2Watchtower"
	tower.position = D2_CENTER + Vector3(20, 0, -16)
	geom.add_child(tower)
	# Tall narrow column
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.16, 0.14, 0.12)
	stone_mat.metallic = 0.45
	stone_mat.roughness = 0.55
	var column: MeshInstance3D = MeshInstance3D.new()
	var cmesh: CylinderMesh = CylinderMesh.new()
	cmesh.top_radius = 0.30
	cmesh.bottom_radius = 0.40
	cmesh.height = 8.0
	column.mesh = cmesh
	column.position = Vector3(0, 4.0, 0)
	column.material_override = stone_mat
	tower.add_child(column)
	# Top platform — wider disc
	var platform: MeshInstance3D = MeshInstance3D.new()
	var pmesh: CylinderMesh = CylinderMesh.new()
	pmesh.top_radius = 1.20
	pmesh.bottom_radius = 1.0
	pmesh.height = 0.40
	platform.mesh = pmesh
	platform.position = Vector3(0, 8.20, 0)
	platform.material_override = stone_mat
	tower.add_child(platform)
	# Cabin on top — small box
	var cabin: MeshInstance3D = MeshInstance3D.new()
	var cab_mesh: BoxMesh = BoxMesh.new()
	cab_mesh.size = Vector3(1.40, 1.0, 1.40)
	cabin.mesh = cab_mesh
	cabin.position = Vector3(0, 8.95, 0)
	cabin.material_override = stone_mat
	tower.add_child(cabin)
	# Cyan window slits on the cabin
	var window_mat: StandardMaterial3D = StandardMaterial3D.new()
	window_mat.albedo_color = Color(0.30, 0.85, 1.0)
	window_mat.emission_enabled = true
	window_mat.emission = Color(0.55, 0.95, 1.0)
	window_mat.emission_energy_multiplier = 1.6
	window_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for sx: float in [-0.71, 0.71]:
		var win: MeshInstance3D = MeshInstance3D.new()
		var wmesh: BoxMesh = BoxMesh.new()
		wmesh.size = Vector3(0.04, 0.30, 0.85)
		win.mesh = wmesh
		win.position = Vector3(sx, 8.95, 0)
		win.material_override = window_mat
		tower.add_child(win)
	# Sweeping searchlight pivot mounted on top of cabin
	var spot_pivot: Node3D = Node3D.new()
	spot_pivot.position = Vector3(0, 9.65, 0)
	tower.add_child(spot_pivot)
	# Searchlight body
	var spot_body: MeshInstance3D = MeshInstance3D.new()
	var sb_mesh: CylinderMesh = CylinderMesh.new()
	sb_mesh.top_radius = 0.20
	sb_mesh.bottom_radius = 0.30
	sb_mesh.height = 0.45
	spot_body.mesh = sb_mesh
	spot_body.position = Vector3(0, 0, 0.30)
	spot_body.rotation = Vector3(deg_to_rad(70), 0, 0)
	spot_body.material_override = stone_mat
	spot_pivot.add_child(spot_body)
	# Real spotlight + visible cone beam pointed downward+forward
	var spot: SpotLight3D = SpotLight3D.new()
	spot.position = Vector3(0, -0.10, 0.40)
	spot.rotation = Vector3(deg_to_rad(-70), 0, 0)
	spot.light_color = Color(1.0, 0.95, 0.65)
	spot.light_energy = 4.0
	spot.spot_range = 18.0
	spot.spot_angle = 26.0
	spot.spot_attenuation = 1.4
	spot_pivot.add_child(spot)
	# Visible cone
	var beam: MeshInstance3D = MeshInstance3D.new()
	var beam_mesh: CylinderMesh = CylinderMesh.new()
	beam_mesh.top_radius = 0.20
	beam_mesh.bottom_radius = 3.40
	beam_mesh.height = 9.0
	beam.mesh = beam_mesh
	beam.position = Vector3(0, -4.0, 1.6)
	beam.rotation = Vector3(deg_to_rad(20), 0, 0)
	var bm_mat: StandardMaterial3D = StandardMaterial3D.new()
	bm_mat.albedo_color = Color(1.0, 0.95, 0.65, 0.10)
	bm_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	bm_mat.emission_enabled = true
	bm_mat.emission = Color(1.0, 0.95, 0.65)
	bm_mat.emission_energy_multiplier = 0.45
	bm_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	beam.material_override = bm_mat
	spot_pivot.add_child(beam)
	# Sweeping rotation tween
	var sweep: Tween = create_tween().set_loops()
	sweep.tween_property(spot_pivot, "rotation:y", deg_to_rad(60), 4.0).set_ease(Tween.EASE_IN_OUT)
	sweep.tween_property(spot_pivot, "rotation:y", deg_to_rad(-60), 4.0).set_ease(Tween.EASE_IN_OUT)
	# Collision around column
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cap: CapsuleShape3D = CapsuleShape3D.new()
	cap.radius = 0.45
	cap.height = 8.0
	cs.shape = cap
	cs.position = Vector3(0, 4.0, 0)
	sb.add_child(cs)
	tower.add_child(sb)


static func _build_d2_data_conduits(geom: Node) -> void:
	## Epic-2 T21: 3 large suspended data conduit pipes running east-west
	## across the district at varying heights. Each is a long thick cylinder
	## with cyan emissive bands at intervals + a slow energy pulse traveling
	## along its length (mocked by moving a bright sphere along the pipe).
	var pipe_specs: Array = [
		[Vector3(70, 4.5, -16), Vector3(115, 4.5, -16), Color(0.55, 0.95, 1.0)],
		[Vector3(70, 5.5, 0), Vector3(115, 5.5, 0), Color(1.0, 0.55, 0.20)],
		[Vector3(70, 4.5, 16), Vector3(115, 4.5, 16), Color(0.85, 0.40, 1.0)],
	]
	var pipe_metal_mat: StandardMaterial3D = StandardMaterial3D.new()
	pipe_metal_mat.albedo_color = Color(0.20, 0.22, 0.28)
	pipe_metal_mat.metallic = 0.85
	pipe_metal_mat.roughness = 0.30
	for i in pipe_specs.size():
		var spec: Array = pipe_specs[i]
		var from: Vector3 = spec[0]
		var to: Vector3 = spec[1]
		var color: Color = spec[2]
		var dist: float = from.distance_to(to)
		var mid: Vector3 = (from + to) * 0.5
		var pipe: MeshInstance3D = MeshInstance3D.new()
		pipe.name = "D2DataConduit_%d" % i
		var pmesh: CylinderMesh = CylinderMesh.new()
		pmesh.top_radius = 0.30
		pmesh.bottom_radius = 0.30
		pmesh.height = dist
		pipe.mesh = pmesh
		pipe.position = mid
		pipe.rotation = Vector3(0, 0, deg_to_rad(90))
		pipe.material_override = pipe_metal_mat
		geom.add_child(pipe)
		# Emissive band rings every 5m along the pipe
		var num_bands: int = int(dist / 5.0)
		for b in num_bands:
			var t: float = float(b + 1) / float(num_bands + 1)
			var band_pos: Vector3 = from.lerp(to, t)
			var band: MeshInstance3D = MeshInstance3D.new()
			var bmesh: TorusMesh = TorusMesh.new()
			bmesh.inner_radius = 0.32
			bmesh.outer_radius = 0.40
			band.mesh = bmesh
			band.position = band_pos
			band.rotation = Vector3(0, 0, deg_to_rad(90))
			var bmat: StandardMaterial3D = StandardMaterial3D.new()
			bmat.albedo_color = color
			bmat.emission_enabled = true
			bmat.emission = color
			bmat.emission_energy_multiplier = 1.6
			bmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
			band.material_override = bmat
			geom.add_child(band)
		# Pulse sphere traveling along the pipe
		var pulse_ball: MeshInstance3D = MeshInstance3D.new()
		var pmesh_b: SphereMesh = SphereMesh.new()
		pmesh_b.radius = 0.22
		pmesh_b.height = 0.44
		pulse_ball.mesh = pmesh_b
		pulse_ball.position = from
		var pball_mat: StandardMaterial3D = StandardMaterial3D.new()
		pball_mat.albedo_color = color
		pball_mat.emission_enabled = true
		pball_mat.emission = color
		pball_mat.emission_energy_multiplier = 3.0
		pball_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		pulse_ball.material_override = pball_mat
		geom.add_child(pulse_ball)
		var travel: Tween = create_tween().set_loops()
		travel.tween_property(pulse_ball, "position", to, 4.0 + i * 0.5).set_ease(Tween.EASE_IN_OUT)
		travel.tween_property(pulse_ball, "position", from, 0.05)


static func _build_d2_server_farm(geom: Node) -> void:
	## Epic-2 T22: a tall multi-rack server farm tower in D2. 3 stacked
	## rack units with rows of small green/red LED lights, vent fins on
	## the sides, and a roof antenna. Hints "this district hosts compute".
	var farm: Node3D = Node3D.new()
	farm.name = "D2ServerFarm"
	farm.position = D2_CENTER + Vector3(-15, 0, 14)
	geom.add_child(farm)
	# Base
	var dark_mat: StandardMaterial3D = StandardMaterial3D.new()
	dark_mat.albedo_color = Color(0.10, 0.13, 0.16)
	dark_mat.metallic = 0.85
	dark_mat.roughness = 0.30
	var base: MeshInstance3D = MeshInstance3D.new()
	var base_mesh: BoxMesh = BoxMesh.new()
	base_mesh.size = Vector3(2.4, 0.30, 2.0)
	base.mesh = base_mesh
	base.position = Vector3(0, 0.15, 0)
	base.material_override = dark_mat
	farm.add_child(base)
	# 3 stacked rack units
	for r in 3:
		var rack: MeshInstance3D = MeshInstance3D.new()
		var rmesh: BoxMesh = BoxMesh.new()
		rmesh.size = Vector3(2.0, 1.6, 1.6)
		rack.mesh = rmesh
		rack.position = Vector3(0, 1.15 + r * 1.85, 0)
		rack.material_override = dark_mat
		farm.add_child(rack)
		# Rows of LEDs across the front face
		for row in 4:
			for col in 5:
				var led: MeshInstance3D = MeshInstance3D.new()
				var lmesh: SphereMesh = SphereMesh.new()
				lmesh.radius = 0.05
				lmesh.height = 0.10
				led.mesh = lmesh
				led.position = Vector3(-0.85 + col * 0.40, 1.50 + r * 1.85 + row * 0.30, 0.81)
				var lmat: StandardMaterial3D = StandardMaterial3D.new()
				var c: Color = Color(0.30, 1.0, 0.40) if (row + col) % 2 == 0 else Color(1.0, 0.40, 0.30)
				lmat.albedo_color = c
				lmat.emission_enabled = true
				lmat.emission = c
				lmat.emission_energy_multiplier = 2.0
				lmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
				led.material_override = lmat
				farm.add_child(led)
				# Random blink (some lights flicker)
				if (row * 5 + col) % 3 == 0:
					var blink: Tween = create_tween().set_loops()
					blink.tween_interval(0.5 + randf() * 1.0)
					blink.tween_property(led, "visible", false, 0.0)
					blink.tween_interval(0.10)
					blink.tween_property(led, "visible", true, 0.0)
		# Vent fins on each side of the rack
		for sx: float in [-1.05, 1.05]:
			for fy in 4:
				var fin: MeshInstance3D = MeshInstance3D.new()
				var fmesh: BoxMesh = BoxMesh.new()
				fmesh.size = Vector3(0.05, 0.06, 1.5)
				fin.mesh = fmesh
				fin.position = Vector3(sx, 1.20 + r * 1.85 + fy * 0.36, 0)
				fin.material_override = dark_mat
				farm.add_child(fin)
	# Roof antenna
	var antenna: MeshInstance3D = MeshInstance3D.new()
	var amesh: CylinderMesh = CylinderMesh.new()
	amesh.top_radius = 0.04
	amesh.bottom_radius = 0.10
	amesh.height = 1.6
	antenna.mesh = amesh
	antenna.position = Vector3(0, 7.50, 0)
	antenna.material_override = dark_mat
	farm.add_child(antenna)
	# Antenna blink tip
	var tip: MeshInstance3D = MeshInstance3D.new()
	var tip_mesh: SphereMesh = SphereMesh.new()
	tip_mesh.radius = 0.10
	tip_mesh.height = 0.20
	tip.mesh = tip_mesh
	tip.position = Vector3(0, 8.30, 0)
	var tmat: StandardMaterial3D = StandardMaterial3D.new()
	tmat.albedo_color = Color(1.0, 0.30, 0.30)
	tmat.emission_enabled = true
	tmat.emission = Color(1.0, 0.40, 0.40)
	tmat.emission_energy_multiplier = 2.5
	tmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	tip.material_override = tmat
	farm.add_child(tip)
	var blink: Tween = create_tween().set_loops()
	blink.tween_property(tip, "scale", Vector3(0.4, 0.4, 0.4), 0.6).set_ease(Tween.EASE_IN_OUT)
	blink.tween_property(tip, "scale", Vector3(1.4, 1.4, 1.4), 0.6).set_ease(Tween.EASE_IN_OUT)
	# Label
	var label: Label3D = Label3D.new()
	label.text = "SERVER FARM"
	label.position = Vector3(0, 9.0, 0)
	label.modulate = Color(0.40, 1.0, 0.50)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 18
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	farm.add_child(label)
	# Collision around the whole stack
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(2.4, 7.0, 2.0)
	cs.shape = cb
	cs.position = Vector3(0, 3.50, 0)
	sb.add_child(cs)
	farm.add_child(sb)


static func _build_d2_cracked_billboard(geom: Node) -> void:
	## Epic-2 T23: a tall cracked highway billboard mounted on 2 thick
	## posts. Old advert face is faded with diagonal cracks. Reads "RUN
	## FASTER / BETA TEST 0.99" with vertical text glitching.
	var bb: Node3D = Node3D.new()
	bb.name = "D2CrackedBillboard"
	bb.position = D2_CENTER + Vector3(-12, 0, -6)
	bb.rotation = Vector3(0, deg_to_rad(20), 0)
	geom.add_child(bb)
	# 2 support posts
	var post_mat: StandardMaterial3D = StandardMaterial3D.new()
	post_mat.albedo_color = Color(0.10, 0.13, 0.16)
	post_mat.metallic = 0.85
	post_mat.roughness = 0.30
	for sx: float in [-1.6, 1.6]:
		var post: MeshInstance3D = MeshInstance3D.new()
		var pmesh: CylinderMesh = CylinderMesh.new()
		pmesh.top_radius = 0.10
		pmesh.bottom_radius = 0.14
		pmesh.height = 4.5
		post.mesh = pmesh
		post.position = Vector3(sx, 2.25, 0)
		post.material_override = post_mat
		bb.add_child(post)
		# Collision
		var sb: StaticBody3D = StaticBody3D.new()
		var cs: CollisionShape3D = CollisionShape3D.new()
		var cap: CapsuleShape3D = CapsuleShape3D.new()
		cap.radius = 0.20
		cap.height = 4.5
		cs.shape = cap
		cs.position = Vector3(sx, 2.25, 0)
		sb.add_child(cs)
		bb.add_child(sb)
	# Billboard backing — wide rectangle
	var back_mat: StandardMaterial3D = StandardMaterial3D.new()
	back_mat.albedo_color = Color(0.95, 0.85, 0.55)
	back_mat.emission_enabled = true
	back_mat.emission = Color(1.0, 0.85, 0.55)
	back_mat.emission_energy_multiplier = 0.40
	back_mat.metallic = 0.10
	back_mat.roughness = 0.65
	var board: MeshInstance3D = MeshInstance3D.new()
	var bmesh: BoxMesh = BoxMesh.new()
	bmesh.size = Vector3(4.5, 2.4, 0.10)
	board.mesh = bmesh
	board.position = Vector3(0, 4.50, 0)
	board.material_override = back_mat
	bb.add_child(board)
	# Diagonal crack lines on the board
	var crack_mat: StandardMaterial3D = StandardMaterial3D.new()
	crack_mat.albedo_color = Color(0.10, 0.10, 0.10)
	crack_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for c in 3:
		var crack: MeshInstance3D = MeshInstance3D.new()
		var cmesh: BoxMesh = BoxMesh.new()
		cmesh.size = Vector3(3.5, 0.05, 0.02)
		crack.mesh = cmesh
		crack.position = Vector3(0, 4.50 + c * 0.30 - 0.40, 0.06)
		crack.rotation = Vector3(0, 0, deg_to_rad(-22 + c * 20))
		crack.material_override = crack_mat
		bb.add_child(crack)
	# Big text on the board
	var label1: Label3D = Label3D.new()
	label1.text = "RUN FASTER"
	label1.position = Vector3(0, 5.05, 0.07)
	label1.modulate = Color(0.95, 0.30, 0.20)
	label1.outline_modulate = Color(0, 0, 0, 0.85)
	label1.outline_size = 6
	label1.font_size = 32
	label1.no_depth_test = true
	bb.add_child(label1)
	var label2: Label3D = Label3D.new()
	label2.text = "BETA TEST 0.99"
	label2.position = Vector3(0, 4.10, 0.07)
	label2.modulate = Color(0.20, 0.20, 0.30)
	label2.outline_modulate = Color(0, 0, 0, 0.85)
	label2.outline_size = 4
	label2.font_size = 18
	label2.no_depth_test = true
	bb.add_child(label2)
	# Glitch flicker on the title
	var flicker: Tween = create_tween().set_loops()
	flicker.tween_interval(2.0)
	flicker.tween_property(label1, "visible", false, 0.0)
	flicker.tween_interval(0.10)
	flicker.tween_property(label1, "visible", true, 0.0)
	flicker.tween_interval(0.05)
	flicker.tween_property(label1, "visible", false, 0.0)
	flicker.tween_interval(0.08)
	flicker.tween_property(label1, "visible", true, 0.0)


static func _build_d2_shipping_containers(geom: Node) -> void:
	## Epic-2 T24: 5 stacked shipping containers cluttering an area. Each
	## is a long box at varying colors with stenciled IDs and rusty trim.
	var stack: Node3D = Node3D.new()
	stack.name = "D2ShippingContainers"
	stack.position = D2_CENTER + Vector3(22, 0, 14)
	geom.add_child(stack)
	var container_specs: Array = [
		[Vector3(0, 0.70, 0), Vector3(0, 0, 0), Color(0.20, 0.40, 0.55)],
		[Vector3(0, 2.10, 0), Vector3(0, deg_to_rad(15), 0), Color(0.55, 0.30, 0.20)],
		[Vector3(2.5, 0.70, 0.5), Vector3(0, deg_to_rad(-25), 0), Color(0.30, 0.45, 0.25)],
		[Vector3(-2.0, 0.70, 0.8), Vector3(0, deg_to_rad(8), 0), Color(0.55, 0.45, 0.20)],
		[Vector3(2.5, 2.10, 0.5), Vector3(0, deg_to_rad(-15), deg_to_rad(8)), Color(0.40, 0.35, 0.40)],
	]
	for i in container_specs.size():
		var spec: Array = container_specs[i]
		var color: Color = spec[2]
		var container: MeshInstance3D = MeshInstance3D.new()
		container.name = "Container_%d" % i
		var cmesh: BoxMesh = BoxMesh.new()
		cmesh.size = Vector3(2.6, 1.40, 1.20)
		container.mesh = cmesh
		container.position = spec[0]
		container.rotation = spec[1]
		var cmat: StandardMaterial3D = StandardMaterial3D.new()
		cmat.albedo_color = color
		cmat.metallic = 0.55
		cmat.roughness = 0.65
		container.material_override = cmat
		stack.add_child(container)
		# Stencil ID label on side
		var id_label: Label3D = Label3D.new()
		id_label.text = "C-%03d" % (i * 47 + 12)
		id_label.position = spec[0] + Vector3(0, 0.20, 0.66)
		id_label.rotation = spec[1]
		id_label.modulate = Color(0.95, 0.95, 0.95, 0.85)
		id_label.outline_modulate = Color(0, 0, 0, 0.55)
		id_label.outline_size = 3
		id_label.font_size = 18
		id_label.no_depth_test = true
		stack.add_child(id_label)
		# Collision per container
		var sb: StaticBody3D = StaticBody3D.new()
		var cs: CollisionShape3D = CollisionShape3D.new()
		var cb: BoxShape3D = BoxShape3D.new()
		cb.size = Vector3(2.6, 1.40, 1.20)
		cs.shape = cb
		cs.position = spec[0]
		sb.add_child(cs)
		stack.add_child(sb)


static func _build_d2_glitch_beast(geom: Node) -> void:
	## Epic-2 T25: a large wandering "glitch beast" — bigger than the
	## glitch enemies, the visual mini-boss of D2. 4-legged hulking body
	## with 6 magenta eyes and a glowing back spike row. Slow patrol.
	var beast: Node3D = Node3D.new()
	beast.name = "D2GlitchBeast"
	beast.position = D2_CENTER + Vector3(15, 0, 14)
	geom.add_child(beast)
	# Body — chunky box
	var body_mat: StandardMaterial3D = StandardMaterial3D.new()
	body_mat.albedo_color = Color(0.30, 0.10, 0.18)
	body_mat.emission_enabled = true
	body_mat.emission = Color(1.0, 0.20, 0.40)
	body_mat.emission_energy_multiplier = 0.55
	body_mat.metallic = 0.40
	body_mat.roughness = 0.55
	var body: MeshInstance3D = MeshInstance3D.new()
	var bmesh: BoxMesh = BoxMesh.new()
	bmesh.size = Vector3(2.0, 1.20, 1.40)
	body.mesh = bmesh
	body.position = Vector3(0, 1.30, 0)
	body.material_override = body_mat
	beast.add_child(body)
	# Head — smaller box jutting forward
	var head: MeshInstance3D = MeshInstance3D.new()
	var hmesh: BoxMesh = BoxMesh.new()
	hmesh.size = Vector3(1.0, 0.85, 1.0)
	head.mesh = hmesh
	head.position = Vector3(1.30, 1.20, 0)
	head.material_override = body_mat
	beast.add_child(head)
	# 6 magenta eyes (3x2 grid on the head front)
	var eye_mat: StandardMaterial3D = StandardMaterial3D.new()
	eye_mat.albedo_color = Color(1.0, 0.30, 0.55)
	eye_mat.emission_enabled = true
	eye_mat.emission = Color(1.0, 0.40, 0.65)
	eye_mat.emission_energy_multiplier = 2.6
	eye_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for col in 3:
		for row in 2:
			var eye: MeshInstance3D = MeshInstance3D.new()
			var emesh: SphereMesh = SphereMesh.new()
			emesh.radius = 0.10
			emesh.height = 0.20
			eye.mesh = emesh
			eye.position = Vector3(1.85, 1.05 + row * 0.30, -0.30 + col * 0.30)
			eye.material_override = eye_mat
			beast.add_child(eye)
	# Glowing back spike row — 5 prisms along the body top
	var spike_mat: StandardMaterial3D = StandardMaterial3D.new()
	spike_mat.albedo_color = Color(1.0, 0.20, 0.40)
	spike_mat.emission_enabled = true
	spike_mat.emission = Color(1.0, 0.30, 0.55)
	spike_mat.emission_energy_multiplier = 2.2
	spike_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for s in 5:
		var spike: MeshInstance3D = MeshInstance3D.new()
		var smesh: PrismMesh = PrismMesh.new()
		smesh.size = Vector3(0.20, 0.65, 0.20)
		spike.mesh = smesh
		spike.position = Vector3(0.80 - s * 0.40, 2.20, 0)
		spike.material_override = spike_mat
		beast.add_child(spike)
	# 4 chunky legs
	var leg_mat: StandardMaterial3D = StandardMaterial3D.new()
	leg_mat.albedo_color = Color(0.16, 0.06, 0.10)
	leg_mat.metallic = 0.30
	leg_mat.roughness = 0.55
	var leg_offsets: Array[Vector3] = [
		Vector3(-0.85, 0.40, -0.55),
		Vector3(0.85, 0.40, -0.55),
		Vector3(-0.85, 0.40, 0.55),
		Vector3(0.85, 0.40, 0.55),
	]
	for off in leg_offsets:
		var leg: MeshInstance3D = MeshInstance3D.new()
		var lmesh: BoxMesh = BoxMesh.new()
		lmesh.size = Vector3(0.30, 0.85, 0.30)
		leg.mesh = lmesh
		leg.position = off
		leg.material_override = leg_mat
		beast.add_child(leg)
	# Slow patrol path
	var origin: Vector3 = D2_CENTER + Vector3(15, 0, 14)
	var patrol: Tween = create_tween().set_loops()
	patrol.tween_property(beast, "rotation:y", 0.0, 0.4)
	patrol.tween_property(beast, "position", origin + Vector3(8, 0, 0), 8.0)
	patrol.tween_property(beast, "rotation:y", deg_to_rad(180), 0.6)
	patrol.tween_property(beast, "position", origin, 8.0)
	# Pulse the back spikes
	var spike_pulse: Tween = create_tween().set_loops()
	spike_pulse.tween_property(spike_mat, "emission_energy_multiplier", 3.4, 0.85).set_ease(Tween.EASE_IN_OUT)
	spike_pulse.tween_property(spike_mat, "emission_energy_multiplier", 1.4, 0.85).set_ease(Tween.EASE_IN_OUT)
	# Boss-like name billboard
	var label: Label3D = Label3D.new()
	label.text = "GLITCH BEAST"
	label.position = Vector3(0, 3.20, 0)
	label.modulate = Color(1.0, 0.30, 0.55)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 6
	label.font_size = 22
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	beast.add_child(label)


static func _build_d2_repair_workshop(geom: Node) -> void:
	## Epic-2 T26: open-air repair workshop — anvil + workbench + active
	## welding spark emitter. Sells "stuff gets fixed here, not bought".
	var shop: Node3D = Node3D.new()
	shop.name = "D2RepairWorkshop"
	shop.position = D2_CENTER + Vector3(-18, 0, 4)
	geom.add_child(shop)
	# Workbench
	var bench_mat: StandardMaterial3D = StandardMaterial3D.new()
	bench_mat.albedo_color = Color(0.20, 0.16, 0.10)
	bench_mat.metallic = 0.30
	bench_mat.roughness = 0.65
	var bench: MeshInstance3D = MeshInstance3D.new()
	var bm: BoxMesh = BoxMesh.new()
	bm.size = Vector3(2.4, 0.95, 1.0)
	bench.mesh = bm
	bench.position = Vector3(0, 0.47, 0)
	bench.material_override = bench_mat
	shop.add_child(bench)
	# Anvil — small block on top of bench
	var anvil_mat: StandardMaterial3D = StandardMaterial3D.new()
	anvil_mat.albedo_color = Color(0.10, 0.10, 0.13)
	anvil_mat.metallic = 0.85
	anvil_mat.roughness = 0.30
	var anvil: MeshInstance3D = MeshInstance3D.new()
	var am: BoxMesh = BoxMesh.new()
	am.size = Vector3(0.65, 0.30, 0.40)
	anvil.mesh = am
	anvil.position = Vector3(0.5, 1.10, 0)
	anvil.material_override = anvil_mat
	shop.add_child(anvil)
	# Half-finished blade lying on the anvil — heated orange tip
	var blade: MeshInstance3D = MeshInstance3D.new()
	var blade_mesh: BoxMesh = BoxMesh.new()
	blade_mesh.size = Vector3(0.85, 0.04, 0.10)
	blade.mesh = blade_mesh
	blade.position = Vector3(0.5, 1.30, 0)
	var blade_mat: StandardMaterial3D = StandardMaterial3D.new()
	blade_mat.albedo_color = Color(0.85, 0.40, 0.20)
	blade_mat.emission_enabled = true
	blade_mat.emission = Color(1.0, 0.55, 0.20)
	blade_mat.emission_energy_multiplier = 1.6
	blade_mat.metallic = 0.65
	blade_mat.roughness = 0.30
	blade.material_override = blade_mat
	shop.add_child(blade)
	# Active welding spark emitter at the bench
	var sparks: GPUParticles3D = GPUParticles3D.new()
	sparks.amount = 40
	sparks.lifetime = 0.65
	sparks.position = Vector3(0.5, 1.32, 0)
	var pmat: ParticleProcessMaterial = ParticleProcessMaterial.new()
	pmat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	pmat.emission_sphere_radius = 0.10
	pmat.direction = Vector3(0, 1, 0)
	pmat.spread = 60.0
	pmat.initial_velocity_min = 1.4
	pmat.initial_velocity_max = 2.4
	pmat.gravity = Vector3(0, -3.0, 0)
	pmat.scale_min = 0.04
	pmat.scale_max = 0.08
	pmat.color = Color(1.0, 0.85, 0.30, 1.0)
	sparks.process_material = pmat
	var sm: SphereMesh = SphereMesh.new()
	sm.radius = 0.04
	sm.height = 0.08
	var sm_mat: StandardMaterial3D = StandardMaterial3D.new()
	sm_mat.albedo_color = Color(1.0, 0.85, 0.30)
	sm_mat.emission_enabled = true
	sm_mat.emission = Color(1.0, 0.95, 0.40)
	sm_mat.emission_energy_multiplier = 2.6
	sm_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	sm.material = sm_mat
	sparks.draw_pass_1 = sm
	shop.add_child(sparks)
	# Tool wall behind the bench — 4 hanging tools
	var wall: MeshInstance3D = MeshInstance3D.new()
	var wmesh: BoxMesh = BoxMesh.new()
	wmesh.size = Vector3(2.6, 1.85, 0.08)
	wall.mesh = wmesh
	wall.position = Vector3(0, 1.85, -0.55)
	wall.material_override = anvil_mat
	shop.add_child(wall)
	for i in 4:
		var tool: MeshInstance3D = MeshInstance3D.new()
		var tm: BoxMesh = BoxMesh.new()
		tm.size = Vector3(0.10, 0.55, 0.05)
		tool.mesh = tm
		tool.position = Vector3(-0.95 + i * 0.65, 1.85, -0.50)
		var tmat: StandardMaterial3D = StandardMaterial3D.new()
		tmat.albedo_color = Color(0.30, 0.30, 0.35)
		tmat.metallic = 0.85
		tool.material_override = tmat
		shop.add_child(tool)
	# Sign
	var label: Label3D = Label3D.new()
	label.text = "REPAIRS"
	label.position = Vector3(0, 3.0, 0)
	label.modulate = Color(1.0, 0.65, 0.30)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 18
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	shop.add_child(label)
	# Collision around the bench
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(2.4, 1.4, 1.4)
	cs.shape = cb
	cs.position = Vector3(0, 0.7, 0)
	sb.add_child(cs)
	shop.add_child(sb)


static func _build_d2_holo_graffiti(geom: Node) -> void:
	## Epic-2 T27: 4 holographic graffiti tags floating on D2 walls. Each
	## is a brightly colored emissive label with intentional misalignment
	## like spray paint, mounted on the boundary wall area.
	var tags: Array = [
		[D2_CENTER + Vector3(-18, 1.8, -16), "404", Color(1.0, 0.30, 0.55)],
		[D2_CENTER + Vector3(-12, 2.5, -16), "GLITCH", Color(0.55, 0.95, 1.0)],
		[D2_CENTER + Vector3(8, 2.0, -16), "FREE BIT", Color(1.0, 0.95, 0.30)],
		[D2_CENTER + Vector3(20, 1.8, -16), "RUN", Color(0.40, 1.0, 0.55)],
	]
	for spec in tags:
		var pos: Vector3 = spec[0]
		var text: String = spec[1]
		var color: Color = spec[2]
		var tag: Label3D = Label3D.new()
		tag.text = text
		tag.position = pos
		tag.modulate = color
		tag.outline_modulate = Color(0, 0, 0, 0.85)
		tag.outline_size = 5
		tag.font_size = 32
		tag.no_depth_test = true
		tag.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		geom.add_child(tag)


static func _build_d2_drone_wreckage(geom: Node) -> void:
	## Epic-2 T28: a debris field of 6 broken drone parts scattered on the
	## ground — propellers, fuselage halves, smoking pieces. Tells a story
	## of "couriers tried to fly through here and got knocked down".
	var field: Node3D = Node3D.new()
	field.name = "D2DroneWreckage"
	field.position = D2_CENTER + Vector3(2, 0, 14)
	geom.add_child(field)
	var dark_mat: StandardMaterial3D = StandardMaterial3D.new()
	dark_mat.albedo_color = Color(0.10, 0.13, 0.16)
	dark_mat.metallic = 0.85
	dark_mat.roughness = 0.40
	# 2 broken propeller discs
	for i in 2:
		var prop: MeshInstance3D = MeshInstance3D.new()
		var pmesh: CylinderMesh = CylinderMesh.new()
		pmesh.top_radius = 0.30
		pmesh.bottom_radius = 0.30
		pmesh.height = 0.04
		prop.mesh = pmesh
		prop.position = Vector3(-1.5 + i * 3.0, 0.05, randf_range(-0.5, 0.5))
		prop.rotation = Vector3(deg_to_rad(randf_range(-30, 30)), randf() * TAU, deg_to_rad(randf_range(-30, 30)))
		prop.material_override = dark_mat
		field.add_child(prop)
	# 3 fuselage chunks (small boxes)
	for i in 3:
		var chunk: MeshInstance3D = MeshInstance3D.new()
		var cmesh: BoxMesh = BoxMesh.new()
		cmesh.size = Vector3(0.55, 0.18, 0.65)
		chunk.mesh = cmesh
		chunk.position = Vector3(randf_range(-2, 2), 0.10, randf_range(-2, 2))
		chunk.rotation = Vector3(deg_to_rad(randf_range(-25, 25)), randf() * TAU, deg_to_rad(randf_range(-25, 25)))
		chunk.material_override = dark_mat
		field.add_child(chunk)
	# 1 smoking battery — has a sparking emitter
	var battery: MeshInstance3D = MeshInstance3D.new()
	var bm: BoxMesh = BoxMesh.new()
	bm.size = Vector3(0.30, 0.18, 0.30)
	battery.mesh = bm
	battery.position = Vector3(0, 0.10, 0)
	var bmat: StandardMaterial3D = StandardMaterial3D.new()
	bmat.albedo_color = Color(0.85, 0.30, 0.20)
	bmat.emission_enabled = true
	bmat.emission = Color(1.0, 0.40, 0.20)
	bmat.emission_energy_multiplier = 1.6
	battery.material_override = bmat
	field.add_child(battery)
	# Spark emitter from the battery
	var sparks: GPUParticles3D = GPUParticles3D.new()
	sparks.amount = 18
	sparks.lifetime = 0.85
	sparks.position = Vector3(0, 0.30, 0)
	var pmat: ParticleProcessMaterial = ParticleProcessMaterial.new()
	pmat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	pmat.emission_sphere_radius = 0.08
	pmat.direction = Vector3(0, 1, 0)
	pmat.spread = 50.0
	pmat.initial_velocity_min = 0.85
	pmat.initial_velocity_max = 1.4
	pmat.gravity = Vector3(0, -1.5, 0)
	pmat.scale_min = 0.04
	pmat.scale_max = 0.08
	pmat.color = Color(1.0, 0.85, 0.30, 1.0)
	sparks.process_material = pmat
	var sm: SphereMesh = SphereMesh.new()
	sm.radius = 0.04
	sm.height = 0.08
	var sm_mat: StandardMaterial3D = StandardMaterial3D.new()
	sm_mat.albedo_color = Color(1.0, 0.85, 0.30)
	sm_mat.emission_enabled = true
	sm_mat.emission = Color(1.0, 0.95, 0.40)
	sm_mat.emission_energy_multiplier = 2.6
	sm_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	sm.material = sm_mat
	sparks.draw_pass_1 = sm
	field.add_child(sparks)


static func _build_d2_watchman_npc(town: Node) -> void:
	## Epic-2 T29: a patrolling D2 watchman NPC marching back and forth
	## along the boundary. Wears a heavy armor body, has a glowing red
	## visor strip, and carries a long pulse rifle.
	var slots: Node3D = town.get_node_or_null("%NPCSlots") as Node3D
	if slots == null:
		return
	var watch: Node3D = Node3D.new()
	watch.name = "D2Watchman"
	watch.position = D2_CENTER + Vector3(18, 0, -10)
	slots.add_child(watch)
	# Body — heavy armored capsule
	var armor_mat: StandardMaterial3D = StandardMaterial3D.new()
	armor_mat.albedo_color = Color(0.20, 0.16, 0.14)
	armor_mat.metallic = 0.65
	armor_mat.roughness = 0.40
	armor_mat.emission_enabled = true
	armor_mat.emission = Color(0.85, 0.30, 0.20)
	armor_mat.emission_energy_multiplier = 0.30
	var body: MeshInstance3D = MeshInstance3D.new()
	var bmesh: CapsuleMesh = CapsuleMesh.new()
	bmesh.radius = 0.45
	bmesh.height = 1.30
	body.mesh = bmesh
	body.position = Vector3(0, 0.70, 0)
	body.material_override = armor_mat
	watch.add_child(body)
	# Helmet — dark cylinder
	var helmet: MeshInstance3D = MeshInstance3D.new()
	var hmesh: CylinderMesh = CylinderMesh.new()
	hmesh.top_radius = 0.35
	hmesh.bottom_radius = 0.40
	hmesh.height = 0.50
	helmet.mesh = hmesh
	helmet.position = Vector3(0, 1.55, 0)
	var hmat: StandardMaterial3D = StandardMaterial3D.new()
	hmat.albedo_color = Color(0.10, 0.10, 0.12)
	hmat.metallic = 0.85
	hmat.roughness = 0.30
	helmet.material_override = hmat
	watch.add_child(helmet)
	# Red glowing visor strip across the front
	var visor: MeshInstance3D = MeshInstance3D.new()
	var vmesh: BoxMesh = BoxMesh.new()
	vmesh.size = Vector3(0.55, 0.10, 0.04)
	visor.mesh = vmesh
	visor.position = Vector3(0, 1.55, 0.34)
	var vmat: StandardMaterial3D = StandardMaterial3D.new()
	vmat.albedo_color = Color(1.0, 0.20, 0.20)
	vmat.emission_enabled = true
	vmat.emission = Color(1.0, 0.30, 0.30)
	vmat.emission_energy_multiplier = 2.6
	vmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	visor.material_override = vmat
	watch.add_child(visor)
	# Pulse rifle held diagonally across the body
	var rifle_root: Node3D = Node3D.new()
	rifle_root.position = Vector3(0.20, 0.85, 0.40)
	rifle_root.rotation = Vector3(0, deg_to_rad(20), deg_to_rad(-25))
	watch.add_child(rifle_root)
	# Rifle body
	var rifle: MeshInstance3D = MeshInstance3D.new()
	var rmesh: BoxMesh = BoxMesh.new()
	rmesh.size = Vector3(0.10, 0.18, 1.40)
	rifle.mesh = rmesh
	rifle.material_override = hmat
	rifle_root.add_child(rifle)
	# Glowing barrel tip
	var muzzle: MeshInstance3D = MeshInstance3D.new()
	var mm: SphereMesh = SphereMesh.new()
	mm.radius = 0.10
	mm.height = 0.20
	muzzle.mesh = mm
	muzzle.position = Vector3(0, 0, -0.85)
	var muz_mat: StandardMaterial3D = StandardMaterial3D.new()
	muz_mat.albedo_color = Color(1.0, 0.40, 0.20)
	muz_mat.emission_enabled = true
	muz_mat.emission = Color(1.0, 0.55, 0.20)
	muz_mat.emission_energy_multiplier = 2.4
	muz_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	muzzle.material_override = muz_mat
	rifle_root.add_child(muzzle)
	# Patrol path — back and forth along z
	var origin: Vector3 = D2_CENTER + Vector3(18, 0, -10)
	var patrol: Tween = create_tween().set_loops()
	patrol.tween_property(watch, "rotation:y", deg_to_rad(180), 0.4)
	patrol.tween_property(watch, "position", origin + Vector3(0, 0, -8), 6.0)
	patrol.tween_property(watch, "rotation:y", 0.0, 0.4)
	patrol.tween_property(watch, "position", origin, 6.0)
	# Name billboard
	var label: Label3D = Label3D.new()
	label.text = "Watchman"
	label.position = Vector3(0, 2.10, 0)
	label.modulate = Color(1.0, 0.55, 0.30)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 18
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	watch.add_child(label)


static func _build_d2_smoke_vents(geom: Node) -> void:
	## Epic-2 T30: 5 ground steam/smoke vents emitting upward streams.
	## Each is a small dark grate with a particle column rising from it.
	var positions: Array[Vector3] = [
		D2_CENTER + Vector3(-10, 0, 6),
		D2_CENTER + Vector3(0, 0, -8),
		D2_CENTER + Vector3(8, 0, 12),
		D2_CENTER + Vector3(20, 0, -2),
		D2_CENTER + Vector3(-4, 0, -16),
	]
	for i in positions.size():
		var vent: Node3D = Node3D.new()
		vent.name = "D2SmokeVent_%d" % i
		vent.position = positions[i]
		geom.add_child(vent)
		# Grate — dark short cylinder flush with ground
		var grate: MeshInstance3D = MeshInstance3D.new()
		var gmesh: CylinderMesh = CylinderMesh.new()
		gmesh.top_radius = 0.45
		gmesh.bottom_radius = 0.45
		gmesh.height = 0.10
		grate.mesh = gmesh
		grate.position = Vector3(0, 0.05, 0)
		var gmat: StandardMaterial3D = StandardMaterial3D.new()
		gmat.albedo_color = Color(0.06, 0.06, 0.10)
		gmat.metallic = 0.65
		gmat.roughness = 0.55
		gmat.emission_enabled = true
		gmat.emission = Color(0.85, 0.30, 0.20)
		gmat.emission_energy_multiplier = 0.55
		grate.material_override = gmat
		vent.add_child(grate)
		# 4 cross bars on top to look like a grate
		for b in 4:
			var bar: MeshInstance3D = MeshInstance3D.new()
			var bmesh: BoxMesh = BoxMesh.new()
			bmesh.size = Vector3(0.85, 0.04, 0.06)
			bar.mesh = bmesh
			bar.position = Vector3(0, 0.13, -0.30 + b * 0.20)
			bar.material_override = gmat
			vent.add_child(bar)
		# Smoke particles rising
		var smoke: GPUParticles3D = GPUParticles3D.new()
		smoke.amount = 24
		smoke.lifetime = 3.0
		smoke.position = Vector3(0, 0.40, 0)
		var pmat: ParticleProcessMaterial = ParticleProcessMaterial.new()
		pmat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
		pmat.emission_sphere_radius = 0.30
		pmat.direction = Vector3(0, 1, 0)
		pmat.spread = 18.0
		pmat.initial_velocity_min = 0.45
		pmat.initial_velocity_max = 0.85
		pmat.gravity = Vector3.ZERO
		pmat.scale_min = 0.30
		pmat.scale_max = 0.55
		pmat.color = Color(0.40, 0.40, 0.50, 0.55)
		smoke.process_material = pmat
		var sm: SphereMesh = SphereMesh.new()
		sm.radius = 0.30
		sm.height = 0.60
		var sm_mat: StandardMaterial3D = StandardMaterial3D.new()
		sm_mat.albedo_color = Color(0.40, 0.40, 0.50, 0.55)
		sm_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		sm_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		sm.material = sm_mat
		smoke.draw_pass_1 = sm
		vent.add_child(smoke)


static func _build_d2_toxic_barrels(geom: Node) -> void:
	## Epic-2 T31: cluster of 6 yellow toxic barrels with glowing rims +
	## hazard symbols. Some are tipped over, some upright. Sells "this
	## stuff is dangerous, the workers couldn't seal it back up".
	var cluster: Node3D = Node3D.new()
	cluster.name = "D2ToxicBarrels"
	cluster.position = D2_CENTER + Vector3(-3, 0, -8)
	geom.add_child(cluster)
	var body_mat: StandardMaterial3D = StandardMaterial3D.new()
	body_mat.albedo_color = Color(0.85, 0.65, 0.10)
	body_mat.metallic = 0.45
	body_mat.roughness = 0.55
	var rim_mat: StandardMaterial3D = StandardMaterial3D.new()
	rim_mat.albedo_color = Color(0.30, 1.0, 0.30)
	rim_mat.emission_enabled = true
	rim_mat.emission = Color(0.45, 1.0, 0.40)
	rim_mat.emission_energy_multiplier = 1.8
	rim_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var barrel_specs: Array = [
		[Vector3(0.0, 0.55, 0.0), Vector3(0, 0, 0)],
		[Vector3(1.2, 0.55, 0.4), Vector3(0, 0, 0)],
		[Vector3(-1.0, 0.55, 0.6), Vector3(0, 0, 0)],
		[Vector3(0.5, 0.55, -1.2), Vector3(0, 0, 0)],
		[Vector3(2.2, 0.30, -0.6), Vector3(deg_to_rad(85), deg_to_rad(20), 0)],
		[Vector3(-1.8, 0.30, -0.4), Vector3(deg_to_rad(80), deg_to_rad(-30), 0)],
	]
	for i in barrel_specs.size():
		var barrel: Node3D = Node3D.new()
		barrel.name = "Barrel_%d" % i
		barrel.position = barrel_specs[i][0]
		barrel.rotation = barrel_specs[i][1]
		cluster.add_child(barrel)
		# Body cylinder
		var body: MeshInstance3D = MeshInstance3D.new()
		var bmesh: CylinderMesh = CylinderMesh.new()
		bmesh.top_radius = 0.40
		bmesh.bottom_radius = 0.40
		bmesh.height = 1.05
		body.mesh = bmesh
		body.material_override = body_mat
		barrel.add_child(body)
		# Top + bottom rim
		for ry: float in [-0.50, 0.50]:
			var rim: MeshInstance3D = MeshInstance3D.new()
			var rmesh: TorusMesh = TorusMesh.new()
			rmesh.inner_radius = 0.40
			rmesh.outer_radius = 0.45
			rim.mesh = rmesh
			rim.position = Vector3(0, ry, 0)
			rim.material_override = rim_mat
			barrel.add_child(rim)
		# Hazard sign label on the side
		var hazard: Label3D = Label3D.new()
		hazard.text = "☢"
		hazard.position = Vector3(0, 0, 0.41)
		hazard.modulate = Color(0.10, 0.10, 0.10)
		hazard.outline_size = 0
		hazard.font_size = 32
		hazard.no_depth_test = true
		barrel.add_child(hazard)
	# Collision around the cluster
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(4.5, 1.20, 3.0)
	cs.shape = cb
	cs.position = Vector3(0, 0.60, 0)
	sb.add_child(cs)
	cluster.add_child(sb)


static func _build_d2_buried_arm(geom: Node) -> void:
	## Epic-2 T32: half-buried giant mechanical arm sticking out of the
	## ground at an angle, frozen in a gripping pose. 4 segments + a
	## 4-fingered claw at the top. Mysterious lore-piece scale prop.
	var arm: Node3D = Node3D.new()
	arm.name = "D2BuriedArm"
	arm.position = D2_CENTER + Vector3(0, 0, 18)
	arm.rotation = Vector3(0, deg_to_rad(35), deg_to_rad(-30))
	geom.add_child(arm)
	var metal_mat: StandardMaterial3D = StandardMaterial3D.new()
	metal_mat.albedo_color = Color(0.20, 0.22, 0.28)
	metal_mat.metallic = 0.85
	metal_mat.roughness = 0.40
	# 4 stacked arm segments (each smaller than the last)
	var segment_sizes: Array[float] = [1.20, 1.0, 0.85, 0.65]
	var current_y: float = 0.0
	for i in segment_sizes.size():
		var seg: MeshInstance3D = MeshInstance3D.new()
		var smesh: BoxMesh = BoxMesh.new()
		var seg_height: float = 1.6
		smesh.size = Vector3(segment_sizes[i], seg_height, segment_sizes[i])
		seg.mesh = smesh
		seg.position = Vector3(0, current_y + seg_height * 0.5, 0)
		seg.material_override = metal_mat
		arm.add_child(seg)
		# Glowing joint ring at the bottom of each segment except the first
		if i > 0:
			var joint: MeshInstance3D = MeshInstance3D.new()
			var jm: TorusMesh = TorusMesh.new()
			jm.inner_radius = segment_sizes[i] * 0.55
			jm.outer_radius = segment_sizes[i] * 0.70
			joint.mesh = jm
			joint.position = Vector3(0, current_y, 0)
			var jmat: StandardMaterial3D = StandardMaterial3D.new()
			jmat.albedo_color = Color(1.0, 0.40, 0.20)
			jmat.emission_enabled = true
			jmat.emission = Color(1.0, 0.55, 0.20)
			jmat.emission_energy_multiplier = 1.8
			jmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
			joint.material_override = jmat
			arm.add_child(joint)
		current_y += seg_height
	# 4 finger claws at the top, splayed outward
	for f in 4:
		var angle: float = (float(f) / 4.0) * TAU
		var finger: MeshInstance3D = MeshInstance3D.new()
		var fmesh: BoxMesh = BoxMesh.new()
		fmesh.size = Vector3(0.18, 1.20, 0.18)
		finger.mesh = fmesh
		finger.position = Vector3(cos(angle) * 0.45, current_y + 0.50, sin(angle) * 0.45)
		finger.rotation = Vector3(deg_to_rad(20) * sin(angle), 0, deg_to_rad(20) * cos(angle))
		finger.material_override = metal_mat
		arm.add_child(finger)
	# Collision around the base
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cap: CapsuleShape3D = CapsuleShape3D.new()
	cap.radius = 0.85
	cap.height = current_y
	cs.shape = cap
	cs.position = Vector3(0, current_y * 0.5, 0)
	sb.add_child(cs)
	arm.add_child(sb)


static func _build_d2_fire_pit(geom: Node) -> void:
	## Epic-2 T33: campfire pit with crackling fire particles + 2 small
	## NPCs (silhouette capsules) seated around it. The first sign of
	## "people gather here for warmth" in the dangerous district.
	var fire: Node3D = Node3D.new()
	fire.name = "D2FirePit"
	fire.position = D2_CENTER + Vector3(-12, 0, 10)
	geom.add_child(fire)
	# Stone ring
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.16, 0.14, 0.12)
	stone_mat.metallic = 0.30
	stone_mat.roughness = 0.55
	for s in 8:
		var angle: float = (float(s) / 8.0) * TAU
		var stone: MeshInstance3D = MeshInstance3D.new()
		var smesh: BoxMesh = BoxMesh.new()
		smesh.size = Vector3(0.35, 0.20, 0.30)
		stone.mesh = smesh
		stone.position = Vector3(cos(angle) * 0.85, 0.10, sin(angle) * 0.85)
		stone.rotation = Vector3(0, -angle, 0)
		stone.material_override = stone_mat
		fire.add_child(stone)
	# Logs in center (4 crossed cylinders)
	var log_mat: StandardMaterial3D = StandardMaterial3D.new()
	log_mat.albedo_color = Color(0.30, 0.18, 0.10)
	log_mat.metallic = 0.10
	log_mat.roughness = 0.65
	for i in 4:
		var log_mesh: MeshInstance3D = MeshInstance3D.new()
		var lm: CylinderMesh = CylinderMesh.new()
		lm.top_radius = 0.10
		lm.bottom_radius = 0.10
		lm.height = 1.0
		log_mesh.mesh = lm
		log_mesh.position = Vector3(0, 0.20, 0)
		log_mesh.rotation = Vector3(deg_to_rad(85), deg_to_rad(45 * i), 0)
		log_mesh.material_override = log_mat
		fire.add_child(log_mesh)
	# Glowing ember core
	var ember: MeshInstance3D = MeshInstance3D.new()
	var em: SphereMesh = SphereMesh.new()
	em.radius = 0.30
	em.height = 0.60
	ember.mesh = em
	ember.position = Vector3(0, 0.30, 0)
	var em_mat: StandardMaterial3D = StandardMaterial3D.new()
	em_mat.albedo_color = Color(1.0, 0.55, 0.20)
	em_mat.emission_enabled = true
	em_mat.emission = Color(1.0, 0.65, 0.20)
	em_mat.emission_energy_multiplier = 2.6
	em_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	ember.material_override = em_mat
	fire.add_child(ember)
	# Pulse ember
	var pulse: Tween = create_tween().set_loops()
	pulse.tween_property(ember, "scale", Vector3(1.20, 1.20, 1.20), 0.6).set_ease(Tween.EASE_IN_OUT)
	pulse.tween_property(ember, "scale", Vector3(0.95, 0.95, 0.95), 0.6).set_ease(Tween.EASE_IN_OUT)
	# Real omni light from fire
	var light: OmniLight3D = OmniLight3D.new()
	light.position = Vector3(0, 0.5, 0)
	light.light_color = Color(1.0, 0.65, 0.30)
	light.light_energy = 2.4
	light.omni_range = 7.0
	fire.add_child(light)
	# Flame particles rising
	var flames: GPUParticles3D = GPUParticles3D.new()
	flames.amount = 50
	flames.lifetime = 1.4
	flames.position = Vector3(0, 0.45, 0)
	var pmat: ParticleProcessMaterial = ParticleProcessMaterial.new()
	pmat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	pmat.emission_sphere_radius = 0.25
	pmat.direction = Vector3(0, 1, 0)
	pmat.spread = 18.0
	pmat.initial_velocity_min = 1.4
	pmat.initial_velocity_max = 2.4
	pmat.gravity = Vector3.ZERO
	pmat.scale_min = 0.18
	pmat.scale_max = 0.35
	pmat.color = Color(1.0, 0.55, 0.20, 1.0)
	flames.process_material = pmat
	var flame_mesh: SphereMesh = SphereMesh.new()
	flame_mesh.radius = 0.18
	flame_mesh.height = 0.36
	var flame_mat: StandardMaterial3D = StandardMaterial3D.new()
	flame_mat.albedo_color = Color(1.0, 0.55, 0.20)
	flame_mat.emission_enabled = true
	flame_mat.emission = Color(1.0, 0.65, 0.20)
	flame_mat.emission_energy_multiplier = 2.4
	flame_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	flame_mesh.material = flame_mat
	flames.draw_pass_1 = flame_mesh
	fire.add_child(flames)
	# 2 seated silhouettes (capsules) around the fire
	var sit_mat: StandardMaterial3D = StandardMaterial3D.new()
	sit_mat.albedo_color = Color(0.16, 0.10, 0.06)
	sit_mat.metallic = 0.10
	sit_mat.roughness = 0.65
	for spec in [[Vector3(-1.7, 0.35, 0), Color(1.0, 0.65, 0.30)], [Vector3(1.7, 0.35, 0), Color(1.0, 0.55, 0.20)]]:
		var npc: MeshInstance3D = MeshInstance3D.new()
		var nmesh: CapsuleMesh = CapsuleMesh.new()
		nmesh.radius = 0.30
		nmesh.height = 0.55
		npc.mesh = nmesh
		npc.position = spec[0]
		npc.rotation = Vector3(deg_to_rad(15), 0, 0)
		npc.material_override = sit_mat
		fire.add_child(npc)
		# Glowing eye facing the fire
		var eye: MeshInstance3D = MeshInstance3D.new()
		var eye_mesh: SphereMesh = SphereMesh.new()
		eye_mesh.radius = 0.05
		eye_mesh.height = 0.10
		eye.mesh = eye_mesh
		var to_fire_x: float = -sign(spec[0].x) * 0.30
		eye.position = (spec[0] as Vector3) + Vector3(to_fire_x, 0.10, 0)
		var eye_mat: StandardMaterial3D = StandardMaterial3D.new()
		var eye_color: Color = spec[1]
		eye_mat.albedo_color = eye_color
		eye_mat.emission_enabled = true
		eye_mat.emission = eye_color
		eye_mat.emission_energy_multiplier = 2.6
		eye_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		eye.material_override = eye_mat
		fire.add_child(eye)


static func _build_d2_hoverbike_wreck(geom: Node) -> void:
	## Epic-2 T34: a wrecked hover-bike at the side of the road, tilted on
	## its side, with one engine pod sparking. Tells "fast travel exists
	## here but it's deadly".
	var bike: Node3D = Node3D.new()
	bike.name = "D2HoverbikeWreck"
	bike.position = D2_CENTER + Vector3(10, 0, -16)
	bike.rotation = Vector3(0, deg_to_rad(-25), deg_to_rad(35))
	geom.add_child(bike)
	# Main fuselage — long box
	var hull_mat: StandardMaterial3D = StandardMaterial3D.new()
	hull_mat.albedo_color = Color(0.20, 0.22, 0.28)
	hull_mat.metallic = 0.85
	hull_mat.roughness = 0.30
	var hull: MeshInstance3D = MeshInstance3D.new()
	var hmesh: BoxMesh = BoxMesh.new()
	hmesh.size = Vector3(1.40, 0.40, 0.55)
	hull.mesh = hmesh
	hull.position = Vector3(0, 0.45, 0)
	hull.material_override = hull_mat
	bike.add_child(hull)
	# Pointy nose (prism)
	var nose: MeshInstance3D = MeshInstance3D.new()
	var nmesh: PrismMesh = PrismMesh.new()
	nmesh.size = Vector3(0.55, 0.40, 0.55)
	nose.mesh = nmesh
	nose.position = Vector3(0.95, 0.45, 0)
	nose.rotation = Vector3(0, deg_to_rad(90), 0)
	nose.material_override = hull_mat
	bike.add_child(nose)
	# Handlebars (thin bar across)
	var bar: MeshInstance3D = MeshInstance3D.new()
	var bmesh: CylinderMesh = CylinderMesh.new()
	bmesh.top_radius = 0.05
	bmesh.bottom_radius = 0.05
	bmesh.height = 0.85
	bar.mesh = bmesh
	bar.position = Vector3(0.55, 0.55, 0)
	bar.rotation = Vector3(deg_to_rad(90), 0, 0)
	bar.material_override = hull_mat
	bike.add_child(bar)
	# 2 engine pods on each side
	var engine_mat: StandardMaterial3D = StandardMaterial3D.new()
	engine_mat.albedo_color = Color(0.30, 0.10, 0.06)
	engine_mat.emission_enabled = true
	engine_mat.emission = Color(1.0, 0.40, 0.20)
	engine_mat.emission_energy_multiplier = 0.85
	engine_mat.metallic = 0.55
	for sz: float in [-0.55, 0.55]:
		var pod: MeshInstance3D = MeshInstance3D.new()
		var pmesh: CylinderMesh = CylinderMesh.new()
		pmesh.top_radius = 0.18
		pmesh.bottom_radius = 0.22
		pmesh.height = 1.0
		pod.mesh = pmesh
		pod.position = Vector3(-0.30, 0.45, sz)
		pod.rotation = Vector3(deg_to_rad(90), 0, 0)
		pod.material_override = engine_mat
		bike.add_child(pod)
	# Sparks from one engine
	var sparks: GPUParticles3D = GPUParticles3D.new()
	sparks.amount = 24
	sparks.lifetime = 0.85
	sparks.position = Vector3(-0.80, 0.45, 0.55)
	var spmat: ParticleProcessMaterial = ParticleProcessMaterial.new()
	spmat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	spmat.emission_sphere_radius = 0.10
	spmat.direction = Vector3(-1, 0.5, 0)
	spmat.spread = 50.0
	spmat.initial_velocity_min = 1.4
	spmat.initial_velocity_max = 2.4
	spmat.gravity = Vector3(0, -2.0, 0)
	spmat.scale_min = 0.04
	spmat.scale_max = 0.10
	spmat.color = Color(1.0, 0.85, 0.30, 1.0)
	sparks.process_material = spmat
	var sm: SphereMesh = SphereMesh.new()
	sm.radius = 0.05
	sm.height = 0.10
	var sm_mat: StandardMaterial3D = StandardMaterial3D.new()
	sm_mat.albedo_color = Color(1.0, 0.85, 0.30)
	sm_mat.emission_enabled = true
	sm_mat.emission = Color(1.0, 0.95, 0.40)
	sm_mat.emission_energy_multiplier = 2.6
	sm_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	sm.material = sm_mat
	sparks.draw_pass_1 = sm
	bike.add_child(sparks)
	# Collision around the wreck
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(2.4, 1.0, 1.6)
	cs.shape = cb
	cs.position = Vector3(0, 0.45, 0)
	sb.add_child(cs)
	bike.add_child(sb)


static func _build_d2_code_waterfall(geom: Node) -> void:
	## Epic-2 T35: a vertical "code stream waterfall" — a tall narrow
	## column of green emissive characters falling from a high broken
	## conduit at the back of the district. Particles + a Label3D ribbon.
	var fall: Node3D = Node3D.new()
	fall.name = "D2CodeWaterfall"
	fall.position = D2_CENTER + Vector3(-22, 0, -2)
	geom.add_child(fall)
	# Broken conduit pipe at the top (small box)
	var pipe_mat: StandardMaterial3D = StandardMaterial3D.new()
	pipe_mat.albedo_color = Color(0.20, 0.22, 0.28)
	pipe_mat.metallic = 0.85
	pipe_mat.roughness = 0.30
	var pipe: MeshInstance3D = MeshInstance3D.new()
	var pmesh: CylinderMesh = CylinderMesh.new()
	pmesh.top_radius = 0.30
	pmesh.bottom_radius = 0.30
	pmesh.height = 1.4
	pipe.mesh = pmesh
	pipe.position = Vector3(0, 7.5, 0)
	pipe.rotation = Vector3(0, 0, deg_to_rad(90))
	pipe.material_override = pipe_mat
	fall.add_child(pipe)
	# Falling green particles
	var stream: GPUParticles3D = GPUParticles3D.new()
	stream.amount = 80
	stream.lifetime = 3.5
	stream.position = Vector3(0, 7.0, 0)
	var spmat: ParticleProcessMaterial = ParticleProcessMaterial.new()
	spmat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	spmat.emission_sphere_radius = 0.20
	spmat.direction = Vector3(0, -1, 0)
	spmat.spread = 4.0
	spmat.initial_velocity_min = 0.85
	spmat.initial_velocity_max = 1.40
	spmat.gravity = Vector3(0, -1.5, 0)
	spmat.scale_min = 0.10
	spmat.scale_max = 0.18
	spmat.color = Color(0.40, 1.0, 0.55, 1.0)
	stream.process_material = spmat
	var bit: BoxMesh = BoxMesh.new()
	bit.size = Vector3(0.10, 0.18, 0.04)
	var bit_mat: StandardMaterial3D = StandardMaterial3D.new()
	bit_mat.albedo_color = Color(0.40, 1.0, 0.55)
	bit_mat.emission_enabled = true
	bit_mat.emission = Color(0.55, 1.0, 0.55)
	bit_mat.emission_energy_multiplier = 2.6
	bit_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	bit.material = bit_mat
	stream.draw_pass_1 = bit
	fall.add_child(stream)
	# 3 floating "01" Label3D ribbons inside the column
	for i in 3:
		var ribbon: Label3D = Label3D.new()
		ribbon.text = "01010\n10110\n01101"
		ribbon.position = Vector3(randf_range(-0.20, 0.20), 5.0 - i * 1.6, 0)
		ribbon.modulate = Color(0.40, 1.0, 0.55)
		ribbon.outline_modulate = Color(0, 0, 0, 0.85)
		ribbon.outline_size = 3
		ribbon.font_size = 16
		ribbon.no_depth_test = true
		ribbon.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		fall.add_child(ribbon)
		# Drift down + reset
		var drift: Tween = create_tween().set_loops()
		var origin_y: float = ribbon.position.y
		drift.tween_property(ribbon, "position:y", origin_y - 4.0, 3.5)
		drift.tween_property(ribbon, "position:y", origin_y, 0.05)
	# Collision around the conduit pipe
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cap: CapsuleShape3D = CapsuleShape3D.new()
	cap.radius = 0.40
	cap.height = 1.4
	cs.shape = cap
	cs.position = Vector3(0, 7.5, 0)
	sb.add_child(cs)
	fall.add_child(sb)


static func _build_d2_dust_storm(geom: Node) -> void:
	## Epic-2 T36: horizontal dust storm particles drifting eastward across
	## the entire D2 floor — large slow grey-amber motes carried by wind.
	var dust: GPUParticles3D = GPUParticles3D.new()
	dust.name = "D2DustStorm"
	dust.position = D2_CENTER + Vector3(-25, 3, 0)
	dust.amount = 80
	dust.lifetime = 8.0
	dust.preprocess = 4.0
	var pmat: ParticleProcessMaterial = ParticleProcessMaterial.new()
	pmat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	pmat.emission_box_extents = Vector3(0.5, 4.0, 18.0)
	pmat.direction = Vector3(1, 0, 0)
	pmat.spread = 6.0
	pmat.initial_velocity_min = 1.4
	pmat.initial_velocity_max = 2.2
	pmat.gravity = Vector3.ZERO
	pmat.scale_min = 0.30
	pmat.scale_max = 0.55
	pmat.color = Color(0.85, 0.65, 0.40, 0.30)
	dust.process_material = pmat
	var dmesh: SphereMesh = SphereMesh.new()
	dmesh.radius = 0.30
	dmesh.height = 0.60
	var dmat: StandardMaterial3D = StandardMaterial3D.new()
	dmat.albedo_color = Color(0.85, 0.65, 0.40, 0.30)
	dmat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	dmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	dmesh.material = dmat
	dust.draw_pass_1 = dmesh
	geom.add_child(dust)


static func _build_d2_data_well(geom: Node) -> void:
	## Epic-2 T37: an ancient data well — a stone circular rim around a
	## glowing cyan pool, with a winch frame above it. The pool surface
	## ripples (scale tween). The first sign of "old infrastructure" in D2.
	var well: Node3D = Node3D.new()
	well.name = "D2DataWell"
	well.position = D2_CENTER + Vector3(0, 0, 6)
	geom.add_child(well)
	# Stone rim torus
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.20, 0.18, 0.14)
	stone_mat.metallic = 0.30
	stone_mat.roughness = 0.65
	var rim: MeshInstance3D = MeshInstance3D.new()
	var rmesh: TorusMesh = TorusMesh.new()
	rmesh.inner_radius = 0.85
	rmesh.outer_radius = 1.15
	rim.mesh = rmesh
	rim.position = Vector3(0, 0.30, 0)
	rim.material_override = stone_mat
	well.add_child(rim)
	# Pool surface inside the rim — glowing cyan disc
	var pool: MeshInstance3D = MeshInstance3D.new()
	var pmesh: CylinderMesh = CylinderMesh.new()
	pmesh.top_radius = 0.85
	pmesh.bottom_radius = 0.85
	pmesh.height = 0.05
	pool.mesh = pmesh
	pool.position = Vector3(0, 0.30, 0)
	var pmat: StandardMaterial3D = StandardMaterial3D.new()
	pmat.albedo_color = Color(0.30, 0.85, 1.0, 0.85)
	pmat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	pmat.emission_enabled = true
	pmat.emission = Color(0.55, 0.95, 1.0)
	pmat.emission_energy_multiplier = 1.6
	pmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	pool.material_override = pmat
	well.add_child(pool)
	# Ripple tween — scale x/z slightly
	var ripple: Tween = create_tween().set_loops()
	ripple.tween_property(pool, "scale", Vector3(1.05, 1.0, 0.96), 1.6).set_ease(Tween.EASE_IN_OUT)
	ripple.tween_property(pool, "scale", Vector3(0.96, 1.0, 1.05), 1.6).set_ease(Tween.EASE_IN_OUT)
	# Winch frame above the well — 4 legs + top crossbar
	var metal_mat: StandardMaterial3D = StandardMaterial3D.new()
	metal_mat.albedo_color = Color(0.10, 0.13, 0.16)
	metal_mat.metallic = 0.85
	metal_mat.roughness = 0.30
	for ox: float in [-0.95, 0.95]:
		for oz: float in [-0.95, 0.95]:
			var leg: MeshInstance3D = MeshInstance3D.new()
			var lmesh: CylinderMesh = CylinderMesh.new()
			lmesh.top_radius = 0.06
			lmesh.bottom_radius = 0.08
			lmesh.height = 2.4
			leg.mesh = lmesh
			leg.position = Vector3(ox * 0.85, 1.20, oz * 0.85)
			# Tilt legs inward to form a tripod top
			leg.rotation = Vector3(-sign(oz) * deg_to_rad(8), 0, sign(ox) * deg_to_rad(8))
			leg.material_override = metal_mat
			well.add_child(leg)
	# Top crossbar
	var bar: MeshInstance3D = MeshInstance3D.new()
	var bmesh: CylinderMesh = CylinderMesh.new()
	bmesh.top_radius = 0.07
	bmesh.bottom_radius = 0.07
	bmesh.height = 1.6
	bar.mesh = bmesh
	bar.position = Vector3(0, 2.40, 0)
	bar.rotation = Vector3(0, 0, deg_to_rad(90))
	bar.material_override = metal_mat
	well.add_child(bar)
	# Hanging bucket on a chain (cylinder + thin chain)
	var chain: MeshInstance3D = MeshInstance3D.new()
	var cmesh: CylinderMesh = CylinderMesh.new()
	cmesh.top_radius = 0.02
	cmesh.bottom_radius = 0.02
	cmesh.height = 1.40
	chain.mesh = cmesh
	chain.position = Vector3(0, 1.70, 0)
	chain.material_override = metal_mat
	well.add_child(chain)
	var bucket: MeshInstance3D = MeshInstance3D.new()
	var buc_mesh: CylinderMesh = CylinderMesh.new()
	buc_mesh.top_radius = 0.20
	buc_mesh.bottom_radius = 0.18
	buc_mesh.height = 0.30
	bucket.mesh = buc_mesh
	bucket.position = Vector3(0, 1.0, 0)
	bucket.material_override = metal_mat
	well.add_child(bucket)
	# Sign
	var label: Label3D = Label3D.new()
	label.text = "DATA WELL"
	label.position = Vector3(0, 3.0, 0)
	label.modulate = Color(0.55, 0.95, 1.0)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 18
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	well.add_child(label)
	# Collision around the rim
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(2.4, 1.0, 2.4)
	cs.shape = cb
	cs.position = Vector3(0, 0.40, 0)
	sb.add_child(cs)
	well.add_child(sb)


static func _build_d2_scrap_tower(geom: Node) -> void:
	## Epic-2 T38: a tall stacked tower of broken machines welded together
	## haphazardly. 8 random boxes in different sizes/orientations climbing
	## upward, topped by a small antenna. Decorative landmark.
	var tower: Node3D = Node3D.new()
	tower.name = "D2ScrapTower"
	tower.position = D2_CENTER + Vector3(-22, 0, 12)
	geom.add_child(tower)
	var dark_mat: StandardMaterial3D = StandardMaterial3D.new()
	dark_mat.albedo_color = Color(0.18, 0.16, 0.12)
	dark_mat.metallic = 0.65
	dark_mat.roughness = 0.55
	var rust_mat: StandardMaterial3D = StandardMaterial3D.new()
	rust_mat.albedo_color = Color(0.40, 0.20, 0.10)
	rust_mat.metallic = 0.30
	rust_mat.roughness = 0.65
	var current_y: float = 0.0
	for i in 8:
		var size: float = 1.5 - i * 0.10
		var height: float = 0.85 + randf_range(-0.20, 0.30)
		var box: MeshInstance3D = MeshInstance3D.new()
		var bmesh: BoxMesh = BoxMesh.new()
		bmesh.size = Vector3(size, height, size)
		box.mesh = bmesh
		box.position = Vector3(randf_range(-0.20, 0.20), current_y + height * 0.5, randf_range(-0.20, 0.20))
		box.rotation = Vector3(0, deg_to_rad(randf_range(-25, 25)), 0)
		box.material_override = dark_mat if i % 2 == 0 else rust_mat
		tower.add_child(box)
		# Random LED
		if i % 2 == 0:
			var led: MeshInstance3D = MeshInstance3D.new()
			var lmesh: SphereMesh = SphereMesh.new()
			lmesh.radius = 0.06
			lmesh.height = 0.12
			led.mesh = lmesh
			led.position = Vector3(0, current_y + height * 0.5, size * 0.5 + 0.04)
			var lmat: StandardMaterial3D = StandardMaterial3D.new()
			lmat.albedo_color = Color(0.30, 1.0, 0.40)
			lmat.emission_enabled = true
			lmat.emission = Color(0.45, 1.0, 0.45)
			lmat.emission_energy_multiplier = 2.0
			lmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
			led.material_override = lmat
			tower.add_child(led)
		current_y += height
	# Top antenna
	var antenna: MeshInstance3D = MeshInstance3D.new()
	var amesh: CylinderMesh = CylinderMesh.new()
	amesh.top_radius = 0.04
	amesh.bottom_radius = 0.10
	amesh.height = 1.6
	antenna.mesh = amesh
	antenna.position = Vector3(0, current_y + 0.80, 0)
	antenna.material_override = dark_mat
	tower.add_child(antenna)
	# Antenna tip blink
	var tip: MeshInstance3D = MeshInstance3D.new()
	var tmesh: SphereMesh = SphereMesh.new()
	tmesh.radius = 0.10
	tmesh.height = 0.20
	tip.mesh = tmesh
	tip.position = Vector3(0, current_y + 1.65, 0)
	var tip_mat: StandardMaterial3D = StandardMaterial3D.new()
	tip_mat.albedo_color = Color(1.0, 0.40, 0.20)
	tip_mat.emission_enabled = true
	tip_mat.emission = Color(1.0, 0.55, 0.20)
	tip_mat.emission_energy_multiplier = 2.4
	tip_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	tip.material_override = tip_mat
	tower.add_child(tip)
	var blink: Tween = create_tween().set_loops()
	blink.tween_property(tip, "scale", Vector3(0.4, 0.4, 0.4), 0.5).set_ease(Tween.EASE_IN_OUT)
	blink.tween_property(tip, "scale", Vector3(1.4, 1.4, 1.4), 0.5).set_ease(Tween.EASE_IN_OUT)
	# Collision around the whole stack
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(1.6, current_y, 1.6)
	cs.shape = cb
	cs.position = Vector3(0, current_y * 0.5, 0)
	sb.add_child(cs)
	tower.add_child(sb)


static func _build_d2_scrap_vendor_cart(geom: Node) -> void:
	## Epic-2 T39: a beat-up vendor cart selling scrap. Lower body with
	## 2 wheels, a hood with hanging metal bits, a sign reading "SCRAP".
	var cart: Node3D = Node3D.new()
	cart.name = "D2ScrapVendorCart"
	cart.position = D2_CENTER + Vector3(12, 0, 0)
	geom.add_child(cart)
	var rust_mat: StandardMaterial3D = StandardMaterial3D.new()
	rust_mat.albedo_color = Color(0.40, 0.20, 0.10)
	rust_mat.metallic = 0.30
	rust_mat.roughness = 0.65
	# Cart body
	var body: MeshInstance3D = MeshInstance3D.new()
	var bmesh: BoxMesh = BoxMesh.new()
	bmesh.size = Vector3(1.85, 0.85, 1.0)
	body.mesh = bmesh
	body.position = Vector3(0, 0.65, 0)
	body.material_override = rust_mat
	cart.add_child(body)
	# 2 wheels
	var wheel_mat: StandardMaterial3D = StandardMaterial3D.new()
	wheel_mat.albedo_color = Color(0.10, 0.10, 0.12)
	wheel_mat.metallic = 0.55
	for sx: float in [-0.85, 0.85]:
		var wheel: MeshInstance3D = MeshInstance3D.new()
		var wmesh: CylinderMesh = CylinderMesh.new()
		wmesh.top_radius = 0.30
		wmesh.bottom_radius = 0.30
		wmesh.height = 0.10
		wheel.mesh = wmesh
		wheel.position = Vector3(sx, 0.30, 0)
		wheel.rotation = Vector3(0, 0, deg_to_rad(90))
		wheel.material_override = wheel_mat
		cart.add_child(wheel)
	# Hood roof — angled box overhead
	var hood: MeshInstance3D = MeshInstance3D.new()
	var hmesh: BoxMesh = BoxMesh.new()
	hmesh.size = Vector3(2.2, 0.10, 1.4)
	hood.mesh = hmesh
	hood.position = Vector3(0, 1.85, 0)
	var hmat: StandardMaterial3D = StandardMaterial3D.new()
	hmat.albedo_color = Color(0.20, 0.16, 0.12)
	hmat.metallic = 0.30
	hmat.roughness = 0.55
	hood.material_override = hmat
	cart.add_child(hood)
	# 4 vertical poles holding hood up
	var pole_mat: StandardMaterial3D = StandardMaterial3D.new()
	pole_mat.albedo_color = Color(0.10, 0.13, 0.16)
	pole_mat.metallic = 0.85
	for ox: float in [-0.95, 0.95]:
		for oz: float in [-0.55, 0.55]:
			var pole: MeshInstance3D = MeshInstance3D.new()
			var pmesh: CylinderMesh = CylinderMesh.new()
			pmesh.top_radius = 0.04
			pmesh.bottom_radius = 0.04
			pmesh.height = 0.85
			pole.mesh = pmesh
			pole.position = Vector3(ox, 1.40, oz)
			pole.material_override = pole_mat
			cart.add_child(pole)
	# 5 hanging metal scrap bits from the hood
	for i in 5:
		var bit: MeshInstance3D = MeshInstance3D.new()
		var bmesh2: BoxMesh = BoxMesh.new()
		bmesh2.size = Vector3(0.18, 0.18, 0.04)
		bit.mesh = bmesh2
		var bx: float = -0.85 + i * 0.40
		bit.position = Vector3(bx, 1.65, 0.30)
		bit.rotation = Vector3(0, 0, deg_to_rad(randf_range(-25, 25)))
		bit.material_override = pole_mat
		cart.add_child(bit)
	# Sign
	var label: Label3D = Label3D.new()
	label.text = "SCRAP"
	label.position = Vector3(0, 2.20, 0)
	label.modulate = Color(1.0, 0.55, 0.20)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 22
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	cart.add_child(label)
	# Collision around body
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(2.0, 1.6, 1.4)
	cs.shape = cb
	cs.position = Vector3(0, 0.85, 0)
	sb.add_child(cs)
	cart.add_child(sb)


static func _build_d2_smuggler_npc(town: Node) -> void:
	## Epic-2 T40: a sneaky smuggler NPC peeking out from behind a shipping
	## container. Crouched body, single shifty cyan eye, holding a small
	## glowing red package. Crouching, with a periodic peek-out animation.
	var slots: Node3D = town.get_node_or_null("%NPCSlots") as Node3D
	if slots == null:
		return
	var smug: Node3D = Node3D.new()
	smug.name = "D2Smuggler"
	smug.position = D2_CENTER + Vector3(20, 0, 12)
	slots.add_child(smug)
	# Crouched body
	var body: MeshInstance3D = MeshInstance3D.new()
	var bmesh: CapsuleMesh = CapsuleMesh.new()
	bmesh.radius = 0.36
	bmesh.height = 0.85
	body.mesh = bmesh
	body.position = Vector3(0, 0.45, 0)
	var bmat: StandardMaterial3D = StandardMaterial3D.new()
	bmat.albedo_color = Color(0.10, 0.10, 0.14)
	bmat.metallic = 0.20
	bmat.roughness = 0.65
	body.material_override = bmat
	smug.add_child(body)
	# Hood
	var hood: MeshInstance3D = MeshInstance3D.new()
	var hmesh: SphereMesh = SphereMesh.new()
	hmesh.radius = 0.40
	hmesh.height = 0.55
	hood.mesh = hmesh
	hood.position = Vector3(0, 1.0, 0)
	hood.material_override = bmat
	smug.add_child(hood)
	# Single shifty cyan eye
	var eye: MeshInstance3D = MeshInstance3D.new()
	var emesh: SphereMesh = SphereMesh.new()
	emesh.radius = 0.08
	emesh.height = 0.16
	eye.mesh = emesh
	eye.position = Vector3(0, 0.95, 0.30)
	var emat: StandardMaterial3D = StandardMaterial3D.new()
	emat.albedo_color = Color(0.30, 0.85, 1.0)
	emat.emission_enabled = true
	emat.emission = Color(0.55, 0.95, 1.0)
	emat.emission_energy_multiplier = 2.6
	emat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	eye.material_override = emat
	smug.add_child(eye)
	# Glowing red package held in front
	var pkg: MeshInstance3D = MeshInstance3D.new()
	var pmesh: BoxMesh = BoxMesh.new()
	pmesh.size = Vector3(0.30, 0.20, 0.30)
	pkg.mesh = pmesh
	pkg.position = Vector3(0.30, 0.50, 0.35)
	var pmat: StandardMaterial3D = StandardMaterial3D.new()
	pmat.albedo_color = Color(0.50, 0.10, 0.10)
	pmat.emission_enabled = true
	pmat.emission = Color(1.0, 0.30, 0.20)
	pmat.emission_energy_multiplier = 1.6
	pmat.metallic = 0.30
	pkg.material_override = pmat
	smug.add_child(pkg)
	# Peek-out tween — body shifts left/right periodically
	var peek: Tween = create_tween().set_loops()
	peek.tween_interval(2.0)
	peek.tween_property(smug, "position:x", D2_CENTER.x + 21.2, 0.5).set_ease(Tween.EASE_OUT)
	peek.tween_interval(1.4)
	peek.tween_property(smug, "position:x", D2_CENTER.x + 20.0, 0.5).set_ease(Tween.EASE_IN)
	# Name billboard
	var label: Label3D = Label3D.new()
	label.text = "Smuggler"
	label.position = Vector3(0, 1.55, 0)
	label.modulate = Color(0.55, 0.95, 1.0)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 16
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	smug.add_child(label)


static func _build_d2_holo_wireframe(geom: Node) -> void:
	## Epic-2 T41: a holographic enemy wireframe billboard — a tall narrow
	## display showing a rotating wireframe glitch beast silhouette. Used
	## by mercenaries as a "WANTED" notice.
	var billboard: Node3D = Node3D.new()
	billboard.name = "D2HoloWireframe"
	billboard.position = D2_CENTER + Vector3(6, 0, -4)
	geom.add_child(billboard)
	# Stand
	var stand_mat: StandardMaterial3D = StandardMaterial3D.new()
	stand_mat.albedo_color = Color(0.10, 0.13, 0.16)
	stand_mat.metallic = 0.85
	stand_mat.roughness = 0.30
	var stand: MeshInstance3D = MeshInstance3D.new()
	var smesh: BoxMesh = BoxMesh.new()
	smesh.size = Vector3(0.30, 0.85, 0.30)
	stand.mesh = smesh
	stand.position = Vector3(0, 0.42, 0)
	stand.material_override = stand_mat
	billboard.add_child(stand)
	# Display panel
	var panel: MeshInstance3D = MeshInstance3D.new()
	var pmesh: BoxMesh = BoxMesh.new()
	pmesh.size = Vector3(1.40, 1.85, 0.10)
	panel.mesh = pmesh
	panel.position = Vector3(0, 1.80, 0)
	var pmat: StandardMaterial3D = StandardMaterial3D.new()
	pmat.albedo_color = Color(0.06, 0.05, 0.10)
	pmat.metallic = 0.40
	pmat.roughness = 0.30
	pmat.emission_enabled = true
	pmat.emission = Color(1.0, 0.30, 0.30)
	pmat.emission_energy_multiplier = 0.45
	panel.material_override = pmat
	billboard.add_child(panel)
	# Rotating wireframe enemy inside the display
	var wire_pivot: Node3D = Node3D.new()
	wire_pivot.position = Vector3(0, 1.80, 0.10)
	billboard.add_child(wire_pivot)
	# Use a wireframe sphere (we approximate with thin emissive bars)
	var wire_mat: StandardMaterial3D = StandardMaterial3D.new()
	wire_mat.albedo_color = Color(1.0, 0.30, 0.30)
	wire_mat.emission_enabled = true
	wire_mat.emission = Color(1.0, 0.40, 0.40)
	wire_mat.emission_energy_multiplier = 2.4
	wire_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	# Body box wireframe (12 edges)
	var size: float = 0.55
	var edges: Array = [
		# Bottom rectangle
		[Vector3(-size, -size, -size), Vector3(size, -size, -size)],
		[Vector3(size, -size, -size), Vector3(size, -size, size)],
		[Vector3(size, -size, size), Vector3(-size, -size, size)],
		[Vector3(-size, -size, size), Vector3(-size, -size, -size)],
		# Top rectangle
		[Vector3(-size, size, -size), Vector3(size, size, -size)],
		[Vector3(size, size, -size), Vector3(size, size, size)],
		[Vector3(size, size, size), Vector3(-size, size, size)],
		[Vector3(-size, size, size), Vector3(-size, size, -size)],
		# Vertical edges
		[Vector3(-size, -size, -size), Vector3(-size, size, -size)],
		[Vector3(size, -size, -size), Vector3(size, size, -size)],
		[Vector3(size, -size, size), Vector3(size, size, size)],
		[Vector3(-size, -size, size), Vector3(-size, size, size)],
	]
	for edge in edges:
		var seg: MeshInstance3D = MeshInstance3D.new()
		var dist: float = (edge[0] as Vector3).distance_to(edge[1] as Vector3)
		var em: BoxMesh = BoxMesh.new()
		em.size = Vector3(0.03, dist, 0.03)
		seg.mesh = em
		var mid: Vector3 = ((edge[0] as Vector3) + (edge[1] as Vector3)) * 0.5
		seg.position = mid
		var dir: Vector3 = ((edge[1] as Vector3) - (edge[0] as Vector3)).normalized()
		# Orient the box so its Y axis aligns with edge direction
		var up: Vector3 = Vector3.UP
		if abs(dir.dot(up)) > 0.99:
			seg.rotation = Vector3(0, 0, 0)
		else:
			var right: Vector3 = up.cross(dir).normalized()
			var new_up: Vector3 = dir
			var new_right: Vector3 = right
			var new_fwd: Vector3 = new_up.cross(new_right)
			var basis: Basis = Basis(new_right, new_up, new_fwd)
			seg.basis = basis
		seg.material_override = wire_mat
		wire_pivot.add_child(seg)
	# Slow rotation
	var spin: Tween = create_tween().set_loops()
	spin.tween_property(wire_pivot, "rotation:y", TAU, 6.0)
	# WANTED label at top
	var wanted: Label3D = Label3D.new()
	wanted.text = "WANTED"
	wanted.position = Vector3(0, 2.85, 0.06)
	wanted.modulate = Color(1.0, 0.30, 0.30)
	wanted.outline_modulate = Color(0, 0, 0, 0.85)
	wanted.outline_size = 5
	wanted.font_size = 22
	wanted.no_depth_test = true
	billboard.add_child(wanted)
	# REWARD subtitle
	var reward: Label3D = Label3D.new()
	reward.text = "REWARD: 500"
	reward.position = Vector3(0, 0.95, 0.06)
	reward.modulate = Color(1.0, 0.85, 0.30)
	reward.outline_modulate = Color(0, 0, 0, 0.85)
	reward.outline_size = 4
	reward.font_size = 14
	reward.no_depth_test = true
	billboard.add_child(reward)
	# Collision around stand
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(0.30, 2.7, 0.30)
	cs.shape = cb
	cs.position = Vector3(0, 1.35, 0)
	sb.add_child(cs)
	billboard.add_child(sb)


static func _build_d2_caged_bugs(geom: Node) -> void:
	## Epic-2 T42: a stack of 3 wireframe cages on a table, each holding
	## a captured glitchbug specimen of a different color (green/orange/violet).
	var cage_root: Node3D = Node3D.new()
	cage_root.name = "D2CagedBugs"
	cage_root.position = D2_CENTER + Vector3(-15, 0, -2)
	geom.add_child(cage_root)
	# Table
	var table_mat: StandardMaterial3D = StandardMaterial3D.new()
	table_mat.albedo_color = Color(0.18, 0.16, 0.12)
	table_mat.metallic = 0.30
	table_mat.roughness = 0.65
	var table: MeshInstance3D = MeshInstance3D.new()
	var tmesh: BoxMesh = BoxMesh.new()
	tmesh.size = Vector3(1.20, 0.85, 0.85)
	table.mesh = tmesh
	table.position = Vector3(0, 0.42, 0)
	table.material_override = table_mat
	cage_root.add_child(table)
	# Helper inline function — 1 cage at given position with given color bug
	var bug_specs: Array = [
		[Vector3(-0.40, 1.10, 0), Color(0.40, 1.0, 0.40), Color(0.40, 1.0, 0.40)],
		[Vector3(0.40, 1.10, 0), Color(1.0, 0.55, 0.20), Color(1.0, 0.55, 0.20)],
		[Vector3(0.0, 1.65, 0), Color(0.85, 0.40, 1.0), Color(0.85, 0.40, 1.0)],
	]
	for spec in bug_specs:
		var pos: Vector3 = spec[0]
		var bar_color: Color = spec[1]
		var bug_color: Color = spec[2]
		# Cage cube wireframe — 12 edges
		var bar_mat: StandardMaterial3D = StandardMaterial3D.new()
		bar_mat.albedo_color = bar_color
		bar_mat.emission_enabled = true
		bar_mat.emission = bar_color
		bar_mat.emission_energy_multiplier = 1.8
		bar_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		var s: float = 0.30
		# 4 vertical
		for ox in [-s, s]:
			for oz in [-s, s]:
				var bar: MeshInstance3D = MeshInstance3D.new()
				var bm: CylinderMesh = CylinderMesh.new()
				bm.top_radius = 0.018
				bm.bottom_radius = 0.018
				bm.height = s * 2
				bar.mesh = bm
				bar.position = pos + Vector3(ox, 0, oz)
				bar.material_override = bar_mat
				cage_root.add_child(bar)
		# 8 horizontal (top + bottom rectangles)
		var horizontals: Array = [
			[Vector3(0, -s, -s), Vector3(s * 2, 0.04, 0.04)],
			[Vector3(0, -s, s), Vector3(s * 2, 0.04, 0.04)],
			[Vector3(-s, -s, 0), Vector3(0.04, 0.04, s * 2)],
			[Vector3(s, -s, 0), Vector3(0.04, 0.04, s * 2)],
			[Vector3(0, s, -s), Vector3(s * 2, 0.04, 0.04)],
			[Vector3(0, s, s), Vector3(s * 2, 0.04, 0.04)],
			[Vector3(-s, s, 0), Vector3(0.04, 0.04, s * 2)],
			[Vector3(s, s, 0), Vector3(0.04, 0.04, s * 2)],
		]
		for h in horizontals:
			var hbar: MeshInstance3D = MeshInstance3D.new()
			var hbm: BoxMesh = BoxMesh.new()
			hbm.size = h[1]
			hbar.mesh = hbm
			hbar.position = pos + (h[0] as Vector3)
			hbar.material_override = bar_mat
			cage_root.add_child(hbar)
		# Bug inside — small sphere
		var bug: MeshInstance3D = MeshInstance3D.new()
		var bgm: SphereMesh = SphereMesh.new()
		bgm.radius = 0.14
		bgm.height = 0.28
		bug.mesh = bgm
		bug.position = pos
		var bgmat: StandardMaterial3D = StandardMaterial3D.new()
		bgmat.albedo_color = bug_color
		bgmat.emission_enabled = true
		bgmat.emission = bug_color
		bgmat.emission_energy_multiplier = 1.8
		bgmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		bug.material_override = bgmat
		cage_root.add_child(bug)
		# Bug bounces inside
		var bounce: Tween = create_tween().set_loops()
		bounce.tween_property(bug, "position", pos + Vector3(0.10, 0.08, 0), 0.4).set_ease(Tween.EASE_IN_OUT)
		bounce.tween_property(bug, "position", pos + Vector3(-0.10, -0.08, 0), 0.4).set_ease(Tween.EASE_IN_OUT)
		bounce.tween_property(bug, "position", pos + Vector3(0, 0, 0.10), 0.4).set_ease(Tween.EASE_IN_OUT)
	# Sign
	var label: Label3D = Label3D.new()
	label.text = "SPECIMENS"
	label.position = Vector3(0, 2.20, 0)
	label.modulate = Color(0.85, 0.95, 0.55)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 16
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	cage_root.add_child(label)
	# Collision around table
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(1.20, 1.85, 0.85)
	cs.shape = cb
	cs.position = Vector3(0, 0.92, 0)
	sb.add_child(cs)
	cage_root.add_child(sb)


static func _build_d2_arc_generator(geom: Node) -> void:
	## Epic-2 T43: an industrial arc generator — 2 metal coil pillars with
	## a sparking electrical arc traveling between them, mounted on a base.
	var gen: Node3D = Node3D.new()
	gen.name = "D2ArcGenerator"
	gen.position = D2_CENTER + Vector3(-18, 0, -10)
	geom.add_child(gen)
	# Base platform
	var dark_mat: StandardMaterial3D = StandardMaterial3D.new()
	dark_mat.albedo_color = Color(0.10, 0.13, 0.16)
	dark_mat.metallic = 0.85
	dark_mat.roughness = 0.30
	var base: MeshInstance3D = MeshInstance3D.new()
	var bmesh: BoxMesh = BoxMesh.new()
	bmesh.size = Vector3(2.40, 0.40, 1.40)
	base.mesh = bmesh
	base.position = Vector3(0, 0.20, 0)
	base.material_override = dark_mat
	gen.add_child(base)
	# 2 coil pillars
	var coil_mat: StandardMaterial3D = StandardMaterial3D.new()
	coil_mat.albedo_color = Color(0.55, 0.30, 0.10)
	coil_mat.metallic = 0.85
	coil_mat.roughness = 0.30
	for sx: float in [-0.85, 0.85]:
		var pillar: MeshInstance3D = MeshInstance3D.new()
		var pmesh: CylinderMesh = CylinderMesh.new()
		pmesh.top_radius = 0.20
		pmesh.bottom_radius = 0.30
		pmesh.height = 1.85
		pillar.mesh = pmesh
		pillar.position = Vector3(sx, 1.30, 0)
		pillar.material_override = coil_mat
		gen.add_child(pillar)
		# Top sphere terminal
		var term: MeshInstance3D = MeshInstance3D.new()
		var tmesh: SphereMesh = SphereMesh.new()
		tmesh.radius = 0.30
		tmesh.height = 0.60
		term.mesh = tmesh
		term.position = Vector3(sx, 2.30, 0)
		var tmat: StandardMaterial3D = StandardMaterial3D.new()
		tmat.albedo_color = Color(0.85, 0.85, 0.95)
		tmat.metallic = 0.85
		tmat.roughness = 0.20
		tmat.emission_enabled = true
		tmat.emission = Color(0.55, 0.95, 1.0)
		tmat.emission_energy_multiplier = 1.4
		term.material_override = tmat
		gen.add_child(term)
	# Arc — 5 thin emissive bars between the terminals at random angles
	var arc_mat: StandardMaterial3D = StandardMaterial3D.new()
	arc_mat.albedo_color = Color(0.85, 0.95, 1.0)
	arc_mat.emission_enabled = true
	arc_mat.emission = Color(0.95, 0.95, 1.0)
	arc_mat.emission_energy_multiplier = 3.6
	arc_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for i in 5:
		var seg: MeshInstance3D = MeshInstance3D.new()
		var sm: BoxMesh = BoxMesh.new()
		sm.size = Vector3(0.36, 0.05, 0.05)
		seg.mesh = sm
		seg.position = Vector3(-0.65 + i * 0.34, 2.30 + randf_range(-0.15, 0.15), 0)
		seg.rotation = Vector3(0, 0, deg_to_rad(randf_range(-25, 25)))
		seg.material_override = arc_mat
		gen.add_child(seg)
		# Flicker
		var flicker: Tween = create_tween().set_loops()
		flicker.tween_property(seg, "visible", false, 0.0)
		flicker.tween_interval(0.06 + randf() * 0.10)
		flicker.tween_property(seg, "visible", true, 0.0)
		flicker.tween_interval(0.04 + randf() * 0.10)
	# Collision around base
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(2.40, 2.20, 1.40)
	cs.shape = cb
	cs.position = Vector3(0, 1.10, 0)
	sb.add_child(cs)
	gen.add_child(sb)


static func _build_d2_hover_platform(geom: Node) -> void:
	## Epic-2 T44: a small floating hover platform that bobs in place.
	## Hex-shaped disc with cyan glow underneath, slowly rotating.
	var plat: Node3D = Node3D.new()
	plat.name = "D2HoverPlatform"
	plat.position = D2_CENTER + Vector3(4, 1.6, -16)
	geom.add_child(plat)
	# Hex disc
	var disc_mat: StandardMaterial3D = StandardMaterial3D.new()
	disc_mat.albedo_color = Color(0.20, 0.22, 0.28)
	disc_mat.metallic = 0.85
	disc_mat.roughness = 0.30
	var disc: MeshInstance3D = MeshInstance3D.new()
	var dmesh: PrismMesh = PrismMesh.new()
	dmesh.size = Vector3(1.40, 0.20, 1.40)
	disc.mesh = dmesh
	disc.material_override = disc_mat
	plat.add_child(disc)
	# Cyan glow underneath
	var glow_mat: StandardMaterial3D = StandardMaterial3D.new()
	glow_mat.albedo_color = Color(0.30, 0.85, 1.0, 0.55)
	glow_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	glow_mat.emission_enabled = true
	glow_mat.emission = Color(0.55, 0.95, 1.0)
	glow_mat.emission_energy_multiplier = 1.8
	glow_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var glow: MeshInstance3D = MeshInstance3D.new()
	var gmesh: CylinderMesh = CylinderMesh.new()
	gmesh.top_radius = 0.95
	gmesh.bottom_radius = 0.95
	gmesh.height = 0.06
	glow.mesh = gmesh
	glow.position = Vector3(0, -0.20, 0)
	glow.material_override = glow_mat
	plat.add_child(glow)
	# Edge emissive trim
	var trim_mat: StandardMaterial3D = StandardMaterial3D.new()
	trim_mat.albedo_color = Color(0.55, 0.95, 1.0)
	trim_mat.emission_enabled = true
	trim_mat.emission = Color(0.55, 0.95, 1.0)
	trim_mat.emission_energy_multiplier = 1.8
	trim_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for i in 6:
		var t: float = float(i) / 6.0
		var angle: float = t * TAU
		var trim: MeshInstance3D = MeshInstance3D.new()
		var tmesh: BoxMesh = BoxMesh.new()
		tmesh.size = Vector3(0.30, 0.04, 0.04)
		trim.mesh = tmesh
		trim.position = Vector3(cos(angle) * 0.65, 0.10, sin(angle) * 0.65)
		trim.rotation = Vector3(0, -angle, 0)
		trim.material_override = trim_mat
		plat.add_child(trim)
	# Bob in place
	var origin: Vector3 = D2_CENTER + Vector3(4, 1.6, -16)
	var bob: Tween = create_tween().set_loops()
	bob.tween_property(plat, "position:y", 2.0, 1.4).set_ease(Tween.EASE_IN_OUT)
	bob.tween_property(plat, "position:y", 1.6, 1.4).set_ease(Tween.EASE_IN_OUT)
	# Slow rotation
	var spin: Tween = create_tween().set_loops()
	spin.tween_property(plat, "rotation:y", TAU, 8.0)
	# Collision
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(1.4, 0.30, 1.4)
	cs.shape = cb
	sb.add_child(cs)
	plat.add_child(sb)


static func _build_d2_arms_dealer_npc(town: Node) -> void:
	## Epic-2 T45: arms dealer NPC standing behind a small table with 3
	## displayed weapons (3 colored vertical bars). Heavy armor + a wide
	## metal shoulder pad.
	var slots: Node3D = town.get_node_or_null("%NPCSlots") as Node3D
	if slots == null:
		return
	var dealer: Node3D = Node3D.new()
	dealer.name = "D2ArmsDealer"
	dealer.position = D2_CENTER + Vector3(15, 0, -6)
	slots.add_child(dealer)
	# Display table in front of the dealer
	var table_mat: StandardMaterial3D = StandardMaterial3D.new()
	table_mat.albedo_color = Color(0.18, 0.16, 0.12)
	table_mat.metallic = 0.40
	var table: MeshInstance3D = MeshInstance3D.new()
	var tmesh: BoxMesh = BoxMesh.new()
	tmesh.size = Vector3(1.40, 0.85, 0.55)
	table.mesh = tmesh
	table.position = Vector3(0, 0.42, 0.65)
	table.material_override = table_mat
	dealer.add_child(table)
	# 3 displayed weapons standing on the table
	var weapon_specs: Array = [
		[-0.45, Color(0.55, 0.95, 1.0)],
		[0.0, Color(1.0, 0.40, 0.20)],
		[0.45, Color(0.85, 0.40, 1.0)],
	]
	for spec in weapon_specs:
		var weapon: MeshInstance3D = MeshInstance3D.new()
		var wmesh: BoxMesh = BoxMesh.new()
		wmesh.size = Vector3(0.05, 0.85, 0.04)
		weapon.mesh = wmesh
		weapon.position = Vector3(spec[0], 1.30, 0.65)
		var wmat: StandardMaterial3D = StandardMaterial3D.new()
		var c: Color = spec[1]
		wmat.albedo_color = c
		wmat.emission_enabled = true
		wmat.emission = c
		wmat.emission_energy_multiplier = 1.8
		wmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		weapon.material_override = wmat
		dealer.add_child(weapon)
	# Body capsule
	var armor_mat: StandardMaterial3D = StandardMaterial3D.new()
	armor_mat.albedo_color = Color(0.20, 0.20, 0.24)
	armor_mat.metallic = 0.65
	armor_mat.roughness = 0.40
	var body: MeshInstance3D = MeshInstance3D.new()
	var bmesh: CapsuleMesh = CapsuleMesh.new()
	bmesh.radius = 0.45
	bmesh.height = 1.30
	body.mesh = bmesh
	body.position = Vector3(0, 0.70, 0)
	body.material_override = armor_mat
	dealer.add_child(body)
	# Wide metal shoulder pad (box on top of capsule)
	var pad: MeshInstance3D = MeshInstance3D.new()
	var pmesh: BoxMesh = BoxMesh.new()
	pmesh.size = Vector3(1.20, 0.20, 0.55)
	pad.mesh = pmesh
	pad.position = Vector3(0, 1.30, 0)
	pad.material_override = armor_mat
	dealer.add_child(pad)
	# Helmet
	var helmet: MeshInstance3D = MeshInstance3D.new()
	var hmesh: BoxMesh = BoxMesh.new()
	hmesh.size = Vector3(0.55, 0.50, 0.55)
	helmet.mesh = hmesh
	helmet.position = Vector3(0, 1.70, 0)
	var hmat: StandardMaterial3D = StandardMaterial3D.new()
	hmat.albedo_color = Color(0.08, 0.08, 0.10)
	hmat.metallic = 0.85
	hmat.roughness = 0.30
	helmet.material_override = hmat
	dealer.add_child(helmet)
	# 1 amber visor stripe
	var visor: MeshInstance3D = MeshInstance3D.new()
	var vmesh: BoxMesh = BoxMesh.new()
	vmesh.size = Vector3(0.55, 0.10, 0.04)
	visor.mesh = vmesh
	visor.position = Vector3(0, 1.72, 0.30)
	var vmat: StandardMaterial3D = StandardMaterial3D.new()
	vmat.albedo_color = Color(1.0, 0.65, 0.20)
	vmat.emission_enabled = true
	vmat.emission = Color(1.0, 0.75, 0.25)
	vmat.emission_energy_multiplier = 2.6
	vmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	visor.material_override = vmat
	dealer.add_child(visor)
	# Name billboard
	var label: Label3D = Label3D.new()
	label.text = "Arms Dealer"
	label.position = Vector3(0, 2.20, 0)
	label.modulate = Color(1.0, 0.65, 0.30)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 18
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	dealer.add_child(label)


static func _build_d2_cracked_road(geom: Node) -> void:
	## Epic-2 T46: 14 cracked broken stone road tiles forming a winding path
	## from the entrance gate (x=72) east to the trial pit area. Each tile
	## has a slight random offset/rotation to look weathered.
	var road: Node3D = Node3D.new()
	road.name = "D2CrackedRoad"
	geom.add_child(road)
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.20, 0.16, 0.12)
	stone_mat.metallic = 0.30
	stone_mat.roughness = 0.65
	stone_mat.emission_enabled = true
	stone_mat.emission = Color(1.0, 0.55, 0.20)
	stone_mat.emission_energy_multiplier = 0.35
	for i in 14:
		var tile: MeshInstance3D = MeshInstance3D.new()
		tile.name = "RoadTile_%d" % i
		var tmesh: BoxMesh = BoxMesh.new()
		tmesh.size = Vector3(2.0 + randf_range(-0.20, 0.20), 0.10, 2.0 + randf_range(-0.20, 0.20))
		tile.mesh = tmesh
		# S-curve from entrance toward trial pit
		var t: float = float(i) / 14.0
		var x: float = 72.0 + i * 2.4
		var z: float = sin(t * 4.0) * 1.6
		tile.position = Vector3(x, 0.05, z)
		tile.rotation = Vector3(0, deg_to_rad(randf_range(-12, 12)), 0)
		tile.material_override = stone_mat
		road.add_child(tile)
		# Random emissive crack across the tile
		if i % 3 == 0:
			var crack: MeshInstance3D = MeshInstance3D.new()
			var cmesh: BoxMesh = BoxMesh.new()
			cmesh.size = Vector3(1.6, 0.04, 0.06)
			crack.mesh = cmesh
			crack.position = tile.position + Vector3(0, 0.06, 0)
			crack.rotation = Vector3(0, deg_to_rad(randf_range(-45, 45)), 0)
			var cmat: StandardMaterial3D = StandardMaterial3D.new()
			cmat.albedo_color = Color(1.0, 0.40, 0.20)
			cmat.emission_enabled = true
			cmat.emission = Color(1.0, 0.55, 0.20)
			cmat.emission_energy_multiplier = 1.6
			cmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
			crack.material_override = cmat
			road.add_child(crack)


static func _build_d2_med_tent(geom: Node) -> void:
	## Epic-2 T47: a small first-aid med tent. White cloth canopy on 4 poles
	## with a glowing red cross on top + a small wooden cot inside.
	var tent: Node3D = Node3D.new()
	tent.name = "D2MedTent"
	tent.position = D2_CENTER + Vector3(-8, 0, 14)
	geom.add_child(tent)
	var post_mat: StandardMaterial3D = StandardMaterial3D.new()
	post_mat.albedo_color = Color(0.18, 0.16, 0.14)
	post_mat.metallic = 0.30
	for ox: float in [-1.2, 1.2]:
		for oz: float in [-1.0, 1.0]:
			var post: MeshInstance3D = MeshInstance3D.new()
			var pmesh: CylinderMesh = CylinderMesh.new()
			pmesh.top_radius = 0.06
			pmesh.bottom_radius = 0.08
			pmesh.height = 2.4
			post.mesh = pmesh
			post.position = Vector3(ox, 1.20, oz)
			post.material_override = post_mat
			tent.add_child(post)
	# White canopy roof — slightly angled prism
	var canopy_mat: StandardMaterial3D = StandardMaterial3D.new()
	canopy_mat.albedo_color = Color(0.85, 0.85, 0.92)
	canopy_mat.emission_enabled = true
	canopy_mat.emission = Color(0.95, 0.95, 1.0)
	canopy_mat.emission_energy_multiplier = 0.30
	canopy_mat.metallic = 0.10
	canopy_mat.roughness = 0.65
	var roof: MeshInstance3D = MeshInstance3D.new()
	var rmesh: PrismMesh = PrismMesh.new()
	rmesh.size = Vector3(2.8, 0.85, 2.4)
	roof.mesh = rmesh
	roof.position = Vector3(0, 2.85, 0)
	roof.material_override = canopy_mat
	tent.add_child(roof)
	# Red cross on top of roof
	var cross_mat: StandardMaterial3D = StandardMaterial3D.new()
	cross_mat.albedo_color = Color(1.0, 0.20, 0.20)
	cross_mat.emission_enabled = true
	cross_mat.emission = Color(1.0, 0.30, 0.30)
	cross_mat.emission_energy_multiplier = 1.8
	cross_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	# Vertical bar
	var v_bar: MeshInstance3D = MeshInstance3D.new()
	var vm: BoxMesh = BoxMesh.new()
	vm.size = Vector3(0.20, 0.85, 0.10)
	v_bar.mesh = vm
	v_bar.position = Vector3(0, 3.55, 0)
	v_bar.material_override = cross_mat
	tent.add_child(v_bar)
	# Horizontal bar
	var h_bar: MeshInstance3D = MeshInstance3D.new()
	var hm: BoxMesh = BoxMesh.new()
	hm.size = Vector3(0.65, 0.20, 0.10)
	h_bar.mesh = hm
	h_bar.position = Vector3(0, 3.55, 0)
	h_bar.material_override = cross_mat
	tent.add_child(h_bar)
	# Cot inside (a low box with a pillow)
	var cot_mat: StandardMaterial3D = StandardMaterial3D.new()
	cot_mat.albedo_color = Color(0.55, 0.50, 0.40)
	cot_mat.metallic = 0.10
	cot_mat.roughness = 0.75
	var cot: MeshInstance3D = MeshInstance3D.new()
	var cot_mesh: BoxMesh = BoxMesh.new()
	cot_mesh.size = Vector3(1.85, 0.18, 0.65)
	cot.mesh = cot_mesh
	cot.position = Vector3(0, 0.30, 0)
	cot.material_override = cot_mat
	tent.add_child(cot)
	# Pillow (smaller box)
	var pillow: MeshInstance3D = MeshInstance3D.new()
	var pmesh2: BoxMesh = BoxMesh.new()
	pmesh2.size = Vector3(0.40, 0.10, 0.30)
	pillow.mesh = pmesh2
	pillow.position = Vector3(-0.65, 0.45, 0)
	var pmat: StandardMaterial3D = StandardMaterial3D.new()
	pmat.albedo_color = Color(0.85, 0.85, 0.85)
	pillow.material_override = pmat
	tent.add_child(pillow)
	# Sign
	var label: Label3D = Label3D.new()
	label.text = "MED TENT"
	label.position = Vector3(0, 4.20, 0)
	label.modulate = Color(1.0, 0.30, 0.30)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 18
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	tent.add_child(label)
	# Collision around the tent
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(2.8, 2.4, 2.4)
	cs.shape = cb
	cs.position = Vector3(0, 1.20, 0)
	sb.add_child(cs)
	tent.add_child(sb)


static func _build_d2_satellite_dish(geom: Node) -> void:
	## Epic-2 T48: a tall rusted satellite dish on a tilted base, slowly
	## rotating to scan the sky. The dish itself is a wide flat disc with
	## a focal element on a short stalk.
	var sat: Node3D = Node3D.new()
	sat.name = "D2SatelliteDish"
	sat.position = D2_CENTER + Vector3(22, 0, 0)
	geom.add_child(sat)
	var rust_mat: StandardMaterial3D = StandardMaterial3D.new()
	rust_mat.albedo_color = Color(0.40, 0.20, 0.10)
	rust_mat.metallic = 0.55
	rust_mat.roughness = 0.65
	# Tilted base mast
	var mast: MeshInstance3D = MeshInstance3D.new()
	var mmesh: CylinderMesh = CylinderMesh.new()
	mmesh.top_radius = 0.18
	mmesh.bottom_radius = 0.30
	mmesh.height = 4.0
	mast.mesh = mmesh
	mast.position = Vector3(0, 2.0, 0)
	mast.rotation = Vector3(deg_to_rad(-12), 0, 0)
	mast.material_override = rust_mat
	sat.add_child(mast)
	# Pivot for the dish (rotates)
	var dish_pivot: Node3D = Node3D.new()
	dish_pivot.position = Vector3(0, 4.0, 0.40)
	sat.add_child(dish_pivot)
	# Dish — wide flat curved disc (use a flat cylinder)
	var dish: MeshInstance3D = MeshInstance3D.new()
	var dmesh: CylinderMesh = CylinderMesh.new()
	dmesh.top_radius = 1.40
	dmesh.bottom_radius = 1.40
	dmesh.height = 0.10
	dish.mesh = dmesh
	dish.rotation = Vector3(deg_to_rad(75), 0, 0)
	dish.material_override = rust_mat
	dish_pivot.add_child(dish)
	# Focal element on a stalk
	var stalk: MeshInstance3D = MeshInstance3D.new()
	var smesh: CylinderMesh = CylinderMesh.new()
	smesh.top_radius = 0.04
	smesh.bottom_radius = 0.04
	smesh.height = 1.0
	stalk.mesh = smesh
	stalk.position = Vector3(0, 0.50, 0.10)
	stalk.rotation = Vector3(deg_to_rad(15), 0, 0)
	stalk.material_override = rust_mat
	dish_pivot.add_child(stalk)
	var focal: MeshInstance3D = MeshInstance3D.new()
	var fmesh: SphereMesh = SphereMesh.new()
	fmesh.radius = 0.18
	fmesh.height = 0.36
	focal.mesh = fmesh
	focal.position = Vector3(0, 1.0, 0.20)
	var focal_mat: StandardMaterial3D = StandardMaterial3D.new()
	focal_mat.albedo_color = Color(0.55, 0.95, 1.0)
	focal_mat.emission_enabled = true
	focal_mat.emission = Color(0.55, 0.95, 1.0)
	focal_mat.emission_energy_multiplier = 2.4
	focal_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	focal.material_override = focal_mat
	dish_pivot.add_child(focal)
	# Slow rotation scanning the sky
	var spin: Tween = create_tween().set_loops()
	spin.tween_property(dish_pivot, "rotation:y", deg_to_rad(80), 6.0).set_ease(Tween.EASE_IN_OUT)
	spin.tween_property(dish_pivot, "rotation:y", deg_to_rad(-80), 6.0).set_ease(Tween.EASE_IN_OUT)
	# Collision around mast
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cap: CapsuleShape3D = CapsuleShape3D.new()
	cap.radius = 0.45
	cap.height = 4.0
	cs.shape = cap
	cs.position = Vector3(0, 2.0, 0)
	sb.add_child(cs)
	sat.add_child(sb)


static func _build_d2_cage_arena(geom: Node) -> void:
	## Epic-2 T49: a small caged fight arena with chain-link walls + a
	## center floor pad. 8 vertical bars + 8 horizontal cross-bars on each
	## of the 4 sides, leaving an entrance gap on the south side.
	var arena: Node3D = Node3D.new()
	arena.name = "D2CageArena"
	arena.position = D2_CENTER + Vector3(8, 0, -3)
	geom.add_child(arena)
	# Floor pad — 5x5 dark disc
	var pad_mat: StandardMaterial3D = StandardMaterial3D.new()
	pad_mat.albedo_color = Color(0.16, 0.10, 0.08)
	pad_mat.metallic = 0.40
	pad_mat.roughness = 0.55
	pad_mat.emission_enabled = true
	pad_mat.emission = Color(1.0, 0.40, 0.20)
	pad_mat.emission_energy_multiplier = 0.40
	var pad: MeshInstance3D = MeshInstance3D.new()
	var pad_mesh: CylinderMesh = CylinderMesh.new()
	pad_mesh.top_radius = 2.5
	pad_mesh.bottom_radius = 2.5
	pad_mesh.height = 0.08
	pad.mesh = pad_mesh
	pad.position = Vector3(0, 0.05, 0)
	pad.material_override = pad_mat
	arena.add_child(pad)
	# Cage bars — 4 sides, 6 verticals each side
	var bar_mat: StandardMaterial3D = StandardMaterial3D.new()
	bar_mat.albedo_color = Color(0.10, 0.10, 0.13)
	bar_mat.metallic = 0.85
	bar_mat.roughness = 0.30
	# 4 walls (north, east, west — south has entrance)
	var wall_specs: Array = [
		[Vector3(0, 0, -3.0), Vector3(0, 0, 0)],  # North wall
		[Vector3(3.0, 0, 0), Vector3(0, deg_to_rad(90), 0)],  # East wall
		[Vector3(-3.0, 0, 0), Vector3(0, deg_to_rad(90), 0)],  # West wall
	]
	for spec in wall_specs:
		var wall: Node3D = Node3D.new()
		wall.position = spec[0]
		wall.rotation = spec[1]
		arena.add_child(wall)
		# 6 vertical bars
		for v in 6:
			var vbar: MeshInstance3D = MeshInstance3D.new()
			var vbm: CylinderMesh = CylinderMesh.new()
			vbm.top_radius = 0.05
			vbm.bottom_radius = 0.05
			vbm.height = 2.4
			vbar.mesh = vbm
			vbar.position = Vector3(-2.5 + v * 1.0, 1.20, 0)
			vbar.material_override = bar_mat
			wall.add_child(vbar)
		# 4 horizontal cross-bars
		for h in 4:
			var hbar: MeshInstance3D = MeshInstance3D.new()
			var hbm: BoxMesh = BoxMesh.new()
			hbm.size = Vector3(5.0, 0.05, 0.05)
			hbar.mesh = hbm
			hbar.position = Vector3(0, 0.30 + h * 0.65, 0)
			hbar.material_override = bar_mat
			wall.add_child(hbar)
	# Top corner posts (4 thick posts framing the cage)
	for ox: float in [-3.0, 3.0]:
		for oz: float in [-3.0, 3.0]:
			var post: MeshInstance3D = MeshInstance3D.new()
			var pmesh: CylinderMesh = CylinderMesh.new()
			pmesh.top_radius = 0.10
			pmesh.bottom_radius = 0.12
			pmesh.height = 2.6
			post.mesh = pmesh
			post.position = Vector3(ox, 1.30, oz)
			post.material_override = bar_mat
			arena.add_child(post)
			# Collision per post
			var sb: StaticBody3D = StaticBody3D.new()
			var cs: CollisionShape3D = CollisionShape3D.new()
			var cap: CapsuleShape3D = CapsuleShape3D.new()
			cap.radius = 0.25
			cap.height = 2.6
			cs.shape = cap
			cs.position = Vector3(ox, 1.30, oz)
			sb.add_child(cs)
			arena.add_child(sb)
	# CAGE FIGHT label above
	var label: Label3D = Label3D.new()
	label.text = "CAGE FIGHT"
	label.position = Vector3(0, 3.0, 0)
	label.modulate = Color(1.0, 0.40, 0.30)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 6
	label.font_size = 22
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	arena.add_child(label)


static func _build_d2_corrupted_titan(geom: Node) -> void:
	## Epic-2 T50: a 2nd mini-boss visual called "Corrupted Titan" — taller
	## than the glitch beast. Humanoid silhouette with hulking shoulders,
	## glitching geometry segments around the body, 2 huge red eyes, slow
	## intimidating pacing tween.
	var titan: Node3D = Node3D.new()
	titan.name = "D2CorruptedTitan"
	titan.position = D2_CENTER + Vector3(20, 0, -16)
	geom.add_child(titan)
	# Body torso — wide block
	var body_mat: StandardMaterial3D = StandardMaterial3D.new()
	body_mat.albedo_color = Color(0.10, 0.05, 0.10)
	body_mat.emission_enabled = true
	body_mat.emission = Color(0.85, 0.20, 0.40)
	body_mat.emission_energy_multiplier = 0.85
	body_mat.metallic = 0.55
	body_mat.roughness = 0.45
	var torso: MeshInstance3D = MeshInstance3D.new()
	var tmesh: BoxMesh = BoxMesh.new()
	tmesh.size = Vector3(2.0, 2.4, 1.40)
	torso.mesh = tmesh
	torso.position = Vector3(0, 2.20, 0)
	torso.material_override = body_mat
	titan.add_child(torso)
	# Hulking shoulder pads (2 wide blocks on top of torso)
	for sx: float in [-1.20, 1.20]:
		var pad: MeshInstance3D = MeshInstance3D.new()
		var pmesh: BoxMesh = BoxMesh.new()
		pmesh.size = Vector3(0.85, 0.55, 1.40)
		pad.mesh = pmesh
		pad.position = Vector3(sx, 3.20, 0)
		pad.material_override = body_mat
		titan.add_child(pad)
	# Head — smaller block
	var head: MeshInstance3D = MeshInstance3D.new()
	var hmesh: BoxMesh = BoxMesh.new()
	hmesh.size = Vector3(1.0, 0.95, 1.0)
	head.mesh = hmesh
	head.position = Vector3(0, 4.0, 0)
	head.material_override = body_mat
	titan.add_child(head)
	# 2 huge red eyes on the head
	var eye_mat: StandardMaterial3D = StandardMaterial3D.new()
	eye_mat.albedo_color = Color(1.0, 0.20, 0.20)
	eye_mat.emission_enabled = true
	eye_mat.emission = Color(1.0, 0.30, 0.30)
	eye_mat.emission_energy_multiplier = 3.4
	eye_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for ex: float in [-0.25, 0.25]:
		var eye: MeshInstance3D = MeshInstance3D.new()
		var em: SphereMesh = SphereMesh.new()
		em.radius = 0.18
		em.height = 0.36
		eye.mesh = em
		eye.position = Vector3(ex, 4.0, 0.55)
		eye.material_override = eye_mat
		titan.add_child(eye)
	# 2 huge legs (wide pillars)
	var leg_mat: StandardMaterial3D = StandardMaterial3D.new()
	leg_mat.albedo_color = Color(0.10, 0.05, 0.08)
	leg_mat.metallic = 0.40
	leg_mat.roughness = 0.55
	leg_mat.emission_enabled = true
	leg_mat.emission = Color(0.85, 0.20, 0.40)
	leg_mat.emission_energy_multiplier = 0.40
	for sx: float in [-0.55, 0.55]:
		var leg: MeshInstance3D = MeshInstance3D.new()
		var lm: BoxMesh = BoxMesh.new()
		lm.size = Vector3(0.65, 1.0, 0.55)
		leg.mesh = lm
		leg.position = Vector3(sx, 0.50, 0)
		leg.material_override = leg_mat
		titan.add_child(leg)
	# Glitching geometry segments — 6 random small boxes orbiting torso
	var glitch_mat: StandardMaterial3D = StandardMaterial3D.new()
	glitch_mat.albedo_color = Color(0.85, 0.20, 0.40, 0.65)
	glitch_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	glitch_mat.emission_enabled = true
	glitch_mat.emission = Color(1.0, 0.30, 0.55)
	glitch_mat.emission_energy_multiplier = 2.0
	glitch_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for i in 6:
		var glitch: MeshInstance3D = MeshInstance3D.new()
		var gm: BoxMesh = BoxMesh.new()
		gm.size = Vector3(0.30, 0.30, 0.30)
		glitch.mesh = gm
		var angle: float = (float(i) / 6.0) * TAU
		glitch.position = Vector3(cos(angle) * 1.50, 2.20 + (i - 3) * 0.30, sin(angle) * 1.50)
		glitch.material_override = glitch_mat
		titan.add_child(glitch)
		# Flicker visibility
		var fl: Tween = create_tween().set_loops()
		fl.tween_interval(0.5 + i * 0.1)
		fl.tween_property(glitch, "visible", false, 0.0)
		fl.tween_interval(0.10)
		fl.tween_property(glitch, "visible", true, 0.0)
		fl.tween_interval(0.4)
	# Slow pacing tween
	var origin: Vector3 = D2_CENTER + Vector3(20, 0, -16)
	var pace: Tween = create_tween().set_loops()
	pace.tween_property(titan, "rotation:y", deg_to_rad(180), 0.6)
	pace.tween_property(titan, "position", origin + Vector3(-6, 0, 0), 10.0)
	pace.tween_property(titan, "rotation:y", 0.0, 0.6)
	pace.tween_property(titan, "position", origin, 10.0)
	# Boss-tier name billboard
	var label: Label3D = Label3D.new()
	label.text = "CORRUPTED TITAN"
	label.position = Vector3(0, 5.20, 0)
	label.modulate = Color(1.0, 0.30, 0.40)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 6
	label.font_size = 24
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	titan.add_child(label)


static func _build_d2_power_substation(geom: Node) -> void:
	## Epic-2 T51: a power substation — large transformer box on a fenced
	## platform with sparking insulators and warning signs.
	var sub: Node3D = Node3D.new()
	sub.name = "D2PowerSubstation"
	sub.position = D2_CENTER + Vector3(-22, 0, 6)
	geom.add_child(sub)
	# Concrete platform
	var plat_mat: StandardMaterial3D = StandardMaterial3D.new()
	plat_mat.albedo_color = Color(0.30, 0.32, 0.38)
	plat_mat.metallic = 0.20
	plat_mat.roughness = 0.65
	var plat: MeshInstance3D = MeshInstance3D.new()
	var pmesh: BoxMesh = BoxMesh.new()
	pmesh.size = Vector3(2.40, 0.30, 2.40)
	plat.mesh = pmesh
	plat.position = Vector3(0, 0.15, 0)
	plat.material_override = plat_mat
	sub.add_child(plat)
	# Transformer box (big rusted box)
	var trans_mat: StandardMaterial3D = StandardMaterial3D.new()
	trans_mat.albedo_color = Color(0.40, 0.30, 0.18)
	trans_mat.metallic = 0.40
	trans_mat.roughness = 0.55
	var trans: MeshInstance3D = MeshInstance3D.new()
	var tmesh: BoxMesh = BoxMesh.new()
	tmesh.size = Vector3(1.60, 1.85, 1.60)
	trans.mesh = tmesh
	trans.position = Vector3(0, 1.225, 0)
	trans.material_override = trans_mat
	sub.add_child(trans)
	# 3 ceramic insulator stacks on top
	var ceramic_mat: StandardMaterial3D = StandardMaterial3D.new()
	ceramic_mat.albedo_color = Color(0.85, 0.80, 0.70)
	ceramic_mat.metallic = 0.20
	ceramic_mat.roughness = 0.45
	for ix: float in [-0.50, 0.0, 0.50]:
		# 3 stacked discs
		for s in 3:
			var disc: MeshInstance3D = MeshInstance3D.new()
			var dmesh: CylinderMesh = CylinderMesh.new()
			dmesh.top_radius = 0.18 - s * 0.02
			dmesh.bottom_radius = 0.20 - s * 0.02
			dmesh.height = 0.18
			disc.mesh = dmesh
			disc.position = Vector3(ix, 2.30 + s * 0.20, 0)
			disc.material_override = ceramic_mat
			sub.add_child(disc)
		# Top spark cap
		var cap: MeshInstance3D = MeshInstance3D.new()
		var cmesh: SphereMesh = SphereMesh.new()
		cmesh.radius = 0.10
		cmesh.height = 0.20
		cap.mesh = cmesh
		cap.position = Vector3(ix, 2.95, 0)
		var cap_mat: StandardMaterial3D = StandardMaterial3D.new()
		cap_mat.albedo_color = Color(0.55, 0.95, 1.0)
		cap_mat.emission_enabled = true
		cap_mat.emission = Color(0.55, 0.95, 1.0)
		cap_mat.emission_energy_multiplier = 2.6
		cap_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		cap.material_override = cap_mat
		sub.add_child(cap)
	# Spark particles from the center insulator
	var sparks: GPUParticles3D = GPUParticles3D.new()
	sparks.amount = 20
	sparks.lifetime = 0.65
	sparks.position = Vector3(0, 3.0, 0)
	var spmat: ParticleProcessMaterial = ParticleProcessMaterial.new()
	spmat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	spmat.emission_sphere_radius = 0.15
	spmat.direction = Vector3(0, 1, 0)
	spmat.spread = 90.0
	spmat.initial_velocity_min = 1.4
	spmat.initial_velocity_max = 2.2
	spmat.gravity = Vector3(0, -3.0, 0)
	spmat.scale_min = 0.04
	spmat.scale_max = 0.10
	spmat.color = Color(0.55, 0.95, 1.0, 1.0)
	sparks.process_material = spmat
	var sm: SphereMesh = SphereMesh.new()
	sm.radius = 0.05
	sm.height = 0.10
	var sm_mat: StandardMaterial3D = StandardMaterial3D.new()
	sm_mat.albedo_color = Color(0.55, 0.95, 1.0)
	sm_mat.emission_enabled = true
	sm_mat.emission = Color(0.55, 0.95, 1.0)
	sm_mat.emission_energy_multiplier = 2.6
	sm_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	sm.material = sm_mat
	sparks.draw_pass_1 = sm
	sub.add_child(sparks)
	# Warning sign on the front of transformer (yellow box with red text)
	var warn: MeshInstance3D = MeshInstance3D.new()
	var wmesh: BoxMesh = BoxMesh.new()
	wmesh.size = Vector3(0.55, 0.40, 0.04)
	warn.mesh = wmesh
	warn.position = Vector3(0, 1.40, 0.82)
	var wmat: StandardMaterial3D = StandardMaterial3D.new()
	wmat.albedo_color = Color(1.0, 0.85, 0.20)
	wmat.emission_enabled = true
	wmat.emission = Color(1.0, 0.95, 0.30)
	wmat.emission_energy_multiplier = 1.4
	wmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	warn.material_override = wmat
	sub.add_child(warn)
	var warn_label: Label3D = Label3D.new()
	warn_label.text = "DANGER\nHIGH V"
	warn_label.position = Vector3(0, 1.40, 0.86)
	warn_label.modulate = Color(0.85, 0.10, 0.10)
	warn_label.outline_size = 0
	warn_label.font_size = 12
	warn_label.no_depth_test = true
	sub.add_child(warn_label)
	# Collision around platform + transformer
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(2.40, 3.30, 2.40)
	cs.shape = cb
	cs.position = Vector3(0, 1.65, 0)
	sb.add_child(cs)
	sub.add_child(sb)


static func _build_d2_corpse_pile(geom: Node) -> void:
	## Epic-2 T52: a small respectful pile of fallen NPC silhouettes — 3
	## crumpled capsule bodies + 2 small Label3Ds with names. Lore element
	## sells "people died fighting here". Pure decoration, no gore.
	var pile: Node3D = Node3D.new()
	pile.name = "D2CorpsePile"
	pile.position = D2_CENTER + Vector3(13, 0, -14)
	geom.add_child(pile)
	var corpse_mat: StandardMaterial3D = StandardMaterial3D.new()
	corpse_mat.albedo_color = Color(0.16, 0.10, 0.06)
	corpse_mat.metallic = 0.10
	corpse_mat.roughness = 0.85
	var corpse_specs: Array = [
		[Vector3(-0.5, 0.18, 0), Vector3(deg_to_rad(85), deg_to_rad(20), 0)],
		[Vector3(0.4, 0.18, 0.3), Vector3(deg_to_rad(85), deg_to_rad(-30), deg_to_rad(15))],
		[Vector3(0.0, 0.18, -0.4), Vector3(deg_to_rad(85), deg_to_rad(60), 0)],
	]
	for spec in corpse_specs:
		var corpse: MeshInstance3D = MeshInstance3D.new()
		var cmesh: CapsuleMesh = CapsuleMesh.new()
		cmesh.radius = 0.32
		cmesh.height = 0.85
		corpse.mesh = cmesh
		corpse.position = spec[0]
		corpse.rotation = spec[1]
		corpse.material_override = corpse_mat
		pile.add_child(corpse)
	# Memorial banner stake
	var stake_mat: StandardMaterial3D = StandardMaterial3D.new()
	stake_mat.albedo_color = Color(0.18, 0.16, 0.14)
	stake_mat.metallic = 0.30
	var stake: MeshInstance3D = MeshInstance3D.new()
	var smesh: CylinderMesh = CylinderMesh.new()
	smesh.top_radius = 0.05
	smesh.bottom_radius = 0.05
	smesh.height = 1.40
	stake.mesh = smesh
	stake.position = Vector3(0, 0.70, 0.85)
	stake.material_override = stake_mat
	pile.add_child(stake)
	# Tiny banner cloth
	var banner: MeshInstance3D = MeshInstance3D.new()
	var bm: BoxMesh = BoxMesh.new()
	bm.size = Vector3(0.50, 0.30, 0.04)
	banner.mesh = bm
	banner.position = Vector3(0.30, 1.20, 0.85)
	var bmat: StandardMaterial3D = StandardMaterial3D.new()
	bmat.albedo_color = Color(0.55, 0.55, 0.65)
	bmat.emission_enabled = true
	bmat.emission = Color(0.65, 0.65, 0.75)
	bmat.emission_energy_multiplier = 0.55
	banner.material_override = bmat
	pile.add_child(banner)
	# Memorial text
	var label: Label3D = Label3D.new()
	label.text = "REMEMBER\nTHE FALLEN"
	label.position = Vector3(0, 1.70, 0.85)
	label.modulate = Color(0.85, 0.85, 0.95)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 4
	label.font_size = 13
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	pile.add_child(label)


static func _build_d2_hover_truck_wreck(geom: Node) -> void:
	## Epic-2 T53: a much larger wrecked hover-truck blocking part of the
	## road. Long boxy body, 4 broken hover engines, cargo bay door open
	## with broken crates spilling out.
	var truck: Node3D = Node3D.new()
	truck.name = "D2HoverTruckWreck"
	truck.position = D2_CENTER + Vector3(8, 0, 4)
	truck.rotation = Vector3(0, deg_to_rad(40), deg_to_rad(-12))
	geom.add_child(truck)
	# Cab
	var cab_mat: StandardMaterial3D = StandardMaterial3D.new()
	cab_mat.albedo_color = Color(0.20, 0.22, 0.28)
	cab_mat.metallic = 0.85
	cab_mat.roughness = 0.40
	var cab: MeshInstance3D = MeshInstance3D.new()
	var cab_mesh: BoxMesh = BoxMesh.new()
	cab_mesh.size = Vector3(1.80, 1.20, 1.40)
	cab.mesh = cab_mesh
	cab.position = Vector3(2.20, 0.85, 0)
	cab.material_override = cab_mat
	truck.add_child(cab)
	# Cargo body — long box
	var cargo: MeshInstance3D = MeshInstance3D.new()
	var crmesh: BoxMesh = BoxMesh.new()
	crmesh.size = Vector3(3.40, 1.85, 1.85)
	cargo.mesh = crmesh
	cargo.position = Vector3(-0.50, 1.20, 0)
	cargo.material_override = cab_mat
	truck.add_child(cargo)
	# Cyan windshield
	var glass: MeshInstance3D = MeshInstance3D.new()
	var gmesh: BoxMesh = BoxMesh.new()
	gmesh.size = Vector3(0.10, 0.55, 1.20)
	glass.mesh = gmesh
	glass.position = Vector3(3.05, 1.20, 0)
	var gmat: StandardMaterial3D = StandardMaterial3D.new()
	gmat.albedo_color = Color(0.20, 0.50, 0.70, 0.55)
	gmat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	gmat.emission_enabled = true
	gmat.emission = Color(0.30, 0.85, 1.0)
	gmat.emission_energy_multiplier = 1.0
	gmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	glass.material_override = gmat
	truck.add_child(glass)
	# 4 hover engine pods underneath
	var engine_mat: StandardMaterial3D = StandardMaterial3D.new()
	engine_mat.albedo_color = Color(0.30, 0.10, 0.06)
	engine_mat.emission_enabled = true
	engine_mat.emission = Color(1.0, 0.40, 0.20)
	engine_mat.emission_energy_multiplier = 0.85
	engine_mat.metallic = 0.55
	for ox: float in [-1.5, 0.0, 1.5]:
		for oz: float in [-0.85, 0.85]:
			var pod: MeshInstance3D = MeshInstance3D.new()
			var pmesh: CylinderMesh = CylinderMesh.new()
			pmesh.top_radius = 0.20
			pmesh.bottom_radius = 0.30
			pmesh.height = 0.40
			pod.mesh = pmesh
			pod.position = Vector3(ox, 0.20, oz)
			pod.material_override = engine_mat
			truck.add_child(pod)
	# Cargo door open at the back — small angled panel
	var door: MeshInstance3D = MeshInstance3D.new()
	var door_mesh: BoxMesh = BoxMesh.new()
	door_mesh.size = Vector3(0.10, 1.85, 1.85)
	door.mesh = door_mesh
	door.position = Vector3(-2.30, 1.20, 0)
	door.rotation = Vector3(0, 0, deg_to_rad(45))
	door.material_override = cab_mat
	truck.add_child(door)
	# 3 spilled crates behind the truck
	var crate_mat: StandardMaterial3D = StandardMaterial3D.new()
	crate_mat.albedo_color = Color(0.30, 0.18, 0.08)
	crate_mat.metallic = 0.10
	crate_mat.roughness = 0.65
	for i in 3:
		var crate: MeshInstance3D = MeshInstance3D.new()
		var cmesh2: BoxMesh = BoxMesh.new()
		cmesh2.size = Vector3(0.55, 0.55, 0.55)
		crate.mesh = cmesh2
		crate.position = Vector3(-3.30 - i * 0.30, 0.30, randf_range(-0.55, 0.55))
		crate.rotation = Vector3(0, deg_to_rad(randf_range(-30, 30)), 0)
		crate.material_override = crate_mat
		truck.add_child(crate)
	# Collision around the cargo + cab
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(5.5, 2.4, 2.0)
	cs.shape = cb
	cs.position = Vector3(0.85, 1.20, 0)
	sb.add_child(cs)
	truck.add_child(sb)


static func _build_d2_faction_wall(geom: Node) -> void:
	## Epic-2 T54: a tall stone faction wall painted with a glowing red
	## faction symbol (X inside a circle). Marks territory of "the
	## Outskirts gang".
	var wall: Node3D = Node3D.new()
	wall.name = "D2FactionWall"
	wall.position = D2_CENTER + Vector3(-22, 0, -2)
	geom.add_child(wall)
	# Wall slab
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.20, 0.16, 0.12)
	stone_mat.metallic = 0.30
	stone_mat.roughness = 0.65
	var slab: MeshInstance3D = MeshInstance3D.new()
	var smesh: BoxMesh = BoxMesh.new()
	smesh.size = Vector3(0.30, 4.0, 4.5)
	slab.mesh = smesh
	slab.position = Vector3(0, 2.0, 0)
	slab.material_override = stone_mat
	wall.add_child(slab)
	# Painted symbol — circle made of small box segments
	var sym_mat: StandardMaterial3D = StandardMaterial3D.new()
	sym_mat.albedo_color = Color(1.0, 0.20, 0.20)
	sym_mat.emission_enabled = true
	sym_mat.emission = Color(1.0, 0.30, 0.30)
	sym_mat.emission_energy_multiplier = 1.8
	sym_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	# Circle of 16 small boxes
	for i in 16:
		var angle: float = (float(i) / 16.0) * TAU
		var seg: MeshInstance3D = MeshInstance3D.new()
		var sgm: BoxMesh = BoxMesh.new()
		sgm.size = Vector3(0.06, 0.20, 0.20)
		seg.mesh = sgm
		seg.position = Vector3(0.16, 2.0 + cos(angle) * 1.20, sin(angle) * 1.20)
		seg.material_override = sym_mat
		wall.add_child(seg)
	# X across the circle (4 boxes forming 2 diagonal lines)
	for i in 2:
		var rot_z: float = deg_to_rad(45 if i == 0 else -45)
		var x_bar: MeshInstance3D = MeshInstance3D.new()
		var xm: BoxMesh = BoxMesh.new()
		xm.size = Vector3(0.06, 0.20, 2.40)
		x_bar.mesh = xm
		x_bar.position = Vector3(0.16, 2.0, 0)
		x_bar.rotation = Vector3(rot_z, 0, 0)
		x_bar.material_override = sym_mat
		wall.add_child(x_bar)
	# Faction name graffiti below
	var label: Label3D = Label3D.new()
	label.text = "OUTSKIRTS"
	label.position = Vector3(0.18, 0.55, 0)
	label.rotation = Vector3(0, deg_to_rad(90), 0)
	label.modulate = Color(1.0, 0.30, 0.30)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 26
	label.no_depth_test = true
	wall.add_child(label)
	# Collision
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(0.30, 4.0, 4.5)
	cs.shape = cb
	cs.position = Vector3(0, 2.0, 0)
	sb.add_child(cs)
	wall.add_child(sb)


static func _build_d2_hacker_npc(town: Node) -> void:
	## Epic-2 T55: a hacker NPC sitting cross-legged with 3 small floating
	## holographic screens around them. Hooded body, glowing green visor,
	## screens cycle through "code".
	var slots: Node3D = town.get_node_or_null("%NPCSlots") as Node3D
	if slots == null:
		return
	var hacker: Node3D = Node3D.new()
	hacker.name = "D2Hacker"
	hacker.position = D2_CENTER + Vector3(-6, 0, 8)
	slots.add_child(hacker)
	# Body — short capsule (sitting)
	var bmat: StandardMaterial3D = StandardMaterial3D.new()
	bmat.albedo_color = Color(0.10, 0.14, 0.10)
	bmat.metallic = 0.20
	bmat.roughness = 0.65
	var body: MeshInstance3D = MeshInstance3D.new()
	var bmesh: CapsuleMesh = CapsuleMesh.new()
	bmesh.radius = 0.40
	bmesh.height = 0.85
	body.mesh = bmesh
	body.position = Vector3(0, 0.45, 0)
	body.material_override = bmat
	hacker.add_child(body)
	# Hood
	var hood: MeshInstance3D = MeshInstance3D.new()
	var hmesh: SphereMesh = SphereMesh.new()
	hmesh.radius = 0.40
	hmesh.height = 0.55
	hood.mesh = hmesh
	hood.position = Vector3(0, 1.0, 0)
	hood.material_override = bmat
	hacker.add_child(hood)
	# Wide green visor strip
	var visor: MeshInstance3D = MeshInstance3D.new()
	var vmesh: BoxMesh = BoxMesh.new()
	vmesh.size = Vector3(0.50, 0.10, 0.04)
	visor.mesh = vmesh
	visor.position = Vector3(0, 0.95, 0.34)
	var vmat: StandardMaterial3D = StandardMaterial3D.new()
	vmat.albedo_color = Color(0.40, 1.0, 0.55)
	vmat.emission_enabled = true
	vmat.emission = Color(0.55, 1.0, 0.55)
	vmat.emission_energy_multiplier = 2.6
	vmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	visor.material_override = vmat
	hacker.add_child(visor)
	# 3 floating screens around the hacker
	var screen_mat: StandardMaterial3D = StandardMaterial3D.new()
	screen_mat.albedo_color = Color(0.04, 0.10, 0.06, 0.85)
	screen_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	screen_mat.emission_enabled = true
	screen_mat.emission = Color(0.40, 1.0, 0.55)
	screen_mat.emission_energy_multiplier = 1.0
	screen_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var screen_specs: Array = [
		[Vector3(-0.85, 1.40, 0.55), "0xFF\nMOV\nLDR"],
		[Vector3(0.85, 1.40, 0.55), "01010\nERROR\n404"],
		[Vector3(0.0, 1.85, 0.65), "ROOT\nGRANT"],
	]
	for spec in screen_specs:
		var screen: MeshInstance3D = MeshInstance3D.new()
		var sgm: BoxMesh = BoxMesh.new()
		sgm.size = Vector3(0.65, 0.45, 0.04)
		screen.mesh = sgm
		screen.position = spec[0]
		screen.material_override = screen_mat
		hacker.add_child(screen)
		# Code text on the screen
		var code: Label3D = Label3D.new()
		code.text = spec[1]
		code.position = (spec[0] as Vector3) + Vector3(0, 0, 0.04)
		code.modulate = Color(0.55, 1.0, 0.55)
		code.outline_size = 0
		code.font_size = 12
		code.no_depth_test = true
		code.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		hacker.add_child(code)
		# Bob screen
		var bob: Tween = create_tween().set_loops()
		var origin_y: float = (spec[0] as Vector3).y
		bob.tween_property(screen, "position:y", origin_y + 0.10, 1.4).set_ease(Tween.EASE_IN_OUT)
		bob.tween_property(screen, "position:y", origin_y, 1.4).set_ease(Tween.EASE_IN_OUT)
	# Name billboard
	var label: Label3D = Label3D.new()
	label.text = "Hacker"
	label.position = Vector3(0, 1.55, 0)
	label.modulate = Color(0.55, 1.0, 0.55)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 18
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	hacker.add_child(label)


static func _build_d2_sniper_npc(town: Node) -> void:
	## Epic-2 T56: a sniper NPC perched on top of the watchtower roof at
	## (D2_CENTER + 20, 0, -16). Crouched silhouette with a long rifle
	## scope visible, cyan laser sight projecting downward into the plaza.
	var slots: Node3D = town.get_node_or_null("%NPCSlots") as Node3D
	if slots == null:
		return
	var sniper: Node3D = Node3D.new()
	sniper.name = "D2Sniper"
	sniper.position = D2_CENTER + Vector3(20, 9.45, -16)
	slots.add_child(sniper)
	# Crouched body
	var bmat: StandardMaterial3D = StandardMaterial3D.new()
	bmat.albedo_color = Color(0.10, 0.13, 0.16)
	bmat.metallic = 0.30
	bmat.roughness = 0.55
	bmat.emission_enabled = true
	bmat.emission = Color(0.30, 0.30, 0.40)
	bmat.emission_energy_multiplier = 0.30
	var body: MeshInstance3D = MeshInstance3D.new()
	var bmesh: CapsuleMesh = CapsuleMesh.new()
	bmesh.radius = 0.30
	bmesh.height = 0.55
	body.mesh = bmesh
	body.position = Vector3(0, 0.30, 0)
	body.rotation = Vector3(deg_to_rad(20), 0, 0)
	body.material_override = bmat
	sniper.add_child(body)
	# Helmet
	var helmet: MeshInstance3D = MeshInstance3D.new()
	var hmesh: BoxMesh = BoxMesh.new()
	hmesh.size = Vector3(0.40, 0.30, 0.40)
	helmet.mesh = hmesh
	helmet.position = Vector3(0, 0.65, 0.10)
	helmet.material_override = bmat
	sniper.add_child(helmet)
	# Long rifle held in front
	var rifle_mat: StandardMaterial3D = StandardMaterial3D.new()
	rifle_mat.albedo_color = Color(0.05, 0.05, 0.10)
	rifle_mat.metallic = 0.85
	rifle_mat.roughness = 0.30
	var rifle: MeshInstance3D = MeshInstance3D.new()
	var rmesh: BoxMesh = BoxMesh.new()
	rmesh.size = Vector3(0.10, 0.10, 1.85)
	rifle.mesh = rmesh
	rifle.position = Vector3(0.20, 0.50, 0.50)
	rifle.rotation = Vector3(deg_to_rad(-15), deg_to_rad(10), 0)
	rifle.material_override = rifle_mat
	sniper.add_child(rifle)
	# Scope on top of rifle
	var scope: MeshInstance3D = MeshInstance3D.new()
	var sc_mesh: CylinderMesh = CylinderMesh.new()
	sc_mesh.top_radius = 0.06
	sc_mesh.bottom_radius = 0.06
	sc_mesh.height = 0.30
	scope.mesh = sc_mesh
	scope.position = Vector3(0.20, 0.62, 0.50)
	scope.rotation = Vector3(deg_to_rad(75), deg_to_rad(10), 0)
	scope.material_override = rifle_mat
	sniper.add_child(scope)
	# Cyan laser sight — long thin emissive line projecting forward + down
	var laser: MeshInstance3D = MeshInstance3D.new()
	var lmesh: BoxMesh = BoxMesh.new()
	lmesh.size = Vector3(0.02, 0.02, 14.0)
	laser.mesh = lmesh
	laser.position = Vector3(0.20, 0.30, -6.5)
	laser.rotation = Vector3(deg_to_rad(-25), deg_to_rad(15), 0)
	var lmat: StandardMaterial3D = StandardMaterial3D.new()
	lmat.albedo_color = Color(0.55, 0.95, 1.0)
	lmat.emission_enabled = true
	lmat.emission = Color(0.55, 0.95, 1.0)
	lmat.emission_energy_multiplier = 3.4
	lmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	laser.material_override = lmat
	sniper.add_child(laser)
	# Name billboard
	var label: Label3D = Label3D.new()
	label.text = "Sniper"
	label.position = Vector3(0, 1.20, 0)
	label.modulate = Color(0.55, 0.95, 1.0)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 16
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	sniper.add_child(label)


static func _build_d2_treasure_chest(geom: Node) -> void:
	## Epic-2 T57: a locked treasure chest with a glowing combination dial
	## sitting in a hidden corner of the district. Made of dark metal with
	## a glowing amber rim around the lid.
	var chest: Node3D = Node3D.new()
	chest.name = "D2TreasureChest"
	chest.position = D2_CENTER + Vector3(-8, 0, -16)
	chest.rotation = Vector3(0, deg_to_rad(35), 0)
	geom.add_child(chest)
	var metal_mat: StandardMaterial3D = StandardMaterial3D.new()
	metal_mat.albedo_color = Color(0.16, 0.13, 0.10)
	metal_mat.metallic = 0.85
	metal_mat.roughness = 0.40
	# Body box
	var body: MeshInstance3D = MeshInstance3D.new()
	var bmesh: BoxMesh = BoxMesh.new()
	bmesh.size = Vector3(1.20, 0.65, 0.85)
	body.mesh = bmesh
	body.position = Vector3(0, 0.32, 0)
	body.material_override = metal_mat
	chest.add_child(body)
	# Lid (slightly raised box)
	var lid: MeshInstance3D = MeshInstance3D.new()
	var lmesh: BoxMesh = BoxMesh.new()
	lmesh.size = Vector3(1.25, 0.20, 0.90)
	lid.mesh = lmesh
	lid.position = Vector3(0, 0.75, 0)
	lid.material_override = metal_mat
	chest.add_child(lid)
	# Glowing amber rim around the lid edge
	var rim_mat: StandardMaterial3D = StandardMaterial3D.new()
	rim_mat.albedo_color = Color(1.0, 0.65, 0.20)
	rim_mat.emission_enabled = true
	rim_mat.emission = Color(1.0, 0.75, 0.25)
	rim_mat.emission_energy_multiplier = 1.8
	rim_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for spec in [
		[Vector3(0, 0.65, 0.45), Vector3(1.20, 0.06, 0.06)],
		[Vector3(0, 0.65, -0.45), Vector3(1.20, 0.06, 0.06)],
		[Vector3(-0.60, 0.65, 0), Vector3(0.06, 0.06, 0.85)],
		[Vector3(0.60, 0.65, 0), Vector3(0.06, 0.06, 0.85)],
	]:
		var seg: MeshInstance3D = MeshInstance3D.new()
		var sm: BoxMesh = BoxMesh.new()
		sm.size = spec[1]
		seg.mesh = sm
		seg.position = spec[0]
		seg.material_override = rim_mat
		chest.add_child(seg)
	# Combination dial on the front face
	var dial: MeshInstance3D = MeshInstance3D.new()
	var dmesh: CylinderMesh = CylinderMesh.new()
	dmesh.top_radius = 0.18
	dmesh.bottom_radius = 0.18
	dmesh.height = 0.06
	dial.mesh = dmesh
	dial.position = Vector3(0, 0.30, 0.45)
	dial.rotation = Vector3(deg_to_rad(90), 0, 0)
	var dmat: StandardMaterial3D = StandardMaterial3D.new()
	dmat.albedo_color = Color(0.85, 0.85, 0.95)
	dmat.metallic = 0.85
	dmat.roughness = 0.20
	dmat.emission_enabled = true
	dmat.emission = Color(1.0, 0.85, 0.30)
	dmat.emission_energy_multiplier = 0.85
	dial.material_override = dmat
	chest.add_child(dial)
	# Dial pointer needle
	var needle: MeshInstance3D = MeshInstance3D.new()
	var nm: BoxMesh = BoxMesh.new()
	nm.size = Vector3(0.04, 0.04, 0.16)
	needle.mesh = nm
	needle.position = Vector3(0, 0.30, 0.50)
	var nmat: StandardMaterial3D = StandardMaterial3D.new()
	nmat.albedo_color = Color(1.0, 0.30, 0.30)
	nmat.emission_enabled = true
	nmat.emission = Color(1.0, 0.40, 0.40)
	nmat.emission_energy_multiplier = 2.6
	nmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	needle.material_override = nmat
	chest.add_child(needle)
	# Slow needle rotation simulating "trying combinations"
	var spin: Tween = create_tween().set_loops()
	spin.tween_property(needle, "rotation:z", deg_to_rad(45), 1.4).set_ease(Tween.EASE_IN_OUT)
	spin.tween_interval(0.5)
	spin.tween_property(needle, "rotation:z", deg_to_rad(-90), 2.0).set_ease(Tween.EASE_IN_OUT)
	spin.tween_interval(0.5)
	spin.tween_property(needle, "rotation:z", 0.0, 1.4).set_ease(Tween.EASE_IN_OUT)
	# Label
	var label: Label3D = Label3D.new()
	label.text = "LOCKED"
	label.position = Vector3(0, 1.20, 0)
	label.modulate = Color(1.0, 0.65, 0.20)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 16
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	chest.add_child(label)
	# Collision
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(1.30, 0.95, 0.95)
	cs.shape = cb
	cs.position = Vector3(0, 0.45, 0)
	sb.add_child(cs)
	chest.add_child(sb)


static func _build_d2_graveyard(geom: Node) -> void:
	## Epic-2 T58: a small graveyard plot with 5 simple stone markers
	## arranged in a row. Each marker has a different name on it.
	var grave: Node3D = Node3D.new()
	grave.name = "D2Graveyard"
	grave.position = D2_CENTER + Vector3(-10, 0, 18)
	geom.add_child(grave)
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.30, 0.32, 0.38)
	stone_mat.metallic = 0.30
	stone_mat.roughness = 0.55
	var names: Array[String] = ["BIT", "ECHO", "NULL", "FORGE", "PIXEL"]
	for i in names.size():
		var marker: Node3D = Node3D.new()
		marker.name = "Marker_%s" % names[i]
		marker.position = Vector3(-2.0 + i * 1.0, 0, 0)
		marker.rotation = Vector3(0, 0, deg_to_rad(randf_range(-8, 8)))
		grave.add_child(marker)
		# Tablet — flat box with rounded top (we use a box + sphere on top)
		var tablet: MeshInstance3D = MeshInstance3D.new()
		var tmesh: BoxMesh = BoxMesh.new()
		tmesh.size = Vector3(0.55, 0.85, 0.18)
		tablet.mesh = tmesh
		tablet.position = Vector3(0, 0.42, 0)
		tablet.material_override = stone_mat
		marker.add_child(tablet)
		# Top arch
		var arch: MeshInstance3D = MeshInstance3D.new()
		var amesh: SphereMesh = SphereMesh.new()
		amesh.radius = 0.27
		amesh.height = 0.30
		arch.mesh = amesh
		arch.position = Vector3(0, 0.85, 0)
		arch.scale = Vector3(1.0, 0.6, 0.4)
		arch.material_override = stone_mat
		marker.add_child(arch)
		# Name engraved
		var label: Label3D = Label3D.new()
		label.text = names[i]
		label.position = Vector3(0, 0.55, 0.10)
		label.modulate = Color(0.10, 0.10, 0.10)
		label.outline_size = 0
		label.font_size = 14
		label.no_depth_test = true
		marker.add_child(label)
	# Memorial sign behind the row
	var sign_label: Label3D = Label3D.new()
	sign_label.text = "FALLEN AGENTS"
	sign_label.position = Vector3(0, 1.85, -1.0)
	sign_label.modulate = Color(0.65, 0.65, 0.75)
	sign_label.outline_modulate = Color(0, 0, 0, 0.85)
	sign_label.outline_size = 5
	sign_label.font_size = 18
	sign_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	grave.add_child(sign_label)


static func _build_d2_data_packets(geom: Node) -> void:
	## Epic-2 T59: 8 floating data packet "envelopes" drifting through the
	## district. Each is a small glowing cyan box with an emissive seal,
	## bobbing on independent paths through the air.
	var positions: Array[Vector3] = [
		D2_CENTER + Vector3(-15, 4.0, -10),
		D2_CENTER + Vector3(-5, 5.5, 0),
		D2_CENTER + Vector3(8, 4.5, -8),
		D2_CENTER + Vector3(18, 5.0, 4),
		D2_CENTER + Vector3(22, 4.5, 16),
		D2_CENTER + Vector3(0, 5.5, 12),
		D2_CENTER + Vector3(-10, 4.0, 6),
		D2_CENTER + Vector3(14, 5.0, -16),
	]
	for i in positions.size():
		var packet: MeshInstance3D = MeshInstance3D.new()
		packet.name = "D2DataPacket_%d" % i
		var pmesh: BoxMesh = BoxMesh.new()
		pmesh.size = Vector3(0.30, 0.20, 0.04)
		packet.mesh = pmesh
		packet.position = positions[i]
		var pmat: StandardMaterial3D = StandardMaterial3D.new()
		pmat.albedo_color = Color(0.85, 0.95, 1.0, 0.85)
		pmat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		pmat.emission_enabled = true
		pmat.emission = Color(0.55, 0.95, 1.0)
		pmat.emission_energy_multiplier = 1.6
		pmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		packet.material_override = pmat
		geom.add_child(packet)
		# Drift through random waypoints
		var origin: Vector3 = positions[i]
		var drift: Tween = create_tween().set_loops()
		var wp1: Vector3 = origin + Vector3(randf_range(-3, 3), randf_range(-1, 1), randf_range(-3, 3))
		var wp2: Vector3 = origin + Vector3(randf_range(-3, 3), randf_range(-1, 1), randf_range(-3, 3))
		drift.tween_property(packet, "position", wp1, 4.0).set_ease(Tween.EASE_IN_OUT)
		drift.tween_property(packet, "position", wp2, 4.0).set_ease(Tween.EASE_IN_OUT)
		drift.tween_property(packet, "position", origin, 4.0).set_ease(Tween.EASE_IN_OUT)
		# Tumble
		var tumble: Tween = create_tween().set_loops()
		tumble.tween_property(packet, "rotation", Vector3(TAU, TAU * 0.5, 0), 5.0)


static func _build_d2_turret(geom: Node) -> void:
	## Epic-2 T60: a defensive automated turret on a base. Fixed to the
	## ground, with a slowly tracking barrel that sweeps left/right looking
	## for targets. Red blinking power indicator on the side.
	var turret: Node3D = Node3D.new()
	turret.name = "D2Turret"
	turret.position = D2_CENTER + Vector3(0, 0, -16)
	geom.add_child(turret)
	# Base pedestal
	var base_mat: StandardMaterial3D = StandardMaterial3D.new()
	base_mat.albedo_color = Color(0.16, 0.18, 0.22)
	base_mat.metallic = 0.85
	base_mat.roughness = 0.30
	var base: MeshInstance3D = MeshInstance3D.new()
	var bmesh: CylinderMesh = CylinderMesh.new()
	bmesh.top_radius = 0.55
	bmesh.bottom_radius = 0.65
	bmesh.height = 0.85
	base.mesh = bmesh
	base.position = Vector3(0, 0.42, 0)
	base.material_override = base_mat
	turret.add_child(base)
	# Pivot for rotating top
	var pivot: Node3D = Node3D.new()
	pivot.position = Vector3(0, 1.0, 0)
	turret.add_child(pivot)
	# Turret head — bigger box on the pivot
	var head: MeshInstance3D = MeshInstance3D.new()
	var hmesh: BoxMesh = BoxMesh.new()
	hmesh.size = Vector3(0.85, 0.55, 0.85)
	head.mesh = hmesh
	head.material_override = base_mat
	pivot.add_child(head)
	# 2 long barrels protruding from the front
	var barrel_mat: StandardMaterial3D = StandardMaterial3D.new()
	barrel_mat.albedo_color = Color(0.10, 0.10, 0.13)
	barrel_mat.metallic = 0.85
	barrel_mat.roughness = 0.30
	for sx: float in [-0.20, 0.20]:
		var barrel: MeshInstance3D = MeshInstance3D.new()
		var brmesh: CylinderMesh = CylinderMesh.new()
		brmesh.top_radius = 0.07
		brmesh.bottom_radius = 0.07
		brmesh.height = 1.20
		barrel.mesh = brmesh
		barrel.position = Vector3(sx, 0, 0.85)
		barrel.rotation = Vector3(deg_to_rad(90), 0, 0)
		barrel.material_override = barrel_mat
		pivot.add_child(barrel)
		# Glowing tip
		var tip: MeshInstance3D = MeshInstance3D.new()
		var tip_mesh: SphereMesh = SphereMesh.new()
		tip_mesh.radius = 0.08
		tip_mesh.height = 0.16
		tip.mesh = tip_mesh
		tip.position = Vector3(sx, 0, 1.45)
		var tip_mat: StandardMaterial3D = StandardMaterial3D.new()
		tip_mat.albedo_color = Color(1.0, 0.40, 0.20)
		tip_mat.emission_enabled = true
		tip_mat.emission = Color(1.0, 0.55, 0.20)
		tip_mat.emission_energy_multiplier = 2.4
		tip_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		tip.material_override = tip_mat
		pivot.add_child(tip)
	# Sweeping rotation
	var sweep: Tween = create_tween().set_loops()
	sweep.tween_property(pivot, "rotation:y", deg_to_rad(80), 4.0).set_ease(Tween.EASE_IN_OUT)
	sweep.tween_property(pivot, "rotation:y", deg_to_rad(-80), 4.0).set_ease(Tween.EASE_IN_OUT)
	# Red blinking power indicator on the base side
	var indicator: MeshInstance3D = MeshInstance3D.new()
	var im: SphereMesh = SphereMesh.new()
	im.radius = 0.08
	im.height = 0.16
	indicator.mesh = im
	indicator.position = Vector3(0.55, 0.55, 0)
	var imat: StandardMaterial3D = StandardMaterial3D.new()
	imat.albedo_color = Color(1.0, 0.20, 0.20)
	imat.emission_enabled = true
	imat.emission = Color(1.0, 0.30, 0.30)
	imat.emission_energy_multiplier = 2.6
	imat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	indicator.material_override = imat
	turret.add_child(indicator)
	var blink: Tween = create_tween().set_loops()
	blink.tween_property(indicator, "scale", Vector3(0.4, 0.4, 0.4), 0.4).set_ease(Tween.EASE_IN_OUT)
	blink.tween_property(indicator, "scale", Vector3(1.2, 1.2, 1.2), 0.4).set_ease(Tween.EASE_IN_OUT)
	# Collision around base
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(1.0, 1.85, 1.0)
	cs.shape = cb
	cs.position = Vector3(0, 0.92, 0)
	sb.add_child(cs)
	turret.add_child(sb)


static func _build_d2_floating_debris(geom: Node) -> void:
	## Epic-2 T61: 8 large slabs of cracked architecture floating overhead
	## as if torn from a broken world. Each is a tilted slab on a slow
	## bobbing tween, scattered across the district.
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 88
	for i in 8:
		var slab: MeshInstance3D = MeshInstance3D.new()
		slab.name = "D2FloatingSlab_%d" % i
		var smesh: BoxMesh = BoxMesh.new()
		smesh.size = Vector3(rng.randf_range(1.4, 2.6), rng.randf_range(0.20, 0.55), rng.randf_range(1.4, 2.6))
		slab.mesh = smesh
		slab.position = D2_CENTER + Vector3(
			rng.randf_range(-22, 22),
			rng.randf_range(8, 14),
			rng.randf_range(-16, 16)
		)
		slab.rotation = Vector3(
			deg_to_rad(rng.randf_range(-25, 25)),
			deg_to_rad(rng.randf_range(0, 360)),
			deg_to_rad(rng.randf_range(-25, 25))
		)
		var mat: StandardMaterial3D = StandardMaterial3D.new()
		mat.albedo_color = Color(0.16, 0.13, 0.10)
		mat.metallic = 0.30
		mat.roughness = 0.65
		mat.emission_enabled = true
		mat.emission = Color(1.0, 0.40, 0.20)
		mat.emission_energy_multiplier = 0.30
		slab.material_override = mat
		geom.add_child(slab)
		# Slow bob + drift
		var origin: Vector3 = slab.position
		var bob: Tween = create_tween().set_loops()
		bob.tween_property(slab, "position", origin + Vector3(0, 0.55, 0), 2.4 + i * 0.2).set_ease(Tween.EASE_IN_OUT)
		bob.tween_property(slab, "position", origin, 2.4 + i * 0.2).set_ease(Tween.EASE_IN_OUT)
		# Slow lazy rotation
		var spin: Tween = create_tween().set_loops()
		spin.tween_property(slab, "rotation:y", slab.rotation.y + TAU, 16.0 + i * 1.5)


static func _build_d2_power_lines(geom: Node) -> void:
	## Epic-2 T62: 3 suspended power lines running across the district from
	## tall metal poles. Each line is a thin sagging cylinder + small spark
	## that periodically slides along the wire.
	var pole_specs: Array = [
		[D2_CENTER + Vector3(-22, 0, -14), D2_CENTER + Vector3(22, 0, -14)],
		[D2_CENTER + Vector3(-22, 0, 0), D2_CENTER + Vector3(22, 0, 0)],
		[D2_CENTER + Vector3(-22, 0, 14), D2_CENTER + Vector3(22, 0, 14)],
	]
	var pole_mat: StandardMaterial3D = StandardMaterial3D.new()
	pole_mat.albedo_color = Color(0.10, 0.13, 0.16)
	pole_mat.metallic = 0.85
	pole_mat.roughness = 0.30
	for i in pole_specs.size():
		var from: Vector3 = pole_specs[i][0]
		var to: Vector3 = pole_specs[i][1]
		# 2 metal poles at the endpoints
		for endpoint in [from, to]:
			var pole: MeshInstance3D = MeshInstance3D.new()
			var pmesh: CylinderMesh = CylinderMesh.new()
			pmesh.top_radius = 0.10
			pmesh.bottom_radius = 0.14
			pmesh.height = 6.0
			pole.mesh = pmesh
			pole.position = endpoint + Vector3(0, 3.0, 0)
			pole.material_override = pole_mat
			geom.add_child(pole)
			# Cross arm
			var arm: MeshInstance3D = MeshInstance3D.new()
			var amesh: BoxMesh = BoxMesh.new()
			amesh.size = Vector3(1.40, 0.10, 0.10)
			arm.mesh = amesh
			arm.position = endpoint + Vector3(0, 5.85, 0)
			arm.material_override = pole_mat
			geom.add_child(arm)
			# Collision per pole
			var sb: StaticBody3D = StaticBody3D.new()
			var cs: CollisionShape3D = CollisionShape3D.new()
			var cap: CapsuleShape3D = CapsuleShape3D.new()
			cap.radius = 0.20
			cap.height = 6.0
			cs.shape = cap
			cs.position = endpoint + Vector3(0, 3.0, 0)
			sb.add_child(cs)
			geom.add_child(sb)
		# Power line — long thin cylinder slightly sagging at the middle
		var line: MeshInstance3D = MeshInstance3D.new()
		line.name = "D2PowerLine_%d" % i
		var dist: float = from.distance_to(to)
		var lmesh: CylinderMesh = CylinderMesh.new()
		lmesh.top_radius = 0.04
		lmesh.bottom_radius = 0.04
		lmesh.height = dist
		line.mesh = lmesh
		line.position = (from + to) * 0.5 + Vector3(0, 5.50, 0)
		line.rotation = Vector3(0, 0, deg_to_rad(90))
		var lmat: StandardMaterial3D = StandardMaterial3D.new()
		lmat.albedo_color = Color(0.05, 0.05, 0.10)
		lmat.metallic = 0.55
		line.material_override = lmat
		geom.add_child(line)
		# Spark traveling along the line
		var spark: MeshInstance3D = MeshInstance3D.new()
		var sm: SphereMesh = SphereMesh.new()
		sm.radius = 0.10
		sm.height = 0.20
		spark.mesh = sm
		spark.position = from + Vector3(0, 5.50, 0)
		var smat: StandardMaterial3D = StandardMaterial3D.new()
		smat.albedo_color = Color(0.55, 0.95, 1.0)
		smat.emission_enabled = true
		smat.emission = Color(0.55, 0.95, 1.0)
		smat.emission_energy_multiplier = 3.0
		smat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		spark.material_override = smat
		geom.add_child(spark)
		var travel: Tween = create_tween().set_loops()
		travel.tween_property(spark, "position", to + Vector3(0, 5.50, 0), 5.0 + i * 0.4).set_ease(Tween.EASE_IN_OUT)
		travel.tween_property(spark, "position", from + Vector3(0, 5.50, 0), 5.0 + i * 0.4).set_ease(Tween.EASE_IN_OUT)


static func _build_d2_quarantine_zone(geom: Node) -> void:
	## Epic-2 T63: a quarantine zone marked off with yellow biohazard tape
	## stretched between 4 metal posts forming a square. Inside the zone,
	## a single sealed container with a hazard symbol.
	var zone: Node3D = Node3D.new()
	zone.name = "D2QuarantineZone"
	zone.position = D2_CENTER + Vector3(-15, 0, 0)
	geom.add_child(zone)
	var post_mat: StandardMaterial3D = StandardMaterial3D.new()
	post_mat.albedo_color = Color(0.10, 0.13, 0.16)
	post_mat.metallic = 0.85
	# 4 corner posts forming a 3x3 square
	var post_offsets: Array[Vector3] = [
		Vector3(-1.5, 0, -1.5),
		Vector3(1.5, 0, -1.5),
		Vector3(-1.5, 0, 1.5),
		Vector3(1.5, 0, 1.5),
	]
	for off in post_offsets:
		var post: MeshInstance3D = MeshInstance3D.new()
		var pmesh: CylinderMesh = CylinderMesh.new()
		pmesh.top_radius = 0.07
		pmesh.bottom_radius = 0.10
		pmesh.height = 1.40
		post.mesh = pmesh
		post.position = off + Vector3(0, 0.70, 0)
		post.material_override = post_mat
		zone.add_child(post)
	# Yellow biohazard tape between posts at 2 heights
	var tape_mat: StandardMaterial3D = StandardMaterial3D.new()
	tape_mat.albedo_color = Color(1.0, 0.85, 0.20)
	tape_mat.emission_enabled = true
	tape_mat.emission = Color(1.0, 0.95, 0.30)
	tape_mat.emission_energy_multiplier = 1.4
	tape_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	# 4 sides x 2 heights = 8 tape segments
	var tape_specs: Array = [
		[Vector3(0, 0, -1.5), Vector3(3.0, 0.10, 0.05)],
		[Vector3(0, 0, 1.5), Vector3(3.0, 0.10, 0.05)],
		[Vector3(-1.5, 0, 0), Vector3(0.05, 0.10, 3.0)],
		[Vector3(1.5, 0, 0), Vector3(0.05, 0.10, 3.0)],
	]
	for spec in tape_specs:
		for ty: float in [0.55, 1.10]:
			var tape: MeshInstance3D = MeshInstance3D.new()
			var tmesh: BoxMesh = BoxMesh.new()
			tmesh.size = spec[1]
			tape.mesh = tmesh
			var p: Vector3 = spec[0]
			p.y = ty
			tape.position = p
			tape.material_override = tape_mat
			zone.add_child(tape)
	# Sealed container at the center with hazard symbol
	var container_mat: StandardMaterial3D = StandardMaterial3D.new()
	container_mat.albedo_color = Color(0.18, 0.20, 0.24)
	container_mat.metallic = 0.85
	container_mat.roughness = 0.40
	var container: MeshInstance3D = MeshInstance3D.new()
	var cmesh: BoxMesh = BoxMesh.new()
	cmesh.size = Vector3(1.0, 0.85, 0.85)
	container.mesh = cmesh
	container.position = Vector3(0, 0.42, 0)
	container.material_override = container_mat
	zone.add_child(container)
	# Hazard symbol on the front
	var hazard: Label3D = Label3D.new()
	hazard.text = "☣"
	hazard.position = Vector3(0, 0.42, 0.45)
	hazard.modulate = Color(1.0, 0.95, 0.30)
	hazard.outline_modulate = Color(0, 0, 0, 0.85)
	hazard.outline_size = 4
	hazard.font_size = 36
	hazard.no_depth_test = true
	zone.add_child(hazard)
	# Sign
	var label: Label3D = Label3D.new()
	label.text = "QUARANTINE"
	label.position = Vector3(0, 1.85, 0)
	label.modulate = Color(1.0, 0.85, 0.20)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 18
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	zone.add_child(label)
	# Collision around container
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(1.0, 0.85, 0.85)
	cs.shape = cb
	cs.position = Vector3(0, 0.42, 0)
	sb.add_child(cs)
	zone.add_child(sb)


static func _build_d2_lander_pod(geom: Node) -> void:
	## Epic-2 T64: a crashed lander pod — egg-shaped capsule with 4 landing
	## legs splayed outward, hatch open with a deployable ramp dropped to
	## the ground, glowing cyan interior visible.
	var pod: Node3D = Node3D.new()
	pod.name = "D2LanderPod"
	pod.position = D2_CENTER + Vector3(18, 0, 8)
	pod.rotation = Vector3(0, deg_to_rad(-30), deg_to_rad(8))
	geom.add_child(pod)
	# Capsule body
	var hull_mat: StandardMaterial3D = StandardMaterial3D.new()
	hull_mat.albedo_color = Color(0.55, 0.55, 0.65)
	hull_mat.metallic = 0.85
	hull_mat.roughness = 0.30
	var hull: MeshInstance3D = MeshInstance3D.new()
	var hmesh: SphereMesh = SphereMesh.new()
	hmesh.radius = 1.10
	hmesh.height = 2.80
	hull.mesh = hmesh
	hull.position = Vector3(0, 1.40, 0)
	hull.scale = Vector3(0.85, 1.0, 0.85)
	hull.material_override = hull_mat
	pod.add_child(hull)
	# 4 landing legs splayed
	var leg_mat: StandardMaterial3D = StandardMaterial3D.new()
	leg_mat.albedo_color = Color(0.10, 0.13, 0.16)
	leg_mat.metallic = 0.85
	leg_mat.roughness = 0.30
	for i in 4:
		var angle: float = (float(i) / 4.0) * TAU
		var leg: MeshInstance3D = MeshInstance3D.new()
		var lmesh: CylinderMesh = CylinderMesh.new()
		lmesh.top_radius = 0.10
		lmesh.bottom_radius = 0.14
		lmesh.height = 1.40
		leg.mesh = lmesh
		leg.position = Vector3(cos(angle) * 0.85, 0.45, sin(angle) * 0.85)
		# Splay outward
		leg.rotation = Vector3(sin(angle) * deg_to_rad(20), 0, -cos(angle) * deg_to_rad(20))
		leg.material_override = leg_mat
		pod.add_child(leg)
		# Foot pad
		var foot: MeshInstance3D = MeshInstance3D.new()
		var fmesh: CylinderMesh = CylinderMesh.new()
		fmesh.top_radius = 0.18
		fmesh.bottom_radius = 0.18
		fmesh.height = 0.06
		foot.mesh = fmesh
		foot.position = Vector3(cos(angle) * 1.20, 0.05, sin(angle) * 1.20)
		foot.material_override = leg_mat
		pod.add_child(foot)
	# Open hatch — flat box at the front rotated outward
	var hatch_mat: StandardMaterial3D = StandardMaterial3D.new()
	hatch_mat.albedo_color = Color(0.20, 0.50, 0.70, 0.55)
	hatch_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	hatch_mat.emission_enabled = true
	hatch_mat.emission = Color(0.55, 0.95, 1.0)
	hatch_mat.emission_energy_multiplier = 1.6
	hatch_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var hatch: MeshInstance3D = MeshInstance3D.new()
	var ha_mesh: BoxMesh = BoxMesh.new()
	ha_mesh.size = Vector3(1.20, 1.40, 0.06)
	hatch.mesh = ha_mesh
	hatch.position = Vector3(0.30, 1.40, 0.95)
	hatch.rotation = Vector3(0, deg_to_rad(60), 0)
	hatch.material_override = hatch_mat
	pod.add_child(hatch)
	# Ramp — long flat box from hatch to the ground
	var ramp: MeshInstance3D = MeshInstance3D.new()
	var rmesh: BoxMesh = BoxMesh.new()
	rmesh.size = Vector3(1.20, 0.06, 1.85)
	ramp.mesh = rmesh
	ramp.position = Vector3(0, 0.40, 1.85)
	ramp.rotation = Vector3(deg_to_rad(15), 0, 0)
	ramp.material_override = hull_mat
	pod.add_child(ramp)
	# Glowing cyan interior light visible through hatch
	var interior: OmniLight3D = OmniLight3D.new()
	interior.position = Vector3(0, 1.40, 0)
	interior.light_color = Color(0.55, 0.95, 1.0)
	interior.light_energy = 1.6
	interior.omni_range = 4.0
	pod.add_child(interior)
	# Collision around the body
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cap: CapsuleShape3D = CapsuleShape3D.new()
	cap.radius = 1.0
	cap.height = 2.40
	cs.shape = cap
	cs.position = Vector3(0, 1.40, 0)
	sb.add_child(cs)
	pod.add_child(sb)


static func _build_d2_info_broker_npc(town: Node) -> void:
	## Epic-2 T65: an info broker NPC standing behind a small data table
	## with a holographic file folder floating above it. The "trade
	## information for credits" archetype.
	var slots: Node3D = town.get_node_or_null("%NPCSlots") as Node3D
	if slots == null:
		return
	var broker: Node3D = Node3D.new()
	broker.name = "D2InfoBroker"
	broker.position = D2_CENTER + Vector3(-10, 0, -2)
	slots.add_child(broker)
	# Table
	var table_mat: StandardMaterial3D = StandardMaterial3D.new()
	table_mat.albedo_color = Color(0.18, 0.16, 0.12)
	table_mat.metallic = 0.40
	var table: MeshInstance3D = MeshInstance3D.new()
	var tmesh: BoxMesh = BoxMesh.new()
	tmesh.size = Vector3(1.20, 0.85, 0.55)
	table.mesh = tmesh
	table.position = Vector3(0, 0.42, 0.65)
	table.material_override = table_mat
	broker.add_child(table)
	# Floating holographic file folder above the table
	var folder: MeshInstance3D = MeshInstance3D.new()
	var fmesh: BoxMesh = BoxMesh.new()
	fmesh.size = Vector3(0.85, 0.55, 0.04)
	folder.mesh = fmesh
	folder.position = Vector3(0, 1.30, 0.65)
	var fmat: StandardMaterial3D = StandardMaterial3D.new()
	fmat.albedo_color = Color(0.95, 0.85, 0.30, 0.85)
	fmat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	fmat.emission_enabled = true
	fmat.emission = Color(1.0, 0.95, 0.40)
	fmat.emission_energy_multiplier = 1.8
	fmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	folder.material_override = fmat
	broker.add_child(folder)
	# Bob the folder
	var bob: Tween = create_tween().set_loops()
	bob.tween_property(folder, "position:y", 1.45, 1.4).set_ease(Tween.EASE_IN_OUT)
	bob.tween_property(folder, "position:y", 1.30, 1.4).set_ease(Tween.EASE_IN_OUT)
	# Slow rotation
	var spin: Tween = create_tween().set_loops()
	spin.tween_property(folder, "rotation:y", TAU, 6.0)
	# Body — slim figure
	var bmat: StandardMaterial3D = StandardMaterial3D.new()
	bmat.albedo_color = Color(0.20, 0.18, 0.30)
	bmat.metallic = 0.30
	bmat.roughness = 0.45
	bmat.emission_enabled = true
	bmat.emission = Color(0.40, 0.30, 0.85)
	bmat.emission_energy_multiplier = 0.30
	var body: MeshInstance3D = MeshInstance3D.new()
	var bmesh: CapsuleMesh = CapsuleMesh.new()
	bmesh.radius = 0.36
	bmesh.height = 1.30
	body.mesh = bmesh
	body.position = Vector3(0, 0.70, 0)
	body.material_override = bmat
	broker.add_child(body)
	# Top hat (small cylinder)
	var hat: MeshInstance3D = MeshInstance3D.new()
	var hmesh: CylinderMesh = CylinderMesh.new()
	hmesh.top_radius = 0.30
	hmesh.bottom_radius = 0.30
	hmesh.height = 0.45
	hat.mesh = hmesh
	hat.position = Vector3(0, 1.62, 0)
	var hmat: StandardMaterial3D = StandardMaterial3D.new()
	hmat.albedo_color = Color(0.05, 0.04, 0.10)
	hmat.metallic = 0.30
	hmat.roughness = 0.55
	hat.material_override = hmat
	broker.add_child(hat)
	# Hat brim
	var brim: MeshInstance3D = MeshInstance3D.new()
	var brmesh: CylinderMesh = CylinderMesh.new()
	brmesh.top_radius = 0.45
	brmesh.bottom_radius = 0.45
	brmesh.height = 0.05
	brim.mesh = brmesh
	brim.position = Vector3(0, 1.40, 0)
	brim.material_override = hmat
	broker.add_child(brim)
	# 2 yellow eyes
	var eye_mat: StandardMaterial3D = StandardMaterial3D.new()
	eye_mat.albedo_color = Color(1.0, 0.95, 0.30)
	eye_mat.emission_enabled = true
	eye_mat.emission = Color(1.0, 0.95, 0.30)
	eye_mat.emission_energy_multiplier = 2.6
	eye_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for ex: float in [-0.10, 0.10]:
		var eye: MeshInstance3D = MeshInstance3D.new()
		var em: SphereMesh = SphereMesh.new()
		em.radius = 0.06
		em.height = 0.12
		eye.mesh = em
		eye.position = Vector3(ex, 1.30, 0.30)
		eye.material_override = eye_mat
		broker.add_child(eye)
	# Name billboard
	var label: Label3D = Label3D.new()
	label.text = "Info Broker"
	label.position = Vector3(0, 2.10, 0)
	label.modulate = Color(1.0, 0.95, 0.30)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 18
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	broker.add_child(label)


static func _build_d2_rune_pile(geom: Node) -> void:
	## Epic-2 T66: a pile of 8 glowing rune stones / data crystals stacked
	## haphazardly. Each is a prism with a different color tint, pulsing
	## emission at slightly different rates.
	var pile: Node3D = Node3D.new()
	pile.name = "D2RunePile"
	pile.position = D2_CENTER + Vector3(-12, 0, -12)
	geom.add_child(pile)
	var palette: Array[Color] = [
		Color(0.55, 0.95, 1.0),
		Color(1.0, 0.55, 0.20),
		Color(0.85, 0.40, 1.0),
		Color(0.40, 1.0, 0.55),
		Color(1.0, 0.95, 0.30),
		Color(0.30, 0.85, 1.0),
		Color(1.0, 0.30, 0.55),
		Color(0.55, 1.0, 0.85),
	]
	var stone_specs: Array = [
		Vector3(0, 0.30, 0),
		Vector3(0.55, 0.30, 0.20),
		Vector3(-0.45, 0.30, 0.30),
		Vector3(-0.20, 0.30, -0.55),
		Vector3(0.30, 0.30, -0.40),
		Vector3(0.0, 0.85, 0.0),
		Vector3(0.40, 0.85, -0.10),
		Vector3(-0.20, 0.85, 0.30),
	]
	for i in stone_specs.size():
		var stone: MeshInstance3D = MeshInstance3D.new()
		var smesh: PrismMesh = PrismMesh.new()
		smesh.size = Vector3(0.30, 0.65, 0.30)
		stone.mesh = smesh
		stone.position = stone_specs[i]
		stone.rotation = Vector3(0, deg_to_rad(randf_range(0, 360)), deg_to_rad(randf_range(-25, 25)))
		var color: Color = palette[i]
		var mat: StandardMaterial3D = StandardMaterial3D.new()
		mat.albedo_color = color
		mat.emission_enabled = true
		mat.emission = color
		mat.emission_energy_multiplier = 2.0
		mat.metallic = 0.40
		mat.roughness = 0.20
		mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		stone.material_override = mat
		pile.add_child(stone)
		# Pulse emission
		var pulse: Tween = create_tween().set_loops()
		var ps: float = 1.0 + i * 0.15
		pulse.tween_property(mat, "emission_energy_multiplier", 3.4, ps).set_ease(Tween.EASE_IN_OUT)
		pulse.tween_property(mat, "emission_energy_multiplier", 1.4, ps).set_ease(Tween.EASE_IN_OUT)
	# Sign
	var label: Label3D = Label3D.new()
	label.text = "RUNE PILE"
	label.position = Vector3(0, 1.85, 0)
	label.modulate = Color(0.85, 0.95, 1.0)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 16
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	pile.add_child(label)


static func _build_d2_broken_clock(geom: Node) -> void:
	## Epic-2 T67: a tall broken clock tower with frozen hands. Stone
	## column with a clock face on each of 4 sides at the top, frozen at
	## different broken angles like time stopped here.
	var tower: Node3D = Node3D.new()
	tower.name = "D2BrokenClockTower"
	tower.position = D2_CENTER + Vector3(20, 0, -8)
	geom.add_child(tower)
	# Stone column
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.18, 0.16, 0.14)
	stone_mat.metallic = 0.30
	stone_mat.roughness = 0.65
	var col: MeshInstance3D = MeshInstance3D.new()
	var cmesh: BoxMesh = BoxMesh.new()
	cmesh.size = Vector3(1.40, 6.5, 1.40)
	col.mesh = cmesh
	col.position = Vector3(0, 3.25, 0)
	col.material_override = stone_mat
	tower.add_child(col)
	# Cracked stripe down one side
	var crack_mat: StandardMaterial3D = StandardMaterial3D.new()
	crack_mat.albedo_color = Color(1.0, 0.30, 0.20)
	crack_mat.emission_enabled = true
	crack_mat.emission = Color(1.0, 0.40, 0.20)
	crack_mat.emission_energy_multiplier = 1.4
	crack_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var crack: MeshInstance3D = MeshInstance3D.new()
	var cmesh2: BoxMesh = BoxMesh.new()
	cmesh2.size = Vector3(0.06, 5.5, 0.10)
	crack.mesh = cmesh2
	crack.position = Vector3(0.71, 3.0, 0)
	crack.rotation = Vector3(0, 0, deg_to_rad(8))
	crack.material_override = crack_mat
	tower.add_child(crack)
	# Crown — wider top block
	var crown: MeshInstance3D = MeshInstance3D.new()
	var crmesh: BoxMesh = BoxMesh.new()
	crmesh.size = Vector3(2.0, 2.0, 2.0)
	crown.mesh = crmesh
	crown.position = Vector3(0, 7.50, 0)
	crown.material_override = stone_mat
	tower.add_child(crown)
	# 4 clock faces (one on each side of the crown)
	var face_mat: StandardMaterial3D = StandardMaterial3D.new()
	face_mat.albedo_color = Color(0.85, 0.85, 0.95)
	face_mat.emission_enabled = true
	face_mat.emission = Color(1.0, 0.95, 0.85)
	face_mat.emission_energy_multiplier = 0.75
	face_mat.metallic = 0.20
	face_mat.roughness = 0.30
	var sides: Array[Vector3] = [
		Vector3(0, 0, 1.01),
		Vector3(0, 0, -1.01),
		Vector3(1.01, 0, 0),
		Vector3(-1.01, 0, 0),
	]
	for i in sides.size():
		var face: MeshInstance3D = MeshInstance3D.new()
		var fmesh: CylinderMesh = CylinderMesh.new()
		fmesh.top_radius = 0.65
		fmesh.bottom_radius = 0.65
		fmesh.height = 0.06
		face.mesh = fmesh
		face.position = sides[i] + Vector3(0, 7.50, 0)
		# Orient flat to the side
		if i < 2:
			face.rotation = Vector3(deg_to_rad(90), 0, 0)
		else:
			face.rotation = Vector3(0, 0, deg_to_rad(90))
		face.material_override = face_mat
		tower.add_child(face)
		# Hour hand (broken angle)
		var hour: MeshInstance3D = MeshInstance3D.new()
		var hmesh: BoxMesh = BoxMesh.new()
		hmesh.size = Vector3(0.06, 0.45, 0.04)
		hour.mesh = hmesh
		hour.position = sides[i] * 1.05 + Vector3(0, 7.50, 0)
		var hour_rot: float = deg_to_rad(45 + i * 60)
		if i < 2:
			hour.rotation = Vector3(deg_to_rad(90), 0, hour_rot)
		else:
			hour.rotation = Vector3(0, hour_rot, deg_to_rad(90))
		var hour_mat: StandardMaterial3D = StandardMaterial3D.new()
		hour_mat.albedo_color = Color(0.05, 0.05, 0.10)
		hour_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		hour.material_override = hour_mat
		tower.add_child(hour)
		# Minute hand
		var minute: MeshInstance3D = MeshInstance3D.new()
		var mm: BoxMesh = BoxMesh.new()
		mm.size = Vector3(0.04, 0.55, 0.04)
		minute.mesh = mm
		minute.position = sides[i] * 1.05 + Vector3(0, 7.50, 0)
		var min_rot: float = deg_to_rad(-30 + i * 90)
		if i < 2:
			minute.rotation = Vector3(deg_to_rad(90), 0, min_rot)
		else:
			minute.rotation = Vector3(0, min_rot, deg_to_rad(90))
		minute.material_override = hour_mat
		tower.add_child(minute)
	# Collision around tower
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(2.0, 8.5, 2.0)
	cs.shape = cb
	cs.position = Vector3(0, 4.25, 0)
	sb.add_child(cs)
	tower.add_child(sb)


static func _build_d2_arrow_signs(geom: Node) -> void:
	## Epic-2 T68: 4 glowing directional arrow signs near the entrance arch
	## pointing toward key D2 landmarks (TRIAL PIT, MERC CAMP, ARCHIVE,
	## CAGE FIGHT). Each is a tilted post with an angled emissive arrow.
	var sign_root: Node3D = Node3D.new()
	sign_root.name = "D2ArrowSigns"
	sign_root.position = D2_CENTER + Vector3(-18, 0, -2)
	geom.add_child(sign_root)
	# 1 shared post
	var post_mat: StandardMaterial3D = StandardMaterial3D.new()
	post_mat.albedo_color = Color(0.10, 0.13, 0.16)
	post_mat.metallic = 0.85
	var post: MeshInstance3D = MeshInstance3D.new()
	var pmesh: CylinderMesh = CylinderMesh.new()
	pmesh.top_radius = 0.07
	pmesh.bottom_radius = 0.10
	pmesh.height = 3.4
	post.mesh = pmesh
	post.position = Vector3(0, 1.7, 0)
	post.material_override = post_mat
	sign_root.add_child(post)
	# 4 arrow signs at different heights, each pointing at a different yaw
	var sign_specs: Array = [
		["TRIAL PIT", Color(1.0, 0.40, 0.20), 2.85, deg_to_rad(45)],
		["MERC CAMP", Color(1.0, 0.65, 0.30), 2.40, deg_to_rad(135)],
		["ARMS DEALER", Color(0.85, 0.40, 1.0), 1.95, deg_to_rad(225)],
		["CAGE FIGHT", Color(0.55, 0.95, 1.0), 1.50, deg_to_rad(315)],
	]
	for spec in sign_specs:
		var arrow_pivot: Node3D = Node3D.new()
		arrow_pivot.position = Vector3(0, spec[2], 0)
		arrow_pivot.rotation = Vector3(0, spec[3], 0)
		sign_root.add_child(arrow_pivot)
		# Arrow board
		var arrow: MeshInstance3D = MeshInstance3D.new()
		var amesh: BoxMesh = BoxMesh.new()
		amesh.size = Vector3(0.04, 0.30, 1.40)
		arrow.mesh = amesh
		arrow.position = Vector3(0, 0, 0.85)
		var color: Color = spec[1]
		var amat: StandardMaterial3D = StandardMaterial3D.new()
		amat.albedo_color = Color(color.r * 0.40, color.g * 0.40, color.b * 0.40)
		amat.emission_enabled = true
		amat.emission = color
		amat.emission_energy_multiplier = 1.4
		amat.metallic = 0.30
		arrow.material_override = amat
		arrow_pivot.add_child(arrow)
		# Pointed tip prism
		var tip: MeshInstance3D = MeshInstance3D.new()
		var tmesh: PrismMesh = PrismMesh.new()
		tmesh.size = Vector3(0.30, 0.30, 0.06)
		tip.mesh = tmesh
		tip.position = Vector3(0, 0, 1.65)
		tip.rotation = Vector3(0, deg_to_rad(90), deg_to_rad(90))
		tip.material_override = amat
		arrow_pivot.add_child(tip)
		# Label on the arrow
		var label: Label3D = Label3D.new()
		label.text = spec[0]
		label.position = Vector3(0.05, 0, 0.85)
		label.modulate = Color(1, 1, 1)
		label.outline_modulate = Color(0, 0, 0, 0.85)
		label.outline_size = 4
		label.font_size = 14
		label.no_depth_test = true
		arrow_pivot.add_child(label)
	# Collision around the post
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cap: CapsuleShape3D = CapsuleShape3D.new()
	cap.radius = 0.20
	cap.height = 3.4
	cs.shape = cap
	cs.position = Vector3(0, 1.7, 0)
	sb.add_child(cs)
	sign_root.add_child(sb)


static func _build_d2_zipline(geom: Node) -> void:
	## Epic-2 T69: a zipline cable strung diagonally between 2 tall scrap
	## towers, with a small handle slider that occasionally rides down it.
	var line_root: Node3D = Node3D.new()
	line_root.name = "D2Zipline"
	geom.add_child(line_root)
	var from_tower: Vector3 = D2_CENTER + Vector3(-22, 7.5, 12)  # top of scrap tower
	var to_tower: Vector3 = D2_CENTER + Vector3(20, 4.5, -16)   # top of watchtower
	var dist: float = from_tower.distance_to(to_tower)
	var mid: Vector3 = (from_tower + to_tower) * 0.5
	# Cable — long thin cylinder
	var cable: MeshInstance3D = MeshInstance3D.new()
	var cmesh: CylinderMesh = CylinderMesh.new()
	cmesh.top_radius = 0.04
	cmesh.bottom_radius = 0.04
	cmesh.height = dist
	cable.mesh = cmesh
	cable.position = mid
	# Orient along from->to direction
	var dir: Vector3 = (to_tower - from_tower).normalized()
	# Use look_at trick: rotate cylinder so its Y axis aligns with dir
	var basis: Basis = Basis(Quaternion(Vector3(0, 1, 0), dir))
	cable.basis = basis
	var cmat: StandardMaterial3D = StandardMaterial3D.new()
	cmat.albedo_color = Color(0.05, 0.05, 0.08)
	cmat.metallic = 0.85
	cmat.roughness = 0.30
	cable.material_override = cmat
	line_root.add_child(cable)
	# Handle slider — small box that rides along the cable
	var slider: MeshInstance3D = MeshInstance3D.new()
	var smesh: BoxMesh = BoxMesh.new()
	smesh.size = Vector3(0.30, 0.20, 0.30)
	slider.mesh = smesh
	slider.position = from_tower
	var smat: StandardMaterial3D = StandardMaterial3D.new()
	smat.albedo_color = Color(0.30, 0.35, 0.42)
	smat.metallic = 0.85
	smat.emission_enabled = true
	smat.emission = Color(1.0, 0.55, 0.20)
	smat.emission_energy_multiplier = 0.85
	slider.material_override = smat
	line_root.add_child(slider)
	# Travel tween — slider rides down the cable, resets, repeats
	var travel: Tween = create_tween().set_loops()
	travel.tween_property(slider, "position", to_tower, 3.5).set_ease(Tween.EASE_IN)
	travel.tween_interval(2.0)
	travel.tween_property(slider, "position", from_tower, 0.05)
	travel.tween_interval(1.0)


static func _build_d2_mechanic_npc(town: Node) -> void:
	## Epic-2 T70: mechanic NPC standing next to the repair workshop with
	## an oversized wrench in one hand and a tool belt around the waist.
	var slots: Node3D = town.get_node_or_null("%NPCSlots") as Node3D
	if slots == null:
		return
	var mech: Node3D = Node3D.new()
	mech.name = "D2Mechanic"
	mech.position = D2_CENTER + Vector3(-16, 0, 4)
	slots.add_child(mech)
	# Body — average capsule with overall blue tint
	var bmat: StandardMaterial3D = StandardMaterial3D.new()
	bmat.albedo_color = Color(0.20, 0.30, 0.40)
	bmat.metallic = 0.30
	bmat.roughness = 0.55
	bmat.emission_enabled = true
	bmat.emission = Color(0.30, 0.55, 0.85)
	bmat.emission_energy_multiplier = 0.30
	var body: MeshInstance3D = MeshInstance3D.new()
	var bmesh: CapsuleMesh = CapsuleMesh.new()
	bmesh.radius = 0.42
	bmesh.height = 1.20
	body.mesh = bmesh
	body.position = Vector3(0, 0.65, 0)
	body.material_override = bmat
	mech.add_child(body)
	# Tool belt — a thin amber band around the waist
	var belt: MeshInstance3D = MeshInstance3D.new()
	var belt_mesh: TorusMesh = TorusMesh.new()
	belt_mesh.inner_radius = 0.40
	belt_mesh.outer_radius = 0.45
	belt.mesh = belt_mesh
	belt.position = Vector3(0, 0.55, 0)
	var belt_mat: StandardMaterial3D = StandardMaterial3D.new()
	belt_mat.albedo_color = Color(0.85, 0.65, 0.20)
	belt_mat.metallic = 0.65
	belt_mat.roughness = 0.30
	belt_mat.emission_enabled = true
	belt_mat.emission = Color(1.0, 0.75, 0.25)
	belt_mat.emission_energy_multiplier = 0.85
	belt.material_override = belt_mat
	mech.add_child(belt)
	# Helmet
	var helmet: MeshInstance3D = MeshInstance3D.new()
	var hmesh: SphereMesh = SphereMesh.new()
	hmesh.radius = 0.40
	hmesh.height = 0.55
	helmet.mesh = hmesh
	helmet.position = Vector3(0, 1.45, 0)
	var hmat: StandardMaterial3D = StandardMaterial3D.new()
	hmat.albedo_color = Color(1.0, 0.55, 0.10)
	hmat.metallic = 0.30
	hmat.roughness = 0.55
	hmat.emission_enabled = true
	hmat.emission = Color(1.0, 0.65, 0.15)
	hmat.emission_energy_multiplier = 0.40
	helmet.material_override = hmat
	mech.add_child(helmet)
	# 2 cyan eyes
	var eye_mat: StandardMaterial3D = StandardMaterial3D.new()
	eye_mat.albedo_color = Color(0.55, 0.95, 1.0)
	eye_mat.emission_enabled = true
	eye_mat.emission = Color(0.55, 0.95, 1.0)
	eye_mat.emission_energy_multiplier = 2.6
	eye_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for ex: float in [-0.10, 0.10]:
		var eye: MeshInstance3D = MeshInstance3D.new()
		var em: SphereMesh = SphereMesh.new()
		em.radius = 0.05
		em.height = 0.10
		eye.mesh = em
		eye.position = Vector3(ex, 1.30, 0.30)
		eye.material_override = eye_mat
		mech.add_child(eye)
	# Oversized wrench (thin handle + chunky head)
	var wrench_handle: MeshInstance3D = MeshInstance3D.new()
	var wh_mesh: BoxMesh = BoxMesh.new()
	wh_mesh.size = Vector3(0.08, 1.40, 0.08)
	wrench_handle.mesh = wh_mesh
	wrench_handle.position = Vector3(0.55, 0.85, 0)
	wrench_handle.rotation = Vector3(0, 0, deg_to_rad(-30))
	var wmat: StandardMaterial3D = StandardMaterial3D.new()
	wmat.albedo_color = Color(0.20, 0.22, 0.28)
	wmat.metallic = 0.85
	wmat.roughness = 0.30
	wrench_handle.material_override = wmat
	mech.add_child(wrench_handle)
	var wrench_head: MeshInstance3D = MeshInstance3D.new()
	var wh2_mesh: BoxMesh = BoxMesh.new()
	wh2_mesh.size = Vector3(0.30, 0.30, 0.18)
	wrench_head.mesh = wh2_mesh
	wrench_head.position = Vector3(0.85, 1.50, 0)
	wrench_head.rotation = Vector3(0, 0, deg_to_rad(-30))
	wrench_head.material_override = wmat
	mech.add_child(wrench_head)
	# Idle wrench swing tween
	var swing: Tween = create_tween().set_loops()
	swing.tween_property(wrench_handle, "rotation:z", deg_to_rad(-15), 1.4).set_ease(Tween.EASE_IN_OUT)
	swing.tween_property(wrench_handle, "rotation:z", deg_to_rad(-30), 1.4).set_ease(Tween.EASE_IN_OUT)
	# Name billboard
	var label: Label3D = Label3D.new()
	label.text = "Mechanic"
	label.position = Vector3(0, 2.0, 0)
	label.modulate = Color(1.0, 0.65, 0.20)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 18
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	mech.add_child(label)


static func _build_d2_parkour_course(geom: Node) -> void:
	## Epic-2 T71: a small parkour obstacle course in D2 — 4 jump pads of
	## ascending heights + 1 climb wall + a finish goal pad. Each pad has
	## glowing edge trim. Telegraphs traversal training without coding it.
	var course: Node3D = Node3D.new()
	course.name = "D2ParkourCourse"
	course.position = D2_CENTER + Vector3(-2, 0, 14)
	geom.add_child(course)
	var pad_mat: StandardMaterial3D = StandardMaterial3D.new()
	pad_mat.albedo_color = Color(0.16, 0.18, 0.22)
	pad_mat.metallic = 0.85
	pad_mat.roughness = 0.30
	var trim_mat: StandardMaterial3D = StandardMaterial3D.new()
	trim_mat.albedo_color = Color(0.55, 0.95, 1.0)
	trim_mat.emission_enabled = true
	trim_mat.emission = Color(0.55, 0.95, 1.0)
	trim_mat.emission_energy_multiplier = 1.8
	trim_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	# 4 jump pads at ascending heights
	for i in 4:
		var height: float = 0.5 + i * 0.45
		var pad: MeshInstance3D = MeshInstance3D.new()
		var pmesh: BoxMesh = BoxMesh.new()
		pmesh.size = Vector3(1.40, height, 1.40)
		pad.mesh = pmesh
		pad.position = Vector3(-3.0 + i * 1.85, height * 0.5, 0)
		pad.material_override = pad_mat
		course.add_child(pad)
		# Top trim ring (4 box edges)
		for spec in [
			[Vector3(0, height + 0.05, -0.70), Vector3(1.40, 0.06, 0.06)],
			[Vector3(0, height + 0.05, 0.70), Vector3(1.40, 0.06, 0.06)],
			[Vector3(-0.70, height + 0.05, 0), Vector3(0.06, 0.06, 1.40)],
			[Vector3(0.70, height + 0.05, 0), Vector3(0.06, 0.06, 1.40)],
		]:
			var edge: MeshInstance3D = MeshInstance3D.new()
			var em: BoxMesh = BoxMesh.new()
			em.size = spec[1]
			edge.mesh = em
			edge.position = Vector3(-3.0 + i * 1.85, 0, 0) + (spec[0] as Vector3)
			edge.material_override = trim_mat
			course.add_child(edge)
		# Per-pad collision
		var sb: StaticBody3D = StaticBody3D.new()
		var cs: CollisionShape3D = CollisionShape3D.new()
		var cb: BoxShape3D = BoxShape3D.new()
		cb.size = Vector3(1.40, height, 1.40)
		cs.shape = cb
		cs.position = Vector3(-3.0 + i * 1.85, height * 0.5, 0)
		sb.add_child(cs)
		course.add_child(sb)
	# Climb wall at the end
	var wall: MeshInstance3D = MeshInstance3D.new()
	var wmesh: BoxMesh = BoxMesh.new()
	wmesh.size = Vector3(2.40, 3.50, 0.30)
	wall.mesh = wmesh
	wall.position = Vector3(5.0, 1.75, 0)
	wall.material_override = pad_mat
	course.add_child(wall)
	# 6 hand-grip prisms across the wall
	for i in 6:
		var grip: MeshInstance3D = MeshInstance3D.new()
		var gmesh: PrismMesh = PrismMesh.new()
		gmesh.size = Vector3(0.20, 0.18, 0.18)
		grip.mesh = gmesh
		grip.position = Vector3(5.0 + (i % 2) * 0.40 - 0.20, 0.50 + i * 0.55, 0.18)
		grip.rotation = Vector3(0, 0, deg_to_rad(90))
		grip.material_override = trim_mat
		course.add_child(grip)
	# Wall collision
	var wsb: StaticBody3D = StaticBody3D.new()
	var wcs: CollisionShape3D = CollisionShape3D.new()
	var wcb: BoxShape3D = BoxShape3D.new()
	wcb.size = Vector3(2.40, 3.50, 0.30)
	wcs.shape = wcb
	wcs.position = Vector3(5.0, 1.75, 0)
	wsb.add_child(wcs)
	course.add_child(wsb)
	# Finish goal pad — bright green disc on the ground past the wall
	var goal: MeshInstance3D = MeshInstance3D.new()
	var gmesh: CylinderMesh = CylinderMesh.new()
	gmesh.top_radius = 0.85
	gmesh.bottom_radius = 0.85
	gmesh.height = 0.06
	goal.mesh = gmesh
	goal.position = Vector3(7.0, 0.05, 0)
	var gmat: StandardMaterial3D = StandardMaterial3D.new()
	gmat.albedo_color = Color(0.30, 1.0, 0.40)
	gmat.emission_enabled = true
	gmat.emission = Color(0.45, 1.0, 0.45)
	gmat.emission_energy_multiplier = 1.8
	gmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	goal.material_override = gmat
	course.add_child(goal)
	# "PARKOUR" sign overhead
	var label: Label3D = Label3D.new()
	label.text = "PARKOUR"
	label.position = Vector3(2.0, 4.40, 0)
	label.modulate = Color(0.55, 0.95, 1.0)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 22
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	course.add_child(label)


static func _build_d2_debris_belt(geom: Node) -> void:
	## Epic-2 T72: orbiting debris belt — 12 small chunks of metal
	## arranged in a horizontal ring at high altitude, all rotating around
	## the D2 center on a shared pivot tween.
	var belt_pivot: Node3D = Node3D.new()
	belt_pivot.name = "D2DebrisBelt"
	belt_pivot.position = D2_CENTER + Vector3(0, 16, 0)
	geom.add_child(belt_pivot)
	var chunk_mat: StandardMaterial3D = StandardMaterial3D.new()
	chunk_mat.albedo_color = Color(0.18, 0.16, 0.14)
	chunk_mat.metallic = 0.85
	chunk_mat.roughness = 0.40
	chunk_mat.emission_enabled = true
	chunk_mat.emission = Color(1.0, 0.40, 0.20)
	chunk_mat.emission_energy_multiplier = 0.45
	for i in 12:
		var angle: float = (float(i) / 12.0) * TAU
		var radius: float = 18.0
		var chunk: MeshInstance3D = MeshInstance3D.new()
		chunk.name = "DebrisChunk_%d" % i
		var cmesh: BoxMesh = BoxMesh.new()
		cmesh.size = Vector3(randf_range(0.55, 0.95), randf_range(0.20, 0.40), randf_range(0.55, 0.95))
		chunk.mesh = cmesh
		chunk.position = Vector3(cos(angle) * radius, randf_range(-0.5, 0.5), sin(angle) * radius)
		chunk.rotation = Vector3(deg_to_rad(randf_range(-30, 30)), randf() * TAU, deg_to_rad(randf_range(-30, 30)))
		chunk.material_override = chunk_mat
		belt_pivot.add_child(chunk)
	# Shared pivot rotation tween
	var spin: Tween = create_tween().set_loops()
	spin.tween_property(belt_pivot, "rotation:y", TAU, 24.0)


static func _build_d2_ruins(geom: Node) -> void:
	## Epic-2 T73: a cluster of ancient ruins — 4 broken stone pillars at
	## different heights + 1 partially intact arch (2 pillars + crumbling
	## lintel). Suggests this district once held an old structure.
	var ruins: Node3D = Node3D.new()
	ruins.name = "D2Ruins"
	ruins.position = D2_CENTER + Vector3(-12, 0, 12)
	geom.add_child(ruins)
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.30, 0.26, 0.22)
	stone_mat.metallic = 0.30
	stone_mat.roughness = 0.65
	# 4 broken pillars at different positions/heights
	var pillar_specs: Array = [
		[Vector3(-3.0, 0, -1.0), 2.40],
		[Vector3(-1.5, 0, 1.5), 1.85],
		[Vector3(0.5, 0, -1.5), 3.20],
		[Vector3(2.0, 0, 0.5), 2.10],
	]
	for spec in pillar_specs:
		var pos: Vector3 = spec[0]
		var height: float = spec[1]
		var pillar: MeshInstance3D = MeshInstance3D.new()
		var pmesh: CylinderMesh = CylinderMesh.new()
		pmesh.top_radius = 0.40
		pmesh.bottom_radius = 0.50
		pmesh.height = height
		pillar.mesh = pmesh
		pillar.position = pos + Vector3(0, height * 0.5, 0)
		pillar.rotation = Vector3(deg_to_rad(randf_range(-5, 5)), 0, deg_to_rad(randf_range(-5, 5)))
		pillar.material_override = stone_mat
		ruins.add_child(pillar)
		# Top "broken cap" — small angled cylinder
		var cap: MeshInstance3D = MeshInstance3D.new()
		var cmesh: CylinderMesh = CylinderMesh.new()
		cmesh.top_radius = 0.20
		cmesh.bottom_radius = 0.40
		cmesh.height = 0.30
		cap.mesh = cmesh
		cap.position = pos + Vector3(0, height + 0.15, 0)
		cap.rotation = Vector3(deg_to_rad(randf_range(-15, 15)), 0, deg_to_rad(randf_range(-15, 15)))
		cap.material_override = stone_mat
		ruins.add_child(cap)
		# Collision per pillar
		var sb: StaticBody3D = StaticBody3D.new()
		var cs: CollisionShape3D = CollisionShape3D.new()
		var cap_shape: CapsuleShape3D = CapsuleShape3D.new()
		cap_shape.radius = 0.50
		cap_shape.height = height
		cs.shape = cap_shape
		cs.position = pos + Vector3(0, height * 0.5, 0)
		sb.add_child(cs)
		ruins.add_child(sb)
	# Partially intact arch — 2 pillars + lintel
	for sx: float in [-4.5, -2.5]:
		var arch_pillar: MeshInstance3D = MeshInstance3D.new()
		var apm: BoxMesh = BoxMesh.new()
		apm.size = Vector3(0.55, 4.0, 0.55)
		arch_pillar.mesh = apm
		arch_pillar.position = Vector3(sx, 2.0, -3.5)
		arch_pillar.material_override = stone_mat
		ruins.add_child(arch_pillar)
		# Collision
		var sb: StaticBody3D = StaticBody3D.new()
		var cs: CollisionShape3D = CollisionShape3D.new()
		var cb: BoxShape3D = BoxShape3D.new()
		cb.size = Vector3(0.55, 4.0, 0.55)
		cs.shape = cb
		cs.position = Vector3(sx, 2.0, -3.5)
		sb.add_child(cs)
		ruins.add_child(sb)
	# Crumbling lintel — short slab on top with a missing chunk on one side
	var lintel: MeshInstance3D = MeshInstance3D.new()
	var lmesh: BoxMesh = BoxMesh.new()
	lmesh.size = Vector3(2.20, 0.55, 0.65)
	lintel.mesh = lmesh
	lintel.position = Vector3(-3.5, 4.30, -3.5)
	lintel.rotation = Vector3(0, 0, deg_to_rad(-3))
	lintel.material_override = stone_mat
	ruins.add_child(lintel)
	# Sign
	var label: Label3D = Label3D.new()
	label.text = "ANCIENT RUINS"
	label.position = Vector3(-3.5, 5.20, -3.5)
	label.modulate = Color(0.85, 0.85, 0.65)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 16
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	ruins.add_child(label)


static func _build_d2_reality_tear(geom: Node) -> void:
	## Epic-2 T74: a vertical "reality tear" — a tall thin emissive rift
	## that the simulation has torn open. 3 stacked elongated boxes at
	## random Z offsets, glitching color tween. Magenta/cyan duotone.
	var tear: Node3D = Node3D.new()
	tear.name = "D2RealityTear"
	tear.position = D2_CENTER + Vector3(15, 0, -3)
	geom.add_child(tear)
	# 3 stacked rift segments
	for i in 3:
		var seg: MeshInstance3D = MeshInstance3D.new()
		var smesh: BoxMesh = BoxMesh.new()
		smesh.size = Vector3(0.30, 2.20, 0.06)
		seg.mesh = smesh
		seg.position = Vector3(randf_range(-0.20, 0.20), 1.10 + i * 2.0, randf_range(-0.20, 0.20))
		seg.rotation = Vector3(0, deg_to_rad(randf_range(-25, 25)), 0)
		var mat: StandardMaterial3D = StandardMaterial3D.new()
		mat.albedo_color = Color(1.0, 0.30, 0.55)
		mat.emission_enabled = true
		mat.emission = Color(1.0, 0.30, 0.55)
		mat.emission_energy_multiplier = 3.4
		mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		seg.material_override = mat
		tear.add_child(seg)
		# Color cycle tween between magenta and cyan
		var cycle: Tween = create_tween().set_loops()
		cycle.tween_property(mat, "emission", Color(0.55, 0.95, 1.0), 1.4 + i * 0.2).set_ease(Tween.EASE_IN_OUT)
		cycle.tween_property(mat, "emission", Color(1.0, 0.30, 0.55), 1.4 + i * 0.2).set_ease(Tween.EASE_IN_OUT)
		# Tiny visibility flicker for glitch feel
		var flicker: Tween = create_tween().set_loops()
		flicker.tween_interval(2.0 + randf() * 1.0)
		flicker.tween_property(seg, "visible", false, 0.0)
		flicker.tween_interval(0.05)
		flicker.tween_property(seg, "visible", true, 0.0)
	# Floating "RIFT" label
	var label: Label3D = Label3D.new()
	label.text = "RIFT"
	label.position = Vector3(0, 7.20, 0)
	label.modulate = Color(1.0, 0.40, 0.65)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 22
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	tear.add_child(label)


static func _build_d2_glitch_rain(geom: Node) -> void:
	## Epic-2 T75: glitch rain — magenta GPU particles falling through D2
	## with light gravity, looking like distorted simulation rain.
	var rain: GPUParticles3D = GPUParticles3D.new()
	rain.name = "D2GlitchRain"
	rain.position = D2_CENTER + Vector3(0, 14, 0)
	rain.amount = 120
	rain.lifetime = 5.0
	rain.preprocess = 2.5
	var pmat: ParticleProcessMaterial = ParticleProcessMaterial.new()
	pmat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	pmat.emission_box_extents = Vector3(22, 0.5, 18)
	pmat.direction = Vector3(0, -1, 0)
	pmat.spread = 4.0
	pmat.initial_velocity_min = 1.4
	pmat.initial_velocity_max = 2.4
	pmat.gravity = Vector3(0, -2.0, 0)
	pmat.scale_min = 0.04
	pmat.scale_max = 0.10
	pmat.color = Color(1.0, 0.30, 0.55, 1.0)
	rain.process_material = pmat
	var drop_mesh: BoxMesh = BoxMesh.new()
	drop_mesh.size = Vector3(0.04, 0.18, 0.04)
	var drop_mat: StandardMaterial3D = StandardMaterial3D.new()
	drop_mat.albedo_color = Color(1.0, 0.30, 0.55)
	drop_mat.emission_enabled = true
	drop_mat.emission = Color(1.0, 0.40, 0.65)
	drop_mat.emission_energy_multiplier = 2.6
	drop_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	drop_mesh.material = drop_mat
	rain.draw_pass_1 = drop_mesh
	geom.add_child(rain)


static func _build_d2_mail_terminal(geom: Node) -> void:
	## Epic-2 T76: a small mail / message terminal kiosk. Tall thin box
	## with a slot opening, an indicator light showing "new mail", and an
	## envelope icon Label3D on the front.
	var term: Node3D = Node3D.new()
	term.name = "D2MailTerminal"
	term.position = D2_CENTER + Vector3(-12, 0, -3)
	geom.add_child(term)
	# Body box
	var body_mat: StandardMaterial3D = StandardMaterial3D.new()
	body_mat.albedo_color = Color(0.20, 0.18, 0.30)
	body_mat.metallic = 0.65
	body_mat.roughness = 0.40
	body_mat.emission_enabled = true
	body_mat.emission = Color(0.40, 0.30, 0.85)
	body_mat.emission_energy_multiplier = 0.40
	var body: MeshInstance3D = MeshInstance3D.new()
	var bmesh: BoxMesh = BoxMesh.new()
	bmesh.size = Vector3(0.65, 1.85, 0.55)
	body.mesh = bmesh
	body.position = Vector3(0, 0.92, 0)
	body.material_override = body_mat
	term.add_child(body)
	# Mail slot — dark recess
	var slot: MeshInstance3D = MeshInstance3D.new()
	var smesh: BoxMesh = BoxMesh.new()
	smesh.size = Vector3(0.45, 0.10, 0.04)
	slot.mesh = smesh
	slot.position = Vector3(0, 1.40, 0.27)
	var smat: StandardMaterial3D = StandardMaterial3D.new()
	smat.albedo_color = Color(0.04, 0.04, 0.06)
	smat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	slot.material_override = smat
	term.add_child(slot)
	# "NEW MAIL" indicator light (small pulsing yellow sphere)
	var indicator: MeshInstance3D = MeshInstance3D.new()
	var im: SphereMesh = SphereMesh.new()
	im.radius = 0.06
	im.height = 0.12
	indicator.mesh = im
	indicator.position = Vector3(0, 1.62, 0.27)
	var imat: StandardMaterial3D = StandardMaterial3D.new()
	imat.albedo_color = Color(1.0, 0.95, 0.30)
	imat.emission_enabled = true
	imat.emission = Color(1.0, 0.95, 0.30)
	imat.emission_energy_multiplier = 2.6
	imat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	indicator.material_override = imat
	term.add_child(indicator)
	var pulse: Tween = create_tween().set_loops()
	pulse.tween_property(indicator, "scale", Vector3(1.4, 1.4, 1.4), 0.6).set_ease(Tween.EASE_IN_OUT)
	pulse.tween_property(indicator, "scale", Vector3(0.8, 0.8, 0.8), 0.6).set_ease(Tween.EASE_IN_OUT)
	# Envelope icon label on the front
	var icon: Label3D = Label3D.new()
	icon.text = "✉"
	icon.position = Vector3(0, 1.0, 0.30)
	icon.modulate = Color(1.0, 0.95, 0.55)
	icon.outline_modulate = Color(0, 0, 0, 0.85)
	icon.outline_size = 4
	icon.font_size = 28
	icon.no_depth_test = true
	term.add_child(icon)
	# Sign above
	var label: Label3D = Label3D.new()
	label.text = "MAIL"
	label.position = Vector3(0, 2.10, 0)
	label.modulate = Color(0.85, 0.75, 1.0)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 16
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	term.add_child(label)
	# Collision
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(0.65, 1.85, 0.55)
	cs.shape = cb
	cs.position = Vector3(0, 0.92, 0)
	sb.add_child(cs)
	term.add_child(sb)


static func _build_d2_trading_post(geom: Node) -> void:
	## Epic-2 T77: a permanent trading post building — small storefront
	## hut with a sloped roof, a counter window cut into the front, and
	## glowing "OPEN" sign hanging beside it.
	var post: Node3D = Node3D.new()
	post.name = "D2TradingPost"
	post.position = D2_CENTER + Vector3(2, 0, -8)
	geom.add_child(post)
	# Walls — single wide box
	var wall_mat: StandardMaterial3D = StandardMaterial3D.new()
	wall_mat.albedo_color = Color(0.30, 0.22, 0.16)
	wall_mat.metallic = 0.20
	wall_mat.roughness = 0.65
	wall_mat.emission_enabled = true
	wall_mat.emission = Color(0.85, 0.55, 0.20)
	wall_mat.emission_energy_multiplier = 0.30
	var hut: MeshInstance3D = MeshInstance3D.new()
	var hmesh: BoxMesh = BoxMesh.new()
	hmesh.size = Vector3(3.40, 2.80, 2.40)
	hut.mesh = hmesh
	hut.position = Vector3(0, 1.40, 0)
	hut.material_override = wall_mat
	post.add_child(hut)
	# Sloped roof — prism on top
	var roof_mat: StandardMaterial3D = StandardMaterial3D.new()
	roof_mat.albedo_color = Color(0.45, 0.20, 0.12)
	roof_mat.metallic = 0.20
	roof_mat.roughness = 0.55
	var roof: MeshInstance3D = MeshInstance3D.new()
	var rmesh: PrismMesh = PrismMesh.new()
	rmesh.size = Vector3(3.60, 0.85, 2.60)
	roof.mesh = rmesh
	roof.position = Vector3(0, 3.20, 0)
	roof.material_override = roof_mat
	post.add_child(roof)
	# Counter window cut into front (a dark recessed box)
	var window: MeshInstance3D = MeshInstance3D.new()
	var wmesh: BoxMesh = BoxMesh.new()
	wmesh.size = Vector3(1.85, 0.85, 0.10)
	window.mesh = wmesh
	window.position = Vector3(0, 1.40, 1.21)
	var winmat: StandardMaterial3D = StandardMaterial3D.new()
	winmat.albedo_color = Color(0.05, 0.04, 0.10)
	winmat.emission_enabled = true
	winmat.emission = Color(0.85, 0.55, 0.20)
	winmat.emission_energy_multiplier = 0.55
	winmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	window.material_override = winmat
	post.add_child(window)
	# Counter board below the window
	var counter: MeshInstance3D = MeshInstance3D.new()
	var cmesh: BoxMesh = BoxMesh.new()
	cmesh.size = Vector3(2.0, 0.10, 0.45)
	counter.mesh = cmesh
	counter.position = Vector3(0, 0.95, 1.30)
	counter.material_override = roof_mat
	post.add_child(counter)
	# Hanging "OPEN" sign on the side
	var sign_panel: MeshInstance3D = MeshInstance3D.new()
	var sm: BoxMesh = BoxMesh.new()
	sm.size = Vector3(0.85, 0.40, 0.05)
	sign_panel.mesh = sm
	sign_panel.position = Vector3(1.85, 1.85, 1.0)
	var spmat: StandardMaterial3D = StandardMaterial3D.new()
	spmat.albedo_color = Color(0.30, 1.0, 0.40)
	spmat.emission_enabled = true
	spmat.emission = Color(0.45, 1.0, 0.45)
	spmat.emission_energy_multiplier = 1.6
	spmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	sign_panel.material_override = spmat
	post.add_child(sign_panel)
	var open_label: Label3D = Label3D.new()
	open_label.text = "OPEN"
	open_label.position = Vector3(1.85, 1.85, 1.04)
	open_label.modulate = Color(1, 1, 1)
	open_label.outline_modulate = Color(0, 0, 0, 0.85)
	open_label.outline_size = 4
	open_label.font_size = 16
	open_label.no_depth_test = true
	post.add_child(open_label)
	# Big "TRADING POST" sign on the roof
	var label: Label3D = Label3D.new()
	label.text = "TRADING POST"
	label.position = Vector3(0, 4.0, 0)
	label.modulate = Color(1.0, 0.85, 0.30)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 22
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	post.add_child(label)
	# Collision around the hut
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(3.40, 2.80, 2.40)
	cs.shape = cb
	cs.position = Vector3(0, 1.40, 0)
	sb.add_child(cs)
	post.add_child(sb)


static func _build_d2_playground(geom: Node) -> void:
	## Epic-2 T78: an eerie abandoned playground — a single swing on a
	## rusty frame swaying gently in the wind + a small slide. The sense
	## of "kids used to live here" before the district fell.
	var play: Node3D = Node3D.new()
	play.name = "D2Playground"
	play.position = D2_CENTER + Vector3(-18, 0, 18)
	geom.add_child(play)
	var rust_mat: StandardMaterial3D = StandardMaterial3D.new()
	rust_mat.albedo_color = Color(0.40, 0.20, 0.10)
	rust_mat.metallic = 0.40
	rust_mat.roughness = 0.65
	# Swing frame — 2 angled legs + horizontal top bar
	for sx: float in [-1.20, 1.20]:
		var leg: MeshInstance3D = MeshInstance3D.new()
		var lmesh: CylinderMesh = CylinderMesh.new()
		lmesh.top_radius = 0.07
		lmesh.bottom_radius = 0.10
		lmesh.height = 2.40
		leg.mesh = lmesh
		leg.position = Vector3(sx, 1.20, 0)
		leg.rotation = Vector3(0, 0, sign(sx) * deg_to_rad(15))
		leg.material_override = rust_mat
		play.add_child(leg)
	# Top bar
	var top_bar: MeshInstance3D = MeshInstance3D.new()
	var tbmesh: CylinderMesh = CylinderMesh.new()
	tbmesh.top_radius = 0.06
	tbmesh.bottom_radius = 0.06
	tbmesh.height = 2.40
	top_bar.mesh = tbmesh
	top_bar.position = Vector3(0, 2.40, 0)
	top_bar.rotation = Vector3(0, 0, deg_to_rad(90))
	top_bar.material_override = rust_mat
	play.add_child(top_bar)
	# Swing pivot at top center
	var swing_pivot: Node3D = Node3D.new()
	swing_pivot.position = Vector3(0, 2.40, 0)
	play.add_child(swing_pivot)
	# Swing chains + seat
	for sx: float in [-0.30, 0.30]:
		var chain: MeshInstance3D = MeshInstance3D.new()
		var ch_mesh: CylinderMesh = CylinderMesh.new()
		ch_mesh.top_radius = 0.02
		ch_mesh.bottom_radius = 0.02
		ch_mesh.height = 1.30
		chain.mesh = ch_mesh
		chain.position = Vector3(sx, -0.65, 0)
		chain.material_override = rust_mat
		swing_pivot.add_child(chain)
	var seat: MeshInstance3D = MeshInstance3D.new()
	var seat_mesh: BoxMesh = BoxMesh.new()
	seat_mesh.size = Vector3(0.85, 0.06, 0.30)
	seat.mesh = seat_mesh
	seat.position = Vector3(0, -1.30, 0)
	var seat_mat: StandardMaterial3D = StandardMaterial3D.new()
	seat_mat.albedo_color = Color(0.20, 0.16, 0.12)
	seat_mat.metallic = 0.20
	seat.material_override = seat_mat
	swing_pivot.add_child(seat)
	# Sway tween
	var sway: Tween = create_tween().set_loops()
	sway.tween_property(swing_pivot, "rotation:x", deg_to_rad(15), 1.4).set_ease(Tween.EASE_IN_OUT)
	sway.tween_property(swing_pivot, "rotation:x", deg_to_rad(-15), 1.4).set_ease(Tween.EASE_IN_OUT)
	# Small slide nearby — angled box
	var slide: MeshInstance3D = MeshInstance3D.new()
	var sl_mesh: BoxMesh = BoxMesh.new()
	sl_mesh.size = Vector3(0.85, 0.10, 2.60)
	slide.mesh = sl_mesh
	slide.position = Vector3(3.5, 0.85, 0)
	slide.rotation = Vector3(deg_to_rad(-30), 0, 0)
	var sl_mat: StandardMaterial3D = StandardMaterial3D.new()
	sl_mat.albedo_color = Color(0.85, 0.85, 0.95)
	sl_mat.metallic = 0.65
	sl_mat.roughness = 0.30
	slide.material_override = sl_mat
	play.add_child(slide)
	# Slide top platform
	var platform: MeshInstance3D = MeshInstance3D.new()
	var pl_mesh: BoxMesh = BoxMesh.new()
	pl_mesh.size = Vector3(0.85, 0.10, 0.85)
	platform.mesh = pl_mesh
	platform.position = Vector3(3.5, 1.85, -1.20)
	platform.material_override = sl_mat
	play.add_child(platform)
	# Slide ladder (angled)
	var ladder: MeshInstance3D = MeshInstance3D.new()
	var ld_mesh: BoxMesh = BoxMesh.new()
	ld_mesh.size = Vector3(0.45, 0.06, 1.85)
	ladder.mesh = ld_mesh
	ladder.position = Vector3(3.5, 0.95, -1.85)
	ladder.rotation = Vector3(deg_to_rad(60), 0, 0)
	ladder.material_override = rust_mat
	play.add_child(ladder)


static func _build_d2_data_scrolls(geom: Node) -> void:
	## Epic-2 T79: 5 floating data archive scrolls — vertical translucent
	## strips with code-like symbols on them, drifting in a small cluster
	## near the data well.
	var origin: Vector3 = D2_CENTER + Vector3(0, 1.5, 6)
	for i in 5:
		var scroll: MeshInstance3D = MeshInstance3D.new()
		scroll.name = "D2DataScroll_%d" % i
		var smesh: BoxMesh = BoxMesh.new()
		smesh.size = Vector3(0.30, 1.40, 0.04)
		scroll.mesh = smesh
		scroll.position = origin + Vector3(randf_range(-1.5, 1.5), randf_range(0, 0.85), randf_range(-1.5, 1.5))
		scroll.rotation = Vector3(0, deg_to_rad(randf_range(0, 360)), 0)
		var mat: StandardMaterial3D = StandardMaterial3D.new()
		mat.albedo_color = Color(0.55, 0.95, 1.0, 0.65)
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		mat.emission_enabled = true
		mat.emission = Color(0.55, 0.95, 1.0)
		mat.emission_energy_multiplier = 1.4
		mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		scroll.material_override = mat
		geom.add_child(scroll)
		# Slow rotation
		var spin: Tween = create_tween().set_loops()
		spin.tween_property(scroll, "rotation:y", scroll.rotation.y + TAU, 8.0 + i)
		# Slow vertical bob
		var bob: Tween = create_tween().set_loops()
		var origin_y: float = scroll.position.y
		bob.tween_property(scroll, "position:y", origin_y + 0.30, 1.6 + i * 0.2).set_ease(Tween.EASE_IN_OUT)
		bob.tween_property(scroll, "position:y", origin_y, 1.6 + i * 0.2).set_ease(Tween.EASE_IN_OUT)


static func _build_d2_enchanter_npc(town: Node) -> void:
	## Epic-2 T80: enchanter NPC standing with 4 small rune cubes orbiting
	## their head on a horizontal ring. Robed figure with a glowing violet
	## staff. The "magical" archetype contrasting the more mechanical NPCs.
	var slots: Node3D = town.get_node_or_null("%NPCSlots") as Node3D
	if slots == null:
		return
	var enc: Node3D = Node3D.new()
	enc.name = "D2Enchanter"
	enc.position = D2_CENTER + Vector3(8, 0, 8)
	slots.add_child(enc)
	# Body — robed capsule
	var bmat: StandardMaterial3D = StandardMaterial3D.new()
	bmat.albedo_color = Color(0.20, 0.10, 0.30)
	bmat.metallic = 0.30
	bmat.roughness = 0.55
	bmat.emission_enabled = true
	bmat.emission = Color(0.55, 0.30, 0.85)
	bmat.emission_energy_multiplier = 0.40
	var body: MeshInstance3D = MeshInstance3D.new()
	var bmesh: CapsuleMesh = CapsuleMesh.new()
	bmesh.radius = 0.45
	bmesh.height = 1.40
	body.mesh = bmesh
	body.position = Vector3(0, 0.70, 0)
	body.material_override = bmat
	enc.add_child(body)
	# Hood
	var hood: MeshInstance3D = MeshInstance3D.new()
	var hmesh: SphereMesh = SphereMesh.new()
	hmesh.radius = 0.45
	hmesh.height = 0.55
	hood.mesh = hmesh
	hood.position = Vector3(0, 1.55, 0)
	hood.material_override = bmat
	enc.add_child(hood)
	# 2 small violet eyes
	var eye_mat: StandardMaterial3D = StandardMaterial3D.new()
	eye_mat.albedo_color = Color(0.85, 0.40, 1.0)
	eye_mat.emission_enabled = true
	eye_mat.emission = Color(1.0, 0.55, 1.0)
	eye_mat.emission_energy_multiplier = 2.6
	eye_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for ex: float in [-0.10, 0.10]:
		var eye: MeshInstance3D = MeshInstance3D.new()
		var em: SphereMesh = SphereMesh.new()
		em.radius = 0.05
		em.height = 0.10
		eye.mesh = em
		eye.position = Vector3(ex, 1.40, 0.34)
		eye.material_override = eye_mat
		enc.add_child(eye)
	# Staff in front of the body — long thin cylinder
	var staff: MeshInstance3D = MeshInstance3D.new()
	var smesh: CylinderMesh = CylinderMesh.new()
	smesh.top_radius = 0.05
	smesh.bottom_radius = 0.06
	smesh.height = 2.0
	staff.mesh = smesh
	staff.position = Vector3(0.45, 1.0, 0)
	var stmat: StandardMaterial3D = StandardMaterial3D.new()
	stmat.albedo_color = Color(0.10, 0.06, 0.10)
	stmat.metallic = 0.30
	staff.material_override = stmat
	enc.add_child(staff)
	# Staff orb on top
	var orb: MeshInstance3D = MeshInstance3D.new()
	var om: SphereMesh = SphereMesh.new()
	om.radius = 0.20
	om.height = 0.40
	orb.mesh = om
	orb.position = Vector3(0.45, 2.10, 0)
	var omat: StandardMaterial3D = StandardMaterial3D.new()
	omat.albedo_color = Color(0.85, 0.40, 1.0)
	omat.emission_enabled = true
	omat.emission = Color(1.0, 0.55, 1.0)
	omat.emission_energy_multiplier = 2.6
	omat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	orb.material_override = omat
	enc.add_child(orb)
	# Pulse the orb
	var pulse: Tween = create_tween().set_loops()
	pulse.tween_property(orb, "scale", Vector3(1.30, 1.30, 1.30), 1.0).set_ease(Tween.EASE_IN_OUT)
	pulse.tween_property(orb, "scale", Vector3(1.0, 1.0, 1.0), 1.0).set_ease(Tween.EASE_IN_OUT)
	# 4 orbiting rune cubes — pivot at the head, cubes at TAU/4 spacings
	var rune_pivot: Node3D = Node3D.new()
	rune_pivot.position = Vector3(0, 2.10, 0)
	enc.add_child(rune_pivot)
	for i in 4:
		var angle: float = (float(i) / 4.0) * TAU
		var rune: MeshInstance3D = MeshInstance3D.new()
		var rmesh: BoxMesh = BoxMesh.new()
		rmesh.size = Vector3(0.18, 0.18, 0.18)
		rune.mesh = rmesh
		rune.position = Vector3(cos(angle) * 0.65, 0, sin(angle) * 0.65)
		var rmat: StandardMaterial3D = StandardMaterial3D.new()
		var color: Color = [Color(0.55, 0.95, 1.0), Color(1.0, 0.55, 0.20), Color(0.85, 0.40, 1.0), Color(0.45, 1.0, 0.55)][i]
		rmat.albedo_color = color
		rmat.emission_enabled = true
		rmat.emission = color
		rmat.emission_energy_multiplier = 2.4
		rmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		rune.material_override = rmat
		rune_pivot.add_child(rune)
	# Pivot rotation
	var spin: Tween = create_tween().set_loops()
	spin.tween_property(rune_pivot, "rotation:y", TAU, 4.0)
	# Name billboard
	var label: Label3D = Label3D.new()
	label.text = "Enchanter"
	label.position = Vector3(0, 2.55, 0)
	label.modulate = Color(0.85, 0.55, 1.0)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 18
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	enc.add_child(label)


static func _build_d2_hospital_wing(geom: Node) -> void:
	## Epic-2 T81: a small hospital wing building next to the med tent.
	## Wider concrete structure with red cross emblem on the front + a
	## glowing entryway and 2 small upper windows.
	var wing: Node3D = Node3D.new()
	wing.name = "D2HospitalWing"
	wing.position = D2_CENTER + Vector3(-12, 0, 14)
	geom.add_child(wing)
	# Main building
	var wall_mat: StandardMaterial3D = StandardMaterial3D.new()
	wall_mat.albedo_color = Color(0.85, 0.85, 0.92)
	wall_mat.metallic = 0.20
	wall_mat.roughness = 0.55
	wall_mat.emission_enabled = true
	wall_mat.emission = Color(0.95, 0.95, 1.0)
	wall_mat.emission_energy_multiplier = 0.30
	var building: MeshInstance3D = MeshInstance3D.new()
	var bmesh: BoxMesh = BoxMesh.new()
	bmesh.size = Vector3(3.40, 3.20, 2.40)
	building.mesh = bmesh
	building.position = Vector3(0, 1.60, 0)
	building.material_override = wall_mat
	wing.add_child(building)
	# Flat roof slab
	var roof_mat: StandardMaterial3D = StandardMaterial3D.new()
	roof_mat.albedo_color = Color(0.55, 0.55, 0.65)
	roof_mat.metallic = 0.30
	var roof: MeshInstance3D = MeshInstance3D.new()
	var rmesh: BoxMesh = BoxMesh.new()
	rmesh.size = Vector3(3.65, 0.20, 2.65)
	roof.mesh = rmesh
	roof.position = Vector3(0, 3.30, 0)
	roof.material_override = roof_mat
	wing.add_child(roof)
	# Big red cross emblem on the front face
	var cross_mat: StandardMaterial3D = StandardMaterial3D.new()
	cross_mat.albedo_color = Color(1.0, 0.20, 0.20)
	cross_mat.emission_enabled = true
	cross_mat.emission = Color(1.0, 0.30, 0.30)
	cross_mat.emission_energy_multiplier = 1.8
	cross_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var v_bar: MeshInstance3D = MeshInstance3D.new()
	var vm: BoxMesh = BoxMesh.new()
	vm.size = Vector3(0.30, 1.40, 0.10)
	v_bar.mesh = vm
	v_bar.position = Vector3(0, 2.30, 1.21)
	v_bar.material_override = cross_mat
	wing.add_child(v_bar)
	var h_bar: MeshInstance3D = MeshInstance3D.new()
	var hm: BoxMesh = BoxMesh.new()
	hm.size = Vector3(1.0, 0.30, 0.10)
	h_bar.mesh = hm
	h_bar.position = Vector3(0, 2.30, 1.21)
	h_bar.material_override = cross_mat
	wing.add_child(h_bar)
	# Glowing entryway — dark recessed door with cyan light frame
	var door: MeshInstance3D = MeshInstance3D.new()
	var dmesh: BoxMesh = BoxMesh.new()
	dmesh.size = Vector3(0.85, 1.40, 0.10)
	door.mesh = dmesh
	door.position = Vector3(0, 0.80, 1.21)
	var dmat: StandardMaterial3D = StandardMaterial3D.new()
	dmat.albedo_color = Color(0.06, 0.10, 0.16)
	dmat.emission_enabled = true
	dmat.emission = Color(0.55, 0.95, 1.0)
	dmat.emission_energy_multiplier = 0.85
	dmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	door.material_override = dmat
	wing.add_child(door)
	# Door frame trim — 4 cyan emissive bars
	var trim_mat: StandardMaterial3D = StandardMaterial3D.new()
	trim_mat.albedo_color = Color(0.55, 0.95, 1.0)
	trim_mat.emission_enabled = true
	trim_mat.emission = Color(0.55, 0.95, 1.0)
	trim_mat.emission_energy_multiplier = 1.6
	trim_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for spec in [
		[Vector3(0, 0.10, 1.22), Vector3(0.95, 0.05, 0.04)],
		[Vector3(0, 1.50, 1.22), Vector3(0.95, 0.05, 0.04)],
		[Vector3(-0.45, 0.80, 1.22), Vector3(0.05, 1.40, 0.04)],
		[Vector3(0.45, 0.80, 1.22), Vector3(0.05, 1.40, 0.04)],
	]:
		var bar: MeshInstance3D = MeshInstance3D.new()
		var bmesh2: BoxMesh = BoxMesh.new()
		bmesh2.size = spec[1]
		bar.mesh = bmesh2
		bar.position = spec[0]
		bar.material_override = trim_mat
		wing.add_child(bar)
	# 2 upper window squares
	for sx: float in [-0.95, 0.95]:
		var win: MeshInstance3D = MeshInstance3D.new()
		var wm2: BoxMesh = BoxMesh.new()
		wm2.size = Vector3(0.55, 0.45, 0.04)
		win.mesh = wm2
		win.position = Vector3(sx, 2.85, 1.22)
		var wmat2: StandardMaterial3D = StandardMaterial3D.new()
		wmat2.albedo_color = Color(0.95, 0.85, 0.55)
		wmat2.emission_enabled = true
		wmat2.emission = Color(1.0, 0.85, 0.55)
		wmat2.emission_energy_multiplier = 1.4
		wmat2.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		win.material_override = wmat2
		wing.add_child(win)
	# Sign
	var label: Label3D = Label3D.new()
	label.text = "HOSPITAL"
	label.position = Vector3(0, 4.0, 0)
	label.modulate = Color(1.0, 0.30, 0.30)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 22
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	wing.add_child(label)
	# Collision around the building
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(3.40, 3.20, 2.40)
	cs.shape = cb
	cs.position = Vector3(0, 1.60, 0)
	sb.add_child(cs)
	wing.add_child(sb)


static func _build_d2_garage(geom: Node) -> void:
	## Epic-2 T82: a garage building with an open roll-up door, revealing
	## a small hover-vehicle stored inside. Big rusty metal walls + slot
	## for the door + a half-built bike on the floor.
	var garage: Node3D = Node3D.new()
	garage.name = "D2Garage"
	garage.position = D2_CENTER + Vector3(-18, 0, -8)
	geom.add_child(garage)
	# Walls — concrete sides
	var wall_mat: StandardMaterial3D = StandardMaterial3D.new()
	wall_mat.albedo_color = Color(0.30, 0.30, 0.34)
	wall_mat.metallic = 0.30
	wall_mat.roughness = 0.65
	# Back wall
	var back: MeshInstance3D = MeshInstance3D.new()
	var bm: BoxMesh = BoxMesh.new()
	bm.size = Vector3(3.40, 2.85, 0.20)
	back.mesh = bm
	back.position = Vector3(0, 1.42, -1.20)
	back.material_override = wall_mat
	garage.add_child(back)
	# Side walls
	for sx: float in [-1.70, 1.70]:
		var side: MeshInstance3D = MeshInstance3D.new()
		var sm2: BoxMesh = BoxMesh.new()
		sm2.size = Vector3(0.20, 2.85, 2.60)
		side.mesh = sm2
		side.position = Vector3(sx, 1.42, 0)
		side.material_override = wall_mat
		garage.add_child(side)
	# Roof
	var roof: MeshInstance3D = MeshInstance3D.new()
	var rm: BoxMesh = BoxMesh.new()
	rm.size = Vector3(3.60, 0.20, 2.80)
	roof.mesh = rm
	roof.position = Vector3(0, 2.95, 0)
	roof.material_override = wall_mat
	garage.add_child(roof)
	# Half-rolled door — sits at the top of the front opening
	var door_mat: StandardMaterial3D = StandardMaterial3D.new()
	door_mat.albedo_color = Color(0.40, 0.20, 0.10)
	door_mat.metallic = 0.40
	door_mat.roughness = 0.55
	var door: MeshInstance3D = MeshInstance3D.new()
	var dm: BoxMesh = BoxMesh.new()
	dm.size = Vector3(3.40, 0.85, 0.10)
	door.mesh = dm
	door.position = Vector3(0, 2.40, 1.20)
	door.material_override = door_mat
	garage.add_child(door)
	# Half-built bike inside (small bike body box)
	var bike_mat: StandardMaterial3D = StandardMaterial3D.new()
	bike_mat.albedo_color = Color(0.20, 0.22, 0.28)
	bike_mat.metallic = 0.85
	bike_mat.roughness = 0.30
	var bike: MeshInstance3D = MeshInstance3D.new()
	var bk_mesh: BoxMesh = BoxMesh.new()
	bk_mesh.size = Vector3(1.40, 0.40, 0.55)
	bike.mesh = bk_mesh
	bike.position = Vector3(0, 0.30, -0.20)
	bike.rotation = Vector3(0, deg_to_rad(20), 0)
	bike.material_override = bike_mat
	garage.add_child(bike)
	# Bike engine glow
	var engine: MeshInstance3D = MeshInstance3D.new()
	var em: SphereMesh = SphereMesh.new()
	em.radius = 0.18
	em.height = 0.36
	engine.mesh = em
	engine.position = Vector3(-0.45, 0.30, -0.20)
	var emat: StandardMaterial3D = StandardMaterial3D.new()
	emat.albedo_color = Color(1.0, 0.40, 0.20)
	emat.emission_enabled = true
	emat.emission = Color(1.0, 0.55, 0.20)
	emat.emission_energy_multiplier = 2.4
	emat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	engine.material_override = emat
	garage.add_child(engine)
	# Sign
	var label: Label3D = Label3D.new()
	label.text = "GARAGE"
	label.position = Vector3(0, 3.55, 0)
	label.modulate = Color(1.0, 0.55, 0.20)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 18
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	garage.add_child(label)
	# Collision around walls
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(3.40, 2.85, 2.60)
	cs.shape = cb
	cs.position = Vector3(0, 1.42, 0)
	sb.add_child(cs)
	garage.add_child(sb)


static func _build_d2_library_ruins(geom: Node) -> void:
	## Epic-2 T83: collapsed library — 3 broken bookshelf boxes leaning at
	## angles + 4 floating "data tomes" hovering above them. Lore element
	## telling "knowledge was destroyed here".
	var lib: Node3D = Node3D.new()
	lib.name = "D2LibraryRuins"
	lib.position = D2_CENTER + Vector3(6, 0, 16)
	geom.add_child(lib)
	# 3 shelves leaning
	var shelf_mat: StandardMaterial3D = StandardMaterial3D.new()
	shelf_mat.albedo_color = Color(0.30, 0.18, 0.10)
	shelf_mat.metallic = 0.10
	shelf_mat.roughness = 0.65
	var shelf_specs: Array = [
		[Vector3(-1.5, 1.10, 0), Vector3(0, 0, deg_to_rad(-12))],
		[Vector3(0, 1.10, 0.55), Vector3(0, deg_to_rad(15), deg_to_rad(8))],
		[Vector3(1.5, 1.10, -0.30), Vector3(0, deg_to_rad(-25), deg_to_rad(15))],
	]
	for spec in shelf_specs:
		var shelf: MeshInstance3D = MeshInstance3D.new()
		var smesh: BoxMesh = BoxMesh.new()
		smesh.size = Vector3(1.0, 2.20, 0.40)
		shelf.mesh = smesh
		shelf.position = spec[0]
		shelf.rotation = spec[1]
		shelf.material_override = shelf_mat
		lib.add_child(shelf)
		# 3 colored book "row" boxes inside the shelf
		for i in 3:
			var book_color: Color = [Color(0.55, 0.30, 0.30), Color(0.30, 0.55, 0.30), Color(0.30, 0.30, 0.55)][i]
			var book: MeshInstance3D = MeshInstance3D.new()
			var bk: BoxMesh = BoxMesh.new()
			bk.size = Vector3(0.85, 0.55, 0.30)
			book.mesh = bk
			book.position = (spec[0] as Vector3) + Vector3(0, -0.65 + i * 0.55, 0)
			book.rotation = spec[1]
			var bmat: StandardMaterial3D = StandardMaterial3D.new()
			bmat.albedo_color = book_color
			bmat.metallic = 0.10
			book.material_override = bmat
			lib.add_child(book)
		# Collision per shelf
		var sb: StaticBody3D = StaticBody3D.new()
		var cs: CollisionShape3D = CollisionShape3D.new()
		var cb: BoxShape3D = BoxShape3D.new()
		cb.size = Vector3(1.0, 2.20, 0.40)
		cs.shape = cb
		cs.position = spec[0]
		sb.add_child(cs)
		lib.add_child(sb)
	# 4 floating data tomes hovering above
	var tome_mat: StandardMaterial3D = StandardMaterial3D.new()
	tome_mat.albedo_color = Color(0.85, 0.40, 1.0)
	tome_mat.emission_enabled = true
	tome_mat.emission = Color(1.0, 0.55, 1.0)
	tome_mat.emission_energy_multiplier = 1.8
	tome_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for i in 4:
		var tome: MeshInstance3D = MeshInstance3D.new()
		var tmesh: BoxMesh = BoxMesh.new()
		tmesh.size = Vector3(0.40, 0.30, 0.10)
		tome.mesh = tmesh
		var origin_y: float = 3.0 + (i % 2) * 0.55
		tome.position = Vector3(-1.5 + i * 0.85, origin_y, 0)
		tome.material_override = tome_mat
		lib.add_child(tome)
		# Bob + spin
		var bob: Tween = create_tween().set_loops()
		bob.tween_property(tome, "position:y", origin_y + 0.30, 1.4 + i * 0.15).set_ease(Tween.EASE_IN_OUT)
		bob.tween_property(tome, "position:y", origin_y, 1.4 + i * 0.15).set_ease(Tween.EASE_IN_OUT)
		var spin: Tween = create_tween().set_loops()
		spin.tween_property(tome, "rotation:y", TAU, 6.0)
	# Sign
	var label: Label3D = Label3D.new()
	label.text = "LIBRARY RUINS"
	label.position = Vector3(0, 4.40, 0)
	label.modulate = Color(0.85, 0.65, 1.0)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 16
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	lib.add_child(label)


static func _build_d2_gargoyles(geom: Node) -> void:
	## Epic-2 T84: 4 gargoyle statues guarding the trading post. Each is a
	## small dark figure crouched on a pedestal with red eyes. Decorative
	## ward-like flavor.
	var positions: Array[Vector3] = [
		D2_CENTER + Vector3(0, 0, -6),
		D2_CENTER + Vector3(4, 0, -6),
		D2_CENTER + Vector3(0, 0, -10),
		D2_CENTER + Vector3(4, 0, -10),
	]
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.16, 0.14, 0.18)
	stone_mat.metallic = 0.30
	stone_mat.roughness = 0.65
	var eye_mat: StandardMaterial3D = StandardMaterial3D.new()
	eye_mat.albedo_color = Color(1.0, 0.20, 0.20)
	eye_mat.emission_enabled = true
	eye_mat.emission = Color(1.0, 0.30, 0.30)
	eye_mat.emission_energy_multiplier = 2.6
	eye_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for i in positions.size():
		var garg: Node3D = Node3D.new()
		garg.name = "D2Gargoyle_%d" % i
		garg.position = positions[i]
		garg.rotation = Vector3(0, deg_to_rad(45 + i * 90), 0)
		geom.add_child(garg)
		# Pedestal
		var ped: MeshInstance3D = MeshInstance3D.new()
		var pmesh: BoxMesh = BoxMesh.new()
		pmesh.size = Vector3(0.65, 0.65, 0.65)
		ped.mesh = pmesh
		ped.position = Vector3(0, 0.32, 0)
		ped.material_override = stone_mat
		garg.add_child(ped)
		# Body — crouched cube
		var body: MeshInstance3D = MeshInstance3D.new()
		var bm2: BoxMesh = BoxMesh.new()
		bm2.size = Vector3(0.45, 0.45, 0.55)
		body.mesh = bm2
		body.position = Vector3(0, 0.85, 0)
		body.material_override = stone_mat
		garg.add_child(body)
		# Head
		var head: MeshInstance3D = MeshInstance3D.new()
		var hmesh: BoxMesh = BoxMesh.new()
		hmesh.size = Vector3(0.35, 0.30, 0.35)
		head.mesh = hmesh
		head.position = Vector3(0, 1.20, 0.10)
		head.material_override = stone_mat
		garg.add_child(head)
		# 2 red eyes
		for ex: float in [-0.07, 0.07]:
			var eye: MeshInstance3D = MeshInstance3D.new()
			var em: SphereMesh = SphereMesh.new()
			em.radius = 0.04
			em.height = 0.08
			eye.mesh = em
			eye.position = Vector3(ex, 1.22, 0.28)
			eye.material_override = eye_mat
			garg.add_child(eye)
		# Wing on top of body (small angled box)
		for sx: float in [-0.30, 0.30]:
			var wing: MeshInstance3D = MeshInstance3D.new()
			var wmesh: BoxMesh = BoxMesh.new()
			wmesh.size = Vector3(0.10, 0.45, 0.20)
			wing.mesh = wmesh
			wing.position = Vector3(sx, 1.10, -0.10)
			wing.rotation = Vector3(0, 0, sign(sx) * deg_to_rad(20))
			wing.material_override = stone_mat
			garg.add_child(wing)
		# Collision per gargoyle
		var sb: StaticBody3D = StaticBody3D.new()
		var cs: CollisionShape3D = CollisionShape3D.new()
		var cb: BoxShape3D = BoxShape3D.new()
		cb.size = Vector3(0.65, 1.40, 0.65)
		cs.shape = cb
		cs.position = Vector3(0, 0.70, 0)
		sb.add_child(cs)
		garg.add_child(sb)


static func _build_d2_boss_arena_teaser(geom: Node) -> void:
	## Epic-2 T85: a massive shadowed boss arena teaser at the far east
	## edge of D2 — a wide circular ring of dark stone pillars surrounding
	## a glowing red rune-circle in the center. Tells the player "the
	## final boss lives here, but is asleep". Telegraphs Epic 3.
	var arena: Node3D = Node3D.new()
	arena.name = "D2BossArenaTeaser"
	arena.position = D2_CENTER + Vector3(28, 0, 0)
	geom.add_child(arena)
	# Big circular floor disc — dark amber emissive
	var floor_mat: StandardMaterial3D = StandardMaterial3D.new()
	floor_mat.albedo_color = Color(0.10, 0.04, 0.04)
	floor_mat.metallic = 0.45
	floor_mat.roughness = 0.55
	floor_mat.emission_enabled = true
	floor_mat.emission = Color(0.85, 0.20, 0.20)
	floor_mat.emission_energy_multiplier = 0.45
	var floor_disc: MeshInstance3D = MeshInstance3D.new()
	var fmesh: CylinderMesh = CylinderMesh.new()
	fmesh.top_radius = 6.0
	fmesh.bottom_radius = 6.0
	fmesh.height = 0.10
	floor_disc.mesh = fmesh
	floor_disc.position = Vector3(0, 0.06, 0)
	floor_disc.material_override = floor_mat
	arena.add_child(floor_disc)
	# 8 dark stone pillars in a ring
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.10, 0.10, 0.13)
	stone_mat.metallic = 0.55
	stone_mat.roughness = 0.45
	stone_mat.emission_enabled = true
	stone_mat.emission = Color(1.0, 0.20, 0.30)
	stone_mat.emission_energy_multiplier = 0.45
	for i in 8:
		var angle: float = (float(i) / 8.0) * TAU
		var pillar: MeshInstance3D = MeshInstance3D.new()
		var pmesh: BoxMesh = BoxMesh.new()
		pmesh.size = Vector3(0.85, 6.0, 0.85)
		pillar.mesh = pmesh
		pillar.position = Vector3(cos(angle) * 5.5, 3.0, sin(angle) * 5.5)
		pillar.material_override = stone_mat
		arena.add_child(pillar)
		# Top emissive crown
		var crown: MeshInstance3D = MeshInstance3D.new()
		var cm: SphereMesh = SphereMesh.new()
		cm.radius = 0.30
		cm.height = 0.60
		crown.mesh = cm
		crown.position = Vector3(cos(angle) * 5.5, 6.30, sin(angle) * 5.5)
		var cmat: StandardMaterial3D = StandardMaterial3D.new()
		cmat.albedo_color = Color(1.0, 0.30, 0.30)
		cmat.emission_enabled = true
		cmat.emission = Color(1.0, 0.40, 0.40)
		cmat.emission_energy_multiplier = 2.6
		cmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		crown.material_override = cmat
		arena.add_child(crown)
		# Collision per pillar
		var sb: StaticBody3D = StaticBody3D.new()
		var cs: CollisionShape3D = CollisionShape3D.new()
		var cb: BoxShape3D = BoxShape3D.new()
		cb.size = Vector3(0.85, 6.0, 0.85)
		cs.shape = cb
		cs.position = Vector3(cos(angle) * 5.5, 3.0, sin(angle) * 5.5)
		sb.add_child(cs)
		arena.add_child(sb)
	# Center rune circle — 3 concentric pulsing torus rings
	for r in 3:
		var ring: MeshInstance3D = MeshInstance3D.new()
		var rmesh: TorusMesh = TorusMesh.new()
		rmesh.inner_radius = 1.0 + r * 0.55
		rmesh.outer_radius = 1.20 + r * 0.55
		ring.mesh = rmesh
		ring.position = Vector3(0, 0.12, 0)
		var rmat: StandardMaterial3D = StandardMaterial3D.new()
		rmat.albedo_color = Color(1.0, 0.20, 0.20)
		rmat.emission_enabled = true
		rmat.emission = Color(1.0, 0.30, 0.30)
		rmat.emission_energy_multiplier = 2.4
		rmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		ring.material_override = rmat
		arena.add_child(ring)
		# Pulse the ring scale outward
		var pulse: Tween = create_tween().set_loops()
		pulse.tween_property(ring, "scale", Vector3(1.10, 1.0, 1.10), 1.8 + r * 0.3).set_ease(Tween.EASE_IN_OUT)
		pulse.tween_property(ring, "scale", Vector3(0.92, 1.0, 0.92), 1.8 + r * 0.3).set_ease(Tween.EASE_IN_OUT)
	# Center marker — small dark sphere on the rune circle
	var marker: MeshInstance3D = MeshInstance3D.new()
	var mm: SphereMesh = SphereMesh.new()
	mm.radius = 0.40
	mm.height = 0.80
	marker.mesh = mm
	marker.position = Vector3(0, 0.50, 0)
	var marker_mat: StandardMaterial3D = StandardMaterial3D.new()
	marker_mat.albedo_color = Color(0.04, 0.04, 0.06)
	marker_mat.metallic = 0.85
	marker_mat.emission_enabled = true
	marker_mat.emission = Color(1.0, 0.20, 0.20)
	marker_mat.emission_energy_multiplier = 0.85
	marker.material_override = marker_mat
	arena.add_child(marker)
	# Boss-tier name billboard
	var label: Label3D = Label3D.new()
	label.text = "BOSS ARENA\n— ASLEEP —"
	label.position = Vector3(0, 8.0, 0)
	label.modulate = Color(1.0, 0.30, 0.30)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 6
	label.font_size = 26
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	arena.add_child(label)


static func _build_d2_rival_faction_wall(geom: Node) -> void:
	## Epic-2 T86: a second rival faction wall opposite the first one,
	## painted with a glowing cyan triangle symbol and "NULL CREW" tag.
	## Establishes "two factions are fighting over this district".
	var wall: Node3D = Node3D.new()
	wall.name = "D2RivalFactionWall"
	wall.position = D2_CENTER + Vector3(22, 0, 4)
	wall.rotation = Vector3(0, deg_to_rad(180), 0)
	geom.add_child(wall)
	# Wall slab
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.20, 0.16, 0.12)
	stone_mat.metallic = 0.30
	stone_mat.roughness = 0.65
	var slab: MeshInstance3D = MeshInstance3D.new()
	var smesh: BoxMesh = BoxMesh.new()
	smesh.size = Vector3(0.30, 4.0, 4.5)
	slab.mesh = smesh
	slab.position = Vector3(0, 2.0, 0)
	slab.material_override = stone_mat
	wall.add_child(slab)
	# Painted triangle symbol — 3 box edges forming the outline
	var sym_mat: StandardMaterial3D = StandardMaterial3D.new()
	sym_mat.albedo_color = Color(0.30, 0.85, 1.0)
	sym_mat.emission_enabled = true
	sym_mat.emission = Color(0.55, 0.95, 1.0)
	sym_mat.emission_energy_multiplier = 1.8
	sym_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	# 3 triangle sides
	var tri_specs: Array = [
		[Vector3(0.16, 1.10, 0), Vector3(0.06, 0.20, 2.40), 0.0],
		[Vector3(0.16, 2.05, -0.55), Vector3(0.06, 0.20, 2.20), deg_to_rad(60)],
		[Vector3(0.16, 2.05, 0.55), Vector3(0.06, 0.20, 2.20), deg_to_rad(-60)],
	]
	for spec in tri_specs:
		var seg: MeshInstance3D = MeshInstance3D.new()
		var sm: BoxMesh = BoxMesh.new()
		sm.size = spec[1]
		seg.mesh = sm
		seg.position = spec[0]
		seg.rotation = Vector3(spec[2], 0, 0)
		seg.material_override = sym_mat
		wall.add_child(seg)
	# Faction tag
	var label: Label3D = Label3D.new()
	label.text = "NULL CREW"
	label.position = Vector3(0.18, 0.65, 0)
	label.rotation = Vector3(0, deg_to_rad(90), 0)
	label.modulate = Color(0.55, 0.95, 1.0)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 26
	label.no_depth_test = true
	wall.add_child(label)
	# Collision
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(0.30, 4.0, 4.5)
	cs.shape = cb
	cs.position = Vector3(0, 2.0, 0)
	sb.add_child(cs)
	wall.add_child(sb)


static func _build_d2_skill_trainer_npc(town: Node) -> void:
	## Epic-2 T87: skill trainer NPC standing next to a punching dummy,
	## demonstrating combat skills with a periodic punch animation.
	var slots: Node3D = town.get_node_or_null("%NPCSlots") as Node3D
	if slots == null:
		return
	var trainer: Node3D = Node3D.new()
	trainer.name = "D2SkillTrainer"
	trainer.position = D2_CENTER + Vector3(2, 0, -3)
	slots.add_child(trainer)
	# Body — fit capsule
	var bmat: StandardMaterial3D = StandardMaterial3D.new()
	bmat.albedo_color = Color(0.85, 0.30, 0.20)
	bmat.metallic = 0.30
	bmat.roughness = 0.55
	bmat.emission_enabled = true
	bmat.emission = Color(1.0, 0.40, 0.20)
	bmat.emission_energy_multiplier = 0.40
	var body: MeshInstance3D = MeshInstance3D.new()
	var bmesh: CapsuleMesh = CapsuleMesh.new()
	bmesh.radius = 0.42
	bmesh.height = 1.30
	body.mesh = bmesh
	body.position = Vector3(0, 0.70, 0)
	body.material_override = bmat
	trainer.add_child(body)
	# Head sphere
	var head: MeshInstance3D = MeshInstance3D.new()
	var hmesh: SphereMesh = SphereMesh.new()
	hmesh.radius = 0.36
	hmesh.height = 0.65
	head.mesh = hmesh
	head.position = Vector3(0, 1.55, 0)
	var hmat: StandardMaterial3D = StandardMaterial3D.new()
	hmat.albedo_color = Color(0.30, 0.20, 0.15)
	hmat.metallic = 0.20
	hmat.roughness = 0.65
	head.material_override = hmat
	trainer.add_child(head)
	# 2 amber eyes
	var eye_mat: StandardMaterial3D = StandardMaterial3D.new()
	eye_mat.albedo_color = Color(1.0, 0.85, 0.30)
	eye_mat.emission_enabled = true
	eye_mat.emission = Color(1.0, 0.95, 0.30)
	eye_mat.emission_energy_multiplier = 2.6
	eye_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for ex: float in [-0.10, 0.10]:
		var eye: MeshInstance3D = MeshInstance3D.new()
		var em: SphereMesh = SphereMesh.new()
		em.radius = 0.06
		em.height = 0.12
		eye.mesh = em
		eye.position = Vector3(ex, 1.55, 0.30)
		eye.material_override = eye_mat
		trainer.add_child(eye)
	# Punching arm in front of body — animated forward/back tween
	var arm: MeshInstance3D = MeshInstance3D.new()
	var amesh: BoxMesh = BoxMesh.new()
	amesh.size = Vector3(0.20, 0.20, 0.85)
	arm.mesh = amesh
	arm.position = Vector3(0, 0.95, 0.55)
	arm.material_override = bmat
	trainer.add_child(arm)
	# Punching dummy in front of trainer
	var dummy_mat: StandardMaterial3D = StandardMaterial3D.new()
	dummy_mat.albedo_color = Color(0.40, 0.30, 0.18)
	dummy_mat.metallic = 0.10
	dummy_mat.roughness = 0.65
	var dummy: MeshInstance3D = MeshInstance3D.new()
	var dmesh: CapsuleMesh = CapsuleMesh.new()
	dmesh.radius = 0.40
	dmesh.height = 1.40
	dummy.mesh = dmesh
	dummy.position = Vector3(0, 0.70, 1.85)
	dummy.material_override = dummy_mat
	trainer.add_child(dummy)
	# Dummy stand
	var stand: MeshInstance3D = MeshInstance3D.new()
	var smesh: CylinderMesh = CylinderMesh.new()
	smesh.top_radius = 0.45
	smesh.bottom_radius = 0.45
	smesh.height = 0.10
	stand.mesh = smesh
	stand.position = Vector3(0, 0.05, 1.85)
	var stand_mat: StandardMaterial3D = StandardMaterial3D.new()
	stand_mat.albedo_color = Color(0.10, 0.10, 0.13)
	stand_mat.metallic = 0.85
	stand.material_override = stand_mat
	trainer.add_child(stand)
	# Punch tween — arm shoots forward and back, dummy recoils slightly
	var punch: Tween = create_tween().set_loops()
	punch.tween_property(arm, "position:z", 1.40, 0.18).set_ease(Tween.EASE_OUT)
	punch.tween_property(dummy, "position:z", 2.00, 0.10).set_ease(Tween.EASE_OUT)
	punch.tween_property(arm, "position:z", 0.55, 0.30).set_ease(Tween.EASE_IN)
	punch.tween_property(dummy, "position:z", 1.85, 0.30).set_ease(Tween.EASE_IN)
	punch.tween_interval(0.40)
	# Name billboard
	var label: Label3D = Label3D.new()
	label.text = "Skill Trainer"
	label.position = Vector3(0, 2.20, 0)
	label.modulate = Color(1.0, 0.55, 0.20)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 18
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	trainer.add_child(label)


static func _build_d2_ground_fissure(geom: Node) -> void:
	## Epic-2 T88: a long jagged ground fissure — 6 connected emissive
	## red bars at random angles forming a crack across the floor.
	var fissure: Node3D = Node3D.new()
	fissure.name = "D2GroundFissure"
	fissure.position = D2_CENTER + Vector3(10, 0.06, -6)
	fissure.rotation = Vector3(0, deg_to_rad(35), 0)
	geom.add_child(fissure)
	var crack_mat: StandardMaterial3D = StandardMaterial3D.new()
	crack_mat.albedo_color = Color(1.0, 0.30, 0.20)
	crack_mat.emission_enabled = true
	crack_mat.emission = Color(1.0, 0.40, 0.20)
	crack_mat.emission_energy_multiplier = 2.4
	crack_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var current_offset: float = 0.0
	for i in 6:
		var seg: MeshInstance3D = MeshInstance3D.new()
		var smesh: BoxMesh = BoxMesh.new()
		var seg_len: float = 1.40 + randf_range(-0.30, 0.30)
		smesh.size = Vector3(seg_len, 0.04, 0.30 + randf_range(-0.10, 0.10))
		seg.mesh = smesh
		seg.position = Vector3(current_offset + seg_len * 0.5, 0, randf_range(-0.30, 0.30))
		seg.rotation = Vector3(0, deg_to_rad(randf_range(-25, 25)), 0)
		seg.material_override = crack_mat
		fissure.add_child(seg)
		current_offset += seg_len * 0.85
		# Pulse on a random delay
		var pulse: Tween = create_tween().set_loops()
		pulse.tween_interval(randf() * 0.4)
		pulse.tween_property(crack_mat, "emission_energy_multiplier", 3.5, 0.85).set_ease(Tween.EASE_IN_OUT)
		pulse.tween_property(crack_mat, "emission_energy_multiplier", 1.4, 0.85).set_ease(Tween.EASE_IN_OUT)


static func _build_d2_scratch_decals(geom: Node) -> void:
	## Epic-2 T89: 12 small skid mark decals scattered on the road —
	## thin dark grey lines suggesting hover-vehicle landings + drag.
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 99
	var decal_mat: StandardMaterial3D = StandardMaterial3D.new()
	decal_mat.albedo_color = Color(0.04, 0.04, 0.06)
	decal_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for i in 12:
		var decal: MeshInstance3D = MeshInstance3D.new()
		decal.name = "D2Skid_%d" % i
		var dmesh: BoxMesh = BoxMesh.new()
		dmesh.size = Vector3(rng.randf_range(0.85, 1.40), 0.02, 0.10)
		decal.mesh = dmesh
		decal.position = D2_CENTER + Vector3(
			rng.randf_range(-22, 22),
			0.04,
			rng.randf_range(-16, 16)
		)
		decal.rotation = Vector3(0, deg_to_rad(rng.randf_range(0, 360)), 0)
		decal.material_override = decal_mat
		geom.add_child(decal)


static func _build_d2_ammo_stash(geom: Node) -> void:
	## Epic-2 T90: a small ammo crate stash — 4 ammo boxes stacked with
	## a tarp covering them and a glowing yellow "AMMO" label.
	var stash: Node3D = Node3D.new()
	stash.name = "D2AmmoStash"
	stash.position = D2_CENTER + Vector3(16, 0, -3)
	geom.add_child(stash)
	var box_mat: StandardMaterial3D = StandardMaterial3D.new()
	box_mat.albedo_color = Color(0.30, 0.40, 0.20)
	box_mat.metallic = 0.30
	box_mat.roughness = 0.55
	box_mat.emission_enabled = true
	box_mat.emission = Color(0.45, 0.55, 0.20)
	box_mat.emission_energy_multiplier = 0.30
	# 4 stacked boxes
	var box_specs: Array = [
		[Vector3(0, 0.30, 0), 0.0],
		[Vector3(0.55, 0.30, 0), 0.0],
		[Vector3(0.30, 0.85, 0), deg_to_rad(8)],
		[Vector3(-0.10, 0.85, 0.30), deg_to_rad(-15)],
	]
	for spec in box_specs:
		var box: MeshInstance3D = MeshInstance3D.new()
		var bm: BoxMesh = BoxMesh.new()
		bm.size = Vector3(0.55, 0.55, 0.40)
		box.mesh = bm
		box.position = spec[0]
		box.rotation = Vector3(0, spec[1], 0)
		box.material_override = box_mat
		stash.add_child(box)
		# Side label
		var side: Label3D = Label3D.new()
		side.text = "AMMO"
		side.position = (spec[0] as Vector3) + Vector3(0, 0, 0.21)
		side.rotation = Vector3(0, spec[1], 0)
		side.modulate = Color(1.0, 0.95, 0.30)
		side.outline_modulate = Color(0, 0, 0, 0.85)
		side.outline_size = 3
		side.font_size = 12
		side.no_depth_test = true
		stash.add_child(side)
	# Tarp draped over the top — flat box
	var tarp_mat: StandardMaterial3D = StandardMaterial3D.new()
	tarp_mat.albedo_color = Color(0.20, 0.20, 0.25)
	tarp_mat.metallic = 0.10
	tarp_mat.roughness = 0.85
	var tarp: MeshInstance3D = MeshInstance3D.new()
	var tmesh: BoxMesh = BoxMesh.new()
	tmesh.size = Vector3(1.40, 0.04, 1.0)
	tarp.mesh = tmesh
	tarp.position = Vector3(0.20, 1.20, 0.10)
	tarp.rotation = Vector3(deg_to_rad(-8), deg_to_rad(15), deg_to_rad(5))
	tarp.material_override = tarp_mat
	stash.add_child(tarp)
	# Sign
	var label: Label3D = Label3D.new()
	label.text = "AMMO STASH"
	label.position = Vector3(0, 1.85, 0)
	label.modulate = Color(1.0, 0.95, 0.30)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 16
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	stash.add_child(label)
	# Collision around the whole stash
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(1.40, 1.20, 1.0)
	cs.shape = cb
	cs.position = Vector3(0.20, 0.60, 0.10)
	sb.add_child(cs)
	stash.add_child(sb)


static func _build_d2_cargo_lift(geom: Node) -> void:
	## Epic-2 T91: a cargo lift platform with 4 corner posts and a center
	## platform that bobs vertically. The "moving" cargo is a stack of
	## 2 large crates fastened to the lift.
	var lift: Node3D = Node3D.new()
	lift.name = "D2CargoLift"
	lift.position = D2_CENTER + Vector3(20, 0, 4)
	geom.add_child(lift)
	# 4 corner posts (fixed)
	var post_mat: StandardMaterial3D = StandardMaterial3D.new()
	post_mat.albedo_color = Color(0.10, 0.13, 0.16)
	post_mat.metallic = 0.85
	post_mat.roughness = 0.30
	for ox: float in [-1.40, 1.40]:
		for oz: float in [-1.40, 1.40]:
			var post: MeshInstance3D = MeshInstance3D.new()
			var pmesh: CylinderMesh = CylinderMesh.new()
			pmesh.top_radius = 0.10
			pmesh.bottom_radius = 0.14
			pmesh.height = 4.0
			post.mesh = pmesh
			post.position = Vector3(ox, 2.0, oz)
			post.material_override = post_mat
			lift.add_child(post)
			# Collision per post
			var sb: StaticBody3D = StaticBody3D.new()
			var cs: CollisionShape3D = CollisionShape3D.new()
			var cap: CapsuleShape3D = CapsuleShape3D.new()
			cap.radius = 0.20
			cap.height = 4.0
			cs.shape = cap
			cs.position = Vector3(ox, 2.0, oz)
			sb.add_child(cs)
			lift.add_child(sb)
	# Lift platform that bobs (parent for the platform + crates)
	var lift_pivot: Node3D = Node3D.new()
	lift_pivot.position = Vector3(0, 0.30, 0)
	lift.add_child(lift_pivot)
	# Platform base — wide flat box
	var plat_mat: StandardMaterial3D = StandardMaterial3D.new()
	plat_mat.albedo_color = Color(0.20, 0.22, 0.28)
	plat_mat.metallic = 0.65
	plat_mat.roughness = 0.40
	plat_mat.emission_enabled = true
	plat_mat.emission = Color(0.55, 0.95, 1.0)
	plat_mat.emission_energy_multiplier = 0.55
	var plat: MeshInstance3D = MeshInstance3D.new()
	var pmesh: BoxMesh = BoxMesh.new()
	pmesh.size = Vector3(2.60, 0.20, 2.60)
	plat.mesh = pmesh
	plat.material_override = plat_mat
	lift_pivot.add_child(plat)
	# 2 crates on the platform
	var crate_mat: StandardMaterial3D = StandardMaterial3D.new()
	crate_mat.albedo_color = Color(0.30, 0.18, 0.08)
	crate_mat.metallic = 0.10
	crate_mat.roughness = 0.65
	for spec in [
		[Vector3(-0.40, 0.65, 0), Vector3(0.85, 0.85, 0.85)],
		[Vector3(0.55, 0.65, 0.20), Vector3(0.85, 0.85, 0.85)],
	]:
		var crate: MeshInstance3D = MeshInstance3D.new()
		var cm: BoxMesh = BoxMesh.new()
		cm.size = spec[1]
		crate.mesh = cm
		crate.position = spec[0]
		crate.rotation = Vector3(0, deg_to_rad(randf_range(-15, 15)), 0)
		crate.material_override = crate_mat
		lift_pivot.add_child(crate)
	# Bob the lift up and down
	var bob: Tween = create_tween().set_loops()
	bob.tween_property(lift_pivot, "position:y", 3.0, 4.0).set_ease(Tween.EASE_IN_OUT)
	bob.tween_interval(0.85)
	bob.tween_property(lift_pivot, "position:y", 0.30, 4.0).set_ease(Tween.EASE_IN_OUT)
	bob.tween_interval(0.85)
	# Sign
	var label: Label3D = Label3D.new()
	label.text = "CARGO LIFT"
	label.position = Vector3(0, 4.40, 0)
	label.modulate = Color(0.55, 0.95, 1.0)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 16
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	lift.add_child(label)


static func _build_d2_ember_drift(geom: Node) -> void:
	## Epic-2 T92: ambient orange ember particles drifting upward across
	## the district — 100 small embers floating up like burning paper.
	var embers: GPUParticles3D = GPUParticles3D.new()
	embers.name = "D2EmberDrift"
	embers.position = D2_CENTER + Vector3(0, 1, 0)
	embers.amount = 100
	embers.lifetime = 6.5
	embers.preprocess = 3.0
	var pmat: ParticleProcessMaterial = ParticleProcessMaterial.new()
	pmat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	pmat.emission_box_extents = Vector3(22, 0.5, 18)
	pmat.direction = Vector3(0.2, 1, 0)
	pmat.spread = 18.0
	pmat.initial_velocity_min = 0.55
	pmat.initial_velocity_max = 1.0
	pmat.gravity = Vector3.ZERO
	pmat.scale_min = 0.04
	pmat.scale_max = 0.10
	pmat.color = Color(1.0, 0.55, 0.20, 1.0)
	embers.process_material = pmat
	var em: SphereMesh = SphereMesh.new()
	em.radius = 0.05
	em.height = 0.10
	var em_mat: StandardMaterial3D = StandardMaterial3D.new()
	em_mat.albedo_color = Color(1.0, 0.55, 0.20)
	em_mat.emission_enabled = true
	em_mat.emission = Color(1.0, 0.65, 0.20)
	em_mat.emission_energy_multiplier = 2.6
	em_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	em.material = em_mat
	embers.draw_pass_1 = em
	geom.add_child(embers)


static func _build_d2_unknown_tomb(geom: Node) -> void:
	## Epic-2 T93: a stone tomb engraved "TOMB OF THE UNKNOWN AGENT".
	## Long sarcophagus shape with a glowing central rune on top.
	var tomb: Node3D = Node3D.new()
	tomb.name = "D2UnknownTomb"
	tomb.position = D2_CENTER + Vector3(-15, 0, 18)
	geom.add_child(tomb)
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.30, 0.30, 0.34)
	stone_mat.metallic = 0.30
	stone_mat.roughness = 0.55
	# Stepped base
	for i in 2:
		var step: MeshInstance3D = MeshInstance3D.new()
		var sm: BoxMesh = BoxMesh.new()
		sm.size = Vector3(3.0 - i * 0.30, 0.20, 1.40 - i * 0.20)
		step.mesh = sm
		step.position = Vector3(0, 0.10 + i * 0.20, 0)
		step.material_override = stone_mat
		tomb.add_child(step)
	# Sarcophagus body
	var sarc: MeshInstance3D = MeshInstance3D.new()
	var sm2: BoxMesh = BoxMesh.new()
	sm2.size = Vector3(2.40, 0.85, 0.85)
	sarc.mesh = sm2
	sarc.position = Vector3(0, 0.85, 0)
	sarc.material_override = stone_mat
	tomb.add_child(sarc)
	# Glowing rune on top — small emissive star (4-prism arrangement)
	var rune_mat: StandardMaterial3D = StandardMaterial3D.new()
	rune_mat.albedo_color = Color(0.85, 0.85, 0.95)
	rune_mat.emission_enabled = true
	rune_mat.emission = Color(0.95, 0.95, 1.0)
	rune_mat.emission_energy_multiplier = 2.4
	rune_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for i in 4:
		var spike: MeshInstance3D = MeshInstance3D.new()
		var prm: PrismMesh = PrismMesh.new()
		prm.size = Vector3(0.10, 0.30, 0.10)
		spike.mesh = prm
		var angle: float = (float(i) / 4.0) * TAU
		spike.position = Vector3(cos(angle) * 0.15, 1.40, sin(angle) * 0.15)
		spike.rotation = Vector3(0, -angle, 0)
		spike.material_override = rune_mat
		tomb.add_child(spike)
	# Engraved text on the side of the sarcophagus
	var label: Label3D = Label3D.new()
	label.text = "TOMB OF THE\nUNKNOWN AGENT"
	label.position = Vector3(0, 0.85, 0.45)
	label.modulate = Color(0.85, 0.85, 0.95)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 4
	label.font_size = 14
	label.no_depth_test = true
	tomb.add_child(label)
	# Collision around the sarcophagus
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(2.40, 1.40, 1.40)
	cs.shape = cb
	cs.position = Vector3(0, 0.70, 0)
	sb.add_child(cs)
	tomb.add_child(sb)


static func _build_d2_stalker_enemy(geom: Node) -> void:
	## Epic-2 T94: a stalker enemy slinking around the district. Tall thin
	## body with 3 spider-like leg sticks and 1 single white-hot eye.
	var stalker: Node3D = Node3D.new()
	stalker.name = "D2Stalker"
	stalker.position = D2_CENTER + Vector3(-3, 0, 12)
	geom.add_child(stalker)
	# Tall thin body — vertical capsule
	var bmat: StandardMaterial3D = StandardMaterial3D.new()
	bmat.albedo_color = Color(0.04, 0.04, 0.06)
	bmat.metallic = 0.30
	bmat.roughness = 0.65
	bmat.emission_enabled = true
	bmat.emission = Color(0.20, 0.10, 0.30)
	bmat.emission_energy_multiplier = 0.30
	var body: MeshInstance3D = MeshInstance3D.new()
	var bmesh: CapsuleMesh = CapsuleMesh.new()
	bmesh.radius = 0.20
	bmesh.height = 1.40
	body.mesh = bmesh
	body.position = Vector3(0, 1.30, 0)
	body.material_override = bmat
	stalker.add_child(body)
	# Single white-hot eye on top
	var eye: MeshInstance3D = MeshInstance3D.new()
	var em: SphereMesh = SphereMesh.new()
	em.radius = 0.12
	em.height = 0.24
	eye.mesh = em
	eye.position = Vector3(0, 1.85, 0.18)
	var emat: StandardMaterial3D = StandardMaterial3D.new()
	emat.albedo_color = Color(1, 1, 1)
	emat.emission_enabled = true
	emat.emission = Color(1, 1, 1)
	emat.emission_energy_multiplier = 3.4
	emat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	eye.material_override = emat
	stalker.add_child(eye)
	# 3 thin spider legs splaying outward from the bottom
	var leg_mat: StandardMaterial3D = StandardMaterial3D.new()
	leg_mat.albedo_color = Color(0.04, 0.04, 0.06)
	leg_mat.metallic = 0.30
	for i in 3:
		var angle: float = (float(i) / 3.0) * TAU
		var leg: MeshInstance3D = MeshInstance3D.new()
		var lmesh: CylinderMesh = CylinderMesh.new()
		lmesh.top_radius = 0.04
		lmesh.bottom_radius = 0.04
		lmesh.height = 1.20
		leg.mesh = lmesh
		leg.position = Vector3(cos(angle) * 0.30, 0.55, sin(angle) * 0.30)
		leg.rotation = Vector3(sin(angle) * deg_to_rad(20), 0, -cos(angle) * deg_to_rad(20))
		leg.material_override = leg_mat
		stalker.add_child(leg)
	# Patrol path
	var origin: Vector3 = D2_CENTER + Vector3(-3, 0, 12)
	var patrol: Tween = create_tween().set_loops()
	patrol.tween_property(stalker, "position", origin + Vector3(6, 0, -6), 8.0)
	patrol.tween_property(stalker, "position", origin + Vector3(-3, 0, -6), 8.0)
	patrol.tween_property(stalker, "position", origin, 8.0)
	# Eye flicker
	var flicker: Tween = create_tween().set_loops()
	flicker.tween_property(emat, "emission_energy_multiplier", 4.5, 0.6).set_ease(Tween.EASE_IN_OUT)
	flicker.tween_property(emat, "emission_energy_multiplier", 1.6, 0.6).set_ease(Tween.EASE_IN_OUT)
	# Boss-tier name billboard
	var label: Label3D = Label3D.new()
	label.text = "STALKER"
	label.position = Vector3(0, 2.40, 0)
	label.modulate = Color(0.85, 0.55, 1.0)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 16
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	stalker.add_child(label)


static func _build_d2_boss_fortifications(geom: Node) -> void:
	## Epic-2 T95: 6 stone barricade walls forming a partial outer ring
	## around the boss arena teaser, suggesting "the gangs tried to keep
	## the boss contained but failed".
	var fort: Node3D = Node3D.new()
	fort.name = "D2BossFortifications"
	fort.position = D2_CENTER + Vector3(28, 0, 0)
	geom.add_child(fort)
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.16, 0.13, 0.10)
	stone_mat.metallic = 0.30
	stone_mat.roughness = 0.65
	stone_mat.emission_enabled = true
	stone_mat.emission = Color(1.0, 0.40, 0.20)
	stone_mat.emission_energy_multiplier = 0.20
	# 6 walls at 60-degree increments around the arena
	for i in 6:
		var angle: float = (float(i) / 6.0) * TAU + deg_to_rad(30)
		var wall_root: Node3D = Node3D.new()
		wall_root.position = Vector3(cos(angle) * 8.5, 0, sin(angle) * 8.5)
		wall_root.rotation = Vector3(0, -angle, 0)
		fort.add_child(wall_root)
		# Wall slab — wide flat box
		var wall: MeshInstance3D = MeshInstance3D.new()
		var wmesh: BoxMesh = BoxMesh.new()
		wmesh.size = Vector3(0.40, 1.85, 2.40)
		wall.mesh = wmesh
		wall.position = Vector3(0, 0.92, 0)
		wall.rotation = Vector3(deg_to_rad(randf_range(-5, 5)), 0, deg_to_rad(randf_range(-8, 8)))
		wall.material_override = stone_mat
		wall_root.add_child(wall)
		# Crack stripe down the middle (broken through)
		if i % 2 == 0:
			var crack: MeshInstance3D = MeshInstance3D.new()
			var cmesh: BoxMesh = BoxMesh.new()
			cmesh.size = Vector3(0.06, 1.20, 0.30)
			crack.mesh = cmesh
			crack.position = Vector3(0.21, 0.92, 0)
			crack.rotation = Vector3(0, 0, deg_to_rad(8))
			var crack_mat: StandardMaterial3D = StandardMaterial3D.new()
			crack_mat.albedo_color = Color(1.0, 0.40, 0.20)
			crack_mat.emission_enabled = true
			crack_mat.emission = Color(1.0, 0.55, 0.20)
			crack_mat.emission_energy_multiplier = 1.8
			crack_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
			crack.material_override = crack_mat
			wall_root.add_child(crack)
		# Collision per wall
		var sb: StaticBody3D = StaticBody3D.new()
		var cs: CollisionShape3D = CollisionShape3D.new()
		var cb: BoxShape3D = BoxShape3D.new()
		cb.size = Vector3(0.40, 1.85, 2.40)
		cs.shape = cb
		cs.position = Vector3(0, 0.92, 0)
		sb.add_child(cs)
		wall_root.add_child(sb)


static func _build_d2_welcome_banner(geom: Node) -> void:
	## Epic-2 T96: a wide amber banner stretched between the existing D2
	## entrance arch pillars at x=70 reading "STACK OVERFLOW / OUTSKIRTS".
	## Has waving emissive trim and a slow alpha pulse.
	var banner_root: Node3D = Node3D.new()
	banner_root.name = "D2WelcomeBanner"
	banner_root.position = Vector3(70, 0, 0)
	geom.add_child(banner_root)
	# Banner cloth — long horizontal box
	var cloth: MeshInstance3D = MeshInstance3D.new()
	var cmesh: BoxMesh = BoxMesh.new()
	cmesh.size = Vector3(0.10, 0.95, 7.5)
	cloth.mesh = cmesh
	cloth.position = Vector3(0, 5.5, 0)
	var cmat: StandardMaterial3D = StandardMaterial3D.new()
	cmat.albedo_color = Color(0.30, 0.10, 0.04)
	cmat.emission_enabled = true
	cmat.emission = Color(1.0, 0.40, 0.20)
	cmat.emission_energy_multiplier = 1.0
	cmat.metallic = 0.10
	cmat.roughness = 0.55
	cloth.material_override = cmat
	banner_root.add_child(cloth)
	# Top + bottom emissive trim
	var trim_mat: StandardMaterial3D = StandardMaterial3D.new()
	trim_mat.albedo_color = Color(1.0, 0.55, 0.20)
	trim_mat.emission_enabled = true
	trim_mat.emission = Color(1.0, 0.65, 0.20)
	trim_mat.emission_energy_multiplier = 2.0
	trim_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for ty: float in [5.95, 5.05]:
		var trim: MeshInstance3D = MeshInstance3D.new()
		var tmesh: BoxMesh = BoxMesh.new()
		tmesh.size = Vector3(0.12, 0.08, 7.5)
		trim.mesh = tmesh
		trim.position = Vector3(0, ty, 0)
		trim.material_override = trim_mat
		banner_root.add_child(trim)
	# Welcome text — duplicated for both sides
	for fx: float in [-0.10, 0.10]:
		var label: Label3D = Label3D.new()
		label.text = "STACK OVERFLOW\nOUTSKIRTS"
		label.position = Vector3(fx, 5.50, 0)
		label.rotation = Vector3(0, deg_to_rad(-90 if fx < 0 else 90), 0)
		label.modulate = Color(1.0, 0.55, 0.20)
		label.outline_modulate = Color(0, 0, 0, 0.85)
		label.outline_size = 6
		label.font_size = 24
		label.no_depth_test = true
		banner_root.add_child(label)
	# Slow emission pulse
	var pulse: Tween = create_tween().set_loops()
	pulse.tween_property(cmat, "emission_energy_multiplier", 1.6, 2.0).set_ease(Tween.EASE_IN_OUT)
	pulse.tween_property(cmat, "emission_energy_multiplier", 0.85, 2.0).set_ease(Tween.EASE_IN_OUT)


static func _build_d2_red_fog(geom: Node) -> void:
	## Epic-2 T97: atmospheric red fog drifting low across the district —
	## 60 large translucent red puff particles slowly moving east at
	## ~0.5m altitude, very transparent.
	var fog: GPUParticles3D = GPUParticles3D.new()
	fog.name = "D2RedFog"
	fog.position = D2_CENTER + Vector3(-25, 0.5, 0)
	fog.amount = 60
	fog.lifetime = 12.0
	fog.preprocess = 6.0
	var pmat: ParticleProcessMaterial = ParticleProcessMaterial.new()
	pmat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	pmat.emission_box_extents = Vector3(0.5, 0.5, 18.0)
	pmat.direction = Vector3(1, 0, 0)
	pmat.spread = 4.0
	pmat.initial_velocity_min = 0.45
	pmat.initial_velocity_max = 0.85
	pmat.gravity = Vector3.ZERO
	pmat.scale_min = 0.85
	pmat.scale_max = 1.40
	pmat.color = Color(1.0, 0.30, 0.20, 0.20)
	fog.process_material = pmat
	var puff: SphereMesh = SphereMesh.new()
	puff.radius = 0.85
	puff.height = 1.70
	var puff_mat: StandardMaterial3D = StandardMaterial3D.new()
	puff_mat.albedo_color = Color(1.0, 0.30, 0.20, 0.20)
	puff_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	puff_mat.emission_enabled = true
	puff_mat.emission = Color(1.0, 0.40, 0.20)
	puff_mat.emission_energy_multiplier = 0.45
	puff_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	puff.material = puff_mat
	fog.draw_pass_1 = puff
	geom.add_child(fog)


static func _build_d2_epic2_plaque(geom: Node) -> void:
	## Epic-2 T98: a stone tablet plaque commemorating the completion of
	## Epic 2 ("EPIC 02 / OUTSKIRTS COMPLETE"), placed near the boss arena.
	var plaque: Node3D = Node3D.new()
	plaque.name = "D2Epic2Plaque"
	plaque.position = D2_CENTER + Vector3(24, 0, -8)
	geom.add_child(plaque)
	# Tiny pedestal
	var ped_mat: StandardMaterial3D = StandardMaterial3D.new()
	ped_mat.albedo_color = Color(0.16, 0.13, 0.10)
	ped_mat.metallic = 0.55
	ped_mat.roughness = 0.45
	var ped: MeshInstance3D = MeshInstance3D.new()
	var pmesh: BoxMesh = BoxMesh.new()
	pmesh.size = Vector3(0.85, 0.50, 0.40)
	ped.mesh = pmesh
	ped.position = Vector3(0, 0.25, 0)
	ped.material_override = ped_mat
	plaque.add_child(ped)
	# Tilted stone tablet
	var tablet: MeshInstance3D = MeshInstance3D.new()
	var tmesh: BoxMesh = BoxMesh.new()
	tmesh.size = Vector3(0.85, 0.65, 0.06)
	tablet.mesh = tmesh
	tablet.position = Vector3(0, 0.85, 0)
	tablet.rotation = Vector3(deg_to_rad(-25), 0, 0)
	var tmat: StandardMaterial3D = StandardMaterial3D.new()
	tmat.albedo_color = Color(0.30, 0.20, 0.14)
	tmat.metallic = 0.65
	tmat.roughness = 0.30
	tmat.emission_enabled = true
	tmat.emission = Color(1.0, 0.55, 0.20)
	tmat.emission_energy_multiplier = 0.40
	tablet.material_override = tmat
	plaque.add_child(tablet)
	# Engraved text
	var label: Label3D = Label3D.new()
	label.text = "EPIC 02\nOUTSKIRTS\nCOMPLETE"
	label.position = Vector3(0, 0.95, 0.18)
	label.rotation = Vector3(deg_to_rad(-25), 0, 0)
	label.modulate = Color(1.0, 0.55, 0.20)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 4
	label.font_size = 14
	label.no_depth_test = true
	plaque.add_child(label)
	# Collision
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(0.85, 0.60, 0.40)
	cs.shape = cb
	cs.position = Vector3(0, 0.30, 0)
	sb.add_child(cs)
	plaque.add_child(sb)


static func _build_d2_ambient_lighting(geom: Node) -> void:
	## Epic-2 T99: 3 high amber-tinted OmniLight3D fill lights spaced
	## along the D2 length lifting the overall light level so all 100
	## elements read nicely.
	var positions: Array[Vector3] = [
		D2_CENTER + Vector3(-15, 8, 0),
		D2_CENTER + Vector3(0, 8, 0),
		D2_CENTER + Vector3(15, 8, 0),
	]
	for i in positions.size():
		var fill: OmniLight3D = OmniLight3D.new()
		fill.name = "D2FillLight_%d" % i
		fill.position = positions[i]
		fill.light_color = Color(1.0, 0.75, 0.55)
		fill.light_energy = 1.4
		fill.omni_range = 22.0
		fill.omni_attenuation = 1.6
		geom.add_child(fill)


static func _build_d2_glitch_herald_landmark(geom: Node) -> void:
	## Epic-2 T100 (FINALE): a massive hovering "Glitch Herald" landmark
	## above the D2 center — translucent crimson humanoid figure with
	## 6 orbital glitch shards, slow rotation, ground halo, real omni
	## light. The Outskirts equivalent of East Plaza's Globbler landmark.
	var landmark: Node3D = Node3D.new()
	landmark.name = "D2GlitchHeraldLandmark"
	landmark.position = D2_CENTER + Vector3(0, 12, 0)
	geom.add_child(landmark)
	# Pivot for rotation
	var pivot: Node3D = Node3D.new()
	pivot.name = "RotationPivot"
	landmark.add_child(pivot)
	# Translucent humanoid body — capsule
	var holo_mat: StandardMaterial3D = StandardMaterial3D.new()
	holo_mat.albedo_color = Color(1.0, 0.30, 0.30, 0.45)
	holo_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	holo_mat.emission_enabled = true
	holo_mat.emission = Color(1.0, 0.30, 0.30)
	holo_mat.emission_energy_multiplier = 2.4
	holo_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	# Body capsule
	var body: MeshInstance3D = MeshInstance3D.new()
	var bmesh: CapsuleMesh = CapsuleMesh.new()
	bmesh.radius = 0.85
	bmesh.height = 2.40
	body.mesh = bmesh
	body.position = Vector3(0, 0, 0)
	body.material_override = holo_mat
	pivot.add_child(body)
	# Head sphere
	var head: MeshInstance3D = MeshInstance3D.new()
	var hmesh: SphereMesh = SphereMesh.new()
	hmesh.radius = 0.70
	hmesh.height = 1.40
	head.mesh = hmesh
	head.position = Vector3(0, 1.85, 0)
	head.material_override = holo_mat
	pivot.add_child(head)
	# 2 huge glowing white eyes
	var eye_mat: StandardMaterial3D = StandardMaterial3D.new()
	eye_mat.albedo_color = Color(1, 1, 1, 0.9)
	eye_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	eye_mat.emission_enabled = true
	eye_mat.emission = Color(1, 1, 1)
	eye_mat.emission_energy_multiplier = 3.4
	eye_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for ex: float in [-0.32, 0.32]:
		var eye: MeshInstance3D = MeshInstance3D.new()
		var em: SphereMesh = SphereMesh.new()
		em.radius = 0.22
		em.height = 0.44
		eye.mesh = em
		eye.position = Vector3(ex, 1.95, 0.55)
		eye.material_override = eye_mat
		pivot.add_child(eye)
	# 2 outstretched arms
	for sx: float in [-1.0, 1.0]:
		var arm: MeshInstance3D = MeshInstance3D.new()
		var am: BoxMesh = BoxMesh.new()
		am.size = Vector3(0.30, 0.30, 1.60)
		arm.mesh = am
		arm.position = Vector3(sx * 1.10, 0.30, 0)
		arm.rotation = Vector3(0, 0, sign(sx) * deg_to_rad(20))
		arm.material_override = holo_mat
		pivot.add_child(arm)
	# 6 orbital glitch shards (prisms) circling at body height
	for i in 6:
		var angle: float = (float(i) / 6.0) * TAU
		var shard: MeshInstance3D = MeshInstance3D.new()
		var sm: PrismMesh = PrismMesh.new()
		sm.size = Vector3(0.30, 0.65, 0.30)
		shard.mesh = sm
		shard.position = Vector3(cos(angle) * 2.20, sin(float(i) * 0.85) * 0.55, sin(angle) * 2.20)
		shard.rotation = Vector3(0, -angle, deg_to_rad(15))
		var smat: StandardMaterial3D = StandardMaterial3D.new()
		smat.albedo_color = Color(1.0, 0.40, 0.40)
		smat.emission_enabled = true
		smat.emission = Color(1.0, 0.55, 0.30)
		smat.emission_energy_multiplier = 2.6
		smat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		shard.material_override = smat
		pivot.add_child(shard)
	# Slow main rotation
	var spin: Tween = create_tween().set_loops()
	spin.tween_property(pivot, "rotation:y", TAU, 18.0)
	# Bobbing in place
	var bob: Tween = create_tween().set_loops()
	bob.tween_property(landmark, "position:y", 13.0, 3.0).set_ease(Tween.EASE_IN_OUT)
	bob.tween_property(landmark, "position:y", 12.0, 3.0).set_ease(Tween.EASE_IN_OUT)
	# Ground halo beneath the landmark
	var halo: MeshInstance3D = MeshInstance3D.new()
	var hmesh2: TorusMesh = TorusMesh.new()
	hmesh2.inner_radius = 4.0
	hmesh2.outer_radius = 4.55
	halo.mesh = hmesh2
	halo.position = D2_CENTER + Vector3(0, 0.06, 0)
	var hmat2: StandardMaterial3D = StandardMaterial3D.new()
	hmat2.albedo_color = Color(1.0, 0.40, 0.40)
	hmat2.emission_enabled = true
	hmat2.emission = Color(1.0, 0.55, 0.30)
	hmat2.emission_energy_multiplier = 2.4
	hmat2.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	halo.material_override = hmat2
	geom.add_child(halo)
	var halo_pulse: Tween = create_tween().set_loops()
	halo_pulse.tween_property(halo, "scale", Vector3(1.20, 1.0, 1.20), 2.0).set_ease(Tween.EASE_IN_OUT)
	halo_pulse.tween_property(halo, "scale", Vector3(1.0, 1.0, 1.0), 2.0).set_ease(Tween.EASE_IN_OUT)
	# Real OmniLight at the landmark casting amber light over the district
	var landmark_light: OmniLight3D = OmniLight3D.new()
	landmark_light.position = Vector3(0, 0, 0)
	landmark_light.light_color = Color(1.0, 0.55, 0.30)
	landmark_light.light_energy = 3.5
	landmark_light.omni_range = 28.0
	landmark_light.omni_attenuation = 1.4
	pivot.add_child(landmark_light)
	# GLITCH HERALD billboard above the landmark
	var label: Label3D = Label3D.new()
	label.text = "GLITCH HERALD"
	label.position = Vector3(0, 4.0, 0)
	label.modulate = Color(1.0, 0.40, 0.40)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 6
	label.font_size = 26
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	landmark.add_child(label)
