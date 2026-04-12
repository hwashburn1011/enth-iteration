class_name CombatDepthV2
extends RefCounted
## Post-V1 Epic C — Combat Depth II config and helpers.
##
## Consolidates tuning constants and data tables for items C22-C30.
## Each feature is a static function that systems call at runtime.

## C22: Dodge-roll — direction + dash becomes a roll with 20% longer i-frames.
const ROLL_IFRAME_BONUS: float = 0.2  # +20% of base iframe_duration
const ROLL_DISTANCE_MULT: float = 0.7  # Rolls are shorter than dashes

## C23: Enemy attack patterns v2 — additional patterns unlocked at higher iterations.
## Maps enemy_type to an array of additional attack_ids available per iteration.
const ENEMY_V2_PATTERNS: Dictionary = {
	"glitch_bug": {"min_iter": 3, "patterns": ["lunge_bite", "scatter_burst"]},
	"memory_leak": {"min_iter": 2, "patterns": ["triple_projectile", "aoe_puddle"]},
	"rogue_process": {"min_iter": 3, "patterns": ["spin_dash", "ground_slam"]},
}

## C24: Boss phase 4 — desperation phase at <15% HP on iteration 4.
const BOSS_DESPERATION_HP_THRESHOLD: float = 0.15
const BOSS_DESPERATION_MIN_ITER: int = 4
const BOSS_DESPERATION_SPEED_MULT: float = 1.4
const BOSS_DESPERATION_DAMAGE_MULT: float = 1.3

## C25: Environmental hazards — damage per second for floor traps.
const HAZARD_SPIKE_DPS: float = 8.0
const HAZARD_LASER_DPS: float = 12.0
const HAZARD_DEBRIS_DAMAGE: float = 20.0  # Per hit, not DPS

## C27: Weapon types — fast/balanced/heavy with different combo chains.
const WEAPON_TYPES: Dictionary = {
	"fast": {"attack_speed": 1.3, "damage_mult": 0.75, "combo_hits": 4, "desc": "Fast dual-strike"},
	"balanced": {"attack_speed": 1.0, "damage_mult": 1.0, "combo_hits": 3, "desc": "Standard combo"},
	"heavy": {"attack_speed": 0.7, "damage_mult": 1.5, "combo_hits": 2, "desc": "Slow power hits"},
}

## C29: Elite enemy affixes — modifiers beyond the promotion system.
const ELITE_AFFIXES: Array[Dictionary] = [
	{"id": "glowing", "hp_mult": 1.0, "damage_mult": 1.0, "speed_mult": 1.0, "color": [1.0, 0.9, 0.3], "desc": "Illuminated — easier to see, drops extra gold"},
	{"id": "shielded", "hp_mult": 1.0, "damage_mult": 1.0, "speed_mult": 0.9, "shield_hp": 30.0, "color": [0.3, 0.6, 1.0], "desc": "Energy shield absorbs first 30 damage"},
	{"id": "regenerating", "hp_mult": 1.0, "damage_mult": 1.0, "speed_mult": 1.0, "regen_per_sec": 3.0, "color": [0.3, 0.9, 0.4], "desc": "Slowly regenerates HP"},
	{"id": "berserker", "hp_mult": 0.8, "damage_mult": 1.4, "speed_mult": 1.2, "color": [1.0, 0.3, 0.2], "desc": "Low HP but hits hard and fast"},
]


## C22: Check if the current dash should be a roll (directional input held).
static func should_dodge_roll(input_vector: Vector2) -> bool:
	return input_vector.length() > 0.5


## C23: Get additional attack patterns for an enemy at the given iteration.
static func get_v2_patterns(enemy_type: String, iteration: int) -> Array:
	if not ENEMY_V2_PATTERNS.has(enemy_type):
		return []
	var entry: Dictionary = ENEMY_V2_PATTERNS[enemy_type]
	if iteration < int(entry.get("min_iter", 99)):
		return []
	return entry.get("patterns", []) as Array


## C24: Check if the boss should enter desperation phase.
static func should_enter_desperation(hp_ratio: float, iteration: int) -> bool:
	return hp_ratio <= BOSS_DESPERATION_HP_THRESHOLD and iteration >= BOSS_DESPERATION_MIN_ITER


## C29: Pick a random elite affix.
static func random_elite_affix() -> Dictionary:
	if ELITE_AFFIXES.is_empty():
		return {}
	return ELITE_AFFIXES[randi() % ELITE_AFFIXES.size()]


## C30: Parry riposte — returns true if the player is in the parry window.
## The actual riposte damage is handled by the combat system reading
## a meta flag set here.
static func check_parry_riposte(player: Node) -> bool:
	if player == null:
		return false
	if player.has_method(&"is_in_parry_window"):
		return player.is_in_parry_window()
	return false
