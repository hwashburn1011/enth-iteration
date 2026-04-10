class_name SkillTreeNodesDatabase
extends RefCounted

## Skill Tree Nodes 26-50 Database (Epic 32 tasks 22, 24, 26).
##
## Hosts the effect data for the late-tree skill nodes (26-50) for all 3
## classes. Nodes 1-25 already exist in an older system. The 26-50 range
## represents the late-game / endgame nodes including:
##   - Keystones (5 per class with major effects)
##   - Hybrid nodes (synergize with multiple existing passives)
##   - Build-defining capstones
##
## Each node entry has:
##   id, label, description, kind (PASSIVE/STAT/KEYSTONE/HYBRID),
##   effect: Dictionary with the actual gameplay numbers,
##   prerequisites: Array[StringName] of node ids that must be allocated first,
##   cost: int (default 1 skill point, keystones cost 3),
##   icon_path: String pointing at the rendered Blender icon
##
## Consumed by the existing SkillTreeManager for allocation, prerequisite
## checking, and effect application via apply_effects_to_player().

const NODE_KIND_PASSIVE: StringName = &"passive"
const NODE_KIND_STAT: StringName = &"stat"
const NODE_KIND_KEYSTONE: StringName = &"keystone"
const NODE_KIND_HYBRID: StringName = &"hybrid"

