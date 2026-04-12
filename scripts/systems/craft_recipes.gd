class_name CraftRecipes
extends RefCounted
## Post-V1 Epic A #8 — crafting recipe table.
##
## One functional recipe for V1: combine 3 common items into 1 rare.
## The full crafting UI uses the existing CraftingStation scene; this
## provides the recipe data and execution logic.

const RECIPES: Array[Dictionary] = [
	{
		"id": "common_to_rare",
		"name": "Forge Upgrade",
		"description": "Combine 3 common items into 1 random rare item (costs 20g)",
		"input_rarity": 0,
		"input_count": 3,
		"output_rarity": 2,
		"gold_cost": 20,
	},
]


## Attempt to craft a recipe. Returns true on success.
static func craft(recipe_id: String, player: Node) -> bool:
	var recipe: Dictionary = {}
	for r: Dictionary in RECIPES:
		if r["id"] == recipe_id:
			recipe = r
			break
	if recipe.is_empty():
		return false
	var gold_cost: int = int(recipe.get("gold_cost", 0))
	if GameManager.player_gold < gold_cost:
		return false
	var inv: Node = player.get_node_or_null("InventoryComponent") as Node
	if inv == null:
		return false
	var input_rarity: int = int(recipe.get("input_rarity", 0))
	var input_count: int = int(recipe.get("input_count", 3))
	var candidates: Array = []
	for y: int in inv.grid_height:
		for x: int in inv.grid_width:
			var item: Resource = inv.grid[y][x] as Resource
			if item != null and item not in candidates:
				var r: int = int(item.get(&"rarity")) if &"rarity" in item else 0
				if r == input_rarity:
					candidates.append(item)
	if candidates.size() < input_count:
		return false
	for i: int in input_count:
		inv.remove_item(candidates[i])
	GameManager.player_gold -= gold_cost
	var gen_script: Script = load("res://scripts/items/item_generator.gd") as Script
	if gen_script and gen_script.has_method(&"generate_item"):
		var output: Resource = gen_script.generate_item(int(recipe.get("output_rarity", 2)))
		if output != null:
			inv.add_item(output)
			return true
	return false
