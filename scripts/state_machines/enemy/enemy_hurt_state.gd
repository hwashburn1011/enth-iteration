class_name EnemyHurtState
extends "res://scripts/state_machines/state.gd"
## Enemy was hit — brief stun with knockback.
##
## Knockback uses an ease-out cubic curve so the enemy gets a strong initial
## pop and a smooth tail, instead of a linear deceleration that feels stiff.
## A small vertical kick adds a subtle "lift" so connecting hits register
## visually even from a top-down isometric angle.

## Phase 3 #31 — beefier flinch. The pre-T31 numbers (0.3s stun, 0.08s
## flash, no body language) made the hit-confirm payoff from gameplay/T2
## (hitstop + camera shake) feel like it landed on a stone wall: the
## player heard the hit, felt the screen shake, and then watched the
## enemy keep marching as if nothing happened. T31 stretches the stun
## window, doubles the flash time, and adds a procedural stagger lean
## + squash on the model so the body language reads "I got hit."
const STUN_DURATION: float = 0.5
const KNOCKBACK_SPEED: float = 8.5
const UPWARD_KICK: float = 2.4
const UPWARD_KICK_GRAVITY: float = 14.0
const FLASH_DURATION: float = 0.16
const STAGGER_LEAN_DEG: float = 14.0
const STAGGER_SQUASH: float = 0.12

var _timer: float = 0.0
var _knockback_dir: Vector3 = Vector3.ZERO
var _vertical_velocity: float = 0.0
var _stagger_baseline_rotation: Vector3 = Vector3.ZERO
var _stagger_baseline_scale: Vector3 = Vector3.ONE
var _stagger_captured: bool = false
var _stagger_tween: Tween = null


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
	# Procedural stagger — lean back from the hit source + squash the
	# model briefly. Reads on every enemy regardless of whether the
	# imported GLB has a "hurt" animation (most R3 sculpts don't).
	_apply_stagger(enemy)


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


func _restore_material(enemy: CharacterBody3D) -> void:
	if _flashed:
		_flashed = false
		for i: int in _flashed_meshes.size():
			var m: MeshInstance3D = _flashed_meshes[i]
			if is_instance_valid(m):
				m.material_override = _original_mats[i] if i < _original_mats.size() else null
	# Reset the stagger pose so the next state inherits the model upright.
	# We don't tween the recovery — at this point the player has already
	# moved on visually and we want the state machine to hand off cleanly.
	if _stagger_captured and is_instance_valid(enemy) and enemy.model != null:
		if _stagger_tween and _stagger_tween.is_valid():
			_stagger_tween.kill()
		_stagger_tween = null
		enemy.model.rotation = _stagger_baseline_rotation
		enemy.model.scale = _stagger_baseline_scale
		_stagger_captured = false


func _apply_stagger(enemy: CharacterBody3D) -> void:
	## Procedural body language: lean back from the hit source, squash
	## the model briefly, then ease back. The squash + lean tween runs
	## independently of the state machine timer so it survives a quick
	## hurt → chase handoff. Killed in _restore_material on exit so the
	## model never gets stuck mid-stagger.
	if enemy.model == null:
		return
	# Snapshot baseline once per enter — we're still mutating it from
	# the previous baseline if the enemy is hit again before the state
	# exits, which is the desired "stack the lean further back" feel.
	if not _stagger_captured:
		_stagger_baseline_rotation = enemy.model.rotation
		_stagger_baseline_scale = enemy.model.scale
		_stagger_captured = true
	# Lean back along the knockback direction. The lean axis is
	# perpendicular to knockback (so the model tilts AWAY from the hit)
	# and clamped to a small angle so heavy enemies don't snap.
	var lean_angle: float = deg_to_rad(STAGGER_LEAN_DEG)
	var lean_target: Vector3 = _stagger_baseline_rotation
	if _knockback_dir.length() > 0.01:
		# Tilt forward in world XZ — rotate model.x by lean_angle in the
		# direction of knockback so the body folds backward away from
		# the player who just hit it.
		lean_target.x = _stagger_baseline_rotation.x + lean_angle * sign(_knockback_dir.z)
		lean_target.z = _stagger_baseline_rotation.z - lean_angle * sign(_knockback_dir.x)
	# Vertical squash + lateral pinch — quick pop, then recover.
	var squash_scale: Vector3 = Vector3(
		_stagger_baseline_scale.x * (1.0 + STAGGER_SQUASH * 0.5),
		_stagger_baseline_scale.y * (1.0 - STAGGER_SQUASH),
		_stagger_baseline_scale.z * (1.0 + STAGGER_SQUASH * 0.5)
	)
	if _stagger_tween and _stagger_tween.is_valid():
		_stagger_tween.kill()
	_stagger_tween = enemy.model.create_tween()
	_stagger_tween.tween_property(enemy.model, "rotation", lean_target, 0.10).set_ease(Tween.EASE_OUT)
	_stagger_tween.parallel().tween_property(enemy.model, "scale", squash_scale, 0.10).set_ease(Tween.EASE_OUT)
	_stagger_tween.tween_property(enemy.model, "rotation", _stagger_baseline_rotation, STUN_DURATION - 0.12).set_ease(Tween.EASE_IN_OUT)
	_stagger_tween.parallel().tween_property(enemy.model, "scale", _stagger_baseline_scale, STUN_DURATION - 0.12).set_ease(Tween.EASE_IN_OUT)
