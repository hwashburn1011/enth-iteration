class_name VFXFactory
extends RefCounted
## Static factory for common VFX — spawn-and-forget visual effects.


static func spawn_hit_flash(position: Vector3, parent: Node) -> void:
	## White flash burst on hit (0.2s)
	var mesh: MeshInstance3D = MeshInstance3D.new()
	var sphere: SphereMesh = SphereMesh.new()
	sphere.radius = 0.3
	sphere.height = 0.6
	mesh.mesh = sphere
	var mat: StandardMaterial3D = StandardMaterial3D.new()
	mat.albedo_color = Color(1, 1, 1, 0.8)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.emission_enabled = true
	mat.emission = Color.WHITE
	mat.emission_energy_multiplier = 2.0
	mesh.material_override = mat
	mesh.global_position = position
	parent.add_child(mesh)
	var tween: Tween = mesh.create_tween()
	tween.tween_property(mesh, "scale", Vector3(2, 2, 2), 0.2)
	tween.parallel().tween_property(mat, "albedo_color:a", 0.0, 0.2)
	tween.tween_callback(mesh.queue_free)


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
	mesh.global_position = position
	parent.add_child(mesh)
	var tween: Tween = mesh.create_tween()
	tween.tween_property(mesh, "scale", Vector3(4, 4, 4), 0.3)
	tween.parallel().tween_property(mat, "albedo_color:a", 0.0, 0.3)
	tween.tween_callback(mesh.queue_free)


static func spawn_death_dissolve(target: Node3D) -> void:
	## Shrink + fade dissolve on enemy death (0.5s)
	var tween: Tween = target.create_tween()
	tween.tween_property(target, "scale", Vector3(0.01, 0.01, 0.01), 0.5).set_ease(Tween.EASE_IN)


static func spawn_item_sparkle(position: Vector3, rarity: int, parent: Node) -> void:
	## Rarity-colored sparkle on item drop
	var color: Color = load("res://scripts/utils/color_palette.gd").rarity_color(rarity)
	var particles: GPUParticles3D = GPUParticles3D.new()
	particles.amount = 8
	particles.lifetime = 0.6
	particles.one_shot = true
	particles.emitting = true
	particles.global_position = position
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
	# Auto-free after emission
	var timer: SceneTreeTimer = parent.get_tree().create_timer(1.0)
	timer.timeout.connect(particles.queue_free)


static func spawn_portal_particles(position: Vector3, parent: Node) -> GPUParticles3D:
	## Rotating particle ring for portals (persistent until freed)
	var particles: GPUParticles3D = GPUParticles3D.new()
	particles.amount = 20
	particles.lifetime = 1.5
	particles.global_position = position + Vector3(0, 1, 0)
	var mat: ParticleProcessMaterial = ParticleProcessMaterial.new()
	mat.direction = Vector3(0, 0, 0)
	mat.spread = 180.0
	mat.initial_velocity_min = 0.5
	mat.initial_velocity_max = 1.0
	mat.orbit_velocity_min = 1.0
	mat.orbit_velocity_max = 1.5
	mat.gravity = Vector3.ZERO
	mat.color = Color(0.4, 0.7, 1.0, 0.8)
	particles.process_material = mat
	var mesh: SphereMesh = SphereMesh.new()
	mesh.radius = 0.06
	mesh.height = 0.12
	particles.draw_pass_1 = mesh
	parent.add_child(particles)
	return particles


static func spawn_damage_number(position: Vector3, amount: int, is_crit: bool, parent: Node) -> void:
	## Floating damage number that rises and fades
	var label: Label3D = Label3D.new()
	label.text = str(amount)
	label.font_size = 32 if not is_crit else 48
	label.modulate = Color(1.0, 0.3, 0.2) if not is_crit else Color(1.0, 0.9, 0.1)
	label.outline_modulate = Color(0, 0, 0)
	label.outline_size = 4
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.global_position = position + Vector3(randf_range(-0.3, 0.3), 1.0, 0)
	parent.add_child(label)
	var tween: Tween = label.create_tween()
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
	particles.global_position = position
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
	parent.get_tree().create_timer(1.2).timeout.connect(particles.queue_free)


static func spawn_level_up_effect(position: Vector3, parent: Node) -> void:
	## Golden burst + ring for level up celebration
	# Burst particles
	var particles: GPUParticles3D = GPUParticles3D.new()
	particles.amount = 30
	particles.lifetime = 1.0
	particles.one_shot = true
	particles.emitting = true
	particles.global_position = position
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
	ring.global_position = position
	parent.add_child(ring)
	var tween: Tween = ring.create_tween()
	tween.tween_property(ring, "scale", Vector3(5, 5, 5), 0.5)
	tween.parallel().tween_property(ring_mat, "albedo_color:a", 0.0, 0.5)
	tween.tween_callback(ring.queue_free)
	parent.get_tree().create_timer(1.5).timeout.connect(particles.queue_free)
