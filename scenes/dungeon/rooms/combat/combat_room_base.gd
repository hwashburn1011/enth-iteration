class_name CombatRoomBase
extends "res://scenes/dungeon/rooms/room_base.gd"
## Combat room that blocks exit until enemies are cleared.

@onready var exit_barrier: Node = get_node_or_null("ExitBarrier") as Node
@onready var enemy_spawner: Node = get_node_or_null("EnemySpawner") as Node


func _ready() -> void:
	room_type = "combat"
	is_cleared = false
	super._ready()

	if enemy_spawner:
		_bind_spawn_points_to_spawner()
		enemy_spawner.all_enemies_defeated.connect(_on_room_cleared)


func _bind_spawn_points_to_spawner() -> void:
	## Auto-wire any "SpawnPoints" child Marker3Ds into the EnemySpawner so the
	## hand-placed markers are actually used. Without this the spawner falls
	## back to a random ±3m blob around its own origin (latent bug since the
	## first combat rooms shipped — markers were placed but never bound).
	var holder: Node = get_node_or_null("SpawnPoints")
	if holder == null:
		return
	var points: Array[Marker3D] = []
	for child: Node in holder.get_children():
		if child is Marker3D:
			points.append(child as Marker3D)
	if points.size() > 0:
		enemy_spawner.spawn_points = points


func start_encounter() -> void:
	if enemy_spawner:
		enemy_spawner.spawn_wave()


func _on_room_cleared() -> void:
	is_cleared = true
	if exit_barrier:
		exit_barrier.open()
	room_cleared.emit()
	_show_exit_indicator()
