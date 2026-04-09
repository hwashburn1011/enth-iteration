class_name EnemySpawnerV2
extends Node3D

## Enemy spawner that consumes the Epic 08 EnemyTuning resources to
## drive floor-tier-aware encounters with group composition presets
## (Epic 08 task 47).
##
## Each spawn cycle:
##   1) Pick a primary enemy from the eligible pool for the current
##      floor tier (filtered by EnemyTuning.can_spawn_on_tier)
##   2) Roll the primary's group_composition_presets — if any preset
##      includes other enemies, spawn them alongside at the configured
##      counts and weights
##   3) Apply the per-tier HP/damage scaling from EnemyTuning to each
##      spawned instance via HealthComponent.set_max_hp / set_base_damage
##   4) Distribute the spawn positions in a small cluster around the
##      spawn point (1.5m radius)
##
## Required scene shape:
##   EnemySpawnerV2 (Node3D + this script)
##     export current_floor_tier: int
##     export eligible_tuning_paths: Array[String] paths to .tres files
##     export enemy_scene_paths: Dictionary mapping enemy_id → scene path
##
## Hookup from a dungeon room:
##   var spawner: EnemySpawnerV2 = preload(...).instantiate()
##   spawner.current_floor_tier = current_dungeon_floor_tier
##   spawner.global_position = room.spawn_anchor.global_position
##   add_child(spawner)
##   spawner.spawn_encounter()

signal encounter_spawned(enemies: Array[Node3D])

@export_range(0, 4) var current_floor_tier: int = 0
@export var eligible_tuning_paths: Array[String] = []
@export var enemy_scene_paths: Dictionary = {}
@export var spawn_radius_m: float = 1.5
@export var max_simultaneous: int = 8

var _eligible_tunings: Array[EnemyTuning] = []


func _ready() -> void:
	_load_eligible_tunings()


func _load_eligible_tunings() -> void:
	_eligible_tunings.clear()
	for path: String in eligible_tuning_paths:
		if not ResourceLoader.exists(path):
			continue
		var tuning: EnemyTuning = load(path) as EnemyTuning
		if tuning == null:
			continue
		if tuning.can_spawn_on_tier(current_floor_tier):
			_eligible_tunings.append(tuning)


func spawn_encounter() -> Array[Node3D]:
	if _eligible_tunings.is_empty():
		push_warning("EnemySpawnerV2: no eligible tunings for tier %d" % current_floor_tier)
		return []
	# Pick a primary
	var primary: EnemyTuning = _eligible_tunings[randi() % _eligible_tunings.size()]
	var spawned: Array[Node3D] = []
	# Roll the composition presets for the primary
	var composition: Array = primary.group_composition_presets
	if composition.is_empty():
		# Fallback: spawn 1 of the primary
		var spawn := _spawn_one(primary)
		if spawn != null:
			spawned.append(spawn)
	else:
		# Pick a preset
		var preset: Dictionary = composition[randi() % composition.size()]
		# Spawn N of each entry in the preset
		var preset_entries: Array = composition
		for entry: Dictionary in preset_entries:
			var enemy_id: StringName = entry.get("enemy_id", &"")
			var count: int = entry.get("count", 1)
			var weight: float = entry.get("weight", 1.0)
			# Roll weight gate
			if randf() > weight:
				continue
			var entry_tuning: EnemyTuning = _find_tuning(enemy_id)
			if entry_tuning == null:
				continue
			for i in range(count):
				if spawned.size() >= max_simultaneous:
					break
				var s := _spawn_one(entry_tuning)
				if s != null:
					spawned.append(s)
	encounter_spawned.emit(spawned)
	return spawned


func _find_tuning(enemy_id: StringName) -> EnemyTuning:
	for t: EnemyTuning in _eligible_tunings:
		if t.enemy_id == enemy_id:
			return t
	# Fall back to loading directly even if not in the eligible pool
	var path: String = "res://data/enemies/tuning/%s_tuning.tres" % String(enemy_id)
	if ResourceLoader.exists(path):
		return load(path) as EnemyTuning
	return null


func _spawn_one(tuning: EnemyTuning) -> Node3D:
	var enemy_id: StringName = tuning.enemy_id
	if not enemy_scene_paths.has(enemy_id):
		return null
	var scene_path: String = enemy_scene_paths[enemy_id]
	if not ResourceLoader.exists(scene_path):
		return null
	var packed: PackedScene = load(scene_path) as PackedScene
	if packed == null:
		return null
	var enemy: Node3D = packed.instantiate() as Node3D
	if enemy == null:
		return null
	get_tree().current_scene.add_child(enemy)
	# Pick a random position within spawn radius
	var angle: float = randf() * TAU
	var dist: float = randf() * spawn_radius_m
	var offset: Vector3 = Vector3(cos(angle) * dist, 0, sin(angle) * dist)
	enemy.global_position = global_position + offset
	# Apply tier-scaled HP/damage to the HealthComponent if present
	for child: Node in enemy.get_children():
		if child.has_method("set_max_hp"):
			child.call("set_max_hp", tuning.get_hp_for_tier(current_floor_tier))
		if child.has_method("set_base_damage"):
			child.call("set_base_damage", tuning.get_damage_for_tier(current_floor_tier))
	return enemy
