class_name EnemyHurtState
extends "res://scripts/state_machines/state.gd"
## Enemy was hit — brief stun with knockback.

const STUN_DURATION: float = 0.3
const KNOCKBACK_SPEED: float = 6.0

var _timer: float = 0.0
var _knockback_dir: Vector3 = Vector3.ZERO


func enter() -> void:
	var enemy = player
	_timer = 0.0

	if enemy.has_meta(&"damage_source_position"):
		var source_pos: Vector3 = enemy.get_meta(&"damage_source_position") as Vector3
		_knockback_dir = (enemy.global_position - source_pos).normalized()
		_knockback_dir.y = 0.0
		enemy.remove_meta(&"damage_source_position")
	else:
		_knockback_dir = Vector3.ZERO

	if enemy.animation_player.has_animation(&"hurt"):
		enemy.animation_player.play(&"hurt")

	# White flash on enemy model for hit feedback
	_flash_white(enemy)


func physics_update(delta: float) -> void:
	var enemy = player
	_timer += delta

	var factor: float = maxf(0.0, 1.0 - _timer / STUN_DURATION)
	enemy.velocity = _knockback_dir * KNOCKBACK_SPEED * factor
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
	# Restore after 0.08s
	if enemy.is_inside_tree():
		enemy.get_tree().create_timer(0.08).timeout.connect(func() -> void:
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
