class_name FishingMinigame
extends Control

## Stardew-style fishing minigame. A vertical bar contains a fish icon that
## moves erratically. The player holds a "catch zone" indicator that's
## affected by gravity, and must overlap the fish for 5 cumulative seconds
## to win.

signal fish_caught(fish: Dictionary)
signal fish_escaped

@export var catch_zone_height: float = 0.20  ## fraction of bar
@export var fish_size_min: float = 0.04
@export var fish_size_max: float = 0.10
@export var gravity: float = 0.6
@export var lift_force: float = 1.4
@export var win_threshold: float = 5.0  ## cumulative seconds in zone

@onready var _bar: ColorRect = %FishingBar
@onready var _zone: ColorRect = %CatchZone
@onready var _fish_icon: TextureRect = %FishIcon
@onready var _progress_bar: ProgressBar = %ProgressBar

var _bar_height: float = 400.0
var _zone_position: float = 0.5  ## 0=bottom, 1=top
var _zone_velocity: float = 0.0
var _fish_position: float = 0.5
var _fish_target: float = 0.5
var _fish_target_timer: float = 0.0
var _progress: float = 0.0
var _active: bool = false
var _holding: bool = false
var _current_fish: Dictionary = {}


func start(fish: Dictionary, rod_tier: int = 1) -> void:
	_current_fish = fish
	# Larger catch zone with higher rod tier
	catch_zone_height = 0.20 + 0.05 * (rod_tier - 1)
	_zone_position = 0.5
	_zone_velocity = 0.0
	_fish_position = randf()
	_fish_target = _fish_position
	_fish_target_timer = 0.0
	_progress = 0.0
	_active = true
	visible = true
	if _bar != null:
		_bar_height = _bar.size.y


func _process(delta: float) -> void:
	if not _active:
		return

	# Player input — hold to lift the catch zone
	if _holding:
		_zone_velocity += lift_force * delta
	else:
		_zone_velocity -= gravity * delta
	_zone_velocity = clampf(_zone_velocity, -1.5, 1.5)
	_zone_position = clampf(_zone_position + _zone_velocity * delta, 0.0, 1.0 - catch_zone_height)

	# Fish movement based on behavior
	_fish_target_timer -= delta
	if _fish_target_timer <= 0.0:
		_pick_new_fish_target()

	var fish_lerp_speed: float = 2.0
	match StringName(_current_fish.get("behavior", "calm")):
		&"calm":
			fish_lerp_speed = 1.0
		&"erratic":
			fish_lerp_speed = 4.0
		&"sinker":
			_fish_target = clampf(_fish_target - 0.3 * delta, 0.05, 0.95)
			fish_lerp_speed = 1.5
		&"dasher":
			fish_lerp_speed = 6.0

	_fish_position = lerp(_fish_position, _fish_target, fish_lerp_speed * delta)
	_fish_position = clampf(_fish_position, 0.0, 1.0)

	# Check overlap
	var fish_in_zone: bool = (_fish_position >= _zone_position) and (_fish_position <= _zone_position + catch_zone_height)
	if fish_in_zone:
		_progress += delta
	else:
		_progress = maxf(0.0, _progress - delta * 0.5)

	# Update visuals
	if _zone != null:
		_zone.position.y = (1.0 - _zone_position - catch_zone_height) * _bar_height
		_zone.size.y = catch_zone_height * _bar_height
	if _fish_icon != null:
		_fish_icon.position.y = (1.0 - _fish_position) * _bar_height - _fish_icon.size.y * 0.5
	if _progress_bar != null:
		_progress_bar.value = _progress / win_threshold * 100.0

	# Win / lose
	if _progress >= win_threshold:
		_succeed()
	elif _progress < -2.0:
		_fail()


func _pick_new_fish_target() -> void:
	var size_range: float = fish_size_max - fish_size_min
	var jump: float = randf_range(0.1, 0.4)
	if randf() < 0.5:
		jump = -jump
	_fish_target = clampf(_fish_position + jump, 0.05, 0.95)
	_fish_target_timer = randf_range(0.4, 1.5)


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mb: InputEventMouseButton = event
		if mb.button_index == MOUSE_BUTTON_LEFT:
			_holding = mb.pressed


func _succeed() -> void:
	_active = false
	visible = false
	fish_caught.emit(_current_fish)


func _fail() -> void:
	_active = false
	visible = false
	fish_escaped.emit()
