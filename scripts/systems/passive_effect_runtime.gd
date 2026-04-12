class_name PassiveEffectRuntime
extends RefCounted
## R5 Epic U — Runtime consumers for lifesteal and thorns passive effects.
##
## U1: Lifesteal — heals player for % of damage dealt
## U2: Thorns — reflects % of incoming damage back to attacker
## U4: Lifesteal VFX — green heal number
## U5: Thorns VFX — red reflect number
## U6-U10: Persistence, stacking, tooltip, HUD indicator, balance


## U1: Apply lifesteal after dealing damage. Call from attack hit handler.
## Returns the amount healed (0 if no lifesteal passive).
static func apply_lifesteal(player: Node, damage_dealt: float) -> float:
	if not player.has_meta(&"passive_lifesteal_pct"):
		return 0.0
	var pct: float = float(player.get_meta(&"passive_lifesteal_pct", 0.0))
	if pct <= 0.0:
		return 0.0
	var heal_amount: float = damage_dealt * pct / 100.0
	var health: Node = player.get_node_or_null("HealthComponent")
	if health and health.has_method(&"heal"):
		health.heal(heal_amount)
	elif health and "current_health" in health and "max_health" in health:
		health.current_health = minf(health.current_health + heal_amount, health.max_health)
	# U4: Lifesteal VFX — green heal number
	if player is Node3D and player.is_inside_tree():
		_spawn_heal_number((player as Node3D).global_position, heal_amount, player.get_tree().current_scene)
	return heal_amount


## U2: Apply thorns when player takes damage. Call from hurtbox damage handler.
## Returns the amount reflected (0 if no thorns passive).
static func apply_thorns(player: Node, attacker: Node, damage_taken: float) -> float:
	if not player.has_meta(&"passive_thorns_pct"):
		return 0.0
	var pct: float = float(player.get_meta(&"passive_thorns_pct", 0.0))
	if pct <= 0.0:
		return 0.0
	var reflect_amount: float = damage_taken * pct / 100.0
	if attacker != null:
		var attacker_health: Node = attacker.get_node_or_null("HealthComponent")
		if attacker_health and attacker_health.has_method(&"take_damage"):
			attacker_health.take_damage(reflect_amount)
	# U5: Thorns VFX — red reflect number at attacker position
	if attacker is Node3D and attacker.is_inside_tree():
		_spawn_reflect_number((attacker as Node3D).global_position, reflect_amount, attacker.get_tree().current_scene)
	return reflect_amount


## U4: Green heal number VFX.
static func _spawn_heal_number(pos: Vector3, amount: float, scene_root: Node) -> void:
	var label: Label3D = Label3D.new()
	label.text = "+%.0f" % amount
	label.font_size = 48
	label.modulate = Color(0.2, 1.0, 0.3)
	label.outline_modulate = Color(0, 0.3, 0, 0.9)
	label.outline_size = 4
	label.no_depth_test = true
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.global_position = pos + Vector3(0.3, 1.2, 0)
	scene_root.add_child(label)
	var tween: Tween = label.create_tween()
	tween.tween_property(label, "global_position:y", pos.y + 2.0, 0.8)
	tween.parallel().tween_property(label, "modulate:a", 0.0, 0.8)
	tween.tween_callback(label.queue_free)


## U5: Red reflect number VFX.
static func _spawn_reflect_number(pos: Vector3, amount: float, scene_root: Node) -> void:
	var label: Label3D = Label3D.new()
	label.text = "%.0f" % amount
	label.font_size = 40
	label.modulate = Color(1.0, 0.4, 0.2)
	label.outline_modulate = Color(0.4, 0, 0, 0.9)
	label.outline_size = 4
	label.no_depth_test = true
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.global_position = pos + Vector3(-0.3, 1.5, 0)
	scene_root.add_child(label)
	var tween: Tween = label.create_tween()
	tween.tween_property(label, "global_position:y", pos.y + 2.3, 0.7)
	tween.parallel().tween_property(label, "modulate:a", 0.0, 0.7)
	tween.tween_callback(label.queue_free)


## U7: Get total lifesteal and thorns percentages for display.
static func get_passive_summary(player: Node) -> Dictionary:
	return {
		"lifesteal_pct": float(player.get_meta(&"passive_lifesteal_pct", 0.0)),
		"thorns_pct": float(player.get_meta(&"passive_thorns_pct", 0.0)),
	}
