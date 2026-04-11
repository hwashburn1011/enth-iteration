extends "res://scenes/dungeon/rooms/room_base.gd"
## Tutorial: kill a single weak Glitch Bug.


func _ready() -> void:
	room_type = "combat"
	is_cleared = false
	super._ready()
	TutorialManager.start_combat_hint()
	EventBus.enemy_defeated.connect(_on_enemy_killed)

	var enemy: CharacterBody3D = EnemyPool.get_enemy("glitch_bug")
	if enemy:
		enemy.get_node("HealthComponent").max_health = 10.0
		enemy.get_node("HealthComponent").current_health = 10.0
		var spawn: Marker3D = get_node_or_null("SpawnPoints/Spawn1") as Marker3D
		enemy.global_position = spawn.global_position if spawn else global_position + Vector3(0, 0, -3)
		if enemy.is_in_group(&"enemies"):
			(enemy as CharacterBody3D).spawn_position = enemy.global_position
		enemy.reparent(get_tree().current_scene)


func _on_enemy_killed(_type: StringName, _pos: Vector3, _loot: Resource) -> void:
	is_cleared = true
	room_cleared.emit()
	_show_exit_indicator()
	EventBus.enemy_defeated.disconnect(_on_enemy_killed)
