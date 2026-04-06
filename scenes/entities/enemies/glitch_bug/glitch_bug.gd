class_name GlitchBug
extends "res://scenes/entities/enemies/enemy_base.gd"
## Fast melee enemy — teaches basic combat. Small, red, aggressive.

const XP_REWARD: int = 10


func _ready() -> void:
	super._ready()
	# Override base stats
	health_component.max_health = 30.0
	health_component.current_health = 30.0
	stats_component.base_processing = 5.0
	stats_component.base_bandwidth = 4.0
	stats_component.base_memory = 0.0
	stats_component.base_integrity = 2.0


func _on_died() -> void:
	EventBus.enemy_defeated.emit(
		&"glitch_bug",
		global_position,
		null  # loot table populated in Epic 4
	)
	var death_state: Node = state_machine.get_node_or_null("EnemyDeathState") as Node
	if death_state:
		state_machine.force_transition_to(death_state)
