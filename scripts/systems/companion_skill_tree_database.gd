class_name CompanionSkillTreeDatabase
extends RefCounted

## Companion Skill Tree Database (Epic 40 task 19).
##
## 60 skill nodes total — 15 nodes per companion (Tank/DPS/Healer/Utility).
## Each node has: id, label, kind (passive/stat/keystone), description,
## effect dict, prereqs, cost.
##
## Trees are intentionally smaller than the player's 50-node tree because
## companions are secondary characters with focused roles.

const TANK_NODES: Dictionary = {
	&"tank_n01": {"label": "Iron Hide", "kind": &"stat", "description": "+15% armor", "effect": {"armor": 0.15}, "prereqs": [], "cost": 1},
	&"tank_n02": {"label": "Stand Firm", "kind": &"passive", "description": "Cannot be knocked back", "effect": {"cc_immune_knockback": true}, "prereqs": [&"tank_n01"], "cost": 1},
	&"tank_n03": {"label": "Bulwark", "kind": &"stat", "description": "+25 max HP", "effect": {"max_hp": 25}, "prereqs": [&"tank_n02"], "cost": 1},
	&"tank_n04": {"label": "Provoke", "kind": &"passive", "description": "Taunts nearby enemies on damage taken", "effect": {"taunt_radius": 4.0}, "prereqs": [&"tank_n03"], "cost": 1},
	&"tank_n05": {"label": "★ Wall of Iron", "kind": &"keystone", "description": "Take 30% less damage while blocking", "effect": {"block_dr": 0.30}, "prereqs": [&"tank_n02", &"tank_n04"], "cost": 3},
	&"tank_n06": {"label": "Heavy Footing", "kind": &"stat", "description": "+10% melee damage", "effect": {"melee_damage": 0.10}, "prereqs": [&"tank_n05"], "cost": 1},
	&"tank_n07": {"label": "Counter Blow", "kind": &"passive", "description": "Perfect block deals 20 damage", "effect": {"block_reflect": 20}, "prereqs": [&"tank_n06"], "cost": 1},
	&"tank_n08": {"label": "Earthen", "kind": &"stat", "description": "+15% defense", "effect": {"defense": 0.15}, "prereqs": [&"tank_n07"], "cost": 1},
	&"tank_n09": {"label": "Last Stand", "kind": &"passive", "description": "Below 25% HP, gain 50% damage reduction", "effect": {"low_hp_dr": 0.50}, "prereqs": [&"tank_n08"], "cost": 1},
	&"tank_n10": {"label": "★ Immovable", "kind": &"keystone", "description": "Cannot be CC'd while at full HP", "effect": {"full_hp_cc_immune": true}, "prereqs": [&"tank_n09"], "cost": 3},
	&"tank_n11": {"label": "Anchor", "kind": &"stat", "description": "+30 max HP", "effect": {"max_hp": 30}, "prereqs": [&"tank_n10"], "cost": 1},
	&"tank_n12": {"label": "Aura of Steel", "kind": &"passive", "description": "Allies within 5m gain +10% armor", "effect": {"aura_armor": 0.10, "aura_radius": 5.0}, "prereqs": [&"tank_n11"], "cost": 1},
	&"tank_n13": {"label": "Vanguard", "kind": &"stat", "description": "+20% block window", "effect": {"block_window": 0.20}, "prereqs": [&"tank_n12"], "cost": 1},
	&"tank_n14": {"label": "Resolute", "kind": &"passive", "description": "Status effects last 50% less", "effect": {"status_resist": 0.50}, "prereqs": [&"tank_n13"], "cost": 1},
	&"tank_n15": {"label": "★ Mountain", "kind": &"keystone", "description": "Damage below 5 reduced to 1", "effect": {"chip_floor": 5}, "prereqs": [&"tank_n14"], "cost": 3},
}

