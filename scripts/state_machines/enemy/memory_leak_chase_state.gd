class_name MemoryLeakChaseState
extends "res://scripts/state_machines/enemy/enemy_chase_state.gd"
## Memory Leak flees if player is too close (< 4.0 units).

const FLEE_DISTANCE: float = 4.0


func physics_update(delta: float) -> void:
	var enemy = player

	if enemy.target_player == null:
		_leash_timer += delta
		if _leash_timer >= enemy.leash_time:
			state_machine.transition_to(state_machine.get_node("EnemyPatrolState") as Node)
			return
	else:
		_leash_timer = 0.0
		var dist: float = enemy.global_position.distance_to(enemy.target_player.global_position)

		# Attack if in range
		if dist <= enemy.attack_range:
			state_machine.transition_to(state_machine.get_node("EnemyAttackState") as Node)
			return

		# Flee if too close
		if dist < FLEE_DISTANCE:
			var flee_dir: Vector3 = (enemy.global_position - enemy.target_player.global_position).normalized()
			flee_dir.y = 0.0
			enemy.velocity = flee_dir * enemy.move_speed
			enemy.move_and_slide()
			if flee_dir.length() > 0.1:
				enemy.model.rotation.y = lerp_angle(enemy.model.rotation.y, atan2(flee_dir.x, flee_dir.z), 10.0 * delta)
			return

		# Otherwise chase normally
		enemy.navigation_agent.target_position = enemy.target_player.global_position

	if enemy.navigation_agent.is_navigation_finished():
		return

	var next_pos: Vector3 = enemy.navigation_agent.get_next_path_position()
	var direction: Vector3 = (next_pos - enemy.global_position).normalized()
	direction.y = 0.0
	enemy.velocity = direction * enemy.move_speed
	enemy.move_and_slide()

	if direction.length() > 0.1:
		enemy.model.rotation.y = lerp_angle(enemy.model.rotation.y, atan2(direction.x, direction.z), 10.0 * delta)
