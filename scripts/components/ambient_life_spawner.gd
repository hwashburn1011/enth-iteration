class_name AmbientLifeSpawner
extends Node3D

## Atmospheric ambient life — the layer BENEATH the named critters
## handled by WildlifeSpawner. This component spawns:
##
##   1. Insect swarm particle systems (fireflies, midges, dragonflies,
##      dust motes) inside its bounds, hidden when the player isn't
##      around to save GPU
##
##   2. Distant bird formations — silhouette models that drift across
##      the sky on a curve, audio-only when too far for the silhouette
##      to read
##
##   3. Audio-only ambient calls (cricket beds, distant cuckoo, owl
##      hoots) on a randomized schedule
##
## Configurable per scene instance via the inspector.
##
## Required scene shape:
##   AmbientLifeSpawner (Node3D + this script)
##     SwarmAnchors (Node3D — child Marker3Ds where swarm particles spawn)
##     BirdFormationPath (Path3D — optional, for formation drifts)
##     BirdFormationCurveFollow (PathFollow3D — child of the path)
##     AmbientAudioPlayer (AudioStreamPlayer3D — for one-shot calls)
##     PresenceArea (Area3D — toggles spawning on/off when player enters)

@export var region_id: StringName = &""

@export_group("Insect swarms")
@export var swarm_particle_scene: PackedScene
@export var swarm_density_multiplier: float = 1.0
@export var swarm_phase_filter: Array[StringName] = []  # empty = all phases
@export var swarm_weather_blacklist: Array[StringName] = [&"storm", &"glitch_storm"]

@export_group("Bird formations")
@export var formation_silhouette_scene: PackedScene
@export var formation_count: int = 1
@export var formation_speed: float = 4.0
@export var formation_phase_filter: Array[StringName] = [&"dawn", &"day", &"dusk"]

@export_group("Ambient calls")
@export var call_sfx_pool: Array[StringName] = []
@export var call_min_interval_s: float = 8.0
@export var call_max_interval_s: float = 22.0
@export var call_phase_filter: Array[StringName] = []
@export var call_volume_db: float = -16.0

@onready var _swarm_anchors: Node3D = $SwarmAnchors if has_node("SwarmAnchors") else null
@onready var _bird_path_follow: PathFollow3D = $BirdFormationPath/BirdFormationCurveFollow if has_node("BirdFormationPath/BirdFormationCurveFollow") else null
@onready var _ambient_player: AudioStreamPlayer3D = $AmbientAudioPlayer if has_node("AmbientAudioPlayer") else null
@onready var _presence_area: Area3D = $PresenceArea if has_node("PresenceArea") else null

var _active_swarms: Array[Node3D] = []
var _active_formations: Array[Node3D] = []
var _player_in_range: bool = false
var _next_call_time: float = 0.0
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()


func _ready() -> void:
	_rng.randomize()
	if _presence_area != null:
		_presence_area.body_entered.connect(_on_player_entered)
		_presence_area.body_exited.connect(_on_player_exited)
	if has_node("/root/DayNightController"):
		var dnc: Node = get_node("/root/DayNightController")
		if dnc.has_signal("phase_changed"):
			dnc.phase_changed.connect(_on_phase_changed)
	if has_node("/root/WeatherController"):
		var wc: Node = get_node("/root/WeatherController")
		if wc.has_signal("weather_changed"):
			wc.weather_changed.connect(_on_weather_changed)
	_schedule_next_call()


func _process(delta: float) -> void:
	if not _player_in_range:
		return
	_advance_formations(delta)
	_tick_calls(delta)


# === SWARMS ===

func refresh_swarms() -> void:
	_clear_swarms()
	if not _player_in_range:
		return
	if not _phase_allows(swarm_phase_filter):
		return
	if _weather_blacklisted(swarm_weather_blacklist):
		return
	if _swarm_anchors == null or swarm_particle_scene == null:
		return
	for marker in _swarm_anchors.get_children():
		if marker is Marker3D:
			if _rng.randf() <= swarm_density_multiplier:
				var inst: Node3D = swarm_particle_scene.instantiate() as Node3D
				if inst != null:
					add_child(inst)
					inst.global_position = (marker as Marker3D).global_position
					_active_swarms.append(inst)


