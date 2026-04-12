class_name ProgressionExpansion
extends RefCounted
## R3 Epic M — Progression Expansion config.
##
## Defines tier 2 items, equipment set definitions, and respec costs.
## Item data is consumed by ItemGenerator and VendorStock. Set bonuses
## are checked by EquipmentComponent at equip time. Respec costs are
## read by the inventory UI when the player opens the respec panel.

## M23: Tier 2 Modules — upgraded versions with higher base damage.
const TIER2_MODULES: Array[Dictionary] = [
	{"item_id": "module_fork_bomb_2", "name": "Fork Bomb II", "rarity": 3, "compute_cost": 28.0, "cooldown": 5.0, "base_damage": 45.0, "description": "Launches 4 explosive forks that each deal area damage."},
	{"item_id": "module_logic_bomb_2", "name": "Logic Bomb II", "rarity": 3, "compute_cost": 24.0, "cooldown": 4.5, "base_damage": 55.0, "description": "Delayed detonation dealing massive damage in a large radius."},
	{"item_id": "module_packet_storm_2", "name": "Packet Storm II", "rarity": 3, "compute_cost": 32.0, "cooldown": 6.0, "base_damage": 35.0, "description": "Fires 8 homing packets that each deal moderate damage."},
	{"item_id": "module_defrag_pulse_2", "name": "Defrag Pulse II", "rarity": 3, "compute_cost": 22.0, "cooldown": 8.0, "base_damage": 0.0, "description": "Heals 40% max health and grants 3s damage immunity."},
	{"item_id": "module_deadlock_2", "name": "Deadlock II", "rarity": 3, "compute_cost": 26.0, "cooldown": 7.0, "base_damage": 30.0, "description": "Freezes all enemies in range for 4s, then deals burst damage."},
]

## M24: Tier 2 Cores — upgraded cores with stacking effects.
const TIER2_CORES: Array[Dictionary] = [
	{"item_id": "core_quantum_processor_2", "name": "Quantum Processor II", "rarity": 4, "bonus_stats": {"processing": 12, "bandwidth": 8}, "description": "Dual-channel quantum core. +15% crit damage."},
	{"item_id": "core_volatile_compiler_2", "name": "Volatile Compiler II", "rarity": 4, "bonus_stats": {"processing": 15}, "crit_bonus": 12.0, "description": "Overclocked compiler. +12% crit chance, +15 processing."},
	{"item_id": "core_persistent_thread_2", "name": "Persistent Thread II", "rarity": 4, "bonus_stats": {"integrity": 15, "memory": 10}, "description": "Hardened thread. Health regen +3/s, +15 integrity."},
]

## M25: Tier 2 Chips — upgraded chips with enhanced passives.
const TIER2_CHIPS: Array[Dictionary] = [
	{"item_id": "chip_bandwidth_booster_2", "name": "Bandwidth Booster II", "rarity": 3, "bonus": {"bandwidth": 10}, "description": "+10 Bandwidth. Compute regen +25%."},
	{"item_id": "chip_armor_plating_2", "name": "Armor Plating II", "rarity": 3, "bonus": {"integrity": 12}, "description": "+12 Integrity. Damage reduction +8%."},
	{"item_id": "chip_assault_processor_2", "name": "Assault Processor II", "rarity": 3, "bonus": {"processing": 10}, "description": "+10 Processing. Attack speed +15%."},
	{"item_id": "chip_kinetic_dash_2", "name": "Kinetic Dash II", "rarity": 3, "bonus": {"bandwidth": 8}, "description": "Dash distance +40%. Dash cooldown −0.5s."},
	{"item_id": "chip_counterstrike_2", "name": "Counterstrike II", "rarity": 4, "bonus": {"processing": 8}, "description": "Parry window +50ms. Riposte damage +80%."},
]

## M26: Equipment Set Definitions — 3 item sets with 2-piece and 3-piece bonuses.
const EQUIPMENT_SETS: Dictionary = {
	"compiler_suite": {
		"name": "Compiler Suite",
		"items": ["core_volatile_compiler", "chip_assault_processor", "module_logic_bomb"],
		"bonus_2": {"description": "+10% Crit Chance", "effect": "crit", "amount": 10.0},
		"bonus_3": {"description": "+25% Ability Damage", "effect": "ability_damage", "amount": 25.0},
	},
	"fortress_protocol": {
		"name": "Fortress Protocol",
		"items": ["core_persistent_thread", "chip_armor_plating", "module_defrag_pulse"],
		"bonus_2": {"description": "+15 Integrity", "effect": "stat", "key": "integrity", "amount": 15.0},
		"bonus_3": {"description": "Thorns: reflect 20% damage", "effect": "thorns", "amount": 20.0},
	},
	"speed_daemon": {
		"name": "Speed Daemon",
		"items": ["core_quantum_processor", "chip_kinetic_dash", "chip_bandwidth_booster"],
		"bonus_2": {"description": "+20% Move Speed", "effect": "move_speed", "amount": 20.0},
		"bonus_3": {"description": "Dash resets on kill", "effect": "dash_reset_on_kill", "amount": 1.0},
	},
}

## M29: Respec passive allocations — gold cost per node.
const RESPEC_PASSIVE_COST_PER_NODE: int = 50

## M30: Respec stat points — gold cost per point.
const RESPEC_STAT_COST_PER_POINT: int = 100

## Returns the set match count for a given set_id from equipped item_ids.
static func count_set_matches(set_id: String, equipped_ids: Array[String]) -> int:
	if set_id not in EQUIPMENT_SETS:
		return 0
	var set_items: Array = EQUIPMENT_SETS[set_id]["items"] as Array
	var count: int = 0
	for item_id: String in set_items:
		if item_id in equipped_ids:
			count += 1
	return count


## Returns active set bonuses as an array of bonus dicts.
static func get_active_bonuses(equipped_ids: Array[String]) -> Array[Dictionary]:
	var bonuses: Array[Dictionary] = []
	for set_id: String in EQUIPMENT_SETS:
		var count: int = count_set_matches(set_id, equipped_ids)
		var set_data: Dictionary = EQUIPMENT_SETS[set_id] as Dictionary
		if count >= 2 and "bonus_2" in set_data:
			bonuses.append(set_data["bonus_2"] as Dictionary)
		if count >= 3 and "bonus_3" in set_data:
			bonuses.append(set_data["bonus_3"] as Dictionary)
	return bonuses
