class_name ForagingTableDatabase
extends RefCounted

## Per-region foraging tables. Where ResourceNodes are hand-placed
## tool-required harvest points (chop a log, mine a vein), foraging
## spots are quick hands-only searches at random patches that roll
## from a weighted item pool. Higher gathering skill unlocks rarer
## entries; high luck nudges the roll toward higher-tier items.
##
## Each entry on a region's table has:
##   - item_id          — what's granted
##   - weight           — relative roll weight at minimum unlock skill
##   - min_skill        — gathering level required to roll this entry
##   - tier             — 1 common .. 4 epic, drives sting + log color
##   - count_min/max    — quantity range
##   - rare_message     — flavor line shown on tier ≥ 3 finds

const TABLES: Dictionary = {
	&"wild_plateau": [
		{"item_id": &"healing_herb",     "weight": 60, "min_skill": 1, "tier": 1, "count_min": 1, "count_max": 2},
		{"item_id": &"clover_leaf",      "weight": 30, "min_skill": 1, "tier": 1, "count_min": 1, "count_max": 3},
		{"item_id": &"sunpetal",         "weight": 18, "min_skill": 2, "tier": 2, "count_min": 1, "count_max": 2},
		{"item_id": &"echo_bird_egg",    "weight":  5, "min_skill": 4, "tier": 3, "count_min": 1, "count_max": 1, "rare_message": "An echo bird's nest, abandoned."},
		{"item_id": &"data_seed",        "weight":  3, "min_skill": 5, "tier": 3, "count_min": 1, "count_max": 1, "rare_message": "A seed humming with unread data."},
	],
	&"wild_pasture": [
		{"item_id": &"wild_mint",        "weight": 50, "min_skill": 1, "tier": 1, "count_min": 1, "count_max": 3},
		{"item_id": &"healing_herb",     "weight": 35, "min_skill": 1, "tier": 1, "count_min": 1, "count_max": 2},
		{"item_id": &"butter_blossom",   "weight": 22, "min_skill": 2, "tier": 2, "count_min": 1, "count_max": 2},
		{"item_id": &"sages_mint",       "weight":  6, "min_skill": 4, "tier": 3, "count_min": 1, "count_max": 1, "rare_message": "Sage's mint — rare in the wild."},
		{"item_id": &"deer_horn_shed",   "weight":  3, "min_skill": 5, "tier": 4, "count_min": 1, "count_max": 1, "rare_message": "A shed sim-deer antler, still warm."},
	],
	&"wild_river": [
		{"item_id": &"reed_stalk",       "weight": 45, "min_skill": 1, "tier": 1, "count_min": 1, "count_max": 3},
		{"item_id": &"water_lily",       "weight": 30, "min_skill": 1, "tier": 1, "count_min": 1, "count_max": 2},
		{"item_id": &"clay_lump",        "weight": 24, "min_skill": 2, "tier": 2, "count_min": 1, "count_max": 2},
		{"item_id": &"river_pearl",      "weight":  8, "min_skill": 3, "tier": 3, "count_min": 1, "count_max": 1, "rare_message": "A pearl in the silt — pre-loop."},
		{"item_id": &"lost_data_chip",   "weight":  3, "min_skill": 5, "tier": 4, "count_min": 1, "count_max": 1, "rare_message": "A waterlogged data chip, still readable."},
	],
	&"wild_forest": [
		{"item_id": &"forest_mushroom",  "weight": 50, "min_skill": 1, "tier": 1, "count_min": 1, "count_max": 3},
		{"item_id": &"bark_strip",       "weight": 30, "min_skill": 1, "tier": 1, "count_min": 1, "count_max": 2},
		{"item_id": &"glow_moss",        "weight": 22, "min_skill": 2, "tier": 2, "count_min": 1, "count_max": 2, "phase_restriction": [&"night", &"dusk", &"dawn"]},
		{"item_id": &"firefly_dust",     "weight": 12, "min_skill": 3, "tier": 3, "count_min": 1, "count_max": 1, "phase_restriction": [&"night"], "rare_message": "Powder of firefly wings — only at night."},
		{"item_id": &"fox_token",        "weight":  3, "min_skill": 5, "tier": 4, "count_min": 1, "count_max": 1, "rare_message": "A small carved fox the forest left for you."},
	],
	&"wild_ruins": [
		{"item_id": &"stone_chip",       "weight": 50, "min_skill": 1, "tier": 1, "count_min": 1, "count_max": 4},
		{"item_id": &"glyph_dust",       "weight": 28, "min_skill": 2, "tier": 2, "count_min": 1, "count_max": 2},
		{"item_id": &"glyph_shard",      "weight": 14, "min_skill": 3, "tier": 3, "count_min": 1, "count_max": 1, "rare_message": "A glyph fragment, half-decoded."},
		{"item_id": &"corrupted_coin",   "weight":  6, "min_skill": 4, "tier": 3, "count_min": 1, "count_max": 1, "rare_message": "A corrupted coin from a lost iteration."},
		{"item_id": &"prime_glyph",      "weight":  2, "min_skill": 6, "tier": 4, "count_min": 1, "count_max": 1, "rare_message": "A prime glyph. The spire writes them."},
	],
	&"wild_cliffs": [
		{"item_id": &"echo_feather",     "weight": 45, "min_skill": 1, "tier": 1, "count_min": 1, "count_max": 2},
		{"item_id": &"wind_smooth_stone","weight": 30, "min_skill": 1, "tier": 1, "count_min": 1, "count_max": 2},
		{"item_id": &"swallow_egg",      "weight": 16, "min_skill": 3, "tier": 2, "count_min": 1, "count_max": 1},
		{"item_id": &"sky_crystal",      "weight":  6, "min_skill": 4, "tier": 3, "count_min": 1, "count_max": 1, "rare_message": "A wind-carved crystal from a high ledge."},
		{"item_id": &"void_speck",       "weight":  3, "min_skill": 5, "tier": 4, "count_min": 1, "count_max": 1, "rare_message": "A speck of void where a portal once was."},
	],
}

