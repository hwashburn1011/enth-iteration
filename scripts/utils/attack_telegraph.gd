class_name AttackTelegraph
extends RefCounted
## Creates visual attack telegraph indicators: ground circles, cones, and lines.
## All telegraphs auto-cleanup after their duration expires.


static func show_circle(position: Vector3, radius: float, duration: float, parent: Node) -> MeshInstance3D:
	## Expanding red circle indicator for AoE attacks.
	var indicator: MeshInstance3D = MeshInstance3D.new()
	var mesh: PlaneMesh = PlaneMesh.new()
	mesh.size = Vector2(radius * 2.0, radius * 2.0)
	indicator.mesh = mesh
	indicator.rotation.x = 0  # Flat on ground

	var mat: StandardMaterial3D = StandardMaterial3D.new()
	mat.albedo_color = Color(1.0, 0.13, 0.0, 0.0)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.emission_enabled = true
	mat.emission = Color(1.0, 0.13, 0.0)
	mat.emission_energy_multiplier = 1.5
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	indicator.material_override = mat
	parent.add_child(indicator)
	indicator.global_position = position + Vector3(0, 0.05, 0)

	# Animate: fade in while pulsing, then disappear
	indicator.scale = Vector3(0.1, 1.0, 0.1)
	var tween: Tween = indicator.create_tween()
	tween.tween_property(indicator, "scale", Vector3(1.0, 1.0, 1.0), duration * 0.8).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(mat, "albedo_color:a", 0.3, duration * 0.3)
	# Pulse effect
	tween.parallel().tween_property(mat, "emission_energy_multiplier", 3.0, duration * 0.4).set_ease(Tween.EASE_IN)
	tween.tween_property(mat, "albedo_color:a", 0.0, duration * 0.2)
	tween.tween_callback(indicator.queue_free)

	return indicator


static func show_line(origin: Vector3, direction: Vector3, length: float, width: float, duration: float, parent: Node) -> MeshInstance3D:
	## Narrow line indicator for charge/lunge attacks.
	var indicator: MeshInstance3D = MeshInstance3D.new()
	var mesh: PlaneMesh = PlaneMesh.new()
	mesh.size = Vector2(width, length)
	indicator.mesh = mesh
	# Rotate to face direction
	var angle: float = atan2(direction.x, direction.z)
	indicator.rotation = Vector3(0, angle, 0)

	var mat: StandardMaterial3D = StandardMaterial3D.new()
	mat.albedo_color = Color(1.0, 0.13, 0.0, 0.0)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.emission_enabled = true
	mat.emission = Color(1.0, 0.2, 0.0)
	mat.emission_energy_multiplier = 1.5
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	indicator.material_override = mat
	parent.add_child(indicator)
	# Position AFTER add_child (Position at midpoint along direction)
	var mid: Vector3 = origin + direction.normalized() * (length * 0.5)
	indicator.global_position = mid + Vector3(0, 0.05, 0)

	# Animate
	var tween: Tween = indicator.create_tween()
	tween.tween_property(mat, "albedo_color:a", 0.3, duration * 0.3)
	tween.parallel().tween_property(mat, "emission_energy_multiplier", 3.0, duration * 0.7).set_ease(Tween.EASE_IN)
	tween.tween_property(mat, "albedo_color:a", 0.0, duration * 0.2)
	tween.tween_callback(indicator.queue_free)

	return indicator


