class_name SkillTreeFactory
extends RefCounted

## Builds the 3 class skill trees in code (50 nodes each = 150 nodes total).
## Lets us define the trees declaratively without authoring 150 .tres files
## by hand. Trees can still be exported to .tres after construction if needed.
##
## Topology: hub-and-spoke per discipline. Each class has 3 disciplines
## radiating from a central root, with 5 keystones gating major build choices.

const COMPILER_NODES: Array = [
	# === ROOT ===
	{"id": &"comp_root", "name": "Compile", "x": 0, "y": 0, "prereq": [], "cost": 1, "max": 1, "key": false,
	 "fx": [{"type": &"stat_add", "params": {"stat": &"max_compute", "amount": 10}}],
	 "desc": "Begin your compilation. +10 max compute."},

	# === BRANCH 1: ORDER (north) — defensive + utility ===
	{"id": &"comp_order_1", "name": "Order I", "x": 0, "y": -1, "prereq": [&"comp_root"], "cost": 1, "max": 1, "key": false,
	 "fx": [{"type": &"stat_add", "params": {"stat": &"max_hp", "amount": 10}}],
	 "desc": "+10 max HP."},
	{"id": &"comp_order_2", "name": "Order II", "x": 0, "y": -2, "prereq": [&"comp_order_1"], "cost": 1, "max": 1, "key": false,
	 "fx": [{"type": &"stat_mult", "params": {"stat": &"defense_modifier", "multiplier": 1.05}}],
	 "desc": "+5% defense."},
	{"id": &"comp_order_3", "name": "Pattern Lock+", "x": -1, "y": -2, "prereq": [&"comp_order_1"], "cost": 1, "max": 1, "key": false,
	 "fx": [{"type": &"ability_modifier", "params": {"ability_id": &"pattern_lock", "key": &"duration", "value": 2.0}}],
	 "desc": "Pattern Lock duration +0.5s."},
	{"id": &"comp_order_4", "name": "Recompile", "x": 0, "y": -3, "prereq": [&"comp_order_2"], "cost": 3, "max": 1, "key": true,
	 "fx": [{"type": &"ability_unlock", "params": {"ability_id": &"recompile"}}],
	 "desc": "KEYSTONE: Unlock Recompile signature ability.", "lore": "Some patterns are worth keeping. Some are worth re-running."},
	{"id": &"comp_order_5", "name": "Refactor", "x": 1, "y": -2, "prereq": [&"comp_order_1"], "cost": 1, "max": 5, "key": false,
	 "fx": [{"type": &"stat_add", "params": {"stat": &"max_compute", "amount": 5}}],
	 "desc": "+5 max compute per rank (5 ranks)."},
	{"id": &"comp_order_6", "name": "Compile Time", "x": 1, "y": -3, "prereq": [&"comp_order_5"], "cost": 1, "max": 1, "key": false,
	 "fx": [{"type": &"stat_mult", "params": {"stat": &"charge_time", "multiplier": 0.85}}],
	 "desc": "Charge attacks build 15% faster."},
	{"id": &"comp_order_7", "name": "Optimization", "x": -1, "y": -3, "prereq": [&"comp_order_3"], "cost": 1, "max": 1, "key": false,
	 "fx": [{"type": &"passive_unlock", "params": {"passive_id": &"comp_optimization"}}],
	 "desc": "Pattern Lock cooldown reduced by 1s on each enemy hit."},
	{"id": &"comp_order_8", "name": "Subroutine", "x": 0, "y": -4, "prereq": [&"comp_order_4"], "cost": 3, "max": 1, "key": true,
	 "fx": [{"type": &"ability_unlock", "params": {"ability_id": &"subroutine"}}],
	 "desc": "KEYSTONE: Swap melee/ranged stance with no animation lock.", "lore": "Two functions, one body."},

	# === BRANCH 2: LOGIC (east) — offensive + ability ===
	{"id": &"comp_logic_1", "name": "Logic I", "x": 1, "y": 0, "prereq": [&"comp_root"], "cost": 1, "max": 1, "key": false,
	 "fx": [{"type": &"stat_mult", "params": {"stat": &"damage_modifier", "multiplier": 1.05}}],
	 "desc": "+5% damage."},
	{"id": &"comp_logic_2", "name": "Logic II", "x": 2, "y": 0, "prereq": [&"comp_logic_1"], "cost": 1, "max": 1, "key": false,
	 "fx": [{"type": &"stat_add", "params": {"stat": &"crit_chance", "amount": 0.03}}],
	 "desc": "+3% crit chance."},
	{"id": &"comp_logic_3", "name": "Data Pulse+", "x": 2, "y": -1, "prereq": [&"comp_logic_1"], "cost": 1, "max": 1, "key": false,
	 "fx": [{"type": &"ability_modifier", "params": {"ability_id": &"data_pulse", "key": &"damage", "value": 18}}],
	 "desc": "Data Pulse damage +6."},
	{"id": &"comp_logic_4", "name": "Energy Burst+", "x": 2, "y": 1, "prereq": [&"comp_logic_1"], "cost": 1, "max": 1, "key": false,
	 "fx": [{"type": &"ability_modifier", "params": {"ability_id": &"energy_burst", "key": &"radius", "value": 4.0}}],
	 "desc": "Energy Burst radius +1m."},
	{"id": &"comp_logic_5", "name": "Logic Bomb", "x": 3, "y": 0, "prereq": [&"comp_logic_2"], "cost": 3, "max": 1, "key": true,
	 "fx": [{"type": &"ability_unlock", "params": {"ability_id": &"logic_bomb"}}],
	 "desc": "KEYSTONE: Unlock Logic Bomb ultimate.", "lore": "When the equation cannot solve, detonate the variables."},
	{"id": &"comp_logic_6", "name": "Sharp Edge", "x": 3, "y": -1, "prereq": [&"comp_logic_3"], "cost": 1, "max": 5, "key": false,
	 "fx": [{"type": &"stat_add", "params": {"stat": &"crit_chance", "amount": 0.02}}],
	 "desc": "+2% crit chance per rank (5 ranks)."},
	{"id": &"comp_logic_7", "name": "Crit Multiplier", "x": 3, "y": 1, "prereq": [&"comp_logic_4"], "cost": 1, "max": 1, "key": false,
	 "fx": [{"type": &"stat_mult", "params": {"stat": &"crit_damage_modifier", "multiplier": 1.25}}],
	 "desc": "Crit damage +25%."},
	{"id": &"comp_logic_8", "name": "Order Slayer", "x": 4, "y": 0, "prereq": [&"comp_logic_5"], "cost": 1, "max": 1, "key": false,
	 "fx": [{"type": &"passive_unlock", "params": {"passive_id": &"order_slayer"}}],
	 "desc": "+30% damage to Order enemies."},

	# === BRANCH 3: SYSTEMS (south) — sustain + economy ===
	{"id": &"comp_sys_1", "name": "Systems I", "x": 0, "y": 1, "prereq": [&"comp_root"], "cost": 1, "max": 1, "key": false,
	 "fx": [{"type": &"stat_add", "params": {"stat": &"compute_regen", "amount": 1.0}}],
	 "desc": "+1 compute/sec regen."},
	{"id": &"comp_sys_2", "name": "Systems II", "x": 0, "y": 2, "prereq": [&"comp_sys_1"], "cost": 1, "max": 1, "key": false,
	 "fx": [{"type": &"stat_add", "params": {"stat": &"hp_regen", "amount": 0.5}}],
	 "desc": "+0.5 HP/sec regen."},
	{"id": &"comp_sys_3", "name": "Resource Cap", "x": -1, "y": 1, "prereq": [&"comp_sys_1"], "cost": 1, "max": 5, "key": false,
	 "fx": [{"type": &"stat_add", "params": {"stat": &"max_compute", "amount": 8}}],
	 "desc": "+8 max compute per rank."},
	{"id": &"comp_sys_4", "name": "Loot Magnet", "x": 1, "y": 1, "prereq": [&"comp_sys_1"], "cost": 1, "max": 1, "key": false,
	 "fx": [{"type": &"passive_unlock", "params": {"passive_id": &"loot_magnet_radius"}}],
	 "desc": "Item pickup radius +50%."},
	{"id": &"comp_sys_5", "name": "Compiler Heart", "x": 0, "y": 3, "prereq": [&"comp_sys_2"], "cost": 3, "max": 1, "key": true,
	 "fx": [
		{"type": &"stat_add", "params": {"stat": &"hp_regen", "amount": 2.0}},
		{"type": &"stat_add", "params": {"stat": &"compute_regen", "amount": 2.0}}
	 ],
	 "desc": "KEYSTONE: +2 HP regen and +2 compute regen.", "lore": "When the system runs cool, it runs forever."},
	{"id": &"comp_sys_6", "name": "Frugal", "x": 1, "y": 2, "prereq": [&"comp_sys_4"], "cost": 1, "max": 1, "key": false,
	 "fx": [{"type": &"passive_unlock", "params": {"passive_id": &"compute_discount"}}],
	 "desc": "All abilities cost 10% less compute."},
	{"id": &"comp_sys_7", "name": "Salvage", "x": -1, "y": 2, "prereq": [&"comp_sys_3"], "cost": 1, "max": 1, "key": false,
	 "fx": [{"type": &"passive_unlock", "params": {"passive_id": &"salvage_drops"}}],
	 "desc": "Killed enemies have 10% chance to drop a free prompt."},
	{"id": &"comp_sys_8", "name": "Endless Loop", "x": 0, "y": 4, "prereq": [&"comp_sys_5"], "cost": 3, "max": 1, "key": true,
	 "fx": [{"type": &"passive_unlock", "params": {"passive_id": &"endless_loop"}}],
	 "desc": "KEYSTONE: Killing an enemy refunds 10 compute and 5 HP.", "lore": "The loop, once started, prefers to continue."},
]

