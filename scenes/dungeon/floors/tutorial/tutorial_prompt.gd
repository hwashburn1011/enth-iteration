extends RoomBase
## Tutorial: combat at 50% health, learn to use prompts.

var _enemies_killed: int = 0


func _ready() -> void:
	room_type = "combat"
	is_cleared = false
	super._ready()
	TutorialManager.start_prompt_hint()
	EventBus.enemy_defeated.connect(_on_enemy_killed)

	var player: Player = _find_player()
	if player:
		player.health_component.current_health = player.health_component.max_health * 0.5
		player.health_component.health_changed.emit(
			player.health_component.current_health,
			player.health_component.max_health
		)

	for i: int in 2:
		var enemy: CharacterBody3D = EnemyPool.get_enemy("glitch_bug")
		if enemy:
			var offset: Vector3 = Vector3(-2.0 + i * 4.0, 0, -3)
			enemy.global_position = global_position + offset
			if enemy is EnemyBase:
				(enemy as EnemyBase).spawn_position = enemy.global_position
			enemy.reparent(get_tree().current_scene)


func _on_enemy_killed(_type: StringName, _pos: Vector3, _loot: Resource) -> void:
	_enemies_killed += 1
	if _enemies_killed >= 2:
		is_cleared = true
		room_cleared.emit()
		EventBus.enemy_defeated.disconnect(_on_enemy_killed)


func _find_player() -> Player:
	var nodes: Array[Node] = get_tree().get_nodes_in_group(&"player")
	if nodes.size() > 0:
		return nodes[0] as Player
	return null
