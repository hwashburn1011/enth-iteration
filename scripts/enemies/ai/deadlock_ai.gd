class_name DeadlockAI
extends Node

## Deadlock AI state machine (Epic 08 task 31).
## Implements the "turret / chain anchor" combat role: cannot move,
## fires CHAIN attacks that lock onto the player and pull them toward
## the Deadlock. Once locked, deals 5 dmg/sec while dragging. Chain
## breaks when player runs perpendicular for 1.5s OR melees the Deadlock.
##
## States:
##   IDLE     — no aggro
##   SCAN     — sweeping for player in aggro range
##   AIM      — locks chain target before fire (1.0s windup)
##   FIRE     — chain projectile travels to target
##   LOCKED   — chain attached, dragging tick + perpendicular escape detection
##   COOLDOWN — 2.5s pause before next chain
##   DEAD
##
## Required scene shape:
##   Deadlock (Node3D root, immobile)
##     DeadlockAI (Node + this script)
##     HealthComponent
##     ChainTether (Node3D + LineRenderer3D for the visible chain)

enum State {
	IDLE,
	SCAN,
	AIM,
	FIRE,
	LOCKED,
	COOLDOWN,
	DEAD,
}

signal state_changed(new_state: State)
signal chain_locked(target: Node3D)
signal chain_broken

@export var target_path: NodePath
@export var aggro_range_m: float = 16.0
@export var chain_max_range_m: float = 12.0
@export var aim_duration_s: float = 1.0
@export var fire_travel_time_s: float = 0.4
@export var drag_speed_m_s: float = 2.0
@export var drag_dps: float = 5.0
@export var drag_tick_interval_s: float = 0.5
@export var perpendicular_break_threshold_s: float = 1.5
@export var melee_break_range_m: float = 2.0
@export var cooldown_s: float = 2.5

var _target: Node3D
var _root: Node3D
var _state: State = State.IDLE
var _state_timer: float = 0.0
var _drag_tick_timer: float = 0.0
var _perpendicular_accumulator: float = 0.0
var _last_target_pos: Vector3 = Vector3.ZERO
var _aim_locked_pos: Vector3 = Vector3.ZERO


func _ready() -> void:
	_target = get_node_or_null(target_path) as Node3D
	_root = get_parent() as Node3D
	if _root == null:
		push_warning("DeadlockAI: parent must be Node3D")
		return
	for child: Node in _root.get_children():
		if child.has_signal("died"):
			child.died.connect(_on_died)


func _physics_process(delta: float) -> void:
	if _root == null or _state == State.DEAD:
		return
	_state_timer += delta
	if _drag_tick_timer > 0.0:
		_drag_tick_timer -= delta
	match _state:
		State.IDLE:     _process_idle()
		State.SCAN:     _process_scan()
		State.AIM:      _process_aim()
		State.FIRE:     _process_fire()
		State.LOCKED:   _process_locked(delta)
		State.COOLDOWN: _process_cooldown()


func _change_state(new_state: State) -> void:
	if new_state == _state:
		return
	_state = new_state
	_state_timer = 0.0
	state_changed.emit(new_state)


func _distance_to_target() -> float:
	if _target == null:
		return INF
	return _root.global_position.distance_to(_target.global_position)


func _process_idle() -> void:
	if _target != null and _distance_to_target() < aggro_range_m:
		_change_state(State.SCAN)


func _process_scan() -> void:
	if _state_timer >= 0.4:
		_change_state(State.AIM)


func _process_aim() -> void:
	if _state_timer >= aim_duration_s:
		if _target != null:
			_aim_locked_pos = _target.global_position
		_change_state(State.FIRE)


func _process_fire() -> void:
	if _state_timer >= fire_travel_time_s:
		# Check if the player is still within chain range from where we aimed
		if _target != null and _root.global_position.distance_to(_target.global_position) <= chain_max_range_m:
			_change_state(State.LOCKED)
			chain_locked.emit(_target)
			_perpendicular_accumulator = 0.0
			_last_target_pos = _target.global_position
		else:
			_change_state(State.COOLDOWN)


func _process_locked(delta: float) -> void:
	if _target == null:
		_break_chain()
		return
	# Drag the player toward the Deadlock by reducing their position
	# delta-velocity along the chain direction. We don't directly move
	# the player here — instead the player controller listens for the
	# chain_locked signal and applies the drag itself. We just track
	# the escape conditions.
	# Drag damage tick
	if _drag_tick_timer <= 0.0:
		if _target.has_method("apply_damage"):
			_target.call("apply_damage", drag_dps * drag_tick_interval_s)
		_drag_tick_timer = drag_tick_interval_s
	# Melee break: player closes to within melee_break_range
	if _root.global_position.distance_to(_target.global_position) <= melee_break_range_m:
		_break_chain()
		return
	# Perpendicular break: track player movement direction relative to chain dir
	var chain_dir: Vector3 = (_target.global_position - _root.global_position).normalized()
	chain_dir.y = 0
	var player_velocity: Vector3 = _target.global_position - _last_target_pos
	player_velocity.y = 0
	if player_velocity.length() > 0.01:
		var move_dir: Vector3 = player_velocity.normalized()
		var perpendicular_amount: float = 1.0 - absf(move_dir.dot(chain_dir))
		if perpendicular_amount > 0.7:
			_perpendicular_accumulator += delta
		else:
			_perpendicular_accumulator = max(0.0, _perpendicular_accumulator - delta * 0.5)
	_last_target_pos = _target.global_position
	if _perpendicular_accumulator >= perpendicular_break_threshold_s:
		_break_chain()


func _break_chain() -> void:
	chain_broken.emit()
	_change_state(State.COOLDOWN)


func _process_cooldown() -> void:
	if _state_timer >= cooldown_s:
		if _target != null and _distance_to_target() < aggro_range_m:
			_change_state(State.AIM)
		else:
			_change_state(State.IDLE)


func _on_died() -> void:
	_change_state(State.DEAD)
	if _state == State.LOCKED:
		_break_chain()
