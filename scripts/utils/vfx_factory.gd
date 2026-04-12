class_name VFXFactory
extends RefCounted
## Static factory for common VFX — spawn-and-forget visual effects.


static func spawn_hit_flash(position: Vector3, parent: Node) -> void:
	## Double-pulse white flash burst on hit (0.15s) + spark particles
	var mesh: MeshInstance3D = MeshInstance3D.new()
	var sphere: SphereMesh = SphereMesh.new()
	sphere.radius = 0.3
	sphere.height = 0.6
	mesh.mesh = sphere
	var mat: StandardMaterial3D = StandardMaterial3D.new()
	mat.albedo_color = Color(1, 1, 1, 0.9)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.emission_enabled = true
	mat.emission = Color.WHITE
	mat.emission_energy_multiplier = 3.0
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mesh.material_override = mat
	parent.add_child(mesh)
	mesh.global_position = position
	# Double-pulse: flash→dim→flash→fade
	var tween: Tween = mesh.create_tween()
	tween.tween_property(mat, "albedo_color:a", 1.0, 0.02)
	tween.tween_property(mat, "albedo_color:a", 0.2, 0.03)
	tween.tween_property(mat, "albedo_color:a", 0.9, 0.02)
	tween.tween_property(mesh, "scale", Vector3(1.8, 1.8, 1.8), 0.08)
	tween.parallel().tween_property(mat, "albedo_color:a", 0.0, 0.08)
	tween.tween_callback(mesh.queue_free)
	# Spark particles (10 small cyan/white sparks)
	_spawn_hit_sparks(position, parent)


static func _spawn_hit_sparks(position: Vector3, parent: Node) -> void:
	var particles: GPUParticles3D = GPUParticles3D.new()
	particles.amount = 10
	particles.lifetime = 0.3
	particles.one_shot = true
	particles.emitting = true
	var mat: ParticleProcessMaterial = ParticleProcessMaterial.new()
	mat.direction = Vector3(0, 1, 0)
	mat.spread = 180.0
	mat.initial_velocity_min = 3.0
	mat.initial_velocity_max = 5.0
	mat.gravity = Vector3(0, -6, 0)
	mat.color = Color(0.7, 0.95, 1.0, 0.9)
	mat.scale_min = 0.3
	mat.scale_max = 0.8
	particles.process_material = mat
	var mesh: BoxMesh = BoxMesh.new()
	mesh.size = Vector3(0.03, 0.03, 0.03)
	particles.draw_pass_1 = mesh
	var vis_mat: StandardMaterial3D = StandardMaterial3D.new()
	vis_mat.albedo_color = Color(0.8, 0.95, 1.0)
	vis_mat.emission_enabled = true
	vis_mat.emission = Color(0.6, 0.9, 1.0)
	vis_mat.emission_energy_multiplier = 3.0
	vis_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	particles.material_override = vis_mat
	parent.add_child(particles)
	particles.global_position = position
	parent.get_tree().create_timer(0.6).timeout.connect(particles.queue_free)


static func spawn_energy_burst_ring(position: Vector3, parent: Node) -> void:
	## Expanding ring on Energy Burst release (0.3s)
	var mesh: MeshInstance3D = MeshInstance3D.new()
	var torus: TorusMesh = TorusMesh.new()
	torus.inner_radius = 0.5
	torus.outer_radius = 0.8
	mesh.mesh = torus
	var mat: StandardMaterial3D = StandardMaterial3D.new()
	mat.albedo_color = Color(0.3, 0.6, 1.0, 0.7)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.emission_enabled = true
	mat.emission = Color(0.4, 0.7, 1.0)
	mesh.material_override = mat
	parent.add_child(mesh)
	mesh.global_position = position
	var tween: Tween = mesh.create_tween()
	tween.tween_property(mesh, "scale", Vector3(4, 4, 4), 0.3)
	tween.parallel().tween_property(mat, "albedo_color:a", 0.0, 0.3)
	tween.tween_callback(mesh.queue_free)


static func spawn_death_dissolve(target: Node3D) -> void:
	## Digital dissolve: shrink + pixel scatter + data fragments (1.2s)
	if not target.is_inside_tree():
		return
	var parent: Node = target.get_tree().current_scene
	# Phase 1: Flash white twice (0.1s)
	var tween: Tween = target.create_tween()
	tween.tween_property(target, "scale", target.scale * 1.1, 0.05)
	tween.tween_property(target, "scale", target.scale * 0.95, 0.05)
	# Phase 2: Dissolve + pixel scatter (0.8s)
	tween.tween_property(target, "scale", Vector3(0.01, 0.01, 0.01), 0.8).set_ease(Tween.EASE_IN)
	# Phase 3: Data fragment text particles
	_spawn_data_fragments(target.global_position + Vector3(0, 0.5, 0), parent)


