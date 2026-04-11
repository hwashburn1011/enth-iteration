class_name LockpickingMinigame
extends Control

## Lockpicking minigame: a moving cursor sweeps back and forth across a bar.
## Player presses interact when the cursor is inside one or more target zones.
## Multiple zones must all be hit (in any order) to unlock.

signal completed(success: bool, score: int)

const SWEEP_SPEED: float = 1.5  ## bar units per second

@export var difficulty_params: Dictionary = {"zone_width": 0.18, "zones": 2, "moving": false}

@onready var _bar: ColorRect = %LockBar
@onready var _cursor: ColorRect = %LockCursor
@onready var _zones_container: Control = %ZonesContainer

var _zone_positions: PackedFloat32Array = []  ## 0-1 along bar
var _zones_hit: Array[bool] = []
var _cursor_pos: float = 0.0
var _cursor_velocity: float = 1.0
var _accept_input: bool = false
var _bar_width_px: float = 400.0


func start() -> void:
	var zone_count: int = difficulty_params.get("zones", 2)
	var zone_width: float = difficulty_params.get("zone_width", 0.18)
	_setup_zones(zone_count, zone_width)
	_cursor_pos = 0.0
	_cursor_velocity = SWEEP_SPEED
	_accept_input = true
	visible = true
	if _bar != null:
		_bar_width_px = _bar.size.x


func _setup_zones(count: int, width: float) -> void:
	_zone_positions.clear()
	_zones_hit.clear()
	if _zones_container != null:
		for c in _zones_container.get_children():
			c.queue_free()

	# Spread zones across the bar
	for i in count:
		var center: float = randf_range(0.1, 0.9)
		# Avoid clumping
		var attempts: int = 0
		while _zones_too_close(center, width) and attempts < 10:
			center = randf_range(0.1, 0.9)
			attempts += 1
		_zone_positions.append(center)
		_zones_hit.append(false)

		# Visualize the zone
		if _zones_container != null:
			var zone_rect: ColorRect = ColorRect.new()
			zone_rect.color = Color(0.4, 0.95, 0.4, 0.4)
			zone_rect.anchor_left = center - width * 0.5
			zone_rect.anchor_right = center + width * 0.5
			zone_rect.anchor_top = 0.0
			zone_rect.anchor_bottom = 1.0
			_zones_container.add_child(zone_rect)


func _zones_too_close(new_center: float, width: float) -> bool:
	for c in _zone_positions:
		if abs(c - new_center) < width:
			return true
	return false


func _process(delta: float) -> void:
	if not _accept_input:
		return
	# Sweep
	_cursor_pos += _cursor_velocity * delta
	if _cursor_pos >= 1.0:
		_cursor_pos = 1.0
		_cursor_velocity = -SWEEP_SPEED
	elif _cursor_pos <= 0.0:
		_cursor_pos = 0.0
		_cursor_velocity = SWEEP_SPEED
	if _cursor != null:
		_cursor.position.x = _cursor_pos * _bar_width_px - _cursor.size.x * 0.5

	# Move zones if difficulty has moving zones
	if difficulty_params.get("moving", false):
		for i in _zone_positions.size():
			if _zones_hit[i]:
				continue
			_zone_positions[i] += sin(Time.get_ticks_msec() * 0.001 + i) * delta * 0.05
			_zone_positions[i] = clampf(_zone_positions[i], 0.05, 0.95)


func _unhandled_input(event: InputEvent) -> void:
	if not _accept_input:
		return
	if event.is_action_pressed(&"interact"):
		_attempt_pick()


func _attempt_pick() -> void:
	var width: float = difficulty_params.get("zone_width", 0.18)
	for i in _zone_positions.size():
		if _zones_hit[i]:
			continue
		var center: float = _zone_positions[i]
		if abs(_cursor_pos - center) <= width * 0.5:
			_zones_hit[i] = true
			# Check win
			if _all_zones_hit():
				_finish(true)
			return
	# Missed all zones — fail
	_finish(false)


func _all_zones_hit() -> bool:
	for hit in _zones_hit:
		if not hit:
			return false
	return true


func _finish(success: bool) -> void:
	_accept_input = false
	visible = false
	var score: int = 100 if success else 0
	completed.emit(success, score)
