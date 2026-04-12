class_name BossArena
extends "res://scenes/dungeon/rooms/room_base.gd"
## Boss arena — large room with destructible pillars. Spawns portal on boss defeat.

var _boss_defeated: bool = false


func _ready() -> void:
	room_type = "combat"
	is_cleared = false
	super._ready()
	EventBus.boss_defeated.connect(_on_boss_defeated)
	# Boss music — falls back gracefully to whatever track is currently
	# playing if the boss_music asset isn't authored yet (audio_manager
	# warns and keeps the current track per T54).
	AudioManager.play_music("boss_music")
	# R5 round-7: BossArena.tscn ships with PillarR3_1..4 GLB instances and a
	# TreasurePileR5 prop, all wearing the placeholder white R3 baked albedo.
	# Apply digital theme overrides so they fit the cyan/violet cyber theme.
	_polish_arena_props()
	# Phase 2 #17: cinematic intro banner. Make each iteration's boss
	# feel like an event — tinted iteration label + boss name banner
	# with a music sting on entry. Deferred so the scene tree, HUD,
	# and player are all parented before we add the canvas overlay.
	call_deferred(&"_play_boss_arena_intro")


func _polish_arena_props() -> void:
	var geom: Node = get_node_or_null("Geometry")
	if geom == null:
		return
	# Pillar material: dark base + bright cyan emission edges (data column)
	var pillar_mat: StandardMaterial3D = StandardMaterial3D.new()
	pillar_mat.albedo_color = Color(0.10, 0.18, 0.26)
	pillar_mat.emission_enabled = true
	pillar_mat.emission = Color(0.20, 0.65, 0.85)
	pillar_mat.emission_energy_multiplier = 0.7
	pillar_mat.metallic = 0.6
	pillar_mat.roughness = 0.4
	pillar_mat.transparency = BaseMaterial3D.TRANSPARENCY_DISABLED
	# Treasure pile: warm amber emissive (data hoard / glowing memory)
	var hoard_mat: StandardMaterial3D = StandardMaterial3D.new()
	hoard_mat.albedo_color = Color(0.45, 0.30, 0.05)
	hoard_mat.emission_enabled = true
	hoard_mat.emission = Color(0.95, 0.65, 0.10)
	hoard_mat.emission_energy_multiplier = 0.85
	hoard_mat.metallic = 0.85
	hoard_mat.roughness = 0.25
	# Gem material: bright cyan crystal
	var gem_mat: StandardMaterial3D = StandardMaterial3D.new()
	gem_mat.albedo_color = Color(0.30, 0.80, 0.95)
	gem_mat.emission_enabled = true
	gem_mat.emission = Color(0.50, 0.95, 1.0)
	gem_mat.emission_energy_multiplier = 2.5
	gem_mat.metallic = 0.6
	gem_mat.roughness = 0.15
	for child in geom.get_children():
		if child is Node3D and child.name.begins_with("PillarR3"):
			_apply_to_meshes(child, pillar_mat)
			# R5 round-45: pillars are solid props but ship without collision —
			# player walks through them. Add procedural collision.
			_add_solid_collision_local(child as Node3D)
		elif child is Node3D and child.name.begins_with("TreasurePile"):
			# Body gets hoard, gem children get gem material
			for sub in child.get_children():
				if sub is MeshInstance3D:
					if "gem" in sub.name.to_lower():
						(sub as MeshInstance3D).material_override = gem_mat
					else:
						(sub as MeshInstance3D).material_override = hoard_mat
			# R5 round-45: treasure pile is also a solid prop — add collision
			_add_solid_collision_local(child as Node3D)


