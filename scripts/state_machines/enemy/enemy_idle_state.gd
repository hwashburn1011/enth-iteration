class_name EnemyIdleState
extends State
## Enemy stands idle for a duration, then patrols.

const IDLE_TIME: float = 2.0

var _timer: float = 0.0


func enter() -> void:
	_timer = 0.0
	var enemy: EnemyBase = player as EnemyBase
	if enemy and enemy.animation_player.has_animation(&"idle"):
		enemy.animation_player.play(&"idle")


func physics_update(delta: float) -> void:
	var enemy: EnemyBase = player as EnemyBase
	_timer += delta

	# Aggro if player detected
	if enemy.target_player != null:
		state_machine.transition_to(state_machine.get_node("EnemyChaseState") as State)
		return

	if _timer >= IDLE_TIME:
		state_machine.transition_to(state_machine.get_node("EnemyPatrolState") as State)
