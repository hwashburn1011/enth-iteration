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


var _original_mat: Material = null
var _flashed: bool = false


func _flash_white(enemy: CharacterBody3D) -> void:
	var mesh: MeshInstance3D = enemy.model.get_child(0) as MeshInstance3D
	if mesh == null:
		return
	_original_mat = mesh.material_override
	_flashed = true
	var flash_mat: StandardMaterial3D = StandardMaterial3D.new()
	flash_mat.albedo_color = Color(1, 1, 1)
	flash_mat.emission_enabled = true
	flash_mat.emission = Color(1, 1, 1)
	flash_mat.emission_energy_multiplier = 2.0
	mesh.material_override = flash_mat
	# Restore after 0.08s
	if enemy.is_inside_tree():
		enemy.get_tree().create_timer(0.08).timeout.connect(func() -> void:
			if is_instance_valid(mesh):
				mesh.material_override = _original_mat
		)


func _restore_material(enemy: CharacterBody3D) -> void:
	if not _flashed:
		return
	_flashed = false
	var mesh: MeshInstance3D = enemy.model.get_child(0) as MeshInstance3D
	if mesh and is_instance_valid(mesh):
		mesh.material_override = _original_mat