func _add_solid_collision_local(prop_root: Node3D) -> void:
	## R5 round-45: same helper as room_base._add_solid_collision but inlined
	## here because boss_arena.gd extends room_base, and the static helper
	## would be self-callable but for clarity duplicate the logic.
	var biggest_size: float = 0.0
	var biggest_aabb: AABB
	var st: Array = [prop_root]
	while not st.is_empty():
		var n: Node = st.pop_back()
		if n is MeshInstance3D and (n as MeshInstance3D).mesh:
			var ab: AABB = (n as MeshInstance3D).mesh.get_aabb()
			var sv: float = ab.size.x * ab.size.y * ab.size.z
			if sv > biggest_size:
				biggest_size = sv
				biggest_aabb = ab
		for c in n.get_children():
			st.append(c)
	if biggest_size <= 0.0:
		return
	var prop_scale: Vector3 = prop_root.scale
	var body: StaticBody3D = StaticBody3D.new()
	var shape: CollisionShape3D = CollisionShape3D.new()
	var box: BoxShape3D = BoxShape3D.new()
	box.size = Vector3(
		biggest_aabb.size.x * prop_scale.x,
		biggest_aabb.size.y * prop_scale.y,
		biggest_aabb.size.z * prop_scale.z
	)
	shape.shape = box
	var center: Vector3 = biggest_aabb.position + biggest_aabb.size * 0.5
	shape.position = Vector3(
		center.x * prop_scale.x,
		center.y * prop_scale.y,
		center.z * prop_scale.z
	)
	body.add_child(shape)
	prop_root.add_child(body)


func _apply_to_meshes(root: Node, mat: Material) -> void:
	var stack: Array = [root]
	while not stack.is_empty():
		var n: Node = stack.pop_back()
		if n is MeshInstance3D:
			(n as MeshInstance3D).material_override = mat
		for c in n.get_children():
			stack.append(c)


