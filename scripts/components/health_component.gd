class_name HealthComponent
extends Node
## Tracks health, emits signals on change and death.

signal health_changed(new_value: float, max_value: float)
signal died

@export var max_health: float = 100.0
var current_health: float
var is_dead: bool = false


func _ready() -> void:
	current_health = max_health


func take_damage(amount: float) -> void:
	if is_dead:
		return
	# Check invulnerability on parent if it has the property
	var parent: Node = get_parent()
	if parent and &"is_invulnerable" in parent and parent.is_invulnerable:
		return
	current_health = maxf(0.0, current_health - amount)
	health_changed.emit(current_health, max_health)
	if current_health <= 0.0 and not is_dead:
		is_dead = true
		died.emit()
		if parent.is_in_group(&"player"):
			EventBus.player_died.emit(parent.global_position if parent is Node3D else Vector3.ZERO)


func heal(amount: float) -> void:
	if is_dead:
		return
	current_health = minf(max_health, current_health + amount)
	health_changed.emit(current_health, max_health)
	# Heal VFX
	var parent: Node = get_parent()
	if parent is Node3D:
		VFXFactory.spawn_heal_particles((parent as Node3D).global_position, parent.get_tree().current_scene)


func reset() -> void:
	current_health = max_health
	is_dead = false
	health_changed.emit(current_health, max_health)


func get_health_percentage() -> float:
	if max_health <= 0.0:
		return 0.0
	return current_health / max_health
