class_name DungeonEntranceSfxBed
extends Node3D

## Per-entrance localized ambient SFX bed. Where the
## AmbientSoundscapeMixer handles broad regional ambience (cliff wind,
## ruin stone groans), this bed handles the close-up, specific sounds
## that should only be audible when the player is *at* the portal:
##
##   server_room    → server hum drone + occasional fan whirs + key clicks
##   memory_vaults  → paper rustle + distant choir + ink scrape
##   corrupted_wilds → vine creak + sap drip + distant wind chimes (broken)
##   final_vault    → seal pulse drone + chain rattle + distant void echo
##
## Spawns up to 4 AudioStreamPlayer3D children with the configured loops
## at varying volumes. Activates on player entry to a presence Area3D,
## tweens to the active volumes over 1.5s, fades back out on exit.
##
## Required scene shape:
##   DungeonEntranceSfxBed (Node3D + this script)
##     Presence (Area3D + CollisionShape3D — approach radius)
##     [child AudioStreamPlayer3D nodes are spawned at runtime]
##
## Configure via inspector:
##   entrance_id — must match an EntranceSfxProfile key

const PROFILES: Dictionary = {
	&"server_room": {
		"loops": [
			{"sfx_id": &"amb_server_hum_drone",     "db": -10.0, "pitch": 1.0},
			{"sfx_id": &"amb_server_fan_whirr",     "db": -16.0, "pitch": 0.95},
			{"sfx_id": &"amb_server_key_clicks",    "db": -22.0, "pitch": 1.05},
			{"sfx_id": &"amb_server_data_chime",    "db": -20.0, "pitch": 1.0},
		],
	},
	&"memory_vaults": {
		"loops": [
			{"sfx_id": &"amb_vault_paper_rustle",   "db": -14.0, "pitch": 1.0},
			{"sfx_id": &"amb_vault_choir_distant",  "db": -18.0, "pitch": 1.0},
			{"sfx_id": &"amb_vault_ink_scrape",     "db": -22.0, "pitch": 0.92},
			{"sfx_id": &"amb_vault_dust_settle",    "db": -20.0, "pitch": 1.0},
		],
	},
	&"corrupted_wilds": {
		"loops": [
			{"sfx_id": &"amb_wilds_vine_creak",     "db": -12.0, "pitch": 1.0},
			{"sfx_id": &"amb_wilds_sap_drip",       "db": -18.0, "pitch": 1.0},
			{"sfx_id": &"amb_wilds_chimes_broken",  "db": -20.0, "pitch": 0.85},
			{"sfx_id": &"amb_wilds_breath_low",     "db": -16.0, "pitch": 1.0},
		],
	},
	&"final_vault": {
		"loops": [
			{"sfx_id": &"amb_final_seal_pulse",     "db": -10.0, "pitch": 1.0},
			{"sfx_id": &"amb_final_chain_rattle",   "db": -16.0, "pitch": 1.0},
			{"sfx_id": &"amb_final_void_echo",      "db": -12.0, "pitch": 0.9},
			{"sfx_id": &"amb_final_breath_distant", "db": -22.0, "pitch": 1.0},
		],
	},
}

const FADE_IN_S: float = 1.5
const FADE_OUT_S: float = 2.0
const SILENT_DB: float = -80.0

@export var entrance_id: StringName = &""
@export var max_distance: float = 18.0  ## per-player AudioStreamPlayer3D audible range

@onready var _presence: Area3D = $Presence if has_node("Presence") else null

var _players: Array[AudioStreamPlayer3D] = []
var _player_in_range: bool = false
var _tweens: Dictionary = {}  # AudioStreamPlayer3D → Tween


func _ready() -> void:
	_build_players()
	if _presence != null:
		_presence.body_entered.connect(_on_player_entered)
		_presence.body_exited.connect(_on_player_exited)


# === BUILD ===

func _build_players() -> void:
	if entrance_id == &"":
		return
	var profile: Dictionary = PROFILES.get(entrance_id, {})
	var loops: Array = profile.get("loops", [])
	for layer in loops:
		var p: AudioStreamPlayer3D = AudioStreamPlayer3D.new()
		p.name = "Loop_" + String(layer.get("sfx_id", &""))
		p.max_distance = max_distance
		p.unit_size = 4.0
		p.volume_db = SILENT_DB
		p.bus = &"World"
		p.pitch_scale = float(layer.get("pitch", 1.0))
		add_child(p)
		_load_and_play(p, layer.get("sfx_id", &""))
		p.set_meta(&"target_db", float(layer.get("db", -16.0)))
		_players.append(p)


func _load_and_play(player: AudioStreamPlayer3D, sfx_id: StringName) -> void:
	if sfx_id == &"":
		return
	# Try several conventional locations for the loop file
	var candidates: Array[String] = [
		"res://assets/audio/sfx/ambient/" + String(sfx_id) + ".ogg",
		"res://assets/audio/sfx/loops/" + String(sfx_id) + ".ogg",
		"res://assets/audio/ambient/" + String(sfx_id) + ".ogg",
	]
	for path in candidates:
		if ResourceLoader.exists(path):
			var stream: AudioStream = load(path) as AudioStream
			if stream is AudioStreamOggVorbis:
				(stream as AudioStreamOggVorbis).loop = true
			player.stream = stream
			player.play()
			return
	# Silent placeholder when audio file isn't produced yet — the rest
	# of the system still works on tween/fade values


# === FADE ===

func fade_in() -> void:
	for p in _players:
		var target: float = float(p.get_meta(&"target_db", -16.0))
		_tween_volume(p, target, FADE_IN_S)


func fade_out() -> void:
	for p in _players:
		_tween_volume(p, SILENT_DB, FADE_OUT_S)


func _tween_volume(p: AudioStreamPlayer3D, target_db: float, duration: float) -> void:
	if _tweens.has(p):
		var prev: Tween = _tweens[p]
		if is_instance_valid(prev):
			prev.kill()
	var tw: Tween = create_tween()
	tw.tween_property(p, "volume_db", target_db, duration)
	_tweens[p] = tw


# === EVENTS ===

func _on_player_entered(body: Node3D) -> void:
	if not body.is_in_group(&"player"):
		return
	if _player_in_range:
		return
	_player_in_range = true
	fade_in()


func _on_player_exited(body: Node3D) -> void:
	if not body.is_in_group(&"player"):
		return
	if not _player_in_range:
		return
	_player_in_range = false
	fade_out()
