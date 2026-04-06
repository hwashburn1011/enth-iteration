class_name EnemyPatrolState
extends State
## Enemy wanders to a random point within patrol_radius.

var _arrived: bool = false


func enter() -> void:
	_arrived = false
	var enemy: EnemyBase = player as EnemyBase
	if enemy and enemy.animation_player.has_animation(&"walk"):
		enemy.animation_player.play(&"walk")

	# Pick a random patrol target
	var offset: Vector3 = Vector3(
		randf_range(-enemy.patrol_radius, enemy.patrol_radius),
		0.0,
		randf_range(-enemy.patrol_radius, enemy.patrol_radius)
	)
	enemy.navigation_agent.target_position = enemy.spawn_position + offset


func physics_update(delta: float) -> void:
	var enemy: EnemyBase = player as EnemyBase

	# Aggro if player detected
	if enemy.target_player != null:
		state_machine.transition_to(state_machine.get_node("EnemyChaseState") as State)
		return

	if enemy.navigation_agent.is_navigation_finished():
		state_machine.transition_to(state_machine.get_node("EnemyIdleState") as State)
		return

	var next_pos: Vector3 = enemy.navigation_agent.get_next_path_position()
	var direction: Vector3 = (next_pos - enemy.global_position).normalized()
	direction.y = 0.0
	enemy.velocity = direction * enemy.move_speed
	enemy.move_and_slide()

	# Rotate model
	if direction.length() > 0.1:
		var target_angle: float = atan2(direction.x, direction.z)
		enemy.model.rotation.y = lerp_angle(enemy.model.rotation.y, target_angle, 10.0 * delta)
