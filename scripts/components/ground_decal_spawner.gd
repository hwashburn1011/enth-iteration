class_name GroundDecalSpawner
extends Node3D

## Scatters Decal3D nodes from GroundDecalDatabase across a region's
## bounds (random positions, rotations, sizes) and along path lines
## (a child Path3D that walks the road network through the region).
##
## Spawns at scene load and amplifies wet-category decals when weather
## changes (rain → more puddles + mud, then they fade out on clear).
##
## Required scene shape:
##   GroundDecalSpawner (Node3D + this script)
##     RegionBounds (Area3D + CollisionShape3D BoxShape3D)
##     PathLines (Node3D, optional — child Path3Ds for path-aligned decals)
##     DecalsParent (Node3D — where spawned decals are added)
##
## Configure via inspector:
##   region_id            — drives the database query
##   ground_height        — Y position decals snap to
##   ground_normal        — usually Vector3.UP, override for sloped regions
##   density_multiplier   — global multiplier on per-decal density
##   max_decals           — hard cap to keep frame budget safe

const DECAL_TEXTURE_BASE_PATH: String = "res://assets/textures/decals/"

@export var region_id: StringName = &""
@export var ground_height: float = 0.0
@export var ground_normal: Vector3 = Vector3.UP
@export var density_multiplier: float = 1.0
@export var max_decals: int = 200

@onready var _bounds: Area3D = $RegionBounds if has_node("RegionBounds") else null
@onready var _path_lines: Node3D = $PathLines if has_node("PathLines") else null
@onready var _decals_parent: Node3D = $DecalsParent if has_node("DecalsParent") else null

var _spawned_decals: Array[Decal] = []
var _spawned_by_category: Dictionary = {}  # category → Array[Decal]
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()


func _ready() -> void:
	_rng.randomize()
	if has_node("/root/WeatherController"):
		var wc: Node = get_node("/root/WeatherController")
		if wc.has_signal("weather_changed"):
			wc.weather_changed.connect(_on_weather_changed)
	# Defer to next frame so the scene is fully ready
	call_deferred("scatter")


# === SCATTER ===

func scatter() -> void:
	if region_id == &"" or _decals_parent == null:
		return
	clear_all()
	var weather: StringName = _current_weather()
	var phase: StringName = _current_phase()
	var iteration: int = _current_iteration()

	var pool: Array[Dictionary] = GroundDecalDatabase.get_for_region(region_id, weather, phase, iteration)
	if pool.is_empty():
		return

	for entry in pool:
		_scatter_one_type(entry, weather)
		if _spawned_decals.size() >= max_decals:
			return


func _scatter_one_type(entry: Dictionary, weather: StringName) -> void:
	# Path-aligned (footprints, scuffs)
	var per_path_meter: float = float(entry.get("density_per_path_meter", 0.0))
	if per_path_meter > 0.0 and _path_lines != null:
		_scatter_along_paths(entry, per_path_meter)

	# Region-distributed (mud, leaves, glyphs)
	var per_100m2: float = float(entry.get("density_per_region_100m2", 0.0))
	if per_100m2 > 0.0 and _bounds != null:
		var amplification: float = _weather_amplification(entry, weather)
		_scatter_in_bounds(entry, per_100m2 * amplification)


func _scatter_along_paths(entry: Dictionary, per_meter: float) -> void:
	for path_node in _path_lines.get_children():
		if not (path_node is Path3D):
			continue
		var path: Path3D = path_node
		if path.curve == null:
			continue
		var length: float = path.curve.get_baked_length()
		var count: int = int(round(length * per_meter * density_multiplier))
		for i in count:
			if _spawned_decals.size() >= max_decals:
				return
			var t: float = _rng.randf() * length
			var pos: Vector3 = path.curve.sample_baked(t)
			var jitter: Vector3 = Vector3(_rng.randf_range(-0.4, 0.4), 0, _rng.randf_range(-0.4, 0.4))
			_spawn_decal(entry, path.global_position + pos + jitter)


func _scatter_in_bounds(entry: Dictionary, per_100m2: float) -> void:
	var shape: CollisionShape3D = _bounds.get_node_or_null("CollisionShape3D") as CollisionShape3D
	if shape == null or not (shape.shape is BoxShape3D):
		return
	var box: BoxShape3D = shape.shape
	var size: Vector3 = box.size
	var area_m2: float = size.x * size.z
	var count: int = int(round(area_m2 / 100.0 * per_100m2 * density_multiplier))
	for i in count:
		if _spawned_decals.size() >= max_decals:
			return
		var local: Vector3 = Vector3(
			_rng.randf_range(-size.x * 0.5, size.x * 0.5),
			0,
			_rng.randf_range(-size.z * 0.5, size.z * 0.5)
		)
		var world: Vector3 = shape.global_transform * Vector3(local.x, ground_height, local.z)
		_spawn_decal(entry, world)


