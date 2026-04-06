class_name ModuleItem
extends "res://scripts/items/item_base.gd"
## Equippable ability module — grants an active skill in slots 1-4.

@export var ability_scene: PackedScene
@export var compute_cost: float = 10.0
@export var cooldown: float = 3.0
@export var ability_name: String = ""
@export var ability_description: String = ""


func _init() -> void:
	item_type = "module"
