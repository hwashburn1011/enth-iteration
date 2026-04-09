extends Node
## MusicManager — global music controller. Drives track playback, smooth
## crossfades, layered combat intensity, and boss override sequences.
##
## Add to project autoloads as "MusicManager".

signal track_changed(new_track_id: StringName)
signal combat_intensity_changed(new_intensity: int)

const FADE_DURATION: float = 1.5  ## seconds for crossfade
const BOSS_FADE_OUT: float = 1.0
const COMBAT_BUS_NAMES: Array = [&"Combat_L1", &"Combat_L2", &"Combat_L3"]

var current_track_id: StringName = &""
var current_zone_track_id: StringName = &""  ## what to return to after combat
var combat_intensity: int = 0  ## 0 none, 1 light, 2 mid, 3 intense
var boss_active: bool = false

var _zone_player: AudioStreamPlayer
var _combat_layer_players: Array[AudioStreamPlayer] = []
var _boss_player: AudioStreamPlayer
var _sting_player: AudioStreamPlayer
var _fade_tweens: Dictionary = {}  ## player_node -> Tween


func _ready() -> void:
	_setup_players()
	_subscribe_to_events()


func _setup_players() -> void:
	_zone_player = AudioStreamPlayer.new()
	_zone_player.name = "ZonePlayer"
	_zone_player.bus = &"Music"
	add_child(_zone_player)

	for i in 3:
		var p: AudioStreamPlayer = AudioStreamPlayer.new()
		p.name = "CombatLayer%d" % (i + 1)
		p.bus = &"Music"
		p.volume_db = -80.0  # silent until faded in
		add_child(p)
		_combat_layer_players.append(p)

	_boss_player = AudioStreamPlayer.new()
	_boss_player.name = "BossPlayer"
	_boss_player.bus = &"Music"
	_boss_player.volume_db = -80.0
	add_child(_boss_player)

	_sting_player = AudioStreamPlayer.new()
	_sting_player.name = "StingPlayer"
	_sting_player.bus = &"Music"
	add_child(_sting_player)


func _subscribe_to_events() -> void:
	if Engine.has_singleton("EventBus") or has_node("/root/EventBus"):
		var bus: Node = get_node("/root/EventBus")
		if bus.has_signal("zone_entered"):
			bus.zone_entered.connect(_on_zone_entered)
		if bus.has_signal("combat_started"):
			bus.combat_started.connect(_on_combat_started)
		if bus.has_signal("combat_ended"):
			bus.combat_ended.connect(_on_combat_ended)
		if bus.has_signal("combat_intensity_changed"):
			bus.combat_intensity_changed.connect(_on_combat_intensity_changed)
		if bus.has_signal("boss_intro"):
			bus.boss_intro.connect(_on_boss_intro)
		if bus.has_signal("boss_defeated"):
			bus.boss_defeated.connect(_on_boss_defeated)


# === ZONE TRACK ===

func play_zone_track(track_id: StringName) -> void:
	if current_zone_track_id == track_id:
		return
	current_zone_track_id = track_id
	if not boss_active:
		_play_track_on_player(_zone_player, track_id)
		current_track_id = track_id
		track_changed.emit(track_id)


func _on_zone_entered(zone_id: StringName, music_track_id: StringName) -> void:
	if music_track_id != &"":
		play_zone_track(music_track_id)


# === COMBAT LAYERS ===

func _on_combat_started() -> void:
	# Start combat layer 1 at normal volume, drop zone to 75%
	_load_combat_layers()
	_fade_player(_zone_player, -2.5, FADE_DURATION)  # ~75%
	_fade_player(_combat_layer_players[0], 0.0, FADE_DURATION)
	combat_intensity = 1
	combat_intensity_changed.emit(1)


func _on_combat_ended() -> void:
	# Fade out all combat layers, restore zone
	for p in _combat_layer_players:
		_fade_player(p, -80.0, FADE_DURATION)
	_fade_player(_zone_player, 0.0, FADE_DURATION)
	combat_intensity = 0
	combat_intensity_changed.emit(0)


