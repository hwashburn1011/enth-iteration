class_name EnemyChaseState
extends "res://scripts/state_machines/state.gd"
## Enemy chases the player until within attack range or leash expires.

var _leash_timer: float = 0.0


func enter() -> void:
	_leash_timer = 0.0
	var enemy = player
	if enemy and enemy.animation_player.has_animation(&"walk"):
		enemy.animation_player.play(&"walk")


func physics_update(delta: float) -> void:
	var enemy = player

	if enemy.target_player == null:
		_leash_timer += delta
		if _leash_timer >= enemy.leash_time:
			state_machine.transition_to(state_machine.get_node("EnemyPatrolState") as Node)
			return
	else:
		_leash_timer = 0.0
		enemy.navigation_agent.target_position = enemy.target_player.global_position

		# Check attack range
		var dist: float = enemy.global_position.distance_to(enemy.target_player.global_position)
		if dist <= enemy.attack_range:
			state_machine.transition_to(state_machine.get_node("EnemyAttackState") as Node)
			return

	if enemy.navigation_agent.is_navigation_finished():
		return

	var next_pos: Vector3 = enemy.navigation_agent.get_next_path_position()
	var direction: Vector3 = (next_pos - enemy.global_position).normalized()
	direction.y = 0.0
	enemy.velocity = direction * enemy.move_speed
	enemy.move_and_slide()

	if direction.length() > 0.1:
		var target_angle: float = atan2(direction.x, direction.z)
		enemy.model.rotation.y = lerp_angle(enemy.model.rotation.y, target_angle, 10.0 * delta)
