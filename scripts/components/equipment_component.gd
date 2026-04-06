class_name EquipmentComponent
extends Node
## Manages equipped items in typed slot arrays. Triggers stat recalculation on change.

signal equipment_changed

var module_slots: Array[ModuleItem] = [null, null, null, null]
var core_slot: CoreItem = null
var chip_slots: Array[ChipItem] = [null, null, null, null]
var protocol_slots: Array[ProtocolItem] = [null, null, null]

var _stats_component: StatsComponent = null
var _ability_manager: Node = null


func _ready() -> void:
	_stats_component = get_parent().get_node_or_null("StatsComponent") as StatsComponent
	_ability_manager = get_parent().get_node_or_null("AbilityManager")


func equip(item: ItemBase, slot_index: int = -1) -> ItemBase:
	var previous: ItemBase = null

	match item.item_type:
		"module":
			var module: ModuleItem = item as ModuleItem
			var idx: int = slot_index if slot_index >= 0 and slot_index < 4 else _first_empty_slot_index(module_slots)
			if idx < 0:
				idx = 0
			previous = module_slots[idx]
			module_slots[idx] = module

		"core":
			previous = core_slot
			core_slot = item as CoreItem

		"chip":
			var chip: ChipItem = item as ChipItem
			var idx: int = slot_index if slot_index >= 0 and slot_index < 4 else _first_empty_slot_index(chip_slots)
			if idx < 0:
				idx = 0
			previous = chip_slots[idx]
			chip_slots[idx] = chip

		"protocol":
			var protocol: ProtocolItem = item as ProtocolItem
			var idx: int = slot_index if slot_index >= 0 and slot_index < 3 else _first_empty_slot_index(protocol_slots)
			if idx < 0:
				idx = 0
			previous = protocol_slots[idx]
			protocol_slots[idx] = protocol

		_:
			push_warning("EquipmentComponent: cannot equip item_type '%s'" % item.item_type)
			return null

	_on_equipment_changed()
	return previous


func unequip(item_type: String, slot_index: int) -> ItemBase:
	var removed: ItemBase = null

	match item_type:
		"module":
			if slot_index >= 0 and slot_index < 4:
				removed = module_slots[slot_index]
				module_slots[slot_index] = null
		"core":
			removed = core_slot
			core_slot = null
		"chip":
			if slot_index >= 0 and slot_index < 4:
				removed = chip_slots[slot_index]
				chip_slots[slot_index] = null
		"protocol":
			if slot_index >= 0 and slot_index < 3:
				removed = protocol_slots[slot_index]
				protocol_slots[slot_index] = null

	if removed:
		_on_equipment_changed()
	return removed


func get_all_equipped_items() -> Array[ItemBase]:
	var items: Array[ItemBase] = []
	for m: ModuleItem in module_slots:
		if m != null:
			items.append(m)
	if core_slot != null:
		items.append(core_slot)
	for c: ChipItem in chip_slots:
		if c != null:
			items.append(c)
	for p: ProtocolItem in protocol_slots:
		if p != null:
			items.append(p)
	return items


func _on_equipment_changed() -> void:
	if _stats_component:
		_stats_component.recalculate_equipment_bonuses(get_all_equipped_items())
	# Notify AbilityManager about module changes
	if _ability_manager and _ability_manager.has_method(&"refresh_abilities"):
		_ability_manager.refresh_abilities(module_slots)
	equipment_changed.emit()


func _first_empty_slot_index(slots: Array) -> int:
	for i: int in slots.size():
		if slots[i] == null:
			return i
	return -1
