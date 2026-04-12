class_name D4Builder
extends Node
## Bloom Cluster district builder — extracted from scenes/town/town.gd to keep
## the main town script modular and under control.

const D4_CENTER := Vector3(220, 0, 0)


func extend_boundary(geom: Node) -> void:
	## Push the east boundary wall from x=180 out to x=260.
	var east_wall: CSGBox3D = geom.get_node_or_null("BoundaryEast") as CSGBox3D
	if east_wall:
		east_wall.position.x = 260.0


func build(town: Node, geom: Node) -> void:
	## Entry point — called from town.gd::_build_district_4(geom).
	#print("[D4Builder] start")
	extend_boundary(geom)
	_build_d4_ground(geom)
	_build_d4_entrance_arch(geom)
	_build_d4_great_bloom(geom)
	_build_d4_bloomling(geom)
	_build_d4_gardener_npc(town)
	_build_d4_bush_cluster(geom)
	_build_d4_mushroom_forest(geom)
	_build_d4_vine_canopy(geom)
	_build_d4_botanist_npc(town)
	_build_d4_beehive(geom)
	_build_d4_meadow_flowers(geom)
	_build_d4_butterflies(geom)
	_build_d4_watering_well(geom)
	_build_d4_farmer_npc(town)
	_build_d4_scarecrow(geom)
	_build_d4_tree_grove(geom)
	_build_d4_apple_tree(geom)
	_build_d4_fish_pond(geom)
	_build_d4_fisherman_npc(town)
	_build_d4_lily_pads(geom)
	_build_d4_greenhouse_building(geom)
	_build_d4_plant_pot_row(geom)
	_build_d4_ladybug_creature(geom)
	_build_d4_chef_npc(town)
	_build_d4_soup_pot(geom)
	_build_d4_stone_path(geom)
	_build_d4_windmill(geom)
	_build_d4_wheat_field(geom)
	_build_d4_miller_npc(town)
	_build_d4_bread_oven(geom)
	_build_d4_gazebo(geom)
	_build_d4_flower_wreaths(geom)
	_build_d4_bird_bath(geom)
	_build_d4_storyteller_npc(town)
	_build_d4_sleeping_cat(geom)
	_build_d4_picnic_blanket(geom)
	_build_d4_veg_cart(geom)
	_build_d4_garden_gnomes(geom)
	_build_d4_beekeeper_npc(town)
	_build_d4_honey_jars(geom)
	_build_d4_compost_heap(geom)
	_build_d4_painter_npc(town)
	_build_d4_easel_canvas(geom)
	_build_d4_birdhouse(geom)
	_build_d4_clothesline(geom)
	_build_d4_stone_bridge(geom)
	_build_d4_small_stream(geom)
	_build_d4_frog_creature(geom)
	_build_d4_musician_npc(town)
	_build_d4_bloom_guardian(geom)
	_build_d4_stable(geom)
	_build_d4_horse(geom)
	_build_d4_stableboy_npc(town)
	_build_d4_hay_loft(geom)
	_build_d4_hay_bales(geom)
	_build_d4_pumpkin_patch(geom)
	_build_d4_chicken_coop(geom)
	_build_d4_chickens(geom)
	_build_d4_harvest_crates(geom)
	_build_d4_berry_bushes(geom)
	_build_d4_veg_garden_rows(geom)
	_build_d4_water_trough(geom)
	_build_d4_shepherd_npc(town)
	_build_d4_sheep_flock(geom)
	_build_d4_sheepdog(geom)
	_build_d4_cherry_orchard(geom)
	_build_d4_preserves_stand(geom)
	_build_d4_child_npc(town)
	_build_d4_dandelion_patch(geom)
	_build_d4_rope_swing(geom)
	_build_d4_ancient_willow(geom)
	_build_d4_garden_statue(geom)
	_build_d4_forager_npc(town)
	_build_d4_fairy_lights(geom)
	_build_d4_petal_drift(geom)
	_build_d4_thornling_patrol(geom)
	_build_d4_archery_range(geom)
	_build_d4_ranger_npc(town)
	_build_d4_rabbit_family(geom)
	_build_d4_ivy_stone_arch(geom)
	_build_d4_druid_circle(geom)
	_build_d4_ancient_sundial(geom)
	_build_d4_merchant_cart(geom)
	_build_d4_traveling_merchant_npc(town)
	_build_d4_fireflies(geom)
	_build_d4_pollen_veil(geom)
	_build_d4_lantern_path(geom)
	_build_d4_blossom_bridge(geom)
	_build_d4_songbird_flock(geom)
	_build_d4_blossom_shrine(geom)
	_build_d4_blossom_drake(geom)
	_build_d4_flower_clock(geom)
	_build_d4_lovers_bench(geom)
	_build_d4_apprentice_gardener_npc(town)
	_build_d4_sunflower_field(geom)
	_build_d4_welcome_banner(geom)
	_build_d4_grand_altar(geom)
	_build_d4_district_plaque(geom)
	_build_d4_ambient_tweak(geom)
	_build_d4_bloom_elder(geom)
	#print("[D4Builder] done")


