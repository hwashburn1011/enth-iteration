class_name AudioManagerClass
extends Node
## Manages music playback with crossfade and pooled SFX via EventBus triggers.

var _music_player: AudioStreamPlayer = null
var _music_tween: Tween = null
var _sfx_pool: Array[AudioStreamPlayer] = []
var _current_track: String = ""

const SFX_POOL_SIZE: int = 8

const MUSIC_TRACKS: Dictionary = {
	"town_ambient": "res://assets/audio/music/town_ambient.wav",
	"dungeon_ambient": "res://assets/audio/music/dungeon_ambient.wav",
	"combat_music": "res://assets/audio/music/combat_music.wav",
	"boss_music": "res://assets/audio/music/boss_music.wav",
}

const SFX_CLIPS: Dictionary = {
	"attack_hit": "res://assets/audio/sfx/attack_hit.wav",
	"attack_miss": "res://assets/audio/sfx/attack_miss.wav",
	"dash": "res://assets/audio/sfx/dash.wav",
	"pickup": "res://assets/audio/sfx/pickup.wav",
	"hurt": "res://assets/audio/sfx/hurt.wav",
	"death": "res://assets/audio/sfx/death.wav",
	"level_up": "res://assets/audio/sfx/level_up.wav",
	"menu_click": "res://assets/audio/sfx/menu_click.wav",
	"portal_activate": "res://assets/audio/sfx/portal_activate.wav",
	"container_open": "res://assets/audio/sfx/container_open.wav",
}


func _ready() -> void:
	# AudioManager must run even while game is paused (dialogue pauses tree)
	process_mode = Node.PROCESS_MODE_ALWAYS

	# Music player — PROCESS_MODE_ALWAYS so it plays during dialogue pause
	_music_player = AudioStreamPlayer.new()
	# Phase 6 #47: route music to Music bus if it exists, otherwise Master
	var music_bus: StringName = &"Music" if AudioServer.get_bus_index(&"Music") >= 0 else &"Master"
	_music_player.bus = music_bus
	_music_player.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(_music_player)

	# Phase 6 #47: set default bus volumes — music slightly below SFX so
	# combat SFX don't get buried. Master 100%, Music 80%, SFX 100%.
	_apply_default_bus_volumes()

	# SFX pool
	var sfx_bus: StringName = &"SFX" if AudioServer.get_bus_index(&"SFX") >= 0 else &"Master"
	for i: int in SFX_POOL_SIZE:
		var player: AudioStreamPlayer = AudioStreamPlayer.new()
		player.bus = sfx_bus
		add_child(player)
		_sfx_pool.append(player)

	# Connect EventBus triggers
	EventBus.damage_dealt.connect(_on_damage_dealt)
	EventBus.player_dashed.connect(_on_player_dashed)
	EventBus.item_collected.connect(_on_item_collected)
	EventBus.player_died.connect(_on_player_died)
	EventBus.player_leveled_up.connect(_on_player_leveled_up)
	EventBus.portal_used.connect(_on_portal_used)
	EventBus.scene_changed.connect(_on_scene_changed)
	EventBus.dialogue_ended.connect(_on_dialogue_ended_audio)


var _pending_stream: AudioStream = null

func _process(_delta: float) -> void:
	# Keep retrying until music actually plays
	if _pending_stream != null and not _music_player.playing:
		if not get_tree().paused:
			_music_player.stream = _pending_stream
			# Ensure loop mode is set
			if _music_player.stream is AudioStreamWAV:
				(_music_player.stream as AudioStreamWAV).loop_mode = AudioStreamWAV.LOOP_FORWARD
			_music_player.play()
			if _music_player.playing:
				_pending_stream = null
	# Also check if music stopped (non-looping track ended) and restart
	elif _music_player.stream != null and not _music_player.playing and _current_track != "":
		if _music_player.stream is AudioStreamWAV:
			(_music_player.stream as AudioStreamWAV).loop_mode = AudioStreamWAV.LOOP_FORWARD
		if not get_tree().paused:
			_music_player.play()


