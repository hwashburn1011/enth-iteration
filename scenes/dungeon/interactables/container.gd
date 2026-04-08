class_name LootContainer
extends Area3D
## Interactable loot container — opens once to spawn dropped items.

signal opened

@export var loot_table: Resource
@export var drop_count_min: int = 1
@export var drop_count_max: int = 3

var is_opened: bool = false
var _player_in_range: bool = false

@onready var _mesh: MeshInstance3D = %ContainerMesh
@onready var _tooltip: Label3D = %Tooltip


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	_tooltip.visible = false
	_build_chest_visual()


func _build_chest_visual() -> void:
	var glb: PackedScene = load("res://assets/models/props/loot_chest.glb") as PackedScene
	if glb and _mesh:
		var instance: Node3D = glb.instantiate() as Node3D
		_mesh.add_child(instance)
		# Add a subtle glow light
		var light: OmniLight3D = OmniLight3D.new()
		light.position = Vector3(0, 0.5, 0)
		light.light_color = Color(0.2, 0.6, 0.7)
		light.light_energy = 0.8
		light.omni_range = 3.0
		_mesh.add_child(light)


func _unhandled_input(event: InputEvent) -> void:
	if not _player_in_range or is_opened:
		return
	if event.is_action_pressed(&"interact"):
		_open()


func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group(&"player") and not is_opened:
		_player_in_range = true
		_tooltip.text = "Press E to open"
		_tooltip.visible = true


func _on_body_exited(body: Node3D) -> void:
	if body.is_in_group(&"player"):
		_player_in_range = false
		_tooltip.visible = false


func _open() -> void:
	is_opened = true
	_tooltip.visible = false

	# Open animation — lid pop with overshoot
	var tween: Tween = create_tween()
	tween.tween_property(_mesh, "scale:y", 1.2, 0.08).set_ease(Tween.EASE_OUT)
	tween.tween_property(_mesh, "scale:y", 0.3, 0.2)

	# Chest open VFX — golden burst + light flash
	_spawn_open_vfx()

	# Spawn loot
	var drop_count: int = randi_range(drop_count_min, drop_count_max)
	if loot_table:
		for entry: Resource in loot_table.entries:
			if randf() > entry.drop_chance:
				continue
			var item: Resource = load("res://scripts/items/item_generator.gd").generate_item(entry.item_base)
			_spawn_item(item)
			drop_count -= 1
			if drop_count <= 0:
				break

	# If loot table didn't produce enough, spawn prompt drops
	for i: int in maxi(0, drop_count):
		var prompt: Resource = load("res://scripts/items/prompt_item.gd").new()
		prompt.item_name = "Health Prompt" if randf() < 0.5 else "Compute Prompt"
		prompt.item_id = "prompt_health_small" if prompt.item_name == "Health Prompt" else "prompt_compute_small"
		prompt.prompt_type = "health" if prompt.item_name == "Health Prompt" else "compute"
		prompt.restore_amount = 25.0 if prompt.prompt_type == "health" else 15.0
		prompt.rarity = 0
		_spawn_item(prompt)

	opened.emit()


func _spawn_open_vfx() -> void:
	if not is_inside_tree():
		return
	var pos: Vector3 = global_position + Vector3(0, 0.5, 0)
	var scene_root: Node = get_tree().current_scene
	# Golden particle burst upward
	var particles: GPUParticles3D = GPUParticles3D.new()
	particles.amount = 20
	particles.lifetime = 0.8
	particles.one_shot = true
	particles.emitting = true
	particles.global_position = pos
	var pmat: ParticleProcessMaterial = ParticleProcessMaterial.new()
	pmat.direction = Vector3(0, 1, 0)
	pmat.spread = 60.0
	pmat.initial_velocity_min = 2.0
	pmat.initial_velocity_max = 4.0
	pmat.gravity = Vector3(0, -3, 0)
	pmat.color = Color(1.0, 0.85, 0.3, 0.8)
	pmat.scale_min = 0.4
	pmat.scale_max = 1.2
	particles.process_material = pmat
	var mesh: SphereMesh = SphereMesh.new()
	mesh.radius = 0.04
	mesh.height = 0.08
	particles.draw_pass_1 = mesh
	var vis: StandardMaterial3D = StandardMaterial3D.new()
	vis.albedo_color = Color(1.0, 0.85, 0.3, 0.8)
	vis.emission_enabled = true
	vis.emission = Color(1.0, 0.8, 0.2)
	vis.emission_energy_multiplier = 3.0
	vis.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	particles.material_override = vis
	scene_root.add_child(particles)
	get_tree().create_timer(1.2).timeout.connect(particles.queue_free)
	# Bright flash
	VFXFactory.spawn_hit_flash(pos, scene_root)
	# Temporary bright light that fades
	var flash_light: OmniLight3D = OmniLight3D.new()
	flash_light.global_position = pos
	flash_light.light_color = Color(1.0, 0.85, 0.4)
	flash_light.light_energy = 4.0
	flash_light.omni_range = 6.0
	scene_root.add_child(flash_light)
	var light_tween: Tween = flash_light.create_tween()
	light_tween.tween_property(flash_light, "light_energy", 0.0, 0.8)
	light_tween.tween_callback(flash_light.queue_free)


func _spawn_item(item: Resource) -> void:
	var dropped_scene: PackedScene = load("res://scenes/items/DroppedItem.tscn") as PackedScene
	if dropped_scene == null:
		return
	var dropped: Node = dropped_scene.instantiate() as Node
	dropped.item = item
	var angle: float = randf() * TAU
	var dist: float = randf_range(0.5, 1.5)
	get_tree().current_scene.add_child(dropped)
	dropped.global_position = global_position + Vector3(cos(angle) * dist, 0.5, sin(angle) * dist)
