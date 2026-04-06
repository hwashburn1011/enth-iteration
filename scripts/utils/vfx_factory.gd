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