static func _spawn_data_fragments(position: Vector3, parent: Node) -> void:
	## Small drifting text fragments ("0x00", "NULL", "ERR") on death
	var fragments: Array[String] = ["0x00", "NULL", "ERR", "NaN", "0xFF", "VOID"]
	for i: int in 3:
		var label: Label3D = Label3D.new()
		label.text = fragments[randi() % fragments.size()]
		label.font_size = 16
		label.modulate = Color(0.5, 0.8, 1.0, 0.7)
		label.outline_modulate = Color(0, 0, 0, 0.5)
		label.outline_size = 2
		label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		parent.add_child(label)
		label.global_position = position + Vector3(randf_range(-0.3, 0.3), randf_range(0, 0.5), randf_range(-0.3, 0.3))
		var tween: Tween = label.create_tween()
		tween.tween_property(label, "position:y", label.position.y + 1.5, 1.2).set_ease(Tween.EASE_OUT)
		tween.parallel().tween_property(label, "modulate:a", 0.0, 1.2).set_delay(0.4)
		tween.tween_callback(label.queue_free)


static func spawn_item_sparkle(position: Vector3, rarity: int, parent: Node) -> void:
	## Rarity-colored sparkle on item drop
	var color: Color = load("res://scripts/utils/color_palette.gd").rarity_color(rarity)
	var particles: GPUParticles3D = GPUParticles3D.new()
	particles.amount = 8
	particles.lifetime = 0.6
	particles.one_shot = true
	particles.emitting = true
	var mat: ParticleProcessMaterial = ParticleProcessMaterial.new()
	mat.direction = Vector3(0, 1, 0)
	mat.spread = 45.0
	mat.initial_velocity_min = 1.0
	mat.initial_velocity_max = 2.0
	mat.gravity = Vector3(0, -3, 0)
	mat.color = color
	particles.process_material = mat
	var mesh: SphereMesh = SphereMesh.new()
	mesh.radius = 0.05
	mesh.height = 0.1
	particles.draw_pass_1 = mesh
	parent.add_child(particles)
	particles.global_position = position
	# Auto-free after emission
	var timer: SceneTreeTimer = parent.get_tree().create_timer(1.0)
	timer.timeout.connect(particles.queue_free)


static func spawn_portal_particles(position: Vector3, parent: Node) -> GPUParticles3D:
	## Rotating particle ring for portals (persistent until freed)
	# Primary orbiting ring
	var particles: GPUParticles3D = GPUParticles3D.new()
	particles.amount = 24
	particles.lifetime = 2.0
	particles.position = position + Vector3(0, 1, 0)
	var mat: ParticleProcessMaterial = ParticleProcessMaterial.new()
	mat.direction = Vector3(0, 0.3, 0)
	mat.spread = 180.0
	mat.initial_velocity_min = 0.3
	mat.initial_velocity_max = 0.8
	mat.orbit_velocity_min = 1.2
	mat.orbit_velocity_max = 2.0
	mat.gravity = Vector3.ZERO
	mat.color = Color(0.35, 0.65, 1.0, 0.75)
	mat.scale_min = 0.5
	mat.scale_max = 1.2
	particles.process_material = mat
	var mesh: BoxMesh = BoxMesh.new()
	mesh.size = Vector3(0.05, 0.05, 0.05)
	particles.draw_pass_1 = mesh
	var vis: StandardMaterial3D = StandardMaterial3D.new()
	vis.albedo_color = Color(0.4, 0.7, 1.0, 0.7)
	vis.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	vis.emission_enabled = true
	vis.emission = Color(0.3, 0.6, 0.95)
	vis.emission_energy_multiplier = 2.5
	vis.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	particles.material_override = vis
	parent.add_child(particles)

	# Secondary: slow upward drift particles (data fragments)
	var drift: GPUParticles3D = GPUParticles3D.new()
	drift.amount = 10
	drift.lifetime = 3.0
	drift.position = position + Vector3(0, 0.5, 0)
	var drift_mat: ParticleProcessMaterial = ParticleProcessMaterial.new()
	drift_mat.direction = Vector3(0, 1, 0)
	drift_mat.spread = 30.0
	drift_mat.initial_velocity_min = 0.3
	drift_mat.initial_velocity_max = 0.6
	drift_mat.gravity = Vector3.ZERO
	drift_mat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	drift_mat.emission_sphere_radius = 0.8
	drift_mat.color = Color(0.5, 0.8, 1.0, 0.4)
	drift_mat.scale_min = 0.2
	drift_mat.scale_max = 0.6
	drift.process_material = drift_mat
	var drift_mesh: BoxMesh = BoxMesh.new()
	drift_mesh.size = Vector3(0.03, 0.03, 0.03)
	drift.draw_pass_1 = drift_mesh
	var drift_vis: StandardMaterial3D = StandardMaterial3D.new()
	drift_vis.albedo_color = Color(0.5, 0.8, 1.0, 0.3)
	drift_vis.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	drift_vis.emission_enabled = true
	drift_vis.emission = Color(0.4, 0.7, 0.95)
	drift_vis.emission_energy_multiplier = 1.5
	drift_vis.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	drift.material_override = drift_vis
	parent.add_child(drift)

	return particles


