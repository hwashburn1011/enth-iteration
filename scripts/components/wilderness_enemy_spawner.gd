class_name WildernessEnemySpawner
extends Node3D

## Region-attached overworld enemy spawner. Place one in each wilderness
## region scene. Enforces the bible's spawn rules:
##   1. Never within 20m of the player on first entry
##   2. Never within 30m of a fast-travel waypoint
##   3. Density scales with iteration (30% → 100% across iter 1–9)
##   4. No respawn during a single visit (cleared until town return)
##
## Required scene shape:
##   WildernessEnemySpawner (Node3D + this script)
##     SpawnArea (Area3D with BoxShape3D defining the region bounds)
##     Waypoints (Node3D with child Node3Ds tagged as fast-travel)
##     SpawnAnchors (optional Node3D with child Marker3Ds for hand-placed
##                   anchor points; falls back to random sampling)

const FIRST_ENTRY_PLAYER_EXCLUSION_RADIUS: float = 20.0
const WAYPOINT_EXCLUSION_RADIUS: float = 30.0

@export var region_id: StringName = &""
@export var max_active_enemies: int = 24
@export var ground_height: float = 0.0
@export var enemy_scenes: Dictionary = {}  # enemy_type → PackedScene

@onready var _spawn_area: Area3D = $SpawnArea if has_node("SpawnArea") else null
@onready var _waypoints: Node3D = $Waypoints if has_node("Waypoints") else null
@onready var _spawn_anchors: Node3D = $SpawnAnchors if has_node("SpawnAnchors") else null

var _spawned_this_visit: Dictionary = {}  # enemy_id → Array[Node3D]
var _cleared_until_town_return: bool = false
var _player_inside: bool = false
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()


func _ready() -> void:
	_rng.randomize()
	if _spawn_area != null:
		_spawn_area.body_entered.connect(_on_player_entered)
		_spawn_area.body_exited.connect(_on_player_exited)
	if has_node("/root/EventBus"):
		var bus: Node = get_node("/root/EventBus")
		if bus.has_signal("player_returned_to_town"):
			bus.player_returned_to_town.connect(_on_player_returned_to_town)


# === SPAWNING ===

func spawn_for_region(player: Node3D) -> void:
	if _cleared_until_town_return:
		return
	if region_id == &"":
		push_warning("WildernessEnemySpawner: empty region_id")
		return

	var phase: StringName = _current_phase()
	var weather: StringName = _current_weather()
	var iteration: int = _current_iteration()
	var density_mult: float = WildernessEnemyDatabase.get_density_multiplier_for_iteration(iteration)

	var pool: Array[Dictionary] = WildernessEnemyDatabase.get_for_region(region_id)
	var total_spawned: int = 0

	for entry: Dictionary in pool:
		if not entry.get("phases", []).has(phase):
			continue
		if entry.get("weather_blacklist", []).has(weather):
			continue

		var pack_count: int = int(round(float(entry.get("base_density", 1)) * density_mult))
		pack_count = max(1, pack_count)

		for p in pack_count:
			if total_spawned >= max_active_enemies:
				return
			var pack_size: int = _rng.randi_range(
				entry.get("base_pack_size", 1),
				entry.get("max_pack_size", entry.get("base_pack_size", 1))
			)
			var anchor: Vector3 = _find_valid_spawn_point(player, entry)
			if anchor == Vector3.INF:
				continue
			for member in pack_size:
				if total_spawned >= max_active_enemies:
					return
				var offset: Vector3 = _random_pack_offset(2.5)
				_spawn_enemy(entry, anchor + offset)
				total_spawned += 1


func _spawn_enemy(entry: Dictionary, position: Vector3) -> void:
	var enemy_type: StringName = entry.get("enemy_type", &"")
	var enemy_id: StringName = entry["id"]
	var scene: PackedScene = enemy_scenes.get(enemy_type, null)

	if scene == null:
		# Fallback: track placeholder so kill counters and density stay valid
		_spawned_this_visit.get_or_add(enemy_id, []).append(null)
		return

	var inst: Node3D = scene.instantiate() as Node3D
	if inst == null:
		return
	add_child(inst)
	inst.global_position = position
	inst.set_meta(&"wilderness_enemy_id", enemy_id)
	inst.set_meta(&"alert_radius", entry.get("alert_radius", 8.0))
	inst.set_meta(&"chase_radius", entry.get("chase_radius", 14.0))

	if inst.has_signal("died"):
		inst.died.connect(_on_enemy_died.bind(enemy_id, inst))

	_spawned_this_visit.get_or_add(enemy_id, []).append(inst)
	if has_node("/root/EventBus"):
		var bus: Node = get_node("/root/EventBus")
		if bus.has_signal("wilderness_enemy_spawned"):
			bus.emit_signal("wilderness_enemy_spawned", enemy_id)


