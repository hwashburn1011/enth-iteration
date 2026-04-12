class_name EquipmentComponent
extends Node
## Manages equipped items in typed slot arrays. Triggers stat recalculation on change.

signal equipment_changed

var module_slots: Array[Resource] = [null, null, null, null]
var core_slot: Resource = null
var chip_slots: Array[Resource] = [null, null, null, null]
var protocol_slots: Array[Resource] = [null, null, null]

var _stats_component: Node = null
var _ability_manager: Node = null


func _ready() -> void:
	_stats_component = get_parent().get_node_or_null("StatsComponent") as Node
	_ability_manager = get_parent().get_node_or_null("AbilityManager")
	EventBus.item_degradation_triggered.connect(_on_degradation_triggered)


func equip(item: Resource, slot_index: int = -1) -> Resource:
	var previous: Resource = null

	match item.item_type:
		"module":
			var module: Resource = item as Resource
			var idx: int = slot_index if slot_index >= 0 and slot_index < 4 else _first_empty_slot_index(module_slots)
			if idx < 0:
				idx = 0
			previous = module_slots[idx]
			module_slots[idx] = module

		"core":
			previous = core_slot
			core_slot = item as Resource

		"chip":
			var chip: Resource = item as Resource
			var idx: int = slot_index if slot_index >= 0 and slot_index < 4 else _first_empty_slot_index(chip_slots)
			if idx < 0:
				idx = 0
			previous = chip_slots[idx]
			chip_slots[idx] = chip

		"protocol":
			var protocol: Resource = item as Resource
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


func unequip(item_type: String, slot_index: int) -> Resource:
	var removed: Resource = null

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


## Returns the item that WOULD be displaced if equip(item, slot_index) were
## called now, without mutating any slot. Use this to pre-check whether a
## swap would have somewhere to put the displaced item before committing.
## Mirrors the slot-selection logic of equip() exactly.
func peek_displaced(item: Resource, slot_index: int = -1) -> Resource:
	match item.item_type:
		"module":
			var idx: int = slot_index if slot_index >= 0 and slot_index < 4 else _first_empty_slot_index(module_slots)
			if idx < 0:
				idx = 0
			return module_slots[idx]
		"core":
			return core_slot
		"chip":
			var idx: int = slot_index if slot_index >= 0 and slot_index < 4 else _first_empty_slot_index(chip_slots)
			if idx < 0:
				idx = 0
			return chip_slots[idx]
		"protocol":
			var idx: int = slot_index if slot_index >= 0 and slot_index < 3 else _first_empty_slot_index(protocol_slots)
			if idx < 0:
				idx = 0
			return protocol_slots[idx]
	return null


func get_all_equipped_items() -> Array[Resource]:
	var items: Array[Resource] = []
	for m: Resource in module_slots:
		if m != null:
			items.append(m)
	if core_slot != null:
		items.append(core_slot)
	for c: Resource in chip_slots:
		if c != null:
			items.append(c)
	for p: Resource in protocol_slots:
		if p != null:
			items.append(p)
	return items


## Phase 3 #29 — chip passive lookup. Returns true if any equipped
## chip carries the given passive_id. Defensive against null slots
## and chips without the new field. Used by player_dash_state and
## hurtbox_component to gate moveset-altering passives.
func has_chip_passive(id: String) -> bool:
	if id == "":
		return false
	for c: Resource in chip_slots:
		if c == null:
			continue
		if not (&"passive_id" in c):
			continue
		if String(c.passive_id) == id:
			return true
	return false


func _on_equipment_changed() -> void:
	if _stats_component:
		_stats_component.recalculate_equipment_bonuses(get_all_equipped_items())
	# Notify AbilityManager about module changes
	if _ability_manager and _ability_manager.has_method(&"refresh_abilities"):
		_ability_manager.refresh_abilities(module_slots)
	# Task81: Apply equipment set bonuses when gear changes
	var equipped_ids: Array[String] = []
	for item: Resource in get_all_equipped_items():
		if item != null and "item_id" in item:
			equipped_ids.append(str(item.item_id))
	SetBonusRuntime.apply_set_bonuses(get_parent(), equipped_ids)
	equipment_changed.emit()


func _on_degradation_triggered() -> void:
	var all_items: Array[Resource] = get_all_equipped_items()
	if all_items.is_empty():
		return
	# Select 1-3 random items to degrade
	var count: int = mini(randi_range(1, 3), all_items.size())
	all_items.shuffle()
	for i: int in count:
		all_items[i].degrade(0.10)  # 10% of max durability
	# Recalculate stats with degraded modifiers
	_on_equipment_changed()


func _first_empty_slot_index(slots: Array) -> int:
	for i: int in slots.size():
		if slots[i] == null:
			return i
	return -1
