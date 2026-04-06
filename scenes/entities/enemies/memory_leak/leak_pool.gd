class_name LeakPool
extends Area3D
## Damaging ground pool left by Memory Leak projectiles.

const POOL_DURATION: float = 3.0
const POOL_DPS: float = 3.0
const POOL_RADIUS: float = 1.5

var source_node: Node = null
var _timer: float = 0.0
var _damage_timer: float = 0.0


func _ready() -> void:
	# Passive detection area
	collision_layer = 0
	collision_mask = 64  # detect hurtboxes

	var shape: CollisionShape3D = CollisionShape3D.new()
	var sphere: SphereShape3D = SphereShape3D.new()
	sphere.radius = POOL_RADIUS
	shape.shape = sphere
	add_child(shape)

	# Placeholder visual — flat green disc
	var mesh_instance: MeshInstance3D = MeshInstance3D.new()
	var cylinder: CylinderMesh = CylinderMesh.new()
	cylinder.top_radius = POOL_RADIUS
	cylinder.bottom_radius = POOL_RADIUS
	cylinder.height = 0.05
	mesh_instance.mesh = cylinder
	var mat: StandardMaterial3D = StandardMaterial3D.new()
	mat.albedo_color = Color(0.2, 0.8, 0.2, 0.5)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mesh_instance.material_override = mat
	add_child(mesh_instance)


func _process(delta: float) -> void:
	_timer += delta
	_damage_timer += delta

	if _timer >= POOL_DURATION:
		queue_free()
		return

	# Deal damage once per second to overlapping hurtboxes
	if _damage_timer >= 1.0:
		_damage_timer = 0.0
		for area: Area3D in get_overlapping_areas():
			if not area is HurtboxComponent:
				continue
			var hurtbox: HurtboxComponent = area as HurtboxComponent
			if hurtbox.owner_entity == source_node:
				continue
			if &"is_invulnerable" in hurtbox.owner_entity and hurtbox.owner_entity.is_invulnerable:
				continue
			var health: HealthComponent = hurtbox.owner_entity.get_node_or_null("HealthComponent") as HealthComponent
			if health:
				health.take_damage(POOL_DPS)
