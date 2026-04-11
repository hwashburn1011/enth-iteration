class_name RaceConditionAI
extends Node

## Race Condition AI state machine (Epic 08 task 30).
## Implements the "multiplier" combat role: fast melee charger that
## SPLITS into 2 smaller copies when damaged below 50% HP. Those copies
## can split again at 25% HP. Max 4 generations from a starting unit.
## The split moment has 0.5s of invuln so the player can't kill mid-split.
##
## States:
##   IDLE       — no aggro
##   PURSUE     — chases target at fast speed
##   MELEE      — close-range damage tick on contact
##   SPLITTING  — 0.5s invuln + scale animation + spawn copies
##   STAGGER
##   DEAD
##
## Required scene shape:
##   RaceCondition (CharacterBody3D root)
##     RaceConditionAI (Node + this script)
##     HealthComponent
##     export split_scene: PackedScene to instantiate copies (self-reference)
##     export generation: int (0 = original, increments on split)

enum State {
	IDLE,
	PURSUE,
	MELEE,
	SPLITTING,
	STAGGER,
	DEAD,
}

signal state_changed(new_state: State)
signal copies_spawned(copies: Array[Node3D])

@export var target_path: NodePath
@export var aggro_range_m: float = 16.0
@export var melee_range_m: float = 1.4
@export var pursuit_speed_m_s: float = 6.5
@export var melee_damage: float = 12.0
@export var melee_tick_interval_s: float = 0.5
@export var split_animation_duration_s: float = 0.5
@export var split_threshold_pct: float = 0.5
@export var max_generation: int = 3
@export var generation: int = 0
@export var split_scene: PackedScene

var _target: Node3D
var _body: CharacterBody3D
var _hc: Node
var _state: State = State.IDLE
var _state_timer: float = 0.0
var _melee_tick_timer: float = 0.0
var _has_split: bool = false


func _ready() -> void:
	_target = get_node_or_null(target_path) as Node3D
	_body = get_parent() as CharacterBody3D
	if _body == null:
		push_warning("RaceConditionAI: parent must be CharacterBody3D")
		return
	for child: Node in _body.get_children():
		if child.has_signal("damage_taken"):
			_hc = child
			child.damage_taken.connect(_on_damage_taken)
		if child.has_signal("died"):
			child.died.connect(_on_died)


func _physics_process(delta: float) -> void:
	if _body == null or _state == State.DEAD:
		return
	_state_timer += delta
	if _melee_tick_timer > 0.0:
		_melee_tick_timer -= delta
	match _state:
		State.IDLE:      _process_idle()
		State.PURSUE:    _process_pursue()
		State.MELEE:     _process_melee()
		State.SPLITTING: _process_splitting()
		State.STAGGER:   _process_stagger()


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


func _process_idle() -> void:
	if _target != null and _distance_to_target() < aggro_range_m:
		_change_state(State.PURSUE)
	_body.velocity = Vector3(0, _body.velocity.y, 0)
	_body.move_and_slide()


func _process_pursue() -> void:
	if _target == null:
		_change_state(State.IDLE)
		return
	var dist: float = _distance_to_target()
	if dist <= melee_range_m:
		_change_state(State.MELEE)
		return
	var dir: Vector3 = (_target.global_position - _body.global_position).normalized()
	dir.y = 0
	_body.velocity = dir * pursuit_speed_m_s + Vector3(0, _body.velocity.y, 0)
	_body.move_and_slide()
	_face_target()


func _process_melee() -> void:
	if _target == null:
		_change_state(State.IDLE)
		return
	if _distance_to_target() > melee_range_m:
		_change_state(State.PURSUE)
		return
	_body.velocity = Vector3(0, _body.velocity.y, 0)
	_body.move_and_slide()
	_face_target()
	if _melee_tick_timer <= 0.0:
		if _target.has_method("apply_damage"):
			_target.call("apply_damage", melee_damage)
		_melee_tick_timer = melee_tick_interval_s


func _process_splitting() -> void:
	# 0.5s invuln + scale-down tween then spawn 2 copies + free self
	_body.velocity = Vector3(0, _body.velocity.y, 0)
	_body.move_and_slide()
	if _state_timer >= split_animation_duration_s:
		_spawn_split_copies()
		_change_state(State.DEAD)
		_body.queue_free()


func _spawn_split_copies() -> void:
	if split_scene == null or _body.get_parent() == null:
		return
	var copies: Array[Node3D] = []
	for i in range(2):
		var copy: Node3D = split_scene.instantiate() as Node3D
		_body.get_parent().add_child(copy)
		# Position copies at slight offset
		var offset_angle: float = float(i) * PI
		var offset: Vector3 = Vector3(cos(offset_angle), 0, sin(offset_angle)) * 0.5
		copy.global_position = _body.global_position + offset
		copy.scale = _body.scale * 0.7
		# Bump generation on each child copy AI so they know not to over-split
		var child_ai: Node = copy.get_node_or_null("RaceConditionAI")
		if child_ai == null:
			# Find any RaceConditionAI in children
			for c: Node in copy.get_children():
				if c is RaceConditionAI:
					child_ai = c
					break
		if child_ai != null and child_ai is RaceConditionAI:
			(child_ai as RaceConditionAI).generation = generation + 1
			(child_ai as RaceConditionAI).target_path = target_path
		copies.append(copy)
	copies_spawned.emit(copies)


func _process_stagger() -> void:
	if _state_timer >= 0.3:
		_change_state(State.PURSUE)


func _face_target() -> void:
	if _target == null:
		return
	var dir: Vector3 = (_target.global_position - _body.global_position)
	dir.y = 0
	if dir.length_squared() < 0.001:
		return
	_body.look_at(_body.global_position + dir, Vector3.UP)


func _on_damage_taken(_amount: float) -> void:
	if _has_split or generation >= max_generation:
		return
	if _hc == null or not _hc.has_method("get_hp_pct"):
		return
	var hp_pct: float = _hc.call("get_hp_pct")
	if hp_pct <= split_threshold_pct:
		_has_split = true
		_change_state(State.SPLITTING)


func _on_died() -> void:
	_change_state(State.DEAD)