# === COMPILER nodes 26-50 ===
const COMPILER_NODES: Dictionary = {
	&"compiler_n26": {
		"label": "Optimized Loop", "kind": NODE_KIND_STAT,
		"description": "+8% attack speed",
		"effect": {"stat": &"attack_speed", "delta": 0.08},
		"prereqs": [&"compiler_n22"], "cost": 1,
	},
	&"compiler_n27": {
		"label": "Tail Call", "kind": NODE_KIND_PASSIVE,
		"description": "Killing an enemy refunds 1 second of all cooldowns.",
		"effect": {"on_kill_cooldown_refund": 1.0},
		"prereqs": [&"compiler_n26"], "cost": 1,
	},
	&"compiler_n28": {
		"label": "Constant Folding", "kind": NODE_KIND_STAT,
		"description": "+15% damage on first hit of a combo",
		"effect": {"first_hit_combo_bonus": 0.15},
		"prereqs": [&"compiler_n27"], "cost": 1,
	},
	&"compiler_n29": {
		"label": "Branch Prediction", "kind": NODE_KIND_PASSIVE,
		"description": "After dodging, your next attack auto-crits.",
		"effect": {"dodge_to_crit": true},
		"prereqs": [&"compiler_n28"], "cost": 1,
	},
	&"compiler_n30": {
		"label": "★ KEYSTONE: Recursive Descent", "kind": NODE_KIND_KEYSTONE,
		"description": "Your signature ability casts a second time at 50% power.",
		"effect": {"signature_double_cast": 0.5},
		"prereqs": [&"compiler_n27", &"compiler_n29"], "cost": 3,
	},
	&"compiler_n31": {
		"label": "Inline Expansion", "kind": NODE_KIND_STAT,
		"description": "+10 max HP per allocated node in this branch",
		"effect": {"hp_per_branch_node": 10},
		"prereqs": [&"compiler_n30"], "cost": 1,
	},
	&"compiler_n32": {
		"label": "Stack Frame", "kind": NODE_KIND_PASSIVE,
		"description": "Block damage stores 50% as a charge — release on next strike.",
		"effect": {"block_to_strike_carry": 0.5},
		"prereqs": [&"compiler_n31"], "cost": 1,
	},
	&"compiler_n33": {
		"label": "Pure Function", "kind": NODE_KIND_HYBRID,
		"description": "If untouched for 4 seconds, gain +30% damage on next attack.",
		"effect": {"untouched_window": 4.0, "untouched_bonus": 0.30},
		"prereqs": [&"compiler_n32"], "cost": 1,
	},
	&"compiler_n34": {
		"label": "Type Inference", "kind": NODE_KIND_STAT,
		"description": "+5% to all damage types",
		"effect": {"all_damage_bonus": 0.05},
		"prereqs": [&"compiler_n33"], "cost": 1,
	},
	&"compiler_n35": {
		"label": "★ KEYSTONE: Static Linking", "kind": NODE_KIND_KEYSTONE,
		"description": "Your last 3 abilities chain — each cast adds +20% damage to the next.",
		"effect": {"chain_window": 3.0, "chain_bonus_per_cast": 0.20},
		"prereqs": [&"compiler_n33", &"compiler_n34"], "cost": 3,
	},
	&"compiler_n36": {
		"label": "Hot Path", "kind": NODE_KIND_STAT,
		"description": "+12% movement speed in combat",
		"effect": {"combat_movespeed": 0.12},
		"prereqs": [&"compiler_n35"], "cost": 1,
	},
	&"compiler_n37": {
		"label": "Memoization", "kind": NODE_KIND_PASSIVE,
		"description": "Repeated abilities cost 25% less mana.",
		"effect": {"repeat_cost_reduction": 0.25},
		"prereqs": [&"compiler_n36"], "cost": 1,
	},
	&"compiler_n38": {
		"label": "Higher Order", "kind": NODE_KIND_PASSIVE,
		"description": "Your buffs apply to the nearest ally if any.",
		"effect": {"buff_share_radius": 5.0},
		"prereqs": [&"compiler_n37"], "cost": 1,
	},
	&"compiler_n39": {
		"label": "Lazy Evaluation", "kind": NODE_KIND_PASSIVE,
		"description": "Holding an ability charges it; release for +50% effect.",
		"effect": {"charge_window": 1.5, "charge_bonus": 0.50},
		"prereqs": [&"compiler_n38"], "cost": 1,
	},
	&"compiler_n40": {
		"label": "★ KEYSTONE: Ahead-of-Time", "kind": NODE_KIND_KEYSTONE,
		"description": "Cooldowns start at 1 second instead of full duration after a respec.",
		"effect": {"warm_start_cooldown": 1.0},
		"prereqs": [&"compiler_n39"], "cost": 3,
	},
	&"compiler_n41": {
		"label": "Tail Recursion", "kind": NODE_KIND_PASSIVE,
		"description": "Killing 3 enemies in 6s grants a free signature cast.",
		"effect": {"streak_kills": 3, "streak_window": 6.0, "free_signature": true},
		"prereqs": [&"compiler_n40"], "cost": 1,
	},
	&"compiler_n42": {
		"label": "Garbage Collected", "kind": NODE_KIND_HYBRID,
		"description": "Defeated elites drop a heal packet (+15 HP).",
		"effect": {"elite_heal_drop": 15},
		"prereqs": [&"compiler_n41"], "cost": 1,
	},
	&"compiler_n43": {
		"label": "Optimized Compile", "kind": NODE_KIND_STAT,
		"description": "+20% cooldown reduction on signature",
		"effect": {"signature_cdr": 0.20},
		"prereqs": [&"compiler_n42"], "cost": 1,
	},
	&"compiler_n44": {
		"label": "Cross-Compile", "kind": NODE_KIND_PASSIVE,
		"description": "Switching ability sets refunds half the prior cooldowns.",
		"effect": {"set_swap_refund": 0.5},
		"prereqs": [&"compiler_n43"], "cost": 1,
	},
	&"compiler_n45": {
		"label": "★ KEYSTONE: Just-In-Time", "kind": NODE_KIND_KEYSTONE,
		"description": "Your ultimate cooldown decreases by 1s every time you crit.",
		"effect": {"crit_ult_cdr": 1.0},
		"prereqs": [&"compiler_n44"], "cost": 3,
	},
	&"compiler_n46": {
		"label": "Source Map", "kind": NODE_KIND_PASSIVE,
		"description": "Lore tablets reveal nearby treasure on the minimap.",
		"effect": {"lore_treasure_radar": 12.0},
		"prereqs": [&"compiler_n45"], "cost": 1,
	},
	&"compiler_n47": {
		"label": "Symbol Table", "kind": NODE_KIND_STAT,
		"description": "+1 inventory slot per allocated keystone",
		"effect": {"inv_per_keystone": 1},
		"prereqs": [&"compiler_n46"], "cost": 1,
	},
	&"compiler_n48": {
		"label": "Linker", "kind": NODE_KIND_PASSIVE,
		"description": "Picking up a module immediately equips it if a slot is free.",
		"effect": {"auto_equip_modules": true},
		"prereqs": [&"compiler_n47"], "cost": 1,
	},
	&"compiler_n49": {
		"label": "Compile-Time Check", "kind": NODE_KIND_PASSIVE,
		"description": "Reveals 2 random enemy weaknesses on first sight.",
		"effect": {"reveal_weakness_count": 2},
		"prereqs": [&"compiler_n48"], "cost": 1,
	},
	&"compiler_n50": {
		"label": "★ KEYSTONE: Compile Once Run Forever", "kind": NODE_KIND_KEYSTONE,
		"description": "Your ultimate's effect persists for 8 seconds at half strength.",
		"effect": {"ult_echo_duration": 8.0, "ult_echo_power": 0.50},
		"prereqs": [&"compiler_n49"], "cost": 3,
	},
}

