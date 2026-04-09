class_name MaterialItem
extends "res://scripts/items/item_base.gd"

## Crafting material — stackable, no equip slot, used as recipe ingredient.

@export var material_id: StringName = &""
@export var stack_size_max: int = 999
@export var source_tag: StringName = &""  ## "drop", "gather", "fish", "boss"


func _init() -> void:
	item_type = "material"
	grid_size = Vector2i(1, 1)
