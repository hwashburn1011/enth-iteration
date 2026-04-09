class_name BossPhaseAmbientSfx
extends Node

## Per-phase ambient SFX hook for the Compiler boss (Epic 07 task 39).
## Crossfades between 3 looping ambient stems as the boss progresses
## through its phases. Each phase has its own audio identity:
##
##   Phase 1 — clean server-rack hum + occasional cyan LED ping
##   Phase 2 — distorted glitch tone + magenta crackle bursts
##   Phase 3 — corrupted low rumble + scrolling code-rivulet whisper
##
## The crossfade is 1.5 seconds when phase changes, smoother than a hard
## cut, communicating the phase shift musically as well as visually.
##
## Required scene shape:
##   BossPhaseAmbientSfx (Node + this script)
##     PhaseStream1 (AudioStreamPlayer3D, paused, stream loaded externally)
##     PhaseStream2 (AudioStreamPlayer3D)
##     PhaseStream3 (AudioStreamPlayer3D)
##
## Hookup from boss factory:
##   var ambient: BossPhaseAmbientSfx = boss.get_node("BossPhaseAmbientSfx")
##   ambient.set_phase(0)  # initial phase 1
##   # Later, on phase transition:
##   ambient.set_phase(1)  # crossfade to phase 2

@export var crossfade_duration_s: float = 1.5
@export var max_volume_db: float = 0.0

@export var phase_1_stream_path: String = "res://assets/audio/ambient/compiler_phase_1_loop.ogg"
@export var phase_2_stream_path: String = "res://assets/audio/ambient/compiler_phase_2_loop.ogg"
@export var phase_3_stream_path: String = "res://assets/audio/ambient/compiler_phase_3_loop.ogg"

var _players: Array[AudioStreamPlayer3D] = []
var _current_phase: int = -1
var _crossfade_tween: Tween


func _ready() -> void:
	_create_players()


func _create_players() -> void:
	for i in range(3):
		var p: AudioStreamPlayer3D = AudioStreamPlayer3D.new()
		p.name = "PhaseStream%d" % (i + 1)
		p.volume_db = -80.0
		p.unit_size = 12.0
		p.max_distance = 60.0
		var path: String = [phase_1_stream_path, phase_2_stream_path, phase_3_stream_path][i]
		if ResourceLoader.exists(path):
			var stream: AudioStream = load(path) as AudioStream
			if stream is AudioStreamOggVorbis:
				(stream as AudioStreamOggVorbis).loop = true
			p.stream = stream
		add_child(p)
		_players.append(p)


func set_phase(phase_index: int) -> void:
	if phase_index == _current_phase:
		return
	if phase_index < 0 or phase_index >= _players.size():
		return
	# Start the new phase player if it isn't already playing
	var target: AudioStreamPlayer3D = _players[phase_index]
	if target.stream != null and not target.playing:
		target.volume_db = -80.0
		target.play()
	# Crossfade
	if _crossfade_tween != null and _crossfade_tween.is_valid():
		_crossfade_tween.kill()
	_crossfade_tween = create_tween().set_parallel(true)
	for i in range(_players.size()):
		var target_db: float = max_volume_db if i == phase_index else -80.0
		_crossfade_tween.tween_property(_players[i], "volume_db", target_db, crossfade_duration_s)
	_current_phase = phase_index


func stop_all() -> void:
	for p in _players:
		p.stop()
	_current_phase = -1
