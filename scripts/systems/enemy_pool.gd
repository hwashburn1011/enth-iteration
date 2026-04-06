class_name EnemyPool
extends Node
## Object pool for enemies — pre-instantiates and recycles to avoid allocation spikes.

@export var pool_sizes: Dictionary = {
	"glitch_bug": 10,
	"memory_leak": 5,
	"rogue_process": 5,
}

const ENEMY_SCENES: Dictionary = {
	"glitch_bug": "res://scenes/entities/enemies/glitch_bug/GlitchBug.tscn",
	"memory_leak": "res://scenes/entities/enemies/memory_leak/MemoryLeak.tscn",
	"rogue_process": "res://scenes/entities/enemies/rogue_process/RogueProcess.tscn",
	"corrupted_compiler": "res://scenes/entities/enemies/corrupted_compiler/CorruptedCompiler.tscn",
}

var _pools: Dictionary = {}  # type -> Array[CharacterBody3D]
var _active: Dictionary = {}  # type -> Array[CharacterBody3D]


func _ready() -> void:
	for enemy_type: String in pool_sizes:
		_pools[enemy_type] = [] as Array[CharacterBody3D]
		_active[enemy_type] = [] as Array[CharacterBody3D]
		var scene_path: String = ENEMY_SCENES.get(enemy_type, "") as String
		if scene_path.is_empty():
			push_error("EnemyPool: unknown enemy type '%s'" % enemy_type)
			continue
		var scene: PackedScene = load(scene_path) as PackedScene
		for i: int in pool_sizes[enemy_type]:
			var enemy: CharacterBody3D = scene.instantiate() as CharacterBody3D
			_deactivate(enemy)
			add_child(enemy)
			(_pools[enemy_type] as Array).append(enemy)


func get_enemy(type: String) -> CharacterBody3D:
	if type not in _pools:
		_pools[type] = []
		_active[type] = []

	var pool: Array = _pools[type] as Array
	var enemy: CharacterBody3D = null

	if pool.size() > 0:
		enemy = pool.pop_back() as CharacterBody3D
	else:
		push_warning("EnemyPool: pool empty for '%s', instantiating new" % type)
		var scene_path: String = ENEMY_SCENES.get(type, "") as String
		if scene_path.is_empty():
			push_error("EnemyPool: no scene for type '%s'" % type)
			return null
		var scene: PackedScene = load(scene_path) as PackedScene
		enemy = scene.instantiate() as CharacterBody3D
		add_child(enemy)

	_activate(enemy)
	(_active[type] as Array).append(enemy)

	# Reset enemy state
	if enemy.has_method(&"reset"):
		enemy.reset()
	elif enemy.has_node("HealthComponent"):
		var health: HealthComponent = enemy.get_node("HealthComponent") as HealthComponent
		health.reset()

	return enemy


func return_enemy(enemy: CharacterBody3D) -> void:
	var enemy_type: String = _get_type(enemy)
	if enemy_type.is_empty():
		enemy.queue_free()
		return

	if enemy_type in _active:
		(_active[enemy_type] as Array).erase(enemy)
	if enemy_type not in _pools:
		_pools[enemy_type] = []
	(_pools[enemy_type] as Array).append(enemy)
	_deactivate(enemy)


func _activate(enemy: CharacterBody3D) -> void:
	enemy.visible = true
	enemy.set_process(true)
	enemy.set_physics_process(true)
	enemy.set_process_unhandled_input(true)
	enemy.collision_layer = 2
	enemy.collision_mask = 9


func _deactivate(enemy: CharacterBody3D) -> void:
	enemy.visible = false
	enemy.set_process(false)
	enemy.set_physics_process(false)
	enemy.set_process_unhandled_input(false)
	enemy.collision_layer = 0
	enemy.collision_mask = 0
	enemy.global_position = Vector3(9999.0, 9999.0, 9999.0)


func _get_type(enemy: CharacterBody3D) -> String:
	if enemy is GlitchBug:
		return "glitch_bug"
	elif enemy is MemoryLeak:
		return "memory_leak"
	elif enemy is RogueProcess:
		return "rogue_process"
	return ""
