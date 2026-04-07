class_name EnemyDeathState
extends "res://scripts/state_machines/state.gd"
## Enemy dies — play animation, emit event, queue_free.

func _ready() -> void:
	can_be_interrupted = false


func enter() -> void:
	var enemy = player

	if enemy.animation_player.has_animation(&"death"):
		enemy.animation_player.play(&"death")

	# Disable collision and processing
	enemy.collision_layer = 0
	enemy.collision_mask = 0
	enemy.set_physics_process(false)
	enemy.hitbox_component.deactivate()

	# Death burst VFX
	_spawn_death_burst(enemy)

	# Drop loot before emitting defeat
	if enemy.loot_dropper:
		enemy.loot_dropper.drop_loot(enemy.global_position)

	EventBus.enemy_defeated.emit(
		StringName(enemy.name),
		enemy.global_position,
		enemy.loot_dropper.loot_table if enemy.loot_dropper else null
	)

	# Wait for death animation then return to pool
	if enemy.animation_player.has_animation(&"death"):
		await enemy.animation_player.animation_finished
	EnemyPool.return_enemy(enemy)


func _spawn_death_burst(enemy: CharacterBody3D) -> void:
	if not enemy.is_inside_tree():
		return
	# Determine color based on enemy type
	var burst_color: Color = Color(0.8, 0.3, 0.2)  # Default red
	var script: Script = enemy.get_script()
	if script:
		var class_name_str: String = script.get_global_name()
		match class_name_str:
			"GlitchBug":
				burst_color = Color(0.9, 0.2, 0.1)
			"MemoryLeak":
				burst_color = Color(0.2, 0.8, 0.3)
			"RogueProcess":
				burst_color = Color(0.2, 0.3, 0.9)
			"CorruptedCompiler":
				burst_color = Color(0.8, 0.1, 0.15)

	var particles: GPUParticles3D = GPUParticles3D.new()
	particles.amount = 20
	particles.lifetime = 0.6
	particles.one_shot = true
	particles.emitting = true
	particles.global_position = enemy.global_position + Vector3(0, 0.5, 0)

	var mat: ParticleProcessMaterial = ParticleProcessMaterial.new()
	mat.direction = Vector3(0, 1, 0)
	mat.spread = 180.0
	mat.initial_velocity_min = 2.0
	mat.initial_velocity_max = 4.0
	mat.gravity = Vector3(0, -3, 0)
	mat.color = burst_color
	mat.scale_min = 0.5
	mat.scale_max = 1.5
	particles.process_material = mat

	var mesh: SphereMesh = SphereMesh.new()
	mesh.radius = 0.05
	mesh.height = 0.1
	particles.draw_pass_1 = mesh

	var vis_mat: StandardMaterial3D = StandardMaterial3D.new()
	vis_mat.albedo_color = burst_color
	vis_mat.emission_enabled = true
	vis_mat.emission = burst_color
	vis_mat.emission_energy_multiplier = 2.0
	vis_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	particles.material_override = vis_mat

	enemy.get_tree().current_scene.add_child(particles)
	# Auto-cleanup
	enemy.get_tree().create_timer(1.0).timeout.connect(particles.queue_free)
