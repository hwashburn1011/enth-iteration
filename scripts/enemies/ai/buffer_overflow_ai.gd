class_name BufferOverflowAI
extends Node

## Buffer Overflow AI state machine (Epic 08 task 32).
## Implements the "suicide bomb" combat role: walks slowly toward player
## while INFLATING in real time. Explodes at full inflation OR on death
## dealing 60 damage in a 5m radius. The size growth IS the warning —
## no animation telegraph.
##
## States:
##   IDLE      — no aggro, normal size
##   APPROACH  — walks toward player, inflates as it gets closer
##   PRIMED    — fully inflated, slowest movement, ready to detonate
##   EXPLODE   — instant blast, free self
##   DEAD      — killed before detonation, also explodes
##
## Inflation curve:
##   distance > 12m  → scale 1.0
##   distance 12→6m  → scale 1.0 → 1.5
##   distance 6→2m   → scale 1.5 → 2.0  (PRIMED at 2m)
##   detonation      → scale 2.0 → 0.0 in explosion frame
##
## Required scene shape:
##   BufferOverflow (CharacterBody3D root)
##     BufferOverflowAI (Node + this script)
##     HealthComponent
##     BodyMesh (MeshInstance3D for scale animation)

enum State {
	IDLE,
	APPROACH,
	PRIMED,
	EXPLODE,
	DEAD,
}

signal state_changed(new_state: State)
signal exploded(world_position: Vector3, damage: float, radius: float)

@export var target_path: NodePath
@export var aggro_range_m: float = 18.0
@export var primed_distance_m: float = 2.0
@export var walk_speed_m_s: float = 2.5
@export var primed_speed_m_s: float = 1.0
@export var blast_damage: float = 60.0
@export var blast_radius_m: float = 5.0
@export var body_mesh_path: NodePath
@export var max_inflation_scale: float = 2.0

var _target: Node3D
var _body: CharacterBody3D
var _state: State = State.IDLE
var _state_timer: float = 0.0
var _body_mesh: MeshInstance3D
var _initial_mesh_scale: Vector3 = Vector3.ONE


func _ready() -> void:
	_target = get_node_or_null(target_path) as Node3D
	_body = get_parent() as CharacterBody3D
	_body_mesh = get_node_or_null(body_mesh_path) as MeshInstance3D
	if _body_mesh != null:
		_initial_mesh_scale = _body_mesh.scale
	if _body == null:
		push_warning("BufferOverflowAI: parent must be CharacterBody3D")
		return
	for child: Node in _body.get_children():
		if child.has_signal("died"):
			child.died.connect(_on_died)


func _physics_process(delta: float) -> void:
	if _body == null or _state == State.DEAD or _state == State.EXPLODE:
		return
	_state_timer += delta
	match _state:
		State.IDLE:     _process_idle()
		State.APPROACH: _process_approach()
		State.PRIMED:   _process_primed()
	_apply_inflation()


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
		_change_state(State.APPROACH)


func _process_approach() -> void:
	if _target == null:
		_change_state(State.IDLE)
		return
	var dist: float = _distance_to_target()
	if dist <= primed_distance_m:
		_change_state(State.PRIMED)
		return
	var dir: Vector3 = (_target.global_position - _body.global_position).normalized()
	dir.y = 0
	_body.velocity = dir * walk_speed_m_s + Vector3(0, _body.velocity.y, 0)
	_body.move_and_slide()


func _process_primed() -> void:
	# Move slower, but if the player runs away the bomb still tracks
	if _target == null:
		_explode()
		return
	if _distance_to_target() > primed_distance_m + 0.5:
		# Crawling primed approach
		var dir: Vector3 = (_target.global_position - _body.global_position).normalized()
		dir.y = 0
		_body.velocity = dir * primed_speed_m_s + Vector3(0, _body.velocity.y, 0)
		_body.move_and_slide()
		return
	# At primed distance — detonate after a short fuse
	if _state_timer >= 0.4:
		_explode()


func _apply_inflation() -> void:
	if _body_mesh == null or _target == null:
		return
	var dist: float = _distance_to_target()
	# Inflation curve: scale grows from 1.0 → max_inflation_scale as distance shrinks
	var t: float = clamp((aggro_range_m - dist) / (aggro_range_m - primed_distance_m), 0.0, 1.0)
	t = t * t  # ease-in so growth accelerates
	var scale_mult: float = lerp(1.0, max_inflation_scale, t)
	_body_mesh.scale = _initial_mesh_scale * scale_mult


func _explode() -> void:
	if _state == State.EXPLODE or _state == State.DEAD:
		return
	_change_state(State.EXPLODE)
	# Apply blast damage to anything within radius
	var blast_pos: Vector3 = _body.global_position
	exploded.emit(blast_pos, blast_damage, blast_radius_m)
	if _target != null:
		var dist: float = _target.global_position.distance_to(blast_pos)
		if dist <= blast_radius_m and _target.has_method("apply_damage"):
			# Linear falloff
			var falloff: float = 1.0 - (dist / blast_radius_m)
			_target.call("apply_damage", blast_damage * falloff)
	_body.queue_free()


func _on_died() -> void:
	# Killed before detonation — still explodes
	_explode()
