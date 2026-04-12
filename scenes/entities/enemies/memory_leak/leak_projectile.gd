class_name LeakProjectile
extends Area3D
## Slow projectile that damages on contact and leaves a damaging pool.

const SPEED: float = 5.0
const LIFETIME: float = 4.0
const POOL_RADIUS: float = 1.5
const POOL_DURATION: float = 3.0
const POOL_DPS: float = 3.0

var direction: Vector3 = Vector3.ZERO
var base_damage: float = 12.0
var source_node: Node = null
var _timer: float = 0.0


func _ready() -> void:
	# Hitbox behavior — layer 6, mask 7
	collision_layer = 32
	collision_mask = 64
	area_entered.connect(_on_area_entered)


func _physics_process(delta: float) -> void:
	_timer += delta
	global_position += direction * SPEED * delta
	if _timer >= LIFETIME:
		_spawn_pool()
		queue_free()


func _on_area_entered(area: Area3D) -> void:
	# hit_received is a SIGNAL on HurtboxComponent, not a method, so
	# has_method(&"hit_received") always returns false. Duck-type via the
	# owner_entity property instead — that's a HurtboxComponent field
	# nothing else exposes. Without this, the projectile silently no-ops
	# every overlap and the Memory Leak's entire ranged attack is dead.
	if not (&"owner_entity" in area):
		return
	var hurtbox: Node = area as Node
	# Skip self-damage
	if hurtbox.owner_entity == source_node:
		return
	if &"is_invulnerable" in hurtbox.owner_entity and hurtbox.owner_entity.is_invulnerable:
		return

	var info: Resource = load("res://scripts/resources/damage_info.gd").new()
	info.source = source_node
	info.target = hurtbox.owner_entity
	info.base_damage = base_damage
	info.damage_type = &"energy"
	info = load("res://scripts/combat/damage_calculator.gd").calculate(info)
	hurtbox.hit_received.emit(info)

	var health: Node = hurtbox.owner_entity.get_node_or_null("HealthComponent") as Node
	if health:
		health.take_damage(info.final_damage)

	_spawn_pool()
	queue_free()


func _spawn_pool() -> void:
	var pool: Node = load("res://scenes/entities/enemies/memory_leak/leak_pool.gd").new()
	pool.source_node = source_node
	var pool_pos: Vector3 = global_position
	get_tree().current_scene.add_child(pool)
	pool.global_position = pool_pos
