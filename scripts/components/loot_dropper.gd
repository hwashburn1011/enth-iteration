class_name LootDropper
extends Node
## Reads from a loot table and spawns DroppedItem scenes in the world.

@export var loot_table: Resource

const PROMPT_DROP_CHANCE: float = 0.30
const SCATTER_MIN: float = 1.0
const SCATTER_MAX: float = 2.0

func drop_loot(global_pos: Vector3) -> void:
	var scene_root: Node = get_tree().current_scene
	if scene_root == null:
		return

	# Drop from loot table entries
	if loot_table:
		for entry: Resource in loot_table.entries:
			if randf() > entry.drop_chance:
				continue
			var quantity: int = randi_range(entry.min_quantity, entry.max_quantity)
			for i: int in quantity:
				var item: Resource = load("res://scripts/items/item_generator.gd").generate_item(entry.item_base)
				_spawn_dropped_item(item, global_pos, scene_root)

	# Universal prompt sub-table (30% chance)
	if randf() < PROMPT_DROP_CHANCE:
		var prompt: Resource = _create_random_prompt()
		_spawn_dropped_item(prompt, global_pos, scene_root)


func _spawn_dropped_item(item: Resource, pos: Vector3, parent: Node) -> void:
	# Scatter offset
	var angle: float = randf() * TAU
	var dist: float = randf_range(SCATTER_MIN, SCATTER_MAX)
	var offset: Vector3 = Vector3(cos(angle) * dist, 0.0, sin(angle) * dist)

	# Use DroppedItem scene if available, else fallback to manual creation
	var dropped_scene: PackedScene = load("res://scenes/items/DroppedItem.tscn") as PackedScene
	if dropped_scene:
		var dropped: Node = dropped_scene.instantiate() as Node
		dropped.item = item
		parent.add_child(dropped)
		dropped.global_position = pos + offset
	else:
		var dropped: Node3D = _create_dropped_item_node(item)
		parent.add_child(dropped)
		dropped.global_position = pos + offset


func _create_dropped_item_node(item: Resource) -> Node3D:
	# Create a simple Area3D placeholder (DroppedItem scene will be used in story 4.7)
	var node: Area3D = Area3D.new()
	node.name = "DroppedItem"
	node.set_meta(&"item", item)

	# Collision for pickup
	var col: CollisionShape3D = CollisionShape3D.new()
	var sphere: SphereShape3D = SphereShape3D.new()
	sphere.radius = 1.0
	col.shape = sphere
	node.add_child(col)

	# Visual placeholder — small box colored by rarity
	var mesh: MeshInstance3D = MeshInstance3D.new()
	var box: BoxMesh = BoxMesh.new()
	box.size = Vector3(0.3, 0.3, 0.3)
	mesh.mesh = box
	var mat: StandardMaterial3D = StandardMaterial3D.new()
	mat.albedo_color = _rarity_color(item.rarity)
	mesh.material_override = mat
	mesh.position = Vector3(0, 0.3, 0)
	node.add_child(mesh)

	# Label
	var label: Label3D = Label3D.new()
	label.text = item.item_name
	label.position = Vector3(0, 0.8, 0)
	label.font_size = 24
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	node.add_child(label)

	return node


func _rarity_color(rarity: int) -> Color:
	match rarity:
		0: return Color(0.9, 0.9, 0.9)   # Common — white
		1: return Color(0.3, 0.9, 0.3)   # Uncommon — green
		2: return Color(0.3, 0.5, 1.0)   # Rare — blue
		3: return Color(1.0, 0.85, 0.1)  # Legendary — gold
		_: return Color.WHITE


func _create_random_prompt() -> Resource:
	var prompt: Resource = load("res://scripts/items/prompt_item.gd").new()
	if randf() < 0.5:
		prompt.item_name = "Health Prompt"
		prompt.item_id = "prompt_health_small"
		prompt.prompt_type = "health"
		prompt.restore_amount = 25.0
	else:
		prompt.item_name = "Compute Prompt"
		prompt.item_id = "prompt_compute_small"
		prompt.prompt_type = "compute"
		prompt.restore_amount = 15.0
	prompt.rarity = 0
	return prompt
