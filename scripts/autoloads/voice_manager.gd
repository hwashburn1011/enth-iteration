extends Node
## VoiceManager — global voice grunt + narrator controller. Handles per-NPC
## grunt playback during dialogue, reverb based on environment, reactive
## grunts on gameplay events, and narrator track playback.
##
## Add to project autoloads as "VoiceManager".

signal grunt_played(npc_id: StringName, grunt_id: StringName)
signal narrator_started(track_id: StringName)
signal narrator_finished(track_id: StringName)

const VOICE_BUS: StringName = &"Voice"

var current_environment: StringName = &"dry"
var _last_grunt_per_npc: Dictionary = {}  ## npc_id -> last grunt id (for variation)
var _grunt_player: AudioStreamPlayer
var _narrator_player: AudioStreamPlayer
var _reactive_player: AudioStreamPlayer


func _ready() -> void:
	_setup_players()
	_subscribe_to_events()


func _setup_players() -> void:
	_grunt_player = AudioStreamPlayer.new()
	_grunt_player.name = "GruntPlayer"
	_grunt_player.bus = VOICE_BUS
	add_child(_grunt_player)

	_narrator_player = AudioStreamPlayer.new()
	_narrator_player.name = "NarratorPlayer"
	_narrator_player.bus = VOICE_BUS
	_narrator_player.finished.connect(_on_narrator_finished)
	add_child(_narrator_player)

	_reactive_player = AudioStreamPlayer.new()
	_reactive_player.name = "ReactivePlayer"
	_reactive_player.bus = VOICE_BUS
	add_child(_reactive_player)


func _subscribe_to_events() -> void:
	if Engine.has_singleton("EventBus") or has_node("/root/EventBus"):
		var bus: Node = get_node("/root/EventBus")
		if bus.has_signal("dialogue_line_started"):
			bus.dialogue_line_started.connect(_on_dialogue_line_started)
		if bus.has_signal("player_damaged"):
			bus.player_damaged.connect(_on_player_damaged)
		if bus.has_signal("player_died"):
			bus.player_died.connect(_on_player_died)
		if bus.has_signal("player_leveled_up"):
			bus.player_leveled_up.connect(_on_player_leveled_up)
		if bus.has_signal("zone_environment_changed"):
			bus.zone_environment_changed.connect(_on_environment_changed)


# === DIALOGUE GRUNTS ===

func play_grunt(npc_id: StringName, emotion: StringName = &"neutral") -> void:
	var last: StringName = _last_grunt_per_npc.get(npc_id, &"")
	var grunt_id: StringName = VoiceDatabase.get_random_grunt(npc_id, emotion, last)
	if grunt_id == &"":
		return
	_last_grunt_per_npc[npc_id] = grunt_id
	var voice: Dictionary = VoiceDatabase.get_npc_voice(npc_id)

	var path: String = VoiceDatabase.get_file_path(grunt_id)
	if not ResourceLoader.exists(path):
		return  # silent fallback when audio not yet produced
	var stream: AudioStream = load(path)
	if stream == null:
		return

	_grunt_player.stream = stream
	_grunt_player.pitch_scale = voice.get("pitch", 1.0)
	_grunt_player.volume_db = voice.get("volume_db", 0.0)
	_grunt_player.bus = VOICE_BUS
	_grunt_player.play()
	grunt_played.emit(npc_id, grunt_id)


func _on_dialogue_line_started(npc_id: StringName, line_emotion: StringName) -> void:
	play_grunt(npc_id, line_emotion)


# === REACTIVE GRUNTS ===

func play_reactive(grunt_key: StringName) -> void:
	var grunt_id: StringName = VoiceDatabase.REACTIVE_GRUNTS.get(grunt_key, &"")
	if grunt_id == &"":
		return
	var path: String = VoiceDatabase.get_file_path(grunt_id)
	if not ResourceLoader.exists(path):
		return
	var stream: AudioStream = load(path)
	if stream == null:
		return
	_reactive_player.stream = stream
	_reactive_player.pitch_scale = 1.0
	_reactive_player.play()


func _on_player_damaged(amount: float) -> void:
	if amount < 10.0:
		play_reactive(&"hit_light")
	elif amount < 25.0:
		play_reactive(&"hit_med")
	else:
		play_reactive(&"hit_heavy")


func _on_player_died() -> void:
	play_reactive(&"death")


func _on_player_leveled_up(_new_level: int) -> void:
	play_reactive(&"level_up")


# === NARRATOR ===

func play_narrator(track_key: StringName) -> void:
	var path: String = VoiceDatabase.NARRATOR_TRACKS.get(track_key, "")
	if path == "" or not ResourceLoader.exists(path):
		return
	var stream: AudioStream = load(path)
	if stream == null:
		return
	_narrator_player.stream = stream
	_narrator_player.play()
	narrator_started.emit(track_key)


func _on_narrator_finished() -> void:
	narrator_finished.emit(&"")


func stop_narrator() -> void:
	if _narrator_player.playing:
		_narrator_player.stop()


# === ENVIRONMENT REVERB ===

func _on_environment_changed(env: StringName) -> void:
	current_environment = env
	# Apply bus effect based on environment.
	# Reverb effect mapping is configured in the audio bus layout asset.


# === COMBAT CALLOUTS ===

func emit_combat_callout(speaker_npc_id: StringName) -> String:
	## Returns the callout text — caller should display it as a subtitle.
	## Plays a grunt to accompany.
	var callout_text: String = VoiceDatabase.get_random_callout()
	play_grunt(speaker_npc_id, &"surprised")
	return callout_text


# === SAVE / LOAD ===

func to_save_data() -> Dictionary:
	var grunts_str: Dictionary = {}
	for k: StringName in _last_grunt_per_npc.keys():
		grunts_str[String(k)] = String(_last_grunt_per_npc[k])
	return {
		"current_environment": String(current_environment),
		"last_grunt_per_npc": grunts_str,
	}


func from_save_data(data: Dictionary) -> void:
	current_environment = StringName(data.get("current_environment", "dry"))
	_last_grunt_per_npc.clear()
	for k in data.get("last_grunt_per_npc", {}).keys():
		_last_grunt_per_npc[StringName(k)] = StringName(data["last_grunt_per_npc"][k])
