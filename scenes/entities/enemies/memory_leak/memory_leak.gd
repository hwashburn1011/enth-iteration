class_name MemoryLeak
extends "res://scenes/entities/enemies/enemy_base.gd"
## Ranged enemy — fires slow projectiles that leave damaging pools.

const XP_REWARD: int = 15
const FLEE_DISTANCE: float = 4.0


func _ready() -> void:
	super._ready()
	health_component.max_health = 20.0
	health_component.current_health = 20.0
	stats_component.base_processing = 8.0
	stats_component.base_bandwidth = 2.0
	stats_component.base_memory = 0.0
	stats_component.base_integrity = 1.0


func _on_died() -> void:
	EventBus.enemy_defeated.emit(
		&"memory_leak",
		global_position,
		null
	)
	var death_state: Node = state_machine.get_node_or_null("EnemyDeathState") as Node
	if death_state:
		state_machine.force_transition_to(death_state)
