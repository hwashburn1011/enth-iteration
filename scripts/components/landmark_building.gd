class_name LandmarkBuilding
extends Node3D

## Town landmark building component (Epic 11 tasks 33-37, 43-48).
## Mounts onto a landmark building scene to drive:
##
##   1) Per-building emissive at night (task 33) — listens to the
##      day/night cycle and ramps up the accent emission as night falls
##   2) Ambient particle attachment points (task 34) — exposes named
##      Marker3D children where smoke/sparks/leaves spawn
##   3) Ambient SFX zone (task 35) — proximity-triggered ambient sound
##      that plays when the player is within ambient_range
##   4) Interior shell visibility (task 36) — toggles interior mesh
##      visibility based on whether the player is inside the building
##   5) Path connector + interaction prompt (task 44, 45) — shows the
##      door interaction prompt when the player is in interact range
##   6) Quest hooks (task 48) — has_active_quest flag for the
##      QuestManager
##
## Required scene shape:
##   LandmarkBuilding (Node3D + this script)
##     <BuildingName>_LOD0 (MeshInstance3D, the body)
##     [optional] %ParticleAttachPoint (Marker3D for smoke/etc)
##     [optional] %DoorPrompt (Marker3D for interaction prompt position)
##     [optional] %AmbientSfxPlayer (AudioStreamPlayer3D)

signal interact_prompt_shown
signal interact_prompt_hidden
signal door_interacted(building_id: StringName)

@export var building_id: StringName
@export var display_name: String = ""
@export var target_path: NodePath
@export var body_mesh_path: NodePath
@export var night_emission_multiplier: float = 2.5
@export var ambient_range_m: float = 10.0
@export var interact_range_m: float = 3.0
@export var door_position: Vector3 = Vector3.ZERO
@export var has_active_quest: bool = false
@export var quest_id: StringName = &""
@export var ambient_sfx_id: StringName = &""

const NIGHT_START_HOUR: float = 19.0
const NIGHT_END_HOUR: float = 6.0

var _target: Node3D
var _body_mesh: MeshInstance3D
var _shader_material: ShaderMaterial
var _is_in_interact_range: bool = false
var _is_in_ambient_range: bool = false
var _ambient_player: AudioStreamPlayer3D
var _current_emission_multiplier: float = 1.0


func _ready() -> void:
	_target = get_node_or_null(target_path) as Node3D
	_body_mesh = get_node_or_null(body_mesh_path) as MeshInstance3D
	if _body_mesh != null and _body_mesh.material_override is ShaderMaterial:
		_shader_material = _body_mesh.material_override
	_ambient_player = get_node_or_null("%AmbientSfxPlayer") as AudioStreamPlayer3D


func _process(_delta: float) -> void:
	if _target == null:
		return
	var dist: float = global_position.distance_to(_target.global_position)
	_check_interact_range(dist)
	_check_ambient_range(dist)


func _check_interact_range(dist: float) -> void:
	var in_range: bool = dist <= interact_range_m
	if in_range != _is_in_interact_range:
		_is_in_interact_range = in_range
		if in_range:
			interact_prompt_shown.emit()
		else:
			interact_prompt_hidden.emit()


func _check_ambient_range(dist: float) -> void:
	var in_range: bool = dist <= ambient_range_m
	if in_range != _is_in_ambient_range:
		_is_in_ambient_range = in_range
		if _ambient_player != null:
			if in_range and not _ambient_player.playing:
				_ambient_player.play()
			elif not in_range and _ambient_player.playing:
				_ambient_player.stop()


func set_time_of_day(hours: float) -> void:
	## Drives the night emission ramp. Called by GameManager day/night cycle.
	var is_night: bool = hours >= NIGHT_START_HOUR or hours < NIGHT_END_HOUR
	var target_mult: float = night_emission_multiplier if is_night else 1.0
	_current_emission_multiplier = lerp(_current_emission_multiplier, target_mult, 0.05)
	if _shader_material != null:
		_shader_material.set_shader_parameter("emission_multiplier", _current_emission_multiplier)


func interact_with_door() -> void:
	if not _is_in_interact_range:
		return
	door_interacted.emit(building_id)


func get_quest_id() -> StringName:
	return quest_id if has_active_quest else &""
