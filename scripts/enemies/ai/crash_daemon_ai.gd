class_name CrashDaemonAI
extends Node

## Crash Daemon AI state machine (Epic 08 task 27).
## Implements the "pressure / charger" combat role from the enemy bible:
## maintains a 6m circling distance around the player, then locks into a
## 0.3-second coiled wind-up pose and dashes 8m in a straight line. If
## it hits, deals 25 damage + brief stagger; if it misses, takes 1.0s
## to reorient (the player's punish window).
##
## States:
##   IDLE       — no aggro, slow patrol
##   APPROACH   — circling around player at preferred range 6m
##   WIND_UP    — 0.3s coil pose before charge (the dodge tell)
##   CHARGE     — 8m straight-line dash at high speed
##   RECOVER    — 1.0s skid recovery, vulnerable
##   STAGGER    — hit-stagger from melee counter-hit
##   DEAD       — death sequence
##
## Required scene shape:
##   CrashDaemon (CharacterBody3D root with movement)
##     CrashDaemonAI (Node + this script)
##     HealthComponent (with damage_taken / died signals)
##     AttackHitbox (Area3D with body_entered signal)
##     AnimationPlayer (with crash_daemon_idle/circle/coil/dash/skid/death anims)
##
## Hookup from spawn:
##   var ai: CrashDaemonAI = CrashDaemonAI.new()
##   ai.target_path = player.get_path()
##   crash_daemon.add_child(ai)

enum State {
	IDLE,
	APPROACH,
	WIND_UP,
	CHARGE,
	RECOVER,
	STAGGER,
	DEAD,
}

signal state_changed(new_state: State)

@export var target_path: NodePath
@export var preferred_range_m: float = 6.0
@export var aggro_range_m: float = 14.0
@export var dash_distance_m: float = 8.0
@export var dash_speed_m_s: float = 18.0
@export var circle_speed_m_s: float = 3.5
@export var wind_up_duration_s: float = 0.3
@export var recover_duration_s: float = 1.0
@export var stagger_duration_s: float = 0.6
@export var dash_damage: float = 25.0
@export var charge_cooldown_s: float = 1.5

var _target: Node3D
var _body: CharacterBody3D
var _state: State = State.IDLE
var _state_timer: float = 0.0
var _charge_cooldown_timer: float = 0.0
var _dash_origin: Vector3
var _dash_direction: Vector3
var _hit_player_this_charge: bool = false
var _circle_direction: int = 1  # +1 or -1


func _ready() -> void:
	_target = get_node_or_null(target_path) as Node3D
	_body = get_parent() as CharacterBody3D
	if _body == null:
		push_warning("CrashDaemonAI: parent must be CharacterBody3D")
		return
	_resolve_signals()
	_circle_direction = 1 if randf() > 0.5 else -1


func _resolve_signals() -> void:
	for child: Node in _body.get_children():
		if child.has_signal("damage_taken"):
			child.damage_taken.connect(_on_damage_taken)
		if child.has_signal("died"):
			child.died.connect(_on_died)
		if child is Area3D and child.name == "AttackHitbox":
			child.body_entered.connect(_on_attack_hitbox_body_entered)


func _physics_process(delta: float) -> void:
	if _body == null or _state == State.DEAD:
		return
	_state_timer += delta
	if _charge_cooldown_timer > 0.0:
		_charge_cooldown_timer -= delta
	match _state:
		State.IDLE:        _process_idle()
		State.APPROACH:    _process_approach(delta)
		State.WIND_UP:     _process_wind_up()
		State.CHARGE:      _process_charge(delta)
		State.RECOVER:     _process_recover()
		State.STAGGER:     _process_stagger()


func _change_state(new_state: State) -> void:
	if new_state == _state:
		return
	_state = new_state
	_state_timer = 0.0
	state_changed.emit(new_state)


func _distance_to_target() -> float:
	if _target == null:
		return INF
	return _body.global_position.distance_to(_target.global_position)


func _direction_to_target() -> Vector3:
	if _target == null:
		return Vector3.FORWARD
	return (_target.global_position - _body.global_position).normalized()


