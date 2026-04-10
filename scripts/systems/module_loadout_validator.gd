class_name ModuleLoadoutValidator
extends RefCounted

## Module Loadout UI Validator (Epic 33 tasks 44, 47).
##
## Validates that a module loadout configuration is legal AND viable in
## combat. Used both as a UI gate (you cannot apply an illegal loadout)
## and as an automated test harness (Epic 33 task 47 — full module loadouts
## tested in combat).
##
## Validation rules:
##   1. All slots must contain a module of the player's class OR universal
##   2. Ultimate slot must contain an ultimate-tier module
##   3. Total mana cost of equipped modules must fit budget
##   4. No duplicate module ids
##   5. Cooldown synergy: at least one ability with <8s cooldown
##   6. Loadout has at least 1 damage source
##   7. Mixed-class loadouts (e.g. Daemon module on Compiler) flagged
##
## Combat test harness simulates a 60-second mock combat run for each loadout
## and reports DPS, survival time, and any "broken" combinations.

const SLOT_COUNT: int = 6
const ULTIMATE_SLOT_INDEX: int = 5
const MANA_BUDGET: int = 100
const MIN_COOLDOWN_FAST_ABILITY: float = 8.0


## Validates a loadout for the given class. Returns:
##   {
##     "valid": bool,
##     "errors": Array[String],
##     "warnings": Array[String],
##     "mana_used": int,
##     "fastest_cooldown": float,
##     "damage_source_count": int,
##   }
static func validate(class_id: StringName, loadout: Array) -> Dictionary:
	var report: Dictionary = {
		"valid": true,
		"errors": [],
		"warnings": [],
		"mana_used": 0,
		"fastest_cooldown": INF,
		"damage_source_count": 0,
	}

	# 1. Slot count check
	if loadout.size() != SLOT_COUNT:
		report["errors"].append("Loadout has %d slots, expected %d" % [loadout.size(), SLOT_COUNT])
		report["valid"] = false
		return report

	var seen_ids: Dictionary = {}
	for i in range(loadout.size()):
		var module: Dictionary = loadout[i]
		if module.is_empty():
			# Empty slot is allowed except ultimate
			if i == ULTIMATE_SLOT_INDEX:
				report["errors"].append("Ultimate slot cannot be empty")
				report["valid"] = false
			continue

		var mid: StringName = module.get("id", &"")
		var mclass: StringName = module.get("class", &"universal")
		var mtier: StringName = module.get("tier", &"normal")
		var cost: int = int(module.get("mana_cost", 10))
		var cooldown: float = float(module.get("cooldown", 10.0))
		var dmg_source: bool = bool(module.get("is_damage", true))

		# 2. Class compatibility
		if mclass != class_id and mclass != &"universal" and mtier != &"ultimate":
			report["errors"].append("Slot %d: %s is %s class but player is %s" % [i, mid, mclass, class_id])
			report["valid"] = false

		# 3. Duplicates
		if seen_ids.has(mid):
			report["errors"].append("Duplicate module: %s" % mid)
			report["valid"] = false
		seen_ids[mid] = true

		# 4. Ultimate slot check
		if i == ULTIMATE_SLOT_INDEX and mtier != &"ultimate":
			report["errors"].append("Ultimate slot must contain an ultimate-tier module (got %s)" % mtier)
			report["valid"] = false
		elif i != ULTIMATE_SLOT_INDEX and mtier == &"ultimate":
			report["errors"].append("Ultimate-tier module %s in non-ultimate slot %d" % [mid, i])
			report["valid"] = false

		report["mana_used"] += cost
		if cooldown < report["fastest_cooldown"]:
			report["fastest_cooldown"] = cooldown
		if dmg_source:
			report["damage_source_count"] += 1

	# 5. Mana budget
	if report["mana_used"] > MANA_BUDGET:
		report["errors"].append("Mana cost %d exceeds budget %d" % [report["mana_used"], MANA_BUDGET])
		report["valid"] = false

	# 6. Fast ability requirement
	if report["fastest_cooldown"] >= MIN_COOLDOWN_FAST_ABILITY:
		report["warnings"].append("No ability with cooldown < %.1fs (combat may feel sluggish)" % MIN_COOLDOWN_FAST_ABILITY)

	# 7. At least 1 damage source
	if report["damage_source_count"] == 0:
		report["errors"].append("Loadout has no damage sources")
		report["valid"] = false

	# 8. Synergy hint
	if report["damage_source_count"] >= 4:
		report["warnings"].append("All-damage loadout: consider adding utility")

	return report


## Combat test harness — simulates 60s of mock combat and reports DPS,
## survival time, and broken combination flags.
##
## Used for Epic 33 task 47 (full module loadouts tested in combat).
## Stateless — does not touch the live game state.
static func simulate_combat(class_id: StringName, loadout: Array, target_hp: int = 5000, sim_duration: float = 60.0) -> Dictionary:
	var dps_total: float = 0.0
	var time_elapsed: float = 0.0
	var damage_dealt: float = 0.0
	var deaths: int = 0
	var broken_flags: Array[String] = []

	# Compute per-second DPS as sum of (damage / cooldown) for each module
	for module in loadout:
		if module.is_empty(): continue
		var cooldown: float = float(module.get("cooldown", 10.0))
		var damage: float = float(module.get("damage", 0))
		if cooldown <= 0.01:
			broken_flags.append("Module %s has zero cooldown — infinite DPS" % module.get("id", "?"))
			continue
		dps_total += damage / cooldown

	# Class base DPS modifier
	match class_id:
		&"compiler": dps_total *= 1.0
		&"daemon": dps_total *= 1.15  # crit-heavy class
		&"kernel": dps_total *= 0.85   # tank class

	damage_dealt = dps_total * sim_duration
	time_elapsed = sim_duration
	if damage_dealt > target_hp * 5:
		broken_flags.append("Loadout one-shots a 5x HP target — consider rebalancing")

	# Survival simulation: count incoming attacks per second × class def
	var defense: float = 1.0
	match class_id:
		&"compiler": defense = 1.0
		&"daemon": defense = 0.7
		&"kernel": defense = 1.5
	var survival_seconds: float = (200.0 * defense) / 8.0  # 200 HP / ~8 dps incoming

	return {
		"dps": dps_total,
		"sim_seconds": time_elapsed,
		"damage_dealt": damage_dealt,
		"deaths": deaths,
		"survival_seconds": survival_seconds,
		"broken_flags": broken_flags,
		"clear_target": damage_dealt >= target_hp,
	}
