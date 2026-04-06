class_name EnemySpawner
extends Node3D
## Spawns enemies from the pool at designated spawn points. Supports multi-wave encounters.

signal all_enemies_defeated

@export var enemy_types: Array[String] = []
@export var spawn_count: int = 3
@export var spawn_points: Array[Marker3D] = []
@export var waves: Array[Resource] = []

var _alive_count: int = 0
var _current_wave: int = 0
var _using_waves: bool = false


func spawn_wave() -> void:
	if waves.size() > 0:
		_using_waves = true
		_current_wave = 0
		_spawn_wave_data(waves[0])
	else:
		_using_waves = false
		_spawn_from_config(enemy_types, spawn_count)


func _spawn_from_config(types: Array[String], count: int) -> void:
	_alive_count = 0
	for i: int in count:
		var type: String = types[i % types.size()]
		var enemy: CharacterBody3D = EnemyPool.get_enemy(type)
		if enemy == null:
			push_warning("EnemySpawner: could not get enemy of type '%s'" % type)
			continue

		if spawn_points.size() > 0:
			var point: Marker3D = spawn_points[i % spawn_points.size()]
			enemy.global_position = point.global_position
		else:
			enemy.global_position = global_position + Vector3(randf_range(-3.0, 3.0), 0.0, randf_range(-3.0, 3.0))

		if enemy.is_in_group(&"enemies"):
			(enemy as CharacterBody3D).spawn_position = enemy.global_position

		if enemy.get_parent() != get_tree().current_scene:
			enemy.reparent(get_tree().current_scene)

		_alive_count += 1

	if not EventBus.enemy_defeated.is_connected(_on_enemy_defeated):
		EventBus.enemy_defeated.connect(_on_enemy_defeated)


func _spawn_wave_data(wave: Resource) -> void:
	var types: Array[String] = []
	for t: String in wave.enemy_types:
		types.append(t)
	_spawn_from_config(types, wave.spawn_count)


func _on_enemy_defeated(_enemy_type: StringName, _position: Vector3, _loot_table: Resource) -> void:
	_alive_count -= 1
	if _alive_count <= 0:
		_alive_count = 0
		if _using_waves:
			_current_wave += 1
			if _current_wave < waves.size():
				_spawn_wave_data(waves[_current_wave])
				return
		# All waves / single wave complete
		all_enemies_defeated.emit()
		if EventBus.enemy_defeated.is_connected(_on_enemy_defeated):
			EventBus.enemy_defeated.disconnect(_on_enemy_defeated)
