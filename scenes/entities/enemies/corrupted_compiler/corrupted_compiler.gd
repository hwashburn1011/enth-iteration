class_name CorruptedCompiler
extends "res://scenes/entities/enemies/enemy_base.gd"
## First boss — multi-phase encounter with escalating attack patterns.

signal phase_changed(new_phase: int)

const PHASE_THRESHOLDS: Array[float] = [1.0, 0.6, 0.3]

var current_phase: int = 1
var is_transitioning: bool = false
var _phase_checked: Array[bool] = [false, false, false]


func _ready() -> void:
	super._ready()
	health_component.max_health = 500.0
	health_component.current_health = 500.0
	stats_component.base_processing = 15.0
	stats_component.base_bandwidth = 5.0
	stats_component.base_integrity = 10.0
	model.scale = Vector3(2.0, 2.0, 2.0)

	health_component.health_changed.connect(_on_boss_health_changed)
	# Dramatic HUD boss bar
	call_deferred(&"_register_with_hud")


func _register_with_hud() -> void:
	if not is_inside_tree():
		return
	var hud_nodes: Array[Node] = get_tree().get_nodes_in_group(&"hud")
	if hud_nodes.is_empty():
		# Try finding by type
		for node: Node in get_tree().root.get_children():
			if node.has_method(&"show_boss_bar"):
				node.show_boss_bar(self, "CORRUPTED COMPILER")
				break
		# Search deeper
		var root: Node = get_tree().current_scene
		if root:
			for child: Node in root.get_children():
				if child.has_method(&"show_boss_bar"):
					child.show_boss_bar(self, "CORRUPTED COMPILER")
					break
	else:
		var hud: Node = hud_nodes[0]
		if hud.has_method(&"show_boss_bar"):
			hud.show_boss_bar(self, "CORRUPTED COMPILER")
	# Dramatic intro effects
	_play_boss_intro()


func _play_boss_intro() -> void:
	## Dramatic boss encounter intro: screen shake + slow-mo + pulsing light
	if not is_inside_tree():
		return
	# Brief global hitstop
	Engine.time_scale = 0.4
	get_tree().create_timer(0.5, true, false, true).timeout.connect(func() -> void:
		Engine.time_scale = 1.0
	)
	# Find player camera and shake it
	var players: Array[Node] = get_tree().get_nodes_in_group(&"player")
	if not players.is_empty():
		var player: Node = players[0]
		var camera: Camera3D = player.get_viewport().get_camera_3d()
		if camera and camera.has_method(&"shake"):
			camera.shake(0.3, 3.0)
	# Red ground shockwave emanating from boss
	var shock: MeshInstance3D = MeshInstance3D.new()
	var torus: TorusMesh = TorusMesh.new()
	torus.inner_radius = 0.5
	torus.outer_radius = 0.8
	torus.rings = 16
	torus.ring_segments = 20
	shock.mesh = torus
	shock.scale = Vector3(0.5, 0.5, 0.5)
	var mat: StandardMaterial3D = StandardMaterial3D.new()
	mat.albedo_color = Color(0.9, 0.1, 0.05, 0.8)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.emission_enabled = true
	mat.emission = Color(0.85, 0.1, 0.03)
	mat.emission_energy_multiplier = 4.0
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	shock.material_override = mat
	get_tree().current_scene.add_child(shock)
	shock.global_position = global_position + Vector3(0, 0.1, 0)
	var tween: Tween = shock.create_tween()
	tween.tween_property(shock, "scale", Vector3(8.0, 1.0, 8.0), 1.2).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(mat, "albedo_color:a", 0.0, 1.5)
	tween.tween_callback(shock.queue_free)


