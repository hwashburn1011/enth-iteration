class_name EnemyAttackState
extends "res://scripts/state_machines/state.gd"
## Enemy performs an attack, then returns to chase.

const ATTACK_DURATION: float = 0.6
const HITBOX_START: float = 0.2
const HITBOX_END: float = 0.4

@export var base_damage: float = 5.0
@export var attack_cooldown: float = 1.0

var _timer: float = 0.0
var _hitbox_enabled: bool = false


func enter() -> void:
	var enemy = player
	_timer = 0.0
	_hitbox_enabled = false

	# Face the player
	if enemy.target_player:
		var dir: Vector3 = (enemy.target_player.global_position - enemy.global_position).normalized()
		dir.y = 0.0
		if dir.length() > 0.1:
			enemy.model.rotation.y = atan2(dir.x, dir.z)

	enemy.velocity = Vector3.ZERO
	if enemy.animation_player.has_animation(&"attack"):
		enemy.animation_player.play(&"attack")

	enemy.hitbox_component.set_meta(&"base_damage", base_damage)
	enemy.hitbox_component.set_meta(&"damage_type", &"physical")


func physics_update(delta: float) -> void:
	var enemy = player
	_timer += delta

	if _timer >= HITBOX_START and _timer < HITBOX_END:
		if not _hitbox_enabled:
			enemy.hitbox_component.activate()
			_hitbox_enabled = true
	elif _hitbox_enabled:
		enemy.hitbox_component.deactivate()
		_hitbox_enabled = false

	if _timer >= ATTACK_DURATION:
		enemy.hitbox_component.deactivate()
		state_machine.transition_to(state_machine.get_node("EnemyChaseState") as Node)


func exit() -> void:
	var enemy = player
	enemy.hitbox_component.deactivate()
	_hitbox_enabled = false
