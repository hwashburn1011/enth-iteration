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
	# Iteration 5 stock — tier 2 upgrades unlock here
	{"item_id": "module_fork_bomb_2", "name": "Fork Bomb II", "price": 180, "rarity": 3, "min_iter": 5},
	{"item_id": "module_logic_bomb_2", "name": "Logic Bomb II", "price": 180, "rarity": 3, "min_iter": 5},
	{"item_id": "module_packet_storm_2", "name": "Packet Storm II", "price": 200, "rarity": 3, "min_iter": 5},
	{"item_id": "chip_bandwidth_booster_2", "name": "Bandwidth Booster II", "price": 150, "rarity": 3, "min_iter": 5},
	{"item_id": "chip_armor_plating_2", "name": "Armor Plating II", "price": 150, "rarity": 3, "min_iter": 5},
	{"item_id": "chip_assault_processor_2", "name": "Assault Processor II", "price": 150, "rarity": 3, "min_iter": 5},
	{"item_id": "chip_overclock", "name": "Overclock", "price": 150, "rarity": 2, "min_iter": 5},
	{"item_id": "core_entropy_engine", "name": "Entropy Engine", "price": 250, "rarity": 3, "min_iter": 5},
	{"item_id": "module_stack_overflow", "name": "Stack Overflow", "price": 180, "rarity": 2, "min_iter": 5},
	# Iteration 6 stock — remaining tier 2 upgrades
	{"item_id": "module_defrag_pulse_2", "name": "Defrag Pulse II", "price": 200, "rarity": 3, "min_iter": 6},
	{"item_id": "module_deadlock_2", "name": "Deadlock II", "price": 220, "rarity": 3, "min_iter": 6},
	{"item_id": "chip_kinetic_dash_2", "name": "Kinetic Dash II", "price": 180, "rarity": 3, "min_iter": 6},
	{"item_id": "chip_counterstrike_2", "name": "Counterstrike II", "price": 200, "rarity": 3, "min_iter": 6},
	{"item_id": "core_quantum_processor_2", "name": "Quantum Processor II", "price": 300, "rarity": 3, "min_iter": 6},
	{"item_id": "core_volatile_compiler_2", "name": "Volatile Compiler II", "price": 320, "rarity": 3, "min_iter": 6},
	{"item_id": "core_persistent_thread_2", "name": "Persistent Thread II", "price": 350, "rarity": 3, "min_iter": 6},
	{"item_id": "chip_void_shield", "name": "Void Shield", "price": 200, "rarity": 3, "min_iter": 6},
	{"item_id": "core_decompressor", "name": "Decompressor", "price": 320, "rarity": 3, "min_iter": 6},
	{"item_id": "module_null_wave", "name": "Null Wave", "price": 220, "rarity": 3, "min_iter": 6},
	# Iteration 7 stock
	{"item_id": "chip_mosaic_lens", "name": "Mosaic Lens", "price": 260, "rarity": 3, "min_iter": 7},
	{"item_id": "core_fragment_weaver", "name": "Fragment Weaver", "price": 400, "rarity": 4, "min_iter": 7},
	{"item_id": "module_glitch_storm", "name": "Glitch Storm", "price": 280, "rarity": 3, "min_iter": 7},
	# Iteration 8 stock
	{"item_id": "chip_mirror_protocol", "name": "Mirror Protocol", "price": 340, "rarity": 4, "min_iter": 8},
	{"item_id": "core_recursion_engine", "name": "Recursion Engine", "price": 500, "rarity": 4, "min_iter": 8},
	{"item_id": "module_infinite_loop", "name": "Infinite Loop", "price": 360, "rarity": 4, "min_iter": 8},
	# Iteration 9 stock — endgame
	{"item_id": "chip_origin_spark", "name": "Origin Spark", "price": 450, "rarity": 4, "min_iter": 9},
	{"item_id": "core_enth_key", "name": "Enth Key", "price": 666, "rarity": 5, "min_iter": 9},
	{"item_id": "module_decompression", "name": "Decompression", "price": 500, "rarity": 5, "min_iter": 9},
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
