class_name CombatRoomBase
extends RoomBase
## Combat room that blocks exit until enemies are cleared.

@onready var exit_barrier: ExitBarrier = get_node_or_null("ExitBarrier") as ExitBarrier
@onready var enemy_spawner: EnemySpawner = get_node_or_null("EnemySpawner") as EnemySpawner


func _ready() -> void:
	room_type = "combat"
	is_cleared = false
	super._ready()

	if enemy_spawner:
		enemy_spawner.all_enemies_defeated.connect(_on_room_cleared)


func start_encounter() -> void:
	if enemy_spawner:
		enemy_spawner.spawn_wave()


func _on_room_cleared() -> void:
	is_cleared = true
	if exit_barrier:
		exit_barrier.open()
	room_cleared.emit()
