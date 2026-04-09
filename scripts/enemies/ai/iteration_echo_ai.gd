class_name IterationEchoAI
extends Node

## Iteration Echo AI state machine (Epic 08 task 34).
## Implements the "mirror match" combat role: the player's silhouette
## with inverted colors. Uses player skeleton, copies the player's
## CURRENT loadout (main attack + dodge), at 60% damage and 75% HP.
## Dodges in the player's direction with 0.2s reaction delay so it can
## be outplayed.
##
## States:
##   IDLE       — no aggro
##   POSITION   — moves to optimal range for current loadout
##   ATTACK     — fires the player's main attack
##   DODGE      — mirrors the player's dodge with reaction delay
##   STAGGER
##   DEAD
##
## The Echo reads the player's loadout via the LoadoutMirror service
## (a separate component that snapshots the player's currently equipped
## ability + weapon at spawn time).
##
## Required scene shape:
##   IterationEcho (CharacterBody3D root, uses player skeleton)
##     IterationEchoAI (Node + this script)
##     LoadoutMirror (snapshots player loadout)
##     HealthComponent (75% of player max)

enum State {
	IDLE,
	POSITION,
	ATTACK,
	DODGE,
	STAGGER,
	DEAD,
}

signal state_changed(new_state: State)

@export var target_path: NodePath
@export var aggro_range_m: float = 16.0
@export var damage_scale_factor: float = 0.6
@export var hp_scale_factor: float = 0.75
@export var dodge_reaction_delay_s: float = 0.2
@export var dodge_distance_m: float = 4.0
@export var dodge_duration_s: float = 0.35
@export var attack_cooldown_s: float = 1.2
@export var loadout_mirror_path: NodePath

var _target: Node3D
var _body: CharacterBody3D
var _state: State = State.IDLE
var _state_timer: float = 0.0
var _attack_cooldown_timer: float = 0.0
var _loadout_mirror: Node
var _pending_dodge_direction: Vector3 = Vector3.ZERO
var _dodge_react_timer: float = 0.0
var _last_target_velocity: Vector3 = Vector3.ZERO
var _last_target_pos: Vector3 = Vector3.ZERO


func _ready() -> void:
	_target = get_node_or_null(target_path) as Node3D
	_body = get_parent() as CharacterBody3D
	_loadout_mirror = get_node_or_null(loadout_mirror_path)
	if _body == null:
		push_warning("IterationEchoAI: parent must be CharacterBody3D")
		return
	for child: Node in _body.get_children():
		if child.has_signal("damage_taken"):
			child.damage_taken.connect(_on_damage_taken)
		if child.has_signal("died"):
			child.died.connect(_on_died)


func _physics_process(delta: float) -> void:
	if _body == null or _state == State.DEAD:
		return
	_state_timer += delta
	if _attack_cooldown_timer > 0.0:
		_attack_cooldown_timer -= delta
	_track_target_velocity(delta)
	_check_for_dodge_trigger(delta)
	match _state:
		State.IDLE:     _process_idle()
		State.POSITION: _process_position()
		State.ATTACK:   _process_attack()
		State.DODGE:    _process_dodge()
		State.STAGGER:  _process_stagger()


func _change_state(new_state: State) -> void:
	if new_state == _state:
		return
	_state = new_state
	_state_timer = 0.0
	state_changed.emit(new_state)


func _track_target_velocity(delta: float) -> void:
	if _target == null:
		return
	if delta > 0.0:
		_last_target_velocity = (_target.global_position - _last_target_pos) / delta
	_last_target_pos = _target.global_position


func _check_for_dodge_trigger(delta: float) -> void:
	# Mirror the player's dodge: if the player just dashed (high velocity
	# burst), schedule a dodge with the reaction delay
	if _state == State.DODGE or _state == State.DEAD:
		return
	if _last_target_velocity.length() > 8.0:  # heuristic for player dash
		_pending_dodge_direction = _last_target_velocity.normalized()
		_dodge_react_timer = dodge_reaction_delay_s
	if _dodge_react_timer > 0.0:
		_dodge_react_timer -= delta
		if _dodge_react_timer <= 0.0:
			_change_state(State.DODGE)


func _distance_to_target() -> float:
	if _target == null:
		return INF
	return _body.global_position.distance_to(_target.global_position)


func _get_optimal_range() -> float:
	# Read from loadout mirror — defaults to 5m if no loadout
	if _loadout_mirror != null and _loadout_mirror.has_method("get_optimal_range"):
		return _loadout_mirror.call("get_optimal_range")
	return 5.0


func _process_idle() -> void:
	if _target != null and _distance_to_target() < aggro_range_m:
		_change_state(State.POSITION)


func _process_position() -> void:
	if _target == null:
		_change_state(State.IDLE)
		return
	var dist: float = _distance_to_target()
	var optimal: float = _get_optimal_range()
	var to_target: Vector3 = (_target.global_position - _body.global_position).normalized()
	to_target.y = 0
	# Maintain optimal: move forward if too far, back if too close
	var move_dir: Vector3 = to_target * sign(dist - optimal)
	_body.velocity = move_dir * 4.0 + Vector3(0, _body.velocity.y, 0)
	_body.move_and_slide()
	_face_target()
	if absf(dist - optimal) < 1.0 and _attack_cooldown_timer <= 0.0:
		_change_state(State.ATTACK)


func _process_attack() -> void:
	# Fire the mirrored player attack via the loadout mirror service
	if _loadout_mirror != null and _loadout_mirror.has_method("fire_mirrored_attack"):
		var dir: Vector3 = (_target.global_position - _body.global_position).normalized()
		_loadout_mirror.call("fire_mirrored_attack", dir, damage_scale_factor)
	_attack_cooldown_timer = attack_cooldown_s
	_change_state(State.POSITION)


func _process_dodge() -> void:
	if _state_timer < dodge_duration_s:
		_body.velocity = _pending_dodge_direction * (dodge_distance_m / dodge_duration_s)
		_body.velocity.y = 0
		_body.move_and_slide()
	else:
		_change_state(State.POSITION)


func _process_stagger() -> void:
	if _state_timer >= 0.4:
		_change_state(State.POSITION)


func _face_target() -> void:
	if _target == null:
		return
	var dir: Vector3 = (_target.global_position - _body.global_position)
	dir.y = 0
	if dir.length_squared() < 0.001:
		return
	_body.look_at(_body.global_position + dir, Vector3.UP)


func _on_damage_taken(_amount: float) -> void:
	if _state == State.ATTACK:
		_change_state(State.STAGGER)


func _on_died() -> void:
	_change_state(State.DEAD)