func _build_enemy_visual() -> void:
	for child: Node in model.get_children():
		child.queue_free()
	# Try Blender model first
	var glb: PackedScene = load("res://assets/models/enemies/enemy_corrupted_compiler_v2.glb") as PackedScene
	if glb:
		var instance: Node3D = glb.instantiate() as Node3D
		model.add_child(instance)
		return
	# Fallback: Large dark-red core body
	var core: MeshInstance3D = MeshInstance3D.new()
	var core_mesh: SphereMesh = SphereMesh.new()
	core_mesh.radius = 0.6
	core_mesh.height = 1.0
	core_mesh.radial_segments = 8
	core_mesh.rings = 4
	core.mesh = core_mesh
	core.position = Vector3(0, 0.5, 0)
	var mat: StandardMaterial3D = StandardMaterial3D.new()
	mat.albedo_color = Color(0.5, 0.1, 0.15)
	mat.emission_enabled = true
	mat.emission = Color(0.6, 0.05, 0.2)
	mat.emission_energy_multiplier = 1.0
	mat.roughness = 0.4
	core.material_override = mat
	model.add_child(core)
	# Orbiting armor plates
	for i: int in 4:
		var plate: MeshInstance3D = MeshInstance3D.new()
		var plate_mesh: BoxMesh = BoxMesh.new()
		plate_mesh.size = Vector3(0.3, 0.6, 0.1)
		plate.mesh = plate_mesh
		var angle: float = i * TAU / 4.0
		plate.position = Vector3(cos(angle) * 0.7, 0.5, sin(angle) * 0.7)
		plate.rotation.y = angle
		var plate_mat: StandardMaterial3D = StandardMaterial3D.new()
		plate_mat.albedo_color = Color(0.3, 0.05, 0.1)
		plate_mat.emission_enabled = true
		plate_mat.emission = Color(0.4, 0.02, 0.1)
		plate_mat.emission_energy_multiplier = 0.5
		plate.material_override = plate_mat
		model.add_child(plate)
	# Top eye/core
	var eye: MeshInstance3D = MeshInstance3D.new()
	var eye_mesh: SphereMesh = SphereMesh.new()
	eye_mesh.radius = 0.15
	eye_mesh.height = 0.3
	eye.mesh = eye_mesh
	eye.position = Vector3(0, 1.0, 0)
	var eye_mat: StandardMaterial3D = StandardMaterial3D.new()
	eye_mat.albedo_color = Color(1.0, 0.2, 0.1)
	eye_mat.emission_enabled = true
	eye_mat.emission = Color(1.0, 0.15, 0.05)
	eye_mat.emission_energy_multiplier = 3.0
	eye.material_override = eye_mat
	model.add_child(eye)


func _process(_delta: float) -> void:
	# Pulse emission across all mesh instances under the model (works for
	# both placeholder fallback meshes and the Blender GLB model tree)
	var pulse: float = 0.8 + sin(Time.get_ticks_msec() * 0.003) * 0.4
	for mesh: MeshInstance3D in _find_mesh_instances(model):
		if mesh.material_override is StandardMaterial3D:
			var mat: StandardMaterial3D = mesh.material_override as StandardMaterial3D
			mat.emission_energy_multiplier = pulse


func _find_mesh_instances(root: Node) -> Array[MeshInstance3D]:
	var out: Array[MeshInstance3D] = []
	var stack: Array = [root]
	while not stack.is_empty():
		var n: Node = stack.pop_back()
		if n is MeshInstance3D:
			out.append(n as MeshInstance3D)
		for c in n.get_children():
			stack.append(c)
	return out


func _on_boss_health_changed(current: float, max_val: float) -> void:
	var pct: float = current / max_val
	if pct <= PHASE_THRESHOLDS[2] and not _phase_checked[2]:
		_phase_checked[2] = true
		_transition_to_phase(3)
	elif pct <= PHASE_THRESHOLDS[1] and not _phase_checked[1]:
		_phase_checked[1] = true
		_transition_to_phase(2)


