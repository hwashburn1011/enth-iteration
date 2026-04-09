class_name LoungeStage
extends Node3D

## The Underground Lounge stage. Sync (the musician NPC) shows up to
## perform between 22:00 and 02:00 every in-game day. While he's on
## stage:
##   - The lounge zone music crossfades to a special "lounge_live_set"
##     track via MusicManager
##   - The stage spotlight pulses gently in time with the implied beat
##   - Sync's dialogue pool unlocks the "lounge_set" lines
##   - Tip jar interaction becomes available (player can tip from
##     currency for an affinity boost + a small buff)
##
## When Sync is off-shift, the jukebox in the back corner takes over —
## see Jukebox component for that side.
##
## Required scene shape:
##   LoungeStage (Node3D + this script)
##     SyncAnchor (Marker3D — where Sync stands while performing)
##     Spotlight (SpotLight3D — pulses in time)
##     TipJar (Area3D — player interact range)
##     [optional] AudienceAnchors (Node3D with Marker3D children for
##                ambient audience NPCs)
##
## Configure via inspector:
##   sync_npc_id            — NPC database id for Sync
##   live_set_track_id      — MusicManager zone track to swap to
##   set_start_hour         — 22 default
##   set_end_hour           — 2 default (rolls past midnight)

signal sync_arrived
signal sync_departed
signal tip_jar_used(amount: int, response_line: String)

const TIP_AMOUNT: int = 25
const SPOTLIGHT_PULSE_PERIOD_S: float = 1.6  # 75 BPM-ish
const SPOTLIGHT_PULSE_AMPLITUDE: float = 0.35

@export var sync_npc_id: StringName = &"sync"
@export var live_set_track_id: StringName = &"lounge_live_set"
@export var jukebox_track_id: StringName = &"lounge_jukebox_loop"
@export var set_start_hour: int = 22
@export var set_end_hour: int = 2  # rolls past midnight

@onready var _spotlight: SpotLight3D = $Spotlight if has_node("Spotlight") else null
@onready var _tip_jar: Area3D = $TipJar if has_node("TipJar") else null
@onready var _sync_anchor: Marker3D = $SyncAnchor if has_node("SyncAnchor") else null

var _sync_present: bool = false
var _sync_node: Node3D
var _spotlight_base_energy: float = 0.0
var _player_at_jar: bool = false
var _last_tip_hour_total: int = -100000


func _ready() -> void:
	if _spotlight != null:
		_spotlight_base_energy = _spotlight.light_energy
	if _tip_jar != null:
		_tip_jar.body_entered.connect(_on_jar_entered)
		_tip_jar.body_exited.connect(_on_jar_exited)
		_tip_jar.collision_layer = 0
		_tip_jar.collision_mask = 1 << 0
		_tip_jar.monitorable = false
	if has_node("/root/DayNightController"):
		var dnc: Node = get_node("/root/DayNightController")
		if dnc.has_signal("hour_changed"):
			dnc.hour_changed.connect(_on_hour_changed)
	# Apply current schedule state
	_evaluate_sync_schedule()


func _process(_delta: float) -> void:
	if _sync_present and _spotlight != null:
		_pulse_spotlight()


# === SCHEDULE ===

func _evaluate_sync_schedule() -> void:
	var hour: int = _current_hour()
	var should_be_present: bool = _hour_in_window(hour, set_start_hour, set_end_hour)
	if should_be_present and not _sync_present:
		_summon_sync()
	elif not should_be_present and _sync_present:
		_dismiss_sync()


func _hour_in_window(hour: int, start_h: int, end_h: int) -> bool:
	if start_h <= end_h:
		return hour >= start_h and hour < end_h
	# Wraps past midnight
	return hour >= start_h or hour < end_h


# === SYNC ===

func _summon_sync() -> void:
	_sync_present = true
	sync_arrived.emit()

	# Swap to live set track
	if has_node("/root/MusicManager"):
		var mm: Node = get_node("/root/MusicManager")
		if mm.has_method("play_zone_track"):
			mm.play_zone_track(live_set_track_id)
		if mm.has_method("play_sting"):
			mm.play_sting(&"sting_lounge_set_intro")

	# Spawn Sync at the anchor (NPC system handles the actual model)
	if has_node("/root/NPCManager") and _sync_anchor != null:
		var npc_mgr: Node = get_node("/root/NPCManager")
		if npc_mgr.has_method("spawn_npc_at"):
			_sync_node = npc_mgr.spawn_npc_at(sync_npc_id, _sync_anchor.global_position) as Node3D

	# Trigger Sync's "set begins" dialogue line
	if has_node("/root/DialogueManager"):
		var dm: Node = get_node("/root/DialogueManager")
		if dm.has_method("show_line"):
			dm.show_line("Sync", "Welcome to the second set.", &"voice_sync")

	# Audience NPCs perk up
	if has_node("/root/EventBus"):
		var bus: Node = get_node("/root/EventBus")
		if bus.has_signal("lounge_set_started"):
			bus.emit_signal("lounge_set_started")