static func show_cone(origin: Vector3, direction: Vector3, radius: float, _angle_deg: float, duration: float, parent: Node) -> MeshInstance3D:
	## Fan-shaped indicator for sweeping/cone attacks.
	## Uses a flattened cylinder segment approximation.
	var indicator: MeshInstance3D = MeshInstance3D.new()
	var mesh: PlaneMesh = PlaneMesh.new()
	mesh.size = Vector2(radius * 2.0, radius)
	indicator.mesh = mesh
	var face_angle: float = atan2(direction.x, direction.z)
	indicator.rotation = Vector3(0, face_angle, 0)

	var mat: StandardMaterial3D = StandardMaterial3D.new()
	mat.albedo_color = Color(1.0, 0.4, 0.0, 0.0)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.emission_enabled = true
	mat.emission = Color(1.0, 0.3, 0.0)
	mat.emission_energy_multiplier = 1.5
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	indicator.material_override = mat
	parent.add_child(indicator)
	indicator.global_position = origin + direction.normalized() * (radius * 0.4) + Vector3(0, 0.05, 0)

	indicator.scale = Vector3(0.1, 1.0, 0.1)
	var tween: Tween = indicator.create_tween()
	tween.tween_property(indicator, "scale", Vector3(1.0, 1.0, 1.0), duration * 0.6).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(mat, "albedo_color:a", 0.25, duration * 0.3)
	tween.parallel().tween_property(mat, "emission_energy_multiplier", 3.0, duration * 0.7).set_ease(Tween.EASE_IN)
	tween.tween_property(mat, "albedo_color:a", 0.0, duration * 0.2)
	tween.tween_callback(indicator.queue_free)

	return indicator


# =============================================================================
# v2 — Polished readability layer (Epic 04 task 42)
# =============================================================================
#
# The original show_circle / show_line / show_cone are kept for compat. The
# v2 helpers below produce the trailer-ready version with:
#
#   - 3-phase color ramp: anticipation (yellow, low alpha) → commit (orange,
#     building alpha) → snap (red, max intensity flash on the final ~10%)
#   - Outline ring drawn as a separate mesh so the indicator reads against
#     any background, not just dark dungeon floors
#   - Optional Decal projection so the fill conforms to uneven terrain
#     instead of z-fighting
#   - Audio cue hook fired on telegraph start so the player can hear
#     incoming attacks even with the camera off-center
#
# Color ramp tuned for color-blind safety: the saturation/value contrast
# between yellow→orange→red is what carries the message, so deuteranopes
# still see the phase change as a brightness ramp.

const PHASE_ANTICIPATION_FRAC: float = 0.30
const PHASE_COMMIT_FRAC: float = 0.50  # 0.30 → 0.80
const PHASE_SNAP_FRAC: float = 0.20    # 0.80 → 1.00

const TELEGRAPH_YELLOW: Color = Color(1.0, 0.85, 0.10)
const TELEGRAPH_ORANGE: Color = Color(1.0, 0.42, 0.05)
const TELEGRAPH_RED:    Color = Color(1.0, 0.10, 0.05)

const OUTLINE_THICKNESS_FRAC: float = 0.06  # ring width as fraction of radius


static func show_circle_telegraph(
	position: Vector3,
	radius: float,
	duration: float,
	parent: Node,
	use_decal: bool = true,
	sfx_id: StringName = &"",
) -> Node3D:
	## Polished circular AoE telegraph. Returns the container Node3D so the
	## caller can attach it to a moving enemy or pass it to coordinated cues.
	var container: Node3D = Node3D.new()
	container.name = "CircleTelegraph"
	parent.add_child(container)
	container.global_position = position + Vector3(0, 0.05, 0)

	# === FILL ===
	var fill: Node3D
	if use_decal:
		fill = _make_decal_fill(radius, container)
	else:
		fill = _make_plane_fill(radius, container)

	# === OUTLINE RING ===
	var outline: MeshInstance3D = _make_ring_outline(radius, container)

	# === TWEENED 3-PHASE COLOR RAMP ===
	_animate_3phase(fill, outline, duration)

	# === AUDIO CUE ===
	if sfx_id != &"" and Engine.has_singleton("SfxManager"):
		(Engine.get_singleton("SfxManager") as Object).call(&"play", sfx_id, position)
	elif sfx_id != &"":
		var sfx: Node = Engine.get_main_loop().root.get_node_or_null("/root/SfxManager")
		if sfx != null and sfx.has_method("play"):
			sfx.play(sfx_id, position)

	# === FREE AFTER DURATION ===
	var free_tween: Tween = container.create_tween()
	free_tween.tween_interval(duration + 0.05)
	free_tween.tween_callback(container.queue_free)

	return container