static func spawn_damage_number(position: Vector3, amount: int, is_crit: bool, parent: Node) -> void:
	## Floating damage number that rises, scales, and fades — size reflects damage.
	## Phase 4 #40 polish: no_depth_test for readability, crit scale pulse for pop.
	var label: Label3D = Label3D.new()
	# Scale font size by damage amount (clamped)
	var size_factor: float = clampf(amount / 20.0, 0.6, 2.5)
	if is_crit:
		label.text = str(amount) + "!"
		label.font_size = int(44 * size_factor)
		label.modulate = Color(1.0, 0.9, 0.1)
		label.outline_modulate = Color(0.4, 0.15, 0, 0.9)
		label.outline_size = 7
	else:
		label.text = str(amount)
		label.font_size = int(28 * size_factor)
		label.modulate = Color(1.0, 0.35, 0.2)
		label.outline_modulate = Color(0, 0, 0, 0.8)
		label.outline_size = 5
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.no_depth_test = true
	label.fixed_size = true
	label.pixel_size = 0.004
	# Scatter horizontally to prevent stacking
	var scatter_x: float = randf_range(-0.5, 0.5)
	var scatter_z: float = randf_range(-0.2, 0.2)
	label.position = position + Vector3(scatter_x, 1.0, scatter_z)
	parent.add_child(label)
	# Pop-in scale effect then float up
	label.scale = Vector3(0.5, 0.5, 0.5)
	var tween: Tween = label.create_tween()
	if is_crit:
		# Crit: overshoot scale pulse for visual pop
		tween.tween_property(label, "scale", Vector3(1.4, 1.4, 1.4), 0.06).set_ease(Tween.EASE_OUT)
		tween.tween_property(label, "scale", Vector3(1.0, 1.0, 1.0), 0.08).set_ease(Tween.EASE_IN)
	else:
		tween.tween_property(label, "scale", Vector3(1.0, 1.0, 1.0), 0.08).set_ease(Tween.EASE_OUT)
	tween.tween_property(label, "position:y", label.position.y + 1.8, 0.9).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(label, "modulate:a", 0.0, 0.9).set_delay(0.35)
	tween.tween_callback(label.queue_free)


static func spawn_heal_number(position: Vector3, amount: int, parent: Node) -> void:
	## Green floating "+HP" number for heals
	var label: Label3D = Label3D.new()
	label.text = "+" + str(amount)
	label.font_size = 24
	label.modulate = Color(0.2, 0.95, 0.4)
	label.outline_modulate = Color(0, 0, 0, 0.6)
	label.outline_size = 3
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.position = position + Vector3(randf_range(-0.3, 0.3), 1.2, 0)
	parent.add_child(label)
	label.scale = Vector3(0.5, 0.5, 0.5)
	var tween: Tween = label.create_tween()
	tween.tween_property(label, "scale", Vector3(1.0, 1.0, 1.0), 0.1)
	tween.tween_property(label, "position:y", label.position.y + 1.5, 0.8).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(label, "modulate:a", 0.0, 0.8).set_delay(0.3)
	tween.tween_callback(label.queue_free)


static func spawn_compute_particles(position: Vector3, parent: Node) -> void:
	## Blue compute restore particles rising upward
	var particles: GPUParticles3D = GPUParticles3D.new()
	particles.amount = 12
	particles.lifetime = 0.8
	particles.one_shot = true
	particles.emitting = true
	var mat: ParticleProcessMaterial = ParticleProcessMaterial.new()
	mat.direction = Vector3(0, 1, 0)
	mat.spread = 30.0
	mat.initial_velocity_min = 1.5
	mat.initial_velocity_max = 2.5
	mat.gravity = Vector3(0, -1, 0)
	mat.color = Color(0.3, 0.6, 1.0, 0.8)
	particles.process_material = mat
	var mesh: BoxMesh = BoxMesh.new()
	mesh.size = Vector3(0.03, 0.03, 0.03)
	particles.draw_pass_1 = mesh
	var vis: StandardMaterial3D = StandardMaterial3D.new()
	vis.albedo_color = Color(0.3, 0.6, 1.0, 0.7)
	vis.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	vis.emission_enabled = true
	vis.emission = Color(0.25, 0.55, 0.95)
	vis.emission_energy_multiplier = 2.5
	vis.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	particles.material_override = vis
	parent.add_child(particles)
	particles.global_position = position
	parent.get_tree().create_timer(1.2).timeout.connect(particles.queue_free)


