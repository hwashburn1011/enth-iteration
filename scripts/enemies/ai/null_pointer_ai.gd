class_name NullPointerAI
extends Node

## Null Pointer AI state machine (Epic 08 task 28).
## Implements the "spike teleport sniper" combat role from the enemy bible:
## stays at 12-15m range, every 4 seconds picks a random angle 8-10m from
## the player, plays a 0.2s cyan flash telegraph at the destination,
## teleports there, then charges a 1.5s ranged shot dealing 35 damage.
##
## Counter-play: shoot during the charge (interruptible). Or close to
## melee range to break concentration.
##
## States:
##   IDLE         — no aggro
##   REPOSITION   — picks teleport destination + plays flash telegraph
##   TELEPORT_OUT — fade visual transition (0.15s)
##   TELEPORT_IN  — appear at destination (0.15s)
##   CHARGE_SHOT  — 1.5s aiming windup
##   FIRE         — instant projectile spawn
##   STAGGER      — interrupted by melee or hit during charge
##   DEAD
##
## Required scene shape:
##   NullPointer (CharacterBody3D root)
##     NullPointerAI (Node + this script)
##     HealthComponent
##     ProjectileSpawner (Node3D with spawn_projectile method)
##     AnimationPlayer
##     [optional] FadeMeshes (visible Array[MeshInstance3D] for fade-in/out)

enum State {
	IDLE,
	REPOSITION,
	TELEPORT_OUT,
	TELEPORT_IN,
	CHARGE_SHOT,
	FIRE,
	STAGGER,
	DEAD,
}

signal state_changed(new_state: State)
signal teleport_telegraph(world_position: Vector3)

@export var target_path: NodePath
@export var aggro_range_m: float = 18.0
@export var min_engagement_range_m: float = 8.0
@export var max_engagement_range_m: float = 10.0
@export var melee_break_range_m: float = 3.0
@export var teleport_telegraph_lead_s: float = 0.2
@export var teleport_out_duration_s: float = 0.15
@export var teleport_in_duration_s: float = 0.15
@export var charge_duration_s: float = 1.5
@export var reposition_cooldown_s: float = 4.0
@export var shot_damage: float = 35.0
@export var stagger_duration_s: float = 0.5
@export var projectile_spawner_path: NodePath

var _target: Node3D
var _body: CharacterBody3D
var _state: State = State.IDLE
var _state_timer: float = 0.0
var _next_teleport_destination: Vector3 = Vector3.ZERO
var _telegraph_played: bool = false
var _projectile_spawner: Node


func _ready() -> void:
	_target = get_node_or_null(target_path) as Node3D
	_body = get_parent() as CharacterBody3D
	_projectile_spawner = get_node_or_null(projectile_spawner_path)
	if _body == null:
		push_warning("NullPointerAI: parent must be CharacterBody3D")
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
	match _state:
		State.IDLE:         _process_idle()
		State.REPOSITION:   _process_reposition()
		State.TELEPORT_OUT: _process_teleport_out()
		State.TELEPORT_IN:  _process_teleport_in()
		State.CHARGE_SHOT:  _process_charge_shot()
		State.FIRE:         _process_fire()
		State.STAGGER:      _process_stagger()


func _change_state(new_state: State) -> void:
	if new_state == _state:
		return
	_state = new_state
	_state_timer = 0.0
	_telegraph_played = false
	state_changed.emit(new_state)


func _distance_to_target() -> float:
	if _target == null:
		return INF
	return _body.global_position.distance_to(_target.global_position)


func _pick_teleport_destination() -> Vector3:
	if _target == null:
		return _body.global_position
	var angle: float = randf() * TAU
	var distance: float = randf_range(min_engagement_range_m, max_engagement_range_m)
	var offset: Vector3 = Vector3(cos(angle), 0, sin(angle)) * distance
	return _target.global_position + offset


# === IDLE ===
func _process_idle() -> void:
	if _target != null and _distance_to_target() < aggro_range_m:
		_change_state(State.REPOSITION)
	_body.velocity = Vector3(0, _body.velocity.y, 0)
	_body.move_and_slide()


# === REPOSITION (pick destination + play flash telegraph) ===
func _process_reposition() -> void:
	if not _telegraph_played:
		_next_teleport_destination = _pick_teleport_destination()
		teleport_telegraph.emit(_next_teleport_destination)
		_telegraph_played = true
	_body.velocity = Vector3(0, _body.velocity.y, 0)
	_body.move_and_slide()
	if _state_timer >= teleport_telegraph_lead_s:
		_change_state(State.TELEPORT_OUT)


# === TELEPORT OUT ===
func _process_teleport_out() -> void:
	# Fade out visuals (would tween mesh transparency in a full impl)
	if _state_timer >= teleport_out_duration_s:
		_body.global_position = _next_teleport_destination
		_change_state(State.TELEPORT_IN)


# === TELEPORT IN ===
func _process_teleport_in() -> void:
	# Fade in visuals
	if _state_timer >= teleport_in_duration_s:
		_face_target()
		_change_state(State.CHARGE_SHOT)


# === CHARGE SHOT (1.5s windup, interruptible) ===
func _process_charge_shot() -> void:
	if _target == null:
		_change_state(State.IDLE)
		return
	# Break if player closes to melee
	if _distance_to_target() < melee_break_range_m:
		_change_state(State.STAGGER)
		return
	_face_target()
	_body.velocity = Vector3(0, _body.velocity.y, 0)
	_body.move_and_slide()
	if _state_timer >= charge_duration_s:
		_change_state(State.FIRE)


# === FIRE ===
func _process_fire() -> void:
	# Spawn the projectile via the spawner
	if _projectile_spawner != null and _projectile_spawner.has_method("spawn_projectile"):
		var direction: Vector3 = (_target.global_position - _body.global_position).normalized()
		_projectile_spawner.call("spawn_projectile", direction, shot_damage)
	_change_state(State.REPOSITION)


# === STAGGER ===
func _process_stagger() -> void:
	_body.velocity = Vector3(0, _body.velocity.y, 0)
	_body.move_and_slide()
	if _state_timer >= stagger_duration_s:
		_change_state(State.REPOSITION)


func _face_target() -> void:
	if _target == null:
		return
	var dir: Vector3 = (_target.global_position - _body.global_position)
	dir.y = 0
	if dir.length_squared() < 0.001:
		return
	_body.look_at(_body.global_position + dir, Vector3.UP)


func _on_damage_taken(_amount: float) -> void:
	# Hits during charge interrupt the shot
	if _state == State.CHARGE_SHOT:
		_change_state(State.STAGGER)


func _on_died() -> void:
	_change_state(State.DEAD)
	_body.velocity = Vector3.ZERO
	_body.move_and_slide()