# === SPAWN ===

func _spawn_decal(entry: Dictionary, world_position: Vector3) -> void:
	var decal: Decal = Decal.new()
	var size_min: Vector2 = entry.get("size_min", Vector2(1, 1))
	var size_max: Vector2 = entry.get("size_max", size_min)
	var sx: float = _rng.randf_range(size_min.x, size_max.x)
	var sz: float = _rng.randf_range(size_min.y, size_max.y)
	var depth: float = float(entry.get("depth_meters", 0.3))
	decal.size = Vector3(sx, depth, sz)
	decal.modulate = entry.get("albedo_tint", Color.WHITE)

	# Try to load the texture; falls back to a tinted plain decal if missing
	var texture_id: StringName = entry.get("texture_id", &"")
	if texture_id != &"":
		var path: String = DECAL_TEXTURE_BASE_PATH + String(texture_id) + ".png"
		if ResourceLoader.exists(path):
			decal.texture_albedo = load(path) as Texture2D

	# Emissive ruin glyph at night
	if entry.get("emissive_at_night", false):
		decal.texture_emission = decal.texture_albedo
		decal.emission_energy = float(entry.get("emission_energy", 0.0))
		decal.modulate_emission = entry.get("emission_color", Color.WHITE)

	_decals_parent.add_child(decal)
	decal.global_position = world_position
	decal.global_position.y = ground_height + 0.5  # decal Y origin sits above ground

	# Random rotation around Y axis if requested
	if entry.get("random_rotation", false):
		decal.rotation_degrees.y = _rng.randf() * 360.0

	# Slope normal alignment
	if ground_normal != Vector3.UP:
		decal.transform.basis = Basis.looking_at(-ground_normal, Vector3.UP)

	_spawned_decals.append(decal)
	var category: StringName = entry.get("category", &"misc")
	_spawned_by_category.get_or_add(category, []).append(decal)


# === CLEAR ===

func clear_all() -> void:
	for d in _spawned_decals:
		if is_instance_valid(d):
			d.queue_free()
	_spawned_decals.clear()
	_spawned_by_category.clear()


func clear_category(category: StringName) -> void:
	var arr: Array = _spawned_by_category.get(category, [])
	for d in arr:
		if is_instance_valid(d):
			d.queue_free()
	_spawned_by_category.erase(category)
	_spawned_decals = _spawned_decals.filter(func(d: Decal) -> bool: return is_instance_valid(d))


# === WEATHER REACTION ===

func _on_weather_changed(weather_id: StringName) -> void:
	# Wet-category decals (mud, puddles) refresh on weather change so the
	# wilderness gets visibly muddier when it rains.
	clear_category(&"wet")
	var pool: Array[Dictionary] = GroundDecalDatabase.get_for_region(region_id, weather_id, _current_phase(), _current_iteration())
	for entry in pool:
		if entry.get("category", &"") != &"wet":
			continue
		var per_100m2: float = float(entry.get("density_per_region_100m2", 0.0))
		if per_100m2 > 0.0 and _bounds != null:
			var amp: float = _weather_amplification(entry, weather_id)
			_scatter_in_bounds(entry, per_100m2 * amp)


func _weather_amplification(entry: Dictionary, weather_id: StringName) -> float:
	var amp_table: Dictionary = entry.get("weather_amplification", {})
	return float(amp_table.get(weather_id, 1.0))


# === HELPERS ===

func _current_weather() -> StringName:
	if not has_node("/root/WeatherController"):
		return &"clear"
	var wc: Node = get_node("/root/WeatherController")
	if "current_weather_id" in wc:
		return StringName(wc.current_weather_id)
	return &"clear"


func _current_phase() -> StringName:
	if not has_node("/root/DayNightController"):
		return &"day"
	var dnc: Node = get_node("/root/DayNightController")
	if "current_phase" in dnc:
		return StringName(dnc.current_phase)
	return &"day"


func _current_iteration() -> int:
	if not has_node("/root/IterationManager"):
		return 1
	var im: Node = get_node("/root/IterationManager")
	if im.has_method("get_current_iteration"):
		return int(im.get_current_iteration())
	return 1
