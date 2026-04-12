class_name VendorStock
extends RefCounted
## Post-V1 Epic A #2 — vendor rotating stock per iteration.
##
## Returns a curated item pool for the shop based on the current iteration.
## Stock refreshes every time the player enters town. Higher iterations
## unlock better items and increase prices.

## Base stock available at all iterations — essentials.
const BASE_STOCK: Array[Dictionary] = [
	{"item_id": "health_prompt", "name": "Health Prompt", "price": 15, "rarity": 0},
	{"item_id": "compute_prompt", "name": "Compute Prompt", "price": 15, "rarity": 0},
]

## Iteration-gated stock tiers. Each entry unlocks at the specified iteration.
const TIER_STOCK: Array[Dictionary] = [
	# Iteration 1 stock
	{"item_id": "chip_bandwidth_booster", "name": "Bandwidth Booster", "price": 40, "rarity": 1, "min_iter": 1},
	{"item_id": "chip_armor_plating", "name": "Armor Plating", "price": 40, "rarity": 1, "min_iter": 1},
	{"item_id": "module_logic_bomb", "name": "Logic Bomb", "price": 60, "rarity": 1, "min_iter": 1},
	# Iteration 2 stock
	{"item_id": "chip_assault_processor", "name": "Assault Processor", "price": 65, "rarity": 1, "min_iter": 2},
	{"item_id": "core_quantum_processor", "name": "Quantum Processor", "price": 100, "rarity": 2, "min_iter": 2},
	{"item_id": "module_garbage_collect", "name": "Garbage Collect", "price": 80, "rarity": 1, "min_iter": 2},
	# Iteration 3 stock
	{"item_id": "chip_kinetic_dash", "name": "Kinetic Dash", "price": 90, "rarity": 2, "min_iter": 3},
	{"item_id": "chip_counterstrike", "name": "Counterstrike", "price": 90, "rarity": 2, "min_iter": 3},
	{"item_id": "core_volatile_compiler", "name": "Volatile Compiler", "price": 150, "rarity": 2, "min_iter": 3},
	{"item_id": "module_recursion", "name": "Recursion", "price": 100, "rarity": 2, "min_iter": 3},
	# Iteration 4 stock
	{"item_id": "chip_threat_analyzer", "name": "Threat Analyzer", "price": 120, "rarity": 2, "min_iter": 4},
	{"item_id": "core_persistent_thread", "name": "Persistent Thread", "price": 200, "rarity": 3, "min_iter": 4},
	{"item_id": "module_deadlock", "name": "Deadlock", "price": 140, "rarity": 2, "min_iter": 4},
	{"item_id": "module_refactor", "name": "Refactor", "price": 160, "rarity": 3, "min_iter": 4},
]


## Returns the full vendor stock array for the current iteration.
## Each entry: {item_id, name, price, rarity}
static func get_stock_for_iteration(iteration: int) -> Array[Dictionary]:
	var stock: Array[Dictionary] = []
	# Always include base stock
	for entry: Dictionary in BASE_STOCK:
		stock.append(entry.duplicate())
	# Add tier stock that's unlocked at this iteration
	for entry: Dictionary in TIER_STOCK:
		var min_iter: int = int(entry.get("min_iter", 1))
		if iteration >= min_iter:
			var cleaned: Dictionary = entry.duplicate()
			cleaned.erase("min_iter")
			stock.append(cleaned)
	# Post-V1 A10: scale prices by iteration — 10% per iteration past 1
	if iteration > 1:
		var price_mult: float = 1.0 + (iteration - 1) * 0.1
		for entry: Dictionary in stock:
			entry["price"] = int(ceil(float(entry["price"]) * price_mult))
	return stock
