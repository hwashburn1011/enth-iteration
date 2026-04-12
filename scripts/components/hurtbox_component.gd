class_name HurtboxComponent
extends Area3D
## Receives damage from HitboxComponents and routes through the damage pipeline.

signal hit_received(damage_info: Resource)

var owner_entity: Node


func _ready() -> void:
	# Collision layer 7 (Hurtbox), scans no layers (passive)
	collision_layer = 64   # bit 6 = layer 7
	collision_mask = 0
	owner_entity = get_parent()
	area_entered.connect(_on_area_entered)


func _on_area_entered(area: Area3D) -> void:
	if not area.has_method(&"activate"):
		return
	var hitbox: Node = area as Node

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
	var info: Resource = load("res://scripts/resources/damage_info.gd").new()
	info.source = hitbox.damage_source
	info.target = owner_entity
	info.base_damage = hitbox.get_meta(&"base_damage", 5.0) as float
	info.damage_type = hitbox.get_meta(&"damage_type", &"data") as StringName

	# Knockback direction away from source
	if info.source is Node3D and owner_entity is Node3D:
		info.knockback_direction = ((owner_entity as Node3D).global_position - (info.source as Node3D).global_position).normalized()
		info.knockback_direction.y = 0.0

	info = load("res://scripts/combat/damage_calculator.gd").calculate(info)
	hit_received.emit(info)

	# Phase 3 #25 — block / parry. If the target is the player and
	# they're holding block, mitigate or fully negate the incoming
	# hit. The first ~0.18s of a fresh block is a perfect parry that
	# negates the hit AND tags the attacker with `fragmented` so the
	# follow-up swing punches harder. Sustained block past the parry
	# window is just damage reduction.
	var blocked: bool = false
	if &"is_blocking" in owner_entity and owner_entity.is_blocking:
		blocked = true
		var parry: bool = false
		if owner_entity.has_method(&"is_in_parry_window"):
			parry = bool(owner_entity.is_in_parry_window())
		if parry:
			info.final_damage = 0.0
			# A7: Riposte — deal 50% of the blocked damage back to the attacker
			if info.source is Node:
				var riposte_dmg: float = info.base_damage * 0.5
				var attacker_hp: Node = info.source.get_node_or_null("HealthComponent") as Node
				if attacker_hp and attacker_hp.has_method(&"take_damage"):
					attacker_hp.take_damage(riposte_dmg)
					EventBus.damage_dealt.emit(info.source as Node3D, riposte_dmg, false)
			# Tag the attacker fragmented for free
			if info.source is Node and info.source.has_node("StatusEffectManager"):
				var sm: Node = info.source.get_node("StatusEffectManager")
				if sm.has_method(&"apply_effect"):
					var effect: Resource = load("res://scripts/combat/status_effect_library.gd").make_fragmented()
					if effect != null:
						sm.apply_effect(effect)
			# Phase 3 #29 — Counterstrike chip: extend the parry
			# payoff into an AoE. Every enemy within 5m of the
			# parrying player gets the same Fragmented tag, so the
			# parry becomes a setup for a follow-up sweep instead
			# of just a single-target counter.
			var equip: Node = owner_entity.get_node_or_null("EquipmentComponent") as Node
			if equip and equip.has_method(&"has_chip_passive") and equip.has_chip_passive("parry_counterstrike"):
				var center: Vector3 = (owner_entity as Node3D).global_position
				for enemy: Node in owner_entity.get_tree().get_nodes_in_group(&"enemies"):
					if enemy == info.source or not enemy is Node3D:
						continue
					if (enemy as Node3D).global_position.distance_to(center) > 5.0:
						continue
					var esm: Node = enemy.get_node_or_null("StatusEffectManager") as Node
					if esm and esm.has_method(&"apply_effect"):
						var aoe_effect: Resource = load("res://scripts/combat/status_effect_library.gd").make_fragmented()
						if aoe_effect != null:
							esm.apply_effect(aoe_effect)
		else:
			# 80% mitigation — readable as "I'm absorbing it but it
			# still chips through". The const lives on player.gd.
			var reduction: float = 0.80
			if &"BLOCK_DAMAGE_REDUCTION" in owner_entity:
				reduction = float(owner_entity.BLOCK_DAMAGE_REDUCTION)
			info.final_damage *= (1.0 - reduction)

	# Apply damage to HealthComponent if present
	var health: Node = owner_entity.get_node_or_null("HealthComponent") as Node
	if health:
		health.take_damage(info.final_damage)
	# F63: Wire thorns passive — reflect damage back to attacker when player takes damage
	if owner_entity.is_in_group(&"player") and info.final_damage > 0.0 and info.source is Node:
		CombatFeelWiring.on_player_took_damage(owner_entity, info.source, info.final_damage)
	# Suppress the apply_status routing on a successful block /
	# parry — the whole point of holding block is "I refuse the
	# debuff". Drop through to the existing apply_status path
	# below ONLY when blocked is false.
	if blocked:
		return

	# Phase 3 #22 — status effect routing. The source's hitbox can
	# tag the swing with `apply_status = "<name>"` and we'll route a
	# fresh StatusEffect onto the target's StatusEffectManager. The
	# library returns null on unknown names so this no-ops cleanly
	# for hits that don't carry a status payload.
	if hitbox.has_meta(&"apply_status"):
		var sm: Node = owner_entity.get_node_or_null("StatusEffectManager") as Node
		if sm and sm.has_method(&"apply_effect"):
			var effect: Resource = load("res://scripts/combat/status_effect_library.gd").make_by_name(
				hitbox.get_meta(&"apply_status") as StringName
			)
			if effect != null:
				sm.apply_effect(effect)
