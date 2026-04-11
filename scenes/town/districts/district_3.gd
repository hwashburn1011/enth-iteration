class_name D3Builder
extends Node
## Memory Vault district builder — extracted from scenes/town/town.gd to keep
## the main town script modular and under control.

const D3_CENTER := Vector3(150, 0, 0)


func extend_boundary(geom: Node) -> void:
	## Push the east boundary wall from x=120 out to x=180.
	var east_wall: CSGBox3D = geom.get_node_or_null("BoundaryEast") as CSGBox3D
	if east_wall:
		east_wall.position.x = 180.0


func build(town: Node, geom: Node) -> void:
	## Entry point — called from town.gd::_build_district_3(geom).
	print("[D3Builder] start")
	extend_boundary(geom)
	_build_d3_ground(geom)
	_build_d3_entrance_arch(geom)
	_build_d3_great_crystal(geom)
	_build_d3_awakened_guardian(geom)
	_build_d3_lost_coder_npc(town)
	_build_d3_ancient_pillars(geom)
	_build_d3_sigil_glyphs(geom)
	_build_d3_reading_chamber(geom)
	_build_d3_memory_shards(geom)
	_build_d3_archivist_npc(town)
	_build_d3_codex_pages(geom)
	_build_d3_spiral_stair(geom)
	_build_d3_wisp_enemy(geom)
	_build_d3_vault_keeper_npc(town)
	_build_d3_memory_pool(geom)
	_build_d3_floating_bookshelves(geom)
	_build_d3_stone_benches(geom)
	_build_d3_ritual_circle(geom)
	_build_d3_war_banners(geom)
	_build_d3_acolyte_npc(town)
	_build_d3_mana_font(geom)
	_build_d3_mausoleum(geom)
	_build_d3_crystal_lanterns(geom)
	_build_d3_sage_npc(town)
	_build_d3_echo_wraith(geom)
	_build_d3_rune_decals(geom)
	_build_d3_sealed_gates(geom)
	_build_d3_data_spirits(geom)
	_build_d3_oracle_npc(town)
	_build_d3_violet_mist(geom)
	_build_d3_floating_arches(geom)
	_build_d3_battle_scars(geom)
	_build_d3_memory_obelisks(geom)
	_build_d3_phantom_warrior_npc(town)
	_build_d3_illusion_bridge(geom)
	_build_d3_levitating_runes(geom)
	_build_d3_observatory_dome(geom)
	_build_d3_portal_pad(geom)
	_build_d3_ritualist_npc(town)
	_build_d3_violet_braziers(geom)
	_build_d3_spell_puzzle(geom)
	_build_d3_floating_stair(geom)
	_build_d3_chained_statue(geom)
	_build_d3_librarian_npc(town)
	_build_d3_elemental_wisps(geom)
	_build_d3_sky_portal(geom)
	_build_d3_judgment_dais(geom)
	_build_d3_echo_singer_npc(town)
	_build_d3_mana_crystals(geom)
	_build_d3_memory_echo(geom)
	_build_d3_ancient_pool(geom)
	_build_d3_pendulum(geom)
	_build_d3_prophecy_stones(geom)
	_build_d3_apprentice_npc(town)
	_build_d3_page_rain(geom)
	_build_d3_alchemy_table(geom)
	_build_d3_sundial(geom)
	_build_d3_library_facade(geom)
	_build_d3_starlight_projector(geom)
	_build_d3_data_dragon(geom)
	_build_d3_healing_fountain(geom)
	_build_d3_study_desks(geom)
	_build_d3_mage_robes(geom)
	_build_d3_fortune_teller_npc(town)
	_build_d3_tarot_cards(geom)
	_build_d3_sky_chimes(geom)
	_build_d3_spirit_altars(geom)
	_build_d3_floating_crown(geom)
	_build_d3_grimoire_stack(geom)
	_build_d3_monk_npc(town)
	_build_d3_conjurer_npc(town)
	_build_d3_map_wall(geom)
	_build_d3_dust_orbs(geom)
	_build_d3_altar_circle(geom)
	_build_d3_mind_crystals(geom)
	_build_d3_ascending_stairs(geom)
	_build_d3_grand_telescope(geom)
	_build_d3_prayer_chains(geom)
	_build_d3_dreamcatcher(geom)
	_build_d3_starseer_npc(town)
	_build_d3_spell_scrolls(geom)
	_build_d3_cleric_npc(town)
	_build_d3_ancient_gargoyles(geom)
	_build_d3_lone_bell(geom)
	_build_d3_dream_eater(geom)
	_build_d3_lectern(geom)
	_build_d3_reflecting_pool(geom)
	_build_d3_staff_cluster(geom)
	_build_d3_elder_mage_npc(town)
	_build_d3_perimeter_braziers(geom)
	_build_d3_astrolabe(geom)
	_build_d3_ingredient_shelves(geom)
	_build_d3_planet_model(geom)
	_build_d3_time_keeper_npc(town)
	_build_d3_seeker_trial(geom)
	_build_d3_welcome_banner(geom)
	_build_d3_atmosphere_fog(geom)
	_build_d3_epic3_plaque(geom)
	_build_d3_ambient_fills(geom)
	_build_d3_arcane_overseer_landmark(geom)
	print("[D3Builder] done")


