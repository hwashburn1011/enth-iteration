class_name CoreItem
extends ItemBase
## Build-defining core — unique passive effect that shapes playstyle.

@export var core_passive: String = ""
@export var core_bonus_stats: Dictionary = {}


func _init() -> void:
	item_type = "core"
