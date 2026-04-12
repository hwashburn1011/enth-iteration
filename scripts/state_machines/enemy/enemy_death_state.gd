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

	# Brief micro-hitstop on death for impact
	Engine.time_scale = 0.4
	if enemy.is_inside_tree():
		enemy.get_tree().create_timer(0.04, true, false, true).timeout.connect(func() -> void:
			Engine.time_scale = 1.0
		)

	# Drop loot before emitting defeat
	if enemy.loot_dropper:
		enemy.loot_dropper.drop_loot(enemy.global_position)

	# Prefer the stable enemy_type id (snake_case) over the node name
	# (PascalCase, sometimes numbered like GlitchBug2). LevelComponent's
	# XP table and QuestManager objective filters both key on enemy_type;
	# emitting the node name silently broke both — every kill returned
	# XP_REWARD_DEFAULT regardless of enemy class.
	var type_id: StringName = enemy.enemy_type if enemy.enemy_type != &"" else StringName(enemy.name)
	EventBus.enemy_defeated.emit(
		type_id,
		enemy.global_position,
		enemy.loot_dropper.loot_table if enemy.loot_dropper else null
	)

	# Wait for death animation then return to pool
	if enemy.animation_player.has_animation(&"death"):
		await enemy.animation_player.animation_finished
	# Guard: scene change may have freed the enemy during the await
	if not is_instance_valid(enemy):
		return
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

	var scene_root: Node = enemy.get_tree().current_scene
	var pos: Vector3 = enemy.global_position + Vector3(0, 0.5, 0)

	# Primary pixel scatter burst (square particles for digital aesthetic)
	var particles: GPUParticles3D = GPUParticles3D.new()
	particles.amount = 30
	particles.lifetime = 0.8
	particles.one_shot = true
	particles.emitting = true

	var mat: ParticleProcessMaterial = ParticleProcessMaterial.new()
	mat.direction = Vector3(0, 1, 0)
	mat.spread = 180.0
	mat.initial_velocity_min = 2.5
	mat.initial_velocity_max = 5.0
	mat.gravity = Vector3(0, -4, 0)
	mat.color = burst_color
	mat.scale_min = 0.4
	mat.scale_max = 1.5
	mat.damping_min = 1.0
	mat.damping_max = 2.0
	particles.process_material = mat

	var mesh: BoxMesh = BoxMesh.new()
	mesh.size = Vector3(0.06, 0.06, 0.06)
	particles.draw_pass_1 = mesh

	var vis_mat: StandardMaterial3D = StandardMaterial3D.new()
	vis_mat.albedo_color = burst_color
	vis_mat.emission_enabled = true
	vis_mat.emission = burst_color
	vis_mat.emission_energy_multiplier = 2.5
	vis_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	particles.material_override = vis_mat
	scene_root.add_child(particles)
	particles.global_position = pos

	# Secondary: small white spark ring for impact flash
	var flash_ring: MeshInstance3D = MeshInstance3D.new()
	var torus: TorusMesh = TorusMesh.new()
	torus.inner_radius = 0.2
	torus.outer_radius = 0.4
	torus.rings = 8
	torus.ring_segments = 12
	flash_ring.mesh = torus
	var ring_mat: StandardMaterial3D = StandardMaterial3D.new()
	ring_mat.albedo_color = Color(burst_color.r * 0.5 + 0.5, burst_color.g * 0.5 + 0.5, burst_color.b * 0.5 + 0.5, 0.7)
	ring_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	ring_mat.emission_enabled = true
	ring_mat.emission = burst_color.lightened(0.3)
	ring_mat.emission_energy_multiplier = 2.0
	ring_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	flash_ring.material_override = ring_mat
	scene_root.add_child(flash_ring)
	flash_ring.global_position = pos
	var ring_tween: Tween = flash_ring.create_tween()
	ring_tween.tween_property(flash_ring, "scale", Vector3(3, 3, 3), 0.25)
	ring_tween.parallel().tween_property(ring_mat, "albedo_color:a", 0.0, 0.25)
	ring_tween.tween_callback(flash_ring.queue_free)

	# Trigger dissolve + data fragments on the model
	VFXFactory.spawn_death_dissolve(enemy.model)

	# Auto-cleanup particles
	enemy.get_tree().create_timer(1.5).timeout.connect(particles.queue_free)
