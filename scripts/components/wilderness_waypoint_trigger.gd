class_name WildernessWaypointTrigger
extends Area3D

## Place at each wilderness landmark monument. On player overlap,
## discovers the waypoint via WildernessWaypointManager and (optionally)
## fires a discovery cinematic the first time.
##
## Required scene shape:
##   WildernessWaypointTrigger (Area3D + this script)
##     CollisionShape3D (SphereShape3D sized to discovery_radius)
##
## Configure via the inspector:
##   waypoint_id              — must match a WildernessWaypointDatabase id
##   play_discovery_cinematic — short letterbox + name reveal on first hit
##   one_shot                 — disable trigger after first discovery

signal player_arrived(waypoint_id: StringName)
signal discovered(waypoint_id: StringName)

@export var waypoint_id: StringName = &""
@export var play_discovery_cinematic: bool = true
@export var one_shot: bool = true

var _has_fired: bool = false


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	collision_layer = 0
	collision_mask = 1 << 0  # Player layer
	monitorable = false


func _on_body_entered(body: Node3D) -> void:
	if _has_fired and one_shot:
		return
	if not body.is_in_group(&"player"):
		return
	if waypoint_id == &"":
		push_warning("WildernessWaypointTrigger: empty waypoint_id at %s" % get_path())
		return

	player_arrived.emit(waypoint_id)

	if not has_node("/root/WildernessWaypointManager"):
		return
	var wwm: Node = get_node("/root/WildernessWaypointManager")
	var was_new: bool = not wwm.is_unlocked(waypoint_id)
	var ok: bool = wwm.discover_waypoint(waypoint_id)

	if ok and was_new:
		_has_fired = true
		discovered.emit(waypoint_id)
		if play_discovery_cinematic:
			_play_discovery_cinematic()


func _play_discovery_cinematic() -> void:
	if not has_node("/root/CutsceneController"):
		return
	var cc: Node = get_node("/root/CutsceneController")
	if not cc.has_method("play_timeline"):
		return
	var entry: Dictionary = WildernessWaypointDatabase.get_waypoint(waypoint_id)
	if entry.is_empty():
		return
	var name_text: String = entry.get("display_name", "Waypoint")
	var timeline: Array = [
		{"event": &"set_letterbox", "enabled": true},
		{"event": &"camera_move", "target": global_position, "duration": 1.2},
		{"event": &"play_sfx", "id": &"sfx_waypoint_discovered"},
		{"event": &"play_dialogue", "speaker": &"narrator", "text": name_text, "duration": 2.0},
		{"event": &"wait", "duration": 0.4},
		{"event": &"set_letterbox", "enabled": false},
	]
	cc.play_timeline(timeline)