static func show_line_telegraph(
	origin: Vector3,
	direction: Vector3,
	length: float,
	width: float,
	duration: float,
	parent: Node,
	sfx_id: StringName = &"",
) -> Node3D:
	## Polished line/lunge telegraph. Same 3-phase ramp + outline as the
	## circle helper but rectangular.
	var container: Node3D = Node3D.new()
	container.name = "LineTelegraph"
	parent.add_child(container)
	var mid: Vector3 = origin + direction.normalized() * (length * 0.5)
	container.global_position = mid + Vector3(0, 0.05, 0)
	container.rotation.y = atan2(direction.x, direction.z)

	# Fill plane
	var fill: MeshInstance3D = MeshInstance3D.new()
	var fill_mesh: PlaneMesh = PlaneMesh.new()
	fill_mesh.size = Vector2(width, length)
	fill.mesh = fill_mesh
	var fill_mat: StandardMaterial3D = _make_telegraph_material()
	fill.material_override = fill_mat
	container.add_child(fill)

	# Outline rectangle (4 thin border planes)
	var border: Node3D = _make_rect_outline(width, length, container)
	# Wrap border meshes in a single MeshInstance3D-like container so we
	# can re-color all 4 borders together. Use the container itself.
	# We'll iterate the children's materials in the tween instead.

	_animate_line_3phase(fill_mat, border, duration)

	if sfx_id != &"":
		var sfx: Node = Engine.get_main_loop().root.get_node_or_null("/root/SfxManager")
		if sfx != null and sfx.has_method("play"):
			sfx.play(sfx_id, origin)

	var free_tween: Tween = container.create_tween()
	free_tween.tween_interval(duration + 0.05)
	free_tween.tween_callback(container.queue_free)

	return container


# === Internal builders ===

static func _make_telegraph_material(initial_color: Color = TELEGRAPH_YELLOW) -> StandardMaterial3D:
	var mat: StandardMaterial3D = StandardMaterial3D.new()
	mat.albedo_color = Color(initial_color.r, initial_color.g, initial_color.b, 0.0)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.emission_enabled = true
	mat.emission = initial_color
	mat.emission_energy_multiplier = 0.0
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	return mat


static func _make_decal_fill(radius: float, parent: Node3D) -> Decal:
	var dec: Decal = Decal.new()
	dec.size = Vector3(radius * 2.0, 1.5, radius * 2.0)
	dec.modulate = Color(1.0, 0.85, 0.10, 0.0)
	dec.emission_energy = 0.0
	dec.albedo_mix = 0.95
	parent.add_child(dec)
	return dec


static func _make_plane_fill(radius: float, parent: Node3D) -> MeshInstance3D:
	var mi: MeshInstance3D = MeshInstance3D.new()
	var pm: PlaneMesh = PlaneMesh.new()
	pm.size = Vector2(radius * 2.0, radius * 2.0)
	mi.mesh = pm
	mi.material_override = _make_telegraph_material()
	parent.add_child(mi)
	return mi


static func _make_ring_outline(radius: float, parent: Node3D) -> MeshInstance3D:
	## Builds an annular ring as a TorusMesh laid flat.
	var mi: MeshInstance3D = MeshInstance3D.new()
	var torus: TorusMesh = TorusMesh.new()
	torus.inner_radius = radius * (1.0 - OUTLINE_THICKNESS_FRAC)
	torus.outer_radius = radius
	mi.mesh = torus
	mi.rotation.x = deg_to_rad(90.0)  # lay flat on ground
	mi.material_override = _make_telegraph_material()
	parent.add_child(mi)
	return mi


