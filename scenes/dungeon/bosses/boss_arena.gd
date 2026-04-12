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
