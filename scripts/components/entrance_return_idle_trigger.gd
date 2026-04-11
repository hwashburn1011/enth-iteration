class_name EntranceReturnIdleTrigger
extends Area3D

## Plays a brief no-letterbox return-idle camera flourish from
## EntranceReturnCinematicDatabase whenever the player approaches a
## dungeon entrance they've already discovered. Throttled by per-entry
## `cooldown_hours` so it doesn't fire on every back-and-forth.
##
## Skips the first time entirely — `CinematicRevealManager` /
## first-time cinematics handle the initial visit. This component
## kicks in once the entrance is in the player's discovered set.
##
## Required scene shape:
##   EntranceReturnIdleTrigger (Area3D + this script)
##     CollisionShape3D (SphereShape3D, approach radius)
##
## Configure via inspector:
##   entrance_id — must match an EntranceReturnCinematicDatabase key

signal idle_played(entrance_id: StringName)

@export var entrance_id: StringName = &""

var _last_played_hour_total: int = -100000


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	collision_layer = 0
	collision_mask = 1 << 0
	monitorable = false


# === FIRE ===

func _on_body_entered(body: Node3D) -> void:
	if not body.is_in_group(&"player"):
		return
	if entrance_id == &"":
		return
	if not _entrance_already_visited():
		return  # first-time cinematic handles this case
	if _hours_until_ready() > 0:
		return
	_play_idle()


func _play_idle() -> void:
	var entry: Dictionary = EntranceReturnCinematicDatabase.get_idle(entrance_id)
	if entry.is_empty():
		return
	if not has_node("/root/CutsceneController"):
		return
	var cc: Node = get_node("/root/CutsceneController")
	if not cc.has_method("play_timeline"):
		return

	var timeline: Array = []
	# No letterbox — return idles are mood beats, not story beats
	for kf in entry.get("keyframes", []):
		timeline.append({
			"event": &"camera_move",
			"target": kf.get("position", Vector3.ZERO),
			"look_at": kf.get("look_at", Vector3.ZERO),
			"duration": kf.get("duration", 1.5),
			"fov": kf.get("fov", 60.0),
		})
	var sfx: StringName = entry.get("sfx_id", &"")
	if sfx != &"":
		timeline.append({"event": &"play_sfx", "id": sfx})

	cc.play_timeline(timeline)

	# Optional sting (only the final vault has one — to flag seal changes)
	var sting: StringName = entry.get("music_sting", &"")
	if sting != &"" and has_node("/root/MusicManager"):
		var mm: Node = get_node("/root/MusicManager")
		if mm.has_method("play_sting"):
			mm.play_sting(sting)

	_last_played_hour_total = _current_hour_total()
	idle_played.emit(entrance_id)


# === GATING ===

func _entrance_already_visited() -> bool:
	## "Visited" means the player has triggered the first-time cinematic
	## for this entrance — read from CinematicRevealManager so the return
	## idle only kicks in after the reveal has played.
	if not has_node("/root/CinematicRevealManager"):
		return false
	var crm: Node = get_node("/root/CinematicRevealManager")
	# Reuse the four_mouths reveal as the proxy for "you have seen the cliffs"
	# but per-entrance reveal ids would slot in here too.
	if crm.has_method("is_played"):
		return crm.is_played(&"reveal_four_mouths")
	return false


func _hours_until_ready() -> int:
	var entry: Dictionary = EntranceReturnCinematicDatabase.get_idle(entrance_id)
	var cooldown: int = int(entry.get("cooldown_hours", 24))
	if cooldown <= 0:
		return 0
	var elapsed: int = _current_hour_total() - _last_played_hour_total
	if elapsed >= cooldown:
		return 0
	return cooldown - elapsed


# === HELPERS ===

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


# === SAVE / LOAD ===

func to_save_data() -> Dictionary:
	return {
		"entrance_id": String(entrance_id),
		"last_played_hour_total": _last_played_hour_total,
	}


func from_save_data(data: Dictionary) -> void:
	_last_played_hour_total = int(data.get("last_played_hour_total", -100000))
