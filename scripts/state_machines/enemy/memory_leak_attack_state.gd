class_name MemoryLeakAttackState
extends "res://scripts/state_machines/enemy/enemy_attack_state.gd"
## Memory Leak ranged attack — telegraph then fire projectile.

const TELEGRAPH_DURATION: float = 0.5
const ML_ATTACK_DURATION: float = 0.7

var _telegraph_done: bool = false


func _init() -> void:
	base_damage = 12.0
	attack_cooldown = 2.5


func enter() -> void:
	var enemy = player
	_timer = 0.0
	_hitbox_enabled = false
	_telegraph_done = false

	# Face the player
	if enemy.target_player:
		var dir: Vector3 = (enemy.target_player.global_position - enemy.global_position).normalized()
		dir.y = 0.0
		if dir.length() > 0.1:
			enemy.model.rotation.y = atan2(dir.x, dir.z)

	enemy.velocity = Vector3.ZERO
	_set_glow(enemy, true)

	# Ground line telegraph showing projectile path
	if enemy.is_inside_tree() and enemy.target_player:
		var attack_dir: Vector3 = (enemy.target_player.global_position - enemy.global_position).normalized()
		attack_dir.y = 0.0
		if attack_dir.length() > 0.1:
			AttackTelegraph.show_line(
				enemy.global_position,
				attack_dir,
				6.0,  # projectile range
				0.6,  # narrow line
				TELEGRAPH_DURATION,
				enemy.get_tree().current_scene
			)

	if enemy.animation_player.has_animation(&"attack"):
		enemy.animation_player.play(&"attack")


func physics_update(delta: float) -> void:
	var enemy = player
	_timer += delta

	if _timer < TELEGRAPH_DURATION:
		return

	if not _telegraph_done:
		_telegraph_done = true
		_set_glow(enemy, false)
		_fire_projectile(enemy)

	if _timer >= ML_ATTACK_DURATION:
		state_machine.transition_to(state_machine.get_node("EnemyChaseState") as Node)


func exit() -> void:
	var enemy = player
	_set_glow(enemy, false)
	enemy.attack_cooldown_remaining = attack_cooldown


func _fire_projectile(enemy: CharacterBody3D) -> void:
	if enemy.target_player == null:
		return
	var projectile: Node = load("res://scenes/entities/enemies/memory_leak/leak_projectile.gd").new()
	projectile.source_node = enemy
	projectile.base_damage = base_damage
	var dir: Vector3 = (enemy.target_player.global_position - enemy.global_position).normalized()
	dir.y = 0.0
	projectile.direction = dir

	# Add a collision shape
	var shape: CollisionShape3D = CollisionShape3D.new()
	var sphere: SphereShape3D = SphereShape3D.new()
	sphere.radius = 0.3
	shape.shape = sphere
	projectile.add_child(shape)

	# Glowing projectile visual
	var mesh: MeshInstance3D = MeshInstance3D.new()
	var sphere_mesh: SphereMesh = SphereMesh.new()
	sphere_mesh.radius = 0.25
	sphere_mesh.height = 0.5
	mesh.mesh = sphere_mesh
	var mat: StandardMaterial3D = StandardMaterial3D.new()
	mat.albedo_color = Color(0.25, 0.85, 0.3, 0.85)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.emission_enabled = true
	mat.emission = Color(0.2, 0.7, 0.25)
	mat.emission_energy_multiplier = 2.0
	mesh.material_override = mat
	projectile.add_child(mesh)
	# Trail particles
	var trail: GPUParticles3D = GPUParticles3D.new()
	trail.amount = 8
	trail.lifetime = 0.4
	var trail_mat: ParticleProcessMaterial = ParticleProcessMaterial.new()
	trail_mat.direction = Vector3(-dir.x, 0, -dir.z)
	trail_mat.spread = 15.0
	trail_mat.initial_velocity_min = 1.0
	trail_mat.initial_velocity_max = 2.0
	trail_mat.gravity = Vector3(0, -1, 0)
	trail_mat.color = Color(0.2, 0.7, 0.25, 0.5)
	trail_mat.scale_min = 0.3
	trail_mat.scale_max = 0.6
	trail.process_material = trail_mat
	var trail_mesh: SphereMesh = SphereMesh.new()
	trail_mesh.radius = 0.05
	trail_mesh.height = 0.1
	trail.draw_pass_1 = trail_mesh
	var trail_vis: StandardMaterial3D = StandardMaterial3D.new()
	trail_vis.albedo_color = Color(0.2, 0.7, 0.25, 0.4)
	trail_vis.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	trail_vis.emission_enabled = true
	trail_vis.emission = Color(0.15, 0.55, 0.2)
	trail_vis.emission_energy_multiplier = 1.5
	trail_vis.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	trail.material_override = trail_vis
	projectile.add_child(trail)

	# Add to tree FIRST, then set position
	enemy.get_tree().current_scene.add_child(projectile)
	projectile.global_position = enemy.global_position + Vector3(0, 0.5, 0)
	# Muzzle flash at enemy
	_spawn_muzzle_flash(enemy)
	# Track projectile on enemy for cleanup when pooled
	if not enemy.has_meta(&"active_projectiles"):
		enemy.set_meta(&"active_projectiles", [])
	(enemy.get_meta(&"active_projectiles") as Array).append(projectile)


func _spawn_muzzle_flash(enemy: CharacterBody3D) -> void:
	if not enemy.is_inside_tree():
		return
	# Bright green flash sphere at projectile spawn point
	var flash: MeshInstance3D = MeshInstance3D.new()
	var sphere: SphereMesh = SphereMesh.new()
	sphere.radius = 0.3
	sphere.height = 0.6
	flash.mesh = sphere
	var mat: StandardMaterial3D = StandardMaterial3D.new()
	mat.albedo_color = Color(0.3, 1.0, 0.4, 0.8)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.emission_enabled = true
	mat.emission = Color(0.25, 0.95, 0.35)
	mat.emission_energy_multiplier = 4.0
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	flash.material_override = mat
	enemy.get_tree().current_scene.add_child(flash)
	flash.global_position = enemy.global_position + Vector3(0, 0.5, 0)
	var tween: Tween = flash.create_tween()
	tween.tween_property(flash, "scale", Vector3(2.0, 2.0, 2.0), 0.15)
	tween.parallel().tween_property(mat, "albedo_color:a", 0.0, 0.18)
	tween.tween_callback(flash.queue_free)


func _set_glow(enemy: CharacterBody3D, glow: bool) -> void:
	var meshes: Array[MeshInstance3D] = enemy.get_mesh_instances()
	if glow:
		var mat: StandardMaterial3D = StandardMaterial3D.new()
		mat.emission_enabled = true
		mat.emission = Color(0.2, 1.0, 0.2)
		mat.emission_energy_multiplier = 1.5
		for mesh: MeshInstance3D in meshes:
			mesh.material_override = mat
	else:
		for mesh: MeshInstance3D in meshes:
			mesh.material_override = null
