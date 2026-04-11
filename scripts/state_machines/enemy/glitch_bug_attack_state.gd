class_name GlitchBugAttackState
extends "res://scripts/state_machines/enemy/enemy_attack_state.gd"
## Glitch Bug lunge attack with 0.3s telegraph (red flash), 0.2s hitbox window.

const TELEGRAPH_DURATION: float = 0.3
const GB_ATTACK_DURATION: float = 0.6
const GB_HITBOX_START: float = 0.3
const GB_HITBOX_END: float = 0.5
const LUNGE_SPEED: float = 10.0

var _telegraph_done: bool = false
var _lunge_dir: Vector3 = Vector3.ZERO


func _init() -> void:
	base_damage = 8.0
	attack_cooldown = 1.5


func enter() -> void:
	var enemy = player
	_timer = 0.0
	_hitbox_enabled = false
	_telegraph_done = false

	# Face the player
	if enemy.target_player:
		_lunge_dir = (enemy.target_player.global_position - enemy.global_position).normalized()
		_lunge_dir.y = 0.0
		if _lunge_dir.length() > 0.1:
			enemy.model.rotation.y = atan2(_lunge_dir.x, _lunge_dir.z)

	enemy.velocity = Vector3.ZERO
	enemy.hitbox_component.set_meta(&"base_damage", base_damage)
	enemy.hitbox_component.set_meta(&"damage_type", &"physical")

	# Start telegraph — red flash
	_set_telegraph_flash(enemy, true)

	# Ground telegraph: line indicator for lunge direction
	if enemy.is_inside_tree() and _lunge_dir.length() > 0.1:
		AttackTelegraph.show_line(
			enemy.global_position,
			_lunge_dir,
			3.0,  # lunge distance
			1.0,  # width
			TELEGRAPH_DURATION,
			enemy.get_tree().current_scene
		)

	if enemy.animation_player.has_animation(&"attack"):
		enemy.animation_player.play(&"attack")


func physics_update(delta: float) -> void:
	var enemy = player
	_timer += delta

	# Telegraph phase
	if _timer < TELEGRAPH_DURATION:
		enemy.velocity = Vector3.ZERO
		enemy.move_and_slide()
		return

	if not _telegraph_done:
		_telegraph_done = true
		_set_telegraph_flash(enemy, false)

	# Lunge movement
	if _timer < GB_HITBOX_END:
		enemy.velocity = _lunge_dir * LUNGE_SPEED
	else:
		enemy.velocity = Vector3.ZERO
	enemy.move_and_slide()

	# Hitbox window
	if _timer >= GB_HITBOX_START and _timer < GB_HITBOX_END:
		if not _hitbox_enabled:
			enemy.hitbox_component.activate()
			_hitbox_enabled = true
	elif _hitbox_enabled:
		enemy.hitbox_component.deactivate()
		_hitbox_enabled = false

	if _timer >= GB_ATTACK_DURATION:
		enemy.hitbox_component.deactivate()
		state_machine.transition_to(state_machine.get_node("EnemyChaseState") as Node)


func exit() -> void:
	var enemy = player
	enemy.hitbox_component.deactivate()
	_hitbox_enabled = false
	_set_telegraph_flash(enemy, false)
	enemy.attack_cooldown_remaining = attack_cooldown


func _set_telegraph_flash(enemy: CharacterBody3D, flash: bool) -> void:
	var meshes: Array[MeshInstance3D] = enemy.get_mesh_instances()
	if flash:
		var mat: StandardMaterial3D = StandardMaterial3D.new()
		mat.albedo_color = Color(1.0, 0.2, 0.2)
		mat.emission_enabled = true
		mat.emission = Color(1.0, 0.0, 0.0)
		mat.emission_energy_multiplier = 2.0
		for mesh: MeshInstance3D in meshes:
			mesh.material_override = mat
	else:
		for mesh: MeshInstance3D in meshes:
			mesh.material_override = null
