class_name TownNPC
extends Node3D

## Town NPC component bundle (Epic 10 tasks 43, 44, 47, 48).
## Mounts onto a town NPC scene to drive:
##
##   1) Player presence reaction (task 47) — when player enters
##      reaction_range, plays react_happy and faces player
##   2) Dialogue system hookup (task 44) — emits dialogue_requested
##      signal when player enters interact_range and presses interact
##   3) Quest hook system (task 48) — has_active_quest flag + quest_id
##      that the QuestManager can read to know which dialogue branch
##      to serve
##   4) Default placement (task 43) — spawns at default_position on
##      ready if no schedule overrides it
##
## Required scene shape:
##   TownNPC (Node3D + this script)
##     <NPCName>_LOD0 (MeshInstance3D)
##     Armature_<NPCName> (Skeleton3D)
##     AnimationPlayer

signal interact_prompt_shown
signal interact_prompt_hidden
signal dialogue_requested(npc_id: StringName)
signal player_entered_reaction_range
signal player_left_reaction_range

@export var npc_id: StringName
@export var display_name: String = ""
@export var target_path: NodePath
@export var animation_player_path: NodePath
@export var skeleton_path: NodePath
@export var reaction_range_m: float = 5.0
@export var interact_range_m: float = 2.5
@export var has_active_quest: bool = false
@export var quest_id: StringName = &""
@export var default_position: Vector3 = Vector3.ZERO

var _target: Node3D
var _animation_player: AnimationPlayer
var _skeleton: Skeleton3D
var _is_in_reaction_range: bool = false
var _is_prompt_shown: bool = false
var _has_reacted_to_player: bool = false


func _ready() -> void:
	_target = get_node_or_null(target_path) as Node3D
	_animation_player = get_node_or_null(animation_player_path) as AnimationPlayer
	_skeleton = get_node_or_null(skeleton_path) as Skeleton3D
	if default_position != Vector3.ZERO:
		var parent: Node3D = get_parent() as Node3D
		if parent != null:
			parent.global_position = default_position
	_play_idle()


func _process(_delta: float) -> void:
	if _target == null:
		return
	var parent: Node3D = get_parent() as Node3D
	if parent == null:
		return
	var dist: float = parent.global_position.distance_to(_target.global_position)

	# === Reaction range ===
	var in_reaction: bool = dist <= reaction_range_m
	if in_reaction != _is_in_reaction_range:
		_is_in_reaction_range = in_reaction
		if in_reaction:
			player_entered_reaction_range.emit()
			if not _has_reacted_to_player:
				_play_react_happy()
				_has_reacted_to_player = true
				_face_target()
		else:
			player_left_reaction_range.emit()
			_has_reacted_to_player = false

	# === Interact range ===
	var in_interact: bool = dist <= interact_range_m
	if in_interact != _is_prompt_shown:
		_is_prompt_shown = in_interact
		if in_interact:
			interact_prompt_shown.emit()
		else:
			interact_prompt_hidden.emit()


func _face_target() -> void:
	if _target == null:
		return
	var parent: Node3D = get_parent() as Node3D
	if parent == null:
		return
	var dir: Vector3 = _target.global_position - parent.global_position
	dir.y = 0
	if dir.length_squared() < 0.01:
		return
	parent.look_at(parent.global_position + dir, Vector3.UP)


func request_dialogue() -> void:
	## Called by player input when in interact range
	if not _is_prompt_shown:
		return
	dialogue_requested.emit(npc_id)


func _play_idle() -> void:
	_play_animation(String(npc_id) + "_idle")


func _play_react_happy() -> void:
	_play_animation(String(npc_id) + "_react_happy")


func _play_animation(name: String) -> void:
	if _animation_player == null:
		return
	if _animation_player.has_animation(name):
		_animation_player.play(name)


func get_quest_id() -> StringName:
	return quest_id if has_active_quest else &""
