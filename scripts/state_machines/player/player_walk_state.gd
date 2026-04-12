class_name PlayerWalkState
extends "res://scripts/state_machines/state.gd"
## Player is moving via WASD input.

var _dust_timer: float = 0.0
const DUST_INTERVAL: float = 0.3


func enter() -> void:
	var p = player
	if p and p.animation_player.has_animation(&"walk"):
		p.animation_player.play(&"walk")


func handle_input(event: InputEvent) -> void:
	var p = player
	if event.is_action_pressed(&"dash"):
		if p.can_dash:
			state_machine.transition_to(state_machine.get_node("DashState") as Node)
		else:
			_flash_cooldown(p)
	elif event.is_action_pressed(&"attack_primary"):
		if p.can_attack:
			state_machine.transition_to(state_machine.get_node("AttackState") as Node)
		else:
			_flash_cooldown(p)
	elif event.is_action_pressed(&"attack_secondary"):
		if p.can_attack:
			state_machine.transition_to(state_machine.get_node("ChargeState") as Node)
		else:
			_flash_cooldown(p)


func _flash_cooldown(p: CharacterBody3D) -> void:
	## Brief red flash on highlight ring when ability is on cooldown
	if not p.is_inside_tree():
		return
	var ring: MeshInstance3D = p.get_node_or_null("HighlightRing") as MeshInstance3D
	if ring == null or not is_instance_valid(ring):
		return
	var mat: StandardMaterial3D = ring.material_override as StandardMaterial3D
	if mat == null:
		return
	var original_color: Color = mat.albedo_color
	var tween: Tween = ring.create_tween()
	tween.tween_property(mat, "albedo_color", Color(0.95, 0.3, 0.1, 0.6), 0.05)
	tween.tween_property(mat, "albedo_color", original_color, 0.2)


func physics_update(delta: float) -> void:
	var p = player
	var input_vector: Vector2 = Input.get_vector(
		&"move_left", &"move_right", &"move_forward", &"move_back"
	)

	if input_vector.length() <= 0.0:
		state_machine.transition_to(state_machine.get_node("IdleState") as Node)
		return

	var camera: Camera3D = p.get_viewport().get_camera_3d()
	var camera_basis: Basis = Basis(Vector3.UP, camera.global_rotation.y) if camera else Basis.IDENTITY
	var direction: Vector3 = camera_basis * Vector3(input_vector.x, 0.0, input_vector.y)
	direction = direction.normalized()

	# Phase 3 #22 — throttled status slows the player. The meta is set
	# by StatusEffectManager._on_effect_start when a Glitch Bug lunge
	# connects, and unset on expiry. Multiplying through here keeps
	# the slow concentrated to the moments the player is actively
	# moving — no need to mutate p.move_speed.
	var speed: float = p.move_speed
	if p.has_meta(&"status_throttled"):
		var slow_frac: float = float(p.get_meta(&"status_throttled"))
		speed *= clampf(1.0 - slow_frac, 0.1, 1.0)
	p.velocity = direction * speed
	p.facing_direction = direction

	var target_angle: float = atan2(direction.x, direction.z)
	p.model.rotation.y = lerp_angle(p.model.rotation.y, target_angle, p.turn_speed * delta)

	p.move_and_slide()

	# Footstep dust particles
	_dust_timer += delta
	if _dust_timer >= DUST_INTERVAL:
		_dust_timer = 0.0
		_spawn_footstep_dust(p)


func _spawn_footstep_dust(p: CharacterBody3D) -> void:
	if not p.is_inside_tree():
		return
	var dust: MeshInstance3D = MeshInstance3D.new()
	var sphere: SphereMesh = SphereMesh.new()
	sphere.radius = 0.08
	sphere.height = 0.06
	dust.mesh = sphere
	var mat: StandardMaterial3D = StandardMaterial3D.new()
	# Use floor accent color if in dungeon, otherwise warm dust
	var dust_color: Color = Color(0.6, 0.55, 0.45, 0.4)
	if GameManager.has_meta(&"floor_accent_color"):
		var accent: Color = GameManager.get_meta(&"floor_accent_color") as Color
		dust_color = Color(accent.r * 0.6 + 0.3, accent.g * 0.6 + 0.3, accent.b * 0.6 + 0.3, 0.4)
	mat.albedo_color = dust_color
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.emission_enabled = true
	mat.emission = Color(dust_color.r * 0.5, dust_color.g * 0.5, dust_color.b * 0.5)
	mat.emission_energy_multiplier = 0.6
	dust.material_override = mat
	p.get_tree().current_scene.add_child(dust)
	dust.global_position = p.global_position + Vector3(randf_range(-0.15, 0.15), 0.05, randf_range(-0.15, 0.15))
	var tween: Tween = dust.create_tween()
	tween.tween_property(dust, "position:y", dust.position.y + 0.3, 0.4)
	tween.parallel().tween_property(dust, "scale", Vector3(2, 2, 2), 0.4)
	tween.parallel().tween_property(mat, "albedo_color:a", 0.0, 0.4)
	tween.tween_callback(dust.queue_free)
