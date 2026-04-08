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

	var dropped_scene: PackedScene = load("res://scenes/items/DroppedItem.tscn") as PackedScene
	if dropped_scene == null:
		push_error("LootDropper: DroppedItem.tscn failed to load — cannot spawn item")
		return
	var dropped: Node = dropped_scene.instantiate() as Node
	dropped.item = item
	parent.add_child(dropped)
	dropped.global_position = pos + offset


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
