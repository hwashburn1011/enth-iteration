class_name IntegrationWiring
extends RefCounted
## R5 Epics X+Y — Integration wiring for gold autopickup, gamepad,
## damage log, statistics, auto-save, rarity borders, comparison,
## font size, kill counter, respec, and smoke test validation.
##
## X31-X40: Gold & gamepad startup wiring
## Y41-Y50: Integration testing & polish


## X31+X33: Wire gold autopickup into player _physics_process.
## Call per frame. Auto-collects gold drops within radius and shows VFX.
static func wire_gold_autopickup(player: Node3D) -> void:
	var collected: int = QoLRuntime.check_gold_autopickup(player)
	if collected > 0:
		GameManager.player_gold += collected
		# X33: Gold pickup VFX
		if player.is_inside_tree():
			VFXFactory.spawn_gold_number(player.global_position, collected, player.get_tree().current_scene)


## X32: Wire gamepad inputs on startup. Call once from GameManager._ready.
static func wire_gamepad_on_startup() -> void:
	QoLRuntime.wire_gamepad_inputs()


## X35: Wire damage log into HUD. Creates panel and connects to EventBus.
static func wire_damage_log(hud: Control) -> VBoxContainer:
	return HudWidgets.create_damage_log(hud)


## X37: Wire auto-save indicator. Flashes on SaveManager.save_game.
static func wire_autosave_indicator(hud_layer: CanvasLayer) -> Label:
	return HudWidgets.create_autosave_indicator(hud_layer)


## Y45: Wire kill counter into enemy death signal.
## Connect to EventBus.enemy_defeated.
static func on_enemy_defeated_count(enemy_type: StringName, _pos: Vector3, _loot: Resource) -> void:
	EnemyContent.increment_kill_count(String(enemy_type))


## Y47: Respec runtime — deducts gold and resets passive allocations.
static func respec_passives(player: Node) -> bool:
	if not "unlocked_passives" in player:
		return false
	var passives: Array = player.unlocked_passives as Array
	var cost: int = passives.size() * ProgressionExpansion.RESPEC_PASSIVE_COST_PER_NODE
	if GameManager.player_gold < cost:
		return false
	GameManager.player_gold -= cost
	# Clear passive metas
	player.remove_meta(&"passive_crit_bonus")
	player.remove_meta(&"passive_dash_cd_reduction")
	player.remove_meta(&"passive_compute_on_kill")
	player.remove_meta(&"passive_lifesteal_pct")
	player.remove_meta(&"passive_thorns_pct")
	# Clear passive stat bonuses
	var stats: Node = player.get_node_or_null("StatsComponent")
	if stats and stats.has_method(&"clear_passive_bonuses"):
		stats.clear_passive_bonuses()
	# Clear the list (player re-earns them on level-up)
	player.unlocked_passives.clear()
	return true


## Y47: Respec stat points — deducts gold and resets stat allocations.
static func respec_stats(player: Node) -> bool:
	if not "stat_points_allocated" in player:
		return false
	var allocated: int = int(player.get(&"stat_points_allocated"))
	var cost: int = allocated * ProgressionExpansion.RESPEC_STAT_COST_PER_POINT
	if GameManager.player_gold < cost:
		return false
	GameManager.player_gold -= cost
	# Reset stat allocations — implementation depends on StatsComponent
	var stats: Node = player.get_node_or_null("StatsComponent")
	if stats and stats.has_method(&"reset_allocations"):
		stats.reset_allocations()
	return true