static func spawn_compute_number(position: Vector3, amount: int, parent: Node) -> void:
	## Blue floating "+CP" number for compute restore
	var label: Label3D = Label3D.new()
	label.text = "+%d CP" % amount
	label.font_size = 22
	label.modulate = Color(0.35, 0.7, 1.0)
	label.outline_modulate = Color(0, 0, 0, 0.6)
	label.outline_size = 3
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.position = position + Vector3(randf_range(-0.3, 0.3), 1.3, 0)
	parent.add_child(label)
	label.scale = Vector3(0.5, 0.5, 0.5)
	var tween: Tween = label.create_tween()
	tween.tween_property(label, "scale", Vector3(1.0, 1.0, 1.0), 0.1)
	tween.tween_property(label, "position:y", label.position.y + 1.5, 0.8).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(label, "modulate:a", 0.0, 0.8).set_delay(0.3)
	tween.tween_callback(label.queue_free)


static func spawn_heal_particles(position: Vector3, parent: Node) -> void:
	## Green healing particles rising upward
	var particles: GPUParticles3D = GPUParticles3D.new()
	particles.amount = 12
	particles.lifetime = 0.8
	particles.one_shot = true
	particles.emitting = true
	var mat: ParticleProcessMaterial = ParticleProcessMaterial.new()
	mat.direction = Vector3(0, 1, 0)
	mat.spread = 30.0
	mat.initial_velocity_min = 1.5
	mat.initial_velocity_max = 2.5
	mat.gravity = Vector3(0, -1, 0)
	mat.color = Color(0.2, 0.9, 0.3, 0.8)
	particles.process_material = mat
	var mesh: SphereMesh = SphereMesh.new()
	mesh.radius = 0.04
	mesh.height = 0.08
	particles.draw_pass_1 = mesh
	parent.add_child(particles)
	particles.global_position = position
	parent.get_tree().create_timer(1.2).timeout.connect(particles.queue_free)


static func spawn_level_up_effect(position: Vector3, parent: Node) -> void:
	## Golden burst + ring for level up celebration
	# Burst particles
	var particles: GPUParticles3D = GPUParticles3D.new()
	particles.amount = 30
	particles.lifetime = 1.0
	particles.one_shot = true
	particles.emitting = true
	var mat: ParticleProcessMaterial = ParticleProcessMaterial.new()
	mat.direction = Vector3(0, 1, 0)
	mat.spread = 180.0
	mat.initial_velocity_min = 2.0
	mat.initial_velocity_max = 4.0
	mat.gravity = Vector3(0, -2, 0)
	mat.color = Color(1.0, 0.85, 0.2, 0.9)
	particles.process_material = mat
	var mesh: SphereMesh = SphereMesh.new()
	mesh.radius = 0.05
	mesh.height = 0.1
	particles.draw_pass_1 = mesh
	parent.add_child(particles)
	particles.global_position = position
	# Expanding ring
	var ring: MeshInstance3D = MeshInstance3D.new()
	var torus: TorusMesh = TorusMesh.new()
	torus.inner_radius = 0.3
	torus.outer_radius = 0.5
	ring.mesh = torus
	var ring_mat: StandardMaterial3D = StandardMaterial3D.new()
	ring_mat.albedo_color = Color(1.0, 0.8, 0.2, 0.6)
	ring_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	ring_mat.emission_enabled = true
	ring_mat.emission = Color(1.0, 0.75, 0.15)
	ring_mat.emission_energy_multiplier = 2.0
	ring.material_override = ring_mat
	parent.add_child(ring)
	ring.global_position = position
	var tween: Tween = ring.create_tween()
	tween.tween_property(ring, "scale", Vector3(5, 5, 5), 0.5)
	tween.parallel().tween_property(ring_mat, "albedo_color:a", 0.0, 0.5)
	tween.tween_callback(ring.queue_free)
	parent.get_tree().create_timer(1.5).timeout.connect(particles.queue_free)
