class_name PlayerDeathState
extends "res://scripts/state_machines/state.gd"
## Player has died — play death animation, disable everything, wait for respawn.

func _ready() -> void:
	can_be_interrupted = false


func enter() -> void:
	var p: CharacterBody3D = player as CharacterBody3D

	if p.animation_player.has_animation(&"death"):
		p.animation_player.play(&"death")

	# Disable all input processing and collision
	p.set_physics_process(false)
	p.set_process_unhandled_input(false)
	p.collision_layer = 0
	p.collision_mask = 0

	# EventBus notification (HealthComponent also emits this, but ensure it fires)
	if not p.health_component.is_dead:
		EventBus.player_died.emit(p.global_position)


func exit() -> void:
	var p: CharacterBody3D = player as CharacterBody3D
	# Re-enable when respawn system transitions out of DeathState
	p.set_physics_process(true)
	p.set_process_unhandled_input(true)
	p.collision_layer = 1
	p.collision_mask = 138
