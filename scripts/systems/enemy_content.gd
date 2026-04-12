class_name EnemyContent
extends RefCounted
## R4 Epic R — Enemy content wiring: tutorial hints, bestiary, kill counters.
##
## R22: Tutorial hints for new enemy types
## R28: New enemy loot table paths
## R29: Bestiary data (descriptions + stats)
## R30: Kill counter per type

## R22: Tutorial hints for first encounter with each new enemy type.
const ENEMY_TUTORIAL_HINTS: Dictionary = {
	"firewall_guardian": "FIREWALL GUARDIAN: Stationary turret. Close the distance fast — it can't move.",
	"buffer_overflow": "BUFFER OVERFLOW: Explodes on death! Keep your distance when it dies.",
	"null_pointer": "NULL POINTER: Teleports behind you. Watch your back and dodge after it blinks.",
	"stack_crawler": "STACK CRAWLER: Extremely tough but slow. Kite it and use ranged abilities.",
	"syntax_error": "SYNTAX ERROR: Spawns clones when hit. Focus it down quickly before it multiplies.",
}

## R28: Loot table resource paths for 5 new enemy types.
const ENEMY_LOOT_TABLES: Dictionary = {
	"firewall_guardian": "res://data/loot_tables/firewall_guardian_loot.tres",
	"buffer_overflow": "res://data/loot_tables/buffer_overflow_loot.tres",
	"null_pointer": "res://data/loot_tables/null_pointer_loot.tres",
	"stack_crawler": "res://data/loot_tables/stack_crawler_loot.tres",
	"syntax_error": "res://data/loot_tables/syntax_error_loot.tres",
}

## R29: Bestiary data — descriptions and base stats for the pause menu bestiary.
const BESTIARY: Dictionary = {
	"glitch_bug": {
		"name": "Glitch Bug",
		"description": "Fast melee attacker. Small, aggressive, and numerous. The basic threat of any dungeon.",
		"base_hp": 30, "base_damage": 8, "speed": "Fast",
	},
	"memory_leak": {
		"name": "Memory Leak",
		"description": "Ranged attacker that fires data packets. Keeps distance and whittles down health.",
		"base_hp": 50, "base_damage": 12, "speed": "Medium",
	},
	"rogue_process": {
		"name": "Rogue Process",
		"description": "Heavy melee bruiser. High HP and damage but slow. Watch for its charge attack.",
		"base_hp": 80, "base_damage": 18, "speed": "Slow",
	},
	"firewall_guardian": {
		"name": "Firewall Guardian",
		"description": "Stationary shielded turret. Fires projectiles from range but cannot move. High armor.",
		"base_hp": 80, "base_damage": 15, "speed": "Immobile",
	},
	"buffer_overflow": {
		"name": "Buffer Overflow",
		"description": "Fast kamikaze charger. Low HP but explodes on death dealing heavy AoE damage.",
		"base_hp": 20, "base_damage": 10, "speed": "Very Fast",
	},
	"null_pointer": {
		"name": "Null Pointer",
		"description": "Ghostly teleporter. Blinks behind the player to strike, then vanishes again.",
		"base_hp": 40, "base_damage": 14, "speed": "Medium",
	},
	"stack_crawler": {
		"name": "Stack Crawler",
		"description": "Massive armored worm. Extremely high HP and heavy melee but very slow movement.",
		"base_hp": 150, "base_damage": 20, "speed": "Very Slow",
	},
	"syntax_error": {
		"name": "Syntax Error",
		"description": "Glitchy duplicator. When damaged, has a chance to spawn Glitch Bug clones.",
		"base_hp": 45, "base_damage": 10, "speed": "Medium",
	},
}

## R30: Kill counter keys — tracked via GameManager metas.
## Format: GameManager.set_meta(&"kills_<type>", count)
static func increment_kill_count(enemy_type: String) -> int:
	var meta_key: StringName = StringName("kills_%s" % enemy_type)
	var current: int = 0
	if GameManager.has_meta(meta_key):
		current = int(GameManager.get_meta(meta_key))
	current += 1
	GameManager.set_meta(meta_key, current)
	return current


static func get_kill_count(enemy_type: String) -> int:
	var meta_key: StringName = StringName("kills_%s" % enemy_type)
	if GameManager.has_meta(meta_key):
		return int(GameManager.get_meta(meta_key))
	return 0


static func get_all_kill_counts() -> Dictionary:
	var counts: Dictionary = {}
	for enemy_type: String in BESTIARY:
		counts[enemy_type] = get_kill_count(enemy_type)
	return counts
