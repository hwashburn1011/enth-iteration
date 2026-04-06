class_name RogueProcessAttackState
extends EnemyAttackState
## Alternates between dash strike and flurry attacks.

enum AttackPattern { DASH_STRIKE, FLURRY }

const DASH_TELEGRAPH: float = 0.4
const DASH_DISTANCE: float = 3.0
const DASH_DAMAGE: float = 10.0
const DASH_DURATION: float = 0.6

const FLURRY_TELEGRAPH: float = 0.3
const FLURRY_STRIKE_INTERVAL: float = 0.33
const FLURRY_DAMAGE: float = 5.0
const FLURRY_DURATION: float = 1.3  # 0.3 telegraph + 3 strikes over 1.0s
const FLURRY_STRIKES: int = 3

var _current_pattern: AttackPattern = AttackPattern.DASH_STRIKE
var _telegraph_done: bool = false
var _strike_count: int = 0
var _next_strike_time: float = 0.0
var _attack_dir: Vector3 = Vector3.ZERO


func _init() -> void:
	base_damage = 10.0
	attack_cooldown = 1.0


func enter() -> void:
	var enemy: EnemyBase = player as EnemyBase
	_timer = 0.0
	_hitbox_enabled = false
	_telegraph_done = false
	_strike_count = 0

	# Alternate pattern
	_current_pattern = AttackPattern.FLURRY if _current_pattern == AttackPattern.DASH_STRIKE else AttackPattern.DASH_STRIKE

	# Adjust cooldown if enraged
	if enemy is RogueProcess and (enemy as RogueProcess).is_enraged:
		attack_cooldown = 0.7

	# Face the player
	if enemy.target_player:
		_attack_dir = (enemy.target_player.global_position - enemy.global_position).normalized()
		_attack_dir.y = 0.0
		if _attack_dir.length() > 0.1:
			enemy.model.rotation.y = atan2(_attack_dir.x, _attack_dir.z)

	enemy.velocity = Vector3.ZERO
	_set_telegraph(enemy, true)

	enemy.hitbox_component.set_meta(&"damage_type", &"physical")

	if enemy.animation_player.has_animation(&"attack"):
		enemy.animation_player.play(&"attack")


func physics_update(delta: float) -> void:
	var enemy: EnemyBase = player as EnemyBase
	_timer += delta

	var telegraph_time: float = DASH_TELEGRAPH if _current_pattern == AttackPattern.DASH_STRIKE else FLURRY_TELEGRAPH

	# Telegraph phase
	if _timer < telegraph_time:
		enemy.velocity = Vector3.ZERO
		enemy.move_and_slide()
		return

	if not _telegraph_done:
		_telegraph_done = true
		_set_telegraph(enemy, false)
		if _current_pattern == AttackPattern.FLURRY:
			_next_strike_time = telegraph_time

	match _current_pattern:
		AttackPattern.DASH_STRIKE:
			_process_dash_strike(enemy, delta)
		AttackPattern.FLURRY:
			_process_flurry(enemy, delta)


func _process_dash_strike(enemy: EnemyBase, _delta: float) -> void:
	var action_time: float = _timer - DASH_TELEGRAPH

	# Teleport on first frame after telegraph
	if action_time < 0.1 and not _hitbox_enabled:
		# Dash teleport
		enemy.global_position += _attack_dir * DASH_DISTANCE
		enemy.hitbox_component.set_meta(&"base_damage", DASH_DAMAGE)
		enemy.hitbox_component.activate()
		_hitbox_enabled = true

	if action_time >= 0.2 and _hitbox_enabled:
		enemy.hitbox_component.deactivate()
		_hitbox_enabled = false

	if _timer >= DASH_DURATION:
		enemy.hitbox_component.deactivate()
		state_machine.transition_to(state_machine.get_node("EnemyChaseState") as State)

	enemy.velocity = Vector3.ZERO
	enemy.move_and_slide()


func _process_flurry(enemy: EnemyBase, _delta: float) -> void:
	if _strike_count < FLURRY_STRIKES and _timer >= _next_strike_time:
		_strike_count += 1
		_next_strike_time = _timer + FLURRY_STRIKE_INTERVAL
		enemy.hitbox_component.set_meta(&"base_damage", FLURRY_DAMAGE)
		enemy.hitbox_component.activate()
		# Brief hitbox window
		await enemy.get_tree().create_timer(0.1).timeout
		enemy.hitbox_component.deactivate()

	if _timer >= FLURRY_DURATION:
		enemy.hitbox_component.deactivate()
		state_machine.transition_to(state_machine.get_node("EnemyChaseState") as State)

	enemy.velocity = Vector3.ZERO
	enemy.move_and_slide()


func exit() -> void:
	var enemy: EnemyBase = player as EnemyBase
	enemy.hitbox_component.deactivate()
	_hitbox_enabled = false
	_set_telegraph(enemy, false)


func _set_telegraph(enemy: EnemyBase, active: bool) -> void:
	var mesh: MeshInstance3D = enemy.model.get_child(0) as MeshInstance3D
	if mesh == null:
		return
	if active:
		var mat: StandardMaterial3D = StandardMaterial3D.new()
		mat.albedo_color = Color(0.5, 0.5, 1.0)
		mat.emission_enabled = true
		mat.emission = Color(0.3, 0.3, 1.0)
		mat.emission_energy_multiplier = 1.5
		mesh.material_override = mat
	else:
		# Restore enraged glow or clear
		if enemy is RogueProcess and (enemy as RogueProcess).is_enraged:
			var mat: StandardMaterial3D = StandardMaterial3D.new()
			mat.albedo_color = Color(0.3, 0.3, 1.0)
			mat.emission_enabled = true
			mat.emission = Color(0.2, 0.2, 1.0)
			mat.emission_energy_multiplier = 2.0
			mesh.material_override = mat
		else:
			mesh.material_override = null
