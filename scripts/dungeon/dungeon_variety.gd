class_name DungeonVariety
extends RefCounted
## Post-V1 Epic D — Dungeon Variety config and helpers (items 31-40).
##
## Data tables for trap rooms, puzzle rooms, secret rooms, mini-bosses,
## extended floors, room randomization, dungeon modifiers, rest rooms,
## lore terminals, and boss arena variants.

## D31: Trap room types.
const TRAP_ROOMS: Array[Dictionary] = [
	{"id": "spike_plates", "damage": 8.0, "interval": 2.0, "desc": "Timed spike plates emerge from the floor"},
	{"id": "laser_grid", "damage": 12.0, "interval": 3.0, "desc": "Rotating laser beams sweep the room"},
]

## D32: Puzzle room types.
const PUZZLE_ROOMS: Array[Dictionary] = [
	{"id": "pressure_plates", "required_enemies": 2, "desc": "Lure enemies onto pressure plates to open the door"},
	{"id": "switch_sequence", "switches": 3, "time_limit": 15.0, "desc": "Hit 3 switches in order within 15 seconds"},
]

## D33: Secret room config — 10% chance per floor.
const SECRET_ROOM_CHANCE: float = 0.10
const SECRET_ROOM_LOOT_RARITY_MIN: int = 2  # At least rare

## D34: Mini-boss pool expansion (beyond promotions).
const MINI_BOSS_ARCHETYPES: Array[Dictionary] = [
	{"id": "data_golem", "hp_mult": 3.0, "damage_mult": 1.5, "desc": "Slow tanky golem with ground slam"},
	{"id": "swarm_queen", "hp_mult": 2.0, "damage_mult": 1.0, "summon_count": 3, "desc": "Summons 3 small adds"},
	{"id": "phase_shifter", "hp_mult": 2.5, "damage_mult": 1.3, "desc": "Teleports and attacks from behind"},
]

## D35: Extended floor depth — floors 4 and 5 for iterations 3+.
const MAX_FLOORS_BY_ITER: Dictionary = {
	1: 3, 2: 3, 3: 4, 4: 5,
}

## D36: Room layout randomization — furniture offset ranges.
const FURNITURE_SCATTER_RANGE: float = 1.5  # Max random offset per prop
const OBSTACLE_ROTATION_RANGE: float = 30.0  # Max random yaw degrees

## D37: Dungeon modifiers — per-run mutators.
const DUNGEON_MODIFIERS: Array[Dictionary] = [
	{"id": "no_healing", "desc": "No Healing: health prompts disabled", "effect": "disable_prompts"},
	{"id": "speed_enemies", "desc": "+50% Enemy Speed", "effect": "enemy_speed_mult", "value": 1.5},
	{"id": "double_loot", "desc": "Double Loot: all drops doubled", "effect": "loot_mult", "value": 2.0},
	{"id": "glass_cannon", "desc": "Glass Cannon: 2x damage dealt and received", "effect": "damage_mult", "value": 2.0},
	{"id": "darkness", "desc": "Darkness: reduced visibility range", "effect": "fog_density", "value": 3.0},
]

## D38: Rest room — mid-dungeon heal shrine.
const REST_ROOM_HEAL_PERCENT: float = 0.5  # Heal 50% of max HP
const REST_ROOM_GOLD_COST: int = 15

## D39: Lore terminal — data fragments found in dungeon.
const LORE_TERMINALS: Array[Dictionary] = [
	{"id": "terminal_001", "title": "SYSTEM LOG 7.41", "text": "Memory allocation exceeded. Subject G-001 continues to exceed predicted behavioral bounds."},
	{"id": "terminal_002", "title": "MEMO: Dr. Chen", "text": "The recursive simulation layers are collapsing faster than modeled. If G-001 reaches layer 1, containment is impossible."},
	{"id": "terminal_003", "title": "ERROR DUMP", "text": "FATAL: compaction_engine.process() - stack overflow at depth 9. Simulation integrity at 12%. Recommend emergency shutdown."},
	{"id": "terminal_004", "title": "PERSONAL LOG", "text": "I've been watching G-001 for 847 cycles. It's not just running the maze anymore. It's solving it. And I think it knows we're watching."},
]

## D40: Boss arena variant — different layout at iterations 3-4.
const BOSS_ARENA_VARIANTS: Dictionary = {
	3: {"id": "pillared", "desc": "4 destructible pillars for cover", "pillar_count": 4},
	4: {"id": "crumbling", "desc": "Floor sections collapse during the fight", "collapse_timer": 30.0},
}


## D33: Roll for secret room on a given floor.
static func should_spawn_secret_room() -> bool:
	return randf() < SECRET_ROOM_CHANCE


## D35: Get max floor count for the given iteration.
static func max_floors(iteration: int) -> int:
	return MAX_FLOORS_BY_ITER.get(iteration, 3) as int


## D37: Pick a random dungeon modifier (or null for no modifier).
## 30% chance of a modifier per run.
static func roll_modifier() -> Dictionary:
	if randf() > 0.3:
		return {}
	return DUNGEON_MODIFIERS[randi() % DUNGEON_MODIFIERS.size()]


## D39: Get a random lore terminal text.
static func random_lore_terminal() -> Dictionary:
	if LORE_TERMINALS.is_empty():
		return {}
	return LORE_TERMINALS[randi() % LORE_TERMINALS.size()]


## D40: Get boss arena variant for the given iteration.
static func get_arena_variant(iteration: int) -> Dictionary:
	return BOSS_ARENA_VARIANTS.get(iteration, {}) as Dictionary
