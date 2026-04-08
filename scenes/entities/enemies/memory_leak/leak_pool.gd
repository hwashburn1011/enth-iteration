class_name LeakPool
extends Area3D
## Damaging ground pool left by Memory Leak projectiles.

const POOL_DURATION: float = 3.0
const POOL_DPS: float = 3.0
const POOL_RADIUS: float = 1.5

var source_node: Node = null
var _timer: float = 0.0
var _damage_timer: float = 0.0


var _pool_mesh: MeshInstance3D = null
var _pool_mat: StandardMaterial3D = null


func _ready() -> void:
	# Passive detection area
	collision_layer = 0
	collision_mask = 64  # detect hurtboxes

	var shape: CollisionShape3D = CollisionShape3D.new()
	var sphere: SphereShape3D = SphereShape3D.new()
	sphere.radius = POOL_RADIUS
	shape.shape = sphere
	add_child(shape)

	# Enhanced pool visual — glowing green disc with emission
	_pool_mesh = MeshInstance3D.new()
	var cylinder: CylinderMesh = CylinderMesh.new()
	cylinder.top_radius = POOL_RADIUS
	cylinder.bottom_radius = POOL_RADIUS
	cylinder.height = 0.04
	_pool_mesh.mesh = cylinder
	_pool_mat = StandardMaterial3D.new()
	_pool_mat.albedo_color = Color(0.15, 0.75, 0.25, 0.6)
	_pool_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_pool_mat.emission_enabled = true
	_pool_mat.emission = Color(0.1, 0.65, 0.2)
	_pool_mat.emission_energy_multiplier = 1.5
	_pool_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_pool_mesh.material_override = _pool_mat
	add_child(_pool_mesh)
	# Expand-in animation
	_pool_mesh.scale = Vector3(0.3, 1.0, 0.3)
	var tween: Tween = _pool_mesh.create_tween()
	tween.tween_property(_pool_mesh, "scale", Vector3(1.0, 1.0, 1.0), 0.25).set_ease(Tween.EASE_OUT)

	# Bubble particles rising from pool
	var bubbles: GPUParticles3D = GPUParticles3D.new()
	bubbles.amount = 12
	bubbles.lifetime = 1.5
	var bub_mat: ParticleProcessMaterial = ParticleProcessMaterial.new()
	bub_mat.direction = Vector3(0, 1, 0)
	bub_mat.spread = 15.0
	bub_mat.initial_velocity_min = 0.3
	bub_mat.initial_velocity_max = 0.7
	bub_mat.gravity = Vector3(0, -0.3, 0)
	bub_mat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	bub_mat.emission_sphere_radius = POOL_RADIUS * 0.8
	bub_mat.color = Color(0.2, 0.8, 0.25, 0.6)
	bub_mat.scale_min = 0.3
	bub_mat.scale_max = 0.8
	bubbles.process_material = bub_mat
	var bub_mesh: SphereMesh = SphereMesh.new()
	bub_mesh.radius = 0.04
	bub_mesh.height = 0.08
	bubbles.draw_pass_1 = bub_mesh
	var bub_vis: StandardMaterial3D = StandardMaterial3D.new()
	bub_vis.albedo_color = Color(0.2, 0.8, 0.3, 0.5)
	bub_vis.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	bub_vis.emission_enabled = true
	bub_vis.emission = Color(0.15, 0.65, 0.2)
	bub_vis.emission_energy_multiplier = 2.0
	bub_vis.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	bubbles.material_override = bub_vis
	add_child(bubbles)


func _process(delta: float) -> void:
	_timer += delta
	_damage_timer += delta

	# Pulse emission intensity
	if _pool_mat:
		_pool_mat.emission_energy_multiplier = 1.2 + sin(_timer * 4.0) * 0.4
		# Fade out in last 0.5s
		if _timer > POOL_DURATION - 0.5:
			var fade: float = (POOL_DURATION - _timer) / 0.5
			_pool_mat.albedo_color.a = 0.6 * fade

	if _timer >= POOL_DURATION:
		queue_free()
		return

	# Deal damage once per second to overlapping hurtboxes
	if _damage_timer >= 1.0:
		_damage_timer = 0.0
		for area: Area3D in get_overlapping_areas():
			if not area.has_method(&"hit_received"):
				continue
			var hurtbox: Node = area as Node
			if hurtbox.owner_entity == source_node:
				continue
			if &"is_invulnerable" in hurtbox.owner_entity and hurtbox.owner_entity.is_invulnerable:
				continue
			var health: Node = hurtbox.owner_entity.get_node_or_null("HealthComponent") as Node
			if health:
				health.take_damage(POOL_DPS)
