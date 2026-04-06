class_name MemoryLeakAttackState
extends EnemyAttackState
## Memory Leak ranged attack — telegraph then fire projectile.

const TELEGRAPH_DURATION: float = 0.5
const ML_ATTACK_DURATION: float = 0.7

var _telegraph_done: bool = false


func _init() -> void:
	base_damage = 12.0
	attack_cooldown = 2.5


func enter() -> void:
	var enemy: EnemyBase = player as EnemyBase
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

	if enemy.animation_player.has_animation(&"attack"):
		enemy.animation_player.play(&"attack")


func physics_update(delta: float) -> void:
	var enemy: EnemyBase = player as EnemyBase
	_timer += delta

	if _timer < TELEGRAPH_DURATION:
		return

	if not _telegraph_done:
		_telegraph_done = true
		_set_glow(enemy, false)
		_fire_projectile(enemy)

	if _timer >= ML_ATTACK_DURATION:
		state_machine.transition_to(state_machine.get_node("EnemyChaseState") as State)


func exit() -> void:
	var enemy: EnemyBase = player as EnemyBase
	_set_glow(enemy, false)


func _fire_projectile(enemy: EnemyBase) -> void:
	if enemy.target_player == null:
		return
	var projectile: LeakProjectile = LeakProjectile.new()
	projectile.source_node = enemy
	projectile.base_damage = base_damage
	projectile.global_position = enemy.global_position + Vector3(0, 0.5, 0)
	var dir: Vector3 = (enemy.target_player.global_position - enemy.global_position).normalized()
	dir.y = 0.0
	projectile.direction = dir

	# Add a collision shape
	var shape: CollisionShape3D = CollisionShape3D.new()
	var sphere: SphereShape3D = SphereShape3D.new()
	sphere.radius = 0.3
	shape.shape = sphere
	projectile.add_child(shape)

	# Placeholder visual
	var mesh: MeshInstance3D = MeshInstance3D.new()
	var sphere_mesh: SphereMesh = SphereMesh.new()
	sphere_mesh.radius = 0.3
	sphere_mesh.height = 0.6
	mesh.mesh = sphere_mesh
	var mat: StandardMaterial3D = StandardMaterial3D.new()
	mat.albedo_color = Color(0.3, 0.9, 0.3, 0.8)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mesh.material_override = mat
	projectile.add_child(mesh)

	enemy.get_tree().current_scene.add_child(projectile)


func _set_glow(enemy: EnemyBase, glow: bool) -> void:
	var mesh: MeshInstance3D = enemy.model.get_child(0) as MeshInstance3D
	if mesh == null:
		return
	if glow:
		var mat: StandardMaterial3D = StandardMaterial3D.new()
		mat.emission_enabled = true
		mat.emission = Color(0.2, 1.0, 0.2)
		mat.emission_energy_multiplier = 1.5
		mesh.material_override = mat
	else:
		mesh.material_override = null
