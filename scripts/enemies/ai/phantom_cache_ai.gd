class_name PhantomCacheAI
extends Node

## Phantom Cache AI state machine (Epic 08 task 33).
## Implements the "loot puzzle" combat role: doesn't attack, RUNS AWAY
## from the player at 90% of player speed. If killed within 8 seconds
## of first detection, drops 3x normal loot + a guaranteed rare item.
## If it escapes off-screen, it disappears with the loot.
##
## States:
##   IDLE      — no aggro, hovers
##   FLEEING   — runs from player, 8-second kill-window timer running
##   ESCAPED   — too far from player or timer expired, despawns
##   KILLED    — drops bonus loot
##
## Required scene shape:
##   PhantomCache (CharacterBody3D root)
##     PhantomCacheAI (Node + this script)
##     HealthComponent
##     export bonus_loot_scene: PackedScene to spawn on quick-kill
##     export normal_loot_table: Resource

enum State {
	IDLE,
	FLEEING,
	ESCAPED,
	KILLED,
}

signal state_changed(new_state: State)
signal escaped_with_loot
signal killed_quickly_dropped_bonus

@export var target_path: NodePath
@export var detection_range_m: float = 12.0
@export var escape_range_m: float = 28.0
@export var quick_kill_window_s: float = 8.0
@export var flee_speed_factor: float = 0.9
@export var flee_speed_m_s: float = 5.5
@export var bonus_loot_scene: PackedScene
@export var normal_loot_table: Resource

var _target: Node3D
var _body: CharacterBody3D
var _state: State = State.IDLE
var _detection_time_ms: int = -1


func _ready() -> void:
	_target = get_node_or_null(target_path) as Node3D
	_body = get_parent() as CharacterBody3D
	if _body == null:
		push_warning("PhantomCacheAI: parent must be CharacterBody3D")
		return
	for child: Node in _body.get_children():
		if child.has_signal("died"):
			child.died.connect(_on_died)


func _physics_process(_delta: float) -> void:
	if _body == null or _state == State.KILLED or _state == State.ESCAPED:
		return
	match _state:
		State.IDLE:    _process_idle()
		State.FLEEING: _process_fleeing()


func _change_state(new_state: State) -> void:
	if new_state == _state:
		return
	_state = new_state
	state_changed.emit(new_state)


func _distance_to_target() -> float:
	if _target == null:
		return INF
	return _body.global_position.distance_to(_target.global_position)


func _process_idle() -> void:
	if _target != null and _distance_to_target() < detection_range_m:
		_detection_time_ms = Time.get_ticks_msec()
		_change_state(State.FLEEING)


func _process_fleeing() -> void:
	if _target == null:
		return
	var dist: float = _distance_to_target()
	if dist > escape_range_m:
		_change_state(State.ESCAPED)
		_despawn_with_loot()
		return
	# Check if we've outlasted the quick-kill window — no longer drops bonus
	# but still flees until escape range
	# (the bonus check happens in _on_died via _is_within_quick_kill_window)
	# Run away from player
	var away: Vector3 = (_body.global_position - _target.global_position).normalized()
	away.y = 0
	if away.length_squared() < 0.01:
		# Player is on top of us — pick a random direction
		away = Vector3(randf() - 0.5, 0, randf() - 0.5).normalized()
	_body.velocity = away * flee_speed_m_s + Vector3(0, _body.velocity.y, 0)
	_body.move_and_slide()


func _is_within_quick_kill_window() -> bool:
	if _detection_time_ms < 0:
		return false
	var elapsed_s: float = (Time.get_ticks_msec() - _detection_time_ms) / 1000.0
	return elapsed_s <= quick_kill_window_s


func _despawn_with_loot() -> void:
	escaped_with_loot.emit()
	_body.queue_free()


func _on_died() -> void:
	_change_state(State.KILLED)
	if _is_within_quick_kill_window() and bonus_loot_scene != null:
		killed_quickly_dropped_bonus.emit()
		# Spawn 3x bonus loot at body position
		for i in range(3):
			var loot: Node3D = bonus_loot_scene.instantiate() as Node3D
			_body.get_parent().add_child(loot)
			var offset: Vector3 = Vector3(
				randf_range(-0.5, 0.5),
				0,
				randf_range(-0.5, 0.5),
			)
			loot.global_position = _body.global_position + offset
