class_name StatsComponent
extends Node
## Holds the four base stats and computes final values from base + level + equipment.

signal stats_changed

@export var base_processing: float = 10.0
@export var base_bandwidth: float = 10.0
@export var base_memory: float = 10.0
@export var base_integrity: float = 10.0

var level_points: Dictionary = {
	"processing": 0,
	"bandwidth": 0,
	"memory": 0,
	"integrity": 0,
}
var equipment_bonuses: Dictionary = {}
## Phase 3 #26 — passive node bonuses. Parallel to equipment_bonuses
## but populated by PassiveProgression.add_stat_bonus on level 3, 6,
## 9, etc. Survives equipment swaps and gets summed into get_stat
## the same way equipment bonuses do.
var passive_bonuses: Dictionary = {}


func get_stat(stat_name: String) -> float:
	var base_value: float = 0.0
	match stat_name:
		"processing":
			base_value = base_processing
		"bandwidth":
			base_value = base_bandwidth
		"memory":
			base_value = base_memory
		"integrity":
			base_value = base_integrity
		_:
			push_error("StatsComponent: unknown stat '%s'" % stat_name)
			return 0.0
	var level_bonus: float = float(level_points.get(stat_name, 0))
	var equip_bonus: float = float(equipment_bonuses.get(stat_name, 0.0))
	var passive_bonus: float = float(passive_bonuses.get(stat_name, 0.0))
	return base_value + level_bonus + equip_bonus + passive_bonus


## Phase 3 #26 — passive node helper. Adds (stacking) bonus to a
## stat from a skill tree node. Re-applied on load via the player's
## unlocked_passives serialized list.
func add_passive_bonus(stat_name: String, amount: float) -> void:
	passive_bonuses[stat_name] = float(passive_bonuses.get(stat_name, 0.0)) + amount
	stats_changed.emit()


func allocate_point(stat_name: String) -> void:
	if stat_name not in level_points:
		push_error("StatsComponent: cannot allocate to unknown stat '%s'" % stat_name)
		return
	level_points[stat_name] += 1
	stats_changed.emit()


func recalculate_equipment_bonuses(equipped_items: Array) -> void:
	equipment_bonuses.clear()
	for item: Resource in equipped_items:
		if item == null:
			continue
		# Use effective modifiers (durability-scaled) if available
		var modifiers: Dictionary = {}
		if item.has_method(&"get_effective_stat_modifiers"):
			modifiers = item.get_effective_stat_modifiers()
		elif &"stat_modifiers" in item:
			modifiers = item.stat_modifiers
		for stat_name: String in modifiers:
			equipment_bonuses[stat_name] = equipment_bonuses.get(stat_name, 0.0) + float(modifiers[stat_name])
	stats_changed.emit()


func get_all_stats() -> Dictionary:
	return {
		"processing": get_stat("processing"),
		"bandwidth": get_stat("bandwidth"),
		"memory": get_stat("memory"),
		"integrity": get_stat("integrity"),
	}
