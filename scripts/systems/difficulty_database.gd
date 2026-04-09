class_name DifficultyDatabase
extends RefCounted

## Static catalog of difficulty tiers and 30 modifier definitions.

const DIFFICULTIES: Array = [
	{
		"id": &"easy",
		"name": "Easy",
		"description": "Forgiving — story-focused.",
		"enemy_hp_mult": 0.7,
		"enemy_dmg_mult": 0.6,
		"loot_quality_mult": 1.2,
		"economy_mult": 1.5,
	},
	{
		"id": &"normal",
		"name": "Normal",
		"description": "The designed experience.",
		"enemy_hp_mult": 1.0,
		"enemy_dmg_mult": 1.0,
		"loot_quality_mult": 1.0,
		"economy_mult": 1.0,
	},
	{
		"id": &"hard",
		"name": "Hard",
		"description": "Mastery start.",
		"enemy_hp_mult": 1.4,
		"enemy_dmg_mult": 1.3,
		"loot_quality_mult": 1.1,
		"economy_mult": 0.9,
	},
	{
		"id": &"expert",
		"name": "Expert",
		"description": "Tight resource management.",
		"enemy_hp_mult": 1.8,
		"enemy_dmg_mult": 1.6,
		"loot_quality_mult": 1.25,
		"economy_mult": 0.8,
	},
	{
		"id": &"nightmare",
		"name": "Nightmare",
		"description": "Death Wish equivalent.",
		"enemy_hp_mult": 2.5,
		"enemy_dmg_mult": 2.0,
		"loot_quality_mult": 1.5,
		"economy_mult": 0.7,
	},
]

const MODIFIERS: Array = [
	# === NEGATIVE (player handicap) ===
	{"id": &"no_prompts",        "name": "No Prompts",        "type": &"negative", "reward_bonus": 0.25, "desc": "Cannot use prompt items."},
	{"id": &"glass_cannon",      "name": "Glass Cannon",      "type": &"negative", "reward_bonus": 0.30, "desc": "All damage doubled (player + enemies)."},
	{"id": &"one_shot",          "name": "One Shot",          "type": &"negative", "reward_bonus": 2.00, "desc": "1 HP. Don't get hit."},
	{"id": &"no_dash",           "name": "No Dash",           "type": &"negative", "reward_bonus": 0.30, "desc": "Dash disabled."},
	{"id": &"no_modules",        "name": "No Modules",        "type": &"negative", "reward_bonus": 0.50, "desc": "Only basic attacks allowed."},
	{"id": &"no_compute",        "name": "No Compute",        "type": &"negative", "reward_bonus": 0.25, "desc": "Compute regen disabled, max compute 50%."},
	{"id": &"no_healing",        "name": "No Healing",        "type": &"negative", "reward_bonus": 0.35, "desc": "Healing items have no effect."},
	{"id": &"no_pickups",        "name": "No Pickups",        "type": &"negative", "reward_bonus": 0.50, "desc": "Items don't drop."},
	{"id": &"time_limit",        "name": "Time Limit",        "type": &"negative", "reward_bonus": 0.20, "desc": "5 minute floor timer."},
	{"id": &"no_companions",     "name": "No Companions",     "type": &"negative", "reward_bonus": 0.20, "desc": "Companion slot disabled."},
	{"id": &"no_pets",           "name": "No Pets",           "type": &"negative", "reward_bonus": 0.10, "desc": "Pet slot disabled."},
	{"id": &"half_stats",        "name": "Half Stats",        "type": &"negative", "reward_bonus": 0.30, "desc": "Player stats reduced 50%."},
	{"id": &"no_cd_reduction",   "name": "Sluggish",          "type": &"negative", "reward_bonus": 0.25, "desc": "All cooldowns ×2."},
	{"id": &"friendly_fire",     "name": "Friendly Fire",     "type": &"negative", "reward_bonus": 0.15, "desc": "Companion abilities damage you."},
	{"id": &"visible_shadows",   "name": "Hidden Threats",    "type": &"negative", "reward_bonus": 0.20, "desc": "Enemies visible only in line of sight."},
	{"id": &"slow_movement",     "name": "Slow Movement",     "type": &"negative", "reward_bonus": 0.15, "desc": "Move speed -30%."},
	{"id": &"frail_equipment",   "name": "Frail Equipment",   "type": &"negative", "reward_bonus": 0.15, "desc": "Equipment durability ×3 loss rate."},
	{"id": &"no_status_resist",  "name": "No Status Resist",  "type": &"negative", "reward_bonus": 0.10, "desc": "All status durations ×2."},
	{"id": &"locked_doors",      "name": "Locked Doors",      "type": &"negative", "reward_bonus": 0.10, "desc": "Doors require lockpicking."},
	{"id": &"reflect_damage",    "name": "Mirror Boss",       "type": &"negative", "reward_bonus": 0.20, "desc": "Boss reflects 25% of damage."},

	# === POSITIVE (accessibility) ===
	{"id": &"rookie_mode",       "name": "Rookie Mode",       "type": &"positive", "reward_bonus": 0.0,  "desc": "Enemies have 50% HP."},
	{"id": &"defensive_aura",    "name": "Defensive Aura",    "type": &"positive", "reward_bonus": 0.0,  "desc": "Take 25% less damage."},
	{"id": &"generous_loot",     "name": "Generous Loot",     "type": &"positive", "reward_bonus": 0.0,  "desc": "All drops doubled."},
	{"id": &"quick_recharge",    "name": "Quick Recharge",    "type": &"positive", "reward_bonus": 0.0,  "desc": "Cooldowns ×0.7."},
	{"id": &"resurrection",      "name": "Resurrection",      "type": &"positive", "reward_bonus": 0.0,  "desc": "Revive once on death."},

	# === MIXED (random / chaos) ===
	{"id": &"random_modifiers",  "name": "Random Modifiers",  "type": &"mixed",    "reward_bonus": 0.30, "desc": "A new random modifier each floor."},
	{"id": &"mystery_loot",      "name": "Mystery Loot",      "type": &"mixed",    "reward_bonus": 0.15, "desc": "All drops are random tier."},
	{"id": &"lottery_stats",     "name": "Lottery Stats",     "type": &"mixed",    "reward_bonus": 0.25, "desc": "Stats randomized at floor start."},
	{"id": &"modifier_roulette", "name": "Modifier Roulette", "type": &"mixed",    "reward_bonus": 0.50, "desc": "Modifier swaps every 30 seconds."},
	{"id": &"compilers_dare",    "name": "The Compiler's Dare","type": &"mixed",   "reward_bonus": 0.40, "desc": "Random buff and random debuff each floor."},
]

