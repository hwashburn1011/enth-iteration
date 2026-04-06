class_name PlayerAttackState
extends State
## Data Pulse basic attack — quick melee in mouse direction.

const ACTIVE_FRAME_START: float = 0.1
const ACTIVE_FRAME_END: float = 0.3
const ATTACK_DURATION: float = 0.4

var _timer: float = 0.0
var _hitbox_enabled: bool = false
var _has_hit: Dictionary = {}


func enter() -> void:
	var p: Player = player as Player
	_timer = 0.0
	_hitbox_enabled = false
	_has_hit.clear()

	# Face the mouse cursor
	var attack_dir: Vector3 = _get_mouse_world_direction(p)
	if attack_dir.length() > 0.0:
		p.facing_direction = attack_dir
		var target_angle: float = atan2(attack_dir.x, attack_dir.z)
		p.model.rotation.y = target_angle

	# Play attack animation
	if p.animation_player.has_animation(&"attack_primary"):
		p.animation_player.play(&"attack_primary")

	# Start attack cooldown
	p.can_attack = false
	p.attack_cooldown_timer.start(0.5)

	# Disable hitbox initially
	_set_hitbox_active(p, false)


func physics_update(delta: float) -> void:
	var p: Player = player as Player
	_timer += delta

	# Enable hitbox during active frames
	if _timer >= ACTIVE_FRAME_START and _timer < ACTIVE_FRAME_END:
		if not _hitbox_enabled:
			_set_hitbox_active(p, true)
			_hitbox_enabled = true
		# Check for overlapping hurtboxes
		_check_hits(p)
	elif _hitbox_enabled:
		_set_hitbox_active(p, false)
		_hitbox_enabled = false

	# End attack after duration
	if _timer >= ATTACK_DURATION:
		_set_hitbox_active(p, false)
		var input_vector: Vector2 = Input.get_vector(
			&"move_left", &"move_right", &"move_forward", &"move_back"
		)
		if input_vector.length() > 0.0:
			state_machine.transition_to(state_machine.get_node("WalkState") as State)
		else:
			state_machine.transition_to(state_machine.get_node("IdleState") as State)


func exit() -> void:
	var p: Player = player as Player
	_set_hitbox_active(p, false)
	_hitbox_enabled = false


func _check_hits(p: Player) -> void:
	var hitbox: Area3D = p.hitbox_component
	for area: Area3D in hitbox.get_overlapping_areas():
		if area == p.hurtbox_component:
			continue
		var area_id: int = area.get_instance_id()
		if area_id in _has_hit:
			continue
		_has_hit[area_id] = true
		var info: DamageInfo = DamageInfo.new()
		info.source = p
		info.base_damage = 5.0 + p.stats_component.get_stat("processing") * 1.5
		info.damage_type = &"data"
		if area.has_method(&"receive_damage"):
			area.receive_damage(info)


func _set_hitbox_active(p: Player, active: bool) -> void:
	var hitbox: Area3D = p.hitbox_component
	hitbox.monitoring = active
	hitbox.monitorable = active
	for child: Node in hitbox.get_children():
		if child is CollisionShape3D:
			child.disabled = not active


func _get_mouse_world_direction(p: Player) -> Vector3:
	var camera: Camera3D = p.get_viewport().get_camera_3d()
	if camera == null:
		return p.facing_direction
	var mouse_pos: Vector2 = p.get_viewport().get_mouse_position()
	var ray_origin: Vector3 = camera.project_ray_origin(mouse_pos)
	var ray_dir: Vector3 = camera.project_ray_normal(mouse_pos)
	# Intersect with ground plane (Y=0)
	if absf(ray_dir.y) < 0.001:
		return p.facing_direction
	var t: float = -ray_origin.y / ray_dir.y
	var ground_pos: Vector3 = ray_origin + ray_dir * t
	var direction: Vector3 = (ground_pos - p.global_position)
	direction.y = 0.0
	if direction.length() < 0.1:
		return p.facing_direction
	return direction.normalized()