# === DAEMON nodes 26-50 ===
const DAEMON_NODES: Dictionary = {
	&"daemon_n26": {
		"label": "Quick Sprint", "kind": NODE_KIND_STAT,
		"description": "+10% movement speed",
		"effect": {"stat": &"movespeed", "delta": 0.10},
		"prereqs": [&"daemon_n22"], "cost": 1,
	},
	&"daemon_n27": {
		"label": "Vanish", "kind": NODE_KIND_PASSIVE,
		"description": "Dodging grants 0.8s invisibility.",
		"effect": {"dodge_invis": 0.8},
		"prereqs": [&"daemon_n26"], "cost": 1,
	},
	&"daemon_n28": {
		"label": "Bleed", "kind": NODE_KIND_PASSIVE,
		"description": "Crits inflict bleed: 5 damage/sec for 4s.",
		"effect": {"crit_bleed_dps": 5, "crit_bleed_dur": 4.0},
		"prereqs": [&"daemon_n27"], "cost": 1,
	},
	&"daemon_n29": {
		"label": "Stalk", "kind": NODE_KIND_STAT,
		"description": "+25% damage to enemies above 80% HP",
		"effect": {"high_hp_damage_bonus": 0.25, "hp_threshold": 0.80},
		"prereqs": [&"daemon_n28"], "cost": 1,
	},
	&"daemon_n30": {
		"label": "★ KEYSTONE: Twin Strike", "kind": NODE_KIND_KEYSTONE,
		"description": "Your signature hits twice in quick succession.",
		"effect": {"signature_double_hit": true, "second_hit_delay": 0.15},
		"prereqs": [&"daemon_n28", &"daemon_n29"], "cost": 3,
	},
	&"daemon_n31": {
		"label": "Smoke Bomb", "kind": NODE_KIND_PASSIVE,
		"description": "Below 30% HP, you vanish for 2 seconds (60s cooldown).",
		"effect": {"emergency_vanish_threshold": 0.30, "duration": 2.0, "cd": 60.0},
		"prereqs": [&"daemon_n30"], "cost": 1,
	},
	&"daemon_n32": {
		"label": "Bloodscent", "kind": NODE_KIND_PASSIVE,
		"description": "Bleeding enemies appear as red dots on the minimap.",
		"effect": {"bleed_minimap": true},
		"prereqs": [&"daemon_n31"], "cost": 1,
	},
	&"daemon_n33": {
		"label": "Quickdraw", "kind": NODE_KIND_STAT,
		"description": "First attack out of stealth deals +100% damage",
		"effect": {"stealth_first_strike": 1.00},
		"prereqs": [&"daemon_n32"], "cost": 1,
	},
	&"daemon_n34": {
		"label": "Side Step", "kind": NODE_KIND_PASSIVE,
		"description": "Dodging into an enemy attack reflects 30% damage.",
		"effect": {"perfect_dodge_reflect": 0.30},
		"prereqs": [&"daemon_n33"], "cost": 1,
	},
	&"daemon_n35": {
		"label": "★ KEYSTONE: Shadow Fork", "kind": NODE_KIND_KEYSTONE,
		"description": "Your dodge spawns a shadow clone that mimics your next attack.",
		"effect": {"dodge_clone": true, "clone_damage_pct": 0.50},
		"prereqs": [&"daemon_n33", &"daemon_n34"], "cost": 3,
	},
	&"daemon_n36": {
		"label": "Edge Hone", "kind": NODE_KIND_STAT,
		"description": "+10% crit chance",
		"effect": {"stat": &"crit", "delta": 0.10},
		"prereqs": [&"daemon_n35"], "cost": 1,
	},
	&"daemon_n37": {
		"label": "Marked", "kind": NODE_KIND_PASSIVE,
		"description": "Hitting an enemy from behind marks them — next 3 hits crit.",
		"effect": {"mark_window_hits": 3},
		"prereqs": [&"daemon_n36"], "cost": 1,
	},
	&"daemon_n38": {
		"label": "Cull the Weak", "kind": NODE_KIND_PASSIVE,
		"description": "Enemies below 20% HP take +75% damage.",
		"effect": {"low_hp_damage_bonus": 0.75, "hp_threshold": 0.20},
		"prereqs": [&"daemon_n37"], "cost": 1,
	},
	&"daemon_n39": {
		"label": "Lightfoot", "kind": NODE_KIND_PASSIVE,
		"description": "Movement does not interrupt your stealth.",
		"effect": {"stealth_walk": true},
		"prereqs": [&"daemon_n38"], "cost": 1,
	},
	&"daemon_n40": {
		"label": "★ KEYSTONE: Kernel Panic", "kind": NODE_KIND_KEYSTONE,
		"description": "Killing 5 enemies in 4s grants 50% damage for 6s.",
		"effect": {"panic_kills": 5, "panic_window": 4.0, "panic_bonus": 0.50, "panic_dur": 6.0},
		"prereqs": [&"daemon_n39"], "cost": 3,
	},
	&"daemon_n41": {
		"label": "Bleeder", "kind": NODE_KIND_STAT,
		"description": "+50% bleed damage",
		"effect": {"bleed_damage_bonus": 0.50},
		"prereqs": [&"daemon_n40"], "cost": 1,
	},
	&"daemon_n42": {
		"label": "Async Healing", "kind": NODE_KIND_PASSIVE,
		"description": "Killing enemies in stealth restores 8 HP (was 4).",
		"effect": {"stealth_kill_heal": 8},
		"prereqs": [&"daemon_n41"], "cost": 1,
	},
	&"daemon_n43": {
		"label": "Backstab Mastery", "kind": NODE_KIND_STAT,
		"description": "+25% damage from behind (stacks with class passive)",
		"effect": {"backstab_extra": 0.25},
		"prereqs": [&"daemon_n42"], "cost": 1,
	},
	&"daemon_n44": {
		"label": "Perfect Dodge", "kind": NODE_KIND_PASSIVE,
		"description": "Dodging at the last 0.2s window grants invincibility for 1s.",
		"effect": {"perfect_dodge_window": 0.2, "invincibility_dur": 1.0},
		"prereqs": [&"daemon_n43"], "cost": 1,
	},
	&"daemon_n45": {
		"label": "★ KEYSTONE: Multithread", "kind": NODE_KIND_KEYSTONE,
		"description": "Cooldowns tick down 50% faster while in stealth.",
		"effect": {"stealth_cdr_multiplier": 1.5},
		"prereqs": [&"daemon_n44"], "cost": 3,
	},
	&"daemon_n46": {
		"label": "Daemonize", "kind": NODE_KIND_PASSIVE,
		"description": "Combat regen +2 HP/sec while moving.",
		"effect": {"move_regen": 2.0},
		"prereqs": [&"daemon_n45"], "cost": 1,
	},
	&"daemon_n47": {
		"label": "Whisper Blade", "kind": NODE_KIND_PASSIVE,
		"description": "Enemies you've damaged in the last 5s die from any source.",
		"effect": {"contamination_window": 5.0},
		"prereqs": [&"daemon_n46"], "cost": 1,
	},
	&"daemon_n48": {
		"label": "Ghost Step", "kind": NODE_KIND_STAT,
		"description": "+30% dodge distance",
		"effect": {"dodge_distance_bonus": 0.30},
		"prereqs": [&"daemon_n47"], "cost": 1,
	},
	&"daemon_n49": {
		"label": "Two-Pronged", "kind": NODE_KIND_PASSIVE,
		"description": "Dual-wield attacks always alternate; second hit guaranteed crit.",
		"effect": {"alternating_crit": true},
		"prereqs": [&"daemon_n48"], "cost": 1,
	},
	&"daemon_n50": {
		"label": "★ KEYSTONE: Forked Process", "kind": NODE_KIND_KEYSTONE,
		"description": "Your shadow clone now lasts 6 seconds and mirrors all attacks at 75% damage.",
		"effect": {"clone_duration": 6.0, "clone_damage_pct": 0.75},
		"prereqs": [&"daemon_n49"], "cost": 3,
	},
}

