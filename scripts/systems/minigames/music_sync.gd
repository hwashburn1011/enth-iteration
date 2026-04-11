class_name MusicSyncMinigame
extends Control

## Music Sync minigame: notes scroll down 4 lanes. Player presses the
## corresponding key when the note crosses the hit line. Score by accuracy.

signal completed(success: bool, score: int)

const LANES: int = 4
const HIT_WINDOW: float = 0.15  ## seconds
const PERFECT_WINDOW: float = 0.05
const PASS_THRESHOLD: float = 0.7  ## fraction of notes hit to pass

const KEY_FOR_LANE: Array[int] = [KEY_D, KEY_F, KEY_J, KEY_K]

@export var difficulty_params: Dictionary = {"note_speed": 1.5}
@export var note_chart: Array[Dictionary] = []  ## { lane: int, time: float }

@onready var _hit_line: ColorRect = %HitLine
@onready var _lanes_container: Control = %LanesContainer
@onready var _score_label: Label = %ScoreLabel

var _notes_scheduled: Array = []
var _active_notes: Array = []  ## { node, lane, hit_time, missed }
var _song_time: float = 0.0
var _hits: int = 0
var _misses: int = 0
var _perfect: int = 0
var _accept_input: bool = false
var _scroll_speed_pix: float = 400.0  ## px per sec at speed 1.0


func start() -> void:
	# Generate a procedural chart if none provided
	if note_chart.is_empty():
		_generate_random_chart(60)
	_notes_scheduled = note_chart.duplicate()
	_active_notes.clear()
	_song_time = 0.0
	_hits = 0
	_misses = 0
	_perfect = 0
	_accept_input = true
	visible = true


func _generate_random_chart(note_count: int) -> void:
	note_chart.clear()
	var t: float = 1.0
	for i in note_count:
		note_chart.append({"lane": randi() % LANES, "time": t})
		t += randf_range(0.3, 0.7)


func _process(delta: float) -> void:
	if not _accept_input:
		return
	var speed_mult: float = difficulty_params.get("note_speed", 1.5)
	_song_time += delta * speed_mult

	# Spawn notes that should be visible
	while not _notes_scheduled.is_empty() and _song_time + 2.0 >= _notes_scheduled[0]["time"]:
		var note: Dictionary = _notes_scheduled.pop_front()
		_spawn_note(note)

	# Update active notes
	for note in _active_notes:
		if note.get("missed", false):
			continue
		var time_to_hit: float = note["hit_time"] - _song_time
		# Auto-miss if past window
		if time_to_hit < -HIT_WINDOW:
			note["missed"] = true
			_misses += 1
			_update_score()
		# Move visual
		if note.has("node") and note["node"] != null:
			note["node"].position.y = (2.0 - time_to_hit) * _scroll_speed_pix

	# Check if song is over
	if _notes_scheduled.is_empty() and _active_notes_remaining() == 0:
		_finish_song()


func _spawn_note(note_data: Dictionary) -> void:
	var note_visual: ColorRect = ColorRect.new()
	note_visual.size = Vector2(60, 20)
	note_visual.color = Color(0.4, 0.85, 0.95)
	note_visual.position.x = note_data["lane"] * 80 + 10
	note_visual.position.y = -20
	if _lanes_container != null:
		_lanes_container.add_child(note_visual)
	_active_notes.append({
		"node": note_visual,
		"lane": note_data["lane"],
		"hit_time": note_data["time"],
		"missed": false,
		"hit": false,
	})


func _active_notes_remaining() -> int:
	var n: int = 0
	for note in _active_notes:
		if not note.get("hit", false) and not note.get("missed", false):
			n += 1
	return n


func _unhandled_input(event: InputEvent) -> void:
	if not _accept_input:
		return
	if event is InputEventKey and event.pressed:
		var lane: int = -1
		for i in LANES:
			if event.keycode == KEY_FOR_LANE[i]:
				lane = i
				break
		if lane >= 0:
			_attempt_hit(lane)


func _attempt_hit(lane: int) -> void:
	for note in _active_notes:
		if note["lane"] != lane:
			continue
		if note.get("hit", false) or note.get("missed", false):
			continue
		var time_diff: float = abs(_song_time - note["hit_time"])
		if time_diff <= HIT_WINDOW:
			note["hit"] = true
			_hits += 1
			if time_diff <= PERFECT_WINDOW:
				_perfect += 1
			if note["node"] != null:
				note["node"].queue_free()
			_update_score()
			return


func _update_score() -> void:
	if _score_label != null:
		_score_label.text = "Hits: %d | Perfect: %d | Misses: %d" % [_hits, _perfect, _misses]


func _finish_song() -> void:
	_accept_input = false
	visible = false
	var total: int = _hits + _misses
	var hit_rate: float = float(_hits) / float(max(1, total))
	var success: bool = hit_rate >= PASS_THRESHOLD
	var score: int = _hits * 100 + _perfect * 50
	completed.emit(success, score)
