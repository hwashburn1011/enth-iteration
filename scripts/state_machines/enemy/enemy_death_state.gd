class_name EnemyDeathState
extends State
## Enemy dies — play animation, emit event, queue_free.

var can_be_interrupted: bool = false


func enter() -> void:
	var enemy: EnemyBase = player as EnemyBase

	if enemy.animation_player.has_animation(&"death"):
		enemy.animation_player.play(&"death")

	# Disable collision and processing
	enemy.collision_layer = 0
	enemy.collision_mask = 0
	enemy.set_physics_process(false)
	enemy.hitbox_component.deactivate()

	EventBus.enemy_defeated.emit(
		StringName(enemy.name),
		enemy.global_position,
		null  # loot_table filled in by specific enemy types
	)

	# Wait for death animation then free
	if enemy.animation_player.has_animation(&"death"):
		await enemy.animation_player.animation_finished
	enemy.queue_free()
