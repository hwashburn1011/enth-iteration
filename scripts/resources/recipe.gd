class_name Recipe
extends Resource

## A crafting recipe — input materials → output item. Filtered by station type.

@export var recipe_id: StringName = &""
@export var display_name: String = ""
@export var description: String = ""

## Which station can craft this recipe (forge / lab / loom / compiler)
@export var station_type: StringName = &""

## Output: which item this produces, how many
@export var output_item_id: StringName = &""
@export var output_count: int = 1

## Inputs: { material_id (StringName) -> count (int) }
@export var ingredients: Dictionary = {}

## Recipe rarity tier (drives discovery and fail chance)
@export var rarity: int = 0  ## 0=common,1=uncommon,2=rare,3=legendary

## Discovery requirement: how does the player learn this recipe?
## Empty = available from start
## Format: { "type": "drop"|"npc"|"quest"|"explore", "source_id": StringName }
@export var unlock_requirement: Dictionary = {}

## Animation hint
@export var craft_anim: StringName = &"craft_default"

## Optional: time in seconds to craft (default 2.0)
@export var craft_time: float = 2.0


func get_fail_chance() -> float:
	match rarity:
		0, 1: return 0.0
		2: return 0.05
		3: return 0.15
	return 0.0


func get_refund_pct_on_fail() -> float:
	match rarity:
		2: return 0.5
		3: return 0.25
	return 0.0


func is_unlocked_by_default() -> bool:
	return unlock_requirement.is_empty()