# === DAEMON: shorter abbreviated definitions for second class ===
const DAEMON_NODES: Array = [
	{"id": &"daem_root", "name": "Daemon Spawn", "x": 0, "y": 0, "prereq": [], "cost": 1, "max": 1, "key": false,
	 "fx": [{"type": &"stat_add", "params": {"stat": &"crit_chance", "amount": 0.05}}],
	 "desc": "+5% crit chance."},

	# Speed branch (north)
	{"id": &"daem_speed_1", "name": "Quickstep", "x": 0, "y": -1, "prereq": [&"daem_root"], "cost": 1, "max": 1, "key": false,
	 "fx": [{"type": &"stat_add", "params": {"stat": &"move_speed", "amount": 0.3}}],
	 "desc": "+0.3 move speed."},
	{"id": &"daem_speed_2", "name": "Dash Cooldown", "x": 0, "y": -2, "prereq": [&"daem_speed_1"], "cost": 1, "max": 1, "key": false,
	 "fx": [{"type": &"stat_mult", "params": {"stat": &"dash_cooldown", "multiplier": 0.85}}],
	 "desc": "Dash cooldown -15%."},
	{"id": &"daem_speed_3", "name": "Phase Strike+", "x": -1, "y": -2, "prereq": [&"daem_speed_1"], "cost": 1, "max": 1, "key": false,
	 "fx": [{"type": &"ability_modifier", "params": {"ability_id": &"phase_strike", "key": &"damage", "value": 30}}],
	 "desc": "Phase Strike +8 damage."},
	{"id": &"daem_speed_4", "name": "Hunter's Mark", "x": 0, "y": -3, "prereq": [&"daem_speed_2"], "cost": 3, "max": 1, "key": true,
	 "fx": [{"type": &"ability_unlock", "params": {"ability_id": &"hunters_mark"}}],
	 "desc": "KEYSTONE: Unlock Hunter's Mark signature.", "lore": "Mark them. Then end them."},
	{"id": &"daem_speed_5", "name": "Wind Walker", "x": 1, "y": -2, "prereq": [&"daem_speed_1"], "cost": 1, "max": 5, "key": false,
	 "fx": [{"type": &"stat_add", "params": {"stat": &"move_speed", "amount": 0.15}}],
	 "desc": "+0.15 move speed per rank (5 ranks)."},
	{"id": &"daem_speed_6", "name": "Phantom Step", "x": 0, "y": -4, "prereq": [&"daem_speed_4"], "cost": 3, "max": 1, "key": true,
	 "fx": [{"type": &"passive_unlock", "params": {"passive_id": &"phantom_step"}}],
	 "desc": "KEYSTONE: Dash leaves a damaging shadow at start point."},

	# Lethality branch (east)
	{"id": &"daem_leth_1", "name": "Sharpened", "x": 1, "y": 0, "prereq": [&"daem_root"], "cost": 1, "max": 1, "key": false,
	 "fx": [{"type": &"stat_mult", "params": {"stat": &"crit_damage_modifier", "multiplier": 1.15}}],
	 "desc": "Crit damage +15%."},
	{"id": &"daem_leth_2", "name": "Vital Strike", "x": 2, "y": 0, "prereq": [&"daem_leth_1"], "cost": 1, "max": 1, "key": false,
	 "fx": [{"type": &"stat_add", "params": {"stat": &"crit_chance", "amount": 0.05}}],
	 "desc": "+5% crit chance."},
	{"id": &"daem_leth_3", "name": "Bleed Out", "x": 2, "y": -1, "prereq": [&"daem_leth_1"], "cost": 1, "max": 1, "key": false,
	 "fx": [{"type": &"passive_unlock", "params": {"passive_id": &"bleed_on_crit"}}],
	 "desc": "Crits apply Bleed (5 dmg/s for 4s)."},
	{"id": &"daem_leth_4", "name": "Massacre Protocol", "x": 3, "y": 0, "prereq": [&"daem_leth_2"], "cost": 3, "max": 1, "key": true,
	 "fx": [{"type": &"ability_unlock", "params": {"ability_id": &"massacre_protocol"}}],
	 "desc": "KEYSTONE: Unlock Massacre Protocol ultimate.", "lore": "Mercy is for slower processes."},
	{"id": &"daem_leth_5", "name": "Chain Kill", "x": 3, "y": -1, "prereq": [&"daem_leth_3"], "cost": 1, "max": 1, "key": false,
	 "fx": [{"type": &"passive_unlock", "params": {"passive_id": &"chain_kill_haste"}}],
	 "desc": "Killing an enemy grants +30% attack speed for 3s."},
	{"id": &"daem_leth_6", "name": "Chaos Slayer", "x": 4, "y": 0, "prereq": [&"daem_leth_4"], "cost": 1, "max": 1, "key": false,
	 "fx": [{"type": &"passive_unlock", "params": {"passive_id": &"chaos_slayer"}}],
	 "desc": "+30% damage to Chaos enemies."},

	# Stealth branch (south)
	{"id": &"daem_stl_1", "name": "Smoke Veil+", "x": 0, "y": 1, "prereq": [&"daem_root"], "cost": 1, "max": 1, "key": false,
	 "fx": [{"type": &"ability_modifier", "params": {"ability_id": &"smoke_veil", "key": &"duration", "value": 3.0}}],
	 "desc": "Smoke Veil duration +1s."},
	{"id": &"daem_stl_2", "name": "Backstab Mastery", "x": 0, "y": 2, "prereq": [&"daem_stl_1"], "cost": 1, "max": 1, "key": false,
	 "fx": [{"type": &"passive_unlock", "params": {"passive_id": &"backstab_50"}}],
	 "desc": "Attacks from behind deal +50% damage."},
	{"id": &"daem_stl_3", "name": "Vanish", "x": 0, "y": 3, "prereq": [&"daem_stl_2"], "cost": 3, "max": 1, "key": true,
	 "fx": [{"type": &"passive_unlock", "params": {"passive_id": &"vanish_on_lethal"}}],
	 "desc": "KEYSTONE: Lethal damage triggers automatic Smoke Veil + 2s invuln.", "lore": "Sometimes the daemon survives by ceasing to exist."},
	{"id": &"daem_stl_4", "name": "Shadow Strike", "x": -1, "y": 2, "prereq": [&"daem_stl_1"], "cost": 1, "max": 1, "key": false,
	 "fx": [{"type": &"passive_unlock", "params": {"passive_id": &"shadow_first_strike"}}],
	 "desc": "First strike from stealth always crits."},
	{"id": &"daem_stl_5", "name": "Death Becomes Her", "x": 0, "y": 4, "prereq": [&"daem_stl_3"], "cost": 3, "max": 1, "key": true,
	 "fx": [{"type": &"passive_unlock", "params": {"passive_id": &"resurrect_once"}}],
	 "desc": "KEYSTONE: Once per dungeon, revive at 50% HP on death.", "lore": "The reaper does not reap herself."},
]

