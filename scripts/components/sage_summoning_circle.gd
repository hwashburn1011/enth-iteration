class_name SageSummoningCircle
extends Node3D

## Sage summoning circle floor decal (Epic 09 task 35).
## Spawns a 3m radius cyan magic circle decal beneath the AI Sage that
## fades in when the Sage appears + slow-rotates while he's present +
## fades out when he leaves. Decorative, no gameplay impact.
##
## Required scene shape:
##   SageSummoningCircle (Node3D + this script)
##
## Hookup from a town scene factory:
##   var circle: SageSummoningCircle = preload("res://scenes/effects/sage_summoning_circle.tscn").instantiate()
##   circle.global_position = sage_anchor.global_position
##   add_child(circle)
##   circle.appear()

@export var radius_m: float = 3.0
@export var fade_in_duration_s: float = 1.5
@export var fade_out_duration_s: float = 1.5
@export var rotation_speed_deg_s: float = 8.0
@export var circle_color: Color = Color(0.0, 0.85, 1.0, 0.0)
@export var decal_texture_path: String = "res://assets/textures/vfx/sage_summoning_circle.png"

var _decal: Decal
var _is_visible: bool = false
var _t: float = 0.0


func _ready() -> void:
	_build_decal()


func _build_decal() -> void:
	_decal = Decal.new()
	_decal.name = "SummoningCircleDecal"
	_decal.size = Vector3(radius_m * 2.0, 1.5, radius_m * 2.0)
	_decal.modulate = circle_color
	_decal.albedo_mix = 1.0
	_decal.upper_fade = 0.4
	_decal.lower_fade = 0.4
	if ResourceLoader.exists(decal_texture_path):
		_decal.texture_albedo = load(decal_texture_path)
	add_child(_decal)


func appear() -> void:
	if _is_visible:
		return
	_is_visible = true
	var tw: Tween = create_tween()
	tw.tween_property(_decal, "modulate:a", 0.85, fade_in_duration_s)


func disappear() -> void:
	if not _is_visible:
		return
	_is_visible = false
	var tw: Tween = create_tween()
	tw.tween_property(_decal, "modulate:a", 0.0, fade_out_duration_s)


func _process(delta: float) -> void:
	if _is_visible:
		_t += delta
		_decal.rotation.y = deg_to_rad(_t * rotation_speed_deg_s)