func _build_d3_ground(geom: Node) -> void:
	## Epic-3 T1b: D3 ground — violet/purple grid floor extending from
	## x=120 to x=180. Uses a tweaked variant of the digital grid shader
	## with violet primary color on a deep black base.
	var plane: PlaneMesh = PlaneMesh.new()
	plane.size = Vector2(60, 40)
	var ground: MeshInstance3D = MeshInstance3D.new()
	ground.name = "D3Ground"
	ground.mesh = plane
	ground.position = Vector3(150, 0, 0)
	# Violet variant of the grid shader
	var shader: Shader = Shader.new()
	shader.code = """
shader_type spatial;
render_mode unshaded;
uniform vec3 base_color = vec3(0.04, 0.02, 0.08);
uniform vec3 grid_color = vec3(0.85, 0.40, 1.00);
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


func _build_d3_entrance_arch(geom: Node) -> void:
	## Epic-3 T2: a tall ornate violet stone arch at the D3 entrance
	## (just east of D2 boundary at x=120) reading "MEMORY VAULT".
	var arch: Node3D = Node3D.new()
	arch.name = "D3EntranceArch"
	arch.position = Vector3(122, 0, 0)
	geom.add_child(arch)
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.10, 0.06, 0.18)
	stone_mat.metallic = 0.55
	stone_mat.roughness = 0.45
	stone_mat.emission_enabled = true
	stone_mat.emission = Color(0.85, 0.40, 1.0)
	stone_mat.emission_energy_multiplier = 0.40
	# 2 wide pillars
	for sx: float in [-4.5, 4.5]:
		var pillar: MeshInstance3D = MeshInstance3D.new()
		var pmesh: BoxMesh = BoxMesh.new()
		pmesh.size = Vector3(1.85, 8.5, 1.85)
		pillar.mesh = pmesh
		pillar.position = Vector3(sx, 4.25, 0)
		pillar.material_override = stone_mat
		arch.add_child(pillar)
		# Glowing violet rune stripe
		var stripe: MeshInstance3D = MeshInstance3D.new()
		var smesh: BoxMesh = BoxMesh.new()
		smesh.size = Vector3(0.06, 6.5, 1.95)
		stripe.mesh = smesh
		stripe.position = Vector3(sx + (-0.96 if sx < 0 else 0.96), 4.0, 0)
		var stripe_mat: StandardMaterial3D = StandardMaterial3D.new()
		stripe_mat.albedo_color = Color(0.85, 0.40, 1.0)
		stripe_mat.emission_enabled = true
		stripe_mat.emission = Color(1.0, 0.55, 1.0)
		stripe_mat.emission_energy_multiplier = 1.8
		stripe_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		stripe.material_override = stripe_mat
		arch.add_child(stripe)
		# Collision per pillar
		var sb: StaticBody3D = StaticBody3D.new()
		var cs: CollisionShape3D = CollisionShape3D.new()
		var cb: BoxShape3D = BoxShape3D.new()
		cb.size = Vector3(1.85, 8.5, 1.85)
		cs.shape = cb
		cs.position = Vector3(sx, 4.25, 0)
		sb.add_child(cs)
		arch.add_child(sb)
	# Arched lintel — wide flat box
	var lintel: MeshInstance3D = MeshInstance3D.new()
	var lmesh: BoxMesh = BoxMesh.new()
	lmesh.size = Vector3(11.0, 1.85, 1.95)
	lintel.mesh = lmesh
	lintel.position = Vector3(0, 9.40, 0)
	lintel.material_override = stone_mat
	arch.add_child(lintel)
	# Crowning peak — small prism on top of lintel
	var peak: MeshInstance3D = MeshInstance3D.new()
	var prmesh: PrismMesh = PrismMesh.new()
	prmesh.size = Vector3(2.40, 1.40, 1.95)
	peak.mesh = prmesh
	peak.position = Vector3(0, 11.0, 0)
	peak.material_override = stone_mat
	arch.add_child(peak)
	# Glowing eye gem in the peak
	var gem: MeshInstance3D = MeshInstance3D.new()
	var gm: SphereMesh = SphereMesh.new()
	gm.radius = 0.30
	gm.height = 0.60
	gem.mesh = gm
	gem.position = Vector3(0, 11.20, 0)
	var gmat: StandardMaterial3D = StandardMaterial3D.new()
	gmat.albedo_color = Color(0.85, 0.40, 1.0)
	gmat.emission_enabled = true
	gmat.emission = Color(1.0, 0.55, 1.0)
	gmat.emission_energy_multiplier = 3.0
	gmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	gem.material_override = gmat
	arch.add_child(gem)
	# Pulse the gem
	var pulse: Tween = create_tween().set_loops()
	pulse.tween_property(gem, "scale", Vector3(1.30, 1.30, 1.30), 1.6).set_ease(Tween.EASE_IN_OUT)
	pulse.tween_property(gem, "scale", Vector3(0.95, 0.95, 0.95), 1.6).set_ease(Tween.EASE_IN_OUT)
	# Big district name on the lintel both sides
	for fz: float in [-0.99, 0.99]:
		var label: Label3D = Label3D.new()
		label.text = "MEMORY VAULT"
		label.position = Vector3(0, 9.40, fz)
		label.rotation = Vector3(0, deg_to_rad(0 if fz > 0 else 180), 0)
		label.modulate = Color(0.85, 0.55, 1.0)
		label.outline_modulate = Color(0, 0, 0, 0.85)
		label.outline_size = 6
		label.font_size = 26
		label.no_depth_test = true
		arch.add_child(label)


func _build_d3_great_crystal(geom: Node) -> void:
	## Epic-3 T3: a giant 8m-tall data crystal at the D3 center, the
	## district's main landmark. Translucent violet prism floating just
	## above a stepped platform with a slow vertical bob and rotation.
	var crystal: Node3D = Node3D.new()
	crystal.name = "D3GreatCrystal"
	crystal.position = D3_CENTER
	geom.add_child(crystal)
	# Stepped stone platform
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.10, 0.06, 0.18)
	stone_mat.metallic = 0.55
	stone_mat.roughness = 0.45
	for i in 3:
		var step: MeshInstance3D = MeshInstance3D.new()
		var sm: BoxMesh = BoxMesh.new()
		sm.size = Vector3(4.0 - i * 0.55, 0.30, 4.0 - i * 0.55)
		step.mesh = sm
		step.position = Vector3(0, 0.15 + i * 0.30, 0)
		step.material_override = stone_mat
		crystal.add_child(step)
	# Crystal pivot above the platform (where bob + rotation happen)
	var pivot: Node3D = Node3D.new()
	pivot.position = Vector3(0, 5.0, 0)
	crystal.add_child(pivot)
	# Main crystal — large prism
	var crystal_mat: StandardMaterial3D = StandardMaterial3D.new()
	crystal_mat.albedo_color = Color(0.85, 0.40, 1.0, 0.55)
	crystal_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	crystal_mat.emission_enabled = true
	crystal_mat.emission = Color(1.0, 0.55, 1.0)
	crystal_mat.emission_energy_multiplier = 2.4
	crystal_mat.metallic = 0.30
	crystal_mat.roughness = 0.10
	crystal_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var prism: MeshInstance3D = MeshInstance3D.new()
	var pmesh: PrismMesh = PrismMesh.new()
	pmesh.size = Vector3(2.40, 5.0, 2.40)
	prism.mesh = pmesh
	prism.position = Vector3(0, 0, 0)
	prism.material_override = crystal_mat
	pivot.add_child(prism)
	# Inverted crystal underneath (pointing down)
	var lower: MeshInstance3D = MeshInstance3D.new()
	var lmesh: PrismMesh = PrismMesh.new()
	lmesh.size = Vector3(2.40, 2.40, 2.40)
	lower.mesh = lmesh
	lower.position = Vector3(0, -3.40, 0)
	lower.rotation = Vector3(deg_to_rad(180), 0, 0)
	lower.material_override = crystal_mat
	pivot.add_child(lower)
	# Slow rotation
	var spin: Tween = create_tween().set_loops()
	spin.tween_property(pivot, "rotation:y", TAU, 14.0)
	# Bob in place
	var bob: Tween = create_tween().set_loops()
	bob.tween_property(pivot, "position:y", 5.55, 2.4).set_ease(Tween.EASE_IN_OUT)
	bob.tween_property(pivot, "position:y", 5.0, 2.4).set_ease(Tween.EASE_IN_OUT)
	# 4 small orbital satellite crystals around the main one
	for i in 4:
		var angle: float = (float(i) / 4.0) * TAU
		var sat: MeshInstance3D = MeshInstance3D.new()
		var sm: PrismMesh = PrismMesh.new()
		sm.size = Vector3(0.55, 1.20, 0.55)
		sat.mesh = sm
		sat.position = Vector3(cos(angle) * 2.40, randf_range(-0.5, 0.5), sin(angle) * 2.40)
		sat.material_override = crystal_mat
		pivot.add_child(sat)
	# Real OmniLight inside the crystal
	var crystal_light: OmniLight3D = OmniLight3D.new()
	crystal_light.position = Vector3(0, 0, 0)
	crystal_light.light_color = Color(1.0, 0.55, 1.0)
	crystal_light.light_energy = 3.5
	crystal_light.omni_range = 22.0
	pivot.add_child(crystal_light)
	# Halo on the platform
	var halo: MeshInstance3D = MeshInstance3D.new()
	var hmesh: TorusMesh = TorusMesh.new()
	hmesh.inner_radius = 2.40
	hmesh.outer_radius = 2.85
	halo.mesh = hmesh
	halo.position = Vector3(0, 1.05, 0)
	var hmat: StandardMaterial3D = StandardMaterial3D.new()
	hmat.albedo_color = Color(0.85, 0.40, 1.0)
	hmat.emission_enabled = true
	hmat.emission = Color(1.0, 0.55, 1.0)
	hmat.emission_energy_multiplier = 2.0
	hmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	halo.material_override = hmat
	crystal.add_child(halo)
	# Sign
	var label: Label3D = Label3D.new()
	label.text = "GREAT CRYSTAL"
	label.position = Vector3(0, 11.0, 0)
	label.modulate = Color(1.0, 0.55, 1.0)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 6
	label.font_size = 22
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	crystal.add_child(label)
	# Collision around the platform
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(4.0, 1.40, 4.0)
	cs.shape = cb
	cs.position = Vector3(0, 0.70, 0)
	sb.add_child(cs)
	crystal.add_child(sb)


func _build_d3_awakened_guardian(geom: Node) -> void:
	## Epic-3 T4: an awakened guardian mini-boss — a stone humanoid statue
	## that has come to life. Tall thin body, glowing violet runes
	## carved into chest, deep amethyst eyes, slow patrol around the
	## crystal platform.
	var guardian: Node3D = Node3D.new()
	guardian.name = "D3AwakenedGuardian"
	guardian.position = D3_CENTER + Vector3(8, 0, 6)
	geom.add_child(guardian)
	# Body — tall stone box
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.20, 0.16, 0.26)
	stone_mat.metallic = 0.40
	stone_mat.roughness = 0.55
	var torso: MeshInstance3D = MeshInstance3D.new()
	var tm: BoxMesh = BoxMesh.new()
	tm.size = Vector3(1.40, 2.40, 0.85)
	torso.mesh = tm
	torso.position = Vector3(0, 1.90, 0)
	torso.material_override = stone_mat
	guardian.add_child(torso)
	# Head — narrower box
	var head: MeshInstance3D = MeshInstance3D.new()
	var hm: BoxMesh = BoxMesh.new()
	hm.size = Vector3(0.85, 0.85, 0.85)
	head.mesh = hm
	head.position = Vector3(0, 3.55, 0)
	head.material_override = stone_mat
	guardian.add_child(head)
	# 2 deep amethyst eyes
	var eye_mat: StandardMaterial3D = StandardMaterial3D.new()
	eye_mat.albedo_color = Color(0.85, 0.40, 1.0)
	eye_mat.emission_enabled = true
	eye_mat.emission = Color(1.0, 0.55, 1.0)
	eye_mat.emission_energy_multiplier = 3.0
	eye_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for ex: float in [-0.18, 0.18]:
		var eye: MeshInstance3D = MeshInstance3D.new()
		var em: SphereMesh = SphereMesh.new()
		em.radius = 0.10
		em.height = 0.20
		eye.mesh = em
		eye.position = Vector3(ex, 3.60, 0.45)
		eye.material_override = eye_mat
		guardian.add_child(eye)
	# 4 violet rune squares carved into chest
	var rune_mat: StandardMaterial3D = StandardMaterial3D.new()
	rune_mat.albedo_color = Color(0.85, 0.40, 1.0)
	rune_mat.emission_enabled = true
	rune_mat.emission = Color(1.0, 0.55, 1.0)
	rune_mat.emission_energy_multiplier = 2.4
	rune_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for i in 4:
		var rune: MeshInstance3D = MeshInstance3D.new()
		var rm: BoxMesh = BoxMesh.new()
		rm.size = Vector3(0.20, 0.20, 0.04)
		rune.mesh = rm
		@warning_ignore("integer_division")
		var row: int = i / 2
		rune.position = Vector3(-0.40 + (i % 2) * 0.55, 1.60 + row * 0.55, 0.45)
		rune.material_override = rune_mat
		guardian.add_child(rune)
		# Rune flicker
		var flicker: Tween = create_tween().set_loops()
		flicker.tween_interval(1.0 + i * 0.3)
		flicker.tween_property(rune, "visible", false, 0.0)
		flicker.tween_interval(0.10)
		flicker.tween_property(rune, "visible", true, 0.0)
	# 2 thick legs
	for sx: float in [-0.40, 0.40]:
		var leg: MeshInstance3D = MeshInstance3D.new()
		var lm: BoxMesh = BoxMesh.new()
		lm.size = Vector3(0.40, 0.85, 0.40)
		leg.mesh = lm
		leg.position = Vector3(sx, 0.42, 0)
		leg.material_override = stone_mat
		guardian.add_child(leg)
	# Stone sword in front
	var sword: MeshInstance3D = MeshInstance3D.new()
	var sm: BoxMesh = BoxMesh.new()
	sm.size = Vector3(0.20, 2.40, 0.06)
	sword.mesh = sm
	sword.position = Vector3(0.85, 1.40, 0.45)
	sword.material_override = stone_mat
	guardian.add_child(sword)
	# Patrol path circling the crystal
	var origin: Vector3 = D3_CENTER + Vector3(8, 0, 6)
	var patrol: Tween = create_tween().set_loops()
	patrol.tween_property(guardian, "rotation:y", deg_to_rad(90), 0.5)
	patrol.tween_property(guardian, "position", D3_CENTER + Vector3(8, 0, -6), 8.0)
	patrol.tween_property(guardian, "rotation:y", deg_to_rad(180), 0.5)
	patrol.tween_property(guardian, "position", D3_CENTER + Vector3(-8, 0, -6), 8.0)
	patrol.tween_property(guardian, "rotation:y", deg_to_rad(270), 0.5)
	patrol.tween_property(guardian, "position", D3_CENTER + Vector3(-8, 0, 6), 8.0)
	patrol.tween_property(guardian, "rotation:y", 0.0, 0.5)
	patrol.tween_property(guardian, "position", origin, 8.0)
	# Boss-tier name billboard
	var label: Label3D = Label3D.new()
	label.text = "AWAKENED GUARDIAN"
	label.position = Vector3(0, 4.65, 0)
	label.modulate = Color(1.0, 0.55, 1.0)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 6
	label.font_size = 22
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	guardian.add_child(label)


func _build_d3_lost_coder_npc(town: Node) -> void:
	## Epic-3 T5: Lost Coder NPC — a wandering ancient programmer ghost
	## with a translucent body and a glowing keyboard floating in front
	## of them. The first inhabitant of the Memory Vault.
	var slots: Node3D = town.get_node_or_null("%NPCSlots") as Node3D
	if slots == null:
		return
	var coder: Node3D = Node3D.new()
	coder.name = "D3LostCoder"
	coder.position = D3_CENTER + Vector3(-12, 0, 4)
	slots.add_child(coder)
	# Translucent ghostly body
	var bmat: StandardMaterial3D = StandardMaterial3D.new()
	bmat.albedo_color = Color(0.85, 0.55, 1.0, 0.55)
	bmat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	bmat.emission_enabled = true
	bmat.emission = Color(0.85, 0.40, 1.0)
	bmat.emission_energy_multiplier = 1.4
	bmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var body: MeshInstance3D = MeshInstance3D.new()
	var bmesh: CapsuleMesh = CapsuleMesh.new()
	bmesh.radius = 0.42
	bmesh.height = 1.20
	body.mesh = bmesh
	body.position = Vector3(0, 0.65, 0)
	body.material_override = bmat
	coder.add_child(body)
	# Head sphere
	var head: MeshInstance3D = MeshInstance3D.new()
	var hm: SphereMesh = SphereMesh.new()
	hm.radius = 0.36
	hm.height = 0.72
	head.mesh = hm
	head.position = Vector3(0, 1.55, 0)
	head.material_override = bmat
	coder.add_child(head)
	# 2 white glowing eyes
	var eye_mat: StandardMaterial3D = StandardMaterial3D.new()
	eye_mat.albedo_color = Color(1, 1, 1)
	eye_mat.emission_enabled = true
	eye_mat.emission = Color(1, 1, 1)
	eye_mat.emission_energy_multiplier = 2.6
	eye_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for ex: float in [-0.10, 0.10]:
		var eye: MeshInstance3D = MeshInstance3D.new()
		var em: SphereMesh = SphereMesh.new()
		em.radius = 0.06
		em.height = 0.12
		eye.mesh = em
		eye.position = Vector3(ex, 1.55, 0.32)
		eye.material_override = eye_mat
		coder.add_child(eye)
	# Floating glowing keyboard in front
	var kb: MeshInstance3D = MeshInstance3D.new()
	var kbm: BoxMesh = BoxMesh.new()
	kbm.size = Vector3(0.85, 0.10, 0.30)
	kb.mesh = kbm
	kb.position = Vector3(0, 1.0, 0.55)
	var kbmat: StandardMaterial3D = StandardMaterial3D.new()
	kbmat.albedo_color = Color(0.04, 0.10, 0.16)
	kbmat.metallic = 0.65
	kbmat.emission_enabled = true
	kbmat.emission = Color(0.40, 1.0, 0.55)
	kbmat.emission_energy_multiplier = 1.4
	kb.material_override = kbmat
	coder.add_child(kb)
	# 9 small "key" emissive boxes on the keyboard (3x3 grid)
	for r in 3:
		for c in 3:
			var key: MeshInstance3D = MeshInstance3D.new()
			var km: BoxMesh = BoxMesh.new()
			km.size = Vector3(0.10, 0.04, 0.06)
			key.mesh = km
			key.position = Vector3(-0.30 + c * 0.30, 1.07, 0.45 + r * 0.10)
			var kmat: StandardMaterial3D = StandardMaterial3D.new()
			kmat.albedo_color = Color(0.55, 1.0, 0.55)
			kmat.emission_enabled = true
			kmat.emission = Color(0.55, 1.0, 0.55)
			kmat.emission_energy_multiplier = 2.2
			kmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
			key.material_override = kmat
			coder.add_child(key)
	# Pulse the body to feel ghostly
	var pulse: Tween = create_tween().set_loops()
	pulse.tween_property(bmat, "emission_energy_multiplier", 2.4, 1.6).set_ease(Tween.EASE_IN_OUT)
	pulse.tween_property(bmat, "emission_energy_multiplier", 0.85, 1.6).set_ease(Tween.EASE_IN_OUT)
	# Slow drift patrol
	var origin: Vector3 = D3_CENTER + Vector3(-12, 0, 4)
	var drift: Tween = create_tween().set_loops()
	drift.tween_property(coder, "position", origin + Vector3(0, 0, -8), 6.0).set_ease(Tween.EASE_IN_OUT)
	drift.tween_property(coder, "position", origin, 6.0).set_ease(Tween.EASE_IN_OUT)
	# Name billboard
	var label: Label3D = Label3D.new()
	label.text = "Lost Coder"
	label.position = Vector3(0, 2.10, 0)
	label.modulate = Color(0.85, 0.55, 1.0)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 18
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	coder.add_child(label)


func _build_d3_ancient_pillars(geom: Node) -> void:
	## Epic-3 T6: a cluster of 6 ancient violet stone pillars at varying
	## heights forming a half-circle around the great crystal — like
	## sentinels guarding the heart of the vault.
	var cluster: Node3D = Node3D.new()
	cluster.name = "D3AncientPillars"
	cluster.position = D3_CENTER + Vector3(0, 0, -10)
	geom.add_child(cluster)
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.10, 0.06, 0.18)
	stone_mat.metallic = 0.55
	stone_mat.roughness = 0.45
	stone_mat.emission_enabled = true
	stone_mat.emission = Color(0.85, 0.40, 1.0)
	stone_mat.emission_energy_multiplier = 0.30
	for i in 6:
		var t: float = float(i) / 5.0
		var angle: float = (-PI * 0.5) + t * PI
		var radius: float = 8.0
		var height: float = 4.0 + (i % 3) * 1.0
		var pillar: MeshInstance3D = MeshInstance3D.new()
		var pmesh: BoxMesh = BoxMesh.new()
		pmesh.size = Vector3(0.85, height, 0.85)
		pillar.mesh = pmesh
		pillar.position = Vector3(cos(angle) * radius, height * 0.5, sin(angle) * radius)
		pillar.material_override = stone_mat
		cluster.add_child(pillar)
		# Top crown — small pulsing emissive sphere
		var crown: MeshInstance3D = MeshInstance3D.new()
		var cm: SphereMesh = SphereMesh.new()
		cm.radius = 0.20
		cm.height = 0.40
		crown.mesh = cm
		crown.position = Vector3(cos(angle) * radius, height + 0.20, sin(angle) * radius)
		var cmat: StandardMaterial3D = StandardMaterial3D.new()
		cmat.albedo_color = Color(0.85, 0.40, 1.0)
		cmat.emission_enabled = true
		cmat.emission = Color(1.0, 0.55, 1.0)
		cmat.emission_energy_multiplier = 2.4
		cmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		crown.material_override = cmat
		cluster.add_child(crown)
		# Pulse the crown
		var pulse: Tween = create_tween().set_loops()
		pulse.tween_property(crown, "scale", Vector3(1.30, 1.30, 1.30), 1.4 + i * 0.2).set_ease(Tween.EASE_IN_OUT)
		pulse.tween_property(crown, "scale", Vector3(0.85, 0.85, 0.85), 1.4 + i * 0.2).set_ease(Tween.EASE_IN_OUT)
		# Collision per pillar
		var sb: StaticBody3D = StaticBody3D.new()
		var cs: CollisionShape3D = CollisionShape3D.new()
		var cb: BoxShape3D = BoxShape3D.new()
		cb.size = Vector3(0.85, height, 0.85)
		cs.shape = cb
		cs.position = Vector3(cos(angle) * radius, height * 0.5, sin(angle) * radius)
		sb.add_child(cs)
		cluster.add_child(sb)


func _build_d3_sigil_glyphs(geom: Node) -> void:
	## Epic-3 T7: 8 floating violet sigil glyphs drifting through the air
	## near the crystal. Each is a different ancient symbol Label3D
	## floating + slowly rotating + bobbing.
	var symbols: Array[String] = ["Δ", "Φ", "Ψ", "Ω", "Σ", "Λ", "Θ", "Ξ"]
	for i in symbols.size():
		var glyph: Node3D = Node3D.new()
		glyph.name = "D3SigilGlyph_%d" % i
		var t: float = float(i) / symbols.size()
		var angle: float = t * TAU
		glyph.position = D3_CENTER + Vector3(cos(angle) * 6.0, 3.0 + (i % 3) * 0.85, sin(angle) * 6.0)
		geom.add_child(glyph)
		# Backing card (translucent)
		var card: MeshInstance3D = MeshInstance3D.new()
		var cmesh: BoxMesh = BoxMesh.new()
		cmesh.size = Vector3(0.65, 0.65, 0.04)
		card.mesh = cmesh
		var cmat: StandardMaterial3D = StandardMaterial3D.new()
		cmat.albedo_color = Color(0.85, 0.40, 1.0, 0.30)
		cmat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		cmat.emission_enabled = true
		cmat.emission = Color(1.0, 0.55, 1.0)
		cmat.emission_energy_multiplier = 1.0
		cmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		card.material_override = cmat
		glyph.add_child(card)
		# Symbol label
		var label: Label3D = Label3D.new()
		label.text = symbols[i]
		label.position = Vector3(0, 0, 0.05)
		label.modulate = Color(1, 1, 1)
		label.outline_modulate = Color(0, 0, 0, 0.85)
		label.outline_size = 5
		label.font_size = 28
		label.no_depth_test = true
		label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		glyph.add_child(label)
		# Rotation tween
		var spin: Tween = create_tween().set_loops()
		spin.tween_property(glyph, "rotation:y", TAU, 6.0 + i * 0.5)
		# Bob tween
		var bob: Tween = create_tween().set_loops()
		var origin_y: float = glyph.position.y
		bob.tween_property(glyph, "position:y", origin_y + 0.55, 1.6 + i * 0.2).set_ease(Tween.EASE_IN_OUT)
		bob.tween_property(glyph, "position:y", origin_y, 1.6 + i * 0.2).set_ease(Tween.EASE_IN_OUT)


func _build_d3_reading_chamber(geom: Node) -> void:
	## Epic-3 T8: a small alcove reading chamber — 3-sided stone walls
	## containing a podium with a glowing tome and a stool. The "scholar's
	## corner" of the vault.
	var chamber: Node3D = Node3D.new()
	chamber.name = "D3ReadingChamber"
	chamber.position = D3_CENTER + Vector3(-15, 0, -8)
	geom.add_child(chamber)
	var wall_mat: StandardMaterial3D = StandardMaterial3D.new()
	wall_mat.albedo_color = Color(0.14, 0.10, 0.22)
	wall_mat.metallic = 0.40
	wall_mat.roughness = 0.55
	wall_mat.emission_enabled = true
	wall_mat.emission = Color(0.55, 0.30, 0.85)
	wall_mat.emission_energy_multiplier = 0.30
	# Back wall
	var back: MeshInstance3D = MeshInstance3D.new()
	var bm: BoxMesh = BoxMesh.new()
	bm.size = Vector3(3.40, 3.40, 0.30)
	back.mesh = bm
	back.position = Vector3(0, 1.70, -1.40)
	back.material_override = wall_mat
	chamber.add_child(back)
	# Side walls
	for sx: float in [-1.55, 1.55]:
		var side: MeshInstance3D = MeshInstance3D.new()
		var sm: BoxMesh = BoxMesh.new()
		sm.size = Vector3(0.30, 3.40, 2.80)
		side.mesh = sm
		side.position = Vector3(sx, 1.70, 0)
		side.material_override = wall_mat
		chamber.add_child(side)
	# Podium in the center
	var podium_mat: StandardMaterial3D = StandardMaterial3D.new()
	podium_mat.albedo_color = Color(0.20, 0.16, 0.26)
	podium_mat.metallic = 0.55
	var podium: MeshInstance3D = MeshInstance3D.new()
	var pm: BoxMesh = BoxMesh.new()
	pm.size = Vector3(0.85, 1.20, 0.55)
	podium.mesh = pm
	podium.position = Vector3(0, 0.60, -0.55)
	podium.material_override = podium_mat
	chamber.add_child(podium)
	# Glowing tome on the podium
	var tome: MeshInstance3D = MeshInstance3D.new()
	var tm: BoxMesh = BoxMesh.new()
	tm.size = Vector3(0.55, 0.10, 0.40)
	tome.mesh = tm
	tome.position = Vector3(0, 1.30, -0.55)
	tome.rotation = Vector3(deg_to_rad(-20), 0, 0)
	var tmat: StandardMaterial3D = StandardMaterial3D.new()
	tmat.albedo_color = Color(0.85, 0.40, 1.0)
	tmat.emission_enabled = true
	tmat.emission = Color(1.0, 0.55, 1.0)
	tmat.emission_energy_multiplier = 1.6
	tmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	tome.material_override = tmat
	chamber.add_child(tome)
	# Floating page glyph above the tome (a small pulsing prism)
	var page: MeshInstance3D = MeshInstance3D.new()
	var pg: PrismMesh = PrismMesh.new()
	pg.size = Vector3(0.20, 0.30, 0.06)
	page.mesh = pg
	page.position = Vector3(0, 1.85, -0.55)
	var pgmat: StandardMaterial3D = StandardMaterial3D.new()
	pgmat.albedo_color = Color(1, 1, 1)
	pgmat.emission_enabled = true
	pgmat.emission = Color(1, 1, 1)
	pgmat.emission_energy_multiplier = 2.6
	pgmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	page.material_override = pgmat
	chamber.add_child(page)
	var bob: Tween = create_tween().set_loops()
	bob.tween_property(page, "position:y", 2.10, 1.4).set_ease(Tween.EASE_IN_OUT)
	bob.tween_property(page, "position:y", 1.85, 1.4).set_ease(Tween.EASE_IN_OUT)
	# Stool in front
	var stool: MeshInstance3D = MeshInstance3D.new()
	var sm2: CylinderMesh = CylinderMesh.new()
	sm2.top_radius = 0.22
	sm2.bottom_radius = 0.22
	sm2.height = 0.55
	stool.mesh = sm2
	stool.position = Vector3(0, 0.27, 0.65)
	stool.material_override = podium_mat
	chamber.add_child(stool)
	# Sign
	var label: Label3D = Label3D.new()
	label.text = "READING\nCHAMBER"
	label.position = Vector3(0, 3.85, 0)
	label.modulate = Color(0.85, 0.55, 1.0)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 16
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	chamber.add_child(label)
	# Collision around the back wall + sides
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(3.40, 3.40, 2.80)
	cs.shape = cb
	cs.position = Vector3(0, 1.70, 0)
	sb.add_child(cs)
	chamber.add_child(sb)


func _build_d3_memory_shards(geom: Node) -> void:
	## Epic-3 T9: 8 small floating "memory shard" prism collectibles
	## scattered around the great crystal — like Epic 1's data shards but
	## violet. Spinning + bobbing decorative collectibles.
	var positions: Array[Vector3] = [
		D3_CENTER + Vector3(-6, 1.2, -4),
		D3_CENTER + Vector3(6, 1.2, -4),
		D3_CENTER + Vector3(-6, 1.2, 4),
		D3_CENTER + Vector3(6, 1.2, 4),
		D3_CENTER + Vector3(-10, 1.2, 0),
		D3_CENTER + Vector3(10, 1.2, 0),
		D3_CENTER + Vector3(0, 1.2, -10),
		D3_CENTER + Vector3(0, 1.2, 10),
	]
	var shard_mat: StandardMaterial3D = StandardMaterial3D.new()
	shard_mat.albedo_color = Color(0.85, 0.40, 1.0)
	shard_mat.emission_enabled = true
	shard_mat.emission = Color(1.0, 0.55, 1.0)
	shard_mat.emission_energy_multiplier = 2.4
	shard_mat.metallic = 0.40
	shard_mat.roughness = 0.10
	shard_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for i in positions.size():
		var shard: MeshInstance3D = MeshInstance3D.new()
		shard.name = "D3MemoryShard_%d" % i
		var smesh: PrismMesh = PrismMesh.new()
		smesh.size = Vector3(0.30, 0.55, 0.30)
		shard.mesh = smesh
		shard.position = positions[i]
		shard.material_override = shard_mat
		geom.add_child(shard)
		# Spin
		var spin: Tween = create_tween().set_loops()
		spin.tween_property(shard, "rotation:y", TAU, 3.0 + i * 0.2)
		# Bob
		var bob: Tween = create_tween().set_loops()
		var origin_y: float = positions[i].y
		bob.tween_property(shard, "position:y", origin_y + 0.40, 1.4).set_ease(Tween.EASE_IN_OUT)
		bob.tween_property(shard, "position:y", origin_y, 1.4).set_ease(Tween.EASE_IN_OUT)


func _build_d3_archivist_npc(town: Node) -> void:
	## Epic-3 T10: Archivist NPC standing inside the reading chamber.
	## Tall robed figure with a glowing scroll case slung over one shoulder
	## and a single bright violet eye on the head.
	var slots: Node3D = town.get_node_or_null("%NPCSlots") as Node3D
	if slots == null:
		return
	var arch: Node3D = Node3D.new()
	arch.name = "D3Archivist"
	arch.position = D3_CENTER + Vector3(-15, 0, -7)
	slots.add_child(arch)
	# Robed body
	var bmat: StandardMaterial3D = StandardMaterial3D.new()
	bmat.albedo_color = Color(0.16, 0.10, 0.22)
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
	arch.add_child(body)
	# Wide hood
	var hood: MeshInstance3D = MeshInstance3D.new()
	var hmesh: SphereMesh = SphereMesh.new()
	hmesh.radius = 0.50
	hmesh.height = 0.65
	hood.mesh = hmesh
	hood.position = Vector3(0, 1.55, 0)
	hood.material_override = bmat
	arch.add_child(hood)
	# Single bright violet eye
	var eye: MeshInstance3D = MeshInstance3D.new()
	var em: SphereMesh = SphereMesh.new()
	em.radius = 0.10
	em.height = 0.20
	eye.mesh = em
	eye.position = Vector3(0, 1.45, 0.36)
	var emat: StandardMaterial3D = StandardMaterial3D.new()
	emat.albedo_color = Color(1.0, 0.55, 1.0)
	emat.emission_enabled = true
	emat.emission = Color(1.0, 0.55, 1.0)
	emat.emission_energy_multiplier = 3.0
	emat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	eye.material_override = emat
	arch.add_child(eye)
	# Scroll case slung over shoulder — long cylinder at angle
	var case_mat: StandardMaterial3D = StandardMaterial3D.new()
	case_mat.albedo_color = Color(0.30, 0.20, 0.10)
	case_mat.metallic = 0.40
	case_mat.roughness = 0.55
	case_mat.emission_enabled = true
	case_mat.emission = Color(1.0, 0.65, 0.20)
	case_mat.emission_energy_multiplier = 0.55
	var scroll_case: MeshInstance3D = MeshInstance3D.new()
	var scmesh: CylinderMesh = CylinderMesh.new()
	scmesh.top_radius = 0.10
	scmesh.bottom_radius = 0.10
	scmesh.height = 0.85
	scroll_case.mesh = scmesh
	scroll_case.position = Vector3(0.40, 1.0, -0.20)
	scroll_case.rotation = Vector3(0, 0, deg_to_rad(35))
	scroll_case.material_override = case_mat
	arch.add_child(scroll_case)
	# Pulse eye
	var pulse: Tween = create_tween().set_loops()
	pulse.tween_property(emat, "emission_energy_multiplier", 4.0, 1.0).set_ease(Tween.EASE_IN_OUT)
	pulse.tween_property(emat, "emission_energy_multiplier", 2.0, 1.0).set_ease(Tween.EASE_IN_OUT)
	# Name billboard
	var label: Label3D = Label3D.new()
	label.text = "Archivist"
	label.position = Vector3(0, 2.20, 0)
	label.modulate = Color(0.85, 0.55, 1.0)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 18
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	arch.add_child(label)


func _build_d3_codex_pages(geom: Node) -> void:
	## Epic-3 T11: 12 drifting "codex pages" — small thin translucent
	## boxes floating across the vault on independent paths, each with
	## a small Label3D rune symbol on it.
	var pages_root: Node3D = Node3D.new()
	pages_root.name = "D3CodexPages"
	geom.add_child(pages_root)
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 121
	var symbols: Array[String] = ["α", "β", "γ", "δ", "ε", "ζ"]
	for i in 12:
		var page: MeshInstance3D = MeshInstance3D.new()
		page.name = "CodexPage_%d" % i
		var pmesh: BoxMesh = BoxMesh.new()
		pmesh.size = Vector3(0.40, 0.55, 0.04)
		page.mesh = pmesh
		page.position = D3_CENTER + Vector3(
			rng.randf_range(-22, 22),
			rng.randf_range(2, 8),
			rng.randf_range(-16, 16)
		)
		var pmat: StandardMaterial3D = StandardMaterial3D.new()
		pmat.albedo_color = Color(0.95, 0.85, 0.65, 0.75)
		pmat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		pmat.emission_enabled = true
		pmat.emission = Color(1.0, 0.85, 0.55)
		pmat.emission_energy_multiplier = 0.85
		pmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		page.material_override = pmat
		pages_root.add_child(page)
		# Symbol on page
		var label: Label3D = Label3D.new()
		label.text = symbols[i % symbols.size()]
		label.position = page.position + Vector3(0, 0, 0.04)
		label.modulate = Color(0.30, 0.10, 0.40)
		label.outline_size = 0
		label.font_size = 18
		label.no_depth_test = true
		label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		pages_root.add_child(label)
		# Drift tween
		var origin: Vector3 = page.position
		var drift: Tween = create_tween().set_loops()
		var wp1: Vector3 = origin + Vector3(rng.randf_range(-3, 3), rng.randf_range(-1, 1), rng.randf_range(-3, 3))
		var wp2: Vector3 = origin + Vector3(rng.randf_range(-3, 3), rng.randf_range(-1, 1), rng.randf_range(-3, 3))
		drift.tween_property(page, "position", wp1, 5.0).set_ease(Tween.EASE_IN_OUT)
		drift.tween_property(page, "position", wp2, 5.0).set_ease(Tween.EASE_IN_OUT)
		drift.tween_property(page, "position", origin, 5.0).set_ease(Tween.EASE_IN_OUT)
		# Tumble
		var tumble: Tween = create_tween().set_loops()
		tumble.tween_property(page, "rotation", Vector3(TAU, TAU * 0.5, 0), 7.0)


func _build_d3_spiral_stair(geom: Node) -> void:
	## Epic-3 T12: a tall spiral knowledge staircase landmark — 12 steps
	## winding upward around a central column, each step with a small
	## emissive trim. Decorative climb-tower on the side of the district.
	var stair: Node3D = Node3D.new()
	stair.name = "D3SpiralStair"
	stair.position = D3_CENTER + Vector3(15, 0, -12)
	geom.add_child(stair)
	# Center column
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.10, 0.06, 0.18)
	stone_mat.metallic = 0.55
	stone_mat.roughness = 0.45
	var col: MeshInstance3D = MeshInstance3D.new()
	var cmesh: CylinderMesh = CylinderMesh.new()
	cmesh.top_radius = 0.55
	cmesh.bottom_radius = 0.65
	cmesh.height = 7.0
	col.mesh = cmesh
	col.position = Vector3(0, 3.5, 0)
	col.material_override = stone_mat
	stair.add_child(col)
	# 12 steps spiraling upward
	for i in 12:
		var t: float = float(i) / 12.0
		var angle: float = t * TAU * 1.5
		var height: float = 0.3 + i * 0.55
		var step_root: Node3D = Node3D.new()
		step_root.position = Vector3(cos(angle) * 1.20, height, sin(angle) * 1.20)
		step_root.rotation = Vector3(0, -angle, 0)
		stair.add_child(step_root)
		# Step slab
		var step: MeshInstance3D = MeshInstance3D.new()
		var sm: BoxMesh = BoxMesh.new()
		sm.size = Vector3(1.40, 0.20, 0.85)
		step.mesh = sm
		step.material_override = stone_mat
		step_root.add_child(step)
		# Glowing edge trim
		var trim: MeshInstance3D = MeshInstance3D.new()
		var tm: BoxMesh = BoxMesh.new()
		tm.size = Vector3(1.40, 0.06, 0.06)
		trim.mesh = tm
		trim.position = Vector3(0, 0.15, 0.42)
		var tmat: StandardMaterial3D = StandardMaterial3D.new()
		tmat.albedo_color = Color(0.85, 0.40, 1.0)
		tmat.emission_enabled = true
		tmat.emission = Color(1.0, 0.55, 1.0)
		tmat.emission_energy_multiplier = 1.8
		tmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		trim.material_override = tmat
		step_root.add_child(trim)
		# Per-step collision
		var step_body: StaticBody3D = StaticBody3D.new()
		var step_col: CollisionShape3D = CollisionShape3D.new()
		var cb: BoxShape3D = BoxShape3D.new()
		cb.size = Vector3(1.40, 0.20, 0.85)
		step_col.shape = cb
		step_body.add_child(step_col)
		step_root.add_child(step_body)
	# Top crown — pulsing violet sphere
	var crown: MeshInstance3D = MeshInstance3D.new()
	var crmesh: SphereMesh = SphereMesh.new()
	crmesh.radius = 0.45
	crmesh.height = 0.90
	crown.mesh = crmesh
	crown.position = Vector3(0, 7.85, 0)
	var crmat: StandardMaterial3D = StandardMaterial3D.new()
	crmat.albedo_color = Color(0.85, 0.40, 1.0)
	crmat.emission_enabled = true
	crmat.emission = Color(1.0, 0.55, 1.0)
	crmat.emission_energy_multiplier = 2.6
	crmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	crown.material_override = crmat
	stair.add_child(crown)
	var pulse: Tween = create_tween().set_loops()
	pulse.tween_property(crown, "scale", Vector3(1.30, 1.30, 1.30), 1.8).set_ease(Tween.EASE_IN_OUT)
	pulse.tween_property(crown, "scale", Vector3(0.85, 0.85, 0.85), 1.8).set_ease(Tween.EASE_IN_OUT)
	# Collision around the central column
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cap: CapsuleShape3D = CapsuleShape3D.new()
	cap.radius = 0.65
	cap.height = 7.0
	cs.shape = cap
	cs.position = Vector3(0, 3.5, 0)
	sb.add_child(cs)
	stair.add_child(sb)


func _build_d3_wisp_enemy(geom: Node) -> void:
	## Epic-3 T13: 4 small floating wisp enemies — pulsing emissive
	## spheres with trailing tail particles, drifting through the vault.
	var positions: Array[Vector3] = [
		D3_CENTER + Vector3(-8, 2.5, 8),
		D3_CENTER + Vector3(10, 3.0, -6),
		D3_CENTER + Vector3(-12, 2.0, -4),
		D3_CENTER + Vector3(14, 2.5, 10),
	]
	for i in positions.size():
		var wisp: Node3D = Node3D.new()
		wisp.name = "D3Wisp_%d" % i
		wisp.position = positions[i]
		geom.add_child(wisp)
		# Core sphere
		var core: MeshInstance3D = MeshInstance3D.new()
		var cm: SphereMesh = SphereMesh.new()
		cm.radius = 0.30
		cm.height = 0.60
		core.mesh = cm
		var cmat: StandardMaterial3D = StandardMaterial3D.new()
		cmat.albedo_color = Color(0.85, 0.40, 1.0)
		cmat.emission_enabled = true
		cmat.emission = Color(1.0, 0.55, 1.0)
		cmat.emission_energy_multiplier = 3.0
		cmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		core.material_override = cmat
		wisp.add_child(core)
		# Pulse the core
		var pulse: Tween = create_tween().set_loops()
		pulse.tween_property(core, "scale", Vector3(1.40, 1.40, 1.40), 0.8).set_ease(Tween.EASE_IN_OUT)
		pulse.tween_property(core, "scale", Vector3(0.85, 0.85, 0.85), 0.8).set_ease(Tween.EASE_IN_OUT)
		# Trailing tail particles
		var tail: GPUParticles3D = GPUParticles3D.new()
		tail.amount = 30
		tail.lifetime = 0.85
		var pmat: ParticleProcessMaterial = ParticleProcessMaterial.new()
		pmat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
		pmat.emission_sphere_radius = 0.20
		pmat.direction = Vector3(0, -0.5, 0)
		pmat.spread = 30.0
		pmat.initial_velocity_min = 0.30
		pmat.initial_velocity_max = 0.65
		pmat.gravity = Vector3.ZERO
		pmat.scale_min = 0.10
		pmat.scale_max = 0.20
		pmat.color = Color(1.0, 0.55, 1.0, 1.0)
		tail.process_material = pmat
		var pm: SphereMesh = SphereMesh.new()
		pm.radius = 0.10
		pm.height = 0.20
		var pmm: StandardMaterial3D = StandardMaterial3D.new()
		pmm.albedo_color = Color(1.0, 0.55, 1.0)
		pmm.emission_enabled = true
		pmm.emission = Color(1.0, 0.55, 1.0)
		pmm.emission_energy_multiplier = 2.2
		pmm.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		pm.material = pmm
		tail.draw_pass_1 = pm
		wisp.add_child(tail)
		# Slow drift patrol
		var origin: Vector3 = positions[i]
		var drift: Tween = create_tween().set_loops()
		drift.tween_property(wisp, "position", origin + Vector3(3, 0.8, 3), 4.0).set_ease(Tween.EASE_IN_OUT)
		drift.tween_property(wisp, "position", origin + Vector3(-3, -0.8, 3), 4.0).set_ease(Tween.EASE_IN_OUT)
		drift.tween_property(wisp, "position", origin + Vector3(-3, 0.8, -3), 4.0).set_ease(Tween.EASE_IN_OUT)
		drift.tween_property(wisp, "position", origin, 4.0).set_ease(Tween.EASE_IN_OUT)


func _build_d3_vault_keeper_npc(town: Node) -> void:
	## Epic-3 T14: Vault Keeper NPC — large statue-like guardian standing
	## still by the entrance arch. Has a key motif on chest and golden eyes.
	var slots: Node3D = town.get_node_or_null("%NPCSlots") as Node3D
	if slots == null:
		return
	var keeper: Node3D = Node3D.new()
	keeper.name = "D3VaultKeeper"
	keeper.position = Vector3(125, 0, -3)
	slots.add_child(keeper)
	# Tall stone body
	var bmat: StandardMaterial3D = StandardMaterial3D.new()
	bmat.albedo_color = Color(0.18, 0.14, 0.24)
	bmat.metallic = 0.40
	bmat.roughness = 0.55
	bmat.emission_enabled = true
	bmat.emission = Color(0.55, 0.30, 0.85)
	bmat.emission_energy_multiplier = 0.40
	var body: MeshInstance3D = MeshInstance3D.new()
	var bmesh: BoxMesh = BoxMesh.new()
	bmesh.size = Vector3(1.20, 2.20, 0.85)
	body.mesh = bmesh
	body.position = Vector3(0, 1.10, 0)
	body.material_override = bmat
	keeper.add_child(body)
	# Head — square
	var head: MeshInstance3D = MeshInstance3D.new()
	var hm: BoxMesh = BoxMesh.new()
	hm.size = Vector3(0.85, 0.85, 0.85)
	head.mesh = hm
	head.position = Vector3(0, 2.65, 0)
	head.material_override = bmat
	keeper.add_child(head)
	# 2 golden eyes
	var eye_mat: StandardMaterial3D = StandardMaterial3D.new()
	eye_mat.albedo_color = Color(1.0, 0.85, 0.30)
	eye_mat.emission_enabled = true
	eye_mat.emission = Color(1.0, 0.95, 0.30)
	eye_mat.emission_energy_multiplier = 2.6
	eye_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for ex: float in [-0.18, 0.18]:
		var eye: MeshInstance3D = MeshInstance3D.new()
		var em: SphereMesh = SphereMesh.new()
		em.radius = 0.10
		em.height = 0.20
		eye.mesh = em
		eye.position = Vector3(ex, 2.70, 0.45)
		eye.material_override = eye_mat
		keeper.add_child(eye)
	# Key motif on chest — a thin emissive cross + circle
	var key_mat: StandardMaterial3D = StandardMaterial3D.new()
	key_mat.albedo_color = Color(1.0, 0.85, 0.30)
	key_mat.emission_enabled = true
	key_mat.emission = Color(1.0, 0.95, 0.30)
	key_mat.emission_energy_multiplier = 1.8
	key_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	# Vertical bar
	var v_bar: MeshInstance3D = MeshInstance3D.new()
	var vm: BoxMesh = BoxMesh.new()
	vm.size = Vector3(0.10, 0.85, 0.04)
	v_bar.mesh = vm
	v_bar.position = Vector3(0, 1.40, 0.45)
	v_bar.material_override = key_mat
	keeper.add_child(v_bar)
	# Horizontal bar
	var h_bar: MeshInstance3D = MeshInstance3D.new()
	var hbm: BoxMesh = BoxMesh.new()
	hbm.size = Vector3(0.40, 0.10, 0.04)
	h_bar.mesh = hbm
	h_bar.position = Vector3(0, 1.55, 0.45)
	h_bar.material_override = key_mat
	keeper.add_child(h_bar)
	# Circle bow at top of key
	var bow: MeshInstance3D = MeshInstance3D.new()
	var bowm: SphereMesh = SphereMesh.new()
	bowm.radius = 0.18
	bowm.height = 0.36
	bow.mesh = bowm
	bow.position = Vector3(0, 1.85, 0.45)
	bow.material_override = key_mat
	keeper.add_child(bow)
	# Name billboard
	var label: Label3D = Label3D.new()
	label.text = "Vault Keeper"
	label.position = Vector3(0, 3.30, 0)
	label.modulate = Color(1.0, 0.85, 0.30)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 18
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	keeper.add_child(label)


func _build_d3_memory_pool(geom: Node) -> void:
	## Epic-3 T15: a small circular memory pool — torus rim around a
	## glowing translucent disc. Bubbling violet "data" rises from it.
	var pool: Node3D = Node3D.new()
	pool.name = "D3MemoryPool"
	pool.position = D3_CENTER + Vector3(15, 0, 8)
	geom.add_child(pool)
	# Stone rim
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.16, 0.10, 0.20)
	stone_mat.metallic = 0.55
	stone_mat.roughness = 0.45
	var rim: MeshInstance3D = MeshInstance3D.new()
	var rmesh: TorusMesh = TorusMesh.new()
	rmesh.inner_radius = 1.40
	rmesh.outer_radius = 1.85
	rim.mesh = rmesh
	rim.position = Vector3(0, 0.20, 0)
	rim.material_override = stone_mat
	pool.add_child(rim)
	# Inner pool surface — glowing violet disc
	var surface: MeshInstance3D = MeshInstance3D.new()
	var sm: CylinderMesh = CylinderMesh.new()
	sm.top_radius = 1.40
	sm.bottom_radius = 1.40
	sm.height = 0.06
	surface.mesh = sm
	surface.position = Vector3(0, 0.20, 0)
	var smat: StandardMaterial3D = StandardMaterial3D.new()
	smat.albedo_color = Color(0.85, 0.40, 1.0, 0.85)
	smat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	smat.emission_enabled = true
	smat.emission = Color(1.0, 0.55, 1.0)
	smat.emission_energy_multiplier = 1.8
	smat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	surface.material_override = smat
	pool.add_child(surface)
	# Ripple tween
	var ripple: Tween = create_tween().set_loops()
	ripple.tween_property(surface, "scale", Vector3(1.05, 1.0, 0.96), 1.6).set_ease(Tween.EASE_IN_OUT)
	ripple.tween_property(surface, "scale", Vector3(0.96, 1.0, 1.05), 1.6).set_ease(Tween.EASE_IN_OUT)
	# Bubbling violet particles rising from the surface
	var bubbles: GPUParticles3D = GPUParticles3D.new()
	bubbles.amount = 30
	bubbles.lifetime = 2.5
	bubbles.position = Vector3(0, 0.30, 0)
	var pmat: ParticleProcessMaterial = ParticleProcessMaterial.new()
	pmat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	pmat.emission_sphere_radius = 1.20
	pmat.direction = Vector3(0, 1, 0)
	pmat.spread = 12.0
	pmat.initial_velocity_min = 0.55
	pmat.initial_velocity_max = 1.0
	pmat.gravity = Vector3.ZERO
	pmat.scale_min = 0.10
	pmat.scale_max = 0.20
	pmat.color = Color(1.0, 0.55, 1.0, 1.0)
	bubbles.process_material = pmat
	var bm: SphereMesh = SphereMesh.new()
	bm.radius = 0.10
	bm.height = 0.20
	var bm_mat: StandardMaterial3D = StandardMaterial3D.new()
	bm_mat.albedo_color = Color(1.0, 0.55, 1.0)
	bm_mat.emission_enabled = true
	bm_mat.emission = Color(1.0, 0.55, 1.0)
	bm_mat.emission_energy_multiplier = 2.6
	bm_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	bm.material = bm_mat
	bubbles.draw_pass_1 = bm
	pool.add_child(bubbles)
	# Sign
	var label: Label3D = Label3D.new()
	label.text = "MEMORY POOL"
	label.position = Vector3(0, 1.85, 0)
	label.modulate = Color(1.0, 0.55, 1.0)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 16
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	pool.add_child(label)


func _build_d3_floating_bookshelves(geom: Node) -> void:
	## Epic-3 T16: 4 floating bookshelves drifting at different altitudes,
	## each holding 5 colored book spines glowing inside.
	var positions: Array[Vector3] = [
		D3_CENTER + Vector3(-18, 3.5, 4),
		D3_CENTER + Vector3(-18, 4.5, -2),
		D3_CENTER + Vector3(18, 3.5, 4),
		D3_CENTER + Vector3(18, 4.5, -2),
	]
	var shelf_mat: StandardMaterial3D = StandardMaterial3D.new()
	shelf_mat.albedo_color = Color(0.30, 0.18, 0.10)
	shelf_mat.metallic = 0.20
	shelf_mat.roughness = 0.65
	shelf_mat.emission_enabled = true
	shelf_mat.emission = Color(0.85, 0.40, 1.0)
	shelf_mat.emission_energy_multiplier = 0.45
	for i in positions.size():
		var shelf: Node3D = Node3D.new()
		shelf.name = "D3FloatingShelf_%d" % i
		shelf.position = positions[i]
		geom.add_child(shelf)
		# Shelf box
		var body: MeshInstance3D = MeshInstance3D.new()
		var bm: BoxMesh = BoxMesh.new()
		bm.size = Vector3(1.85, 0.85, 0.45)
		body.mesh = bm
		body.material_override = shelf_mat
		shelf.add_child(body)
		# 5 colored book spines
		var book_colors: Array[Color] = [
			Color(0.55, 0.30, 0.30),
			Color(0.30, 0.55, 0.30),
			Color(0.30, 0.30, 0.55),
			Color(0.55, 0.55, 0.30),
			Color(0.55, 0.30, 0.55),
		]
		for b in 5:
			var book: MeshInstance3D = MeshInstance3D.new()
			var bkm: BoxMesh = BoxMesh.new()
			bkm.size = Vector3(0.30, 0.65, 0.04)
			book.mesh = bkm
			book.position = Vector3(-0.65 + b * 0.32, 0, 0.20)
			var bkmat: StandardMaterial3D = StandardMaterial3D.new()
			bkmat.albedo_color = book_colors[b]
			bkmat.emission_enabled = true
			bkmat.emission = book_colors[b]
			bkmat.emission_energy_multiplier = 1.4
			bkmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
			book.material_override = bkmat
			shelf.add_child(book)
		# Bob tween
		var origin_y: float = positions[i].y
		var bob: Tween = create_tween().set_loops()
		bob.tween_property(shelf, "position:y", origin_y + 0.40, 1.8 + i * 0.2).set_ease(Tween.EASE_IN_OUT)
		bob.tween_property(shelf, "position:y", origin_y, 1.8 + i * 0.2).set_ease(Tween.EASE_IN_OUT)
		# Slow rotation
		var spin: Tween = create_tween().set_loops()
		spin.tween_property(shelf, "rotation:y", TAU, 18.0 + i * 2)


func _build_d3_stone_benches(geom: Node) -> void:
	## Epic-3 T17: 5 stone benches arranged in a semicircle facing the
	## great crystal — meditation seating for the vault scholars.
	var bench_mat: StandardMaterial3D = StandardMaterial3D.new()
	bench_mat.albedo_color = Color(0.16, 0.10, 0.20)
	bench_mat.metallic = 0.40
	bench_mat.roughness = 0.55
	bench_mat.emission_enabled = true
	bench_mat.emission = Color(0.55, 0.30, 0.85)
	bench_mat.emission_energy_multiplier = 0.30
	for i in 5:
		var t: float = float(i) / 4.0
		var angle: float = (-PI * 0.5) + t * PI + PI  # facing the crystal
		var radius: float = 6.5
		var bench: Node3D = Node3D.new()
		bench.name = "D3Bench_%d" % i
		bench.position = D3_CENTER + Vector3(cos(angle) * radius, 0, sin(angle) * radius)
		bench.rotation = Vector3(0, -angle, 0)
		geom.add_child(bench)
		# Top slab
		var slab: MeshInstance3D = MeshInstance3D.new()
		var sm: BoxMesh = BoxMesh.new()
		sm.size = Vector3(1.85, 0.20, 0.55)
		slab.mesh = sm
		slab.position = Vector3(0, 0.55, 0)
		slab.material_override = bench_mat
		bench.add_child(slab)
		# 2 stubby legs
		for sx: float in [-0.65, 0.65]:
			var leg: MeshInstance3D = MeshInstance3D.new()
			var lm: BoxMesh = BoxMesh.new()
			lm.size = Vector3(0.30, 0.45, 0.45)
			leg.mesh = lm
			leg.position = Vector3(sx, 0.22, 0)
			leg.material_override = bench_mat
			bench.add_child(leg)
		# Per-bench collision
		var sb: StaticBody3D = StaticBody3D.new()
		var cs: CollisionShape3D = CollisionShape3D.new()
		var cb: BoxShape3D = BoxShape3D.new()
		cb.size = Vector3(1.85, 0.65, 0.55)
		cs.shape = cb
		cs.position = Vector3(0, 0.32, 0)
		sb.add_child(cs)
		bench.add_child(sb)


func _build_d3_ritual_circle(geom: Node) -> void:
	## Epic-3 T18: a 5m violet ritual circle on the ground in front of the
	## great crystal — concentric torus rings + 8 small rune dots in a
	## ring + a center pulsing star.
	var ring_root: Node3D = Node3D.new()
	ring_root.name = "D3RitualCircle"
	ring_root.position = D3_CENTER + Vector3(0, 0.06, 0)
	geom.add_child(ring_root)
	var ring_mat: StandardMaterial3D = StandardMaterial3D.new()
	ring_mat.albedo_color = Color(0.85, 0.40, 1.0)
	ring_mat.emission_enabled = true
	ring_mat.emission = Color(1.0, 0.55, 1.0)
	ring_mat.emission_energy_multiplier = 1.8
	ring_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	# 2 concentric rings
	for r in 2:
		var ring: MeshInstance3D = MeshInstance3D.new()
		var rmesh: TorusMesh = TorusMesh.new()
		rmesh.inner_radius = 4.0 + r * 0.40
		rmesh.outer_radius = 4.20 + r * 0.40
		ring.mesh = rmesh
		ring.material_override = ring_mat
		ring_root.add_child(ring)
		# Slow rotation
		var spin: Tween = create_tween().set_loops()
		spin.tween_property(ring, "rotation:y", TAU * (1 if r % 2 == 0 else -1), 22.0 + r * 4)
	# 8 small rune dots in a ring inside
	for i in 8:
		var angle: float = (float(i) / 8.0) * TAU
		var dot: MeshInstance3D = MeshInstance3D.new()
		var dm: SphereMesh = SphereMesh.new()
		dm.radius = 0.18
		dm.height = 0.36
		dot.mesh = dm
		dot.position = Vector3(cos(angle) * 3.40, 0.10, sin(angle) * 3.40)
		dot.material_override = ring_mat
		ring_root.add_child(dot)
	# Center 4-prong pulsing star
	for i in 4:
		var angle: float = (float(i) / 4.0) * TAU
		var prong: MeshInstance3D = MeshInstance3D.new()
		var pm: BoxMesh = BoxMesh.new()
		pm.size = Vector3(0.20, 0.04, 1.40)
		prong.mesh = pm
		prong.position = Vector3(0, 0.10, 0)
		prong.rotation = Vector3(0, -angle, 0)
		prong.material_override = ring_mat
		ring_root.add_child(prong)
	# Pulse the entire circle scale
	var pulse: Tween = create_tween().set_loops()
	pulse.tween_property(ring_root, "scale", Vector3(1.06, 1.0, 1.06), 2.4).set_ease(Tween.EASE_IN_OUT)
	pulse.tween_property(ring_root, "scale", Vector3(0.96, 1.0, 0.96), 2.4).set_ease(Tween.EASE_IN_OUT)


func _build_d3_war_banners(geom: Node) -> void:
	## Epic-3 T19: 4 ancient war banners hanging from tall stone poles —
	## long violet cloth panels with rune symbols. Tells "ancient battles
	## happened here, the vault commemorates fallen mages".
	var positions: Array[Vector3] = [
		D3_CENTER + Vector3(-22, 0, -8),
		D3_CENTER + Vector3(-22, 0, 8),
		D3_CENTER + Vector3(22, 0, -8),
		D3_CENTER + Vector3(22, 0, 8),
	]
	var pole_mat: StandardMaterial3D = StandardMaterial3D.new()
	pole_mat.albedo_color = Color(0.10, 0.06, 0.18)
	pole_mat.metallic = 0.55
	pole_mat.roughness = 0.45
	var banner_mat: StandardMaterial3D = StandardMaterial3D.new()
	banner_mat.albedo_color = Color(0.20, 0.10, 0.30)
	banner_mat.emission_enabled = true
	banner_mat.emission = Color(0.85, 0.40, 1.0)
	banner_mat.emission_energy_multiplier = 0.95
	banner_mat.metallic = 0.10
	banner_mat.roughness = 0.55
	for i in positions.size():
		var banner_root: Node3D = Node3D.new()
		banner_root.name = "D3WarBanner_%d" % i
		banner_root.position = positions[i]
		geom.add_child(banner_root)
		# Tall pole
		var pole: MeshInstance3D = MeshInstance3D.new()
		var pmesh: CylinderMesh = CylinderMesh.new()
		pmesh.top_radius = 0.10
		pmesh.bottom_radius = 0.14
		pmesh.height = 6.5
		pole.mesh = pmesh
		pole.position = Vector3(0, 3.25, 0)
		pole.material_override = pole_mat
		banner_root.add_child(pole)
		# Hanging banner cloth
		var banner: MeshInstance3D = MeshInstance3D.new()
		var bm: BoxMesh = BoxMesh.new()
		bm.size = Vector3(1.40, 3.0, 0.06)
		banner.mesh = bm
		banner.position = Vector3(0.85, 4.85, 0)
		banner.material_override = banner_mat
		banner_root.add_child(banner)
		# Rune symbol on banner
		var rune: Label3D = Label3D.new()
		var symbols: Array[String] = ["Ψ", "Ω", "Φ", "Δ"]
		rune.text = symbols[i]
		rune.position = Vector3(0.85, 4.85, 0.05)
		rune.modulate = Color(1, 1, 1)
		rune.outline_modulate = Color(0, 0, 0, 0.85)
		rune.outline_size = 5
		rune.font_size = 38
		rune.no_depth_test = true
		banner_root.add_child(rune)
		# Top pole crown
		var crown: MeshInstance3D = MeshInstance3D.new()
		var cm: SphereMesh = SphereMesh.new()
		cm.radius = 0.18
		cm.height = 0.36
		crown.mesh = cm
		crown.position = Vector3(0, 6.65, 0)
		var cmat: StandardMaterial3D = StandardMaterial3D.new()
		cmat.albedo_color = Color(0.85, 0.40, 1.0)
		cmat.emission_enabled = true
		cmat.emission = Color(1.0, 0.55, 1.0)
		cmat.emission_energy_multiplier = 2.4
		cmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		crown.material_override = cmat
		banner_root.add_child(crown)
		# Collision on pole
		var sb: StaticBody3D = StaticBody3D.new()
		var cs: CollisionShape3D = CollisionShape3D.new()
		var cap: CapsuleShape3D = CapsuleShape3D.new()
		cap.radius = 0.20
		cap.height = 6.5
		cs.shape = cap
		cs.position = Vector3(0, 3.25, 0)
		sb.add_child(cs)
		banner_root.add_child(sb)


func _build_d3_acolyte_npc(town: Node) -> void:
	## Epic-3 T20: Acolyte NPC sitting cross-legged on one of the stone
	## benches, meditating with hands clasped in front and eyes closed.
	## Has a small floating prayer symbol over their head.
	var slots: Node3D = town.get_node_or_null("%NPCSlots") as Node3D
	if slots == null:
		return
	var acolyte: Node3D = Node3D.new()
	acolyte.name = "D3Acolyte"
	acolyte.position = D3_CENTER + Vector3(0, 0.65, 6.5)
	acolyte.rotation = Vector3(0, deg_to_rad(180), 0)
	slots.add_child(acolyte)
	# Robed body — short capsule (sitting)
	var bmat: StandardMaterial3D = StandardMaterial3D.new()
	bmat.albedo_color = Color(0.30, 0.20, 0.40)
	bmat.metallic = 0.20
	bmat.roughness = 0.65
	bmat.emission_enabled = true
	bmat.emission = Color(0.55, 0.30, 0.85)
	bmat.emission_energy_multiplier = 0.40
	var body: MeshInstance3D = MeshInstance3D.new()
	var bmesh: CapsuleMesh = CapsuleMesh.new()
	bmesh.radius = 0.40
	bmesh.height = 0.85
	body.mesh = bmesh
	body.position = Vector3(0, 0.45, 0)
	body.material_override = bmat
	acolyte.add_child(body)
	# Hood
	var hood: MeshInstance3D = MeshInstance3D.new()
	var hmesh: SphereMesh = SphereMesh.new()
	hmesh.radius = 0.40
	hmesh.height = 0.50
	hood.mesh = hmesh
	hood.position = Vector3(0, 1.0, 0)
	hood.material_override = bmat
	acolyte.add_child(hood)
	# Closed eyes — 2 thin black bars (eyes shut, meditating)
	var eye_mat: StandardMaterial3D = StandardMaterial3D.new()
	eye_mat.albedo_color = Color(0.05, 0.05, 0.10)
	eye_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for ex: float in [-0.10, 0.10]:
		var eye: MeshInstance3D = MeshInstance3D.new()
		var em: BoxMesh = BoxMesh.new()
		em.size = Vector3(0.08, 0.02, 0.04)
		eye.mesh = em
		eye.position = Vector3(ex, 0.95, 0.32)
		eye.material_override = eye_mat
		acolyte.add_child(eye)
	# Floating prayer rune above head — small pulsing prism
	var rune: MeshInstance3D = MeshInstance3D.new()
	var rmesh: PrismMesh = PrismMesh.new()
	rmesh.size = Vector3(0.20, 0.30, 0.20)
	rune.mesh = rmesh
	rune.position = Vector3(0, 1.85, 0)
	var rmat: StandardMaterial3D = StandardMaterial3D.new()
	rmat.albedo_color = Color(0.85, 0.40, 1.0)
	rmat.emission_enabled = true
	rmat.emission = Color(1.0, 0.55, 1.0)
	rmat.emission_energy_multiplier = 2.6
	rmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	rune.material_override = rmat
	acolyte.add_child(rune)
	# Rune slow rotation + bob
	var spin: Tween = create_tween().set_loops()
	spin.tween_property(rune, "rotation:y", TAU, 4.0)
	var bob: Tween = create_tween().set_loops()
	bob.tween_property(rune, "position:y", 2.10, 1.4).set_ease(Tween.EASE_IN_OUT)
	bob.tween_property(rune, "position:y", 1.85, 1.4).set_ease(Tween.EASE_IN_OUT)
	# Name billboard
	var label: Label3D = Label3D.new()
	label.text = "Acolyte"
	label.position = Vector3(0, 2.40, 0)
	label.modulate = Color(0.85, 0.55, 1.0)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 18
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	acolyte.add_child(label)


func _build_d3_mana_font(geom: Node) -> void:
	## Epic-3 T21: a mana font — small fountain with a glowing violet
	## sphere rising and falling on a tween. Ringed by 4 small candle
	## flames (mocked with emissive amber spheres).
	var font: Node3D = Node3D.new()
	font.name = "D3ManaFont"
	font.position = D3_CENTER + Vector3(-15, 0, 8)
	geom.add_child(font)
	# Stone basin
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.16, 0.10, 0.20)
	stone_mat.metallic = 0.55
	stone_mat.roughness = 0.45
	var basin: MeshInstance3D = MeshInstance3D.new()
	var bmesh: CylinderMesh = CylinderMesh.new()
	bmesh.top_radius = 0.85
	bmesh.bottom_radius = 1.0
	bmesh.height = 0.85
	basin.mesh = bmesh
	basin.position = Vector3(0, 0.42, 0)
	basin.material_override = stone_mat
	font.add_child(basin)
	# Mana sphere — bobs vertically
	var mana: MeshInstance3D = MeshInstance3D.new()
	var mm: SphereMesh = SphereMesh.new()
	mm.radius = 0.40
	mm.height = 0.80
	mana.mesh = mm
	mana.position = Vector3(0, 1.20, 0)
	var mmat: StandardMaterial3D = StandardMaterial3D.new()
	mmat.albedo_color = Color(0.85, 0.40, 1.0)
	mmat.emission_enabled = true
	mmat.emission = Color(1.0, 0.55, 1.0)
	mmat.emission_energy_multiplier = 3.0
	mmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mana.material_override = mmat
	font.add_child(mana)
	# Bob the mana sphere
	var bob: Tween = create_tween().set_loops()
	bob.tween_property(mana, "position:y", 1.85, 1.6).set_ease(Tween.EASE_IN_OUT)
	bob.tween_property(mana, "position:y", 1.0, 1.6).set_ease(Tween.EASE_IN_OUT)
	# 4 candle flames around the basin
	var flame_mat: StandardMaterial3D = StandardMaterial3D.new()
	flame_mat.albedo_color = Color(1.0, 0.65, 0.20)
	flame_mat.emission_enabled = true
	flame_mat.emission = Color(1.0, 0.75, 0.20)
	flame_mat.emission_energy_multiplier = 2.6
	flame_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for i in 4:
		var angle: float = (float(i) / 4.0) * TAU
		var flame: MeshInstance3D = MeshInstance3D.new()
		var fm: SphereMesh = SphereMesh.new()
		fm.radius = 0.12
		fm.height = 0.24
		flame.mesh = fm
		flame.position = Vector3(cos(angle) * 1.20, 0.95, sin(angle) * 1.20)
		flame.material_override = flame_mat
		font.add_child(flame)
		# Tiny flicker
		var fl: Tween = create_tween().set_loops()
		fl.tween_property(flame, "scale", Vector3(1.30, 1.30, 1.30), 0.4 + i * 0.08).set_ease(Tween.EASE_IN_OUT)
		fl.tween_property(flame, "scale", Vector3(0.85, 0.85, 0.85), 0.4 + i * 0.08).set_ease(Tween.EASE_IN_OUT)
	# Sign
	var label: Label3D = Label3D.new()
	label.text = "MANA FONT"
	label.position = Vector3(0, 2.40, 0)
	label.modulate = Color(1.0, 0.55, 1.0)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 16
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	font.add_child(label)
	# Collision around basin
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(2.0, 0.85, 2.0)
	cs.shape = cb
	cs.position = Vector3(0, 0.42, 0)
	sb.add_child(cs)
	font.add_child(sb)


func _build_d3_mausoleum(geom: Node) -> void:
	## Epic-3 T22: a stone mausoleum building — square structure with
	## peaked roof, sealed door with rune carving, and 4 corner crests.
	var maus: Node3D = Node3D.new()
	maus.name = "D3Mausoleum"
	maus.position = D3_CENTER + Vector3(15, 0, -16)
	geom.add_child(maus)
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.18, 0.14, 0.24)
	stone_mat.metallic = 0.40
	stone_mat.roughness = 0.55
	stone_mat.emission_enabled = true
	stone_mat.emission = Color(0.55, 0.30, 0.85)
	stone_mat.emission_energy_multiplier = 0.30
	# Main building cube
	var building: MeshInstance3D = MeshInstance3D.new()
	var bm: BoxMesh = BoxMesh.new()
	bm.size = Vector3(3.40, 3.40, 3.40)
	building.mesh = bm
	building.position = Vector3(0, 1.70, 0)
	building.material_override = stone_mat
	maus.add_child(building)
	# Peaked roof prism
	var roof: MeshInstance3D = MeshInstance3D.new()
	var rmesh: PrismMesh = PrismMesh.new()
	rmesh.size = Vector3(3.85, 1.40, 3.85)
	roof.mesh = rmesh
	roof.position = Vector3(0, 4.10, 0)
	roof.material_override = stone_mat
	maus.add_child(roof)
	# Sealed door — dark recess
	var door: MeshInstance3D = MeshInstance3D.new()
	var dm: BoxMesh = BoxMesh.new()
	dm.size = Vector3(0.85, 1.85, 0.10)
	door.mesh = dm
	door.position = Vector3(0, 1.30, 1.71)
	var dmat: StandardMaterial3D = StandardMaterial3D.new()
	dmat.albedo_color = Color(0.04, 0.02, 0.08)
	dmat.metallic = 0.30
	dmat.emission_enabled = true
	dmat.emission = Color(0.85, 0.40, 1.0)
	dmat.emission_energy_multiplier = 0.45
	dmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	door.material_override = dmat
	maus.add_child(door)
	# Glowing rune symbol on door
	var rune: Label3D = Label3D.new()
	rune.text = "Φ"
	rune.position = Vector3(0, 1.40, 1.77)
	rune.modulate = Color(1.0, 0.55, 1.0)
	rune.outline_modulate = Color(0, 0, 0, 0.85)
	rune.outline_size = 5
	rune.font_size = 36
	rune.no_depth_test = true
	maus.add_child(rune)
	# 4 corner crests on the roof — small spheres
	for ox: float in [-1.40, 1.40]:
		for oz: float in [-1.40, 1.40]:
			var crest: MeshInstance3D = MeshInstance3D.new()
			var cm: SphereMesh = SphereMesh.new()
			cm.radius = 0.20
			cm.height = 0.40
			crest.mesh = cm
			crest.position = Vector3(ox, 3.50, oz)
			var cmat: StandardMaterial3D = StandardMaterial3D.new()
			cmat.albedo_color = Color(0.85, 0.40, 1.0)
			cmat.emission_enabled = true
			cmat.emission = Color(1.0, 0.55, 1.0)
			cmat.emission_energy_multiplier = 2.4
			cmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
			crest.material_override = cmat
			maus.add_child(crest)
	# Sign
	var label: Label3D = Label3D.new()
	label.text = "MAUSOLEUM"
	label.position = Vector3(0, 5.30, 0)
	label.modulate = Color(0.85, 0.55, 1.0)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 18
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	maus.add_child(label)
	# Collision
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(3.40, 3.40, 3.40)
	cs.shape = cb
	cs.position = Vector3(0, 1.70, 0)
	sb.add_child(cs)
	maus.add_child(sb)


func _build_d3_crystal_lanterns(geom: Node) -> void:
	## Epic-3 T23: 6 floating crystal lantern cluster — small prisms
	## suspended in the air with thin tether cables to the ground.
	var positions: Array[Vector3] = [
		D3_CENTER + Vector3(-8, 3.5, 12),
		D3_CENTER + Vector3(-4, 4.0, 12),
		D3_CENTER + Vector3(0, 3.5, 12),
		D3_CENTER + Vector3(4, 4.0, 12),
		D3_CENTER + Vector3(8, 3.5, 12),
		D3_CENTER + Vector3(0, 4.5, 14),
	]
	var lantern_mat: StandardMaterial3D = StandardMaterial3D.new()
	lantern_mat.albedo_color = Color(0.85, 0.40, 1.0)
	lantern_mat.emission_enabled = true
	lantern_mat.emission = Color(1.0, 0.55, 1.0)
	lantern_mat.emission_energy_multiplier = 2.6
	lantern_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var cable_mat: StandardMaterial3D = StandardMaterial3D.new()
	cable_mat.albedo_color = Color(0.05, 0.05, 0.10)
	cable_mat.metallic = 0.55
	for i in positions.size():
		var lantern: MeshInstance3D = MeshInstance3D.new()
		lantern.name = "D3CrystalLantern_%d" % i
		var lmesh: PrismMesh = PrismMesh.new()
		lmesh.size = Vector3(0.30, 0.55, 0.30)
		lantern.mesh = lmesh
		lantern.position = positions[i]
		lantern.material_override = lantern_mat
		geom.add_child(lantern)
		# Thin tether cable down to the ground
		var cable: MeshInstance3D = MeshInstance3D.new()
		var cm: CylinderMesh = CylinderMesh.new()
		cm.top_radius = 0.02
		cm.bottom_radius = 0.02
		cm.height = positions[i].y
		cable.mesh = cm
		cable.position = Vector3(positions[i].x, positions[i].y * 0.5, positions[i].z)
		cable.material_override = cable_mat
		geom.add_child(cable)
		# Bob lantern
		var bob: Tween = create_tween().set_loops()
		var origin_y: float = positions[i].y
		bob.tween_property(lantern, "position:y", origin_y + 0.30, 1.4 + i * 0.15).set_ease(Tween.EASE_IN_OUT)
		bob.tween_property(lantern, "position:y", origin_y, 1.4 + i * 0.15).set_ease(Tween.EASE_IN_OUT)
		# Slow rotation
		var spin: Tween = create_tween().set_loops()
		spin.tween_property(lantern, "rotation:y", TAU, 5.0 + i * 0.3)


func _build_d3_sage_npc(town: Node) -> void:
	## Epic-3 T24: Sage NPC — old wise figure with a long beard, holding
	## a tall crystal staff with a glowing orb on top. The "wisdom giver"
	## archetype.
	var slots: Node3D = town.get_node_or_null("%NPCSlots") as Node3D
	if slots == null:
		return
	var sage: Node3D = Node3D.new()
	sage.name = "D3Sage"
	sage.position = D3_CENTER + Vector3(8, 0, -8)
	slots.add_child(sage)
	# Robed body
	var bmat: StandardMaterial3D = StandardMaterial3D.new()
	bmat.albedo_color = Color(0.30, 0.20, 0.40)
	bmat.metallic = 0.20
	bmat.roughness = 0.65
	bmat.emission_enabled = true
	bmat.emission = Color(0.55, 0.30, 0.85)
	bmat.emission_energy_multiplier = 0.30
	var body: MeshInstance3D = MeshInstance3D.new()
	var bmesh: CapsuleMesh = CapsuleMesh.new()
	bmesh.radius = 0.45
	bmesh.height = 1.40
	body.mesh = bmesh
	body.position = Vector3(0, 0.70, 0)
	body.material_override = bmat
	sage.add_child(body)
	# Wide hood
	var hood: MeshInstance3D = MeshInstance3D.new()
	var hmesh: SphereMesh = SphereMesh.new()
	hmesh.radius = 0.45
	hmesh.height = 0.55
	hood.mesh = hmesh
	hood.position = Vector3(0, 1.55, 0)
	hood.material_override = bmat
	sage.add_child(hood)
	# Long beard — white box
	var beard: MeshInstance3D = MeshInstance3D.new()
	var bm2: BoxMesh = BoxMesh.new()
	bm2.size = Vector3(0.30, 0.55, 0.10)
	beard.mesh = bm2
	beard.position = Vector3(0, 1.20, 0.34)
	var bmat2: StandardMaterial3D = StandardMaterial3D.new()
	bmat2.albedo_color = Color(0.95, 0.95, 1.0)
	bmat2.metallic = 0.10
	bmat2.roughness = 0.85
	beard.material_override = bmat2
	sage.add_child(beard)
	# 2 small white eyes above beard
	var eye_mat: StandardMaterial3D = StandardMaterial3D.new()
	eye_mat.albedo_color = Color(0.55, 0.95, 1.0)
	eye_mat.emission_enabled = true
	eye_mat.emission = Color(0.55, 0.95, 1.0)
	eye_mat.emission_energy_multiplier = 2.4
	eye_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for ex: float in [-0.10, 0.10]:
		var eye: MeshInstance3D = MeshInstance3D.new()
		var em: SphereMesh = SphereMesh.new()
		em.radius = 0.06
		em.height = 0.12
		eye.mesh = em
		eye.position = Vector3(ex, 1.55, 0.32)
		eye.material_override = eye_mat
		sage.add_child(eye)
	# Tall crystal staff — long cylinder
	var staff_mat: StandardMaterial3D = StandardMaterial3D.new()
	staff_mat.albedo_color = Color(0.30, 0.20, 0.10)
	staff_mat.metallic = 0.30
	var staff: MeshInstance3D = MeshInstance3D.new()
	var sm: CylinderMesh = CylinderMesh.new()
	sm.top_radius = 0.05
	sm.bottom_radius = 0.06
	sm.height = 2.40
	staff.mesh = sm
	staff.position = Vector3(0.55, 1.20, 0)
	staff.material_override = staff_mat
	sage.add_child(staff)
	# Crystal orb on top of staff
	var orb: MeshInstance3D = MeshInstance3D.new()
	var om: PrismMesh = PrismMesh.new()
	om.size = Vector3(0.30, 0.55, 0.30)
	orb.mesh = om
	orb.position = Vector3(0.55, 2.50, 0)
	var omat: StandardMaterial3D = StandardMaterial3D.new()
	omat.albedo_color = Color(0.85, 0.40, 1.0)
	omat.emission_enabled = true
	omat.emission = Color(1.0, 0.55, 1.0)
	omat.emission_energy_multiplier = 3.0
	omat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	orb.material_override = omat
	sage.add_child(orb)
	# Pulse the orb
	var pulse: Tween = create_tween().set_loops()
	pulse.tween_property(orb, "scale", Vector3(1.30, 1.30, 1.30), 1.4).set_ease(Tween.EASE_IN_OUT)
	pulse.tween_property(orb, "scale", Vector3(0.95, 0.95, 0.95), 1.4).set_ease(Tween.EASE_IN_OUT)
	# Name billboard
	var label: Label3D = Label3D.new()
	label.text = "Sage"
	label.position = Vector3(0, 2.95, 0)
	label.modulate = Color(0.85, 0.55, 1.0)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 18
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	sage.add_child(label)


func _build_d3_echo_wraith(geom: Node) -> void:
	## Epic-3 T25: an echo wraith — wider thinner enemy than the wisps,
	## with a cloak-like trailing form, glowing white face, slow patrol.
	var wraith: Node3D = Node3D.new()
	wraith.name = "D3EchoWraith"
	wraith.position = D3_CENTER + Vector3(-15, 0, -8)
	geom.add_child(wraith)
	# Translucent body capsule
	var bmat: StandardMaterial3D = StandardMaterial3D.new()
	bmat.albedo_color = Color(0.30, 0.10, 0.40, 0.55)
	bmat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	bmat.emission_enabled = true
	bmat.emission = Color(0.85, 0.40, 1.0)
	bmat.emission_energy_multiplier = 1.4
	bmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var body: MeshInstance3D = MeshInstance3D.new()
	var bmesh: CapsuleMesh = CapsuleMesh.new()
	bmesh.radius = 0.55
	bmesh.height = 1.85
	body.mesh = bmesh
	body.position = Vector3(0, 1.20, 0)
	body.material_override = bmat
	wraith.add_child(body)
	# Trailing skirt — wider box at the bottom
	var skirt: MeshInstance3D = MeshInstance3D.new()
	var sm: PrismMesh = PrismMesh.new()
	sm.size = Vector3(1.40, 1.20, 1.40)
	skirt.mesh = sm
	skirt.position = Vector3(0, 0.60, 0)
	skirt.rotation = Vector3(deg_to_rad(180), 0, 0)
	skirt.material_override = bmat
	wraith.add_child(skirt)
	# Glowing white face — single big oval
	var face: MeshInstance3D = MeshInstance3D.new()
	var fm: SphereMesh = SphereMesh.new()
	fm.radius = 0.30
	fm.height = 0.55
	face.mesh = fm
	face.position = Vector3(0, 1.85, 0.30)
	var fmat: StandardMaterial3D = StandardMaterial3D.new()
	fmat.albedo_color = Color(1, 1, 1)
	fmat.emission_enabled = true
	fmat.emission = Color(1, 1, 1)
	fmat.emission_energy_multiplier = 3.4
	fmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	face.material_override = fmat
	wraith.add_child(face)
	# Pulse the face
	var pulse: Tween = create_tween().set_loops()
	pulse.tween_property(fmat, "emission_energy_multiplier", 4.5, 0.85).set_ease(Tween.EASE_IN_OUT)
	pulse.tween_property(fmat, "emission_energy_multiplier", 2.2, 0.85).set_ease(Tween.EASE_IN_OUT)
	# Slow drift patrol
	var origin: Vector3 = D3_CENTER + Vector3(-15, 0, -8)
	var drift: Tween = create_tween().set_loops()
	drift.tween_property(wraith, "position", origin + Vector3(6, 0, 4), 8.0).set_ease(Tween.EASE_IN_OUT)
	drift.tween_property(wraith, "position", origin + Vector3(0, 0, 8), 8.0).set_ease(Tween.EASE_IN_OUT)
	drift.tween_property(wraith, "position", origin, 8.0).set_ease(Tween.EASE_IN_OUT)
	# Boss-tier name billboard
	var label: Label3D = Label3D.new()
	label.text = "ECHO WRAITH"
	label.position = Vector3(0, 2.85, 0)
	label.modulate = Color(0.85, 0.55, 1.0)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 18
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	wraith.add_child(label)


func _build_d3_rune_decals(geom: Node) -> void:
	## Epic-3 T26: 4 small rune circle decals on the D3 floor scattered
	## across the district. Each is a flat torus with 8 small dots inside.
	var positions: Array[Vector3] = [
		D3_CENTER + Vector3(-12, 0.06, 4),
		D3_CENTER + Vector3(8, 0.06, -4),
		D3_CENTER + Vector3(-6, 0.06, -10),
		D3_CENTER + Vector3(12, 0.06, 10),
	]
	var rune_mat: StandardMaterial3D = StandardMaterial3D.new()
	rune_mat.albedo_color = Color(0.85, 0.40, 1.0)
	rune_mat.emission_enabled = true
	rune_mat.emission = Color(1.0, 0.55, 1.0)
	rune_mat.emission_energy_multiplier = 1.6
	rune_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for i in positions.size():
		var decal: Node3D = Node3D.new()
		decal.name = "D3RuneDecal_%d" % i
		decal.position = positions[i]
		geom.add_child(decal)
		# Outer ring
		var ring: MeshInstance3D = MeshInstance3D.new()
		var rmesh: TorusMesh = TorusMesh.new()
		rmesh.inner_radius = 0.85
		rmesh.outer_radius = 1.0
		ring.mesh = rmesh
		ring.material_override = rune_mat
		decal.add_child(ring)
		# 8 small dots inside
		for d in 8:
			var angle: float = (float(d) / 8.0) * TAU
			var dot: MeshInstance3D = MeshInstance3D.new()
			var dm: SphereMesh = SphereMesh.new()
			dm.radius = 0.10
			dm.height = 0.20
			dot.mesh = dm
			dot.position = Vector3(cos(angle) * 0.55, 0.05, sin(angle) * 0.55)
			dot.material_override = rune_mat
			decal.add_child(dot)
		# Slow rotation
		var spin: Tween = create_tween().set_loops()
		spin.tween_property(decal, "rotation:y", TAU * (1 if i % 2 == 0 else -1), 14.0 + i * 2)


func _build_d3_sealed_gates(geom: Node) -> void:
	## Epic-3 T27: sealed vault gates landmark — 2 huge stone double doors
	## with a glowing rune seal across the middle. Looks like a quest hook
	## but is purely decorative.
	var gates: Node3D = Node3D.new()
	gates.name = "D3SealedGates"
	gates.position = D3_CENTER + Vector3(20, 0, 0)
	geom.add_child(gates)
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.16, 0.10, 0.20)
	stone_mat.metallic = 0.55
	stone_mat.roughness = 0.45
	# Frame around the doors
	for sx: float in [-2.40, 2.40]:
		var frame: MeshInstance3D = MeshInstance3D.new()
		var fm: BoxMesh = BoxMesh.new()
		fm.size = Vector3(0.55, 6.0, 1.20)
		frame.mesh = fm
		frame.position = Vector3(sx, 3.0, 0)
		frame.material_override = stone_mat
		gates.add_child(frame)
		# Collision per side
		var sb: StaticBody3D = StaticBody3D.new()
		var cs: CollisionShape3D = CollisionShape3D.new()
		var cb: BoxShape3D = BoxShape3D.new()
		cb.size = Vector3(0.55, 6.0, 1.20)
		cs.shape = cb
		cs.position = Vector3(sx, 3.0, 0)
		sb.add_child(cs)
		gates.add_child(sb)
	# Top frame
	var top: MeshInstance3D = MeshInstance3D.new()
	var tm: BoxMesh = BoxMesh.new()
	tm.size = Vector3(5.40, 0.55, 1.20)
	top.mesh = tm
	top.position = Vector3(0, 6.30, 0)
	top.material_override = stone_mat
	gates.add_child(top)
	# 2 door slabs
	var door_mat: StandardMaterial3D = StandardMaterial3D.new()
	door_mat.albedo_color = Color(0.04, 0.02, 0.08)
	door_mat.metallic = 0.85
	door_mat.roughness = 0.30
	door_mat.emission_enabled = true
	door_mat.emission = Color(0.85, 0.40, 1.0)
	door_mat.emission_energy_multiplier = 0.30
	for sx: float in [-1.10, 1.10]:
		var door: MeshInstance3D = MeshInstance3D.new()
		var dm: BoxMesh = BoxMesh.new()
		dm.size = Vector3(2.0, 5.5, 0.30)
		door.mesh = dm
		door.position = Vector3(sx, 2.85, 0)
		door.material_override = door_mat
		gates.add_child(door)
		# Door collision
		var sb: StaticBody3D = StaticBody3D.new()
		var cs: CollisionShape3D = CollisionShape3D.new()
		var cb: BoxShape3D = BoxShape3D.new()
		cb.size = Vector3(2.0, 5.5, 0.30)
		cs.shape = cb
		cs.position = Vector3(sx, 2.85, 0)
		sb.add_child(cs)
		gates.add_child(sb)
	# Glowing rune seal across the middle (a circle of 12 small emissive spheres)
	for i in 12:
		var angle: float = (float(i) / 12.0) * TAU
		var rune: MeshInstance3D = MeshInstance3D.new()
		var rmesh: SphereMesh = SphereMesh.new()
		rmesh.radius = 0.12
		rmesh.height = 0.24
		rune.mesh = rmesh
		rune.position = Vector3(cos(angle) * 0.85, 2.85, 0.16)
		var rmat: StandardMaterial3D = StandardMaterial3D.new()
		rmat.albedo_color = Color(1.0, 0.55, 1.0)
		rmat.emission_enabled = true
		rmat.emission = Color(1.0, 0.55, 1.0)
		rmat.emission_energy_multiplier = 2.6
		rmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		rune.material_override = rmat
		gates.add_child(rune)
	# Center seal sphere — bigger
	var seal: MeshInstance3D = MeshInstance3D.new()
	var sm: SphereMesh = SphereMesh.new()
	sm.radius = 0.30
	sm.height = 0.60
	seal.mesh = sm
	seal.position = Vector3(0, 2.85, 0.16)
	var smat: StandardMaterial3D = StandardMaterial3D.new()
	smat.albedo_color = Color(1.0, 0.55, 1.0)
	smat.emission_enabled = true
	smat.emission = Color(1.0, 0.55, 1.0)
	smat.emission_energy_multiplier = 3.4
	smat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	seal.material_override = smat
	gates.add_child(seal)
	# Pulse the seal
	var pulse: Tween = create_tween().set_loops()
	pulse.tween_property(seal, "scale", Vector3(1.30, 1.30, 1.30), 1.6).set_ease(Tween.EASE_IN_OUT)
	pulse.tween_property(seal, "scale", Vector3(0.85, 0.85, 0.85), 1.6).set_ease(Tween.EASE_IN_OUT)
	# Sign
	var label: Label3D = Label3D.new()
	label.text = "SEALED VAULT"
	label.position = Vector3(0, 7.0, 0)
	label.modulate = Color(1.0, 0.55, 1.0)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 18
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	gates.add_child(label)


func _build_d3_data_spirits(geom: Node) -> void:
	## Epic-3 T28: 8 floating data spirits orbiting in a circle overhead
	## around the great crystal — small translucent ghost figures.
	var spirit_mat: StandardMaterial3D = StandardMaterial3D.new()
	spirit_mat.albedo_color = Color(0.85, 0.55, 1.0, 0.55)
	spirit_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	spirit_mat.emission_enabled = true
	spirit_mat.emission = Color(1.0, 0.55, 1.0)
	spirit_mat.emission_energy_multiplier = 1.8
	spirit_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	# Pivot for orbital rotation
	var orbit_pivot: Node3D = Node3D.new()
	orbit_pivot.name = "D3DataSpiritsPivot"
	orbit_pivot.position = D3_CENTER + Vector3(0, 9, 0)
	geom.add_child(orbit_pivot)
	for i in 8:
		var angle: float = (float(i) / 8.0) * TAU
		var spirit: Node3D = Node3D.new()
		spirit.name = "D3DataSpirit_%d" % i
		spirit.position = Vector3(cos(angle) * 6.0, randf_range(-0.5, 0.5), sin(angle) * 6.0)
		orbit_pivot.add_child(spirit)
		# Body capsule
		var body: MeshInstance3D = MeshInstance3D.new()
		var bm: CapsuleMesh = CapsuleMesh.new()
		bm.radius = 0.20
		bm.height = 0.65
		body.mesh = bm
		body.material_override = spirit_mat
		spirit.add_child(body)
		# Single eye
		var eye: MeshInstance3D = MeshInstance3D.new()
		var em: SphereMesh = SphereMesh.new()
		em.radius = 0.08
		em.height = 0.16
		eye.mesh = em
		eye.position = Vector3(0, 0.30, 0)
		var emat: StandardMaterial3D = StandardMaterial3D.new()
		emat.albedo_color = Color(1, 1, 1)
		emat.emission_enabled = true
		emat.emission = Color(1, 1, 1)
		emat.emission_energy_multiplier = 2.6
		emat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		eye.material_override = emat
		spirit.add_child(eye)
	# Rotate the entire pivot
	var spin: Tween = create_tween().set_loops()
	spin.tween_property(orbit_pivot, "rotation:y", TAU, 16.0)


func _build_d3_oracle_npc(town: Node) -> void:
	## Epic-3 T29: Oracle NPC sitting on a small plinth in front of the
	## sealed gates with a glowing crystal ball floating in front of them.
	## Hooded with no visible face, just glowing eyes inside the hood.
	var slots: Node3D = town.get_node_or_null("%NPCSlots") as Node3D
	if slots == null:
		return
	var oracle: Node3D = Node3D.new()
	oracle.name = "D3Oracle"
	oracle.position = D3_CENTER + Vector3(16, 0, 0)
	slots.add_child(oracle)
	# Plinth
	var plinth_mat: StandardMaterial3D = StandardMaterial3D.new()
	plinth_mat.albedo_color = Color(0.16, 0.10, 0.20)
	plinth_mat.metallic = 0.55
	plinth_mat.roughness = 0.45
	var plinth: MeshInstance3D = MeshInstance3D.new()
	var pm: CylinderMesh = CylinderMesh.new()
	pm.top_radius = 0.55
	pm.bottom_radius = 0.65
	pm.height = 0.55
	plinth.mesh = pm
	plinth.position = Vector3(0, 0.27, 0)
	plinth.material_override = plinth_mat
	oracle.add_child(plinth)
	# Body — capsule sitting on plinth
	var bmat: StandardMaterial3D = StandardMaterial3D.new()
	bmat.albedo_color = Color(0.16, 0.10, 0.24)
	bmat.metallic = 0.20
	bmat.roughness = 0.65
	bmat.emission_enabled = true
	bmat.emission = Color(0.55, 0.30, 0.85)
	bmat.emission_energy_multiplier = 0.40
	var body: MeshInstance3D = MeshInstance3D.new()
	var bmesh: CapsuleMesh = CapsuleMesh.new()
	bmesh.radius = 0.40
	bmesh.height = 0.85
	body.mesh = bmesh
	body.position = Vector3(0, 1.0, 0)
	body.material_override = bmat
	oracle.add_child(body)
	# Wide deep hood
	var hood: MeshInstance3D = MeshInstance3D.new()
	var hm: SphereMesh = SphereMesh.new()
	hm.radius = 0.50
	hm.height = 0.65
	hood.mesh = hm
	hood.position = Vector3(0, 1.85, 0)
	hood.material_override = bmat
	oracle.add_child(hood)
	# 2 small bright violet eyes inside hood shadow
	var eye_mat: StandardMaterial3D = StandardMaterial3D.new()
	eye_mat.albedo_color = Color(1.0, 0.55, 1.0)
	eye_mat.emission_enabled = true
	eye_mat.emission = Color(1.0, 0.55, 1.0)
	eye_mat.emission_energy_multiplier = 3.4
	eye_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for ex: float in [-0.10, 0.10]:
		var eye: MeshInstance3D = MeshInstance3D.new()
		var em: SphereMesh = SphereMesh.new()
		em.radius = 0.06
		em.height = 0.12
		eye.mesh = em
		eye.position = Vector3(ex, 1.80, 0.30)
		eye.material_override = eye_mat
		oracle.add_child(eye)
	# Floating crystal ball in front
	var ball: MeshInstance3D = MeshInstance3D.new()
	var bm2: SphereMesh = SphereMesh.new()
	bm2.radius = 0.30
	bm2.height = 0.60
	ball.mesh = bm2
	ball.position = Vector3(0, 1.40, 0.65)
	var ball_mat: StandardMaterial3D = StandardMaterial3D.new()
	ball_mat.albedo_color = Color(0.85, 0.55, 1.0, 0.55)
	ball_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	ball_mat.emission_enabled = true
	ball_mat.emission = Color(1.0, 0.55, 1.0)
	ball_mat.emission_energy_multiplier = 2.4
	ball_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	ball.material_override = ball_mat
	oracle.add_child(ball)
	# Bob the ball
	var bob: Tween = create_tween().set_loops()
	bob.tween_property(ball, "position:y", 1.65, 1.4).set_ease(Tween.EASE_IN_OUT)
	bob.tween_property(ball, "position:y", 1.40, 1.4).set_ease(Tween.EASE_IN_OUT)
	# Name billboard
	var label: Label3D = Label3D.new()
	label.text = "Oracle"
	label.position = Vector3(0, 2.65, 0)
	label.modulate = Color(1.0, 0.55, 1.0)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 18
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	oracle.add_child(label)


func _build_d3_violet_mist(geom: Node) -> void:
	## Epic-3 T30: ambient violet mist drifting low across the district —
	## 80 large translucent violet puff particles slowly moving north.
	var mist: GPUParticles3D = GPUParticles3D.new()
	mist.name = "D3VioletMist"
	mist.position = D3_CENTER + Vector3(0, 1.0, -20)
	mist.amount = 80
	mist.lifetime = 12.0
	mist.preprocess = 6.0
	var pmat: ParticleProcessMaterial = ParticleProcessMaterial.new()
	pmat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	pmat.emission_box_extents = Vector3(28, 0.5, 0.5)
	pmat.direction = Vector3(0, 0, 1)
	pmat.spread = 6.0
	pmat.initial_velocity_min = 0.45
	pmat.initial_velocity_max = 0.85
	pmat.gravity = Vector3.ZERO
	pmat.scale_min = 0.85
	pmat.scale_max = 1.40
	pmat.color = Color(0.85, 0.40, 1.0, 0.20)
	mist.process_material = pmat
	var puff: SphereMesh = SphereMesh.new()
	puff.radius = 0.85
	puff.height = 1.70
	var puff_mat: StandardMaterial3D = StandardMaterial3D.new()
	puff_mat.albedo_color = Color(0.85, 0.40, 1.0, 0.20)
	puff_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	puff_mat.emission_enabled = true
	puff_mat.emission = Color(1.0, 0.55, 1.0)
	puff_mat.emission_energy_multiplier = 0.55
	puff_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	puff.material = puff_mat
	mist.draw_pass_1 = puff
	geom.add_child(mist)


func _build_d3_floating_arches(geom: Node) -> void:
	## Epic-3 T31: 3 floating ancient archways drifting overhead at
	## different altitudes — small free-floating arches like portal
	## fragments suspended in the air.
	var positions: Array[Vector3] = [
		D3_CENTER + Vector3(-15, 6.0, 8),
		D3_CENTER + Vector3(0, 8.5, -10),
		D3_CENTER + Vector3(15, 7.0, 6),
	]
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.16, 0.10, 0.20)
	stone_mat.metallic = 0.55
	stone_mat.roughness = 0.45
	stone_mat.emission_enabled = true
	stone_mat.emission = Color(0.85, 0.40, 1.0)
	stone_mat.emission_energy_multiplier = 0.40
	for i in positions.size():
		var arch: Node3D = Node3D.new()
		arch.name = "D3FloatingArch_%d" % i
		arch.position = positions[i]
		arch.rotation = Vector3(deg_to_rad(randf_range(-15, 15)), deg_to_rad(randf_range(0, 360)), deg_to_rad(randf_range(-15, 15)))
		geom.add_child(arch)
		# 2 side pillars
		for sx: float in [-1.20, 1.20]:
			var pillar: MeshInstance3D = MeshInstance3D.new()
			var pmesh: BoxMesh = BoxMesh.new()
			pmesh.size = Vector3(0.40, 2.40, 0.40)
			pillar.mesh = pmesh
			pillar.position = Vector3(sx, 0, 0)
			pillar.material_override = stone_mat
			arch.add_child(pillar)
		# Top crossbar
		var top: MeshInstance3D = MeshInstance3D.new()
		var tm: BoxMesh = BoxMesh.new()
		tm.size = Vector3(2.85, 0.40, 0.40)
		top.mesh = tm
		top.position = Vector3(0, 1.40, 0)
		top.material_override = stone_mat
		arch.add_child(top)
		# Bob tween
		var origin: Vector3 = positions[i]
		var bob: Tween = create_tween().set_loops()
		bob.tween_property(arch, "position:y", origin.y + 0.55, 2.4 + i * 0.3).set_ease(Tween.EASE_IN_OUT)
		bob.tween_property(arch, "position:y", origin.y, 2.4 + i * 0.3).set_ease(Tween.EASE_IN_OUT)
		# Slow rotation
		var spin: Tween = create_tween().set_loops()
		spin.tween_property(arch, "rotation:y", arch.rotation.y + TAU, 18.0)


func _build_d3_battle_scars(geom: Node) -> void:
	## Epic-3 T32: scattered broken stone fragments across the D3 floor —
	## 10 small angled stone shards suggesting an ancient battle.
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 144
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.18, 0.13, 0.22)
	stone_mat.metallic = 0.40
	stone_mat.roughness = 0.65
	for i in 10:
		var fragment: MeshInstance3D = MeshInstance3D.new()
		fragment.name = "D3BattleFragment_%d" % i
		var fmesh: BoxMesh = BoxMesh.new()
		fmesh.size = Vector3(rng.randf_range(0.30, 0.85), rng.randf_range(0.20, 0.55), rng.randf_range(0.30, 0.85))
		fragment.mesh = fmesh
		fragment.position = D3_CENTER + Vector3(
			rng.randf_range(-22, 22),
			0.10,
			rng.randf_range(-16, 16)
		)
		fragment.rotation = Vector3(
			deg_to_rad(rng.randf_range(-30, 30)),
			deg_to_rad(rng.randf_range(0, 360)),
			deg_to_rad(rng.randf_range(-30, 30))
		)
		fragment.material_override = stone_mat
		geom.add_child(fragment)


func _build_d3_memory_obelisks(geom: Node) -> void:
	## Epic-3 T33: 3 tall memory obelisks — narrow stone prisms with
	## glowing rune lines down each face. Sentinel-like landmarks placed
	## at the edges of the district.
	var positions: Array[Vector3] = [
		D3_CENTER + Vector3(-15, 0, -16),
		D3_CENTER + Vector3(0, 0, -18),
		D3_CENTER + Vector3(15, 0, -16),
	]
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.10, 0.06, 0.18)
	stone_mat.metallic = 0.55
	stone_mat.roughness = 0.45
	for i in positions.size():
		var obelisk: Node3D = Node3D.new()
		obelisk.name = "D3MemoryObelisk_%d" % i
		obelisk.position = positions[i]
		geom.add_child(obelisk)
		# Tapered prism — taller than wide
		var body: MeshInstance3D = MeshInstance3D.new()
		var bmesh: PrismMesh = PrismMesh.new()
		bmesh.size = Vector3(0.85, 5.0, 0.85)
		body.mesh = bmesh
		body.position = Vector3(0, 2.50, 0)
		body.material_override = stone_mat
		obelisk.add_child(body)
		# Glowing rune line down the front face
		var line: MeshInstance3D = MeshInstance3D.new()
		var lm: BoxMesh = BoxMesh.new()
		lm.size = Vector3(0.04, 4.0, 0.06)
		line.mesh = lm
		line.position = Vector3(0, 2.50, 0.40)
		var lmat: StandardMaterial3D = StandardMaterial3D.new()
		lmat.albedo_color = Color(0.85, 0.40, 1.0)
		lmat.emission_enabled = true
		lmat.emission = Color(1.0, 0.55, 1.0)
		lmat.emission_energy_multiplier = 1.8
		lmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		line.material_override = lmat
		obelisk.add_child(line)
		# Top crowning gem
		var gem: MeshInstance3D = MeshInstance3D.new()
		var gm: SphereMesh = SphereMesh.new()
		gm.radius = 0.22
		gm.height = 0.44
		gem.mesh = gm
		gem.position = Vector3(0, 5.20, 0)
		var gmat: StandardMaterial3D = StandardMaterial3D.new()
		gmat.albedo_color = Color(0.85, 0.40, 1.0)
		gmat.emission_enabled = true
		gmat.emission = Color(1.0, 0.55, 1.0)
		gmat.emission_energy_multiplier = 2.6
		gmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		gem.material_override = gmat
		obelisk.add_child(gem)
		# Pulse the gem
		var pulse: Tween = create_tween().set_loops()
		pulse.tween_property(gem, "scale", Vector3(1.30, 1.30, 1.30), 1.4 + i * 0.2).set_ease(Tween.EASE_IN_OUT)
		pulse.tween_property(gem, "scale", Vector3(0.85, 0.85, 0.85), 1.4 + i * 0.2).set_ease(Tween.EASE_IN_OUT)
		# Collision per obelisk
		var sb: StaticBody3D = StaticBody3D.new()
		var cs: CollisionShape3D = CollisionShape3D.new()
		var cb: BoxShape3D = BoxShape3D.new()
		cb.size = Vector3(0.85, 5.0, 0.85)
		cs.shape = cb
		cs.position = Vector3(0, 2.50, 0)
		sb.add_child(cs)
		obelisk.add_child(sb)


func _build_d3_phantom_warrior_npc(town: Node) -> void:
	## Epic-3 T34: Phantom Warrior NPC — a translucent ghost of a fallen
	## warrior with armor outline + a translucent sword. Stands at attention.
	var slots: Node3D = town.get_node_or_null("%NPCSlots") as Node3D
	if slots == null:
		return
	var phantom: Node3D = Node3D.new()
	phantom.name = "D3PhantomWarrior"
	phantom.position = D3_CENTER + Vector3(-8, 0, -16)
	slots.add_child(phantom)
	# Translucent body
	var bmat: StandardMaterial3D = StandardMaterial3D.new()
	bmat.albedo_color = Color(0.55, 0.95, 1.0, 0.45)
	bmat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	bmat.emission_enabled = true
	bmat.emission = Color(0.55, 0.95, 1.0)
	bmat.emission_energy_multiplier = 1.4
	bmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var body: MeshInstance3D = MeshInstance3D.new()
	var bmesh: CapsuleMesh = CapsuleMesh.new()
	bmesh.radius = 0.45
	bmesh.height = 1.40
	body.mesh = bmesh
	body.position = Vector3(0, 0.70, 0)
	body.material_override = bmat
	phantom.add_child(body)
	# Helmet — narrow box
	var helmet: MeshInstance3D = MeshInstance3D.new()
	var hm: BoxMesh = BoxMesh.new()
	hm.size = Vector3(0.55, 0.65, 0.55)
	helmet.mesh = hm
	helmet.position = Vector3(0, 1.65, 0)
	helmet.material_override = bmat
	phantom.add_child(helmet)
	# 2 white slit eyes
	var eye_mat: StandardMaterial3D = StandardMaterial3D.new()
	eye_mat.albedo_color = Color(1, 1, 1)
	eye_mat.emission_enabled = true
	eye_mat.emission = Color(1, 1, 1)
	eye_mat.emission_energy_multiplier = 3.0
	eye_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for ex: float in [-0.10, 0.10]:
		var eye: MeshInstance3D = MeshInstance3D.new()
		var em: BoxMesh = BoxMesh.new()
		em.size = Vector3(0.10, 0.04, 0.04)
		eye.mesh = em
		eye.position = Vector3(ex, 1.65, 0.30)
		eye.material_override = eye_mat
		phantom.add_child(eye)
	# Translucent sword held vertically in front
	var sword: MeshInstance3D = MeshInstance3D.new()
	var sm: BoxMesh = BoxMesh.new()
	sm.size = Vector3(0.10, 1.85, 0.04)
	sword.mesh = sm
	sword.position = Vector3(0.30, 1.0, 0.40)
	sword.material_override = bmat
	phantom.add_child(sword)
	# Slow flicker visibility for ghost feel
	var flicker: Tween = create_tween().set_loops()
	flicker.tween_property(bmat, "emission_energy_multiplier", 2.4, 1.4).set_ease(Tween.EASE_IN_OUT)
	flicker.tween_property(bmat, "emission_energy_multiplier", 0.85, 1.4).set_ease(Tween.EASE_IN_OUT)
	# Name billboard
	var label: Label3D = Label3D.new()
	label.text = "Phantom Warrior"
	label.position = Vector3(0, 2.30, 0)
	label.modulate = Color(0.55, 0.95, 1.0)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 18
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	phantom.add_child(label)


func _build_d3_illusion_bridge(geom: Node) -> void:
	## Epic-3 T35: a short illusion bridge — 6 floating tile platforms in
	## a row that fade in/out on independent flickers, suggesting "the
	## bridge only appears for the worthy".
	var bridge: Node3D = Node3D.new()
	bridge.name = "D3IllusionBridge"
	bridge.position = D3_CENTER + Vector3(0, 0.55, 16)
	geom.add_child(bridge)
	for i in 6:
		var tile: MeshInstance3D = MeshInstance3D.new()
		tile.name = "D3BridgeTile_%d" % i
		var tmesh: BoxMesh = BoxMesh.new()
		tmesh.size = Vector3(1.40, 0.10, 1.40)
		tile.mesh = tmesh
		tile.position = Vector3(-3.5 + i * 1.40, 0, 0)
		var tmat: StandardMaterial3D = StandardMaterial3D.new()
		tmat.albedo_color = Color(0.85, 0.40, 1.0, 0.55)
		tmat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		tmat.emission_enabled = true
		tmat.emission = Color(1.0, 0.55, 1.0)
		tmat.emission_energy_multiplier = 1.6
		tmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		tile.material_override = tmat
		bridge.add_child(tile)
		# Fade visibility on independent timings
		var flicker: Tween = create_tween().set_loops()
		flicker.tween_interval(i * 0.30)
		flicker.tween_property(tile, "visible", false, 0.0)
		flicker.tween_interval(0.20)
		flicker.tween_property(tile, "visible", true, 0.0)
		flicker.tween_interval(2.0 - i * 0.20)
	# Sign
	var label: Label3D = Label3D.new()
	label.text = "ILLUSION BRIDGE"
	label.position = Vector3(0, 1.20, 0)
	label.modulate = Color(1.0, 0.55, 1.0)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 16
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	bridge.add_child(label)


func _build_d3_levitating_runes(geom: Node) -> void:
	## Epic-3 T36: 12 levitating glowing rune cubes orbiting horizontally
	## around the great crystal at chest height. Pivot rotation tween.
	var pivot: Node3D = Node3D.new()
	pivot.name = "D3LevitatingRunes"
	pivot.position = D3_CENTER + Vector3(0, 1.40, 0)
	geom.add_child(pivot)
	for i in 12:
		var angle: float = (float(i) / 12.0) * TAU
		var rune: MeshInstance3D = MeshInstance3D.new()
		rune.name = "Rune_%d" % i
		var rmesh: BoxMesh = BoxMesh.new()
		rmesh.size = Vector3(0.18, 0.18, 0.18)
		rune.mesh = rmesh
		rune.position = Vector3(cos(angle) * 5.0, 0, sin(angle) * 5.0)
		var rmat: StandardMaterial3D = StandardMaterial3D.new()
		rmat.albedo_color = Color(0.85, 0.40, 1.0)
		rmat.emission_enabled = true
		rmat.emission = Color(1.0, 0.55, 1.0)
		rmat.emission_energy_multiplier = 2.4
		rmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		rune.material_override = rmat
		pivot.add_child(rune)
	# Rotate the entire pivot
	var spin: Tween = create_tween().set_loops()
	spin.tween_property(pivot, "rotation:y", TAU, 12.0)


func _build_d3_observatory_dome(geom: Node) -> void:
	## Epic-3 T37: an ancient observatory dome — large hemisphere on a
	## stone base with a slit opening + a small telescope poking out.
	var dome: Node3D = Node3D.new()
	dome.name = "D3ObservatoryDome"
	dome.position = D3_CENTER + Vector3(-20, 0, -16)
	geom.add_child(dome)
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.16, 0.10, 0.20)
	stone_mat.metallic = 0.55
	stone_mat.roughness = 0.45
	# Cylinder base
	var base: MeshInstance3D = MeshInstance3D.new()
	var bm: CylinderMesh = CylinderMesh.new()
	bm.top_radius = 1.85
	bm.bottom_radius = 2.0
	bm.height = 2.40
	base.mesh = bm
	base.position = Vector3(0, 1.20, 0)
	base.material_override = stone_mat
	dome.add_child(base)
	# Hemispherical dome roof
	var roof: MeshInstance3D = MeshInstance3D.new()
	var rmesh: SphereMesh = SphereMesh.new()
	rmesh.radius = 1.85
	rmesh.height = 1.85
	roof.mesh = rmesh
	roof.position = Vector3(0, 2.40, 0)
	roof.scale = Vector3(1.0, 0.5, 1.0)
	roof.material_override = stone_mat
	dome.add_child(roof)
	# Telescope poking out at an angle (cylinder)
	var scope_mat: StandardMaterial3D = StandardMaterial3D.new()
	scope_mat.albedo_color = Color(0.10, 0.13, 0.18)
	scope_mat.metallic = 0.85
	scope_mat.roughness = 0.30
	var scope: MeshInstance3D = MeshInstance3D.new()
	var smesh: CylinderMesh = CylinderMesh.new()
	smesh.top_radius = 0.18
	smesh.bottom_radius = 0.20
	smesh.height = 1.85
	scope.mesh = smesh
	scope.position = Vector3(0.55, 3.0, 0.55)
	scope.rotation = Vector3(deg_to_rad(60), deg_to_rad(45), 0)
	scope.material_override = scope_mat
	dome.add_child(scope)
	# Glowing telescope tip lens
	var lens: MeshInstance3D = MeshInstance3D.new()
	var lmesh: SphereMesh = SphereMesh.new()
	lmesh.radius = 0.20
	lmesh.height = 0.40
	lens.mesh = lmesh
	lens.position = Vector3(1.10, 3.55, 1.10)
	var lmat: StandardMaterial3D = StandardMaterial3D.new()
	lmat.albedo_color = Color(0.55, 0.95, 1.0)
	lmat.emission_enabled = true
	lmat.emission = Color(0.55, 0.95, 1.0)
	lmat.emission_energy_multiplier = 2.6
	lmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	lens.material_override = lmat
	dome.add_child(lens)
	# Sign
	var label: Label3D = Label3D.new()
	label.text = "OBSERVATORY"
	label.position = Vector3(0, 4.65, 0)
	label.modulate = Color(0.55, 0.95, 1.0)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 18
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	dome.add_child(label)
	# Collision around the building
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(4.0, 4.0, 4.0)
	cs.shape = cb
	cs.position = Vector3(0, 2.0, 0)
	sb.add_child(cs)
	dome.add_child(sb)


func _build_d3_portal_pad(geom: Node) -> void:
	## Epic-3 T38: portal pad — circular dais on the ground with 4
	## upright energy beams forming a square gate, slowly rotating.
	var portal: Node3D = Node3D.new()
	portal.name = "D3PortalPad"
	portal.position = D3_CENTER + Vector3(20, 0, 12)
	geom.add_child(portal)
	# Stone dais
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.16, 0.10, 0.20)
	stone_mat.metallic = 0.55
	stone_mat.roughness = 0.45
	var dais: MeshInstance3D = MeshInstance3D.new()
	var dm: CylinderMesh = CylinderMesh.new()
	dm.top_radius = 1.85
	dm.bottom_radius = 2.0
	dm.height = 0.30
	dais.mesh = dm
	dais.position = Vector3(0, 0.15, 0)
	dais.material_override = stone_mat
	portal.add_child(dais)
	# Inner glowing disc
	var disc: MeshInstance3D = MeshInstance3D.new()
	var disc_mesh: CylinderMesh = CylinderMesh.new()
	disc_mesh.top_radius = 1.55
	disc_mesh.bottom_radius = 1.55
	disc_mesh.height = 0.06
	disc.mesh = disc_mesh
	disc.position = Vector3(0, 0.32, 0)
	var disc_mat: StandardMaterial3D = StandardMaterial3D.new()
	disc_mat.albedo_color = Color(0.85, 0.40, 1.0)
	disc_mat.emission_enabled = true
	disc_mat.emission = Color(1.0, 0.55, 1.0)
	disc_mat.emission_energy_multiplier = 2.4
	disc_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	disc.material_override = disc_mat
	portal.add_child(disc)
	# Beam pivot — 4 upright beams that rotate around the center
	var beam_pivot: Node3D = Node3D.new()
	portal.add_child(beam_pivot)
	for i in 4:
		var angle: float = (float(i) / 4.0) * TAU
		var beam: MeshInstance3D = MeshInstance3D.new()
		var bmesh: BoxMesh = BoxMesh.new()
		bmesh.size = Vector3(0.18, 3.40, 0.18)
		beam.mesh = bmesh
		beam.position = Vector3(cos(angle) * 1.40, 1.85, sin(angle) * 1.40)
		var bmat: StandardMaterial3D = StandardMaterial3D.new()
		bmat.albedo_color = Color(0.85, 0.40, 1.0)
		bmat.emission_enabled = true
		bmat.emission = Color(1.0, 0.55, 1.0)
		bmat.emission_energy_multiplier = 3.0
		bmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		beam.material_override = bmat
		beam_pivot.add_child(beam)
	# Rotate the beam pivot
	var spin: Tween = create_tween().set_loops()
	spin.tween_property(beam_pivot, "rotation:y", TAU, 8.0)
	# Real OmniLight inside
	var light: OmniLight3D = OmniLight3D.new()
	light.position = Vector3(0, 1.85, 0)
	light.light_color = Color(1.0, 0.55, 1.0)
	light.light_energy = 2.4
	light.omni_range = 8.0
	portal.add_child(light)
	# Sign
	var label: Label3D = Label3D.new()
	label.text = "PORTAL PAD"
	label.position = Vector3(0, 4.0, 0)
	label.modulate = Color(1.0, 0.55, 1.0)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 16
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	portal.add_child(label)


func _build_d3_ritualist_npc(town: Node) -> void:
	## Epic-3 T39: Ritualist NPC standing by the ritual circle with arms
	## outstretched, casting a spell. Has glowing palms and a tall hat.
	var slots: Node3D = town.get_node_or_null("%NPCSlots") as Node3D
	if slots == null:
		return
	var rit: Node3D = Node3D.new()
	rit.name = "D3Ritualist"
	rit.position = D3_CENTER + Vector3(0, 0, 4)
	rit.rotation = Vector3(0, deg_to_rad(180), 0)
	slots.add_child(rit)
	# Robed body
	var bmat: StandardMaterial3D = StandardMaterial3D.new()
	bmat.albedo_color = Color(0.20, 0.10, 0.30)
	bmat.metallic = 0.20
	bmat.roughness = 0.65
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
	rit.add_child(body)
	# Tall conical hat (prism)
	var hat: MeshInstance3D = MeshInstance3D.new()
	var hm: PrismMesh = PrismMesh.new()
	hm.size = Vector3(0.55, 0.85, 0.55)
	hat.mesh = hm
	hat.position = Vector3(0, 1.85, 0)
	hat.material_override = bmat
	rit.add_child(hat)
	# 2 violet eyes
	var eye_mat: StandardMaterial3D = StandardMaterial3D.new()
	eye_mat.albedo_color = Color(1.0, 0.55, 1.0)
	eye_mat.emission_enabled = true
	eye_mat.emission = Color(1.0, 0.55, 1.0)
	eye_mat.emission_energy_multiplier = 2.6
	eye_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for ex: float in [-0.10, 0.10]:
		var eye: MeshInstance3D = MeshInstance3D.new()
		var em: SphereMesh = SphereMesh.new()
		em.radius = 0.06
		em.height = 0.12
		eye.mesh = em
		eye.position = Vector3(ex, 1.40, 0.36)
		eye.material_override = eye_mat
		rit.add_child(eye)
	# Outstretched arms with glowing palms
	for sx: float in [-1.0, 1.0]:
		var arm: MeshInstance3D = MeshInstance3D.new()
		var am: BoxMesh = BoxMesh.new()
		am.size = Vector3(0.85, 0.18, 0.18)
		arm.mesh = am
		arm.position = Vector3(sx * 0.65, 0.95, 0.30)
		arm.material_override = bmat
		rit.add_child(arm)
		# Glowing palm sphere
		var palm: MeshInstance3D = MeshInstance3D.new()
		var pm: SphereMesh = SphereMesh.new()
		pm.radius = 0.18
		pm.height = 0.36
		palm.mesh = pm
		palm.position = Vector3(sx * 1.0, 0.95, 0.30)
		var pmat: StandardMaterial3D = StandardMaterial3D.new()
		pmat.albedo_color = Color(1.0, 0.55, 1.0)
		pmat.emission_enabled = true
		pmat.emission = Color(1.0, 0.55, 1.0)
		pmat.emission_energy_multiplier = 3.0
		pmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		palm.material_override = pmat
		rit.add_child(palm)
	# Name billboard
	var label: Label3D = Label3D.new()
	label.text = "Ritualist"
	label.position = Vector3(0, 2.85, 0)
	label.modulate = Color(0.85, 0.55, 1.0)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 18
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	rit.add_child(label)


func _build_d3_violet_braziers(geom: Node) -> void:
	## Epic-3 T40: 4 violet flame braziers at the corners of the great
	## crystal platform — stone bowls with flame particles rising from them.
	var positions: Array[Vector3] = [
		D3_CENTER + Vector3(-3, 0, -3),
		D3_CENTER + Vector3(3, 0, -3),
		D3_CENTER + Vector3(-3, 0, 3),
		D3_CENTER + Vector3(3, 0, 3),
	]
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.16, 0.10, 0.20)
	stone_mat.metallic = 0.55
	stone_mat.roughness = 0.45
	for i in positions.size():
		var brazier: Node3D = Node3D.new()
		brazier.name = "D3Brazier_%d" % i
		brazier.position = positions[i]
		geom.add_child(brazier)
		# Stem column
		var stem: MeshInstance3D = MeshInstance3D.new()
		var sm: CylinderMesh = CylinderMesh.new()
		sm.top_radius = 0.18
		sm.bottom_radius = 0.22
		sm.height = 1.20
		stem.mesh = sm
		stem.position = Vector3(0, 0.60, 0)
		stem.material_override = stone_mat
		brazier.add_child(stem)
		# Bowl on top — wider cylinder
		var bowl: MeshInstance3D = MeshInstance3D.new()
		var bm: CylinderMesh = CylinderMesh.new()
		bm.top_radius = 0.40
		bm.bottom_radius = 0.18
		bm.height = 0.30
		bowl.mesh = bm
		bowl.position = Vector3(0, 1.30, 0)
		bowl.material_override = stone_mat
		brazier.add_child(bowl)
		# Flame particles rising
		var flame: GPUParticles3D = GPUParticles3D.new()
		flame.amount = 30
		flame.lifetime = 1.4
		flame.position = Vector3(0, 1.55, 0)
		var pmat: ParticleProcessMaterial = ParticleProcessMaterial.new()
		pmat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
		pmat.emission_sphere_radius = 0.20
		pmat.direction = Vector3(0, 1, 0)
		pmat.spread = 12.0
		pmat.initial_velocity_min = 1.0
		pmat.initial_velocity_max = 1.85
		pmat.gravity = Vector3.ZERO
		pmat.scale_min = 0.18
		pmat.scale_max = 0.35
		pmat.color = Color(1.0, 0.55, 1.0, 1.0)
		flame.process_material = pmat
		var fm: SphereMesh = SphereMesh.new()
		fm.radius = 0.18
		fm.height = 0.36
		var fmat: StandardMaterial3D = StandardMaterial3D.new()
		fmat.albedo_color = Color(1.0, 0.55, 1.0)
		fmat.emission_enabled = true
		fmat.emission = Color(1.0, 0.55, 1.0)
		fmat.emission_energy_multiplier = 2.6
		fmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		fm.material = fmat
		flame.draw_pass_1 = fm
		brazier.add_child(flame)
		# OmniLight from the brazier
		var light: OmniLight3D = OmniLight3D.new()
		light.position = Vector3(0, 1.65, 0)
		light.light_color = Color(1.0, 0.55, 1.0)
		light.light_energy = 1.4
		light.omni_range = 4.5
		brazier.add_child(light)
		# Collision around brazier
		var sb: StaticBody3D = StaticBody3D.new()
		var cs: CollisionShape3D = CollisionShape3D.new()
		var cap: CapsuleShape3D = CapsuleShape3D.new()
		cap.radius = 0.30
		cap.height = 1.40
		cs.shape = cap
		cs.position = Vector3(0, 0.70, 0)
		sb.add_child(cs)
		brazier.add_child(sb)


func _build_d3_spell_puzzle(geom: Node) -> void:
	## Epic-3 T41: a spell circle puzzle on the ground — 4 colored rune
	## tiles in a square arrangement, each pulsing in a different color.
	## Looks like a "step on these in order" puzzle.
	var puzzle: Node3D = Node3D.new()
	puzzle.name = "D3SpellPuzzle"
	puzzle.position = D3_CENTER + Vector3(-12, 0.06, 14)
	geom.add_child(puzzle)
	# Outer circle frame
	var frame: MeshInstance3D = MeshInstance3D.new()
	var fmesh: TorusMesh = TorusMesh.new()
	fmesh.inner_radius = 1.85
	fmesh.outer_radius = 2.10
	frame.mesh = fmesh
	var fmat: StandardMaterial3D = StandardMaterial3D.new()
	fmat.albedo_color = Color(0.16, 0.10, 0.20)
	fmat.metallic = 0.55
	fmat.roughness = 0.45
	fmat.emission_enabled = true
	fmat.emission = Color(0.85, 0.40, 1.0)
	fmat.emission_energy_multiplier = 0.85
	frame.material_override = fmat
	puzzle.add_child(frame)
	# 4 colored rune tiles
	var tile_specs: Array = [
		[Vector3(-1.0, 0.04, 0), Color(0.55, 0.95, 1.0), "I"],
		[Vector3(1.0, 0.04, 0), Color(1.0, 0.55, 0.20), "II"],
		[Vector3(0, 0.04, -1.0), Color(0.45, 1.0, 0.55), "III"],
		[Vector3(0, 0.04, 1.0), Color(0.85, 0.40, 1.0), "IV"],
	]
	for spec in tile_specs:
		var tile: MeshInstance3D = MeshInstance3D.new()
		var tm: BoxMesh = BoxMesh.new()
		tm.size = Vector3(0.65, 0.10, 0.65)
		tile.mesh = tm
		tile.position = spec[0]
		var color: Color = spec[1]
		var tmat: StandardMaterial3D = StandardMaterial3D.new()
		tmat.albedo_color = color
		tmat.emission_enabled = true
		tmat.emission = color
		tmat.emission_energy_multiplier = 1.8
		tmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		tile.material_override = tmat
		puzzle.add_child(tile)
		# Roman numeral on top
		var label: Label3D = Label3D.new()
		label.text = spec[2]
		label.position = (spec[0] as Vector3) + Vector3(0, 0.07, 0)
		label.rotation = Vector3(deg_to_rad(-90), 0, 0)
		label.modulate = Color(1, 1, 1)
		label.outline_modulate = Color(0, 0, 0, 0.85)
		label.outline_size = 4
		label.font_size = 16
		label.no_depth_test = true
		puzzle.add_child(label)
		# Pulse on independent timing
		var pulse: Tween = create_tween().set_loops()
		pulse.tween_property(tmat, "emission_energy_multiplier", 3.0, 0.85 + tile.position.x * 0.1).set_ease(Tween.EASE_IN_OUT)
		pulse.tween_property(tmat, "emission_energy_multiplier", 1.4, 0.85 + tile.position.x * 0.1).set_ease(Tween.EASE_IN_OUT)


func _build_d3_floating_stair(geom: Node) -> void:
	## Epic-3 T42: a vertical "floating platform staircase" — 8 small
	## platforms hovering at ascending heights forming a climbable path
	## up to 8m altitude.
	var stair: Node3D = Node3D.new()
	stair.name = "D3FloatingStair"
	stair.position = D3_CENTER + Vector3(20, 0, -12)
	geom.add_child(stair)
	var pad_mat: StandardMaterial3D = StandardMaterial3D.new()
	pad_mat.albedo_color = Color(0.16, 0.10, 0.20)
	pad_mat.metallic = 0.55
	pad_mat.roughness = 0.45
	pad_mat.emission_enabled = true
	pad_mat.emission = Color(0.85, 0.40, 1.0)
	pad_mat.emission_energy_multiplier = 0.55
	for i in 8:
		var pad: MeshInstance3D = MeshInstance3D.new()
		pad.name = "StairPad_%d" % i
		var pm: BoxMesh = BoxMesh.new()
		pm.size = Vector3(1.40, 0.20, 1.40)
		pad.mesh = pm
		pad.position = Vector3(i * 0.85, 1.0 + i * 0.85, sin(i * 0.5) * 0.55)
		pad.material_override = pad_mat
		stair.add_child(pad)
		# Bob each pad slightly on its own timing
		var origin: Vector3 = pad.position
		var bob: Tween = create_tween().set_loops()
		bob.tween_property(pad, "position:y", origin.y + 0.20, 1.4 + i * 0.1).set_ease(Tween.EASE_IN_OUT)
		bob.tween_property(pad, "position:y", origin.y, 1.4 + i * 0.1).set_ease(Tween.EASE_IN_OUT)
		# Per-pad collision
		var sb: StaticBody3D = StaticBody3D.new()
		var cs: CollisionShape3D = CollisionShape3D.new()
		var cb: BoxShape3D = BoxShape3D.new()
		cb.size = Vector3(1.40, 0.20, 1.40)
		cs.shape = cb
		cs.position = origin
		sb.add_child(cs)
		stair.add_child(sb)


func _build_d3_chained_statue(geom: Node) -> void:
	## Epic-3 T43: a chained ancient statue — humanoid stone figure with
	## 4 thin chain cylinders binding it to the ground. Tells "ancient
	## power was sealed here".
	var statue: Node3D = Node3D.new()
	statue.name = "D3ChainedStatue"
	statue.position = D3_CENTER + Vector3(8, 0, 16)
	geom.add_child(statue)
	# Stone body
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.20, 0.16, 0.26)
	stone_mat.metallic = 0.40
	stone_mat.roughness = 0.55
	var torso: MeshInstance3D = MeshInstance3D.new()
	var tm: BoxMesh = BoxMesh.new()
	tm.size = Vector3(1.20, 1.85, 0.85)
	torso.mesh = tm
	torso.position = Vector3(0, 1.30, 0)
	torso.material_override = stone_mat
	statue.add_child(torso)
	# Head sphere
	var head: MeshInstance3D = MeshInstance3D.new()
	var hm: SphereMesh = SphereMesh.new()
	hm.radius = 0.45
	hm.height = 0.85
	head.mesh = hm
	head.position = Vector3(0, 2.65, 0)
	head.material_override = stone_mat
	statue.add_child(head)
	# 2 dim violet eyes
	var eye_mat: StandardMaterial3D = StandardMaterial3D.new()
	eye_mat.albedo_color = Color(0.85, 0.40, 1.0)
	eye_mat.emission_enabled = true
	eye_mat.emission = Color(1.0, 0.55, 1.0)
	eye_mat.emission_energy_multiplier = 1.4
	eye_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for ex: float in [-0.15, 0.15]:
		var eye: MeshInstance3D = MeshInstance3D.new()
		var em: SphereMesh = SphereMesh.new()
		em.radius = 0.07
		em.height = 0.14
		eye.mesh = em
		eye.position = Vector3(ex, 2.70, 0.36)
		eye.material_override = eye_mat
		statue.add_child(eye)
	# 4 chain cylinders binding it to the ground at angles
	var chain_mat: StandardMaterial3D = StandardMaterial3D.new()
	chain_mat.albedo_color = Color(0.10, 0.10, 0.13)
	chain_mat.metallic = 0.85
	chain_mat.roughness = 0.30
	for i in 4:
		var angle: float = (float(i) / 4.0) * TAU
		var chain: MeshInstance3D = MeshInstance3D.new()
		var cm: CylinderMesh = CylinderMesh.new()
		cm.top_radius = 0.06
		cm.bottom_radius = 0.06
		cm.height = 2.40
		chain.mesh = cm
		chain.position = Vector3(cos(angle) * 0.95, 1.20, sin(angle) * 0.95)
		# Tilt chains outward toward ground
		chain.rotation = Vector3(sin(angle) * deg_to_rad(40), 0, -cos(angle) * deg_to_rad(40))
		chain.material_override = chain_mat
		statue.add_child(chain)
	# Collision around statue
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(1.40, 3.40, 1.0)
	cs.shape = cb
	cs.position = Vector3(0, 1.70, 0)
	sb.add_child(cs)
	statue.add_child(sb)


func _build_d3_librarian_npc(town: Node) -> void:
	## Epic-3 T44: Librarian NPC standing next to the floating bookshelves
	## holding an open glowing book in front of them.
	var slots: Node3D = town.get_node_or_null("%NPCSlots") as Node3D
	if slots == null:
		return
	var lib: Node3D = Node3D.new()
	lib.name = "D3Librarian"
	lib.position = D3_CENTER + Vector3(-18, 0, 1)
	slots.add_child(lib)
	# Robed body
	var bmat: StandardMaterial3D = StandardMaterial3D.new()
	bmat.albedo_color = Color(0.20, 0.16, 0.30)
	bmat.metallic = 0.20
	bmat.roughness = 0.65
	bmat.emission_enabled = true
	bmat.emission = Color(0.55, 0.30, 0.85)
	bmat.emission_energy_multiplier = 0.40
	var body: MeshInstance3D = MeshInstance3D.new()
	var bmesh: CapsuleMesh = CapsuleMesh.new()
	bmesh.radius = 0.42
	bmesh.height = 1.30
	body.mesh = bmesh
	body.position = Vector3(0, 0.70, 0)
	body.material_override = bmat
	lib.add_child(body)
	# Head
	var head: MeshInstance3D = MeshInstance3D.new()
	var hm: SphereMesh = SphereMesh.new()
	hm.radius = 0.36
	hm.height = 0.65
	head.mesh = hm
	head.position = Vector3(0, 1.55, 0)
	head.material_override = bmat
	lib.add_child(head)
	# Round glasses (2 small black torus)
	var glass_mat: StandardMaterial3D = StandardMaterial3D.new()
	glass_mat.albedo_color = Color(0.08, 0.08, 0.10)
	glass_mat.metallic = 0.55
	glass_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for ex: float in [-0.13, 0.13]:
		var glass: MeshInstance3D = MeshInstance3D.new()
		var gm: TorusMesh = TorusMesh.new()
		gm.inner_radius = 0.06
		gm.outer_radius = 0.10
		glass.mesh = gm
		glass.position = Vector3(ex, 1.55, 0.30)
		glass.rotation = Vector3(deg_to_rad(90), 0, 0)
		glass.material_override = glass_mat
		lib.add_child(glass)
	# Open book held in front (2 angled boxes)
	var book_mat: StandardMaterial3D = StandardMaterial3D.new()
	book_mat.albedo_color = Color(0.95, 0.85, 0.55)
	book_mat.emission_enabled = true
	book_mat.emission = Color(1.0, 0.85, 0.55)
	book_mat.emission_energy_multiplier = 1.4
	book_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for sx: float in [-0.18, 0.18]:
		var page: MeshInstance3D = MeshInstance3D.new()
		var pm: BoxMesh = BoxMesh.new()
		pm.size = Vector3(0.30, 0.04, 0.40)
		page.mesh = pm
		page.position = Vector3(sx, 0.85, 0.55)
		page.rotation = Vector3(0, 0, sign(sx) * deg_to_rad(15))
		page.material_override = book_mat
		lib.add_child(page)
	# Name billboard
	var label: Label3D = Label3D.new()
	label.text = "Librarian"
	label.position = Vector3(0, 2.20, 0)
	label.modulate = Color(1.0, 0.85, 0.55)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 18
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	lib.add_child(label)


func _build_d3_elemental_wisps(geom: Node) -> void:
	## Epic-3 T45: 4 elemental wisps in different colors (fire/ice/leaf/
	## storm) drifting near the spell puzzle as if guarding it.
	var wisp_specs: Array = [
		[D3_CENTER + Vector3(-10, 2.5, 13), Color(1.0, 0.40, 0.20)],
		[D3_CENTER + Vector3(-14, 2.5, 13), Color(0.55, 0.95, 1.0)],
		[D3_CENTER + Vector3(-12, 3.5, 11), Color(0.45, 1.0, 0.55)],
		[D3_CENTER + Vector3(-12, 3.5, 16), Color(1.0, 0.95, 0.30)],
	]
	for i in wisp_specs.size():
		var wisp: MeshInstance3D = MeshInstance3D.new()
		wisp.name = "D3ElementalWisp_%d" % i
		var wm: SphereMesh = SphereMesh.new()
		wm.radius = 0.20
		wm.height = 0.40
		wisp.mesh = wm
		wisp.position = wisp_specs[i][0]
		var color: Color = wisp_specs[i][1]
		var wmat: StandardMaterial3D = StandardMaterial3D.new()
		wmat.albedo_color = color
		wmat.emission_enabled = true
		wmat.emission = color
		wmat.emission_energy_multiplier = 3.0
		wmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		wisp.material_override = wmat
		geom.add_child(wisp)
		# Pulse + bob
		var pulse: Tween = create_tween().set_loops()
		pulse.tween_property(wisp, "scale", Vector3(1.40, 1.40, 1.40), 0.85 + i * 0.1).set_ease(Tween.EASE_IN_OUT)
		pulse.tween_property(wisp, "scale", Vector3(0.85, 0.85, 0.85), 0.85 + i * 0.1).set_ease(Tween.EASE_IN_OUT)
		var origin: Vector3 = wisp_specs[i][0]
		var bob: Tween = create_tween().set_loops()
		bob.tween_property(wisp, "position:y", origin.y + 0.55, 1.4 + i * 0.15).set_ease(Tween.EASE_IN_OUT)
		bob.tween_property(wisp, "position:y", origin.y, 1.4 + i * 0.15).set_ease(Tween.EASE_IN_OUT)


func _build_d3_sky_portal(geom: Node) -> void:
	## Epic-3 T46: a large sky portal ring 16m above the district center —
	## a huge translucent torus with 8 emissive runes around its edge,
	## slowly rotating + tilted at an angle.
	var portal: Node3D = Node3D.new()
	portal.name = "D3SkyPortal"
	portal.position = D3_CENTER + Vector3(0, 16, 0)
	portal.rotation = Vector3(deg_to_rad(20), 0, 0)
	geom.add_child(portal)
	# Big ring torus
	var ring: MeshInstance3D = MeshInstance3D.new()
	var rmesh: TorusMesh = TorusMesh.new()
	rmesh.inner_radius = 5.5
	rmesh.outer_radius = 6.0
	ring.mesh = rmesh
	var rmat: StandardMaterial3D = StandardMaterial3D.new()
	rmat.albedo_color = Color(0.85, 0.40, 1.0, 0.85)
	rmat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	rmat.emission_enabled = true
	rmat.emission = Color(1.0, 0.55, 1.0)
	rmat.emission_energy_multiplier = 2.4
	rmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	ring.material_override = rmat
	portal.add_child(ring)
	# 8 small emissive rune dots around the ring's edge
	for i in 8:
		var angle: float = (float(i) / 8.0) * TAU
		var rune: MeshInstance3D = MeshInstance3D.new()
		var rm: SphereMesh = SphereMesh.new()
		rm.radius = 0.30
		rm.height = 0.60
		rune.mesh = rm
		rune.position = Vector3(cos(angle) * 5.75, 0, sin(angle) * 5.75)
		var rmat2: StandardMaterial3D = StandardMaterial3D.new()
		rmat2.albedo_color = Color(1.0, 0.55, 1.0)
		rmat2.emission_enabled = true
		rmat2.emission = Color(1.0, 0.55, 1.0)
		rmat2.emission_energy_multiplier = 3.0
		rmat2.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		rune.material_override = rmat2
		portal.add_child(rune)
	# Slow rotation
	var spin: Tween = create_tween().set_loops()
	spin.tween_property(portal, "rotation:z", TAU, 24.0)


func _build_d3_judgment_dais(geom: Node) -> void:
	## Epic-3 T47: a raised judgment dais with a throne — 3-step stone
	## platform supporting a tall stone seat. Empty throne suggesting
	## "the judge of memories has not yet returned".
	var dais: Node3D = Node3D.new()
	dais.name = "D3JudgmentDais"
	dais.position = D3_CENTER + Vector3(-15, 0, 14)
	geom.add_child(dais)
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.16, 0.10, 0.20)
	stone_mat.metallic = 0.55
	stone_mat.roughness = 0.45
	# 3 stepped platforms
	for i in 3:
		var step: MeshInstance3D = MeshInstance3D.new()
		var step_mesh: BoxMesh = BoxMesh.new()
		step_mesh.size = Vector3(3.40 - i * 0.55, 0.30, 3.40 - i * 0.55)
		step.mesh = step_mesh
		step.position = Vector3(0, 0.15 + i * 0.30, 0)
		step.material_override = stone_mat
		dais.add_child(step)
	# Throne — vertical box body + tall back
	var seat: MeshInstance3D = MeshInstance3D.new()
	var sm: BoxMesh = BoxMesh.new()
	sm.size = Vector3(1.40, 0.65, 1.20)
	seat.mesh = sm
	seat.position = Vector3(0, 1.20, 0)
	seat.material_override = stone_mat
	dais.add_child(seat)
	# Tall throne back
	var back: MeshInstance3D = MeshInstance3D.new()
	var bm: BoxMesh = BoxMesh.new()
	bm.size = Vector3(1.40, 2.85, 0.30)
	back.mesh = bm
	back.position = Vector3(0, 2.55, -0.45)
	back.material_override = stone_mat
	dais.add_child(back)
	# Crowning gem on the throne back
	var gem: MeshInstance3D = MeshInstance3D.new()
	var gm: SphereMesh = SphereMesh.new()
	gm.radius = 0.30
	gm.height = 0.60
	gem.mesh = gm
	gem.position = Vector3(0, 4.0, -0.45)
	var gmat: StandardMaterial3D = StandardMaterial3D.new()
	gmat.albedo_color = Color(0.85, 0.40, 1.0)
	gmat.emission_enabled = true
	gmat.emission = Color(1.0, 0.55, 1.0)
	gmat.emission_energy_multiplier = 3.0
	gmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	gem.material_override = gmat
	dais.add_child(gem)
	# Pulse the gem
	var pulse: Tween = create_tween().set_loops()
	pulse.tween_property(gem, "scale", Vector3(1.30, 1.30, 1.30), 1.4).set_ease(Tween.EASE_IN_OUT)
	pulse.tween_property(gem, "scale", Vector3(0.85, 0.85, 0.85), 1.4).set_ease(Tween.EASE_IN_OUT)
	# Sign
	var label: Label3D = Label3D.new()
	label.text = "JUDGMENT DAIS"
	label.position = Vector3(0, 4.85, 0)
	label.modulate = Color(0.85, 0.55, 1.0)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 18
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	dais.add_child(label)
	# Collision around dais
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(3.40, 4.0, 3.40)
	cs.shape = cb
	cs.position = Vector3(0, 2.0, 0)
	sb.add_child(cs)
	dais.add_child(sb)


func _build_d3_echo_singer_npc(town: Node) -> void:
	## Epic-3 T48: Echo Singer NPC — translucent figure with a flowing
	## robe that "sings" memory echoes. Has 5 small floating note glyphs
	## drifting around their head.
	var slots: Node3D = town.get_node_or_null("%NPCSlots") as Node3D
	if slots == null:
		return
	var singer: Node3D = Node3D.new()
	singer.name = "D3EchoSinger"
	singer.position = D3_CENTER + Vector3(15, 0, 14)
	slots.add_child(singer)
	# Translucent robed body
	var bmat: StandardMaterial3D = StandardMaterial3D.new()
	bmat.albedo_color = Color(0.55, 0.85, 1.0, 0.55)
	bmat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	bmat.emission_enabled = true
	bmat.emission = Color(0.55, 0.95, 1.0)
	bmat.emission_energy_multiplier = 1.4
	bmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var body: MeshInstance3D = MeshInstance3D.new()
	var bmesh: CapsuleMesh = CapsuleMesh.new()
	bmesh.radius = 0.45
	bmesh.height = 1.40
	body.mesh = bmesh
	body.position = Vector3(0, 0.70, 0)
	body.material_override = bmat
	singer.add_child(body)
	# Head
	var head: MeshInstance3D = MeshInstance3D.new()
	var hm: SphereMesh = SphereMesh.new()
	hm.radius = 0.36
	hm.height = 0.65
	head.mesh = hm
	head.position = Vector3(0, 1.55, 0)
	head.material_override = bmat
	singer.add_child(head)
	# Open singing mouth
	var mouth: MeshInstance3D = MeshInstance3D.new()
	var mm: SphereMesh = SphereMesh.new()
	mm.radius = 0.10
	mm.height = 0.20
	mouth.mesh = mm
	mouth.position = Vector3(0, 1.45, 0.30)
	var momat: StandardMaterial3D = StandardMaterial3D.new()
	momat.albedo_color = Color(1, 1, 1)
	momat.emission_enabled = true
	momat.emission = Color(1, 1, 1)
	momat.emission_energy_multiplier = 2.6
	momat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mouth.material_override = momat
	singer.add_child(mouth)
	# 5 floating note glyphs around the head
	var note_pivot: Node3D = Node3D.new()
	note_pivot.position = Vector3(0, 1.85, 0)
	singer.add_child(note_pivot)
	for i in 5:
		var angle: float = (float(i) / 5.0) * TAU
		var note: Label3D = Label3D.new()
		note.text = "♪"
		note.position = Vector3(cos(angle) * 0.65, sin(i * 0.5) * 0.20, sin(angle) * 0.65)
		note.modulate = Color(0.55, 0.95, 1.0)
		note.outline_modulate = Color(0, 0, 0, 0.85)
		note.outline_size = 4
		note.font_size = 22
		note.no_depth_test = true
		note.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		note_pivot.add_child(note)
	# Rotate the note pivot
	var spin: Tween = create_tween().set_loops()
	spin.tween_property(note_pivot, "rotation:y", TAU, 4.0)
	# Name billboard
	var label: Label3D = Label3D.new()
	label.text = "Echo Singer"
	label.position = Vector3(0, 2.85, 0)
	label.modulate = Color(0.55, 0.95, 1.0)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 18
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	singer.add_child(label)


func _build_d3_mana_crystals(geom: Node) -> void:
	## Epic-3 T49: a cluster of 6 floating mana crystals at the corners
	## of the judgment dais — each is a small spinning prism with strong
	## emission.
	var positions: Array[Vector3] = [
		D3_CENTER + Vector3(-18, 0.5, 12),
		D3_CENTER + Vector3(-12, 0.5, 12),
		D3_CENTER + Vector3(-15, 0.5, 11),
		D3_CENTER + Vector3(-18, 0.5, 17),
		D3_CENTER + Vector3(-12, 0.5, 17),
		D3_CENTER + Vector3(-15, 0.5, 18),
	]
	var crystal_mat: StandardMaterial3D = StandardMaterial3D.new()
	crystal_mat.albedo_color = Color(0.85, 0.40, 1.0)
	crystal_mat.emission_enabled = true
	crystal_mat.emission = Color(1.0, 0.55, 1.0)
	crystal_mat.emission_energy_multiplier = 2.4
	crystal_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for i in positions.size():
		var crystal: MeshInstance3D = MeshInstance3D.new()
		crystal.name = "D3ManaCrystal_%d" % i
		var cmesh: PrismMesh = PrismMesh.new()
		cmesh.size = Vector3(0.30, 0.65, 0.30)
		crystal.mesh = cmesh
		crystal.position = positions[i]
		crystal.material_override = crystal_mat
		geom.add_child(crystal)
		var spin: Tween = create_tween().set_loops()
		spin.tween_property(crystal, "rotation:y", TAU, 4.0 + i * 0.3)
		var bob: Tween = create_tween().set_loops()
		bob.tween_property(crystal, "position:y", positions[i].y + 0.30, 1.4 + i * 0.1).set_ease(Tween.EASE_IN_OUT)
		bob.tween_property(crystal, "position:y", positions[i].y, 1.4 + i * 0.1).set_ease(Tween.EASE_IN_OUT)


func _build_d3_memory_echo(geom: Node) -> void:
	## Epic-3 T50: MEMORY ECHO mini-boss — large translucent face with
	## 4 floating cube fragments orbiting it. Slow patrol around the
	## sealed gates area.
	var echo: Node3D = Node3D.new()
	echo.name = "D3MemoryEcho"
	echo.position = D3_CENTER + Vector3(20, 0, 8)
	geom.add_child(echo)
	# Big translucent head sphere
	var head_mat: StandardMaterial3D = StandardMaterial3D.new()
	head_mat.albedo_color = Color(0.55, 0.30, 0.85, 0.45)
	head_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	head_mat.emission_enabled = true
	head_mat.emission = Color(1.0, 0.55, 1.0)
	head_mat.emission_energy_multiplier = 2.0
	head_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var head: MeshInstance3D = MeshInstance3D.new()
	var hmesh: SphereMesh = SphereMesh.new()
	hmesh.radius = 1.40
	hmesh.height = 2.80
	head.mesh = hmesh
	head.position = Vector3(0, 2.40, 0)
	head.material_override = head_mat
	echo.add_child(head)
	# 2 huge glowing white eyes
	var eye_mat: StandardMaterial3D = StandardMaterial3D.new()
	eye_mat.albedo_color = Color(1, 1, 1)
	eye_mat.emission_enabled = true
	eye_mat.emission = Color(1, 1, 1)
	eye_mat.emission_energy_multiplier = 3.4
	eye_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for ex: float in [-0.45, 0.45]:
		var eye: MeshInstance3D = MeshInstance3D.new()
		var em: SphereMesh = SphereMesh.new()
		em.radius = 0.30
		em.height = 0.60
		eye.mesh = em
		eye.position = Vector3(ex, 2.55, 1.0)
		eye.material_override = eye_mat
		echo.add_child(eye)
	# Floating mouth slit
	var mouth: MeshInstance3D = MeshInstance3D.new()
	var mm: BoxMesh = BoxMesh.new()
	mm.size = Vector3(0.85, 0.10, 0.06)
	mouth.mesh = mm
	mouth.position = Vector3(0, 1.85, 1.20)
	var momat: StandardMaterial3D = StandardMaterial3D.new()
	momat.albedo_color = Color(1.0, 0.55, 1.0)
	momat.emission_enabled = true
	momat.emission = Color(1.0, 0.55, 1.0)
	momat.emission_energy_multiplier = 2.6
	momat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mouth.material_override = momat
	echo.add_child(mouth)
	# 4 cube fragments orbiting head
	var orbit_pivot: Node3D = Node3D.new()
	orbit_pivot.position = Vector3(0, 2.40, 0)
	echo.add_child(orbit_pivot)
	for i in 4:
		var angle: float = (float(i) / 4.0) * TAU
		var frag: MeshInstance3D = MeshInstance3D.new()
		var fmesh: BoxMesh = BoxMesh.new()
		fmesh.size = Vector3(0.40, 0.40, 0.40)
		frag.mesh = fmesh
		frag.position = Vector3(cos(angle) * 2.20, randf_range(-0.30, 0.30), sin(angle) * 2.20)
		var fmat: StandardMaterial3D = StandardMaterial3D.new()
		fmat.albedo_color = Color(0.85, 0.40, 1.0, 0.65)
		fmat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		fmat.emission_enabled = true
		fmat.emission = Color(1.0, 0.55, 1.0)
		fmat.emission_energy_multiplier = 2.4
		fmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		frag.material_override = fmat
		orbit_pivot.add_child(frag)
	var spin: Tween = create_tween().set_loops()
	spin.tween_property(orbit_pivot, "rotation:y", TAU, 8.0)
	# Slow patrol path
	var origin: Vector3 = D3_CENTER + Vector3(20, 0, 8)
	var patrol: Tween = create_tween().set_loops()
	patrol.tween_property(echo, "position", origin + Vector3(-4, 0, -4), 6.0).set_ease(Tween.EASE_IN_OUT)
	patrol.tween_property(echo, "position", origin + Vector3(-4, 0, 4), 6.0).set_ease(Tween.EASE_IN_OUT)
	patrol.tween_property(echo, "position", origin, 6.0).set_ease(Tween.EASE_IN_OUT)
	# Boss-tier name billboard
	var label: Label3D = Label3D.new()
	label.text = "MEMORY ECHO"
	label.position = Vector3(0, 4.85, 0)
	label.modulate = Color(1.0, 0.55, 1.0)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 6
	label.font_size = 22
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	echo.add_child(label)


func _build_d3_ancient_pool(geom: Node) -> void:
	## Epic-3 T51: ancient stone pool with 4 floating "data fish" — small
	## elongated emissive shapes drifting in circles above the surface.
	var pool: Node3D = Node3D.new()
	pool.name = "D3AncientPool"
	pool.position = D3_CENTER + Vector3(15, 0, -8)
	geom.add_child(pool)
	# Stone basin — wider than memory pool
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.16, 0.10, 0.20)
	stone_mat.metallic = 0.55
	stone_mat.roughness = 0.45
	var rim: MeshInstance3D = MeshInstance3D.new()
	var rmesh: TorusMesh = TorusMesh.new()
	rmesh.inner_radius = 1.85
	rmesh.outer_radius = 2.20
	rim.mesh = rmesh
	rim.position = Vector3(0, 0.20, 0)
	rim.material_override = stone_mat
	pool.add_child(rim)
	# Water surface — translucent cyan disc
	var water: MeshInstance3D = MeshInstance3D.new()
	var wmesh: CylinderMesh = CylinderMesh.new()
	wmesh.top_radius = 1.85
	wmesh.bottom_radius = 1.85
	wmesh.height = 0.06
	water.mesh = wmesh
	water.position = Vector3(0, 0.20, 0)
	var wmat: StandardMaterial3D = StandardMaterial3D.new()
	wmat.albedo_color = Color(0.30, 0.85, 1.0, 0.55)
	wmat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	wmat.emission_enabled = true
	wmat.emission = Color(0.55, 0.95, 1.0)
	wmat.emission_energy_multiplier = 1.4
	wmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	water.material_override = wmat
	pool.add_child(water)
	# 4 data fish — small elongated boxes circling
	var fish_pivot: Node3D = Node3D.new()
	fish_pivot.position = Vector3(0, 0.55, 0)
	pool.add_child(fish_pivot)
	for i in 4:
		var angle: float = (float(i) / 4.0) * TAU
		var fish: MeshInstance3D = MeshInstance3D.new()
		var fm: BoxMesh = BoxMesh.new()
		fm.size = Vector3(0.30, 0.10, 0.55)
		fish.mesh = fm
		fish.position = Vector3(cos(angle) * 1.20, 0, sin(angle) * 1.20)
		fish.rotation = Vector3(0, -angle - PI * 0.5, 0)
		var fmat: StandardMaterial3D = StandardMaterial3D.new()
		fmat.albedo_color = Color(0.55, 0.95, 1.0)
		fmat.emission_enabled = true
		fmat.emission = Color(0.55, 0.95, 1.0)
		fmat.emission_energy_multiplier = 2.4
		fmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		fish.material_override = fmat
		fish_pivot.add_child(fish)
	# Rotate the fish pivot
	var spin: Tween = create_tween().set_loops()
	spin.tween_property(fish_pivot, "rotation:y", TAU, 6.0)
	# Sign
	var label: Label3D = Label3D.new()
	label.text = "ANCIENT POOL"
	label.position = Vector3(0, 1.85, 0)
	label.modulate = Color(0.55, 0.95, 1.0)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 16
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	pool.add_child(label)
	# Collision around basin
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(4.0, 0.85, 4.0)
	cs.shape = cb
	cs.position = Vector3(0, 0.42, 0)
	sb.add_child(cs)
	pool.add_child(sb)


func _build_d3_pendulum(geom: Node) -> void:
	## Epic-3 T52: tall hanging pendulum — stone arch frame with a long
	## thin chain holding a heavy weighted ball that swings back and forth.
	var pend: Node3D = Node3D.new()
	pend.name = "D3Pendulum"
	pend.position = D3_CENTER + Vector3(8, 0, -16)
	geom.add_child(pend)
	# Arch frame — 2 thin legs + crossbar
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.16, 0.10, 0.20)
	stone_mat.metallic = 0.55
	stone_mat.roughness = 0.45
	for sx: float in [-1.20, 1.20]:
		var leg: MeshInstance3D = MeshInstance3D.new()
		var lm: CylinderMesh = CylinderMesh.new()
		lm.top_radius = 0.10
		lm.bottom_radius = 0.14
		lm.height = 5.0
		leg.mesh = lm
		leg.position = Vector3(sx, 2.50, 0)
		leg.material_override = stone_mat
		pend.add_child(leg)
		# Collision per leg
		var sb: StaticBody3D = StaticBody3D.new()
		var cs: CollisionShape3D = CollisionShape3D.new()
		var cap: CapsuleShape3D = CapsuleShape3D.new()
		cap.radius = 0.20
		cap.height = 5.0
		cs.shape = cap
		cs.position = Vector3(sx, 2.50, 0)
		sb.add_child(cs)
		pend.add_child(sb)
	# Crossbar
	var bar: MeshInstance3D = MeshInstance3D.new()
	var bm: BoxMesh = BoxMesh.new()
	bm.size = Vector3(2.85, 0.30, 0.30)
	bar.mesh = bm
	bar.position = Vector3(0, 5.0, 0)
	bar.material_override = stone_mat
	pend.add_child(bar)
	# Pendulum pivot at the top
	var pivot: Node3D = Node3D.new()
	pivot.position = Vector3(0, 5.0, 0)
	pend.add_child(pivot)
	# Long chain
	var chain_mat: StandardMaterial3D = StandardMaterial3D.new()
	chain_mat.albedo_color = Color(0.10, 0.10, 0.13)
	chain_mat.metallic = 0.85
	var chain: MeshInstance3D = MeshInstance3D.new()
	var cm: CylinderMesh = CylinderMesh.new()
	cm.top_radius = 0.04
	cm.bottom_radius = 0.04
	cm.height = 3.40
	chain.mesh = cm
	chain.position = Vector3(0, -1.70, 0)
	chain.material_override = chain_mat
	pivot.add_child(chain)
	# Heavy weighted ball
	var ball: MeshInstance3D = MeshInstance3D.new()
	var bm2: SphereMesh = SphereMesh.new()
	bm2.radius = 0.40
	bm2.height = 0.80
	ball.mesh = bm2
	ball.position = Vector3(0, -3.55, 0)
	var ball_mat: StandardMaterial3D = StandardMaterial3D.new()
	ball_mat.albedo_color = Color(0.20, 0.16, 0.26)
	ball_mat.metallic = 0.85
	ball_mat.roughness = 0.30
	ball_mat.emission_enabled = true
	ball_mat.emission = Color(0.85, 0.40, 1.0)
	ball_mat.emission_energy_multiplier = 0.55
	ball.material_override = ball_mat
	pivot.add_child(ball)
	# Swing tween
	var swing: Tween = create_tween().set_loops()
	swing.tween_property(pivot, "rotation:x", deg_to_rad(20), 1.6).set_ease(Tween.EASE_IN_OUT)
	swing.tween_property(pivot, "rotation:x", deg_to_rad(-20), 1.6).set_ease(Tween.EASE_IN_OUT)


func _build_d3_prophecy_stones(geom: Node) -> void:
	## Epic-3 T53: 3 prophecy stones forming a small triangle — each stone
	## is a flat slab with text engraved + glowing emission.
	var positions: Array[Vector3] = [
		D3_CENTER + Vector3(-12, 0, 8),
		D3_CENTER + Vector3(-10, 0, 11),
		D3_CENTER + Vector3(-14, 0, 11),
	]
	var texts: Array[String] = ["PAST", "PRESENT", "FUTURE"]
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.30, 0.20, 0.40)
	stone_mat.metallic = 0.40
	stone_mat.roughness = 0.55
	stone_mat.emission_enabled = true
	stone_mat.emission = Color(0.85, 0.40, 1.0)
	stone_mat.emission_energy_multiplier = 0.55
	for i in positions.size():
		var stone: Node3D = Node3D.new()
		stone.name = "D3ProphecyStone_%d" % i
		stone.position = positions[i]
		stone.rotation = Vector3(0, deg_to_rad(i * 120), 0)
		geom.add_child(stone)
		# Slab body
		var slab: MeshInstance3D = MeshInstance3D.new()
		var sm: BoxMesh = BoxMesh.new()
		sm.size = Vector3(1.0, 1.85, 0.30)
		slab.mesh = sm
		slab.position = Vector3(0, 0.92, 0)
		slab.material_override = stone_mat
		stone.add_child(slab)
		# Engraved text
		var label: Label3D = Label3D.new()
		label.text = texts[i]
		label.position = Vector3(0, 0.92, 0.16)
		label.modulate = Color(1.0, 0.95, 0.30)
		label.outline_modulate = Color(0, 0, 0, 0.85)
		label.outline_size = 4
		label.font_size = 16
		label.no_depth_test = true
		stone.add_child(label)
		# Per-stone collision
		var sb: StaticBody3D = StaticBody3D.new()
		var cs: CollisionShape3D = CollisionShape3D.new()
		var cb: BoxShape3D = BoxShape3D.new()
		cb.size = Vector3(1.0, 1.85, 0.30)
		cs.shape = cb
		cs.position = Vector3(0, 0.92, 0)
		sb.add_child(cs)
		stone.add_child(sb)


func _build_d3_apprentice_npc(town: Node) -> void:
	## Epic-3 T54: an apprentice child NPC — smaller body, eager bouncing
	## animation, and a small floating practice rune sphere they're trying
	## to learn to control.
	var slots: Node3D = town.get_node_or_null("%NPCSlots") as Node3D
	if slots == null:
		return
	var app: Node3D = Node3D.new()
	app.name = "D3Apprentice"
	app.position = D3_CENTER + Vector3(-3, 0, 12)
	slots.add_child(app)
	# Smaller body
	var bmat: StandardMaterial3D = StandardMaterial3D.new()
	bmat.albedo_color = Color(0.30, 0.20, 0.40)
	bmat.metallic = 0.20
	bmat.roughness = 0.55
	bmat.emission_enabled = true
	bmat.emission = Color(0.55, 0.30, 0.85)
	bmat.emission_energy_multiplier = 0.40
	var body: MeshInstance3D = MeshInstance3D.new()
	var bmesh: CapsuleMesh = CapsuleMesh.new()
	bmesh.radius = 0.30
	bmesh.height = 0.85
	body.mesh = bmesh
	body.position = Vector3(0, 0.50, 0)
	body.material_override = bmat
	app.add_child(body)
	# Small head
	var head: MeshInstance3D = MeshInstance3D.new()
	var hm: SphereMesh = SphereMesh.new()
	hm.radius = 0.28
	hm.height = 0.50
	head.mesh = hm
	head.position = Vector3(0, 1.10, 0)
	head.material_override = bmat
	app.add_child(head)
	# 2 large eager eyes
	var eye_mat: StandardMaterial3D = StandardMaterial3D.new()
	eye_mat.albedo_color = Color(0.55, 0.95, 1.0)
	eye_mat.emission_enabled = true
	eye_mat.emission = Color(0.55, 0.95, 1.0)
	eye_mat.emission_energy_multiplier = 2.6
	eye_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for ex: float in [-0.10, 0.10]:
		var eye: MeshInstance3D = MeshInstance3D.new()
		var em: SphereMesh = SphereMesh.new()
		em.radius = 0.08
		em.height = 0.16
		eye.mesh = em
		eye.position = Vector3(ex, 1.10, 0.22)
		eye.material_override = eye_mat
		app.add_child(eye)
	# Floating practice rune in front
	var rune: MeshInstance3D = MeshInstance3D.new()
	var rm: SphereMesh = SphereMesh.new()
	rm.radius = 0.18
	rm.height = 0.36
	rune.mesh = rm
	rune.position = Vector3(0, 0.85, 0.65)
	var rmat: StandardMaterial3D = StandardMaterial3D.new()
	rmat.albedo_color = Color(0.85, 0.40, 1.0)
	rmat.emission_enabled = true
	rmat.emission = Color(1.0, 0.55, 1.0)
	rmat.emission_energy_multiplier = 2.6
	rmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	rune.material_override = rmat
	app.add_child(rune)
	# Bounce body in place
	var bounce: Tween = create_tween().set_loops()
	bounce.tween_property(body, "position:y", 0.65, 0.5).set_ease(Tween.EASE_OUT)
	bounce.tween_property(body, "position:y", 0.50, 0.4).set_ease(Tween.EASE_IN)
	bounce.tween_interval(0.8)
	# Wobble the rune
	var wobble: Tween = create_tween().set_loops()
	wobble.tween_property(rune, "position:x", 0.20, 0.5).set_ease(Tween.EASE_IN_OUT)
	wobble.tween_property(rune, "position:x", -0.20, 0.5).set_ease(Tween.EASE_IN_OUT)
	wobble.tween_property(rune, "position:x", 0.0, 0.5).set_ease(Tween.EASE_IN_OUT)
	# Name billboard
	var label: Label3D = Label3D.new()
	label.text = "Apprentice"
	label.position = Vector3(0, 1.65, 0)
	label.modulate = Color(0.55, 0.95, 1.0)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 16
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	app.add_child(label)


func _build_d3_page_rain(geom: Node) -> void:
	## Epic-3 T55: ambient floating page rain — 80 small translucent
	## amber page particles drifting down across the entire district like
	## paper leaves.
	var rain: GPUParticles3D = GPUParticles3D.new()
	rain.name = "D3PageRain"
	rain.position = D3_CENTER + Vector3(0, 14, 0)
	rain.amount = 80
	rain.lifetime = 8.0
	rain.preprocess = 4.0
	var pmat: ParticleProcessMaterial = ParticleProcessMaterial.new()
	pmat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	pmat.emission_box_extents = Vector3(28, 0.5, 18)
	pmat.direction = Vector3(0, -1, 0)
	pmat.spread = 12.0
	pmat.initial_velocity_min = 0.45
	pmat.initial_velocity_max = 0.85
	pmat.gravity = Vector3(0, -0.55, 0)
	pmat.scale_min = 0.20
	pmat.scale_max = 0.40
	pmat.color = Color(1.0, 0.85, 0.55, 0.55)
	rain.process_material = pmat
	var page: BoxMesh = BoxMesh.new()
	page.size = Vector3(0.30, 0.04, 0.40)
	var page_mat: StandardMaterial3D = StandardMaterial3D.new()
	page_mat.albedo_color = Color(1.0, 0.85, 0.55, 0.55)
	page_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	page_mat.emission_enabled = true
	page_mat.emission = Color(1.0, 0.85, 0.55)
	page_mat.emission_energy_multiplier = 0.85
	page_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	page.material = page_mat
	rain.draw_pass_1 = page
	geom.add_child(rain)


func _build_d3_alchemy_table(geom: Node) -> void:
	## Epic-3 T56: alchemy table with 5 colored potion bottles + glowing
	## crucible. Crowded with arcane experimentation gear.
	var alch: Node3D = Node3D.new()
	alch.name = "D3AlchemyTable"
	alch.position = D3_CENTER + Vector3(-12, 0, -3)
	geom.add_child(alch)
	# Wooden table
	var table_mat: StandardMaterial3D = StandardMaterial3D.new()
	table_mat.albedo_color = Color(0.30, 0.18, 0.10)
	table_mat.metallic = 0.10
	table_mat.roughness = 0.65
	var table: MeshInstance3D = MeshInstance3D.new()
	var tm: BoxMesh = BoxMesh.new()
	tm.size = Vector3(2.40, 0.95, 0.85)
	table.mesh = tm
	table.position = Vector3(0, 0.47, 0)
	table.material_override = table_mat
	alch.add_child(table)
	# 5 potion bottles in a row
	var potion_colors: Array[Color] = [
		Color(0.55, 0.95, 1.0),
		Color(1.0, 0.55, 0.20),
		Color(0.45, 1.0, 0.55),
		Color(1.0, 0.95, 0.30),
		Color(0.85, 0.40, 1.0),
	]
	for i in 5:
		var bottle: MeshInstance3D = MeshInstance3D.new()
		var bm: CylinderMesh = CylinderMesh.new()
		bm.top_radius = 0.10
		bm.bottom_radius = 0.14
		bm.height = 0.40
		bottle.mesh = bm
		bottle.position = Vector3(-0.85 + i * 0.40, 1.15, 0)
		var bmat: StandardMaterial3D = StandardMaterial3D.new()
		bmat.albedo_color = potion_colors[i]
		bmat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		bmat.albedo_color.a = 0.85
		bmat.emission_enabled = true
		bmat.emission = potion_colors[i]
		bmat.emission_energy_multiplier = 1.8
		bmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		bottle.material_override = bmat
		alch.add_child(bottle)
	# Glowing crucible at the side — small bowl
	var crucible: MeshInstance3D = MeshInstance3D.new()
	var cm: CylinderMesh = CylinderMesh.new()
	cm.top_radius = 0.30
	cm.bottom_radius = 0.18
	cm.height = 0.30
	crucible.mesh = cm
	crucible.position = Vector3(1.0, 1.10, 0)
	var cmat: StandardMaterial3D = StandardMaterial3D.new()
	cmat.albedo_color = Color(0.10, 0.10, 0.13)
	cmat.metallic = 0.85
	cmat.emission_enabled = true
	cmat.emission = Color(1.0, 0.55, 1.0)
	cmat.emission_energy_multiplier = 1.4
	crucible.material_override = cmat
	alch.add_child(crucible)
	# Pulsing flame inside the crucible
	var flame: MeshInstance3D = MeshInstance3D.new()
	var fmesh: SphereMesh = SphereMesh.new()
	fmesh.radius = 0.15
	fmesh.height = 0.30
	flame.mesh = fmesh
	flame.position = Vector3(1.0, 1.30, 0)
	var fmat: StandardMaterial3D = StandardMaterial3D.new()
	fmat.albedo_color = Color(1.0, 0.55, 1.0)
	fmat.emission_enabled = true
	fmat.emission = Color(1.0, 0.55, 1.0)
	fmat.emission_energy_multiplier = 3.0
	fmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	flame.material_override = fmat
	alch.add_child(flame)
	var pulse: Tween = create_tween().set_loops()
	pulse.tween_property(flame, "scale", Vector3(1.30, 1.30, 1.30), 0.6).set_ease(Tween.EASE_IN_OUT)
	pulse.tween_property(flame, "scale", Vector3(0.85, 0.85, 0.85), 0.6).set_ease(Tween.EASE_IN_OUT)
	# Sign
	var label: Label3D = Label3D.new()
	label.text = "ALCHEMY"
	label.position = Vector3(0, 2.0, 0)
	label.modulate = Color(0.85, 0.55, 1.0)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 16
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	alch.add_child(label)
	# Collision around table
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(2.40, 1.40, 0.85)
	cs.shape = cb
	cs.position = Vector3(0, 0.70, 0)
	sb.add_child(cs)
	alch.add_child(sb)


func _build_d3_sundial(geom: Node) -> void:
	## Epic-3 T57: ancient sundial — flat circular stone disc with a tall
	## angled gnomon casting a virtual shadow across 12 hour markers.
	var dial: Node3D = Node3D.new()
	dial.name = "D3Sundial"
	dial.position = D3_CENTER + Vector3(-15, 0, 4)
	geom.add_child(dial)
	# Flat disc base
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.30, 0.20, 0.40)
	stone_mat.metallic = 0.40
	stone_mat.roughness = 0.55
	stone_mat.emission_enabled = true
	stone_mat.emission = Color(0.85, 0.40, 1.0)
	stone_mat.emission_energy_multiplier = 0.30
	var disc: MeshInstance3D = MeshInstance3D.new()
	var dm: CylinderMesh = CylinderMesh.new()
	dm.top_radius = 1.85
	dm.bottom_radius = 1.85
	dm.height = 0.20
	disc.mesh = dm
	disc.position = Vector3(0, 0.10, 0)
	disc.material_override = stone_mat
	dial.add_child(disc)
	# Angled gnomon — tall thin prism
	var gnomon: MeshInstance3D = MeshInstance3D.new()
	var gm: PrismMesh = PrismMesh.new()
	gm.size = Vector3(0.20, 1.85, 1.40)
	gnomon.mesh = gm
	gnomon.position = Vector3(0, 1.10, 0)
	gnomon.material_override = stone_mat
	dial.add_child(gnomon)
	# 12 hour markers around the rim — small emissive dots
	var marker_mat: StandardMaterial3D = StandardMaterial3D.new()
	marker_mat.albedo_color = Color(0.85, 0.40, 1.0)
	marker_mat.emission_enabled = true
	marker_mat.emission = Color(1.0, 0.55, 1.0)
	marker_mat.emission_energy_multiplier = 2.4
	marker_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for i in 12:
		var angle: float = (float(i) / 12.0) * TAU
		var marker: MeshInstance3D = MeshInstance3D.new()
		var mm: SphereMesh = SphereMesh.new()
		mm.radius = 0.10
		mm.height = 0.20
		marker.mesh = mm
		marker.position = Vector3(cos(angle) * 1.55, 0.25, sin(angle) * 1.55)
		marker.material_override = marker_mat
		dial.add_child(marker)
	# Sign
	var label: Label3D = Label3D.new()
	label.text = "SUNDIAL"
	label.position = Vector3(0, 2.55, 0)
	label.modulate = Color(1.0, 0.55, 1.0)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 16
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	dial.add_child(label)
	# Collision
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(3.85, 0.40, 3.85)
	cs.shape = cb
	cs.position = Vector3(0, 0.20, 0)
	sb.add_child(cs)
	dial.add_child(sb)


func _build_d3_library_facade(geom: Node) -> void:
	## Epic-3 T58: a grand library facade — wide tall building front with
	## 4 columns + lintel + tall pointed pediment + glowing entryway.
	var lib: Node3D = Node3D.new()
	lib.name = "D3LibraryFacade"
	lib.position = D3_CENTER + Vector3(0, 0, 18)
	geom.add_child(lib)
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.20, 0.16, 0.26)
	stone_mat.metallic = 0.40
	stone_mat.roughness = 0.55
	stone_mat.emission_enabled = true
	stone_mat.emission = Color(0.85, 0.40, 1.0)
	stone_mat.emission_energy_multiplier = 0.30
	# 4 wide column pillars
	for ox: float in [-3.0, -1.0, 1.0, 3.0]:
		var col: MeshInstance3D = MeshInstance3D.new()
		var cm: CylinderMesh = CylinderMesh.new()
		cm.top_radius = 0.30
		cm.bottom_radius = 0.40
		cm.height = 4.85
		col.mesh = cm
		col.position = Vector3(ox, 2.42, 0)
		col.material_override = stone_mat
		lib.add_child(col)
		# Per-column collision
		var sb: StaticBody3D = StaticBody3D.new()
		var cs: CollisionShape3D = CollisionShape3D.new()
		var cap: CapsuleShape3D = CapsuleShape3D.new()
		cap.radius = 0.40
		cap.height = 4.85
		cs.shape = cap
		cs.position = Vector3(ox, 2.42, 0)
		sb.add_child(cs)
		lib.add_child(sb)
	# Wide flat lintel on top of columns
	var lintel: MeshInstance3D = MeshInstance3D.new()
	var lm: BoxMesh = BoxMesh.new()
	lm.size = Vector3(7.5, 0.85, 1.40)
	lintel.mesh = lm
	lintel.position = Vector3(0, 5.30, 0)
	lintel.material_override = stone_mat
	lib.add_child(lintel)
	# Tall pointed pediment (prism)
	var pediment: MeshInstance3D = MeshInstance3D.new()
	var pm: PrismMesh = PrismMesh.new()
	pm.size = Vector3(7.5, 1.85, 1.40)
	pediment.mesh = pm
	pediment.position = Vector3(0, 6.65, 0)
	pediment.material_override = stone_mat
	lib.add_child(pediment)
	# Glowing entryway between the middle columns
	var entry: MeshInstance3D = MeshInstance3D.new()
	var em: BoxMesh = BoxMesh.new()
	em.size = Vector3(1.85, 3.40, 0.20)
	entry.mesh = em
	entry.position = Vector3(0, 1.70, 0.55)
	var emat: StandardMaterial3D = StandardMaterial3D.new()
	emat.albedo_color = Color(0.06, 0.04, 0.10)
	emat.emission_enabled = true
	emat.emission = Color(1.0, 0.55, 1.0)
	emat.emission_energy_multiplier = 1.4
	emat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	entry.material_override = emat
	lib.add_child(entry)
	# Glowing rune on pediment
	var rune: Label3D = Label3D.new()
	rune.text = "Φ"
	rune.position = Vector3(0, 6.85, 0.71)
	rune.modulate = Color(1.0, 0.55, 1.0)
	rune.outline_modulate = Color(0, 0, 0, 0.85)
	rune.outline_size = 5
	rune.font_size = 36
	rune.no_depth_test = true
	lib.add_child(rune)
	# Sign above
	var label: Label3D = Label3D.new()
	label.text = "GRAND LIBRARY"
	label.position = Vector3(0, 8.30, 0)
	label.modulate = Color(1.0, 0.55, 1.0)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 6
	label.font_size = 22
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	lib.add_child(label)


func _build_d3_starlight_projector(geom: Node) -> void:
	## Epic-3 T59: a starlight projector — small floor-mounted gem that
	## projects a circle of 24 small stars on the floor around it.
	var proj: Node3D = Node3D.new()
	proj.name = "D3StarlightProjector"
	proj.position = D3_CENTER + Vector3(12, 0.06, 18)
	geom.add_child(proj)
	# Center gem
	var gem: MeshInstance3D = MeshInstance3D.new()
	var gm: SphereMesh = SphereMesh.new()
	gm.radius = 0.30
	gm.height = 0.60
	gem.mesh = gm
	gem.position = Vector3(0, 0.30, 0)
	var gmat: StandardMaterial3D = StandardMaterial3D.new()
	gmat.albedo_color = Color(0.85, 0.40, 1.0)
	gmat.emission_enabled = true
	gmat.emission = Color(1.0, 0.55, 1.0)
	gmat.emission_energy_multiplier = 3.0
	gmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	gem.material_override = gmat
	proj.add_child(gem)
	# 24 floor stars in a ring
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 200
	var star_mat: StandardMaterial3D = StandardMaterial3D.new()
	star_mat.albedo_color = Color(1, 1, 1)
	star_mat.emission_enabled = true
	star_mat.emission = Color(1, 1, 1)
	star_mat.emission_energy_multiplier = 2.6
	star_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for i in 24:
		var angle: float = rng.randf() * TAU
		var dist: float = rng.randf_range(1.20, 4.0)
		var star: MeshInstance3D = MeshInstance3D.new()
		var sm: SphereMesh = SphereMesh.new()
		sm.radius = 0.06
		sm.height = 0.12
		star.mesh = sm
		star.position = Vector3(cos(angle) * dist, 0.04, sin(angle) * dist)
		star.material_override = star_mat
		proj.add_child(star)
		# Twinkle
		var twk: Tween = create_tween().set_loops()
		twk.tween_property(star, "scale", Vector3(0.4, 0.4, 0.4), 0.6 + rng.randf() * 0.4).set_ease(Tween.EASE_IN_OUT)
		twk.tween_property(star, "scale", Vector3(1.4, 1.4, 1.4), 0.6 + rng.randf() * 0.4).set_ease(Tween.EASE_IN_OUT)


func _build_d3_data_dragon(geom: Node) -> void:
	## Epic-3 T60: a floating data dragon — long serpentine body made of
	## 8 connected emissive cube segments that drift in a sinuous pattern.
	var dragon: Node3D = Node3D.new()
	dragon.name = "D3DataDragon"
	dragon.position = D3_CENTER + Vector3(0, 6, -12)
	geom.add_child(dragon)
	# 8 body segments in a chain
	var dragon_mat: StandardMaterial3D = StandardMaterial3D.new()
	dragon_mat.albedo_color = Color(0.30, 0.85, 1.0)
	dragon_mat.emission_enabled = true
	dragon_mat.emission = Color(0.55, 0.95, 1.0)
	dragon_mat.emission_energy_multiplier = 2.4
	dragon_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for i in 8:
		var seg: MeshInstance3D = MeshInstance3D.new()
		var sm: BoxMesh = BoxMesh.new()
		sm.size = Vector3(0.65 - i * 0.04, 0.65 - i * 0.04, 0.65 - i * 0.04)
		seg.mesh = sm
		seg.position = Vector3(-i * 0.85, sin(i * 0.5) * 0.40, 0)
		seg.material_override = dragon_mat
		dragon.add_child(seg)
	# Head — bigger box at index 0 already, add eyes
	var eye_mat: StandardMaterial3D = StandardMaterial3D.new()
	eye_mat.albedo_color = Color(1, 1, 1)
	eye_mat.emission_enabled = true
	eye_mat.emission = Color(1, 1, 1)
	eye_mat.emission_energy_multiplier = 3.4
	eye_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for ex: float in [-0.18, 0.18]:
		var eye: MeshInstance3D = MeshInstance3D.new()
		var em: SphereMesh = SphereMesh.new()
		em.radius = 0.08
		em.height = 0.16
		eye.mesh = em
		eye.position = Vector3(0, 0.15, 0.34) + Vector3(ex, 0, 0)
		eye.material_override = eye_mat
		dragon.add_child(eye)
	# Slow patrol path circling overhead
	var origin: Vector3 = D3_CENTER + Vector3(0, 6, -12)
	var patrol: Tween = create_tween().set_loops()
	patrol.tween_property(dragon, "position", origin + Vector3(8, 1.5, 0), 8.0).set_ease(Tween.EASE_IN_OUT)
	patrol.tween_property(dragon, "position", origin + Vector3(0, 1.5, 8), 8.0).set_ease(Tween.EASE_IN_OUT)
	patrol.tween_property(dragon, "position", origin + Vector3(-8, 1.5, 0), 8.0).set_ease(Tween.EASE_IN_OUT)
	patrol.tween_property(dragon, "position", origin, 8.0).set_ease(Tween.EASE_IN_OUT)
	# Slow rotation
	var spin: Tween = create_tween().set_loops()
	spin.tween_property(dragon, "rotation:y", TAU, 32.0)
	# Boss-tier name billboard
	var label: Label3D = Label3D.new()
	label.text = "DATA DRAGON"
	label.position = Vector3(-3.5, 1.55, 0)
	label.modulate = Color(0.55, 0.95, 1.0)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 18
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	dragon.add_child(label)


func _build_d3_healing_fountain(geom: Node) -> void:
	## Epic-3 T61: a healing fountain — stone basin with rising green
	## emissive water column + 4 small healing pulse particles flowing
	## outward at the rim.
	var font: Node3D = Node3D.new()
	font.name = "D3HealingFountain"
	font.position = D3_CENTER + Vector3(20, 0, -8)
	geom.add_child(font)
	# Stone basin
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.16, 0.10, 0.20)
	stone_mat.metallic = 0.55
	stone_mat.roughness = 0.45
	var basin: MeshInstance3D = MeshInstance3D.new()
	var bm: CylinderMesh = CylinderMesh.new()
	bm.top_radius = 1.20
	bm.bottom_radius = 1.40
	bm.height = 0.85
	basin.mesh = bm
	basin.position = Vector3(0, 0.42, 0)
	basin.material_override = stone_mat
	font.add_child(basin)
	# Inner glowing green water disc
	var water: MeshInstance3D = MeshInstance3D.new()
	var wm: CylinderMesh = CylinderMesh.new()
	wm.top_radius = 1.0
	wm.bottom_radius = 1.0
	wm.height = 0.06
	water.mesh = wm
	water.position = Vector3(0, 0.85, 0)
	var wmat: StandardMaterial3D = StandardMaterial3D.new()
	wmat.albedo_color = Color(0.40, 1.0, 0.55, 0.85)
	wmat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	wmat.emission_enabled = true
	wmat.emission = Color(0.45, 1.0, 0.55)
	wmat.emission_energy_multiplier = 1.8
	wmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	water.material_override = wmat
	font.add_child(water)
	# Rising water column — small cylinder + GPU particles
	var column: MeshInstance3D = MeshInstance3D.new()
	var cm: CylinderMesh = CylinderMesh.new()
	cm.top_radius = 0.18
	cm.bottom_radius = 0.18
	cm.height = 1.40
	column.mesh = cm
	column.position = Vector3(0, 1.55, 0)
	var cmat: StandardMaterial3D = StandardMaterial3D.new()
	cmat.albedo_color = Color(0.45, 1.0, 0.55, 0.65)
	cmat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	cmat.emission_enabled = true
	cmat.emission = Color(0.55, 1.0, 0.55)
	cmat.emission_energy_multiplier = 2.0
	cmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	column.material_override = cmat
	font.add_child(column)
	# Rising particles
	var sparks: GPUParticles3D = GPUParticles3D.new()
	sparks.amount = 30
	sparks.lifetime = 1.85
	sparks.position = Vector3(0, 1.0, 0)
	var pmat: ParticleProcessMaterial = ParticleProcessMaterial.new()
	pmat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	pmat.emission_sphere_radius = 0.20
	pmat.direction = Vector3(0, 1, 0)
	pmat.spread = 8.0
	pmat.initial_velocity_min = 1.4
	pmat.initial_velocity_max = 2.0
	pmat.gravity = Vector3(0, 0.0, 0)
	pmat.scale_min = 0.10
	pmat.scale_max = 0.18
	pmat.color = Color(0.55, 1.0, 0.55, 1.0)
	sparks.process_material = pmat
	var sm2: SphereMesh = SphereMesh.new()
	sm2.radius = 0.10
	sm2.height = 0.20
	var sm_mat: StandardMaterial3D = StandardMaterial3D.new()
	sm_mat.albedo_color = Color(0.55, 1.0, 0.55)
	sm_mat.emission_enabled = true
	sm_mat.emission = Color(0.55, 1.0, 0.55)
	sm_mat.emission_energy_multiplier = 2.6
	sm_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	sm2.material = sm_mat
	sparks.draw_pass_1 = sm2
	font.add_child(sparks)
	# Sign
	var label: Label3D = Label3D.new()
	label.text = "HEALING FOUNT"
	label.position = Vector3(0, 2.85, 0)
	label.modulate = Color(0.55, 1.0, 0.55)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 16
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	font.add_child(label)
	# Collision around basin
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(2.85, 0.85, 2.85)
	cs.shape = cb
	cs.position = Vector3(0, 0.42, 0)
	sb.add_child(cs)
	font.add_child(sb)


func _build_d3_study_desks(geom: Node) -> void:
	## Epic-3 T62: 3 study desks in a row — wooden tables with stacked
	## books + small inkpot + an open scroll on each.
	var positions: Array[Vector3] = [
		D3_CENTER + Vector3(-18, 0, 8),
		D3_CENTER + Vector3(-18, 0, 11),
		D3_CENTER + Vector3(-18, 0, 14),
	]
	var wood_mat: StandardMaterial3D = StandardMaterial3D.new()
	wood_mat.albedo_color = Color(0.30, 0.18, 0.10)
	wood_mat.metallic = 0.10
	wood_mat.roughness = 0.65
	for i in positions.size():
		var desk: Node3D = Node3D.new()
		desk.name = "D3StudyDesk_%d" % i
		desk.position = positions[i]
		geom.add_child(desk)
		# Table
		var table: MeshInstance3D = MeshInstance3D.new()
		var tm: BoxMesh = BoxMesh.new()
		tm.size = Vector3(1.40, 0.85, 1.0)
		table.mesh = tm
		table.position = Vector3(0, 0.42, 0)
		table.material_override = wood_mat
		desk.add_child(table)
		# Stack of books
		for b in 3:
			var book: MeshInstance3D = MeshInstance3D.new()
			var bm: BoxMesh = BoxMesh.new()
			bm.size = Vector3(0.55, 0.10, 0.40)
			book.mesh = bm
			book.position = Vector3(-0.40, 0.95 + b * 0.10, 0)
			var bmat: StandardMaterial3D = StandardMaterial3D.new()
			bmat.albedo_color = [Color(0.55, 0.30, 0.30), Color(0.30, 0.55, 0.30), Color(0.30, 0.30, 0.55)][b]
			book.material_override = bmat
			desk.add_child(book)
		# Small inkpot
		var ink: MeshInstance3D = MeshInstance3D.new()
		var im: CylinderMesh = CylinderMesh.new()
		im.top_radius = 0.06
		im.bottom_radius = 0.08
		im.height = 0.18
		ink.mesh = im
		ink.position = Vector3(0.40, 0.94, 0)
		var imat: StandardMaterial3D = StandardMaterial3D.new()
		imat.albedo_color = Color(0.10, 0.10, 0.13)
		imat.metallic = 0.85
		ink.material_override = imat
		desk.add_child(ink)
		# Open glowing scroll
		var scroll: MeshInstance3D = MeshInstance3D.new()
		var sm: BoxMesh = BoxMesh.new()
		sm.size = Vector3(0.55, 0.04, 0.40)
		scroll.mesh = sm
		scroll.position = Vector3(0, 0.87, 0)
		var smat: StandardMaterial3D = StandardMaterial3D.new()
		smat.albedo_color = Color(0.95, 0.85, 0.55)
		smat.emission_enabled = true
		smat.emission = Color(1.0, 0.85, 0.55)
		smat.emission_energy_multiplier = 0.85
		smat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		scroll.material_override = smat
		desk.add_child(scroll)
		# Per-desk collision
		var sb: StaticBody3D = StaticBody3D.new()
		var cs: CollisionShape3D = CollisionShape3D.new()
		var cb: BoxShape3D = BoxShape3D.new()
		cb.size = Vector3(1.40, 0.85, 1.0)
		cs.shape = cb
		cs.position = Vector3(0, 0.42, 0)
		sb.add_child(cs)
		desk.add_child(sb)


func _build_d3_mage_robes(geom: Node) -> void:
	## Epic-3 T63: a coat rack with 3 hanging mage robes in different
	## colors — boxes with conical hat tops.
	var rack: Node3D = Node3D.new()
	rack.name = "D3MageRobes"
	rack.position = D3_CENTER + Vector3(-15, 0, -3)
	geom.add_child(rack)
	# Wooden post
	var post_mat: StandardMaterial3D = StandardMaterial3D.new()
	post_mat.albedo_color = Color(0.30, 0.18, 0.10)
	post_mat.metallic = 0.10
	post_mat.roughness = 0.65
	var post: MeshInstance3D = MeshInstance3D.new()
	var pmesh: CylinderMesh = CylinderMesh.new()
	pmesh.top_radius = 0.07
	pmesh.bottom_radius = 0.10
	pmesh.height = 2.40
	post.mesh = pmesh
	post.position = Vector3(0, 1.20, 0)
	post.material_override = post_mat
	rack.add_child(post)
	# Top crossbar
	var bar: MeshInstance3D = MeshInstance3D.new()
	var bm: BoxMesh = BoxMesh.new()
	bm.size = Vector3(2.0, 0.06, 0.06)
	bar.mesh = bm
	bar.position = Vector3(0, 2.20, 0)
	bar.material_override = post_mat
	rack.add_child(bar)
	# 3 hanging robes
	var robe_colors: Array[Color] = [
		Color(0.55, 0.30, 0.85),
		Color(0.30, 0.55, 0.85),
		Color(0.85, 0.30, 0.55),
	]
	for i in 3:
		var hx: float = -0.65 + i * 0.65
		# Robe body — narrow box
		var robe: MeshInstance3D = MeshInstance3D.new()
		var rm: BoxMesh = BoxMesh.new()
		rm.size = Vector3(0.55, 1.40, 0.18)
		robe.mesh = rm
		robe.position = Vector3(hx, 1.40, 0)
		var rmat: StandardMaterial3D = StandardMaterial3D.new()
		rmat.albedo_color = robe_colors[i]
		rmat.emission_enabled = true
		rmat.emission = robe_colors[i]
		rmat.emission_energy_multiplier = 0.55
		rmat.metallic = 0.20
		rmat.roughness = 0.55
		robe.material_override = rmat
		rack.add_child(robe)
		# Conical hat on top
		var hat: MeshInstance3D = MeshInstance3D.new()
		var hm: PrismMesh = PrismMesh.new()
		hm.size = Vector3(0.40, 0.55, 0.40)
		hat.mesh = hm
		hat.position = Vector3(hx, 2.40, 0)
		hat.material_override = rmat
		rack.add_child(hat)
	# Sign
	var label: Label3D = Label3D.new()
	label.text = "ROBES"
	label.position = Vector3(0, 3.0, 0)
	label.modulate = Color(0.85, 0.55, 1.0)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 14
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	rack.add_child(label)
	# Collision
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(2.20, 2.40, 0.30)
	cs.shape = cb
	cs.position = Vector3(0, 1.20, 0)
	sb.add_child(cs)
	rack.add_child(sb)


func _build_d3_fortune_teller_npc(town: Node) -> void:
	## Epic-3 T64: Fortune Teller NPC sitting at a small round table with
	## a glowing crystal ball in front. Has a scarf wrapped around the head.
	var slots: Node3D = town.get_node_or_null("%NPCSlots") as Node3D
	if slots == null:
		return
	var teller: Node3D = Node3D.new()
	teller.name = "D3FortuneTeller"
	teller.position = D3_CENTER + Vector3(-12, 0, -8)
	slots.add_child(teller)
	# Round table
	var table_mat: StandardMaterial3D = StandardMaterial3D.new()
	table_mat.albedo_color = Color(0.30, 0.18, 0.10)
	table_mat.metallic = 0.10
	table_mat.roughness = 0.65
	var table: MeshInstance3D = MeshInstance3D.new()
	var tm: CylinderMesh = CylinderMesh.new()
	tm.top_radius = 0.55
	tm.bottom_radius = 0.55
	tm.height = 0.85
	table.mesh = tm
	table.position = Vector3(0, 0.42, 0.85)
	table.material_override = table_mat
	teller.add_child(table)
	# Crystal ball on the table
	var ball: MeshInstance3D = MeshInstance3D.new()
	var bm: SphereMesh = SphereMesh.new()
	bm.radius = 0.20
	bm.height = 0.40
	ball.mesh = bm
	ball.position = Vector3(0, 1.0, 0.85)
	var bmat: StandardMaterial3D = StandardMaterial3D.new()
	bmat.albedo_color = Color(0.85, 0.55, 1.0, 0.55)
	bmat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	bmat.emission_enabled = true
	bmat.emission = Color(1.0, 0.55, 1.0)
	bmat.emission_energy_multiplier = 2.6
	bmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	ball.material_override = bmat
	teller.add_child(ball)
	# Body — short capsule (sitting)
	var bbmat: StandardMaterial3D = StandardMaterial3D.new()
	bbmat.albedo_color = Color(0.30, 0.10, 0.30)
	bbmat.metallic = 0.20
	bbmat.roughness = 0.65
	bbmat.emission_enabled = true
	bbmat.emission = Color(1.0, 0.30, 0.65)
	bbmat.emission_energy_multiplier = 0.40
	var body: MeshInstance3D = MeshInstance3D.new()
	var bmesh: CapsuleMesh = CapsuleMesh.new()
	bmesh.radius = 0.40
	bmesh.height = 0.85
	body.mesh = bmesh
	body.position = Vector3(0, 0.45, 0)
	body.material_override = bbmat
	teller.add_child(body)
	# Wrapped scarf head — sphere
	var head: MeshInstance3D = MeshInstance3D.new()
	var hm: SphereMesh = SphereMesh.new()
	hm.radius = 0.36
	hm.height = 0.65
	head.mesh = hm
	head.position = Vector3(0, 1.0, 0)
	var hmat: StandardMaterial3D = StandardMaterial3D.new()
	hmat.albedo_color = Color(0.85, 0.30, 0.65)
	hmat.metallic = 0.20
	hmat.roughness = 0.65
	hmat.emission_enabled = true
	hmat.emission = Color(1.0, 0.40, 0.65)
	hmat.emission_energy_multiplier = 0.55
	head.material_override = hmat
	teller.add_child(head)
	# 2 small white eyes
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
		eye.position = Vector3(ex, 1.0, 0.32)
		eye.material_override = eye_mat
		teller.add_child(eye)
	# Pulse the ball
	var pulse: Tween = create_tween().set_loops()
	pulse.tween_property(ball, "scale", Vector3(1.30, 1.30, 1.30), 1.4).set_ease(Tween.EASE_IN_OUT)
	pulse.tween_property(ball, "scale", Vector3(0.85, 0.85, 0.85), 1.4).set_ease(Tween.EASE_IN_OUT)
	# Name billboard
	var label: Label3D = Label3D.new()
	label.text = "Fortune Teller"
	label.position = Vector3(0, 1.85, 0)
	label.modulate = Color(1.0, 0.55, 0.85)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 18
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	teller.add_child(label)


func _build_d3_tarot_cards(geom: Node) -> void:
	## Epic-3 T65: 6 floating tarot cards near the fortune teller — small
	## rectangles in different colors with floating animation.
	var positions: Array[Vector3] = [
		D3_CENTER + Vector3(-13, 1.5, -6),
		D3_CENTER + Vector3(-12, 1.8, -6),
		D3_CENTER + Vector3(-11, 1.5, -6),
		D3_CENTER + Vector3(-13, 2.4, -7),
		D3_CENTER + Vector3(-12, 2.7, -7),
		D3_CENTER + Vector3(-11, 2.4, -7),
	]
	var card_colors: Array[Color] = [
		Color(0.55, 0.95, 1.0),
		Color(1.0, 0.55, 0.20),
		Color(0.45, 1.0, 0.55),
		Color(0.85, 0.40, 1.0),
		Color(1.0, 0.95, 0.30),
		Color(1.0, 0.30, 0.55),
	]
	for i in positions.size():
		var card: MeshInstance3D = MeshInstance3D.new()
		card.name = "D3TarotCard_%d" % i
		var cmesh: BoxMesh = BoxMesh.new()
		cmesh.size = Vector3(0.30, 0.55, 0.04)
		card.mesh = cmesh
		card.position = positions[i]
		var cmat: StandardMaterial3D = StandardMaterial3D.new()
		cmat.albedo_color = card_colors[i]
		cmat.emission_enabled = true
		cmat.emission = card_colors[i]
		cmat.emission_energy_multiplier = 1.6
		cmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		card.material_override = cmat
		geom.add_child(card)
		# Bob and slow rotation
		var bob: Tween = create_tween().set_loops()
		var origin_y: float = positions[i].y
		bob.tween_property(card, "position:y", origin_y + 0.30, 1.4 + i * 0.1).set_ease(Tween.EASE_IN_OUT)
		bob.tween_property(card, "position:y", origin_y, 1.4 + i * 0.1).set_ease(Tween.EASE_IN_OUT)
		var spin: Tween = create_tween().set_loops()
		spin.tween_property(card, "rotation:y", TAU, 5.0 + i * 0.5)


func _build_d3_sky_chimes(geom: Node) -> void:
	## Epic-3 T66: 5 hanging sky chimes — long thin metal cylinders
	## hanging from a horizontal bar between 2 tall poles, swinging
	## gently as if in a breeze.
	var chimes: Node3D = Node3D.new()
	chimes.name = "D3SkyChimes"
	chimes.position = D3_CENTER + Vector3(15, 0, 4)
	geom.add_child(chimes)
	# 2 tall poles
	var pole_mat: StandardMaterial3D = StandardMaterial3D.new()
	pole_mat.albedo_color = Color(0.10, 0.06, 0.18)
	pole_mat.metallic = 0.55
	pole_mat.roughness = 0.45
	for sx: float in [-1.40, 1.40]:
		var pole: MeshInstance3D = MeshInstance3D.new()
		var pmesh: CylinderMesh = CylinderMesh.new()
		pmesh.top_radius = 0.07
		pmesh.bottom_radius = 0.10
		pmesh.height = 3.40
		pole.mesh = pmesh
		pole.position = Vector3(sx, 1.70, 0)
		pole.material_override = pole_mat
		chimes.add_child(pole)
		# Collision per pole
		var sb: StaticBody3D = StaticBody3D.new()
		var cs: CollisionShape3D = CollisionShape3D.new()
		var cap: CapsuleShape3D = CapsuleShape3D.new()
		cap.radius = 0.20
		cap.height = 3.40
		cs.shape = cap
		cs.position = Vector3(sx, 1.70, 0)
		sb.add_child(cs)
		chimes.add_child(sb)
	# Top bar
	var bar: MeshInstance3D = MeshInstance3D.new()
	var bm: BoxMesh = BoxMesh.new()
	bm.size = Vector3(3.0, 0.10, 0.10)
	bar.mesh = bm
	bar.position = Vector3(0, 3.40, 0)
	bar.material_override = pole_mat
	chimes.add_child(bar)
	# 5 hanging chimes pivoted from the bar
	var chime_mat: StandardMaterial3D = StandardMaterial3D.new()
	chime_mat.albedo_color = Color(0.85, 0.85, 0.95)
	chime_mat.metallic = 0.85
	chime_mat.roughness = 0.20
	chime_mat.emission_enabled = true
	chime_mat.emission = Color(0.55, 0.95, 1.0)
	chime_mat.emission_energy_multiplier = 0.85
	for i in 5:
		var pivot: Node3D = Node3D.new()
		pivot.position = Vector3(-1.10 + i * 0.55, 3.40, 0)
		chimes.add_child(pivot)
		var chime: MeshInstance3D = MeshInstance3D.new()
		var cmesh: CylinderMesh = CylinderMesh.new()
		cmesh.top_radius = 0.06
		cmesh.bottom_radius = 0.06
		cmesh.height = 0.85 + i * 0.10
		chime.mesh = cmesh
		chime.position = Vector3(0, -(0.85 + i * 0.10) * 0.5, 0)
		chime.material_override = chime_mat
		pivot.add_child(chime)
		# Sway tween
		var sway: Tween = create_tween().set_loops()
		sway.tween_property(pivot, "rotation:x", deg_to_rad(8 + i * 2), 0.85 + i * 0.1).set_ease(Tween.EASE_IN_OUT)
		sway.tween_property(pivot, "rotation:x", deg_to_rad(-8 - i * 2), 0.85 + i * 0.1).set_ease(Tween.EASE_IN_OUT)


func _build_d3_spirit_altars(geom: Node) -> void:
	## Epic-3 T67: 3 small spirit altars in a row — stone pedestals each
	## with a glowing offering bowl on top + flame.
	var positions: Array[Vector3] = [
		D3_CENTER + Vector3(15, 0, -3),
		D3_CENTER + Vector3(15, 0, 0),
		D3_CENTER + Vector3(15, 0, 3),
	]
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.16, 0.10, 0.20)
	stone_mat.metallic = 0.55
	stone_mat.roughness = 0.45
	var flame_mat: StandardMaterial3D = StandardMaterial3D.new()
	flame_mat.albedo_color = Color(0.85, 0.40, 1.0)
	flame_mat.emission_enabled = true
	flame_mat.emission = Color(1.0, 0.55, 1.0)
	flame_mat.emission_energy_multiplier = 2.6
	flame_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for i in positions.size():
		var altar: Node3D = Node3D.new()
		altar.name = "D3SpiritAltar_%d" % i
		altar.position = positions[i]
		geom.add_child(altar)
		# Pedestal
		var ped: MeshInstance3D = MeshInstance3D.new()
		var pm: BoxMesh = BoxMesh.new()
		pm.size = Vector3(0.85, 1.0, 0.85)
		ped.mesh = pm
		ped.position = Vector3(0, 0.50, 0)
		ped.material_override = stone_mat
		altar.add_child(ped)
		# Bowl on top
		var bowl: MeshInstance3D = MeshInstance3D.new()
		var bm: CylinderMesh = CylinderMesh.new()
		bm.top_radius = 0.30
		bm.bottom_radius = 0.18
		bm.height = 0.20
		bowl.mesh = bm
		bowl.position = Vector3(0, 1.10, 0)
		bowl.material_override = stone_mat
		altar.add_child(bowl)
		# Flame inside
		var flame: MeshInstance3D = MeshInstance3D.new()
		var fmesh: SphereMesh = SphereMesh.new()
		fmesh.radius = 0.18
		fmesh.height = 0.36
		flame.mesh = fmesh
		flame.position = Vector3(0, 1.30, 0)
		flame.material_override = flame_mat
		altar.add_child(flame)
		# Pulse the flame
		var pulse: Tween = create_tween().set_loops()
		pulse.tween_property(flame, "scale", Vector3(1.30, 1.30, 1.30), 0.6 + i * 0.1).set_ease(Tween.EASE_IN_OUT)
		pulse.tween_property(flame, "scale", Vector3(0.85, 0.85, 0.85), 0.6 + i * 0.1).set_ease(Tween.EASE_IN_OUT)
		# Per-altar collision
		var sb: StaticBody3D = StaticBody3D.new()
		var cs: CollisionShape3D = CollisionShape3D.new()
		var cb: BoxShape3D = BoxShape3D.new()
		cb.size = Vector3(0.85, 1.0, 0.85)
		cs.shape = cb
		cs.position = Vector3(0, 0.50, 0)
		sb.add_child(cs)
		altar.add_child(sb)


func _build_d3_floating_crown(geom: Node) -> void:
	## Epic-3 T68: a massive floating crown landmark — large 5-pronged
	## golden crown ring suspended above the judgment dais.
	var crown: Node3D = Node3D.new()
	crown.name = "D3FloatingCrown"
	crown.position = D3_CENTER + Vector3(-15, 6, 14)
	geom.add_child(crown)
	# Crown band — torus
	var band: MeshInstance3D = MeshInstance3D.new()
	var bm: TorusMesh = TorusMesh.new()
	bm.inner_radius = 1.20
	bm.outer_radius = 1.40
	band.mesh = bm
	var bmat: StandardMaterial3D = StandardMaterial3D.new()
	bmat.albedo_color = Color(1.0, 0.85, 0.30)
	bmat.metallic = 0.85
	bmat.roughness = 0.20
	bmat.emission_enabled = true
	bmat.emission = Color(1.0, 0.95, 0.30)
	bmat.emission_energy_multiplier = 1.8
	band.material_override = bmat
	crown.add_child(band)
	# 5 vertical prongs around the band
	for i in 5:
		var angle: float = (float(i) / 5.0) * TAU
		var prong: MeshInstance3D = MeshInstance3D.new()
		var pm: PrismMesh = PrismMesh.new()
		pm.size = Vector3(0.20, 0.85, 0.20)
		prong.mesh = pm
		prong.position = Vector3(cos(angle) * 1.30, 0.55, sin(angle) * 1.30)
		prong.material_override = bmat
		crown.add_child(prong)
		# Tip gem at top of each prong
		var gem: MeshInstance3D = MeshInstance3D.new()
		var gm: SphereMesh = SphereMesh.new()
		gm.radius = 0.12
		gm.height = 0.24
		gem.mesh = gm
		gem.position = Vector3(cos(angle) * 1.30, 0.95, sin(angle) * 1.30)
		var gmat: StandardMaterial3D = StandardMaterial3D.new()
		gmat.albedo_color = Color(0.85, 0.40, 1.0)
		gmat.emission_enabled = true
		gmat.emission = Color(1.0, 0.55, 1.0)
		gmat.emission_energy_multiplier = 3.0
		gmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		gem.material_override = gmat
		crown.add_child(gem)
	# Slow rotation
	var spin: Tween = create_tween().set_loops()
	spin.tween_property(crown, "rotation:y", TAU, 12.0)
	# Bob in place
	var bob: Tween = create_tween().set_loops()
	bob.tween_property(crown, "position:y", 6.55, 2.4).set_ease(Tween.EASE_IN_OUT)
	bob.tween_property(crown, "position:y", 6.0, 2.4).set_ease(Tween.EASE_IN_OUT)


func _build_d3_grimoire_stack(geom: Node) -> void:
	## Epic-3 T69: a tall stack of 6 magical grimoires — colored book
	## boxes piled with the top one slightly open and glowing.
	var stack: Node3D = Node3D.new()
	stack.name = "D3GrimoireStack"
	stack.position = D3_CENTER + Vector3(-18, 0, 0)
	geom.add_child(stack)
	var book_colors: Array[Color] = [
		Color(0.55, 0.30, 0.30),
		Color(0.30, 0.55, 0.30),
		Color(0.30, 0.30, 0.55),
		Color(0.55, 0.55, 0.30),
		Color(0.55, 0.30, 0.55),
		Color(0.30, 0.55, 0.55),
	]
	for i in 6:
		var book: MeshInstance3D = MeshInstance3D.new()
		var bm: BoxMesh = BoxMesh.new()
		bm.size = Vector3(0.85, 0.18, 0.55)
		book.mesh = bm
		book.position = Vector3(randf_range(-0.10, 0.10), 0.10 + i * 0.20, randf_range(-0.10, 0.10))
		book.rotation = Vector3(0, deg_to_rad(randf_range(-15, 15)), 0)
		var bmat: StandardMaterial3D = StandardMaterial3D.new()
		bmat.albedo_color = book_colors[i]
		bmat.metallic = 0.10
		bmat.roughness = 0.65
		bmat.emission_enabled = true
		bmat.emission = book_colors[i]
		bmat.emission_energy_multiplier = 0.55
		book.material_override = bmat
		stack.add_child(book)
	# Top open book glowing
	var open_book: MeshInstance3D = MeshInstance3D.new()
	var obm: BoxMesh = BoxMesh.new()
	obm.size = Vector3(0.85, 0.10, 0.55)
	open_book.mesh = obm
	open_book.position = Vector3(0, 1.40, 0)
	var obmat: StandardMaterial3D = StandardMaterial3D.new()
	obmat.albedo_color = Color(0.95, 0.85, 0.55)
	obmat.emission_enabled = true
	obmat.emission = Color(1.0, 0.85, 0.55)
	obmat.emission_energy_multiplier = 1.4
	obmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	open_book.material_override = obmat
	stack.add_child(open_book)
	# Floating glowing rune above the open book
	var rune: MeshInstance3D = MeshInstance3D.new()
	var rm: PrismMesh = PrismMesh.new()
	rm.size = Vector3(0.20, 0.30, 0.20)
	rune.mesh = rm
	rune.position = Vector3(0, 1.85, 0)
	var rmat: StandardMaterial3D = StandardMaterial3D.new()
	rmat.albedo_color = Color(0.85, 0.40, 1.0)
	rmat.emission_enabled = true
	rmat.emission = Color(1.0, 0.55, 1.0)
	rmat.emission_energy_multiplier = 2.6
	rmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	rune.material_override = rmat
	stack.add_child(rune)
	# Bob the rune
	var bob: Tween = create_tween().set_loops()
	bob.tween_property(rune, "position:y", 2.10, 1.4).set_ease(Tween.EASE_IN_OUT)
	bob.tween_property(rune, "position:y", 1.85, 1.4).set_ease(Tween.EASE_IN_OUT)
	# Per-stack collision
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(0.95, 1.40, 0.65)
	cs.shape = cb
	cs.position = Vector3(0, 0.70, 0)
	sb.add_child(cs)
	stack.add_child(sb)


func _build_d3_monk_npc(town: Node) -> void:
	## Epic-3 T70: a Monk NPC walking a circular path around the great
	## crystal — slow continuous patrol on a circle.
	var slots: Node3D = town.get_node_or_null("%NPCSlots") as Node3D
	if slots == null:
		return
	var monk: Node3D = Node3D.new()
	monk.name = "D3Monk"
	monk.position = D3_CENTER + Vector3(8, 0, 0)
	slots.add_child(monk)
	# Robed body
	var bmat: StandardMaterial3D = StandardMaterial3D.new()
	bmat.albedo_color = Color(0.30, 0.20, 0.10)
	bmat.metallic = 0.10
	bmat.roughness = 0.65
	bmat.emission_enabled = true
	bmat.emission = Color(0.85, 0.55, 0.20)
	bmat.emission_energy_multiplier = 0.30
	var body: MeshInstance3D = MeshInstance3D.new()
	var bmesh: CapsuleMesh = CapsuleMesh.new()
	bmesh.radius = 0.42
	bmesh.height = 1.30
	body.mesh = bmesh
	body.position = Vector3(0, 0.70, 0)
	body.material_override = bmat
	monk.add_child(body)
	# Wide hood
	var hood: MeshInstance3D = MeshInstance3D.new()
	var hm: SphereMesh = SphereMesh.new()
	hm.radius = 0.45
	hm.height = 0.55
	hood.mesh = hm
	hood.position = Vector3(0, 1.55, 0)
	hood.material_override = bmat
	monk.add_child(hood)
	# Bald head — small sphere visible from hood
	var head: MeshInstance3D = MeshInstance3D.new()
	var hmesh: SphereMesh = SphereMesh.new()
	hmesh.radius = 0.30
	hmesh.height = 0.55
	head.mesh = hmesh
	head.position = Vector3(0, 1.55, 0.10)
	var hmat: StandardMaterial3D = StandardMaterial3D.new()
	hmat.albedo_color = Color(0.85, 0.55, 0.30)
	hmat.metallic = 0.10
	hmat.roughness = 0.55
	head.material_override = hmat
	monk.add_child(head)
	# 2 closed eye dots (small black bars)
	var eye_mat: StandardMaterial3D = StandardMaterial3D.new()
	eye_mat.albedo_color = Color(0.05, 0.05, 0.10)
	eye_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for ex: float in [-0.08, 0.08]:
		var eye: MeshInstance3D = MeshInstance3D.new()
		var em: BoxMesh = BoxMesh.new()
		em.size = Vector3(0.06, 0.02, 0.04)
		eye.mesh = em
		eye.position = Vector3(ex, 1.58, 0.36)
		eye.material_override = eye_mat
		monk.add_child(eye)
	# Hands clasped in prayer in front (small sphere)
	var hands: MeshInstance3D = MeshInstance3D.new()
	var hands_mesh: SphereMesh = SphereMesh.new()
	hands_mesh.radius = 0.12
	hands_mesh.height = 0.24
	hands.mesh = hands_mesh
	hands.position = Vector3(0, 0.85, 0.45)
	hands.material_override = hmat
	monk.add_child(hands)
	# Walking circular path tween — 4 quarter-turns around the crystal
	var center: Vector3 = D3_CENTER
	var radius: float = 8.0
	var monk_path: Tween = create_tween().set_loops()
	for step in 8:
		var angle: float = (float(step) / 8.0) * TAU
		var target: Vector3 = center + Vector3(cos(angle) * radius, 0, sin(angle) * radius)
		monk_path.tween_property(monk, "position", target, 4.0).set_ease(Tween.EASE_IN_OUT)
		monk_path.tween_property(monk, "rotation:y", -angle, 0.3)
	# Name billboard
	var label: Label3D = Label3D.new()
	label.text = "Monk"
	label.position = Vector3(0, 2.20, 0)
	label.modulate = Color(1.0, 0.85, 0.55)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 18
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	monk.add_child(label)


func _build_d3_conjurer_npc(town: Node) -> void:
	## Epic-3 T71: Conjurer NPC with a small familiar floating beside.
	## Wide-brimmed pointy hat, robe, and a small wisp creature orbiting.
	var slots: Node3D = town.get_node_or_null("%NPCSlots") as Node3D
	if slots == null:
		return
	var conj: Node3D = Node3D.new()
	conj.name = "D3Conjurer"
	conj.position = D3_CENTER + Vector3(-3, 0, -8)
	slots.add_child(conj)
	# Body
	var bmat: StandardMaterial3D = StandardMaterial3D.new()
	bmat.albedo_color = Color(0.30, 0.20, 0.40)
	bmat.metallic = 0.20
	bmat.roughness = 0.65
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
	conj.add_child(body)
	# Wide-brim hat — flat torus + tall prism
	var brim: MeshInstance3D = MeshInstance3D.new()
	var brmesh: TorusMesh = TorusMesh.new()
	brmesh.inner_radius = 0.40
	brmesh.outer_radius = 0.65
	brim.mesh = brmesh
	brim.position = Vector3(0, 1.65, 0)
	brim.material_override = bmat
	conj.add_child(brim)
	var hat_top: MeshInstance3D = MeshInstance3D.new()
	var htm: PrismMesh = PrismMesh.new()
	htm.size = Vector3(0.55, 0.85, 0.55)
	hat_top.mesh = htm
	hat_top.position = Vector3(0, 2.10, 0)
	hat_top.material_override = bmat
	conj.add_child(hat_top)
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
		em.radius = 0.06
		em.height = 0.12
		eye.mesh = em
		eye.position = Vector3(ex, 1.40, 0.32)
		eye.material_override = eye_mat
		conj.add_child(eye)
	# Familiar — small wisp creature orbiting head
	var familiar_pivot: Node3D = Node3D.new()
	familiar_pivot.position = Vector3(0, 1.85, 0)
	conj.add_child(familiar_pivot)
	var familiar: MeshInstance3D = MeshInstance3D.new()
	var fm: SphereMesh = SphereMesh.new()
	fm.radius = 0.18
	fm.height = 0.36
	familiar.mesh = fm
	familiar.position = Vector3(0.85, 0, 0)
	var fmat: StandardMaterial3D = StandardMaterial3D.new()
	fmat.albedo_color = Color(0.55, 0.95, 1.0)
	fmat.emission_enabled = true
	fmat.emission = Color(0.55, 0.95, 1.0)
	fmat.emission_energy_multiplier = 3.0
	fmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	familiar.material_override = fmat
	familiar_pivot.add_child(familiar)
	# 2 small white eyes on the familiar
	for ex: float in [-0.06, 0.06]:
		var f_eye: MeshInstance3D = MeshInstance3D.new()
		var fem: SphereMesh = SphereMesh.new()
		fem.radius = 0.03
		fem.height = 0.06
		f_eye.mesh = fem
		f_eye.position = Vector3(0.85 + ex, 0.04, 0.18)
		var femat: StandardMaterial3D = StandardMaterial3D.new()
		femat.albedo_color = Color(1, 1, 1)
		femat.emission_enabled = true
		femat.emission = Color(1, 1, 1)
		femat.emission_energy_multiplier = 3.0
		femat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		f_eye.material_override = femat
		familiar_pivot.add_child(f_eye)
	# Orbit familiar
	var orbit: Tween = create_tween().set_loops()
	orbit.tween_property(familiar_pivot, "rotation:y", TAU, 4.0)
	# Name billboard
	var label: Label3D = Label3D.new()
	label.text = "Conjurer"
	label.position = Vector3(0, 3.0, 0)
	label.modulate = Color(0.85, 0.55, 1.0)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 18
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	conj.add_child(label)


func _build_d3_map_wall(geom: Node) -> void:
	## Epic-3 T72: ancient map wall — large flat wall covered with 6
	## colored map fragment boxes pinned in a grid pattern.
	var wall_root: Node3D = Node3D.new()
	wall_root.name = "D3MapWall"
	wall_root.position = D3_CENTER + Vector3(-22, 0, -2)
	geom.add_child(wall_root)
	# Wall slab
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.16, 0.10, 0.20)
	stone_mat.metallic = 0.55
	stone_mat.roughness = 0.45
	var wall: MeshInstance3D = MeshInstance3D.new()
	var wm: BoxMesh = BoxMesh.new()
	wm.size = Vector3(0.30, 4.0, 5.0)
	wall.mesh = wm
	wall.position = Vector3(0, 2.0, 0)
	wall.material_override = stone_mat
	wall_root.add_child(wall)
	# 6 map fragments in a 3x2 grid
	var map_colors: Array[Color] = [
		Color(0.55, 0.95, 1.0),
		Color(0.45, 1.0, 0.55),
		Color(1.0, 0.55, 0.20),
		Color(0.85, 0.40, 1.0),
		Color(1.0, 0.95, 0.30),
		Color(1.0, 0.30, 0.55),
	]
	for r in 2:
		for c in 3:
			var i: int = r * 3 + c
			var frag: MeshInstance3D = MeshInstance3D.new()
			var fm: BoxMesh = BoxMesh.new()
			fm.size = Vector3(0.10, 1.20, 1.20)
			frag.mesh = fm
			frag.position = Vector3(0.21, 1.30 + r * 1.40, -1.50 + c * 1.50)
			var fmat: StandardMaterial3D = StandardMaterial3D.new()
			fmat.albedo_color = map_colors[i]
			fmat.emission_enabled = true
			fmat.emission = map_colors[i]
			fmat.emission_energy_multiplier = 1.0
			fmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
			frag.material_override = fmat
			wall_root.add_child(frag)
	# Sign
	var label: Label3D = Label3D.new()
	label.text = "STAR MAPS"
	label.position = Vector3(0, 4.40, 0)
	label.modulate = Color(0.85, 0.55, 1.0)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 16
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	wall_root.add_child(label)
	# Collision
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(0.30, 4.0, 5.0)
	cs.shape = cb
	cs.position = Vector3(0, 2.0, 0)
	sb.add_child(cs)
	wall_root.add_child(sb)


func _build_d3_dust_orbs(geom: Node) -> void:
	## Epic-3 T73: 12 small floating dust orbs scattered through the
	## district airspace at varied heights — pulsing emissive spheres.
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 233
	for i in 12:
		var orb: MeshInstance3D = MeshInstance3D.new()
		orb.name = "D3DustOrb_%d" % i
		var om: SphereMesh = SphereMesh.new()
		om.radius = 0.10
		om.height = 0.20
		orb.mesh = om
		orb.position = D3_CENTER + Vector3(
			rng.randf_range(-22, 22),
			rng.randf_range(2, 10),
			rng.randf_range(-16, 16)
		)
		var omat: StandardMaterial3D = StandardMaterial3D.new()
		omat.albedo_color = Color(1.0, 0.95, 0.55)
		omat.emission_enabled = true
		omat.emission = Color(1.0, 0.95, 0.55)
		omat.emission_energy_multiplier = 2.6
		omat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		orb.material_override = omat
		geom.add_child(orb)
		# Pulse + drift
		var pulse: Tween = create_tween().set_loops()
		var ps: float = 1.0 + rng.randf() * 0.85
		pulse.tween_property(orb, "scale", Vector3(1.40, 1.40, 1.40), ps).set_ease(Tween.EASE_IN_OUT)
		pulse.tween_property(orb, "scale", Vector3(0.85, 0.85, 0.85), ps).set_ease(Tween.EASE_IN_OUT)
		var origin: Vector3 = orb.position
		var drift: Tween = create_tween().set_loops()
		drift.tween_property(orb, "position", origin + Vector3(rng.randf_range(-1, 1), rng.randf_range(-0.5, 0.5), rng.randf_range(-1, 1)), 4.0).set_ease(Tween.EASE_IN_OUT)
		drift.tween_property(orb, "position", origin, 4.0).set_ease(Tween.EASE_IN_OUT)


func _build_d3_altar_circle(geom: Node) -> void:
	## Epic-3 T74: 6 small spirit altars arranged in a circle around a
	## central glow point — like a coven gathering site.
	var circle_root: Node3D = Node3D.new()
	circle_root.name = "D3AltarCircle"
	circle_root.position = D3_CENTER + Vector3(0, 0, -16)
	geom.add_child(circle_root)
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.16, 0.10, 0.20)
	stone_mat.metallic = 0.55
	stone_mat.roughness = 0.45
	for i in 6:
		var angle: float = (float(i) / 6.0) * TAU
		var altar: MeshInstance3D = MeshInstance3D.new()
		altar.name = "AltarCircle_%d" % i
		var am: BoxMesh = BoxMesh.new()
		am.size = Vector3(0.55, 0.85, 0.55)
		altar.mesh = am
		altar.position = Vector3(cos(angle) * 2.40, 0.42, sin(angle) * 2.40)
		altar.material_override = stone_mat
		circle_root.add_child(altar)
		# Top crystal
		var crystal: MeshInstance3D = MeshInstance3D.new()
		var cm: PrismMesh = PrismMesh.new()
		cm.size = Vector3(0.20, 0.40, 0.20)
		crystal.mesh = cm
		crystal.position = Vector3(cos(angle) * 2.40, 1.05, sin(angle) * 2.40)
		var cmat: StandardMaterial3D = StandardMaterial3D.new()
		cmat.albedo_color = Color(0.85, 0.40, 1.0)
		cmat.emission_enabled = true
		cmat.emission = Color(1.0, 0.55, 1.0)
		cmat.emission_energy_multiplier = 2.6
		cmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		crystal.material_override = cmat
		circle_root.add_child(crystal)
		# Per-altar collision
		var sb: StaticBody3D = StaticBody3D.new()
		var cs: CollisionShape3D = CollisionShape3D.new()
		var cb: BoxShape3D = BoxShape3D.new()
		cb.size = Vector3(0.55, 0.85, 0.55)
		cs.shape = cb
		cs.position = Vector3(cos(angle) * 2.40, 0.42, sin(angle) * 2.40)
		sb.add_child(cs)
		circle_root.add_child(sb)
	# Center glow point
	var glow: MeshInstance3D = MeshInstance3D.new()
	var gm: SphereMesh = SphereMesh.new()
	gm.radius = 0.40
	gm.height = 0.80
	glow.mesh = gm
	glow.position = Vector3(0, 0.40, 0)
	var gmat: StandardMaterial3D = StandardMaterial3D.new()
	gmat.albedo_color = Color(1.0, 0.55, 1.0)
	gmat.emission_enabled = true
	gmat.emission = Color(1.0, 0.55, 1.0)
	gmat.emission_energy_multiplier = 3.4
	gmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	glow.material_override = gmat
	circle_root.add_child(glow)
	# Pulse the center
	var pulse: Tween = create_tween().set_loops()
	pulse.tween_property(glow, "scale", Vector3(1.30, 1.30, 1.30), 1.4).set_ease(Tween.EASE_IN_OUT)
	pulse.tween_property(glow, "scale", Vector3(0.85, 0.85, 0.85), 1.4).set_ease(Tween.EASE_IN_OUT)
	# Real OmniLight
	var light: OmniLight3D = OmniLight3D.new()
	light.position = Vector3(0, 0.85, 0)
	light.light_color = Color(1.0, 0.55, 1.0)
	light.light_energy = 2.4
	light.omni_range = 6.0
	circle_root.add_child(light)


func _build_d3_mind_crystals(geom: Node) -> void:
	## Epic-3 T75: a cluster of 8 floating "mind crystals" forming a
	## thinking pattern overhead — small spinning prisms drifting in a
	## brain-like cluster.
	var positions: Array[Vector3] = [
		D3_CENTER + Vector3(8, 6.5, 4),
		D3_CENTER + Vector3(9, 6.5, 5),
		D3_CENTER + Vector3(10, 7.0, 4),
		D3_CENTER + Vector3(9, 6.0, 3),
		D3_CENTER + Vector3(11, 7.0, 5),
		D3_CENTER + Vector3(8, 7.5, 5),
		D3_CENTER + Vector3(10, 6.0, 3),
		D3_CENTER + Vector3(11, 6.5, 4),
	]
	var crystal_mat: StandardMaterial3D = StandardMaterial3D.new()
	crystal_mat.albedo_color = Color(0.55, 0.95, 1.0)
	crystal_mat.emission_enabled = true
	crystal_mat.emission = Color(0.55, 0.95, 1.0)
	crystal_mat.emission_energy_multiplier = 2.4
	crystal_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for i in positions.size():
		var crystal: MeshInstance3D = MeshInstance3D.new()
		crystal.name = "D3MindCrystal_%d" % i
		var cm: PrismMesh = PrismMesh.new()
		cm.size = Vector3(0.20, 0.30, 0.20)
		crystal.mesh = cm
		crystal.position = positions[i]
		crystal.material_override = crystal_mat
		geom.add_child(crystal)
		# Spin + pulse
		var spin: Tween = create_tween().set_loops()
		spin.tween_property(crystal, "rotation:y", TAU, 4.0 + i * 0.3)
		var pulse: Tween = create_tween().set_loops()
		pulse.tween_property(crystal, "scale", Vector3(1.30, 1.30, 1.30), 0.85 + i * 0.1).set_ease(Tween.EASE_IN_OUT)
		pulse.tween_property(crystal, "scale", Vector3(0.85, 0.85, 0.85), 0.85 + i * 0.1).set_ease(Tween.EASE_IN_OUT)


func _build_d3_ascending_stairs(geom: Node) -> void:
	## Epic-3 T76: ascending stone stairs leading up to a high observation
	## platform — 6 wide steps + a square platform at the top.
	var stair: Node3D = Node3D.new()
	stair.name = "D3AscendingStairs"
	stair.position = D3_CENTER + Vector3(20, 0, -16)
	geom.add_child(stair)
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.16, 0.10, 0.20)
	stone_mat.metallic = 0.55
	stone_mat.roughness = 0.45
	stone_mat.emission_enabled = true
	stone_mat.emission = Color(0.85, 0.40, 1.0)
	stone_mat.emission_energy_multiplier = 0.30
	for i in 6:
		var step: MeshInstance3D = MeshInstance3D.new()
		var sm: BoxMesh = BoxMesh.new()
		sm.size = Vector3(2.40, 0.30, 1.20)
		step.mesh = sm
		step.position = Vector3(0, 0.15 + i * 0.30, i * 1.20)
		step.material_override = stone_mat
		stair.add_child(step)
		# Per-step collision
		var sb: StaticBody3D = StaticBody3D.new()
		var cs: CollisionShape3D = CollisionShape3D.new()
		var cb: BoxShape3D = BoxShape3D.new()
		cb.size = Vector3(2.40, 0.30, 1.20)
		cs.shape = cb
		cs.position = Vector3(0, 0.15 + i * 0.30, i * 1.20)
		sb.add_child(cs)
		stair.add_child(sb)
	# Top platform
	var platform: MeshInstance3D = MeshInstance3D.new()
	var pm: BoxMesh = BoxMesh.new()
	pm.size = Vector3(3.40, 0.30, 3.40)
	platform.mesh = pm
	platform.position = Vector3(0, 1.85, 8.40)
	platform.material_override = stone_mat
	stair.add_child(platform)
	# Platform collision
	var psb: StaticBody3D = StaticBody3D.new()
	var pcs: CollisionShape3D = CollisionShape3D.new()
	var pcb: BoxShape3D = BoxShape3D.new()
	pcb.size = Vector3(3.40, 0.30, 3.40)
	pcs.shape = pcb
	pcs.position = Vector3(0, 1.85, 8.40)
	psb.add_child(pcs)
	stair.add_child(psb)


func _build_d3_grand_telescope(geom: Node) -> void:
	## Epic-3 T77: a grand telescope landmark on a tripod stand — large
	## angled cylinder pointing at the sky portal.
	var scope: Node3D = Node3D.new()
	scope.name = "D3GrandTelescope"
	scope.position = D3_CENTER + Vector3(-22, 0, 6)
	geom.add_child(scope)
	# Tripod stand — 3 legs
	var leg_mat: StandardMaterial3D = StandardMaterial3D.new()
	leg_mat.albedo_color = Color(0.10, 0.10, 0.13)
	leg_mat.metallic = 0.85
	leg_mat.roughness = 0.30
	for i in 3:
		var angle: float = (float(i) / 3.0) * TAU
		var leg: MeshInstance3D = MeshInstance3D.new()
		var leg_mesh: CylinderMesh = CylinderMesh.new()
		leg_mesh.top_radius = 0.07
		leg_mesh.bottom_radius = 0.10
		leg_mesh.height = 2.40
		leg.mesh = leg_mesh
		leg.position = Vector3(cos(angle) * 0.55, 1.20, sin(angle) * 0.55)
		leg.rotation = Vector3(sin(angle) * deg_to_rad(20), 0, -cos(angle) * deg_to_rad(20))
		leg.material_override = leg_mat
		scope.add_child(leg)
	# Telescope tube — long angled cylinder
	var tube_mat: StandardMaterial3D = StandardMaterial3D.new()
	tube_mat.albedo_color = Color(0.20, 0.20, 0.28)
	tube_mat.metallic = 0.85
	tube_mat.roughness = 0.30
	tube_mat.emission_enabled = true
	tube_mat.emission = Color(0.85, 0.40, 1.0)
	tube_mat.emission_energy_multiplier = 0.45
	var tube: MeshInstance3D = MeshInstance3D.new()
	var tm: CylinderMesh = CylinderMesh.new()
	tm.top_radius = 0.30
	tm.bottom_radius = 0.40
	tm.height = 2.85
	tube.mesh = tm
	tube.position = Vector3(0, 2.85, 0)
	tube.rotation = Vector3(deg_to_rad(45), 0, 0)
	tube.material_override = tube_mat
	scope.add_child(tube)
	# Glowing lens at the top end
	var lens: MeshInstance3D = MeshInstance3D.new()
	var lm: SphereMesh = SphereMesh.new()
	lm.radius = 0.30
	lm.height = 0.60
	lens.mesh = lm
	lens.position = Vector3(0, 4.0, -1.0)
	var lmat: StandardMaterial3D = StandardMaterial3D.new()
	lmat.albedo_color = Color(0.55, 0.95, 1.0)
	lmat.emission_enabled = true
	lmat.emission = Color(0.55, 0.95, 1.0)
	lmat.emission_energy_multiplier = 3.0
	lmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	lens.material_override = lmat
	scope.add_child(lens)
	# Sign
	var label: Label3D = Label3D.new()
	label.text = "GRAND TELESCOPE"
	label.position = Vector3(0, 5.0, 0)
	label.modulate = Color(0.55, 0.95, 1.0)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 16
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	scope.add_child(label)
	# Collision
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cap: CapsuleShape3D = CapsuleShape3D.new()
	cap.radius = 0.65
	cap.height = 2.40
	cs.shape = cap
	cs.position = Vector3(0, 1.20, 0)
	sb.add_child(cs)
	scope.add_child(sb)


func _build_d3_prayer_chains(geom: Node) -> void:
	## Epic-3 T78: a hanging prayer chain mobile — top horizontal bar
	## with 5 vertical chains, each holding a colored prayer pendant.
	var chains: Node3D = Node3D.new()
	chains.name = "D3PrayerChains"
	chains.position = D3_CENTER + Vector3(0, 4.5, 8)
	geom.add_child(chains)
	# Top bar
	var bar_mat: StandardMaterial3D = StandardMaterial3D.new()
	bar_mat.albedo_color = Color(0.10, 0.10, 0.13)
	bar_mat.metallic = 0.85
	var bar: MeshInstance3D = MeshInstance3D.new()
	var bm: CylinderMesh = CylinderMesh.new()
	bm.top_radius = 0.06
	bm.bottom_radius = 0.06
	bm.height = 2.85
	bar.mesh = bm
	bar.rotation = Vector3(0, 0, deg_to_rad(90))
	bar.material_override = bar_mat
	chains.add_child(bar)
	# 5 hanging chains with pendants
	var pendant_colors: Array[Color] = [
		Color(0.55, 0.95, 1.0),
		Color(1.0, 0.55, 0.20),
		Color(0.45, 1.0, 0.55),
		Color(0.85, 0.40, 1.0),
		Color(1.0, 0.95, 0.30),
	]
	for i in 5:
		var hx: float = -1.20 + i * 0.60
		# Chain — thin cylinder
		var chain: MeshInstance3D = MeshInstance3D.new()
		var cm: CylinderMesh = CylinderMesh.new()
		cm.top_radius = 0.02
		cm.bottom_radius = 0.02
		cm.height = 1.20 + (i % 3) * 0.20
		chain.mesh = cm
		chain.position = Vector3(hx, -(0.60 + (i % 3) * 0.10), 0)
		chain.material_override = bar_mat
		chains.add_child(chain)
		# Pendant at the bottom
		var pendant: MeshInstance3D = MeshInstance3D.new()
		var pmesh: PrismMesh = PrismMesh.new()
		pmesh.size = Vector3(0.18, 0.30, 0.18)
		pendant.mesh = pmesh
		pendant.position = Vector3(hx, -(1.20 + (i % 3) * 0.20), 0)
		var pmat: StandardMaterial3D = StandardMaterial3D.new()
		pmat.albedo_color = pendant_colors[i]
		pmat.emission_enabled = true
		pmat.emission = pendant_colors[i]
		pmat.emission_energy_multiplier = 2.4
		pmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		pendant.material_override = pmat
		chains.add_child(pendant)
	# Sway the entire mobile
	var sway: Tween = create_tween().set_loops()
	sway.tween_property(chains, "rotation:z", deg_to_rad(8), 1.6).set_ease(Tween.EASE_IN_OUT)
	sway.tween_property(chains, "rotation:z", deg_to_rad(-8), 1.6).set_ease(Tween.EASE_IN_OUT)


func _build_d3_dreamcatcher(geom: Node) -> void:
	## Epic-3 T79: a large dreamcatcher mobile — torus rim with 8 thin
	## emissive web threads forming an X pattern + 3 small hanging
	## feathers below.
	var catcher: Node3D = Node3D.new()
	catcher.name = "D3Dreamcatcher"
	catcher.position = D3_CENTER + Vector3(15, 4.5, -4)
	geom.add_child(catcher)
	# Outer torus rim
	var rim_mat: StandardMaterial3D = StandardMaterial3D.new()
	rim_mat.albedo_color = Color(0.85, 0.55, 0.20)
	rim_mat.metallic = 0.40
	rim_mat.roughness = 0.55
	rim_mat.emission_enabled = true
	rim_mat.emission = Color(1.0, 0.65, 0.20)
	rim_mat.emission_energy_multiplier = 0.85
	var rim: MeshInstance3D = MeshInstance3D.new()
	var rmesh: TorusMesh = TorusMesh.new()
	rmesh.inner_radius = 0.85
	rmesh.outer_radius = 1.0
	rim.mesh = rmesh
	rim.rotation = Vector3(deg_to_rad(90), 0, 0)
	rim.material_override = rim_mat
	catcher.add_child(rim)
	# 8 thin web threads in radial pattern
	var web_mat: StandardMaterial3D = StandardMaterial3D.new()
	web_mat.albedo_color = Color(0.85, 0.95, 1.0)
	web_mat.emission_enabled = true
	web_mat.emission = Color(0.85, 0.95, 1.0)
	web_mat.emission_energy_multiplier = 1.4
	web_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for i in 8:
		var angle: float = (float(i) / 8.0) * TAU
		var thread: MeshInstance3D = MeshInstance3D.new()
		var tm: BoxMesh = BoxMesh.new()
		tm.size = Vector3(0.04, 1.85, 0.04)
		thread.mesh = tm
		thread.position = Vector3(0, 0, 0)
		thread.rotation = Vector3(0, 0, angle)
		thread.material_override = web_mat
		catcher.add_child(thread)
	# 3 small hanging feathers below
	for i in 3:
		var feather: MeshInstance3D = MeshInstance3D.new()
		var fm: BoxMesh = BoxMesh.new()
		fm.size = Vector3(0.10, 0.55, 0.04)
		feather.mesh = fm
		feather.position = Vector3(-0.30 + i * 0.30, -1.40, 0)
		var fmat: StandardMaterial3D = StandardMaterial3D.new()
		fmat.albedo_color = [Color(1.0, 0.55, 0.20), Color(0.85, 0.40, 1.0), Color(0.55, 0.95, 1.0)][i]
		fmat.emission_enabled = true
		fmat.emission = fmat.albedo_color
		fmat.emission_energy_multiplier = 0.85
		feather.material_override = fmat
		catcher.add_child(feather)
	# Slow rotation
	var spin: Tween = create_tween().set_loops()
	spin.tween_property(catcher, "rotation:z", TAU, 12.0)


func _build_d3_starseer_npc(town: Node) -> void:
	## Epic-3 T80: Starseer NPC standing on the high observation platform
	## looking up at the sky portal. Has a long telescope held in one hand.
	var slots: Node3D = town.get_node_or_null("%NPCSlots") as Node3D
	if slots == null:
		return
	var seer: Node3D = Node3D.new()
	seer.name = "D3Starseer"
	seer.position = D3_CENTER + Vector3(20, 2.0, -8)
	slots.add_child(seer)
	# Robed body
	var bmat: StandardMaterial3D = StandardMaterial3D.new()
	bmat.albedo_color = Color(0.10, 0.16, 0.30)
	bmat.metallic = 0.20
	bmat.roughness = 0.65
	bmat.emission_enabled = true
	bmat.emission = Color(0.30, 0.55, 0.95)
	bmat.emission_energy_multiplier = 0.40
	var body: MeshInstance3D = MeshInstance3D.new()
	var bmesh: CapsuleMesh = CapsuleMesh.new()
	bmesh.radius = 0.45
	bmesh.height = 1.40
	body.mesh = bmesh
	body.position = Vector3(0, 0.70, 0)
	body.material_override = bmat
	seer.add_child(body)
	# Star-patterned hood
	var hood: MeshInstance3D = MeshInstance3D.new()
	var hmesh: SphereMesh = SphereMesh.new()
	hmesh.radius = 0.45
	hmesh.height = 0.55
	hood.mesh = hmesh
	hood.position = Vector3(0, 1.55, 0)
	hood.material_override = bmat
	seer.add_child(hood)
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
		em.radius = 0.06
		em.height = 0.12
		eye.mesh = em
		eye.position = Vector3(ex, 1.40, 0.34)
		eye.material_override = eye_mat
		seer.add_child(eye)
	# Long telescope held in front pointing upward
	var scope_mat: StandardMaterial3D = StandardMaterial3D.new()
	scope_mat.albedo_color = Color(0.10, 0.10, 0.13)
	scope_mat.metallic = 0.85
	var scope: MeshInstance3D = MeshInstance3D.new()
	var sm: CylinderMesh = CylinderMesh.new()
	sm.top_radius = 0.07
	sm.bottom_radius = 0.10
	sm.height = 1.40
	scope.mesh = sm
	scope.position = Vector3(0.40, 1.30, 0.30)
	scope.rotation = Vector3(deg_to_rad(45), 0, 0)
	scope.material_override = scope_mat
	seer.add_child(scope)
	# Glowing tip
	var tip: MeshInstance3D = MeshInstance3D.new()
	var tm2: SphereMesh = SphereMesh.new()
	tm2.radius = 0.10
	tm2.height = 0.20
	tip.mesh = tm2
	tip.position = Vector3(0.40, 1.85, 0.85)
	var tmat: StandardMaterial3D = StandardMaterial3D.new()
	tmat.albedo_color = Color(0.55, 0.95, 1.0)
	tmat.emission_enabled = true
	tmat.emission = Color(0.55, 0.95, 1.0)
	tmat.emission_energy_multiplier = 3.0
	tmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	tip.material_override = tmat
	seer.add_child(tip)
	# Name billboard
	var label: Label3D = Label3D.new()
	label.text = "Starseer"
	label.position = Vector3(0, 2.20, 0)
	label.modulate = Color(0.55, 0.95, 1.0)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 18
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	seer.add_child(label)


func _build_d3_spell_scrolls(geom: Node) -> void:
	## Epic-3 T81: 8 spell scrolls floating in a cluster — long thin
	## emissive cylinders with rune labels at varying heights.
	var positions: Array[Vector3] = [
		D3_CENTER + Vector3(-15, 2.5, 8),
		D3_CENTER + Vector3(-15, 3.0, 9),
		D3_CENTER + Vector3(-14, 2.5, 9),
		D3_CENTER + Vector3(-16, 2.5, 9),
		D3_CENTER + Vector3(-15, 3.5, 8),
		D3_CENTER + Vector3(-14, 3.5, 8),
		D3_CENTER + Vector3(-16, 3.5, 8),
		D3_CENTER + Vector3(-15, 4.0, 9),
	]
	var scroll_mat: StandardMaterial3D = StandardMaterial3D.new()
	scroll_mat.albedo_color = Color(0.95, 0.85, 0.55)
	scroll_mat.emission_enabled = true
	scroll_mat.emission = Color(1.0, 0.85, 0.55)
	scroll_mat.emission_energy_multiplier = 1.4
	scroll_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for i in positions.size():
		var scroll: MeshInstance3D = MeshInstance3D.new()
		scroll.name = "D3SpellScroll_%d" % i
		var sm: CylinderMesh = CylinderMesh.new()
		sm.top_radius = 0.10
		sm.bottom_radius = 0.10
		sm.height = 0.55
		scroll.mesh = sm
		scroll.position = positions[i]
		scroll.rotation = Vector3(0, 0, deg_to_rad(randf_range(-25, 25)))
		scroll.material_override = scroll_mat
		geom.add_child(scroll)
		# Bob + spin
		var bob: Tween = create_tween().set_loops()
		var origin_y: float = positions[i].y
		bob.tween_property(scroll, "position:y", origin_y + 0.30, 1.4 + i * 0.1).set_ease(Tween.EASE_IN_OUT)
		bob.tween_property(scroll, "position:y", origin_y, 1.4 + i * 0.1).set_ease(Tween.EASE_IN_OUT)
		var spin: Tween = create_tween().set_loops()
		spin.tween_property(scroll, "rotation:y", TAU, 5.0 + i * 0.4)


func _build_d3_cleric_npc(town: Node) -> void:
	## Epic-3 T82: Cleric NPC standing by the healing fountain holding a
	## green glowing healing wand.
	var slots: Node3D = town.get_node_or_null("%NPCSlots") as Node3D
	if slots == null:
		return
	var cleric: Node3D = Node3D.new()
	cleric.name = "D3Cleric"
	cleric.position = D3_CENTER + Vector3(18, 0, -8)
	slots.add_child(cleric)
	# Robed body — white-green
	var bmat: StandardMaterial3D = StandardMaterial3D.new()
	bmat.albedo_color = Color(0.85, 0.95, 0.85)
	bmat.metallic = 0.20
	bmat.roughness = 0.55
	bmat.emission_enabled = true
	bmat.emission = Color(0.45, 1.0, 0.55)
	bmat.emission_energy_multiplier = 0.30
	var body: MeshInstance3D = MeshInstance3D.new()
	var bmesh: CapsuleMesh = CapsuleMesh.new()
	bmesh.radius = 0.45
	bmesh.height = 1.40
	body.mesh = bmesh
	body.position = Vector3(0, 0.70, 0)
	body.material_override = bmat
	cleric.add_child(body)
	# Hood
	var hood: MeshInstance3D = MeshInstance3D.new()
	var hmesh: SphereMesh = SphereMesh.new()
	hmesh.radius = 0.45
	hmesh.height = 0.55
	hood.mesh = hmesh
	hood.position = Vector3(0, 1.55, 0)
	hood.material_override = bmat
	cleric.add_child(hood)
	# 2 green eyes
	var eye_mat: StandardMaterial3D = StandardMaterial3D.new()
	eye_mat.albedo_color = Color(0.55, 1.0, 0.55)
	eye_mat.emission_enabled = true
	eye_mat.emission = Color(0.55, 1.0, 0.55)
	eye_mat.emission_energy_multiplier = 2.6
	eye_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for ex: float in [-0.10, 0.10]:
		var eye: MeshInstance3D = MeshInstance3D.new()
		var em: SphereMesh = SphereMesh.new()
		em.radius = 0.06
		em.height = 0.12
		eye.mesh = em
		eye.position = Vector3(ex, 1.40, 0.34)
		eye.material_override = eye_mat
		cleric.add_child(eye)
	# Healing wand held in front
	var wand: MeshInstance3D = MeshInstance3D.new()
	var wm: CylinderMesh = CylinderMesh.new()
	wm.top_radius = 0.04
	wm.bottom_radius = 0.06
	wm.height = 1.20
	wand.mesh = wm
	wand.position = Vector3(0.45, 1.0, 0)
	var wmat: StandardMaterial3D = StandardMaterial3D.new()
	wmat.albedo_color = Color(0.30, 0.20, 0.10)
	wmat.metallic = 0.30
	wand.material_override = wmat
	cleric.add_child(wand)
	# Glowing tip orb
	var orb: MeshInstance3D = MeshInstance3D.new()
	var om: SphereMesh = SphereMesh.new()
	om.radius = 0.18
	om.height = 0.36
	orb.mesh = om
	orb.position = Vector3(0.45, 1.65, 0)
	var omat: StandardMaterial3D = StandardMaterial3D.new()
	omat.albedo_color = Color(0.55, 1.0, 0.55)
	omat.emission_enabled = true
	omat.emission = Color(0.55, 1.0, 0.55)
	omat.emission_energy_multiplier = 3.0
	omat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	orb.material_override = omat
	cleric.add_child(orb)
	# Pulse the orb
	var pulse: Tween = create_tween().set_loops()
	pulse.tween_property(orb, "scale", Vector3(1.40, 1.40, 1.40), 1.0).set_ease(Tween.EASE_IN_OUT)
	pulse.tween_property(orb, "scale", Vector3(0.85, 0.85, 0.85), 1.0).set_ease(Tween.EASE_IN_OUT)
	# Name billboard
	var label: Label3D = Label3D.new()
	label.text = "Cleric"
	label.position = Vector3(0, 2.20, 0)
	label.modulate = Color(0.55, 1.0, 0.55)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 18
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	cleric.add_child(label)


func _build_d3_ancient_gargoyles(geom: Node) -> void:
	## Epic-3 T83: 3 violet gargoyle statues guarding the sealed gates.
	var positions: Array[Vector3] = [
		D3_CENTER + Vector3(16, 0, -4),
		D3_CENTER + Vector3(16, 0, 4),
		D3_CENTER + Vector3(20, 0, 0),
	]
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.16, 0.10, 0.20)
	stone_mat.metallic = 0.40
	stone_mat.roughness = 0.55
	stone_mat.emission_enabled = true
	stone_mat.emission = Color(0.85, 0.40, 1.0)
	stone_mat.emission_energy_multiplier = 0.30
	for i in positions.size():
		var garg: Node3D = Node3D.new()
		garg.name = "D3AncientGargoyle_%d" % i
		garg.position = positions[i]
		garg.rotation = Vector3(0, deg_to_rad(180 + i * 45), 0)
		geom.add_child(garg)
		# Pedestal
		var ped: MeshInstance3D = MeshInstance3D.new()
		var pm: BoxMesh = BoxMesh.new()
		pm.size = Vector3(0.85, 0.85, 0.85)
		ped.mesh = pm
		ped.position = Vector3(0, 0.42, 0)
		ped.material_override = stone_mat
		garg.add_child(ped)
		# Crouched body
		var body: MeshInstance3D = MeshInstance3D.new()
		var bm: BoxMesh = BoxMesh.new()
		bm.size = Vector3(0.55, 0.55, 0.65)
		body.mesh = bm
		body.position = Vector3(0, 1.10, 0)
		body.material_override = stone_mat
		garg.add_child(body)
		# Head
		var head: MeshInstance3D = MeshInstance3D.new()
		var hm: BoxMesh = BoxMesh.new()
		hm.size = Vector3(0.40, 0.40, 0.40)
		head.mesh = hm
		head.position = Vector3(0, 1.55, 0.10)
		head.material_override = stone_mat
		garg.add_child(head)
		# 2 violet glowing eyes
		var eye_mat: StandardMaterial3D = StandardMaterial3D.new()
		eye_mat.albedo_color = Color(1.0, 0.55, 1.0)
		eye_mat.emission_enabled = true
		eye_mat.emission = Color(1.0, 0.55, 1.0)
		eye_mat.emission_energy_multiplier = 2.6
		eye_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		for ex: float in [-0.08, 0.08]:
			var eye: MeshInstance3D = MeshInstance3D.new()
			var em: SphereMesh = SphereMesh.new()
			em.radius = 0.05
			em.height = 0.10
			eye.mesh = em
			eye.position = Vector3(ex, 1.58, 0.32)
			eye.material_override = eye_mat
			garg.add_child(eye)
		# Wings — angled boxes on the body
		for sx: float in [-0.40, 0.40]:
			var wing: MeshInstance3D = MeshInstance3D.new()
			var wm: BoxMesh = BoxMesh.new()
			wm.size = Vector3(0.10, 0.55, 0.20)
			wing.mesh = wm
			wing.position = Vector3(sx, 1.30, -0.10)
			wing.rotation = Vector3(0, 0, sign(sx) * deg_to_rad(25))
			wing.material_override = stone_mat
			garg.add_child(wing)
		# Per-gargoyle collision
		var sb: StaticBody3D = StaticBody3D.new()
		var cs: CollisionShape3D = CollisionShape3D.new()
		var cb: BoxShape3D = BoxShape3D.new()
		cb.size = Vector3(0.85, 1.85, 0.85)
		cs.shape = cb
		cs.position = Vector3(0, 0.92, 0)
		sb.add_child(cs)
		garg.add_child(sb)


func _build_d3_lone_bell(geom: Node) -> void:
	## Epic-3 T84: a lone tall bell on a stone arch frame near the
	## boundary, swinging gently.
	var bell: Node3D = Node3D.new()
	bell.name = "D3LoneBell"
	bell.position = D3_CENTER + Vector3(-22, 0, 14)
	geom.add_child(bell)
	# 2 frame legs
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.16, 0.10, 0.20)
	stone_mat.metallic = 0.55
	stone_mat.roughness = 0.45
	for sx: float in [-0.85, 0.85]:
		var leg: MeshInstance3D = MeshInstance3D.new()
		var lm: BoxMesh = BoxMesh.new()
		lm.size = Vector3(0.30, 3.40, 0.30)
		leg.mesh = lm
		leg.position = Vector3(sx, 1.70, 0)
		leg.material_override = stone_mat
		bell.add_child(leg)
		# Collision
		var sb: StaticBody3D = StaticBody3D.new()
		var cs: CollisionShape3D = CollisionShape3D.new()
		var cb: BoxShape3D = BoxShape3D.new()
		cb.size = Vector3(0.30, 3.40, 0.30)
		cs.shape = cb
		cs.position = Vector3(sx, 1.70, 0)
		sb.add_child(cs)
		bell.add_child(sb)
	# Crossbar
	var bar: MeshInstance3D = MeshInstance3D.new()
	var bm: BoxMesh = BoxMesh.new()
	bm.size = Vector3(2.0, 0.30, 0.30)
	bar.mesh = bm
	bar.position = Vector3(0, 3.40, 0)
	bar.material_override = stone_mat
	bell.add_child(bar)
	# Pivot for the bell
	var pivot: Node3D = Node3D.new()
	pivot.position = Vector3(0, 3.40, 0)
	bell.add_child(pivot)
	# Bell — wider cylinder + half sphere
	var bell_mat: StandardMaterial3D = StandardMaterial3D.new()
	bell_mat.albedo_color = Color(0.85, 0.65, 0.30)
	bell_mat.emission_enabled = true
	bell_mat.emission = Color(1.0, 0.75, 0.30)
	bell_mat.emission_energy_multiplier = 0.85
	bell_mat.metallic = 0.85
	bell_mat.roughness = 0.20
	var bell_body: MeshInstance3D = MeshInstance3D.new()
	var bbm: CylinderMesh = CylinderMesh.new()
	bbm.top_radius = 0.30
	bbm.bottom_radius = 0.55
	bbm.height = 0.85
	bell_body.mesh = bbm
	bell_body.position = Vector3(0, -0.65, 0)
	bell_body.material_override = bell_mat
	pivot.add_child(bell_body)
	# Swing tween
	var swing: Tween = create_tween().set_loops()
	swing.tween_property(pivot, "rotation:z", deg_to_rad(15), 1.4).set_ease(Tween.EASE_IN_OUT)
	swing.tween_property(pivot, "rotation:z", deg_to_rad(-15), 1.4).set_ease(Tween.EASE_IN_OUT)


func _build_d3_dream_eater(geom: Node) -> void:
	## Epic-3 T85: DREAM EATER 3rd mini-boss — a wide hovering creature
	## with translucent tentacle arms hanging down. Slow drift patrol.
	var eater: Node3D = Node3D.new()
	eater.name = "D3DreamEater"
	eater.position = D3_CENTER + Vector3(-20, 4, 8)
	geom.add_child(eater)
	# Wide hovering body — flattened sphere
	var bmat: StandardMaterial3D = StandardMaterial3D.new()
	bmat.albedo_color = Color(0.55, 0.30, 0.85, 0.55)
	bmat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	bmat.emission_enabled = true
	bmat.emission = Color(1.0, 0.55, 1.0)
	bmat.emission_energy_multiplier = 1.8
	bmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var body: MeshInstance3D = MeshInstance3D.new()
	var bmesh: SphereMesh = SphereMesh.new()
	bmesh.radius = 1.40
	bmesh.height = 1.40
	body.mesh = bmesh
	body.position = Vector3(0, 0, 0)
	body.scale = Vector3(1.0, 0.6, 1.0)
	body.material_override = bmat
	eater.add_child(body)
	# Single bright eye in the center
	var eye: MeshInstance3D = MeshInstance3D.new()
	var em: SphereMesh = SphereMesh.new()
	em.radius = 0.40
	em.height = 0.80
	eye.mesh = em
	eye.position = Vector3(0, 0.10, 0)
	var emat: StandardMaterial3D = StandardMaterial3D.new()
	emat.albedo_color = Color(1, 1, 1)
	emat.emission_enabled = true
	emat.emission = Color(1, 1, 1)
	emat.emission_energy_multiplier = 3.4
	emat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	eye.material_override = emat
	eater.add_child(eye)
	# 6 hanging tentacle arms
	var tent_mat: StandardMaterial3D = StandardMaterial3D.new()
	tent_mat.albedo_color = Color(0.85, 0.40, 1.0, 0.55)
	tent_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	tent_mat.emission_enabled = true
	tent_mat.emission = Color(1.0, 0.55, 1.0)
	tent_mat.emission_energy_multiplier = 1.4
	tent_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for i in 6:
		var angle: float = (float(i) / 6.0) * TAU
		var tent: MeshInstance3D = MeshInstance3D.new()
		var tm: CylinderMesh = CylinderMesh.new()
		tm.top_radius = 0.10
		tm.bottom_radius = 0.04
		tm.height = 1.40
		tent.mesh = tm
		tent.position = Vector3(cos(angle) * 0.85, -1.0, sin(angle) * 0.85)
		tent.material_override = tent_mat
		eater.add_child(tent)
	# Slow drift patrol
	var origin: Vector3 = D3_CENTER + Vector3(-20, 4, 8)
	var patrol: Tween = create_tween().set_loops()
	patrol.tween_property(eater, "position", origin + Vector3(4, 0, 4), 8.0).set_ease(Tween.EASE_IN_OUT)
	patrol.tween_property(eater, "position", origin + Vector3(0, 0, 8), 8.0).set_ease(Tween.EASE_IN_OUT)
	patrol.tween_property(eater, "position", origin, 8.0).set_ease(Tween.EASE_IN_OUT)
	# Pulse the eye
	var pulse: Tween = create_tween().set_loops()
	pulse.tween_property(emat, "emission_energy_multiplier", 4.5, 0.85).set_ease(Tween.EASE_IN_OUT)
	pulse.tween_property(emat, "emission_energy_multiplier", 2.0, 0.85).set_ease(Tween.EASE_IN_OUT)
	# Boss-tier name billboard
	var label: Label3D = Label3D.new()
	label.text = "DREAM EATER"
	label.position = Vector3(0, 2.0, 0)
	label.modulate = Color(1.0, 0.55, 1.0)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 6
	label.font_size = 22
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	eater.add_child(label)


func _build_d3_lectern(geom: Node) -> void:
	## Epic-3 T86: a lectern with a floating script — angled stand with
	## a glowing scroll hovering above the reading surface.
	var lect: Node3D = Node3D.new()
	lect.name = "D3Lectern"
	lect.position = D3_CENTER + Vector3(8, 0, -3)
	geom.add_child(lect)
	# Stand column
	var wood_mat: StandardMaterial3D = StandardMaterial3D.new()
	wood_mat.albedo_color = Color(0.30, 0.18, 0.10)
	wood_mat.metallic = 0.10
	wood_mat.roughness = 0.65
	var stand: MeshInstance3D = MeshInstance3D.new()
	var sm: BoxMesh = BoxMesh.new()
	sm.size = Vector3(0.40, 1.20, 0.40)
	stand.mesh = sm
	stand.position = Vector3(0, 0.60, 0)
	stand.material_override = wood_mat
	lect.add_child(stand)
	# Angled top desk
	var top: MeshInstance3D = MeshInstance3D.new()
	var tm: BoxMesh = BoxMesh.new()
	tm.size = Vector3(0.85, 0.10, 0.55)
	top.mesh = tm
	top.position = Vector3(0, 1.30, 0)
	top.rotation = Vector3(deg_to_rad(-15), 0, 0)
	top.material_override = wood_mat
	lect.add_child(top)
	# Floating script above the desk
	var script: MeshInstance3D = MeshInstance3D.new()
	var scrm: BoxMesh = BoxMesh.new()
	scrm.size = Vector3(0.65, 0.04, 0.40)
	script.mesh = scrm
	script.position = Vector3(0, 1.65, 0)
	script.rotation = Vector3(deg_to_rad(-15), 0, 0)
	var scrmat: StandardMaterial3D = StandardMaterial3D.new()
	scrmat.albedo_color = Color(1.0, 0.85, 0.55)
	scrmat.emission_enabled = true
	scrmat.emission = Color(1.0, 0.85, 0.55)
	scrmat.emission_energy_multiplier = 1.4
	scrmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	script.material_override = scrmat
	lect.add_child(script)
	# Bob the script
	var bob: Tween = create_tween().set_loops()
	bob.tween_property(script, "position:y", 1.85, 1.4).set_ease(Tween.EASE_IN_OUT)
	bob.tween_property(script, "position:y", 1.65, 1.4).set_ease(Tween.EASE_IN_OUT)
	# Collision
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(0.85, 1.40, 0.55)
	cs.shape = cb
	cs.position = Vector3(0, 0.70, 0)
	sb.add_child(cs)
	lect.add_child(sb)


func _build_d3_reflecting_pool(geom: Node) -> void:
	## Epic-3 T87: a long rectangular reflecting pool — slim emissive
	## cyan basin reflecting the sky.
	var pool: Node3D = Node3D.new()
	pool.name = "D3ReflectingPool"
	pool.position = D3_CENTER + Vector3(-15, 0, 0)
	geom.add_child(pool)
	# Stone rim — 4 boxes forming a rectangle frame
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.16, 0.10, 0.20)
	stone_mat.metallic = 0.55
	stone_mat.roughness = 0.45
	var rim_specs: Array = [
		[Vector3(0, 0.10, -1.40), Vector3(3.40, 0.20, 0.30)],
		[Vector3(0, 0.10, 1.40), Vector3(3.40, 0.20, 0.30)],
		[Vector3(-1.55, 0.10, 0), Vector3(0.30, 0.20, 2.50)],
		[Vector3(1.55, 0.10, 0), Vector3(0.30, 0.20, 2.50)],
	]
	for spec in rim_specs:
		var rim: MeshInstance3D = MeshInstance3D.new()
		var rm: BoxMesh = BoxMesh.new()
		rm.size = spec[1]
		rim.mesh = rm
		rim.position = spec[0]
		rim.material_override = stone_mat
		pool.add_child(rim)
	# Inner water surface
	var water: MeshInstance3D = MeshInstance3D.new()
	var wm: BoxMesh = BoxMesh.new()
	wm.size = Vector3(2.85, 0.06, 2.40)
	water.mesh = wm
	water.position = Vector3(0, 0.10, 0)
	var wmat: StandardMaterial3D = StandardMaterial3D.new()
	wmat.albedo_color = Color(0.30, 0.85, 1.0, 0.85)
	wmat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	wmat.emission_enabled = true
	wmat.emission = Color(0.55, 0.95, 1.0)
	wmat.emission_energy_multiplier = 1.4
	wmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	water.material_override = wmat
	pool.add_child(water)
	# Sign
	var label: Label3D = Label3D.new()
	label.text = "REFLECTING POOL"
	label.position = Vector3(0, 1.40, 0)
	label.modulate = Color(0.55, 0.95, 1.0)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 14
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	pool.add_child(label)


func _build_d3_staff_cluster(geom: Node) -> void:
	## Epic-3 T88: 5 mage staves leaning against each other in a cluster —
	## tall thin cylinders with colored gem tops.
	var cluster: Node3D = Node3D.new()
	cluster.name = "D3StaffCluster"
	cluster.position = D3_CENTER + Vector3(-18, 0, 14)
	geom.add_child(cluster)
	var wood_mat: StandardMaterial3D = StandardMaterial3D.new()
	wood_mat.albedo_color = Color(0.30, 0.18, 0.10)
	wood_mat.metallic = 0.10
	wood_mat.roughness = 0.65
	var gem_colors: Array[Color] = [
		Color(0.55, 0.95, 1.0),
		Color(1.0, 0.55, 0.20),
		Color(0.45, 1.0, 0.55),
		Color(0.85, 0.40, 1.0),
		Color(1.0, 0.95, 0.30),
	]
	for i in 5:
		var angle: float = (float(i) / 5.0) * TAU
		var staff: MeshInstance3D = MeshInstance3D.new()
		var smesh: CylinderMesh = CylinderMesh.new()
		smesh.top_radius = 0.05
		smesh.bottom_radius = 0.06
		smesh.height = 1.85
		staff.mesh = smesh
		staff.position = Vector3(cos(angle) * 0.30, 0.92, sin(angle) * 0.30)
		staff.rotation = Vector3(sin(angle) * deg_to_rad(20), 0, -cos(angle) * deg_to_rad(20))
		staff.material_override = wood_mat
		cluster.add_child(staff)
		# Gem tip on top
		var gem: MeshInstance3D = MeshInstance3D.new()
		var gm: SphereMesh = SphereMesh.new()
		gm.radius = 0.10
		gm.height = 0.20
		gem.mesh = gm
		gem.position = Vector3(cos(angle) * 0.55, 1.85, sin(angle) * 0.55)
		var gmat: StandardMaterial3D = StandardMaterial3D.new()
		gmat.albedo_color = gem_colors[i]
		gmat.emission_enabled = true
		gmat.emission = gem_colors[i]
		gmat.emission_energy_multiplier = 2.6
		gmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		gem.material_override = gmat
		cluster.add_child(gem)


func _build_d3_elder_mage_npc(town: Node) -> void:
	## Epic-3 T89: Elder Mage NPC standing on the floating crown landmark
	## platform — long beard, tall hat, multi-colored robe.
	var slots: Node3D = town.get_node_or_null("%NPCSlots") as Node3D
	if slots == null:
		return
	var elder: Node3D = Node3D.new()
	elder.name = "D3ElderMage"
	elder.position = D3_CENTER + Vector3(-15, 2.0, 14)
	slots.add_child(elder)
	# Multi-color robe body
	var bmat: StandardMaterial3D = StandardMaterial3D.new()
	bmat.albedo_color = Color(0.40, 0.20, 0.55)
	bmat.metallic = 0.20
	bmat.roughness = 0.65
	bmat.emission_enabled = true
	bmat.emission = Color(0.85, 0.40, 1.0)
	bmat.emission_energy_multiplier = 0.40
	var body: MeshInstance3D = MeshInstance3D.new()
	var bmesh: CapsuleMesh = CapsuleMesh.new()
	bmesh.radius = 0.45
	bmesh.height = 1.40
	body.mesh = bmesh
	body.position = Vector3(0, 0.70, 0)
	body.material_override = bmat
	elder.add_child(body)
	# Tall pointed hat
	var hat: MeshInstance3D = MeshInstance3D.new()
	var hm: PrismMesh = PrismMesh.new()
	hm.size = Vector3(0.55, 1.20, 0.55)
	hat.mesh = hm
	hat.position = Vector3(0, 2.10, 0)
	hat.material_override = bmat
	elder.add_child(hat)
	# Long white beard
	var beard: MeshInstance3D = MeshInstance3D.new()
	var bm: BoxMesh = BoxMesh.new()
	bm.size = Vector3(0.30, 0.85, 0.10)
	beard.mesh = bm
	beard.position = Vector3(0, 1.20, 0.34)
	var bmat2: StandardMaterial3D = StandardMaterial3D.new()
	bmat2.albedo_color = Color(0.95, 0.95, 1.0)
	bmat2.metallic = 0.10
	bmat2.roughness = 0.85
	beard.material_override = bmat2
	elder.add_child(beard)
	# 2 wise white eyes
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
		eye.position = Vector3(ex, 1.55, 0.34)
		eye.material_override = eye_mat
		elder.add_child(eye)
	# Long curved staff held in front
	var staff: MeshInstance3D = MeshInstance3D.new()
	var sm: CylinderMesh = CylinderMesh.new()
	sm.top_radius = 0.06
	sm.bottom_radius = 0.08
	sm.height = 2.40
	staff.mesh = sm
	staff.position = Vector3(0.45, 1.20, 0)
	var smat: StandardMaterial3D = StandardMaterial3D.new()
	smat.albedo_color = Color(0.30, 0.18, 0.10)
	smat.metallic = 0.30
	staff.material_override = smat
	elder.add_child(staff)
	# Big glowing crystal at the top of the staff
	var crystal: MeshInstance3D = MeshInstance3D.new()
	var cm: PrismMesh = PrismMesh.new()
	cm.size = Vector3(0.30, 0.55, 0.30)
	crystal.mesh = cm
	crystal.position = Vector3(0.45, 2.65, 0)
	var cmat: StandardMaterial3D = StandardMaterial3D.new()
	cmat.albedo_color = Color(1.0, 0.95, 0.30)
	cmat.emission_enabled = true
	cmat.emission = Color(1.0, 0.95, 0.30)
	cmat.emission_energy_multiplier = 3.0
	cmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	crystal.material_override = cmat
	elder.add_child(crystal)
	# Pulse the crystal
	var pulse: Tween = create_tween().set_loops()
	pulse.tween_property(crystal, "scale", Vector3(1.30, 1.30, 1.30), 1.4).set_ease(Tween.EASE_IN_OUT)
	pulse.tween_property(crystal, "scale", Vector3(0.85, 0.85, 0.85), 1.4).set_ease(Tween.EASE_IN_OUT)
	# Name billboard
	var label: Label3D = Label3D.new()
	label.text = "Elder Mage"
	label.position = Vector3(0, 3.25, 0)
	label.modulate = Color(1.0, 0.95, 0.30)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 18
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	elder.add_child(label)


func _build_d3_perimeter_braziers(geom: Node) -> void:
	## Epic-3 T90: 6 large violet flame braziers around the perimeter of
	## D3 — taller than the inner braziers, real lighting.
	for i in 6:
		var angle: float = (float(i) / 6.0) * TAU
		var brazier: Node3D = Node3D.new()
		brazier.name = "D3PerimeterBrazier_%d" % i
		brazier.position = D3_CENTER + Vector3(cos(angle) * 22.0, 0, sin(angle) * 16.0)
		geom.add_child(brazier)
		# Tall column stem
		var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
		stone_mat.albedo_color = Color(0.16, 0.10, 0.20)
		stone_mat.metallic = 0.55
		stone_mat.roughness = 0.45
		var stem: MeshInstance3D = MeshInstance3D.new()
		var smesh: CylinderMesh = CylinderMesh.new()
		smesh.top_radius = 0.20
		smesh.bottom_radius = 0.30
		smesh.height = 2.40
		stem.mesh = smesh
		stem.position = Vector3(0, 1.20, 0)
		stem.material_override = stone_mat
		brazier.add_child(stem)
		# Bowl on top
		var bowl: MeshInstance3D = MeshInstance3D.new()
		var bmesh: CylinderMesh = CylinderMesh.new()
		bmesh.top_radius = 0.55
		bmesh.bottom_radius = 0.20
		bmesh.height = 0.30
		bowl.mesh = bmesh
		bowl.position = Vector3(0, 2.55, 0)
		bowl.material_override = stone_mat
		brazier.add_child(bowl)
		# Big violet flame
		var flame: MeshInstance3D = MeshInstance3D.new()
		var fmesh: SphereMesh = SphereMesh.new()
		fmesh.radius = 0.30
		fmesh.height = 0.60
		flame.mesh = fmesh
		flame.position = Vector3(0, 2.95, 0)
		var fmat: StandardMaterial3D = StandardMaterial3D.new()
		fmat.albedo_color = Color(1.0, 0.55, 1.0)
		fmat.emission_enabled = true
		fmat.emission = Color(1.0, 0.55, 1.0)
		fmat.emission_energy_multiplier = 3.0
		fmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		flame.material_override = fmat
		brazier.add_child(flame)
		# Pulse flame
		var pulse: Tween = create_tween().set_loops()
		pulse.tween_property(flame, "scale", Vector3(1.30, 1.30, 1.30), 0.5 + i * 0.1).set_ease(Tween.EASE_IN_OUT)
		pulse.tween_property(flame, "scale", Vector3(0.85, 0.85, 0.85), 0.5 + i * 0.1).set_ease(Tween.EASE_IN_OUT)
		# OmniLight
		var light: OmniLight3D = OmniLight3D.new()
		light.position = Vector3(0, 3.0, 0)
		light.light_color = Color(1.0, 0.55, 1.0)
		light.light_energy = 1.8
		light.omni_range = 8.0
		brazier.add_child(light)
		# Collision around stem
		var sb: StaticBody3D = StaticBody3D.new()
		var cs: CollisionShape3D = CollisionShape3D.new()
		var cap: CapsuleShape3D = CapsuleShape3D.new()
		cap.radius = 0.40
		cap.height = 2.40
		cs.shape = cap
		cs.position = Vector3(0, 1.20, 0)
		sb.add_child(cs)
		brazier.add_child(sb)


func _build_d3_astrolabe(geom: Node) -> void:
	## Epic-3 T91: an astrolabe device — stone stand with 3 nested rotating
	## torus rings (rotating around different axes) representing celestial
	## tracking.
	var astro: Node3D = Node3D.new()
	astro.name = "D3Astrolabe"
	astro.position = D3_CENTER + Vector3(8, 0, 14)
	geom.add_child(astro)
	# Stone stand
	var stone_mat: StandardMaterial3D = StandardMaterial3D.new()
	stone_mat.albedo_color = Color(0.16, 0.10, 0.20)
	stone_mat.metallic = 0.55
	stone_mat.roughness = 0.45
	var stand: MeshInstance3D = MeshInstance3D.new()
	var sm: BoxMesh = BoxMesh.new()
	sm.size = Vector3(0.55, 1.40, 0.55)
	stand.mesh = sm
	stand.position = Vector3(0, 0.70, 0)
	stand.material_override = stone_mat
	astro.add_child(stand)
	# Pivot for rotating rings
	var pivot: Node3D = Node3D.new()
	pivot.position = Vector3(0, 1.85, 0)
	astro.add_child(pivot)
	# 3 nested torus rings rotating on different axes
	var ring_mat: StandardMaterial3D = StandardMaterial3D.new()
	ring_mat.albedo_color = Color(0.85, 0.55, 0.20)
	ring_mat.emission_enabled = true
	ring_mat.emission = Color(1.0, 0.65, 0.20)
	ring_mat.emission_energy_multiplier = 1.4
	ring_mat.metallic = 0.85
	ring_mat.roughness = 0.20
	for i in 3:
		var ring: MeshInstance3D = MeshInstance3D.new()
		var rm: TorusMesh = TorusMesh.new()
		rm.inner_radius = 0.65 - i * 0.10
		rm.outer_radius = 0.75 - i * 0.10
		ring.mesh = rm
		# Rotate each ring on a different axis
		if i == 0:
			ring.rotation = Vector3(0, 0, 0)
		elif i == 1:
			ring.rotation = Vector3(deg_to_rad(45), 0, 0)
		else:
			ring.rotation = Vector3(0, 0, deg_to_rad(45))
		ring.material_override = ring_mat
		pivot.add_child(ring)
		# Rotation tween
		var spin: Tween = create_tween().set_loops()
		var axis: String = ["rotation:y", "rotation:x", "rotation:z"][i]
		spin.tween_property(ring, axis, ring.get_indexed(axis) + TAU, 6.0 + i * 2)
	# Center sphere
	var center: MeshInstance3D = MeshInstance3D.new()
	var cm: SphereMesh = SphereMesh.new()
	cm.radius = 0.18
	cm.height = 0.36
	center.mesh = cm
	var cmat: StandardMaterial3D = StandardMaterial3D.new()
	cmat.albedo_color = Color(1.0, 0.85, 0.30)
	cmat.emission_enabled = true
	cmat.emission = Color(1.0, 0.95, 0.30)
	cmat.emission_energy_multiplier = 3.0
	cmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	center.material_override = cmat
	pivot.add_child(center)
	# Sign
	var label: Label3D = Label3D.new()
	label.text = "ASTROLABE"
	label.position = Vector3(0, 3.0, 0)
	label.modulate = Color(1.0, 0.65, 0.20)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 16
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	astro.add_child(label)
	# Collision
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(0.55, 1.40, 0.55)
	cs.shape = cb
	cs.position = Vector3(0, 0.70, 0)
	sb.add_child(cs)
	astro.add_child(sb)


func _build_d3_ingredient_shelves(geom: Node) -> void:
	## Epic-3 T92: 2 ingredient shelves stacked with colored vials in
	## small grid arrangements.
	var shelves: Node3D = Node3D.new()
	shelves.name = "D3IngredientShelves"
	shelves.position = D3_CENTER + Vector3(-15, 0, -3)
	geom.add_child(shelves)
	var wood_mat: StandardMaterial3D = StandardMaterial3D.new()
	wood_mat.albedo_color = Color(0.30, 0.18, 0.10)
	wood_mat.metallic = 0.10
	wood_mat.roughness = 0.65
	# 2 horizontal shelf boards
	for sy: float in [0.85, 1.55]:
		var shelf: MeshInstance3D = MeshInstance3D.new()
		var smesh: BoxMesh = BoxMesh.new()
		smesh.size = Vector3(2.40, 0.10, 0.40)
		shelf.mesh = smesh
		shelf.position = Vector3(0, sy, 0)
		shelf.material_override = wood_mat
		shelves.add_child(shelf)
		# 6 colored vials per shelf
		for c in 6:
			var vial: MeshInstance3D = MeshInstance3D.new()
			var vm: CylinderMesh = CylinderMesh.new()
			vm.top_radius = 0.06
			vm.bottom_radius = 0.10
			vm.height = 0.30
			vial.mesh = vm
			vial.position = Vector3(-1.0 + c * 0.40, sy + 0.20, 0)
			var color: Color = Color.from_hsv(c / 6.0, 0.65, 1.0)
			var vmat: StandardMaterial3D = StandardMaterial3D.new()
			vmat.albedo_color = color
			vmat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
			vmat.albedo_color.a = 0.85
			vmat.emission_enabled = true
			vmat.emission = color
			vmat.emission_energy_multiplier = 1.6
			vmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
			vial.material_override = vmat
			shelves.add_child(vial)
	# 2 side support posts
	for sx: float in [-1.20, 1.20]:
		var post: MeshInstance3D = MeshInstance3D.new()
		var pm: BoxMesh = BoxMesh.new()
		pm.size = Vector3(0.10, 1.85, 0.40)
		post.mesh = pm
		post.position = Vector3(sx, 0.92, 0)
		post.material_override = wood_mat
		shelves.add_child(post)
	# Collision
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cb: BoxShape3D = BoxShape3D.new()
	cb.size = Vector3(2.40, 1.85, 0.40)
	cs.shape = cb
	cs.position = Vector3(0, 0.92, 0)
	sb.add_child(cs)
	shelves.add_child(sb)


func _build_d3_planet_model(geom: Node) -> void:
	## Epic-3 T93: a floating planet model — large sphere with a torus
	## ring around it like a saturnian planet, suspended above a stand.
	var plan: Node3D = Node3D.new()
	plan.name = "D3PlanetModel"
	plan.position = D3_CENTER + Vector3(15, 0, 8)
	geom.add_child(plan)
	# Stone stand
	var stand_mat: StandardMaterial3D = StandardMaterial3D.new()
	stand_mat.albedo_color = Color(0.16, 0.10, 0.20)
	stand_mat.metallic = 0.55
	stand_mat.roughness = 0.45
	var stand: MeshInstance3D = MeshInstance3D.new()
	var sm: CylinderMesh = CylinderMesh.new()
	sm.top_radius = 0.30
	sm.bottom_radius = 0.40
	sm.height = 0.85
	stand.mesh = sm
	stand.position = Vector3(0, 0.42, 0)
	stand.material_override = stand_mat
	plan.add_child(stand)
	# Pivot for the planet
	var pivot: Node3D = Node3D.new()
	pivot.position = Vector3(0, 2.20, 0)
	plan.add_child(pivot)
	# Planet sphere
	var planet: MeshInstance3D = MeshInstance3D.new()
	var pm: SphereMesh = SphereMesh.new()
	pm.radius = 0.65
	pm.height = 1.30
	planet.mesh = pm
	var pmat: StandardMaterial3D = StandardMaterial3D.new()
	pmat.albedo_color = Color(0.30, 0.55, 1.0)
	pmat.emission_enabled = true
	pmat.emission = Color(0.55, 0.85, 1.0)
	pmat.emission_energy_multiplier = 1.4
	pmat.metallic = 0.40
	pmat.roughness = 0.30
	pmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	planet.material_override = pmat
	pivot.add_child(planet)
	# Saturn-like ring
	var ring: MeshInstance3D = MeshInstance3D.new()
	var rmesh: TorusMesh = TorusMesh.new()
	rmesh.inner_radius = 0.95
	rmesh.outer_radius = 1.20
	ring.mesh = rmesh
	ring.rotation = Vector3(deg_to_rad(20), 0, 0)
	var rmat: StandardMaterial3D = StandardMaterial3D.new()
	rmat.albedo_color = Color(0.85, 0.65, 0.30, 0.65)
	rmat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	rmat.emission_enabled = true
	rmat.emission = Color(1.0, 0.75, 0.30)
	rmat.emission_energy_multiplier = 1.8
	rmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	ring.material_override = rmat
	pivot.add_child(ring)
	# Slow rotation
	var spin: Tween = create_tween().set_loops()
	spin.tween_property(pivot, "rotation:y", TAU, 12.0)
	# Collision around stand
	var sb: StaticBody3D = StaticBody3D.new()
	var cs: CollisionShape3D = CollisionShape3D.new()
	var cap: CapsuleShape3D = CapsuleShape3D.new()
	cap.radius = 0.45
	cap.height = 0.85
	cs.shape = cap
	cs.position = Vector3(0, 0.42, 0)
	sb.add_child(cs)
	plan.add_child(sb)


func _build_d3_time_keeper_npc(town: Node) -> void:
	## Epic-3 T94: Time Keeper NPC standing by the sundial — robed figure
	## with an hourglass at the belt and a slow pendulum cane.
	var slots: Node3D = town.get_node_or_null("%NPCSlots") as Node3D
	if slots == null:
		return
	var keeper: Node3D = Node3D.new()
	keeper.name = "D3TimeKeeper"
	keeper.position = D3_CENTER + Vector3(-13, 0, 6)
	slots.add_child(keeper)
	# Robed body
	var bmat: StandardMaterial3D = StandardMaterial3D.new()
	bmat.albedo_color = Color(0.20, 0.30, 0.40)
	bmat.metallic = 0.20
	bmat.roughness = 0.65
	bmat.emission_enabled = true
	bmat.emission = Color(0.40, 0.55, 0.85)
	bmat.emission_energy_multiplier = 0.30
	var body: MeshInstance3D = MeshInstance3D.new()
	var bmesh: CapsuleMesh = CapsuleMesh.new()
	bmesh.radius = 0.45
	bmesh.height = 1.40
	body.mesh = bmesh
	body.position = Vector3(0, 0.70, 0)
	body.material_override = bmat
	keeper.add_child(body)
	# Hood
	var hood: MeshInstance3D = MeshInstance3D.new()
	var hmesh: SphereMesh = SphereMesh.new()
	hmesh.radius = 0.45
	hmesh.height = 0.55
	hood.mesh = hmesh
	hood.position = Vector3(0, 1.55, 0)
	hood.material_override = bmat
	keeper.add_child(hood)
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
		em.radius = 0.06
		em.height = 0.12
		eye.mesh = em
		eye.position = Vector3(ex, 1.40, 0.34)
		eye.material_override = eye_mat
		keeper.add_child(eye)
	# Hourglass at the belt — small box with bright sand inside
	var hourglass: MeshInstance3D = MeshInstance3D.new()
	var hgm: BoxMesh = BoxMesh.new()
	hgm.size = Vector3(0.18, 0.40, 0.18)
	hourglass.mesh = hgm
	hourglass.position = Vector3(0.36, 0.70, 0.30)
	var hgmat: StandardMaterial3D = StandardMaterial3D.new()
	hgmat.albedo_color = Color(1.0, 0.95, 0.30, 0.85)
	hgmat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	hgmat.emission_enabled = true
	hgmat.emission = Color(1.0, 0.95, 0.30)
	hgmat.emission_energy_multiplier = 1.4
	hgmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	hourglass.material_override = hgmat
	keeper.add_child(hourglass)
	# Pendulum cane held in front
	var cane_pivot: Node3D = Node3D.new()
	cane_pivot.position = Vector3(-0.40, 1.20, 0)
	keeper.add_child(cane_pivot)
	var cane: MeshInstance3D = MeshInstance3D.new()
	var cnm: CylinderMesh = CylinderMesh.new()
	cnm.top_radius = 0.04
	cnm.bottom_radius = 0.06
	cnm.height = 1.40
	cane.mesh = cnm
	cane.position = Vector3(0, -0.70, 0)
	var cnmat: StandardMaterial3D = StandardMaterial3D.new()
	cnmat.albedo_color = Color(0.30, 0.18, 0.10)
	cnmat.metallic = 0.30
	cane.material_override = cnmat
	cane_pivot.add_child(cane)
	# Pendulum sway
	var swing: Tween = create_tween().set_loops()
	swing.tween_property(cane_pivot, "rotation:z", deg_to_rad(8), 1.6).set_ease(Tween.EASE_IN_OUT)
	swing.tween_property(cane_pivot, "rotation:z", deg_to_rad(-8), 1.6).set_ease(Tween.EASE_IN_OUT)
	# Name billboard
	var label: Label3D = Label3D.new()
	label.text = "Time Keeper"
	label.position = Vector3(0, 2.20, 0)
	label.modulate = Color(0.55, 0.85, 1.0)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 18
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	keeper.add_child(label)


func _build_d3_seeker_trial(geom: Node) -> void:
	## Epic-3 T95: seeker trial — 9 small floor pads in a 3x3 grid that
	## glow in sequence (chase pattern), suggesting a "step on these in
	## the right order" puzzle.
	var trial: Node3D = Node3D.new()
	trial.name = "D3SeekerTrial"
	trial.position = D3_CENTER + Vector3(0, 0.06, 16)
	geom.add_child(trial)
	for r in 3:
		for c in 3:
			var i: int = r * 3 + c
			var pad: MeshInstance3D = MeshInstance3D.new()
			pad.name = "TrialPad_%d" % i
			var pm: BoxMesh = BoxMesh.new()
			pm.size = Vector3(0.85, 0.10, 0.85)
			pad.mesh = pm
			pad.position = Vector3(-1.20 + c * 1.20, 0, -1.20 + r * 1.20)
			var pmat: StandardMaterial3D = StandardMaterial3D.new()
			pmat.albedo_color = Color(0.16, 0.10, 0.20)
			pmat.metallic = 0.55
			pmat.roughness = 0.45
			pmat.emission_enabled = true
			pmat.emission = Color(0.85, 0.40, 1.0)
			pmat.emission_energy_multiplier = 0.45
			pad.material_override = pmat
			trial.add_child(pad)
			# Chase emission pulse
			var pulse: Tween = create_tween().set_loops()
			pulse.tween_interval(i * 0.20)
			pulse.tween_property(pmat, "emission_energy_multiplier", 3.0, 0.30).set_ease(Tween.EASE_OUT)
			pulse.tween_property(pmat, "emission_energy_multiplier", 0.45, 0.30).set_ease(Tween.EASE_IN)
			pulse.tween_interval(2.0 - i * 0.20 * 0.5)
	# Sign overhead
	var label: Label3D = Label3D.new()
	label.text = "SEEKER TRIAL"
	label.position = Vector3(0, 1.85, 0)
	label.modulate = Color(1.0, 0.55, 1.0)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 5
	label.font_size = 16
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	trial.add_child(label)


func _build_d3_welcome_banner(geom: Node) -> void:
	## Epic-3 T96: a wide violet welcome banner stretched between the
	## D3 entrance arch pillars at x=122 reading "MEMORY VAULT".
	var banner_root: Node3D = Node3D.new()
	banner_root.name = "D3WelcomeBanner"
	banner_root.position = Vector3(122, 0, 0)
	geom.add_child(banner_root)
	# Banner cloth
	var cloth: MeshInstance3D = MeshInstance3D.new()
	var cmesh: BoxMesh = BoxMesh.new()
	cmesh.size = Vector3(0.10, 0.95, 8.5)
	cloth.mesh = cmesh
	cloth.position = Vector3(0, 6.0, 0)
	var cmat: StandardMaterial3D = StandardMaterial3D.new()
	cmat.albedo_color = Color(0.16, 0.06, 0.30)
	cmat.emission_enabled = true
	cmat.emission = Color(0.85, 0.40, 1.0)
	cmat.emission_energy_multiplier = 1.0
	cmat.metallic = 0.10
	cmat.roughness = 0.55
	cloth.material_override = cmat
	banner_root.add_child(cloth)
	# Top + bottom emissive trim
	var trim_mat: StandardMaterial3D = StandardMaterial3D.new()
	trim_mat.albedo_color = Color(1.0, 0.55, 1.0)
	trim_mat.emission_enabled = true
	trim_mat.emission = Color(1.0, 0.55, 1.0)
	trim_mat.emission_energy_multiplier = 2.0
	trim_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for ty: float in [6.45, 5.55]:
		var trim: MeshInstance3D = MeshInstance3D.new()
		var tmesh: BoxMesh = BoxMesh.new()
		tmesh.size = Vector3(0.12, 0.08, 8.5)
		trim.mesh = tmesh
		trim.position = Vector3(0, ty, 0)
		trim.material_override = trim_mat
		banner_root.add_child(trim)
	# Welcome text — duplicated for both sides
	for fx: float in [-0.10, 0.10]:
		var label: Label3D = Label3D.new()
		label.text = "MEMORY VAULT"
		label.position = Vector3(fx, 6.0, 0)
		label.rotation = Vector3(0, deg_to_rad(-90 if fx < 0 else 90), 0)
		label.modulate = Color(1.0, 0.55, 1.0)
		label.outline_modulate = Color(0, 0, 0, 0.85)
		label.outline_size = 6
		label.font_size = 28
		label.no_depth_test = true
		banner_root.add_child(label)
	# Slow emission pulse
	var pulse: Tween = create_tween().set_loops()
	pulse.tween_property(cmat, "emission_energy_multiplier", 1.6, 2.0).set_ease(Tween.EASE_IN_OUT)
	pulse.tween_property(cmat, "emission_energy_multiplier", 0.85, 2.0).set_ease(Tween.EASE_IN_OUT)


func _build_d3_atmosphere_fog(geom: Node) -> void:
	## Epic-3 T97: ambient violet fog drifting across the entire D3 floor —
	## 80 large translucent violet puffs.
	var fog: GPUParticles3D = GPUParticles3D.new()
	fog.name = "D3AtmosphereFog"
	fog.position = D3_CENTER + Vector3(-30, 0.5, 0)
	fog.amount = 80
	fog.lifetime = 14.0
	fog.preprocess = 6.0
	var pmat: ParticleProcessMaterial = ParticleProcessMaterial.new()
	pmat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	pmat.emission_box_extents = Vector3(0.5, 0.5, 18.0)
	pmat.direction = Vector3(1, 0, 0)
	pmat.spread = 6.0
	pmat.initial_velocity_min = 0.45
	pmat.initial_velocity_max = 0.85
	pmat.gravity = Vector3.ZERO
	pmat.scale_min = 0.85
	pmat.scale_max = 1.40
	pmat.color = Color(0.85, 0.40, 1.0, 0.20)
	fog.process_material = pmat
	var puff: SphereMesh = SphereMesh.new()
	puff.radius = 0.85
	puff.height = 1.70
	var puff_mat: StandardMaterial3D = StandardMaterial3D.new()
	puff_mat.albedo_color = Color(0.85, 0.40, 1.0, 0.20)
	puff_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	puff_mat.emission_enabled = true
	puff_mat.emission = Color(1.0, 0.55, 1.0)
	puff_mat.emission_energy_multiplier = 0.55
	puff_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	puff.material = puff_mat
	fog.draw_pass_1 = puff
	geom.add_child(fog)


func _build_d3_epic3_plaque(geom: Node) -> void:
	## Epic-3 T98: a stone tablet plaque commemorating Epic 3 completion.
	var plaque: Node3D = Node3D.new()
	plaque.name = "D3Epic3Plaque"
	plaque.position = D3_CENTER + Vector3(15, 0, -3)
	geom.add_child(plaque)
	# Pedestal
	var ped_mat: StandardMaterial3D = StandardMaterial3D.new()
	ped_mat.albedo_color = Color(0.16, 0.10, 0.20)
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
	tmat.albedo_color = Color(0.30, 0.20, 0.40)
	tmat.metallic = 0.65
	tmat.roughness = 0.30
	tmat.emission_enabled = true
	tmat.emission = Color(1.0, 0.55, 1.0)
	tmat.emission_energy_multiplier = 0.40
	tablet.material_override = tmat
	plaque.add_child(tablet)
	# Engraved text
	var label: Label3D = Label3D.new()
	label.text = "EPIC 03\nMEMORY VAULT\nCOMPLETE"
	label.position = Vector3(0, 0.95, 0.18)
	label.rotation = Vector3(deg_to_rad(-25), 0, 0)
	label.modulate = Color(1.0, 0.55, 1.0)
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


func _build_d3_ambient_fills(geom: Node) -> void:
	## Epic-3 T99: 3 high violet-tinted OmniLight3D fill lights spaced
	## along the D3 length lifting overall light level.
	var positions: Array[Vector3] = [
		D3_CENTER + Vector3(-15, 8, 0),
		D3_CENTER + Vector3(0, 8, 0),
		D3_CENTER + Vector3(15, 8, 0),
	]
	for i in positions.size():
		var fill: OmniLight3D = OmniLight3D.new()
		fill.name = "D3FillLight_%d" % i
		fill.position = positions[i]
		fill.light_color = Color(0.85, 0.55, 1.0)
		fill.light_energy = 1.4
		fill.omni_range = 24.0
		fill.omni_attenuation = 1.6
		geom.add_child(fill)


func _build_d3_arcane_overseer_landmark(geom: Node) -> void:
	## Epic-3 T100 (FINALE): a massive ARCANE OVERSEER landmark hovering
	## 14m above the D3 center — translucent violet humanoid + 8 orbital
	## rune cubes + ground halo + real OmniLight3D casting violet over the
	## entire district. The Memory Vault equivalent of D1's Globbler and
	## D2's Glitch Herald.
	var landmark: Node3D = Node3D.new()
	landmark.name = "D3ArcaneOverseerLandmark"
	landmark.position = D3_CENTER + Vector3(0, 14, 0)
	geom.add_child(landmark)
	var pivot: Node3D = Node3D.new()
	pivot.name = "RotationPivot"
	landmark.add_child(pivot)
	# Translucent humanoid body
	var holo_mat: StandardMaterial3D = StandardMaterial3D.new()
	holo_mat.albedo_color = Color(0.85, 0.55, 1.0, 0.45)
	holo_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	holo_mat.emission_enabled = true
	holo_mat.emission = Color(1.0, 0.55, 1.0)
	holo_mat.emission_energy_multiplier = 2.4
	holo_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	# Body capsule
	var body: MeshInstance3D = MeshInstance3D.new()
	var bmesh: CapsuleMesh = CapsuleMesh.new()
	bmesh.radius = 0.95
	bmesh.height = 2.85
	body.mesh = bmesh
	body.position = Vector3(0, 0, 0)
	body.material_override = holo_mat
	pivot.add_child(body)
	# Head sphere
	var head: MeshInstance3D = MeshInstance3D.new()
	var hmesh: SphereMesh = SphereMesh.new()
	hmesh.radius = 0.85
	hmesh.height = 1.70
	head.mesh = hmesh
	head.position = Vector3(0, 2.20, 0)
	head.material_override = holo_mat
	pivot.add_child(head)
	# 3 huge glowing white eyes (cyclops + 2 — overseer style)
	var eye_mat: StandardMaterial3D = StandardMaterial3D.new()
	eye_mat.albedo_color = Color(1, 1, 1, 0.9)
	eye_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	eye_mat.emission_enabled = true
	eye_mat.emission = Color(1, 1, 1)
	eye_mat.emission_energy_multiplier = 4.0
	eye_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for spec in [Vector3(-0.40, 2.30, 0.65), Vector3(0.40, 2.30, 0.65), Vector3(0, 2.65, 0.75)]:
		var eye: MeshInstance3D = MeshInstance3D.new()
		var em: SphereMesh = SphereMesh.new()
		em.radius = 0.22
		em.height = 0.44
		eye.mesh = em
		eye.position = spec
		eye.material_override = eye_mat
		pivot.add_child(eye)
	# 8 orbital rune cubes circling at body height
	for i in 8:
		var angle: float = (float(i) / 8.0) * TAU
		var rune: MeshInstance3D = MeshInstance3D.new()
		var rmesh: BoxMesh = BoxMesh.new()
		rmesh.size = Vector3(0.40, 0.40, 0.40)
		rune.mesh = rmesh
		rune.position = Vector3(cos(angle) * 2.85, sin(float(i) * 0.85) * 0.55, sin(angle) * 2.85)
		rune.rotation = Vector3(0, -angle, deg_to_rad(15))
		var rmat: StandardMaterial3D = StandardMaterial3D.new()
		rmat.albedo_color = Color(1.0, 0.55, 1.0)
		rmat.emission_enabled = true
		rmat.emission = Color(1.0, 0.55, 1.0)
		rmat.emission_energy_multiplier = 2.6
		rmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		rune.material_override = rmat
		pivot.add_child(rune)
	# Slow main rotation
	var spin: Tween = create_tween().set_loops()
	spin.tween_property(pivot, "rotation:y", TAU, 18.0)
	# Bobbing in place
	var bob: Tween = create_tween().set_loops()
	bob.tween_property(landmark, "position:y", 15.0, 3.0).set_ease(Tween.EASE_IN_OUT)
	bob.tween_property(landmark, "position:y", 14.0, 3.0).set_ease(Tween.EASE_IN_OUT)
	# Ground halo beneath the landmark
	var halo: MeshInstance3D = MeshInstance3D.new()
	var hmesh2: TorusMesh = TorusMesh.new()
	hmesh2.inner_radius = 4.5
	hmesh2.outer_radius = 5.0
	halo.mesh = hmesh2
	halo.position = D3_CENTER + Vector3(0, 0.06, 0)
	var hmat2: StandardMaterial3D = StandardMaterial3D.new()
	hmat2.albedo_color = Color(1.0, 0.55, 1.0)
	hmat2.emission_enabled = true
	hmat2.emission = Color(1.0, 0.55, 1.0)
	hmat2.emission_energy_multiplier = 2.4
	hmat2.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	halo.material_override = hmat2
	geom.add_child(halo)
	var halo_pulse: Tween = create_tween().set_loops()
	halo_pulse.tween_property(halo, "scale", Vector3(1.20, 1.0, 1.20), 2.0).set_ease(Tween.EASE_IN_OUT)
	halo_pulse.tween_property(halo, "scale", Vector3(1.0, 1.0, 1.0), 2.0).set_ease(Tween.EASE_IN_OUT)
	# Real OmniLight at the landmark casting violet over the district
	var landmark_light: OmniLight3D = OmniLight3D.new()
	landmark_light.position = Vector3(0, 0, 0)
	landmark_light.light_color = Color(1.0, 0.55, 1.0)
	landmark_light.light_energy = 3.5
	landmark_light.omni_range = 30.0
	landmark_light.omni_attenuation = 1.4
	pivot.add_child(landmark_light)
	# ARCANE OVERSEER billboard
	var label: Label3D = Label3D.new()
	label.text = "ARCANE OVERSEER"
	label.position = Vector3(0, 4.40, 0)
	label.modulate = Color(1.0, 0.55, 1.0)
	label.outline_modulate = Color(0, 0, 0, 0.85)
	label.outline_size = 6
	label.font_size = 26
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	landmark.add_child(label)
