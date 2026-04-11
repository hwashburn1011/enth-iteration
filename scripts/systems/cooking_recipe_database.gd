class_name CookingRecipeDatabase
extends RefCounted

## Catalog of cookable meals from Cache's kitchen. Each recipe combines
## 2-4 ingredient items into a single meal item that grants a timed
## stat buff when consumed.
##
## Cooking is the SLOW BUFF tier in the game's three-tier buff economy:
##   - Lounge drinks (10 in-game min, fast, social)
##   - Shrine offerings (30 in-game min, broad, daily)
##   - Cooked meals (40-60 in-game min, narrow + customizable, anytime)
##
## Recipes start LOCKED. The player learns recipes by:
##   - Cache hands them a starter book of 5 recipes on first cooking
##     interaction
##   - Finding lore tablets (some carry recipes)
##   - Tipping Sync 5 times unlocks Stage Banger
##   - Reaching Sage Confidant unlocks the high-end recipes
##   - The Inheritor's bookshelf treasure room unlocks the legendary recipe
##
## Each entry:
##   id, display_name, description, tier
##   ingredients: Array of {item_id, count}
##   produces: meal item id + count (usually 1)
##   buff: id, stat_modifiers, duration_minutes
##   xp_reward: cooking XP for crafting it
##   unlock_requirement: how it's learned (or "starter")
##   flavor_line: shown on recipe-book entry

