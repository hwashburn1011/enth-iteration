class_name PetDatabase
extends RefCounted

## Static catalog of all 8 pets with stats, acquisition source, and bonuses.

const PETS: Array = [
	{
		"id": &"data_sprite",
		"name": "Data Sprite",
		"role": &"caster",
		"acquisition": &"egg_common",
		"egg_source": &"server_room_boss",
		"stat_bonus_key": &"max_compute",
		"stat_bonus_values": [0, 5, 10, 15, 20],  # Sad, Content, Happy, Devoted... wait, 4 tiers + 0
		"devoted_bonus_key": &"ability_damage_pct",
		"devoted_bonus_value": 0.10,
		"ability_proc": "5% on cast: refund 50% compute",
		"hatch_minutes": 5,
		"color": Color(0.30, 0.85, 0.95),
		"model_path": "res://assets/models/pets/data_sprite.glb",
	},
	{
		"id": &"patch_dog",
		"name": "Patch Dog",
		"role": &"loyal",
		"acquisition": &"npc_gift",
		"npc_source": &"harvest",
		"npc_min_tier": 1,
		"stat_bonus_key": &"max_hp",
		"stat_bonus_values": [0, 10, 20, 30, 40],
		"devoted_bonus_key": &"defense_pct",
		"devoted_bonus_value": 0.05,
		"ability_proc": "Bark on enemy spawn: 10% taunt for 1s",
		"hatch_minutes": 0,  # gift, no hatch
		"color": Color(0.85, 0.65, 0.45),
		"model_path": "res://assets/models/pets/patch_dog.glb",
	},
	{
		"id": &"bit_cat",
		"name": "Bit Cat",
		"role": &"stealth",
		"acquisition": &"egg_common",
		"egg_source": &"memory_vaults",
		"stat_bonus_key": &"crit_chance",
		"stat_bonus_values": [0, 0.01, 0.02, 0.03, 0.04],
		"devoted_bonus_key": &"move_speed_pct",
		"devoted_bonus_value": 0.20,
		"ability_proc": "First strike from stealth: +25% damage",
		"hatch_minutes": 5,
		"color": Color(0.40, 0.40, 0.55),
		"model_path": "res://assets/models/pets/bit_cat.glb",
	},
	{
		"id": &"bug_buddy",
		"name": "Bug Buddy",
		"role": &"corrupt",
		"acquisition": &"quest_reward",
		"quest_source": &"glitcher_recruit",
		"stat_bonus_key": &"damage_pct",
		"stat_bonus_values": [0, 0.03, 0.06, 0.09, 0.12],
		"devoted_bonus_key": &"corrupt_damage_pct",
		"devoted_bonus_value": 0.15,
		"ability_proc": "5% on hit: apply Glitch debuff (target attacks self)",
		"hatch_minutes": 0,
		"color": Color(0.65, 0.20, 0.85),
		"model_path": "res://assets/models/pets/bug_buddy.glb",
	},
	{
		"id": &"memory_owl",
		"name": "Memory Owl",
		"role": &"intelligent",
		"acquisition": &"npc_gift",
		"npc_source": &"index",
		"npc_min_tier": 2,
		"stat_bonus_key": &"xp_gain_pct",
		"stat_bonus_values": [0, 0.05, 0.10, 0.15, 0.20],
		"devoted_bonus_key": &"affinity_per_gift",
		"devoted_bonus_value": 1,
		"ability_proc": "Reveals 1 hidden chest per dungeon",
		"hatch_minutes": 0,
		"color": Color(0.75, 0.85, 0.95),
		"model_path": "res://assets/models/pets/memory_owl.glb",
	},
	{
		"id": &"cache_mouse",
		"name": "Cache Mouse",
		"role": &"gather",
		"acquisition": &"egg_common",
		"egg_source": &"forge_enemies",
		"stat_bonus_key": &"loot_magnet_radius",
		"stat_bonus_values": [0, 1.0, 2.0, 3.0, 4.0],
		"devoted_bonus_key": &"material_drop_pct",
		"devoted_bonus_value": 0.25,
		"ability_proc": "10% on kill: drop free common material",
		"hatch_minutes": 5,
		"color": Color(0.65, 0.55, 0.40),
		"model_path": "res://assets/models/pets/cache_mouse.glb",
	},
	{
		"id": &"echo_bird",
		"name": "Echo Bird",
		"role": &"flying",
		"acquisition": &"hidden_quest",
		"quest_source": &"iteration_memorial_secret",
		"stat_bonus_key": &"dash_charges",
		"stat_bonus_values": [0, 1, 2, 3, 4],
		"devoted_bonus_key": &"dash_invuln_seconds",
		"devoted_bonus_value": 1.0,
		"ability_proc": "5% on dash: refund cooldown",
		"hatch_minutes": 0,
		"color": Color(0.85, 0.95, 0.95),
		"model_path": "res://assets/models/pets/echo_bird.glb",
	},
	{
		"id": &"crystal_fox",
		"name": "Crystal Fox",
		"role": &"legendary",
		"acquisition": &"boss_drop",
		"boss_source": &"final_boss",
		"stat_bonus_key": &"all_stats_pct",
		"stat_bonus_values": [0, 0.01, 0.02, 0.03, 0.04],
		"devoted_bonus_key": &"revive_on_death_chance",
		"devoted_bonus_value": 0.20,
		"ability_proc": "1/dungeon: prevent lethal damage + 3s invuln",
		"hatch_minutes": 60,
		"color": Color(0.95, 0.85, 1.00),
		"model_path": "res://assets/models/pets/crystal_fox.glb",
	},
]

const HAPPINESS_TIERS: Array = [
	{"name": "Sad",     "min": 0,  "max": 25,  "tier_index": 0},
	{"name": "Content", "min": 26, "max": 50,  "tier_index": 1},
	{"name": "Happy",   "min": 51, "max": 75,  "tier_index": 2},
	{"name": "Devoted", "min": 76, "max": 100, "tier_index": 3},
]

static var _index: Dictionary = {}


static func get_all() -> Array:
	return PETS


static func get_pet(id: StringName) -> Dictionary:
	if _index.is_empty():
		_build_index()
	return _index.get(id, {})


static func _build_index() -> void:
	for p in PETS:
		_index[p["id"]] = p


static func get_happiness_tier(happiness: int) -> int:
	for t in HAPPINESS_TIERS:
		if happiness >= t["min"] and happiness <= t["max"]:
			return t["tier_index"]
	return 0


static func get_happiness_tier_name(happiness: int) -> String:
	return HAPPINESS_TIERS[get_happiness_tier(happiness)]["name"]


static func get_stat_bonus(pet_id: StringName, happiness: int) -> Dictionary:
	## Returns { primary_key, primary_value, devoted_key (or null), devoted_value }
	var p: Dictionary = get_pet(pet_id)
	if p.is_empty():
		return {}
	var tier: int = get_happiness_tier(happiness)
	var values: Array = p.get("stat_bonus_values", [0, 0, 0, 0, 0])
	var primary_value: float = float(values[tier + 1]) if (tier + 1) < values.size() else 0.0
	var result: Dictionary = {
		"primary_key": p.get("stat_bonus_key", &""),
		"primary_value": primary_value,
	}
	if tier == 3:  # Devoted
		result["devoted_key"] = p.get("devoted_bonus_key", &"")
		result["devoted_value"] = p.get("devoted_bonus_value", 0.0)
	return result


static func count() -> int:
	return PETS.size()
