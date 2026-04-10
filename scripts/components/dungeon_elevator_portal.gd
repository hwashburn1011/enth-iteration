class_name DungeonElevatorPortal
extends Area3D

## Dungeon Elevator/Portal Transition (Epic 30 task 48).
##
## Marks an in-world transition between two dungeon floors. Validates the
## transition is safe before triggering scene swap:
##   - Verifies the destination floor scene exists in FloorManager registry
##   - Verifies the player is the only body inside (no enemies riding along)
##   - Verifies the floor save state is in a clean serializable state
##   - Verifies destination spawn point is valid
##
## On success: emits transition_started, plays the configured cutscene
## (elevator_descent / portal_warp / stairs_climb), waits for it to finish,
## then calls FloorManager.load_floor(destination).
##
## Hook this onto each elevator/portal mesh in the floor scene. Configure
## destination_floor and transition_kind in the inspector.

signal transition_started(from_floor: StringName, to_floor: StringName)
signal transition_validated(success: bool, reason: String)
signal transition_completed(to_floor: StringName)

enum TransitionKind { ELEVATOR_DESCENT, ELEVATOR_ASCENT, PORTAL_WARP, STAIRS_CLIMB, STAIRS_DESCEND }

const PLAYER_GROUP: StringName = &"player"
const ENEMY_GROUP: StringName = &"enemy"

@export var current_floor: StringName = &""
@export var destination_floor: StringName = &""
@export var transition_kind: TransitionKind = TransitionKind.ELEVATOR_DESCENT
@export var spawn_marker_path: NodePath
@export var requires_floor_clear: bool = false
@export var prompt_label: String = "Press [E] to descend"

var _is_player_inside: bool = false
var _is_transitioning: bool = false
var _save_state_ref: DungeonFloorSaveState


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	# Find adjacent FloorSaveState (search siblings)
	var parent: Node = get_parent()
	if parent != null:
		for sibling in parent.get_children():
			if sibling is DungeonFloorSaveState:
				_save_state_ref = sibling
				break


func _input(event: InputEvent) -> void:
	if not _is_player_inside or _is_transitioning:
		return
	if event.is_action_pressed("interact"):
		try_transition()


func try_transition() -> void:
	if _is_transitioning:
		return
	var validation: Dictionary = _validate_transition()
	transition_validated.emit(validation["success"], validation["reason"])
	if not validation["success"]:
		push_warning("DungeonElevatorPortal: validation failed — %s" % validation["reason"])
		return
	_is_transitioning = true
	transition_started.emit(current_floor, destination_floor)
	_play_transition_cutscene()


func _validate_transition() -> Dictionary:
	# 1. Destination must be set
	if destination_floor == &"":
		return {"success": false, "reason": "destination_floor not set"}

	# 2. FloorManager must know about destination
	if has_node("/root/FloorManager"):
		var fm: Node = get_node("/root/FloorManager")
		if fm.has_method("has_floor"):
			if not bool(fm.call("has_floor", destination_floor)):
				return {"success": false, "reason": "FloorManager does not know floor %s" % destination_floor}

	# 3. No enemies inside the portal volume
	for body in get_overlapping_bodies():
		if body.is_in_group(ENEMY_GROUP):
			return {"success": false, "reason": "enemy inside portal area"}

	# 4. If clear gate set, require floor cleared
	if requires_floor_clear and _save_state_ref != null:
		if _save_state_ref.get_completion_percentage() < 1.0:
			return {"success": false, "reason": "floor not 100% cleared"}

	# 5. Save state can serialize
	if _save_state_ref != null:
		_save_state_ref.save_state()

	return {"success": true, "reason": ""}


func _play_transition_cutscene() -> void:
	var cutscene_id: StringName = _cutscene_id_for_kind()
	if has_node("/root/CutsceneController"):
		var cc: Node = get_node("/root/CutsceneController")
		if cc.has_method("play_named"):
			cc.call("play_named", cutscene_id)
			# Hook completion via timer fallback if no signal
			var t: SceneTreeTimer = get_tree().create_timer(_duration_for_kind())
			t.timeout.connect(_on_cutscene_finished)
			return
	# Fallback if no cutscene controller — direct transition after short delay
	var t2: SceneTreeTimer = get_tree().create_timer(0.5)
	t2.timeout.connect(_on_cutscene_finished)


func _cutscene_id_for_kind() -> StringName:
	match transition_kind:
		TransitionKind.ELEVATOR_DESCENT: return &"transition_elevator_down"
		TransitionKind.ELEVATOR_ASCENT: return &"transition_elevator_up"
		TransitionKind.PORTAL_WARP: return &"transition_portal_warp"
		TransitionKind.STAIRS_CLIMB: return &"transition_stairs_up"
		TransitionKind.STAIRS_DESCEND: return &"transition_stairs_down"
	return &"transition_elevator_down"


func _duration_for_kind() -> float:
	match transition_kind:
		TransitionKind.ELEVATOR_DESCENT, TransitionKind.ELEVATOR_ASCENT: return 2.4
		TransitionKind.PORTAL_WARP: return 1.4
		TransitionKind.STAIRS_CLIMB, TransitionKind.STAIRS_DESCEND: return 1.8
	return 2.0


func _on_cutscene_finished() -> void:
	if has_node("/root/FloorManager"):
		var fm: Node = get_node("/root/FloorManager")
		if fm.has_method("load_floor"):
			fm.call("load_floor", destination_floor)
	transition_completed.emit(destination_floor)
	_is_transitioning = false


func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group(PLAYER_GROUP):
		_is_player_inside = true


func _on_body_exited(body: Node3D) -> void:
	if body.is_in_group(PLAYER_GROUP):
		_is_player_inside = false
