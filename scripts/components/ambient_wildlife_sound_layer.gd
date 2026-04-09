class_name AmbientWildlifeSoundLayer
extends Node3D

## Generic outdoor wildlife sound layer. Drops into any outdoor scene
## that needs a "this is somewhere with animals" baseline beneath the
## broader regional ambience. Owns two spatialized 3D audio loops:
##
##   - DAY layer (birds, soft chatter)
##   - NIGHT layer (crickets, owl calls)
##
## Crossfades between them at the dawn/dusk transitions so the player
## standing in a clearing at sunset hears the birds slowly give way
## to the crickets. Distinct from:
##
##   - AmbientSoundscapeMixer (per-region beds, slot-aware crossfade)
##   - AmbientLifeSpawner (atmospheric particles + audio-only flock
##     calls + bird formation drifts)
##
## This is the *third* layer — the always-on wildlife base bed that
## shouldn't depend on which named region the player is standing in.
##
## Required scene shape:
##   AmbientWildlifeSoundLayer (Node3D + this script)
##     [no children needed; AudioStreamPlayer3D children built at runtime]
##
## Configure via inspector:
##   day_loop_id    — sfx id for the day bird bed
##   night_loop_id  — sfx id for the night cricket bed
##   day_db         — max volume for day layer
##   night_db       — max volume for night layer
##   max_distance   — meters of audible range

signal layer_changed(active_phase_group: StringName)

const FADE_DURATION_S: float = 6.0
const SILENT_DB: float = -80.0
const SFX_BASE_PATH: String = "res://assets/audio/sfx/ambient/"

@export var day_loop_id: StringName = &"amb_birds_meadow_day"
@export var night_loop_id: StringName = &"amb_crickets_open"
@export var day_db: float = -14.0
@export var night_db: float = -16.0
@export var max_distance: float = 60.0
@export var unit_size: float = 8.0

var _day_player: AudioStreamPlayer3D
var _night_player: AudioStreamPlayer3D
var _current_phase_group: StringName = &""  # &"day" or &"night"
var _tweens: Dictionary = {}  # player → Tween


func _ready() -> void:
	_build_players()
	if has_node("/root/DayNightController"):
		var dnc: Node = get_node("/root/DayNightController")
		if dnc.has_signal("phase_changed"):
			dnc.phase_changed.connect(_on_phase_changed)
		if "current_phase" in dnc:
			_apply_phase(StringName(dnc.current_phase), false)
	else:
		_apply_phase(&"day", false)


# === BUILD ===

func _build_players() -> void:
	_day_player = _make_player(day_loop_id, "DayBirdLoop")
	_night_player = _make_player(night_loop_id, "NightCricketLoop")


func _make_player(sfx_id: StringName, name: String) -> AudioStreamPlayer3D:
	var p: AudioStreamPlayer3D = AudioStreamPlayer3D.new()
	p.name = name
	p.bus = &"World"
	p.max_distance = max_distance
	p.unit_size = unit_size
	p.volume_db = SILENT_DB
	add_child(p)
	_load_loop(p, sfx_id)
	return p


func _load_loop(player: AudioStreamPlayer3D, sfx_id: StringName) -> void:
	if sfx_id == &"":
		return
	var path: String = SFX_BASE_PATH + String(sfx_id) + ".ogg"
	if ResourceLoader.exists(path):
		var stream: AudioStream = load(path) as AudioStream
		if stream is AudioStreamOggVorbis:
			(stream as AudioStreamOggVorbis).loop = true
		player.stream = stream
		player.play()
	# Silent fallback when audio file isn't yet produced — still
	# usable, the tweens just won't change anything audible


# === PHASE ===

func _apply_phase(phase: StringName, animate: bool) -> void:
	# Map fine-grained phase to the day/night layer split
	var group: StringName = _phase_group(phase)
	if group == _current_phase_group:
		return
	_current_phase_group = group
	layer_changed.emit(group)

	if group == &"day":
		_fade_player(_day_player, day_db, animate)
		_fade_player(_night_player, SILENT_DB, animate)
	else:
		_fade_player(_day_player, SILENT_DB, animate)
		_fade_player(_night_player, night_db, animate)


func _phase_group(phase: StringName) -> StringName:
	# dawn + day → day group, dusk + night → night group
	if phase == &"day" or phase == &"dawn":
		return &"day"
	return &"night"


func _fade_player(player: AudioStreamPlayer3D, target_db: float, animate: bool) -> void:
	if player == null:
		return
	if not animate:
		player.volume_db = target_db
		return
	if _tweens.has(player):
		var prev: Tween = _tweens[player]
		if is_instance_valid(prev):
			prev.kill()
	var tw: Tween = create_tween()
	tw.tween_property(player, "volume_db", target_db, FADE_DURATION_S)
	_tweens[player] = tw


# === EVENTS ===

func _on_phase_changed(phase: StringName) -> void:
	_apply_phase(phase, true)