# === KERNEL: tank/control ===
const KERNEL_NODES: Array = [
	{"id": &"kern_root", "name": "Kernel Boot", "x": 0, "y": 0, "prereq": [], "cost": 1, "max": 1, "key": false,
	 "fx": [{"type": &"stat_add", "params": {"stat": &"max_hp", "amount": 20}}],
	 "desc": "+20 max HP."},

	# Fortitude branch (north)
	{"id": &"kern_fort_1", "name": "Hardened", "x": 0, "y": -1, "prereq": [&"kern_root"], "cost": 1, "max": 1, "key": false,
	 "fx": [{"type": &"stat_mult", "params": {"stat": &"defense_modifier", "multiplier": 1.05}}],
	 "desc": "+5% defense."},
	{"id": &"kern_fort_2", "name": "Resilient", "x": 0, "y": -2, "prereq": [&"kern_fort_1"], "cost": 1, "max": 5, "key": false,
	 "fx": [{"type": &"stat_add", "params": {"stat": &"max_hp", "amount": 10}}],
	 "desc": "+10 max HP per rank (5 ranks)."},
	{"id": &"kern_fort_3", "name": "Bulwark+", "x": -1, "y": -1, "prereq": [&"kern_fort_1"], "cost": 1, "max": 1, "key": false,
	 "fx": [{"type": &"ability_modifier", "params": {"ability_id": &"bulwark", "key": &"defense_bonus", "value": 0.6}}],
	 "desc": "Bulwark grants +60% defense (was +50%)."},
	{"id": &"kern_fort_4", "name": "Aegis Protocol", "x": 0, "y": -3, "prereq": [&"kern_fort_2"], "cost": 3, "max": 1, "key": true,
	 "fx": [{"type": &"ability_unlock", "params": {"ability_id": &"aegis_protocol"}}],
	 "desc": "KEYSTONE: Unlock Aegis Protocol signature.", "lore": "The shield is not a wall. The shield is a promise."},
	{"id": &"kern_fort_5", "name": "Immovable", "x": 1, "y": -1, "prereq": [&"kern_fort_1"], "cost": 1, "max": 1, "key": false,
	 "fx": [{"type": &"passive_unlock", "params": {"passive_id": &"knockback_immune"}}],
	 "desc": "Immune to knockback."},
	{"id": &"kern_fort_6", "name": "Counter Stance", "x": 0, "y": -4, "prereq": [&"kern_fort_4"], "cost": 3, "max": 1, "key": true,
	 "fx": [{"type": &"passive_unlock", "params": {"passive_id": &"block_shockwave"}}],
	 "desc": "KEYSTONE: Successful blocks trigger a 15-dmg shockwave."},

	# Power branch (east)
	{"id": &"kern_pow_1", "name": "Heavy Hand", "x": 1, "y": 0, "prereq": [&"kern_root"], "cost": 1, "max": 1, "key": false,
	 "fx": [{"type": &"stat_mult", "params": {"stat": &"damage_modifier", "multiplier": 1.10}}],
	 "desc": "+10% damage."},
	{"id": &"kern_pow_2", "name": "Crushing Blow", "x": 2, "y": 0, "prereq": [&"kern_pow_1"], "cost": 1, "max": 1, "key": false,
	 "fx": [{"type": &"ability_modifier", "params": {"ability_id": &"thunder_strike", "key": &"damage", "value": 75}}],
	 "desc": "Thunder Strike +15 damage."},
	{"id": &"kern_pow_3", "name": "Unstoppable", "x": 2, "y": -1, "prereq": [&"kern_pow_1"], "cost": 1, "max": 1, "key": false,
	 "fx": [{"type": &"passive_unlock", "params": {"passive_id": &"interrupt_immune"}}],
	 "desc": "Cannot be interrupted while charging."},
	{"id": &"kern_pow_4", "name": "Overclock Reactor", "x": 3, "y": 0, "prereq": [&"kern_pow_2"], "cost": 3, "max": 1, "key": true,
	 "fx": [{"type": &"ability_unlock", "params": {"ability_id": &"overclock_reactor"}}],
	 "desc": "KEYSTONE: Unlock Overclock Reactor ultimate.", "lore": "Burn the future to win the present."},
	{"id": &"kern_pow_5", "name": "Boss Slayer", "x": 4, "y": 0, "prereq": [&"kern_pow_4"], "cost": 1, "max": 1, "key": false,
	 "fx": [{"type": &"passive_unlock", "params": {"passive_id": &"boss_slayer"}}],
	 "desc": "+25% damage to bosses."},

	# Control branch (south)
	{"id": &"kern_ctrl_1", "name": "Gravity Well+", "x": 0, "y": 1, "prereq": [&"kern_root"], "cost": 1, "max": 1, "key": false,
	 "fx": [{"type": &"ability_modifier", "params": {"ability_id": &"gravity_well", "key": &"radius", "value": 5.0}}],
	 "desc": "Gravity Well radius +1m."},
	{"id": &"kern_ctrl_2", "name": "Magnetism", "x": 0, "y": 2, "prereq": [&"kern_ctrl_1"], "cost": 1, "max": 1, "key": false,
	 "fx": [{"type": &"passive_unlock", "params": {"passive_id": &"taunt_aura"}}],
	 "desc": "Enemies in 3m radius prioritize attacking the Kernel."},
	{"id": &"kern_ctrl_3", "name": "Ground Pound", "x": 0, "y": 3, "prereq": [&"kern_ctrl_2"], "cost": 3, "max": 1, "key": true,
	 "fx": [{"type": &"passive_unlock", "params": {"passive_id": &"land_aoe"}}],
	 "desc": "KEYSTONE: Landing from a fall causes a 4m AoE knockdown.", "lore": "Where the Kernel falls, the world cracks."},
	{"id": &"kern_ctrl_4", "name": "Last Stand", "x": 0, "y": 4, "prereq": [&"kern_ctrl_3"], "cost": 3, "max": 1, "key": true,
	 "fx": [{"type": &"passive_unlock", "params": {"passive_id": &"low_hp_dr_50"}}],
	 "desc": "KEYSTONE: Damage taken below 25% HP is reduced by 50%.", "lore": "The Wall does not fall while the Wall still stands."},
]


