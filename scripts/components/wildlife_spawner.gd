class_name WildlifeSpawner
extends Node3D

## Region-attached wildlife spawner. Place one in each wilderness region
## scene. On player entry it queries WildlifeDatabase for the active
## critters (region + phase + weather), spawns them at random points
## inside its bounds, and despawns them when the player leaves.
##
## Recomputes the active set on day/night phase change and weather
## change so birds give way to owls at dusk and frogs come out at night.
##
## Required scene shape:
##   WildlifeSpawner (Node3D + this script)
##     SpawnArea (Area3D with BoxShape3D defining the region bounds)
##
## Configure via the inspector:
##   region_id          — must match a wilderness region key
##   density_multiplier — 0..2 to scale every entry's density
##   ground_height      — used to drop critters onto the terrain
##   max_critters       — hard cap to keep frame budget safe

@export var region_id: StringName = &""
@export var density_multiplier: float = 1.0
@export var ground_height: float = 0.0
@export var max_critters: int = 40
@export var critter_scene_root: NodePath  # Optional: parent node for spawned critters
@export var critter_scenes: Dictionary = {}  # critter_id → PackedScene

@onready var _spawn_area: Area3D = $SpawnArea if has_node("SpawnArea") else null

var _active: Dictionary = {}  # critter_id → Array[Node3D]
var _player_inside: bool = false
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()


func _ready() -> void:
	_rng.randomize()
	if _spawn_area != null:
		_spawn_area.body_entered.connect(_on_player_entered)
		_spawn_area.body_exited.connect(_on_player_exited)
	if has_node("/root/DayNightController"):
		var dnc: Node = get_node("/root/DayNightController")
		if dnc.has_signal("phase_changed"):
			dnc.phase_changed.connect(_on_phase_changed)
	if has_node("/root/WeatherController"):
		var wc: Node = get_node("/root/WeatherController")
		if wc.has_signal("weather_changed"):
			wc.weather_changed.connect(_on_weather_changed)


# === SPAWNING ===

func refresh_active_critters() -> void:
	_clear_all()
	if not _player_inside:
		return
	var phase: StringName = _current_phase()
	var weather: StringName = _current_weather()
	var active_set: Array[Dictionary] = WildlifeDatabase.get_active_for_region(region_id, phase, weather)
	var total_spawned: int = 0
	for entry: Dictionary in active_set:
		var density: int = int(round(float(entry.get("density", 1)) * density_multiplier))
		var flock_size: int = entry.get("flock_size", 1)
		var groups: int = max(1, density / max(1, flock_size))
		for g in groups:
			if total_spawned >= max_critters:
				return
			var center: Vector3 = _random_point_in_bounds()
			for member in flock_size:
				if total_spawned >= max_critters:
					return
				var offset: Vector3 = _random_offset_within(2.5) if flock_size > 1 else Vector3.ZERO
				_spawn_critter(entry, center + offset)
				total_spawned += 1


func _spawn_critter(entry: Dictionary, position: Vector3) -> void:
	var critter_id: StringName = entry["id"]
	var scene: PackedScene = critter_scenes.get(critter_id, null)
	if scene == null:
		# Fallback: just track a logical placeholder so other systems can
		# query population counts even when art assets aren't loaded yet.
		_active.get_or_add(critter_id, []).append(null)
		return
	var inst: Node3D = scene.instantiate() as Node3D
	if inst == null:
		return
	var parent: Node = get_node(critter_scene_root) if critter_scene_root != NodePath("") else self
	parent.add_child(inst)
	inst.global_position = position
	inst.set_meta(&"critter_id", critter_id)
	inst.set_meta(&"flee_radius", entry.get("flee_radius", 0.0))
	inst.set_meta(&"flee_speed", entry.get("flee_speed", 0.0))
	inst.set_meta(&"return_delay_s", entry.get("return_delay_s", 0.0))
	inst.set_meta(&"locomotion", entry.get("locomotion", &"walk"))

	# Optional point light for fireflies, etc.
	if entry.get("emits_light", false):
		var light: OmniLight3D = OmniLight3D.new()
		light.light_color = entry.get("light_color", Color.WHITE)
		light.light_energy = entry.get("light_energy", 0.5)
		light.omni_range = 1.5
		inst.add_child(light)

	_active.get_or_add(critter_id, []).append(inst)
	if has_node("/root/EventBus"):
		var bus: Node = get_node("/root/EventBus")
		if bus.has_signal("wildlife_spawned"):
			bus.emit_signal("wildlife_spawned", critter_id)


func _clear_all() -> void:
	for critter_id in _active.keys():
		for inst in _active[critter_id]:
			if inst is Node and is_instance_valid(inst):
				inst.queue_free()
	_active.clear()


# === BOUNDS ===

func _random_point_in_bounds() -> Vector3:
	if _spawn_area == null:
		return global_position
	var shape: CollisionShape3D = _spawn_area.get_node_or_null("CollisionShape3D") as CollisionShape3D
	if shape == null:
		return _spawn_area.global_position
	if shape.shape is BoxShape3D:
		var box: BoxShape3D = shape.shape
		var size: Vector3 = box.size
		var local: Vector3 = Vector3(
			_rng.randf_range(-size.x * 0.5, size.x * 0.5),
			0.0,
			_rng.randf_range(-size.z * 0.5, size.z * 0.5)
		)
		return shape.global_transform * Vector3(local.x, ground_height, local.z)
	return _spawn_area.global_position


func _random_offset_within(radius: float) -> Vector3:
	var angle: float = _rng.randf() * TAU
	var dist: float = _rng.randf() * radius
	return Vector3(cos(angle) * dist, 0.0, sin(angle) * dist)


# === EVENTS ===

func _on_player_entered(body: Node3D) -> void:
	if not body.is_in_group(&"player"):
		return
	_player_inside = true
	refresh_active_critters()


func _on_player_exited(body: Node3D) -> void:
	if not body.is_in_group(&"player"):
		return
	_player_inside = false
	_clear_all()


func _on_phase_changed(_phase: StringName) -> void:
	if _player_inside:
		refresh_active_critters()


func _on_weather_changed(_weather: StringName) -> void:
	if _player_inside:
		refresh_active_critters()


# === HELPERS ===

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


func get_population(critter_id: StringName) -> int:
	return _active.get(critter_id, []).size()


func get_total_population() -> int:
	var n: int = 0
	for arr in _active.values():
		n += arr.size()
	return n