const DPS_NODES: Dictionary = {
	&"dps_n01": {"label": "Steady Aim", "kind": &"stat", "description": "+10% ranged damage", "effect": {"ranged_damage": 0.10}, "prereqs": [], "cost": 1},
	&"dps_n02": {"label": "Quick Reload", "kind": &"passive", "description": "Reload 25% faster", "effect": {"reload_speed": 0.25}, "prereqs": [&"dps_n01"], "cost": 1},
	&"dps_n03": {"label": "Marksman", "kind": &"stat", "description": "+10% crit chance", "effect": {"crit_chance": 0.10}, "prereqs": [&"dps_n02"], "cost": 1},
	&"dps_n04": {"label": "Headshot", "kind": &"passive", "description": "Crits deal +50% damage", "effect": {"crit_damage": 0.50}, "prereqs": [&"dps_n03"], "cost": 1},
	&"dps_n05": {"label": "★ Sniper", "kind": &"keystone", "description": "First shot from stealth always crits", "effect": {"stealth_first_crit": true}, "prereqs": [&"dps_n03", &"dps_n04"], "cost": 3},
	&"dps_n06": {"label": "Eagle Eye", "kind": &"stat", "description": "+25% range", "effect": {"range": 0.25}, "prereqs": [&"dps_n05"], "cost": 1},
	&"dps_n07": {"label": "Flanker", "kind": &"passive", "description": "+30% damage from behind", "effect": {"flank_damage": 0.30}, "prereqs": [&"dps_n06"], "cost": 1},
	&"dps_n08": {"label": "Killer Instinct", "kind": &"stat", "description": "+15% damage to enemies below 30% HP", "effect": {"execute_bonus": 0.15}, "prereqs": [&"dps_n07"], "cost": 1},
	&"dps_n09": {"label": "Trick Shot", "kind": &"passive", "description": "Crits ricochet to nearby enemy", "effect": {"crit_ricochet": true}, "prereqs": [&"dps_n08"], "cost": 1},
	&"dps_n10": {"label": "★ Dead Eye", "kind": &"keystone", "description": "All shots crit while standing still", "effect": {"stationary_crit": true}, "prereqs": [&"dps_n09"], "cost": 3},
	&"dps_n11": {"label": "Burst Fire", "kind": &"passive", "description": "Every 3rd shot fires 2 bullets", "effect": {"burst_every_3": true}, "prereqs": [&"dps_n10"], "cost": 1},
	&"dps_n12": {"label": "Coup de Grâce", "kind": &"passive", "description": "Killing an enemy refunds 25% of last cooldown", "effect": {"on_kill_cdr": 0.25}, "prereqs": [&"dps_n11"], "cost": 1},
	&"dps_n13": {"label": "Sharpshooter", "kind": &"stat", "description": "+15% crit chance", "effect": {"crit_chance": 0.15}, "prereqs": [&"dps_n12"], "cost": 1},
	&"dps_n14": {"label": "Adrenaline", "kind": &"passive", "description": "After 3 kills in 5s, +30% attack speed for 5s", "effect": {"adrenaline_window": 5.0, "adrenaline_buff": 0.30}, "prereqs": [&"dps_n13"], "cost": 1},
	&"dps_n15": {"label": "★ Apex Hunter", "kind": &"keystone", "description": "Crit damage doubled below 50% HP", "effect": {"low_hp_crit_damage": 1.0}, "prereqs": [&"dps_n14"], "cost": 3},
}

