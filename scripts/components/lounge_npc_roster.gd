class_name LoungeNpcRoster
extends Node3D

## Manages the cast of NPCs present in the Underground Lounge each
## evening. Three concurrent slots:
##
##   1. CACHE — host, present every evening (18:00 onward) until close
##              (04:00). She runs the bar, hosts dialogue, takes
##              confessions.
##   2. SYNC — handled by LoungeStage, but this roster mirrors the
##             schedule so we don't double-spawn him as an audience
##             member.
##   3. TWO REGULARS — picked from LoungeRegularsDatabase.roll_pair_for_night,
##                     deterministic per in-game day, swap on day rollover.
##
## On scene attach, this roster reads the current day-night phase and
## populates the room. On `hour_changed` it re-evaluates and
## adds/removes NPCs accordingly.
##
## Required scene shape:
##   LoungeNpcRoster (Node3D + this script)
##     CacheAnchor (Marker3D — Cache's spot behind the bar)
##     RegularAnchor1 (Marker3D — first regular's seat fallback)
##     RegularAnchor2 (Marker3D — second regular's seat fallback)
##     [optional] SeatAnchors (Node3D with Marker3D children matching
##                preferred_seat keys from the regulars database)

signal cache_arrived
signal cache_departed
signal regulars_changed(regular_ids: Array)

const CACHE_ARRIVE_HOUR: int = 18
const CACHE_DEPART_HOUR: int = 4  # wraps past midnight

@export var cache_npc_id: StringName = &"cache"
@export var sync_npc_id: StringName = &"sync"

@onready var _cache_anchor: Marker3D = $CacheAnchor if has_node("CacheAnchor") else null
@onready var _regular_anchors: Array[Marker3D] = [
	$RegularAnchor1 if has_node("RegularAnchor1") else null,
	$RegularAnchor2 if has_node("RegularAnchor2") else null,
]
@onready var _seat_anchors: Node3D = $SeatAnchors if has_node("SeatAnchors") else null

var _cache_node: Node3D
var _regular_nodes: Array[Node3D] = []
var _current_regular_ids: Array[StringName] = []
var _cache_present: bool = false
var _last_evaluated_day: int = -1


func _ready() -> void:
	if has_node("/root/DayNightController"):
		var dnc: Node = get_node("/root/DayNightController")
		if dnc.has_signal("hour_changed"):
			dnc.hour_changed.connect(_on_hour_changed)
		if dnc.has_signal("day_advanced"):
			dnc.day_advanced.connect(_on_day_advanced)
	_evaluate_roster()


# === EVALUATE ===

func _evaluate_roster() -> void:
	_evaluate_cache()
	_evaluate_regulars()


# === CACHE ===

func _evaluate_cache() -> void:
	var hour: int = _current_hour()
	var should_be_present: bool = _hour_in_window(hour, CACHE_ARRIVE_HOUR, CACHE_DEPART_HOUR)
	if should_be_present and not _cache_present:
		_summon_cache()
	elif not should_be_present and _cache_present:
		_dismiss_cache()


func _summon_cache() -> void:
	_cache_present = true
	if has_node("/root/NPCManager") and _cache_anchor != null:
		var nm: Node = get_node("/root/NPCManager")
		if nm.has_method("spawn_npc_at"):
			_cache_node = nm.spawn_npc_at(cache_npc_id, _cache_anchor.global_position) as Node3D
	cache_arrived.emit()


func _dismiss_cache() -> void:
	_cache_present = false
	if _cache_node != null and is_instance_valid(_cache_node):
		_cache_node.queue_free()
		_cache_node = null
	cache_departed.emit()


# === REGULARS ===

func _evaluate_regulars() -> void:
	var day: int = _current_day()
	if day == _last_evaluated_day and not _regular_nodes.is_empty():
		return
	_last_evaluated_day = day

	# Clear yesterday's regulars
	_clear_regulars()

	# Roll tonight's pair
	var phase: StringName = _current_phase()
	if phase != &"night" and phase != &"dusk":
		return  # regulars only show in evening phases
	var pair: Array[StringName] = LoungeRegularsDatabase.roll_pair_for_night(day, _current_iteration(), phase)
	_current_regular_ids = pair
	regulars_changed.emit(pair)

	# Spawn each regular at their preferred seat (or fallback anchor)
	for i in pair.size():
		var regular_id: StringName = pair[i]
		var entry: Dictionary = LoungeRegularsDatabase.get_regular(regular_id)
		if entry.is_empty():
			continue
		var anchor_pos: Vector3 = _resolve_seat(entry.get("preferred_seat", &""), i)
		_spawn_regular(regular_id, anchor_pos)


func _resolve_seat(preferred_seat: StringName, fallback_index: int) -> Vector3:
	# Try preferred seat marker first
	if _seat_anchors != null and preferred_seat != &"":
		var node: Node3D = _seat_anchors.get_node_or_null(String(preferred_seat)) as Node3D
		if node != null:
			return node.global_position
	# Fallback to numbered anchor
	if fallback_index < _regular_anchors.size():
		var anchor: Marker3D = _regular_anchors[fallback_index]
		if anchor != null:
			return anchor.global_position
	return global_position


func _spawn_regular(regular_id: StringName, position: Vector3) -> void:
	if not has_node("/root/NPCManager"):
		return
	var nm: Node = get_node("/root/NPCManager")
	if not nm.has_method("spawn_npc_at"):
		return
	var inst: Node3D = nm.spawn_npc_at(regular_id, position) as Node3D
	if inst == null:
		return
	# Stash the regular's lines pool on the instance so the dialogue
	# system can pull from it on interact
	var entry: Dictionary = LoungeRegularsDatabase.get_regular(regular_id)
	inst.set_meta(&"lounge_regular_lines", entry.get("lines", []))
	inst.set_meta(&"lounge_regular_mood", entry.get("mood", &""))
	_regular_nodes.append(inst)


func _clear_regulars() -> void:
	for node in _regular_nodes:
		if is_instance_valid(node):
			node.queue_free()
	_regular_nodes.clear()
	_current_regular_ids.clear()


# === EVENTS ===

func _on_hour_changed(_h: int) -> void:
	_evaluate_roster()


func _on_day_advanced(_d: int) -> void:
	_last_evaluated_day = -1  # force regulars re-roll
	_evaluate_roster()


# === HELPERS ===

func _hour_in_window(hour: int, start_h: int, end_h: int) -> bool:
	if start_h <= end_h:
		return hour >= start_h and hour < end_h
	return hour >= start_h or hour < end_h


func _current_hour() -> int:
	if not has_node("/root/DayNightController"):
		return 12
	var dnc: Node = get_node("/root/DayNightController")
	if dnc.has_method("get_current_hour"):
		return int(dnc.get_current_hour())
	return 12


func _current_day() -> int:
	if not has_node("/root/DayNightController"):
		return 0
	var dnc: Node = get_node("/root/DayNightController")
	if "current_day" in dnc:
		return int(dnc.current_day)
	return 0


func _current_phase() -> StringName:
	if not has_node("/root/DayNightController"):
		return &"day"
	var dnc: Node = get_node("/root/DayNightController")
	if "current_phase" in dnc:
		return StringName(dnc.current_phase)
	return &"day"


func _current_iteration() -> int:
	if not has_node("/root/IterationManager"):
		return 1
	var im: Node = get_node("/root/IterationManager")
	if im.has_method("get_current_iteration"):
		return int(im.get_current_iteration())
	return 1
