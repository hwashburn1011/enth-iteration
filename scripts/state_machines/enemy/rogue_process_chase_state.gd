class_name RogueProcessChaseState
extends "res://scripts/state_machines/enemy/enemy_chase_state.gd"
## Rogue Process chases with erratic zigzag movement.

var _zigzag_timer: float = 0.0


func enter() -> void:
	super.enter()
	_zigzag_timer = 0.0


func physics_update(delta: float) -> void:
	var enemy = player
	_zigzag_timer += delta

	if enemy.target_player == null:
		_leash_timer += delta
		if _leash_timer >= enemy.leash_time:
			state_machine.transition_to(state_machine.get_node("EnemyPatrolState") as Node)
			return
	else:
		_leash_timer = 0.0
		enemy.navigation_agent.target_position = enemy.target_player.global_position

		var dist: float = enemy.global_position.distance_to(enemy.target_player.global_position)
		if dist <= enemy.attack_range:
			state_machine.transition_to(state_machine.get_node("EnemyAttackState") as Node)
			return

	if enemy.navigation_agent.is_navigation_finished():
		return

	var next_pos: Vector3 = enemy.navigation_agent.get_next_path_position()
	var direction: Vector3 = (next_pos - enemy.global_position).normalized()
	direction.y = 0.0

	# Apply sinusoidal zigzag perpendicular to chase direction
	var perp: Vector3 = Vector3(-direction.z, 0.0, direction.x)
	var zigzag_offset: float = sin(_zigzag_timer * 6.0) * 0.5
	var final_dir: Vector3 = (direction + perp * zigzag_offset).normalized()

	enemy.velocity = final_dir * enemy.move_speed
	enemy.move_and_slide()

	if direction.length() > 0.1:
		enemy.model.rotation.y = lerp_angle(enemy.model.rotation.y, atan2(direction.x, direction.z), 10.0 * delta)
