class_name ChipItem
extends ItemBase
## Passive stat-boosting chip — slotted for permanent bonuses.

@export var chip_slot_type: String = "passive"  # "offense", "defense", "utility", "passive"
@export var passive_effect: String = ""


func _init() -> void:
	item_type = "chip"
