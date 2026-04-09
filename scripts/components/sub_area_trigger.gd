class_name SubAreaTrigger
extends Area3D

## In-world entry trigger for a sub-area. Place at the threshold of a
## hidden pocket (waterfall walk-through, vine ladder top, garden gate,
## ruin archway, etc.). On player overlap, calls
## `SubAreaManager.discover_subarea()` and plays a discovery cinematic
## the first time it fires.
##
## Required scene shape:
##   SubAreaTrigger (Area3D + this script)
##     CollisionShape3D (BoxShape3D sized to the threshold)
##
## Configure via the inspector:
##   sub_area_id     — must match a SubAreaDatabase entry id
##   one_shot        — disable trigger after first discovery (default true)
##   require_facing  — only fire when player faces the trigger forward axis

signal player_entered(sub_area_id: StringName)
signal discovered_via_trigger(sub_area_id: StringName)

@export var sub_area_id: StringName = &""
@export var one_shot: bool = true
@export var require_facing: bool = false
@export var play_discovery_cinematic: bool = true

var _has_fired: bool = false


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	# Sub-area triggers are large by default; only collide with the player
	collision_layer = 0
	collision_mask = 1 << 0  # Player layer (adjust to project's actual mask)
	monitorable = false


func _on_body_entered(body: Node3D) -> void:
	if _has_fired and one_shot:
		return
	if not body.is_in_group(&"player"):
		return
	if sub_area_id == &"":
		push_warning("SubAreaTrigger: empty sub_area_id at %s" % get_path())
		return
	if require_facing and not _player_facing_trigger(body):
		return

	player_entered.emit(sub_area_id)

	if not has_node("/root/SubAreaManager"):
		push_warning("SubAreaTrigger: SubAreaManager autoload missing")
		return

	var sam: Node = get_node("/root/SubAreaManager")
	var was_new: bool = not sam.is_discovered(sub_area_id)
	var ok: bool = sam.discover_subarea(sub_area_id)

	if ok and was_new:
		_has_fired = true
		discovered_via_trigger.emit(sub_area_id)
		if play_discovery_cinematic:
			_play_discovery_cinematic()


func _player_facing_trigger(player: Node3D) -> bool:
	var to_trigger: Vector3 = (global_position - player.global_position).normalized()
	var fwd: Vector3 = -player.global_transform.basis.z.normalized()
	return fwd.dot(to_trigger) > 0.3


func _play_discovery_cinematic() -> void:
	if not has_node("/root/CutsceneController"):
		return
	var cc: Node = get_node("/root/CutsceneController")
	if not cc.has_method("play_timeline"):
		return
	var entry: Dictionary = SubAreaDatabase.get_sub_area(sub_area_id)
	if entry.is_empty():
		return
	var display_name: String = entry.get("display_name", "Unknown Place")
	var timeline: Array = [
		{"event": &"set_letterbox", "enabled": true},
		{"event": &"camera_move", "target": global_position, "duration": 1.5},
		{"event": &"play_sfx", "id": &"sfx_discovery_chime"},
		{"event": &"play_dialogue", "speaker": &"narrator", "text": display_name, "duration": 2.5},
		{"event": &"wait", "duration": 0.5},
		{"event": &"set_letterbox", "enabled": false},
	]
	cc.play_timeline(timeline)
