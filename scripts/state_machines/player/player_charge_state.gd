class_name PlayerChargeState
extends "res://scripts/state_machines/state.gd"
## Charges Energy Burst while right mouse button is held.

const MAX_CHARGE_TIME: float = 2.0
const MOVE_SPEED_MULTIPLIER: float = 0.5

var charge_time: float = 0.0
var _original_move_speed: float = 0.0


func enter() -> void:
	var p = player
	charge_time = 0.0
	_original_move_speed = p.move_speed
	p.move_speed *= MOVE_SPEED_MULTIPLIER
	_set_emission(p, 0.0)

	if p.animation_player.has_animation(&"charge"):
		p.animation_player.play(&"charge")


func exit() -> void:
	var p = player
	p.move_speed = _original_move_speed
	_set_emission(p, 0.0)


func handle_input(event: InputEvent) -> void:
	if event.is_action_released(&"attack_secondary"):
		_release_burst()


func physics_update(delta: float) -> void:
	var p = player
	charge_time = minf(charge_time + delta, MAX_CHARGE_TIME)

	# Visual charge indicator — emission intensity
	var charge_pct: float = charge_time / MAX_CHARGE_TIME
	_set_emission(p, charge_pct)

	# Allow reduced-speed movement while charging
	var input_vector: Vector2 = Input.get_vector(
		&"move_left", &"move_right", &"move_forward", &"move_back"
	)
	if input_vector.length() > 0.0:
		var camera: Camera3D = p.get_viewport().get_camera_3d()
		var camera_basis: Basis = Basis(Vector3.UP, camera.global_rotation.y) if camera else Basis.IDENTITY
		var direction: Vector3 = camera_basis * Vector3(input_vector.x, 0.0, input_vector.y)
		direction = direction.normalized()
		p.velocity = direction * p.move_speed
	else:
		p.velocity = p.velocity.lerp(Vector3.ZERO, p.friction)
	p.move_and_slide()


func _release_burst() -> void:
	var p = player
	var charge_multiplier: float = lerpf(0.5, 2.0, charge_time / MAX_CHARGE_TIME)
	var compute_cost: float = 15.0 * charge_multiplier

	if not p.compute_component.spend(compute_cost):
		# Fizzle — not enough compute
		p.move_speed = _original_move_speed
		_set_emission(p, 0.0)
		var input_vector: Vector2 = Input.get_vector(
			&"move_left", &"move_right", &"move_forward", &"move_back"
		)
		if input_vector.length() > 0.0:
			state_machine.transition_to(state_machine.get_node("WalkState") as Node)
		else:
			state_machine.transition_to(state_machine.get_node("IdleState") as Node)
		return

	# Store charge data on player for AttackState to use
	p.set_meta(&"energy_burst_charge_multiplier", charge_multiplier)
	p.set_meta(&"energy_burst_damage", (10.0 + p.stats_component.get_stat("processing") * 3.0) * charge_multiplier)

	# Transition to AttackState for the burst release
	var attack_state: Node = state_machine.get_node("AttackState") as Node
	p.set_meta(&"attack_type", &"energy_burst")
	state_machine.transition_to(attack_state)


func _set_emission(p: CharacterBody3D, intensity: float) -> void:
	var mesh: MeshInstance3D = p.model.get_child(0) as MeshInstance3D
	if mesh == null:
		return
	if intensity > 0.0:
		var mat: StandardMaterial3D = StandardMaterial3D.new()
		mat.emission_enabled = true
		mat.emission = Color(0.4, 0.7, 1.0)
		mat.emission_energy_multiplier = intensity
		mesh.material_override = mat
	else:
		mesh.material_override = null
