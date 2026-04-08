class_name BossAttackState
extends "res://scripts/state_machines/enemy/enemy_attack_state.gd"
## Corrupted Compiler boss attack — phase-aware multi-pattern attacks.

const COMPILE_ERROR_TELEGRAPH: float = 0.8
const COMPILE_ERROR_DAMAGE: float = 20.0
const COMPILE_ERROR_DURATION: float = 1.2
const OVERFLOW_PROJECTILE_COUNT: int = 3
const STACK_OVERFLOW_TELEGRAPH: float = 1.5
const STACK_OVERFLOW_DAMAGE: float = 50.0

var _attack_count: int = 0
var _spawn_timer: float = 0.0


func _init() -> void:
	base_damage = 20.0
	attack_cooldown = 0.5


func enter() -> void:
	var boss = player
	if boss.is_transitioning:
		state_machine.transition_to(state_machine.get_node("EnemyChaseState") as Node)
		return

	_timer = 0.0
	_hitbox_enabled = false
	_attack_count += 1

	# Face player
	if boss.target_player:
		var dir: Vector3 = (boss.target_player.global_position - boss.global_position).normalized()
		dir.y = 0.0
		if dir.length() > 0.1:
			boss.model.rotation.y = atan2(dir.x, dir.z)

	boss.velocity = Vector3.ZERO

	# Select attack based on phase and pattern
	var phase: int = boss.current_phase
	if phase >= 3 and _attack_count % 8 == 0:
		_do_stack_overflow(boss)
	elif phase >= 2 and _attack_count % 3 == 0:
		_do_memory_overflow(boss)
	else:
		_do_compile_error(boss)


func _do_compile_error(boss: CharacterBody3D) -> void:
	# Telegraph
	boss.hitbox_component.set_meta(&"base_damage", COMPILE_ERROR_DAMAGE)
	boss.hitbox_component.set_meta(&"damage_type", &"physical")

	# Apply status in later phases
	if boss.current_phase >= 3:
		boss.set_meta(&"apply_fragmented", true)
	elif boss.current_phase >= 2:
		boss.set_meta(&"apply_corrupted", true)

	if boss.animation_player.has_animation(&"attack"):
		boss.animation_player.play(&"attack")

	# Speed modifier for phase 2+
	var speed_mult: float = 1.2 if boss.current_phase >= 2 else 1.0
	var telegraph: float = COMPILE_ERROR_TELEGRAPH / speed_mult

	# Ground AoE telegraph indicator
	if boss.is_inside_tree() and boss.target_player:
		var attack_dir: Vector3 = (boss.target_player.global_position - boss.global_position).normalized()
		attack_dir.y = 0.0
		AttackTelegraph.show_circle(
			boss.global_position + attack_dir * 1.5,
			boss.attack_range * 0.8,
			telegraph,
			boss.get_tree().current_scene
		)

	await boss.get_tree().create_timer(telegraph).timeout
	if not is_instance_valid(boss) or boss.is_transitioning:
		return

	boss.hitbox_component.activate()
	await boss.get_tree().create_timer(0.3).timeout
	if is_instance_valid(boss):
		boss.hitbox_component.deactivate()
		boss.remove_meta(&"apply_fragmented")
		boss.remove_meta(&"apply_corrupted")

	await boss.get_tree().create_timer(0.5).timeout
	if is_instance_valid(boss) and not boss.is_transitioning:
		state_machine.transition_to(state_machine.get_node("EnemyChaseState") as Node)


func _do_memory_overflow(boss: CharacterBody3D) -> void:
	if boss.target_player == null:
		state_machine.transition_to(state_machine.get_node("EnemyChaseState") as Node)
		return

	var base_dir: Vector3 = (boss.target_player.global_position - boss.global_position).normalized()
	base_dir.y = 0.0

	for i: int in OVERFLOW_PROJECTILE_COUNT:
		var angle_offset: float = (float(i) - 1.0) * 0.3
		var dir: Vector3 = base_dir.rotated(Vector3.UP, angle_offset)
		var projectile: Node = load("res://scenes/entities/enemies/memory_leak/leak_projectile.gd").new()
		projectile.source_node = boss
		projectile.base_damage = 15.0
		projectile.direction = dir
		# Collision shape
		var shape: CollisionShape3D = CollisionShape3D.new()
		var sphere: SphereShape3D = SphereShape3D.new()
		sphere.radius = 0.4
		shape.shape = sphere
		projectile.add_child(shape)
		boss.get_tree().current_scene.add_child(projectile)
		projectile.global_position = boss.global_position + Vector3(0, 0.5, 0)

	await boss.get_tree().create_timer(1.0).timeout
	if is_instance_valid(boss) and not boss.is_transitioning:
		state_machine.transition_to(state_machine.get_node("EnemyChaseState") as Node)


func _do_stack_overflow(boss: CharacterBody3D) -> void:
	# Arena-wide telegraph — flash warning
	# Safe zone in a random corner
	var corners: Array[Vector3] = [
		Vector3(-10, 0, -10), Vector3(10, 0, -10),
		Vector3(-10, 0, 10), Vector3(10, 0, 10)
	]
	var safe_corner: Vector3 = corners[randi() % corners.size()]

	# Create visual indicator (placeholder green zone)
	var safe_zone: MeshInstance3D = MeshInstance3D.new()
	var plane: PlaneMesh = PlaneMesh.new()
	plane.size = Vector2(6, 6)
	safe_zone.mesh = plane
	var mat: StandardMaterial3D = StandardMaterial3D.new()
	mat.albedo_color = Color(0.2, 1.0, 0.2, 0.5)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	safe_zone.material_override = mat
	boss.get_tree().current_scene.add_child(safe_zone)
	safe_zone.global_position = safe_corner + Vector3(0, 0.05, 0)

	await boss.get_tree().create_timer(STACK_OVERFLOW_TELEGRAPH).timeout
	if not is_instance_valid(boss):
		safe_zone.queue_free()
		return

	# Deal damage to player if not in safe zone
	var nodes: Array[Node] = boss.get_tree().get_nodes_in_group(&"player")
	if nodes.size() > 0:
		var p: CharacterBody3D = nodes[0] as CharacterBody3D
		if p.global_position.distance_to(safe_corner) > 4.0:
			p.health_component.take_damage(STACK_OVERFLOW_DAMAGE)
			if p.has_meta(&"damage_source_position") == false:
				p.set_meta(&"damage_source_position", boss.global_position)
			var hurt: Node = p.state_machine.get_node_or_null("HurtState") as Node
			if hurt and not p.health_component.is_dead:
				p.state_machine.force_transition_to(hurt)

	safe_zone.queue_free()

	await boss.get_tree().create_timer(0.5).timeout
	if is_instance_valid(boss) and not boss.is_transitioning:
		state_machine.transition_to(state_machine.get_node("EnemyChaseState") as Node)


func physics_update(delta: float) -> void:
	# Spawn Glitch Bugs periodically in phase 1+
	var boss = player
	_spawn_timer += delta
	if _spawn_timer >= 15.0:
		_spawn_timer = 0.0
		for i: int in 3:
			var enemy: CharacterBody3D = EnemyPool.get_enemy("glitch_bug")
			if enemy:
				enemy.global_position = boss.global_position + Vector3(randf_range(-8, 8), 0, randf_range(-8, 8))
				if enemy.is_in_group(&"enemies"):
					(enemy as CharacterBody3D).spawn_position = enemy.global_position
				enemy.reparent(boss.get_tree().current_scene)
