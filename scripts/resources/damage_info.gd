class_name DamageInfo
extends Resource
## Data container for damage events passed through the damage pipeline.

var source: Node
var target: Node
var base_damage: float = 0.0
var damage_type: StringName = &"data"  # "data", "energy", "physical", "status"
var stat_multiplier: float = 0.0
var equipment_modifier: float = 0.0
var final_damage: float = 0.0
var is_critical: bool = false
var status_effect: Resource = null
var knockback_direction: Vector3 = Vector3.ZERO
var knockback_force: float = 0.0