# === KERNEL nodes 26-50 ===
const KERNEL_NODES: Dictionary = {
	&"kernel_n26": {
		"label": "Reinforced Plate", "kind": NODE_KIND_STAT,
		"description": "+10% armor",
		"effect": {"stat": &"armor", "delta": 0.10},
		"prereqs": [&"kernel_n22"], "cost": 1,
	},
	&"kernel_n27": {
		"label": "Bulwark", "kind": NODE_KIND_PASSIVE,
		"description": "Standing still 2s grants a 25 HP shield.",
		"effect": {"stand_shield": 25, "stand_window": 2.0},
		"prereqs": [&"kernel_n26"], "cost": 1,
	},
	&"kernel_n28": {
		"label": "Deflection", "kind": NODE_KIND_PASSIVE,
		"description": "Blocked attacks reflect 15 damage to attackers.",
		"effect": {"block_reflect": 15},
		"prereqs": [&"kernel_n27"], "cost": 1,
	},
	&"kernel_n29": {
		"label": "Heavy Footing", "kind": NODE_KIND_PASSIVE,
		"description": "You cannot be pushed or knocked down.",
		"effect": {"cc_immune": true},
		"prereqs": [&"kernel_n28"], "cost": 1,
	},
	&"kernel_n30": {
		"label": "★ KEYSTONE: Fortify", "kind": NODE_KIND_KEYSTONE,
		"description": "Your signature grants 30% damage reduction for 6s.",
		"effect": {"signature_dr_dur": 6.0, "signature_dr": 0.30},
		"prereqs": [&"kernel_n28", &"kernel_n29"], "cost": 3,
	},
	&"kernel_n31": {
		"label": "Taunt Aura", "kind": NODE_KIND_PASSIVE,
		"description": "Enemies within 4m prefer attacking you.",
		"effect": {"taunt_radius": 4.0},
		"prereqs": [&"kernel_n30"], "cost": 1,
	},
	&"kernel_n32": {
		"label": "Iron Will", "kind": NODE_KIND_PASSIVE,
		"description": "Below 25% HP, gain +40% damage reduction.",
		"effect": {"low_hp_dr_threshold": 0.25, "low_hp_dr": 0.40},
		"prereqs": [&"kernel_n31"], "cost": 1,
	},
	&"kernel_n33": {
		"label": "Counter", "kind": NODE_KIND_PASSIVE,
		"description": "Perfect blocks deal 50 damage to attacker.",
		"effect": {"perfect_block_damage": 50},
		"prereqs": [&"kernel_n32"], "cost": 1,
	},
	&"kernel_n34": {
		"label": "Anchored", "kind": NODE_KIND_STAT,
		"description": "+20 max HP",
		"effect": {"stat": &"max_hp", "delta": 20},
		"prereqs": [&"kernel_n33"], "cost": 1,
	},
	&"kernel_n35": {
		"label": "★ KEYSTONE: Supervisor", "kind": NODE_KIND_KEYSTONE,
		"description": "Allies within 8m take 25% less damage.",
		"effect": {"ally_dr_radius": 8.0, "ally_dr": 0.25},
		"prereqs": [&"kernel_n33", &"kernel_n34"], "cost": 3,
	},
	&"kernel_n36": {
		"label": "Steady Hand", "kind": NODE_KIND_STAT,
		"description": "+8% block window",
		"effect": {"block_window_bonus": 0.08},
		"prereqs": [&"kernel_n35"], "cost": 1,
	},
	&"kernel_n37": {
		"label": "Last Stand", "kind": NODE_KIND_PASSIVE,
		"description": "Lethal damage leaves you at 1 HP (90s cooldown).",
		"effect": {"last_stand_cd": 90.0},
		"prereqs": [&"kernel_n36"], "cost": 1,
	},
	&"kernel_n38": {
		"label": "Unbroken", "kind": NODE_KIND_PASSIVE,
		"description": "Status effects last 50% less time on you.",
		"effect": {"status_resist": 0.50},
		"prereqs": [&"kernel_n37"], "cost": 1,
	},
	&"kernel_n39": {
		"label": "Shockwave", "kind": NODE_KIND_PASSIVE,
		"description": "Blocking releases a knockback wave.",
		"effect": {"block_knockback_radius": 3.0},
		"prereqs": [&"kernel_n38"], "cost": 1,
	},
	&"kernel_n40": {
		"label": "★ KEYSTONE: System Call", "kind": NODE_KIND_KEYSTONE,
		"description": "Your ultimate makes you and nearby allies invincible for 4s.",
		"effect": {"invincibility_radius": 8.0, "invincibility_dur": 4.0},
		"prereqs": [&"kernel_n39"], "cost": 3,
	},
	&"kernel_n41": {
		"label": "Stout", "kind": NODE_KIND_STAT,
		"description": "+30 max HP",
		"effect": {"stat": &"max_hp", "delta": 30},
		"prereqs": [&"kernel_n40"], "cost": 1,
	},
	&"kernel_n42": {
		"label": "Healing Aura", "kind": NODE_KIND_PASSIVE,
		"description": "+1 HP/sec to all allies within 5m.",
		"effect": {"aura_regen": 1, "aura_radius": 5.0},
		"prereqs": [&"kernel_n41"], "cost": 1,
	},
	&"kernel_n43": {
		"label": "Wide Block", "kind": NODE_KIND_PASSIVE,
		"description": "Block now covers 180° instead of 120°.",
		"effect": {"block_cone": 180.0},
		"prereqs": [&"kernel_n42"], "cost": 1,
	},
	&"kernel_n44": {
		"label": "Earthen", "kind": NODE_KIND_PASSIVE,
		"description": "Standing on earth (not metal/glass) grants +5% all stats.",
		"effect": {"earth_bonus": 0.05},
		"prereqs": [&"kernel_n43"], "cost": 1,
	},
	&"kernel_n45": {
		"label": "★ KEYSTONE: Cluster", "kind": NODE_KIND_KEYSTONE,
		"description": "Your taunt aura now boosts ally damage by 15%.",
		"effect": {"taunt_buff_radius": 4.0, "taunt_dmg_bonus": 0.15},
		"prereqs": [&"kernel_n44"], "cost": 3,
	},
	&"kernel_n46": {
		"label": "Patient", "kind": NODE_KIND_PASSIVE,
		"description": "Cooldowns tick 25% faster while not moving.",
		"effect": {"still_cdr": 0.25},
		"prereqs": [&"kernel_n45"], "cost": 1,
	},
	&"kernel_n47": {
		"label": "Stalwart", "kind": NODE_KIND_STAT,
		"description": "+15% all defenses",
		"effect": {"all_defense_bonus": 0.15},
		"prereqs": [&"kernel_n46"], "cost": 1,
	},
	&"kernel_n48": {
		"label": "Mountain", "kind": NODE_KIND_PASSIVE,
		"description": "Damage taken below 5 is reduced to 1.",
		"effect": {"chip_floor": 5},
		"prereqs": [&"kernel_n47"], "cost": 1,
	},
	&"kernel_n49": {
		"label": "Echoing Bulwark", "kind": NODE_KIND_PASSIVE,
		"description": "Your bulwark shield refreshes when broken (60s cd).",
		"effect": {"bulwark_refresh_cd": 60.0},
		"prereqs": [&"kernel_n48"], "cost": 1,
	},
	&"kernel_n50": {
		"label": "★ KEYSTONE: Immovable Object", "kind": NODE_KIND_KEYSTONE,
		"description": "While blocking you take no damage from any source for the first 3s.",
		"effect": {"perfect_block_window": 3.0},
		"prereqs": [&"kernel_n49"], "cost": 3,
	},
}

