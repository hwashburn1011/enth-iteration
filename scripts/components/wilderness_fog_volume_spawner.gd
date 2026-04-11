class_name WildernessFogVolumeSpawner
extends Node3D

## Region-attached fog volume spawner. Reads FogVolumeDatabase entries
## for `region_id` at scene load and creates one Godot FogVolume per
## entry. Listens to phase + weather change and re-tweens each volume's
## density to its new modulated value.
##
## Add one of these as a child of each wilderness region's scene node.
## The fog volumes are positioned via each entry's `position_offset`
## relative to this spawner's global transform — so place this spawner
## at the region's "center of mass" and the entries describe the offsets.
##
## Required scene shape:
##   WildernessFogVolumeSpawner (Node3D + this script)
##     [no children needed; FogVolume nodes are added at runtime]
##
## Configure via inspector:
##   region_id          — drives the database query
##   density_multiplier — global multiplier on every spawned volume

@export var region_id: StringName = &""
@export var density_multiplier: float = 1.0

var _spawned: Array[Dictionary] = []  # [{node: FogVolume, entry: Dict}]
var _tweens: Dictionary = {}  # node → Tween


func _ready() -> void:
	if has_node("/root/DayNightController"):
		var dnc: Node = get_node("/root/DayNightController")
		if dnc.has_signal("phase_changed"):
			dnc.phase_changed.connect(_on_phase_or_weather_changed)
	if has_node("/root/WeatherController"):
		var wc: Node = get_node("/root/WeatherController")
		if wc.has_signal("weather_changed"):
			wc.weather_changed.connect(_on_phase_or_weather_changed)
	call_deferred("spawn_all")


# === SPAWN ===

func spawn_all() -> void:
	if region_id == &"":
		return
	clear_all()
	var iteration: int = _current_iteration()
	for entry: Dictionary in FogVolumeDatabase.get_volumes_for_region(region_id):
		var iter_gate: int = int(entry.get("iteration_gate_min", 0))
		if iter_gate > 0 and iteration < iter_gate:
			continue
		_spawn_one(entry)


func _spawn_one(entry: Dictionary) -> void:
	var fv: FogVolume = FogVolume.new()
	fv.name = String(entry.get("id", &"fog_volume"))

	# Shape (box only for now; engine supports cone/cylinder/ellipsoid as well)
	var shape_name: StringName = entry.get("shape", &"box")
	match shape_name:
		&"box":      fv.shape = FogVolume.SHAPE_BOX
		&"ellipsoid": fv.shape = FogVolume.SHAPE_ELLIPSOID
		&"cone":     fv.shape = FogVolume.SHAPE_CONE
		&"cylinder": fv.shape = FogVolume.SHAPE_CYLINDER
		_:           fv.shape = FogVolume.SHAPE_BOX

	fv.size = entry.get("size", Vector3(20, 4, 20))

	# Material
	var mat: FogMaterial = FogMaterial.new()
	var phase: StringName = _current_phase()
	var weather: StringName = _current_weather()
	var density: float = FogVolumeDatabase.get_density_for(entry, phase, weather) * density_multiplier
	mat.density = density
	mat.albedo = entry.get("albedo", Color.WHITE)
	mat.emission = entry.get("emission", Color.BLACK)
	fv.material = mat

	add_child(fv)
	fv.global_position = global_position + entry.get("position_offset", Vector3.ZERO)

	_spawned.append({"node": fv, "entry": entry})


# === REACTIVE UPDATE ===

func _on_phase_or_weather_changed(_arg = null) -> void:
	var phase: StringName = _current_phase()
	var weather: StringName = _current_weather()
	for slot in _spawned:
		var fv: FogVolume = slot["node"]
		if not is_instance_valid(fv) or not (fv.material is FogMaterial):
			continue
		var mat: FogMaterial = fv.material
		var target_density: float = FogVolumeDatabase.get_density_for(slot["entry"], phase, weather) * density_multiplier
		_tween_density(fv, mat, target_density)


func _tween_density(fv: FogVolume, mat: FogMaterial, target: float) -> void:
	if _tweens.has(fv):
		var prev: Tween = _tweens[fv]
		if is_instance_valid(prev):
			prev.kill()
	var tw: Tween = create_tween()
	tw.tween_property(mat, "density", target, 4.0)
	_tweens[fv] = tw


# === CLEAR ===

func clear_all() -> void:
	for slot in _spawned:
		var fv: FogVolume = slot["node"]
		if is_instance_valid(fv):
			fv.queue_free()
	_spawned.clear()
	_tweens.clear()


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


func _current_iteration() -> int:
	if not has_node("/root/IterationManager"):
		return 1
	var im: Node = get_node("/root/IterationManager")
	if im.has_method("get_current_iteration"):
		return int(im.get_current_iteration())
	return 1
