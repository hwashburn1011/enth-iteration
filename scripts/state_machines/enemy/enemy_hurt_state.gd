class_name EnemyHurtState
extends "res://scripts/state_machines/state.gd"
## Enemy was hit — brief stun with knockback.
##
## Knockback uses an ease-out cubic curve so the enemy gets a strong initial
## pop and a smooth tail, instead of a linear deceleration that feels stiff.
## A small vertical kick adds a subtle "lift" so connecting hits register
## visually even from a top-down isometric angle.

const STUN_DURATION: float = 0.3
const KNOCKBACK_SPEED: float = 8.5
const UPWARD_KICK: float = 2.4
const UPWARD_KICK_GRAVITY: float = 14.0
const FLASH_DURATION: float = 0.08

var _timer: float = 0.0
var _knockback_dir: Vector3 = Vector3.ZERO
var _vertical_velocity: float = 0.0


func enter() -> void:
	var enemy: CharacterBody3D = player
	_timer = 0.0

	if enemy.has_meta(&"damage_source_position"):
		var source_pos: Vector3 = enemy.get_meta(&"damage_source_position") as Vector3
		_knockback_dir = (enemy.global_position - source_pos).normalized()
		_knockback_dir.y = 0.0
		enemy.remove_meta(&"damage_source_position")
	else:
		_knockback_dir = Vector3.ZERO

	# Brief upward kick — fades via gravity in physics_update
	_vertical_velocity = UPWARD_KICK if _knockback_dir != Vector3.ZERO else 0.0

	if enemy.animation_player.has_animation(&"hurt"):
		enemy.animation_player.play(&"hurt")

	# White flash on enemy model for hit feedback
	_flash_white(enemy)


func physics_update(delta: float) -> void:
	var enemy: CharacterBody3D = player
	_timer += delta

	# Ease-out cubic: 1 - (1-t)^3 of the *remaining* time gives a strong
	# initial pop that smoothly decays to zero.
	var t: float = clampf(_timer / STUN_DURATION, 0.0, 1.0)
	var inv: float = 1.0 - t
	var horizontal_factor: float = inv * inv * inv  # cubic ease-out
	enemy.velocity.x = _knockback_dir.x * KNOCKBACK_SPEED * horizontal_factor
	enemy.velocity.z = _knockback_dir.z * KNOCKBACK_SPEED * horizontal_factor

	# Vertical kick: integrate against a fake gravity, clamp at 0 once landed
	if _vertical_velocity > 0.0 or not enemy.is_on_floor():
		_vertical_velocity -= UPWARD_KICK_GRAVITY * delta
		enemy.velocity.y = _vertical_velocity
	else:
		enemy.velocity.y = 0.0

	enemy.move_and_slide()

	if _timer >= STUN_DURATION:
		_restore_material(enemy)
		state_machine.transition_to(state_machine.get_node("EnemyChaseState") as Node)


var _original_mats: Array[Material] = []
var _flashed_meshes: Array[MeshInstance3D] = []
var _flashed: bool = false


func _flash_white(enemy: CharacterBody3D) -> void:
	var meshes: Array[MeshInstance3D] = enemy.get_mesh_instances()
	if meshes.is_empty():
		return
	_original_mats.clear()
	_flashed_meshes = meshes
	var flash_mat: StandardMaterial3D = StandardMaterial3D.new()
	flash_mat.albedo_color = Color(1, 1, 1)
	flash_mat.emission_enabled = true
	flash_mat.emission = Color(1, 1, 1)
	flash_mat.emission_energy_multiplier = 2.0
	for mesh: MeshInstance3D in meshes:
		_original_mats.append(mesh.material_override)
		mesh.material_override = flash_mat
	_flashed = true
	# Restore after FLASH_DURATION
	if enemy.is_inside_tree():
		enemy.get_tree().create_timer(FLASH_DURATION).timeout.connect(func() -> void:
			for i: int in _flashed_meshes.size():
				var m: MeshInstance3D = _flashed_meshes[i]
				if is_instance_valid(m):
					m.material_override = _original_mats[i] if i < _original_mats.size() else null
		)


func _restore_material(_enemy: CharacterBody3D) -> void:
	if not _flashed:
		return
	_flashed = false
	for i: int in _flashed_meshes.size():
		var m: MeshInstance3D = _flashed_meshes[i]
		if is_instance_valid(m):
			m.material_override = _original_mats[i] if i < _original_mats.size() else null
