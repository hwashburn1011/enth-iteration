class_name CompanionCombatState
extends CompanionState

## Combat: targets enemies based on role priority, attacks within range,
## repositions when needed. Returns to Follow when no targets remain.

var _attack_cooldown: float = 0.0


func get_state_id() -> StringName:
	return STATE_COMBAT


func enter(ai: Node) -> void:
	_attack_cooldown = 0.0
	if ai.has_method("play_animation"):
		ai.play_animation(&"combat_idle")
	if ai.has_method("emit_banter"):
		ai.emit_banter(&"combat_start")


func tick(ai: Node, delta: float) -> void:
	_attack_cooldown -= delta

	# Pick the best target based on companion role
	var target: Node3D = ai.pick_target_by_role()
	if target == null:
		return

	var dist: float = ai.global_position.distance_to(target.global_position)
	var attack_range: float = ai.companion_def.get("attack_range", 2.0)

	if dist > attack_range:
		# Move toward target
		if ai.has_method("move_toward_position"):
			ai.move_toward_position(target.global_position, delta)
		if ai.has_method("play_animation"):
			ai.play_animation(&"run")
	else:
		# In range — attack if cooldown ready
		if _attack_cooldown <= 0.0:
			ai.attack(target)
			var attacks_per_sec: float = ai.companion_def.get("attack_speed", 1.0)
			_attack_cooldown = 1.0 / max(0.1, attacks_per_sec)
			if ai.has_method("play_animation"):
				ai.play_animation(&"attack")


func get_next_state(ai: Node) -> StringName:
	if ai.has_method("get_health") and ai.get_health() <= 0.0:
		return STATE_DOWNED
	if ai.has_method("has_combat_target") and not ai.has_combat_target():
		return STATE_FOLLOW
	return &""
