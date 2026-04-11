class_name OutfitFavorites
extends Resource

## Persistent storage for 3 saved outfit loadouts ("favorite looks").
## Each slot stores the item_ids equipped, plus dye choices.
## Resource so it can be embedded in the main save file.

const MAX_SLOTS: int = 3

## Each loadout: { slot_name(StringName) -> { "item_id": String, "dye_index": int } }
@export var loadouts: Array[Dictionary] = [{}, {}, {}]
@export var loadout_names: PackedStringArray = ["Loadout 1", "Loadout 2", "Loadout 3"]


func save_current(slot_index: int, equipment_dict: Dictionary, name: String = "") -> void:
	if slot_index < 0 or slot_index >= MAX_SLOTS:
		push_warning("OutfitFavorites: invalid slot %d" % slot_index)
		return
	var snapshot: Dictionary = {}
	for slot_name: StringName in equipment_dict.keys():
		var item: OutfitItem = equipment_dict[slot_name] as OutfitItem
		if item == null:
			continue
		snapshot[slot_name] = {
			"item_id": item.item_id,
			"dye_index": item.dye_index,
			"set_id": item.set_id,
		}
	loadouts[slot_index] = snapshot
	if name != "":
		loadout_names[slot_index] = name


func load_into(slot_index: int, equipment_component: Node, item_registry: Node) -> bool:
	if slot_index < 0 or slot_index >= MAX_SLOTS:
		return false
	var snapshot: Dictionary = loadouts[slot_index]
	if snapshot.is_empty():
		return false

	for slot_name: StringName in snapshot.keys():
		var entry: Dictionary = snapshot[slot_name]
		var item_id: String = entry.get("item_id", "")
		var dye_index: int = entry.get("dye_index", -1)
		if item_id == "":
			continue
		# Look up the item in the registry
		if item_registry != null and item_registry.has_method("get_item_by_id"):
			var item: OutfitItem = item_registry.get_item_by_id(item_id) as OutfitItem
			if item != null:
				if dye_index != -1:
					item.apply_dye(dye_index)
				if equipment_component != null and equipment_component.has_method("equip"):
					equipment_component.equip(slot_name, item)
	return true


func clear(slot_index: int) -> void:
	if slot_index < 0 or slot_index >= MAX_SLOTS:
		return
	loadouts[slot_index] = {}


func is_empty(slot_index: int) -> bool:
	if slot_index < 0 or slot_index >= MAX_SLOTS:
		return true
	return loadouts[slot_index].is_empty()
