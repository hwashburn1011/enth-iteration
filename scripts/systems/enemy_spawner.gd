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
	# Phase 2 #13: per-iteration enemy mix. Resolve a substituted
	# spawn list at request time so each iteration introduces more
	# variety into the roster without requiring new enemy assets.
	# iter 1 returns the original list verbatim — anything past that
	# rolls per-slot swaps against the broader enemy roster.
	var resolved: Array[String] = _apply_iteration_mix(types, count)
	# Phase 3 #20: enemy roster expansion via promotions. Each spawn
	# slot rolls a promotion chance scaling with iteration. Charger /
	# Shielder / Sniper / Bomber / Summoner archetypes are stat +
	# behavior overlays on the existing 3 base enemies — see
	# enemy_promotion.gd for the full table.
	var iter_for_promo: int = _current_iter_for_promo()
	var promo_rng: RandomNumberGenerator = RandomNumberGenerator.new()
	promo_rng.randomize()
	for i: int in count:
		var type: String = resolved[i % resolved.size()]
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

		# Roll promotion AFTER reparent so the enemy is in the live
		# scene tree when its baseline gets snapshotted. Promotions
		# only fire on iter 2+; the boss type is exempt because
		# corrupted_compiler has its own set of mechanics that don't
		# play well with stat overlays.
		if iter_for_promo >= 2 and type != "corrupted_compiler":
			_maybe_promote(enemy, type, iter_for_promo, promo_rng)

		_alive_count += 1

	if not EventBus.enemy_defeated.is_connected(_on_enemy_defeated):
		EventBus.enemy_defeated.connect(_on_enemy_defeated)


## Phase 3 #20 — promotion gating. Returns the current iteration
## via IterationManager, defensively. Mirrors _apply_iteration_mix
## reading pattern. Returns 1 as the floor.
func _current_iter_for_promo() -> int:
	if has_node("/root/IterationManager"):
		var im: Node = get_node("/root/IterationManager")
		if im.has_method(&"get_current_iteration"):
			return int(im.get_current_iteration())
	return 1


## Phase 3 #20 — promotion roll. Each slot has a per-iteration
## chance to be promoted to a random eligible variant for its
## base type. The eligible table lives in enemy_promotion.gd.
##
##   iter | promo chance per slot
##   ---- | ---------------------
##    2   | 12%
##    3   | 22%
##   4-6  | 35%
##    7   | 45%
##    8   | 55%
##    9   | 65%
func _maybe_promote(enemy: CharacterBody3D, type: String, iter: int, rng: RandomNumberGenerator) -> void:
	var chance: float = 0.0
	match iter:
		2:
			chance = 0.12
		3:
			chance = 0.22
		4, 5, 6:
			chance = 0.35
		7:
			chance = 0.45
		8:
			chance = 0.55
		_:
			if iter >= 9:
				chance = 0.65
	if rng.randf() >= chance:
		return
	var lib_script: Script = load("res://scripts/systems/enemy_promotion.gd") as Script
	if lib_script == null:
		return
	var eligible: Array = lib_script.ELIGIBLE_BY_TYPE.get(type, []) as Array
	if eligible.is_empty():
		return
	var promotion_id: StringName = eligible[rng.randi() % eligible.size()] as StringName
	lib_script.apply(enemy, promotion_id)


## Phase 2 #13 — per-iteration roster mix.
##
## All combat rooms in V1 ship with hardcoded `enemy_types` arrays in
## their .tscn (e.g. ["glitch_bug", "glitch_bug", "memory_leak"]). At
## iteration 1 we want to honor that authored intent so the player
## learns each enemy in isolation. As the loop advances we want the
## roster to *feel* like it's expanding even though no new assets are
## shipping — we do that by stochastically substituting spawn slots
## with other types from the V1 enemy roster.
##
## The chance grows per iteration:
##   iter 1 → 0%   (verbatim, learn-the-game phase)
##   iter 2 → 25%  (one slot likely swapped per 4-spawn room)
##   iter 3 → 45%  (rooms feel mixed)
##   iter 4 → 60% + a guaranteed swap on the first slot
##
## RNG is seeded per-call so two simultaneous spawners don't collapse
## into the same substitution sequence.
const _MIX_ROSTER: Array[String] = ["glitch_bug", "memory_leak", "rogue_process"]


func _apply_iteration_mix(types: Array[String], count: int) -> Array[String]:
	if types.is_empty() or count <= 0:
		return types
	var iter: int = 1
	if Engine.has_singleton("IterationManager"):
		var im: Object = Engine.get_singleton("IterationManager")
		if im.has_method("get_current_iteration"):
			iter = int(im.call("get_current_iteration"))
	elif has_node("/root/IterationManager"):
		var im2: Node = get_node("/root/IterationManager")
		if im2.has_method(&"get_current_iteration"):
			iter = int(im2.get_current_iteration())
	if iter <= 1:
		return types
	var swap_chance: float = 0.25
	var force_first: bool = false
	match iter:
		2:
			swap_chance = 0.25
		3:
			swap_chance = 0.45
		_:
			swap_chance = 0.60
			force_first = true
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.randomize()
	var mixed: Array[String] = []
	for i: int in count:
		var src: String = types[i % types.size()]
		var should_swap: bool = (force_first and i == 0) or rng.randf() < swap_chance
		if should_swap:
			var pool: Array[String] = []
			for t: String in _MIX_ROSTER:
				if t != src:
					pool.append(t)
			if pool.is_empty():
				mixed.append(src)
			else:
				mixed.append(pool[rng.randi() % pool.size()])
		else:
			mixed.append(src)
	return mixed


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