# === IDLE ===
func _process_idle() -> void:
	if _target != null and _distance_to_target() < aggro_range_m:
		_change_state(State.APPROACH)
	_body.velocity = Vector3.ZERO
	_body.move_and_slide()


# === APPROACH (circle around player) ===
func _process_approach(delta: float) -> void:
	if _target == null:
		_change_state(State.IDLE)
		return
	var dist: float = _distance_to_target()
	if dist > aggro_range_m * 1.5:
		_change_state(State.IDLE)
		return
	# Circle: tangent direction + small radial correction
	var to_target: Vector3 = _direction_to_target()
	var tangent: Vector3 = Vector3(-to_target.z, 0, to_target.x).normalized() * float(_circle_direction)
	var radial: Vector3 = to_target * sign(dist - preferred_range_m) * 0.5
	var move: Vector3 = (tangent + radial).normalized() * circle_speed_m_s
	_body.velocity = Vector3(move.x, _body.velocity.y, move.z)
	_body.move_and_slide()
	# Look at player
	_face_target()
	# Decide to charge: must be near preferred range AND cooldown elapsed
	if _charge_cooldown_timer <= 0.0 and absf(dist - preferred_range_m) < 1.5:
		_change_state(State.WIND_UP)


# === WIND UP (0.3s coil tell) ===
func _process_wind_up() -> void:
	_body.velocity = Vector3(0, _body.velocity.y, 0)
	_body.move_and_slide()
	_face_target()
	if _state_timer >= wind_up_duration_s:
		# Lock dash direction at end of wind-up
		_dash_origin = _body.global_position
		_dash_direction = _direction_to_target()
		_dash_direction.y = 0
		_dash_direction = _dash_direction.normalized()
		_hit_player_this_charge = false
		_change_state(State.CHARGE)


# === CHARGE (8m straight-line dash) ===
func _process_charge(delta: float) -> void:
	var traveled: float = _body.global_position.distance_to(_dash_origin)
	if traveled >= dash_distance_m:
		_change_state(State.RECOVER)
		return
	_body.velocity = _dash_direction * dash_speed_m_s + Vector3(0, _body.velocity.y, 0)
	_body.move_and_slide()


# === RECOVER (1.0s vulnerable skid) ===
func _process_recover() -> void:
	_body.velocity = Vector3(_body.velocity.x * 0.6, _body.velocity.y, _body.velocity.z * 0.6)
	_body.move_and_slide()
	if _state_timer >= recover_duration_s:
		_charge_cooldown_timer = charge_cooldown_s
		# Flip circle direction so the next charge comes from a different angle
		_circle_direction = -_circle_direction
		_change_state(State.APPROACH)


# === STAGGER (from melee counter-hit) ===
func _process_stagger() -> void:
	_body.velocity = Vector3(0, _body.velocity.y, 0)
	_body.move_and_slide()
	if _state_timer >= stagger_duration_s:
		_change_state(State.APPROACH)


func _face_target() -> void:
	if _target == null:
		return
	var dir: Vector3 = _direction_to_target()
	if dir.length_squared() < 0.001:
		return
	var look_pos: Vector3 = _body.global_position + Vector3(dir.x, 0, dir.z)
	_body.look_at(look_pos, Vector3.UP)


# === HITBOX HANDLERS ===
func _on_attack_hitbox_body_entered(body: Node3D) -> void:
	if _state != State.CHARGE or _hit_player_this_charge:
		return
	if body == _target:
		_hit_player_this_charge = true
		if body.has_method("apply_damage"):
			body.call("apply_damage", dash_damage)
		if body.has_method("apply_stagger"):
			body.call("apply_stagger", 0.4)


func _on_damage_taken(_amount: float) -> void:
	# Hit during recover OR wind-up triggers stagger; otherwise resilient
	if _state == State.RECOVER or _state == State.WIND_UP:
		_change_state(State.STAGGER)


func _on_died() -> void:
	_change_state(State.DEAD)
	_body.velocity = Vector3.ZERO
	_body.move_and_slide()
