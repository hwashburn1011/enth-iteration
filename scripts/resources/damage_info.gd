class_name DamageInfo
extends Resource
## Data container for damage events passed through the damage pipeline.

@export var source: Node
@export var base_damage: float = 0.0
@export var damage_type: StringName = &"data"
@export var status_effect: Resource = null