func _find_valid_spawn_point(player: Node3D, entry: Dictionary) -> Vector3:
	# Try hand-placed anchors first
	var anchors: Array = []
	if _spawn_anchors != null:
		for child in _spawn_anchors.get_children():
			if child is Marker3D:
				anchors.append(child.global_position)
	if not anchors.is_empty():
		anchors.shuffle()
		for a in anchors:
			if _point_passes_exclusions(a, player):
				return a
	# Fall back to random sampling within bounds
	for attempt in 12:
		var p: Vector3 = _random_point_in_bounds()
		if _point_passes_exclusions(p, player):
			return p
	return Vector3.INF


func _point_passes_exclusions(point: Vector3, player: Node3D) -> bool:
	if player != null:
		if point.distance_to(player.global_position) < FIRST_ENTRY_PLAYER_EXCLUSION_RADIUS:
			return false
	if _waypoints != null:
		for wp in _waypoints.get_children():
			if wp is Node3D:
				if point.distance_to((wp as Node3D).global_position) < WAYPOINT_EXCLUSION_RADIUS:
					return false
	return true


# === BOUNDS ===

func _random_point_in_bounds() -> Vector3:
	if _spawn_area == null:
		return global_position
	var shape: CollisionShape3D = _spawn_area.get_node_or_null("CollisionShape3D") as CollisionShape3D
	if shape == null or not (shape.shape is BoxShape3D):
		return _spawn_area.global_position
	var box: BoxShape3D = shape.shape
	var size: Vector3 = box.size
	var local: Vector3 = Vector3(
		_rng.randf_range(-size.x * 0.5, size.x * 0.5),
		0.0,
		_rng.randf_range(-size.z * 0.5, size.z * 0.5)
	)
	return shape.global_transform * Vector3(local.x, ground_height, local.z)


func _random_pack_offset(radius: float) -> Vector3:
	var angle: float = _rng.randf() * TAU
	var dist: float = _rng.randf() * radius
	return Vector3(cos(angle) * dist, 0.0, sin(angle) * dist)


# === EVENTS ===

func _on_player_entered(body: Node3D) -> void:
	if not body.is_in_group(&"player"):
		return
	if _player_inside:
		return
	_player_inside = true
	# Only spawn on the first entry of the visit (no respawn rule)
	if _spawned_this_visit.is_empty() and not _cleared_until_town_return:
		spawn_for_region(body)


func _on_player_exited(body: Node3D) -> void:
	if not body.is_in_group(&"player"):
		return
	_player_inside = false


func _on_enemy_died(enemy_id: StringName, inst: Node3D) -> void:
	if not _spawned_this_visit.has(enemy_id):
		return
	_spawned_this_visit[enemy_id].erase(inst)
	# When the last enemy in this region is dead, mark the region cleared
	if get_total_alive() == 0:
		_cleared_until_town_return = true
		if has_node("/root/EventBus"):
			var bus: Node = get_node("/root/EventBus")
			if bus.has_signal("wilderness_region_cleared"):
				bus.emit_signal("wilderness_region_cleared", region_id)


func _on_player_returned_to_town() -> void:
	# Reset the visit so the next return to wilderness re-populates
	_cleared_until_town_return = false
	for enemy_id in _spawned_this_visit.keys():
		for inst in _spawned_this_visit[enemy_id]:
			if inst is Node and is_instance_valid(inst):
				inst.queue_free()
	_spawned_this_visit.clear()


# === HELPERS ===

func get_total_alive() -> int:
	var n: int = 0
	for arr in _spawned_this_visit.values():
		for inst in arr:
			if inst is Node and is_instance_valid(inst):
				n += 1
	return n


func _current_phase() -> StringName:
	if not has_node("/root/DayNightController"):
		return &"day"
	var dnc: Node = get_node("/root/DayNightController")
	if "current_phase" in dnc:
		return StringName(dnc.current_phase)
	return &"day"


func _current_weather() -> StringName:
	if not has_node("/root/WeatherController"):
		return &"clear"
	var wc: Node = get_node("/root/WeatherController")
	if "current_weather_id" in wc:
		return StringName(wc.current_weather_id)
	return &"clear"


func _current_iteration() -> int:
	if not has_node("/root/IterationManager"):
		return 1
	var im: Node = get_node("/root/IterationManager")
	if im.has_method("get_current_iteration"):
		return int(im.get_current_iteration())
	if "current_iteration" in im:
		return int(im.current_iteration)
	return 1
