class_name ComputeComponent
extends Node
## Tracks compute (mana) resource for abilities.

signal compute_changed(new_value: float, max_value: float)
signal compute_depleted

@export var max_compute: float = 50.0
var current_compute: float


func _ready() -> void:
	current_compute = max_compute


func spend(amount: float) -> bool:
	return false


func restore(amount: float) -> void:
	pass
