class_name D1Builder
extends Node
## East Plaza district builder — extracted from district_2.gd where it
## was accidentally bundled. All Epic 1 helpers live here as instance
## methods so they have access to create_tween() and add_child().

const EAST_PLAZA_CENTER := Vector3(32, 0, 0)


func build(town: Node, geom: Node) -> void:
	print("[D1Builder] start")
	# Step 1: extend the playable boundary east.
	var east_wall: CSGBox3D = geom.get_node_or_null("BoundaryEast") as CSGBox3D
	if east_wall:
		east_wall.position.x = 44.0
	# Build all 100 tasks in original order
	_build_east_plaza_ground(geom)
	_build_east_plaza_path(geom)
	_build_data_terminal(geom, EAST_PLAZA_CENTER)
	_build_kiosks(geom)
	_build_queue_bollards(geom)
	_build_market_particles(geom)
	_build_plaza_lights(geom)
	_build_data_merchant_npc(town)
	_build_cipher_npc(town)
	_build_market_hall(geom)
	_attach_kiosk_interactables(geom)
	_build_market_chatter_zone(geom)
	_build_vendor_stall(geom)
	_build_plaza_pedestrians(geom)
	_build_loading_dock(geom)
	_build_banner_flags(geom)
	_build_open_decals(geom)
	_build_plaza_benches(geom)
	_build_plaza_planters(geom)
	_build_vending_machines(geom)
	_build_security_drones(geom)
	_build_info_totems(geom)
	_build_data_fountain(geom)
	_build_holo_billboards(geom)
	_build_neon_ads(geom)
	_build_transit_pad(geom)
	_build_shop_signage(geom)
	_build_ground_light_strips(geom)
	_build_maintenance_bots(geom)
	_build_sky_data_fragments(geom)
	_build_power_conduits(geom)
	_build_plaza_arch_gateway(geom)
	_build_sparring_arena(geom)
	_build_practice_dummies(geom)
	_build_tournament_pit(geom)
	_build_crowd_seating(geom)
	_build_combat_trainer_npc(town)
	_build_weapon_rack(geom)
	_build_combat_mannequin(geom)
	_build_training_mat(geom)
	_build_score_board(geom)
	_build_chalk_lines(geom)
	_build_quest_board(geom)
	_build_data_bins(geom)
	_build_animated_lamps(geom)
	_build_dock_ramp(geom)
	_build_zone_numbers(geom)
	_build_tournament_leaderboard(geom)
	_build_tournament_gate(geom)
	_build_perimeter_seating(geom)
	_build_gate_guards(town)
	_build_cipher_orbs(geom)
	_build_holo_shop_windows(geom)
	_build_atrium_roof(geom)
	_build_cafe_seating(geom)
	_build_data_streams(geom)
	_build_district_signposts(geom)
	_build_tournament_audience(geom)
	_build_waving_banners(geom)
	_build_power_generator(geom)
	_build_data_shards(geom)
	_build_ai_statue(geom)
	_build_merchant_tent(geom)
	_build_data_archive(geom)
	_build_dummy_hit_vfx(geom)
	_build_courier_drones(geom)
	_build_glow_nodes(geom)
	_build_minimap_kiosk(geom)
	_build_data_atm(geom)
	_build_bug_cage(geom)
	_build_announcement_speakers(geom)
	_build_statue_garden(geom)
	_build_radial_floor_decals(geom)
	_build_food_cart(geom)
	_build_coin_drops(geom)
	_build_pit_spotlights(geom)
	_build_data_snow(geom)
	_build_arena_rope_barriers(geom)
	_build_sale_signs(geom)
	_build_chatter_bubbles(geom)
	_build_fountain_mist(geom)
	_build_champion_banner(geom)
	_build_east_gate(geom)
	_build_skyline_silhouette(geom)
	_build_horizon_lights(geom)
	_build_border_guard_npc(town)
	_build_eastbound_path(geom)
	_build_save_shrine(geom)
	_build_bell_tower(geom)
	_build_data_clouds(geom)
	_build_chess_players(geom)
	_build_plaza_directory(geom)
	_build_respawn_beacon(geom)
	_build_ground_glitch(geom)
	_build_floating_receipts(geom)
	_build_combat_golem(geom)
	_build_weather_dial(geom)
	_build_corner_pillars(geom)
	_build_maintenance_patrol(geom)
	_build_news_ticker(geom)
	_build_data_spa(geom)
	_build_plaza_fireworks(geom)
	_build_welcome_arch_banner(geom)
	_build_statue_spotlights(geom)
	_build_plaza_ambient_lighting(geom)
	_build_epic1_plaque(geom)
	_build_central_globbler_landmark(geom)
	print("[D1Builder] done")


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


func _build_data_merchant_npc(town: Node) -> void:
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


func _build_cipher_npc(town: Node) -> void:
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


func _build_gate_guards(town: Node) -> void:
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


func _build_combat_trainer_npc(town: Node) -> void:
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
		conduit.material_override = conduit_mat
		geom.add_child(conduit)
		conduit.look_at(ep, Vector3.UP)


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


func _build_border_guard_npc(town: Node) -> void:
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

func _make_dirt_path_material() -> StandardMaterial3D:
	## Local copy of the helper from town.gd — returns a flat dark-cyan
	## emissive panel that reads as a "data lane".
	var mat: StandardMaterial3D = StandardMaterial3D.new()
	mat.albedo_color = Color(0.08, 0.18, 0.22)
	mat.emission_enabled = true
	mat.emission = Color(0.10, 0.42, 0.50)
	mat.emission_energy_multiplier = 0.45
	mat.metallic = 0.2
	mat.roughness = 0.6
	mat.transparency = BaseMaterial3D.TRANSPARENCY_DISABLED
	return mat
