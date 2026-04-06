class_name AffixDefinition
extends Resource
## Definition of a single affix that can roll on items.

@export var affix_name: String = ""
@export var stat_name: String = ""
@export var min_value: float = 0.0
@export var max_value: float = 0.0
@export var min_rarity: int = 0  # minimum rarity that can roll this affix
@export var allowed_item_types: Array[String] = []