static func _make_rect_outline(width: float, length: float, parent: Node3D) -> Node3D:
	## Builds the 4 thin border planes around a rectangle.
	var border_root: Node3D = Node3D.new()
	border_root.name = "OutlineBorder"
	parent.add_child(border_root)
	var thickness: float = max(width, length) * 0.04
	# 2 long sides + 2 short sides
	for side: int in 4:
		var mi: MeshInstance3D = MeshInstance3D.new()
		var pm: PlaneMesh = PlaneMesh.new()
		var is_long_side: bool = side < 2
		if is_long_side:
			pm.size = Vector2(thickness, length)
			mi.position = Vector3(width * 0.5 if side == 0 else -width * 0.5, 0.01, 0)
		else:
			pm.size = Vector2(width, thickness)
			mi.position = Vector3(0, 0.01, length * 0.5 if side == 2 else -length * 0.5)
		mi.mesh = pm
		mi.material_override = _make_telegraph_material()
		border_root.add_child(mi)
	return border_root


# === Internal animators ===

static func _animate_3phase(fill: Node3D, outline: MeshInstance3D, duration: float) -> void:
	var d_anti: float = duration * PHASE_ANTICIPATION_FRAC
	var d_commit: float = duration * PHASE_COMMIT_FRAC
	var d_snap: float = duration * PHASE_SNAP_FRAC

	var fill_alpha_targets := [0.20, 0.45, 0.85]
	var fill_emission_targets := [1.0, 2.5, 6.0]
	var color_targets := [TELEGRAPH_YELLOW, TELEGRAPH_ORANGE, TELEGRAPH_RED]

	# Drive a Decal vs MeshInstance3D differently
	var is_decal: bool = fill is Decal
	var fill_mat: StandardMaterial3D = null
	if not is_decal and fill is MeshInstance3D:
		fill_mat = (fill as MeshInstance3D).material_override as StandardMaterial3D

	var outline_mat: StandardMaterial3D = outline.material_override as StandardMaterial3D

	var tw: Tween = fill.create_tween()
	tw.set_parallel(false)

	for phase: int in 3:
		var d: float = [d_anti, d_commit, d_snap][phase]
		var a: float = fill_alpha_targets[phase]
		var e: float = fill_emission_targets[phase]
		var c: Color = color_targets[phase]
		var ease_type: int = Tween.EASE_OUT if phase < 2 else Tween.EASE_IN
		var trans_type: int = Tween.TRANS_QUAD if phase < 2 else Tween.TRANS_EXPO

		tw.tween_callback(func(): pass)  # phase boundary marker

		if is_decal:
			var dec: Decal = fill as Decal
			tw.parallel().tween_property(dec, "modulate", Color(c.r, c.g, c.b, a), d) \
				.set_trans(trans_type).set_ease(ease_type)
			tw.parallel().tween_property(dec, "emission_energy", e, d) \
				.set_trans(trans_type).set_ease(ease_type)
		elif fill_mat != null:
			tw.parallel().tween_property(fill_mat, "albedo_color", Color(c.r, c.g, c.b, a), d) \
				.set_trans(trans_type).set_ease(ease_type)
			tw.parallel().tween_property(fill_mat, "emission", c, d) \
				.set_trans(trans_type).set_ease(ease_type)
			tw.parallel().tween_property(fill_mat, "emission_energy_multiplier", e, d) \
				.set_trans(trans_type).set_ease(ease_type)

		# Outline tracks the same color but stays at higher alpha (it's the
		# silhouette anchor; the player should always see WHERE the indicator is)
		if outline_mat != null:
			var outline_alpha: float = clampf(a + 0.30, 0.4, 1.0)
			tw.parallel().tween_property(outline_mat, "albedo_color", Color(c.r, c.g, c.b, outline_alpha), d) \
				.set_trans(trans_type).set_ease(ease_type)
			tw.parallel().tween_property(outline_mat, "emission", c, d) \
				.set_trans(trans_type).set_ease(ease_type)
			tw.parallel().tween_property(outline_mat, "emission_energy_multiplier", e * 1.2, d) \
				.set_trans(trans_type).set_ease(ease_type)


