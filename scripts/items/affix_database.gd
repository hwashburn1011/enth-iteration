class_name AffixDatabase
extends Resource
## Collection of all possible affixes that can roll on items.

@export var affixes: Array[AffixDefinition] = []


func get_eligible_affixes(rarity: int, item_type: String) -> Array[AffixDefinition]:
	var eligible: Array[AffixDefinition] = []
	for affix: AffixDefinition in affixes:
		if affix.min_rarity > rarity:
			continue
		if affix.allowed_item_types.size() > 0 and item_type not in affix.allowed_item_types:
			continue
		eligible.append(affix)
	return eligible
