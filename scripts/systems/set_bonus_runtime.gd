class_name SetBonusRuntime
extends RefCounted
## R5 Epic V — Equipment set bonus runtime application.
##
## V11-V16: Apply set bonuses at equip time
## V17-V19: Tier 2 item integration
## V20: Set bonus tooltip


## V11: Check and apply all active set bonuses to the player.
## Called from EquipmentComponent after any equip/unequip.
static func apply_set_bonuses(player: Node, equipped_ids: Array[String]) -> void:
	# Clear previous set bonuses
	_clear_set_bonuses(player)
	var bonuses: Array[Dictionary] = ProgressionExpansion.get_active_bonuses(equipped_ids)
	for bonus: Dictionary in bonuses:
		_apply_single_bonus(player, bonus)


## Clear all set bonus effects from the player.
static func _clear_set_bonuses(player: Node) -> void:
	player.remove_meta(&"set_bonus_crit")
	player.remove_meta(&"set_bonus_thorns")
	player.remove_meta(&"set_bonus_move_speed")
	player.remove_meta(&"set_bonus_dash_reset_on_kill")
	# V12: Clear stat bonuses
	var stats: Node = player.get_node_or_null("StatsComponent")
	if stats and stats.has_method(&"remove_set_bonuses"):
		stats.remove_set_bonuses()


## Apply a single set bonus effect.
static func _apply_single_bonus(player: Node, bonus: Dictionary) -> void:
	var effect: String = str(bonus.get("effect", ""))
	var amount: float = float(bonus.get("amount", 0.0))
	match effect:
		"stat":
			# V12: Add stat bonus
			var key: String = str(bonus.get("key", ""))
			var stats: Node = player.get_node_or_null("StatsComponent")
			if key != "" and stats and stats.has_method(&"add_set_bonus"):
				stats.add_set_bonus(key, amount)
		"crit":
			# V13: Add crit chance
			player.set_meta(&"set_bonus_crit", amount)
		"thorns":
			# V14: Add thorns reflect
			var existing: float = float(player.get_meta(&"passive_thorns_pct", 0.0))
			player.set_meta(&"passive_thorns_pct", existing + amount)
		"move_speed":
			# V15: Modify move speed
			player.set_meta(&"set_bonus_move_speed", amount)
		"ability_damage":
			# Compiler Suite 3-piece: +25% ability damage
			player.set_meta(&"set_bonus_ability_damage", amount)
		"dash_reset_on_kill":
			# V16: Speed Daemon 3-piece: dash resets on kill
			player.set_meta(&"set_bonus_dash_reset_on_kill", true)


## V17: Check if an item_id is a tier 2 item from ProgressionExpansion.
static func is_tier2_item(item_id: String) -> bool:
	for entry: Dictionary in ProgressionExpansion.TIER2_MODULES:
		if str(entry.get("item_id", "")) == item_id:
			return true
	for entry: Dictionary in ProgressionExpansion.TIER2_CORES:
		if str(entry.get("item_id", "")) == item_id:
			return true
	for entry: Dictionary in ProgressionExpansion.TIER2_CHIPS:
		if str(entry.get("item_id", "")) == item_id:
			return true
	return false


## V20: Get tooltip text for active set bonuses.
static func get_set_tooltip(equipped_ids: Array[String]) -> String:
	var lines: PackedStringArray = PackedStringArray()
	for set_id: String in ProgressionExpansion.EQUIPMENT_SETS:
		var count: int = ProgressionExpansion.count_set_matches(set_id, equipped_ids)
		if count >= 2:
			var set_data: Dictionary = ProgressionExpansion.EQUIPMENT_SETS[set_id] as Dictionary
			var name: String = str(set_data.get("name", set_id))
			lines.append("[%s] %d/3" % [name, count])
			if count >= 2 and "bonus_2" in set_data:
				lines.append("  (2) %s" % str((set_data["bonus_2"] as Dictionary).get("description", "")))
			if count >= 3 and "bonus_3" in set_data:
				lines.append("  (3) %s" % str((set_data["bonus_3"] as Dictionary).get("description", "")))
	return "\n".join(lines)
