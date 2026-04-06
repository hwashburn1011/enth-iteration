extends RoomBase
## Tutorial: kill a single weak Glitch Bug.

var _overlay: TutorialOverlay = null


func _ready() -> void:
	room_type = "combat"
	is_cleared = false
	super._ready()
	_overlay = TutorialOverlay.new()
	_overlay.instruction_text = "Left click to attack with Data Pulse"
	add_child(_overlay)

	EventBus.enemy_defeated.connect(_on_enemy_killed)

	# Spawn a single weak glitch bug
	var enemy: CharacterBody3D = EnemyPool.get_enemy("glitch_bug")
	if enemy:
		enemy.get_node("HealthComponent").max_health = 10.0
		enemy.get_node("HealthComponent").current_health = 10.0
		var spawn: Marker3D = get_node_or_null("SpawnPoints/Spawn1") as Marker3D
		enemy.global_position = spawn.global_position if spawn else global_position + Vector3(0, 0, -3)
		if enemy is EnemyBase:
			(enemy as EnemyBase).spawn_position = enemy.global_position
		enemy.reparent(get_tree().current_scene)


func _on_enemy_killed(_type: StringName, _pos: Vector3, _loot: Resource) -> void:
	is_cleared = true
	room_cleared.emit()
	if _overlay:
		_overlay.dismiss()
	EventBus.enemy_defeated.disconnect(_on_enemy_killed)
