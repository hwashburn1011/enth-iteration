class_name HealthComponent
extends Node
## Tracks health, emits signals on change and death.

signal health_changed(new_value: float, max_value: float)
signal died

@export var max_health: float = 100.0
var current_health: float


func _ready() -> void:
	current_health = max_health


func take_damage(amount: float) -> void:
	pass


func heal(amount: float) -> void:
	pass