const HEALER_NODES: Dictionary = {
	&"healer_n01": {"label": "Caring Touch", "kind": &"stat", "description": "+15% healing power", "effect": {"healing_power": 0.15}, "prereqs": [], "cost": 1},
	&"healer_n02": {"label": "Renewal", "kind": &"passive", "description": "Heal 2 HP/sec to nearest ally", "effect": {"hot_value": 2}, "prereqs": [&"healer_n01"], "cost": 1},
	&"healer_n03": {"label": "Cleanse", "kind": &"passive", "description": "Healing also removes 1 debuff", "effect": {"heal_cleanse_count": 1}, "prereqs": [&"healer_n02"], "cost": 1},
	&"healer_n04": {"label": "Ward", "kind": &"passive", "description": "Healing also grants a 10 HP shield", "effect": {"heal_shield": 10}, "prereqs": [&"healer_n03"], "cost": 1},
	&"healer_n05": {"label": "★ Soothing Aura", "kind": &"keystone", "description": "Allies within 8m gain 1 HP/sec", "effect": {"aura_regen": 1, "aura_radius": 8.0}, "prereqs": [&"healer_n02", &"healer_n04"], "cost": 3},
	&"healer_n06": {"label": "Mana Pool", "kind": &"stat", "description": "+30 max mana", "effect": {"max_mana": 30}, "prereqs": [&"healer_n05"], "cost": 1},
	&"healer_n07": {"label": "Quick Cast", "kind": &"stat", "description": "-15% spell cast time", "effect": {"cast_speed": 0.15}, "prereqs": [&"healer_n06"], "cost": 1},
	&"healer_n08": {"label": "Echo", "kind": &"passive", "description": "Heals echo at 30% potency 1s later", "effect": {"echo_pct": 0.30, "echo_delay": 1.0}, "prereqs": [&"healer_n07"], "cost": 1},
	&"healer_n09": {"label": "Sanctuary", "kind": &"passive", "description": "Standing still grants +20% healing", "effect": {"still_heal_bonus": 0.20}, "prereqs": [&"healer_n08"], "cost": 1},
	&"healer_n10": {"label": "★ Lifebloom", "kind": &"keystone", "description": "Critical heals double in value", "effect": {"crit_heal_multiplier": 2.0}, "prereqs": [&"healer_n09"], "cost": 3},
	&"healer_n11": {"label": "Resurrection", "kind": &"passive", "description": "Revive once per dungeon at 50% HP", "effect": {"self_revive_pct": 0.50}, "prereqs": [&"healer_n10"], "cost": 1},
	&"healer_n12": {"label": "Healing Wisdom", "kind": &"stat", "description": "+15% healing power", "effect": {"healing_power": 0.15}, "prereqs": [&"healer_n11"], "cost": 1},
	&"healer_n13": {"label": "Mass Heal", "kind": &"passive", "description": "Healing splashes to 1 nearby ally", "effect": {"heal_splash": 1}, "prereqs": [&"healer_n12"], "cost": 1},
	&"healer_n14": {"label": "Empathy", "kind": &"passive", "description": "Healing grants 1 mana per heal", "effect": {"heal_mana_refund": 1}, "prereqs": [&"healer_n13"], "cost": 1},
	&"healer_n15": {"label": "★ Eternal Vigil", "kind": &"keystone", "description": "Allies below 25% HP gain double heals", "effect": {"low_hp_heal_multi": 2.0}, "prereqs": [&"healer_n14"], "cost": 3},
}

