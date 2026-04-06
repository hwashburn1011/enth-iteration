class_name EnemyIdleState
extends "res://scripts/state_machines/state.gd"
## Enemy stands idle for a duration, then patrols.

const IDLE_TIME: float = 2.0

var _timer: float = 0.0


func enter() -> void:
	_timer = 0.0
	var enemy: CharacterBody3D = player as CharacterBody3D
	if enemy and enemy.animation_player.has_animation(&"idle"):
		enemy.animation_player.play(&"idle")


func physics_update(delta: float) -> void:
	var enemy: CharacterBody3D = player as CharacterBody3D
	_timer += delta

	# Aggro if player detected
	if enemy.target_player != null:
		state_machine.transition_to(state_machine.get_node("EnemyChaseState") as Node)
		return

	if _timer >= IDLE_TIME:
		state_machine.transition_to(state_machine.get_node("EnemyPatrolState") as Node)
