class_name StackOverflowAI
extends Node

## Stack Overflow AI state machine (Epic 08 task 29).
## Implements the "area denial column" combat role: cannot move (rooted
## to base), fires DOWNWARD attacks from its top cube every 3 seconds.
## Attack type rotates: red AOE blast, cyan slow column, yellow 5-shot fan.
## Top cube color tells the player what's coming next.
##
## States:
##   IDLE      — no aggro
##   ROTATE    — top cube rotates color (next attack picked)
##   TELEGRAPH — windup with floor decal showing AOE position
##   FIRE      — instant damage application + projectile spawn
##   COOLDOWN  — 3s pause before next rotate
##   DEAD
##
## Attack types:
##   RED_AOE      — single 3m circle blast at player position, 20 damage
##   CYAN_COLUMN  — slow-moving 1m wide column from sky, side-stepable
##   YELLOW_FAN   — 5 fast projectiles in a 60deg fan
##
## Required scene shape:
##   StackOverflow (Node3D root, immobile)
##     StackOverflowAI (Node + this script)
##     HealthComponent (300% HP, very tanky)
##     TopCubeMeshInstance (MeshInstance3D for color rotation)
##     ProjectileSpawner (Node3D with spawn_projectile method)
##     export attack_telegraph_path: NodePath to BossAttackTelegraph reusable

enum State {
	IDLE,
	ROTATE,
	TELEGRAPH,
	FIRE,
	COOLDOWN,
	DEAD,
}

enum AttackType {
	RED_AOE,
	CYAN_COLUMN,
	YELLOW_FAN,
}

signal state_changed(new_state: State)
signal attack_telegraphed(attack_type: AttackType, world_pos: Vector3)

@export var target_path: NodePath
@export var aggro_range_m: float = 22.0
@export var attack_cooldown_s: float = 3.0
@export var telegraph_duration_s: float = 1.5
@export var top_cube_mesh_path: NodePath
@export var attack_telegraph_path: NodePath
@export var projectile_spawner_path: NodePath
@export var aoe_radius_m: float = 3.0
@export var aoe_damage: float = 20.0
@export var column_radius_m: float = 0.5
@export var column_damage: float = 25.0
@export var fan_projectile_count: int = 5
@export var fan_spread_deg: float = 60.0
@export var fan_damage: float = 10.0

var _target: Node3D
var _root: Node3D
var _state: State = State.IDLE
var _state_timer: float = 0.0
var _next_attack: AttackType = AttackType.RED_AOE
var _attack_target_pos: Vector3 = Vector3.ZERO
var _top_cube: MeshInstance3D
var _telegraph_node: Node
var _projectile_spawner: Node


func _ready() -> void:
	_target = get_node_or_null(target_path) as Node3D
	_root = get_parent() as Node3D
	_top_cube = get_node_or_null(top_cube_mesh_path) as MeshInstance3D
	_telegraph_node = get_node_or_null(attack_telegraph_path)
	_projectile_spawner = get_node_or_null(projectile_spawner_path)
	if _root == null:
		push_warning("StackOverflowAI: parent must be Node3D")
		return
	for child: Node in _root.get_children():
		if child.has_signal("died"):
			child.died.connect(_on_died)


func _process(delta: float) -> void:
	if _root == null or _state == State.DEAD:
		return
	_state_timer += delta
	match _state:
		State.IDLE:      _process_idle()
		State.ROTATE:    _process_rotate()
		State.TELEGRAPH: _process_telegraph()
		State.FIRE:      _process_fire()
		State.COOLDOWN:  _process_cooldown()


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
		_change_state(State.ROTATE)


func _process_rotate() -> void:
	# Pick next attack type randomly weighted toward variety
	_next_attack = [AttackType.RED_AOE, AttackType.CYAN_COLUMN, AttackType.YELLOW_FAN][randi() % 3]
	_apply_top_cube_color()
	_change_state(State.TELEGRAPH)


func _apply_top_cube_color() -> void:
	if _top_cube == null:
		return
	var color: Color = Color.WHITE
	match _next_attack:
		AttackType.RED_AOE:    color = Color(1.0, 0.10, 0.05)
		AttackType.CYAN_COLUMN: color = Color(0.0, 0.95, 0.95)
		AttackType.YELLOW_FAN: color = Color(1.0, 0.85, 0.05)
	var mat: StandardMaterial3D = _top_cube.material_override as StandardMaterial3D
	if mat == null:
		mat = StandardMaterial3D.new()
		_top_cube.material_override = mat
	mat.albedo_color = color
	mat.emission_enabled = true
	mat.emission = color
	mat.emission_energy_multiplier = 4.0


func _process_telegraph() -> void:
	if _state_timer < 0.05 and _target != null:
		_attack_target_pos = _target.global_position
		attack_telegraphed.emit(_next_attack, _attack_target_pos)
		# Drive the BossAttackTelegraph node if assigned
		if _telegraph_node != null:
			match _next_attack:
				AttackType.RED_AOE:
					if _telegraph_node.has_method("show_circle"):
						_telegraph_node.call("show_circle", _attack_target_pos, aoe_radius_m, telegraph_duration_s)
				AttackType.CYAN_COLUMN:
					if _telegraph_node.has_method("show_circle"):
						_telegraph_node.call("show_circle", _attack_target_pos, column_radius_m, telegraph_duration_s)
				AttackType.YELLOW_FAN:
					# Fan: cone from the StackOverflow base
					if _telegraph_node.has_method("show_cone"):
						var facing: Vector3 = (_attack_target_pos - _root.global_position).normalized()
						_telegraph_node.call("show_cone", _root.global_position, facing, 12.0, fan_spread_deg / 2.0, telegraph_duration_s)
	if _state_timer >= telegraph_duration_s:
		_change_state(State.FIRE)


func _process_fire() -> void:
	# Apply attack damage based on type
	match _next_attack:
		AttackType.RED_AOE:
			_apply_aoe_damage()
		AttackType.CYAN_COLUMN:
			_apply_column_damage()
		AttackType.YELLOW_FAN:
			_spawn_fan_projectiles()
	_change_state(State.COOLDOWN)


func _apply_aoe_damage() -> void:
	if _target == null:
		return
	var dist: float = _target.global_position.distance_to(_attack_target_pos)
	if dist <= aoe_radius_m and _target.has_method("apply_damage"):
		_target.call("apply_damage", aoe_damage)


func _apply_column_damage() -> void:
	if _target == null:
		return
	var dist: float = _target.global_position.distance_to(_attack_target_pos)
	if dist <= column_radius_m and _target.has_method("apply_damage"):
		_target.call("apply_damage", column_damage)


func _spawn_fan_projectiles() -> void:
	if _projectile_spawner == null or not _projectile_spawner.has_method("spawn_projectile"):
		return
	if _target == null:
		return
	var center_dir: Vector3 = (_target.global_position - _root.global_position).normalized()
	var spread_step: float = fan_spread_deg / float(fan_projectile_count - 1)
	for i in range(fan_projectile_count):
		var offset_deg: float = -fan_spread_deg / 2.0 + spread_step * i
		var rotated: Vector3 = center_dir.rotated(Vector3.UP, deg_to_rad(offset_deg))
		_projectile_spawner.call("spawn_projectile", rotated, fan_damage)


func _process_cooldown() -> void:
	if _state_timer >= attack_cooldown_s:
		_change_state(State.ROTATE)


func _on_died() -> void:
	_change_state(State.DEAD)
