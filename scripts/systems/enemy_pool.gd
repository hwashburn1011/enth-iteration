extends Node
## Object pool for enemies — pre-instantiates and recycles to avoid allocation spikes.

@export var pool_sizes: Dictionary = {
	"glitch_bug": 10,
	"memory_leak": 5,
	"rogue_process": 5,
	"corrupted_compiler": 1,
	"firewall_guardian": 3,
	"buffer_overflow": 5,
	"null_pointer": 3,
	"stack_crawler": 2,
	"syntax_error": 4,
}

const ENEMY_SCENES: Dictionary = {
	"glitch_bug": "res://scenes/entities/enemies/glitch_bug/GlitchBug.tscn",
	"memory_leak": "res://scenes/entities/enemies/memory_leak/MemoryLeak.tscn",
	"rogue_process": "res://scenes/entities/enemies/rogue_process/RogueProcess.tscn",
	"corrupted_compiler": "res://scenes/entities/enemies/corrupted_compiler/CorruptedCompiler.tscn",
	"firewall_guardian": "res://scenes/entities/enemies/firewall_guardian/FirewallGuardian.tscn",
	"buffer_overflow": "res://scenes/entities/enemies/buffer_overflow/BufferOverflow.tscn",
	"null_pointer": "res://scenes/entities/enemies/null_pointer/NullPointer.tscn",
	"stack_crawler": "res://scenes/entities/enemies/stack_crawler/StackCrawler.tscn",
	"syntax_error": "res://scenes/entities/enemies/syntax_error/SyntaxError.tscn",
}

var _pools: Dictionary = {}  # type -> Array[CharacterBody3D]
var _active: Dictionary = {}  # type -> Array[CharacterBody3D]
var _initialized: bool = false


func _ready() -> void:
	# Defer initialization to avoid loading scenes before class_names are registered
	call_deferred(&"_deferred_init")


func _deferred_init() -> void:
	if _initialized:
		return
	_initialized = true
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
			add_child(enemy)
			_deactivate(enemy)
			(_pools[enemy_type] as Array).append(enemy)


func _ensure_init() -> void:
	if not _initialized:
		_deferred_init()


func get_enemy(type: String) -> CharacterBody3D:
	_ensure_init()
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
		var health: Node = enemy.get_node("HealthComponent")
		if health.has_method(&"reset"):
			health.reset()

	# Re-apply iteration scaling on every activation. The pool was
	# warmed up at game launch with whatever iteration was current then,
	# so without this an enemy taken out of the pool stays locked to its
	# original iteration even after the player advances mid-session.
	# enemy_base._apply_iteration_scaling is idempotent — it captures the
	# baseline once and recomputes from baseline * current_iter_mult.
	if enemy.has_method(&"_apply_iteration_scaling"):
		enemy._apply_iteration_scaling()

	return enemy


func return_enemy(enemy: CharacterBody3D) -> void:
	_ensure_init()
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
	# Re-enable StateMachine processing
	var sm: Node = enemy.get_node_or_null("StateMachine")
	if sm:
		sm.set_process(true)
		sm.set_physics_process(true)
		sm.set_process_unhandled_input(true)


func _deactivate(enemy: CharacterBody3D) -> void:
	# Clean up any active projectiles/pools owned by this enemy
	if enemy.has_meta(&"active_projectiles"):
		var projectiles: Array = enemy.get_meta(&"active_projectiles") as Array
		for p: Variant in projectiles:
			if p is Node and is_instance_valid(p):
				(p as Node).queue_free()
		enemy.set_meta(&"active_projectiles", [])
	enemy.visible = false
	enemy.set_process(false)
	enemy.set_physics_process(false)
	enemy.set_process_unhandled_input(false)
	enemy.collision_layer = 0
	enemy.collision_mask = 0
	# Stop StateMachine child processing (doesn't inherit from parent)
	var sm: Node = enemy.get_node_or_null("StateMachine")
	if sm:
		sm.set_process(false)
		sm.set_physics_process(false)
		sm.set_process_unhandled_input(false)
	if enemy.is_inside_tree():
		enemy.global_position = Vector3(9999.0, 9999.0, 9999.0)


func _get_type(enemy: CharacterBody3D) -> String:
	# Use script class name to determine type without direct class references
	var script: Script = enemy.get_script() as Script
	if script == null:
		return ""
	var class_name_str: String = script.get_global_name()
	match class_name_str:
		"GlitchBug": return "glitch_bug"
		"MemoryLeak": return "memory_leak"
		"RogueProcess": return "rogue_process"
		"CorruptedCompiler": return "corrupted_compiler"
		"FirewallGuardian": return "firewall_guardian"
		"BufferOverflow": return "buffer_overflow"
		"NullPointer": return "null_pointer"
		"StackCrawler": return "stack_crawler"
		"SyntaxError": return "syntax_error"
		_: return ""