const UTILITY_NODES: Dictionary = {
	&"utility_n01": {"label": "Slow Touch", "kind": &"passive", "description": "Hits apply 20% slow for 2s", "effect": {"slow_pct": 0.20, "slow_dur": 2.0}, "prereqs": [], "cost": 1},
	&"utility_n02": {"label": "Stun Capacity", "kind": &"stat", "description": "+50% stun duration", "effect": {"stun_duration": 0.50}, "prereqs": [&"utility_n01"], "cost": 1},
	&"utility_n03": {"label": "Disrupt", "kind": &"passive", "description": "Stuns interrupt enemy abilities", "effect": {"stun_interrupts": true}, "prereqs": [&"utility_n02"], "cost": 1},
	&"utility_n04": {"label": "Hex", "kind": &"passive", "description": "Hits apply -10% damage taken to enemies", "effect": {"hex_damage_in": 0.10}, "prereqs": [&"utility_n03"], "cost": 1},
	&"utility_n05": {"label": "★ Crowd Control", "kind": &"keystone", "description": "All CC durations +30%", "effect": {"all_cc_dur": 0.30}, "prereqs": [&"utility_n03", &"utility_n04"], "cost": 3},
	&"utility_n06": {"label": "Trickster", "kind": &"passive", "description": "Slowed enemies take +15% damage", "effect": {"slow_damage_bonus": 0.15}, "prereqs": [&"utility_n05"], "cost": 1},
	&"utility_n07": {"label": "Distort", "kind": &"passive", "description": "Enemies near you have 10% miss chance", "effect": {"enemy_miss": 0.10, "miss_radius": 6.0}, "prereqs": [&"utility_n06"], "cost": 1},
	&"utility_n08": {"label": "Bind", "kind": &"passive", "description": "Stuns also root enemies", "effect": {"stun_root": true}, "prereqs": [&"utility_n07"], "cost": 1},
	&"utility_n09": {"label": "Mark", "kind": &"passive", "description": "Hits mark enemies; marked take +20% from allies", "effect": {"mark_damage": 0.20}, "prereqs": [&"utility_n08"], "cost": 1},
	&"utility_n10": {"label": "★ Web", "kind": &"keystone", "description": "Slows chain to 2 nearby enemies", "effect": {"slow_chain_count": 2}, "prereqs": [&"utility_n09"], "cost": 3},
	&"utility_n11": {"label": "Mirage", "kind": &"passive", "description": "Spawn 1 decoy on ability use", "effect": {"decoy_count": 1}, "prereqs": [&"utility_n10"], "cost": 1},
	&"utility_n12": {"label": "Polymorph", "kind": &"passive", "description": "Stuns become polymorphs", "effect": {"stun_to_polymorph": true}, "prereqs": [&"utility_n11"], "cost": 1},
	&"utility_n13": {"label": "Knowledge", "kind": &"stat", "description": "+15% all CC durations", "effect": {"all_cc_dur": 0.15}, "prereqs": [&"utility_n12"], "cost": 1},
	&"utility_n14": {"label": "Curse", "kind": &"passive", "description": "Hits stack curse: -2% damage per stack", "effect": {"curse_per_stack": 0.02, "max_stacks": 5}, "prereqs": [&"utility_n13"], "cost": 1},
	&"utility_n15": {"label": "★ Master of Hexes", "kind": &"keystone", "description": "All debuffs last 2x as long", "effect": {"debuff_duration": 1.0}, "prereqs": [&"utility_n14"], "cost": 3},
}

const ALL_NODES_BY_COMPANION: Dictionary = {
	&"tank": TANK_NODES,
	&"dps": DPS_NODES,
	&"healer": HEALER_NODES,
	&"utility": UTILITY_NODES,
}


static func get_node(companion_id: StringName, node_id: StringName) -> Dictionary:
	var nodes: Dictionary = ALL_NODES_BY_COMPANION.get(companion_id, {})
	return nodes.get(node_id, {}).duplicate(true)


static func get_all_nodes_for_companion(companion_id: StringName) -> Dictionary:
	return ALL_NODES_BY_COMPANION.get(companion_id, {}).duplicate(true)


static func get_keystones_for_companion(companion_id: StringName) -> Array[StringName]:
	var nodes: Dictionary = ALL_NODES_BY_COMPANION.get(companion_id, {})
	var keystones: Array[StringName] = []
	for node_id in nodes.keys():
		if nodes[node_id].get("kind", &"") == &"keystone":
			keystones.append(node_id)
	return keystones


static func validate_prereqs(companion_id: StringName, node_id: StringName, allocated: Array) -> bool:
	var node: Dictionary = get_node(companion_id, node_id)
	if node.is_empty():
		return false
	for prereq: StringName in node.get("prereqs", []):
		if not allocated.has(prereq):
			return false
	return true


static func get_summary() -> Dictionary:
	return {
		"tank_count": TANK_NODES.size(),
		"dps_count": DPS_NODES.size(),
		"healer_count": HEALER_NODES.size(),
		"utility_count": UTILITY_NODES.size(),
		"total": TANK_NODES.size() + DPS_NODES.size() + HEALER_NODES.size() + UTILITY_NODES.size(),
	}
