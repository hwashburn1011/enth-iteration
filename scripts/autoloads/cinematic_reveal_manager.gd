extends Node
## CinematicRevealManager — fires one-shot landmark camera reveals via
## CutsceneController. Each reveal plays exactly once per save file.
## State persists across iterations so the player only ever sees each
## landmark's reveal flourish once.
##
## Add to project autoloads as "CinematicRevealManager".

signal reveal_played(reveal_id: StringName)

var played_reveals: Array[StringName] = []
var _playing: bool = false


func _ready() -> void:
	pass


# === FIRE ===

func try_play(reveal_id: StringName) -> bool:
	if _playing or played_reveals.has(reveal_id):
		return false
	var entry: Dictionary = CinematicRevealDatabase.get_reveal(reveal_id)
	if entry.is_empty():
		push_warning("CinematicRevealManager: unknown reveal '%s'" % reveal_id)
		return false

	played_reveals.append(reveal_id)
	_playing = true
	reveal_played.emit(reveal_id)

	# Build the timeline from the keyframe array
	var timeline: Array = []
	if entry.get("letterbox", true):
		timeline.append({"event": &"set_letterbox", "enabled": true})
	for kf in entry.get("keyframes", []):
		timeline.append({
			"event": &"camera_move",
			"target": kf.get("position", Vector3.ZERO),
			"look_at": kf.get("look_at", Vector3.ZERO),
			"duration": kf.get("duration", 2.0),
			"fov": kf.get("fov", 70.0),
		})
	var sfx: StringName = entry.get("sfx_id", &"")
	if sfx != &"":
		timeline.append({"event": &"play_sfx", "id": sfx})
	if entry.get("letterbox", true):
		timeline.append({"event": &"set_letterbox", "enabled": false})

	if has_node("/root/CutsceneController"):
		var cc: Node = get_node("/root/CutsceneController")
		if cc.has_method("play_timeline"):
			cc.play_timeline(timeline)

	# Music sting
	var sting: StringName = entry.get("music_sting", &"")
	if sting != &"" and has_node("/root/MusicManager"):
		var mm: Node = get_node("/root/MusicManager")
		if mm.has_method("play_sting"):
			mm.play_sting(sting)

	# Total duration to flip the playing flag back
	var total_duration: float = 0.5
	for kf in entry.get("keyframes", []):
		total_duration += float(kf.get("duration", 2.0))
	var t: SceneTreeTimer = get_tree().create_timer(total_duration + 0.5)
	t.timeout.connect(func() -> void: _playing = false)
	return true


# === QUERIES ===

func is_played(reveal_id: StringName) -> bool:
	return played_reveals.has(reveal_id)


func is_currently_playing() -> bool:
	return _playing


func get_played_count() -> int:
	return played_reveals.size()


func get_total_count() -> int:
	return CinematicRevealDatabase.get_count()


# === SAVE / LOAD ===

func to_save_data() -> Dictionary:
	var p: Array = []
	for r in played_reveals:
		p.append(String(r))
	return {"played_reveals": p}


func from_save_data(data: Dictionary) -> void:
	played_reveals.clear()
	for s in data.get("played_reveals", []):
		played_reveals.append(StringName(s))
