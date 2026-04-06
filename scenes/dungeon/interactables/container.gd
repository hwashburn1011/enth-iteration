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

	# Open animation placeholder — squash lid
	var tween: Tween = create_tween()
	tween.tween_property(_mesh, "scale:y", 0.3, 0.3)

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


func _spawn_item(item: Resource) -> void:
	var dropped_scene: PackedScene = load("res://scenes/items/DroppedItem.tscn") as PackedScene
	if dropped_scene == null:
		return
	var dropped: Node = dropped_scene.instantiate() as Node
	dropped.item = item
	var angle: float = randf() * TAU
	var dist: float = randf_range(0.5, 1.5)
	dropped.global_position = global_position + Vector3(cos(angle) * dist, 0.5, sin(angle) * dist)
	get_tree().current_scene.add_child(dropped)
