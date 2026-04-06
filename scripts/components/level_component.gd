class_name LevelComponent
extends Node
## Tracks XP, levels, and unspent stat points.

signal leveled_up(new_level: int)
signal xp_changed(current_xp: int, xp_to_next: int)

@export var xp_per_level_base: int = 100
@export var stat_points_per_level: int = 3

var current_level: int = 1
var current_xp: int = 0
var xp_to_next_level: int = 100
var unspent_stat_points: int = 0


func _ready() -> void:
	xp_to_next_level = xp_per_level_base * current_level
	EventBus.enemy_defeated.connect(_on_enemy_defeated)


func add_xp(amount: int) -> void:
	current_xp += amount
	while current_xp >= xp_to_next_level:
		current_xp -= xp_to_next_level
		current_level += 1
		xp_to_next_level = xp_per_level_base * current_level
		unspent_stat_points += stat_points_per_level
		leveled_up.emit(current_level)
	xp_changed.emit(current_xp, xp_to_next_level)


func _on_enemy_defeated(enemy_type: StringName, _pos: Vector3, _loot: Resource) -> void:
	# XP rewards by enemy type
	var xp: int = 10
	match String(enemy_type):
		"glitch_bug":
			xp = 10
		"memory_leak":
			xp = 15
		"rogue_process":
			xp = 20
		_:
			xp = 10
	add_xp(xp)