const MAX_NEGATIVE_MODIFIERS: int = 5

static var _diff_index: Dictionary = {}
static var _mod_index: Dictionary = {}


static func get_difficulty(id: StringName) -> Dictionary:
	if _diff_index.is_empty():
		for d in DIFFICULTIES:
			_diff_index[d["id"]] = d
	return _diff_index.get(id, {})


static func get_modifier(id: StringName) -> Dictionary:
	if _mod_index.is_empty():
		for m in MODIFIERS:
			_mod_index[m["id"]] = m
	return _mod_index.get(id, {})


static func get_all_modifiers() -> Array:
	return MODIFIERS


static func get_modifiers_by_type(type: StringName) -> Array:
	var result: Array = []
	for m in MODIFIERS:
		if m["type"] == type:
			result.append(m)
	return result


static func compute_total_reward_bonus(active_modifier_ids: Array) -> float:
	## Sum of individual bonuses, plus stacking multiplier for 3+
	var total: float = 0.0
	var negative_count: int = 0
	for id: StringName in active_modifier_ids:
		var m: Dictionary = get_modifier(id)
		if m.is_empty():
			continue
		total += float(m.get("reward_bonus", 0.0))
		if m.get("type", &"") == &"negative":
			negative_count += 1
	# Stacking multiplier
	var stacking_mult: float = 1.0
	if negative_count >= 5:
		stacking_mult = 1.5
	elif negative_count >= 4:
		stacking_mult = 1.25
	elif negative_count >= 3:
		stacking_mult = 1.1
	return total * stacking_mult


static func count_modifiers() -> int:
	return MODIFIERS.size()
