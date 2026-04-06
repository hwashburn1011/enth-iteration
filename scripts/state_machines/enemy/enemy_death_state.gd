class_name EnemyDeathState
extends "res://scripts/state_machines/state.gd"
## Enemy dies — play animation, emit event, queue_free.

func _ready() -> void:
	can_be_interrupted = false


func enter() -> void:
	var enemy = player

	if enemy.animation_player.has_animation(&"death"):
		enemy.animation_player.play(&"death")

	# Disable collision and processing
	enemy.collision_layer = 0
	enemy.collision_mask = 0
	enemy.set_physics_process(false)
	enemy.hitbox_component.deactivate()

	# Drop loot before emitting defeat
	if enemy.loot_dropper:
		enemy.loot_dropper.drop_loot(enemy.global_position)

	EventBus.enemy_defeated.emit(
		StringName(enemy.name),
		enemy.global_position,
		enemy.loot_dropper.loot_table if enemy.loot_dropper else null
	)

	# Wait for death animation then return to pool
	if enemy.animation_player.has_animation(&"death"):
		await enemy.animation_player.animation_finished
	EnemyPool.return_enemy(enemy)
