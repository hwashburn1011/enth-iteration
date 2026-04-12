class_name ChallengeContent
extends RefCounted
## R7 Epic AG — Challenge & endgame content config.
##
## AG21-AG30: Daily challenges, modifiers, boss rush, endless arena.

## AG21: Daily challenge seed — rotates based on date.
static func get_daily_seed() -> int:
	var date: Dictionary = Time.get_date_dict_from_system()
	return hash("%d-%d-%d" % [date["year"], date["month"], date["day"]])

## AG22: Challenge modifiers.
const CHALLENGE_MODIFIERS: Array[Dictionary] = [
	{"id": "glass_cannon", "name": "Glass Cannon", "desc": "Deal 2x damage, take 2x damage", "damage_mult": 2.0, "taken_mult": 2.0},
	{"id": "no_heal", "name": "No Healing", "desc": "Health potions and lifesteal disabled", "heal_disabled": true},
	{"id": "fast_enemies", "name": "Fast Enemies", "desc": "All enemies move 50% faster", "enemy_speed_mult": 1.5},
	{"id": "fragile", "name": "Fragile", "desc": "Player has 50% max HP", "hp_mult": 0.5},
	{"id": "drought", "name": "Compute Drought", "desc": "Compute regen halved", "compute_regen_mult": 0.5},
	{"id": "elite_swarm", "name": "Elite Swarm", "desc": "All enemies are elites", "all_elite": true},
]

## AG23: Challenge reward scaling — bonus multiplier per active modifier.
const CHALLENGE_REWARD_MULT_PER_MOD: float = 0.25

## AG25: Infinite mode high score key.
const INFINITE_HIGH_SCORE_KEY: StringName = &"infinite_best_floor"

static func get_infinite_high_score() -> int:
	if GameManager.has_meta(INFINITE_HIGH_SCORE_KEY):
		return int(GameManager.get_meta(INFINITE_HIGH_SCORE_KEY))
	return 0

static func set_infinite_high_score(floor_num: int) -> void:
	var current: int = get_infinite_high_score()
	if floor_num > current:
		GameManager.set_meta(INFINITE_HIGH_SCORE_KEY, floor_num)

## AG27: Boss rush mode — ordered boss list.
const BOSS_RUSH_ORDER: Array[StringName] = [
	&"memory_warden", &"root_heart", &"sentinel_prime", &"iteration_phantom",
	&"void_architect", &"mosaic_hydra", &"compiler_reborn", &"origin_singularity",
]

## AG28: Boss rush timer format.
static func format_time(seconds: float) -> String:
	var mins: int = int(seconds) / 60
	var secs: int = int(seconds) % 60
	var ms: int = int((seconds - int(seconds)) * 100)
	return "%d:%02d.%02d" % [mins, secs, ms]
