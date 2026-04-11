class_name AmbientEnemySfx
extends Node3D

## Passive ambient sound component for living enemies — distinct from
## EnemyVariantSfx which fires state-driven one-shots. This one drives
## a continuous spatialized loop (the "gurgle" of a MemoryLeak, the
## "buzz" of a GlitchBug) and randomly-timed accent one-shots (the
## "drip", the "click").
##
## Both audio sources are AudioStreamPlayer3D children built at runtime
## so callers don't have to wire scenes.
##
## Lifecycle:
##   - Loop starts on _ready, plays until parent dies
##   - Accents fire on a randomized timer between accent_interval_min_s
##     and accent_interval_max_s
##   - Both stop on the parent HealthComponent's died signal
##
## Required scene shape:
##   AmbientEnemySfx (Node3D + this script)
##     [AudioStreamPlayer3D children added at runtime]
##
## Configure via inspector:
##   loop_sfx_id          — looping ambient (e.g. "amb_leak_gurgle")
##   loop_db              — volume of the loop in dB
##   loop_max_distance    — falloff distance
##   accent_sfx_id        — one-shot sound (e.g. "amb_leak_drip")
##   accent_db            — volume of the accent
##   accent_interval_min/max_s — random timer range between accents

const SFX_BASE_PATH: String = "res://assets/audio/sfx/ambient/"

@export var loop_sfx_id: StringName = &""
@export_range(-60.0, 6.0) var loop_db: float = -16.0
@export_range(2.0, 60.0) var loop_max_distance: float = 18.0
@export_range(0.5, 30.0) var loop_unit_size: float = 6.0

@export var accent_sfx_id: StringName = &""
@export_range(-60.0, 6.0) var accent_db: float = -10.0
@export_range(0.5, 60.0) var accent_interval_min_s: float = 3.5
@export_range(0.5, 60.0) var accent_interval_max_s: float = 8.5

@export var stop_on_death: bool = true
@export var health_component_path: NodePath

var _loop_player: AudioStreamPlayer3D
var _accent_player: AudioStreamPlayer3D
var _accent_timer: float = 0.0
var _accent_target: float = 0.0
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()
var _stopped: bool = false


func _ready() -> void:
	_rng.randomize()

	if loop_sfx_id != &"":
		_loop_player = _make_player("AmbientLoop", loop_db, true)
		_load_stream(_loop_player, loop_sfx_id, true)
		if _loop_player.stream != null:
			_loop_player.play()

	if accent_sfx_id != &"":
		_accent_player = _make_player("AmbientAccent", accent_db, false)
		_load_stream(_accent_player, accent_sfx_id, false)
		_schedule_next_accent()

	if stop_on_death:
		var hc: Node = get_node_or_null(health_component_path)
		if hc == null:
			var parent: Node = get_parent()
			if parent != null:
				for child: Node in parent.get_children():
					if child.has_signal("died"):
						hc = child
						break
		if hc != null and hc.has_signal("died"):
			hc.died.connect(_on_died)


func _make_player(name: String, db: float, is_loop: bool) -> AudioStreamPlayer3D:
	var p: AudioStreamPlayer3D = AudioStreamPlayer3D.new()
	p.name = name
	p.bus = &"World"
	p.volume_db = db
	p.max_distance = loop_max_distance if is_loop else loop_max_distance * 0.7
	p.unit_size = loop_unit_size
	p.attenuation_model = AudioStreamPlayer3D.ATTENUATION_INVERSE_DISTANCE
	add_child(p)
	return p


func _load_stream(player: AudioStreamPlayer3D, sfx_id: StringName, loop: bool) -> void:
	var path: String = SFX_BASE_PATH + String(sfx_id) + ".ogg"
	if not ResourceLoader.exists(path):
		return  # silent fallback when audio file not yet produced
	var stream: AudioStream = load(path) as AudioStream
	if stream is AudioStreamOggVorbis:
		(stream as AudioStreamOggVorbis).loop = loop
	player.stream = stream


func _process(delta: float) -> void:
	if _stopped or _accent_player == null or _accent_player.stream == null:
		return
	_accent_timer += delta
	if _accent_timer >= _accent_target:
		_accent_player.play()
		_schedule_next_accent()


func _schedule_next_accent() -> void:
	_accent_timer = 0.0
	_accent_target = _rng.randf_range(accent_interval_min_s, accent_interval_max_s)


func _on_died() -> void:
	stop()


func stop() -> void:
	_stopped = true
	if _loop_player != null and _loop_player.playing:
		_loop_player.stop()
	if _accent_player != null and _accent_player.playing:
		_accent_player.stop()
