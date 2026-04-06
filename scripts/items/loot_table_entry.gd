class_name LootTableEntry
extends Resource
## A single entry in a loot table — item base, drop chance, and quantity range.

@export var item_base: Resource
@export var drop_chance: float = 0.5  # 0.0 to 1.0
@export var min_quantity: int = 1
@export var max_quantity: int = 1