func _play_boss_arena_intro() -> void:
	## Phase 2 #17: drop-in cinematic banner that pops on boss arena entry.
	## Two stacked Labels in a CanvasLayer overlay:
	##   line 1: "ITERATION N"  — color tinted to match the dungeon biome
	##   line 2: "THE CORRUPTED COMPILER" — big slab caps, white outline
	## Plus a brief audio sting + a slowed-time pause so the player
	## actually registers the moment.
	if not is_inside_tree():
		return
	# Sting cue. Reuse boss_intro if it exists, else fall back to the
	# generic stinger that's already loaded for the dungeon. AudioManager
	# warns silently if the cue is missing (T54).
	AudioManager.play_sfx("boss_intro")
	# Resolve the iteration tint + label
	var iter: int = 1
	if has_node("/root/IterationManager"):
		var im: Node = get_node("/root/IterationManager")
		if im.has_method(&"get_current_iteration"):
			iter = int(im.get_current_iteration())
	var iter_color: Color = _intro_tint_for_iteration(iter)
	# CanvasLayer + holder Control
	var canvas: CanvasLayer = CanvasLayer.new()
	canvas.layer = 90
	add_child(canvas)
	var holder: Control = Control.new()
	holder.set_anchors_preset(Control.PRESET_FULL_RECT)
	holder.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas.add_child(holder)
	# Background vignette wash that fades the dungeon back so the
	# banner reads. Almost-transparent black gradient.
	var bg: ColorRect = ColorRect.new()
	bg.color = Color(0.0, 0.0, 0.0, 0.0)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	holder.add_child(bg)
	# Iteration label (small, color-tinted)
	var iter_label: Label = Label.new()
	iter_label.text = "ITERATION %d" % iter
	iter_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	iter_label.set_anchors_preset(Control.PRESET_TOP_WIDE)
	iter_label.offset_top = 220
	iter_label.offset_bottom = 260
	iter_label.add_theme_font_size_override(&"font_size", 28)
	iter_label.add_theme_color_override(&"font_color", iter_color)
	iter_label.add_theme_constant_override(&"outline_size", 6)
	iter_label.add_theme_color_override(&"font_outline_color", Color(0, 0, 0, 0.95))
	iter_label.modulate.a = 0.0
	iter_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	holder.add_child(iter_label)
	# Boss name banner (huge slab caps)
	var boss_label: Label = Label.new()
	boss_label.text = "THE CORRUPTED COMPILER"
	boss_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	boss_label.set_anchors_preset(Control.PRESET_TOP_WIDE)
	boss_label.offset_top = 264
	boss_label.offset_bottom = 360
	boss_label.add_theme_font_size_override(&"font_size", 64)
	boss_label.add_theme_color_override(&"font_color", Color(1.0, 0.95, 0.92))
	boss_label.add_theme_constant_override(&"outline_size", 12)
	boss_label.add_theme_color_override(&"font_outline_color", Color(0.05, 0.05, 0.10, 1.0))
	boss_label.modulate.a = 0.0
	boss_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	holder.add_child(boss_label)
	# Subtitle hint
	var sub_label: Label = Label.new()
	sub_label.text = "the loop will not close itself"
	sub_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub_label.set_anchors_preset(Control.PRESET_TOP_WIDE)
	sub_label.offset_top = 360
	sub_label.offset_bottom = 392
	sub_label.add_theme_font_size_override(&"font_size", 18)
	sub_label.add_theme_color_override(&"font_color", Color(0.80, 0.85, 0.95))
	sub_label.add_theme_constant_override(&"outline_size", 4)
	sub_label.add_theme_color_override(&"font_outline_color", Color(0, 0, 0, 0.85))
	sub_label.modulate.a = 0.0
	sub_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	holder.add_child(sub_label)
	# Tween: bg darken → iter pop → boss pop → hold → fade everything → free
	var tw: Tween = create_tween()
	tw.tween_property(bg, "color:a", 0.45, 0.30)
	tw.parallel().tween_property(iter_label, "modulate:a", 1.0, 0.30)
	tw.tween_property(boss_label, "modulate:a", 1.0, 0.35)
	tw.parallel().tween_property(sub_label, "modulate:a", 1.0, 0.45)
	tw.tween_interval(2.0)
	tw.tween_property(boss_label, "modulate:a", 0.0, 0.55)
	tw.parallel().tween_property(iter_label, "modulate:a", 0.0, 0.55)
	tw.parallel().tween_property(sub_label, "modulate:a", 0.0, 0.55)
	tw.parallel().tween_property(bg, "color:a", 0.0, 0.6)
	tw.tween_callback(canvas.queue_free)
	# Camera shake on the player camera so the moment registers.
	var players: Array[Node] = get_tree().get_nodes_in_group(&"player")
	if not players.is_empty():
		var cam: Camera3D = players[0].get_viewport().get_camera_3d()
		if cam and cam.has_method(&"shake"):
			cam.shake(0.20, 4.0)


func _intro_tint_for_iteration(iter: int) -> Color:
	## Mirrors the dungeon biome tint table so the boss intro reads
	## in the same palette as the room around it. Index clamped against
	## the array length so post-V1 iterations past 4 reuse the last tint.
	const TINTS: Array[Color] = [
		Color(0.55, 0.85, 1.00),  # 1 — cyan archive
		Color(0.75, 0.55, 1.00),  # 2 — violet strata
		Color(0.95, 0.75, 0.30),  # 3 — amber fault
		Color(1.00, 0.40, 0.35),  # 4 — red horizon
	]
	var idx: int = clampi(iter - 1, 0, TINTS.size() - 1)
	return TINTS[idx]


func _on_boss_defeated(_type: StringName, _pos: Vector3, _loot: Resource) -> void:
	if _boss_defeated:
		return
	_boss_defeated = true
	is_cleared = true
	room_cleared.emit()

	# Spawn compaction portal at center
	var portal_scene: PackedScene = load("res://scenes/dungeon/interactables/CompactionPortal.tscn") as PackedScene
	if portal_scene:
		var portal: Node3D = portal_scene.instantiate() as Node3D
		portal.global_position = global_position
		add_child(portal)

	EventBus.boss_defeated.disconnect(_on_boss_defeated)
