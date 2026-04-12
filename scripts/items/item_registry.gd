class_name ItemRegistry
extends RefCounted
## Maps item_id strings to base item resources for deserialization.

static var _registry: Dictionary = {}
static var _initialized: bool = false

const ITEM_PATHS: Dictionary = {
	"chip_overclocker": "res://data/items/chips/chip_overclocker.tres",
	"chip_firewall": "res://data/items/chips/chip_firewall.tres",
	"chip_bandwidth_booster": "res://data/items/chips/chip_bandwidth_booster.tres",
	# Phase 3 #29 — chip roster expansion (3 → 8). Two of the new chips
	# carry moveset-altering passives (Kinetic Dash damages enemies in
	# the dash path; Counterstrike turns parries into AoE Fragmented).
	# The other three are pure stat sticks for the assault / utility /
	# tank build axes.
	"chip_kinetic_dash": "res://data/items/chips/chip_kinetic_dash.tres",
	"chip_counterstrike": "res://data/items/chips/chip_counterstrike.tres",
	"chip_assault_processor": "res://data/items/chips/chip_assault_processor.tres",
	"chip_threat_analyzer": "res://data/items/chips/chip_threat_analyzer.tres",
	"chip_armor_plating": "res://data/items/chips/chip_armor_plating.tres",
	"module_logic_bomb": "res://data/items/modules/module_logic_bomb.tres",
	"module_packet_storm": "res://data/items/modules/module_packet_storm.tres",
	"module_defrag_pulse": "res://data/items/modules/module_defrag_pulse.tres",
	# Phase 3 #27 — module roster expansion (5 new modules taking the
	# active-ability roster from 3 to 8). Each one shares the inline
	# dispatch path in ability_manager.gd; no ability_scene field needed.
	"module_fork_bomb": "res://data/items/modules/module_fork_bomb.tres",
	"module_garbage_collect": "res://data/items/modules/module_garbage_collect.tres",
	"module_recursion": "res://data/items/modules/module_recursion.tres",
	"module_deadlock": "res://data/items/modules/module_deadlock.tres",
	"module_refactor": "res://data/items/modules/module_refactor.tres",
	"core_standard_cpu": "res://data/items/cores/core_standard_cpu.tres",
	"core_overtuned_gpu": "res://data/items/cores/core_overtuned_gpu.tres",
	# Phase 3 #28 — core roster expansion (2 → 5). Each new core
	# carries a bespoke effect (compute_on_kill, dash_cooldown_reduction)
	# or a distinct stat profile beyond the standard/GPU axes.
	"core_quantum_processor": "res://data/items/cores/core_quantum_processor.tres",
	"core_volatile_compiler": "res://data/items/cores/core_volatile_compiler.tres",
	"core_persistent_thread": "res://data/items/cores/core_persistent_thread.tres",
	"protocol_on_kill_heal": "res://data/items/protocols/protocol_on_kill_heal.tres",
	"protocol_dash_damage": "res://data/items/protocols/protocol_dash_damage.tres",
	"prompt_health_small": "res://data/items/prompts/prompt_health_small.tres",
	"prompt_compute_small": "res://data/items/prompts/prompt_compute_small.tres",
	"prompt_overclock": "res://data/items/prompts/prompt_overclock.tres",
}


static func _ensure_initialized() -> void:
	if _initialized:
		return
	for item_id: String in ITEM_PATHS:
		var res: Resource = load(ITEM_PATHS[item_id])
		if res:
			_registry[item_id] = res
		else:
			push_warning("ItemRegistry: failed to load '%s'" % item_id)
	_initialized = true


static func get_base_item(item_id: String) -> Resource:
	_ensure_initialized()
	return _registry.get(item_id)


static func create_item(item_id: String, durability: float = -1.0, stat_mods: Dictionary = {}, rarity: int = -1) -> Resource:
	var base: Resource = get_base_item(item_id)
	if base == null:
		push_error("ItemRegistry: unknown item_id '%s'" % item_id)
		return null
	var item: Resource = base.duplicate(true)
	if durability >= 0.0:
		item.set(&"current_durability", durability)
	if not stat_mods.is_empty():
		item.set(&"stat_modifiers", stat_mods)
	if rarity >= 0:
		item.set(&"rarity", rarity)
	return item