func play_music(track_name: String, fade_duration: float = 1.0) -> void:
	if track_name == _current_track:
		return

	# Check the track exists BEFORE mutating _current_track. The previous
	# order set _current_track first then fell through to stop_music when
	# the file was missing — calling play_music("boss_music") with a
	# placeholder asset would silence the dungeon ambient and leave the
	# scene with no music until something else triggered a track change.
	var path: String = MUSIC_TRACKS.get(track_name, "") as String
	if path.is_empty() or not ResourceLoader.exists(path):
		push_warning("AudioManager: track '%s' missing — keeping current music" % track_name)
		return
	_current_track = track_name

	var stream: AudioStream = load(path) as AudioStream
	if stream == null:
		push_warning("AudioManager: '%s' is a placeholder — no audio data" % track_name)
		return
	# Enable looping for music
	if stream is AudioStreamWAV:
		(stream as AudioStreamWAV).loop_mode = AudioStreamWAV.LOOP_FORWARD
		(stream as AudioStreamWAV).loop_end = -1

	if _music_player.playing:
		# Crossfade
		if _music_tween and _music_tween.is_running():
			_music_tween.kill()
		_music_tween = create_tween()
		_music_tween.tween_property(_music_player, "volume_db", -40.0, fade_duration * 0.5)
		_music_tween.tween_callback(func() -> void:
			_music_player.stream = stream
			_music_player.play()
		)
		_music_tween.tween_property(_music_player, "volume_db", 0.0, fade_duration * 0.5)
	else:
		_music_player.stream = stream
		_music_player.volume_db = 0.0
		# Deferred play — direct play() fails during scene transitions
		_music_player.play.call_deferred()
		# Also set pending flag for _process retry
		_pending_stream = stream


func play_sfx(sfx_name: String, _position: Vector3 = Vector3.ZERO) -> void:
	var path: String = SFX_CLIPS.get(sfx_name, "") as String
	if path.is_empty() or not ResourceLoader.exists(path):
		return
	var stream: AudioStream = load(path) as AudioStream
	if stream == null:
		return
	# Find free player in pool
	for player: AudioStreamPlayer in _sfx_pool:
		if not player.playing:
			player.stream = stream
			player.play()
			return
	# All busy — use first
	_sfx_pool[0].stream = stream
	_sfx_pool[0].play()


func stop_music(fade_duration: float = 1.0) -> void:
	_current_track = ""
	if not _music_player.playing:
		return
	if _music_tween and _music_tween.is_running():
		_music_tween.kill()
	_music_tween = create_tween()
	_music_tween.tween_property(_music_player, "volume_db", -40.0, fade_duration)
	_music_tween.tween_callback(_music_player.stop)


# --- EventBus SFX triggers ---

func _on_damage_dealt(_amount: int, _source: Node, target: Node, _type: StringName) -> void:
	# Differentiate "player landing a hit" from "player getting hit". Without
	# this, both events played attack_hit and the dedicated hurt.wav cue
	# (already authored in assets/audio/sfx/) was dead. The hurt feedback —
	# screen shake + red vignette + knockback in player_hurt_state — had no
	# audio anchor.
	if target != null and target.is_in_group(&"player"):
		play_sfx("hurt")
	else:
		play_sfx("attack_hit")


func _on_player_dashed(_from: Vector3, _to: Vector3) -> void:
	play_sfx("dash")


func _on_item_collected(_item: Resource) -> void:
	play_sfx("pickup")


func _on_player_died(_pos: Vector3) -> void:
	play_sfx("death")


func _on_player_leveled_up(_new_level: int) -> void:
	play_sfx("level_up")


func _on_portal_used() -> void:
	play_sfx("portal_activate")


func _on_dialogue_ended_audio() -> void:
	# Retry music play after dialogue ends (tree was paused, play() was ignored)
	if _music_player.stream != null and not _music_player.playing:
		_music_player.play()


func _on_scene_changed(path: String) -> void:
	if "town" in path.to_lower():
		play_music("town_ambient")
	elif "dungeon" in path.to_lower():
		play_music("dungeon_ambient")


## Phase 6 #47 — apply balanced default bus volumes on startup.
## Music at 80% prevents combat SFX from being buried by the soundtrack.
func _apply_default_bus_volumes() -> void:
	var music_idx: int = AudioServer.get_bus_index(&"Music")
	if music_idx >= 0:
		AudioServer.set_bus_volume_db(music_idx, linear_to_db(0.8))
	var sfx_idx: int = AudioServer.get_bus_index(&"SFX")
	if sfx_idx >= 0:
		AudioServer.set_bus_volume_db(sfx_idx, linear_to_db(1.0))