# Luck contribution: each point of luck shifts the weighted roll toward
# higher-tier items by reducing low-tier weight by this fraction per point.
const LUCK_TIER_BIAS: float = 0.04


static func get_table(region_id: StringName) -> Array:
	return TABLES.get(region_id, [])


static func get_eligible_for_skill(region_id: StringName, gathering_level: int, phase: StringName) -> Array:
	## Returns the entries the player can roll given their skill level
	## and the current phase, filtering out phase-restricted items in
	## wrong phases.
	var raw: Array = TABLES.get(region_id, [])
	var result: Array = []
	for entry in raw:
		if int(entry.get("min_skill", 1)) > gathering_level:
			continue
		var phase_lock: Array = entry.get("phase_restriction", [])
		if not phase_lock.is_empty() and not phase_lock.has(phase):
			continue
		result.append(entry)
	return result


static func roll(region_id: StringName, gathering_level: int, luck: int, phase: StringName) -> Dictionary:
	## Picks one entry from the eligible pool with luck-biased weights.
	## Higher luck demotes tier-1 weight and promotes tier-3+ weight.
	var pool: Array = get_eligible_for_skill(region_id, gathering_level, phase)
	if pool.is_empty():
		return {}
	var total: float = 0.0
	var weights: Array = []
	for entry in pool:
		var w: float = float(entry.get("weight", 1))
		var tier: int = int(entry.get("tier", 1))
		# Demote common, promote rare based on luck
		if tier == 1:
			w *= max(0.1, 1.0 - LUCK_TIER_BIAS * luck)
		elif tier >= 3:
			w *= 1.0 + LUCK_TIER_BIAS * luck * float(tier - 1)
		weights.append(w)
		total += w
	var roll_val: float = randf() * total
	var acc: float = 0.0
	for i in pool.size():
		acc += weights[i]
		if roll_val <= acc:
			return pool[i]
	return pool[-1]


static func get_region_count() -> int:
	return TABLES.size()