static func _animate_line_3phase(fill_mat: StandardMaterial3D, border_root: Node3D, duration: float) -> void:
	var border_mats: Array[StandardMaterial3D] = []
	for child: Node in border_root.get_children():
		if child is MeshInstance3D:
			var m: Material = (child as MeshInstance3D).material_override
			if m is StandardMaterial3D:
				border_mats.append(m)

	var d_anti: float = duration * PHASE_ANTICIPATION_FRAC
	var d_commit: float = duration * PHASE_COMMIT_FRAC
	var d_snap: float = duration * PHASE_SNAP_FRAC

	var fill_alpha_targets := [0.18, 0.40, 0.80]
	var fill_emission_targets := [1.0, 2.5, 6.0]
	var color_targets := [TELEGRAPH_YELLOW, TELEGRAPH_ORANGE, TELEGRAPH_RED]

	var tw: Tween = border_root.create_tween()
	for phase: int in 3:
		var d: float = [d_anti, d_commit, d_snap][phase]
		var a: float = fill_alpha_targets[phase]
		var e: float = fill_emission_targets[phase]
		var c: Color = color_targets[phase]
		var trans_type: int = Tween.TRANS_QUAD if phase < 2 else Tween.TRANS_EXPO
		var ease_type: int = Tween.EASE_OUT if phase < 2 else Tween.EASE_IN

		tw.tween_property(fill_mat, "albedo_color", Color(c.r, c.g, c.b, a), d) \
			.set_trans(trans_type).set_ease(ease_type)
		tw.parallel().tween_property(fill_mat, "emission", c, d)
		tw.parallel().tween_property(fill_mat, "emission_energy_multiplier", e, d)
		for bm: StandardMaterial3D in border_mats:
			tw.parallel().tween_property(bm, "albedo_color", Color(c.r, c.g, c.b, clampf(a + 0.30, 0.4, 1.0)), d)
			tw.parallel().tween_property(bm, "emission", c, d)
			tw.parallel().tween_property(bm, "emission_energy_multiplier", e * 1.2, d)


static func show_charge_glow(mesh_instance: MeshInstance3D, duration: float, color: Color = Color(1.0, 0.13, 0.0)) -> void:
	## Applies a pulsing glow overlay to a mesh during attack wind-up.
	if mesh_instance == null or not is_instance_valid(mesh_instance):
		return
	var original_mat: Material = mesh_instance.material_override
	var glow_mat: StandardMaterial3D = StandardMaterial3D.new()
	if original_mat is StandardMaterial3D:
		glow_mat.albedo_color = (original_mat as StandardMaterial3D).albedo_color
	else:
		glow_mat.albedo_color = color
	glow_mat.emission_enabled = true
	glow_mat.emission = color
	glow_mat.emission_energy_multiplier = 0.0
	mesh_instance.material_override = glow_mat

	var tween: Tween = mesh_instance.create_tween()
	# Pulsing glow that intensifies
	tween.tween_property(glow_mat, "emission_energy_multiplier", 2.0, duration * 0.3)
	tween.tween_property(glow_mat, "emission_energy_multiplier", 1.0, duration * 0.1)
	tween.tween_property(glow_mat, "emission_energy_multiplier", 3.0, duration * 0.3)
	tween.tween_property(glow_mat, "emission_energy_multiplier", 1.5, duration * 0.1)
	tween.tween_property(glow_mat, "emission_energy_multiplier", 4.0, duration * 0.2)
	# Restore original material
	tween.tween_callback(func() -> void:
		if is_instance_valid(mesh_instance):
			mesh_instance.material_override = original_mat
	)
