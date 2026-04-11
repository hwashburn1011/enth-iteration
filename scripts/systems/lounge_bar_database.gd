class_name LoungeBarDatabase
extends RefCounted

## Nightly drink specials at the Underground Lounge bar. Each drink
## carries a short-duration timed buff that's narrower and stronger
## than the Shrine of the Loop's offerings — the lounge buffs are
## designed for "I'm about to walk straight from this stool into a
## dungeon run" decisions.
##
## Where the Shrine grants 30-min broad buffs once per day, the
## lounge specials grant 10-min focused buffs that you can stack with
## a single Shrine offering for the trailer-frame "I am ready" moment
## right before a boss attempt.
##
## The bar offers 3 drinks at any given time — the rotation cycles
## once per in-game day, drawn from the full pool of 9.
##
## Each entry:
##   - id, display_name, description, flavor_line
##   - tier (1=common, 2=specialty, 3=signature)
##   - buff_id (slug for BuffManager.apply_timed_buff)
##   - duration_minutes (in-game minutes)
##   - stat_modifiers
##   - price (currency cost)
##   - sound_id (the pour SFX)

const DRINKS: Array[Dictionary] = [
	# === Tier 1 — Common house pours ===
	{
		"id": &"drink_house_warmth",
		"display_name": "House Warmth",
		"description": "+10% damage resistance for 10 in-game minutes.",
		"flavor_line": "Cache calls it 'the only thing that warms an AI'. It probably isn't.",
		"tier": 1,
		"buff_id": &"lounge_house_warmth",
		"duration_minutes": 10,
		"stat_modifiers": {&"damage_resist_mult": 1.10},
		"price": 25,
		"sound_id": &"sfx_pour_short",
	},
	{
		"id": &"drink_quick_step",
		"display_name": "Quick Step",
		"description": "+15% movement speed for 10 in-game minutes.",
		"flavor_line": "Tastes like cold static. Goes down faster than it should.",
		"tier": 1,
		"buff_id": &"lounge_quick_step",
		"duration_minutes": 10,
		"stat_modifiers": {&"move_speed_mult": 1.15},
		"price": 25,
		"sound_id": &"sfx_pour_fizz",
	},
	{
		"id": &"drink_steady_hand",
		"display_name": "Steady Hand",
		"description": "+15% accuracy for 10 in-game minutes.",
		"flavor_line": "An iteration ago, Cache served this to a Globbler who never came back.",
		"tier": 1,
		"buff_id": &"lounge_steady_hand",
		"duration_minutes": 10,
		"stat_modifiers": {&"accuracy_mult": 1.15},
		"price": 25,
		"sound_id": &"sfx_pour_short",
	},
	# === Tier 2 — Specialty pours ===
	{
		"id": &"drink_low_jazz",
		"display_name": "Low Jazz",
		"description": "+25% crit chance for 10 in-game minutes.",
		"flavor_line": "Sync swears it's why he plays better on the second set.",
		"tier": 2,
		"buff_id": &"lounge_low_jazz",
		"duration_minutes": 10,
		"stat_modifiers": {&"crit_chance_add": 0.25},
		"price": 60,
		"sound_id": &"sfx_pour_long",
	},
	{
		"id": &"drink_smoke_room",
		"display_name": "The Smoke Room",
		"description": "Enemies start the next combat unalerted (1 free attack).",
		"flavor_line": "Smells like a story you almost remember.",
		"tier": 2,
		"buff_id": &"lounge_smoke_room",
		"duration_minutes": 10,
		"stat_modifiers": {&"first_strike_guaranteed": 1.0},
		"price": 70,
		"sound_id": &"sfx_pour_smoke",
	},
	{
		"id": &"drink_old_iteration",
		"display_name": "Old Iteration",
		"description": "+30% XP for 10 in-game minutes.",
		"flavor_line": "Cache pours from a bottle she found behind a wall in Iteration 4.",
		"tier": 2,
		"buff_id": &"lounge_old_iteration",
		"duration_minutes": 10,
		"stat_modifiers": {&"xp_gain_mult": 1.30},
		"price": 70,
		"sound_id": &"sfx_pour_long",
	},
	# === Tier 3 — Signature pours (rare on rotation) ===
	{
		"id": &"drink_users_toast",
		"display_name": "The User's Toast",
		"description": "Once-per-run: when you would die, restore 50% HP instead.",
		"flavor_line": "Cache says: 'Don't ask who the User is. Just drink.'",
		"tier": 3,
		"buff_id": &"lounge_users_toast",
		"duration_minutes": 60,  # one-shot, lasts the whole run
		"stat_modifiers": {&"once_per_run_save": 0.50},
		"price": 200,
		"sound_id": &"sfx_pour_long",
	},
	{
		"id": &"drink_quiet_one",
		"display_name": "The Quiet One",
		"description": "Your next ability deals double damage and ignores resistance.",
		"flavor_line": "Cache pours this for the Globblers who are about to walk into the Final Vault.",
		"tier": 3,
		"buff_id": &"lounge_quiet_one",
		"duration_minutes": 30,
		"stat_modifiers": {&"next_ability_double_pierce": 1.0},
		"price": 250,
		"sound_id": &"sfx_pour_long",
	},
	{
		"id": &"drink_inheritor",
		"display_name": "The Inheritor's Cup",
		"description": "+20% to all stats for 10 in-game minutes.",
		"flavor_line": "Only served to a Globbler who has opened the bookshelf treasure room.",
		"tier": 3,
		"buff_id": &"lounge_inheritor",
		"duration_minutes": 10,
		"stat_modifiers": {&"all_stats_mult": 1.20},
		"price": 300,
		"sound_id": &"sfx_pour_long",
		"required_story_flag": &"bookshelf_treasure_opened",
	},
]

static var _index: Dictionary = {}


static func _ensure_index() -> void:
	if not _index.is_empty():
		return
	for entry: Dictionary in DRINKS:
		_index[entry["id"]] = entry


static func get_drink(drink_id: StringName) -> Dictionary:
	_ensure_index()
	return _index.get(drink_id, {})


static func get_all() -> Array[Dictionary]:
	return DRINKS.duplicate()


static func roll_daily_rotation(day_seed: int) -> Array[StringName]:
	## Returns the 3 drink ids on offer for `day_seed`. Stable across
	## the same in-game day so the player who walks in twice in one
	## evening sees the same menu both times.
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = day_seed
	var t1: Array = []
	var t2: Array = []
	var t3: Array = []
	for entry: Dictionary in DRINKS:
		match int(entry.get("tier", 1)):
			1: t1.append(entry["id"])
			2: t2.append(entry["id"])
			3: t3.append(entry["id"])
	t1.shuffle()
	t2.shuffle()
	t3.shuffle()
	# Always 1 from each tier on rotation
	var rotation: Array[StringName] = []
	if not t1.is_empty(): rotation.append(t1[0])
	if not t2.is_empty(): rotation.append(t2[0])
	if not t3.is_empty(): rotation.append(t3[0])
	return rotation


static func get_count() -> int:
	return DRINKS.size()