const ALL_NODES_BY_CLASS: Dictionary = {
	&"compiler": COMPILER_NODES,
	&"daemon": DAEMON_NODES,
	&"kernel": KERNEL_NODES,
}


static func get_node(class_id: StringName, node_id: StringName) -> Dictionary:
	var nodes: Dictionary = ALL_NODES_BY_CLASS.get(class_id, {})
	return nodes.get(node_id, {}).duplicate(true)


static func get_all_nodes_for_class(class_id: StringName) -> Dictionary:
	return ALL_NODES_BY_CLASS.get(class_id, {}).duplicate(true)


static func get_keystones_for_class(class_id: StringName) -> Array[StringName]:
	var nodes: Dictionary = ALL_NODES_BY_CLASS.get(class_id, {})
	var keystones: Array[StringName] = []
	for node_id in nodes.keys():
		var n: Dictionary = nodes[node_id]
		if n.get("kind", &"") == NODE_KIND_KEYSTONE:
			keystones.append(node_id)
	return keystones


static func validate_prereqs(class_id: StringName, node_id: StringName, allocated: Array) -> bool:
	var node: Dictionary = get_node(class_id, node_id)
	if node.is_empty():
		return false
	for prereq: StringName in node.get("prereqs", []):
		if not allocated.has(prereq):
			return false
	return true