func _dismiss_sync() -> void:
	_sync_present = false
	sync_departed.emit()

	# Swap back to the jukebox loop (or default lounge ambience)
	if has_node("/root/MusicManager"):
		var mm: Node = get_node("/root/MusicManager")
		if mm.has_method("play_zone_track"):
			mm.play_zone_track(jukebox_track_id)

	# Despawn Sync
	if _sync_node != null and is_instance_valid(_sync_node):
		_sync_node.queue_free()
		_sync_node = null

	# Restore spotlight to base energy
	if _spotlight != null:
		_spotlight.light_energy = _spotlight_base_energy

	if has_node("/root/EventBus"):
		var bus: Node = get_node("/root/EventBus")
		if bus.has_signal("lounge_set_ended"):
			bus.emit_signal("lounge_set_ended")


# === SPOTLIGHT PULSE ===

func _pulse_spotlight() -> void:
	if _spotlight == null:
		return
	var t: float = Time.get_ticks_msec() / 1000.0
	var pulse: float = sin(t * (TAU / SPOTLIGHT_PULSE_PERIOD_S)) * SPOTLIGHT_PULSE_AMPLITUDE
	_spotlight.light_energy = _spotlight_base_energy * (1.0 + pulse)


# === TIP JAR ===

func can_tip() -> bool:
	if not _player_at_jar:
		return false
	if not _sync_present:
		return false
	# One tip per set
	var elapsed: int = _current_hour_total() - _last_tip_hour_total
	if elapsed < 4:
		return false
	return true


func tip_sync() -> bool:
	if not can_tip():
		return false
	if has_node("/root/EconomyManager"):
		var em: Node = get_node("/root/EconomyManager")
		if em.has_method("spend"):
			if not em.spend(&"data_credits", TIP_AMOUNT):
				return false

	_last_tip_hour_total = _current_hour_total()

	# Pump Sync's affinity
	if has_node("/root/AffinityManager"):
		var am: Node = get_node("/root/AffinityManager")
		if am.has_method("add_affinity"):
			am.add_affinity(sync_npc_id, 5)

	# Grant a small "patron of the arts" buff
	if has_node("/root/BuffManager"):
		var bm: Node = get_node("/root/BuffManager")
		if bm.has_method("apply_timed_buff"):
			bm.apply_timed_buff(&"patron_of_arts",
				{&"xp_gain_mult": 1.05},
				600)  # 10 in-game minutes

	# Sync acknowledges with a different line each time
	var responses: Array[String] = [
		"Appreciated. This one's for you.",
		"On the house? Not really. But thanks.",
		"You've got taste. Stick around.",
		"Heh. I'll play the slow one next.",
	]
	var response: String = responses[randi() % responses.size()]
	if has_node("/root/DialogueManager"):
		var dm: Node = get_node("/root/DialogueManager")
		if dm.has_method("show_line"):
			dm.show_line("Sync", response, &"voice_sync")

	tip_jar_used.emit(TIP_AMOUNT, response)
	return true


# === EVENTS ===

func _on_hour_changed(_h: int) -> void:
	_evaluate_sync_schedule()


func _on_jar_entered(body: Node3D) -> void:
	if body.is_in_group(&"player"):
		_player_at_jar = true


func _on_jar_exited(body: Node3D) -> void:
	if body.is_in_group(&"player"):
		_player_at_jar = false


# === HELPERS ===

func _current_hour() -> int:
	if not has_node("/root/DayNightController"):
		return 12
	var dnc: Node = get_node("/root/DayNightController")
	if dnc.has_method("get_current_hour"):
		return int(dnc.get_current_hour())
	return 12


func _current_hour_total() -> int:
	if not has_node("/root/DayNightController"):
		return 0
	var dnc: Node = get_node("/root/DayNightController")
	var day: int = 0
	var hour: int = 0
	if "current_day" in dnc:
		day = int(dnc.current_day)
	if dnc.has_method("get_current_hour"):
		hour = int(dnc.get_current_hour())
	return day * 24 + hour
