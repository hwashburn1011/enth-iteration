class_name CropDatabase
extends RefCounted

## Static catalog of all 20 crop types. Each crop has growth time, stat
## bonuses on consume, material drops, rarity tier, and seed cost.

const CROPS: Array = [
	# Common
	{"id": &"bytewheat",       "name": "Bytewheat",       "rarity": 0, "days": 2, "seed_cost": 5,
	 "drops": {&"bit_fragment": 1}, "buff": {}, "desc": "Basic grain. Used in flour and many recipes."},
	{"id": &"datacarrot",      "name": "Datacarrot",      "rarity": 0, "days": 2, "seed_cost": 5,
	 "drops": {}, "buff": {"max_hp": 5}, "desc": "Crunchy. Grants +5 max HP for 60s."},
	{"id": &"cachepea",        "name": "Cachepea",        "rarity": 0, "days": 2, "seed_cost": 5,
	 "drops": {}, "buff": {"max_compute": 5}, "desc": "Small but efficient. +5 max compute for 60s."},
	{"id": &"pingberry",       "name": "Pingberry",       "rarity": 0, "days": 3, "seed_cost": 5,
	 "drops": {}, "buff": {"move_speed_pct": 0.05}, "desc": "Quick energy. +5% move speed for 30s."},
	{"id": &"patchcotton",     "name": "Patchcotton",     "rarity": 0, "days": 3, "seed_cost": 5,
	 "drops": {&"patch": 2}, "buff": {}, "desc": "Soft fiber. Drops 2 Patch material on harvest."},
	{"id": &"logleaf",         "name": "Logleaf",         "rarity": 0, "days": 2, "seed_cost": 5,
	 "drops": {&"bytewood": 1}, "buff": {}, "desc": "Living wood. Drops 1 Bytewood per harvest."},
	{"id": &"clockmint",       "name": "Clockmint",       "rarity": 0, "days": 3, "seed_cost": 5,
	 "drops": {}, "buff": {"cooldown_reduction_pct": 0.10}, "desc": "Refreshing. -10% cooldowns for 30s."},
	{"id": &"sleeppoppy",      "name": "Sleeppoppy",      "rarity": 0, "days": 3, "seed_cost": 5,
	 "drops": {}, "buff": {"compute_regen": 2.0}, "desc": "Calming. +2 compute/sec regen for 60s."},

	# Uncommon
	{"id": &"refactorradish",  "name": "Refactorradish",  "rarity": 1, "days": 4, "seed_cost": 25,
	 "drops": {}, "buff": {"damage_pct": 0.10}, "desc": "Sharp. +10% damage for 60s."},
	{"id": &"threadflax",      "name": "Threadflax",      "rarity": 1, "days": 4, "seed_cost": 25,
	 "drops": {&"dyed_thread": 1}, "buff": {}, "desc": "Drops Dyed Thread material."},
	{"id": &"glowmoss",        "name": "Glowmoss",        "rarity": 1, "days": 4, "seed_cost": 25,
	 "drops": {&"memory_glass": 1}, "buff": {}, "desc": "Drops Memory Glass material."},
	{"id": &"stardust_sprout", "name": "Stardust Sprout", "rarity": 1, "days": 5, "seed_cost": 25,
	 "drops": {&"bit_fragment": 3}, "buff": {}, "desc": "Unique cooking ingredient. Drops 3 Bit Fragment."},
	{"id": &"iron_onion",      "name": "Iron Onion",      "rarity": 1, "days": 4, "seed_cost": 25,
	 "drops": {}, "buff": {"defense_pct": 0.20}, "desc": "Hardy. +20% defense for 60s."},
	{"id": &"pixel_pumpkin",   "name": "Pixel Pumpkin",   "rarity": 1, "days": 5, "seed_cost": 25,
	 "drops": {&"bytewood": 2}, "buff": {}, "desc": "Seasonal decoration item + Bytewood."},

	# Rare (greenhouse only)
	{"id": &"sages_mint",      "name": "Sage's Mint",     "rarity": 2, "days": 6, "seed_cost": 100,
	 "drops": {}, "buff": {"npc_affinity_boost": 1}, "desc": "Greenhouse only. Boosts NPC affinity gain temporarily."},
	{"id": &"quantum_bean",    "name": "Quantum Bean",    "rarity": 2, "days": 6, "seed_cost": 100,
	 "drops": {}, "buff": {"heal_now": 100}, "desc": "Instantly restores 100 HP."},
	{"id": &"iteration_lily",  "name": "Iteration Lily",  "rarity": 2, "days": 7, "seed_cost": 100,
	 "drops": {}, "buff": {"reveal_iteration_secret": 1}, "desc": "Reveals iteration secrets when consumed."},
	{"id": &"voidpepper",      "name": "Voidpepper",      "rarity": 2, "days": 6, "seed_cost": 100,
	 "drops": {&"voidsteel": 1}, "buff": {}, "desc": "Chance for Voidsteel material on harvest."},

	# Legendary
	{"id": &"heart_fruit",     "name": "Heart Fruit",     "rarity": 3, "days": 10, "seed_cost": 0,
	 "drops": {&"sages_tear": 1}, "buff": {}, "desc": "Story-locked. Chance for Sage's Tear material."},
	{"id": &"compaction_rose", "name": "Compaction Rose", "rarity": 3, "days": 10, "seed_cost": 0,
	 "drops": {&"compaction_heart": 1}, "buff": {}, "desc": "Story-locked. Drops Compaction Heart fragments."},
]

static var _index: Dictionary = {}


static func get_all() -> Array:
	return CROPS


static func get_crop(id: StringName) -> Dictionary:
	if _index.is_empty():
		_build_index()
	return _index.get(id, {})


static func _build_index() -> void:
	for c in CROPS:
		_index[c["id"]] = c


static func get_by_rarity(r: int) -> Array:
	var result: Array = []
	for c in CROPS:
		if c["rarity"] == r:
			result.append(c)
	return result


static func count() -> int:
	return CROPS.size()
