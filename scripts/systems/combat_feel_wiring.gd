class_name CombatFeelWiring
extends RefCounted
## R6 Epics AB+AC — Scene transitions, combat feel, and set bonus wiring.
##
## AB21-AB30: Scene transition fades and pause menu button wiring
## AC31-AC40: Enemy behavior implementations and set bonus consumers


## AB21-AB23: Create scene fade for dungeon/town/death transitions.
static func fade_to_scene(tree: SceneTree, target_scene: String) -> void:
	AudioSceneWiring.create_scene_fade(tree, func() -> void:
		GameManager.change_scene_to(target_scene)
	)


## AB24: Show loading screen during scene changes.
static func show_loading_screen_for(tree: SceneTree, screen_id: StringName) -> void:
	var ls_scene: PackedScene = load("res://scenes/ui/LoadingScreen.tscn") as PackedScene
	if ls_scene == null:
		return
	var ls: Control = ls_scene.instantiate() as Control
	tree.current_scene.add_child(ls)
	if ls.has_method(&"show_for"):
		ls.show_for(screen_id)


## AB30: Death screen iteration context — set iteration meta before death screen.
static func set_death_context() -> void:
	var iter: int = 1
	if GameManager.has_node("/root/IterationManager"):
		var im: Node = GameManager.get_node("/root/IterationManager")
		if im.has_method(&"get_current_iteration"):
			iter = int(im.get_current_iteration())
	GameManager.set_meta(&"death_iteration", iter)


## AC36: Lifesteal trigger — call from player attack hit handler.
static func on_player_dealt_damage(player: Node, damage: float) -> void:
	PassiveEffectRuntime.apply_lifesteal(player, damage)


## AC37: Thorns trigger — call from player hurtbox when taking damage.
static func on_player_took_damage(player: Node, attacker: Node, damage: float) -> void:
	PassiveEffectRuntime.apply_thorns(player, attacker, damage)


## AC38: Dash reset on kill — check set bonus meta.
static func check_dash_reset_on_kill(player: Node) -> void:
	if player.has_meta(&"set_bonus_dash_reset_on_kill"):
		if player.has_method(&"reset_dash_cooldown"):
			player.reset_dash_cooldown()
		elif "dash_cooldown_remaining" in player:
			player.dash_cooldown_remaining = 0.0


## AC39: Move speed set bonus — returns additional move speed multiplier.
static func get_move_speed_bonus(player: Node) -> float:
	if player.has_meta(&"set_bonus_move_speed"):
		return float(player.get_meta(&"set_bonus_move_speed")) / 100.0
	return 0.0


## AC40: Ability damage set bonus — returns damage multiplier.
static func get_ability_damage_mult(player: Node) -> float:
	if player.has_meta(&"set_bonus_ability_damage"):
		return 1.0 + float(player.get_meta(&"set_bonus_ability_damage")) / 100.0
	return 1.0