func _transition_to_phase(new_phase: int) -> void:
	is_transitioning = true
	is_invulnerable = true
	current_phase = new_phase
	phase_changed.emit(new_phase)

	# Stagger animation — flash all mesh children white
	var meshes: Array[MeshInstance3D] = _find_mesh_instances(model)
	var flash_mat: StandardMaterial3D = StandardMaterial3D.new()
	flash_mat.albedo_color = Color.WHITE
	flash_mat.emission_enabled = true
	flash_mat.emission = Color.WHITE
	flash_mat.emission_energy_multiplier = 3.0
	for mesh: MeshInstance3D in meshes:
		mesh.material_override = flash_mat

	velocity = Vector3.ZERO

	# Phase transition shockwave + camera shake
	_spawn_phase_transition_shockwave(new_phase)
	var camera: Camera3D = get_viewport().get_camera_3d()
	if camera and camera.has_method(&"shake"):
		camera.shake(0.25, 4.0)

	await get_tree().create_timer(1.5).timeout

	# Restore default red material on every mesh
	var restore_mat: StandardMaterial3D = StandardMaterial3D.new()
	restore_mat.albedo_color = Color(0.5, 0.1, 0.15)
	restore_mat.emission_enabled = true
	restore_mat.emission = Color(0.6, 0.05, 0.2)
	restore_mat.emission_energy_multiplier = 1.0
	for mesh: MeshInstance3D in meshes:
		if is_instance_valid(mesh):
			mesh.material_override = restore_mat

	is_invulnerable = false
	is_transitioning = false

	# Phase 3: spawn adds
	if new_phase == 3:
		for i: int in 2:
			var enemy: CharacterBody3D = EnemyPool.get_enemy("rogue_process")
			if enemy:
				enemy.global_position = global_position + Vector3(randf_range(-4, 4), 0, randf_range(-4, 4))
				if enemy.is_in_group(&"enemies"):
					(enemy as CharacterBody3D).spawn_position = enemy.global_position
				enemy.reparent(get_tree().current_scene)


func _spawn_phase_transition_shockwave(new_phase: int) -> void:
	if not is_inside_tree():
		return
	# Phase color: 2=orange, 3=deep red
	var color: Color = Color(1.0, 0.45, 0.1) if new_phase == 2 else Color(0.95, 0.1, 0.05)
	var ring: MeshInstance3D = MeshInstance3D.new()
	var torus: TorusMesh = TorusMesh.new()
	torus.inner_radius = 0.6
	torus.outer_radius = 0.9
	torus.rings = 16
	torus.ring_segments = 20
	ring.mesh = torus
	ring.scale = Vector3(0.5, 0.5, 0.5)
	var mat: StandardMaterial3D = StandardMaterial3D.new()
	mat.albedo_color = Color(color.r, color.g, color.b, 0.8)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.emission_enabled = true
	mat.emission = color
	mat.emission_energy_multiplier = 5.0
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	ring.material_override = mat
	get_tree().current_scene.add_child(ring)
	ring.global_position = global_position + Vector3(0, 0.2, 0)
	var tween: Tween = ring.create_tween()
	tween.tween_property(ring, "scale", Vector3(10.0, 1.0, 10.0), 1.2).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(mat, "albedo_color:a", 0.0, 1.4)
	tween.tween_callback(ring.queue_free)


func _on_died() -> void:
	EventBus.boss_defeated.emit(&"corrupted_compiler", global_position, null)
	# Drop guaranteed loot
	_drop_boss_loot()
	var death_state: Node = state_machine.get_node_or_null("EnemyDeathState") as Node
	if death_state:
		state_machine.force_transition_to(death_state)


func _drop_boss_loot() -> void:
	var scene_root: Node = get_tree().current_scene
	# 1. Rare or Legendary item
	var chip: Resource = load("res://scripts/items/item_registry.gd").get_base_item("chip_bandwidth_booster")
	if chip:
		var item: Resource = load("res://scripts/items/item_generator.gd").generate_item(chip, 3 if randf() < 0.1 else 2)
		_spawn_drop(item, scene_root)
	# 2. Uncommon Module
	var module: Resource = load("res://scripts/items/item_registry.gd").get_base_item("module_packet_storm")
	if module:
		var item: Resource = load("res://scripts/items/item_generator.gd").generate_item(module, 1)
		_spawn_drop(item, scene_root)
	# 3. 5 Health Prompts
	for i: int in 5:
		var prompt: Resource = load("res://scripts/items/prompt_item.gd").new()
		prompt.item_name = "Health Prompt"
		prompt.item_id = "prompt_health_small"
		prompt.prompt_type = "health"
		prompt.restore_amount = 30.0
		prompt.rarity = 0
		_spawn_drop(prompt, scene_root)


func _spawn_drop(item: Resource, parent: Node) -> void:
	var scene: PackedScene = load("res://scenes/items/DroppedItem.tscn") as PackedScene
	if scene == null:
		return
	var dropped: Node = scene.instantiate() as Node
	dropped.item = item
	var offset: Vector3 = Vector3(randf_range(-2, 2), 0, randf_range(-2, 2))
	parent.add_child(dropped)
	dropped.global_position = global_position + offset
