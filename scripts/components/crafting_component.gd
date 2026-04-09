class_name CraftingComponent
extends Node

## Player-attached crafting state. Owns: known recipes, station tier per
## station type, craft history (for achievements). Performs ingredient
## validation and material consumption against the player's inventory.

signal recipe_unlocked(recipe_id: StringName)
signal craft_started(recipe_id: StringName)
signal craft_completed(recipe_id: StringName, success: bool, output_count: int)
signal craft_failed(recipe_id: StringName)

@export var inventory_path: NodePath

var known_recipes: Array[StringName] = []
var station_tiers: Dictionary = {        ## station_type -> tier (1-3)
	&"forge": 1,
	&"lab": 1,
	&"loom": 1,
	&"compiler": 1,
}
var craft_history: Dictionary = {}        ## recipe_id -> count
var consecutive_failures: Dictionary = {} ## recipe_id -> failures since last success

var _inventory: Node


func _ready() -> void:
	_inventory = get_node_or_null(inventory_path)
	# Auto-unlock starter recipes (those with empty unlock requirements)
	for r in RecipeDatabase.get_all_recipes():
		var unlock: Dictionary = r.get("unlock", {})
		if unlock.is_empty():
			known_recipes.append(r["id"])


# === RECIPE KNOWLEDGE ===

func unlock_recipe(recipe_id: StringName) -> bool:
	if known_recipes.has(recipe_id):
		return false
	known_recipes.append(recipe_id)
	recipe_unlocked.emit(recipe_id)
	return true


func is_recipe_known(recipe_id: StringName) -> bool:
	return known_recipes.has(recipe_id)


func get_known_recipes_for_station(station_type: StringName) -> Array:
	return RecipeDatabase.get_recipes_for_player(known_recipes, station_type)


# === CRAFTING ===

func has_ingredients(recipe_id: StringName) -> bool:
	if _inventory == null:
		return false
	var recipe: Dictionary = RecipeDatabase.get_recipe(recipe_id)
	if recipe.is_empty():
		return false
	var ing: Dictionary = recipe.get("ing", {})
	for material_id: StringName in ing.keys():
		var needed: int = ing[material_id]
		if not _inventory.has_method("count_item_by_id"):
			return false
		if _inventory.count_item_by_id(String(material_id)) < needed:
			return false
	return true


func can_craft(recipe_id: StringName, station_type: StringName) -> bool:
	if not is_recipe_known(recipe_id):
		return false
	var recipe: Dictionary = RecipeDatabase.get_recipe(recipe_id)
	if recipe.is_empty():
		return false
	if recipe["station"] != station_type:
		return false
	return has_ingredients(recipe_id)


func craft(recipe_id: StringName, station_type: StringName) -> Dictionary:
	## Returns { success: bool, output_count: int, refunded: bool }
	if not can_craft(recipe_id, station_type):
		return {"success": false, "output_count": 0, "refunded": false, "reason": "cannot_craft"}

	var recipe: Dictionary = RecipeDatabase.get_recipe(recipe_id)
	craft_started.emit(recipe_id)

	# Consume ingredients up front
	var ing: Dictionary = recipe.get("ing", {})
	for material_id: StringName in ing.keys():
		_inventory.remove_item_by_id(String(material_id), ing[material_id])

	# Roll for failure
	var rarity: int = recipe.get("rarity", 0)
	var fail_chance: float = _get_fail_chance(rarity)
	# Reduce failure chance via "focused crafting" stack
	var fc_bonus: float = float(consecutive_failures.get(recipe_id, 0)) * 0.10
	fail_chance = maxf(0.0, fail_chance - fc_bonus)

	var roll: float = randf()
	if roll < fail_chance:
		# Refund partial materials
		var refund_pct: float = _get_refund_pct(rarity)
		for material_id: StringName in ing.keys():
			var refund_n: int = int(ceil(ing[material_id] * refund_pct))
			if refund_n > 0:
				_inventory.add_item_by_id(String(material_id), refund_n)
		consecutive_failures[recipe_id] = consecutive_failures.get(recipe_id, 0) + 1
		craft_failed.emit(recipe_id)
		craft_completed.emit(recipe_id, false, 0)
		return {"success": false, "output_count": 0, "refunded": true, "reason": "rng_fail"}

	# Success! Apply station tier crit chance
	var tier: int = station_tiers.get(station_type, 1)
	var output_count: int = recipe.get("out_n", 1)
	if tier >= 3 and randf() < 0.10:
		output_count += 1  # bonus output

	_inventory.add_item_by_id(String(recipe["out"]), output_count)
	craft_history[recipe_id] = craft_history.get(recipe_id, 0) + 1
	consecutive_failures.erase(recipe_id)
	craft_completed.emit(recipe_id, true, output_count)
	return {"success": true, "output_count": output_count, "refunded": false, "reason": "ok"}


func _get_fail_chance(rarity: int) -> float:
	match rarity:
		2: return 0.05
		3: return 0.15
	return 0.0


func _get_refund_pct(rarity: int) -> float:
	match rarity:
		2: return 0.5
		3: return 0.25
	return 0.0


# === STATION UPGRADES ===

func upgrade_station(station_type: StringName) -> bool:
	var current: int = station_tiers.get(station_type, 1)
	if current >= 3:
		return false
	station_tiers[station_type] = current + 1
	return true


# === SAVE / LOAD ===

func to_save_data() -> Dictionary:
	return {
		"known_recipes": known_recipes.map(func(s: StringName) -> String: return String(s)),
		"station_tiers": station_tiers.duplicate(),
		"craft_history": craft_history.duplicate(),
	}


func from_save_data(data: Dictionary) -> void:
	known_recipes.clear()
	for s in data.get("known_recipes", []):
		known_recipes.append(StringName(s))
	station_tiers = data.get("station_tiers", {&"forge": 1, &"lab": 1, &"loom": 1, &"compiler": 1})
	craft_history = data.get("craft_history", {})
