class_name ProtocolItem
extends ItemBase
## Conditional trigger protocol — fires an effect on specific events.

@export var protocol_effect: String = ""
@export var protocol_trigger: String = "on_hit"  # "on_hit", "on_kill", "on_dash"


func _init() -> void:
	item_type = "protocol"