func _build_d4_ground(geom: Node) -> void:
	## Epic-4 T1b: D4 ground — green organic floor extending from x=190 to
	## x=250. Uses a green grid shader variant.
	var plane: PlaneMesh = PlaneMesh.new()
	plane.size = Vector2(60, 40)
	var ground: MeshInstance3D = MeshInstance3D.new()
	ground.name = "D4Ground"
	ground.mesh = plane
	ground.position = Vector3(220, 0, 0)
	# Green organic grid shader
	var shader: Shader = Shader.new()
	shader.code = """
shader_type spatial;
render_mode unshaded;
uniform vec3 base_color = vec3(0.04, 0.10, 0.04);
uniform vec3 grid_color = vec3(0.30, 1.00, 0.40);
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
	# Ground collision
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var bs: BoxShape3D = BoxShape3D.new()
	bs.size = Vector3(60, 0.10, 40)
	cs.shape = bs
	cs.position = Vector3(0, -0.05, 0)
	sb.add_child(cs)
	ground.add_child(sb)


func _build_d4_entrance_arch(geom: Node) -> void:
	## Epic-4 T2: a wide vine-covered organic arch reading "BLOOM CLUSTER".
	var arch: Node3D = Node3D.new()
	arch.name = "D4EntranceArch"
	arch.position = Vector3(192, 0, 0)
	geom.add_child(arch)
	# Wood material with green emission
	var wood_mat: StandardMaterial3D = StandardMaterial3D.new()
	wood_mat.albedo_color = Color(0.30, 0.18, 0.10)
	wood_mat.metallic = 0.10
	wood_mat.roughness = 0.65
	wood_mat.emission_enabled = true
	wood_mat.emission = Color(0.45, 1.0, 0.55)
	wood_mat.emission_energy_multiplier = 0.35
	# 2 wide pillars
	for sx: float in [-4.5, 4.5]:
		var pillar: MeshInstance3D = MeshInstance3D.new()
		var pmesh: CylinderMesh = CylinderMesh.new()
		pmesh.top_radius = 0.65
		pmesh.bottom_radius = 0.85
		pmesh.height = 8.0
		pillar.mesh = pmesh
		pillar.position = Vector3(sx, 4.0, 0)
		pillar.material_override = wood_mat
		arch.add_child(pillar)
		# Spiral vine wrapping the pillar (small green torus rings up the column)
		for v in 6:
			var vine: MeshInstance3D = MeshInstance3D.new()
			var vmesh: TorusMesh = TorusMesh.new()
			vmesh.inner_radius = 0.85
			vmesh.outer_radius = 0.95
			vine.mesh = vmesh
			vine.position = Vector3(sx, 1.0 + v * 1.20, 0)
			var vmat: StandardMaterial3D = StandardMaterial3D.new()
			vmat.albedo_color = Color(0.30, 0.65, 0.30)
			vmat.emission_enabled = true
			vmat.emission = Color(0.45, 1.0, 0.55)
			vmat.emission_energy_multiplier = 1.4
			vmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
			vine.material_override = vmat
			arch.add_child(vine)
		# Collision per pillar
		var sb: StaticBody3D = StaticBody3D.new()
		var cs: CollisionShape3D = CollisionShape3D.new()
		var cap: CapsuleShape3D = CapsuleShape3D.new()
		cap.radius = 0.95
		cap.height = 8.0
		cs.shape = cap
		cs.position = Vector3(sx, 4.0, 0)
		sb.add_child(cs)
		arch.add_child(sb)
	# Top wood crossbar
	var crossbar: MeshInstance3D = MeshInstance3D.new()
	var cm: BoxMesh = BoxMesh.new()
	cm.size = Vector3(11.0, 0.85, 1.40)
	crossbar.mesh = cm
	crossbar.position = Vector3(0, 8.40, 0)
	crossbar.material_override = wood_mat
	arch.add_child(crossbar)
	# Big bloom flower in center of crossbar — pink+yellow petals
	var bloom: MeshInstance3D = MeshInstance3D.new()
	var bm: SphereMesh = SphereMesh.new()
	bm.radius = 0.55
	bm.height = 1.10
	bloom.mesh = bm
	bloom.position = Vector3(0, 9.30, 0)
	var bmat: StandardMaterial3D = StandardMaterial3D.new()
	bmat.albedo_color = Color(1.0, 0.55, 0.85)
	bmat.emission_enabled = true
	bmat.emission = Color(1.0, 0.65, 0.85)
	bmat.emission_energy_multiplier = 2.4
	bmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	bloom.material_override = bmat
	arch.add_child(bloom)
	# Pulse the bloom
	var pulse: Tween = create_tween().set_loops()
	pulse.tween_property(bloom, "scale", Vector3(1.30, 1.30, 1.30), 1.6).set_ease(Tween.EASE_IN_OUT)
	pulse.tween_property(bloom, "scale", Vector3(0.85, 0.85, 0.85), 1.6).set_ease(Tween.EASE_IN_OUT)
	# District name on crossbar both sides
	for fz: float in [-0.71, 0.71]:
		var label: Label3D = Label3D.new()
		label.text = "BLOOM CLUSTER"
		label.position = Vector3(0, 8.40, fz)
		label.rotation = Vector3(0, deg_to_rad(0 if fz > 0 else 180), 0)
		label.modulate = Color(0.45, 1.0, 0.55)
		label.outline_modulate = Color(0, 0, 0, 0.85)
		label.outline_size = 6
		label.font_size = 26
		label.no_depth_test = true
		arch.add_child(label)


func _build_d4_great_bloom(geom: Node) -> void:
	## Epic-4 T3: GREAT BLOOM — a 10m-tall flower in the center. Massive
	## stem cylinder + multi-layered petal sphere arrangement on top.
	var bloom_root: Node3D = Node3D.new()
	bloom_root.name = "D4GreatBloom"
	bloom_root.position = D4_CENTER
	geom.add_child(bloom_root)
	# Tall thick stem cylinder
	var stem_mat: StandardMaterial3D = StandardMaterial3D.new()
	stem_mat.albedo_color = Color(0.20, 0.55, 0.20)
	stem_mat.emission_enabled = true
	stem_mat.emission = Color(0.45, 1.0, 0.55)
	stem_mat.emission_energy_multiplier = 0.85
	stem_mat.metallic = 0.20
	stem_mat.roughness = 0.55
	var stem: MeshInstance3D = MeshInstance3D.new()
	var smesh: CylinderMesh = CylinderMesh.new()
	smesh.top_radius = 0.45
	smesh.bottom_radius = 0.85
	smesh.height = 6.0
	stem.mesh = smesh
	stem.position = Vector3(0, 3.0, 0)
	stem.material_override = stem_mat
	bloom_root.add_child(stem)
	# Pivot for the flower head
	var pivot: Node3D = Node3D.new()
	pivot.position = Vector3(0, 6.0, 0)
	bloom_root.add_child(pivot)
	# Center sphere — glowing yellow pollen pod
	var center: MeshInstance3D = MeshInstance3D.new()
	var cm: SphereMesh = SphereMesh.new()
	cm.radius = 0.85
	cm.height = 1.70
	center.mesh = cm
	center.position = Vector3(0, 0, 0)
	var center_mat: StandardMaterial3D = StandardMaterial3D.new()
	center_mat.albedo_color = Color(1.0, 0.95, 0.30)
	center_mat.emission_enabled = true
	center_mat.emission = Color(1.0, 0.95, 0.30)
	center_mat.emission_energy_multiplier = 3.0
	center_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	center.material_override = center_mat
	pivot.add_child(center)
	# 8 large petal spheres arranged around the center
	var petal_mat: StandardMaterial3D = StandardMaterial3D.new()
	petal_mat.albedo_color = Color(1.0, 0.55, 0.85)
	petal_mat.emission_enabled = true
	petal_mat.emission = Color(1.0, 0.65, 0.85)
	petal_mat.emission_energy_multiplier = 1.8
	petal_mat.metallic = 0.20
	petal_mat.roughness = 0.30
	for i in 8:
		var angle: float = (float(i) / 8.0) * TAU
		var petal: MeshInstance3D = MeshInstance3D.new()
		var pm: SphereMesh = SphereMesh.new()
		pm.radius = 0.85
		pm.height = 1.70
		petal.mesh = pm
		petal.position = Vector3(cos(angle) * 1.55, 0, sin(angle) * 1.55)
		petal.scale = Vector3(0.85, 0.4, 1.20)
		petal.material_override = petal_mat
		pivot.add_child(petal)
	# Slow rotation
	var spin: Tween = create_tween().set_loops()
	spin.tween_property(pivot, "rotation:y", TAU, 16.0)
	# Bob in place
	var bob: Tween = create_tween().set_loops()
	bob.tween_property(pivot, "position:y", 6.55, 2.4).set_ease(Tween.EASE_IN_OUT)
	bob.tween_property(pivot, "position:y", 6.0, 2.4).set_ease(Tween.EASE_IN_OUT)
	# Real OmniLight from the bloom
	var light: OmniLight3D = OmniLight3D.new()
	light.position = Vector3(0, 0, 0)
	light.light_color = Color(1.0, 0.85, 0.65)
	light.light_energy = 3.0
	light.omni_range = 22.0
	pivot.add_child(light)
	# Sign
	var label: Label3D = Label3D.new()
	label.text = "GREAT BLOOM"
	label.position = Vector3(0, 8.85, 0)
	label.modulate = Color(1.0, 0.65, 0.85)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 6
	label.font_size = 22
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	bloom_root.add_child(label)
	# Collision around stem
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cap: CapsuleShape3D = CapsuleShape3D.new()
	cap.radius = 1.0
	cap.height = 6.0
	cs.shape = cap
	cs.position = Vector3(0, 3.0, 0)
	sb.add_child(cs)
	bloom_root.add_child(sb)


func _build_d4_bloomling(geom: Node) -> void:
	## Epic-4 T4: a friendly bloomling — small plant creature with a
	## flower head, 2 leaf arms, and a wandering hop animation.
	var bloomling: Node3D = Node3D.new()
	bloomling.name = "D4Bloomling"
	bloomling.position = D4_CENTER + Vector3(8, 0, 4)
	geom.add_child(bloomling)
	# Body — short capsule
	var body_mat: StandardMaterial3D = StandardMaterial3D.new()
	body_mat.albedo_color = Color(0.30, 0.65, 0.30)
	body_mat.emission_enabled = true
	body_mat.emission = Color(0.45, 1.0, 0.55)
	body_mat.emission_energy_multiplier = 0.85
	body_mat.metallic = 0.10
	body_mat.roughness = 0.55
	var body: MeshInstance3D = MeshInstance3D.new()
	var bmesh: SphereMesh = SphereMesh.new()
	bmesh.radius = 0.40
	bmesh.height = 0.65
	body.mesh = bmesh
	body.position = Vector3(0, 0.40, 0)
	body.material_override = body_mat
	bloomling.add_child(body)
	# Flower head — sphere
	var head: MeshInstance3D = MeshInstance3D.new()
	var hmesh: SphereMesh = SphereMesh.new()
	hmesh.radius = 0.30
	hmesh.height = 0.60
	head.mesh = hmesh
	head.position = Vector3(0, 0.95, 0)
	var hmat: StandardMaterial3D = StandardMaterial3D.new()
	hmat.albedo_color = Color(1.0, 0.55, 0.85)
	hmat.emission_enabled = true
	hmat.emission = Color(1.0, 0.65, 0.85)
	hmat.emission_energy_multiplier = 2.0
	hmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	head.material_override = hmat
	bloomling.add_child(head)
	# 2 white eye dots
	var eye_mat: StandardMaterial3D = StandardMaterial3D.new()
	eye_mat.albedo_color = Color(1, 1, 1)
	eye_mat.emission_enabled = true
	eye_mat.emission = Color(1, 1, 1)
	eye_mat.emission_energy_multiplier = 2.6
	eye_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for ex: float in [-0.10, 0.10]:
		var eye: MeshInstance3D = MeshInstance3D.new()
		var em: SphereMesh = SphereMesh.new()
		em.radius = 0.05
		em.height = 0.10
		eye.mesh = em
		eye.position = Vector3(ex, 0.95, 0.25)
		eye.material_override = eye_mat
		bloomling.add_child(eye)
	# 2 leaf arms — flat angled boxes
	for sx: float in [-1.0, 1.0]:
		var arm: MeshInstance3D = MeshInstance3D.new()
		var am: BoxMesh = BoxMesh.new()
		am.size = Vector3(0.40, 0.04, 0.20)
		arm.mesh = am
		arm.position = Vector3(sx * 0.55, 0.50, 0)
		arm.rotation = Vector3(0, 0, sign(sx) * deg_to_rad(20))
		arm.material_override = body_mat
		bloomling.add_child(arm)
	# Hop tween
	var hop: Tween = create_tween().set_loops()
	hop.tween_property(body, "position:y", 0.65, 0.4).set_ease(Tween.EASE_OUT)
	hop.tween_property(body, "position:y", 0.40, 0.30).set_ease(Tween.EASE_IN)
	hop.tween_interval(0.5)
	# Slow patrol path
	var origin: Vector3 = D4_CENTER + Vector3(8, 0, 4)
	var patrol: Tween = create_tween().set_loops()
	patrol.tween_property(bloomling, "position", origin + Vector3(4, 0, 4), 6.0).set_ease(Tween.EASE_IN_OUT)
	patrol.tween_property(bloomling, "position", origin + Vector3(-4, 0, 4), 6.0).set_ease(Tween.EASE_IN_OUT)
	patrol.tween_property(bloomling, "position", origin, 6.0).set_ease(Tween.EASE_IN_OUT)
	# Friendly name
	var label: Label3D = Label3D.new()
	label.text = "Bloomling"
	label.position = Vector3(0, 1.55, 0)
	label.modulate = Color(0.45, 1.0, 0.55)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 16
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	bloomling.add_child(label)


func _build_d4_gardener_npc(town: Node) -> void:
	## Epic-4 T5: Gardener NPC — friendly green-robed figure with a small
	## watering can in one hand and a flower-petal hat.
	var slots: Node3D = town.get_node_or_null("%NPCSlots") as Node3D
	if slots == null:
		return
	var gardener: Node3D = Node3D.new()
	gardener.name = "D4Gardener"
	gardener.position = D4_CENTER + Vector3(-12, 0, 4)
	slots.add_child(gardener)
	# Robed body
	var bmat: StandardMaterial3D = StandardMaterial3D.new()
	bmat.albedo_color = Color(0.30, 0.65, 0.30)
	bmat.metallic = 0.20
	bmat.roughness = 0.55
	bmat.emission_enabled = true
	bmat.emission = Color(0.45, 1.0, 0.55)
	bmat.emission_energy_multiplier = 0.40
	var body: MeshInstance3D = MeshInstance3D.new()
	var bmesh: CapsuleMesh = CapsuleMesh.new()
	bmesh.radius = 0.45
	bmesh.height = 1.40
	body.mesh = bmesh
	body.position = Vector3(0, 0.70, 0)
	body.material_override = bmat
	gardener.add_child(body)
	# Head
	var head: MeshInstance3D = MeshInstance3D.new()
	var hmesh: SphereMesh = SphereMesh.new()
	hmesh.radius = 0.36
	hmesh.height = 0.65
	head.mesh = hmesh
	head.position = Vector3(0, 1.55, 0)
	head.material_override = bmat
	gardener.add_child(head)
	# Petal hat (3 layered torus)
	var hat_mat: StandardMaterial3D = StandardMaterial3D.new()
	hat_mat.albedo_color = Color(1.0, 0.55, 0.85)
	hat_mat.emission_enabled = true
	hat_mat.emission = Color(1.0, 0.65, 0.85)
	hat_mat.emission_energy_multiplier = 1.4
	hat_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for i in 3:
		var petal: MeshInstance3D = MeshInstance3D.new()
		var pm: TorusMesh = TorusMesh.new()
		pm.inner_radius = 0.30 - i * 0.05
		pm.outer_radius = 0.45 - i * 0.05
		petal.mesh = pm
		petal.position = Vector3(0, 1.85 + i * 0.10, 0)
		petal.material_override = hat_mat
		gardener.add_child(petal)
	# 2 brown eyes
	var eye_mat: StandardMaterial3D = StandardMaterial3D.new()
	eye_mat.albedo_color = Color(0.30, 0.18, 0.10)
	eye_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for ex: float in [-0.10, 0.10]:
		var eye: MeshInstance3D = MeshInstance3D.new()
		var em: SphereMesh = SphereMesh.new()
		em.radius = 0.05
		em.height = 0.10
		eye.mesh = em
		eye.position = Vector3(ex, 1.55, 0.32)
		eye.material_override = eye_mat
		gardener.add_child(eye)
	# Watering can held in front (small box + spout)
	var can_mat: StandardMaterial3D = StandardMaterial3D.new()
	can_mat.albedo_color = Color(0.55, 0.55, 0.65)
	can_mat.metallic = 0.85
	can_mat.roughness = 0.30
	var can: MeshInstance3D = MeshInstance3D.new()
	var cm: BoxMesh = BoxMesh.new()
	cm.size = Vector3(0.30, 0.30, 0.30)
	can.mesh = cm
	can.position = Vector3(0.45, 0.85, 0.30)
	can.material_override = can_mat
	gardener.add_child(can)
	# Spout cylinder
	var spout: MeshInstance3D = MeshInstance3D.new()
	var sm: CylinderMesh = CylinderMesh.new()
	sm.top_radius = 0.04
	sm.bottom_radius = 0.06
	sm.height = 0.40
	spout.mesh = sm
	spout.position = Vector3(0.65, 0.95, 0.30)
	spout.rotation = Vector3(0, 0, deg_to_rad(60))
	spout.material_override = can_mat
	gardener.add_child(spout)
	# Name billboard
	var label: Label3D = Label3D.new()
	label.text = "Gardener"
	label.position = Vector3(0, 2.45, 0)
	label.modulate = Color(0.45, 1.0, 0.55)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 18
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	gardener.add_child(label)


func _build_d4_bush_cluster(geom: Node) -> void:
	## Epic-4 T6: 8 round green bushes scattered across the district.
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 277
	for i in 8:
		var bush: MeshInstance3D = MeshInstance3D.new()
		bush.name = "D4Bush_%d" % i
		var bm: SphereMesh = SphereMesh.new()
		bm.radius = rng.randf_range(0.55, 0.95)
		bm.height = bm.radius * 2
		bush.mesh = bm
		bush.position = D4_CENTER + Vector3(rng.randf_range(-22, 22), bm.radius * 0.85, rng.randf_range(-16, 16))
		var bmat: StandardMaterial3D = StandardMaterial3D.new()
		bmat.albedo_color = Color(0.20, 0.55, 0.20)
		bmat.emission_enabled = true
		bmat.emission = Color(0.45, 1.0, 0.45)
		bmat.emission_energy_multiplier = 0.55
		bmat.metallic = 0.10
		bmat.roughness = 0.65
		bush.material_override = bmat
		geom.add_child(bush)
		var sb: StaticBody3D = StaticBody3D.new()
		var cs: CollisionShape3D = CollisionShape3D.new()
		var cap: CapsuleShape3D = CapsuleShape3D.new()
		cap.radius = bm.radius
		cap.height = bm.radius * 2
		cs.shape = cap
		sb.add_child(cs)
		bush.add_child(sb)


func _build_d4_mushroom_forest(geom: Node) -> void:
	## Epic-4 T7: 8 glowing mushrooms with bioluminescent caps.
	var positions: Array[Vector3] = [
		D4_CENTER + Vector3(-15, 0, 8),
		D4_CENTER + Vector3(-13, 0, 10),
		D4_CENTER + Vector3(-11, 0, 9),
		D4_CENTER + Vector3(-14, 0, 12),
		D4_CENTER + Vector3(-16, 0, 11),
		D4_CENTER + Vector3(-12, 0, 13),
		D4_CENTER + Vector3(-10, 0, 11),
		D4_CENTER + Vector3(-15, 0, 14),
	]
	var cap_colors: Array[Color] = [
		Color(0.55, 0.95, 1.0),
		Color(1.0, 0.55, 1.0),
		Color(0.45, 1.0, 0.55),
		Color(1.0, 0.95, 0.30),
		Color(1.0, 0.55, 0.20),
		Color(0.85, 0.40, 1.0),
		Color(0.55, 0.95, 1.0),
		Color(1.0, 0.30, 0.55),
	]
	for i in positions.size():
		var shroom: Node3D = Node3D.new()
		shroom.name = "D4Mushroom_%d" % i
		shroom.position = positions[i]
		geom.add_child(shroom)
		var height: float = 0.55 + (i % 3) * 0.30
		var stem: MeshInstance3D = MeshInstance3D.new()
		var sm: CylinderMesh = CylinderMesh.new()
		sm.top_radius = 0.10
		sm.bottom_radius = 0.14
		sm.height = height
		stem.mesh = sm
		stem.position = Vector3(0, height * 0.5, 0)
		var smat: StandardMaterial3D = StandardMaterial3D.new()
		smat.albedo_color = Color(0.95, 0.95, 0.85)
		smat.metallic = 0.10
		smat.roughness = 0.65
		smat.emission_enabled = true
		smat.emission = Color(1.0, 1.0, 0.85)
		smat.emission_energy_multiplier = 0.55
		stem.material_override = smat
		shroom.add_child(stem)
		var cap: MeshInstance3D = MeshInstance3D.new()
		var cm: SphereMesh = SphereMesh.new()
		cm.radius = 0.30 + (i % 2) * 0.10
		cm.height = cm.radius
		cap.mesh = cm
		cap.position = Vector3(0, height + cm.radius * 0.4, 0)
		cap.scale = Vector3(1.0, 0.55, 1.0)
		var cmat: StandardMaterial3D = StandardMaterial3D.new()
		cmat.albedo_color = cap_colors[i]
		cmat.emission_enabled = true
		cmat.emission = cap_colors[i]
		cmat.emission_energy_multiplier = 2.4
		cmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		cap.material_override = cmat
		shroom.add_child(cap)


func _build_d4_vine_canopy(geom: Node) -> void:
	## Epic-4 T8: overhead vine canopy at 5m altitude.
	var canopy: Node3D = Node3D.new()
	canopy.name = "D4VineCanopy"
	canopy.position = D4_CENTER + Vector3(0, 5.0, 0)
	geom.add_child(canopy)
	var vine_mat: StandardMaterial3D = StandardMaterial3D.new()
	vine_mat.albedo_color = Color(0.20, 0.55, 0.20)
	vine_mat.emission_enabled = true
	vine_mat.emission = Color(0.45, 1.0, 0.45)
	vine_mat.emission_energy_multiplier = 0.85
	vine_mat.metallic = 0.10
	vine_mat.roughness = 0.65
	for i in 3:
		var vine: MeshInstance3D = MeshInstance3D.new()
		var vm: CylinderMesh = CylinderMesh.new()
		vm.top_radius = 0.15
		vm.bottom_radius = 0.15
		vm.height = 12.0
		vine.mesh = vm
		vine.position = Vector3(0, 0, -8 + i * 8)
		vine.rotation = Vector3(0, 0, deg_to_rad(90))
		vine.material_override = vine_mat
		canopy.add_child(vine)
	for i in 3:
		var vine: MeshInstance3D = MeshInstance3D.new()
		var vm: CylinderMesh = CylinderMesh.new()
		vm.top_radius = 0.15
		vm.bottom_radius = 0.15
		vm.height = 12.0
		vine.mesh = vm
		vine.position = Vector3(-8 + i * 8, 0.30, 0)
		vine.rotation = Vector3(deg_to_rad(90), 0, 0)
		vine.material_override = vine_mat
		canopy.add_child(vine)
	for i in 12:
		var leaf: MeshInstance3D = MeshInstance3D.new()
		var lm: PrismMesh = PrismMesh.new()
		lm.size = Vector3(0.30, 0.55, 0.10)
		leaf.mesh = lm
		leaf.position = Vector3(randf_range(-8, 8), -0.55, randf_range(-8, 8))
		leaf.rotation = Vector3(deg_to_rad(180), randf() * TAU, 0)
		leaf.material_override = vine_mat
		canopy.add_child(leaf)


func _build_d4_botanist_npc(town: Node) -> void:
	## Epic-4 T9: Botanist NPC with green coat and magnifying glass.
	var slots: Node3D = town.get_node_or_null("%NPCSlots") as Node3D
	if slots == null:
		return
	var bot: Node3D = Node3D.new()
	bot.name = "D4Botanist"
	bot.position = D4_CENTER + Vector3(-12, 0, 12)
	slots.add_child(bot)
	var bmat: StandardMaterial3D = StandardMaterial3D.new()
	bmat.albedo_color = Color(0.30, 0.65, 0.30)
	bmat.metallic = 0.20
	bmat.roughness = 0.55
	bmat.emission_enabled = true
	bmat.emission = Color(0.45, 1.0, 0.45)
	bmat.emission_energy_multiplier = 0.40
	var body: MeshInstance3D = MeshInstance3D.new()
	var bmesh: CapsuleMesh = CapsuleMesh.new()
	bmesh.radius = 0.42
	bmesh.height = 1.30
	body.mesh = bmesh
	body.position = Vector3(0, 0.70, 0)
	body.material_override = bmat
	bot.add_child(body)
	var head: MeshInstance3D = MeshInstance3D.new()
	var hmesh: SphereMesh = SphereMesh.new()
	hmesh.radius = 0.36
	hmesh.height = 0.65
	head.mesh = hmesh
	head.position = Vector3(0, 1.55, 0)
	var hmat: StandardMaterial3D = StandardMaterial3D.new()
	hmat.albedo_color = Color(0.85, 0.65, 0.45)
	head.material_override = hmat
	bot.add_child(head)
	# Glasses
	var glass_mat: StandardMaterial3D = StandardMaterial3D.new()
	glass_mat.albedo_color = Color(0.08, 0.08, 0.10)
	glass_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for ex: float in [-0.13, 0.13]:
		var glass: MeshInstance3D = MeshInstance3D.new()
		var gm: TorusMesh = TorusMesh.new()
		gm.inner_radius = 0.06
		gm.outer_radius = 0.10
		glass.mesh = gm
		glass.position = Vector3(ex, 1.55, 0.32)
		glass.rotation = Vector3(deg_to_rad(90), 0, 0)
		glass.material_override = glass_mat
		bot.add_child(glass)
	# Magnifying glass
	var handle: MeshInstance3D = MeshInstance3D.new()
	var ham: CylinderMesh = CylinderMesh.new()
	ham.top_radius = 0.04
	ham.bottom_radius = 0.04
	ham.height = 0.40
	handle.mesh = ham
	handle.position = Vector3(0.40, 0.85, 0.30)
	handle.rotation = Vector3(0, 0, deg_to_rad(-25))
	var hand_mat: StandardMaterial3D = StandardMaterial3D.new()
	hand_mat.albedo_color = Color(0.30, 0.18, 0.10)
	handle.material_override = hand_mat
	bot.add_child(handle)
	var lens: MeshInstance3D = MeshInstance3D.new()
	var lm: TorusMesh = TorusMesh.new()
	lm.inner_radius = 0.10
	lm.outer_radius = 0.18
	lens.mesh = lm
	lens.position = Vector3(0.55, 1.20, 0.30)
	var lmat: StandardMaterial3D = StandardMaterial3D.new()
	lmat.albedo_color = Color(0.85, 0.65, 0.30)
	lmat.metallic = 0.85
	lmat.emission_enabled = true
	lmat.emission = Color(1.0, 0.85, 0.30)
	lmat.emission_energy_multiplier = 0.85
	lens.material_override = lmat
	bot.add_child(lens)
	var label: Label3D = Label3D.new()
	label.text = "Botanist"
	label.position = Vector3(0, 2.20, 0)
	label.modulate = Color(0.45, 1.0, 0.55)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 18
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	bot.add_child(label)


func _build_d4_beehive(geom: Node) -> void:
	## Epic-4 T10: hanging beehive with bee particles.
	var hive: Node3D = Node3D.new()
	hive.name = "D4Beehive"
	hive.position = D4_CENTER + Vector3(15, 0, 12)
	geom.add_child(hive)
	var wood_mat: StandardMaterial3D = StandardMaterial3D.new()
	wood_mat.albedo_color = Color(0.30, 0.18, 0.10)
	wood_mat.metallic = 0.10
	wood_mat.roughness = 0.65
	var post: MeshInstance3D = MeshInstance3D.new()
	var pm: CylinderMesh = CylinderMesh.new()
	pm.top_radius = 0.18
	pm.bottom_radius = 0.30
	pm.height = 4.0
	post.mesh = pm
	post.position = Vector3(0, 2.0, 0)
	post.material_override = wood_mat
	hive.add_child(post)
	var branch: MeshInstance3D = MeshInstance3D.new()
	var bm: CylinderMesh = CylinderMesh.new()
	bm.top_radius = 0.10
	bm.bottom_radius = 0.10
	bm.height = 1.40
	branch.mesh = bm
	branch.position = Vector3(0.55, 3.85, 0)
	branch.rotation = Vector3(0, 0, deg_to_rad(90))
	branch.material_override = wood_mat
	hive.add_child(branch)
	var hive_mat: StandardMaterial3D = StandardMaterial3D.new()
	hive_mat.albedo_color = Color(0.85, 0.65, 0.20)
	hive_mat.emission_enabled = true
	hive_mat.emission = Color(1.0, 0.75, 0.25)
	hive_mat.emission_energy_multiplier = 0.85
	for i in 3:
		var seg: MeshInstance3D = MeshInstance3D.new()
		var sm: SphereMesh = SphereMesh.new()
		sm.radius = 0.40 - i * 0.05
		sm.height = sm.radius
		seg.mesh = sm
		seg.position = Vector3(1.20, 3.30 - i * 0.40, 0)
		seg.scale = Vector3(1.0, 0.65, 1.0)
		seg.material_override = hive_mat
		hive.add_child(seg)
	var bees: GPUParticles3D = GPUParticles3D.new()
	bees.amount = 25
	bees.lifetime = 4.0
	bees.position = Vector3(1.20, 3.0, 0)
	var pmat: ParticleProcessMaterial = ParticleProcessMaterial.new()
	pmat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	pmat.emission_sphere_radius = 0.85
	pmat.spread = 180.0
	pmat.initial_velocity_min = 0.30
	pmat.initial_velocity_max = 0.85
	pmat.scale_min = 0.04
	pmat.scale_max = 0.08
	pmat.color = Color(1.0, 0.95, 0.30, 1.0)
	bees.process_material = pmat
	var bee_mesh: SphereMesh = SphereMesh.new()
	bee_mesh.radius = 0.05
	bee_mesh.height = 0.10
	var bee_mat: StandardMaterial3D = StandardMaterial3D.new()
	bee_mat.albedo_color = Color(1.0, 0.95, 0.30)
	bee_mat.emission_enabled = true
	bee_mat.emission = Color(1.0, 0.95, 0.30)
	bee_mat.emission_energy_multiplier = 2.6
	bee_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	bee_mesh.material = bee_mat
	bees.draw_pass_1 = bee_mesh
	hive.add_child(bees)
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cap: CapsuleShape3D = CapsuleShape3D.new()
	cap.radius = 0.45
	cap.height = 4.0
	cs.shape = cap
	cs.position = Vector3(0, 2.0, 0)
	sb.add_child(cs)
	hive.add_child(sb)


func _build_d4_meadow_flowers(geom: Node) -> void:
	## Epic-4 T11: 24 small flower stem+head clusters scattered across D4.
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 311
	var colors: Array[Color] = [
		Color(1.0, 0.55, 0.85),
		Color(1.0, 0.95, 0.30),
		Color(0.85, 0.40, 1.0),
		Color(1.0, 0.55, 0.20),
		Color(0.55, 0.95, 1.0),
	]
	var stem_mat: StandardMaterial3D = StandardMaterial3D.new()
	stem_mat.albedo_color = Color(0.30, 0.65, 0.30)
	stem_mat.emission_enabled = true
	stem_mat.emission = Color(0.45, 1.0, 0.45)
	stem_mat.emission_energy_multiplier = 0.65
	for i in 24:
		var flower: Node3D = Node3D.new()
		flower.name = "D4MeadowFlower_%d" % i
		flower.position = D4_CENTER + Vector3(
			rng.randf_range(-22, 22),
			0,
			rng.randf_range(-16, 16)
		)
		geom.add_child(flower)
		var stem: MeshInstance3D = MeshInstance3D.new()
		var sm: CylinderMesh = CylinderMesh.new()
		sm.top_radius = 0.04
		sm.bottom_radius = 0.05
		sm.height = 0.55
		stem.mesh = sm
		stem.position = Vector3(0, 0.27, 0)
		stem.material_override = stem_mat
		flower.add_child(stem)
		var head: MeshInstance3D = MeshInstance3D.new()
		var hm: SphereMesh = SphereMesh.new()
		hm.radius = 0.10
		hm.height = 0.20
		head.mesh = hm
		head.position = Vector3(0, 0.60, 0)
		var color: Color = colors[i % colors.size()]
		var hmat: StandardMaterial3D = StandardMaterial3D.new()
		hmat.albedo_color = color
		hmat.emission_enabled = true
		hmat.emission = color
		hmat.emission_energy_multiplier = 1.8
		hmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		head.material_override = hmat
		flower.add_child(head)


func _build_d4_butterflies(geom: Node) -> void:
	## Epic-4 T12: 30 butterfly particles drifting near the great bloom.
	var fly: GPUParticles3D = GPUParticles3D.new()
	fly.name = "D4Butterflies"
	fly.position = D4_CENTER + Vector3(0, 3, 0)
	fly.amount = 30
	fly.lifetime = 6.0
	fly.preprocess = 3.0
	var pmat: ParticleProcessMaterial = ParticleProcessMaterial.new()
	pmat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	pmat.emission_box_extents = Vector3(8, 2, 8)
	pmat.direction = Vector3(0, 0, 0)
	pmat.spread = 180.0
	pmat.initial_velocity_min = 0.30
	pmat.initial_velocity_max = 0.85
	pmat.gravity = Vector3.ZERO
	pmat.scale_min = 0.10
	pmat.scale_max = 0.18
	pmat.color = Color(1.0, 0.55, 0.85, 1.0)
	fly.process_material = pmat
	var bm: BoxMesh = BoxMesh.new()
	bm.size = Vector3(0.18, 0.04, 0.10)
	var bmat: StandardMaterial3D = StandardMaterial3D.new()
	bmat.albedo_color = Color(1.0, 0.55, 0.85)
	bmat.emission_enabled = true
	bmat.emission = Color(1.0, 0.65, 0.85)
	bmat.emission_energy_multiplier = 1.8
	bmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	bm.material = bmat
	fly.draw_pass_1 = bm
	geom.add_child(fly)


func _build_d4_watering_well(geom: Node) -> void:
	## Epic-4 T13: stone watering well with bucket.
	var well: Node3D = Node3D.new()
	well.name = "D4WateringWell"
	well.position = D4_CENTER + Vector3(8, 0, -8)
	geom.add_child(well)
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.55, 0.50, 0.45)
	stone_mat.metallic = 0.30
	stone_mat.roughness = 0.65
	# Round well wall — torus
	var rim: MeshInstance3D = MeshInstance3D.new()
	var rmesh: TorusMesh = TorusMesh.new()
	rmesh.inner_radius = 0.85
	rmesh.outer_radius = 1.10
	rim.mesh = rmesh
	rim.position = Vector3(0, 0.50, 0)
	rim.material_override = stone_mat
	well.add_child(rim)
	# Water inside
	var water: MeshInstance3D = MeshInstance3D.new()
	var wmesh: CylinderMesh = CylinderMesh.new()
	wmesh.top_radius = 0.85
	wmesh.bottom_radius = 0.85
	wmesh.height = 0.06
	water.mesh = wmesh
	water.position = Vector3(0, 0.50, 0)
	var wmat: StandardMaterial3D = StandardMaterial3D.new()
	wmat.albedo_color = Color(0.30, 0.55, 0.85, 0.85)
	wmat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	wmat.emission_enabled = true
	wmat.emission = Color(0.55, 0.85, 1.0)
	wmat.emission_energy_multiplier = 1.0
	wmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	water.material_override = wmat
	well.add_child(water)
	# Wood arch over the well
	var wood_mat: StandardMaterial3D = StandardMaterial3D.new()
	wood_mat.albedo_color = Color(0.30, 0.18, 0.10)
	for sx: float in [-0.85, 0.85]:
		var leg: MeshInstance3D = MeshInstance3D.new()
		var lm: BoxMesh = BoxMesh.new()
		lm.size = Vector3(0.14, 2.40, 0.14)
		leg.mesh = lm
		leg.position = Vector3(sx, 1.20, 0)
		leg.material_override = wood_mat
		well.add_child(leg)
	var crossbar: MeshInstance3D = MeshInstance3D.new()
	var cm: BoxMesh = BoxMesh.new()
	cm.size = Vector3(2.0, 0.18, 0.18)
	crossbar.mesh = cm
	crossbar.position = Vector3(0, 2.40, 0)
	crossbar.material_override = wood_mat
	well.add_child(crossbar)
	# Hanging bucket
	var bucket: MeshInstance3D = MeshInstance3D.new()
	var bm: CylinderMesh = CylinderMesh.new()
	bm.top_radius = 0.20
	bm.bottom_radius = 0.18
	bm.height = 0.30
	bucket.mesh = bm
	bucket.position = Vector3(0, 1.85, 0)
	bucket.material_override = wood_mat
	well.add_child(bucket)
	# Collision
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(2.20, 2.40, 2.20)
	cs.shape = cb
	cs.position = Vector3(0, 1.20, 0)
	sb.add_child(cs)
	well.add_child(sb)


func _build_d4_farmer_npc(town: Node) -> void:
	## Epic-4 T14: Farmer NPC with straw hat and pitchfork.
	var slots: Node3D = town.get_node_or_null("%NPCSlots") as Node3D
	if slots == null:
		return
	var farmer: Node3D = Node3D.new()
	farmer.name = "D4Farmer"
	farmer.position = D4_CENTER + Vector3(15, 0, -8)
	slots.add_child(farmer)
	var bmat: StandardMaterial3D = StandardMaterial3D.new()
	bmat.albedo_color = Color(0.55, 0.40, 0.20)
	bmat.metallic = 0.10
	bmat.roughness = 0.65
	bmat.emission_enabled = true
	bmat.emission = Color(0.85, 0.65, 0.30)
	bmat.emission_energy_multiplier = 0.30
	var body: MeshInstance3D = MeshInstance3D.new()
	var bmesh: CapsuleMesh = CapsuleMesh.new()
	bmesh.radius = 0.42
	bmesh.height = 1.30
	body.mesh = bmesh
	body.position = Vector3(0, 0.70, 0)
	body.material_override = bmat
	farmer.add_child(body)
	# Straw hat — wide flat cylinder
	var hat: MeshInstance3D = MeshInstance3D.new()
	var hm: CylinderMesh = CylinderMesh.new()
	hm.top_radius = 0.55
	hm.bottom_radius = 0.55
	hm.height = 0.10
	hat.mesh = hm
	hat.position = Vector3(0, 1.65, 0)
	var hmat: StandardMaterial3D = StandardMaterial3D.new()
	hmat.albedo_color = Color(0.85, 0.65, 0.30)
	hmat.metallic = 0.10
	hmat.roughness = 0.85
	hat.material_override = hmat
	farmer.add_child(hat)
	# Eyes
	var eye_mat: StandardMaterial3D = StandardMaterial3D.new()
	eye_mat.albedo_color = Color(0.30, 0.18, 0.10)
	eye_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for ex: float in [-0.10, 0.10]:
		var eye: MeshInstance3D = MeshInstance3D.new()
		var em: SphereMesh = SphereMesh.new()
		em.radius = 0.05
		em.height = 0.10
		eye.mesh = em
		eye.position = Vector3(ex, 1.50, 0.32)
		eye.material_override = eye_mat
		farmer.add_child(eye)
	# Pitchfork
	var fork: MeshInstance3D = MeshInstance3D.new()
	var fm: CylinderMesh = CylinderMesh.new()
	fm.top_radius = 0.05
	fm.bottom_radius = 0.05
	fm.height = 2.40
	fork.mesh = fm
	fork.position = Vector3(0.50, 1.20, 0)
	var fork_mat: StandardMaterial3D = StandardMaterial3D.new()
	fork_mat.albedo_color = Color(0.30, 0.18, 0.10)
	fork.material_override = fork_mat
	farmer.add_child(fork)
	# Name billboard
	var label: Label3D = Label3D.new()
	label.text = "Farmer"
	label.position = Vector3(0, 2.20, 0)
	label.modulate = Color(0.85, 0.65, 0.30)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 18
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	farmer.add_child(label)


func _build_d4_scarecrow(geom: Node) -> void:
	## Epic-4 T15: a straw scarecrow on a wooden cross post.
	var crow: Node3D = Node3D.new()
	crow.name = "D4Scarecrow"
	crow.position = D4_CENTER + Vector3(18, 0, -4)
	geom.add_child(crow)
	var wood_mat: StandardMaterial3D = StandardMaterial3D.new()
	wood_mat.albedo_color = Color(0.30, 0.18, 0.10)
	# Vertical post
	var post: MeshInstance3D = MeshInstance3D.new()
	var pm: CylinderMesh = CylinderMesh.new()
	pm.top_radius = 0.07
	pm.bottom_radius = 0.10
	pm.height = 2.85
	post.mesh = pm
	post.position = Vector3(0, 1.42, 0)
	post.material_override = wood_mat
	crow.add_child(post)
	# Cross arms
	var arms: MeshInstance3D = MeshInstance3D.new()
	var am: BoxMesh = BoxMesh.new()
	am.size = Vector3(2.0, 0.10, 0.10)
	arms.mesh = am
	arms.position = Vector3(0, 2.20, 0)
	arms.material_override = wood_mat
	crow.add_child(arms)
	# Straw head — yellow sphere
	var straw_mat: StandardMaterial3D = StandardMaterial3D.new()
	straw_mat.albedo_color = Color(0.95, 0.85, 0.30)
	straw_mat.emission_enabled = true
	straw_mat.emission = Color(1.0, 0.95, 0.30)
	straw_mat.emission_energy_multiplier = 0.55
	var head: MeshInstance3D = MeshInstance3D.new()
	var hmesh: SphereMesh = SphereMesh.new()
	hmesh.radius = 0.40
	hmesh.height = 0.80
	head.mesh = hmesh
	head.position = Vector3(0, 2.85, 0)
	head.material_override = straw_mat
	crow.add_child(head)
	# Conical hat
	var hat: MeshInstance3D = MeshInstance3D.new()
	var hat_mesh: PrismMesh = PrismMesh.new()
	hat_mesh.size = Vector3(0.55, 0.40, 0.55)
	hat.mesh = hat_mesh
	hat.position = Vector3(0, 3.30, 0)
	var hat_mat: StandardMaterial3D = StandardMaterial3D.new()
	hat_mat.albedo_color = Color(0.18, 0.10, 0.06)
	hat.material_override = hat_mat
	crow.add_child(hat)
	# X eyes (black bars)
	var eye_mat: StandardMaterial3D = StandardMaterial3D.new()
	eye_mat.albedo_color = Color(0.05, 0.05, 0.10)
	eye_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for ex: float in [-0.12, 0.12]:
		var eye: MeshInstance3D = MeshInstance3D.new()
		var em: BoxMesh = BoxMesh.new()
		em.size = Vector3(0.10, 0.10, 0.04)
		eye.mesh = em
		eye.position = Vector3(ex, 2.85, 0.36)
		eye.material_override = eye_mat
		crow.add_child(eye)
	# Collision
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cap: CapsuleShape3D = CapsuleShape3D.new()
	cap.radius = 0.30
	cap.height = 3.40
	cs.shape = cap
	cs.position = Vector3(0, 1.70, 0)
	sb.add_child(cs)
	crow.add_child(sb)


func _build_d4_tree_grove(geom: Node) -> void:
	## Epic-4 T16: 5 medium-sized trees in a grove cluster.
	var positions: Array[Vector3] = [
		D4_CENTER + Vector3(-18, 0, -10),
		D4_CENTER + Vector3(-15, 0, -8),
		D4_CENTER + Vector3(-20, 0, -6),
		D4_CENTER + Vector3(-16, 0, -12),
		D4_CENTER + Vector3(-12, 0, -10),
	]
	var trunk_mat: StandardMaterial3D = StandardMaterial3D.new()
	trunk_mat.albedo_color = Color(0.30, 0.18, 0.10)
	trunk_mat.metallic = 0.10
	trunk_mat.roughness = 0.65
	var leaves_mat: StandardMaterial3D = StandardMaterial3D.new()
	leaves_mat.albedo_color = Color(0.20, 0.55, 0.20)
	leaves_mat.emission_enabled = true
	leaves_mat.emission = Color(0.45, 1.0, 0.45)
	leaves_mat.emission_energy_multiplier = 0.55
	for i in positions.size():
		var tree: Node3D = Node3D.new()
		tree.name = "D4Tree_%d" % i
		tree.position = positions[i]
		geom.add_child(tree)
		var trunk: MeshInstance3D = MeshInstance3D.new()
		var tm: CylinderMesh = CylinderMesh.new()
		tm.top_radius = 0.30
		tm.bottom_radius = 0.45
		tm.height = 3.0
		trunk.mesh = tm
		trunk.position = Vector3(0, 1.50, 0)
		trunk.material_override = trunk_mat
		tree.add_child(trunk)
		var leaves: MeshInstance3D = MeshInstance3D.new()
		var lm: SphereMesh = SphereMesh.new()
		lm.radius = 1.40
		lm.height = 2.80
		leaves.mesh = lm
		leaves.position = Vector3(0, 4.0, 0)
		leaves.material_override = leaves_mat
		tree.add_child(leaves)
		var sb: StaticBody3D = StaticBody3D.new()
		var cs: CollisionShape3D = CollisionShape3D.new()
		var cap: CapsuleShape3D = CapsuleShape3D.new()
		cap.radius = 0.55
		cap.height = 3.0
		cs.shape = cap
		cs.position = Vector3(0, 1.50, 0)
		sb.add_child(cs)
		tree.add_child(sb)


func _build_d4_apple_tree(geom: Node) -> void:
	## Epic-4 T17: a single big apple tree with red apples on the leaves.
	var tree: Node3D = Node3D.new()
	tree.name = "D4AppleTree"
	tree.position = D4_CENTER + Vector3(15, 0, -16)
	geom.add_child(tree)
	var trunk_mat: StandardMaterial3D = StandardMaterial3D.new()
	trunk_mat.albedo_color = Color(0.30, 0.18, 0.10)
	var trunk: MeshInstance3D = MeshInstance3D.new()
	var tm: CylinderMesh = CylinderMesh.new()
	tm.top_radius = 0.55
	tm.bottom_radius = 0.85
	tm.height = 4.0
	trunk.mesh = tm
	trunk.position = Vector3(0, 2.0, 0)
	trunk.material_override = trunk_mat
	tree.add_child(trunk)
	var leaves: MeshInstance3D = MeshInstance3D.new()
	var lm: SphereMesh = SphereMesh.new()
	lm.radius = 2.40
	lm.height = 4.80
	leaves.mesh = lm
	leaves.position = Vector3(0, 5.0, 0)
	var lmat: StandardMaterial3D = StandardMaterial3D.new()
	lmat.albedo_color = Color(0.20, 0.55, 0.20)
	lmat.emission_enabled = true
	lmat.emission = Color(0.45, 1.0, 0.45)
	lmat.emission_energy_multiplier = 0.55
	leaves.material_override = lmat
	tree.add_child(leaves)
	# 8 red apple spheres
	var apple_mat: StandardMaterial3D = StandardMaterial3D.new()
	apple_mat.albedo_color = Color(1.0, 0.20, 0.20)
	apple_mat.emission_enabled = true
	apple_mat.emission = Color(1.0, 0.30, 0.30)
	apple_mat.emission_energy_multiplier = 1.4
	apple_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for i in 8:
		var angle: float = (float(i) / 8.0) * TAU
		var apple: MeshInstance3D = MeshInstance3D.new()
		var am: SphereMesh = SphereMesh.new()
		am.radius = 0.18
		am.height = 0.36
		apple.mesh = am
		apple.position = Vector3(cos(angle) * 1.85, 4.5 + sin(i * 0.85) * 0.55, sin(angle) * 1.85)
		apple.material_override = apple_mat
		tree.add_child(apple)
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cap: CapsuleShape3D = CapsuleShape3D.new()
	cap.radius = 0.95
	cap.height = 4.0
	cs.shape = cap
	cs.position = Vector3(0, 2.0, 0)
	sb.add_child(cs)
	tree.add_child(sb)


func _build_d4_fish_pond(geom: Node) -> void:
	## Epic-4 T18: oval fish pond with stone rim + 3 circling fish.
	var pond: Node3D = Node3D.new()
	pond.name = "D4FishPond"
	pond.position = D4_CENTER + Vector3(-8, 0, 14)
	geom.add_child(pond)
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.55, 0.50, 0.45)
	stone_mat.metallic = 0.30
	var rim: MeshInstance3D = MeshInstance3D.new()
	var rm: TorusMesh = TorusMesh.new()
	rm.inner_radius = 1.85
	rm.outer_radius = 2.20
	rim.mesh = rm
	rim.position = Vector3(0, 0.10, 0)
	rim.material_override = stone_mat
	pond.add_child(rim)
	# Water
	var water: MeshInstance3D = MeshInstance3D.new()
	var wm: CylinderMesh = CylinderMesh.new()
	wm.top_radius = 1.85
	wm.bottom_radius = 1.85
	wm.height = 0.06
	water.mesh = wm
	water.position = Vector3(0, 0.10, 0)
	var wmat: StandardMaterial3D = StandardMaterial3D.new()
	wmat.albedo_color = Color(0.30, 0.65, 0.85, 0.85)
	wmat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	wmat.emission_enabled = true
	wmat.emission = Color(0.55, 0.85, 1.0)
	wmat.emission_energy_multiplier = 1.4
	wmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	water.material_override = wmat
	pond.add_child(water)
	# 3 fish circling on a pivot
	var fish_pivot: Node3D = Node3D.new()
	fish_pivot.position = Vector3(0, 0.30, 0)
	pond.add_child(fish_pivot)
	for i in 3:
		var angle: float = (float(i) / 3.0) * TAU
		var fish: MeshInstance3D = MeshInstance3D.new()
		var fm: BoxMesh = BoxMesh.new()
		fm.size = Vector3(0.30, 0.10, 0.10)
		fish.mesh = fm
		fish.position = Vector3(cos(angle) * 1.20, 0, sin(angle) * 1.20)
		fish.rotation = Vector3(0, -angle - PI * 0.5, 0)
		var fmat: StandardMaterial3D = StandardMaterial3D.new()
		fmat.albedo_color = Color(1.0, 0.55, 0.20)
		fmat.emission_enabled = true
		fmat.emission = Color(1.0, 0.65, 0.20)
		fmat.emission_energy_multiplier = 2.0
		fmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		fish.material_override = fmat
		fish_pivot.add_child(fish)
	var spin: Tween = create_tween().set_loops()
	spin.tween_property(fish_pivot, "rotation:y", TAU, 6.0)


func _build_d4_fisherman_npc(town: Node) -> void:
	## Epic-4 T19: Fisherman NPC by the pond holding a fishing rod.
	var slots: Node3D = town.get_node_or_null("%NPCSlots") as Node3D
	if slots == null:
		return
	var fish: Node3D = Node3D.new()
	fish.name = "D4Fisherman"
	fish.position = D4_CENTER + Vector3(-10, 0, 12)
	slots.add_child(fish)
	var bmat: StandardMaterial3D = StandardMaterial3D.new()
	bmat.albedo_color = Color(0.30, 0.55, 0.85)
	bmat.metallic = 0.20
	bmat.roughness = 0.55
	bmat.emission_enabled = true
	bmat.emission = Color(0.55, 0.85, 1.0)
	bmat.emission_energy_multiplier = 0.30
	var body: MeshInstance3D = MeshInstance3D.new()
	var bmesh: CapsuleMesh = CapsuleMesh.new()
	bmesh.radius = 0.42
	bmesh.height = 1.30
	body.mesh = bmesh
	body.position = Vector3(0, 0.70, 0)
	body.material_override = bmat
	fish.add_child(body)
	var head: MeshInstance3D = MeshInstance3D.new()
	var hm: SphereMesh = SphereMesh.new()
	hm.radius = 0.36
	hm.height = 0.65
	head.mesh = hm
	head.position = Vector3(0, 1.55, 0)
	var hmat: StandardMaterial3D = StandardMaterial3D.new()
	hmat.albedo_color = Color(0.85, 0.65, 0.45)
	head.material_override = hmat
	fish.add_child(head)
	# Fishing rod — long thin angled cylinder
	var rod: MeshInstance3D = MeshInstance3D.new()
	var rm: CylinderMesh = CylinderMesh.new()
	rm.top_radius = 0.04
	rm.bottom_radius = 0.06
	rm.height = 2.40
	rod.mesh = rm
	rod.position = Vector3(0.55, 1.50, 0.55)
	rod.rotation = Vector3(deg_to_rad(45), 0, deg_to_rad(-15))
	var rmat: StandardMaterial3D = StandardMaterial3D.new()
	rmat.albedo_color = Color(0.30, 0.18, 0.10)
	rod.material_override = rmat
	fish.add_child(rod)
	# Name billboard
	var label: Label3D = Label3D.new()
	label.text = "Fisherman"
	label.position = Vector3(0, 2.20, 0)
	label.modulate = Color(0.55, 0.85, 1.0)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 18
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	fish.add_child(label)


func _build_d4_lily_pads(geom: Node) -> void:
	## Epic-4 T20: 6 lily pads scattered on the pond surface.
	var positions: Array[Vector3] = [
		D4_CENTER + Vector3(-9, 0.18, 13),
		D4_CENTER + Vector3(-7, 0.18, 14),
		D4_CENTER + Vector3(-8, 0.18, 15),
		D4_CENTER + Vector3(-9, 0.18, 15),
		D4_CENTER + Vector3(-7, 0.18, 13),
		D4_CENTER + Vector3(-8, 0.18, 12),
	]
	var pad_mat: StandardMaterial3D = StandardMaterial3D.new()
	pad_mat.albedo_color = Color(0.20, 0.55, 0.20)
	pad_mat.emission_enabled = true
	pad_mat.emission = Color(0.45, 1.0, 0.45)
	pad_mat.emission_energy_multiplier = 0.85
	var flower_mat: StandardMaterial3D = StandardMaterial3D.new()
	flower_mat.albedo_color = Color(1.0, 0.55, 0.85)
	flower_mat.emission_enabled = true
	flower_mat.emission = Color(1.0, 0.65, 0.85)
	flower_mat.emission_energy_multiplier = 1.8
	flower_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for i in positions.size():
		var pad: MeshInstance3D = MeshInstance3D.new()
		pad.name = "D4LilyPad_%d" % i
		var pm: CylinderMesh = CylinderMesh.new()
		pm.top_radius = 0.30
		pm.bottom_radius = 0.30
		pm.height = 0.06
		pad.mesh = pm
		pad.position = positions[i]
		pad.material_override = pad_mat
		geom.add_child(pad)
		# Small lily flower on top of every other pad
		if i % 2 == 0:
			var flower: MeshInstance3D = MeshInstance3D.new()
			var fm: SphereMesh = SphereMesh.new()
			fm.radius = 0.10
			fm.height = 0.20
			flower.mesh = fm
			flower.position = positions[i] + Vector3(0, 0.12, 0)
			flower.material_override = flower_mat
			geom.add_child(flower)


func _build_d4_greenhouse_building(geom: Node) -> void:
	## Epic-4 T21: a glass greenhouse building.
	var house: Node3D = Node3D.new()
	house.name = "D4Greenhouse"
	house.position = D4_CENTER + Vector3(15, 0, 8)
	geom.add_child(house)
	var glass_mat: StandardMaterial3D = StandardMaterial3D.new()
	glass_mat.albedo_color = Color(0.55, 0.95, 0.85, 0.30)
	glass_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	glass_mat.emission_enabled = true
	glass_mat.emission = Color(0.45, 1.0, 0.55)
	glass_mat.emission_energy_multiplier = 0.55
	glass_mat.metallic = 0.30
	glass_mat.roughness = 0.10
	# Walls
	var body: MeshInstance3D = MeshInstance3D.new()
	var bm: BoxMesh = BoxMesh.new()
	bm.size = Vector3(3.40, 2.85, 2.40)
	body.mesh = bm
	body.position = Vector3(0, 1.42, 0)
	body.material_override = glass_mat
	house.add_child(body)
	# Pitched roof
	var roof: MeshInstance3D = MeshInstance3D.new()
	var rm: PrismMesh = PrismMesh.new()
	rm.size = Vector3(3.40, 1.0, 2.40)
	roof.mesh = rm
	roof.position = Vector3(0, 3.40, 0)
	roof.material_override = glass_mat
	house.add_child(roof)
	# 4 corner posts
	var frame_mat: StandardMaterial3D = StandardMaterial3D.new()
	frame_mat.albedo_color = Color(0.30, 0.18, 0.10)
	for ox: float in [-1.70, 1.70]:
		for oz: float in [-1.20, 1.20]:
			var post: MeshInstance3D = MeshInstance3D.new()
			var pm: BoxMesh = BoxMesh.new()
			pm.size = Vector3(0.10, 2.85, 0.10)
			post.mesh = pm
			post.position = Vector3(ox, 1.42, oz)
			post.material_override = frame_mat
			house.add_child(post)
	# Sign
	var label: Label3D = Label3D.new()
	label.text = "GREENHOUSE"
	label.position = Vector3(0, 4.40, 0)
	label.modulate = Color(0.45, 1.0, 0.55)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 18
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	house.add_child(label)
	# Collision
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(3.40, 2.85, 2.40)
	cs.shape = cb
	cs.position = Vector3(0, 1.42, 0)
	sb.add_child(cs)
	house.add_child(sb)


func _build_d4_plant_pot_row(geom: Node) -> void:
	## Epic-4 T22: 6 small plant pots in a row near the greenhouse.
	var pot_mat: StandardMaterial3D = StandardMaterial3D.new()
	pot_mat.albedo_color = Color(0.55, 0.30, 0.20)
	var plant_mat: StandardMaterial3D = StandardMaterial3D.new()
	plant_mat.albedo_color = Color(0.20, 0.55, 0.20)
	plant_mat.emission_enabled = true
	plant_mat.emission = Color(0.45, 1.0, 0.45)
	plant_mat.emission_energy_multiplier = 0.65
	for i in 6:
		var pot: Node3D = Node3D.new()
		pot.name = "D4Pot_%d" % i
		pot.position = D4_CENTER + Vector3(11 + i * 0.85, 0, 10)
		geom.add_child(pot)
		var pot_body: MeshInstance3D = MeshInstance3D.new()
		var pm: CylinderMesh = CylinderMesh.new()
		pm.top_radius = 0.30
		pm.bottom_radius = 0.20
		pm.height = 0.40
		pot_body.mesh = pm
		pot_body.position = Vector3(0, 0.20, 0)
		pot_body.material_override = pot_mat
		pot.add_child(pot_body)
		# Plant on top
		var plant: MeshInstance3D = MeshInstance3D.new()
		var plm: SphereMesh = SphereMesh.new()
		plm.radius = 0.22
		plm.height = 0.44
		plant.mesh = plm
		plant.position = Vector3(0, 0.55, 0)
		plant.material_override = plant_mat
		pot.add_child(plant)


func _build_d4_ladybug_creature(geom: Node) -> void:
	## Epic-4 T23: large red ladybug with black spots wandering on a patrol.
	var bug: Node3D = Node3D.new()
	bug.name = "D4Ladybug"
	bug.position = D4_CENTER + Vector3(5, 0, 10)
	geom.add_child(bug)
	# Red body shell — flattened sphere
	var body: MeshInstance3D = MeshInstance3D.new()
	var bm: SphereMesh = SphereMesh.new()
	bm.radius = 0.45
	bm.height = 0.65
	body.mesh = bm
	body.position = Vector3(0, 0.40, 0)
	body.scale = Vector3(1.0, 0.7, 1.20)
	var bmat: StandardMaterial3D = StandardMaterial3D.new()
	bmat.albedo_color = Color(1.0, 0.20, 0.20)
	bmat.emission_enabled = true
	bmat.emission = Color(1.0, 0.30, 0.30)
	bmat.emission_energy_multiplier = 1.4
	body.material_override = bmat
	bug.add_child(body)
	# 4 black spots on top
	var spot_mat: StandardMaterial3D = StandardMaterial3D.new()
	spot_mat.albedo_color = Color(0.05, 0.05, 0.10)
	spot_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for spec in [Vector3(-0.20, 0.65, 0.10), Vector3(0.20, 0.65, 0.10), Vector3(-0.20, 0.65, -0.10), Vector3(0.20, 0.65, -0.10)]:
		var spot: MeshInstance3D = MeshInstance3D.new()
		var sm: SphereMesh = SphereMesh.new()
		sm.radius = 0.10
		sm.height = 0.20
		spot.mesh = sm
		spot.position = spec
		spot.material_override = spot_mat
		bug.add_child(spot)
	# Patrol path
	var origin: Vector3 = D4_CENTER + Vector3(5, 0, 10)
	var patrol: Tween = create_tween().set_loops()
	patrol.tween_property(bug, "position", origin + Vector3(3, 0, 3), 5.0)
	patrol.tween_property(bug, "position", origin + Vector3(-3, 0, 3), 5.0)
	patrol.tween_property(bug, "position", origin, 5.0)


func _build_d4_chef_npc(town: Node) -> void:
	## Epic-4 T24: Chef NPC with white outfit and tall chef hat.
	var slots: Node3D = town.get_node_or_null("%NPCSlots") as Node3D
	if slots == null:
		return
	var chef: Node3D = Node3D.new()
	chef.name = "D4Chef"
	chef.position = D4_CENTER + Vector3(15, 0, -3)
	slots.add_child(chef)
	var bmat: StandardMaterial3D = StandardMaterial3D.new()
	bmat.albedo_color = Color(0.95, 0.95, 0.95)
	bmat.metallic = 0.10
	bmat.roughness = 0.55
	bmat.emission_enabled = true
	bmat.emission = Color(1.0, 1.0, 1.0)
	bmat.emission_energy_multiplier = 0.30
	var body: MeshInstance3D = MeshInstance3D.new()
	var bmesh: CapsuleMesh = CapsuleMesh.new()
	bmesh.radius = 0.45
	bmesh.height = 1.40
	body.mesh = bmesh
	body.position = Vector3(0, 0.70, 0)
	body.material_override = bmat
	chef.add_child(body)
	# Tall chef hat — cylinder + dome top
	var hat: MeshInstance3D = MeshInstance3D.new()
	var hm: CylinderMesh = CylinderMesh.new()
	hm.top_radius = 0.30
	hm.bottom_radius = 0.30
	hm.height = 0.65
	hat.mesh = hm
	hat.position = Vector3(0, 1.95, 0)
	hat.material_override = bmat
	chef.add_child(hat)
	var hat_top: MeshInstance3D = MeshInstance3D.new()
	var htm: SphereMesh = SphereMesh.new()
	htm.radius = 0.40
	htm.height = 0.40
	hat_top.mesh = htm
	hat_top.position = Vector3(0, 2.40, 0)
	hat_top.scale = Vector3(1.0, 0.55, 1.0)
	hat_top.material_override = bmat
	chef.add_child(hat_top)
	var label: Label3D = Label3D.new()
	label.text = "Chef"
	label.position = Vector3(0, 2.95, 0)
	label.modulate = Color(1, 1, 1)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 18
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	chef.add_child(label)


func _build_d4_soup_pot(geom: Node) -> void:
	## Epic-4 T25: a large iron pot with bubbling orange soup and steam.
	var pot: Node3D = Node3D.new()
	pot.name = "D4SoupPot"
	pot.position = D4_CENTER + Vector3(13, 0, -3)
	geom.add_child(pot)
	var iron_mat: StandardMaterial3D = StandardMaterial3D.new()
	iron_mat.albedo_color = Color(0.16, 0.16, 0.18)
	iron_mat.metallic = 0.85
	iron_mat.roughness = 0.30
	var pot_body: MeshInstance3D = MeshInstance3D.new()
	var pm: CylinderMesh = CylinderMesh.new()
	pm.top_radius = 0.55
	pm.bottom_radius = 0.45
	pm.height = 0.85
	pot_body.mesh = pm
	pot_body.position = Vector3(0, 0.42, 0)
	pot_body.material_override = iron_mat
	pot.add_child(pot_body)
	# Soup inside
	var soup: MeshInstance3D = MeshInstance3D.new()
	var sm: CylinderMesh = CylinderMesh.new()
	sm.top_radius = 0.50
	sm.bottom_radius = 0.50
	sm.height = 0.06
	soup.mesh = sm
	soup.position = Vector3(0, 0.85, 0)
	var sm_mat: StandardMaterial3D = StandardMaterial3D.new()
	sm_mat.albedo_color = Color(1.0, 0.55, 0.20)
	sm_mat.emission_enabled = true
	sm_mat.emission = Color(1.0, 0.65, 0.20)
	sm_mat.emission_energy_multiplier = 1.4
	sm_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	soup.material_override = sm_mat
	pot.add_child(soup)
	# Steam particles
	var steam: GPUParticles3D = GPUParticles3D.new()
	steam.amount = 25
	steam.lifetime = 2.5
	steam.position = Vector3(0, 1.40, 0)
	var pmat: ParticleProcessMaterial = ParticleProcessMaterial.new()
	pmat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	pmat.emission_sphere_radius = 0.30
	pmat.direction = Vector3(0, 1, 0)
	pmat.spread = 18.0
	pmat.initial_velocity_min = 0.55
	pmat.initial_velocity_max = 1.0
	pmat.gravity = Vector3.ZERO
	pmat.scale_min = 0.30
	pmat.scale_max = 0.55
	pmat.color = Color(0.95, 0.95, 1.0, 0.55)
	steam.process_material = pmat
	var smesh: SphereMesh = SphereMesh.new()
	smesh.radius = 0.30
	smesh.height = 0.60
	var st_mat: StandardMaterial3D = StandardMaterial3D.new()
	st_mat.albedo_color = Color(0.95, 0.95, 1.0, 0.55)
	st_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	st_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	smesh.material = st_mat
	steam.draw_pass_1 = smesh
	pot.add_child(steam)
	# Collision
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cap: CapsuleShape3D = CapsuleShape3D.new()
	cap.radius = 0.65
	cap.height = 0.85
	cs.shape = cap
	cs.position = Vector3(0, 0.42, 0)
	sb.add_child(cs)
	pot.add_child(sb)


func _build_d4_stone_path(geom: Node) -> void:
	## Epic-4 T26: 12 cracked stone path tiles winding through D4.
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.55, 0.50, 0.45)
	stone_mat.metallic = 0.30
	stone_mat.roughness = 0.65
	for i in 12:
		var t: float = float(i) / 12.0
		var x: float = 192.0 + i * 2.4
		var z: float = sin(t * 4.0) * 1.6
		var tile: MeshInstance3D = MeshInstance3D.new()
		tile.name = "D4PathTile_%d" % i
		var tm: BoxMesh = BoxMesh.new()
		tm.size = Vector3(1.40, 0.10, 1.40)
		tile.mesh = tm
		tile.position = Vector3(x, 0.05, z)
		tile.rotation = Vector3(0, deg_to_rad(randf_range(-15, 15)), 0)
		tile.material_override = stone_mat
		geom.add_child(tile)


func _build_d4_windmill(geom: Node) -> void:
	## Epic-4 T27: a tall windmill — round stone tower + 4 rotating blades.
	var mill: Node3D = Node3D.new()
	mill.name = "D4Windmill"
	mill.position = D4_CENTER + Vector3(-15, 0, -16)
	geom.add_child(mill)
	# Tower body
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.55, 0.50, 0.45)
	var tower: MeshInstance3D = MeshInstance3D.new()
	var tm: CylinderMesh = CylinderMesh.new()
	tm.top_radius = 1.20
	tm.bottom_radius = 1.40
	tm.height = 6.0
	tower.mesh = tm
	tower.position = Vector3(0, 3.0, 0)
	tower.material_override = stone_mat
	mill.add_child(tower)
	# Roof cone
	var roof: MeshInstance3D = MeshInstance3D.new()
	var rm: PrismMesh = PrismMesh.new()
	rm.size = Vector3(2.85, 1.20, 2.85)
	roof.mesh = rm
	roof.position = Vector3(0, 6.55, 0)
	var roof_mat: StandardMaterial3D = StandardMaterial3D.new()
	roof_mat.albedo_color = Color(0.30, 0.18, 0.10)
	roof.material_override = roof_mat
	mill.add_child(roof)
	# Blade pivot at front
	var pivot: Node3D = Node3D.new()
	pivot.position = Vector3(0, 4.0, 1.40)
	mill.add_child(pivot)
	for i in 4:
		var angle: float = (float(i) / 4.0) * TAU
		var blade: MeshInstance3D = MeshInstance3D.new()
		var bm: BoxMesh = BoxMesh.new()
		bm.size = Vector3(0.40, 3.40, 0.18)
		blade.mesh = bm
		blade.position = Vector3(cos(angle) * 1.70, sin(angle) * 1.70, 0)
		blade.rotation = Vector3(0, 0, -angle)
		var bmat: StandardMaterial3D = StandardMaterial3D.new()
		bmat.albedo_color = Color(0.95, 0.95, 0.95)
		blade.material_override = bmat
		pivot.add_child(blade)
	var spin: Tween = create_tween().set_loops()
	spin.tween_property(pivot, "rotation:z", TAU, 8.0)
	# Collision around tower
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cap: CapsuleShape3D = CapsuleShape3D.new()
	cap.radius = 1.40
	cap.height = 6.0
	cs.shape = cap
	cs.position = Vector3(0, 3.0, 0)
	sb.add_child(cs)
	mill.add_child(sb)


func _build_d4_wheat_field(geom: Node) -> void:
	## Epic-4 T28: 30 wheat stalks in a 5x6 grid.
	var field: Node3D = Node3D.new()
	field.name = "D4WheatField"
	field.position = D4_CENTER + Vector3(-12, 0, -12)
	geom.add_child(field)
	var wheat_mat: StandardMaterial3D = StandardMaterial3D.new()
	wheat_mat.albedo_color = Color(0.95, 0.85, 0.30)
	wheat_mat.emission_enabled = true
	wheat_mat.emission = Color(1.0, 0.95, 0.30)
	wheat_mat.emission_energy_multiplier = 0.85
	wheat_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for r in 5:
		for c in 6:
			var stalk: MeshInstance3D = MeshInstance3D.new()
			var sm: BoxMesh = BoxMesh.new()
			sm.size = Vector3(0.06, 0.85, 0.06)
			stalk.mesh = sm
			stalk.position = Vector3(-1.5 + c * 0.65, 0.42, -1.0 + r * 0.55)
			stalk.material_override = wheat_mat
			field.add_child(stalk)


func _build_d4_miller_npc(town: Node) -> void:
	## Epic-4 T29: Miller NPC with flour-dusted apron.
	var slots: Node3D = town.get_node_or_null("%NPCSlots") as Node3D
	if slots == null:
		return
	var miller: Node3D = Node3D.new()
	miller.name = "D4Miller"
	miller.position = D4_CENTER + Vector3(-12, 0, -16)
	slots.add_child(miller)
	var bmat: StandardMaterial3D = StandardMaterial3D.new()
	bmat.albedo_color = Color(0.85, 0.65, 0.45)
	bmat.metallic = 0.10
	bmat.roughness = 0.65
	bmat.emission_enabled = true
	bmat.emission = Color(1.0, 0.85, 0.55)
	bmat.emission_energy_multiplier = 0.30
	var body: MeshInstance3D = MeshInstance3D.new()
	var bmesh: CapsuleMesh = CapsuleMesh.new()
	bmesh.radius = 0.45
	bmesh.height = 1.30
	body.mesh = bmesh
	body.position = Vector3(0, 0.70, 0)
	body.material_override = bmat
	miller.add_child(body)
	var head: MeshInstance3D = MeshInstance3D.new()
	var hm: SphereMesh = SphereMesh.new()
	hm.radius = 0.36
	hm.height = 0.65
	head.mesh = hm
	head.position = Vector3(0, 1.55, 0)
	head.material_override = bmat
	miller.add_child(head)
	var label: Label3D = Label3D.new()
	label.text = "Miller"
	label.position = Vector3(0, 2.20, 0)
	label.modulate = Color(1.0, 0.85, 0.55)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 18
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	miller.add_child(label)


func _build_d4_bread_oven(geom: Node) -> void:
	## Epic-4 T30: stone bread oven with fire mouth and chimney smoke.
	var oven: Node3D = Node3D.new()
	oven.name = "D4BreadOven"
	oven.position = D4_CENTER + Vector3(-9, 0, -16)
	geom.add_child(oven)
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.55, 0.50, 0.45)
	var body: MeshInstance3D = MeshInstance3D.new()
	var bm: BoxMesh = BoxMesh.new()
	bm.size = Vector3(1.40, 1.20, 1.40)
	body.mesh = bm
	body.position = Vector3(0, 0.60, 0)
	body.material_override = stone_mat
	oven.add_child(body)
	# Dome top
	var dome: MeshInstance3D = MeshInstance3D.new()
	var dm: SphereMesh = SphereMesh.new()
	dm.radius = 0.85
	dm.height = 0.85
	dome.mesh = dm
	dome.position = Vector3(0, 1.20, 0)
	dome.scale = Vector3(1.0, 0.6, 1.0)
	dome.material_override = stone_mat
	oven.add_child(dome)
	# Dark fire mouth
	var mouth: MeshInstance3D = MeshInstance3D.new()
	var mm: BoxMesh = BoxMesh.new()
	mm.size = Vector3(0.55, 0.40, 0.10)
	mouth.mesh = mm
	mouth.position = Vector3(0, 0.65, 0.71)
	var mmat: StandardMaterial3D = StandardMaterial3D.new()
	mmat.albedo_color = Color(0.10, 0.06, 0.04)
	mmat.emission_enabled = true
	mmat.emission = Color(1.0, 0.55, 0.20)
	mmat.emission_energy_multiplier = 2.0
	mmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mouth.material_override = mmat
	oven.add_child(mouth)
	# Chimney
	var chimney: MeshInstance3D = MeshInstance3D.new()
	var cm: BoxMesh = BoxMesh.new()
	cm.size = Vector3(0.30, 1.0, 0.30)
	chimney.mesh = cm
	chimney.position = Vector3(0, 2.0, -0.40)
	chimney.material_override = stone_mat
	oven.add_child(chimney)
	# Smoke particles
	var smoke: GPUParticles3D = GPUParticles3D.new()
	smoke.amount = 20
	smoke.lifetime = 3.0
	smoke.position = Vector3(0, 2.55, -0.40)
	var pmat: ParticleProcessMaterial = ParticleProcessMaterial.new()
	pmat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	pmat.emission_sphere_radius = 0.10
	pmat.direction = Vector3(0, 1, 0)
	pmat.spread = 12.0
	pmat.initial_velocity_min = 0.55
	pmat.initial_velocity_max = 1.0
	pmat.gravity = Vector3.ZERO
	pmat.scale_min = 0.20
	pmat.scale_max = 0.40
	pmat.color = Color(0.40, 0.40, 0.50, 0.55)
	smoke.process_material = pmat
	var sm: SphereMesh = SphereMesh.new()
	sm.radius = 0.20
	sm.height = 0.40
	var sm_mat: StandardMaterial3D = StandardMaterial3D.new()
	sm_mat.albedo_color = Color(0.40, 0.40, 0.50, 0.55)
	sm_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	sm_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	sm.material = sm_mat
	smoke.draw_pass_1 = sm
	oven.add_child(smoke)
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(1.40, 1.85, 1.40)
	cs.shape = cb
	cs.position = Vector3(0, 0.92, 0)
	sb.add_child(cs)
	oven.add_child(sb)


func _build_d4_gazebo(geom: Node) -> void:
	## Epic-4 T31: 6-column octagonal gazebo with roof.
	var gaz: Node3D = Node3D.new()
	gaz.name = "D4Gazebo"
	gaz.position = D4_CENTER + Vector3(0, 0, -14)
	geom.add_child(gaz)
	var wood_mat: StandardMaterial3D = StandardMaterial3D.new()
	wood_mat.albedo_color = Color(0.55, 0.40, 0.20)
	for i in 6:
		var angle: float = (float(i) / 6.0) * TAU
		var col: MeshInstance3D = MeshInstance3D.new()
		var cm: CylinderMesh = CylinderMesh.new()
		cm.top_radius = 0.10
		cm.bottom_radius = 0.14
		cm.height = 2.40
		col.mesh = cm
		col.position = Vector3(cos(angle) * 1.85, 1.20, sin(angle) * 1.85)
		col.material_override = wood_mat
		gaz.add_child(col)
		var sb: StaticBody3D = StaticBody3D.new()
		var cs: CollisionShape3D = CollisionShape3D.new()
		var cap: CapsuleShape3D = CapsuleShape3D.new()
		cap.radius = 0.20
		cap.height = 2.40
		cs.shape = cap
		cs.position = Vector3(cos(angle) * 1.85, 1.20, sin(angle) * 1.85)
		sb.add_child(cs)
		gaz.add_child(sb)
	# Roof — flat tapered cylinder
	var roof: MeshInstance3D = MeshInstance3D.new()
	var rm: CylinderMesh = CylinderMesh.new()
	rm.top_radius = 1.85
	rm.bottom_radius = 2.40
	rm.height = 0.85
	roof.mesh = rm
	roof.position = Vector3(0, 2.85, 0)
	roof.material_override = wood_mat
	gaz.add_child(roof)


func _build_d4_flower_wreaths(geom: Node) -> void:
	## Epic-4 T32: 4 pink flower wreaths hanging on the gazebo columns.
	var wreath_mat: StandardMaterial3D = StandardMaterial3D.new()
	wreath_mat.albedo_color = Color(1.0, 0.55, 0.85)
	wreath_mat.emission_enabled = true
	wreath_mat.emission = Color(1.0, 0.65, 0.85)
	wreath_mat.emission_energy_multiplier = 1.4
	wreath_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for i in 4:
		var angle: float = (float(i) / 4.0) * TAU
		var wreath: MeshInstance3D = MeshInstance3D.new()
		wreath.name = "D4Wreath_%d" % i
		var wm: TorusMesh = TorusMesh.new()
		wm.inner_radius = 0.30
		wm.outer_radius = 0.45
		wreath.mesh = wm
		wreath.position = D4_CENTER + Vector3(cos(angle) * 1.85, 1.85, sin(angle) * 1.85) + Vector3(0, 0, -14)
		wreath.rotation = Vector3(deg_to_rad(90), 0, 0)
		wreath.material_override = wreath_mat
		geom.add_child(wreath)


func _build_d4_bird_bath(geom: Node) -> void:
	## Epic-4 T33: stone bird bath with rim, water, and 2 small birds.
	var bath: Node3D = Node3D.new()
	bath.name = "D4BirdBath"
	bath.position = D4_CENTER + Vector3(8, 0, 16)
	geom.add_child(bath)
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.55, 0.50, 0.45)
	# Stem column
	var stem: MeshInstance3D = MeshInstance3D.new()
	var sm: CylinderMesh = CylinderMesh.new()
	sm.top_radius = 0.18
	sm.bottom_radius = 0.30
	sm.height = 1.0
	stem.mesh = sm
	stem.position = Vector3(0, 0.50, 0)
	stem.material_override = stone_mat
	bath.add_child(stem)
	# Bowl
	var bowl: MeshInstance3D = MeshInstance3D.new()
	var bm: CylinderMesh = CylinderMesh.new()
	bm.top_radius = 0.55
	bm.bottom_radius = 0.30
	bm.height = 0.20
	bowl.mesh = bm
	bowl.position = Vector3(0, 1.10, 0)
	bowl.material_override = stone_mat
	bath.add_child(bowl)
	# Water
	var water: MeshInstance3D = MeshInstance3D.new()
	var wm: CylinderMesh = CylinderMesh.new()
	wm.top_radius = 0.50
	wm.bottom_radius = 0.50
	wm.height = 0.06
	water.mesh = wm
	water.position = Vector3(0, 1.20, 0)
	var wmat: StandardMaterial3D = StandardMaterial3D.new()
	wmat.albedo_color = Color(0.30, 0.85, 1.0, 0.85)
	wmat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	wmat.emission_enabled = true
	wmat.emission = Color(0.55, 0.95, 1.0)
	wmat.emission_energy_multiplier = 1.4
	wmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	water.material_override = wmat
	bath.add_child(water)
	# 2 small birds on the rim
	var bird_mat: StandardMaterial3D = StandardMaterial3D.new()
	bird_mat.albedo_color = Color(0.85, 0.85, 0.95)
	for sx: float in [-0.40, 0.40]:
		var bird: MeshInstance3D = MeshInstance3D.new()
		var bird_mesh: SphereMesh = SphereMesh.new()
		bird_mesh.radius = 0.10
		bird_mesh.height = 0.20
		bird.mesh = bird_mesh
		bird.position = Vector3(sx, 1.30, 0)
		bird.material_override = bird_mat
		bath.add_child(bird)
	# Collision
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cap: CapsuleShape3D = CapsuleShape3D.new()
	cap.radius = 0.55
	cap.height = 1.20
	cs.shape = cap
	cs.position = Vector3(0, 0.60, 0)
	sb.add_child(cs)
	bath.add_child(sb)


func _build_d4_storyteller_npc(town: Node) -> void:
	## Epic-4 T34: Storyteller NPC standing inside the gazebo.
	var slots: Node3D = town.get_node_or_null("%NPCSlots") as Node3D
	if slots == null:
		return
	var teller: Node3D = Node3D.new()
	teller.name = "D4Storyteller"
	teller.position = D4_CENTER + Vector3(0, 0, -14)
	slots.add_child(teller)
	var bmat: StandardMaterial3D = StandardMaterial3D.new()
	bmat.albedo_color = Color(0.55, 0.30, 0.20)
	bmat.emission_enabled = true
	bmat.emission = Color(0.85, 0.55, 0.30)
	bmat.emission_energy_multiplier = 0.30
	var body: MeshInstance3D = MeshInstance3D.new()
	var bmesh: CapsuleMesh = CapsuleMesh.new()
	bmesh.radius = 0.42
	bmesh.height = 1.30
	body.mesh = bmesh
	body.position = Vector3(0, 0.70, 0)
	body.material_override = bmat
	teller.add_child(body)
	var head: MeshInstance3D = MeshInstance3D.new()
	var hm: SphereMesh = SphereMesh.new()
	hm.radius = 0.36
	hm.height = 0.65
	head.mesh = hm
	head.position = Vector3(0, 1.55, 0)
	var hmat: StandardMaterial3D = StandardMaterial3D.new()
	hmat.albedo_color = Color(0.85, 0.65, 0.45)
	head.material_override = hmat
	teller.add_child(head)
	var label: Label3D = Label3D.new()
	label.text = "Storyteller"
	label.position = Vector3(0, 2.20, 0)
	label.modulate = Color(1.0, 0.85, 0.55)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 18
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	teller.add_child(label)


func _build_d4_sleeping_cat(geom: Node) -> void:
	## Epic-4 T35: a small yellow cat curled up sleeping on a pink cushion.
	var cat: Node3D = Node3D.new()
	cat.name = "D4SleepingCat"
	cat.position = D4_CENTER + Vector3(-3, 0, 12)
	geom.add_child(cat)
	# Cushion
	var cush: MeshInstance3D = MeshInstance3D.new()
	var cm: CylinderMesh = CylinderMesh.new()
	cm.top_radius = 0.55
	cm.bottom_radius = 0.55
	cm.height = 0.18
	cush.mesh = cm
	cush.position = Vector3(0, 0.10, 0)
	var cmat: StandardMaterial3D = StandardMaterial3D.new()
	cmat.albedo_color = Color(0.85, 0.55, 0.85)
	cush.material_override = cmat
	cat.add_child(cush)
	# Cat body — curled flattened sphere
	var body: MeshInstance3D = MeshInstance3D.new()
	var bm: SphereMesh = SphereMesh.new()
	bm.radius = 0.30
	bm.height = 0.40
	body.mesh = bm
	body.position = Vector3(0, 0.30, 0)
	body.scale = Vector3(1.4, 0.85, 1.0)
	var bmat: StandardMaterial3D = StandardMaterial3D.new()
	bmat.albedo_color = Color(0.95, 0.85, 0.30)
	bmat.emission_enabled = true
	bmat.emission = Color(1.0, 0.85, 0.30)
	bmat.emission_energy_multiplier = 0.30
	body.material_override = bmat
	cat.add_child(body)
	# 2 ear prisms
	for sx: float in [-0.10, 0.10]:
		var ear: MeshInstance3D = MeshInstance3D.new()
		var em: PrismMesh = PrismMesh.new()
		em.size = Vector3(0.08, 0.10, 0.08)
		ear.mesh = em
		ear.position = Vector3(sx, 0.50, 0.30)
		ear.material_override = bmat
		cat.add_child(ear)
	# Closed eyes — black bars
	var eye_mat: StandardMaterial3D = StandardMaterial3D.new()
	eye_mat.albedo_color = Color(0.05, 0.05, 0.10)
	eye_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for ex: float in [-0.08, 0.08]:
		var eye: MeshInstance3D = MeshInstance3D.new()
		var em: BoxMesh = BoxMesh.new()
		em.size = Vector3(0.06, 0.02, 0.04)
		eye.mesh = em
		eye.position = Vector3(ex, 0.40, 0.32)
		eye.material_override = eye_mat
		cat.add_child(eye)
	# Slow breathing scale tween
	var breath: Tween = create_tween().set_loops()
	breath.tween_property(body, "scale", Vector3(1.45, 0.90, 1.05), 1.4).set_ease(Tween.EASE_IN_OUT)
	breath.tween_property(body, "scale", Vector3(1.4, 0.85, 1.0), 1.4).set_ease(Tween.EASE_IN_OUT)


func _build_d4_picnic_blanket(geom: Node) -> void:
	## Epic-4 T36: a red picnic blanket spread with a basket and 3 fruits.
	var picnic: Node3D = Node3D.new()
	picnic.name = "D4Picnic"
	picnic.position = D4_CENTER + Vector3(-3, 0, -8)
	geom.add_child(picnic)
	# Red checkered blanket — flat box
	var blanket: MeshInstance3D = MeshInstance3D.new()
	var bm: BoxMesh = BoxMesh.new()
	bm.size = Vector3(2.40, 0.05, 2.40)
	blanket.mesh = bm
	blanket.position = Vector3(0, 0.04, 0)
	var bmat: StandardMaterial3D = StandardMaterial3D.new()
	bmat.albedo_color = Color(0.85, 0.20, 0.20)
	bmat.emission_enabled = true
	bmat.emission = Color(1.0, 0.30, 0.30)
	bmat.emission_energy_multiplier = 0.45
	blanket.material_override = bmat
	picnic.add_child(blanket)
	# Wicker basket — small brown box
	var basket: MeshInstance3D = MeshInstance3D.new()
	var bk: BoxMesh = BoxMesh.new()
	bk.size = Vector3(0.55, 0.40, 0.40)
	basket.mesh = bk
	basket.position = Vector3(0, 0.30, -0.40)
	var bkmat: StandardMaterial3D = StandardMaterial3D.new()
	bkmat.albedo_color = Color(0.55, 0.40, 0.20)
	basket.material_override = bkmat
	picnic.add_child(basket)
	# 3 small fruits
	var fruit_specs: Array = [
		[Vector3(0.55, 0.18, 0.20), Color(1.0, 0.20, 0.20)],   # apple
		[Vector3(-0.40, 0.18, 0.30), Color(1.0, 0.65, 0.20)],  # orange
		[Vector3(0.20, 0.18, 0.65), Color(0.45, 1.0, 0.55)],   # apple
	]
	for spec in fruit_specs:
		var fruit: MeshInstance3D = MeshInstance3D.new()
		var fm: SphereMesh = SphereMesh.new()
		fm.radius = 0.14
		fm.height = 0.28
		fruit.mesh = fm
		fruit.position = spec[0]
		var fmat: StandardMaterial3D = StandardMaterial3D.new()
		fmat.albedo_color = spec[1]
		fmat.emission_enabled = true
		fmat.emission = spec[1]
		fmat.emission_energy_multiplier = 1.0
		fruit.material_override = fmat
		picnic.add_child(fruit)


func _build_d4_veg_cart(geom: Node) -> void:
	## Epic-4 T37: wooden vegetable cart with 2 wheels and colorful veg.
	var cart: Node3D = Node3D.new()
	cart.name = "D4VegCart"
	cart.position = D4_CENTER + Vector3(8, 0, 8)
	geom.add_child(cart)
	var wood_mat: StandardMaterial3D = StandardMaterial3D.new()
	wood_mat.albedo_color = Color(0.55, 0.40, 0.20)
	# Cart body
	var body: MeshInstance3D = MeshInstance3D.new()
	var bm: BoxMesh = BoxMesh.new()
	bm.size = Vector3(1.85, 0.65, 1.20)
	body.mesh = bm
	body.position = Vector3(0, 0.65, 0)
	body.material_override = wood_mat
	cart.add_child(body)
	# 2 wheels
	var wheel_mat: StandardMaterial3D = StandardMaterial3D.new()
	wheel_mat.albedo_color = Color(0.30, 0.18, 0.10)
	for sx: float in [-0.85, 0.85]:
		var wheel: MeshInstance3D = MeshInstance3D.new()
		var wm: CylinderMesh = CylinderMesh.new()
		wm.top_radius = 0.30
		wm.bottom_radius = 0.30
		wm.height = 0.10
		wheel.mesh = wm
		wheel.position = Vector3(sx, 0.30, 0)
		wheel.rotation = Vector3(0, 0, deg_to_rad(90))
		wheel.material_override = wheel_mat
		cart.add_child(wheel)
	# Push handle
	var handle: MeshInstance3D = MeshInstance3D.new()
	var hm: CylinderMesh = CylinderMesh.new()
	hm.top_radius = 0.05
	hm.bottom_radius = 0.05
	hm.height = 1.20
	handle.mesh = hm
	handle.position = Vector3(0, 1.0, -0.85)
	handle.rotation = Vector3(deg_to_rad(45), 0, 0)
	handle.material_override = wood_mat
	cart.add_child(handle)
	# Vegetables in a heap on top
	var veg_specs: Array = [
		[Vector3(-0.40, 1.10, 0.20), Color(1.0, 0.55, 0.20), 0.18],   # carrot
		[Vector3(0.20, 1.10, -0.20), Color(0.45, 1.0, 0.45), 0.20],   # cabbage
		[Vector3(0.55, 1.10, 0.20), Color(1.0, 0.20, 0.20), 0.16],    # tomato
		[Vector3(-0.20, 1.30, -0.10), Color(0.85, 0.65, 0.20), 0.18], # squash
	]
	for spec in veg_specs:
		var veg: MeshInstance3D = MeshInstance3D.new()
		var vm: SphereMesh = SphereMesh.new()
		vm.radius = spec[2]
		vm.height = spec[2] * 2
		veg.mesh = vm
		veg.position = spec[0]
		var vmat: StandardMaterial3D = StandardMaterial3D.new()
		vmat.albedo_color = spec[1]
		vmat.emission_enabled = true
		vmat.emission = spec[1]
		vmat.emission_energy_multiplier = 1.0
		veg.material_override = vmat
		cart.add_child(veg)
	# Collision
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(1.85, 1.40, 1.20)
	cs.shape = cb
	cs.position = Vector3(0, 0.70, 0)
	sb.add_child(cs)
	cart.add_child(sb)


func _build_d4_garden_gnomes(geom: Node) -> void:
	## Epic-4 T38: 3 garden gnome statues with red conical hats.
	var positions: Array[Vector3] = [
		D4_CENTER + Vector3(-6, 0, -3),
		D4_CENTER + Vector3(-4, 0, -4),
		D4_CENTER + Vector3(-5, 0, -5),
	]
	for i in positions.size():
		var gnome: Node3D = Node3D.new()
		gnome.name = "D4Gnome_%d" % i
		gnome.position = positions[i]
		gnome.rotation = Vector3(0, deg_to_rad(i * 90), 0)
		geom.add_child(gnome)
		# Stocky body
		var body: MeshInstance3D = MeshInstance3D.new()
		var bm: CylinderMesh = CylinderMesh.new()
		bm.top_radius = 0.18
		bm.bottom_radius = 0.30
		bm.height = 0.55
		body.mesh = bm
		body.position = Vector3(0, 0.27, 0)
		var bmat: StandardMaterial3D = StandardMaterial3D.new()
		bmat.albedo_color = Color(0.20, 0.55, 0.85)
		body.material_override = bmat
		gnome.add_child(body)
		# Round head
		var head: MeshInstance3D = MeshInstance3D.new()
		var hmesh: SphereMesh = SphereMesh.new()
		hmesh.radius = 0.18
		hmesh.height = 0.36
		head.mesh = hmesh
		head.position = Vector3(0, 0.65, 0)
		var hmat: StandardMaterial3D = StandardMaterial3D.new()
		hmat.albedo_color = Color(0.95, 0.85, 0.65)
		head.material_override = hmat
		gnome.add_child(head)
		# White beard
		var beard: MeshInstance3D = MeshInstance3D.new()
		var bbm: BoxMesh = BoxMesh.new()
		bbm.size = Vector3(0.20, 0.20, 0.06)
		beard.mesh = bbm
		beard.position = Vector3(0, 0.55, 0.16)
		var bb_mat: StandardMaterial3D = StandardMaterial3D.new()
		bb_mat.albedo_color = Color(0.95, 0.95, 1.0)
		beard.material_override = bb_mat
		gnome.add_child(beard)
		# Tall red conical hat
		var hat: MeshInstance3D = MeshInstance3D.new()
		var hat_mesh: PrismMesh = PrismMesh.new()
		hat_mesh.size = Vector3(0.30, 0.55, 0.30)
		hat.mesh = hat_mesh
		hat.position = Vector3(0, 1.05, 0)
		var hatmat: StandardMaterial3D = StandardMaterial3D.new()
		hatmat.albedo_color = Color(1.0, 0.20, 0.20)
		hatmat.emission_enabled = true
		hatmat.emission = Color(1.0, 0.30, 0.30)
		hatmat.emission_energy_multiplier = 0.85
		hat.material_override = hatmat
		gnome.add_child(hat)


func _build_d4_beekeeper_npc(town: Node) -> void:
	## Epic-4 T39: Beekeeper NPC near the beehive with a white veil hat.
	var slots: Node3D = town.get_node_or_null("%NPCSlots") as Node3D
	if slots == null:
		return
	var bk: Node3D = Node3D.new()
	bk.name = "D4Beekeeper"
	bk.position = D4_CENTER + Vector3(13, 0, 12)
	slots.add_child(bk)
	var bmat: StandardMaterial3D = StandardMaterial3D.new()
	bmat.albedo_color = Color(0.95, 0.95, 0.95)
	bmat.metallic = 0.10
	bmat.roughness = 0.55
	bmat.emission_enabled = true
	bmat.emission = Color(1.0, 1.0, 1.0)
	bmat.emission_energy_multiplier = 0.30
	var body: MeshInstance3D = MeshInstance3D.new()
	var bmesh: CapsuleMesh = CapsuleMesh.new()
	bmesh.radius = 0.45
	bmesh.height = 1.40
	body.mesh = bmesh
	body.position = Vector3(0, 0.70, 0)
	body.material_override = bmat
	bk.add_child(body)
	# Wide veil hat — flat cylinder + dome top
	var brim: MeshInstance3D = MeshInstance3D.new()
	var brm: CylinderMesh = CylinderMesh.new()
	brm.top_radius = 0.55
	brm.bottom_radius = 0.55
	brm.height = 0.06
	brim.mesh = brm
	brim.position = Vector3(0, 1.65, 0)
	brim.material_override = bmat
	bk.add_child(brim)
	# Veil — thin translucent cylinder hanging down
	var veil: MeshInstance3D = MeshInstance3D.new()
	var vm: CylinderMesh = CylinderMesh.new()
	vm.top_radius = 0.40
	vm.bottom_radius = 0.40
	vm.height = 0.55
	veil.mesh = vm
	veil.position = Vector3(0, 1.40, 0)
	var vmat: StandardMaterial3D = StandardMaterial3D.new()
	vmat.albedo_color = Color(0.95, 0.95, 0.95, 0.45)
	vmat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	veil.material_override = vmat
	bk.add_child(veil)
	# Top dome
	var dome: MeshInstance3D = MeshInstance3D.new()
	var dm: SphereMesh = SphereMesh.new()
	dm.radius = 0.30
	dm.height = 0.30
	dome.mesh = dm
	dome.position = Vector3(0, 1.85, 0)
	dome.scale = Vector3(1.0, 0.55, 1.0)
	dome.material_override = bmat
	bk.add_child(dome)
	var label: Label3D = Label3D.new()
	label.text = "Beekeeper"
	label.position = Vector3(0, 2.50, 0)
	label.modulate = Color(1.0, 0.95, 0.30)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 18
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	bk.add_child(label)


func _build_d4_honey_jars(geom: Node) -> void:
	## Epic-4 T40: 6 honey jars in a 2x3 grid on a small wooden table.
	var jars: Node3D = Node3D.new()
	jars.name = "D4HoneyJars"
	jars.position = D4_CENTER + Vector3(13, 0, 14)
	geom.add_child(jars)
	# Wood table
	var wood_mat: StandardMaterial3D = StandardMaterial3D.new()
	wood_mat.albedo_color = Color(0.55, 0.40, 0.20)
	var table: MeshInstance3D = MeshInstance3D.new()
	var tm: BoxMesh = BoxMesh.new()
	tm.size = Vector3(1.40, 0.85, 0.85)
	table.mesh = tm
	table.position = Vector3(0, 0.42, 0)
	table.material_override = wood_mat
	jars.add_child(table)
	# 6 honey jars
	var honey_mat: StandardMaterial3D = StandardMaterial3D.new()
	honey_mat.albedo_color = Color(1.0, 0.75, 0.20, 0.85)
	honey_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	honey_mat.emission_enabled = true
	honey_mat.emission = Color(1.0, 0.85, 0.30)
	honey_mat.emission_energy_multiplier = 1.4
	honey_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for r in 2:
		for c in 3:
			var jar: MeshInstance3D = MeshInstance3D.new()
			var jm: CylinderMesh = CylinderMesh.new()
			jm.top_radius = 0.10
			jm.bottom_radius = 0.14
			jm.height = 0.30
			jar.mesh = jm
			jar.position = Vector3(-0.40 + c * 0.40, 1.0, -0.18 + r * 0.36)
			jar.material_override = honey_mat
			jars.add_child(jar)
	# Collision around table
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(1.40, 1.40, 0.85)
	cs.shape = cb
	cs.position = Vector3(0, 0.70, 0)
	sb.add_child(cs)
	jars.add_child(sb)


func _build_d4_compost_heap(geom: Node) -> void:
	## Epic-4 T41: compost heap — wooden bin frame with brown organic pile.
	var heap: Node3D = Node3D.new()
	heap.name = "D4Compost"
	heap.position = D4_CENTER + Vector3(-15, 0, -3)
	geom.add_child(heap)
	# 4 corner posts
	var wood_mat: StandardMaterial3D = StandardMaterial3D.new()
	wood_mat.albedo_color = Color(0.30, 0.18, 0.10)
	for ox: float in [-0.85, 0.85]:
		for oz: float in [-0.85, 0.85]:
			var post: MeshInstance3D = MeshInstance3D.new()
			var pm: BoxMesh = BoxMesh.new()
			pm.size = Vector3(0.10, 1.20, 0.10)
			post.mesh = pm
			post.position = Vector3(ox, 0.60, oz)
			post.material_override = wood_mat
			heap.add_child(post)
	# Side rails
	for spec in [
		[Vector3(0, 0.30, -0.85), Vector3(1.85, 0.06, 0.06)],
		[Vector3(0, 0.30, 0.85), Vector3(1.85, 0.06, 0.06)],
		[Vector3(-0.85, 0.30, 0), Vector3(0.06, 0.06, 1.85)],
		[Vector3(0.85, 0.30, 0), Vector3(0.06, 0.06, 1.85)],
		[Vector3(0, 0.85, -0.85), Vector3(1.85, 0.06, 0.06)],
		[Vector3(0, 0.85, 0.85), Vector3(1.85, 0.06, 0.06)],
		[Vector3(-0.85, 0.85, 0), Vector3(0.06, 0.06, 1.85)],
		[Vector3(0.85, 0.85, 0), Vector3(0.06, 0.06, 1.85)],
	]:
		var rail: MeshInstance3D = MeshInstance3D.new()
		var rm: BoxMesh = BoxMesh.new()
		rm.size = spec[1]
		rail.mesh = rm
		rail.position = spec[0]
		rail.material_override = wood_mat
		heap.add_child(rail)
	# Brown organic pile inside
	var pile: MeshInstance3D = MeshInstance3D.new()
	var plm: BoxMesh = BoxMesh.new()
	plm.size = Vector3(1.40, 0.85, 1.40)
	pile.mesh = plm
	pile.position = Vector3(0, 0.42, 0)
	var plmat: StandardMaterial3D = StandardMaterial3D.new()
	plmat.albedo_color = Color(0.30, 0.20, 0.10)
	plmat.emission_enabled = true
	plmat.emission = Color(0.40, 0.30, 0.10)
	plmat.emission_energy_multiplier = 0.30
	pile.material_override = plmat
	heap.add_child(pile)
	# 3 small green sprout box leaves on top
	var sprout_mat: StandardMaterial3D = StandardMaterial3D.new()
	sprout_mat.albedo_color = Color(0.45, 1.0, 0.45)
	sprout_mat.emission_enabled = true
	sprout_mat.emission = Color(0.55, 1.0, 0.55)
	sprout_mat.emission_energy_multiplier = 1.0
	sprout_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for i in 3:
		var sprout: MeshInstance3D = MeshInstance3D.new()
		var spm: BoxMesh = BoxMesh.new()
		spm.size = Vector3(0.10, 0.20, 0.10)
		sprout.mesh = spm
		sprout.position = Vector3(-0.30 + i * 0.30, 0.95, randf_range(-0.30, 0.30))
		sprout.material_override = sprout_mat
		heap.add_child(sprout)
	# Collision
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(1.85, 1.20, 1.85)
	cs.shape = cb
	cs.position = Vector3(0, 0.60, 0)
	sb.add_child(cs)
	heap.add_child(sb)


func _build_d4_painter_npc(town: Node) -> void:
	## Epic-4 T42: Painter NPC at an easel with a paint palette.
	var slots: Node3D = town.get_node_or_null("%NPCSlots") as Node3D
	if slots == null:
		return
	var p: Node3D = Node3D.new()
	p.name = "D4Painter"
	p.position = D4_CENTER + Vector3(-3, 0, 8)
	slots.add_child(p)
	var bmat: StandardMaterial3D = StandardMaterial3D.new()
	bmat.albedo_color = Color(0.85, 0.55, 0.85)
	bmat.metallic = 0.10
	bmat.emission_enabled = true
	bmat.emission = Color(1.0, 0.65, 0.95)
	bmat.emission_energy_multiplier = 0.30
	var body: MeshInstance3D = MeshInstance3D.new()
	var bmesh: CapsuleMesh = CapsuleMesh.new()
	bmesh.radius = 0.42
	bmesh.height = 1.30
	body.mesh = bmesh
	body.position = Vector3(0, 0.70, 0)
	body.material_override = bmat
	p.add_child(body)
	var head: MeshInstance3D = MeshInstance3D.new()
	var hm: SphereMesh = SphereMesh.new()
	hm.radius = 0.36
	hm.height = 0.65
	head.mesh = hm
	head.position = Vector3(0, 1.55, 0)
	var hmat: StandardMaterial3D = StandardMaterial3D.new()
	hmat.albedo_color = Color(0.85, 0.65, 0.45)
	head.material_override = hmat
	p.add_child(head)
	# Beret hat (flat torus + small cap)
	var beret: MeshInstance3D = MeshInstance3D.new()
	var brm: CylinderMesh = CylinderMesh.new()
	brm.top_radius = 0.45
	brm.bottom_radius = 0.40
	brm.height = 0.15
	beret.mesh = brm
	beret.position = Vector3(0, 1.85, 0)
	var brmat: StandardMaterial3D = StandardMaterial3D.new()
	brmat.albedo_color = Color(0.30, 0.10, 0.10)
	beret.material_override = brmat
	p.add_child(beret)
	# Paint palette held in hand — flat oval
	var palette: MeshInstance3D = MeshInstance3D.new()
	var pm: CylinderMesh = CylinderMesh.new()
	pm.top_radius = 0.30
	pm.bottom_radius = 0.30
	pm.height = 0.04
	palette.mesh = pm
	palette.position = Vector3(0.55, 0.85, 0.30)
	palette.rotation = Vector3(0, 0, deg_to_rad(-20))
	var pmat: StandardMaterial3D = StandardMaterial3D.new()
	pmat.albedo_color = Color(0.85, 0.65, 0.30)
	palette.material_override = pmat
	p.add_child(palette)
	# 5 colored paint dots on palette
	for i in 5:
		var angle: float = (float(i) / 5.0) * TAU
		var dot: MeshInstance3D = MeshInstance3D.new()
		var dm: SphereMesh = SphereMesh.new()
		dm.radius = 0.04
		dm.height = 0.08
		dot.mesh = dm
		dot.position = Vector3(0.55 + cos(angle) * 0.18, 0.92, 0.30 + sin(angle) * 0.18)
		var dot_mat: StandardMaterial3D = StandardMaterial3D.new()
		var color: Color = [Color(1.0, 0.20, 0.20), Color(0.20, 0.55, 1.0), Color(1.0, 0.95, 0.30), Color(0.45, 1.0, 0.45), Color(0.85, 0.40, 1.0)][i]
		dot_mat.albedo_color = color
		dot_mat.emission_enabled = true
		dot_mat.emission = color
		dot_mat.emission_energy_multiplier = 1.4
		dot_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		dot.material_override = dot_mat
		p.add_child(dot)
	var label: Label3D = Label3D.new()
	label.text = "Painter"
	label.position = Vector3(0, 2.40, 0)
	label.modulate = Color(1.0, 0.65, 0.95)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 18
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	p.add_child(label)


func _build_d4_easel_canvas(geom: Node) -> void:
	## Epic-4 T43: a wooden easel with a colorful painted canvas.
	var easel: Node3D = Node3D.new()
	easel.name = "D4Easel"
	easel.position = D4_CENTER + Vector3(-2, 0, 9)
	geom.add_child(easel)
	var wood_mat: StandardMaterial3D = StandardMaterial3D.new()
	wood_mat.albedo_color = Color(0.55, 0.40, 0.20)
	# 3-leg tripod stand
	for i in 3:
		var angle: float = (float(i) / 3.0) * TAU
		var leg: MeshInstance3D = MeshInstance3D.new()
		var lm: CylinderMesh = CylinderMesh.new()
		lm.top_radius = 0.04
		lm.bottom_radius = 0.06
		lm.height = 1.85
		leg.mesh = lm
		leg.position = Vector3(cos(angle) * 0.30, 0.92, sin(angle) * 0.30)
		leg.rotation = Vector3(sin(angle) * deg_to_rad(15), 0, -cos(angle) * deg_to_rad(15))
		leg.material_override = wood_mat
		easel.add_child(leg)
	# Canvas — flat box
	var canvas: MeshInstance3D = MeshInstance3D.new()
	var cm: BoxMesh = BoxMesh.new()
	cm.size = Vector3(0.85, 1.20, 0.04)
	canvas.mesh = cm
	canvas.position = Vector3(0, 1.70, 0.10)
	var cmat: StandardMaterial3D = StandardMaterial3D.new()
	cmat.albedo_color = Color(0.95, 0.85, 0.65)
	cmat.emission_enabled = true
	cmat.emission = Color(1.0, 0.85, 0.65)
	cmat.emission_energy_multiplier = 0.55
	canvas.material_override = cmat
	easel.add_child(canvas)
	# 4 colored paint blobs on canvas (abstract painting)
	var blob_specs: Array = [
		[Vector3(-0.20, 1.95, 0.13), Color(1.0, 0.55, 0.85)],
		[Vector3(0.20, 1.85, 0.13), Color(0.45, 1.0, 0.55)],
		[Vector3(0, 1.55, 0.13), Color(1.0, 0.95, 0.30)],
		[Vector3(0.10, 1.30, 0.13), Color(0.55, 0.85, 1.0)],
	]
	for spec in blob_specs:
		var blob: MeshInstance3D = MeshInstance3D.new()
		var bm: SphereMesh = SphereMesh.new()
		bm.radius = 0.10
		bm.height = 0.20
		blob.mesh = bm
		blob.position = spec[0]
		blob.scale = Vector3(1.0, 1.0, 0.3)
		var bmat: StandardMaterial3D = StandardMaterial3D.new()
		bmat.albedo_color = spec[1]
		bmat.emission_enabled = true
		bmat.emission = spec[1]
		bmat.emission_energy_multiplier = 1.4
		bmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		blob.material_override = bmat
		easel.add_child(blob)
	# Collision
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cap: CapsuleShape3D = CapsuleShape3D.new()
	cap.radius = 0.40
	cap.height = 1.85
	cs.shape = cap
	cs.position = Vector3(0, 0.92, 0)
	sb.add_child(cs)
	easel.add_child(sb)


func _build_d4_birdhouse(geom: Node) -> void:
	## Epic-4 T44: a small wooden birdhouse on a tall pole.
	var house: Node3D = Node3D.new()
	house.name = "D4Birdhouse"
	house.position = D4_CENTER + Vector3(5, 0, 14)
	geom.add_child(house)
	var wood_mat: StandardMaterial3D = StandardMaterial3D.new()
	wood_mat.albedo_color = Color(0.55, 0.40, 0.20)
	# Tall pole
	var pole: MeshInstance3D = MeshInstance3D.new()
	var pm: CylinderMesh = CylinderMesh.new()
	pm.top_radius = 0.07
	pm.bottom_radius = 0.10
	pm.height = 2.85
	pole.mesh = pm
	pole.position = Vector3(0, 1.42, 0)
	pole.material_override = wood_mat
	house.add_child(pole)
	# House body (small box)
	var body: MeshInstance3D = MeshInstance3D.new()
	var bm: BoxMesh = BoxMesh.new()
	bm.size = Vector3(0.40, 0.40, 0.40)
	body.mesh = bm
	body.position = Vector3(0, 3.05, 0)
	body.material_override = wood_mat
	house.add_child(body)
	# Pitched roof
	var roof: MeshInstance3D = MeshInstance3D.new()
	var rm: PrismMesh = PrismMesh.new()
	rm.size = Vector3(0.50, 0.20, 0.50)
	roof.mesh = rm
	roof.position = Vector3(0, 3.35, 0)
	var roof_mat: StandardMaterial3D = StandardMaterial3D.new()
	roof_mat.albedo_color = Color(0.30, 0.18, 0.10)
	roof.material_override = roof_mat
	house.add_child(roof)
	# Round entrance hole (dark sphere recess)
	var hole: MeshInstance3D = MeshInstance3D.new()
	var hm: SphereMesh = SphereMesh.new()
	hm.radius = 0.06
	hm.height = 0.12
	hole.mesh = hm
	hole.position = Vector3(0, 3.05, 0.21)
	var hmat: StandardMaterial3D = StandardMaterial3D.new()
	hmat.albedo_color = Color(0.05, 0.05, 0.10)
	hmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	hole.material_override = hmat
	house.add_child(hole)
	# Tiny perch stick
	var perch: MeshInstance3D = MeshInstance3D.new()
	var per: CylinderMesh = CylinderMesh.new()
	per.top_radius = 0.02
	per.bottom_radius = 0.02
	per.height = 0.18
	perch.mesh = per
	perch.position = Vector3(0, 2.95, 0.30)
	perch.rotation = Vector3(deg_to_rad(90), 0, 0)
	perch.material_override = wood_mat
	house.add_child(perch)
	# Collision around pole
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cap: CapsuleShape3D = CapsuleShape3D.new()
	cap.radius = 0.20
	cap.height = 2.85
	cs.shape = cap
	cs.position = Vector3(0, 1.42, 0)
	sb.add_child(cs)
	house.add_child(sb)


func _build_d4_clothesline(geom: Node) -> void:
	## Epic-4 T45: hanging clothesline between 2 wooden posts with 5 sheets.
	var line: Node3D = Node3D.new()
	line.name = "D4Clothesline"
	line.position = D4_CENTER + Vector3(0, 0, 14)
	geom.add_child(line)
	var wood_mat: StandardMaterial3D = StandardMaterial3D.new()
	wood_mat.albedo_color = Color(0.55, 0.40, 0.20)
	# 2 vertical posts
	for sx: float in [-2.0, 2.0]:
		var post: MeshInstance3D = MeshInstance3D.new()
		var pm: CylinderMesh = CylinderMesh.new()
		pm.top_radius = 0.07
		pm.bottom_radius = 0.10
		pm.height = 2.40
		post.mesh = pm
		post.position = Vector3(sx, 1.20, 0)
		post.material_override = wood_mat
		line.add_child(post)
		# Collision per post
		var sb: StaticBody3D = StaticBody3D.new()
		var cs: CollisionShape3D = CollisionShape3D.new()
		var cap: CapsuleShape3D = CapsuleShape3D.new()
		cap.radius = 0.20
		cap.height = 2.40
		cs.shape = cap
		cs.position = Vector3(sx, 1.20, 0)
		sb.add_child(cs)
		line.add_child(sb)
	# Rope line — thin cylinder
	var rope: MeshInstance3D = MeshInstance3D.new()
	var rm: CylinderMesh = CylinderMesh.new()
	rm.top_radius = 0.02
	rm.bottom_radius = 0.02
	rm.height = 4.0
	rope.mesh = rm
	rope.position = Vector3(0, 2.20, 0)
	rope.rotation = Vector3(0, 0, deg_to_rad(90))
	var rope_mat: StandardMaterial3D = StandardMaterial3D.new()
	rope_mat.albedo_color = Color(0.85, 0.85, 0.85)
	rope.material_override = rope_mat
	line.add_child(rope)
	# 5 sheets hanging in different colors
	var sheet_colors: Array[Color] = [
		Color(1.0, 0.55, 0.85),
		Color(0.55, 0.85, 1.0),
		Color(0.95, 0.95, 0.95),
		Color(1.0, 0.95, 0.30),
		Color(0.45, 1.0, 0.55),
	]
	for i in 5:
		var sheet: MeshInstance3D = MeshInstance3D.new()
		var sm: BoxMesh = BoxMesh.new()
		sm.size = Vector3(0.65, 0.85, 0.04)
		sheet.mesh = sm
		sheet.position = Vector3(-1.60 + i * 0.80, 1.55, 0)
		var smat: StandardMaterial3D = StandardMaterial3D.new()
		smat.albedo_color = sheet_colors[i]
		smat.emission_enabled = true
		smat.emission = sheet_colors[i]
		smat.emission_energy_multiplier = 0.55
		sheet.material_override = smat
		line.add_child(sheet)


func _build_d4_stone_bridge(geom: Node) -> void:
	## Epic-4 T46: stone arch bridge over the small stream — wide flat
	## deck on 2 stone arches with side rails.
	var bridge: Node3D = Node3D.new()
	bridge.name = "D4StoneBridge"
	bridge.position = D4_CENTER + Vector3(-12, 0, -3)
	geom.add_child(bridge)
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.55, 0.50, 0.45)
	stone_mat.metallic = 0.30
	stone_mat.roughness = 0.65
	# Wide deck box
	var deck: MeshInstance3D = MeshInstance3D.new()
	var dm: BoxMesh = BoxMesh.new()
	dm.size = Vector3(4.0, 0.30, 1.85)
	deck.mesh = dm
	deck.position = Vector3(0, 1.0, 0)
	deck.material_override = stone_mat
	bridge.add_child(deck)
	# 2 stone arch supports — half cylinders
	for sx: float in [-1.40, 1.40]:
		var arch: MeshInstance3D = MeshInstance3D.new()
		var am: CylinderMesh = CylinderMesh.new()
		am.top_radius = 0.85
		am.bottom_radius = 0.85
		am.height = 1.85
		arch.mesh = am
		arch.position = Vector3(sx, 0.50, 0)
		arch.rotation = Vector3(deg_to_rad(90), 0, 0)
		arch.material_override = stone_mat
		bridge.add_child(arch)
	# 2 side rails
	for sz: float in [-0.85, 0.85]:
		var rail: MeshInstance3D = MeshInstance3D.new()
		var rm: BoxMesh = BoxMesh.new()
		rm.size = Vector3(4.0, 0.55, 0.10)
		rail.mesh = rm
		rail.position = Vector3(0, 1.40, sz)
		rail.material_override = stone_mat
		bridge.add_child(rail)
	# 6 small post markers along each rail
	for sz: float in [-0.85, 0.85]:
		for i in 6:
			var post: MeshInstance3D = MeshInstance3D.new()
			var pm: BoxMesh = BoxMesh.new()
			pm.size = Vector3(0.18, 0.30, 0.18)
			post.mesh = pm
			post.position = Vector3(-1.85 + i * 0.74, 1.55, sz)
			post.material_override = stone_mat
			bridge.add_child(post)
	# Collision around deck
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(4.0, 0.30, 1.85)
	cs.shape = cb
	cs.position = Vector3(0, 1.0, 0)
	sb.add_child(cs)
	bridge.add_child(sb)


func _build_d4_small_stream(geom: Node) -> void:
	## Epic-4 T47: a small flowing stream running through D4 — long thin
	## emissive blue strip on the ground passing under the stone bridge.
	var stream: MeshInstance3D = MeshInstance3D.new()
	stream.name = "D4Stream"
	var sm: BoxMesh = BoxMesh.new()
	sm.size = Vector3(40.0, 0.10, 0.85)
	stream.mesh = sm
	stream.position = D4_CENTER + Vector3(-12, 0.06, -3)
	var smat: StandardMaterial3D = StandardMaterial3D.new()
	smat.albedo_color = Color(0.30, 0.65, 0.95, 0.85)
	smat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	smat.emission_enabled = true
	smat.emission = Color(0.55, 0.85, 1.0)
	smat.emission_energy_multiplier = 1.4
	smat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	stream.material_override = smat
	geom.add_child(stream)


func _build_d4_frog_creature(geom: Node) -> void:
	## Epic-4 T48: a friendly green frog sitting on a lily pad near the
	## stream. Has 2 large eyes and a hop tween.
	var frog: Node3D = Node3D.new()
	frog.name = "D4Frog"
	frog.position = D4_CENTER + Vector3(-15, 0.10, -3)
	geom.add_child(frog)
	# Lily pad under frog
	var pad: MeshInstance3D = MeshInstance3D.new()
	var pm: CylinderMesh = CylinderMesh.new()
	pm.top_radius = 0.40
	pm.bottom_radius = 0.40
	pm.height = 0.06
	pad.mesh = pm
	pad.position = Vector3(0, 0.0, 0)
	var pmat: StandardMaterial3D = StandardMaterial3D.new()
	pmat.albedo_color = Color(0.20, 0.55, 0.20)
	pmat.emission_enabled = true
	pmat.emission = Color(0.45, 1.0, 0.45)
	pmat.emission_energy_multiplier = 0.85
	pad.material_override = pmat
	frog.add_child(pad)
	# Frog body — flattened sphere
	var body: MeshInstance3D = MeshInstance3D.new()
	var bm: SphereMesh = SphereMesh.new()
	bm.radius = 0.20
	bm.height = 0.30
	body.mesh = bm
	body.position = Vector3(0, 0.20, 0)
	body.scale = Vector3(1.4, 0.85, 1.0)
	var bmat: StandardMaterial3D = StandardMaterial3D.new()
	bmat.albedo_color = Color(0.30, 0.85, 0.30)
	bmat.emission_enabled = true
	bmat.emission = Color(0.45, 1.0, 0.45)
	bmat.emission_energy_multiplier = 1.0
	body.material_override = bmat
	frog.add_child(body)
	# 2 large bulging eyes
	var eye_mat: StandardMaterial3D = StandardMaterial3D.new()
	eye_mat.albedo_color = Color(0.95, 0.95, 0.95)
	eye_mat.emission_enabled = true
	eye_mat.emission = Color(1.0, 1.0, 1.0)
	eye_mat.emission_energy_multiplier = 1.4
	eye_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for ex: float in [-0.10, 0.10]:
		var eye: MeshInstance3D = MeshInstance3D.new()
		var em: SphereMesh = SphereMesh.new()
		em.radius = 0.08
		em.height = 0.16
		eye.mesh = em
		eye.position = Vector3(ex, 0.40, 0.10)
		eye.material_override = eye_mat
		frog.add_child(eye)
		# Black pupil
		var pupil: MeshInstance3D = MeshInstance3D.new()
		var pum: SphereMesh = SphereMesh.new()
		pum.radius = 0.03
		pum.height = 0.06
		pupil.mesh = pum
		pupil.position = Vector3(ex, 0.42, 0.16)
		var pumat: StandardMaterial3D = StandardMaterial3D.new()
		pumat.albedo_color = Color(0.05, 0.05, 0.10)
		pumat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		pupil.material_override = pumat
		frog.add_child(pupil)
	# Hop tween
	var hop: Tween = create_tween().set_loops()
	hop.tween_property(body, "position:y", 0.45, 0.30).set_ease(Tween.EASE_OUT)
	hop.tween_property(body, "position:y", 0.20, 0.25).set_ease(Tween.EASE_IN)
	hop.tween_interval(1.5)


func _build_d4_musician_npc(town: Node) -> void:
	## Epic-4 T49: Musician NPC near the gazebo with a small wooden lute.
	var slots: Node3D = town.get_node_or_null("%NPCSlots") as Node3D
	if slots == null:
		return
	var mus: Node3D = Node3D.new()
	mus.name = "D4Musician"
	mus.position = D4_CENTER + Vector3(3, 0, -14)
	slots.add_child(mus)
	var bmat: StandardMaterial3D = StandardMaterial3D.new()
	bmat.albedo_color = Color(0.30, 0.20, 0.55)
	bmat.metallic = 0.20
	bmat.roughness = 0.55
	bmat.emission_enabled = true
	bmat.emission = Color(0.55, 0.30, 0.85)
	bmat.emission_energy_multiplier = 0.30
	var body: MeshInstance3D = MeshInstance3D.new()
	var bmesh: CapsuleMesh = CapsuleMesh.new()
	bmesh.radius = 0.42
	bmesh.height = 1.30
	body.mesh = bmesh
	body.position = Vector3(0, 0.70, 0)
	body.material_override = bmat
	mus.add_child(body)
	var head: MeshInstance3D = MeshInstance3D.new()
	var hm: SphereMesh = SphereMesh.new()
	hm.radius = 0.36
	hm.height = 0.65
	head.mesh = hm
	head.position = Vector3(0, 1.55, 0)
	var hmat: StandardMaterial3D = StandardMaterial3D.new()
	hmat.albedo_color = Color(0.85, 0.65, 0.45)
	head.material_override = hmat
	mus.add_child(head)
	# Wooden lute body — oval shape
	var lute: MeshInstance3D = MeshInstance3D.new()
	var lm: SphereMesh = SphereMesh.new()
	lm.radius = 0.30
	lm.height = 0.55
	lute.mesh = lm
	lute.position = Vector3(0.40, 0.85, 0.40)
	lute.scale = Vector3(0.85, 0.65, 1.20)
	var lutemat: StandardMaterial3D = StandardMaterial3D.new()
	lutemat.albedo_color = Color(0.55, 0.30, 0.10)
	lutemat.emission_enabled = true
	lutemat.emission = Color(0.85, 0.55, 0.20)
	lutemat.emission_energy_multiplier = 0.55
	lute.material_override = lutemat
	mus.add_child(lute)
	# Lute neck — long thin cylinder
	var neck: MeshInstance3D = MeshInstance3D.new()
	var nm: CylinderMesh = CylinderMesh.new()
	nm.top_radius = 0.04
	nm.bottom_radius = 0.05
	nm.height = 0.85
	neck.mesh = nm
	neck.position = Vector3(0.40, 1.30, 0.40)
	neck.rotation = Vector3(0, 0, deg_to_rad(20))
	neck.material_override = lutemat
	mus.add_child(neck)
	# Music notes floating around the head
	var note_mat: StandardMaterial3D = StandardMaterial3D.new()
	note_mat.albedo_color = Color(1.0, 0.95, 0.30)
	note_mat.emission_enabled = true
	note_mat.emission = Color(1.0, 0.95, 0.30)
	note_mat.emission_energy_multiplier = 2.4
	note_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for i in 3:
		var note: Label3D = Label3D.new()
		note.text = "♪"
		note.position = Vector3(-0.55 + i * 0.55, 2.10 + sin(i * 0.85) * 0.30, 0)
		note.modulate = Color(1.0, 0.95, 0.30)
		note.outline_modulate = Color(0, 0, 0, 0.85)
		note.outline_size = 4
		note.font_size = 22
		note.no_depth_test = true
		note.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		mus.add_child(note)
	var label: Label3D = Label3D.new()
	label.text = "Musician"
	label.position = Vector3(0, 2.55, 0)
	label.modulate = Color(0.85, 0.55, 1.0)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 18
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	mus.add_child(label)


func _build_d4_bloom_guardian(geom: Node) -> void:
	## Epic-4 T50: BLOOM GUARDIAN — friendly mini-boss with a giant
	## flower-bud body, 4 leaf wings, and a slow patrol around the central
	## bloom. Pure decorative — peaceful guardian, not hostile.
	var guard: Node3D = Node3D.new()
	guard.name = "D4BloomGuardian"
	guard.position = D4_CENTER + Vector3(8, 0, -8)
	geom.add_child(guard)
	# Big flower bud body — large pink sphere
	var body: MeshInstance3D = MeshInstance3D.new()
	var bm: SphereMesh = SphereMesh.new()
	bm.radius = 0.85
	bm.height = 1.70
	body.mesh = bm
	body.position = Vector3(0, 1.20, 0)
	var bmat: StandardMaterial3D = StandardMaterial3D.new()
	bmat.albedo_color = Color(1.0, 0.55, 0.85)
	bmat.emission_enabled = true
	bmat.emission = Color(1.0, 0.65, 0.85)
	bmat.emission_energy_multiplier = 1.6
	bmat.metallic = 0.20
	bmat.roughness = 0.30
	body.material_override = bmat
	guard.add_child(body)
	# Yellow center pollen disc on the body's front
	var center: MeshInstance3D = MeshInstance3D.new()
	var cm: SphereMesh = SphereMesh.new()
	cm.radius = 0.40
	cm.height = 0.80
	center.mesh = cm
	center.position = Vector3(0, 1.20, 0.55)
	center.scale = Vector3(1.0, 1.0, 0.4)
	var cmat: StandardMaterial3D = StandardMaterial3D.new()
	cmat.albedo_color = Color(1.0, 0.95, 0.30)
	cmat.emission_enabled = true
	cmat.emission = Color(1.0, 0.95, 0.30)
	cmat.emission_energy_multiplier = 2.4
	cmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	center.material_override = cmat
	guard.add_child(center)
	# 2 white friendly eyes
	var eye_mat: StandardMaterial3D = StandardMaterial3D.new()
	eye_mat.albedo_color = Color(0.05, 0.05, 0.10)
	eye_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for ex: float in [-0.18, 0.18]:
		var eye: MeshInstance3D = MeshInstance3D.new()
		var em: SphereMesh = SphereMesh.new()
		em.radius = 0.08
		em.height = 0.16
		eye.mesh = em
		eye.position = Vector3(ex, 1.40, 0.85)
		eye.material_override = eye_mat
		guard.add_child(eye)
	# 4 leaf wings around the body
	var wing_mat: StandardMaterial3D = StandardMaterial3D.new()
	wing_mat.albedo_color = Color(0.20, 0.55, 0.20)
	wing_mat.emission_enabled = true
	wing_mat.emission = Color(0.45, 1.0, 0.45)
	wing_mat.emission_energy_multiplier = 1.2
	wing_mat.metallic = 0.20
	wing_mat.roughness = 0.55
	for i in 4:
		var angle: float = (float(i) / 4.0) * TAU
		var wing: MeshInstance3D = MeshInstance3D.new()
		var wm: PrismMesh = PrismMesh.new()
		wm.size = Vector3(0.30, 0.85, 0.10)
		wing.mesh = wm
		wing.position = Vector3(cos(angle) * 1.10, 1.20, sin(angle) * 1.10)
		wing.rotation = Vector3(0, -angle, deg_to_rad(20))
		wing.material_override = wing_mat
		guard.add_child(wing)
	# Slow patrol path
	var origin: Vector3 = D4_CENTER + Vector3(8, 0, -8)
	var patrol: Tween = create_tween().set_loops()
	patrol.tween_property(guard, "position", origin + Vector3(-8, 0, 0), 8.0).set_ease(Tween.EASE_IN_OUT)
	patrol.tween_property(guard, "position", origin + Vector3(0, 0, 8), 8.0).set_ease(Tween.EASE_IN_OUT)
	patrol.tween_property(guard, "position", origin, 8.0).set_ease(Tween.EASE_IN_OUT)
	# Pulse the body
	var pulse: Tween = create_tween().set_loops()
	pulse.tween_property(body, "scale", Vector3(1.10, 1.10, 1.10), 1.4).set_ease(Tween.EASE_IN_OUT)
	pulse.tween_property(body, "scale", Vector3(1.0, 1.0, 1.0), 1.4).set_ease(Tween.EASE_IN_OUT)
	# Friendly name billboard
	var label: Label3D = Label3D.new()
	label.text = "BLOOM GUARDIAN"
	label.position = Vector3(0, 2.85, 0)
	label.modulate = Color(1.0, 0.65, 0.85)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 6
	label.font_size = 22
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	guard.add_child(label)


func _build_d4_stable(geom: Node) -> void:
	## Epic-4 T51: wooden stable building with open front and stall doors.
	var stable: Node3D = Node3D.new()
	stable.name = "D4Stable"
	stable.position = D4_CENTER + Vector3(20, 0, 8)
	geom.add_child(stable)
	var wood_mat: StandardMaterial3D = StandardMaterial3D.new()
	wood_mat.albedo_color = Color(0.55, 0.40, 0.20)
	wood_mat.metallic = 0.10
	wood_mat.roughness = 0.65
	wood_mat.emission_enabled = true
	wood_mat.emission = Color(0.85, 0.55, 0.30)
	wood_mat.emission_energy_multiplier = 0.30
	# Building body — wide box
	var body: MeshInstance3D = MeshInstance3D.new()
	var bm: BoxMesh = BoxMesh.new()
	bm.size = Vector3(4.0, 2.85, 2.40)
	body.mesh = bm
	body.position = Vector3(0, 1.42, 0)
	body.material_override = wood_mat
	stable.add_child(body)
	# Pitched prism roof
	var roof: MeshInstance3D = MeshInstance3D.new()
	var rm: PrismMesh = PrismMesh.new()
	rm.size = Vector3(4.0, 1.20, 2.40)
	roof.mesh = rm
	roof.position = Vector3(0, 3.40, 0)
	var roof_mat: StandardMaterial3D = StandardMaterial3D.new()
	roof_mat.albedo_color = Color(0.30, 0.18, 0.10)
	roof.material_override = roof_mat
	stable.add_child(roof)
	# 2 stall doors on front (dark recessed boxes)
	var door_mat: StandardMaterial3D = StandardMaterial3D.new()
	door_mat.albedo_color = Color(0.18, 0.10, 0.06)
	door_mat.metallic = 0.30
	for sx: float in [-0.95, 0.95]:
		var door: MeshInstance3D = MeshInstance3D.new()
		var dm: BoxMesh = BoxMesh.new()
		dm.size = Vector3(1.40, 1.85, 0.10)
		door.mesh = dm
		door.position = Vector3(sx, 0.95, 1.21)
		door.material_override = door_mat
		stable.add_child(door)
	# "STABLE" sign above
	var label: Label3D = Label3D.new()
	label.text = "STABLE"
	label.position = Vector3(0, 4.40, 0)
	label.modulate = Color(0.85, 0.55, 0.20)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 18
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	stable.add_child(label)
	# Collision around the building
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(4.0, 2.85, 2.40)
	cs.shape = cb
	cs.position = Vector3(0, 1.42, 0)
	sb.add_child(cs)
	stable.add_child(sb)


func _build_d4_horse(geom: Node) -> void:
	## Epic-4 T52: a friendly horse standing outside the stable. Body
	## capsule + 4 legs + head + mane + tail.
	var horse: Node3D = Node3D.new()
	horse.name = "D4Horse"
	horse.position = D4_CENTER + Vector3(16, 0, 8)
	geom.add_child(horse)
	# Brown body
	var body_mat: StandardMaterial3D = StandardMaterial3D.new()
	body_mat.albedo_color = Color(0.55, 0.30, 0.10)
	body_mat.metallic = 0.10
	body_mat.roughness = 0.55
	body_mat.emission_enabled = true
	body_mat.emission = Color(0.85, 0.55, 0.30)
	body_mat.emission_energy_multiplier = 0.30
	var body: MeshInstance3D = MeshInstance3D.new()
	var bm: BoxMesh = BoxMesh.new()
	bm.size = Vector3(0.85, 0.85, 1.85)
	body.mesh = bm
	body.position = Vector3(0, 1.20, 0)
	body.material_override = body_mat
	horse.add_child(body)
	# 4 legs
	for ox: float in [-0.30, 0.30]:
		for oz: float in [-0.65, 0.65]:
			var leg: MeshInstance3D = MeshInstance3D.new()
			var lm: BoxMesh = BoxMesh.new()
			lm.size = Vector3(0.18, 1.20, 0.18)
			leg.mesh = lm
			leg.position = Vector3(ox, 0.60, oz)
			leg.material_override = body_mat
			horse.add_child(leg)
	# Head — angled box at front
	var head: MeshInstance3D = MeshInstance3D.new()
	var hm: BoxMesh = BoxMesh.new()
	hm.size = Vector3(0.55, 0.65, 0.85)
	head.mesh = hm
	head.position = Vector3(0, 1.85, 1.20)
	head.rotation = Vector3(deg_to_rad(20), 0, 0)
	head.material_override = body_mat
	horse.add_child(head)
	# Black mane — small dark box on top of neck
	var mane: MeshInstance3D = MeshInstance3D.new()
	var mm: BoxMesh = BoxMesh.new()
	mm.size = Vector3(0.20, 0.30, 0.85)
	mane.mesh = mm
	mane.position = Vector3(0, 1.85, 0.55)
	var mmat: StandardMaterial3D = StandardMaterial3D.new()
	mmat.albedo_color = Color(0.10, 0.06, 0.04)
	mane.material_override = mmat
	horse.add_child(mane)
	# Tail — small dark box at the back
	var tail: MeshInstance3D = MeshInstance3D.new()
	var tm: BoxMesh = BoxMesh.new()
	tm.size = Vector3(0.10, 0.55, 0.10)
	tail.mesh = tm
	tail.position = Vector3(0, 1.10, -1.0)
	tail.rotation = Vector3(deg_to_rad(-30), 0, 0)
	tail.material_override = mmat
	horse.add_child(tail)
	# 2 small black eyes on the head
	var eye_mat: StandardMaterial3D = StandardMaterial3D.new()
	eye_mat.albedo_color = Color(0.05, 0.05, 0.10)
	eye_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for ex: float in [-0.15, 0.15]:
		var eye: MeshInstance3D = MeshInstance3D.new()
		var em: SphereMesh = SphereMesh.new()
		em.radius = 0.05
		em.height = 0.10
		eye.mesh = em
		eye.position = Vector3(ex, 1.95, 1.55)
		eye.material_override = eye_mat
		horse.add_child(eye)
	# Slow swaying head animation
	var sway: Tween = create_tween().set_loops()
	sway.tween_property(head, "rotation:x", deg_to_rad(15), 1.4).set_ease(Tween.EASE_IN_OUT)
	sway.tween_property(head, "rotation:x", deg_to_rad(25), 1.4).set_ease(Tween.EASE_IN_OUT)
	# Friendly name
	var label: Label3D = Label3D.new()
	label.text = "Horse"
	label.position = Vector3(0, 2.85, 0)
	label.modulate = Color(0.85, 0.65, 0.30)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 16
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	horse.add_child(label)


func _build_d4_stableboy_npc(town: Node) -> void:
	## Epic-4 T53: Stableboy NPC near the stable holding a feed bucket.
	var slots: Node3D = town.get_node_or_null("%NPCSlots") as Node3D
	if slots == null:
		return
	var sb: Node3D = Node3D.new()
	sb.name = "D4Stableboy"
	sb.position = D4_CENTER + Vector3(18, 0, 6)
	slots.add_child(sb)
	var bmat: StandardMaterial3D = StandardMaterial3D.new()
	bmat.albedo_color = Color(0.55, 0.40, 0.20)
	bmat.metallic = 0.10
	bmat.roughness = 0.55
	bmat.emission_enabled = true
	bmat.emission = Color(0.85, 0.55, 0.30)
	bmat.emission_energy_multiplier = 0.30
	var body: MeshInstance3D = MeshInstance3D.new()
	var bmesh: CapsuleMesh = CapsuleMesh.new()
	bmesh.radius = 0.40
	bmesh.height = 1.20
	body.mesh = bmesh
	body.position = Vector3(0, 0.65, 0)
	body.material_override = bmat
	sb.add_child(body)
	var head: MeshInstance3D = MeshInstance3D.new()
	var hm: SphereMesh = SphereMesh.new()
	hm.radius = 0.32
	hm.height = 0.55
	head.mesh = hm
	head.position = Vector3(0, 1.45, 0)
	var hmat: StandardMaterial3D = StandardMaterial3D.new()
	hmat.albedo_color = Color(0.85, 0.65, 0.45)
	head.material_override = hmat
	sb.add_child(head)
	# Small straw hat
	var hat: MeshInstance3D = MeshInstance3D.new()
	var hatm: CylinderMesh = CylinderMesh.new()
	hatm.top_radius = 0.45
	hatm.bottom_radius = 0.45
	hatm.height = 0.10
	hat.mesh = hatm
	hat.position = Vector3(0, 1.75, 0)
	var hatmat: StandardMaterial3D = StandardMaterial3D.new()
	hatmat.albedo_color = Color(0.85, 0.65, 0.30)
	hat.material_override = hatmat
	sb.add_child(hat)
	# Feed bucket held in hand
	var bucket: MeshInstance3D = MeshInstance3D.new()
	var bkm: CylinderMesh = CylinderMesh.new()
	bkm.top_radius = 0.20
	bkm.bottom_radius = 0.18
	bkm.height = 0.30
	bucket.mesh = bkm
	bucket.position = Vector3(0.45, 0.85, 0.30)
	var bk_mat: StandardMaterial3D = StandardMaterial3D.new()
	bk_mat.albedo_color = Color(0.30, 0.18, 0.10)
	bucket.material_override = bk_mat
	sb.add_child(bucket)
	# Eyes
	var eye_mat: StandardMaterial3D = StandardMaterial3D.new()
	eye_mat.albedo_color = Color(0.30, 0.18, 0.10)
	eye_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for ex: float in [-0.10, 0.10]:
		var eye: MeshInstance3D = MeshInstance3D.new()
		var em: SphereMesh = SphereMesh.new()
		em.radius = 0.05
		em.height = 0.10
		eye.mesh = em
		eye.position = Vector3(ex, 1.40, 0.30)
		eye.material_override = eye_mat
		sb.add_child(eye)
	var label: Label3D = Label3D.new()
	label.text = "Stableboy"
	label.position = Vector3(0, 2.20, 0)
	label.modulate = Color(0.85, 0.55, 0.30)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 18
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	sb.add_child(label)


func _build_d4_hay_loft(geom: Node) -> void:
	## Epic-4 T54: a hay loft jutting out of the stable's upper level —
	## small platform with a stack of hay sacks.
	var loft: Node3D = Node3D.new()
	loft.name = "D4HayLoft"
	loft.position = D4_CENTER + Vector3(20, 0, 8)
	geom.add_child(loft)
	# Wooden platform deck — small flat box jutting out the front of the stable
	var wood_mat: StandardMaterial3D = StandardMaterial3D.new()
	wood_mat.albedo_color = Color(0.55, 0.40, 0.20)
	var deck: MeshInstance3D = MeshInstance3D.new()
	var dm: BoxMesh = BoxMesh.new()
	dm.size = Vector3(2.40, 0.18, 0.85)
	deck.mesh = dm
	deck.position = Vector3(0, 2.85, 1.55)
	deck.material_override = wood_mat
	loft.add_child(deck)
	# 2 support rope angles to the deck
	var rope_mat: StandardMaterial3D = StandardMaterial3D.new()
	rope_mat.albedo_color = Color(0.85, 0.85, 0.85)
	for sx: float in [-0.85, 0.85]:
		var rope: MeshInstance3D = MeshInstance3D.new()
		var rm: CylinderMesh = CylinderMesh.new()
		rm.top_radius = 0.03
		rm.bottom_radius = 0.03
		rm.height = 1.40
		rope.mesh = rm
		rope.position = Vector3(sx, 3.40, 1.10)
		rope.rotation = Vector3(deg_to_rad(45), 0, 0)
		rope.material_override = rope_mat
		loft.add_child(rope)
	# 3 hay sacks stacked on the deck
	var hay_mat: StandardMaterial3D = StandardMaterial3D.new()
	hay_mat.albedo_color = Color(0.95, 0.85, 0.30)
	hay_mat.emission_enabled = true
	hay_mat.emission = Color(1.0, 0.95, 0.30)
	hay_mat.emission_energy_multiplier = 0.85
	for i in 3:
		var sack: MeshInstance3D = MeshInstance3D.new()
		var sm: BoxMesh = BoxMesh.new()
		sm.size = Vector3(0.55, 0.40, 0.40)
		sack.mesh = sm
		sack.position = Vector3(-0.55 + i * 0.55, 3.20, 1.55)
		sack.material_override = hay_mat
		loft.add_child(sack)


func _build_d4_hay_bales(geom: Node) -> void:
	## Epic-4 T55: 5 stacked round hay bales near the stable.
	var bales: Node3D = Node3D.new()
	bales.name = "D4HayBales"
	bales.position = D4_CENTER + Vector3(15, 0, 14)
	geom.add_child(bales)
	var hay_mat: StandardMaterial3D = StandardMaterial3D.new()
	hay_mat.albedo_color = Color(0.95, 0.85, 0.30)
	hay_mat.emission_enabled = true
	hay_mat.emission = Color(1.0, 0.95, 0.30)
	hay_mat.emission_energy_multiplier = 0.85
	hay_mat.metallic = 0.10
	hay_mat.roughness = 0.65
	# 3 bales on the ground row + 2 stacked on top
	var bale_specs: Array = [
		[Vector3(-0.85, 0.45, 0), 0.0],
		[Vector3(0, 0.45, 0), 0.0],
		[Vector3(0.85, 0.45, 0), 0.0],
		[Vector3(-0.40, 1.20, 0), 0.0],
		[Vector3(0.40, 1.20, 0), 0.0],
	]
	for spec in bale_specs:
		var bale: MeshInstance3D = MeshInstance3D.new()
		var bm: CylinderMesh = CylinderMesh.new()
		bm.top_radius = 0.40
		bm.bottom_radius = 0.40
		bm.height = 0.65
		bale.mesh = bm
		bale.position = spec[0]
		bale.rotation = Vector3(0, 0, deg_to_rad(90))
		bale.material_override = hay_mat
		bales.add_child(bale)
	# Collision around the heap
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(2.40, 1.85, 0.85)
	cs.shape = cb
	cs.position = Vector3(0, 0.92, 0)
	sb.add_child(cs)
	bales.add_child(sb)


func _build_d4_pumpkin_patch(geom: Node) -> void:
	## Epic-4 T56: pumpkin patch — squat orange pumpkins of varying sizes on
	## a small dirt plot at the south of D4.
	var patch: Node3D = Node3D.new()
	patch.name = "PumpkinPatch"
	patch.position = Vector3(D4_CENTER.x - 6.0, 0.0, 14.0)
	geom.add_child(patch)
	# Dirt plot
	var dirt: MeshInstance3D = MeshInstance3D.new()
	var dm: BoxMesh = BoxMesh.new()
	dm.size = Vector3(6.0, 0.10, 4.0)
	dirt.mesh = dm
	var dmat: StandardMaterial3D = StandardMaterial3D.new()
	dmat.albedo_color = Color(0.30, 0.18, 0.10)
	dmat.roughness = 0.95
	dirt.material_override = dmat
	dirt.position = Vector3(0, 0.05, 0)
	patch.add_child(dirt)
	# Pumpkin material
	var pmat: StandardMaterial3D = StandardMaterial3D.new()
	pmat.albedo_color = Color(0.95, 0.45, 0.10)
	pmat.emission_enabled = true
	pmat.emission = Color(0.85, 0.30, 0.05)
	pmat.emission_energy_multiplier = 0.20
	pmat.roughness = 0.55
	# Stem material
	var stem_mat: StandardMaterial3D = StandardMaterial3D.new()
	stem_mat.albedo_color = Color(0.30, 0.50, 0.15)
	stem_mat.roughness = 0.80
	# Place 9 pumpkins in a grid
	var positions: Array = [
		Vector3(-2.2, 0, -1.4), Vector3(-0.4, 0, -1.4), Vector3(1.6, 0, -1.4),
		Vector3(-2.2, 0,  0.0), Vector3( 0.4, 0,  0.0), Vector3(2.0, 0, -0.2),
		Vector3(-1.8, 0,  1.4), Vector3( 0.0, 0,  1.4), Vector3(1.8, 0,  1.4),
	]
	var sizes: Array = [0.55, 0.70, 0.45, 0.80, 0.50, 0.65, 0.60, 0.75, 0.55]
	for i in positions.size():
		var p: Vector3 = positions[i]
		var s: float = sizes[i]
		var pumpkin: MeshInstance3D = MeshInstance3D.new()
		var sm: SphereMesh = SphereMesh.new()
		sm.radius = s
		sm.height = s * 1.4
		pumpkin.mesh = sm
		pumpkin.material_override = pmat
		pumpkin.position = Vector3(p.x, s * 0.7, p.z)
		pumpkin.scale = Vector3(1.0, 0.7, 1.0)
		patch.add_child(pumpkin)
		# Stem
		var stem: MeshInstance3D = MeshInstance3D.new()
		var stm: CylinderMesh = CylinderMesh.new()
		stm.top_radius = 0.06
		stm.bottom_radius = 0.10
		stm.height = 0.25
		stem.mesh = stm
		stem.material_override = stem_mat
		stem.position = Vector3(p.x, s * 1.05, p.z)
		patch.add_child(stem)


func _build_d4_chicken_coop(geom: Node) -> void:
	## Epic-4 T57: chicken coop — small wooden hut with sloped roof, opening,
	## and a small wire fence run.
	var coop: Node3D = Node3D.new()
	coop.name = "ChickenCoop"
	coop.position = Vector3(D4_CENTER.x + 7.0, 0.0, 13.0)
	geom.add_child(coop)
	# Wooden walls
	var wood_mat: StandardMaterial3D = StandardMaterial3D.new()
	wood_mat.albedo_color = Color(0.55, 0.35, 0.18)
	wood_mat.roughness = 0.85
	var hut: MeshInstance3D = MeshInstance3D.new()
	var hm: BoxMesh = BoxMesh.new()
	hm.size = Vector3(2.4, 1.6, 2.0)
	hut.mesh = hm
	hut.material_override = wood_mat
	hut.position = Vector3(0, 0.8, 0)
	coop.add_child(hut)
	# Sloped roof (prism)
	var roof: MeshInstance3D = MeshInstance3D.new()
	var rm: PrismMesh = PrismMesh.new()
	rm.size = Vector3(2.6, 0.7, 2.2)
	roof.mesh = rm
	var roof_mat: StandardMaterial3D = StandardMaterial3D.new()
	roof_mat.albedo_color = Color(0.40, 0.22, 0.10)
	roof_mat.roughness = 0.85
	roof.material_override = roof_mat
	roof.position = Vector3(0, 1.95, 0)
	coop.add_child(roof)
	# Door opening (dark hole)
	var door: MeshInstance3D = MeshInstance3D.new()
	var dm: BoxMesh = BoxMesh.new()
	dm.size = Vector3(0.5, 0.7, 0.05)
	door.mesh = dm
	var dmat: StandardMaterial3D = StandardMaterial3D.new()
	dmat.albedo_color = Color(0.10, 0.07, 0.04)
	dmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	door.material_override = dmat
	door.position = Vector3(0, 0.45, 1.02)
	coop.add_child(door)
	# Run fence (4 short posts and rails)
	var fence_mat: StandardMaterial3D = StandardMaterial3D.new()
	fence_mat.albedo_color = Color(0.45, 0.30, 0.15)
	fence_mat.roughness = 0.90
	var fence_corners: Array = [
		Vector2(-1.5,  1.4), Vector2( 1.5,  1.4),
		Vector2( 1.5,  3.4), Vector2(-1.5,  3.4),
	]
	for c in fence_corners:
		var post: MeshInstance3D = MeshInstance3D.new()
		var pm: CylinderMesh = CylinderMesh.new()
		pm.top_radius = 0.06
		pm.bottom_radius = 0.06
		pm.height = 0.9
		post.mesh = pm
		post.material_override = fence_mat
		post.position = Vector3(c.x, 0.45, c.y)
		coop.add_child(post)
	# Static collision body
	var sb: StaticBody3D = StaticBody3D.new()
	sb.position = Vector3(0, 0.8, 0)
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(2.4, 1.6, 2.0)
	cs.shape = cb
	sb.add_child(cs)
	coop.add_child(sb)


func _build_d4_chickens(geom: Node) -> void:
	## Epic-4 T58: rooster + 3 hens pecking and bobbing around the coop.
	var flock: Node3D = Node3D.new()
	flock.name = "Chickens"
	flock.position = Vector3(D4_CENTER.x + 7.0, 0.0, 11.0)
	geom.add_child(flock)
	var birds: Array = [
		{"pos": Vector3( 0.0, 0,  0.0), "color": Color(0.95, 0.92, 0.85), "is_rooster": true},
		{"pos": Vector3(-1.4, 0,  0.6), "color": Color(0.95, 0.85, 0.60), "is_rooster": false},
		{"pos": Vector3( 1.2, 0, -0.4), "color": Color(0.85, 0.55, 0.30), "is_rooster": false},
		{"pos": Vector3( 0.4, 0,  1.4), "color": Color(0.95, 0.95, 0.92), "is_rooster": false},
	]
	for b in birds:
		var bird: Node3D = Node3D.new()
		bird.position = b["pos"]
		flock.add_child(bird)
		# Body
		var body_mat: StandardMaterial3D = StandardMaterial3D.new()
		body_mat.albedo_color = b["color"]
		body_mat.roughness = 0.75
		var body: MeshInstance3D = MeshInstance3D.new()
		var bm: SphereMesh = SphereMesh.new()
		bm.radius = 0.20
		bm.height = 0.30
		body.mesh = bm
		body.material_override = body_mat
		body.position = Vector3(0, 0.20, 0)
		body.scale = Vector3(1.0, 0.85, 1.2)
		bird.add_child(body)
		# Head
		var head: MeshInstance3D = MeshInstance3D.new()
		var hm: SphereMesh = SphereMesh.new()
		hm.radius = 0.10
		hm.height = 0.18
		head.mesh = hm
		head.material_override = body_mat
		head.position = Vector3(0, 0.42, 0.18)
		bird.add_child(head)
		# Beak
		var beak: MeshInstance3D = MeshInstance3D.new()
		var bkm: PrismMesh = PrismMesh.new()
		bkm.size = Vector3(0.06, 0.05, 0.10)
		beak.mesh = bkm
		var beak_mat: StandardMaterial3D = StandardMaterial3D.new()
		beak_mat.albedo_color = Color(0.95, 0.65, 0.10)
		beak.material_override = beak_mat
		beak.position = Vector3(0, 0.40, 0.30)
		beak.rotation_degrees = Vector3(90, 0, 0)
		bird.add_child(beak)
		# Comb (red, larger on rooster)
		var comb: MeshInstance3D = MeshInstance3D.new()
		var cm: BoxMesh = BoxMesh.new()
		var sf: float = 1.5 if b["is_rooster"] else 1.0
		cm.size = Vector3(0.05, 0.08 * sf, 0.14 * sf)
		comb.mesh = cm
		var cmat: StandardMaterial3D = StandardMaterial3D.new()
		cmat.albedo_color = Color(0.95, 0.20, 0.20)
		cmat.emission_enabled = true
		cmat.emission = Color(0.75, 0.10, 0.10)
		cmat.emission_energy_multiplier = 0.30
		comb.material_override = cmat
		comb.position = Vector3(0, 0.52, 0.16)
		bird.add_child(comb)
		# Tail (rooster gets larger plume)
		var tail: MeshInstance3D = MeshInstance3D.new()
		var tm: SphereMesh = SphereMesh.new()
		tm.radius = 0.12 if b["is_rooster"] else 0.08
		tm.height = 0.20 if b["is_rooster"] else 0.14
		tail.mesh = tm
		var tail_mat: StandardMaterial3D = StandardMaterial3D.new()
		var base_col: Color = b["color"]
		if b["is_rooster"]:
			tail_mat.albedo_color = base_col.darkened(0.3)
		else:
			tail_mat.albedo_color = base_col
		tail.material_override = tail_mat
		tail.position = Vector3(0, 0.30, -0.24)
		bird.add_child(tail)
		# Bobbing tween
		var tw: Tween = bird.create_tween().set_loops()
		tw.tween_property(bird, "position:y", 0.04, 0.30 + randf() * 0.20)
		tw.tween_property(bird, "position:y", 0.0, 0.30 + randf() * 0.20)


func _build_d4_harvest_crates(geom: Node) -> void:
	## Epic-4 T59: stacked wooden crates filled with vegetables (carrots,
	## potatoes, onions). Sit by the chicken coop.
	var crates: Node3D = Node3D.new()
	crates.name = "HarvestCrates"
	crates.position = Vector3(D4_CENTER.x + 5.0, 0.0, 15.5)
	geom.add_child(crates)
	var wood_mat: StandardMaterial3D = StandardMaterial3D.new()
	wood_mat.albedo_color = Color(0.55, 0.35, 0.18)
	wood_mat.roughness = 0.85
	# 3 crates: two on bottom, one on top
	var positions: Array = [
		Vector3(-0.55, 0.40, 0.0),
		Vector3( 0.55, 0.40, 0.0),
		Vector3( 0.0,  1.20, 0.0),
	]
	var contents: Array = [
		{"col": Color(0.95, 0.50, 0.10), "shape": "carrot"},
		{"col": Color(0.85, 0.65, 0.40), "shape": "potato"},
		{"col": Color(0.85, 0.85, 0.65), "shape": "onion"},
	]
	for i in positions.size():
		var crate: MeshInstance3D = MeshInstance3D.new()
		var cm: BoxMesh = BoxMesh.new()
		cm.size = Vector3(1.0, 0.80, 1.0)
		crate.mesh = cm
		crate.material_override = wood_mat
		crate.position = positions[i]
		crates.add_child(crate)
		# Veggies inside
		var contents_mat: StandardMaterial3D = StandardMaterial3D.new()
		contents_mat.albedo_color = contents[i]["col"]
		contents_mat.roughness = 0.80
		for j in 5:
			var veg: MeshInstance3D = MeshInstance3D.new()
			var vm: SphereMesh = SphereMesh.new()
			vm.radius = 0.12
			vm.height = 0.20
			veg.mesh = vm
			veg.material_override = contents_mat
			var ox: float = randf_range(-0.30, 0.30)
			var oz: float = randf_range(-0.30, 0.30)
			veg.position = positions[i] + Vector3(ox, 0.50, oz)
			crates.add_child(veg)
	# Collision
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(1.20, 1.65, 1.00)
	cs.shape = cb
	cs.position = Vector3(0, 0.80, 0)
	sb.add_child(cs)
	crates.add_child(sb)


func _build_d4_berry_bushes(geom: Node) -> void:
	## Epic-4 T60: row of 6 berry bushes lining a path. Each bush has dark
	## green foliage with bright red berries (small spheres).
	var row: Node3D = Node3D.new()
	row.name = "BerryBushes"
	row.position = Vector3(D4_CENTER.x - 14.0, 0.0, 4.0)
	geom.add_child(row)
	var leaf_mat: StandardMaterial3D = StandardMaterial3D.new()
	leaf_mat.albedo_color = Color(0.18, 0.45, 0.20)
	leaf_mat.roughness = 0.85
	var berry_mat: StandardMaterial3D = StandardMaterial3D.new()
	berry_mat.albedo_color = Color(0.85, 0.10, 0.15)
	berry_mat.emission_enabled = true
	berry_mat.emission = Color(0.75, 0.10, 0.15)
	berry_mat.emission_energy_multiplier = 0.30
	berry_mat.roughness = 0.40
	for i in 6:
		var bush: Node3D = Node3D.new()
		bush.position = Vector3(i * 1.6, 0, 0)
		row.add_child(bush)
		# Foliage (3 overlapping spheres)
		for j in 3:
			var leaf: MeshInstance3D = MeshInstance3D.new()
			var lm: SphereMesh = SphereMesh.new()
			lm.radius = 0.45
			lm.height = 0.85
			leaf.mesh = lm
			leaf.material_override = leaf_mat
			leaf.position = Vector3(
				randf_range(-0.20, 0.20),
				0.45 + randf_range(-0.10, 0.10),
				randf_range(-0.20, 0.20)
			)
			bush.add_child(leaf)
		# Berries (8 small red spheres scattered on the bush)
		for j in 8:
			var berry: MeshInstance3D = MeshInstance3D.new()
			var bm: SphereMesh = SphereMesh.new()
			bm.radius = 0.06
			bm.height = 0.12
			berry.mesh = bm
			berry.material_override = berry_mat
			berry.position = Vector3(
				randf_range(-0.40, 0.40),
				randf_range(0.30, 0.85),
				randf_range(-0.40, 0.40)
			)
			bush.add_child(berry)
		# Static collision (one body per bush)
		var sb: StaticBody3D = StaticBody3D.new()
		sb.position = Vector3(0, 0.45, 0)
		var cs: CollisionShape3D = CollisionShape3D.new()
		var cb: BoxShape3D = BoxShape3D.new()
		cb.size = Vector3(0.85, 0.85, 0.85)
		cs.shape = cb
		sb.add_child(cs)
		bush.add_child(sb)


func _build_d4_veg_garden_rows(geom: Node) -> void:
	## Epic-4 T61: 4 long raised garden rows with green sprouts.
	var rows: Node3D = Node3D.new()
	rows.name = "VegGardenRows"
	rows.position = Vector3(D4_CENTER.x + 12.0, 0.0, -10.0)
	geom.add_child(rows)
	var dirt_mat: StandardMaterial3D = StandardMaterial3D.new()
	dirt_mat.albedo_color = Color(0.32, 0.20, 0.10)
	dirt_mat.roughness = 0.95
	var sprout_mat: StandardMaterial3D = StandardMaterial3D.new()
	sprout_mat.albedo_color = Color(0.30, 0.65, 0.25)
	sprout_mat.emission_enabled = true
	sprout_mat.emission = Color(0.20, 0.55, 0.15)
	sprout_mat.emission_energy_multiplier = 0.18
	sprout_mat.roughness = 0.70
	for r in 4:
		var row: MeshInstance3D = MeshInstance3D.new()
		var rm: BoxMesh = BoxMesh.new()
		rm.size = Vector3(6.0, 0.18, 0.6)
		row.mesh = rm
		row.material_override = dirt_mat
		row.position = Vector3(0, 0.09, r * 1.0)
		rows.add_child(row)
		# Sprouts spaced along the row
		for s in 8:
			var sprout: MeshInstance3D = MeshInstance3D.new()
			var sm: PrismMesh = PrismMesh.new()
			sm.size = Vector3(0.10, 0.30, 0.10)
			sprout.mesh = sm
			sprout.material_override = sprout_mat
			sprout.position = Vector3(-2.6 + s * 0.74, 0.30, r * 1.0)
			rows.add_child(sprout)


func _build_d4_water_trough(geom: Node) -> void:
	## Epic-4 T62: long wooden water trough with shimmering water surface.
	var trough: Node3D = Node3D.new()
	trough.name = "WaterTrough"
	trough.position = Vector3(D4_CENTER.x + 4.0, 0.0, 8.0)
	geom.add_child(trough)
	var wood_mat: StandardMaterial3D = StandardMaterial3D.new()
	wood_mat.albedo_color = Color(0.48, 0.30, 0.15)
	wood_mat.roughness = 0.90
	# Outer hollow box (made from 4 walls + base)
	var base: MeshInstance3D = MeshInstance3D.new()
	var bm: BoxMesh = BoxMesh.new()
	bm.size = Vector3(2.4, 0.10, 0.8)
	base.mesh = bm
	base.material_override = wood_mat
	base.position = Vector3(0, 0.05, 0)
	trough.add_child(base)
	var walls: Array = [
		{"size": Vector3(2.4, 0.40, 0.10), "pos": Vector3(0, 0.30,  0.40)},
		{"size": Vector3(2.4, 0.40, 0.10), "pos": Vector3(0, 0.30, -0.40)},
		{"size": Vector3(0.10, 0.40, 0.80), "pos": Vector3( 1.20, 0.30, 0)},
		{"size": Vector3(0.10, 0.40, 0.80), "pos": Vector3(-1.20, 0.30, 0)},
	]
	for w in walls:
		var wall: MeshInstance3D = MeshInstance3D.new()
		var wm: BoxMesh = BoxMesh.new()
		wm.size = w["size"]
		wall.mesh = wm
		wall.material_override = wood_mat
		wall.position = w["pos"]
		trough.add_child(wall)
	# Water surface (translucent cyan)
	var water: MeshInstance3D = MeshInstance3D.new()
	var waterm: BoxMesh = BoxMesh.new()
	waterm.size = Vector3(2.30, 0.05, 0.70)
	water.mesh = waterm
	var water_mat: StandardMaterial3D = StandardMaterial3D.new()
	water_mat.albedo_color = Color(0.30, 0.65, 0.85, 0.75)
	water_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	water_mat.emission_enabled = true
	water_mat.emission = Color(0.20, 0.50, 0.85)
	water_mat.emission_energy_multiplier = 0.40
	water_mat.metallic = 0.30
	water_mat.roughness = 0.10
	water.material_override = water_mat
	water.position = Vector3(0, 0.45, 0)
	trough.add_child(water)
	# Subtle bob
	var tw: Tween = water.create_tween().set_loops()
	tw.tween_property(water, "position:y", 0.47, 1.5)
	tw.tween_property(water, "position:y", 0.45, 1.5)
	# Collision
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(2.4, 0.5, 0.8)
	cs.shape = cb
	cs.position = Vector3(0, 0.25, 0)
	sb.add_child(cs)
	trough.add_child(sb)


func _build_d4_shepherd_npc(town: Node) -> void:
	## Epic-4 T63: shepherd NPC with brown robe + tall crook.
	var npc_slots: Node3D = town.get_node_or_null("%NPCSlots") as Node3D
	if npc_slots == null:
		return
	var slot: Marker3D = Marker3D.new()
	slot.name = "ShepherdSlot"
	slot.position = Vector3(D4_CENTER.x + 6.0, 0.0, 10.0)
	npc_slots.add_child(slot)
	var npc_scene: PackedScene = load("res://scenes/entities/npcs/VillagerR3.tscn") as PackedScene
	if npc_scene == null:
		return
	var npc: Node3D = npc_scene.instantiate() as Node3D
	npc.name = "Shepherd"
	if "npc_name" in npc:
		npc.set("npc_name", "Pasture Keeper")
	if "npc_id" in npc:
		npc.set("npc_id", "shepherd_d4")
	slot.add_child(npc)
	# Tall wooden crook
	var crook: Node3D = Node3D.new()
	crook.position = Vector3(0.40, 0, 0)
	npc.add_child(crook)
	var staff: MeshInstance3D = MeshInstance3D.new()
	var stm: CylinderMesh = CylinderMesh.new()
	stm.top_radius = 0.04
	stm.bottom_radius = 0.05
	stm.height = 1.85
	staff.mesh = stm
	var wood_mat: StandardMaterial3D = StandardMaterial3D.new()
	wood_mat.albedo_color = Color(0.45, 0.28, 0.12)
	wood_mat.roughness = 0.85
	staff.material_override = wood_mat
	staff.position = Vector3(0, 0.92, 0)
	crook.add_child(staff)
	# Crook curl (torus)
	var curl: MeshInstance3D = MeshInstance3D.new()
	var tm: TorusMesh = TorusMesh.new()
	tm.inner_radius = 0.13
	tm.outer_radius = 0.20
	curl.mesh = tm
	curl.material_override = wood_mat
	curl.position = Vector3(0, 1.85, 0)
	curl.rotation_degrees = Vector3(90, 0, 0)
	crook.add_child(curl)
	# Brown robe block (overlay color hint)
	var robe: MeshInstance3D = MeshInstance3D.new()
	var rm: BoxMesh = BoxMesh.new()
	rm.size = Vector3(0.55, 0.85, 0.35)
	robe.mesh = rm
	var robe_mat: StandardMaterial3D = StandardMaterial3D.new()
	robe_mat.albedo_color = Color(0.45, 0.30, 0.18)
	robe_mat.roughness = 0.85
	robe.material_override = robe_mat
	robe.position = Vector3(0, 0.55, 0)
	npc.add_child(robe)


func _build_d4_sheep_flock(geom: Node) -> void:
	## Epic-4 T64: 5 fluffy sheep grazing in a loose group with idle bobbing.
	var flock: Node3D = Node3D.new()
	flock.name = "SheepFlock"
	flock.position = Vector3(D4_CENTER.x + 8.0, 0.0, 4.0)
	geom.add_child(flock)
	var wool_mat: StandardMaterial3D = StandardMaterial3D.new()
	wool_mat.albedo_color = Color(0.92, 0.92, 0.88)
	wool_mat.roughness = 0.95
	var face_mat: StandardMaterial3D = StandardMaterial3D.new()
	face_mat.albedo_color = Color(0.20, 0.18, 0.15)
	face_mat.roughness = 0.85
	var leg_mat: StandardMaterial3D = StandardMaterial3D.new()
	leg_mat.albedo_color = Color(0.25, 0.22, 0.18)
	leg_mat.roughness = 0.85
	var positions: Array = [
		Vector3( 0.0, 0,  0.0),
		Vector3( 1.8, 0,  0.6),
		Vector3(-1.5, 0,  1.2),
		Vector3( 2.4, 0, -1.3),
		Vector3(-0.8, 0, -1.6),
	]
	for p in positions:
		var sheep: Node3D = Node3D.new()
		sheep.position = p
		flock.add_child(sheep)
		# Wool body (3 overlapping spheres)
		for i in 3:
			var wool: MeshInstance3D = MeshInstance3D.new()
			var wm: SphereMesh = SphereMesh.new()
			wm.radius = 0.30
			wm.height = 0.55
			wool.mesh = wm
			wool.material_override = wool_mat
			wool.position = Vector3((i - 1) * 0.20, 0.55, 0)
			wool.scale = Vector3(1.0, 0.95, 1.10)
			sheep.add_child(wool)
		# Head (dark sphere with face)
		var head: MeshInstance3D = MeshInstance3D.new()
		var hm: SphereMesh = SphereMesh.new()
		hm.radius = 0.16
		hm.height = 0.28
		head.mesh = hm
		head.material_override = face_mat
		head.position = Vector3(0.40, 0.55, 0)
		sheep.add_child(head)
		# 4 legs
		var leg_positions: Array = [
			Vector3( 0.18, 0.18,  0.15),
			Vector3( 0.18, 0.18, -0.15),
			Vector3(-0.18, 0.18,  0.15),
			Vector3(-0.18, 0.18, -0.15),
		]
		for lp in leg_positions:
			var leg: MeshInstance3D = MeshInstance3D.new()
			var lm: CylinderMesh = CylinderMesh.new()
			lm.top_radius = 0.05
			lm.bottom_radius = 0.05
			lm.height = 0.36
			leg.mesh = lm
			leg.material_override = leg_mat
			leg.position = lp
			sheep.add_child(leg)
		# Grazing tween: head bob
		var tw: Tween = sheep.create_tween().set_loops()
		tw.tween_property(head, "position:y", 0.40, 0.8 + randf() * 0.4)
		tw.tween_property(head, "position:y", 0.55, 0.8 + randf() * 0.4)
		# Collision
		var sb: StaticBody3D = StaticBody3D.new()
		var cs: CollisionShape3D = CollisionShape3D.new()
		var cb: BoxShape3D = BoxShape3D.new()
		cb.size = Vector3(0.85, 0.75, 0.55)
		cs.shape = cb
		cs.position = Vector3(0, 0.50, 0)
		sb.add_child(cs)
		sheep.add_child(sb)


func _build_d4_sheepdog(geom: Node) -> void:
	## Epic-4 T65: black-and-white sheepdog patrolling around the flock.
	var dog: Node3D = Node3D.new()
	dog.name = "Sheepdog"
	dog.position = Vector3(D4_CENTER.x + 10.0, 0.0, 5.5)
	geom.add_child(dog)
	# Body — white with black patches
	var white_mat: StandardMaterial3D = StandardMaterial3D.new()
	white_mat.albedo_color = Color(0.95, 0.94, 0.92)
	white_mat.roughness = 0.85
	var black_mat: StandardMaterial3D = StandardMaterial3D.new()
	black_mat.albedo_color = Color(0.10, 0.08, 0.08)
	black_mat.roughness = 0.85
	var body: MeshInstance3D = MeshInstance3D.new()
	var bm: SphereMesh = SphereMesh.new()
	bm.radius = 0.22
	bm.height = 0.36
	body.mesh = bm
	body.material_override = white_mat
	body.position = Vector3(0, 0.32, 0)
	body.scale = Vector3(1.0, 0.85, 1.55)
	dog.add_child(body)
	# Black patch on back
	var patch: MeshInstance3D = MeshInstance3D.new()
	var pm: SphereMesh = SphereMesh.new()
	pm.radius = 0.18
	pm.height = 0.30
	patch.mesh = pm
	patch.material_override = black_mat
	patch.position = Vector3(0, 0.42, -0.05)
	patch.scale = Vector3(0.85, 0.40, 1.20)
	dog.add_child(patch)
	# Head
	var head: MeshInstance3D = MeshInstance3D.new()
	var hm: SphereMesh = SphereMesh.new()
	hm.radius = 0.14
	hm.height = 0.24
	head.mesh = hm
	head.material_override = black_mat
	head.position = Vector3(0, 0.42, 0.32)
	dog.add_child(head)
	# Snout (white)
	var snout: MeshInstance3D = MeshInstance3D.new()
	var sm: BoxMesh = BoxMesh.new()
	sm.size = Vector3(0.10, 0.08, 0.16)
	snout.mesh = sm
	snout.material_override = white_mat
	snout.position = Vector3(0, 0.36, 0.46)
	dog.add_child(snout)
	# 4 legs
	var leg_positions: Array = [
		Vector3( 0.13, 0.10,  0.20),
		Vector3( 0.13, 0.10, -0.20),
		Vector3(-0.13, 0.10,  0.20),
		Vector3(-0.13, 0.10, -0.20),
	]
	for lp in leg_positions:
		var leg: MeshInstance3D = MeshInstance3D.new()
		var lm: CylinderMesh = CylinderMesh.new()
		lm.top_radius = 0.04
		lm.bottom_radius = 0.04
		lm.height = 0.20
		leg.mesh = lm
		leg.material_override = black_mat
		leg.position = lp
		dog.add_child(leg)
	# Tail
	var tail: MeshInstance3D = MeshInstance3D.new()
	var tm: CylinderMesh = CylinderMesh.new()
	tm.top_radius = 0.03
	tm.bottom_radius = 0.05
	tm.height = 0.22
	tail.mesh = tm
	tail.material_override = white_mat
	tail.position = Vector3(0, 0.40, -0.36)
	tail.rotation_degrees = Vector3(70, 0, 0)
	dog.add_child(tail)
	# Patrol tween — circles the flock area
	var tw: Tween = dog.create_tween().set_loops()
	tw.tween_property(dog, "position", Vector3(D4_CENTER.x + 6.0, 0.0, 7.5), 4.0)
	tw.tween_property(dog, "position", Vector3(D4_CENTER.x + 4.0, 0.0, 4.0), 4.0)
	tw.tween_property(dog, "position", Vector3(D4_CENTER.x + 8.0, 0.0, 2.5), 4.0)
	tw.tween_property(dog, "position", Vector3(D4_CENTER.x + 10.0, 0.0, 5.5), 4.0)
	# Tail wag
	var twag: Tween = tail.create_tween().set_loops()
	twag.tween_property(tail, "rotation_degrees:y", 25.0, 0.25)
	twag.tween_property(tail, "rotation_degrees:y", -25.0, 0.25)


func _build_d4_cherry_orchard(geom: Node) -> void:
	## Epic-4 T66: 3 rows × 3 cherry trees with pink blossoms and red fruit.
	var orchard: Node3D = Node3D.new()
	orchard.name = "CherryOrchard"
	orchard.position = Vector3(D4_CENTER.x - 13.0, 0.0, -10.0)
	geom.add_child(orchard)
	var trunk_mat: StandardMaterial3D = StandardMaterial3D.new()
	trunk_mat.albedo_color = Color(0.35, 0.22, 0.12)
	trunk_mat.roughness = 0.90
	var blossom_mat: StandardMaterial3D = StandardMaterial3D.new()
	blossom_mat.albedo_color = Color(0.95, 0.75, 0.85)
	blossom_mat.emission_enabled = true
	blossom_mat.emission = Color(0.85, 0.55, 0.70)
	blossom_mat.emission_energy_multiplier = 0.20
	blossom_mat.roughness = 0.70
	var cherry_mat: StandardMaterial3D = StandardMaterial3D.new()
	cherry_mat.albedo_color = Color(0.90, 0.10, 0.15)
	cherry_mat.emission_enabled = true
	cherry_mat.emission = Color(0.85, 0.10, 0.10)
	cherry_mat.emission_energy_multiplier = 0.40
	cherry_mat.roughness = 0.30
	for r in 3:
		for c in 3:
			var tree: Node3D = Node3D.new()
			tree.position = Vector3(c * 2.6, 0, r * 2.6)
			orchard.add_child(tree)
			# Trunk
			var trunk: MeshInstance3D = MeshInstance3D.new()
			var tm: CylinderMesh = CylinderMesh.new()
			tm.top_radius = 0.10
			tm.bottom_radius = 0.16
			tm.height = 1.6
			trunk.mesh = tm
			trunk.material_override = trunk_mat
			trunk.position = Vector3(0, 0.80, 0)
			tree.add_child(trunk)
			# Canopy of 3 blossom spheres
			for i in 3:
				var canopy: MeshInstance3D = MeshInstance3D.new()
				var sm: SphereMesh = SphereMesh.new()
				sm.radius = 0.55
				sm.height = 0.95
				canopy.mesh = sm
				canopy.material_override = blossom_mat
				canopy.position = Vector3(
					randf_range(-0.30, 0.30),
					1.70 + randf_range(-0.10, 0.20),
					randf_range(-0.30, 0.30)
				)
				tree.add_child(canopy)
			# Cherry clusters (5 small bright red spheres)
			for i in 5:
				var cherry: MeshInstance3D = MeshInstance3D.new()
				var cm: SphereMesh = SphereMesh.new()
				cm.radius = 0.07
				cm.height = 0.14
				cherry.mesh = cm
				cherry.material_override = cherry_mat
				cherry.position = Vector3(
					randf_range(-0.45, 0.45),
					1.55 + randf_range(-0.10, 0.30),
					randf_range(-0.45, 0.45)
				)
				tree.add_child(cherry)
			# Trunk collision
			var sb: StaticBody3D = StaticBody3D.new()
			var cs: CollisionShape3D = CollisionShape3D.new()
			var cap: CapsuleShape3D = CapsuleShape3D.new()
			cap.radius = 0.18
			cap.height = 1.6
			cs.shape = cap
			cs.position = Vector3(0, 0.80, 0)
			sb.add_child(cs)
			tree.add_child(sb)


func _build_d4_preserves_stand(geom: Node) -> void:
	## Epic-4 T67: roadside preserves stand — wooden table with rows of
	## colored jars (jam, honey, pickles).
	var stand: Node3D = Node3D.new()
	stand.name = "PreservesStand"
	stand.position = Vector3(D4_CENTER.x - 9.0, 0.0, 8.0)
	geom.add_child(stand)
	var wood_mat: StandardMaterial3D = StandardMaterial3D.new()
	wood_mat.albedo_color = Color(0.50, 0.32, 0.16)
	wood_mat.roughness = 0.85
	# Table top
	var top: MeshInstance3D = MeshInstance3D.new()
	var tm: BoxMesh = BoxMesh.new()
	tm.size = Vector3(2.4, 0.10, 0.85)
	top.mesh = tm
	top.material_override = wood_mat
	top.position = Vector3(0, 0.90, 0)
	stand.add_child(top)
	# Legs
	var leg_positions: Array = [
		Vector3( 1.10, 0.45,  0.35),
		Vector3( 1.10, 0.45, -0.35),
		Vector3(-1.10, 0.45,  0.35),
		Vector3(-1.10, 0.45, -0.35),
	]
	for lp in leg_positions:
		var leg: MeshInstance3D = MeshInstance3D.new()
		var lm: BoxMesh = BoxMesh.new()
		lm.size = Vector3(0.10, 0.90, 0.10)
		leg.mesh = lm
		leg.material_override = wood_mat
		leg.position = lp
		stand.add_child(leg)
	# Roof shade (slanted)
	var roof: MeshInstance3D = MeshInstance3D.new()
	var rm: BoxMesh = BoxMesh.new()
	rm.size = Vector3(2.6, 0.06, 1.10)
	roof.mesh = rm
	var roof_mat: StandardMaterial3D = StandardMaterial3D.new()
	roof_mat.albedo_color = Color(0.65, 0.20, 0.15)
	roof_mat.roughness = 0.85
	roof.material_override = roof_mat
	roof.position = Vector3(0, 1.85, -0.10)
	roof.rotation_degrees = Vector3(-12, 0, 0)
	stand.add_child(roof)
	# Roof support posts
	for sx in [-1.10, 1.10]:
		var post: MeshInstance3D = MeshInstance3D.new()
		var pm: CylinderMesh = CylinderMesh.new()
		pm.top_radius = 0.05
		pm.bottom_radius = 0.05
		pm.height = 0.95
		post.mesh = pm
		post.material_override = wood_mat
		post.position = Vector3(sx, 1.40, -0.30)
		stand.add_child(post)
	# Jars — 9 jars in 3 rows of 3
	var jar_colors: Array = [
		Color(0.85, 0.20, 0.20),  # strawberry jam
		Color(0.95, 0.65, 0.10),  # honey
		Color(0.65, 0.85, 0.20),  # pickles
	]
	for row_idx in 3:
		for col in 3:
			var jar: MeshInstance3D = MeshInstance3D.new()
			var jm: CylinderMesh = CylinderMesh.new()
			jm.top_radius = 0.10
			jm.bottom_radius = 0.10
			jm.height = 0.28
			jar.mesh = jm
			var jar_mat: StandardMaterial3D = StandardMaterial3D.new()
			jar_mat.albedo_color = jar_colors[row_idx]
			jar_mat.emission_enabled = true
			jar_mat.emission = jar_colors[row_idx]
			jar_mat.emission_energy_multiplier = 0.25
			jar_mat.metallic = 0.40
			jar_mat.roughness = 0.20
			jar.material_override = jar_mat
			jar.position = Vector3(-0.80 + col * 0.80, 1.10, -0.25 + row_idx * 0.25)
			stand.add_child(jar)
			# Lid (small dark cap)
			var lid: MeshInstance3D = MeshInstance3D.new()
			var lm: CylinderMesh = CylinderMesh.new()
			lm.top_radius = 0.11
			lm.bottom_radius = 0.11
			lm.height = 0.04
			lid.mesh = lm
			var lid_mat: StandardMaterial3D = StandardMaterial3D.new()
			lid_mat.albedo_color = Color(0.20, 0.18, 0.15)
			lid_mat.metallic = 0.70
			lid_mat.roughness = 0.50
			lid.material_override = lid_mat
			lid.position = Vector3(-0.80 + col * 0.80, 1.26, -0.25 + row_idx * 0.25)
			stand.add_child(lid)
	# Collision
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(2.4, 1.85, 1.10)
	cs.shape = cb
	cs.position = Vector3(0, 0.92, 0)
	sb.add_child(cs)
	stand.add_child(sb)


func _build_d4_child_npc(town: Node) -> void:
	## Epic-4 T68: child NPC playing with a wooden hoop, smaller scale than adult NPCs.
	var npc_slots: Node3D = town.get_node_or_null("%NPCSlots") as Node3D
	if npc_slots == null:
		return
	var slot: Marker3D = Marker3D.new()
	slot.name = "ChildSlot"
	slot.position = Vector3(D4_CENTER.x - 7.0, 0.0, 5.0)
	npc_slots.add_child(slot)
	var npc_scene: PackedScene = load("res://scenes/entities/npcs/VillagerR3.tscn") as PackedScene
	if npc_scene == null:
		return
	var npc: Node3D = npc_scene.instantiate() as Node3D
	npc.name = "ChildPlaying"
	if "npc_name" in npc:
		npc.set("npc_name", "Sprout")
	if "npc_id" in npc:
		npc.set("npc_id", "child_d4")
	npc.scale = Vector3(0.65, 0.65, 0.65)
	slot.add_child(npc)
	# Wooden hoop (torus, vertical) next to the child
	var hoop: MeshInstance3D = MeshInstance3D.new()
	var tm: TorusMesh = TorusMesh.new()
	tm.inner_radius = 0.45
	tm.outer_radius = 0.55
	hoop.mesh = tm
	var hoop_mat: StandardMaterial3D = StandardMaterial3D.new()
	hoop_mat.albedo_color = Color(0.60, 0.40, 0.20)
	hoop_mat.roughness = 0.85
	hoop.material_override = hoop_mat
	hoop.position = Vector3(0.70, 0.55, 0)
	hoop.rotation_degrees = Vector3(0, 0, 0)
	slot.add_child(hoop)
	# Hoop spin tween
	var tw: Tween = hoop.create_tween().set_loops()
	tw.tween_property(hoop, "rotation_degrees:y", 360.0, 2.0)
	tw.tween_property(hoop, "rotation_degrees:y", 0.0, 0.0)
	# Tiny bouncing motion on the child
	var tb: Tween = npc.create_tween().set_loops()
	tb.tween_property(npc, "position:y", 0.10, 0.45)
	tb.tween_property(npc, "position:y", 0.0, 0.45)


func _build_d4_dandelion_patch(geom: Node) -> void:
	## Epic-4 T69: meadow patch of dandelion puffballs — white fluffy spheres
	## on thin green stems with subtle drift particles.
	var patch: Node3D = Node3D.new()
	patch.name = "DandelionPatch"
	patch.position = Vector3(D4_CENTER.x + 11.0, 0.0, -2.0)
	geom.add_child(patch)
	var stem_mat: StandardMaterial3D = StandardMaterial3D.new()
	stem_mat.albedo_color = Color(0.30, 0.65, 0.25)
	stem_mat.roughness = 0.75
	var puff_mat: StandardMaterial3D = StandardMaterial3D.new()
	puff_mat.albedo_color = Color(0.95, 0.95, 0.95, 0.85)
	puff_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	puff_mat.emission_enabled = true
	puff_mat.emission = Color(0.85, 0.85, 0.85)
	puff_mat.emission_energy_multiplier = 0.30
	puff_mat.roughness = 0.95
	for i in 14:
		var dande: Node3D = Node3D.new()
		dande.position = Vector3(
			randf_range(-2.5, 2.5),
			0.0,
			randf_range(-2.5, 2.5)
		)
		patch.add_child(dande)
		var stem: MeshInstance3D = MeshInstance3D.new()
		var stm: CylinderMesh = CylinderMesh.new()
		stm.top_radius = 0.015
		stm.bottom_radius = 0.025
		stm.height = 0.50 + randf() * 0.20
		stem.mesh = stm
		stem.material_override = stem_mat
		stem.position = Vector3(0, stm.height * 0.5, 0)
		dande.add_child(stem)
		var puff: MeshInstance3D = MeshInstance3D.new()
		var pm: SphereMesh = SphereMesh.new()
		pm.radius = 0.09
		pm.height = 0.18
		puff.mesh = pm
		puff.material_override = puff_mat
		puff.position = Vector3(0, stm.height + 0.05, 0)
		dande.add_child(puff)
		# Subtle sway tween
		var tw: Tween = dande.create_tween().set_loops()
		tw.tween_property(dande, "rotation_degrees:z", 4.0, 1.5 + randf())
		tw.tween_property(dande, "rotation_degrees:z", -4.0, 1.5 + randf())


func _build_d4_rope_swing(geom: Node) -> void:
	## Epic-4 T70: rope swing — overhead horizontal branch with two ropes
	## holding a wooden plank seat that gently swings.
	var swing: Node3D = Node3D.new()
	swing.name = "RopeSwing"
	swing.position = Vector3(D4_CENTER.x - 10.0, 0.0, -4.0)
	geom.add_child(swing)
	# Tall trunk supporting the branch
	var trunk_mat: StandardMaterial3D = StandardMaterial3D.new()
	trunk_mat.albedo_color = Color(0.35, 0.22, 0.12)
	trunk_mat.roughness = 0.90
	var trunk: MeshInstance3D = MeshInstance3D.new()
	var trm: CylinderMesh = CylinderMesh.new()
	trm.top_radius = 0.18
	trm.bottom_radius = 0.30
	trm.height = 4.0
	trunk.mesh = trm
	trunk.material_override = trunk_mat
	trunk.position = Vector3(-1.5, 2.0, 0)
	swing.add_child(trunk)
	# Overhead branch (horizontal cylinder)
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
	rope_mat.albedo_color = Color(0.75, 0.65, 0.45)
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
	# Wooden plank seat
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
	# Gentle swing tween (rotate the pivot)
	var tw: Tween = pivot.create_tween().set_loops()
	tw.tween_property(pivot, "rotation_degrees:x", 12.0, 1.4)
	tw.tween_property(pivot, "rotation_degrees:x", -12.0, 1.4)
	# Trunk collision
	var sb: StaticBody3D = StaticBody3D.new()
	sb.position = Vector3(-1.5, 2.0, 0)
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cap: CapsuleShape3D = CapsuleShape3D.new()
	cap.radius = 0.32
	cap.height = 4.0
	cs.shape = cap
	sb.add_child(cs)
	swing.add_child(sb)


func _build_d4_ancient_willow(geom: Node) -> void:
	## Epic-4 T71: massive ancient willow — fat trunk, broad bowl-shaped
	## canopy, and drooping vine ropes that hang to the ground.
	var willow: Node3D = Node3D.new()
	willow.name = "AncientWillow"
	willow.position = Vector3(D4_CENTER.x + 14.0, 0.0, 6.0)
	geom.add_child(willow)
	# Trunk
	var trunk_mat: StandardMaterial3D = StandardMaterial3D.new()
	trunk_mat.albedo_color = Color(0.30, 0.20, 0.10)
	trunk_mat.roughness = 0.95
	var trunk: MeshInstance3D = MeshInstance3D.new()
	var trm: CylinderMesh = CylinderMesh.new()
	trm.top_radius = 0.40
	trm.bottom_radius = 0.85
	trm.height = 4.5
	trunk.mesh = trm
	trunk.material_override = trunk_mat
	trunk.position = Vector3(0, 2.25, 0)
	willow.add_child(trunk)
	# Crown — wide flat sphere
	var crown_mat: StandardMaterial3D = StandardMaterial3D.new()
	crown_mat.albedo_color = Color(0.30, 0.55, 0.20)
	crown_mat.emission_enabled = true
	crown_mat.emission = Color(0.20, 0.45, 0.15)
	crown_mat.emission_energy_multiplier = 0.20
	crown_mat.roughness = 0.80
	for i in 5:
		var lobe: MeshInstance3D = MeshInstance3D.new()
		var lm: SphereMesh = SphereMesh.new()
		lm.radius = 1.40
		lm.height = 1.40
		lobe.mesh = lm
		lobe.material_override = crown_mat
		var ang: float = (TAU / 5.0) * i
		lobe.position = Vector3(cos(ang) * 1.2, 4.5 + sin(i) * 0.30, sin(ang) * 1.2)
		lobe.scale = Vector3(1.0, 0.55, 1.0)
		willow.add_child(lobe)
	# Hanging vines — 12 thin droopers
	var vine_mat: StandardMaterial3D = StandardMaterial3D.new()
	vine_mat.albedo_color = Color(0.40, 0.65, 0.30)
	vine_mat.emission_enabled = true
	vine_mat.emission = Color(0.30, 0.55, 0.20)
	vine_mat.emission_energy_multiplier = 0.20
	vine_mat.roughness = 0.85
	for i in 12:
		var ang: float = (TAU / 12.0) * i
		var radius: float = 1.6 + randf() * 0.4
		var vine: MeshInstance3D = MeshInstance3D.new()
		var vm: CylinderMesh = CylinderMesh.new()
		vm.top_radius = 0.05
		vm.bottom_radius = 0.025
		vm.height = 3.5 + randf() * 0.6
		vine.mesh = vm
		vine.material_override = vine_mat
		vine.position = Vector3(cos(ang) * radius, 2.6, sin(ang) * radius)
		willow.add_child(vine)
		# Sway tween
		var tw: Tween = vine.create_tween().set_loops()
		tw.tween_property(vine, "rotation_degrees:z", 3.0, 1.8 + randf() * 0.5)
		tw.tween_property(vine, "rotation_degrees:z", -3.0, 1.8 + randf() * 0.5)
	# Trunk collision
	var sb: StaticBody3D = StaticBody3D.new()
	sb.position = Vector3(0, 2.25, 0)
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cap: CapsuleShape3D = CapsuleShape3D.new()
	cap.radius = 0.85
	cap.height = 4.5
	cs.shape = cap
	sb.add_child(cs)
	willow.add_child(sb)


func _build_d4_garden_statue(geom: Node) -> void:
	## Epic-4 T72: stone garden statue of a woodland deity — pedestal +
	## robed figure + flower crown + soft amber emission for guardian aura.
	var statue: Node3D = Node3D.new()
	statue.name = "GardenStatue"
	statue.position = Vector3(D4_CENTER.x - 4.0, 0.0, -8.0)
	geom.add_child(statue)
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.65, 0.62, 0.55)
	stone_mat.roughness = 0.95
	# Pedestal (3-tier)
	var p1: MeshInstance3D = MeshInstance3D.new()
	var p1m: BoxMesh = BoxMesh.new()
	p1m.size = Vector3(1.40, 0.30, 1.40)
	p1.mesh = p1m
	p1.material_override = stone_mat
	p1.position = Vector3(0, 0.15, 0)
	statue.add_child(p1)
	var p2: MeshInstance3D = MeshInstance3D.new()
	var p2m: BoxMesh = BoxMesh.new()
	p2m.size = Vector3(1.10, 0.25, 1.10)
	p2.mesh = p2m
	p2.material_override = stone_mat
	p2.position = Vector3(0, 0.42, 0)
	statue.add_child(p2)
	var p3: MeshInstance3D = MeshInstance3D.new()
	var p3m: CylinderMesh = CylinderMesh.new()
	p3m.top_radius = 0.45
	p3m.bottom_radius = 0.50
	p3m.height = 0.20
	p3.mesh = p3m
	p3.material_override = stone_mat
	p3.position = Vector3(0, 0.65, 0)
	statue.add_child(p3)
	# Robe / body (tapered)
	var body: MeshInstance3D = MeshInstance3D.new()
	var bm: CylinderMesh = CylinderMesh.new()
	bm.top_radius = 0.30
	bm.bottom_radius = 0.45
	bm.height = 1.40
	body.mesh = bm
	body.material_override = stone_mat
	body.position = Vector3(0, 1.45, 0)
	statue.add_child(body)
	# Head
	var head: MeshInstance3D = MeshInstance3D.new()
	var hm: SphereMesh = SphereMesh.new()
	hm.radius = 0.22
	hm.height = 0.40
	head.mesh = hm
	head.material_override = stone_mat
	head.position = Vector3(0, 2.30, 0)
	statue.add_child(head)
	# Flower crown (torus + small flower spheres)
	var crown: MeshInstance3D = MeshInstance3D.new()
	var ctm: TorusMesh = TorusMesh.new()
	ctm.inner_radius = 0.20
	ctm.outer_radius = 0.26
	crown.mesh = ctm
	var crown_mat: StandardMaterial3D = StandardMaterial3D.new()
	crown_mat.albedo_color = Color(0.85, 0.65, 0.30)
	crown_mat.emission_enabled = true
	crown_mat.emission = Color(0.95, 0.65, 0.20)
	crown_mat.emission_energy_multiplier = 0.55
	crown_mat.metallic = 0.50
	crown_mat.roughness = 0.40
	crown.material_override = crown_mat
	crown.position = Vector3(0, 2.50, 0)
	statue.add_child(crown)
	# Aura light
	var light: OmniLight3D = OmniLight3D.new()
	light.light_color = Color(1.0, 0.85, 0.55)
	light.light_energy = 1.8
	light.omni_range = 5.0
	light.position = Vector3(0, 2.30, 0)
	statue.add_child(light)
	# Subtle aura pulse
	var tw: Tween = light.create_tween().set_loops()
	tw.tween_property(light, "light_energy", 2.4, 1.8)
	tw.tween_property(light, "light_energy", 1.8, 1.8)
	# Collision
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(1.40, 2.50, 1.40)
	cs.shape = cb
	cs.position = Vector3(0, 1.25, 0)
	sb.add_child(cs)
	statue.add_child(sb)


func _build_d4_forager_npc(town: Node) -> void:
	## Epic-4 T73: forager NPC with woven basket carrying glowing mushrooms.
	var npc_slots: Node3D = town.get_node_or_null("%NPCSlots") as Node3D
	if npc_slots == null:
		return
	var slot: Marker3D = Marker3D.new()
	slot.name = "ForagerSlot"
	slot.position = Vector3(D4_CENTER.x - 2.0, 0.0, 12.0)
	npc_slots.add_child(slot)
	var npc_scene: PackedScene = load("res://scenes/entities/npcs/VillagerR3.tscn") as PackedScene
	if npc_scene == null:
		return
	var npc: Node3D = npc_scene.instantiate() as Node3D
	npc.name = "Forager"
	if "npc_name" in npc:
		npc.set("npc_name", "Mossfoot")
	if "npc_id" in npc:
		npc.set("npc_id", "forager_d4")
	slot.add_child(npc)
	# Basket (cylinder, woven brown)
	var basket: MeshInstance3D = MeshInstance3D.new()
	var bm: CylinderMesh = CylinderMesh.new()
	bm.top_radius = 0.28
	bm.bottom_radius = 0.22
	bm.height = 0.30
	basket.mesh = bm
	var basket_mat: StandardMaterial3D = StandardMaterial3D.new()
	basket_mat.albedo_color = Color(0.50, 0.32, 0.16)
	basket_mat.roughness = 0.95
	basket.material_override = basket_mat
	basket.position = Vector3(0.45, 0.55, 0.10)
	slot.add_child(basket)
	# Mushrooms inside (5 small glowing caps)
	var cap_mat: StandardMaterial3D = StandardMaterial3D.new()
	cap_mat.albedo_color = Color(0.95, 0.45, 0.20)
	cap_mat.emission_enabled = true
	cap_mat.emission = Color(0.85, 0.30, 0.15)
	cap_mat.emission_energy_multiplier = 0.85
	cap_mat.roughness = 0.55
	for i in 5:
		var cap: MeshInstance3D = MeshInstance3D.new()
		var cm: SphereMesh = SphereMesh.new()
		cm.radius = 0.08
		cm.height = 0.14
		cap.mesh = cm
		cap.material_override = cap_mat
		cap.position = Vector3(
			0.45 + randf_range(-0.15, 0.15),
			0.74,
			0.10 + randf_range(-0.15, 0.15)
		)
		slot.add_child(cap)


func _build_d4_fairy_lights(geom: Node) -> void:
	## Epic-4 T74: string of glowing fairy lights between two posts. Each
	## bulb is a small emissive sphere with an OmniLight3D.
	var strand: Node3D = Node3D.new()
	strand.name = "FairyLights"
	strand.position = Vector3(D4_CENTER.x - 5.0, 0.0, 0.0)
	geom.add_child(strand)
	var post_mat: StandardMaterial3D = StandardMaterial3D.new()
	post_mat.albedo_color = Color(0.45, 0.30, 0.18)
	post_mat.roughness = 0.85
	# Two posts
	for sx in [-3.5, 3.5]:
		var post: MeshInstance3D = MeshInstance3D.new()
		var pm: CylinderMesh = CylinderMesh.new()
		pm.top_radius = 0.06
		pm.bottom_radius = 0.08
		pm.height = 2.5
		post.mesh = pm
		post.material_override = post_mat
		post.position = Vector3(sx, 1.25, 0)
		strand.add_child(post)
		# Post collision
		var sb: StaticBody3D = StaticBody3D.new()
		sb.position = Vector3(sx, 1.25, 0)
		var cs: CollisionShape3D = CollisionShape3D.new()
		var cap: CapsuleShape3D = CapsuleShape3D.new()
		cap.radius = 0.10
		cap.height = 2.5
		cs.shape = cap
		sb.add_child(cs)
		strand.add_child(sb)
	# Wire (thin cylinder horizontal)
	var wire: MeshInstance3D = MeshInstance3D.new()
	var wm: CylinderMesh = CylinderMesh.new()
	wm.top_radius = 0.012
	wm.bottom_radius = 0.012
	wm.height = 7.0
	wire.mesh = wm
	var wire_mat: StandardMaterial3D = StandardMaterial3D.new()
	wire_mat.albedo_color = Color(0.20, 0.18, 0.15)
	wire_mat.roughness = 0.90
	wire.material_override = wire_mat
	wire.position = Vector3(0, 2.30, 0)
	wire.rotation_degrees = Vector3(0, 0, 90)
	strand.add_child(wire)
	# 9 bulbs spaced along the wire — colored cycling
	var bulb_colors: Array = [
		Color(0.95, 0.30, 0.30),
		Color(0.95, 0.85, 0.30),
		Color(0.30, 0.95, 0.50),
		Color(0.30, 0.65, 0.95),
		Color(0.85, 0.40, 0.95),
	]
	for i in 9:
		var bulb: MeshInstance3D = MeshInstance3D.new()
		var bm2: SphereMesh = SphereMesh.new()
		bm2.radius = 0.07
		bm2.height = 0.14
		bulb.mesh = bm2
		var color: Color = bulb_colors[i % bulb_colors.size()]
		var bulb_mat: StandardMaterial3D = StandardMaterial3D.new()
		bulb_mat.albedo_color = color
		bulb_mat.emission_enabled = true
		bulb_mat.emission = color
		bulb_mat.emission_energy_multiplier = 1.6
		bulb_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		bulb.material_override = bulb_mat
		bulb.position = Vector3(-3.0 + i * 0.75, 2.20, 0)
		strand.add_child(bulb)
		# Tiny light per bulb (cheap range)
		var light: OmniLight3D = OmniLight3D.new()
		light.light_color = color
		light.light_energy = 0.55
		light.omni_range = 1.6
		light.position = Vector3(-3.0 + i * 0.75, 2.20, 0)
		strand.add_child(light)
		# Pulse tween (offset per bulb)
		var tw: Tween = light.create_tween().set_loops()
		tw.tween_interval(i * 0.10)
		tw.tween_property(light, "light_energy", 1.0, 0.6)
		tw.tween_property(light, "light_energy", 0.55, 0.6)


func _build_d4_petal_drift(geom: Node) -> void:
	## Epic-4 T75: GPU particles that drift soft pink petals around the
	## great bloom area, falling slowly downward with random sway.
	var drift: GPUParticles3D = GPUParticles3D.new()
	drift.name = "PetalDrift"
	drift.position = Vector3(D4_CENTER.x, 8.0, 0.0)
	drift.amount = 80
	drift.lifetime = 8.0
	drift.preprocess = 4.0
	drift.explosiveness = 0.0
	drift.randomness = 0.6
	drift.visibility_aabb = AABB(Vector3(-20, -10, -20), Vector3(40, 20, 40))
	var pm: ParticleProcessMaterial = ParticleProcessMaterial.new()
	pm.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	pm.emission_box_extents = Vector3(18, 0.5, 18)
	pm.direction = Vector3(0, -1, 0)
	pm.spread = 25.0
	pm.gravity = Vector3(0, -0.4, 0)
	pm.initial_velocity_min = 0.20
	pm.initial_velocity_max = 0.55
	pm.angular_velocity_min = -90.0
	pm.angular_velocity_max = 90.0
	pm.scale_min = 0.10
	pm.scale_max = 0.18
	pm.color = Color(0.95, 0.65, 0.85, 0.90)
	drift.process_material = pm
	# Petal mesh — small flat box
	var petal_mesh: BoxMesh = BoxMesh.new()
	petal_mesh.size = Vector3(0.18, 0.02, 0.10)
	drift.draw_pass_1 = petal_mesh
	# Material
	var pmat: StandardMaterial3D = StandardMaterial3D.new()
	pmat.albedo_color = Color(0.95, 0.60, 0.80)
	pmat.emission_enabled = true
	pmat.emission = Color(0.85, 0.40, 0.65)
	pmat.emission_energy_multiplier = 0.40
	pmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	pmat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	petal_mesh.material = pmat
	geom.add_child(drift)


func _build_d4_thornling_patrol(geom: Node) -> void:
	## Epic-4 T76: 3 hostile thornling props patrolling along a tween path.
	## Decorative — these are not real combat enemies but show the corruption
	## edge of the bloom cluster. Spiky dark-green pods with red eyes.
	var patrol: Node3D = Node3D.new()
	patrol.name = "ThornlingPatrol"
	patrol.position = Vector3(D4_CENTER.x + 17.0, 0.0, -8.0)
	geom.add_child(patrol)
	var pod_mat: StandardMaterial3D = StandardMaterial3D.new()
	pod_mat.albedo_color = Color(0.15, 0.30, 0.10)
	pod_mat.emission_enabled = true
	pod_mat.emission = Color(0.20, 0.45, 0.15)
	pod_mat.emission_energy_multiplier = 0.30
	pod_mat.roughness = 0.65
	var thorn_mat: StandardMaterial3D = StandardMaterial3D.new()
	thorn_mat.albedo_color = Color(0.40, 0.20, 0.10)
	thorn_mat.roughness = 0.85
	var eye_mat: StandardMaterial3D = StandardMaterial3D.new()
	eye_mat.albedo_color = Color(0.95, 0.10, 0.10)
	eye_mat.emission_enabled = true
	eye_mat.emission = Color(0.95, 0.05, 0.05)
	eye_mat.emission_energy_multiplier = 1.6
	eye_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var start_positions: Array = [
		Vector3( 0.0, 0,  0.0),
		Vector3(-2.5, 0,  1.0),
		Vector3( 2.5, 0, -1.5),
	]
	for i in start_positions.size():
		var thorn: Node3D = Node3D.new()
		thorn.position = start_positions[i]
		patrol.add_child(thorn)
		# Body
		var body: MeshInstance3D = MeshInstance3D.new()
		var bm: SphereMesh = SphereMesh.new()
		bm.radius = 0.40
		bm.height = 0.65
		body.mesh = bm
		body.material_override = pod_mat
		body.position = Vector3(0, 0.45, 0)
		thorn.add_child(body)
		# 6 thorns radiating
		for j in 6:
			var ang: float = (TAU / 6.0) * j
			var spike: MeshInstance3D = MeshInstance3D.new()
			var spm: PrismMesh = PrismMesh.new()
			spm.size = Vector3(0.10, 0.35, 0.10)
			spike.mesh = spm
			spike.material_override = thorn_mat
			spike.position = Vector3(cos(ang) * 0.40, 0.55, sin(ang) * 0.40)
			spike.rotation = Vector3(0, ang, PI * 0.5)
			thorn.add_child(spike)
		# 2 red eyes
		for ex in [-0.10, 0.10]:
			var eye: MeshInstance3D = MeshInstance3D.new()
			var em: SphereMesh = SphereMesh.new()
			em.radius = 0.05
			em.height = 0.10
			eye.mesh = em
			eye.material_override = eye_mat
			eye.position = Vector3(ex, 0.55, 0.32)
			thorn.add_child(eye)
		# Patrol tween — bobbing + drifting
		var tw: Tween = thorn.create_tween().set_loops()
		var sp: Vector3 = start_positions[i]
		tw.tween_property(thorn, "position", sp + Vector3(2.0, 0, 0), 2.5)
		tw.tween_property(thorn, "position", sp + Vector3(2.0, 0, 2.0), 2.5)
		tw.tween_property(thorn, "position", sp + Vector3(0, 0, 2.0), 2.5)
		tw.tween_property(thorn, "position", sp, 2.5)
		# Bob
		var tb: Tween = body.create_tween().set_loops()
		tb.tween_property(body, "position:y", 0.55, 0.6)
		tb.tween_property(body, "position:y", 0.45, 0.6)


func _build_d4_archery_range(geom: Node) -> void:
	## Epic-4 T77: archery range — line of 4 painted bullseye targets on
	## wooden stands at the south end of D4.
	var range_node: Node3D = Node3D.new()
	range_node.name = "ArcheryRange"
	range_node.position = Vector3(D4_CENTER.x - 16.0, 0.0, 14.0)
	geom.add_child(range_node)
	var stand_mat: StandardMaterial3D = StandardMaterial3D.new()
	stand_mat.albedo_color = Color(0.50, 0.32, 0.16)
	stand_mat.roughness = 0.85
	var ring_white: Color = Color(0.95, 0.95, 0.92)
	var ring_red: Color = Color(0.85, 0.10, 0.10)
	var ring_yellow: Color = Color(0.95, 0.85, 0.20)
	var rings: Array = [
		{"r": 0.55, "c": ring_white},
		{"r": 0.40, "c": ring_red},
		{"r": 0.25, "c": ring_white},
		{"r": 0.10, "c": ring_yellow},
	]
	for i in 4:
		var stand: Node3D = Node3D.new()
		stand.position = Vector3(i * 2.4, 0, 0)
		range_node.add_child(stand)
		# 2 vertical posts
		for sx in [-0.50, 0.50]:
			var post: MeshInstance3D = MeshInstance3D.new()
			var pm: BoxMesh = BoxMesh.new()
			pm.size = Vector3(0.10, 1.80, 0.10)
			post.mesh = pm
			post.material_override = stand_mat
			post.position = Vector3(sx, 0.90, 0)
			stand.add_child(post)
		# Horizontal cross brace
		var brace: MeshInstance3D = MeshInstance3D.new()
		var bcm: BoxMesh = BoxMesh.new()
		bcm.size = Vector3(1.20, 0.10, 0.10)
		brace.mesh = bcm
		brace.material_override = stand_mat
		brace.position = Vector3(0, 0.40, 0)
		stand.add_child(brace)
		# Bullseye rings (concentric flat cylinders)
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
			dmat.emission_energy_multiplier = 0.25
			dmat.roughness = 0.55
			disc.material_override = dmat
			disc.position = Vector3(0, 1.20, 0.0 - rings.find(ring) * 0.005)
			disc.rotation_degrees = Vector3(90, 0, 0)
			stand.add_child(disc)
		# Stand collision
		var sb: StaticBody3D = StaticBody3D.new()
		var cs: CollisionShape3D = CollisionShape3D.new()
		var cb: BoxShape3D = BoxShape3D.new()
		cb.size = Vector3(1.20, 1.80, 0.30)
		cs.shape = cb
		cs.position = Vector3(0, 0.90, 0)
		sb.add_child(cs)
		stand.add_child(sb)


func _build_d4_ranger_npc(town: Node) -> void:
	## Epic-4 T78: ranger NPC with green hood + wooden longbow.
	var npc_slots: Node3D = town.get_node_or_null("%NPCSlots") as Node3D
	if npc_slots == null:
		return
	var slot: Marker3D = Marker3D.new()
	slot.name = "RangerSlot"
	slot.position = Vector3(D4_CENTER.x - 12.0, 0.0, 14.0)
	npc_slots.add_child(slot)
	var npc_scene: PackedScene = load("res://scenes/entities/npcs/VillagerR3.tscn") as PackedScene
	if npc_scene == null:
		return
	var npc: Node3D = npc_scene.instantiate() as Node3D
	npc.name = "Ranger"
	if "npc_name" in npc:
		npc.set("npc_name", "Briarstride")
	if "npc_id" in npc:
		npc.set("npc_id", "ranger_d4")
	slot.add_child(npc)
	# Green hood block over head
	var hood: MeshInstance3D = MeshInstance3D.new()
	var hm: SphereMesh = SphereMesh.new()
	hm.radius = 0.20
	hm.height = 0.34
	hood.mesh = hm
	var hood_mat: StandardMaterial3D = StandardMaterial3D.new()
	hood_mat.albedo_color = Color(0.20, 0.45, 0.20)
	hood_mat.roughness = 0.85
	hood.material_override = hood_mat
	hood.position = Vector3(0, 1.40, 0)
	npc.add_child(hood)
	# Longbow at side (curved torus arc visible as full circle, scaled)
	var bow: MeshInstance3D = MeshInstance3D.new()
	var btm: TorusMesh = TorusMesh.new()
	btm.inner_radius = 0.55
	btm.outer_radius = 0.60
	bow.mesh = btm
	var wood_mat: StandardMaterial3D = StandardMaterial3D.new()
	wood_mat.albedo_color = Color(0.45, 0.28, 0.12)
	wood_mat.roughness = 0.85
	bow.material_override = wood_mat
	bow.position = Vector3(0.45, 0.85, 0)
	bow.rotation_degrees = Vector3(0, 0, 90)
	bow.scale = Vector3(1.0, 0.40, 1.0)
	npc.add_child(bow)
	# Bowstring (thin cylinder vertical)
	var string: MeshInstance3D = MeshInstance3D.new()
	var sm: CylinderMesh = CylinderMesh.new()
	sm.top_radius = 0.005
	sm.bottom_radius = 0.005
	sm.height = 1.10
	string.mesh = sm
	var sm_mat: StandardMaterial3D = StandardMaterial3D.new()
	sm_mat.albedo_color = Color(0.95, 0.95, 0.92)
	string.material_override = sm_mat
	string.position = Vector3(0.45, 0.85, 0)
	npc.add_child(string)


func _build_d4_rabbit_family(geom: Node) -> void:
	## Epic-4 T79: rabbit family — 4 rabbits of varying sizes hopping in
	## a meadow patch with bobbing tweens.
	var family: Node3D = Node3D.new()
	family.name = "RabbitFamily"
	family.position = Vector3(D4_CENTER.x - 14.0, 0.0, 0.0)
	geom.add_child(family)
	var fur_mat: StandardMaterial3D = StandardMaterial3D.new()
	fur_mat.albedo_color = Color(0.75, 0.65, 0.55)
	fur_mat.roughness = 0.90
	var ear_mat: StandardMaterial3D = StandardMaterial3D.new()
	ear_mat.albedo_color = Color(0.85, 0.55, 0.50)
	ear_mat.roughness = 0.85
	var eye_mat: StandardMaterial3D = StandardMaterial3D.new()
	eye_mat.albedo_color = Color(0.10, 0.05, 0.05)
	eye_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var configs: Array = [
		{"pos": Vector3( 0.0, 0,  0.0), "scale": 1.00},
		{"pos": Vector3(-1.4, 0,  0.8), "scale": 0.65},
		{"pos": Vector3( 1.5, 0, -0.4), "scale": 0.60},
		{"pos": Vector3( 0.6, 0,  1.6), "scale": 0.55},
	]
	for cfg in configs:
		var rabbit: Node3D = Node3D.new()
		rabbit.position = cfg["pos"]
		rabbit.scale = Vector3.ONE * cfg["scale"]
		family.add_child(rabbit)
		# Body
		var body: MeshInstance3D = MeshInstance3D.new()
		var bm: SphereMesh = SphereMesh.new()
		bm.radius = 0.18
		bm.height = 0.30
		body.mesh = bm
		body.material_override = fur_mat
		body.position = Vector3(0, 0.20, 0)
		body.scale = Vector3(1.0, 0.85, 1.20)
		rabbit.add_child(body)
		# Head
		var head: MeshInstance3D = MeshInstance3D.new()
		var hm: SphereMesh = SphereMesh.new()
		hm.radius = 0.13
		hm.height = 0.22
		head.mesh = hm
		head.material_override = fur_mat
		head.position = Vector3(0, 0.32, 0.18)
		rabbit.add_child(head)
		# 2 long ears
		for ex in [-0.06, 0.06]:
			var ear: MeshInstance3D = MeshInstance3D.new()
			var em: PrismMesh = PrismMesh.new()
			em.size = Vector3(0.06, 0.22, 0.04)
			ear.mesh = em
			ear.material_override = ear_mat
			ear.position = Vector3(ex, 0.50, 0.18)
			rabbit.add_child(ear)
		# 2 small eyes
		for ex in [-0.05, 0.05]:
			var eye: MeshInstance3D = MeshInstance3D.new()
			var emm: SphereMesh = SphereMesh.new()
			emm.radius = 0.02
			emm.height = 0.04
			eye.mesh = emm
			eye.material_override = eye_mat
			eye.position = Vector3(ex, 0.34, 0.30)
			rabbit.add_child(eye)
		# Cotton tail (white sphere)
		var tail: MeshInstance3D = MeshInstance3D.new()
		var tm: SphereMesh = SphereMesh.new()
		tm.radius = 0.06
		tm.height = 0.12
		tail.mesh = tm
		var tail_mat: StandardMaterial3D = StandardMaterial3D.new()
		tail_mat.albedo_color = Color(0.95, 0.95, 0.92)
		tail_mat.roughness = 0.90
		tail.material_override = tail_mat
		tail.position = Vector3(0, 0.20, -0.20)
		rabbit.add_child(tail)
		# Hopping tween
		var tw: Tween = rabbit.create_tween().set_loops()
		var origin: Vector3 = cfg["pos"]
		tw.tween_property(rabbit, "position:y", 0.30, 0.30)
		tw.tween_property(rabbit, "position:y", 0.0, 0.30)
		tw.tween_interval(1.0 + randf() * 0.8)


func _build_d4_ivy_stone_arch(geom: Node) -> void:
	## Epic-4 T80: ivy-covered stone arch marking a side path. Two stone
	## pillars with a curved torus top + green ivy clumps.
	var arch: Node3D = Node3D.new()
	arch.name = "IvyStoneArch"
	arch.position = Vector3(D4_CENTER.x + 16.0, 0.0, 0.0)
	geom.add_child(arch)
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.60, 0.58, 0.52)
	stone_mat.roughness = 0.95
	# 2 pillars
	for sx in [-1.40, 1.40]:
		var pillar: MeshInstance3D = MeshInstance3D.new()
		var pm: BoxMesh = BoxMesh.new()
		pm.size = Vector3(0.55, 3.20, 0.55)
		pillar.mesh = pm
		pillar.material_override = stone_mat
		pillar.position = Vector3(sx, 1.60, 0)
		arch.add_child(pillar)
		# Pillar collision
		var sb: StaticBody3D = StaticBody3D.new()
		sb.position = Vector3(sx, 1.60, 0)
		var cs: CollisionShape3D = CollisionShape3D.new()
		var cb: BoxShape3D = BoxShape3D.new()
		cb.size = Vector3(0.55, 3.20, 0.55)
		cs.shape = cb
		sb.add_child(cs)
		arch.add_child(sb)
	# Curved arch top (half-torus, scaled)
	var top: MeshInstance3D = MeshInstance3D.new()
	var tm: TorusMesh = TorusMesh.new()
	tm.inner_radius = 1.20
	tm.outer_radius = 1.60
	top.mesh = tm
	top.material_override = stone_mat
	top.position = Vector3(0, 3.20, 0)
	top.rotation_degrees = Vector3(90, 0, 0)
	top.scale = Vector3(1.0, 1.0, 0.45)
	arch.add_child(top)
	# Ivy clumps (green spheres draped on the arch)
	var ivy_mat: StandardMaterial3D = StandardMaterial3D.new()
	ivy_mat.albedo_color = Color(0.20, 0.50, 0.18)
	ivy_mat.emission_enabled = true
	ivy_mat.emission = Color(0.15, 0.40, 0.12)
	ivy_mat.emission_energy_multiplier = 0.20
	ivy_mat.roughness = 0.85
	for i in 14:
		var ivy: MeshInstance3D = MeshInstance3D.new()
		var im: SphereMesh = SphereMesh.new()
		im.radius = 0.22
		im.height = 0.40
		ivy.mesh = im
		ivy.material_override = ivy_mat
		# Random along the arch top + pillars
		var t: float = randf()
		var ang: float = lerp(PI, 0.0, t)
		var rx: float = cos(ang) * 1.40
		var ry: float = 3.20 + sin(ang) * 1.20
		ivy.position = Vector3(rx, ry, randf_range(-0.30, 0.30))
		ivy.scale = Vector3(1.0, 0.55, 0.85)
		arch.add_child(ivy)


func _build_d4_druid_circle(geom: Node) -> void:
	## Epic-4 T81: druid stone circle — 7 standing stones in a ring with
	## glowing green rune carvings, surrounding a central altar.
	var circle: Node3D = Node3D.new()
	circle.name = "DruidCircle"
	circle.position = Vector3(D4_CENTER.x + 4.0, 0.0, -14.0)
	geom.add_child(circle)
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.45, 0.42, 0.38)
	stone_mat.roughness = 0.95
	var rune_mat: StandardMaterial3D = StandardMaterial3D.new()
	rune_mat.albedo_color = Color(0.30, 0.85, 0.40)
	rune_mat.emission_enabled = true
	rune_mat.emission = Color(0.25, 0.95, 0.40)
	rune_mat.emission_energy_multiplier = 1.6
	rune_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	# 7 standing stones
	for i in 7:
		var ang: float = (TAU / 7.0) * i
		var radius: float = 4.0
		var stone: Node3D = Node3D.new()
		stone.position = Vector3(cos(ang) * radius, 0, sin(ang) * radius)
		stone.rotation.y = -ang + PI * 0.5
		circle.add_child(stone)
		# Standing stone — uneven height
		var pillar: MeshInstance3D = MeshInstance3D.new()
		var pm: BoxMesh = BoxMesh.new()
		pm.size = Vector3(0.65, 2.40 + (i % 3) * 0.30, 0.45)
		pillar.mesh = pm
		pillar.material_override = stone_mat
		pillar.position = Vector3(0, pm.size.y * 0.5, 0)
		stone.add_child(pillar)
		# Rune carving (small glowing rectangle)
		var rune: MeshInstance3D = MeshInstance3D.new()
		var rm: BoxMesh = BoxMesh.new()
		rm.size = Vector3(0.30, 0.50, 0.04)
		rune.mesh = rm
		rune.material_override = rune_mat
		rune.position = Vector3(0, 1.40, 0.25)
		stone.add_child(rune)
		# Pulse the rune
		var tw: Tween = rune.create_tween().set_loops()
		tw.tween_interval(i * 0.20)
		tw.tween_property(rune, "scale:y", 1.20, 1.0)
		tw.tween_property(rune, "scale:y", 0.85, 1.0)
		# Stone collision
		var sb: StaticBody3D = StaticBody3D.new()
		sb.position = Vector3(0, pm.size.y * 0.5, 0)
		var cs: CollisionShape3D = CollisionShape3D.new()
		var cb: BoxShape3D = BoxShape3D.new()
		cb.size = pm.size
		cs.shape = cb
		sb.add_child(cs)
		stone.add_child(sb)
	# Central altar
	var altar: MeshInstance3D = MeshInstance3D.new()
	var am: CylinderMesh = CylinderMesh.new()
	am.top_radius = 0.85
	am.bottom_radius = 1.00
	am.height = 0.65
	altar.mesh = am
	altar.material_override = stone_mat
	altar.position = Vector3(0, 0.32, 0)
	circle.add_child(altar)
	# Glowing crystal on top of altar
	var crystal: MeshInstance3D = MeshInstance3D.new()
	var cm: PrismMesh = PrismMesh.new()
	cm.size = Vector3(0.40, 0.85, 0.40)
	crystal.mesh = cm
	var crystal_mat: StandardMaterial3D = StandardMaterial3D.new()
	crystal_mat.albedo_color = Color(0.30, 0.95, 0.50)
	crystal_mat.emission_enabled = true
	crystal_mat.emission = Color(0.25, 0.95, 0.45)
	crystal_mat.emission_energy_multiplier = 2.5
	crystal_mat.metallic = 0.40
	crystal_mat.roughness = 0.10
	crystal.material_override = crystal_mat
	crystal.position = Vector3(0, 1.05, 0)
	circle.add_child(crystal)
	# Crystal hover + spin
	var ts: Tween = crystal.create_tween().set_loops()
	ts.tween_property(crystal, "rotation_degrees:y", 360.0, 6.0)
	ts.tween_property(crystal, "rotation_degrees:y", 0.0, 0.0)
	var th: Tween = crystal.create_tween().set_loops()
	th.tween_property(crystal, "position:y", 1.20, 1.4)
	th.tween_property(crystal, "position:y", 1.05, 1.4)
	# Central light
	var light: OmniLight3D = OmniLight3D.new()
	light.light_color = Color(0.40, 1.0, 0.55)
	light.light_energy = 2.5
	light.omni_range = 8.0
	light.position = Vector3(0, 1.20, 0)
	circle.add_child(light)
	# Altar collision
	var asb: StaticBody3D = StaticBody3D.new()
	asb.position = Vector3(0, 0.32, 0)
	var acs: CollisionShape3D = CollisionShape3D.new()
	var acap: CylinderShape3D = CylinderShape3D.new()
	acap.radius = 1.00
	acap.height = 0.65
	acs.shape = acap
	asb.add_child(acs)
	circle.add_child(asb)


func _build_d4_ancient_sundial(geom: Node) -> void:
	## Epic-4 T82: ancient stone sundial — round disc on a low pedestal
	## with a triangular gnomon casting a slow-rotating shadow blade.
	var sundial: Node3D = Node3D.new()
	sundial.name = "AncientSundial"
	sundial.position = Vector3(D4_CENTER.x - 4.0, 0.0, 4.0)
	geom.add_child(sundial)
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.65, 0.62, 0.55)
	stone_mat.roughness = 0.92
	# Pedestal base
	var base: MeshInstance3D = MeshInstance3D.new()
	var bm: BoxMesh = BoxMesh.new()
	bm.size = Vector3(1.00, 0.30, 1.00)
	base.mesh = bm
	base.material_override = stone_mat
	base.position = Vector3(0, 0.15, 0)
	sundial.add_child(base)
	# Pillar
	var pillar: MeshInstance3D = MeshInstance3D.new()
	var pm: CylinderMesh = CylinderMesh.new()
	pm.top_radius = 0.30
	pm.bottom_radius = 0.40
	pm.height = 0.85
	pillar.mesh = pm
	pillar.material_override = stone_mat
	pillar.position = Vector3(0, 0.72, 0)
	sundial.add_child(pillar)
	# Disc
	var disc: MeshInstance3D = MeshInstance3D.new()
	var dm: CylinderMesh = CylinderMesh.new()
	dm.top_radius = 0.85
	dm.bottom_radius = 0.85
	dm.height = 0.10
	disc.mesh = dm
	disc.material_override = stone_mat
	disc.position = Vector3(0, 1.20, 0)
	sundial.add_child(disc)
	# 12 hour notches around the disc edge
	var notch_mat: StandardMaterial3D = StandardMaterial3D.new()
	notch_mat.albedo_color = Color(0.30, 0.25, 0.20)
	notch_mat.emission_enabled = true
	notch_mat.emission = Color(0.85, 0.65, 0.20)
	notch_mat.emission_energy_multiplier = 0.40
	for i in 12:
		var ang: float = (TAU / 12.0) * i
		var notch: MeshInstance3D = MeshInstance3D.new()
		var nm: BoxMesh = BoxMesh.new()
		nm.size = Vector3(0.06, 0.04, 0.18)
		notch.mesh = nm
		notch.material_override = notch_mat
		notch.position = Vector3(cos(ang) * 0.70, 1.27, sin(ang) * 0.70)
		notch.rotation.y = -ang
		sundial.add_child(notch)
	# Gnomon — triangular blade rising from the center
	var gnomon: MeshInstance3D = MeshInstance3D.new()
	var gm: PrismMesh = PrismMesh.new()
	gm.size = Vector3(0.10, 0.65, 0.85)
	gnomon.mesh = gm
	var bronze_mat: StandardMaterial3D = StandardMaterial3D.new()
	bronze_mat.albedo_color = Color(0.65, 0.45, 0.20)
	bronze_mat.metallic = 0.70
	bronze_mat.roughness = 0.40
	gnomon.material_override = bronze_mat
	gnomon.position = Vector3(0, 1.55, 0)
	sundial.add_child(gnomon)
	# Slow rotation tween (simulates time passing)
	var tw: Tween = sundial.create_tween().set_loops()
	tw.tween_property(sundial, "rotation_degrees:y", 360.0, 60.0)
	tw.tween_property(sundial, "rotation_degrees:y", 0.0, 0.0)
	# Collision
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(1.00, 1.30, 1.00)
	cs.shape = cb
	cs.position = Vector3(0, 0.65, 0)
	sb.add_child(cs)
	sundial.add_child(sb)


func _build_d4_merchant_cart(geom: Node) -> void:
	## Epic-4 T83: traveling merchant cart — wooden wagon with cloth canopy
	## and barrels/crates of wares stacked behind.
	var cart: Node3D = Node3D.new()
	cart.name = "MerchantCart"
	cart.position = Vector3(D4_CENTER.x - 9.0, 0.0, -2.0)
	geom.add_child(cart)
	var wood_mat: StandardMaterial3D = StandardMaterial3D.new()
	wood_mat.albedo_color = Color(0.50, 0.32, 0.16)
	wood_mat.roughness = 0.85
	# Cart bed (large box)
	var bed: MeshInstance3D = MeshInstance3D.new()
	var bm: BoxMesh = BoxMesh.new()
	bm.size = Vector3(2.20, 0.30, 1.20)
	bed.mesh = bm
	bed.material_override = wood_mat
	bed.position = Vector3(0, 0.55, 0)
	cart.add_child(bed)
	# Side rails
	for sz in [-0.55, 0.55]:
		var rail: MeshInstance3D = MeshInstance3D.new()
		var rm: BoxMesh = BoxMesh.new()
		rm.size = Vector3(2.20, 0.45, 0.08)
		rail.mesh = rm
		rail.material_override = wood_mat
		rail.position = Vector3(0, 0.92, sz)
		cart.add_child(rail)
	# Wheels (2 large round)
	var wheel_mat: StandardMaterial3D = StandardMaterial3D.new()
	wheel_mat.albedo_color = Color(0.30, 0.20, 0.10)
	wheel_mat.roughness = 0.85
	for sx in [-0.85, 0.85]:
		for sz in [-0.70, 0.70]:
			var wheel: MeshInstance3D = MeshInstance3D.new()
			var wm: CylinderMesh = CylinderMesh.new()
			wm.top_radius = 0.45
			wm.bottom_radius = 0.45
			wm.height = 0.10
			wheel.mesh = wm
			wheel.material_override = wheel_mat
			wheel.position = Vector3(sx, 0.45, sz)
			wheel.rotation_degrees = Vector3(0, 0, 90)
			cart.add_child(wheel)
	# Cloth canopy (4 posts + sloped top box)
	for cx in [-0.95, 0.95]:
		for cz in [-0.50, 0.50]:
			var post: MeshInstance3D = MeshInstance3D.new()
			var pm: CylinderMesh = CylinderMesh.new()
			pm.top_radius = 0.04
			pm.bottom_radius = 0.04
			pm.height = 1.20
			post.mesh = pm
			post.material_override = wood_mat
			post.position = Vector3(cx, 1.40, cz)
			cart.add_child(post)
	var canopy: MeshInstance3D = MeshInstance3D.new()
	var cm: BoxMesh = BoxMesh.new()
	cm.size = Vector3(2.30, 0.10, 1.30)
	canopy.mesh = cm
	var cloth_mat: StandardMaterial3D = StandardMaterial3D.new()
	cloth_mat.albedo_color = Color(0.85, 0.20, 0.30)
	cloth_mat.roughness = 0.85
	canopy.material_override = cloth_mat
	canopy.position = Vector3(0, 2.05, 0)
	cart.add_child(canopy)
	# Wares — 2 barrels + 1 crate stacked
	var barrel_mat: StandardMaterial3D = StandardMaterial3D.new()
	barrel_mat.albedo_color = Color(0.45, 0.28, 0.12)
	barrel_mat.roughness = 0.85
	for bx in [-0.55, 0.55]:
		var barrel: MeshInstance3D = MeshInstance3D.new()
		var bbm: CylinderMesh = CylinderMesh.new()
		bbm.top_radius = 0.30
		bbm.bottom_radius = 0.30
		bbm.height = 0.80
		barrel.mesh = bbm
		barrel.material_override = barrel_mat
		barrel.position = Vector3(bx, 1.10, 0)
		cart.add_child(barrel)
	var crate: MeshInstance3D = MeshInstance3D.new()
	var crm: BoxMesh = BoxMesh.new()
	crm.size = Vector3(0.55, 0.55, 0.55)
	crate.mesh = crm
	crate.material_override = wood_mat
	crate.position = Vector3(0, 1.00, 0)
	cart.add_child(crate)
	# Cart collision
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(2.40, 1.85, 1.40)
	cs.shape = cb
	cs.position = Vector3(0, 1.00, 0)
	sb.add_child(cs)
	cart.add_child(sb)


func _build_d4_traveling_merchant_npc(town: Node) -> void:
	## Epic-4 T84: traveling merchant NPC standing beside the cart with
	## a long blue coat and a small purse.
	var npc_slots: Node3D = town.get_node_or_null("%NPCSlots") as Node3D
	if npc_slots == null:
		return
	var slot: Marker3D = Marker3D.new()
	slot.name = "TravelingMerchantSlot"
	slot.position = Vector3(D4_CENTER.x - 7.5, 0.0, -2.0)
	npc_slots.add_child(slot)
	var npc_scene: PackedScene = load("res://scenes/entities/npcs/VillagerR3.tscn") as PackedScene
	if npc_scene == null:
		return
	var npc: Node3D = npc_scene.instantiate() as Node3D
	npc.name = "TravelingMerchant"
	if "npc_name" in npc:
		npc.set("npc_name", "Roving Trader")
	if "npc_id" in npc:
		npc.set("npc_id", "trader_d4")
	slot.add_child(npc)
	# Blue coat (overlay box)
	var coat: MeshInstance3D = MeshInstance3D.new()
	var cm: BoxMesh = BoxMesh.new()
	cm.size = Vector3(0.60, 1.00, 0.40)
	coat.mesh = cm
	var coat_mat: StandardMaterial3D = StandardMaterial3D.new()
	coat_mat.albedo_color = Color(0.20, 0.30, 0.65)
	coat_mat.roughness = 0.80
	coat.material_override = coat_mat
	coat.position = Vector3(0, 0.55, 0)
	npc.add_child(coat)
	# Coin purse at hip
	var purse: MeshInstance3D = MeshInstance3D.new()
	var pm: SphereMesh = SphereMesh.new()
	pm.radius = 0.10
	pm.height = 0.18
	purse.mesh = pm
	var purse_mat: StandardMaterial3D = StandardMaterial3D.new()
	purse_mat.albedo_color = Color(0.50, 0.32, 0.16)
	purse_mat.roughness = 0.85
	purse.material_override = purse_mat
	purse.position = Vector3(0.30, 0.50, 0.10)
	npc.add_child(purse)
	# Tall pointed hat (cone via prism)
	var hat: MeshInstance3D = MeshInstance3D.new()
	var hm: PrismMesh = PrismMesh.new()
	hm.size = Vector3(0.40, 0.50, 0.40)
	hat.mesh = hm
	var hat_mat: StandardMaterial3D = StandardMaterial3D.new()
	hat_mat.albedo_color = Color(0.30, 0.20, 0.50)
	hat_mat.roughness = 0.80
	hat.material_override = hat_mat
	hat.position = Vector3(0, 1.55, 0)
	npc.add_child(hat)


func _build_d4_fireflies(geom: Node) -> void:
	## Epic-4 T85: yellow firefly particles drifting upward in a wide volume
	## around the central bloom area, giving warm magic atmosphere.
	var fireflies: GPUParticles3D = GPUParticles3D.new()
	fireflies.name = "Fireflies"
	fireflies.position = Vector3(D4_CENTER.x, 1.0, 0.0)
	fireflies.amount = 60
	fireflies.lifetime = 6.0
	fireflies.preprocess = 3.0
	fireflies.explosiveness = 0.0
	fireflies.randomness = 0.7
	fireflies.visibility_aabb = AABB(Vector3(-25, -2, -25), Vector3(50, 12, 50))
	var pm: ParticleProcessMaterial = ParticleProcessMaterial.new()
	pm.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	pm.emission_box_extents = Vector3(20, 0.5, 18)
	pm.direction = Vector3(0, 1, 0)
	pm.spread = 35.0
	pm.gravity = Vector3(0, 0.10, 0)
	pm.initial_velocity_min = 0.30
	pm.initial_velocity_max = 0.65
	pm.scale_min = 0.06
	pm.scale_max = 0.12
	pm.color = Color(1.0, 0.92, 0.45, 1.0)
	fireflies.process_material = pm
	# Firefly mesh — small bright sphere
	var firefly_mesh: SphereMesh = SphereMesh.new()
	firefly_mesh.radius = 0.05
	firefly_mesh.height = 0.10
	fireflies.draw_pass_1 = firefly_mesh
	var fmat: StandardMaterial3D = StandardMaterial3D.new()
	fmat.albedo_color = Color(1.0, 0.92, 0.45)
	fmat.emission_enabled = true
	fmat.emission = Color(1.0, 0.85, 0.35)
	fmat.emission_energy_multiplier = 2.5
	fmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	firefly_mesh.material = fmat
	geom.add_child(fireflies)


func _build_d4_pollen_veil(geom: Node) -> void:
	## Epic-4 T86: GPU pollen veil — slow-drifting golden specks at ankle
	## height across the central bloom area, contributing soft "magic dust"
	## haze without volumetrics.
	var veil: GPUParticles3D = GPUParticles3D.new()
	veil.name = "PollenVeil"
	veil.position = Vector3(D4_CENTER.x, 0.4, 0.0)
	veil.amount = 120
	veil.lifetime = 12.0
	veil.preprocess = 6.0
	veil.explosiveness = 0.0
	veil.randomness = 0.8
	veil.visibility_aabb = AABB(Vector3(-25, -1, -25), Vector3(50, 6, 50))
	var pm: ParticleProcessMaterial = ParticleProcessMaterial.new()
	pm.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	pm.emission_box_extents = Vector3(22, 0.3, 20)
	pm.direction = Vector3(0.2, 0.6, 0.1)
	pm.spread = 60.0
	pm.gravity = Vector3(0.05, 0.06, 0.02)
	pm.initial_velocity_min = 0.05
	pm.initial_velocity_max = 0.20
	pm.scale_min = 0.04
	pm.scale_max = 0.10
	pm.color = Color(0.95, 0.85, 0.45, 0.55)
	veil.process_material = pm
	var pollen_mesh: SphereMesh = SphereMesh.new()
	pollen_mesh.radius = 0.04
	pollen_mesh.height = 0.08
	veil.draw_pass_1 = pollen_mesh
	var pmat: StandardMaterial3D = StandardMaterial3D.new()
	pmat.albedo_color = Color(0.95, 0.85, 0.45, 0.65)
	pmat.emission_enabled = true
	pmat.emission = Color(0.95, 0.80, 0.30)
	pmat.emission_energy_multiplier = 1.4
	pmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	pmat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	pollen_mesh.material = pmat
	geom.add_child(veil)


func _build_d4_lantern_path(geom: Node) -> void:
	## Epic-4 T87: row of 8 wooden post lanterns along a winding path with
	## warm orange glow lights, each pulsing gently.
	var path: Node3D = Node3D.new()
	path.name = "LanternPath"
	path.position = Vector3(D4_CENTER.x - 18.0, 0.0, -3.0)
	geom.add_child(path)
	var post_mat: StandardMaterial3D = StandardMaterial3D.new()
	post_mat.albedo_color = Color(0.45, 0.30, 0.16)
	post_mat.roughness = 0.85
	var glass_mat: StandardMaterial3D = StandardMaterial3D.new()
	glass_mat.albedo_color = Color(1.0, 0.75, 0.30, 0.85)
	glass_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	glass_mat.emission_enabled = true
	glass_mat.emission = Color(1.0, 0.65, 0.20)
	glass_mat.emission_energy_multiplier = 2.0
	glass_mat.metallic = 0.30
	glass_mat.roughness = 0.10
	# 8 lanterns along a sinuous path
	for i in 8:
		var t: float = i / 7.0
		var lantern: Node3D = Node3D.new()
		var lx: float = i * 2.4
		var lz: float = sin(t * TAU) * 1.8
		lantern.position = Vector3(lx, 0, lz)
		path.add_child(lantern)
		# Wooden post
		var post: MeshInstance3D = MeshInstance3D.new()
		var pmm: CylinderMesh = CylinderMesh.new()
		pmm.top_radius = 0.06
		pmm.bottom_radius = 0.08
		pmm.height = 1.85
		post.mesh = pmm
		post.material_override = post_mat
		post.position = Vector3(0, 0.92, 0)
		lantern.add_child(post)
		# Lantern body (cube of glass)
		var lamp: MeshInstance3D = MeshInstance3D.new()
		var lmm: BoxMesh = BoxMesh.new()
		lmm.size = Vector3(0.30, 0.40, 0.30)
		lamp.mesh = lmm
		lamp.material_override = glass_mat
		lamp.position = Vector3(0, 2.05, 0)
		lantern.add_child(lamp)
		# Cap (small wooden box on top)
		var cap: MeshInstance3D = MeshInstance3D.new()
		var cmm: BoxMesh = BoxMesh.new()
		cmm.size = Vector3(0.40, 0.06, 0.40)
		cap.mesh = cmm
		cap.material_override = post_mat
		cap.position = Vector3(0, 2.30, 0)
		lantern.add_child(cap)
		# Light
		var light: OmniLight3D = OmniLight3D.new()
		light.light_color = Color(1.0, 0.65, 0.25)
		light.light_energy = 1.8
		light.omni_range = 4.5
		light.position = Vector3(0, 2.05, 0)
		lantern.add_child(light)
		# Pulse (offset per lantern for shimmer)
		var tw: Tween = light.create_tween().set_loops()
		tw.tween_interval(i * 0.18)
		tw.tween_property(light, "light_energy", 2.4, 1.0)
		tw.tween_property(light, "light_energy", 1.8, 1.0)
		# Post collision
		var sb: StaticBody3D = StaticBody3D.new()
		sb.position = Vector3(0, 0.92, 0)
		var cs: CollisionShape3D = CollisionShape3D.new()
		var cap_shape: CapsuleShape3D = CapsuleShape3D.new()
		cap_shape.radius = 0.10
		cap_shape.height = 1.85
		cs.shape = cap_shape
		sb.add_child(cs)
		lantern.add_child(sb)


func _build_d4_blossom_bridge(geom: Node) -> void:
	## Epic-4 T88: small ornamental bridge of vine planks framed by 2
	## blossom-clad vine arches.
	var bridge: Node3D = Node3D.new()
	bridge.name = "BlossomBridge"
	bridge.position = Vector3(D4_CENTER.x + 2.0, 0.0, -10.0)
	geom.add_child(bridge)
	var plank_mat: StandardMaterial3D = StandardMaterial3D.new()
	plank_mat.albedo_color = Color(0.35, 0.25, 0.12)
	plank_mat.roughness = 0.85
	# Bridge deck (5 planks)
	for i in 5:
		var plank: MeshInstance3D = MeshInstance3D.new()
		var pmm: BoxMesh = BoxMesh.new()
		pmm.size = Vector3(2.40, 0.10, 0.40)
		plank.mesh = pmm
		plank.material_override = plank_mat
		plank.position = Vector3(0, 0.30, -0.80 + i * 0.40)
		bridge.add_child(plank)
	# Side rails (curved cylinders)
	for sx in [-1.10, 1.10]:
		var rail: MeshInstance3D = MeshInstance3D.new()
		var rmm: CylinderMesh = CylinderMesh.new()
		rmm.top_radius = 0.05
		rmm.bottom_radius = 0.05
		rmm.height = 2.30
		rail.mesh = rmm
		var rmat: StandardMaterial3D = StandardMaterial3D.new()
		rmat.albedo_color = Color(0.55, 0.35, 0.15)
		rmat.roughness = 0.85
		rail.material_override = rmat
		rail.position = Vector3(sx, 0.55, 0)
		rail.rotation_degrees = Vector3(90, 0, 0)
		bridge.add_child(rail)
	# 2 blossom arches at the bridge ends
	var blossom_mat: StandardMaterial3D = StandardMaterial3D.new()
	blossom_mat.albedo_color = Color(0.95, 0.55, 0.75)
	blossom_mat.emission_enabled = true
	blossom_mat.emission = Color(0.95, 0.40, 0.65)
	blossom_mat.emission_energy_multiplier = 0.40
	blossom_mat.roughness = 0.65
	var vine_mat: StandardMaterial3D = StandardMaterial3D.new()
	vine_mat.albedo_color = Color(0.30, 0.55, 0.20)
	vine_mat.roughness = 0.85
	for sz in [-1.10, 1.10]:
		# Arch curve via torus
		var arch: MeshInstance3D = MeshInstance3D.new()
		var atm: TorusMesh = TorusMesh.new()
		atm.inner_radius = 1.10
		atm.outer_radius = 1.30
		arch.mesh = atm
		arch.material_override = vine_mat
		arch.position = Vector3(0, 1.50, sz)
		arch.rotation_degrees = Vector3(90, 90, 0)
		arch.scale = Vector3(1.0, 1.0, 0.40)
		bridge.add_child(arch)
		# 8 blossoms scattered along the arch
		for i in 8:
			var ang: float = lerp(0.0, PI, float(i) / 7.0)
			var blossom: MeshInstance3D = MeshInstance3D.new()
			var bmm: SphereMesh = SphereMesh.new()
			bmm.radius = 0.18
			bmm.height = 0.32
			blossom.mesh = bmm
			blossom.material_override = blossom_mat
			blossom.position = Vector3(cos(ang) * 1.20, 1.50 + sin(ang) * 1.20, sz)
			bridge.add_child(blossom)
	# Plank collision (horizontal slab)
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(2.40, 0.20, 2.20)
	cs.shape = cb
	cs.position = Vector3(0, 0.30, 0)
	sb.add_child(cs)
	bridge.add_child(sb)


func _build_d4_songbird_flock(geom: Node) -> void:
	## Epic-4 T89: 5 small songbirds flying in a slow circular pattern
	## around the great bloom area, each at a slightly different radius
	## and elevation, with wing-flap pulse.
	var flock: Node3D = Node3D.new()
	flock.name = "SongbirdFlock"
	flock.position = Vector3(D4_CENTER.x, 4.0, 0.0)
	geom.add_child(flock)
	var bird_colors: Array = [
		Color(0.95, 0.45, 0.20),
		Color(0.30, 0.65, 0.95),
		Color(0.95, 0.85, 0.30),
		Color(0.85, 0.30, 0.85),
		Color(0.30, 0.95, 0.50),
	]
	for i in 5:
		var bird_pivot: Node3D = Node3D.new()
		bird_pivot.position = Vector3(0, i * 0.30, 0)
		flock.add_child(bird_pivot)
		# Bird body (small sphere) offset on the pivot
		var bird: Node3D = Node3D.new()
		bird.position = Vector3(6.0 + i * 0.6, 0, 0)
		bird_pivot.add_child(bird)
		var body: MeshInstance3D = MeshInstance3D.new()
		var bm: SphereMesh = SphereMesh.new()
		bm.radius = 0.18
		bm.height = 0.30
		body.mesh = bm
		var body_mat: StandardMaterial3D = StandardMaterial3D.new()
		body_mat.albedo_color = bird_colors[i]
		body_mat.emission_enabled = true
		body_mat.emission = bird_colors[i]
		body_mat.emission_energy_multiplier = 0.30
		body_mat.roughness = 0.65
		body.material_override = body_mat
		body.scale = Vector3(1.0, 0.85, 1.20)
		bird.add_child(body)
		# 2 wings (thin boxes)
		var wing_mat: StandardMaterial3D = StandardMaterial3D.new()
		wing_mat.albedo_color = bird_colors[i].darkened(0.3)
		wing_mat.roughness = 0.65
		for sx in [-0.20, 0.20]:
			var wing: MeshInstance3D = MeshInstance3D.new()
			var wm: BoxMesh = BoxMesh.new()
			wm.size = Vector3(0.20, 0.04, 0.30)
			wing.mesh = wm
			wing.material_override = wing_mat
			wing.position = Vector3(sx, 0.05, 0)
			bird.add_child(wing)
			# Wing flap tween
			var tw: Tween = wing.create_tween().set_loops()
			tw.tween_property(wing, "rotation_degrees:z", 25.0 if sx < 0 else -25.0, 0.18)
			tw.tween_property(wing, "rotation_degrees:z", 0.0, 0.18)
		# Beak
		var beak: MeshInstance3D = MeshInstance3D.new()
		var bkm: PrismMesh = PrismMesh.new()
		bkm.size = Vector3(0.05, 0.05, 0.10)
		beak.mesh = bkm
		var beak_mat: StandardMaterial3D = StandardMaterial3D.new()
		beak_mat.albedo_color = Color(0.95, 0.65, 0.10)
		beak.material_override = beak_mat
		beak.position = Vector3(0, 0, 0.20)
		beak.rotation_degrees = Vector3(90, 0, 0)
		bird.add_child(beak)
		# Pivot rotation tween (each bird circles the bloom)
		var trot: Tween = bird_pivot.create_tween().set_loops()
		trot.tween_property(bird_pivot, "rotation_degrees:y", 360.0, 8.0 + i * 0.6)
		trot.tween_property(bird_pivot, "rotation_degrees:y", 0.0, 0.0)


func _build_d4_blossom_shrine(geom: Node) -> void:
	## Epic-4 T90: blossom heart shrine — small kneeling shrine with a
	## stone bowl, glowing pink heart-shaped offering, and 4 candle posts.
	var shrine: Node3D = Node3D.new()
	shrine.name = "BlossomShrine"
	shrine.position = Vector3(D4_CENTER.x - 4.0, 0.0, -4.0)
	geom.add_child(shrine)
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.65, 0.62, 0.55)
	stone_mat.roughness = 0.95
	# Stone base
	var base: MeshInstance3D = MeshInstance3D.new()
	var bm: BoxMesh = BoxMesh.new()
	bm.size = Vector3(1.40, 0.20, 1.40)
	base.mesh = bm
	base.material_override = stone_mat
	base.position = Vector3(0, 0.10, 0)
	shrine.add_child(base)
	# Stone bowl (low cylinder)
	var bowl: MeshInstance3D = MeshInstance3D.new()
	var bowm: CylinderMesh = CylinderMesh.new()
	bowm.top_radius = 0.55
	bowm.bottom_radius = 0.65
	bowm.height = 0.30
	bowl.mesh = bowm
	bowl.material_override = stone_mat
	bowl.position = Vector3(0, 0.35, 0)
	shrine.add_child(bowl)
	# Bowl interior (darker)
	var inner: MeshInstance3D = MeshInstance3D.new()
	var inm: CylinderMesh = CylinderMesh.new()
	inm.top_radius = 0.45
	inm.bottom_radius = 0.45
	inm.height = 0.05
	inner.mesh = inm
	var inner_mat: StandardMaterial3D = StandardMaterial3D.new()
	inner_mat.albedo_color = Color(0.20, 0.15, 0.12)
	inner_mat.roughness = 0.95
	inner.material_override = inner_mat
	inner.position = Vector3(0, 0.45, 0)
	shrine.add_child(inner)
	# Heart-shaped offering — 2 spheres + 1 prism
	var heart_mat: StandardMaterial3D = StandardMaterial3D.new()
	heart_mat.albedo_color = Color(0.95, 0.30, 0.55)
	heart_mat.emission_enabled = true
	heart_mat.emission = Color(0.95, 0.20, 0.50)
	heart_mat.emission_energy_multiplier = 1.8
	heart_mat.metallic = 0.30
	heart_mat.roughness = 0.20
	for sx in [-0.10, 0.10]:
		var lobe: MeshInstance3D = MeshInstance3D.new()
		var lm: SphereMesh = SphereMesh.new()
		lm.radius = 0.14
		lm.height = 0.24
		lobe.mesh = lm
		lobe.material_override = heart_mat
		lobe.position = Vector3(sx, 0.65, 0)
		shrine.add_child(lobe)
	var point: MeshInstance3D = MeshInstance3D.new()
	var pmm: PrismMesh = PrismMesh.new()
	pmm.size = Vector3(0.30, 0.20, 0.18)
	point.mesh = pmm
	point.material_override = heart_mat
	point.position = Vector3(0, 0.50, 0)
	point.rotation_degrees = Vector3(180, 0, 0)
	shrine.add_child(point)
	# Heart hover + pulse
	var th: Tween = point.create_tween().set_loops()
	th.tween_property(point, "position:y", 0.55, 1.4)
	th.tween_property(point, "position:y", 0.50, 1.4)
	# 4 candle posts at corners
	for cx in [-0.55, 0.55]:
		for cz in [-0.55, 0.55]:
			var post: MeshInstance3D = MeshInstance3D.new()
			var pm2: CylinderMesh = CylinderMesh.new()
			pm2.top_radius = 0.05
			pm2.bottom_radius = 0.05
			pm2.height = 0.45
			post.mesh = pm2
			var wax_mat: StandardMaterial3D = StandardMaterial3D.new()
			wax_mat.albedo_color = Color(0.95, 0.92, 0.85)
			wax_mat.roughness = 0.55
			post.material_override = wax_mat
			post.position = Vector3(cx, 0.42, cz)
			shrine.add_child(post)
			# Flame (small emissive sphere)
			var flame: MeshInstance3D = MeshInstance3D.new()
			var fm: SphereMesh = SphereMesh.new()
			fm.radius = 0.05
			fm.height = 0.10
			flame.mesh = fm
			var flame_mat: StandardMaterial3D = StandardMaterial3D.new()
			flame_mat.albedo_color = Color(1.0, 0.75, 0.20)
			flame_mat.emission_enabled = true
			flame_mat.emission = Color(1.0, 0.65, 0.20)
			flame_mat.emission_energy_multiplier = 2.5
			flame_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
			flame.material_override = flame_mat
			flame.position = Vector3(cx, 0.70, cz)
			shrine.add_child(flame)
			# Flame flicker
			var tf: Tween = flame.create_tween().set_loops()
			tf.tween_property(flame, "scale", Vector3(1.10, 1.20, 1.10), 0.20)
			tf.tween_property(flame, "scale", Vector3(0.90, 0.85, 0.90), 0.20)
	# Aura light
	var light: OmniLight3D = OmniLight3D.new()
	light.light_color = Color(1.0, 0.65, 0.85)
	light.light_energy = 1.6
	light.omni_range = 4.0
	light.position = Vector3(0, 0.85, 0)
	shrine.add_child(light)
	# Collision
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(1.40, 0.50, 1.40)
	cs.shape = cb
	cs.position = Vector3(0, 0.25, 0)
	sb.add_child(cs)
	shrine.add_child(sb)


func _build_d4_blossom_drake(geom: Node) -> void:
	## Epic-4 T91: small floating dragon spirit guarding the bloom — pink
	## body, butterfly wings, long tail, gentle hover circling pattern.
	var drake: Node3D = Node3D.new()
	drake.name = "BlossomDrake"
	drake.position = Vector3(D4_CENTER.x, 5.0, 0.0)
	geom.add_child(drake)
	# Pivot for circling
	var pivot: Node3D = Node3D.new()
	drake.add_child(pivot)
	var body_root: Node3D = Node3D.new()
	body_root.position = Vector3(7.0, 0, 0)
	pivot.add_child(body_root)
	# Body — pink elongated sphere
	var body_mat: StandardMaterial3D = StandardMaterial3D.new()
	body_mat.albedo_color = Color(0.95, 0.55, 0.75)
	body_mat.emission_enabled = true
	body_mat.emission = Color(0.95, 0.40, 0.65)
	body_mat.emission_energy_multiplier = 0.45
	body_mat.metallic = 0.20
	body_mat.roughness = 0.40
	var body: MeshInstance3D = MeshInstance3D.new()
	var bm: SphereMesh = SphereMesh.new()
	bm.radius = 0.32
	bm.height = 0.55
	body.mesh = bm
	body.material_override = body_mat
	body.scale = Vector3(1.0, 0.85, 1.55)
	body_root.add_child(body)
	# Head
	var head: MeshInstance3D = MeshInstance3D.new()
	var hm: SphereMesh = SphereMesh.new()
	hm.radius = 0.20
	hm.height = 0.34
	head.mesh = hm
	head.material_override = body_mat
	head.position = Vector3(0, 0.10, 0.55)
	body_root.add_child(head)
	# Eyes (cyan)
	var eye_mat: StandardMaterial3D = StandardMaterial3D.new()
	eye_mat.albedo_color = Color(0.30, 0.85, 0.95)
	eye_mat.emission_enabled = true
	eye_mat.emission = Color(0.30, 0.95, 1.0)
	eye_mat.emission_energy_multiplier = 1.6
	eye_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for ex in [-0.08, 0.08]:
		var eye: MeshInstance3D = MeshInstance3D.new()
		var em: SphereMesh = SphereMesh.new()
		em.radius = 0.04
		em.height = 0.08
		eye.mesh = em
		eye.material_override = eye_mat
		eye.position = Vector3(ex, 0.16, 0.71)
		body_root.add_child(eye)
	# 4 butterfly wings (large flat boxes)
	var wing_mat: StandardMaterial3D = StandardMaterial3D.new()
	wing_mat.albedo_color = Color(0.95, 0.65, 0.85, 0.85)
	wing_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	wing_mat.emission_enabled = true
	wing_mat.emission = Color(0.95, 0.40, 0.75)
	wing_mat.emission_energy_multiplier = 0.85
	for sx in [-1, 1]:
		for sz in [-1, 1]:
			var wing: MeshInstance3D = MeshInstance3D.new()
			var wm: BoxMesh = BoxMesh.new()
			wm.size = Vector3(0.50, 0.04, 0.35)
			wing.mesh = wm
			wing.material_override = wing_mat
			wing.position = Vector3(sx * 0.32, 0.18, sz * 0.10)
			body_root.add_child(wing)
			# Wing flap
			var twf: Tween = wing.create_tween().set_loops()
			twf.tween_property(wing, "rotation_degrees:z", 35.0 * sx, 0.18)
			twf.tween_property(wing, "rotation_degrees:z", -10.0 * sx, 0.18)
	# Tail (3 segments)
	for i in 3:
		var seg: MeshInstance3D = MeshInstance3D.new()
		var sm2: SphereMesh = SphereMesh.new()
		sm2.radius = 0.10 - i * 0.02
		sm2.height = 0.20 - i * 0.04
		seg.mesh = sm2
		seg.material_override = body_mat
		seg.position = Vector3(0, -0.05 + i * 0.04, -0.55 - i * 0.22)
		body_root.add_child(seg)
	# Pivot rotation tween
	var trot: Tween = pivot.create_tween().set_loops()
	trot.tween_property(pivot, "rotation_degrees:y", 360.0, 14.0)
	trot.tween_property(pivot, "rotation_degrees:y", 0.0, 0.0)
	# Body bob
	var tb: Tween = body_root.create_tween().set_loops()
	tb.tween_property(body_root, "position:y", 0.6, 1.6)
	tb.tween_property(body_root, "position:y", 0.0, 1.6)


func _build_d4_flower_clock(geom: Node) -> void:
	## Epic-4 T92: living flower clock — round flowerbed face with 12 petal
	## "hour markers" and a single rotating golden hour-hand petal.
	var clock: Node3D = Node3D.new()
	clock.name = "FlowerClock"
	clock.position = Vector3(D4_CENTER.x + 0.0, 0.0, 12.0)
	geom.add_child(clock)
	# Base disc (dirt + grass ring)
	var dirt_mat: StandardMaterial3D = StandardMaterial3D.new()
	dirt_mat.albedo_color = Color(0.30, 0.18, 0.10)
	dirt_mat.roughness = 0.95
	var disc: MeshInstance3D = MeshInstance3D.new()
	var dm: CylinderMesh = CylinderMesh.new()
	dm.top_radius = 2.20
	dm.bottom_radius = 2.20
	dm.height = 0.10
	disc.mesh = dm
	disc.material_override = dirt_mat
	disc.position = Vector3(0, 0.05, 0)
	clock.add_child(disc)
	# Grass ring border
	var grass_mat: StandardMaterial3D = StandardMaterial3D.new()
	grass_mat.albedo_color = Color(0.30, 0.65, 0.25)
	grass_mat.emission_enabled = true
	grass_mat.emission = Color(0.20, 0.55, 0.15)
	grass_mat.emission_energy_multiplier = 0.18
	grass_mat.roughness = 0.85
	var ring: MeshInstance3D = MeshInstance3D.new()
	var rm: TorusMesh = TorusMesh.new()
	rm.inner_radius = 2.10
	rm.outer_radius = 2.30
	ring.mesh = rm
	ring.material_override = grass_mat
	ring.position = Vector3(0, 0.10, 0)
	clock.add_child(ring)
	# 12 petal hour markers
	var petal_colors: Array = [
		Color(0.95, 0.30, 0.40),
		Color(0.95, 0.65, 0.30),
		Color(0.95, 0.85, 0.30),
		Color(0.30, 0.85, 0.40),
	]
	for i in 12:
		var ang: float = (TAU / 12.0) * i - PI * 0.5
		var petal: MeshInstance3D = MeshInstance3D.new()
		var pm: SphereMesh = SphereMesh.new()
		pm.radius = 0.18
		pm.height = 0.30
		petal.mesh = pm
		var pmat: StandardMaterial3D = StandardMaterial3D.new()
		pmat.albedo_color = petal_colors[i % petal_colors.size()]
		pmat.emission_enabled = true
		pmat.emission = petal_colors[i % petal_colors.size()]
		pmat.emission_energy_multiplier = 0.45
		pmat.roughness = 0.55
		petal.material_override = pmat
		petal.position = Vector3(cos(ang) * 1.80, 0.20, sin(ang) * 1.80)
		clock.add_child(petal)
	# Hour-hand petal (golden, larger)
	var hand: Node3D = Node3D.new()
	hand.position = Vector3(0, 0.25, 0)
	clock.add_child(hand)
	var hand_petal: MeshInstance3D = MeshInstance3D.new()
	var hpm: PrismMesh = PrismMesh.new()
	hpm.size = Vector3(0.35, 0.10, 1.50)
	hand_petal.mesh = hpm
	var hand_mat: StandardMaterial3D = StandardMaterial3D.new()
	hand_mat.albedo_color = Color(0.95, 0.85, 0.20)
	hand_mat.emission_enabled = true
	hand_mat.emission = Color(0.95, 0.75, 0.15)
	hand_mat.emission_energy_multiplier = 0.85
	hand_mat.metallic = 0.55
	hand_mat.roughness = 0.30
	hand_petal.material_override = hand_mat
	hand_petal.position = Vector3(0, 0.05, 0.75)
	hand.add_child(hand_petal)
	# Slow rotation tween (one full rotation per minute)
	var tw: Tween = hand.create_tween().set_loops()
	tw.tween_property(hand, "rotation_degrees:y", 360.0, 60.0)
	tw.tween_property(hand, "rotation_degrees:y", 0.0, 0.0)
	# Center sphere (axis)
	var center: MeshInstance3D = MeshInstance3D.new()
	var cm: SphereMesh = SphereMesh.new()
	cm.radius = 0.22
	cm.height = 0.40
	center.mesh = cm
	center.material_override = hand_mat
	center.position = Vector3(0, 0.30, 0)
	clock.add_child(center)


func _build_d4_lovers_bench(geom: Node) -> void:
	## Epic-4 T93: ornate stone bench under a small flowering arch — perfect
	## for the apprentice + courier scene later.
	var bench: Node3D = Node3D.new()
	bench.name = "LoversBench"
	bench.position = Vector3(D4_CENTER.x + 6.0, 0.0, -12.0)
	geom.add_child(bench)
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.70, 0.65, 0.55)
	stone_mat.roughness = 0.92
	# Bench seat
	var seat: MeshInstance3D = MeshInstance3D.new()
	var sm: BoxMesh = BoxMesh.new()
	sm.size = Vector3(2.20, 0.18, 0.55)
	seat.mesh = sm
	seat.material_override = stone_mat
	seat.position = Vector3(0, 0.55, 0)
	bench.add_child(seat)
	# 2 legs
	for sx in [-0.85, 0.85]:
		var leg: MeshInstance3D = MeshInstance3D.new()
		var lm: BoxMesh = BoxMesh.new()
		lm.size = Vector3(0.30, 0.55, 0.45)
		leg.mesh = lm
		leg.material_override = stone_mat
		leg.position = Vector3(sx, 0.27, 0)
		bench.add_child(leg)
	# Backrest with carved heart cutout (use a small heart of red emissive at center)
	var back: MeshInstance3D = MeshInstance3D.new()
	var bbm: BoxMesh = BoxMesh.new()
	bbm.size = Vector3(2.20, 0.85, 0.10)
	back.mesh = bbm
	back.material_override = stone_mat
	back.position = Vector3(0, 1.05, -0.25)
	bench.add_child(back)
	# Heart symbol (2 spheres + prism, glowing red)
	var heart_mat: StandardMaterial3D = StandardMaterial3D.new()
	heart_mat.albedo_color = Color(0.95, 0.30, 0.40)
	heart_mat.emission_enabled = true
	heart_mat.emission = Color(0.95, 0.20, 0.40)
	heart_mat.emission_energy_multiplier = 1.6
	for sx in [-0.10, 0.10]:
		var lobe: MeshInstance3D = MeshInstance3D.new()
		var lm2: SphereMesh = SphereMesh.new()
		lm2.radius = 0.10
		lm2.height = 0.18
		lobe.mesh = lm2
		lobe.material_override = heart_mat
		lobe.position = Vector3(sx, 1.18, -0.18)
		bench.add_child(lobe)
	var pt: MeshInstance3D = MeshInstance3D.new()
	var ptm: PrismMesh = PrismMesh.new()
	ptm.size = Vector3(0.20, 0.16, 0.10)
	pt.mesh = ptm
	pt.material_override = heart_mat
	pt.position = Vector3(0, 1.05, -0.18)
	pt.rotation_degrees = Vector3(180, 0, 0)
	bench.add_child(pt)
	# Small flowering arch behind bench (2 thin pillars + curved blossom top)
	var pillar_mat: StandardMaterial3D = StandardMaterial3D.new()
	pillar_mat.albedo_color = Color(0.60, 0.55, 0.45)
	pillar_mat.roughness = 0.90
	for sx in [-1.20, 1.20]:
		var pillar: MeshInstance3D = MeshInstance3D.new()
		var pm: CylinderMesh = CylinderMesh.new()
		pm.top_radius = 0.08
		pm.bottom_radius = 0.10
		pm.height = 2.20
		pillar.mesh = pm
		pillar.material_override = pillar_mat
		pillar.position = Vector3(sx, 1.10, -0.45)
		bench.add_child(pillar)
	var top: MeshInstance3D = MeshInstance3D.new()
	var tm: TorusMesh = TorusMesh.new()
	tm.inner_radius = 1.10
	tm.outer_radius = 1.30
	top.mesh = tm
	top.material_override = pillar_mat
	top.position = Vector3(0, 2.20, -0.45)
	top.rotation_degrees = Vector3(90, 0, 0)
	top.scale = Vector3(1.0, 1.0, 0.40)
	bench.add_child(top)
	# Pink blossoms on the arch
	var blossom_mat: StandardMaterial3D = StandardMaterial3D.new()
	blossom_mat.albedo_color = Color(0.95, 0.55, 0.75)
	blossom_mat.emission_enabled = true
	blossom_mat.emission = Color(0.95, 0.40, 0.65)
	blossom_mat.emission_energy_multiplier = 0.45
	for i in 9:
		var ang: float = lerp(PI, 0.0, float(i) / 8.0)
		var blossom: MeshInstance3D = MeshInstance3D.new()
		var bm2: SphereMesh = SphereMesh.new()
		bm2.radius = 0.14
		bm2.height = 0.24
		blossom.mesh = bm2
		blossom.material_override = blossom_mat
		blossom.position = Vector3(cos(ang) * 1.20, 2.20 + sin(ang) * 1.20, -0.45)
		bench.add_child(blossom)
	# Bench collision
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(2.40, 1.50, 0.55)
	cs.shape = cb
	cs.position = Vector3(0, 0.75, 0)
	sb.add_child(cs)
	bench.add_child(sb)


func _build_d4_apprentice_gardener_npc(town: Node) -> void:
	## Epic-4 T94: small apprentice gardener NPC with watering can.
	var npc_slots: Node3D = town.get_node_or_null("%NPCSlots") as Node3D
	if npc_slots == null:
		return
	var slot: Marker3D = Marker3D.new()
	slot.name = "ApprenticeGardenerSlot"
	slot.position = Vector3(D4_CENTER.x + 5.5, 0.0, -12.0)
	npc_slots.add_child(slot)
	var npc_scene: PackedScene = load("res://scenes/entities/npcs/VillagerR3.tscn") as PackedScene
	if npc_scene == null:
		return
	var npc: Node3D = npc_scene.instantiate() as Node3D
	npc.name = "ApprenticeGardener"
	if "npc_name" in npc:
		npc.set("npc_name", "Sapling")
	if "npc_id" in npc:
		npc.set("npc_id", "apprentice_d4")
	npc.scale = Vector3(0.80, 0.80, 0.80)
	slot.add_child(npc)
	# Watering can — body (cylinder) + spout (small cylinder)
	var can_mat: StandardMaterial3D = StandardMaterial3D.new()
	can_mat.albedo_color = Color(0.55, 0.60, 0.30)
	can_mat.metallic = 0.50
	can_mat.roughness = 0.45
	var body: MeshInstance3D = MeshInstance3D.new()
	var bm: CylinderMesh = CylinderMesh.new()
	bm.top_radius = 0.18
	bm.bottom_radius = 0.20
	bm.height = 0.34
	body.mesh = bm
	body.material_override = can_mat
	body.position = Vector3(0.45, 0.55, 0.10)
	slot.add_child(body)
	var spout: MeshInstance3D = MeshInstance3D.new()
	var sm: CylinderMesh = CylinderMesh.new()
	sm.top_radius = 0.04
	sm.bottom_radius = 0.06
	sm.height = 0.40
	spout.mesh = sm
	spout.material_override = can_mat
	spout.position = Vector3(0.70, 0.65, 0.10)
	spout.rotation_degrees = Vector3(0, 0, -50)
	slot.add_child(spout)
	# Sapling (small green plant on head — tiny stem + 3 leaves)
	var stem_mat: StandardMaterial3D = StandardMaterial3D.new()
	stem_mat.albedo_color = Color(0.30, 0.65, 0.25)
	stem_mat.roughness = 0.80
	var stem: MeshInstance3D = MeshInstance3D.new()
	var stm: CylinderMesh = CylinderMesh.new()
	stm.top_radius = 0.025
	stm.bottom_radius = 0.025
	stm.height = 0.20
	stem.mesh = stm
	stem.material_override = stem_mat
	stem.position = Vector3(0, 1.50, 0)
	slot.add_child(stem)
	for i in 3:
		var ang: float = (TAU / 3.0) * i
		var leaf: MeshInstance3D = MeshInstance3D.new()
		var lm: SphereMesh = SphereMesh.new()
		lm.radius = 0.08
		lm.height = 0.10
		leaf.mesh = lm
		leaf.material_override = stem_mat
		leaf.position = Vector3(cos(ang) * 0.10, 1.65, sin(ang) * 0.10)
		leaf.scale = Vector3(1.5, 0.4, 0.7)
		slot.add_child(leaf)


func _build_d4_sunflower_field(geom: Node) -> void:
	## Epic-4 T95: large sunflower field — 6×4 sunflowers with thick green
	## stems, large yellow petal heads, dark centers, and a slight sway.
	var field: Node3D = Node3D.new()
	field.name = "SunflowerField"
	field.position = Vector3(D4_CENTER.x - 12.0, 0.0, -16.0)
	geom.add_child(field)
	var stem_mat: StandardMaterial3D = StandardMaterial3D.new()
	stem_mat.albedo_color = Color(0.30, 0.55, 0.20)
	stem_mat.roughness = 0.85
	var petal_mat: StandardMaterial3D = StandardMaterial3D.new()
	petal_mat.albedo_color = Color(0.95, 0.85, 0.20)
	petal_mat.emission_enabled = true
	petal_mat.emission = Color(0.95, 0.75, 0.15)
	petal_mat.emission_energy_multiplier = 0.40
	petal_mat.roughness = 0.55
	var center_mat: StandardMaterial3D = StandardMaterial3D.new()
	center_mat.albedo_color = Color(0.30, 0.20, 0.10)
	center_mat.roughness = 0.85
	for r in 4:
		for c in 6:
			var stalk: Node3D = Node3D.new()
			stalk.position = Vector3(c * 1.40, 0, r * 1.40)
			field.add_child(stalk)
			# Stem
			var stem: MeshInstance3D = MeshInstance3D.new()
			var stm: CylinderMesh = CylinderMesh.new()
			stm.top_radius = 0.05
			stm.bottom_radius = 0.07
			stm.height = 1.95
			stem.mesh = stm
			stem.material_override = stem_mat
			stem.position = Vector3(0, 0.97, 0)
			stalk.add_child(stem)
			# 2 leaves on the stem
			for ly in [0.85, 1.30]:
				var leaf: MeshInstance3D = MeshInstance3D.new()
				var lm: SphereMesh = SphereMesh.new()
				lm.radius = 0.20
				lm.height = 0.14
				leaf.mesh = lm
				leaf.material_override = stem_mat
				leaf.position = Vector3(0.18, ly, 0)
				leaf.scale = Vector3(1.4, 0.35, 0.85)
				stalk.add_child(leaf)
			# Dark center disk
			var center: MeshInstance3D = MeshInstance3D.new()
			var cmm: CylinderMesh = CylinderMesh.new()
			cmm.top_radius = 0.22
			cmm.bottom_radius = 0.22
			cmm.height = 0.08
			center.mesh = cmm
			center.material_override = center_mat
			center.position = Vector3(0, 1.97, 0)
			center.rotation_degrees = Vector3(15, 0, 0)
			stalk.add_child(center)
			# 8 petals around center
			for i in 8:
				var ang: float = (TAU / 8.0) * i
				var petal: MeshInstance3D = MeshInstance3D.new()
				var pmm: PrismMesh = PrismMesh.new()
				pmm.size = Vector3(0.16, 0.06, 0.30)
				petal.mesh = pmm
				petal.material_override = petal_mat
				petal.position = Vector3(cos(ang) * 0.32, 1.97, sin(ang) * 0.32)
				petal.rotation = Vector3(0, ang + PI * 0.5, deg_to_rad(15))
				stalk.add_child(petal)
			# Slight sway tween
			var tw: Tween = stalk.create_tween().set_loops()
			tw.tween_property(stalk, "rotation_degrees:z", 3.0, 1.6 + randf() * 0.6)
			tw.tween_property(stalk, "rotation_degrees:z", -3.0, 1.6 + randf() * 0.6)
			# Stem collision
			var sb: StaticBody3D = StaticBody3D.new()
			sb.position = Vector3(0, 0.97, 0)
			var cs: CollisionShape3D = CollisionShape3D.new()
			var cap: CapsuleShape3D = CapsuleShape3D.new()
			cap.radius = 0.08
			cap.height = 1.95
			cs.shape = cap
			sb.add_child(cs)
			stalk.add_child(sb)


func _build_d4_welcome_banner(geom: Node) -> void:
	## Epic-4 T96: tall double-pole banner welcoming travelers to the
	## Bloom Cluster. Bright pink fabric with vine details.
	var banner: Node3D = Node3D.new()
	banner.name = "D4WelcomeBanner"
	banner.position = Vector3(D4_CENTER.x - 28.0, 0.0, 0.0)
	geom.add_child(banner)
	var pole_mat: StandardMaterial3D = StandardMaterial3D.new()
	pole_mat.albedo_color = Color(0.45, 0.30, 0.15)
	pole_mat.roughness = 0.85
	for sx in [-2.40, 2.40]:
		var pole: MeshInstance3D = MeshInstance3D.new()
		var pm: CylinderMesh = CylinderMesh.new()
		pm.top_radius = 0.10
		pm.bottom_radius = 0.14
		pm.height = 5.50
		pole.mesh = pm
		pole.material_override = pole_mat
		pole.position = Vector3(sx, 2.75, 0)
		banner.add_child(pole)
		# Pole collision
		var sb: StaticBody3D = StaticBody3D.new()
		sb.position = Vector3(sx, 2.75, 0)
		var cs: CollisionShape3D = CollisionShape3D.new()
		var cap: CapsuleShape3D = CapsuleShape3D.new()
		cap.radius = 0.16
		cap.height = 5.50
		cs.shape = cap
		sb.add_child(cs)
		banner.add_child(sb)
	# Top crossbar
	var bar: MeshInstance3D = MeshInstance3D.new()
	var bm: CylinderMesh = CylinderMesh.new()
	bm.top_radius = 0.08
	bm.bottom_radius = 0.08
	bm.height = 5.20
	bar.mesh = bm
	bar.material_override = pole_mat
	bar.position = Vector3(0, 5.20, 0)
	bar.rotation_degrees = Vector3(0, 0, 90)
	banner.add_child(bar)
	# Banner cloth (large pink box)
	var cloth: MeshInstance3D = MeshInstance3D.new()
	var cm: BoxMesh = BoxMesh.new()
	cm.size = Vector3(4.60, 2.80, 0.06)
	cloth.mesh = cm
	var cloth_mat: StandardMaterial3D = StandardMaterial3D.new()
	cloth_mat.albedo_color = Color(0.95, 0.55, 0.75)
	cloth_mat.emission_enabled = true
	cloth_mat.emission = Color(0.95, 0.40, 0.65)
	cloth_mat.emission_energy_multiplier = 0.45
	cloth_mat.roughness = 0.65
	cloth.material_override = cloth_mat
	cloth.position = Vector3(0, 3.50, 0)
	banner.add_child(cloth)
	# Banner text label
	var label: Label3D = Label3D.new()
	label.text = "BLOOM CLUSTER"
	label.modulate = Color(1.0, 1.0, 1.0)
	label.outline_modulate = Color(0.20, 0.10, 0.30)
	label.outline_size = 12
	label.font_size = 96
	label.pixel_size = 0.012
	label.billboard = BaseMaterial3D.BILLBOARD_DISABLED
	label.position = Vector3(0, 4.00, 0.05)
	banner.add_child(label)
	var subtitle: Label3D = Label3D.new()
	subtitle.text = "where the simulation still grows"
	subtitle.modulate = Color(0.95, 0.85, 0.95)
	subtitle.outline_modulate = Color(0.30, 0.10, 0.20)
	subtitle.outline_size = 8
	subtitle.font_size = 48
	subtitle.pixel_size = 0.010
	subtitle.position = Vector3(0, 3.10, 0.05)
	banner.add_child(subtitle)
	# 4 vine clusters draping from the bar
	var vine_mat: StandardMaterial3D = StandardMaterial3D.new()
	vine_mat.albedo_color = Color(0.30, 0.60, 0.20)
	vine_mat.emission_enabled = true
	vine_mat.emission = Color(0.20, 0.50, 0.15)
	vine_mat.emission_energy_multiplier = 0.30
	for sx in [-2.0, -0.7, 0.7, 2.0]:
		var vine: MeshInstance3D = MeshInstance3D.new()
		var vm: CylinderMesh = CylinderMesh.new()
		vm.top_radius = 0.04
		vm.bottom_radius = 0.02
		vm.height = 1.60
		vine.mesh = vm
		vine.material_override = vine_mat
		vine.position = Vector3(sx, 4.40, 0.10)
		banner.add_child(vine)


func _build_d4_grand_altar(geom: Node) -> void:
	## Epic-4 T97: grand bloom altar at the heart of the cluster — large
	## tiered stone platform with a giant glowing pink crystal flower
	## bud at the top, supporting beams of light, and orbiting petals.
	var altar: Node3D = Node3D.new()
	altar.name = "GrandBloomAltar"
	altar.position = Vector3(D4_CENTER.x, 0.0, -2.0)
	geom.add_child(altar)
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.65, 0.62, 0.55)
	stone_mat.roughness = 0.92
	# 3-tier base
	var sizes: Array = [
		Vector3(5.00, 0.40, 5.00),
		Vector3(3.80, 0.40, 3.80),
		Vector3(2.60, 0.40, 2.60),
	]
	for i in sizes.size():
		var tier: MeshInstance3D = MeshInstance3D.new()
		var tm: BoxMesh = BoxMesh.new()
		tm.size = sizes[i]
		tier.mesh = tm
		tier.material_override = stone_mat
		tier.position = Vector3(0, 0.20 + i * 0.40, 0)
		altar.add_child(tier)
	# Pedestal column
	var col: MeshInstance3D = MeshInstance3D.new()
	var clm: CylinderMesh = CylinderMesh.new()
	clm.top_radius = 0.85
	clm.bottom_radius = 1.00
	clm.height = 1.40
	col.mesh = clm
	col.material_override = stone_mat
	col.position = Vector3(0, 1.90, 0)
	altar.add_child(col)
	# Giant crystal bud (sphere + 6 petal prisms around it)
	var bud_mat: StandardMaterial3D = StandardMaterial3D.new()
	bud_mat.albedo_color = Color(0.95, 0.45, 0.75)
	bud_mat.emission_enabled = true
	bud_mat.emission = Color(0.95, 0.30, 0.65)
	bud_mat.emission_energy_multiplier = 2.5
	bud_mat.metallic = 0.40
	bud_mat.roughness = 0.15
	var bud: MeshInstance3D = MeshInstance3D.new()
	var bm: SphereMesh = SphereMesh.new()
	bm.radius = 0.85
	bm.height = 1.50
	bud.mesh = bm
	bud.material_override = bud_mat
	bud.position = Vector3(0, 3.40, 0)
	altar.add_child(bud)
	for i in 6:
		var ang: float = (TAU / 6.0) * i
		var petal: MeshInstance3D = MeshInstance3D.new()
		var pmm: PrismMesh = PrismMesh.new()
		pmm.size = Vector3(0.55, 0.30, 1.20)
		petal.mesh = pmm
		petal.material_override = bud_mat
		petal.position = Vector3(cos(ang) * 1.10, 3.40, sin(ang) * 1.10)
		petal.rotation = Vector3(0, ang + PI * 0.5, 0)
		altar.add_child(petal)
	# Beam of light pillar (tall thin emissive cylinder rising from bud)
	var beam: MeshInstance3D = MeshInstance3D.new()
	var beam_m: CylinderMesh = CylinderMesh.new()
	beam_m.top_radius = 0.18
	beam_m.bottom_radius = 0.55
	beam_m.height = 12.0
	beam.mesh = beam_m
	var beam_mat: StandardMaterial3D = StandardMaterial3D.new()
	beam_mat.albedo_color = Color(0.95, 0.65, 0.85, 0.55)
	beam_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	beam_mat.emission_enabled = true
	beam_mat.emission = Color(0.95, 0.45, 0.75)
	beam_mat.emission_energy_multiplier = 1.4
	beam_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	beam.material_override = beam_mat
	beam.position = Vector3(0, 9.40, 0)
	altar.add_child(beam)
	# Pulse the beam
	var tw: Tween = beam.create_tween().set_loops()
	tw.tween_property(beam, "scale:x", 1.20, 1.6)
	tw.tween_property(beam, "scale:x", 0.85, 1.6)
	# 4 orbiting petals
	for i in 4:
		var pivot: Node3D = Node3D.new()
		pivot.position = Vector3(0, 3.40, 0)
		pivot.rotation_degrees = Vector3(0, 90.0 * i, 0)
		altar.add_child(pivot)
		var orbiter: MeshInstance3D = MeshInstance3D.new()
		var om: SphereMesh = SphereMesh.new()
		om.radius = 0.20
		om.height = 0.36
		orbiter.mesh = om
		orbiter.material_override = bud_mat
		orbiter.position = Vector3(2.20, 0, 0)
		pivot.add_child(orbiter)
		var trot: Tween = pivot.create_tween().set_loops()
		trot.tween_property(pivot, "rotation_degrees:y", 90.0 * i + 360.0, 6.0 + i * 0.4)
		trot.tween_property(pivot, "rotation_degrees:y", 90.0 * i, 0.0)
	# Massive central light
	var light: OmniLight3D = OmniLight3D.new()
	light.light_color = Color(1.0, 0.65, 0.85)
	light.light_energy = 4.0
	light.omni_range = 18.0
	light.position = Vector3(0, 3.40, 0)
	altar.add_child(light)
	# Altar collision (3 tiers)
	for i in sizes.size():
		var sb: StaticBody3D = StaticBody3D.new()
		sb.position = Vector3(0, 0.20 + i * 0.40, 0)
		var cs: CollisionShape3D = CollisionShape3D.new()
		var cb: BoxShape3D = BoxShape3D.new()
		cb.size = sizes[i]
		cs.shape = cb
		sb.add_child(cs)
		altar.add_child(sb)


func _build_d4_district_plaque(geom: Node) -> void:
	## Epic-4 T98: dedication plaque mounted on a small stone pedestal at
	## the entrance to the Bloom Cluster.
	var plaque: Node3D = Node3D.new()
	plaque.name = "D4Plaque"
	plaque.position = Vector3(D4_CENTER.x - 24.0, 0.0, 4.0)
	geom.add_child(plaque)
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.65, 0.62, 0.55)
	stone_mat.roughness = 0.92
	# Pedestal
	var ped: MeshInstance3D = MeshInstance3D.new()
	var pm: BoxMesh = BoxMesh.new()
	pm.size = Vector3(0.85, 1.20, 0.55)
	ped.mesh = pm
	ped.material_override = stone_mat
	ped.position = Vector3(0, 0.60, 0)
	plaque.add_child(ped)
	# Plaque face (bronze)
	var face: MeshInstance3D = MeshInstance3D.new()
	var fm: BoxMesh = BoxMesh.new()
	fm.size = Vector3(0.75, 0.50, 0.06)
	face.mesh = fm
	var bronze_mat: StandardMaterial3D = StandardMaterial3D.new()
	bronze_mat.albedo_color = Color(0.65, 0.45, 0.20)
	bronze_mat.metallic = 0.75
	bronze_mat.roughness = 0.30
	face.material_override = bronze_mat
	face.position = Vector3(0, 1.00, 0.30)
	face.rotation_degrees = Vector3(-15, 0, 0)
	plaque.add_child(face)
	var label: Label3D = Label3D.new()
	label.text = "BLOOM CLUSTER\nDistrict 04 — Iteration 04\nWhere code remembers how to grow"
	label.modulate = Color(0.10, 0.05, 0.10)
	label.outline_modulate = Color(0.95, 0.85, 0.55)
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


func _build_d4_ambient_tweak(geom: Node) -> void:
	## Epic-4 T99: gentle warm ambient tint over the Bloom Cluster — soft
	## pink directional glow + low ambient OmniLight at center for warmth.
	var amb: Node3D = Node3D.new()
	amb.name = "D4Ambient"
	amb.position = Vector3(D4_CENTER.x, 6.0, 0.0)
	geom.add_child(amb)
	# Wide-range warm fill
	var fill: OmniLight3D = OmniLight3D.new()
	fill.light_color = Color(1.0, 0.80, 0.85)
	fill.light_energy = 0.65
	fill.omni_range = 32.0
	amb.add_child(fill)
	# Slow color shift to feel "alive"
	var tw: Tween = fill.create_tween().set_loops()
	tw.tween_property(fill, "light_color", Color(0.95, 0.85, 0.95), 6.0)
	tw.tween_property(fill, "light_color", Color(1.0, 0.80, 0.85), 6.0)
	# Soft secondary directional from above
	var sun: DirectionalLight3D = DirectionalLight3D.new()
	sun.light_color = Color(1.0, 0.85, 0.95)
	sun.light_energy = 0.30
	sun.shadow_enabled = false
	sun.position = Vector3(0, 14.0, 0)
	sun.rotation_degrees = Vector3(-65, 35, 0)
	amb.add_child(sun)


func _build_d4_bloom_elder(geom: Node) -> void:
	## Epic-4 T100: BLOOM ELDER — the district guardian / Epic 4 finale.
	## Towering tree-spirit with a massive flowering crown, multiple eyes,
	## floating petal halo, and an aura of ancient power. The
	## emotional payoff for completing the Bloom Cluster.
	var elder: Node3D = Node3D.new()
	elder.name = "BloomElder"
	elder.position = Vector3(D4_CENTER.x + 22.0, 0.0, -16.0)
	geom.add_child(elder)
	# Trunk — wide tapered stone-bark cylinder
	var bark_mat: StandardMaterial3D = StandardMaterial3D.new()
	bark_mat.albedo_color = Color(0.30, 0.22, 0.15)
	bark_mat.emission_enabled = true
	bark_mat.emission = Color(0.55, 0.30, 0.45)
	bark_mat.emission_energy_multiplier = 0.30
	bark_mat.roughness = 0.85
	var trunk: MeshInstance3D = MeshInstance3D.new()
	var trm: CylinderMesh = CylinderMesh.new()
	trm.top_radius = 0.85
	trm.bottom_radius = 1.65
	trm.height = 6.50
	trunk.mesh = trm
	trunk.material_override = bark_mat
	trunk.position = Vector3(0, 3.25, 0)
	elder.add_child(trunk)
	# 4 root buttresses
	for i in 4:
		var ang: float = (TAU / 4.0) * i + PI * 0.25
		var root: MeshInstance3D = MeshInstance3D.new()
		var rm: PrismMesh = PrismMesh.new()
		rm.size = Vector3(0.65, 1.40, 1.50)
		root.mesh = rm
		root.material_override = bark_mat
		root.position = Vector3(cos(ang) * 1.20, 0.70, sin(ang) * 1.20)
		root.rotation = Vector3(0, ang + PI * 0.5, 0)
		elder.add_child(root)
	# Massive flowering crown (5 large overlapping spheres)
	var crown_mat: StandardMaterial3D = StandardMaterial3D.new()
	crown_mat.albedo_color = Color(0.95, 0.55, 0.75)
	crown_mat.emission_enabled = true
	crown_mat.emission = Color(0.95, 0.40, 0.65)
	crown_mat.emission_energy_multiplier = 0.85
	crown_mat.roughness = 0.55
	for i in 5:
		var ang: float = (TAU / 5.0) * i
		var lobe: MeshInstance3D = MeshInstance3D.new()
		var lm: SphereMesh = SphereMesh.new()
		lm.radius = 1.85
		lm.height = 3.20
		lobe.mesh = lm
		lobe.material_override = crown_mat
		lobe.position = Vector3(cos(ang) * 1.20, 7.20, sin(ang) * 1.20)
		elder.add_child(lobe)
	# Topmost giant flower bud (hero piece)
	var top_bud: MeshInstance3D = MeshInstance3D.new()
	var tbm: SphereMesh = SphereMesh.new()
	tbm.radius = 1.40
	tbm.height = 2.40
	top_bud.mesh = tbm
	var bud_mat: StandardMaterial3D = StandardMaterial3D.new()
	bud_mat.albedo_color = Color(0.95, 0.30, 0.65)
	bud_mat.emission_enabled = true
	bud_mat.emission = Color(0.95, 0.20, 0.55)
	bud_mat.emission_energy_multiplier = 2.5
	bud_mat.metallic = 0.30
	bud_mat.roughness = 0.20
	top_bud.material_override = bud_mat
	top_bud.position = Vector3(0, 9.30, 0)
	elder.add_child(top_bud)
	# Central trunk face — 3 large glowing eyes
	var eye_mat: StandardMaterial3D = StandardMaterial3D.new()
	eye_mat.albedo_color = Color(0.30, 0.95, 0.55)
	eye_mat.emission_enabled = true
	eye_mat.emission = Color(0.30, 1.0, 0.50)
	eye_mat.emission_energy_multiplier = 3.5
	eye_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for i in 3:
		var eye: MeshInstance3D = MeshInstance3D.new()
		var em: SphereMesh = SphereMesh.new()
		em.radius = 0.20
		em.height = 0.36
		eye.mesh = em
		eye.material_override = eye_mat
		var ang: float = (TAU / 3.0) * i + PI * 0.5
		eye.position = Vector3(cos(ang) * 0.45, 4.20 + sin(ang) * 0.45, 1.10)
		elder.add_child(eye)
		# Pulse eye
		var tw: Tween = eye.create_tween().set_loops()
		tw.tween_interval(i * 0.30)
		tw.tween_property(eye, "scale", Vector3.ONE * 1.20, 0.85)
		tw.tween_property(eye, "scale", Vector3.ONE * 0.85, 0.85)
	# Floating petal halo — 12 petals orbiting at head height
	var halo_pivot: Node3D = Node3D.new()
	halo_pivot.position = Vector3(0, 7.20, 0)
	elder.add_child(halo_pivot)
	for i in 12:
		var ang: float = (TAU / 12.0) * i
		var petal: MeshInstance3D = MeshInstance3D.new()
		var pmm: PrismMesh = PrismMesh.new()
		pmm.size = Vector3(0.30, 0.10, 0.55)
		petal.mesh = pmm
		petal.material_override = crown_mat
		petal.position = Vector3(cos(ang) * 3.20, 0, sin(ang) * 3.20)
		petal.rotation = Vector3(0, ang + PI * 0.5, 0)
		halo_pivot.add_child(petal)
	# Slow halo rotation
	var thalo: Tween = halo_pivot.create_tween().set_loops()
	thalo.tween_property(halo_pivot, "rotation_degrees:y", 360.0, 16.0)
	thalo.tween_property(halo_pivot, "rotation_degrees:y", 0.0, 0.0)
	# Massive central aura light
	var light: OmniLight3D = OmniLight3D.new()
	light.light_color = Color(1.0, 0.55, 0.85)
	light.light_energy = 4.5
	light.omni_range = 22.0
	light.position = Vector3(0, 7.20, 0)
	elder.add_child(light)
	# Aura pulse
	var tlight: Tween = light.create_tween().set_loops()
	tlight.tween_property(light, "light_energy", 6.0, 2.4)
	tlight.tween_property(light, "light_energy", 4.5, 2.4)
	# Title label above the elder (lore moment)
	var label: Label3D = Label3D.new()
	label.text = "THE BLOOM ELDER"
	label.modulate = Color(1.0, 0.85, 0.95)
	label.outline_modulate = Color(0.30, 0.05, 0.20)
	label.outline_size = 14
	label.font_size = 84
	label.pixel_size = 0.014
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.position = Vector3(0, 11.30, 0)
	elder.add_child(label)
	var subtitle: Label3D = Label3D.new()
	subtitle.text = "Guardian of the last living root"
	subtitle.modulate = Color(0.85, 0.95, 0.75)
	subtitle.outline_modulate = Color(0.10, 0.20, 0.05)
	subtitle.outline_size = 8
	subtitle.font_size = 42
	subtitle.pixel_size = 0.011
	subtitle.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	subtitle.position = Vector3(0, 10.50, 0)
	elder.add_child(subtitle)
	# Trunk collision (capsule)
	var sb: StaticBody3D = StaticBody3D.new()
	sb.position = Vector3(0, 3.25, 0)
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cap: CapsuleShape3D = CapsuleShape3D.new()
	cap.radius = 1.65
	cap.height = 6.50
	cs.shape = cap
	sb.add_child(cs)
	elder.add_child(sb)
