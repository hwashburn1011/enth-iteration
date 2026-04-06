class_name ItemBase
extends Resource
## Base class for all items. Subclassed by Chip, Module, Core, Protocol, Prompt.

@export var item_name: String = ""
@export var item_id: String = ""
@export var description: String = ""
@export var icon: Texture2D
@export var rarity: int = 0  # 0=Common, 1=Uncommon, 2=Rare, 3=Legendary
@export var item_type: String = ""  # "chip", "module", "core", "protocol", "prompt"
@export var grid_size: Vector2i = Vector2i(1, 1)
@export var stat_modifiers: Dictionary = {}
@export var max_durability: float = 100.0
var current_durability: float = 100.0


func get_effective_stat_modifiers() -> Dictionary:
	var durability_pct: float = current_durability / max_durability if max_durability > 0.0 else 0.0
	var scale: float = 1.0
	if durability_pct <= 0.0:
		scale = 0.0
	elif durability_pct < 0.25:
		scale = 0.5
	elif durability_pct < 0.50:
		scale = 0.75
	var effective: Dictionary = {}
	for stat_name: String in stat_modifiers:
		effective[stat_name] = float(stat_modifiers[stat_name]) * scale
	return effective


func degrade(amount_pct: float) -> void:
	current_durability = maxf(0.0, current_durability - max_durability * amount_pct)


func repair() -> void:
	current_durability = max_durability
