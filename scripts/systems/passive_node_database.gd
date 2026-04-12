class_name PassiveNodeDatabase
extends RefCounted
## Phase 3 #26 — V1 passive node database.
##
## A flat list of 24 passive nodes the player unlocks every 3 levels
## (level 3, 6, 9, 12, etc.). Each node has:
##
##   id          — stable string for save/load
##   name        — display label
##   description — one-line tooltip
##   effect_type — "stat" | "crit" | "dash_cd" | "compute_kill"
##   effect_key  — for "stat", the stat name; otherwise unused
##   amount      — magnitude
##
## The "stat" type adds to stats_component.passive_bonuses (a new
## dict parallel to equipment_bonuses, summed inside get_stat).
## The other 3 types are read by their respective consumers via
## player metas (passive_crit_bonus, passive_dash_cd_reduction,
## passive_compute_on_kill) — same pattern as the T28 core hooks.
##
## ORDER MATTERS: PassiveProgression rotates through this list in
## order so the first node a new player unlocks is always reproducible
## (Reinforced Hull at level 3, then Quick Cycle at level 6, etc.).
## R3 M21: expanded to 24 nodes with new effect types (lifesteal, thorns).
## A 24-node tree gives ~72 levels of allocation runway before wrapping.

const NODES: Array[Dictionary] = [
	{
		"id": "reinforced_hull",
		"name": "Reinforced Hull",
		"description": "+3 Integrity",
		"effect_type": "stat",
		"effect_key": "integrity",
		"amount": 3.0,
	},
	{
		"id": "quick_cycle",
		"name": "Quick Cycle",
		"description": "+3 Bandwidth",
		"effect_type": "stat",
		"effect_key": "bandwidth",
		"amount": 3.0,
	},
	{
		"id": "deep_cache",
		"name": "Deep Cache",
		"description": "+3 Memory",
		"effect_type": "stat",
		"effect_key": "memory",
		"amount": 3.0,
	},
	{
		"id": "sharper_edge",
		"name": "Sharper Edge",
		"description": "+3 Processing",
		"effect_type": "stat",
		"effect_key": "processing",
		"amount": 3.0,
	},
	{
		"id": "killing_edge",
		"name": "Killing Edge",
		"description": "+5% Critical Hit Chance",
		"effect_type": "crit",
		"effect_key": "",
		"amount": 5.0,
	},
	{
		"id": "combat_reflexes",
		"name": "Combat Reflexes",
		"description": "Dash cooldown −0.2s",
		"effect_type": "dash_cd",
		"effect_key": "",
		"amount": 0.2,
	},
	{
		"id": "volatile_spark",
		"name": "Volatile Spark",
		"description": "Restore 4 Compute on kill",
		"effect_type": "compute_kill",
		"effect_key": "",
		"amount": 4.0,
	},
	{
		"id": "hardened_plating",
		"name": "Hardened Plating",
		"description": "+5 Integrity",
		"effect_type": "stat",
		"effect_key": "integrity",
		"amount": 5.0,
	},
	{
		"id": "compute_surge",
		"name": "Compute Surge",
		"description": "+5 Bandwidth",
		"effect_type": "stat",
		"effect_key": "bandwidth",
		"amount": 5.0,
	},
	{
		"id": "memory_crystal",
		"name": "Memory Crystal",
		"description": "+5 Memory",
		"effect_type": "stat",
		"effect_key": "memory",
		"amount": 5.0,
	},
	{
		"id": "optimized_loop",
		"name": "Optimized Loop",
		"description": "+5 Processing",
		"effect_type": "stat",
		"effect_key": "processing",
		"amount": 5.0,
	},
	{
		"id": "killing_edge_2",
		"name": "Killing Edge II",
		"description": "+5% Critical Hit Chance",
		"effect_type": "crit",
		"effect_key": "",
		"amount": 5.0,
	},
	# --- R3 M21: 12 new nodes (13-24) with lifesteal and thorns ---
	{
		"id": "data_siphon",
		"name": "Data Siphon",
		"description": "Heal 3% of damage dealt",
		"effect_type": "lifesteal",
		"effect_key": "",
		"amount": 3.0,
	},
	{
		"id": "thorned_firewall",
		"name": "Thorned Firewall",
		"description": "Reflect 8% damage to attackers",
		"effect_type": "thorns",
		"effect_key": "",
		"amount": 8.0,
	},
	{
		"id": "overclocked_hull",
		"name": "Overclocked Hull",
		"description": "+8 Integrity",
		"effect_type": "stat",
		"effect_key": "integrity",
		"amount": 8.0,
	},
	{
		"id": "turbo_bandwidth",
		"name": "Turbo Bandwidth",
		"description": "+8 Bandwidth",
		"effect_type": "stat",
		"effect_key": "bandwidth",
		"amount": 8.0,
	},
	{
		"id": "expanded_memory",
		"name": "Expanded Memory",
		"description": "+8 Memory",
		"effect_type": "stat",
		"effect_key": "memory",
		"amount": 8.0,
	},
	{
		"id": "neural_accelerator",
		"name": "Neural Accelerator",
		"description": "+8 Processing",
		"effect_type": "stat",
		"effect_key": "processing",
		"amount": 8.0,
	},
	{
		"id": "killing_edge_3",
		"name": "Killing Edge III",
		"description": "+8% Critical Hit Chance",
		"effect_type": "crit",
		"effect_key": "",
		"amount": 8.0,
	},
	{
		"id": "combat_mastery",
		"name": "Combat Mastery",
		"description": "Dash cooldown −0.4s",
		"effect_type": "dash_cd",
		"effect_key": "",
		"amount": 0.4,
	},
	{
		"id": "recursive_siphon",
		"name": "Recursive Siphon",
		"description": "Restore 8 Compute on kill",
		"effect_type": "compute_kill",
		"effect_key": "",
		"amount": 8.0,
	},
	{
		"id": "vampiric_code",
		"name": "Vampiric Code",
		"description": "Heal 5% of damage dealt",
		"effect_type": "lifesteal",
		"effect_key": "",
		"amount": 5.0,
	},
	{
		"id": "razor_firewall",
		"name": "Razor Firewall",
		"description": "Reflect 15% damage to attackers",
		"effect_type": "thorns",
		"effect_key": "",
		"amount": 15.0,
	},
	{
		"id": "final_optimization",
		"name": "Final Optimization",
		"description": "+10 to all stats",
		"effect_type": "stat",
		"effect_key": "all",
		"amount": 10.0,
	},
]


## Returns the node dict for a given id, or {} if not found.
static func get_by_id(node_id: String) -> Dictionary:
	for n: Dictionary in NODES:
		if n["id"] == node_id:
			return n
	return {}


## Returns the node id at the given rotation index. Wraps around
## NODES.size() so the player keeps unlocking nodes past the
## natural end of the rotation (each repeat is a duplicate stack).
static func get_id_at_index(idx: int) -> String:
	if NODES.is_empty():
		return ""
	return NODES[idx % NODES.size()]["id"]
