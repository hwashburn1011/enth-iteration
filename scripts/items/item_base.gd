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