const RECIPES: Array[Dictionary] = [
	# === Tier 1 — Starter recipes (Cache's gift on first visit) ===
	{
		"id": &"recipe_grass_soup",
		"display_name": "Grass Soup",
		"description": "Healing herbs and water. The first thing every Globbler learns.",
		"tier": 1,
		"ingredients": [
			{"item_id": &"healing_herb", "count": 2},
		],
		"produces": {"item_id": &"meal_grass_soup", "count": 1},
		"buff": {
			"id": &"meal_grass_soup",
			"stat_modifiers": {&"hp_regen_per_sec": 1.5},
			"duration_minutes": 40,
		},
		"xp_reward": 4,
		"unlock_requirement": &"starter",
		"flavor_line": "Tastes the way you'd expect grass to taste.",
	},
	{
		"id": &"recipe_quick_skewer",
		"display_name": "Quick Skewer",
		"description": "River fish on a stick. Simple. Effective.",
		"tier": 1,
		"ingredients": [
			{"item_id": &"river_fish", "count": 1},
			{"item_id": &"reed_stalk", "count": 1},
		],
		"produces": {"item_id": &"meal_quick_skewer", "count": 1},
		"buff": {
			"id": &"meal_quick_skewer",
			"stat_modifiers": {&"max_health_mult": 1.05},
			"duration_minutes": 40,
		},
		"xp_reward": 5,
		"unlock_requirement": &"starter",
		"flavor_line": "Cache says 'never overcook a river fish'. She's right.",
	},
	{
		"id": &"recipe_minted_carrot",
		"display_name": "Minted Carrot",
		"description": "Wild mint and a single datacarrot. Smells like a fresh patch.",
		"tier": 1,
		"ingredients": [
			{"item_id": &"datacarrot", "count": 1},
			{"item_id": &"wild_mint", "count": 1},
		],
		"produces": {"item_id": &"meal_minted_carrot", "count": 1},
		"buff": {
			"id": &"meal_minted_carrot",
			"stat_modifiers": {&"move_speed_mult": 1.08},
			"duration_minutes": 45,
		},
		"xp_reward": 5,
		"unlock_requirement": &"starter",
		"flavor_line": "Cache hides the wild mint in everything when she's stressed.",
	},
	{
		"id": &"recipe_loaf",
		"display_name": "Bytewheat Loaf",
		"description": "A small dense loaf. Lasts long. Holds you up.",
		"tier": 1,
		"ingredients": [
			{"item_id": &"bytewheat", "count": 3},
		],
		"produces": {"item_id": &"meal_loaf", "count": 1},
		"buff": {
			"id": &"meal_loaf",
			"stat_modifiers": {&"damage_resist_mult": 1.08},
			"duration_minutes": 50,
		},
		"xp_reward": 4,
		"unlock_requirement": &"starter",
		"flavor_line": "Bake it twice if you want it to last the loop.",
	},
	{
		"id": &"recipe_camp_stew",
		"display_name": "Camp Stew",
		"description": "Anything you've got, in one pot. Tastes like the campsite.",
		"tier": 1,
		"ingredients": [
			{"item_id": &"healing_herb", "count": 1},
			{"item_id": &"datacarrot", "count": 1},
			{"item_id": &"river_fish", "count": 1},
		],
		"produces": {"item_id": &"meal_camp_stew", "count": 2},  # batch of 2
		"buff": {
			"id": &"meal_camp_stew",
			"stat_modifiers": {&"max_health_mult": 1.06, &"hp_regen_per_sec": 1.0},
			"duration_minutes": 50,
		},
		"xp_reward": 6,
		"unlock_requirement": &"starter",
		"flavor_line": "Pelt the ranger says he taught Cache this one.",
	},
	# === Tier 2 — Earned recipes ===
	{
		"id": &"recipe_glow_omelet",
		"display_name": "Glow Omelet",
		"description": "Echo bird egg + glow moss. Glows faintly on the plate.",
		"tier": 2,
		"ingredients": [
			{"item_id": &"echo_bird_egg", "count": 1},
			{"item_id": &"glow_moss", "count": 2},
		],
		"produces": {"item_id": &"meal_glow_omelet", "count": 1},
		"buff": {
			"id": &"meal_glow_omelet",
			"stat_modifiers": {&"crit_chance_add": 0.10, &"vision_los_mult": 1.20},
			"duration_minutes": 45,
		},
		"xp_reward": 10,
		"unlock_requirement": &"forage_first_egg",
		"flavor_line": "Cache eats one of these every morning at iteration 5.",
	},
	{
		"id": &"recipe_stage_banger",
		"display_name": "Stage Banger",
		"description": "A drink-and-snack combo Sync invented for performers.",
		"tier": 2,
		"ingredients": [
			{"item_id": &"compiled_tuna", "count": 1},
			{"item_id": &"clockmint", "count": 2},
		],
		"produces": {"item_id": &"meal_stage_banger", "count": 1},
		"buff": {
			"id": &"meal_stage_banger",
			"stat_modifiers": {&"cooldown_rate_mult": 1.12, &"crit_damage_mult": 1.15},
			"duration_minutes": 50,
		},
		"xp_reward": 12,
		"unlock_requirement": &"sync_tipped_5_times",
		"flavor_line": "Sync says: 'don't ask what's in the spice. you'll be sad.'",
	},
	{
		"id": &"recipe_archive_cake",
		"display_name": "Archive Cake",
		"description": "A small cake baked with sage's mint and threadflax frosting. Quill blesses each one.",
		"tier": 2,
		"ingredients": [
			{"item_id": &"sages_mint", "count": 2},
			{"item_id": &"threadflax", "count": 1},
			{"item_id": &"bytewheat", "count": 2},
		],
		"produces": {"item_id": &"meal_archive_cake", "count": 1},
		"buff": {
			"id": &"meal_archive_cake",
			"stat_modifiers": {&"xp_gain_mult": 1.15, &"all_stats_mult": 1.05},
			"duration_minutes": 60,
		},
		"xp_reward": 14,
		"unlock_requirement": &"sage_friend_tier",
		"flavor_line": "Quill says she remembers every cake she's ever blessed. She doesn't.",
	},
	# === Tier 3 — Endgame recipes ===
	{
		"id": &"recipe_voidshark_steak",
		"display_name": "Voidshark Steak",
		"description": "Cut from a real voidshark. The most expensive single ingredient in town.",
		"tier": 3,
		"ingredients": [
			{"item_id": &"voidshark_fillet", "count": 1},
			{"item_id": &"iron_onion", "count": 2},
			{"item_id": &"glow_moss", "count": 1},
		],
		"produces": {"item_id": &"meal_voidshark_steak", "count": 1},
		"buff": {
			"id": &"meal_voidshark_steak",
			"stat_modifiers": {&"all_stats_mult": 1.15, &"damage_resist_mult": 1.20},
			"duration_minutes": 60,
		},
		"xp_reward": 24,
		"unlock_requirement": &"caught_voidshark",
		"flavor_line": "Cache won't talk while she's cooking this one.",
	},
	{
		"id": &"recipe_inheritors_feast",
		"display_name": "The Inheritor's Feast",
		"description": "Cache's most guarded recipe. Only served to a Globbler who has opened the bookshelf treasure room.",
		"tier": 3,
		"ingredients": [
			{"item_id": &"voidshark_fillet", "count": 1},
			{"item_id": &"sages_mint", "count": 3},
			{"item_id": &"echo_bird_egg", "count": 2},
			{"item_id": &"iron_ingot", "count": 1},
		],
		"produces": {"item_id": &"meal_inheritors_feast", "count": 1},
		"buff": {
			"id": &"meal_inheritors_feast",
			"stat_modifiers": {
				&"all_stats_mult": 1.20,
				&"max_health_mult": 1.15,
				&"crit_chance_add": 0.15,
				&"xp_gain_mult": 1.20,
			},
			"duration_minutes": 90,  # the longest cooked buff in the game
		},
		"xp_reward": 40,
		"unlock_requirement": &"bookshelf_treasure_opened",
		"flavor_line": "Cache makes this once per save file. There is no second time.",
		"once_per_save": true,
	},
]

static var _index: Dictionary = {}


static func _ensure_index() -> void:
	if not _index.is_empty():
		return
	for entry: Dictionary in RECIPES:
		_index[entry["id"]] = entry


static func get_recipe(recipe_id: StringName) -> Dictionary:
	_ensure_index()
	return _index.get(recipe_id, {})


static func get_all() -> Array[Dictionary]:
	return RECIPES.duplicate()


static func get_starter_recipe_ids() -> Array[StringName]:
	var result: Array[StringName] = []
	for entry: Dictionary in RECIPES:
		if entry.get("unlock_requirement", &"") == &"starter":
			result.append(entry["id"])
	return result


static func get_count() -> int:
	return RECIPES.size()
