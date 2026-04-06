class_name ItemRegistry
extends RefCounted
## Maps item_id strings to base ItemBase resources for deserialization.

static var _registry: Dictionary = {}
static var _initialized: bool = false

const ITEM_PATHS: Dictionary = {
	"chip_overclocker": "res://data/items/chips/chip_overclocker.tres",
	"chip_firewall": "res://data/items/chips/chip_firewall.tres",
	"chip_bandwidth_booster": "res://data/items/chips/chip_bandwidth_booster.tres",
	"module_logic_bomb": "res://data/items/modules/module_logic_bomb.tres",
	"module_packet_storm": "res://data/items/modules/module_packet_storm.tres",
	"module_defrag_pulse": "res://data/items/modules/module_defrag_pulse.tres",
	"core_standard_cpu": "res://data/items/cores/core_standard_cpu.tres",
	"core_overtuned_gpu": "res://data/items/cores/core_overtuned_gpu.tres",
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
		var res: ItemBase = load(ITEM_PATHS[item_id]) as ItemBase
		if res:
			_registry[item_id] = res
		else:
			push_warning("ItemRegistry: failed to load '%s'" % item_id)
	_initialized = true


static func get_base_item(item_id: String) -> ItemBase:
	_ensure_initialized()
	return _registry.get(item_id) as ItemBase


static func create_item(item_id: String, durability: float = -1.0, stat_mods: Dictionary = {}, rarity: int = -1) -> ItemBase:
	var base: ItemBase = get_base_item(item_id)
	if base == null:
		push_error("ItemRegistry: unknown item_id '%s'" % item_id)
		return null
	var item: ItemBase = base.duplicate(true) as ItemBase
	if durability >= 0.0:
		item.current_durability = durability
	if not stat_mods.is_empty():
		item.stat_modifiers = stat_mods
	if rarity >= 0:
		item.rarity = rarity
	return item
