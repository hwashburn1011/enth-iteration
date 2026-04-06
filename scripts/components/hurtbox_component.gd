class_name HurtboxComponent
extends Area3D
## Receives damage from HitboxComponents and routes through the damage pipeline.

signal hit_received(damage_info: DamageInfo)

var owner_entity: Node


func _ready() -> void:
	# Collision layer 7 (Hurtbox), scans no layers (passive)
	collision_layer = 64   # bit 6 = layer 7
	collision_mask = 0
	owner_entity = get_parent()
	area_entered.connect(_on_area_entered)


func _on_area_entered(area: Area3D) -> void:
	if not area is HitboxComponent:
		return
	var hitbox: HitboxComponent = area as HitboxComponent

	if not hitbox.is_active:
		return

	# No self-damage
	if hitbox.damage_source == owner_entity:
		return

	# Prevent duplicate hits
	if hitbox.has_hit(owner_entity):
		return
	hitbox.register_hit(owner_entity)

	# Check invulnerability
	if &"is_invulnerable" in owner_entity and owner_entity.is_invulnerable:
		return

	# Build DamageInfo and run through pipeline
	var info: DamageInfo = DamageInfo.new()
	info.source = hitbox.damage_source
	info.target = owner_entity
	info.base_damage = hitbox.get_meta(&"base_damage", 5.0) as float
	info.damage_type = hitbox.get_meta(&"damage_type", &"data") as StringName

	# Knockback direction away from source
	if info.source is Node3D and owner_entity is Node3D:
		info.knockback_direction = ((owner_entity as Node3D).global_position - (info.source as Node3D).global_position).normalized()
		info.knockback_direction.y = 0.0

	info = DamageCalculator.calculate(info)
	hit_received.emit(info)

	# Apply damage to HealthComponent if present
	var health: HealthComponent = owner_entity.get_node_or_null("HealthComponent") as HealthComponent
	if health:
		health.take_damage(info.final_damage)
