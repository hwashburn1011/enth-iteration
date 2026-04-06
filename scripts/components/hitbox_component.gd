class_name HitboxComponent
extends Area3D
## Deals damage when overlapping a HurtboxComponent. Tracks hits to prevent duplicates.

@export var damage_source: Node

var is_active: bool = false
var hit_targets: Array[Node] = []


func _ready() -> void:
	# Collision layer 6 (Hitbox), mask layer 7 (Hurtbox)
	collision_layer = 32   # bit 5 = layer 6
	collision_mask = 64    # bit 6 = layer 7
	monitoring = false
	monitorable = false


func activate() -> void:
	is_active = true
	hit_targets.clear()
	monitoring = true
	monitorable = true
	for child: Node in get_children():
		if child is CollisionShape3D:
			child.disabled = false


func deactivate() -> void:
	is_active = false
	hit_targets.clear()
	monitoring = false
	monitorable = false
	for child: Node in get_children():
		if child is CollisionShape3D:
			child.disabled = true


func has_hit(target: Node) -> bool:
	return target in hit_targets


func register_hit(target: Node) -> void:
	hit_targets.append(target)