func _on_combat_intensity_changed(new_intensity: int) -> void:
	combat_intensity = clampi(new_intensity, 0, 3)
	for i in 3:
		var target_db: float = 0.0 if i < combat_intensity else -80.0
		_fade_player(_combat_layer_players[i], target_db, FADE_DURATION)
	combat_intensity_changed.emit(combat_intensity)


func _load_combat_layers() -> void:
	const LAYER_IDS: Array[StringName] = [&"combat_l1", &"combat_l2", &"combat_l3"]
	for i in 3:
		if _combat_layer_players[i].stream == null:
			var path: String = MusicTrackDatabase.get_file_path(LAYER_IDS[i])
			if ResourceLoader.exists(path):
				_combat_layer_players[i].stream = load(path)
				_combat_layer_players[i].play()


# === BOSS OVERRIDE ===

func _on_boss_intro(boss_id: StringName) -> void:
	boss_active = true
	# Fade out current music
	_fade_player(_zone_player, -80.0, BOSS_FADE_OUT)
	for p in _combat_layer_players:
		_fade_player(p, -80.0, BOSS_FADE_OUT)
	# Play sting
	play_sting(&"boss_intro_sting")
	# Schedule boss music to fade in after sting
	await get_tree().create_timer(0.8).timeout
	var boss_track: StringName = _resolve_boss_track(boss_id)
	_play_track_on_player(_boss_player, boss_track)
	_fade_player(_boss_player, 0.0, BOSS_FADE_OUT)


func _on_boss_defeated(_boss_id: StringName) -> void:
	boss_active = false
	_fade_player(_boss_player, -80.0, BOSS_FADE_OUT)
	play_sting(&"victory_fanfare")
	# Restore zone music after sting
	await get_tree().create_timer(1.5).timeout
	if current_zone_track_id != &"":
		_play_track_on_player(_zone_player, current_zone_track_id)
		_fade_player(_zone_player, 0.0, FADE_DURATION)


func _resolve_boss_track(boss_id: StringName) -> StringName:
	const MAP: Dictionary = {
		&"corrupted_compiler":  &"boss_compiler",
		&"memory_warden":       &"boss_memory_warden",
		&"root_heart":          &"boss_root_heart",
		&"sentinel_prime":      &"boss_sentinel_prime",
		&"iteration_phantom":   &"boss_iteration_phantom",
		&"compiler_reborn":     &"boss_compiler_reborn",
	}
	return MAP.get(boss_id, &"boss_compiler")


# === STINGS ===

func play_sting(sting_id: StringName) -> void:
	var path: String = MusicTrackDatabase.get_file_path(sting_id)
	if ResourceLoader.exists(path):
		_sting_player.stream = load(path)
		_sting_player.play()


# === HELPERS ===

func _play_track_on_player(player: AudioStreamPlayer, track_id: StringName) -> void:
	var path: String = MusicTrackDatabase.get_file_path(track_id)
	if not ResourceLoader.exists(path):
		# Audio file not yet produced — silent placeholder
		return
	var stream: AudioStream = load(path)
	if stream != null:
		var track_data: Dictionary = MusicTrackDatabase.get_track(track_id)
		if track_data.get("loop", true) and stream is AudioStreamOggVorbis:
			(stream as AudioStreamOggVorbis).loop = true
		player.stream = stream
		player.play()


func _fade_player(player: AudioStreamPlayer, target_db: float, duration: float) -> void:
	# Cancel previous tween for this player
	if _fade_tweens.has(player):
		var prev_tween: Tween = _fade_tweens[player]
		if is_instance_valid(prev_tween):
			prev_tween.kill()
	var tween: Tween = create_tween()
	tween.tween_property(player, "volume_db", target_db, duration)
	_fade_tweens[player] = tween


# === SAVE / LOAD ===

func to_save_data() -> Dictionary:
	return {
		"current_zone_track_id": String(current_zone_track_id),
		"combat_intensity": combat_intensity,
	}


func from_save_data(data: Dictionary) -> void:
	current_zone_track_id = StringName(data.get("current_zone_track_id", ""))
	combat_intensity = data.get("combat_intensity", 0)
	if current_zone_track_id != &"":
		play_zone_track(current_zone_track_id)
