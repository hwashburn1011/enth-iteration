class_name ChipItem
extends "res://scripts/items/item_base.gd"
## Passive stat-boosting chip — slotted for permanent bonuses.

@export var chip_slot_type: String = "passive"  # "offense", "defense", "utility", "passive"
@export var passive_effect: String = ""
## Phase 3 #29 — moveset-altering chip passives. The string is read by
## the consumer that owns the relevant moveset (player_dash_state for
## kinetic_dash, hurtbox_component for counterstrike, etc.). Default
## empty so existing chips no-op cleanly. EquipmentComponent exposes
## has_chip_passive(id) for fast lookup.
@export var passive_id: String = ""


func _init() -> void:
	item_type = "chip"
