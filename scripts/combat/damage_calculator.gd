class_name DamageCalculator
extends RefCounted
## Static damage pipeline: stats → equipment → defense → status → crit → final.

const BASE_CRIT_CHANCE: float = 5.0
const CRIT_MULTIPLIER: float = 2.0
const MIN_DAMAGE: float = 1.0


static func calculate(info: Resource) -> Resource:
	var damage: float = info.base_damage

	# 1. Apply stat multiplier from source Processing
	# Note: base_damage from attack states may already include processing scaling.
	# Only apply the multiplier for enemies (whose base_damage is raw).
	var source_stats: Node = _get_stats(info.source)
	if source_stats and not info.source.is_in_group(&"player"):
		info.stat_multiplier = source_stats.get_stat("processing") * 0.1
		damage *= (1.0 + info.stat_multiplier)

	# 2. Apply equipment modifier
	damage *= (1.0 + info.equipment_modifier)

	# 3. Apply defense from target Integrity
	var target_stats: Node = _get_stats(info.target)
	if target_stats:
		var defense: float = target_stats.get_stat("integrity") * 0.5
		damage = maxf(MIN_DAMAGE, damage - defense)

	# 4. Apply status modifiers
	damage = _apply_status_modifiers(damage, info)

	# 5. Critical hit check
	var crit_chance: float = BASE_CRIT_CHANCE
	if source_stats:
		crit_chance += source_stats.get_stat("processing") * 0.5
	if randf() * 100.0 < crit_chance:
		damage *= CRIT_MULTIPLIER
		info.is_critical = true

	# 6. Set final damage
	info.final_damage = damage

	# Emit event
	EventBus.damage_dealt.emit(int(info.final_damage), info.source, info.target, info.damage_type)

	# Spawn VFX
	if info.target is Node3D:
		var target_3d: Node3D = info.target as Node3D
		VFXFactory.spawn_damage_number(target_3d.global_position, int(info.final_damage), info.is_critical, target_3d.get_tree().current_scene)
		VFXFactory.spawn_hit_flash(target_3d.global_position + Vector3(0, 0.5, 0), target_3d.get_tree().current_scene)
		# Screen shake on hit
		var camera: Camera3D = target_3d.get_viewport().get_camera_3d()
		if camera and camera.has_method(&"shake"):
			var shake_amount: float = 0.08 if not info.is_critical else 0.2
			camera.shake(shake_amount)

	return info


static func _get_stats(node: Node) -> Node:
	if node == null:
		return null
	return node.get_node_or_null("StatsComponent") as Node


static func _apply_status_modifiers(damage: float, info: Resource) -> float:
	var result: float = damage
	# Check if target has Fragmented status (takes 30% more damage)
	if info.target and info.target.has_meta(&"status_fragmented"):
		result *= 1.3
	# Check if source has Overclocked status (deals 50% more damage)
	if info.source and info.source.has_meta(&"status_overclocked"):
		result *= 1.5
	return result
