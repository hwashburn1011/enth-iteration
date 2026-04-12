class_name CoreItem
extends "res://scripts/items/item_base.gd"
## Build-defining core — unique passive effect that shapes playstyle.
##
## core_bonus_stats lives outside the base stat_modifiers dict so that the
## inventory UI can show the core's signature stats in their own row, but
## the equipment recalculator only reads get_effective_stat_modifiers().
## We override that here to merge both dicts (durability-scaled) so the
## bonus actually reaches the player. Without this override every core's
## headline stats are silently dropped — every legendary core is just
## the passive description with no numbers behind it.

@export var core_passive: String = ""
@export var core_bonus_stats: Dictionary = {}
## Flat percentage points added to the player's critical hit chance when this
## core is equipped. damage_calculator reads source.equipment_component.core_slot
## and adds this to BASE_CRIT_CHANCE. Use the same units as BASE_CRIT_CHANCE
## (5.0 = 5%) so e.g. 10.0 here gives a +10% crit bonus.
@export var extra_crit_chance: float = 0.0
## Phase 3 #28 — bespoke core effects beyond crit. Each new field is
## consumed by exactly one component to keep the dependency graph
## obvious. Cores stack additively when more than one passive applies.
##
## compute_on_kill: flat compute restored every time an enemy dies in
## the player's scene. Read by ComputeComponent on EventBus.enemy_defeated.
## Lets the player turn aggression into resource for sustained module use.
@export var compute_on_kill: float = 0.0
## dash_cooldown_reduction: flat seconds removed from the player's
## dash cooldown. Read by player.gd when starting the dash cooldown
## timer. Stacks with player.dash_cooldown floor of 0.2s.
@export var dash_cooldown_reduction: float = 0.0


func _init() -> void:
	item_type = "core"


func get_effective_stat_modifiers() -> Dictionary:
	var base: Dictionary = super.get_effective_stat_modifiers()
	var durability_pct: float = current_durability / max_durability if max_durability > 0.0 else 0.0
	var scale: float = 1.0
	if durability_pct <= 0.0:
		scale = 0.0
	elif durability_pct < 0.25:
		scale = 0.5
	elif durability_pct < 0.50:
		scale = 0.75
	for stat_name: String in core_bonus_stats:
		var bonus: float = float(core_bonus_stats[stat_name]) * scale
		base[stat_name] = float(base.get(stat_name, 0.0)) + bonus
	return base
