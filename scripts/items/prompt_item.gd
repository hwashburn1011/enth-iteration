class_name PromptItem
extends "res://scripts/items/item_base.gd"
## Consumable item — heals, restores compute, or applies a buff.

@export var prompt_type: String = "health"  # "health", "compute", "buff"
@export var restore_amount: float = 25.0
@export var buff_duration: float = 10.0
@export var max_stack: int = 20
@export var is_consumable: bool = true


func _init() -> void:
	item_type = "prompt"
