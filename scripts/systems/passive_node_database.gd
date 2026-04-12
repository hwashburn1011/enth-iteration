class_name PassiveNodeDatabase
extends RefCounted
## Phase 3 #26 — V1 passive node database.
##
## A flat list of 12 passive nodes the player unlocks every 3 levels
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
## A 12-node tree gives the player ~36 levels of allocation runway
## before the rotation wraps, which covers the full v1 demo arc.

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