static func compute_total_cost(class_id: StringName, node_ids: Array) -> int:
	var total: int = 0
	for node_id: StringName in node_ids:
		var node: Dictionary = get_node(class_id, node_id)
		total += int(node.get("cost", 1))
	return total


## Validates the node math doesn't break balance (Epic 32 task 29).
## Returns a report dict with detected issues.
static func validate_balance() -> Dictionary:
	var report: Dictionary = {"issues": [], "warnings": [], "node_counts": {}}
	for class_id in ALL_NODES_BY_CLASS.keys():
		var nodes: Dictionary = ALL_NODES_BY_CLASS[class_id]
		report["node_counts"][class_id] = nodes.size()
		# Check that every class has 25 nodes (26-50)
		if nodes.size() != 25:
			report["issues"].append("%s has %d nodes, expected 25" % [class_id, nodes.size()])
		# Check that every keystone costs 3
		for node_id in nodes.keys():
			var node: Dictionary = nodes[node_id]
			if node.get("kind", &"") == NODE_KIND_KEYSTONE and int(node.get("cost", 1)) != 3:
				report["warnings"].append("%s/%s keystone has cost %d, expected 3" % [class_id, node_id, node.get("cost", 1)])
		# Check 5 keystones per class
		var keystones: Array[StringName] = get_keystones_for_class(class_id)
		if keystones.size() != 5:
			report["issues"].append("%s has %d keystones, expected 5" % [class_id, keystones.size()])
	return report
