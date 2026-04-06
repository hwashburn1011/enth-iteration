class_name EnemySpawner
extends Node3D
## Spawns enemies from the pool at designated spawn points.

signal all_enemies_defeated

@export var enemy_types: Array[String] = []
@export var spawn_count: int = 3
@export var spawn_points: Array[Marker3D] = []

var _alive_count: int = 0


func spawn_wave() -> void:
	_alive_count = 0
	for i: int in spawn_count:
		var type: String = enemy_types[i % enemy_types.size()]
		var enemy: CharacterBody3D = EnemyPool.get_enemy(type)
		if enemy == null:
			push_warning("EnemySpawner: could not get enemy of type '%s'" % type)
			continue

		# Position at spawn point
		if spawn_points.size() > 0:
			var point: Marker3D = spawn_points[i % spawn_points.size()]
			enemy.global_position = point.global_position
		else:
			enemy.global_position = global_position + Vector3(randf_range(-3.0, 3.0), 0.0, randf_range(-3.0, 3.0))

		if enemy is EnemyBase:
			(enemy as EnemyBase).spawn_position = enemy.global_position

		# Reparent to current scene if needed
		if enemy.get_parent() != get_tree().current_scene:
			enemy.reparent(get_tree().current_scene)

		_alive_count += 1

	# Listen for enemy deaths
	if not EventBus.enemy_defeated.is_connected(_on_enemy_defeated):
		EventBus.enemy_defeated.connect(_on_enemy_defeated)


func _on_enemy_defeated(_enemy_type: StringName, _position: Vector3, _loot_table: Resource) -> void:
	_alive_count -= 1
	if _alive_count <= 0:
		_alive_count = 0
		all_enemies_defeated.emit()
		if EventBus.enemy_defeated.is_connected(_on_enemy_defeated):
			EventBus.enemy_defeated.disconnect(_on_enemy_defeated)
