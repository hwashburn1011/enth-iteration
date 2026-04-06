class_name BossArena
extends "res://scenes/dungeon/rooms/room_base.gd"
## Boss arena — large room with destructible pillars. Spawns portal on boss defeat.

var _boss_defeated: bool = false


func _ready() -> void:
	room_type = "combat"
	is_cleared = false
	super._ready()
	EventBus.enemy_defeated.connect(_on_boss_defeated)


func _on_boss_defeated(_type: StringName, _pos: Vector3, _loot: Resource) -> void:
	if _boss_defeated:
		return
	_boss_defeated = true
	is_cleared = true
	room_cleared.emit()

	# Spawn compaction portal at center
	var portal_scene: PackedScene = load("res://scenes/dungeon/interactables/CompactionPortal.tscn") as PackedScene
	if portal_scene:
		var portal: Node3D = portal_scene.instantiate() as Node3D
		portal.global_position = global_position
		add_child(portal)

	EventBus.enemy_defeated.disconnect(_on_boss_defeated)