func _clear_swarms() -> void:
	for s in _active_swarms:
		if is_instance_valid(s):
			s.queue_free()
	_active_swarms.clear()


# === BIRD FORMATIONS ===

func refresh_formations() -> void:
	_clear_formations()
	if not _player_in_range:
		return
	if not _phase_allows(formation_phase_filter):
		return
	if formation_silhouette_scene == null or _bird_path_follow == null:
		return
	for i in formation_count:
		var inst: Node3D = formation_silhouette_scene.instantiate() as Node3D
		if inst == null:
			continue
		_bird_path_follow.add_child(inst)
		inst.position = Vector3(_rng.randf_range(-3.0, 3.0), _rng.randf_range(-1.5, 1.5), 0.0)
		_active_formations.append(inst)


func _advance_formations(delta: float) -> void:
	if _bird_path_follow == null or _active_formations.is_empty():
		return
	_bird_path_follow.progress += formation_speed * delta
	# Loop the curve
	if _bird_path_follow.progress_ratio > 0.999:
		_bird_path_follow.progress_ratio = 0.0


func _clear_formations() -> void:
	for f in _active_formations:
		if is_instance_valid(f):
			f.queue_free()
	_active_formations.clear()


# === AMBIENT CALLS ===

func _tick_calls(delta: float) -> void:
	if _ambient_player == null or call_sfx_pool.is_empty():
		return
	if not _phase_allows(call_phase_filter):
		return
	_next_call_time -= delta
	if _next_call_time <= 0.0:
		_play_random_call()
		_schedule_next_call()


func _play_random_call() -> void:
	var sfx_id: StringName = call_sfx_pool[_rng.randi() % call_sfx_pool.size()]
	# Try SFXManager first; fall back to local AudioStreamPlayer3D
	if has_node("/root/SFXManager"):
		var sm: Node = get_node("/root/SFXManager")
		if sm.has_method("play_at"):
			sm.play_at(sfx_id, global_position)
			return
	if _ambient_player != null:
		_ambient_player.volume_db = call_volume_db
		var stream: AudioStream = _resolve_call_stream(sfx_id)
		if stream != null:
			_ambient_player.stream = stream
			_ambient_player.play()


func _resolve_call_stream(sfx_id: StringName) -> AudioStream:
	# Hand-rolled fallback when SFXManager isn't routing the call.
	# Returns null if the audio file doesn't exist.
	var path: String = "res://assets/audio/sfx/ambient/" + String(sfx_id) + ".ogg"
	if ResourceLoader.exists(path):
		return load(path) as AudioStream
	return null


func _schedule_next_call() -> void:
	_next_call_time = _rng.randf_range(call_min_interval_s, call_max_interval_s)


# === GATING ===

func _phase_allows(filter: Array[StringName]) -> bool:
	if filter.is_empty():
		return true
	return filter.has(_current_phase())


func _weather_blacklisted(blacklist: Array[StringName]) -> bool:
	if blacklist.is_empty():
		return false
	return blacklist.has(_current_weather())


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


# === EVENTS ===

func _on_player_entered(body: Node3D) -> void:
	if not body.is_in_group(&"player"):
		return
	_player_in_range = true
	refresh_swarms()
	refresh_formations()


func _on_player_exited(body: Node3D) -> void:
	if not body.is_in_group(&"player"):
		return
	_player_in_range = false
	_clear_swarms()
	_clear_formations()


func _on_phase_changed(_phase: StringName) -> void:
	if _player_in_range:
		refresh_swarms()
		refresh_formations()


func _on_weather_changed(_weather: StringName) -> void:
	if _player_in_range:
		refresh_swarms()