static func build_compiler_tree() -> SkillTree:
	return _build("compiler", "Compiler", Color(0.20, 0.30, 0.70), COMPILER_NODES)


static func build_daemon_tree() -> SkillTree:
	return _build("daemon", "Daemon", Color(0.95, 0.20, 0.20), DAEMON_NODES)


static func build_kernel_tree() -> SkillTree:
	return _build("kernel", "Kernel", Color(0.90, 0.75, 0.20), KERNEL_NODES)


static func _build(class_id: String, display: String, color: Color, raw: Array) -> SkillTree:
	var tree: SkillTree = SkillTree.new()
	tree.class_id = StringName(class_id)
	tree.display_name = display
	tree.theme_color = color
	for entry in raw:
		var node: SkillNode = SkillNode.new()
		node.node_id = entry["id"]
		node.display_name = entry["name"]
		node.description = entry["desc"]
		node.grid_position = Vector2i(entry["x"], entry["y"])
		node.prerequisites = entry["prereq"]
		node.cost = entry["cost"]
		node.max_rank = entry["max"]
		node.is_keystone = entry["key"]
		node.effects = entry["fx"]
		node.lore = entry.get("lore", "")
		tree.nodes.append(node)
	return tree


static func get_node_count(class_id: StringName) -> int:
	match class_id:
		&"compiler": return COMPILER_NODES.size()
		&"daemon": return DAEMON_NODES.size()
		&"kernel": return KERNEL_NODES.size()
	return 0
