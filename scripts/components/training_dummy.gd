class_name TrainingDummy
extends CharacterBody3D

## In-world training dummy. Reads its config from TrainingDummyDatabase
## by `dummy_id`, takes damage, tracks DPS over a sliding 20-second
## window, drives the configured movement pattern, never dies, and
## resets when the training arena reset lever is pulled.
##
## Required scene shape:
##   TrainingDummy (CharacterBody3D + this script)
##     CollisionShape3D (cylinder, sized to hit_radius)
##     Visual (any Node3D — the dummy mesh)
##     [optional] PatrolPath (Path3D — for patrol movement pattern)
##     [optional] HitFlash (AnimationPlayer — flashes on take_damage)

signal damaged(amount: float, source: Node)
signal dps_window_closed(total_damage: float, dps: float)
signal staggered
signal stagger_window_ended
signal reset_complete

const DPS_WINDOW_S: float = 20.0

@export var dummy_id: StringName = &""

var _config: Dictionary = {}
var _current_health: int = 0
var _dps_log: Array[Dictionary] = []  # [{time, amount}]
var _dps_window_open: bool = false
var _dps_window_start: float = 0.0
var _stagger_buildup: int = 0
var _stagger_active: bool = false
var _stagger_end_time: float = 0.0
var _patrol_progress: float = 0.0
var _hover_origin: Vector3
var _patrol_path: Path3D
var _cluster_orbit_angle: float = 0.0


func _ready() -> void:
	if dummy_id == &"":
		return
	_config = TrainingDummyDatabase.get_dummy(dummy_id)
	if _config.is_empty():
		push_warning("TrainingDummy: unknown dummy_id '%s'" % dummy_id)
		return
	_current_health = int(_config.get("max_health", 9999))
	_hover_origin = global_position
	_patrol_path = get_node_or_null(^"PatrolPath") as Path3D


func _physics_process(delta: float) -> void:
	_update_movement(delta)
	_update_stagger()
	_update_dps_window()


# === DAMAGE ===

func take_damage(amount: float, source: Node = null, damage_type: StringName = &"physical") -> float:
	if _config.is_empty():
		return 0.0

	# Apply armor + resistance
	var armor: int = int(_config.get("armor", 0))
	var resists: Dictionary = _config.get("resistance_profile", {})
	var resist_mult: float = float(resists.get(damage_type, 1.0))
	var post_armor: float = max(1.0, amount - float(armor)) * resist_mult

	# Stagger meter accumulates if doubled stagger window not active
	if _config.get("has_stagger_meter", false) and not _stagger_active:
		_stagger_buildup += int(post_armor)
		if _stagger_buildup >= int(_config.get("stagger_threshold", 5000)):
			_trigger_stagger()

	# Stagger window doubles damage
	var final_damage: float = post_armor * (2.0 if _stagger_active else 1.0)

	# DPS log
	_dps_log.append({"time": Time.get_ticks_msec() / 1000.0, "amount": final_damage})
	_open_dps_window_if_needed()

	# Health is purely cosmetic — dummies never die
	_current_health = max(1, _current_health - int(final_damage))

	# Hit flash
	var flash: AnimationPlayer = get_node_or_null(^"HitFlash") as AnimationPlayer
	if flash != null and flash.has_animation(&"flash"):
		flash.play(&"flash")

	damaged.emit(final_damage, source)
	return final_damage


# === STAGGER ===

func _trigger_stagger() -> void:
	_stagger_active = true
	_stagger_end_time = (Time.get_ticks_msec() / 1000.0) + float(_config.get("stagger_window_s", 5.0))
	_stagger_buildup = 0
	staggered.emit()
	if has_node("/root/SFXManager"):
		var sm: Node = get_node("/root/SFXManager")
		if sm.has_method("play"):
			sm.play(&"sfx_stagger_open")


func _update_stagger() -> void:
	if not _stagger_active:
		return
	if (Time.get_ticks_msec() / 1000.0) >= _stagger_end_time:
		_stagger_active = false
		stagger_window_ended.emit()


# === DPS WINDOW ===

func _open_dps_window_if_needed() -> void:
	if _dps_window_open:
		return
	_dps_window_open = true
	_dps_window_start = Time.get_ticks_msec() / 1000.0


func _update_dps_window() -> void:
	if not _dps_window_open:
		return
	var now: float = Time.get_ticks_msec() / 1000.0
	if now - _dps_window_start < DPS_WINDOW_S:
		return
	# Window closed — compute total + DPS, emit, then reset for next window
	var total: float = 0.0
	for entry in _dps_log:
		if entry["time"] >= _dps_window_start:
			total += float(entry["amount"])
	var dps: float = total / DPS_WINDOW_S
	dps_window_closed.emit(total, dps)
	_dps_log.clear()
	_dps_window_open = false


# === MOVEMENT ===

func _update_movement(delta: float) -> void:
	var pattern: StringName = _config.get("movement_pattern", &"stationary")
	match pattern:
		&"stationary":
			pass
		&"patrol":
			_advance_patrol(delta)
		&"hover":
			_advance_hover(delta)
		&"cluster_orbit":
			_advance_cluster_orbit(delta)


func _advance_patrol(delta: float) -> void:
	if _patrol_path == null or _patrol_path.curve == null:
		return
	var speed: float = float(_config.get("movement_speed", 1.0))
	_patrol_progress += speed * delta
	var length: float = _patrol_path.curve.get_baked_length()
	if length <= 0.0:
		return
	_patrol_progress = fmod(_patrol_progress, length)
	var pos: Vector3 = _patrol_path.curve.sample_baked(_patrol_progress)
	global_position = _patrol_path.global_position + pos


func _advance_hover(delta: float) -> void:
	var speed: float = float(_config.get("movement_speed", 1.0))
	var t: float = Time.get_ticks_msec() / 1000.0
	# Small lissajous in XZ plane around the hover origin
	global_position = _hover_origin + Vector3(
		sin(t * speed) * 1.2,
		sin(t * speed * 1.4) * 0.4,
		cos(t * speed) * 1.2
	)


func _advance_cluster_orbit(delta: float) -> void:
	var speed: float = float(_config.get("movement_speed", 0.5))
	_cluster_orbit_angle += speed * delta
	var radius: float = float(_config.get("cluster_radius", 1.5))
	global_position = _hover_origin + Vector3(
		cos(_cluster_orbit_angle) * radius,
		0,
		sin(_cluster_orbit_angle) * radius
	)


# === RESET (called by training arena reset lever) ===

func reset() -> void:
	_current_health = int(_config.get("max_health", 9999))
	_dps_log.clear()
	_dps_window_open = false
	_stagger_buildup = 0
	_stagger_active = false
	_patrol_progress = 0.0
	_cluster_orbit_angle = 0.0
	if _config.get("movement_pattern", &"stationary") in [&"hover", &"cluster_orbit"]:
		global_position = _hover_origin
	reset_complete.emit()


# === QUERY ===

func get_health_percent() -> float:
	var max_h: int = int(_config.get("max_health", 9999))
	return float(_current_health) / float(max_h) if max_h > 0 else 0.0


func is_in_stagger_window() -> bool:
	return _stagger_active
